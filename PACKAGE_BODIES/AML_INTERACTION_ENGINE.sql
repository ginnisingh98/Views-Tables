--------------------------------------------------------
--  DDL for Package Body AML_INTERACTION_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AML_INTERACTION_ENGINE" as
/* $Header: amlitenb.pls 115.13 2004/05/07 23:37:12 solin ship $ */

--
-- HISTORY
--   06/17/2003  SOLIN    Created.
--   11/05/2003  SOLIN    Bug 3240753
--                        Pass party_id, party_site_id to as_import_interface
--   02/23/2004  SOLIN    Bug 3454115
--                        Add "AND aap.level_type_code = 'FAMILY'" in cursor
--                        C_Get_Category
--   04/27/2004  SOLIN    Bug 3584079, 3583298
--                        Join mtl_system_items_b to get uom_code.
--                        Change rule exit condition.
--
-- FLOW
--
-- NOTES
--   The main package for the concurrent program "Run Interaction Engine to
--   Match or Create Leads"
--
/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE CONSTANTS
 |
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE DATATYPES
 |
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE VARIABLES
 |
 *-------------------------------------------------------------------------*/
g_debug_flag       VARCHAR2(1);


/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE ROUTINES SPECIFICATION
 |
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC ROUTINES
 |
 *-------------------------------------------------------------------------*/
PROCEDURE AML_DEBUG(msg IN VARCHAR2);


/*-------------------------------------------------------------------------*
 | PUBLIC ROUTINE
 |  Run_Interaction_Engine
 |
 | PURPOSE
 |  The main program to run interaction engine.
 |  Concurrent program finds interesting interactions and match them with
 |  leads. If there's any lead matched, bump up score and rerun rating engine.
 |  Otherwise, create a new lead.
 |
 | NOTES
 |
 | HISTORY
 |   06/17/2003  SOLIN    Created
 *-------------------------------------------------------------------------*/

PROCEDURE Run_Interaction_Engine(
    ERRBUF                OUT NOCOPY VARCHAR2,
    RETCODE               OUT NOCOPY VARCHAR2,
    p_debug_mode          IN  VARCHAR2,
    p_trace_mode          IN  VARCHAR2)
IS
l_status                      BOOLEAN;
l_batch_id                    NUMBER;
l_last_interaction_id         NUMBER;
l_lead_interaction_lookback   NUMBER;
l_default_source_code         VARCHAR2(30);
l_interaction_lookback        NUMBER;
l_interaction_id_tbl          JTF_NUMBER_TABLE;
l_source_code_tbl             JTF_VARCHAR2_TABLE_100;
l_source_code_id_tbl          JTF_NUMBER_TABLE;
l_source_code_for_id_tbl      JTF_NUMBER_TABLE;
l_arc_source_code_for_tbl     JTF_VARCHAR2_TABLE_100;
l_description_tbl             JTF_VARCHAR2_TABLE_400;
l_party_id_tbl                JTF_NUMBER_TABLE;
l_customer_id_tbl             JTF_NUMBER_TABLE;
l_address_id_tbl              JTF_NUMBER_TABLE;
l_contact_party_id_tbl        JTF_NUMBER_TABLE;
l_process_rule_id_tbl         JTF_NUMBER_TABLE;
l_rank_tbl                    JTF_NUMBER_TABLE;
l_save_profile                BOOLEAN;
l_default_interaction_score   NUMBER;
l_temp_interaction_score      NUMBER;
l_get_score_flag              VARCHAR2(1);
l_interaction_score           NUMBER;
l_prev_rank                   NUMBER;
l_sales_lead_id               NUMBER;
l_status_code                 VARCHAR2(30);
l_category_id                 NUMBER;
l_category_set_id             NUMBER;
l_inventory_item_id           NUMBER;
l_organization_id             NUMBER;
l_uom_code                    VARCHAR2(3);
l_quantity                    NUMBER;
l_offer_id                    NUMBER;
l_sales_lead_line_id          NUMBER;
l_lead_interaction_score      NUMBER;
l_highest_score               NUMBER;
l_check_rerun                 NUMBER;
l_identity_salesforce_id      NUMBER;
l_salesgroup_id               NUMBER;
l_interaction_lead_id         NUMBER;
l_return_status               VARCHAR2(1);
l_msg_count                   NUMBER;
l_msg_data                    VARCHAR2(4000);
l_import_interface_id         NUMBER;
l_imp_lines_interface_id      NUMBER;
l_response_interaction_score  NUMBER;
l_interaction_score_threshold NUMBER;
l_run_import_flag             VARCHAR2(1);
l_request_id                  NUMBER;
l_count                       NUMBER;
l_message                     VARCHAR2(2000);


CURSOR c_get_last_interaction_id(c_interaction_lookback NUMBER) IS
    SELECT interaction_id
    FROM jtf_ih_interactions
    WHERE creation_date > (SYSDATE - c_interaction_lookback)
    ORDER BY interaction_id;

CURSOR c_get_interactions(c_last_interaction_id NUMBER,
           c_default_source_code VARCHAR2) IS
    SELECT DISTINCT v.interaction_id, NVL(v.source_code, c_default_source_code),
           amsc.source_code_id,
           amsc.source_code_for_id, amsc.arc_source_code_for,
           v.party_name, v.party_id, v.customer_id, v.address_id,
           v.contact_party_id
    FROM ams_source_codes amsc,
        (
        -- Interactions from OMO and customer is person or organization without
        -- contact
        SELECT interact.interaction_id, interact.source_code,
               interact.source_code_id, party.party_name, party.party_type,
               TO_NUMBER(NULL) party_id, interact.resource_id,
               party.party_id customer_id, site.party_site_id address_id,
               TO_NUMBER(NULL) contact_party_id
        FROM jtf_ih_interactions interact, hz_parties party, hz_party_sites site
       	WHERE interact.party_id = party.party_id
        AND interact.handler_id = 530 -- for Oracle Marketing
       	AND party.party_type IN ('PERSON', 'ORGANIZATION')
       	AND party.party_id = site.party_id(+)
       	AND site.identifying_address_flag(+) = 'Y'
       	UNION ALL
       	-- Interactions from OMO and customer is organization with contact
       	SELECT interact.interaction_id, interact.source_code,
               interact.source_code_id, party.party_name, party.party_type,
               interact.party_id, interact.resource_id,
               rel.object_id customer_id, site.party_site_id address_id,
               rel.subject_id contact_party_id
        FROM jtf_ih_interactions interact, hz_parties party,
             hz_relationships rel, hz_party_sites site
       	WHERE interact.party_id = party.party_id
        AND interact.handler_id = 530 -- for Oracle Marketing
       	AND party.party_type = 'PARTY_RELATIONSHIP'
       	AND party.party_id = rel.party_id
       	AND rel.object_type = 'ORGANIZATION'
        AND rel.status = 'A'
       	AND rel.object_id = site.party_id(+)
       	AND site.identifying_address_flag(+) = 'Y'
       	UNION ALL
       	-- Interactions not from OMO and customer is person or organization
        -- without contact
       	SELECT interact.interaction_id, interact.source_code,
               interact.source_code_id, party.party_name, party.party_type,
               TO_NUMBER(NULL) party_id, interact.resource_id,
               party.party_id customer_id, site.party_site_id address_id,
               TO_NUMBER(NULL) contact_party_id
          FROM jtf_ih_interactions interact, hz_parties party,
             jtf_ih_activities acv, pv_process_rules_b rule,
             pv_enty_select_criteria cra, pv_selected_attr_values val,
             aml_business_event_types_b bet, hz_party_sites site
       	WHERE interact.party_id = party.party_id
       	AND interact.handler_id <> 530 -- for Oracle Marketing
       	AND party.party_type IN ('PERSON', 'ORGANIZATION')
       	AND party.party_id = site.party_id(+)
       	AND site.identifying_address_flag(+) = 'Y'
       	AND interact.interaction_id = acv.interaction_id
       	AND TO_CHAR(bet.business_event_type_id) = val.attribute_value
       	AND bet.action_id = acv.action_id
       	AND bet.action_item_id = acv.action_item_id
       	AND val.selection_criteria_id = cra.selection_criteria_id
       	AND cra.selection_type_code = 'CRITERION'
       	AND cra.process_rule_id = rule.process_rule_id
       	AND rule.process_type = 'LEAD_INTERACTION'
       	AND rule.status_code = 'ACTIVE'
       	AND SYSDATE BETWEEN rule.start_date AND rule.end_date
       	UNION ALL
       	-- Interactions not from OMO and customer is organization with contact
       	SELECT interact.interaction_id, interact.source_code,
               interact.source_code_id, party.party_name, party.party_type,
               interact.party_id, interact.resource_id,
               rel.object_id customer_id, site.party_site_id address_id,
               rel.subject_id contact_party_id
        FROM jtf_ih_interactions interact, hz_parties party,
             hz_relationships rel, hz_party_sites site, jtf_ih_activities acv,
             pv_process_rules_b rule, pv_enty_select_criteria cra,
             pv_selected_attr_values val, aml_business_event_types_b bet
        WHERE interact.party_id = party.party_id
       	AND interact.handler_id <> 530 -- for Oracle Marketing
       	AND party.party_type = 'PARTY_RELATIONSHIP'
       	AND rel.object_id = site.party_id(+)
       	AND site.identifying_address_flag(+) = 'Y'
       	AND party.party_id = rel.party_id
       	AND rel.object_type = 'ORGANIZATION'
        AND rel.status = 'A'
       	AND interact.interaction_id = acv.interaction_id
       	AND TO_CHAR(bet.business_event_type_id) = val.attribute_value
       	AND bet.action_id = acv.action_id
       	AND bet.action_item_id = acv.action_item_id
       	AND val.selection_criteria_id = cra.selection_criteria_id
       	AND cra.selection_type_code = 'CRITERION'
       	AND cra.process_rule_id = rule.process_rule_id
       	AND rule.process_type = 'LEAD_INTERACTION'
       	AND rule.status_code = 'ACTIVE'
       	AND SYSDATE BETWEEN rule.start_date AND rule.end_date) v
    WHERE v.interaction_id > c_last_interaction_id
    AND   NVL(v.source_code, c_default_source_code) = amsc.source_code(+)
    ORDER BY v.interaction_id;

CURSOR C_Get_Batch_ID IS
    SELECT as_sl_imp_batch_s.nextval
    FROM dual;

CURSOR C_Get_Matching_Rules(c_interaction_id NUMBER, c_source_code_id NUMBER,
        c_address_id NUMBER) IS
    SELECT rule.process_rule_id, rule.rank
    FROM  (
          -- ----------------------------------------------------------------
          -- Campaign
          -------------------------------------------------------------------
          SELECT DISTINCT a.process_rule_id, a.rank
          FROM   pv_process_rules_b a,
                 pv_enty_select_criteria b,
                 pv_selected_attr_values c
          WHERE  b.selection_type_code = 'INPUT_FILTER' AND
                 b.attribute_id        = pv_check_match_pub.g_a_Campaign_ AND
                 a.process_type        = 'LEAD_INTERACTION' AND
                 a.process_rule_id     = b.process_rule_id AND
                 c_source_code_id IS NOT NULL AND
                 b.selection_criteria_id = c.selection_criteria_id(+) AND
               ((b.operator = 'EQUALS' AND c.attribute_value = c_source_code_id) OR
                (b.operator = 'NOT_EQUALS' AND c.attribute_value <> c_source_code_id) OR
                (b.operator = 'IS_NOT_NULL' AND c_source_code_id IS NOT NULL) OR
                (b.operator = 'IS_NULL' AND c_source_code_id IS NULL))
          UNION ALL
          SELECT DISTINCT a.process_rule_id, a.rank
          FROM   pv_process_rules_b a,
                 pv_enty_select_criteria b,
                 pv_selected_attr_values c,
                 jtf_ih_activities d
          WHERE  b.selection_type_code = 'INPUT_FILTER' AND
                 b.attribute_id        = pv_check_match_pub.g_a_Campaign_ AND
                 a.process_type        = 'LEAD_INTERACTION' AND
                 a.process_rule_id     = b.process_rule_id AND
                 c_source_code_id IS NULL AND
                 b.selection_criteria_id = c.selection_criteria_id(+) AND
                 d.interaction_id = c_interaction_id AND
               ((b.operator = 'EQUALS' AND c.attribute_value = d.source_code_id) OR
                (b.operator = 'NOT_EQUALS' AND c.attribute_value <> d.source_code_id) OR
                (b.operator = 'IS_NOT_NULL' AND d.source_code_id IS NOT NULL) OR
                (b.operator = 'IS_NULL' AND d.source_code_id IS NULL))

          -- ----------------------------------------------------------------
          -- All
          -------------------------------------------------------------------
          UNION ALL
          SELECT DISTINCT a.process_rule_id, a.rank
          FROM   pv_process_rules_b a,
                 pv_enty_select_criteria b
          WHERE  b.selection_type_code = 'INPUT_FILTER' AND
                 b.attribute_id        = pv_check_match_pub.g_a_all AND
                 a.process_type        = 'LEAD_INTERACTION' AND
                 a.process_rule_id     = b.process_rule_id
          -- -------------------------------------------------------------------
          -- Country
          -- -------------------------------------------------------------------
          UNION ALL
          SELECT DISTINCT a.process_rule_id, a.rank
          FROM   pv_process_rules_b a,
                 pv_enty_select_criteria b,
                 pv_selected_attr_values c,
                 hz_party_sites d,
                 hz_locations e
          WHERE  b.selection_type_code   = 'INPUT_FILTER' AND
                 b.attribute_id          = pv_check_match_pub.g_a_Country_ AND
                 a.process_type          = 'LEAD_INTERACTION' AND
                 a.process_rule_id       = b.process_rule_id AND
                 d.party_site_id         = c_address_id AND
                 e.location_id           = d.location_id AND
                 b.selection_criteria_id = c.selection_criteria_id(+) AND
               ((b.operator = 'EQUALS' AND c.attribute_value = e.country) OR
                (b.operator = 'NOT_EQUALS' AND c.attribute_value <> e.country) OR
                (b.operator = 'IS_NOT_NULL' AND e.country IS NOT NULL) OR
                (b.operator = 'IS_NULL' AND e.country IS NULL))
          ) rule
          GROUP BY rule.process_rule_id, rule.rank
          HAVING (rule.process_rule_id, COUNT(*)) IN (
             SELECT a.process_rule_id, COUNT(*)
             FROM   pv_process_rules_b a,
                    pv_enty_select_criteria b
             WHERE  a.process_rule_id     = b.process_rule_id AND
                    b.selection_type_code = 'INPUT_FILTER' AND
                    a.status_code         = 'ACTIVE' AND
                    a.process_type        = 'LEAD_INTERACTION' AND
                    SYSDATE BETWEEN a.start_date AND a.end_date
             GROUP  BY a.process_rule_id)
          ORDER BY rule.rank DESC;

CURSOR C_Calculate_Score(c_interaction_id NUMBER, c_process_rule_id NUMBER) IS
    SELECT SUM(TO_NUMBER(val.score))
    FROM jtf_ih_activities activity, pv_enty_select_criteria attr,
         pv_selected_attr_values val, aml_business_event_types_b bet
    WHERE activity.interaction_id = c_interaction_id
    AND attr.process_rule_id = c_process_rule_id
    AND attr.attribute_id = pv_check_match_pub.g_a_business_event_type
    AND attr.selection_type_code = 'CRITERION'
    AND attr.selection_criteria_id = val.selection_criteria_id
    AND val.attribute_value = bet.business_event_type_id
    AND bet.action_id = activity.action_id
    AND bet.action_item_id = activity.action_item_id;

CURSOR C_Match_Lead1(c_lead_interaction_lookback NUMBER, c_customer_id NUMBER,
                     c_cnt_person_party_id NUMBER) IS
    SELECT sl.sales_lead_id--, NVL(sl.interaction_score, 0)
    FROM as_sales_leads sl
    WHERE sl.creation_date > (SYSDATE - c_lead_interaction_lookback)
    AND sl.customer_id = c_customer_id
    AND sl.primary_cnt_person_party_id = c_cnt_person_party_id
    AND sl.status_open_flag = 'Y'
    ORDER BY sl.lead_rank_score DESC, sl.creation_date DESC;

CURSOR C_Match_Lead2(c_lead_interaction_lookback NUMBER, c_customer_id NUMBER) IS
    SELECT sl.sales_lead_id--, NVL(sl.interaction_score, 0)
    FROM as_sales_leads sl
    WHERE sl.creation_date > (SYSDATE - c_lead_interaction_lookback)
    AND sl.customer_id = c_customer_id
    AND sl.status_open_flag = 'Y'
    ORDER BY sl.lead_rank_score DESC, sl.creation_date DESC;

-- Bug 3583298, join mtl_system_items_b to get uom_code
-- Bug 3583510, remove AND aap.level_type_code = 'FAMILY' because both 'PRODUCT'
--     and 'FAMILY' should be used.
CURSOR C_Get_Category(c_interaction_id NUMBER, c_default_source_code VARCHAR2) IS
    SELECT distinct aap.category_id, aap.category_set_id, aap.inventory_item_id,
	 aap.organization_id,
	 DECODE(aap.inventory_item_id, NULL, NULL, msi.primary_uom_code),
         aap.quantity
    FROM ams_source_codes amsc,
         ams_act_products aap,
         mtl_system_items_b msi,
      (
        SELECT jii.source_code
        FROM jtf_ih_interactions jii
        WHERE interaction_id = c_interaction_id
        UNION ALL
        SELECT jia.source_code
        FROM jtf_ih_activities jia
        WHERE interaction_id = c_interaction_id
        ) v
    WHERE v.source_code = amsc.source_code
    AND amsc.source_code_for_id = aap.act_product_used_by_id
    AND amsc.arc_source_code_for = aap.arc_act_product_used_by
    AND aap.enabled_flag = 'Y'
    AND aap.category_id IS NOT NULL
    AND aap.inventory_item_id = msi.inventory_item_id(+)
    AND aap.organization_id = msi.organization_id(+);

CURSOR C_Check_Rerun IS
    SELECT rule.process_rule_id
    FROM pv_process_rules_b rule, pv_process_rules_b prule,
        pv_enty_select_criteria ruleattr
    WHERE rule.process_type IN ('LEAD_QUALIFICATION', 'LEAD_RATING',
          'CHANNEL_SELECTION')
    AND rule.process_rule_id = ruleattr.process_rule_id
    AND ruleattr.attribute_id = pv_check_match_pub.g_a_interaction_score
    AND rule.parent_rule_id = prule.process_rule_id
    AND prule.status_code = 'ACTIVE'
    AND prule.start_date <= SYSDATE
    AND prule.end_date >= SYSDATE;

CURSOR C_get_current_resource IS
    SELECT res.resource_id
    FROM jtf_rs_resource_extns res
    WHERE res.category IN ('EMPLOYEE', 'PARTY')
    AND res.user_id = fnd_global.user_id;

CURSOR c_get_group_id (c_resource_id NUMBER, c_rs_group_member VARCHAR2,
                       c_sales VARCHAR2, c_telesales VARCHAR2,
                       c_fieldsales VARCHAR2, c_prm VARCHAR2, c_y VARCHAR2) IS
    SELECT grp.group_id
    FROM JTF_RS_GROUP_MEMBERS mem,
         JTF_RS_ROLE_RELATIONS rrel,
         JTF_RS_ROLES_B role,
         JTF_RS_GROUP_USAGES u,
         JTF_RS_GROUPS_B grp
    WHERE mem.group_member_id = rrel.role_resource_id
    AND rrel.role_resource_type = c_rs_group_member --'RS_GROUP_MEMBER'
    AND rrel.role_id = role.role_id
    AND role.role_type_code in (c_sales, c_telesales, c_fieldsales, c_prm) --'LES','TELESALES','FIELDSALES','PRM')
    AND mem.delete_flag <> c_y --'Y'
    AND rrel.delete_flag <> c_y --'Y'
    AND SYSDATE BETWEEN rrel.start_date_active AND
        NVL(rrel.end_date_active,SYSDATE)
    AND mem.resource_id = c_resource_id
    AND mem.group_id = u.group_id
    AND u.usage = c_sales --'SALES'
    AND mem.group_id = grp.group_id
    AND SYSDATE BETWEEN grp.start_date_active AND
        NVL(grp.end_date_active,SYSDATE)
    AND ROWNUM < 2;

CURSOR C_Match_Reponse1(c_lead_interaction_lookback NUMBER,
                        c_customer_id NUMBER,
                        c_contact_party_id NUMBER) IS
    SELECT imp.import_interface_id--, NVL(imp.interaction_score, 0)
    FROM as_import_interface imp
    WHERE imp.creation_date > (SYSDATE - c_lead_interaction_lookback)
    AND imp.party_id = c_customer_id
    AND imp.contact_party_id = c_contact_party_id
    AND imp.sales_lead_id IS NULL
    AND imp.source_system = 'INTERACTION' -- new in 11.5.10
    AND imp.load_status = 'NEW'
    ORDER BY imp.interaction_score DESC, imp.creation_date DESC;

CURSOR C_Match_Reponse2(c_lead_interaction_lookback NUMBER,
                        c_customer_id NUMBER) IS
    SELECT imp.import_interface_id--, NVL(imp.interaction_score, 0)
    FROM as_import_interface imp
    WHERE imp.creation_date > (SYSDATE - c_lead_interaction_lookback)
    AND imp.party_id = c_customer_id
    AND imp.sales_lead_id IS NULL
    AND imp.source_system = 'INTERACTION' -- new in 11.5.10
    AND imp.load_status = 'NEW'
    ORDER BY imp.interaction_score DESC, imp.creation_date DESC;

CURSOR C_Find_Highest_Score(c_import_interface_id NUMBER) IS
    SELECT il.score
    FROM aml_interaction_leads il
    WHERE il.import_interface_id = c_import_interface_id
    ORDER BY il.score desc;

CURSOR C_Get_Run_Import_Flag(c_batch_id NUMBER) IS
    SELECT 'Y'
    FROM as_import_interface
    WHERE batch_id = c_batch_id
    AND source_system = 'INTERACTION';
BEGIN
    g_debug_flag := p_debug_mode;
    AML_DEBUG('Run_Interaction_Engine starts ***');

    IF p_trace_mode = 'Y' THEN
        dbms_session.set_sql_trace(TRUE);
    ELSE
        dbms_session.set_sql_trace(FALSE);
    END IF;

    -- Find all the interactions after the last interaction engine run.
    l_last_interaction_id :=
        NVL(TO_NUMBER(FND_PROFILE.Value('AS_LAST_INTERACTION_ID')), 0);
    l_lead_interaction_lookback :=
        NVL(TO_NUMBER(FND_PROFILE.Value('AS_LEAD_INTERACTION_LOOKBACK')), 0);
    l_default_source_code :=
        FND_PROFILE.Value('AS_DEFAULT_SOURCE_FOR_INTERENG');
    AML_DEBUG('l_last_interaction_id=' || l_last_interaction_id);
    AML_DEBUG('l_lead_interaction_lookback=' || l_lead_interaction_lookback);
    AML_DEBUG('l_default_source_code=' || l_default_source_code);

    -- If this is the first time for interaction engine, get the first
    -- interaction created in N days.
    IF l_last_interaction_id = 0
    THEN
        l_interaction_lookback :=
            NVL(TO_NUMBER(FND_PROFILE.Value('AS_INTERACTION_LOOKBACK')), 0);
        AML_DEBUG('l_interaction_lookback=' || l_interaction_lookback);
        -- Pick the first interaction created in N days.
        OPEN c_get_last_interaction_id(l_interaction_lookback);
        FETCH c_get_last_interaction_id INTO l_last_interaction_id;
        CLOSE c_get_last_interaction_id;
    END IF;

    AML_DEBUG('l_last_interaction_id=' || l_last_interaction_id);

    -- Find the interactions that should be processed.
    OPEN c_get_interactions(l_last_interaction_id, l_default_source_code);
    FETCH c_get_interactions BULK COLLECT INTO l_interaction_id_tbl,
        l_source_code_tbl, l_source_code_id_tbl, l_source_code_for_id_tbl,
        l_arc_source_code_for_tbl, l_description_tbl,
        l_party_id_tbl, l_customer_id_tbl, l_address_id_tbl,
        l_contact_party_id_tbl;
    CLOSE c_get_interactions;

    AML_DEBUG('l_interaction_id_tbl.count=' || l_interaction_id_tbl.count);
    -- Set profile AS_LAST_INTERACTION_ID to be the maximum id in
    -- l_interaction_id_tbl;
    IF l_interaction_id_tbl.count > 0
    THEN
        OPEN C_Get_Batch_ID;
        FETCH C_Get_Batch_ID INTO l_batch_id;
        CLOSE C_Get_Batch_ID;
        AML_DEBUG('batch_id=' || l_batch_id);

        l_save_profile := fnd_profile.save('AS_LAST_INTERACTION_ID',
            TO_CHAR(l_interaction_id_tbl(l_interaction_id_tbl.count)), 'SITE');

        l_default_interaction_score :=
            NVL(TO_NUMBER(FND_PROFILE.Value('AS_DEFAULT_INTERACTION_SCORE')),0);
        AML_DEBUG('default score=' || l_default_interaction_score);

        -- If the attribute Interaction Score is not used in
        -- qualification, rating, channel selection rules, lead
        -- doesn't need to be reprocessed.
        OPEN C_Check_Rerun;
        FETCH C_Check_Rerun INTO l_check_rerun;
        CLOSE C_Check_Rerun;
        AML_DEBUG('interaction score attr used?' || l_check_rerun);

        -- For each interaction, find the matching interaction rules
        FOR i IN l_interaction_id_tbl.FIRST..l_interaction_id_tbl.LAST
        LOOP
            AML_DEBUG(i || '==========----------==========----------');
            AML_DEBUG('interaction_id=' || l_interaction_id_tbl(i));
            AML_DEBUG('source_code=' || l_source_code_tbl(i));
            AML_DEBUG('source_code_id=' || l_source_code_id_tbl(i));
            AML_DEBUG('source_code_for_id=' || l_source_code_for_id_tbl(i));
            AML_DEBUG('arc_source_code_for=' || l_arc_source_code_for_tbl(i));
            AML_DEBUG('description=' || l_description_tbl(i));
            AML_DEBUG('party_id=' || l_party_id_tbl(i));
            AML_DEBUG('customer_id=' || l_customer_id_tbl(i));
            AML_DEBUG('address_id=' || l_address_id_tbl(i));
            AML_DEBUG('contact_party_id=' || l_contact_party_id_tbl(i));
            OPEN C_Get_Matching_Rules(l_interaction_id_tbl(i),
                l_source_code_id_tbl(i), l_address_id_tbl(i));
            FETCH C_Get_Matching_Rules BULK COLLECT INTO
                l_process_rule_id_tbl, l_rank_tbl;
            CLOSE C_Get_Matching_Rules;

            AML_DEBUG('l_process_rule_id_tbl.count='
                || l_process_rule_id_tbl.count);
            l_interaction_score := l_default_interaction_score;
            -- For each rule, calculate interaction score
            IF l_process_rule_id_tbl.count > 0
            THEN
                -- Get the score of the highest precedence rule. If different
                -- rules have the same precedence, get the highest score
                l_prev_rank := l_rank_tbl(1);
                l_temp_interaction_score := NULL;
                l_get_score_flag := 'N';
                FOR j IN l_process_rule_id_tbl.FIRST..l_process_rule_id_tbl.LAST
                LOOP
                    AML_DEBUG('process_rule_id=' || l_process_rule_id_tbl(j));

                    -- Bug 3584079, add check for l_get_score_flag
                    IF l_prev_rank <> l_rank_tbl(j) AND l_get_score_flag = 'Y'
                    THEN
                        -- different precedence
                        EXIT;
                    END IF;

                    OPEN C_Calculate_Score(l_interaction_id_tbl(i),
                        l_process_rule_id_tbl(j));
                    FETCH C_Calculate_Score INTO l_temp_interaction_score;
                    CLOSE C_Calculate_Score;

                    AML_DEBUG('l_temp_score=' || l_temp_interaction_score);
                    IF l_temp_interaction_score IS NOT NULL
                    THEN
                        l_get_score_flag := 'Y';
                    END IF;
                    IF l_interaction_score < l_temp_interaction_score
                    THEN
                        l_interaction_score := l_temp_interaction_score;
                    END IF;
                    l_prev_rank := l_rank_tbl(j);
                END LOOP;
            END IF;

            AML_DEBUG('l_interaction_score=' || l_interaction_score);
            l_sales_lead_id := NULL;
--            l_lead_interaction_score := NULL;
            IF FND_PROFILE.Value('AS_INTR_MATCH_B2B_LEAD_CONTACT') = 'Y' AND
               l_contact_party_id_tbl(i) IS NOT NULL
            THEN
                -- match organization party_id and contact
                AML_DEBUG('Match lead party and contact');
                OPEN C_Match_Lead1(l_lead_interaction_lookback,
                    l_customer_id_tbl(i), l_contact_party_id_tbl(i));
                FETCH C_Match_Lead1 INTO
                    l_sales_lead_id/*, l_lead_interaction_score*/;
                CLOSE C_Match_Lead1;
	    ELSE
                -- match party_id
                AML_DEBUG('Match lead party only');
                OPEN C_Match_Lead2(l_lead_interaction_lookback,
                    l_customer_id_tbl(i));
                FETCH C_Match_Lead2 INTO
                    l_sales_lead_id/*, l_lead_interaction_score*/;
                CLOSE C_Match_Lead2;
            END IF;
            AML_DEBUG('sales_lead_id=' || l_sales_lead_id);
--            AML_DEBUG('lead_interaction_score=' || l_lead_interaction_score);

            IF l_sales_lead_id IS NOT NULL
            THEN
                -- Create_Sales_Lead_Lines for category_id/category_set_id from
                -- l_source_code_id(both interaction and activities);
                OPEN C_Get_Category(l_interaction_id_tbl(i),
                    l_default_source_code);
                LOOP
                    FETCH C_Get_Category INTO l_category_id, l_category_set_id,
                        l_inventory_item_id, l_organization_id, l_uom_code,
                        l_quantity;
                    EXIT WHEN C_Get_Category%NOTFOUND;
                    AML_DEBUG('found category_id=' || l_category_id);

                    IF l_arc_source_code_for_tbl(i) = 'OFFR'
                    THEN
                        l_offer_id := l_source_code_id_tbl(i);
                    ELSE
                        l_offer_id := NULL;
                    END IF;

                    l_sales_lead_line_id := NULL;
                    AS_SALES_LEAD_LINES_PKG.Sales_Lead_Line_Insert_Row(
                        px_SALES_LEAD_LINE_ID    => l_sales_lead_line_id,
                        p_LAST_UPDATE_DATE       => SYSDATE,
                        p_LAST_UPDATED_BY        => FND_GLOBAL.USER_ID,
                        p_CREATION_DATE          => SYSDATE,
                        p_CREATED_BY             => FND_GLOBAL.USER_ID,
                        p_LAST_UPDATE_LOGIN      => FND_GLOBAL.CONC_LOGIN_ID,
                        p_REQUEST_ID             => FND_GLOBAL.Conc_Request_Id,
                        p_PROGRAM_APPLICATION_ID => FND_GLOBAL.Prog_Appl_Id,
                        p_PROGRAM_ID             => FND_GLOBAL.Conc_Program_Id,
                        p_PROGRAM_UPDATE_DATE    => SYSDATE,
                        p_SALES_LEAD_ID          => l_sales_lead_id,
                        p_STATUS_CODE            => NULL, -- ???
                        p_CATEGORY_ID	         => l_category_id,
                        p_CATEGORY_SET_ID        => l_category_set_id,
                        p_INVENTORY_ITEM_ID      => l_inventory_item_id,
                        p_ORGANIZATION_ID        => l_organization_id,
                        p_UOM_CODE               => l_uom_code,
                        p_QUANTITY               => l_quantity,
                        p_BUDGET_AMOUNT          => NULL,
                        p_SOURCE_PROMOTION_ID    => l_source_code_id_tbl(i),
                        p_ATTRIBUTE_CATEGORY     => FND_API.G_MISS_CHAR,
                        p_ATTRIBUTE1             => FND_API.G_MISS_CHAR,
                        p_ATTRIBUTE2             => FND_API.G_MISS_CHAR,
                        p_ATTRIBUTE3             => FND_API.G_MISS_CHAR,
                        p_ATTRIBUTE4             => FND_API.G_MISS_CHAR,
                        p_ATTRIBUTE5             => FND_API.G_MISS_CHAR,
                        p_ATTRIBUTE6             => FND_API.G_MISS_CHAR,
                        p_ATTRIBUTE7             => FND_API.G_MISS_CHAR,
                        p_ATTRIBUTE8             => FND_API.G_MISS_CHAR,
                        p_ATTRIBUTE9             => FND_API.G_MISS_CHAR,
                        p_ATTRIBUTE10            => FND_API.G_MISS_CHAR,
                        p_ATTRIBUTE11            => FND_API.G_MISS_CHAR,
                        p_ATTRIBUTE12            => FND_API.G_MISS_CHAR,
                        p_ATTRIBUTE13            => FND_API.G_MISS_CHAR,
                        p_ATTRIBUTE14            => FND_API.G_MISS_CHAR,
                        p_ATTRIBUTE15            => FND_API.G_MISS_CHAR,
                        p_OFFER_ID               => l_offer_id);
                    AML_DEBUG('created sales_lead_line_id='
                        || l_sales_lead_line_id);
                END LOOP;
                CLOSE C_Get_Category;

                -- If the attribute Interaction Score is not used in
                -- qualification, rating, channel selection rules, lead
                -- doesn't need to be reprocessed.
                IF l_check_rerun IS NOT NULL
                THEN
                    UPDATE as_sales_leads
                    SET last_update_date = SYSDATE,
                        last_updated_by = fnd_global.user_id,
                        last_update_login = FND_GLOBAL.CONC_LOGIN_ID,
                        qualified_flag = 'N',
                        lead_rank_id = NULL,
                        channel_code = NULL,
                        interaction_score = NVL(interaction_score, 0)
                            + l_interaction_score
                    WHERE sales_lead_id = l_sales_lead_id;

                    OPEN C_get_current_resource;
                    FETCH C_get_current_resource INTO l_identity_salesforce_id;
                    IF (C_get_current_resource%NOTFOUND)
                    THEN
                        AML_DEBUG('No current resource found! Get default');
                        l_identity_salesforce_id :=
                            fnd_profile.value('AS_DEFAULT_RESOURCE_ID');
                    END IF;
                    CLOSE C_get_current_resource;

                    AML_DEBUG('l_i_sf_id=' || l_identity_salesforce_id);
                    OPEN c_get_group_id (l_identity_salesforce_id,
                        'RS_GROUP_MEMBER', 'SALES',
                        'TELESALES', 'FIELDSALES', 'PRM', 'Y');
                    FETCH c_get_group_id INTO l_salesgroup_id;
                    CLOSE c_get_group_id;
                    AML_DEBUG('l_sg_id=' || l_salesgroup_id);

                    -- Initialize message list for each interaction
                    FND_MSG_PUB.initialize;

                    AS_SALES_LEAD_ENGINE_PVT.Lead_Process_After_Update(
                        P_Api_Version_Number      => 2.0,
                        P_Init_Msg_List           => FND_API.G_FALSE,
                        p_Commit                  => FND_API.G_FALSE,
                        p_Validation_Level        => FND_API.G_VALID_LEVEL_NONE,
                        P_Check_Access_Flag       => 'N',
                        p_Admin_Flag              => 'N',
                        P_Admin_Group_Id          => NULL,
                        P_identity_salesforce_id  => l_identity_salesforce_id,
                        P_Salesgroup_id           => l_salesgroup_id,
                        P_Sales_Lead_Id           => l_sales_lead_id,
                        X_Return_Status           => l_return_status,
                        X_Msg_Count               => l_msg_count,
                        X_Msg_Data                => l_msg_data);

                    IF l_return_status = FND_API.G_RET_STS_ERROR OR
                       l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
                    THEN
                        AML_DEBUG('Lead_Process_After_Update has error for '
                            || 'sales_lead_id ' || l_sales_lead_id || '!');
--                        RAISE FND_API.G_EXC_ERROR;
                    END IF;

                    l_count := FND_MSG_PUB.Count_Msg;
                    FOR l_index IN 1..l_count LOOP
                        l_message := FND_MSG_PUB.Get(
                              p_msg_index   =>  l_index,
                              p_encoded     =>  FND_API.G_FALSE);
                        AML_DEBUG(l_message);
                    END LOOP;
                ELSE
                    -- Lead doesn't need to be reprocessed, update
                    -- interaction_score
                    UPDATE as_sales_leads
                    SET last_update_date = SYSDATE,
                        last_updated_by = fnd_global.user_id,
                        last_update_login = FND_GLOBAL.CONC_LOGIN_ID,
                        interaction_score = NVL(interaction_score, 0)
                            + l_interaction_score
                    WHERE sales_lead_id = l_sales_lead_id;

                END IF; -- lead get reprocessed

	        -- Maintain relevance of interaction and lead
                l_INTERACTION_LEAD_ID := NULL;
                AML_INTERACTION_LEADS_PKG.INSERT_ROW(
                    px_INTERACTION_LEAD_ID    => l_INTERACTION_LEAD_ID,
                    p_INTERACTION_ID          => l_interaction_id_tbl(i),
                    p_IMPORT_INTERFACE_ID     => NULL,
                    p_SALES_LEAD_ID           => l_sales_lead_id,
                    p_CREATION_DATE           => SYSDATE,
                    p_CREATED_BY              => fnd_global.user_id,
                    p_LAST_UPDATE_DATE        => SYSDATE,
                    p_LAST_UPDATED_BY         => fnd_global.user_id,
                    p_LAST_UPDATE_LOGIN       => FND_GLOBAL.CONC_LOGIN_ID,
                    p_REQUEST_ID              => FND_GLOBAL.Conc_Request_Id,
                    p_PROGRAM_APPLICATION_ID  => FND_GLOBAL.Prog_Appl_Id,
                    p_PROGRAM_ID              => FND_GLOBAL.Conc_Program_Id,
                    p_PROGRAM_UPDATE_DATE     => SYSDATE,
                    p_OBJECT_VERSION_NUMBER   => 1,
                    p_SCORE                   => l_interaction_score);
            ELSE
                -- This interaction can't match any lead.
                -- Find matched record in as_import_interface, if no open lead
                -- matched
                l_import_interface_id := NULL;

                IF FND_PROFILE.Value('AS_INTR_MATCH_B2B_LEAD_CONTACT') = 'Y' AND
                    l_contact_party_id_tbl(i) IS NOT NULL
                THEN
                    -- match organization party_id and contact
                    AML_DEBUG('Match response party and contact');
                    OPEN C_Match_Reponse1(l_lead_interaction_lookback,
                        l_customer_id_tbl(i), l_contact_party_id_tbl(i));
                    FETCH C_Match_Reponse1 INTO
                        l_import_interface_id/*, l_response_interaction_score*/;
                    CLOSE C_Match_Reponse1;
                ELSE
                    -- match party_id
                    AML_DEBUG('Match response party only');
                    OPEN C_Match_Reponse2(l_lead_interaction_lookback,
                        l_customer_id_tbl(i));
                    FETCH C_Match_Reponse2 INTO
                        l_import_interface_id/*, l_response_interaction_score*/;
                    CLOSE C_Match_Reponse2;
                END IF;
                AML_DEBUG('import_interface_id=' || l_import_interface_id);

                IF l_import_interface_id IS NOT NULL
                THEN
                    OPEN C_Find_Highest_Score(l_import_interface_id);
                    FETCH C_Find_Highest_Score INTO l_highest_score;
                    CLOSE C_Find_Highest_Score;

                    IF l_interaction_score > l_highest_score
                    THEN
                        -- All interactions for this response have score lower
                        -- than that of this interaction.
                        UPDATE as_import_interface
                        SET last_update_date = SYSDATE,
                            last_updated_by = fnd_global.user_id,
                            last_update_login = FND_GLOBAL.CONC_LOGIN_ID,
                            interaction_score = NVL(interaction_score, 0)
                                + l_interaction_score,
                            promotion_id = l_source_code_id_tbl(i),
                            batch_id = l_batch_id
                        WHERE import_interface_id = l_import_interface_id;
                    ELSE
                        UPDATE as_import_interface
                        SET last_update_date = SYSDATE,
                            last_updated_by = fnd_global.user_id,
                            last_update_login = FND_GLOBAL.CONC_LOGIN_ID,
                            interaction_score = NVL(interaction_score, 0)
                                + l_interaction_score,
                            batch_id = l_batch_id
                        WHERE import_interface_id = l_import_interface_id;
                    END IF;
                ELSE
                    INSERT INTO AS_IMPORT_INTERFACE(
                        IMPORT_INTERFACE_ID, LAST_UPDATE_DATE,
                        LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,
                        LAST_UPDATE_LOGIN, REQUEST_ID,
                        PROGRAM_APPLICATION_ID, PROGRAM_ID,
                        PROGRAM_UPDATE_DATE, LOAD_TYPE, LOAD_DATE, LOAD_STATUS,
                        PROMOTION_ID, CUSTOMER_ID,
                        PARTY_ID, ADDRESS_ID,
                        PARTY_SITE_ID, SOURCE_SYSTEM, BATCH_ID,
                        REL_PARTY_ID, CONTACT_PARTY_ID,
                        INTERACTION_SCORE, SOURCE_PRIMARY_REFERENCE
                    ) VALUES (
                        AS_IMPORT_INTERFACE_S.nextval, SYSDATE,
                        fnd_global.user_id, SYSDATE, fnd_global.user_id,
                        FND_GLOBAL.CONC_LOGIN_ID, FND_GLOBAL.Conc_Request_Id,
                        FND_GLOBAL.Prog_Appl_Id, FND_GLOBAL.Conc_Program_Id,
                        SYSDATE, 'LEAD_LOAD', SYSDATE, 'NEW',
                        l_source_code_id_tbl(i), l_customer_id_tbl(i),
                        l_customer_id_tbl(i), l_address_id_tbl(i),
                        l_address_id_tbl(i), 'INTERACTION', l_batch_id,
                        l_party_id_tbl(i), l_contact_party_id_tbl(i),
                        l_interaction_score, l_interaction_id_tbl(i))
                    RETURNING IMPORT_INTERFACE_ID INTO l_import_interface_id;
                    AML_DEBUG('Create new response ' || l_import_interface_id);
                END IF; -- l_import_interface_id IS NULL or not

                OPEN C_Get_Category(l_interaction_id_tbl(i),
                    l_default_source_code);
                LOOP
                    FETCH C_Get_Category INTO l_category_id,
                        l_category_set_id, l_inventory_item_id,
                        l_organization_id, l_uom_code, l_quantity;
                    EXIT WHEN C_Get_Category%NOTFOUND;
                    AML_DEBUG('found category_id=' || l_category_id);

                    INSERT INTO AS_IMP_LINES_INTERFACE(
                        IMP_LINES_INTERFACE_ID,
                        IMPORT_INTERFACE_ID, LAST_UPDATE_DATE,
                        LAST_UPDATED_BY, CREATION_DATE,
                        CREATED_BY, LAST_UPDATE_LOGIN,
                        REQUEST_ID, PROGRAM_APPLICATION_ID,
                        PROGRAM_ID, PROGRAM_UPDATE_DATE,
                        SOURCE_PROMOTION_ID, CATEGORY_ID,
                        INVENTORY_ITEM_ID, ORGANIZATION_ID, UOM_CODE,
                        QUANTITY
                    ) VALUES (
                        AS_IMP_LINES_INTERFACE_S.nextval,
                        l_import_interface_id, SYSDATE,
                        fnd_global.user_id, SYSDATE,
                        fnd_global.user_id, FND_GLOBAL.CONC_LOGIN_ID,
                        FND_GLOBAL.Conc_Request_Id, FND_GLOBAL.Prog_Appl_Id,
                        FND_GLOBAL.Conc_Program_Id, SYSDATE,
                        l_source_code_id_tbl(i), l_category_id,
                        l_inventory_item_id, l_organization_id, l_uom_code,
                        l_quantity)
                    RETURNING IMP_LINES_INTERFACE_ID INTO
                        l_imp_lines_interface_id;
                    AML_DEBUG('created imp_lines_interface_id='
                        || l_imp_lines_interface_id);
                END LOOP;
                CLOSE C_Get_Category;

                -- Maintain relevance of interaction and response
                l_INTERACTION_LEAD_ID := NULL;
                AML_INTERACTION_LEADS_PKG.INSERT_ROW(
                    px_INTERACTION_LEAD_ID    => l_INTERACTION_LEAD_ID,
                    p_INTERACTION_ID          => l_interaction_id_tbl(i),
                    p_IMPORT_INTERFACE_ID     => l_import_interface_id,
                    p_SALES_LEAD_ID           => NULL,
                    p_CREATION_DATE           => SYSDATE,
                    p_CREATED_BY              => fnd_global.user_id,
                    p_LAST_UPDATE_DATE        => SYSDATE,
                    p_LAST_UPDATED_BY         => fnd_global.user_id,
                    p_LAST_UPDATE_LOGIN       => FND_GLOBAL.CONC_LOGIN_ID,
                    p_REQUEST_ID              => FND_GLOBAL.Conc_Request_Id,
                    p_PROGRAM_APPLICATION_ID  => FND_GLOBAL.Prog_Appl_Id,
                    p_PROGRAM_ID              => FND_GLOBAL.Conc_Program_Id,
                    p_PROGRAM_UPDATE_DATE     => SYSDATE,
                    p_OBJECT_VERSION_NUMBER   => 1,
                    p_SCORE                   => l_interaction_score);
	    END IF; -- sales_lead_id is NULL or not
        END LOOP; -- for each interaction

        -- If interaction_score is less than threshold, lead import doesn't
        -- need to process this record. Therefore, set batch_id to NULL,
        -- so lead import program won't pick up this record, and interaction
        -- engine can match this interaction again next time.
        l_interaction_score_threshold :=
            NVL(TO_NUMBER(FND_PROFILE.Value('AS_INTERACTION_SCORE_THRESHOLD')), 0);
        AML_DEBUG('intr score threshold: ' || l_interaction_score_threshold);
        UPDATE as_import_interface
        SET last_update_date = SYSDATE,
            last_updated_by = fnd_global.user_id,
            last_update_login = FND_GLOBAL.CONC_LOGIN_ID,
            batch_id = NULL
        WHERE batch_id = l_batch_id
        AND source_system = 'INTERACTION'
        AND interaction_score < l_interaction_score_threshold;

        -- Only if there is one or more records in as_import_interface,
        -- then we launch lead import program.
        l_run_import_flag := 'N';
        OPEN C_Get_Run_Import_Flag(l_batch_id);
        FETCH C_Get_Run_Import_Flag INTO l_run_import_flag;
        CLOSE C_Get_Run_Import_Flag;
        AML_DEBUG('l_run_import_flag: ' || l_run_import_flag);

        IF l_run_import_flag = 'Y'
        THEN
            -- Call Lead Import program to import lead.
            l_request_id := FND_REQUEST.SUBMIT_REQUEST('AS',
                            'ASXSLIMP',
                            'Import Sales Leads',
                            '',
                            FALSE,
                            'INTERACTION',
                            p_debug_mode,
                            l_batch_id, -- batch id
                            'N',
                            CHR(0));

            IF l_request_id = 0
            THEN
                l_msg_data := FND_MESSAGE.GET;
                AML_DEBUG(l_msg_data);
            END IF;
        END IF;

        AML_DEBUG('submitted request ' || l_request_id);
    END IF; -- If more than on interaction is found

/*
-- The following logic is to find open opportunity for closed lead.
-- It's low priority for 11.5.10.
-- Find open opportunity, if no open lead matched
IF l_sales_lead_id IS NULL THEN
    SELECT sl.sales_lead_id, sl.status_code, sl.status_open_flag
    INTO l_sales_lead_id, l_status_code, l_status_open_flag
    FROM as_sales_leads sl, as_sales_lead_opportunity slo, as_leads_all opp, as_statuses_b status
    WHERE sl.creation_date > l_lead_interaction_lookback
    AND sl.customer_id = l_customer_id
    AND sl.status_code = 'CONVERTED_TO_OPPORTUNITY'
    AND sl.sales_lead_id = slo.sales_lead_id
    AND slo.opportunity_id = opp.lead_id
    AND opp.status_code = status.status_code
    AND status.opp_open_status_flag = 'Y'
    ORDER BY sl.lead_rank_score DESC, sl.creation_date DESC;
END IF;
IF l_status_code = 'NEW' THEN
    Create_Sales_Lead_Lines for interest_type_id from l_source_code_id(both interaction and activities);
    L_lead_interaction_score := l_lead_interaction_score + l_interaction_score;
    UPDATE as_sales_leads
    SET lead_rank_id = NULL, channel_code = NULL, interaction_score = l_lead_interaction_score
    WHERE sales_lead_id = l_sales_lead_id;
    Call Lead_Process_After_Update;
END IF;
UPDATE jtf_ih_interactions
SET sales_lead_id = l_sales_lead_id
WHERE interaction_id = l_interaction_id;
*/

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      AML_DEBUG('Expected error');

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      AML_DEBUG('Unexpected error');

  WHEN others THEN
      AML_DEBUG('Exception: others in Run_Interaction_Engine');
      AML_DEBUG('SQLCODE ' || to_char(SQLCODE) ||
               ' SQLERRM ' || substr(SQLERRM, 1, 100));

      errbuf := SQLERRM;
      retcode := FND_API.G_RET_STS_UNEXP_ERROR;
      l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);

END Run_Interaction_Engine;


/*-------------------------------------------------------------------------*
 | PRIVATE ROUTINE
 |  AML_Debug
 |
 | PURPOSE
 |  Write debug message
 |
 | NOTES
 |
 |
 | HISTORY
 |   06/17/2003  SOLIN  Created
 *-------------------------------------------------------------------------*/


PROCEDURE AML_DEBUG(msg IN VARCHAR2)
IS
l_length        NUMBER;
l_start         NUMBER;
l_substring     VARCHAR2(255);

l_base          VARCHAR2(12);
BEGIN
    l_start := 1;
    IF g_debug_flag = 'Y'
    THEN
        -- chop the message to 255 long
        l_length := length(msg);
        WHILE l_length > 255 LOOP
            l_substring := substr(msg, l_start, 255);
            FND_FILE.PUT_LINE(FND_FILE.LOG, l_substring);
            -- dbms_output.put_line(l_substring);

            l_start := l_start + 255;
            l_length := l_length - 255;
        END LOOP;

        l_substring := substr(msg, l_start);
        FND_FILE.PUT_LINE(FND_FILE.LOG,l_substring);
        -- dbms_output.put_line(l_substring);
    END IF;
EXCEPTION
WHEN others THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception: others in AML_DEBUG');
      FND_FILE.PUT_LINE(FND_FILE.LOG,
               'SQLCODE ' || to_char(SQLCODE) ||
               ' SQLERRM ' || substr(SQLERRM, 1, 100));
END AML_Debug;


END AML_INTERACTION_ENGINE;

/
