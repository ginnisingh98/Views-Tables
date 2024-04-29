--------------------------------------------------------
--  DDL for Package Body JAI_RCV_RT_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_RCV_RT_TRIGGER_PKG" AS
/* $Header: jai_rcv_rt_t.plb 120.8.12010000.6 2010/04/15 10:59:11 boboli ship $ */

/*
  REM +======================================================================+
  REM NAME          ARI_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_RCV_RT_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_RCV_RT_ARI_T2
  REM
  REM +======================================================================+
*/
  PROCEDURE ARI_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
   v_tax_count         number  := 0;
  v_orgn_setup_count    number  := 0;
  v_currency_code       gl_sets_of_books.currency_code%type;
  v_gl_set_of_bks_id    number;


   cursor c_get_tax_count(p_shipment_header_id number, p_shipment_line_id number) is
   select count(1)
   from   JAI_RCV_LINE_TAXES
   where  shipment_header_id  = p_shipment_header_id
   and  shipment_line_id  = p_shipment_line_id;


  cursor chk_org_setup_is_present (
                  p_organization_id  number ,
                  p_location_id      number
                )
  is
  select
    count(1)
  from
    JAI_CMN_INVENTORY_ORGS
  where
    organization_id = p_organization_id AND
    location_id     = p_location_id;

  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Removed cursors c_fetch_sob_id and c_fetch_currency_code
   * and implemented caching logic to get the values.
   */
    cursor c_fetch_shipment_line_info(p_shipment_line_id number) is
    select destination_type_code from
    rcv_shipment_lines
    where shipment_line_id = p_shipment_line_id;

    v_destination_type_code rcv_shipment_lines.destination_type_code%type; --3655330

  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Defined variable for implementing caching logic.
   */
  l_func_curr_det     jai_plsql_cache_pkg.func_curr_details;

  /* following added by CSahoo BUG#5592114 */
  lv_scenario varchar2(50);
  ln_location_id number;
  cursor c_get_location_id(p_organization_id number, cp_subinventory varchar2) is
  select location_id
  from   JAI_INV_SUBINV_DTLS
  where  organization_id  = p_organization_id
and sub_inventory_name = cp_subinventory;


  BEGIN
    pv_return_code := jai_constants.successful ;
   /*------------------------------------------------------------------------------------------
 FILENAME: ja_in_localization_setup_checks_trg.sql

 CHANGE HISTORY:
S.No      Date          Author and Details

1.     02/01/2004      Nagaraj.s for Bug#3496327. Version: 619.1
             This Trigger is created to validate whether Localization setups exist for
             the Organization/Location combination.

2.     07/06/2004      Nagaraj.s for Bug#3655330. Version : 619.2
                       In case of change in destination type for standard routing, the location
                       would still be null as a result of which the setups are checked and the error
                       is thrown up. This scenario of change in destination type is not supported
                       by Localization yet and hence a message in such a scenario is :
                      Localization does not support change in destination type

3. 08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                 DB Entity Names, as required for CASE COMPLAINCE. Version 116.1

4. 13-Jun-2005   File Version: 116.2
                 Ramananda for bug#4428980. Removal of SQL LITERALs is done

5. 06-Jul-2005   Ramananda for bug#4477004. File Version: 116.3
                 GL Sources and GL Categories got changed. Refer bug for the details

6. 20-Feb-2007   CSahoo for Bug#5592114. File Version  120.3
                 Forward Porting of 11i BUG#5592023
                 Modified the code not to error during RECEIVE trx of Standard Routing changed to Direct delivery
                 + enhanced this trigger to execute for direct delivery case also

14-may-07   kunkumar made changes for Budget and ST by IO and Build issues resolved

8.  10-oct-2007  rchandan for bug#6488175, File version 120.8
                 Issue : R12RUP04.I/ORG.QA.ST1: RTP GOES INTO ERROR IF LOCATIONIS NOT GIVENFOR INTRANSIT
                   Fix : the check for Il setup should be made only for DELIVER transaction. This was happening only for
                         PO source_document_code. made a change to allow this to happen for INVENTORY source_document_code
                         also.

9.  05-Jun-2009  CSahoo for bug#8551593, File Version 120.1.12000000.5
                 INTERFACE TRIP STOP ERROR : TRANSACTION PROCESSOR ERROR - RECEIVING TRANSACTION
                 Fix: added an elsif block where it would check if the destination type code is 'EXPENSE'. If yes, then no
                      check is required for org location set up.
--------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------

--Dependency section post IN60105d2



Dependencies For Future Bugs
  -------------------------------------


-------------------------------------------------------------------------------------------------
*/

   /* Bug 5243532. Added by Lakshmi Gopalsami
    * Removed cursors c_fetch_sob_id and c_fetch_currency_code and
    * implemented caching logic for getting SOB.
    */
   l_func_curr_det       := jai_plsql_cache_pkg.return_sob_curr
                              (p_org_id  => pr_new.organization_id);
   v_gl_set_of_bks_id    := l_func_curr_det.ledger_id;
   v_currency_code       := l_func_curr_det.currency_code;

   open c_get_tax_count
    (
      p_shipment_header_id => pr_new.shipment_header_id,
      p_shipment_line_id   => pr_new.shipment_line_id
    );
    fetch c_get_tax_count into v_tax_count;
    close c_get_tax_count;

  if nvl(v_tax_count,0) =  0 then
    return;
  end if;

  /* Start, added by CSahoo BUG#5592114 */
  OPEN   c_fetch_shipment_line_info(pr_new.shipment_line_id);
  FETCH  c_fetch_shipment_line_info INTO v_destination_type_code;
  CLOSE  c_fetch_shipment_line_info;

  IF  v_destination_type_code='INVENTORY'
    AND pr_new.source_document_code IN ('PO','INVENTORY')/*rchandan for bug#6488175*/
  THEN
    IF pr_new.transaction_type = 'RECEIVE' THEN
      RETURN;
    ELSIF pr_new.transaction_type = 'DELIVER' THEN
      lv_scenario := 'STANDARD_TO_DIRECT';   /* go ahead to validate the IL Setup */
    END IF;
  /*added this elsif block for bug#8551593*/
  ELSIF v_destination_type_code= 'EXPENSE'
  THEN
    RETURN;
  ELSIF pr_new.transaction_type = 'DELIVER' THEN
    RETURN; -- no need of this check for deliver case except for above
  END IF;
  /* End, added by CSahoo BUG#5592114 */

  open  chk_org_setup_is_present
      (
        p_organization_id =>  pr_new.organization_id ,
        p_location_id     =>  pr_new.location_id
      );
  fetch chk_org_setup_is_present into v_orgn_setup_count;
  close chk_org_setup_is_present;

  if nvl(v_orgn_setup_count,0) = 0 then
    /* Start, added by CSahoo Bug#5592114 */
    if lv_scenario = 'STANDARD_TO_DIRECT' then
      open c_get_location_id(pr_new.organization_id, pr_new.subinventory);
      fetch c_get_location_id into ln_location_id;
      close c_get_location_id;

      if ln_location_id is not null then

        open  chk_org_setup_is_present
            (
              p_organization_id =>  pr_new.organization_id ,
              p_location_id     =>  ln_location_id
            );
        fetch chk_org_setup_is_present into v_orgn_setup_count;
        close chk_org_setup_is_present;

        if nvl(v_orgn_setup_count,0) > 0 then
          return; /* no problem with setup. so, do not error */
        end if;

      end if;

    end if;
    /* End, added by CSahoo Bug#5592114 */

      open   c_fetch_shipment_line_info(pr_new.shipment_line_id);
      fetch  c_fetch_shipment_line_info into v_destination_type_code;
      close  c_fetch_shipment_line_info;

      --3655330
      if pr_new.source_document_code in ('PO') and v_destination_type_code='INVENTORY' then
      fnd_file.put_line(fnd_file.log, 'Cannot process records.The change of destination type for standard/inspection routing is not supported by Localization');
    app_exception.raise_exception( exception_type  => 'APP' ,
                                   exception_code  => -20120 ,
                                       exception_text  => 'Localization does not support change in destination type'
                                     );
      end if;

    fnd_file.put_line(fnd_file.log, 'Cannot process records.The organization Location combination does not have a valid localization setup');
    app_exception.raise_exception( exception_type  => 'APP' ,
                                 exception_code  => -20120 ,
                                     exception_text  => 'No India Localization setup for this Location '
                                   );
  end if;

  END ARI_T1 ;

  /*
REM +======================================================================+
  REM NAME          BRI_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_RCV_RT_BRIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_RCV_RT_BRI_T1
  REM
  REM +======================================================================+
*/
  PROCEDURE BRI_T1 ( pr_old t_rec%type , pr_new in out t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
   v_shipment_header_id    rcv_shipment_headers.shipment_header_id % type;
  /* Commented rallamse bug#4479131 PADDR Elimination
  v_rowid                 JAI_CMN_LOCATORS_T.row_id%type;
  */
  -- CSahoo for Bug 5344225
   lv_request_id           NUMBER ;
   lv_group_id             NUMBER ;
   lv_profile_val          VARCHAR2(100);
   --lv_debug                VARCHAR2(1) := 'Y';
   --ln_file_hdl             UTL_FILE.FILE_TYPE;

  CURSOR c_rcv_hdr IS
  SELECT rowid, receipt_source_code, receipt_num, shipment_num, shipped_date, organization_id,
    vendor_id, vendor_site_id, customer_id, customer_site_id
  FROM rcv_shipment_headers
  WHERE shipment_header_id = pr_new.shipment_header_id;

  /* Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. */
  r_rcv_hdr c_rcv_hdr%ROWTYPE;
  v_chk     number(5);
  CURSOR c_jai_rcv_hdr_chk(cp_shipment_header_id number) is
  select 1
  from jai_rcv_headers
  where shipment_header_id = cp_shipment_header_id;

  v_error_mesg    VARCHAR2(200); -- added by Aparajita for bug#2514979 on 18/08/2002.
  v_receipt_source_code       rcv_shipment_headers.receipt_source_code%type; --ashish for bug # 2613817

  -- Vijay Shankar for Enhancement Bug# 3496408
  -- lv_opm_flag     MTL_PARAMETERS_VIEW.process_enabled_flag%TYPE;
  lv_process_mode VARCHAR2(1);
  lv_request_desc   VARCHAR2(200);
  lv_req_id   NUMBER;
  lv_result   BOOLEAN;

  CURSOR c_receipt_line(cp_shipment_line_id IN NUMBER) IS
    SELECT tax_modified_flag
    FROM JAI_RCV_LINES
    WHERE shipment_line_id = cp_shipment_line_id;
  lv_tax_modified_flag    JAI_RCV_LINES.tax_modified_flag%TYPE;

  v_temp1           VARCHAR2(30);
  v_chk_form        VARCHAR2(30);     -- Vijay Shankar for Bug#3940588. RECEIPTS DEPLUG
  lv_called_from    VARCHAR2(30);

  lv_allow_tax_change_hook    VARCHAR2(1);

  /* Vijay Shankar for Bug#4250171 */
  lv_comments           VARCHAR2(30);
  lv_submit_jainrvctp   VARCHAR2(1);  --File.Sql.35 Cbabu  := 'N';

  --Cursor Added by Sanjikum for Bug #4105721
  CURSOR c_mtl_trx(cp_organization_id IN NUMBER) IS
    SELECT NVL(process_enabled_flag, jai_constants.no) process_enabled_flag
    FROM   mtl_parameters_view
    WHERE  Organization_id =  cp_organization_id;

    r_mtl_trx c_mtl_trx%ROWTYPE;

    /* start bgowrava for forward porting Bug#5636560 */
      lv_parent_trx_type      JAI_RCV_TRANSACTIONS.transaction_type%type;
      CURSOR c_parent_trx_type is
        SELECT transaction_type
        from JAI_RCV_TRANSACTIONS
        where transaction_id = pr_new.parent_transaction_id;
  /* End bgowrava for Bug#5636560 */

  --Function Added by Sanjikum for Bug #4105721
  FUNCTION get_deliver_unit_price(p_shipment_line_id  IN  NUMBER)
    RETURN NUMBER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    CURSOR c_deliver_unit_price(cp_transaction_type rcv_transactions.transaction_type%type)  IS
    SELECT  po_unit_price
    FROM    rcv_transactions
    WHERE   shipment_line_id = p_shipment_line_id
    AND     transaction_type = cp_transaction_type ; /* 'DELIVER'; Ramananda for removal of SQL LITERALs */

    r_deliver_unit_price c_deliver_unit_price%ROWTYPE;
  BEGIN
    pv_return_code := jai_constants.successful ;
    OPEN c_deliver_unit_price('DELIVER');
    FETCH c_deliver_unit_price INTO r_deliver_unit_price;
    CLOSE c_deliver_unit_price;

    RETURN r_deliver_unit_price.po_unit_price;
  END get_deliver_unit_price;
  BEGIN
    pv_return_code := jai_constants.successful ;
    /*------------------------------------------------------------------------------------------
Change history for ja_in_receipt_tax_insert_trg.sql
S.No      Date          Author and Details
-------------------------------------------------------------------------------------------------
1.      31-aug-01       Subbu Modified code for DFF issue.

2.        07-07-02      Nagaraj.s for Bug2449826.
                        Incorporated an IF condition
                        wherein if the comments is OPM Receipt
                        then the trigger should not be processed
                        further.

3.        18/08/2002    Aparajita, revamp of process at receipt. bug #2514979.
                        Added the call  to procedure  Ja_In_Set_Rcv_Process_Flags
                        to set the process flag for various processes.

4.        23/08/2002    Nagaraj.s for Bug2525910
                        Incorporated an parameter in the call to ja_in_receipts_p.sql
                        pr_new.ROUTING_HEADER_ID
5.       24/10/2002     ashish for bug #  2613817
                        changes done for express receipt functionality.
                        this functionality enables a user to perform the express receipt.
                        this functionality was lost and is reintroduced.


6.       04/03/2003     Nagaraj.s for Bug#2692052 Version:615.4
                        High Dependency with this Patch
                        Added 3 arguments for the call to JA_NI_SET_RCV_PROCESS_FLAGS.
                        The Arguments are :
                        pr_new.ATTRIBUTE3
                        NVL(pr_new.ROUTING_HEADER_ID,0)
                        'TRIGGER'

7.       2003/04/01     Sriram - Bug # 2881674
                        Attribute5 was not getting copied for 'India RMA Receipt' attribute category. This has
                        been fixed in this bug.

8.     08/07/2003       Nagaraj.s for Bug#3036825. Version : 616.1
                        A new parameter attribute_category is passed to
                        ja_in_set_rcv_process_flags through this procedure.

10.    15/10/2003       Nagaraj.s for Bug#3162928. Version : 616.2
                        One more Condition is added in the Trigger to allow
                        "To handle Deliver RTR RTV" to fire in case of an
                        RMA Receipt/standard Delivery.

11.    08/01/2004       Nagaraj.s for Bug#3354415. Version : 618.1
                        The call to ja_in_set_rcv_process_flags is now having one more parameter
                        p_attribute5. Hence this would result into an Dependency. This is being
                        passed to the procedure

12.   13/03/2004        Nagaraj.s for Bug#3456636. Version: 619.1
                        The call to ja_in_set_rcv_process_flags is made only in case of Transaction
                        Type=RECEIVE so that the program flow may not enter ja_in_set_rcv_process_flags
                        in case of other transactions.
                        This Patch has an alter statement and is hence a high dependency.

13.   16/06/2004        SSUMAITH - bug# 3683666 File version 115.1

                        if the attribute_category is a null value and attribute2 is a not null value
                        it is being set to NULL and passed on to the jai_rcv_tax_pkg.default_taxes_onto_line procedure.

                        If the value is not one of the India Localization standard ones, then we entering the
                        values in a JAI_CMN_ERRORS_T and are returing the control.

                        The 'INR' check which was commented is now un-commented so that code returns in cases where
                        in Non-INR set of books , no processing occurs..

                        Dependency due to this bug - None

14.   16/07/2004        Vijay Shankar for Enhancement Bug# 3496408, Version: 115.2
                        trigger enabled to Support CORRECT transactions for Localization Processing
                        Also DELIVER and RTR transactions are delinked from Old Code and linked to New code with this enhancement.
                        New Concurrent program JAINRVCTP is called incase of DELIVER, RTR and CORRECT transactions
                        HIGH DEPENDENCY

15.   20/10/2004        Vijay Shankar for Bug#3927371 (3836490), Version: 115.3
                        Concurrent request for JAINRVCTP should not be fired for Direct Delivery case, as it is handled in
                        ja_in_rel_close_loc Also the issue of RTV passing Localization Accounting for UNORDERED Receipt
                        even if it is not matched is resolved by returning back the execution if PO_HEADER_ID
                        link is not found for transaction

16.   03/11/2004        Vijay Shankar for Bug#3959765, Version: 115.4
                        Modified the code added for Bug#3683666, so that the trigger fires even if NEW.attribute_category has customer DFF values.
       commented the code that is checking for localization DFFs and doesnt allow customer DFFs for localization processing.

17.   30/11/2005        Aparajita for bug#4036241. Version#115.5

                        Introduced the call to centralized packaged procedure,
                        jai_cmn_utils_pkg.check_jai_exists to check if localization has been installed.

18    03/01/2005   Vijay Shankar for Bug# 3940588, Version:115.6
                    Following are the changes done as part of RECEIPTS DEPLUG
                     - Submits a request for "India - Receiving Transaction Processor" for DELIVER, RTR, RTV, Any CORRECTs, RECEIVE
                     Transations that are not Created without Navigating from Localization Receipts Screen
                     - Makes a call to jai_rcv_tax_pkg.default_taxes_onto_line incase of 'RECEIVE', 'UNORDERED', 'MATCH', 'RETURN TO VENDOR' transactions only
                     - a new parameter v_chk_form is added in call to jai_rcv_tax_pkg.default_taxes_onto_line based on which request for JAINRVCTP is submitted
                     incase of RECEIVE transaction
                     - Commented the call to ja_in_set_rvc_process_flags as it is redundant with RECEIPTS DEPLUG from Old Code
                     - Updates flags of JAI_RCV_LINES with X value. updates transaction_id to MATCH transaction_id in case of
                     UNORDERED transaction

19    03/02/2005   Vijay Shankar for Bug# 4159557, Version:115.7
                    Modified the code, so that users will be able to modify taxes of Receipt by Querying it in Localization Screen with the
                    help of localization Receipts Hook for Open Interface/WMS Receipts.
                    v_chk_form chk is modified to look only for ASBN Receipts and submit request for "India - Receiving Transaction Processor"

                    * This is a dependancy for Future Versions of the trigger *

20    22/02/2005   Vijay Shankar for Bug# 4199929, Version:115.8
                    Revoked the call to jai_cmn_hook_pkg as it is replaced with Orgn. Addl. info setup usage in jai_rcv_tax_pkg.default_taxes_onto_line call

                    * This is a dependancy for Future Versions of the trigger *

21    19/03/2005   Vijay Shankar for Bug#4250236(4245089). FileVersion: 115.9
                    modified an if condition to assign a proper value to lv_called_from variable. if a wrong value is assigned, then
                    India RTP may not process the transaction

22    25/03/2005   Vijay Shankar for Bug#4250171. Version:115.11
                Code is modified to populate JAI_RCV_TRANSACTIONS even if the transaction is created through an
                OPM Receipt/Return. This modification is done, so that VAT Processing of OPM Receipt happens through Discrete code

23   07/04/2005  Harshita for  Bug #4285064    Version : 115.12

                 When a user creates a new receipt against a purchase order, he needs to enter the following information
                 through a DFF : invoice no, invoice_date, Claim Cenvat On Receipt etc.
                 This DFF is provided at two places, header and line.
                 Information from the header DFF is captured into the rcv_shipment_headers table.
                 Information from the lines DFF is captured into the rcv_transactions table.
                 This information is retrieved into our base tables JAI_RCV_TRANSACTIONS and JAI_RCV_LINES.
                 At this time, a facility has been provided for the user to default the information
                 given at the header level DFF to all the lines only if these columns are null at the
                 line level. Else the information in the line level DFF is sustained.
                 For this NVL conditions have been added where this information gets defaulted.

24   15/04/2005  Harshita for  Bug #4285064    Version : 115.13
                 Debug messages that have been added for testing were not removed in the previous chech in.
                 Removed the debug messages.

25   15/04/2005  Sanjikum for Bug #4105721, File Version 116.0(115.14)

                 Problem
                 -------
                 In case of RTR and RTV, PO_UNIT_PRICE is not updated with the proper costing effect.
                 Previously base was updating the PO_UNIT_PRICE, same as the PO_UNIT_PRICE of the
                 Deliver Transaction. Now base has changed the logic, and in 11.5.10, it is not
                 Populated correctly

                 Fix
                 ---
                 In case of RTR and RTV, PO_UNIT_PRICE is updated same as the PO_UNIT_PRICE of the Deliver Transaction.
                 Following changes are done for the same -

                 1) Created a new inline function get_deliver_unit_price
                 2) Added a new IF Condition, before the <<end_of_trigger>> LABEL
                    IF pr_new.transaction_type IN ('RETURN TO RECEIVING', 'RETURN TO VENDOR') THEN
                      pr_new.po_unit_price := get_deliver_unit_price(pr_new.shipment_line_id);
                    END IF;

26 10/05/2005   Vijay Shankar for Bug#4346453. Version: 116.1
                 Code is modified due to the Impact of Receiving Transactions DFF Elimination

              * High Dependancy for future Versions of this object *


27  08-Jun-2005  This Object is Modified to refer to New DB Entity names in place of Old DB Entity Names,
                 as required for CASE COMPLAINCE. Version 116.1

28. 13-Jun-2005  Ramananda for bug#4428980. File Version: 116.2
                 Removal of SQL LITERALs is done

29   06-Jul-2005 rallamse for bug# PADDR Elimination
                 Commented reference to JAI_CMN_LOCATORS_T table

30.  01-Aug-2005 Ramananda for bug#4565478 (4519697), File Version 120.3
                 Changed the If condition for setting the value of lv_called_from

                 Dependency due to this Bug
                 --------------------------
                 jai_rcv_trx_prc.plb (120.3)
                 jai_rcv_tax.plb     (120.3)

31. 13-Feb-2007  bgowrava for forward porting Bug#5636560 (11i bug#5405889). File Version 120.2
                 Added an if condition to return from the trigger if parent transaction type of CORRECT is
                  NOT IN (RECEIVE, MATCH, DELIVER, RETURN TO RECEIVING , RETURN TO VENDOR).
                 The reson is, we support once these transaction types

                 added a cursor c_parent_trx_type to fetch transaction_type of parent_transaction_id from ja_in_rcv_transactions

                 Dependancy due to this bug: None

 32. 20-Feb-2007 CSahoo, BUG#5344225, File Version 120.4
                 Forward Porting of 11i Bug 5343848
                 Issue : India - Receiving Transaction Processor Concurrent Program was called
                   for each transaction on a shipment line.
                 Fix:
                 Following approach was taken in case RTP was fired in the IMMEDIATE MODE.
                 -------------------------------------------------------------------------
                 Added code to check if variable gv_shipment_header_id is null.
                 if yes,
                  a) Get the Request Id of the base RVCTP
                  b) Call the India - RTP concurrent passing the Shipment Header Id and the Request Id of the base RVCTP.
                  c) Set the variable gv_shipment_header_id to the Shipment header Id called.
                 else
                   null ;

                 Following approach was taken in case RTP was fired in the ONLINE MODE.
                 -------------------------------------------------------------------------
                 Added code to check if variable gv_group_id is null.
                 if yes,
                   a) Get the group_id of the base table rcv_transactions
                   b) Call the India - RTP concurrent passing the Shipment Header Id and the group id of rcv_transactions.
                   c) Set the variable gv_group_id to the group_id passed.
                 else
                   null ;

                 Dependency Due to this Bug : Yes.

33.  25-may-2207 CSahoo, bug#6071528, file version 120.6
                 added the following line fnd_profile.get('RCV_TP_MODE',lv_profile_val);

34.  03-JUN-2007 SACSETHI BUG 6078460   File version

                 Problem- IN Purchasing to Return to vendor cycle , vat and cenvat was not reversing in accounting .

     Solution - Argument was not required when we going to call concurrent program JAINRVCTP

     Reasong - For bug 5344225 - we made the approach to execute only concurrent program JAINRVCTP for only one time
               instead of calling again and again .....

-------------------------------------------------------------------------------------------------
Dependencies For Future Bugs
-------------------------------------------------------------------------------------------------
IN60104d  + 3036825
IN60105d2 + 3354415 + 3456636 + 3496408 + 3927371 + 3959765
IN60105d2 + 3354415 + 3456636 + 3496408 + 3927371 + 3959765 + 4033992 + 4036241

IN60106   + 3940588 + 4199929 + 4346453

Sl No. Bug        Dependent on
                  Bug/Patch set    Details
-------------------------------------------------------------------------------------------------
1      4036241    4033992          Call to  jai_cmn_utils_pkg.check_jai_exists, whcih was created thru bug
                                   4033992.
                                   ja_in_util_pkg_s.sql 115.0
                                   ja_in_util_pkg_b.sql 115.0
------------------------------------------------------------------------------------------------- */

--File.Sql.35 Cbabu
lv_submit_jainrvctp  := 'N';

--if jai_cmn_utils_pkg.check_jai_exists (p_calling_object     => 'JA_IN_RECEIPT_TAX_INSERT_TRG',
--                               p_inventory_orgn_id  =>  pr_new.organization_id)

--  = FALSE
--then
  /* India Localization funtionality is not required */
--  return;
--end if;


/*start bgowrava for forward porting Bug#5636560 */
if pr_new.transaction_type = 'CORRECT' then

  open c_parent_trx_type;
  fetch c_parent_trx_type into lv_parent_trx_type;
  close c_parent_trx_type;

  /* IL support only the corrections of the following transaction types. Hence if the parent of the
  correction is not within these trx types, we should return back from this trigger */
  if nvl(lv_parent_trx_type, 'XX') not in
      ('RECEIVE', 'MATCH', 'DELIVER', 'RETURN TO RECEIVING', 'RETURN TO VENDOR')
  then
    return;
  end if;

end if;
/*end bgowrava for Bug#5636560 */


IF  pr_new.comments in ('OPM RECEIPT','OPM Receipt Correction') THEN
  lv_comments := pr_new.comments;
ELSE
  lv_comments := NULL;
END IF;

/* Vijay Shankar for Bug#4250171 */
/* following insert is moved from bottom to here to take care of OPM Functionality also */
IF pr_new.transaction_type in ( 'RECEIVE', 'DELIVER', 'RETURN TO RECEIVING',
      'RETURN TO VENDOR', 'CORRECT', 'MATCH')
THEN
  jai_rcv_transactions_pkg.insert_row(
    P_SHIPMENT_HEADER_ID       => pr_new.shipment_header_id,
    P_SHIPMENT_LINE_ID         => pr_new.shipment_line_id,
    P_TRANSACTION_ID           => pr_new.transaction_id,
    P_TRANSACTION_DATE         => pr_new.transaction_date,
    P_TRANSACTION_TYPE         => pr_new.transaction_type,
    P_QUANTITY                 => pr_new.quantity,
    P_UOM_CODE                 => nvl(pr_new.uom_code, jai_general_pkg.get_uom_code(pr_new.unit_of_measure)),
    P_PARENT_TRANSACTION_ID    => pr_new.parent_transaction_id,
    P_PARENT_TRANSACTION_TYPE  => NULL,
    P_destination_type_code    => pr_new.destination_type_code,
    P_RECEIPT_NUM              => NULL,
    P_ORGANIZATION_ID          => pr_new.organization_id,
    P_LOCATION_ID              => NULL,
    P_INVENTORY_ITEM_ID        => NULL,
    p_excise_invoice_no        => null,
    p_excise_invoice_date      => null,
    p_tax_amount               => null,
    P_assessable_value         => NULL,
    P_currency_conversion_rate => pr_new.currency_conversion_rate,
    P_ITEM_CLASS               => NULL,
    P_ITEM_cenvatABLE          => NULL,
    P_ITEM_EXCISABLE           => NULL,
    P_ITEM_TRADING_FLAG        => NULL,
    P_INV_ITEM_FLAG            => NULL,
    P_INV_ASSET_FLAG           => NULL,
    P_LOC_SUBINV_TYPE          => NULL,
    P_BASE_SUBINV_ASSET_FLAG   => NULL,
    P_ORGANIZATION_TYPE        => NULL,
    P_EXCISE_IN_TRADING        => NULL,
    P_COSTING_METHOD           => NULL,
    P_BOE_APPLIED_FLAG         => NULL,
    P_THIRD_PARTY_FLAG         => NULL,
    --Modified by Bo Li for bug9305067 replacing the old parameters  Begin
    ---------------------------------------------------------------------
    P_TRX_INFORMATION         => lv_comments,
    P_EXCISE_INV_GEN_STATUS   => NULL,
    P_VAT_INV_GEN_STATUS      => NULL,
    P_EXCISE_INV_GEN_NUMBER   => NULL,
    P_VAT_INV_GEN_NUMBER      => NULL,
    P_CENVAT_COSTED_FLAG	    => NULL,
     ---------------------------------------------------------------------
     --Modified by Bo Li for bug9305067 replacing the old parameters  End
    p_tax_transaction_id       => NULL
  );

  OPEN  c_rcv_hdr;
  FETCH c_rcv_hdr into r_rcv_hdr;
  CLOSE c_rcv_hdr;
  /*v_rowid := r_rcv_hdr.rowid;*/

  open c_jai_rcv_hdr_chk(pr_new.shipment_header_id);
  fetch c_jai_rcv_hdr_chk into v_chk;
  close c_jai_rcv_hdr_chk;

  if v_chk is null then

    INSERT INTO jai_rcv_headers(
       SHIPMENT_HEADER_ID
      ,RECEIPT_SOURCE_CODE
      ,RECEIPT_NUM
      ,SHIPMENT_NUM
      ,SHIPPED_DATE
      ,ORGANIZATION_ID
      ,VENDOR_ID
      ,VENDOR_SITE_ID
      ,CUSTOMER_ID
      ,CUSTOMER_SITE_ID,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      pr_new.shipment_header_id,
      r_rcv_hdr.receipt_source_code,
      r_rcv_hdr.receipt_num,
      r_rcv_hdr.shipment_num,
      r_rcv_hdr.shipped_date,
      r_rcv_hdr.organization_id,
      r_rcv_hdr.vendor_id,
      r_rcv_hdr.vendor_site_id,
      r_rcv_hdr.customer_id,
      r_rcv_hdr.customer_site_id,
      sysdate,
      fnd_global.user_id,
      sysdate,
      fnd_global.user_id,
      fnd_global.login_id
    );
  end if;
END IF;

/* Vijay Shankar for Bug#4250171 */
IF pr_new.comments in ('OPM RECEIPT', 'OPM Receipt Correction') THEN
  IF pr_new.comments = 'OPM Receipt Correction' THEN
    lv_request_desc := 'India - Receiving Transaction Processor for OPM '|| initcap(pr_new.transaction_type);
    lv_called_from := 'RECEIPT_TAX_INSERT_TRG';
    lv_submit_jainrvctp := 'Y';
    GOTO end_of_trigger;
  ELSE
    RETURN;
  END IF;
END IF;

v_shipment_header_id := pr_new.shipment_header_id;

/* Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
 -- IFpr_new.attribute_category IS NULL AND :
       -- commented, Harshita for bug #4285064
  -- 'RETURN TO RECEIVING' added by ssumaith - bug#3633666
IF pr_new.transaction_type IN ('RECEIVE', 'UNORDERED','DELIVER','RETURN TO RECEIVING') -- DELIVER added by sriram - Bug # 2881674 (RMA Accounting Entries )
THEN

 For head_rec IN (SELECT attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5, --ashish for bug # 2613817
          receipt_source_code,
          attribute_category
          FROM rcv_shipment_headers
          WHERE shipment_header_id = v_shipment_header_id)
  LOOP

  IF head_rec.attribute_category = 'India Receipt' THEN
    pr_new.attribute_category := nvl(pr_new.attribute_category, head_rec.attribute_category);
    pr_new.attribute1 := nvl(pr_new.attribute1, head_rec.attribute1) ;   -- nvl conditions added by Harshita for bug #4285064
    pr_new.attribute2 := nvl(pr_new.attribute2, head_rec.attribute2) ;
    pr_new.attribute3 := nvl(pr_new.attribute3, head_rec.attribute3) ;
    pr_new.attribute4 := nvl(pr_new.attribute4, head_rec.attribute4) ;
    pr_new.attribute5 := nvl(pr_new.attribute5, head_rec.attribute5) ;   --ashish for bug # 2613817
    v_receipt_source_code := head_rec.receipt_source_code;--ashish for bug # 2613817
  ELSIF head_rec.attribute_category = 'India RMA Receipt' THEN
    pr_new.attribute_category := nvl(pr_new.attribute_category, head_rec.attribute_category) ;
    pr_new.attribute1 := nvl(pr_new.attribute1, head_rec.attribute1) ; -- -- nvl conditions added by Harshita for bug #4285064
    pr_new.attribute2 := nvl(pr_new.attribute2, head_rec.attribute2) ;
    pr_new.attribute3 := nvl(pr_new.attribute3, head_rec.attribute3) ;
    pr_new.attribute4 := nvl(pr_new.attribute4, head_rec.attribute4) ;
    pr_new.attribute5 := nvl(pr_new.attribute5, head_rec.attribute5) ;   -- sriram  for 'India RMA Receipt' attribute5 was not getting copied -- Bug # 2881674 (RMA Accounting Entries ).
  END IF;

  END LOOP;
END IF;

if pr_new.attribute_category = 'India Return to Vendor' or pr_new.transaction_type = 'RETURN TO VENDOR' then
  pr_new.attribute4 :=pr_new.attribute4;
  pr_new.attribute_category:= 'India Return to Vendor';
end if;

-- code added in Bug#3683666 is a problem if Customer has their own DFFs. So,
-- following condition added by Vijay Shankar for Bug#3959765 by modifying the code added in Bug#3683666
IF  pr_new.source_document_code = 'RMA' AND
    pr_new.attribute_category IS NULL AND
    pr_new.attribute2 is NOT NULL
THEN
  pr_new.attribute2 := null;
END IF;

--ashish for bug # 2613817
IF pr_new.attribute_category <> 'India RMA Receipt'
  AND v_receipt_source_code in ('VENDOR','INTERNAL ORDER')
  AND pr_new.attribute15 is null
  AND pr_new.interface_source_code is null
THEN
  pr_new.attribute15 := pr_new.attribute5;
  pr_new.attribute5  := null;
END IF;
-- End ashish for bug # 2613817
*/

-- if pr_new.transaction_type NOT IN ('CORRECT', 'DELIVER',  'RETURN TO RECEIVING', 'RETURN TO VENDOR') then  -- Vijay Shankar for Bug#3940588
-- following IF condition added by Vijay Shankar for Bug#3940588
if pr_new.transaction_type IN ('RECEIVE', 'UNORDERED', 'MATCH',
  'RETURN TO VENDOR')   -- RTV is added in the list just for validation checking in the calling procedure
then

    jai_rcv_tax_pkg.default_taxes_onto_line(
      pr_new.transaction_id,
      pr_new.parent_transaction_id,
      pr_new.shipment_header_id,
      pr_new.shipment_line_id,
      pr_new.organization_id,
      pr_new.requisition_line_id,
      pr_new.quantity,
      pr_new.primary_quantity,
      pr_new.po_line_location_id,
      pr_new.transaction_type,
      pr_new.source_document_code,
      pr_new.destination_type_code,
      pr_new.subinventory,
      pr_new.vendor_id,
      pr_new.vendor_site_id,
      pr_new.po_header_id,
      pr_new.po_line_id,
      pr_new.location_id,
      pr_new.transaction_date,
      pr_new.uom_code,
      -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. pr_new.attribute1,
      --to_date(pr_new.attribute2,'YYYY/MM/DD HH24:MI:SS'),
      --pr_new.attribute3,
      --pr_new.attribute4,
      pr_new.attribute15,
      pr_new.currency_code,
      pr_new.currency_conversion_type,
      pr_new.currency_conversion_date,
      pr_new.currency_conversion_rate,
      pr_new.creation_date,
      pr_new.created_by,
      pr_new.last_update_date,
      pr_new.last_updated_by,
      pr_new.last_update_login,
      pr_new.unit_of_measure,
      pr_new.po_distribution_id,
      pr_new.oe_order_header_id,
      pr_new.oe_order_line_id,
      pr_new.routing_header_id
      -- Vijay Shankar for Bug#3940588. RECEIPTS DEPLUG
      -- , v_chk_form  -- commented by ssumaith - R12-PADDR
      -- Vijay Shankar for Bug#4159557
      , pr_new.interface_source_code
      , pr_new.interface_transaction_id
      , lv_allow_tax_change_hook
   --Reverted the change in R12   ,  pr_new.group_id   /*Added by nprashar for bug # 8566481 */
    );
end if;

pr_new.attribute15 := null;

-- added by Vijay Shankar for Bug#3940588
-- following is to take care that the old code will not be executed because
UPDATE JAI_RCV_LINES
SET
    process_receiving       = 'X', --DECODE(process_receiving, 'Y', 'Y', v_process_receiving),
    process_delivery        = 'X', --DECODE(process_delivery, 'Y', 'Y', v_process_delivery),
    process_third_party_inv = 'X', --DECODE(process_third_party_inv, 'Y', 'Y', v_process_third_party_inv),
    process_modvat          = 'X', --DECODE(process_modvat, 'Y', 'Y', v_process_modvat),
    process_rg              = 'X', --DECODE(process_rg, 'Y', 'Y', v_process_rg),
    process_populate_cenvat = 'X',  --DECODE(process_populate_cenvat,'Y','Y',v_process_populate_cenvat) --Changed by Nagaraj.s for Bug3036825
    process_rtr             = 'X',
    process_rtv             = 'X'
    -- this update is to take care that the RECEIPT line is of MATCH and not of UNORDERED
    , transaction_id        = decode(pr_new.transaction_type,'MATCH', pr_new.transaction_id, transaction_id)
    ,last_update_date       = sysdate
    ,last_updated_by        = fnd_global.user_id
WHERE shipment_line_id = pr_new.shipment_line_id;

/* following added as part of VAT Impl. Changes */
IF pr_new.transaction_type = 'MATCH' THEN
  UPDATE JAI_RCV_LINE_TAXES
  SET transaction_id = pr_new.transaction_id
    , last_update_date  = sysdate
    , last_updated_by   = fnd_global.user_id
  WHERE shipment_line_id = pr_new.shipment_line_id
  and (transaction_id is null or transaction_id <> pr_new.transaction_id);
END IF;

/* Start, Vijay Shankar for Bug# 3496408
 "MATCH" is added in the following if condition by Vijay Shankar for Bug#3940588
*/
IF pr_new.transaction_type in ( 'RECEIVE', 'DELIVER', 'RETURN TO RECEIVING', 'RETURN TO VENDOR', 'CORRECT', 'MATCH') THEN
  BEGIN
    pv_return_code := jai_constants.successful ;

    lv_process_mode := FND_PROFILE.value('JA_IN_RCP_TP_MODE');

    OPEN c_receipt_line(pr_new.shipment_line_id);
    FETCH c_receipt_line INTO lv_tax_modified_flag;
    CLOSE c_receipt_line;

    -- Code modified by Vijay Shankar for Bug#3940588. Refer to Previous version for changes
    -- Incase of transactions Other than CORRECT, the request has to fired always
    if    ( lv_process_mode = '1' and pr_new.transaction_type = 'CORRECT')         -- '1' Indicates Online Mode
      OR  ( pr_new.transaction_type IN ('RETURN TO RECEIVING', 'RETURN TO VENDOR'
                                      , 'DELIVER')
            -- OR (pr_new.transaction_type = 'DELIVER' AND (lv_tax_modified_flag='N' OR pr_new.routing_header_id <> 3))   -- Vijay Shankar for Bug#3940588
          )
      -- following condition added by Vijay Shankar for Bug#3940588. this piece of condition is copied from jai_rcv_tax_pkg.default_taxes_onto_line procedure
      -- OR  ( v_chk_form IS NULL AND pr_new.transaction_type IN ('RECEIVE', 'ASBN') )
      -- following added by Vijay Shankar for Bug#4159557 by commenting the above chk
      OR  ( v_chk_form IS NULL AND pr_new.transaction_type IN ('ASBN') )
      --OR  ( pr_new.transaction_type = 'RECEIVE' AND nvl(lv_tax_modified_flag, 'N')  <> 'Y' )
      --commented the above and added the below by Ramananda for Bug#4565478
      OR  ( pr_new.transaction_type = 'RECEIVE' AND nvl(lv_tax_modified_flag, 'N')  = 'N' )
    then

        lv_request_desc := 'India - Receiving Transaction Processor for '|| initcap(pr_new.transaction_type);

        /* IF v_chk_form IS NULL AND pr_new.transaction_type IN ('RECEIVE', 'ASBN') THEN */
        /* above condition modified as below by Vijay Shankar for Bug#4250236(4245089) as part of VAT Impl. */
        IF ( v_chk_form IS NULL AND pr_new.transaction_type IN ('ASBN') )
          --OR  ( pr_new.transaction_type = 'RECEIVE' AND nvl(lv_tax_modified_flag, 'N')  <> 'Y' )
          --commented the above and added the below by Ramananda for Bug#4565478
          OR  ( pr_new.transaction_type = 'RECEIVE' AND nvl(lv_tax_modified_flag, 'N')  = 'N' )
        THEN
          lv_called_from := 'JAINPORE';
        ELSE
          lv_called_from := 'RECEIPT_TAX_INSERT_TRG';
        END IF;

        /* Vijay Shankar for Bug#4250171 */
        lv_submit_jainrvctp := 'Y';

    end if;

  EXCEPTION
    WHEN OTHERS THEN
/*       RAISE_APPLICATION_ERROR( -20100,'Localization Correction errored -> ' || SQLERRM);
*/ pv_return_code := jai_constants.expected_error ; pv_return_message := 'Localization Correction errored -> ' || SQLERRM ; return ;
 END;
  -- added by Vijay Shankar for Bug#3940588
  if pr_new.transaction_type IN ('CORRECT', 'RETURN TO RECEIVING', 'RETURN TO VENDOR', 'DELIVER') then
    -- previous code which is at the bottom of trigger is brought here

    /* Commented by rallamse bug#4479131 PADDR Elimination
    if pr_new.transaction_type = 'RETURN TO VENDOR' THEN
      UPDATE JAI_CMN_LOCATORS_T
      SET row_id = v_rowid
      WHERE FORM_NAME = 'JAINRTVN';
    end if;
    */
    --Added by Sanjikum for Bug #4105721

    IF pr_new.transaction_type IN ('RETURN TO RECEIVING', 'RETURN TO VENDOR') THEN

      OPEN c_mtl_trx(pr_new.organization_id);
      FETCH c_mtl_trx INTO r_mtl_trx;
      CLOSE c_mtl_trx;

      IF r_mtl_trx.process_enabled_flag = 'Y' THEN
        pr_new.po_unit_price := get_deliver_unit_price(pr_new.shipment_line_id);
      END IF;
    END IF;

    /* commented by Vijay Shankar for Bug#4250171
    return;
    */
  end if;

end if;
-- End, Vijay Shankar for Bug# 3496408

<<end_of_trigger>>

IF lv_submit_jainrvctp = 'Y' THEN

  fnd_profile.get('RCV_TP_MODE',lv_profile_val); --added by csahoo for bug#6071528
 /*Added by CSahoo, BUG 5344225*/
  IF lv_profile_val <> 'BATCH' THEN

    IF
      ( jai_rcv_trx_processing_pkg.gv_shipment_header_id is null
                            OR
       (jai_rcv_trx_processing_pkg.gv_shipment_header_id is not null
                            AND
        NVL(jai_rcv_trx_processing_pkg.gv_shipment_header_id,0) <> pr_new.shipment_header_id)
      )
                              or
      ( jai_rcv_trx_processing_pkg.gv_group_id is null
                            OR
       (jai_rcv_trx_processing_pkg.gv_group_id is not null
                            AND
        NVL(jai_rcv_trx_processing_pkg.gv_group_id,0) <> pr_new.group_id)
      )
    THEN

      IF lv_profile_val = 'IMMEDIATE' THEN
        lv_request_id := fnd_global.conc_request_id ;
      ELSIF lv_profile_val = 'ONLINE' THEN
        lv_group_id   := pr_new.group_id ;
      END IF ;


    /* END BUG 5344225*/

  lv_result := FND_REQUEST.set_mode(true);


-- Date 03/06/2007 by sacsethi for bug 6078460
-- Following parameter is commented
-- p_transaction_type , p_shipment_line_id , p_transaction_id


  lv_req_id := FND_REQUEST.submit_request(
                  'JA', 'JAINRVCTP', lv_request_desc, '', FALSE,
                  pr_new.organization_id,       -- p_organization_id  (number)
                  '',                         -- p_transaction_from (date)
                  '',                         -- p_transaction_to   (date)
                  '',                         -- p_transaction_type
                  '',                         -- p_parent_type
                  pr_new.shipment_header_id,    -- p_shipment_header_id
                  '',                         -- p_receipt_num
                  '',      -- p_shipment_line_id
                  '',        -- p_transaction_id
                  'Y',                        -- p_commit_switch  -> indicates whether to commit the data or not
                  lv_called_from,             -- p_called_from
                  'N',                        -- p_simulate_flag
                  'N',                        -- p_trace_switch
                  CHR(0), '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', ''
              );
  jai_rcv_trx_processing_pkg.gv_shipment_header_id := pr_new.shipment_header_id ;
  jai_rcv_trx_processing_pkg.gv_group_id := pr_new.group_id ;
          END IF;
  END IF;


END IF;

END BRI_T1 ;

END JAI_RCV_RT_TRIGGER_PKG ;

/
