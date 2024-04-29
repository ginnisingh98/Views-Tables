--------------------------------------------------------
--  DDL for Package Body JAI_AP_TOLERANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AP_TOLERANCE_PKG" AS
/* $Header: jai_ap_tolerance.plb 120.1.12010000.3 2008/09/23 17:13:16 lgopalsa ship $ */


PROCEDURE inv_holds_check
       (
         p_invoice_id            IN NUMBER,
         p_org_id                IN NUMBER,
	 p_set_of_books_id       IN NUMBER,
         p_invoice_amount        IN NUMBER,
         p_invoice_currency_code IN VARCHAR2,
         p_return_code           OUT NOCOPY VARCHAR2,
         p_return_message        OUT NOCOPY VARCHAR2
)  IS

   CURSOR set_up_values IS
   SELECT *
   FROM   JAI_AP_TOL_SETUPS_ALL
   where  org_id = p_org_id;

   CURSOR check_entry(inv_id NUMBER, cp_vat_code ap_invoice_distributions_all.vat_code%type) IS
   SELECT 1
   FROM   ap_invoice_distributions_all
   WHERE  invoice_id = inv_id
   AND    vat_code = cp_vat_code
   AND    rownum = 1;

   CURSOR line_amounts(inv_id NUMBER) IS
   SELECT SUM(ail.amount) line_amount
   FROM   ap_invoice_lines_all ail
   WHERE  ail.invoice_id = inv_id
   AND    EXISTS (SELECT 1
                     FROM   ap_invoice_distributions_all apid
                     WHERE  apid.invoice_line_number = ail.line_number
                     AND    apid.invoice_id = inv_id
                     );

   CURSOR least_values(h_amt NUMBER) IS
   SELECT least(h_amt*NVL(tolerance_pos_percent,0)/100, NVL(tolerance_pos_amt,0)) max_val,
          least(h_amt*NVL(tolerance_neg_percent,0)/100, NVL(tolerance_neg_amt,0)) min_val
   FROM   JAI_AP_TOL_SETUPS_ALL;

 CURSOR from_inv_dist(inv_id NUMBER,
                        cp_description  ap_invoice_distributions_all.description%type,
                        cp_invoice_line_number ap_invoice_lines_all.line_number%TYPE,
                        cp_line_type   ap_invoice_lines_all.line_type_lookup_code%TYPE
                        )
   IS
   SELECT distribution_line_number, set_of_books_id
   FROM   ap_invoice_distributions_all
   WHERE  invoice_id = inv_id
   AND    invoice_line_number = cp_invoice_line_number
   AND    line_type_lookup_code = cp_line_type
   AND    description   = cp_description
   AND    rownum = 1;

   -- bug 7114863. Added by Lakshmi Gopalsami

    CURSOR from_inv_line(inv_id NUMBER,
                        cp_description ap_invoice_lines_all.description%TYPE,
                        cp_line_type   ap_invoice_lines_all.line_type_lookup_code%TYPE
                        )
   IS
   SELECT line_number, set_of_books_id
   FROM   ap_invoice_lines_all
   WHERE  invoice_id = inv_id
   AND    line_type_lookup_code =cp_line_type
   AND    description   = cp_description
   AND    rownum = 1;

   -- End for bug 7114863


   CURSOR for_functional_currency(sob_id NUMBER) IS
   SELECT currency_code
   FROM   gl_sets_of_books
   WHERE  set_of_books_id = sob_id;


  upper_value                       NUMBER := 0;
  lower_value                       NUMBER := 0;
  diff_amount                       NUMBER := 0;
  insertion_amount                  NUMBER := 0;
  SOB_ID                            NUMBER;
  v_check_entry                     NUMBER;
  least_values_rec                  least_values%ROWTYPE;
  from_inv_dist_rec                 from_inv_dist%ROWTYPE;
  set_up_values_rec                 set_up_values%ROWTYPE;
  line_amounts_rec               line_amounts%ROWTYPE;
  -- for_dist_insertion_rec            for_dist_insertion%ROWTYPE; For Bug# 4445989
  for_functional_currency_rec       for_functional_currency%ROWTYPE;

  lv_misc            ap_invoice_distributions_all.line_type_lookup_code%type;
  lv_vat_code        ap_invoice_distributions_all.vat_code%type;
  lv_description     ap_invoice_distributions_all.description%type;
  lv_not_required       AP_INVOICE_LINES_ALL.WFAPPROVAL_STATUS%TYPE;
  lv_not_matched        AP_INVOICE_LINES_ALL.MATCH_TYPE%TYPE;
  ln_max_lnno           NUMBER;
  lv_cash_posted_flag   AP_INVOICE_DISTRIBUTIONS_ALL.CASH_POSTED_FLAG%TYPE;
  ln_distribution_line_num AP_INVOICE_DISTRIBUTIONS_ALL.DISTRIBUTION_LINE_NUMBER%TYPE;
  ln_user_id            AP_INVOICE_LINES_ALL.CREATED_BY%TYPE;
  ln_login_id           AP_INVOICE_LINES_ALL.LAST_UPDATE_LOGIN%TYPE;
  ln_invc_line_num      AP_INVOICE_LINES_ALL.LINE_NUMBER%TYPE;

  --> Cursor to fetch the maximum line_number for current invoice
  CURSOR cur_get_max_line_number
  IS
  SELECT max (line_number)
  FROM   ap_invoice_lines_all
  WHERE  invoice_id = p_invoice_id;

  -- Cursor to fetch the details of
  -- maximum line from ap_invoice_lines_all for current invoice
  CURSOR cur_get_max_ap_inv_line (cpn_max_line_num AP_INVOICE_LINES_ALL.LINE_NUMBER%TYPE)
  IS
  SELECT   accounting_date
          ,period_name
          ,deferred_acctg_flag
          ,def_acctg_start_date
          ,def_acctg_end_date
          ,def_acctg_number_of_periods
          ,def_acctg_period_type
          ,set_of_books_id
  FROM    ap_invoice_lines_all
  WHERE   invoice_id = p_invoice_id
  AND     line_number = cpn_max_line_num;

  rec_max_ap_lines_all    CUR_GET_MAX_AP_INV_LINE%ROWTYPE;


  -- Bug#7114863. Added by Lakshmi Gopalsami
	CURSOR c_invoice_distribution(cp_invoice_id NUMBER)
	IS
	SELECT	a.accrual_posted_flag,
			a.assets_addition_flag,
			a.assets_tracking_flag
	FROM 	ap_invoice_distributions_all a,
			ap_invoice_lines_all b
	WHERE 	a.invoice_id = b.invoice_id
	and 	a.invoice_line_number = b.line_number
	and 	a.invoice_id = cp_invoice_id
	AND 	b.line_type_lookup_code = 'ITEM';

	r_invoice_distribution c_invoice_distribution%ROWTYPE;

	from_inv_line_rec                 from_inv_line%ROWTYPE;

  BEGIN

    /* India Localization funtionality is not required */
    if  jai_cmn_utils_pkg.check_jai_exists
          (p_calling_object   => 'apaprvlb.pls',
	   p_org_id           =>  p_org_id,
	   p_set_of_books_id  =>  p_set_of_books_id)     =    FALSE
     then
       P_return_code     :=  jai_constants.successful;
       P_return_message  := 'No need to create adjustment line as IL functionality is used';
       return;
     end if;

    --p_return_code := jai_constants.successful ;

    lv_vat_code := 'ROUNDING';
    lv_description := 'Commercial Rounding Off Distribution';
    ln_user_id := fnd_global.user_id;
    ln_login_id := fnd_global.login_id;
    lv_misc := 'MISCELLANEOUS'; -- Bug 7114863. Added by Laskhmi Gopalsami

    OPEN  set_up_values;
      FETCH set_up_values INTO set_up_values_rec;

      IF set_up_values%NOTFOUND THEN
         CLOSE set_up_values;
         RETURN;
      END IF;
    CLOSE set_up_values;

    OPEN  line_amounts(p_invoice_id);
      FETCH line_amounts INTO line_amounts_rec;
    CLOSE line_amounts;

    OPEN  cur_get_max_line_number;
      FETCH cur_get_max_line_number INTO ln_max_lnno;
    CLOSE cur_get_max_line_number;

    OPEN  cur_get_max_ap_inv_line (cpn_max_line_num => ln_max_lnno );
      FETCH cur_get_max_ap_inv_line INTO rec_max_ap_lines_all;
    CLOSE cur_get_max_ap_inv_line;

    OPEN  for_functional_currency(rec_max_ap_lines_all.set_of_books_id);
      FETCH for_functional_currency INTO for_functional_currency_rec;
    CLOSE for_functional_currency;

    v_check_entry := 0 ;

    OPEN  check_entry(p_invoice_id, lv_vat_code);
      FETCH check_entry INTO v_check_entry;
    CLOSE check_entry;


   --Check the header amount and the line total
   -- 1
   IF ((  (p_invoice_amount = line_amounts_rec.line_amount) AND
       (v_check_entry = 0)
     )
       OR
     (for_functional_currency_rec.currency_code <> p_invoice_currency_code) OR
     (NVL(set_up_values_rec.tolerance_flag,'X') = 'X')
    ) THEN  --0
    -- there is no diff in header and distribution amount / currency is not INR / tolerance not setup
     P_return_code     :=  jai_constants.successful;
     P_return_message  := ' No difference found and so no adjustment line created';
    RETURN;
   END IF; --1

   --2
   IF ((p_invoice_amount = line_amounts_rec.line_amount)
        AND v_check_entry <> 0) THEN

      -- rounding entry has gone but the vat code not updated.
      ln_invc_line_num := null;

     UPDATE ap_invoice_distributions_all
        SET amount = 0
      WHERE invoice_id = p_invoice_id
        AND vat_code = lv_vat_code
  RETURNING invoice_line_number INTO ln_invc_line_num;

     UPDATE  ap_invoice_lines_all
        SET  amount = 0
      WHERE  invoice_id = p_invoice_id
        AND  line_number = ln_invc_line_num;

     P_return_code     :=  jai_constants.successful;
     P_return_message  := ' Updated existing rounding line';

     RETURN;

   END IF;
   --2


   diff_amount := line_amounts_rec.line_amount - p_invoice_amount ;

   --IF IT DOES NOT MATCH THEN CHECK THE TOLERANCE LEVEL
   -- 3

   IF (NVL(set_up_values_rec.tolerance_flag,'Z') = 'P') THEN
   --CONSIDER ONLY THE PERCENTAGE TOLERANCE

    upper_value := NVL(set_up_values_rec.tolerance_pos_percent,0) * p_invoice_amount/100;
    lower_value := NVL(set_up_values_rec.tolerance_neg_percent,0) * p_invoice_amount/100;


  ELSIF (NVL(set_up_values_rec.tolerance_flag,'Z') = 'A') THEN

  --CONSIDER ONLY THE AMOUNT TOLERANCE

    upper_value := NVL(set_up_values_rec.tolerance_pos_amt,0);
    lower_value := NVL(set_up_values_rec.tolerance_neg_amt,0);


  ELSE                     --1
   --CONSIDER LEAST OF PERCENTAGE AND AMOUNT TOLERANCES

    OPEN  least_values(p_invoice_amount);
       FETCH least_values INTO least_values_rec;
    CLOSE least_values;

    upper_value := least_values_rec.max_val;
    lower_value := least_values_rec.min_val;

  END IF;
  -- 3

  -- 4
  IF (  (diff_amount > 0 AND diff_amount <= upper_value)
         OR
      (diff_amount < 0 AND ABS(diff_amount) <= lower_value)
     ) THEN

	  --INSERT POSITIVE OR NEGATIVE DISTRIBUTION EQUAL TO DIFF_AMOUNT
	  insertion_amount := (-1)*diff_amount;
  END IF;
  -- 4

  --5
  IF insertion_amount <> 0 THEN

    lv_not_required := 'NOT REQUIRED';
    lv_not_matched  := 'NOT_MATCHED';
    lv_cash_posted_flag := 'N';

   -- Check whether the rounding line already exists in table

    OPEN  from_inv_line(p_invoice_id, lv_description,lv_misc);
    FETCH from_inv_line INTO from_inv_line_rec;
    -- 5(a)
    IF from_inv_line%FOUND THEN
     ln_invc_line_num := from_inv_line_rec.line_number;

     UPDATE ap_invoice_lines_all
        SET amount = insertion_amount,
	    last_update_date = sysdate,
	    last_updated_by  = ln_user_id,
	    last_update_login = ln_login_id
      WHERE  invoice_id  =p_invoice_id
        AND    line_number = ln_invc_line_num  ;

    ELSE
      ln_invc_line_num := ln_max_lnno + 1;
      BEGIN
      -->  Create a record in ap_invoice_lines based on the maximum line
	    INSERT INTO ap_invoice_lines_all
	    (
	        INVOICE_ID
	      , LINE_NUMBER
	      , LINE_TYPE_LOOKUP_CODE
	      , DESCRIPTION
	      , ORG_ID
	      , MATCH_TYPE
	      , ACCOUNTING_DATE
	      , PERIOD_NAME
	      , DEFERRED_ACCTG_FLAG
	      , DEF_ACCTG_START_DATE
	      , DEF_ACCTG_END_DATE
	      , DEF_ACCTG_NUMBER_OF_PERIODS
	      , DEF_ACCTG_PERIOD_TYPE
	      , SET_OF_BOOKS_ID
	      , AMOUNT
	      , WFAPPROVAL_STATUS
	      , CREATION_DATE
	      , CREATED_BY
	      , LAST_UPDATED_BY
	      , LAST_UPDATE_DATE
	      , LAST_UPDATE_LOGIN
	    )
	    VALUES
	    (
	        p_invoice_id
	      , ln_invc_line_num
	      , lv_misc
	      , lv_description
	      , p_org_id
	      , lv_not_matched
	      , rec_max_ap_lines_all.accounting_date
	      , rec_max_ap_lines_all.period_name
	      , rec_max_ap_lines_all.deferred_acctg_flag
	      , rec_max_ap_lines_all.def_acctg_start_date
	      , rec_max_ap_lines_all.def_acctg_end_date
	      , rec_max_ap_lines_all.def_acctg_number_of_periods
	      , rec_max_ap_lines_all.def_acctg_period_type
	      , rec_max_ap_lines_all.set_of_books_id
	      , insertion_amount
	       , lv_not_required
	      , sysdate
	      , ln_user_id
	      , ln_user_id
	      , sysdate
	      , ln_login_id
	    );
     EXCEPTION
      WHEN OTHERS THEN

       fnd_file.put_line(FND_FILE.LOG,' Error while inserting JAI Rounding
                                        adjustment in ail'|| SQLERRM);
       P_return_code     :=  jai_constants.unexpected_error;
       P_return_message  := 'Encountered an error in JAI_AP_IA_TRIGGER_PKG.ARUID_T1 '  || substr(sqlerrm,1,1900);
     END;
    END IF;

    -- 5(a)
    IF from_inv_line%ISOPEN THEN
     CLOSE from_inv_line;
    END IF;

    OPEN  from_inv_dist(p_invoice_id, lv_description,ln_invc_line_num,lv_misc);
     FETCH from_inv_dist INTO from_inv_dist_rec;

     -- 5(b)
     IF from_inv_dist%FOUND THEN

        UPDATE ap_invoice_distributions_all
           SET amount = insertion_amount,
               last_update_date = sysdate,
	       last_updated_by  = ln_user_id,
	       last_update_login = ln_login_id
         WHERE invoice_id               =p_invoice_id
           AND distribution_line_number = from_inv_dist_rec.distribution_line_number
           AND invoice_line_number =ln_invc_line_num ;
     ELSE
       CLOSE from_inv_dist;
       ln_distribution_line_num := 1;

       OPEN c_invoice_distribution(p_invoice_id);
		FETCH c_invoice_distribution INTO r_invoice_distribution;
	   CLOSE c_invoice_distribution;
           BEGIN
       -->  Create a record in distributions based on the new line created above
	    INSERT INTO ap_invoice_distributions_all
	    (
	      accounting_date,
	      accrual_posted_flag,
	      assets_addition_flag,
	      assets_tracking_flag,
	      cash_posted_flag,
	      distribution_line_number,
	      dist_code_combination_id,
	      invoice_id,
	      last_updated_by,
	      last_update_date,
	      line_type_lookup_code,
	      period_name,
	      set_of_books_id,
	      amount,
	      base_amount,
	      created_by,
	      creation_date,
	      description,
	      last_update_login,
	      posted_flag,
	      reversal_flag,
	      vat_code,
	      invoice_distribution_id,
	      org_id,
	      dist_match_type,
	      invoice_line_number
	    )
	    VALUES
	    (
	      rec_max_ap_lines_all.accounting_date,
	      r_invoice_distribution.accrual_posted_flag,
	      r_invoice_distribution.assets_addition_flag,
	      r_invoice_distribution.assets_tracking_flag,
	      lv_cash_posted_flag,
	      ln_distribution_line_num ,
	      set_up_values_rec.tolerance_charge_account_id,
	      p_invoice_id,
	      ln_user_id,
	      sysdate,
	      lv_misc,
	      rec_max_ap_lines_all.period_name,
	      rec_max_ap_lines_all.set_of_books_id,
	      insertion_amount,
	      insertion_amount,
	      ln_user_id,
	      sysdate,
	      lv_description, /* 'Commercial Rounding Off Distribution', Ramananda for removal of SQL LITERALs */
	      ln_login_id,
	      'N',
	      'N',
	      lv_vat_code, /* 'ROUNDING',  Ramananda for removal of SQL LITERALs */
	      ap_invoice_distributions_s.nextval,
	      p_org_id
	      ,lv_not_matched
	      ,ln_invc_line_num
	    );
         EXCEPTION
          when others then

          fnd_file.put_line(FND_FILE.LOG,' Error while inserting JAI Rounding adjustment in aid'|| SQLERRM);
          P_return_code     :=  jai_constants.unexpected_error;
          P_return_message  := 'Encountered an error in JAI_AP_IA_TRIGGER_PKG.ARUID_T1 '  || substr(sqlerrm,1,1900);
         END;
	 END IF;
     -- 5(b)

  END IF;
  -- 5

EXCEPTION

  WHEN OTHERS THEN
  fnd_file.put_line(FND_FILE.LOG,'Encountered an error in JAI_AP_IA_TRIGGER_PKG.ARUID_T1 '|| SQLERRM);

     P_return_code     :=  jai_constants.unexpected_error;
     P_return_message  := 'Encountered an error in JAI_AP_IA_TRIGGER_PKG.ARUID_T1 '  || substr(sqlerrm,1,1900);

END  inv_holds_check;


END jai_ap_tolerance_pkg;

/
