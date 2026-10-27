# TD — Stockage de matrices en C

INSA Centre Val de Loire · 3e année STI · Programmation C · A. ADELL

**Groupe :** NGUYEN Xuan Duc, PHAM Nguyen Khanh Huy, HUYNH Gia Quy (responsable du groupe).

**Comptes GitHub :** NGUYEN Xuan Duc : [nguyenxuanduc-vn](https://github.com/nguyenxuanduc-vn) ; PHAM Nguyen Khanh Huy : [khanhuy06](https://github.com/khanhuy06) ; HUYNH Gia Quy : [quy0901147933](https://github.com/quy0901147933).`n`n**Dépôt :** https://github.com/quy0901147933/Programmation_C

## 1. Introduction

Ce projet réalise une bibliothèque de matrices d'entiers de dimensions variables. Elle permet l'allocation et la destruction des matrices, leur lecture et leur écriture dans un fichier texte, ainsi que leur addition et leur multiplication. Le programme `demo_matrices` utilise ces modules. Les contrôles ci-dessous ont été effectués sur une copie de travail sous Ubuntu 22.04, avec GCC et Valgrind ; ils mettent aussi en évidence une anomalie de multiplication, décrite plus bas.

## 2. Conception

### Modules et inclusions

```text
main.c ──────> matrice.h, matrice_alloc.h, matrice_io.h, matrice_calcul.h
matrice.c ───> matrice.h
matrice_alloc.c ──> matrice_alloc.h ──> matrice.h
matrice_io.c ─────> matrice_io.h ─────> matrice.h, stdio.h
             └────> matrice_alloc.h
matrice_calcul.c ─> matrice_calcul.h ─> matrice.h
                 └> matrice_alloc.h
```

La structure `Matrice` contient les dimensions et un tableau de pointeurs ; chaque pointeur désigne une ligne allouée séparément. `matrice.c` fournit les fonctions communes ; `matrice_alloc.c` gère la mémoire ; `matrice_io.c` traite les flux ; `matrice_calcul.c` réalise les opérations. Le Makefile compile séparément les modules avec `-std=c11 -Wall -Wextra -Wpedantic -g` et construit le programme ; `make test` construit et exécute les trois tests.

### Propriété de la mémoire

Les matrices sont initialisées à `MATRICE_VIDE`. Une fonction qui réussit transfère la propriété du résultat à l'appelant, qui doit appeler `mat_detruire`. En cas d'échec après une allocation partielle, le code libère les allocations effectuées et laisse le résultat vide. Les entrées ne sont ni libérées ni modifiées par les fonctions de calcul. Un résultat préexistant doit être détruit avant d'être réutilisé ; les paramètres de sortie du calcul doivent être distincts des entrées. `mat_detruire` remet la structure à l'état vide. Les fonctions de lecture et d'écriture ne ferment pas les flux : le code qui les ouvre les ferme.

## 3. Réalisation et questions

### Exercice 1 — Allocation et destruction

`mat_allouer` vérifie les dimensions, alloue le tableau de pointeurs puis les lignes avec `calloc`, et libère les allocations précédentes en cas d'échec. `mat_detruire` libère les lignes puis le tableau de pointeurs et réinitialise la structure.

**Q3.1** `mat_detruire` reçoit un pointeur afin de modifier la structure de l'appelant et la remettre à `MATRICE_VIDE`. Un passage par valeur ne modifierait qu'une copie : l'appelant conserverait des pointeurs devenus invalides.

**Q3.2** En cas de succès, une matrice de `n` lignes demande `n + 1` appels à `calloc` et `n + 1` appels à `free`. Si le k-ième appel à `calloc` échoue, il faut libérer les `k - 1` allocations qui ont réussi, y compris le tableau de pointeurs si celui-ci a été alloué.

**Q3.3** Le premier appel remet la structure à l'état vide ; le second ne libère donc rien. Avec `Matrice b = a`, seule la structure est copiée : les deux objets désignent les mêmes allocations. Détruire `a` puis `b` risque une double libération et un comportement indéfini. Il faut éviter cette copie propriétaire superficielle.

**Q3.4** L'initialisation avant la validation des dimensions garantit un résultat vide même si la fonction échoue immédiatement. La précondition reste que l'ancien contenu de `*res` ne possède pas de mémoire non libérée.

**Test fourni :** `test_ex1` affiche 16 / 16 vérifications réussies.

### Exercice 2 — Entrées-sorties

La lecture vérifie les dimensions et les coefficients avant de transmettre la matrice construite à l'appelant. L'écriture contrôle les opérations et force l'écriture du tampon avec `fflush`. L'affichage présente les dimensions et les coefficients.

**Q4.1** La matrice locale `tmp` permet de libérer un résultat incomplet si une lecture échoue. `*res` n'est rempli qu'après lecture complète ; l'appelant ne reçoit donc pas une matrice partiellement construite.

**Q4.2** Non : `fscanf` lit les mots séparés par des espaces ou des sauts de ligne, sans imposer une ligne physique par ligne de matrice. Cela accepte plusieurs mises en forme valides ; à l'écriture, un format canonique facilite l'échange et la vérification.

**Q4.3** Après lecture du nombre attendu de coefficients, on peut appeler de nouveau `mat_lire` sur le même flux pour lire les dimensions puis les coefficients de la matrice suivante, séparés par des espaces ou des sauts de ligne.

**Q4.4** `fflush` peut révéler une erreur lors de l'envoi des données tamponnées avant de renvoyer le succès. Il ne remplace pas le contrôle de `fclose`, car une erreur peut aussi apparaître lors de la fermeture.

**Test fourni :** `test_ex2` affiche 14 / 14 vérifications réussies.

### Exercice 3 — Calcul matriciel

L'addition vérifie les paramètres et les dimensions, calcule les coefficients dans un type plus large et vérifie leur intervalle. La multiplication accumule les produits dans `long long`, vérifie les dépassements et alloue une matrice résultat. **Limite constatée :** la condition de compatibilité de la multiplication compare actuellement le nombre de lignes de A au nombre de colonnes de B, au lieu de comparer les colonnes de A aux lignes de B. Les tests fournis passent, mais certains cas rectangulaires échouent ou produisent un accès mémoire invalide ; voir la démonstration.

**Q5.1** Non. `const Matrice *a` empêche de modifier les champs de la structure à travers `a`, mais ne rend pas constants les entiers désignés par `a->coef`. Pour interdire l'écriture des coefficients via une interface de lecture, il faut exposer un accès dont les valeurs pointées sont `const`, par exemple au moyen d'une interface adaptée ; ajouter `const` au seul pointeur de structure ne suffit pas.

**Q5.2** `res` est mis à l'état vide avant le calcul ; s'il désignait `a`, cette réinitialisation écraserait la structure d'entrée et perdrait son allocation. Le contrôle d'identité refuse donc cet alias ; les entrées restent disponibles et la propriété mémoire est préservée.

**Q5.3** Le calcul effectue `n × p × q` multiplications d'entiers, soit un milliard pour deux matrices de 1000 × 1000.

**Q5.4** Un dépassement d'un `int` signé est un comportement indéfini en C : le programme ne peut pas compter sur le résultat pour détecter l'erreur après coup. L'addition utilise ici un type plus large puis vérifie que le résultat appartient à l'intervalle de `int`.

**Test fourni :** `test_ex3` affiche 14 / 14 vérifications réussies. Ce bilan ne couvre pas les dimensions rectangulaires citées ci-dessus.

### Exercice 4 — Programme de démonstration

Le programme charge les deux matrices, les affiche, appelle l'opération demandée, enregistre le résultat puis passe par un point de nettoyage commun.

**Q6.1** La bibliothèque renvoie un code d'erreur plutôt que d'imposer son affichage. L'application peut choisir comment présenter l'erreur : dans le terminal, dans une interface graphique ou autrement.

**Q6.2** Pour un fichier en écriture, `fclose` peut signaler une erreur d'écriture retardée ; `sauvegarder` teste donc son retour. `charger`, fourni dans le sujet, ne teste pas le retour de fermeture d'un flux de lecture ; les erreurs de lecture sont traitées pendant `mat_lire`.

**Q6.3** Après un calcul réussi, les trois matrices A, B et R doivent être libérées même si l'enregistrement échoue. Le saut vers `nettoyage` appelle `mat_detruire` sur les trois structures.

## 4. Vérifications mémoire

Sous Ubuntu 22.04, `valgrind --leak-check=full` sur chacun des trois tests fournis indique `All heap blocks were freed` et `ERROR SUMMARY: 0 errors`. La même vérification sur une addition réussie et sur la lecture du fichier invalide indique aussi zéro erreur et aucune allocation restante.

Ces résultats ne couvrent pas tous les scénarios. Avec une multiplication incompatible `2 × 3` par `2 × 2`, le contrôle actuel accepte les dimensions ; Valgrind signale des lectures invalides dans `mat_multiplier`, suivies d'un arrêt par `SIGSEGV`. Ce cas ne doit pas être présenté comme une exécution propre.

## 5. Démonstration finale

Les commandes ci-dessous ont été exécutées sur la copie de vérification Linux. Les sorties affichées sont celles observées.

### Addition valide

```text
$ ./demo_matrices add donnees/A.txt donnees/B.txt R.txt
A (4 x 3) :
       25       48       84
       15       33       11
       45       88       10
        0       12       -5
B (4 x 3) :
        1        2        3
        4        5        6
        7        8        9
       10       11       12
R = A + B (4 x 3) :
       26       50       87
       19       38       17
       52       96       19
       10       23        7
Resultat enregistre dans "R.txt".
$ echo $?
0
```

### Multiplication valide refusée

```text
$ ./demo_matrices mul donnees/A.txt donnees/C.txt R.txt
A (4 x 3) :
       25       48       84
       15       33       11
       45       88       10
        0       12       -5
B (3 x 2) :
        1        0
        0        1
        2       -1
Erreur : calcul impossible : dimensions incompatibles (A : 4 x 3, B : 3 x 2)
$ echo $?
1
```

Ces dimensions sont pourtant compatibles : le résultat attendu a 4 lignes et 2 colonnes. L'ordre d'affichage entre les flux standard et erreur peut varier selon leur mise en tampon.

### Fichier mal formé

```text
$ ./demo_matrices add donnees/A.txt donnees/invalide.txt R.txt
Erreur : lecture de "donnees/invalide.txt" : fichier mal formé
$ echo $?
1
```

## 6. Bilan et difficultés

Le projet met en pratique la séparation entre interfaces et implémentations, l'allocation dynamique et la libération sur les chemins d'erreur, les flux et la gestion des erreurs. Les trois tests fournis réussissent sans erreur Valgrind, mais les tests supplémentaires montrent une anomalie importante dans la validation des dimensions de multiplication. Une différence a également été constatée dans l'ordre des inclusions de `matrice_io.h` par rapport au fichier d'origine : les en-têtes devront être strictement identiques pour respecter la consigne.

**Répartition déclarée par le groupe :** NGUYEN Xuan Duc : code des exercices 3 et 4 ; HUYNH Gia Quy : code de l'exercice 2, tests Valgrind et Makefile ; PHAM Nguyen Khanh Huy : code de l'exercice 1, rapport et remise.

## 7. Reproduction des vérifications

```sh
make
make test
valgrind --leak-check=full ./test_ex1
valgrind --leak-check=full ./test_ex2
valgrind --leak-check=full ./test_ex3
valgrind --leak-check=full ./demo_matrices add donnees/A.txt donnees/B.txt R.txt
valgrind --leak-check=full ./demo_matrices add donnees/A.txt donnees/invalide.txt R.txt
```

`make` construit le programme de démonstration ; `make test` construit et exécute les trois programmes de test. Les fichiers de sortie créés pendant les tests ne font pas partie du rendu.
