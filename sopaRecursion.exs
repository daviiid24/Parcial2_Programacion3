defmodule SopaRecursion do
  @direcciones [
    {0, 1},   # Derecha
    {0, -1},  # Izquierda
    {1, 0},   # Abajo
    {-1, 0},  # Arriba
    {1, 1},   # Abajo-derecha
    {1, -1},  # Abajo-izquierda
    {-1, 1},  # Arriba-derecha
    {-1, -1}  # Arriba-izquierda
  ]


  def palabra_posible?(palabra, letras_sopa) do
    frecuencias_palabra = contar_letras_recursivo(String.graphemes(palabra), %{})
    comparar_frecuencias(Map.keys(frecuencias_palabra), frecuencias_palabra, letras_sopa)
  end


  defp contar_letras_recursivo([], mapa_frecuencias), do: mapa_frecuencias
  defp contar_letras_recursivo([letra | resto], mapa_frecuencias) do
    nuevo_mapa = Map.update(mapa_frecuencias, letra, 1, &(&1 + 1))
    contar_letras_recursivo(resto, nuevo_mapa)
  end


  defp comparar_frecuencias([], _req, _disp), do: true
  defp comparar_frecuencias([letra | resto_letras], req, disp) do
    necesarias = Map.get(req, letra, 0)
    disponibles = Map.get(disp, letra, 0)

    if necesarias <= disponibles do
      comparar_frecuencias(resto_letras, req, disp)
    else
      false
    end
  end


  def buscar_todas(sopa, total_filas, total_columnas, palabra) do
    letras = String.graphemes(palabra)
    recorrer_filas(0, total_filas, total_columnas, sopa, letras, [])
  end


  defp recorrer_filas(fila, total_filas, _cols, _sopa, _palabra, resultados)
       when fila >= total_filas, do: resultados


  defp recorrer_filas(fila, total_filas, total_columnas, sopa, palabra, resultados) do
    resultados_fila = recorrer_columnas(fila, 0, total_columnas, sopa, palabra, [])
    recorrer_filas(fila + 1, total_filas, total_columnas, sopa, palabra, concatenar_listas(resultados, resultados_fila))
  end


  defp recorrer_columnas(_fila, col, total_columnas, _sopa, _palabra, resultados)
       when col >= total_columnas, do: resultados


  defp recorrer_columnas(fila, col, total_columnas, sopa, palabra, resultados) do
    resultados_celda = probar_direcciones(@direcciones, fila, col, sopa, palabra, [])
    recorrer_columnas(fila, col + 1, total_columnas, sopa, palabra, concatenar_listas(resultados, resultados_celda))
  end


  defp probar_direcciones([], _f, _c, _sopa, _palabra, resultados), do: resultados


  defp probar_direcciones([{df, dc} | resto_dir], f, c, sopa, palabra, resultados) do
    case comparar_letras(f, c, df, dc, sopa, palabra, []) do
      nil ->
        probar_direcciones(resto_dir, f, c, sopa, palabra, resultados)
      ruta ->

        probar_direcciones(resto_dir, f, c, sopa, palabra, [revertir_lista(ruta, []) | resultados])
    end
  end


  defp comparar_letras(_f, _c, _df, _dc, _sopa, [], ruta), do: ruta


  defp comparar_letras(f, c, df, dc, sopa, [letra_buscada | resto_palabra], ruta) do
    case Map.get(sopa, {f, c}) do
      ^letra_buscada ->

        comparar_letras(f + df, c + dc, df, dc, sopa, resto_palabra, [{f, c} | ruta])
      _ ->

        nil
    end
  end


  defp concatenar_listas([], lista2), do: lista2
  defp concatenar_listas([cabeza | cola], lista2), do: [cabeza | concatenar_listas(cola, lista2)]

  
  defp revertir_lista([], acumulador), do: acumulador
  defp revertir_lista([cabeza | cola], acumulador), do: revertir_lista(cola, [cabeza | acumulador])
end
