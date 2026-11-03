defmodule SopaReporte do

  def generar_reporte(sopa, palabras, total_filas, total_columnas, archivo_salida) do

    {:ok, file} = File.open(archivo_salida, [:write, :utf8])


    letras_sopa = contar_letras_sopa_recursivo(Map.values(sopa), %{})


    {encontradas, total} = procesar_palabras(palabras, sopa, letras_sopa, total_filas, total_columnas, file, 0, 0)


    IO.write(file, "\nPalabras encontradas: #{encontradas} de #{total}\n")
    File.close(file)

    IO.puts("¡Búsqueda finalizada! Resultados escritos en #{archivo_salida}")
  end


  defp procesar_palabras([], _sopa, _letras_sopa, _tf, _tc, _file, encontradas, total), do: {encontradas, total}

  defp procesar_palabras([palabra | resto_palabras], sopa, letras_sopa, tf, tc, file, encontradas, total) do
    IO.write(file, "Palabra: #{palabra}\n")

    # 1. Validación previa
    if SopaRecursion.palabra_posible?(palabra, letras_sopa) do
      # 2. Búsqueda
      rutas = SopaRecursion.buscar_todas(sopa, tf, tc, palabra)

      if rutas == [] do
        IO.write(file, "Encontrada: No (estaban las letras pero no formaban la palabra)\n\n")
        procesar_palabras(resto_palabras, sopa, letras_sopa, tf, tc, file, encontradas, total + 1)
      else
        cantidad_formas = longitud_lista(rutas, 0)
        plural = if cantidad_formas == 1, do: "forma", else: "formas"
        IO.write(file, "Encontrada: Sí (#{cantidad_formas} #{plural})\n")


        escribir_rutas(rutas, 1, file)
        IO.write(file, "\n")

        procesar_palabras(resto_palabras, sopa, letras_sopa, tf, tc, file, encontradas + 1, total + 1)
      end
    else

      letras_faltantes = identificar_faltantes(palabra, letras_sopa)
      IO.write(file, "Encontrada: No (descartada: la sopa no tiene #{letras_faltantes})\n\n")
      procesar_palabras(resto_palabras, sopa, letras_sopa, tf, tc, file, encontradas, total + 1)
    end
  end


  defp escribir_rutas([], _indice, _file), do: :ok
  defp escribir_rutas([ruta | resto_rutas], indice, file) do
    inicio = hd(ruta)
    final = hd(Enum.reverse(ruta))
    direccion = calcular_direccion(ruta)


    IO.write(file, "Forma #{indice}: comienza en {#{elem(inicio, 0)},#{elem(inicio, 1)}}, termina en {#{elem(final, 0)},#{elem(final, 1)}}, dirección #{direccion}\n")


    ruta_formateada = Enum.map_join(ruta, " -> ", fn {f, c} -> "{#{f},#{c}}" end)
    IO.write(file, "#{ruta_formateada}\n")

    escribir_rutas(resto_rutas, indice + 1, file)
  end


  defp calcular_direccion([_una_sola_letra]), do: "ninguna"
  defp calcular_direccion([{f1, c1}, {f2, c2} | _]) do
    case {f2 - f1, c2 - c1} do
      {0, 1} -> "derecha"
      {0, -1} -> "izquierda"
      {1, 0} -> "abajo"
      {-1, 0} -> "arriba"
      {1, 1} -> "abajo-derecha"
      {1, -1} -> "abajo-izquierda"
      {-1, 1} -> "arriba-derecha"
      {-1, -1} -> "arriba-izquierda"
      _ -> "desconocida"
    end
  end


  defp identificar_faltantes(palabra, letras_sopa) do
    freqs = Enum.frequencies(String.graphemes(palabra))
    freqs
    |> Enum.filter(fn {letra, cant_nec} -> cant_nec > Map.get(letras_sopa, letra, 0) end)
    |> Enum.map(fn {letra, _} -> letra end)
    |> Enum.join(", ")
  end


  defp contar_letras_sopa_recursivo([], mapa), do: mapa
  defp contar_letras_sopa_recursivo([letra | resto], mapa) do
    contar_letras_sopa_recursivo(resto, Map.update(mapa, letra, 1, &(&1 + 1)))
  end


  defp longitud_lista([], acc), do: acc
  defp longitud_lista([_ | resto], acc), do: longitud_lista(resto, acc + 1)
end
