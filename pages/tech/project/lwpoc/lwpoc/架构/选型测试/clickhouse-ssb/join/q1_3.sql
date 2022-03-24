SELECT SUM(LO_EXTENDEDPRICE*LO_DISCOUNT) AS REVENUE
FROM ssb.lineorder , ssb.dates  
WHERE LO_ORDERDATE = D_DATEKEY
  AND D_WEEKNUMINYEAR = 6
  AND D_YEAR = 1994
  AND LO_DISCOUNT BETWEEN 5 AND 7
  AND LO_QUANTITY BETWEEN 26 AND 35;