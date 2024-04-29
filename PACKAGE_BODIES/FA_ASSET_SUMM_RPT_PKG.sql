--------------------------------------------------------
--  DDL for Package Body FA_ASSET_SUMM_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_ASSET_SUMM_RPT_PKG" AS
-- $Header: FASSUMRPTPB.pls 120.5.12010000.9 2009/08/24 13:58:37 klakshmi ship $
FUNCTION ASSIGNED_UNITS(p_asset_id_in IN NUMBER
                       ,p_ccid_in  IN NUMBER
                       ,p_transaction_units_in IN NUMBER  /* what does this parameter do? */
                       ,p_original_cost_in IN NUMBER
                       ,p_units_in  IN NUMBER)
RETURN NUMBER
IS
  ln_units  NUMBER;
  ln_amount NUMBER;
BEGIN

  SELECT NVL(SUM(fdh.units_assigned),0)
  INTO   ln_units
  FROM   fa_distribution_history fdh
  WHERE  fdh.asset_id            = p_asset_id_in
  AND    fdh.book_type_code      = P_BOOK_NAME
  AND    fdh.code_combination_id = p_ccid_in
  AND    fdh.transaction_header_id_in =
      (SELECT MAX(fdh1.transaction_header_id_in)
       FROM   fa_distribution_history fdh1
             ,fa_transaction_headers  fth1
       WHERE  fdh1.asset_id            = p_asset_id_in
       AND    fdh1.book_type_code      = P_BOOK_NAME   /* why P_BOOK_NAME it should be P_BOOK_TYPE_CODE, both are not synonymous */
       AND    fdh1.code_combination_id = p_ccid_in
       AND    fdh1.transaction_header_id_in = fth1.transaction_header_id
       AND    fth1.date_effective <= gd_per_close_date);

  SELECT (p_original_cost_in/p_units_in) * ln_units
  INTO   ln_amount
  FROM   DUAL;
  /* Dev comments:
     what happened to rounding of the amount!!
  */
  RETURN (ln_amount);
END ASSIGNED_UNITS;
--=====================================================================
--=====================================================================

FUNCTION CURRENT_AMOUNT(p_transaction_header_id IN NUMBER
                        ,p_asset_id_in IN NUMBER
                        ,p_category_id_in IN NUMBER
                        ,p_asset_type_in IN VARCHAR2
                        ,p_ccid_in  IN NUMBER
                        ,p_location_id_in IN NUMBER)
RETURN NUMBER
IS
  ln_amount       NUMBER;
BEGIN
  BEGIN
  fnd_file.put_line(fnd_file.log,'Begin Original Amount::');

    SELECT NVL(fdd.cost,0)
    INTO   ln_amount
    FROM   fa_deprn_detail         fdd
          ,fa_distribution_history fdh
          ,fa_asset_history        fah
          ,fa_transaction_headers  fth
    WHERE  fdd.period_counter = (
              SELECT MAX(fdd1.period_counter)
              FROM   fa_deprn_detail fdd1
              WHERE  fdd1.book_type_code  = P_BOOK_NAME
              AND    fdd1.distribution_id = fdd.distribution_id
              AND    fdd1.asset_id        = fdd.asset_id
              AND    fdd1.period_counter  < gn_lex_begin_period_counter)
    AND    fdd.book_type_code            = P_BOOK_NAME
    AND    fdh.asset_id                  = fth.asset_id
    AND    fdh.transaction_header_id_in  = p_transaction_header_id
    AND    fah.category_id               = p_category_id_in
    AND    fah.asset_type                = p_asset_type_in
    AND    fah.asset_id                  = p_asset_id_in
    AND    fdd.asset_id                  = p_asset_id_in
    AND    fdd.distribution_id           = fdh.distribution_id
    AND    fah.asset_type                IN ('CAPITALIZED','CIP')
    AND    fdh.location_id               = p_location_id_in
    AND  ((fdh.date_effective               >= fah.date_effective
          AND fdh.date_effective            < NVL(fah.date_ineffective, fdh.date_effective + 1)
          AND fdh.transaction_header_id_in  = fth.transaction_header_id)
         OR(fah.date_effective             > fdh.date_effective
             AND fah.transaction_header_id_in  = fth.transaction_header_id
         AND fth.transaction_type_code     = 'ADDITION'  /* CIP ADDITION is not considered?  */
         AND fah.date_effective < gd_per_open_date))
    AND    fdh.code_combination_id          = p_ccid_in
    AND    fdd.distribution_id           = (
              SELECT MAX(fdd1.distribution_id)
              FROM   fa_deprn_detail fdd1
                    ,fa_distribution_history fdh1
              WHERE  fdd1.book_type_code      = fdd.book_type_code
              AND    fdd1.asset_id            = fdd.asset_id
              AND    fdd1.distribution_id     = fdh1.distribution_id
              AND    fdh1.code_combination_id = fdh.code_combination_id
              AND    fdh1.location_id         = p_location_id_in
              AND    fdd1.period_counter      < gn_lex_begin_period_counter);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ln_amount := 0;
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'In CURRENT_AMOUNT');
	  --RAISE;
  END;
  RETURN ln_amount;
END CURRENT_AMOUNT;

--=====================================================================
--=====================================================================

FUNCTION ADDITIONS_AMOUNT(p_transaction_header_id IN NUMBER
                         ,p_asset_id_in IN NUMBER
                         ,p_category_id_in IN NUMBER
                         ,p_asset_type_in IN VARCHAR2
                         ,p_ccid_in IN NUMBER
                         ,p_location_id_in IN NUMBER
                         ,p_fah_trx_header_id IN NUMBER)
RETURN NUMBER
IS
  ln_amount       NUMBER;
BEGIN
  BEGIN
    SELECT NVL(SUM(NVL(DECODE(fadj.debit_credit_flag, 'CR', -1 * fadj.adjustment_amount
                                             , fadj.adjustment_amount), 0)),0) additions
    INTO   ln_amount
    FROM   fa_transaction_headers  fth
          ,fa_adjustments          fadj
          ,fa_asset_history        fah
		  ,fa_distribution_history fdh
    WHERE  fth.asset_id                = fah.asset_id
    AND    fth.asset_id                = fdh.asset_id
   	AND    fdh.distribution_id         = fadj.distribution_id
    AND    fdh.transaction_header_id_in  = p_transaction_header_id
    AND    fah.category_id             = p_category_id_in
    AND    fah.asset_type              = p_asset_type_in
    AND    fth.asset_id                = p_asset_id_in
    AND    fth.book_type_code          = P_BOOK_NAME
    AND    fadj.transaction_header_id  = fth.transaction_header_id
    AND    ((fth.transaction_type_code IN ('CIP ADDITION','CIP ADJUSTMENT')
             AND fah.asset_type       = 'CIP'
             AND fadj.adjustment_type = 'CIP COST')
           OR (fth.transaction_type_code = 'ADDITION' AND fah.asset_type       = 'CAPITALIZED'
		      AND fadj.adjustment_type = 'COST'))
    AND    fth.transaction_date_entered <= NVL(gd_period_close_date,fth.transaction_date_entered)
    AND    fadj.period_counter_adjusted BETWEEN gn_lex_begin_period_counter AND gn_lex_end_period_counter
    AND    ((fdh.date_effective           >= fah.date_effective
    AND    fdh.date_effective           < NVL(fah.date_ineffective, fdh.date_effective + 1))
	   OR    (fah.date_effective      > fdh.date_effective
              AND fth.transaction_type_code = 'ADDITION'))
	AND    fah.transaction_header_id_in = p_fah_trx_header_id
	AND    fdh.code_combination_id      = p_ccid_in
    AND    fdh.location_id               = p_location_id_in
	AND  (fah.asset_type <> 'CAPITALIZED' OR ((fah.asset_type='CAPITALIZED') AND (NOT EXISTS (-- Added these lines as part of the fix to the SR 7284007.992
    SELECT 'Y'
	FROM  fa_asset_history  fah1
	WHERE fah1.asset_type='CIP'
	and   fah1.transaction_header_id_out = fah.transaction_header_id_in
	and   fah1.asset_id = fah.asset_id
	))));
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ln_amount := 0;
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'In ADDITIONS_AMOUNT');
	  --raise; /* why is this missed out? */   /* This is missed out as the program completes in error when run with few Null parameters*/
  END;
  /*  IF ln_amount IS NULL THEN   is this condition needed  if we add nvls to the above SUM statement?
    ln_amount := 0;
  END IF;*/
  RETURN ln_amount;
END ADDITIONS_AMOUNT;

--=====================================================================
--=====================================================================

FUNCTION RETIREMENT_AMOUNT(p_transaction_header_id IN NUMBER
                          ,p_asset_id_in IN NUMBER
                          ,p_category_id_in IN NUMBER
                          ,p_asset_type_in IN VARCHAR2
                          ,p_ccid_in IN NUMBER
                          ,p_location_id_in IN NUMBER)
RETURN NUMBER
IS
  ln_amount       NUMBER := 0;
BEGIN
  BEGIN
    SELECT NVL(SUM(NVL(DECODE(fadj.debit_credit_flag, 'DR',(-1)*fadj.adjustment_amount,fadj.adjustment_amount), 0)),0) retirements
    INTO   ln_amount
    FROM   fa_books                fb
          ,fa_transaction_headers  fth
          ,fa_adjustments          fadj
          ,fa_asset_history        fah
          ,fa_distribution_history fdh
    WHERE  fth.asset_id                 = fah.asset_id
    AND    fth.asset_id                 = fdh.asset_id
    AND    fah.asset_type               = p_asset_type_in
    AND    fdh.distribution_id          = fadj.distribution_id
    AND    fah.category_id              = p_category_id_in
    AND    fdh.transaction_header_id_in  = p_transaction_header_id
    AND    fth.book_type_code           = P_BOOK_NAME
    AND    fb.asset_id                  = p_asset_id_in
    AND    fdh.code_combination_id      = p_ccid_in
    AND    fadj.transaction_header_id   = fth.transaction_header_id
    AND    fth.transaction_type_code    IN ('FULL RETIREMENT', 'PARTIAL RETIREMENT', 'REINSTATEMENT')
    AND    fadj.adjustment_type         IN ('COST', 'CIP COST')
    AND    fadj.source_type_code        IN ('RETIREMENT', 'CIP RETIREMENT')
    AND    fadj.period_counter_adjusted BETWEEN gn_lex_begin_period_counter AND gn_lex_end_period_counter
    AND    fth.transaction_date_entered <= NVL(gd_period_close_date,fth.transaction_date_entered)
    AND    fth.transaction_header_id    >= fah.transaction_header_id_in
    AND    fth.transaction_header_id    < NVL(fah.transaction_header_id_out, fth.transaction_header_id + 1)
    AND    fb.transaction_header_id_in  = fth.transaction_header_id
    AND    fb.book_type_code            = P_BOOK_NAME
    AND    fdh.location_id               = p_location_id_in;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ln_amount := 0;
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'In RETIREMENT_AMOUNT');
  END;
 /* IF ln_amount IS NULL THEN   is this condition needed  if we add nvls to the above SUM statement?
    ln_amount := 0;
  END IF; */
  RETURN ln_amount;
END RETIREMENT_AMOUNT;

--=====================================================================
--=====================================================================

FUNCTION CHANGES_OF_ACCOUNTS(p_transaction_header_id IN NUMBER
                            ,p_asset_id_in IN NUMBER
                            ,p_category_id_in IN NUMBER
                            ,p_asset_type_in IN VARCHAR2
                            ,p_ccid_in IN NUMBER
                            ,p_location_id_in IN NUMBER
							,p_fah_trx_header_id IN NUMBER)
RETURN NUMBER
IS
  ln_amount       NUMBER := 0;
BEGIN
  BEGIN
    SELECT NVL(SUM(x.all_transferred),0)
    INTO   ln_amount
    FROM   (
        SELECT NVL(DECODE(fadj.debit_credit_flag, 'CR', -1 * fadj.adjustment_amount, fadj.adjustment_amount),0) all_transferred
        FROM   fa_transaction_headers  fth
              ,fa_adjustments          fadj
              ,fa_asset_history        fah1
              ,fa_distribution_history fdh
        WHERE EXISTS (
             SELECT 1
              FROM   fa_deprn_detail fdd
              WHERE  fdd.asset_id          = fth.asset_id
              AND    fdd.book_type_code    = P_BOOK_NAME
              AND    fdd.deprn_source_code = 'D'
                    )
        AND (fah1.asset_type = p_asset_type_in
            OR (fah1.asset_type = 'CIP'
              AND EXISTS (
                  SELECT period_counter_capitalized
                   FROM   fa_books fb2
                   WHERE  fb2.asset_id                   = fah1.asset_id
                   AND    fb2.book_type_code             = P_BOOK_NAME
                   AND    fb2.period_counter_capitalized < gn_lex_begin_period_counter
                       )))
        AND   fadj.period_counter_adjusted BETWEEN gn_lex_begin_period_counter AND gn_lex_end_period_counter
        AND   fadj.source_type_code        = 'TRANSFER'
        AND   fadj.adjustment_type         IN ('COST', 'CIP COST')
        AND   fth.transaction_type_code    <> 'TRANSFER IN'
        AND   fth.asset_id                 = fah1.asset_id
        AND   fth.asset_id                 = fdh.asset_id
        AND   fdh.distribution_id          = fadj.distribution_id
        AND    fdh.transaction_header_id_in  = p_transaction_header_id
        AND   fth.asset_id                 = p_asset_id_in
        AND   fah1.category_id             = p_category_id_in
        AND   fth.book_type_code           = P_BOOK_NAME
        AND   fadj.transaction_header_id   = fth.transaction_header_id
        AND   fth.transaction_date_entered <= gd_period_close_date
        AND   fadj.asset_id                = fah1.asset_id
        AND   fadj.book_type_code          = P_BOOK_NAME
        AND   fdh.code_combination_id      = p_ccid_in
        AND   fdh.location_id              = p_location_id_in
        AND   fth.transaction_header_id    >= fah1.transaction_header_id_in
        AND   fth.transaction_header_id    < NVL(fah1.transaction_header_id_out, fth.transaction_header_id + 1)
      UNION ALL  -- Added this query as part of the fix to the SR 7284007.992
        SELECT NVL(SUM(NVL(DECODE(fadj.debit_credit_flag, 'CR', -1 * fadj.adjustment_amount
                                             , fadj.adjustment_amount),0)),0) all_transferred
    FROM   fa_transaction_headers  fth
          ,fa_adjustments          fadj
          ,fa_asset_history        fah
          ,fa_distribution_history fdh
    WHERE  fth.asset_id                = fah.asset_id
    AND    fth.asset_id                = fdh.asset_id
    AND    fdh.distribution_id         = fadj.distribution_id
    AND    fdh.transaction_header_id_in  = p_transaction_header_id
    AND    fah.category_id             = p_category_id_in
    AND    fah.asset_type              = p_asset_type_in
    AND    fth.asset_id                = p_asset_id_in
    AND    fth.book_type_code          = P_BOOK_NAME
    AND    fadj.transaction_header_id  = fth.transaction_header_id
    AND    fth.transaction_type_code = 'ADDITION'
	AND    fah.asset_type       = 'CAPITALIZED'
    AND    fadj.adjustment_type = 'COST'
    AND    fth.transaction_date_entered <= NVL(gd_period_close_date,fth.transaction_date_entered)
    AND    fadj.period_counter_adjusted BETWEEN gn_lex_begin_period_counter AND gn_lex_end_period_counter
    AND    ((fdh.date_effective           >= fah.date_effective
    AND    fdh.date_effective           < NVL(fah.date_ineffective, fdh.date_effective + 1))
           OR    (fah.date_effective      > fdh.date_effective
              AND fth.transaction_type_code = 'ADDITION'))
              AND    fah.transaction_header_id_in = p_fah_trx_header_id
              AND    fdh.code_combination_id      = p_ccid_in
              AND    fdh.location_id              = p_location_id_in
         AND  ((fah.asset_type='CAPITALIZED') AND (EXISTS (-- Added these lines as part of the fix to the SR 7284007.992
             SELECT 'Y'
             FROM  fa_asset_history  fah1
             WHERE fah1.asset_type='CIP'
             and   fah1.transaction_header_id_out = fah.transaction_header_id_in
             and   fah1.asset_id = fah.asset_id
             )))
      UNION ALL
	  SELECT (-1)*(NVL(SUM(NVL(DECODE(fadj.debit_credit_flag, 'CR', -1 * fadj.adjustment_amount  -- Added this query as part of the fix to the SR 7284007.992
                                             , fadj.adjustment_amount), 0)),0)) all_transferred
    FROM   fa_transaction_headers  fth
          ,fa_adjustments          fadj
          ,fa_asset_history        fah
		  ,fa_distribution_history fdh
    WHERE  fth.asset_id                = fah.asset_id
    AND    fth.asset_id                = fdh.asset_id
   	AND    fdh.distribution_id         = fadj.distribution_id
    AND    fdh.transaction_header_id_in  = p_transaction_header_id
    AND    fah.category_id             = p_category_id_in
    AND    fah.asset_type              = p_asset_type_in
    AND    fth.asset_id                = p_asset_id_in
    AND    fth.book_type_code          = P_BOOK_NAME
    AND    fadj.transaction_header_id  = fth.transaction_header_id
    AND    fth.transaction_type_code IN ('CIP ADDITION','CIP ADJUSTMENT')
    AND    fah.asset_type       = 'CIP'
    AND    fadj.adjustment_type = 'CIP COST'
    AND    fth.transaction_date_entered <= NVL(gd_period_close_date,fth.transaction_date_entered)
    AND    fdh.date_effective           >= fah.date_effective
    AND    fdh.date_effective           < NVL(fah.date_ineffective, fdh.date_effective + 1)
	AND    fah.transaction_header_id_in = p_fah_trx_header_id
	AND    fdh.code_combination_id      = p_ccid_in
    AND    fdh.location_id               = p_location_id_in
	AND   (EXISTS (
    SELECT 'Y'
	FROM  fa_asset_history  fah1
          ,fa_transaction_headers  fth1
	WHERE fah1.asset_type='CAPITALIZED'
	AND   fah1.transaction_header_id_in = fah.transaction_header_id_out
	AND   fah1.asset_id = fah.asset_id
	AND   fth1.transaction_header_id = fah1.transaction_header_id_in
	AND   fth1.transaction_type_code = 'ADDITION'
	AND   fth1.transaction_date_entered BETWEEN gd_period_open_date AND gd_period_close_date
	))
	UNION ALL
        SELECT NVL(DECODE(fadj.debit_credit_flag, 'CR', -1 * fadj.adjustment_amount, fadj.adjustment_amount),0) all_transferred
        FROM   fa_transaction_headers    fth
              ,fa_adjustments          fadj
              ,fa_asset_history        fah1
              ,fa_asset_history        fah2
              ,fa_distribution_history fdh
        WHERE EXISTS (
           SELECT 1
            FROM   fa_deprn_detail fdd
            WHERE  fdd.asset_id          = fth.asset_id
            AND    fdd.book_type_code    = P_BOOK_NAME
            AND    fdd.deprn_source_code = 'D'
                    )
        AND (fah1.asset_type   = p_asset_type_in
           OR (fah1.asset_type = 'CIP'
             AND EXISTS (
                SELECT fb2.period_counter_capitalized
                 FROM   fa_books fb2
                 WHERE  fb2.asset_id                   = fah1.asset_id
                 AND    fb2.book_type_code             = P_BOOK_NAME
                 AND    fb2.period_counter_capitalized < gn_lex_begin_period_counter
                      )
              )
           )
       AND   fadj.source_type_code        =  'RECLASS'
       AND   fadj.adjustment_type         IN ('COST', 'CIP COST')
       AND   fth.transaction_type_code    <> 'TRANSFER IN'
       AND   fth.asset_id                 =  fah1.asset_id
       AND   fth.asset_id                 =  fdh.asset_id
       AND   fdh.distribution_id          =  fadj.distribution_id
       AND   fdh.transaction_header_id_in  = p_transaction_header_id
       AND   fdh.location_id               = p_location_id_in
       AND   fth.book_type_code           =  P_BOOK_NAME
       AND   fah2.category_id             =  p_category_id_in
       AND   fth.asset_id                 =  p_asset_id_in
       AND   fdh.code_combination_id      = p_ccid_in
       AND   fadj.transaction_header_id   =  fth.transaction_header_id
       AND   fth.transaction_date_entered <= gd_period_close_date
       AND   fadj.period_counter_adjusted BETWEEN gn_lex_begin_period_counter AND gn_lex_end_period_counter
       AND   fadj.asset_id                =  fah1.asset_id
       AND   fadj.book_type_code          =  P_BOOK_NAME
       AND   fah1.asset_id                =  fah2.asset_id
       AND   fth.transaction_header_id    >= fah1.transaction_header_id_in
       AND   fth.transaction_header_id    <  NVL(fah1.transaction_header_id_out, fth.transaction_header_id + 1)
       AND   fdh.date_effective           >= fah2.date_effective
       AND   fdh.date_effective           <  NVL(fah2.date_ineffective, fdh.date_effective + 1)
    ) X;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ln_amount := 0;
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'In CHANGES_OF_ACCOUNTS');
     -- RAISE;
  END;
  RETURN ln_amount;
END CHANGES_OF_ACCOUNTS;

--=====================================================================
--=====================================================================

FUNCTION ADJUSTMENT_AMOUNT(p_transaction_header_id IN NUMBER
                          ,p_asset_id_in IN NUMBER
                          ,p_category_id_in IN NUMBER
                          ,p_asset_type_in IN VARCHAR2
                          ,p_location_id_in IN NUMBER
                          ,p_ccid_in     IN NUMBER)
RETURN NUMBER
IS
  ln_amount NUMBER;
BEGIN
  BEGIN
    SELECT NVL(SUM(DECODE(fadj.debit_credit_flag, 'CR', -1 * fadj.adjustment_amount, fadj.adjustment_amount)),0)
    INTO   ln_amount
    FROM   fa_transaction_headers  fth
          ,fa_adjustments          fadj
          ,fa_asset_history        fah
          ,fa_distribution_history fdh
    WHERE  fth.asset_id                 = fah.asset_id
    AND    fth.asset_id                 = fdh.asset_id
    AND    fdh.distribution_id          = fadj.distribution_id
    AND    fdh.transaction_header_id_in  = p_transaction_header_id
    AND    fah.category_id              = p_category_id_in
    AND    fdh.location_id               = p_location_id_in
    AND    fah.asset_type               = p_asset_type_in
    AND    fth.book_type_code           = P_BOOK_NAME
    AND    fdh.code_combination_id      = p_ccid_in
    AND    fth.asset_id                 = p_asset_id_in
    AND    fadj.transaction_header_id   = fth.transaction_header_id
    AND    fadj.period_counter_adjusted BETWEEN gn_lex_begin_period_counter AND gn_lex_end_period_counter
    AND    fth.transaction_type_code  IN ('ADJUSTMENT')  /* CIP ADJUSTMENT excluded ? */
    AND    fadj.adjustment_type    IN ('COST')
    AND    fth.transaction_date_entered <= gd_period_close_date
    AND    fth.transaction_header_id    >= fah.transaction_header_id_in
    AND    fth.transaction_header_id    < NVL(fah.transaction_header_id_out, fth.transaction_header_id + 1);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ln_amount := 0;
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'In ADJUSTMENT_AMOUNT');
	  -- RAISE;
  END;
 /* IF ln_amount IS NULL THEN
    ln_amount := 0;
  END IF; */
  RETURN ln_amount ;
END ADJUSTMENT_AMOUNT;

--=====================================================================
--=====================================================================
/* what is this appreciation amount? */
FUNCTION APPRECIATION_AMOUNT(p_transaction_header_id IN NUMBER
                          ,p_asset_id_in IN NUMBER
                          ,p_category_id_in IN NUMBER
                          ,p_asset_type_in IN VARCHAR2
                          ,p_location_id_in IN NUMBER
                          ,p_ccid_in     IN NUMBER)
RETURN NUMBER
IS
  ln_amount NUMBER;
BEGIN
  BEGIN
    SELECT NVL(SUM(DECODE(fadj.debit_credit_flag, 'CR', -1 * fadj.adjustment_amount, fadj.adjustment_amount)),0)
    INTO   ln_amount
    FROM   fa_books                fb
          ,fa_transaction_headers  fth
          ,fa_adjustments          fadj
          ,fa_asset_history        fah
          ,fa_distribution_history fdh
    WHERE  fth.asset_id                 = fah.asset_id
    AND    fth.asset_id                 = fdh.asset_id
    AND    fdh.distribution_id          = fadj.distribution_id
    AND    fdh.transaction_header_id_in  = p_transaction_header_id
    AND    fah.category_id              = p_category_id_in
    AND    fdh.location_id               = p_location_id_in
    AND    fah.asset_type               = p_asset_type_in
    AND    fth.book_type_code           = P_BOOK_NAME
    AND    fdh.code_combination_id      = p_ccid_in
    AND    fth.asset_id                 = p_asset_id_in
    AND    fadj.transaction_header_id   = fth.transaction_header_id
    AND    fadj.period_counter_adjusted BETWEEN gn_lex_begin_period_counter AND gn_lex_end_period_counter
    AND    fth.transaction_type_code    IN ('ADJUSTMENT','CIP ADJUSTMENT')
    AND    fadj.adjustment_type    = 'EXPENSE'
    AND    fth.transaction_subtype = 'APPREC'
    AND    fth.transaction_date_entered <= gd_period_close_date
    AND    fth.transaction_header_id    >= fah.transaction_header_id_in
    AND    fth.transaction_header_id    < NVL(fah.transaction_header_id_out, fth.transaction_header_id + 1)
    AND    fb.transaction_header_id_in  = fth.transaction_header_id
    AND    fb.book_type_code            = P_BOOK_NAME;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ln_amount := 0;
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'In ADJUSTMENT_AMOUNT');
	  -- RAISE;
  END;
/* IF ln_amount IS NULL THEN
    ln_amount := 0;
  END IF; */
  RETURN ln_amount ;
END APPRECIATION_AMOUNT;

--=====================================================================
--=====================================================================
-- Bit unclear of this requirement for this routine
FUNCTION ACCM_DEPRN_AMT(p_transaction_header_id IN NUMBER
                       ,p_asset_id_in IN NUMBER
                       ,p_ccid_in IN NUMBER
                       ,p_location_id_in IN NUMBER)
RETURN NUMBER
IS
  ln_amount NUMBER;
BEGIN
  BEGIN
    SELECT NVL(fdd.deprn_reserve,0)
    INTO   ln_amount
    FROM   fa_deprn_summary fds
          ,fa_deprn_detail  fdd
          ,fa_distribution_history fdh
    WHERE  fds.book_type_code      = fdd.book_type_code
    AND    fds.asset_id            = fdd.asset_id
    AND    fds.period_counter      = fdd.period_counter
    AND    fdd.distribution_id     = fdh.distribution_id
    AND    fdh.transaction_header_id_in  = p_transaction_header_id
    AND    fdd.book_type_code      = fdh.book_type_code
    AND    fdd.asset_id            = fdh.asset_id
    AND    fds.book_type_code      = P_BOOK_NAME
    AND    fds.asset_id            = p_asset_id_in
    AND    fdh.code_combination_id = p_ccid_in
    AND    fdh.location_id         = p_location_id_in
    AND    fds.period_counter      = (
               SELECT MAX(fds1.period_counter)
               FROM   fa_deprn_summary fds1
                     ,fa_deprn_detail  fdd1
                     ,fa_distribution_history fdh1
               WHERE  fds1.book_type_code      = fdd1.book_type_code
               AND    fds1.asset_id            = fdd1.asset_id
               AND    fds1.period_counter      = fdd1.period_counter
               AND    fdd1.distribution_id     = fdh1.distribution_id
               AND    fdd1.book_type_code      = fdh1.book_type_code
               AND    fdd1.asset_id            = fdh1.asset_id
               AND    fds1.book_type_code      = fds.book_type_code
               AND    fds1.asset_id            = fds.asset_id
               AND    fdh1.code_combination_id = fdh.code_combination_id
               AND    fdh1.location_id         = p_location_id_in
               AND    fds1.period_counter      BETWEEN gn_lex_begin_period_counter AND gn_lex_end_period_counter
                               );
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
BEGIN
    SELECT fdd.deprn_reserve
    INTO   ln_amount
    FROM   fa_deprn_summary fds
          ,fa_deprn_detail  fdd
          ,fa_distribution_history fdh
          ,fa_books  fb
    WHERE  fds.book_type_code      = fdd.book_type_code
    AND    fds.asset_id            = fdd.asset_id
    AND    fds.period_counter      = fdd.period_counter
    AND    fdd.distribution_id     = fdh.distribution_id
    AND    fdd.book_type_code      = fdh.book_type_code
    AND    fdd.asset_id            = fdh.asset_id
    AND    fds.book_type_code      = P_BOOK_NAME
    AND    fds.asset_id            = p_asset_id_in
    AND    fdh.code_combination_id = p_ccid_in
    AND    fdh.location_id         = p_location_id_in
    AND    fb.asset_id             = fdd.asset_id
    AND    fb.book_type_code       = fdd.book_type_code
    AND    fb.date_ineffective IS NULL
    AND    fb.period_counter_life_complete IS NOT NULL
    AND    fds.period_counter      = (
               SELECT MAX(fds1.period_counter)
               FROM   fa_deprn_summary fds1
                     ,fa_deprn_detail  fdd1
                     ,fa_distribution_history fdh1
               WHERE  fds1.book_type_code      = fdd1.book_type_code
               AND    fds1.asset_id            = fdd1.asset_id
               AND    fds1.period_counter      = fdd1.period_counter
               AND    fdd1.distribution_id     = fdh1.distribution_id
               AND    fdd1.book_type_code      = fdh1.book_type_code
               AND    fdd1.asset_id            = fdh1.asset_id
               AND    fds1.book_type_code      = fds.book_type_code
               AND    fds1.asset_id            = fds.asset_id
               AND    fdh1.code_combination_id = fdh.code_combination_id
               AND    fdh1.location_id         = p_location_id_in
               AND    fds1.period_counter      < = gn_lex_begin_period_counter);
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
      ln_amount := 0;
      WHEN OTHERS THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'In ACCM_DEPRN_AMT (Inner)');
     END;
      WHEN TOO_MANY_ROWS THEN
        SELECT NVL(MAX(fdd.deprn_reserve),0)
        INTO   ln_amount
        FROM   fa_deprn_summary fds
              ,fa_deprn_detail  fdd
              ,fa_distribution_history fdh
        WHERE  fds.book_type_code      = fdd.book_type_code
        AND    fds.asset_id            = fdd.asset_id
        AND    fds.period_counter      = fdd.period_counter
        AND    fdd.distribution_id     = fdh.distribution_id
        AND    fdh.transaction_header_id_in  = p_transaction_header_id
        AND    fdd.book_type_code      = fdh.book_type_code
        AND    fdd.asset_id            = fdh.asset_id
        AND    fds.book_type_code      = P_BOOK_NAME
        AND    fds.asset_id            = p_asset_id_in
        AND    fdh.code_combination_id = p_ccid_in
        AND    fdh.location_id               = p_location_id_in
        AND    fds.period_counter = (
                  SELECT MAX(fds1.period_counter)
                   FROM   fa_deprn_summary fds1
                         ,fa_deprn_detail  fdd1
                         ,fa_distribution_history fdh1
                   WHERE fds1.book_type_code      = fdd1.book_type_code
                   AND   fds1.asset_id            = fdd1.asset_id
                   AND   fds1.period_counter      = fdd1.period_counter
                   AND   fdd1.distribution_id     = fdh1.distribution_id
                       AND    fdh.transaction_header_id_in  = p_transaction_header_id
                   AND   fdd1.book_type_code      = fdh1.book_type_code
                   AND   fdd1.asset_id            = fdh1.asset_id
                   AND   fds1.book_type_code      = fds.book_type_code
                   AND   fds1.asset_id            = fds.asset_id
                   AND   fdh1.code_combination_id = fdh.code_combination_id
                   AND   fdh1.location_id               = p_location_id_in
                   AND   fds1.period_counter      BETWEEN gn_lex_begin_period_counter AND gn_lex_end_period_counter
                                   );
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'In ACCM_DEPRN_AMT');
	  --RAISE;
  END;
/*  IF ln_amount IS NULL THEN
    ln_amount := 0;
  END IF;*/
  RETURN ln_amount;
END ACCM_DEPRN_AMT;

--=====================================================================
--=====================================================================

FUNCTION CATEGORY_ACCM_DEPRN_AMT(p_transaction_header_id IN NUMBER
                                ,p_asset_id_in IN NUMBER
                                ,p_ccid_in IN NUMBER
                                ,p_location_id_in IN NUMBER)
RETURN NUMBER
IS
  ln_amount        NUMBER;
BEGIN
  BEGIN
    SELECT NVL(SUM(DECODE(fdd.deprn_source_code,'B',fdd.deprn_reserve,fdd.deprn_amount)),0)
    INTO   ln_amount
    FROM   fa_deprn_summary fds
          ,fa_deprn_detail  fdd
          ,fa_distribution_history fdh
    WHERE  fds.book_type_code      = fdd.book_type_code
    AND    fds.asset_id            = fdd.asset_id
    AND    fds.period_counter      = fdd.period_counter
    AND    fdd.distribution_id     = fdh.distribution_id
    AND    fdh.transaction_header_id_in  = p_transaction_header_id
    AND    fdd.book_type_code      = fdh.book_type_code
    AND    fdd.asset_id            = fdh.asset_id
    AND    fds.book_type_code      = P_BOOK_NAME
    AND    fds.asset_id            = p_asset_id_in
    AND    fdh.code_combination_id = p_ccid_in
    AND    fdh.location_id         = p_location_id_in
    AND    fds.period_counter      <= gn_lex_end_period_counter;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
       ln_amount := 0;
      WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'In ACCM_DEPRN_AMT');
		--RAISE;
    END;
/*  IF ln_amount IS NULL THEN
    ln_amount := 0;
  END IF;*/
  RETURN ln_amount;
END CATEGORY_ACCM_DEPRN_AMT;

--=====================================================================
--=====================================================================

FUNCTION ACCM_DEPRN_AMT_PR_YEAR(p_transaction_header_id IN NUMBER
                         ,p_asset_id_in IN NUMBER
                  ,p_ccid_in IN NUMBER
                  ,p_location_id_in IN NUMBER)
RETURN NUMBER
IS
  ln_amount NUMBER;
BEGIN
  BEGIN
    SELECT NVL(fdd.deprn_reserve,0)
    INTO   ln_amount
    FROM   fa_books fb
          ,fa_deprn_summary fds
          ,fa_deprn_detail  fdd
          ,fa_distribution_history fdh
    WHERE  fb.book_type_code    = P_BOOK_NAME
    AND fb.date_ineffective     IS NULL
    AND fb.book_type_code       = fds.book_type_code
    AND fb.asset_id             = fds.asset_id
    AND fds.period_counter      = gn_lex_begin_period_counter - 1
    AND fdh.transaction_header_id_in  = p_transaction_header_id
    AND fb.asset_id             = p_asset_id_in
    AND fds.book_type_code      = fdd.book_type_code
    AND fds.asset_id            = fdd.asset_id
    AND fds.period_counter      = fdd.period_counter
    AND fdd.distribution_id     = fdh.distribution_id
    AND fdd.book_type_code      = fdh.book_type_code
    AND fdd.asset_id            = fdh.asset_id
    AND fdh.code_combination_id = p_ccid_in
    AND fdh.location_id         = p_location_id_in;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ln_amount := 0;
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'In NBV_VALUE');
	  --RAISE;
  END;
  RETURN ln_amount;
END ACCM_DEPRN_AMT_PR_YEAR;

--=====================================================================
--=====================================================================

FUNCTION DEPRN_EXPENSE(p_transaction_header_id IN NUMBER
                         ,p_asset_id_in IN NUMBER
                      ,p_ccid_in IN NUMBER
                      ,p_location_id_in IN NUMBER)
RETURN NUMBER
IS
  ln_amount        NUMBER;
BEGIN
  BEGIN
    SELECT NVL(SUM(fdd.deprn_amount - fdd.deprn_adjustment_amount + NVL(fx.adjustment_amount,0)),0)
        INTO   ln_amount
        FROM   fa_deprn_detail          fdd
              ,fa_distribution_history  fdh
                    ,(SELECT fadj.distribution_id
                           ,fadj.period_counter_created
                                 ,SUM(DECODE(fth.transaction_subtype,'APPREC',0,
                                DECODE(fadj.debit_credit_flag,'CR',-1*fadj.adjustment_amount
                                                  ,fadj.adjustment_amount))) adjustment_amount
               FROM fa_adjustments           fadj
                   ,fa_transaction_headers   fth
              WHERE fadj.transaction_header_id = fth.transaction_header_id(+)
              and fth.transaction_type_code IN ('ADJUSTMENT','ADDITION')
              and fadj.adjustment_type(+) = 'EXPENSE'
                    and fadj.book_type_code  = P_BOOK_NAME
              AND fadj.asset_id        = p_asset_id_in
                    and fadj.asset_id = fth.asset_id
                    and fadj.book_type_code = fth.book_type_code
                    group by  fadj.distribution_id
                           ,fadj.period_counter_created) fx
        WHERE fdd.distribution_id = fx.distribution_id(+)
          and fdd.period_counter = fx.period_counter_created(+)
          and fdd.distribution_id = fdh.distribution_id
          and fdd.period_counter BETWEEN gn_lex_begin_period_counter AND gn_lex_end_period_counter
          AND    fdd.book_type_code           = P_BOOK_NAME
          AND    fdd.asset_id                 = p_asset_id_in
          AND    fdh.code_combination_id      = p_ccid_in
          AND    fdh.transaction_header_id_in = p_transaction_header_id
      AND    fdh.location_id                = p_location_id_in;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ln_amount := 0;
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'In DEPRN_EXPENSE');
	  --RAISE;
  END;
 /* IF ln_amount IS NULL THEN
    ln_amount := 0;
  END IF;*/
  RETURN ln_amount;
END DEPRN_EXPENSE;

--=====================================================================
--=====================================================================

FUNCTION GAIN_LOSS_AMOUNT(p_transaction_header_id IN NUMBER
                          ,p_asset_id_in IN NUMBER
                          ,p_category_id_in IN NUMBER
                          ,p_asset_type_in IN VARCHAR2
                          ,p_ccid_in IN NUMBER
                          ,p_location_id_in IN NUMBER)
RETURN NUMBER
IS
  ln_amount       NUMBER := 0;
BEGIN
  BEGIN
    SELECT NVL(SUM(NVL(DECODE(fadj.debit_credit_flag, 'DR',(-1)*fadj.adjustment_amount,fadj.adjustment_amount), 0)),0) retirements
    INTO   ln_amount
    FROM   fa_books                fb
          ,fa_transaction_headers  fth
          ,fa_adjustments          fadj
          ,fa_asset_history        fah
          ,fa_distribution_history fdh
    WHERE  fth.asset_id                 = fah.asset_id
    AND    fth.asset_id                 = fdh.asset_id
    AND    fah.asset_type               = p_asset_type_in
    AND    fdh.distribution_id          = fadj.distribution_id
    AND    fah.category_id              = p_category_id_in
    AND    fdh.transaction_header_id_in  = p_transaction_header_id
    AND    fth.book_type_code           = P_BOOK_NAME
    AND    fb.asset_id                  = p_asset_id_in
    AND    fdh.code_combination_id      = p_ccid_in
    AND    fadj.transaction_header_id   = fth.transaction_header_id
    AND    fth.transaction_type_code    IN ('FULL RETIREMENT', 'PARTIAL RETIREMENT', 'REINSTATEMENT')
    AND    fadj.adjustment_type         IN ('RESERVE')
    AND    fadj.source_type_code        IN ('RETIREMENT', 'CIP RETIREMENT')
    AND    fadj.period_counter_adjusted <= gn_lex_end_period_counter
    AND    fth.transaction_date_entered <= NVL(gd_period_close_date,fth.transaction_date_entered)
    AND    fth.transaction_header_id    >= fah.transaction_header_id_in
    AND    fth.transaction_header_id    < NVL(fah.transaction_header_id_out, fth.transaction_header_id + 1)
    AND    fb.transaction_header_id_in  = fth.transaction_header_id
    AND    fb.book_type_code            = P_BOOK_NAME
    AND    fdh.location_id               = p_location_id_in;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ln_amount := 0;
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'In RETIREMENT_AMOUNT');
	  --RAISE;
  END;
 /* IF ln_amount IS NULL THEN
    ln_amount := 0;
  END IF;*/
  RETURN ln_amount;
END GAIN_LOSS_AMOUNT;

--=====================================================================
--=====================================================================

FUNCTION beforeReport
RETURN BOOLEAN
IS
  lc_ledger_id NUMBER;
  lc_maj_seg   VARCHAR2(30);
  lc_min_seg   VARCHAR2(30);
  lc_separator VARCHAR2(10);
BEGIN

--*************************************************
--Used to obtain the Book Controls data
--*************************************************
  SELECT FSC.category_flex_structure
  INTO   gc_cat_flex_struc
  FROM   fa_system_controls FSC;
fnd_file.put_line(fnd_file.log,'gc_cat_flex_struc::'||gc_cat_flex_struc);

--*************************************************
--Used to obtain the Category Flexfield Columns
--dynamically
--*************************************************
SELECT fsav.application_column_name
INTO   lc_maj_seg
FROM   fnd_segment_attribute_values fsav
WHERE  fsav.id_flex_code           = 'CAT#'
AND    fsav.id_flex_num            = gc_cat_flex_struc
AND    fsav.attribute_value        = 'Y'
AND    fsav.segment_attribute_type = 'BASED_CATEGORY';

SELECT fsav.application_column_name
INTO   lc_min_seg
FROM   fnd_segment_attribute_values fsav
WHERE  fsav.id_flex_code           = 'CAT#'
AND    fsav.id_flex_num            = gc_cat_flex_struc
AND    fsav.attribute_value        = 'Y'
AND    fsav.segment_attribute_type = 'MINOR_CATEGORY';

SELECT fifs.concatenated_segment_delimiter
INTO   lc_separator
FROM   fnd_id_flex_structures fifs
WHERE  fifs.id_flex_num  = gc_cat_flex_struc
AND    fifs.id_flex_code = 'CAT#';
--*************************************************
--Based on P_FROM_CATEGORY and P_TO_CATEGORY the
-- dynamic filter is created
--*************************************************
IF P_FROM_CATEGORY IS NOT NULL AND TRIM(P_FROM_CATEGORY) <> lc_separator THEN
  gc_from_maj_seg := RTRIM(SUBSTR(P_FROM_CATEGORY,1,INSTR(P_FROM_CATEGORY,lc_separator)),lc_separator);
  gc_from_min_seg := LTRIM(SUBSTR(P_FROM_CATEGORY,INSTR(P_FROM_CATEGORY,lc_separator)),lc_separator);
ELSE
  gc_from_maj_seg := 'A';
  gc_from_min_seg := 'A';
END IF;
  fnd_file.put_line(fnd_file.log, 'gc_from_maj_seg::'||gc_from_maj_seg);
  fnd_file.put_line(fnd_file.log, 'gc_from_min_seg::'||gc_from_min_seg);

IF P_TO_CATEGORY IS NOT NULL AND TRIM(P_TO_CATEGORY) <> lc_separator THEN
  gc_to_maj_seg := RTRIM(SUBSTR(P_TO_CATEGORY,1,INSTR(P_TO_CATEGORY,lc_separator)),lc_separator);
  gc_to_min_seg := LTRIM(SUBSTR(P_TO_CATEGORY,INSTR(P_TO_CATEGORY,lc_separator)),lc_separator);
ELSE
  gc_to_maj_seg := 'Z';
  gc_to_min_seg := 'Z';
END IF;
  fnd_file.put_line(fnd_file.log, 'gc_to_maj_seg::'||gc_to_maj_seg);
  fnd_file.put_line(fnd_file.log, 'gc_to_min_seg::'||gc_to_min_seg);

IF P_ASSET_DETAILS IS NULL THEN
  gc_asset_details := 'N';
ELSE
  gc_asset_details := P_ASSET_DETAILS;
END IF;

IF P_FROM_CATEGORY IS NOT NULL AND P_TO_CATEGORY IS NOT NULL THEN
IF gc_from_maj_seg <> gc_to_maj_seg THEN
gc_category_where := '((fc.'||lc_maj_seg||' = '''||gc_from_maj_seg||''' AND  fc.'||lc_min_seg||' >= '''||gc_from_min_seg||''')
                   OR (fc.'||lc_maj_seg||' = '''||gc_to_maj_seg||''' AND  fc.'||lc_min_seg||' <= '''||gc_to_min_seg||''')
                   OR (fc.'||lc_maj_seg||' > '''||gc_from_maj_seg||''' AND fc.'||lc_maj_seg||' < '''||gc_to_maj_seg||'''))';
ELSE
gc_category_where := ' ((fc.'||lc_maj_seg||' = '''||gc_from_maj_seg||''' AND  fc.'||lc_min_seg||' BETWEEN '''||gc_from_min_seg||''' AND '''||gc_to_min_seg||'''))';
END IF;
END IF;

IF P_FROM_CATEGORY IS NULL AND P_TO_CATEGORY IS NULL THEN
  gc_category_where := ' 1=1';
END IF;

IF P_FROM_CATEGORY IS NULL AND P_TO_CATEGORY IS NOT NULL THEN
IF gc_from_maj_seg <> gc_to_maj_seg THEN
gc_category_where := '((fc.'||lc_maj_seg||' = '''||gc_from_maj_seg||''' AND  fc.'||lc_min_seg||' >= '''||gc_from_min_seg||''')
                   OR (fc.'||lc_maj_seg||' = '''||gc_to_maj_seg||''' AND  fc.'||lc_min_seg||' <= '''||gc_to_min_seg||''')
                   OR (fc.'||lc_maj_seg||' > '''||gc_from_maj_seg||''' AND fc.'||lc_maj_seg||' < '''||gc_to_maj_seg||'''))';
ELSE
gc_category_where := ' ((fc.'||lc_maj_seg||' = '''||gc_from_maj_seg||''' AND  fc.'||lc_min_seg||' BETWEEN '''||gc_from_min_seg||''' AND '''||gc_to_min_seg||'''))';
END IF;
END IF;

IF P_FROM_CATEGORY IS NOT NULL AND P_TO_CATEGORY IS NULL THEN
IF gc_from_maj_seg <> gc_to_maj_seg THEN
gc_category_where := '((fc.'||lc_maj_seg||' = '''||gc_from_maj_seg||''' AND  fc.'||lc_min_seg||' >= '''||gc_from_min_seg||''')
                   OR (fc.'||lc_maj_seg||' = '''||gc_to_maj_seg||''' AND  fc.'||lc_min_seg||' <= '''||gc_to_min_seg||''')
                   OR (fc.'||lc_maj_seg||' > '''||gc_from_maj_seg||''' AND fc.'||lc_maj_seg||' < '''||gc_to_maj_seg||'''))';
ELSE
gc_category_where := ' ((fc.'||lc_maj_seg||' = '''||gc_from_maj_seg||''' AND  fc.'||lc_min_seg||' BETWEEN '''||gc_from_min_seg||''' AND '''||gc_to_min_seg||'''))';
END IF;
END IF;

fnd_file.put_line(fnd_file.log,'gc_asset_details::'||gc_asset_details);
fnd_file.put_line(fnd_file.log,'gc_category_where::'||gc_category_where);

--*************************************************
--Used to obtain the Begin period data
--*************************************************
  SELECT FDP.period_counter
        ,FDP.calendar_period_open_date
        ,fdp.period_open_date
  INTO   gn_lex_begin_period_counter
        ,gd_period_open_date
        ,gd_per_open_date
  FROM   fa_deprn_periods  FDP
  WHERE  FDP.book_type_code = P_BOOK_NAME
  AND    FDP.period_name    = P_BEGIN_PERIOD;

fnd_file.put_line(fnd_file.log,'gn_lex_begin_period_counter::'||gn_lex_begin_period_counter);
fnd_file.put_line(fnd_file.log,'gd_period_open_date::'||gd_period_open_date);
fnd_file.put_line(fnd_file.log,'P_BEGIN_PERIOD::'||P_BEGIN_PERIOD);

--*************************************************
--Used to obtain the End period data
--*************************************************
  SELECT FDP.period_counter
        ,NVL(FDP.calendar_period_close_date,SYSDATE)
        ,NVL(fdp.period_close_date,SYSDATE)
  INTO   gn_lex_end_period_counter
        ,gd_period_close_date
        ,gd_per_close_date
  FROM   fa_deprn_periods FDP
  WHERE  FDP.book_type_code = P_BOOK_NAME
  AND    FDP.period_name    = P_END_PERIOD;

fnd_file.put_line(fnd_file.log,'gn_lex_end_period_counter::'||gn_lex_end_period_counter);
fnd_file.put_line(fnd_file.log,'gd_period_close_date::'||gd_period_close_date);
fnd_file.put_line(fnd_file.log,'gd_per_close_date::'||to_char(gd_per_close_date,'dd/mm/yyyy hh24:mi:ss'));
fnd_file.put_line(fnd_file.log,'P_END_PERIOD::'||P_END_PERIOD);

--*************************************************
--Used to obtain the Book Controls data
--*************************************************
  SELECT FBC.book_class
        ,FBC.accounting_flex_structure
        ,FBC.set_of_books_id
  INTO   gc_book_class
        ,gc_acct_flex_struc
        ,lc_ledger_id
  FROM   fa_book_controls FBC
  WHERE  FBC.book_type_code = P_BOOK_NAME;
fnd_file.put_line(fnd_file.log,'gc_book_class::'||gc_book_class);

--*************************************************
--Used to obtain the Ledger Name AND Currency
--*************************************************
  SELECT GLED.name
        ,GLED.currency_code
  INTO   gc_ledger_name
        ,gc_currency_code
  FROM   gl_ledgers GLED
  WHERE  GLED.ledger_id = lc_ledger_id;
fnd_file.put_line(fnd_file.log,'gc_ledger_name::'||gc_ledger_name);

  RETURN (TRUE);
END beforeReport;

END FA_ASSET_SUMM_RPT_PKG;

/
