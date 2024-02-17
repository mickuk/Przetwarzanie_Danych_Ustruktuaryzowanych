# Michał Kukla, 311134
# PDU - pierwsza praca domowa


calka <- function(f, a, b, n=100, alfa=0.5){
  # funkcja ta wyznaczy całkę funkcji f na przedziale [a,b]
  # przy użyciu metody prostokątów
  
  stopifnot(is.function(f))  # musi to być funkcja
  stopifnot(is.numeric(a), is.numeric(b), # a i b to 'liczby rzeczywiste'
            length(a) == 1, length(b) == 1,
            a < b)
  stopifnot(is.numeric(n), n > 0, n == floor(n))  # tutaj n jest domyślnie
  # wprowadzane, ale gdy użytkownik chce je zmienić to trzeba sprawdzić
  
  stopifnot(is.numeric(alfa), length(alfa) == 1)
  stopifnot(alfa <=1 & alfa >= 0)  # przy testowaniu funkcji doszedłem i po
  # spojrzeniu na przykładowe wartości doszedłem do wniosku, że alfa należy do
  # przedziału [0,1]. Gdy wychodzi poza ten przedział, to wartości naszej
  # całki odbiegają od prawdziwej wartości
  

  h = (b-a)/n
  
  x = seq(from = a, to = b-h, by = h)  # tworzymy wektor x. Będzie to ciąg
  #arytmetyczny od a do b-h (ponieważ w szeregu nie bierzemy wyrazu xn = b)
  
  
  h*sum(f(x + alfa*h))  # sumujemy wartości funkcji pomnożone przez h,
  # czyli h*(f(x0 + alfa*h) + f(x1 + alfa*h) +...+ f(x_(n-1) + alfa*h))
  # ten wynik otrzymamy po wywołaniu funkcji
  
}


# Przekopiowana funkcja całka Monte Carlo
# Będzie służyć do sprawdzenia wyników pod koniec zadania

calkaMonteCarlo <- function(f, a, b, n = 1000){
  # Funkcja wyznacza caĹ‚kÄ™ funkcji przy uzyciu metodu Monte Carlo
  # Argumenty funkcji:
  # f - funkcja scisle monotoniczna  (tego nie sprawdzamy)
  #     o wartosciach nieujemnych (spr. zob. ponizej)
  # a, b - granice przedzialu, na ktorym calkujemy funkcje
  #        a < b
  # n - dokladnosc obliczen
  # Sprawdzenie warunkow poprawnosci:
  stopifnot(is.function(f))
  stopifnot(is.numeric(a), length(a) == 1, 
            is.numeric(b), length(b) == 1,
            a < b)
  stopifnot(is.numeric(n), n > 0, n == floor(n))
  
  fa = f(a) # wartosci funkcji na krancach przedzialu
  fb = f(b)
  
  # sprawdzamy czy wartosci na krancach przedzialu sa nieujemne:
  stopifnot(fa >= 0, fb >= 0) 
  # Postepujemy zgodnie z algorytmem opisanym w zadaniu:
  fMIN = min(fa, fb)
  fMAX = max(fa, fb)
  
  x <- runif(n, min = a, max = b) # ?runif - liczba pseudolosowa 
  # z  przedzialu [a,  b]
  y <- runif(n, fMIN, fMAX)
  # Wynik:
  ( sum(y <= f(x))/n ) * (b - a) * (fMAX - fMIN) + (b - a) * fMIN
  
}

# Sprawdzamy, czy nasza funkcja daje te same wartości co w treści zadania
# Całka i integrate dadzą te same wartości, natomiast wartość calkaMonteCarlo
# najprawdopodobniej nie będzie taka sama - przez użycie funkcji runif

integrate(dnorm, 0, 3)
calka(dnorm, 0, 3, 100, alfa = 0)
calka(dnorm, 0, 3, 100)
calka(dnorm, 0, 3, 100, alfa = 1)
calkaMonteCarlo(dnorm, 0, 3, 100)
calkaMonteCarlo(dnorm, 0, 3, 1000)


# Teraz przygotuję kilka przykładowych funkcji


kwadrat <- function(x) x*x
dziwna <- function(x){
  (1/sqrt(3*pi))*exp(-(x^3)/5)
}

sincos <- function(x) sin(x)*cos(x)
wiel <- function(x) 6*x^3 + 3.2*x^2 + 5 

# A teraz sprawdzimy poprawność. Paramentr n pozostawimy jako 100

# kwadrat

integrate(kwadrat, 0, 3)
calka(kwadrat, 0, 3, 100, alfa = 0)
calka(kwadrat, 0, 3, 100)
calka(kwadrat, 0, 3, 100, alfa = 1)
calkaMonteCarlo(kwadrat, 0, 3, 100)
calkaMonteCarlo(kwadrat, 0, 3, 1000)

# dziwna

integrate(dziwna, 0, 3)
calka(dziwna, 0, 3, 100, alfa = 0)
calka(dziwna, 0, 3, 100)
calka(dziwna, 0, 3, 100, alfa = 1)
calkaMonteCarlo(dziwna, 0, 3, 100)
calkaMonteCarlo(dziwna, 0, 3, 1000)

# sincos
# tutaj wziąłem przedział [0,1], by zadziałała funkcja
# calkaMonteCarlo - gdzie f(a)>=0 i f(b)>=0

integrate(sincos, 0, 1)
calka(sincos, 0, 1, 100, alfa = 0)
calka(sincos, 0, 1, 100)
calka(sincos, 0, 1, 100, alfa = 1)
calkaMonteCarlo(sincos, 0, 1, 100)
calkaMonteCarlo(sincos, 0, 1, 1000)

# wiel

integrate(wiel, 0, 3)
calka(wiel, 0, 3, 100, alfa = 0)
calka(wiel, 0, 3, 100)
calka(wiel, 0, 3, 100, alfa = 1)
calkaMonteCarlo(wiel, 0, 3, 100)
calkaMonteCarlo(wiel, 0, 3, 1000)


# Jak widać, funkcja calka dosyć dobrze przybliża wartość całek
# Najbliżej wyniku byłem, gdy alfa to około 0,5.





