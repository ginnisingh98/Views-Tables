--------------------------------------------------------
--  DDL for Package Body QA_SKIPLOT_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_SKIPLOT_UTILITY" AS
/* $Header: qaslutlb.pls 120.1 2006/02/15 08:43:15 ntungare noship $ */

    --
    -- local function
    --
    function get_first_rule_num(
    p_process_plan_id in number)return number is

    cursor fr (pp_id in number) is
        select min(rule_seq)
        from qa_skiplot_process_plan_rules
        where process_plan_id = pp_id;

    first_rule number;

    begin
        open fr (p_process_plan_id);
        fetch fr into first_rule;

        if fr%notfound or first_rule is null then
            first_rule := -1;
        end if;
        close fr;
        return first_rule;
    end get_first_rule_num;

    --
    -- local function
    --
    function get_last_lot_date(
    p_criteria_id in number,
    p_receipt_date in date default null)return date is

    prev_date date;

    cursor p (p_criteria_id in number, p_receipt_date in date) is
        select qsrr.receipt_date
        from   qa_skiplot_rcv_results qsrr
        where  insp_lot_id = (select max(qsrr2.insp_lot_id)
               from qa_skiplot_rcv_results qsrr2
               where qsrr2.criteria_id = p_criteria_id and
               qsrr2.receipt_date < p_receipt_date);

    begin

        open p (p_criteria_id, p_receipt_date);
        fetch p into prev_date;
        close p;

        --
        -- if no previous date, assign current date to it
        -- which will make date range check automatically true
        --
        if p%notfound then
            prev_date := p_receipt_date;
        end if;

        return prev_date;

    end get_last_lot_date;

    --
    --local function
    --
    function check_adjacent_date(
    p_receipt_date in date default null,
    p_plan_state in plan_state_rec)return varchar2 is

    prev_date date;
    day_range number;

    begin

        --
        -- if no date range restriction is setup
        -- return true
        --
        day_range := p_plan_state.adjacent_days;
        if day_range is null then
            --
            -- no adjacent date restriction
            --
            return fnd_api.g_true;
        end if;

        prev_date := p_plan_state.last_receipt_date;
        if trunc(nvl(p_receipt_date, sysdate)) - trunc(prev_date)
           <= day_range then
            return fnd_api.g_true;
        else
            return fnd_api.g_false;
        end if;
    end check_adjacent_date;

    --
    -- local function
    --
    function check_date_span(
    p_plan_state in plan_state_rec)return varchar2 is

    x_next_lotid number;
    x_next_receipt_date date;

    --
    -- get the lotid and receipt date right after
    -- the rule start lotid and receipt date
    --
    cursor new_start_lot (x_rule_start_lotid number, x_criteria_id number,
           x_process_id number) is
        select q1.insp_lot_id, q1.receipt_date
        from qa_skiplot_rcv_results q1
        where q1.insp_lot_id = (select min(q2.insp_lot_id)
                                from qa_skiplot_rcv_results q2
                                where q2.insp_lot_id > x_rule_start_lotid and
                                q2.criteria_id = x_criteria_id and
                                q2.process_id = x_process_id);

    begin


        if p_plan_state.last_receipt_date is null or
        p_plan_state.rule_start_date is null or
        p_plan_state.day_span is null or
        trunc(p_plan_state.last_receipt_date) - trunc(p_plan_state.rule_start_date)
        <= p_plan_state.day_span then


            return fnd_api.g_true;

        --
        -- if day span restriction is violated, update
        -- rule_start_lot_id and rule_start_date with
        -- the next lot id and receipt date to prepare
        -- next comparison.
        --
        else

            open new_start_lot (p_plan_state.rule_start_lot_id,
                 p_plan_state.criteria_id, p_plan_state.process_id);
            fetch new_start_lot into x_next_lotid, x_next_receipt_date;
            close new_start_lot;

            if x_next_lotid is not null and x_next_receipt_date is not null then

                update qa_skiplot_plan_states
                set rule_start_lot_id = x_next_lotid,
                rule_start_date = x_next_receipt_date
                where process_plan_id = p_plan_state.process_plan_id and
                criteria_id = p_plan_state.criteria_id;
            --
            -- this case should not happen
            --
            else
                insert_error_log (
                p_module_name =>'QA_SKIPLOT_UTILITY.check_date_span',
                p_error_message => 'Next lotid or next receipt date is null');
            end if;

            return fnd_api.g_false;

        end if;

    end check_date_span;



    FUNCTION CHECK_SKIPLOT_AVAILABILITY (
    p_txn IN NUMBER,
    p_organization_id IN NUMBER) RETURN VARCHAR2 IS

    -- Check in as Bug 2917141
    -- Performance standard.
    -- l_qa_installation   VARCHAR2(1) := fnd_api.g_false;
    -- l_skiplot_control VARCHAR2(1) := fnd_api.g_false;
    -- l_skiplot_setup VARCHAR2(1) := fnd_api.g_false;
    -- l_qa_inspection VARCHAR2(1) := fnd_api.g_false;

    l_qa_installation   VARCHAR2(1);
    l_skiplot_control VARCHAR2(1);
    l_skiplot_setup VARCHAR2(1);
    l_qa_inspection VARCHAR2(1);

    BEGIN

/*
rkaza: 07/16/2002. Bug 2451734. This caching mechanism doesnt work well
for different users getting the same database connection in mobile, also when
the user changes the skipping flag in the middle of his work.
Temporarily commenting it at the cost of a little bit of performance.

        if skiplot_avail <> fnd_api.g_miss_char then
           return skiplot_avail;
        end if;
*/

        l_qa_installation := QA_INSPECTION_PKG.qa_installation;

        l_skiplot_control := skiplot_control(p_organization_id);

        l_skiplot_setup := skiplot_setup(p_txn, p_organization_id);

        l_qa_inspection := QA_INSPECTION_PKG.qa_inspection;

        if l_qa_installation = fnd_api.g_true and
           l_skiplot_control = fnd_api.g_true and
           l_skiplot_setup = fnd_api.g_true and
           l_qa_inspection = fnd_api.g_true then
            skiplot_avail := fnd_api.g_true;
        else
            skiplot_avail := fnd_api.g_false;
        end if;

        return skiplot_avail;

    EXCEPTION

        WHEN OTHERS THEN

            insert_error_log (
            p_module_name =>'QA_SKIPLOT_UTILITY.CHECK_SKIPLOT_AVAILABILITY',
            p_error_message => 'QA_SKIPLOT_CHECK_AVALIABLITY_ERR',
            p_comments => SUBSTR (SQLERRM , 1 , 240));

            return fnd_api.g_false;

    END CHECK_SKIPLOT_AVAILABILITY;

    FUNCTION SKIPLOT_CONTROL
    (p_organization_id IN NUMBER)
    RETURN VARCHAR2 IS

    cursor sk_ctrl (x_org_id number) is
        select qa_skipping_insp_flag
        from mtl_parameters
        where organization_id = x_org_id;

    sk_flag VARCHAR2(1) := fnd_api.g_false;

    BEGIN
        --
        -- open cursor when INV is ready
        -- return true for now.
        --
        open sk_ctrl (p_organization_id);
        fetch sk_ctrl into sk_flag;
        close sk_ctrl;

        if sk_flag = 'Y' or sk_flag = 'T' then
            return fnd_api.g_true;
        else
            return fnd_api.g_false;
        end if;

    END SKIPLOT_CONTROL;


    FUNCTION SKIPLOT_SETUP (
    p_txn IN NUMBER,
    p_organization_id IN NUMBER)
    RETURN VARCHAR2 IS

    cursor rcv_criteria (x_org_id number) is
    select count(*)
    from qa_skiplot_rcv_criteria_val_v qsrc
    where qsrc.organization_id = x_org_id and
    trunc(sysdate) between nvl(trunc(qsrc.effective_from), trunc(sysdate))
    and nvl(trunc(qsrc.effective_to), trunc(sysdate));


    criteria_count number;

    BEGIN

        if p_txn = RCV then
            open rcv_criteria (p_organization_id);
            fetch rcv_criteria into criteria_count;
            close rcv_criteria;
            if criteria_count > 0 then
                return fnd_api.g_true;
            else
                return fnd_api.g_false;
            end if;
        else
            return fnd_api.g_false;
        end if;

    END SKIPLOT_SETUP;

    PROCEDURE CHECK_RULE_FREQUENCY (
    p_process_plan_id IN NUMBER,
    p_rule_seq IN NUMBER,
    p_freq_num OUT NOCOPY NUMBER,
    p_freq_denom OUT NOCOPY NUMBER) IS

    cursor rule (x_pp_id number, x_rule_seq number) is
        select frequency_num, frequency_denom
        from qa_skiplot_process_plan_rules
        where process_plan_id = x_pp_id and
        rule_seq = x_rule_seq;

    BEGIN
        open rule (p_process_plan_id, p_rule_seq);
        fetch rule into p_freq_num, p_freq_denom;
        close rule;

    END CHECK_RULE_FREQUENCY;


    FUNCTION GET_PROCESS_PLAN_ID (
    p_plan_id IN NUMBER,
    p_criteria_id IN NUMBER,
    p_process_id IN NUMBER,
    p_txn IN NUMBER)RETURN NUMBER IS

    pp_id number;
    pp refCursorTyp;

    BEGIN

        if p_txn = RCV then
            open pp for
            'select qspp.process_plan_id
            from qa_skiplot_association qsa,
            qa_skiplot_process_plans qspp
            where qsa.criteria_id = :1 and
            qsa.process_id = :2 and
            qsa.process_id = qspp.process_id and
            qspp.plan_id = :3'
            using p_criteria_id, p_process_id, p_plan_id;
        else
            --
            -- wip goes here
            --
            return -1;
        end if;

        fetch pp into pp_id;

        if pp%notfound then
            pp_id :=  -1;
        end if;
        close pp;

        return pp_id;

   END GET_PROCESS_PLAN_ID ;


    PROCEDURE FETCH_PLAN_STATE(
    p_plan_id IN NUMBER DEFAULT NULL,
    p_process_plan_id IN NUMBER DEFAULT NULL,
    p_process_id IN NUMBER DEFAULT NULL,
    p_criteria_id IN NUMBER,
    p_txn IN NUMBER DEFAULT NULL,
    p_plan_state OUT nocopy plan_state_rec) IS

    ps refCursorTyp;
    pp_id number;

    BEGIN

        pp_id := p_process_plan_id;

        if pp_id is null then
            pp_id := get_process_plan_id(
            p_plan_id => p_plan_id,
            p_criteria_id => p_criteria_id,
            p_process_id => p_process_id,
            p_txn => p_txn);
        end if;

        if pp_id is not null and  pp_id <> -1 then
            open ps for
            'select
            qspp.plan_id,
            qspp.process_plan_id,
            qsa.process_id,
            qsp.disqualification_days,
            qsa.criteria_id,
            qspp.alternate_plan_id,
            qsps.current_rule,
            qsppr.rounds,
            qsppr.days_span,
            qsppr.frequency_num,
            qsppr.frequency_denom,
            qsps.current_round,
            qsps.current_lot,
            qsps.lot_accepted,
            qsps.rule_start_lot_id,
            qsps.rule_start_date,
            qsps.last_receipt_lot_id,
            qsps.last_receipt_date
            from qa_skiplot_association qsa,
            qa_skiplot_processes qsp,
            qa_skiplot_process_plans qspp,
            qa_skiplot_process_plan_rules qsppr,
            qa_skiplot_plan_states qsps
            where qsa.criteria_id = :1 and
            qsp.process_id = qsa.process_id and
            qspp.process_plan_id = :2 and
            qsppr.process_plan_id = qspp.process_plan_id and
            qsps.process_plan_id = qspp.process_plan_id and
            qsps.criteria_id = qsa.criteria_id and
            qsps.current_rule = qsppr.rule_seq'

            using p_criteria_id, pp_id;
            fetch ps into p_plan_state;
            close ps;
        end if;

    EXCEPTION
        WHEN OTHERS THEN
            insert_error_log (
            p_module_name => 'QA_SKIPLOT_UTILITY.FETCH_PLAN_STATE',
            p_error_message => 'fail to fetch plan state',
            p_comments => SUBSTR (SQLERRM , 1 , 240));
            APP_EXCEPTION.RAISE_EXCEPTION;

    END FETCH_PLAN_STATE;

    PROCEDURE INIT_PLAN_STATES(
    p_process_id IN NUMBER,
    p_criteria_id IN NUMBER,
    p_txn IN NUMBER) IS

    cursor p_plans (x_pid number) is
        select qspp.process_plan_id
        from qa_skiplot_process_plans qspp
        where process_id = x_pid;

    BEGIN

        for pp in p_plans (p_process_id) loop
            init_plan_state (
            p_process_plan_id => pp.process_plan_id,
            p_criteria_id => p_criteria_id,
            p_txn => p_txn);
        end loop;

        update_insp_stage(
        p_txn => p_txn,
        p_stage => 'QUALIFICATION',
        p_criteria_id =>p_criteria_id,
        p_process_id => p_process_id);


    END INIT_PLAN_STATES;

    PROCEDURE INIT_PLAN_STATE(
    p_plan_id IN NUMBER,
    p_criteria_id IN NUMBER,
    p_process_id IN NUMBER,
    p_txn IN NUMBER,
    p_lot_id IN NUMBER DEFAULT NULL,
    p_process_plan_id OUT NOCOPY NUMBER) IS

    pp_id number;

    BEGIN

        pp_id := get_process_plan_id
        (p_plan_id, p_criteria_id, p_process_id,p_txn);

        init_plan_state (
        p_process_plan_id => pp_id,
        p_criteria_id => p_criteria_id,
        p_txn => p_txn,
        p_lot_id => p_lot_id);

        p_process_plan_id := pp_id;

    END INIT_PLAN_STATE;

    PROCEDURE INIT_PLAN_STATE(
    p_process_plan_id IN NUMBER,
    p_criteria_id IN NUMBER,
    p_txn IN NUMBER,
    p_lot_id IN NUMBER DEFAULT NULL) IS

    first_rule number;
    last_date date;
    last_receipt_lot number;
    old_rule number;


    BEGIN
        first_rule := get_first_rule_num(p_process_plan_id);

        if p_process_plan_id is null or p_process_plan_id = -1 or
           p_criteria_id is null or p_criteria_id = -1 then

            --
            -- insert into error log
            --
            insert_error_log (
            p_module_name =>'QA_SKIPLOT_UTILITY.INIT_PLAN_STATE',
            p_error_message => 'QA_SKIPLOT_INIT_STATE_FAILURE',
            p_comments => 'process_plan_id or criteria_id not available');

            fnd_message.set_name ('QA', 'QA_SKIPLOT_INIT_STATE_FAILURE');
            APP_EXCEPTION.RAISE_EXCEPTION;

        end if;

        delete qa_skiplot_plan_states where
        process_plan_id = p_process_plan_id and
        criteria_id = p_criteria_id
        returning current_rule, last_receipt_date, last_receipt_lot_id into
        old_rule, last_date, last_receipt_lot;

        --
        -- in wip p_receipt_date will be null,
        -- use sysdate
        --
        insert into qa_skiplot_plan_states(
        PROCESS_PLAN_ID,
        CRITERIA_ID,
        CURRENT_RULE,
        CURRENT_ROUND,
        CURRENT_LOT,
        LOT_ACCEPTED,
        RULE_START_LOT_ID,
        RULE_START_DATE,
        LAST_RECEIPT_LOT_ID,
        LAST_RECEIPT_DATE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN)
        values(
        p_process_plan_id,
        p_criteria_id,
        first_rule,
        1,
        0,
        0,
        p_lot_id,
        decode(p_lot_id, null, null, sysdate),
        nvl(p_lot_id,last_receipt_lot),
        nvl(last_date,sysdate),
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        fnd_global.login_id);

        update_state_history (
        p_process_plan_id => p_process_plan_id,
        p_criteria_id => p_criteria_id,
        p_old_rule => old_rule,
        p_new_rule => first_rule,
        p_txn => p_txn);

    EXCEPTION
        WHEN OTHERS THEN
            insert_error_log (
            p_module_name => 'QA_SKIPLOT_UTILITY.INIT_PLAN_STATE',
            p_error_message => 'fail to delete and insert initial plan state',
            p_comments => SUBSTR (SQLERRM , 1 , 240));

    END INIT_PLAN_STATE;

    PROCEDURE INIT_PLAN_STATES(
    p_criteria_id IN NUMBER) IS

    cursor plan_states (x_cid number) is
        select qspp.process_plan_id
        from qa_skiplot_association qsa,
        qa_skiplot_process_plans qspp
        where qsa.criteria_id = x_cid and
        qsa.process_id = qspp.process_id;

    BEGIN
        for ps in plan_states (p_criteria_id) loop
            update_plan_state (
            p_process_plan_id => ps.process_plan_id,
            p_criteria_id => p_criteria_id,
            p_next_rule => 0,
            p_next_round => 1,
            p_next_lot => 0,
            p_lot_accepted => 0);
        end loop;

        EXCEPTION
        WHEN OTHERS THEN
            insert_error_log (
            p_module_name => 'QA_SKIPLOT_UTILITY.INIT_PLAN_STATES',
            p_error_message => 'fail to update qa_skiplot_plan_states',
            p_comments => SUBSTR (SQLERRM , 1 , 240));
    END INIT_PLAN_STATES;

    --
    -- Bug 5037121
    -- Added a new procedure to reset the last receipt date to the
    -- sysdate, in case the plan state is reset due to the day span
    -- getting violated
    -- ntungare Wed Feb 15 07:29:08 PST 2006
    --
    PROCEDURE RESET_LAST_RECEIPT_DATE(
    p_criteria_id     IN NUMBER,
    p_process_plan_id IN NUMBER) IS

    BEGIN
        UPDATE qa_skiplot_plan_states
          SET last_receipt_date = SYSDATE,
              last_update_date  = SYSDATE,
              last_updated_by   = fnd_global.user_id,
              last_update_login = fnd_global.login_id
         WHERE process_plan_id  = p_process_plan_id AND
               criteria_id      = p_criteria_id;
    END RESET_LAST_RECEIPT_DATE;


    PROCEDURE RESET_PLAN_STATES(
    p_process_id IN NUMBER) IS

    cursor plan_states (x_pid number) is
        select qspp.process_plan_id,
        qsa.criteria_id
        from qa_skiplot_process_plans qspp,
        qa_skiplot_association qsa
        where qspp.process_id = x_pid and
        qspp.process_id = qsa.process_id;

    BEGIN

        for ps in plan_states (p_process_id) loop
            update_plan_state (
            p_process_plan_id => ps.process_plan_id,
            p_criteria_id => ps.criteria_id,
            p_next_rule => 0,
            p_next_round => 1,
            p_next_lot => 0,
            p_lot_accepted => 0);
        end loop;

        EXCEPTION
        WHEN OTHERS THEN
            insert_error_log (
            p_module_name => 'QA_SKIPLOT_UTILITY.RESET_PLAN_STATES',
            p_error_message => 'fail to update qa_skiplot_plan_states',
            p_comments => SUBSTR (SQLERRM , 1 , 240));
    END RESET_PLAN_STATES;

    FUNCTION INSP_ROUND_FINISHED(
    p_plan_state IN plan_state_rec) RETURN VARCHAR2 IS

    current_lot number;
    total_lots number;
    current_rule number;
    total_round number;

    BEGIN

        current_rule := p_plan_state.current_rule;
        current_lot := p_plan_state.current_lot;
        total_lots := p_plan_state.current_freq_denom;
        total_round := p_plan_state.total_round;

        --
        -- add this if statement to fix bug 2125382
        -- if qualification lot is 0 or null, mark round as finished
        -- jezheng
        -- Thu Nov 29 16:56:22 PST 2001
        --
        if current_rule = 0 and (total_round = 0 or total_round is null) then
            return fnd_api.g_true;
        end if;

        if current_lot is not null and total_lots is not null and
           current_lot - total_lots >= 0 then
            return fnd_api.g_true;
        end if;

        return fnd_api.g_false;

    END INSP_ROUND_FINISHED;


    FUNCTION INSP_RULE_FINISHED(
    p_plan_state IN plan_state_rec)RETURN VARCHAR2 IS

    c_round number;
    total_round number;
    current_rule number;

    BEGIN
        current_rule := p_plan_state.current_rule;
        c_round := p_plan_state.current_round;
        total_round := p_plan_state.total_round;

        --
        -- added if statement to fix bug 2125382
        -- when quanlification lots is 0, always mark rule as finished
        -- jezheng
        -- Thu Nov 29 16:56:05 PST 2001
        --
        if current_rule = 0 and (total_round = 0 or total_round is null) then
            return fnd_api.g_true;
        end if;

        if c_round is not null and
           total_round is not null and
           c_round >= total_round and
           insp_round_finished(p_plan_state) = fnd_api.g_true then

           return fnd_api.g_true;
        end if;

        return fnd_api.g_false;

    END INSP_RULE_FINISHED;


    FUNCTION GET_NEXT_INSP_RULE (
    p_plan_state in plan_state_rec)RETURN NUMBER IS

    next_rule number;

    cursor rule (pp_id in number, current_rule in number)is
        select min(rule_seq)
        from qa_skiplot_process_plan_rules
        where process_plan_id = pp_id and
        rule_seq > current_rule;

    BEGIN
        open rule(
        p_plan_state.process_plan_id,
        p_plan_state.current_rule);

        fetch rule into next_rule;

        if rule%notfound or next_rule is null then
            next_rule := -1;
        end if;
        return next_rule;

    END GET_NEXT_INSP_RULE;

    FUNCTION MORE_ROUNDS(
    p_plan_state IN plan_state_rec) RETURN VARCHAR2 IS

    BEGIN

         If (get_next_insp_rule(p_plan_state) = -1) and (p_plan_state.total_round is null) then
            return fnd_api.g_true;
        elsif p_plan_state.total_round - p_plan_state.current_round >0 then
            return fnd_api.g_true;
        else
            return fnd_api.g_false;
        end if;

    END MORE_ROUNDS;

    FUNCTION ENOUGH_LOT_ACCEPTED(
    p_plan_state IN plan_state_rec) RETURN VARCHAR2 IS

    accepted_num number;
    required_num number;

    BEGIN
        accepted_num := p_plan_state.lot_accepted;
        required_num := p_plan_state.current_freq_num;

        if accepted_num is not null and required_num is not null and
           accepted_num - required_num >= 0 then
            return fnd_api.g_true;
        end if;


        return fnd_api.g_false;
    END ENOUGH_LOT_ACCEPTED;



    FUNCTION DATE_REASONABLE(
    p_receipt_date IN DATE DEFAULT NULL,
    p_check_mode IN NUMBER,
    p_plan_state plan_state_rec)RETURN VARCHAR2 IS

    c_date DATE;
    day_span NUMBER;

    BEGIN

        --
        -- receipt date is checked in two scenarios:
        -- ADJACENT_DATE_CHECK and DATE_SPAN_CHECK
        --
        if p_check_mode = ADJACENT_DATE_CHECK then
            return check_adjacent_date(p_receipt_date, p_plan_state);
        elsif p_check_mode = DATE_SPAN_CHECK then
            return check_date_span (p_plan_state);
        else
            -- unknow mode
            -- treat as no restriction.
            return fnd_api.g_true;
        end if;
    END DATE_REASONABLE;

    PROCEDURE UPDATE_INSP_STAGE (
    p_txn IN NUMBER,
    p_stage IN VARCHAR2,
    p_criteria_id IN NUMBER,
    p_process_id IN NUMBER)IS

    BEGIN

        --
        -- removed the if statement as it's really unnecessary.
        -- Reference bug 2137211
        -- jezheng
        -- Wed Mar 17 15:41:02 PST 2004
        --
        --if p_txn = RCV then
            update qa_skiplot_association
            set insp_stage = p_stage
            where criteria_id = p_criteria_id and
            process_id = p_process_id;
        --end if;

    END UPDATE_INSP_STAGE;

    PROCEDURE UPDATE_PLAN_STATE(
    p_process_plan_id IN NUMBER,
    p_criteria_id IN NUMBER,
    p_next_rule IN NUMBER DEFAULT NULL,
    p_next_round IN NUMBER DEFAULT NULL,
    p_next_lot IN NUMBER DEFAULT NULL,
    p_rule_start_lotid IN NUMBER DEFAULT NULL,
    p_last_receipt_lot_id IN NUMBER DEFAULT NULL,
    p_lot_accepted IN NUMBER DEFAULT NULL,
    p_txn IN NUMBER DEFAULT NULL) IS

    old_plan_state plan_state_rec;
    x_rule_start_date date;

    BEGIN


        fetch_plan_state (
        p_process_plan_id => p_process_plan_id,
        p_criteria_id => p_criteria_id,
        p_txn => p_txn,
        p_plan_state => old_plan_state);

        if p_next_rule is not null or
           (p_rule_start_lotid is not null and
            p_rule_start_lotid <> old_plan_state.rule_start_lot_id) then
            x_rule_start_date := sysdate;
        else
            x_rule_start_date := old_plan_state.rule_start_date;
        end if;

        update qa_skiplot_plan_states
        set current_rule = nvl(p_next_rule, current_rule),
        current_round = nvl(p_next_round, current_round),
        current_lot = nvl(p_next_lot, current_lot),
        lot_accepted = nvl(p_lot_accepted, lot_accepted),
        last_receipt_lot_id = nvl(p_last_receipt_lot_id, last_receipt_lot_id),
        last_receipt_date = decode(p_last_receipt_lot_id, null, last_receipt_date, sysdate),
        rule_start_lot_id = nvl(p_rule_start_lotid, rule_start_lot_id),
        rule_start_date = x_rule_start_date,
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.login_id
        where process_plan_id = p_process_plan_id and
        criteria_id = p_criteria_id;

        if p_next_rule is not null then
            update_state_history (
            p_old_plan_state => old_plan_state,
            p_next_rule => p_next_rule,
            p_txn => p_txn);

            --
            -- rule 0 is the system default 1/1 frequency
            -- if we pass this frequency, it means the inspection stage
            -- is changing to skipping stage
            --
            if  p_next_rule > 0 then
                update_insp_stage(
                p_txn => p_txn,
                p_stage => 'SKIPPING',
                p_criteria_id => p_criteria_id,
                p_process_id => get_process_id (p_process_plan_id));
            else -- p_next_rule = 0
                update_insp_stage(
                p_txn => p_txn,
                p_stage => 'QUALIFICATION',
                p_criteria_id =>p_criteria_id,
                p_process_id => get_process_id(p_process_plan_id));
            end if;
        end if;

    EXCEPTION
        WHEN OTHERS THEN
            insert_error_log (
            p_module_name => 'QA_SKIPLOT_UTILITY.UPDATE_PLAN_STATE',
            p_error_message => 'QA_SKIPLOT_UPDATE_STATE_FAILURE',
            p_comments => SUBSTR (SQLERRM , 1 , 240));

    END UPDATE_PLAN_STATE;


    -- local function
    procedure get_process_info (
    p_process_plan_id in number,
    p_process_id out NOCOPY number,
    p_process_code out NOCOPY varchar2,
    p_process_desc out NOCOPY varchar2) is

    cursor process_info (x_ppid number) is
        select qsp.process_id, qsp.process_code, qsp.description
        from qa_skiplot_processes qsp, qa_skiplot_process_plans qspp
        where qspp.process_plan_id = x_ppid and
        qspp.process_id = qsp.process_id;

    begin
        open process_info(p_process_plan_id);
        fetch process_info into p_process_id, p_process_code, p_process_desc;
        close process_info;
    end get_process_info;


    -- local function
    function get_rcv_criteria_str(
    p_criteria_id in number,
    p_wf_role_name out NOCOPY varchar2) return varchar2 is

    cursor rcv_criteria (x_criteria_id number) is
        select vendor_name,
        vendor_site_code,
        item,
        item_revision,
        category_desc,
        manufacturer_name,
        project_number,
        task_number,
        wf_role_name
        from qa_skiplot_rcv_criteria_v
        where criteria_id = x_criteria_id;

    cursor char_names is
        select name
        from qa_chars
        where char_id in (10, 11, 13, 26, 121, 122, 130)
        order by char_id;

    x_supplier qa_chars.name%type;
    x_supplier_site qa_chars.name%type;
    x_item qa_chars.name%type;
    x_rev qa_chars.name%type;
    x_cat qa_chars.name%type;
    x_project qa_chars.name%type;
    x_task qa_chars.name%type;
    x_manufacturer varchar2(50);

    x_criteria_str varchar2(2000) := '';
    x_vendor_name varchar2(240);
    x_vendor_site_code varchar2(100);
    x_item_name varchar2(40);
    x_item_rev varchar2(30);
    x_item_cat varchar2(500);
    x_manufacturer_name varchar2(30);
    x_project_number varchar2(100);
    x_task_number varchar2(25);

    begin
        open rcv_criteria (p_criteria_id);
        fetch rcv_criteria into
        x_vendor_name,
        x_vendor_site_code,
        x_item_name,
        x_item_rev,
        x_item_cat,
        x_manufacturer_name,
        x_project_number,
        x_task_number,
        p_wf_role_name;

        close rcv_criteria;

        if p_wf_role_name is null then
            return null;
        end if;

        --
        -- fetch the translated name for these collection
        -- elements
        --
        open char_names;
        fetch char_names into x_item; -- char_id 10
        fetch char_names into x_cat; -- char_id 11
        fetch char_names into x_rev; -- char_id 13
        fetch char_names into x_supplier; -- char_id 26
        fetch char_names into x_project; -- char_id 121
        fetch char_names into x_task; -- char_id 122
        fetch char_names into x_supplier_site; -- char_id 130
        close char_names;

        --
        -- manufacturer is not a collection element
        -- retrieve the translated name from data dictionary
        -- jezheng
        -- Tue Oct 30 08:42:46 HKT 2001
        --
        x_manufacturer := fnd_message.get_string ('QA', 'QA_MANUFACTURER');

        if x_vendor_name is not null then
            x_criteria_str := x_criteria_str ||
            x_supplier || ' = ' || x_vendor_name || '; ';
        end if;
        if x_vendor_site_code is not null then
            x_criteria_str :=  x_criteria_str ||
            x_supplier_site || ' = ' ||x_vendor_site_code || '; ';
        end if;
        if x_item_name is not null then
            x_criteria_str := x_criteria_str ||
            x_item || ' = ' || x_item_name || '; ';
        end if;
        if x_item_rev is not null then
            x_criteria_str := x_criteria_str ||
            x_rev || ' = ' || x_item_rev || '; ';
        end if;
        if x_item_cat is not null then
            x_criteria_str := x_criteria_str ||
            x_cat || ' = ' || x_item_cat || '; ';
        end if;
        if x_manufacturer_name is not null then
            x_criteria_str := x_criteria_str ||
            x_manufacturer || ' = ' || x_manufacturer_name || '; ';
        end if;
        if x_project_number is not null then
            x_criteria_str := x_criteria_str ||
            x_project || ' = ' || x_project_number || '; ';
        end if;
        if x_task_number is not null then
            x_criteria_str := x_criteria_str ||
            x_task || ' = ' || x_task_number || '; ';
        end if;

        return x_criteria_str;
    end get_rcv_criteria_str;

    -- local function
    function get_coll_plan_name (
    p_process_plan_id in number)return varchar2 is

    cursor coll_plan (x_process_plan_id number) is
        select qp.name
        from qa_plans qp, qa_skiplot_process_plans qspp
        where qspp.process_plan_id = x_process_plan_id and
        qspp.plan_id = qp.plan_id;

    x_coll_plan_name varchar2(30);

    begin
        open coll_plan (p_process_plan_id);
        fetch coll_plan into x_coll_plan_name;
        close coll_plan;

        return x_coll_plan_name;
    end get_coll_plan_name;


    PROCEDURE LAUNCH_WORKFLOW (
    p_process_plan_id IN NUMBER,
    p_criteria_id IN NUMBER,
    p_old_freq_num IN NUMBER,
    p_old_freq_denom IN NUMBER,
    p_new_freq_num IN NUMBER,
    p_new_freq_denom IN NUMBER,
    p_txn IN NUMBER) IS

    x_process_id number;
    x_process_code varchar2(30);
    x_process_desc varchar2(300);
    x_plan_name varchar2(30);
    x_from_freq_str varchar2(30);
    x_to_freq_str varchar2(30);
    x_criteria_str varchar2(2000);
    x_wf_role_name varchar2(360);
    x_wf_itemkey number;

    BEGIN
        if p_txn is not null and p_txn <> RCV then
            return;
        end if;

        x_criteria_str := get_rcv_criteria_str(p_criteria_id,x_wf_role_name);
        if x_wf_role_name is null then
            return;
        end if;

        get_process_info (
        p_process_plan_id,
        x_process_id, -- out parameter
        x_process_code, -- out parameter
        x_process_desc); -- out parameter

        if x_process_id is null then
            return;
        end if;

        x_plan_name := get_coll_plan_name (p_process_plan_id);

        x_from_freq_str := p_old_freq_num || '/' || p_old_freq_denom;
        x_to_freq_str := p_new_freq_num || '/' || p_new_freq_denom;

        x_wf_itemkey := qa_inspection_wf.raise_frequency_change_event(
        p_process_code => x_process_code,
        p_description => x_process_desc,
        p_inspection_plan => x_plan_name,
        p_from_frequency => x_from_freq_str,
        p_to_frequency => x_to_freq_str,
        p_criteria => x_criteria_str,
        p_role_name => x_wf_role_name);

    EXCEPTION
        WHEN OTHERS THEN
            insert_error_log (
            p_module_name => 'QA_SKIPLOT_UTILITY.LAUNCH_WORKFLOW',
            p_error_message => 'QA_SKIPLOT_WORKFLOW_FAILURE',
            p_comments => SUBSTR (SQLERRM , 1 , 240));

    END LAUNCH_WORKFLOW;


    PROCEDURE UPDATE_STATE_HISTORY(
    p_old_plan_state IN plan_state_rec,
    p_next_rule IN NUMBER,
    p_txn IN NUMBER DEFAULT NULL) IS

    new_freq_num number;
    new_freq_denom number;

    BEGIN

        check_rule_frequency (
        p_process_plan_id => p_old_plan_state.process_plan_id,
        p_rule_seq => p_next_rule,
        p_freq_num => new_freq_num, -- out parameter
        p_freq_denom => new_freq_denom); -- out parameter

        update_state_history (
        p_process_plan_id => p_old_plan_state.process_plan_id,
        p_criteria_id => p_old_plan_state.criteria_id,
        p_old_freq_num => p_old_plan_state.current_freq_num,
        p_old_freq_denom => p_old_plan_state.current_freq_denom,
        p_new_freq_num => new_freq_num,
        p_new_freq_denom => new_freq_denom,
        p_txn => p_txn);

    END UPDATE_STATE_HISTORY;


    PROCEDURE UPDATE_STATE_HISTORY(
    p_process_plan_id IN NUMBER,
    p_criteria_id IN NUMBER,
    p_old_rule IN NUMBER,
    p_new_rule IN NUMBER,
    p_txn IN NUMBER) IS

    old_freq_num number;
    old_freq_denom number;
    new_freq_num number;
    new_freq_denom number;

    BEGIN
        check_rule_frequency (
        p_process_plan_id,
        p_old_rule,
        old_freq_num, -- out parameter
        old_freq_denom); -- out parameter

        check_rule_frequency (
        p_process_plan_id,
        p_new_rule,
        new_freq_num, -- out parameter
        new_freq_denom);  -- out parameter

        update_state_history (
        p_process_plan_id => p_process_plan_id,
        p_criteria_id => p_criteria_id,
        p_old_freq_num => old_freq_num,
        p_old_freq_denom => old_freq_denom,
        p_new_freq_num => new_freq_num,
        p_new_freq_denom => new_freq_denom,
        p_txn => p_txn);

    END UPDATE_STATE_HISTORY;

    PROCEDURE UPDATE_STATE_HISTORY(
    p_process_plan_id IN NUMBER,
    p_criteria_id IN NUMBER,
    p_old_freq_num IN NUMBER,
    p_old_freq_denom IN NUMBER,
    p_new_freq_num IN NUMBER,
    p_new_freq_denom IN NUMBER,
    p_txn IN NUMBER) IS

    BEGIN

        insert into qa_skiplot_state_history(
        PROCESS_PLAN_ID,
        CRITERIA_ID,
        CHANGE_DATE,
        OLD_FREQ_NUM,
        OLD_FREQ_DENOM,
        NEW_FREQ_NUM,
        NEW_FREQ_DENOM,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN)
        values(
        p_process_plan_id,
        p_criteria_id,
        sysdate,
        p_old_freq_num,
        p_old_freq_denom,
        p_new_freq_num,
        p_new_freq_denom,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        fnd_global.login_id);

        launch_workflow (
        p_process_plan_id => p_process_plan_id,
        p_criteria_id => p_criteria_id,
        p_old_freq_num => p_old_freq_num,
        p_old_freq_denom => p_old_freq_denom,
        p_new_freq_num => p_new_freq_num,
        p_new_freq_denom => p_new_freq_denom,
        p_txn => p_txn);


    EXCEPTION
        WHEN OTHERS THEN
            insert_error_log (
            p_module_name => 'QA_SKIPLOT_UTILITY.UPDATE_STATE_HISTORY',
            p_error_message => 'QA_SKIPLOT_UPDATE_HISTORY_FAILURE',
            p_comments => SUBSTR (SQLERRM , 1 , 240));
    END UPDATE_STATE_HISTORY;

    PROCEDURE INSERT_ERROR_LOG (
    p_module_name IN VARCHAR2,
    p_error_message IN VARCHAR2 DEFAULT NULL,
    p_comments IN VARCHAR2 DEFAULT NULL) IS

    PRAGMA AUTONOMOUS_TRANSACTION;

    x_logid number;
    cursor id is
        select qa_skiplot_log_id_s.nextval
        from dual;

    cursor c (x_id number)is
    select 1 from qa_skiplot_log
    where log_id = x_id;

    existing_flag number;

    BEGIN

        open id;
        fetch id into x_logid;
        close id;

        --
        -- qa_skiplot_log_id_s is a cycle sequence
        -- the purpose is to control log table size
        --
        open c (x_logid);
        fetch c into existing_flag;
        close c;

        if existing_flag is null then
            insert into qa_skiplot_log(
            LOG_ID,
            MODULE_NAME,
            ERROR_MESSAGE,
            COMMENTS,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN)
            values(
            x_logid,
            p_module_name,
            p_error_message,
            p_comments,
            sysdate,
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id,
            fnd_global.login_id);
        else
            update qa_skiplot_log
            set MODULE_NAME = p_module_name,
            ERROR_MESSAGE = p_error_message,
            COMMENTS = p_comments,
            LAST_UPDATE_DATE = sysdate,
            LAST_UPDATED_BY = fnd_global.user_id,
            CREATION_DATE = sysdate,
            CREATED_BY = fnd_global.user_id,
            LAST_UPDATE_LOGIN = fnd_global.login_id
            where LOG_ID = x_logid;
        end if;

        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            rollback;

    END INSERT_ERROR_LOG;

    FUNCTION GET_LOT_ID RETURN NUMBER IS

    x_lotID number;
    cursor id is
        select qa_skiplot_lot_id_s.nextval
        from dual;

    BEGIN
        open id;
        fetch id into x_lotID;
        close id;

        return x_lotID;

    END GET_LOT_ID;

    FUNCTION INSPECT_ZERO (
    p_plan_state IN plan_state_rec,
    p_txn IN NUMBER DEFAULT NULL) RETURN VARCHAR2 IS

    next_rule number;
    next_freq_num number;
    next_freq_denom number;

    BEGIN
        next_rule := GET_NEXT_INSP_RULE (p_plan_state);
        CHECK_RULE_FREQUENCY(
        p_process_plan_id => p_plan_state.process_plan_id,
        p_rule_seq => next_rule,
        p_freq_num => next_freq_num,
        p_freq_denom => next_freq_denom);

        if next_freq_num = 0 then

            --
            -- set inspection stage to Skipping when no
            -- inspection is required
            -- Reference bug 2940984
            -- jezheng
            -- Wed Mar 17 14:56:08 PST 2004
            --

            update_insp_stage(
            p_txn => nvl(p_txn, RCV),
            p_stage => 'SKIPPING',
            p_criteria_id => p_plan_state.criteria_id,
            p_process_id => p_plan_state.process_id);

            return fnd_api.g_true;
        else
            return fnd_api.g_false;
        end if;
    END INSPECT_ZERO;

    FUNCTION GET_PROCESS_ID (
    p_process_plan_id IN NUMBER) RETURN NUMBER IS

    cursor pid (x_ppid number) is
        select process_id
        from qa_skiplot_process_plans
        where process_plan_id = x_ppid;
    proc_id number;

    BEGIN
        open pid (p_process_plan_id);
        fetch pid into proc_id;
        close pid;
        return nvl(proc_id, -1);
    END GET_PROCESS_ID;

END QA_SKIPLOT_UTILITY;


/
