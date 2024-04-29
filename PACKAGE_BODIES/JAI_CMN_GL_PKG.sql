--------------------------------------------------------
--  DDL for Package Body JAI_CMN_GL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_GL_PKG" AS
/* $Header: jai_cmn_gl.plb 120.2 2006/05/26 11:38:28 lgopalsa ship $ */

/* --------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
08-Jun-2005  Version 116.3 jai_cmn_gl -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		as required for CASE COMPLAINCE.
*/
PROCEDURE get_account_number(p_chart_of_accounts_id IN NUMBER,
                                              p_ccid IN NUMBER, p_account_number OUT NOCOPY VARCHAR2) IS

CURSOR get_segments_used(coa_id NUMBER,c_flex_code fnd_id_flex_segments.id_flex_code%TYPE ) IS
   SELECT segment_num, application_column_name
   FROM   fnd_id_flex_segments
   WHERE  id_flex_num = coa_id
   AND    id_flex_code = c_flex_code
   ORDER BY segment_num;

v_account_number  VARCHAR2(1000) := NULL;
v_segment         VARCHAR2(25);
v_segment_cur     INTEGER;
v_execute         INTEGER;
v_rows        INTEGER;

BEGIN

    FOR i IN get_segments_used(p_chart_of_accounts_id,'GL#') LOOP       --L1
       v_segment_cur := DBMS_SQL.OPEN_CURSOR;
       DBMS_SQL.PARSE(v_segment_cur, 'SELECT '||i.application_column_name||' FROM gl_code_combinations'
                      ||' WHERE code_combination_id = :p_ccid', DBMS_SQL.NATIVE); -- Modified by Brathod, for 4407184 (Bind Var)
       DBMS_SQL.BIND_VARIABLE(v_segment_cur,':p_ccid',p_ccid); -- Added by Brathod, for 4407184 (Bind Var)
       DBMS_SQL.DEFINE_COLUMN(v_segment_cur, 1, v_segment, 1000);
       v_execute := DBMS_SQL.EXECUTE(v_segment_cur);
       v_rows := DBMS_SQL.FETCH_ROWS(v_segment_cur);
       DBMS_SQL.COLUMN_VALUE(v_segment_cur, 1, v_segment);

       IF v_account_number IS NOT NULL AND v_segment IS NOT NULL THEN
          v_account_number := v_account_number||'-'||v_segment;
       ELSIF v_account_number IS NULL AND v_segment IS NOT NULL THEN
          v_account_number := v_segment;
       END IF;
       DBMS_SQL.CLOSE_CURSOR(v_segment_cur);
    END LOOP;                               --L1
    p_account_number := v_account_number;
EXCEPTION
  WHEN OTHERS THEN
    IF dbms_sql.is_open(v_segment_cur) THEN
      dbms_sql.close_cursor(v_segment_cur);
    END IF;
END get_account_number ;

PROCEDURE create_gl_entry
          (p_organization_id number,
           p_currency_code varchar2,
           p_credit_amount number,
           p_debit_amount number,
           p_cc_id number,
           p_je_source_name varchar2,
           p_je_category_name varchar,
           p_created_by number,
           p_accounting_date date default null,
           p_currency_conversion_date date default null,
           p_currency_conversion_type varchar2 default null,
           p_currency_conversion_rate number default null,
           p_reference_10 varchar2 default null, --Added by Nagaraj.s for Bug2801751. Populated - Transaction Types || Document Number || Transaction Description
           p_reference_23 varchar2 default null, --Added by Nagaraj.s for Bug2801751. Populated - Object Name
           p_reference_24 varchar2 default null, --Added by Nagaraj.s for Bug2801751. Populated-  Unique Key Table Name
           p_reference_25 varchar2 default null, --Added by Nagaraj.s for Bug2801751. Populated-  Unique Key Column Name
           p_reference_26 varchar2 default null --Added by Nagaraj.s for Bug2801751.  Populated-  Unique Key
           ) IS
  v_last_update_login          number;
  v_creation_date              date;
  v_created_by                 number;
  v_last_update_date           date;
  v_last_updated_by            number;
  v_set_of_books_id            number;
  v_accounting_date            date;
  v_organization_code          org_organization_definitions.organization_code%type;
  v_reference_entry            varchar2(240); -- := 'India Localization Entry'; --Ramananda for File.Sql.35
  v_debug                      char(1); -- :='Y'; --Ramananda for File.Sql.35
  v_reference_10               gl_interface.reference10%type;
  v_reference_23               gl_interface.reference23%type;
  v_reference_24               gl_interface.reference24%type;
  v_reference_25               gl_interface.reference25%type;
  v_reference_26               gl_interface.reference26%type;
  lv_status                    gl_interface.status%TYPE ;--rchandan for bug#4428980

  cursor c_trunc_references is
  select
      substr(v_reference_10,1,240),
      substr(p_reference_23,1,240),
      substr(p_reference_24,1,240),
      substr(p_reference_25,1,240),
      substr(p_reference_26,1,240)
 from dual;

 cursor c_curr_code (cp_Set_of_books_id fnd_currencies.currency_code%type )is
 select currency_Code
 from   gl_Sets_of_books
 where  set_of_books_id = cp_Set_of_books_id;

 lv_currency_code fnd_currencies.currency_code%type;

 /* Bug 5243532. Added by Lakshmi Gopalsami
    Implemented caching logic.
  */
 l_func_curr_det jai_plsql_cache_pkg.func_curr_details;

/*------------------------------------------------------------------------------------------
 FILENAME: ja_in_gl_interface_p.sql

 CHANGE HISTORY:
S.No      Date          Author and Details
1        08/08/2003     By Nagaraj.s for Bug2801751 Version : 616.1
            Added 5 parameters to capture the reference values
            in gl_interface and also changed the Insert statement
            of gl_interface to include organization code,
            reference10,22,23,24,25,26,27 for Link to GL.
            As Parameters are added, this is an huge dependency.
            It is to be noted that the columns reference25 and 26 are swapped
            to maintain upward compatibility.

2        20/02/2004     Nagaraj.s for Bug3456481. Version : 618.1
            Accounting Date should not be punched with time stamp.
            This may lead to a scenario where, GL Import Program
            does not pick these records if the end date given as parameter
            is equal to the date_created in gl_interface.
            Hence trunc(v_accounting_date) is written to ensure that these
            records are picked up.

3.     11/01/2005
           ssumIth - bug# 4136981
           fetch the currency code based on the set of books id retreived and use it for inserting into the
           gl_interface table.


Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent           Files                                  Version     Author     Date         Remarks
Of File                              On Bug/Patchset    Dependent On
ja_in_gl_interface_p.sql
----------------------------------------------------------------------------------------------------------------------------------------------------
616.1                  2801751       IN60104D1+2801751   1. ja_in_gl_interface_p.sql
                                                         2. ja_in_receipt_acct_pkg.sql
                                                         3. ja_in_rma_receipt_p.sql
                                                         4. JAINRGAC.fmb
                                                         5. JAINRGCO.fmb
                                                         6. JAINRTVN.fmb
                                                         7. JAINPLAM.fmb
                                                         8. JAINOSPM.fmb
                                                         9. JAINIRGI.fmb
                                                        10. JAIN57F4.fmb
                            11. JAINIBOE.fmb


--------------------------------------------------------------------------------------------*/

BEGIN

  v_reference_entry            := 'India Localization Entry'; --Ramananda for File.Sql.35
  v_debug                      := jai_constants.yes; --Ramananda for File.Sql.35

  /* Bug 5243532. Added by Lakshmi Gopalsami
     Eliminated the usage of org_organization_definitions
     and implemented the same using caching logic
   */

   l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => p_organization_id);

   v_set_of_books_id   :=   l_func_curr_det.ledger_id;
   v_organization_code :=   l_func_curr_det.organization_code;
   -- End for bug 5243532


  v_reference_10 := p_reference_10 || ' for the Organization code ' || v_organization_code;

  /* start additions by ssumaith - bug#4136981
     coding here to get the currency code based on the set of books id fetched.
     Its better this is done at a central place rather than at all the satellite calling procedures / triggers
  */
  /* Bug 5243532. Added by Lakshmi Gopalsami
     Removed the cursor which is getting currency code for SOB
     as it is already fetched using caching logic.
   */
  lv_currency_code := l_func_curr_det.currency_code;

  /* end additions by ssumaith - bug#4136981*/

  --This is introduced to ensure that if the reference values goes beyond the specified width,
  --then the value would be restriced to an width of 240 so that exception would not occur.
  open c_trunc_references;
  fetch c_trunc_references
  into
  v_reference_10,
  v_reference_23,
  v_reference_24,
  v_reference_25,
  v_reference_26;
  close c_trunc_references;

  IF v_debug='Y' THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG, '**********Inside gl_interface_insert_new Procedure' );
   FND_FILE.PUT_LINE(FND_FILE.LOG, '9.0 The Value of v_reference_10 is ' || v_reference_10 );
   FND_FILE.PUT_LINE(FND_FILE.LOG, '9.1 The Value of v_reference_23 is ' || v_reference_23 );
   FND_FILE.PUT_LINE(FND_FILE.LOG, '9.2 The Value of v_reference_24 is ' || v_reference_24 );
   FND_FILE.PUT_LINE(FND_FILE.LOG, '9.3 The Value of v_reference_25 is ' || v_reference_25 );
   FND_FILE.PUT_LINE(FND_FILE.LOG, '9.4 The Value of v_reference_26 is ' || v_reference_26 );
   FND_FILE.PUT_LINE(FND_FILE.LOG, '9.4 The Value of v_set_of_books_id is ' || v_set_of_books_id );
   FND_FILE.PUT_LINE(FND_FILE.LOG, '9.4 The Value of v_organization_code is ' || v_organization_code );
   FND_FILE.PUT_LINE(FND_FILE.LOG, '9.4 The Value of p_organization_id is ' || p_organization_id);
   FND_FILE.PUT_LINE(FND_FILE.LOG, '9.4 The Value of p_credit_amount is ' || p_credit_amount);
   FND_FILE.PUT_LINE(FND_FILE.LOG, '9.4 The Value of p_debit_amount is ' || p_debit_amount);
  END IF;



  IF p_accounting_date is null
  THEN
    v_accounting_date := sysdate;
  ELSE
    v_accounting_date := p_accounting_date;
  END IF;

  v_accounting_date := trunc(v_accounting_date); --Trunc Added by Nagaraj.s for Bug3456481

  --This is added by Nagaraj.s for Bug2801751, so that in case ccid is null then an application error is raised.
  IF p_cc_id is NULL THEN
    RAISE_APPLICATION_ERROR(-20000,'Error raised in jai_cmn_gl_pkg.create_gl_entry. Code Combination Id Cannot be Populated as Null. Please Check.');
  END IF;


  IF NVL(p_credit_amount, 0) <> 0 OR
     NVL(p_debit_amount, 0) <> 0
  THEN

   --The Reference 25 and 26 have been swapped with values as Reference25 needs to be maintained
   --as the Unique key reference value,as many clients would have got their own customizations
   --and changing the column for unique key reference value may result in not supporting
   --the upward compatibility of the existing feature and this decision was done, after the code
   --was implemented and hence now reference25 is populated with p_reference_26 and reference26
   --is populated with p_reference_25.
    lv_status := 'NEW';----rchandan for bug#4428980
    INSERT into gl_interface
           (status,
           set_of_books_id,
           user_je_source_name,
           user_je_category_name,
           accounting_date,
           currency_code,
           date_created,
           created_by,           actual_flag,
           entered_cr,
           entered_dr,
           transaction_date,
           code_combination_id,
           currency_conversion_date,
           user_currency_conversion_type,
           currency_conversion_rate,
           --These References are added by Nagaraj.s for Bug2801751
           reference1,
           reference10,
           reference22,
           reference23,
           reference24,
           reference25,
           reference26,
           reference27
           )
    VALUES (lv_status,--rchandan for bug#4428980
           v_set_of_books_id,
           p_je_source_name,
           p_je_category_name,
           v_accounting_date,
           lv_currency_code , --p_currency_code,
           sysdate,
           p_created_by,
           'A',
           p_credit_amount,
           p_debit_amount,
           sysdate,
           p_cc_id,
           p_currency_conversion_date,
           p_currency_conversion_type,
           p_currency_conversion_rate,
           --These References are added by Nagaraj.s for Bug2801751
           v_organization_code,
           v_reference_10,
           v_reference_entry,
           v_reference_23,
           v_reference_24,
           v_reference_26,
           v_reference_25,
           to_char(p_organization_id)
           );
  END IF;
  IF v_debug='Y' THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG, '**********End of gl_interface_insert_new Procedure' );
  END IF;
  --Exception Introduced by Nagaraj.s for Bug2801751.
exception
 when others then
   IF v_debug='Y' THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error is raised in gl_interface procedure ' || sqlerrm );
  END IF;
  raise_application_error(-20106,'Error is raised in gl_interface procedure ' || sqlerrm);
END create_gl_entry;

Procedure create_gl_entry_for_opm(n_organization_id number,
                                    n_currency_code varchar2,
                                    n_credit_amount number,
                                    n_debit_amount number,
                                    n_cc_id number,
                                    n_je_source_name  in varchar2,
                                    n_je_category_name in varchar2,
                                    n_created_by  in number) is
    v_last_update_login          number;
    v_creation_date              date;
    v_created_by                 number;
    v_last_update_date           date;
    v_last_updated_by            number;
    v_set_of_books_id            number;
    lv_status                    gl_interface.status%TYPE ;--rchandan for bug#4428980

 Begin
   select set_of_books_id
   into v_set_of_books_id
   From org_organization_definitions
   where organization_id = n_organization_id;
   If NVL(n_credit_amount,0) <> 0 Or NVL(n_debit_amount,0) <> 0 Then
     lv_status := 'NEW';--rchandan for bug#4428980
     INSERT into gl_interface(status,
                         set_of_books_id,
                         user_je_source_name,
                         user_je_category_name,

                         accounting_date,
                         currency_code,
                         date_created,
                         created_by,
                         actual_flag,
                         entered_cr,
                         entered_dr,
                         transaction_date,
                         code_combination_id)
     VALUES
                         (lv_status,--rchandan for bug#4428980
                           v_set_of_books_id,
                           n_je_source_name,
                           n_je_category_name,
                            sysdate,
                            n_currency_code,
                            sysdate,
                            n_created_by,
                            'A',
                            n_credit_amount,
                            n_debit_amount,
                            sysdate,
                            n_cc_id);

   End If;
 End create_gl_entry_for_opm;


END jai_cmn_gl_pkg ;

/
