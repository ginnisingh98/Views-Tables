--------------------------------------------------------
--  DDL for Package Body BOMPKMUD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPKMUD" AS
/* $Header: BOMKMUDB.pls 120.11.12010000.5 2012/03/28 11:30:10 anagubad ship $ */

--+==========================================================================
--|
--| HISTORY: ..-SEP-03 odaboval added procedure Raise_ECO_Create_Event
--|                             for raising that event after creating the ECO
--|    14-oct-03 odaboval  made ERES calls 8i compliant.
--|    29-May-06 BBPATEL    Performance fix
--|
--|
--+==========================================================================*/

--
--  Lookup values for acd_type (domain BOM_CO_ACTION) in
--  bom_inventory_comps_interface.
--
        action_add      CONSTANT NUMBER(1) := 1;
        action_change   CONSTANT NUMBER(1) := 4;  -- new attributes
        action_delete   CONSTANT NUMBER(1) := 3;
        action_replace  CONSTANT NUMBER(1) := 2;  -- old attributes
--
--  Lookup values for acd_type in bom_inventory_components
--
        ecg_action_add    CONSTANT NUMBER(1) := 1;
        ecg_action_change CONSTANT NUMBER(1) := 2;
        ecg_action_delete CONSTANT NUMBER(1) := 3;
--
-- Defaults
--
        default_approval_status        CONSTANT NUMBER(1) := 5; -- approved
        default_operation_seq_num      CONSTANT NUMBER(1) := 1;
        default_component_quantity     CONSTANT NUMBER(1) := 1;
        default_component_yield_factor CONSTANT NUMBER(1) := 1;
        default_planning_factor        CONSTANT NUMBER(3) := 100;
        default_quantity_related       CONSTANT NUMBER(1) := 2;
        default_include_in_cost_rollup CONSTANT NUMBER(1) := 2;
        default_check_atp              CONSTANT NUMBER(1) := 2;
        default_disposition            CONSTANT NUMBER(1) := 1;
        default_status                 CONSTANT NUMBER(1) := 1;  -- open

--
--  Lookup values for bom_item_type in mtl_system_items.
--
        model_type        CONSTANT NUMBER(1) := 1;
        option_class_type CONSTANT NUMBER(1) := 2;
        planning_type     CONSTANT NUMBER(1) := 3;
        standard_type     CONSTANT NUMBER(1) := 4;

--
--  Lookup values for wip_supply_type in mtl_system_items.
--
        phantom CONSTANT NUMBER(1) := 6;

--
--  Lookup values for assembly type
--
        mfg CONSTANT NUMBER(1) := 1;
        eng CONSTANT NUMBER(1) := 2;

--
--  Lookup value for MRP_ATO_FORECAST_CONTROL
--
        g_consume_and_derive CONSTANT NUMBER(1) := 2;

--
--  Lookup value for EFFECTIVITY_CONTROL
--
        date_control CONSTANT NUMBER(1) := 1;
        unit_control CONSTANT NUMBER(1) := 2;

--
--  Lookup value for structure EFFECTIVITY_CONTROL
--
        G_STRUCT_DATE_EFF CONSTANT NUMBER(1) := 1;
        G_STRUCT_UNIT_EFF CONSTANT NUMBER(1) := 2;
        G_STRUCT_SER_EFF  CONSTANT NUMBER(1) := 3;
        G_STRUCT_REV_EFF  CONSTANT NUMBER(1) := 4;

--
--  Bug 4106826 - Added variable l_bom_lists_count for debugging
--
    l_bom_lists_count NUMBER;


-- ERES change begins
PROCEDURE Raise_ECO_Create_Event( p_organization_id   IN NUMBER
                                , p_organization_code IN VARCHAR2
                                , p_change_notice     IN VARCHAR2
                                , x_return_status     IN OUT NOCOPY VARCHAR2
                                --, x_msg_data          OUT NOCOPY VARCHAR2
                                , x_msg_count         IN OUT NOCOPY NUMBER)
IS

CURSOR Get_ECO_details( org_id IN NUMBER
                      , eco    IN VARCHAR2) IS
SELECT change_id
FROM ENG_ENGINEERING_CHANGES
WHERE change_mgmt_type_code = 'CHANGE_ORDER'
AND organization_id = org_id
AND change_notice = eco;

l_child_record         QA_EDR_STANDARD.ERECORD_ID_TBL_TYPE;
l_event                QA_EDR_STANDARD.ERES_EVENT_REC_TYPE;
-- l_payload              FND_WF_EVENT.PARAM_TABLE;
l_change_id            NUMBER;
l_parent_record_id     NUMBER;
l_msg_data             VARCHAR2(2000);
l_message              VARCHAR2(2000);
l_dummy_cnt            NUMBER;
l_erecord_id           NUMBER;
l_trans_status         VARCHAR2(20);
l_event_status         VARCHAR2(20);
l_send_ackn            BOOLEAN;
l_ackn_by              VARCHAR2(200);

RAISE_ERES_EVENT_ERROR EXCEPTION;
SEND_ACKN_ERROR        EXCEPTION;
BEGIN

x_return_status := FND_API.G_FALSE;

FND_FILE.PUT_LINE(FND_FILE.LOG, 'Beginning the ERES part for org_id='||p_organization_id||', change_notice='||p_change_notice);

-- Get Parent Event record id :
-- The error is not trapped, so that the execution can carry on.
QA_EDR_STANDARD.GET_ERECORD_ID
        ( p_api_version   => 1.0
        , p_init_msg_list => FND_API.G_TRUE
        , x_return_status => x_return_status
        , x_msg_count     => x_msg_count
        , x_msg_data      => l_msg_data
        , p_event_name    => 'oracle.apps.eng.massChangeBill'
        , p_event_key     => TO_CHAR(p_organization_id)||'-'||p_change_notice
        , x_erecord_id    => l_parent_record_id);


-- Prepare ecoCreate event
OPEN Get_ECO_Details(p_organization_id, p_change_notice);
FETCH Get_ECO_Details
 INTO l_change_id;
CLOSE Get_ECO_Details;

FND_FILE.PUT_LINE(FND_FILE.LOG, 'change_id='||l_change_id||', parent_id='||l_parent_record_id);
IF (l_change_id IS NOT NULL)
THEN
  -- First: Preparing child event #1

  l_event.param_name_1  := 'DEFERRED';
  l_event.param_value_1 := 'Y';

  l_event.param_name_2  := 'POST_OPERATION_API';
  l_event.param_value_2 := 'NONE';

  l_event.param_name_3  := 'PSIG_USER_KEY_LABEL';
  FND_MESSAGE.SET_NAME('ENG', 'ENG_ERES_ECO_USER_KEY');
  l_event.param_value_3 := FND_MESSAGE.GET;

  l_event.param_name_4  := 'PSIG_USER_KEY_VALUE';
  l_event.param_value_4 := p_organization_code||'-'||p_change_notice;

  l_event.param_name_5  := 'PSIG_TRANSACTION_AUDIT_ID';
  l_event.param_value_5 := -1;

  l_event.param_name_6  := '#WF_SOURCE_APPLICATION_TYPE';
  l_event.param_value_6 := 'DB';

  l_event.param_name_7  := '#WF_SIGN_REQUESTER';
  l_event.param_value_7 := FND_GLOBAL.USER_NAME;

  IF (l_parent_record_id > 0)
  THEN
    --additional parameters for the child event
    l_event.param_name_8 := 'PARENT_EVENT_NAME';
    l_event.param_value_8 := 'oracle.apps.eng.massChangeBill';
    l_event.param_name_9 := 'PARENT_EVENT_KEY';
    l_event.param_value_9 := TO_CHAR(p_organization_id)||'-'||p_change_notice;
    l_event.param_name_10 := 'PARENT_ERECORD_ID';
    l_event.param_value_10 := TO_CHAR(l_parent_record_id);
  END IF;

  -- Part 2 of preparation of child event :
  l_event.event_name   := 'oracle.apps.eng.ecoCreate';
  l_event.event_key    := TO_CHAR(l_change_id);
  -- l_event.payload      := l_payload;
  l_event.erecord_id   := l_erecord_id;
  l_event.event_status := l_event_status;

  QA_EDR_STANDARD.RAISE_ERES_EVENT
      ( p_api_version      => 1.0
      , p_init_msg_list    => FND_API.G_FALSE
      , p_validation_level => FND_API.G_VALID_LEVEL_FULL
      , x_return_status    => x_return_status
      , x_msg_count        => x_msg_count
      , x_msg_data         => l_msg_data
      , p_child_erecords   => l_child_record
      , x_event            => l_event);

  IF (NVL(x_return_status, FND_API.G_FALSE) <> FND_API.G_TRUE)
    AND (x_msg_count > 0)
  THEN
       RAISE RAISE_ERES_EVENT_ERROR;

  END IF;

  IF (l_event.event_status = 'PENDING')
  THEN
       l_send_ackn := TRUE;
       l_trans_status := 'SUCCESS';
  ELSIF (l_event.event_status = 'ERROR'
      AND l_event.erecord_id IS NOT NULL)
  THEN
       l_send_ackn := TRUE;
       l_trans_status := 'ERROR';
  ELSIF (l_event.event_status = 'NOACTION'
      AND l_event.erecord_id IS NOT NULL)
  THEN
       l_send_ackn := TRUE;
       l_trans_status := 'SUCCESS';
  END IF;
  IF (l_send_ackn = TRUE )
  THEN
     FND_MESSAGE.SET_NAME('ENG', 'ENG_ERES_ACKN_MASS_CHANGES');
     l_ackn_by := FND_MESSAGE.GET;

     QA_EDR_STANDARD.SEND_ACKN
         ( p_api_version       => 1.0
         , p_init_msg_list     => FND_API.G_FALSE
         , x_return_status     => x_return_status
         , x_msg_count         => x_msg_count
         , x_msg_data          => l_msg_data
         , p_event_name        => l_event.event_name
         , p_event_key         => l_event.event_key
         , p_erecord_id        => l_event.erecord_id
         , p_trans_status      => l_trans_status
         , p_ackn_by           => l_ackn_by
         , p_ackn_note         => '(organization_id, change_notice)='||TO_CHAR(p_organization_id)||', '||p_change_notice||')'
         , p_autonomous_commit => FND_API.G_FALSE);

     FND_FILE.PUT_LINE(FND_FILE.LOG, 'After QA_EDR_STANDARD.SEND_ACKN msg='||x_msg_count);
     IF (NVL(x_return_status, FND_API.G_FALSE) <> FND_API.G_TRUE)
       AND (x_msg_count > 0)
     THEN
          RAISE SEND_ACKN_ERROR;
     END IF;

  END IF;  -- (l_send_ackn = TRUE)
END IF;   -- (l_change_id IS NOT NULL)

EXCEPTION
WHEN RAISE_ERES_EVENT_ERROR THEN
  FND_FILE.PUT_LINE(FND_FILE.LOG,'ECO Create event, RAISE_ERES_EVENT_ERROR :');
  -- Get the message and raise the procedure exception.
  FND_MSG_PUB.Get(
            p_msg_index  => 1,
            p_data       => l_message,
            p_encoded    => FND_API.G_FALSE,
            p_msg_index_out => l_dummy_cnt);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Error='||l_message);

WHEN SEND_ACKN_ERROR THEN
  FND_FILE.PUT_LINE(FND_FILE.LOG,'ECO Create event, SEND_ACKN_ERROR :');
  -- Get the message and raise the procedure exception.
  FND_MSG_PUB.Get(
            p_msg_index  => 1,
            p_data       => l_message,
            p_encoded    => FND_API.G_FALSE,
            p_msg_index_out => l_dummy_cnt);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Error='||l_message);

WHEN OTHERS THEN
  FND_FILE.PUT_LINE(FND_FILE.LOG,'ECO Create event, OTHERS :'||SQLERRM);

END Raise_ECO_Create_Event;
-- ERES change ends


FUNCTION cnt(p_list_id NUMBER)
RETURN NUMBER IS
    CURSOR lc_cnt IS
        SELECT COUNT(*)
          FROM bom_lists
         WHERE sequence_id = p_list_id;
    l_cnt NUMBER;
BEGIN
    OPEN lc_cnt;
    FETCH lc_cnt
     INTO l_cnt;
    CLOSE lc_cnt;
    RETURN l_cnt;
END cnt;

----------------------------- Procedure ---------------------------------
--
--  NAME
--      Match_Attributes
--  DESCRIPTION
--      Checks if component exists with attributes matching criteria in
--      component interface table.
--  REQUIRES
--      List - Sequence id of list in BOM_LISTS.
--      ECO - Engineering change order number of Mass Change Order.
--      Org Id - Organization id of Mass Change Order.
--  MODIFIES
--      Error Message - PL/SQL error.
--  RETURNS
--
--  NOTES
--
--  EXAMPLE
--
PROCEDURE Match_Attributes(
  p_list_id       IN  bom_lists.sequence_id%TYPE,
  p_eco           IN  eng_revised_items_interface.change_notice%TYPE,
  p_org_id        IN  eng_revised_items_interface.organization_id%TYPE,
  x_error_message IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS

BEGIN
    SAVEPOINT begin_match;

-- Bug 4216428

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Delete rev effective structures from list');
 DELETE FROM bom_lists l
    WHERE l.sequence_id = p_list_id
    AND   EXISTS (
          SELECT NULL
          FROM   bom_bill_of_materials b
          WHERE  b.assembly_item_id = l.assembly_item_id
          AND    b.organization_id = p_org_id
          AND    ( (b.alternate_bom_designator IS NULL AND l.alternate_designator IS NULL)
                 OR (b.alternate_bom_designator = l.alternate_designator) )
          AND    b.effectivity_control =4);
--
--  Bug 4106826
--
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Entered Match Attributes');
    select count(*) into l_bom_lists_count from bom_lists where sequence_id = p_list_id;
    FND_FILE.PUT_LINE(FND_FILE.LOG,'  Records in BOM_LISTS before delete st in Match attributes='||
                                    to_char(l_bom_lists_count));
-- end Bug 4106826

    -- Removed NVL and added AND/OR condition on Alternate_bom_desigantor to improve performance
    DELETE FROM bom_lists l
    WHERE l.sequence_id = p_list_id
    AND   EXISTS (
          SELECT NULL
          FROM
                 bom_inventory_comps_interface ci,
                 eng_revised_items_interface ri
          WHERE
                 ci.acd_type IN (action_replace, action_delete)
          AND    ci.revised_item_sequence_id = ri.revised_item_sequence_id
          AND    ri.change_notice = p_eco
          AND    ri.organization_id = p_org_id
          /* For bug 8550652
          AND    NOT EXISTS (
                  SELECT NULL
                  FROM   eng_revised_items_interface rii,
                         bom_inventory_comps_interface cii
                  WHERE  rii.change_notice = p_eco
                         AND  rii.organization_id = p_org_id
                         AND  rii.revised_item_sequence_id =
                                       ri.revised_item_sequence_id
                         AND  cii.revised_item_sequence_id =
                                       ri.revised_item_sequence_id
                         AND    cii.acd_type IN (action_add))
          For bug 8550652 */
          AND    NOT EXISTS (
                 SELECT NULL
                 FROM   bom_structures_b b,
                        bom_components_b c
                 WHERE
                        b.assembly_item_id = l.assembly_item_id
                 AND    b.organization_id = p_org_id
                 AND    ( (l.alternate_designator IS NULL AND b.alternate_bom_designator IS NULL)
                          OR (b.alternate_bom_designator = l.alternate_designator) )
                 AND (c.item_num = ci.item_num
                        OR ci.item_num IS NULL)
     AND (Nvl(c.basis_type,4) = Decode(ci.basis_type, FND_API.G_MISS_NUM,4,ci.basis_type) -- 5214239
                      OR ci.basis_type is NULL)
                 AND (c.component_quantity = ci.component_quantity
                      OR ci.component_quantity IS NULL)
                 AND (c.component_yield_factor = ci.component_yield_factor
                      OR ci.component_yield_factor IS NULL)
                 AND (c.planning_factor = ci.planning_factor
                      OR ci.planning_factor IS NULL)
                 AND (c.quantity_related = ci.quantity_related
                      OR ci.quantity_related IS NULL)
                 AND (c.so_basis = ci.so_basis
                      OR ci.so_basis IS NULL)
                 AND (c.optional = ci.optional
                      OR ci.optional IS NULL)
                 AND (c.mutually_exclusive_options =
                      ci.mutually_exclusive_options
                      OR ci.mutually_exclusive_options IS NULL)
                 AND (c.include_in_cost_rollup = ci.include_in_cost_rollup
                      OR ci.include_in_cost_rollup IS NULL)
                 AND (c.check_atp = ci.check_atp
                      OR ci.check_atp IS NULL)
                 AND (c.shipping_allowed = ci.shipping_allowed
                      OR ci.shipping_allowed IS NULL)
                 AND (c.required_to_ship = ci.required_to_ship
                      OR ci.required_to_ship IS NULL)
                 AND (c.required_for_revenue = ci.required_for_revenue
                      OR   ci.required_for_revenue IS NULL)
                 AND (c.include_on_ship_docs = ci.include_on_ship_docs
                      OR ci.include_on_ship_docs IS NULL)
                 AND (c.low_quantity = ci.low_quantity
                      OR ci.low_quantity IS NULL)
                 AND (c.high_quantity = ci.high_quantity
                      OR ci.high_quantity IS NULL)
                 AND (c.wip_supply_type = ci.wip_supply_type
                      OR ci.wip_supply_type IS NULL)
                 AND (c.supply_subinventory = ci.supply_subinventory
                      OR ci.supply_subinventory IS NULL)
                 AND (c.supply_locator_id = ci.supply_locator_id
                      OR ci.supply_locator_id IS NULL)
                 AND (c.component_remarks = ci.component_remarks
                     OR ci.component_remarks IS NULL)
                 AND (c.attribute_category = ci.attribute_category
                      OR ci.attribute_category IS NULL)
                 AND (c.attribute1 = ci.attribute1 OR ci.attribute1 IS NULL)
                 AND (c.attribute2 = ci.attribute2 OR ci.attribute2 IS NULL)
                 AND (c.attribute3 = ci.attribute3 OR ci.attribute3 IS NULL)
                 AND (c.attribute4 = ci.attribute4 OR ci.attribute4 IS NULL)
                 AND (c.attribute5 = ci.attribute5 OR ci.attribute5 IS NULL)
                 AND (c.attribute6 = ci.attribute6 OR ci.attribute6 IS NULL)
                 AND (c.attribute7 = ci.attribute7 OR ci.attribute7 IS NULL)
                 AND (c.attribute8 = ci.attribute8 OR ci.attribute8 IS NULL)
                 AND (c.attribute9 = ci.attribute9 OR ci.attribute9 IS NULL)
                 AND (c.attribute10 = ci.attribute10 OR ci.attribute10 IS NULL)
                 AND (c.attribute11 = ci.attribute11 OR ci.attribute11 IS NULL)
                 AND (c.attribute12 = ci.attribute12 OR ci.attribute12 IS NULL)
                 AND (c.attribute13 = ci.attribute13 OR ci.attribute13 IS NULL)
                 AND (c.attribute14 = ci.attribute14 OR ci.attribute14 IS NULL)
                 AND (c.attribute15 = ci.attribute15 OR ci.attribute15 IS NULL)
                 AND  c.operation_seq_num =
                      NVL(ci.operation_seq_num, c.operation_seq_num)
                 AND  c.component_item_id = ci.component_item_id
                 AND  c.bill_sequence_id = b.bill_sequence_id

                 AND     NVL(TRUNC(c.disable_date), NVL(ri.scheduled_date,TRUNC(SYSDATE)) + 1) >
                         NVL(ri.scheduled_date,TRUNC(SYSDATE))
                 AND     TRUNC(c.effectivity_date) <= NVL(ri.scheduled_date,TRUNC(SYSDATE))

                 AND  (     ( b.effectivity_control IN (G_STRUCT_DATE_EFF, G_STRUCT_REV_EFF) )
                        OR
                        (
                             ( b.effectivity_control IN (G_STRUCT_UNIT_EFF, G_STRUCT_SER_EFF) )
                          AND NVL(c.to_end_item_unit_number, ri.from_end_item_unit_number) >=
                                                              ri.from_end_item_unit_number
                          AND c.from_end_item_unit_number <= ri.from_end_item_unit_number )
                      )
                 )
             );

    x_error_message := NULL;
    COMMIT;
    select count(*) into l_bom_lists_count from bom_lists where sequence_id = p_list_id;
    FND_FILE.PUT_LINE(FND_FILE.LOG,'  Records in BOM_LISTS after delete st in match_attribute='||
                                    to_char(l_bom_lists_count));

EXCEPTION
    WHEN others THEN
        ROLLBACK TO begin_match;
        x_error_message := SUBSTRB(sqlerrm, 1, 150);
END Match_Attributes;

----------------------------- Procedure ---------------------------------
--
--  NAME
--      Check_Combination
--  DESCRIPTION
--      Checks attributes of component item with those of revised item to see
--      if they are compatible.
--  REQUIRES
--      List id - Sequence id of list in BOM_LISTS.
--      ECO - Engineering Change Order number of Mass Update.
--      Organization - Organization id of revised item.
--  MODIFIES
--      Error Message - PL/SQL error.
--  RETURNS
--
--  NOTES
--
--  EXAMPLE
--

PROCEDURE Check_Combination(
    p_list_id       IN  bom_lists.sequence_id%TYPE,
    p_eco           IN  eng_revised_items_interface.change_notice%TYPE,
    p_organization  IN  eng_revised_items_interface.organization_id%TYPE,
    x_error_message IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS

BEGIN
    SAVEPOINT begin_combo;

--
-- 1.  Y = Allowed  N = Not Allowed
--     P = Must be Phantom  O = Must be Optional
--     Configured items are ATO standard items that have a base item id.
--     ATO items have Replenish to Order flags set to "Y".
--     PTO items have Pick Component flags set to "Y".
--
--                                     Parent
-- Child         |Config  ATO Mdl  ATO Opt  ATO Std  PTO Mdl  PTO Opt  PTO Std
-- ---------------------------------------------------------------------------
-- Planning      |   N       N        N        N        N        N        N
-- Configured    |   Y       Y        Y        Y        Y        Y        N
-- ATO Model     |   P       P        P        N        P        P        N
-- ATO Opt Class |   P       P        P        N        N        N        N
-- ATO Standard  |   Y       Y        Y        Y        O        O        N
-- PTO Model     |   N       N        N        N        P        P        N
-- PTO Opt Class |   N       N        N        N        P        P        N
-- PTO Standard  |   N       N        N        N        Y        Y        Y
--
-- NOTE:  Phantoms and Optional are handled by an update statement in
-- procedure Mass_Update below.
--
-- 2.   Check Component ATP, delete bill from list if:
--
--      - Revised Item is ATO Model, ATO Option Class, ATO Standard,
--        PTO Model, PTO Option Class, PTO Standard or Phantom and ATP
--        Components Flag is set to No.
--
--      - Component Item's ATP Flag or ATP Components Flag is set to Yes.
--
    select count(*) into l_bom_lists_count from bom_lists where sequence_id = p_list_id;
    FND_FILE.PUT_LINE(FND_FILE.LOG,'  Records in BOM_LISTS before delete stmt Check_Combination ='||
                                    to_char(l_bom_lists_count));
    DELETE FROM bom_lists l
    WHERE l.sequence_id = p_list_id
    AND   EXISTS (
            SELECT NULL
            FROM mtl_system_items_b ri,
                 mtl_system_items_b ci,
                 bom_inventory_comps_interface c,
                 eng_revised_items_interface r
            WHERE ((ci.bom_item_type = planning_type AND
                    ri.bom_item_type <> planning_type)
                   OR
                   (ci.bom_item_type IN (model_type, option_class_type) AND
                    ri.bom_item_type = standard_type AND
                    ri.base_item_id IS NULL)
                   OR
                   (ci.replenish_to_order_flag = 'Y' AND
                    ci.bom_item_type = option_class_type AND
                    ri.pick_components_flag = 'Y')
                   OR
                   (ci.replenish_to_order_flag = 'Y' AND
                    ci.bom_item_type = standard_type AND
                    ri.pick_components_flag = 'Y' AND
                    ri.bom_item_type = standard_type)
                   OR
                   (ci.pick_components_flag = 'Y' AND
                    ri.replenish_to_order_flag = 'Y')
                   /* commented for bug 3548357 and 3508992
                   OR
                   (ri.bom_item_type <> planning_type AND
                    ri.atp_components_flag = 'N'
                    AND (ri.replenish_to_order_flag = 'Y' OR
                         ri.pick_components_flag = 'Y' OR
                         ri.wip_supply_type = phantom)
                    AND (ci.atp_flag = 'Y'
                         OR ci.atp_components_flag = 'Y'))*/
                  )
            AND   ri.inventory_item_id = l.assembly_item_id
            AND   ri.organization_id = p_organization
            AND   ci.inventory_item_id = c.component_item_id
            AND   ci.organization_id = p_organization
            AND   c.acd_type IN (action_add, action_change)
            AND   c.revised_item_sequence_id = r.revised_item_sequence_id
            AND   r.change_notice = p_eco
            AND   r.organization_id = p_organization);

      select count(*) into l_bom_lists_count from bom_lists where sequence_id = p_list_id;
    FND_FILE.PUT_LINE(FND_FILE.LOG,'  Records in BOM_LISTS after delete stmt 1 Check_Combination ='||
                                    to_char(l_bom_lists_count));

--
-- Do not create revised items if:
--
--      - Optional = Yes and Revised Item <> Model/OC
--      - Planning Percent <> 100% and
--         - Revised Item is Standard or
--         - Revised Items is Model/OC and
--           Component is mandatory and is not "Consume or Derive"
--      - Shippable = Yes and Revised Items is not pick-to-order
--

    DELETE FROM bom_lists l
    WHERE l.sequence_id = p_list_id
    AND EXISTS (
            SELECT NULL
            FROM mtl_system_items_b i,
                 mtl_system_items_b ci,
                 bom_inventory_comps_interface c,
                 eng_revised_items_interface r
            WHERE ((c.optional = yes AND i.bom_item_type
                    NOT IN (model_type, option_class_type))
                   OR
                   (c.planning_factor <> default_planning_factor
                    AND ((i.bom_item_type IN
                            (model_type, option_class_type)
                         AND c.optional = no
                         AND ci.ato_forecast_control <>
                             g_consume_and_derive)
                         OR (i.bom_item_type = standard_type)))
                  )
            AND   i.inventory_item_id = l.assembly_item_id
            AND   i.organization_id = r.organization_id
            AND   ci.inventory_item_id = c.component_item_id
            AND   ci.organization_id = r.organization_id
            AND   c.acd_type = action_add
            AND   c.revised_item_sequence_id = r.revised_item_sequence_id
            AND   r.change_notice = p_eco
            AND   r.organization_id = p_organization);
         select count(*) into l_bom_lists_count from bom_lists where sequence_id = p_list_id;
    FND_FILE.PUT_LINE(FND_FILE.LOG,'  Records in BOM_LISTS after delete stmt 2 in  Check_Combination='||
                                    to_char(l_bom_lists_count));

    DELETE FROM bom_lists bl
    WHERE bl.sequence_id = p_list_id
    AND EXISTS (
            SELECT NULL
            FROM mtl_system_items_b ri_itm, -- revised item
                 mtl_system_items_b ci_itm, -- component item
                 bom_inventory_components c,
                 bom_bill_of_materials bom,
                 bom_inventory_comps_interface o, -- old component
                 bom_inventory_comps_interface n, -- new component
                 eng_revised_items_interface ri
            WHERE ri_itm.inventory_item_id = bom.assembly_item_id
            AND   ri_itm.organization_id = bom.organization_id
            AND   ci_itm.inventory_item_id = c.component_item_id
            AND   ci_itm.organization_id = bom.organization_id
            AND  ((NVL(n.optional, c.optional) = yes AND
                   ri_itm.bom_item_type NOT IN
                     (model_type, option_class_type))
                   OR
                   (NVL(n.planning_factor, c.planning_factor) <>
                      default_planning_factor
                    AND ((ri_itm.bom_item_type IN
                            (model_type, option_class_type)
                          AND NVL(n.optional, c.optional) = no
                          AND ci_itm.ato_forecast_control <> g_consume_and_derive)
                         OR (ri_itm.bom_item_type = standard_type)))
                  )
            AND  (c.item_num = o.item_num OR o.item_num IS NULL)
            AND  (c.component_quantity = o.component_quantity
                  OR o.component_quantity IS NULL)
            AND  (c.component_yield_factor = o.component_yield_factor
                  OR o.component_yield_factor IS NULL)
            AND  (c.planning_factor = o.planning_factor
                  OR o.planning_factor IS NULL)
            AND  (c.quantity_related = o.quantity_related
                  OR o.quantity_related IS NULL)
            AND  (c.so_basis = o.so_basis OR o.so_basis IS NULL)
            AND  (c.optional = o.optional
                  OR o.optional IS NULL)
            AND  (c.mutually_exclusive_options =
                  o.mutually_exclusive_options
                  OR o.mutually_exclusive_options IS NULL)
            AND  (c.include_in_cost_rollup = o.include_in_cost_rollup
                  OR o.include_in_cost_rollup IS NULL)
            AND  (c.check_atp = o.check_atp
                  OR o.check_atp IS NULL)
            AND  (c.shipping_allowed = o.shipping_allowed
                  OR o.shipping_allowed IS NULL)
            AND  (c.required_to_ship = o.required_to_ship
                  OR o.required_to_ship IS NULL)
            AND  (c.required_for_revenue = o.required_for_revenue
                  OR   o.required_for_revenue IS NULL)
            AND  (c.include_on_ship_docs = o.include_on_ship_docs
                  OR o.include_on_ship_docs IS NULL)
            AND  (c.low_quantity = o.low_quantity
                  OR o.low_quantity IS NULL)
            AND  (c.high_quantity = o.high_quantity
                  OR o.high_quantity IS NULL)
            AND  (c.wip_supply_type = o.wip_supply_type
                  OR o.wip_supply_type IS NULL)
            AND  (c.supply_subinventory = o.supply_subinventory
                  OR o.supply_subinventory IS NULL)
            AND  (c.supply_locator_id = o.supply_locator_id
                  OR o.supply_locator_id IS NULL)
            AND  (c.component_remarks = o.component_remarks
                  OR o.component_remarks IS NULL)
            AND  (c.attribute_category = o.attribute_category
                  OR o.attribute_category IS NULL)
            AND  (c.attribute1 = o.attribute1 OR o.attribute1 IS NULL)
            AND  (c.attribute2 = o.attribute2 OR o.attribute2 IS NULL)
            AND  (c.attribute3 = o.attribute3 OR o.attribute3 IS NULL)
            AND  (c.attribute4 = o.attribute4 OR o.attribute4 IS NULL)
            AND  (c.attribute5 = o.attribute5 OR o.attribute5 IS NULL)
            AND  (c.attribute6 = o.attribute6 OR o.attribute6 IS NULL)
            AND  (c.attribute7 = o.attribute7 OR o.attribute7 IS NULL)
            AND  (c.attribute8 = o.attribute8 OR o.attribute8 IS NULL)
            AND  (c.attribute9 = o.attribute9 OR o.attribute9 IS NULL)
            AND  (c.attribute10 = o.attribute10 OR o.attribute10 IS NULL)
            AND  (c.attribute11 = o.attribute11 OR o.attribute11 IS NULL)
            AND  (c.attribute12 = o.attribute12 OR o.attribute12 IS NULL)
            AND  (c.attribute13 = o.attribute13 OR o.attribute13 IS NULL)
            AND  (c.attribute14 = o.attribute14 OR o.attribute14 IS NULL)
            AND  (c.attribute15 = o.attribute15 OR o.attribute15 IS NULL)
            AND   c.operation_seq_num =
                  NVL(o.operation_seq_num, c.operation_seq_num)
            AND   c.component_item_id = o.component_item_id
            AND   c.bill_sequence_id = bom.bill_sequence_id
            AND    ( (bom.alternate_bom_designator IS NULL AND bl.alternate_designator IS NULL)
                 OR (bom.alternate_bom_designator = bl.alternate_designator) )
            AND   bom.organization_id = ri.organization_id
            AND   bom.assembly_item_id = bl.assembly_item_id
            AND   o.component_sequence_id = n.old_component_sequence_id
            AND   n.acd_type = action_change
            AND   n.revised_item_sequence_id = ri.revised_item_sequence_id
            AND   ri.change_notice = p_eco
            AND   ri.organization_id = p_organization

            AND   NVL(TRUNC(c.disable_date), NVL(ri.scheduled_date,TRUNC(SYSDATE)) + 1) >
                  NVL(ri.scheduled_date,TRUNC(SYSDATE))
            AND   TRUNC(c.effectivity_date) <= NVL(ri.scheduled_date,TRUNC(SYSDATE))

            AND  ((NVL(c.to_end_item_unit_number, ri.from_end_item_unit_number) >=
                   ri.from_end_item_unit_number
               AND c.from_end_item_unit_number <= ri.from_end_item_unit_number
               AND ri_itm.effectivity_control = unit_control)
                  OR
                 ri_itm.effectivity_control = date_control)
            );
    select count(*) into l_bom_lists_count from bom_lists where sequence_id = p_list_id;
    FND_FILE.PUT_LINE(FND_FILE.LOG,'  Records in BOM_LISTS after delete stmt3 in Check_Combination ='||
                                    to_char(l_bom_lists_count));
--
-- Do not create revised items if:
--
--      - Operation Sequence Number does not exist in routing (except 1).
--

    DELETE FROM bom_lists l
    WHERE l.sequence_id = p_list_id
    AND EXISTS (
            SELECT NULL
            FROM bom_inventory_comps_interface ci,
                 eng_revised_items_interface ri
            WHERE   ci.operation_seq_num NOT IN (
                    SELECT o.operation_seq_num
                    FROM bom_operation_sequences o,
                         bom_operational_routings r
                    WHERE NVL(TRUNC(o.disable_date), NVL(ri.scheduled_date,
                                                         TRUNC(SYSDATE)) + 1)
                          > NVL(ri.scheduled_date,TRUNC(SYSDATE))
                    AND   r.common_routing_sequence_id =
                          o.routing_sequence_id
                    AND   (NVL(r.alternate_routing_designator, 'NONE') =
                           NVL(l.alternate_designator, 'NONE')
                           OR
                           (r.alternate_routing_designator IS NULL
                            AND NOT EXISTS (
                                 SELECT NULL
                                 FROM bom_operational_routings rr
                                 WHERE rr.alternate_routing_designator =
                                       l.alternate_designator
                                 AND rr.assembly_item_id =
                                     l.assembly_item_id
                                 AND rr.organization_id =
                                     ri.organization_id))
                          )
                    AND   r.organization_id = ri.organization_id
                    AND   r.assembly_item_id = l.assembly_item_id)
            AND   ci.operation_seq_num <> 1
            AND   ci.acd_type IN (action_add, action_change)
            AND   ci.revised_item_sequence_id = ri.revised_item_sequence_id
            AND   ri.change_notice = p_eco
            AND   ri.organization_id = p_organization
        );

--
--  If use up is specified, only bills for the use up item or bills
--  whose components include the use up item are allowed.
--
    DELETE FROM bom_lists l
    WHERE l.sequence_id = p_list_id
    AND EXISTS (
            SELECT NULL
            FROM eng_revised_items_interface ri,
                 mtl_system_items_b          ri_itm
            WHERE ri.use_up = yes
            AND   ri.change_notice = p_eco
            AND   ri.organization_id = p_organization
            AND   ri.use_up_item_id <> l.assembly_item_id
            AND   ri_itm.organization_id = ri.organization_id
            AND   ri_itm.inventory_item_id = l.assembly_item_id
            AND NOT EXISTS  (
                    SELECT NULL
                    FROM bom_inventory_components c,
                         bom_bill_of_materials    b
                    WHERE c.component_item_id = ri.use_up_item_id
                    AND   b.bill_sequence_id = c.bill_sequence_id
                    AND   b.assembly_item_id = l.assembly_item_id
                    AND   b.organization_id = p_organization
         AND    ( (b.alternate_bom_designator IS NULL AND l.alternate_designator IS NULL)
                 OR (b.alternate_bom_designator = l.alternate_designator) )
                    AND   c.implementation_date IS NOT NULL

                    AND   NVL(TRUNC(c.disable_date), NVL(ri.scheduled_date,TRUNC(SYSDATE)) + 1) >
                          NVL(ri.scheduled_date,TRUNC(SYSDATE))
                    AND   TRUNC(c.effectivity_date) <= NVL(ri.scheduled_date,TRUNC(SYSDATE))

                    AND  ((NVL(c.to_end_item_unit_number, ri.from_end_item_unit_number) >=
                           ri.from_end_item_unit_number
                       AND c.from_end_item_unit_number <= ri.from_end_item_unit_number
                       AND ri_itm.effectivity_control = unit_control)
                          OR
                         ri_itm.effectivity_control = date_control)
                    )
            );

    x_error_message := NULL;
    COMMIT;
     select count(*) into l_bom_lists_count from bom_lists where sequence_id = p_list_id;
    FND_FILE.PUT_LINE(FND_FILE.LOG,'  Records in BOM_LISTS after delete stmt 4 in Check_Combination ='||
                                    to_char(l_bom_lists_count));
EXCEPTION
    WHEN others THEN
        ROLLBACK TO begin_combo;
        x_error_message := SUBSTRB(sqlerrm, 1, 150);
END Check_Combination;

----------------------------- Procedure ---------------------------------
--
--  NAME
--      Check_Component
--  DESCRIPTION
--      Checks if listed items has valid components.
--  REQUIRES
--      List - Sequence id of list in BOM_LISTS.
--      Organization - Organization id of Bill to be checked.
--      Change Order - ECO number of Mass Change Order.
--  MODIFIES
--      Error buffer - Message if PL/SQL error encountered.
--  RETURNS
--
--  NOTES
--
--  EXAMPLE
--
PROCEDURE Check_Component(
    p_list_id      IN  bom_lists.sequence_id%TYPE,
    p_change_order IN  eng_revised_items_interface.change_notice%TYPE,
    p_organization IN  eng_revised_items_interface.organization_id%TYPE,
    x_error_buffer IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS

    l_subroutine_error EXCEPTION;
    l_internal_error   VARCHAR2(150);

BEGIN
    Match_Attributes(p_list_id, p_change_order, p_organization, l_internal_error);
    IF l_internal_error IS NOT NULL THEN
        RAISE l_subroutine_error;
    END IF;
    Check_Combination(p_list_id, p_change_order, p_organization, l_internal_error);
    IF l_internal_error IS NOT NULL THEN
        RAISE l_subroutine_error;
    END IF;
    SAVEPOINT begin_check;

--
--  Bills can not be components of itself.
--
    DELETE FROM bom_lists bl
    WHERE bl.sequence_id = p_list_id
    AND   EXISTS (
            SELECT NULL
            FROM   bom_inventory_comps_interface c,
                   eng_revised_items_interface r
            WHERE  c.revised_item_sequence_id = r.revised_item_sequence_id
            AND    r.change_notice = p_change_order
            AND    r.organization_id = p_organization
            AND    bl.assembly_item_id = c.component_item_id);

--
-- Duplicate adds
--
    DELETE FROM bom_lists l
    WHERE l.sequence_id = p_list_id
    AND EXISTS (
            SELECT NULL
            FROM   bom_inventory_components      c,
                   bom_bill_of_materials         b,
                   bom_inventory_comps_interface ci,
                   eng_revised_items_interface   ri
            WHERE c.implementation_date IS NOT NULL
            AND   c.operation_seq_num =
                  NVL(ci.operation_seq_num, default_operation_seq_num)
            AND   c.component_item_id = ci.component_item_id
            AND   c.bill_sequence_id = b.bill_sequence_id
            AND   ci.acd_type = action_add
            AND   ci.revised_item_sequence_id = ri.revised_item_sequence_id
            AND   ri.change_notice = p_change_order
            AND   ri.organization_id = p_organization
            AND   b.assembly_item_id = l.assembly_item_id
            AND   b.organization_id =  p_organization
         AND    ( (b.alternate_bom_designator IS NULL AND l.alternate_designator IS NULL)
                 OR (b.alternate_bom_designator = l.alternate_designator) )
            AND   NVL(TRUNC(c.disable_date), NVL(ri.scheduled_date,TRUNC(SYSDATE)) + 1) >
                  NVL(ri.scheduled_date,TRUNC(SYSDATE))
            AND   TRUNC(c.effectivity_date) <= NVL(ri.scheduled_date,TRUNC(SYSDATE))
            AND  (    ( b.effectivity_control IN (G_STRUCT_DATE_EFF, G_STRUCT_REV_EFF) )
                  OR
                    (    b.effectivity_control IN (G_STRUCT_UNIT_EFF, G_STRUCT_SER_EFF)
                     AND NVL(c.to_end_item_unit_number, ri.from_end_item_unit_number) >=
                                                                ri.from_end_item_unit_number
                     AND c.from_end_item_unit_number <= ri.from_end_item_unit_number )
                 )
            );

--
-- Duplicate adds check,
--  if action is replace and old comp_item_id!=new comp_item_id
--  Included for mass replace of components.
--
    DELETE FROM bom_lists l
    WHERE l.sequence_id = p_list_id
    AND EXISTS (
            SELECT /*+ ORDERED USE_NL (B C CI CIR RI CO RI_ITM) */ NULL
            FROM   bom_structures_b b,
                   bom_components_b c,
                   bom_inventory_comps_interface ci,
                   bom_inventory_comps_interface cir,
                   eng_revised_items_interface ri,
                   bom_components_b co,
                   mtl_system_items_b ri_itm
            WHERE c.implementation_date IS NOT NULL
            AND   c.operation_seq_num =
                  NVL(ci.operation_seq_num, NVL(cir.operation_seq_num,
                                                co.operation_seq_num))
            AND   c.component_item_id = ci.component_item_id
            AND   c.bill_sequence_id = b.bill_sequence_id
            AND   ci.acd_type = action_change
            AND   ci.old_component_sequence_id = cir.component_sequence_id
            AND   ci.component_item_id <> cir.component_item_id
            AND   ci.revised_item_sequence_id = ri.revised_item_sequence_id
            AND   ri.change_notice = p_change_order
            AND   ri.organization_id = p_organization
            AND   co.operation_seq_num = NVL(cir.operation_seq_num,
                                             co.operation_seq_num)
            AND   co.bill_sequence_id = c.bill_sequence_id
            AND   co.component_item_id = cir.component_item_id
            AND   b.assembly_item_id = l.assembly_item_id
            AND   b.organization_id =  p_organization
            AND   ( (b.alternate_bom_designator IS NULL AND l.alternate_designator IS NULL) OR (b.alternate_bom_designator = l.alternate_designator))
            AND   ri_itm.inventory_item_id = b.assembly_item_id
            AND   ri_itm.organization_id = b.organization_id
            AND   NVL(TRUNC(c.disable_date), NVL(ri.scheduled_date,TRUNC(SYSDATE)) + 1) >
                  NVL(ri.scheduled_date,TRUNC(SYSDATE))
            AND   TRUNC(c.effectivity_date) <= NVL(ri.scheduled_date,TRUNC(SYSDATE))

            AND  ((NVL(c.to_end_item_unit_number, ri.from_end_item_unit_number) >=
                   ri.from_end_item_unit_number
               AND c.from_end_item_unit_number <= ri.from_end_item_unit_number
               AND ri_itm.effectivity_control = unit_control)
                  OR
                 ri_itm.effectivity_control = date_control)
            );

--
--  Only manufacturing items can be added as components to manufacturing bills
--
    DELETE FROM bom_lists l
    WHERE l.sequence_id = p_list_id
    AND EXISTS (
            SELECT NULL
            FROM mtl_system_items_b i,
                 bom_inventory_comps_interface ci,
                 eng_revised_items_interface ri
            WHERE i.eng_item_flag = 'Y'
            AND   i.inventory_item_id = ci.component_item_id
            AND   i.organization_id = p_organization
            AND   ci.acd_type = action_add
            AND   ci.revised_item_sequence_id = ri.revised_item_sequence_id
            AND   ri.change_notice = p_change_order
            AND   ri.organization_id = p_organization
        )
     AND EXISTS (
                  SELECT NULL
                  FROM bom_bill_of_materials b
                  WHERE  b.assembly_type = mfg
                  AND   b.assembly_item_id = l.assembly_item_id
                  AND   b.organization_id =  p_organization
          AND    ( (b.alternate_bom_designator IS NULL AND l.alternate_designator IS NULL)
                 OR (b.alternate_bom_designator = l.alternate_designator) )
                );
--
--  Only manufacturing items can be added as components to manufacturing
--   bills, if action is replace and old comp_item_id!=new comp_item_id
--   Included for mass replace of components.
--
    DELETE FROM bom_lists l
    WHERE l.sequence_id = p_list_id
    AND EXISTS (
            SELECT NULL
            FROM mtl_system_items_b i,
                 bom_inventory_comps_interface ci,
                 bom_inventory_comps_interface cir,
                 eng_revised_items_interface ri
            WHERE i.eng_item_flag = 'Y'
            AND   i.inventory_item_id = ci.component_item_id
            AND   i.organization_id = p_organization
            AND   ci.acd_type = action_change
            AND   ci.old_component_sequence_id = cir.component_sequence_id
            AND   ci.component_item_id <> cir.component_item_id
            AND   ci.revised_item_sequence_id = ri.revised_item_sequence_id
            AND   ri.change_notice = p_change_order
            AND   ri.organization_id = p_organization
        )
    AND EXISTS
    (
            SELECT NULL
            FROM bom_structures_b b
            WHERE
                  b.assembly_type = mfg
            AND   b.assembly_item_id = l.assembly_item_id
            AND   b.organization_id =  p_organization
          AND    ( (b.alternate_bom_designator IS NULL AND l.alternate_designator IS NULL)
                 OR (b.alternate_bom_designator = l.alternate_designator) )
    );

--
-- Duplicate components deletes and changes
--
    DELETE FROM bom_lists l
    WHERE l.sequence_id = p_list_id
    AND EXISTS (
            SELECT NULL
            FROM   bom_components_b c,
                   bom_structures_b b,
                   bom_inventory_comps_interface ci,
                   eng_revised_items_interface ri,
                   mtl_system_items_b  ri_itm
            WHERE c.operation_seq_num =
                  NVL(ci.operation_seq_num, c.operation_seq_num)
            AND   c.component_item_id = ci.component_item_id
            AND   c.bill_sequence_id = b.bill_sequence_id
            AND   ci.acd_type IN (action_delete, action_change)
            AND   ci.revised_item_sequence_id = ri.revised_item_sequence_id
            AND   ri.change_notice = p_change_order
            AND   ri.organization_id = p_organization
            AND   b.assembly_item_id = l.assembly_item_id
            AND   b.organization_id =  p_organization
          AND    ( (b.alternate_bom_designator IS NULL AND l.alternate_designator IS NULL)
                 OR (b.alternate_bom_designator = l.alternate_designator) )
            AND   ri_itm.organization_id = ri.organization_id
            AND   ri_itm.inventory_item_id = ri.revised_item_id

            AND   NVL(TRUNC(c.disable_date), NVL(ri.scheduled_date,TRUNC(SYSDATE)) + 1) >
                  NVL(ri.scheduled_date,TRUNC(SYSDATE))
            AND   TRUNC(c.effectivity_date) <= NVL(ri.scheduled_date,TRUNC(SYSDATE))

            AND  ((NVL(c.to_end_item_unit_number, ri.from_end_item_unit_number) >=
                   ri.from_end_item_unit_number
               AND c.from_end_item_unit_number <= ri.from_end_item_unit_number
               AND ri_itm.effectivity_control = unit_control)
                  OR
                 ri_itm.effectivity_control = date_control)
            );

--
--  Other organizations who use our bills as common bills must have the
--  component items in their organization as well.
--
    DELETE FROM bom_lists l
    WHERE l.sequence_id = p_list_id
    AND EXISTS (
            SELECT NULL
            FROM bom_bill_of_materials cb,
                 bom_bill_of_materials b,
                 bom_inventory_comps_interface ci,
                 eng_revised_items_interface ri
            WHERE NOT EXISTS (
                    SELECT NULL
                    FROM mtl_system_items_b i
                    WHERE i.eng_item_flag = DECODE(cb.assembly_type,
                                            1, 'N',
                                            2, i.eng_item_flag)
                    AND   i.bom_enabled_flag = 'Y'
                    AND   i.organization_id = cb.organization_id
                    AND   i.inventory_item_id = ci.component_item_id)
            AND cb.organization_id <> b.organization_id
            AND cb.common_bill_sequence_id = b.bill_sequence_id
          AND    ( (b.alternate_bom_designator IS NULL AND l.alternate_designator IS NULL)
                 OR (b.alternate_bom_designator = l.alternate_designator) )
            AND b.organization_id = p_organization
            AND b.assembly_item_id = l.assembly_item_id
            AND ci.revised_item_sequence_id = ri.revised_item_sequence_id
            AND ri.change_notice = p_change_order
            AND ri.organization_id = p_organization);

    COMMIT;
    x_error_buffer := NULL;
    select count(*) into l_bom_lists_count from bom_lists where sequence_id = p_list_id;
    FND_FILE.PUT_LINE(FND_FILE.LOG,'  Records in BOM_LISTS after delete stmt in Check_Component ='||
                                    to_char(l_bom_lists_count));
EXCEPTION
    WHEN l_subroutine_error THEN
        x_error_buffer := l_internal_error;
    WHEN others THEN
        ROLLBACK TO begin_check;
        x_error_buffer := SUBSTRB(sqlerrm, 1, 150);
END Check_Component;

--------------------------------- Procedure -------------------------------
--
--  NAME
--      Restrict_List
--  DESCRIPTION
--        Deletes from BOM_LISTS according to access permissions granted by the
--        profile options: planning item access, standard item access
--        and model item access.  Also culls out bills that would not
--        qualify for a change order because it does not have
--        components which match all the criteria specified in
--        BOM_INVENTORY_COMPS_INTERFACE.
--  REQUIRES
--        Model Item Access - Yes (1) or No (2).
--        Planning Item Access - Yes (1) or No (2).
--        Standard Item Access - Yes (1) or No (2).
--        List id - A sequence id used to identify the list in BOM_LISTS.  This
--        may either be a session id or a number obtained from the
--        database sequence, BOM_LISTS_S.
--      Organization Id - Organization stored in ENG_CHANGES_INTERFACE.
--  MODIFIES
--        Error message.  If no error, returns NULL.
--  RETURNS
--
--  NOTES
--        Intended to be called from mass_update.
--  EXAMPLE
--
PROCEDURE Restrict_List(
    p_list_id              IN  NUMBER,
    p_model_item_access    IN  NUMBER,
    p_planning_item_access IN  NUMBER,
    p_standard_item_access IN  NUMBER,
    p_change_order         IN  VARCHAR2,
    p_organization         IN  NUMBER,
    x_error_message        IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS

    l_internal_error       EXCEPTION;
    l_subroutine_error_msg VARCHAR2(150);

BEGIN

    SAVEPOINT begin_deletes;

--
--  Eliminate common bills
--
    DELETE FROM bom_lists l
    WHERE l.sequence_id = p_list_id
    AND EXISTS (
            SELECT NULL
            FROM   bom_bill_of_materials b
            WHERE  b.common_bill_sequence_id <> b.bill_sequence_id
          AND    ( (b.alternate_bom_designator IS NULL AND l.alternate_designator IS NULL)
                 OR (b.alternate_bom_designator = l.alternate_designator) )
            AND    b.organization_id = p_organization
            AND    b.assembly_item_id = l.assembly_item_id);

--
--  Eliminate Packaging BOMs
--
    DELETE FROM bom_lists l
    WHERE l.sequence_id = p_list_id
    AND EXISTS (
            SELECT NULL
            FROM   bom_bill_of_materials b
            WHERE  b.assembly_item_id = l.assembly_item_id
            AND    b.organization_id = p_organization
          AND    ( (b.alternate_bom_designator IS NULL AND l.alternate_designator IS NULL)
                 OR (b.alternate_bom_designator = l.alternate_designator) )
            AND    b.structure_type_id IN
                (SELECT Structure_Type_Id FROM Bom_Structure_Types_B
                    WHERE Structure_Type_Name= Bom_Globals.G_PKG_ST_TYPE_NAME
                )
            );

--
--  Eliminate Product Families
--
    DELETE FROM bom_lists l
    WHERE l.sequence_id = p_list_id
    AND EXISTS (
            SELECT NULL
            FROM   mtl_system_items_b msi
            WHERE  msi.inventory_item_id = l.assembly_item_id
            AND    msi.organization_id = p_organization
            AND    msi.bom_item_type = 5
            );

--
--  Check profile values for item access
--
    DELETE FROM bom_lists l
    WHERE  l.sequence_id = p_list_id
    AND EXISTS (
            SELECT NULL
            FROM   mtl_system_items_b i
            WHERE    i.inventory_item_id = l.assembly_item_id
            AND      i.organization_id = p_organization
            AND ((i.bom_item_type = DECODE(p_model_item_access,
                                           no, model_type))
                 OR
                 (i.bom_item_type = DECODE(p_model_item_access,
                                           no, option_class_type))
                 OR
                 (i.bom_item_type = DECODE(p_planning_item_access,
                                           no, planning_type))
                 OR
                 (i.bom_item_type = DECODE(p_standard_item_access,
                                           no, standard_type))
                )
        );

--
--  Check item type
--
    DELETE FROM bom_lists l
    WHERE  l.sequence_id = p_list_id
    AND EXISTS (
            SELECT NULL
            FROM   eng_revised_items_interface r,
                   mtl_system_items_b i
            WHERE r.item_type <> NVL(i.item_type, 'NONE')
            AND   i.organization_id = p_organization
            AND   i.inventory_item_id = l.assembly_item_id
            AND   r.change_notice = p_change_order
            AND   r.organization_id = p_organization);

--
--  Check if configuration bills are specified
--
    DELETE FROM bom_lists l
    WHERE  l.sequence_id = p_list_id
    AND EXISTS (
            SELECT NULL
            FROM   eng_revised_items_interface r,
                   mtl_system_items_b i
            WHERE r.base_item_id <> NVL(i.base_item_id, -1)
            AND   i.organization_id = r.organization_id
            AND   i.inventory_item_id = l.assembly_item_id
            AND   r.change_notice = p_change_order
            AND   r.organization_id = p_organization);

-- delete from bom_lists those records that have Invalid or Obsolete item status codes
  DELETE FROM bom_lists l
  WHERE l.sequence_id = p_list_id
  AND EXISTS (SELECT NULL
              FROM   eng_revised_items_interface r,
                   mtl_system_items_b i,
                   bom_parameters bp
            WHERE (i.inventory_item_status_code in ('Obsolete','Inactive')
                  OR i.inventory_item_status_code = nvl(bp.bom_delete_status_code, FND_API.G_MISS_CHAR)
                  OR i.bom_enabled_flag = 'N' )-- Modified for bug 13362684
            AND   i.organization_id = bp.organization_id -- Added for bug 13362684
            AND   i.organization_id = r.organization_id
            AND   i.inventory_item_id = l.assembly_item_id
            AND   r.change_notice = p_change_order
            AND   r.organization_id = p_organization);


/* removed, as this comment mentions
--
--  Check unit effectivity. This code may have to be removed/changed in
--  the future once we start supporting unit effectivity for mass change.
--
    DELETE FROM bom_lists l
    WHERE  l.sequence_id = p_list_id
    AND EXISTS (
        SELECT NULL
        FROM  mtl_system_items_b i
        WHERE i.effectivity_control <> 1
        AND   i.organization_id = p_organization
        AND   i.inventory_item_id = l.assembly_item_id);
*/

    COMMIT;
    Check_Component(p_list_id, p_change_order, p_organization, l_subroutine_error_msg);
    IF l_subroutine_error_msg IS NOT NULL THEN
        RAISE l_internal_error;
    END IF;
    x_error_message := NULL;
    select count(*) into l_bom_lists_count from bom_lists where sequence_id = p_list_id;
    FND_FILE.PUT_LINE(FND_FILE.LOG,'  Records in BOM_LISTS after delete stmt in Restrict_List='||
                                    to_char(l_bom_lists_count));
EXCEPTION
    WHEN l_internal_error THEN
        x_error_message := l_subroutine_error_msg;
    WHEN others THEN
        ROLLBACK TO begin_deletes;
        x_error_message := SUBSTRB(sqlerrm, 1, 150);
END Restrict_List;

----------------------------- Function ---------------------------------
--
--  NAME
--      Get_Item_Name
--  DESCRIPTION
--      Given an item id and org_id, returns the item name
--  REQUIRES
--      Item_Id - Id of Inventory Item
--      Org Id  - Organization id of Item
--  MODIFIES
--
--  RETURNS
--      VARCHAR2
--  NOTES
--
--  EXAMPLE
--
FUNCTION Get_Item_Name(
    p_item_id IN mtl_system_items_vl.inventory_item_id%TYPE,
    p_org_id  IN mtl_system_items_vl.organization_id%TYPE)
RETURN mtl_system_items_vl.concatenated_segments%TYPE
IS

    CURSOR c_item_name IS
        SELECT msi.concatenated_segments
        FROM   mtl_system_items_vl msi
        WHERE  msi.inventory_item_id = p_item_id
        AND    msi.organization_id = p_org_id;

  l_item_name mtl_system_items_vl.concatenated_segments%TYPE;

BEGIN
    IF (p_item_id IS NOT NULL) THEN
        OPEN c_item_name;
        FETCH c_item_name
         INTO l_item_name;
        CLOSE c_item_name;
    ELSE
        l_item_name := NULL;
    END IF;

    RETURN l_item_name;
END Get_Item_Name;

----------------------------- Function ---------------------------------
--
--  NAME
--      Get_Location_Name
--  DESCRIPTION
--      Given a Supply Locator id, returns the location name
--  REQUIRES
--      Supply_Locator_Id - Id of Location
--  MODIFIES
--
--  RETURNS
--      VARCHAR2
--  NOTES
--
--  EXAMPLE
--
FUNCTION Get_Location_Name(
    p_supply_locator_id IN mtl_item_locations.inventory_location_id%TYPE)
RETURN mtl_item_locations_kfv.CONCATENATED_SEGMENTS%TYPE
IS

    CURSOR c_location_name IS
        SELECT CONCATENATED_SEGMENTS
        FROM   mtl_item_locations_kfv
        WHERE  inventory_location_id = p_supply_locator_id;

    l_location_name mtl_item_locations_kfv.CONCATENATED_SEGMENTS%TYPE;

BEGIN

    IF (p_supply_locator_id IS NOT NULL) THEN
        OPEN c_location_name;
        FETCH c_location_name
         INTO l_location_name;
        CLOSE c_location_name;
    ELSE
        l_location_name := NULL;
    END IF;
    RETURN l_location_name;
END Get_Location_Name;

----------------------------- Procedure ---------------------------------
--
--  NAME
--      mass_update
--  DESCRIPTION
--      Creates Mass Changes to Engineering Change Orders
--  REQUIRES
--      List Id      - Id of Bom_List of Bills of Materials to update
--      Change_Order - the name of the Change Order
--      Org_Id       - Organization id of Bill
--      Delete_Mco   - yes/no to delete Change Order when done processing
--  MODIFIES
--
--  RETURNS
--        Error_Message.  If no error, returns NULL.
--  NOTES
--
--  EXAMPLE
--
PROCEDURE mass_update(list_id       IN  NUMBER,
                      profile       IN  ProgramInfoStruct,
                      change_order  IN  VARCHAR2,
                      org_id        IN  NUMBER,
                      delete_mco    IN  NUMBER,
                      error_message IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2) IS

-- ERES change begins :
l_eres_enabled   VARCHAR2(10);
-- ERES change ends

-- Bug 1807268
--   Changed the following cursor for performance issue
--   Remove NVL from alternate designator.
--   Also added condition l.organization_id = p_org_id
--   This is done to avoid FULL Table scan on Bom_bill_of_materials Table
--   and thus reduce the Cost
--
    CURSOR c_get_bom_list(p_list_id IN bom_lists.sequence_id%TYPE,
                          p_org_id  IN bom_lists.organization_id%TYPE) IS
        SELECT l.assembly_item_id,
               l.alternate_designator,
               b.bill_sequence_id,
               itm.effectivity_control,
               ri.new_item_revision,
               ri.scheduled_date,
               ri.mrp_active,
               ri.update_wip,
               ri.use_up,
               ri.use_up_item_id,
               ri.revised_item_sequence_id,
               ri.increment_rev,
               ri.use_up_plan_name,
               ri.from_end_item_unit_number
        FROM   bom_lists l,
               eng_revised_items_interface ri,
               bom_bill_of_materials b,
               mtl_system_items_b itm
        WHERE
              ((l.alternate_designator IS NULL
                AND b.alternate_bom_designator IS NULL)
                OR b.alternate_bom_designator = l.alternate_designator)
        AND    b.organization_id = p_org_id
        AND    b.assembly_item_id = l.assembly_item_id
        AND    l.sequence_id = p_list_id
        AND    l.organization_id = p_org_id
        AND    ri.change_notice = change_order
        AND    ri.organization_id = p_org_id
        AND    itm.inventory_item_id = l.assembly_item_id
        AND    itm.organization_id = p_org_id
        AND    ((itm.effectivity_control = unit_control
             AND ri.from_end_item_unit_number IS NOT NULL)
             OR
               (itm.effectivity_control = date_control
             AND ri.scheduled_date IS NOT NULL));

--
--  Change Order
--
    CURSOR c_eco_rec IS
        SELECT i.description,
               i.change_order_type_id,
               i.responsible_organization_id,
               i.cancellation_comments,
               i.priority_code,
               i.reason_code,
               i.estimated_eng_cost,
               i.estimated_mfg_cost,
               i.approval_list_name
        FROM   eng_eng_changes_interface i
        WHERE  i.change_notice = change_order
        AND    i.organization_id = org_id;

--
--  Component deletes.
--
    CURSOR c_comp_delete(
        x_scheduled_date   bom_inventory_components.effectivity_date%TYPE,
        x_bill_sequence_id bom_inventory_components.bill_sequence_id%TYPE,
        x_from_unit_number eng_revised_items_interface.from_end_item_unit_number%TYPE)
    IS
        SELECT  /*+ NO_EXPAND */ NVL(o.operation_seq_num,
                    c.operation_seq_num)          operation_sequence_number,
                o.component_item_id,
                NVL(o.item_num,
                    c.item_num)                   item_num,
                NVL(o.basis_type,
                    c.basis_type)             basis_type,
                NVL(o.component_quantity,
                    c.component_quantity)         component_quantity,
                NVL(o.component_yield_factor,
                    c.component_yield_factor)     component_yield_factor,
                c.effectivity_date                old_effectivity_date,
                NVL(o.planning_factor,
                    c.planning_factor)            planning_factor,
                NVL(o.quantity_related,
                    c.quantity_related)           quantity_related,
                NVL(o.so_basis,
                    c.so_basis)                   so_basis,
                NVL(o.optional,
                    c.optional)                   optional,
                NVL(o.mutually_exclusive_options,
                    c.mutually_exclusive_options) mutually_exclusive_options,
                NVL(o.include_in_cost_rollup,
                    c.include_in_cost_rollup)     include_in_cost_rollup,
                NVL(o.check_atp,
                    c.check_atp)                  check_atp,
                NVL(o.shipping_allowed,
                    c.shipping_allowed)           shipping_allowed,
                NVL(o.required_to_ship,
                    c.required_to_ship)           required_to_ship,
                NVL(o.required_for_revenue,
                    c.required_for_revenue)       required_for_revenue,
                NVL(o.include_on_ship_docs,
                    c.include_on_ship_docs)       include_on_ship_docs,
                NVL(o.low_quantity,
                    c.low_quantity)               low_quantity,
                NVL(o.high_quantity,
                    c.high_quantity)              high_quantity,
                ecg_action_delete                 acd_type,
                c.component_sequence_id           old_component_sequence_id,
                NVL(o.wip_supply_type,
                    c.wip_supply_type)            wip_supply_type,
                NVL(o.supply_subinventory,
                    c.supply_subinventory)        supply_subinventory,
                NVL(o.supply_locator_id,
                    c.supply_locator_id)          supply_locator_id,
                c.from_end_item_unit_number       old_from_end_item_unit_number,
                ci_itm.bom_item_type,
                ri.from_end_item_unit_number,
                o.to_end_item_unit_number,
    Nvl(o.component_remarks,c.component_remarks)
              component_remarks       --Bug 3347094
        FROM    mtl_system_items_b ci_itm,
                mtl_system_items_b ri_itm,
                bom_bill_of_materials b,
                bom_inventory_components c,
                bom_inventory_comps_interface o,
                eng_revised_items_interface ri
        WHERE   (c.item_num = o.item_num OR o.item_num IS NULL)
        AND     (Nvl(c.basis_type,4) = Decode(o.basis_type,FND_API.G_MISS_NUM,4,o.basis_type) OR o.basis_type is NULL) -- 5214239
        AND     (c.component_quantity = o.component_quantity OR
                 o.component_quantity IS NULL)
        AND     (c.component_yield_factor = o.component_yield_factor OR
                 o.component_yield_factor IS NULL)
        AND     (c.planning_factor = o.planning_factor OR
                 o.planning_factor IS NULL)
        AND     (c.quantity_related = o.quantity_related OR
                 o.quantity_related IS NULL)
        AND     (c.so_basis = o.so_basis OR o.so_basis IS NULL)
        AND     (c.optional = o.optional OR o.optional IS NULL)
        AND     (c.mutually_exclusive_options = o.mutually_exclusive_options OR
                 o.mutually_exclusive_options IS NULL)
        AND     (c.include_in_cost_rollup = o.include_in_cost_rollup OR
                 o.include_in_cost_rollup IS NULL)
        AND     (c.check_atp = o.check_atp OR o.check_atp IS NULL)
        AND     (c.shipping_allowed = o.shipping_allowed OR
                 o.shipping_allowed IS NULL)
        AND     (c.required_to_ship = o.required_to_ship OR
                 o.required_to_ship IS NULL)
        AND     (c.required_for_revenue = o.required_for_revenue OR
                 o.required_for_revenue IS NULL)
        AND     (c.include_on_ship_docs = o.include_on_ship_docs OR
                 o.include_on_ship_docs IS NULL)
        AND     (c.low_quantity = o.low_quantity OR o.low_quantity IS NULL)
        AND     (c.high_quantity = o.high_quantity OR o.high_quantity IS NULL)
        AND     (c.wip_supply_type = o.wip_supply_type OR
                 o.wip_supply_type IS NULL)
        AND     (c.supply_subinventory = o.supply_subinventory OR
                 o.supply_subinventory IS NULL)
        AND     (c.supply_locator_id = o.supply_locator_id OR
                 o.supply_locator_id IS NULL)
        AND     (c.component_remarks = o.component_remarks OR
                 o.component_remarks IS NULL)
        AND     (c.attribute_category = o.attribute_category OR
                 o.attribute_category IS NULL)
        AND     (c.attribute1 = o.attribute1 OR o.attribute1 IS NULL)
        AND     (c.attribute2 = o.attribute2 OR o.attribute2 IS NULL)
        AND     (c.attribute3 = o.attribute3 OR o.attribute3 IS NULL)
        AND     (c.attribute4 = o.attribute4 OR o.attribute4 IS NULL)
        AND     (c.attribute5 = o.attribute5 OR o.attribute5 IS NULL)
        AND     (c.attribute6 = o.attribute6 OR o.attribute6 IS NULL)
        AND     (c.attribute7 = o.attribute7 OR o.attribute7 IS NULL)
        AND     (c.attribute8 = o.attribute8 OR o.attribute8 IS NULL)
        AND     (c.attribute9 = o.attribute9 OR o.attribute9 IS NULL)
        AND     (c.attribute10 = o.attribute10 OR o.attribute10 IS NULL)
        AND     (c.attribute11 = o.attribute11 OR o.attribute11 IS NULL)
        AND     (c.attribute12 = o.attribute12 OR o.attribute12 IS NULL)
        AND     (c.attribute13 = o.attribute13 OR o.attribute13 IS NULL)
        AND     (c.attribute14 = o.attribute14 OR o.attribute14 IS NULL)
        AND     (c.attribute15 = o.attribute15 OR o.attribute15 IS NULL)
        AND     c.operation_seq_num = NVL(o.operation_seq_num,
                                          c.operation_seq_num)
        AND     c.bill_sequence_id = x_bill_sequence_id
        AND     c.component_item_id = o.component_item_id
        AND     ci_itm.inventory_item_id = c.component_item_id
        AND     ci_itm.organization_id = org_id
        AND     o.acd_type = action_delete
        AND     o.revised_item_sequence_id = ri.revised_item_sequence_id
        AND     ri.change_notice = change_order
        AND     ri.organization_id = org_id
        AND     b.bill_sequence_id = c.bill_sequence_id
        AND     ri_itm.inventory_item_id = b.assembly_item_id
        AND     ri_itm.organization_id = org_id
  /*  Check for implemenation date is done to avoid mass changes from including
    unimplemented components in the mass changes list*/
  AND   c.implementation_date IS NOT NULL
        AND     NVL(TRUNC(c.disable_date), NVL(x_scheduled_date,TRUNC(SYSDATE)) + 1) >
                NVL(x_scheduled_date,TRUNC(SYSDATE))
        AND     TRUNC(c.effectivity_date) <= NVL(x_scheduled_date,TRUNC(SYSDATE))

        AND  ((NVL(c.to_end_item_unit_number, x_from_unit_number) >=
               x_from_unit_number
           AND c.from_end_item_unit_number <= x_from_unit_number
           AND ri_itm.effectivity_control = unit_control)
              OR
             ri_itm.effectivity_control = date_control);

--
--  Disable component changes, if action_type =action_replace
--   and New component_item_id != old row's component_item_id
--  Included mass replace of components.
    CURSOR c_comp_replace (
        x_scheduled_date   bom_inventory_components.effectivity_date%TYPE,
        x_bill_sequence_id bom_inventory_components.bill_sequence_id%TYPE,
        x_from_unit_number eng_revised_items_interface.from_end_item_unit_number%TYPE)
    IS
        SELECT  NVL(o.operation_seq_num,
                    c.operation_seq_num)          operation_sequence_number,
                n.operation_seq_num               new_operation_sequence_number,
                o.component_item_id,
                NVL(o.item_num, c.item_num)       item_num,
                NVL(o.basis_type, c.basis_type)       basis_type,
                NVL(o.component_quantity,
                    c.component_quantity)         component_quantity,
                NVL(o.component_yield_factor,
                    c.component_yield_factor)     component_yield_factor,
                c.effectivity_date                old_effectivity_date,
                NVL(o.planning_factor,
                    c.planning_factor)            planning_factor,
                NVL(o.quantity_related,
                    c.quantity_related)           quantity_related,
                NVL(o.so_basis, c.so_basis)       so_basis,
                NVL(o.optional, c.optional)       optional,
                NVL(o.mutually_exclusive_options,
                    c.mutually_exclusive_options) mutually_exclusive_options,
                NVL(o.include_in_cost_rollup,
                    c.include_in_cost_rollup)     include_in_cost_rollup,
                NVL(o.check_atp, c.check_atp)     check_atp,
                NVL(o.shipping_allowed,
                    c.shipping_allowed)           shipping_allowed,
                NVL(o.required_to_ship,
                    c.required_to_ship)           required_to_ship,
                NVL(o.required_for_revenue,
                    c.required_for_revenue)       required_for_revenue,
                NVL(o.include_on_ship_docs,
                    c.include_on_ship_docs)       include_on_ship_docs,
                NVL(o.low_quantity,
                    c.low_quantity)               low_quantity,
                NVL(o.high_quantity,
                    c.high_quantity)              high_quantity,
                ecg_action_delete                 acd_type,
                c.component_sequence_id           old_component_sequence_id,
                NVL(o.wip_supply_type,
                    c.wip_supply_type)            wip_supply_type,
                NVL(o.supply_subinventory,
                    c.supply_subinventory)        supply_subinventory,
                NVL(o.supply_locator_id,
                    c.supply_locator_id)          supply_locator_id,
                c.from_end_item_unit_number       old_from_end_item_unit_number,
                ci_itm.bom_item_type,
                ri.from_end_item_unit_number,
                NVL(o.to_end_item_unit_number, c.to_end_item_unit_number) to_end_item_unit_number,
    Nvl(o.component_remarks,c.component_remarks)
              component_remarks       --Bug 3347094
        FROM    mtl_system_items_b            ci_itm,
                mtl_system_items_b            ri_itm,
                bom_bill_of_materials         b,
                bom_inventory_components      c,
                bom_inventory_comps_interface n,  -- new attributes
                bom_inventory_comps_interface o,  -- old attributes
                eng_revised_items_interface   ri
        WHERE   n.old_component_sequence_id = o.component_sequence_id
        AND     (n.component_item_id <> o.component_item_id)
        AND     (c.item_num = o.item_num OR o.item_num IS NULL)
        AND     (Nvl(c.basis_type,4) = Decode(o.basis_type,FND_API.G_MISS_NUM,4,o.basis_type) OR o.basis_type IS NULL) -- 5214239
        AND     (c.component_quantity = o.component_quantity OR
                 o.component_quantity IS NULL)
        AND     (c.component_yield_factor = o.component_yield_factor OR
                 o.component_yield_factor IS NULL)
        AND     (c.component_remarks = o.component_remarks OR
                 o.component_remarks IS NULL)
        AND     (c.attribute_category = o.attribute_category OR
                 o.attribute_category IS NULL)
        AND     (c.attribute1 = o.attribute1 OR o.attribute1 IS NULL)
        AND     (c.attribute2 = o.attribute2 OR o.attribute2 IS NULL)
        AND     (c.attribute3 = o.attribute3 OR o.attribute3 IS NULL)
        AND     (c.attribute4 = o.attribute4 OR o.attribute4 IS NULL)
        AND     (c.attribute5 = o.attribute5 OR o.attribute5 IS NULL)
        AND     (c.attribute6 = o.attribute6 OR o.attribute6 IS NULL)
        AND     (c.attribute7 = o.attribute7 OR o.attribute7 IS NULL)
        AND     (c.attribute8 = o.attribute8 OR o.attribute8 IS NULL)
        AND     (c.attribute9 = o.attribute9 OR o.attribute9 IS NULL)
        AND     (c.attribute10 = o.attribute10 OR o.attribute10 IS NULL)
        AND     (c.attribute11 = o.attribute11 OR o.attribute11 IS NULL)
        AND     (c.attribute12 = o.attribute12 OR o.attribute12 IS NULL)
        AND     (c.attribute13 = o.attribute13 OR o.attribute13 IS NULL)
        AND     (c.attribute14 = o.attribute14 OR o.attribute14 IS NULL)
        AND     (c.attribute15 = o.attribute15 OR o.attribute15 IS NULL)
        AND     (c.planning_factor = o.planning_factor OR
                 o.planning_factor IS NULL)
        AND     (c.quantity_related = o.quantity_related OR
                 o.quantity_related IS NULL)
        AND     (c.so_basis = o.so_basis OR o.so_basis IS NULL)
        AND     (c.optional = o.optional OR o.optional IS NULL)
        AND     (c.mutually_exclusive_options = o.mutually_exclusive_options OR
                 o.mutually_exclusive_options IS NULL)
        AND     (c.include_in_cost_rollup = o.include_in_cost_rollup OR
                 o.include_in_cost_rollup IS NULL)
        AND     (c.check_atp = o.check_atp OR o.check_atp IS NULL)
        AND     (c.shipping_allowed = o.shipping_allowed OR
                 o.shipping_allowed IS NULL)
        AND     (c.required_to_ship = o.required_to_ship OR
                 o.required_to_ship IS NULL)
        AND     (c.required_for_revenue = o.required_for_revenue OR
                 o.required_for_revenue IS NULL)
        AND     (c.include_on_ship_docs = o.include_on_ship_docs OR
                 o.include_on_ship_docs IS NULL)
        AND     (c.low_quantity = o.low_quantity OR o.low_quantity IS NULL)
        AND     (c.high_quantity = o.high_quantity OR o.high_quantity IS NULL)
        AND     (c.wip_supply_type = o.wip_supply_type OR
                 o.wip_supply_type IS NULL)
        AND     (c.supply_subinventory = o.supply_subinventory OR
                 o.supply_subinventory IS NULL)
        AND     (c.supply_locator_id = o.supply_locator_id OR
                 o.supply_locator_id IS NULL)
        AND     c.operation_seq_num = NVL(o.operation_seq_num,
                                          c.operation_seq_num)
        AND     c.bill_sequence_id = x_bill_sequence_id
        AND     c.component_item_id = o.component_item_id
        AND     o.acd_type = action_replace
        AND     o.revised_item_sequence_id = ri.revised_item_sequence_id
        AND     ci_itm.inventory_item_id = c.component_item_id
        AND     ci_itm.organization_id = org_id
        AND     ri.change_notice = change_order
        AND     ri.organization_id = org_id
        AND     b.bill_sequence_id = c.bill_sequence_id
        AND     ri_itm.inventory_item_id = b.assembly_item_id
        AND     ri_itm.organization_id = org_id
  /*  Check for implemenation date is done to avoid mass changes from including
    unimplemented components in the mass changes list*/
  AND   c.implementation_date IS NOT NULL
        AND     NVL(TRUNC(c.disable_date), NVL(x_scheduled_date,TRUNC(SYSDATE)) + 1) >
                NVL(x_scheduled_date,TRUNC(SYSDATE))
        AND     TRUNC(c.effectivity_date) <= NVL(x_scheduled_date,TRUNC(SYSDATE))

        AND  ((NVL(c.to_end_item_unit_number, x_from_unit_number) >=
               x_from_unit_number
           AND c.from_end_item_unit_number <= x_from_unit_number
           AND ri_itm.effectivity_control = unit_control)
              OR
             ri_itm.effectivity_control = date_control);

--  Insert component changes.
--  Bug 568258:  If replacement values for Supply Type, Subinventory or
--  Locator is null and corresponding search criteria is not null, update
--  component's attributes to null
--
    CURSOR c_comp_change (
        x_scheduled_date   bom_inventory_components.effectivity_date%TYPE,
        x_bill_sequence_id bom_inventory_components.bill_sequence_id%TYPE,
        x_from_unit_number eng_revised_items_interface.from_end_item_unit_number%TYPE)
    IS
        SELECT  NVL(o.operation_seq_num,
                    c.operation_seq_num)             old_operation_sequence_number,
                n.operation_seq_num                  new_operation_sequence_number,
                c.operation_seq_num                  operation_sequence_number,
                n.component_item_id,
                NVL(n.item_num, c.item_num)          item_num,
                NVL(n.basis_type , c.basis_type )          basis_type,
                NVL(n.component_quantity,
                    c.component_quantity)            component_quantity,
                NVL(n.component_yield_factor,
                    c.component_yield_factor)        component_yield_factor,
                DECODE(n.component_item_id,
                       o.component_item_id,
                       NVL(x_scheduled_date,TRUNC(SYSDATE)),
                       NULL)                         new_effectivity_date,
                DECODE(n.component_item_id,
                       o.component_item_id,
                       GREATEST(NVL(x_scheduled_date,
                                    TRUNC(SYSDATE)),
                                n.disable_date),
                       NULL)                         disable_date,
                NVL(n.component_remarks,
                    c.component_remarks)             component_remarks,
                DECODE(n.component_item_id,
                       o.component_item_id,
                       c.effectivity_date,
                       NULL)                         old_effectivity_date,
                NVL(n.planning_factor,
                    c.planning_factor)               planning_factor,
                NVL(n.quantity_related,
                    c.quantity_related)              quantity_related,
                NVL(n.so_basis, c.so_basis)          so_basis,
                NVL(n.optional, c.optional)          optional,
                NVL(n.mutually_exclusive_options,
                    c.mutually_exclusive_options)    mutually_exclusive_options,
                NVL(n.include_in_cost_rollup,
                    c.include_in_cost_rollup)        include_in_cost_rollup,
                NVL(n.check_atp, c.check_atp)        check_atp,
                NVL(n.shipping_allowed,
                    c.shipping_allowed)              shipping_allowed,
                NVL(n.required_to_ship,
                    c.required_to_ship)              required_to_ship,
                NVL(n.required_for_revenue,
                    c.required_for_revenue)          required_for_revenue,
                NVL(n.include_on_ship_docs,
                    c.include_on_ship_docs)          include_on_ship_docs,
                NVL(n.low_quantity, c.low_quantity)  low_quantity,
                NVL(n.high_quantity,
                    c.high_quantity)                 high_quantity,
                DECODE(n.component_item_id,
                       o.component_item_id,
                       ecg_action_change,
                       ecg_action_add)               acd_type,
                NVL(n.wip_supply_type,
                    DECODE(o.wip_supply_type, NULL,
                           c.wip_supply_type, FND_API.G_MISS_NUM)) wip_supply_type, /* bug fix : 9019348 */
                NVL(n.supply_subinventory,
                    DECODE(o.supply_subinventory,
                           NULL,
                           c.supply_subinventory,
                           FND_API.G_MISS_CHAR))                    supply_subinventory,
                NVL(n.supply_locator_id,
                    DECODE(o.supply_locator_id,
                           NULL,
                           c.supply_locator_id,
                           FND_API.G_MISS_NUM))                    supply_locator_id,
                DECODE(n.component_item_id,
                       o.component_item_id,
                       c.from_end_item_unit_number,
                       NULL)                         old_from_end_item_unit_number,
                ci_itm.bom_item_type,
                ri.from_end_item_unit_number,
                DECODE(n.component_item_id,
                       o.component_item_id,
                       GREATEST(x_from_unit_number,
                                NVL(n.to_end_item_unit_number, c.to_end_item_unit_number)),
                       NULL)                         to_end_item_unit_number,

    -- added attribute information to resolve BUG# 2784395
                    NVL(n.attribute_category, c.attribute_category)   attribute_category ,
                    NVL(n.attribute1, c.attribute1)                   attribute1 ,
                    NVL(n.attribute2, c.attribute2)                   attribute2 ,
                    NVL(n.attribute3, c.attribute3)                   attribute3 ,
                    NVL(n.attribute4, c.attribute4)                   attribute4 ,
                    NVL(n.attribute5, c.attribute5)                   attribute5 ,
                    NVL(n.attribute6, c.attribute6)                   attribute6 ,
                    NVL(n.attribute7, c.attribute7)                   attribute7 ,
                    NVL(n.attribute8, c.attribute8)                   attribute8 ,
                    NVL(n.attribute9, c.attribute9)                   attribute9 ,
                    NVL(n.attribute10, c.attribute10)                 attribute10,
                    NVL(n.attribute11, c.attribute11)                 attribute11,
                    NVL(n.attribute12, c.attribute12)                 attribute12,
                    NVL(n.attribute13, c.attribute13)                 attribute13,
                    NVL(n.attribute14, c.attribute14)                 attribute14,
                    NVL(n.attribute15, c.attribute15)                 attribute15
    -- added attribute information to resolve BUG# 2784395

        FROM    mtl_system_items_b            ci_itm,
                mtl_system_items_b            ri_itm,
                bom_bill_of_materials         b,
                bom_inventory_components      c,
                bom_inventory_comps_interface n,  -- new attributes
                bom_inventory_comps_interface o,  -- old attributes
                eng_revised_items_interface   ri
        WHERE   n.old_component_sequence_id = o.component_sequence_id
        AND     (c.item_num = o.item_num OR o.item_num IS NULL)
         AND     (Nvl(c.basis_type,4) = Decode(o.basis_type,FND_API.G_MISS_NUM,4,o.basis_type) OR o.basis_type is NULL) -- 5214239
        AND     (c.component_quantity = o.component_quantity OR
                 o.component_quantity IS NULL)
        AND     (c.component_yield_factor = o.component_yield_factor OR
                 o.component_yield_factor IS NULL)
        AND     (c.component_remarks = o.component_remarks OR
                 o.component_remarks IS NULL)
        AND     (c.attribute_category = o.attribute_category OR
                 o.attribute_category IS NULL)
        AND     (c.attribute1 = o.attribute1 OR o.attribute1 IS NULL)
        AND     (c.attribute2 = o.attribute2 OR o.attribute2 IS NULL)
        AND     (c.attribute3 = o.attribute3 OR o.attribute3 IS NULL)
        AND     (c.attribute4 = o.attribute4 OR o.attribute4 IS NULL)
        AND     (c.attribute5 = o.attribute5 OR o.attribute5 IS NULL)
        AND     (c.attribute6 = o.attribute6 OR o.attribute6 IS NULL)
        AND     (c.attribute7 = o.attribute7 OR o.attribute7 IS NULL)
        AND     (c.attribute8 = o.attribute8 OR o.attribute8 IS NULL)
        AND     (c.attribute9 = o.attribute9 OR o.attribute9 IS NULL)
        AND     (c.attribute10 = o.attribute10 OR o.attribute10 IS NULL)
        AND     (c.attribute11 = o.attribute11 OR o.attribute11 IS NULL)
        AND     (c.attribute12 = o.attribute12 OR o.attribute12 IS NULL)
        AND     (c.attribute13 = o.attribute13 OR o.attribute13 IS NULL)
        AND     (c.attribute14 = o.attribute14 OR o.attribute14 IS NULL)
        AND     (c.attribute15 = o.attribute15 OR o.attribute15 IS NULL)
        AND     (c.planning_factor = o.planning_factor OR
                 o.planning_factor IS NULL)
        AND     (c.quantity_related = o.quantity_related OR
                 o.quantity_related IS NULL)
        AND     (c.so_basis = o.so_basis OR o.so_basis IS NULL)
        AND     (c.optional = o.optional OR o.optional IS NULL)
        AND     (c.mutually_exclusive_options = o.mutually_exclusive_options OR
                 o.mutually_exclusive_options IS NULL)
        AND     (c.include_in_cost_rollup = o.include_in_cost_rollup OR
                 o.include_in_cost_rollup IS NULL)
        AND     (c.check_atp = o.check_atp OR o.check_atp IS NULL)
        AND     (c.shipping_allowed = o.shipping_allowed OR
                 o.shipping_allowed IS NULL)
        AND     (c.required_to_ship = o.required_to_ship OR
                 o.required_to_ship IS NULL)
        AND     (c.required_for_revenue = o.required_for_revenue OR
                 o.required_for_revenue IS NULL)
        AND     (c.include_on_ship_docs = o.include_on_ship_docs OR
                 o.include_on_ship_docs IS NULL)
        AND     (c.low_quantity = o.low_quantity OR o.low_quantity IS NULL)
        AND     (c.high_quantity = o.high_quantity OR o.high_quantity IS NULL)
        AND     (c.wip_supply_type = o.wip_supply_type OR
                 o.wip_supply_type IS NULL)
        AND     (c.supply_subinventory = o.supply_subinventory OR
                 o.supply_subinventory IS NULL)
        AND     (c.supply_locator_id = o.supply_locator_id OR
                 o.supply_locator_id IS NULL)
        AND     c.operation_seq_num = NVL(o.operation_seq_num,
                                          c.operation_seq_num)
        AND     c.bill_sequence_id = x_bill_sequence_id
        AND     c.component_item_id = o.component_item_id
        AND     o.acd_type = action_replace
        AND     o.revised_item_sequence_id = ri.revised_item_sequence_id
        AND     ci_itm.inventory_item_id = c.component_item_id
        AND     ci_itm.organization_id = org_id
        AND     ri.change_notice = change_order
        AND     ri.organization_id = org_id
        AND     b.bill_sequence_id = c.bill_sequence_id
        AND     ri_itm.inventory_item_id = b.assembly_item_id
        AND     ri_itm.organization_id = org_id
  /*  Check for implemenation date is done to avoid mass changes from including
    unimplemented components in the mass changes list*/
  AND   c.implementation_date IS NOT NULL
        AND     NVL(TRUNC(c.disable_date), NVL(x_scheduled_date,TRUNC(SYSDATE)) + 1) >
                NVL(x_scheduled_date,TRUNC(SYSDATE))
        AND     TRUNC(c.effectivity_date) <= NVL(x_scheduled_date,TRUNC(SYSDATE))

        AND  ((NVL(c.to_end_item_unit_number, x_from_unit_number) >=
               x_from_unit_number
           AND c.from_end_item_unit_number <= x_from_unit_number
           AND ri_itm.effectivity_control = unit_control)
              OR
             ri_itm.effectivity_control = date_control);

--
-- Insert component adds.  Insert defaults where mandatory columns were
-- left NULL.
--
    CURSOR c_comp_add(x_bill_sequence_id bom_inventory_components.bill_sequence_id%TYPE)
    IS
        SELECT  NVL(i.operation_seq_num,
                    default_operation_seq_num)              operation_seq_num,
                i.component_item_id,
                i.item_num,
                i.basis_type          basis_type,
                NVL(i.component_quantity,
                    default_component_quantity)             component_quantity,
                NVL(i.component_yield_factor,
                    default_component_yield_factor)         component_yield_factor,
                i.component_remarks,
                NVL(i.planning_factor,
                    default_planning_factor)                planning_factor,
                NVL(i.quantity_related,
                    default_quantity_related)               quantity_related,
                i.so_basis,
                i.optional,
                i.mutually_exclusive_options,
                NVL(i.include_in_cost_rollup,
                    default_include_in_cost_rollup)         include_in_cost_rollup,
                NVL(i.check_atp, default_check_atp)         check_atp,
                i.shipping_allowed,
                i.required_to_ship,
                i.required_for_revenue,
                i.include_on_ship_docs,
                i.low_quantity,
                i.high_quantity,
                ecg_action_add                              acd_type,
                i.wip_supply_type,
                i.supply_subinventory,
                i.supply_locator_id,
                ci_itm.bom_item_type,
                ri.from_end_item_unit_number,
                i.to_end_item_unit_number,
                GREATEST(ri.scheduled_date, i.disable_date) disable_date,
   -- added Attribute information for BUG #2784395
    i.attribute_category,
    i.attribute1,
    i.attribute2,
    i.attribute3,
    i.attribute4,
    i.attribute5,
    i.attribute6,
    i.attribute7,
    i.attribute8,
    i.attribute9,
    i.attribute10,
    i.attribute11,
    i.attribute12,
    i.attribute13,
    i.attribute14,
    i.attribute15
   -- added Attribute information for BUG #2784395
        FROM    mtl_system_items_b            ci_itm,
                mtl_system_items_b            bi_itm,
                bom_bill_of_materials         b,
                bom_inventory_comps_interface i,
                eng_revised_items_interface   ri
        WHERE   i.acd_type = action_add
        AND     ci_itm.inventory_item_id = i.component_item_id
        AND     ci_itm.organization_id = org_id
        AND     ri.revised_item_sequence_id = i.revised_item_sequence_id
        AND     ri.change_notice = change_order
        AND     ri.organization_id = org_id
        AND     b.bill_sequence_id = x_bill_sequence_id
        AND     bi_itm.inventory_item_id = b.assembly_item_id
        AND     bi_itm.organization_id = org_id

        AND     ((bi_itm.effectivity_control = date_control
              AND ci_itm.effectivity_control = date_control)
              OR
                 (bi_itm.effectivity_control = unit_control
              AND ci_itm.effectivity_control IN (date_control,unit_control)));

        /* Fix for bug 5083488 -  Added below cursor to get reference designator rows. */

   CURSOR c_add_ref_desg(
        x_bill_sequence_id bom_inventory_components.bill_sequence_id%TYPE,
        x_scheduled_date   bom_inventory_components.effectivity_date%TYPE,
        x_from_unit_number eng_revised_items_interface.from_end_item_unit_number%TYPE)
    IS
  SELECT  n.component_item_id,
                NVL(o.operation_seq_num,
                    c.operation_seq_num)            operation_sequence_number,
    brd.COMPONENT_REFERENCE_DESIGNATOR  reference_designator_name,
    --nvl(brd.acd_type,1)       acd_type,
    1		acd_type, --modified for 10039721
    brd.REF_DESIGNATOR_COMMENT      Ref_Designator_Comment,
    brd.Attribute_category,
    brd.Attribute1,
    brd.Attribute2,
                c.component_sequence_id             old_component_sequence_id,
    brd.attribute3,
    brd.attribute4,
    brd.attribute5,
    brd.attribute7,
    brd.attribute6,
    brd.attribute8,
    brd.attribute9,
    brd.attribute11,
    brd.attribute10,
    brd.attribute12,
    brd.attribute13,
    brd.attribute14,
    brd.attribute15
        FROM    bom_inventory_components      c,
                bom_inventory_comps_interface n,  -- new attributes
                bom_inventory_comps_interface o,  -- old attributes
                eng_revised_items_interface   ri,
                bom_reference_designators  brd,
                mtl_system_items_b            ri_itm,
                bom_bill_of_materials b
        WHERE   n.old_component_sequence_id = o.component_sequence_id
  AND     brd.component_sequence_id = c.component_Sequence_id
        AND     (n.component_item_id <> o.component_item_id)
        AND     (c.item_num = o.item_num OR o.item_num IS NULL)
        AND     (c.component_quantity = o.component_quantity OR
                 o.component_quantity IS NULL)
        AND     (c.component_yield_factor = o.component_yield_factor OR
                 o.component_yield_factor IS NULL)
        AND     (c.component_remarks = o.component_remarks OR
                 o.component_remarks IS NULL)
        AND     (c.attribute_category = o.attribute_category OR
                 o.attribute_category IS NULL)
  AND     (c.attribute1 = o.attribute1 OR o.attribute1 IS NULL)
        AND     (c.attribute2 = o.attribute2 OR o.attribute2 IS NULL)
        AND     (c.attribute3 = o.attribute3 OR o.attribute3 IS NULL)
        AND     (c.attribute4 = o.attribute4 OR o.attribute4 IS NULL)
        AND     (c.attribute5 = o.attribute5 OR o.attribute5 IS NULL)
        AND     (c.attribute6 = o.attribute6 OR o.attribute6 IS NULL)
        AND     (c.attribute7 = o.attribute7 OR o.attribute7 IS NULL)
        AND     (c.attribute8 = o.attribute8 OR o.attribute8 IS NULL)
        AND     (c.attribute9 = o.attribute9 OR o.attribute9 IS NULL)
        AND     (c.attribute10 = o.attribute10 OR o.attribute10 IS NULL)
        AND     (c.attribute11 = o.attribute11 OR o.attribute11 IS NULL)
        AND     (c.attribute12 = o.attribute12 OR o.attribute12 IS NULL)
        AND     (c.attribute13 = o.attribute13 OR o.attribute13 IS NULL)
        AND     (c.attribute14 = o.attribute14 OR o.attribute14 IS NULL)
        AND     (c.attribute15 = o.attribute15 OR o.attribute15 IS NULL)
        AND     (c.planning_factor = o.planning_factor OR
                 o.planning_factor IS NULL)
        AND     (c.quantity_related = o.quantity_related OR
                 o.quantity_related IS NULL)
        AND     (c.so_basis = o.so_basis OR o.so_basis IS NULL)
        AND     (c.optional = o.optional OR o.optional IS NULL)
        AND     (c.mutually_exclusive_options = o.mutually_exclusive_options OR
                 o.mutually_exclusive_options IS NULL)
        AND     (c.include_in_cost_rollup = o.include_in_cost_rollup OR
                 o.include_in_cost_rollup IS NULL)
        AND     (c.check_atp = o.check_atp OR o.check_atp IS NULL)
        AND     (c.shipping_allowed = o.shipping_allowed OR
                 o.shipping_allowed IS NULL)
        AND     (c.required_to_ship = o.required_to_ship OR
                 o.required_to_ship IS NULL)
        AND     (c.required_for_revenue = o.required_for_revenue OR
                 o.required_for_revenue IS NULL)
        AND     (c.include_on_ship_docs = o.include_on_ship_docs OR
                 o.include_on_ship_docs IS NULL)
        AND     (c.low_quantity = o.low_quantity OR o.low_quantity IS NULL)
        AND     (c.high_quantity = o.high_quantity OR o.high_quantity IS NULL)
        AND     (c.wip_supply_type = o.wip_supply_type OR
                 o.wip_supply_type IS NULL)
        AND     (c.supply_subinventory = o.supply_subinventory OR
                 o.supply_subinventory IS NULL)
  AND     (c.supply_locator_id = o.supply_locator_id OR
                 o.supply_locator_id IS NULL)
  AND     c.operation_seq_num = NVL(o.operation_seq_num,
                                          c.operation_seq_num)
        AND     c.bill_sequence_id = x_bill_sequence_id
        AND     c.component_item_id = o.component_item_id
        AND     o.acd_type = action_replace
        AND     o.revised_item_sequence_id = ri.revised_item_sequence_id
        AND     ri.change_notice = change_order
        AND     ri.organization_id = org_id
        AND     b.bill_sequence_id = x_bill_sequence_id
        AND     ri_itm.inventory_item_id = b.assembly_item_id
        AND     ri_itm.organization_id = org_id
        /*      Check for implemenation date is done to avoid mass changes from including
                unimplemented components in the mass changes list*/
        AND     c.implementation_date IS NOT NULL
        AND     NVL(TRUNC(c.disable_date), NVL(x_scheduled_date,TRUNC(SYSDATE)) + 1) >
                NVL(x_scheduled_date,TRUNC(SYSDATE))
        AND     TRUNC(c.effectivity_date) <= NVL(x_scheduled_date,TRUNC(SYSDATE))

        AND  ((NVL(c.to_end_item_unit_number, x_from_unit_number) >=
               x_from_unit_number
           AND c.from_end_item_unit_number <= x_from_unit_number
           AND ri_itm.effectivity_control = unit_control)
              OR
             ri_itm.effectivity_control = date_control)
  AND nvl(brd.acd_type,1) <> 3;


/* Bug 2614633 */

CURSOR rev_item IS
    select revised_item_id,revised_item_sequence_id,
           new_item_revision,organization_id
    from eng_revised_items
    where change_notice = change_order
     and organization_id=org_id;


    list_error         EXCEPTION;
    list_error_msg     VARCHAR2(150);
    revision_error     EXCEPTION;
    rev_error_msg      VARCHAR2(150);
    process_eco_error  EXCEPTION;
    whoami             bompinrv.ProgramInfoStruct;
    X_Statement_Number VARCHAR2(3) := '[0]';

    --The remaining declarations have been added as part of the change
    --to use the ECO Business Object
    l_eco_rec              Eng_Eco_Pub.Eco_Rec_Type;
    l_item_tbl             Eng_Eco_Pub.Revised_Item_Tbl_Type;
    l_comp_tbl             Bom_Bo_Pub.Rev_Component_Tbl_Type;
    l_error_tbl            Error_Handler.Error_Tbl_Type;
    i                      NUMBER;

    --These tables are not used but are required parameters to
    --ENG_ECO_PUB.process_eco
    l_rev_tbl              Eng_Eco_Pub.Eco_Revision_Tbl_Type;
    l_ref_designator_tbl   Bom_Bo_Pub.Ref_Designator_Tbl_Type;
    l_sub_component_tbl    Bom_Bo_Pub.Sub_Component_Tbl_Type;
    l_rev_operation_tbl    Bom_Rtg_Pub.Rev_Operation_Tbl_Type;
    l_rev_op_resource_tbl  Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type;
    l_rev_sub_resource_tbl Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type;

    l_org_code             VARCHAR2(3);
    l_change_type_code     VARCHAR2(80);  -- Bug 3238295 Changed from 10 to 80
    l_department_name      VARCHAR2(240);  --Bug 2925982 Changes 60 to 240
    l_use_up_item_name     VARCHAR2(801);
    l_revised_item_name    VARCHAR2(801);
    l_component_item_name  VARCHAR2(801);
    l_location_name        VARCHAR2(81);

    l_rev_cnt              NUMBER := 0;
    l_comp_cnt             NUMBER := 0;
    l_item_cnt             NUMBER := 0;
    l_return_status        VARCHAR2(1);
    l_msg_cnt              NUMBER;
    l_alternate_bom_code   VARCHAR2(10) := NULL;                               -- Bug 2353962
    l_ref_count      NUMBER := 0; /* Added this variable to fix bug 5083488. */

--    l_Mesg_Token_Tbl       Error_Handler.Mesg_Token_Tbl_Type;
--    l_Token_Tbl            Error_Handler.Token_Tbl_Type;

BEGIN

   --Default error message in case the mass update fails
   --The error message is set to null on successful completion
   error_message := 'A fatal error occurred while processing mass_update.';

-- Bug 1807268
--  Added update statement here to update the org_id in bom_lists Table
--
    UPDATE bom_lists
    SET organization_id = org_id
    WHERE sequence_id = list_id;

    Restrict_List(list_id,
                  profile.model_item_access,
                  profile.planning_item_access,
                  profile.standard_item_access,
                  change_order,
                  org_id,
                  list_error_msg);

    IF list_error_msg IS NOT NULL THEN
        RAISE list_error;
    END IF;

    SAVEPOINT begin_mass_update;

    --Need the Organization Code
    SELECT organization_code
    INTO   l_org_code
    FROM   org_organization_definitions
    WHERE  organization_id = org_id;

    --Popuating PL/SQL record for ECO Header
    FOR eco_rec IN c_eco_rec LOOP

        --reset the tables
        l_item_tbl.DELETE;
        l_comp_tbl.DELETE;
        l_error_tbl.DELETE;
        l_rev_tbl.DELETE;
        l_ref_designator_tbl.DELETE;
        l_sub_component_tbl.DELETE;
        l_rev_operation_tbl.DELETE;
        l_rev_op_resource_tbl.DELETE;
        l_rev_sub_resource_tbl.DELETE;

        l_return_status := 'E';

/*
        INSERT INTO eng_engineering_changes(
                change_notice,
                organization_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                description,
                status_type,
                initiation_date,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                approval_status_type,
                change_order_type_id,
                responsible_organization_id,
                hierarchy_flag,
                organization_hierarchy)
        SELECT  i.change_notice,
                i.organization_id,
                SYSDATE,
                profile.userid,
                SYSDATE,
                profile.userid,
                profile.loginid,
                i.description,
                default_status, -- open
                SYSDATE,
                profile.reqstid,
                profile.appid,
                profile.progid,
                SYSDATE,
                default_approval_status, -- approved
                i.change_order_type_id,
                i.responsible_organization_id,
                2,
                NULL
        FROM    eng_eng_changes_interface i
        WHERE   i.change_notice = change_order
        AND     i.organization_id = org_id;
*/

        --Need the Change Order Type Code
        IF (eco_rec.change_order_type_id IS NOT NULL) THEN

           --SELECT change_order_type
     SELECT type_name
           INTO   l_change_type_code
           --FROM   eng_change_order_types
     FROM eng_change_order_types_vl
           WHERE  change_order_type_id = eco_rec.change_order_type_id;

        ELSE

           l_change_type_code := NULL;

        END IF;

        --Need the Responsible Org Name
        IF (eco_rec.responsible_organization_id IS NOT NULL) THEN

           SELECT name
           INTO   l_department_name
           FROM   hr_all_organization_units
           WHERE  organization_id = eco_rec.responsible_organization_id;

        ELSE

           l_department_name := NULL;

        END IF;

        --Populating PL/SQL record for ECO Header
        l_eco_rec.eco_name                  := change_order;
        l_eco_rec.organization_code         := l_org_code;
        l_eco_rec.change_type_code          := l_change_type_code;
        -- l_eco_rec.status_type               := default_status; --open
        l_eco_rec.eco_department_name       := l_department_name;
        l_eco_rec.priority_code             := eco_rec.priority_code;
        l_eco_rec.approval_list_name        := eco_rec.approval_list_name;
        -- l_eco_rec.approval_status_type      := default_approval_status;
        l_eco_rec.reason_code               := eco_rec.reason_code;
        l_eco_rec.eng_implementation_cost   := eco_rec.estimated_eng_cost;
        l_eco_rec.mfg_implementation_cost   := eco_rec.estimated_mfg_cost;
        l_eco_rec.cancellation_comments     := eco_rec.cancellation_comments;
        l_eco_rec.description               := eco_rec.description;
        l_eco_rec.return_status             := NULL;
        l_eco_rec.transaction_type          := 'CREATE';
  -- hierarchy_flag not used any more
        -- l_eco_rec.hierarchy_flag            := 2;
        l_eco_rec.organization_hierarchy    := NULL;
  l_eco_rec.plm_or_erp_change :='ERP'; --Bug 3224337

        FOR bom_list IN c_get_bom_list(list_id, org_id) LOOP

            l_use_up_item_name  := Get_Item_Name(bom_list.use_up_item_id,
                                                 org_id);
            l_revised_item_name := Get_Item_Name(bom_list.assembly_item_id,
                                                 org_id);

            bom_list.new_item_revision := NULL;
            l_alternate_bom_code := bom_list.alternate_designator;   -- Bug 2353962

            IF (bom_list.increment_rev = yes AND
                bom_list.alternate_designator IS NULL) THEN

                whoami.userid  := profile.userid;
                whoami.reqstid := profile.reqstid;
                whoami.appid   := profile.appid;
                whoami.progid  := profile.progid;
                whoami.loginid := profile.loginid;

                BOMPINRV.increment_revision(
                    i_item_id     => bom_list.assembly_item_id,
                    i_org_id      => org_id,
                    i_date_time   => NVL(bom_list.scheduled_date,
                                         SYSDATE),
                    who           => whoami,
                    o_out_code    => bom_list.new_item_revision,
                    error_message => rev_error_msg);

                IF rev_error_msg IS NOT NULL THEN
                    raise revision_error;
                END IF;

            END IF; --increment revision

/*
                IF bom_list.new_item_revision IS NOT NULL THEN

                    UPDATE mtl_item_revisions
                    SET    change_notice = change_order,
                           ecn_initiation_date = SYSDATE,
                           revised_item_sequence_id =
                               bom_list.revised_item_sequence_id
                    WHERE  inventory_item_id = bom_list.assembly_item_id
                    AND    organization_id = org_id
                    AND    revision = bom_list.new_item_revision;

                END IF;   -- increment revision successful

            INSERT INTO eng_revised_items(
                change_notice,
                organization_id,
                revised_item_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                disposition_type,
                new_item_revision,
                early_schedule_date,
                status_type,
                scheduled_date,
                bill_sequence_id,
                mrp_active,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                update_wip,
                use_up,
                use_up_item_id,
                revised_item_sequence_id,
                use_up_plan_name,
                eco_for_production,                    --- bug 1890000
                from_end_item_unit_number)
            VALUES (
                change_order,
                org_id,
                bom_list.assembly_item_id,
                SYSDATE,
                profile.userid,
                SYSDATE,
                profile.userid,
                profile.loginid,
                default_disposition, -- no change required
                bom_list.new_item_revision,
                LEAST(bom_list.scheduled_date, SYSDATE),
                default_status, -- open status
                NVL(bom_list.scheduled_date,SYSDATE),
                bom_list.bill_sequence_id,
                NVL(bom_list.mrp_active, no),
                profile.reqstid,
                profile.appid,
                profile.progid,
                SYSDATE,
                NVL(bom_list.update_wip, no),
                NVL(bom_list.use_up, no),
                bom_list.use_up_item_id,
                bom_list.revised_item_sequence_id,
                bom_list.use_up_plan_name,
                2,
                bom_list.from_end_item_unit_number);
*/

            l_item_cnt := l_item_cnt + 1;

            l_item_tbl(l_item_cnt).eco_name                  := change_order;
            l_item_tbl(l_item_cnt).organization_code         := l_org_code;
            l_item_tbl(l_item_cnt).revised_item_name         := l_revised_item_name;
            l_item_tbl(l_item_cnt).new_revised_item_revision := bom_list.new_item_revision;
            l_item_tbl(l_item_cnt).start_effective_date      := NVL(bom_list.scheduled_date,
                                                                    TRUNC(SYSDATE));
-- 2387927            l_item_tbl(l_item_cnt).alternate_bom_code        := NULL;
            l_item_tbl(l_item_cnt).alternate_bom_code        := bom_list.alternate_designator;
            l_item_tbl(l_item_cnt).status_type               := default_status;
            l_item_tbl(l_item_cnt).mrp_active                := NVL(bom_list.mrp_active, no);
            l_item_tbl(l_item_cnt).use_up_item_name          := l_use_up_item_name;
            l_item_tbl(l_item_cnt).use_up_plan_name          := bom_list.use_up_plan_name;
            l_item_tbl(l_item_cnt).disposition_type          := default_disposition; -- no change
            l_item_tbl(l_item_cnt).update_wip                := NVL(bom_list.update_wip, no);

            IF bom_list.effectivity_control = unit_control THEN
                l_item_tbl(l_item_cnt).earliest_effective_date := NULL;
                l_item_tbl(l_item_cnt).from_end_item_unit_number := bom_list.from_end_item_unit_number;
            ELSE
                l_item_tbl(l_item_cnt).earliest_effective_date := LEAST(NVL(bom_list.scheduled_date,
                                                                            TRUNC(SYSDATE)),
                                                                        TRUNC(SYSDATE));
            END IF;

            l_item_tbl(l_item_cnt).transaction_type          := 'CREATE';
            l_item_tbl(l_item_cnt).eco_for_production        := 2;
            --l_item_tbl(l_item_cnt).updated_revised_item_revision :=
            l_item_tbl(l_item_cnt).new_effective_date        := NVL(bom_list.scheduled_date,
                                                                    TRUNC(SYSDATE));
            --l_item_tbl(l_item_cnt).new_from_end_item_unit_number :=
            l_item_tbl(l_item_cnt).return_status             := NULL;
            l_item_tbl(l_item_cnt).new_routing_revision      := NULL;
            --l_item_tbl(l_item_cnt).updated_routing_revision  :=
            l_item_tbl(l_item_cnt).cancel_comments           := NULL;
            l_item_tbl(l_item_cnt).change_description        := NULL;

/*
            INSERT INTO eng_current_scheduled_dates(
                change_notice,
                organization_id,
                revised_item_id,
                scheduled_date,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                schedule_id,
                program_application_id,
                program_id,
                program_update_date,
                request_id,
                revised_item_sequence_id)
            VALUES(
                change_order,
                org_id,
                bom_list.assembly_item_id,
                NVL(bom_list.scheduled_date,SYSDATE),
                SYSDATE,
                profile.userid,
                SYSDATE,
                profile.userid,
                profile.loginid,
                eng_current_scheduled_dates_s.NEXTVAL,
                profile.appid,
                profile.progid,
                SYSDATE,
                profile.reqstid,
                bom_list.revised_item_sequence_id);
*/
--
--  Insert component deletes.
--
            X_Statement_Number := '[1]';

/* replaced with cursor loop following
            INSERT INTO bom_inventory_components(
                operation_seq_num,
                component_item_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                item_num,
                component_quantity,
                component_yield_factor,
                effectivity_date,
                disable_date,
                change_notice,
                planning_factor,
                quantity_related,
                so_basis,
                optional,
                mutually_exclusive_options,
                include_in_cost_rollup,
                check_atp,
                shipping_allowed,
                required_to_ship,
                required_for_revenue,
                include_on_ship_docs,
                low_quantity,
                high_quantity,
                acd_type,
                old_component_sequence_id,
                component_sequence_id,
                bill_sequence_id,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                wip_supply_type,
                supply_subinventory,
                supply_locator_id,
                revised_item_sequence_id,
                bom_item_type)
            SELECT  NVL(i.operation_seq_num, c.operation_seq_num),
                    i.component_item_id,
                    SYSDATE,
                    r.last_updated_by,
                    SYSDATE,
                    r.created_by,
                    r.last_update_login,
                    NVL(i.item_num, c.item_num),
                    NVL(i.component_quantity, c.component_quantity),
                    NVL(i.component_yield_factor,
                    c.component_yield_factor),
                    NVL(r.scheduled_date,SYSDATE),
                    r.scheduled_date,
                    r.change_notice,
                    NVL(i.planning_factor, c.planning_factor),
                    NVL(i.quantity_related, c.quantity_related),
                    NVL(i.so_basis, c.so_basis),
                    NVL(i.optional, c.optional),
                    NVL(i.mutually_exclusive_options,
                        c.mutually_exclusive_options),
                    NVL(i.include_in_cost_rollup, c.include_in_cost_rollup),
                    NVL(i.check_atp, c.check_atp),
                    NVL(i.shipping_allowed, c.shipping_allowed),
                    NVL(i.required_to_ship, c.required_to_ship),
                    NVL(i.required_for_revenue, c.required_for_revenue),
                    NVL(i.include_on_ship_docs, c.include_on_ship_docs),
                    NVL(i.low_quantity, c.low_quantity),
                    NVL(i.high_quantity, c.high_quantity),
                    ecg_action_delete,
                    c.component_sequence_id,
                    bom_inventory_components_s.NEXTVAL,
                    r.bill_sequence_id,
                    r.request_id,
                    r.program_application_id,
                    r.program_id,
                    SYSDATE,
                    NVL(i.wip_supply_type, c.wip_supply_type),
                    NVL(i.supply_subinventory, c.supply_subinventory),
                    NVL(i.supply_locator_id, c.supply_locator_id),
                    r.revised_item_sequence_id,
                    itm.bom_item_type
            FROM    mtl_system_items_b itm,
                    bom_inventory_components c,
                    bom_inventory_comps_interface i,
                    eng_revised_items_interface ri,
                    eng_revised_items r
            WHERE (c.item_num = i.item_num OR i.item_num IS NULL)
            AND (c.component_quantity = i.component_quantity OR
                 i.component_quantity IS NULL)
            AND (c.component_yield_factor = i.component_yield_factor OR
                 i.component_yield_factor IS NULL)
            AND (c.planning_factor = i.planning_factor OR
                 i.planning_factor IS NULL)
            AND (c.quantity_related = i.quantity_related OR
                 i.quantity_related IS NULL)
            AND (c.so_basis = i.so_basis OR i.so_basis IS NULL)
            AND (c.optional = i.optional OR i.optional IS NULL)
            AND (c.mutually_exclusive_options = i.mutually_exclusive_options OR
                 i.mutually_exclusive_options IS NULL)
            AND (c.include_in_cost_rollup = i.include_in_cost_rollup OR
                 i.include_in_cost_rollup IS NULL)
            AND (c.check_atp = i.check_atp OR i.check_atp IS NULL)
            AND (c.shipping_allowed = i.shipping_allowed OR
                 i.shipping_allowed IS NULL)
            AND (c.required_to_ship = i.required_to_ship OR
                 i.required_to_ship IS NULL)
            AND (c.required_for_revenue = i.required_for_revenue OR
                 i.required_for_revenue IS NULL)
            AND (c.include_on_ship_docs = i.include_on_ship_docs OR
                 i.include_on_ship_docs IS NULL)
            AND (c.low_quantity = i.low_quantity OR i.low_quantity IS NULL)
            AND (c.high_quantity = i.high_quantity OR i.high_quantity IS NULL)
            AND (c.wip_supply_type = i.wip_supply_type OR
                 i.wip_supply_type IS NULL)
            AND (c.supply_subinventory = i.supply_subinventory OR
                 i.supply_subinventory IS NULL)
            AND (c.supply_locator_id = i.supply_locator_id OR
                 i.supply_locator_id IS NULL)
            AND (c.component_remarks = i.component_remarks
                 OR i.component_remarks IS NULL)
            AND (c.attribute_category = i.attribute_category
                 OR i.attribute_category IS NULL)
            AND (c.attribute1 = i.attribute1 OR i.attribute1 IS NULL)
            AND (c.attribute2 = i.attribute2 OR i.attribute2 IS NULL)
            AND (c.attribute3 = i.attribute3 OR i.attribute3 IS NULL)
            AND (c.attribute4 = i.attribute4 OR i.attribute4 IS NULL)
            AND (c.attribute5 = i.attribute5 OR i.attribute5 IS NULL)
            AND (c.attribute6 = i.attribute6 OR i.attribute6 IS NULL)
            AND (c.attribute7 = i.attribute7 OR i.attribute7 IS NULL)
            AND (c.attribute8 = i.attribute8 OR i.attribute8 IS NULL)
            AND (c.attribute9 = i.attribute9 OR i.attribute9 IS NULL)
            AND (c.attribute10 = i.attribute10 OR i.attribute10 IS NULL)
            AND (c.attribute11 = i.attribute11 OR i.attribute11 IS NULL)
            AND (c.attribute12 = i.attribute12 OR i.attribute12 IS NULL)
            AND (c.attribute13 = i.attribute13 OR i.attribute13 IS NULL)
            AND (c.attribute14 = i.attribute14 OR i.attribute14 IS NULL)
            AND (c.attribute15 = i.attribute15 OR i.attribute15 IS NULL)
            AND NVL(TRUNC(c.disable_date),
                          r.scheduled_date+1) > r.scheduled_date
            AND TRUNC(c.effectivity_date) <= r.scheduled_date
            AND c.operation_seq_num = NVL(i.operation_seq_num,
                                          c.operation_seq_num)
            AND c.bill_sequence_id = r.bill_sequence_id
            AND c.component_item_id = i.component_item_id
            AND itm.inventory_item_id = c.component_item_id
            AND itm.organization_id = r.organization_id
            AND r.revised_item_sequence_id = bom_list.revised_item_sequence_id
            AND i.acd_type = action_delete
            AND i.revised_item_sequence_id = ri.revised_item_sequence_id
            AND ri.change_notice = change_order
            AND ri.organization_id = org_id;
*/

            FOR comp_delete IN c_comp_delete(bom_list.scheduled_date,
                                             bom_list.bill_sequence_id,
                                             bom_list.from_end_item_unit_number)
            LOOP

                --get lookup values
                l_component_item_name := Get_Item_Name(comp_delete.component_item_id, org_id);
                l_location_name       := Get_Location_Name(comp_delete.supply_locator_id);

                FND_FILE.PUT_LINE(FND_FILE.LOG,'Preparing disable of ' ||l_component_item_name||
                                               ' on '||l_revised_item_name);

                l_comp_cnt := l_comp_cnt + 1;

                l_comp_tbl(l_comp_cnt).eco_name                  := change_order;
                l_comp_tbl(l_comp_cnt).organization_code         := l_org_code;
                l_comp_tbl(l_comp_cnt).revised_item_name         := l_revised_item_name;
                l_comp_tbl(l_comp_cnt).new_revised_item_revision := bom_list.new_item_revision;
                l_comp_tbl(l_comp_cnt).start_effective_date      := NVL(bom_list.scheduled_date,
                                                                        TRUNC(SYSDATE));
                --l_comp_tbl(l_comp_cnt).new_effectivity_date      :=
                l_comp_tbl(l_comp_cnt).disable_date              := bom_list.scheduled_date;
                l_comp_tbl(l_comp_cnt).operation_sequence_number := comp_delete.operation_sequence_number;
                l_comp_tbl(l_comp_cnt).component_item_name       := l_component_item_name;
                l_comp_tbl(l_comp_cnt).alternate_bom_code        := l_alternate_bom_code;  -- Bug 2353962
                l_comp_tbl(l_comp_cnt).acd_type                  := comp_delete.acd_type;
                l_comp_tbl(l_comp_cnt).old_effectivity_date      := comp_delete.old_effectivity_date;
                l_comp_tbl(l_comp_cnt).old_operation_sequence_number := comp_delete.operation_sequence_number;
                l_comp_tbl(l_comp_cnt).new_operation_sequence_number := NULL;
                l_comp_tbl(l_comp_cnt).item_sequence_number      := comp_delete.item_num;
                l_comp_tbl(l_comp_cnt).basis_type      := comp_delete.basis_type;
                l_comp_tbl(l_comp_cnt).quantity_per_assembly     := comp_delete.component_quantity;
                l_comp_tbl(l_comp_cnt).planning_percent          := comp_delete.planning_factor;
                l_comp_tbl(l_comp_cnt).projected_yield           := comp_delete.component_yield_factor;
                l_comp_tbl(l_comp_cnt).include_in_cost_rollup    := comp_delete.include_in_cost_rollup;
                l_comp_tbl(l_comp_cnt).wip_supply_type           := comp_delete.wip_supply_type;
                l_comp_tbl(l_comp_cnt).so_basis                  := comp_delete.so_basis;
                l_comp_tbl(l_comp_cnt).optional                  := comp_delete.optional;
                l_comp_tbl(l_comp_cnt).mutually_exclusive := comp_delete.mutually_exclusive_options;
                l_comp_tbl(l_comp_cnt).check_atp                 := comp_delete.check_atp;
                l_comp_tbl(l_comp_cnt).shipping_allowed          := comp_delete.shipping_allowed;
                l_comp_tbl(l_comp_cnt).required_to_ship          := comp_delete.required_to_ship;
                l_comp_tbl(l_comp_cnt).required_for_revenue      := comp_delete.required_for_revenue;
                l_comp_tbl(l_comp_cnt).include_on_ship_docs      := comp_delete.include_on_ship_docs;
                l_comp_tbl(l_comp_cnt).quantity_related          := comp_delete.quantity_related;
                l_comp_tbl(l_comp_cnt).supply_subinventory       := comp_delete.supply_subinventory;
                l_comp_tbl(l_comp_cnt).location_name             := l_location_name;
                l_comp_tbl(l_comp_cnt).minimum_allowed_quantity  := comp_delete.low_quantity;
                l_comp_tbl(l_comp_cnt).maximum_allowed_quantity  := comp_delete.high_quantity;
                IF bom_list.effectivity_control = unit_control THEN
                    l_comp_tbl(l_comp_cnt).old_from_end_item_unit_number := comp_delete.old_from_end_item_unit_number;
                    l_comp_tbl(l_comp_cnt).from_end_item_unit_number := comp_delete.from_end_item_unit_number;
                    l_comp_tbl(l_comp_cnt).to_end_item_unit_number   := comp_delete.to_end_item_unit_number;
                ELSE
                    l_comp_tbl(l_comp_cnt).old_from_end_item_unit_number := NULL;
                    l_comp_tbl(l_comp_cnt).from_end_item_unit_number := NULL;
                    l_comp_tbl(l_comp_cnt).to_end_item_unit_number   := NULL;
                END IF;
                l_comp_tbl(l_comp_cnt).new_routing_revision      := NULL;
                l_comp_tbl(l_comp_cnt).return_status             := NULL;
                l_comp_tbl(l_comp_cnt).transaction_type          := 'CREATE';
                l_comp_tbl(l_comp_cnt).comments                  := comp_delete.component_remarks; -- Bug 3347094

            END LOOP; --comp_delete

--
--  Disable component changes, if action_type =action_replace
--   and New component_item_id != old row's component_item_id
--  Included mass replace of components.
            X_Statement_Number := '[2]';

/* replaced with cursor loop following
            INSERT INTO bom_inventory_components(
                operation_seq_num,
                component_item_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                item_num,
                component_quantity,
                component_yield_factor,
                effectivity_date,
                disable_date,
                change_notice,
                planning_factor,
                quantity_related,
                so_basis,
                optional,
                mutually_exclusive_options,
                include_in_cost_rollup,
                check_atp,
                shipping_allowed,
                required_to_ship,
                required_for_revenue,
                include_on_ship_docs,
                low_quantity,
                high_quantity,
                acd_type,
                old_component_sequence_id,
                component_sequence_id,
                bill_sequence_id,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                wip_supply_type,
                supply_subinventory,
                supply_locator_id,
                revised_item_sequence_id,
                bom_item_type)
            SELECT  NVL(o.operation_seq_num, c.operation_seq_num),
                    o.component_item_id,
                    SYSDATE,
                    r.last_updated_by,
                    SYSDATE,
                    r.created_by,
                    r.last_update_login,
                    NVL(o.item_num, c.item_num),
                    NVL(o.component_quantity, c.component_quantity),
                    NVL(o.component_yield_factor,
                    c.component_yield_factor),
                    NVL(r.scheduled_date,SYSDATE),
                    r.scheduled_date,
                    r.change_notice,
                    NVL(o.planning_factor, c.planning_factor),
                    NVL(o.quantity_related, c.quantity_related),
                    NVL(o.so_basis, c.so_basis),
                    NVL(o.optional, c.optional),
                    NVL(o.mutually_exclusive_options,
                        c.mutually_exclusive_options),
                    NVL(o.include_in_cost_rollup, c.include_in_cost_rollup),
                        NVL(o.check_atp, c.check_atp),
                    NVL(o.shipping_allowed, c.shipping_allowed),
                    NVL(o.required_to_ship, c.required_to_ship),
                    NVL(o.required_for_revenue, c.required_for_revenue),
                    NVL(o.include_on_ship_docs, c.include_on_ship_docs),
                    NVL(o.low_quantity, c.low_quantity),
                    NVL(o.high_quantity, c.high_quantity),
                    ecg_action_delete,
                    c.component_sequence_id,
                    bom_inventory_components_s.NEXTVAL,
                    r.bill_sequence_id,
                    r.request_id,
                    r.program_application_id,
                    r.program_id,
                    SYSDATE,
                    NVL(o.wip_supply_type, c.wip_supply_type),
                    NVL(o.supply_subinventory, c.supply_subinventory),
                    NVL(o.supply_locator_id, c.supply_locator_id),
                    r.revised_item_sequence_id,
                    itm.bom_item_type
            FROM    mtl_system_items_b itm,
                    bom_inventory_components c,
                    bom_inventory_comps_interface n,  -- new attributes
                    bom_inventory_comps_interface o,  -- old attributes
                    eng_revised_items_interface ri,
                    eng_revised_items r
            WHERE n.old_component_sequence_id = o.component_sequence_id
            AND (n.component_item_id <> o.component_item_id)
            AND (c.item_num = o.item_num OR o.item_num IS NULL)
            AND (c.component_quantity = o.component_quantity OR
                 o.component_quantity IS NULL)
            AND (c.component_yield_factor = o.component_yield_factor OR
                 o.component_yield_factor IS NULL)
            AND (c.component_remarks = o.component_remarks OR
                 o.component_remarks IS NULL)
            AND (c.attribute_category = o.attribute_category OR
                 o.attribute_category IS NULL)
            AND (c.attribute1 = o.attribute1 OR o.attribute1 IS NULL)
            AND (c.attribute2 = o.attribute2 OR o.attribute2 IS NULL)
            AND (c.attribute3 = o.attribute3 OR o.attribute3 IS NULL)
            AND (c.attribute4 = o.attribute4 OR o.attribute4 IS NULL)
            AND (c.attribute5 = o.attribute5 OR o.attribute5 IS NULL)
            AND (c.attribute6 = o.attribute6 OR o.attribute6 IS NULL)
            AND (c.attribute7 = o.attribute7 OR o.attribute7 IS NULL)
            AND (c.attribute8 = o.attribute8 OR o.attribute8 IS NULL)
            AND (c.attribute9 = o.attribute9 OR o.attribute9 IS NULL)
            AND (c.attribute10 = o.attribute10 OR o.attribute10 IS NULL)
            AND (c.attribute11 = o.attribute11 OR o.attribute11 IS NULL)
            AND (c.attribute12 = o.attribute12 OR o.attribute12 IS NULL)
            AND (c.attribute13 = o.attribute13 OR o.attribute13 IS NULL)
            AND (c.attribute14 = o.attribute14 OR o.attribute14 IS NULL)
            AND (c.attribute15 = o.attribute15 OR o.attribute15 IS NULL)
            AND (c.planning_factor = o.planning_factor OR
                 o.planning_factor IS NULL)
            AND (c.quantity_related = o.quantity_related OR
                 o.quantity_related IS NULL)
            AND (c.so_basis = o.so_basis OR o.so_basis IS NULL)
            AND (c.optional = o.optional OR o.optional IS NULL)
            AND (c.mutually_exclusive_options = o.mutually_exclusive_options OR
                 o.mutually_exclusive_options IS NULL)
            AND (c.include_in_cost_rollup = o.include_in_cost_rollup OR
                 o.include_in_cost_rollup IS NULL)
            AND (c.check_atp = o.check_atp OR o.check_atp IS NULL)
            AND (c.shipping_allowed = o.shipping_allowed OR
                 o.shipping_allowed IS NULL)
            AND (c.required_to_ship = o.required_to_ship OR
                 o.required_to_ship IS NULL)
            AND (c.required_for_revenue = o.required_for_revenue OR
                 o.required_for_revenue IS NULL)
            AND (c.include_on_ship_docs = o.include_on_ship_docs OR
                 o.include_on_ship_docs IS NULL)
            AND (c.low_quantity = o.low_quantity OR o.low_quantity IS NULL)
            AND (c.high_quantity = o.high_quantity OR o.high_quantity IS NULL)
            AND (c.wip_supply_type = o.wip_supply_type OR
                 o.wip_supply_type IS NULL)
            AND (c.supply_subinventory = o.supply_subinventory OR
                 o.supply_subinventory IS NULL)
            AND (c.supply_locator_id = o.supply_locator_id OR
                 o.supply_locator_id IS NULL)
            AND NVL(TRUNC(c.disable_date),
                    r.scheduled_date+1) > r.scheduled_date
            AND TRUNC(c.effectivity_date) <= r.scheduled_date
            AND c.operation_seq_num = NVL(o.operation_seq_num,
                                          c.operation_seq_num)
            AND c.bill_sequence_id = r.bill_sequence_id
            AND c.component_item_id = o.component_item_id
            AND o.acd_type = action_replace
            AND o.revised_item_sequence_id = ri.revised_item_sequence_id
            AND itm.inventory_item_id = c.component_item_id
            AND itm.organization_id = r.organization_id
            AND r.revised_item_sequence_id = bom_list.revised_item_sequence_id
            AND ri.change_notice = change_order
            AND ri.organization_id = org_id;
*/

            FOR comp_replace IN c_comp_replace(
                                    bom_list.scheduled_date,
                                    bom_list.bill_sequence_id,
                                    bom_list.from_end_item_unit_number) LOOP

                --get lookup values
                l_component_item_name := Get_Item_Name(comp_replace.component_item_id, org_id);
                l_location_name       := Get_Location_Name(comp_replace.supply_locator_id);

                FND_FILE.PUT_LINE(FND_FILE.LOG,'Preparing disable of ' ||l_component_item_name||
                                               ' on '||l_revised_item_name);

                l_comp_cnt := l_comp_cnt + 1;

                l_comp_tbl(l_comp_cnt).eco_name                  := change_order;
                l_comp_tbl(l_comp_cnt).organization_code         := l_org_code;
                l_comp_tbl(l_comp_cnt).new_revised_item_revision := bom_list.new_item_revision;
                l_comp_tbl(l_comp_cnt).revised_item_name         := l_revised_item_name;
                l_comp_tbl(l_comp_cnt).start_effective_date      := NVL(bom_list.scheduled_date,
                                                                        TRUNC(SYSDATE));
                --l_comp_tbl(l_comp_cnt).new_effectivity_date      :=

                l_comp_tbl(l_comp_cnt).disable_date              := bom_list.scheduled_date;
                l_comp_tbl(l_comp_cnt).operation_sequence_number := comp_replace.operation_sequence_number;
                l_comp_tbl(l_comp_cnt).component_item_name       := l_component_item_name;
                l_comp_tbl(l_comp_cnt).alternate_bom_code        := l_alternate_bom_code;  -- Bug 2353962
                l_comp_tbl(l_comp_cnt).acd_type                  := comp_replace.acd_type;
                l_comp_tbl(l_comp_cnt).old_effectivity_date      := comp_replace.old_effectivity_date;
                l_comp_tbl(l_comp_cnt).old_operation_sequence_number := comp_replace.operation_sequence_number;
                l_comp_tbl(l_comp_cnt).new_operation_sequence_number := comp_replace.new_operation_sequence_number;
                l_comp_tbl(l_comp_cnt).item_sequence_number      := comp_replace.item_num;
                l_comp_tbl(l_comp_cnt).basis_type      := comp_replace.basis_type;
                l_comp_tbl(l_comp_cnt).quantity_per_assembly     := comp_replace.component_quantity;
                l_comp_tbl(l_comp_cnt).planning_percent          := comp_replace.planning_factor;
                l_comp_tbl(l_comp_cnt).projected_yield           := comp_replace.component_yield_factor;
                l_comp_tbl(l_comp_cnt).include_in_cost_rollup    := comp_replace.include_in_cost_rollup;
                l_comp_tbl(l_comp_cnt).wip_supply_type           := comp_replace.wip_supply_type;
                l_comp_tbl(l_comp_cnt).so_basis                  := comp_replace.so_basis;
                l_comp_tbl(l_comp_cnt).optional                  := comp_replace.optional;
                l_comp_tbl(l_comp_cnt).mutually_exclusive := comp_replace.mutually_exclusive_options;
                l_comp_tbl(l_comp_cnt).check_atp                 := comp_replace.check_atp;
                l_comp_tbl(l_comp_cnt).shipping_allowed          := comp_replace.shipping_allowed;
                l_comp_tbl(l_comp_cnt).required_to_ship          := comp_replace.required_to_ship;
                l_comp_tbl(l_comp_cnt).required_for_revenue      := comp_replace.required_for_revenue;
                l_comp_tbl(l_comp_cnt).include_on_ship_docs      := comp_replace.include_on_ship_docs;
                l_comp_tbl(l_comp_cnt).quantity_related          := comp_replace.quantity_related;
                l_comp_tbl(l_comp_cnt).supply_subinventory       := comp_replace.supply_subinventory;
                l_comp_tbl(l_comp_cnt).location_name             := l_location_name;
                l_comp_tbl(l_comp_cnt).minimum_allowed_quantity  := comp_replace.low_quantity;
                l_comp_tbl(l_comp_cnt).maximum_allowed_quantity  := comp_replace.high_quantity;
                IF bom_list.effectivity_control = unit_control THEN
                    l_comp_tbl(l_comp_cnt).old_from_end_item_unit_number := comp_replace.old_from_end_item_unit_number;
                    l_comp_tbl(l_comp_cnt).from_end_item_unit_number := comp_replace.from_end_item_unit_number;
                    l_comp_tbl(l_comp_cnt).to_end_item_unit_number   := comp_replace.to_end_item_unit_number;
                ELSE
                    l_comp_tbl(l_comp_cnt).old_from_end_item_unit_number := NULL;
                    l_comp_tbl(l_comp_cnt).from_end_item_unit_number := NULL;
                    l_comp_tbl(l_comp_cnt).to_end_item_unit_number   := NULL;
                END IF;
                l_comp_tbl(l_comp_cnt).new_routing_revision      := NULL;
                l_comp_tbl(l_comp_cnt).return_status             := NULL;
                l_comp_tbl(l_comp_cnt).transaction_type          := 'CREATE';
                l_comp_tbl(l_comp_cnt).comments                  := comp_replace.component_remarks; --* Modified for Bug 3347094

            END LOOP; --comp_replace

--
--  Insert component changes.
--  Bug 568258:  If replacement values for Supply Type, Subinventory or
--  Locator is null and corresponding search criteria is not null, update
--  component's attributes to null
--
            X_Statement_Number := '[3]';

/* replaced with cursor loop following
            INSERT INTO bom_inventory_components(
                operation_seq_num,
                component_item_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                item_num,
                component_quantity,
                component_yield_factor,
                effectivity_date,
                disable_date,
                change_notice,
                component_remarks,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                planning_factor,
                quantity_related,
                so_basis,
                optional,
                mutually_exclusive_options,
                include_in_cost_rollup,
                check_atp,
                shipping_allowed,
                required_to_ship,
                required_for_revenue,
                include_on_ship_docs,
                low_quantity,
                high_quantity,
                acd_type,
                component_sequence_id,
                old_component_sequence_id,
                bill_sequence_id,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                wip_supply_type,
                supply_subinventory,
                supply_locator_id,
                revised_item_sequence_id,
                bom_item_type)
            SELECT  NVL(n.operation_seq_num, c.operation_seq_num),
                    n.component_item_id,
                    SYSDATE,
                    r.last_updated_by,
                    SYSDATE,
                    r.created_by,
                    r.last_update_login,
                    NVL(n.item_num, c.item_num),
                    NVL(n.component_quantity, c.component_quantity),
                    NVL(n.component_yield_factor, c.component_yield_factor),
                    NVL(r.scheduled_date,SYSDATE),
                    GREATEST(r.scheduled_date, n.disable_date),
                    r.change_notice,
                    NVL(n.component_remarks, c.component_remarks),
                    NVL(n.attribute_category, c.attribute_category),
                    NVL(n.attribute1, c.attribute1),
                    NVL(n.attribute2, c.attribute2),
                    NVL(n.attribute3, c.attribute3),
                    NVL(n.attribute4, c.attribute4),
                    NVL(n.attribute5, c.attribute5),
                    NVL(n.attribute6, c.attribute6),
                    NVL(n.attribute7, c.attribute7),
                    NVL(n.attribute8, c.attribute8),
                    NVL(n.attribute9, c.attribute9),
                    NVL(n.attribute10, c.attribute10),
                    NVL(n.attribute11, c.attribute11),
                    NVL(n.attribute12, c.attribute12),
                    NVL(n.attribute13, c.attribute13),
                    NVL(n.attribute14, c.attribute14),
                    NVL(n.attribute15, c.attribute15),
                    NVL(n.planning_factor, c.planning_factor),
                    NVL(n.quantity_related, c.quantity_related),
                    NVL(n.so_basis, c.so_basis),
                    NVL(n.optional, c.optional),
                    NVL(n.mutually_exclusive_options,
                        c.mutually_exclusive_options),
                    NVL(n.include_in_cost_rollup, c.include_in_cost_rollup),
                    NVL(n.check_atp, c.check_atp),
                    NVL(n.shipping_allowed, c.shipping_allowed),
                    NVL(n.required_to_ship, c.required_to_ship),
                    NVL(n.required_for_revenue, c.required_for_revenue),
                    NVL(n.include_on_ship_docs, c.include_on_ship_docs),
                    NVL(n.low_quantity, c.low_quantity),
                    NVL(n.high_quantity, c.high_quantity),
                    DECODE(n.component_item_id, o.component_item_id,
                           ecg_action_change, ecg_action_add),
                    bom_inventory_components_s.NEXTVAL,
                    DECODE(n.component_item_id,
                           o.component_item_id,
                           c.component_sequence_id,
                           bom_inventory_components_s.CURRVAL),
                    r.bill_sequence_id,
                    r.request_id,
                    r.program_application_id,
                    r.program_id,
                    SYSDATE,
                    NVL(n.wip_supply_type,
                      DECODE(o.wip_supply_type, NULL, c.wip_supply_type, NULL)),
                    NVL(n.supply_subinventory, DECODE(o.supply_subinventory,
                      NULL, c.supply_subinventory, NULL)),
                    NVL(n.supply_locator_id, DECODE(o.supply_locator_id, NULL,
                      c.supply_locator_id, NULL)),
                    r.revised_item_sequence_id,
                    itm.bom_item_type
            FROM    mtl_system_items_b itm,
                    bom_inventory_components c,
                    bom_inventory_comps_interface n,  -- new attributes
                    bom_inventory_comps_interface o,  -- old attributes
                    eng_revised_items_interface ri,
                    eng_revised_items r
            WHERE n.old_component_sequence_id = o.component_sequence_id
            AND  (c.item_num = o.item_num OR o.item_num IS NULL)
            AND (c.component_quantity = o.component_quantity OR
                 o.component_quantity IS NULL)
            AND (c.component_yield_factor = o.component_yield_factor OR
                 o.component_yield_factor IS NULL)
            AND (c.component_remarks = o.component_remarks OR
                 o.component_remarks IS NULL)
            AND (c.attribute_category = o.attribute_category OR
                 o.attribute_category IS NULL)
            AND (c.attribute1 = o.attribute1 OR o.attribute1 IS NULL)
            AND (c.attribute2 = o.attribute2 OR o.attribute2 IS NULL)
            AND (c.attribute3 = o.attribute3 OR o.attribute3 IS NULL)
            AND (c.attribute4 = o.attribute4 OR o.attribute4 IS NULL)
            AND (c.attribute5 = o.attribute5 OR o.attribute5 IS NULL)
            AND (c.attribute6 = o.attribute6 OR o.attribute6 IS NULL)
            AND (c.attribute7 = o.attribute7 OR o.attribute7 IS NULL)
            AND (c.attribute8 = o.attribute8 OR o.attribute8 IS NULL)
            AND (c.attribute9 = o.attribute9 OR o.attribute9 IS NULL)
            AND (c.attribute10 = o.attribute10 OR o.attribute10 IS NULL)
            AND (c.attribute11 = o.attribute11 OR o.attribute11 IS NULL)
            AND (c.attribute12 = o.attribute12 OR o.attribute12 IS NULL)
            AND (c.attribute13 = o.attribute13 OR o.attribute13 IS NULL)
            AND (c.attribute14 = o.attribute14 OR o.attribute14 IS NULL)
            AND (c.attribute15 = o.attribute15 OR o.attribute15 IS NULL)
            AND (c.planning_factor = o.planning_factor OR
                 o.planning_factor IS NULL)
            AND (c.quantity_related = o.quantity_related OR
                 o.quantity_related IS NULL)
            AND (c.so_basis = o.so_basis OR o.so_basis IS NULL)
            AND (c.optional = o.optional OR o.optional IS NULL)
            AND (c.mutually_exclusive_options = o.mutually_exclusive_options OR
                 o.mutually_exclusive_options IS NULL)
            AND (c.include_in_cost_rollup = o.include_in_cost_rollup OR
                 o.include_in_cost_rollup IS NULL)
            AND (c.check_atp = o.check_atp OR o.check_atp IS NULL)
            AND (c.shipping_allowed = o.shipping_allowed OR
                 o.shipping_allowed IS NULL)
            AND (c.required_to_ship = o.required_to_ship OR
                 o.required_to_ship IS NULL)
            AND (c.required_for_revenue = o.required_for_revenue OR
                 o.required_for_revenue IS NULL)
            AND (c.include_on_ship_docs = o.include_on_ship_docs OR
                 o.include_on_ship_docs IS NULL)
            AND (c.low_quantity = o.low_quantity OR o.low_quantity IS NULL)
            AND (c.high_quantity = o.high_quantity OR o.high_quantity IS NULL)
            AND (c.wip_supply_type = o.wip_supply_type OR
                 o.wip_supply_type IS NULL)
            AND (c.supply_subinventory = o.supply_subinventory OR
                 o.supply_subinventory IS NULL)
            AND (c.supply_locator_id = o.supply_locator_id OR
                 o.supply_locator_id IS NULL)
            AND NVL(TRUNC(c.disable_date),
                    r.scheduled_date+1) > r.scheduled_date
            AND TRUNC(c.effectivity_date) <= r.scheduled_date
            AND c.operation_seq_num = NVL(o.operation_seq_num,
                                          c.operation_seq_num)
            AND c.bill_sequence_id = r.bill_sequence_id
            AND c.component_item_id = o.component_item_id
            AND o.acd_type = action_replace
            AND o.revised_item_sequence_id = ri.revised_item_sequence_id
            AND itm.inventory_item_id = c.component_item_id
            AND itm.organization_id = r.organization_id
            AND r.revised_item_sequence_id = bom_list.revised_item_sequence_id
            AND ri.change_notice = change_order
            AND ri.organization_id = org_id;
*/

            FOR comp_change IN c_comp_change(
                                   bom_list.scheduled_date,
                                   bom_list.bill_sequence_id,
                                   bom_list.from_end_item_unit_number) LOOP

                --get lookup values
                l_component_item_name := Get_Item_Name(comp_change.component_item_id, org_id);
                l_location_name       := Get_Location_Name(comp_change.supply_locator_id);

                IF (comp_change.acd_type = ecg_action_change) THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'Preparing update of ' ||l_component_item_name||
                                                   ' on '||l_revised_item_name);
                ELSE --comp_change.acd_type = ecg_action_add
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'Preparing add of ' ||l_component_item_name||
                                                   ' to '||l_revised_item_name);
                END IF;

                l_comp_cnt := l_comp_cnt + 1;

                l_comp_tbl(l_comp_cnt).eco_name                  := change_order;
                l_comp_tbl(l_comp_cnt).organization_code         := l_org_code;
                l_comp_tbl(l_comp_cnt).new_revised_item_revision := bom_list.new_item_revision;
                l_comp_tbl(l_comp_cnt).revised_item_name         := l_revised_item_name;
                l_comp_tbl(l_comp_cnt).start_effective_date      := NVL(bom_list.scheduled_date,
                                                                        TRUNC(SYSDATE));
                --l_comp_tbl(l_comp_cnt).new_effectivity_date      :=
                IF bom_list.effectivity_control = date_control THEN
                    l_comp_tbl(l_comp_cnt).disable_date              := comp_change.disable_date;
                ELSE
                    l_comp_tbl(l_comp_cnt).disable_date              := NULL;
                END IF;
                l_comp_tbl(l_comp_cnt).operation_sequence_number := comp_change.operation_sequence_number;
                l_comp_tbl(l_comp_cnt).component_item_name       := l_component_item_name;
                l_comp_tbl(l_comp_cnt).alternate_bom_code        := l_alternate_bom_code;  -- Bug 2353962
                l_comp_tbl(l_comp_cnt).acd_type                  := comp_change.acd_type;
                l_comp_tbl(l_comp_cnt).old_effectivity_date      := comp_change.old_effectivity_date;
                l_comp_tbl(l_comp_cnt).old_operation_sequence_number := comp_change.old_operation_sequence_number;
                l_comp_tbl(l_comp_cnt).new_operation_sequence_number := comp_change.new_operation_sequence_number;
                l_comp_tbl(l_comp_cnt).item_sequence_number      := comp_change.item_num;
                l_comp_tbl(l_comp_cnt).basis_type                := comp_change.basis_type;
                l_comp_tbl(l_comp_cnt).quantity_per_assembly     := comp_change.component_quantity;
                l_comp_tbl(l_comp_cnt).planning_percent          := comp_change.planning_factor;
                l_comp_tbl(l_comp_cnt).projected_yield           := comp_change.component_yield_factor;
                l_comp_tbl(l_comp_cnt).include_in_cost_rollup    := comp_change.include_in_cost_rollup;
                l_comp_tbl(l_comp_cnt).wip_supply_type           := comp_change.wip_supply_type;
                l_comp_tbl(l_comp_cnt).so_basis                  := comp_change.so_basis;
                l_comp_tbl(l_comp_cnt).optional                  := comp_change.optional;
                l_comp_tbl(l_comp_cnt).mutually_exclusive := comp_change.mutually_exclusive_options;
                l_comp_tbl(l_comp_cnt).check_atp                 := comp_change.check_atp;
                l_comp_tbl(l_comp_cnt).shipping_allowed          := comp_change.shipping_allowed;
                l_comp_tbl(l_comp_cnt).required_to_ship          := comp_change.required_to_ship;
                l_comp_tbl(l_comp_cnt).required_for_revenue      := comp_change.required_for_revenue;
                l_comp_tbl(l_comp_cnt).include_on_ship_docs      := comp_change.include_on_ship_docs;
                l_comp_tbl(l_comp_cnt).quantity_related          := comp_change.quantity_related;
                l_comp_tbl(l_comp_cnt).supply_subinventory       := comp_change.supply_subinventory;
                l_comp_tbl(l_comp_cnt).location_name             := l_location_name;
                l_comp_tbl(l_comp_cnt).minimum_allowed_quantity  := comp_change.low_quantity;
                l_comp_tbl(l_comp_cnt).maximum_allowed_quantity  := comp_change.high_quantity;
                IF bom_list.effectivity_control = unit_control THEN
                    l_comp_tbl(l_comp_cnt).old_from_end_item_unit_number := comp_change.old_from_end_item_unit_number;
                    l_comp_tbl(l_comp_cnt).from_end_item_unit_number := comp_change.from_end_item_unit_number;
                    l_comp_tbl(l_comp_cnt).to_end_item_unit_number   := comp_change.to_end_item_unit_number;
                ELSE
                    l_comp_tbl(l_comp_cnt).old_from_end_item_unit_number := NULL;
                    l_comp_tbl(l_comp_cnt).from_end_item_unit_number := NULL;
                    l_comp_tbl(l_comp_cnt).to_end_item_unit_number   := NULL;
                END IF;
                l_comp_tbl(l_comp_cnt).new_routing_revision      := NULL;
                l_comp_tbl(l_comp_cnt).return_status             := NULL;
                l_comp_tbl(l_comp_cnt).transaction_type          := 'CREATE';
                l_comp_tbl(l_comp_cnt).comments                  := Comp_Change.Component_Remarks;  --* Modified for Bug-3347094

-- added Attribute information to resolve  BUG #2784395
    l_comp_tbl(l_comp_cnt).attribute_category  := comp_change.attribute_category;
    l_comp_tbl(l_comp_cnt).attribute1    := comp_change.attribute1;
    l_comp_tbl(l_comp_cnt).attribute2                := comp_change.attribute2;
    l_comp_tbl(l_comp_cnt).attribute3                := comp_change.attribute3;
    l_comp_tbl(l_comp_cnt).attribute4                := comp_change.attribute4;
    l_comp_tbl(l_comp_cnt).attribute5                := comp_change.attribute5;
    l_comp_tbl(l_comp_cnt).attribute6                := comp_change.attribute6;
    l_comp_tbl(l_comp_cnt).attribute7                := comp_change.attribute7;
    l_comp_tbl(l_comp_cnt).attribute8                := comp_change.attribute8;
    l_comp_tbl(l_comp_cnt).attribute9                := comp_change.attribute9;
    l_comp_tbl(l_comp_cnt).attribute10               := comp_change.attribute10;
    l_comp_tbl(l_comp_cnt).attribute11               := comp_change.attribute11;
    l_comp_tbl(l_comp_cnt).attribute12               := comp_change.attribute12;
    l_comp_tbl(l_comp_cnt).attribute13               := comp_change.attribute13;
    l_comp_tbl(l_comp_cnt).attribute14               := comp_change.attribute14;
    l_comp_tbl(l_comp_cnt).attribute15               := comp_change.attribute15;
-- added Attribute information to resolve BUG #2784395

            END LOOP; --comp_change

--
-- Insert component adds.  Insert defaults where mandatory columns were
-- left NULL.
--
            X_Statement_Number := '[4]';

/* replaced with cursor loop following
            INSERT INTO bom_inventory_components(
                operation_seq_num,
                component_item_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                item_num,
                component_quantity,
                component_yield_factor,
                effectivity_date,
                disable_date,
                change_notice,
                component_remarks,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                planning_factor,
                quantity_related,
                so_basis,
                optional,
                mutually_exclusive_options,
                include_in_cost_rollup,
                check_atp,
                shipping_allowed,
                required_to_ship,
                required_for_revenue,
                include_on_ship_docs,
                low_quantity,
                high_quantity,
                acd_type,
                old_component_sequence_id,
                component_sequence_id,
                bill_sequence_id,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                wip_supply_type,
                supply_subinventory,
                supply_locator_id,
                revised_item_sequence_id,
                bom_item_type)
            SELECT  NVL(i.operation_seq_num, default_operation_seq_num),
                    i.component_item_id,
                    SYSDATE,
                    r.last_updated_by,
                    SYSDATE,
                    r.created_by,
                    r.last_update_login,
                    i.item_num,
                    NVL(i.component_quantity, default_component_quantity),
                    NVL(i.component_yield_factor,
                        default_component_yield_factor),
                    NVL(r.scheduled_date,SYSDATE),
                    GREATEST(r.scheduled_date, i.disable_date),
                    r.change_notice,
                    i.component_remarks,
                    i.attribute_category,
                    i.attribute1,
                    i.attribute2,
                    i.attribute3,
                    i.attribute4,
                    i.attribute5,
                    i.attribute6,
                    i.attribute7,
                    i.attribute8,
                    i.attribute9,
                    i.attribute10,
                    i.attribute11,
                    i.attribute12,
                    i.attribute13,
                    i.attribute14,
                    i.attribute15,
                    NVL(i.planning_factor, default_planning_factor),
                    NVL(i.quantity_related, default_quantity_related),
                    i.so_basis,
                    i.optional,
                    i.mutually_exclusive_options,
                    NVL(i.include_in_cost_rollup,
                        default_include_in_cost_rollup),
                    NVL(i.check_atp, default_check_atp),
                    i.shipping_allowed,
                    i.required_to_ship,
                    i.required_for_revenue,
                    i.include_on_ship_docs,
                    i.low_quantity,
                    i.high_quantity,
                    ecg_action_add,
                    bom_inventory_components_s.NEXTVAL,
                    bom_inventory_components_s.CURRVAL,
                    r.bill_sequence_id,
                    r.request_id,
                    r.program_application_id,
                    r.program_id,
                    SYSDATE,
                    i.wip_supply_type,
                    i.supply_subinventory,
                    i.supply_locator_id,
                    r.revised_item_sequence_id,
                    itm.bom_item_type
            FROM    mtl_system_items_b itm,
                    bom_inventory_comps_interface i,
                    eng_revised_items_interface ri,
                    eng_revised_items r
            WHERE   r.revised_item_sequence_id =
                    bom_list.revised_item_sequence_id
            AND     i.acd_type = action_add
            AND     itm.inventory_item_id = i.component_item_id
            AND     itm.organization_id = r.organization_id
            AND     ri.revised_item_sequence_id = i.revisedeco_name
            AND     ri.change_notice = change_order
            AND     ri.organization_id = org_id;
*/

            FOR comp_add IN c_comp_add(bom_list.bill_sequence_id) LOOP

                --get lookup values
                l_component_item_name := Get_Item_Name(comp_add.component_item_id, org_id);
                l_location_name       := Get_Location_Name(comp_add.supply_locator_id);

                FND_FILE.PUT_LINE(FND_FILE.LOG,'Preparing add of ' ||l_component_item_name||
                                               ' to '||l_revised_item_name);

                l_comp_cnt := l_comp_cnt + 1;

                l_comp_tbl(l_comp_cnt).eco_name                  := change_order;
                l_comp_tbl(l_comp_cnt).organization_code         := l_org_code;
                l_comp_tbl(l_comp_cnt).revised_item_name         := l_revised_item_name;
                l_comp_tbl(l_comp_cnt).new_revised_item_revision := bom_list.new_item_revision;
                l_comp_tbl(l_comp_cnt).start_effective_date      := NVL(bom_list.scheduled_date,
                                                                        TRUNC(SYSDATE));
                --l_comp_tbl(l_comp_cnt).new_effectivity_date      :=
                IF bom_list.effectivity_control = date_control THEN
                    l_comp_tbl(l_comp_cnt).disable_date              := comp_add.disable_date;
                ELSE
                    l_comp_tbl(l_comp_cnt).disable_date              := NULL;
                END IF;
                l_comp_tbl(l_comp_cnt).operation_sequence_number := comp_add.operation_seq_num;
                l_comp_tbl(l_comp_cnt).component_item_name       := l_component_item_name;
                l_comp_tbl(l_comp_cnt).alternate_bom_code        := l_alternate_bom_code;  -- Bug 2353962
                l_comp_tbl(l_comp_cnt).acd_type                  := comp_add.acd_type;
                l_comp_tbl(l_comp_cnt).old_effectivity_date      := NULL;
                l_comp_tbl(l_comp_cnt).old_operation_sequence_number := NULL;
                l_comp_tbl(l_comp_cnt).new_operation_sequence_number := NULL;
                l_comp_tbl(l_comp_cnt).item_sequence_number      := comp_add.item_num;
                l_comp_tbl(l_comp_cnt).basis_type                := comp_add.basis_type;
                l_comp_tbl(l_comp_cnt).quantity_per_assembly     := comp_add.component_quantity;
                l_comp_tbl(l_comp_cnt).planning_percent          := comp_add.planning_factor;
                l_comp_tbl(l_comp_cnt).projected_yield           := comp_add.component_yield_factor;
                l_comp_tbl(l_comp_cnt).include_in_cost_rollup    := comp_add.include_in_cost_rollup;
                l_comp_tbl(l_comp_cnt).wip_supply_type           := comp_add.wip_supply_type;
                l_comp_tbl(l_comp_cnt).so_basis                  := comp_add.so_basis;
                l_comp_tbl(l_comp_cnt).optional                  := comp_add.optional;
                l_comp_tbl(l_comp_cnt).mutually_exclusive := comp_add.mutually_exclusive_options;
                l_comp_tbl(l_comp_cnt).check_atp                 := comp_add.check_atp;
                l_comp_tbl(l_comp_cnt).shipping_allowed          := comp_add.shipping_allowed;
                l_comp_tbl(l_comp_cnt).required_to_ship          := comp_add.required_to_ship;
                l_comp_tbl(l_comp_cnt).required_for_revenue      := comp_add.required_for_revenue;
                l_comp_tbl(l_comp_cnt).include_on_ship_docs      := comp_add.include_on_ship_docs;
                l_comp_tbl(l_comp_cnt).quantity_related          := comp_add.quantity_related;
                l_comp_tbl(l_comp_cnt).supply_subinventory       := comp_add.supply_subinventory;
                l_comp_tbl(l_comp_cnt).location_name             := l_location_name;
                l_comp_tbl(l_comp_cnt).minimum_allowed_quantity  := comp_add.low_quantity;
                l_comp_tbl(l_comp_cnt).maximum_allowed_quantity  := comp_add.high_quantity;
                l_comp_tbl(l_comp_cnt).old_from_end_item_unit_number := NULL;
                IF bom_list.effectivity_control = unit_control THEN
                    l_comp_tbl(l_comp_cnt).from_end_item_unit_number := comp_add.from_end_item_unit_number;
                    l_comp_tbl(l_comp_cnt).to_end_item_unit_number   := comp_add.to_end_item_unit_number;
                ELSE
                    l_comp_tbl(l_comp_cnt).from_end_item_unit_number := NULL;
                    l_comp_tbl(l_comp_cnt).to_end_item_unit_number   := NULL;
                END IF;
                l_comp_tbl(l_comp_cnt).new_routing_revision      := NULL;
                l_comp_tbl(l_comp_cnt).return_status             := NULL;
                l_comp_tbl(l_comp_cnt).transaction_type          := 'CREATE';
                l_comp_tbl(l_comp_cnt).comments                  := Comp_Add.Component_Remarks;  --* Modified for Bug-3347094
     -- added Attribute information for BUG #2784395
    l_comp_tbl(l_comp_cnt).attribute_category  := comp_add.attribute_category;
    l_comp_tbl(l_comp_cnt).attribute1    := comp_add.attribute1;
    l_comp_tbl(l_comp_cnt).attribute2                := comp_add.attribute2;
    l_comp_tbl(l_comp_cnt).attribute3                := comp_add.attribute3;
    l_comp_tbl(l_comp_cnt).attribute4                := comp_add.attribute4;
    l_comp_tbl(l_comp_cnt).attribute5                := comp_add.attribute5;
    l_comp_tbl(l_comp_cnt).attribute6                := comp_add.attribute6;
    l_comp_tbl(l_comp_cnt).attribute7                := comp_add.attribute7;
    l_comp_tbl(l_comp_cnt).attribute8                := comp_add.attribute8;
    l_comp_tbl(l_comp_cnt).attribute9                := comp_add.attribute9;
    l_comp_tbl(l_comp_cnt).attribute10               := comp_add.attribute10;
    l_comp_tbl(l_comp_cnt).attribute11               := comp_add.attribute11;
    l_comp_tbl(l_comp_cnt).attribute12               := comp_add.attribute12;
    l_comp_tbl(l_comp_cnt).attribute13               := comp_add.attribute13;
    l_comp_tbl(l_comp_cnt).attribute14               := comp_add.attribute14;
    l_comp_tbl(l_comp_cnt).attribute15               := comp_add.attribute15;
     -- added Attribute information for BUG #2784395
            END LOOP; --comp_add

/* --not needed since no inserts being done
            EXCEPTION
                WHEN Dup_Val_On_Index THEN
                    DELETE FROM bom_inventory_components
                    WHERE revised_item_sequence_id = bom_list.revised_item_sequence_id;
                    DELETE FROM eng_current_scheduled_dates
                    WHERE revised_item_sequence_id = bom_list.revised_item_sequence_id;
                    DELETE FROM eng_revised_items
                    WHERE revised_item_sequence_id = bom_list.revised_item_sequence_id;
                    DELETE FROM mtl_item_revisions
                    WHERE revised_item_sequence_id = bom_list.revised_item_sequence_id;
            END; -- single revised item
*/

 /* Fix for bug 5083488- Populate Ref Desgs records also.*/
      For add_ref_desg in c_add_ref_Desg(
                        bom_list.bill_sequence_id,
                        bom_list.scheduled_date,
                        bom_list.from_end_item_unit_number) LOOP

    l_component_item_name := Get_Item_Name(add_ref_Desg.component_item_id, org_id);
    l_ref_count := l_ref_count + 1;

    l_ref_designator_tbl(l_ref_count).eco_name := change_order;
    l_ref_designator_tbl(l_ref_count).organization_code := l_org_code;
    l_ref_designator_tbl(l_ref_count).new_revised_item_revision := bom_list.new_item_revision;
    l_ref_designator_tbl(l_ref_count).revised_item_name := l_revised_item_name;
    l_ref_designator_tbl(l_ref_count).start_effective_date := NVL(bom_list.scheduled_date,
                                                                        TRUNC(SYSDATE));
    l_ref_designator_tbl(l_ref_count).operation_sequence_number := add_ref_Desg.operation_sequence_number;
    l_ref_designator_tbl(l_ref_count).Component_Item_Name := l_component_item_name;
    l_ref_designator_tbl(l_ref_count).alternate_bom_code := l_alternate_bom_code;
    l_ref_designator_tbl(l_ref_count).Reference_Designator_Name := add_ref_Desg.reference_designator_name;
    l_ref_designator_tbl(l_ref_count).acd_type := add_ref_Desg.acd_type;
    l_ref_designator_tbl(l_ref_count).Ref_Designator_Comment := add_ref_Desg.Ref_Designator_Comment;
    l_ref_designator_tbl(l_ref_count).Attribute_category := add_ref_Desg.Attribute_category;
    l_ref_designator_tbl(l_ref_count).attribute1 := add_ref_Desg.Attribute1;
    l_ref_designator_tbl(l_ref_count).attribute2 := add_ref_Desg.Attribute2;
    l_ref_designator_tbl(l_ref_count).attribute3 := add_ref_Desg.Attribute3;
    l_ref_designator_tbl(l_ref_count).attribute4 := add_ref_Desg.Attribute4;
    l_ref_designator_tbl(l_ref_count).attribute5 := add_ref_Desg.Attribute5;
    l_ref_designator_tbl(l_ref_count).Attribute6 := add_ref_Desg.Attribute6;
    l_ref_designator_tbl(l_ref_count).Attribute7 := add_ref_Desg.Attribute7;
    l_ref_designator_tbl(l_ref_count).Attribute8 := add_ref_Desg.Attribute8;
    l_ref_designator_tbl(l_ref_count).Attribute9 := add_ref_Desg.Attribute9;
    l_ref_designator_tbl(l_ref_count).Attribute10 := add_ref_Desg.Attribute10;
    l_ref_designator_tbl(l_ref_count).Attribute11 := add_ref_Desg.Attribute11;
    l_ref_designator_tbl(l_ref_count).Attribute12 := add_ref_Desg.Attribute12;
    l_ref_designator_tbl(l_ref_count).Attribute13 := add_ref_Desg.Attribute13;
    l_ref_designator_tbl(l_ref_count).Attribute14 := add_ref_Desg.Attribute14;
    l_ref_designator_tbl(l_ref_count).Attribute15 := add_ref_Desg.Attribute15;
    l_ref_designator_tbl(l_ref_count).New_Routing_Revision := NULL;
    l_ref_designator_tbl(l_ref_count).Return_Status := NULL;
    l_ref_designator_tbl(l_ref_count).Transaction_Type := 'CREATE';
      End Loop; -- add_ref_Desg
  /* End of fix for bug 5083488. */

        END LOOP; -- revised items

        --Only call business object if there are some components
        -- Commenting this IF condition to retain the old functionality
        -- in 11.5.5.  Refer bug 3823876 FP fix for 3762086.
        -- IF (l_comp_cnt > 0) THEN

            ENG_GLOBALS.g_who_rec.org_id     := org_id;
            ENG_GLOBALS.g_who_rec.user_id    := FND_PROFILE.value('USER_ID');
            ENG_GLOBALS.g_who_rec.login_id   := FND_PROFILE.value('LOGIN_ID');
            ENG_GLOBALS.g_who_rec.prog_appid := FND_PROFILE.value('RESP_APPL_ID');
            ENG_GLOBALS.g_who_rec.prog_id    := NULL;
            ENG_GLOBALS.g_who_rec.req_id     := NULL;

            FND_GLOBAL.apps_initialize(user_id      => ENG_GLOBALS.g_who_rec.user_id,
                                       resp_id      => FND_PROFILE.value('RESP_ID'),
                                       resp_appl_id => ENG_GLOBALS.g_who_rec.prog_appid
                                       );

            --Initializing the Error Handler
            ERROR_HANDLER.Initialize;

            -- Set Value for Caller Type
            BOM_GLOBALS.Set_Caller_Type(BOM_GLOBALS.G_MASS_CHANGE);

            --Now call the Business Object to process the ECOs
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing ECO');
            ENG_ECO_PUB.Process_Eco(p_api_version_number   => 1.0
                                ,   p_init_msg_list        => FALSE
                                ,   x_return_status        => l_return_status
                                ,   x_msg_count            => l_msg_cnt
                                ,   p_bo_identifier        => 'ECO'
                                ,   p_eco_rec              => l_eco_rec
                                --,   p_eco_revision_tbl     => l_rev_tbl              --empty
                                ,   p_revised_item_tbl     => l_item_tbl
                                ,   p_rev_component_tbl    => l_comp_tbl
                                ,   p_ref_designator_tbl   => l_ref_designator_tbl /* Fix for bug 5083488 - Pass ref degs also */
                                --,   p_sub_component_tbl    => l_sub_component_tbl    --empty
                                --,   p_rev_operation_tbl    => l_rev_operation_tbl    --empty
                                --,   p_rev_op_resource_tbl  => l_rev_op_resource_tbl  --empty
                                --,   p_rev_sub_resource_tbl => l_rev_sub_resource_tbl --empty
                                ,   x_ECO_rec              => l_eco_rec
                                ,   x_eco_revision_tbl     => l_rev_tbl
                                ,   x_revised_item_tbl     => l_item_tbl
                                ,   x_rev_component_tbl    => l_comp_tbl
                                ,   x_ref_designator_tbl   => l_ref_designator_tbl   --empty
                                ,   x_sub_component_tbl    => l_sub_component_tbl    --empty
                                ,   x_rev_operation_tbl    => l_rev_operation_tbl    --empty
                                ,   x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --empty
                                ,   x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --empty
                                --,   p_debug                => 'Y'
                                --,   p_output_dir           => '/sqlcom/log/v115dlyp'
                                --,   p_debug_filename       =>  'ECO_BO_Debug.log'
                                );

            IF (NVL(l_return_status,'E') <> 'S') THEN
                RAISE process_eco_error;
            END IF;

            -- ERES change begins :
            l_eres_enabled := FND_PROFILE.VALUE('EDR_ERES_ENABLED');
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Info: profile EDR_ERES_ENABLED ='||l_eres_enabled||'.');
            IF ( NVL( l_eres_enabled, 'N') = 'Y')
            THEN
              Raise_ECO_Create_Event
                 ( p_organization_id   => org_id
                 , p_organization_code => l_eco_rec.organization_code
                 , p_change_notice     => l_eco_rec.eco_name
                 , x_return_status     => l_return_status
                 , x_msg_count         => l_msg_cnt);
            END IF;  -- l_eres_enabled
            -- ERES change ends

/*  Bug 2614633 - Update change notice value and revised item sequence id in
 MTL_ITEM_REVISIONS Table for the newly created Revision by Mass change
*/

       For item in rev_item
       loop

           If (item.new_item_revision is not NULL) then

           UPDATE mtl_item_revisions_b
           SET  change_notice = change_order,
                ecn_initiation_date = SYSDATE,
                revised_item_sequence_id = item.revised_item_sequence_id
           WHERE inventory_item_id = item.revised_item_id and
                 organization_id   = item.organization_id and
                 revision          = item.new_item_revision ;

          END if;

        End loop;

/*
--
--  If Revised Item has:
--     - Check Component ATP = No
--     - Replenish to Order flag = No
--     - Pick Components flag = No
--     - WIP Supply Type not a phantom
--  set component level Check ATP to No
--
        UPDATE bom_inventory_components
        SET check_atp = no
        WHERE revised_item_sequence_id IN (
             SELECT r.revised_item_sequence_id
            FROM eng_revised_items r,
                 mtl_system_items_b i
            WHERE i.atp_components_flag = 'N'
            AND   i.pick_components_flag = 'N'
            AND   i.replenish_to_order_flag = 'N'
            AND   i.wip_supply_type <> phantom
            AND   i.inventory_item_id = r.revised_item_id
            AND   i.organization_id = r.organization_id
            AND   r.change_notice = change_order
            AND   r.organization_id = org_id);

--
-- Check ATP must be No if component quantity <= 0
--
        UPDATE bom_inventory_components
        SET check_atp = no
        WHERE component_sequence_id IN (
            SELECT component_sequence_id
            FROM bom_inventory_components c,
                 eng_revised_items r
            WHERE r.change_notice = change_order
            AND   r.organization_id = org_id
            AND   r.revised_item_sequence_id = c.revised_item_sequence_id
            AND   c.component_quantity <= 0);

--
--     Y = Allowed  N = Not Allowed
--     P = Must be Phantom  O = Must be Optional
--     Configured items are ATO standard items that have a base item id.
--     ATO items have Replenish to Order flags set to "Y".
--     PTO items have Pick Component flags set to "Y".
--
--                                     Parent
-- Child         |Config  ATO Mdl  ATO Opt  ATO Std  PTO Mdl  PTO Opt  PTO Std
-- ---------------------------------------------------------------------------
-- Planning      |   N       N        N        N        N        N        N
-- Configured    |   Y       Y        Y        Y        Y        Y        N
-- ATO Model     |   P       P        P        N        P        P        N
-- ATO Opt Class |   P       P        P        N        N        N        N
-- ATO Standard  |   Y       Y        Y        Y        O        O        N
-- PTO Model     |   N       N        N        N        P        P        N
-- PTO Opt Class |   N       N        N        N        P        P        N
-- PTO Standard  |   N       N        N        N        Y        Y        Y
--
-- NOTE:  "Not Allowed" is handled by a delete statement in procedure
--        Check_Combination above.
--
        UPDATE bom_inventory_components
        SET wip_supply_type = phantom
        WHERE component_sequence_id IN (
            SELECT c.component_sequence_id
            FROM mtl_system_items_b i,
                 mtl_system_items_b ci,
                 bom_inventory_components c,
                 eng_revised_items r
            WHERE ci.bom_item_type IN (model_type, option_class_type)
            AND   ci.inventory_item_id = c.component_item_id
            AND   ci.organization_id = r.organization_id
            AND   c.revised_item_sequence_id = r.revised_item_sequence_id
            AND   i.inventory_item_id = r.revised_item_id
            AND   i.organization_id = r.organization_id
            AND   r.change_notice = change_order
            AND   r.organization_id = org_id);

        UPDATE bom_inventory_components
        SET optional = yes
        WHERE component_sequence_id IN (
            SELECT c.component_sequence_id
            FROM mtl_system_items_b i,
                 mtl_system_items_b ci,
                 bom_inventory_components c,
                 eng_revised_items r
            WHERE ci.base_item_id IS NULL
            AND   ci.replenish_to_order_flag = 'Y'
            AND   ci.bom_item_type = standard_type
            AND   i.pick_components_flag = 'Y'
            AND   i.bom_item_type IN (model_type, option_class_type)
            AND   ci.inventory_item_id = c.component_item_id
            AND   ci.organization_id = r.organization_id
            AND   c.revised_item_sequence_id = r.revised_item_sequence_id
            AND   i.inventory_item_id = r.revised_item_id
            AND   i.organization_id = r.organization_id
            AND   r.change_notice = change_order
            AND   r.organization_id = org_id);
*/

        --END IF; --processed -- Commented IF. Bug 3823876.

        IF delete_mco = yes THEN

            DELETE FROM bom_inventory_comps_interface
            WHERE  revised_item_sequence_id IN
                (SELECT revised_item_sequence_id
                 FROM   eng_revised_items_interface
                 WHERE  change_notice = change_order
                 AND    organization_id = org_id);

            DELETE FROM eng_revised_items_interface
            WHERE  change_notice = change_order
            AND    organization_id = org_id;

            DELETE FROM eng_eng_changes_interface
            WHERE  change_notice = change_order
            AND    organization_id = org_id;

        END IF; --delete_eco

    END LOOP; --eco_rec

    COMMIT;

    BEGIN

  ENG_CHANGE_TEXT_UTIL.Sync_Index ( p_idx_name => 'ENG_CHANGE_IMTEXT_TL_CTX1' );

    EXCEPTION

  WHEN others THEN
    error_message := 'Error in ENG_CHANGE_TEXT_UTIL.Sync_index';
    FND_FILE.PUT_LINE(FND_FILE.LOG,error_message);
    END;

    error_message := NULL;

EXCEPTION

    WHEN list_error THEN
        error_message := list_error_msg;
        FND_FILE.PUT_LINE(FND_FILE.LOG,error_message);

    WHEN revision_error THEN
        ROLLBACK TO begin_mass_update;
        error_message := rev_error_msg;
        FND_FILE.PUT_LINE(FND_FILE.LOG,error_message);

    WHEN process_eco_error THEN
        ROLLBACK TO begin_mass_update;
        Error_Handler.Get_Message_List( x_message_list  => l_error_tbl);
        i:=0;
        FOR i IN 1..l_error_tbl.COUNT LOOP
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Entity Id: '||l_error_tbl(i).entity_id);
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Index: '||l_error_tbl(i).entity_index);
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Mesg: '||l_error_tbl(i).message_text);
        END LOOP;
        error_message := 'Error processing ECO Business Object';
        FND_FILE.PUT_LINE(FND_FILE.LOG,error_message);

    WHEN others THEN
        error_message := X_Statement_Number||SUBSTRB(sqlerrm, 1, 150);
        FND_FILE.PUT_LINE(FND_FILE.LOG,error_message);
        ROLLBACK TO begin_mass_update;

END mass_update;

END BOMPKMUD;

/
