## Zadanie 2
Aby doda� nowy component do windows forms b�dziemy chcieli u�y� do tego nowej klasy, kt�ra b�dzie dziedziczy� po jakim obiekcie z windows forms.
Jednak, je�li chcemy u�y� do tego klasy w wersji nowszej .net, to musimy w pliku xml wpisa�
```
<UseWindowsForms>true</UseWindowsForms>
```
oraz wej�� we w�a�ciwo�ci klasy i w target OS ustawi� na Windows.

### Pytania
- Zapyta� dlaczego jak zmienie warto�� jakie� zmiennej dla danego obiektu, to czemu w desinerze si� to nie zmienia.