--------------------------------------------------------
--  DDL for Package Body JAI_AR_MATCH_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AR_MATCH_TAX_PKG" 
/* $Header: jai_ar_match_tax.plb 120.19.12010000.29 2010/06/04 08:39:51 boboli ship $ */
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
--|     This package is mainly used for posting the                       |
--|     taxes, VAT/excise invoice num to base AR table.                   |
--|                                                                       |
--| TDD REFERENCE                                                         |
--|        The procedure "display_vat_invoice_no" is referenced by        |
--|        the "VAT Invoice Number on AR Invoice Technical Design.doc"    |
--|                                                                       |
--|                                                                       |
--| PURPOSE                                                               |
--|     PROCEDURE process_batch                                           |
--|     PROCEDURE process_from_order_line                                 |
--|     PROCEDURE process_manual_invoice                                  |
--|     PROCEDURE acct_inclu_taxes                                        |
--|     PROCEDURE display_vat_invoice_no is used for updating the         |
--|     reference field in AR transaction workbench to show the           |
--|     VAT/Excise invoice numbers                                        |
--|                                                                       |
--| HISTORY                                                               |
--|        Bug 5243532. Added by Lakshmi Gopalsami                        |
--|    (1) --|oved the reference to fnd_profile.value('ORG_ID');          |
--|    (2) --|oved the cursor ORG_CUR_UPD as it is same as ORG_CUR        |
--|    (3) --|oved the reference to hr_operating_units and                |
--|        Implemented using caching logic.                               |
--|                                                                       |
--|        Bug 5490479. Added by Harshita                                 |
--|        In the concurrent program, the multi org category has been     |
--|        set to 'S'. To accomodate the same, derived the org_id from    |
--|        the function mo_global.get_current_org_id and populated        |
--|        an internal variable.Used this variable in all places          |
--|        instead of p_org_id.                                           |
--|                                                                       |
--|       Bug 6201263  Added by Sacsethi                                  |
--|       Problem - R12RUP03-ST2: IL TAXES NOT POPULATED IN PAYMENT S     |
--|                 CHEDULE OF CM GENERATED FOR RMA                       |
--|       Solution - 11i forward porting was missing                      |
--|                                                                       |
--|       1. Code changes -                                               |
--|           1.1 Following code added -                                  |
--|           1.1.1 Private procedure added  -                            |
--|                 maintain_mrc                                          |
--|                 maintain_applications                                 |
--|                 maintain_schedules                                    |
--|                 insert_trx_line_gl_dist                               |
--|                 insert_trx_lines                                      |
--|                 delete_trx_data                                       |
--|          1.1.2  Procedure process_from_order_line is changed          |
--|                 as compare to 11i code                                |
--|                                                                       |
--|       BUG 6012570   BRATHOD, File Version 120.9                       |
--|                Re-implemented project changes by --|oving comments    |
--|                and also added p_debug parameter in process_batch      |
--|                procedure                                              |
--|                                                                       |
--|       23-Jan-2008   rchandan for bug#6766561  - file version 120.16   |
--|                  delete from jai_ar_trx_lines_ins_t was missing for   |
--|                  autoinvoiced records. This has been added.           |
--|                  This change is made to merge the fix of version      |
--|                  120.14 made for bug#6691354                          |
--|                                                                       |
--|       Bug 6784276   Changes performed by nprashar . The date columns  |
--|                  actual_closed_date, gl_date_closed of table          |
--|                  ar_payment_schedules_all, are set to a default       |
--|                  value TO_DATE('31/12/4712','DD/MM/RRRR').            |
--|                                                                       |
--|       19-Jan-2010  Bo Li modified for VAT/Excise Number shown         |
--|                    in AR transaction workbench and Bug 9303168# can   |
--|                    be tracked                                         |
--|                                                                       |
--|       09-Mar-2010  Bo Li modified the display_invoice_no to solve the |
--|                    bug which the length of reference is over 150 has  |
--|                    not been truncated and Bug 9453040# can            |
--|                    be tracked                                         |
--|                                                                       |
--|       10-Apr-2010  Allen Yang modified for bug 9485355                |
--|                    (12.1.3 non-shippable Enhancement)                 |
--|                    modified cursor c_ex_inv_no to include nonshippable|
--|                    items.                                             |
--|                                                                       |
--|       05-May-2010  Bo Li Modified for displaying  VAT/EXCISE invoice  |
--|                    on AR transaction when the reference    already    |
--|                    contains the VAT/EXCISE invoice number characters  |
--|                                                                       |
--|       04-Jun-2010  Allen Yang for bug #9709906                        |
--|                    Issue: TST1213.XB1.QA.ORIGINAL TAX AMOUNT SHOULD BE|
--|                           BALANCED TO A CORRECT VALUE BY RMA.         |
--|                    Fix:   In procedure 'process_from_order_line',     |
--|                           added IF condition to avoid using table     |
--|                           lt_receipt_id_tab when lt_receipt_id_tab is |
--|                           NULL.                                       |
--|                                                                       |
--|       04-JUN-2010  Bo Li Modified for Bug#9771955                     |
--|                    Issue - Accounting for inclusive tax is not        |
--|                            correct when the order has been imported   |
--|                            into AR transactions                       |
--|                    Fix - Change the accounting for inclusive tax      |
--|                          Modified the procedure acct_inclu_taxes      |
--|                          and function get_tax_account_id  to get the  |
--|                          correct accounting and insert into           |
--|                          GL_INTERFACE table                           |
--+======================================================================*/

  gv_projects_invoices constant varchar2(30) := 'PROJECTS INVOICES';  /* bug#6012570 (5876390) */
  GV_MODULE_PREFIX     CONSTANT VARCHAR2(30) := 'jai_ar_match_tax_pkg'; -- -- Added by Jia Li on tax inclusive computation on 2007/11/30


PROCEDURE process_batch (
    ERRBUF OUT NOCOPY VARCHAR2,
    RETCODE OUT NOCOPY VARCHAR2,
    P_ORG_ID   IN NUMBER,
    p_all_orgs IN Varchar2
  , p_debug    in varchar2 default 'N'
  , p_called_from IN VARCHAR2 default null /*parameter added for bug#6012570 (5876390)commented by kunkumar for bugno6066813  */
  -- revoked the comments for 6012570
)
IS
lv_error_mesg                   VARCHAR2(255);
var_cust_trx_id                 NUMBER;
var_prev_cust_trx_id            NUMBER(15);
var_rowid                       ROWID;
var_tax_amount                  NUMBER :=0;
var_freight_amount              NUMBER :=0;
var_error_invoice               CHAR(1);
error_from_called_unit          EXCEPTION;
var_error_mesg                  VARCHAR2(1996);
v_org_id                        NUMBER; -- added by sriram - Bug # 2779967
lv_source                       JAI_AR_TRX_INS_LINES_T.source%TYPE ; --rchandan for bug#4428980

ln_org_id                       number ; -- Harshita for Bug 5490479
lv_debug                        varchar2(1)  ;
lv_process_status                VARCHAR2(2);
lv_process_message               VARCHAR2(2000);
    /*
     commented by kunkumar for bug#6066813
     Start, bug#6012570 (5876390)
    */  -- Ended comments to redo the Project changes, 6012570
  --Added by JMEENA for bug#8232976
  cursor c_get_context(cp_customer_trx_id in number) is
      select interface_header_context
      from ra_customer_trx_all
      where customer_trx_id = cp_customer_trx_id;
--End bug#8232976
    lv_invoice_context      ra_customer_trx_all.interface_header_context%type;
    lv_projects_flag        varchar2(1);
    lv_called_from          varchar2(30);

-- Added by Jia Li for Tax Inclusive Computations on 2007/11/30
---------------------------------------------------------------
lv_inclu_tax_flag   jai_ap_tds_years.inclusive_tax_flag%TYPE;
ln_cust_trx_type_id ra_customer_trx_all.cust_trx_type_id%TYPE;

CURSOR cur_separate_flag(pn_org_id IN NUMBER) IS
  SELECT
    nvl(ja.inclusive_tax_flag, 'N')  inclusive_tax_flag
  FROM
    jai_ap_tds_years ja
  WHERE ja.legal_entity_id = pn_org_id
    AND sysdate between ja.start_date and ja.end_date;

CURSOR cur_cust_trx_type(pn_customer_trx_id IN NUMBER) IS
  SELECT
    cust_trx_type_id
  FROM
    ra_customer_trx_all
  WHERE customer_trx_id = pn_customer_trx_id;
---------------------------------------------------------------

    /* Start, bug#6012570 (5876390)
       end commented by kunkumar */

  --Added by Bo Li for VAT/Excise Number shown in AR transaction workbench on 19-Jan-2010 and In Bug 9303168,Begin
  -----------------------------------------------------------------------------------------------
    CURSOR c_delivery(pn_customer_trx_id IN NUMBER, pn_org_id IN NUMBER)
    IS
    SELECT rctl.interface_line_attribute3, rctl.interface_line_attribute6
      FROM ra_customer_trx_all       trx,
           ra_customer_trx_lines_all rctl,
           jai_ar_trx_lines          jrctl,
           JAI_AR_TRXS               jrct
     WHERE trx.customer_trx_id = rctl.customer_trx_id
       AND jrct.customer_trx_id = trx.customer_trx_id
       AND rctl.line_type = 'LINE'
       AND trx.customer_trx_id =
           nvl(pn_customer_trx_id, trx.customer_trx_id)
       AND trx.org_id = nvl(pn_org_id, trx.org_id)
       AND trx.created_from = 'RAXTRX'
       AND rctl.customer_trx_line_id = jrctl.customer_trx_line_id;


    CURSOR c_ex_inv_no(p_delivery_id VARCHAR2, p_order_line_id VARCHAR2)
    IS
    SELECT
      excise_invoice_no
    , vat_invoice_no
    FROM
      JAI_OM_WSH_LINES_ALL
    -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
    -- WHERE delivery_id = p_delivery_id
    WHERE (delivery_id IS NULL OR delivery_id = p_delivery_id)
    -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), end
      AND ( order_line_id = p_order_line_id
          OR order_line_id IN
             ( SELECT
                 line_id
               FROM
                 oe_order_lines_all
               WHERE header_id IN
                     ( SELECT
                         header_id
                       FROM
                         oe_order_lines_all
                       WHERE line_id = p_order_line_id
                     )
                 AND item_type_code = 'CONFIG'
             )
          )
      AND (excise_invoice_no IS NOT NULL OR vat_invoice_no IS NOT NULL);

    ln_delivery_id       NUMBER;
    ln_order_line_id     NUMBER;
    lv_vat_invoice_no    JAI_OM_WSH_LINES_ALL.Vat_Invoice_No%TYPE;
    lv_excise_invoice_no JAI_OM_WSH_LINES_ALL.excise_invoice_no%TYPE;
    lv_display_flag      VARCHAR2(1);
  ------------------------------------------------------------------------------------------------------------------
  --Added by Bo Li for VAT/Excise Number shown in AR transaction workbench on 19-Jan-2010 and In Bug 9303168 ,Begin
BEGIN


/* ------------------------------------------------------------------------------------------------------------------------
CHANGE HISTORY:
S.No      DATE                Author AND Details
---------------------------------------------------------------------------------------------------------------------------
1     04-MAY-2002       Sriram. Procedure Created . This Procedure will be
                              invoked by the concurrent
                            'India Local Concurrent Procedure for processing Order Lines to AR' - JAINMREQ .
                            This will be only applicable for Invoiced Created from Order Entry.
2     09-MAY-2002       Sriram. Adding fnd_file.put_line -
                              to write logs from concurrent program.
3     24-May-2002             Sriram. Set the Code so that it works in the batch mode .
4.    09-JAN-2003             Sriram - Bug # 2740546 - File Version is 615.1
                                      Added the substr function to the update statement that updates the
                                      JAI_AR_TRX_INS_LINES_T table . If due to some reason the error message is
                                      very long ,then it can be a potential problem.Because of this the program
                                      should not halt.
5.    08/04/2003              Sriram  - Bug # 2779967
                              Added logic to see that only records that belong to the current operating unit need
                              to be picked up for processing.This was done because records are inserted into the
                              JAI_AR_TRX_INS_LINES_T table from various 'India Local Receivables' responsibility
                              attached to various org ids , The concurrent program is not scheduled , but run by
                              the user , it picks up the records not only for the current org id but also for other
                              org ids as well which causes the problem.

6.    22/08/2003              Sriram - Bug # 3068927.
                              Added a new parameter P_ORG_ID to the Procedure. This has been done a new parameter
                              has been added in the concurrent program definition "JAINMREQ" to enable conflict domains.
                              The Concurrent program 'India Local Concurrent For Processing Order Lines to AR" has
                              been set incompatible to itself and also to autoinvoice import program . Because of the
                              previous bugfix , the concurrent has to be scheduled for each org id , hence causing performance
                              bottleneck because until one concurrent program runs , all others have to wait in pending state.
                              Hence , by using the conflict domains concept with the domain as org id , we are ensuring that
                              the concurrent are incompatible to itself only to the extent of those running in the same org id


7.    30/10/2003              Added another parameters P_all_orgs . This parameter is used for indicating whether to process for all
                              org ids or for the org id entered.
                              P_Org_id parameter is set as an optional parameter

8.    09/03/2004              ssumaith - bug# 3491600 file version 618.1

                              incorrect exception handling was done. variable width was smaller than the actual
                              width of the string assigned to the variable. This was causing the exception
                              'numeric or value error.'

9. 2004/08/11  Aiyer for bug#3826140. Version#115.1
                Issue:-
                 Lines marked as deleted get reprocessed when a record is submitted for reprocessing from the the India Resubmit Errored OM
                 Tax Records form.

                Reason:-
                The current procedure previously used to also consider those records which have been marked as deleted.

                Fix:-
                 The cursor temp_rec has been modified to discard all those lines which have been marked as 'R' or 'D'.

                Dependency Due to this Bug:-
                  None

10. 2004/10/21  Aiyer for bug#3839560. Version#115.2
                  Issue:-
                   India Local Concurrent to Process Order Lines To AR corrrupts data in Base AR tables when two instances of this program
                   are run simultaneously with Process of Orgs = 'Y'

                  Reason:-
                    This is because the procedure ja_in_ra_order_lines_insert does not implement locking of records while processing in batch mode with Process of Orgs = 'Y'

                  Fix:-
                    This fix has been done in the procedure ja_ar_rec_process_validate.val_revrec_records called from procedure ja_in_ra_order_lines_insert.

                  Dependency Due to this Bug:-
                   This version of the file is dependent on the file jai_ar_match_tax_pkg.process_from_order_line version (115.1) due to the additions of a new parameter p_org_id.
                   It is also dependent on ja_in_ar_rec_prc_val_b.pls (115.0),ja_in_ar_rec_prc_val_s.pls (115.0) as jai_ar_match_tax_pkg.process_from_order_line version (115.1) calls
                   ja_ar_rec_process_validate.val_revrec_records(115.0).

11. 08-Jun-2005  Version 116.2 jai_ar_match_tax -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
    as required for CASE COMPLAINCE.

12  14-Jun-2005  rchandan for bug#4428980, Version 116.3
                 Modified the object to --|ove literals from DML statements and CURSORS.

13  23-Jun-2005  Ramananda for bug#4468353   ,version 116.4
                 Issue:
                   Impact on IL due to SLA Uptake by AR
     Reason:
                India Localization taxes and charges are inserted into RA_CUSTOIMER_TRX_LINES_ALL and
                RA_CUST_LINES_GL_DIST_ALL, as Tax and Freight lines.Since India Localization directly updates
                the above-mentioned tables, the accounting happens through the base AR accounting itself.
                In R12, since the AR accounting will be handled through SLA IL tax lines that are inserted
                in the RA_CUSTOIMER_TRX_LINES_ALL and RA_CUST_TRX_LINE_GL_DIST_ALL will be impacted
      Fix:
            IL should ensure the following while inserting into RA_CUST_LINES_GL_DIST_ALL table:
              1. The tax and freight lines that are inserted should be inserted before the associated base item lines
                     are posted to GL. This should be achieved by checking the Posting_Status by IL.

                     A new cursor is created to check the gl_posted_date for the base item. If the gl_posted_date is null,
                     then it inserts the tax and freight lines

             2. Each of the Tax and freight lines should carry the same Accounting event information as the base
                 line. Event_Id field should be punched with the value as on the Item line. This value can be derived
                 from the call to 'Event Engine' for each line.  IL will call the Event Engine API, and derive the
                 Event_Id for the base item line. This Event_Id will be punched to all the tax and freight lines related
                 to the base item line

                 A call is made to ARP_XLA_EVENTS.CREATE_EVENTS(p_xla_ev_rec => l_xla_event) to update the event_id field

              Issue:
                 Impact on IL due to ebTax Uptake by AR
              Reason:
                India Localization tax lines are inserted into AR transaction tables with an AR Tax code (Vat_Tax_Id).
              In R12, the AR tax engine will be replace by ebTax. Due to this, all the tax code related setups will
              be made in ebTax and not in AR. Since India Localization uses the Vat_Tax_Id for populating the
              tax lines into the AR transaction tables and it will not uptake ebTax, it would be mandatory for
              IL to have setups under the ebTax that can be used in the above transactions.

             Fix:
                    Query logic is changed. Instead of querying vat_Tax_id from ar_vat_tax_all , tax_rate_id of zx_rates_b
              is queried

14      25-Apr-2007  cbabu for Bug#6012570 (5876390), File Version 120.5 (115.5)
                      FP: Project billing implementation.
                          New concurrent JAINIPTR created for Project taxes to flow into AR and related
                          changes are made in process_batch

                          Excise invoice will not be updated in the Referece_field for Project Invoices as it is
                          giving error in the Invoices Form when Queried for Project Invoice

15.    17-09-2007  sacsethi for Bug#6407648  , File Version 120.3.12000000.3/ 120.11

                    Problem - R.TST1203.XB2.QA:INCORRECT IL TAXES ON RMA CM
                    Reason - Variable ln_created_by  ,ld_creation_date  initialization was missing .
                    Solution - Procedure maintain_applications is modified with initialization.

16.   18-sep-2007   anujsax for Bug#5636544, File Version 120.11
                    forward porting R11 bug 5629319 into R12 bug 5636544

17.   26-jan-2008   ssumaith - bug#6776085
                    following changes are done.
                    a. --|oved the code changes done for bug#5636544
                    b.did the code changes into the mainline for bug#6764386

18.   28-Jan-2009 CSahoo for bug#7645588, File Version 120.19.12010000.2
                  Issue: TAX ENTRIES ARE NOT VISIBLE IN DISTRIBUTIONS
                  Fix: Modified the code in the process_from_order_line. added the cursor cur_event_id
                  to get the event id. This cursor would get called only in case of a credit memo having
                  accounting rules defined. This would provide the event id of the REC account class.
                  The tax entries also need to be latched to this event id. so passed this event id to the
                  procedure insert_trx_line_gl_dist to get stamped in the table ra_cust_trx_line_gl_dist_all
                  table.
19 06-FEB-2009 JMEENA for bug#8232976
      Created cursor c_get_context and to get the interface_header_context of the invoice and checked if it is PROJECT INVOICE.

20.   27-Feb-2009 CSahoo for bug#8276902, File Version 120.19.12010000.4
                  Issue: UNABLE TO ACCOUNT CREDIT MEMOS IN AR JAN-09
                  Fix: Added the following OR condition in the procedure process_from_order_line
                       "OR rec_customer_trx_lines.interface_line_context = gv_projects_invoices"

21. 02-Nov-2009   CSahoo for bug#8325824, File Version 120.19.12010000.11
                  Issue: REW:ROOTCAUSE: UNABLE TO POST AR TRANSACTIONS UPTO GL.
                  Fix: added the code to populate the AR distribution table. added the procedure
                       insert_ar_dist_entries.

21 09-dec-2009 vkaranam for bug#9177024,file version 120.19.12010000.12
               Issue:Taxes doesn't become zero in Base AR Transaction screen even after deleting
  the taxes in Localized AR Screen
               Fix:
             Added the call to delete_trx_data  in process_manual_invoice procedure for
	     manual transactions.
22  23-MAR-2009  vkaranam for bug#9230409
                 Issue:
                 AR INVOICE IS SHOWING WRONG BALANCE WHENEVER A RMA CREDIT MEMO IS APPLIED.
                 Reason:
                The problem is that when the credit memo
                is created, it automatically unapplies the Receipt and applies the Credit Memo and
                then re-applies the receipt for the remaining amount. This happens
                 fine for the base amount. But the same is not happening for the tax amount.

                 Hence the incorrect invoice balance issue.

                 The procedure jai_ar_match_tax_pkg.process_from_order_line
                  is responsible for populating the IL taxes in base AR table. Here we do not
                   check if a cash receipt is already applied to the invoice. The code just
                   directly applies the tax amount of the credit memo to the invoice. it does
                   not unapply the tax amount of the cash receipt applied before. Thats the
                   reason why this issue is coming.

                 fix:
                 changes are done in process_from_order_line procedure.
                 used base AR APIs to unapply the receipt and then appying the remaining.

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version    Current Bug    Dependent           Files                                           Version   Author   Date          --|arks
Of File                           On Bug/Patchset    Dependent On
jai_ar_match_tax_pkg.process_batch
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
115.2               3839560      IN60105D2             jai_ar_match_tax_pkg.process_from_order_line                     115.1       Aiyer   21/10/2004  New parameter p_org_id added
                                                       ja_in_ar_rec_prc_val_s.pls                      115.0       Aiyer   21/10/2004  jai_ar_match_tax_pkg.process_from_order_line calls
                                                       ja_in_ar_rec_prc_val_b.pls                      115.0       Aiyer   21/10/2004
                                                                                                                                       ja_ar_rec_process_validate.val_revrec_records
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/* Bug 5243532. Added by Lakshmi Gopalsami
   --|oved the reference to fnd_profile.value('ORG_ID')
v_org_id := FND_PROFILE.VALUE('ORG_ID');
*/
lv_debug := nvl(p_debug,'N');
lv_debug := 'Y';
fnd_file.put_line(FND_FILE.LOG,' Entering Procedure - jai_ar_match_tax_pkg.process_batch');

ln_org_id := mo_global.get_current_org_id() ; -- Harshita for Bug 5490479
/*commented by kunkumar for bug# 6066813 Start
 6012570 (5876390) -- Revoked the comments for 6012570*/
if p_called_from is null then
  lv_called_from := 'ORDER_ENTRY';
else
  lv_called_from := p_called_from;
end if;
    -- End commented by kunkumar for 6066813 */ revoked the comments for 6012570
if p_all_orgs = 'Y' or p_all_orgs = 'y' then
   v_org_id := NULL;
else
   v_org_id := ln_org_id; -- p_org_id -- Harshita for Bug 5490479
end if;

fnd_file.put_line(FND_FILE.LOG,' Org id retreived is  - ' || v_org_id || ' Generate for All orgs is : ' || p_all_orgs);

       lv_source := 'RAXTRX';
       FOR temp_rec IN
    (
     SELECT  DISTINCT  customer_trx_id
                FROM  JAI_AR_TRX_INS_LINES_T
                WHERE   source = lv_source
                AND     org_id = nvl(ln_org_id, org_id)
                MINUS
                SELECT  customer_trx_id
                FROM    JAI_AR_TRX_INS_LINES_T temp_dtl
                WHERE   source = 'RAXTRX'
                AND     org_id = nvl(ln_org_id, org_id)
                AND     error_flag IN ('R','D')
    )
       LOOP
/*Start commented by kunkumar for bug#6066813
         -- Start, bug#6012570 (5876390)
       */ -- Revoked comments for projects 6012570
        lv_projects_flag     := null;
        lv_invoice_context   := null;
--Added by JMEENA for bug#8232976
        open c_get_context(temp_rec.customer_trx_id);
        fetch c_get_context into lv_invoice_context;
        close c_get_context;
--End bug#8232976
        lv_projects_flag := is_this_projects_context(lv_invoice_context);
        if lv_called_from = gv_projects_invoices
          and lv_projects_flag = jai_constants.no
        then
          -- no need to process this customer trx
          goto continue_with_next;

        elsif lv_called_from <> gv_projects_invoices
          and lv_projects_flag = jai_constants.yes
        then
          -- no need to process this customer trx
          goto continue_with_next;
        end if;
        -- End, bug#6012570 (5876390)
        -- End commented by kunkumar for bug 6066813*/ -- revoked the comments, 6012570
         BEGIN

            var_cust_trx_id := temp_rec.customer_trx_id;

     jai_ar_match_tax_pkg.process_from_order_line(
                                   temp_rec.customer_trx_id,
           lv_debug       ,
           lv_process_status ,
           lv_process_message
                                );

      errbuf := lv_process_message ;

                /*
                        Get the Status of the retcode flag - if it is not 2 it means success
                        else , it means error . On an Error Condition , rollback the transaction -
                        set the error_flag in the table for the
        CUSTOMER_TRX_ID / LINK_TO_CUST_TRX_LINE_ID
        COMBINATION  to 'R' and err_mesg to
                        to the ERRBUF returned from the procedure.
                */

                -- The Following lines are for testing exception  conditions.
                -- Forcing an exception to occur and test the behaviour of the program

                /*
                IF temp_rec.link_to_cust_trx_line_id = 56673 THEN
                     RAISE NO_DATA_FOUND;
                END IF;
                */


                IF lv_process_message IS NOT NULL  THEN

                      /*
                         Error has Occured in the jai_ar_match_tax_pkg.process_from_order_line procedure .
                         Rollback all inserts , updates , deletes which have happened in
                         the procedure and update the temp_lines_insert procedure
                         setting the error flag to 'R' and err_mesg to ERRBUF
                      */

                  var_error_mesg := 'Error from called unit jai_ar_match_tax_pkg.process_from_order_line';
                  RAISE  error_from_called_unit;

                -- Added by Jia Li for Tax Inclusive Computations on 2007/11/30, Begin
                -- TD17-Changed Account Inclusive taxes in AR separately
                -----------------------------------------------------------------------
                ELSE
                  -- Check if inclusive taxes needs to be accounted separately
                  OPEN cur_separate_flag(v_org_id);
                  FETCH cur_separate_flag INTO lv_inclu_tax_flag;
                  CLOSE cur_separate_flag;

                  OPEN cur_cust_trx_type(temp_rec.customer_trx_id);
                  FETCH cur_cust_trx_type INTO ln_cust_trx_type_id;
                  CLOSE cur_cust_trx_type;

                  IF lv_inclu_tax_flag = 'Y'
                  THEN
                    acct_inclu_taxes( pn_customer_trx_id  => temp_rec.customer_trx_id
                                    , pn_org_id           => v_org_id
                                    , pn_cust_trx_type_id => ln_cust_trx_type_id
                                    , xv_process_flag     => lv_process_status
                                    , xv_process_message  => lv_process_message);
                  END IF;

                  IF lv_process_status <> jai_constants.successful
                  THEN
                    RAISE  error_from_called_unit;
                  END IF;  -- lv_process_status <> 'SS'
                -----------------------------------------------------------------------
                -- Added by Jia Li for Tax Inclusive Computations on 2007/11/30, End
                /* ssumaith bug# 6685976(6766561) */
          delete from jai_ar_trx_ins_lines_t
          WHERE  customer_trx_id = temp_rec.customer_trx_id;

                END IF;

    EXCEPTION
      WHEN OTHERS THEN
         IF var_error_mesg IS NULL  THEN
           -- the exception condition is not because of returned error from inner procedure
           errbuf  := substr(SQLERRM,1,200);
           var_error_mesg := errbuf || 'Error in loop (not in jai_ar_match_tax_pkg.process_from_order_line procedure) ';
         END IF;

         ROLLBACK;

         UPDATE JAI_AR_TRX_INS_LINES_T
         SET    ERROR_FLAG = 'R' ,
                ERR_MESG   =  SUBSTR(ERRBUF,1,230) --  substr added by sriram Bug # 2740546
         WHERE  CUSTOMER_TRX_ID = var_cust_trx_id;


         COMMIT;

         fnd_file.put_line(FND_FILE.LOG , 'Error - '  || ' When Processing '||
                               temp_rec.customer_trx_id );
         fnd_file.put_line(FND_FILE.LOG , 'Error is '  || var_error_mesg );

         var_error_invoice := 'Y';

    END;

      --Added by Bo Li for VAT/Excise Number shown in AR transaction workbench on 19-Jan-2010 and In Bug 9303168,Begin
      ---------------------------------------------------------------------------------------------------------
      BEGIN
        fnd_file.put_line(FND_FILE.LOG,
                          'Display the VAT/Excise number in AR Transaction workbench');

        --when there is no error happening in the above process
        IF nvl(var_error_invoice, 'N') <> 'Y'
        THEN

          -- Initial the invoice number
           lv_excise_invoice_no := NULL;
           lv_vat_invoice_no := NULL;

          OPEN  c_delivery(temp_rec.customer_trx_id, v_org_id);
          FETCH c_delivery
          INTO  ln_delivery_id, ln_order_line_id;
          CLOSE c_delivery;

          OPEN
            c_ex_inv_no(ln_delivery_id
          , ln_order_line_id);
          FETCH
            c_ex_inv_no
          INTO
            lv_excise_invoice_no
          , lv_vat_invoice_no;
          CLOSE c_ex_inv_No;

          lv_display_flag := FND_PROFILE.VALUE('JAI_DISP_VAT_EXC_INV_AR_TRX_REF');

          FND_FILE.put_line(FND_FILE.LOG,
                            'JAI:Include Excise and VAT Invoice Number in AR transactions - Referencde is set to ' ||
                            lv_display_flag);

          -- when then profile "JAI:Include Excise and VAT Invoice Number
          -- in AR transactions - Referencde" set to "Yes"

          FND_FILE.put_line( FND_FILE.LOG
                            ,'temp_rec.customer_trx_id :' || temp_rec.customer_trx_id);
          FND_FILE.put_line( FND_FILE.LOG
                            , 'lv_excise_invoice_no :' ||lv_excise_invoice_no);
          FND_FILE.put_line( FND_FILE.LOG
                            , 'lv_vat_invoice_no :' || lv_vat_invoice_no);

          -- when the two inovice number has not been generated
          -- and the profile has been set as "Yes", the default profile value is "No"
          IF (lv_excise_invoice_no IS NOT NULL OR
             lv_vat_invoice_no IS NOT NULL) AND
             nvl(lv_display_flag, 'N') = 'Y'
          THEN
            display_vat_invoice_no( pn_customer_trx_id   => temp_rec.customer_trx_id
                                  , pv_excise_invoice_no => lv_excise_invoice_no
                                  , pv_vat_invoice_no    => lv_vat_invoice_no);

            fnd_file.put_line(FND_FILE.LOG,'The invoice number has been displayed successfully!');
          END IF;   --lv_excise_invoice_no IS NOT NULL

        END IF;--nvl(var_error_invoice, 'N') <> 'Y'
      END;
      -----------------------------------------------------------------------------------------------------
      --Added by Bo Li for VAT/Excise Number shown in AR transaction workbench on 19-Jan-2010 and In Bug 9303168,End

   <<continue_with_next>>
     NULL;

 END LOOP;

 -- write here to log the successful processing for last invoice

 IF var_error_invoice <> 'Y' THEN
     fnd_file.put_line(FND_FILE.LOG, 'Processed Customer_trx_id - ' ||var_cust_trx_id);
 END IF;

 COMMIT;
 fnd_file.put_line(FND_FILE.LOG,'Successfully Exiting PROCEDURE - jai_ar_match_tax_pkg.process_batch');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

        UPDATE JAI_AR_TRX_INS_LINES_T
                      SET    ERROR_FLAG = 'R' ,
                             ERR_MESG = SUBSTR(ERRBUF,1,230) --  substr added by sriram Bug # 2740546
                      WHERE  CUSTOMER_TRX_ID = var_cust_trx_id;

        COMMIT;

        var_tax_amount :=0;
    var_freight_amount :=0;

    ERRBUF := SQLERRM;
        RETCODE := 2;
    Fnd_file.put_line(FND_FILE.LOG,'EXCEPTION Occured - ' || ERRBUF || ' WHILE Processing Customer_trx_id - ' || var_cust_trx_id );
END process_batch;

------------------------------------------------ ---------------------------------------
--=========================================================================================--
  --This procedure updates the MRC data for ra_cust_trx_line_gl_dist_all, ar_payment_schedules_all,
  --ar_receivable_applications_all
  --=========================================================================================--

  PROCEDURE maintain_mrc( p_customer_trx_id       IN  ra_customer_trx_all.customer_trx_id%TYPE,
                          p_previous_cust_trx_id  IN  ra_customer_trx_all.customer_trx_id%TYPE DEFAULT NULL,
                          p_called_from           IN  VARCHAR2,
                          p_process_status        OUT NOCOPY  VARCHAR2,
                          p_process_message       OUT NOCOPY  VARCHAR2)
  IS
   lv_imported_trx                  VARCHAR2(10) := 'IMPORTED';
   ln_gl_dist_id ra_cust_trx_line_gl_dist_all.cust_trx_line_gl_dist_id%TYPE;
   lv_account_class_rec             VARCHAR2(10) := 'REC';


  CURSOR c_proc_exists(cp_object_name    user_procedures.object_name%type,
                       cp_procedure_name user_procedures.procedure_name%type) IS
  SELECT 1
  FROM  user_procedures
  WHERE object_name    = cp_object_name
  AND   procedure_name = cp_procedure_name ;

  CURSOR cur_payment_schedule_mrc(cp_customer_trx_id  ra_customer_trx_all.customer_trx_id%TYPE)
  IS
  SELECT  payment_schedule_id
  FROM    ar_payment_schedules_all
  WHERE   customer_trx_id = cp_customer_trx_id;

    --get the cust_trx_line_gl_dist_id for the REC row from ra_cust_trx_line_gl_dist_all
  CURSOR cur_gl_dist(cp_customer_trx_id      ra_customer_trx_all.customer_trx_id%TYPE)
  IS
  SELECT  cust_trx_line_gl_dist_id
  FROM    ra_cust_trx_line_gl_dist_all
  WHERE   customer_trx_id = cp_customer_trx_id
  AND     account_class = lv_account_class_rec --'REC'
  AND     latest_rec_flag = jai_constants.yes; --'Y';

  /* Ramananda for bug#5219225. */
  lv_object_name    user_procedures.object_name%type ;
  lv_procedure_name user_procedures.procedure_name%type ;
  ln_exists         NUMBER := 0 ;
  lv_sqlstmt        VARCHAR2(2000) ;

  BEGIN
    p_process_status := jai_constants.successful;
    p_process_message := NULL;

    --get the cust_trx_line_gl_dist_id for the REC row from ra_cust_trx_line_gl_dist_all
    open  cur_gl_dist(p_customer_trx_id);
    fetch cur_gl_dist into ln_gl_dist_id;
    close cur_gl_dist;

    /* Ramananda for bug#5219225. START. Modified the following if..endif. and the call to be dynamic using execute immediate */
    lv_object_name    := 'AR_MRC_ENGINE' ;
    lv_procedure_name := 'MAINTAIN_MRC_DATA' ;

    OPEN c_proc_exists(lv_object_name, lv_procedure_name) ;
    FETCH c_proc_exists INTO ln_exists ;
    CLOSE c_proc_exists ;
    IF ln_exists = 1 THEN
      --Update the mrc data for ra_cust_trx_line_gl_dist_all
      --This is done, irrespective of whether the transaction_type is CM or Invoice
      /* Commented for bug# 5219225
          ar_mrc_engine.maintain_mrc_data(
                        p_event_mode        => 'UPDATE',
                        p_table_name        => 'RA_CUST_TRX_LINE_GL_DIST',
                        p_mode              => 'SINGLE',
                        p_key_value         =>  ln_gl_dist_id); */

      lv_sqlstmt := 'BEGIN ar_mrc_engine.maintain_mrc_data(
                                                            p_event_mode        => ''UPDATE'',
                                                            p_table_name        => ''RA_CUST_TRX_LINE_GL_DIST'',
                                                            p_mode              => ''SINGLE'',
                                                            p_key_value         =>  :1
                                                          );
                      END; ';
        EXECUTE IMMEDIATE lv_sqlstmt USING ln_gl_dist_id ;

    --if the program is called from process_imported_invoice
    IF p_called_from = lv_imported_trx THEN
      FOR rec_mrc IN cur_payment_schedule_mrc(p_customer_trx_id)
      LOOP
        /* Commented for bug# 5219225
           ar_mrc_engine.maintain_mrc_data(
                       p_event_mode        => 'UPDATE',
                       p_table_name        => 'AR_PAYMENT_SCHEDULES',
                       p_mode              => 'SINGLE',
                       p_key_value         =>  rec_mrc.payment_schedule_id); */

        lv_sqlstmt := 'BEGIN ar_mrc_engine.maintain_mrc_data(
                                                           p_event_mode        => ''UPDATE'',
                                                           p_table_name        => ''AR_PAYMENT_SCHEDULES'',
                                                           p_mode              => ''SINGLE'',
                                                           p_key_value         =>  :1
                                                           );
                        END; ';
        EXECUTE IMMEDIATE lv_sqlstmt USING rec_mrc.payment_schedule_id ;
      END LOOP;
    END IF;

      --If the current transaction is a CM
      if p_previous_cust_trx_id IS NOT NULL THEN

        FOR rec_mrc IN cur_payment_schedule_mrc(p_previous_cust_trx_id)
        LOOP

          lv_sqlstmt := 'BEGIN  ar_mrc_engine.maintain_mrc_data(
                                                               p_event_mode        => ''UPDATE'',
                                                               p_table_name        => ''AR_PAYMENT_SCHEDULES'',
                                                               p_mode              => ''SINGLE'',
                                                               p_key_value         =>  :1
                                                              );
                         END; ';
          EXECUTE IMMEDIATE lv_sqlstmt USING rec_mrc.payment_schedule_id ;
        END LOOP;

        for rec_ar_appl in
          ( select receivable_application_id
            from   ar_receivable_applications_all
            where  customer_trx_id = p_customer_trx_id
          )
        LOOP

          lv_sqlstmt := 'BEGIN  ar_mrc_engine.maintain_mrc_data(
                                                              p_event_mode        => ''UPDATE'',
                                                              p_table_name        => ''AR_RECEIVABLE_APPLICATIONS'',
                                                              p_mode              => ''SINGLE'',
                                                              p_key_value         =>  :1
                                                              );
                         END;' ;
          EXECUTE IMMEDIATE lv_sqlstmt USING rec_ar_appl.receivable_application_id ;
        END LOOP;
      END IF;
    END IF ;
  /* Ramananda for bug#5219225. END */

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status  := jai_constants.unexpected_error;
      p_process_message := SUBSTR(SQLERRM,1,300);
  END maintain_mrc;
 --=========================================================================================--
  --This procedure maintains the history of ar_receivable_applications_all in jai_ar_rec_appl_audits
  --=========================================================================================--

  PROCEDURE maintain_applications(p_customer_trx_id             IN  ra_customer_trx_all.customer_trx_id%TYPE,
                                  p_receivable_application_id   IN  jai_ar_rec_appl_audits.receivable_application_id%TYPE,
                                  p_concurrent_req_num          IN  NUMBER,
                                  p_request_id                  IN  NUMBER,
                                  p_operation_type              IN  VARCHAR2,
                                  p_rec_appl_audit_id           IN OUT NOCOPY NUMBER,
                                  p_process_status              OUT NOCOPY  VARCHAR2,
                                  p_process_message             OUT NOCOPY  VARCHAR2)
  IS
    CURSOR cur_rec_appl_audits_s
    IS
    SELECT  jai_ar_rec_appl_audits_s.nextval
    FROM    dual;

    ln_created_by         jai_ar_payment_audits.created_by%TYPE;
    ld_creation_date      jai_ar_payment_audits.creation_date%TYPE;
    ln_last_updated_by    jai_ar_payment_audits.last_updated_by%TYPE;
    ld_last_update_date   jai_ar_payment_audits.last_update_date%TYPE;
    ln_last_update_login  jai_ar_payment_audits.last_update_login%TYPE;

  BEGIN
    p_process_status := jai_constants.successful;
    p_process_message := NULL;

    --set the values for WHO columns
    ln_last_updated_by    := TO_NUMBER(fnd_profile.value('USER_ID'));
    ld_last_update_date   := SYSDATE;
    ln_last_update_login  := TO_NUMBER(fnd_profile.value('LOGIN_ID'));

    --In case of operation_type = 'UPDATE', the parameter p_payment_audit_id shall have a value
    --In case of 'INSERT', the value for parameter p_payment_audit_id shall be null
    IF p_rec_appl_audit_id IS NULL THEN
      OPEN  cur_rec_appl_audits_s;
      FETCH cur_rec_appl_audits_s INTO p_rec_appl_audit_id;
      CLOSE cur_rec_appl_audits_s;
    END IF;

    IF p_operation_type = 'INSERT' THEN

      -- Date 17/09/2007 by sacsethi for bug 6407648
      ln_created_by     := ln_last_updated_by;
      ld_creation_date  := ld_last_update_date;

      INSERT INTO jai_ar_rec_appl_audits(
              rec_appl_audit_id,
              concurrent_req_num,
              customer_trx_id,
              receivable_application_id,
              aapp_old,
              acctd_aapp_from_old,
              acctd_aapp_to_old,
              tapp_old,
              fapp_old,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login
              )
      SELECT  p_rec_appl_audit_id,
              p_concurrent_req_num,
              p_customer_trx_id,
              p_receivable_application_id,
              amount_applied,
              acctd_amount_applied_from,
              acctd_amount_applied_to,
              tax_applied,
              freight_applied,
              ln_created_by,
              ld_creation_date,
              ln_last_updated_by,
              ld_last_update_date,
              ln_last_update_login
      FROM    ar_receivable_applications_all
      WHERE   customer_trx_id             = p_customer_trx_id
      AND     receivable_application_id   = p_receivable_application_id;

    ELSIF p_operation_type = 'UPDATE' THEN
      UPDATE  jai_ar_rec_appl_audits a
      SET     (aapp_new,
              acctd_aapp_applied_from_new,
              acctd_aapp_applied_to_new,
              tapp_new,
              fapplied_new,
              last_updated_by,
              last_update_date,
              last_update_login) =
              (SELECT   amount_applied,
                        acctd_amount_applied_from,
                        acctd_amount_applied_to,
                        tax_applied,
                        freight_applied,
                        ln_last_updated_by,
                        ld_last_update_date,
                        ln_last_update_login
              FROM      ar_receivable_applications_all b
              WHERE     customer_trx_id           = a.customer_trx_id
              AND       receivable_application_id = a.receivable_application_id)
      WHERE   customer_trx_id           = p_customer_trx_id
      AND     receivable_application_id = p_receivable_application_id
      AND     rec_appl_audit_id         = p_rec_appl_audit_id;

    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_process_status  := jai_constants.unexpected_error;
      p_process_message := SUBSTR(SQLERRM,1,300);
  END maintain_applications;

  --=========================================================================================--
  --This procedure maintains the history of ar_payment_schedules_all in jai_ar_payment_audits
  --=========================================================================================--

  PROCEDURE maintain_schedules( p_customer_trx_id           IN          ra_customer_trx_all.customer_trx_id%TYPE,
                                p_payment_schedule_id       IN          ar_payment_schedules_all.payment_schedule_id%TYPE DEFAULT NULL,
                                p_cm_customer_trx_id        IN          ra_customer_trx_all.customer_trx_id%TYPE DEFAULT NULL,
                                p_invoice_customer_trx_id   IN          ra_customer_trx_all.customer_trx_id%TYPE,
                                p_concurrent_req_num        IN          NUMBER,
                                p_request_id                IN          NUMBER,
                                p_operation_type            IN          VARCHAR2,
                                p_payment_audit_id          IN OUT NOCOPY jai_ar_payment_audits.payment_audit_id%TYPE,
                                p_process_status            OUT NOCOPY  VARCHAR2,
                                p_process_message           OUT NOCOPY  VARCHAR2)
  IS




    CURSOR cur_payment_audits_s
    IS
    SELECT  jai_ar_payment_audits_s.nextval
    FROM    dual;

    ln_created_by         jai_ar_payment_audits.created_by%TYPE;
    ld_creation_date      jai_ar_payment_audits.creation_date%TYPE;
    ln_last_updated_by    jai_ar_payment_audits.last_updated_by%TYPE;
    ld_last_update_date   jai_ar_payment_audits.last_update_date%TYPE;
    ln_last_update_login  jai_ar_payment_audits.last_update_login%TYPE;
  BEGIN
    p_process_status  := jai_constants.successful;
    p_process_message := NULL;

    --set the values for WHO columns
    ln_last_updated_by    := TO_NUMBER(fnd_profile.value('USER_ID'));
    ld_last_update_date   := SYSDATE;
    ln_last_update_login  := TO_NUMBER(fnd_profile.value('LOGIN_ID'));

    --In case of operation_type = 'UPDATE', the parameter p_payment_audit_id shall have a value
    --In case of 'INSERT', the value for parameter p_payment_audit_id shall be null
    IF p_payment_audit_id IS NULL THEN
      OPEN  cur_payment_audits_s;
      FETCH cur_payment_audits_s INTO p_payment_audit_id;
      CLOSE cur_payment_audits_s;
    END IF;

    IF p_operation_type = 'INSERT' THEN

      ln_created_by     := ln_last_updated_by;
      ld_creation_date  := ld_last_update_date;

      INSERT INTO jai_ar_payment_audits(
              payment_audit_id,
              concurrent_req_num,
              payment_schedule_id,
              cm_customer_trx_id,
              invoice_customer_trx_id,
              original_customer_trx_id,
              ado_old,
              to_old,
              fo_old,
              aapp_old,
              adr_old,
              fr_old,
              tr_old,
              acctd_adr_old,
              acred_old,
              alio_old,
              status_old,
              gl_date_closed_old,
              actual_date_closed_old,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login
              )
      SELECT  p_payment_audit_id,
              p_concurrent_req_num,
              payment_schedule_id,
              p_cm_customer_trx_id,
              p_invoice_customer_trx_id,
              p_customer_trx_id,
              amount_due_original,
              tax_original,
              freight_original,
              amount_applied,
              amount_due_remaining,
              freight_remaining,
              tax_remaining,
              acctd_amount_due_remaining,
              amount_credited,
              amount_line_items_original,
              status,
              gl_date_closed,
              actual_date_closed,
              ln_created_by,
              ld_creation_date,
              ln_last_updated_by,
              ld_last_update_date,
              ln_last_update_login
      FROM    ar_payment_schedules_all
      WHERE   customer_trx_id     = p_customer_trx_id
      AND     payment_schedule_id = NVL(p_payment_schedule_id, payment_schedule_id);

    ELSIF p_operation_type = 'UPDATE' THEN
      UPDATE  jai_ar_payment_audits a
      SET     (ado_new,
              to_new,
              fo_new,
              aapp_new,
              adr_new,
              fr_new,
              tr_new,
              acctd_adr_new,
              acred_new,
              alio_new,
              status_new,
              gl_date_closed_new,
              actual_date_closed_new,
              last_updated_by,
              last_update_date,
              last_update_login) =
              (SELECT   amount_due_original,
                        tax_original,
                        freight_original,
                        amount_applied,
                        amount_due_remaining,
                        freight_remaining,
                        tax_remaining,
                        acctd_amount_due_remaining,
                        amount_credited,
                        amount_line_items_original,
                        status,
                        gl_date_closed,
                        actual_date_closed,
                        ln_last_updated_by,
                        ld_last_update_date,
                        ln_last_update_login
                FROM    ar_payment_schedules_all b
                WHERE   customer_trx_id     = a.original_customer_trx_id
                AND     payment_schedule_id = a.payment_schedule_id)
      WHERE   original_customer_trx_id      = p_customer_trx_id
      AND     payment_schedule_id           = NVL(p_payment_schedule_id, payment_schedule_id)
      AND     payment_audit_id              = p_payment_audit_id;

    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_process_status  := jai_constants.unexpected_error;
      p_process_message := SUBSTR(SQLERRM,1,300);
  END maintain_schedules;

PROCEDURE insert_trx_line_gl_dist(p_account_class             IN  ra_cust_trx_line_gl_dist_all.account_class%TYPE,
                                    p_account_set_flag          IN  ra_cust_trx_line_gl_dist_all.account_set_flag%TYPE,
                                    p_acctd_amount              IN  ra_cust_trx_line_gl_dist_all.acctd_amount%TYPE,
                                    p_amount                    IN  ra_cust_trx_line_gl_dist_all.amount%TYPE,
                                    p_code_combination_id       IN  ra_cust_trx_line_gl_dist_all.code_combination_id%TYPE,
                                    p_cust_trx_line_gl_dist_id  IN  ra_cust_trx_line_gl_dist_all.cust_trx_line_gl_dist_id%TYPE,
                                    p_cust_trx_line_salesrep_id IN  ra_cust_trx_line_gl_dist_all.cust_trx_line_salesrep_id%TYPE,
                                    p_customer_trx_id           IN  ra_cust_trx_line_gl_dist_all.customer_trx_id%TYPE,
                                    p_customer_trx_line_id      IN  ra_cust_trx_line_gl_dist_all.customer_trx_line_id%TYPE,
                                    p_gl_date                   IN  ra_cust_trx_line_gl_dist_all.gl_date%TYPE,
                                    p_last_update_date          IN  ra_cust_trx_line_gl_dist_all.last_update_date%TYPE,
                                    p_last_updated_by           IN  ra_cust_trx_line_gl_dist_all.last_updated_by%TYPE,
                                    p_creation_date             IN  ra_cust_trx_line_gl_dist_all.creation_date%TYPE,
                                    p_created_by                IN  ra_cust_trx_line_gl_dist_all.created_by%TYPE,
                                    p_last_update_login         IN  ra_cust_trx_line_gl_dist_all.last_update_login%TYPE,
                                    p_org_id                    IN  ra_cust_trx_line_gl_dist_all.org_id%TYPE,
                                    p_percent                   IN  ra_cust_trx_line_gl_dist_all.percent%TYPE,
                                    p_posting_control_id        IN  ra_cust_trx_line_gl_dist_all.posting_control_id%TYPE,
                                    p_set_of_books_id           IN  ra_cust_trx_line_gl_dist_all.set_of_books_id%TYPE,
                                    p_seq_id                    OUT NOCOPY  NUMBER,
                                    p_process_status            OUT NOCOPY  VARCHAR2,
                                    p_process_message           OUT NOCOPY  VARCHAR2,
                                    p_event_id                  IN  NUMBER  DEFAULT NULL) --added for bug#7645588
  IS
CURSOR c_proc_exists(cp_object_name    user_procedures.object_name%type,
                       cp_procedure_name user_procedures.procedure_name%type) IS
  SELECT 1
  FROM  user_procedures
  WHERE object_name    = cp_object_name
  AND   procedure_name = cp_procedure_name ;

    CURSOR cur_gl_seq
    IS
    SELECT  ra_cust_trx_line_gl_dist_s.NEXTVAL
    FROM    dual;

   /* Ramananda for bug#5219225. */
   lv_object_name    user_procedures.object_name%type ;
   lv_procedure_name user_procedures.procedure_name%type ;
   ln_exists         NUMBER := 0 ;
   lv_sqlstmt        VARCHAR2(2000);

   ln_cust_trx_line_gl_dist_id ra_cust_trx_line_gl_dist_all.cust_trx_line_gl_dist_id%TYPE;
  BEGIN
    p_process_status := jai_constants.successful;
    p_process_message := NULL;

    --get the value for cust_trx_line_gl_dist_id
    OPEN cur_gl_seq;
    FETCH cur_gl_seq into ln_cust_trx_line_gl_dist_id;
    CLOSE cur_gl_seq;



    INSERT INTO RA_CUST_TRX_LINE_GL_DIST_ALL(account_class,
                                             account_set_flag,
                                             acctd_amount,
                                             amount,
                                             code_combination_id,
                                             cust_trx_line_gl_dist_id,
                                             cust_trx_line_salesrep_id,
                                             customer_trx_id,
                                             customer_trx_line_id,
                                             gl_date,
                                             last_update_date,
                                             last_updated_by,
                                             creation_date,
                                             created_by,
                                             last_update_login,
                                             org_id,
                                             percent,
                                             posting_control_id,
                                             set_of_books_id,
                                             event_id) --added for bug#7645588
                                      VALUES(p_account_class,
                                             p_account_set_flag,
                                             p_acctd_amount,
                                             p_amount,
                                             p_code_combination_id,
                                             ln_cust_trx_line_gl_dist_id,
                                             p_cust_trx_line_salesrep_id,
                                             p_customer_trx_id,
                                             p_customer_trx_line_id,
                                             p_gl_date,
                                             p_last_update_date,
                                             p_last_updated_by,
                                             p_creation_date,
                                             p_created_by,
                                             p_last_update_login,
                                             p_org_id,
                                             p_percent,
                                             p_posting_control_id,
                                             p_set_of_books_id,
                                             p_event_id); --added for bug#7645588

   /* Ramananda for bug#5219225. START */
    lv_object_name    := 'AR_MRC_ENGINE' ;
    lv_procedure_name := 'MAINTAIN_MRC_DATA' ;

    p_seq_id  := ln_cust_trx_line_gl_dist_id ;
    OPEN c_proc_exists(lv_object_name, lv_procedure_name) ;
    FETCH c_proc_exists INTO ln_exists ;
    CLOSE c_proc_exists ;
    IF ln_exists = 1 THEN

      lv_sqlstmt := 'BEGIN ar_mrc_engine.maintain_mrc_data(
                                                           p_event_mode        => ''INSERT'',
                                                           p_table_name        => ''RA_CUST_TRX_LINE_GL_DIST'',
                                                           p_mode              => ''SINGLE'',
                                                           p_key_value         => :1
                                                           );
                     END; ';
      EXECUTE IMMEDIATE lv_sqlstmt USING ln_cust_trx_line_gl_dist_id ;
    END IF ;
   /* Ramananda for bug#5219225. END */

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status  := jai_constants.unexpected_error;
      p_process_message := SUBSTR(SQLERRM,1,300);
  END insert_trx_line_gl_dist;
PROCEDURE insert_trx_lines(p_extended_amount            IN  ra_customer_trx_lines_all.extended_amount%TYPE,
                             p_taxable_amount             IN  ra_customer_trx_lines_all.taxable_amount%TYPE,
                             p_customer_trx_line_id       IN  ra_customer_trx_lines_all.customer_trx_line_id%TYPE,
                             p_last_update_date           IN  ra_customer_trx_lines_all.last_update_date%TYPE,
                             p_last_updated_by            IN  ra_customer_trx_lines_all.last_updated_by%TYPE,
                             p_creation_date              IN  ra_customer_trx_lines_all.creation_date%TYPE,
                             p_created_by                 IN  ra_customer_trx_lines_all.created_by%TYPE,
                             p_last_update_login          IN  ra_customer_trx_lines_all.last_update_login%TYPE,
                             p_customer_trx_id            IN  ra_customer_trx_lines_all.customer_trx_id%TYPE,
                             p_line_number                IN  ra_customer_trx_lines_all.line_number%TYPE,
                             p_set_of_books_id            IN  ra_customer_trx_lines_all.set_of_books_id%TYPE,
                             p_link_to_cust_trx_line_id   IN  ra_customer_trx_lines_all.link_to_cust_trx_line_id%TYPE,
                             p_line_type                  IN  ra_customer_trx_lines_all.line_type%TYPE,
                             p_org_id                     IN  ra_customer_trx_lines_all.org_id%TYPE,
                             p_uom_code                   IN  ra_customer_trx_lines_all.uom_code%TYPE,
                             p_autotax                    IN  ra_customer_trx_lines_all.autotax%TYPE,
                             p_vat_tax_id                 IN  ra_customer_trx_lines_all.vat_tax_id%TYPE,
                             p_interface_line_context     IN  ra_customer_trx_lines_all.interface_line_context%TYPE,
                             p_interface_line_attribute6  IN  ra_customer_trx_lines_all.interface_line_attribute6%TYPE,
                             p_interface_line_attribute3  IN  ra_customer_trx_lines_all.interface_line_attribute3%TYPE,
                             p_process_status             OUT NOCOPY VARCHAR2,
                             p_process_message            OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    p_process_status := jai_constants.successful;
    p_process_message := NULL;

    INSERT INTO RA_CUSTOMER_TRX_LINES_ALL ( extended_amount,
                                            taxable_amount,
                                            customer_trx_line_id,
                                            last_update_date,
                                            last_updated_by,
                                            creation_date,
                                            created_by,
                                            last_update_login,
                                            customer_trx_id,
                                            line_number,
                                            set_of_books_id,
                                            link_to_cust_trx_line_id,
                                            line_type,
                                            org_id,
                                            uom_code,
                                            autotax,
                                            vat_tax_id,
                                            interface_line_context,
                                            interface_line_attribute6,
                                            interface_line_attribute3)
                                   VALUES ( p_extended_amount,
                                            p_taxable_amount,
                                            p_customer_trx_line_id,
                                            p_last_update_date,
                                            p_last_updated_by,
                                            p_creation_date,
                                            p_created_by,
                                            p_last_update_login,
                                            p_customer_trx_id,
                                            p_line_number,
                                            p_set_of_books_id,
                                            p_link_to_cust_trx_line_id,
                                            p_line_type,
                                            p_org_id,
                                            p_uom_code,
                                            p_autotax,
                                            p_vat_tax_id,
                                            p_interface_line_context,
                                            p_interface_line_attribute6,
                                            p_interface_line_attribute3);
  EXCEPTION
    WHEN OTHERS THEN
      p_process_status  := jai_constants.unexpected_error;
      p_process_message := SUBSTR(SQLERRM,1,300);
  END insert_trx_lines;

  /*added the following procedure for bug#8325824*/
  PROCEDURE insert_ar_dist_entries (p_customer_trx_id IN NUMBER,
                                    p_receivable_appl_id  IN NUMBER,
                                    p_debug IN VARCHAR2 DEFAULT 'N',
                                    p_process_status OUT NOCOPY VARCHAR2,
                                    p_process_message OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    IF p_debug = 'Y' THEN
      fnd_file.put_line(FND_FILE.LOG, 'Before deleting ar_distributions : p_receivable_appl_id '|| p_receivable_appl_id);
    END IF;

    DELETE ar_distributions
    where  source_id = p_receivable_appl_id
    and    source_table = 'RA' ;

    IF p_debug = 'Y' THEN
      fnd_file.put_line(FND_FILE.LOG, 'Before call to  create_Acct_entry: p_customer_trx_id '|| p_customer_trx_id||
                                      ' p_receivable_appl_id '|| p_receivable_appl_id);
    END IF;

    arp_acct_main.create_Acct_entry('CREDIT_MEMO',
                                    p_customer_trx_id,
                                    'ONE',
                                    'RA',
                                    p_receivable_appl_id,
                                    null,
                                    null,
                                    'Y',
                                    'C',
                                    'N',
                                    null);
  EXCEPTION
    WHEN OTHERS THEN
      p_process_status  := jai_constants.unexpected_error;
      p_process_message := SUBSTR(SQLERRM,1,300);
  END insert_ar_dist_entries;



PROCEDURE delete_trx_data(p_customer_trx_id           IN          ra_customer_trx_all.customer_trx_id%TYPE,
                            p_link_to_cust_trx_line_id  IN          ra_customer_trx_lines_all.link_to_cust_trx_line_id%TYPE DEFAULT NULL,
                            p_process_status            OUT NOCOPY  VARCHAR2,
                            p_process_message           OUT NOCOPY  VARCHAR2)
  IS
  /* Ramananda for bug#5219225. */
  lv_object_name    user_procedures.object_name%type ;
  lv_procedure_name user_procedures.procedure_name%type ;
  ln_exists         NUMBER := 0 ;
  lv_sqlstmt        VARCHAR2(2000) ;
  lv_account_class_tax             VARCHAR2(10) := 'TAX';
  lv_account_class_freight         VARCHAR2(10) := 'FREIGHT';

 --get the sum of amount, acctd_amount and max of acctd_amount from ra_cust_trx_line_gl_dist_all for cp_customer_trx_id
  --and account_class in ('TAX','FREIGHT')
  CURSOR cur_total_amt_gl_dist( cp_customer_trx_id      ra_customer_trx_all.customer_trx_id%TYPE)
  IS
  SELECT  NVL(SUM(amount),0)        amount,
          NVL(SUM(acctd_amount),0)  acctd_amount,
          MAX(acctd_amount)         max_acctd_amount
  FROM    ra_cust_trx_line_gl_dist_all
  WHERE   customer_trx_id   =  cp_customer_trx_id
  AND     account_class     IN (lv_account_class_tax,lv_account_class_freight);

  --get the data from JAI_AR_TRX_INS_LINES_T for customer_trx_id and link_to_cust_trx_line_id
  CURSOR cur_temp_lines_insert( cp_customer_trx_id            ra_customer_trx_all.customer_trx_id%TYPE,
                                cp_link_to_cust_trx_line_id   JAI_AR_TRX_INS_LINES_T.link_to_cust_trx_line_id%TYPE DEFAULT NULL)
  IS
  SELECT  *
  FROM    JAI_AR_TRX_INS_LINES_T
  WHERE   customer_trx_id           = cp_customer_trx_id
  AND     link_to_cust_trx_line_id  = NVL(cp_link_to_cust_trx_line_id, link_to_cust_trx_line_id)
  ORDER BY link_to_cust_trx_line_id,
           customer_trx_line_id;


   /* Ramananda for bug#5219225. */
  CURSOR c_proc_exists(cp_object_name    user_procedures.object_name%type,
                       cp_procedure_name user_procedures.procedure_name%type) IS
  SELECT 1
  FROM  user_procedures
  WHERE object_name    = cp_object_name
  AND   procedure_name = cp_procedure_name ;

  BEGIN
    p_process_status := jai_constants.successful;
    p_process_message := NULL;

    /* Ramananda for bug#5219225. START */
    lv_object_name    := 'AR_MRC_ENGINE' ;
    lv_procedure_name := 'MAINTAIN_MRC_DATA' ;

    OPEN c_proc_exists(lv_object_name, lv_procedure_name) ;
    FETCH c_proc_exists INTO ln_exists ;
    CLOSE c_proc_exists ;
    IF ln_exists = 1 THEN
      --delete the mrc data from ra_cust_trx_line_gl_dist_all
      FOR rec_mrc IN
                ( SELECT  cust_trx_line_gl_dist_id
                  FROM    ra_cust_trx_line_gl_dist_all
                  WHERE   customer_trx_id = p_customer_trx_id
                  AND     account_class IN ('TAX','FREIGHT')
                  AND     customer_trx_line_id IN
                               (SELECT  customer_trx_line_id
                                FROM    ra_customer_trx_lines_all
                                WHERE   customer_trx_id = p_customer_trx_id
                                AND     link_to_cust_trx_line_id = NVL(p_link_to_cust_trx_line_id, link_to_cust_trx_line_id)
                                AND     line_type in ('TAX','FREIGHT')
                               )
                )
      LOOP

        lv_sqlstmt := 'BEGIN ar_mrc_engine.maintain_mrc_data(
                                                      p_event_mode        =>''DELETE'',
                                                      p_table_name        =>''RA_CUST_TRX_LINE_GL_DIST'',
                                                      p_mode              =>''SINGLE'',
                                                      p_key_value         => :1
                                                     );

                        END; ' ;
        EXECUTE IMMEDIATE lv_sqlstmt USING rec_mrc.cust_trx_line_gl_dist_id ;
      END LOOP;
    END IF ;
   /* Ramananda for bug#5219225. END */

    --delete the data from ra_cust_trx_line_gl_dist_all
    DELETE  ra_cust_trx_line_gl_dist_all
    WHERE   customer_trx_id = p_customer_trx_id
    AND     account_class IN ('TAX','FREIGHT')
    AND     customer_trx_line_id IN
                 (SELECT  customer_trx_line_id
                  FROM    ra_customer_trx_lines_all
                  WHERE   customer_trx_id = p_customer_trx_id
                  AND     link_to_cust_trx_line_id  = NVL(p_link_to_cust_trx_line_id, link_to_cust_trx_line_id)
                  AND     line_type in ('TAX','FREIGHT')
                 );

    --delete the data from ra_customer_trx_lines_all
    DELETE  ra_customer_trx_lines_all
    WHERE   customer_trx_id = p_customer_trx_id
    AND     link_to_cust_trx_line_id  = NVL(p_link_to_cust_trx_line_id, link_to_cust_trx_line_id)
    AND     line_type IN ('TAX','FREIGHT');

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status  := jai_constants.unexpected_error;
      p_process_message := SUBSTR(SQLERRM,1,300);
  END delete_trx_data;


  PROCEDURE process_from_order_line( p_customer_trx_id   IN          NUMBER,
                                      p_debug             IN          VARCHAR2 DEFAULT 'N',
                                      p_process_status    OUT NOCOPY  VARCHAR2,
                                      p_process_message   OUT NOCOPY  VARCHAR2)
  IS


  v_org_id                         number;
  lv_object_name                   user_procedures.object_name%type ;
  lv_procedure_name                user_procedures.procedure_name%type ;
  ln_exists                        NUMBER := 0 ;
  lv_sqlstmt                       VARCHAR2(2000) ;
  lv_account_class_tax             VARCHAR2(10) := 'TAX';
  lv_account_class_freight         VARCHAR2(10) := 'FREIGHT';
  lv_loc_tax_code                  VARCHAR2(20) := 'Localization';
  lv_line_type_line                VARCHAR2(10) := 'LINE';
  ld_gl_posted_date                RA_CUST_TRX_LINE_GL_DIST_ALL.gl_posted_date%type ;
  lv_account_class_rec             VARCHAR2(10) := 'REC';
  l_xla_event                      arp_xla_events.xla_events_type;
  ln_gl_seq                        Number;
  imported_trx                     VARCHAR2(10) := 'IMPORTED';

  lv_tax_regime_code               zx_rates_b.tax_regime_code%type ;
  ln_party_tax_profile_id          zx_party_tax_profile.party_tax_profile_id%type ;
  ln_tax_rate_id                   zx_rates_b.tax_rate_id%type ;

  localization_tax_not_defined     EXCEPTION;
  Item_lines_already_accounted     EXCEPTION;  /* Ramanand for SLA Uptake */
  rounding_account_not_defined     EXCEPTION;
  resource_busy                    EXCEPTION;

  --get the allow_overapplication_flag from ra_cust_trx_types_all for cust_trx_type_id
  CURSOR cur_trx_types( cp_cust_trx_type_id     ra_cust_trx_types_all.cust_trx_type_id%TYPE)
  IS
  SELECT  allow_overapplication_flag
  FROM    ra_cust_trx_types_all
  WHERE   cust_trx_type_id = cp_cust_trx_type_id;

  --get the data from ar_payment_schedules_all for customer_trx_id and payment_schedule_id
  CURSOR cur_payment_schedule(cp_customer_trx_id      ra_customer_trx_all.customer_trx_id%TYPE,
                              cp_payment_Schedule_id  ar_payment_schedules_all.payment_schedule_id%TYPE DEFAULT NULL)
  IS
  SELECT  payment_schedule_id,
          term_id,
          terms_sequence_number,
          amount_line_items_original,
          amount_line_items_remaining,
          tax_original,
          tax_remaining,
          freight_original,
          amount_due_remaining
  FROM    ar_payment_schedules_all
  WHERE   customer_trx_id     = cp_customer_trx_id
  AND     payment_schedule_id = NVL(cp_payment_schedule_id, payment_schedule_id);

  --get the sum of extended_amount, taxable_amount from ra_customer_trx_lines_all for customer_trx_id, customer_trx_line_id and line_type
  CURSOR cur_total_amt_trx_lines( cp_customer_trx_id      ra_customer_trx_all.customer_trx_id%TYPE,
                                  cp_customer_trx_line_id ra_customer_trx_lines_all.customer_trx_line_id%TYPE DEFAULT NULL,
                                  cp_line_type            ra_customer_trx_lines_all.line_type%TYPE)
  IS
  SELECT  NVL(SUM(extended_amount),0) extended_amount,
          NVL(SUM(taxable_amount),0) taxable_amount
  FROM    ra_customer_trx_lines_all
  WHERE   customer_trx_id       = cp_customer_trx_id
  AND     customer_trx_line_id  = NVL(cp_customer_trx_line_id, customer_trx_line_id)
  AND     line_type             = cp_line_type;



  CURSOR c_gl_posted_date_cur(p_customer_trx_line_id RA_CUST_TRX_LINE_GL_DIST_ALL.customer_trx_line_id%type) IS
  SELECT gl_posted_date
  from RA_CUST_TRX_LINE_GL_DIST_ALL
  where customer_trx_line_id = p_customer_trx_line_id
  and account_class = 'REC'
  and latest_rec_flag = 'Y';

  --get the accounting_rule_id from ra_customer_trx_lines_all for customer_trx_line_id
  CURSOR accounting_set_cur(cp_customer_trx_line_id   ra_customer_trx_lines_all.customer_trx_line_id%TYPE)
  IS
  SELECT  accounting_rule_id
  FROM    ra_customer_trx_lines_all
  WHERE   customer_trx_line_id = cp_customer_trx_line_id;

  /* Ramananda for bug#5219225. */
  CURSOR c_proc_exists(cp_object_name    user_procedures.object_name%type,
                       cp_procedure_name user_procedures.procedure_name%type) IS
  SELECT 1
  FROM  user_procedures
  WHERE object_name    = cp_object_name
  AND   procedure_name = cp_procedure_name ;

 --get the sum of amount, acctd_amount and max of acctd_amount from ra_cust_trx_line_gl_dist_all for cp_customer_trx_id
  --and account_class in ('TAX','FREIGHT')

  CURSOR cur_total_amt_gl_dist( cp_customer_trx_id      ra_customer_trx_all.customer_trx_id%TYPE)
  IS
  SELECT  NVL(SUM(amount),0)        amount,
          NVL(SUM(acctd_amount),0)  acctd_amount,
          MAX(acctd_amount)         max_acctd_amount
  FROM    ra_cust_trx_line_gl_dist_all
  WHERE   customer_trx_id   =  cp_customer_trx_id
  AND     account_class     IN (lv_account_class_tax,lv_account_class_freight);

  --get the data from JAI_AR_TRX_INS_LINES_T for customer_trx_id and link_to_cust_trx_line_id
  CURSOR cur_temp_lines_insert( cp_customer_trx_id            ra_customer_trx_all.customer_trx_id%TYPE,
                                cp_link_to_cust_trx_line_id   JAI_AR_TRX_INS_LINES_T.link_to_cust_trx_line_id%TYPE DEFAULT NULL)
  IS
  SELECT  *
  FROM    JAI_AR_TRX_INS_LINES_T
  WHERE   customer_trx_id           = cp_customer_trx_id
  AND     link_to_cust_trx_line_id  = NVL(cp_link_to_cust_trx_line_id, link_to_cust_trx_line_id)
  ORDER BY link_to_cust_trx_line_id,
           customer_trx_line_id;

   --get the data from ra_cust_trx_line_gl_dist_all for customer_trx_id and account_class = 'REC'
  CURSOR cur_gl_date(cp_customer_trx_id ra_customer_trx_all.customer_trx_id%TYPE)
  IS
  SELECT  gl_date
  FROM    ra_cust_trx_line_gl_dist_all
  WHERE   customer_trx_id   = cp_customer_trx_id
  AND     account_class     = 'REC'
  AND     latest_rec_flag   = 'Y';

 --get the currency precision from fnd_currencies for the set_of_books_id
  CURSOR cur_curr_precision(cp_set_of_books_id gl_sets_of_books.set_of_books_id%TYPE)
  IS
  SELECT  NVL(minimum_accountable_unit,NVL(precision,2))
  FROM    fnd_currencies
  WHERE   currency_code IN
              (
              SELECT  Currency_code
              FROM    gl_sets_of_books
              WHERE   set_of_books_id = cp_set_of_books_id
              );

   --get the data from ra_customer_trx_lines_all for customer_trx_id, customer_trx_line_id and line_type = 'LINE'
  CURSOR cur_customer_trx_lines(cp_customer_trx_id      ra_customer_trx_all.customer_trx_id%TYPE,
                                cp_customer_trx_line_id ra_customer_trx_lines_all.customer_trx_line_id%TYPE)
  IS
  SELECT  interface_line_attribute6,
          interface_line_attribute3,
          interface_line_context,
          NVL(extended_amount,0) extended_amount,
          NVL(taxable_amount,0) taxable_amount
  FROM    ra_customer_trx_lines_all
  WHERE   customer_trx_id       = cp_customer_trx_id
  AND     customer_trx_line_id  = cp_customer_trx_line_id
  AND     line_type             = lv_line_type_line; --'LINE'


 --get the min(payment_schedule_id) and term_id from ar_payment_schedules_all for customer_trx_id
  CURSOR cur_min_payment_schedule(cp_customer_trx_id  ra_customer_trx_all.customer_trx_id%TYPE)
  IS
  SELECT  MIN(payment_schedule_id) payment_schedule_id,
          MIN(term_id) term_id
  FROM    ar_payment_schedules_all
  WHERE   customer_trx_id = cp_customer_trx_id;


      --get the data from ra_customer_trx_all for a customer_trx_id
  CURSOR cur_customer_trx(cp_customer_trx_id ra_customer_trx_all.customer_trx_id%TYPE)
  IS
  SELECT  org_id,
          NVL(exchange_rate,1) exchange_rate,
          trx_number,
          cust_trx_type_id,
          created_from,
          set_of_books_id,
          previous_customer_trx_id
  FROM    ra_customer_trx_all
  WHERE   customer_trx_id = cp_customer_trx_id;


    --Lock all the rows from JAI_AR_TRX_INS_LINES_T for a customer_trx_id, which are to be processed
    CURSOR cur_lock_temp(cp_customer_trx_id JAI_AR_TRX_INS_LINES_T.customer_trx_id%TYPE)
    IS
    SELECT  *
    FROM    JAI_AR_TRX_INS_LINES_T
    WHERE   customer_trx_id = cp_customer_trx_id
    FOR UPDATE NOWAIT;


    --Get the first_installment_code and base_amount from ra_terms
    CURSOR cur_term_details(cp_term_id ra_terms.term_id%TYPE)
    IS
    SELECT  first_installment_code,
            DECODE(base_amount, 0, 1, base_amount) base_amount
    FROM    ra_terms
    WHERE   term_id = cp_term_id;


    --Get the relative_amount from ra_terms_lines
    CURSOR cur_term_lines(cp_term_id        ra_terms_lines.term_id%TYPE,
                          cp_sequence_num   ra_terms_lines.sequence_num%TYPE)
    IS
    SELECT  relative_amount
    FROM    ra_terms_lines
    WHERE   term_id       = cp_term_id
    AND     sequence_num  = cp_sequence_num;


    --Get the SUM(amount) from ra_cust_trx_line_gl_dist_all for the Credit Memo
    CURSOR cur_tot_amt_for_cms(cp_applied_customer_trx_id   ar_receivable_applications_all.applied_customer_trx_id%TYPE,
                               cp_account_class             ra_cust_trx_line_gl_dist_all.account_class%TYPE)
    IS
    SELECT  NVL(SUM(amount),0) amount
    FROM    ra_cust_trx_line_gl_dist_all
    WHERE   customer_trx_id IN
                  (
                  SELECT customer_trx_id
                  FROM   ar_receivable_applications_all
                  WHERE  applied_customer_trx_id  = cp_applied_customer_trx_id
                  AND    application_type         = 'CM'
                  AND    display                  = 'Y'
                  AND    status                   = 'APP'
                  )
    AND     account_class = cp_account_class;


    --Get the SUM of tax_applied and freight_applied from ar_receivable_applications_all for Cash receipts applied
    CURSOR cur_tot_cash_rcpt(cp_applied_customer_trx_id   ar_receivable_applications_all.applied_customer_trx_id%TYPE)
    IS
    SELECT  NVL(sum(tax_applied),0) tax_applied,
            NVL(sum(freight_applied),0) freight_applied
    FROM    ar_receivable_applications_all
    WHERE   applied_customer_trx_id = cp_applied_customer_trx_id
    AND     application_type        = 'CASH'
    AND     display                 = 'Y'
    AND     status                  = 'APP';


    --Get the SUM of line_applied from ar_receivable_applications_all for CM
    CURSOR cur_tot_recv_appl( cp_applied_customer_Trx_id      ar_receivable_applications_all.applied_customer_Trx_id%TYPE,
                              cp_applied_payment_Schedule_id  ar_receivable_applications_all.applied_payment_Schedule_id%TYPE)
    IS
    SELECT NVL(sum(line_applied),0) line_applied
    FROM   ar_receivable_applications_all
    WHERE  applied_customer_Trx_id      = cp_applied_customer_Trx_id
    AND    application_type             = 'CM'
    AND    display                      = 'Y'
    and    status                       = 'APP'
    AND    applied_payment_Schedule_id  = cp_applied_payment_Schedule_id;


    --Get the receivable_application_id from ar_receivable_applications_all for the Invoice's payment_schedule_id
    CURSOR cur_recv_appl_id(cp_applied_customer_Trx_id      ar_receivable_applications_all.applied_customer_Trx_id%TYPE,
                            cp_customer_trx_id              ar_receivable_applications_all.customer_trx_id%TYPE,
                            cp_applied_payment_Schedule_id  ar_receivable_applications_all.applied_payment_Schedule_id%TYPE)
    IS
    SELECT receivable_application_id
    FROM   ar_receivable_applications_all
    WHERE  applied_customer_Trx_id = cp_applied_customer_Trx_id
    AND    customer_trx_id  = cp_customer_trx_id
    AND    application_type = 'CM'
    AND    display          = 'Y'
    and    status           = 'APP'
    AND    applied_payment_Schedule_id = cp_applied_payment_Schedule_id;

    --Get the data from ar_payment_schedules_all for customer_trx_id
    CURSOR cur_prev_payment_schedule( cp_customer_trx_id      ra_customer_trx_all.customer_trx_id%TYPE,
                                      cp_payment_Schedule_id  ar_payment_schedules_all.payment_schedule_id%TYPE DEFAULT NULL)
    IS
    SELECT  amount_line_items_original,
            amount_line_items_remaining,
            tax_original,
            tax_remaining,
            freight_original,
            amount_due_remaining
    FROM    ar_payment_schedules_all
    WHERE   customer_trx_id     = cp_customer_trx_id
    AND     payment_schedule_id = NVL(cp_payment_schedule_id, payment_schedule_id);

   CURSOR ORG_CUR IS
   SELECT ORG_ID, CREATED_FROM
   FROM   RA_CUSTOMER_TRX_ALL
   WHERE  CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID;

   --added the cursor for bug#7645588
    CURSOR cur_event_id (cp_customer_trx_id ra_customer_trx_all.customer_trx_id%TYPE)
    IS
    SELECT  event_id
    FROM    ra_cust_trx_line_gl_dist_all
    WHERE   customer_trx_id   = cp_customer_trx_id
    AND     account_class     = 'REC'
    AND     latest_rec_flag   = 'Y'
    AND     account_set_flag  = 'N' ;

     --Start Addition by anujsax for Bug#5636544
    CURSOR cur_excise_invoice_number(cp_customer_trx_id NUMBER)
    IS
    SELECT  excise_invoice_no
    FROM  JAI_AR_TRX_LINES
    WHERE   customer_trx_id = cp_customer_trx_id
    AND   excise_invoice_no is NOT NULL;

    r_excise_invoice_number     cur_excise_invoice_number%ROWTYPE;
    lv_errbuf                   VARCHAR2(4000);
    lv_retcode                  VARCHAR2(10);
    --End of addition by Anujsax for Bug#5636544

    --added for bug#9230409, start
    TYPE RECEIPT_ID_TAB IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE receipt_date_tab IS TABLE OF DATE INDEX BY BINARY_INTEGER;
    lt_apply_date                 receipt_date_tab;
    lt_gl_date                    receipt_date_tab;
    lt_receipt_id_tab             RECEIPT_ID_TAB;
    ln_row_count                  NUMBER;
    ln_msg_count                  NUMBER;
    lv_msg_data                   VARCHAR2(2000);
    lv_return_status              VARCHAR2(1);

    CURSOR  cur_get_apply_date (ln_cash_receipt_id IN NUMBER,
                                ln_customer_trx_id IN NUMBER)
    IS
      SELECT max(apply_date)
      FROM   ar_receivable_applications_all
      WHERE  cash_receipt_id = ln_cash_receipt_id
      AND    applied_customer_trx_id = ln_customer_trx_id;

    CURSOR  cur_get_gl_date (ln_cash_receipt_id IN NUMBER,
                             ln_customer_trx_id IN NUMBER,
                             ld_apply_date      IN DATE)
    IS
      SELECT gl_date
      FROM   ar_receivable_applications_all
      WHERE  cash_receipt_id = ln_cash_receipt_id
      AND    applied_customer_trx_id = ln_customer_trx_id
      AND    receivable_application_id = (Select max(receivable_application_id)
                                          from ar_receivable_applications_all
                                          where cash_receipt_id = ln_cash_receipt_id
                                          and   applied_customer_trx_id = ln_customer_trx_id
                                          and   apply_date = ld_apply_date);
    --bug#9230409, end



    rec_customer_trx            cur_customer_trx%ROWTYPE;
    rec_inv_customer_trx        cur_customer_trx%ROWTYPE;
    rec_min_payment_schedule    cur_min_payment_schedule%ROWTYPE;
    rec_inv_payment_schedule    cur_min_payment_schedule%ROWTYPE;
    rec_customer_trx_lines      cur_customer_trx_lines%ROWTYPE;
    rec_term_details            cur_term_details%ROWTYPE;
    rec_prev_payment_schedule   cur_prev_payment_schedule%ROWTYPE;

    ln_previous_customer_trx_id ra_customer_trx_lines_all.previous_customer_trx_id%TYPE;
    ln_inv_curr_conv_rate       ra_customer_trx_all.exchange_rate%TYPE;
    ln_cm_curr_conv_rate        ra_customer_trx_all.exchange_rate%TYPE;
    ld_gl_date                  ra_cust_trx_line_gl_dist_all.gl_date%TYPE;
    ln_vat_tax_id               ar_vat_tax_all.vat_tax_id%TYPE;
    lv_amount_includes_tax_flag ar_vat_tax_all.amount_includes_tax_flag%TYPE;
    lv_account_Set_flag         ra_cust_trx_line_gl_dist_all.account_set_flag%TYPE;
    ln_precision                fnd_currencies.precision%TYPE;
    ln_accounting_rule_id       NUMBER;
    ln_old_amount               NUMBER;
    ln_taxable_amount           NUMBER;
    ln_tax_amt                  NUMBER;
    ln_tax_acctd_amount         NUMBER;
    ln_max_tax_acctd_amount     NUMBER;
    ln_old_acctd_amount         NUMBER;
    ln_adjusted_tax             NUMBER;
    ln_diff_tax_frt             NUMBER;
    ln_total_tax_amt_for_inv    NUMBER;
    ln_total_frt_amt_for_inv    NUMBER;
    ln_inst_tax_amt_for_inv     NUMBER;
    ln_inst_frt_amt_for_inv     NUMBER;
    ln_relative_amt             NUMBER;
    ln_recv_appln_id            NUMBER;
    ln_tax_amt_cms              NUMBER;
    ln_frt_amt_cms              NUMBER;
    ln_apportion_factor         NUMBER;
    lv_allow_overappln_flag     VARCHAR2(10);
    ln_amt_due_rem              NUMBER;
    ln_line_applied             NUMBER;
    ln_frt_amt_cashrcpt         NUMBER;
    ln_tax_amt_cashrcpt         NUMBER;
    ln_payment_audit_id         jai_ar_payment_audits.payment_audit_id%TYPE;
    ln_rec_appl_audit_id        jai_ar_rec_appl_audits.rec_appl_audit_id%TYPE;
    lv_process_status           VARCHAR2(2);
    lv_process_message          VARCHAR2(1000);
    v_upd_created_from          VARCHAR2(15);
    ln_event_id                 NUMBER; --added for bug#7645588
  BEGIN

    fnd_file.put_line(FND_FILE.LOG, 'START process_imported_invoice');

    --Lock all the rows from JAI_AR_TRX_INS_LINES_T for a customer_trx_id, which are to be processed
    FOR i IN cur_lock_temp(p_customer_trx_id)
    LOOP
      EXIT;
    END LOOP;

    --get the data from ra_customer_trx_all for a customer_trx_id
    OPEN cur_customer_trx(p_customer_trx_id);
    FETCH cur_customer_trx INTO rec_customer_trx;
    CLOSE cur_customer_trx;

    OPEN  ORG_CUR;
    FETCH ORG_CUR INTO v_org_id, v_upd_created_from;
    CLOSE ORG_CUR;

    --If ln_previous_customer_trx_id is not null, then current transaction is a CM
    ln_previous_customer_trx_id := rec_customer_trx.previous_customer_trx_id;

    IF p_debug = 'Y' THEN
      fnd_file.put_line(FND_FILE.LOG, 'Before pre_validation');
    END IF;

    --do the basic validations before processing the transaction
    jai_ar_validate_data_pkg.pre_validation
                  ( p_customer_trx_id => p_customer_trx_id,
                    p_process_status  => lv_process_status,
                    p_process_message => lv_process_message);

    IF p_debug = 'Y' THEN
      fnd_file.put_line(FND_FILE.LOG, 'Before pre_validation');
    END IF;

    IF lv_process_status <> jai_constants.successful THEN
      p_process_status  := lv_process_status;
      p_process_message := lv_process_message;
      goto EXIT_POINT;
    END IF;

    --If it is CM
    IF ln_previous_customer_trx_id IS NOT NULL THEN
      --get the data from ra_customer_trx_all for the Invoice
      OPEN cur_customer_trx(ln_previous_customer_trx_id);
      FETCH cur_customer_trx INTO rec_inv_customer_trx;
      CLOSE cur_customer_trx;

      ln_inv_curr_conv_rate := rec_inv_customer_trx.exchange_rate;
      ln_cm_curr_conv_rate := rec_customer_trx.exchange_rate;
    ELSE
      ln_inv_curr_conv_rate := rec_customer_trx.exchange_rate;
    END IF;

    --get the min(payment_schedule_id) and term_id from ar_payment_schedules_all for customer_trx_id
    OPEN cur_min_payment_schedule(p_customer_trx_id);
    FETCH cur_min_payment_schedule INTO rec_min_payment_schedule;
    CLOSE cur_min_payment_schedule;


    --get the currency precision from fnd_currencies for the set_of_books_id
    OPEN cur_curr_precision(rec_customer_trx.set_of_books_id);
    FETCH cur_curr_precision INTO ln_precision;
    CLOSE cur_curr_precision;

    IF p_debug = 'Y' THEN
      fnd_file.put_line(FND_FILE.LOG, 'Before delete_trx_data');
    END IF;

    --This procedure deletes the data from ra_cust_trx_line_gl_dist_all, ra_customer_trx_lines_all
    --Also deletes the MRC data from ra_cust_trx_line_gl_dist
    delete_trx_data(p_customer_trx_id => p_customer_trx_id,
                    p_process_status  => lv_process_status,
                    p_process_message => lv_process_message);

    IF p_debug = 'Y' THEN
      fnd_file.put_line(FND_FILE.LOG, 'After delete_trx_data');
    END IF;

    IF lv_process_status <> jai_constants.successful THEN
      p_process_status := lv_process_status;
      p_process_message := lv_process_message;
      goto EXIT_POINT;
    END IF;

    --get the data from ra_cust_trx_line_gl_dist_all for customer_trx_id and account_class = 'REC'
    OPEN cur_gl_date(p_customer_trx_id);
    FETCH cur_gl_date INTO ld_gl_date;
    CLOSE cur_gl_date;



    /* Added by Ramananda for bug#4468353 due to ebtax uptake by AR, start */
       OPEN  jai_ar_trx_pkg.c_tax_regime_code_cur(V_ORG_ID);
       FETCH jai_ar_trx_pkg.c_tax_regime_code_cur INTO lv_tax_regime_code;
       CLOSE jai_ar_trx_pkg.c_tax_regime_code_cur ;

       OPEN  jai_ar_trx_pkg.c_party_tax_profile_id_cur(V_ORG_ID);
       FETCH jai_ar_trx_pkg.c_party_tax_profile_id_cur INTO ln_party_tax_profile_id;
       CLOSE jai_ar_trx_pkg.c_party_tax_profile_id_cur ;

       OPEN  jai_ar_trx_pkg.c_tax_rate_id_cur(lv_tax_regime_code, ln_party_tax_profile_id);
       FETCH jai_ar_trx_pkg.c_tax_rate_id_cur INTO ln_tax_rate_id;
       CLOSE jai_ar_trx_pkg.c_tax_rate_id_cur ;

       if ln_tax_rate_id is null then
          raise Localization_tax_not_defined;
       end if;
    /* Added by Ramananda for bug#4468353 due to ebtax uptake by AR, end */


    IF p_debug = 'Y' THEN
      fnd_file.put_line(FND_FILE.LOG, 'Before cur_temp_lines_insert LOOP');
    END IF;

    FOR rec_temp IN cur_temp_lines_insert(p_customer_trx_id)
    LOOP

      --get the accounting_rule_id from ra_customer_trx_lines_all for customer_trx_line_id
      OPEN  accounting_set_cur(rec_temp.link_to_cust_trx_line_id);
      FETCH accounting_set_cur INTO ln_accounting_rule_id;
      CLOSE accounting_set_cur;

      IF ln_accounting_rule_id IS NOT NULL THEN
        -- Added the IF condition for bug#7645588, start
        IF ln_previous_customer_trx_id IS NOT NULL THEN --it is a CM transaction
          lv_account_Set_flag := 'N';
        ELSE
          lv_account_Set_flag := 'Y';
        END IF;
        --bug#7645588, end
      ELSE
        lv_account_Set_flag := 'N';
      END IF;

      --get the data from ra_customer_trx_lines_all for customer_trx_id, customer_trx_line_id and line_type = 'LINE'
      OPEN cur_customer_trx_lines(p_customer_trx_id,
                                  rec_temp.link_to_cust_trx_line_id);
      FETCH cur_customer_trx_lines INTO rec_customer_trx_lines;
      CLOSE cur_customer_trx_lines;

      --added the following IF block for bug#7645588
      -- moved the following piece of code for bug#8276902
      -- added the OR condition for bug#8276902
      IF (ln_accounting_rule_id is not null OR rec_customer_trx_lines.interface_line_context = gv_projects_invoices)
          and ln_previous_customer_trx_id IS NOT NULL then
        open cur_event_id (p_customer_trx_id);
        Fetch cur_event_id into ln_event_id;
        close cur_event_id;
      ELSE
        ln_event_id := null;
      END if;
      -- bug#7645588, end

      IF rec_temp.insert_update_flag IN('U','X') THEN

        IF lv_amount_includes_tax_flag = 'Y' then
           ln_taxable_amount := rec_customer_trx_lines.extended_amount - rec_temp.extended_amount;
        ELSE
           ln_taxable_amount := rec_customer_trx_lines.extended_amount;
        END IF;

        IF p_debug = 'Y' THEN
          fnd_file.put_line(FND_FILE.LOG, 'In loop cur_temp_lines_insert - before insert_trx_lines');
        END IF;


                 -- #### IMPORTANT FOR R12
                /* Modified by Ramananda for bug#4468353 due to sla uptake by AR, start */
                OPEN  c_gl_posted_date_cur( rec_temp.link_to_cust_trx_line_id);
                FETCH c_gl_posted_date_cur INTO ld_gl_posted_date ;
                CLOSE c_gl_posted_date_cur ;

                IF  ld_gl_posted_date is NULL THEN

                 -- #### IMPORTANT FOR R12 ENDS HERE

        --This procedure inserts the data into ra_customer_trx_lines_all
        insert_trx_lines(p_extended_amount            =>  rec_temp.extended_amount,
                         p_taxable_amount             =>  ln_taxable_amount,
                         p_customer_trx_line_id       =>  rec_temp.customer_trx_line_id,
                         p_last_update_date           =>  rec_temp.last_update_date,
                         p_last_updated_by            =>  rec_temp.last_updated_by,
                         p_creation_date              =>  rec_temp.creation_date,
                         p_created_by                 =>  rec_temp.created_by,
                         p_last_update_login          =>  rec_temp.last_update_login,
                         p_customer_trx_id            =>  rec_temp.customer_trx_id,
                         p_line_number                =>  rec_temp.line_number,
                         p_set_of_books_id            =>  rec_temp.set_of_books_id,
                         p_link_to_cust_trx_line_id   =>  rec_temp.link_to_cust_trx_line_id,
                         p_line_type                  =>  rec_temp.line_type,
                         p_org_id                     =>  rec_customer_trx.org_id,
                         p_uom_code                   =>  rec_temp.uom_code,
                         p_autotax                    =>  'N',
                         p_vat_tax_id                 =>  ln_vat_tax_id,
                         p_interface_line_context     =>  rec_customer_trx_lines.interface_line_context,
                         p_interface_line_attribute6  =>  rec_customer_trx_lines.interface_line_attribute6,
                         p_interface_line_attribute3  =>  rec_customer_trx_lines.interface_line_attribute3,
                         p_process_status             =>  lv_process_status,
                         p_process_message            =>  lv_process_message);

        IF p_debug = 'Y' THEN
          fnd_file.put_line(FND_FILE.LOG, 'In loop cur_temp_lines_insert - after insert_trx_lines');
        END IF;

        IF lv_process_status <> jai_constants.successful THEN
          p_process_status := lv_process_status;
          p_process_message := lv_process_message;
          goto EXIT_POINT;
        END IF;

        IF p_debug = 'Y' THEN
          fnd_file.put_line(FND_FILE.LOG, 'In loop cur_temp_lines_insert - before insert_trx_line_gl_dist');
        END IF;


        --This procedure inserts the data into ra_cust_trx_line_gl_dist_all
        insert_trx_line_gl_dist(p_account_class             =>  rec_temp.line_type,
                                p_account_set_flag          =>  lv_account_set_flag,
                                p_acctd_amount              =>  ROUND(rec_temp.acctd_amount, ln_precision),
                                p_amount                    =>  rec_temp.amount,
                                p_code_combination_id       =>  rec_temp.code_combination_id,
                                p_cust_trx_line_gl_dist_id  =>  NULL,
                                p_cust_trx_line_salesrep_id =>  rec_temp.cust_trx_line_sales_rep_id,
                                p_customer_trx_id           =>  rec_temp.customer_trx_id,
                                p_customer_trx_line_id      =>  rec_temp.customer_trx_line_id,
                                p_gl_date                   =>  ld_gl_date,
                                p_last_update_date          =>  rec_temp.last_update_date,
                                p_last_updated_by           =>  rec_temp.last_updated_by,
                                p_creation_date             =>  rec_temp.creation_date,
                                p_created_by                =>  rec_temp.created_by,
                                p_last_update_login         =>  rec_temp.last_update_login,
                                p_org_id                    =>  rec_customer_trx.org_id,
                                p_percent                   =>  100,
                                p_posting_control_id        =>  -3,
                                p_set_of_books_id           =>  rec_temp.set_of_books_id,
                                p_process_status            =>  lv_process_status,
                                p_process_message           =>  lv_process_message ,
                                p_seq_id                    =>  ln_gl_seq,
                                p_event_id                  =>  ln_event_id); --added for bug#7645588

        IF p_debug = 'Y' THEN
          fnd_file.put_line(FND_FILE.LOG, 'In loop cur_temp_lines_insert - after insert_trx_line_gl_dist');
        END IF;

       --added the following IF condition for bug#7645588
        --added the OR condition for bug#8276902
        IF (ln_accounting_rule_id is not null OR rec_customer_trx_lines.interface_line_context = gv_projects_invoices)
            and ln_previous_customer_trx_id IS NOT NULL then
          NULL;
        ELSE
          -- ###### IMPORTANT FOR R12
          /* following added by Ramanand for Bug#4468353 as part of SLA uptake */
          l_xla_event.xla_req_id            := NULL      ;
          l_xla_event.xla_dist_id           := ln_gl_seq  ;
          l_xla_event.xla_doc_table         := 'CT'      ;
          l_xla_event.xla_doc_event         := NULL      ;
          l_xla_event.xla_mode              := 'O'       ;
          l_xla_event.xla_call              := 'D'       ;
          ARP_XLA_EVENTS.CREATE_EVENTS(p_xla_ev_rec => l_xla_event);
          -- ###### IMPORTANT FOR R12
        END IF;



        IF lv_process_status <> jai_constants.successful THEN
          p_process_status  := lv_process_status;
          p_process_message := lv_process_message;
          goto EXIT_POINT;
        END IF;


    --- #### IMPORTANT FOR R12
     ELSE  /*  ld_gl_posted_date will not be null when the execution comes here */
                  raise Item_lines_already_accounted;
                END IF ; --ld_gl_posted_date is null
              /* Modified by Ramananda for bug#4468353 due to sla uptake by AR, end */
      END IF;

    END LOOP; --End rec_temp

    --get the sum of extended_amount, taxable_amount from ra_customer_trx_lines_all for customer_trx_id, customer_trx_line_id and line_type
    OPEN cur_total_amt_trx_lines( p_customer_trx_id,
                                  NULL,
                                  lv_line_type_line);
    FETCH cur_total_amt_trx_lines INTO ln_old_amount,
                                       ln_taxable_amount; --this variable is not being used
    CLOSE cur_total_amt_trx_lines;


    --get the sum of amount, acctd_amount and max of acctd_amount from ra_cust_trx_line_gl_dist_all for cp_customer_trx_id
    --and account_class in ('TAX','FREIGHT')
    OPEN cur_total_amt_gl_dist(p_customer_trx_id);
    FETCH cur_total_amt_gl_dist INTO  ln_tax_amt,
                                      ln_tax_acctd_amount,
                                      ln_max_tax_acctd_amount;
    CLOSE cur_total_amt_gl_dist;

    IF ln_previous_customer_trx_id IS NOT NULL THEN --CM
       ln_old_acctd_amount := ln_old_amount * ln_cm_curr_conv_rate;
       ln_adjusted_tax := ROUND(ln_tax_amt * ln_cm_curr_conv_rate, ln_precision);
    else
       ln_old_acctd_amount := ln_old_amount * ln_inv_curr_conv_rate;
       ln_adjusted_tax := ROUND(ln_tax_amt * ln_inv_curr_conv_rate, ln_precision);
    end if;

    /* Modified for bug#5495711
    || acctd_amount = ROUND( (ln_old_acctd_amount + ln_tax_acctd_amount + ln_diff_tax_frt), ln_precision)
    */
    UPDATE  ra_cust_trx_line_gl_dist_all
    SET     amount = ln_old_amount + ln_tax_amt,
            acctd_amount = ROUND( (ln_old_acctd_amount + ln_tax_acctd_amount ), ln_precision)
    WHERE   customer_trx_id = p_customer_trx_id
    AND     account_class = lv_account_class_rec --'REC'
    AND     latest_rec_flag = 'Y';

   IF lv_process_status <> jai_constants.successful THEN

      p_process_status  := lv_process_status;
      p_process_message := lv_process_message;
      goto EXIT_POINT;

    END IF;
    --Added by Ramananda for bug#5495711, Ends

    --get the sum of extended_amount, taxable_amount from ra_customer_trx_lines_all for customer_trx_id, customer_trx_line_id and line_type
    OPEN cur_total_amt_trx_lines(p_customer_trx_id,
                                 NULL,
                                 lv_account_class_tax);
    FETCH cur_total_amt_trx_lines INTO ln_total_tax_amt_for_inv,
                                       ln_taxable_amount; --this variable is not being used
    CLOSE cur_total_amt_trx_lines;


    --get the sum of extended_amount, taxable_amount from ra_customer_trx_lines_all for customer_trx_id, customer_trx_line_id and line_type
    OPEN cur_total_amt_trx_lines(p_customer_trx_id,
                                 NULL,
                                 lv_account_class_freight);
    FETCH cur_total_amt_trx_lines INTO ln_total_frt_amt_for_inv,
                                       ln_taxable_amount; --this variable is not being used
    CLOSE cur_total_amt_trx_lines;

    IF p_debug = 'Y' THEN
      fnd_file.put_line(FND_FILE.LOG, 'Before ln_previous_customer_trx_id is not null'||ln_previous_customer_trx_id);
    END IF;

    IF ln_previous_customer_trx_id IS NOT NULL  THEN --CM

      ln_payment_audit_id := NULL;
      ln_rec_appl_audit_id := NULL;

      -- Added for bug#9230409, start
      /*unapplication of the receipt logic****/
        ln_row_count := 1;
      FOR rec_get_receipt_id IN ( select  distinct cash_receipt_id
                                  from    ar_receivable_applications_all
                                  where   status = 'APP'
                                  and     application_type = 'CASH'
                                  and     applied_customer_trx_id = ln_previous_customer_trx_id
                                  group by cash_receipt_id
                                  having  sum(acctd_amount_applied_from) > 0)
      LOOP
        lt_receipt_id_tab(ln_row_count) := rec_get_receipt_id.cash_receipt_id;

        OPEN cur_get_apply_date (lt_receipt_id_tab(ln_row_count),
                                 ln_previous_customer_trx_id);
        FETCH cur_get_apply_date INTO lt_apply_date(ln_row_count);
        CLOSE cur_get_apply_date;

        OPEN cur_get_gl_date (lt_receipt_id_tab(ln_row_count),
                              ln_previous_customer_trx_id,
                              lt_apply_date(ln_row_count));
        FETCH cur_get_gl_date INTO lt_gl_date(ln_row_count);
        CLOSE cur_get_gl_date;

        fnd_file.put_line(FND_FILE.LOG, 'lt_receipt_id_tab(i) '|| lt_receipt_id_tab(ln_row_count) ||
                                        ' ln_previous_customer_trx_id '|| ln_previous_customer_trx_id ||
                                        ' lt_apply_date(i) '|| lt_apply_date(ln_row_count) ||
                                        ' lt_gl_date(i) '|| lt_gl_date(ln_row_count) );


        AR_RECEIPT_API_PUB.Unapply (
                                      p_api_version       =>  1.0                   ,
                                      p_init_msg_list     =>  FND_API.G_TRUE        ,
                                      x_return_status     =>  lv_return_status      ,
                                      x_msg_count         =>  ln_msg_count          ,
                                      x_msg_data          =>  lv_msg_data           ,
                                      p_cash_receipt_id   =>  lt_receipt_id_tab(ln_row_count),
                                      p_customer_trx_id   =>  ln_previous_customer_trx_id,
                                      p_reversal_gl_date  =>  lt_gl_date(ln_row_count));


        IF  (lv_return_status <> 'S')
        THEN
          fnd_file.put_line(FND_FILE.LOG, '>>>>>>>>>> Problems during Receipt Unapplication');
          fnd_file.put_line(FND_FILE.LOG,  'lv_return_status : ' || lv_return_status);
          fnd_file.put_line(FND_FILE.LOG,  'ln_msg_count     : ' || ln_msg_count);
          fnd_file.put_line(FND_FILE.LOG,  'lv_msg_data      : ' || lv_msg_data);
          p_process_status  := lv_return_status;
          p_process_message := lv_msg_data;
          goto EXIT_POINT;
        END IF;

        ln_row_count := ln_row_count + 1;

      END LOOP;
      --bug#9230409, end


      --This procedure maintains the history of ar_payment_schedules_all in jai_ar_payment_audits
      maintain_schedules( p_customer_trx_id           => p_customer_trx_id,
                          p_payment_schedule_id       => NULL,
                          p_cm_customer_trx_id        => p_customer_trx_id,
                          p_invoice_customer_trx_id   => ln_previous_customer_trx_id,
                          p_concurrent_req_num        => NULL,
                          p_request_id                => NULL,
                          p_operation_type            => 'INSERT',
                          p_payment_audit_id          => ln_payment_audit_id,
                          p_process_status            => lv_process_status,
                          p_process_message           => lv_process_message);

      IF lv_process_status <> jai_constants.successful THEN
        p_process_status := lv_process_status;
        p_process_message := lv_process_message;
        goto EXIT_POINT;
      END IF;

      IF p_debug = 'Y' THEN
        fnd_file.put_line(FND_FILE.LOG, 'After INSERT call to maintain_schedules');
      END IF;

      UPDATE ar_payment_schedules_all
      SET    amount_due_original = ROUND(NVL(amount_line_items_original,0) + ln_total_tax_amt_for_inv + ln_total_frt_amt_for_inv, ln_precision),
             tax_original        = ROUND(ln_total_tax_amt_for_inv, ln_precision),
             freight_original    = ROUND(ln_total_frt_amt_for_inv, ln_precision),
             amount_applied      = ROUND(NVL(amount_line_items_original,0) + ln_total_tax_amt_for_inv + ln_total_frt_amt_for_inv, ln_precision),
             last_update_date    = SYSDATE
      WHERE  customer_trx_id     = p_customer_trx_id;

      --This procedure maintains the history of ar_payment_schedules_all in jai_ar_payment_audits
      maintain_schedules( p_customer_trx_id           => p_customer_trx_id,
                          p_payment_schedule_id       => NULL,
                          p_cm_customer_trx_id        => p_customer_trx_id,
                          p_invoice_customer_trx_id   => ln_previous_customer_trx_id,
                          p_concurrent_req_num        => NULL,
                          p_request_id                => NULL,
                          p_operation_type            => 'UPDATE',
                          p_payment_audit_id          => ln_payment_audit_id,
                          p_process_status            => lv_process_status,
                          p_process_message           => lv_process_message);

      IF lv_process_status <> jai_constants.successful THEN
        p_process_status := lv_process_status;
        p_process_message := lv_process_message;
        goto EXIT_POINT;
      END IF;

      IF p_debug = 'Y' THEN
        fnd_file.put_line(FND_FILE.LOG, 'After UPDATE call to maintain_schedules');
      END IF;


      --get the min(payment_schedule_id) and term_id from ar_payment_schedules_all for customer_trx_id
      OPEN cur_min_payment_schedule(ln_previous_customer_trx_id);
      FETCH cur_min_payment_schedule INTO rec_inv_payment_schedule;
      CLOSE cur_min_payment_schedule;

      --Get the first_installment_code and base_amount from ra_terms
      OPEN cur_term_details(rec_inv_payment_schedule.term_id);
      FETCH cur_term_details INTO rec_term_details;
      CLOSE cur_term_details;

      --Get the SUM(amount) from ra_cust_trx_line_gl_dist_all for the Credit Memo
      OPEN cur_tot_amt_for_cms(ln_previous_customer_trx_id,
                                lv_account_class_tax);
      FETCH cur_tot_amt_for_cms INTO ln_tax_amt_cms;
      CLOSE cur_tot_amt_for_cms;

      --Get the SUM(amount) from ra_cust_trx_line_gl_dist_all for the Credit Memo
      OPEN cur_tot_amt_for_cms(ln_previous_customer_trx_id,
                                lv_account_class_freight);
      FETCH cur_tot_amt_for_cms INTO ln_frt_amt_cms;
      CLOSE cur_tot_amt_for_cms;

      --Get the SUM of tax_applied and freight_applied from ar_receivable_applications_all for Cash receipts applied
      OPEN cur_tot_cash_rcpt(ln_previous_customer_trx_id);
      FETCH cur_tot_cash_rcpt INTO ln_tax_amt_cashrcpt,
                                    ln_frt_amt_cashrcpt;
      CLOSE cur_tot_cash_rcpt;

      IF p_debug = 'Y' THEN
        fnd_file.put_line(FND_FILE.LOG, 'Before entering rec_payment LOOP');
      END IF;

      --get the data from ar_payment_schedules_all for customer_trx_id and payment_schedule_id
      FOR rec_payment in cur_payment_schedule(ln_previous_customer_trx_id)
      LOOP
        IF p_debug = 'Y' THEN
          fnd_file.put_line(FND_FILE.LOG, 'In rec_payment LOOP');
        END IF;


        --Get the relative_amount from ra_terms_lines
        OPEN cur_term_lines(rec_payment.term_id,
                            rec_payment.terms_sequence_number);
        FETCH cur_term_lines INTO ln_relative_amt;
        CLOSE cur_term_lines;

        IF p_debug = 'Y' THEN
          fnd_file.put_line(FND_FILE.LOG, 'after cursor cur_term_lines');
        END IF;

        IF rec_term_details.first_installment_code = 'ALLOCATE' THEN
          ln_apportion_factor := ln_relative_amt/rec_term_details.base_amount;
        ELSE
          ln_apportion_factor := 1;
          rec_payment.payment_schedule_id := rec_inv_payment_schedule.payment_schedule_id;
        END IF;

        --Get the SUM of line_applied from ar_receivable_applications_all for CM
        OPEN cur_tot_recv_appl( ln_previous_customer_trx_id,
                                rec_payment.payment_schedule_id);
        FETCH cur_tot_recv_appl INTO ln_line_applied;
        CLOSE cur_tot_recv_appl;

        IF p_debug = 'Y' THEN
          fnd_file.put_line(FND_FILE.LOG, 'after cursor cur_tot_recv_appl');
        END IF;

        ln_inst_tax_amt_for_inv := ln_tax_amt_cms * ln_apportion_factor;
        ln_inst_frt_amt_for_inv := ln_frt_amt_cms * ln_apportion_factor;


        --get the allow_overapplication_flag from ra_cust_trx_types_all for cust_trx_type_id
        OPEN  cur_trx_types(rec_inv_customer_trx.cust_trx_type_id);
        FETCH cur_trx_types INTO lv_allow_overappln_flag ;
        CLOSE cur_trx_types ;

        IF p_debug = 'Y' THEN
          fnd_file.put_line(FND_FILE.LOG, 'after cursor cur_trx_types');
        END IF;


        --Get the data from ar_payment_schedules_all for customer_trx_id
        OPEN cur_prev_payment_schedule( ln_previous_customer_trx_id,
                                        rec_payment.payment_schedule_id);
        FETCH cur_prev_payment_schedule INTO rec_prev_payment_schedule;
        CLOSE cur_prev_payment_schedule;

        IF p_debug = 'Y' THEN
          fnd_file.put_line(FND_FILE.LOG, 'after cursor cur_payment_schedule');
        END IF;

        ln_amt_due_rem :=   NVL(rec_prev_payment_schedule.amount_line_items_remaining,0)
                          + NVL(rec_prev_payment_schedule.tax_original,0)
                          + NVL(rec_prev_payment_schedule.freight_original,0)
                          + NVL(ln_inst_tax_amt_for_inv,0)
                          + NVL(ln_inst_frt_amt_for_inv,0)
                          - ln_tax_amt_cashrcpt
                          - ln_frt_amt_cashrcpt;

        IF p_debug = 'Y' THEN
          fnd_file.put_line(FND_FILE.LOG, 'ln_amt_due_--| '||ln_amt_due_rem);
        END IF;

        IF   ( NVL(lv_allow_overappln_flag,'N') = 'Y'                         )  OR
             ( NVL(lv_allow_overappln_flag,'N') = 'N' AND ln_amt_due_rem >= 0 )
        THEN

          --This procedure maintains the history of ar_payment_schedules_all in jai_ar_payment_audits
          maintain_schedules( p_customer_trx_id           => p_customer_trx_id,
                              p_payment_schedule_id       => rec_payment.payment_schedule_id,
                              p_cm_customer_trx_id        => p_customer_trx_id,
                              p_invoice_customer_trx_id   => ln_previous_customer_trx_id,
                              p_concurrent_req_num        => NULL,
                              p_request_id                => NULL,
                              p_operation_type            => 'INSERT',
                              p_payment_audit_id          => ln_payment_audit_id,
                              p_process_status            => lv_process_status,
                              p_process_message           => lv_process_message);

          IF lv_process_status <> jai_constants.successful THEN
            p_process_status := lv_process_status;
            p_process_message := lv_process_message;
            goto EXIT_POINT;
          END IF;

          IF p_debug = 'Y' THEN
            fnd_file.put_line(FND_FILE.LOG, 'after Call to maintain_schedules');
          END IF;

          UPDATE  ar_payment_schedules_all
          SET     amount_due_remaining        = ROUND (ln_amt_due_rem ,ln_precision) ,
                  tax_remaining               = ROUND(tax_original - ln_tax_amt_cashrcpt + NVL(ln_inst_tax_amt_for_inv,0),ln_precision) ,
                  freight_remaining           = ROUND(freight_original - ln_frt_amt_cashrcpt + NVL(ln_inst_frt_amt_for_inv,0),ln_precision) ,
                  acctd_amount_due_remaining  = ROUND(ln_amt_due_rem * ln_inv_curr_conv_rate, ln_precision) ,
                  amount_credited             = (-1) * ROUND( ( NVL(ln_line_Applied,0) - NVL(ln_inst_tax_amt_for_inv,0) - NVL(ln_inst_frt_amt_for_inv,0)),ln_precision),
                  last_update_date            = SYSDATE
          WHERE   customer_trx_id             = ln_previous_customer_trx_id
          AND     payment_schedule_id         = rec_payment.payment_schedule_id;


          IF p_debug = 'Y' THEN
            fnd_file.put_line(FND_FILE.LOG, 'After first update fo ar_payment_schedules_all');
          END IF;

          UPDATE  ar_payment_schedules_all
          SET     status                      = DECODE (amount_due_remaining, 0, 'CL', 'OP'),
                  gl_date_closed              = DECODE (amount_due_remaining, 0, SYSDATE,  TO_DATE('31/12/4712','DD/MM/RRRR') /* Commented by Nprashar for Bug #6784276(SYSDATE -100000 )*/ ), --TO_DATE('31-DEC-4712','DD-MON-YYYY')) ,
                  actual_date_closed          = DECODE (amount_due_remaining, 0, SYSDATE,  TO_DATE('31/12/4712','DD/MM/RRRR') /* Commented by Nprashar for Bug #6784276(SYSDATE -100000 )*/ ),-- TO_DATE('31-DEC-4712','DD-MON-YYYY')),
                  last_update_date            = SYSDATE
          WHERE   customer_trx_id             = ln_previous_customer_trx_id
          AND     payment_schedule_id         = rec_payment.payment_schedule_id;

          IF p_debug = 'Y' THEN
            fnd_file.put_line(FND_FILE.LOG, 'After second update fo ar_payment_schedules_all');
          END IF;

          --This procedure maintains the history of ar_payment_schedules_all in jai_ar_payment_audits
          maintain_schedules( p_customer_trx_id           => p_customer_trx_id,
                              p_payment_schedule_id       => rec_payment.payment_schedule_id,
                              p_cm_customer_trx_id        => p_customer_trx_id,
                              p_invoice_customer_trx_id   => ln_previous_customer_trx_id,
                              p_concurrent_req_num        => NULL,
                              p_request_id                => NULL,
                              p_operation_type            => 'UPDATE',
                              p_payment_audit_id          => ln_payment_audit_id,
                              p_process_status            => lv_process_status,
                              p_process_message           => lv_process_message);

          IF lv_process_status <> jai_constants.successful THEN
            p_process_status := lv_process_status;
            p_process_message := lv_process_message;
            goto EXIT_POINT;
          END IF;

          IF p_debug = 'Y' THEN
            fnd_file.put_line(FND_FILE.LOG, 'after Call to maintain_schedules');
          END IF;


          --Get the receivable_application_id from ar_receivable_applications_all for the Invoice's payment_schedule_id
          OPEN cur_recv_appl_id(ln_previous_customer_trx_id,
                                p_customer_trx_id,
                                rec_payment.payment_schedule_id);
          FETCH cur_recv_appl_id INTO ln_recv_appln_id;
          CLOSE cur_recv_appl_id;


          --This procedure maintains the history of ar_receivable_applications_all in jai_ar_rec_appl_audits
          maintain_applications(p_customer_trx_id             => p_customer_trx_id,
                                p_receivable_application_id   => ln_recv_appln_id,
                                p_concurrent_req_num          => NULL,
                                p_request_id                  => NULL,
                                p_operation_type              => 'INSERT',
                                p_rec_appl_audit_id           => ln_rec_appl_audit_id,
                                p_process_status              => lv_process_status,
                                p_process_message             => lv_process_message);

          IF lv_process_status <> jai_constants.successful THEN
            p_process_status := lv_process_status;
            p_process_message := lv_process_message;
            goto EXIT_POINT;
          END IF;

          IF p_debug = 'Y' THEN
            fnd_file.put_line(FND_FILE.LOG, 'after Call to maintain_applications');
          END IF;


          UPDATE  ar_receivable_applications_all
          SET     amount_applied              = ROUND( NVL(line_applied,0)
                                                        + ( (-1) * NVL(ln_total_tax_amt_for_inv,0) * ln_apportion_factor)
                                                        + ( (-1) * NVL(ln_total_frt_amt_for_inv,0) * ln_apportion_factor)
                                                        ,ln_precision),
                  acctd_amount_applied_from   = ROUND( ( NVL(line_applied,0)
                                                        + ( (-1) * NVL(ln_total_tax_amt_for_inv,0) * ln_apportion_factor)
                                                        + ( (-1) * NVL(ln_total_frt_amt_for_inv,0) * ln_apportion_factor)
                                                       ) * ln_cm_curr_conv_rate
                                                       ,ln_precision),
                  acctd_amount_applied_to     = ROUND( ( NVL(line_applied,0)
                                                        + ( (-1) * NVL(ln_total_tax_amt_for_inv,0) * ln_apportion_factor)
                                                        + ( (-1) * NVL(ln_total_frt_amt_for_inv,0) * ln_apportion_factor)
                                                       ) * ln_inv_curr_conv_rate
                                                       ,ln_precision),
                  tax_applied                 = (ROUND( (-1) * NVL(ln_total_tax_amt_for_inv,0) * ln_apportion_factor , ln_precision )),
                  freight_applied             = (ROUND( (-1) * NVL(ln_total_frt_amt_for_inv,0) * ln_apportion_factor , ln_precision )),
                  last_update_date            = SYSDATE
          WHERE   customer_trx_id             = p_customer_trx_id
          AND     receivable_application_id   = ln_recv_appln_id;
          /*
          || Modified by Ramananda for bug#5495711, Ends
          */

          IF p_debug = 'Y' THEN
            fnd_file.put_line(FND_FILE.LOG, 'after update of ar_receivable_applications_all');
          END IF;

          maintain_applications(p_customer_trx_id             => p_customer_trx_id,
                                p_receivable_application_id   => ln_recv_appln_id,
                                p_concurrent_req_num          => NULL,
                                p_request_id                  => NULL,
                                p_operation_type              => 'UPDATE',
                                p_rec_appl_audit_id           => ln_rec_appl_audit_id,
                                p_process_status              => lv_process_status,
                                p_process_message             => lv_process_message);

          IF lv_process_status <> jai_constants.successful THEN
            p_process_status := lv_process_status;
            p_process_message := lv_process_message;
            goto EXIT_POINT;
          END IF;

          IF p_debug = 'Y' THEN
            fnd_file.put_line(FND_FILE.LOG, 'after Call to maintain_applications');
          END IF;

          --added for bug#8325824, start
          IF p_debug = 'Y' THEN
            fnd_file.put_line(FND_FILE.LOG, 'before insert into ar_distributions_all');
          END IF;
          insert_ar_dist_entries( p_customer_trx_id             => p_customer_trx_id,
                                  p_receivable_appl_id          => ln_recv_appln_id,
                                  p_debug                       => p_debug,
                                  p_process_status              => lv_process_status,
                                  p_process_message             => lv_process_message
                                  );

          IF p_debug = 'Y' THEN
            fnd_file.put_line(FND_FILE.LOG, 'after insert into ar_distributions_all');
          END IF;

          --bug#8325824, end

          IF rec_term_details.first_installment_code <> 'ALLOCATE' THEN
            EXIT;
          END IF;

        ELSE --over_application condition
          p_process_message := 'CM : Allow Over application on invoice is not allowed , hence not processing the taxes on the credit memo';
          p_process_status := jai_constants.expected_error;

          goto EXIT_POINT;

        END IF ;

      END LOOP; --End rec_payment cursor
       --added for bug#9230409,start
      /**application of the receipt for the remaining amount i.e after application of CM***/
      -- added by Allen Yang 04-Jun-2010 for bug #9709906, begin
      --------------------------------------------------------------------------
      /* for non-shippable RMAs, receipt action is not required and supported,
         hence lt_receipt_id_tab will be null for non-shippable RMAs*/
      IF lt_receipt_id_tab.COUNT > 0 THEN
      --------------------------------------------------------------------------
      -- added by Allen Yang 04-Jun-2010 for bug #9709906, end
        FOR i in lt_receipt_id_tab.FIRST..lt_receipt_id_tab.LAST
        LOOP
          fnd_file.put_line(FND_FILE.LOG, 'lt_receipt_id_tab(i) '|| lt_receipt_id_tab(i) ||
                                          ' ln_previous_customer_trx_id '|| ln_previous_customer_trx_id ||
                                          ' lt_apply_date(i) '|| lt_apply_date(i) ||
                                          ' lt_gl_date(i) '|| lt_gl_date(i) );
          AR_RECEIPT_API_PUB.Apply (
                                    p_api_version       =>  1.0                       ,
                                    p_init_msg_list     =>  FND_API.G_TRUE            ,
                                    x_return_status     =>  lv_return_status          ,
                                    x_msg_count         =>  ln_msg_count              ,
                                    x_msg_data          =>  lv_msg_data               ,
                                    p_cash_receipt_id   =>  lt_receipt_id_tab(i)      ,
                                    p_customer_trx_id   =>  ln_previous_customer_trx_id,
                                    p_apply_date        =>  lt_apply_date(i)          ,
                                    p_apply_gl_date     =>  lt_gl_date(i)
                                  );
          IF  (lv_return_status <> 'S')
          THEN
           fnd_file.put_line(FND_FILE.LOG, '>>>>>>>>>> Problems during Receipt Application');
           fnd_file.put_line(FND_FILE.LOG, 'lv_return_status : ' || lv_return_status);
           fnd_file.put_line(FND_FILE.LOG, 'ln_msg_count     : ' || ln_msg_count);
           fnd_file.put_line(FND_FILE.LOG, 'lv_msg_data      : ' || lv_msg_data);
           p_process_status := lv_return_status;
           p_process_message := lv_msg_data;
           goto EXIT_POINT;
          END IF;
        END LOOP;
      -- added by Allen Yang 04-Jun-2010 for bug #9709906, begin
      END IF; -- lt_receipt_id_tab.COUNT > 0
      -- added by Allen Yang 04-Jun-2010 for bug #9709906, end
        --bug#9230409, end

    ELSE --In case of invoice

      ln_payment_audit_id := NULL;

      IF p_debug = 'Y' THEN
        fnd_file.put_line(FND_FILE.LOG, 'In else of previous_customer_trx_id');
      END IF;

      --Get the first_installment_code and base_amount from ra_terms
      OPEN cur_term_details(rec_min_payment_schedule.term_id);
      FETCH cur_term_details INTO rec_term_details;
      CLOSE cur_term_details;

      --get the data from ar_payment_schedules_all for customer_trx_id and payment_schedule_id
      FOR rec_payment in cur_payment_schedule(p_customer_trx_id)
      LOOP

        IF p_debug = 'Y' THEN
          fnd_file.put_line(FND_FILE.LOG, 'In LOOP cur_payment_schedule - rec_payment.payment_schedule_id'||rec_payment.payment_schedule_id);
          fnd_file.put_line(FND_FILE.LOG, 'In LOOP cur_payment_schedule - rec_term_details.first_installment_code'||rec_term_details.first_installment_code);
        END IF;

        --Get the relative_amount from ra_terms_lines
        OPEN cur_term_lines(rec_payment.term_id,
                            rec_payment.terms_sequence_number);
        FETCH cur_term_lines INTO ln_relative_amt;
        CLOSE cur_term_lines;

        IF rec_term_details.first_installment_code = 'ALLOCATE' THEN
          ln_apportion_factor := ln_relative_amt/rec_term_details.base_amount;
        ELSE
          ln_apportion_factor := 1;
          rec_payment.payment_schedule_id := rec_min_payment_schedule.payment_schedule_id;
        END IF;

        ln_inst_tax_amt_for_inv := ln_total_tax_amt_for_inv * ln_apportion_factor;
        ln_inst_frt_amt_for_inv := ln_total_frt_amt_for_inv * ln_apportion_factor;


        --This procedure maintains the history of ar_payment_schedules_all in jai_ar_payment_audits
        maintain_schedules( p_customer_trx_id           => p_customer_trx_id,
                            p_payment_schedule_id       => rec_payment.payment_schedule_id,
                            p_cm_customer_trx_id        => NULL,
                            p_invoice_customer_trx_id   => p_customer_trx_id,
                            p_concurrent_req_num        => NULL,
                            p_request_id                => NULL,
                            p_operation_type            => 'INSERT',
                            p_payment_audit_id          => ln_payment_audit_id,
                            p_process_status            => lv_process_status,
                            p_process_message           => lv_process_message);

        IF lv_process_status <> jai_constants.successful THEN
          p_process_status := lv_process_status;
          p_process_message := lv_process_message;
          goto EXIT_POINT;
        END IF;

        IF p_debug = 'Y' THEN
          fnd_file.put_line(FND_FILE.LOG, 'After call to maintain_schedules');
        END IF;

        UPDATE  ar_payment_schedules_all
        SET     amount_due_original        = ROUND(NVL(amount_line_items_original,0) + NVL(ln_inst_tax_amt_for_inv,0) + NVL(ln_inst_frt_amt_for_inv,0) , ln_precision),
                amount_due_remaining       = ROUND(NVL(amount_line_items_remaining,0) + NVL(ln_inst_tax_amt_for_inv,0) + NVL(ln_inst_frt_amt_for_inv,0), ln_precision),
                tax_original               = ROUND(NVL(ln_inst_tax_amt_for_inv,0), ln_precision),
                tax_remaining              = ROUND(NVL(ln_inst_tax_amt_for_inv,0), ln_precision),
                freight_original           = ROUND(NVL(ln_inst_frt_amt_for_inv,0), ln_precision),
                freight_remaining          = ROUND(NVL(ln_inst_frt_amt_for_inv,0), ln_precision),
                acctd_amount_due_remaining = ROUND(( NVL(amount_line_items_remaining,0) + NVL(ln_inst_tax_amt_for_inv,0) +  NVL(ln_inst_frt_amt_for_inv,0) ) * ln_inv_curr_conv_rate, ln_precision),
                last_update_date           = SYSDATE
        WHERE   customer_trx_id            = p_customer_trx_id
        AND     payment_schedule_id        = rec_payment.payment_schedule_id;

        IF p_debug = 'Y' THEN
          fnd_file.put_line(FND_FILE.LOG, 'After First update of ar_payment_schedules_all');
        END IF;

        UPDATE  ar_payment_schedules_all
        SET     status                      = DECODE (amount_due_remaining, 0, 'CL', 'OP'),
                gl_date_closed              = DECODE (amount_due_remaining, 0, SYSDATE, TO_DATE('31/12/4712','DD/MM/RRRR') /* Commented by Nprashar for Bug #6784276(SYSDATE -100000 )*/ ), --TO_DATE('31-DEC-4712','DD-MON-YYYY')) ,
                actual_date_closed          = DECODE (amount_due_remaining, 0, SYSDATE, TO_DATE('31/12/4712','DD/MM/RRRR') /* Commented by Nprashar for Bug #6784276(SYSDATE -100000 )*/ ), --TO_DATE('31-DEC-4712','DD-MON-YYYY')),
                last_update_date            = SYSDATE
        WHERE   customer_trx_id             = p_customer_trx_id
        AND     payment_schedule_id         = rec_payment.payment_schedule_id;

        IF p_debug = 'Y' THEN
          fnd_file.put_line(FND_FILE.LOG, 'After Second update of ar_payment_schedules_all '||SQL%ROWCOUNT);
        END IF;


        --This procedure maintains the history of ar_payment_schedules_all in jai_ar_payment_audits
        maintain_schedules( p_customer_trx_id           => p_customer_trx_id,
                            p_payment_schedule_id       => rec_payment.payment_schedule_id,
                            p_cm_customer_trx_id        => NULL,
                            p_invoice_customer_trx_id   => p_customer_trx_id,
                            p_concurrent_req_num        => NULL,
                            p_request_id                => NULL,
                            p_operation_type            => 'UPDATE',
                            p_payment_audit_id          => ln_payment_audit_id,
                            p_process_status            => lv_process_status,
                            p_process_message           => lv_process_message);

        fnd_file.put_line(FND_FILE.LOG, 'Out ln_payment_audit_id '||ln_payment_audit_id);

        IF lv_process_status <> jai_constants.successful THEN
          p_process_status := lv_process_status;
          p_process_message := lv_process_message;
          goto EXIT_POINT;
        END IF;

        IF p_debug = 'Y' THEN
          fnd_file.put_line(FND_FILE.LOG, 'After call to maintain_schedules');
        END IF;

        IF rec_term_details.first_installment_code <> 'ALLOCATE' THEN
          EXIT;
        END IF;

      END LOOP; --End cursor rec_payment
    END IF;


    --This procedure updates the MRC data for ra_cust_trx_line_gl_dist_all, ar_payment_schedules_all, ar_receivable_applications_all
    maintain_mrc( p_customer_trx_id       => p_customer_trx_id,
                  p_previous_cust_trx_id  => ln_previous_customer_trx_id,
                  p_called_from           => 7/13/2007,
                  p_process_status        => lv_process_status,
                  p_process_message       => lv_process_message);

    IF lv_process_status <> jai_constants.successful THEN
      p_process_status := lv_process_status;
      p_process_message := lv_process_message;
      goto EXIT_POINT;
    END IF;

    <<EXIT_POINT>>
    NULL;

  EXCEPTION
    WHEN resource_busy THEN
      fnd_file.put_line(FND_FILE.LOG,'Resource Busy,record '||p_customer_trx_id||' has been locked by another resource');
      p_process_message:= ' Resource Busy,record '||p_customer_trx_id||' has been locked by another resource ';
      p_process_status := jai_constants.unexpected_error;

    WHEN LOCALIZATION_TAX_NOT_DEFINED THEN
      fnd_file.put_line(FND_FILE.LOG,' ''Localization'' Tax not defined or is end-dated. Please ensure that a valid ''Localization'' Tax exists and is not enddated ');
      p_process_message:= ' ''Localization'' Tax not defined or is end-dated. Please ensure that a valid ''Localization'' Tax exists and is not enddated ';
      p_process_status := jai_constants.expected_error;

    WHEN ROUNDING_ACCOUNT_NOT_DEFINED THEN
      fnd_file.put_line(FND_FILE.LOG, lv_process_message );
      p_process_message := lv_process_message;
      p_process_status  := lv_process_status;

    WHEN OTHERS THEN
      fnd_file.put_line(FND_FILE.LOG,sqlerrm);
      p_process_status := jai_constants.unexpected_error;
      p_process_message :=SUBSTR(SQLERRM,1,120);

      UPDATE  JAI_AR_TRX_INS_LINES_T
      SET     error_flag      = 'R',
              err_mesg        = p_process_message
      WHERE   customer_trx_id = p_customer_trx_id;
  END process_from_order_line;

----------------------------------------------- --------------------


PROCEDURE process_manual_invoice(ERRBUF OUT NOCOPY VARCHAR2,
                 RETCODE OUT NOCOPY VARCHAR2,
                 P_CUSTOMER_TRX_ID  IN NUMBER,
                 P_LINK_LINE_ID IN NUMBER)
IS
  v_counter             Number:= 0;
  v_gl_date             Date;
  v_org_id              Number;
  v_line_no             Number := 0;
  v_receivable_amount       Number := 0;
  v_receivable_acctd_amount Number := 0;
  v_old_amount          Number := 0;
  v_old_acctd_amount        Number := 0;
  v_vat_tax_id          nUMBER(15);
  v_created_from            Varchar2(40);
  v_tax_amount          Number := 0;
  v_tax_amount1               Number := 0;
  v_freight_amount      Number := 0;
  v_freight_amount1     Number := 0;
  v_payment_schedule_id     Number ;
  lv_tax_const                  CONSTANT VARChar2(10) := 'TAX';   --rchandan for bug#4428980
  lv_freight_acc_class          CONSTANT varchar2(10) := 'FREIGHT';--rchandan for bug#4428980
  lv_acc_class_rev              CONSTANT varchar2(10) := 'REV';--rchandan for bug#4428980
  lv_acc_class_rec              CONSTANT varchar2(10) := 'REC';--rchandan for bug#4428980

  CURSOR count_cur IS
  SELECT count(customer_trx_line_id) FROM JAI_AR_TRX_INS_LINES_T
  WHERE  customer_trx_id = P_CUSTOMER_TRX_ID;

  CURSOR ORG_CUR IS
  SELECT ORG_ID, CREATED_FROM
  FROM   RA_CUSTOMER_TRX_ALL
  WHERE  CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID;



  CURSOR TEMP_CUR IS
  SELECT EXTENDED_AMOUNT,CUSTOMER_TRX_LINE_ID,CUSTOMER_TRX_ID ,SET_OF_BOOKS_ID,
         LINK_TO_CUST_TRX_LINE_ID,LINE_TYPE ,UOM_CODE,VAT_TAX_ID,ACCTD_AMOUNT,AMOUNT,
       CODE_COMBINATION_ID,CUST_TRX_LINE_SALES_REP_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,
       CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN,INSERT_UPDATE_FLAG
  FROM   JAI_AR_TRX_INS_LINES_T
  WHERE  customer_trx_id = P_CUSTOMER_TRX_ID and
         link_to_cust_trx_line_id = p_link_line_id
         order by CUSTOMER_TRX_LINE_ID;


  /* Added by Ramananda for bug#4468353 due to SLA uptake by AR */
  CURSOR c_gl_posted_date_cur(p_customer_trx_line_id RA_CUST_TRX_LINE_GL_DIST_ALL.customer_trx_line_id%type) IS
  SELECT gl_posted_date
  from RA_CUST_TRX_LINE_GL_DIST_ALL
  where customer_trx_line_id = p_customer_trx_line_id
  and account_class = 'REC'
  and latest_rec_flag = 'Y';

  ld_gl_posted_date RA_CUST_TRX_LINE_GL_DIST_ALL.gl_posted_date%type ;

  CURSOR GL_DATE_CUR IS
  SELECT DISTINCT gl_date
  FROM   RA_CUST_TRX_LINE_GL_DIST_ALL
  WHERE  CUSTOMER_TRX_LINE_ID IN (SELECT LINK_TO_CUST_TRX_LINE_ID FROM JAI_AR_TRX_INS_LINES_T
  WHERE  customer_trx_id = P_CUSTOMER_TRX_ID);


  CURSOR MAX_LINE_CUR(p_cust_link_line_id IN NUMBER, p_line_type IN VARCHAR2) IS
  SELECT NVL(MAX(line_number),0)
  FROM   RA_CUSTOMER_TRX_LINES_ALL
  WHERE  link_to_cust_trx_line_id = p_cust_link_line_id
   and   line_type = p_line_type;


  CURSOR LINK_LINE_CUR IS
  SELECT LINK_TO_CUST_TRX_LINE_ID,ERROR_FLAG   --added the error_flag condition to process the records,which got stuck up
  FROM   JAI_AR_TRX_INS_LINES_T
  WHERE  customer_trx_id = P_CUSTOMER_TRX_ID AND LINK_TO_CUST_TRX_LINE_ID = p_link_line_id;

  CURSOR PREVIOUS_AMOUNT_CUR IS
  SELECT A.AMOUNT , A.ACCTD_AMOUNT
  FROM   RA_CUST_TRX_LINE_GL_DIST_ALL A, RA_CUSTOMER_TRX_LINES_ALL B, JAI_AR_TRX_INS_LINES_T C
  WHERE  A.CUSTOMER_TRX_LINE_ID = B.CUSTOMER_TRX_LINE_ID
  AND    B.LINK_TO_CUST_TRX_LINE_ID = C.LINK_TO_CUST_TRX_LINE_ID
  AND    C.CUSTOMER_TRX_ID =    P_CUSTOMER_TRX_ID
  AND    A.ACCOUNT_CLASS IN (lv_tax_const,lv_freight_acc_class)
  AND    A.CUSTOMER_TRX_LINE_ID = C.CUSTOMER_TRX_LINE_ID;


/* Added by Ramananda for bug#4468353 due to ebtax uptake by AR, start */
lv_tax_regime_code       zx_rates_b.tax_regime_code%type ;
ln_party_tax_profile_id  zx_party_tax_profile.party_tax_profile_id%type ;
ln_tax_rate_id           zx_rates_b.tax_rate_id%type ;
/* Added by Ramananda for bug#4468353 due to ebtax uptake by AR, end */

--2001/06/26 Anuradha Parthasarathy
  Cursor payment_schedule_cur IS
  Select min(payment_schedule_id)
  From   Ar_Payment_Schedules_All
  Where  Customer_trx_ID = p_customer_trx_id;

/* AR Transactions with Invoicing Acctg Rules not supported by Localization, Enhancement Done on 16th NOV */
  Cursor accounting_set_cur IS
  Select accounting_rule_id
  From   Ra_Customer_Trx_Lines_All
  Where  Customer_Trx_Line_Id = p_link_line_id;
  v_accounting_rule_id      Number;
  v_account_set_flag        Char(1);

  Cursor prev_customer_trx_cur(p_line_type ra_customer_trx_lines_all.line_type%TYPE ) is
  Select previous_customer_trx_id
  from   ra_customer_trx_lines_all
  where  customer_trx_id = P_CUSTOMER_TRX_ID
  and      line_type     = p_line_type;
  --AND  customer_trx_line_id = p_link_line_id;  --Added this condition on 05-Apr-2002 as it should fetch only one value
  v_prev_customer_trx_id    Number;

  Cursor Inv_payment_schedule_cur(p_prev_customer_trx_id IN Number) is
  Select payment_schedule_id
  from   ar_payment_schedules_all
  where  customer_trx_id = p_prev_customer_trx_id;

--2001/07/04 Anuradha Parthasarathy
  v_interface_line_attribute6       Varchar2(30);
  v_return_reference_type_code  Varchar2(30);
  v_credit_invoice_line_id      Number;

  Cursor line_id_cur(p_line_type ra_customer_trx_lines_all.line_type%TYPE ) is
  Select interface_line_attribute6
  From   ra_customer_trx_lines_all
  Where  customer_trx_id = p_customer_trx_id
  and    line_type       = p_line_type;

  Cursor Ref_type_cur(p_line_id IN Number) is
  Select context,reference_line_id
  From   oe_order_lines_all
  Where  line_id = p_line_id;

  v_upd_created_from        varchar2(15);
  v_rma_check           Number;
  v_temp_cust_trx_id        Number;

  CURSOR ORG_CUR_UPD IS
   SELECT            created_from,
          NVL(exchange_rate,1) exchange_rate --9177024
          FROM   RA_CUSTOMER_TRX_ALL
  WHERE  CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID;

  CURSOR check_rma_ref IS
  SELECT 1 from JAI_OM_OE_RMA_LINES
  WHERE  TO_CHAR(RMA_NUMBER) IN (SELECT INTERFACE_HEADER_ATTRIBUTE1 FROM RA_CUSTOMER_TRX_ALL
       WHERE CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID)
         AND Rma_line_id in  ( Select RMA_LINE_ID from JAI_OM_OE_RMA_TAXES a,JAI_CMN_TAXES_ALL b
                               Where a.tax_id = b.tax_id
                               AND b.tax_type = jai_constants.tax_type_freight );

--added 12-Mar-2002
  CURSOR tax_type IS SELECT b.tax_type t_type,a.customer_trx_line_id  line_id
  FROM   JAI_AR_TRX_TAX_LINES A , JAI_CMN_TAXES_ALL B
  WHERE  link_to_cust_trx_line_id = p_link_line_id
  and  A.tax_id = B.tax_id;

  CURSOR get_reason IS
  SELECT reason_code FROM
  RA_CUSTOMER_TRX_ALL WHERE
  CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID;
  v_reason_code ra_customer_trx_all.reason_code%TYPE;
--end 12-Mar-2002
  v_tax_amt Number;
  v_err_mesg  VARCHAR2(250);
  l_retcode   NUMBER(1);
  l_errbuf    VARCHAR2(1996);

  CURSOR get_trx_num IS SELECT  --21-Mar-2002 for ar tax and freight
  trx_number FROM
  ra_customer_trx_all WHERE
  customer_trx_id = p_customer_trx_id;

--added the following cursor for bug#8476512
    CURSOR cur_chk_jai_tax_dtls ( cp_customer_trx_line_id IN ra_customer_trx_lines_all.customer_trx_line_id%TYPE,
                                  cp_link_to_cust_trx_line_id IN ra_customer_trx_lines_all.link_to_cust_trx_line_id%TYPE)
    IS
    SELECT 1
    FROM    jai_ar_trx_tax_lines
    WHERE   customer_trx_line_id = cp_customer_trx_line_id
    AND     link_to_cust_trx_line_id = cp_link_to_cust_trx_line_id;
 ln_tax_line_exists            NUMBER; --added for bug#8476512


  v_trx_num ra_customer_trx_all.trx_number%TYPE;
  v_count_trx NUMBER;
  V_sum_amt NUMBER;

------------------------------------------------------------------------------------------------
-- start of modification added by subbu and Jagdish on 10-jun-01 for discount issue.
  v_extended_amount_line number;
  v_taxable_amt number := 0;

   Cursor get_ext_amt_ln( p_line_type ra_customer_trx_lines.line_type%TYPE )
   is Select extended_amount
        from Ra_customer_trx_lines_all
       where customer_trx_id = P_CUSTOMER_TRX_ID
         and customer_trx_line_id = P_LINK_LINE_ID
         and line_type = p_line_type;--rchandan for bug#4428980

   Cursor get_ext_amt_tax is Select extended_amount,customer_trx_line_id
                            from Ra_customer_trx_lines_all
                            where customer_trx_id = P_CUSTOMER_TRX_ID
                            and Link_to_cust_trx_line_id = P_LINK_LINE_ID
                            and line_type = lv_tax_const;--rchandan for bug#4428980

  get_ext_amt_tax_rec get_ext_amt_tax%rowtype;

  Cursor get_taxable_amt(cust_trx_ln_id number) Is Select nvl(taxable_amount,0)
                                                  from ra_customer_trx_lines_all
                                                  where customer_trx_line_id = cust_trx_ln_id
                                                  and customer_trx_id = P_CUSTOMER_TRX_ID
                                                  and line_type = lv_tax_const;--rchandan for bug#4428980


-- end of modification  by subbu and Jagdish on 10-jun-01 for discount issue.
------------------------------------------------------------------------------------------------
--05-Apr-2002

  v_rec_ctr             Number ;
  v_PAYMENT_amt               Number :=0;
  v_FREIGHT_amt               Number :=0;
  V_TEMP                      Number ;
  v_sql_num                   Number ;
v_amt_a                       NUMBER;
v_tot_amount            NUMBER;
v_sql_count                   NUMBER;
v1_sql_count                  NUMBER;

Localization_tax_not_defined  EXCEPTION;  -- added by sriram - 3340594
Item_lines_already_accounted  EXCEPTION;
-- declaration for mrc starts here bug # 3326394

cursor c_gl_dist_cur is
select cust_trx_line_gl_dist_id
from   ra_cust_trx_line_gl_dist_all
where  customer_trx_id = p_customer_trx_id
and    account_class = lv_acc_class_rec  --rchandan for bug#4428980
and    latest_rec_flag = 'Y';

v_gl_dist_id  number;


/* Added by Ramananda for bug#4468353 due to sla uptake by AR, end */
l_xla_event  arp_xla_events.xla_events_type;
--start additions for bug#9177024

    lv_process_status VARCHAR2(100);
lv_process_message VARCHAR2(1000);
ln_exchange_rate jai_ar_trxs.exchange_rate%type;
lv_account_class_tax             VARCHAR2(10) := 'TAX';
  lv_account_class_freight         VARCHAR2(10) := 'FREIGHT';
  lv_account_class_rec             VARCHAR2(10) := 'REC';
  ln_precision                fnd_currencies.precision%TYPE;
  ln_old_amount               NUMBER;
    ln_taxable_amount           NUMBER;
    ln_tax_amt                  NUMBER;
    ln_tax_acctd_amount         NUMBER;


CURSOR cur_total_amt_trx_lines( cp_customer_trx_id      ra_customer_trx_all.customer_trx_id%TYPE,
                                  cp_customer_trx_line_id ra_customer_trx_lines_all.customer_trx_line_id%TYPE DEFAULT NULL,
                                  cp_line_type            ra_customer_trx_lines_all.line_type%TYPE)
  IS
  SELECT  NVL(SUM(extended_amount),0) extended_amount
  FROM    ra_customer_trx_lines_all
  WHERE   customer_trx_id       = cp_customer_trx_id
  AND     customer_trx_line_id  = NVL(cp_customer_trx_line_id, customer_trx_line_id)
  AND     line_type             = cp_line_type;


CURSOR cur_total_amt_gl_dist( cp_customer_trx_id      ra_customer_trx_all.customer_trx_id%TYPE)
  IS
  SELECT  NVL(SUM(amount),0)        amount,
          NVL(SUM(acctd_amount),0)  acctd_amount
  FROM    ra_cust_trx_line_gl_dist_all
  WHERE   customer_trx_id   =  cp_customer_trx_id
  AND     account_class     IN (lv_account_class_tax,lv_account_class_freight);



--end additions for bug#9177024


BEGIN   --MAIN BLOCK BEGIN


/*------------------------------------------------------------------------------------------
 FILENAME: jai_ar_match_tax_pkg.process_manual_invoice.sql

 CHANGE HISTORY:

S.No      Date          Author and Details
1.  2001/06/26      Anuradha Parthasarathy
                Cursor defn changed for proper defaultation of Tax Code.
2.  2001/07/04      Anuradha Parthasarathy
                Code added to credit tax amounts  when rma references
                a Sales Order or an Invoice.
3     2002/03/22        RPK : for BUG#2285636

                        Code modified to rollback the entire transactions if a transaction
                        is failed.That is, the tax lines will be inserted all or none in the
                        tables ra_customer_trx_lines_all ,ra_cust_trx_line_gl_dist_all.
                        Also,whenever any record got errored out,then the corresponding invoice
                        taxes will not be processed to the base table itself and that record will
                        be updated to 'R'(column error_flag).

                        Code modified to get the freight lines for the RMA Transactions.

4     2002/04/04        Code merged for the issue of the receipt not getting saved when applied to an
                        invoice having the discounts attached.

5     2002/04/09        For the BUG:2303830
                        Added the condition IF v_rec_ctr > 0 to update only if the record is
                        found in gl_dist table.

6     2002/04/22        RPK
                        BUG#2247013
                        Code modified to populate the freight lines for the Credit memo generated
                        against a RMA transaction and the update the customer balances for the
                        original invoice against which,this credit memo is generated.

7     2002/04/26        Sriram
                        For Bug #2316589 for handling duplicate customer trx ids that are
                        processed from manual invoice that might be stuck in the temp_lines
                        insert table

8     2002/05/30        RPK
                        BUG#2247013
                        Bug re-opened to prevent the duplication of the taxes in the credit memo
                        for the RMA transaction and also corresponding updation of the balances
                        of the original invoice.
10.   2003/02/17        Sriram - Bug # 2784431 - The select statement that identifies whether
                        tax records already exist is not written correctly , it has been
                        corrected.

11.  2003/12/26         Sriram - bug# 3340594 File Version 618.1

                        'Localization' tax if is end dates or is not present , it should show a meaningful
                        error message instead of a cannot insert null into type of error.This has been
                        acheived by adding an exception 'Localization_tax_not_defined' , raising the exception
                        and handling the exception with the appropriate error message.

12.  2003/26/12         Sriram - bug# 3326394 File Version 618.2

                        incorporating code changes for multiple reporting currencies.
                        api calls to ar_mrc_maintain procedure have been made at appropriate places to
                        delete data from ra_mc_trx_line_gl_dist table in case of re-processing records.

                        api calls to ar_mrc_maintain package insert records in the RA_MC_TRX_LINE_GL_DIST table
                        have  been added to insert tax and freight records

                        api call to update the REC row for the gl dist also has been written .

                        no calls made for ar_payment_schedules and ar_receivable_applications because
                        it is taken care when invoice is completed by base apps itself.

13.  28-May-2009    JMEENA for bug#8476512
        Modified the code in the procedure process_manual_invoice. Added the cursor cur_chk_jai_tax_dtls.
--------------------------------------------------------------------------------------------*/

v_sql_num := 0;

OPEN get_trx_num;
FETCH get_trx_num INTO v_trx_num;
CLOSE get_trx_num;

l_retcode := 0;
v_sql_num  :=1;

open prev_customer_trx_cur('LINE');--rchandan for bug#4428980
fetch prev_customer_trx_cur into v_temp_cust_trx_id;
close prev_customer_trx_cur;
v_sql_num  :=2;
OPEN  ORG_CUR_UPD;
FETCH ORG_CUR_UPD INTO v_upd_created_from,ln_exchange_rate;
CLOSE ORG_CUR_UPD;
  v_sql_num  :=3;

OPEN check_rma_ref;
FETCH check_rma_ref INTO v_rma_check;
CLOSE check_rma_ref;
v_sql_num  :=4;

--12-MAR-2002
OPEN get_reason;
FETCH get_reason INTO v_reason_code;
CLOSE get_reason;
v_sql_num  :=5;

OPEN  payment_schedule_cur;
FETCH payment_schedule_cur  INTO v_payment_schedule_id;
CLOSE payment_schedule_cur;
v_sql_num  :=6;

OPEN  prev_customer_trx_cur('LINE');--rchandan for bug#4428980
FETCH prev_customer_trx_cur INTO v_prev_customer_trx_id;
CLOSE prev_customer_trx_cur;
v_sql_num  :=7;

    BEGIN  --RMA Block.This block is for processing localization taxes for the Credit memos of RMA

       IF  v_temp_cust_trx_id IS NOT NULL AND  v_upd_created_from = 'RAXTRX' THEN
          -- AND v_reason_code = 'RETURN' THEN --commented for the BUG#2247013 as the reason_code can be anything.
           FOR tax_type_rec IN tax_type
           LOOP
             IF tax_type_rec.t_type <> 'Freight' THEN
                DELETE JAI_AR_TRX_INS_LINES_T
                  WHERE  customer_trx_id = P_CUSTOMER_TRX_ID
                  and link_to_cust_trx_line_id = P_LINK_LINE_ID
                and customer_trx_line_id = tax_type_rec.line_id
                and tax_type_rec.t_type <> jai_constants.tax_type_freight;
 v_sql_num  :=8;
                v_sql_count := SQL%ROWCOUNT;
             END IF;
          END LOOP;
       END IF;
       fnd_file.put_line(FND_FILE.LOG, 'Deletion in the RMA Blk...No. of rows deleted  '|| v_sql_count);
       fnd_file.put_line(FND_FILE.LOG, 'COMPLETED RUN.Processed the Invoice..RMA Blk.. '|| v_trx_num);

       EXCEPTION
       WHEN OTHERS THEN
         --retcode :=3;
         fnd_file.put_line(FND_FILE.LOG, 'ABORTED RUN FOR RMA.   Retcode = '|| retcode);
         fnd_file.put_line(FND_FILE.LOG, 'ERROR IN PROCESSING ..... ' || SQLERRM);
    END; --End block of RMA processing
    v_sql_num  :=9;

     --start additions for bug#9177024
    if v_upd_created_from ='ARXTWMAI'
    then
    delete_trx_data(p_customer_trx_id => p_customer_trx_id,
	            p_link_to_cust_trx_line_id=>p_link_line_id,
                    p_process_status  => lv_process_status,
                    p_process_message => lv_process_message);

    --get the tax amount
    OPEN cur_total_amt_gl_dist(p_customer_trx_id);
    FETCH cur_total_amt_gl_dist INTO  ln_tax_amt,
                                      ln_tax_acctd_amount;
    CLOSE cur_total_amt_gl_dist;

    --get the line amount
    OPEN cur_total_amt_trx_lines( p_customer_trx_id,
                                  NULL,
                                  'LINE');
    FETCH cur_total_amt_trx_lines INTO ln_old_amount ;
    CLOSE cur_total_amt_trx_lines;





    /* Modified for bug#5495711
    || acctd_amount = ROUND( (ln_old_acctd_amount + ln_tax_acctd_amount + ln_diff_tax_frt), ln_precision)
    */
    UPDATE  ra_cust_trx_line_gl_dist_all
    SET     amount = ln_old_amount + ln_tax_amt,
            acctd_amount = ROUND( ( ln_old_amount *ln_exchange_rate + ln_tax_acctd_amount ), ln_precision)
    WHERE   customer_trx_id = p_customer_trx_id
    AND     account_class = lv_account_class_rec --'REC'
    AND     latest_rec_flag = 'Y';

    end if;
--end addtiions for bug#9177024


    SELECT NVL(SUM(AMOUNT),0) INTO V_sum_amt FROM RA_CUST_TRX_LINE_GL_DIST_ALL WHERE
    ACCOUNT_CLASS = lv_acc_class_rev AND CUSTOMER_TRX_ID=P_CUSTOMER_TRX_ID;  --added on 22-Mar-2002 to get the revenue amount for the invoice
    v_sql_num  :=10;

    OPEN  COUNT_CUR;
    FETCH COUNT_CUR INTO v_counter;
    CLOSE COUNT_CUR;
    v_sql_num  :=11;

    IF NVL(v_counter,0) > 0 THEN   --Main v_counter if
       FOR PREVIOUS_AMOUNT_REC IN PREVIOUS_AMOUNT_CUR
       LOOP
          v_old_amount := NVL(v_old_amount,0) + nvl(PREVIOUS_AMOUNT_REC.amount,0);
          v_old_acctd_amount := NVL(v_old_acctd_amount,0) + NVL(PREVIOUS_AMOUNT_REC.acctd_amount,0);

       END LOOP;
       v_sql_num  :=12;

       FOR LINK_REC IN LINK_LINE_CUR
       LOOP
        v_sql_num  :=13;


            -- the following select statement commented and using the next one instead
            -- because this is wrong.We need to compare the ra_customer_trx_lines_all table
            -- with the link_to_cust_trx_line_id column instead of based on the customer_trx_line_id
            -- column in the ra_cust_trx_line_gl_dist_all table. -- bug # 2784431

            /*
            SELECT COUNT(Customer_trx_line_id) INTO v_rec_ctr FROM ra_cust_trx_line_gl_dist_all
            WHERE customer_trx_line_id = P_LINK_LINE_ID
            AND Account_class IN ('TAX','FREIGHT');  --Added on 09-Apr-2002 For the BUG#2303830
            */

            SELECT COUNT(Customer_trx_line_id) INTO v_rec_ctr
            FROM   ra_customer_trx_lines_all
            where  link_to_cust_trx_line_id = p_link_line_id
            and    line_type in (lv_tax_const,lv_freight_acc_class);  --rchandan for bug#4428980


            IF v_rec_ctr > 0 THEN   --Added on 09-Apr-2002 for the BUG#2303830

               v_sql_num  :=14;

               DELETE RA_CUST_TRX_LINE_GL_DIST_ALL
               WHERE  CUSTOMER_TRX_LINE_ID IN (SELECT CUSTOMER_TRX_LINE_ID
                                          FROM   RA_CUSTOMER_TRX_LINES_ALL
                                          WHERE LINK_TO_CUST_TRX_LINE_ID = LINK_REC.LINK_TO_CUST_TRX_LINE_ID)
               AND ACCOUNT_CLASS IN (lv_tax_const,lv_freight_acc_class);  --rchandan for bug#4428980

               -- added for mrc -- sriram - 26/12 -- 3326394

               for mrc_rec in
               (
                SELECT CUST_TRX_LINE_GL_DIST_ID
                FROM   RA_CUST_TRX_LINE_GL_DIST_ALL
                WHERE  CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID
                AND    ACCOUNT_CLASS IN (lv_tax_const,lv_freight_acc_class)  --rchandan for bug#4428980
                AND    CUSTOMER_TRX_LINE_ID
                IN
                (SELECT CUSTOMER_TRX_LINE_ID
                 FROM   RA_CUSTOMER_TRX_LINES_ALL
                 WHERE  CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID
                 AND    LINK_TO_CUST_TRX_LINE_ID = P_LINK_LINE_ID
                 AND    LINE_TYPE IN (lv_tax_const,lv_freight_acc_class)  --rchandan for bug#4428980
                )
               )
               Loop
                ar_mrc_engine.maintain_mrc_data(
                                                p_event_mode        => 'DELETE',
                                                p_table_name        => 'RA_CUST_TRX_LINE_GL_DIST',
                                                p_mode              => 'SINGLE',
                                                p_key_value         => mrc_rec.CUST_TRX_LINE_GL_DIST_ID
                                               );

               end loop;

               /*
               DELETE RA_MC_TRX_LINE_GL_DIST
               WHERE  CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID
               AND    CUST_TRX_LINE_GL_DIST_ID IN
               (
                SELECT CUST_TRX_LINE_GL_DIST_ID
                FROM   RA_CUST_TRX_LINE_GL_DIST_ALL
                WHERE  CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID
                AND    ACCOUNT_CLASS IN ('TAX','FREIGHT')
                AND    CUSTOMER_TRX_LINE_ID
                IN
                (SELECT CUSTOMER_TRX_LINE_ID
                 FROM   RA_CUSTOMER_TRX_LINES_ALL
                 WHERE  CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID
                 AND    LINK_TO_CUST_TRX_LINE_ID = P_LINK_LINE_ID
                 AND    LINE_TYPE IN ('TAX','FREIGHT')
                )
                )
               AND    ACCOUNT_CLASS IN ('TAX','FREIGHT');

              */

           v_sql_num  :=15;

               DELETE RA_CUSTOMER_TRX_LINES_ALL
               WHERE  LINK_TO_CUST_TRX_LINE_ID = LINK_REC.LINK_TO_CUST_TRX_LINE_ID;
             v_sql_num  :=16;

               Update  Ar_Payment_Schedules_All
               Set  Tax_Original = 0,
               Tax_remaining = 0,
               Freight_Original = 0,
               Freight_remaining = 0,
               Amount_Due_Original = v_sum_amt,
               Amount_Due_remaining = v_sum_amt,
               Acctd_amount_due_remaining = v_sum_amt
               Where    Customer_Trx_ID = p_customer_trx_id
             And     Payment_Schedule_ID = v_payment_schedule_id;

            END IF;

         v_sql_num  :=17;

       END LOOP;


       OPEN  ORG_CUR;
       FETCH ORG_CUR INTO V_ORG_ID, V_CREATED_FROM;
       CLOSE ORG_CUR;
       v_sql_num  :=18;

       OPEN  GL_DATE_CUR;
       FETCH GL_DATE_CUR INTO v_gl_date;
       CLOSE GL_DATE_CUR;
       v_sql_num  :=19;

      /* Commented by Ramananda for bug#4468353 due to ebtax uptake by AR */
      --2001/06/26 Anuradha Parthasarathy
       /*
       OPEN  VAT_TAX_ID_CUR(V_ORG_ID,'Localization');--rchandan for bug#4428980
       FETCH VAT_TAX_ID_CUR INTO v_vat_tax_id;
       CLOSE VAT_TAX_ID_CUR;

       if v_vat_tax_id is null then
          raise Localization_tax_not_defined;
       end if;
       */

/* Added by Ramananda for bug#4468353 due to ebtax uptake by AR, start */
       OPEN  jai_ar_trx_pkg.c_tax_regime_code_cur(V_ORG_ID);
       FETCH jai_ar_trx_pkg.c_tax_regime_code_cur INTO lv_tax_regime_code;
       CLOSE jai_ar_trx_pkg.c_tax_regime_code_cur ;

       OPEN  jai_ar_trx_pkg.c_party_tax_profile_id_cur(V_ORG_ID);
       FETCH jai_ar_trx_pkg.c_party_tax_profile_id_cur INTO ln_party_tax_profile_id;
       CLOSE jai_ar_trx_pkg.c_party_tax_profile_id_cur ;

       OPEN  jai_ar_trx_pkg.c_tax_rate_id_cur(lv_tax_regime_code, ln_party_tax_profile_id);
       FETCH jai_ar_trx_pkg.c_tax_rate_id_cur INTO ln_tax_rate_id;
       CLOSE jai_ar_trx_pkg.c_tax_rate_id_cur ;

       if ln_tax_rate_id is null then
          raise Localization_tax_not_defined;
       end if;
/* Added by Ramananda for bug#4468353 due to ebtax uptake by AR, end */

       v_sql_num  :=20;

       OPEN  ACCOUNTING_SET_CUR;
       FETCH ACCOUNTING_SET_CUR INTO v_accounting_rule_id;
       CLOSE ACCOUNTING_SET_CUR;
       v_sql_num  :=21;

       IF v_accounting_rule_id IS NOT NULL THEN
          v_account_Set_flag := 'Y';
       ELSE
          v_account_Set_flag := 'N';
       END IF;


       BEGIN   --Begin Temp_Cur Block

          SAVEPOINT TEMP_CUR_BLK_SVP;


          FOR TEMP_REC IN TEMP_CUR
          LOOP

--added for bug#8476512,start
          OPEN cur_chk_jai_tax_dtls( temp_rec.customer_trx_line_id,
                                     temp_rec.link_to_cust_trx_line_id);
          FETCH cur_chk_jai_tax_dtls INTO ln_tax_line_exists;
          CLOSE cur_chk_jai_tax_dtls;

          IF nvl(ln_tax_line_exists,0) <> 1 THEN
            Delete  JAI_AR_TRX_INS_LINES_T
            WHERE   customer_trx_line_id = temp_rec.customer_trx_line_id
            AND     link_to_cust_trx_line_id = temp_rec.link_to_cust_trx_line_id;
          ELSE
--End bug#8476512
              OPEN  MAX_LINE_CUR(TEMP_REC.LINK_TO_CUST_TRX_LINE_ID, TEMP_REC.line_type);
              FETCH MAX_LINE_CUR INTO v_line_no;
              CLOSE MAX_LINE_CUR;
          v_sql_num  :=22;

              v_line_no := NVL(v_line_no,0) + 1;

              IF TEMP_REC.INSERT_UPDATE_FLAG IN('U','X') THEN
                      v_sql_num  :=23;

                  /* Modified by Ramananda for bug#4468353 due to sla uptake by AR, start */
              OPEN  c_gl_posted_date_cur( TEMP_REC.link_to_cust_trx_line_id ) ;
              FETCH c_gl_posted_date_cur INTO ld_gl_posted_date ;
              CLOSE c_gl_posted_date_cur ;

              IF  ld_gl_posted_date is NULL THEN

                      INSERT INTO RA_CUSTOMER_TRX_LINES_ALL ( extended_amount,
                                                              customer_trx_line_id,
                                                              last_update_date,
                                                              last_updated_by,
                                                              creation_date,
                                                              created_by,
                                                              last_update_login,
                                                              customer_trx_id,
                                                              line_number,
                                                              set_of_books_id,
                                                              link_to_cust_trx_line_id,
                                                              line_type,
                                                              org_id,
                                                              uom_code,
                                                              autotax,
                                                              vat_tax_id)
                                                     VALUES ( TEMP_REC.extended_amount,
                                                              TEMP_REC.customer_trx_line_id,
                                                              TEMP_REC.last_update_date,
                                                              TEMP_REC.last_updated_by,
                                                              TEMP_REC.creation_date,
                                                              TEMP_REC.created_by,
                                                              TEMP_REC.last_update_login,
                                                              TEMP_REC.customer_trx_id,
                                                              v_line_no,
                                                              TEMP_REC.set_of_books_id,
                                                              TEMP_REC.link_to_cust_trx_line_id,
                                                              TEMP_REC.line_type,
                                                              v_org_id,
                                                              TEMP_REC.uom_code,
                                                              'N',
                                                              v_vat_tax_id);
                      v_sql_num  :=24;

                      INSERT INTO RA_CUST_TRX_LINE_GL_DIST_ALL(account_class,
                                                               account_set_flag,
                                                               acctd_amount,
                                                               amount,
                                                               code_combination_id,
                                                               cust_trx_line_gl_dist_id,
                                                               cust_trx_line_salesrep_id,
                                                               customer_trx_id,
                                                               customer_trx_line_id,
                                                               gl_date,
                                                               last_update_date,
                                                               last_updated_by,
                                                               creation_date,
                                                               created_by,
                                                               last_update_login,
                                                               org_id,
                                                               percent,
                                                               posting_control_id,
                                                               set_of_books_id )
                                                        VALUES( TEMP_REC.line_type,
                                                               v_account_set_flag,
                                                               TEMP_REC.acctd_amount,
                                                               TEMP_REC.amount,
                                                               TEMP_REC.CODE_COMBINATION_ID,
                                                               RA_CUST_TRX_LINE_GL_DIST_S.nextval,
                                                               TEMP_REC.cust_trx_line_sales_rep_id,
                                                               TEMP_REC.customer_trx_id,
                                                               TEMP_REC.customer_trx_line_id,
                                                               v_gl_date,
                                                               TEMP_REC.last_update_date,
                                                               TEMP_REC.last_updated_by,
                                                               TEMP_REC.creation_date,
                                                               TEMP_REC.created_by,
                                                               TEMP_REC.last_update_login,
                                                               v_org_id,
                                                               100,
                                                               -3,
                                                               TEMP_REC.set_of_books_id ) RETURNING cust_trx_line_gl_dist_id INTO v_gl_dist_id;

                   /* SLA Impact uptake */
                     --l_xla_event.xla_from_doc_id ;
                     --l_xla_event.xla_to_doc_id   ;
                     l_xla_event.xla_req_id            := NULL         ;
                     l_xla_event.xla_dist_id           := v_gl_dist_id ;
                     l_xla_event.xla_doc_table         := 'CT'         ;
                     l_xla_event.xla_doc_event         := NULL         ;
                     l_xla_event.xla_mode              := 'O'          ;
                     l_xla_event.xla_call              := 'D'          ;
                     --l_xla_event.xla_fetch_size

                    ARP_XLA_EVENTS.CREATE_EVENTS(p_xla_ev_rec => l_xla_event);


                   -- code for mrc insert starts here -- bug # 3326394
                   ar_mrc_engine.maintain_mrc_data(
                                p_event_mode        => 'INSERT',
                                p_table_name        => 'RA_CUST_TRX_LINE_GL_DIST',
                                p_mode              => 'SINGLE',
                                p_key_value         => v_gl_dist_id);

                   -- code for mrc ends here -- bug # 3326394

                  v_sql_num  :=25;

                ELSE  /*  v_gl_posted_date will not be null when the execution comes here */
                  raise Item_lines_already_accounted;
                END IF ; --v_gl_posted_date is null
             /* Modified by Ramananda for bug#4468353 due to sla uptake by AR, end */

           ELSE
                      UPDATE RA_CUSTOMER_TRX_LINES_ALL
                      SET    EXTENDED_AMOUNT = TEMP_REC.EXTENDED_AMOUNT,
                            LAST_UPDATE_DATE = TEMP_REC.LAST_UPDATE_DATE,
                            LAST_UPDATED_BY = TEMP_REC.LAST_UPDATED_BY,
                            CREATION_DATE  = TEMP_REC.CREATION_DATE,
                             CREATED_BY  = TEMP_REC.CREATED_BY,
                    LAST_UPDATE_LOGIN = TEMP_REC.LAST_UPDATE_LOGIN
                      WHERE  CUSTOMER_TRX_LINE_ID = TEMP_REC.CUSTOMER_TRX_LINE_ID;
                      v_sql_num  :=26;

                      UPDATE RA_CUST_TRX_LINE_GL_DIST_ALL
                      SET    ACCTD_AMOUNT = TEMP_REC.ACCTD_AMOUNT,
                      AMOUNT = TEMP_REC.EXTENDED_AMOUNT,
                      LAST_UPDATE_DATE = TEMP_REC.LAST_UPDATE_DATE,
                      LAST_UPDATED_BY = TEMP_REC.LAST_UPDATED_BY,
                      CREATION_DATE  = TEMP_REC.CREATION_DATE,
                      CREATED_BY  = TEMP_REC.CREATED_BY,
                      LAST_UPDATE_LOGIN = TEMP_REC.LAST_UPDATE_LOGIN
                      WHERE  CUSTOMER_TRX_LINE_ID = TEMP_REC.CUSTOMER_TRX_LINE_ID;
                v_sql_num  :=27;

              END IF;

              IF TEMP_REC.LINE_TYPE = 'TAX' THEN
                 v_tax_amount := nvl(v_tax_amount,0) + nvl(TEMP_REC.EXTENDED_AMOUNT,0);

              ELSIF TEMP_REC.LINE_TYPE = 'FREIGHT' THEN
                 v_freight_amount := nvl(v_freight_amount,0) + nvl(TEMP_REC.EXTENDED_AMOUNT,0);

              END IF;

              v_receivable_amount := nvl(v_receivable_amount,0) + nvl(TEMP_REC.EXTENDED_AMOUNT,0);
              v_receivable_acctd_amount := nvl(v_receivable_acctd_amount,0) + nvl(TEMP_REC.ACCTD_AMOUNT,0);
END IF; -- 8476512  IF nvl(ln_tax_line_exists,0) <> 1 THEN
         END LOOP;

         v_sql_num  :=28;

         Select SUM(amount),SUM(acctd_amount) into v_old_amount,v_old_acctd_amount   --Added this stmt for the above stmt
         From RA_CUST_TRX_LINE_GL_DIST_ALL
         Where customer_trx_id = P_CUSTOMER_TRX_ID
         AND  ACCOUNT_CLASS = lv_acc_class_rev; --rchandan for bug#4428980
         v_sql_num  :=29;

         Select SUM(amount) INTO v_tax_amt
         From RA_CUST_TRX_LINE_GL_DIST_ALL
         Where customer_trx_id = P_CUSTOMER_TRX_ID
         AND     ACCOUNT_CLASS IN (lv_tax_const,lv_freight_acc_class);  --rchandan for bug#4428980
         v_sql_num  :=30;

         UPDATE RA_CUST_TRX_LINE_GL_DIST_ALL
         SET    AMOUNT = NVL(v_old_amount,0) + NVL(v_tax_amt,0),
         ACCTD_AMOUNT = NVL(v_old_acctd_amount,0) + NVL(v_tax_amt,0)
         WHERE  CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID AND
         ACCOUNT_CLASS = lv_acc_class_rec; --rchandan for bug#4428980

         -- mrc update for gl dist - bug # 3326394
         open  c_gl_dist_cur;
         fetch c_gl_dist_cur into v_gl_dist_id;
         close c_gl_dist_cur;


         ar_mrc_engine.maintain_mrc_data(
                       p_event_mode        => 'UPDATE',
                       p_table_name        => 'RA_CUST_TRX_LINE_GL_DIST',
                       p_mode              => 'SINGLE',
                       p_key_value         => v_gl_dist_id);



v_amt_a := NVL(v_old_amount,0) + NVL(v_tax_amt,0);

         v_sql_num  :=31;

         --22-MAR-2002 FOR PROPER UPDATION

 If v_prev_customer_trx_id is null then

  v_sql_num  :=32;

            Update  Ar_Payment_Schedules_All
            Set  Tax_Original = NVL(Tax_Original,0) + NVL(v_tax_amount,0),
               Tax_remaining = NVL(Tax_remaining,0) + NVL(v_tax_amount,0),
               Freight_Original = NVL(Freight_Original,0) + NVL(v_freight_amount,0),
               Freight_remaining = NVL(Freight_remaining,0) + NVL(v_freight_amount,0),
                 Amount_Due_Original = NVL(Amount_Due_Original,0) + NVL(v_receivable_amount,0),
                 Amount_Due_remaining = NVL(Amount_Due_remaining,0) + NVL(v_receivable_amount,0),
                 Acctd_amount_due_remaining = NVL(Acctd_amount_due_remaining,0) + NVL(v_receivable_acctd_amount,0)
            Where    Customer_Trx_ID = p_customer_trx_id
            And     Payment_Schedule_ID = v_payment_schedule_id;

         fnd_file.put_line(FND_FILE.LOG, 'TAX ORIGINAL 1.......' || v_trx_num || 'is   ' || NVL(v_tax_amount,-111));
         fnd_file.put_line(FND_FILE.LOG, 'TAX --|AINING 1......' || v_trx_num || 'is   ' || NVL(v_tax_amount,-111));
         fnd_file.put_line(FND_FILE.LOG, 'FREIGHT ORIGINAL 1...' || v_trx_num || 'is      ' || NVL(v_freight_amount,-77));
         fnd_file.put_line(FND_FILE.LOG, 'FREIGHT --|AINING 1..' || v_trx_num || 'is     ' || NVL(v_freight_amount,-66));
         fnd_file.put_line(FND_FILE.LOG, 'AMOUNT DUE --|AINING 1...' || v_trx_num || 'is  ' || NVL(v_receivable_amount,-222));
         fnd_file.put_line(FND_FILE.LOG, 'AMOUNT DUE ORIGINAL 1...' || v_trx_num || 'is   ' || NVL(v_receivable_amount,333));
         fnd_file.put_line(FND_FILE.LOG, 'ACCTD AMOUNT DUE 1...' || v_trx_num || 'is      ' || NVL(v_receivable_acctd_amount,444));

       V_TEMP := NVL(v_old_amount,0) + NVL(v_tax_amt,0);

         fnd_file.put_line(FND_FILE.LOG, 'TAX ORIGINAL 2.......' || v_trx_num || 'is   ' || NVL(v_PAYMENT_amt,-111));
         fnd_file.put_line(FND_FILE.LOG, 'TAX --|AINING 2......' || v_trx_num || 'is   ' || NVL(v_PAYMENT_amt,-111));
         fnd_file.put_line(FND_FILE.LOG, 'FREIGHT ORIGINAL 2...' || v_trx_num || 'is      ' || NVL(v_FREIGHT_amt,-77));
         fnd_file.put_line(FND_FILE.LOG, 'FREIGHT --|AINING 2...' || v_trx_num || 'is     ' || NVL(v_FREIGHT_amt,-66));
         fnd_file.put_line(FND_FILE.LOG, 'AMOUNT DUE --|AINING 2...' || v_trx_num || 'is  ' || V_TEMP);
         fnd_file.put_line(FND_FILE.LOG, 'AMOUNT DUE ORIGINAL 2...' || v_trx_num || 'is   ' || V_TEMP);
         fnd_file.put_line(FND_FILE.LOG, 'ACCTD AMOUNT DUE 2...' || v_trx_num || 'is      ' || NVL(v_receivable_acctd_amount,444));

         end if;  --END 22-MAR-02 FOR PROPER UPDATION

         v_sql_num  :=33;

         DELETE JAI_AR_TRX_INS_LINES_T
         WHERE  customer_trx_id = P_CUSTOMER_TRX_ID and
       link_to_cust_trx_line_id = P_LINK_LINE_ID;
         v_sql_num  :=34;

         ERRBUF :=SQLERRM;
--         retcode := 0;
         fnd_file.put_line(FND_FILE.LOG, 'The total tax amount for the line  is....' ||  v_tax_amt);
         fnd_file.put_line(FND_FILE.LOG, 'The receivable amount for the line is....' ||  v_receivable_amount);
         fnd_file.put_line(FND_FILE.LOG, 'Successfully Processed the Invoice... '|| v_trx_num);
--         fnd_file.put_line(FND_FILE.LOG, 'COMPLETED RUN.Processed the Invoice  Retcode = '|| retcode);

         EXCEPTION
--          retcode := 5;
          when others then
          ERRBUF :=SUBSTR(SQLERRM,1,230);
          ROLLBACK TO TEMP_CUR_BLK_SVP;

          UPDATE JAI_AR_TRX_INS_LINES_T SET ERROR_FLAG = 'R',ERR_MESG = ERRBUF WHERE
          CUSTOMER_TRX_ID=P_CUSTOMER_TRX_ID
          AND LINK_TO_CUST_TRX_LINE_ID = P_LINK_LINE_ID;

          COMMIT;

--          fnd_file.put_line(FND_FILE.LOG, 'ABORTED RUN.   Retcode = '|| retcode);
          fnd_file.put_line(FND_FILE.LOG, 'Updated the customer_trx_id error_flag to ...' || 'R');
          fnd_file.put_line(FND_FILE.LOG, 'Unable to Process the invoice...   '|| v_trx_num);
          fnd_file.put_line(FND_FILE.LOG, 'ABORTED RUN... the err   = '|| SQLERRM);
          fnd_file.put_line(FND_FILE.LOG, 'ABORTED RUN... the err   = '|| SQLERRM || v_sql_num);


      END;   --End Temp_Cur Block


      IF v_created_from = 'RAXTRX' THEN

         If v_prev_customer_trx_id is NOT null THEN  --added on 22-Mar-2002

             Open  line_id_cur('LINE');--rchandan for bug#4428980
           Fetch line_id_cur into v_interface_line_attribute6;
           Close line_id_cur;

             Open  Ref_type_cur(v_interface_line_attribute6);
           Fetch Ref_type_cur into v_return_reference_type_code,v_credit_invoice_line_id;
           Close Ref_type_cur;

             --2001/07/04 Anuradha Parthasarathy

             IF v_return_reference_type_code = 'Sales Order India' and v_credit_invoice_line_id IS NULL THEN
                   Update  Ar_Payment_Schedules_All
                   Set     Tax_Original = NVL(Tax_Original,0) + NVL(v_tax_amount,0),
                     Freight_Original = NVL(Freight_Original,0) + NVL(v_freight_amount,0),
                     Amount_Due_Original = NVL(Amount_Due_Original,0) + NVL(v_receivable_amount,0)
                   Where   Customer_Trx_ID = p_customer_trx_id
                   And   Payment_Schedule_ID = v_payment_schedule_id;
                  fnd_file.put_line(FND_FILE.LOG, ' DEBUG:SPATIAL) checking Tax Details updating updating v_return_reference_type_code ' || v_return_reference_type_code  );
             ELSIF v_return_reference_type_code in ('Invoice India','Sales Order India')
             and v_credit_invoice_line_id IS NOT NULL THEN

                   Select sum(amount) INTO v_tax_amount1
                   FROM ra_cust_trx_line_gl_dist_all
                   Where customer_trx_id = p_customer_trx_id
                   And Account_class = lv_tax_const; --rchandan for bug#4428980

                   Select sum(amount) INTO v_freight_amount1
                   FROM ra_cust_trx_line_gl_dist_all
                   Where customer_trx_id = p_customer_trx_id
                   And Account_class = lv_freight_acc_class; --rchandan for bug#4428980

                   SELECT SUM(AMOUNT) INTO v_tot_amount
                   FROM ra_cust_trx_line_gl_dist_all
                   WHERE customer_trx_id = p_customer_trx_id
                   AND account_class = lv_acc_class_rec; --rchandan for bug#4428980


                   Update  Ar_Payment_Schedules_All
                   Set Tax_Original = NVL(v_tax_amount1,0),
                       Freight_Original = NVL(v_freight_amount1,0),
                       Amount_Due_Original = NVL(Amount_line_items_Original,0) + NVL(v_tax_amount1,0) + NVL(v_freight_amount1,0),
                       Amount_Applied = NVL(Amount_line_items_Original,0) + NVL(v_tax_amount1,0) + NVL(v_freight_amount1,0)
                   Where Customer_Trx_ID = p_customer_trx_id
                   And   Payment_Schedule_ID = v_payment_schedule_id;


--In the below statement only the freight amount is getting updated to all the columns,because the tax amount is
--automatcally updated by the base apps product

                   Update Ar_Receivable_Applications_All
                   Set    Amount_Applied = NVL(Amount_Applied,0) - (NVL(v_freight_amount1,0)),
                    --Tax_Applied    = NVL(Tax_Applied,0) - NVL(v_tax_amount1,0),
                    Freight_Applied = NVL(Freight_Applied,0) - NVL(v_freight_amount1,0),
                    Acctd_Amount_Applied_From = NVL(Acctd_Amount_Applied_From,0) - ( NVL(v_freight_amount1,0) ),
                    Acctd_Amount_Applied_To   = NVL(Acctd_Amount_Applied_To,0) - ( NVL(v_freight_amount1,0) )
                    Where  Customer_Trx_ID = p_customer_trx_id
                    And    Payment_Schedule_ID = v_payment_schedule_id; --20-Apr-2002

                 /* Updating Ar_Payment_Schedules for the Invoice against which this credit memo is applied */

                 OPEN      Inv_payment_schedule_cur(v_prev_customer_trx_id);
                 FETCH     Inv_payment_schedule_cur into v_payment_schedule_id;
                 CLOSE     Inv_payment_schedule_cur;

                 Update    Ar_Payment_Schedules_All
                 Set       --Tax_remaining = NVL(Tax_remaining,0) - NVL(v_tax_amount1,0),
                       Freight_remaining = NVL(Freight_remaining,0) + NVL(v_freight_amount1,0),
                       Amount_Due_remaining = NVL(Amount_Due_remaining,0) + NVL(v_freight_amount1,0),
                       Amount_Credited = NVL(Amount_Credited,0) + NVL(v_freight_amount1,0),
                       Acctd_Amount_Due_remaining = NVL(Acctd_Amount_Due_remaining,0) + NVL(v_freight_amount1,0)
                       Where     Customer_Trx_Id = v_prev_customer_trx_id
                       And       Payment_Schedule_Id = v_payment_Schedule_id;  --18-apr-2002

          fnd_file.put_line(FND_FILE.LOG, 'v_tot_amount   = '|| v_tot_amount);
          fnd_file.put_line(FND_FILE.LOG, 'v_tax_amount1   = '|| v_tax_amount1);
          fnd_file.put_line(FND_FILE.LOG, 'v_freight_amount1   = '|| v_freight_amount1);
                  fnd_file.put_line(FND_FILE.LOG, ' DEBUG:SPATIAL) checking Tax Details updating updating v_return_reference_type_code ' || v_return_reference_type_code  );
             END IF;

         END IF;

      END IF;

    END IF;  --End Main v_counter if

------------------------------------------------------------------------------------------------
-- Start modifications by subbu and Jagdish on 10-jun-01 for receipt discount issue.
OPEN get_ext_amt_ln('LINE');--rchandan for bug#4428980
FETCH get_ext_amt_ln INTO v_extended_amount_line;
CLOSE get_ext_amt_ln;

OPEN get_ext_amt_tax ;
LOOP
FETCH get_ext_amt_tax INTO get_ext_amt_tax_rec;
EXIT WHEN get_ext_amt_tax%NOTFOUND;
OPEN get_taxable_amt(get_ext_amt_tax_rec.customer_trx_line_id);
FETCH get_taxable_amt INTO v_taxable_amt;
 IF v_taxable_amt = 0 THEN
   UPDATE ra_customer_trx_lines_all
    SET Taxable_amount = (v_extended_amount_line - get_ext_amt_tax_rec.extended_amount)
     WHERE Customer_trx_line_id = get_ext_amt_tax_rec.customer_trx_line_id
     and customer_trx_id = P_CUSTOMER_TRX_ID
     and link_to_cust_trx_line_id = P_LINK_LINE_ID
     and Line_type = lv_tax_const;
 END IF;
CLOSE get_taxable_amt;
END LOOP;
CLOSE get_ext_amt_tax;
-- end  modifications by subbu and Jagdish on 10-jun-01 for receipt discount issue.
------------------------------------------------------------------------------------------------

    ERRBUF := SQLERRM;
--    retcode := 2;
    v_err_mesg := ERRBUF;

    COMMIT;

--    retcode := 0;
    fnd_file.put_line(FND_FILE.LOG, 'COMPLETED RUN.Processed the invoice   = '|| v_trx_num);
--    fnd_file.put_line(FND_FILE.LOG, 'COMPLETED RUN.Processed the customer_trx_id   Retcode = '|| retcode);

    EXCEPTION

       when Localization_tax_not_defined then
            fnd_file.put_line(FND_FILE.LOG,' ''Localization'' Tax not defined or is end-dated. Please ensure that a valid ''Localization'' Tax exists and is not enddated ');
            errbuf:= ' ''Localization'' Tax not defined or is end-dated. Please ensure that a valid ''Localization'' Tax exists and is not enddated ';
            retcode := 2;

        WHEN OTHERS THEN

           ERRBUF :=SUBSTR(SQLERRM,1,230);
           UPDATE JAI_AR_TRX_INS_LINES_T SET ERROR_FLAG = 'R',ERR_MESG=ERRBUF WHERE CUSTOMER_TRX_ID=P_CUSTOMER_TRX_ID
           AND LINK_TO_CUST_TRX_LINE_ID = P_LINK_LINE_ID;
           COMMIT;
--           retcode := 7;
--           fnd_file.put_line(FND_FILE.LOG, 'ABORTED RUN.   Retcode = '|| retcode);
           fnd_file.put_line(FND_FILE.LOG, 'ABORTED RUN... the invoice   = '|| v_trx_num);
           fnd_file.put_line(FND_FILE.LOG, 'ABORTED RUN... the err   = '|| SQLERRM);
           fnd_file.put_line(FND_FILE.LOG, 'Main Block.... the err   = '|| SQLERRM);
           fnd_file.put_line(FND_FILE.LOG, 'Please Contact the System Administrator Or Oracle Software Support Services...');

END process_manual_invoice;
-- Start commented by kunkumar for bug#6066813
--   following function added for bug#6012570 (5876390) --> revoked the comments, 6012570
  function is_this_projects_context(pv_context in varchar2) return varchar2 is
  begin
    if jai_ar_rctla_trigger_pkg.is_this_projects_context(pv_context) then
      return jai_constants.yes;
    else
      return jai_constants.no;
    end if;
  end is_this_projects_context;
--  End commented by kunkumar for bug#6066813*/, revoked the comments, 6012570


-- Added by Jia Li on tax inclusive computation on 2007/11/30, Begin
--==========================================================================
--  FUNCTION NAME:
--
--    get_tax_account_id                        Private
--
--  DESCRIPTION:
--
--    This function is get tax account ccid
--
--  PARAMETERS:
--      In:  pn_tax_id
--           pn_tax_type
--           pn_org_id
--
--  DESIGN REFERENCES:
--    Inclusive Tax Technical Design V1.4.doc
--
--  CHANGE HISTORY:
--
--           20-DEC-2007   Jia Li  created
--           20-Apr-2009   Jia Li  Modified for fixed bug#7205349
--                               Issue: VAT accounting is not proper for manual ar transaction
--                                      when inclusive VAT taxes are used.
--                               Fixed: Use VAT Interim Liability account to replace VAT Interim recovery account
--           30-Apr-2009   Jia Li  Modified for fixed bug#8474445
--                               Issue: VAT accounting is not proper for manual ar transaction
--                                      when inclusive VAT taxes are used.
--                               Fixed: Used VAT Liability account to replace VAT Interim Liability account.
--           04-JUN-2010   Bo Li  Modified for fixed bug#9771955
--                               Issue: VAT accounting is not proper for ORDER ENTRY
--                                      when inclusive VAT taxes are used.
--                               Fixed: Used  VAT Interim Liability account when the AR transation has
--                                      generated by autoinvoice

--==========================================================================
FUNCTION get_tax_account_id
( pn_tax_id    IN NUMBER
, pv_tax_type  IN VARCHAR2
, pn_org_id    IN NUMBER
)
RETURN NUMBER
IS
ln_tax_def_acc_id NUMBER;
ln_tax_rgm_acc_id NUMBER;
ln_tax_acc_id     NUMBER;
lv_procedure_name VARCHAR2(40):='get_tax_account_id';
ln_dbg_level      NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
ln_proc_level     NUMBER:=FND_LOG.LEVEL_PROCEDURE;

BEGIN
  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                  , 'Enter procedure'
                  );
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.parameter'
                  , 'Org_id = ' || pn_org_id
                  );
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.parameter'
                  , 'Tax_id = '|| pn_tax_id ||' Tax_type = ' || pv_tax_type
                  );
  END IF; --ln_proc_level>=l_dbg_level

  -- Get tax_account_id from tax defination
  BEGIN
    SELECT
      tax_account_id
    INTO
      ln_tax_def_acc_id
    FROM
      jai_cmn_taxes_all
    WHERE tax_id = pn_tax_id
      AND org_id = pn_org_id;
  EXCEPTION
    WHEN OTHERS THEN
      ln_tax_def_acc_id := -1;
  END;

  -- Get tax_account_id from rgm setup for SERVICE and VAT tax.
  BEGIN
    SELECT
      TO_NUMBER(acc_rgm.attribute_value)
    INTO
      ln_tax_rgm_acc_id
    FROM
      jai_rgm_definitions   rgm_def
    , jai_rgm_registrations tax_rgm
    , jai_rgm_registrations acc_rgm
    WHERE regime_code IN (jai_constants.service_regime,jai_constants.vat_regime)
      AND tax_rgm.regime_id = rgm_def.regime_id
      AND tax_rgm.registration_type = jai_constants.regn_type_tax_types
      AND tax_rgm.attribute_code = pv_tax_type
      AND tax_rgm.regime_id = acc_rgm.regime_id
      AND acc_rgm.registration_type = jai_constants.regn_type_accounts
      --AND acc_rgm.attribute_code = jai_constants.recovery_interim   -- --|oved by Jia for fixed bug#7205349 on 20-Apr-2009
     -- AND acc_rgm.attribute_code = jai_constants.liability    -- Modified by Jia for fixed bug#8474445 on 30-Apr-2009, use liability account to replace liability interim account

     AND acc_rgm.attribute_code = jai_constants.liability_interim --Added by Bo Li for bug#9771955 on 2010-06-04
     AND acc_rgm.parent_registration_id = tax_rgm.registration_id;

    ln_tax_acc_id := ln_tax_rgm_acc_id;
  EXCEPTION
    WHEN no_data_found THEN
      ln_tax_acc_id := ln_tax_def_acc_id;
    WHEN OTHERS THEN
      ln_tax_acc_id := -1;
  END;

  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.result'
                  , 'Tax Account ID = ' || ln_tax_acc_id
                  );
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                  , 'Enter procedure'
                  );
  END IF;  -- ln_proc_level >= ln_dbg_level

  RETURN ln_tax_acc_id;

END get_tax_account_id;


--==========================================================================
--  PROCEDURE NAME:
--
--    acct_inclu_taxes                        Public
--
--  DESCRIPTION:
--
--    This procedure is written that whould pass GL entries for inclusive taxes in GL interface
--
--  PARAMETERS:
--      In:  pn_customer_trx_id            Indicates the customer trx id
--           pn_org_id                     Indicates the transaction org id
--           pn_cust_trx_type_id           Indicates the custormer trx tye id
--     OUt:  xv_process_flag               Indicates the process flag, 'SS' for success
--                                                                     'EE' for expected error
--                                                                     'UE' for unexpected error
--           xv_process_message           Indicates the process message
--
--
--  DESIGN REFERENCES:
--    Inclusive Tax Technical Design V1.4.doc
--
--  CHANGE HISTORY:
--
--           30-NOV-2007   Jia Li  created
--           30-Apr-2009   Jia Li  Modified for fixed bug#8474445
--                               Issue: VAT accounting is not proper for manual ar transaction
--                                      when inclusive VAT taxes are used.
--                               Fixed: Used Revenue account to replace Receivables account for Inclusive Dr Accounting
--==========================================================================
PROCEDURE acct_inclu_taxes
( pn_customer_trx_id  IN  NUMBER
, pn_org_id           IN  NUMBER
, pn_cust_trx_type_id IN  NUMBER
, xv_process_flag     OUT NOCOPY VARCHAR2
, xv_process_message  OUT NOCOPY VARCHAR2
)
IS
ln_org_id              ra_customer_trx_all.org_id%TYPE;
ln_cust_trx_type_id    ra_customer_trx_all.cust_trx_type_id%TYPE;
lv_inv_num             ra_customer_trx_all.trx_number%TYPE;
ld_cur_conversion_date jai_ar_trxs.exchange_date%TYPE;
lv_cur_conversion_type jai_ar_trxs.exchange_rate_type%TYPE;
ln_cur_conversion_rate jai_ar_trxs.exchange_rate%TYPE;
lv_currency_code       jai_ar_trxs.invoice_currency_code%TYPE;
ln_inv_org_id          jai_ar_trxs.organization_id%TYPE;
lv_inv_org_code        mtl_parameters.organization_code%TYPE;
ln_rec_account_id      ra_cust_trx_types_all.gl_id_rec%TYPE;
ln_set_of_books_id     ra_cust_trx_line_gl_dist_all.set_of_books_id%TYPE;
ld_gl_date             ra_cust_trx_line_gl_dist_all.gl_date%TYPE;
ln_tax_account_id      NUMBER;
ln_total_inclu_tax_amt NUMBER;
exception_error        EXCEPTION;

CURSOR inclu_tax IS
  SELECT
    a.tax_id               tax_id
  , b.tax_type             tax_type
  , SUM(a.tax_amount)      tax_amount
  FROM
    jai_cmn_taxes_all    b
  , jai_ar_trx_tax_lines a
  WHERE a.tax_id = b.tax_id
    AND NVL(b.inclusive_tax_flag, 'N') = 'Y'
    AND a.link_to_cust_trx_line_id IN (SELECT
                                         customer_trx_line_id
                                       FROM
                                         jai_ar_trx_lines
                                       WHERE customer_trx_id = pn_customer_trx_id)
  GROUP BY
    a.tax_id
  , b.tax_type;

lv_procedure_name VARCHAR2(40):='acct_inclu_taxes';
ln_dbg_level      NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
ln_proc_level     NUMBER:=FND_LOG.LEVEL_PROCEDURE;


 lv_acc_class_rev              CONSTANT varchar2(10) := 'REV'; --bug#9461197

  /*start additions by vkaranam for bug#9461197*/
  cursor c_rev_acc is
select code_combination_id
from   ra_cust_trx_line_gl_dist_all
where  customer_trx_id = pn_customer_trx_id
and    account_class = lv_acc_class_rev;


BEGIN
  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                  , 'Enter procedure'
                  );
  END IF; --ln_proc_level>=l_dbg_level

  ln_org_id := pn_org_id;
  ln_cust_trx_type_id := pn_cust_trx_type_id;

  -- Get customer info
  BEGIN
    SELECT
      jat.trx_number
    , jat.exchange_date
    , jat.exchange_rate_type
    , jat.exchange_rate
    , jat.invoice_currency_code
    , jat.organization_id
    , mp.organization_code
    INTO
      lv_inv_num
    , ld_cur_conversion_date
    , lv_cur_conversion_type
    , ln_cur_conversion_rate
    , lv_currency_code
    , ln_inv_org_id
    , lv_inv_org_code
    FROM
      jai_ar_trxs         jat
    , mtl_parameters      mp
    WHERE jat.customer_trx_id = pn_customer_trx_id
      AND jat.organization_id = mp.organization_id;

  EXCEPTION
    WHEN OTHERS THEN
      xv_process_message := Sqlerrm||'. Get customer info in acct_inclu_taxes procedure.';
      RAISE exception_error;
  END;

  -- Get Revenue dr accounting id
  BEGIN
    /*
    SELECT
      gl_id_rev           -- Modified by Jia for fixed bug#8474445, use gl_id_rev to replace gl_id_rec
    INTO
      ln_rec_account_id
    FROM
      ra_cust_trx_types_all
    WHERE  org_id = ln_org_id
      AND cust_trx_type_id = ln_cust_trx_type_id;
      *//*commented by vkaranam for bug#9461197*/

     --added the below by vkaranam for bug#9461197
      open c_rev_acc;
      fetch c_rev_acc into ln_rec_account_id;
      close c_rev_acc;

  EXCEPTION
    WHEN OTHERS THEN
      xv_process_message := Sqlerrm||'. Get revenue dr accounting in acct_inclu_taxes procedure.';
      RAISE exception_error;
  END;


  BEGIN
    SELECT
      set_of_books_id
    , gl_date
    INTO
      ln_set_of_books_id
    , ld_gl_date
    FROM ra_cust_trx_line_gl_dist_all
    WHERE customer_trx_id = pn_customer_trx_id
      AND rownum = 1;

  EXCEPTION
    WHEN OTHERS THEN
      xv_process_message := Sqlerrm||'. Get gl date in acct_inclu_taxes procedure.';
      RAISE exception_error;
  END;

  -- Insert inclusive taxes into GL Interface table
  ln_total_inclu_tax_amt := 0;

  FOR inclu_tax_csr IN inclu_tax
  LOOP
    ln_tax_account_id := get_tax_account_id
                           ( pn_tax_id   => inclu_tax_csr.tax_id
                           , pv_tax_type => inclu_tax_csr.tax_type
                           , pn_org_id   => ln_org_id
                           );
    INSERT INTO gl_interface
      ( status
      , set_of_books_id
      , user_je_source_name
      , user_je_category_name
      , accounting_date
      , currency_code
      , date_created
      , created_by
      , actual_flag
      , entered_cr
      , entered_dr
      , transaction_date
      , code_combination_id
      , currency_conversion_date
      , user_currency_conversion_type
      , currency_conversion_rate
      , reference1
      , reference10
      , reference22
      , reference23
      , reference24
      , reference25
      , reference26
      , reference27
      )
    VALUES
      ( 'NEW'
      , ln_set_of_books_id                      -- the set of books id
      , 'Receivables India'                     -- je source name 'Receivables India'
      , 'Register India'                        -- je category name 'Register India'
      , ld_gl_date                              -- accounting date (GL date of the invoice)
      , lv_currency_code                        -- currency code
      , sysdate                                 -- standard who column
      , TO_NUMBER(fnd_profile.value('USER_ID')) -- standard who column
      , 'A'                                     -- actual flag, hard coded value
      , inclu_tax_csr.tax_amount                -- credit amt, inclusive tax amount
      , null                                    -- debit amt
      , sysdate                                 -- invoice date
      , ln_tax_account_id                       -- code combination
      , ld_cur_conversion_date
      , lv_cur_conversion_type
      , ln_cur_conversion_rate
      , lv_inv_org_code                        -- inventory organization code
      , 'India Localization Entry for accounting inclusive taxes for invoice'||lv_inv_num
      , 'India Localization Entry'             -- hard code string
      , 'acct_inclu_taxes'                     -- procedure name that makes the insert into gl_interface hard code string
      , 'RA_CUSTOMER_TRX_ALL'                  -- hard code string
      , 'CUSTOMER_TRX_ID'                      -- hard code string
      , pn_customer_trx_id                     -- value of customer_trx_id
      , ln_inv_org_id                          -- organization id of the inventory organization id
      );

    ln_total_inclu_tax_amt := ln_total_inclu_tax_amt + inclu_tax_csr.tax_amount;
    FND_FILE.PUT_LINE ( FND_FILE.LOG
                      , 'Insert tax info: '
                      || 'tax_account_id = ' || ln_tax_account_id
                      || '    tax_amount = '|| inclu_tax_csr.tax_amount
                      );
  END LOOP;  -- inclu_tax cusor

  -- Insert revenue amount into GL Interface table
  INSERT INTO gl_interface
    ( status
    , set_of_books_id
    , user_je_source_name
    , user_je_category_name
    , accounting_date
    , currency_code
    , date_created
    , created_by
    , actual_flag
    , entered_cr
    , entered_dr
    , transaction_date
    , code_combination_id
    , currency_conversion_date
    , user_currency_conversion_type
    , currency_conversion_rate
    , reference1
    , reference10
    , reference22
    , reference23
    , reference24
    , reference25
    , reference26
    , reference27
    )
  VALUES
    ( 'NEW'
    , ln_set_of_books_id                      -- the set of books id
    , 'Receivables India'                     -- je source name 'Receivables India'
    , 'Register India'                        -- je category name 'Register India'
    , ld_gl_date                              -- accounting date (GL date of the invoice)
    , lv_currency_code                        -- currency code
    , sysdate                                 -- standard who column
    , TO_NUMBER(fnd_profile.value('USER_ID')) -- standard who column
    , 'A'                                     -- actual flag, hard coded value
    , null                                    -- credit amt, inclusive tax amount
    , ln_total_inclu_tax_amt                  -- debit amt
    , sysdate                                 -- invoice date
    , ln_rec_account_id                       -- code combination
    , ld_cur_conversion_date
    , lv_cur_conversion_type
    , ln_cur_conversion_rate
    , lv_inv_org_code                        -- inventory organization code
    , 'India Localization Entry for accounting inclusive taxes for invoice'||lv_inv_num
    , 'India Localization Entry'             -- hard code string
    , 'acct_inclu_taxes'                     -- procedure name that makes the insert into gl_interface hard code string
    , 'RA_CUSTOMER_TRX_ALL'                  -- hard code string
    , 'CUSTOMER_TRX_ID'                      -- hard code string
    , pn_customer_trx_id                     -- value of customer_trx_id
    , ln_inv_org_id                          -- organization id of the inventory organization id
    );

    FND_FILE.PUT_LINE ( FND_FILE.LOG
                      , 'Insert debit info: '
                      || 'account_id = ' || ln_rec_account_id
                      || '    amount = '|| ln_total_inclu_tax_amt
                  );

  xv_process_flag := 'SS';
  xv_process_message := 'Inclusive taxes have successed into GL Interface';

  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                  , 'Exit procedure'
                  );
  END IF; -- (ln_proc_level>=ln_dbg_level)

EXCEPTION
  WHEN exception_error THEN
    xv_process_flag    := 'EE';
  WHEN OTHERS THEN
    xv_process_flag    := 'UE';
    xv_process_message := Sqlerrm||'. Exception error in acct_inclu_taxes procedure';

    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)

END acct_inclu_taxes;
-- Added by Jia Li on tax inclusive computation on 2007/11/30, End

--==========================================================================
--  PROCEDURE NAME:
--    Display_Vat_Invoice_No                        Public
--
--  DESCRIPTION:
--    This procedure is written that update the ra_customer_trx_all ct_reference column
--  to display the VAT/Excise Number in AR
--
--  ER NAME/BUG#
--    VAT/Excise Number shown in AR transaction workbench'
--    Bug 9303168
--
--  PARAMETERS:
--      In:  pn_customer_trx_id            Indicates the customer trx id
--           pv_excise_invoice_no          Indicates the excise invoice number
--           pv_vat_invoice_no             Indicates vat invoice number
--
--
--  DESIGN REFERENCES:
--       TD named "VAT Invoice Number on AR Invoice Technical Design.doc" has been
--     referenced in the section 6.1
--
--  CALL FROM
--       JAI_AR_MATCH_TAX_PKG.process_batch
--       JAI_AR_TRX.update_excise_invoice_no
--       JAI_AR_TRX.update_reference
--
--  CHANGE HISTORY:
--  19-Jan-2010                Created by Bo Li
--  09-Mar-2010                Fix the bug#9453040 for the recording the bug which
--                             length of reference over 150  is not truncated
--                             automatically
--  05-May-2010								 Add conditon for the IF clauses
--==========================================================================
PROCEDURE display_vat_invoice_no
( pn_customer_trx_id   IN NUMBER
, pv_excise_invoice_no IN VARCHAR2
, pv_vat_invoice_no    IN VARCHAR2
)
IS

    cv_seperator CONSTANT VARCHAR2(30) := ';';
    lv_reference ra_customer_trx_all.ct_reference%TYPE;
    lv_reference_check ra_customer_trx_all.ct_reference%TYPE;
    lv_procedure_name       VARCHAR2(40):='display_vat_invoice_no';
    ln_dbg_level            NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    ln_proc_level           NUMBER:=FND_LOG.LEVEL_PROCEDURE;

    -- check the invoice numbers are in the referece field or not
    CURSOR check_reference IS
      SELECT ct_reference
      FROM ra_customer_trx_all
      WHERE customer_trx_id = pn_customer_trx_id;

  BEGIN
     --logging for debug
    IF (ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING( ln_proc_level
                    , lv_procedure_name || '.begin'
                    , 'Enter procedure'
                   );
    END IF; --l_proc_level>=l_dbg_level


     -- get the exist value of reference field
      OPEN  check_reference;
      FETCH check_reference
      INTO  lv_reference_check;
      CLOSE check_reference;

      fnd_file.put_line(FND_FILE.LOG,
                          'The exist excise reference is: '||lv_reference_check);

     lv_reference := NULL;

     -- When the vat invoice number is not null
     IF pv_vat_invoice_no IS NOT NULL
     THEN
       --when the vat invoice number and excise invoice no
       --are the same
       IF pv_vat_invoice_no = pv_excise_invoice_no
       THEN
         --When the vat and excise invoice has not been imported
         IF instr(nvl(lv_reference_check,'$$'),pv_vat_invoice_no) = 0
            OR (instr(nvl(lv_reference_check,'$$'),cv_seperator)=0)--Added by Bo Li on 2010-05-05
         THEN
           lv_reference:=substr(lv_reference_check||cv_seperator||pv_vat_invoice_no,1,150);
         END IF;--instr(nvl(lv_reference_check,'$$'),pv_vat_invoice_no)

       ELSE -- When the vat and excise invoice number are different
         --When neither the vat and excise number is displayed
         IF ( instr(nvl(lv_reference_check,'$$'),pv_vat_invoice_no) = 0
         AND instr(nvl(lv_reference_check,'$$'),nvl(pv_excise_invoice_no,'##')) = 0 )
         OR (instr(nvl(lv_reference_check,'$$'),cv_seperator)=0)--Added by Bo Li on 2010-05-05
         THEN
          lv_reference:=substr(lv_reference_check||cv_seperator||pv_excise_invoice_no||
                        cv_seperator||pv_vat_invoice_no,1,150);
          -- when the vat is displayed and excise invoice number is not displayed
          --when the excise is displayed and vat invoice number is not displayed
         ELSIF ((instr(nvl(lv_reference_check,'$$'),pv_vat_invoice_no) > 0
               OR instr(nvl(lv_reference_check,'$$'),nvl(pv_excise_invoice_no,'##')) > 0))
               AND (instr(nvl(lv_reference_check,'$$'),pv_excise_invoice_no||cv_seperator||pv_vat_invoice_no)=0)
               AND (instr(nvl(lv_reference_check,'$$'),cv_seperator)>0) --Added by Bo Li on 2010-05-05
         THEN
          lv_reference:=substr(substr(lv_reference_check,1,instr(lv_reference_check,cv_seperator,1,1))||
                        pv_excise_invoice_no||cv_seperator||pv_vat_invoice_no,1,150);

         END IF; --((instr(nvl(lv_reference_check,'$$'),pv_vat_invoice_no) > 0
       END IF; --pv_vat_invoice_no = pv_excise_invoice_no
       -- When vat invoice number is null
     ELSE
       --when the excise invoice is not null
       IF  pv_excise_invoice_no IS NOT NULL
       THEN
         --When  excise invoice has not been imported
         IF instr(nvl(lv_reference_check,'$$'),pv_excise_invoice_no) = 0
         THEN
           lv_reference:=substr(lv_reference_check||cv_seperator||pv_excise_invoice_no,1,150);
         END IF;
       END IF; -- pv_excise_invoice_no IS NOT NULL
     END IF; --pv_vat_invoice_no IS NOT NULL


     IF lv_reference IS NOT NULL
     THEN
     -- update the reference column in the ra_customer_trx_all
      UPDATE ra_customer_trx_all
         SET ct_reference = lv_reference
       WHERE customer_trx_id = pn_customer_trx_id;
     END IF; --lv_reference IS NOT NULL

    --logging for debug
    /*IF (ln_proc_level >= ln_dbg_level)
    THEN
     FND_LOG.STRING( ln_proc_level
                    , lv_procedure_name || '.end'
                    , 'Exit procedure');
    END IF;*/
  END display_vat_invoice_no;

END jai_ar_match_tax_pkg;

/
