#Kukla_Michal_PD2.R
# PDU Praca domowa nr 2
# Michał Kukla 311134


# Ropoczniemy od zainstalowania potrzebnych pakietów

install.packages(c("sqldf","dplyr","data.table"))

# I załączymy te pakiety
library("sqldf")
library("dplyr")
library("data.table")
library("microbenchmark")

# Dokumentacja pakietów
help(package = "data.table") 
help(package = "sqldf")
help(package = "dplyr")

# Setup
options(stringsAsFactors=FALSE)  # ustawiam na wszelki wypadek tutaj, by nie zapomnieć w kolejnych zadaniach



# Załączamy ramki danych

Badges <- read.csv("travel_stackexchange_com/Badges.csv.gz")  # odczytujemy ramki danych
Comments <- read.csv("travel_stackexchange_com/Comments.csv.gz")
PostLinks <- read.csv("travel_stackexchange_com/PostLinks.csv.gz")
Posts <- read.csv("travel_stackexchange_com/Posts.csv.gz")
Tags <- read.csv("travel_stackexchange_com/Tags.csv.gz")
Users <- read.csv("travel_stackexchange_com/Users.csv.gz")
Votes <- read.csv("travel_stackexchange_com/Votes.csv.gz")

# Spojrzymy wstępnie na nazwy kolumn i kilka wierszy

head(Badges) # Id, UserId, Name, Date, Class, TagBased ---6
head(Comments) # Id, PostId, Score, CreationDate, UserId, ContentLicense ---6
head(PostLinks) # Id, CreationDate, PostId, RelatedPostId, LinkTypeId ---5
head(Posts) # tutaj mamy aż 22 kolumny, więc użyjemy colnames ---22
colnames(Posts)
head(Tags) # Id, TagName, Count, ExcerptPostId, WikiPostId ---5
head(Users) # tak samo dużo kolumn ---12
colnames(Users) # 12 kolumn
head(Votes) # Id, PostId, VoteTypeId, CreationDate, UserId, BountyAmount ---6




#-----------------------------------------------------------
# TERAZ ROZPOCZNĘ ZADANIA


# Zadanie 1


# a) Za pomocą sqldf
#?sqldf::sqldf()

sqldf("SELECT Count, TagName
      FROM Tags
      WHERE Count > 1000
      ORDER BY Count DESC") -> wynik1

wynik1  # Tak wygląda ramka danych po poleceniu w SQL


df_sql_1 <- function(Tags){
  stopifnot(is.data.frame(Tags))  # tak normalnie pisałbym warunek, ale ta funkcja będzie działać tylko dla Tags (w zależności od nazw kolumn)
  sqldf("SELECT Count, TagName
      FROM Tags
      WHERE Count > 1000
      ORDER BY Count DESC")
}


dplyr::all_equal(wynik1, df_sql_1(Tags))
# Funkcja napisana przy pomocy sqldf::sqldf() jest napisana poprawnie
# Następnym razem nie będziemy tworzyć zmiennej "wynik",
# tylko od razu zakładać, że df_sql_i jest poprawne

# b) Za pomocą funkcji bazowych

df_base_1 <- function(Tags){
x <- na.omit(Tags[Tags$Count > 1000, c("Count", "TagName")])  # wybieramy (pomijając NA) z Tags wiersze, gdzie Count > 1000 i kolumny Count oraz Tagname
x <- x[order(x$Count, decreasing = TRUE),]  # szeregujemy, by Count było malejąco 
rownames(x) <- NULL  # mogliśmy kolumnę 1 zamienić z kolumną 500. Wtedy kolejność wierszy to 500,2,3,4,...
# chcemy to usunąć, dlatego stosujemy rownames(x) <- NULL. Teraz wiersze to 1,2,3,4,..., czyli ok
x
}

dplyr::all_equal(df_sql_1(Tags), df_base_1(Tags)) # TRUE


# c) za pomocą pakietu dplyr

df_dplyr_1 <- function(Tags){
a1 <- Tags %>% arrange(desc(Count))  # szeregujemy Tags tak, by wartości z Count były malejąco
a2 <- select(a1, Count, TagName)  # z otrzymanej ramki bierzemy Count oraz Tagname
a3 <- a2 %>% filter(Count > 1000)  # bierzemy te wiersze, gdzie Count > 1000
a3
}

dplyr::all_equal(df_sql_1(Tags), df_dplyr_1(Tags)) # TRUE


# d) za pomocą data.table

df_table_1 <- function(Tags){
Tag_1 <- data.table(Tags)  # zamieniamy na data.table
ans <- Tag_1[, .(Count, TagName)]  # wybieramy wiersze Count i Tagname
ans <- ans[order(-Count)]  # zmieniamy kolejność wierszy, by Count było malejąco
ans <- ans[with(ans, Count>1000)]  # wybieramy te wiersze, gdzie Count > 1000
ans
}

dplyr::all_equal(df_sql_1(Tags), df_table_1(Tags)) # TRUE


# Zadanie 2

# a) za pomocą sqldf

df_sql_2 <- function(Users, Posts){
  sqldf("SELECT Location, COUNT(*) AS Count
FROM (
    SELECT Posts.OwnerUserId, Users.Id, Users.Location
    FROM Users
    JOIN Posts ON Users.Id = Posts.OwnerUserId
)
WHERE Location NOT IN ('')
GROUP BY Location
ORDER BY Count DESC
LIMIT 10")
}



# b) za pomocą funkcji bazowych

df_base_2 <- function(Users, Posts){
x <- merge(Users, Posts,  # łączymy kolumny Id oraz OwnerUserId, robimy inner join, dlatego all = FALSE
           by.x ='Id', by.y = 'OwnerUserId', all = FALSE)
colnames(x)[13] <- 'OwnerUserId'  # zamieniam Id.y na dobrą nazwę
x <- x[,c("OwnerUserId", "Id", "Location")]  # bierzemy (SELECT) tylko te wiersze
Baza <-x
# Mamy już ramkę A - jest nią Baza
Baza$Location[which(Baza$Location == "")] <- NA  # zamieniam wartości "" na NA (ponieważ linijka niżej był problem, jak było Baza$Location != "")
x <- as.data.frame( table( Baza[ !is.na(Baza$Location),  # Pomijam wartości NA, grupuję po lokacji, zlicząc ich wystąpienia w ramce Baza
                                   "Location" ] ),
                    stringsAsFactors = FALSE)
colnames(x) <- c("Location", "Count")  # Zamieniam nazwy kolumn na odpowiednie
rownames(x) <- NULL  # chcę, by wiersze były o "nazwach" 1,2,3,4,...
x <- x[order(x$Count, decreasing = TRUE),]  # szereguję, by Count było malejąco
head(x,10)  # wybieram 10 pierwszych linijek
}

dplyr::all_equal(df_sql_2(Users,Posts), df_base_2(Users,Posts)) #TRUE


# c) za pomocą pakietu dplyr

df_dplyr_2 <- function(Users, Posts){
a1 <- Posts %>% select(OwnerUserId)  # wybieram z Posts OwnerUserId
a2 <- Users %>% select(Id, Location) # z Users wybieram Id oraz Location
a3 <- a1 %>% inner_join(a2, by = c("OwnerUserId"="Id"), keep = TRUE)  # wykonuję inner_join a1 i a2, łącząc OwnerUserId i Id
y <- a3 %>% mutate(Location = replace(Location, Location=='',NA))  # tam gdzie lokacja jest równa "" dajemy NA
a4 <- filter(y, !is.na(Location))  # usuwamy wiersze, gdzie w kolumnie Location jest NA
a5 <- group_by(a4,Location) %>%  # grupujemy po Location
      summarise(Count = n())  #  zliczając wszystkie miejsca wystąpienia danej lokacji
a6 <- arrange(a5,desc(Count))  # uporządkowujemy wiersze tak, by Count było malejące
a7 <- a6 %>% slice_head(n = 10)  # bierzemy 10 pierwszych wierszy
a7
}

all_equal(df_sql_2(Users, Posts), df_dplyr_2(Users, Posts)) # TRUE


# d) za pomocą data.table

df_table_2 <- function(Users, Posts){
Users_1 <- data.table(Users)  # będziemy pracować na data.table, więc zmieniamy nasze ramki danych
Posts_1 <- data.table(Posts)
a1 <- Users_1[, .(Id, Location)]  # wybieramy Id oraz Location
a2 <- Posts_1[, .(OwnerUserId)]  # wybieramy OwnerUserId
a3 <- a1[a2, on = .(Id = OwnerUserId), nomatch = NULL]  # zostanie nam Id i Location
y1 <- a3$Id  # będziemy dodawać tę kolumnę
a3[, `:=` (OwnerUserId=y1)]  # teraz mamy Id, Location oraz OwnerUserId
neworder <- c("OwnerUserId","Id","Location")  # zmienimy kolejność
a3 <- a3[ , ..neworder]  # zmieniamy kolejność kolumn 
# Mamy ramkę a3. Teraz przejdziemy do najbardziej zewnętrznej funkcji
a3 <- a3[with(a3, Location != "")]  # bierzemy te a3, gdzie Location != ""
a4 <- a3[, .(Count = .N), by =.(Location)]  # grupujemy po lokacji, zliczając ile razy wystąpiła dana lokalizacja
a5 <- a4[order(-Count)]  # kolejność wierszy, by Count było malejąco
a6 <- a5[1:10]  # biorę tylko 10 pierwszych wierszy
a6
}


all_equal(df_sql_2(Users,Posts), df_table_2(Users, Posts)) # TRUE



# Zadanie 3

# a) za pomocą sqldf

df_sql_3 <- function(Badges){
sqldf("SELECT Year, SUM(Number) AS TotalNumber
FROM (
    SELECT
        Name,
        COUNT(*) AS Number,
        STRFTIME('%Y', Badges.Date) AS Year
    FROM Badges
    WHERE Class = 1
    GROUP BY Name, Year
)
GROUP BY Year
ORDER BY TotalNumber")
}



# b) za pomocą funkcji bazowych

df_base_3 <- function(Badges){
rok <- strftime(Badges$Date, '%Y')  # zmieniamy zbyt dokładny dla nas punkt w czasie na po prostu rok i zapisujemy do zmiennej rok
x <- Badges[, c("Name", "Date", "Class")]  # wybieramy z ramki Badges kolumny Name, Date, Class
x[,"Date"] <- rok  # zmieniamy wartości całej kolumny na wartości z rok
x <- x[x$Class == 1,]  # bierzemy te wiersze, gdzie Class == 1
x <- x[,c(1,2)]  # wybieramy pierwszą i drugą kolumnę
y <- as.data.frame( table( x[, c("Name", "Date")] ),   # zliczamy wszystkie kombinacje wystąpienia kolumn Name i Date
                    stringsAsFactors = FALSE )
y <- y[y$Freq != 0,]  # usuwamy te wiersze, gdzie dane kombinacje nie wystąpiły - nie potrzebujemy ich
y[,c("Date", "Freq")] <- y[,c("Freq", "Date")]  # zmieniamy kolejność kolumn na Name, Freq, Date
colnames(y)[2] <- "Number"  # druga kolumna będzie nazywać się "Number"
colnames(y)[3] <- "Year"  # a trzecia "Year"
rownames(y) <- NULL  # ponownie chcemy, by w nowej ramce kolejne "nazwy" wierszy to 1,2,3,4,5,...
z <- aggregate(y["Number"], y["Year"], sum)  #grupujemy po Year, sumując wszystkie wystąpienia Number w konkretnym roku
colnames(z) <- c("Year","TotalNumber")  # zmieniamy nazwy kolumn, by było jak w zadaniu
z <- z[order(z$TotalNumber, decreasing = FALSE),]  # kolejne wiersze TotalNumber będą malejąco - zmieniamy kolejność wierszy
rownames(z) <- NULL  # ponownie kolejne wiersze będą w postaci 1,2,3,4,...,  a nie np. 345,143,1,4,656,...
z
}

dplyr::all_equal(df_sql_3(Badges), df_base_3(Badges)) # TRUE


# c) za pomocą pakietu dplyr


df_dplyr_3 <- function(Badges){
a1 <- select(Badges, Name, Date, Class)  # wybieram z Badges kolumny Name, Date oraz Class (Class tylko, by wybrać gdzie Class == 1)
a2 <- mutate(a1, Date = strftime(Date, "%Y"))  # zamieniam daty, by były w formacie "rok"
a3 <- rename(a2,  Year = Date)  # zmieniam nazwę kolumny na Year
a4 <- filter(a3, Class == 1)  # wybieram te wiersze, gdzie Class == 1
a5 <- select(a4, Name, Year)  # wybieram wszystko tylko nie Class - nie jest już potrzebne
a6 <- group_by(a5, Name, Year)  # grupujemy po imieniu i roku
a7 <- summarise(a6,
                Number = n())  # zliczamy ilość wystąpienia różnych kombinacji Name, Year, kolumnę nazwiemy Number
# Teraz ostatni krok, funkcja najbardziej zewnętrzna
b1 <- group_by(a7, Year)  # grupujemy po roku
b2 <- select(b1, Year, Number)  # wybieramy Year i Number
b3 <- summarise(b2,
                TotalNumber = sum(Number))  # sumuję wartości przy kombinacjach Year i Number - tutaj też mogłem zrobić group_by (argument .groups)
b3
}


all_equal(df_sql_3(Badges), df_dplyr_3(Badges)) # TRUE





# d) za pomocą data.table


df_table_3 <- function(Badges){
Badges_1 <- data.table(Badges)  # ponownie zmiana na data. table
a1 <- Badges_1[, .(Name, Date,Class)]  # wybieramy te 3 kolumny
y1 <- strftime(Badges$Date, '%Y') # zamiana konkretnej daty na rok i zapis do y1
a1[,`:=` (Year = y1)]  # wstawiamy nową kolumnę Year o wartościach z y1
a1 <- a1[with(a1, Class == 1)]  # wybieramy te kolumny, gdzie Class == 1
a2 <- a1[, .(Name, Year)]  # wybieramy Name i Year -- niepotrzbne nam Class (bo filtrowaliśmy już), a Year to już zmienione Date
a3 <- a2[, .(Number = .N), by = .(Name, Year)]  # zliczamy po numerze i po roku
# Teraz przejdziemy do najbardziej zewnętrznej funkcji
b1 <- a3[, .(Year, Number)]
b2 <- b1[, .(TotalNumber = sum(Number)), by =.(Year)]  # grupujemy po Year, wykonujemy sum na Number i nazywamy tę kolumnę TotalNumber
b3 <- b2[order(TotalNumber)]  # zmieniamy kolejność wierszy (ASC - ascending - rosnąco, a "-" oznacza malejąco)
b3
}



all_equal(df_sql_3(Badges), df_table_3(Badges)) # TRUE



# Zadanie 4

# a) za pomocą sqldf

df_sql_4 <- function(Posts){
  sqldf("SELECT
            Users.AccountId,
            Users.DisplayName,
            Users.Location,
            AVG(PostAuth.AnswersCount) as AverageAnswersCount
FROM
(
    SELECT
        AnsCount.AnswersCount,
        Posts.Id,
        Posts.OwnerUserId
    FROM (
            SELECT Posts.ParentId, COUNT(*) AS AnswersCount
            FROM Posts
            WHERE Posts.PostTypeId = 2
            GROUP BY Posts.ParentId
          ) AS AnsCount
    JOIN Posts ON Posts.Id = AnsCount.ParentId
) AS PostAuth
JOIN Users ON Users.AccountId=PostAuth.OwnerUserId
GROUP BY OwnerUserId
ORDER BY AverageAnswersCount DESC, AccountId ASC
LIMIT 10")
}




# b) za pomocą funkcji bazowych



df_base_4 <- function(Posts){
x <- as.data.frame( table( Posts[Posts$PostTypeId == 2,"ParentId" ] ),  # zliczamy wystąpienia różnych ParentId (biorąc tylko te, gdzie PostTypeId == 2)
                    stringsAsFactors = FALSE)
colnames(x) <- c("ParentId", "AnswersCount")  # zmieniam nazwy kolumn
rownames(x) <- NULL  # ponownie wiersze mają być postaci 1,2,3,4,...
x$ParentId <- as.integer(x$ParentId)  # zamieniamy wartości z ParentId na liczby całkowite
AnsCount <- x  # mamy już AnsCount
x <- merge(Posts, AnsCount,  # łączymy Posts i AnsCount, łącząc kolumny Id i ParentId. W połączonej kolumnie będą tylko te wartości, które występowały w Id i ParentId
           by.x ='Id', by.y = 'ParentId', all = FALSE) 
x <- x[, c("AnswersCount", "Id", "OwnerUserId")]  # zmieniamy kolejność kolumn
PostAuth <- x
# Mamy PostAuth - zaczynamy kolejny etap
abcd <- PostAuth[c("OwnerUserId", "AnswersCount")]
wea2 <- Users[c("AccountId", "DisplayName", "Location")]
a <- merge(wea2, abcd, by.x = "AccountId", by.y = "OwnerUserId")  # kolejna operacja join
inna <- aggregate(x = a["AnswersCount"],
               by = a[c("AccountId","DisplayName","Location")],  # wykonamy operację średniej na AnswersCount
               FUN = mean)
colnames(inna)[4] <- "AverageAnswersCount"  # zmieniamy nazwę kolumny
#Porównując wyniki tego fragmentu kodu w sql i otrzymanej ramki"inna" pojawiło się, że ramka z ma dokładnie 1 wiersz więcej
#być może coś się zduplikowało...
inna <- inna[!(duplicated(inna[,c("AccountId")])), c("AccountId","DisplayName","Location","AverageAnswersCount")]  # usuwamy wiersze, gdzie są duplikaty AccountId
# Teraz liczba wierszy się zgadza ;)
# Musimy posortować jednocześnie
inna <- inna[order(inna$AverageAnswersCount, inna$AccountId,decreasing = c("TRUE","FALSE")),]
rownames(inna) <- NULL
head(inna, 10)  # bierzemy 10 pierwszych wierszy
}


dplyr::all_equal(df_sql_4(Posts), df_base_4(Posts)) # TRUE



# c) za pomocą pakietu dplyr

df_dplyr_4 <- function(Posts){
a1 <- select(Posts, ParentId, PostTypeId)  # z ramki Posts wybieramy ParentId oraz PostTypeId
a2 <- filter(a1, PostTypeId == 2)  # bierzemy te wiersze, gdzie PostTypeId == 2
a3 <- group_by(a2,ParentId)  # grupujemy a2 po ParentId
AnsCount <- summarise(a3,  # zliczamy ilość wystąpienia różnych ParentId
                AnswersCount = n())
# Mamy AnsCount, rozpoczynamy kolejny krok
b1 <- select(AnsCount,AnswersCount, ParentId)
b2 <- select(Posts, Id, OwnerUserId)
b3 <- inner_join(b1,b2, by = c( "ParentId" = "Id"))
PostAuth <- rename(b3, Id = ParentId)  # zmieniamy nazwę kolumn ParentId na Id
# Mamy PostAuth, pora na ostatnie kroki
c1 <- select(Users,AccountId,DisplayName,Location)  # z ramki Users wybieramy 3 kolumny
c2 <- select(PostAuth, AnswersCount,OwnerUserId)  # a z PostAuth 2 kolumnt
c3 <- inner_join(c1,c2, by=c("AccountId" = "OwnerUserId"))
c4 <- group_by(c3,AccountId) # AccountId to teraz "to samo" co OwnerUserId po inner_join, więc wykonaliśmy poprawne grupowanie
c5 <- summarise(c4,
                DisplayName = first(DisplayName), # na tych DisplayName wykonujemy operacji specjalnej
                Location = first(Location),       # na Location też
                AverageAnswersCount = mean(AnswersCount)  # a tutaj liczymy średnią wystąpień AnswersCount w danym AccountId
)
c6 <- arrange(c5, desc(AverageAnswersCount), AccountId)  # szeregujemy wiersze - AverageAnswersCount malejąco, AccountId rosnąco
c7 <- c6 %>% slice_head(n = 10)  # wybieramy dokładnie 10 wierszy z naszej ramki
c7
}

all_equal(df_sql_4(Posts), df_dplyr_4(Posts)) # TRUE


# d) za pomocą data.table

df_table_4 <- function(Posts){
Users_1 <- data.table(Users)  # trzeba pamiętać przez cały czas, że pracujemy na data.table
Posts_1 <- data.table(Posts)  # i nie możemy np. łączyć zwykłej ramki i tej z data.table 
x <- Posts_1[, .(ParentId, PostTypeId)]  
a1 <- x[with(x, PostTypeId == 2)]  # bierzemyt te wiersze, gdzie PostTypeId == 2
a2 <- a1[, .(ParentId)]
AnsCount <- a2[, .(AnswersCount = .N), by = .(ParentId)]  # grupujemy po ParentId, licząc liczbę wystąpień takich samych (kolumnę nazwiemy AnswersCount)
# Mamy już AnsCount, przechodzimy do funkcji bardziej zewnętrznej
b1 <- AnsCount[, .(AnswersCount, ParentId)]
b2 <- Posts_1[, .(Id, OwnerUserId)]
PostAuth <- b1[b2, on = .(ParentId = Id), nomatch = NULL]  # dołączamy do b1 tabelkę b2
setnames(PostAuth, "ParentId", "Id")  # zmieniamy nazwy kolumn
# Mamy już PostAuth (TRUE), teraz zrobimy najbardziej zewnętrzną funkcję
c1 <- Users_1[, .(AccountId, DisplayName, Location)]
c2 <- PostAuth[, .(OwnerUserId, AnswersCount)]
y1 <- PostAuth[, .(AverageAnswersCount = mean(AnswersCount)), by = .(OwnerUserId)]  # będziemy liczyć średnią wystąpień AnswersCount, grupując po OwnerUserId
c3 <- c1[y1, on = .(AccountId = OwnerUserId), nomatch = NULL]  # robimy inner_join
c4 <- c3[order(-AverageAnswersCount,AccountId)]  # szeregujemy AverageAnswersCount malejąco, a AccountId rosnąco
# Teraz usuniemy zduplikowane wiersze oraz tam, gdzie jest NA
c5 <- c4[!duplicated(c4[,c("AccountId")])]  # podobny problem co w basie - usuwamy duplikat
inne <- na.omit(c5)  # oraz usuwamy te wiersze, gdzie nam się pojawiło NA
head(inne, 10)  # wybieramy dokładnie 10 pierwszych wierszy
}


all_equal(df_sql_4(Posts) , df_table_4(Posts)) # TRUE


# Zadanie 5

# a) za pomocą sqldf

df_sql_5 <- function(Posts, Votes){
  sqldf(
"SELECT Posts.Title, Posts.Id,
        STRFTIME('%Y-%m-%d', Posts.CreationDate) AS Date,
        VotesByAge.Votes
FROM Posts
JOIN (
          SELECT
              PostId,
              MAX(CASE WHEN VoteDate = 'new' THEN Total ELSE 0 END) NewVotes,
              MAX(CASE WHEN VoteDate = 'old' THEN Total ELSE 0 END) OldVotes,
              SUM(Total) AS Votes
          FROM (
              SELECT
                  PostId,
                  CASE STRFTIME('%Y', CreationDate)
                      WHEN '2021' THEN 'new'
                      WHEN '2020' THEN 'new'
                      ELSE 'old'
                      END VoteDate,
                  COUNT(*) AS Total
              FROM Votes
              WHERE VoteTypeId IN (1, 2, 5)
              GROUP BY PostId, VoteDate
          ) AS VotesDates
          GROUP BY VotesDates.PostId
          HAVING NewVotes > OldVotes
) AS VotesByAge ON Posts.Id = VotesByAge.PostId
WHERE Title NOT IN ('')
ORDER BY Votes DESC
LIMIT 10")
}



# b) Za pomocą funkcji bazowych

df_base_5 <- function(Posts, Votes){
VoteDate <- strftime(Votes$CreationDate, '%Y')  # zmieniamy konkretny czas na po prostu rok
VoteDate[VoteDate == "2020" | VoteDate == "2021"] <- "new"  # tam gdzie jest wartość "2020" lub "2021" zmieniamy na wartość "new"
VoteDate[VoteDate != "new"] <- "old"  # a w pozostałych na wartość "old"
x <- Votes[,c("PostId", "CreationDate", "VoteTypeId")]
x[c("CreationDate")] <- VoteDate  # zmieniamy kolumnę "dokładnej daty" na po prostu rok
colnames(x)[2] <- "VoteDate"  # zmieniamy nazwę drugiej kolumny na 2
x <- x[x$VoteTypeId == 1 | x$VoteTypeId == 2 | x$VoteTypeId == 5,]  # filtrujemy po takich VoteTypeId, które jest równe 1,2 lub 5
x <- x[,c("PostId","VoteDate")]
y <- as.data.frame( table( x[, c("PostId","VoteDate")]),  # zliczamy liczbę wystąpień różnych kombinacji
                    stringsAsFactors = FALSE)
y <- y[y$Freq > 0,]  # nie bierzemy pod uwagę tych wierszy, gdzie dana kombinacja PostId i VoteDate nie wystąpiła
colnames(y)[3] <- "Total"
# wykonujemy dodatkową operację order, by PostId było malejąco, bo przy funkcji table nie zostało to dobrze poszeregowane (group by)
y <- y[order(y$PostId, decreasing = FALSE),]
rownames(y) <- NULL
y$PostId <- as.integer(y$PostId)  # zmieniamy wartości z PostId, by były liczbami całkowitymi
VotesDates <-y
#MAM JUŻ VotesDates. PORA NA KOLEJNE PODZADANIE
x <- VotesDates[,c("PostId","VoteDate","VoteDate","Total")]  # z VoteDates wybieramy 4 kolumny - VoteDate bierzemy dwukrotnie
colnames(x)[2:3] <- c("NewVotes", "OldVotes")  # zmieniamy nazwy kolumn
x[x$NewVotes == "new", "NewVotes"] <- x$Total[x$NewVotes == "new"]  # tam gdzie "new", wartość z kolumny Total
x[x$NewVotes == "old", "NewVotes"] <- 0  #  reszta wartości to będzie 0
x[x$OldVotes == "old", "OldVotes"] <- x$Total[x$OldVotes == "old"]  # analogicznie
x[x$OldVotes == "new", "OldVotes"] <- 0
inna1 <- aggregate(x = x["NewVotes"],  # grupujemy po PostId, szukając maksimum NewVotes dla takich samych wartości występujących w PostId
                  by = x["PostId"],    # np. Id = "303" wystąpiło 3 razy, wtedy NewVotes było równe odpowiednio 3,14,2,9.
                  FUN = max)           # zatem w wynikowej tabeli przy wierszu, gdzie Id = "303", w kolumnie NewVotes będzie max(3,14,2,9) = 14 
inna2 <- aggregate(x = x["OldVotes"],  
                  by = x["PostId"],  # analogicznie, tylko dla OldVotes
                  FUN = max)
inna3 <- aggregate(x = x["Total"],  # szeregujemy Total po PostId, sumując wartości z Total dla konkretnych PostId
                  by = x["PostId"],
                  FUN = sum)
tabelka <- cbind(inna2["PostId"], inna1["NewVotes"], inna2["OldVotes"], inna3["Total"])  # łączymy te kolumny już zgrupowane i przetworzone
colnames(tabelka)[4] <- "Votes"  # zmieniamy nazwę czwartej kolumny na Votes
tabelka$NewVotes <- as.integer(tabelka$NewVotes)  # zamieniamy na integer wartości z NewVotes
tabelka$OldVotes <- as.integer(tabelka$OldVotes)  # tak samo OldVotes (ponieważ 105L > 24L, ale "105" < "25")
VotesByAge <- tabelka[tabelka$NewVotes > tabelka$OldVotes,]  # wybieramy te wiersze, w których wartość z kolumny NewVotes jest większa od wartości z kolumny OldVotes
rownames(VotesByAge) <- NULL  # wiersze będą się "nazywać" 1,2,3,4,5,...
# Mamy VotesByAge - pozostaje nam funkcja najbardziej zewnętrzna
a <- merge(Posts, VotesByAge, by.x = "Id", by.y = "PostId", all = FALSE)  # łączymy Posts i VotesByAge - inner_join
a <- a[c("Title", "Id", "CreationDate", "Votes")]
rok <- strftime(a$CreationDate, "%Y-%m-%d")  # zmieniamy dokładny czas na format "rok-miesiąc-dzień" i zapisujemy do zmiennej rok
a[,"CreationDate"] <- rok  # zamieniamy daty w ramce
colnames(a)[3] <- "Date"  # zmieniamy nazwę na Date
a <- a[a$Title != "",]  # wybieramy te Title, które nie są puste
a <- a[order(a$Votes, decreasing = TRUE),]  # szeregujemy, by Votes było malejąco
rownames(a) <- NULL
wyniczek <- head(a,10)  # bierzemy dokładnie 10 wierszy ramki danych a
wyniczek
}


all_equal(df_sql_5(Posts, Votes), df_base_5(Posts, Votes)) # TRUE


# c) za pomocą pakietu dplyr

df_dplyr_5 <- function(Posts, Votes){
a1 <- select(Votes, PostId, CreationDate, VoteTypeId)  # z ramki Votes wybieramy PostId, CreationDate, VoteTypeId
a2 <- mutate(a1, CreationDate = strftime(CreationDate, "%Y"))  #konwersja na postać "rok"
a3 <-  a2 %>% mutate(CreationDate = if_else(CreationDate == "2021" | CreationDate == "2020", "new", "old"))  # tam gdzie 2021 lub 2021 jest "new", reszta to "old"
a4 <- rename(a3, VoteDate = CreationDate)  #  zmieniamy nazwę CreationDate na VoteDate
a5 <- filter(a4, VoteTypeId == 1 | VoteTypeId == 2 | VoteTypeId == 5)
a6 <- select(a5, PostId, VoteDate) %>% group_by(PostId,VoteDate)  # bierzemy PostID i VoteDate, grupujemy po nich
VotesDates <- summarise(a6,  # zliczamy ilość wystąpień kombinacji PostId i VoteDate
                Total = n())
# Mamy VotesDates, przechodzimy do funkcji poziom wyżej
b1 <- select(VotesDates, PostId, VoteDate, Total)
y <- b1 %>% group_by(PostId)  # grupujemy po PostId
b2 <- y %>% mutate(OldVotes = VoteDate)  # będziemy mieć nową kolumnę o nazwie OldVotes
b3 <- select(b2, PostId, VoteDate, OldVotes, Total)  # bierzemy te kolumny
b4 <- rename(b3, NewVotes = VoteDate)  # i jedną nazwiemy NewVotes
b5 <- b4 %>% mutate(NewVotes = if_else(NewVotes == "new", Total, 0L)) %>% 
      mutate(OldVotes = if_else(OldVotes == "old", Total, 0L))  # tam gdzie OldVotes == "old" dajemy wartość z Total, w przeciwnym przypadku liczbę całkowitą 0
b6 <- summarise(b5,
                PostId = first(PostId),  # wykonujemt operację max na NewVotes, na OldVotes oraz sum na Total
                NewVotes = max(NewVotes),
                OldVotes = max(OldVotes),
                Votes = sum(Total))      # kolumnę Total nazwiemy teraz Votes
VotesByAge <- filter(b6, NewVotes > OldVotes)  # bierzemy te wiersze, gdzie wartości w kolumnie NewVotes są większe od wartości z kolumny OldVotes
# Mamy ramkę VotesByAge, pora na ostatnie kroki
c1 <- select(Posts, Title, Id, CreationDate)  # wybieramy Title, Id, CreationDate
c2 <- select(VotesByAge, Votes, PostId)  # a z VotesByAge Votes oraz PostId
c3 <- inner_join(c1,c2, by = c("Id" = "PostId"))  # robimy inner_join
c4 <- mutate(c3, CreationDate = strftime(CreationDate, "%Y-%m-%d"))  # konkwertujemy kolumnę z czasem na format "rok-miesiąc-dzień"
y <- rename(c4, Date = CreationDate)  # zmieniamy nazwę kolumny CreationDate na Date
c5 <- filter(y, Title != "")  # bierzemy te wiersze z y, gdzie Title != ""
c6 <- arrange(c5, desc(Votes))  # szeregujemy w c5 wiersze tak, by kolejne wartości z Votes były malejąco uporządkowane
c7 <- c6 %>% slice_head(n = 10)  # wybieramy dokładnie 10 pierwszych wierszy
c7
}
  

all_equal(df_sql_5(Posts,Votes), df_dplyr_5(Posts, Votes)) # TRUE



# d) za pomocą data.table

df_table_5 <- function(Posts, Votes){
Posts_1 <- data.table(Posts)  # będziemy tutaj potem pracować na Posts, ale jesteśmy w data.table
Votes_1 <- data.table(Votes)
a1 <- Votes_1[, .(PostId, CreationDate, VoteTypeId)]  # te kolumny wybieramy
rok <- strftime(Votes$CreationDate, "%Y")  # konwersja na rok
a1[, `:=` (VoteDate = rok)]  # dodajemy nową kolumnę VoteDate o wartościach z rok
a2 <- a1[, .(PostId, VoteDate, VoteTypeId)]
a2[, VoteDate := VoteDate][VoteDate == "2021"| VoteDate == "2020", VoteDate := "new"]  # nazwiemy VoteDate, tam gdzie 2021 lub 2020 jest "new"
a2[, VoteDate := VoteDate][VoteDate != "new", VoteDate := "old"]  # a w pozostałych przypadkach wartość kolumnie VoteDate zmienimy na "old"
a3 <- a2[with(a2, VoteTypeId == 1 | VoteTypeId == 2 | VoteTypeId == 5)]  # wybieramy z a2 takie wiersze, gdzie VoteTypeId == 1,2 lub 5
a4 <- a3[, .(PostId, VoteDate)]
a5 <- a4[, .(Total = .N), by = .(PostId, VoteDate)]  # zliczamy ilość wystąpień kombinacji PostId i VoteDate do kolumny Total
VotesDates <- a5[order(PostId, VoteDate)] 
# Wykonaliśmy dodatkową operację order, by dobrze pogrupowało
# Mamy VotesDates, przechodzimy dalej
b1 <- VotesDates
b1[, `:=` (NewVotes = VotesDates$VoteDate)]  # dodajemy kolumnę identyczną, co VoteDate
b1[, `:=` (OldVotes = VotesDates$VoteDate)]  # tu tak samo
b2 <- b1[, .(PostId, NewVotes, OldVotes, Total)]
b2[, NewVotes := NewVotes][NewVotes == "new", NewVotes:= Total]  # tam gdzie NewVotes == "new" damy wartość z kolumny Total
b2[, NewVotes := NewVotes][NewVotes == "old", NewVotes:= 0]      # a w pozostałych przypadkach jest 0
b2[, OldVotes := OldVotes][OldVotes == "old", OldVotes := Total]  # analogicznie jak powyżej
b2[, OldVotes := OldVotes][OldVotes == "new", OldVotes := 0]
b3 <- b2
b3 <- b3[, .(NewVotes = max(NewVotes),  # liczymy max po NewVotes, po OldVotes, sumę po Total grupując po PostId
            OldVotes = max(OldVotes),
            Votes = sum(Total)),
         by = .(PostId)]
# Zmienię wartości OldVotes oraz NewVotes na integer, ponieważ aktualnie
# są jako character. Oczywiście 245 > 98, ale "245" < "98", bo 2 < 9
b3$OldVotes <- as.integer(b3$OldVotes)
b3$NewVotes <- as.integer(b3$NewVotes)
b4 <- b3[with(b3, NewVotes > OldVotes)]  # filtrujemy po wierszach
b4$NewVotes <- as.character(b4$NewVotes)  # teraz zmieniamy na character - by na tym etapie się zgadzało w funckji all_equal
b4$OldVotes <- as.character(b4$OldVotes)
VotesByAge <- b4
#Mamy już VotesByAge, przechodzimy do funkcji najbardziej zewnętrznej
c1 <- Posts_1[, .(Title, Id, CreationDate)]
c2 <- VotesByAge[, .(Votes, PostId)]  
rok <- strftime(Posts_1$CreationDate, "%Y-%m-%d")  # konwersja na "rok-miesiąc-dzień"
c1[, `:=` (CreationDate = rok)]  # dodajemy kolumnę CreationDate o wartościach z rok
setnames(c1, "CreationDate", "Date")  #  zmieniamy nazwy kolumn na CreationDate oraz Date
c2 <- c1[c2, on = .(Id = PostId), nomatch = NULL]  # inner_join
# Zrobiliśmy operację join, teraz ostatnie kroki
c3 <- c2[with(c2, Title != "")]  # filtrowanie, gdzie Title != ""
c4 <- c3[order(-Votes)]  # szeregujemy wiersze tak, by Votes było malejąco
c5 <- c4[1:10]  # wybieramy dokładnie 10 pierwszych wartości z ramki c4
c5
}


all_equal(df_sql_5(Posts, Votes), df_table_5(Posts, Votes)) # TRUE

#------------------------------------------------------------------------

# WSZĘDZIE JEST TRUE. Wszystkie funkcje z danych 5 zadań dają ten sam wynik.
# Pomiar szybkości wszystkich funkcji sprawdzimy w pliku Rmd.




