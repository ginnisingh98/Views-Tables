--------------------------------------------------------
--  DDL for Package Body JL_BR_AR_GENERATE_DEBIT_MEMO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AR_GENERATE_DEBIT_MEMO" AS
/*$Header: jlbrrdmb.pls 120.18.12010000.7 2010/04/27 13:22:57 mkandula ship $*/

/************************************************************************/
/*	Function get_account						*/
/*	Parameters: 	account type, 					*/
/*			transaction id, 				*/
/*			salesrep id   					*/
/*	Purpose: get the account id from Gl_code_combination         	*/
/************************************************************************/
FUNCTION	get_account(
  X_account_type 	VARCHAR2,
  X_cust_trx_type_id	NUMBER,
  X_salesrep_id	NUMBER,
  x_int_revenue_ccid NUMBER,
  x_billto_site_use_id NUMBER,	 -- Bug#7718063
  x_struct_num NUMBER,
  x_error_code OUT NOCOPY NUMBER,
  x_error_msg  OUT NOCOPY VARCHAR2,
  x_token      OUT NOCOPY VARCHAR2
) RETURN	NUMBER	IS

X_increment  		NUMBER;
X_counter		NUMBER;
X_gl_default_id		NUMBER;
X_select1		INTEGER;
X_select2		INTEGER;
X_cust_rev_id		NUMBER;
X_cust_rec_id		NUMBER;
X_site_rev_id           NUMBER;        -- Bug#7718063
X_site_rec_id           NUMBER;        -- Bug#7718063
X_sale_rev_id		NUMBER;
X_sale_rec_id		NUMBER;
X_remittance_bank_account_id NUMBER;
X_receipt_method_id     NUMBER;
X_currency_code         NUMBER;
X_gl_id			NUMBER;
X_amount_id		NUMBER;
X_segment_name		VARCHAR2(30);
X_table_name		VARCHAR2(100);
X_constant		VARCHAR2(50);
X_segment_amount	VARCHAR2(25);
X_condition		VARCHAR2(500);
X_selection		INTEGER;
X_first_time		boolean;
X_memo_rev_id           NUMBER;
X_ccid                  NUMBER;
X_segs                  FND_FLEX_EXT.SegmentArray;
X_dummy                 BOOLEAN;
x_flexfield             VARCHAR2(2000);
x_dyn_insert            VARCHAR2(2) ;
x_delimiter             VARCHAR2(1);

 /* Select the segment number, table name and constant to get the account */

CURSOR c1 IS
  SELECT segment, table_name, constant
  FROM ra_account_default_segments
  WHERE gl_default_id = X_gl_default_id;

BEGIN
  X_first_time := TRUE;
  x_dyn_insert := 'N';

/* Get the id to access RA_ACCOUNT_DEFAULT_SEGMENTS table */

  SELECT gl_default_id
  INTO	X_gl_default_id
  FROM ra_account_defaults
  WHERE type=X_account_type;

/* Get number of segments to the transaction type */

  SELECT count(*)
  INTO	X_counter
  FROM ra_account_default_segments
  WHERE gl_default_id = X_gl_default_id;

/* Get the account id to the Revene and Receivables tables
  RA_CUST_TRX_TYPES e RA_SALESREPS AR_MEMO_LINES*/

  BEGIN
    SELECT gl_id_rev, gl_id_rec
    INTO X_cust_rev_id, X_cust_rec_id
    FROM ra_cust_trx_types
    WHERE cust_trx_type_id = X_cust_trx_type_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;

  BEGIN
    SELECT gl_id_rev, gl_id_rec
    INTO X_sale_rev_id, X_sale_rec_id
    FROM ra_salesreps
    WHERE salesrep_id = X_salesrep_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;

   -- Bug#7718063 Start
  BEGIN
     SELECT gl_id_rev, gl_id_rec
     INTO X_site_rev_id, X_site_rec_id
     FROM HZ_CUST_SITE_USES     		---FROM ra_site_uses     --Replaced by the R12 table
     WHERE site_use_id = x_billto_site_use_id;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN NULL;
  END;
   -- Bug#7718063 End

  x_error_code := 0;

  OPEN c1;
  FOR X_increment IN 1..X_counter
  LOOP
    FETCH c1 INTO X_segment_name, X_table_name, X_constant;
    EXIT WHEN c1%NOTFOUND;

    X_select1 := DBMS_SQL.OPEN_CURSOR;

  /* Se o segmento nao e' uma X_constant entao
  	Verifica se o segmento esta' na tab. RA_CUST_TRX_TYPES entao
  		se o tipo de conta for Revenue Account entao
  			busca o id da conta Rev. da RA_CUST_TRX_TYPES
  		senao se o tipo de conta for Receivable Account entao
  			busca o id da conta Rec. da RA_CUST_TRX_TYPES
  	senao verifica se segmento esta tab. RA_SALESREPS entao
  		se o tipo de conta for Revenue Account entao
                                busca o id da conta Rev. da RA_SALESREPS
  		senao se o tipo de conta for Receivable Account entao
                                busca o id da conta Rec. da RA_SALESREPS
  */
    IF X_constant IS NULL THEN
      IF X_table_name = 'RA_CUST_TRX_TYPES' THEN
        IF X_account_type = 'REV' THEN
  	  X_gl_id := X_cust_rev_id;
        ELSIF X_account_type = 'REC' THEN
  	  X_gl_id := X_cust_rec_id;
        END IF;
      ELSIF X_table_name = 'RA_SALESREPS' THEN
        IF X_account_type = 'REV' THEN
  	  X_gl_id := X_sale_rev_id;
        ELSIF X_account_type = 'REC' THEN
  	  X_gl_id := X_sale_rec_id;
        END IF;

	-- Bug#7718063 Start
      --ELSIF X_table_name = 'RA_SITE_USES' THEN	  -- Replaced by the R12 table

	ELSIF X_table_name = 'HZ_CUST_SITE_USES' THEN
 	  IF X_account_type = 'REV' THEN
 	   X_gl_id := X_site_rev_id;
 	  ELSIF X_account_type = 'REC' THEN
 	   X_gl_id := X_site_rec_id;
 	  END IF;
       -- Bug#7718063 End

      /*ELSIF X_table_name = 'RA_STD_TRX_LINES' THEN*/
      ELSE
          X_gl_id := x_int_revenue_ccid;
      END IF;

  /* Mount the select dynamically to find the segment (X) in
     gl_code_combinations table */

     /*Bug 2939830 - SQL Bind compliance project
      DBMS_SQL.PARSE(X_select1, 'SELECT '||X_segment_name||'
      FROM gl_code_combinations WHERE code_combination_id = '
  	|| X_gl_id, DBMS_SQL.v7);
    */

      DBMS_SQL.PARSE(X_select1, 'SELECT '||X_segment_name||'
      FROM gl_code_combinations WHERE code_combination_id = :x and chart_of_accounts_id = :y ', DBMS_SQL.v7);

      DBMS_SQL.BIND_VARIABLE (X_select1, ':x', X_gl_id) ;
      DBMS_SQL.BIND_VARIABLE (X_select1, ':y', X_struct_num) ;
     -- End of fix for SQL Bind Compliance

  /* Mount the where clause to get the gl_code_combinations id */

      DBMS_SQL.DEFINE_COLUMN(X_select1,1,X_segment_amount,25);
      X_selection := DBMS_SQL.EXECUTE(X_select1);
      IF DBMS_SQL.FETCH_ROWS (X_select1) > 0 THEN
        DBMS_SQL.COLUMN_VALUE(X_select1,1,X_segment_amount);
        IF X_first_time	THEN
          X_condition := X_segment_name||'='||''''||X_segment_amount||'''';
          X_segs(x_increment) := x_segment_amount;
          X_first_time := FALSE;
        ELSE
          X_condition := X_condition||' and '||X_segment_name||'='||''''||X_segment_amount||'''';
          X_segs(x_increment) := x_segment_amount;
        END IF;
      END IF;
    ELSE
      IF X_first_time THEN
  	X_condition := X_segment_name||'='||''''||X_constant||'''';
        X_segs(x_increment) := x_constant;
  	X_first_time := FALSE;
      ELSE
  	X_condition := X_condition||' and '||X_segment_name||'='||''''||X_constant||'''';
        X_segs(x_increment) := x_constant;
      END IF;
    END IF;
    DBMS_SQL.CLOSE_CURSOR(X_select1);
  END LOOP;

    X_condition := X_condition||' and chart_of_accounts_id ='||to_char(x_struct_num);

  /* Mount the select to get the account on gl_code_combinations */
  -- Bug 2089230 following close cursor was moved above - before end loop.
  --DBMS_SQL.CLOSE_CURSOR(X_select1);
  BEGIN
  X_select2 := DBMS_SQL.OPEN_CURSOR;

  /*ignored conversion for bug 2939830 since entire where clause cannot be passed as bind variable - GBUZSAK*/
  DBMS_SQL.PARSE(X_select2,'SELECT code_combination_id FROM gl_code_combinations WHERE '||X_condition,DBMS_SQL.v7);

  DBMS_SQL.DEFINE_COLUMN(X_select2,1,X_amount_id);
  X_selection := DBMS_SQL.EXECUTE(X_select2);
  IF DBMS_SQL.FETCH_ROWS (X_select2) > 0 THEN
    DBMS_SQL.COLUMN_VALUE(X_select2,1,X_amount_id);
  END IF;
  DBMS_SQL.CLOSE_CURSOR(X_select2);
  EXCEPTION
   WHEN OTHERS THEN NULL;
  END;

  CLOSE c1;

  IF x_amount_id is NULL THEN

     x_delimiter := fnd_flex_ext.get_delimiter('SQLGL','GL#',x_struct_num);

      BEGIN

        SELECT  DYNAMIC_INSERTS_ALLOWED_FLAG
        INTO    x_dyn_insert
        FROM    fnd_id_flex_Structures ffs
        WHERE   ffs.APPLICATION_ID = 101
        AND     ffs.ID_FLEX_CODE = 'GL#'
        AND     ffs.ID_FLEX_NUM = x_struct_num;

      EXCEPTION
        WHEN OTHERS THEN
          x_dyn_insert := 'N';
      END;

      IF X_dyn_insert = 'Y' THEN

        x_dummy := FND_FLEX_EXT.get_combination_id ('SQLGL', 'GL#',x_struct_num,
                                                 sysdate, x_counter,
                                                  x_segs,x_amount_id);

        IF NOT(x_dummy) THEN

          x_flexfield := fnd_flex_ext.concatenate_segments( x_counter,
                                                          x_segs,
                                                          x_delimiter);

          x_error_msg := 'JL_CO_FA_CCID_NOT_CREATED';
          x_error_code := 62324;
          x_token := x_flexfield;

        END IF;

      ELSE

        x_error_msg  := 'JL_DYN_INS_NOT_ALLOWED';

        x_error_code := 61245;

      END IF;

  END IF;

  RETURN (X_amount_id);

END get_account;

/************************************************************************/
/*	Procedure ins_ra_batches					*/
/*	Purpose : Get all the fields to insert row in ra_batches   	*/
/************************************************************************/

PROCEDURE ins_ra_batches (
  X_batch_source_id	IN	NUMBER,
  X_invoice_amount	IN	NUMBER,
  X_invoice_currency_code IN    VARCHAR2,
  X_user_id		IN	NUMBER,
  X_batch_id		IN OUT NOCOPY	NUMBER
) IS
X_batch_name		VARCHAR2(50);
X_set_of_books_id	NUMBER(15);
X_batch_rec	ra_batches%ROWTYPE;
BEGIN

  SELECT set_of_books_id
  INTO	X_set_of_books_id
  FROM ar_system_parameters;

  X_batch_rec.batch_date := sysdate;
  X_batch_rec.gl_date := sysdate;
  X_batch_rec.status := 'NB';
  X_batch_rec.batch_source_id := X_batch_source_id;
  X_batch_rec.set_of_books_id := X_set_of_books_id;
  X_batch_rec.control_count := 1;
  X_batch_rec.control_amount := X_invoice_amount;
  X_batch_rec.currency_code := X_invoice_currency_code;
  --arp_tbat_pkg.insert_p(X_batch_rec, X_batch_id, X_batch_name);

END ins_ra_batches;

/************************************************************************/
/* 	Function : Generate_Interest_DM_Number				*/
/*	Purpose  : Get the number to the transaction			*/
/************************************************************************/

FUNCTION generate_interest_DM_number(
  X_original_customer_trx_id	NUMBER,
  X_payment_schedule_id		NUMBER
) RETURN	VARCHAR2	IS
X_next_sequence	NUMBER;
X_first_position	NUMBER;
X_terms_sequence      NUMBER;
X_trx_number		VARCHAR2(30);
BEGIN

  BEGIN

  /*	Find the string '-NDJ' to know which number will be
  	the Debit Memo transaction */

  SELECT nvl(max(instr(trx_number,'-NDJ')) + 4,0) --bug 6011423
  INTO X_first_position
  FROM ra_customer_trx
  WHERE related_customer_trx_id=X_original_customer_trx_id
  AND trx_number like '%-NDJ%';

  SELECT nvl(MAX(TO_NUMBER(SUBSTR(trx_number,X_first_position,LENGTH(trx_number)-
  	X_first_position+1)))+1,1) --bug 6011423
  INTO X_next_sequence
  FROM ra_customer_trx
  WHERE related_customer_trx_id=X_original_customer_trx_id
  AND trx_number LIKE '%-NDJ%';

  /*	If the selects failure, then this is the first
	Interest Debit Memo to this transaction */

  EXCEPTION
  	WHEN NO_DATA_FOUND	THEN
  	X_next_sequence := 1;
  END;

  /*	Get the transaction number to mount the Interest Debit
	Memo transaction number */

  SELECT trx_number, terms_sequence_number
  INTO X_trx_number, X_terms_sequence
  FROM ar_payment_schedules
  WHERE payment_schedule_id = X_payment_schedule_id;

  X_trx_number := X_trx_number||'-'||X_terms_sequence||'-NDJ'||X_next_sequence;
  RETURN X_trx_number;
END generate_interest_DM_number;

/************************************************************************/
/*	Procedure ins_ra_customer_trx					*/
/*	Purpose : Get the fields to insert into ra_customer_trx    	*/
/************************************************************************/

PROCEDURE ins_ra_customer_trx (
  X_inv_cust_trx_id	IN	NUMBER,
  X_new_cust_trx_id 	IN OUT NOCOPY	NUMBER,
  X_set_of_books_id	IN OUT NOCOPY	NUMBER,
  X_lastlogin		IN OUT NOCOPY	NUMBER,
  X_primary_salesrep_id	IN OUT NOCOPY	NUMBER,
  X_billto_customer_id	IN OUT NOCOPY	NUMBER,
  X_billto_site_use_id	IN OUT NOCOPY	NUMBER,
  X_invoice_currencycode IN OUT NOCOPY	VARCHAR2,
  X_trx_number		IN OUT NOCOPY	VARCHAR2,
  X_termid		IN OUT NOCOPY	NUMBER,
  X_legal_entity_id IN OUT NOCOPY NUMBER, -- Bug#7835709
  X_cust_trx_type_id	IN	NUMBER,
  X_payment_schedule_id	IN	NUMBER,
  X_user_id		IN	NUMBER,
  X_batch_source_id	IN	NUMBER,
  X_receipt_method_id	IN	NUMBER,
  X_batch_id		IN	NUMBER,
  X_idm_date		IN	DATE
) IS
X_sold_to_customer_id	NUMBER(15);
X_ship_to_customer_id	NUMBER(15);
X_ship_to_site_use_id	NUMBER(15);
X_remit_to_address_id	NUMBER(15);
X_printing_option	VARCHAR2(20);
X_territory_id		NUMBER(15);
X_attribute1		VARCHAR2(150);
X_global_attribute1	VARCHAR2(150);
X_global_attribute2	VARCHAR2(150);
X_global_attribute3	VARCHAR2(150);
X_global_attribute4	VARCHAR2(150);
X_global_attribute5	VARCHAR2(150);
X_global_attribute6	VARCHAR2(150);
X_global_attribute7	VARCHAR2(150);
X_org_id                NUMBER(15);

l_trx_rec               ra_customer_trx%ROWTYPE;


BEGIN
/*  SELECT ra_customer_trx_s.nextval
  INTO X_new_cust_trx_id
  FROM sys.dual;
*/

  X_trx_number := jl_br_ar_generate_debit_memo.generate_interest_DM_number(X_inv_cust_trx_id,
  				 X_payment_schedule_id);

  SELECT to_number(global_attribute20)
  INTO	X_termid
  FROM ar_system_parameters;

  SELECT last_update_login,
  	set_of_books_id,
  	sold_to_customer_id,
  	bill_to_customer_id,
  	bill_to_site_use_id,
  	ship_to_customer_id,
  	ship_to_site_use_id,
  	remit_to_address_id,
  	primary_salesrep_id,
  	printing_option,
  	territory_id,
  	invoice_currency_code,
	legal_entity_id, -- Bug#7835709
  	attribute1,
  	global_attribute1,
  	global_attribute2,
  	global_attribute3,
  	global_attribute4,
  	global_attribute5,
  	global_attribute6,
  	global_attribute7,
        org_id
  INTO	X_lastlogin,
  	X_set_of_books_id,
  	X_sold_to_customer_id,
  	X_billto_customer_id,
  	X_billto_site_use_id,
  	X_ship_to_customer_id,
  	X_ship_to_site_use_id,
  	X_remit_to_address_id,
  	X_primary_salesrep_id,
  	X_printing_option,
  	X_territory_id,
  	X_invoice_currencycode,
	X_legal_entity_id, -- Bug#7835709
  	X_attribute1,
  	X_global_attribute1,
  	X_global_attribute2,
  	X_global_attribute3,
  	X_global_attribute4,
  	X_global_attribute5,
  	X_global_attribute6,
  	X_global_attribute7,
        X_org_id
  FROM	ra_customer_trx
  WHERE	customer_trx_id = X_inv_cust_trx_id;

/*  INSERT INTO ra_customer_trx (
  	customer_trx_id,
  	last_update_date,
  	last_updated_by,
  	creation_date,
  	created_by,
  	last_update_login,
  	trx_number,
  	related_customer_trx_id,
  	cust_trx_type_id,
  	trx_date,
  	set_of_books_id,
  	batch_source_id,
  	batch_id,
  	sold_to_customer_id,
  	bill_to_customer_id,
  	bill_to_site_use_id,
  	ship_to_customer_id,
  	ship_to_site_use_id,
  	remit_to_address_id,
  	term_id,
  	primary_salesrep_id,
  	printing_option,
  	printing_pending,
  	territory_id,
  	invoice_currency_code,
  	attribute1,
  	complete_flag,
  	receipt_method_id,
  	status_trx,
  	default_tax_exempt_flag,
  	created_from,
  	global_attribute1,
  	global_attribute2,
  	global_attribute3,
        global_attribute4,
        global_attribute5,
        global_attribute6,
        global_attribute7
  ) VALUES (
  	X_new_cust_trx_id,
  	sysdate,
  	X_user_id,
  	sysdate,
  	X_user_id,
  	X_lastlogin,
  	X_trx_number,
  	X_inv_cust_trx_id,
  	X_cust_trx_type_id,
  	X_idm_date,
  	X_set_of_books_id,
  	X_batch_source_id,
  	X_batch_id,
  	X_sold_to_customer_id,
  	X_billto_customer_id,
  	X_billto_site_use_id,
  	X_ship_to_customer_id,
  	X_ship_to_site_use_id,
  	X_remit_to_address_id,
  	X_termid,
  	X_primary_salesrep_id,
  	X_printing_option,
  	'N',
  	X_territory_id,
  	X_invoice_currencycode,
  	X_attribute1,
  	'Y',
  	X_receipt_method_id,
  	'OP',
  	'S',
  	'RAXMATRX',
  	X_global_attribute1,
  	X_global_attribute2,
  	X_global_attribute3,
  	X_global_attribute4,
  	X_global_attribute5,
  	X_global_attribute6,
  	X_global_attribute7
  );
*/

/* Replace Insert by AR's Table Handlers. Bug # 2249731 */

    l_trx_rec.last_update_date :=   	  sysdate;
    l_trx_rec.last_updated_by :=   	  X_user_id;
    l_trx_rec.creation_date :=   	  sysdate;
    l_trx_rec.created_by :=   	          X_user_id;
    l_trx_rec.last_update_login :=   	  X_lastlogin;
    l_trx_rec.trx_number :=   	          X_trx_number;
    l_trx_rec.related_customer_trx_id :=  X_inv_cust_trx_id;
    l_trx_rec.cust_trx_type_id :=   	  X_cust_trx_type_id;
    l_trx_rec.trx_date :=   	          X_idm_date ;
    l_trx_rec.set_of_books_id :=  	  X_set_of_books_id;
    l_trx_rec.batch_source_id :=   	  X_batch_source_id;
    l_trx_rec.batch_id :=   	          X_batch_id;
    l_trx_rec.sold_to_customer_id :=   	  X_sold_to_customer_id;
    l_trx_rec.bill_to_customer_id :=   	  X_billto_customer_id;
    l_trx_rec.bill_to_site_use_id :=      X_billto_site_use_id;
    l_trx_rec.ship_to_customer_id :=   	  X_ship_to_customer_id;
    l_trx_rec.ship_to_site_use_id :=   	  X_ship_to_site_use_id ;
    l_trx_rec.remit_to_address_id :=  	  X_remit_to_address_id;
    l_trx_rec.term_id :=   	          X_termid;
	l_trx_rec.legal_entity_id :=   	  X_legal_entity_id; -- Bug#7835709
    l_trx_rec.primary_salesrep_id :=   	  X_primary_salesrep_id;
    l_trx_rec.printing_option :=   	  X_printing_option;
    l_trx_rec.printing_pending :=   	  'N';
    l_trx_rec.territory_id :=   	  X_territory_id;
    l_trx_rec.invoice_currency_code :=    X_invoice_currencycode;
    l_trx_rec.attribute1 :=   	          X_attribute1;
    l_trx_rec.complete_flag :=   	  'Y';
    l_trx_rec.receipt_method_id :=   	  X_receipt_method_id;
    l_trx_rec.status_trx :=   	          'OP';
    l_trx_rec.default_tax_exempt_flag :=  'S';
    l_trx_rec.created_from :=   	  'RAXMATRX';
    l_trx_rec.global_attribute1 :=   	  X_global_attribute1;
    l_trx_rec.global_attribute2 :=   	  X_global_attribute2;
    l_trx_rec.global_attribute3 :=  	  X_global_attribute3;
    l_trx_rec.global_attribute4 :=   	  X_global_attribute4;
    l_trx_rec.global_attribute5 :=   	  X_global_attribute5;
    l_trx_rec.global_attribute6 :=   	  X_global_attribute6;
    l_trx_rec.global_attribute7 :=   	  X_global_attribute7;
    l_trx_rec.org_id            :=        X_org_id;

    arp_ct_pkg.insert_p(l_trx_rec, X_trx_number, X_new_cust_trx_id);

  EXCEPTION
  	WHEN NO_DATA_FOUND THEN
                    RAISE_APPLICATION_ERROR( -20000,
                   'IL: Id da Transacao Invalido'||sqlerrm );
END ins_ra_customer_trx;

/************************************************************************/
/*	Procedure ins_ra_customer_trx_lines				*/
/*	Purpose : Get the fields to insert into ra_customer_trx_lines   */
/************************************************************************/

PROCEDURE ins_ra_customer_trx_lines (
  X_new_customer_trx_id	IN	NUMBER,
  X_invoice_amount	IN	NUMBER,
  X_set_of_books_id	IN	NUMBER,
  X_user_id		IN	NUMBER,
  X_last_login		IN	NUMBER,
  X_customertrx_line_id	IN OUT  NOCOPY  NUMBER
) IS
  l_org_id       NUMBER(15);
BEGIN
  SELECT ra_customer_trx_lines_s.nextval
  INTO X_customertrx_line_id
  FROM dual;

  SELECT org_id into l_org_id
  FROM   ra_customer_trx_all
  Where  customer_trx_id = x_new_customer_trx_id;

  INSERT INTO ra_customer_trx_lines (
  	customer_trx_line_id,
  	last_update_date,
  	last_updated_by,
  	creation_date,
  	created_by,
  	last_update_login,
  	customer_trx_id,
  	line_number,
  	set_of_books_id,
  	description,
  	quantity_invoiced,
  	unit_selling_price,
  	line_type,
  	extended_amount,
  	revenue_amount,
  	tax_exempt_flag,
        org_id
  ) VALUES (
  	X_customertrx_line_id,
  	sysdate,
  	X_user_id,
  	sysdate,
  	X_user_id,
  	X_last_login,
  	X_new_customer_trx_id,
  	'1',
  	X_set_of_books_id,
  	'Nota de Debito Juros',
  	'1',
  	X_invoice_amount,
  	'LINE',
  	X_invoice_amount,
  	X_invoice_amount,
  	'S',
        l_org_id
  );
END ins_ra_customer_trx_lines;

/***************************************************************************/
/*	Procedure ins_ra_cust_trx_line_salesreps			   */
/*	Purpose : Get the fields to insert into ra_cust_trx_line_salesreps */
/***************************************************************************/
PROCEDURE ins_ra_cust_trx_line_salesreps (
  X_new_cust_trx_id	IN	NUMBER,
  X_new_cust_trx_line_id IN	NUMBER,
  X_salesrep_id		IN	NUMBER,
  X_user_id		IN	NUMBER,
  X_last_login		IN	NUMBER,
  X_invoice_amount	IN	NUMBER
) IS
l_org_id      NUMBER(15);
BEGIN
  SELECT org_id into l_org_id
  FROM ra_customer_trx_all where
  customer_trx_id = x_new_cust_trx_id;

  INSERT INTO ra_cust_trx_line_salesreps (
  	cust_trx_line_salesrep_id,
  	last_update_date,
  	last_updated_by,
  	creation_date,
  	created_by,
  	last_update_login,
  	customer_trx_id,
  	salesrep_id,
  	revenue_percent_split,
  	revenue_amount_split,
        org_id
  ) VALUES (
  	ra_cust_trx_line_salesreps_s.nextval,
  	sysdate,
  	X_user_id,
  	sysdate,
  	X_user_id,
  	X_last_login,
  	X_new_cust_trx_id,
  	X_salesrep_id,
  	'100',
  	X_invoice_amount,
        l_org_id
  );

  INSERT INTO ra_cust_trx_line_salesreps (
  	cust_trx_line_salesrep_id,
  	last_update_date,
  	last_updated_by,
  	creation_date,
  	created_by,
  	last_update_login,
  	customer_trx_id,
  	customer_trx_line_id,
  	salesrep_id,
  	revenue_percent_split,
  	revenue_amount_split,
        org_id
  ) VALUES (
  	ra_cust_trx_line_salesreps_s.nextval,
  	sysdate,
  	X_user_id,
  	sysdate,
  	X_user_id,
  	X_last_login,
  	X_new_cust_trx_id,
  	X_new_cust_trx_line_id,
  	X_salesrep_id,
  	'100',
  	X_invoice_amount,
        l_org_id
  );
END ins_ra_cust_trx_line_salesreps;

/************************************************************************/
/*	Procedure ins_ra_cust_trx_line_gl_dist				*/
/*	Purpose : Get the fields to insert into ra_cust_trx_line_gl_dist*/
/************************************************************************/
PROCEDURE	ins_ra_cust_trx_line_gl_dist (
  X_customer_trx_id	IN	NUMBER,
  X_customer_trx_line_id IN OUT NOCOPY	NUMBER,
  X_invoice_amount	IN	NUMBER,
  X_set_of_books_id	IN	NUMBER,
  X_user_id		IN	NUMBER,
  X_batch_source_id	IN	NUMBER,
  X_last_login		IN	NUMBER,
  X_cust_trx_type_id	IN	NUMBER,
  X_billto_site_use_id  IN	NUMBER,    -- Bug#7718063
  X_salesrep_id		IN	NUMBER,
  X_account_type	IN	VARCHAR,
  X_idm_date		IN	DATE,
  x_int_revenue_ccid    IN      NUMBER,
  X_invoice_currency_code IN    VARCHAR2,
  X_minimum_accountable_unit IN NUMBER,
  X_precision           IN      NUMBER,
  x_error_code          OUT NOCOPY   NUMBER,
  x_error_msg           OUT NOCOPY   VARCHAR2,
  x_token               OUT NOCOPY   VARCHAR2
) IS
X_code_id	NUMBER(15);
X_gl_date	DATE;
X_post_gl	VARCHAR2(1);
--X_latest_rec_flag	VARCHAR2(1);
X_line_salesrepid	NUMBER(15);
X_custtrx_line_id	NUMBER(15);
X_memo_line_id      NUMBER(15);
X_cust_trx_line_gl_dist_id NUMBER(15);
l_dist_rec          ra_cust_trx_line_gl_dist%ROWTYPE;
x_struct_num         NUMBER(15);
invalid_account      EXCEPTION;
l_org_id            NUMBER(15);

BEGIN

  SELECT org_id into l_org_id from ra_customer_trx_all where
  customer_trx_id = x_customer_trx_id;
  SELECT chart_of_accounts_id into x_struct_num FROM gl_sets_of_books
  WHERE  set_of_books_id = x_set_of_books_id;

/*
 X_code_id := jl_br_ar_generate_debit_memo.get_account(X_account_type,X_cust_trx_type_id, X_salesrep_id,x_int_revenue_ccid,x_struct_num,x_error_code, x_error_msg,x_token); */

 -- Bug#7718063 Start

 	   X_code_id := jl_br_ar_generate_debit_memo.get_account(X_account_type,X_cust_trx_type_id, X_salesrep_id,x_int_revenue_ccid,x_billto_site_use_id,x_struct_num,x_error_code, x_error_msg,x_token);

 -- Bug#7718063 End

  IF X_code_id is NULL THEN

   Raise invalid_account;

  END IF;

  IF X_account_type = 'REC' THEN
    --X_latest_rec_flag := 'Y';  --Bug 3067731 - ARs table handler handles it
    X_custtrx_line_id := NULL;
    X_line_salesrepid := NULL;
  ELSE
    BEGIN
      X_custtrx_line_id := X_customer_trx_line_id;
      SELECT ra_cust_trx_line_salesreps_s.nextval
      INTO X_line_salesrepid
      FROM sys.dual;
    END;
  END IF;

  /* Check if this transaction has to be posted to GL */
  SELECT post_to_gl
  INTO	X_post_gl
  FROM	ra_cust_trx_types
  WHERE	cust_trx_type_id = X_cust_trx_type_id;

  IF X_post_gl = 'Y' THEN
    X_gl_date := X_idm_date;
  ELSE
    X_gl_date := NULL;
  END IF;

  --Commented out for Bug 3067731; Need to call AR table handler instead of direct insert
 /* INSERT INTO ra_cust_trx_line_gl_dist (
  	cust_trx_line_gl_dist_id,
  	customer_trx_line_id,
  	code_combination_id,
  	set_of_books_id,
  	last_update_date,
  	last_updated_by,
  	creation_date,
  	created_by,
  	percent,
  	amount,
  	gl_date,
  	cust_trx_line_salesrep_id,
  	original_gl_date,
  	posting_control_id,
  	account_class,
  	customer_trx_id,
  	account_set_flag,
  	acctd_amount,
  	latest_rec_flag
  ) VALUES (
  	ra_cust_trx_line_gl_dist_s.nextval,
  	X_custtrx_line_id,
  	X_code_id,
  	X_set_of_books_id,
  	sysdate,
  	X_user_id,
  	sysdate,
  	X_user_id,
  	'100',
  	X_invoice_amount,
  	X_gl_date,
  	X_line_salesrepid,
  	X_gl_date,
  	'-3',
  	X_account_type,
  	X_customer_trx_id,
  	'N',
  	X_invoice_amount,
  	X_latest_rec_flag
  );
  */
   l_dist_rec.customer_trx_line_id      :=  x_custtrx_line_id;
   l_dist_rec.customer_trx_id           :=  x_customer_trx_id;
   l_dist_rec.code_combination_id       :=  x_code_id;
   l_dist_rec.set_of_books_id           :=  x_set_of_books_id;
   l_dist_rec.percent                   :=  '100';
   l_dist_rec.amount                    :=  x_invoice_amount;
   l_dist_rec.gl_date                   :=  x_gl_date;
   l_dist_rec.cust_trx_line_salesrep_id :=  X_line_salesrepid;
   l_dist_rec.original_gl_date          :=  x_gl_date;
   l_dist_rec.account_class             :=  x_account_type;
   l_dist_rec.account_set_flag          :=  'N';
   l_dist_rec.acctd_amount              :=  x_invoice_amount;
   l_dist_rec.org_id                    :=  l_org_id;

-- Inserted new parameters for fixing 3498430.......
   ARP_CTLGD_PKG.insert_p (l_dist_rec, X_cust_trx_line_gl_dist_id,NULL,X_invoice_currency_code,X_precision,X_minimum_accountable_unit);
   --End of fix for bug 3067731

  EXCEPTION
   WHEN invalid_account THEN
     Raise;
   WHEN OTHERS THEN
     x_error_code := sqlcode;
     x_error_msg := sqlerrm;

END ins_ra_cust_trx_line_gl_dist;

/************************************************************************/
/*	Procedure ins_ar_payment_schedules				*/
/*	Purpose : Get the fields to insert into ar_payment_schedules    */
/************************************************************************/
PROCEDURE ins_ar_payment_schedules (
  X_user_id		IN	NUMBER,
  X_last_login		IN	NUMBER,
  X_invoice_amount	IN	NUMBER,
  X_invoice_currency_code IN	VARCHAR2,
  X_cust_trx_type_id	IN	NUMBER,
  X_customer_id		IN	NUMBER,
  X_customer_site_use_id IN	NUMBER,
  X_customer_trx_id	IN	NUMBER,
  X_term_id		IN	NUMBER,
  X_trx_number		IN	VARCHAR2,
  X_idm_date		IN	DATE
) IS
X_payment_scheduleid NUMBER(15);
l_org_id             NUMBER(15);
l_ps_rec  ar_payment_schedules%ROWTYPE;
X_due_date           DATE;
BEGIN
  SELECT ar_payment_schedules_s.nextval
  INTO X_payment_scheduleid
  FROM sys.dual;


/*  INSERT INTO ar_payment_schedules (
  	payment_schedule_id,
  	last_update_date,
  	last_updated_by,
  	creation_date,
  	created_by,
  	last_update_login,
  	due_date,
  	amount_due_original,
  	amount_due_remaining,
  	number_of_due_dates,
  	status,
  	invoice_currency_code,
  	class,
  	cust_trx_type_id,
  	customer_id,
  	customer_site_use_id,
  	customer_trx_id,
  	term_id,
  	terms_sequence_number,
  	gl_date_closed,
  	actual_date_closed,
  	amount_line_items_original,
  	amount_line_items_remaining,
  	trx_number,
  	trx_date,
  	gl_date,
  	acctd_amount_due_remaining
  ) VALUES (
  	X_payment_scheduleid,
  	sysdate,
  	X_user_id,
  	sysdate,
  	X_user_id,
  	X_last_login,
  	X_idm_date,
  	X_invoice_amount,
  	X_invoice_amount,
  	'1',
  	'OP',
  	X_invoice_currency_code,
  	'DM',
  	X_cust_trx_type_id,
  	X_customer_id,
  	X_customer_site_use_id,
  	X_customer_trx_id,
  	X_term_id,
  	'1',
  	to_date('31124712','DDMMYYYY'),
  	to_date('31124712','DDMMYYYY'),
  	X_invoice_amount,
  	X_invoice_amount,
  	X_trx_number,
  	X_idm_date,
  	X_idm_date,
  	X_invoice_amount
  );
*/

BEGIN
   X_due_date := ARPT_SQL_FUNC_UTIL.Get_first_due_date(X_term_id, X_idm_date);
  EXCEPTION
    WHEN others THEN
     X_due_date := X_idm_date;
  END;

  IF X_due_date is NULL THEN
    X_due_date := X_idm_date;
  END IF;

/* Replace Insert by AR's table handler. Bug # 2249731 */

  SELECT org_id into l_org_id from
  ra_customer_trx_all
  where customer_trx_id = X_customer_trx_id;
  l_ps_rec.last_update_date := sysdate;
  l_ps_rec.last_updated_by :=  X_user_id;
  l_ps_rec.creation_date :=  sysdate;
  l_ps_rec.created_by :=  X_user_id;
  l_ps_rec.last_update_login :=  X_last_login;
  l_ps_rec.due_date :=  X_due_date;
  l_ps_rec.amount_due_original :=  X_invoice_amount;
  l_ps_rec.amount_due_remaining :=  X_invoice_amount;
  l_ps_rec.number_of_due_dates :=  '1';
  l_ps_rec.status :=  'OP';
  l_ps_rec.invoice_currency_code :=  X_invoice_currency_code;
  l_ps_rec.class :=  'DM';
  l_ps_rec.cust_trx_type_id :=  X_cust_trx_type_id;
  l_ps_rec.customer_id :=  X_customer_id;
  l_ps_rec.customer_site_use_id :=  X_customer_site_use_id;
  l_ps_rec.customer_trx_id :=  X_customer_trx_id;
  l_ps_rec.term_id :=  X_term_id;
  l_ps_rec.terms_sequence_number :=  '1';
  l_ps_rec.gl_date_closed :=  to_date('31124712','DDMMYYYY');
  l_ps_rec.actual_date_closed :=  to_date('31124712','DDMMYYYY');
  l_ps_rec.amount_line_items_original :=  X_invoice_amount;
  l_ps_rec.amount_line_items_remaining :=  X_invoice_amount;
  l_ps_rec.trx_number :=  X_trx_number;
  l_ps_rec.trx_date :=  X_idm_date;
  l_ps_rec.gl_date :=  X_idm_date;
  l_ps_rec.org_id :=  l_org_id;
  l_ps_rec.acctd_amount_due_remaining :=  X_invoice_amount;

  arp_ps_pkg.insert_p(l_ps_rec, X_payment_scheduleid);

END ins_ar_payment_schedules;

/************************************************************************/
/*	Procedure sla_create_event                                      */
/*	Purpose : Call AR procedure to create SLA accounting            */
/*              event for new Debit Memo transaction                    */
/* SLA KI - bug 4301543                                                 */
/************************************************************************/
PROCEDURE sla_create_event (
  X_customer_trx_id	IN	NUMBER
) IS
  l_ev_rec  arp_xla_events.xla_events_type;
BEGIN
     l_ev_rec.xla_from_doc_id   := X_customer_trx_id;
     l_ev_rec.xla_to_doc_id     := X_customer_trx_id;
     l_ev_rec.xla_req_id        := NULL;
     l_ev_rec.xla_dist_id       := NULL;
     l_ev_rec.xla_doc_table     := 'CT';
     l_ev_rec.xla_doc_event     := NULL;
     l_ev_rec.xla_mode          := 'O';
     l_ev_rec.xla_call          := 'B';
     l_ev_rec.xla_fetch_size    := 999;
     arp_xla_events.create_events(p_xla_ev_rec => l_ev_rec );
END sla_create_event;

PROCEDURE jl_br_interest_debit_memo (
  X_original_customer_trx_id	IN	NUMBER,
  X_invoice_amount		IN	NUMBER,
  X_user_id			IN	NUMBER,
  X_cust_trx_type_id		IN	NUMBER,
  X_batch_source_id		IN	NUMBER,
  X_receipt_method_id		IN	NUMBER,
  X_payment_schedule_id		IN	NUMBER,
  X_interest_date		IN	VARCHAR2,
  X_exit			OUT NOCOPY	VARCHAR2,
  x_int_revenue_ccid            IN      NUMBER,
  X_error_code                  OUT NOCOPY    NUMBER,
  X_error_msg                   OUT NOCOPY    VARCHAR2,
  X_token                       OUT NOCOPY    VARCHAR2
) IS
X_batch_id			NUMBER(15);
X_new_customer_trx_id		NUMBER(15);
X_set_of_books_id		NUMBER(15);
X_last_login			NUMBER(15);
X_salesrep_id			NUMBER(15);
X_bill_to_customer_id		NUMBER(15);
X_bill_to_site_use_id		NUMBER(15);
X_invoice_currency_code		VARCHAR2(15);
X_minimum_accountable_unit      NUMBER(15);
x_precision                     NUMBER(15);
X_trx_number			VARCHAR2(20);
X_term_id			NUMBER(15);
X_new_customer_trx_line_id	NUMBER(15);
X_interest_DM_date		DATE;
X_legal_entity_id NUMBER; -- Bug#7835709

BEGIN
  select to_date(X_interest_date,'DD-MM-YYYY')
  into X_interest_DM_date
  from dual;

  -----------------------------------------------------
  -- Bug 3378555. Retrieves information for the invoice
  --              currency code.
  -----------------------------------------------------
  SELECT invoice_currency_code, minimum_accountable_unit, precision
  INTO   X_invoice_currency_code, x_minimum_accountable_unit, x_precision
  FROM   ra_customer_trx, fnd_currencies_vl
  WHERE  customer_trx_id = X_original_customer_trx_id
  AND    invoice_currency_code = currency_code;

  jl_br_ar_generate_debit_memo.ins_ra_batches ( X_batch_source_id,
    X_invoice_amount,
    X_invoice_currency_code,
    X_user_id,
    X_batch_id );


  jl_br_ar_generate_debit_memo.ins_ra_customer_trx (
    X_original_customer_trx_id,
    X_new_customer_trx_id,
    X_set_of_books_id,
    X_last_login,
    X_salesrep_id,
    X_bill_to_customer_id,
    X_bill_to_site_use_id,
    X_invoice_currency_code,
    X_trx_number,
    X_term_id,
	X_legal_entity_id, -- Bug#7835709
    X_cust_trx_type_id,
    X_payment_schedule_id,
    X_user_id,
    X_batch_source_id,
    X_receipt_method_id,
    X_batch_id,
    X_interest_DM_date
  );

  jl_br_ar_generate_debit_memo.ins_ra_customer_trx_lines (
    X_new_customer_trx_id,
    X_invoice_amount,
    X_set_of_books_id,
    X_user_id,
    X_last_login,
    X_new_customer_trx_line_id
  );
  IF X_salesrep_id IS NOT NULL THEN
    jl_br_ar_generate_debit_memo.ins_ra_cust_trx_line_salesreps (
      X_new_customer_trx_id,
      X_new_customer_trx_line_id,
      X_salesrep_id,
      X_user_id,
      X_last_login,
      X_invoice_amount
    );
  END IF;

  jl_br_ar_generate_debit_memo.ins_ra_cust_trx_line_gl_dist (
    X_new_customer_trx_id,
    X_new_customer_trx_line_id,
    X_invoice_amount,
    X_set_of_books_id,
    X_user_id,
    X_batch_source_id,
    X_last_login,
    X_cust_trx_type_id,
    X_bill_to_site_use_id,   -- Bug#7718063
    X_salesrep_id,
    'REC',
    X_interest_DM_date,
    x_int_revenue_ccid,
    X_invoice_currency_code,
    X_minimum_accountable_unit,
    x_precision,
    x_error_code,
    x_error_msg,
    x_token
  );

  jl_br_ar_generate_debit_memo.ins_ra_cust_trx_line_gl_dist (
    X_new_customer_trx_id,
    X_new_customer_trx_line_id,
    X_invoice_amount,
    X_set_of_books_id,
    X_user_id,
    X_batch_source_id,
    X_last_login,
    X_cust_trx_type_id,
    X_bill_to_site_use_id,   -- Bug#7718063
    X_salesrep_id,
    'REV',
    X_interest_DM_date,
    x_int_revenue_ccid,
    X_invoice_currency_code,
    x_minimum_accountable_unit,
    x_precision,
    x_error_code,
    x_error_msg,
    x_token
  );

  jl_br_ar_generate_debit_memo.ins_ar_payment_schedules (
    X_user_id,
    X_last_login,
    X_invoice_amount,
    X_invoice_currency_code,
    X_cust_trx_type_id,
    X_bill_to_customer_id,
    X_bill_to_site_use_id,
    X_new_customer_trx_id,
    X_term_id,
    X_trx_number,
    X_interest_DM_date
  );

/* SLA KI - bug 4301543 */
  jl_br_ar_generate_debit_memo.sla_create_event (
    X_new_customer_trx_id
  );

  X_exit := '0';
END jl_br_interest_debit_memo;

Function validate_and_default_gl_date(x_receipt_date in date, --- receipt_date
                                      x_set_of_books_id      in  number,
                                      x_application_id       in  number,
				      x_default_gl_date      out nocopy date,
				      x_def_rule             out nocopy varchar2,
				      x_error_msg            out nocopy varchar2) return boolean is

l_default_gl_date  date;
l_cnt              number := 0;
l_application_id      number;
l_set_of_books_id     number;
l_org_id              number;
begin

   if (x_application_id is null) then
       l_application_id := 222;
   else
       l_application_id := x_application_id;
   end if;

   if (x_set_of_books_id is null) then
    --  l_set_of_books_id := to_number(fnd_profile.value('GL_SET_OF_BKS_ID'));
       l_org_id := mo_global.get_current_org_id;

       select set_of_books_id
         into l_set_of_books_id
         from ar_system_parameters
        where org_id = nvl(l_org_id,org_id);

   else
       l_set_of_books_id := x_set_of_books_id;
   end if;


    select  count(1)
      into  l_cnt
      from  gl_period_statuses
     where  application_id         = l_application_id
       and  set_of_books_id        = l_set_of_books_id
       and  adjustment_period_flag = 'N'
       and  trunc(x_receipt_date) between trunc(start_date) and trunc(end_date)
       and  closing_status in ('O', 'F');

    if (l_cnt > 0) then
           x_default_gl_date := x_receipt_date;
	   x_def_rule := 'Receipt date got defaulted. As it is in open period.' ;
	   x_error_msg := '';
	   return true;
    end if;

   -- Check whether Sysdate is in open period or not.

    select  count(1)
      into  l_cnt
      from  gl_period_statuses
     where  application_id         = l_application_id
       and  set_of_books_id        = l_set_of_books_id
       and  adjustment_period_flag = 'N'
       and  trunc(sysdate) between trunc(start_date) and trunc(end_date)
       and  closing_status in ('O', 'F');

    if (l_cnt > 0) then
           x_default_gl_date := sysdate;
	   x_def_rule := 'Sysdate defaulted';
	   x_error_msg := '';
	   return true;
    end if;

 -- open periods occur before the system date
 -- Get the last date of the open period most recent to the system date

    select  max(end_date)
      into  l_default_gl_date
      from  gl_period_statuses
     where  application_id         = l_application_id
       and  set_of_books_id        = l_set_of_books_id
       and  adjustment_period_flag = 'N'
       and  closing_status         = 'O'
       and  trunc(start_date) < trunc(sysdate);

    if( l_default_gl_date is not null) then
           x_default_gl_date := l_default_gl_date;
	   x_def_rule := 'Last date of most recent period open before system';
	   x_error_msg := '';
	   return true;
    end if;

-- open periods occur after the system date
-- Get the first date of open period after the system date

    select  min(start_date)
      into  l_default_gl_date
      from  gl_period_statuses
     where  application_id         = l_application_id
       and  set_of_books_id        = l_set_of_books_id
       and  adjustment_period_flag = 'N'
       and  closing_status         = 'O'
       and  trunc(start_date) >= trunc(sysdate);

    if( l_default_gl_date is not null) then
           x_default_gl_date := l_default_gl_date;
	   x_def_rule := 'Starting date of first open period after sysdate';
	   x_error_msg := '';
	   return true;
    end if;
  EXCEPTION
     WHEN OTHERS THEN
        x_error_msg := sqlerrm;
        return FALSE;

END validate_and_default_gl_date;


END jl_br_ar_generate_debit_memo;

/
