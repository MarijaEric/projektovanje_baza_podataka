xidel b.xml --output-format=xml --xquery \
'for $r in //Racun
let $p := //Proizvod[@Naziv="Coca-Cola"]
where $r/StavkaRacuna/@SifraProizvoda = $p/@SifraProizvoda
and $r/@UkupniIznos > "200"
return $r'