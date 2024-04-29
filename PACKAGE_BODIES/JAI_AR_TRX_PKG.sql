--------------------------------------------------------
--  DDL for Package Body JAI_AR_TRX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AR_TRX_PKG" 
/* $Header: jai_ar_trx.plb 120.8.12010000.8 2010/04/16 21:46:13 haoyang ship $ */
AS
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     jai_ar_match_tax.plb                                              |
--|                                                                       |
--| DESCRIPTION                                                           |
--|                                                                       |
--|                                                                       |
--| TDD REFERENCE                                                         |
--|                                                                       |
--|                                                                       |
--| PURPOSE                                                               |
--|     PROCEDURE update_excise_invoice_no                                |
--|     PROCEDURE validate_invoice                                        |
--|                                                                       |
--| HISTORY                                                               |
--|    Bug 5096787   Added by Lakshmi GopalsamiAdded by Lakshmi Gopalsami |
--|                    Added following parameters in                      |
--|                    procedure update_excise_invoice_no                 |
--|                   (1) p_start_date                                    |
--|                   (2) p_end_date                                      |
--|                                                                       |
--|    Bug 5490479  Added by Harshita                                     |
--|                    In the concurrent program, the multi org category  |
--|                  has been set to 'S'.                                 |
--|                    To accomodate the same, derived the org_id from    |
--|                  the function mo_global.get_current_org_id            |
--|                  and populated an internal variable.                  |
--|                    Used this variable in all places instead of        |
--|                    p_org_id.                                          |
--|                                                                       |
--|    08-Jun-2005  Version 116.1 jai_ar_trx -Object is Modified to refer |
--|                 to New DB Entity names in place of Old DB Entity Names|
--|                 as required for CASE COMPLAINCE.                      |
--|                                                                       |
--|    14-Jun-2005  rchandan for bug#4428980, Version 116.2               |
--|                 Modified the object to remove literals from           |
--|                 DML statements and CURSORS.                           |
--|                                                                       |
--|    01-Jul-2005  Ramananda for bug#4468353 due to ebtax uptake by AR,  |
--|                 File Version 116.3                                    |
--|                                                                       |
--|    29-Jul-2005  Ramananda for bug#4523064, File Version 120.2         |
--|                 Changed the cursor from tax_regime_code_cur           |
--|                 to c_tax_regime_code_cur                              |
--|                                                                       |
--|   28/12/2005   4892111 Hjujjuru, File Version 120.3                   |
--|                Modified the Hard Coded value of the tax               |
--|                'Localization' to 'LOCALIZATION' in all its occurences |
--|                                                                       |
--|   12-Jan-2006  rallamse bug#4931630, Version 120.4                    |
--|                Issue : Remove references to ar_vat_tax_all as it      |
--|                is obsoleted.                                          |
--|                Impacted code:cp_loc_tax_code                          |
--|                              ar_vat_tax_all.tax_code%TYPE             |
--|                Fix: Changed the cp_loc_tax_code from                  |
--|                ar_vat_tax_all.tax_code%type to zx_rates_b.tax         |
--|                                                                       |
--|  05-Jul-2006   Aiyer for the bug 5369250, Version  120.7              |
--|                Issue:-                                                |
--|                The concurrent failes with the following error :-      |
--|                "FDPSTP failed due to ORA-01861: literal does not      |
--|                match format string ORA-06512: at line 1 "             |
--|                                                                       |
--|                Reason:-                                               |
--|                The procedure update_excise_invoice_no has two         |
--|                parameters p_start_date and p_end_date which are of    |
--|                type date , however the concurrent program passes it   |
--|                in the canonical format and hence the failure.         |
--|                                                                       |
--|                Fix:-                                                  |
--|                Modified the procedure update_excise_invoice_no.       |
--|                Changed the datatype of p_start_date and p_end_date    |
--|                from date to varchar2 as this parameter.               |
--|                Also added the new parameters ld_start_date and        |
--|                ld_end_date. The values in p_start_date and p_end_date |
--|                would be converted to date format and stored in these  |
--|                local variables                                        |
--|                Dependency due to this fix:-                           |
--|                None                                                   |
--|                                                                       |
--|  20-Feb-2007   kvaidyan for bug 5894175                               |
--|                Modified cursor c_delivery to accept parameters        |
--|                cp_start_date and cp_end_date, the values are passed   |
--|                into cursor delivery_rec in c_delivery(ld_start_date , |
--|                ld_end_Date). Added filter condition 'excise_invoice_no|
--|                IS NOT NULL' to cursor c_ex_inv_no.                    |
--|  17-Sep-2007   anujsax for Bug#5636544, File Version 120.10           |
--|                forward porting for R11 bug 5629319 into R12 bug5636544|
--|                                                                       |
--|  13-Oct-2008   CSahoo for bug#6685050, File Version 120.11            |
--|                Issue: Enhancement for including the vat invoice number|
--|                       in the order reference field in AR invoice.     |
--|                Fix: Modified the code in the procedure                |
--|                     update_excise_invoice_no. Added the cursor        |
--|                     c_same_inv_no.Modified the cursor c_ex_inv_no.    |
--|                                                                       |
--|  20-Nov-2008   JMEENA for Bug#6391684( FP of 6386592)                 |
--|                Issue: AUTOINVOICE FOR CERTAIN CTO SALES ORDERS GOING  |
--|                INTO ERRORS.Because Excise Invoice# and VAT Invoice#   |
--|                are not getting imported into AR)                      |
--|                Reason: Import program is considering the Model item   |
--|                while importing the excise and vat invoice number.     |
--|                As the Config item is shipped for ATO Orders,Excise    |
--|                Invoice and VAT Invoice are not getting imported       |
--|                Fix: Modified the cursor c_ex_inv_no. Included an      |
--|                condition to check the order_line_id against the       |
--|                line_id of 'CONFIG' item                               |
--|                                                                       |
--| 19-nov-08      vkaranam for bug#5194107                               |
--|                forwardported the changes in 115 bug#5174616           |
--|                                                                       |
--| 05-DEC-2008    JMEENA for bug#7621541                                 |
--| 			         Reverted the changes of bug#5636544 as this should     |
--|                not go in 12.1.1 release because this bug is still     |
--|                open.                                                  |
--|                                                                       |
--| 19-Jan-2010    Bo Li modified for VAT/Excise Number shown             |
--|                    in AR transaction workbench and Bug 9303168# can   |
--|                    be tracked                                         |
--| 02-Apr-2010    Allen Yang modified for bug 9485355                    |
--|                (12.1.3 non-shippable Enhancement)                     |
--|                Modified procedure update_excise_invoice_no            |
--|                to enable processing of non-shippable items            |
--+======================================================================*/
PROCEDURE update_excise_invoice_no(
                                     retcode OUT NOCOPY varchar2,
                                     errbuf OUT NOCOPY varchar2,
                                     p_org_id          number,        /* Bug 5096787. Added by Lakshmi Gopalsami Added following two parameters.*/
                                     p_start_date        VARCHAR2, /* modified by aiyer for the bug 5369250 */
                                     p_end_date          VARCHAR2      DEFAULT NULL, /* modified by aiyer for the bug 5369250 */
                                     p_customer_trx_id number
                                    )
 IS

    ln_org_id                       number ; -- Harshita for Bug 5490479

     /*
  || Code modified for the bug 4474256
  || Change the c_delivery
  */
  CURSOR  c_delivery(cp_start_Date  IN DATE , cp_end_date IN DATE )
  IS
  SELECT  trx.customer_trx_id,
          rctl.customer_trx_line_id       ,
          rctl.interface_line_attribute3 ,
	  rctl.interface_line_attribute6
  FROM
          ra_customer_trx_all           trx   ,
          ra_customer_trx_lines_all     rctl  ,
    jai_ar_trx_lines    jrctl, -- Changed for Bug 5894175
          -- ja_in_ra_customer_trx_lines   jrctl
          JAI_AR_TRXS         jrct  --bug#5194107
  WHERE
          trx.customer_trx_id     = rctl.customer_trx_id
	  AND     jrct.customer_trx_id        = trx.customer_trx_id --5194107
  AND     rctl.line_type              = 'LINE'
  AND     trunc(trx.trx_date)         BETWEEN trunc(cp_start_date) AND nvl(trunc(cp_end_date),trunc(sysdate))
  AND     trx.customer_trx_id         = nvl(p_customer_trx_id,trx.customer_trx_id)
  AND     trx.org_id                  = p_org_id
 -- AND     trx.created_from            = 'RAXTRX'  -- modified by Bo Li for display VAT/Excise inv # in the reference
                                                    -- by manual AR transation
  AND     rctl.customer_trx_line_id   = jrctl.customer_trx_line_id
   AND     ( jrctl.excise_invoice_no   IS NULL OR jrct.vat_invoice_no IS NULL ) ;--bug#5194107

  --added for bug#6685050,csahoo
  CURSOR c_same_inv_no (cp_customer_trx_id ra_customer_trx_all.customer_trx_id%type)
  IS
  SELECT jror.attribute_Value
  FROM   JAI_RGM_ORG_REGNS_V jror, jai_ar_trxs jat
  WHERE  regime_code = 'VAT'
  AND    jror.attribute_type_code = jai_constants.regn_type_others
  AND    jror.attribute_code = jai_constants.attr_code_same_inv_no
  AND    jror.organization_id = jat.organization_id
  AND    jror.location_id = jat.location_id
  AND    jat.customer_trx_id = cp_customer_trx_id;


  CURSOR c_ex_inv_no(p_delivery_id varchar2, p_order_line_id varchar2) is
  SELECT excise_invoice_no , excise_invoice_date,
         vat_invoice_no, vat_invoice_date --added for bug#6685050
  FROM   JAI_OM_WSH_LINES_ALL
  -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
  -- WHERE  delivery_id = p_delivery_id
  WHERE (delivery_id IS NULL OR delivery_id = p_delivery_id)
  -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), end
   AND     (order_line_id     = p_order_line_id
           /* Added for bug#6391684, Starts */
           OR order_line_id in (SELECT line_id FROM oe_order_lines_all
                                WHERE  header_id in (SELECT header_id
                                                     FROM   oe_order_lines_all
                                                     WHERE  line_id = p_order_line_id)
                                 AND    item_type_code = 'CONFIG')
           ) /* Added for bug#6391684, Ends */
  AND    ( excise_invoice_no IS NOT NULL OR vat_invoice_no IS NOT NULL ) ; -- Bug Fixed 5894175

  ld_start_date       DATE ;
  ld_end_date         DATE ;
  --Commented below for bug#7621541
  --ln_excise_invoice_no   JAI_AR_TRX_LINES.excise_invoice_no%TYPE; --Added by Anujsax for bug#5636544
  ln_vat_invoice_no      JAI_AR_TRXS.vat_invoice_No%TYPE;  --added for bug#6685050
  lv_same_inv_no VARCHAR2(1); --added for bug#6685050
  lv_updt_exc_no VARCHAR2(1); --added for bug#6685050

    --start additions for bug#5194107
  ln_last_updated_by     JAI_AR_TRX_LINES.LAST_UPDATED_BY%TYPE   ;
  ln_last_update_login   JAI_AR_TRX_LINES.LAST_UPDATE_LOGIN%TYPE ;
  ld_vat_invoice_date    JAI_AR_TRXs.VAT_INVOICE_DATE%TYPE;

    --add by Bo Li for VAT/Excise Number shown in AR transaction workbench on 19-Jan-2010 and In Bug 9303168#,begin
    ----------------------------------------------------------------------------------------------------------------
    lv_display_flag      VARCHAR2(1);
    lv_excise_invoice_no JAI_OM_WSH_LINES_ALL.excise_invoice_no%TYPE;
   --------------------------------------------------------------------------------------------------------------
    --add by Bo Li for VAT/Excise Number shown in AR transaction workbench  on 19-Jan-2010 and In Bug 9303168#,end
BEGIN
  /*
  || start of 5369250
  ||code added by aiyer for the bug 5369250
  */
  ld_start_date := fnd_date.canonical_to_date(p_start_date);
  ld_end_date   := fnd_date.canonical_to_date(p_end_date)  ;

    fnd_file.put_line(FND_FILE.LOG,'Input parameters are p_org_id-> ' || p_org_id
                                  ||' ,p_start_date -> '            || p_start_date
                                  ||' ,p_end_date -> '              || p_end_date
                                  ||' ,p_customer_trx_id -> '       || p_customer_trx_id);  --bug#5194107

  /* End of 5369250 */

   ln_last_updated_by    := fnd_global.user_id;	 --bug#5194107
  ln_last_update_login  := fnd_global.login_id;	--bug#5194107

  ln_org_id := mo_global.get_current_org_id() ; -- Harshita for Bug 5490479

  fnd_file.put_line(FND_FILE.LOG,'Processing Customer Trx id : ' || p_customer_trx_id);

 for delivery_rec in c_delivery(ld_start_date , ld_end_Date)
  Loop
   fnd_file.put_line(FND_FILE.LOG,'Delivery id : ' || delivery_rec.interface_line_attribute3);
   fnd_file.put_line(FND_FILE.LOG,'Customer Trx Line id : ' ||delivery_rec.customer_trx_line_id);
   --added for bug#6685050, start
   OPEN c_same_inv_no(delivery_rec.customer_trx_id);
   FETCH c_same_inv_no INTO lv_same_inv_no;
   CLOSE c_same_inv_no;
   -- bug#6685050, end
   For ex_inv_rec in c_ex_inv_no(to_number(delivery_rec.interface_line_attribute3), to_number(delivery_rec.interface_line_attribute6))--bug#5194107
    loop
      update JAI_AR_TRX_LINES
      set    excise_invoice_no    = ex_inv_rec.excise_invoice_no ,
             excise_invoice_date  = ex_inv_rec.excise_invoice_date
      where  customer_trx_line_id = delivery_rec.customer_trx_line_id;
      /* --Commented below for bug#7621541
	  --Added the below by Anujsax for bug#5636544
      IF ln_excise_invoice_no IS NULL AND ex_inv_rec.excise_invoice_no IS NOT NULL THEN
        ln_excise_invoice_no := ex_inv_rec.excise_invoice_no;
      END IF;
      --ended by anujsax for bug#5636544
	  */
      --added for bug#6685050, start
      IF ln_vat_invoice_no IS NULL AND ex_inv_rec.vat_invoice_no IS NOT NULL THEN
        ln_vat_invoice_no := ex_inv_rec.vat_invoice_no;
      END IF;
      -- bug#6685050, end

      ld_vat_invoice_date := ex_inv_rec.vat_invoice_date;  --BUG#5194107

         --add by Bo Li for VAT/Excise Number shown in AR transaction workbench(Bug 9303168#) on 19-Jan-2010 ,begin
        -----------------------------------------------------------------------------------------------------------------
        lv_excise_invoice_no := ex_inv_rec.excise_invoice_no;
        -----------------------------------------------------------------------------------------------------------------
       --add by Bo Li for VAT/Excise Number shown in AR transaction workbench(Bug 9303168#) on 19-Jan-2010, end
    end loop;

    --start additions by vkaranam for bug#5194107
     IF ln_vat_invoice_no IS NOT NULL or ld_vat_invoice_date IS NOT NULL THEN

       fnd_file.put_line(FND_FILE.LOG,' VAT invoice No -> '||ln_vat_invoice_no
                                       || ', VAT  inv date -> ' ||ld_vat_invoice_date
                                    ||' for customer_trx_id -> '||delivery_rec.customer_trx_id );

       UPDATE JAI_AR_TRXS
          SET vat_invoice_no       = nvl( ln_vat_invoice_no  ,vat_invoice_no )   ,
              vat_invoice_date     = nvl( ld_vat_invoice_date,vat_invoice_date ) ,
              last_update_date     = sysdate                                     ,
              last_updated_by      = ln_last_updated_by                          ,
              last_update_login    = ln_last_update_login
        WHERE customer_trx_id      = delivery_rec.customer_trx_id;

    END IF;
    --end additions for bug#5194107


    lv_updt_exc_no := FND_PROFILE.value('JAI_INCLUDE_EXC_INV_AR_TRX_REF'); --added for bug#6685050

      --add by Bo Li for VAT/Excise Number shown in AR transaction workbench(Bug 9303168#) on 19-Jan-2010,begin
      -----------------------------------------------------------------------------------------------------------------
      -- when then profile "JAI:Include Excise and VAT Invoice Number in AR transactions - Referencde" set to "Yes"
      lv_display_flag := FND_PROFILE.VALUE('JAI_DISP_VAT_EXC_INV_AR_TRX_REF');

      fnd_file.put_line( FND_FILE.LOG
                       , 'JAI:Include Excise and VAT Invoice Number in AR transactions - Referencde is set to ' ||
                        lv_display_flag);

      fnd_file.put_line( FND_FILE.LOG
                       , 'delivery_rec.customer_trx_id :'||delivery_rec.customer_trx_id);
      fnd_file.put_line( FND_FILE.LOG
                       , 'lv_excise_invoice_no :' || lv_excise_invoice_no);
      fnd_file.put_line( FND_FILE.LOG
                       , 'lv_vat_invoice_no :' || ln_vat_invoice_no);

      IF ( lv_excise_invoice_no IS NOT NULL OR ln_vat_invoice_no IS NOT NULL)
         AND nvl(lv_display_flag, 'N') = 'Y'
      THEN
        JAI_AR_MATCH_TAX_PKG.display_vat_invoice_no( pn_customer_trx_id    => delivery_rec.customer_trx_id
                                                   , pv_excise_invoice_no  => lv_excise_invoice_no
                                                   , pv_vat_invoice_no     => ln_vat_invoice_no
                                                   );

        fnd_file.put_line(FND_FILE.LOG,'The invoice number has been displayed successfully!');
      END IF;
      -----------------------------------------------------------------------------------------------------------------
      --Add by Bo Li for VAT/Excise Number shown in AR transaction workbench(Bug 9303168#) on 19-Jan-2010,End
  end loop;
 commit;
 retcode :='0';
 exception
when others then
 rollback;
 retcode :='2';
 errbuf := sqlerrm;
end update_excise_invoice_no;

procedure validate_invoice    ( p_customer_trx_id IN  RA_CUST_TRX_LINE_GL_DIST_ALL.CUSTOMER_TRX_ID%TYPE ,
                              p_trx_number      IN  RA_CUSTOMER_TRX_ALL.TRX_NUMBER%TYPE               , /* should not be used in a where clause as this is not unique */
                              p_error_flag OUT NOCOPY VARCHAR2                                          ,
                              p_error_message OUT NOCOPY VARCHAR2
                            )

/* --------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------

07-Feb-2006  Aiyer for the bug 5021243, Version  120.5
             Issue:-
              Error plsql numeric or value error encontered while
              execution of the procedure jai_ar_trx_pkg.validate_invoice

             Fix:-
               The error was occuring as the variable lv_tax_regime_code was
               declared as Number however the cursor
               jai_ar_trx_pkg.c_tax_regime_code_cur fetches a varchar value
               into this variable.
               Changed the variable from number to
               ZX_RATES_B.TAX_REGIME_CODE%TYPE.Also changed the parameter
               cp_tax_regime_code of the cursor cur_chk_non_il_taxes from
               number to ZX_RATES_B.TAX_REGIME_CODE%TYPE.

             Dependency due to this fix:-
              None
--------------------------------------------------------------------------------------------------
*/

IS



  V_ORG_ID number ;
  /*Changed the Variable lv_tax_regime_code datatype from NUMBER to
  ZX_RATES_B.TAX_REGIME_CODE%TYPE for the bug 5021243 */
  lv_tax_regime_code ZX_RATES_B.TAX_REGIME_CODE%TYPE ;

  CURSOR ORG_CUR IS
  SELECT ORG_ID
  FROM   RA_CUSTOMER_TRX_ALL
  WHERE  CUSTOMER_TRX_ID = p_customer_trx_id;
 /*
 || Modified by Ramananda for bug#4468353
 || Check whether any other taxes other than localizations taxes exist.
 || rallamse bug#4931630 changed the cp_loc_tax_code from ar_vat_tax_all.tax_code%type
 || to zx_rates_b.tax
 */
 CURSOR cur_chk_non_il_taxes(cp_loc_tax_code      ZX_RATES_B.TAX%TYPE,
                             cp_line_type_tax     RA_CUSTOMER_TRX_LINES_ALL.LINE_TYPE%TYPE,
                             cp_line_type_freight RA_CUSTOMER_TRX_LINES_ALL.LINE_TYPE%TYPE,
                             cp_tax_regime_code   ZX_RATES_B.TAX_REGIME_CODE%TYPE
                         /*Variable datatype changed from number to
                         ZX_RATES_B.TAX_REGIME_CODE%TYPE for the bug 5021243 */
                            )   --rchandan for bug#4428980
  IS
  SELECT
         1
  FROM   ra_customer_trx_lines_all  rctl,
         zx_rates_b  zrb,
         zx_party_tax_profile zptp
  WHERE
        zrb.tax                      = 'LOCALIZATION' -- 'Localization' , Harshita for Bug 4907217
        AND zrb.tax_regime_code     =  cp_tax_regime_code
        AND zrb.tax_status_code     = 'STANDARD'
        AND zrb.active_flag         = 'Y'
        AND trunc(sysdate) between trunc(zrb.effective_from) and trunc(nvl(zrb.effective_to, sysdate))
        AND zrb.content_owner_id    = zptp.party_tax_profile_id
        AND rctl.vat_tax_id         = zrb.tax_rate_id
        AND rctl.org_id             = zptp.party_id
        AND zrb.tax                <> cp_loc_tax_code
        AND rctl.customer_trx_id    = p_customer_trx_id
        AND rctl.line_type          IN (cp_line_type_tax,cp_line_type_freight) ;--rchandan for bug#4428980



  /*
  ||Check whether the accounting rules have been used by the invoice
  ||This code is commented for the time being, as the functionality is not quite clear
  */
  CURSOR cur_chk_account_rule
  IS
  SELECT
         1
  FROM
         ra_customer_trx_lines_all
  WHERE
         customer_trx_id    = p_customer_trx_id AND
     accounting_rule_id IS NOT NULL;

  /*
  ||Check whether the Revenue Recognition Program has been already run for an invoice with rules
  */
  CURSOR cur_revrec_run( p_acc_class ra_cust_trx_line_gl_dist_all.account_class%TYPE )
  IS
  SELECT
         1
  FROM
         ra_cust_trx_line_gl_dist_all gl_dist,
     ra_customer_trx_all          rctx
  WHERE
         rctx.customer_trx_id      =  gl_dist.customer_trx_id   AND
     rctx.invoicing_rule_id    IS NOT NULL                  AND
         gl_dist.account_class     = p_acc_class          AND
         gl_dist.account_set_flag  = 'N'            AND
         gl_dist.latest_rec_flag   = 'Y'                        AND
     gl_dist.customer_trx_id   =  p_customer_trx_id     ;

  /*
  ||Check whether the invoice has been gl posted
  */
  CURSOR cur_chk_gl_posting
  IS
  SELECT
         1
  FROM
        ra_cust_trx_line_gl_dist_all
  WHERE
        customer_trx_id    =  p_customer_trx_id  AND
        account_set_flag   = 'N'                 AND
        posting_control_id <> -3                 AND
    rownum             = 1;

  ln_exists NUMBER;

BEGIN

 /*
 || Initialize the variables
 */
  p_error_message := null;
  p_error_flag    := 'SS';

  /*************************
  ||############################################################################################
  ||Check Whether any other tax other than India Localization Exists, IF yes report error
  ||############################################################################################
  *************************/

  /* Added by Ramananda for bug# due to ebtax uptake by AR, start */
       OPEN  ORG_CUR;
       FETCH ORG_CUR INTO V_ORG_ID;
       CLOSE ORG_CUR;

       OPEN  jai_ar_trx_pkg.c_tax_regime_code_cur(V_ORG_ID);
       FETCH jai_ar_trx_pkg.c_tax_regime_code_cur INTO lv_tax_regime_code;
       CLOSE jai_ar_trx_pkg.c_tax_regime_code_cur ;
  /* Added by Ramananda for bug# due to ebtax uptake by AR, start */


  OPEN  cur_chk_non_il_taxes('LOCALIZATION', 'TAX','FREIGHT',lv_tax_regime_code ); -- 'Localization' , Harshita for Bug 4907217
  FETCH cur_chk_non_il_taxes INTO ln_exists ;

  IF cur_chk_non_il_taxes%FOUND THEN
    CLOSE cur_chk_non_il_taxes;
    p_error_flag     := 'EE' ;
    p_error_message  := 'Invoice lines have taxes other than localization type of tax for the invoice TRX No'||p_trx_number||'. Please delete it and reprocess the invoice';
    return;
  END IF;
  CLOSE cur_chk_non_il_taxes;

  /*************************
  ||############################################################################################
  ||Check whether the invoice uses accounting rules, IF yes report error and return
  ||############################################################################################
  *************************/
  OPEN  cur_chk_account_rule;
  FETCH cur_chk_account_rule INTO ln_exists ;
  IF cur_chk_account_rule%FOUND THEN
    CLOSE cur_chk_account_rule;
    p_error_flag     := 'EE' ;
    p_error_message  := 'Invoice with TRX No '||p_trx_number||' uses accounting rules. Cannot process invoice ';
    return;
  END IF;
  CLOSE cur_chk_account_rule;




  /*************************
  ||#############################################################################################
  ||Check Whether the Revenue Recognition Program has been already been run for an invoice with
  ||rules. If yes then report error
  ||#############################################################################################
  *************************/
  OPEN  cur_revrec_run('REC');
  FETCH cur_revrec_run INTO ln_exists ;
  IF cur_revrec_run%FOUND THEN

  /*
  || Invoice has already been revenue recognised
  || cannot process the taxes related to the record, return.
  */

    CLOSE cur_revrec_run;
    p_error_flag     := 'EE' ;
    p_error_message  := 'Invoice has already been revenue recognised. Taxes related to invoice TRX No'||p_trx_number||' cannot be processed' ;
    return;
  END IF;
  CLOSE cur_revrec_run;





  /*************************
  ||############################################################################################
  ||Check whether the invoice has already been gl posted. IF yes report error and return
  ||############################################################################################
  *************************/
  OPEN  cur_chk_gl_posting;
  FETCH cur_chk_gl_posting INTO ln_exists ;
  IF cur_chk_gl_posting%FOUND THEN
  /*
    Invoice has already been gl posted,
    cannot process the taxes related to the record, return.
  */
    CLOSE cur_chk_gl_posting;
    p_error_flag     := 'EE' ;
    p_error_message  := 'Invoice TRX No '||p_trx_number||' has already been GL posted. Taxes related to this invoice cannot be processed' ;
    return;
  END IF;
  CLOSE cur_chk_gl_posting;



  /*
  || set out variables to success as no error has been encountered above.
  */
  p_error_flag     := 'SS' ;
  p_error_message  := null ;

EXCEPTION
  WHEN OTHERS THEN
    p_error_flag     := 'UE';
    p_error_message  := 'Unexpected error while processing invoice TRX No'||p_trx_number||' - '||substr(SQLERRM,1,300);
END validate_invoice;

--==========================================================================
--  PROCEDURE NAME:
--    update_reference                        Public
--
--  DESCRIPTION:
--    This procedure is written that update the reference field in AR
--  transaction workbench when the AR invoice has been created manually
--
--  ER NAME/BUG#
--    VAT/Excise Number shown in AR transaction workbench
--    Bug 9303168
--
--  PARAMETERS:
--      In:  pn_customer_trx_id            Indicates the customer trx id
--
--  DESIGN REFERENCES:
--       TD named "VAT Invoice Number on AR Invoice Technical Design.doc" has been
--     referenced in the section 6.1
--
--  CALL FROM
--       The concurrent program "India - Excise/VAT Number in Transactions Workbench"
--
--  CHANGE HISTORY:
--  25-Jan-2010       Bo Li         Created by Bo Li

--==========================================================================
 PROCEDURE update_reference
 ( retcode           OUT NOCOPY VARCHAR2
 , errbuf            OUT NOCOPY VARCHAR2
 , pn_customer_trx_id NUMBER
 )
 IS

    -- get vat invoice number
    CURSOR get_vat_invoice_cur IS
      SELECT vat_invoice_no
        FROM JAI_AR_TRXS
       WHERE customer_trx_id = pn_customer_trx_id;
   -- get excise invoice number
    CURSOR get_exc_inv_no_cur IS
      SELECT excise_invoice_no
        FROM JAI_AR_TRX_LINES
       WHERE customer_trx_id = pn_customer_trx_id;

    lv_vat_invoice_no       JAI_AR_TRXS.VAT_INVOICE_NO%Type;
    lv_excise_invoice_no    JAI_AR_TRX_LINES.excise_invoice_no%type;
    lv_display_flag         VARCHAR2(240);
    lv_procedure_name       VARCHAR2(40):='update_reference';
    ln_dbg_level            NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    ln_proc_level           NUMBER:=FND_LOG.LEVEL_PROCEDURE;

  BEGIN
    --logging for debug
    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING( ln_proc_level
                    , lv_procedure_name || '.begin'
                    , 'Enter procedure'
                    );
    END IF; --l_proc_level>=l_dbg_level

   -- get the values of VAT/Excise invoice number
   OPEN  get_vat_invoice_cur;
   FETCH get_vat_invoice_cur
   INTO  lv_vat_invoice_no;
   CLOSE get_vat_invoice_cur;

   OPEN  get_exc_inv_no_cur;
   FETCH get_exc_inv_no_cur
   INTO  lv_excise_invoice_no;
   CLOSE get_exc_inv_no_cur;

   --get the profile value
   lv_display_flag := FND_PROFILE.VALUE('JAI_DISP_VAT_EXC_INV_AR_TRX_REF');

   fnd_file.put_line( FND_FILE.LOG
                    , 'pn_customer_trx_id :' || pn_customer_trx_id);
   fnd_file.put_line( FND_FILE.LOG
                    , 'lv_excise_invoice_no :' || lv_excise_invoice_no);
   fnd_file.put_line( FND_FILE.LOG
                    , 'lv_vat_invoice_no :' || lv_vat_invoice_no);

    -- update the reference field in the AR transaction workbench
   IF (lv_excise_invoice_no IS NOT NULL OR lv_vat_invoice_no IS NOT NULL)
      AND nvl(lv_display_flag, 'N') = 'Y'
   THEN
        JAI_AR_MATCH_TAX_PKG.display_vat_invoice_no(pn_customer_trx_id   => pn_customer_trx_id,
                                                    pv_excise_invoice_no => lv_excise_invoice_no,
                                                    pv_vat_invoice_no    => lv_vat_invoice_no);

         fnd_file.put_line( FND_FILE.LOG
                          , 'The invoice number has been displayed successfully!');
   END IF;

   COMMIT;
   retcode := '0';

   --logging for debug
   IF (ln_proc_level >= ln_dbg_level)
   THEN
     FND_LOG.STRING( ln_proc_level
                   , lv_procedure_name || '.end'
                   , 'Exit procedure'
                   );
   END IF; --l_proc_level>=l_dbg_level
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      retcode := '2';
      errbuf  := SQLERRM;
  END update_reference;

END jai_ar_trx_pkg;

/
