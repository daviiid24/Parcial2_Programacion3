defmodule SopaArchivos do
 
  def leer_sopa(ruta_archivo) do
    if File.exists?(ruta_archivo) do
      ruta_archivo
      |> File.stream!()
      |> Stream.map(&String.trim/1)
      |> Stream.reject(fn linea -> linea == "" or String.starts_with?(linea, "#") end)
      |> Stream.with_index()
      |> Enum.reduce(%{}, fn {linea, fila}, mapa_acc ->
        linea
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(mapa_acc, fn {letra, columna}, mapa_fila ->
          Map.put(mapa_fila, {fila, columna}, String.upcase(letra))
        end)
      end)
    else
      IO.puts("Error: El archivo #{ruta_archivo} no existe.")
      %{}
    end
  end

  def leer_palabras(ruta_archivo) do
    if File.exists?(ruta_archivo) do
      ruta_archivo
      |> File.stream!()
      |> Stream.map(&String.trim/1)
      |> Stream.reject(fn linea -> linea == "" or String.starts_with?(linea, "#") end)
      |> Stream.map(&String.upcase/1)
      |> Enum.uniq()
    else
      IO.puts("Error: El archivo #{ruta_archivo} no existe.")
      []
    end
  end
end
