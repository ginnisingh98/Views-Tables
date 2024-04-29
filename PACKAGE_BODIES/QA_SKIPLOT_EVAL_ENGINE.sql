--------------------------------------------------------
--  DDL for Package Body QA_SKIPLOT_EVAL_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_SKIPLOT_EVAL_ENGINE" AS
/* $Header: qaslevab.pls 120.3.12010000.2 2009/11/27 10:01:15 pdube ship $ */

    --
    -- local function
    --
    function insp_required(
    p_plan_state in qa_skiplot_utility.plan_state_rec)return varchar2 is

    begin
        --
        -- p_plan_state is the state before we consider the new coming lot
        --

        --
        -- rule is finished
        --
        if qa_skiplot_utility.insp_rule_finished(p_plan_state) = fnd_api.g_true then
            --
            -- if the next rule does not have freq_numerator as 0, then inspect
            -- otherwise skip
            --
            if qa_skiplot_utility.inspect_zero(p_plan_state) = fnd_api.g_false then
                return fnd_api.g_true;
            else
                return fnd_api.g_false;
            end if;
        --
        -- rule is not finished, but round is finished
        --
        elsif qa_skiplot_utility.insp_round_finished(p_plan_state) = fnd_api.g_true then
            --
            -- if more rounds and the current frequency numerator is not 0 then inspect
            -- otherwise skip
            --
            if qa_skiplot_utility.more_rounds(p_plan_state) = fnd_api.g_true and
               p_plan_state.current_freq_num > 0 then
                return fnd_api.g_true;
            else
                return fnd_api.g_false;
            end if;

        --
        -- round not finished
        --
        else
            -- if not enough lot accepted, then inspect, otherwise skip
            if qa_skiplot_utility.enough_lot_accepted(p_plan_state) = fnd_api.g_false then
                return fnd_api.g_true;
            else
                return fnd_api.g_false;
            end if;

        end if;

    end insp_required;

    --
    -- local function
    --
    procedure fetch_plan_states(
    p_planList IN qa_skiplot_utility.planList,
    p_criteria_id IN NUMBER,
    p_process_id IN NUMBER,
    p_txn IN NUMBER,
    p_plan_states  OUT nocopy qa_skiplot_utility.planStateTable) IS

    plan_state qa_skiplot_utility.plan_state_rec;
    plan_id number;
    i number := null;

    begin
        i := p_planList.first;
        while i is not null loop
            plan_id := p_planList(i).plan_id;

            qa_skiplot_utility.fetch_plan_state (
            p_plan_id => plan_id,
            p_criteria_id => p_criteria_id,
            p_process_id => p_process_id,
            p_txn => p_txn,
            p_plan_state => plan_state); -- out parameter

            if plan_state.plan_id is not null then
                p_plan_states(plan_state.plan_id) := plan_state;
            end if;

        i := p_planList.next(i);
        end loop;
    end fetch_plan_states;


    --
    -- The function returns criteria id
    -- it also resolve the criteria conflicts
    -- so that only one criteria id is returned
    -- if multiple groups of criteria are setup
    --


    FUNCTION GET_RCV_CRITERIA_ID
    (p_organization_id IN NUMBER,
    p_vendor_id IN NUMBER,
    p_vendor_site_id IN NUMBER,
    p_item_id IN NUMBER,
    p_item_revision IN VARCHAR2,
    p_item_category_id IN NUMBER,
    p_project_id IN NUMBER,
    p_task_id IN NUMBER,
    p_manufacturer_id IN NUMBER)
    RETURN NUMBER IS

    criteriaID NUMBER := -1;

    -- Bug 7270226.FP for bug#7219703
    -- Getting the categories having criterion defined
    -- for skipping or sampling for the item.
    -- pdube Thu Nov 26 03:19:15 PST 2009
    CURSOR item_categories (
    x_item_id NUMBER,
    x_organization_id number,
    x_item_category_id number) IS
    SELECT Nvl(micv.category_id,-1) item_category_id
    FROM MTL_ITEM_CATEGORIES_V MICV,
         qa_sl_sp_rcv_criteria qssrc,
         qa_skiplot_association qsa,
         qa_skiplot_processes qsp
    WHERE micv.inventory_item_id= x_item_id AND
          micv.organization_id= x_organization_id AND
          qssrc.item_category_id = micv.category_id AND
          qsa.criteria_id = qssrc.criteria_id AND
          qsa.process_id = qsp.process_id AND
          micv.category_id <> x_item_category_id
     ORDER BY qsp.process_code asc;

    CURSOR criteria (
    x_organization_id number,
    x_vendor_id number,
    x_vendor_site_id number,
    x_item_id number,
    x_item_revision varchar2,
    x_item_category_id number,
    x_project_id number,
    x_task_id number,
    x_manufacturer_id number) IS

    -- the SQL resolves the criteria conflict
    -- by using order by statement.

    --
    -- removed the rownum = 1 statement from this cursor
    -- since rownum cound is done before ordering which
    -- will give wrong criteria
    -- jezheng
    -- Thu Oct 18 18:18:29 PDT 2001
    --
    --
    -- Bug 7270226.FP for bug#7219703
    -- Added the effective date validation clause to handle
    -- the scenario of multiple applicable scenario with one end dated.
    -- pdube Thu Nov 26 03:19:15 PST 2009
    SELECT
            qsrc.criteria_id criteria_id
    FROM
            qa_sl_sp_rcv_criteria qsrc,
            qa_skiplot_association qsa
    WHERE
            qsrc.vendor_id in (-1,  x_vendor_id) AND
            qsrc.vendor_site_id in (-1, x_vendor_site_id) AND
            qsrc.item_id in (-1, x_item_id)AND
            qsrc.item_revision in ('-1', x_item_revision) AND
            qsrc.item_category_id in (-1, x_item_category_id) AND
            qsrc.project_id  in (-1, x_project_id) AND
            qsrc.task_id in (-1, x_task_id) AND
            qsrc.manufacturer_id in (-1, x_manufacturer_id) AND
            qsrc.organization_id = x_organization_id AND
	    qsa.criteria_id = qsrc.criteria_id AND
	    trunc(sysdate) BETWEEN
            nvl(trunc(qsa.effective_from), trunc(sysdate)) AND
            nvl(trunc(qsa.effective_to), trunc(sysdate))
    ORDER BY
            qsrc.task_id desc, qsrc.project_id desc , qsrc.manufacturer_id desc,
            qsrc.vendor_site_id desc, qsrc.vendor_id desc, qsrc.item_revision desc,
            qsrc.item_id desc, qsrc.item_category_id desc, qsrc.last_update_date desc
    FOR UPDATE NOWAIT;

    begin

        open criteria
            (p_organization_id,
            p_vendor_id,
            p_vendor_site_id,
            p_item_id,
            p_item_revision,
            p_item_category_id,
            p_project_id,
            p_task_id,
            p_manufacturer_id);

        --
        -- fetch statement will fetch only one criteria_id
        -- based on the order specified in the cursor
        -- if more than one applicable.
        --
        fetch criteria into criteriaID;
        close criteria;

        -- Bug 7270226.FP for bug#7219703
        -- Added this code to check for criteria based on
        -- categories defined out of "Purchasing" Category Set.
        -- pdube Thu Nov 26 03:19:15 PST 2009
        IF (criteriaID = -1) THEN
           for prec in item_categories(p_item_id,p_organization_id,p_item_category_id) LOOP
            open criteria
              (p_organization_id,
               p_vendor_id,
               p_vendor_site_id,
               p_item_id,
               p_item_revision,
               prec.item_category_id,
               p_project_id,
               p_task_id,
               p_manufacturer_id);
            fetch criteria into criteriaID;
            close criteria;
            EXIT WHEN(criteriaID <> -1);
           END LOOP;
        END IF;
        -- End of bug 7270226.FP for bug#7219703

	return criteriaID;

    END GET_RCV_CRITERIA_ID;


    PROCEDURE EVALUATE_RCV_CRITERIA (
    p_organization_id IN NUMBER,
    p_vendor_id IN NUMBER,
    p_vendor_site_id IN NUMBER,
    p_item_id IN NUMBER,
    p_item_revision IN VARCHAR2,
    p_item_category_id IN NUMBER,
    p_project_id IN NUMBER,
    p_task_id IN NUMBER,
    p_manufacturer_id IN NUMBER,
    p_lot_qty IN NUMBER,
    p_primary_uom IN varchar2,
    p_transaction_uom IN varchar2,
    p_availablePlans OUT NOCOPY qa_skiplot_utility.planList,
    p_criteria_id OUT NOCOPY NUMBER,
    p_process_id OUT NOCOPY NUMBER)IS

    x_availablePlans qa_skiplot_utility.planList;
    x_criteria_id NUMBER := -1;
    x_process_id NUMBER := -1;

    primary_lot_qty NUMBER;

    --
    -- given a criteria_id, we can get multiple process_ids
    -- from qa_skiplot_association table. Put lot size and
    -- effective date as restriction, we will get only one
    -- process_id if any.
    -- With this process_id, we can get multiple collection
    -- plan ids from qa_skiplot_process_plans table.
    -- jezheng
    -- Tue Oct 30 17:47:20 PST 2001
    --
    cursor the_process (x_c_id number, x_lotsize number) is
        select qsa.process_id
        from   qa_skiplot_association qsa
        where  qsa.criteria_id = x_c_id and
               trunc(sysdate) between
               nvl(trunc(qsa.effective_from), trunc(sysdate)) and
               nvl(trunc(qsa.effective_to), trunc(sysdate)) and
               x_lotsize between
               nvl(qsa.lotsize_from, x_lotsize) and
               nvl(qsa.lotsize_to, x_lotsize);

    cursor avail_plans (x_process_id number) is
        select  qspp.plan_id
        from    qa_skiplot_process_plans qspp
        where   qspp.process_id = x_process_id;

        BEGIN
    /* p_lot_qty is in transaction_uom. so it is converted to primary_uom*/
        if ((p_primary_uom is not null) and (p_transaction_uom is not null) and (p_primary_uom <> p_transaction_uom)) then
           primary_lot_qty := inv_convert.inv_um_convert(
                              item_id => p_item_id,
                              precision => null,
                              from_quantity => p_lot_qty,
                              from_unit => p_transaction_uom,
                              to_unit => p_primary_uom,
                              from_name => null,
                              to_name => null );
        else
           primary_lot_qty := p_lot_qty;
        end if;

        x_criteria_id := get_rcv_criteria_id(
                         p_organization_id => p_organization_id,
                         p_vendor_id => p_vendor_id,
                         p_vendor_site_id => p_vendor_site_id,
                         p_item_id => p_item_id,
                         p_item_revision => p_item_revision,
                         p_item_category_id => p_item_category_id,
                         p_project_id => p_project_id,
                         p_task_id => p_task_id,
                         p_manufacturer_id => p_manufacturer_id);

        open the_process (x_criteria_id, primary_lot_qty);
        fetch the_process into x_process_id;
        close the_process;

        for p in avail_plans (x_process_id) loop
            x_availablePlans(p.plan_id).plan_id := p.plan_id;
        end loop;

        p_availablePlans := x_availablePlans;
        p_criteria_id := x_criteria_id;
        p_process_id := x_process_id;

    END EVALUATE_RCV_CRITERIA;

    PROCEDURE EVALUATE_RULES (
    p_availablePlans IN qa_skiplot_utility.planList,
    p_criteria_id IN NUMBER,
    p_process_id IN NUMBER,
    p_txn IN NUMBER,
    p_lot_id OUT NOCOPY NUMBER,
    p_applicablePlans OUT NOCOPY qa_skiplot_utility.planList)IS

    pID number; -- plan id
    alternate_plan_id number;
    plan_states qa_skiplot_utility.planStateTable;
    i number := null;
    p_plan_id number; -- process plan id
    rule_start_lotid number;

    x_lotID number;

    -- Bug 3959767. Skiplot not skipping if we are setting
    -- qualification to zero and frequency zero out of n.
    -- Adding the following code including three cursor
    -- track bug number for changes
    -- saugupta Mon, 22 Nov 2004 23:59:14 -0800 PDT
    inspection_stage VARCHAR2(100) := ' ';
    q_rounds NUMBER;
    next_rule NUMBER;
    freq_denom NUMBER;
    freq_num NUMBER;
    process_plan_id NUMBER;

    -- Bug 3959767. Fetches the inspection stage

    -- Bug 5197549
    -- Added the condition for Process Id
    -- so that the inspection Stage is picked
    -- Up corresponding to that process
    -- SHKALYAN 01-May-2006

    CURSOR insp_stage(x_crit_id NUMBER, x_process_id NUMBER) IS
       SELECT  INSP_STAGE
       FROM qa_skiplot_association
       WHERE  criteria_id = x_crit_id
       AND    process_id = x_process_id;

    -- Bug 3959767 fetches qualification rounds
    CURSOR qualification_rounds(x_process_id NUMBER) IS
    SELECT qsppr.rounds
    FROM qa_skiplot_process_plans qspp,
         qa_skiplot_process_plan_rules qsppr
    WHERE qspp.process_id = x_process_id
    AND   qspp.process_plan_id = qsppr.process_plan_id
    AND   qsppr.rule_seq=0;

    -- Bug 3959767 fetches next rule
    CURSOR nxt_rule (pp_id in number, current_rule in number) IS
       SELECT MIN(rule_seq)
       FROM  qa_skiplot_process_plan_rules
       WHERE process_plan_id = pp_id and
           rule_seq > current_rule;

       --
       -- Bug 5037121
       -- New flag to check if the plans state
       -- have been initialized
       -- ntungare Wed Feb 15 06:46:23 PST 2006
       --
       plan_init_flag  BOOLEAN;

       -- Bug 5037121
       -- New cursor to fetch all the plans associated
       -- and the criteria Id for the Skip process Id
       -- ntungare Wed Feb 15 06:46:23 PST 2006
       --
       -- Bug 6344791
       -- Added a parameter x_crit_id so that the process_plans
       -- are uniquely identified for a particular
       -- skiplot process-criteria combination
       -- bhsankar Wed Aug 22 01:16:48 PDT 2007
       --
       CURSOR plan_det (x_pid NUMBER, x_crit_id NUMBER) IS
        SELECT qspp.process_plan_id
        FROM qa_skiplot_process_plans qspp, qa_skiplot_association qsa
        WHERE qspp.process_id = qsa.process_id AND
              qsa.criteria_id = x_crit_id AND
              qspp.process_id = x_pid;

    BEGIN

        x_lotID := qa_skiplot_utility.get_lot_id;
        p_lot_id := x_lotID;

        fetch_plan_states(
        p_planList => p_availablePlans,
        p_criteria_id => p_criteria_id,
        p_process_id => p_process_id,
        p_txn => p_txn,
        p_plan_states => plan_states); -- out parameter

        i := p_availablePlans.first;

        -- Bug 3959767. Get the inspection stage

        -- Bug 5037121
        -- Moved the Cursor into the check for date violation
        -- as in there the Inspectin stage is set to Qualification
        -- and we need to get the new set stage.
        -- ntungare Wed Feb 15 06:48:37 PST 2006

        --OPEN insp_stage(p_criteria_id);
        --FETCH insp_stage INTO inspection_stage;
        --CLOSE insp_stage;

        --
        -- loop through each available plan to
        -- see whether it is applicable
        -- if yes, write it into applicable plan pl/sql table
        --
        while i is not null loop

           pID := p_availablePlans(i).plan_id;

           --
           -- if state not found for this plan
           -- or if adjacent date restriction is violated,
           -- initialize the plan state table and
           -- the plan must be inspected
           --
           --
           -- Bug 5037121
           -- If a state is not found then call the update_plan_state
           -- procedure that will reset the inspection stage to
           -- qualification.
           -- If the adjacent date restriction is violated the procedure
           -- reset_last_receipt_date is called after Update_plan_state
           -- to update the last receipt date to the sysdate.
           -- This reset is done for all the Plans associated with
           -- a skip process
           -- ntungare Wed Feb 15 06:50:41 PST 2006
           --

           if not plan_states.exists(pID) THEN
                qa_skiplot_utility.init_plan_state(
                p_plan_id=> pID,
                p_criteria_id => p_criteria_id,
                p_process_id => p_process_id,
                p_txn => p_txn,
                p_lot_id => x_lotID,
                p_process_plan_id => p_plan_id);

                plan_init_flag := TRUE;
           elsif
                qa_skiplot_utility.date_reasonable (
                  p_receipt_date => sysdate,
                  p_check_mode => qa_skiplot_utility.ADJACENT_DATE_CHECK,
                  p_plan_state =>plan_states(pID)) = fnd_api.g_false THEN
                --
                -- bug 6344791
                -- Included a parameter p_criteria_id so as
                -- to uniquely identify the skiplot plans
                -- whose statuses needs to be reset to qualification.
                -- Also modified parameter name from ps.criteria_id to
                -- p_criteria_id in calls to procedures UPDATE_PLAN_STATE
                -- and RESET_LAST_RECEIPT_DATE.
                -- bhsankar Wed Aug 22 01:16:48 PDT 2007
                --
                For ps in plan_det (p_process_id, p_criteria_id)
                  LOOP
                     QA_SKIPLOT_UTILITY.UPDATE_PLAN_STATE (
                          p_process_plan_id => ps.process_plan_id,
                          p_criteria_id => p_criteria_id,
                          p_next_rule => 0,
                          p_next_round => 1,
                          p_next_lot => 0,
                          p_lot_accepted => 0,
                          p_txn => QA_SKIPLOT_UTILITY.RCV);

                     QA_SKIPLOT_UTILITY.RESET_LAST_RECEIPT_DATE(
                          p_criteria_id     => p_criteria_id,
                          p_process_plan_id =>  ps.process_plan_id);
                   END LOOP;

                 plan_init_flag := TRUE;
           else
                 plan_init_flag := FALSE;
           end if;

           --
           -- Bug 5037121
           -- This processing logic was based on any of the above
           -- conditions being true. Since the aboce conditions
           -- have been split so a separate flag has been used.
           -- ntungare Wed Feb 15 06:56:10 PST 2006
           --
           IF plan_init_flag THEN

                -- Bug 3959767 Since plan exists, we need to check if
                -- process in Qualification stage. If in Qualification
                -- stage we need to check the rounds as this is where the
                -- Qualification parameter comes in picture.
                -- saugupta Tue, 23 Nov 2004 00:00:58 -0800 PDT

                -- Bug 5037121
                -- Opening the cursor to fetch the Inspection Stage
                -- ntungare Wed Feb 15 06:57:25 PST 2006
                --


                -- Bug 5197549
                -- Passing the Process Id too to the
                -- cursor as that the Inspection Stage
                -- is read specific to that process
                -- SHKALYAN 01-May-2006

                OPEN insp_stage(p_criteria_id, p_process_id);
                FETCH insp_stage INTO inspection_stage;
                CLOSE insp_stage;

                IF inspection_stage='QUALIFICATION' THEN

                   -- Bug 3959767 Get number of qualifying rounds.
                   OPEN qualification_rounds(p_process_id);
                   FETCH qualification_rounds INTO q_rounds;
                   CLOSE qualification_rounds;

                  -- Bug 3959767. If qualification round equals zero the process should
                  -- be skipped that is it should directly go to next rule.
                  -- saugupta Tue, 23 Nov 2004 00:01:19 -0800 PDT
                  IF q_rounds =0 THEN

                     process_plan_id := QA_SKIPLOT_UTILITY.GET_PROCESS_PLAN_ID(
                                                           p_plan_id => pID,
                                                           p_criteria_id => p_criteria_id,
                                                           p_process_id => p_process_id,
                                                           p_txn => p_txn);


                     OPEN nxt_rule(process_plan_id, 0);
                     FETCH nxt_rule INTO next_rule;
                     CLOSE nxt_rule;

                     QA_SKIPLOT_UTILITY.CHECK_RULE_FREQUENCY(
                                           process_plan_id,
                                           next_rule,
                                           freq_num,
                                           freq_denom);
                    -- Bug 3959767. Checking the frequency of next rule. If this is also set
                    -- to zero then skip and update the plan state/process state.
                    -- saugupta Tue, 23 Nov 2004 00:01:58 -0800 PDT
                    IF freq_num = 0 THEN
                         QA_SKIPLOT_UTILITY.update_plan_state(
                                            p_process_plan_id => process_plan_id,
                                            p_criteria_id => p_criteria_id,
                                            p_next_rule => next_rule,
                                            p_txn => p_txn);


                    ELSE
                        p_applicablePlans(pID).plan_id := pID;
                    END IF;
                  ELSE
                    p_applicablePlans(pID).plan_id := pID;
                  END IF;
            END IF;

           elsif insp_required(plan_states(pID)) = fnd_api.g_true then
                --
                -- plan must be inspected
                --
                p_applicablePlans(pID).plan_id := pID;

                --
                -- if rule_start_lot_id is null, update it with new id
                -- otherwise leave it as it is
                --
                if qa_skiplot_utility.insp_rule_finished(plan_states(pID)) = fnd_api.g_true and
                   (plan_states(pID).last_receipt_date is null or
                    plan_states(pID).rule_start_date is null or
                    plan_states(pID).day_span is null or
                    trunc(plan_states(pID).last_receipt_date) - trunc(plan_states(pID).rule_start_date) <=
                    plan_states(pID).day_span ) then

                    rule_start_lotid := x_lotID;
                else
                    rule_start_lotid :=  plan_states(pID).rule_start_lot_id;
                end if;

                --
                -- update plan state with the latest lot id
                --
                qa_skiplot_utility.update_plan_state (
                p_process_plan_id => plan_states(pID).process_plan_id,
                p_criteria_id => p_criteria_id,
                p_last_receipt_lot_id => x_lotID,
                p_rule_start_lotid => rule_start_lotid,
                p_txn => p_txn);

           else
                --
                -- plan is skipped
                -- forward the current_lot and
                -- update the last receipt lot id
                -- get alternate plan if available
                --
                qa_skiplot_utility.update_plan_state (
                p_process_plan_id => plan_states(pID).process_plan_id,
                p_criteria_id => p_criteria_id,
                p_next_lot => plan_states(pID).current_lot + 1,
                p_last_receipt_lot_id => x_lotID,
                p_txn => p_txn);

                alternate_plan_id := plan_states(pID).alternate_plan_id;

                if alternate_plan_id is not null then
                     p_applicablePlans(alternate_plan_id).plan_id := alternate_plan_id;
                     p_applicablePlans(alternate_plan_id).alternate_flag := 'Y';
                end if;
           end if;

        i := p_availablePlans.next(i);
        end loop;

    EXCEPTION
        WHEN OTHERS THEN
            qa_skiplot_utility.insert_error_log (
            p_module_name => 'QA_SKIPLOT_EVAL_ENGINE.EVALUATE_RULES',
            p_error_message => 'QA_SKIPLOT_EVAL_RULE_FAILURE',
            p_comments => SUBSTR (SQLERRM , 1 , 240));
            fnd_message.set_name ('QA', 'QA_SKIPLOT_EVAL_RULE_FAILURE');
            APP_EXCEPTION.RAISE_EXCEPTION;

    END EVALUATE_RULES;

    PROCEDURE INSERT_RCV_RESULTS (
    p_interface_txn_id IN NUMBER,
    p_manufacturer_id IN NUMBER,
    p_receipt_qty IN NUMBER,
    p_criteriaID IN NUMBER,
    p_insp_status IN VARCHAR2,
    p_receipt_date IN DATE,
    p_lotID IN NUMBER DEFAULT NULL,
    p_source_inspected IN NUMBER,
    p_process_id IN NUMBER,
    p_lpn_id IN NUMBER) IS


    x_lotID number := null;

    BEGIN

        x_lotID := p_lotID;

        if x_lotID is null then
            x_lotID := qa_skiplot_utility.get_lot_id;
        end if;

        insert into qa_skiplot_rcv_results(
        INSP_LOT_ID,
        CRITERIA_ID,
        PROCESS_ID,
        INTERFACE_TXN_ID,
        SHIPMENT_LINE_ID,
        RECEIPT_DATE,
        MANUFACTURER_ID,
        LPN_ID,
        SOURCE_INSPECTED,
        LOT_QTY,
        TRANSACTED_QTY,
        INSPECTION_STATUS,
        INSPECTION_RESULT,
        LAST_INSP_DATE,
        VALID_FLAG,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN)
        values(
        x_lotID,
        p_criteriaID,
        p_process_id,
        p_interface_txn_id,
        null,
        p_receipt_date,
        p_manufacturer_id,
        p_lpn_id,
        decode(p_source_inspected, 1, 'Y', 'N'),
        p_receipt_qty,
        0,
        p_insp_status,
        null,
        null,
        1,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        fnd_global.login_id);

    END INSERT_RCV_RESULTS;

    PROCEDURE STORE_LOT_PLANS(
    p_applicablePlans IN qa_skiplot_utility.planList,
    p_lotID IN NUMBER,
    p_insp_status IN VARCHAR2) IS

    plan_id number;
    alter_flag varchar2(1);
    i number;

    BEGIN

        i := p_applicablePlans.first;
        while i is not null loop
            plan_id := p_applicablePlans(i).plan_id;
            alter_flag := nvl(p_applicablePlans(i).alternate_flag, 'N');

            insert into qa_skiplot_lot_plans(
            INSP_LOT_ID,
            PLAN_ID,
            ALTERNATE_FLAG,
            SHIPMENT_LINE_ID,
            PLAN_INSP_STATUS,
            PLAN_INSP_RESULT,
            SAMPLE_SIZE,
            INSPECTED_QTY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN)
            values(
            p_lotID,
            plan_id,
            alter_flag,
            null,
            p_insp_status,
            null,
            null,
            0,
            sysdate,
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id,
            fnd_global.login_id);

            i := p_applicablePlans.next(i);
        end loop;


    END STORE_LOT_PLANS;

END QA_SKIPLOT_EVAL_ENGINE;

/
