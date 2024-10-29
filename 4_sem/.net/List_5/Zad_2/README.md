# Lista 5
| 1  | 2  |  3 | 4 |
| -----------------|
| 3p | 3p | 1p | - |

## Zadanie 1
Dlaczego w pierwszym aby program dzia�a� musimy da� Tryb Release zamiast Debug

### Odpowied�: 
Po prostu Debug wp�ywa na wydajno��, czasem warunkach zamiast 1 zmiennej przechowuje dodatkowo drug�.


## Zadanie 2
- Nie rozumiem dlaczego odwo�uj�c si� ca�y czas do indexes[0] otrzymujemy nowy indeks.
- Dlaczego nie mog� zrobi� 
	```
		if(dictionary.ContainsKey(index.ToString())){
			return dictionary.TryGetValue(index.ToString(), out result)
		}
		else{
			return false
		}
	``` 
W sumie chodzi mi tutaj o to, �e czemu musz� przypisa� jak�� warto�� dla result 

### Odpowied�:
- W tym indexes[0] to odwo�ujemy si� do pierwszej tablicy po prostu
- I w tym result musimy przypisa� jak�� zmienn�, bo jak w C# mamy typ out to musimy przypisa� mu warto�� przed zako�czeniem funkcji. 

## Zadanie 3
Nie rozumiem, sutuacji napisanej przez mnie 
Czyli wywo�uje w g��wnej metodzie asynchronicznie **PrintSome**, jej wykonanie trwa d�u�ej ni� kolejne op�nienie w g��wnej metodzie. Kiedy wszystkie funkcje w g��nej metodzie si� wykonaj�, to nie czekaj� na zako�czenie funkcji **PrintSome** i ko�czy si� program. 

### Odpowied�: 
- W skr�cie interpreter C# jest g�upi XD, je�li sko�czy si� funkcja Main  to nie czeka na sko�czenie innych funkcji. 

# Zadanie 4
Nie wiem dlaczego nie mog� zrobi� takiego w�a�nie rozwi�zania

### Odpowied�:
- TO-DO - Trzeba na to spojrze� jeszcze. 