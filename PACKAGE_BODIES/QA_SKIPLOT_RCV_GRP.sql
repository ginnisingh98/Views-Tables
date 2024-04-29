--------------------------------------------------------
--  DDL for Package Body QA_SKIPLOT_RCV_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_SKIPLOT_RCV_GRP" AS
/* $Header: qaslrcvb.pls 120.0.12000000.2 2007/07/05 11:35:26 bhsankar ship $ */

    g_pkg_name  CONSTANT VARCHAR2(30):= 'QA_SKIPLOT_RCV_GRP';

    PROCEDURE CHECK_AVAILABILITY
    (p_api_version IN NUMBER,  -- 1.0
    p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_validation_level IN VARCHAR2 DEFAULT FND_API.G_VALID_LEVEL_FULL,
    p_organization_id IN NUMBER,
    x_qa_availability OUT NOCOPY VARCHAR2, -- return fnd_api.g_true/false
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2) IS


    l_api_version   CONSTANT NUMBER := 1.0;
    l_api_name  CONSTANT VARCHAR2(30):= 'CHECK_AVAILABILITY';
    l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(240);

    BEGIN

        --
        -- standard start of API savepoint
        --
        SAVEPOINT check_availability_pub;

        --
        -- standard call to check for call compatibility.
        --
        if not fnd_api.compatible_api_call (
            l_api_version,
            p_api_version,
            l_api_name,
            g_pkg_name) then
            raise fnd_api.g_exc_unexpected_error;
        end if;

        --
        -- initialize message list if p_init_msg_list is set to TRUE.
        --
        if fnd_api.to_boolean(p_init_msg_list) then
            fnd_msg_pub.initialize;
        end if;


        --
        --  Initialize API return status to success
        --
        x_return_status := fnd_api.g_ret_sts_success;

        x_qa_availability := qa_skiplot_utility.check_skiplot_availability(
                             qa_skiplot_utility.RCV,
                             p_organization_id);

            qa_skiplot_utility.insert_error_log (
            p_module_name => 'QA_SKIPLOT_RCV_GRP.CHECK_AVAILABILITY',
            p_error_message => 'no error ',
            p_comments => 'availability=' || x_qa_availability);



    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := fnd_api.g_ret_sts_error;

            qa_skiplot_utility.insert_error_log (
            p_module_name => 'QA_SKIPLOT_RCV_GRP.CHECK_AVAILABILITY',
            p_error_message => 'FND_API.G_EXC_ERROR ',
            p_comments => SUBSTR (SQLERRM , 1 , 240));

            --
            --  get message count and data
            --
            fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data);

            x_qa_availability := fnd_api.g_false;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error ;

            qa_skiplot_utility.insert_error_log (
            p_module_name => 'QA_SKIPLOT_RCV_GRP.CHECK_AVAILABILITY',
            p_error_message => 'FND_API.G_EXC_UNEXPECTED_ERROR',
            p_comments => SUBSTR (SQLERRM , 1 , 240));

            --
            --  get message count and data
            --
            fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data);

            x_qa_availability := fnd_api.g_false;

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
                fnd_msg_pub.add_exc_msg (g_pkg_name , l_api_name);
            end if;

            qa_skiplot_utility.insert_error_log (
            p_module_name => 'QA_SKIPLOT_RCV_GRP.CHECK_AVAILABILITY',
            p_error_message => 'OTHERS exception',
            p_comments => SUBSTR (SQLERRM , 1 , 240));

            --
            --  get message count and data
            --
            fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data);

            x_qa_availability := fnd_api.g_false;

    END CHECK_AVAILABILITY;

    --
    -- local function
    --
    procedure get_project_task (
    p_po_distribution_id in number,
    p_po_line_location_id in number,
    p_project_id out NOCOPY number,
    p_task_id out NOCOPY number) is

    --
    -- select from po_distributions_all so that
    -- current organization need not to be considered
    --

    --
    -- in PO receipt form, when a po line location has
    -- only one distribution, the po_distribution_id is
    -- populated, otherwise it is null
    -- when the po_distribution_id is provided, we use
    -- it to derive project and task ids, otherwise we
    -- use po_line_location_id
    -- one po_line_location_id may contain multiple po
    -- distributions, thus multiple project/task pair
    -- skiplot engine only consider the situtaion when
    -- one line location has only one distribution case
    -- reference P1 2141280
    -- jezheng
    -- Fri Dec 14 11:28:49 PST 2001
    --

    cursor project_task (x_distribution_id number) is
        select project_id, task_id
        from po_distributions_all
        where po_distribution_id = x_distribution_id;

    cursor project_task2 (x_line_location_id number) is
        select project_id, task_id
        from po_distributions_all
        where line_location_id = x_line_location_id;

    counter number := 0;

    begin

        if p_po_distribution_id is not null then
            open project_task (p_po_distribution_id);
            fetch project_task into p_project_id, p_task_id;
            close project_task;

        elsif p_po_line_location_id is not null then
            for pt in project_task2 (p_po_line_location_id) loop
                p_project_id := pt.project_id;
                p_task_id := pt.task_id;
                counter := counter + 1;
            end loop;


            --
            -- one po line location may have multiple po distributions
            -- each of them may have one project/task pair
            -- skiplot does not support this case
            -- reference p1 2141280
            --
            if counter = 0 or counter = 1 then
                p_project_id := null;
                p_task_id := null;
            end if;
        end if;

    end get_project_task;

    PROCEDURE EVALUATE_LOT
    (p_api_version IN NUMBER,  -- 1.0
    p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_validation_level IN VARCHAR2 DEFAULT FND_API.G_VALID_LEVEL_FULL,
    p_interface_txn_id IN NUMBER,
    p_organization_id IN NUMBER,
    p_vendor_id IN NUMBER,
    p_vendor_site_id IN NUMBER,
    p_item_id IN NUMBER,
    p_item_revision IN VARCHAR2,
    p_item_category_id IN NUMBER,
    p_project_id IN NUMBER,
    p_task_id IN NUMBER,
    p_manufacturer_id IN NUMBER,
    p_source_inspected IN NUMBER,
    p_receipt_qty IN NUMBER,
    p_receipt_date IN DATE,
    p_primary_uom IN varchar2 DEFAULT null,
    p_transaction_uom IN varchar2 DEFAULT null,
    p_po_header_id IN NUMBER DEFAULT null,
    p_po_line_id IN NUMBER DEFAULT null,
    p_po_line_location_id IN NUMBER DEFAULT null,
    p_po_distribution_id IN NUMBER DEFAULT null,
    p_lpn_id IN NUMBER DEFAULT null,
    p_wms_flag IN VARCHAR2 DEFAULT 'N',
    x_evaluation_result OUT NOCOPY VARCHAR2, -- returns INSPECTor STANDARD
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2) IS

    PRAGMA AUTONOMOUS_TRANSACTION;

    l_api_version   CONSTANT NUMBER := 1.0;
    l_api_name  CONSTANT VARCHAR2(30):= 'EVALUATE_LOT';
    l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(500);

    SOURCE_INSPECTED CONSTANT NUMBER := 1;
    applicablePlans qa_skiplot_utility.planList;
    availablePlans qa_skiplot_utility.planList;
    lotID NUMBER;
    criteriaID NUMBER;
    processID NUMBER;
    insp_status VARCHAR2(10);
    project_id number;
    task_id number;

    BEGIN

        --
        -- standard start of API savepoint
        --
        SAVEPOINT check_availability_pub;

        --
        -- standard call to check for call compatibility.
        --
        if not fnd_api.compatible_api_call (
            l_api_version,
            p_api_version,
            l_api_name,
            g_pkg_name) then
            raise fnd_api.g_exc_unexpected_error;
        end if;

        --
        -- initialize message list if p_init_msg_list is set to TRUE.
        --
        if fnd_api.to_boolean(p_init_msg_list) then
            fnd_msg_pub.initialize;
        end if;


        --
        --  Initialize API return status to success
        --
        x_return_status := fnd_api.g_ret_sts_success;


        --
        -- if skip lot not available, use normal inspection
        --
        if qa_skiplot_utility.check_skiplot_availability
        (qa_skiplot_utility.RCV, p_organization_id ) = fnd_api.g_false then
            x_evaluation_result := 'INSPECT';

        --
        -- if source inspected, skip the lot
        --
        elsif p_source_inspected = SOURCE_INSPECTED then
            --
            -- lot is already source inspected
            -- skip it and do not write it into database
            --

            x_evaluation_result := 'STANDARD';

        --
        -- evaluate criteria needed
        --
        else

            project_id := p_project_id;
            task_id := p_task_id;

            if project_id is null and task_id is null then
                get_project_task (
                p_po_distribution_id,
                p_po_line_location_id,
                project_id, -- out parameter
                task_id); -- out parameter
            end if;

            --
            -- get the availablePlans from skip lot setup
            --
            qa_skiplot_eval_engine.evaluate_rcv_criteria (
            p_organization_id => p_organization_id,
            p_vendor_id => p_vendor_id,
            p_vendor_site_id => p_vendor_site_id,
            p_item_id => p_item_id,
            p_item_revision => p_item_revision,
            p_item_category_id => p_item_category_id,
            p_project_id => project_id,
            p_task_id => task_id,
            p_manufacturer_id => p_manufacturer_id,
            p_lot_qty => p_receipt_qty,
            p_primary_uom => p_primary_uom,
            p_transaction_uom => p_transaction_uom,
            p_availablePlans => availablePlans, -- out parameter
            p_criteria_ID => criteriaID, -- out parameter
            p_process_id => processID); -- out parameter

            --
            -- if skip lot is not setup for this lot
            -- use normal inspection.
            --

            if availablePlans.count = 0 then
                x_evaluation_result := 'INSPECT';
            else
                --
                -- evaluate the available plans to get the
                -- applicable plans
                --
                qa_skiplot_eval_engine.evaluate_rules (
                p_availablePlans => availablePlans,
                p_criteria_id => criteriaID,
                p_process_id => processID,
                p_txn => qa_skiplot_utility.RCV,
                p_lot_id => lotID, -- out parameter
                p_applicablePlans => applicablePlans); -- out parameter

                --
                -- lot is skipped
                --
                if applicablePlans.count = 0 then
                    x_evaluation_result := 'STANDARD';
                    insp_status := 'SKIPPED';
                else
                    x_evaluation_result := 'INSPECT';
                    insp_status := 'PENDING';   -- inspection pending

                    --
                    -- store the lot/plan pairs if inspection required.
                    --
                    qa_skiplot_eval_engine.store_lot_plans(
                    p_applicablePlans => applicablePlans,
                    p_lotID => lotID,
                    p_insp_status => insp_status);

                end if;

                --
                -- insert into skip lot results table
                -- no matter insepction or skipping
                -- as long as skip lot inspection is
                -- applied
                --
                qa_skiplot_eval_engine.insert_rcv_results (
                p_interface_txn_id => p_interface_txn_id,
                p_manufacturer_id => p_manufacturer_id,
                p_receipt_qty => p_receipt_qty,
                p_criteriaID => criteriaID,
                p_insp_status => insp_status,
                p_receipt_date => sysdate,
                p_lotID => lotID,
                p_source_inspected => p_source_inspected,
                p_process_id => processID,
                p_lpn_id => p_lpn_id);
            end if;
        end if;

        COMMIT;

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := fnd_api.g_ret_sts_error;

            --
            --  get message count and data
            --
            fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data);

            qa_skiplot_utility.insert_error_log (
            p_module_name => 'QA_SKIPLOT_RCV_GRP.EVALUATE_LOT',
            p_error_message => 'FND_API.G_EXC_ERROR',
            p_comments => SUBSTR (SQLERRM , 1 , 240));

            x_evaluation_result := 'INSPECT';

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error ;

            --
            --  get message count and data
            --
            fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data);

            qa_skiplot_utility.insert_error_log (
            p_module_name => 'QA_SKIPLOT_RCV_GRP.EVALUATE_LOT',
            p_error_message => 'FND_API.G_EXC_UNEXPECTED_ERROR',
            p_comments => SUBSTR (SQLERRM , 1 , 240));

            x_evaluation_result := 'INSPECT';

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
                fnd_msg_pub.add_exc_msg (g_pkg_name , l_api_name);
            end if;

            qa_skiplot_utility.insert_error_log (
            p_module_name => 'QA_SKIPLOT_RCV_GRP.EVALUATE_LOT',
            p_error_message => 'OTHERS exception ',
            p_comments => SUBSTR (SQLERRM , 1 , 240));

            --
            --  get message count and data
            --
            fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data);

            x_evaluation_result := 'INSPECT';


    END EVALUATE_LOT;

    PROCEDURE MATCH_SHIPMENT
        (p_api_version IN NUMBER,
        p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_validation_level IN VARCHAR2 DEFAULT FND_API.G_VALID_LEVEL_FULL,
        p_interface_txn_id IN NUMBER,
        p_shipment_header_id IN NUMBER,
        p_shipment_line_id IN NUMBER,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2) IS

    l_api_version   CONSTANT NUMBER := 1.0;
    l_api_name  CONSTANT VARCHAR2(30):= 'MATCH_SHIPMENT';
    l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2400);

    lotID NUMBER := null;

    BEGIN

        --
        -- standard start of API savepoint
        --
        SAVEPOINT check_availability_pub;

        --
        -- standard call to check for call compatibility.
        --
        if not fnd_api.compatible_api_call (
            l_api_version,
            p_api_version,
            l_api_name,
            g_pkg_name) then
            raise fnd_api.g_exc_unexpected_error;
        end if;

        --
        -- initialize message list if p_init_msg_list is set to TRUE.
        --
        if fnd_api.to_boolean(p_init_msg_list) then
            fnd_msg_pub.initialize;
        end if;


        --
        --  Initialize API return status to success
        --
        x_return_status := fnd_api.g_ret_sts_success;


        --
        -- update lot plans table and results table
        -- with shipment line id
        --

        if p_interface_txn_id is not null then
            update qa_skiplot_rcv_results
            set shipment_line_id = p_shipment_line_id,
            valid_flag = 2
            where interface_txn_id = p_interface_txn_id
            returning insp_lot_id into lotID;
        end if;

        if lotID is not null then
            update qa_skiplot_lot_plans
            set shipment_line_id = p_shipment_line_id
            where insp_lot_id = lotID;
        end if;

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := fnd_api.g_ret_sts_error;

            qa_skiplot_utility.insert_error_log (
            p_module_name => 'QA_SKIPLOT_RCV_GRP.MATCH_SHIPMENT',
            p_error_message => 'FND_API.G_EXC_ERROR ',
            p_comments => SUBSTR (SQLERRM , 1 , 240));

            --
            --  get message count and data
            --
            fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error ;

            qa_skiplot_utility.insert_error_log (
            p_module_name => 'QA_SKIPLOT_RCV_GRP.MATCH_SHIPMENT',
            p_error_message => 'FND_API.G_EXC_UNEXPECTED_ERROR ',
            p_comments => SUBSTR (SQLERRM , 1 , 240));

            --
            --  get message count and data
            --
            fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data);

        WHEN OTHERS THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error ;

            if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
                fnd_msg_pub.add_exc_msg (g_pkg_name , l_api_name);
            end if;

            qa_skiplot_utility.insert_error_log (
            p_module_name => 'QA_SKIPLOT_RCV_GRP.MATCH_SHIPMENT',
            p_error_message => 'OTHERS exception ',
            p_comments => SUBSTR (SQLERRM , 1 , 240));

            --
            --  get message count and data
            --
            fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data);

   END MATCH_SHIPMENT;

   PROCEDURE IS_QA_RESULT_PRESENT
        (p_api_version IN NUMBER, -- 1.0
        p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_validation_level IN VARCHAR2 DEFAULT FND_API.G_VALID_LEVEL_FULL,
        p_collection_id IN NUMBER,
        x_result_present OUT NOCOPY VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2) IS

    l_api_version   CONSTANT NUMBER := 1.0;
    l_api_name  CONSTANT VARCHAR2(30):= 'IS_QA_RESULT_PRESENT';
    l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2400);

    --uses qa_pc_results_relationship to ensure we don't count orphan child rows
    CURSOR C1 IS
        SELECT   count(qr.occurrence)
        FROM     qa_results qr
        WHERE    qr.collection_id = p_collection_id
                 AND qr.occurrence NOT IN (SELECT qprr.child_occurrence
                                           FROM qa_pc_results_relationship qprr);
    l_res_count NUMBER := 0;
   BEGIN

        --
        -- savepoint unnecessary since this is a read-only procedure
        --

        --
        -- standard call to check for call compatibility.
        --
        if not fnd_api.compatible_api_call (
            l_api_version,
            p_api_version,
            l_api_name,
            g_pkg_name) then
            raise fnd_api.g_exc_unexpected_error;
        end if;

        --
        -- initialize message list if p_init_msg_list is set to TRUE.
        --
        if fnd_api.to_boolean(p_init_msg_list) then
            fnd_msg_pub.initialize;
        end if;

        --
        --  Initialize API return status to success and
        --  data found result to false
        --
        x_return_status := fnd_api.g_ret_sts_success;
        x_result_present := fnd_api.g_false;

        --
        -- do a lookup on qa_results to check for the collection_id
        -- in a non-child plan
        --
        OPEN C1;
        FETCH C1 INTO l_res_count;
        IF l_res_count > 0 THEN
          x_result_present := fnd_api.g_true;
        END IF;
        CLOSE C1;

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := fnd_api.g_ret_sts_error;

            qa_skiplot_utility.insert_error_log (
            p_module_name => 'QA_SKIPLOT_RCV_GRP.IS_QA_RESULT_PRESENT',
            p_error_message => 'FND_API.G_EXC_ERROR ',
            p_comments => SUBSTR (SQLERRM , 1 , 240));

            --
            --  get message count and data
            --
            fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error ;

            qa_skiplot_utility.insert_error_log (
            p_module_name => 'QA_SKIPLOT_RCV_GRP.IS_QA_RESULT_PRESENT',
            p_error_message => 'FND_API.G_EXC_UNEXPECTED_ERROR ',
            p_comments => SUBSTR (SQLERRM , 1 , 240));

            --
            --  get message count and data
            --
            fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data);

        WHEN OTHERS THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error ;

            if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
                fnd_msg_pub.add_exc_msg (g_pkg_name , l_api_name);
            end if;

            qa_skiplot_utility.insert_error_log (
            p_module_name => 'QA_SKIPLOT_RCV_GRP.IS_QA_RESULT_PRESENT',
            p_error_message => 'OTHERS exception ',
            p_comments => SUBSTR (SQLERRM , 1 , 240));

            --
            --  get message count and data
            --
            fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data);

    END IS_QA_RESULT_PRESENT;

    --
    -- bug 6064562
    -- This procedure is used by PO's RCV integration to
    -- check if a receiving transaction lot was skipped.
    -- This API is being introduced since, AP Invoicing
    -- creates an hold for skipped records for PO's created
    -- with 4 Way Match with Receipt. This happens because
    -- AP calls Receiving API to get the quantity details
    -- from rcv_transactions but rcv_transactions does
    -- not maintain details of Skipped lots.
    -- returns x_skip_status = {fnd_api.g_true | fnd_api.g_false}
    -- bhsankar Thu Jul 5 04:09:04 PDT 2007
    --
    PROCEDURE IS_LOT_SKIPPED(p_api_version IN NUMBER, -- 1.0
        p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_validation_level IN VARCHAR2 DEFAULT FND_API.G_VALID_LEVEL_FULL,
        p_transaction_id IN NUMBER,
        x_skip_status OUT NOCOPY VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2) IS


    l_api_version   CONSTANT NUMBER := 1.0;
    l_api_name  CONSTANT VARCHAR2(30):= 'IS_LOT_SKIPPED';
    l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2400);

    CURSOR C1 IS
      SELECT count(qa.inspection_status)
        FROM qa_skiplot_rcv_results qa, rcv_transactions rt
       WHERE rt.interface_transaction_id = qa.interface_txn_id
         AND rt.shipment_line_id = qa.shipment_line_id
         AND qa.inspection_status = 'SKIPPED'
        AND rt.transaction_id = p_transaction_id;

    l_skip_count number;
    BEGIN

        --
        -- savepoint unnecessary since this is a read-only procedure
        --

        --
        -- standard call to check for call compatibility.
        --
        if not fnd_api.compatible_api_call (
            l_api_version,
            p_api_version,
            l_api_name,
            g_pkg_name) then
            raise fnd_api.g_exc_unexpected_error;
        end if;

        --
        -- initialize message list if p_init_msg_list is set to TRUE.
        --
        if fnd_api.to_boolean(p_init_msg_list) then
            fnd_msg_pub.initialize;
        end if;

        --
        --  Initialize API return status to success and
        --  data found result to false
        --
        x_return_status := fnd_api.g_ret_sts_success;
        x_skip_status := fnd_api.g_false;

        --
        -- do a lookup in qa_skiplot_rcv_results and check
        -- if the lot pertaining to the rcv_transaction_id
        -- was skipped.
        --
        OPEN C1;
        FETCH C1 INTO l_skip_count;
        IF l_skip_count > 0 THEN
          x_skip_status := fnd_api.g_true;
        END IF;
        CLOSE C1;

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := fnd_api.g_ret_sts_error;

            qa_skiplot_utility.insert_error_log (
            p_module_name => 'QA_SKIPLOT_RCV_GRP.IS_LOT_SKIPPED',
            p_error_message => 'FND_API.G_EXC_ERROR ',
            p_comments => SUBSTR (SQLERRM , 1 , 240));

            --
            --  get message count and data
            --
            fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error ;

            qa_skiplot_utility.insert_error_log (
            p_module_name => 'QA_SKIPLOT_RCV_GRP.IS_LOT_SKIPPED',
            p_error_message => 'FND_API.G_EXC_UNEXPECTED_ERROR ',
            p_comments => SUBSTR (SQLERRM , 1 , 240));

            --
            --  get message count and data
            --
            fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data);

        WHEN OTHERS THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error ;

            if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
                fnd_msg_pub.add_exc_msg (g_pkg_name , l_api_name);
            end if;

            qa_skiplot_utility.insert_error_log (
            p_module_name => 'QA_SKIPLOT_RCV_GRP.IS_LOT_SKIPPED',
            p_error_message => 'OTHERS exception ',
            p_comments => SUBSTR (SQLERRM , 1 , 240));

            --
            --  get message count and data
            --
            fnd_msg_pub.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data);


    END IS_LOT_SKIPPED;

END QA_SKIPLOT_RCV_GRP;

/
