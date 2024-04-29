--------------------------------------------------------
--  DDL for Package Body QA_INSPECTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_INSPECTION_PKG" AS
/* $Header: qainspb.pls 120.0.12000000.2 2007/04/23 12:18:39 skolluku ship $ */


    PROCEDURE INIT_COLLECTION (
    p_collection_id IN NUMBER,
    p_lot_size IN NUMBER,
    p_coll_plan_id IN NUMBER,
    p_uom_name IN VARCHAR2) IS

    dummy NUMBER;

    cursor qict_cur is
        select 1
        from qa_insp_collections_temp
        where collection_id = p_collection_id;

    cursor qipt_cur is
        select 1
        from qa_insp_plans_temp
        where collection_id = p_collection_id
        and plan_id = p_coll_plan_id;

    BEGIN

	--code needs to be added here to check if these records already exist
	--if they do exist then dont insert again.

        --
        -- Bug 5926256
        -- Commented the below code
        -- skolluku Wed Apr 18 03:15:08 PDT 2007
        --
/*
	open qict_cur;
	fetch qict_cur into dummy;
	if (qict_cur%notfound) then

		insert into qa_insp_collections_temp
		(collection_id, lot_size, transaction_uom,lot_result)
		values
		(p_collection_id, p_lot_size, p_uom_name, null);
	end if;
	close qict_cur;
*/
        --
        -- Bug 5926256
        -- Delete existing rows for this collection id
        -- and insert the values for the next item.
        -- skolluku  Wed Apr 18 03:15:08 PDT 2007
        --
        delete from qa_insp_collections_temp
        where collection_id = p_collection_id;

        insert into qa_insp_collections_temp
        (collection_id, lot_size, transaction_uom,lot_result)
        values
        (p_collection_id, p_lot_size, p_uom_name, null);

	open qipt_cur;
	fetch qipt_cur into dummy;
	if (qipt_cur%notfound) then

		insert into qa_insp_plans_temp
		(collection_id, plan_id, sampling_plan_id, sample_size,
		 c_number, rejection_number, aql, plan_insp_result)
		values
		(p_collection_id, p_coll_plan_id, -1, null,
		 null, null, null, null);

	end if;
	close qipt_cur;

    END INIT_COLLECTION;


    PROCEDURE LAUNCH_SHIPMENT_ACTION(
    p_po_processor_mode IN VARCHAR2,
    p_group_id IN NUMBER,
    p_employee_id IN NUMBER) IS

    cursor collection is
        select collection_id,
        sampling_flag,
        skiplot_flag,
        lot_size,
        transaction_uom
        from qa_insp_collections_temp;

    --
    -- this information is needed by PO API
    -- PO API is writen for unit-by-unit inspection
    -- these information may be different for records,
    -- but this is only corner case. We don't consider
    -- this case here.  We reasonably assume that the
    -- following information is the same for all records
    -- in one collection.
    --
    cursor info (x_coll_id number) is
        select transaction_id,
        transaction_date,
        created_by,
        last_updated_by,
        last_update_login
        from qa_results
        where collection_id = x_coll_id and
        transaction_id is not null and
        rownum =1;

    x_txn_id number;
    x_transaction_date date;
    x_created_by number;
    x_last_updated_by number;
    x_last_update_login number;
    x_lotsize number;

    BEGIN
        for c in collection loop
            open info (c.collection_id);
            fetch info into x_txn_id, x_transaction_date,
            x_created_by, x_last_updated_by, x_last_update_login;
            close info;

            x_lotsize := c.lot_size;

            if c.sampling_flag = 'Y' then

qa_skiplot_utility.insert_error_log (
p_module_name => 'QA_INSPECTION_PKG.launch_shipment_action',
p_comments => 'sampling_flag  =  y' );

                qa_sampling_pkg.launch_shipment_action(
                p_po_txn_processor_mode =>  p_po_processor_mode,
                p_po_group_id => p_group_id,
                p_collection_id => c.collection_id,
                p_employee_id => p_employee_id,
                p_transaction_id => x_txn_id,
                p_uom => c.transaction_uom,
                p_transaction_date => x_transaction_date,
                p_created_by => x_created_by,
                p_last_updated_by => x_last_updated_by,
                p_last_update_login => x_last_update_login);
            elsif c.skiplot_flag = 'Y' then

qa_skiplot_utility.insert_error_log (
p_module_name => 'QA_INSPECTION_PKG.launch_shipment_action',
p_comments => 'skiplot_flag  =  y' );

                qa_skiplot_res_engine.launch_shipment_action(
                p_po_txn_processor_mode =>  p_po_processor_mode,
                p_po_group_id => p_group_id,
                p_collection_id => c.collection_id,
                p_employee_id => p_employee_id,
                p_transaction_id => x_txn_id,
                p_uom => c.transaction_uom,
                p_lotsize => x_lotsize,
                p_transaction_date => x_transaction_date,
                p_created_by => x_created_by,
                p_last_updated_by => x_last_updated_by,
                p_last_update_login => x_last_update_login);
            else
                --
                -- normal inspection
                -- action is handled in qltdactb.plb, so no code here
                null;
            end if;
        end loop;

    END LAUNCH_SHIPMENT_ACTION;

    FUNCTION IS_REGULAR_INSP (
    p_collection_id IN NUMBER) RETURN VARCHAR2 IS

    BEGIN
        if is_sampling_insp(p_collection_id) = fnd_api.g_true  or
           is_skiplot_insp (p_collection_id) = fnd_api.g_true then
            return fnd_api.g_false;
        else
            return fnd_api.g_true;
        end if;
    END IS_REGULAR_INSP;

    FUNCTION IS_SAMPLING_INSP(
    p_collection_id IN NUMBER) RETURN VARCHAR2 IS

    cursor sampling_flag (x_coll_id number) is
        select sampling_flag
        from qa_insp_collections_temp
        where collection_id = x_coll_id;

    x_sampling_flag VARCHAR2(1);

    BEGIN
        open sampling_flag (p_collection_id);
        fetch sampling_flag into x_sampling_flag;
        close sampling_flag;

        if x_sampling_flag = 'Y' then
            return fnd_api.g_true;
        else
            return fnd_api.g_false;
        end if;
    END IS_SAMPLING_INSP;

    FUNCTION IS_SKIPLOT_INSP(
    p_collection_id IN NUMBER) RETURN VARCHAR2 IS

    cursor skiplot_flag (x_coll_id number) is
        select skiplot_flag
        from qa_insp_collections_temp
        where collection_id = x_coll_id;

    x_skiplot_flag VARCHAR2(1);

    BEGIN
        open skiplot_flag (p_collection_id);
        fetch skiplot_flag into x_skiplot_flag;
        close skiplot_flag;

        if x_skiplot_flag = 'Y' then
            return fnd_api.g_true;
        else
            return fnd_api.g_false;
        end if;
    END IS_SKIPLOT_INSP;

    FUNCTION QA_INSTALLATION RETURN VARCHAR2 IS

    l_status   varchar2(1);
    l_industry varchar2(10);
    l_schema   varchar2(30);
    dummy boolean;

    BEGIN
        dummy := fnd_installation.get_app_info('QA', l_status,
        l_industry, l_schema);

        --
        -- l_status will be 'I' if installed or 'N' if not.
        -- Bug 1685697.  Status will be 'S' if shared installed.
        --
        if l_status in ('I', 'S') then

            return fnd_api.g_true;
        else
            return fnd_api.g_false;
        end if;

    END QA_INSTALLATION;

    FUNCTION QA_INSPECTION RETURN VARCHAR2 IS

    BEGIN
        if FND_PROFILE.VALUE('QA_PO_INSPECTION') = 1 then
            return fnd_api.g_true;
        else
            return fnd_api.g_false;
        end if;
    END QA_INSPECTION;

END QA_INSPECTION_PKG;


/
