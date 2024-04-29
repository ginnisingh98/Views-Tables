--------------------------------------------------------
--  DDL for Package Body JAI_RCV_ACCOUNTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_RCV_ACCOUNTING_PKG" AS
/* $Header: jai_rcv_accnt.plb 120.6.12010000.10 2010/03/05 07:13:10 vkaranam ship $ */

/*----------------------------------------------------------------------------------------------------------------------------
CHANGE HISTORY for FILENAME: jai_rcv_accounting_pkg.sql
S.No  dd/mm/yyyy   Author and Details
------------------------------------------------------------------------------------------------------------------------------
1     07/08/2004   Nagaraj.s for Bug# 3496408, Version:115.0
                   This Package is coded to handle all Accounting Entries for all the Receiving/Return Transactions and Cenvat Entries

2     16/09/2004    Sanjikum for bug # 3889243 File Version : 115.1
                        - Added 2 new variables - r_rcv_transactions, ln_accounting_line_type
                        - Added cursor - cur_trans_type, to get the transaction type
                        - Assigned the value to ln_accounting_line_type, on the basis of transaction type and
                          Debit_credit_flag
                        - While inserting into mtl_transaction_accounts, the value of column accounting_line_type
                          is changed from hadrcoded 1 to ln_accounting_line_type
                        - In the Begin of the Procedure mta_entry, Changed the condition from
                          "if NVL(ln_tax_amount, 0) = 0 then " to "if NVL(p_tax_amount, 0) = 0 then"

3     10/10/2004   Vijay Shankar for Bug#3899897 (3927371), Version:115.2
                    During Average Costing, Instead of populating MTL_MATERIAL_TRANSACTIONS_TEMP table we stated populating
                    MTL_TRANSACTIONS_INTERFACE and MTL_TXN_COST_DET_INTERFACE. This new route is followed to remove the incosistancy in
                    the way the costing happens. This is porting of Bug#3841831
                    New Internal Package Procedure MTI_ENTRY is introduced with this fix. Procedure name MMTT_ENTRY is modified as AVERAGE_COSTING

4     08/11/2004   Vijay Shankar for Bug#3949487, Version:115.3
                    Duplicate Check in process_transaction is modified to use CR, DR filter. This is to pass both CR and DR
                    entries if Inventory receiving and AP Acrual account refers to same account_id. Previously its passing
                    only one CR or DR entry if this is the case

5     19/03/2005   Vijay Shankar for Bug#4250236(4245089). FileVersion: 115.4
                    added two parameters(reference_name, reference_id) in process_transaction procedure as part of VAT Implementation
                    to enhance the duplicate check. Modified the duplicate check cursor to use the two new input parameters that
                    are added

6  01/04/2005      Sanjikum for Bug#4257065, Version 115.5
                   Reason/problem
                   --------------
                   As ln_entered_cr and ln_entered_dr are rounded to the currency precision, before calling the procedure rcv_transactions_update.
                   So in the Procedure rcv_transactions_update, po_unit_price is rounded to the precision of the currency

                   Fix
                   ---
                   In the Procedure Process_transaction, while calling procedure rcv_transactions_update, passed the value of parameter
                   p_costing_amount as ROUND(NVL(p_entered_cr, p_entered_dr),5), instead of NVL(ln_entered_cr, ln_entered_dr)

7  08-Jun-2005     File Version 116.2. Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
                   as required for CASE COMPLAINCE.

8. 13-Jun-2005     Ramananda for bug#4428980. File Version: 116.3
                   Removal of SQL LITERALs is done.

9. 7-Jul-2005      rchandan for bug#4473022. File Version: 116.4
                   Modified the object as part of SLA impact uptake. The procedure mta_entry has changed
                   to replace an insert into mtl_transaction_accounts with a call to gl_entry.
10. 28/07/2005     Ramananda for Bug#4522484. File Version: 120.2
                   Issue:-
                    Due to a PO Receipt Delivery transaction,India Localization does an the average cost update value change transaction.
                    The tax amounts are getting prorated and all the costing elements get updated.
                    The correct behaviour would be to pass on all the tax amounts to the Material and Material Overhead costing element.

                   Fix:-
                    The issue has been resolved by making an insert into the the mctcdi with a value change of 0 for the cost elements which
                    are present in the CLCD (cst_layer_cost_details) but not in mctcdi.

                   Dependency Due to this Bug:-
                    Functional dependency with procedure jai_rcv_accounting_pkg.mti_entry version 120.2

Dependancy:
-----------
IN60105D2 + 3496408
IN60106   + 3940588 +  4245089

11.13-FEB-2007     Vkaranam for bug #5186391,File version 120.5
                   Forward Port changes for the base bug #4738650(Over Heads Are Still Loaded For Average When Overheads Are Not Defined In System).
                   Changes are done in the cursor c_fetch_count_overheads.

12.  03-oct-2008  vkaranam for bug#5228227,File version 120.6.12010000.1/120.7
                  Forward ported the changes done in 115 bug#4994774

13. 29-Apr-2008    CSahoo for bug#8449597, File Version 120.6.12010000.6
                   Modified the cursor c_cost_group. Added an and clause in the cursor.
14.  01-jul-2009  vkaranam for bug#8649408,File version 120.6.12010000.8/120.10
                  Forward ported the changes done in 115 bug#8547858

13. 05-mar-2010   vkaranam for bug#9441529
                  issue:
                  Material overhead is not adding to the nonrecoverable tax potion,due to which the
                  same is not getting costed.
                  Fix:
                  Forwardported the changes done in 115 bug 5737092




----------------------------------------------------------------------------------------------------------------------------*/

  -- This is an Internal Package procedure that simply inserts data into MTI Gateway based on the parameters passed to this procedure
  PROCEDURE mti_entry(
    p_txn_header_id              IN OUT NOCOPY NUMBER,
    p_item_id                     IN NUMBER,
    p_organization_id             IN NUMBER,
    p_uom_code                    IN VARCHAR2,
    p_transaction_date            IN DATE,
    p_transaction_type_id         IN NUMBER,
    p_transaction_source_type_id  IN NUMBER,
    p_transaction_id              IN NUMBER,
    p_cost_group_id               IN NUMBER,
    p_receiving_account_id        IN NUMBER,
    p_absorption_account_id       IN NUMBER,
    p_value_change                IN NUMBER,
    p_new_cost                    IN NUMBER,
    p_usage_rate_or_amount        IN NUMBER,
    p_overhead_exists             IN VARCHAR2, -- Added by Ramananda for the bug 4522484
    p_transaction_action_id       IN NUMBER   -- Vkaranam for bug#5228227
  ) IS

    ln_txn_interface_id         NUMBER;

    -- Default Values
    lv_transaction_source_name  VARCHAR2(30); --File.Sql.35 Cbabu   := 'Avg Cost Update Conversion';
    lv_source_code              VARCHAR2(30); --File.Sql.35 Cbabu   := 'Localization-Value Change';
    ln_src_line_id              NUMBER      ; --File.Sql.35 Cbabu   := -1;
    ln_src_header_id            NUMBER      ; --File.Sql.35 Cbabu   := -1;
    ln_process_flag             NUMBER      ; --File.Sql.35 Cbabu   := 1;
    ln_transaction_mode         NUMBER      ; --File.Sql.35 Cbabu   := 3;
    ln_quantity                 NUMBER      ; --File.Sql.35 Cbabu   := 0;
    ln_lock_flag                NUMBER      ; --File.Sql.35 Cbabu   := 2;     -- No Lock
    ln_material_cost_element_id NUMBER      ; --File.Sql.35 Cbabu   := 1;     -- Material
    ln_overhead_cost_element_id NUMBER      ; --File.Sql.35 Cbabu   := 2;     -- Material
    ln_level_type               NUMBER      ; --File.Sql.35 Cbabu   := 1;     -- This Level
    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_rcv_accnt_pkg.mti_entry';

  BEGIN
     --File.Sql.35 Cbabu
    lv_transaction_source_name   := 'Avg Cost Update Conversion';
    lv_source_code              := 'Localization-Value Change';
    ln_src_line_id              := -1;
    ln_src_header_id            := -1;
    ln_process_flag             := 1;
    ln_transaction_mode         := 3;
    ln_quantity                 := 0;
    ln_lock_flag                := 2;     -- No Lock
    ln_material_cost_element_id := 1;     -- Material
    ln_overhead_cost_element_id := 2;     -- Material
    ln_level_type               := 1;     -- This Level

    -- Material Over head account is defaulted put into Absorption account.
    INSERT INTO mtl_transactions_interface
    (
                    source_code                                         ,
                    source_line_id                                      ,
                    source_header_id                                    ,
                    process_flag                                        ,
                    transaction_mode                                    ,
                    transaction_interface_id                            ,
                    transaction_header_id                               ,
                    inventory_item_id                                   ,
                    organization_id                                     ,
                    revision                                            ,
                    transaction_quantity                                ,
                    transaction_uom                                     ,
                    transaction_date                                    ,
                    transaction_source_name                             ,
                    transaction_type_id                                 ,
                    transaction_source_type_Id                          ,     --PVI
                    rcv_transaction_id                                  ,
                    transaction_reference                               ,     -- rcv_transaction Id.
                    last_update_date                                    ,
                    last_updated_by                                     ,
                    creation_date                                       ,
                    created_by                                          ,
                    cost_group_id                                       ,
                    material_account                                    ,
                    material_overhead_account                           ,      --overhead absorption account
                    resource_account                                    ,
                    overhead_account                                    ,
                    outside_processing_account                          ,
                    lock_flag           ,
        transaction_action_id                                 -- Vkaranam for bug#5228227
                )
         VALUES (
                    lv_source_code                                      ,
                    ln_src_line_id                                      ,
                    ln_src_header_id                                    ,
                    ln_process_flag                                     ,
                    ln_transaction_mode                                 ,
                    mtl_material_transactions_s.nextval                 ,
                    decode( p_txn_header_id, null                       ,
                            mtl_material_transactions_s.currval         ,
                            p_txn_header_id
                          )                                             ,
                    p_item_id                                           ,
                    p_organization_id                                   ,
                    null                                                ,
                    ln_quantity                                         ,      -- No Qty
                    p_uom_code                                          ,
                    p_transaction_date                                  ,
                    lv_transaction_source_name                          ,
                    p_transaction_type_id                               ,      -- Avg Cost Update
                    p_transaction_source_type_id                        ,      -- Inventory
                    p_transaction_id                                    ,
                    to_char(p_transaction_id)                           ,
                    sysdate                                             ,
                    fnd_global.user_id                                  ,
                    sysdate                                             ,
                    fnd_global.user_id                                  ,
                    p_cost_group_id                                     ,
                    p_receiving_account_id                              ,
                    p_absorption_account_id                             ,
                    p_receiving_account_id                              ,
                    p_receiving_account_id                              ,
                    p_receiving_account_id                              ,
                    ln_lock_flag          ,
        p_transaction_action_id                                 -- Vkaranam for bug#5228227
      )
      RETURNING transaction_interface_id                                ,
                transaction_header_id
      INTO      ln_txn_interface_id                                     ,
                p_txn_header_id ;

    INSERT INTO mtl_txn_cost_det_interface
    (
                    transaction_interface_id                       ,
                    last_update_date                               ,
                    last_updated_by                                ,
                    creation_date                                  ,
                    created_by                                     ,
                    organization_id                                ,
                    cost_element_id                                ,
                    level_type                                     ,
                    value_change
      )
      VALUES
      (
                    ln_txn_interface_id                            ,
                    sysdate                                        ,
                    fnd_global.user_id                             ,
                    sysdate                                        ,
                    fnd_global.user_id                             ,
                    p_organization_id                              ,
                    ln_material_cost_element_id                    ,
                    ln_level_type                                  ,
                    p_value_change
    );

    /*
    ||Start of bug 4522484
    ||Added the condition p_overhead_exists
    ||so that the insert gets executed only for Overhead elements
    */
    IF nvl(p_overhead_exists,'NO') = 'YES' THEN
      INSERT INTO mtl_txn_cost_det_interface
      (
                    transaction_interface_id                     ,
                    last_update_date                             ,
                    last_updated_by                              ,
                    creation_date                                ,
                    created_by                                   ,
                    organization_id                              ,
                    cost_element_id                              ,
                    level_type                                   ,
                    value_change
      )
      VALUES
      (
                    ln_txn_interface_id                          ,
                    sysdate                                      ,
                    fnd_global.user_id                           ,
                    sysdate                                      ,
                    fnd_global.user_id                           ,
                    p_organization_id                            ,
                    ln_overhead_cost_element_id                  ,
                    ln_level_type                                ,
                    (p_new_cost  * p_usage_rate_or_amount)
      );
    END IF;

    /*
    || Added by Ramananda for bug 4522484
    || Cost elements which are present in the CLCD (cst_layer_cost_details)
    || should be inserted into MCTCDI with a value change of 0 .
    */

    INSERT INTO mtl_txn_cost_det_interface
       (
         transaction_interface_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         organization_id,
         cost_element_id,
         level_type,
         value_change
       )
       (SELECT
               ln_txn_interface_id   ,
               sysdate               ,
               fnd_global.user_id    ,
               sysdate               ,
               fnd_global.user_id    ,
               p_organization_id     ,
               clcd.cost_element_id  ,
               clcd.level_type       ,
               0
        FROM
               cst_layer_cost_details  clcd,
               cst_quantity_layers     cql
        WHERE
               cql.organization_id   = p_organization_id
        and    cql.inventory_item_id = p_item_id
        and    cql.cost_group_id     = p_cost_group_id
        and    clcd.layer_id         = cql.layer_id
        and   (clcd.cost_element_id,clcd.level_type) NOT IN
                                         ( SELECT
                                                   mctcd1.cost_element_id,
                                                   mctcd1.level_type
                                           FROM
                                                   mtl_txn_cost_det_interface mctcd1
                                           WHERE
                                                   mctcd1.transaction_interface_id = ln_txn_interface_id
                                         )
       );
    /*
    ||End of bug 4522484
    */
  EXCEPTION
    WHEN OTHERS THEN
    p_txn_header_id := null;
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
END mti_entry;

  PROCEDURE process_transaction
  (

      p_transaction_id              in        number,
      p_acct_type                   in        varchar2,
      p_acct_nature                 in        varchar2,
      p_source_name                 in        varchar2,
      p_category_name               in        varchar2,
      p_code_combination_id         in        number,
      p_entered_dr                  in        number,
      p_entered_cr                  in        number,
      p_currency_code               in        varchar2,
      p_accounting_date             in        date,
      p_reference_10                in        varchar2,
      p_reference_23                in        varchar2,
      p_reference_24                in        varchar2,
      p_reference_25                in        varchar2,
      p_reference_26                in        varchar2,
      p_destination                 in        varchar2,
      p_simulate_flag               in        varchar2,
      p_codepath                    in OUT NOCOPY varchar2,
      p_process_message OUT NOCOPY varchar2,
      p_process_status OUT NOCOPY varchar2,
      /* two parameters added by Vijay Shankar for Bug#4250236(4245089). VAT Implementation */
      p_reference_name              in        varchar2 DEFAULT NULL,
      p_reference_id                in        number   DEFAULT NULL

  ) IS


    cursor c_acct_check(cp_transaction_id number ,cp_account_nature varchar2, cp_ccid number,
        cp_reference_name varchar2, cp_reference_id number) is
    select count(transaction_id)
    from   JAI_RCV_JOURNAL_ENTRIES
    where  transaction_id       = cp_transaction_id
    and    acct_nature          = cp_account_nature
    and    code_combination_id  = cp_ccid
    /* following reference columns condition added by Vijay Shankar for Bug#4250236(4245089). VAT Implementation */
    and    ( (cp_reference_name is null and reference_name is null)
            or (cp_reference_name is not null
                and reference_name = cp_reference_name)
           )
    and    ( (cp_reference_id is null and reference_id is null)
            or (cp_reference_id is not null
                and reference_id = cp_reference_id)
           )
    and    ((p_entered_cr <> 0 AND entered_cr <>0) OR (p_entered_dr <> 0 AND entered_dr <>0));   -- Bug#3949487

    /* Need to confirm these 2 Queries as these can be merged */

    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Removed cursor c_fetch_org_information and removed
     * org_organization_definitions from the cursor c_period_name
     * and passed set_of_books_id to the cursor. Also removed
     * gl_sets_of_books and included gl_ledgers.
     */

    cursor c_period_name(cp_set_of_books_id in number, cp_accounting_date in date) IS
    select gd.period_name
    FROM   gl_ledgers gle, gl_periods gd
    where gle.ledger_id          = cp_set_of_books_id
    and   gd.period_set_name     = gle.period_set_name
    and   cp_accounting_date        between gd.start_date and gd.end_date
    and   gd.adjustment_period_flag = 'N';

    /*Added by nprashar for FP bug # 9304844*/
    cursor c_get_gl_period_status(cp_set_of_books_id  number,cp_accounting_date date) IS /* added for bug 7007523 */
 	  select closing_status from gl_period_statuses where
 	  set_of_books_id=cp_set_of_books_id
 	  and application_id=101 /*seeded application id for GL*/
 	  and trunc(cp_accounting_date) between start_date and end_date; /*Added the Trunc clause for bug # 9288398*/

 	 /*Added by nprashar for FP bug # 9304844*/
 	 cursor c_new_accounting_date(cp_set_of_books_id  number) IS  /* added for bug 7007523 */
 	   select start_date from gl_period_statuses
 	   where set_of_books_id=cp_set_of_books_id
 	   and application_id=101 /*seeded application id for GL*/
 	   and closing_status IN ('O','F')
 	   and start_date > p_accounting_date
 	   order by period_year asc,period_num asc,closing_status desc;

     /*Added by nprashar for FP bug # 9304844*/
 	   lv_show_status gl_period_statuses.closing_status%TYPE; /* added for bug 7007523 */
 	   lv_new_accounting_date date; /* added for bug 7007523 */
 	   lv_accounting_date date;   /* added for bug 7007523 */


    /* Record Declarations */
    r_trx                      c_trx%ROWTYPE;
    r_base_trx                 c_base_trx%ROWTYPE;

    ln_acct_count              number; --File.Sql.35 Cbabu  := 0 ;
    ln_set_of_books_id         org_organization_definitions.set_of_books_id%type;
    ln_precision               number;
    ln_entered_cr              number;
    ln_entered_dr              number;
    ln_user_id                 fnd_user.user_id%type; --File.Sql.35 Cbabu  := fnd_global.user_id;

    lv_organization_code       org_organization_definitions.organization_code%type;
    lv_period_name             gl_periods.period_name%type;
    lv_debit_credit_flag       varchar2(1);
    lv_debug                   varchar2(1); --File.Sql.35 Cbabu  := 'Y';

    ld_sysdate                 date; --File.Sql.35 Cbabu         := SYSDATE;

    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Defined variable for implementing caching logic.
     */
    l_func_curr_det jai_plsql_cache_pkg.func_curr_details;
    -- End for bug 5243532
  BEGIN

    lv_debug    := 'Y';
    ld_sysdate  := SYSDATE;
    ln_acct_count := 0 ;
    ln_user_id    := fnd_global.user_id;

    /* Multiple Accounting Entry Checks. Needs to be changed for CENVAT */
    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_accnt.plb> --- 1');
    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_accounting_pkg.process_transaction', 'START'); /* 1 */
    lv_accounting_date:=p_accounting_date; /*Added by nprashar for FP bug # 9304844*/

    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_accnt.plb> --- 2');

    open   c_acct_check(p_transaction_id, p_acct_nature, p_code_combination_id, p_reference_name, p_reference_id);
    fetch  c_acct_check into ln_acct_count;
    close  c_acct_check;

    if lv_debug ='Y' then
      fnd_file.put_line( fnd_file.log, '1.0 ln_acct_count -> ' || ln_acct_count ||' p_simulate_flag ->  ' || p_simulate_flag );
    end if;

    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_accnt.plb> --- 3');
   /**bug#8649408
    if ln_acct_count > 0 and p_simulate_flag ='N' then
      p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2
      p_process_status  := 'X';
      p_process_message := 'Accounting Entries are already passed for Transaction' ; --After Review
      goto exit_from_procedure;
    end if;
    **//*8649408*/

    /* Fetch all the information from JAI_RCV_TRANSACTIONS */
    open c_trx(p_transaction_id);
    fetch c_trx into r_trx;
    close c_trx;

    open   c_base_trx(p_transaction_id);
    fetch  c_base_trx into r_base_trx;
    close  c_base_trx;

    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Removed cursor c_fetch_org_information and
     * implemented caching logic.
     */

     l_func_curr_det       := jai_plsql_cache_pkg.return_sob_curr
                              (p_org_id  =>  r_trx.organization_id);
     lv_organization_code  := l_func_curr_det.organization_code;
     ln_set_of_books_id    := l_func_curr_det.ledger_id;

     p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */

    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_accnt.plb> --- 4');

      /* added for bug 7007523 */
   /*If accouting date is in a closed gl period, the startdate of the latest open period is used as accounting date */

     /*Added by nprashar for FP bug # 9304844*/
     OPEN c_get_gl_period_status(ln_set_of_books_id,lv_accounting_date);/* modified p_accouting_date to lv_accounting_date for bug 7007523 */
     FETCH c_get_gl_period_status into lv_show_status;
     CLOSE c_get_gl_period_status;

     /*Added by nprashar for FP bug # 9304844*/
     IF upper(lv_show_status)='C' THEN
       OPEN c_new_accounting_date(ln_set_of_books_id);
       FETCH c_new_accounting_date INTO lv_new_accounting_date;
       CLOSE c_new_accounting_date;
       lv_accounting_date:=lv_new_accounting_date;
     END IF;
    /* end -  added for bug 7007523 */


    /* Fetch Period Information */

    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Passed set_of_books_id instead of r_trx.organization_id
     * as org_organization_definitions has been removed
     * from the cursor c_period_name,
     */
    /*Added by nprashar for FP bug # 9304844*/
    open    c_period_name(ln_set_of_books_id, lv_accounting_date); --Commented p_accounting_date added lv_accounting_date by nprashar;
    fetch   c_period_name into lv_period_name;
    close   c_period_name;

    p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
    ln_precision         :=  jai_general_pkg.get_currency_precision(r_trx.organization_id);

    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_accnt.plb> --- 5');

    ln_entered_cr        :=  ROUND(p_entered_cr,ln_precision);
    ln_entered_dr        :=  ROUND(p_entered_dr,ln_precision);

    if lv_debug ='Y' then
      fnd_file.put_line( fnd_file.log, '1.3 ln_entered_cr -> ' || ln_entered_cr ||' ln_entered_dr ->  '|| ln_entered_dr );
    end if;

    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_accnt.plb> ---6');

    p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
   jai_rcv_journal_pkg.insert_row
   (
     p_organization_id            =>       r_trx.organization_id,
     p_organization_code          =>       lv_organization_code,
     p_receipt_num                =>       r_trx.receipt_num,
     p_transaction_id             =>       p_transaction_id,
     p_transaction_date           =>       r_trx.transaction_date,
     p_shipment_line_id           =>       r_trx.shipment_line_id,
     p_acct_type                  =>       p_acct_type,
     p_acct_nature                =>       p_acct_nature,
     p_source_name                =>       p_source_name,
     p_category_name              =>       p_category_name,
     p_code_combination_id        =>       p_code_combination_id,
     p_entered_dr                 =>       ln_entered_dr,
     p_entered_cr                 =>       ln_entered_cr,
     p_transaction_type           =>       r_trx.transaction_type,
     p_period_name                =>       lv_period_name,
     p_currency_code              =>       jai_rcv_trx_processing_pkg.gv_func_curr,
     p_currency_conversion_type   =>       NULL,
     p_currency_conversion_date   =>       NULL,
     p_currency_conversion_rate   =>       NULL,
     p_simulate_flag              =>       p_simulate_flag,
     p_process_status             =>       p_process_status,
     p_process_message            =>       p_process_message,
     /* following two parameters added by Vijay Shankar for Bug#4250236(4245089). VAT Implementation */
     p_reference_name             =>       p_reference_name,
     p_reference_id               =>       p_reference_id
   );

    p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
     if p_process_status IN ('E', 'X') then
       goto exit_from_procedure;
     end if;
    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_accnt.plb> --- 7');

  /*This is to Ensure that in case of simulate flag ='Y',
  No Accounting, costing and sub ledger tables are affected */

  if p_simulate_flag ='Y' then
    p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */
    goto exit_from_procedure;
  end if;

    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_accnt.plb> --- 8');
  /*
  The Destination is sent from the respective procedures depending on the Accounting/Costing that
  needs to happen.
  Following are the p_destination values and its target tables.
  |------------------------|-------------------------------------------------------|
  |Destination Type        |        Destination value                              |
  |------------------------|-------------------------------------------------------|
  |    G                   |        GL Interface                                   |
  |    A1                  |        Average Costing - Inventory receiving Entry    |
  |    S                   |        Standard Costing                               |
  |    O1                  |        OPM Costing                                    |
  |------------------------|-------------------------------------------------------|
  */

  if p_destination ='G' then     --GL Interface Entries

    p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8 */

    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_accnt.plb> --- 9');
    gl_entry
    (
       p_organization_id                =>      r_trx.organization_id,
       p_organization_code              =>      lv_organization_code,
       p_set_of_books_id                =>      ln_set_of_books_id,
       p_credit_amount                  =>      ln_entered_cr,
       p_debit_amount                   =>      ln_entered_dr,
       p_cc_id                          =>      p_code_combination_id,
       p_je_source_name                 =>      p_source_name,
       p_je_category_name               =>      p_category_name,
       p_created_by                     =>      ln_user_id,
       p_accounting_date                =>      lv_accounting_date, --Replaced the call of p_accounting_date by nprashar /*Added by nprashar for FP bug # 9304844*/
       p_currency_code                  =>      jai_rcv_trx_processing_pkg.gv_func_curr,
       p_currency_conversion_date       =>      NULL,
       p_currency_conversion_type       =>      NULL,
       p_currency_conversion_rate       =>      NULL,
       p_reference_10                   =>      p_reference_10,
       p_reference_23                   =>      p_reference_23,
       p_reference_24                   =>      p_reference_24,
       p_reference_25                   =>      p_reference_25,
       p_reference_26                   =>      p_reference_26,
       p_process_message                =>      p_process_message,
       p_process_status                 =>      p_process_status,
       p_codepath                       =>      p_codepath
    );

     p_codepath := jai_general_pkg.plot_codepath(9, p_codepath); /* 9 */
     if p_process_status IN ('E', 'X') then
       p_codepath := jai_general_pkg.plot_codepath(10, p_codepath); /* 10 */
       goto exit_from_procedure;
     end if;



  elsif p_destination = 'A1' then /*Average Costing Receiving Inspection Account Entry */

    p_codepath := jai_general_pkg.plot_codepath(11, p_codepath); /* 11 */

    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_accnt.plb> --- 10');

    average_costing
    (
        p_receiving_account_id    =>     p_code_combination_id,
        p_new_cost                =>     NVL(ln_entered_cr, ln_entered_dr),
        p_organization_id         =>     r_trx.organization_id,
        p_item_id                 =>     r_trx.inventory_item_id,
        p_shipment_line_id        =>     r_trx.shipment_line_id,
        p_transaction_uom         =>     r_trx.uom_code,
        p_transaction_date        =>     r_trx.transaction_date,
        p_subinventory            =>     r_base_trx.subinventory,
        p_func_currency           =>     jai_rcv_trx_processing_pkg.gv_func_curr,
        p_transaction_id          =>     p_transaction_id,
        p_process_message         =>     p_process_message,
        p_process_status          =>     p_process_status,
        p_codepath                =>     p_codepath
    );
    p_codepath := jai_general_pkg.plot_codepath(12, p_codepath); /* 12 */

     if p_process_status IN ('E', 'X') then
       p_codepath := jai_general_pkg.plot_codepath(13, p_codepath); /* 13 */
       goto exit_from_procedure;
     end if;

  ELSIF p_destination ='S' then         /* Indicates Standard Costing */

    /*Logic for Setting Debit Credit Flag
    ===================================================
    Amount   > 0                  Debit Credit Flag
    Credit Amount                    N
    Debit  Amount                    Y
    */
    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_accnt.plb> --- 11');

    p_codepath := jai_general_pkg.plot_codepath(14, p_codepath); /* 14 */
    if ln_entered_cr <> 0 then
      p_codepath := jai_general_pkg.plot_codepath(15, p_codepath); /* 15 */
      lv_debit_credit_flag :='N';
    elsif ln_entered_dr <> 0 then
      p_codepath := jai_general_pkg.plot_codepath(16, p_codepath); /* 16 */
      lv_debit_credit_flag :='Y';
    end if;

    if lv_debug ='Y' then
      fnd_file.put_line( fnd_file.log, '1.7 Before the call to mta_entry Procedure ' || 'lv_debit_credit_flag ' || lv_debit_credit_flag);
    end if;

    p_codepath := jai_general_pkg.plot_codepath(17, p_codepath); /* 17 */
    mta_entry
    (
        p_transaction_id              =>      p_transaction_id,
        p_reference_account           =>      p_code_combination_id,
        p_debit_credit_flag           =>      lv_debit_credit_flag,
        p_tax_amount                  =>      NVL(ln_entered_cr, ln_entered_dr),
        p_transaction_date            =>      r_trx.transaction_date,
        p_currency_code               =>      jai_rcv_trx_processing_pkg.gv_func_curr,
        p_currency_conversion_date    =>      NULL,
        p_currency_conversion_type    =>      NULL,
        p_currency_conversion_rate    =>      NULL,
        p_reference_23                =>      p_reference_23,
        p_reference_24                =>      p_reference_24,
        p_reference_26                =>      p_reference_26,
        p_process_message             =>      p_process_message,
        p_process_status              =>      p_process_status,
        p_codepath                    =>      p_codepath,
        p_source_name                 =>      p_source_name,
        p_category_name               =>      p_category_name,
       p_accounting_date             =>       lv_accounting_date --Replaced the call of p_accounting_date by nprashar /*Added by nprashar for FP bug # 9304844*/
    );

    p_codepath := jai_general_pkg.plot_codepath(18, p_codepath); /* 18 */

    if p_process_status IN ('E', 'X') then
       p_codepath := jai_general_pkg.plot_codepath(19, p_codepath); /* 19 */
       goto exit_from_procedure;
    end if;

  /*Bug 7581494 Porting fix made via 6905807 to 12.1 branch and Mainline*/
  /*
  ELSIF p_destination ='O1' then -- OPM Costing Entry

    p_codepath := jai_general_pkg.plot_codepath(20, p_codepath); -- 20

    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_accnt.plb> --- 12');

    rcv_transactions_update
    (
        p_transaction_id               =>       p_transaction_id,
        p_costing_amount               =>       ROUND(NVL(p_entered_cr, p_entered_dr),5), --added by Sanjikum for Bug #4257065
        --p_costing_amount               =>       NVL(ln_entered_cr, ln_entered_dr), --commented by Sanjikum for Bug #4257065
        --This was now rounded to 5 decimal places, as PO_UNIT_PRICE should be rounded to 5 places
        p_process_message              =>       p_process_message,
        p_process_status               =>       p_process_status,
        p_codepath                     =>       p_codepath
    ) ;

    p_codepath := jai_general_pkg.plot_codepath(21, p_codepath); -- 21

    if p_process_status IN ('E', 'X') then
       p_codepath := jai_general_pkg.plot_codepath(22, p_codepath); -- 22
       goto exit_from_procedure;
    end if;
   */

  end if; /*End if for p_destination */
  p_codepath := jai_general_pkg.plot_codepath(23, p_codepath); /* 23 */

    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_accnt.plb> --- 13');

  /*This check ensures that this is called only in the following transaction types
  1. RECEIVE
  2. RETURN TO VENDOR
  3. CORRECT TO RECEIVE
  4. CORRECT TO RTV
  And this is called from JA_in_RECEIVE_RTR_PKG.  */

  if lv_debug ='Y' then
    fnd_file.put_line( fnd_file.log, '2.0 p_acct_nature - > '  || p_acct_nature );
  end if;

  if p_acct_nature = 'Receiving' then

    p_codepath := jai_general_pkg.plot_codepath(24, p_codepath); /* 24 */

    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_accnt.plb> --- 14');

    rcv_receiving_sub_ledger_entry
    (
      p_transaction_id                       =>  p_transaction_id,
      p_organization_id                      =>  r_trx.organization_id,
      p_set_of_books_id                      =>  ln_set_of_books_id,
      p_currency_code                        =>  jai_rcv_trx_processing_pkg.gv_func_curr,
      p_credit_amount                        =>  ln_entered_cr,
      p_debit_amount                         =>  ln_entered_dr,
      p_cc_id                                =>  p_code_combination_id,
      p_shipment_line_id                     =>  r_trx.shipment_line_id,
      p_item_id                              =>  r_trx.inventory_item_id,
      p_source_document_code                 =>  r_base_trx.source_document_code,
      p_po_line_location_id                  =>  r_base_trx.po_line_location_id,
      p_requisition_line_id                  =>  r_base_trx.requisition_line_id,
      p_accounting_date                      =>  lv_accounting_date, --Replaced the call of p_accounting_date by nprashar /*Added by nprashar for FP bug # 9304844*/
      p_currency_conversion_date             =>  NULL,
      p_currency_conversion_type             =>  NULL,
      p_currency_conversion_rate             =>  NULL,
      p_process_message                      =>  p_process_message,
      p_process_status                       =>  p_process_status,
      p_codepath                             =>  p_codepath
    );

    p_codepath := jai_general_pkg.plot_codepath(25, p_codepath); /* 25 */

    if p_process_status IN ('E', 'X') then
      p_codepath := jai_general_pkg.plot_codepath(26, p_codepath); /* 26 */
      goto exit_from_procedure;
    end if;

    p_codepath := jai_general_pkg.plot_codepath(27, p_codepath); /* 27 */

  end if; /* End if for p_acct_nature */

  << exit_from_procedure >>
    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_accnt.plb> --- 15');

  if p_process_status = 'Y' then
    p_process_message := 'The Accounting / Costing Entries are passed successfully ' ;
  end if;

  p_codepath := jai_general_pkg.plot_codepath(28, p_codepath, NULL, 'END'); /* 28 */

  fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_accnt.plb> --- 16');

exception

  when others then
    p_process_status  := 'E';
    fnd_file.put_line(FND_FILE.LOG, ' <jai_rcv_accnt.plb> --- 17');
    p_process_message := 'RECEIPT_ACCOUNTING_PKG.process_transaction:' || SQLERRM;
    FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
    p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, NULL, 'END'); /* 29 */
    return;

end process_transaction;

  /*--------------------------------------------------------------------------------------------------*/
  PROCEDURE gl_entry
  (
      p_organization_id                in         number,
      p_organization_code              in         varchar2,
      p_set_of_books_id                in         number,
      p_credit_amount                  in         number,
      p_debit_amount                   in         number,
      p_cc_id                          in         number,
      p_je_source_name                 in         varchar2,
      p_je_category_name               in         varchar2,
      p_created_by                     in         number,
      p_accounting_date                in         date           default null,
      p_currency_code                  in         varchar2,
      p_currency_conversion_date       in         date           default null,
      p_currency_conversion_type       in         varchar2       default null,
      p_currency_conversion_rate       in         number         default null,
      p_reference_10                   in         varchar2       default null,
      p_reference_23                   in         varchar2       default null,
      p_reference_24                   in         varchar2       default null,
      p_reference_25                   in         varchar2       default null,
      p_reference_26                   in         varchar2       default null ,
      p_process_message OUT NOCOPY varchar2,
      p_process_status OUT NOCOPY varchar2,
      p_codepath                       in OUT NOCOPY varchar2
  ) IS


    lv_reference_entry          gl_interface.reference22%type; --File.Sql.35 Cbabu  := 'India Localization Entry';
    lv_reference_10             gl_interface.reference10%type;
    lv_reference_23             gl_interface.reference23%type;
    lv_reference_24             gl_interface.reference24%type;
    lv_reference_25             gl_interface.reference25%type;
    lv_reference_26             gl_interface.reference26%type;
    lv_debug                    varchar2(1); --File.Sql.35 Cbabu                    := 'Y';

    ln_user_id                  fnd_user.user_id%type; --File.Sql.35 Cbabu          := fnd_global.user_id;

    ld_sysdate                  date; --File.Sql.35 Cbabu                           := SYSDATE;
    ld_accounting_date          date;

    cursor c_trunc_references is
    select
        substr(lv_reference_10,1,240),
        substr(p_reference_23,1,240),
        substr(p_reference_24,1,240),
        substr(p_reference_25,1,240),
        substr(p_reference_26,1,240)
    from dual;

   lv_status  gl_interface.status%type;
  BEGIN

    lv_reference_entry  := 'India Localization Entry';
    lv_debug            := jai_constants.yes;
    ln_user_id          := fnd_global.user_id;
    ld_sysdate          := SYSDATE;

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_accounting_pkg.gl_entry', 'START'); /* 1 */
    lv_reference_10 := substr(p_reference_10 || ' for the Organization code ' || p_organization_code,1,240);

    /*This is introduced to ensure that if the reference values goes beyond the specified width,
    then the value would be restriced to an width of 240 so that exception would not occur.*/
    open c_trunc_references;
    fetch c_trunc_references
      into lv_reference_10, lv_reference_23, lv_reference_24, lv_reference_25, lv_reference_26;
    close c_trunc_references;


    if p_accounting_date is null then
      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
      ld_accounting_date  := sysdate;
    else
      ld_accounting_date := p_accounting_date;
      p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
    end if;

    ld_accounting_date := trunc(ld_accounting_date);

    if p_cc_id is NULL then
      p_process_status  := 'E';
      p_process_message := 'Account not given';
      p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
      goto exit_from_procedure;
    end if;

    if NVL(p_credit_amount, 0) = 0 and NVL(p_debit_amount,0) = 0 then
      p_process_status  := 'E';
      p_process_message := 'Both Credit and Debit are Zero';
      p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
      goto exit_from_procedure;
    end if;

    p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */

    lv_status := 'NEW' ;
    insert into gl_interface
    (
      status,
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
      code_combination_id,
      currency_conversion_date,
      user_currency_conversion_type,
      currency_conversion_rate,
      reference1,
      reference10,
      reference22,
      reference23,
      reference24,
      reference25,
      reference26,
      reference27
    )
    VALUES
    (
      lv_status , --'NEW',
      p_set_of_books_id,
      p_je_source_name,
      p_je_category_name,
      ld_accounting_date,
      p_currency_code,
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
      p_organization_code,
      lv_reference_10,
      lv_reference_entry,
      lv_reference_23,
      lv_reference_24,
      lv_reference_26,
      lv_reference_25,
      to_char(p_organization_id)
    );

    << exit_from_procedure >>
    p_codepath := jai_general_pkg.plot_codepath(8, p_codepath, NULL, 'END'); /* 8 */
    return;

  EXCEPTION

    WHEN OTHERS then
      p_process_status  := 'E';
      p_process_message := 'RECEIPT_ACCOUNTING_PKG.gl_entry:' || SQLERRM;
      FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
      p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, NULL, 'END'); /* 9 */
      RETURN;

  end gl_entry;

  /*--------------------------------------------------------------------------------------------------*/
  PROCEDURE average_costing
  (
      p_receiving_account_id          in         number,
      p_new_cost                      in         number,
      p_organization_id               in         number,
      p_item_id                       in         number,
      p_shipment_line_id              in         number,
      p_transaction_uom               in         varchar2,
      p_transaction_date              in         date,
      p_subinventory                  in         varchar2,
      p_func_currency                 in         varchar2,
      p_transaction_id                in         number          default null,
      p_process_message OUT NOCOPY varchar2,
      p_process_status OUT NOCOPY varchar2,
      p_codepath                      in OUT NOCOPY varchar2
  ) IS

    ln_txn_header_id            NUMBER;
    ln_costing_group_id         pjm_project_parameters.costing_group_id%TYPE;
    ln_user_id                  fnd_user.user_id%type; --File.Sql.35 Cbabu  := fnd_global.user_id;

    lv_error_msg                VARCHAR2(1996);
    lv_process_mode             VARCHAR2(100);
    lv_debug                    VARCHAR2(1); --File.Sql.35 Cbabu  := 'Y';

    ln_retval                       NUMBER;
    lv_return_status                VARCHAR2(2);
    lv_msg_data                     VARCHAR2(300);
    ln_msg_cnt                      NUMBER;
    ln_trans_count                  NUMBER;
    ln_overhead_cnt                 NUMBER;
    ln_loop_count                   NUMBER;
    ln_value_change                 NUMBER;
    lv_result                       BOOLEAN;

    lv_transaction_type_name        VARCHAR2(30); --File.Sql.35 Cbabu  := 'Average cost update';
    ln_transaction_type_id          MTL_TRANSACTION_TYPES.transaction_type_id%TYPE;
    ln_transaction_source_type_id   MTL_TRANSACTION_TYPES.transaction_source_type_id%TYPE;
    ln_transaction_action_id        MTL_TRANSACTION_TYPES.transaction_action_id%TYPE;

    CURSOR c_trx_type_dtls(cp_transaction_type_name IN VARCHAR2) IS
      SELECT transaction_type_id, transaction_source_type_id, transaction_action_id
      FROM mtl_transaction_types
      WHERE transaction_type_name = cp_transaction_type_name;

    CURSOR c_account_period_id(cp_organization_id IN NUMBER, cp_transaction_date IN DATE) IS
      SELECT acct_period_id
      FROM org_acct_periods
      WHERE period_close_date is null
      AND organization_id = cp_organization_id
      AND trunc(schedule_close_date) >= trunc(nvl(cp_transaction_date,sysdate))
      AND trunc(period_start_date) <= trunc(nvl(cp_transaction_date,sysdate));

    CURSOR c_fetch_count_overheads(cp_organization_id in number, cp_item_id in number) IS
  /*
  || added, vkaranam for Bug 5186391
  */
  /*commented by vkaranam for bug#9441529
  select 1
  from CST_ITEM_OVERHEAD_DEFAULTS_V
  where organization_id = cp_organization_id
  and
   ( item_type = 3  -- All items
       OR
     item_type = (select planning_make_buy_code
      from mtl_system_items_fvl a
      where organization_id = cp_organization_id
      and inventory_item_id = cp_item_id
           )
   )
  and basis_type = 5 ;
   /*
      Commented by vkaranam for Bug 5186391  */
     --added by vkaranam for bug#9441529
     SELECT count(1)
     FROM cst_item_cost_details
     WHERE inventory_item_id     = cp_item_id
     AND organization_id         = cp_organization_id
     AND cost_element_id         =  2      --Indicates Material OverHead
     AND basis_type              =  5      --Total Value Basis
     AND cost_type_id = (SELECT avg_rates_cost_type_id
                          FROM mtl_parameters
                          WHERE organization_id   = cp_organization_id
                        );

    CURSOR c_fetch_overhead_rate(cp_organization_id in number, cp_item_id in number) IS
      SELECT a.resource_id, a.usage_rate_or_amount, b.absorption_account
      FROM cst_item_cost_details a, bom_resources b
      WHERE a.resource_id        =  b.resource_id
      AND a.organization_id      =  cp_organization_id
      AND a.inventory_item_id    =  cp_item_id
      AND a.cost_element_id      =  2       --Indicates Material OverHead
      AND a.basis_type           =  5       --Total Value Basis
      AND a.cost_type_id = (SELECT c.avg_rates_cost_type_id
                            FROM mtl_parameters c
                            WHERE c.organization_id = cp_organization_id
                           )
      ORDER BY a.resource_id;

    CURSOR  c_cost_group(cp_transaction_id IN NUMBER,
                         cp_organization_id IN NUMBER) --added for bug#8449597
    IS
      SELECT  costing_group_id
      FROM    pjm_project_parameters
      WHERE   project_id IN ( SELECT project_id
                              FROM   po_distributions_all
                              WHERE  po_distribution_id IN (SELECT  po_distribution_id
                                                            FROM    rcv_transactions
                                                            WHERE   transaction_id = cp_transaction_id
                                                            )
                            )
      AND     organization_id = cp_organization_id; --added for bug#8449597

    cursor c_get_accounts(cp_organization_id IN NUMBER) is
      select mp.default_cost_group_id
      from mtl_parameters mp
      where mp.organization_id = cp_organization_id
      and mp.primary_cost_method = 2;       --Average

    r_get_accounts      c_get_accounts%ROWTYPE;

  BEGIN

    ln_user_id                  := fnd_global.user_id;
    lv_debug                    := 'Y';
    lv_transaction_type_name    := 'Average cost update';

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_accounting_pkg.average_costing', 'START'); /* 1 */

    open  c_cost_group(p_transaction_id, p_organization_id); --added the parameter p_organization_id for bug#8449597
    fetch c_cost_group into ln_costing_group_id;
    close c_cost_group;

    if lv_debug='Y' THEN
      fnd_file.put_line(fnd_file.log, 'ln_costing_group_id:' || ln_costing_group_id);
    end if;

    -- if cost group is 1, then it means it is Common Cost group which should not be populated
    -- so that costing happens at Organization Level instead of CostGroup level
    -- Vijay Shankar for Bug#3747390
    if ln_costing_group_id = 1 then
      ln_costing_group_id := null;
    end if;

    --If cost group id is 1, then the accounts are picked up from the Organization level
    --and hence the Organization Level cost group id needs to be picked up.
    if ln_costing_group_id is null then
      open    c_get_accounts(p_organization_id);
      fetch   c_get_accounts into r_get_accounts;
      close   c_get_accounts;

      ln_costing_group_id := r_get_accounts.default_cost_group_id;
    end if;

    OPEN c_trx_type_dtls(lv_transaction_type_name);
    FETCH c_trx_type_dtls INTO ln_transaction_type_id, ln_transaction_source_type_id, ln_transaction_action_id;
    CLOSE c_trx_type_dtls;

    open   c_fetch_count_overheads(p_organization_id, p_item_id);
    fetch  c_fetch_count_overheads into ln_overhead_cnt;
    close  c_fetch_count_overheads;

    if lv_debug='Y' then
      fnd_file.put_line(fnd_file.log, 'v_transaction_type_id:' || ln_transaction_type_id
        ||', v_transaction_source_type_id:' || ln_transaction_source_type_id
        ||', v_transaction_action_id:' || ln_transaction_action_id
        ||', p_transaction_uom:' || p_transaction_uom
        ||', Transaction Id:' || p_transaction_id ||', ln_overhead_cnt:' || ln_overhead_cnt
      );
    end if;

    -- Normal Clients route
    if nvl(ln_overhead_cnt,0) = 0 then --vkaranam for bug 5186391

      mti_entry(
          p_txn_header_id                 => ln_txn_header_id,
          p_item_id                       => p_item_id,
          p_organization_id               => p_organization_id,
          p_uom_code                      => p_transaction_uom,
          p_transaction_date              => p_transaction_date,
          p_transaction_type_id           => ln_transaction_type_id,
          p_transaction_source_type_id    => ln_transaction_source_type_id,
          p_transaction_id                => p_transaction_id,
          p_cost_group_id                 => ln_costing_group_id,
          p_receiving_account_id          => p_receiving_account_id,
          p_absorption_account_id         => p_receiving_account_id,
          p_value_change                  => p_new_cost,
          p_new_cost                      => p_new_cost,
          p_usage_rate_or_amount          => 0 ,
          p_overhead_exists               => 'NO' ,   --Added by Ramananda for the bug 4522484
    p_transaction_action_id         => ln_transaction_action_id    -- Vkaranam for bug#5228227
      );

    -- if Overheads Exist
    else

      ln_loop_count := 0;

      for c_fetch_records in c_fetch_overhead_rate(p_organization_id, p_item_id)
      loop

        if ln_loop_count = 0 then
          ln_value_change := p_new_cost;
        else
          ln_value_change := 0;
        end if;

        mti_entry(
            p_txn_header_id                 => ln_txn_header_id,
            p_item_id                       => p_item_id,
            p_organization_id               => p_organization_id,
            p_uom_code                      => p_transaction_uom,
            p_transaction_date              => p_transaction_date,
            p_transaction_type_id           => ln_transaction_type_id,
            p_transaction_source_type_id    => ln_transaction_source_type_id,
            p_transaction_id                => p_transaction_id,
            p_cost_group_id                 => ln_costing_group_id,
            p_receiving_account_id          => p_receiving_account_id,
            p_absorption_account_id         => c_fetch_records.absorption_account,
            p_value_change                  => ln_value_change,
            p_new_cost                      => p_new_cost,
            p_usage_rate_or_amount          => c_fetch_records.usage_rate_or_amount,
            p_overhead_exists               => 'YES'   ,  --Added by Ramananda for the bug 4522484
      p_transaction_action_id         => ln_transaction_action_id    -- Vkaranam for bug#5228227
        );


        ln_loop_count := ln_loop_count + 1;

      end loop; --end loop for c_fetch_records

    end if; --end if for ln_overhead_cnt= 0


    p_codepath      := jai_general_pkg.plot_codepath(4, p_codepath);
    lv_process_mode  := FND_PROFILE.value('TRANSACTION_PROCESS_MODE');

    --Indicates Online Mode
    if lv_process_mode = '1' then

      if p_shipment_line_id is null then
        lv_result := FND_SUBMIT.set_mode(TRUE); /*Modified FND call to FND_SUBMIT API -  Bug 8504135*/
      end if;

      --API which populates data into MMT from the data populated earlier in MMTT, so that
      --Localization Taxes get added immediately. This API is suggested by the Base Inventory team.
      ln_retval := inv_txn_manager_pub.process_transactions (
                      p_api_version         => 1,
                      p_init_msg_list       => fnd_api.g_false ,
                      p_commit              => fnd_api.g_false ,
                      p_validation_level    => fnd_api.g_valid_level_full ,
                      x_return_status       => lv_return_status,
                      x_msg_count           => ln_msg_cnt,
                      x_msg_data            => lv_msg_data,
                      x_trans_count         => ln_trans_count,
                      p_table               => 1,
                      p_header_id           => ln_txn_header_id
                   );
    end if;

    << exit_from_procedure >>
    p_codepath := jai_general_pkg.plot_codepath(9, p_codepath, null, 'END');

  EXCEPTION
    WHEN OTHERS then
      p_process_status  := 'E';
      p_process_message := 'RECEIPT_ACCOUNTING_PKG.average_costing:' || SQLERRM;
      FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
      p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END');
      RETURN;

  end average_costing;

  /*------------------------------------------------------------------------------------------------*/
  PROCEDURE rcv_receiving_sub_ledger_entry
  (
       p_transaction_id              in          number,
       p_organization_id             in          number,
       p_set_of_books_id             in          number,
       p_currency_code               in          varchar2,
       p_credit_amount               in          number,
       p_debit_amount                in          number,
       p_cc_id                       in          number,
       p_shipment_line_id            in          number,
       p_item_id                     in          number,
       p_source_document_code        in          varchar2,
       p_po_line_location_id         in          number,
       p_requisition_line_id         in          number,
       p_accounting_date             in          date           default null,
       p_currency_conversion_date    in          date           default null,
       p_currency_conversion_type    in          varchar2       default null,
       p_currency_conversion_rate    in          number         default null,
       p_process_message OUT NOCOPY varchar2,
       p_process_status OUT NOCOPY varchar2,
       p_codepath                    in OUT NOCOPY varchar2
  ) IS

    /* Variable Definitions */
    ln_unit_price      number;
    ln_amount          number;
    ln_user_id         fnd_user.user_id%type;   --File.Sql.35 Cbabu  := fnd_global.user_id;

    ld_accounting_date JAI_RCV_SUBLED_ENTRIES.accounting_date%type;
    ld_sysdate         date;    --File.Sql.35 Cbabu         := SYSDATE;

    lv_debug           varchar2(1); --File.Sql.35 Cbabu  := 'Y';

    /* Cursor Definitions */
    cursor c_base_sub_ledger_details(cp_transaction_id number) IS
    select *
    from rcv_receiving_sub_ledger
    where rcv_transaction_id = cp_transaction_id
    and rownum = 1;

    cursor c_fetch_price_override(cp_po_line_location_id number) IS
    select price_override
    from po_line_locations_all
    where line_location_id = cp_po_line_location_id;

    cursor c_fetch_list_price(cp_organization_id number, cp_item_id number) IS
    select list_price_per_unit
    from mtl_system_items
    where inventory_item_id   = cp_item_id
    and   organization_id     = cp_organization_id;

    cursor c_fetch_unit_price(cp_requisition_line_id number) IS
    select unit_price
    from   po_requisition_lines_all
    where  requisition_line_id = cp_requisition_line_id;

    /*Record Definitions */
    r_base_subledger_details c_base_sub_ledger_details%rowtype;

  BEGin

    lv_debug      := 'Y';
    ln_user_id    := fnd_global.user_id;
    ld_sysdate    := SYSDATE;

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_accounting_pkg.rcv_receiving_sub_ledger_entry', 'START'); /* 1 */

    if NVL(p_credit_amount, 0) = 0 AND NVL(p_debit_amount, 0) = 0 then
      fnd_file.put_line( fnd_file.log, 'Both Credit and Debit are 0. So, returning back');
      GOTO exit_from_procedure;
    end if;

    open  c_base_sub_ledger_details(p_transaction_id);
    fetch c_base_sub_ledger_details into r_base_subledger_details;

    if c_base_sub_ledger_details%notfound then
      close c_base_sub_ledger_details;

      fnd_file.put_line( fnd_file.log, 'Base Entry in rcv_receiving_sub_ledger not found. Hence returning back');
      p_codepath := jai_general_pkg.plot_codepath(2, p_codepath, null, 'END'); /* 2 */
      goto exit_from_procedure;
    end if;

    close c_base_sub_ledger_details;

    p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */

    if  p_source_document_code='PO' then

      p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
      open   c_fetch_price_override(p_po_line_location_id);
      fetch  c_fetch_price_override into ln_unit_price;
      close  c_fetch_price_override;

    ELSIF p_source_document_code='INVENTORY' then

      p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
      open  c_fetch_list_price(p_organization_id, p_item_id);
      fetch c_fetch_list_price into ln_unit_price;
      close c_fetch_list_price;

    ELSIF p_source_document_code = 'REQ' then

      p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
      open   c_fetch_unit_price(p_requisition_line_id);
      fetch  c_fetch_unit_price into ln_unit_price;
      close  c_fetch_unit_price;

    end if;

    p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */
    ln_amount := NVL(p_credit_amount,p_debit_amount);

    if ln_amount is not NULL and nvl(ln_unit_price,0) <> 0 then
      p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8 */
      ln_amount := ln_amount / ln_unit_price;
    end if;

    if p_accounting_date is NULL then
      p_codepath := jai_general_pkg.plot_codepath(9, p_codepath); /* 9 */
      ld_accounting_date := TRUNC(ld_sysdate);
    ELSE
      p_codepath := jai_general_pkg.plot_codepath(10, p_codepath); /* 10 */
      ld_accounting_date := TRUNC(p_accounting_date);
    end if;

      p_codepath := jai_general_pkg.plot_codepath(11, p_codepath); /* 11 */
      insert into JAI_RCV_SUBLED_ENTRIES
             (SUBLED_ENTRY_ID,
                rcv_transaction_id,
                set_of_books_id,
                je_source_name,
                je_category_name,
                accounting_date,
                currency_code,
                date_created_in_gl,
                entered_cr,
                entered_dr,
                transaction_date,
                code_combination_id,
                currency_conversion_date,
                user_currency_conversion_type,
                currency_conversion_rate,
                actual_flag,
                period_name,
                chart_of_accounts_id,
                functional_currency_code,
                je_batch_name,
                je_batch_description,
                je_header_name,
                je_line_description,
                reference1,
                reference2,
                reference3,
                reference4,
                source_doc_quantity,
                created_by,
                creation_date,
                last_update_date,
                last_updated_by,
                last_update_login,
                from_type,
    program_application_id
              )
      VALUES ( JAI_RCV_SUBLED_ENTRIES_S.nextval,
                p_transaction_id,
                p_set_of_books_id,
                r_base_subledger_details.je_source_name,
                r_base_subledger_details.je_category_name,
                ld_accounting_date,
                p_currency_code,
                ld_sysdate,
                p_credit_amount,
                p_debit_amount,
                ld_accounting_date,
                p_cc_id,
                p_currency_conversion_date,
                p_currency_conversion_type,
                p_currency_conversion_rate,
                r_base_subledger_details.actual_flag,
                r_base_subledger_details.period_name,
                r_base_subledger_details.chart_of_accounts_id,
                r_base_subledger_details.functional_currency_code,
                r_base_subledger_details.je_batch_name,
                r_base_subledger_details.je_batch_description,
                r_base_subledger_details.je_header_name,
                r_base_subledger_details.je_line_description,
                r_base_subledger_details.reference1,
                r_base_subledger_details.reference2,
                r_base_subledger_details.reference3,
                r_base_subledger_details.reference4,
                ln_amount,
                ln_user_id,
                ld_sysdate,
                ld_sysdate,
                ln_user_id,
                ln_user_id,
                'L',
    fnd_profile.value('PROG_APPL_ID')
              );
      p_codepath := jai_general_pkg.plot_codepath(12, p_codepath); /* 12 */

    << exit_from_procedure >>
    p_codepath := jai_general_pkg.plot_codepath(13, p_codepath, null, 'END'); /* 13 */

  EXCEPTION

    WHEN OTHERS then
      p_process_status  := 'E';
      p_process_message := 'RECEIPT_ACCOUNTING_PKG.rcv_receiving_sub_ledger_entry:' || SQLERRM;
      FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
      p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END'); /* 14 */
      RETURN;

  end rcv_receiving_sub_ledger_entry;

  /*------------------------------------------------------------------------------------------------*/
  PROCEDURE mta_entry
  (
      p_transaction_id               in          number,
      p_reference_account            in          number,
      p_debit_credit_flag            in          varchar2,
      p_tax_amount                   in          number,
      p_transaction_date             in          date            default null,
      p_currency_code                in          varchar2        default null,
      p_currency_conversion_date     in          date            default null,
      p_currency_conversion_type     in          varchar2        default null,
      p_currency_conversion_rate     in          number          default null,
      p_source_name                 in        varchar2           default null,  /*rchandan for bug#4473022 Start*/
      p_category_name               in        VARCHAR2           default null,
      p_accounting_date             in        DATE               default null,
      p_reference_23                in        varchar2           default null,
      p_reference_24                in        varchar2           default null,
      p_reference_26                in        varchar2           default null,/*rchandan for bug#4473022 End*/
      p_process_message OUT NOCOPY varchar2,
      p_process_status OUT NOCOPY varchar2,
      p_codepath                     in OUT NOCOPY varchar2
  ) IS

  -- ln_primary_quantity     number;
  --ln_tax_amount           number;
  ln_user_id              fnd_user.user_id%type;    --File.Sql.35 Cbabu  := fnd_global.user_id;

  --ld_transaction_date     date;
  ld_sysdate              date; --File.Sql.35 Cbabu         := SYSDATE;

  lv_debug                varchar2(1); --File.Sql.35 Cbabu  := 'Y';
  ln_entered_cr           NUMBER ;--rchandan for bug#4473022
  ln_entered_dr           NUMBER ;--rchandan for bug#4473022
  lv_reference_10_desc1         VARCHAR2(75);--rchandan for bug#4473022
  lv_reference_10_desc2         VARCHAR2(30); --rchandan for bug#4473022
  lv_reference_10_desc          gl_interface.reference10%type;--rchandan for bug#4473022


  --ln_accounting_line_type      mtl_transaction_accounts.accounting_line_type%TYPE; --Added by Sanjikum for Bug#3889243

  cursor c_fetch_mmt_details(cp_transaction_id number) IS
  select *
  from mtl_material_transactions mmt
  where mmt.rcv_transaction_id = cp_transaction_id;

  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Removed cursor c_fetch_org_information and variable r_org_dtls
   * and implemented caching logic.
   */

  r_mmt_details c_fetch_mmt_details%rowtype;

  --Added the cursor by Sanjikum for Bug#3889243
  /*
  CURSOR cur_trans_type(cp_transaction_id rcv_transactions.transaction_id%type) IS
  SELECT  *
    FROM rcv_transactions
   WHERE transaction_id = cp_transaction_id;
  r_rcv_transactions cur_trans_type%ROWTYPE;
  *//*commented by rchandan for bug#4473022 */
  r_trx c_trx%rowtype;-- rchandan for bug#4473022

  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Defined variable for implementing caching logic.
   */
  l_func_curr_det    jai_plsql_cache_pkg.func_curr_details;
  lv_org_code        org_organization_definitions.organization_code%TYPE;
  ln_set_of_books_id gl_ledgers.ledger_id%TYPE;
  -- End for bug 5243532


  BEGin

    lv_debug      := 'Y';
    ln_user_id    := fnd_global.user_id;
    ld_sysdate    := SYSDATE;
    lv_reference_10_desc1      := 'India Local Receiving Entry for the Receipt Number ';--rchandan for bug#4473022
    lv_reference_10_desc2      := ' For the Transaction Type ';--rchandan for bug#4473022

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_accounting_pkg.mta_entry', 'START'); /* 1 */

    if NVL(p_tax_amount, 0) = 0 then
      fnd_file.put_line( fnd_file.log, 'Tax amount is 0. So, returning back');
      GOTO exit_from_procedure;
    end if;

    open  c_fetch_mmt_details(p_transaction_id);
    fetch c_fetch_mmt_details into r_mmt_details;
    close c_fetch_mmt_details;

    if lv_debug ='Y' then
      fnd_file.put_line( fnd_file.log, '5.1 r_mmt_details.primary_quantity ' || r_mmt_details.primary_quantity ||' '||r_mmt_details.transaction_id);
    end if;
    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Removed the commented codes.
     */
    open c_trx(p_transaction_id);-- rchandan for bug#4473022
     fetch c_trx into r_trx;
    close c_trx;
    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Removed cursor c_fetch_org_information and
     * implemented caching logic.
     */

     l_func_curr_det       := jai_plsql_cache_pkg.return_sob_curr
                              (p_org_id  =>  r_trx.organization_id);
     lv_org_code           := l_func_curr_det.organization_code;
     ln_set_of_books_id    := l_func_curr_det.ledger_id;

     /* Bug 5243532. Added by Lakshmi Gopalsami
     * Removed the commented codes.
     */
     IF p_debit_credit_flag  = 'N' THEN     /* rchandan for bug#4473022   start*/
       ln_entered_cr := p_tax_amount;
       ln_entered_dr := null;
     ELSIF p_debit_credit_flag  = 'Y' THEN
       ln_entered_cr := null;
       ln_entered_dr := p_tax_amount;
     END IF;
     lv_reference_10_desc := lv_reference_10_desc1 || r_trx.receipt_num ||lv_reference_10_desc2 ||r_trx.transaction_type ||' of Parent Trx Type ' || r_trx.parent_transaction_type;
     gl_entry
        (  /* Bug 5243532. Added by Lakshmi Gopalsami
      * Changed the parameter to lv_org_code and ln_set_of_books_id
      * instead of r_org_dtls
      */
           p_organization_id                =>      r_trx.organization_id,
           p_organization_code              =>      lv_org_code,
           p_set_of_books_id                =>      ln_set_of_books_id,
           p_credit_amount                  =>      ln_entered_cr,
           p_debit_amount                   =>      ln_entered_dr,
           p_cc_id                          =>      p_reference_account,
           p_je_source_name                 =>      p_source_name,
           p_je_category_name               =>      p_category_name,
           p_created_by                     =>      ln_user_id,
           p_accounting_date                =>      p_accounting_date,
           p_currency_code                  =>      p_currency_code,
           p_currency_conversion_date       =>      p_currency_conversion_date,
           p_currency_conversion_type       =>      p_currency_conversion_type,
           p_currency_conversion_rate       =>      p_currency_conversion_rate,
           p_reference_10                   =>      lv_reference_10_desc,
           p_reference_23                   =>      p_reference_23,
           p_reference_24                   =>      p_reference_24,
           p_reference_25                   =>      r_mmt_details.transaction_id,
           p_reference_26                   =>      p_reference_26,
           p_process_message                =>      p_process_message,
           p_process_status                 =>      p_process_status,
           p_codepath                       =>      p_codepath
        );
     if p_process_status IN ('E', 'X') then
       p_codepath := jai_general_pkg.plot_codepath(10, p_codepath); /* 10 */
       goto exit_from_procedure;
     end if;  /* rchandan for bug#4473022   end*/

     p_codepath := jai_general_pkg.plot_codepath(9, p_codepath); /* 9 */

   << exit_from_procedure >>
   p_codepath := jai_general_pkg.plot_codepath(10, p_codepath, null, 'END'); /* 10 */

  EXCEPTION
    WHEN OTHERS then
      p_process_status  := 'E';
      p_process_message := 'RECEIPT_ACCOUNTING_PKG.mta_entry:' || SQLERRM;
      FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
      p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END'); /* 11 */
      RETURN;
  end mta_entry;

  /*------------------------------------------------------------------------------------------------*/
  PROCEDURE rcv_transactions_update
  (
      p_transaction_id               in          number,
      p_costing_amount               in          number,
      p_process_message OUT NOCOPY varchar2,
      p_process_status OUT NOCOPY varchar2,
      p_codepath                     in OUT NOCOPY varchar2
  ) IS

  BEGIN

      p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_rcv_accounting_pkg.rcv_transactions_update', 'START'); /* 1 */

      UPDATE rcv_transactions
      SET po_unit_price = nvl(po_unit_price,0) + nvl(p_costing_amount,0)
      WHERE transaction_id = p_transaction_id;

      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath, null, 'END'); /* 3 */

  EXCEPTION
    WHEN OTHERS then
      p_process_status  := 'E';
      p_process_message := 'RECEIPT_ACCOUNTING_PKG.rcv_transactions_update:' || SQLERRM;
      FND_FILE.put_line( FND_FILE.log, 'Error in '||p_process_message);
      p_codepath := jai_general_pkg.plot_codepath(999, p_codepath, null, 'END'); /* 4 */
      RETURN;

  end rcv_transactions_update;

end jai_rcv_accounting_pkg;

/
