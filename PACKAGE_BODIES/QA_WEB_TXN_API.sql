--------------------------------------------------------
--  DDL for Package Body QA_WEB_TXN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_WEB_TXN_API" AS
/* $Header: qlttxnwb.plb 120.7.12010000.2 2009/06/29 11:46:48 skolluku ship $ */

g_module_name CONSTANT VARCHAR2(60):= 'qa.plsql.qa_web_txn_api';

FUNCTION evaluate_triggers (p_context_table in qa_ss_const.ctx_table,
    p_txn_number IN NUMBER,
    p_org_id IN NUMBER,
    p_optimize_flag IN NUMBER,
    p_mandatory_flag IN NUMBER DEFAULT NULL,
    p_background_flag IN NUMBER DEFAULT NULL,
    p_plans_table IN OUT NOCOPY qa_ss_const.num_table)
    RETURN BOOLEAN IS

    -- The p_optimize_flag parameter is an optimization hint. A value 2 for
    -- p_optimize_flag means optimize. As as soon as one plan apply we should
    -- immediately return true. On the other hand, if the p_optimize_flag
    -- passed is 1 then go ahead and find all the applicable plans
    -- (populate the out table and then return.

    CURSOR trigger_cur IS
	SELECT 	qpt.plan_transaction_id,
	       	qpt.plan_id,
	       	qc.char_id,
               	qc.dependent_char_id,
	       	qc.datatype,
	       	qpct.operator,
	       	qpct.low_value,
	       	qpct.high_value
	FROM 	qa_plan_collection_triggers qpct,
		qa_plan_transactions qpt,
		qa_plans_val_v qp,
        	qa_chars qc,
		qa_txn_collection_triggers qtct
	WHERE 	qpt.plan_id = qp.plan_id
	AND 	qpct.plan_transaction_id(+) = qpt.plan_transaction_id
        AND 	qpct.collection_trigger_id = qtct.collection_trigger_id(+)
        AND 	qpct.collection_trigger_id = qc.char_id(+)
	AND 	qpt.transaction_number = p_txn_number
        AND 	qtct.transaction_number(+) = p_txn_number
        AND 	qp.organization_id = p_org_id
        AND 	qpt.enabled_flag = 1
        AND 	qpt.mandatory_collection_flag =
                NVL(p_mandatory_flag, qpt.mandatory_collection_flag)
        AND 	qpt.background_collection_flag =
                NVL(p_background_flag, qpt.background_collection_flag)
	ORDER BY qpt.plan_transaction_id;

    type coll_trigg_type IS TABLE OF trigger_cur%ROWTYPE
        INDEX BY BINARY_INTEGER;
    coll_trigg_tab  coll_trigg_type;

    plan_is_applicable BOOLEAN;
    counter INTEGER;
    i INTEGER := 1;
    l_rowcount INTEGER;
    l_datatype NUMBER;
    l_operator NUMBER;
    l_low_char VARCHAR2(150);
    l_high_char VARCHAR2(150);
    l_low_number NUMBER;
    l_high_number NUMBER;
    l_low_date DATE;
    l_high_date DATE;
    l_value_char VARCHAR2(150);
    l_value_number NUMBER;
    l_value_date DATE;
    l_plan_id	NUMBER;
    l_old_plan_id NUMBER;
    l_plan_txn_id NUMBER ;
    l_old_plan_txn_id NUMBER ;
    l_char_id NUMBER;
    l_dep_char_id NUMBER;
    pid_count NUMBER := 0;
    atleast_one BOOLEAN;

BEGIN

    atleast_one := FALSE;
    counter := 1;

    FOR ct_rec IN trigger_cur LOOP
	coll_trigg_tab(counter) := ct_rec;
	counter := counter + 1;
    END LOOP;

    l_rowcount := coll_trigg_tab.count;

    IF (l_rowcount < 1) THEN -- no plans apply
        RETURN FALSE;
    END IF;

    l_plan_txn_id := coll_trigg_tab(1).plan_transaction_id;

    -- The variable i has been  initialized to 1

    WHILE ( i <= l_rowcount) LOOP

        l_old_plan_txn_id := l_plan_txn_id;
        plan_is_applicable := TRUE; -- start with this assumption

        WHILE (l_plan_txn_id = l_old_plan_txn_id) AND (i <= l_rowcount) LOOP

            IF (plan_is_applicable = TRUE) THEN

                l_operator := coll_trigg_tab(i).Operator;
                l_datatype := coll_trigg_tab(i).Datatype;
                l_char_id := coll_trigg_tab(i).char_id;

                IF (l_operator is NULL) AND (l_datatype is NULL) THEN
                    null;  -- null collection trigger. Plan applies
                ELSE
                    -- watch out for exceptions while accessing
                    -- p_context_table below
                    IF (qltcompb.compare(p_context_table(l_char_id),
                        l_operator, coll_trigg_tab(i).low_value,
                        coll_trigg_tab(i).high_value, l_datatype)) THEN
                        plan_is_applicable := TRUE;
                    ELSE
                        plan_is_applicable := FALSE;
                    END IF; --end qltcompb
                 END IF;  -- end l_operator and l_datatype null

             END IF; -- end Check plan applicable is true

             i := i+1;

             IF (i <= l_rowcount) THEN
                 l_plan_txn_id := coll_trigg_tab(i).plan_transaction_id;
             END IF;

         END LOOP; -- end inner while loop

         IF (plan_is_applicable = TRUE) THEN
              atleast_one := TRUE;
              -- if p_optimize_flag is 2, stop here itself and return True
              IF (p_optimize_flag = 2) THEN
                   RETURN TRUE;
              END IF;
              -- if p_optimize_flag is not 2, then keep continuing
              pid_count := pid_count + 1;
              -- at very beginning pid_count is ZERO
              p_plans_table(pid_count) := coll_trigg_tab(i-1).plan_id;
          END IF;

      END LOOP; -- end outer while loop

      RETURN atleast_one;

END evaluate_triggers;


FUNCTION check_plan_for_applicability (
    p_context_table IN qa_ss_const.ctx_table,
    p_txn_number IN NUMBER,
    p_org_id IN NUMBER,
    p_plan_id IN NUMBER)
    RETURN VARCHAR2 IS

    CURSOR coll_trigg_cur IS
        SELECT qpt.plan_transaction_id,
	    qpt.plan_id,
	    qc.char_id,
            qc.dependent_char_id,
	    qc.datatype,
	    qpct.operator,
	    qpct.low_value,
	    qpct.high_value
        FROM qa_plan_collection_triggers qpct,
	    qa_plan_transactions qpt,
	    qa_plans qp,
            qa_chars qc,
	    qa_txn_collection_triggers qtct
	WHERE qp.plan_id = p_plan_id
	and qpt.plan_id = qp.plan_id
	and qpct.plan_transaction_id(+) = qpt.plan_transaction_id
        and qpct.collection_trigger_id = qtct.collection_trigger_id(+)
        and qpct.collection_trigger_id = qc.char_id(+)
	and qpt.transaction_number = p_txn_number
        and qtct.transaction_number(+) = p_txn_number
        and qp.organization_id = p_org_id
        and qpt.enabled_flag = 1
        ORDER BY qpt.plan_transaction_id;

    --
    -- Bug 2891093
    -- 'qa_txn_collection_triggers qtct' is used in FROM clause
    -- which is not required at all.
    -- Removed this to fix the SQL Repository issue
    --
    -- rkunchal Mon Apr  7 21:58:22 PDT 2003
    --
    CURSOR coll_trigg_cur_for_asset IS
        SELECT qpt.plan_transaction_id,
	    qpt.plan_id,
	    qc.char_id,
            qc.dependent_char_id,
	    qc.datatype,
	    qpct.operator,
	    qpct.low_value,
	    qpct.high_value
        FROM qa_plan_collection_triggers qpct,
	    qa_plan_transactions qpt,
	    qa_plans qp,
            qa_chars qc
	WHERE qp.plan_id = p_plan_id
	and qpt.plan_id = qp.plan_id
	and qpct.plan_transaction_id(+) = qpt.plan_transaction_id
        and qpct.collection_trigger_id = qc.char_id(+)
	and qpt.transaction_number in (31, 32, 33)
        and qp.organization_id = p_org_id
        and qpt.enabled_flag = 1
        ORDER BY qpt.plan_transaction_id;

    type coll_trigg_type IS TABLE OF coll_trigg_cur%ROWTYPE
        INDEX BY BINARY_INTEGER;
    coll_trigg_tab  coll_trigg_type;

    plan_is_applicable 	BOOLEAN;
    atleast_one 	BOOLEAN;
    counter 		INTEGER;
    l_rowcount 		INTEGER;
    i 			INTEGER := 1;

    pid_count		NUMBER := 0;

    l_datatype		NUMBER;
    l_operator		NUMBER;
    l_low_number	NUMBER;
    l_high_number	NUMBER;
    l_value_number	NUMBER;
    l_plan_id		NUMBER;
    l_old_plan_id	NUMBER;
    l_plan_txn_id	NUMBER ;
    l_old_plan_txn_id	NUMBER ;
    l_char_id		NUMBER;
    l_dep_char_id	NUMBER;

    l_low_char 		VARCHAR2(150);
    l_high_char 	VARCHAR2(150);
    l_value_char 	VARCHAR2(150);

    l_low_date 		DATE;
    l_high_date 	DATE;
    l_value_date 	DATE;


BEGIN
    atleast_one := FALSE;
    counter := 1;

    if p_txn_number = 32 then
    	FOR ct_rec in coll_trigg_cur_for_asset LOOP
	    coll_trigg_tab(counter) := ct_rec;
	    counter := counter + 1;
    	END LOOP;
    else
    	FOR ct_rec in coll_trigg_cur LOOP
	    coll_trigg_tab(counter) := ct_rec;
	    counter := counter + 1;
    	END LOOP;
    end if;

    l_rowcount := coll_trigg_tab.count;

    IF (l_rowcount < 1) THEN
        RETURN 'N'; -- no plans applicable
    END IF;

    l_plan_txn_id := coll_trigg_tab(1).plan_transaction_id;

    -- The variable i has been  initialized to 1

    WHILE ( i <= l_rowcount) LOOP
        l_old_plan_txn_id := l_plan_txn_id;
        plan_is_applicable := TRUE; -- start with this assumption

        WHILE (l_plan_txn_id = l_old_plan_txn_id) AND (i <= l_rowcount) LOOP
            IF (plan_is_applicable = TRUE) THEN
                l_operator := coll_trigg_tab(i).Operator;
                l_datatype := coll_trigg_tab(i).Datatype;
                l_char_id := coll_trigg_tab(i).char_id;

                IF (l_operator is NULL) AND (l_datatype is NULL) THEN
                    null;
                   -- null collection trigger. Plan applies
                ELSE
                    -- WATCH OUT FOR EXCEPTIONS while
                    -- accessing Ctx table below
                    IF (qltcompb.compare( p_context_table(l_char_id),
                            l_operator, coll_trigg_tab(i).Low_value,
                            coll_trigg_tab(i).High_Value,l_datatype)) THEN
                                        plan_is_applicable := TRUE;
                    ELSE
                        plan_is_applicable := FALSE;
                    END IF; --end qltcompb
                END IF;  -- end l_operator and l_datatype null
            END IF; -- end Check plan applicable is true

            i := i+1;
            IF (i <= l_rowcount) THEN
                l_plan_txn_id := coll_trigg_tab(i).plan_transaction_id;
            END IF;
        END LOOP; -- end inner while loop
        IF (plan_is_applicable = TRUE) THEN
            RETURN 'Y';
	END IF;

            -- if flag is not 2, then keep continuing

   END LOOP; -- end outer while loop

   RETURN 'N';

END check_plan_for_applicability;


FUNCTION plan_applicable_for_txn ( p_plan_id IN NUMBER,
    p_txn_number IN NUMBER default null)
    RETURN BOOLEAN IS

    CURSOR txn_plans IS
	SELECT qpt.plan_id
	FROM qa_plan_transactions qpt
	WHERE qpt.plan_id = p_plan_id
	AND qpt.transaction_number = p_txn_number;

    CURSOR txn_plans_for_asset IS
	SELECT qpt.plan_id
	FROM qa_plan_transactions qpt
	WHERE qpt.plan_id = p_plan_id
	AND qpt.transaction_number in (31, 32, 33);

    result BOOLEAN;
    dummy  NUMBER;

BEGIN

    -- This procedure quickly determines if a colleciton plan
    -- applies at all to a transaction wihtout taking into
    -- complexity of collection triggers.

    if (p_txn_number = 32) then

        OPEN txn_plans_for_asset;
    	FETCH txn_plans_for_asset INTO dummy;
    	result := txn_plans_for_asset%FOUND;
    	CLOSE txn_plans_for_asset;

    else

        OPEN txn_plans;
    	FETCH txn_plans INTO dummy;
    	result := txn_plans%FOUND;
    	CLOSE txn_plans;

    end if;

    RETURN result;

END plan_applicable_for_txn;


FUNCTION plan_applies ( p_plan_id 	IN NUMBER,
			p_txn_number    IN NUMBER, --   DEFAULT NULL
                        p_org_id        IN NUMBER, --   DEFAULT NULL
			pk1 		IN VARCHAR2, -- DEFAULT NULL
			pk2 		IN VARCHAR2, -- DEFAULT NULL
			pk3 		IN VARCHAR2, -- DEFAULT NULL
			pk4	 	IN VARCHAR2, -- DEFAULT NULL
			pk5 		IN VARCHAR2, -- DEFAULT NULL
			pk6 		IN VARCHAR2, -- DEFAULT NULL
			pk7 		IN VARCHAR2, -- DEFAULT NULL
			pk8 		IN VARCHAR2, -- DEFAULT NULL
			pk9 		IN VARCHAR2, -- DEFAULT NULL
			pk10 		IN VARCHAR2, -- DEFAULT NULL
			p_txn_name   	IN VARCHAR2) -- DEFAULT NULL)
    RETURN VARCHAR2 IS

    l_context_table 	qa_ss_const.ctx_table;

BEGIN
    -- This function is called to figure out if a particular plan applies
    -- to the transaction and the associated context.  For EAM this is
    -- called before rendering the lsit of plans page.

    -- bug 3189850. rkaza. 01/30/2003.
    -- This check is not needed when coming from asset txn because
    -- now only plans that are associated with the transaction come here
    -- for context check. Modified the VO to have this check in the VO
    -- itself, for perf reasons.
    -- Also please note that the same change need to be made for other
    -- EAM txns too. But list of plans VO for other EAM txns now belongs
    -- to EAM code (they have duplicated it in 11i10). So needs a fix from
    -- their side. Temporarily leaving it as it is.
    if p_txn_number <> 32 then
       IF NOT plan_applicable_for_txn(p_plan_id, p_txn_number) THEN
 	   RETURN 'N';
       END IF;
    end if;

    -- IF (p_txn_number = 31) THEN

    l_context_table(qa_ss_const.asset_group)        := pk1;
    l_context_table(qa_ss_const.asset_number)       := pk2;
    l_context_table(qa_ss_const.asset_activity)     := pk3;
    l_context_table(qa_ss_const.work_order)         := pk4;
    l_context_table(qa_ss_const.maintenance_op_seq) := pk5;
    l_context_table(qa_ss_const.asset_instance_number) := pk6; --dgupta: R12 EAM Integration. Bug 4345492

    -- END IF;

    RETURN check_plan_for_applicability(l_context_table, p_txn_number,
        p_org_id, p_plan_id);

END plan_applies;


FUNCTION get_mandatory_optional_info (p_plan_id NUMBER, p_txn_number IN NUMBER)
    RETURN VARCHAR2 IS

    l_plan_type VARCHAR2(240) DEFAULT 'N/A';

    CURSOR c IS
        SELECT decode(mandatory_collection_flag, 1, 'Mandatory', 2, 'Optional')
        FROM qa_plan_transactions
        WHERE plan_id = p_plan_id
        AND transaction_number = p_txn_number
        AND enabled_flag = 1;

BEGIN

    -- This function determines given a plan and transactions number
    -- whether this plan is mandatory or optional.

    IF  background_plan(p_plan_id, p_txn_number) = 'Y' THEN
        l_plan_type := 'Background';
    ELSE
        OPEN c;
        FETCH c INTO l_plan_type;
        CLOSE c;
    END IF;

    RETURN l_plan_type;

END get_mandatory_optional_info;


FUNCTION background_plan ( p_plan_id IN NUMBER, p_txn_number IN NUMBER)
    RETURN VARCHAR2 IS

    l_result VARCHAR2(1) DEFAULT 'N';

    CURSOR c IS
	SELECT 'Y'
	FROM qa_plan_transactions
	WHERE plan_id = p_plan_id
        AND transaction_number = p_txn_number
        AND background_collection_flag = 1;

BEGIN

    -- This function is called to figure out if a particular plan is
    -- background plan or not

    OPEN c;
    FETCH c INTO l_result;
    CLOSE c;

    RETURN l_result;

END background_plan;


FUNCTION get_user_name
    RETURN VARCHAR2 IS

    l_user_id NUMBER;
    l_user_name VARCHAR2(30);
    l_customer_id NUMBER;

    CURSOR c (p_user_id NUMBER) IS
        SELECT NVL(customer_id, -1)
	FROM fnd_user
	WHERE user_id = p_user_id;

BEGIN

   l_user_id := fnd_global.user_id;

   OPEN c(l_user_id);
   FETCH c INTO l_customer_id;
   CLOSE c;

   l_user_name := 'HZ_PARTY:'||to_char(l_customer_id);

   RETURN l_user_name;

END get_user_name;


FUNCTION allowed_for_plan ( p_function_name IN VARCHAR2, p_plan_id IN NUMBER)
    RETURN VARCHAR2 IS

    l_result VARCHAR2(1) DEFAULT 'F';
    l_profile_value NUMBER DEFAULT NULL;
    l_user_name VARCHAR2(30);
    dummy NUMBER;

    CURSOR c IS
        SELECT PLAN_RELATIONSHIP_ID
        FROM QA_PC_PLAN_RELATIONSHIP
        WHERE CHILD_PLAN_ID = p_plan_id
        AND DATA_ENTRY_MODE = 4;

BEGIN

    -- Bug 3412523 ksoh Fri Jan 30 11:38:19 PST 2004
    -- should return false for Update/Entry/Delete of a
    -- plan that has history relationship with another parent plan(s)
    -- regardless of the security profile.
    IF (p_function_name = 'QA_RESULTS_ENTER' OR
        p_function_name = 'QA_RESULTS_UPDATE' OR
        p_function_name = 'QA_RESULTS_DELETE') THEN
        OPEN c;
        FETCH c INTO dummy;
        IF c%FOUND THEN
            CLOSE c;
            RETURN 'F';
        END IF;
        CLOSE c;
    END IF;

    l_profile_value := fnd_profile.value('QA_SECURITY_USED');

    -- 2 is no, 1 is yes
    IF (l_profile_value = 2) OR (l_profile_value IS NULL) THEN
        l_result := 'T';
    ELSE

        l_user_name := get_user_name;

        -- Bug 4465241
        -- ATG Mandatory Fix: Deprecated API
        -- removing p_user_name
        -- saugupta Mon, 27 Jun 2005 06:21:00 -0700 PDT
        l_result := fnd_data_security.check_function
            (p_api_version => 1.0,
             p_function    => p_function_name,
             p_object_name => 'QA_PLANS',
             p_instance_pk1_value => p_plan_id,
             p_instance_pk2_value => NULL,
             p_instance_pk3_value => NULL,
             p_instance_pk4_value => NULL,
             p_instance_pk5_value => NULL);
             -- p_user_name          => l_user_name);
    END IF;

    RETURN l_result;

END allowed_for_plan;


FUNCTION quality_plans_applicable (p_txn_number IN NUMBER,
    p_organization_id IN NUMBER, -- DEFAULT NULL
    pk1 IN VARCHAR2, -- DEFAULT NULL
    pk2 IN VARCHAR2, -- DEFAULT NULL
    pk3 IN VARCHAR2, -- DEFAULT NULL
    pk4 IN VARCHAR2, -- DEFAULT NULL
    pk5 IN VARCHAR2, -- DEFAULT NULL
    pk6 IN VARCHAR2, -- DEFAULT NULL
    pk7 IN VARCHAR2, -- DEFAULT NULL
    pk8 IN VARCHAR2, -- DEFAULT NULL
    pk9 IN VARCHAR2, -- DEFAULT NULL
    pk10 IN VARCHAR2, -- DEFAULT NULL
    p_txn_name IN VARCHAR2) -- DEFAULT NULL)
    RETURN VARCHAR2 IS

    l_context_table qa_ss_const.ctx_table;
    l_plans_table   qa_ss_const.num_table;
    result BOOLEAN;
    return_value VARCHAR2(1) DEFAULT 'N';

BEGIN

    -- This function will be called from parent page to determine
    -- if they will show Quality Button on their page or not.
    -- They will pass the context information through pk variables.
    -- Note that these will contain different values for different
    -- transactions.


--    IF (p_txn_number = qa_ss_const.eam_work_order_completion_txn) THEN

        -- The following are the context elements for work order completions.
        -- Ordered By char id
        --
        -- pk1 -> asset group
        -- pk2 -> asset number
        -- pk3 -> asset activity
        -- pk4 -> work order number
        -- pk5 -> step

        l_context_table(qa_ss_const.asset_group)        := pk1;
        l_context_table(qa_ss_const.asset_number)       := pk2;
        l_context_table(qa_ss_const.asset_activity)     := pk3;
        l_context_table(qa_ss_const.work_order)         := pk4;
        l_context_table(qa_ss_const.maintenance_op_seq) := pk5;
        l_context_table(qa_ss_const.asset_instance_number) := pk6; --dgupta: R12 EAM Integration. Bug 4345492



        --dbms_output.put_line(p_txn_number || ' ' || p_organization_id);
        --dbms_output.put_line(l_context_table(qa_ss_const.asset_group));
        --dbms_output.put_line(l_context_table(qa_ss_const.asset_number));
        --dbms_output.put_line(l_context_table(qa_ss_const.asset_activity));
        --dbms_output.put_line(l_context_table(qa_ss_const.work_order));
        --dbms_output.put_line(l_context_table(qa_ss_const.step));

        result := evaluate_triggers (
            p_context_table 	=> l_context_table,
            p_txn_number  	=> p_txn_number,
            p_org_id      	=> p_organization_id,
            p_optimize_flag     => 2,
            p_plans_table   	=> l_plans_table);


        IF result = TRUE  THEN
           return_value := 'Y';
        END IF;

--    END IF;

    RETURN return_value;

END quality_plans_applicable;


FUNCTION quality_mandatory_plans_remain (p_txn_number IN NUMBER,
    p_organization_id IN NUMBER, -- DEFAULT NULL
    pk1 IN VARCHAR2, -- DEFAULT NULL
    pk2 IN VARCHAR2, -- DEFAULT NULL
    pk3 IN VARCHAR2, -- DEFAULT NULL
    pk4 IN VARCHAR2, -- DEFAULT NULL
    pk5 IN VARCHAR2, -- DEFAULT NULL
    pk6 IN VARCHAR2, -- DEFAULT NULL
    pk7 IN VARCHAR2, -- DEFAULT NULL
    pk8 IN VARCHAR2, -- DEFAULT NULL
    pk9 IN VARCHAR2, -- DEFAULT NULL
    pk10 IN VARCHAR2, -- DEFAULT NULL
    p_txn_name IN VARCHAR2, -- DEFAULT NULL
    p_list_of_plans IN VARCHAR2,-- DEFAULT NULL
    p_collection_id IN NUMBER, -- DEFAULT NULL,
    p_wip_entity_id IN NUMBER) -- DEFAULT NULL
    RETURN VARCHAR2 IS

    l_module constant varchar2(200) := g_module_name||'.quality_mandatory_plans_remain';
    l_log  boolean := ((FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) and
  	  FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module));
    l_plog  boolean := l_log and (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL);
    l_slog  boolean := l_plog and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL);
    l_context_table qa_ss_const.ctx_table;
    l_plans_table   qa_ss_const.num_table;
    result BOOLEAN;
    return_value VARCHAR2(1) DEFAULT 'N';
    i NUMBER;
    l_plan_token VARCHAR2(30);
    l_results_entered VARCHAR2(1);
    l_wip_entity_id NUMBER := p_wip_entity_id;
BEGIN
--dgupta: Start R12 EAM Integration. Bug 4345492
  if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
    'Start of ' || l_module || '(' || 'p_txn_number=' || p_txn_number
    || ',p_organization_id='|| p_organization_id|| ',pk1='|| pk1|| ',pk2='|| pk2
    || ',pk3='|| pk3|| ', pk4='|| pk4|| ', pk5='|| pk5 || ', pk6='|| pk6|| ',p_txn_name='|| p_txn_name
    || ',p_list_of_plans='|| p_list_of_plans || ',p_collection_id='|| p_collection_id
    || ',p_wip_entity_id='|| p_wip_entity_id|| ')');
  end if;
  l_context_table(qa_ss_const.asset_group)        := pk1;
  l_context_table(qa_ss_const.asset_number)       := pk2;
  l_context_table(qa_ss_const.asset_activity)     := pk3;
  l_context_table(qa_ss_const.work_order)         := pk4;
  l_context_table(qa_ss_const.maintenance_op_seq) := pk5;
  l_context_table(qa_ss_const.asset_instance_number) := pk6;
--dgupta: End R12 EAM Integration. Bug 4345492

  if (l_slog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
    'Calling evaluate_triggers');
  end if;
  result := evaluate_triggers (
    p_context_table 	=> l_context_table,
    p_txn_number  	=> p_txn_number,
    p_org_id      	=> p_organization_id,
    p_optimize_flag    	=> 1,
    p_mandatory_flag 	=> 1,
    p_background_flag 	=> 2,
    p_plans_table   	=> l_plans_table);
  if (l_slog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
    'evaluate_triggers returned. No. of mandatory plans: '|| l_plans_table.count);
  end if;

  i := l_plans_table.FIRST;
  if (p_txn_number = 31 or p_txn_number = 33) then
    if (l_wip_entity_id is null and l_plans_table.count > 0) then
      select wip_entity_id into l_wip_entity_id
      from wip_entities where wip_entity_name = pk4
      and organization_id = p_organization_id;
      if (l_slog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
        'l_wip_entity_id: '|| l_wip_entity_id);
      end if;
    end if;
  elsif (i > 0) AND ( length(p_list_of_plans) = 2) THEN
    RETURN 'Y';
  end if;
  WHILE (i <> l_plans_table.LAST +1) LOOP
    l_results_entered := 'N';
    begin
      if (l_slog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
        'l_plans_table('||i||'): ' || l_plans_table(i));
      end if;
      --
      -- Bug 7685429
      -- Added condition to check for transaction_number in case of
      -- operation/work order completion.
      -- skolluku
      --
      if (p_txn_number = 31) then --maintenance work order completion
        select 'Y' into l_results_entered
        from dual where exists (
        select collection_id from QA_RESULTS
        where organization_id = p_organization_id
        and work_order_id =l_wip_entity_id
        and (maintenance_op_seq is null or transaction_number = 31)
        and plan_id = l_plans_table(i)
        and (status is null or status=2 or --results be either enabled or belong to p_collection_id
        (p_collection_id is not null and collection_id = p_collection_id))
        );
      elsif (p_txn_number = 33) then  --maintenance op completion
        select 'Y' into l_results_entered from dual
        where exists (
        select collection_id from QA_RESULTS
        where organization_id = p_organization_id
        and work_order_id =l_wip_entity_id
        and maintenance_op_seq = pk5
        and transaction_number = 33
        and plan_id = l_plans_table(i)
        and (status is null or status=2 or --results be either enabled or belong to p_collection_id
        (p_collection_id is not null and collection_id = p_collection_id))
        );
      else --all other txns
        l_plan_token := '@' || l_plans_table(i) || '@';
        if (instr(p_list_of_plans, l_plan_token) <> 0) then
          l_results_entered := 'Y';
        end if;
      end if;
      if (l_results_entered is null) then
        l_results_entered := 'N';
      end if;
      if (l_slog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
        'l_results_entered('||i||'): ' || l_results_entered);
      end if;
    exception
  	when no_data_found then
        RETURN 'Y';
    end;
    IF (l_results_entered = 'N') THEN
      RETURN 'Y';
    END IF;
    i := l_plans_table.NEXT(i);
  END LOOP;
  if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
    'Exiting ' || l_module
    || '. No mandatory qa plans remain. Return value: '|| return_value );
  end if;
  RETURN return_value;
END quality_mandatory_plans_remain;


PROCEDURE quality_post_commit_processing (p_collection_id IN NUMBER,
    p_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2) IS
BEGIN
    -- This procedure shoots off the background actions after
    -- parent transactions have committed.

    qa_results_pub.enable_and_fire_action (
	p_api_version 	=> 1.0,
	p_commit 	=> FND_API.G_TRUE,
	p_collection_id => p_collection_id,
        x_return_status => p_return_status,
	x_msg_count	=> x_msg_count,
	x_msg_data	=> x_msg_data);

END quality_post_commit_processing;



PROCEDURE post_background_results(
    p_txn_number IN NUMBER,
    p_org_id IN NUMBER,
    p_context_values IN VARCHAR2,
    p_collection_id IN NUMBER) IS

    l_plan_id NUMBER;
    elements qa_txn_grp.ElementsArray;

    Cursor c1(txn_no number, org_id number, col_id number) is
        SELECT DISTINCT qpt.plan_id
        FROM  qa_plan_transactions qpt, qa_plans qp
        WHERE  qpt.transaction_number = txn_no
         AND    qpt.plan_id = qp.plan_id
         AND    qp.organization_id = org_id
         AND    trunc(sysdate) between
		nvl(trunc(qp.effective_from), trunc(sysdate)) and
		nvl(trunc(qp.effective_to), trunc(sysdate))
         AND    qpt.enabled_flag = 1
         AND qpt.background_collection_flag = 1
         AND NOT EXISTS
         (SELECT 1
          FROM   qa_results qr
          WHERE  qr.plan_id = qpt.plan_id
          AND qr.collection_id = col_id);

BEGIN
    --bug 4995406
    --Checking if the Txn is an EAM transaction
    --ntungare Wed Feb 22 06:57:05 PST 2006
    If p_txn_number in (qa_ss_const.eam_checkin_txn,
                        qa_ss_const.eam_checkout_txn,
                        qa_ss_const.eam_operation_txn,
                        qa_ss_const.eam_work_order_txn) THEN
       -- CAll the procedure to process the result
       -- Collection for Background Plans for EAM Txn
       -- ntungare Wed Feb 22 07:48:02 PST 2006
       qa_txn_grp.eam_post_background_results(p_txn_number     => p_txn_number,
                                              p_org_id         => p_org_id,
                                              p_context_values => p_context_values,
                                              p_collection_id  => p_collection_id);
    ELSE
       elements := qa_txn_grp.result_to_array(p_context_values);
       OPEN c1(p_txn_number, p_org_id, p_collection_id);
       LOOP
           FETCH c1 INTO l_plan_id;
           EXIT WHEN c1%NOTFOUND;
           qa_txn_grp.insert_results(l_plan_id, p_org_id, p_collection_id, elements);
       END LOOP;
       CLOSE c1;
    END IF;
END post_background_results;


--
-- Tracking Bug 4343758.  Fwk Integration.
-- Currently there is no simple metamodel to look up
-- which transactions are enabled for Workbench.
-- So, we do a hard check here.  When there is
-- datamodel available, this can be changed to
-- select from the db.
--
-- Return fnd_api.g_true if p_txn is enabled for OAF
-- transaction integration; else fnd_api.g_false.
-- bso Fri May 20 14:01:25 PDT 2005
--
--
FUNCTION is_workbench_txn(p_txn IN NUMBER)
    RETURN VARCHAR2 IS

BEGIN

    IF p_txn IN (
        qa_ss_const.wip_move_txn,
        qa_ss_const.wip_completion_txn,
        qa_ss_const.flow_work_order_less_txn,
        qa_ss_const.flow_line_op_txn,
        qa_ss_const.osfm_move_txn) THEN
        RETURN fnd_api.g_true;
    END IF;

    RETURN fnd_api.g_false;
END is_workbench_txn;

-- Bug 4343758. Oa Fwk Integration Project.
-- New API used to get information on mandatory
-- result entry.
-- srhariha. Mon May  2 00:33:26 PDT 2005.

FUNCTION get_result_entered(p_plan_id IN NUMBER,
                            p_collection_id IN NUMBER)
      RETURN VARCHAR2 IS

CURSOR c1(x_plan_id NUMBER, x_collection_id NUMBER, x_status NUMBER) IS
           SELECT occurrence
           FROM QA_RESULTS
           WHERE plan_id = x_plan_id
           AND collection_id = x_collection_id
           AND status = x_status;

l_occurrence NUMBER;

BEGIN


  OPEN C1(p_plan_id,p_collection_id,1);
  FETCH C1 INTO l_occurrence;
  CLOSE C1;

  IF (l_occurrence IS NULL) THEN
     RETURN 'N';
  END IF;

  RETURN 'Y';

END get_result_entered;

-- Bug 4519559. Oa Fwk Integration Project. UT bug fix.
-- Return fnd_api.g_true if p_txn is a mobile txn
-- else return fnd_api.g_false
-- srhariha. Tue Aug  2 01:37:53 PDT 2005

-- Bug 4519558.OA Framework Integration project. UT bug fix.
-- Incorporating Bryan's code review comments. Moved the
-- method to qa_mqa_mwa_api package.
-- srhariha. Mon Aug 22 02:50:35 PDT 2005.

/*
FUNCTION is_mobile_txn(p_txn IN NUMBER)
                               RETURN VARCHAR2 IS

BEGIN

  IF p_txn IN (qa_ss_const.mob_move_txn,
               qa_ss_const.mob_scrap_reject_txn,
               qa_ss_const.mob_return_txn,
               qa_ss_const.mob_completion_txn,
               qa_ss_const.mob_wo_less_txn,
               qa_ss_const.mob_flow_txn,
               qa_ss_const.mob_material_txn,
               qa_ss_const.mob_move_and_complete_txn,
               qa_ss_const.mob_return_and_move_txn,
               qa_ss_const.mob_ser_move_txn,
               qa_ss_const.mob_ser_scrap_rej_txn,
               qa_ss_const.mob_ser_return_txn,
               qa_ss_const.mob_ser_completion_txn,
               qa_ss_const.mob_ser_material_txn,
               qa_ss_const.mob_ser_move_and_comp_txn,
               qa_ss_const.mob_ser_return_and_move_txn,
               qa_ss_const.mob_lpn_inspection_txn,
               qa_ss_const.mob_recv_inspection_txn,
               qa_ss_const.wms_lpn_based_txn) THEN
      RETURN fnd_api.g_true;
   END IF;

   RETURN fnd_api.g_false;

END is_mobile_txn;
*/

END qa_web_txn_api;

/
