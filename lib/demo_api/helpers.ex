defmodule Helpers do

  def get_base_headers() do
    %{
      "api-key": Credentials.get("api-key"),
      "device-id": Credentials.get("device-id"),
      "content-type": "application/json",
      accept: "application/json",
      "user-agent": "Demo Bank iOS 2.0"
    }
  end

  def get_mfa_headers() do
    Map.merge(get_base_headers(), %{
      "r-token" => Credentials.get("r-token"),
      "f-token" =>  Credentials.get("f-token"),
      "demo-mission" => "accepted!",
    })
  end

  def get_reauthenticated_headers() do
    Map.merge(get_mfa_headers(), %{
      "s-token" => Credentials.get("s-token")
    })
  end

  def get_f_token_from_spec(f_token_spec) do
    {:ok, decoded} = Base.decode64(f_token_spec)

    decoded
    |> get_f_token_signature
    |> get_f_token_string
    |> encode_f_token_string
  end

  defp get_f_token_signature(str) do
    str
    |> String.slice(15..-2)
    |> String.slice(0..-1)
  end

  defp get_f_token_string(string) do
    delimeter = get_f_token_delimeter(string)
    f_token_fields = get_f_token_fields(string)
    f_token_field_values = Enum.map(f_token_fields, fn key -> Credentials.get(key) end)

    Enum.join(f_token_field_values, Enum.join(delimeter, ""))
  end

  defp encode_f_token_string(string) do
    :crypto.hash(:sha256, string)
    |> Base.encode64()
    |> String.trim_trailing("=")
  end 

  defp get_f_token_fields(string) do
    regex = ~r/(?:[^-\p{L}]+|--)/
    String.split(string, regex)
  end

  defp get_f_token_delimeter(string) do
    regex = ~r/(?:[^-\p{L}]+|--)/
    Regex.run(regex, string)
  end

  def parseEncryptionKey(resp) do
    enc_key = Jason.decode!(resp)["data"]["enc_key"]
    { :ok, decoded_signature } = Base.decode64(enc_key)
    Jason.decode!(decoded_signature)["key"]
  end

  def decrypt_account_number(resp) do
    [ct, iv, t] = String.split(Jason.decode!(resp)["number"], ":")
    {:ok, key} = Base.decode64(Credentials.get("enc-key"))
    {:ok, ct} = Base.decode64(ct)
    {:ok, iv} = Base.decode64(iv)
    {:ok, t} = Base.decode64(t)
    aad = Credentials.get("username")

    :crypto.crypto_one_time_aead(
      :aes_256_gcm, 
      key,
      iv,
      ct,
      aad,
      t,
      false
    )
  end
end