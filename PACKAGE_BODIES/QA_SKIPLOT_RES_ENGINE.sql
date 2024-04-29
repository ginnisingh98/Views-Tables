--------------------------------------------------------
--  DDL for Package Body QA_SKIPLOT_RES_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_SKIPLOT_RES_ENGINE" AS
/* $Header: qaslresb.pls 120.3.12010000.6 2010/04/26 17:13:30 ntungare ship $ */


--
-- This procedure is an alternate wrapper for launch_shipment_action() to
-- call the RCV API to perform accept or reject. This new procedure enables
-- unit wise inspections with LPN and Lot/Serial controls. Thsi procedure
-- will be used only if one Inspection Plan is involved. Multiple Inspection
-- Plans Inspection will be executed through launch_shipment_action().
-- This procedure called from is launch_shipment_action().
-- Bug 3096256. For RCV/WMS Merge. kabalakr Thu Aug 28 08:34:59 PDT 2003.
--

PROCEDURE launch_shipment_action_int(
              p_po_txn_processor_mode IN VARCHAR2,
              p_po_group_id           IN NUMBER,
              p_collection_id         IN NUMBER,
              p_employee_id           IN NUMBER,
              p_transaction_id        IN NUMBER,
              p_uom                   IN VARCHAR2,
              p_transaction_date      IN DATE,
              p_created_by            IN NUMBER,
              p_last_updated_by       IN NUMBER,
              p_last_update_login     IN NUMBER) IS


  x_return_status    VARCHAR2(5);
  x_msg_count        NUMBER;
  x_msg_data         VARCHAR2(240);


  CURSOR insp_coll_dtl IS
    select organization_id, item_id, lpn_id, xfr_lpn_id,
           lot_number, serial_number, insp_result, sum(insp_qty)
    from   qa_insp_collections_dtl_temp
    where  collection_id = p_collection_id
    group by organization_id, item_id, lpn_id, xfr_lpn_id,
             lot_number, serial_number, insp_result;

  CURSOR item_uom_cur(l_item NUMBER, l_org NUMBER) IS
    select primary_unit_of_measure
    from   mtl_system_items_b
    where  inventory_item_id = l_item
    and    organization_id = l_org;

  l_lpn_id           NUMBER;
  l_xfr_lpn_id       NUMBER;

  -- OPM Conv R12 Tracking Bug 4345760
  -- change variable size for lot num

  l_lot_number       qa_results.lot_number%TYPE;

  l_serial_number    VARCHAR2(30);
  l_insp_result      VARCHAR2(80);
  l_insp_qty         NUMBER;
  l_org_id           NUMBER;
  l_item_id          NUMBER;

  l_primary_uom      VARCHAR2(25);
  l_primary_qty      NUMBER;
  l_int_txn_id       NUMBER;
  l_ser_txn_id       NUMBER;

  -- Added the below cursor and variables for Bug 3225280.
  -- kabalakr Wed Oct 29 23:19:22 PST 2003.

  CURSOR int_txn (grp_id NUMBER, txn_id NUMBER) IS
    SELECT max(interface_transaction_id)
    FROM   rcv_transactions_interface
    WHERE  group_id = grp_id
    AND    parent_transaction_id = txn_id;

  l_rti_int_txn_id  NUMBER;

  -- Bug 8806035.ntungare
  -- Added this cursor and variable for copying the supplier lot number information.
  CURSOR vend_lot_num (txn_id NUMBER) IS
    SELECT vendor_lot_num
    FROM rcv_transactions
    WHERE transaction_id = txn_id;

  l_vendor_lot_num VARCHAR2(30) := NULL;

-- Bug  6781108
-- Added the following two variables to get the value
-- and pass to the RCV API
l_rti_sub_code  mtl_secondary_inventories.secondary_inventory_name%TYPE :=NULL;
l_rti_loc_id    NUMBER := NULL;
begin

    -- First, post the Inspection details from qa_results onto
    -- the temp table qa_insp_collections_dtl_temp.
    -- Here we build the detail temp table for the plan.

    qa_sampling_pkg.post_insp_coll_details(p_collection_id);

    -- Bug 8806035.ntungare
    -- Added this cursor to fetch
    OPEN vend_lot_num(p_transaction_id);
    FETCH vend_lot_num INTO l_vendor_lot_num;
    CLOSE vend_lot_num;

    -- Fetch the records in qa_insp_collections_dtl_temp for calling the
    -- RCV API. We have grouped the records in cursor so that it gives the
    -- consolidated picture.

    OPEN insp_coll_dtl;
    LOOP

        FETCH insp_coll_dtl INTO l_org_id,
                                 l_item_id,
                                 l_lpn_id,
                                 l_xfr_lpn_id,
                                 l_lot_number,
                                 l_serial_number,
                                 l_insp_result,
                                 l_insp_qty;

        EXIT WHEN insp_coll_dtl%NOTFOUND;

        IF l_lpn_id IS NOT NULL THEN

            IF l_xfr_lpn_id IS NULL THEN
                l_xfr_lpn_id := l_lpn_id;
                -- Bug 6781108
                -- Calling this Procedure to get subinv_code and loc_id
                -- in order to insert into RTI table
                -- pdube Wed Feb  6 04:53:32 PST 2008
                QLTDACTB.DEFAULT_LPN_SUB_LOC_INFO(L_LPN_ID,
                                                  L_XFR_LPN_ID,
                                                  l_rti_sub_code,
                                                  l_rti_loc_id);
            END IF;
        END IF;


        -- First, call the RCV API for the Inspection.

        -- Bug 6781108
        -- Passing two variables to four parameters p_sub, p_loc_id,
        -- p_from_subinv and p_from_loc_id as new API
        -- for receiving needed these parameters
        -- pdube Wed Feb  6 23:22:10 PST 2008
        RCV_INSPECTION_GRP.INSERT_INSPECTION
           (p_api_version           => 1.1,
            p_init_msg_list         => NULL,
            p_commit                => 'F',
            p_validation_level      => NULL,
            p_created_by            => p_created_by,
            p_last_updated_by       => p_last_updated_by,
            p_last_update_login     => p_last_update_login,
            p_employee_id           => p_employee_id,
            p_group_id              => p_po_group_id,
            p_transaction_id        => p_transaction_id,
            p_transaction_type      => l_insp_result,
            p_processing_mode       => p_po_txn_processor_mode,
            p_quantity              => l_insp_qty,
            p_uom                   => p_uom,
            p_quality_code          => null,
            p_transaction_date      => p_transaction_date,
            p_comments              => null,
            p_reason_id             => null,
            p_vendor_lot            => l_vendor_lot_num, -- Bug 8806035
            p_lpn_id                => l_lpn_id,
            p_transfer_lpn_id       => l_xfr_lpn_id,
            p_qa_collection_id      => p_collection_id,
            p_return_status         => x_return_status,
            p_msg_count             => x_msg_count,
            p_msg_data              => x_msg_data,
            p_subinventory          => L_RTI_SUB_CODE,
            p_locator_id            => L_RTI_LOC_ID,
            p_from_subinventory     => L_RTI_SUB_CODE,
            p_from_locator_id       => L_RTI_LOC_ID);


        if x_return_status <> 'S' then
                qa_skiplot_utility.insert_error_log (
                p_module_name => 'QA_SKIPLOT_RES_ENGINE.LAUNCH_SHIPMENT_ACTION_INT',
                p_error_message => 'QA_PO_INSP_ACTION_FAIL',
                p_comments => x_msg_data);
                fnd_message.clear;
                fnd_message.set_name ('QA', 'QA_PO_INSP_ACTION_FAIL');
                APP_EXCEPTION.RAISE_EXCEPTION;
        end if;

        -- Bug 9356158.pdube
        -- uncommented the code for getting the interface_txn_id, because this is passed
        -- to insert_mtli and insert_mtsi apis.

        -- Bug 3225280. Moved the Lot and serial insertion code after RCV
        -- insert_inspection API because, we want the interface_transaction_id
        -- of the ACCEPT and REJECT transactions to be passed to the WMS APIs
        -- as product_transaction_id.
        --
        -- For this, first we need to find the interface_transaction_id of the
        -- inspection record inserted by RCV API. The logic here is to fetch the
        -- max(interface_transaction_id) from rti for the parent_transaction_id
        -- and group_id combination. Since we are implementing this just after
        -- RCV API call, it will fetch the interface_transaction_id of the
        -- inspection record just inserted.
        -- kabalakr. Wed Oct 29 23:19:22 PST 2003.
        --

        OPEN  int_txn(p_po_group_id, p_transaction_id);
        FETCH int_txn INTO l_rti_int_txn_id;
        CLOSE int_txn;

        -- Bug 6781108
        -- Commenting the following fix for 3270283
        -- as already handled above through the INSERT_INSPECTION API
        -- pdube Wed Feb  6 04:53:32 PST 2008
	/*-- Bug 3270283. For LPN inspections, we need to default the receiving
        -- subinventory and Locator for the transfer LPN, if its a newly
        -- created one OR, it has a LPN context 'Defined but not used'.
        -- The new procedure DEFAULT_LPN_SUB_LOC_INFO() takes care of this
        -- defaulting logic entirely. Hence just call this procedure if its
        -- a LPN inspection. kabalakr Mon Mar  8 08:01:35 PST 2004.

        IF l_lpn_id IS NOT NULL THEN

           QLTDACTB.DEFAULT_LPN_SUB_LOC_INFO(l_lpn_id,
                                             l_xfr_lpn_id,
                                             l_rti_int_txn_id);

        END IF; -- If l_lpn_id is not null*/
        -- End of Bug 6781108


        IF l_lot_number IS NOT NULL THEN

            OPEN  item_uom_cur(l_item_id, l_org_id);
            FETCH item_uom_cur INTO l_primary_uom;
            CLOSE item_uom_cur;


            IF (l_primary_uom = p_uom) THEN
                l_primary_qty := l_insp_qty;

            ELSE
                l_primary_qty := inv_convert.inv_um_convert
                                   (l_item_id,
                                    NULL,
                                    l_insp_qty,
                                    p_uom,
                                    l_primary_uom,
                                    NULL,
                                    NULL);

            END IF;

            l_int_txn_id := NULL;

            -- Now, call the Inventory/WMS API for Lot Insertion.
            -- Passing NULL value to p_transaction_interface_id to allow the
            -- API to generate one.

            -- Bug 3225280. Changed the value passed as p_product_transaction_id
            -- to l_rti_int_txn_id, derived above.


            INV_RCV_INTEGRATION_APIS.INSERT_MTLI
               (p_api_version                => 1.0,
                p_init_msg_lst               => NULL,
                x_return_status              => x_return_status,
                x_msg_count                  => x_msg_count,
                x_msg_data                   => x_msg_data,
                p_transaction_interface_id   => l_int_txn_id,
                p_transaction_quantity       => l_insp_qty,
                p_primary_quantity           => l_primary_qty,
                p_organization_id            => l_org_id,
                p_inventory_item_id          => l_item_id,
                p_lot_number                 => l_lot_number,
                p_expiration_date            => NULL,
                p_status_id                  => NULL,
                x_serial_transaction_temp_id => l_ser_txn_id,
                p_product_code               => 'RCV',
                p_product_transaction_id     => l_rti_int_txn_id);


            if x_return_status <> 'S' then
                qa_skiplot_utility.insert_error_log (
                p_module_name => 'QA_SKIPLOT_RES_ENGINE.LAUNCH_SHIPMENT_ACTION_INT',
                p_error_message => 'QA_WMS_LOT_INSERT_FAIL',
                p_comments => x_msg_data);
                fnd_message.clear;
                fnd_message.set_name ('QA', 'QA_WMS_LOT_INSERT_FAIL');
                APP_EXCEPTION.RAISE_EXCEPTION;
            end if;


        END IF;


        IF l_serial_number IS NOT NULL THEN

            IF l_lot_number IS NOT NULL THEN
                l_int_txn_id := l_ser_txn_id;

            ELSE
                l_int_txn_id := NULL;

            END IF;

            -- Now, call the Inventory/WMS API for Serial Insertion.
            -- Passing NULL value to p_transaction_interface_id to allow the
            -- API to generate one.

            -- Bug 3225280. Changed the value passed as p_product_transaction_id
            -- to l_rti_int_txn_id, derived above.

            INV_RCV_INTEGRATION_APIS.INSERT_MSNI
              (p_api_version              => 1.0,
               p_init_msg_lst             => NULL,
               x_return_status            => x_return_status,
               x_msg_count                => x_msg_count,
               x_msg_data                 => x_msg_data,
               p_transaction_interface_id => l_int_txn_id,
               p_fm_serial_number         => l_serial_number,
               p_to_serial_number         => l_serial_number,
               p_organization_id          => l_org_id,
               p_inventory_item_id        => l_item_id,
               p_status_id                => NULL,
               p_product_code             => 'RCV',
               p_product_transaction_id   => l_rti_int_txn_id);


            if x_return_status <> 'S' then
                qa_skiplot_utility.insert_error_log (
                p_module_name => 'QA_SKIPLOT_RES_ENGINE.LAUNCH_SHIPMENT_ACTION_INT',
                p_error_message => 'QA_WMS_SER_INSERT_FAIL',
                p_comments => x_msg_data);
                fnd_message.clear;
                fnd_message.set_name ('QA', 'QA_WMS_SER_INSERT_FAIL');
                APP_EXCEPTION.RAISE_EXCEPTION;
            end if;

        END IF;


    END LOOP;

END launch_shipment_action_int;


    --
    -- local function
    --
    function get_result_column(
    p_plan_id in number) return varchar2 is

    col_ref qa_skiplot_utility.refCursorTyp;
    res_col qa_plan_chars.result_column_name%type;

    begin
        open col_ref for
        'select result_column_name
        from qa_plan_chars
        where plan_id = :1 and
        char_id = 8'
        using p_plan_id;

        fetch col_ref into res_col;

        close col_ref;

        return res_col;

    end get_result_column;


    --
    -- local function
    -- Note: this function will not work for wip since 'quantity'
    -- is used as context element in wip, not as inspected quantity
    -- in wip, inspected quantity needs to be passed from UI.
    --
    function get_plan_insp_qty (
    p_collection_id in number,
    p_plan_id in number) return number is

    cursor qty(x_coll_id number, x_plan_id number) is
        select sum(quantity)
        from qa_results
        where collection_id = x_coll_id and
        plan_id = x_plan_id;

    quantity number;

    begin

        open qty (p_collection_id, p_plan_id);
        fetch qty into quantity;
        close qty;

        return nvl(quantity, 0);

    end get_plan_insp_qty;


    --
    -- local function
    --
    function get_plan_result(
    p_collection_id in number,
    p_plan_id in number,
    p_insp_qty out NOCOPY number,
    p_accepted_qty out NOCOPY number,
    p_rejected_qty out NOCOPY number) return varchar2 is

    in_str varchar2(3000);
    result_column qa_plan_chars.result_column_name%type;
    sql_str varchar2(5000);
    result varchar2(100);
    insp_qty number;
    accept_qty number;
    reject_qty number;

    begin

        result_column := get_result_column (p_plan_id);
        in_str :=
        'select displayed_field ' ||
        'from po_lookup_codes ' ||
        'where lookup_type = ''ERT RESULTS ACTION'' and lookup_code = ''REJECT''';

        --
        -- check whether there is a rejection for the plan
        -- since we store the inspection result meaning which
        -- can be in any language, we use in statement to check
        -- inspection result in all possible language
        --

        sql_str := 'select sum(quantity) from qa_results ' ||
        'where collection_id = :1 and plan_id = :2 and '||
        result_column || ' in (' || in_str || ' )';


        execute immediate sql_str into reject_qty
        using p_collection_id, p_plan_id;

        p_insp_qty := get_plan_insp_qty (p_collection_id, p_plan_id);
        p_rejected_qty := nvl(reject_qty, 0);
        p_accepted_qty := p_insp_qty - p_rejected_qty;

        if reject_qty > 0 then
            return 'REJECT';
        elsif p_accepted_qty > 0 then
            return 'ACCEPT';
        else
            return null;
        end if;

    exception
        when  no_data_found then
            return 'ACCEPT';
    end get_plan_result;


    --
    -- local function checks whether inspection is pending
    --
    function are_all_plans_completed(
    p_lot_plans lotPlanTable)
    return varchar2 is

    plan_status varchar2(20);
    plan_result varchar2(20);
    i number;

    begin


        i := p_lot_plans.first;
        while i is not null loop
            plan_result := p_lot_plans(i).plan_insp_status;
            exit when plan_status = 'PENDING';
            i := p_lot_plans.next(i);
        end loop;

        if plan_status = 'PENDING' then
            return fnd_api.g_false;
        else
            return fnd_api.g_true;
        end if;

    end are_all_plans_completed;

    --
    -- local function checks whether inspection is rejected
    --
    function is_any_plan_rejected(
    p_lot_plans lotPlanTable)
    return varchar2 is

    plan_result varchar2(20);
    i number;

    begin


        i := p_lot_plans.first;
        while i is not null loop
            plan_result := p_lot_plans(i).plan_insp_result;
            exit when plan_result = 'REJECT';
            i := p_lot_plans.next(i);
        end loop;


        if plan_result = 'REJECT' then
            return fnd_api.g_true;
        else
            return fnd_api.g_false;
        end if;

    end is_any_plan_rejected;

    --
    -- local function
    -- in rcv inspection, due to transfering,
    -- the lot qty may be splited.
    --
    function is_lot_qty_finished(
    p_txn_qty in number,
    p_shipment_line_id in number) return varchar2 is

    cursor c (x_txn_qty number, x_shl_id number) is
        select 'FINISHED' from qa_skiplot_rcv_results
        where shipment_line_id = x_shl_id and
        lot_qty <= transacted_qty + nvl(x_txn_qty, 0) ;

    conclusion varchar2(20);

    begin

        --
        -- maybe in wip, no need to check lot qty
        --
        if p_shipment_line_id is null then
            return fnd_api.g_true;
        end if;

        open c (p_txn_qty, p_shipment_line_id);
        fetch c into conclusion;
        close c;

        if conclusion = 'FINISHED' then
            return fnd_api.g_true;
        else
            return fnd_api.g_false;
        end if;
    end is_lot_qty_finished;

    --
    -- local procedure
    --
    procedure update_plan_states(
    p_insp_result in varchar2,
    p_criteria_id in number,
    p_lot_id in number default null,
    p_shipment_line_id in number default null,
    p_lot_size in number,
    p_lot_plans in lotPlanTable,
    p_txn in number,
    p_prev_txn_type in varchar2 default null,
    p_reinsp_flag in varchar2 default null) is

    i number;
    receipt_date date;
    pid number;

    cursor get_receipt_date (x_insp_lot_id number) is
        select receipt_date
        from qa_skiplot_rcv_results
        where insp_lot_id = x_insp_lot_id;

    cursor get_receipt_date2 (x_shl_id number) is
        select receipt_date
        from qa_skiplot_rcv_results
        where shipment_line_id = x_shl_id;

    --
    -- given a criteria_id, lotsize and receipt date
    -- process id should be unique.
    --
    cursor get_process_id (x_cid number, x_receipt_date date,
    x_lotsize number) is
        select qsa.process_id
        from qa_skiplot_association qsa
        where criteria_id = x_cid and
        trunc(x_receipt_date) between
        nvl(trunc(qsa.effective_from), trunc(x_receipt_date)) and
        nvl(trunc(qsa.effective_to), trunc(x_receipt_date)) and
        x_lotsize between
        nvl(qsa.lotsize_from, x_lotsize) and
        nvl(qsa.lotsize_to, x_lotsize);

    begin

        if p_shipment_line_id is not null then
            open get_receipt_date2 (p_shipment_line_id);
            fetch get_receipt_date2 into receipt_date;
            close get_receipt_date2;
        else
            open get_receipt_date (p_lot_id);
            fetch get_receipt_date into receipt_date;
            close get_receipt_date;
        end if;

        open get_process_id (p_criteria_id, receipt_date, p_lot_size);
        fetch get_process_id into pid;
        close get_process_id;

        --
        -- if re-inspection changed the result from accept to reject
        -- or if 1st inspection shows reject, reset the plan states
        --
        if p_reinsp_flag = fnd_api.g_true  then

            if p_prev_txn_type = 'ACCEPT' and p_insp_result = 'REJECT' then
                qa_skiplot_utility.init_plan_states(
                p_process_id => pid,
                p_criteria_id => p_criteria_id,
                p_txn => p_txn);
            end if;

        --
        -- 1st inspection failed
        --
        elsif p_insp_result = 'REJECT' then

                qa_skiplot_utility.init_plan_states(
                p_process_id => pid,
                p_criteria_id => p_criteria_id,
                p_txn => p_txn);

        --
        -- 1st inspection accepted
        -- update the plan states one by one if it's not alternate plan
        --
        else

            i := p_lot_plans.first;
            while i is not null loop
                --
                -- alternate plan does not have plan state
                --
                if p_lot_plans(i).alternate_flag is null or
                   p_lot_plans(i).alternate_flag <> 'Y' then
                    update_plan_state(
                    p_insp_result => p_insp_result,
                    p_criteria_id => p_criteria_id,
                    p_process_id => pid,
                    p_lot_plan => p_lot_plans(i),
                    p_txn =>p_txn);
                end if;
                i := p_lot_plans.next(i);
            end loop;
        end if;

    end update_plan_states;


    --
    -- procedure set skiplot flag to 'Y'.
    --

    procedure set_skiplot_flag(
    p_collection_id in number) is

    begin

        update qa_insp_collections_temp
        set skiplot_flag = 'Y'
        where collection_id = p_collection_id;

    end set_skiplot_flag;

    --
    -- local function
    -- check the previous transaction type.
    -- This check is needed to decide whether the current
    -- inspection is re-inspection.
    --
    procedure check_txn_type (
    p_rcv_txn_id in number,
    p_txn_type out NOCOPY varchar2,
    p_reinsp_flag out NOCOPY varchar2) is

    cursor txn_type (x_txn_id in number) is
        select transaction_type
        from rcv_transactions
        where transaction_id = x_txn_id;

    begin

        open txn_type (p_rcv_txn_id);
        fetch txn_type into p_txn_type;
        close txn_type;

        if p_txn_type in ( 'ACCEPT', 'REJECT') then
            p_reinsp_flag := fnd_api.g_true;
        else
            p_reinsp_flag := fnd_api.g_false;

        end if;

    end check_txn_type;

    --
    -- insert the inspecion result to po rcv tables.
    --
    --
    -- Bug 8678609. FP for Bug 4517387.
    -- Added a new parameter p_shipment_header_id to support skiplot based on ASN's.
    -- skolluku
    --
    PROCEDURE PROCESS_SKIPLOT_RESULT (
    p_collection_id IN NUMBER,
    p_insp_lot_id IN NUMBER DEFAULT NULL,
    p_shipment_line_id IN NUMBER DEFAULT NULL,
    p_inspected_qty IN NUMBER DEFAULT NULL,
    p_total_txn_qty IN NUMBER DEFAULT NULL,
    p_rcv_txn_id IN NUMBER DEFAULT NULL,
    p_shipment_header_id IN NUMBER DEFAULT NULL, -- Added for bug 8678609.
    p_lot_result OUT NOCOPY VARCHAR2) IS

    lot_result VARCHAR2(30);
    lot_plans lotPlanTable;
    criteria_id NUMBER;
    txn NUMBER;
    prev_txn_type varchar2(30);
    reinsp_flag varchar2(10);

    BEGIN

        --
        -- set skip lot flag in qa_insp_collections_temp table.
        --
        set_skiplot_flag (p_collection_id);


        --
        -- check previous txn type
        --
        if p_rcv_txn_id is not null then
            check_txn_type (p_rcv_txn_id,prev_txn_type, reinsp_flag);
        end if;

        --
        -- update lot plans table with inspection
        -- status and results and return back the
        -- plan list
        --
        update_lot_plans(
        p_collection_id => p_collection_id,
        p_insp_lot_id => p_insp_lot_id,
        p_shipment_line_id => p_shipment_line_id,
        p_rcv_txn_id => p_rcv_txn_id,
        p_inspected_qty => p_inspected_qty,
        p_prev_txn_type => prev_txn_type,
        p_reinsp_flag => reinsp_flag);

        --
        -- update lot result table with the lot
        -- inspection result
        --
        --
        -- Bug 8678609. FP for Bug 4517387.
        -- Added two new parameters p_shipment_header_id and p_rcv_txn_id to support
        -- skiplot based on ASN's.
        -- skolluku
        --
        update_skiplot_result(
        p_collection_id => p_collection_id,
        p_insp_lot_id => p_insp_lot_id,
        p_shipment_line_id => p_shipment_line_id,
        p_total_txn_qty => p_total_txn_qty,
        p_prev_txn_type => prev_txn_type,
        p_reinsp_flag => reinsp_flag,
        p_shipment_header_id => p_shipment_header_id, -- Added for bug 8678609.
        p_rcv_txn_id => p_rcv_txn_id, -- Added for bug 8678609.
        p_criteria_id => criteria_id, -- out parameter
        p_result => lot_result, -- out parameter
        p_lot_plans => lot_plans); -- out parameter


        --
        -- update plan state table for each plan
        --
        if p_shipment_line_id is null then
            txn := QA_SKIPLOT_UTILITY.WIP;
        else
            txn := QA_SKIPLOT_UTILITY.RCV;
        end if;

        update_plan_states(
        p_insp_result => lot_result,
        p_criteria_id => criteria_id,
        p_shipment_line_id => p_shipment_line_id,
        p_lot_id => p_insp_lot_id,
        p_lot_size => p_total_txn_qty,
        p_lot_plans => lot_plans,
        p_txn =>txn,
        p_prev_txn_type => prev_txn_type,
        p_reinsp_flag => reinsp_flag);

        p_lot_result := lot_result;


    EXCEPTION
        WHEN OTHERS THEN
            qa_skiplot_utility.insert_error_log (
            p_module_name => 'QA_SKIPLOT_RES_ENGINE.PROCESS_SKIPLOT_RESULT',
            p_error_message => 'QA_SKIPLOT_PROCESS_RES_ERROR',
            p_comments => SUBSTR (SQLERRM , 1 , 240));

            fnd_message.clear;
            fnd_message.set_name ('QA', 'QA_SKIPLOT_PROCESS_RES_ERROR');
            APP_EXCEPTION.RAISE_EXCEPTION;

    END PROCESS_SKIPLOT_RESULT;

    PROCEDURE PROCESS_SKIPLOT_RESULT (
    p_collection_id IN NUMBER,
    p_lpn_id IN NUMBER,
    p_inspected_qty IN NUMBER,
    p_total_txn_qty IN NUMBER,
    p_lot_result OUT NOCOPY VARCHAR2) IS


    cursor shls (x_lpn_id number) is
    select shipment_line_id
    from qa_skiplot_rcv_results
    where lpn_id = x_lpn_id;

    shlid number;
    lot_result varchar2(30);
    --
    -- Bug 8678609. FP for Bug 7557274.
    -- Adding the condition for shipment_line_id to filter
    -- this query further to handle scenario of multiple
    -- receipts in single LPN case.pdube Tue Nov 25 01:26:03 PST 2008
    -- Bug 8678609. FP for Bug 6603716
    -- Adding the following variables and cursor
    -- for ASN receipts
    -- skolluku
    --
    p_shipment_header_id NUMBER;
    p_rcv_txn_id NUMBER;
    CURSOR shp_hdr_rcv_txns(x_lpn_id NUMBER, x_shipment_line_id NUMBER) IS
    SELECT rt.shipment_header_id shipment_header_id,
           rt.transaction_id transaction_id
    FROM rcv_transactions rt,
         rcv_supply rs
    WHERE rs.lpn_id = x_lpn_id AND
          rt.transaction_id=rs.supply_source_id AND
          rt.transaction_type='RECEIVE' AND
          rt.shipment_line_id = x_shipment_line_id;
    BEGIN

        for id in shls (p_lpn_id) loop
          --
          -- Bug 8678609. FP for Bug 7557274
          -- Making multiple calls to process skiplot result to handle
          -- multiple receipts in same lpn case.
          -- skolluku
          --
          for shl in shp_hdr_rcv_txns(p_lpn_id,id.shipment_line_id) loop
            process_skiplot_result (
            p_collection_id => p_collection_id,
            p_shipment_line_id => id.shipment_line_id,
            p_inspected_qty => p_inspected_qty,
            p_total_txn_qty => p_total_txn_qty,
            p_lot_result => lot_result,
            p_shipment_header_id => shl.shipment_header_id,     -- Bug 8678609
            p_rcv_txn_id => shl.transaction_id);                -- Bug 8678609
          end loop;
        end loop;
        p_lot_result := lot_result;

    END;

    --
    -- added p_receipt_num, p_rma_id and p_int_ship_id as parameters
    -- to fix bug 2374625.
    -- Changed static cursor to ref cursor
    -- Also tuned sql query based on po number for better performance
    -- jezheng
    -- Tue May 21 18:24:03 PDT 2002
    --
    PROCEDURE MSCA_PROCESS_SKIPLOT_RESULT (  p_collection_id IN  NUMBER,
                                             p_po_num        IN  VARCHAR2,
                                             p_receipt_num   IN  VARCHAR2,
                                             p_rma_id        IN  NUMBER,
                                             p_int_ship_id   IN  NUMBER,
                                             p_item          IN  VARCHAR2,
                                             p_revision      IN  VARCHAR2,
                                             p_org_id        IN  NUMBER,
                                             p_inspected_qty IN  NUMBER,
                                             p_total_txn_qty IN  NUMBER,
                                             x_lot_result    OUT NOCOPY VARCHAR2) IS
    l_item_id    NUMBER;
    l_lot_result VARCHAR2(30);
    l_shl_id     NUMBER;
    shls_query   VARCHAR2(10000);

    TYPE shls_cur_type is REF CURSOR;
    shls_cur shls_cur_type;

    BEGIN


      l_item_id := QA_FLEX_UTIL.get_item_id(p_org_id, p_item);

      --
      -- RMA Inspection
      --
      if p_rma_id is not null and p_rma_id > 0 then
        shls_query :=
        ' select distinct rs.shipment_line_id  ' ||
        ' from rcv_supply rs, rcv_transactions rt, rcv_shipment_headers rsh  ' ||
        ' where  rsh.receipt_source_code = ''CUSTOMER''  ' ||
        ' and    rs.oe_order_header_id = :1  ' ||
        ' and    rs.to_organization_id = :2  ' ||
        ' and    rs.item_id            = :3  ' ||
        ' and   (rs.item_revision      = :4 OR  ' ||
        '        (rs.item_revision is null and :4 is null ))  ' ||
        ' and    rs.rcv_transaction_id     = rt.transaction_id  ' ||
        ' and    rsh.shipment_header_id    = rs.shipment_header_id  ' ||
        ' and    rt.inspection_status_code = ''NOT INSPECTED''  ' ||
        ' and    rs.supply_type_code       = ''RECEIVING''  ' ||
        ' and    rt.transaction_type       <> ''UNORDERED''  ' ||
        ' and    rt.routing_header_id      = 2 ';

        open shls_cur for shls_query
        using p_rma_id, p_org_id, l_item_id, p_revision, p_revision;

      --
      -- Intransit Shipment Inspection
      --
      elsif p_int_ship_id is not null and p_int_ship_id > 0 then
        shls_query :=
        ' select   distinct rs.shipment_line_id  ' ||
        ' from rcv_supply rs, rcv_transactions rt, rcv_shipment_headers rsh  ' ||
        ' where  rsh.receipt_source_code <> ''VENDOR''  ' ||
        ' and    rs.shipment_header_id = :1  ' ||
        ' and    rs.to_organization_id = :2  ' ||
        ' and    rs.item_id            = :3  ' ||
        ' and    (rs.item_revision     = :4 OR  ' ||
        '        (rs.item_revision is null and :4 is null))  ' ||
        ' and    rs.rcv_transaction_id     = rt.transaction_id  ' ||
        ' and    rsh.shipment_header_id    = rs.shipment_header_id  ' ||
        ' and    rt.inspection_status_code = ''NOT INSPECTED''  ' ||
        ' and    rs.supply_type_code       = ''RECEIVING''  ' ||
        ' and    rt.transaction_type       <> ''UNORDERED''  ' ||
        ' and    rt.routing_header_id      = 2)  ';

        open shls_cur for shls_query
        using p_int_ship_id, p_org_id, l_item_id, p_revision, p_revision;

      --
      -- Inspection based on receipt number
      --
      elsif p_receipt_num is not null then
        shls_query :=
        ' select distinct rsl.shipment_line_id ' ||
        ' from rcv_supply rs,  ' ||
        ' rcv_transactions rt,  ' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
        ' where     rsh.receipt_num           = :1  ' ||
        ' and       rsh.shipment_header_id    = rs.shipment_header_id  ' ||
        ' and       rs.supply_type_code       = ''RECEIVING''  ' ||
        ' and       rs.rcv_transaction_id     = rt.transaction_id  ' ||
        ' and       rt.inspection_status_code = ''NOT INSPECTED''  ' ||
        ' and       rt.transaction_type       <> ''UNORDERED''  ' ||
        ' and       rt.routing_header_id      = 2  ' ||
        ' and       rsh.shipment_header_id    = rsl.shipment_header_id ';

        open shls_cur for shls_query
        using p_receipt_num;

      --
      -- Default: inspection based on PO number
      --
      else
        -- Bug 7699303
        -- Changed the query to include qsrr table to filter out the skipped shipment lines
        -- because inspection_status_code of rt remains at not_inspected' even for skipped
        -- shipment lines.pdube Fri May 15 02:20:44 PDT 2009
        /*shls_query :=
        ' SELECT distinct rs.shipment_line_id ' ||
        ' FROM   rcv_supply rs, rcv_transactions rt, po_headers ph ' ||
        ' WHERE  rs.rcv_transaction_id = rt.transaction_id ' ||
        ' AND    rs.po_header_id = ph.po_header_id ' ||
        ' AND    ph.segment1 = :1 ' ||
        ' AND    rs.to_organization_id = :2 ' ||
        ' AND    rs.item_id = :3 ' ||
        ' AND    (rs.item_revision = :4 OR  ' ||
        '        (rs.item_revision is null AND :4 is null)) ' ||
        ' AND    rt.inspection_status_code = ''NOT INSPECTED'' ';*/
        --
        -- bug 9652549 CLM changes
        --
        shls_query :=
        ' SELECT distinct rs.shipment_line_id ' ||
        ' FROM   rcv_supply rs, rcv_transactions rt,qa_skiplot_rcv_results qsrr , PO_HEADERS_TRX_V ph '||
        ' WHERE  rs.rcv_transaction_id = rt.transaction_id ' ||
        ' AND    rs.po_header_id = ph.po_header_id ' ||
        ' AND    ph.segment1 = :1 ' ||
        ' AND    rs.to_organization_id = :2 ' ||
        ' AND    rs.item_id = :3 ' ||
        ' AND    (rs.item_revision = :4 OR  ' ||
        '        (rs.item_revision is null AND :4 is null)) ' ||
        ' AND    rt.inspection_status_code = ''NOT INSPECTED'' ' ||
        ' AND    qsrr.interface_txn_id =  rt.interface_transaction_id '||
        ' AND    qsrr.inspection_status = ''PENDING'' ';

        open shls_cur for shls_query
        using p_po_num, p_org_id, l_item_id, p_revision, p_revision;

      end if;

      loop
        fetch shls_cur into l_shl_id;

        exit when shls_cur%notfound;

        process_skiplot_result (
        p_collection_id => p_collection_id,
        p_shipment_line_id =>l_shl_id,
        p_inspected_qty => p_inspected_qty,
        p_total_txn_qty => p_total_txn_qty,
        p_lot_result => l_lot_result);
      end loop;

      x_lot_result := l_lot_result;

    END MSCA_PROCESS_SKIPLOT_RESULT;

    --
    -- local function
    -- get previous inspection history information
    --
    procedure get_prev_insp_info (
    p_rcv_txn_id in number,
    p_plan_id in number,
    p_insp_qty out NOCOPY number,
    p_acpt_qty out NOCOPY number,
    p_rej_qty out NOCOPY number) is

    cursor get_coll_id (x_txn_id in number) is
        select qa_collection_id
        from rcv_transactions
        where transaction_id = x_txn_id;

    coll_id number;
    result varchar2(100);

    begin

        open get_coll_id (p_rcv_txn_id);
        fetch get_coll_id into coll_id;
        close get_coll_id;

        result:= get_plan_result (
        coll_id,
        p_plan_id,
        p_insp_qty, -- out parameter
        p_acpt_qty, -- out parameter
        p_rej_qty); -- out parameter

    end get_prev_insp_info;


    PROCEDURE UPDATE_LOT_PLANS(
    p_collection_id IN NUMBER,
    p_insp_lot_id IN NUMBER,
    p_rcv_txn_id IN NUMBER,
    p_shipment_line_id IN NUMBER,
    p_inspected_qty IN NUMBER DEFAULT NULL,
    p_prev_txn_type IN VARCHAR2 DEFAULT NULL,
    p_reinsp_flag IN VARCHAR2 DEFAULT NULL) IS

    cursor lotPlans (x_insp_lot_id number) is
        select *
        from qa_skiplot_lot_plans
        where insp_lot_id = x_insp_lot_id;

    cursor lotPlans2 (x_shl_id number) is
        select *
        from qa_skiplot_lot_plans
        where shipment_line_id = x_shl_id;

    res_col varchar2(30);
    result varchar2(100);
    insp_qty number;
    plan_status varchar2(20);
    sql_str varchar2(3000);
    acpt_qty number;
    rej_qty number;
    prev_insp_qty number;
    prev_acpt_qty number;
    prev_rej_qty number;

    BEGIN

        --
        -- loop through all the plans for the lot
        --

        --
        -- in PO receiving scenario, shipment_line_id is provided
        -- then use shipment_line_id
        -- in other scenario where shipment_line_id does not make sense
        -- use insp_lot_id
        --
        if p_shipment_line_id is not null then
            for lp in lotPlans2(p_shipment_line_id) loop

                --
                -- get plan result and accept and reject quantities
                --
                result := get_plan_result (
                p_collection_id => p_collection_id,
                p_plan_id => lp.plan_id,
                p_insp_qty => insp_qty,
                p_accepted_qty => acpt_qty,
                p_rejected_qty => rej_qty);

                --
                -- re-inspection
                --
                if p_reinsp_flag = fnd_api.g_true then
                    --
                    -- when only part of the lot qty is re-inspected
                    -- we need to get the historical inspection info.
                    -- this typically happens when transfering txn is done
                    -- before inspection
                    --
                    if lp.inspected_qty > insp_qty then
                        get_prev_insp_info (
                        p_rcv_txn_id,
                        lp.plan_id,
                        prev_insp_qty, -- out parameter
                        prev_acpt_qty, -- out parameter
                        prev_rej_qty); -- out parameter

                        acpt_qty := nvl(lp.accepted_qty, 0) - prev_acpt_qty + acpt_qty;
                        rej_qty := nvl(lp.rejected_qty, 0) - prev_rej_qty + rej_qty;
                        if rej_qty > 0 then
                            result := 'REJECT';
                        else
                            result := 'ACCEPT';
                        end if;

                    --
                    -- when total quantity is re-inspected, simply take the
                    -- new result, acpt_qty and rej_qty
                    --
                    else
                        null;
                    end if;

                --
                -- not re-inspection
                --
                else
                    --
                    -- if transfering transaction splits a shipment line
                    -- into multiple lines. As long as one line
                    -- is rejected, the shipment line is rejected.
                    -- i.e. the current result will not override the previous
                    -- 'reject' decision
                    --
                    if lp.plan_insp_result = 'REJECT' then
                        result := 'REJECT';
                    end if;

                    insp_qty := nvl(lp.inspected_qty, 0) + insp_qty;
                    acpt_qty := nvl(lp.accepted_qty, 0) + acpt_qty;
                    rej_qty := nvl(lp.rejected_qty, 0) + rej_qty;

                end if;

                if result is not null then

                    --
                    -- update lot plans table
                    --
                    sql_str := 'update qa_skiplot_lot_plans set ' ||
                    'plan_insp_status = ''INSPECTED'', ' ||
                    'plan_insp_result = :1, ' ||
                    'inspected_qty = :2 ,' ||
                    'accepted_qty = :3, ' ||
                    'rejected_qty = :4, ' ||
                    'collection_id = :5 ' ||
                    'where shipment_line_id = :6 and ' ||
                    'plan_id = :7 ';

                    execute immediate sql_str
                    using result, insp_qty, acpt_qty, rej_qty, p_collection_id,
                    p_shipment_line_id, lp.plan_id;

                end if;

            end loop;
        else -- p_insp_lot_id must be provided
            for lp in lotPlans(p_insp_lot_id) loop

                --
                -- get plan result and accept and reject quantities
                --
                result := get_plan_result (
                p_collection_id => p_collection_id,
                p_plan_id => lp.plan_id,
                p_insp_qty => insp_qty,
                p_accepted_qty => acpt_qty,
                p_rejected_qty => rej_qty);

                --
                -- re-inspection
                --
                if p_reinsp_flag = fnd_api.g_true then
                    --
                    -- Take the latest result, insp_qty, acpt_qty and rej_qty
                    --
                    null;
                --
                -- not re-inspection
                --
                else
                    --
                    -- if transfering transaction splits a shipment line
                    -- into multiple lines. As long as one line
                    -- is rejected, the shipment line is rejected.
                    -- i.e. the current result will not override the previous
                    -- 'reject' decision
                    --
                    if lp.plan_insp_result = 'REJECT' then
                        result := 'REJECT';
                    end if;

                    insp_qty := nvl(lp.inspected_qty, 0) + insp_qty;
                    acpt_qty := nvl(lp.accepted_qty, 0) + acpt_qty;
                    rej_qty := nvl(lp.rejected_qty, 0) + rej_qty;

                end if;

                if result is not null then
                    --
                    -- update lot plans table
                    -- if plan was rejected before, keep the result
                    --
                    sql_str := 'update qa_skiplot_lot_plans set ' ||
                    'plan_insp_status = ''INSPECTED'', ' ||
                    'plan_insp_result = :1, ' ||
                    'inspected_qty = :2 ,' ||
                    'accepted_qty =  :3, ' ||
                    'rejected_qty = :4, ' ||
                    'collection_id = :5 ' ||
                    'where insp_lot_id = :6 and ' ||
                    'plan_id = :7 ';

                    execute immediate sql_str
                    using result, insp_qty, acpt_qty, rej_qty, p_collection_id,
                    p_insp_lot_id, lp.plan_id;

                end if;
            end loop;
        end if;

    EXCEPTION
        WHEN OTHERS THEN
            qa_skiplot_utility.insert_error_log (
            p_module_name => 'QA_SKIPLOT_RES_ENGINE.UPDATE_LOT_PLANS',
            p_error_message => 'QA_SKIPLOT_RES_UPDATE_PLANS_ERR',
            p_comments => SUBSTR (SQLERRM , 1 , 240));
            fnd_message.clear;
            fnd_message.set_name ('QA', 'QA_SKIPLOT_RES_UPDATE_PLANS_ERR');
            APP_EXCEPTION.RAISE_EXCEPTION;

    END UPDATE_LOT_PLANS;

    --
    -- Bug 8678609. FP for Bug 4517387.
    -- Added two new parameters p_shipment_header_id and p_rcv_txn_id to support
    -- skiplot based on ASN's.
    -- skolluku
    --
    PROCEDURE UPDATE_SKIPLOT_RESULT(
    p_collection_id IN NUMBER,
    p_insp_lot_id IN NUMBER DEFAULT NULL,
    p_shipment_line_id IN NUMBER DEFAULT NULL,
    p_total_txn_qty IN NUMBER DEFAULT NULL,
    p_prev_txn_type IN VARCHAR2 DEFAULT NULL,
    p_reinsp_flag IN VARCHAR2 DEFAULT NULL,
    p_shipment_header_id IN NUMBER DEFAULT NULL, -- Added for bug 8678609.
    p_rcv_txn_id IN NUMBER DEFAULT NULL, -- Added for bug 8678609.
    p_criteria_id OUT NOCOPY NUMBER,
    p_lot_plans OUT NOCOPY lotPlanTable,
    p_result OUT NOCOPY VARCHAR2) IS

    c_id NUMBER := null;

    -- values: 'INCOMPLETE', 'REJECT', 'ACCEPT'
    lot_result VARCHAR2(20);

    -- values: 'PENDING', 'INSPECTED'
    lot_status VARCHAR2(20);
    lot_plans lotPlanTable;

    cursor lotPlans (x_insp_lot_id number) is
        select *
        from qa_skiplot_lot_plans
        where insp_lot_id = x_insp_lot_id;

    cursor lotPlans2 (x_shl_id number) is
        select *
        from qa_skiplot_lot_plans
        where shipment_line_id = x_shl_id;

    cursor sampling_result (x_coll_id number) is
        select sampling_flag, lot_result
        from  qa_insp_collections_temp
        where collection_id = x_coll_id;

    sampling_flag varchar2(1);

    -- Bug 8678609. skolluku.
    l_txn_id number := null;
    temp_txn_type varchar2(30);
    temp_parent_txn_id NUMBER;

    BEGIN

        --
        -- fetch the lot plans into pl/sql table
        --

        --
        -- in receiving inspection shipment_line_id will be provided
        -- while in other inspections, insp_lot_id is used because
        -- shipment_line_id does not make sense
        --
        if p_shipment_line_id is not null then
            for lp in lotPlans2 (p_shipment_line_id) loop
                lot_plans (lp.plan_id) := lp;
            end loop;
        else -- insp_lot_id must be provided
            for lp in lotPlans (p_insp_lot_id) loop
                lot_plans (lp.plan_id) := lp;
            end loop;
        end if;

        p_lot_plans := lot_plans;

        open sampling_result (p_collection_id);
        fetch sampling_result into sampling_flag, lot_result;
        close sampling_result;

        --
        -- if not sampling, the lot result need to be calculated.
        --
        if sampling_flag is null or sampling_flag <> 'Y' then

            --
            -- if any plan is rejected, reject the lot
            --
            if is_any_plan_rejected(lot_plans) = fnd_api.g_true then
                lot_result := 'REJECT';
                lot_status := 'INSPECTED';
            --
            -- if some plans are incomplete, lot result can not be decided.
            -- this usually will not happen since we catch them at UI part
            --
            elsif are_all_plans_completed (lot_plans) = fnd_api.g_false then
                lot_result := 'INCOMPLETE';
                lot_status := 'PENDING';
            --
            -- only happens in receiving inspection when transafering
            -- occurs before inspection
            --
            elsif is_lot_qty_finished (p_total_txn_qty, p_shipment_line_id)
                = fnd_api.g_false then
                lot_result := 'ACCEPT';
                lot_status := 'PENDING';
            --
            -- if no rejection, all plans finished and lot qty finished,
            -- accept the lot
            --
            else
                lot_result := 'ACCEPT';
                lot_status := 'INSPECTED';
            end if;
        else
            lot_status := 'INSPECTED';
        end if;

            --
            -- If there are incomplete inspection plans and no rejection found,
            -- the lot result can not be decided.
            -- Do not update skiplot result table.
            --

        if lot_result <> 'INCOMPLETE' then

            --
            -- if original inspection result is rejected, keep it.
            -- current transacted qty needs to be added to original
            -- transacted_qty
            --

            --
            -- if shipment_line_id is provided, use it,
            -- otherwise use insp_lot_id
            --
            -- valid_flag = 3 indicate result is entered, but invalid
            -- after the parent txn goes through fine, the result will
            -- be set to valid_flag = 4 indicating valid
            --

            if p_shipment_line_id is not null then
                --
                --
                /*
                   Bug 8678609. FP for Bug 4517387.

                   For receipts made against ASN the shipment line is created already
                   and no new shipment line will be generated when creating receipts.
                   The shipment_line_id will always be the same. So the existing update
                   statement based on shipment_line_id would error out(multiple rows
                   would be fetched) when skiplot is done for ASN's. So using the new
                   parameters p_shipment_header_id, p_rcv_txn_id and the existing
                   p_shipment_line_id we can identify the interface_transaction_id
                   which in turn can be used in combination with p_shipment_line_id
                   to identify a unique row in qa_skiplot_rcv_results. The existing
                   update statement would work for Receipts against Purchase Orders
                   in which seperate shipment line will be created for each Receipt.

                   In the where clause i have used "interface_txn_id IS NULL" to prevent
                   any exceptions if p_shipment_header_id and p_rcv_txn_id are not passed.
                   There are couple of occurrences in this file itself where p_shipment_header_id
                   and p_rcv_txn_id would not be passed(Check overloaded PROCESS_SKIPLOT_RESULT
                   and MSCA_PROCESS_SKIPLOT_RESULT which call process_skiplot_result which
                   in turn calls this procedure).

                */

                IF ((p_shipment_header_id IS NOT NULL) AND (p_rcv_txn_id IS NOT NULL)) THEN

                    SELECT INTERFACE_TRANSACTION_ID,
                           parent_transaction_id,
                           transaction_type
                    INTO l_txn_id,
                         temp_parent_txn_id,
                         temp_txn_type
                    FROM RCV_TRANSACTIONS
                    WHERE SHIPMENT_LINE_ID = p_shipment_line_id
                    AND SHIPMENT_HEADER_ID = p_shipment_header_id
                            AND TRANSACTION_ID = p_rcv_txn_id;

                    IF temp_txn_type = 'TRANSFER' THEN
                            SELECT INTERFACE_TRANSACTION_ID into l_txn_id
                            FROM (SELECT INTERFACE_TRANSACTION_ID , transaction_type
                                    FROM RCV_TRANSACTIONS
                                  START WITH transaction_id = temp_parent_txn_id
                                  CONNECT BY PRIOR parent_transaction_id = transaction_id)
                            WHERE transaction_type = 'RECEIVE';
                    END IF;
                --
                -- Bug 8678609. FP for Bug 7557274.
                -- Added this else part of the query to fetch the correct value of
                -- intf_txn_id based on shipment_line_id for Non-ASN cases.
                -- In case of MSCA+ASN case, only one receipt will have multiple
                -- shipment_line_id(s) linked to it.This case is more like a functional
                -- gap.In order to prevent system raising an exception here, introducing
                -- exception handler, which will avoid failing the transaction here.
                -- For details refer bug#7633101.
                --
                ELSE
                    BEGIN
                            SELECT INTERFACE_TRANSACTION_ID into l_txn_id
                            FROM RCV_TRANSACTIONS
                            WHERE SHIPMENT_LINE_ID = p_shipment_line_id;
                    EXCEPTION WHEN TOO_MANY_ROWS THEN
                            NULL;
                    END;
                END IF;

                update qa_skiplot_rcv_results
                set inspection_status = lot_status,
                inspection_result = decode(p_reinsp_flag, fnd_api.g_true, lot_result,
                                           decode (inspection_result, 'REJECT', 'REJECT', lot_result)),
                transacted_qty =  decode (p_reinsp_flag, fnd_api.g_true, transacted_qty,
                                          (nvl(transacted_qty, 0) + nvl(p_total_txn_qty, 0))),
                last_insp_date = sysdate,
                valid_flag = 2,
                last_update_date = sysdate,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
                where shipment_line_id = p_shipment_line_id
                    and (interface_txn_id IS NULL or interface_txn_id = l_txn_id)
                returning criteria_id, inspection_result into c_id, lot_result;

                 /* End of inclusion for bug 8678609. */
            else
                update qa_skiplot_rcv_results
                set inspection_status = lot_status,
                inspection_result = decode(p_reinsp_flag, fnd_api.g_true, lot_result,
                                           decode (inspection_result, 'REJECT', 'REJECT', lot_result)),
                transacted_qty =  decode(p_reinsp_flag, fnd_api.g_true, transacted_qty,
                                         (nvl(transacted_qty, 0) + nvl(p_total_txn_qty, 0))),
                last_insp_date = sysdate,
                valid_flag = 2,
                last_update_date = sysdate,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
                where insp_lot_id = p_insp_lot_id
                returning criteria_id, inspection_result into c_id, lot_result;
            end if;
        end if;

        p_criteria_id := nvl(c_id, -1);
        p_result := lot_result;


    EXCEPTION
        WHEN OTHERS THEN
            qa_skiplot_utility.insert_error_log (
            p_module_name => 'QA_SKIPLOT_RES_ENGINE.UPDATE_SKIPLOT_RESULT',
            p_error_message => 'QA_SKIPLOT_RES_UPDATE_RESULT_ERR',
            p_comments => SUBSTR (SQLERRM , 1 , 240));
            fnd_message.clear;
            fnd_message.set_name ('QA', 'QA_SKIPLOT_RES_UPDATE_RESULT_ERR');
            APP_EXCEPTION.RAISE_EXCEPTION;

    END UPDATE_SKIPLOT_RESULT;


    PROCEDURE UPDATE_PLAN_STATE(
    p_insp_result IN VARCHAR2,
    p_criteria_id IN NUMBER,
    p_process_id IN NUMBER,
    p_lot_plan IN lot_plan_rec,
    p_txn IN NUMBER,
    p_prev_txn_type IN VARCHAR2 DEFAULT NULL,
    p_reinsp_flag IN VARCHAR2 DEFAULT NULL) IS

    plan_state qa_skiplot_utility.plan_state_rec;
    forward_lot number;
    pp_id number;
    next_rule number;

    BEGIN

        qa_skiplot_utility.fetch_plan_state(
        p_plan_id => p_lot_plan.plan_id,
        p_criteria_id => p_criteria_id,
        p_process_id => p_process_id,
        p_txn => p_txn,
        p_plan_state => plan_state);

        --
        -- re-inspection
        --
        if p_reinsp_flag = fnd_api.g_true then
            if p_prev_txn_type = 'ACCEPT' and p_insp_result = 'REJECT' then
                --
                -- reset plan states if re-inspection failed
                --
                qa_skiplot_utility.init_plan_state(
                p_plan_id => p_lot_plan.plan_id,
                p_criteria_id => p_criteria_id,
                p_process_id => plan_state.process_id,
                p_lot_id => p_lot_plan.insp_lot_id,
                p_txn => p_txn,
                p_process_plan_id => pp_id); -- out parameter

            end if;
        --
        -- 1st inspection
        --
        elsif p_insp_result = 'REJECT' then
            --
            -- if lot is rejected, reset every inspection plan state
            --
            qa_skiplot_utility.init_plan_state(
            p_plan_id => p_lot_plan.plan_id,
            p_criteria_id => p_criteria_id,
            p_process_id => plan_state.process_id,
            p_lot_id => p_lot_plan.insp_lot_id,
            p_txn => p_txn,
            p_process_plan_id => pp_id); -- out parameter

        --
        -- if round is not finished, update the round parameters
        --
        elsif qa_skiplot_utility.insp_round_finished(plan_state)
            = fnd_api.g_false then

            if qa_skiplot_utility.enough_lot_accepted (plan_state)
            = fnd_api.g_false then
                forward_lot := 1;
            --
            -- if this is over inspection, do not forward the
            -- current lot pointer
            --
            else
                forward_lot := 0;
            end if;

            qa_skiplot_utility.update_plan_state(
            p_process_plan_id => plan_state.process_plan_id,
            p_criteria_id => plan_state.criteria_id,
            p_next_lot => plan_state.current_lot + forward_lot,
            p_lot_accepted => plan_state.lot_accepted + 1,
            p_txn => p_txn);


        --
        -- if this round is done and there are more rounds or
        -- if this rule is done and there are no more rules or
        -- if date span exceeded then
        -- start a new round for this rule
        --
        elsif qa_skiplot_utility.more_rounds(plan_state)
             = fnd_api.g_true OR
             qa_skiplot_utility.get_next_insp_rule(plan_state) = -1 OR
             qa_skiplot_utility.date_reasonable (
             p_check_mode => qa_skiplot_utility.DATE_SPAN_CHECK,
             p_plan_state => plan_state) = fnd_api.g_false then

            qa_skiplot_utility.update_plan_state(
            p_process_plan_id => plan_state.process_plan_id,
            p_criteria_id => plan_state.criteria_id,
            p_next_round => plan_state.current_round + 1,
            p_next_lot => 1,
            p_lot_accepted => 1,
            p_txn => p_txn);


        --
        -- if this rule is finished and there are more rules and
        -- date span is reasonable
        -- then go to next rule
        --
        else
            next_rule := qa_skiplot_utility.get_next_insp_rule(plan_state);

            qa_skiplot_utility.update_plan_state(
            p_process_plan_id => plan_state.process_plan_id,
            p_criteria_id => plan_state.criteria_id,
            p_next_rule => next_rule,
            p_next_round => 1,
            p_next_lot => 1,
            p_lot_accepted => 1,
            p_txn => p_txn);

        end if;
    EXCEPTION
        WHEN OTHERS THEN
            qa_skiplot_utility.insert_error_log (
            p_module_name => 'QA_SKIPLOT_RES_ENGINE.UPDATE_PLAN_STATE',
            p_error_message => 'QA_SKIPLOT_RES_UPDATE_STATE_ERR',
            p_comments => SUBSTR (SQLERRM , 1 , 240));
            fnd_message.clear;
            fnd_message.set_name ('QA', 'QA_SKIPLOT_RES_UPDATE_STATE_ERR');
            APP_EXCEPTION.RAISE_EXCEPTION;

    END UPDATE_PLAN_STATE;

    FUNCTION GET_SKIPLOT_FLAG (
    p_collection_id IN NUMBER) RETURN VARCHAR2 IS

    cursor skiplot_flag (x_coll_id number) is
        select skiplot_flag
        from qa_insp_collections_temp
        where collection_id = x_coll_id;

    x_skiplot_flag varchar2(1) := null;

    BEGIN
        open skiplot_flag (p_collection_id);
        fetch skiplot_flag into x_skiplot_flag;
        close skiplot_flag;

        if x_skiplot_flag = 'Y' then
            return fnd_api.g_true;
        elsif x_skiplot_flag = 'N' then
            return fnd_api.g_false;
        else
            return null;
        end if;

    END GET_SKIPLOT_FLAG;

    PROCEDURE SET_SKIPLOT_FLAG(
    p_collection_id IN NUMBER,
    p_skiplot_flag IN VARCHAR2) IS

    BEGIN

        update qa_insp_collections_temp
        set skiplot_flag = decode(p_skiplot_flag, 'T', 'Y','Y', 'Y', 'N')
        where collection_id = p_collection_id;

    END SET_SKIPLOT_FLAG;

    --
    -- local function
    --
    function get_rejected_qty(
    p_collection_id in number,
    p_lot_qty in number) return number is

    cursor rej_qty(x_coll_id number) is
        select sum(rejected_qty)
        from qa_skiplot_lot_plans
        where collection_id = x_coll_id;

    x_rej_qty number;

    begin
        open rej_qty (p_collection_id);
        fetch rej_qty into x_rej_qty;
        close rej_qty;

        if x_rej_qty is null then
            return 0;
        elsif x_rej_qty > p_lot_qty then
            return p_lot_qty;
        else
            return x_rej_qty;
        end if;
    end get_rejected_qty;


    PROCEDURE LAUNCH_SHIPMENT_ACTION (
    p_po_txn_processor_mode IN VARCHAR2,
    p_po_group_id IN NUMBER,
    p_collection_id IN NUMBER,
    p_employee_id IN NUMBER,
    p_transaction_id IN NUMBER,
    p_uom IN VARCHAR2,
    p_lotsize IN NUMBER,
    p_transaction_date IN DATE,
    p_created_by IN NUMBER,
    p_last_updated_by IN NUMBER,
    p_last_update_login IN NUMBER) IS

    x_rejected_qty number;
    x_accepted_qty number;

    x_return_status varchar2(5);
    x_msg_count number;
    x_msg_data varchar2(2400);

    -- kmqa
    CURSOR plan_count_cur IS
      select count(*) AS insp_plans
      from   qa_insp_plans_temp
      where  collection_id = p_collection_id;

    l_plan_count    NUMBER;

    -- Bug 8806035.ntungare
    -- Added this cursor and variable for copying the supplier lot number information.
    CURSOR vend_lot_num (txn_id NUMBER) IS
        SELECT vendor_lot_num
        FROM rcv_transactions
        WHERE transaction_id = txn_id;
    l_vendor_lot_num VARCHAR2(30) := NULL;


    BEGIN

        OPEN plan_count_cur;
        FETCH plan_count_cur INTO l_plan_count;
        CLOSE plan_count_cur;

        -- Bug 8806035.ntungare
        -- Added this cursor to fetch
        OPEN vend_lot_num(p_transaction_id);
        FETCH vend_lot_num INTO l_vendor_lot_num;
        CLOSE vend_lot_num;

        -- If the Receiving Inspection involves only one Inspection Collection
        -- Plan, call the new procedure. This procedure supports unit wise
        -- inspection at lpn, lot and Serial levels.

        IF (l_plan_count = 1) THEN

           launch_shipment_action_int
             (p_po_txn_processor_mode => p_po_txn_processor_mode,
              p_po_group_id           => p_po_group_id,
              p_collection_id         => p_collection_id,
              p_employee_id           => p_employee_id,
              p_transaction_id        => p_transaction_id,
              p_uom                   => p_uom,
              p_transaction_date      => p_transaction_date,
              p_created_by            => p_created_by,
              p_last_updated_by       => p_last_updated_by,
              p_last_update_login     => p_last_update_login);

           -- No Need to continue as the Inspections are completed.
           -- Return from the procedure.
           return;

        END IF;


        x_rejected_qty := get_rejected_qty(p_collection_id,p_lotsize);
        x_accepted_qty := p_lotsize - x_rejected_qty;

        --
        -- launch rejection action for rejected quantity
        --

        --
        -- modified p_commit values from 'T' to 'F' to fix
        -- bug 2056343. If p_commit = 'T', PO will commit the
        -- work and the skiplot temp table will be cleared
        -- and the skiplot flag will not be available
        -- any more.
        -- this procedure is called in post-forms-commit
        -- the transaction will be committed anyway when the
        -- forms is committed. So no need to commit here.
        -- jezheng
        -- Mon Nov 12 14:12:44 PST 2001
        --

        -- Modified the API call for RCV/EMS merge.
        -- p_api_version changed to 1.1. Also added p_lpn_id and
        -- p_transfer_lpn_id. Passed as NULL.
        -- kabalakr Thu Aug 28 08:34:59 PDT 2003.

        if x_rejected_qty > 0 then
            RCV_INSPECTION_GRP.INSERT_INSPECTION(
            p_api_version           => 1.1,
            p_init_msg_list         => NULL,
            p_commit                => 'F',
            p_validation_level      => NULL,
            p_created_by            => p_created_by,
            p_last_updated_by       => p_last_updated_by,
            p_last_update_login     => p_last_update_login,
            p_employee_id           => p_employee_id,
            p_group_id              => p_po_group_id,
            p_transaction_id        => p_transaction_id,
            p_transaction_type      => 'REJECT',
            p_processing_mode       => p_po_txn_processor_mode,
            p_quantity              => x_rejected_qty,
            p_uom                   => p_uom,
            p_quality_code          => null,
            p_transaction_date      => p_transaction_date,
            p_comments              => null,
            p_reason_id             => null,
            p_vendor_lot            => l_vendor_lot_num, -- Bug 8806035
            p_lpn_id                => null,
            p_transfer_lpn_id       => null,
            p_qa_collection_id      => p_collection_id,
            p_return_status         => x_return_status,
            p_msg_count             => x_msg_count,
            p_msg_data              => x_msg_data);
        end if;

        if x_return_status <> 'S' then
            qa_skiplot_utility.insert_error_log (
            p_module_name => 'QA_SKIPLOT_RES_ENGINE.LAUNCH_SHIPMENT_ACTION',
            p_error_message => 'QA_SKIPLOT_REJECTION_ACTION_ERROR',
            p_comments => x_msg_data);
            fnd_message.clear;
            fnd_message.set_name ('QA', 'QA_SKIPLOT_LAUNCH_ACTION_ERROR');
            APP_EXCEPTION.RAISE_EXCEPTION;
        end if;

        --
        -- launch acceptance action for accepted qty
        --
        if x_accepted_qty > 0 then
            RCV_INSPECTION_GRP.INSERT_INSPECTION(
            p_api_version           => 1.1,
            p_init_msg_list         => NULL,
            p_commit                => 'F',
            p_validation_level      => NULL,
            p_created_by            => p_created_by,
            p_last_updated_by       => p_last_updated_by,
            p_last_update_login     => p_last_update_login,
            p_employee_id           => p_employee_id,
            p_group_id              => p_po_group_id,
            p_transaction_id        => p_transaction_id,
            p_transaction_type      => 'ACCEPT',
            p_processing_mode       => p_po_txn_processor_mode,
            p_quantity              => x_accepted_qty,
            p_uom                   => p_uom,
            p_quality_code          => null,
            p_transaction_date      => p_transaction_date,
            p_comments              => null,
            p_reason_id             => null,
            p_vendor_lot            => l_vendor_lot_num, -- Bug 8806035
            p_lpn_id                => null,
            p_transfer_lpn_id       => null,
            p_qa_collection_id      => p_collection_id,
            p_return_status         => x_return_status,
            p_msg_count             => x_msg_count,
            p_msg_data              => x_msg_data);
        end if;
        if x_return_status <> 'S' then
            qa_skiplot_utility.insert_error_log (
            p_module_name => 'QA_SKIPLOT_RES_ENGINE.LAUNCH_SHIPMENT_ACTION',
            p_error_message => 'QA_SKIPLOT_ACCEPTANCE_ACTION_ERROR',
            p_comments => x_msg_data);
            fnd_message.clear;
            fnd_message.set_name ('QA', 'QA_SKIPLOT_LAUNCH_ACTION_ERROR');
            APP_EXCEPTION.RAISE_EXCEPTION;
        end if;


    END LAUNCH_SHIPMENT_ACTION;

    PROCEDURE CALCULATE_QUANT_RESULT (
    p_collection_id IN NUMBER,
    p_lotqty IN NUMBER,
    p_rej_qty OUT NOCOPY NUMBER,
    p_acc_qty OUT NOCOPY NUMBER) IS


    BEGIN

       p_rej_qty := get_rejected_qty (
                    p_collection_id,
                    p_lotqty);

       p_acc_qty := p_lotqty - p_rej_qty;

    END CALCULATE_QUANT_RESULT;

/*
  anagarwa Wed Apr 10 12:48:10 PDT 2002
  Qa MSCA: Following method should actually be placed in qltutlfb.pls
  But due to GSCC error for qltutlfb.pls, I'm putting it here. The related bug
  is 2312644.
  Whenever this is moved back to qltutlfb.pls, the java file
  $QA_TOP/java/util/ContextElementTable.java should be changed
*/

FUNCTION get_asl_status(p_org_id NUMBER,
                        p_po_num VARCHAR2,
                        p_item_id NUMBER) RETURN VARCHAR2 IS

-- Bug 4958740.  SQL Repository Fix SQL ID: 15008408
--
-- bug 9652549 CLM changes
--
CURSOR c(c_org_id NUMBER, c_po_num VARCHAR2, c_item_id NUMBER) IS
SELECT past.status
FROM   po_approved_supplier_list pasl,
       po_asl_statuses past,
       PO_HEADERS_TRX_V ph
WHERE  ph.segment1 = c_po_num AND
       ph.vendor_id = pasl.vendor_id(+) AND
       ph.vendor_site_id = pasl.vendor_site_id(+) AND
       pasl.using_organization_id = c_org_id AND
       pasl.item_id = c_item_id AND
       pasl.asl_status_id = past.status_id(+);

/*
        select asl_status_dsp
        from   po_asl_suppliers_v pasv,
               po_headers ph
        where  ph.segment1 = c_po_num
        and    ph.vendor_id = pasv.vendor_id(+)
        and    ph.vendor_site_id = pasv.vendor_site_id(+)
        and    pasv.using_organization_id = c_org_id
        and    pasv.item_id = c_item_id;
*/

x_asl_status VARCHAR2(100);

BEGIN

        IF ((p_org_id IS NULL) or (p_po_num is null))  THEN
            RETURN NULL;
        END IF;

        OPEN c(p_org_id, p_po_num, p_item_id);
        FETCH c INTO x_asl_status;
        CLOSE c;

        RETURN x_asl_status;

END get_asl_status;



END QA_SKIPLOT_RES_ENGINE;


/
