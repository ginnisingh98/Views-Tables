--------------------------------------------------------
--  DDL for Package Body JAI_RCV_RND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_RCV_RND_PKG" AS
/* $Header: jai_rcv_rnd.plb 120.10 2007/05/02 15:31:02 bduvarag ship $ */



  PROCEDURE do_rounding(
    p_err_buf               OUT NOCOPY VARCHAR2,
    p_ret_code              OUT NOCOPY NUMBER,
    P_ORGANIZATION_ID       IN  NUMBER,
    P_TRANSACTION_TYPE      IN  VARCHAR2, -- AT PRESENT THIS CAN CONTAIN ONLY ONE VALUE 'RECEIVE'. IN FUTURE THIS MAY CONTAIN MANY VALUES
    P_REGISTER_TYPE         IN  VARCHAR2,   -- CAN BE EITHER A OR C
    PV_EX_INVOICE_FROM_DATE  IN  VARCHAR2, /* rallamse bug#4336482 changed to VARCHAR2 from DATE */
    PV_EX_INVOICE_TO_DATE    IN  VARCHAR2  /* rallamse bug#4336482 changed to VARCHAR2 from DATE */
  ) IS

  /* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_rcv_rnd_pkg.do_rounding';

  /* rallamse bug#4336482 */
   P_EX_INVOICE_FROM_DATE  DATE ; --File.Sql.35 Cbabu  DEFAULT fnd_date.canonical_to_date(PV_EX_INVOICE_FROM_DATE);
   P_EX_INVOICE_TO_DATE    DATE ; --File.Sql.35 Cbabu  DEFAULT fnd_date.canonical_to_date(PV_EX_INVOICE_TO_DATE);
   /* End of Bug# 4336482 */

    --Added by Sanjikum for Bug #4049363
    TYPE amount_record IS RECORD( basic              NUMBER,
                                  additional         NUMBER,
				  additional_cvd     NUMBER,  /* 5228046  change by sacsethi  */
                                  other              NUMBER,
                                  excise_edu_cess    NUMBER,
                                  cvd_edu_cess       NUMBER,
                                  sh_excise_edu_cess NUMBER,    -- Date 16/04/2007 by
                                  sh_cvd_edu_cess    NUMBER,    -- sacsethi for Bug#5989740
                                  total              NUMBER);

    v_zero_record AMOUNT_RECORD;

    --Added the below by Sanjikum for Bug #4049363
    v_tot_amount              AMOUNT_RECORD;
    v_tot_rounded_amount      AMOUNT_RECORD;
    v_rounded_amount          AMOUNT_RECORD;
    v_rounded_amount_abs      NUMBER;
    v_rounded_amount_rg23     NUMBER;

    /*
    v_rounded_cr_amount       AMOUNT_RECORD;
    v_rounded_dr_amount       AMOUNT_RECORD;
    */
    v_rounded_cr_amount       NUMBER;
    v_rounded_dr_amount       NUMBER;

    v_rounded_cr_rg23_amount  AMOUNT_RECORD;
    v_rounded_dr_rg23_amount  AMOUNT_RECORD;
    v_rounded_cr_oth_amount   AMOUNT_RECORD;
    v_rounded_dr_oth_amount   AMOUNT_RECORD;

    v_rounding_entry_type VARCHAR2(2);

    v_commit_interval     NUMBER(5)     ; --File.Sql.35 Cbabu  := 50;
    v_rounding_precision  NUMBER(2)     ; --File.Sql.35 Cbabu  := 0;
    v_acct_type           VARCHAR2(20)  ; --File.Sql.35 Cbabu  := 'REGULAR';
    v_acct_nature         VARCHAR2(20)  ; --File.Sql.35 Cbabu  := 'CENVAT-ROUNDING';
    v_source_name         VARCHAR2(20)  ; --File.Sql.35 Cbabu  := 'Purchasing India';
    v_category_name       VARCHAR2(20)  ; --File.Sql.35 Cbabu  := 'Receiving India';
    v_statement_no        VARCHAR2(4)   ; --File.Sql.35 Cbabu  := '0';
    v_err_message         VARCHAR2(100) ; --File.Sql.35 Cbabu  := '';

    v_rounding_entries_made   NUMBER    ; --File.Sql.35 Cbabu  := 0;
    v_tot_errored_entries     NUMBER    ; --File.Sql.35 Cbabu  := 0;
    v_zero_round_found        NUMBER    ; --File.Sql.35 Cbabu  := 0;
    v_tot_processed_invoices  NUMBER    ; --File.Sql.35 Cbabu  := 0;
    v_no_of_invoices_posted   NUMBER    ; --File.Sql.35 Cbabu  := 0;
    v_save_point_set          BOOLEAN   ; --File.Sql.35 Cbabu  := FALSE;

    v_fin_year                NUMBER(4);

    v_vendor_id               NUMBER;
    v_vendor_site_id          NUMBER;
    v_rg23_balance            NUMBER;

    v_modvat_rm_account_id    NUMBER(15);
    v_modvat_cg_account_id    NUMBER(15);
    v_rg_rounding_account_id  NUMBER(15);

    v_rg_account_id           NUMBER(15);

    v_register_id_part_ii     NUMBER;
    v_rounding_id             NUMBER;

    v_created_by              NUMBER ; --File.Sql.35 Cbabu  := nvl(FND_GLOBAL.USER_ID, -1);
    v_last_update_login       NUMBER ; --File.Sql.35 Cbabu  := nvl(FND_GLOBAL.LOGIN_ID,- 1);
    v_today                   DATE ; --File.Sql.35 Cbabu  := trunc(SYSDATE);

    v_shipment_header_id      NUMBER;
    v_excise_invoice_no       JAI_CMN_RG_23AC_II_TRXS.excise_invoice_no%TYPE;
    v_excise_invoice_date     JAI_CMN_RG_23AC_II_TRXS.excise_invoice_date%TYPE;
    v_register_type           JAI_CMN_RG_23AC_II_TRXS.register_type%TYPE;
    v_line_type_a_cnt         NUMBER ; --File.Sql.35 Cbabu  := 0;
    v_line_type_c_cnt         NUMBER ; --File.Sql.35 Cbabu  := 0;
    v_tot_lines_cnt           NUMBER ; --File.Sql.35 Cbabu  := 0;

    -- Following values are used for the below variable
    -- 0 => RMIN Items, 1 => CGIN Items, 2 => Both RMIN and CGIN items
    v_rounding_type           NUMBER(1);

    v_enable_trace            FND_CONCURRENT_PROGRAMS.enable_trace%TYPE;
    v_sid                     v$session.sid%type;
    v_serial                  v$session.serial#%type;
    v_spid                    v$process.spid%type;
    v_name1                   v$database.name%type;

    CURSOR c_enable_trace(cp_conc_pname fnd_concurrent_programs.concurrent_program_name%type) IS
      SELECT enable_trace
      FROM fnd_concurrent_programs
      WHERE concurrent_program_name = cp_conc_pname ; --'JAINRGRND';

    CURSOR get_audsid IS
       SELECT a.sid, a.serial#, b.spid
       FROM v$session a, v$process b
       WHERE audsid = userenv('SESSIONID')
       AND a.paddr = b.addr;

      CURSOR get_dbname IS SELECT name FROM v$database;

    CURSOR c_vendor(p_shipment_header_id IN NUMBER) IS
      SELECT vendor_id, vendor_site_id, receipt_num
      FROM rcv_shipment_headers
      WHERE shipment_header_id = p_shipment_header_id;

    v_slno    NUMBER;
    v_balance NUMBER;

    CURSOR c_slno_balance(p_organization_id IN NUMBER, p_location_id IN NUMBER,
        p_fin_year IN NUMBER, p_register_type IN VARCHAR2) IS
      SELECT slno, closing_balance
      FROM JAI_CMN_RG_23AC_II_TRXS
      WHERE organization_id = p_organization_id
      AND location_id = p_location_id
      AND fin_year = p_fin_year
      AND register_type = p_register_type
      AND slno = (SELECT max(slno) slno
            FROM JAI_CMN_RG_23AC_II_TRXS
            WHERE organization_id = p_organization_id
            AND location_id = p_location_id
            AND fin_year = p_fin_year
            AND register_type = p_register_type);

    --Added by Sanjikum for Bug #4049363
    /*Bug 5141459 bduvarag start*/
/*    CURSOR c_rg23_cess_balance( p_organization_id IN  NUMBER,
                                p_location_id     IN  NUMBER,
                                p_register_type   IN  VARCHAR2,
                                p_tax_type        IN  VARCHAR2) is
    Select  nvl(a.closing_balance,0) closing_balance
    from    JAI_CMN_RG_OTHERS a
    Where   a.source_type = 1 --1 is for JAI_CMN_RG_23AC_II_TRXS
    AND     a.source_register = DECODE(p_register_type,'A',jai_constants.reg_rg23a_2, 'C', jai_constants.reg_rg23c_2) --'RG23A_P2','C','RG23C_P2')
    and     a.tax_type = p_tax_type
    AND     abs(a.source_register_id)   IN (Select  max(abs(c.source_register_id))
                                            from    JAI_CMN_RG_23AC_II_TRXS b,
                                                    JAI_CMN_RG_OTHERS c
                                            Where   c.source_type = 1 --1 is for JAI_CMN_RG_23AC_II_TRXS
                                            AND     c.source_register = DECODE(p_register_type,'A',jai_constants.reg_rg23a_2, 'C', jai_constants.reg_rg23c_2) --'RG23A_P2','C','RG23C_P2')
                                            AND     b.register_id = c.source_register_id
                                            AND     b.organization_id = p_organization_id
                                            and     b.location_id = p_location_id
                                            and     c.tax_type = p_tax_type
                                            and     b.register_type = P_register_type);*/
    /*Bug 5141459 bduvarag end*/

    CURSOR c_active_fin_year(p_organization_id IN NUMBER) IS
      SELECT max(fin_year)
      FROM JAI_CMN_FIN_YEARS
      WHERE organization_id = p_organization_id
      AND fin_active_flag = 'Y';

    CURSOR c_rg_rounding_account(p_organization_id IN NUMBER) IS
      SELECT rg_rounding_account_id
      FROM JAI_CMN_INVENTORY_ORGS
      WHERE organization_id = p_organization_id
      AND ( location_id IS NULL OR location_id = 0);

    CURSOR c_rg_modvat_account(p_organization_id IN NUMBER, p_location_id IN NUMBER) IS
      SELECT modvat_rm_account_id, modvat_cg_account_id
      FROM JAI_CMN_INVENTORY_ORGS
      WHERE organization_id = p_organization_id
      AND location_id = p_location_id;

    ln_receive_qty    NUMBER;
    CURSOR c_ja_in_receive_qty(cp_shipment_line_id IN NUMBER) IS
      SELECT qty_received
      FROM JAI_RCV_LINES
      WHERE shipment_line_id = cp_shipment_line_id;

    --Added the below 2 by Sanjikum for Bug #4049363
    ln_cenvat_amount  AMOUNT_RECORD;
    ln_receive_amount AMOUNT_RECORD;

    CURSOR c_receipt_tax_amount(cp_shipment_line_id IN NUMBER) IS  /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
      SELECT  --Added the 6 columns by Sanjikum for Bug #4049363
              sum(decode(b.tax_type, 'Excise', b.tax_amount * nvl(c.mod_cr_percentage, 0), 0) /100) excise_amt,
	      sum(decode(b.tax_type, 'Addl. Excise', b.tax_amount * nvl(c.mod_cr_percentage, 0), 'CVD', b.tax_amount * nvl(c.mod_cr_percentage, 0), 0) /100) additional_excise_amt,
              sum(decode(b.tax_type, jai_constants.tax_type_add_cvd, b.tax_amount * nvl(c.mod_cr_percentage, 0), 0) /100) additional_cvd , /*Changed by SACSETHI for the bug 5228046 -Additional CVD Enhancement*/
	      sum(decode(b.tax_type, 'Other Excise', b.tax_amount * nvl(c.mod_cr_percentage, 0), 0) /100) other_excise_amt,
              sum(decode(b.tax_type, jai_constants.tax_type_exc_edu_cess, b.tax_amount * nvl(c.mod_cr_percentage, 0), 0) /100) excise_edu_cess_amt,
              sum(decode(b.tax_type, jai_constants.tax_type_cvd_edu_cess, b.tax_amount * nvl(c.mod_cr_percentage, 0), 0) /100) cvd_edu_cess_amt ,
              sum(decode(b.tax_type, jai_constants.tax_type_sh_exc_edu_cess, b.tax_amount * nvl(c.mod_cr_percentage, 0), 0) /100) sh_excise_edu_cess_amt,  -- Date 16/04/2007 by
              sum(decode(b.tax_type, jai_constants.tax_type_sh_cvd_edu_cess, b.tax_amount * nvl(c.mod_cr_percentage, 0), 0) /100) sh_cvd_edu_cess_amt      -- sacsethi for Bug#5989740
      FROM JAI_RCV_LINE_TAXES b, JAI_CMN_TAXES_ALL c
      WHERE b.shipment_line_id = cp_shipment_line_id
      AND b.tax_id = c.tax_id
      AND b.tax_type IN (jai_constants.tax_type_excise, jai_constants.tax_type_exc_additional, jai_constants.tax_type_exc_other,
                         jai_constants.tax_type_cvd,  jai_constants.tax_type_exc_edu_cess, jai_constants.tax_type_cvd_edu_cess ,
			 jai_constants.tax_type_sh_exc_edu_cess, jai_constants.tax_type_sh_cvd_edu_cess  -- Date 16/04/2007 by sacsethi for Bug#5989740
			 )
      --AND b.tax_type IN ('Excise', 'Addl. Excise', 'Other Excise', 'CVD', jai_constants.tax_type_exc_edu_cess, jai_constants.tax_type_cvd_edu_cess)
      AND b.modvat_flag = 'Y';

    v_already_rounded_chk NUMBER;
    v_excise_inv_rnd_cnt  NUMBER;

    CURSOR c_already_rounded_chk(p_source_header_id IN NUMBER, p_excise_invoice_no IN VARCHAR2,
        p_excise_invoice_date IN DATE, p_transaction_type IN VARCHAR2) IS
      SELECT  max(rounding_id) rounding_id,
              --Added the below 6 by Sanjikum for Bug #4049363
              sum(basic_ed - rounded_basic_ed) rounded_basic_amt,
              sum(additional_ed - rounded_additional_ed) rounded_addl_amt,
              sum(additional_cvd - rounded_additional_cvd)  rounded_additional_cvd ,/*Changed by SACSETHI for the bug 5228046 -Additional CVD Enhancement*/
	      sum(other_ed - rounded_other_ed) rounded_other_amt,
              sum(excise_edu_cess - rounded_excise_edu_cess) rounded_excise_edu_cess,
              sum(cvd_edu_cess - rounded_cvd_edu_cess) rounded_cvd_edu_cess,
              sum(sh_excise_edu_cess - rounded_sh_excise_edu_cess) rounded_sh_excise_edu_cess,
              sum(sh_cvd_edu_cess - rounded_sh_cvd_edu_cess) rounded_sh_cvd_edu_cess,
              count(1)
      FROM    JAI_CMN_RG_ROUND_HDRS
      WHERE   source_header_id = p_source_header_id
      AND     excise_invoice_no = p_excise_invoice_no
      AND     excise_invoice_date = p_excise_invoice_date
      AND     src_transaction_type = p_transaction_type
      GROUP BY rounding_id, excise_invoice_no, excise_invoice_date;

    --Added the 2 variables below by Sanjikum for Bug #4049363
    v_temp_amount           AMOUNT_RECORD;
    v_1st_claim_rnd_amount  AMOUNT_RECORD;

    v_1st_claim_cgin_cnt  NUMBER;
    v_1st_claim_tot_cnt   NUMBER;

    CURSOR c_1st_claim_cgin_cnt(p_rounding_id IN NUMBER) IS
      SELECT count(1) total_cnt, sum( decode(item_class, 'CGIN', 1, 'CGEX', 1, 0) ) cgin_cnt
      FROM JAI_CMN_RG_ROUND_LINES
      WHERE rounding_id = p_rounding_id
      GROUP BY rounding_id;

    r_1st_claim_cgin_cnt  c_1st_claim_cgin_cnt%ROWTYPE;

    r_cgin_chk_for_2nd_claim  c_cgin_chk_for_2nd_claim%ROWTYPE;
    r_full_cgin_chk       c_full_cgin_chk%ROWTYPE;


    v_no_of_periods_updated NUMBER(15);
    v_period_balance_id     NUMBER(15);
    v_full_cgin_case        VARCHAR(1) ; --File.Sql.35 Cbabu  := 'N';
    v_proceed_for_2nd_claim VARCHAR(1) ; --File.Sql.35 Cbabu  := 'N';

    v_exc_inv_rnd_counter   NUMBER; --File.Sql.35 Cbabu  := 0;
    v_rnd_entries_to_be_passed  NUMBER;--File.Sql.35 Cbabu  := 0;
    v_receipt_num           rcv_shipment_headers.receipt_num%type;
    v_transaction_type      rcv_transactions.transaction_type%type;

   lv_ttype_correct 	rcv_transactions.transaction_type%type ;
  BEGIN

  /*--------------------------------------------------------------------------------------------------------------------------------
  Change History for Filename - ja_in_rg_rounding_p.sql
  S.No   dd/mm/yyyy  Author and Details
  ----------------------------------------------------------------------------------------------------------------------------------
  1      08/01/2004  Vijay Shankar for Bug# 3213826 Version : 619.1
                      Created the Package to handle Receipts related RG Rounding.
                      DO_ROUNDING Procedue is called from concurrent program JAINRGRND. This procedure posts excise amount Rounding differences to
                       - RG_PART_II, GL Accouting, Update RG balances
                       - Insert into JAI_CMN_RG_ROUND_HDRS, JAI_CMN_RG_ROUND_LINES tables
                       - Makes a call to jai_cmn_rg_period_bals_pkg.adjust_rounding to adjust this rounding amount in PERIOD Balance if
                         the min(ROUNDING_LINE_ID,register_id) of excise invoice is already consolidated in another period

                      Only for Excise Invoice having all CGIN Items is considered as a case where in two rounding entries were passed.
                      all the other scenarios only one rounding entry is passed

  2      31/08/2004  Vijay Shankar for Bug# 3496408 Version : 115.1
                      Modified the code to consider CORRECTions of RECEIVE to round the CENVAT amount. Related Selects and Updates
                      are modified to select JAI_CMN_RG_ROUND_LINES_S.nextval, the all the required data and punch Rounding_id in JAI_CMN_RG_23AC_II_TRXS in CORRECT RG records also

  3      21/01/2005  Sanjikum for Bug #4049363 Version 116.0 (115.2)
                      Modified the Code to consider the rounding for each tax type instead of total excise amount
                      Changed a lot of code. Can be searched with Bug#4049363

                      Dependency -
                      New columns are added in the Tables - JAI_CMN_RG_ROUND_HDRS, JAI_CMN_RG_ROUND_LINES

  4      31/08/2004  Vijay Shankar for Bug# 4103161 Version : 116.1
                      added a new procedure DO_RTV_ROUNDING to take care of RTV Rounding also.
                      And existing procedure do_rounding is modified to make a call to do_rtv_rounding

                    * Dependancy for later version of the object *

  5.  10/05/2005   Vijay Shankar for Bug#4346453. Version: 116.2
                     Code is modified due to the Impact of Receiving Transactions DFF Elimination

                    * High Dependancy for future Versions of this object *

  6.  19/04/2005  rallamse for Bug#4336482, Version 116.3
                  For SEED there is a change in concurrent "JAINRGRND" to use FND_STANDARD_DATE with STANDARD_DATE format
                  Procedure ja_in_rg_rounding_pkg.do_rounding signature modified by converting P_EX_INVOICE_TO_DATE, P_EX_INVOICE_TO_DATE
                 of DATE datatype to PV_EX_INVOICE_FROM_DATE, PV_EX_INVOICE_TO_DATE of varchar2 datatype.
                 The varchar2 values are converted to DATE fromat using fnd_date.canonical_to_date function.

 7. 08-Jun-2005   Version 116.2 jai_rcv_rnd -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		  as required for CASE COMPLAINCE.

 8. 13-Jun-2005   File Version: 116.3
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

 9. 06-Jul-2005   Ramananda for bug#4477004. File Version: 116.4
                  GL Sources and GL Categories got changed. Refer bug for the details

10. 31-Jan-2006   Bug 4930048. Added by Lakshmi Gopalsami version 120.2
 	          (1) Changed transaction_source_num to transaction_id in
		      update of JAI_CMN_RG_23AC_II_TRXS and subquery checking
		      for the existence in jai_rcv_transactions
 	          (2) Changed transaction_source_num to transaction_id in
		      update of JAI_CMN_RG_PLA_TRXS and subquery checking
		      for the existence in jai_rcv_transactions
	          (3) Changed transaction_source_num to transaction_id in
		      update of JAI_CMN_RG_23AC_II_TRXS and subquery checking
		      for the existence in rcv_transactions
                  (4) Added proper alias names and changed
		      transaction_source_num to transaction_id while
		      checking data in rcv_transactions in update to
		      JAI_CMN_RG_23AC_II_TRXS. This is done in 2 places.


  DEPENDENCY
  ----------
  IN60106 + 4146708 + 4103161 + 4346453


11.   20/11/2006   Aiyer for bug#5228046 , File Version 120.3
                    Issue :- Enhancement to support new tax type called ADDITIONAL_CVD
                    Fix   :- Added the code similar to that of additional_ed. The procedures do_rounding and do_rtv_rounding
                             have been modified.
                    Dependencies Due to this Bug:-
                    There are Datamodel and spec changes done for this bug. So this bug has both

12.   26-FEB-2007   SSAWANT , File version 120.7
                    Forward porting the change in 11.5 bug 5053992  to R12 bug no 5054176.

		    Issue:

                        The rounding entries for CESS are hitting wrong register.

                      Fix:

                        While inserting rounding for excise into JAI_CMN_RG_23AC_II_TRXS table the varibale v_register_type was
                        used for register_type column. But for jai_rg_others while inserting the corresponding CESS the
                        parameter p_register_type is used for source_register and so the discrepancy. Replaced p_register_type with
                        v_register_type while inserting into jai_rg_others.

13. 19-Apr-2007    Sacsethi for forward porting Bug#5989740, 11i bug#5907436, file version 120.8

14. 19-Apr-2007   bgowrava for forward porting bug#5674376. File Version 120.9
                    Issue : Rounding entries are not generated correctly.
                      Fix : Whenever we fetch parent register id for a rounding entry we use excise_invoice_no and
                            excise_invoice_date. But these two can be same for different vendors. So added a check to include vendor_id
                            and vendor_site_id wherever applicable. The cursor to fetch parent register id is also modified to include
                            shipment header id.

                            The vendor_id and vendor_site_id for rounding_entries are populated from rcv_shipment_headers
                            This is now changed to be populated from the parent entry in ja_in_rg23_part_ii.

                            These changes were made in bug#5478107 at PRE Addl. CVD enh level. The same are
                            forward ported to the latest code line.

 15. 19-Apr-2007   bgowrava for forward porting bug#5674376. File Version 120.9
                    Issue : Rounding entries are not generated correctly.
                      Fix : The concurrent was erroring out as the group by clause did not have vendor_id and vendor_site_id. These
                      were included in the select clause as part of previous fix. Now these are added in group by clause also.
16.  02/05/2007	  bduvarag for the Bug#5141459, file version 120.10
		  Forward porting the changes done in 11i bug#4548378


  --------------------------------------------------------------------------------------------------------------------------------*/

   P_EX_INVOICE_FROM_DATE  := fnd_date.canonical_to_date(PV_EX_INVOICE_FROM_DATE);
   P_EX_INVOICE_TO_DATE    := fnd_date.canonical_to_date(PV_EX_INVOICE_TO_DATE);
    v_commit_interval     := 50;
    v_rounding_precision  := 0;
    v_acct_type           := 'REGULAR';
    v_acct_nature         := 'CENVAT-ROUNDING';
    v_source_name         := 'Purchasing India';
    v_category_name       := 'Receiving India';
    v_statement_no        := '0';
    v_err_message         := '';
    v_rounding_entries_made   := 0;
    v_tot_errored_entries     := 0;
    v_zero_round_found        := 0;
    v_tot_processed_invoices  := 0;
    v_no_of_invoices_posted   := 0;
    v_save_point_set          := FALSE;
    v_created_by              := nvl(FND_GLOBAL.USER_ID, -1);
    v_last_update_login       := nvl(FND_GLOBAL.LOGIN_ID,- 1);
    v_today                   := trunc(SYSDATE);
    v_line_type_a_cnt         := 0;
    v_line_type_c_cnt         := 0;
    v_tot_lines_cnt           := 0;
    v_full_cgin_case        := 'N';
    v_proceed_for_2nd_claim := 'N';
    v_exc_inv_rnd_counter   := 0;
    v_rnd_entries_to_be_passed  := 0;


  OPEN c_enable_trace('JAINRGRND'); /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
  FETCH c_enable_trace INTO v_enable_trace;
  CLOSE c_enable_trace;

  FND_FILE.PUT_LINE( FND_FILE.log, 'File Version: 115.2 and LastUpdateDate:08/01/2004, Inputs parameters: p_organization_id->'
    ||p_organization_id
    ||', p_ex_invoice_from_date->'||p_ex_invoice_from_date
    ||', p_ex_invoice_to_date->'||p_ex_invoice_to_date
    ||', v_enable_trace->'||v_enable_trace
  );

  IF v_enable_trace = 'Y' THEN

    OPEN get_audsid;
    FETCH get_audsid INTO v_sid, v_serial, v_spid;
    CLOSE get_audsid;

    OPEN get_dbname;
    FETCH get_dbname INTO v_name1;
    CLOSE get_dbname;

    FND_FILE.PUT_LINE( FND_FILE.log, 'TraceFile Name = '||lower(v_name1)||'_ora_'||v_spid||'.trc');

    EXECUTE IMMEDIATE 'ALTER SESSION SET EVENTS ''10046 trace name context forever, level 4''';

  END IF;

  /* Vijay Shankar for Bug#4103161 */
  if p_transaction_type IN ('ALL', 'RETURN TO VENDOR') then
    v_transaction_type := 'RETURN TO VENDOR';
    do_rtv_rounding(
      p_organization_id       => p_organization_id,
      p_transaction_type      => v_transaction_type,
      p_register_type         => p_register_type,
      p_ex_invoice_from_date  => p_ex_invoice_from_date,
      p_ex_invoice_to_date    => p_ex_invoice_to_date
    );


    /* as rounding is complete we can return from execution after commit*/
    if p_transaction_type = 'RETURN TO VENDOR' then
      goto do_commit;
    else
      /* we need to do the rounding of RECEIVE transactions also */
      null;
    end if;

  end if;

  v_statement_no := '0.1';
  if p_transaction_type = 'ALL' then
    v_transaction_type := 'RECEIVE';
  else
    v_transaction_type := p_transaction_type;
  end if;

  OPEN c_rg_rounding_account(p_organization_id);
  FETCH c_rg_rounding_account INTO v_rg_rounding_account_id;
  CLOSE c_rg_rounding_account;

  v_statement_no := '0.2';

  IF v_rg_rounding_account_id IS NULL THEN
    FND_FILE.PUT_LINE( FND_FILE.log, 'ERROR: Rounding Account is not specified at Organization Level');
    RAISE_APPLICATION_ERROR( -20099, 'Rounding Account is not specified at Organization Level');
  END IF;

  v_statement_no := '0.3';

  OPEN c_active_fin_year(p_organization_id);
  FETCH c_active_fin_year INTO v_fin_year;
  CLOSE c_active_fin_year;

  --Added by Sanjikum for Bug #4049363
  v_zero_record.basic := 0;
  v_zero_record.additional := 0;
  v_zero_record.additional_cvd := 0; /*added by SACSETHI for the bug 5228046 -Additional CVD Enhancement*/
  v_zero_record.other := 0;
  v_zero_record.excise_edu_cess := 0;
  v_zero_record.cvd_edu_cess := 0;
  v_zero_record.total := 0;

-- Date 16/04/2007 by sacsethi for Bug#5989740

  v_zero_record.sh_excise_edu_cess := 0;
  v_zero_record.sh_cvd_edu_cess := 0;


  v_tot_amount := v_zero_record;

  -- PART II A, C rounding entries can be posted into one of the Registers A or C
  FOR r IN (
        select b.shipment_header_id, a.excise_invoice_no, a.excise_invoice_date, b.transaction_type,
        a.vendor_id,a.vendor_site_id,/*bgowrava for forward porting bug#5674376*/
          min(a.location_id)        location_id,
          sum(a.cr_basic_ed)        cr_basic_ed,
          sum(a.cr_additional_ed)   cr_additional_ed,
          sum(a.cr_additional_cvd)  cr_additional_cvd,/*5228046 Additional cvd Enhancement*/
	  sum(a.cr_other_ed)	    cr_other_ed,
          sum(a.dr_basic_ed)        dr_basic_ed,
          sum(a.dr_additional_ed)   dr_additional_ed,
          sum(a.dr_additional_cvd)  dr_additional_cvd, /*Column added by SACSETHI for the bug 5228046 - Additional CVD Enhancement  */
          sum(a.dr_other_ed)        dr_other_ed
        from JAI_CMN_RG_23AC_II_TRXS a, rcv_transactions b
        where a.RECEIPT_REF = b.transaction_id
        AND a.organization_id = p_organization_id
        AND (
            (p_ex_invoice_from_date IS NULL AND p_ex_invoice_to_date IS NULL)
          OR  (p_ex_invoice_from_date IS NOT NULL AND p_ex_invoice_to_date IS NULL
              AND a.excise_invoice_date >= p_ex_invoice_from_date)
          OR  (p_ex_invoice_from_date IS NULL AND p_ex_invoice_to_date IS NOT NULL
              AND a.excise_invoice_date <= p_ex_invoice_to_date)
          OR  (p_ex_invoice_from_date IS NOT NULL AND p_ex_invoice_to_date IS NOT NULL
              AND a.excise_invoice_date BETWEEN p_ex_invoice_from_date AND p_ex_invoice_to_date)
        )
        AND a.rounding_id IS NULL
        AND a.TRANSACTION_SOURCE_NUM = 18
        AND b.transaction_type = v_transaction_type
        GROUP BY b.shipment_header_id, b.transaction_type, a.excise_invoice_no, a.excise_invoice_date,
        a.vendor_id,a.vendor_site_id /*bgowrava for forward porting bug#5674376*/
       )
  LOOP

    v_exc_inv_rnd_counter       := 0;
    v_rnd_entries_to_be_passed  := 1;

    LOOP

     EXIT WHEN v_exc_inv_rnd_counter >= v_rnd_entries_to_be_passed;

     BEGIN

      v_statement_no := '1';
      v_shipment_header_id      := r.shipment_header_id;
      v_excise_invoice_no       := r.excise_invoice_no;
      v_excise_invoice_date     := r.excise_invoice_date;
      r_full_cgin_chk           := null;

      v_excise_inv_rnd_cnt      := 0;
      --Added below 1 statements by Sanjikum for Bug #4049363
      v_temp_amount := v_zero_record;

      v_already_rounded_chk     := null;
      r_1st_claim_cgin_cnt      := null;
      r_cgin_chk_for_2nd_claim  := null;
      v_period_balance_id       := null;
      v_no_of_periods_updated   := null;
      v_proceed_for_2nd_claim   := 'N';
      v_full_cgin_case          := 'N';

      --Added below 1 statements by Sanjikum for Bug #4049363
      v_1st_claim_rnd_amount := v_zero_record;

      v_statement_no := '1.1';
      v_already_rounded_chk := NULL;
      OPEN c_already_rounded_chk(v_shipment_header_id, v_excise_invoice_no, v_excise_invoice_date, r.transaction_type);
      FETCH c_already_rounded_chk INTO
            v_already_rounded_chk,
            --Added the below 6 variables by Sanjikum for Bug #4049363
            v_1st_claim_rnd_amount.basic,
            v_1st_claim_rnd_amount.additional,
            v_1st_claim_rnd_amount.additional_cvd,/*Added by SACSETHI for the bug 5228046 -Additional CVD Enhancement*/
            v_1st_claim_rnd_amount.other,
            v_1st_claim_rnd_amount.excise_edu_cess,
            v_1st_claim_rnd_amount.cvd_edu_cess,
	    v_1st_claim_rnd_amount.sh_excise_edu_cess,  -- Date 16/04/2007
            v_1st_claim_rnd_amount.sh_cvd_edu_cess,     -- by sacsethi for Bug#5989740
            v_excise_inv_rnd_cnt;
      CLOSE c_already_rounded_chk;

      -- Chk for full CGIN case
      OPEN c_full_cgin_chk(v_shipment_header_id, v_excise_invoice_no, v_excise_invoice_date,r.vendor_id,r.vendor_site_id);/*bgowrava for forward porting bug#5674376*/
      FETCH c_full_cgin_chk INTO r_full_cgin_chk;
      CLOSE c_full_cgin_chk;

      IF r_full_cgin_chk.total_cnt = r_full_cgin_chk.cgin_cnt THEN
        v_full_cgin_case := 'Y';

        OPEN c_cgin_chk_for_2nd_claim(v_shipment_header_id, v_excise_invoice_no, v_excise_invoice_date,r.vendor_id,r.vendor_site_id);/*bgowrava for forward porting bug#5674376*/
        FETCH c_cgin_chk_for_2nd_claim INTO r_cgin_chk_for_2nd_claim;
        CLOSE c_cgin_chk_for_2nd_claim;

      END IF;

      IF v_full_cgin_case = 'Y' AND r_cgin_chk_for_2nd_claim.cent_percent_cnt > 0
        AND v_excise_inv_rnd_cnt=0
      THEN
        v_rnd_entries_to_be_passed := 2;
      END IF;

      FND_FILE.PUT_LINE( FND_FILE.log, 'v_already_rounded_chk->'||v_already_rounded_chk
          ||', v_1st_claim_rnd_amt->'||r_cgin_chk_for_2nd_claim.cent_percent_cnt
      );

      -- If the following if is satisfied, then cgin chk for 2nd claim has to be done
      IF v_already_rounded_chk IS NOT NULL THEN

        -- if the following condition is satisfied, then it means Excise Invoice has All CGIN items
        IF v_full_cgin_case = 'Y' THEN

          -- 2nd Claim is done and 2nd rounding has also happened so no more rounding
          IF v_excise_inv_rnd_cnt = 2 THEN
            v_proceed_for_2nd_claim := 'N';

          -- proceed for 2nd rounding entry as 1st rounding happened and 2nd claim is done
          ELSIF v_excise_inv_rnd_cnt = 1  AND r_cgin_chk_for_2nd_claim.cent_percent_cnt > 0 THEN
            v_proceed_for_2nd_claim := 'Y';

          -- 1st claim is done but 2nd claim was not done and 1st rounding has already happened so new rounding entry
          ELSE
            v_proceed_for_2nd_claim := 'N';

          END IF;

        -- Other Than Full CGIN Case
        ELSE
          v_proceed_for_2nd_claim := 'N';

        END IF;

        v_statement_no := '1.3';
        SAVEPOINT previous_savepoint;
        v_save_point_set := TRUE;

        IF v_proceed_for_2nd_claim = 'N' THEN
          -- punching the rounding id found above in these transactions, so that they will not be considered again
          v_statement_no := '1.2';
          UPDATE JAI_CMN_RG_23AC_II_TRXS jcrg23ac
          SET jcrg23ac.rounding_id = v_already_rounded_chk
          WHERE jcrg23ac.excise_invoice_no = v_excise_invoice_no
          AND jcrg23ac.excise_invoice_date = v_excise_invoice_date
          AND nvl(vendor_id,-999) = nvl(r.vendor_id,-999)/*bgowrava for forward porting bug#5674376*/
          AND nvl(vendor_site_id,-999) = nvl(r.vendor_site_id,-999)/*bgowrava for forward porting bug#5674376*/
          AND jcrg23ac.organization_id = p_organization_id
          AND jcrg23ac.rounding_id IS NULL
          AND jcrg23ac.transaction_source_num = 18
          AND exists (select 1 from rcv_transactions rt
	    /*  Bug 4930048. Added by Lakshmi Gopalsami
	        Changed transaction_source_num to transaction_id
	    */
            where rt.transaction_id = jcrg23ac.receipt_ref
            and rt.transaction_type = v_transaction_type);

          FND_FILE.PUT_LINE( FND_FILE.log, '+++++ Ex. Invoice Already rounded +++++');
          GOTO next_exc_inv;
        END IF;

      -- Rounding was not yet done for this excise invoice
      ELSE

        IF v_full_cgin_case = 'Y' THEN
          NULL;
        END IF;

      END IF;

      FND_FILE.PUT_LINE( FND_FILE.log, '2nd_claim.cent ->'||r_cgin_chk_for_2nd_claim.cent_percent_cnt
          ||', fifty->'||r_cgin_chk_for_2nd_claim.fifty_percent_cnt
          ||', zero->'||r_cgin_chk_for_2nd_claim.zero_percent_cnt
          ||', v_proceed_for_2nd_claim->'||v_proceed_for_2nd_claim
      );

      -- This indicates whether the processing has to ROLLBACK or not
      -- incase error occured due to code between v_save_point_set = FALSE and v_save_point_set = TRUE
      v_tot_processed_invoices := v_tot_processed_invoices + 1;

      v_statement_no := '1.4';
      SELECT JAI_CMN_RG_ROUND_HDRS_S.nextval INTO v_rounding_id FROM dual;

      v_line_type_a_cnt := 0;
      v_line_type_c_cnt := 0;
      v_tot_lines_cnt := 0;
      --Added below 1 statements by Sanjikum for Bug #4049363
      v_tot_amount := v_zero_record;

      v_statement_no := '1.4';
      -- this is to get RECEIVE type of transactions
      FOR line IN ( SELECT a.shipment_line_id, a.transaction_id, d.item_class
            FROM JAI_RCV_LINES a,JAI_RCV_CENVAT_CLAIMS b,RCV_TRANSACTIONS c, JAI_INV_ITM_SETUPS d
            WHERE a.organization_id = d.organization_id
            AND b.transaction_id    = a.transaction_id /*bgowrava for forward porting bug#5674376*/
            AND a.inventory_item_id = d.inventory_item_id
            AND a.shipment_header_id = v_shipment_header_id
            AND a.excise_invoice_no = v_excise_invoice_no
            AND a.excise_invoice_date = v_excise_invoice_date
            AND ( (nvl(b.vendor_id,-999)    = nvl(r.vendor_id,-999)
								AND nvl(b.vendor_site_id,-999) = nvl(r.vendor_site_id,-999)
								AND b.vendor_changed_flag      = 'Y' )
								OR
								(nvl(c.vendor_id,-999)      = nvl(r.vendor_id,-999)
								AND nvl(c.vendor_site_id,-999) = nvl(r.vendor_site_id,-999)
								AND b.vendor_changed_flag      = 'N' )
									) /*bgowrava for forward porting bug#5674376*/
            GROUP BY a.shipment_line_id, a.transaction_id, d.item_class
          )
      LOOP
        --Added below 1 statements by Sanjikum for Bug #4049363
        ln_receive_amount := v_zero_record;

        ln_receive_qty := 0;

        OPEN c_ja_in_receive_qty(line.shipment_line_id);
        FETCH c_ja_in_receive_qty INTO ln_receive_qty;
        CLOSE c_ja_in_receive_qty;

        OPEN c_receipt_tax_amount(line.shipment_line_id);
        --Added the 6 columns by Sanjikum for Bug #4049363
        FETCH c_receipt_tax_amount INTO
                                        ln_receive_amount.basic,
                                        ln_receive_amount.additional,
                                        ln_receive_amount.additional_cvd, /*Added by SACSETHI for the bug 5228046 -Additional CVD Enhancement*/
                                        ln_receive_amount.other,
                                        ln_receive_amount.excise_edu_cess,
                                        ln_receive_amount.cvd_edu_cess ,
                                        ln_receive_amount.sh_excise_edu_cess,
                                        ln_receive_amount.sh_cvd_edu_cess;

        CLOSE c_receipt_tax_amount;

        FND_FILE.PUT_LINE( FND_FILE.log, 'TrxId:'||line.transaction_id ||', RecvQty->'||ln_receive_qty);

        -- this is to loop through all the RECEIVE and related CORRECT transactions
	lv_ttype_correct := 'CORRECT' ; /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
        FOR trx IN (select transaction_id, quantity
                    from rcv_transactions
                    where shipment_line_id = line.shipment_line_id
                    and (
                          (transaction_type = lv_ttype_correct and parent_transaction_id = line.transaction_id)
                          OR transaction_id = line.transaction_id
                        )
                   )
        LOOP

          --Added below the 7 statements by Sanjikum for Bug #4049363
          ln_cenvat_amount.basic            := ln_receive_amount.basic * trx.quantity/ln_receive_qty;
          ln_cenvat_amount.additional       := ln_receive_amount.additional * trx.quantity/ln_receive_qty;
          ln_cenvat_amount.other            := ln_receive_amount.other * trx.quantity/ln_receive_qty;
          ln_cenvat_amount.excise_edu_cess  := ln_receive_amount.excise_edu_cess * trx.quantity/ln_receive_qty;
          ln_cenvat_amount.cvd_edu_cess     := ln_receive_amount.cvd_edu_cess * trx.quantity/ln_receive_qty;
          ln_cenvat_amount.sh_excise_edu_cess  := ln_receive_amount.sh_excise_edu_cess * trx.quantity/ln_receive_qty;  -- Date 16/04/2007 by sacsethi for Bug#5989740
          ln_cenvat_amount.sh_cvd_edu_cess     := ln_receive_amount.cvd_edu_cess * trx.quantity/ln_receive_qty; -- Date 16/04/2007 by sacsethi for Bug#5989740
	  ln_cenvat_amount.total            := NVL(ln_cenvat_amount.basic,0) + NVL(ln_cenvat_amount.additional,0) + NVL(ln_cenvat_amount.other,0) + NVL(ln_cenvat_amount.excise_edu_cess,0) + NVL(ln_cenvat_amount.cvd_edu_cess,0);
          v_statement_no := '1.5';

            -- populate item class
          INSERT INTO JAI_CMN_RG_ROUND_LINES (ROUNDING_LINE_ID,
            ROUNDING_ID, SRC_LINE_ID, SRC_TRANSACTION_ID,
            EXCISE_AMT,
            BASIC_ED, ADDITIONAL_ED, OTHER_ED,  --Added by Sanjikum for Bug #4049363
            EXCISE_EDU_CESS, CVD_EDU_CESS,--Added by Sanjikum for Bug #4049363
            sh_excise_edu_cess ,  -- Date 16/04/2007 by sacsethi for Bug#5989740
	    sh_cvd_edu_cess ,
            ITEM_CLASS, CREATION_DATE, CREATED_BY,
	    program_application_id, program_id, program_login_id, request_id
          )
	  VALUES ( JAI_CMN_RG_ROUND_LINES_S.nextval,
                   v_rounding_id,
		   line.shipment_line_id,
		   trx.transaction_id,
                   ln_cenvat_amount.total, --Added by Sanjikum for Bug #4049363
                   ln_cenvat_amount.basic,
		   ln_cenvat_amount.additional,
		   ln_cenvat_amount.other, --Columns Added by Sanjikum for Bug #4049363
                   ln_cenvat_amount.excise_edu_cess,
		   ln_cenvat_amount.cvd_edu_cess, -- Date 16/04/2007 by sacsethi for Bug#5989740
                   ln_cenvat_amount.sh_excise_edu_cess,
		   ln_cenvat_amount.sh_cvd_edu_cess, --Columns Added by Sanjikum for Bug #4049363
                   line.item_class, SYSDATE, v_created_by,
	           fnd_profile.value('PROG_APPL_ID'), fnd_profile.value('CONC_PROGRAM_ID'), fnd_profile.value('CONC_LOGIN_ID'), fnd_profile.value('CONC_REQUEST_ID')
          );

          --Added the 6 statements by Sanjikum for Bug #4049363
          v_tot_amount.basic            := v_tot_amount.basic             + ln_cenvat_amount.basic;
          v_tot_amount.additional       := v_tot_amount.additional        + ln_cenvat_amount.additional;
          v_tot_amount.other            := v_tot_amount.other             + ln_cenvat_amount.other;
          v_tot_amount.excise_edu_cess  := v_tot_amount.excise_edu_cess   + ln_cenvat_amount.excise_edu_cess;
          v_tot_amount.cvd_edu_cess     := v_tot_amount.cvd_edu_cess      + ln_cenvat_amount.cvd_edu_cess;
-- Date 16/04/2007 by sacsethi for Bug#5989740
-- start 5989740
	  v_tot_amount.sh_excise_edu_cess  := v_tot_amount.sh_excise_edu_cess   + ln_cenvat_amount.sh_excise_edu_cess;
          v_tot_amount.sh_cvd_edu_cess     := v_tot_amount.sh_cvd_edu_cess      + ln_cenvat_amount.sh_cvd_edu_cess;
-- end 5989740
-----------------------------------------------
	  v_tot_amount.total            := NVL(v_tot_amount.basic,0) +
	                                   NVL(v_tot_amount.additional,0) +
					   NVL(v_tot_amount.other,0) +
					   NVL(v_tot_amount.excise_edu_cess,0) +
					   NVL(v_tot_amount.cvd_edu_cess,0) +
					   NVL(v_tot_amount.sh_excise_edu_cess,0) +  -- Date 16/04/2007 by sacsethi for Bug#5989740
					   NVL(v_tot_amount.sh_cvd_edu_cess,0);

        END LOOP;

        IF line.item_class IN ('RMIN', 'RMEX') THEN
          v_line_type_a_cnt := v_line_type_a_cnt + 1;
        ELSIF line.item_class IN ('CGIN', 'CGEX') THEN
          v_line_type_c_cnt := v_line_type_c_cnt + 1;
        END IF;
        v_tot_lines_cnt := v_tot_lines_cnt + 1;

      END LOOP;

      v_statement_no := '1.6';
      IF v_line_type_c_cnt = v_tot_lines_cnt THEN
        v_register_type := 'C';
        v_rounding_type := 1;
      ELSIF v_line_type_c_cnt = 0 THEN
        v_register_type := 'A';
        v_rounding_type := 0;
      ELSE
        v_register_type := p_register_type;
        v_rounding_type := 2;
      END IF;

      FND_FILE.PUT_LINE( FND_FILE.log, 'Started Processing shipment_header_id->'||v_shipment_header_id
          ||', excise_invoice_no->'||v_excise_invoice_no
          ||', excise_invoice_date->'||v_excise_invoice_date
      );

      -- find the rounding amount for the receipt
      -- CGIN case
      IF v_line_type_c_cnt = v_tot_lines_cnt THEN

        --7 statements added by Sanjikum for Bug #4049363
        v_tot_amount.basic            := v_tot_amount.basic/2;
        v_tot_amount.additional       := v_tot_amount.additional/2;
        v_tot_amount.additional_cvd   := v_tot_amount.additional_cvd/2;/*Added by SACSETHI for the bug 5228046 -Additional CVD Enhancement*/
        v_tot_amount.other            := v_tot_amount.other/2;
        v_tot_amount.excise_edu_cess  := v_tot_amount.excise_edu_cess/2;
        v_tot_amount.cvd_edu_cess     := v_tot_amount.cvd_edu_cess/2;
-- Date 16/04/2007 by sacsethi for Bug#5989740
-- start 5989740
	v_tot_amount.sh_excise_edu_cess  := v_tot_amount.sh_excise_edu_cess/2;
        v_tot_amount.sh_cvd_edu_cess     := v_tot_amount.sh_cvd_edu_cess/2;
-- end 5989740
        v_tot_amount.total            := NVL(v_tot_amount.basic,0) +
	                                 NVL(v_tot_amount.additional,0) +
                                         NVL(v_tot_amount.additional_cvd,0) + /*Added by SACSETHI for the bug 5228046 -Additional CVD Enhancement*/
					 NVL(v_tot_amount.other,0) +
					 NVL(v_tot_amount.excise_edu_cess,0) +
					 NVL(v_tot_amount.cvd_edu_cess,0) +
                                         NVL(v_tot_amount.sh_excise_edu_cess,0) +  -- Date 16/04/2007 by sacsethi for Bug#5989740
					 NVL(v_tot_amount.sh_cvd_edu_cess,0);


        UPDATE  JAI_CMN_RG_ROUND_LINES
        SET     --7 columns added by Sanjikum for Bug #4049363
                excise_amt        = NVL(basic_ed/2,0) +
		                    NVL(additional_ed/2,0) +
				    NVL(additional_cvd/2,0) + /*Added by SACSETHI for the bug 5228046 -Additional CVD Enhancement*/
				    NVL(other_ed/2,0) +
				    NVL(excise_edu_cess/2,0) +
				    NVL(cvd_edu_cess/2,0),
                basic_ed          = basic_ed/2,
                additional_ed     = additional_ed/2,
                additional_cvd    = additional_cvd/2,/*Added by SACSETHI for the bug 5228046 -Additional CVD Enhancement*/
                other_ed          = other_ed/2,
                excise_edu_cess   = excise_edu_cess/2,
                cvd_edu_cess      = cvd_edu_cess/2 ,
                sh_excise_edu_cess   = sh_excise_edu_cess/2,
                sh_cvd_edu_cess      = sh_cvd_edu_cess/2
        WHERE   rounding_id = v_rounding_id;

        -- 1st Claim
        IF v_proceed_for_2nd_claim = 'N' THEN
          v_statement_no := '2';

          --6 statements added by Sanjikum for Bug #4049363
          v_tot_rounded_amount.basic            := FLOOR(v_tot_amount.basic); -- i.e floor(25.7) = 25
          v_tot_rounded_amount.additional       := FLOOR(v_tot_amount.additional);
          v_tot_rounded_amount.additional_cvd   := FLOOR(v_tot_amount.additional_cvd); /*Added by SACSETHI for the bug 5228046 -Additional CVD Enhancement*/
          v_tot_rounded_amount.other            := FLOOR(v_tot_amount.other);
          v_tot_rounded_amount.excise_edu_cess  := FLOOR(v_tot_amount.excise_edu_cess);
          v_tot_rounded_amount.cvd_edu_cess     := FLOOR(v_tot_amount.cvd_edu_cess);

-- Date 16/04/2007 by sacsethi for Bug#5989740
	  v_tot_rounded_amount.sh_excise_edu_cess  := FLOOR(v_tot_amount.sh_excise_edu_cess);
   	  v_tot_rounded_amount.sh_cvd_edu_cess     := FLOOR(v_tot_amount.sh_cvd_edu_cess);
-- end 5989740


          --6 statements added by Sanjikum for Bug #4049363
          v_rounded_amount.basic                := v_tot_rounded_amount.basic             - v_tot_amount.basic;
          v_rounded_amount.additional           := v_tot_rounded_amount.additional        - v_tot_amount.additional;
          v_rounded_amount.additional_cvd       := v_tot_rounded_amount.additional_cvd    - v_tot_amount.additional_cvd;/*Added by SACSETHI for the bug 5228046
                                                                                                                        -Additional CVD Enhancement*/
          v_rounded_amount.other                := v_tot_rounded_amount.other             - v_tot_amount.other;
          v_rounded_amount.excise_edu_cess      := v_tot_rounded_amount.excise_edu_cess   - v_tot_amount.excise_edu_cess;
          v_rounded_amount.cvd_edu_cess         := v_tot_rounded_amount.cvd_edu_cess      - v_tot_amount.cvd_edu_cess;

-- Date 16/04/2007 by sacsethi for Bug#5989740
        v_rounded_amount.sh_excise_edu_cess      := v_tot_rounded_amount.sh_excise_edu_cess   - v_tot_amount.sh_excise_edu_cess;
	v_rounded_amount.sh_cvd_edu_cess         := v_tot_rounded_amount.sh_cvd_edu_cess      - v_tot_amount.sh_cvd_edu_cess;
-- end 5989740

	-- 2nd Claim
        ELSIF v_proceed_for_2nd_claim = 'Y' THEN
          --statements added by Sanjikum for Bug #4049363

          v_temp_amount.basic                   := v_tot_amount.basic + v_1st_claim_rnd_amount.basic; -- 25.7 + 0.7 = 26.4
          v_tot_rounded_amount.basic            := ROUND(v_temp_amount.basic, v_rounding_precision); -- round(26.4, 0)= 26
          v_rounded_amount.basic                := (v_tot_rounded_amount.basic - v_temp_amount.basic) + v_1st_claim_rnd_amount.basic;

          v_temp_amount.additional              := v_tot_amount.additional + v_1st_claim_rnd_amount.additional;
          v_tot_rounded_amount.additional       := ROUND(v_temp_amount.additional, v_rounding_precision);
          v_rounded_amount.additional           := (v_tot_rounded_amount.additional - v_temp_amount.additional) + v_1st_claim_rnd_amount.additional;

        /*
        || Start of bug 5228046 -Additional CVD Enhancement
        || Added by SACSETHI
        */
        v_temp_amount.additional_cvd          := v_tot_amount.additional_cvd + v_1st_claim_rnd_amount.additional_cvd;
        v_tot_rounded_amount.additional_cvd   := ROUND(v_temp_amount.additional_cvd, v_rounding_precision);
        v_rounded_amount.additional_cvd       := (v_tot_rounded_amount.additional_cvd - v_temp_amount.additional_cvd) + v_1st_claim_rnd_amount.additional_cvd;

        /* End of bug 5228046 */

	  v_temp_amount.other                   := v_tot_amount.other + v_1st_claim_rnd_amount.other;
          v_tot_rounded_amount.other            := ROUND(v_temp_amount.other, v_rounding_precision);
          v_rounded_amount.other                := (v_tot_rounded_amount.other - v_temp_amount.other) + v_1st_claim_rnd_amount.other;

          v_temp_amount.excise_edu_cess         := v_tot_amount.excise_edu_cess + v_1st_claim_rnd_amount.excise_edu_cess;
          v_tot_rounded_amount.excise_edu_cess  := ROUND(v_temp_amount.excise_edu_cess, v_rounding_precision);
          v_rounded_amount.excise_edu_cess      := (v_tot_rounded_amount.excise_edu_cess - v_temp_amount.excise_edu_cess) + v_1st_claim_rnd_amount.excise_edu_cess;

          v_temp_amount.cvd_edu_cess            := v_tot_amount.cvd_edu_cess + v_1st_claim_rnd_amount.cvd_edu_cess;
          v_tot_rounded_amount.cvd_edu_cess     := ROUND(v_temp_amount.cvd_edu_cess, v_rounding_precision);
          v_rounded_amount.cvd_edu_cess         := (v_tot_rounded_amount.cvd_edu_cess - v_temp_amount.cvd_edu_cess) + v_1st_claim_rnd_amount.cvd_edu_cess;

-- Date 16/04/2007 by sacsethi for Bug#5989740
-- start 5989740

	  v_temp_amount.sh_excise_edu_cess         := v_tot_amount.sh_excise_edu_cess + v_1st_claim_rnd_amount.sh_excise_edu_cess;
          v_tot_rounded_amount.sh_excise_edu_cess  := ROUND(v_temp_amount.sh_excise_edu_cess, v_rounding_precision);
          v_rounded_amount.sh_excise_edu_cess      := (v_tot_rounded_amount.sh_excise_edu_cess - v_temp_amount.sh_excise_edu_cess) + v_1st_claim_rnd_amount.sh_excise_edu_cess;

          v_temp_amount.sh_cvd_edu_cess            := v_tot_amount.sh_cvd_edu_cess + v_1st_claim_rnd_amount.sh_cvd_edu_cess;
          v_tot_rounded_amount.sh_cvd_edu_cess     := ROUND(v_temp_amount.sh_cvd_edu_cess, v_rounding_precision);
          v_rounded_amount.sh_cvd_edu_cess         := (v_tot_rounded_amount.sh_cvd_edu_cess - v_temp_amount.sh_cvd_edu_cess) + v_1st_claim_rnd_amount.sh_cvd_edu_cess;

-- end 5989740

	ELSE
          FND_FILE.PUT_LINE( FND_FILE.log, 'Some Problem in CGIN Claiming');
        END IF;

      -- Other than CGIN cases
      ELSE
        v_statement_no := '2';

        --added by Sanjikum for Bug #4049363
        v_tot_rounded_amount.basic            := ROUND(v_tot_amount.basic, v_rounding_precision);
        v_rounded_amount.basic                := v_tot_rounded_amount.basic - v_tot_amount.basic;

        v_tot_rounded_amount.additional       := ROUND(v_tot_amount.additional, v_rounding_precision);
        v_rounded_amount.additional           := v_tot_rounded_amount.additional - v_tot_amount.additional;

      /*
      || Start of bug 5228046 -Additional CVD Enhancement
      || Added by SACSETHI
      */

       v_tot_rounded_amount.additional_cvd   := ROUND(v_tot_amount.additional_cvd, v_rounding_precision);
       v_rounded_amount.additional_cvd       := v_tot_rounded_amount.additional_cvd - v_tot_amount.additional_cvd;

      /* End of bug 5228046 */

        v_tot_rounded_amount.other            := ROUND(v_tot_amount.other, v_rounding_precision);
        v_rounded_amount.other                := v_tot_rounded_amount.other - v_tot_amount.other;

        v_tot_rounded_amount.excise_edu_cess  := ROUND(v_tot_amount.excise_edu_cess, v_rounding_precision);
        v_rounded_amount.excise_edu_cess      := v_tot_rounded_amount.excise_edu_cess - v_tot_amount.excise_edu_cess;

        v_tot_rounded_amount.cvd_edu_cess     := ROUND(v_tot_amount.cvd_edu_cess, v_rounding_precision);
        v_rounded_amount.cvd_edu_cess         := v_tot_rounded_amount.cvd_edu_cess - v_tot_amount.cvd_edu_cess;

-- Date 16/04/2007 by sacsethi for Bug#5989740
-- start 5989740

	v_tot_rounded_amount.sh_excise_edu_cess  := ROUND(v_tot_amount.sh_excise_edu_cess, v_rounding_precision);
        v_rounded_amount.sh_excise_edu_cess      := v_tot_rounded_amount.sh_excise_edu_cess - v_tot_amount.sh_excise_edu_cess;

        v_tot_rounded_amount.sh_cvd_edu_cess     := ROUND(v_tot_amount.sh_cvd_edu_cess, v_rounding_precision);
        v_rounded_amount.sh_cvd_edu_cess         := v_tot_rounded_amount.sh_cvd_edu_cess - v_tot_amount.sh_cvd_edu_cess;

-- end 5989740


      END IF;

      --These are common for all the If elses above and should be sum of different tax types

      v_tot_rounded_amount.total := NVL(v_tot_rounded_amount.basic,0) +
                                    NVL(v_tot_rounded_amount.additional,0) +
                                    NVL(v_tot_rounded_amount.additional_cvd,0) /*Added by SACSETHI for the bug 5228046 -Additional CVD Enhancement*/ +
				    NVL(v_tot_rounded_amount.other,0) +
				    NVL(v_tot_rounded_amount.excise_edu_cess,0) +
				    NVL(v_tot_rounded_amount.cvd_edu_cess,0) +
				    NVL(v_tot_rounded_amount.sh_excise_edu_cess,0) +  -- Date 16/04/2007 by sacsethi for Bug#5989740
				    NVL(v_tot_rounded_amount.sh_cvd_edu_cess,0);

      v_rounded_amount.total :=     NVL(v_rounded_amount.basic,0) +
				    NVL(v_rounded_amount.additional,0) +
                                    NVL(v_rounded_amount.additional_cvd,0) /*Added by SACSETHI for the bug 5228046 -Additional CVD Enhancement*/ +
				    NVL(v_rounded_amount.other,0) +
				    NVL(v_rounded_amount.excise_edu_cess,0) +
			     	    NVL(v_rounded_amount.cvd_edu_cess,0) +
				    NVL(v_rounded_amount.sh_excise_edu_cess,0) +  -- Date 16/04/2007 by sacsethi for Bug#5989740
			     	    NVL(v_rounded_amount.sh_cvd_edu_cess,0);

      v_rounded_amount_rg23 :=      NVL(v_rounded_amount.basic,0) +
                                    NVL(v_rounded_amount.additional,0) +
                                    NVL(v_rounded_amount.additional_cvd,0) +  /*Added by SACSETHI for the bug 5228046 -Additional CVD Enhancement*/  +
			            NVL(v_rounded_amount.other,0);
      v_rounded_amount_abs :=       ABS(NVL(v_rounded_amount.basic,0)) +
                                    ABS(NVL(v_rounded_amount.additional,0)) +
                                    ABS(NVL(v_rounded_amount.additional_cvd,0)) /*Added by SACSETHI for the bug 5228046 -Additional CVD Enhancement*/  +
				    ABS(NVL(v_rounded_amount.other,0)) +
				    ABS(NVL(v_rounded_amount.excise_edu_cess,0)) +
				    ABS(NVL(v_rounded_amount.cvd_edu_cess,0)) +
				    ABS(NVL(v_rounded_amount.sh_excise_edu_cess,0)) +  -- Date 16/04/2007 by sacsethi for Bug#5989740
				    ABS(NVL(v_rounded_amount.sh_cvd_edu_cess,0));

      -- Punching Rounding_Id as 0 for RG transactions where in no Rounding is Required
      v_statement_no := '3';

      --To check the amount with adding after taking absolute value
      IF v_rounded_amount_abs = 0 THEN
        v_zero_round_found := v_zero_round_found + 1;

	/* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
	lv_ttype_correct := 'CORRECT' ;
	/* Bug 4930048. Added by Lakshmi Gopalsami
	   Added proper alias names and changed transaction_source_num
	   to transaction_id while checking data in rcv_transactions.
	*/
        UPDATE JAI_CMN_RG_23AC_II_TRXS jcrg23ac
          SET jcrg23ac.rounding_id = 0
        WHERE jcrg23ac.organization_id = p_organization_id
        AND jcrg23ac.excise_invoice_no = v_excise_invoice_no
        AND jcrg23ac.excise_invoice_date = v_excise_invoice_date
        AND nvl(vendor_id,-999) = nvl(r.vendor_id,-999)/*bgowrava for forward porting bug#5674376*/
        AND nvl(vendor_site_id,-999) = nvl(r.vendor_site_id,-999)/*bgowrava for forward porting bug#5674376*/
        AND jcrg23ac.rounding_id IS NULL
        AND jcrg23ac.TRANSACTION_SOURCE_NUM = 18
        AND EXISTS (
            SELECT 1 FROM rcv_transactions rt
            WHERE rt.shipment_header_id = v_shipment_header_id
            AND rt.transaction_id = jcrg23ac.receipt_ref
            AND ( rt.transaction_type = r.transaction_type
                  OR ( rt.transaction_type = lv_ttype_correct AND exists
                            (select 1 from rcv_transactions rt1
			      where rt1.transaction_id = rt.parent_transaction_id
                             and rt1.transaction_type = r.transaction_type)
                     )
                )
        );

        DELETE FROM JAI_CMN_RG_ROUND_LINES WHERE rounding_id = v_rounding_id;

        FND_FILE.PUT_LINE( FND_FILE.log, '**** Zero Rounded ****');
        GOTO next_exc_inv;
      ELSIF v_rounded_amount.total > 0 THEN
        v_rounding_entry_type := 'CR';

        --Added by Sanjikum for Bug #4049363
        v_rounded_cr_amount := ABS(NVL(v_rounded_amount.basic,0) +
	                           NVL(v_rounded_amount.additional,0) +
                                   NVL(v_rounded_amount.additional_cvd,0) /*Changed by SACSETHI for the bug 5228046 -Additional CVD Enhancement*/ +
				   NVL(v_rounded_amount.other,0) +
				   NVL(v_rounded_amount.excise_edu_cess,0) +
				   NVL(v_rounded_amount.cvd_edu_cess,0) +
				   NVL(v_rounded_amount.sh_excise_edu_cess,0) +  -- Date 16/04/2007 by sacsethi for Bug#5989740
				   NVL(v_rounded_amount.sh_cvd_edu_cess,0));

      ELSIF v_rounded_amount.total < 0 THEN
        v_rounding_entry_type := 'DR';

        --Added by Sanjikum for Bug #4049363
        v_rounded_dr_amount := ABS(NVL(v_rounded_amount.basic,0) +
	                           NVL(v_rounded_amount.additional,0) +
                                   NVL(v_rounded_amount.additional_cvd,0) + /* 5228046 -Additional CVD Enhancement*/
				   NVL(v_rounded_amount.other,0) +
				   NVL(v_rounded_amount.excise_edu_cess,0) +
				   NVL(v_rounded_amount.cvd_edu_cess,0) +
				   NVL(v_rounded_amount.sh_excise_edu_cess,0) +  -- Date 16/04/2007 by sacsethi for Bug#5989740
				   NVL(v_rounded_amount.sh_cvd_edu_cess,0));

      END IF;

      IF NVL(v_rounded_amount.basic,0) < 0 THEN
        v_rounded_dr_rg23_amount.basic      := ABS(v_rounded_amount.basic);
      ELSE
        v_rounded_cr_rg23_amount.basic      := ABS(v_rounded_amount.basic);
      END IF;

      IF NVL(v_rounded_amount.additional,0) < 0 THEN
        v_rounded_dr_rg23_amount.additional := ABS(v_rounded_amount.additional);
      ELSE
        v_rounded_cr_rg23_amount.additional := ABS(v_rounded_amount.additional);
      END IF;

    /*
    ||Start of bug 5228046 - Additional CVD Enhancement
    */
    IF NVL(v_rounded_amount.additional_cvd,0) < 0 THEN
      v_rounded_dr_rg23_amount.additional_cvd := ABS(v_rounded_amount.additional_cvd);
    ELSE
      v_rounded_cr_rg23_amount.additional_cvd := ABS(v_rounded_amount.additional_cvd);
    END IF;

    /*End of bug 5228046 */


      IF NVL(v_rounded_amount.other,0) < 0 THEN
        v_rounded_dr_rg23_amount.other      := ABS(v_rounded_amount.other);
      ELSE
        v_rounded_cr_rg23_amount.other      := ABS(v_rounded_amount.other);
      END IF;

      IF (NVL(v_rounded_amount.excise_edu_cess,0) +
         NVL(v_rounded_amount.cvd_edu_cess,0)  +
	 NVL(v_rounded_amount.sh_excise_edu_cess,0) +
         NVL(v_rounded_amount.sh_cvd_edu_cess,0)) < 0
      THEN
        v_rounded_dr_oth_amount.total := ABS(NVL(v_rounded_amount.excise_edu_cess,0) +
	                                     NVL(v_rounded_amount.cvd_edu_cess,0) +
                                             NVL(v_rounded_amount.sh_excise_edu_cess,0) + -- Date 16/04/2007 by sacsethi for Bug#5989740
	                                     NVL(v_rounded_amount.sh_cvd_edu_cess,0)
					     );
      ELSE
        v_rounded_cr_oth_amount.total := ABS(NVL(v_rounded_amount.excise_edu_cess,0) +
	                                     NVL(v_rounded_amount.cvd_edu_cess,0) +
                                             NVL(v_rounded_amount.sh_excise_edu_cess,0) +  -- Date 16/04/2007 by sacsethi for Bug#5989740
	                                     NVL(v_rounded_amount.sh_cvd_edu_cess,0));
      END IF;

      IF NVL(v_rounded_amount.excise_edu_cess,0) < 0 THEN
        v_rounded_dr_oth_amount.excise_edu_cess   := ABS(v_rounded_amount.excise_edu_cess);
      ELSE
        v_rounded_cr_oth_amount.excise_edu_cess   := ABS(v_rounded_amount.excise_edu_cess);
      END IF;

      IF NVL(v_rounded_amount.cvd_edu_cess,0) < 0 THEN
        v_rounded_dr_oth_amount.cvd_edu_cess      := ABS(v_rounded_amount.cvd_edu_cess);
      ELSE
        v_rounded_cr_oth_amount.cvd_edu_cess      := ABS(v_rounded_amount.cvd_edu_cess);
      END IF;

-- Date 16/04/2007 by sacsethi for Bug#5989740
-- start 5989740


      IF NVL(v_rounded_amount.sh_excise_edu_cess,0) < 0 THEN
        v_rounded_dr_oth_amount.sh_excise_edu_cess   := ABS(v_rounded_amount.sh_excise_edu_cess);
      ELSE
        v_rounded_cr_oth_amount.sh_excise_edu_cess   := ABS(v_rounded_amount.sh_excise_edu_cess);
      END IF;

      IF NVL(v_rounded_amount.sh_cvd_edu_cess,0) < 0 THEN
        v_rounded_dr_oth_amount.sh_cvd_edu_cess      := ABS(v_rounded_amount.sh_cvd_edu_cess);
      ELSE
        v_rounded_cr_oth_amount.sh_cvd_edu_cess      := ABS(v_rounded_amount.sh_cvd_edu_cess);
      END IF;

-- end 5989740



      -- check the item classes
      -- if there is a combination of cgin and rmin find which register to hit

      v_statement_no := '4';

      OPEN c_rg_modvat_account(p_organization_id, r.location_id);
      FETCH c_rg_modvat_account INTO v_modvat_rm_account_id, v_modvat_cg_account_id;
      CLOSE c_rg_modvat_account;

      v_statement_no := '4.1';
      IF v_register_type = 'A' THEN
        v_rg_account_id := v_modvat_rm_account_id;
      ELSIF v_register_type = 'C' THEN
        v_rg_account_id := v_modvat_cg_account_id;
      END IF;

      -- Required Accounts are not specified at the location where RG23 PART II entry will be posted. So, through out an error
      IF v_rg_account_id IS NULL THEN
        IF v_register_type = 'A' THEN
          v_err_message := 'ERROR: Cenvat RMIN Account is not specified for Location:'||r.location_id;
        ELSE
          v_err_message := 'ERROR: Cenvat CGIN Account is not specified for Location:'||r.location_id;
        END IF;

        FND_FILE.PUT_LINE( FND_FILE.log, v_err_message);
        RAISE_APPLICATION_ERROR( -20099, v_err_message);
      END IF;

      v_statement_no := '5';

      OPEN c_vendor(v_shipment_header_id);
      FETCH c_vendor INTO v_vendor_id, v_vendor_site_id, v_receipt_num;
      CLOSE c_vendor;

      v_statement_no := '7';

      OPEN c_slno_balance(p_organization_id, r.location_id, v_fin_year, v_register_type);
      FETCH c_slno_balance INTO v_slno, v_balance;
      CLOSE c_slno_balance;
      v_rg23_balance := nvl(v_balance,0);

      v_statement_no := '8';

      IF v_slno IS NULL or v_slno = 0 THEN
        v_slno := 1;
      ELSE
        v_slno := v_slno + 1;
      END IF;

      v_statement_no := '8.1';

      INSERT INTO JAI_CMN_RG_23AC_II_TRXS(
        REGISTER_ID, ORGANIZATION_ID, LOCATION_ID, FIN_YEAR, INVENTORY_ITEM_ID, SLNO,
        CR_BASIC_ED, DR_BASIC_ED,
        CR_ADDITIONAL_ED, DR_ADDITIONAL_ED, --Added by Sanjikum for Bug #4049363
        CR_ADDITIONAL_CVD,DR_ADDITIONAL_CVD, /* ADDED THE COLUMNS CR_ADDITIONAL_CVD,DR_ADDITIONAL_CVD FOR THE ENHANCEMENT 5228046 */
	CR_OTHER_ED, DR_OTHER_ED, --Added by Sanjikum for Bug #4049363
        ROUNDING_ID, EXCISE_INVOICE_NO, EXCISE_INVOICE_DATE,
        TRANSACTION_SOURCE_NUM, RECEIPT_REF, REGISTER_TYPE, REMARKS,
        VENDOR_ID, VENDOR_SITE_ID, CUSTOMER_ID, CUSTOMER_SITE_ID,
        OPENING_BALANCE, CLOSING_BALANCE, CHARGE_ACCOUNT_ID,
        CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN
        , TRANSACTION_DATE, OTHER_TAX_CREDIT, OTHER_TAX_DEBIT--Added by Sanjikum
      ) VALUES (
        JAI_CMN_RG_23AC_II_TRXS_S.nextval, p_organization_id, r.location_id , v_fin_year, 0, v_slno,
        --Added by Sanjikum for Bug #4049363
        v_rounded_cr_rg23_amount.basic, v_rounded_dr_rg23_amount.basic,
        v_rounded_cr_rg23_amount.additional, v_rounded_dr_rg23_amount.additional,
        v_rounded_cr_rg23_amount.additional_cvd, v_rounded_dr_rg23_amount.additional_cvd,/* added for the enhancement 5228046 */
	v_rounded_cr_rg23_amount.other, v_rounded_dr_rg23_amount.other,
        -1, r.excise_invoice_no, r.excise_invoice_date,
        18, r.shipment_header_id, v_register_type, 'Rounding Entry for Receipt No:'||v_receipt_num,
        v_vendor_id, v_vendor_site_id, NULL, NULL,
        v_rg23_balance, v_rg23_balance + v_rounded_amount_rg23, v_rg_account_id,
        SYSDATE, v_created_by, SYSDATE, v_created_by, v_last_update_login
        , v_today, v_rounded_cr_oth_amount.total, v_rounded_dr_oth_amount.total

      ) RETURNING register_id INTO v_register_id_part_ii;

      DECLARE
        v_tax_type JAI_CMN_RG_OTHERS.tax_type%TYPE;
        v_dr_amt JAI_CMN_RG_OTHERS.debit%TYPE;
        v_cr_amt JAI_CMN_RG_OTHERS.credit%TYPE;
      BEGIN

        FOR I in 1..4 LOOP -- Date 16/04/2007 by sacsethi for Bug#5989740

          /* Vijay Shankar for Bug#4103161
          SELECT  DECODE(i, 1, jai_constants.tax_type_exc_edu_cess, 2, jai_constants.tax_type_cvd_edu_cess) tax_type,
                  DECODE(i, 1, v_rounded_dr_oth_amount.excise_edu_cess, 2, v_rounded_dr_oth_amount.cvd_edu_cess) dr_cess_amount,
                  DECODE(i, 1, v_rounded_cr_oth_amount.excise_edu_cess, 2, v_rounded_cr_oth_amount.cvd_edu_cess) cr_cess_amount
          INTO    v_tax_type, v_dr_amt, v_cr_amt
          FROM    dual;
          */

          if i = 1 then
            v_tax_type  := jai_constants.tax_type_exc_edu_cess;
            v_dr_amt    := v_rounded_dr_oth_amount.excise_edu_cess;
            v_cr_amt    := v_rounded_cr_oth_amount.excise_edu_cess;
          elsif i = 2 then
            v_tax_type  := jai_constants.tax_type_cvd_edu_cess;
            v_dr_amt    := v_rounded_dr_oth_amount.cvd_edu_cess;
            v_cr_amt    := v_rounded_cr_oth_amount.cvd_edu_cess;
-- Date 16/04/2007 by sacsethi for Bug#5989740
	  elsif i = 3 then
            v_tax_type  := jai_constants.tax_type_sh_exc_edu_cess;
	    v_dr_amt    := v_rounded_dr_oth_amount.sh_excise_edu_cess;
	    v_cr_amt    := v_rounded_cr_oth_amount.sh_excise_edu_cess;
          elsif i = 4 then
	    v_tax_type  := jai_constants.tax_type_sh_cvd_edu_cess;
	    v_dr_amt    := v_rounded_dr_oth_amount.sh_cvd_edu_cess;
	    v_cr_amt    := v_rounded_cr_oth_amount.sh_cvd_edu_cess;
-- end 5989740
          end if;

          IF NVL(v_dr_amt,0) <> 0 OR NVL(v_cr_amt,0) <> 0 THEN
            INSERT INTO JAI_CMN_RG_OTHERS
            (RG_OTHER_ID,
            SOURCE_TYPE,
            SOURCE_REGISTER,
            SOURCE_REGISTER_ID,
            TAX_TYPE,
            DEBIT,
            CREDIT,
            OPENING_BALANCE,
            CLOSING_BALANCE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN)
          VALUES
            (JAI_CMN_RG_OTHERS_S.nextval,
            1,
            DECODE(v_register_type,'A','RG23A_P2','C','RG23C_P2'),/*for bug 5054176*/
            v_register_id_part_ii,
            v_tax_type,
            v_dr_amt,
            v_cr_amt,
            NULL,
            NULL,
            v_created_by,
            sysdate,
            v_created_by,
            sysdate,
            v_last_update_login);
          END IF;
        END LOOP;
      END;

      v_statement_no := '10a';
      -- this call will update Rounding RG23 PartII entry with Period_balance_id and updates all records of JAI_CMN_RG_PERIOD_BALS
      -- that come after the period in which parent Excise invoice has hit RG
      jai_cmn_rg_period_bals_pkg.adjust_rounding(v_register_id_part_ii, v_period_balance_id, v_no_of_periods_updated);

      v_statement_no := '11';
      INSERT INTO JAI_CMN_RG_ROUND_HDRS(
        ROUNDING_ID, SOURCE_HEADER_ID, EXCISE_INVOICE_NO, EXCISE_INVOICE_DATE,
        EXCISE_AMT_BEFORE_ROUNDING, EXCISE_AMT_AFTER_ROUNDING,
        --Added the below 3 by Sanjikum for Bug #4049363
        BASIC_ED, ROUNDED_BASIC_ED,
        ADDITIONAL_ED, ROUNDED_ADDITIONAL_ED,
        ADDITIONAL_CVD, ROUNDED_ADDITIONAL_CVD, /* ADDED FOR THE BUG 5228046 -ADDITIONAL CVD ENHANCEMENT*/
        OTHER_ED, ROUNDED_OTHER_ED,
        EXCISE_EDU_CESS, ROUNDED_EXCISE_EDU_CESS,
        sh_excise_edu_cess, rounded_sh_excise_edu_cess, -- Date 16/04/2007 by sacsethi for Bug#5989740
        CVD_EDU_CESS, ROUNDED_CVD_EDU_CESS,
        sh_cvd_edu_cess, rounded_sh_cvd_edu_cess, -- Date 16/04/2007 by sacsethi for Bug#5989740
        REGISTER_ID, SOURCE, SRC_TRANSACTION_TYPE,
        CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN
        , register, -- Vijay Shankar for Bug#4103161
	program_application_id, program_id, program_login_id, request_id

      ) VALUES (
        v_rounding_id, v_shipment_header_id, v_excise_invoice_no, v_excise_invoice_date,
        v_tot_amount.total, v_tot_rounded_amount.total,
        --Added the below 6 by Sanjikum for Bug #4049363
        v_tot_amount.basic, v_tot_rounded_amount.basic,
        v_tot_amount.additional, v_tot_rounded_amount.additional,
        v_tot_amount.additional_cvd, v_tot_rounded_amount.additional_cvd,/* added for the bug 5228046 -additional cvd enhancement*/
        v_tot_amount.other, v_tot_rounded_amount.other,
        v_tot_amount.excise_edu_cess, v_tot_rounded_amount.excise_edu_cess,
        v_tot_amount.sh_excise_edu_cess, v_tot_rounded_amount.sh_excise_edu_cess, -- Date 16/04/2007 by sacsethi for Bug#5989740
        v_tot_amount.cvd_edu_cess, v_tot_rounded_amount.cvd_edu_cess,
        v_tot_amount.sh_cvd_edu_cess, v_tot_rounded_amount.sh_cvd_edu_cess, -- Date 16/04/2007 by sacsethi for Bug#5989740
        v_register_id_part_ii, 'PO', v_transaction_type,
        SYSDATE, v_created_by, SYSDATE, v_created_by, v_last_update_login
        , LV_RG23_REGISTER,  -- Vijay Shankar for Bug#4103161
	fnd_profile.value('PROG_APPL_ID'), fnd_profile.value('CONC_PROGRAM_ID'), fnd_profile.value('CONC_LOGIN_ID'), fnd_profile.value('CONC_REQUEST_ID')
      );

      v_statement_no := '12';

      -- 2 (CR, DR) GL Interface related calls has to be coded
      -- Modvat Account entries
      pass_accounting(
        p_organization_id           => p_organization_id,
        p_transaction_id            => v_rounding_id,
        p_transaction_date          => v_today,
        p_shipment_line_id          => -1,
        p_acct_type                 => v_acct_type,
        p_acct_nature               => v_acct_nature,
        p_source                    => v_source_name,
        p_category                  => v_category_name,
        p_code_combination_id       => v_rg_account_id,
        p_entered_dr                => v_rounded_cr_amount,
        p_entered_cr                => v_rounded_dr_amount,
        p_created_by                => v_created_by,
        p_currency_code             => 'INR',
        p_currency_conversion_type  => NULL,
        p_currency_conversion_date  => NULL,
        p_currency_conversion_rate  => NULL,
        p_receipt_num               => v_receipt_num
      );

      v_statement_no := '13';

      jai_cmn_gl_pkg.create_gl_entry(
        p_organization_id   => p_organization_id,
        p_currency_code     => 'INR',
        p_credit_amount     => v_rounded_dr_amount,
        p_debit_amount      => v_rounded_cr_amount,
        p_cc_id             => v_rg_account_id,
        p_je_source_name    => v_source_name,
        p_je_category_name  => v_category_name,
        p_created_by        => v_created_by,
        p_accounting_date   => v_today,
        p_reference_10      => 'India Local Rounding Entry for Shipment_Header_id:'||r.shipment_header_id
                              ||', excise_invoice_no:'||r.excise_invoice_no||', exc_inv_date:'||r.excise_invoice_date,
        p_reference_23      => 'ja_in_rg_rounding_p',
        p_reference_24      => 'JAI_CMN_RG_ROUND_HDRS',
        p_reference_25      => 'ROUNDING_ID',
        p_reference_26      => v_rounding_id
      );

      v_statement_no := '14';

      -- Rounding Account entries
      pass_accounting(
        p_organization_id           => p_organization_id,
        p_transaction_id            => v_rounding_id,
        p_transaction_date          => v_today,
        p_shipment_line_id          => -1,
        p_acct_type                 => v_acct_type,
        p_acct_nature               => v_acct_nature,
        p_source                    => v_source_name,
        p_category                  => v_category_name,
        p_code_combination_id       => v_rg_rounding_account_id,
        p_entered_dr                => v_rounded_dr_amount,
        p_entered_cr                => v_rounded_cr_amount,
        p_created_by                => v_created_by,
        p_currency_code             => 'INR',
        p_currency_conversion_type  => NULL,
        p_currency_conversion_date  => NULL,
        p_currency_conversion_rate  => NULL,
        p_receipt_num               => v_receipt_num
      );

      v_statement_no := '15';

      jai_cmn_gl_pkg.create_gl_entry(
        p_organization_id   => p_organization_id,
        p_currency_code     => 'INR',
        p_credit_amount     => v_rounded_cr_amount,
        p_debit_amount      => v_rounded_dr_amount,
        p_cc_id             => v_rg_rounding_account_id,
        p_je_source_name    => v_source_name,
        p_je_category_name  => v_category_name,
        p_created_by        => v_created_by,
        p_accounting_date   => v_today,
        p_reference_10      => 'India Local Rounding Entry for Shipment_Header_id:'||r.shipment_header_id
                                ||', excise_invoice_no:'||r.excise_invoice_no||', exc_inv_date:'||r.excise_invoice_date,
        p_reference_23      => 'ja_in_rg_rounding_p',
        p_reference_24      => 'JAI_CMN_RG_ROUND_HDRS',
        p_reference_25      => 'ROUNDING_ID',
        p_reference_26      => v_rounding_id
      );

      v_statement_no := '16';

      IF v_register_type = 'A' THEN
        UPDATE JAI_CMN_RG_BALANCES
          SET rg23a_balance = nvl(rg23a_balance, 0) + v_rounded_amount_rg23
        WHERE organization_id = p_organization_id
        AND location_id = r.location_id;

      ELSIF v_register_type = 'C' THEN
        UPDATE JAI_CMN_RG_BALANCES
          SET rg23c_balance = nvl(rg23c_balance, 0) + v_rounded_amount_rg23
        WHERE organization_id = p_organization_id
        AND location_id = r.location_id;

      END IF;

      v_statement_no := '16.1';

      FND_FILE.put_line( FND_FILE.log, 'v_full_cgin_case->'||v_full_cgin_case
        ||', cent_cnt->'||r_cgin_chk_for_2nd_claim.cent_percent_cnt
        ||', exc_rnd_cnt->'||v_excise_inv_rnd_cnt
      );

      -- Updating the RG lines of Receipt with Rounding_ID
      IF v_full_cgin_case = 'Y' AND r_cgin_chk_for_2nd_claim.cent_percent_cnt > 0
        AND v_excise_inv_rnd_cnt=0
      THEN

        FND_FILE.put_line( FND_FILE.log, '1st Rounding of CGIN in Case of 100% CGIN claim');
        /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
	lv_ttype_correct := 'CORRECT' ;
	/*  Bug 4930048. Added by Lakshmi Gopalsami
	    Added proper aliases and changed transaction_source_num
	    to transaction_id
	*/
	/* Bug 5207827. Added by Lakshmi Gopalsami
	   Fixed performance issue for sql id - 17699668
           Removed EXISTS and added IN clause
	*/
        UPDATE JAI_CMN_RG_23AC_II_TRXS jcrg23ac
          SET jcrg23ac.rounding_id = v_rounding_id
        WHERE jcrg23ac.organization_id = p_organization_id
        AND jcrg23ac.excise_invoice_no = v_excise_invoice_no
        AND jcrg23ac.excise_invoice_date = v_excise_invoice_date
        AND nvl(vendor_id,-999) = nvl(r.vendor_id,-999)/*bgowrava for forward porting bug#5674376*/
        AND nvl(vendor_site_id,-999) = nvl(r.vendor_site_id,-999)/*bgowrava for forward porting bug#5674376*/
        AND jcrg23ac.rounding_id IS NULL
        AND jcrg23ac.TRANSACTION_SOURCE_NUM = 18
        AND jcrg23ac.receipt_ref IN  (
            SELECT rt.transaction_id
            FROM rcv_transactions rt
            WHERE rt.shipment_header_id = v_shipment_header_id
            AND ( rt.transaction_type = r.transaction_type
                  OR ( rt.transaction_type = lv_ttype_correct
		       AND exists (select 1
		                     from rcv_transactions rt1
				    where rt1.transaction_id = rt.parent_transaction_id
				      and rt1.transaction_type = r.transaction_type)
                     )
                )
          )
       AND register_id IN (
                select min(register_id) from JAI_CMN_RG_23AC_II_TRXS
                WHERE organization_id = p_organization_id
                AND excise_invoice_no = v_excise_invoice_no
                AND excise_invoice_date = v_excise_invoice_date
                AND nvl(vendor_id,-999) = nvl(r.vendor_id,-999)/*bgowrava for forward porting bug#5674376*/
                AND nvl(vendor_site_id,-999) = nvl(r.vendor_site_id,-999)/*bgowrava for forward porting bug#5674376*/
                AND rounding_id IS NULL
                AND TRANSACTION_SOURCE_NUM = 18
                group by RECEIPT_REF);

      ELSE

      /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/

      lv_ttype_correct := 'CORRECT' ;

      /*  Bug 4930048. Added by Lakshmi Gopalsami
          Added proper aliases and changed transaction_source_num
	  to transaction_id
      */

        UPDATE JAI_CMN_RG_23AC_II_TRXS jcrg23ac
          SET jcrg23ac.rounding_id = v_rounding_id
        WHERE jcrg23ac.organization_id = p_organization_id
        AND jcrg23ac.excise_invoice_no = v_excise_invoice_no
        AND jcrg23ac.excise_invoice_date = v_excise_invoice_date
        AND nvl(vendor_id,-999) = nvl(r.vendor_id,-999)/*bgowrava for forward porting bug#5674376*/
        AND nvl(vendor_site_id,-999)= nvl(r.vendor_site_id,-999)/*bgowrava for forward porting bug#5674376*/
        AND jcrg23ac.rounding_id IS NULL
        AND jcrg23ac.TRANSACTION_SOURCE_NUM = 18
        AND EXISTS (
            SELECT rt.transaction_id
            FROM rcv_transactions rt
            WHERE rt.shipment_header_id = v_shipment_header_id
            AND rt.transaction_id = jcrg23ac.receipt_ref
            AND ( rt.transaction_type = r.transaction_type
                  OR ( rt.transaction_type = lv_ttype_correct
		        AND exists      --'CORRECT'
                            (select 1
			       from rcv_transactions rt1
			      where rt1.transaction_id= rt.parent_transaction_id
                                and rt1.transaction_type = r.transaction_type)
                     )
                )
        );

      END IF;


      v_rounding_entries_made := v_rounding_entries_made + 1;

      v_statement_no := '17';
      IF v_no_of_invoices_posted >= v_commit_interval THEN
        v_no_of_invoices_posted := 0;
        COMMIT;
      ELSE
        v_no_of_invoices_posted := v_no_of_invoices_posted + 1;
      END IF;

      <<next_exc_inv>>
      v_save_point_set := false;

    EXCEPTION
      WHEN OTHERS THEN
        v_tot_errored_entries := v_tot_errored_entries + 1;
        FND_FILE.PUT_LINE( FND_FILE.log, 'Error at statement_no->'|| v_statement_no
          ||', shipment_header_id->'||v_shipment_header_id
          ||', excise_invoice_no->'||v_excise_invoice_no
          ||', excise_invoice_date->'||v_excise_invoice_date||' '
        );
        FND_FILE.PUT_LINE( FND_FILE.log, 'ErrMess->'|| SQLERRM);

        IF v_save_point_set THEN
          -- This has to rollback only if SAVEPOINT is set for the exc invoice being processed
          ROLLBACK TO previous_savepoint;
          v_save_point_set := false;
        END IF;

    END;

    --Added the below 5 by Sanjikum for Bug #4049363
    v_tot_amount := NULL;
    v_tot_rounded_amount := NULL;
    v_rounded_amount := NULL;
    v_rounded_amount_abs := NULL;
    v_rounded_amount_rg23 := NULL;
    v_rounded_cr_amount := NULL;
    v_rounded_dr_amount := NULL;
    v_rounded_cr_rg23_amount := NULL;
    v_rounded_dr_rg23_amount := NULL;
    v_rounded_cr_oth_amount := NULL;
    v_rounded_dr_oth_amount := NULL;

    v_rounding_entry_type := null;

    v_vendor_id := null;
    v_vendor_site_id := null;
    v_modvat_rm_account_id := null;
    v_modvat_cg_account_id := null;
    v_rg_account_id := null;
    v_rg23_balance := null;
    v_balance := null;
    v_slno := null;

    v_rounding_id := null;
    v_register_id_part_ii := null;

    v_shipment_header_id := null;
    v_excise_invoice_no := null;
    v_excise_invoice_date := null;
    v_rounding_type := null;
    v_register_type := null;

    v_exc_inv_rnd_counter := v_exc_inv_rnd_counter + 1;

   END LOOP;

  END LOOP;

  FND_FILE.PUT_LINE( FND_FILE.log, 'Completed. Total Rounding entries made -> '|| v_rounding_entries_made
    ||', errored entries->'||v_tot_errored_entries
    ||', Zero Exc. Amt. Invoices found->'||v_zero_round_found
    ||', total Ex. Invoices processed->'||v_tot_processed_invoices
  );

  <<do_commit>>
  COMMIT;


   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      p_err_buf  := null;
      p_ret_code := null;
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

  END do_rounding;

  FUNCTION get_parent_register_id
  (
    p_register_id IN NUMBER
  ) RETURN NUMBER IS

  /* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_rcv_rnd_pkg.get_parent_register_id';

    CURSOR c_part_ii_record(cp_register_id IN NUMBER) IS
      SELECT
        register_type, organization_id, location_id, excise_invoice_no, excise_invoice_date,
        receipt_ref shipment_header_id,
        vendor_id,vendor_site_id/*bgowrava for forward porting bug#5674376*/
      FROM JAI_CMN_RG_23AC_II_TRXS
      WHERE register_id = cp_register_id;
    r_part_ii_rec c_part_ii_record%ROWTYPE;

    -- this cursor excludes rounding entries
    CURSOR c_parent_part_ii_rec( cp_register_type IN VARCHAR2, cp_organization_id IN NUMBER, cp_location_id IN NUMBER,
        cp_excise_invoice_no IN VARCHAR2, cp_excise_invoice_date IN DATE,
        cp_vendor_id NUMBER,cp_vendor_site_id NUMBER,cp_shipment_header_id NUMBER) IS
      SELECT min(register_id) register_id
      FROM JAI_CMN_RG_23AC_II_TRXS
      WHERE organization_id = cp_organization_id
      AND location_id = cp_location_id
      AND register_type = cp_register_type
      AND excise_invoice_no = cp_excise_invoice_no
      AND excise_invoice_date = cp_excise_invoice_date
      AND inventory_item_id <> 0;

    CURSOR c_2nd_claim_register_id(cp_organization_id IN NUMBER, cp_location_id IN NUMBER,
          cp_excise_invoice_no IN VARCHAR2, cp_excise_invoice_date IN DATE,
          cp_vendor_id NUMBER,cp_vendor_site_id NUMBER) IS /*bgowrava for forward porting bug#5674376*/
      select  min(register_id)
      from    JAI_CMN_RG_23AC_II_TRXS a
      where   organization_id = cp_organization_id
      and     location_id = cp_location_id
      and     excise_invoice_no = cp_excise_invoice_no
      and     excise_invoice_date = cp_excise_invoice_date
      AND     nvl(vendor_id,-999) = nvl(cp_vendor_id,-999)/*bgowrava for forward porting bug#5674376*/
		  AND     nvl(vendor_site_id,-999) = nvl(cp_vendor_site_id,-999)/*bgowrava for forward porting bug#5674376*/
      and     inventory_item_id <> 0
      and     exists (select '1'
                      from JAI_CMN_RG_23AC_II_TRXS
                      where   organization_id = a.organization_id
                      and     location_id = a.location_id
                      and     excise_invoice_no = a.excise_invoice_no
                      and     excise_invoice_date = a.excise_invoice_date
                      AND     nvl(vendor_id,-999) = nvl(a.vendor_id,-999)/*bgowrava for forward porting bug#5674376*/
										  AND     nvl(vendor_site_id,-999) = nvl(a.vendor_site_id,-999)/*bgowrava for forward porting bug#5674376*/
                      and     inventory_item_id = a.inventory_item_id
                      and     receipt_ref = a.RECEIPT_REF
                      and     register_id < a.register_id
                    );

    cursor c_get_all_rounding_ids
    (cp_excise_invoice_no IN VARCHAR2, cp_excise_invoice_date IN DATE,
    cp_vendor_id NUMBER, cp_vendor_site_id NUMBER) is
    select min(register_id) minimum_rounding_id, max(register_id) maximum_rounding_id
    from   JAI_CMN_RG_23AC_II_TRXS
    where  inventory_item_id = 0
    and    excise_invoice_no = cp_excise_invoice_no
    and   excise_invoice_date = cp_excise_invoice_date
    and    nvl(vendor_id,-999)      = nvl(cp_vendor_id,-999)/*bgowrava for forward porting bug#5674376*/
    and    nvl(vendor_site_id,-999) = nvl(cp_vendor_site_id,-999);/*bgowrava for forward porting bug#5674376*/


    r_full_cgin_chk             c_full_cgin_chk%ROWTYPE;
    r_parent_part_ii_rec        c_parent_part_ii_rec%ROWTYPE;
    r_cgin_chk                  c_cgin_chk_for_2nd_claim%ROWTYPE;
    r_get_all_rounding_ids      c_get_all_rounding_ids%rowtype;

    v_return_register_id        NUMBER;
  BEGIN

    /* Get the details of the rounding entry */
    OPEN c_part_ii_record(p_register_id);
    FETCH c_part_ii_record INTO r_part_ii_rec;
    CLOSE c_part_ii_record;

    /* Check if rounding is against an excise invoice having only CGIN items */
    OPEN c_full_cgin_chk(r_part_ii_rec.shipment_header_id, r_part_ii_rec.excise_invoice_no,
        r_part_ii_rec.excise_invoice_date,r_part_ii_rec.vendor_id,r_part_ii_rec.vendor_site_id); /*bgowrava for forward porting bug#5674376*/
    FETCH c_full_cgin_chk INTO r_full_cgin_chk;
    CLOSE c_full_cgin_chk;

    /* check if the CGIN invoice has been claimed 100 % */
    OPEN c_cgin_chk_for_2nd_claim(r_part_ii_rec.shipment_header_id, r_part_ii_rec.excise_invoice_no,
        r_part_ii_rec.excise_invoice_date,r_part_ii_rec.vendor_id,r_part_ii_rec.vendor_site_id); /*bgowrava for forward porting bug#5674376*/
    FETCH c_cgin_chk_for_2nd_claim INTO r_cgin_chk;
    CLOSE c_cgin_chk_for_2nd_claim;

      -- Condition to test whether excise invoice is of full CGIN items and 2nd Claim is done for some/all lines
    IF  r_full_cgin_chk.total_cnt = r_full_cgin_chk.cgin_cnt AND
        r_cgin_chk.cent_percent_cnt > 0
    THEN

      /* Check if two rounding entry has been passed for the given excise invoice */
      open c_get_all_rounding_ids(r_part_ii_rec.excise_invoice_no, r_part_ii_rec.excise_invoice_date,r_part_ii_rec.vendor_id,r_part_ii_rec.vendor_site_id);/*bgowrava for forward porting bug#5674376*/
      fetch c_get_all_rounding_ids into r_get_all_rounding_ids;
      close c_get_all_rounding_ids;

      if r_get_all_rounding_ids.minimum_rounding_id <> r_get_all_rounding_ids.maximum_rounding_id then

        if r_get_all_rounding_ids.maximum_rounding_id = p_register_id then

          FND_FILE.put_line(fnd_file.log, '2nd Claim Rounding Register_id is Selected');

          OPEN c_2nd_claim_register_id
            (r_part_ii_rec.organization_id, r_part_ii_rec.location_id,
             r_part_ii_rec.excise_invoice_no, r_part_ii_rec.excise_invoice_date
             , r_part_ii_rec.vendor_id, r_part_ii_rec.vendor_site_id);/*bgowrava for forward porting bug#5674376*/
          FETCH c_2nd_claim_register_id INTO v_return_register_id;
          CLOSE c_2nd_claim_register_id;

          goto exit_from_function;

        else

          FND_FILE.put_line(fnd_file.log, '1st Claim Rounding Register_id is Selected');

        end if; /* 2nd claim rounding id is selected */

      end if;

    end if; /* excise invoice is of full CGIN items and 2nd Claim is done for some/all lines */

    FND_FILE.put_line(fnd_file.log, 'Minimum Register_id is Selected');
    OPEN c_parent_part_ii_rec
      (r_part_ii_rec.register_type, r_part_ii_rec.organization_id,
       r_part_ii_rec.location_id, r_part_ii_rec.excise_invoice_no, r_part_ii_rec.excise_invoice_date,
       r_part_ii_rec.vendor_id,r_part_ii_rec.vendor_site_id,r_part_ii_rec.shipment_header_id);/*bgowrava for forward porting bug#5674376*/
    FETCH c_parent_part_ii_rec INTO v_return_register_id;
    CLOSE c_parent_part_ii_rec;

    -- v_return_register_id := r_parent_part_ii_rec.register_id;

    << exit_from_function >>
    return v_return_register_id;

   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

  END get_parent_register_id;

  PROCEDURE pass_accounting(
      p_organization_id           number,
      p_transaction_id            number,   -- this is the rounding_id passed in JAI_CMN_RG_ROUND_HDRS table
      p_transaction_date          date,
      p_shipment_line_id          number,
      p_acct_type                 varchar2,
      p_acct_nature               varchar2,
      p_source                    varchar2,
      p_category                  varchar2,
      p_code_combination_id       number,
      p_entered_dr                number,
      p_entered_cr                number,
      p_created_by                number,
      p_currency_code             varchar2,
      p_currency_conversion_type  varchar2,
      p_currency_conversion_date  varchar2,
      p_currency_conversion_rate  varchar2,
      p_receipt_num               varchar2
  ) IS

    v_organization_code   ORG_ORGANIZATION_DEFINITIONS.organization_code%TYPE;
    --v_receipt_num         RCV_SHIPMENT_HEADERS.receipt_num%TYPE;
    v_period_name         GL_PERIODS.period_name%TYPE;

    v_transaction_type    VARCHAR2(20);
    --v_shipment_header_id  NUMBER;

    CURSOR c_shipment_header_id(cp_rounding_id IN NUMBER) IS
      SELECt source_header_id shipment_header_id
      FROM JAI_CMN_RG_ROUND_HDRS
      WHERE rounding_id = cp_rounding_id;

    CURSOR c_receipt_num(cp_shipment_header_id IN NUMBER) IS
      SELECt receipt_num
      FROM rcv_shipment_headers
      WHERE shipment_header_id = cp_shipment_header_id;

    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Removed org_organization_definitions from the
     * cursor c_orgn_code_n_period_name
     * and passed set_of_books_id to the cursor. Also removed
     * gl_sets_of_books and included gl_ledgers.
     */

    CURSOR c_orgn_code_n_period_name(cp_set_of_books_id IN NUMBER) IS
      SELECT gd.period_name
      FROM   gl_ledgers gle,gl_periods gd
      WHERE gle.ledger_id = cp_set_of_books_id
       AND gd.period_set_name = gle.period_set_name
       AND trunc(p_transaction_date) BETWEEN gd.start_date and gd.end_date
       AND adjustment_period_flag='N';

  /* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_rcv_rnd_pkg.pass_accounting';

  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Defined variable for implementing caching logic.
   */
  l_func_curr_det     jai_plsql_cache_pkg.func_curr_details;
  ln_set_of_books_id  NUMBER;

  BEGIN

    v_transaction_type  := 'HEADER';
   /* Bug 5243532. Added by Lakshmi Gopalsami
    * Implemented caching logic for getting organization_code
    */
    l_func_curr_det       := jai_plsql_cache_pkg.return_sob_curr
                              (p_org_id  =>  p_organization_id);
    v_organization_code  := l_func_curr_det.organization_code;
    ln_set_of_books_id    := l_func_curr_det.ledger_id;

   /* Bug 5243532. Added by Lakshmi Gopalsami
    * Passes ln_set_of_books_id instead of p_transaction_id
    */

    OPEN c_orgn_code_n_period_name(ln_set_of_books_id);
    FETCH c_orgn_code_n_period_name INTO v_period_name;
    CLOSE c_orgn_code_n_period_name;

    /*
    OPEN c_shipment_header_id(p_transaction_id);
    FETCH c_shipment_header_id INTO v_shipment_header_id;
    CLOSE c_shipment_header_id;

    OPEN c_receipt_num(v_shipment_header_id);
    FETCH c_receipt_num INTO v_receipt_num;
    CLOSE c_receipt_num;
    */
    INSERT INTO JAI_RCV_JOURNAL_ENTRIES (JOURNAL_ENTRY_ID,
      organization_code, receipt_num, transaction_id, creation_date, transaction_date,
      shipment_line_id, acct_type, acct_nature, source_name, category_name,
      code_combination_id, entered_dr, entered_cr, transaction_type, period_name,
      created_by, currency_code, currency_conversion_type, currency_conversion_date,
      currency_conversion_rate
    ) VALUES ( JAI_RCV_JOURNAL_ENTRIES_S.nextval,
      v_organization_code, p_receipt_num, p_transaction_id, sysdate, p_transaction_date,
      p_shipment_line_id, p_acct_type, p_acct_nature, p_source, p_category,
      p_code_combination_id, p_entered_dr, p_entered_cr, v_transaction_type, v_period_name,
      p_created_by, p_currency_code, p_currency_conversion_type, p_currency_conversion_date,
      p_currency_conversion_rate
    );


   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;
  END pass_accounting;


  /* Following Procedure added as part of RTV Rounding Resolution. Bug#4103161 */
  PROCEDURE do_rtv_rounding(
    P_ORGANIZATION_ID       IN  NUMBER,
    P_TRANSACTION_TYPE      IN  VARCHAR2,
    P_REGISTER_TYPE         IN  VARCHAR2,
    P_EX_INVOICE_FROM_DATE  IN  DATE,
    P_EX_INVOICE_TO_DATE    IN  DATE
  ) IS

   /* Added by Ramananda for bug#4407165 */
   lv_object_name CONSTANT VARCHAR2(61) := 'jai_rcv_rnd_pkg.do_rtv_rounding';

    TYPE amount_record IS RECORD( basic                NUMBER,
                                  additional           NUMBER,
				  additional_cvd       NUMBER,  /* 5228046  change by sacsethi  */
                                  other                NUMBER,
                                  excise_edu_cess      NUMBER,
                                  cvd_edu_cess         NUMBER,
  				  sh_excise_edu_cess   NUMBER, -- Date 16/04/2007 by
                                  sh_cvd_edu_cess      NUMBER, -- sacsethi for Bug#5989740
                                  total                NUMBER);


    v_zero_record AMOUNT_RECORD;

    v_tot_amount              AMOUNT_RECORD;
    v_tot_rounded_amount      AMOUNT_RECORD;
    v_rounded_amount          AMOUNT_RECORD;

    v_rounded_cr_rg23_amount  AMOUNT_RECORD;
    v_rounded_dr_rg23_amount  AMOUNT_RECORD;
    v_rounded_cr_oth_amount   AMOUNT_RECORD;
    v_rounded_dr_oth_amount   AMOUNT_RECORD;

    v_rounded_amount_abs      NUMBER;
    v_rounded_amount_rg23     NUMBER;
    v_rounded_cr_amount       NUMBER;
    v_rounded_dr_amount       NUMBER;

    v_rounding_entry_type VARCHAR2(2);

    v_commit_interval     NUMBER(5)     ;--File.Sql.35 Cbabu := 50;
    v_rounding_precision  NUMBER(2)     ;--File.Sql.35 Cbabu := 0;
    v_acct_type           VARCHAR2(20)  ;--File.Sql.35 Cbabu := 'REGULAR';
    v_acct_nature         VARCHAR2(20)  ;--File.Sql.35 Cbabu := 'CENVAT-ROUNDING';
    v_source_name         VARCHAR2(20)  ;--File.Sql.35 Cbabu := 'Purchasing India';
    v_category_name       VARCHAR2(20)  ;--File.Sql.35 Cbabu := 'Receiving India';
    v_statement_no        VARCHAR2(4)   ;--File.Sql.35 Cbabu := '0';
    v_err_message         VARCHAR2(100) ;--File.Sql.35 Cbabu := '';

    v_rounding_entries_made   NUMBER    ;--File.Sql.35 Cbabu := 0;
    v_tot_errored_entries     NUMBER    ;--File.Sql.35 Cbabu := 0;
    v_zero_round_found        NUMBER    ;--File.Sql.35 Cbabu := 0;
    v_tot_processed_invoices  NUMBER    ;--File.Sql.35 Cbabu := 0;
    v_no_of_invoices_posted   NUMBER    ;--File.Sql.35 Cbabu := 0;
    v_save_point_set          BOOLEAN   ;--File.Sql.35 Cbabu := FALSE;

    v_fin_year                NUMBER(9);

    v_vendor_id               NUMBER;
    v_vendor_site_id          NUMBER;
    v_rg23_balance            NUMBER;

    v_modvat_rm_account_id    NUMBER(15);
    v_modvat_cg_account_id    NUMBER(15);
    v_modvat_pla_account_id   NUMBER(15);
    v_rg_rounding_account_id  NUMBER(15);

    v_rg_account_id           NUMBER(15);

    v_register_id_part_ii     NUMBER;
    v_rounding_id             NUMBER;

    v_created_by              NUMBER ;--File.Sql.35 Cbabu := nvl(FND_GLOBAL.USER_ID, -1);
    v_last_update_login       NUMBER ;--File.Sql.35 Cbabu := nvl(FND_GLOBAL.LOGIN_ID,- 1);
    v_today                   DATE ;--File.Sql.35 Cbabu := trunc(SYSDATE);

    v_excise_invoice_no       JAI_CMN_RG_23AC_II_TRXS.excise_invoice_no%TYPE;
    v_excise_invoice_date     JAI_CMN_RG_23AC_II_TRXS.excise_invoice_date%TYPE;
    v_register_type           JAI_CMN_RG_23AC_II_TRXS.register_type%TYPE;
    v_line_type_c_cnt         NUMBER ;--File.Sql.35 Cbabu := 0;
    v_tot_lines_cnt           NUMBER ;--File.Sql.35 Cbabu := 0;

    CURSOR c_vendor(p_shipment_header_id IN NUMBER) IS
      SELECT vendor_id, vendor_site_id, receipt_num
      FROM rcv_shipment_headers
      WHERE shipment_header_id = p_shipment_header_id;

    v_slno    NUMBER;
    v_balance NUMBER;

    CURSOR c_slno_balance_rg23p2(p_organization_id IN NUMBER, p_location_id IN NUMBER,
        p_fin_year IN NUMBER, p_register_type IN VARCHAR2) IS
      SELECT slno, closing_balance
      FROM JAI_CMN_RG_23AC_II_TRXS
      WHERE organization_id = p_organization_id
      AND location_id = p_location_id
      AND fin_year = p_fin_year
      AND register_type = p_register_type
      AND slno = (SELECT max(slno) slno
            FROM JAI_CMN_RG_23AC_II_TRXS
            WHERE organization_id = p_organization_id
            AND location_id = p_location_id
            AND fin_year = p_fin_year
            AND register_type = p_register_type);


    CURSOR c_active_fin_year(p_organization_id IN NUMBER) IS
      SELECT max(fin_year)
      FROM JAI_CMN_FIN_YEARS
      WHERE organization_id = p_organization_id
      AND fin_active_flag = 'Y';

    CURSOR c_rg_rounding_account(p_organization_id IN NUMBER) IS
      SELECT rg_rounding_account_id
      FROM JAI_CMN_INVENTORY_ORGS
      WHERE organization_id = p_organization_id
      AND ( location_id IS NULL OR location_id = 0);

    CURSOR c_rg_modvat_account(p_organization_id IN NUMBER, p_location_id IN NUMBER) IS
      SELECT modvat_rm_account_id, modvat_cg_account_id, modvat_pla_account_id
      FROM JAI_CMN_INVENTORY_ORGS
      WHERE organization_id = p_organization_id
      AND location_id = p_location_id;

    ln_receive_qty    NUMBER;
    CURSOR c_ja_in_receive_qty(cp_shipment_line_id IN NUMBER) IS
      SELECT qty_received
      FROM JAI_RCV_LINES
      WHERE shipment_line_id = cp_shipment_line_id;

    --Added the below 2 by Sanjikum for Bug #4049363
    ln_cenvat_amount  AMOUNT_RECORD;
    ln_receive_amount AMOUNT_RECORD;

    CURSOR c_receipt_tax_amount(cp_shipment_line_id IN NUMBER) IS
      SELECT  --Added the 6 columns by Sanjikum for Bug #4049363
        sum(decode(upper(b.tax_type), 'EXCISE', b.tax_amount * nvl(c.mod_cr_percentage, 0), 0) /100) excise_amt,
        sum(decode(upper(b.tax_type), 'ADDL. EXCISE', b.tax_amount * nvl(c.mod_cr_percentage, 0),
                                      'CVD', b.tax_amount * nvl(c.mod_cr_percentage, 0), 0) /100) additional_excise_amt,
        sum(decode(upper(b.tax_type),  jai_constants.tax_type_add_cvd, b.tax_amount * nvl(c.mod_cr_percentage, 0), 0) /100) additional_cvd,/*5228046 Addtional cvd Enhancement*/
	sum(decode(upper(b.tax_type), 'OTHER EXCISE', b.tax_amount * nvl(c.mod_cr_percentage, 0), 0) /100) other_excise_amt,
        sum(decode(b.tax_type, jai_constants.tax_type_exc_edu_cess, b.tax_amount * nvl(c.mod_cr_percentage, 0), 0) /100) excise_edu_cess_amt,
        sum(decode(b.tax_type, jai_constants.tax_type_cvd_edu_cess, b.tax_amount * nvl(c.mod_cr_percentage, 0), 0) /100) cvd_edu_cess_amt ,
        sum(decode(b.tax_type, jai_constants.tax_type_sh_exc_edu_cess, b.tax_amount * nvl(c.mod_cr_percentage, 0), 0) /100) sh_excise_edu_cess_amt, -- Date 16/04/2007 by sacsethi for Bug#5989740
        sum(decode(b.tax_type, jai_constants.tax_type_sh_cvd_edu_cess, b.tax_amount * nvl(c.mod_cr_percentage, 0), 0) /100) sh_cvd_edu_cess_amt
      FROM JAI_RCV_LINE_TAXES b, JAI_CMN_TAXES_ALL c
      WHERE b.shipment_line_id = cp_shipment_line_id
      AND b.tax_id = c.tax_id
      AND upper(b.tax_type) IN ('EXCISE', 'ADDL. EXCISE', 'OTHER EXCISE', 'CVD',JAI_CONSTANTS.tax_type_add_cvd,
                                jai_constants.tax_type_exc_edu_cess, jai_constants.tax_type_cvd_edu_cess,
                                jai_constants.tax_type_sh_exc_edu_cess,jai_constants.tax_type_sh_cvd_edu_cess -- Date 16/04/2007 by sacsethi for Bug#5989740
				)
      AND b.modvat_flag = 'Y';

    v_already_rounded_chk NUMBER;
    v_excise_inv_rnd_cnt  NUMBER;

    CURSOR c_already_rounded_chk(p_source_header_id IN NUMBER, p_excise_invoice_no IN VARCHAR2,
        p_excise_invoice_date IN DATE, p_transaction_type IN VARCHAR2) IS
      SELECT  max(rounding_id) rounding_id,
              count(1)
      FROM    JAI_CMN_RG_ROUND_HDRS
      WHERE   source_header_id = p_source_header_id
      AND     excise_invoice_no = p_excise_invoice_no
      AND     excise_invoice_date = p_excise_invoice_date
      AND     src_transaction_type = p_transaction_type
      GROUP BY rounding_id, excise_invoice_no, excise_invoice_date;

    /*Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. */
    ln_rtv_excise_batch_group_id    jai_rcv_rtv_batch_trxs.excise_batch_group_id%TYPE;
    CURSOR c_excise_batch_group_id(cpn_transaction_id number) IS
      select excise_batch_group_id
      from jai_rcv_rtv_batch_trxs
      where transaction_id = cpn_transaction_id;

    v_no_of_periods_updated NUMBER(15);
    v_period_balance_id     NUMBER(15);

    v_exc_inv_rnd_counter   NUMBER ;--File.Sql.35 Cbabu := 0;

    lv_process_status   VARCHAR2(3);
    lv_process_message  VARCHAR2(1996);
    v_receipt_num       rcv_shipment_headers.receipt_num%TYPE;
    v_pla_register_id   NUMBER;

    lv_ttype_correct 	JAI_RCV_TRANSACTIONS.transaction_type%type ;

  BEGIN

  v_statement_no := '0.1';
    v_commit_interval     := 50;
    v_rounding_precision  := 0;
    v_acct_type           := 'REGULAR';
    v_acct_nature         := 'CENVAT-ROUNDING';
    v_source_name         := 'Purchasing India';
    v_category_name       := 'Receiving India';
    v_statement_no        := '0';
    v_err_message         := '';
    v_rounding_entries_made   := 0;
    v_tot_errored_entries     := 0;
    v_zero_round_found        := 0;
    v_tot_processed_invoices  := 0;
    v_no_of_invoices_posted   := 0;
    v_save_point_set          := FALSE;
    v_created_by              := nvl(FND_GLOBAL.USER_ID, -1);
    v_last_update_login       := nvl(FND_GLOBAL.LOGIN_ID,- 1);
    v_today                   := trunc(SYSDATE);
    v_line_type_c_cnt         := 0;
    v_tot_lines_cnt           := 0;
    v_exc_inv_rnd_counter     := 0;

  if gb_debug then
    fnd_file.put_line(fnd_file.log, '-1-Start of Procedure');
  end if;

  OPEN c_rg_rounding_account(p_organization_id);
  FETCH c_rg_rounding_account INTO v_rg_rounding_account_id;
  CLOSE c_rg_rounding_account;

  v_statement_no := '0.2';

  IF v_rg_rounding_account_id IS NULL THEN
    fnd_file.put_line(fnd_file.log, 'ERROR: Rounding Account is not specified at Organization Level');
    RAISE_APPLICATION_ERROR( -20099, 'Rounding Account is not specified at Organization Level');
  END IF;

  v_statement_no := '0.3';

  OPEN c_active_fin_year(p_organization_id);
  FETCH c_active_fin_year INTO v_fin_year;
  CLOSE c_active_fin_year;

  --Added by Sanjikum for Bug #4049363
  v_zero_record.basic := 0;
  v_zero_record.additional := 0;
  v_zero_record.additional_cvd := 0;/*5228046 Addtional cvd Enhancement*/
  v_zero_record.other := 0;
  v_zero_record.excise_edu_cess := 0;
  v_zero_record.cvd_edu_cess := 0;
  v_zero_record.total := 0;

  v_tot_amount := v_zero_record;

  if gb_debug then
    fnd_file.put_line(fnd_file.log, '0-Before MAIN LOOP');
  end if;

  -- PART II A, C rounding entries can be posted into one of the Registers A or C
  lv_ttype_correct := 'CORRECT' ;
  FOR r IN (
        select
          LV_RG23_REGISTER                register,
          -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. b.shipment_header_id            shipment_header_id,
          min(b.shipment_header_id)            min_shipment_header_id,    -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
          count( distinct shipment_header_id)   cnt_shipment_header_id,   -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
          a.excise_invoice_no             excise_invoice_no,
          a.excise_invoice_date           excise_invoice_date,
          a.vendor_id                     Vendor_id,/*bgowrava for forward porting bug#5674376*/
          a.vendor_site_id                vendor_site_id,/*bgowrava for forward porting bug#5674376*/
          p_transaction_type              transaction_type,
          max(to_number(a.RECEIPT_REF))    rcv_transaction_id,
          min(a.location_id)              location_id,
          nvl(sum(a.cr_basic_ed), 0)      cr_basic_ed,
          nvl(sum(a.cr_additional_ed), 0) cr_additional_ed,
          nvl(sum(a.cr_additional_cvd),0) cr_additional_cvd,/*5228046 Addtional cvd Enhancement*/
          nvl(sum(a.cr_other_ed), 0)      cr_other_ed,
          nvl(sum(a.dr_basic_ed), 0)      dr_basic_ed,
          nvl(sum(a.dr_additional_ed), 0) dr_additional_ed,
          nvl(sum(a.dr_additional_cvd),0) dr_additional_cvd,/*5228046 Addtional cvd Enhancement*/
          nvl(sum(a.dr_other_ed), 0)      dr_other_ed,
          nvl(sum( decode(c.tax_type, 'EXCISE_EDUCATION_CESS', c.credit, 0)), 0)  cr_exc_edu_cess,
          nvl(sum( decode(c.tax_type, 'CVD_EDUCATION_CESS', c.credit, 0)), 0)     cr_cvd_edu_cess,
          nvl(sum( decode(c.tax_type, jai_constants.tax_type_sh_exc_edu_cess, c.credit, 0)), 0)  cr_sh_exc_edu_cess, -- Date 16/04/2007 by sacsethi for Bug#5989740
          nvl(sum( decode(c.tax_type, jai_constants.tax_type_sh_cvd_edu_cess, c.credit, 0)), 0)  cr_sh_cvd_edu_cess,
	  nvl(sum( decode(c.tax_type, 'EXCISE_EDUCATION_CESS', c.debit, 0)), 0)                  dr_exc_edu_cess,
          nvl(sum( decode(c.tax_type, 'CVD_EDUCATION_CESS', c.debit, 0)), 0)                     dr_cvd_edu_cess,
          nvl(sum( decode(c.tax_type, jai_constants.tax_type_sh_exc_edu_cess, c.debit, 0)), 0)   dr_sh_exc_edu_cess, -- Date 16/04/2007 by sacsethi for Bug#5989740
          nvl(sum( decode(c.tax_type, jai_constants.tax_type_sh_cvd_edu_cess, c.debit, 0)), 0)   dr_sh_cvd_edu_cess,
          null transaction_date
        -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. from JAI_CMN_RG_23AC_II_TRXS a, rcv_transactions b, JAI_CMN_RG_OTHERS c
        from JAI_CMN_RG_23AC_II_TRXS a, JAI_RCV_TRANSACTIONS b, JAI_CMN_RG_OTHERS c
        where a.RECEIPT_REF = b.transaction_id
        AND a.organization_id = p_organization_id
        AND c.source_type(+) = 1  -- this means register is JAI_CMN_RG_23AC_II_TRXS
        AND a.register_id = c.source_register_id(+)
        AND (
            (p_ex_invoice_from_date IS NULL AND p_ex_invoice_to_date IS NULL)
          OR  (p_ex_invoice_from_date IS NOT NULL AND p_ex_invoice_to_date IS NULL
              AND a.excise_invoice_date >= p_ex_invoice_from_date)
          OR  (p_ex_invoice_from_date IS NULL AND p_ex_invoice_to_date IS NOT NULL
              AND a.excise_invoice_date <= p_ex_invoice_to_date)
          OR  (p_ex_invoice_from_date IS NOT NULL AND p_ex_invoice_to_date IS NOT NULL
              AND a.excise_invoice_date BETWEEN p_ex_invoice_from_date AND p_ex_invoice_to_date)
        )
        AND a.rounding_id IS NULL
        AND a.TRANSACTION_SOURCE_NUM = 18
        AND ( (b.transaction_type = p_transaction_type)
              or (b.transaction_type = lv_ttype_correct and b.parent_transaction_type = p_transaction_type --'CORRECT'
                  /* Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. exists (select 1 from JAI_RCV_TRANSACTIONS
                                       where transaction_id = b.parent_transaction_id
                                       and transaction_type = p_transaction_type)*/
                  )
            )
        -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. GROUP BY b.shipment_header_id, a.excise_invoice_no, a.excise_invoice_date
        GROUP BY a.excise_invoice_no, a.excise_invoice_date,
        a.vendor_id       ,  /*bgowrava for forward porting bug#5674376*/
      	a.vendor_site_id  /*bgowrava for forward porting bug#5674376*/
       UNION ALL
        select
          LV_PLA_REGISTER                 register,
          -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. b.shipment_header_id            shipment_header_id,
          min(b.shipment_header_id)            min_shipment_header_id,    -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
          count( distinct shipment_header_id)   cnt_shipment_header_id,   -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
          a.DR_INVOICE_NO                 excise_invoice_no,
          a.dr_invoice_date               excise_invoice_date,
          a.vendor_id                     Vendor_id,/*bgowrava for forward porting bug#5674376*/
          a.vendor_site_id                vendor_site_id,/*bgowrava for forward porting bug#5674376*/
          p_transaction_type              transaction_type,
          max(to_number(ref_document_id)) rcv_transaction_id,
          min(a.location_id)              location_id,
          nvl(sum(a.cr_basic_ed),0)       cr_basic_ed,
          nvl(sum(a.cr_additional_ed), 0) cr_additional_ed,
          to_number(null)                 cr_additional_cvd,   /*5228046 Addtional cvd Enhancement*/
          nvl(sum(a.cr_other_ed), 0)      cr_other_ed,
          nvl(sum(a.dr_basic_ed), 0)      dr_basic_ed,
          nvl(sum(a.dr_additional_ed), 0) dr_additional_ed,
          to_number(null)                 dr_additional_cvd,   /*5228046 Addtional cvd Enhancement*/
          nvl(sum(a.dr_other_ed), 0)      dr_other_ed,
          nvl(sum( decode(c.tax_type, 'EXCISE_EDUCATION_CESS', c.credit, 0)), 0)  cr_exc_edu_cess,
          nvl(sum( decode(c.tax_type, 'CVD_EDUCATION_CESS', c.credit, 0)), 0)     cr_cvd_edu_cess,
-- Date 16/04/2007 by sacsethi for Bug#5989740
	  nvl(sum( decode(c.tax_type, 'EXCISE_SH_EDU_CESS', c.credit, 0)), 0)  cr_sh_exc_edu_cess,
          nvl(sum( decode(c.tax_type, 'CVD_SH_EDU_CESS', c.credit, 0)), 0)     cr_sh_cvd_edu_cess,
-- end
          nvl(sum( decode(c.tax_type, 'EXCISE_EDUCATION_CESS', c.debit, 0)), 0)   dr_exc_edu_cess,
          nvl(sum( decode(c.tax_type, 'CVD_EDUCATION_CESS', c.debit, 0)), 0)      dr_cvd_edu_cess,
-- Date 16/04/2007 by sacsethi for Bug#5989740
          nvl(sum( decode(c.tax_type, 'EXCISE_SH_EDU_CESS', c.debit, 0)), 0)   dr_sh_exc_edu_cess,
          nvl(sum( decode(c.tax_type, 'CVD_SH_EDU_CESS', c.debit, 0)), 0)      dr_sh_cvd_edu_cess,
-- end
          max(a.transaction_date)                                                 transaction_date
        -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. from JAI_CMN_RG_PLA_TRXS a, rcv_transactions b, JAI_CMN_RG_OTHERS c
        from JAI_CMN_RG_PLA_TRXS a, JAI_RCV_TRANSACTIONS b, JAI_CMN_RG_OTHERS c
        where a.ref_document_id = b.transaction_id
        AND a.organization_id = p_organization_id
        AND c.source_type(+) = 2  -- this means register is JAI_CMN_RG_PLA_TRXS
        AND a.register_id = c.source_register_id(+)
        AND (
            (p_ex_invoice_from_date IS NULL AND p_ex_invoice_to_date IS NULL)
          OR  (p_ex_invoice_from_date IS NOT NULL AND p_ex_invoice_to_date IS NULL
              AND a.dr_invoice_date >= p_ex_invoice_from_date)
          OR  (p_ex_invoice_from_date IS NULL AND p_ex_invoice_to_date IS NOT NULL
              AND a.dr_invoice_date <= p_ex_invoice_to_date)
          OR  (p_ex_invoice_from_date IS NOT NULL AND p_ex_invoice_to_date IS NOT NULL
              AND a.dr_invoice_date BETWEEN p_ex_invoice_from_date AND p_ex_invoice_to_date)
        )
        AND a.rounding_id IS NULL
        AND a.TRANSACTION_SOURCE_NUM = 19
        AND ( (b.transaction_type = p_transaction_type)
              or (b.transaction_type = 'CORRECT' and b.parent_transaction_type = p_transaction_type
                  /*Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. exists (select 1 from JAI_RCV_TRANSACTIONS
                                       where transaction_id = b.parent_transaction_id
                                       and transaction_type = p_transaction_type)*/
                  )
            )
        -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. GROUP BY b.shipment_header_id, a.DR_INVOICE_NO, a.dr_invoice_date
        GROUP BY a.DR_INVOICE_NO, a.dr_invoice_date,
        a.vendor_id       ,  /*bgowrava for forward porting bug#5674376*/
      	a.vendor_site_id  /*bgowrava for forward porting bug#5674376*/
        -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. ORDER BY shipment_header_id
        ORDER BY rcv_transaction_id
       )
  LOOP

    BEGIN

      if gb_debug then
        fnd_file.put_line(fnd_file.log, '0-Amts: crBas:'||r.cr_basic_ed
          ||', crAdd:'||r.cr_additional_ed||', crOth:'||r.cr_other_ed
          ||', crExcEdu:'||r.cr_exc_edu_cess||', crCvdEdu:'||r.cr_cvd_edu_cess
          ||', drBas:'||r.dr_basic_ed
          ||', drAdd:'||r.dr_additional_ed||', drOth:'||r.dr_other_ed
          ||', drExcEdu:'||r.dr_exc_edu_cess||', drCvdEdu:'||r.dr_cvd_edu_cess
        );
      end if;

      v_statement_no := '1';
      v_excise_invoice_no       := r.excise_invoice_no;
      v_excise_invoice_date     := r.excise_invoice_date;

      v_excise_inv_rnd_cnt      := 0;

      v_already_rounded_chk     := null;
      v_period_balance_id       := null;
      v_no_of_periods_updated   := null;

      /* Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. */
      ln_rtv_excise_batch_group_id    := null;
      open c_excise_batch_group_id(r.rcv_transaction_id);
      fetch c_excise_batch_group_id into ln_rtv_excise_batch_group_id;
      close c_excise_batch_group_id;

      v_statement_no := '1.1';
      v_already_rounded_chk := NULL;
      -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. OPEN c_already_rounded_chk(v_shipment_header_id, v_excise_invoice_no, v_excise_invoice_date, r.transaction_type);
      OPEN c_already_rounded_chk(ln_rtv_excise_batch_group_id, v_excise_invoice_no,
                                 v_excise_invoice_date, r.transaction_type);
      FETCH c_already_rounded_chk INTO
            v_already_rounded_chk,
            v_excise_inv_rnd_cnt;
      CLOSE c_already_rounded_chk;

      IF v_already_rounded_chk IS NOT NULL THEN

        v_statement_no := '1.3';
        SAVEPOINT previous_savepoint;
        v_save_point_set := TRUE;

        if gb_debug then
          fnd_file.put_line(fnd_file.log, '1-Before Update of Register');
        end if;

        if r.register = LV_RG23_REGISTER then
          v_statement_no := '1.2';
          UPDATE JAI_CMN_RG_23AC_II_TRXS jcrg23ac
          SET jcrg23ac.rounding_id = v_already_rounded_chk
          WHERE jcrg23ac.excise_invoice_no = v_excise_invoice_no
          AND jcrg23ac.excise_invoice_date = v_excise_invoice_date
          AND nvl(vendor_id,-999) = nvl(r.vendor_id,-999)/*bgowrava for forward porting bug#5674376*/
				  AND nvl(vendor_site_id,-999) = nvl(r.vendor_site_id,-999)/*bgowrava for forward porting bug#5674376*/
          AND jcrg23ac.organization_id = p_organization_id
          AND jcrg23ac.rounding_id IS NULL
          AND jcrg23ac.transaction_source_num = 18
          AND exists (select 1 from JAI_RCV_TRANSACTIONS jrt
	    /* Bug 4930048. Added by Lakshmi Gopalsami
	       Changed transaction_source_num to transaction_id
	    */
            where jrt.transaction_id =  jcrg23ac.receipt_ref
            and (jrt.transaction_type = p_transaction_type or
	         jrt.parent_transaction_type = p_transaction_type) );

        elsif r.register = LV_PLA_REGISTER then

          v_statement_no := '1.2';
          UPDATE JAI_CMN_RG_PLA_TRXS jcpla
          SET jcpla.rounding_id = v_already_rounded_chk
          WHERE jcpla.DR_INVOICE_NO = v_excise_invoice_no
          AND jcpla.dr_invoice_date = v_excise_invoice_date
          AND nvl(vendor_id,-999) = nvl(r.vendor_id,-999)/*bgowrava for forward porting bug#5674376*/
          AND nvl(vendor_site_id,-999) = nvl(r.vendor_site_id,-999)/*bgowrava for forward porting bug#5674376*/
          AND jcpla.organization_id = p_organization_id
          AND jcpla.rounding_id IS NULL
          AND jcpla.TRANSACTION_SOURCE_NUM = 19
          AND exists (select 1 from JAI_RCV_TRANSACTIONS jrt
  	    /* Bug 4930048. Added by Lakshmi Gopalsami
	       Changed transaction_source_num to transaction_id
	    */
            where jrt.transaction_id = jcpla.ref_document_id
            and (jrt.transaction_type = p_transaction_type or
	         jrt.parent_transaction_type = p_transaction_type) );
        end if;

        fnd_file.put_line(fnd_file.log, '+++++ Ex. Invoice Already rounded +++++');
        GOTO next_exc_inv;

      END IF;

      v_tot_processed_invoices := v_tot_processed_invoices + 1;

      v_statement_no := '1.4';
      SELECT JAI_CMN_RG_ROUND_HDRS_S.nextval INTO v_rounding_id FROM dual;

      v_line_type_c_cnt := 0;
      v_tot_lines_cnt := 0;
      v_tot_amount := v_zero_record;

      v_statement_no := '1.4';
      FOR line IN ( SELECT a.shipment_line_id, a.transaction_id, a.item_class,
                          a.transaction_type, a.parent_transaction_type, a.quantity
                    FROM JAI_RCV_TRANSACTIONS a,
                    JAI_RCV_CENVAT_CLAIMS b,/*bgowrava for forward porting bug#5674376*/
                         RCV_TRANSACTIONS c,/*bgowrava for forward porting bug#5674376*/
                       jai_rcv_rtv_batch_trxs d
                    -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. WHERE a.shipment_header_id = v_shipment_header_id
                    WHERE a.transaction_id = d.transaction_id       -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
                    and d.excise_batch_group_id = ln_rtv_excise_batch_group_id    -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
                    AND (a.transaction_type = p_transaction_type
                          or (a.transaction_type = 'CORRECT' and a.parent_transaction_type = p_transaction_type))
                     AND (
															(nvl(b.vendor_id,-999)          = nvl(r.vendor_id,-999)
															AND nvl(b.vendor_site_id,-999) = nvl(r.vendor_site_id,-999)
															AND b.vendor_changed_flag      = 'Y' )
															OR
															(nvl(c.vendor_id,-999)      = nvl(r.vendor_id,-999)
															AND nvl(c.vendor_site_id,-999) = nvl(r.vendor_site_id,-999)
															AND b.vendor_changed_flag      = 'N' )
													 ) /*bgowrava for forward porting bug#5674376*/
                    AND a.excise_invoice_no = v_excise_invoice_no
                    AND a.excise_invoice_date = v_excise_invoice_date
                  )
      LOOP

        ln_receive_amount := v_zero_record;

        ln_receive_qty := 0;

        OPEN c_ja_in_receive_qty(line.shipment_line_id);
        FETCH c_ja_in_receive_qty INTO ln_receive_qty;
        CLOSE c_ja_in_receive_qty;

        OPEN c_receipt_tax_amount(line.shipment_line_id);
        FETCH c_receipt_tax_amount INTO
                                        ln_receive_amount.basic,
                                        ln_receive_amount.additional,
                                        ln_receive_amount.additional_cvd,/*5228046 Addtional cvd Enhancement*/
					ln_receive_amount.other,
                                        ln_receive_amount.excise_edu_cess,
                                        ln_receive_amount.cvd_edu_cess,
                                        ln_receive_amount.sh_excise_edu_cess, -- Date 16/04/2007 by sacsethi for Bug#5989740
                                        ln_receive_amount.sh_cvd_edu_cess ;
        CLOSE c_receipt_tax_amount;

        fnd_file.put_line(fnd_file.log, 'TrxId:'||line.transaction_id ||', RecvQty->'||ln_receive_qty);

        ln_cenvat_amount.basic            := ln_receive_amount.basic * line.quantity/ln_receive_qty;
        ln_cenvat_amount.additional       := ln_receive_amount.additional * line.quantity/ln_receive_qty;
        ln_cenvat_amount.additional_cvd   := nvl(ln_receive_amount.additional_cvd,0) * line.quantity/ln_receive_qty;/*5228046 Addtional cvd Enhancement*/
	ln_cenvat_amount.other            := ln_receive_amount.other * line.quantity/ln_receive_qty;
        ln_cenvat_amount.excise_edu_cess  := ln_receive_amount.excise_edu_cess * line.quantity/ln_receive_qty;
        ln_cenvat_amount.cvd_edu_cess     := ln_receive_amount.cvd_edu_cess * line.quantity/ln_receive_qty;
-- Date 16/04/2007 by sacsethi for Bug#5989740
        ln_cenvat_amount.sh_excise_edu_cess  := nvl(ln_receive_amount.sh_excise_edu_cess,0) * line.quantity/ln_receive_qty;
        ln_cenvat_amount.sh_cvd_edu_cess     := nvl(ln_receive_amount.sh_cvd_edu_cess,0) * line.quantity/ln_receive_qty;
-- end 5989740

        ln_cenvat_amount.total  :=
              NVL(ln_cenvat_amount.basic,0)
              + NVL(ln_cenvat_amount.additional,0)
              + NVL(ln_cenvat_amount.additional_cvd,0)/*5228046 Addtional cvd Enhancement*/
	      + NVL(ln_cenvat_amount.other,0)
              + NVL(ln_cenvat_amount.excise_edu_cess,0)
              + NVL(ln_cenvat_amount.cvd_edu_cess,0)
              + NVL(ln_cenvat_amount.sh_excise_edu_cess,0)-- Date 16/04/2007 by sacsethi for Bug#5989740
              + NVL(ln_cenvat_amount.sh_cvd_edu_cess,0) ;

        v_statement_no := '1.5';

        if gb_debug then
          fnd_file.put_line(fnd_file.log, '2-Before Insert into Entry Lines');
        end if;

          -- populate item class
        INSERT INTO JAI_CMN_RG_ROUND_LINES (ROUNDING_LINE_ID,
          ROUNDING_ID, SRC_LINE_ID, SRC_TRANSACTION_ID,
          EXCISE_AMT,
          BASIC_ED, ADDITIONAL_ED,ADDITIONAL_CVD ,  OTHER_ED,
          EXCISE_EDU_CESS, CVD_EDU_CESS,
          sh_excise_edu_cess, sh_cvd_edu_cess, -- Date 16/04/2007 by sacsethi for Bug#5989740
          ITEM_CLASS, CREATION_DATE, CREATED_BY,
	  program_application_id, program_id, program_login_id, request_id
        ) VALUES ( JAI_CMN_RG_ROUND_LINES_S.nextval,
          v_rounding_id, line.shipment_line_id, line.transaction_id,
          ln_cenvat_amount.total,
          ln_cenvat_amount.basic,
	  ln_cenvat_amount.additional,
	  ln_cenvat_amount.additional_cvd,/*5228046 Addtional cvd Enhancement*/
	  ln_cenvat_amount.other,
          ln_cenvat_amount.excise_edu_cess, ln_cenvat_amount.cvd_edu_cess,
          ln_cenvat_amount.sh_excise_edu_cess, ln_cenvat_amount.sh_cvd_edu_cess, -- Date 16/04/2007 by sacsethi for Bug#5989740
          line.item_class, SYSDATE, v_created_by,
	  fnd_profile.value('PROG_APPL_ID'), fnd_profile.value('CONC_PROGRAM_ID'), fnd_profile.value('CONC_LOGIN_ID'), fnd_profile.value('CONC_REQUEST_ID')
        );

        v_tot_amount.basic            := v_tot_amount.basic             +  ln_cenvat_amount.basic;
        v_tot_amount.additional       := v_tot_amount.additional        +  ln_cenvat_amount.additional;
        v_tot_amount.additional_cvd   := v_tot_amount.additional_cvd    +  nvl(ln_cenvat_amount.additional_cvd,0);/*Added by SACSETHI for the bug 5228046
                                                                                                                   -Additional CVD Enhancement*/

        v_tot_amount.other            := v_tot_amount.other             +  ln_cenvat_amount.other;
        v_tot_amount.excise_edu_cess  := v_tot_amount.excise_edu_cess   +  ln_cenvat_amount.excise_edu_cess;
        v_tot_amount.cvd_edu_cess     := v_tot_amount.cvd_edu_cess      +  ln_cenvat_amount.cvd_edu_cess;

-- Date 16/04/2007 by sacsethi for Bug#5989740
	v_tot_amount.sh_excise_edu_cess  := v_tot_amount.sh_excise_edu_cess   +  ln_cenvat_amount.sh_excise_edu_cess;
        v_tot_amount.sh_cvd_edu_cess     := v_tot_amount.sh_cvd_edu_cess      +  ln_cenvat_amount.sh_cvd_edu_cess;
-- end 5989740

        v_tot_amount.total            := NVL(v_tot_amount.basic,0) +
					 NVL(v_tot_amount.additional,0) +
                                         NVL(v_tot_amount.additional_cvd,0) + /*5228046 Additional cvd Enhancement*/
					 NVL(v_tot_amount.other,0) +
					 NVL(v_tot_amount.excise_edu_cess,0) +
					 NVL(v_tot_amount.cvd_edu_cess,0) +
					 NVL(v_tot_amount.sh_excise_edu_cess,0) +  -- Date 16/04/2007 by sacsethi for Bug#5989740
					 NVL(v_tot_amount.sh_cvd_edu_cess,0);


        if line.transaction_type = p_transaction_type or line.parent_transaction_type = p_transaction_type then
          IF line.item_class IN ('CGIN', 'CGEX') THEN
            v_line_type_c_cnt := v_line_type_c_cnt + 1;
          END IF;
          v_tot_lines_cnt := v_tot_lines_cnt + 1;
        end if;

      END LOOP;

      v_statement_no := '1.6';
      IF v_line_type_c_cnt = v_tot_lines_cnt THEN
        v_register_type := 'C';
      ELSIF v_line_type_c_cnt = 0 THEN
        v_register_type := 'A';
      ELSE
        v_register_type := p_register_type;
      END IF;

      v_tot_amount.basic            := -r.cr_basic_ed + r.dr_basic_ed;
      v_tot_amount.additional       := -r.cr_additional_ed + r.dr_additional_ed;
      v_tot_amount.additional_cvd   := -r.cr_additional_cvd + r.dr_additional_cvd;/*Added by SACSETHI for the bug 5228046 -Additional CVD Enhancement*/
      v_tot_amount.other            := -r.cr_other_ed + r.dr_other_ed;
      v_tot_amount.excise_edu_cess  := -r.cr_exc_edu_cess + r.dr_exc_edu_cess;
      v_tot_amount.cvd_edu_cess     := -r.cr_cvd_edu_cess + r.dr_cvd_edu_cess;

-- Date 16/04/2007 by sacsethi for Bug#5989740
-- start
      v_tot_amount.sh_excise_edu_cess  := -r.cr_sh_exc_edu_cess + r.dr_sh_exc_edu_cess;
      v_tot_amount.sh_cvd_edu_cess     := -r.cr_sh_cvd_edu_cess + r.dr_sh_cvd_edu_cess;
-- end

      v_tot_amount.total  := NVL(v_tot_amount.basic,0) +
                             NVL(v_tot_amount.additional,0) +
                             NVL(v_tot_amount.additional_cvd,0) + /*Added by SACSETHI for the bug 5228046 -Additional CVD Enhancement*/
			     NVL(v_tot_amount.other,0) +
			     NVL(v_tot_amount.excise_edu_cess,0) +
			     NVL(v_tot_amount.cvd_edu_cess,0)+
			     NVL(v_tot_amount.sh_excise_edu_cess,0) +  -- Date 16/04/2007 by sacsethi for Bug#5989740
                             NVL(v_tot_amount.sh_cvd_edu_cess,0);
      if gb_debug then
        fnd_file.put_line(fnd_file.log, '2.1-Amts: tBas:'||v_tot_amount.basic
          ||', tAdd:'||v_tot_amount.additional||', tOth:'||v_tot_amount.other
          ||', tAdditional_cvd:'||v_tot_amount.additional_cvd /*5228046 Addtional cvd Enhancement*/
          ||', tExcEdu:'||v_tot_amount.excise_edu_cess||', tCvdEdu:'||v_tot_amount.cvd_edu_cess
          ||', tAmt:'||v_tot_amount.total
        );
      end if;

      fnd_file.put_line(fnd_file.log, 'Started Processing rtvExcBtchGrpId->'||ln_rtv_excise_batch_group_id
          ||', excise_invoice_no->'||v_excise_invoice_no
          ||', excise_invoice_date->'||v_excise_invoice_date
      );

      v_statement_no := '2';

      v_tot_rounded_amount.basic            := ROUND(v_tot_amount.basic, v_rounding_precision);
      v_rounded_amount.basic                := v_tot_rounded_amount.basic - v_tot_amount.basic;

      v_tot_rounded_amount.additional       := ROUND(v_tot_amount.additional, v_rounding_precision);
      v_rounded_amount.additional           := v_tot_rounded_amount.additional - v_tot_amount.additional;

    /*5228046 Addtional cvd Enhancement*/
      v_tot_rounded_amount.additional_cvd   := ROUND(v_tot_amount.additional_cvd, v_rounding_precision);
      v_rounded_amount.additional_cvd       := v_tot_rounded_amount.additional_cvd - v_tot_amount.additional_cvd;


      v_tot_rounded_amount.other            := ROUND(v_tot_amount.other, v_rounding_precision);
      v_rounded_amount.other                := v_tot_rounded_amount.other - v_tot_amount.other;

      v_tot_rounded_amount.excise_edu_cess  := ROUND(v_tot_amount.excise_edu_cess, v_rounding_precision);
      v_rounded_amount.excise_edu_cess      := v_tot_rounded_amount.excise_edu_cess - v_tot_amount.excise_edu_cess;

      v_tot_rounded_amount.cvd_edu_cess     := ROUND(v_tot_amount.cvd_edu_cess, v_rounding_precision);
      v_rounded_amount.cvd_edu_cess         := v_tot_rounded_amount.cvd_edu_cess - v_tot_amount.cvd_edu_cess;

-- Date 16/04/2007 by sacsethi for Bug#5989740
-- start 5989740

      v_tot_rounded_amount.sh_excise_edu_cess  := ROUND(v_tot_amount.sh_excise_edu_cess, v_rounding_precision);
      v_rounded_amount.sh_excise_edu_cess      := v_tot_rounded_amount.sh_excise_edu_cess - v_tot_amount.sh_excise_edu_cess;

      v_tot_rounded_amount.sh_cvd_edu_cess     := ROUND(v_tot_amount.sh_cvd_edu_cess, v_rounding_precision);
      v_rounded_amount.sh_cvd_edu_cess         := v_tot_rounded_amount.sh_cvd_edu_cess - v_tot_amount.sh_cvd_edu_cess;

-- end 5989740

      v_tot_rounded_amount.total :=
                NVL(v_tot_rounded_amount.basic,0)
                + NVL(v_tot_rounded_amount.additional,0)
                + NVL(v_tot_rounded_amount.additional_cvd,0)  /*5228046 Additional cvd Enhancement*/
		+ NVL(v_tot_rounded_amount.other,0)
                + NVL(v_tot_rounded_amount.excise_edu_cess,0)
                + NVL(v_tot_rounded_amount.cvd_edu_cess,0)
                + NVL(v_tot_rounded_amount.sh_excise_edu_cess,0)  -- Date 16/04/2007 by sacsethi for Bug#5989740
                + NVL(v_tot_rounded_amount.sh_cvd_edu_cess,0);

      v_rounded_amount.total :=
                  NVL(v_rounded_amount.basic,0)
                + NVL(v_rounded_amount.additional,0)
                + NVL(v_rounded_amount.additional_cvd,0)              /*5228046 Additional cvd Enhancement*/
                + NVL(v_rounded_amount.other,0)
                + NVL(v_rounded_amount.excise_edu_cess,0)
                + NVL(v_rounded_amount.cvd_edu_cess,0)
                + NVL(v_rounded_amount.sh_excise_edu_cess,0)  -- Date 16/04/2007 by sacsethi for Bug#5989740
                + NVL(v_rounded_amount.sh_cvd_edu_cess,0);

      v_rounded_amount_rg23 :=
                NVL(v_rounded_amount.basic,0)
                + NVL(v_rounded_amount.additional,0)
                + NVL(v_rounded_amount.additional_cvd,0)/*5228046 Additional cvd Enhancement*/
                + NVL(v_rounded_amount.other,0);

      if gb_debug then
        fnd_file.put_line(fnd_file.log, '2.2-Amts: rBas:'||v_rounded_amount.basic
          ||', rAdd:'||v_rounded_amount.additional||', rOth:'||v_rounded_amount.other
          ||', rAdd_cvd:'||v_rounded_amount.additional_cvd /*5228046 Additional cvd Enhancement*/
          ||', rExcEdu:'||v_rounded_amount.excise_edu_cess||', rCvdEdu:'||v_rounded_amount.cvd_edu_cess
        );
      end if;

      v_rounded_amount_abs :=
                ABS(NVL(v_rounded_amount.basic,0)) +
                ABS(NVL(v_rounded_amount.additional,0)) +
                ABS(NVL(v_rounded_amount.additional_cvd,0)) +      /*5228046 Additional cvd Enhancement*/
		ABS(NVL(v_rounded_amount.other,0)) +
                ABS(NVL(v_rounded_amount.excise_edu_cess,0)) +
                ABS(NVL(v_rounded_amount.cvd_edu_cess,0)) +
                ABS(NVL(v_rounded_amount.sh_excise_edu_cess,0)) + -- Date 16/04/2007 by sacsethi for Bug#5989740
		ABS(NVL(v_rounded_amount.sh_cvd_edu_cess,0));

      v_statement_no := '3';

      /* Punching Rounding_Id as 0 for RG transactions where in no Rounding is Required */
      IF v_rounded_amount_abs = 0 THEN
        v_zero_round_found := v_zero_round_found + 1;

        if gb_debug then
          fnd_file.put_line(fnd_file.log, '3-Before Update of Register with 0 Rounding');
        end if;

        if r.register = LV_RG23_REGISTER then
          UPDATE JAI_CMN_RG_23AC_II_TRXS aa
            SET rounding_id = 0
          WHERE organization_id = p_organization_id
          AND excise_invoice_no = v_excise_invoice_no
          AND excise_invoice_date = v_excise_invoice_date
          AND nvl(vendor_id,-999) = nvl(r.vendor_id,-999)/*bgowrava for forward porting bug#5674376*/
          AND nvl(vendor_site_id,-999) = nvl(r.vendor_site_id,-999)/*bgowrava for forward porting bug#5674376*/
          AND rounding_id IS NULL
          AND TRANSACTION_SOURCE_NUM = 18
          AND EXISTS (
              SELECT 1 FROM JAI_RCV_TRANSACTIONS bb, jai_rcv_rtv_batch_trxs b1
              -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. WHERE BB.shipment_header_id = v_shipment_header_id
              WHERE bb.transaction_id = b1.transaction_id       -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
              and b1.excise_batch_group_id = ln_rtv_excise_batch_group_id    -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
              AND bb.transaction_id = aa.receipt_ref
              AND ( bb.transaction_type = r.transaction_type or bb.parent_transaction_type = r.transaction_type)
          );

        elsif r.register = LV_PLA_REGISTER then

          UPDATE JAI_CMN_RG_PLA_TRXS aa
            SET rounding_id = 0
          WHERE organization_id = p_organization_id
          AND DR_INVOICE_NO = v_excise_invoice_no
          AND dr_invoice_date = v_excise_invoice_date
          AND nvl(vendor_id,-999) = nvl(r.vendor_id,-999)/*bgowrava for forward porting bug#5674376*/
          AND nvl(vendor_site_id,-999) = nvl(r.vendor_site_id,-999)/*bgowrava for forward porting bug#5674376*/
          AND rounding_id IS NULL
          AND TRANSACTION_SOURCE_NUM = 19
          AND EXISTS (
              SELECT 1 FROM JAI_RCV_TRANSACTIONS bb, jai_rcv_rtv_batch_trxs b1
              -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. WHERE BB.shipment_header_id = v_shipment_header_id
              WHERE bb.transaction_id = b1.transaction_id       -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
              and b1.excise_batch_group_id = ln_rtv_excise_batch_group_id    -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
              AND bb.transaction_id = aa.ref_document_id
              AND ( bb.transaction_type = r.transaction_type or bb.parent_transaction_type = r.transaction_type)
          );

        end if;

        DELETE FROM JAI_CMN_RG_ROUND_LINES WHERE rounding_id = v_rounding_id;

        fnd_file.put_line(fnd_file.log, '**** Zero Rounded ****');
        GOTO next_exc_inv;

      elsif v_rounded_amount.total < 0 then
        v_rounding_entry_type := 'CR';
        v_rounded_cr_amount := ABS(NVL(v_rounded_amount.basic,0) +
	                           NVL(v_rounded_amount.additional,0) +
                                   NVL(v_rounded_amount.additional_cvd,0) + /*5228046 Additional cvd Enhancement*/
				   NVL(v_rounded_amount.other,0) +
				   NVL(v_rounded_amount.excise_edu_cess,0) +
				   NVL(v_rounded_amount.cvd_edu_cess,0) +
				   NVL(v_rounded_amount.sh_excise_edu_cess,0) +  -- Date 16/04/2007 by sacsethi for Bug#5989740
				   NVL(v_rounded_amount.sh_cvd_edu_cess,0));

      ELSIF v_rounded_amount.total > 0 THEN
        v_rounding_entry_type := 'DR';
        v_rounded_dr_amount := ABS(NVL(v_rounded_amount.basic,0) +
				   NVL(v_rounded_amount.additional,0) +
                                   NVL(v_rounded_amount.additional_cvd,0) +/*5228046 Additional cvd Enhancement*/
				   NVL(v_rounded_amount.other,0) +
				   NVL(v_rounded_amount.excise_edu_cess,0) +
				   NVL(v_rounded_amount.cvd_edu_cess,0) +
				   NVL(v_rounded_amount.sh_excise_edu_cess,0) + -- Date 16/04/2007 by sacsethi for Bug#5989740
				   NVL(v_rounded_amount.sh_cvd_edu_cess,0));
      END IF;

      IF NVL(v_rounded_amount.basic,0) > 0 THEN
        v_rounded_dr_rg23_amount.basic      := ABS(v_rounded_amount.basic);
      ELSE
        v_rounded_cr_rg23_amount.basic      := ABS(v_rounded_amount.basic);
      END IF;

      IF NVL(v_rounded_amount.additional,0) > 0 THEN
        v_rounded_dr_rg23_amount.additional := ABS(v_rounded_amount.additional);
      ELSE
        v_rounded_cr_rg23_amount.additional := ABS(v_rounded_amount.additional);
      END IF;

    /*5228046 Additional cvd Enhancement*/
    IF NVL(v_rounded_amount.additional_cvd,0) > 0 THEN
      v_rounded_dr_rg23_amount.additional_cvd := ABS(v_rounded_amount.additional_cvd);
    ELSE
      v_rounded_cr_rg23_amount.additional_cvd := ABS(v_rounded_amount.additional_cvd);
    END IF;


      IF NVL(v_rounded_amount.other,0) > 0 THEN
        v_rounded_dr_rg23_amount.other      := ABS(v_rounded_amount.other);
      ELSE
        v_rounded_cr_rg23_amount.other      := ABS(v_rounded_amount.other);
      END IF;

      IF (NVL(v_rounded_amount.excise_edu_cess,0) +
         NVL(v_rounded_amount.cvd_edu_cess,0)+
         NVL(v_rounded_amount.sh_excise_edu_cess,0) +
         NVL(v_rounded_amount.sh_cvd_edu_cess,0)) > 0
      THEN
        v_rounded_dr_oth_amount.total := ABS(NVL(v_rounded_amount.excise_edu_cess,0) +
	                                     NVL(v_rounded_amount.cvd_edu_cess,0) +
                                             NVL(v_rounded_amount.sh_excise_edu_cess,0) +  -- Date 16/04/2007 by sacsethi for Bug#5989740
	                                     NVL(v_rounded_amount.sh_cvd_edu_cess,0)
					     );

      ELSE
        v_rounded_cr_oth_amount.total := ABS(NVL(v_rounded_amount.excise_edu_cess,0) +
	                                     NVL(v_rounded_amount.cvd_edu_cess,0) +
                                             NVL(v_rounded_amount.sh_excise_edu_cess,0) +  -- Date 16/04/2007 by sacsethi for Bug#5989740
	                                     NVL(v_rounded_amount.sh_cvd_edu_cess,0)
					    );
      END IF;

      IF NVL(v_rounded_amount.excise_edu_cess,0) > 0 THEN
        v_rounded_dr_oth_amount.excise_edu_cess   := ABS(v_rounded_amount.excise_edu_cess);
      ELSE
        v_rounded_cr_oth_amount.excise_edu_cess   := ABS(v_rounded_amount.excise_edu_cess);
      END IF;

      IF NVL(v_rounded_amount.cvd_edu_cess,0) > 0 THEN
        v_rounded_dr_oth_amount.cvd_edu_cess      := ABS(v_rounded_amount.cvd_edu_cess);
      ELSE
        v_rounded_cr_oth_amount.cvd_edu_cess      := ABS(v_rounded_amount.cvd_edu_cess);
      END IF;

-- Date 16/04/2007 by sacsethi for Bug#5989740
-- start 5989740
    IF NVL(v_rounded_amount.sh_excise_edu_cess,0) > 0 THEN
      v_rounded_dr_oth_amount.sh_excise_edu_cess   := ABS(v_rounded_amount.sh_excise_edu_cess);
    ELSE
      v_rounded_cr_oth_amount.sh_excise_edu_cess   := ABS(v_rounded_amount.sh_excise_edu_cess);
    END IF;

    IF NVL(v_rounded_amount.sh_cvd_edu_cess,0) > 0 THEN
      v_rounded_dr_oth_amount.sh_cvd_edu_cess      := ABS(v_rounded_amount.sh_cvd_edu_cess);
    ELSE
      v_rounded_cr_oth_amount.sh_cvd_edu_cess      := ABS(v_rounded_amount.sh_cvd_edu_cess);
    END IF;
-- end 5989740

      v_statement_no := '4';

      OPEN c_rg_modvat_account(p_organization_id, r.location_id);
      FETCH c_rg_modvat_account INTO v_modvat_rm_account_id, v_modvat_cg_account_id, v_modvat_pla_account_id;
      CLOSE c_rg_modvat_account;

      v_statement_no := '4.1';
      if r.register = LV_PLA_REGISTER then
        v_rg_account_id := v_modvat_pla_account_id;

      elsif v_register_type = 'A' THEN
        v_rg_account_id := v_modvat_rm_account_id;

      elsif v_register_type = 'C' THEN
        v_rg_account_id := v_modvat_cg_account_id;
      end if;

      -- Required Accounts are not specified at the location where RG23 PART II entry will be posted. So, through out an error
      if v_rg_account_id IS NULL then
        if r.register = LV_PLA_REGISTER then
          v_err_message := 'ERROR: PLA Account is not specified for Location:'||r.location_id;
        elsif v_register_type = 'A' THEN
          v_err_message := 'ERROR: Cenvat RMIN Account is not specified for Location:'||r.location_id;
        else
          v_err_message := 'ERROR: Cenvat CGIN Account is not specified for Location:'||r.location_id;
        end if;

        fnd_file.put_line(fnd_file.log, v_err_message);
        RAISE_APPLICATION_ERROR( -20099, v_err_message);
      end if;

      v_statement_no := '5';

      -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. OPEN c_vendor(v_shipment_header_id);
      OPEN c_vendor(r.min_shipment_header_id);
      FETCH c_vendor INTO v_vendor_id, v_vendor_site_id, v_receipt_num;
      CLOSE c_vendor;

      /*Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.*/
      if r.cnt_shipment_header_id > 1 then
        v_receipt_num := null;
      end if;

      v_statement_no := '7';

      if r.register = LV_RG23_REGISTER then
        OPEN c_slno_balance_rg23p2(p_organization_id, r.location_id, v_fin_year, v_register_type);
        FETCH c_slno_balance_rg23p2 INTO v_slno, v_balance;
        CLOSE c_slno_balance_rg23p2;
        v_rg23_balance := nvl(v_balance,0);

        v_statement_no := '8';

        IF v_slno IS NULL or v_slno = 0 THEN
          v_slno := 1;
        ELSE
          v_slno := v_slno + 1;
        END IF;
      end if;

      v_statement_no := '8.1';

      if gb_debug then
        fnd_file.put_line(fnd_file.log, '4-Before Insert of Rounding Entry into Register:'||r.register );
      end if;

      if r.register = LV_PLA_REGISTER then

        jai_cmn_rg_pla_trxs_pkg.insert_row(
            p_register_id                   => v_register_id_part_ii,
            p_tr6_challan_no                => NULL,
            p_tr6_challan_date              => NULL,
            p_cr_basic_ed                   => v_rounded_cr_rg23_amount.basic,
            p_cr_additional_ed              => v_rounded_cr_rg23_amount.additional,
            p_cr_other_ed                   => v_rounded_cr_rg23_amount.other,
            -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. p_ref_document_id               => r.shipment_header_id,
            p_ref_document_id               => ln_rtv_excise_batch_group_id,  -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
            p_ref_document_date             => trunc(sysdate),    -- CHK
            p_dr_invoice_id                 => r.excise_invoice_no,
            p_dr_invoice_date               => r.excise_invoice_date,
            p_dr_basic_ed                   => v_rounded_dr_rg23_amount.basic,
            p_dr_additional_ed              => v_rounded_dr_rg23_amount.additional,
            p_dr_other_ed                   => v_rounded_dr_rg23_amount.other,
            p_organization_id               => p_organization_id,
            p_location_id                   => r.location_id,
            p_bank_branch_id                => NULL,
            p_entry_date                    => NULL,
            p_inventory_item_id             => 0,
            p_vendor_cust_flag              => 'V',
            p_vendor_id                     => v_vendor_id,
            p_vendor_site_id                => v_vendor_site_id,
            p_excise_invoice_no             => r.excise_invoice_no,
            p_remarks                       => 'Rounding Entry for Receipt No:'||v_receipt_num,
            p_transaction_date              => r.transaction_date,
            p_charge_account_id             => NULL,
            p_other_tax_credit              => v_rounded_cr_oth_amount.total,
            p_other_tax_debit               => v_rounded_dr_oth_amount.total,
            p_transaction_type              => 'RETURN TO VENDOR',
            p_transaction_source            => null,
            p_called_from                   => 'rg_rounding_pkg.do_rtv_rounding',
            p_simulate_flag                 => 'N',
            p_process_status                => lv_process_status,
            p_process_message               => lv_process_message,
            p_rounding_id                   => -1
        );

        if lv_process_status = 'E' then
          raise_application_error( -20010, lv_process_message, true);
        end if;

      elsif r.register = LV_RG23_REGISTER then
        INSERT INTO JAI_CMN_RG_23AC_II_TRXS(
          REGISTER_ID, ORGANIZATION_ID, LOCATION_ID, FIN_YEAR, INVENTORY_ITEM_ID, SLNO,
          CR_BASIC_ED, DR_BASIC_ED,
          CR_ADDITIONAL_ED, DR_ADDITIONAL_ED,
          CR_ADDITIONAL_CVD, DR_ADDITIONAL_CVD,/*5228046 ADDITIONAL CVD ENHANCEMENT*/
          CR_OTHER_ED, DR_OTHER_ED,
          ROUNDING_ID, EXCISE_INVOICE_NO, EXCISE_INVOICE_DATE,
          TRANSACTION_SOURCE_NUM, RECEIPT_REF, REGISTER_TYPE, REMARKS,
          VENDOR_ID, VENDOR_SITE_ID, CUSTOMER_ID, CUSTOMER_SITE_ID,
          OPENING_BALANCE, CLOSING_BALANCE, CHARGE_ACCOUNT_ID,
          CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN
          , TRANSACTION_DATE, OTHER_TAX_CREDIT, OTHER_TAX_DEBIT
        ) VALUES (
          JAI_CMN_RG_23AC_II_TRXS_S.nextval, p_organization_id, r.location_id , v_fin_year, 0, v_slno,
          v_rounded_cr_rg23_amount.basic, v_rounded_dr_rg23_amount.basic,
          v_rounded_cr_rg23_amount.additional, v_rounded_dr_rg23_amount.additional,
          v_rounded_cr_rg23_amount.additional_cvd, v_rounded_dr_rg23_amount.additional_cvd,/*5228046 Additional cvd Enhancement*/
          v_rounded_cr_rg23_amount.other, v_rounded_dr_rg23_amount.other,
          -1, r.excise_invoice_no, r.excise_invoice_date,
          -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. 18, r.shipment_header_id, v_register_type, 'Rounding Entry for Receipt No:'||v_receipt_num,
          18, ln_rtv_excise_batch_group_id, v_register_type, 'Rounding Entry for Receipt No:'||v_receipt_num,
          v_vendor_id, v_vendor_site_id, NULL, NULL,
          v_rg23_balance, v_rg23_balance + v_rounded_amount_rg23, v_rg_account_id,
          SYSDATE, v_created_by, SYSDATE, v_created_by, v_last_update_login
          , r.transaction_date, v_rounded_cr_oth_amount.total, v_rounded_dr_oth_amount.total

        ) RETURNING register_id INTO v_register_id_part_ii;
      end if;

      DECLARE
        v_tax_type JAI_CMN_RG_OTHERS.tax_type%TYPE;
        v_dr_amt JAI_CMN_RG_OTHERS.debit%TYPE;
        v_cr_amt JAI_CMN_RG_OTHERS.credit%TYPE;
      BEGIN
        FOR I in 1..4 LOOP -- Date 16/04/2007 by sacsethi for Bug#5989740 changed the loop counter from 2 to 4

          if i = 1 then
            v_tax_type  := jai_constants.tax_type_exc_edu_cess;
            v_dr_amt    := v_rounded_dr_oth_amount.excise_edu_cess;
            v_cr_amt    := v_rounded_cr_oth_amount.excise_edu_cess;
          elsif i = 2 then
            v_tax_type  := jai_constants.tax_type_cvd_edu_cess;
            v_dr_amt    := v_rounded_dr_oth_amount.cvd_edu_cess;
            v_cr_amt    := v_rounded_cr_oth_amount.cvd_edu_cess;
-- Date 16/04/2007 by sacsethi for Bug#5989740
-- start 5989740
	  elsif i = 3 then
            v_tax_type  := jai_constants.tax_type_sh_exc_edu_cess;
            v_dr_amt    := v_rounded_dr_oth_amount.sh_excise_edu_cess;
            v_cr_amt    := v_rounded_cr_oth_amount.sh_excise_edu_cess;
          elsif i = 4 then
            v_tax_type  := jai_constants.tax_type_sh_cvd_edu_cess;
            v_dr_amt    := v_rounded_dr_oth_amount.sh_cvd_edu_cess;
            v_cr_amt    := v_rounded_cr_oth_amount.sh_cvd_edu_cess;
-- end 5989740
          end if;

          if gb_debug then
            fnd_file.put_line(fnd_file.log, '5-Before Insert of RG Others.Amts:dr-'||v_dr_amt||',cr-'||v_cr_amt );
          end if;

          IF NVL(v_dr_amt,0) <> 0 OR NVL(v_cr_amt,0) <> 0 THEN
            INSERT INTO JAI_CMN_RG_OTHERS (
              RG_OTHER_ID,
              SOURCE_TYPE,
              SOURCE_REGISTER,
              SOURCE_REGISTER_ID,
              TAX_TYPE,
              DEBIT,
              CREDIT,
              OPENING_BALANCE,
              CLOSING_BALANCE,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN
            ) VALUES (
              JAI_CMN_RG_OTHERS_S.nextval,
              DECODE(r.register, LV_PLA_REGISTER, 2, 1),
              DECODE(r.register, LV_PLA_REGISTER, 'PLA', decode(v_register_type,'A','RG23A_P2','C','RG23C_P2')),/*for bug 5054176*/
              v_register_id_part_ii,
              v_tax_type,
              v_dr_amt,
              v_cr_amt,
              NULL,
              NULL,
              v_created_by,
              sysdate,
              v_created_by,
              sysdate,
              v_last_update_login
            );
          END IF;
        END LOOP;
      END;

      v_statement_no := '10a';
      -- this call will update Rounding RG23 PartII entry with Period_balance_id and updates all records of JAI_CMN_RG_PERIOD_BALS
      -- that come after the period in which parent Excise invoice has hit RG
      if r.register = LV_RG23_REGISTER then
        jai_cmn_rg_period_bals_pkg.adjust_rounding(v_register_id_part_ii, v_period_balance_id, v_no_of_periods_updated);
      end if;

      if gb_debug then
        fnd_file.put_line(fnd_file.log, '6-Before Insert into Rounding Entries. Id:'||v_rounding_id);
      end if;

      v_statement_no := '11';
      INSERT INTO JAI_CMN_RG_ROUND_HDRS(
        ROUNDING_ID, SOURCE_HEADER_ID, EXCISE_INVOICE_NO, EXCISE_INVOICE_DATE,
        EXCISE_AMT_BEFORE_ROUNDING, EXCISE_AMT_AFTER_ROUNDING,
        BASIC_ED, ROUNDED_BASIC_ED,
        ADDITIONAL_ED, ROUNDED_ADDITIONAL_ED,
        ADDITIONAL_CVD, ROUNDED_ADDITIONAL_CVD,/*5228046 ADDITIONAL CVD ENHANCEMENT*/
        OTHER_ED, ROUNDED_OTHER_ED,
        EXCISE_EDU_CESS, ROUNDED_EXCISE_EDU_CESS,
        CVD_EDU_CESS, ROUNDED_CVD_EDU_CESS,
        sh_excise_edu_cess, rounded_sh_excise_edu_cess, -- Date 16/04/2007 by sacsethi for Bug#5989740
        sh_cvd_edu_cess, rounded_sh_cvd_edu_cess,       -- SH Cess column is added
        register, REGISTER_ID, SOURCE, SRC_TRANSACTION_TYPE,
        CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
        program_application_id, program_id, program_login_id, request_id
      ) VALUES (
        -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. v_rounding_id, v_shipment_header_id, v_excise_invoice_no, v_excise_invoice_date,
        v_rounding_id, ln_rtv_excise_batch_group_id, v_excise_invoice_no, v_excise_invoice_date,
        v_tot_amount.total, v_tot_rounded_amount.total,
        v_tot_amount.basic, v_tot_rounded_amount.basic,
        v_tot_amount.additional, v_tot_rounded_amount.additional,
        V_TOT_AMOUNT.ADDITIONAL_CVD, V_TOT_ROUNDED_AMOUNT.ADDITIONAL_CVD,      /*5228046 ADDITIONAL CVD ENHANCEMENT*/
        v_tot_amount.other, v_tot_rounded_amount.other,
        v_tot_amount.excise_edu_cess, v_tot_rounded_amount.excise_edu_cess,
        v_tot_amount.cvd_edu_cess, v_tot_rounded_amount.cvd_edu_cess,
        v_tot_amount.sh_excise_edu_cess, v_tot_rounded_amount.sh_excise_edu_cess, -- Date 16/04/2007 by sacsethi for Bug#5989740
        v_tot_amount.sh_cvd_edu_cess, v_tot_rounded_amount.sh_cvd_edu_cess,
	r.register, v_register_id_part_ii, 'PO', p_transaction_type,
        SYSDATE, v_created_by, SYSDATE, v_created_by, v_last_update_login,
	fnd_profile.value('PROG_APPL_ID'), fnd_profile.value('CONC_PROGRAM_ID'), fnd_profile.value('CONC_LOGIN_ID'), fnd_profile.value('CONC_REQUEST_ID')
      );

      v_statement_no := '12';

      if gb_debug then
        fnd_file.put_line(fnd_file.log, '7-Pass RG Accnting: Cr-'||v_rounded_cr_amount||', Dr-'||v_rounded_dr_amount);
      end if;

      -- 2 (CR, DR) GL Interface related calls has to be coded
      -- Modvat Account entries
      jai_rcv_rnd_pkg.pass_accounting(
        p_organization_id           => p_organization_id,
        p_transaction_id            => r.rcv_transaction_id,
        p_transaction_date          => v_today,
        p_shipment_line_id          => -1,
        p_acct_type                 => v_acct_type,
        p_acct_nature               => v_acct_nature,
        p_source                    => v_source_name,
        p_category                  => v_category_name,
        p_code_combination_id       => v_rg_account_id,
        p_entered_dr                => v_rounded_cr_amount,
        p_entered_cr                => v_rounded_dr_amount,
        p_created_by                => v_created_by,
        p_currency_code             => 'INR',
        p_currency_conversion_type  => NULL,
        p_currency_conversion_date  => NULL,
        p_currency_conversion_rate  => NULL,
        p_receipt_num               => v_receipt_num
      );

      v_statement_no := '13';

      jai_cmn_gl_pkg.create_gl_entry(
        p_organization_id   => p_organization_id,
        p_currency_code     => 'INR',
        p_credit_amount     => v_rounded_dr_amount,
        p_debit_amount      => v_rounded_cr_amount,
        p_cc_id             => v_rg_account_id,
        p_je_source_name    => v_source_name,
        p_je_category_name  => v_category_name,
        p_created_by        => v_created_by,
        p_accounting_date   => v_today,
        -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. p_reference_10      => 'India Local Rounding Entry for Shipment_Header_id:'||r.shipment_header_id
        p_reference_10      => 'India Local Rounding Entry for RTV batch_group_id:'||ln_rtv_excise_batch_group_id
                              ||', excise_invoice_no:'||r.excise_invoice_no||', exc_inv_date:'||r.excise_invoice_date,
        p_reference_23      => 'ja_in_rg_rounding_p',
        p_reference_24      => 'JAI_CMN_RG_ROUND_HDRS',
        p_reference_25      => 'ROUNDING_ID',
        p_reference_26      => v_rounding_id
      );

      v_statement_no := '14';

      -- Rounding Account entries
      jai_rcv_rnd_pkg.pass_accounting(
        p_organization_id           => p_organization_id,
        p_transaction_id            => r.rcv_transaction_id,
        p_transaction_date          => v_today,
        p_shipment_line_id          => -1,
        p_acct_type                 => v_acct_type,
        p_acct_nature               => v_acct_nature,
        p_source                    => v_source_name,
        p_category                  => v_category_name,
        p_code_combination_id       => v_rg_rounding_account_id,
        p_entered_dr                => v_rounded_dr_amount,
        p_entered_cr                => v_rounded_cr_amount,
        p_created_by                => v_created_by,
        p_currency_code             => 'INR',
        p_currency_conversion_type  => NULL,
        p_currency_conversion_date  => NULL,
        p_currency_conversion_rate  => NULL,
        p_receipt_num               => v_receipt_num
      );

      v_statement_no := '15';

      jai_cmn_gl_pkg.create_gl_entry(
        p_organization_id   => p_organization_id,
        p_currency_code     => 'INR',
        p_credit_amount     => v_rounded_cr_amount,
        p_debit_amount      => v_rounded_dr_amount,
        p_cc_id             => v_rg_rounding_account_id,
        p_je_source_name    => v_source_name,
        p_je_category_name  => v_category_name,
        p_created_by        => v_created_by,
        p_accounting_date   => v_today,
        -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. p_reference_10      => 'India Local Rounding Entry for Shipment_Header_id:'||r.shipment_header_id
        p_reference_10      => 'India Local Rounding Entry for RTV batch_group_id:'||ln_rtv_excise_batch_group_id
                                ||', excise_invoice_no:'||r.excise_invoice_no||', exc_inv_date:'||r.excise_invoice_date,
        p_reference_23      => 'ja_in_rg_rounding_p',
        p_reference_24      => 'JAI_CMN_RG_ROUND_HDRS',
        p_reference_25      => 'ROUNDING_ID',
        p_reference_26      => v_rounding_id
      );

      v_statement_no := '16';

      if v_register_type = 'A' then
        UPDATE JAI_CMN_RG_BALANCES
          SET rg23a_balance = nvl(rg23a_balance, 0) + v_rounded_amount_rg23
        WHERE organization_id = p_organization_id
        AND location_id = r.location_id;

      elsif v_register_type = 'C' then
        UPDATE JAI_CMN_RG_BALANCES
          SET rg23c_balance = nvl(rg23c_balance, 0) + v_rounded_amount_rg23
        WHERE organization_id = p_organization_id
        AND location_id = r.location_id;

      elsif r.register = LV_PLA_REGISTER then
        /* this update is already taken in jai_cmn_rg_pla_trxs_pkg.insert_row call*/
        NULL;

      end if;

      v_statement_no := '16.1';

      fnd_file.put_line(fnd_file.log,' 101 exc_rnd_cnt->'||v_excise_inv_rnd_cnt);

      if gb_debug then
        fnd_file.put_line(fnd_file.log, '8-Punching RoundingId in Register');
      end if;

      if r.register = LV_RG23_REGISTER then
	lv_ttype_correct := 'CORRECT'; /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
        UPDATE JAI_CMN_RG_23AC_II_TRXS aa
          SET rounding_id = v_rounding_id
        WHERE organization_id = p_organization_id
        AND excise_invoice_no = v_excise_invoice_no
        AND excise_invoice_date = v_excise_invoice_date
        AND nvl(vendor_id,-999) = nvl(r.vendor_id,-999)/*bgowrava for forward porting bug#5674376*/
        AND nvl(vendor_site_id,-999) = nvl(r.vendor_site_id,-999)/*bgowrava for forward porting bug#5674376*/
        AND rounding_id IS NULL
        AND TRANSACTION_SOURCE_NUM = 18
        AND EXISTS (
            SELECT BB.transaction_id
            FROM JAI_RCV_TRANSACTIONS bb, jai_rcv_rtv_batch_trxs b1
            -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. WHERE bb.shipment_header_id = v_shipment_header_id
            WHERE bb.transaction_id = b1.transaction_id       -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
            and b1.excise_batch_group_id = ln_rtv_excise_batch_group_id    -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
            AND bb.transaction_id = aa.receipt_ref
            AND ( bb.transaction_type = r.transaction_type
                  OR (bb.transaction_type =  lv_ttype_correct and bb.parent_transaction_type = r.transaction_type) --'CORRECT'
                )
        );

      elsif r.register = LV_PLA_REGISTER then
       lv_ttype_correct := 'CORRECT'; /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
        UPDATE JAI_CMN_RG_PLA_TRXS aa
          SET rounding_id = v_rounding_id
        WHERE organization_id = p_organization_id
        AND DR_INVOICE_NO = v_excise_invoice_no
        AND dr_invoice_date = v_excise_invoice_date
        AND nvl(vendor_id,-999) = nvl(r.vendor_id,-999)/*bgowrava for forward porting bug#5674376*/
        AND nvl(vendor_site_id,-999) = nvl(r.vendor_site_id,-999)/*bgowrava for forward porting bug#5674376*/
        AND rounding_id IS NULL
        AND TRANSACTION_SOURCE_NUM = 19
        AND exists (
            SELECT BB.transaction_id
            FROM JAI_RCV_TRANSACTIONS bb, jai_rcv_rtv_batch_trxs b1
            -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. WHERE bb.shipment_header_id = v_shipment_header_id
            WHERE bb.transaction_id = b1.transaction_id       -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
            and b1.excise_batch_group_id = ln_rtv_excise_batch_group_id    -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
            AND bb.transaction_id = aa.ref_document_id
            AND ( bb.transaction_type = r.transaction_type
                  OR (bb.transaction_type = lv_ttype_correct and bb.parent_transaction_type = r.transaction_type)
                )
        );

      end if;

      v_rounding_entries_made := v_rounding_entries_made + 1;

      v_statement_no := '17';
      IF v_no_of_invoices_posted >= v_commit_interval THEN
        v_no_of_invoices_posted := 0;
        COMMIT;
        if gb_debug then
          fnd_file.put_line(fnd_file.log, '9-After Commit of '||v_commit_interval||' entries');
        end if;

      ELSE
        v_no_of_invoices_posted := v_no_of_invoices_posted + 1;
      END IF;

      <<next_exc_inv>>
      v_save_point_set := false;

    EXCEPTION
      WHEN OTHERS THEN
        v_tot_errored_entries := v_tot_errored_entries + 1;
        fnd_file.put_line(fnd_file.log, 'Error at statement_no->'|| v_statement_no
          ||', rtvExcBtchGrpId->'||ln_rtv_excise_batch_group_id
          ||', excise_invoice_no->'||v_excise_invoice_no
          ||', excise_invoice_date->'||v_excise_invoice_date||' '
        );
        fnd_file.put_line(fnd_file.log, 'ErrMess->'|| SQLERRM);

        IF v_save_point_set THEN
          -- This has to rollback only if SAVEPOINT is set for the exc invoice being processed
          ROLLBACK TO previous_savepoint;
          v_save_point_set := false;
        END IF;

    END;

    v_tot_amount := NULL;
    v_tot_rounded_amount := NULL;
    v_rounded_amount := NULL;
    v_rounded_amount_abs := NULL;
    v_rounded_amount_rg23 := NULL;
    v_rounded_cr_amount := NULL;
    v_rounded_dr_amount := NULL;
    v_rounded_cr_rg23_amount := NULL;
    v_rounded_dr_rg23_amount := NULL;
    v_rounded_cr_oth_amount := NULL;
    v_rounded_dr_oth_amount := NULL;

    v_rounding_entry_type := null;

    v_vendor_id := null;
    v_vendor_site_id := null;
    v_modvat_rm_account_id := null;
    v_modvat_cg_account_id := null;
    v_rg_account_id := null;
    v_rg23_balance := null;
    v_balance := null;
    v_slno := null;

    v_rounding_id := null;
    v_register_id_part_ii := null;

    v_excise_invoice_no := null;
    v_excise_invoice_date := null;
    v_register_type := null;
    v_receipt_num := null;
    v_pla_register_id := null;
    lv_process_message := null;
    lv_process_status := null;

    v_exc_inv_rnd_counter := v_exc_inv_rnd_counter + 1;

  END LOOP;

  fnd_file.put_line(fnd_file.log, 'Completed. Total Rounding entries made -> '|| v_rounding_entries_made
    ||', errored entries->'||v_tot_errored_entries
    ||', Zero Exc. Amt. Invoices found->'||v_zero_round_found
    ||', total Ex. Invoices processed->'||v_tot_processed_invoices
  );


   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

  END do_rtv_rounding;

END jai_rcv_rnd_pkg;

/
