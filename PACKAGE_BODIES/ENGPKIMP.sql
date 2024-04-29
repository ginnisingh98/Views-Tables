--------------------------------------------------------
--  DDL for Package Body ENGPKIMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENGPKIMP" as
/* $Header: ENGEIMPB.pls 120.51.12010000.8 2010/08/03 20:31:41 umajumde ship $ */

--##########################################################################
--  HISTORY :
--
-- Sept-2003     odaboval  ERES_Project.
--                     Raise child events of ERES parent event ecoImplement:
--                     - copyToManufacturing
--                     - transferToManufacturing
--                     - billCreate or billUpdate
--                     - routingCreate or routingC=Update.
--                     These event are not attached to the parent if
--                     it doesn't exist.
--                     Created local procedure event_acknowledgement for
--                      acknowledging the events in case of error.
--
-- Oct-2003      odaboval set the ERES calls as 8i Compliant.
-- 06/29/04               Added parameter p_revised_item_seq_id to Procedure
--                        LOG_IMPLEMENT_FAILURE
--
-- Jul-2004      odaboval bug 3741444, added flag bERES_Flag_for_BOM.
-- Dec-2004      odaboval bug 3908563, added flag bERES_Flag_for_Routing.

--##########################################################################

        cancelled_status constant number(1) := 5;
        implemented_status constant number(1) := 6;

--
--  From domain ECG_ACTION.
--
        acd_add constant number(1) := 1;
        acd_change constant number(1) := 2;
        acd_delete constant number(1) := 3;

--  Oracle Order Entry

        G_OrderEntry constant number(3) := 300;
-- set new wip job name used in creating wip_job_schedule_interface

        rev_op_disable_date_tbl      Rev_Op_Disable_Date_Tbl_Type;
        rev_comp_disable_date_tbl    Rev_Comp_Disable_Date_Tbl_Type;

------------------------------------------------------------------
-- Added for bug 3448857                                        --
-- Defining Exception if package is not found when they are     --
-- called using dynamic sql                                     --
------------------------------------------------------------------
PLSQL_COMPILE_ERROR EXCEPTION;
PRAGMA EXCEPTION_INIT(PLSQL_COMPILE_ERROR, -6550);

------------------------------------------------------
-- R12: Type declaration for Common BOM Enhancement --
------------------------------------------------------
TYPE Common_Rev_Comp_Rec_Type IS RECORD (
    Revised_Item_Sequence_Id     NUMBER
  , dest_bill_sequence_id        NUMBER
  , dest_old_comp_sequence_id    NUMBER
  , Component_sequence_id        NUMBER
  , common_component_sequence_id NUMBER
  , prev_common_comp_sequence_id NUMBER
 );
TYPE Common_Rev_Comp_Tbl_Type IS TABLE OF Common_Rev_Comp_Rec_Type
    INDEX BY BINARY_INTEGER ;
-----------------------------------------------------------------
-- R12: Global variable declaration for Common BOM Enhancement --
-----------------------------------------------------------------
g_Common_Rev_Comp_Tbl    Common_Rev_Comp_Tbl_Type;
g_common_rev_comps_cnt   NUMBER;
isCommonedBOM            VARCHAR2(1);
-----------------------------------------------------------------
-- Procedures Begin                                            --
-----------------------------------------------------------------

-- Added private procedure for bug 3584193
-- Description: The bill with unapproved items should not be allowed to be transferred through ECO.
/********************************************************************
 * API Name      : UNAPPROVED_COMPONENTS_EXISTS
 * Parameters IN : L_NEW_ASSEMBLY_ITEM_ID, VAR_ORGANIZATION_ID, VAR_SELECTION_OPTION, VAR_ALTERNATE_BOM_DESIGNATOR
 * Parameters OUT: None
 * Returns       : Boolean 'TRUE' or 'FALSE' depending on whether bill contains any un-approved items.
 * Purpose       : For an Engineering BOM to transfer to Manufacturing, the BOM should not contain any un-approved items.
 *                      This API will find if the BOM contains any un-approved items.
 *********************************************************************/
FUNCTION UNAPPROVED_COMPONENTS_EXISTS (L_NEW_ASSEMBLY_ITEM_ID IN NUMBER,
        VAR_ORGANIZATION_ID IN NUMBER,
        VAR_SELECTION_OPTION IN NUMBER,
        VAR_ALTERNATE_BOM_DESIGNATOR IN VARCHAR2)
        RETURN BOOLEAN IS
          CURSOR check_components IS
          SELECT count(1)
          FROM DUAL
          WHERE EXISTS (
          SELECT 1
          FROM bom_bill_of_materials bbom,
               bom_inventory_components bic,
         mtl_system_items msi
          WHERE bbom.assembly_item_id   = L_NEW_ASSEMBLY_ITEM_ID
          AND   bbom.organization_id    = VAR_ORGANIZATION_ID
          AND ((VAR_SELECTION_OPTION = 2 AND
                bBOM.ALTERNATE_BOM_DESIGNATOR IS NULL)
            OR (VAR_SELECTION_OPTION = 3 AND
                  bBOM.ALTERNATE_BOM_DESIGNATOR = VAR_ALTERNATE_BOM_DESIGNATOR)
            OR (VAR_SELECTION_OPTION = 1))
          AND   bic.bill_Sequence_id  = bbom.bill_sequence_id
          AND   msi.inventory_item_id  = bic.component_item_id
          AND   msi.organization_id    = VAR_ORGANIZATION_ID
          AND   nvl(msi.approval_status,'A') <> 'A');
          l_dummy number;
        BEGIN
        --FND_FILE.PUT_LINE(FND_FILE.LOG, 'ENGEIMPB.pls - in method UNAPPROVED_COMPONENTS_EXISTS');
        OPEN check_components;
        FETCH check_components INTO l_dummy;
        CLOSE check_components;
        IF l_dummy = 1 THEN
          RETURN TRUE; -- This means that there is atleast one unapproved item as component
        END IF;
        RETURN FALSE;
END UNAPPROVED_COMPONENTS_EXISTS;

  -- Added for bug 3482152
/********************************************************************
 * API Name      : check_header_impl_allowed
 * Parameters IN : p_change_id, p_status_code
 * Parameters OUT: None
 * Returns       : 'T' or 'F' depending on whether header can be promoted
 * Purpose       : For PLM ECOs checks the following to determine
 * whether header can be promoted.
 * a) Valid status
 * b) Workflow status
 * c) Mandatory tasks
 *********************************************************************/
FUNCTION check_header_impl_allowed
( p_change_id   IN NUMBER
, p_change_notice IN VARCHAR2
, p_status_code IN NUMBER
, p_curr_status_code IN NUMBER
, p_plm_or_erp_change IN VARCHAR2
, p_request_id  IN NUMBER
) RETURN VARCHAR2 IS

        l_mandatory_task_count  NUMBER;
        l_implement_header      VARCHAR2(1) := 'F';
        l_valid_phase           NUMBER;
        l_eco_impl_mode NUMBER := 0; -- implementation trigger point header

        -- cursor to check if the implementation trigger point is not the eco header
        -- i.e., either auto-implement or revised items promote action
        CURSOR c_eco_impl_mode_header IS
        SELECT 1
        FROM fnd_concurrent_requests
        WHERE request_id = p_request_id
        AND ARGUMENT4 IS NOT NULL
        AND ARGUMENT5 IS NULL;

        -- Cursor to check --
        -- if current phase of the header is the second last phase of the lifecycle of the change
        -- and if workflow is associated to the phase then , it is in completed or approved phase
        CURSOR  c_check_phase IS
        SELECT 1
        FROM eng_lifecycle_statuses els
        WHERE els.entity_id1 = p_change_id
        AND els.entity_name = 'ENG_CHANGE'
        AND els.status_code = p_curr_status_code
        AND els.active_flag = 'Y'
        AND (   1 = l_eco_impl_mode
                OR (    1 = (   SELECT count(*)
                                FROM eng_lifecycle_statuses els_in
                                WHERE els_in.entity_id1 = p_change_id
                                AND els_in.entity_name = 'ENG_CHANGE'
                                AND els_in.active_flag = 'Y'
                                AND els_in.sequence_number > els.sequence_number)
                        AND ((  els.change_wf_route_id IS NOT NULL
                                AND (   els.workflow_status = 'APPROVED'
                                        OR els.workflow_status = 'COMPLETED')
                             )
                             OR (       els.change_wf_route_id IS NULL
                                        AND els.CHANGE_WF_ROUTE_TEMPLATE_ID IS NULL)
                           )
                   )
            );


BEGIN

        IF (p_plm_or_erp_change =  'ERP')
        THEN
                l_implement_header := 'T';
                RETURN l_implement_header;
        ELSE

                OPEN c_eco_impl_mode_header;
                FETCH c_eco_impl_mode_header INTO l_eco_impl_mode;
                CLOSE c_eco_impl_mode_header;

                OPEN c_check_phase;
                FETCH c_check_phase INTO l_valid_phase;
                IF c_check_phase%NOTFOUND
                THEN
                        l_implement_header := 'F';
                        FND_FILE.NEW_LINE(FND_FILE.LOG);
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'The header of ECO '|| p_change_notice||' will not be implemented.');
                ELSE

                        l_implement_header := 'T';
                        -- check if there are any pending mandatory tasks in the ECO
                        SELECT count(1)
                        INTO l_mandatory_task_count
                        FROM eng_change_lines l,
                             eng_change_statuses s
                        WHERE l.change_id = p_change_id
                        AND s.status_code = l.status_code
                        AND l.complete_before_status_code IS NOT NULL
                        AND s.status_type NOT IN (5, 6, 11)
                        AND nvl(l.required_flag , 'Y') = 'Y';

                        IF(l_mandatory_task_count <> 0)
                        THEN
                                l_implement_header := 'F';
                                FND_FILE.NEW_LINE(FND_FILE.LOG);
                                FND_FILE.PUT_LINE(FND_FILE.LOG, 'The header of ECO '|| p_change_notice||' will not be implemented as '||
                                                                'there is at least one mandatory task which must be completed/cancelled.');
                        END IF;
                END IF;
                CLOSE c_check_phase;
                RETURN l_implement_header;
        END IF;
EXCEPTION
WHEN OTHERS THEN
        FND_FILE.NEW_LINE(FND_FILE.LOG);
        FND_FILE.PUT_LINE(FND_FILE.LOG,' Error in check_header_impl_allowed .. ' ||SQLERRM);
	--do not implement the header if validation errors out
        CLOSE c_check_phase;
        l_implement_header := 'F';
        RETURN l_implement_header;
END check_header_impl_allowed;
-- End changes for bug 3482152

-- Bug 6982970 vggarg code added for business event start
-- Internal procedure to raise cm status change events
  PROCEDURE Raise_Status_Change_Event
  (
    p_change_id                 IN   NUMBER
   ,p_base_cm_type_code         IN   VARCHAR2
   ,p_status_code               IN   NUMBER
   ,p_action_type               IN   VARCHAR2
   ,p_action_id                 IN   NUMBER
   )
  IS
    l_param_list                WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();

  BEGIN

    -- Adding event parameters to the list
    WF_EVENT.AddParameterToList
    ( p_name          => ENG_CHANGE_BES_UTIL.G_BES_PARAM_CHANGE_ID
     ,p_value         => to_char(p_change_id)
     ,p_parameterList => l_param_list
     );
    WF_EVENT.AddParameterToList
    ( p_name          => ENG_CHANGE_BES_UTIL.G_BES_PARAM_BASE_CM_TYPE_CODE
     ,p_value         => p_base_cm_type_code
     ,p_parameterList => l_param_list
     );
    WF_EVENT.AddParameterToList
    ( p_name          => ENG_CHANGE_BES_UTIL.G_BES_PARAM_STATUS_CODE
     ,p_value         => to_char(p_status_code)
     ,p_parameterList => l_param_list
     );
    WF_EVENT.AddParameterToList
    ( p_name          => ENG_CHANGE_BES_UTIL.G_BES_PARAM_ACT_TYPE_CODE
     ,p_value         => p_action_type
     ,p_parameterList => l_param_list
     );
    WF_EVENT.AddParameterToList
    ( p_name          => ENG_CHANGE_BES_UTIL.G_BES_PARAM_ACTION_ID
     ,p_value         => to_char(p_action_id)
     ,p_parameterList => l_param_list
     );

    -- Raise event
    WF_EVENT.RAISE
    ( p_event_name    => ENG_CHANGE_BES_UTIL.G_CMBE_HEADER_CHG_STATUS
     ,p_event_key     => p_change_id
     ,p_parameters    => l_param_list
     );
    l_param_list.DELETE;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END Raise_Status_Change_Event;
-- Bug 6982970 vggarg end


-- Code changes for enhancement 6084027 start
   PROCEDURE LOG_IMPLEMENT_FAILURE(p_change_notice IN VARCHAR2
                                   ,p_org_id IN NUMBER
                                  , p_revised_item_seq_id IN NUMBER
                                 )
   IS
   l_change_id NUMBER;
   BEGIN
     SELECT change_id INTO l_change_id FROM eng_engineering_changes WHERE change_notice = p_change_notice AND
                                                               organization_id = p_org_id;
     LOG_IMPLEMENT_FAILURE(l_change_id, p_revised_item_seq_id);
   END;
   -- Code changes for enhancement 6084027 end


--   Added for bug 6157001
PROCEDURE Chk_GDSN_SingleRow_Chgs_Exist ( p_change_line_id IN NUMBER,
                                     p_attr_group_id IN NUMBER,
                                     x_can_implement_status OUT NOCOPY VARCHAR2
                                        )
IS
  l_single_changes_count NUMBER;
  l_multi_changes_count NUMBER;
  l_inventory_item_id NUMBER;
  l_org_id NUMBER;
  l_single_gdsn_item_prod_rec EGO_ITEM_GTN_ATTRS_VL%ROWTYPE;
  l_single_gdsn_item_pend_rec EGO_GTN_ATTR_CHG_VL%ROWTYPE;
  l_multi_gdsn_item_prod_rec EGO_ITEM_GTN_ATTRS_VL%ROWTYPE;
  l_multi_gdsn_item_pend_rec EGO_GTN_MUL_ATTR_CHG_VL%ROWTYPE;
  abort_implementation exception;

  CURSOR cur_gdsn_singlerow_attr_grps IS
     SELECT attr_group_id, attr_group_name FROM ego_attr_groups_v WHERE attr_group_type='EGO_ITEM_GTIN_ATTRS' AND application_id=431;

BEGIN
  l_single_changes_count := 0;
  l_multi_changes_count := 0;

  -- First Check if there are any pending changes for gdsn single or multi row attrs done through the change order.
  SELECT count(*) INTO l_single_changes_count FROM ego_gtn_attr_chg_vl WHERE change_line_id = p_change_line_id AND implementation_date IS NULL;
  SELECT count(*) INTO l_multi_changes_count FROM ego_gtn_mul_attr_chg_vl WHERE change_line_id = p_change_line_id AND implementation_date IS NULL;
  -- If there are no gdsn single or multi row attrs changes return
  IF l_single_changes_count = 0 AND l_multi_changes_count = 0 THEN
     x_can_implement_status := 'YES';
     RETURN;
  END IF;

  SELECT revised_item_id, organization_id
  INTO l_inventory_item_id, l_org_id
  FROM eng_revised_items
  WHERE revised_item_sequence_id = p_change_line_id;

  -- If gdsn single row changes exists
  IF l_single_changes_count > 0 THEN
       -- Get the pending and production rows for comparision
       SELECT * INTO l_single_gdsn_item_pend_rec FROM ego_gtn_attr_chg_vl WHERE change_line_id = p_change_line_id;
       SELECT * INTO l_single_gdsn_item_prod_rec FROM ego_item_gtn_attrs_vl WHERE inventory_item_id = l_inventory_item_id AND organization_id = l_org_id;

       FOR single_attr_grps_cur IN cur_gdsn_singlerow_attr_grps
       LOOP

          --   Check if there are any pending changes done for this attribute group
          --   Trade_Item_Description   GDSN Single Row Attribute Group
          IF single_attr_grps_cur.attr_group_id = p_attr_group_id AND single_attr_grps_cur.attr_group_name = 'Trade_Item_Description' THEN
               IF (NVL(l_single_gdsn_item_pend_rec.BRAND_NAME, NVL(l_single_gdsn_item_prod_rec.BRAND_NAME,'!')) <> NVL(l_single_gdsn_item_prod_rec.BRAND_NAME,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.BRAND_OWNER_GLN, NVL(l_single_gdsn_item_prod_rec.BRAND_OWNER_GLN,'!')) <> NVL(l_single_gdsn_item_prod_rec.BRAND_OWNER_GLN,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.BRAND_OWNER_NAME, NVL(l_single_gdsn_item_prod_rec.BRAND_OWNER_NAME,'!')) <> NVL(l_single_gdsn_item_prod_rec.BRAND_OWNER_NAME,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.DESCRIPTION_SHORT, NVL(l_single_gdsn_item_prod_rec.DESCRIPTION_SHORT,'!')) <> NVL(l_single_gdsn_item_prod_rec.DESCRIPTION_SHORT,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.EANUCC_CODE, NVL(l_single_gdsn_item_prod_rec.EANUCC_CODE,'!')) <> NVL(l_single_gdsn_item_prod_rec.EANUCC_CODE,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.EANUCC_TYPE, NVL(l_single_gdsn_item_prod_rec.EANUCC_TYPE,'!')) <> NVL(l_single_gdsn_item_prod_rec.EANUCC_TYPE,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.FUNCTIONAL_NAME, NVL(l_single_gdsn_item_prod_rec.FUNCTIONAL_NAME,'!')) <> NVL(l_single_gdsn_item_prod_rec.FUNCTIONAL_NAME,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.INVOICE_NAME, NVL(l_single_gdsn_item_prod_rec.INVOICE_NAME,'!')) <> NVL(l_single_gdsn_item_prod_rec.INVOICE_NAME,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.IS_BARCODE_SYMBOLOGY_DERIVABLE, NVL(l_single_gdsn_item_prod_rec.IS_BARCODE_SYMBOLOGY_DERIVABLE,'!')) <> NVL(l_single_gdsn_item_prod_rec.IS_BARCODE_SYMBOLOGY_DERIVABLE,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.SUB_BRAND, NVL(l_single_gdsn_item_prod_rec.SUB_BRAND,'!')) <> NVL(l_single_gdsn_item_prod_rec.SUB_BRAND,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.TRADE_ITEM_COUPON, NVL(l_single_gdsn_item_prod_rec.TRADE_ITEM_COUPON,-999999)) <> NVL(l_single_gdsn_item_prod_rec.TRADE_ITEM_COUPON,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.TRADE_ITEM_DESCRIPTOR, NVL(l_single_gdsn_item_prod_rec.TRADE_ITEM_DESCRIPTOR,-999999)) <> NVL(l_single_gdsn_item_prod_rec.TRADE_ITEM_DESCRIPTOR,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.TRADE_ITEM_FINISH_DESCRIPTION, NVL(l_single_gdsn_item_prod_rec.TRADE_ITEM_FINISH_DESCRIPTION,'!')) <> NVL(l_single_gdsn_item_prod_rec.TRADE_ITEM_FINISH_DESCRIPTION,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.TRADE_ITEM_FORM_DESCRIPTION, NVL(l_single_gdsn_item_prod_rec.TRADE_ITEM_FORM_DESCRIPTION,'!')) <> NVL(l_single_gdsn_item_prod_rec.TRADE_ITEM_FORM_DESCRIPTION,'!'))
               THEN
                    x_can_implement_status := 'NO';
                    EXIT;
               END IF;
          END IF;   --   Trade_Item_Description

          --   Trade_Item_Measurements   GDSN Single Row Attribute Group
          IF single_attr_grps_cur.attr_group_id = p_attr_group_id AND single_attr_grps_cur.attr_group_name = 'Trade_Item_Measurements' THEN
               IF (NVL(l_single_gdsn_item_pend_rec.DIAMETER, NVL(l_single_gdsn_item_prod_rec.DIAMETER,-999999)) <> NVL(l_single_gdsn_item_prod_rec.DIAMETER,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.DRAINED_WEIGHT, NVL(l_single_gdsn_item_prod_rec.DRAINED_WEIGHT,-999999)) <> NVL(l_single_gdsn_item_prod_rec.DRAINED_WEIGHT,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.GENERIC_INGREDIENT, NVL(l_single_gdsn_item_prod_rec.GENERIC_INGREDIENT,'!')) <> NVL(l_single_gdsn_item_prod_rec.GENERIC_INGREDIENT,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.GENERIC_INGREDIENT_STRGTH, NVL(l_single_gdsn_item_prod_rec.GENERIC_INGREDIENT_STRGTH,-999999)) <> NVL(l_single_gdsn_item_prod_rec.GENERIC_INGREDIENT_STRGTH,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.GROSS_WEIGHT, NVL(l_single_gdsn_item_prod_rec.GROSS_WEIGHT,-999999)) <> NVL(l_single_gdsn_item_prod_rec.GROSS_WEIGHT,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.INGREDIENT_STRENGTH, NVL(l_single_gdsn_item_prod_rec.INGREDIENT_STRENGTH,'!')) <> NVL(l_single_gdsn_item_prod_rec.INGREDIENT_STRENGTH,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.IS_NET_CONTENT_DEC_FLAG, NVL(l_single_gdsn_item_prod_rec.IS_NET_CONTENT_DEC_FLAG,'!')) <> NVL(l_single_gdsn_item_prod_rec.IS_NET_CONTENT_DEC_FLAG,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.NET_CONTENT, NVL(l_single_gdsn_item_prod_rec.NET_CONTENT,-999999)) <> NVL(l_single_gdsn_item_prod_rec.NET_CONTENT,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.PEG_HORIZONTAL, NVL(l_single_gdsn_item_prod_rec.PEG_HORIZONTAL,-999999)) <> NVL(l_single_gdsn_item_prod_rec.PEG_HORIZONTAL,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.PEG_VERTICAL, NVL(l_single_gdsn_item_prod_rec.PEG_VERTICAL,-999999)) <> NVL(l_single_gdsn_item_prod_rec.PEG_VERTICAL,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.UOM_NET_CONTENT, NVL(l_single_gdsn_item_prod_rec.UOM_NET_CONTENT,'!')) <> NVL(l_single_gdsn_item_prod_rec.UOM_NET_CONTENT,'!'))
               THEN
                    x_can_implement_status := 'NO';
                    EXIT;
               END IF;
          END IF;   --   Trade_Item_Measurements

          --   Gtin_Unit_Indicator   GDSN Single Row Attribute Group
          IF single_attr_grps_cur.attr_group_id = p_attr_group_id AND single_attr_grps_cur.attr_group_name = 'Gtin_Unit_Indicator' THEN
               IF (NVL(l_single_gdsn_item_pend_rec.IS_TRADE_ITEM_A_CONSUMER_UNIT, NVL(l_single_gdsn_item_prod_rec.IS_TRADE_ITEM_A_CONSUMER_UNIT,'!')) <> NVL(l_single_gdsn_item_prod_rec.IS_TRADE_ITEM_A_CONSUMER_UNIT,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.IS_TRADE_ITEM_A_CONSUMER_UNIT, NVL(l_single_gdsn_item_prod_rec.IS_TRADE_ITEM_A_CONSUMER_UNIT,'!')) <> NVL(l_single_gdsn_item_prod_rec.IS_TRADE_ITEM_A_CONSUMER_UNIT,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.IS_TRADE_ITEM_A_VARIABLE_UNIT, NVL(l_single_gdsn_item_prod_rec.IS_TRADE_ITEM_A_VARIABLE_UNIT,'!')) <> NVL(l_single_gdsn_item_prod_rec.IS_TRADE_ITEM_A_VARIABLE_UNIT,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.IS_TRADE_ITEM_INFO_PRIVATE, NVL(l_single_gdsn_item_prod_rec.IS_TRADE_ITEM_INFO_PRIVATE,'!')) <> NVL(l_single_gdsn_item_prod_rec.IS_TRADE_ITEM_INFO_PRIVATE,'!'))
               THEN
                    x_can_implement_status := 'NO';
                    EXIT;
               END IF;
          END IF;   --   Gtin_Unit_Indicator

          --   Price_Date_Information   GDSN Single Row Attribute Group
          IF single_attr_grps_cur.attr_group_id = p_attr_group_id AND single_attr_grps_cur.attr_group_name = 'Price_Date_Information' THEN
               IF (NVL(l_single_gdsn_item_pend_rec.CATALOG_PRICE, NVL(l_single_gdsn_item_prod_rec.CATALOG_PRICE,-999999)) <> NVL(l_single_gdsn_item_prod_rec.CATALOG_PRICE,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.SUGGESTED_RETAIL_PRICE, NVL(l_single_gdsn_item_prod_rec.SUGGESTED_RETAIL_PRICE,-999999)) <> NVL(l_single_gdsn_item_prod_rec.SUGGESTED_RETAIL_PRICE,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.EFFECTIVE_END_DATE, NVL(l_single_gdsn_item_prod_rec.EFFECTIVE_END_DATE,to_date('''1''','''j'''))) <> NVL(l_single_gdsn_item_prod_rec.EFFECTIVE_END_DATE,to_date('''1''','''j''')))
               OR (NVL(l_single_gdsn_item_pend_rec.EFFECTIVE_START_DATE, NVL(l_single_gdsn_item_prod_rec.EFFECTIVE_START_DATE,to_date('''1''','''j'''))) <> NVL(l_single_gdsn_item_prod_rec.EFFECTIVE_START_DATE,to_date('''1''','''j''')))
               THEN
                    x_can_implement_status := 'NO';
                    EXIT;
               END IF;
          END IF;   --   Price_Date_Information

          --   Trade_Item_Hierarchy   GDSN Single Row Attribute Group
          IF single_attr_grps_cur.attr_group_id = p_attr_group_id AND single_attr_grps_cur.attr_group_name = 'Trade_Item_Hierarchy' THEN
               IF (NVL(l_single_gdsn_item_pend_rec.QUANITY_OF_ITEM_IN_LAYER, NVL(l_single_gdsn_item_prod_rec.QUANITY_OF_ITEM_IN_LAYER,-999999)) <> NVL(l_single_gdsn_item_prod_rec.QUANITY_OF_ITEM_IN_LAYER,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.QUANTITY_OF_COMP_LAY_ITEM, NVL(l_single_gdsn_item_prod_rec.QUANTITY_OF_COMP_LAY_ITEM,-999999)) <> NVL(l_single_gdsn_item_prod_rec.QUANTITY_OF_COMP_LAY_ITEM,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.QUANTITY_OF_INNER_PACK, NVL(l_single_gdsn_item_prod_rec.QUANTITY_OF_INNER_PACK,-999999)) <> NVL(l_single_gdsn_item_prod_rec.QUANTITY_OF_INNER_PACK,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.QUANTITY_OF_ITEM_INNER_PACK, NVL(l_single_gdsn_item_prod_rec.QUANTITY_OF_ITEM_INNER_PACK,-999999)) <> NVL(l_single_gdsn_item_prod_rec.QUANTITY_OF_ITEM_INNER_PACK,-999999))
               THEN
                    x_can_implement_status := 'NO';
                    EXIT;
               END IF;
          END IF;   --   Trade_Item_Hierarchy

          --   Trade_Item_Marking   GDSN Single Row Attribute Group
          IF single_attr_grps_cur.attr_group_id = p_attr_group_id AND single_attr_grps_cur.attr_group_name = 'Trade_Item_Marking' THEN
               IF (NVL(l_single_gdsn_item_pend_rec.HAS_BATCH_NUMBER, NVL(l_single_gdsn_item_prod_rec.HAS_BATCH_NUMBER,'!')) <> NVL(l_single_gdsn_item_prod_rec.HAS_BATCH_NUMBER,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.IS_NON_SOLD_TRADE_RET_FLAG, NVL(l_single_gdsn_item_prod_rec.IS_NON_SOLD_TRADE_RET_FLAG,'!')) <> NVL(l_single_gdsn_item_prod_rec.IS_NON_SOLD_TRADE_RET_FLAG,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.IS_TRADE_ITEM_MAR_REC_FLAG, NVL(l_single_gdsn_item_prod_rec.IS_TRADE_ITEM_MAR_REC_FLAG,'!')) <> NVL(l_single_gdsn_item_prod_rec.IS_TRADE_ITEM_MAR_REC_FLAG,'!'))
               THEN
                    x_can_implement_status := 'NO';
                    EXIT;
               END IF;
          END IF;   --   Trade_Item_Marking

          --   Handling_Information   GDSN Single Row Attribute Group
          IF single_attr_grps_cur.attr_group_id = p_attr_group_id AND single_attr_grps_cur.attr_group_name = 'Handling_Information' THEN
               IF (NVL(l_single_gdsn_item_pend_rec.STACKING_FACTOR, NVL(l_single_gdsn_item_prod_rec.STACKING_FACTOR,-999999)) <> NVL(l_single_gdsn_item_prod_rec.STACKING_FACTOR,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.STACKING_WEIGHT_MAXIMUM, NVL(l_single_gdsn_item_prod_rec.STACKING_WEIGHT_MAXIMUM,-999999)) <> NVL(l_single_gdsn_item_prod_rec.STACKING_WEIGHT_MAXIMUM,-999999))
               THEN
                    x_can_implement_status := 'NO';
                    EXIT;
               END IF;
          END IF;   --   Handling_Information

          --   Packaging_Marking   GDSN Single Row Attribute Group
          IF single_attr_grps_cur.attr_group_id = p_attr_group_id AND single_attr_grps_cur.attr_group_name = 'Packaging_Marking' THEN
               IF (NVL(l_single_gdsn_item_pend_rec.IS_PACKAGE_MARKED_AS_REC, NVL(l_single_gdsn_item_prod_rec.IS_PACKAGE_MARKED_AS_REC,'!')) <> NVL(l_single_gdsn_item_prod_rec.IS_PACKAGE_MARKED_AS_REC,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.IS_PACKAGE_MARKED_RET, NVL(l_single_gdsn_item_prod_rec.IS_PACKAGE_MARKED_RET,'!')) <> NVL(l_single_gdsn_item_prod_rec.IS_PACKAGE_MARKED_RET,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.IS_PACK_MARKED_WITH_EXP_DATE, NVL(l_single_gdsn_item_prod_rec.IS_PACK_MARKED_WITH_EXP_DATE,'!')) <> NVL(l_single_gdsn_item_prod_rec.IS_PACK_MARKED_WITH_EXP_DATE,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.IS_PACK_MARKED_WITH_GREEN_DOT, NVL(l_single_gdsn_item_prod_rec.IS_PACK_MARKED_WITH_GREEN_DOT,'!')) <> NVL(l_single_gdsn_item_prod_rec.IS_PACK_MARKED_WITH_GREEN_DOT,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.IS_PACK_MARKED_WITH_INGRED, NVL(l_single_gdsn_item_prod_rec.IS_PACK_MARKED_WITH_INGRED,'!')) <> NVL(l_single_gdsn_item_prod_rec.IS_PACK_MARKED_WITH_INGRED,'!'))
               THEN
                    x_can_implement_status := 'NO';
                    EXIT;
               END IF;
          END IF;   --   Packaging_Marking

          --   Temperature_Information   GDSN Single Row Attribute Group
          IF single_attr_grps_cur.attr_group_id = p_attr_group_id AND single_attr_grps_cur.attr_group_name = 'Temperature_Information' THEN
               IF (NVL(l_single_gdsn_item_pend_rec.DELIVERY_TO_MRKT_TEMP_MAX, NVL(l_single_gdsn_item_prod_rec.DELIVERY_TO_MRKT_TEMP_MAX,-999999)) <> NVL(l_single_gdsn_item_prod_rec.DELIVERY_TO_MRKT_TEMP_MAX,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.DELIVERY_TO_MRKT_TEMP_MIN, NVL(l_single_gdsn_item_prod_rec.DELIVERY_TO_MRKT_TEMP_MIN,-999999)) <> NVL(l_single_gdsn_item_prod_rec.DELIVERY_TO_MRKT_TEMP_MIN,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.DEL_TO_DIST_CNTR_TEMP_MAX, NVL(l_single_gdsn_item_prod_rec.DEL_TO_DIST_CNTR_TEMP_MAX,-999999)) <> NVL(l_single_gdsn_item_prod_rec.DEL_TO_DIST_CNTR_TEMP_MAX,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.DEL_TO_DIST_CNTR_TEMP_MIN, NVL(l_single_gdsn_item_prod_rec.DEL_TO_DIST_CNTR_TEMP_MIN,-999999)) <> NVL(l_single_gdsn_item_prod_rec.DEL_TO_DIST_CNTR_TEMP_MIN,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.STORAGE_HANDLING_TEMP_MAX, NVL(l_single_gdsn_item_prod_rec.STORAGE_HANDLING_TEMP_MAX,-999999)) <> NVL(l_single_gdsn_item_prod_rec.STORAGE_HANDLING_TEMP_MAX,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.STORAGE_HANDLING_TEMP_MIN, NVL(l_single_gdsn_item_prod_rec.STORAGE_HANDLING_TEMP_MIN,-999999)) <> NVL(l_single_gdsn_item_prod_rec.STORAGE_HANDLING_TEMP_MIN,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.UOM_DELIVERY_TO_MRKT_TEMP_MAX, NVL(l_single_gdsn_item_prod_rec.UOM_DELIVERY_TO_MRKT_TEMP_MAX,'!')) <> NVL(l_single_gdsn_item_prod_rec.UOM_DELIVERY_TO_MRKT_TEMP_MAX,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.UOM_DELIVERY_TO_MRKT_TEMP_MIN, NVL(l_single_gdsn_item_prod_rec.UOM_DELIVERY_TO_MRKT_TEMP_MIN,'!')) <> NVL(l_single_gdsn_item_prod_rec.UOM_DELIVERY_TO_MRKT_TEMP_MIN,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.UOM_DEL_TO_DIST_CNTR_TEMP_MAX, NVL(l_single_gdsn_item_prod_rec.UOM_DEL_TO_DIST_CNTR_TEMP_MAX,'!')) <> NVL(l_single_gdsn_item_prod_rec.UOM_DEL_TO_DIST_CNTR_TEMP_MAX,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.UOM_DEL_TO_DIST_CNTR_TEMP_MIN, NVL(l_single_gdsn_item_prod_rec.UOM_DEL_TO_DIST_CNTR_TEMP_MIN,'!')) <> NVL(l_single_gdsn_item_prod_rec.UOM_DEL_TO_DIST_CNTR_TEMP_MIN,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.UOM_STORAGE_HANDLING_TEMP_MAX, NVL(l_single_gdsn_item_prod_rec.UOM_STORAGE_HANDLING_TEMP_MAX,'!')) <> NVL(l_single_gdsn_item_prod_rec.UOM_STORAGE_HANDLING_TEMP_MAX,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.UOM_STORAGE_HANDLING_TEMP_MIN, NVL(l_single_gdsn_item_prod_rec.UOM_STORAGE_HANDLING_TEMP_MIN,'!')) <> NVL(l_single_gdsn_item_prod_rec.UOM_STORAGE_HANDLING_TEMP_MIN,'!'))
               THEN
                    x_can_implement_status := 'NO';
                    EXIT;
               END IF;
          END IF;   --   Temperature_Information

          --   Price_Information   GDSN Single Row Attribute Group
          IF single_attr_grps_cur.attr_group_id = p_attr_group_id AND single_attr_grps_cur.attr_group_name = 'Price_Information' THEN
               IF (NVL(l_single_gdsn_item_pend_rec.RETAIL_PRICE_ON_TRADE_ITEM, NVL(l_single_gdsn_item_prod_rec.RETAIL_PRICE_ON_TRADE_ITEM,-999999)) <> NVL(l_single_gdsn_item_prod_rec.RETAIL_PRICE_ON_TRADE_ITEM,-999999))
               THEN
                    x_can_implement_status := 'NO';
                    EXIT;
               END IF;
          END IF;   --   Price_Information

          --   Material_Safety_Data   GDSN Single Row Attribute Group
          IF single_attr_grps_cur.attr_group_id = p_attr_group_id AND single_attr_grps_cur.attr_group_name = 'Material_Safety_Data' THEN
               IF (NVL(l_single_gdsn_item_pend_rec.MATERIAL_SAFETY_DATA_SHEET_NO, NVL(l_single_gdsn_item_prod_rec.MATERIAL_SAFETY_DATA_SHEET_NO,'!')) <> NVL(l_single_gdsn_item_prod_rec.MATERIAL_SAFETY_DATA_SHEET_NO,'!'))
               THEN
                    x_can_implement_status := 'NO';
                    EXIT;
               END IF;
          END IF;   --   Material_Safety_Data

          --   Date_Information   GDSN Single Row Attribute Group
          IF single_attr_grps_cur.attr_group_id = p_attr_group_id AND single_attr_grps_cur.attr_group_name = 'Date_Information' THEN
               IF (NVL(l_single_gdsn_item_pend_rec.CANCELED_DATE, NVL(l_single_gdsn_item_prod_rec.CANCELED_DATE,to_date('''1''','''j'''))) <> NVL(l_single_gdsn_item_prod_rec.CANCELED_DATE,to_date('''1''','''j''')))
               OR (NVL(l_single_gdsn_item_pend_rec.CONSUMER_AVAIL_DATE_TIME, NVL(l_single_gdsn_item_prod_rec.CONSUMER_AVAIL_DATE_TIME,to_date('''1''','''j'''))) <> NVL(l_single_gdsn_item_prod_rec.CONSUMER_AVAIL_DATE_TIME,to_date('''1''','''j''')))
               OR (NVL(l_single_gdsn_item_pend_rec.DISCONTINUED_DATE, NVL(l_single_gdsn_item_prod_rec.DISCONTINUED_DATE,to_date('''1''','''j'''))) <> NVL(l_single_gdsn_item_prod_rec.DISCONTINUED_DATE,to_date('''1''','''j''')))
               OR (NVL(l_single_gdsn_item_pend_rec.EFFECTIVE_DATE, NVL(l_single_gdsn_item_prod_rec.EFFECTIVE_DATE,to_date('''1''','''j'''))) <> NVL(l_single_gdsn_item_prod_rec.EFFECTIVE_DATE,to_date('''1''','''j''')))
               OR (NVL(l_single_gdsn_item_pend_rec.END_AVAILABILITY_DATE_TIME, NVL(l_single_gdsn_item_prod_rec.END_AVAILABILITY_DATE_TIME,to_date('''1''','''j'''))) <> NVL(l_single_gdsn_item_prod_rec.END_AVAILABILITY_DATE_TIME,to_date('''1''','''j''')))
               OR (NVL(l_single_gdsn_item_pend_rec.START_AVAILABILITY_DATE_TIME, NVL(l_single_gdsn_item_prod_rec.START_AVAILABILITY_DATE_TIME,to_date('''1''','''j'''))) <>
                    NVL(l_single_gdsn_item_prod_rec.START_AVAILABILITY_DATE_TIME,to_date('''1''','''j''')))
               THEN
                    x_can_implement_status := 'NO';
                    EXIT;
               END IF;
          END IF;   --   Date_Information

          --   Order_Information   GDSN Single Row Attribute Group
          IF single_attr_grps_cur.attr_group_id = p_attr_group_id AND single_attr_grps_cur.attr_group_name = 'Order_Information' THEN
               IF (NVL(l_single_gdsn_item_pend_rec.ORDERING_LEAD_TIME, NVL(l_single_gdsn_item_prod_rec.ORDERING_LEAD_TIME,-999999)) <> NVL(l_single_gdsn_item_prod_rec.ORDERING_LEAD_TIME,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.ORDER_QUANTITY_MAX, NVL(l_single_gdsn_item_prod_rec.ORDER_QUANTITY_MAX,-999999)) <> NVL(l_single_gdsn_item_prod_rec.ORDER_QUANTITY_MAX,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.ORDER_QUANTITY_MIN, NVL(l_single_gdsn_item_prod_rec.ORDER_QUANTITY_MIN,-999999)) <> NVL(l_single_gdsn_item_prod_rec.ORDER_QUANTITY_MIN,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.ORDER_QUANTITY_MULTIPLE, NVL(l_single_gdsn_item_prod_rec.ORDER_QUANTITY_MULTIPLE,-999999)) <> NVL(l_single_gdsn_item_prod_rec.ORDER_QUANTITY_MULTIPLE,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.ORDER_SIZING_FACTOR, NVL(l_single_gdsn_item_prod_rec.ORDER_SIZING_FACTOR,-999999)) <> NVL(l_single_gdsn_item_prod_rec.ORDER_SIZING_FACTOR,-999999))
               THEN
                    x_can_implement_status := 'NO';
                    EXIT;
               END IF;
          END IF;   --   Order_Information

          --   Uccnet_Size_Description   GDSN Single Row Attribute Group
          IF single_attr_grps_cur.attr_group_id = p_attr_group_id AND single_attr_grps_cur.attr_group_name = 'Uccnet_Size_Description' THEN
               IF (NVL(l_single_gdsn_item_pend_rec.DESCRIPTIVE_SIZE, NVL(l_single_gdsn_item_prod_rec.DESCRIPTIVE_SIZE,'!')) <> NVL(l_single_gdsn_item_prod_rec.DESCRIPTIVE_SIZE,'!'))
               THEN
                    x_can_implement_status := 'NO';
                    EXIT;
               END IF;
          END IF;   --   Uccnet_Size_Description

          --   FMCG_Measurements   GDSN Single Row Attribute Group
          IF single_attr_grps_cur.attr_group_id = p_attr_group_id AND single_attr_grps_cur.attr_group_name = 'FMCG_Measurements' THEN
               IF (NVL(l_single_gdsn_item_pend_rec.DEGREE_OF_ORIGINAL_WORT, NVL(l_single_gdsn_item_prod_rec.DEGREE_OF_ORIGINAL_WORT,'!')) <> NVL(l_single_gdsn_item_prod_rec.DEGREE_OF_ORIGINAL_WORT,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.FAT_PERCENT_IN_DRY_MATTER, NVL(l_single_gdsn_item_prod_rec.FAT_PERCENT_IN_DRY_MATTER,-999999)) <> NVL(l_single_gdsn_item_prod_rec.FAT_PERCENT_IN_DRY_MATTER,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.PERCENT_OF_ALCOHOL_BY_VOL, NVL(l_single_gdsn_item_prod_rec.PERCENT_OF_ALCOHOL_BY_VOL,-999999)) <> NVL(l_single_gdsn_item_prod_rec.PERCENT_OF_ALCOHOL_BY_VOL,-999999))
               THEN
                    x_can_implement_status := 'NO';
                    EXIT;
               END IF;
          END IF;   --   FMCG_Measurements

          --   FMCG_Measurements   GDSN Single Row Attribute Group
          IF single_attr_grps_cur.attr_group_id = p_attr_group_id AND single_attr_grps_cur.attr_group_name = 'FMCG_Measurements' THEN
               IF (NVL(l_single_gdsn_item_pend_rec.DEGREE_OF_ORIGINAL_WORT, NVL(l_single_gdsn_item_prod_rec.DEGREE_OF_ORIGINAL_WORT,'!')) <> NVL(l_single_gdsn_item_prod_rec.DEGREE_OF_ORIGINAL_WORT,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.FAT_PERCENT_IN_DRY_MATTER, NVL(l_single_gdsn_item_prod_rec.FAT_PERCENT_IN_DRY_MATTER,-999999)) <> NVL(l_single_gdsn_item_prod_rec.FAT_PERCENT_IN_DRY_MATTER,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.PERCENT_OF_ALCOHOL_BY_VOL, NVL(l_single_gdsn_item_prod_rec.PERCENT_OF_ALCOHOL_BY_VOL,-999999)) <> NVL(l_single_gdsn_item_prod_rec.PERCENT_OF_ALCOHOL_BY_VOL,-999999))
               THEN
                    x_can_implement_status := 'NO';
                    EXIT;
               END IF;
          END IF;   --   FMCG_Measurements

          --   FMCG_Identification   GDSN Single Row Attribute Group
          IF single_attr_grps_cur.attr_group_id = p_attr_group_id AND single_attr_grps_cur.attr_group_name = 'FMCG_Identification' THEN
               IF (NVL(l_single_gdsn_item_pend_rec.ISBN_NUMBER, NVL(l_single_gdsn_item_prod_rec.ISBN_NUMBER,'!')) <> NVL(l_single_gdsn_item_prod_rec.ISBN_NUMBER,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.ISSN_NUMBER, NVL(l_single_gdsn_item_prod_rec.ISSN_NUMBER,'!')) <> NVL(l_single_gdsn_item_prod_rec.ISSN_NUMBER,'!'))
               THEN
                    x_can_implement_status := 'NO';
                    EXIT;
               END IF;
          END IF;   --   FMCG_Identification

          --   FMCG_MARKING   GDSN Single Row Attribute Group
          IF single_attr_grps_cur.attr_group_id = p_attr_group_id AND single_attr_grps_cur.attr_group_name = 'FMCG_MARKING' THEN
               IF (NVL(l_single_gdsn_item_pend_rec.IS_INGREDIENT_IRRADIATED, NVL(l_single_gdsn_item_prod_rec.IS_INGREDIENT_IRRADIATED,'!')) <> NVL(l_single_gdsn_item_prod_rec.IS_INGREDIENT_IRRADIATED,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.IS_RAW_MATERIAL_IRRADIATED, NVL(l_single_gdsn_item_prod_rec.IS_RAW_MATERIAL_IRRADIATED,'!')) <> NVL(l_single_gdsn_item_prod_rec.IS_RAW_MATERIAL_IRRADIATED,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.IS_TRADE_ITEM_GENETICALLY_MOD, NVL(l_single_gdsn_item_prod_rec.IS_TRADE_ITEM_GENETICALLY_MOD,'!')) <> NVL(l_single_gdsn_item_prod_rec.IS_TRADE_ITEM_GENETICALLY_MOD,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.IS_TRADE_ITEM_IRRADIATED, NVL(l_single_gdsn_item_prod_rec.IS_TRADE_ITEM_IRRADIATED,'!')) <> NVL(l_single_gdsn_item_prod_rec.IS_TRADE_ITEM_IRRADIATED,'!'))
               THEN
                    x_can_implement_status := 'NO';
                    EXIT;
               END IF;
          END IF;   --   FMCG_MARKING

          --   Uccnet_Hardlines   GDSN Single Row Attribute Group
          IF single_attr_grps_cur.attr_group_id = p_attr_group_id AND single_attr_grps_cur.attr_group_name = 'Uccnet_Hardlines' THEN
               IF (NVL(l_single_gdsn_item_pend_rec.DEPT_OF_TRNSPRT_DANG_GOODS_NUM, NVL(l_single_gdsn_item_prod_rec.DEPT_OF_TRNSPRT_DANG_GOODS_NUM,'!')) <> NVL(l_single_gdsn_item_prod_rec.DEPT_OF_TRNSPRT_DANG_GOODS_NUM,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.IS_OUT_OF_BOX_PROVIDED, NVL(l_single_gdsn_item_prod_rec.IS_OUT_OF_BOX_PROVIDED,'!')) <> NVL(l_single_gdsn_item_prod_rec.IS_OUT_OF_BOX_PROVIDED,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.IS_TRADE_ITEM_RECALLED, NVL(l_single_gdsn_item_prod_rec.IS_TRADE_ITEM_RECALLED,'!')) <> NVL(l_single_gdsn_item_prod_rec.IS_TRADE_ITEM_RECALLED,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.MODEL_NUMBER, NVL(l_single_gdsn_item_prod_rec.MODEL_NUMBER,'!')) <> NVL(l_single_gdsn_item_prod_rec.MODEL_NUMBER,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.RETURN_GOODS_POLICY, NVL(l_single_gdsn_item_prod_rec.RETURN_GOODS_POLICY,'!')) <> NVL(l_single_gdsn_item_prod_rec.RETURN_GOODS_POLICY,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.URL_FOR_WARRANTY, NVL(l_single_gdsn_item_prod_rec.URL_FOR_WARRANTY,'!')) <> NVL(l_single_gdsn_item_prod_rec.URL_FOR_WARRANTY,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.WARRANTY_DESCRIPTION, NVL(l_single_gdsn_item_prod_rec.WARRANTY_DESCRIPTION,'!')) <> NVL(l_single_gdsn_item_prod_rec.WARRANTY_DESCRIPTION,'!'))
               OR (NVL(l_single_gdsn_item_pend_rec.NESTING_INCREMENT, NVL(l_single_gdsn_item_prod_rec.NESTING_INCREMENT,-999999)) <> NVL(l_single_gdsn_item_prod_rec.NESTING_INCREMENT,-999999))
               OR (NVL(l_single_gdsn_item_pend_rec.PIECES_PER_TRADE_ITEM, NVL(l_single_gdsn_item_prod_rec.PIECES_PER_TRADE_ITEM,-999999)) <> NVL(l_single_gdsn_item_prod_rec.PIECES_PER_TRADE_ITEM,-999999))
               THEN
                    x_can_implement_status := 'NO';
                    EXIT;
               END IF;
          END IF;   --   Uccnet_Hardlines

          --   Security_Tag   GDSN Single Row Attribute Group
          IF single_attr_grps_cur.attr_group_id = p_attr_group_id AND single_attr_grps_cur.attr_group_name = 'Security_Tag' THEN
               IF (NVL(l_single_gdsn_item_pend_rec.SECURITY_TAG_LOCATION, NVL(l_single_gdsn_item_prod_rec.SECURITY_TAG_LOCATION,'!')) <> NVL(l_single_gdsn_item_prod_rec.SECURITY_TAG_LOCATION,'!'))
               THEN
                    x_can_implement_status := 'NO';
                    EXIT;
               END IF;
          END IF;   --   Security_Tag

       END LOOP;    --   single row attr groups cursor loop
  END IF;
  IF x_can_implement_status = 'NO' THEN
     RETURN;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     x_can_implement_status := 'NO';
     RAISE abort_implementation;

END Chk_GDSN_SingleRow_Chgs_Exist;

PROCEDURE Can_Implement_Item ( p_change_line_id IN NUMBER,
                               x_implementation_status OUT NOCOPY VARCHAR2
                             )
IS
  l_org_id NUMBER;
  l_inventory_item_id NUMBER;
  l_item_catalog_cat_id NUMBER;
  l_item_lifecycle_id NUMBER;
  l_item_current_phase_id NUMBER;
  l_current_attr_group_id NUMBER;
  l_can_implement_status VARCHAR2(30);
  l_pending_changes_count NUMBER;
  l_attribute_group_type VARCHAR2(50);
  l_concatenated_segments VARCHAR2(100);
  abort_implementation exception;

     Cursor cur_item_change_not_allowed IS
          SELECT pv.policy_char_value, r.attribute_number_value, ra.attribute_code
          FROM eng_change_policies p, eng_change_policy_values pv, eng_change_rules r, eng_change_rule_attributes_vl ra
          WHERE p.policy_object_pk1_value = l_item_catalog_cat_id
          and p.policy_object_pk2_value = l_item_lifecycle_id
          and p.policy_object_pk3_value = l_item_current_phase_id
          AND pv.POLICY_CHAR_VALUE='NOT_ALLOWED'
          and pv.change_rule_id = r.change_rule_id
          and r.attribute_object_name = ra.attribute_object_name
          and r.attribute_code = ra.attribute_code
          AND p.change_policy_id = pv.change_policy_id
          AND p.policy_object_name = 'CATALOG_LIFECYCLE_PHASE'
          and p.policy_code= 'CHANGE_POLICY'
          and ra.attribute_object_name = 'EGO_CATALOG_GROUP';
BEGIN
  l_can_implement_status := 'YES';
/*
PROMOTE_DEMOTE      1
PROMOTE_DEMOTE      2
PROMOTE_DEMOTE      3
AML_RULE            1    AML
AML_RULE            2    Related Documents        ENG_RELATIONSHIP_CHANGES
STRUCTURE_TYPE
ATTRIBUTE_GROUP     id   Attr Group Id
ATTACHMENT
*/

  -- First get the item information
  SELECT revised_item_id, organization_id
  INTO l_inventory_item_id, l_org_id
  FROM eng_revised_items
  WHERE revised_item_sequence_id = p_change_line_id;
  -- Get the item details
  SELECT item_catalog_group_id, lifecycle_id, current_phase_id , concatenated_segments
  INTO l_item_catalog_cat_id, l_item_lifecycle_id, l_item_current_phase_id, l_concatenated_segments
  FROM mtl_system_items_kfv
  WHERE inventory_item_id = l_inventory_item_id
  AND organization_id = l_org_id;

  -- Check whether there are any change policies for the current phase of item at any level which are not allowed
  FOR rev_items IN cur_item_change_not_allowed
  LOOP

      IF 'ATTRIBUTE_GROUP' = rev_items.attribute_code THEN       --   Attribute Groups
          --   Get the attribute group id
          l_current_attr_group_id := rev_items.attribute_number_value;
          SELECT attr_group_type INTO l_attribute_group_type FROM ego_attr_groups_v WHERE attr_group_id = l_current_attr_group_id;

          IF l_attribute_group_type = 'EGO_ITEMMGMT_GROUP' THEN
               --   Check if there are any UDA pending changes done through this Change Order for this attribute group
               SELECT count(*) INTO l_pending_changes_count
               FROM ego_items_attrs_changes_b
               WHERE change_line_id = p_change_line_id
               AND attr_group_id = l_current_attr_group_id
	       AND data_level_id not in (43103,43104,43105);	--  Bug 6439100 Supplier datalevels change policy not supported

               IF l_pending_changes_count > 0 THEN
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cannot Implement the Revised Item '|| l_concatenated_segments || ' because there is a change policy NOT_ALLOWED on User Defined Attribute Group with Id ' || l_current_attr_group_id);
                    l_can_implement_status := 'NO';
                    EXIT;
                END IF;
          END IF;
/*
          --   Not required to check here. EGO_ITEM_PUB.process_item() API will do the change policy check
          IF l_attribute_group_type = 'EGO_MASTER_ITEMS' THEN
          END IF;
*/
          -- Check if there are item GDSN Singlerow attribute group changes
          IF l_attribute_group_type = 'EGO_ITEM_GTIN_ATTRS' THEN
               Chk_GDSN_SingleRow_Chgs_Exist(p_change_line_id => p_change_line_id,
                                        p_attr_group_id => l_current_attr_group_id,
                                        x_can_implement_status => l_can_implement_status);

               IF l_can_implement_status = 'NO' THEN
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cannot Implement the Revised Item '|| l_concatenated_segments || ' because there is a change policy NOT_ALLOWED on GDSN Singlerow Attribute Group with Id ' || l_current_attr_group_id);
                    EXIT;
                END IF;
          END IF;

          -- Check if there are item GDSN Multirow attribute group changes
          IF l_attribute_group_type = 'EGO_ITEM_GTIN_MULTI_ATTRS' THEN
               SELECT count(*) INTO l_pending_changes_count
               FROM ego_gtn_mul_attr_chg_vl
               WHERE change_line_id = p_change_line_id
               AND attr_group_id = l_current_attr_group_id
               AND implementation_date IS NULL;

               IF l_pending_changes_count > 0 THEN
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cannot Implement the Revised Item '|| l_concatenated_segments || ' because there is a change policy NOT_ALLOWED on GDSN Multirow Attribute Group with Id ' || l_current_attr_group_id);
                    l_can_implement_status := 'NO';
                    EXIT;
                END IF;
          END IF;

      END IF;  --   All Attribute groups

      --  Promote/Demote change policy check should be done for revision creation
      IF 'PROMOTE_DEMOTE' = rev_items.attribute_code AND rev_items.attribute_number_value = 3 THEN       --    New Revision for item
          --   Check whether a new revision is created with this change order for the item
          SELECT count(*) INTO l_pending_changes_count
          FROM mtl_item_revisions
          WHERE inventory_item_id = l_inventory_item_id
          AND organization_id = l_org_id
          AND revised_item_sequence_id = p_change_line_id
          AND change_notice = ( SELECT change_notice FROM eng_engineering_changes
                                   WHERE change_id in (SELECT change_id FROM eng_revised_items
                                                       WHERE revised_item_sequence_id = p_change_line_id))
          AND implementation_date IS NULL;

          IF l_pending_changes_count > 0 THEN
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cannot Implement the Revised Item '|| l_concatenated_segments || ' because there is a change policy NOT_ALLOWED on New Revision creation for the item.' );
               l_can_implement_status := 'NO';
               EXIT;
          END IF;
      END IF;

      IF 'AML_RULE' = rev_items.attribute_code AND rev_items.attribute_number_value = 1 THEN   --   AML Changes

          SELECT count(*) INTO l_pending_changes_count
          FROM ego_mfg_part_num_chgs
          WHERE change_line_id = p_change_line_id
          AND implmentation_date IS NULL;

          IF l_pending_changes_count > 0 THEN
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cannot Implement the Revised Item '|| l_concatenated_segments || ' because there is a change policy NOT_ALLOWED on AML Associations.');
               l_can_implement_status := 'NO';
               EXIT;
           END IF;
      END IF;

      IF 'AML_RULE' = rev_items.attribute_code AND rev_items.attribute_number_value = 2 THEN   --   Related Documents Changes

          SELECT count(*) INTO l_pending_changes_count
          FROM eng_relationship_changes
          WHERE entity_id = p_change_line_id;

          IF l_pending_changes_count > 0 THEN
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cannot Implement the Revised Item '|| l_concatenated_segments || ' because there is a change policy NOT_ALLOWED on Related Document Changes.');
               l_can_implement_status := 'NO';
               EXIT;
          END IF;
      END IF;

      IF 'STRUCTURE_TYPE' = rev_items.attribute_code THEN        --   Structure Changes

          l_current_attr_group_id := rev_items.attribute_number_value;

          --   Check whether there are any structures created for the item with this change order ..
          SELECT count(*) INTO l_pending_changes_count
          FROM bom_bill_of_materials
          WHERE assembly_item_id = l_inventory_item_id
          AND organization_id = l_org_id
          AND structure_type_id = l_current_attr_group_id
          AND pending_from_ecn = ( SELECT change_notice FROM eng_engineering_changes
                                   WHERE change_id in (SELECT change_id FROM eng_revised_items
                                                       WHERE revised_item_sequence_id = p_change_line_id));

          IF l_pending_changes_count > 0 THEN
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cannot Implement the Revised Item '|| l_concatenated_segments || ' because there is a change policy NOT_ALLOWED on Structure Changes with structure type id ' || l_current_attr_group_id);
               l_can_implement_status := 'NO';
               EXIT;
          END IF;

          --   Check whether there are any component changes created for the item with this change order ..
          SELECT count(*) INTO l_pending_changes_count
          FROM bom_components_b comp, bom_bill_of_materials bom
          WHERE revised_item_sequence_id = p_change_line_id
          AND comp.implementation_date IS NULL
          AND comp.bill_sequence_id = bom.bill_sequence_id
          AND bom.structure_type_id = l_current_attr_group_id
          AND comp.change_notice = ( SELECT change_notice FROM eng_engineering_changes
                                   WHERE change_id in (SELECT change_id FROM eng_revised_items
                                                       WHERE revised_item_sequence_id = p_change_line_id));

          IF l_pending_changes_count > 0 THEN
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cannot Implement the Revised Item '|| l_concatenated_segments || ' because there is a change policy NOT_ALLOWED on Component Changes with structure type id ' || l_current_attr_group_id);
               l_can_implement_status := 'NO';
               EXIT;
          END IF;

          --   Check whether there are any operations changes created for the item with this change order ..
          SELECT count(st.structure_type_id) INTO l_pending_changes_count
          FROM bom_operation_sequences op, eng_revised_items ri , bom_structure_types_vl st
          WHERE op.revised_item_sequence_id = p_change_line_id
          AND op.revised_item_sequence_id = ri.revised_item_sequence_id
          AND op.implementation_date IS NULL
          AND st.structure_type_id = ( SELECT bbom.structure_type_id
                                    FROM bom_bill_of_materials bbom
                                    WHERE bbom.bill_sequence_id = ri.bill_sequence_id )
          AND st.structure_type_id = l_current_attr_group_id
          AND op.change_notice = ( SELECT change_notice FROM eng_engineering_changes
                                   WHERE change_id in (SELECT change_id FROM eng_revised_items
                                                       WHERE revised_item_sequence_id = p_change_line_id));

          IF l_pending_changes_count > 0 THEN
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cannot Implement the Revised Item '|| l_concatenated_segments || ' because there is a change policy NOT_ALLOWED on Operations Changes with structure type id ' || l_current_attr_group_id);
               l_can_implement_status := 'NO';
               EXIT;
          END IF;

      END IF;

      IF 'ATTACHMENT' = rev_items.attribute_code THEN            --   Attachment Changes
          l_current_attr_group_id := rev_items.attribute_number_value;

          SELECT count(*) INTO l_pending_changes_count
          FROM eng_attachment_changes
          WHERE revised_item_sequence_id = p_change_line_id
          AND category_id = l_current_attr_group_id;   --   ?

          IF l_pending_changes_count > 0 THEN
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cannot Implement the Revised Item '|| l_concatenated_segments || ' because there is a change policy NOT_ALLOWED on Attachment Changes with Category type id ' || l_current_attr_group_id);
               l_can_implement_status := 'NO';
               EXIT;
          END IF;
      END IF;

  END LOOP;

  x_implementation_status := l_can_implement_status;
EXCEPTION
  WHEN OTHERS THEN
     x_implementation_status := 'NO';
     RAISE abort_implementation;

END Can_Implement_Item;

-- Added procedure for bug 3402607
/********************************************************************
 * API Name      : LOG_IMPLEMENT_FAILURE
 * Parameters IN : p_change_id, p_revised_item_seq_id
 * Parameters OUT: None
 * Purpose       : Used to update the lifecycle states of the header
 * and create a log in header Action Log if implementation fails.
 * In case of revised item implementation failure, updates the revised
 * item status_type
 *********************************************************************/
PROCEDURE LOG_IMPLEMENT_FAILURE(p_change_id IN NUMBER
                              , p_revised_item_seq_id IN NUMBER) IS
        l_plsql_block           VARCHAR2(1000);
        l_api_caller            VARCHAR2(3) := 'CP';
        l_msg_count             NUMBER := 0;
        l_return_status         VARCHAR2(1);
        l_msg_data              VARCHAR2(2000);

    -- Changes for bug 4642163
   l_rev_item_sts_type  eng_revised_items.status_type%TYPE;
   l_plm_or_erp_change  eng_engineering_changes.plm_or_erp_change%TYPE;

   CURSOR c_get_rev_item_status_type
   IS
   SELECT ecs.status_type
      FROM eng_change_statuses ecs, eng_revised_items eri
      WHERE ecs.status_code = eri.status_code
      AND eri.revised_item_sequence_id = p_revised_item_seq_id;

   CURSOR c_plm_or_erp
   IS
   SELECT nvl(plm_or_erp_change, 'PLM') plm_or_erp
      FROM eng_engineering_changes
      WHERE change_id = p_change_id;
   -- End changes for bug 4642163

BEGIN
    -- Changes for bug 3720341
    -- If p_revised_item_seq_id is null, then the implementation failure is
    -- logged at the header level. Affects the status_type and change header lifecycle
    IF (p_revised_item_seq_id IS NULL OR p_revised_item_seq_id = 0)
    THEN
        -- Using dynamic sql as the package has call to workflow apis which are not included in the
        -- ENG patchset
        l_plsql_block := 'begin ENG_CHANGE_LIFECYCLE_UTIL.Update_Lifecycle_States('
                        || 'p_api_version       => 1.0  '
                        || ',p_change_id        => :1   ' -- l_change_id
                        || ',p_status_code      => 10   '
                        || ',p_api_caller       => :2   ' -- 'CP'
                        || ',p_wf_route_id      => NULL '
                        || ',p_route_status     => NULL '
                        || ',x_return_status    => :3   ' -- l_return_status
                        || ',x_msg_count        => :4   ' -- l_msg_count
                        || ',x_msg_data         => :5   );'  -- l_msg_data
                        || 'end;';

        EXECUTE IMMEDIATE l_plsql_block USING IN p_change_id, IN l_api_caller,
        OUT l_return_status, OUT l_msg_count, OUT l_msg_data;
    ELSE
    /* IF p_revised_item_seq_id is  not null, then the implementation failure is
     logged at the revised item level. Affects the status_type (set to 10)
        l_plsql_block := 'begin ENG_CHANGE_LIFECYCLE_UTIL.Update_RevItem_Lifecycle('
                        || 'p_api_version       => 1.0  '
                        || ',p_rev_item_seq_id  => :1   ' -- p_revised_item_seq_id
                        || ',p_status_type      => 10   '
                        || ',p_api_caller       => :2   ' -- 'CP'
                        || ',x_return_status    => :3   ' -- l_return_status
                        || ',x_msg_count        => :4   ' -- l_msg_count
                        || ',x_msg_data         => :5   );'  -- l_msg_data
                        || 'end;';

       EXECUTE IMMEDIATE l_plsql_block USING IN p_revised_item_seq_id, IN l_api_caller,
        OUT l_return_status, OUT l_msg_count, OUT l_msg_data;
   END IF;*/
   -- Changes for bug 4642163
    OPEN c_plm_or_erp;
    FETCH c_plm_or_erp INTO l_plm_or_erp_change;
    CLOSE c_plm_or_erp;
    -- Fetch the correct status type if it is ERP ECO else
    -- set the status type as implementation failed
    IF (l_plm_or_erp_change = 'PLM')
    THEN
      l_rev_item_sts_type := 10;
    ELSE
      OPEN c_get_rev_item_status_type;
      FETCH c_get_rev_item_status_type INTO l_rev_item_sts_type;
      CLOSE c_get_rev_item_status_type;
    END IF;
    -- IF p_revised_item_seq_id is  not null, then the implementation failure is
    -- logged at the revised item level. Affects the status_type (set to 10)
    l_plsql_block := 'begin ENG_CHANGE_LIFECYCLE_UTIL.Update_RevItem_Lifecycle('
            || 'p_api_version       => 1.0  '
            || ',p_rev_item_seq_id  => :1   ' -- p_revised_item_seq_id
            || ',p_status_type      => :2   '
            || ',p_api_caller       => :3   ' -- 'CP'
            || ',x_return_status    => :4   ' -- l_return_status
            || ',x_msg_count        => :5   ' -- l_msg_count
            || ',x_msg_data         => :6 );'  -- l_msg_data
            || 'end;';

    EXECUTE IMMEDIATE l_plsql_block
            USING IN  p_revised_item_seq_id
                , IN  l_rev_item_sts_type
                , IN  l_api_caller
                , OUT l_return_status
                , OUT l_msg_count
                , OUT l_msg_data;
    -- End changes for 4642163
     END IF;
    commit;
EXCEPTION
WHEN PLSQL_COMPILE_ERROR THEN
    -- changes for 4642163
    IF c_plm_or_erp%ISOPEN THEN
      CLOSE c_plm_or_erp;
    END IF;
    IF c_get_rev_item_status_type%ISOPEN THEN
      CLOSE c_get_rev_item_status_type;
    END IF;
        -- package is not found when called using dynamic sql
        -- ok to proceed
        -- null;
WHEN OTHERS THEN
    -- changes for 4642163
    IF c_plm_or_erp%ISOPEN THEN
      CLOSE c_plm_or_erp;
    END IF;
    IF c_get_rev_item_status_type%ISOPEN THEN
      CLOSE c_get_rev_item_status_type;
    END IF;
        -- Nothing is required to be done
        -- logging fails
        --  null;
END LOG_IMPLEMENT_FAILURE;

-- ERES change begins
PROCEDURE event_acknowledgement (p_event_status IN VARCHAR2) IS

CURSOR Get_Parent_Child_Events IS
SELECT parent_event_name
, parent_event_key
, parent_erecord_id
, event_name
, event_key
, erecord_id
, event_status
FROM eng_parent_child_events_temp;

l_erecord_id            NUMBER;
l_parent_child_count    NUMBER;
l_return_status         VARCHAR2(2);
l_msg_data              VARCHAR2(240);
l_msg_count             NUMBER;
l_dummy_cnt             NUMBER;
l_trans_status          VARCHAR2(10);
l_ackn_by               VARCHAR2(200);
SEND_ACKN_ERROR         EXCEPTION;

BEGIN
-- Acknowledgement part :
-- for all the events raised in the process.

-- Get message that will be send to SEND_ACKN :
FND_MESSAGE.SET_NAME('ENG', 'ENG_ERES_ACKN_ECO_IMPLEMENT');
l_ackn_by := FND_MESSAGE.GET;

FOR my_events IN Get_Parent_Child_Events
LOOP

  IF (p_event_status = 'SUCCESS')
  THEN
     l_trans_status := 'SUCCESS';
  ELSE
     l_trans_status := 'ERROR';
  END IF;
  l_erecord_id := my_events.erecord_id;
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Acknowledgement for ev_name='||my_events.event_name||', key='||my_events.event_key||', erec_id='||my_events.erecord_id||', stat='||l_trans_status);

  IF l_erecord_id IS NOT NULL
  THEN
    -- In case of error, autonomousCommit = TRUE
    QA_EDR_STANDARD.SEND_ACKN
          ( p_api_version       => 1.0
          , p_init_msg_list     => FND_API.G_FALSE
          , x_return_status     => l_return_status
          , x_msg_count         => l_msg_count
          , x_msg_data          => l_msg_data
          , p_event_name        => my_events.event_name
          , p_event_key         => my_events.event_key
          , p_erecord_id        => my_events.erecord_id
          , p_trans_status      => l_trans_status
          , p_ackn_by           => l_ackn_by
          , p_ackn_note         => my_events.event_name||', '||my_events.event_key
          , p_autonomous_commit => FND_API.G_TRUE);

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'After QA_EDR_STANDARD.SEND_ACKN msg='||l_msg_count);
    IF (NVL(l_return_status, FND_API.G_FALSE) <> FND_API.G_TRUE)
      AND (l_msg_count > 0)
    THEN
       RAISE SEND_ACKN_ERROR;
    END IF;
  END IF;

  DELETE FROM eng_parent_child_events_temp
  WHERE erecord_id = my_events.erecord_id
  AND parent_erecord_id = my_events.parent_erecord_id;

--  select count(*) INTO l_parent_child_count from eng_parent_child_events_temp;
--  FND_FILE.PUT_LINE(FND_FILE.LOG, 'eng_parent_child_events_temp count='||l_parent_child_count);
END LOOP;
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Normal end of acknowledgement part ');

EXCEPTION
WHEN SEND_ACKN_ERROR THEN
   FND_MSG_PUB.Get(
     p_msg_index  => 1,
     p_data       => l_msg_data,
     p_encoded    => FND_API.G_FALSE,
     p_msg_index_out => l_dummy_cnt);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'ACKN Error: '||l_msg_data);

WHEN OTHERS THEN
   l_msg_data := 'ACKN Others Error='||SQLERRM;
   FND_FILE.PUT_LINE(FND_FILE.LOG, l_msg_data);

END event_acknowledgement;
-- ERES change ends


/***********************************************************************************

procedure       CHECK_ONHAND
 This procedure checks if there is any onhand qty available
 If onhand qty is found it returns FND_API.G_TRUE

arguments
 p_inventory_item_id :config item id
 p_org_id            : given org id
 x_return_status     : FND_API.G_TRUE

**********************************************************************************/
PROCEDURE CHECK_ONHAND(
                             p_inventory_item_id     IN     NUMBER,
                             p_org_id                IN     NUMBER,
                             x_return_status         OUT NOCOPY    VARCHAR2
                      )
IS
      xdummy   number;
BEGIN
      x_return_status := FND_API.G_FALSE;

      select transaction_quantity into xdummy
      from  mtl_onhand_quantities
      where inventory_item_id = p_inventory_item_id
      and   organization_id = p_org_id
      and   transaction_quantity > 0;

      raise TOO_MANY_ROWS;      -- single row treated as too many rows

EXCEPTION
      when no_data_found then
           null;        -- no onhand. ok to proceed.

      when too_many_rows then
           x_return_status := FND_API.G_TRUE;

      when others then
           x_return_status := FND_API.G_TRUE;


END;




-- 11.5.10 changes This function checks if there is any onhand qty available
--If onhand qty is found it returns 1 else 0

Function inv_onhand(p_item_id IN NUMBER,
                     p_org_id IN NUMBER) RETURN NUMBER IS
l_return_status VARCHAR2(1);
BEGIN

     CHECK_ONHAND(p_inventory_item_id =>p_item_id,
                       p_org_id      =>p_org_id,
                       x_return_status     =>l_return_status);

     if  (l_return_status     = FND_API.G_TRUE )
      then
        return 1;
     else
       return 0;
       end if;

END;


PROCEDURE CHANGE_ITEM_LIFECYCLE_PHASE (
          p_rev_item_seq_id             IN      NUMBER
        , p_organization_id             IN      NUMBER
        , p_inventory_item_id           IN      NUMBER
        , p_scheduled_date              IN      DATE
        , p_new_lifecycle_phase_id      IN      NUMBER
        , x_return_status       OUT NOCOPY      VARCHAR2)
IS

  l_project_id                  NUMBER;
  l_lifecycle_id                NUMBER;
  l_lifecycle_project_id        NUMBER;
  l_lifecycle_project_number    VARCHAR2(30);
  l_return_status               VARCHAR2(1);
  l_error_code                  NUMBER;
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(4000);
  l_project_assoc_type          VARCHAR2(24) := 'EGO_ITEM_PROJ_ASSOC_TYPE';
  l_lifecycle_tracking_code     VARCHAR2(18) := 'LIFECYCLE_TRACKING';
  l_api_version                 VARCHAR2(3) := '1.0';
  l_sql_stmt                    VARCHAR2(1000);
  l_plsql_block                 VARCHAR2(1000);
  l_new_lifecycle_phase         VARCHAR2(240);
  l_object_name                 VARCHAR2(30):= 'EGO_ITEM';

BEGIN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Processing lifecycle phase change .. ');
        l_sql_stmt := ' SELECT eip.project_id, ppa.name                 '
                        || 'FROM EGO_ITEM_PROJECTS eip, PA_PROJECTS_ALL ppa '
                        || 'WHERE eip.project_id = ppa.project_id               '
                        || 'AND eip.INVENTORY_ITEM_ID = :1              '
                        || 'AND eip.ORGANIZATION_ID = :2                '
                        || 'AND eip.REVISION IS NULL                    '
                        || 'AND eip.ASSOCIATION_TYPE = :3               '
                        || 'AND eip.ASSOCIATION_CODE = :4               '
                        || 'AND ROWNUM = 1                              ';
        BEGIN
                EXECUTE IMMEDIATE l_sql_stmt INTO l_lifecycle_project_id , l_lifecycle_project_number
                USING p_inventory_item_id, p_organization_id, l_project_assoc_type, l_lifecycle_tracking_code;

                l_sql_stmt := ' SELECT  name                            '
                                || 'FROM PA_EGO_PHASES_V     '
                                || 'WHERE PROJ_ELEMENT_ID = :1;         ';
                EXECUTE IMMEDIATE l_sql_stmt INTO l_new_lifecycle_phase
                USING p_new_lifecycle_phase_id;

                /* call the Projects api */
                l_plsql_block := 'begin PA_PROJ_TASK_STRUC_PUB.Update_Current_Phase '
                                || ' ( p_project_id                     => :1 '
                                || ' , p_project_name                   => :2 '
                                || ' , p_current_lifecycle_phase_id     => :3 '
                                || ' , p_current_lifecycle_phase        => :4 '
                                || ' , x_return_status                  => :5 '
                                || ' , x_msg_count                      => :6 '
                                || ' , x_msg_data                       => :7 '
                                || ' ); '
                                || 'end; ';
                EXECUTE IMMEDIATE l_plsql_block USING
                        IN l_lifecycle_project_id, IN l_lifecycle_project_number, IN p_new_lifecycle_phase_id, IN l_new_lifecycle_phase,
                        OUT l_return_status, OUT l_msg_count, OUT l_msg_data;
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Processing lifecycle phase change for project '|| l_lifecycle_project_number || '.. ');

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
                l_sql_stmt := ' SELECT lifecycle_id                             '
                                || '  FROM mtl_system_items_b                   '
                                || '  WHERE inventory_item_id = :1              '
                                || '  AND organization_id = :2                  ' ;

                BEGIN
                        EXECUTE IMMEDIATE l_sql_stmt INTO l_lifecycle_id USING p_inventory_item_id, p_organization_id;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Lifecycle phase change Error: No lifecycle associated to the item ');
                        l_return_status := 'U';
                END;
                IF (l_lifecycle_id IS NOT NULL)
                THEN
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Processing lifecycle phase change for item.. ');

                        /*l_plsql_block := 'begin '
                                || 'ego_lifecycle_user_pub.Sync_Phase_Change '
                                || '( p_api_version     => :1   '
                                || ', p_organization_id => :2   '
                                || ', p_inventory_item_id => :3 '
                                || ', p_revision        => null '
                                || ', p_lifecycle_id    => :4   '
                                || ', p_phase_id        => :5   '
                                || ', p_effective_date  => :6   '
                                || ', x_return_status   => :7   '
                                || ', x_errorcode       => :8   '
                                || ', x_msg_count       => :9   '
                                || ', x_msg_data        => :10  '
                                || '); '
                                || 'end; ';

                        EXECUTE IMMEDIATE  l_plsql_block USING
                        IN l_api_version, IN p_organization_id, IN p_inventory_item_id, IN l_lifecycle_id, IN p_new_lifecycle_phase_id, IN p_scheduled_date,
                        OUT l_return_status, OUT l_error_code,OUT l_msg_count, OUT l_msg_data;*/
                        l_plsql_block := 'begin '
                                || 'EGO_ITEM_LC_IMP_PC_PUB.Implement_Pending_Changes  '
                                || '( p_api_version     => 1.0  '
                                || ', p_commit          => :1   '
                                || ', p_change_id       => null '
                                || ', p_change_line_id  => :2   '
                                || ', x_return_status   => :3   '
                                || ', x_errorcode       => :4   '
                                || ', x_msg_count       => :5   '
                                || ', x_msg_data        => :6   '
                                || '); '
                                || 'end; ';

                        EXECUTE IMMEDIATE  l_plsql_block USING IN l_return_status, IN p_rev_item_seq_id,
                        OUT l_return_status, OUT l_error_code,OUT l_msg_count, OUT l_msg_data;

                        FOR I IN 1..l_msg_count
                        LOOP
                                FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MSG_PUB.get(I, 'F'));
                        END LOOP;

                END IF;
        END;
        x_return_status := l_return_status;

        EXCEPTION
        WHEN OTHERS THEN

                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Lifecycle phase change Error: ' ||SQLERRM);
                x_return_status := 'U';

END CHANGE_ITEM_LIFECYCLE_PHASE;

------------------------------------------------------------------------
--           R12: Changes for Common BOM Enhancement                  --
--             Begin Private Procedures Definition                    --
------------------------------------------------------------------------
------------------------------------------------------------------------
--  API name    : Move_Pending_Dest_Components                        --
--  Type        : Private                                             --
--  Pre-reqs    : None.                                               --
--  Procedure   : Propagates the specified ECO                        --
--  Parameters  :                                                     --
--       IN     : p_src_old_comp_seq_id  NUMBER Required              --
--                p_src_comp_seq_id      NUMBER Required              --
--                p_change_notice        vARCHAR2 Required            --
--                p_revised_item_sequence_id  NUMBER Required         --
--                p_effectivity_date     NUMBER Required              --
--       OUT    : x_return_status            VARCHAR2(1)              --
--  Version     : Current version       1.0                           --
--                Initial version       1.0                           --
--                                                                    --
--  Notes       : This API is invoked only when a common bill has     --
--                pending changes associated for its WIP supply type  --
--                attributes and the common component in the source   --
--                bill is being implemented.                          --
--                All the destination pending changes are then moved  --
--                to this new component with the effectivity range of --
--                the component being implemented.                    --
------------------------------------------------------------------------
PROCEDURE Move_Pending_Dest_Components (
    p_src_old_comp_seq_id IN NUMBER
  , p_src_comp_seq_id     IN NUMBER
  , p_change_notice       IN VARCHAR2
  , p_revised_item_sequence_id IN NUMBER
  , p_effectivity_date    IN DATE
  , p_eco_for_production  IN NUMBER
  , x_return_status       OUT NOCOPY VARCHAR2
) IS

    --
    -- Cursor to fetch the component being implemented wrt the detination bill
    -- for the change in the soruce bill
    --
    CURSOR c_related_components IS
    SELECT bcb.component_sequence_id, old_component_sequence_id, bill_sequence_id
    FROM bom_components_b bcb
    WHERE bcb.change_notice = p_change_notice
    AND bcb.revised_item_sequence_id = p_revised_item_sequence_id
    AND bcb.common_component_sequence_id = p_src_comp_seq_id
    AND bcb.common_component_sequence_id <> bcb.component_sequence_id
    AND bcb.implementation_date IS NULL;

BEGIN
    --
    -- Initialize
    --
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    IF p_eco_for_production = 2
    -- Do not reset the value of old component sequence_id when only
    -- WIPs have to be updated and the BOM changes are to be reversed.
    -- This is actually done for normal bills post implemntation
    -- of the new component for update of the old_component_sequence_id
    -- Here, Doing it in one go for all the pending changes of the common
    -- referenced component being implemented.
    THEN

        -- For each destination component record that will be implemented
        FOR c_dest_comp_rec IN c_related_components
        LOOP
            UPDATE bom_components_b bcb
               SET bcb.old_component_sequence_id = c_dest_comp_rec.component_sequence_id
                 , bcb.common_component_sequence_id = p_src_comp_seq_id
                 , bcb.last_update_date = sysdate
                 , bcb.last_updated_by = FND_PROFILE.value('USER_ID')
                 , bcb.last_update_login = FND_PROFILE.value('LOGIN_ID')
                 , bcb.request_id = FND_PROFILE.value('REQUEST_ID')
                 , bcb.program_application_id = FND_PROFILE.value('RESP_APPL_ID')
                 , bcb.program_id = FND_PROFILE.value('PROGRAM_ID')
                 , bcb.program_update_date = sysdate
             WHERE bcb.old_component_sequence_id = c_dest_comp_rec.old_component_sequence_id
               AND bcb.bill_sequence_id = c_dest_comp_rec.bill_sequence_id
               AND bcb.common_component_sequence_id = p_src_old_comp_seq_id
               AND bcb.implementation_date IS NULL
               -- The following exists clause is to ensure that the pending component is not a source
               -- referenced component but the one actually created for the destination bill itself
               AND EXISTS (SELECT 1 FROM eng_revised_items eri
                          WHERE eri.revised_item_sequence_id = bcb.revised_item_sequence_id
                            AND eri.change_notice= bcb.change_notice
                            AND eri.bill_sequence_id = bcb.bill_sequence_id);
        END LOOP;
    ELSE
        -- For each destination component record that will be implemented
        FOR c_dest_comp_rec IN c_related_components
        LOOP
            -- set the values being updated into the global table to revert it
            -- when reverse standard bom is called .
            -- Here only common component sequence id is being updated to
            -- point to the new referenced component that is going to be implemented
            --
            g_common_rev_comps_cnt := g_common_rev_comps_cnt+1;
            g_Common_Rev_Comp_Tbl(g_common_rev_comps_cnt).revised_item_sequence_id := p_revised_item_sequence_id;
            g_Common_Rev_Comp_Tbl(g_common_rev_comps_cnt).dest_bill_sequence_id := c_dest_comp_rec.bill_sequence_id;
            g_Common_Rev_Comp_Tbl(g_common_rev_comps_cnt).dest_old_comp_sequence_id := c_dest_comp_rec.old_component_sequence_id;
            g_Common_Rev_Comp_Tbl(g_common_rev_comps_cnt).component_sequence_id := c_dest_comp_rec.component_sequence_id;
            g_Common_Rev_Comp_Tbl(g_common_rev_comps_cnt).common_component_sequence_id := p_src_comp_seq_id;
            g_Common_Rev_Comp_Tbl(g_common_rev_comps_cnt).prev_common_comp_sequence_id := p_src_old_comp_seq_id;

            UPDATE bom_components_b bcb
               SET bcb.common_component_sequence_id = p_src_comp_seq_id
                 , bcb.last_update_date = sysdate
                 , bcb.last_updated_by = FND_PROFILE.value('USER_ID')
                 , bcb.last_update_login = FND_PROFILE.value('LOGIN_ID')
                 , bcb.request_id = FND_PROFILE.value('REQUEST_ID')
                 , bcb.program_application_id = FND_PROFILE.value('RESP_APPL_ID')
                 , bcb.program_id = FND_PROFILE.value('PROGRAM_ID')
                 , bcb.program_update_date = sysdate
             WHERE bcb.old_component_sequence_id = c_dest_comp_rec.old_component_sequence_id
               AND bcb.bill_sequence_id = c_dest_comp_rec.bill_sequence_id
               AND bcb.common_component_sequence_id = p_src_old_comp_seq_id
               AND bcb.implementation_date IS NULL
               -- The following exists clause is to ensure that the pending component is not a source
               -- referenced component but the one actually created for the destination bill itself
               AND EXISTS (SELECT 1 FROM eng_revised_items eri
                          WHERE eri.revised_item_sequence_id = bcb.revised_item_sequence_id
                            AND eri.change_notice= bcb.change_notice
                            AND eri.bill_sequence_id = bcb.bill_sequence_id);
        END LOOP;
    END IF;
EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Move_Pending_Dest_Components;

PROCEDURE Reset_Common_Comp_Details (
  x_Mesg_Token_Tbl   OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_return_status    OUT NOCOPY VARCHAR2
) IS

BEGIN
    --
    -- Initialize
    --
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    -- For each component thats been
    FOR i IN 1..g_common_rev_comps_cnt
    LOOP
        UPDATE bom_components_b bcb
           SET bcb.common_component_sequence_id = g_Common_Rev_Comp_Tbl(i).prev_common_comp_sequence_id
             , bcb.last_update_date = sysdate
             , bcb.last_updated_by = FND_PROFILE.value('USER_ID')
             , bcb.last_update_login = FND_PROFILE.value('LOGIN_ID')
             , bcb.request_id = FND_PROFILE.value('REQUEST_ID')
             , bcb.program_application_id = FND_PROFILE.value('RESP_APPL_ID')
             , bcb.program_id = FND_PROFILE.value('PROGRAM_ID')
             , bcb.program_update_date = sysdate
         WHERE bcb.old_component_sequence_id = g_Common_Rev_Comp_Tbl(i).dest_old_comp_sequence_id
           AND bcb.bill_sequence_id = g_Common_Rev_Comp_Tbl(i).dest_bill_sequence_id
           AND bcb.common_component_sequence_id = g_Common_Rev_Comp_Tbl(i).common_component_sequence_id
           AND bcb.implementation_date IS NULL
           -- The following exists clause is to ensure that the pending component is not a source
           -- referenced component but the one actually created for the destination bill itself
           AND EXISTS (SELECT 1 FROM eng_revised_items eri
                      WHERE eri.revised_item_sequence_id = bcb.revised_item_sequence_id
                        AND eri.change_notice= bcb.change_notice
                        AND eri.bill_sequence_id = bcb.bill_sequence_id);

        BOMPCMBM.Update_Related_Components(
            p_src_comp_seq_id => g_Common_Rev_Comp_Tbl(i).prev_common_comp_sequence_id
          , x_Mesg_Token_Tbl  => x_Mesg_Token_Tbl
          , x_Return_Status   => x_return_status);
    END LOOP;
EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Reset_Common_Comp_Details;


-- PROCEDURE ENTER_WIP_DETAILS_FOR_COMPS
-- Bug No: 5285282
-- Procedure to populate the WIP_JOB_DETAILS_INTERFACE table.
-- This procedure is called only if 'Update Job Only' is ticked for revised items.
-- For 'Update Job Only' changes are not visible in the BOM explosion, hence to
-- make these changes visible to the WIP jobs, we need to explicitly enter the
-- data in the WIP interface table WIP_JOB_DETAILS_INTERFACE
--

PROCEDURE ENTER_WIP_DETAILS_FOR_COMPS ( p_revised_item_sequence_id IN NUMBER,
                                        p_group_id                 IN NUMBER,
                                        p_parent_header_id         IN NUMBER,
                                        p_mrp_active               IN NUMBER,
                                        p_user_id                  IN NUMBER,
                                        p_login_id                 IN NUMBER,
                                        p_request_id               IN NUMBER,
                                        p_program_id               IN NUMBER,
                                        p_program_application_id   IN NUMBER
                                        )
IS
  CURSOR c_comps IS
  SELECT component_item_id,
         operation_seq_num,
         component_quantity,
         supply_locator_id,
         supply_subinventory,
         wip_supply_type,
         acd_type
  FROM bom_components_b
  WHERE revised_item_sequence_id = p_revised_item_sequence_id;

BEGIN
  FOR comp_details IN c_comps
  LOOP
    INSERT INTO WIP_JOB_DTLS_INTERFACE
      (created_by,
       creation_date,
       last_update_date,
       last_updated_by,
       last_update_login,
       request_id,
       program_id,
       program_application_id,
       program_update_date,
       group_id,
       load_type,
       parent_header_id,
       process_phase,
       process_status,
       substitution_type,
       inventory_item_id_new,
       inventory_item_id_old,
       operation_seq_num,
       quantity_per_assembly,
       supply_locator_id,
       supply_subinventory,
       wip_supply_type,
       mrp_net_flag)
    VALUES
      (p_user_id,
       sysdate,
       sysdate,
       p_user_id,
       p_login_id,
       p_request_id,
       p_program_id,
       p_program_application_id,
       sysdate,
       p_group_id,
       2,                                        -- Load Type is 2 for components
       p_parent_header_id,
       2,                                        -- process_phase 2 for validation
       1,                                        -- process_status 1 for pending
       decode(comp_details.acd_type, 1, 2,
                                     2, 3,
                                     1),         -- substitution_type 1->Delete, 2->Add, 3->Change
       decode(comp_details.acd_type, 1,
                 comp_details.component_item_id, -- inventory_item_id_new populated only for component add
                 null),
       decode(comp_details.acd_type, 1,          -- inventory_item_id_old populated only for component change/delete
                 null,
                 comp_details.component_item_id),
       comp_details.operation_seq_num,
       comp_details.component_quantity,
       comp_details.supply_locator_id,
       comp_details.supply_subinventory,
       comp_details.wip_supply_type,
       p_mrp_active);

  END LOOP;
END ENTER_WIP_DETAILS_FOR_COMPS;

------------------------------------------------------------------------
--           R12: Changes for Common BOM Enhancement                  --
--             END Private Procedures Definition                      --
------------------------------------------------------------------------

Procedure implement_revised_item(
        revised_item in eng_revised_items.revised_item_sequence_id%type,
        trial_mode in number,
        max_messages in number, -- size of host arrays
        userid  in number,  -- user id
        reqstid in number,  -- concurrent request id
        appid   in number,  -- application id
        progid  in number,  -- program id
        loginid in number,  -- login id
        bill_sequence_id        OUT NOCOPY eng_revised_items.bill_sequence_id%type ,
        routing_sequence_id     OUT NOCOPY eng_revised_items.routing_sequence_id%type ,
        eco_for_production      OUT NOCOPY eng_revised_items.eco_for_production%type ,
        revision_high_date      OUT NOCOPY mtl_item_revisions.effectivity_date%type,
        rtg_revision_high_date  OUT NOCOPY mtl_rtg_item_revisions.effectivity_date%type,
        update_wip              OUT NOCOPY eng_revised_items.update_wip%type ,
        group_id1               OUT NOCOPY wip_job_schedule_interface.group_id%type,
        group_id2               OUT NOCOPY wip_job_schedule_interface.group_id%type,
        wip_job_name1           OUT NOCOPY wip_entities.wip_entity_name%type,
        wip_job_name2           OUT NOCOPY wip_entities.wip_entity_name%type,
        wip_job_name2_org_id    OUT NOCOPY wip_entities.organization_id%type,
        message_names OUT NOCOPY NameArray,
        token1 OUT NOCOPY NameArray,
        value1 OUT NOCOPY StringArray,
        translate1 OUT NOCOPY BooleanArray,
        token2 OUT NOCOPY NameArray,
        value2 OUT NOCOPY StringArray,
        translate2 OUT NOCOPY BooleanArray,
        msg_qty in OUT NOCOPY binary_integer,
        warnings in OUT NOCOPY number,
        p_is_lifecycle_phase_change     IN      NUMBER,
        p_now                           IN      DATE,
        p_status_code                   IN      NUMBER)
IS

-- ERES change begins
bERES_Flag_for_BOM     BOOLEAN := FALSE;        -- bug 3741444.
bERES_Flag_for_Routing BOOLEAN := FALSE;        -- bug 3908563.
l_eres_enabled         VARCHAR2(10);
l_child_record         QA_EDR_STANDARD.ERECORD_ID_TBL_TYPE;
l_event                QA_EDR_STANDARD.ERES_EVENT_REC_TYPE;
-- l_payload              FND_WF_EVENT.PARAM_TABLE;
-- ll_payload             FND_WF_EVENT.PARAM_TABLE;
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(2000);
l_message              VARCHAR2(2000);
l_dummy_cnt            NUMBER;
l_erecord_id           NUMBER;
l_trans_status         VARCHAR2(20);
l_event_status         VARCHAR2(20);
i                      PLS_INTEGER;
l_child_event_name     VARCHAR2(200);
l_temp_id              VARCHAR2(200);
l_parent_record_id     NUMBER;
l_pending_from_ecn     VARCHAR2(10);
l_alternate_designator VARCHAR2(10);
l_send_ackn            BOOLEAN;
l_plsql_block           VARCHAR2(1000);
l_api_caller VARCHAR2(3)        := 'CP';

-- Bug 6982970 vggarg declared this variable start
l_base_cm_type_code  eng_change_order_types.BASE_CHANGE_MGMT_TYPE_CODE%TYPE;
-- Bug 6982970 vggarg end

l_err_tbl Error_Handler.Mesg_Token_Tbl_Type;


-- Item Attribute and AML changes support
plsql_block VARCHAR2(5000);
-- Item Attribute and AML changes support

ERES_EVENT_ERROR       EXCEPTION;

CURSOR Get_Bill_of_Materials_Info( bill_id IN NUMBER) IS
SELECT pending_from_ecn
, alternate_bom_designator
FROM bom_bill_of_materials
WHERE bill_sequence_id = bill_id;

CURSOR Get_Operational_Routing_Info( routing_id IN NUMBER) IS
SELECT pending_from_ecn
, alternate_routing_designator
FROM bom_operational_routings
WHERE routing_sequence_id = routing_id ;
-- ERES change ends

        abort_implementation exception;
        dummy varchar2(1);
        eco_rev_warning_flag varchar2(1);
        today  date;  -- implementation date
        now    date;  -- effectivity date and time
        eff_date    date;  -- effectivity date and time
        count_op_disable   number:=0;      --  count for table rev_op_disable_date_tbl
        count_comp_disable number:=0;      --  count for table rev_comp_disable_date_tbl
        l_disable_date  date;              --  variable for disable date
        l_current_revision varchar2(3);
        l_current_rev_eff_date date;
        l_current_rtg_revision varchar2(3);
        l_current_rtg_rev_eff_date date;

        -- Local variables for update routings
        l_routing_sequence_id NUMBER;
        l_cfm_routing_flag    NUMBER;
        l_completion_subinventory  VARCHAR2(10);
        l_completion_locator_id NUMBER;
        l_mixed_model_map_flag  NUMBER;
        l_common_assembly_item_id NUMBER;
        l_common_routing_sequence_id NUMBER;
        l_ctp_flag                   NUMBER;
        l_priority                   NUMBER;
        l_routing_comment            VARCHAR2(240);
        l_bom_assembly_type          NUMBER;

        l_old_disable_date date;
        -- Bug 5657390
	l_update_all_jobs     NUMBER := nvl(fnd_profile.value('ENG:UPDATE_UNRELEASED_WIP_JOBS'),2);

        -- ERES change
        -- odab added columns change_id, organization_code
        -- , organization_name, concatenated_segments, description
        -- last_update_date, last_updated_by, creation_date, created_by
        -- replaced mtl_system_items by mtl_system_items_vl
        -- added joint tables mtl_parameters, hr_all_organization_units_tl
        Cursor get_item_info is
                Select  i.change_notice,
                        i.change_id,                         -- ERES change
                        i.organization_id,
                        mp1.organization_code,               -- ERES change
                        hou.name organization_name,          -- ERES change
                        i.revised_item_id,
                        si.concatenated_segments,            -- ERES change
                        si.description,                      -- ERES change
			si.bom_enabled_flag,                 -- Bug 5846248
                        i.new_item_revision,
                        i.bill_sequence_id,
                        i.update_wip,
                        si.pick_components_flag,
                        si.bom_item_type,                    --BOM ER 9946990
                        i.revised_item_sequence_id,
                        i.scheduled_date,
                        si.inventory_item_status_code,
                        si.eng_item_flag,
                        i.mrp_active,
                        i.from_wip_entity_id,
                        i.to_wip_entity_id,
                        i.from_cum_qty,
                        i.lot_number,
                        i.new_routing_revision,
                        i.routing_sequence_id,
                        i.cfm_routing_flag,
                        i.completion_locator_id ,
                        i.completion_subinventory,
                        i.mixed_model_map_flag,
                        i.eco_for_production,
                        i.ctp_flag,
                        i.priority,
                        i.routing_comment,
                        i.designator_selection_type,
                        i.alternate_bom_designator,
                        i.transfer_or_copy,
                        i.transfer_or_copy_item,
                        i.transfer_or_copy_bill,
                        i.transfer_or_copy_routing,
                        i.copy_to_item,
                        i.copy_to_item_desc,
                        i.implemented_only,
                        i.selection_option,
                        i.selection_date,
                        i.selection_unit_number,             -- ERES change
                        i.last_update_date,                  -- ERES change
                        i.last_updated_by,                   -- ERES change
                        i.creation_date,                     -- ERES change
                        i.created_by          ,               -- ERES change
                        i.new_item_revision_id,
                        i.current_item_revision_id ,
                        i.new_lifecycle_state_id,
                        i.use_up_item_id ,
                        i.disposition_type,
                        i.new_structure_revision,
                        i.current_lifecycle_state_id,
                        i.enable_item_in_local_org,
                        i.from_end_item_id,
                        i.from_end_item_rev_id
                from    eng_revised_items i,
                        mtl_system_items_vl si,              -- ERES change
                        mtl_parameters mp1,                  -- ERES change
                        hr_all_organization_units_tl hou     -- ERES change
                where i.revised_item_sequence_id = revised_item
                and   si.inventory_item_id = i.revised_item_id
                and   si.organization_id = i.organization_id
                AND hou.organization_id = i.organization_id
                AND hou.language(+) = USERENV('LANG')
                AND mp1.organization_id = i.organization_id
                for update of i.implementation_date,
                              i.status_type,
                              i.last_update_date,
                              i.last_updated_by,
                              i.last_update_login,
                              i.request_id,
                              i.program_application_id,
                              i.program_id,
                              i.program_update_date,
                              i.status_code;

        item get_item_info%rowtype;
        Cursor check_rev_item_inactive is
                Select 'x'
                from   bom_parameters
                where  organization_id = item.organization_id
                and    bom_delete_status_code = item.inventory_item_status_code;
        Cursor check_for_unimp_items is
                Select 'x'
                from    eng_revised_items
                where   organization_id = item.organization_id
                and     change_notice = item.change_notice
                and     status_type not in
                        (cancelled_status, implemented_status);
        Cursor unimplemented_rev is
                Select eri.new_item_revision
                from eng_engineering_changes eec,
                     eng_revised_items eri
                where eec.change_notice = eri.change_notice
                and  eec.organization_id = eri.organization_id
                and  eri.organization_id = item.organization_id
                and  eri.revised_item_id = item.revised_item_id
                and  eec.status_type not in
                        (cancelled_status, implemented_status)
                and  eri.status_type not in
                        (cancelled_status, implemented_status)
                and  nlssort(eri.new_item_revision) <
                     nlssort(item.new_item_revision);

        unimp_rec  unimplemented_rev%rowtype;

        Cursor get_current_rev is
                Select r.revision, r.effectivity_date
                from   mtl_item_revisions r
                where  r.inventory_item_id = item.revised_item_id
                and    r.organization_id = item.organization_id
                and    r.effectivity_date = (
                        select max(cr.effectivity_date)
                        from   mtl_item_revisions cr
                        where  cr.inventory_item_id = item.revised_item_id
                        and    cr.organization_id = item.organization_id
                        and    cr.implementation_date is not null
                        and    cr.effectivity_date <= eff_date);
        current_revision get_current_rev%rowtype;
        ----added r.effectivity_date >= eff_date for bug 5496417
        Cursor check_high_date_low_rev is
                Select 'x'
                from   mtl_item_revisions r
                where  r.inventory_item_id = item.revised_item_id
                and    r.organization_id = item.organization_id
                and    r.effectivity_date >= eff_date
                and    r.revision < item.new_item_revision
                and    r.implementation_date is not null;

        Cursor get_common_bills is
                Select b.organization_id, b.assembly_item_id,
                       b.bill_sequence_id
                from   bom_bill_of_materials b
                where  b.common_assembly_item_id = item.revised_item_id
                and    b.common_organization_id = item.organization_id
                AND    b.source_bill_sequence_id = item.bill_sequence_id; -- R12: Common BOM changes
                --and    b.common_bill_sequence_id = item.bill_sequence_id;
        common get_common_bills%rowtype;
        Cursor get_common_current_rev(common_assembly_item_id IN NUMBER,
                                common_org_id IN NUMBER) is
                Select r.revision
                from   mtl_item_revisions r
                where  r.inventory_item_id = common_assembly_item_id
                and    r.organization_id = common_org_id
                and    r.effectivity_date = (
                        select max(cr.effectivity_date)
                        from   mtl_item_revisions cr
                        where  cr.inventory_item_id = common_assembly_item_id
                        and    cr.organization_id = common_org_id
                        and    cr.implementation_date is not null
                        and    cr.effectivity_date <= eff_date);
        common_current_rev  mtl_item_revisions.revision%type;

        --* Added for Bug 4366583
        Cursor revision_exists(common_assembly_item_id IN NUMBER,
                               common_org_id IN NUMBER,
                               common_revision IN VARCHAR2) is
                select count(*)
                from mtl_item_revisions_b
                where inventory_item_id = common_assembly_item_id
                and organization_id = common_org_id
                and revision = common_revision;
        l_revision_exists NUMBER;
        --* End of Bug 4366583

        Cursor chng_component_rows(cp_bill_sequence_id IN NUMBER) is
            Select c.component_sequence_id,
                   f.concatenated_segments item_number,
                   c.component_item_id,
                   c.operation_seq_num,
                   c.acd_type,
                   c.quantity_related,
                   c.component_quantity,
                   c.old_component_sequence_id,
                   c.disable_date,
                   c.from_end_item_unit_number,
                   c.to_end_item_unit_number,
                   c.from_object_revision_id,
                   c.to_object_revision_id,
                   c.overlapping_changes,
                   f.eng_item_flag,
                   c.from_end_item_rev_id,
                   c.to_end_item_rev_id,
                   c.component_item_revision_id,
                   c.obj_name,
                   f.bom_item_type,             --BOM ER 9946990
                   f.replenish_to_order_flag,   --BOM ER 9946990
                   c.optional,                  --BOM ER 9946990
                   c.component_remarks
            from bom_components_b c,  --bom_inventory_components c,
                 mtl_system_items_b_kfv f
            where c.revised_item_sequence_id = revised_item
            AND   c.bill_sequence_id = cp_bill_sequence_id -- R12: Added for common bom changes
            and   f.inventory_item_id = c.component_item_id
            and   f.organization_id = item.organization_id
            AND   c.obj_name IS NULL -- added for bom_components_b
            for update of c.implementation_date,
                          c.change_notice,
                          c.disable_date,
                          c.from_end_item_unit_number,
                          c.to_end_item_unit_number,
                          c.from_object_revision_id,
                          c.overlapping_changes,
                          c.effectivity_date,
                          c.last_update_date,
                          c.last_updated_by,
                          c.last_update_login,
                          c.request_id,
                          c.program_application_id,
                          c.program_id,
                          c.program_update_date;
/*According to new where condition of this cursor  union Query has commented out
   case 1: S1 => C1 (Q= 1 ,eff= D1) changed to S1 => C1 (Q= 10 ,eff= D1)  [D1 = future date] is supported.
   initailly overlapping error used to come in both cases .
   case 2: S1 => C1(eff = D1 ,disb =D3)  C1 (eff = D3 ) now make changes from C1(eff = D2 ,disb =D3) supported
   Initially disable adte 1 sec less than eff date was required now 1 sec gap won't be check.*/

        Cursor check_existing_component(X_bill number, X_component number,
            X_operation number, X_comp_seq_id number, X_disable_date date,X_old_comp_seq_id number
	    ,X_old_rec_disable_date  date) is
            Select 'x' -- overlapping effectivity
            from bom_components_b c --bom_inventory_components c
            where c.bill_sequence_id = X_bill
            and c.component_item_id = X_component
            and c.operation_seq_num = X_operation
            and c.implementation_date is not null
            AND   c.obj_name IS NULL -- added for bom_components_b
	     /* Bug: 2307923 Date filter logic has been modified to prevent
               the duplicate creation of components through ECO */
           and ( (eff_date < c.effectivity_date
                   and nvl(X_disable_date,c.effectivity_date + 1) > c.effectivity_date)
                   or
		   (eff_date < c.effectivity_date
                   and nvl(X_disable_date,c.effectivity_date ) <>  c.effectivity_date
		   and nvl(X_old_rec_disable_date,c.effectivity_date) = c.effectivity_date )
		   or
		   /*Bug no:2867564 Eco is implementing and allowing duplicate item, and seqs. */
                  /*and eff_date <= nvl(c.disable_date,eff_date-1)*/
                  (eff_date > c.effectivity_date
                   and eff_date <  nvl(c.disable_date,eff_date+1) )
                   or
		  (eff_date = c.effectivity_date
                   and  c.component_sequence_id <> X_old_comp_seq_id
		   and  c.disable_date <> c.effectivity_date ) );
	 /*
	    union
            select 'x' -- duplicate value on unique index
            from bom_components_b c --bom_inventory_components c
            where c.bill_sequence_id = X_bill
            and c.component_item_id = X_component
            and c.operation_seq_num = X_operation
            and c.effectivity_date = eff_date
            AND   c.obj_name IS NULL -- added for bom_components_b
            and c.component_sequence_id <> X_comp_seq_id; */

        Cursor check_existing_unit(X_bill number, X_component number,
        X_operation number, X_comp_seq_id number, X_from_unit_number varchar2,
        X_to_unit_number varchar2) is
            Select 'x' -- overlapping effectivity
            from bom_components_b c--bom_inventory_components c
            where c.bill_sequence_id = X_bill
            and c.component_item_id = X_component
            and c.operation_seq_num = X_operation
            and c.implementation_date is not null
            AND   c.obj_name IS NULL -- added for bom_components_b
            and c.disable_date is NULL
            and (X_To_Unit_Number IS NULL
                 or (X_To_Unit_Number >= c.from_end_item_unit_number))
            and ((X_From_Unit_Number <=  c.to_end_item_unit_number)
                 or c.to_end_item_unit_number IS NULL);

        Cursor old_component(old_id number) is
            select o.change_notice,
                   o.implementation_date,
                   o.disable_date,
                   o.effectivity_date,
                   o.from_end_item_unit_number,
                   o.to_end_item_unit_number,
                   o.from_object_revision_id,
                   o.to_object_revision_id,
                   o.overlapping_changes,
                   o.component_sequence_id,
                   o.from_end_item_rev_id,
                   o.to_end_item_rev_id
            FROM bom_components_b o -- bom_inventory_components o
            where o.component_sequence_id = old_id
            for update of o.change_notice,
                          o.disable_date,
                          o.to_object_revision_id,
                          o.overlapping_changes,
                          o.last_update_date,
                          o.last_updated_by,
                          o.last_update_login,
                          o.request_id,
                          o.program_application_id,
                          o.program_id,
                          o.program_update_date;
        old_comp_rec  old_component%rowtype;
        Cursor count_ref_designators(comp_id number) is
            Select count(*)
            from   bom_reference_designators r
            where  r.component_sequence_id = comp_id
            and    nvl(r.acd_type, acd_add) = acd_add;
        ref_designator_count  number;
        X_GetInstallStatus boolean;
        X_InstallStatus varchar2(1) := 'N';
        X_Industry varchar2(1);
        X_prev_unit_number varchar2(30);
        X_UnitEff_RevItem varchar2(1) := 'N';
        X_new_structure_revision_id number := null;
        X_prev_structure_revision_id number := null;

-----------------------------------------------------------------
-- For ECO cumulative/ECO wip job/ECO lot  ---------8/2/2000----
-----------------------------------------------------------------
CURSOR check_job_valid_for_cum
   ( p_from_wip_entity_id NUMBER)
 IS
            SELECT wdj.scheduled_start_date,
                   wdj.scheduled_completion_date,
                   wdj.start_quantity,
                   wdj.net_quantity,
                   we.wip_entity_name,
                   wdj.bom_revision,
                   wdj.routing_revision,
                   wdj.bom_revision_date,
                   wdj.routing_revision_date
            FROM  wip_discrete_jobs wdj, wip_entities we
            WHERE wdj.wip_entity_id = p_from_wip_entity_id
            AND   we.wip_entity_id = wdj.wip_entity_id
            AND   wdj.status_type = 1;

cum_job_rec check_job_valid_for_cum%rowtype;

CURSOR check_job_valid_for_job
     ( p_from_wip_entity_id NUMBER,
       p_to_wip_entity_id   NUMBER,
       p_organization_id    NUMBER,
       p_effective_date     DATE )
IS
            SELECT 'X'
            FROM  DUAL
            WHERE  EXISTS (
                            SELECT 1
                            FROM wip_discrete_jobs wdj,
                                 wip_entities we,
                                 wip_entities we1,
                                 wip_entities we2
                             WHERE we1.wip_entity_id = p_from_wip_entity_id
                             AND  we2.wip_entity_id = p_to_wip_entity_id
                             AND  we.wip_entity_name >= we1.wip_entity_name
                             AND  we.wip_entity_name <= we2.wip_entity_name
                             AND  we.organization_id = p_organization_id
                             AND  wdj.wip_entity_id = we.wip_entity_id
                             AND (  wdj.status_type <> 1
                                  OR
				  (
				  wdj.scheduled_start_date < p_effective_date
				  and l_update_all_jobs = 2 -- Bug 5657390
				  )
		                 )
                         );

CURSOR check_job_valid_for_lot
       ( p_wip_lot_number VARCHAR2
       , p_effective_date DATE)
 IS
            SELECT 'X'
            FROM  DUAL
            WHERE  EXISTS (
                            SELECT 1
                            FROM   wip_discrete_jobs wdj, wip_entities we
                            WHERE  wdj.lot_number = p_wip_lot_number
                             AND   wdj.wip_entity_id = we.wip_entity_id
                             AND   wdj.primary_item_id = item.revised_item_id
                             AND   wdj.organization_Id = item.organization_id
                             AND (  status_type <> 1
                                  OR  (	wdj.scheduled_start_date < p_effective_date
	                                and l_update_all_jobs = 2 ) -- Bug 5662105
				  )
              );

CURSOR check_chng_rounting_existing( revised_item NUMBER) IS
            SELECT 'X'
            FROM bom_operation_sequences
            WHERE revised_item_sequence_id = revised_item;


CURSOR chng_operation_rows  IS
       SELECT change_notice
     , operation_seq_num
     , operation_sequence_id
     , old_operation_sequence_id
     , routing_sequence_id
     , acd_type
     , revised_item_sequence_id
     , disable_date
     , effectivity_date
 FROM bom_operation_sequences
 WHERE revised_item_sequence_id = revised_item
 AND    change_notice = item.change_notice
 FOR UPDATE OF change_notice
    , implementation_date
    , old_operation_sequence_id
    , acd_type
    , revised_item_sequence_id
    , effectivity_date
    , disable_date
    , last_update_date
    , last_updated_by
    , last_update_login
    , request_id
    , program_application_id
    , program_id
    , program_update_date
order by operation_sequence_id;

chng_operation_rec chng_operation_rows%rowtype;


CURSOR check_op_seq_num_exists IS
 SELECT 'X'
 FROM   bom_operation_sequences
 WHERE  operation_sequence_id = chng_operation_rec.old_operation_sequence_id
 AND    operation_seq_num = chng_operation_rec.operation_seq_num;

CURSOR unimplemented_rtg_rev
  IS
  SELECT  eri.new_routing_revision
  FROM   eng_engineering_changes eec,
         eng_revised_items eri
  WHERE  eec.change_notice = eri.change_notice
  AND     eec.organization_id = eri.organization_id
  AND     eri.organization_id = item.organization_id
  AND     eri.revised_item_id = item.revised_item_id
  AND     eec.status_type NOT IN
          ( cancelled_status, implemented_status)
  AND     eri.status_type NOT IN
          (cancelled_status, implemented_status)
  AND     nlssort(eri.new_routing_revision) <
          nlssort(item.new_routing_revision);

 unimp_ref_rec unimplemented_rtg_rev%ROWTYPE;

CURSOR check_highEffDate_lowRtgRev IS
SELECT   'x'
FROM   mtl_rtg_item_revisions r
WHERE    r.inventory_item_id = item.revised_item_id
  AND    r.organization_id = item.organization_id
  AND    r.effectivity_date > eff_date
  AND    r.process_revision < item.new_routing_revision --bug 3476154
  AND    r.implementation_date IS NOT null;


CURSOR get_common_routing  IS
  SELECT r.organization_id,
         r.assembly_item_id,
         r.routing_sequence_id
  FROM bom_operational_routings r
  WHERE  r.common_assembly_item_id = item.revised_item_id
  AND    r.common_routing_sequence_id = item.routing_sequence_id;

common_routing get_common_routing%ROWTYPE;

CURSOR get_common_current_routing_rev(common_assembly_item_id IN NUMBER,
                                common_org_id IN NUMBER) is
                Select r.process_revision
                from   mtl_rtg_item_revisions r
                where  r.inventory_item_id = common_assembly_item_id
                and    r.organization_id = common_org_id
                and    r.effectivity_date = (
                        select max(cr.effectivity_date)
                        from   mtl_rtg_item_revisions cr
                        where  cr.inventory_item_id = common_assembly_item_id
                        and    cr.organization_id = common_org_id
                        and    cr.implementation_date is not null
                        and    cr.effectivity_date <= eff_date);
common_current_rtg_rev  mtl_rtg_item_revisions.process_revision%type;

--* Added for Bug 4366583
Cursor routing_revision_exists(common_assembly_item_id IN NUMBER,
                       common_org_id IN NUMBER,
                       common_revision IN VARCHAR2) is
        select count(*)
        from mtl_rtg_item_revisions
        where inventory_item_id = common_assembly_item_id
        and organization_id = common_org_id
        and process_revision = common_revision;
l_rtg_revision_exists NUMBER;
--* End of Bug 4366583

CURSOR get_current_routing_rev  IS
SELECT r.process_revision,
       r.effectivity_date
FROM mtl_rtg_item_revisions r
WHERE  r.inventory_item_id = item.revised_item_id
AND   r.organization_id = item.organization_id
AND   r.effectivity_date = (
      SELECT max(cr.effectivity_date)
      FROM   mtl_rtg_item_revisions cr
      WHERE  cr.inventory_item_id = item.revised_item_id
      AND   cr.organization_id = item.organization_id
      AND   cr.implementation_date is not null
      AND   cr.effectivity_date <= eff_date);

current_routing_revision get_current_routing_rev%rowtype;

CURSOR check_not_existing_op_cum
    (p_from_wip_entity_id NUMBER,
     p_operation_seq_num NUMBER,
     p_organization_id NUMBER)
 IS
    SELECT 'X'
    FROM    wip_operations o,
            wip_discrete_jobs w
    WHERE  w.wip_entity_id  = p_from_wip_entity_id
    AND    w.status_type    = 1
    AND    o.wip_entity_id  = w.wip_entity_id
    AND    o.operation_seq_num = p_operation_seq_num
    AND    o.organization_id   = p_organization_id;

CURSOR check_not_existing_op_job
  (  p_from_wip_entity_id NUMBER,
     p_to_wip_entity_id   NUMBER,
     p_operation_seq_num      NUMBER,
     p_organization_id    NUMBER )
 IS
            SELECT 'X'
            FROM  DUAL
            WHERE  EXISTS (
                            SELECT 1
                            FROM wip_discrete_jobs wdj,
                                 wip_entities we,
                                 wip_entities we1,
                                 wip_entities we2
                            WHERE we1.wip_entity_id = p_from_wip_entity_id
                             AND  we2.wip_entity_id = p_to_wip_entity_id
                             AND  we.wip_entity_name >= we1.wip_entity_name
                             AND  we.wip_entity_name <= we2.wip_entity_name
                             AND  wdj.wip_entity_id = we.wip_entity_id
                             AND  we.organization_id = p_organization_id
                             AND  status_type = 1
                             AND  NOT EXISTS (
                                    SELECT 1
                                    FROM wip_operations wo
                                    WHERE wo.wip_entity_id = we.wip_entity_id
                                    AND operation_seq_num = p_operation_seq_num
                              )
              );

 CURSOR check_not_existing_op_lot
  ( p_wip_lot_number VARCHAR2,
    p_operation_seq_num  NUMBER
   )
 IS
            SELECT 'X'
            FROM  DUAL
            WHERE  EXISTS (
                            SELECT 1
                            FROM wip_discrete_jobs wdj
                            WHERE  wdj.lot_number= p_wip_lot_number
                             AND  wdj.status_type = 1
                             AND   wdj.primary_item_id = item.revised_item_id
                             AND   wdj.organization_Id = item.organization_id
                             AND  NOT EXISTS (
                                     SELECT 1
                                     FROM wip_operations wo
                                     WHERE wo.wip_entity_id = wdj.wip_entity_id
                                     AND operation_seq_num = p_operation_seq_num
                              )
 );

 Cursor old_operation(old_id number) is
            select o.change_notice,
                   o.implementation_date,
                   o.disable_date,
                   o.effectivity_date,
                   o.operation_sequence_id
            from bom_operation_sequences o
            where o.operation_sequence_id = old_id
            for update of o.change_notice,
                          o.disable_date,
                          o.last_update_date,
                          o.last_updated_by,
                          o.last_update_login,
                          o.request_id,
                          o.program_application_id,
                          o.program_id,
                          o.program_update_date;
 old_op_rec  old_operation%rowtype;

 CURSOR chng_resource_rows is
  SELECT  acd_type,
          operation_sequence_id,
          resource_seq_num,
          resource_id
  FROM    bom_operation_resources
  WHERE   operation_sequence_id= chng_operation_rec.operation_sequence_id;

  chng_resource_rec chng_resource_rows%rowtype;

 CURSOR check_overlapping_operation ( routing_seq_id NUMBER,
       operation_num NUMBER, operation_seq_id NUMBER, eff_date DATE)  IS
          Select 'x' -- overlapping effectivity
            from bom_operation_sequences b
            where b.routing_sequence_id= routing_seq_id
          --  and b.operation_sequence_id = operation_seq_id
            and b.operation_seq_num = operation_num
            and b.implementation_date is not null
            and b.effectivity_date <= eff_date
            and nvl(b.disable_date, eff_date + 1) > eff_date
            union
            select 'x' -- duplicate value on unique index
            from bom_operation_sequences b
            where b.routing_sequence_id= routing_seq_id
            and b.operation_seq_num = operation_num
            and b.effectivity_date = eff_date
            and b.operation_sequence_id <> operation_seq_id;

--for resources conflict check

CURSOR check_not_existing_res_cum
    ( p_from_wip_entity_id NUMBER,
      p_operation_seq_num  NUMBER,
      p_resource_seq_num   NUMBER,
      p_organization_id    NUMBER
     )
 IS
    SELECT 'X'
    FROM   wip_operation_resources wor,
           wip_discrete_jobs w
    WHERE  w.wip_entity_id = p_from_wip_entity_id
    AND    w.status_type = 1
    AND    wor.wip_entity_id = p_from_wip_entity_id
    AND    wor.operation_seq_num = p_operation_seq_num
    AND    wor.organization_id = p_organization_id
    AND    wor.resource_seq_num = p_resource_seq_num;

CURSOR check_not_existing_res_job
  (  p_from_wip_entity_id NUMBER,
     p_to_wip_entity_id   NUMBER,
     p_operation_seq_num  NUMBER,
     p_resource_seq_num   NUMBER,
     p_organization_id    NUMBER
  )
 IS
            SELECT 'X'
            FROM  DUAL
            WHERE  EXISTS (
                            SELECT 1
                            FROM wip_discrete_jobs wdj,
                                 wip_entities we,
                                 wip_entities we1,
                                 wip_entities we2
                             WHERE we1.wip_entity_id = p_from_wip_entity_id
                             AND  we2.wip_entity_id = p_to_wip_entity_id
                             AND  we.wip_entity_name >= we1.wip_entity_name
                             AND  we.wip_entity_name <= we2.wip_entity_name
                             AND  wdj.wip_entity_id = we.wip_entity_id
                             AND  we.organization_id = p_organization_id
                             AND  status_type = 1
                             AND  NOT EXISTS (
                                 SELECT 1
                                 FROM wip_operation_resources wor
                                 WHERE wor.wip_entity_id = we.wip_entity_id
                                 AND wor.operation_seq_num = p_operation_seq_num
                                 AND wor.resource_seq_num = p_resource_seq_num
                                 AND wor.organization_id = p_organization_id
                              )
              );

CURSOR check_not_existing_res_lot
  ( p_wip_lot_number    VARCHAR2,
    p_operation_seq_num NUMBER,
    p_resource_seq_num  NUMBER,
    p_organization_id   NUMBER
  )
IS
            SELECT 'X'
            FROM  DUAL
            WHERE  EXISTS (
                            SELECT 1
                            FROM wip_discrete_jobs wdj
                            WHERE  wdj.lot_number= p_wip_lot_number
                            AND   wdj.primary_item_id = item.revised_item_id
                            AND   wdj.organization_Id = item.organization_id
                            AND  wdj.status_type = 1
                            AND  NOT EXISTS (
                                 SELECT 1
                                 FROM wip_operation_resources wor
                                 WHERE wor.wip_entity_id = wdj.wip_entity_id
                                 AND wor.operation_seq_num = p_operation_seq_num
                                 AND wor.resource_seq_num = p_resource_seq_num
                                 AND wor.organization_id = p_organization_id
                              )
 );


-- for components
CURSOR check_not_existing_comp_cum
    (p_from_wip_entity_id  NUMBER,
     p_operation_seq_num   NUMBER,
     p_inventory_item_id   NUMBER,
     p_organization_id     NUMBER
     )
 IS
    SELECT 'X'
          FROM    wip_requirement_operations ro,
                 wip_discrete_jobs w
          WHERE  w.wip_entity_id = p_from_wip_entity_id
          AND    w.status_type = 1
          AND    ro.wip_entity_id       = p_from_wip_entity_id
          AND    ro.operation_seq_num   = p_operation_seq_num
          AND    ro.organization_id     = p_organization_id
          AND    ro.inventory_item_id   = p_inventory_item_id
           ;

CURSOR check_not_existing_comp_job
  (  p_from_wip_entity_id NUMBER,
     p_to_wip_entity_id   NUMBER,
     p_operation_seq_num  NUMBER,
     p_inventory_item_id  NUMBER,
     p_organization_id    NUMBER
   )
 IS
            SELECT 'X'
            FROM  DUAL
            WHERE  EXISTS (
                            SELECT 1
                            FROM wip_discrete_jobs wdj,
                                 wip_entities we,
                                 wip_entities we1,
                                 wip_entities we2
                             WHERE we1.wip_entity_id = p_from_wip_entity_id
                             AND  we2.wip_entity_id = p_to_wip_entity_id
                             AND  we.wip_entity_name >= we1.wip_entity_name
                             AND  we.wip_entity_name <= we2.wip_entity_name
                             AND  wdj.wip_entity_id = we.wip_entity_id
                             AND  we.organization_id = p_organization_id
                             AND  status_type = 1
                             AND  NOT EXISTS (
                                  SELECT 1
                                  FROM wip_requirement_operations ro
                                  WHERE ro.wip_entity_id = we.wip_entity_id
                                  AND ro.operation_seq_num = p_operation_seq_num
                                  AND ro.inventory_item_id= p_inventory_item_id
                                  AND ro.organization_id = p_organization_id
                              )
              );

CURSOR check_not_existing_comp_lot
  ( p_wip_lot_number    VARCHAR2,
    p_operation_seq_num NUMBER,
    p_inventory_item_id NUMBER,
    p_organization_id   NUMBER
  )
IS
            SELECT 'X'
            FROM  DUAL
            WHERE  EXISTS (
                            SELECT 1
                            FROM wip_discrete_jobs wdj
                            WHERE  wdj.lot_number= p_wip_lot_number
                            AND   wdj.primary_item_id = item.revised_item_id
                            AND   wdj.organization_Id = item.organization_id
                            AND    wdj.status_type = 1
                            AND    NOT EXISTS (
                               SELECT 1
                               FROM wip_requirement_operations ro
                               WHERE ro.wip_entity_id = wdj.wip_entity_id
                               AND ro.operation_seq_num = p_operation_seq_num
                               AND ro.inventory_item_id = p_inventory_item_id
                               AND ro.organization_id = p_organization_id
                              )
 );

-- Variables for ECO Enhancement
-- l_rtg_header_rec        BOM_Rtg_Pub.rtg_header_Rec_Type;
-- l_rtg_header_unexp_rec  BOM_Rtg_Pub.rtg_header_unexposed_Rec_Type;
-- l_mesg_token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
 l_alternate_routing_designator    VARCHAR2(10);
 l_return_status         VARCHAR2(1);

-- Vairables for update wip
  l_wip_group_id1               NUMBER ;
  l_wip_group_id2               NUMBER ;
  l_wip_header_id               NUMBER ;
  l_wip_organization_id         NUMBER;
  l_wip_load_type               NUMBER :=1;
  l_wip_status_type             NUMBER :=1;
  l_wip_primary_item_id         NUMBER;
  l_wip_bom_revision_date1      DATE;
  l_wip_routing_revision_date1  DATE;
  l_wip_bom_revision_date2      DATE;
  l_wip_routing_revision_date2  DATE;
  l_wip_job_name                VARCHAR2(240):=NULL;
  l_wip_job_name1               VARCHAR2(240):=NULL;
  l_wip_job_name2               VARCHAR2(240):=NULL;
  l_wip_start_quantity1         NUMBER;
  l_wip_start_quantity2         NUMBER;
  l_wip_process_phase           NUMBER :=2;
  l_wip_process_status          NUMBER :=1;
  l_wip_last_u_compl_date1      DATE;
  l_wip_last_u_compl_date2      DATE;
  l_wip_completion_locator_id   NUMBER;
  l_wip_routing_revision1       VARCHAR2(3):=NULL;
  l_wip_routing_revision2       VARCHAR2(3):=NULL;
  l_wip_bom_revision1           VARCHAR2(3):=NULL;
  l_wip_bom_revision2           VARCHAR2(3):=NULL;
  l_wip_completion_subinventory VARCHAR2(10):=NULL;
  l_wip_net_quantity1           NUMBER :=0;
  l_wip_net_quantity2           NUMBER :=0;
  l_wip_allow_explosion         VARCHAR2(1) := 'Y';
  l_wip_jsi_insert_flag         NUMBER :=0;
  l_old_op_seq_num              NUMBER :=0;    -- bug2722280

  l_update_wip                  NUMBER;
  l_wip_from_cum_qty            NUMBER;
  l_from_wip_entity_id          NUMBER;
  l_to_wip_entity_id            NUMBER;
  l_lot_number                  VARCHAR2(30):=NULL;
  --l_effective_date              date;
  --l_update_all_jobs             NUMBER := 2 ;     Bug 5657390 declared in the beginning
  l_eco_for_production          NUMBER := 2 ;

  -- Bug 4455543
  -- Added the following flag to check if routing details have been updated
  -- for the revised item. Only then the routing details are set on the
  -- wip_job_schedules_interface. Otherwise they are not set.
  -- This is done so that WIP does not explode routings when there has been
  -- no changes for them as part of the revised item.
  l_WIP_Flag_for_Routing   VARCHAR2(1);

-- for inserting rows to wip schedule interface

--  Cursor was added to resolve the bug 2722280
CURSOR get_old_operation_seq_num
  (  p_old_component_sequence_id NUMBER
   )
 IS

   SELECT operation_seq_num
   FROM   bom_components_b --bom_inventory_components
   WHERE  component_sequence_id = p_old_component_sequence_id ;
-- Cursor completed Bug 2722280

CURSOR l_wip_name_for_job_cur
 IS
         SELECT we.wip_entity_name,
                we.organization_id,
                wdj.start_quantity,
                wdj.scheduled_start_date,
                wdj.scheduled_completion_date,
                wdj.primary_item_id,
                wdj.alternate_bom_designator,           --2964588
                wdj.alternate_routing_designator,           --2964588
                wdj.bom_revision_date,
                wdj.routing_revision_date,
                null bom_revision,              -- Bug 3381547
                null routing_revision           -- Bug 3381547
         FROM wip_discrete_jobs wdj,
              wip_entities we,
              wip_entities we1,
              wip_entities we2
         WHERE we1.wip_entity_id = l_from_wip_entity_id
         AND  we2.wip_entity_id = l_to_wip_entity_id
         AND  ( (we.wip_entity_name >= we1.wip_entity_name
                and we.wip_entity_name <= we2.wip_entity_name)
              )
         AND  we.organization_id = l_wip_organization_id
         AND  wdj.wip_entity_id = we.wip_entity_id
         AND  wdj.status_type = 1
         AND  wdj.job_type = 1                -- 2986915
         AND  (( wdj.scheduled_start_date >= eff_date
                OR wdj.scheduled_completion_date >= eff_date)       --1900068
                OR l_update_all_jobs =1)                --bug 2327582.
 /* Modified for Bug 2883762 */
   UNION
          SELECT we.wip_entity_name,
                we.organization_id,
                wdj.start_quantity,
                wdj.scheduled_start_date,
                wdj.scheduled_completion_date,
                wdj.primary_item_id,
                wdj.alternate_bom_designator,           --2964588
                wdj.alternate_routing_designator,           --2964588
                wdj.bom_revision_date,
                wdj.routing_revision_date,
                wdj.bom_revision  bom_revision,               -- Bug 3381547
                wdj.routing_revision routing_revision         -- Bug 3381547
         FROM wip_discrete_jobs wdj,
              wip_entities we,
              wip_requirement_operations o,
              wip_entities we1,
              wip_entities we2
         WHERE wdj.wip_entity_id = we.wip_entity_id
           AND   we1.wip_entity_id = l_from_wip_entity_id
           AND  we2.wip_entity_id = l_to_wip_entity_id
           AND  ( (we.wip_entity_name >= we1.wip_entity_name
                and we.wip_entity_name <= we2.wip_entity_name)
              )

           AND  wdj.status_type = 1
         AND  wdj.job_type = 1                -- 2986915
           AND (( wdj.scheduled_start_date >= eff_date
             or wdj.scheduled_completion_date >= eff_date )          --1900068
             OR l_update_all_jobs =1)                         --bug 2327582
          AND wdj.organization_id = we.organization_id
          AND we.organization_id = o.organization_id
          AND we.wip_entity_id = o.wip_entity_id
          AND o.inventory_item_id = l_wip_primary_item_id
          AND o.organization_id = l_wip_organization_id
          AND o.repetitive_schedule_id is NULL
          AND o.wip_supply_type = 6 ;

wip_name_for_job_rec l_wip_name_for_job_cur%ROWTYPE;


CURSOR  l_wip_name_for_lot_cur
 IS
         SELECT we.wip_entity_name,
                we.organization_id,
                wdj.start_quantity,
                wdj.scheduled_start_date,
                wdj.scheduled_completion_date,
                wdj.primary_item_id,
                wdj.alternate_bom_designator,           --2964588
                wdj.alternate_routing_designator,           --2964588
                wdj.bom_revision_date,
                wdj.routing_revision_date,
                null bom_revision,            -- Bug 3381547
                null routing_revision         -- Bug 3381547
         FROM wip_discrete_jobs wdj,
              wip_entities we,
              bom_bill_of_materials b         --3412747
         WHERE we.organization_id = wdj.organization_id
         AND  we.wip_entity_id = wdj.wip_entity_id
         AND  wdj.status_type = 1
         AND  wdj.job_type = 1                -- 2986915
         AND (( wdj.scheduled_start_date >= eff_date
              or wdj.scheduled_completion_date >= eff_date)           --1900068
               OR l_update_all_jobs =1)             --bug 2327582
         AND  wdj.lot_number = l_lot_number
         --AND   wdj.primary_item_id = item.revised_item_id  --3412747
         AND  wdj.primary_item_id = b.assembly_item_id
         AND  wdj.organization_id = b.organization_id
         AND nvl(wdj.alternate_bom_designator,'NO ALTERNATE') =
                nvl(b.alternate_bom_designator,'NO ALTERNATE')
         --AND b.common_bill_sequence_id = item.bill_sequence_id
         AND b.source_bill_sequence_id = item.bill_sequence_id
          /* Modified for Bug 2883762 */
   UNION
          SELECT we.wip_entity_name,
                we.organization_id,
                wdj.start_quantity,
                wdj.scheduled_start_date,
                wdj.scheduled_completion_date,
                wdj.primary_item_id,
                wdj.alternate_bom_designator,           --2964588
                wdj.alternate_routing_designator,           --2964588
                wdj.bom_revision_date,
                wdj.routing_revision_date,
                wdj.bom_revision  bom_revision,               -- Bug 3381547
                wdj.routing_revision routing_revision         -- Bug 3381547
         FROM wip_discrete_jobs wdj,
              wip_entities we,
              wip_requirement_operations o
         WHERE wdj.wip_entity_id = we.wip_entity_id
           AND  wdj.status_type = 1
         AND  wdj.job_type = 1                -- 2986915
           AND (( wdj.scheduled_start_date >= eff_date
             or wdj.scheduled_completion_date >= eff_date )          --1900068
             OR l_update_all_jobs =1)                         --bug 2327582
          AND wdj.organization_id = we.organization_id
          AND we.organization_id = o.organization_id
          AND we.wip_entity_id = o.wip_entity_id
          AND o.inventory_item_id = l_wip_primary_item_id
          AND o.organization_id = l_wip_organization_id
          AND o.repetitive_schedule_id is NULL
          AND o.wip_supply_type = 6
          AND wdj.lot_number = l_lot_number;


wip_name_for_lot_rec l_wip_name_for_lot_cur%ROWTYPE;

CURSOR  l_wip_name_for_common_cur
 IS
         SELECT we.wip_entity_name,
                we.organization_id,
                wdj.start_quantity,
                wdj.scheduled_start_date,
                wdj.scheduled_completion_date,
                wdj.primary_item_id,
                wdj.alternate_bom_designator,           --2964588
                wdj.alternate_routing_designator,           --2964588
                wdj.bom_revision_date,
                wdj.routing_revision_date,
                null bom_revision,                         -- Bug 3381547
                null routing_revision                      -- Bug 3381547
         FROM wip_discrete_jobs wdj,
              wip_entities we,
              bom_bill_of_materials b                         --3412747
         WHERE we.organization_id = wdj.organization_id
         --WHERE we.organization_id = l_wip_organization_id
         AND  wdj.wip_entity_id = we.wip_entity_id
         AND  wdj.status_type = 1
         AND  wdj.job_type = 1                -- 2986915
         AND (( wdj.scheduled_start_date >= eff_date
              or wdj.scheduled_completion_date >= eff_date )          --1900068
             OR l_update_all_jobs =1)                         --bug 2327582
         --AND  wdj.primary_item_id = l_wip_primary_item_id   --3412747
         AND  wdj.primary_item_id = b.assembly_item_id
         AND  wdj.organization_id = b.organization_id
         AND nvl(wdj.alternate_bom_designator,'NO ALTERNATE') =
             nvl(b.alternate_bom_designator,'NO ALTERNATE')
         --AND b.common_bill_sequence_id = item.bill_sequence_id
         AND b.source_bill_sequence_id = item.bill_sequence_id
         AND  l_lot_number IS NULL
         AND  l_from_wip_entity_id IS NULL
         AND  l_to_wip_entity_id IS NULL
        /* Modified for Bug 2883762 */
         UNION
          SELECT we.wip_entity_name,
                we.organization_id,
                wdj.start_quantity,
                wdj.scheduled_start_date,
                wdj.scheduled_completion_date,
                wdj.primary_item_id,
                wdj.alternate_bom_designator,           --2964588
                wdj.alternate_routing_designator,           --2964588
                wdj.bom_revision_date,
                wdj.routing_revision_date,
                wdj.bom_revision  bom_revision,               -- Bug 3381547
                wdj.routing_revision routing_revision         -- Bug 3381547
         FROM wip_discrete_jobs wdj,
              wip_entities we,
              bom_bill_of_materials b,                        --3412747
              wip_requirement_operations o
         WHERE wdj.wip_entity_id = we.wip_entity_id
           AND  wdj.status_type = 1
         AND  wdj.job_type = 1                -- 2986915
           AND (( wdj.scheduled_start_date >= eff_date
             or wdj.scheduled_completion_date >= eff_date )          --1900068
             OR l_update_all_jobs =1)                         --bug 2327582
          AND wdj.organization_id = we.organization_id
          AND we.organization_id = o.organization_id
          AND we.wip_entity_id = o.wip_entity_id
          --AND o.inventory_item_id = l_wip_primary_item_id   --3412747
          --AND o.organization_id = l_wip_organization_id
          AND o.inventory_item_id = b.assembly_item_id
          AND o.organization_id = b.organization_id
          AND (nvl(wdj.alternate_bom_designator,'NO ALTERNATE') =
               nvl(b.alternate_bom_designator,'NO ALTERNATE')
               or
               (wdj.alternate_bom_designator is not null
                and
                b.alternate_bom_designator is null
                and not exists (select null
                                from bom_bill_of_materials b2
                                where b2.organization_id = b.organization_id
                                and b2.assembly_item_id = b.assembly_item_id
                                and b2.alternate_bom_designator =
                                    wdj.alternate_bom_designator)
               )
              )
          AND b.source_bill_sequence_id = item.bill_sequence_id -- r12 common bom changes
          --AND b.common_bill_sequence_id = item.bill_sequence_id
          AND o.repetitive_schedule_id is NULL
          AND o.wip_supply_type = 6 ;

wip_name_for_common_rec l_wip_name_for_common_cur%ROWTYPE;

    CURSOR mfgitem_already_exists(p_tomfg_item IN VARCHAR2)
    IS
        SELECT 1
        FROM mtl_system_items_kfv
        WHERE concatenated_segments = p_tomfg_item;

    CURSOR Get_starting_revision (p_org_id IN NUMBER)
    IS
            select starting_revision
            from mtl_parameters where
            organization_id = p_org_id;

    Cursor Check_Item(p_item_id  IN NUMBER,
                      p_org_id   IN NUMBER) is
    Select 'x' dummy
    From mtl_system_items msi
    Where msi.inventory_item_id = p_item_id
    And   msi.organization_id = p_org_id
    And   msi.eng_item_flag = 'N';

    Cursor Check_Bill(p_item_id   IN NUMBER,
                      p_org_id    IN NUMBER,
                      p_alternate IN VARCHAR2) is
    Select 'x' dummy
    From bom_bill_of_materials bbom
    Where bbom.assembly_item_id = p_item_id
    And   bbom.organization_id = p_org_id
    And   nvl(bbom.alternate_bom_designator, 'PRIMARY ALTERNATE') =
          nvl(p_alternate, 'PRIMARY ALTERNATE')
    And   bbom.assembly_type = 1;

    Cursor Check_Routing(p_item_id   IN NUMBER,
                         p_org_id    IN NUMBER,
                         p_alternate IN VARCHAR2) is
    Select 'x' dummy
    From bom_operational_routings bor
    Where bor.assembly_item_id = p_item_id
    And   bor.organization_id = p_org_id
    And   nvl(bor.alternate_routing_designator, 'PRIMARY ALTERNATE') =
          nvl(p_alternate, 'PRIMARY ALTERNATE')
    And   bor.routing_type = 1;

    l_item_revision               VARCHAR2(3);
    l_routing_revision            VARCHAR2(3);
    l_new_assembly_item_id        NUMBER;
    l_concatenated_copy_segments  VARCHAR2(2000);

    TYPE SEGMENTARRAY IS table of VARCHAR2(150) index by BINARY_INTEGER;

    copy_segments SEGMENTARRAY;
    l_language_code     VARCHAR2(10);  --Bug 2963301

    l_impl_date                         DATE;
    l_max_scheduled_date                DATE;
    l_implement_revised_item            NUMBER := 1;
    l_Item_rec_in                       INV_ITEM_GRP.Item_Rec_Type;
    l_revision_rec                      INV_ITEM_GRP.Item_Revision_Rec_Type;
    l_Item_rec_out                      INV_ITEM_GRP.Item_Rec_Type;
    l_inv_return_status                 VARCHAR2(1);
    l_Error_tbl                         INV_ITEM_GRP.Error_Tbl_Type;
    l_item_lifecycle_changed            NUMBER := 0;
    l_lc_return_status                  VARCHAR2(1);

    CURSOR c_local_org_rev_items (p_change_id                   NUMBER,
                                  p_revised_item_sequence_id    NUMBER
    ) IS
        SELECT scheduled_date, implementation_date
        FROM eng_revised_items
        WHERE revised_item_sequence_id IN
                (SELECT local_revised_item_sequence_id
                FROM eng_change_logs_vl
                WHERE (local_change_id, local_organization_id) IN
                        (SELECT object_to_id1, object_to_id3 -- local_change_id, local_org_id
                        From Eng_Change_Obj_Relationships
                        Where object_to_name = 'ENG_CHANGE'
                        and   change_id = p_change_id
                        And   relationship_code = 'PROPAGATED_TO')
                AND local_change_id IS NOT NULL
                AND local_revised_item_sequence_id IS NOT NULL
                AND log_classification_code = 'PROPAGATN'
                AND change_id = p_change_id
                AND revised_item_sequence_id =  p_revised_item_sequence_id
                AND log_type_code = 'INFO')
        AND status_type <> 5
        AND transfer_or_copy = 'O'
        AND parent_revised_item_seq_id IS NULL;

  -- Fix for bug 3463308
  l_item_key    VARCHAR2(240) := NULL;
  l_action_id   NUMBER := NULL;

  -- Added for bug 3482152
  l_curr_status_code            NUMBER;
  l_implement_header            VARCHAR2(1);
  l_plm_or_erp_change           VARCHAR2(3);
  l_wf_route_id                 NUMBER; -- Bug 3479509
  l_overlap_found               NUMBER;

  -- Added For 11510+ Enhancement

  l_effectivity_control         NUMBER;
  l_revision_eff_bill           VARCHAR2(1);
  l_from_rev_eff_date           DATE;
  l_to_rev_eff_date             DATE;
  l_old_from_rev_eff_date       DATE;
  l_old_to_rev_eff_date         DATE;
  l_from_revision               VARCHAR2(3);
  l_current_end_item_revision   VARCHAR2(3);
  l_to_revision                 VARCHAR2(3);
  l_from_end_item_id            NUMBER;
  l_disabled_old_comp           NUMBER;
  l_valid_from_to_revision      NUMBER;
  l_prev_end_item_rev_id        NUMBER;
  l_prev_end_item_eff           DATE;

  Cursor get_bill_effectivity_control (cp_bill_id NUMBER)
  Is
  SELECT effectivity_control
  FROM bom_structures_b
  WHERE bill_sequence_id = cp_bill_id;

  Cursor check_impl_revision ( cp_revision_id NUMBER
                             , cp_item_id     NUMBER
                             , cp_org_id      NUMBER)
  Is
  select effectivity_date, revision
  from mtl_item_revisions_b
  where revision_id = cp_revision_id
  and inventory_item_id = cp_item_id
  and organization_id = cp_org_id
  and implementation_date is not null;

  Cursor check_from_to_revision ( cp_from_rev_eff      DATE
                                , cp_comp_sequence_id  NUMBER)
  Is
  SELECT -1
  FROM bom_components_b bcb
  where bcb.component_sequence_id = cp_comp_sequence_id
  AND cp_from_rev_eff >= (SELECT mirb1.effectivity_date FROM mtl_item_revisions_b mirb1
                          WHERE mirb1.revision_id = bcb.from_end_item_rev_id)
  AND (bcb.to_end_item_rev_id is null
       OR cp_from_rev_eff <= (SELECT mirb2.effectivity_date FROM mtl_item_revisions_b mirb2
                              WHERE mirb2.revision_id = bcb.to_end_item_rev_id)
      );

  Cursor get_prev_impl_revision ( cp_item_id NUMBER
                                , cp_org_id NUMBER
                                , cp_effec_date DATE)
  Is
  Select mirb1.revision_id, mirb1.effectivity_date
  from mtl_item_revisions_b mirb1
  where mirb1.inventory_item_id =  cp_item_id
  and mirb1.organization_id = cp_org_id
  and mirb1.effectivity_date < cp_effec_date
  and mirb1.implementation_date is not null
  and rownum < 2
  order by mirb1.revision desc;

  Cursor check_existing_rev_eff_comp( cp_bill_id           NUMBER
                                    , cp_component_item_id NUMBER
                                    , cp_operation_seq_num NUMBER
                                    , cp_end_item_id       NUMBER
                                    , cp_org_id            NUMBER
                                    , cp_from_rev_eff      DATE
                                    , cp_to_rev_eff        DATE)
  Is
  SELECT 1
  FROM bom_components_b bcb
  where bcb.bill_sequence_id = cp_bill_id
  and bcb.component_item_id = cp_component_item_id
  and bcb.operation_seq_num = cp_operation_seq_num
  and bcb.implementation_date is not null
  and bcb.disable_date is NULL
  AND EXISTS (SELECT null FROM mtl_item_revisions_b mirb1 WHERE
              mirb1.inventory_item_id = cp_end_item_id AND mirb1.organization_id  = cp_org_id
              AND mirb1.revision_id = bcb.from_end_item_rev_id)
  AND ( cp_to_rev_eff IS NULL
        OR cp_to_rev_eff >= (SELECT mirb2.effectivity_date FROM mtl_item_revisions_b mirb2
                             WHERE mirb2.revision_id = bcb.from_end_item_rev_id)
      )
  AND ( bcb.to_end_item_rev_id IS NULL
        OR cp_from_rev_eff <= (SELECT mirb3.effectivity_date FROM mtl_item_revisions_b mirb3
                               WHERE mirb3.revision_id = bcb.to_end_item_rev_id)
      );
  -- End Changes: 11510+ Enhancement

  -- Added for bug 4150069
  -- Cusrsor to fetch the revision given the revision id.
  Cursor c_get_revision (cp_revision_id NUMBER)
  Is
  select revision, implementation_date
  from mtl_item_revisions_b
  where revision_id = cp_revision_id;

  l_revitem_from_rev    mtl_item_revisions_b.revision%TYPE;
  l_rev_impl_date       DATE;
  -- End Changes For bug 4150069
  -- Bug 4213886
  l_compitem_rev        mtl_item_revisions_b.revision%TYPE;
  l_compitem_rev_impldate DATE;

  -- R12 : Changes for common BOM
  CURSOR check_if_commoned_bom( cp_bill_id IN NUMBER) IS
  SELECT nvl(bsb.SOURCE_BILL_SEQUENCE_ID, bsb.BILL_SEQUENCE_ID) SOURCE_BILL_SEQUENCE_ID
  FROM bom_structures_b bsb
  WHERE bsb.source_bill_sequence_id = cp_bill_id
    AND bsb.bill_sequence_id <> bsb.source_bill_sequence_id;
  -- Cursor to fetch the valid value of effectivity date when the
  -- effectivity date is in the future.
  -- For common bom the component change made are to be immediately effective
  CURSOR get_common_bom_eff_date( cp_bill_id IN NUMBER, cp_rev_seq_id IN NUMBER ) IS
  SELECT bcb.effectivity_date
    FROM bom_components_b bcb
   WHERE bcb.revised_item_sequence_id = cp_rev_seq_id
     AND bcb.bill_sequence_id = cp_bill_id
     AND EXISTS
         (SELECT 1
            FROM bom_structures_b bsb
           WHERE bsb.bill_sequence_id = cp_bill_id
             AND bsb.bill_sequence_id <> bsb.source_bill_sequence_id)
     AND ROWNUM < 2;

  commoned_bom           check_if_commoned_bom%rowtype;
  l_common_bom_eff_date  DATE;
  l_comn_return_status   VARCHAR2(1);
  l_comn_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;
  -- R12 : End Changes for common BOM

  -- Bug 4584490 : Changes for BOM Business Events
  l_Comp_Child_Entity_Modified NUMBER;
  l_BOMEvents_Comps_ACD        NUMBER;
  l_BOMEvents_Bill_Event_Name  VARCHAR2(240);
  CURSOR c_Comp_Child_Entity_Modified(cp_component_sequence_id IN NUMBER)
  IS
  SELECT 1 FROM dual
   WHERE EXISTS (SELECT 1 FROM bom_substitute_components
                  WHERE component_sequence_id = cp_component_sequence_id
                    AND acd_type IS NOT NULL)
      OR EXISTS (SELECT 1 FROM bom_substitute_components
                  WHERE component_sequence_id = cp_component_sequence_id
                    AND acd_type IS NOT NULL);
  -- End Changes for bug 4584490

-- Bug 5854437 Start
        rec_exist               NUMBER := 0;
        l_error_msg_count       NUMBER := 0;

        Cursor chng_sub_component_rows is
        SELECT a.component_sequence_id,
                     b.old_component_sequence_id,
                     a.acd_type,
                     a.substitute_component_id,
                     f.concatenated_segments item_number
        FROM bom_substitute_components a,
                  bom_inventory_components b,
                  mtl_system_items_b_kfv f
        WHERE a.component_sequence_id = b.component_sequence_id
                  and b.revised_item_sequence_id = revised_item
                  and f.inventory_item_id = a.substitute_component_id
--                  and f.organization_id = item.organization_id
                  and f.organization_id = b.pk2_value
                  and nvl(a.acd_type,acd_add) = acd_add;

           Cursor check_existing_substitutes(X_old_comp_seq_id number,X_sub_comp_id number,X_change_notice varchar2) is
       select 'x'
            from bom_substitute_components a, bom_inventory_components b
               where a.component_sequence_id = b.component_sequence_id
               and b.component_sequence_id = X_old_comp_seq_id
               and nvl(a.acd_type, acd_add) = acd_add
               and b.change_notice = X_change_notice
               and a.substitute_component_id = X_sub_comp_id;
-- Bug 5854437 End

Begin

msg_qty := 0;
warnings := 0;
rev_op_disable_date_tbl.delete;
rev_comp_disable_date_tbl.delete;

-- Bug 4455543: Initialize l_WIP_Flag_for_Routing
l_WIP_Flag_for_Routing := 'N';
--

-- Get item information
Open get_item_info;
Fetch get_item_info into item;
/* -- changed for bug 2827313
Select trunc(sysdate, 'MI')
into   now
from dual;
today := trunc(now, 'DD');
*/
now := p_now;
today := now;

--Code changes for bug 5846248 starts
--If this is a transfer operation (or copy operation also--)
IF (Nvl(item.transfer_or_copy,'N') = 'T'  OR Nvl(item.transfer_or_copy,'N') = 'C') THEN
BEGIN
  IF(item.bom_enabled_flag = 'N' ) THEN
      -- The user cannot try to transfer/copy a bill or routings when the bom_enabled flag of the item is false..
      IF( item.transfer_or_copy_bill = 1 OR item.transfer_or_copy_routing = 1) THEN

            msg_qty := msg_qty + 1;
            message_names(msg_qty) :=
                      'ENG_CANNOT_TRANSFER_OR_COPY';
            token1(msg_qty) := 'ITEM_NAME';
            value1(msg_qty) := item.concatenated_segments;
            translate1(msg_qty) := 0;
            IF trial_mode = no THEN
                  Raise abort_implementation;
            END IF;

      END IF;
  END IF;
END;
END IF;

IF (Nvl(item.transfer_or_copy,'N') = 'T'  OR Nvl(item.transfer_or_copy,'N') = 'C') THEN
DECLARE
l_no_bom_dis_comps NUMBER;
l_no_bom_dis_sub_comps NUMBER;
BEGIN

      IF(item.transfer_or_copy_bill = 1 OR item.transfer_or_copy_routing = 1)  then
        IF(item.implemented_only = 1) THEN
            --if it's implemented only then check if it's already implemented or going to be implemented as a part of this change...
            select count(*) into l_no_bom_dis_comps from dual where exists(
              select 1 from mtl_system_items_b where inventory_item_id in
              (
                select COMPONENT_ITEM_ID from bom_components_b WHERE bill_sequence_id IN
                (
                  select bill_sequence_id from bom_bill_of_materials where
                  ASSEMBLY_ITEM_ID = item.revised_item_id AND
                  ORGANIZATION_ID = item.organization_id AND
                  (
                    (item.designator_selection_type = 1) --select everything
                    OR  (item.designator_selection_type =2 AND ALTERNATE_BOM_DESIGNATOR IS NULL) --select only primary BOM
                    OR (item.designator_selection_type = 3 AND ALTERNATE_BOM_DESIGNATOR = item.alternate_bom_designator) --select that particular  BOM
                  )
                )
                AND (CHANGE_NOTICE IS NULL OR IMPLEMENTATION_DATE IS NOT NULL OR  revised_item_sequence_id = revised_item)
              ) and organization_id = item.organization_id and bom_enabled_flag = 'N'
            );
        ELSE
            -- If implemented only is not set then check everything even other pending ECOS
            select count(*) into l_no_bom_dis_comps from dual where exists(
              select 1 from mtl_system_items_b where inventory_item_id in
              (
                select COMPONENT_ITEM_ID from bom_components_b WHERE bill_sequence_id IN
                (
                  select bill_sequence_id from bom_bill_of_materials where
                  ASSEMBLY_ITEM_ID = item.revised_item_id AND
                  ORGANIZATION_ID = item.organization_id   AND
                  (
                    (item.designator_selection_type = 1) --select everything
                    OR  (item.designator_selection_type =2 AND ALTERNATE_BOM_DESIGNATOR IS NULL) --select only primary BOM
                    OR (item.designator_selection_type = 3 AND ALTERNATE_BOM_DESIGNATOR = item.alternate_bom_designator) --select that particular  BOM
                  )
                )
             ) and organization_id = item.organization_id and bom_enabled_flag = 'N'
            );
        END IF;

        -- throw error if l_no_bom_dis_comps is greater than 0
        IF(l_no_bom_dis_comps >0) THEN
          msg_qty := msg_qty + 1;
          message_names(msg_qty) :=
                    'ENG_COMP_NOT_BOM_ENABLED';
          token1(msg_qty) := 'OPERATION_NAME';
          value1(msg_qty) := 'Implement';
          translate1(msg_qty) := 0;
          token2(msg_qty) :=  'RI_NAME';
          value2(msg_qty) :=  item.concatenated_segments;
          translate2(msg_qty) := 0;
          translate2(msg_qty) := 0;
          IF trial_mode = no THEN
                Raise abort_implementation;
          END IF;
        END IF;


        --Get all the sub components for which bom_enabled_flag is false...
        IF(item.implemented_only = 1) THEN
              select count(*) into l_no_bom_dis_sub_comps from dual where exists(
                select 1 from mtl_system_items_b WHERE  inventory_item_id IN
                (
                  --Get all the sub components for all the components for this item
                  select SUBSTITUTE_COMPONENT_ID from bom_substitute_components where COMPONENT_SEQUENCE_ID in(
                            -- Get all the components for this item
                            select COMPONENT_SEQUENCE_ID from bom_components_b WHERE bill_sequence_id IN
                            (
                              select bill_sequence_id from bom_bill_of_materials where
                              ASSEMBLY_ITEM_ID = item.revised_item_id AND
                              ORGANIZATION_ID = item.organization_id  AND
                              (
                                (item.designator_selection_type = 1) --select everything
                                OR  (item.designator_selection_type =2 AND ALTERNATE_BOM_DESIGNATOR IS NULL) --select only primary BOM
                                OR (item.designator_selection_type = 3 AND ALTERNATE_BOM_DESIGNATOR = item.alternate_bom_designator) --select that particular  BOM
                              )

                            ) AND (CHANGE_NOTICE IS NULL OR IMPLEMENTATION_DATE IS NOT NULL OR  revised_item_sequence_id = revised_item)
                  )
                )  and organization_id = item.organization_id and bom_enabled_flag = 'N'
              );
        ELSE
             select count(*) into l_no_bom_dis_sub_comps from dual where exists(
              select 1 from mtl_system_items_b WHERE  inventory_item_id IN
                (
                  --Get all the sub components for all the components for this item
                  select SUBSTITUTE_COMPONENT_ID from bom_substitute_components where COMPONENT_SEQUENCE_ID in(
                            -- Get all the components for this item
                            select COMPONENT_SEQUENCE_ID from bom_components_b WHERE bill_sequence_id IN
                            (
                              select bill_sequence_id from bom_bill_of_materials where
                              ASSEMBLY_ITEM_ID = item.revised_item_id AND
                              ORGANIZATION_ID = item.organization_id  AND
                              (
                                (item.designator_selection_type = 1) --select everything
                                OR  (item.designator_selection_type =2 AND ALTERNATE_BOM_DESIGNATOR IS NULL) --select only primary BOM
                                OR (item.designator_selection_type = 3 AND ALTERNATE_BOM_DESIGNATOR = item.alternate_bom_designator) --select that particular  BOM
                              )
                            )
                  )
               )  and organization_id = item.organization_id and bom_enabled_flag = 'N'
              );

        END IF;

        -- throw error if   l_no_bom_dis_sub_comps is greater than 0..
        IF(l_no_bom_dis_sub_comps > 0 ) THEN
            msg_qty := msg_qty + 1;
            message_names(msg_qty) :=
                      'ENG_SUB_COMP_NOT_BOM_ENABLED';
            token1(msg_qty) := 'OPERATION_NAME';
            value1(msg_qty) := 'Implement';
            translate1(msg_qty) := 0;
            token2(msg_qty) :=  'RI_NAME';
            value2(msg_qty) :=  item.concatenated_segments;
            translate2(msg_qty) := 0;
            translate2(msg_qty) := 0;
            IF trial_mode = no THEN
                Raise abort_implementation;
            END IF;
        END IF;
      END IF;
END;
END IF;


IF (Nvl(item.transfer_or_copy,'N') <> 'T'  AND Nvl(item.transfer_or_copy,'N') <> 'C') THEN
  -- This is not transfer or copy...
IF(item.bom_enabled_flag = 'N') THEN
  --check if there are any components for this tiem
  -- bug 5846248
   --If bom_enabled_flag is false.. there should be no components or sub components for this revised item...

  DECLARE
    l_no_components NUMBER;
    l_no_operations NUMBER;
  BEGIN
    --Note that in implementation we check only if there are any compoenents. Empty BOMs will be implemented
    --This is done because.. BOMs are created the first item we add a component in ECO.. but there is no way
    -- to delete that BOM, if the user wants to implement it by deleting the components and proceeding with other
    -- changes...
    SELECT Count(*) INTO l_no_components FROM dual WHERE EXISTS(
      select 1 from bom_components_b where bill_sequence_id in
      (
        select bill_sequence_id from bom_bill_of_materials where
        ASSEMBLY_ITEM_ID = item.revised_item_id AND
        ORGANIZATION_ID = item.organization_id
      ) AND revised_item_sequence_id = revised_item  AND acd_type <> acd_delete
    );

    IF(l_no_components <> 0) THEN
              msg_qty := msg_qty + 1;
              message_names(msg_qty) :=
                        'ENG_RI_NOT_BOM_ENABLED_COMP';
              token1(msg_qty) := 'OPERATION_NAME';
              value1(msg_qty) := 'Implement';
              translate1(msg_qty) := 0;
              token2(msg_qty) :=  'RI_NAME';
              value2(msg_qty) :=  item.concatenated_segments;
              translate2(msg_qty) := 0;
              IF trial_mode = no THEN
                  Raise abort_implementation;
              END IF;
            -- Need not code for substitute components in this flow because if there are components itself we are throwing an error
            -- so there is not way that there are substitute components, if we pass this condition
    END IF;

    --Check if there are any operations for this item ..
    --Again, we allow empty routings to get implemented for the same reason for which we allowe empty BOMs
    SELECT Count(*) INTO l_no_operations FROM dual WHERE EXISTS(
      select 1 FROM bom_operation_sequences WHERE routing_sequence_id IN
      (
        SELECT routing_sequence_id FROM BOM_OPERATIONAL_ROUTINGS WHERE
        ASSEMBLY_ITEM_ID = item.revised_item_id and
        ORGANIZATION_ID = item.organization_id
      ) AND revised_item_sequence_id = item.revised_item_sequence_id  AND acd_type <> acd_delete
    );

    IF(l_no_operations <> 0) THEN
              msg_qty := msg_qty + 1;
              message_names(msg_qty) :=
                        'ENG_RI_NOT_BOM_ENABLED_ROUT';
              token1(msg_qty) := 'OPERATION_NAME';
              value1(msg_qty) := 'Implement';
              translate1(msg_qty) := 0;
              token2(msg_qty) :=  'RI_NAME';
              value2(msg_qty) :=  item.concatenated_segments;
              translate2(msg_qty) := 0;
                translate2(msg_qty) := 0;
                IF trial_mode = no THEN
                    Raise abort_implementation;
                END IF;
    end if;
  END;
END IF;
-- bug 5846248
-- for any one of the components or substitue components have bom_enabled_flag as 'N' then throw an error,
-- even if the bom_enabled_flag of this revised item is 'Y'

  DECLARE

      no_bom_disabled_comps NUMBER;
      no_bom_disabled_sub_comps NUMBER;
  BEGIN
   --Check if there is atleast one component such that it's bom_enabled_flag is false for this Revised Item
   SELECT Count(*) INTO no_bom_disabled_comps FROM dual WHERE EXISTS(
      select 1 from mtl_system_items_b where inventory_item_id in
      (
        select COMPONENT_ITEM_ID from bom_components_b WHERE bill_sequence_id IN
        (
          select bill_sequence_id from bom_bill_of_materials where
          ASSEMBLY_ITEM_ID = item.revised_item_id AND
          ORGANIZATION_ID = item.organization_id
        )
        AND  revised_item_sequence_id = revised_item   AND acd_type <> acd_delete
     ) and organization_id = item.organization_id and bom_enabled_flag = 'N'
    );


    IF( no_bom_disabled_comps <> 0) THEN
        msg_qty := msg_qty + 1;
              message_names(msg_qty) :=
                        'ENG_COMP_NOT_BOM_ENABLED';
              token1(msg_qty) := 'OPERATION_NAME';
              value1(msg_qty) := 'Implement';
              translate1(msg_qty) := 0;
              token2(msg_qty) :=  'RI_NAME';
              value2(msg_qty) :=  item.concatenated_segments;
              translate2(msg_qty) := 0;
                translate2(msg_qty) := 0;
        IF trial_mode = no THEN
          Raise abort_implementation;
        END IF;
    END IF;

       --Check if there is atleast one sub component such that it's bom_enabled_flag is false for this Revised Item
    SELECT Count(*) INTO no_bom_disabled_sub_comps FROM dual WHERE EXISTS(
      select 1 from mtl_system_items_b WHERE  inventory_item_id IN
      (
        --Get all the sub components for all the components for this item
        select SUBSTITUTE_COMPONENT_ID from bom_substitute_components where COMPONENT_SEQUENCE_ID in(
          -- Get all the components for this item
          select COMPONENT_SEQUENCE_ID from bom_components_b WHERE bill_sequence_id IN
          (
            select bill_sequence_id from bom_bill_of_materials where
            ASSEMBLY_ITEM_ID = item.revised_item_id AND
            ORGANIZATION_ID = item.organization_id
          ) AND revised_item_sequence_id = revised_item  AND acd_type <> acd_delete
        ) AND acd_type <> acd_delete
      )  and organization_id = item.organization_id and bom_enabled_flag = 'N'
    );

    IF( no_bom_disabled_sub_comps <> 0) THEN
             msg_qty := msg_qty + 1;
              message_names(msg_qty) :=
                        'ENG_SUB_COMP_NOT_BOM_ENABLED';
              token1(msg_qty) := 'OPERATION_NAME';
              value1(msg_qty) := 'Implement';
              translate1(msg_qty) := 0;
              token2(msg_qty) :=  'RI_NAME';
              value2(msg_qty) :=  item.concatenated_segments;
              translate2(msg_qty) := 0;
                translate2(msg_qty) := 0;
          IF trial_mode = no then
            Raise abort_implementation;
          END IF;
    END IF;
  END;
END IF;

--Code changes for bug 5846248 ends

  --Code changes for Enhancement 6084027 start, update description while implementing the Co
   DECLARE
     l_new_description mtl_system_items_b.description%TYPE;
   BEGIN
     -- Get the new description from the eng_revised_items table
     -- check if the value is not null
     -- update the production if this value is not null
     -- Note: If the ECO fails these changes will be rollbacked automatically..
     SELECT new_item_description INTO l_new_description FROM eng_revised_items WHERE   revised_item_sequence_id = item.revised_item_sequence_id;

     IF (l_new_description IS NOT NULL)  THEN
       UPDATE mtl_system_items_tl SET description = l_new_description WHERE inventory_item_id = item.revised_item_id AND
                       organization_id  = item.organization_id AND source_lang = UserEnv('LANG');
     END IF;
   END;
   --Code changes for Enhancement 6084027 ends


-- ERES change begins
-- First Get the parent event details (ECO Implementation)
-- If the call fails or returns and error, the exception is not catched.
l_eres_enabled := FND_PROFILE.VALUE('EDR_ERES_ENABLED');
IF ( NVL( l_eres_enabled, 'N') = 'Y')
THEN
  QA_EDR_STANDARD.GET_ERECORD_ID
       ( p_api_version   => 1.0
       , p_init_msg_list => FND_API.G_TRUE
       , x_return_status => l_return_status
       , x_msg_count     => l_msg_count
       , x_msg_data      => l_msg_data
       , p_event_name    => 'oracle.apps.eng.ecoImplement'
       , p_event_key     => TO_CHAR(item.change_id)
       , x_erecord_id    => l_parent_record_id);

  -- When MassChangeBill, then an ECO Create is created.
  -- So, when procedure implement_revised_item is called,
  -- there is either an ECO implement event,
  -- or an ECO Create event created before.
  IF (l_parent_record_id IS NULL)
  THEN
    QA_EDR_STANDARD.GET_ERECORD_ID
       ( p_api_version   => 1.0
       , p_init_msg_list => FND_API.G_TRUE
       , x_return_status => l_return_status
       , x_msg_count     => l_msg_count
       , x_msg_data      => l_msg_data
       , p_event_name    => 'oracle.apps.eng.ecoCreate'
       , p_event_key     => TO_CHAR(item.change_id)
       , x_erecord_id    => l_parent_record_id);
  END IF;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'in Implement Revised Item. After Getting Parent Id, parent_erecord_id='||l_parent_record_id||', msg_cnt='||l_msg_count);
ELSE
  -- set the value to N in case it is NULL.
  l_eres_enabled := 'N';
END IF;
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Info: EDR_ERES_ENABLED='||l_eres_enabled);

-- ERES change ends

IF (Nvl(item.transfer_or_copy,'N') = 'T'  OR Nvl(item.transfer_or_copy,'N') = 'C') -- Check for Transfer/Copy OR Revised Item Change
THEN

  l_item_revision         := item.new_item_revision;
  l_routing_revision      := item.new_routing_revision;
  l_new_assembly_item_id  := item.revised_item_id;

  FOR i IN 1..20
  LOOP
    copy_segments(i) := Null;
  END LOOP;

  IF item.transfer_or_copy = 'C' THEN
    /* Check for the non existence of mfg item before copy */
    FOR r1 IN mfgitem_already_exists(item.copy_to_item)
    LOOP
            IF msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) :=
                                  'ENG_COPYTO_MFGITEM_EXISTS';
                        token1(msg_qty) :=  null;
                        value1(msg_qty) :=  null;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := null;
                        value2(msg_qty) := null;
                        translate2(msg_qty) := 0;
            END IF;
            IF trial_mode = no then
                        Raise abort_implementation;
            END IF;
    END LOOP;

    IF l_item_revision IS NULL
    THEN
      FOR r1 IN get_starting_revision(item.organization_id)
      LOOP
        l_item_revision := r1.starting_revision;
      END LOOP;
    END IF;

    IF l_routing_revision IS NULL
    THEN
      FOR r1 IN get_starting_revision(item.organization_id)
      LOOP
        l_routing_revision := r1.starting_revision;
      END LOOP;
    END IF;

    SELECT mtl_system_items_s.NEXTVAL INTO l_new_assembly_item_id FROM dual;

    SELECT concatenated_copy_segments INTO l_concatenated_copy_segments
       FROM eng_revised_items WHERE revised_item_sequence_id = item.revised_item_sequence_id;

    FOR i IN 1..20
    LOOP
      copy_segments(i) := substr(l_concatenated_copy_segments,
                                 to_number(instr(l_concatenated_copy_segments,fnd_global.local_chr(1),1,i))+1,
                                 ( to_number( instr(l_concatenated_copy_segments,fnd_global.local_chr(1),1,i+1) ) -
                                   to_number(instr(l_concatenated_copy_segments,fnd_global.local_chr(1),1,i)+1)) );
    END LOOP;

  END IF;

  -- ERES change begins
  -- Create child event Transfer or Copy ToManufacturing:
  IF (l_eres_enabled = 'Y')
  THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Preparing ERES. parent_erecord_id='||l_parent_record_id);

   l_event.param_name_1  := 'DEFERRED';
   l_event.param_value_1 := 'Y';

   l_event.param_name_2  := 'POST_OPERATION_API';
   l_event.param_value_2 := 'NONE';

   l_event.param_name_3  := 'PSIG_USER_KEY_LABEL';
   -- see later ... l_event.param_value_3 := '... ';

   l_event.param_name_4  := 'PSIG_USER_KEY_VALUE';
   -- see later ... l_event.param_value_4 := '... ';

   l_event.param_name_5  := 'PSIG_TRANSACTION_AUDIT_ID';
   l_event.param_value_5 := -1;

   l_event.param_name_6  := '#WF_SOURCE_APPLICATION_TYPE';
   l_event.param_value_6 := 'DB';

   l_event.param_name_7  := '#WF_SIGN_REQUESTER';
   l_event.param_value_7 := FND_GLOBAL.USER_NAME;

   IF (item.transfer_or_copy = 'C')
   THEN
    l_child_event_name := 'oracle.apps.eng.copyToManufacturing';
    FND_MESSAGE.SET_NAME('ENG', 'ENG_ERES_CPY2MANUF_USER_KEY');
    l_event.param_value_3 := FND_MESSAGE.GET;

    l_event.param_value_4 := item.concatenated_segments||'-'||item.organization_code||'-'||item.copy_to_item;

    l_temp_id := TO_CHAR(item.revised_item_id)||'-'||TO_CHAR(item.organization_id)||'-'||TO_CHAR(l_new_assembly_item_id);

  ELSIF (item.transfer_or_copy = 'T')
  THEN
    l_child_event_name := 'oracle.apps.eng.transferToManufacturing';
    FND_MESSAGE.SET_NAME('ENG', 'ENG_ERES_XFER2MANUF_USER_KEY');
    l_event.param_value_3 := FND_MESSAGE.GET;

    -- bug 3741224 : odaboval changed the userkey order:
    -- l_event.param_value_4 := item.concatenated_segments||'-'||item.organization_code;
    l_event.param_value_4 := item.organization_code||'-'||item.concatenated_segments;

    l_temp_id := TO_CHAR(item.revised_item_id)||'-'||TO_CHAR(item.organization_id);
  ELSE
    l_child_event_name := NULL;
    l_event.param_value_3 := 'NOT_FOUND';
    l_event.param_value_4 := 'NOT_FOUND';
    l_temp_id := '-1';
  END IF;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Creating event='||l_child_event_name);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'for event_key='||l_temp_id);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'for user_event_key='||l_event.param_value_4);

  IF (NVL(l_parent_record_id, -1) > 0)
  THEN
    --additional parameters for the child event
    l_event.param_name_8 := 'PARENT_EVENT_NAME';
    l_event.param_value_8 := 'oracle.apps.eng.ecoImplement';
    l_event.param_name_9 := 'PARENT_EVENT_KEY';
    l_event.param_value_9 := TO_CHAR(item.change_id);
    l_event.param_name_10 := 'PARENT_ERECORD_ID';
    l_event.param_value_10 := TO_CHAR(l_parent_record_id);
  END IF;

  -- Part 2 of preparation of child event :
  l_event.event_name   := l_child_event_name;
  l_event.event_key    := l_temp_id;
  -- l_event.payload      := l_payload;
  l_event.erecord_id   := l_erecord_id;
  l_event.event_status := l_event_status;

  -- populate the temporary table
  INSERT INTO eng_revised_items_temp
          ( temp_id
          , organization_id
          , organization_code
          , organization_name
          , inventory_item_id
          , item_number
          , item_description
          , transfer_or_copy_item
          , transfer_or_copy_bill
          , transfer_or_copy_routing
          , new_item_revision
          , new_routing_revision
          , designator_selection_type
          , alternate_bom_designator
          , change_notice
          , copy_to_item
          , copy_to_item_desc
          , transfer_or_copy
          , last_update_date
          , last_updated_by
          , creation_date
          , created_by)
   VALUES ( l_temp_id
          , item.organization_id
          , item.organization_code
          , item.organization_name
          , item.revised_item_id
          , item.concatenated_segments
          , item.description
          , item.transfer_or_copy_item
          , item.transfer_or_copy_bill
          , item.transfer_or_copy_routing
          , item.new_item_revision
          , item.new_routing_revision
          , item.designator_selection_type
          , item.alternate_bom_designator
          , item.change_notice
          , item.copy_to_item
          , item.copy_to_item_desc
          , item.transfer_or_copy
          , item.last_update_date
          , item.last_updated_by
          , item.creation_date
          , item.created_by);

    QA_EDR_STANDARD.RAISE_ERES_EVENT
           ( p_api_version      => 1.0
           , p_init_msg_list    => FND_API.G_FALSE
           , p_validation_level => FND_API.G_VALID_LEVEL_FULL
           , x_return_status    => l_return_status
           , x_msg_count        => l_msg_count
           , x_msg_data         => l_msg_data
           , p_child_erecords   => l_child_record
           , x_event            => l_event);

    IF (NVL(l_return_status, FND_API.G_FALSE) <> FND_API.G_TRUE)
      AND (l_msg_count > 0)
    THEN
       RAISE ERES_EVENT_ERROR;
    END IF;

    -- Keep the eRecord id :
    IF (NVL(l_event.erecord_id, -1) > 0)
    THEN
      INSERT INTO ENG_PARENT_CHILD_EVENTS_TEMP(parent_event_name
         , parent_event_key, parent_erecord_id
         , event_name, event_key, erecord_id
         , event_status)
      VALUES ( 'oracle.apps.eng.ecoImplement', TO_CHAR(item.change_id)
         , l_parent_record_id
         , l_event.event_name, l_event.event_key, l_event.erecord_id
         , l_event.event_status);

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'After event='||l_child_event_name||', eRecord_id='||l_event.erecord_id||', status='||l_event.event_status||', ev_key='||l_event.event_key);
    ELSE
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'No eRecord generated for '||l_event.event_name||'. This is normal. Please check your rules or other setups');
    END IF;
  END IF;   -- l_eres_enabled
  -- ERES change ends

-- Added procedure for bug 3584193
-- Description: The bill with unapproved items should not be allowed to be transferred through ECO.

-- If the Transfer/Copy Bill option is selected, then check for the unapproved items. Log error message if unapproved items found.
 IF item.transfer_or_copy_bill = 1 AND UNAPPROVED_COMPONENTS_EXISTS (item.revised_item_id, item.organization_id, item.designator_selection_type, item.alternate_bom_designator) THEN
        IF msg_qty < max_messages THEN
                msg_qty := msg_qty + 1;
                token1(msg_qty) := null;
                value1(msg_qty) := null;
                translate1(msg_qty) := 0;
                token2(msg_qty) := null;
                value2(msg_qty) := null;
                translate2(msg_qty) := 0;
                message_names(msg_qty) := 'ENG_UNAPPROVED_COMP_IN_BILL';
                IF trial_mode = no THEN
                        Raise abort_implementation;
                END IF;
        END IF;
 ELSE
                ENG_BOM_RTG_TRANSFER_PKG.ENG_BOM_RTG_TRANSFER(
                X_org_id                          => item.organization_id,
                X_eng_item_id                     => item.revised_item_id,
                X_mfg_item_id                     => l_new_assembly_item_id,
                X_transfer_option                 => item.selection_option,
                X_designator_option               => item.designator_selection_type,
                X_alt_bom_designator              => item.alternate_bom_designator,
                X_alt_rtg_designator              => item.alternate_bom_designator,
                X_effectivity_date                => item.selection_date,
                X_last_login_id                   => loginid,
                X_bom_rev_starting                => l_item_revision,
                X_rtg_rev_starting                => l_routing_revision,
                X_ecn_name                        => item.change_notice,
                X_item_code                       => item.transfer_or_copy_item,
                X_bom_code                        => item.transfer_or_copy_bill,
                X_rtg_code                        => item.transfer_or_copy_routing,
                X_mfg_description                 => item.copy_to_item_desc,
                X_segment1                        => copy_segments(1),
                X_segment2                        => copy_segments(2),
                X_segment3                        => copy_segments(3),
                X_segment4                        => copy_segments(4),
                X_segment5                        => copy_segments(5),
                X_segment6                        => copy_segments(6),
                X_segment7                        => copy_segments(7),
                X_segment8                        => copy_segments(8),
                X_segment9                        => copy_segments(9),
                X_segment10                       => copy_segments(10),
                X_segment11                       => copy_segments(11),
                X_segment12                       => copy_segments(12),
                X_segment13                       => copy_segments(13),
                X_segment14                       => copy_segments(14),
                X_segment15                       => copy_segments(15),
                X_segment16                       => copy_segments(16),
                X_segment17                       => copy_segments(17),
                X_segment18                       => copy_segments(18),
                X_segment19                       => copy_segments(19),
                X_segment20                       => copy_segments(20),
                X_implemented_only                => item.implemented_only,
                X_unit_number                   => item.selection_unit_number);
 END IF;

        IF (item.new_lifecycle_state_id IS NOT NULL AND item.new_lifecycle_state_id <> item.current_lifecycle_state_id )
        THEN

                CHANGE_ITEM_LIFECYCLE_PHASE (
                          p_rev_item_seq_id             => revised_item
                        , p_organization_id             => item.organization_id
                        , p_inventory_item_id           => item.revised_item_id
                        , p_scheduled_date              => item.scheduled_date
                        , p_new_lifecycle_phase_id      => item.new_lifecycle_state_id
                        , x_return_status               => l_lc_return_status);
                IF (l_lc_return_status <> 'S')
                THEN
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Change Item phase for transfer line Failed');
                        RAISE abort_implementation;
                END IF;
        END IF;


        IF ( p_is_lifecycle_phase_change = 2)
        THEN

  Update eng_revised_items
    set implementation_date = today,
        status_type = 6,
        last_update_date = sysdate,
        last_updated_by = userid,
        last_update_login = loginid,
        request_id = reqstid,
        program_application_id = appid,
        program_id = progid,
        program_update_date = sysdate,
        status_code = p_status_code
   where revised_item_sequence_id = item.revised_item_sequence_id;

        END IF;


 END IF;

 IF (item.transfer_or_copy = 'O')               -- if the item is obsoleted
 THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Processing obsolete Item .. ');

        l_max_scheduled_date := item.scheduled_date;
        l_implement_revised_item := 1;
        FOR li IN c_local_org_rev_items (item.change_id, item.revised_item_sequence_id)
        LOOP
                IF (li.implementation_date IS NULL )
                THEN
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'This item cannot be obsoleted since revised items propagated to the local organizations have not been implemented');
                        Raise abort_implementation;
                END IF;
                IF li.scheduled_date > l_max_scheduled_date THEN
                        l_max_scheduled_date := li.scheduled_date;
                END IF;

        END LOOP;
        /* reschedule the revised item if l_max_scheduled_date > item.scheduled_date*/
        IF ( l_max_scheduled_date > item.scheduled_date)
        THEN
                UPDATE eng_revised_items
                SET    scheduled_date = l_max_scheduled_date
                WHERE  revised_item_sequence_id = item.revised_item_sequence_id;
        END IF;

        IF (item.new_lifecycle_state_id IS NOT NULL AND item.new_lifecycle_state_id <> item.current_lifecycle_state_id )
        THEN
                CHANGE_ITEM_LIFECYCLE_PHASE (
                          p_rev_item_seq_id             => revised_item
                        , p_organization_id             => item.organization_id
                        , p_inventory_item_id           => item.revised_item_id
                        , p_scheduled_date              => l_max_scheduled_date
                        , p_new_lifecycle_phase_id      => item.new_lifecycle_state_id
                        , x_return_status               => l_lc_return_status);

                IF (l_lc_return_status <> 'S')
                THEN
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Change Item phase for obsolete item line Failed');
                        RAISE abort_implementation;
                END IF;
        END IF;

        l_Item_rec_in.INVENTORY_ITEM_ID :=  item.revised_item_id;
        l_Item_rec_in.ORGANIZATION_ID :=  item.Organization_Id;
        l_Item_rec_in.INVENTORY_ITEM_STATUS_CODE := 'Inactive';

        INV_Item_GRP.Update_Item (
                  p_Item_rec         =>  l_Item_rec_in
                , p_Revision_rec     =>  l_revision_rec
                , p_Template_Id      =>  NULL
                , p_Template_Name    =>  NULL
                , x_Item_rec         =>  l_Item_rec_out
                , x_return_status    =>  l_inv_return_status
                , x_Error_tbl        =>  l_Error_tbl );

        IF (l_inv_return_status <> 'S' )
        THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Change Item status to inactive Failed');
                Raise abort_implementation;
        END IF;

        IF (p_is_lifecycle_phase_change = 2 )
        THEN
                Update eng_revised_items
                set implementation_date = today,
                   status_type = 6,
                   last_update_date = sysdate,
                   last_updated_by = userid,
                   last_update_login = loginid,
                   request_id = reqstid,
                   program_application_id = appid,
                   program_id = progid,
                   program_update_date = sysdate,
                   status_code = p_status_code
                where revised_item_sequence_id = item.revised_item_sequence_id;
        END IF;

 ELSIF item.transfer_or_copy = 'L' THEN   --life cycle phase chnage

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Processing phase change Item .. ');
        IF (item.new_lifecycle_state_id IS NOT NULL AND item.new_lifecycle_state_id <> item.current_lifecycle_state_id )
        THEN
                CHANGE_ITEM_LIFECYCLE_PHASE (
                          p_rev_item_seq_id             => revised_item
                        , p_organization_id             => item.organization_id
                        , p_inventory_item_id           => item.revised_item_id
                        , p_scheduled_date              => item.scheduled_date
                        , p_new_lifecycle_phase_id      => item.new_lifecycle_state_id
                        , x_return_status               => l_lc_return_status);
                IF (l_lc_return_status <> 'S')
                THEN
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Change Item phase for phase change line Failed');
                        RAISE abort_implementation;
                END IF;
        END IF;

        IF (p_is_lifecycle_phase_change = 2)
        THEN

                Update eng_revised_items
                set implementation_date = today,
                   status_type = 6,
                   last_update_date = sysdate,
                   last_updated_by = userid,
                   last_update_login = loginid,
                   request_id = reqstid,
                   program_application_id = appid,
                   program_id = progid,
                   program_update_date = sysdate,
                   status_code = p_status_code
                where revised_item_sequence_id = item.revised_item_sequence_id;

        END IF;
END IF;

IF (p_is_lifecycle_phase_change = 1) THEN


  /* Implement Revised Item Change */


-- Effectivity date should be sysdate, if scheduled_date < sysdate
-- New eff_date included to fix bug #777353.

if (item.scheduled_date < now)
then
        eff_date := now;
        revision_high_date := now;
        rtg_revision_high_date := now;
else
        eff_date := item.scheduled_date;
        revision_high_date := item.scheduled_date;
        rtg_revision_high_date := item.scheduled_date;
end if;


/*** Added by 11.5.10 ***/
if (item.use_up_item_id is not null and item.disposition_type = 8) then
    --- 8 use_up =Exhaust WIP and Inventory
  if (inv_onhand(item.use_up_item_id, item.organization_id) <> 0) then
       	/* Fix for bug 5962435 - Added nvl around the profile,
	otherwise eff_date becomes null when that profile value is left blank.*/
        eff_date := eff_date + nvl(FND_PROFILE.VALUE('ENG:ENG_RESCHEDULE_DAYS_BY'),0);
  end if;
end if;
/***   ***/

Open get_current_rev;
Fetch get_current_rev into current_revision;
l_current_revision := current_revision.revision;
l_current_rev_eff_date := current_revision.effectivity_date;
Close get_current_rev;


Open get_current_routing_rev;
Fetch get_current_routing_rev into current_routing_revision;
l_current_rtg_revision := current_routing_revision.process_revision;
l_current_rtg_rev_eff_date := current_routing_revision.effectivity_date;
Close get_current_routing_rev;


bill_sequence_id    := nvl(item.bill_sequence_id,-1)   ;
routing_sequence_id := nvl(item.routing_sequence_id,-1);
update_wip          := item.update_wip;
eco_for_production  := item.eco_for_production;
l_wip_organization_id := item.organization_id;
l_wip_completion_subinventory := item.completion_subinventory;  -- Bug 5896479
l_wip_completion_locator_id   := item.completion_locator_id;    -- Bug 5896479

   -----------------------------------------------------------
   -- R12: Changes for Common BOM Enhancement
   -- Step 1: Initialization
   -----------------------------------------------------------
   g_Common_Rev_Comp_Tbl.delete;
   g_common_rev_comps_cnt := 0;
   isCommonedBOM := 'N';
   l_common_bom_eff_date := NULL;
   OPEN check_if_commoned_bom( item.bill_sequence_id);
   FETCH check_if_commoned_bom into commoned_bom;
   IF  check_if_commoned_bom%FOUND
   THEN
       isCommonedBOM := 'Y';
   END IF;
   CLOSE check_if_commoned_bom;
   IF isCommonedBOM = 'N' AND eff_date > sysdate
   THEN
       -- check if it is a common bom and fetch its effectivity date
       -- from the components records if the effectivity date is not now
       OPEN get_common_bom_eff_date( item.bill_sequence_id, item.revised_item_sequence_id);
       FETCH get_common_bom_eff_date into l_common_bom_eff_date;
       CLOSE get_common_bom_eff_date;
   END IF;
   -----------------------------------------------------------
   -- R12: End Step 1: Changes for Common BOM Enhancement --
   -----------------------------------------------------------
   -- Initialize For Business events
   l_BOMEvents_Comps_ACD := NULL;
   l_BOMEvents_Bill_Event_Name := NULL;
   -- End Initialize For Bom Business Events

-- Is Unit Effective Revised Item?

   If (PJM_UNIT_EFF.Enabled = 'Y' AND
            PJM_UNIT_EFF.Unit_Effective_Item(
                    X_Item_ID => item.revised_item_id,
                    X_Organization_ID => item.organization_id) = 'Y')
   then
        X_UnitEff_RevItem := 'Y';
   end if;
-- Is Order Entry Installed?

   X_GetInstallStatus := Fnd_Installation.get(
        appl_id => G_OrderEntry,
        dep_appl_id => G_OrderEntry,
        status => X_InstallStatus,
        industry => X_Industry);

   If not X_GetInstallStatus then
        X_InstallStatus := 'N';
   End if;

   -- Added validation for bug 4150069
   -- Check for revised items with unimplemented "From Revision".
   -- The value of "From revision" is saved in current_item_revision_id.
   -- In case of ECO Form the value of the current_item_revision_id will be:
   -- the current implemented revision of the item at the time of creation of the revised item.
   Open c_get_revision(item.current_item_revision_id);
   Fetch c_get_revision into l_revitem_from_rev, l_rev_impl_date;
   IF c_get_revision%FOUND AND l_rev_impl_date IS NULL
   THEN
       If msg_qty < max_messages
       Then
           msg_qty := msg_qty + 1;
           token1(msg_qty) := 'REVISION';
           value1(msg_qty) := l_revitem_from_rev;
           translate1(msg_qty) := 0;
           token2(msg_qty) := null;
           value2(msg_qty) := null;
           translate2(msg_qty) := 0;
           message_names(msg_qty) := 'ENG_REV_ITM_FROMREV_UNIMPL';
           IF trial_mode = no
           THEN
               Close c_get_revision;
               RAISE abort_implementation;
           END IF;
       End If;
   END IF;
   Close c_get_revision;
   -- End changes for bug 4150069

-- Check for rev items which are not active. Fix for bug 835813.
   Open check_rev_item_inactive;
   Fetch check_rev_item_inactive into dummy;
   If check_rev_item_inactive%found then
        If msg_qty < max_messages then
                msg_qty := msg_qty + 1;
                token1(msg_qty) := null;
                value1(msg_qty) := null;
                translate1(msg_qty) := 0;
                token2(msg_qty) := null;
                value2(msg_qty) := null;
                translate2(msg_qty) := 0;
                message_names(msg_qty) := 'ENG_REV_ITEM_INACTIVE';
                If trial_mode = no then
                        Raise abort_implementation;
                end if;
        end if;
   end if;
   Close check_rev_item_inactive;

If item.new_item_revision is not null then

--
-- Check if there exists an unimplemented ECO having the same
-- item and a new revision less than the new revision of this ECO.
-- if found, issue a warning only.
--

    Open unimplemented_rev;
    Fetch unimplemented_rev into unimp_rec;
    If unimplemented_rev%found then
        If msg_qty < max_messages then

        begin
                SELECT  substrb(profile_option_value,1,1)
                INTO    eco_rev_warning_flag
                FROM    fnd_profile_options opt,
                        fnd_application appl,
                        fnd_profile_option_values val
                WHERE   opt.application_id = val.application_id
                AND     opt.profile_option_id = val.profile_option_id
                AND     opt.application_id = appl.application_id
                AND     appl.application_short_name = 'ENG'
                AND     opt.profile_option_name = 'ENG:ECO_REV_WARNING'
                AND     val.level_id = 10001;
        exception
                when OTHERS then
                        eco_rev_warning_flag := 'Y';
        end;
                msg_qty := msg_qty + 1;
                token1(msg_qty) := null;
                value1(msg_qty) := null;
                translate1(msg_qty) := 0;
                token2(msg_qty) := null;
                value2(msg_qty) := null;
                translate2(msg_qty) := 0;

                if eco_rev_warning_flag = 'Y' then

                        warnings := warnings + 1;
                        message_names(msg_qty) := 'ENG_REV_PENDING';
                else
                        message_names(msg_qty) := 'ENG_REV_IMPL_ORDER';
                        If trial_mode = no then
                                Raise abort_implementation;
                        end if;
                end if;


        end if;
    end if;
    Close unimplemented_rev;

--
--   Check if there is a revision lower than new revision with higher eff date.
--   bug #737239.

     Open check_high_date_low_rev;
     Fetch check_high_date_low_rev into dummy;
     If check_high_date_low_rev%found then
        If msg_qty < max_messages then
                msg_qty := msg_qty + 1;
                token1(msg_qty) := null;
                value1(msg_qty) := null;
                translate1(msg_qty) := 0;
                token2(msg_qty) := null;
                value2(msg_qty) := null;
                translate2(msg_qty) := 0;
                message_names(msg_qty) := 'ENG_REVISION_ORDER';
                If trial_mode = no then
                        Raise abort_implementation;
                end if;
        end if;
     end if;
     Close check_high_date_low_rev;

--
--   Check if current revision is higher than new revision.
--

    If nlssort(l_current_revision) > nlssort(item.new_item_revision) then
                If msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) := 'ENG_CUR_REV_HIGHER';
                        token1(msg_qty) := 'ENTITY1';
                        value1(msg_qty) := item.new_item_revision;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := 'ENTITY2';
                        value2(msg_qty) := l_current_revision;
                        translate2(msg_qty) := 0;
                end if;
                If trial_mode = no then
                        Raise abort_implementation;
                end if;
    elsif nlssort(l_current_revision) < nlssort(item.new_item_revision) then

--
--   Implement the new revision.
--
        Update mtl_item_revisions_b   --changed mtl_item_revisions to mtl_item_revisions_b
        set implementation_date = today,
                effectivity_date = eff_date,
                last_update_date = sysdate,
                last_updated_by = userid,
                last_update_login = loginid,
                request_id = reqstid,
                program_application_id = appid,
                program_id = progid,
                program_update_date = sysdate
        where inventory_item_id = item.revised_item_id
        and   organization_id   = item.organization_id
        and   revision          = item.new_item_revision;

        -- R12: Business Event Enhancement:
        -- Raise Event if Revision got Updated successfully
        BEGIN
            INV_ITEM_EVENTS_PVT.Raise_Events(
             p_event_name        => 'EGO_WF_WRAPPER_PVT.G_REV_CHANGE_EVENT'
            ,p_dml_type          => 'UPDATE'
            ,p_inventory_item_id => item.revised_item_id
            ,p_organization_id   => item.organization_id
            ,p_revision_id       => item.new_item_revision_id );
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
        -- R12: Business Event Enhancement:
        -- Raise Event if Revision got Updated successfully


--
--   Implement the new revision in common bills also.
--   Fixed bug #747439.
--
        OPEN get_common_bills;
        LOOP
                FETCH get_common_bills into common;
                EXIT WHEN get_common_bills%NOTFOUND;

                OPEN get_common_current_rev(
                        common_assembly_item_id=>common.assembly_item_id,
                        common_org_id          =>common.organization_id);
                FETCH get_common_current_rev into common_current_rev;
                CLOSE get_common_current_rev;

                --* Added for Bug 4366583
                OPEN revision_exists(
                             common_assembly_item_id=>common.assembly_item_id,
                             common_org_id          =>common.organization_id,
                     common_revision        =>item.new_item_revision);
                     FETCH revision_exists into l_revision_exists;
                CLOSE revision_exists;
                --* End of Bug 4366583

                if (( nlssort(common_current_rev) < nlssort(item.new_item_revision))
                    and  ( l_revision_exists = 0)) --* AND condition added for Bug 4366583
                then
                        ENG_COPY_TABLE_ROWS_PKG.C_MTL_ITEM_REVISIONS(
                                X_inventory_item_id => common.assembly_item_id,
                                X_organization_id => common.organization_id,
                                X_revision => item.new_item_revision,
                                X_last_update_date => SYSDATE,
                                X_last_updated_by => userid,
                                X_creation_date => SYSDATE,
                                X_created_by => userid,
                                X_last_update_login => loginid,
                                X_effectivity_date => eff_date,
                                X_change_notice => item.change_notice,
                                X_implementation_date => today);
               --Start of changes Bug 2963301
                Begin
                  SELECT userenv('LANG') INTO l_language_code FROM dual;
                      Update mtl_item_revisions_tl MIR
                       set description =
                          (select MIR1.description
                            from   mtl_item_revisions_tl MIR1
                            where revision_id IN (SELECT revision_id
                                                  FROM   MTL_ITEM_REVISIONS_B
                                                  WHERE
                                                          inventory_item_id  = item.revised_item_id
                                                and       organization_id = item.organization_id
                                                and       revision = item.new_item_revision)
                            and language    =   l_language_code
                          )
                       where inventory_item_id = common.assembly_item_id
                       and   organization_id = common.organization_id
                       and   revision_id  in  (SELECT revision_id
                                                  FROM   MTL_ITEM_REVISIONS_B
                                                  WHERE
                                                          inventory_item_id  = common.assembly_item_id
                                                and       organization_id =    common.organization_id
                                                and       revision = item.new_item_revision);

                Exception
                        When Others then
                                NULL;
                End;
                --End of changes Bug 2963301
                end if;
        END LOOP;
        CLOSE get_common_bills ;   -- Closed this Cursor for Bug #3102887
--   end fix #747439.

    end if;

end if; -- end of "if new_item_revision is not null"

   --- as there is no updation of description ,updation to mtl_item_revisions_tl is not required
   -- Moved this code here so that  if new revision gets implemented rev effective structure will get implement successfully 	5243333
   -- Added For 11510+ Enhancement
   -- Fetch the effectivity control of the bill
   Open get_bill_effectivity_control(bill_sequence_id);
   Fetch get_bill_effectivity_control into l_effectivity_control;
   Close get_bill_effectivity_control;
   -- Is the effectivity control End-item-revision Effectivity
   l_revision_eff_bill := 'N';
   If (l_effectivity_control = 4)
   Then
       l_revision_eff_bill := 'Y';
       Open check_impl_revision(item.from_end_item_rev_id, item.from_end_item_id, item.organization_id);
       Fetch check_impl_revision into l_from_rev_eff_date, l_from_revision;
       Close check_impl_revision;
       l_from_end_item_id := item.from_end_item_id;
       l_current_end_item_revision :=
          BOM_REVISIONS.GET_ITEM_REVISION_FN('ALL', 'IMPL_ONLY', item.organization_id, item.from_end_item_id, now);
   End If;
   -- End 11510+ Enhancement

	-- Added to support structure revision
	If item.new_structure_revision is not null then
		-- Call BOM API to create new BOM revision
		X_new_structure_revision_id := null;
		X_prev_structure_revision_id := null;
	End if;



--
--  Implement Item Pending Changes
--  In R12
--  ENG_IMPL_ITEM_CHANGES_PKG.impl_item_changes API
--  implement all Item Pending Changes
BEGIN

--    SAVEPOINT ITEM_CHG ;

    FND_FILE.NEW_LINE(FND_FILE.LOG);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Implement Item Pending Changes ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'==================================================');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Before: ENG_IMPL_ITEM_CHANGES_PKG.impl_item_changes ');

    l_return_status := FND_API.G_RET_STS_SUCCESS;
    plsql_block := 'BEGIN
                      FND_MSG_PUB.initialize ;
                      ENG_IMPL_ITEM_CHANGES_PKG.impl_item_changes
                      ( p_api_version    => 1.0
                      , p_change_id      => :a
                      , p_change_line_id => :b
                      , x_return_status  => :c
                      , x_msg_count      => :d
                      , x_msg_data       => :e );
                    END ; ' ;

    EXECUTE IMMEDIATE plsql_block USING
                    '',                   -- p_change_id
                    revised_item,         -- p_change_line_id
                    OUT l_return_status,  -- x_return_status
                    OUT l_msg_count,      -- x_msg_count
                    OUT l_msg_data;       -- x_msg_data

    FND_FILE.PUT_LINE(FND_FILE.LOG,'After: ENG_IMPL_ITEM_CHANGES_PKG.impl_item_changes: Return Status=' || l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
        FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CALLING_PS_API');
        FND_MESSAGE.Set_Token('OBJECT_NAME'
                              ,'ENG_IMPL_ITEM_CHANGES_PKG.impl_item_changes') ;
        FND_MSG_PUB.Add;

        RAISE FND_API.G_EXC_ERROR;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'==================================================');

EXCEPTION
    WHEN PLSQL_COMPILE_ERROR THEN
        null;

    WHEN FND_API.G_EXC_ERROR THEN

FND_FILE.PUT_LINE(FND_FILE.LOG,'ENG_IMPL_ITEM_CHANGES_PKG.impl_item_changes failed ');
FND_FILE.PUT_LINE(FND_FILE.LOG,'--------------------------------------------------');
--        ROLLBACK TO SAVEPOINT ITEM_CHG ;

        FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP

FND_FILE.PUT_LINE(FND_FILE.LOG,'Message Number : '|| I );
FND_FILE.PUT_LINE(FND_FILE.LOG,'DATA = '||replace(substr(FND_MSG_PUB.Get(I), 1, 200), chr(0), ' '));

            IF msg_qty < max_messages
            then
                msg_qty := msg_qty + 1;
                message_names(msg_qty) := 'ENG_IMPL_ITEM_CHANGE_FAIL' ;
                token1(msg_qty) :=  'MSG_TEXT';
                value1(msg_qty) := replace(substr(FND_MSG_PUB.Get(I), 1, 80), chr(0), ' ');
                translate1(msg_qty) := 0;
                token2(msg_qty) := null;
                value2(msg_qty) := null;
                translate2(msg_qty) := 0;
            END IF;


        END LOOP;


FND_FILE.PUT_LINE(FND_FILE.LOG,'==================================================');

        IF trial_mode = no then
             Raise abort_implementation;
        END IF;



    WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Other Unexpected Error: '|| substr(SQLERRM,1,200));

FND_FILE.PUT_LINE(FND_FILE.LOG,'--------------------------------------------------');
FND_FILE.PUT_LINE(FND_FILE.LOG,'ROLL BACK TO ITEM_CHG');
--        ROLLBACK TO SAVEPOINT ITEM_CHG ;


        IF msg_qty < max_messages
        then
            msg_qty := msg_qty + 1;
            message_names(msg_qty) := 'ENG_IMPL_ITEM_CHANGE_FAIL' ;
            token1(msg_qty) :=  'MSG_TEXT';
            value1(msg_qty) := substr(SQLERRM, 1, 80);
            translate1(msg_qty) := 0;
            token2(msg_qty) := null;
            value2(msg_qty) := null;
            translate2(msg_qty) := 0;
        END IF;

FND_FILE.PUT_LINE(FND_FILE.LOG,'--------------------------------------------------');


FND_FILE.PUT_LINE(FND_FILE.LOG,'==================================================');

        IF trial_mode = no then
             Raise abort_implementation;
        END IF;

END;

-----------------------------------------------------------------
-- For ECO cumulative/ECO wip job/ECO lot   ---------8/2/2000----
 IF  item.eco_for_production =1
 THEN
   IF item.from_wip_entity_id IS NULL
   AND item.to_wip_entity_id IS  NULL
   AND item.from_cum_qty IS NULL
   AND item.lot_number IS  NULL
   THEN
            IF msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) :=
                                  'ENG_IMP_ECO_JOB_ONLY_CHECKED';
                        token1(msg_qty) :=  null;
                        value1(msg_qty) :=  null;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := null;
                        value2(msg_qty) := null;
                        translate2(msg_qty) := 0;
            END IF;
            IF trial_mode = no then
                        Raise abort_implementation;
            END IF;
   END IF;

   IF item.new_item_revision IS NOT NULL
   OR item.new_routing_revision IS NOT  NULL
   THEN
            IF msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) :=
                                  'ENG_IMP_INVALID_REVISION';
                        token1(msg_qty) :=  null;
                        value1(msg_qty) :=  null;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := null;
                        value2(msg_qty) := null;
                        translate2(msg_qty) := 0;
            END IF;
            IF trial_mode = no then
                        Raise abort_implementation;
            END IF;
   END IF;

   IF  NOT (  item.from_wip_entity_id IS NOT NULL
                  and item.to_wip_entity_id IS NOT NULL
                  and item.from_cum_qty IS NULL
                  and item.lot_number is NULL
               OR item.from_wip_entity_id IS NOT NULL
                  and item.to_wip_entity_id IS NULL
                  and item.from_cum_qty IS NOT NULL
                  and item.lot_number is NULL
               OR item.from_wip_entity_id IS  NULL
                  and item.to_wip_entity_id IS NULL
                  and item.from_cum_qty IS  NULL
                  and item.lot_number IS NOT NULL
                )
   THEN
            IF msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) :=
                                  'ENG_IMP_INVALID_JOB_SPEC';
                        token1(msg_qty) :=  null;
                        value1(msg_qty) :=  null;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := null;
                        value2(msg_qty) := null;
                        translate2(msg_qty) := 0;
            END IF;
            IF trial_mode = no then
                        Raise abort_implementation;
            END IF;

   END IF;
  END IF;

  IF  item.eco_for_production =2
  AND ( item.from_wip_entity_id IS NOT NULL
       or item.to_wip_entity_id IS NOT NULL
       or item.from_cum_qty IS NOT NULL
       or item.lot_number is NOT NULL )
  THEN
            IF msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) :=
                                  'ENG_IMP_ECO_JOB_ONLY_UNCHECKED';
                        token1(msg_qty) :=  null;
                        value1(msg_qty) :=  null;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := null;
                        value2(msg_qty) := null;
                        translate2(msg_qty) := 0;
            END IF;
            IF trial_mode = no then
                        Raise abort_implementation;
            END IF;

  END IF;


 IF item.update_wip = 1 and item.mrp_active = 2
 THEN
     -- For ECO cumulative type
     IF  NVL(item.from_cum_qty, 0) > 0
     THEN
        OPEN check_job_valid_for_cum
         ( p_from_wip_entity_id => item.from_wip_entity_id);
        FETCH check_job_valid_for_cum INTO cum_job_rec;
        IF check_job_valid_for_cum %NOTFOUND
        THEN
            IF msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) :=
                                  'ENG_NO_VALID_WO_FOR_ECO_CUM';
                        token1(msg_qty) :=  null;
                        value1(msg_qty) :=  null;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := null;
                        value2(msg_qty) := null;
                        translate2(msg_qty) := 0;
            END IF;
            IF trial_mode = no then
                        Raise abort_implementation;
            END IF;
        ELSIF  (item.from_cum_qty >  cum_job_rec.start_quantity  )
           THEN  IF msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) :=
                                  'ENG_INVALID_START_QTY_ECO_CUM';
                        token1(msg_qty) :=  null;
                        value1(msg_qty) :=  null;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := null;
                        value2(msg_qty) := null;
                        translate2(msg_qty) := 0;
                END IF;
                IF trial_mode = no then
                        Raise abort_implementation;
                END IF;
        ELSIF  eff_date >  cum_job_rec.scheduled_start_date
             THEN  IF msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) :=
                                  'ENG_INVALID_EFF_DATE_ECO_CUM';
                        token1(msg_qty) :=  null;
                        value1(msg_qty) :=  null;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := null;
                        value2(msg_qty) := null;
                        translate2(msg_qty) := 0;
                END IF;
                IF trial_mode = no then
                        Raise abort_implementation;
                END IF;

      END IF;   --  end of check_job_valid_for_cum %NOTFOUND


      -- set the following variables used in insert WIP schedule interface.
     l_wip_start_quantity1       := item.from_cum_qty - 1;
     l_wip_start_quantity2       := cum_job_rec.start_quantity-item.from_cum_qty + 1;
     IF  cum_job_rec.start_quantity = cum_job_rec.net_quantity
     THEN
       l_wip_net_quantity1         :=  l_wip_start_quantity1;
       l_wip_net_quantity2         :=  l_wip_start_quantity2;
     ELSE
       l_wip_net_quantity1         :=
          round(cum_job_rec.net_quantity*l_wip_start_quantity1/cum_job_rec.start_quantity+0.5);
       l_wip_net_quantity2         :=
          round(cum_job_rec.net_quantity*l_wip_start_quantity2/cum_job_rec.start_quantity+0.5);
     END IF;
     l_wip_job_name              := cum_job_rec.wip_entity_name;
     l_wip_bom_revision1         := cum_job_rec.bom_revision;
     l_wip_routing_revision1     := cum_job_rec.routing_revision;

/*     select effectivity_date into l_wip_bom_revision_date1
     from mtl_item_revisions
     where inventory_item_id = item.revised_item_id
     and revision = l_wip_bom_revision1
     and organization_id = item.organization_id;

     select effectivity_date into l_wip_routing_revision_date1
     from mtl_rtg_item_revisions
     where inventory_item_id = item.revised_item_id
     and process_revision = l_wip_routing_revision1
     and organization_id = item.organization_id;
*/


--     l_wip_bom_revision_date1    := cum_job_rec.bom_revision_date;
--     l_wip_routing_revision_date1:= cum_job_rec.routing_revision_date;
     l_wip_last_u_compl_date2    :=  cum_job_rec.scheduled_completion_date;

      Generate_New_Wip_Name(
       p_wip_entity_name => l_wip_job_name
      ,p_organization_id => item.organization_id
      ,x_wip_entity_name1   => l_wip_job_name1
      ,x_wip_entity_name2   => l_wip_job_name2
      ,x_return_status   => l_return_status
     );

     -- set the values for out type parameters
     wip_job_name1 := l_wip_job_name1;
     wip_job_name2 :=  l_wip_job_name2;
     wip_job_name2_org_id := item.organization_id;


     IF l_return_status <>0
     THEN IF msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) :=
                                  'ENG_NEW_WIP_JOB_NAMES_ERROR';
                        token1(msg_qty) :=  'WIP_JOB_NAME';
                        value1(msg_qty) :=  l_wip_job_name;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := null;
                        value2(msg_qty) := null;
                        translate2(msg_qty) := 0;
          END IF;
          IF trial_mode = no then
                Raise abort_implementation;
          END IF;
      END IF;   --  end of l_return_status <>0

      CLOSE check_job_valid_for_cum;
  ELSIF NVL(item.from_cum_qty,0) < 0
     THEN
               IF msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) :=
                                  'ENG_INVALID_START_QTY_ECO_CUM';
                        token1(msg_qty) :=  null;
                        value1(msg_qty) :=  null;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := null;
                        value2(msg_qty) := null;
                        translate2(msg_qty) := 0;
                END IF;
                IF trial_mode = no then
                        Raise abort_implementation;
                END IF;
  END IF;       --  end of NVL(item.start_quantity,0) > 0

 -- For ECO job type
 IF nvl(item.to_wip_entity_id, 0) <> 0
 THEN

   /*  IF nvl(item.from_wip_entity_id, 0 ) > nvl(item.to_wip_entity_id, 0 )
     THEN
        IF msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) :=
                                  'ENG_INVALID_EFF_WIP_JOB_IN_ECO_JOB';
                        token1(msg_qty) :=  null;
                        value1(msg_qty) :=  null;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := null;
                        value2(msg_qty) := null;
                        translate2(msg_qty) := 0;
         END IF;
         IF trial_mode = no then
          Raise abort_implementation;
         END IF;
       END IF;            -- IF nvl(item.to_wip_entity_id, 0 )
   */


     OPEN check_job_valid_for_job
      ( p_from_wip_entity_id => item.from_wip_entity_id,
       p_to_wip_entity_id   => item.to_wip_entity_id,
       p_effective_date     => eff_date,
       p_organization_id    => item.organization_id
      );
     FETCH check_job_valid_for_job  INTO dummy;
     IF check_job_valid_for_job%FOUND
     THEN

         IF msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) :=
                                  'ENG_INVALID_WO_ECO_JOB';
                        token1(msg_qty) :=  null;
                        value1(msg_qty) :=  null;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := null;
                        value2(msg_qty) := null;
                        translate2(msg_qty) := 0;
         END IF;
         IF trial_mode = no then
                        Raise abort_implementation;
         END IF;
     END IF;          --  check_job_valid_for_job

     l_from_wip_entity_id := item.from_wip_entity_id;
     l_to_wip_entity_id   := item.to_wip_entity_id;

     CLOSE check_job_valid_for_job;

   END IF;            -- IF nvl(item.to_wip_entity_id, 0) <> 0

  -- For ECO lot type
IF item.lot_number IS NOT NULL
THEN
    OPEN check_job_valid_for_lot
     ( p_wip_lot_number => item.lot_number,
       p_effective_date => eff_date);
    FETCH check_job_valid_for_lot  INTO dummy;
    IF check_job_valid_for_lot%FOUND
    THEN  IF msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) :=
                                  'ENG_INVALID_WO_EXITS_ECO_LOT';
                        token1(msg_qty) :=  null;
                        value1(msg_qty) :=  null;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := null;
                        value2(msg_qty) := null;
                        translate2(msg_qty) := 0;
         END IF;
         IF trial_mode = no then
           Raise abort_implementation;
         END IF;
     END IF;            --  check_job_valid_for_lot
     l_lot_number := item.lot_number;

     CLOSE check_job_valid_for_lot;
  END IF;                  --  IF item.lot_number IS NOT NULL
 END IF;
                  -- update_wip = 1



-- Validate the new routing revision
-- If new routing revision is not null, check the followings.

   IF item.new_routing_revision IS NOT NULL
   THEN
     -- Check if there exists an unimplemented  ECO having the same revised
     -- item and a  routing revision less than the new revision of this
     --   routing. If found, issue a warning only

      OPEN unimplemented_rtg_rev;
      FETCH unimplemented_rtg_rev INTO unimp_ref_rec;
      IF unimplemented_rtg_rev%FOUND
      THEN
        If msg_qty < max_messages then

        begin
                SELECT  substrb(profile_option_value,1,1)
                INTO    eco_rev_warning_flag
                FROM    fnd_profile_options opt,
                        fnd_application appl,
                        fnd_profile_option_values val
                WHERE   opt.application_id = val.application_id
                AND     opt.profile_option_id = val.profile_option_id
                AND     opt.application_id = appl.application_id
                AND     appl.application_short_name = 'ENG'
                AND     opt.profile_option_name = 'ENG:ECO_REV_WARNING'
                AND     val.level_id = 10001;
        exception
                when OTHERS then
                        eco_rev_warning_flag := 'Y';
        end;
                msg_qty := msg_qty + 1;
                token1(msg_qty) := null;
                value1(msg_qty) := null;
                translate1(msg_qty) := 0;
                token2(msg_qty) := null;
                value2(msg_qty) := null;
                translate2(msg_qty) := 0;

                if eco_rev_warning_flag = 'Y' then

                        warnings := warnings + 1;
                        message_names(msg_qty) := 'ENG_RTG_REV_PENDING';
                else
                        message_names(msg_qty) := 'ENG_RTG_REV_IMPL_ORDER';
                        If trial_mode = no then
                                Raise abort_implementation;
                        end if;
                end if;
       END IF;       -- end of check_existing_diff_rev
     END IF;         -- end of check_existing_diff_rev %FOUND

     CLOSE unimplemented_rtg_rev;

     -- Check if there is a routing revision lower than new routing revision
     -- with  higher effective date.
     --   OPEN check_high_eff_date_low_rtg_rev;
     OPEN check_highEffDate_lowRtgRev;
     FETCH check_highEffDate_lowRtgRev INTO dummy;
     IF check_highEffDate_lowRtgRev%FOUND
     THEN
       If msg_qty < max_messages then
                msg_qty := msg_qty + 1;
                token1(msg_qty) := null;
                value1(msg_qty) := null;
                translate1(msg_qty) := 0;
                token2(msg_qty) := null;
                value2(msg_qty) := null;
                translate2(msg_qty) := 0;
                message_names(msg_qty) := 'ENG_RTG_REVISION_ORDER';
                If trial_mode = no then
                        Raise abort_implementation;
                end if;
        end if;


     END IF;
     CLOSE check_highEffDate_lowRtgRev;


     -- Check if the current revision is higher than new revision
  /*   OPEN get_current_routing_rev;
     FETCH get_current_routing_rev into current_routing_revision  ;
     CLOSE get_current_routing_rev;
  */
     IF nlssort(l_current_rtg_revision) >
                nlssort(item.new_routing_revision)
     THEN
     If msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) := 'ENG_CUR_RTG_REV_HIGHER';
                        token1(msg_qty) := 'ENTITY1';
                        value1(msg_qty) := item.new_item_revision;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := 'ENTITY2';
                        value2(msg_qty) := l_current_revision;
                        translate2(msg_qty) := 0;
                end if;
                If trial_mode = no then
                        Raise abort_implementation;
        end if;

       /*Bug 5256284    Added below IF condition to check whether the current rtg rev is less than new rtg rev.
       Implement the new rtg rev only if it is greater than (and not equal to) the current rtg rev.
       This is done to prevent the updation of the effectivity_date of the current rtg rev.*/

      ELSIF nlssort(l_current_rtg_revision) < nlssort(item.new_routing_revision)  THEN
     -- implement the new routing revision
     UPDATE mtl_rtg_item_revisions
     SET        implementation_date = today,
                effectivity_date = eff_date,
                last_update_date = sysdate,
                last_updated_by = userid,
                last_update_login = loginid,
                request_id = reqstid,
                program_application_id = appid,
                program_id = progid,
                program_update_date = sysdate
     WHERE  inventory_item_id = item.revised_item_id
     AND   organization_id   = item.organization_id
     AND   process_revision  = item.new_routing_revision;

     -- ERES changes begin : bug 3908563
     IF SQL%ROWCOUNT > 0
     THEN
       -- ERES flag to be set for triggering Routing Event:
       bERES_Flag_for_Routing := TRUE;
       -- Bug 4455543: Set l_WIP_Flag_for_Routing when routing revision is being updated by revised item
       l_WIP_Flag_for_Routing := 'Y';
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'in mtl_rtg_item_revisions... bERES_Flag_for_Routing=TRUE');
     END IF;
     -- ERES changes end.

    END IF;   -- end of nlssort(current_routing_revision)

    -- implement the new revision in common routing too

    OPEN get_common_routing;
        LOOP
                FETCH get_common_routing into common_routing;
                EXIT WHEN get_common_routing %NOTFOUND;

                OPEN get_common_current_routing_rev
                (common_assembly_item_id => common_routing.assembly_item_id,
   --2809431        common_org_id  => common.organization_id
                 common_org_id           => common_routing.organization_id
                ) ;


                FETCH get_common_current_routing_rev into
                        common_current_rtg_rev;
                CLOSE get_common_current_routing_rev;

                --* Added for Bug 4366583
                OPEN routing_revision_exists(
                             common_assembly_item_id=>common_routing.assembly_item_id,
                             common_org_id          =>common_routing.organization_id,
                    common_revision        =>item.new_routing_revision);
                     FETCH routing_revision_exists into l_rtg_revision_exists;
                CLOSE routing_revision_exists;
                --* End of Bug 4366583

   -- 2809431   IF nlssort(common_current_rev)
                IF nlssort(common_current_rtg_rev)   -- added for BUG 2809431
                            < nlssort( item.new_routing_revision)
                   AND l_rtg_revision_exists = 0 --* AND condition added for bug 4366583
                THEN
                    --- Update the revision to new revision
                    --- See if existing API can be used here
                  --- 2809431 NULL;
         -- 2809431 ( added the below API to Populate common routing revision)


                     ENG_COPY_TABLE_ROWS_PKG.C_MTL_RTG_ITEM_REVISIONS(
                         X_inventory_item_id => common_routing.assembly_item_id,
                         X_organization_id => common_routing.organization_id,
                         X_process_revision => item.new_routing_revision,
                         X_last_update_date => SYSDATE,
                         X_last_updated_by => userid,
                         X_creation_date => SYSDATE,
                         X_created_by => userid,
                         X_last_update_login => loginid,
                         X_effectivity_date => eff_date,
                         X_change_notice => item.change_notice,
                         X_implementation_date => today);

         -- 2809431 ( added the above API to Populate common routing revision)
              END IF;
        END LOOP;
    CLOSE get_common_routing;

  END IF;            -- IF item.new_routing_revision IS NOT NULL

  --If routing  change exists, Update routing header.
  --A new routing header should be generated from Form.
  -- Using RTG BO
  IF item.routing_sequence_id IS NOT NULL
  THEN
    SELECT alternate_routing_designator
    INTO  l_alternate_routing_designator
    FROM  bom_operational_routings
    WHERE routing_sequence_id  = item.routing_sequence_id;
/*
    BOM_Rtg_Header_Util.Query_Row
        (  p_assembly_item_id       => item.revised_item_id
         , p_organization_id        => item.organization_id
         , p_alternate_routing_code => l_alternate_routing_designator
         , x_rtg_header_rec         => l_rtg_header_rec
         , x_rtg_header_unexp_rec   => l_rtg_header_unexp_rec
         , x_Return_status          => l_Return_status
        );

   l_rtg_header_rec.cfm_routing_flag :=
          NVL(item.cfm_routing_flag, l_rtg_header_rec.cfm_routing_flag);
   l_rtg_header_rec.completion_subinventory :=
   NVL(item.completion_subinventory, l_rtg_header_rec.completion_subinventory);
   l_rtg_header_unexp_rec.completion_locator_id:=
   NVL(item.completion_locator_id, l_rtg_header_unexp_rec.completion_locator_id);
   l_rtg_header_rec.mixed_model_map_flag :=
         NVL(item.mixed_model_map_flag, l_rtg_header_rec.mixed_model_map_flag);
*/

   SELECT
     routing_sequence_id
    ,cfm_routing_flag
    ,completion_subinventory
    ,completion_locator_id
    ,mixed_model_map_flag
    ,common_assembly_item_id
    ,common_routing_sequence_id
    ,ctp_flag
    ,priority
    ,routing_comment
   INTO
     l_routing_sequence_id
    ,l_cfm_routing_flag
    ,l_completion_subinventory
    ,l_completion_locator_id
    ,l_mixed_model_map_flag
    ,l_common_assembly_item_id
    ,l_common_routing_sequence_id
    ,l_ctp_flag
    ,l_priority
    ,l_routing_comment
   FROM  bom_operational_routings
   WHERE  assembly_item_id = item.revised_item_id
   AND  organization_id  = item.organization_id
   AND  NVL(alternate_routing_designator, 'NULL_ALTERNATE_DESIGNATOR' )
                    = NVL(l_alternate_routing_designator,  'NULL_ALTERNATE_DESIGNATOR')
    ;

 --start of bugfix 3234628
    IF item.completion_subinventory IS NOT NULL OR
       item.completion_locator_id IS NOT NULL OR
       item.ctp_flag = 1 OR
       item.priority IS NOT NULL OR
       item.routing_comment IS NOT NULL
    THEN

                   UPDATE bom_operational_routings
                   SET common_assembly_item_id =
                             l_common_assembly_item_id
                     , common_routing_sequence_id =
                             l_common_routing_sequence_id
                     , ctp_flag = NVL(item.ctp_flag,l_ctp_flag)
                     , priority = NVL(item.priority,l_priority)
                     , cfm_routing_flag =
                         NVL(item.cfm_routing_flag, l_cfm_routing_flag)
                     , routing_comment =
                         NVL(item.routing_comment, l_routing_comment)
                     , mixed_model_map_flag =
                          NVL(item.mixed_model_map_flag, l_mixed_model_map_flag)
                     , completion_subinventory =
                          NVL(item.completion_subinventory, l_completion_subinventory)
                     , completion_locator_id =
                          NVL(item.completion_locator_id, l_completion_locator_id)
                     , last_update_date =  SYSDATE
                     , last_updated_by =    userid
                     , last_update_login =  loginid
                  WHERE routing_sequence_id =
                             l_routing_sequence_id;

         -- ERES changes begin : bug 3908563
         IF SQL%ROWCOUNT > 0
         THEN
           -- ERES flag to be set for triggering Routing Event:
           bERES_Flag_for_Routing := TRUE;
           -- Bug 4455543: Set l_WIP_Flag_for_Routing when routing header is being updated by revised item
           l_WIP_Flag_for_Routing := 'Y';
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'in bom_operational_routings ... bERES_Flag_for_Routing=TRUE');
         END IF;
         -- ERES changes end.
    END IF;
 --end of bugfix 3234628
 END IF;      -- enf of IF item.routing_sequence_id IS NOT NULL


--Check if there are revised operations or events for the routing.

 OPEN chng_operation_rows;
 LOOP
    FETCH chng_operation_rows  into chng_operation_rec;
    EXIT WHEN chng_operation_rows %NOTFOUND;


    --check the ECO operation conflict
    IF item.update_wip = 1
    AND chng_operation_rec.acd_type IN (acd_change, acd_delete)
    THEN

       -- For ECO Cumulative type record
       -- Check if the current operation is not existing in
       -- the specified WIP discrete job.
     IF  NVL(item.from_cum_qty, 0) > 0
     THEN
       OPEN check_not_existing_op_cum
       ( p_from_wip_entity_id => item.from_wip_entity_id,
         p_operation_seq_num  => chng_operation_rec.operation_seq_num,
         p_organization_id    => item.organization_id ) ;
       FETCH check_not_existing_op_cum INTO dummy;
       IF check_not_existing_op_cum%NOTFOUND
       THEN If msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) := 'ENG_OP_ECO_CUM_CONFLICT';
                        token1(msg_qty) := 'REVISED_ITEM';
                        value1(msg_qty) := item.revised_item_id;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := 'OPERATION_SEQ_NUM';
                        value2(msg_qty) :=
                              chng_operation_rec.operation_seq_num;
                        translate2(msg_qty) := 0;
             end if;
             If trial_mode = no then
                        Raise abort_implementation;
             end if;
       END IF;
       CLOSE check_not_existing_op_cum;
      END IF;        -- end of IF NVL(item.from_cum_qty, 0) > 0

       -- For ECO Discrete Job type record
       -- At the WIP job range ( from_wip_job_name, to_wip_job_name),
       -- check if there is a WIP discrete job,  in which the current
       -- operation has already disabled or changed.
      IF nvl(item.to_wip_entity_id, 0) <> 0
      THEN
        OPEN check_not_existing_op_job
        (  p_from_wip_entity_id => item.from_wip_entity_id,
          p_to_wip_entity_id   => item.to_wip_entity_id,
          p_operation_seq_num  => chng_operation_rec.operation_seq_num,
          p_organization_id    => item.organization_id) ;
        FETCH check_not_existing_op_job INTO dummy;
        IF check_not_existing_op_job%FOUND
        THEN If msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) := 'ENG_OP_ECO_JOB_CONFLICT';
                        token1(msg_qty) := 'REVISED_ITEM';
                        value1(msg_qty) := item.revised_item_id;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := 'OPERATION_SEQ_NUM';
                        value2(msg_qty) :=
                              chng_operation_rec.operation_seq_num;
                        translate2(msg_qty) := 0;
             end if;
             If trial_mode = no then
                        Raise abort_implementation;
             end if;

        END IF;
        CLOSE check_not_existing_op_job ;
       END IF;    -- nvl(item.to_wip_entity_id, 0) <> 0


       -- For ECO Lot type record
       -- Among WIP discrete jobs with  same specified lot number, check
       -- if there is a WIP discrete job,  in which the current opertion has
       -- already been disabled or changed.
      IF item.lot_number IS NOT NULL
      THEN
        OPEN check_not_existing_op_lot
        (  p_wip_lot_number     => item.lot_number,
           p_operation_seq_num  =>  chng_operation_rec.operation_seq_num);
        FETCH check_not_existing_op_lot INTO dummy;
        IF check_not_existing_op_lot%FOUND
        THEN If msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) := 'ENG_OP_ECO_LOT_CONFLICT';
                        token1(msg_qty) := 'REVISED_ITEM';
                        value1(msg_qty) := item.revised_item_id;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := 'OPERATION_SEQ_NUM';
                        value2(msg_qty) :=
                              chng_operation_rec.operation_seq_num;
                        translate2(msg_qty) := 0;
             end if;
             If trial_mode = no then
                        Raise abort_implementation;
             end if;
        END IF;
        CLOSE  check_not_existing_op_lot;
      END IF;     -- item.lot_number IS NOT NULL
    END IF;       -- end of IF item.update_wip = 1


    -- For operation ADD/Change type records, check the effectivity of
    -- operation

    IF chng_operation_rec.acd_type IN (acd_change, acd_add)
    THEN

        IF NVL(chng_operation_rec.disable_date, eff_date)  < eff_date
        THEN If msg_qty < max_messages then
                msg_qty := msg_qty + 1;
                message_names(msg_qty) := 'ENG_OP_INVALID_DISABLE_DATE';
                token1(msg_qty) := 'OPERATION_SEQ_NUM';
                value1(msg_qty) := chng_operation_rec.operation_seq_num;
                translate1(msg_qty) := 0;
                token2(msg_qty) := 'DISABLE_DATE';
                value2(msg_qty) :=
                              chng_operation_rec.disable_date;
                        translate2(msg_qty) := 0;
             end if;
             If trial_mode = no then
                        Raise abort_implementation;
             end if;
        END IF;


   END IF;             -- end of IF chng_operation_rec.acd_type IN (acd_add, acd_change)


   IF chng_operation_rec.acd_type IN ( acd_change, acd_delete)
   THEN

            Open old_operation(chng_operation_rec.old_operation_sequence_id);
            Fetch old_operation into old_op_rec;

            If old_op_rec.implementation_date is null then
                        If msg_qty < max_messages then
                                msg_qty := msg_qty + 1;
                                message_names(msg_qty) :=
                                        'ENG_OLD_OP_UNIMPLEMENTED';
                                token1(msg_qty) := 'ITEM';
                                value1(msg_qty) := item.revised_item_id;
                                translate1(msg_qty) := 0;
                                token2(msg_qty) := 'OPERATION';
                                value2(msg_qty) := chng_operation_rec.operation_seq_num;
                                translate2(msg_qty) := 0;
                        end if;
                        If trial_mode = no then
                                Close old_operation;
                                Raise abort_implementation;
                        end if;
            elsif nvl(old_op_rec.disable_date,eff_date) < eff_date then
                        If msg_qty < max_messages then
                                msg_qty := msg_qty + 1;
                                message_names(msg_qty) :=
                                        'ENG_OLD_OP_DISABLED';
                                token1(msg_qty) := 'ITEM';
                                value1(msg_qty) := item.revised_item_id;
                                translate1(msg_qty) := 0;
                                token2(msg_qty) := 'OPERATION';
                                value2(msg_qty) := chng_operation_rec.operation_seq_num;
                                translate2(msg_qty) := 0;
                        end if;
                        If trial_mode = no then
                                Close old_operation;
                                Raise abort_implementation;
                        end if;
            elsif old_op_rec.effectivity_date > eff_date then
                        If msg_qty < max_messages then
                                msg_qty := msg_qty + 1;
                                message_names(msg_qty) :=
                                        'ENG_OLD_OP_INEFFECTIVE';
                                token1(msg_qty) := 'ITEM';
                                value1(msg_qty) := item.revised_item_id;
                                translate1(msg_qty) := 0;
                                token2(msg_qty) :=  'OPERATION';
                                value2(msg_qty) := chng_operation_rec.operation_seq_num;
                                translate2(msg_qty) := 0;
                        end if;
                        If trial_mode = no then
                                Close old_operation;
                                Raise abort_implementation;
                        end if;

            else

               count_op_disable := count_op_disable + 1;
               rev_op_disable_date_tbl(count_op_disable).revised_item_id  := item.revised_item_id;
               rev_op_disable_date_tbl(count_op_disable).operation_seq_id :=
                                        chng_operation_rec.old_operation_sequence_id;
               rev_op_disable_date_tbl(count_op_disable).disable_date     :=  old_op_rec.disable_date;

               old_op_rec.disable_date := eff_date;
               IF item.eco_for_production = 2
               THEN old_op_rec.change_notice := item.change_notice;
               END IF;
            end if;

            If  chng_operation_rec.acd_type = acd_delete then
                chng_operation_rec.disable_date := eff_date;
            end if;

            -- Disalbe the old operation record
            UPDATE bom_operation_sequences
            SET
                      change_notice = old_op_rec.change_notice,
                      implementation_date = today,
                      disable_date = old_op_rec.disable_date,
    --bug 5622459     disable_date = old_op_rec.disable_date - 1/(60*60*24),
                      last_update_date = sysdate,
                      last_updated_by = userid,
                      last_update_login = loginid,
                      request_id = reqstid,
                      program_application_id = appid,
                      program_id = progid,
                      program_update_date = sysdate
           WHERE operation_sequence_id=
                  old_op_rec.operation_sequence_id;

           Close  old_operation;

    IF chng_operation_rec.acd_type IN (acd_change, acd_add)
    THEN

    --  Check operation verlapping for date effective
        OPEN check_overlapping_operation
         ( chng_operation_rec.routing_sequence_id,
           chng_operation_rec.operation_seq_num,
           chng_operation_rec.operation_sequence_id,
--           chng_operation_rec.effectivity_date -- changed for bug 2827313
           eff_date -- this is the date that will eventually be the effective date of the new operation
         );
         FETCH check_overlapping_operation  INTO dummy;
   --      IF check_overlapping_operation%NOTFOUND
         IF check_overlapping_operation%FOUND
         THEN If msg_qty < max_messages then
                msg_qty := msg_qty + 1;
                message_names(msg_qty) := 'ENG_IMP_OP_INVALID_EFF_DATE';
                token1(msg_qty) := 'OPERATION_SEQ_NUM';
                value1(msg_qty) := chng_operation_rec.operation_seq_num;
                translate1(msg_qty) := 0;
                token2(msg_qty) := 'EFFECTIVE_DATE';
                value2(msg_qty) :=
                              chng_operation_rec.effectivity_date;
                        translate2(msg_qty) := 0;
             end if;
             If trial_mode = no then
                        Raise abort_implementation;
             end if;
         END IF;
        CLOSE check_overlapping_operation;
     END IF;


          IF  chng_operation_rec.acd_type = acd_change
          -- Copy attached resources in the old operation to the new operation,
          -- except the disabled resource.
          THEN
              INSERT INTO  bom_operation_resources
                 (
                   operation_sequence_id
                   , resource_seq_num
                   , resource_id
                   , activity_id
                   , standard_rate_flag
                   , assigned_units
                   , usage_rate_or_amount
                   , usage_rate_or_amount_inverse
                   , basis_type
                   , schedule_flag
                   , last_update_date
                   , last_updated_by
                   , creation_date
                   , created_by
                   , last_update_login
                   , resource_offset_percent
                   , autocharge_type
                   , attribute_category
                   , attribute1
                   , attribute2
                   , attribute3
                   , attribute4
                   , attribute5
                   , attribute6
                   , attribute7
                   , attribute8
                   , attribute9
                   , attribute10
                   , attribute11
                   , attribute12
                   , attribute13
                   , attribute14
                   , attribute15
                   , request_id
                   , program_application_id
                   , program_id
                   , program_update_date
                   , schedule_seq_num
                   , substitute_group_num
                   , principle_flag
                   , change_notice
                   , acd_type
                   , original_system_reference
                 )
              SELECT
                   chng_operation_rec.operation_sequence_id
                   , resource_seq_num
                   , resource_id
                   , activity_id
                   , standard_rate_flag
                   , assigned_units
                   , usage_rate_or_amount
                   , usage_rate_or_amount_inverse
                   , basis_type
                   , schedule_flag
                   , sysdate
                   , userid
                   , sysdate
                   , userid
                   , loginid
                   , resource_offset_percent
                   , autocharge_type
                   , attribute_category
                   , attribute1
                   , attribute2
                   , attribute3
                   , attribute4
                   , attribute5
                   , attribute6
                   , attribute7
                   , attribute8
                   , attribute9
                   , attribute10
                   , attribute11
                   , attribute12
                   , attribute13
                   , attribute14
                   , attribute15
                   , reqstid
                   , appid
                   , progid
                   , sysdate
                   , schedule_seq_num
                   , substitute_group_num
                   , principle_flag
                   , change_notice
                   , acd_type
                   , original_system_reference
             FROM  bom_operation_resources a
             WHERE operation_sequence_id =
                   chng_operation_rec.old_operation_sequence_id
             --* Commented following line for Bug 3520302
             --* AND nvl(acd_type, acd_add)  = acd_add
             --* Added for Bug 3520302
             AND nvl(acd_type, acd_add) in (acd_add,acd_change)
	     AND resource_seq_num  NOT IN (
                 SELECT b.resource_seq_num
                 FROM  bom_operation_resources b
                 WHERE b.operation_sequence_id =
                            chng_operation_rec.operation_sequence_id);

/* Fix for bug 4606950  - In the above select query, modified the sub-query in the where clause.
   Replaced the resource_id with resource_seq_num. The old sub-query was commented as below*/
/*
             AND resource_id NOT IN (
                 SELECT b.resource_id
                 FROM  bom_operation_resources b
                 WHERE b.operation_sequence_id =
                            chng_operation_rec.operation_sequence_id
                       and b.resource_seq_num = a.resource_seq_num);
*/
-- Bug 2641382
-- The above filter condition was modified to search the valid
-- resources based on operation_sequence_id and resource_seq_num

             -- Copy attached substitute resources in the old operation to the new operation,
             -- except the disabled substitute resource.

             INSERT INTO bom_sub_operation_resources
                        (
                           operation_sequence_id
                         , substitute_group_num
                         , resource_id
                         , replacement_group_num
                         , activity_id
                         , standard_rate_flag
                         , assigned_units
                         , usage_rate_or_amount
                         , usage_rate_or_amount_inverse
                         , basis_type
                         , schedule_flag
                         , last_update_date
                         , last_updated_by
                         , creation_date
                         , created_by
                         , last_update_login
                         , resource_offset_percent
                         , autocharge_type
                         , principle_flag
                         , attribute_category
                         , attribute1
                         , attribute2
                         , attribute3
                         , attribute4
                         , attribute5
                         , attribute6
                         , attribute7
                         , attribute8
                         , attribute9
                         , attribute10
                         , attribute11
                         , attribute12
                         , attribute13
                         , attribute14
                         , attribute15
                         , request_id
                         , program_application_id
                         , program_id
                         , program_update_date
                         , schedule_seq_num
                         , change_notice
                         , acd_type
                         , original_system_reference
                         )
                     select
                           chng_operation_rec.operation_sequence_id
                         , substitute_group_num
                         , resource_id
                         , replacement_group_num
                         , activity_id
                         , standard_rate_flag
                         , assigned_units
                         , usage_rate_or_amount
                         , usage_rate_or_amount_inverse
                         , basis_type
                         , schedule_flag
                         , sysdate
                         , userid
                         , sysdate
                         , userid
                         , loginid
                         , resource_offset_percent
                         , autocharge_type
                         , principle_flag
                         , attribute_category
                         , attribute1
                         , attribute2
                         , attribute3
                         , attribute4
                         , attribute5
                         , attribute6
                         , attribute7
                         , attribute8
                         , attribute9
                         , attribute10
                         , attribute11
                         , attribute12
                         , attribute13
                         , attribute14
                         , attribute15
                         , reqstid
                         , appid
                         , progid
                         , sysdate
                         , schedule_seq_num
                         , change_notice
                         , acd_type
                         , original_system_reference
                     FROM bom_sub_operation_resources
                     WHERE operation_sequence_id =
                       chng_operation_rec.old_operation_sequence_id
                     AND nvl(acd_type, acd_add) = acd_add
                     AND resource_id NOT IN (
                     SELECT resource_id
                     FROM bom_sub_operation_resources
                     WHERE operation_sequence_id =
                            chng_operation_rec.operation_sequence_id );

             -- Copy attachment of the Operation Sequences
             -- Added for Bug 3701023
             FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
                    X_from_entity_name         => 'BOM_OPERATION_SEQUENCES'
                  , X_from_pk1_value           => to_char(chng_operation_rec.old_operation_sequence_id)
                  , X_from_pk2_value           => null
                  , X_from_pk3_value           => null
                  , X_from_pk4_value           => null
                  , X_from_pk5_value           => null
                  , X_to_entity_name           => 'BOM_OPERATION_SEQUENCES'
                  , X_to_pk1_value             => to_char(chng_operation_rec.operation_sequence_id)
                  , X_to_pk2_value             => null
                  , X_to_pk3_value             => null
                  , X_to_pk4_value             => null
                  , X_to_pk5_value             => null
                  , X_created_by               => userid
                  , X_last_update_login        => loginid
                  , X_program_application_id   => appid
                  , X_program_id               => progid
                  , X_request_id               => reqstid);

             -- End Changes for Bug 3701023


         END IF;    --   IF  chng_operation_rec.acd_type = acd_change



      END IF;      -- end of  IF chng_operation_rec.acd_type in ( acd_change, acd_delete )

      IF chng_operation_rec.acd_type =  acd_change
      THEN

       -- The following is for resource process
       --Check resource Add/Disable record existing
        OPEN chng_resource_rows;
        LOOP
                FETCH chng_resource_rows  into chng_resource_rec;
                EXIT  WHEN chng_resource_rows%NOTFOUND;

               -- Resource conflict check
               IF  item.update_wip = 1
               AND chng_resource_rec.acd_type IN ( acd_change, acd_delete)
               THEN

                 --For ECO Cumulative type record
                 --Check if the current  resource is not existing in the
                 --specified WIP discrete job'operation.
                 IF  NVL(item.from_cum_qty, 0) > 0
                 THEN

                 OPEN check_not_existing_res_cum
                  (p_from_wip_entity_id => item.from_wip_entity_id,
                   p_operation_seq_num  => chng_operation_rec.operation_seq_num,
                   p_resource_seq_num   => chng_resource_rec.resource_seq_num,
                   p_organization_id    => item.organization_id
                  )  ;
                 FETCH check_not_existing_res_cum  INTO dummy;
                 IF check_not_existing_res_cum%NOTFOUND
                 THEN If msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) := 'ENG_RES_ECO_CUM_CONFLICT';
                        token1(msg_qty) := 'OPERATION_SEQ_NUM';
                        value1(msg_qty) :=
                              to_char(chng_operation_rec.operation_seq_num);
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := 'RESOURCE_SEQ_NUM';
                        value2(msg_qty) :=
                              to_char(chng_resource_rec.resource_seq_num);
                        translate2(msg_qty) := 0;
                      end if;
                      If trial_mode = no then
                        Raise abort_implementation;
                      end if;

                 END IF; -- end of check_not_existing_res_cum%NOTFOUND
                 CLOSE check_not_existing_res_cum;
               END IF;   -- end of NVL(item.from_cum_qty, 0) > 0


                 --For ECO Discrete Job type record
                 --At the WIP job range ( from_wip_job_name, to_wip_job_name),
                 --check if there is a WIP discrete job,  in which the current
                 --resouce has already been disabled or changed.
               IF nvl(item.to_wip_entity_id, 0) <> 0
               THEN
                 OPEN check_not_existing_res_job
                 ( p_from_wip_entity_id=> item.from_wip_entity_id,
                   p_to_wip_entity_id  => item.to_wip_entity_id,
                   p_operation_seq_num => chng_operation_rec.operation_seq_num,
                   p_resource_seq_num  => chng_resource_rec.resource_seq_num,
                   p_organization_id   =>  item.organization_id
                 ) ;
                 FETCH check_not_existing_res_job INTO dummy;
                 IF check_not_existing_res_job%FOUND
                 THEN If msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) := 'ENG_RES_ECO_JOB_CONFLICT';
                        token1(msg_qty) := 'OPERATION_SEQ_NUM';
                        value1(msg_qty) :=
                              to_char(chng_operation_rec.operation_seq_num);
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := 'RESOURCE_SEQ_NUM';
                        value2(msg_qty) :=
                              to_char(chng_resource_rec.resource_seq_num);
                        translate2(msg_qty) := 0;

                     end if;
                      If trial_mode = no then
                        Raise abort_implementation;
                      end if;

                  END IF; -- end ofcheck_not_existing_res_job%FOUND
                  CLOSE check_not_existing_res_job;
                END IF; -- envl(item.to_wip_entity_id, 0) <> 0

                 --For ECO Lot type record
                 --Among WIP discrete jobs with same specified lot number,
                 -- check if there is a WIP discrete job,  in which the
                 -- current component has already been disabled or changed.
                IF item.lot_number IS NOT NULL
                THEN
                 OPEN check_not_existing_res_lot
                 ( p_wip_lot_number    => item.lot_number,
                   p_operation_seq_num => chng_operation_rec.operation_seq_num,
                   p_resource_seq_num  => chng_resource_rec.resource_seq_num,
                   p_organization_id   =>  item.organization_id
                 );
                 FETCH check_not_existing_res_lot INTO dummy;
                 IF check_not_existing_res_lot%FOUND
                 THEN If msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) := 'ENG_RES_ECO_LOT_CONFLICT';
                        token1(msg_qty) := 'OPERATION_SEQ_NUM';
                        value1(msg_qty) :=
                              to_char(chng_operation_rec.operation_seq_num);
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := 'RESOURCE_SEQ_NUM';
                        value2(msg_qty) :=
                              to_char(chng_resource_rec.resource_seq_num);
                        translate2(msg_qty) := 0;
                      end if;
                      If trial_mode = no then
                        Raise abort_implementation;
                      end if;
                  END IF; -- check_not_existing_res_lot%FOUND
                  CLOSE check_not_existing_res_lot;
                END IF;   -- end of  IF item.lot_number IS NOT NULL

           END IF;  -- end of IF item.update_wip = 1 and chng_resource_rec
               --
               -- Check whether all resources in same resource group have been
               -- disabled, if so, delete the sub resources too.
	       /* Commented the below delete st for bug 4577459 . This delete st deletes all rows from the table
   that have been created through the routing form irrespective of which routing they belong to.
   As while implementing the ECO we do not delete the bom_operation_resources data the sub resources
   associated need not be deleted */
              /* DELETE
               FROM bom_sub_operation_resources sr
               WHERE   NOT EXISTS (
               SELECT 1
               FROM bom_operation_resources bor
               WHERE   bor.operation_sequence_id  =  sr.operation_sequence_id
               AND        bor.substitute_group_num = sr.substitute_group_num
               AND        bor.acd_type  <> 3
               );*/


        END LOOP;       -- end of OPEN chng_resource_rows Loop

        CLOSE chng_resource_rows;

      END IF;           -- end of IF chng_operation_rec.acd_type = acd_change

-- Implement the current operation row.
            UPDATE bom_operation_sequences
            SET
                      change_notice       = item.change_notice,
                      implementation_date = today,
                      disable_date        = chng_operation_rec.disable_date,
                      effectivity_date = eff_date,
                      last_update_date    = sysdate,
                      last_updated_by     = userid,
                      last_update_login   = loginid,
                      request_id          = reqstid,
                      program_application_id = appid,
                      program_id          = progid,
                      program_update_date = sysdate
           WHERE operation_sequence_id    =
                  chng_operation_rec.operation_sequence_id;


--
-- Update all unimplemented rows that point to the old row, so that they now
-- point to the new operation row.
--

        If  chng_operation_rec.acd_type = acd_change then
--fix for bug 1607851
          IF item.eco_for_production = 2  THEN
            Update bom_operation_sequences
            set    old_operation_sequence_id = chng_operation_rec.operation_sequence_id,
                   last_update_date = sysdate,
                   last_updated_by = userid,
                   last_update_login = loginid,
                   request_id = reqstid,
                   program_application_id = appid,
                   program_id = progid,
                   program_update_date = sysdate
            where  old_operation_sequence_id =
                   chng_operation_rec.old_operation_sequence_id
            and    implementation_date is null;
         END IF;
        end if; -- reset pointers

 -- Copy all implemented operations to eng_revised_operations.

  INSERT into eng_revised_operations(
    operation_sequence_id ,
    routing_sequence_id ,
    operation_seq_num ,
    last_update_date ,
    last_updated_by ,
    creation_date ,
    created_by ,
    last_update_login ,
    standard_operation_id ,
    department_id ,
    operation_lead_time_percent ,
    minimum_transfer_quantity ,
    count_point_type ,
    operation_description ,
    effectivity_date ,
    disable_date ,
    backflush_flag ,
    option_dependent_flag ,
    attribute_category ,
    attribute1 ,
    attribute2 ,
    attribute3 ,
    attribute4 ,
    attribute5 ,
    attribute6 ,
    attribute7 ,
    attribute8 ,
    attribute9 ,
    attribute10 ,
    attribute11 ,
    attribute12 ,
    attribute13 ,
    attribute14 ,
    attribute15 ,
    request_id ,
    program_application_id ,
    program_id ,
    program_update_date ,
    operation_type ,
    reference_flag ,
    process_op_seq_id ,
    line_op_seq_id ,
    yield ,
    cumulative_yield ,
    reverse_cumulative_yield ,
    labor_time_calc ,
    machine_time_calc ,
    total_time_calc ,
    labor_time_user ,
    machine_time_user ,
    total_time_user ,
    net_planning_percent ,
    --x_coodinate,
    --y_coordinate,
    include_in_rollup ,
    operation_yield_enabled ,
    change_notice ,
    implementation_date ,
    old_operation_sequence_id ,
    acd_type  ,
    revised_item_sequence_id ,
    original_system_reference,
    eco_for_production
   )
   SELECT
    operation_sequence_id ,
    routing_sequence_id ,
    operation_seq_num ,
    last_update_date ,
    last_updated_by ,
    creation_date ,
    created_by ,
    last_update_login ,
    standard_operation_id ,
    department_id ,
    operation_lead_time_percent ,
    minimum_transfer_quantity ,
    count_point_type ,
    operation_description ,
    effectivity_date ,
    disable_date ,
    backflush_flag ,
    option_dependent_flag ,
    attribute_category ,
    attribute1 ,
    attribute2 ,
    attribute3 ,
    attribute4 ,
    attribute5 ,
    attribute6 ,
    attribute7 ,
    attribute8 ,
    attribute9 ,
    attribute10 ,
    attribute11 ,
    attribute12 ,
    attribute13 ,
    attribute14 ,
    attribute15 ,
    request_id ,
    program_application_id ,
    program_id ,
    program_update_date ,
    operation_type ,
    reference_flag ,
    process_op_seq_id ,
    line_op_seq_id ,
    yield ,
    cumulative_yield ,
    reverse_cumulative_yield ,
    labor_time_calc ,
    machine_time_calc ,
    total_time_calc ,
    labor_time_user ,
    machine_time_user ,
    total_time_user ,
    net_planning_percent ,
    --x_coodinate,
    --y_coordinate,
    include_in_rollup ,
    operation_yield_enabled ,
    change_notice ,
    implementation_date ,
    old_operation_sequence_id ,
    acd_type  ,
    revised_item_sequence_id ,
    original_system_reference,
    eco_for_production
   FROM bom_operation_sequences b
   WHERE operation_sequence_id
            = chng_operation_rec.operation_sequence_id;

   IF  chng_operation_rec.acd_type = acd_delete then
     Delete from bom_operation_sequences
     where operation_sequence_id =  chng_operation_rec.operation_sequence_id;
   END IF;

   -- ERES changes begin : bug 3908563
   -- ERES flag to be set for triggering Routing Event:
   bERES_Flag_for_Routing := TRUE;
   -- Bug 4455543: Set l_WIP_Flag_for_Routing when routing details is being updated by revised item
   l_WIP_Flag_for_Routing := 'Y';
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'in chng_operation_rows loop... bERES_Flag_for_Routing=TRUE');
   -- ERES changes end.

 END LOOP;

 CLOSE chng_operation_rows;

-- For ECO cumulative/ECO wip job/ECO lot  ---------8/2/2000----
-----------------------------------------------------------------

-- ECO for Bills implementation process
--
-- Select all component rows for the assembly and change notice in
-- question from bom_inventory_components
--
  -- if the common bom has a diiferent effectivity from the scheduled date then
  -- reset the eff_date value used for processing
  -- assuming that the components with the same effectivity are grouped together
  IF l_common_bom_eff_date IS NOT NULL
  THEN
      eff_date := l_common_bom_eff_date;
  END IF;

  For component in chng_component_rows(item.bill_sequence_id) loop

	--   Get pending from ecn to check if structure created through this revised item or not.
	--   Mark the BOM header as no longer pending from ECO
	--
	-- ERES Change begins
	-- Decision for BillCreate or Update depends on pending_from_ecn:
	    OPEN Get_Bill_of_Materials_Info( item.bill_sequence_id);
	    FETCH Get_Bill_of_Materials_Info
	     INTO l_pending_from_ecn
		, l_alternate_designator;
	    CLOSE Get_Bill_of_Materials_Info;
	-- ERES change ends

	IF( l_pending_from_ecn IS NOT NULL AND l_pending_from_ecn <> item.change_notice ) then
              If msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) := 'ENG_PENDING_BILL_EXIST';
                        token1(msg_qty) := 'ECO_NAME';
                        value1(msg_qty) := l_pending_from_ecn;
                        translate1(msg_qty) := 0;
                end if;
                If trial_mode = no then
                        Raise abort_implementation;
                end if;
        end if;

       --BOM ER 9946990  begin
       if item.bom_item_type = 4 and item.pick_components_flag = 'Y'
          and component.bom_item_type = 4 and component.replenish_to_order_flag = 'Y'
          and nvl(FND_PROFILE.value('BOM:MANDATORY_ATO_IN_PTO'), 2) <> 1
       then
          If msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) := 'BOM_KIT_COMP_PRF_NOT_SET';
                        token1(msg_qty) := null;
                        value1(msg_qty) := null;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := null;
                        value2(msg_qty) := null;
                        translate2(msg_qty) := 0;
                end if;
                If trial_mode = no then
                        Raise abort_implementation;
                end if;

       end if;

       if item.bom_item_type = 1 and item.pick_components_flag = 'Y'
          and component.bom_item_type = 4 and component.replenish_to_order_flag = 'Y'
          and nvl(component.optional, 1) = 2
          and nvl(FND_PROFILE.value('BOM:MANDATORY_ATO_IN_PTO'), 2) <> 1
       then
          If msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) := 'BOM_MODEL_COMP_PRF_NOT_SET';
                        token1(msg_qty) := null;
                        value1(msg_qty) := null;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := null;
                        value2(msg_qty) := null;
                        translate2(msg_qty) := 0;
                end if;
                If trial_mode = no then
                        Raise abort_implementation;
                end if;

       end if;
        --BOM ER 9946990 end

        If component.acd_type in (acd_change, acd_add) and
        component.disable_date < eff_date then
                If msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) := 'ENG_COMPONENT_ACD_DISABLED';
                        token1(msg_qty) := 'ITEM';
                        value1(msg_qty) := component.item_number;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := null;
                        value2(msg_qty) := null;
                        translate2(msg_qty) := 0;
                end if;
                If trial_mode = no then
                        Raise abort_implementation;
                end if;
        end if;

        -- Check for mfg assemblies with eng components.

/*bug 2264654
  Changed the condition to check for mfg assemblies instead of mfg items*/

        begin

           select assembly_type
           into l_bom_assembly_type
           from bom_bill_of_materials
           where bill_sequence_id = item.bill_sequence_id;

        end;

--        If item.eng_item_flag = 'N' and

         If l_bom_assembly_type = 1 and
            component.eng_item_flag = 'Y' then
                If msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        token1(msg_qty) := null;
                        value1(msg_qty) := null;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := null;
                        value2(msg_qty) := null;
                        translate2(msg_qty) := 0;
                        message_names(msg_qty) := 'ENG_ENG_COMPONENTS';
                end if;
                If trial_mode = no then
                        Raise abort_implementation;
                end if;
        end if;

        -- Added validation for bug 4213886
        -- Check for component items with unimplemented component item revision.
        IF (component.component_item_revision_id IS NOT null)
        THEN
            l_compitem_rev_impldate := null;
            Open c_get_revision(component.component_item_revision_id);
            Fetch c_get_revision into l_compitem_rev, l_compitem_rev_impldate;
            IF c_get_revision%NOTFOUND
            THEN
                If msg_qty < max_messages
                Then
                    msg_qty := msg_qty + 1;
                    token1(msg_qty) := 'ITEM';
                    value1(msg_qty) := component.item_number;
                    translate1(msg_qty) := 0;
                    token2(msg_qty) := 'OP_SEQ_NUM';
                    value2(msg_qty) := to_char(component.operation_seq_num);
                    translate2(msg_qty) := 0;
                    message_names(msg_qty) := 'ENG_COMP_ITM_REV_INVALID';
                    IF trial_mode = no
                    THEN
                        Close c_get_revision;
                        RAISE abort_implementation;
                    END IF;
                END IF;
            ELSIF c_get_revision%FOUND AND l_compitem_rev_impldate IS NULL
            THEN
                If msg_qty < max_messages
                Then
                    msg_qty := msg_qty + 1;
                    token1(msg_qty) := 'ITEM';
                    value1(msg_qty) := component.item_number;
                    translate1(msg_qty) := 0;
                    token2(msg_qty) := 'OP_SEQ_NUM';
                    value2(msg_qty) := to_char(component.operation_seq_num);
                    translate2(msg_qty) := 0;
                    message_names(msg_qty) := 'ENG_COMP_ITM_REV_UNIMPL';
                    IF trial_mode = no
                    THEN
                        Close c_get_revision;
                        RAISE abort_implementation;
                    END IF;
                End If;
            END IF;
            Close c_get_revision;
        END IF;
        -- End changes for bug 4213886

        -- check from and to unit numbers.
        -- Unit Effectivity implementation
        If (X_UnitEff_RevItem = 'Y')
        then
                if (component.from_end_item_unit_number is NULL)
                then
                        If msg_qty < max_messages then
                                msg_qty := msg_qty + 1;
                                token1(msg_qty) := null;
                                value1(msg_qty) := null;
                                translate1(msg_qty) := 0;
                                token2(msg_qty) := null;
                                value2(msg_qty) := null;
                                translate2(msg_qty) := 0;
                                message_names(msg_qty) :=
                                        'ENG_RCOMP_UNIT_KEYCOL_NULL';
                        end if;
                        If trial_mode = no then
                                Raise abort_implementation;
                        end if;
                end if;

                if (component.to_end_item_unit_number is not null AND
                    component.to_end_item_unit_number < component.from_end_item_unit_number)
                then
                        If msg_qty < max_messages then
                                msg_qty := msg_qty + 1;
                                message_names(msg_qty) :=
                                        'ENG_TOUNIT_LESSTHAN_FROMUNIT';
                                token1(msg_qty) := 'ITEM';
                                value1(msg_qty) := component.item_number;
                                translate1(msg_qty) := 0;
                                token2(msg_qty) := 'OP_SEQ_NUM';
                                value2(msg_qty) :=
                                        to_char(component.operation_seq_num);
                                translate2(msg_qty) := 0;
                        end if;
                        If trial_mode = no then
                                Raise abort_implementation;
                        end if;
                end if;
        end if;

--------------------------------------------------------------------------
--For ECO cumulative/ECO WIP job/ECO lot              8/2/2000 ---------
--IFACD type =  CHANGE or DISABLE, check the followings.


               -- Component conflict check
            IF item.update_wip = 1
            AND component.acd_type IN (2, 3)
            THEN
                 --For ECO Cumulative type record
                 --Check if the current  compoment is not existing in the
                 --specified WIP discrete job'operation.
               IF  NVL(item.from_cum_qty, 0) > 0
               THEN
                 OPEN check_not_existing_comp_cum
                  (p_from_wip_entity_id => item.from_wip_entity_id,
                   p_operation_seq_num  => component.operation_seq_num,
                   p_inventory_item_id  => component.component_item_id,
                   p_organization_id    => item.organization_id
                  ) ;
                 FETCH check_not_existing_comp_cum  INTO dummy;
                 IF check_not_existing_comp_cum%NOTFOUND
                 THEN If msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) := 'ENG_COMP_ECO_CUM_CONFLICT';
                        token1(msg_qty) := 'COMPONENT';
                        value1(msg_qty) :=component.component_item_id;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := 'OP_SEQ_NUM';
                        value2(msg_qty) :=
                                       to_char(component.operation_seq_num);
                        translate2(msg_qty) := 0;
                      end if;
                      If trial_mode = no then
                        Raise abort_implementation;
                      end if;

                 END IF;  -- end of check_not_existing_res_cum%NOTFOUND
                 CLOSE  check_not_existing_comp_cum;

               END IF;    -- end of NVL(item.from_cum_qty, 0) > 0


                 --For ECO Discrete Job type record
                 --At the WIP job range ( from_wip_job_name, to_wip_job_name),
                 --check if there is a WIP discrete job,  in which the current
                 --comp has already been disabled or changed.
               IF nvl(item.to_wip_entity_id, 0) <> 0
               THEN

-- code to resolve the bug 2722280 begin
              if (component.acd_type = 2) then
                    OPEN get_old_operation_seq_num
                    ( p_old_component_sequence_id => component.old_component_sequence_id );

                    FETCH   get_old_operation_seq_num INTO l_old_op_seq_num;
                    CLOSE get_old_operation_seq_num;
              else
                    l_old_op_seq_num :=  component.operation_seq_num;
              end if;
-- 2722280 completed

             if (l_old_op_seq_num <> 1) then              --2974766

                 OPEN check_not_existing_comp_job
                 (   p_from_wip_entity_id => item.from_wip_entity_id,
                     p_to_wip_entity_id   => item.to_wip_entity_id,
-- 2722280             p_operation_seq_num  => component.operation_seq_num,
                     p_operation_seq_num  => l_old_op_seq_num,
                     p_inventory_item_id  => component.component_item_id,
                     p_organization_id    => item.organization_id
                 );

                 FETCH check_not_existing_comp_job INTO dummy;
                 IF check_not_existing_comp_job%FOUND
                 THEN If msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) := 'ENG_COMP_ECO_JOB_CONFLICT';
                        token1(msg_qty) := 'COMPONENT';
                        value1(msg_qty) :=component.component_item_id;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := 'OP_SEQ_NUM';
                        value2(msg_qty) :=
                              to_char(component.operation_seq_num);
                        translate2(msg_qty) := 0;
                      end if;
                      If trial_mode = no then
                        Raise abort_implementation;
                      end if;

                 END IF; -- end of check_not_existing_comp_job%FOUND
                 CLOSE check_not_existing_comp_job;
                End if;                        --2974766
               END IF;

                 -- For ECO Lot type record
                 -- Among WIP discrete jobs with same specified lot number,
                 -- check if there is a WIP discrete job,  in which the
                 -- current component has already been disabled or changed.
               IF item.lot_number IS NOT NULL
               THEN
                 OPEN check_not_existing_comp_lot
                  (   p_wip_lot_number     => item.lot_number,
                      p_operation_seq_num  => component.operation_seq_num,
                      p_inventory_item_id  => component.component_item_id,
                      p_organization_id    => item.organization_id
                  );
                 FETCH check_not_existing_comp_lot INTO dummy;
                 IF check_not_existing_comp_lot%FOUND
                 THEN If msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) := 'ENG_COMP_ECO_LOT_CONFLICT';
                        token1(msg_qty) := 'COMPONENT';
                        value1(msg_qty) :=component.component_item_id;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := 'OP_SEQ_NUM';
                        value2(msg_qty) :=
                              to_char(component.operation_seq_num);
                        translate2(msg_qty) := 0;
                      end if;
                      If trial_mode = no then
                        Raise abort_implementation;
                      end if;
                  END IF; -- check_not_existing_comp_lot%FOUND
                  CLOSE check_not_existing_comp_lot;
                 END IF;  -- item.lot_number IS NOT NULL
               END IF;  -- end of IF item.update_wip = 1

--For ECO cumulative/ECO WIP job/ECO lot              8/2/2000 ---------
-------------------------------------------------------------------------
        --
        -- Added For 11510+ Enhancement
        -- Begin Validations For End-Item-Revision Effectivity
        --
        If (l_revision_eff_bill = 'Y')
        then
            -- Validate that from_end_item_revision_id is not null
            if (component.from_end_item_rev_id is NULL or component.from_end_item_rev_id <> item.from_end_item_rev_id)
            then
                If msg_qty < max_messages
                then
                    msg_qty := msg_qty + 1;
                    token1(msg_qty) := null;
                    value1(msg_qty) := null;
                    translate1(msg_qty) := 0;
                    token2(msg_qty) := null;
                    value2(msg_qty) := null;
                    translate2(msg_qty) := 0;
                    message_names(msg_qty) := 'ENG_RCOMP_REV_KEYCOL_INVALID';
                end if;
                If trial_mode = no
                then
                    Raise abort_implementation;
                end if;
            end if;

            -- Validate that from_end_item_revision_id is implemented
            if (l_from_revision is NULL)
            then
                If msg_qty < max_messages
                then
                    msg_qty := msg_qty + 1;
                    token1(msg_qty) :=  'ITEM';
                    value1(msg_qty) := component.item_number;
                    translate1(msg_qty) := 0;
                    token2(msg_qty) := 'OP_SEQ_NUM';
                    value2(msg_qty) :=  to_char(component.operation_seq_num);
                    translate2(msg_qty) := 0;
                    message_names(msg_qty) := 'ENG_RCOMP_FROM_REV_UNIMPL';
                end if;
                If trial_mode = no
                then
                    Raise abort_implementation;
                end if;
            end if;
            -- Validate that  to_end_item_revision_id is implemented
            l_to_rev_eff_date := null;
            l_to_revision := null;
            If(component.to_end_item_rev_id is not null)
            Then
                Open check_impl_revision(component.to_end_item_rev_id, l_from_end_item_id, item.organization_id);
                Fetch check_impl_revision into l_to_rev_eff_date, l_to_revision;
                Close check_impl_revision;
                if (l_to_revision is NULL)
                then
                    If msg_qty < max_messages then
                            msg_qty := msg_qty + 1;
                            token1(msg_qty) :=  'ITEM';
                            value1(msg_qty) := component.item_number;
                            translate1(msg_qty) := 0;
                            token2(msg_qty) := 'OP_SEQ_NUM';
                            value2(msg_qty) :=  to_char(component.operation_seq_num);
                            translate2(msg_qty) := 0;
                            message_names(msg_qty) := 'ENG_RCOMP_TO_REV_UNIMPL';
                    end if;
                    If trial_mode = no
                    then
                        Raise abort_implementation;
                    end if;
                end if;
            End If;

            -- Validate that Effectivity_date of from_end_item_revision_id is less than the the
            -- Effectivity_date of to_end_item_revision_id of the component
            If(l_from_revision is not null and l_to_revision is not null
               and l_from_revision > l_to_revision)
            Then
                If msg_qty < max_messages
                then
                    msg_qty := msg_qty + 1;
                    token1(msg_qty) :='ITEM';
                    value1(msg_qty) := component.item_number;
                    translate1(msg_qty) := 0;
                    token2(msg_qty) := 'OP_SEQ_NUM';
                    value2(msg_qty) := to_char(component.operation_seq_num);
                    translate2(msg_qty) := 0;
                    message_names(msg_qty) := 'ENG_TOREV_LESSTHAN_FROMREV';
                end if;
                If trial_mode = no
                then
                    Raise abort_implementation;
                end if;
            End If;

            -- Validate that from_end_item_revision_id is effective i.e its effectivity_date
            -- is current or in future

            If(l_current_end_item_revision > l_from_revision)
            Then
                If msg_qty < max_messages
                then
                    msg_qty := msg_qty + 1;
                    token1(msg_qty) := 'ITEM';
                    value1(msg_qty) :=  component.item_number;
                    translate1(msg_qty) := 0;
                    token2(msg_qty) := 'OP_SEQ_NUM';
                    value2(msg_qty) :=  to_char(component.operation_seq_num);
                    translate2(msg_qty) := 0;
                    message_names(msg_qty) := 'ENG_RCOMP_CURRREV_GREATER';
                end if;
                If trial_mode = no
                then
                    Raise abort_implementation;
                end if;
            End If;
        End If;
        -- End Validations For End-Item-Revision Effectivity
        -- End Changes: 11510+ Enhancement
        --

        If component.acd_type in (acd_change, acd_delete)
        then
            -- Fetch The Old component Details For Validations
            Open old_component(component.old_component_sequence_id);
            Fetch old_component into old_comp_rec;


            -- Case 1: Check if old component is implemented
            If old_comp_rec.implementation_date is null
            then
                If msg_qty < max_messages
                then
                    msg_qty := msg_qty + 1;
                    message_names(msg_qty) := 'ENG_OLD_COMP_UNIMPLEMENTED';
                    token1(msg_qty) := 'ITEM';
                    value1(msg_qty) := component.item_number;
                    translate1(msg_qty) := 0;
                    token2(msg_qty) := null;
                    value2(msg_qty) := null;
                    translate2(msg_qty) := 0;
                end if;
                If trial_mode = no
                then
                    Close old_component;
                    Raise abort_implementation;
                end if;

            -- Case 2: Check that the old component is effective for CHANGE/DISABLE
            --         that is, the old component has not been disabled
            -- Changes Done For : 11510+ Enhancement
            elsif old_comp_rec.disable_date is not null
            then
                l_disabled_old_comp := 2;
                If (X_UnitEff_RevItem = 'Y' or l_revision_eff_bill = 'Y')
                Then
                    l_disabled_old_comp := 1;
                Elsif (old_comp_rec.disable_date < eff_date)
                Then
                    l_disabled_old_comp := 1;
                End If;
                If( l_disabled_old_comp = 1)
                Then
                    If msg_qty < max_messages
                    then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) := 'ENG_OLD_COMP_DISABLED';
                        token1(msg_qty) := 'ITEM';
                        value1(msg_qty) := component.item_number;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := null;
                        value2(msg_qty) := null;
                        translate2(msg_qty) := 0;
                    end if;
                    If trial_mode = no
                    then
                        Close old_component;
                        Raise abort_implementation;
                    end if;
                End If;
            -- Case 3: Check the effectivity for date effective structures
            elsif (old_comp_rec.effectivity_date > eff_date and X_UnitEff_RevItem = 'N' AND l_revision_eff_bill = 'N')
            then
                If msg_qty < max_messages
                then
                    msg_qty := msg_qty + 1;
                    message_names(msg_qty) := 'ENG_OLD_COMP_INEFFECTIVE';
                    token1(msg_qty) := 'ITEM';
                    value1(msg_qty) := component.item_number;
                    translate1(msg_qty) := 0;
                    token2(msg_qty) := null;
                    value2(msg_qty) := null;
                    translate2(msg_qty) := 0;
                end if;
                If trial_mode = no
                then
                    Close old_component;
                    Raise abort_implementation;
                end if;

            -- Changes Done For : 11510+ Enhancement
            -- Case 4: Validate that the from_end_item_revision of revised component
            --                         > from_end_item_revision of the old component
            --                     and < to_end_item_revision of the old component
            elsIf(l_revision_eff_bill = 'Y')
            Then
                l_valid_from_to_revision := 2;
                Open check_from_to_revision (l_from_rev_eff_date, old_comp_rec.component_sequence_id);
                Fetch check_from_to_revision into l_valid_from_to_revision;
                Close check_from_to_revision;
                If (l_valid_from_to_revision = 2)
                Then
                    If msg_qty < max_messages
                    then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) := 'ENG_RCOMP_REV_NOTIN_OLDRANGE';
                        token1(msg_qty) := 'ITEM';
                        value1(msg_qty) := component.item_number;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := null;
                        value2(msg_qty) := null;
                        translate2(msg_qty) := 0;
                    end if;
                    If trial_mode = no
                    then
                        Close old_component;
                        Raise abort_implementation;
                    end if;
                End If;

            -- If all validations passed, then set the old component record details
            ELSE
                -- added for eco enhancement
                count_comp_disable := count_comp_disable + 1;
                rev_comp_disable_date_tbl(count_comp_disable).revised_item_id  := item.revised_item_id;
                rev_comp_disable_date_tbl(count_comp_disable).component_seq_id :=
                                                           component.old_component_sequence_id;
                rev_comp_disable_date_tbl(count_comp_disable).disable_date     := old_comp_rec.disable_date;


                old_comp_rec.disable_date := eff_date;
                /* Bug 2441062. disable_date should be a second lesser than eff_date
                   to avoid overlapping effectivity within the same component
		   The above change has been reverted for this bug 5622459
		   */
                IF component.acd_type = acd_change
                THEN
                    -- Set disable_date
                     /*bug 5622459
		     old_comp_rec.disable_date := eff_date-((1/1440)/60);
		     */
                    -- Set overlapping_changes
                    IF component.overlapping_changes = 1
                    THEN
                        old_comp_rec.overlapping_changes := 1;
                    END IF;
                ELSE
                    old_comp_rec.disable_date := eff_date;
                END IF;
                -- Added for structure revision
                -- Set to_object_revision_id
                IF (old_comp_rec.from_object_revision_id is not null
                    AND item.new_structure_revision is not null
                    AND old_comp_rec.to_object_revision_id is NULL)
                THEN
                     old_comp_rec.to_object_revision_id := X_prev_structure_revision_id;
                END IF;
                -- Set change_notice
                IF item.eco_for_production = 2
                THEN
                    old_comp_rec.change_notice := item.change_notice;
                END IF;
            end if;
            -- End of Validations

            If component.acd_type = acd_delete
            then
                component.disable_date := eff_date;
            end if;
            -- Unit Effectivity implementation
            If (X_UnitEff_RevItem = 'Y')
            then
                -- Disable the old component by populating disable_date, if
                -- the change/disable is for whole range starting from the
                -- from_unit_number of the old component.
                -- Else, update the to_unit_number of the old comp with the prev
                -- unit number of the new comp's from_unit_number.
                -- Need to be enhanced for spliting.
                if (component.from_end_item_unit_number = old_comp_rec.from_end_item_unit_number)
                then
                    /*bug 5622459
		    IF component.acd_type = acd_change
                    THEN
                        old_comp_rec.disable_date := eff_date-((1/1440)/60);
                    ELSE*/
                    old_comp_rec.disable_date := eff_date;
                    --END IF;

                    Update bom_components_b --bom_inventory_components
                    set disable_date = old_comp_rec.disable_date,
                    to_object_revision_id = old_comp_rec.to_object_revision_id,
                    overlapping_changes = old_comp_rec.overlapping_changes,
                    change_notice = old_comp_rec.change_notice,
                    implementation_date = today,
                    last_update_date = sysdate,
                    last_updated_by = userid,
                    last_update_login = loginid,
                    request_id = reqstid,
                    program_application_id = appid,
                    program_id = progid,
                    program_update_date = sysdate
                    where component_sequence_id = old_comp_rec.component_sequence_id;
                else
                    X_prev_unit_number := PJM_UNIT_EFF.Prev_unit_number(X_unit_number => component.from_end_item_unit_number);
                    if (X_prev_unit_number is NULL)
                    then
                        X_prev_unit_number := component.from_end_item_unit_number;
                    end if;
                    if (X_prev_unit_number < old_comp_rec.from_end_item_unit_number)
                    then
                        If msg_qty < max_messages
                        then
                            msg_qty := msg_qty + 1;
                            message_names(msg_qty) := 'ENG_TOUNIT_LESSTHAN_FROMUNIT';
                            token1(msg_qty) := 'ITEM';
                            value1(msg_qty) := component.item_number;
                            translate1(msg_qty) := 0;
                            token2(msg_qty) := 'OP_SEQ_NUM';
                            value2(msg_qty) := to_char(component.operation_seq_num);
                            translate2(msg_qty) := 0;
                        end if;
                        If trial_mode = no
                        then
                            Raise abort_implementation;
                        end if;
                    end if;

                    Update bom_components_b --bom_inventory_components
                    set to_end_item_unit_number = X_prev_unit_number,
                    to_object_revision_id = old_comp_rec.to_object_revision_id,
                    overlapping_changes = old_comp_rec.overlapping_changes,
                    change_notice = old_comp_rec.change_notice,
                    implementation_date = today,
                    last_update_date = sysdate,
                    last_updated_by = userid,
                    last_update_login = loginid,
                    request_id = reqstid,
                    program_application_id = appid,
                    program_id = progid,
                    program_update_date = sysdate
                    where component_sequence_id =
                          old_comp_rec.component_sequence_id;
                end if;
            ELSIF (l_revision_eff_bill = 'Y')
            THEN
                -- Disable the old component by populating disable_date, if
                -- the change/disable is for whole range starting from the
                -- from_unit_number of the old component.
                -- Else, update the to_unit_number of the old comp with the prev
                -- unit number of the new comp's from_unit_number.
                -- Need to be enhanced for spliting.
                if (component.from_end_item_rev_id = old_comp_rec.from_end_item_rev_id)
                then
		/* bug 5622459. 1 sec difference is removed
                    IF component.acd_type = acd_change
                    THEN
                        old_comp_rec.disable_date := eff_date-((1/1440)/60);
                    ELSE*/
                    old_comp_rec.disable_date := eff_date;
                    --END IF;

                    Update bom_components_b --bom_inventory_components
                    set disable_date = old_comp_rec.disable_date,
                    to_object_revision_id = old_comp_rec.to_object_revision_id,
                    overlapping_changes = old_comp_rec.overlapping_changes,
                    change_notice = old_comp_rec.change_notice,
                    implementation_date = today,
                    last_update_date = sysdate,
                    last_updated_by = userid,
                    last_update_login = loginid,
                    request_id = reqstid,
                    program_application_id = appid,
                    program_id = progid,
                    program_update_date = sysdate
                    where component_sequence_id = old_comp_rec.component_sequence_id;
                else
                    l_prev_end_item_rev_id := NULL;
                    OPEN get_prev_impl_revision(l_from_end_item_id,
                                                item.organization_id,
                                                l_from_rev_eff_date);
                    FETCH get_prev_impl_revision INTO l_prev_end_item_rev_id, l_prev_end_item_eff;
                    CLOSE get_prev_impl_revision;
                    IF (l_prev_end_item_rev_id is NULL)
                    THEN
                        l_prev_end_item_rev_id := component.from_end_item_rev_id;
                        l_prev_end_item_eff := l_from_rev_eff_date;
                    END IF;
                    l_valid_from_to_revision := 2;
                    Open check_from_to_revision (l_prev_end_item_eff, old_comp_rec.component_sequence_id);
                    Fetch check_from_to_revision into l_valid_from_to_revision;
                    Close check_from_to_revision;
                    IF (l_valid_from_to_revision = 2)
                    Then
                        If msg_qty < max_messages
                        then
                            msg_qty := msg_qty + 1;
                            message_names(msg_qty) := 'ENG_TOREV_LESSTHAN_FROMREV';
                            token1(msg_qty) := 'ITEM';
                            value1(msg_qty) := component.item_number;
                            translate1(msg_qty) := 0;
                            token2(msg_qty) := 'OP_SEQ_NUM';
                            value2(msg_qty) := to_char(component.operation_seq_num);
                            translate2(msg_qty) := 0;
                        end if;
                        If trial_mode = no
                        then
                            Raise abort_implementation;
                        end if;
                    end if;

                    Update bom_components_b --bom_inventory_components
                    set to_end_item_rev_id = l_prev_end_item_rev_id,
                    to_object_revision_id = old_comp_rec.to_object_revision_id,
                    overlapping_changes = old_comp_rec.overlapping_changes,
                    change_notice = old_comp_rec.change_notice,
                    implementation_date = today,
                    last_update_date = sysdate,
                    last_updated_by = userid,
                    last_update_login = loginid,
                    request_id = reqstid,
                    program_application_id = appid,
                    program_id = progid,
                    program_update_date = sysdate
                    where component_sequence_id = old_comp_rec.component_sequence_id;
                end if;
            else
             --Added to reflect correct disable date in old component.
	     /*added case
	     case 1: S1 => C1 (Q= 1 ,eff= D1) changed to S1 => C1 (Q= 10 ,eff= D1)  [D1 = future date] is supported.
	     in this case while implemention put disable date same as eff date in old comp.
	     initailly overlapping error used to come*/

	     /* --bug 5622459 1 sec difference is removed
		  IF component.acd_type = acd_change
                  THEN
			IF old_comp_rec.effectivity_date =  eff_date
			THEN
			old_comp_rec.disable_date := eff_date;
			 ELSE
                            old_comp_rec.disable_date := eff_date-((1/1440)/60);
			 END IF;
                  ELSE
                        old_comp_rec.disable_date := eff_date;
                  END IF;*/
		old_comp_rec.disable_date := eff_date; --bug 5622459
                l_old_disable_date  :=   old_comp_rec.disable_date;
                -- Date effectivity implementation
                Update bom_components_b --bom_inventory_components
                set disable_date = old_comp_rec.disable_date,
                to_object_revision_id = old_comp_rec.to_object_revision_id,
                overlapping_changes = old_comp_rec.overlapping_changes,
                change_notice = old_comp_rec.change_notice,
                last_update_date = sysdate,
                last_updated_by = userid,
                last_update_login = loginid,
                request_id = reqstid,
                program_application_id = appid,
                program_id = progid,
                program_update_date = sysdate
                -- where current of old_component;
                where component_sequence_id = old_comp_rec.component_sequence_id;
            end if;
            -----------------------------------------------------------
            -- R12: Changes for Common BOM Enhancement
            -- Step 2: Update related old components
            --         Move/Copy pending changes on old component to new.
            -- Pending changes for WIP attributes could have been created
            -- on the implemented old component on the destination bill
            -- These need to be updated to reference the new component
            -- Since the effectivity date is not a modifiable attribute on
            -- the destination bill's component change records , the pending
            -- changes derive their old components effectivities only.
            -- So if the oldcomponent is disable date is future effective, then
            -- pending changes are copied from the old to the new refenced
            -- component in the destination bill
            -- They are copied otherwise.
            -----------------------------------------------------------
            IF isCommonedBOM = 'Y'
            THEN
                IF component.acd_type = acd_change
                THEN
                    -- if the old component is being disabled as of not
                    -- or the old component was future effective but is being disabled as of the
                    -- same date then we move the pending changes to the new component.
                    IF eff_date <= SYSDATE OR old_comp_rec.disable_date <= old_comp_rec.effectivity_date
                    THEN
                        Move_Pending_Dest_Components(
                            p_src_old_comp_seq_id      => old_comp_rec.component_sequence_id
                          , p_src_comp_seq_id          => component.component_sequence_id
                          , p_change_notice            => item.change_notice
                          , p_revised_item_sequence_id => item.revised_item_sequence_id
                          , p_effectivity_date         => eff_date
                          , p_eco_for_production       => item.eco_for_production
                          , x_return_status            => l_comn_return_status);
                    ELSE
                        BOMPCMBM.Copy_Pending_Dest_Components(
                            p_src_old_comp_seq_id      => old_comp_rec.component_sequence_id
                          , p_src_comp_seq_id          => component.component_sequence_id
                          , p_change_notice            => item.change_notice
                          , p_organization_id          => item.organization_id
                          , p_revised_item_sequence_id => item.revised_item_sequence_id
                          , p_effectivity_date         => eff_date
                          , x_return_status            => l_comn_return_status);
                    END IF;
                    If ( l_comn_return_status <> 'S')
                    Then
                        If msg_qty < max_messages
                        then
                            msg_qty := msg_qty + 1;
                            message_names(msg_qty) := 'ENG_COM_COMP_UPDATE_FAILED';
                            token1(msg_qty) := 'ITEM';
                            value1(msg_qty) := component.item_number;
                            translate1(msg_qty) := 0;
                            token2(msg_qty) := null;
                            value2(msg_qty) := null;
                            translate2(msg_qty) := 0;
                        end if;
                        If trial_mode = no
                        then
                            Close old_component;
                            Raise abort_implementation;
                        end if;
                    End If;
                END IF;

                BOMPCMBM.Update_Related_Components(
                    p_src_comp_seq_id => old_comp_rec.component_sequence_id
                  , x_Mesg_Token_Tbl  => l_comn_mesg_token_tbl
                  , x_Return_Status   => l_comn_return_status);
                If ( l_comn_return_status <> 'S')
                Then
                    If msg_qty < max_messages
                    then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) := 'ENG_COM_COMP_UPDATE_FAILED';
                        token1(msg_qty) := 'ITEM';
                        value1(msg_qty) := component.item_number;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := null;
                        value2(msg_qty) := null;
                        translate2(msg_qty) := 0;
                    end if;
                    If trial_mode = no
                    then
                        Close old_component;
                        Raise abort_implementation;
                    end if;
                End If;
                -- added here, for the R12 change management for common  bom
            END IF;
            -----------------------------------------------------------
            -- R12: End Step 2: End Changes for Common BOM Enhancement --
            -----------------------------------------------------------

            Close old_component;
        end if; -- old components

        --
        --  Check for duplicate value on unique index (avoid overlapping effectivity)
        --
        /* No need to perform the overlap check for the component row which has acd_type as
           delete since this row will be deleted from the inventory_components table at the
           end if implementation */
        IF component.acd_type <> acd_delete
        THEN
            -- Initialize
            l_overlap_found := 2;

            -- Check for Unit Effectivity implementation
            If (X_UnitEff_RevItem = 'Y')
            then
                Open check_existing_unit(
                        X_bill => item.bill_sequence_id,
                        X_component => component.component_item_id,
                        X_operation => component.operation_seq_num,
                        X_comp_seq_id => component.component_sequence_id,
                        X_from_unit_number => component.from_end_item_unit_number,
                        X_to_unit_number   => component.to_end_item_unit_number);
                Fetch check_existing_unit into dummy;
                If check_existing_unit%found
                then
                    l_overlap_found := 1;
                end if;
                Close check_existing_unit;
            -- Check For End-Item-Revision Effectivity
            -- 11510+ Enhancement
            elsIf(l_revision_eff_bill = 'Y')
            Then
                Open check_existing_rev_eff_comp
                        ( cp_bill_id           => item.bill_sequence_id
                        , cp_component_item_id => component.component_item_id
                        , cp_operation_seq_num => component.operation_seq_num
                        , cp_end_item_id       => l_from_end_item_id
                        , cp_org_id            => item.organization_id
                        , cp_from_rev_eff      => l_from_rev_eff_date
                        , cp_to_rev_eff        => l_to_rev_eff_date );
                Fetch check_existing_rev_eff_comp into l_overlap_found;
                Close check_existing_rev_eff_comp;
            else
            -- Check for Date effectivity implementation
                Open check_existing_component(
                        X_bill => item.bill_sequence_id,
                        X_component => component.component_item_id,
                        X_operation => component.operation_seq_num,
                        X_comp_seq_id => component.component_sequence_id,
                        X_disable_date => component.disable_date,
			X_old_comp_seq_id => component.old_component_sequence_id,
			X_old_rec_disable_date => l_old_disable_date );
                Fetch check_existing_component into dummy;
                If check_existing_component%found
                then
                    l_overlap_found := 1;
                end if;
                Close check_existing_component;
            end if;
            -- If overlapping Effectivity Found then Raise Error
            If l_overlap_found = 1
            Then
                If msg_qty < max_messages
                then
                    msg_qty := msg_qty + 1;
                    message_names(msg_qty) := 'ENG_COMPONENT_ALREADY_EXISTS';
                    token1(msg_qty) := 'ITEM';
                    value1(msg_qty) := component.item_number;
                    translate1(msg_qty) := 0;
                    token2(msg_qty) := 'OP';
                    value2(msg_qty) := to_char(component.operation_seq_num);
                    translate2(msg_qty) := 0;
                end if;
                If trial_mode = no then
                        Raise abort_implementation;
                end if;
            End If;
        END IF;
        -- End of Check for duplicate values on unique Index (Overlapping Effectivities)

        If component.acd_type = acd_change then
          -- Bug 4584490: Changes for Bom Business Events
          -- Check if there exists and substitue comps/ ref desigs
          -- on the component
          BEGIN
              IF item.eco_for_production = 2
              THEN
                  l_Comp_Child_Entity_Modified := NULL;
                  OPEN c_Comp_Child_Entity_Modified(component.component_sequence_id);
                  FETCH c_Comp_Child_Entity_Modified INTO l_Comp_Child_Entity_Modified;
                  CLOSE c_Comp_Child_Entity_Modified;
                  IF l_Comp_Child_Entity_Modified IS NOT NULL
                  THEN
                      Bom_Business_Event_PKG.Raise_Component_Event(
                          p_bill_sequence_Id => item.bill_sequence_id
                        , p_pk1_value        => component.component_item_id
                        , p_pk2_value        => item.organization_id
                        , p_obj_name         => component.obj_name
                        , p_organization_id  => item.organization_id
                        , p_comp_item_name   => component.item_number
                        , p_comp_description => component.component_remarks
                        , p_Event_Name       => Bom_Business_Event_PKG.G_COMPONENT_MODIFIED_EVENT
                        );
                  END IF;
              END IF;
          EXCEPTION
          WHEN OTHERS THEN
              null;
              -- nothing is required to be done, process continues
          END;
          -- End changes for Bug 4584490

 -- Bug 5854437 Start
  For sub_component in chng_sub_component_rows loop
                Open check_existing_substitutes(X_old_comp_seq_id => sub_component.old_component_sequence_id,
                                                                     X_sub_comp_id => sub_component.substitute_component_id,
                                                                     X_change_notice => item.change_notice);
                Fetch check_existing_substitutes into dummy;

                If check_existing_substitutes%found then
              rec_exist:=0;
              BEGIN
                SELECT bsc.acd_type into rec_exist
                FROM   Bom_Inventory_Components bic,
                           BOM_SUBSTITUTE_COMPONENTS bsc
                WHERE  bic.Old_Component_Sequence_Id = sub_component.old_component_sequence_id
                        AND    bic.Change_Notice = item.change_notice
                        AND    bic.Implementation_Date IS NULL
                        AND    bsc.component_sequence_id = bic.component_sequence_id
                        AND    bsc.substitute_component_id =  sub_component.substitute_component_id
                       ;-- AND    bsc. ACD_TYPE = acd_delete; --removed for bug 8499831
              EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                               -- NULL; --removed for bug 8499831
				  rec_exist := sub_component.acd_type; --added for bug 8499831
              END;
                   If (rec_exist <> acd_delete) and (rec_exist <> acd_add) then --changed for bug 8499831
                           rec_exist := 0;
                        If msg_qty < max_messages then
                               msg_qty := msg_qty + 1;
                                message_names(msg_qty) :=
                                        'ENG_SUB_COMP_ALREADY_EXISTS';
                                token1(msg_qty) := 'SUBSTITUTE_ITEM_NAME';
                                value1(msg_qty) := sub_component.item_number;
                                translate1(msg_qty) := 0;
                                token2(msg_qty) := 'REVISED_COMPONENT_NAME';
                                value2(msg_qty) := component.item_number;
                                translate2(msg_qty) := 0;

                        end if;
        FND_MESSAGE.Set_Name('ENG','ENG_SUB_COMP_ALREADY_EXISTS');
        FND_MESSAGE.Set_Token('SUBSTITUTE_ITEM_NAME',sub_component.item_number) ;
        FND_MESSAGE.Set_Token('REVISED_COMPONENT_NAME',component.item_number) ;
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE, p_count => l_error_msg_count , p_data => l_message);
FND_FILE.put_line(FND_FILE.LOG, l_message);
                        If trial_mode = no then
                                Close check_existing_substitutes;
                                Raise abort_implementation;
                        end if;
                   end if;
                end if;
             Close check_existing_substitutes;
  end loop;

-- Bug 5854437 End


               -- Copy substitute components
               Insert into bom_substitute_components(
                   substitute_component_id,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login,
                   substitute_item_quantity,
                   component_sequence_id,
                   acd_type,
                   change_notice,
                   request_id,
                   program_application_id,
                   program_id,
                   program_update_date,
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
                   attribute15)
               select
                   substitute_component_id,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login,
                   substitute_item_quantity,
                   component.component_sequence_id, -- new component
                   acd_type,
                   change_notice, --null, bug 5174519
                   request_id,
                   program_application_id,
                   program_id,
                   program_update_date,
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
                   attribute15
               from bom_substitute_components
               where component_sequence_id =
                        component.old_component_sequence_id
               and   nvl(acd_type, acd_add) = acd_add
               and   substitute_component_id not in (
                        select substitute_component_id
                        from bom_substitute_components
                        where component_sequence_id =
                              component.component_sequence_id);
           -- Copy reference designators
              Insert into bom_reference_designators (
                 component_reference_designator,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 ref_designator_comment,
                 change_notice,
                 component_sequence_id,
                 acd_type,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date,
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
                 attribute15)
              select
                 component_reference_designator,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 ref_designator_comment,
                 change_notice, --null, bug 5174519
                 component.component_sequence_id, -- new component
                 acd_type,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date,
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
                 attribute15
            from bom_reference_designators
            where component_sequence_id =
                     component.old_component_sequence_id
            and   nvl(acd_type, acd_add) = acd_add -- adds only
            and   component_reference_designator not in (
                  select component_reference_designator
                  from bom_reference_designators
                  where component_sequence_id =
                        component.component_sequence_id);
        end if; -- Copy component's children

        If component.acd_type in (acd_add, acd_change) and
        component.quantity_related = yes then
            Open count_ref_designators(component.component_sequence_id);
            Fetch count_ref_designators into ref_designator_count;
            Close count_ref_designators;
            If component.component_quantity <> ref_designator_count then
                If msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) := 'ENG_QUANTITY_RELATED_2';
                        token1(msg_qty) := 'ITEM';
                        value1(msg_qty) := component.item_number;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := null;
                        value2(msg_qty) := null;
                        translate2(msg_qty) := 0;
                end if;
                If trial_mode = no then
                        Raise abort_implementation;
                end if;
            end if;
        end if; -- reference designator count

        -- Check fractional component quantities if OE is installed
        -- and the revised item is PTO

        If component.acd_type in (acd_add, acd_change) and
           X_InstallStatus = 'I' and
           item.pick_components_flag = 'Y' and
           component.component_quantity <> trunc(component.component_quantity)
        then
                If msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) := 'ENG_FRACTIONAL_QTY';
                        token1(msg_qty) := 'ITEM';
                        value1(msg_qty) := component.item_number;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := null;
                        value2(msg_qty) := null;
                        translate2(msg_qty) := 0;
                end if;
                If trial_mode = no then
                        Raise abort_implementation;
                end if;
        end if;

        -- added for structure revision
        If component.acd_type in (acd_add, acd_change) then
                IF item.new_structure_revision is not null THEN
                          component.from_object_revision_id := X_new_structure_revision_id;
                END IF;
                IF component.overlapping_changes = 1 THEN
                          component.overlapping_changes := null;
                END IF;
        end if;

        Update bom_components_b--bom_inventory_components
        set implementation_date = today,
            change_notice = item.change_notice,
            disable_date = component.disable_date,
            effectivity_date = eff_date,
            from_object_revision_id = component.from_object_revision_id,
            overlapping_changes = component.overlapping_changes,
            last_update_date = sysdate,
            last_updated_by = userid,
            last_update_login = loginid,
            request_id = reqstid,
            program_application_id = appid,
            program_id = progid,
            program_update_date = sysdate
        -- where current of chng_component_rows;
        where component_sequence_id = component.component_sequence_id;
        -----------------------------------------------------------
        -- R12: Changes for Common BOM Enhancement
        -- Step 3: Implementing Referenced Pending Destination Components
        --         And Copy the Component's children to the Implemented Component
        -- Whether update attributes is requred from src to destination again ?
        -- Not done as any UI updates will maintain the attrs in sync
        -----------------------------------------------------------
        IF isCommonedBOM = 'Y'
        THEN
            UPDATE bom_components_b--bom_inventory_components
               SET implementation_date = today,
                   change_notice       = item.change_notice,
                   disable_date        = component.disable_date,
                   effectivity_date    = eff_date,
                   overlapping_changes = component.overlapping_changes,
                   last_update_date    = sysdate,
                   last_updated_by     = userid,
                   last_update_login   = loginid,
                   request_id          = reqstid,
                   program_application_id = appid,
                   program_id          = progid,
                   program_update_date = sysdate
             WHERE common_component_sequence_id = component.component_sequence_id
               AND common_component_sequence_id <> component_sequence_id
               AND implementation_date IS NULL
               AND change_notice = item.change_notice
               AND revised_item_sequence_id = item.revised_item_sequence_id;

            -- Update related components to set the effectivity and the disable date attributes
            -- as set above.
            -- This is a repitition of the move/copy related pending destination changes
            -- in the destination bill to the newly implemented component that is created
            -- as a reference in the destination bills.
            BOMPCMBM.Update_Related_Components(
                p_src_comp_seq_id => component.component_sequence_id
              , x_Mesg_Token_Tbl  => l_comn_mesg_token_tbl
              , x_Return_Status   => l_comn_return_status);
            If ( l_comn_return_status <> 'S')
            Then
                If msg_qty < max_messages
                then
                    msg_qty := msg_qty + 1;
                    message_names(msg_qty) := 'ENG_COM_COMP_UPDATE_FAILED';
                    token1(msg_qty) := 'ITEM';
                    value1(msg_qty) := component.item_number;
                    translate1(msg_qty) := 0;
                    token2(msg_qty) := null;
                    value2(msg_qty) := null;
                    translate2(msg_qty) := 0;
                end if;
                If trial_mode = no
                then
                    Close old_component;
                    Raise abort_implementation;
                end if;
            End If;

            -- Copy the components children to the referneced components
            -- implemented just above statement
            BOMPCMBM.Replicate_Ref_Desg(
                p_component_sequence_id => component.component_sequence_id
              , x_Mesg_Token_Tbl        => l_comn_mesg_token_tbl
              , x_Return_Status         => l_comn_return_status);
            BOMPCMBM.Replicate_Sub_Comp(
                p_component_sequence_id => component.component_sequence_id
              , x_Mesg_Token_Tbl        => l_comn_mesg_token_tbl
              , x_Return_Status         => l_comn_return_status);
        END IF;
        -----------------------------------------------------------
        -- R12: End Step 3: Changes for Common BOM Enhancement --
        -----------------------------------------------------------

--
-- Update all unimplemented rows that point to the old row, so that they now
-- point to the new component row.
--

        If component.acd_type = acd_change then
           IF item.eco_for_production = 2 Then
            Update bom_components_b--bom_inventory_components
            set    old_component_sequence_id = component.component_sequence_id,
                   last_update_date = sysdate,
                   last_updated_by = userid,
                   last_update_login = loginid,
                   request_id = reqstid,
                   program_application_id = appid,
                   program_id = progid,
                   program_update_date = sysdate
            where  old_component_sequence_id =
                   component.old_component_sequence_id
            and    implementation_date is null;
            --
            -- Here , the common Components are NOT being updated as they have been
            -- taken care of in the Step 1 of updation of pending desination changes.
            --
          END IF;
        end if; -- reset pointers

--
--  Copy all implemented components to eng_revised_components.
--

        Insert into eng_revised_components(
                component_sequence_id,
                component_item_id,
                operation_sequence_num,
                bill_sequence_id,
                change_notice,
                effectivity_date,
                component_quantity,
                component_yield_factor,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                old_component_sequence_id,
                item_num,
                wip_supply_type,
                component_remarks,
                supply_subinventory,
                supply_locator_id,
                implementation_date,
                disable_date,
                acd_type,
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
                include_on_bill_docs,
                low_quantity,
                high_quantity,
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
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                revised_item_sequence_id,
                from_end_item_unit_number,
                to_end_item_unit_number,
                eco_for_production,
                FROM_END_ITEM_REV_ID,
                TO_END_ITEM_REV_ID,
                FROM_OBJECT_REVISION_ID,
                TO_OBJECT_REVISION_ID,
                FROM_END_ITEM_MINOR_REV_ID,
                TO_END_ITEM_MINOR_REV_ID,
                COMPONENT_ITEM_REVISION_ID,
                COMMON_COMPONENT_SEQUENCE_ID,
                BASIS_TYPE)
         select
                component_sequence_id,
                component_item_id,
                operation_seq_num,
                bill_sequence_id,
                change_notice,
                effectivity_date,
                component_quantity,
                component_yield_factor,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                old_component_sequence_id,
                item_num,
                wip_supply_type,
                component_remarks,
                supply_subinventory,
                supply_locator_id,
                implementation_date,
                disable_date,
                acd_type,
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
                include_on_bill_docs,
                low_quantity,
                high_quantity,
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
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                revised_item_sequence_id,
                from_end_item_unit_number,
                to_end_item_unit_number,
                eco_for_production,
                FROM_END_ITEM_REV_ID,
                TO_END_ITEM_REV_ID,
                FROM_OBJECT_REVISION_ID,
                TO_OBJECT_REVISION_ID,
                FROM_END_ITEM_MINOR_REV_ID,
                TO_END_ITEM_MINOR_REV_ID,
                COMPONENT_ITEM_REVISION_ID,
                COMMON_COMPONENT_SEQUENCE_ID,
                BASIS_TYPE
        from bom_components_b --bom_inventory_components
        where component_sequence_id = component.component_sequence_id;
        If component.acd_type = acd_delete then
            Delete from bom_components_b --bom_inventory_components
            -- where current of chng_component_rows;
               where component_sequence_id = component.component_sequence_id;

            -----------------------------------------------------------
            -- R12: Changes for Common BOM Enhancement
            -- Step 4: Deleting Related Disabled Components
            -- When the disabled component is deleted from the bill,
            -- and it is a commoned bill, it will have referenced components
            -- in the common (destination) bills which also have to be deleted
            -- This record will have a reference to the change_notice and
            -- revised_item_sequence_id of the commoned component.
            -----------------------------------------------------------
            IF isCommonedBOM = 'Y'
            THEN
                DELETE FROM bom_components_b bcb
                 WHERE bcb.common_component_sequence_id = component.component_sequence_id
                   AND bcb.common_component_sequence_id <> bcb.component_sequence_id
                   AND bcb.implementation_date IS null
                   AND bcb.change_notice = item.change_notice
                   AND bcb.revised_item_sequence_id = item.revised_item_sequence_id
                   AND bcb.acd_type = acd_delete;
            END IF;
            -----------------------------------------------------------
            -- R12: End Step 4: Changes for Common BOM Enhancement --
            -----------------------------------------------------------
        end if;

    -- ERES changes begin : bug 3741444
    bERES_Flag_for_BOM := TRUE;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'in component loop... bERES_Flag_for_BOM=TRUE');
    -- ERES changes end.

    -- Bug 4584490: Changes for Bom Business Events
    -- l_BOMEvents_Comps_ACD:
    -- Setting as add when the components are only added to this bill
    -- Setting it as change if components are changed or disabled in this bill.
    -- Removed l_BOMEvents_Comps_ACD clause so that component quantity change will raise an event.
    IF (component.acd_type = acd_add AND l_BOMEvents_Comps_ACD IS NULL)
    THEN
        l_BOMEvents_Comps_ACD := acd_add;
    ELSIF (component.acd_type IN (acd_change, acd_delete) )
    THEN
        l_BOMEvents_Comps_ACD := acd_change;
    END IF;
    -- End changes for 4584490
    end loop; -- all components



    Update bom_bill_of_materials
    set last_update_date = sysdate,
        last_updated_by = userid,
        last_update_login = loginid,
        request_id = reqstid,
        program_application_id = appid,
        program_id = progid,
        program_update_date = sysdate,
        pending_from_ecn = null
    where bill_sequence_id = item.bill_sequence_id
    AND pending_from_ecn = item.change_notice; -- Fixed for bug 3646438

    -- Bug 4584490: Changes for Bom Business Events
    BEGIN
        IF item.eco_for_production = 2
        THEN
            IF (l_pending_from_ecn = item.change_notice AND l_BOMEvents_Comps_ACD = acd_add)
            THEN
                l_BOMEvents_Bill_Event_Name := Bom_Business_Event_PKG.G_STRUCTURE_CREATION_EVENT;
            ELSIF l_BOMEvents_Comps_ACD IS NOT NULL
            THEN
                l_BOMEvents_Bill_Event_Name := Bom_Business_Event_PKG.G_STRUCTURE_MODIFIED_EVENT;
            END IF;
            IF (l_BOMEvents_Bill_Event_Name IS NOT NULL)
            THEN
                Bom_Business_Event_PKG.Raise_Bill_Event(
                    p_pk1_value         => item.revised_item_id
                  , p_pk2_value         => item.organization_id
                  , p_obj_name          => null
                  , p_structure_name    => l_alternate_designator
                  , p_organization_id   => item.organization_id
                  , p_structure_comment => NULL
                  , p_Event_Name        => l_BOMEvents_Bill_Event_Name
		  , p_revised_item_sequence_id => item.revised_item_sequence_id    -- Added for bug#8574333
                  );
            END IF;
        END IF;
    EXCEPTION
    WHEN OTHERS THEN
        null;
        -- nothing is required to be done, process continues
    END;
    -- End changes for 4584490

-- ERES change begins
--#######################################################
-- Call the billCreate / billUpdate ERES event:
-- BillCreate or billUpdate are children of event ecoImplementation
-- Create or Update is decided on the value of
--   column pending_from_ecn.
--#######################################################
IF (l_eres_enabled = 'Y')
THEN
 -- bug 3234628, May-2004:
 -- odaboval added this test in order to only raise an ERES event
 --          when a row in bom_bill_of_materials has been updated:
 -- bug 3741444 : added bERES_Flag_for_BOM in the condition
 --               and removed ROWCOUNT>0 from the condition.
 IF (bERES_Flag_for_BOM)
 THEN
  -- First: Preparing child event BillCreate/Update
  IF (NVL(item.bill_sequence_id, -1) > 0)
  THEN
    l_event.param_name_1  := 'DEFERRED';
    l_event.param_value_1 := 'Y';

    l_event.param_name_2  := 'POST_OPERATION_API';
    l_event.param_value_2 := 'NONE';

    l_event.param_name_3  := 'PSIG_USER_KEY_LABEL';
    FND_MESSAGE.SET_NAME('BOM', 'BOM_ERES_BILL_USER_KEY');
    l_event.param_value_3 := FND_MESSAGE.GET;

    l_event.param_name_4  := 'PSIG_USER_KEY_VALUE';
    IF (l_alternate_designator IS NOT NULL)
    THEN
      l_event.param_value_4 := item.concatenated_segments||' - '||item.organization_code||' - '||l_alternate_designator;
    ELSE
      l_event.param_value_4 := item.concatenated_segments||' - '||item.organization_code;
    END IF;

    l_event.param_name_5  := 'PSIG_TRANSACTION_AUDIT_ID';
    l_event.param_value_5 := -1;

    l_event.param_name_6  := '#WF_SOURCE_APPLICATION_TYPE';
    l_event.param_value_6 := 'DB';

    l_event.param_name_7  := '#WF_SIGN_REQUESTER';
    l_event.param_value_7 := FND_GLOBAL.USER_NAME;

    IF (l_pending_from_ecn IS NULL)
    THEN
       l_child_event_name := 'oracle.apps.bom.billUpdate';
    ELSE
       l_child_event_name := 'oracle.apps.bom.billCreate';
    END IF;

    IF (NVL(l_parent_record_id, -1) > 0)
    THEN
      --additional parameters for the child event
      l_event.param_name_8 := 'PARENT_EVENT_NAME';
      l_event.param_value_8 := 'oracle.apps.eng.ecoImplement';
      l_event.param_name_9 := 'PARENT_EVENT_KEY';
      l_event.param_value_9 := TO_CHAR(item.change_id);
      l_event.param_name_10 := 'PARENT_ERECORD_ID';
      l_event.param_value_10 := TO_CHAR(l_parent_record_id);
    END IF;

    -- Part 2 of preparation of child event :
    l_event.event_name   := l_child_event_name;
    l_event.event_key    := TO_CHAR(item.bill_sequence_id);
    -- l_event.payload      := l_payload;
    l_event.erecord_id   := l_erecord_id;
    l_event.event_status := l_event_status;

    QA_EDR_STANDARD.RAISE_ERES_EVENT
           ( p_api_version      => 1.0
           , p_init_msg_list    => FND_API.G_FALSE
           , p_validation_level => FND_API.G_VALID_LEVEL_FULL
           , x_return_status    => l_return_status
           , x_msg_count        => l_msg_count
           , x_msg_data         => l_msg_data
           , p_child_erecords   => l_child_record
           , x_event            => l_event);

    IF (NVL(l_return_status, FND_API.G_FALSE) <> FND_API.G_TRUE)
      AND (l_msg_count > 0)
    THEN
       RAISE ERES_EVENT_ERROR;
    END IF;

    -- Keep the eRecord id :
    IF (NVL(l_event.erecord_id, -1) > 0)
    THEN
      INSERT INTO ENG_PARENT_CHILD_EVENTS_TEMP(parent_event_name
         , parent_event_key, parent_erecord_id
         , event_name, event_key, erecord_id
         , event_status)
      VALUES ( 'oracle.apps.eng.ecoImplement', TO_CHAR(item.change_id)
         , l_parent_record_id
         , l_event.event_name, l_event.event_key, l_event.erecord_id
         , l_event.event_status);

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'After event='||l_child_event_name||', eRecord_id='||l_event.erecord_id||', status='||l_event.event_status||', bill='||item.bill_sequence_id);
    ELSE
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'No eRecord generated for '||l_event.event_name||'. This is normal. Please check your rules or other setups');
    END IF;
  END IF;    -- (NVL(item.bill_sequence_id, -1) > 0)

 ELSE
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'bERES_Flag_for_BOM=FALSE, then, NO ERES event for BOM .');
 END IF;   -- SQL%ROWCOUNT > 0
END IF;   -- l_eres_enabled
-- ERES change ends

--
--   Mark the RTG header as no longer pending from ECO
--   added for eco enhancement
-- ERES Change begins
-- Decision for RoutingCreate or Update depends on pending_from_ecn:
    OPEN Get_Operational_Routing_Info( item.routing_sequence_id);
    FETCH Get_Operational_Routing_Info
     INTO l_pending_from_ecn
        , l_alternate_designator;
    CLOSE Get_Operational_Routing_Info;
-- ERES change ends

    Update bom_operational_routings
    set last_update_date = sysdate,
        last_updated_by = userid,
        last_update_login = loginid,
        request_id = reqstid,
        program_application_id = appid,
        program_id = progid,
        program_update_date = sysdate,
        pending_from_ecn = null
    where routing_sequence_id = item.routing_sequence_id
    and pending_from_ecn is not null; --for bugfix 3234628

-- ERES change begins
--#######################################################
-- Call the routingUpdate ERES event:
-- RoutingCreate or RoutingUpdate are children of event ecoImplementation
-- Create or Update is decided on the value of
--   column pending_from_ecn.
--######################################################
IF (l_eres_enabled = 'Y')
THEN
 -- bug 3234628, May-2004:
 -- odaboval added this test in order to only raise an ERES event
 --          when a row in bom_operational_routings has been updated:
 -- bug 3908563 : added bERES_Flag_for_Routing in the condition
 --               and removed ROWCOUNT>0 from the condition.
 IF (bERES_Flag_for_Routing)
 THEN
  -- Preparing child event RoutingCreate/Update
  IF (NVL(item.routing_sequence_id, -1) > 0)
  THEN
    l_event.param_name_1  := 'DEFERRED';
    l_event.param_value_1 := 'Y';

    l_event.param_name_2  := 'POST_OPERATION_API';
    l_event.param_value_2 := 'NONE';

    l_event.param_name_3  := 'PSIG_USER_KEY_LABEL';
    FND_MESSAGE.SET_NAME('BOM', 'BOM_ERES_ROUTING_USER_KEY');
    l_event.param_value_3 := FND_MESSAGE.GET;

    l_event.param_name_4  := 'PSIG_USER_KEY_VALUE';
    IF (l_alternate_designator IS NOT NULL)
    THEN
      l_event.param_value_4 := item.concatenated_segments||' - '||item.organization_code||' - '||l_alternate_designator;
    ELSE
      l_event.param_value_4 := item.concatenated_segments||' - '||item.organization_code;
    END IF;

    l_event.param_name_5  := 'PSIG_TRANSACTION_AUDIT_ID';
    l_event.param_value_5 := -1;

    l_event.param_name_6  := '#WF_SOURCE_APPLICATION_TYPE';
    l_event.param_value_6 := 'DB';

    l_event.param_name_7  := '#WF_SIGN_REQUESTER';
    l_event.param_value_7 := FND_GLOBAL.USER_NAME;

    IF (l_pending_from_ecn IS NULL)
    THEN
       l_child_event_name := 'oracle.apps.bom.routingUpdate';
    ELSE
       l_child_event_name := 'oracle.apps.bom.routingCreate';
    END IF;

    IF (NVL(l_parent_record_id, -1) > 0)
    THEN
      --additional parameters for the child event
      l_event.param_name_8 := 'PARENT_EVENT_NAME';
      l_event.param_value_8 := 'oracle.apps.eng.ecoImplement';
      l_event.param_name_9 := 'PARENT_EVENT_KEY';
      l_event.param_value_9 := TO_CHAR(item.change_id);
      l_event.param_name_10 := 'PARENT_ERECORD_ID';
      l_event.param_value_10 := TO_CHAR(l_parent_record_id);
    END IF;

    -- Part 2 of preparation of child event :
    l_event.event_name   := l_child_event_name;
    l_event.event_key    := TO_CHAR(item.routing_sequence_id);
    -- l_event.payload      := l_payload;
    l_event.erecord_id   := l_erecord_id;
    l_event.event_status := l_event_status;

    QA_EDR_STANDARD.RAISE_ERES_EVENT
           ( p_api_version      => 1.0
           , p_init_msg_list    => FND_API.G_FALSE
           , p_validation_level => FND_API.G_VALID_LEVEL_FULL
           , x_return_status    => l_return_status
           , x_msg_count        => l_msg_count
           , x_msg_data         => l_msg_data
           , p_child_erecords   => l_child_record
           , x_event            => l_event);

    IF (NVL(l_return_status, FND_API.G_FALSE) <> FND_API.G_TRUE)
      AND (l_msg_count > 0)
    THEN
       RAISE ERES_EVENT_ERROR;
    END IF;

    -- Keep the eRecord id :
    IF (NVL(l_event.erecord_id, -1) > 0)
    THEN
      INSERT INTO ENG_PARENT_CHILD_EVENTS_TEMP(parent_event_name
         , parent_event_key, parent_erecord_id
         , event_name, event_key, erecord_id
         , event_status)
      VALUES ( 'oracle.apps.eng.ecoImplement', TO_CHAR(item.change_id)
         , l_parent_record_id
         , l_event.event_name, l_event.event_key, l_event.erecord_id
         , l_event.event_status);

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'After event='||l_child_event_name||', eRecord_id='||l_event.erecord_id||', status='||l_event.event_status||', routing='||item.routing_sequence_id);
    ELSE
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'No eRecord generated for '||l_event.event_name||'. This is normal. Please check your rules or other setups');
    END IF;

  END IF;    -- (NVL(item.routing_sequence_id, -1) > 0)
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Normal end of ERES Calls for procedure implement_revised_item.');

 ELSE
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'bERES_Flag_for_Routing=FALSE, then, NO ERES event for Routing.');
 END IF;   -- SQL%ROWCOUNT > 0
END IF;   -- l_eres_enabled
-- ERES change ends

Update eng_revised_items
set     implementation_date = today,
        scheduled_date = eff_date,
        status_type = 6,
        last_update_date = sysdate,
        last_updated_by = userid,
        last_update_login = loginid,
        request_id = reqstid,
        program_application_id = appid,
        program_id = progid,
        program_update_date = sysdate,
        status_code = p_status_code
-- where current of get_item_info;
   where revised_item_sequence_id = item.revised_item_sequence_id;


-- set values for inserting rows into wip schedule interface
   l_wip_primary_item_id := item.revised_item_id;
   l_wip_from_cum_qty    := item.from_cum_qty;
   l_from_wip_entity_id  := item.from_wip_entity_id;
   l_to_wip_entity_id    := item.to_wip_entity_id;

   IF item.new_item_revision IS NOT NULL
   THEN
      l_wip_bom_revision2          := item.new_item_revision;
      l_wip_bom_revision_date2     := revision_high_date + 1/60/24;
   ELSE
      l_wip_bom_revision2          := l_current_revision;
  /*    IF l_current_rev_eff_date <= now
      THEN
         l_wip_bom_revision_date2     := revision_high_date;
      ELSE
          IF l_current_rev_eff_date < revision_high_date
         THEN
           l_wip_bom_revision_date2     := revision_high_date;
         ELSE
           l_wip_bom_revision_date2     := l_current_rev_eff_date;
         END IF;
      END IF;
   */
     IF l_current_rev_eff_date <=  revision_high_date
      THEN
         l_wip_bom_revision_date2     := revision_high_date + 1/60/24;
      ELSE
         l_wip_bom_revision_date2     := l_current_rev_eff_date;
      END IF;

   END IF;

   IF item.new_routing_revision IS NOT NULL
   THEN
      l_wip_routing_revision2      := item.new_routing_revision;
      l_wip_routing_revision_date2 := rtg_revision_high_date + 1/60/24;
   ELSE
      l_wip_routing_revision2          := l_current_rtg_revision;
  /*    IF l_current_rtg_rev_eff_date <= now
      THEN
         l_wip_routing_revision_date2  := now;
      ELSE
         IF l_current_rtg_rev_eff_date < rtg_revision_high_date
         THEN
           l_wip_routing_revision_date2     := rtg_revision_high_date;
         ELSE
           l_wip_routing_revision_date2     := l_current_rtg_rev_eff_date;
         END IF;
      END IF;
   */
      IF l_current_rtg_rev_eff_date <= rtg_revision_high_date
      THEN
         l_wip_routing_revision_date2  := rtg_revision_high_date + 1/60/24;
      ELSE
           l_wip_routing_revision_date2  := l_current_rtg_rev_eff_date;
      END IF;

   END IF;

   l_wip_bom_revision_date1 := l_wip_bom_revision_date2- 1/3600/24;         -- minus 1 second
   l_wip_routing_revision_date1 := l_wip_bom_revision_date2- 1;             -- minus 1 day

   l_update_wip                 := NVL(item.update_wip,2);
   l_eco_for_production         := NVL(item.eco_for_production, 2);

END IF; -- Check for Transfer/Copy OR Revised Item Change

Close get_item_info;

Open check_for_unimp_items;
Fetch check_for_unimp_items into dummy;
If check_for_unimp_items%notfound then
        -- old code before 11.5.10 lifecycle enhancement
        /*
        Update eng_engineering_changes
        set    implementation_date = today,
               status_type = 6,
               last_update_date = sysdate,
               last_updated_by = userid,
               last_update_login = loginid,
               request_id = reqstid,
               program_application_id = appid,
               program_id = progid,
               program_update_date = sysdate
        where  organization_id = item.organization_id
        and    change_notice = item.change_notice;
        */

        -- New code: begin
    -- Check if implementation of header is allowed or not for the current phase
    -- added for bug 3482152
    select nvl(plm_or_erp_change, 'PLM') , status_code
    into l_plm_or_erp_change, l_curr_status_code
    from eng_engineering_changes where
    change_id = item.change_id;

    l_implement_header := 'T';
    l_implement_header := check_header_impl_allowed(
                                p_change_id => item.change_id
                              , p_change_notice => item.change_notice
                              , p_status_code => p_status_code
                              , p_curr_status_code => l_curr_status_code
                              , p_plm_or_erp_change => l_plm_or_erp_change
                              , p_request_id => reqstid);

    IF (l_implement_header = 'T')
    THEN
        -- setting the end-date to the current phase if null
        -- added for bug 3482152
        UPDATE eng_lifecycle_statuses
        SET completion_date = sysdate,
            last_update_date = sysdate,
            last_updated_by = userid,
            last_update_login = loginid
        WHERE entity_name = 'ENG_CHANGE'
          AND entity_id1 = item.change_id
          AND status_code = l_curr_status_code
          AND active_flag = 'Y'
          AND completion_date IS NULL;

        -- First set header phase to implement
        Update eng_engineering_changes
        set implementation_date = today,
            status_type = 6,
            status_code = p_status_code,
            last_update_date = sysdate,
            last_updated_by = userid,
            last_update_login = loginid,
            request_id = reqstid,
            program_application_id = appid,
            program_id = progid,
            program_update_date = sysdate
        where organization_id = item.organization_id
          and change_notice = item.change_notice;

        -- Reset promote_status_code
        Update eng_engineering_changes
        set promote_status_code = null
        where organization_id = item.organization_id
          and change_notice = item.change_notice;

        -- Complete the last phase in the lifecycle
        UPDATE eng_lifecycle_statuses
        SET start_date  = nvl(start_date,sysdate),      -- set the start date on implemented phase after promoting the header to implemented phase
                                        -- added for bug 3482152
            completion_date = sysdate,
            last_update_date = sysdate,
            last_updated_by = userid,
            last_update_login = loginid
        WHERE entity_name = 'ENG_CHANGE'
          AND entity_id1 = (SELECT change_id
                            FROM eng_engineering_changes
                            WHERE organization_id = item.organization_id
                              AND change_notice = item.change_notice
                            )
          AND active_flag = 'Y'
          AND sequence_number = (SELECT max(sequence_number)
                                 FROM eng_lifecycle_statuses
                                 WHERE entity_name = 'ENG_CHANGE'
                                   AND entity_id1 = (SELECT change_id
                                                     FROM eng_engineering_changes
                                                     WHERE organization_id = item.organization_id
                                                       AND change_notice = item.change_notice
                                                     )
                                 );
        -- New code: end

        -- Fix for bug: 3463308
        /* does not work for some reason, but do not delete
        FND_FILE.PUT_NAMES('CP.impECO.wf.log',
                           'CP.impECO.wf.out',
                           '/appslog/bis_top/utl/plm115dt/log'
                           );
        FND_FILE.PUT_LINE(fnd_file.log, 'Before: calling startWorkflow');
        FND_FILE.PUT_LINE(fnd_file.log, '  item.change_id = ' || item.change_id);
        */
                    -- using dynamic sql to launch status_change workflow API for implement phase
        BEGIN
          -- Log action for promotion to implement phase
          l_plsql_block :=
            'BEGIN '
            || ' ENG_CHANGE_ACTIONS_UTIL.Create_Change_Action('
            || ' p_api_version        => 1.0 '
            || ',x_return_status      => :1     '
            || ',x_msg_count          => :2     '
            || ',x_msg_data           => :3     '
            || ',p_action_type        => ''PROMOTE'' '
            || ',p_object_name        => ''ENG_CHANGE'' '
            || ',p_object_id1         => :4 '
            || ',p_parent_action_id   => -1 '
            || ',p_status_code        => :5 '  -- seeded value for implement phase
            || ',p_action_date        => SYSDATE '
            || ',p_change_description => NULL '
            || ',p_user_id            => -10000 '
            || ',p_api_caller         => ''WF'' '
            || ',x_change_action_id   => :6 '
            /*
            || ',p_init_msg_list      => FND_API.G_TRUE '
            || ',p_validation_level   => FND_API.G_VALID_LEVEL_FULL '
            || ',p_debug              => FND_API.G_TRUE '
            || ',p_output_dir         => ''/appslog/bis_top/utl/plm115dt/log'' '
            || ',p_debug_filename     => ''engact.createAct4Imp.log'' '
            */
            || '); END;';
          EXECUTE IMMEDIATE l_plsql_block USING
            OUT l_return_status,  -- :1
            OUT l_msg_count,      -- :2
            OUT l_msg_data,       -- :3
            IN  item.change_id,   -- :4
            IN  p_status_code,    -- :5
            OUT l_action_id;      -- :6

          -- Bug Fix: 5023201
          -- Should not start workflow if it's MFG Change Order
          IF ( l_plm_or_erp_change = 'PLM' )
          THEN
					 	--- Bug 6982970 vggarg code added for status change business event fire start
					   SELECT cot.base_change_mgmt_type_code
					   INTO l_base_cm_type_code
					   FROM eng_engineering_changes ec,
					        eng_change_order_types cot
					   WHERE ec.change_id = item.change_id
					   AND ec.change_mgmt_type_code = cot.change_mgmt_type_code
					   AND cot.type_classification = 'CATEGORY';

					  Raise_Status_Change_Event
					     ( p_change_id         => item.change_id
					      ,p_base_cm_type_code => l_base_cm_type_code
					      ,p_status_code       => p_status_code
					      ,p_action_type       => 'PROMOTE'
					      ,p_action_id         => l_action_id
					     );
				       --- Bug 6982970 vggarg code added for status change business event fire end

              -- Start workflow for phase change
              l_plsql_block :=
              'BEGIN '
              || ' Eng_Workflow_Util.StartWorkflow('
              || ' p_api_version        => 1.0 '
              || ',x_return_status      => :1	'
              || ',x_msg_count          => :2	'
              || ',x_msg_data           => :3	'
              || ',p_item_type          => Eng_Workflow_Util.G_CHANGE_ACTION_ITEM_TYPE '
              || ',x_item_key           => :4	'
              || ',p_process_name       => Eng_Workflow_Util.G_STATUS_CHANGE_PROC '
              || ',p_change_id          => :5	'
              || ',p_action_id          => :6	'
              || ',p_wf_user_id         => -10000	'
              || ',p_route_id           => 0 '
              /*
              || ',p_init_msg_list      => FND_API.G_TRUE '
              || ',p_validation_level   => FND_API.G_VALID_LEVEL_FULL '
              || ',p_debug              => FND_API.G_TRUE '
              || ',p_output_dir         => ''/appslog/bis_top/utl/plm115dt/log'' '
              || ',p_debug_filename     => ''engact.startWF4Imp.log'' '
              */
            || '); END;';
            EXECUTE IMMEDIATE l_plsql_block USING
              OUT l_return_status,  -- :1
              OUT l_msg_count,      -- :2
              OUT l_msg_data,       -- :3
              IN OUT l_item_key,    -- :4
              IN  item.change_id,   -- :5
              IN  l_action_id;      -- :6

            -- Bug: 3479509
  	    -- Starting the workflow associated to implemented status
	    SELECT change_wf_route_id
            INTO l_wf_route_id
            FROM eng_lifecycle_statuses
            WHERE entity_name = 'ENG_CHANGE'
            AND entity_id1 = item.change_id
            AND status_code = p_status_code
            AND active_flag = 'Y'
            AND rownum = 1;

            IF (l_wf_route_id IS NOT NULL) THEN
                l_plsql_block :=
                'BEGIN '
                || ' Eng_Workflow_Util.StartWorkflow('
                || ' p_api_version        => 1.0 '
                || ',x_return_status      => :1	'
                || ',x_msg_count          => :2	'
                || ',x_msg_data           => :3	'
                || ',p_item_type          => Eng_Workflow_Util.G_CHANGE_ROUTE_ITEM_TYPE '
                || ',x_item_key           => :4	'
                || ',p_process_name       => Eng_Workflow_Util.G_ROUTE_AGENT_PROC '
                || ',p_change_id          => :5	'
                || ',p_wf_user_id         => -10000	'
                || ',p_route_id           => :6 '
                || '); END;';
              EXECUTE IMMEDIATE l_plsql_block USING
                OUT l_return_status,  -- :1
                OUT l_msg_count,      -- :2
                OUT l_msg_data,       -- :3
                IN OUT l_item_key,    -- :4
                IN  item.change_id,   -- :5
                IN  l_wf_route_id;    -- :6
            END IF;

          END IF ; --  ( l_plm_or_erp_change = 'PLM' )

        EXCEPTION
          WHEN OTHERS THEN
            null;
        END;
        /* does not work for some reason, but do not delete
        FND_FILE.PUT_LINE(fnd_file.log, 'After: calling startWorkflow');
        FND_FILE.PUT_LINE(fnd_file.log, '  l_return_status = ' || l_return_status);
        FND_FILE.PUT_LINE(fnd_file.log, '  l_msg_count     = ' || to_char( nvl(l_msg_count, 0) ) );
        FND_FILE.PUT_LINE(fnd_file.log, '  l_msg_data      = ' || nvl(l_msg_data, 'no msg data') );
        FND_FILE.PUT_LINE(fnd_file.log, '  l_item_key      = ' || nvl(l_item_key, 'no item key') );
        FND_FILE.CLOSE;
        */
    END IF;
end if;
Close check_for_unimp_items;

-----------------------------------------------------------------
-- For ECO cumulative/ECO wip job/ECO lot  ---------9/07/2000----
-----------------------------------------------------------------
-- IF item.update_wip = 1 and  NVL(item.start_quantity,0) > 0
 IF l_update_wip = 1
 THEN

    SELECT wip_job_schedule_interface_s.NEXTVAL INTO  l_wip_group_id1
    FROM DUAL;
    group_id1 :=  l_wip_group_id1;  --- set out type value

    --bug 2327582
    l_update_all_jobs := fnd_profile.value('ENG:UPDATE_UNRELEASED_WIP_JOBS');

    l_wip_jsi_insert_flag :=  0;
    IF NVL(l_wip_from_cum_qty, 0) > 0
    THEN
      IF l_wip_start_quantity1 <> 0
      THEN
        SELECT wip_job_schedule_interface_s.NEXTVAL INTO  l_wip_group_id2
        FROM DUAL;
        group_id2 :=  l_wip_group_id2;  --- set out type value
      ELSE group_id2 := -1;
      END IF;

      --WIP job gets split into 2 based on the CUM quantity
      -- delete the original wip job
      INSERT INTO wip_job_schedule_interface
       (
         last_update_date
       , last_updated_by
       , creation_date
       , created_by
       , request_id
       , program_application_id
       , program_id
       , program_update_date
       , group_id
       , process_phase
       , process_status
       , organization_id
       , load_type
       , status_type
       , wip_entity_id
       )
       VALUES
       (
        sysdate
       , userid
       , sysdate
       , userid
       , reqstid
       , appid
       , progid
       , sysdate
       , l_wip_group_id1
       , l_wip_process_phase
       , l_wip_process_status
       , item.organization_id
       , 3    -- update or delete wip
       , 7    -- cancel wip order
       , item.from_wip_entity_id
      );

      -- Create first new order
      IF l_wip_start_quantity1 <> 0
      THEN
        INSERT INTO wip_job_schedule_interface
        (
          last_update_date
        , last_updated_by
        , creation_date
        , created_by
        , last_update_login
        , request_id
        , program_id
        , program_application_id
        , program_update_date
        , group_id
        , organization_id
        , load_type
        , status_type
        , primary_item_id
        , bom_revision_date
        , routing_revision_date
        , job_name
        , start_quantity
        , net_quantity
        , process_phase
        , process_status
        , last_unit_completion_date
        -- , routing_revision
        -- , bom_revision
        , completion_subinventory
        , completion_locator_id
        , allow_explosion
        , header_id
        )
        values
        ( sysdate
          , userid
          , sysdate
          , userid
          , loginid
          , reqstid
          , progid
          , appid
          , sysdate
          , l_wip_group_id2
          , l_wip_organization_id
          , l_wip_load_type
          , l_wip_status_type
          , l_wip_primary_item_id
          , l_wip_bom_revision_date1
          , decode(l_WIP_Flag_for_routing,'Y', l_wip_routing_revision_date1, NULL) -- Bug 4455543
          , l_wip_job_name1
          , l_wip_start_quantity1
          , l_wip_net_quantity1
          , l_wip_process_phase
          , l_wip_process_status
          , l_wip_last_u_compl_date1
          --, l_wip_routing_revision1
          --, l_wip_bom_revision1
          , l_wip_completion_subinventory
          , l_wip_completion_locator_id
          , l_wip_allow_explosion
          , l_wip_group_id2
        );

        -- Add components for 'Update Job Only' case
        -- Bug No: 5285282
        IF l_eco_for_production = 1
        THEN
          ENTER_WIP_DETAILS_FOR_COMPS ( p_revised_item_sequence_id => item.revised_item_sequence_id,
                                        p_group_id                 => l_wip_group_id2,
                                        p_parent_header_id         => l_wip_group_id2,
                                        p_mrp_active               => item.mrp_active,
                                        p_user_id                  => userid,
                                        p_login_id                 => loginid,
                                        p_request_id               => reqstid,
                                        p_program_id               => progid,
                                        p_program_application_id   => appid);
        END IF;
      END IF; -- IF l_wip_start_quantity1 <> 0

      -- Create second new records
      INSERT INTO wip_job_schedule_interface (
        last_update_date
       , last_updated_by
       , creation_date
       , created_by
       , last_update_login
       , request_id
       , program_id
       , program_application_id
       , program_update_date
       , group_id
       , organization_id
       , load_type
       , status_type
       , primary_item_id
       , bom_revision_date
       , routing_revision_date
       , job_name
       , start_quantity
       , net_quantity
       , process_phase
       , process_status
       , last_unit_completion_date
      -- , routing_revision
      -- , bom_revision
       , completion_subinventory
       , completion_locator_id
       , allow_explosion
       , header_id
       )
       values
       (
             sysdate
           , userid
           , sysdate
           , userid
           , loginid
           , reqstid
           , progid
           , appid
           , sysdate
           , l_wip_group_id1
           , l_wip_organization_id
           , l_wip_load_type
           , l_wip_status_type
           , l_wip_primary_item_id
           , l_wip_bom_revision_date2
           , decode(l_WIP_Flag_for_routing,'Y', l_wip_routing_revision_date2, NULL) -- Bug 4455543
           , l_wip_job_name2
           , l_wip_start_quantity2
           , l_wip_net_quantity2
           , l_wip_process_phase
           , l_wip_process_status
           , decode(l_WIP_Flag_for_routing,'Y',l_wip_last_u_compl_date2, NULL) -- Bug 4455543
      --     , l_wip_routing_revision2
      --     , l_wip_bom_revision2
           , l_wip_completion_subinventory
           , l_wip_completion_locator_id
           , l_wip_allow_explosion
           , l_wip_group_id1
      );

      -- Add components for 'Update Job Only' case
      -- Bug No: 5285282
      IF l_eco_for_production = 1
      THEN
        ENTER_WIP_DETAILS_FOR_COMPS ( p_revised_item_sequence_id => item.revised_item_sequence_id,
                                      p_group_id                 => l_wip_group_id1,
                                      p_parent_header_id         => l_wip_group_id1,
                                      p_mrp_active               => item.mrp_active,
                                      p_user_id                  => userid,
                                      p_login_id                 => loginid,
                                      p_request_id               => reqstid,
                                      p_program_id               => progid,
                                      p_program_application_id   => appid);
      END IF;

      l_wip_jsi_insert_flag := 1;

    ELSIF  NVL(l_to_wip_entity_id, 0) <> 0
    THEN
      FOR wip_name_for_job_rec in l_wip_name_for_job_cur
      LOOP
        l_wip_job_name2 := wip_name_for_job_rec.wip_entity_name;
        l_wip_last_u_compl_date2 :=  wip_name_for_job_rec.scheduled_completion_date;

	SELECT wip_job_schedule_interface_s.NEXTVAL INTO  l_wip_header_id
        FROM DUAL; --fix bug 5667398 cannot have duplicate header id from same group id
        /* Added for Bug2970539, Bug 3076067 */

        --if (l_wip_bom_revision_date2 > today) then          -- 3412747
        if (wip_name_for_job_rec.bom_revision_date > today)
        then
          l_wip_bom_revision_date2  := wip_name_for_job_rec.bom_revision_date;
        end if;
        --if (l_wip_routing_revision_date2 > today) then       -- 3412747
        if (wip_name_for_job_rec.routing_revision_date > today)
        then
          l_wip_routing_revision_date2 := wip_name_for_job_rec.routing_revision_date;
        end if;

        --Update existing WIP headers
        INSERT INTO wip_job_schedule_interface
        (
           last_update_date
         , last_updated_by
         , creation_date
         , created_by
         , last_update_login
         , request_id
         , program_id
         , program_application_id
         , program_update_date
         , group_id
         , organization_id
         , load_type
         , status_type
         , primary_item_id
         , bom_revision_date
         , routing_revision_date
         , job_name
         , process_phase
         , process_status
         , last_unit_completion_date
         , routing_revision
         , bom_revision
         , bom_reference_id
         , routing_reference_id
         , allow_explosion
         , alternate_bom_designator
         , alternate_routing_designator
	 , completion_subinventory
 	 , completion_locator_id
         , header_id
        )
        values
        (
           sysdate
         , userid
         , sysdate
         , userid
         , loginid
         , reqstid
         , progid
         , appid
         , sysdate
         , l_wip_group_id1
         , l_wip_organization_id
         , 3          --l_wip_load_type
         , l_wip_status_type
         , wip_name_for_job_rec.primary_item_id
         --, l_wip_primary_item_id
         , l_wip_bom_revision_date2
         , decode(l_WIP_Flag_for_routing,'Y',l_wip_routing_revision_date2, NULL) -- Bug 4455543
         , l_wip_job_name2
         , l_wip_process_phase
         , l_wip_process_status
         , decode(l_WIP_Flag_for_routing,'Y', l_wip_last_u_compl_date2, NULL) -- Bug 4455543
         , decode(l_WIP_Flag_for_routing,'Y', nvl(wip_name_for_job_rec.routing_revision, l_wip_routing_revision2)   -- Bug 3381547
                                      , NULL) -- Bug 4455543
         , nvl(wip_name_for_job_rec.bom_revision, l_wip_bom_revision2)              -- Bug 3381547
         , wip_name_for_job_rec.primary_item_id
         , decode(l_WIP_Flag_for_routing,'Y',wip_name_for_job_rec.primary_item_id, NULL) -- Bug 4455543
         --, l_wip_primary_item_id
         --, l_wip_primary_item_id
         , l_wip_allow_explosion
         ,wip_name_for_job_rec.alternate_bom_designator    --2964588
         ,decode(l_WIP_Flag_for_Routing,'Y',wip_name_for_job_rec.alternate_routing_designator,NULL)    --2964588, modified for bug 8412836
         , l_wip_completion_subinventory   -- Bug 5896479
         , l_wip_completion_locator_id     -- Bug 5896479
         , l_wip_header_id
        );

        -- Add components for 'Update Job Only' case
        -- Bug No: 5285282
        IF l_eco_for_production = 1
        THEN
          ENTER_WIP_DETAILS_FOR_COMPS ( p_revised_item_sequence_id => item.revised_item_sequence_id,
                                        p_group_id                 => l_wip_group_id1,
                                        p_parent_header_id         => l_wip_header_id,
                                        p_mrp_active               => item.mrp_active,
                                        p_user_id                  => userid,
                                        p_login_id                 => loginid,
                                        p_request_id               => reqstid,
                                        p_program_id               => progid,
                                        p_program_application_id   => appid);
        END IF;

        IF l_wip_jsi_insert_flag = 0
        THEN
          l_wip_jsi_insert_flag := 1;
        END IF ;
      END LOOP;

    ELSIF  NVL(l_lot_number,'NULL') <> 'NULL'
    THEN

      FOR wip_name_for_lot_rec in l_wip_name_for_lot_cur
      LOOP
        l_wip_job_name2 := wip_name_for_lot_rec.wip_entity_name;
        l_wip_last_u_compl_date2 :=  wip_name_for_lot_rec.scheduled_completion_date;

	SELECT wip_job_schedule_interface_s.NEXTVAL INTO  l_wip_header_id
        FROM DUAL; --fix bug 5667398 cannot have duplicate header id from same group id

        /* Added for Bug2970539, Bug 3076067 */

        --if (l_wip_bom_revision_date2 > today) then                             --3412747
        if (wip_name_for_lot_rec.bom_revision_date > today
            OR l_wip_bom_revision_date2 IS NULL      -- Added 'OR' condition for Bug #3988681
           )
        then
          l_wip_bom_revision_date2  := wip_name_for_lot_rec.bom_revision_date;
        end if;
        --if (l_wip_routing_revision_date2 > today) then                         --3412747
        if (wip_name_for_lot_rec.routing_revision_date > today
            OR l_wip_routing_revision_date2 IS NULL    -- Added 'OR' condition for Bug #3988681
            )
        then
          l_wip_routing_revision_date2 := wip_name_for_lot_rec.routing_revision_date;
        end if;

        INSERT INTO wip_job_schedule_interface
        (
          last_update_date
        , last_updated_by
        , creation_date
        , created_by
        , last_update_login
        , request_id
        , program_id
        , program_application_id
        , program_update_date
        , group_id
        , organization_id
        , load_type
        , status_type
        , primary_item_id
        , bom_revision_date
        , routing_revision_date
        , job_name
        , process_phase
        , process_status
        , last_unit_completion_date
        , routing_revision
        , bom_revision
        , bom_reference_id
        , routing_reference_id
        , allow_explosion
        , alternate_bom_designator
        , alternate_routing_designator
	, completion_subinventory
	, completion_locator_id
        , header_id
        )
        values
        (
           sysdate
           , userid
           , sysdate
           , userid
           , loginid
           , reqstid
           , progid
           , appid
           , sysdate
           , l_wip_group_id1
           --, l_wip_organization_id                    --3412747
           , wip_name_for_lot_rec.organization_id
           , 3      --l_wip_load_type
           , l_wip_status_type
           , wip_name_for_lot_rec.primary_item_id
      --     , l_wip_primary_item_id
           , l_wip_bom_revision_date2
           , decode(l_WIP_Flag_for_routing,'Y',l_wip_routing_revision_date2, null) -- Bug 4455543
           , l_wip_job_name2
           , l_wip_process_phase
           , l_wip_process_status
           , decode(l_WIP_Flag_for_routing,'Y',l_wip_last_u_compl_date2, null) -- Bug 4455543
           , decode(l_WIP_Flag_for_routing,'Y',nvl(wip_name_for_lot_rec.routing_revision, l_wip_routing_revision2) -- Bug 3381547
                      , null) -- Bug 4455543
           , nvl(wip_name_for_lot_rec.bom_revision, l_wip_bom_revision2) -- Bug 3381547
           , wip_name_for_lot_rec.primary_item_id
           , decode(l_WIP_Flag_for_routing,'Y',wip_name_for_lot_rec.primary_item_id, null) -- Bug 4455543
      --     , l_wip_primary_item_id
      --     , l_wip_primary_item_id
           , l_wip_allow_explosion
           ,wip_name_for_lot_rec.alternate_bom_designator    --2964588
           ,decode(l_WIP_Flag_for_Routing,'Y',wip_name_for_lot_rec.alternate_routing_designator,NULL)    --2964588, modified for bug 8412836
     	   , l_wip_completion_subinventory   -- Bug 5896479
	   , l_wip_completion_locator_id     -- Bug 5896479
           , l_wip_header_id
        );

        -- Add components for 'Update Job Only' case
        -- Bug No: 5285282
        IF l_eco_for_production = 1
        THEN
          ENTER_WIP_DETAILS_FOR_COMPS ( p_revised_item_sequence_id => item.revised_item_sequence_id,
                                        p_group_id                 => l_wip_group_id1,
                                        p_parent_header_id         => l_wip_header_id,
                                        p_mrp_active               => item.mrp_active,
                                        p_user_id                  => userid,
                                        p_login_id                 => loginid,
                                        p_request_id               => reqstid,
                                        p_program_id               => progid,
                                        p_program_application_id   => appid);
        END IF;

        IF l_wip_jsi_insert_flag = 0
        THEN
          l_wip_jsi_insert_flag := 1;
        END IF ;
      END LOOP;
    ELSE
    -- for updating other common wip discrete jobs

      FOR wip_name_for_common_rec in l_wip_name_for_common_cur
      LOOP
        l_wip_job_name2 := wip_name_for_common_rec.wip_entity_name;
        l_wip_last_u_compl_date2 :=  wip_name_for_common_rec.scheduled_completion_date;

	SELECT wip_job_schedule_interface_s.NEXTVAL INTO  l_wip_header_id
        FROM DUAL; --fix bug 5667398 cannot have duplicate header id from same group id

        /* Added for Bug2970539, Bug 3076067 */

        --if (l_wip_bom_revision_date2 > today) then                        --3412747
        if (wip_name_for_common_rec.bom_revision_date > today
            OR l_wip_bom_revision_date2 IS NULL      -- Added 'OR' condition for Bug #3988681
           )
        then
          l_wip_bom_revision_date2 := wip_name_for_common_rec.bom_revision_date;
        end if;
        --if (l_wip_routing_revision_date2 > today) then                    --3412747
        if (wip_name_for_common_rec.routing_revision_date > today
            OR l_wip_routing_revision_date2 IS NULL    -- Added 'OR' condition for Bug #3988681
           )
        then
          l_wip_routing_revision_date2 := wip_name_for_common_rec.routing_revision_date;
        end if;


        INSERT INTO wip_job_schedule_interface
           (
             last_update_date
           , last_updated_by
           , creation_date
           , created_by
           , last_update_login
           , request_id
           , program_id
           , program_application_id
           , program_update_date
           , group_id
           , organization_id
           , load_type
           , status_type
           , primary_item_id
           , bom_revision_date
           , routing_revision_date
           , job_name
           , process_phase
           , process_status
           , last_unit_completion_date
           , routing_revision
           , bom_revision
           , bom_reference_id
           , routing_reference_id
           , allow_explosion
           , alternate_bom_designator
           , alternate_routing_designator
 	   , completion_subinventory
	   , completion_locator_id
           , header_id
        )
        values
        (
          sysdate
          , userid
          , sysdate
          , userid
          , loginid
          , reqstid
          , progid
          , appid
          , sysdate
          , l_wip_group_id1
          --, l_wip_organization_id                      --3412747
          , wip_name_for_common_rec.organization_id
          , 3      --l_wip_load_type
          , l_wip_status_type
          , wip_name_for_common_rec.primary_item_id
          --, l_wip_primary_item_id
          , l_wip_bom_revision_date2
          , decode(l_WIP_Flag_for_routing,'Y',l_wip_routing_revision_date2, null) -- Bug 4455543
          , l_wip_job_name2
          , l_wip_process_phase
          , l_wip_process_status
          , decode(l_WIP_Flag_for_routing,'Y',l_wip_last_u_compl_date2, null) -- Bug 4455543
          , decode(l_WIP_Flag_for_routing,'Y', nvl(wip_name_for_common_rec.routing_revision,l_wip_routing_revision2) -- Bug 3381547
               , null) -- Bug 4455543
          , nvl(wip_name_for_common_rec.bom_revision,l_wip_bom_revision2)            -- Bug 3381547
          , wip_name_for_common_rec.primary_item_id
          , decode(l_WIP_Flag_for_routing,'Y',wip_name_for_common_rec.primary_item_id, null) -- Bug 4455543
          --, l_wip_primary_item_id
          --, l_wip_primary_item_id
          , l_wip_allow_explosion
          ,wip_name_for_common_rec.alternate_bom_designator    --2964588
          ,decode(l_WIP_Flag_for_Routing,'Y',wip_name_for_common_rec.alternate_routing_designator,NULL)    --2964588, modified for bug 8412836
	  , l_wip_completion_subinventory   -- Bug 5896479
	  , l_wip_completion_locator_id     -- Bug 5896479
          , l_wip_header_id
        );

        -- Add components for 'Update Job Only' case
        -- Bug No: 5285282
        IF l_eco_for_production = 1
        THEN
          ENTER_WIP_DETAILS_FOR_COMPS ( p_revised_item_sequence_id => item.revised_item_sequence_id,
                                        p_group_id                 => l_wip_group_id1,
                                        p_parent_header_id         => l_wip_header_id,
                                        p_mrp_active               => item.mrp_active,
                                        p_user_id                  => userid,
                                        p_login_id                 => loginid,
                                        p_request_id               => reqstid,
                                        p_program_id               => progid,
                                        p_program_application_id   => appid);
        END IF;

        IF l_wip_jsi_insert_flag = 0
        THEN
          l_wip_jsi_insert_flag := 1;
        END IF ;
      END LOOP;
    END IF;          -- end of IF NVL(item.start_quantity,0)

  END IF;   -- end of item.update_wip = 1 and NVL...
  IF l_wip_jsi_insert_flag = 0
  THEN  group_id1 :=  -1;  --- reset out type value
    group_id2 :=  -1;  --- reset out type value
  END IF;



Exception
        When abort_implementation then
                Close get_item_info;

        -- ERES change begins
        WHEN ERES_EVENT_ERROR THEN

          FND_MSG_PUB.Get(
            p_msg_index  => 1,
            p_data       => l_message,
            p_encoded    => FND_API.G_FALSE,
            p_msg_index_out => l_dummy_cnt);

          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error while creating event='||l_child_event_name||', key='||l_event.event_key);
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERES_EVENT_ERROR: '||l_message);
          event_acknowledgement('FAILURE');

          IF (msg_qty < max_messages)
          THEN
            msg_qty := msg_qty + 1;
            message_names(msg_qty) := 'ERES_EVENT_ERROR';
            token1(msg_qty) := 'CHANGE_ID';
            value1(msg_qty) := item.change_id;
            translate1(msg_qty) := 0;
            token2(msg_qty) := null;
            value2(msg_qty) := null;
            translate2(msg_qty) := 0;

            msg_qty := msg_qty + 1;
            message_names(msg_qty) := l_message;
            token1(msg_qty) := 'CHANGE_ID';
            value1(msg_qty) := item.change_id;
            translate1(msg_qty) := 0;
            token2(msg_qty) := null;
            value2(msg_qty) := null;
            translate2(msg_qty) := 0;
          END IF;
        -- ERES change ends

        When others then
          -- ERES change begins
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Others Error: '||SQLERRM);
          event_acknowledgement('FAILURE');
          -- ERES change ends

          -- Added for bug 4150069
          If c_get_revision%ISOPEN
          Then
              Close c_get_revision;
          End If;
          -- End changes for bug 4150069


                If msg_qty < max_messages then
                        msg_qty := msg_qty + 1;
                        message_names(msg_qty) := 'ENG_ORA_ERROR';
                        token1(msg_qty) := 'ROUTINE';
                        value1(msg_qty) := 'ENGPKLIMP';
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := 'SQLERRM';
                        value2(msg_qty) := substrb(sqlerrm, 1, 80);
                        translate2(msg_qty) := 0;
                end if;

end;
Procedure reverse_standard_bom(
        revised_item in eng_revised_items.revised_item_sequence_id%type,
        userid  in number,  -- user id
        reqstid in number,  -- concurrent request id
        appid   in number,  -- application id
        progid  in number,  -- program id
        loginid in number,  -- login id
        bill_sequence_id     in  eng_revised_items.bill_sequence_id%type,
        routing_sequence_id  in  eng_revised_items.routing_sequence_id%type,
        return_message OUT NOCOPY VARCHAR2,
        return_status in OUT NOCOPY NUMBER

     )
IS
     i NUMBER := 0;
     p_bill_sequence_id           number := bill_sequence_id;
     p_routing_sequence_id        number := routing_sequence_id;
     p_revised_item_sequence_id   number := revised_item;
     l_return_status         VARCHAR2(1);
--     l_mesg_token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
    l_comn_return_status     VARCHAR2(1);
    l_comn_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;
begin



 return_status := 0;
 return_message:= NULL;

 -- Reverse standard bom is called from ENCACN.opp,
 -- If bill sequence id is null, p_bill_sequence_id = -1
 IF p_bill_sequence_id <> -1 THEN
  --  Delete the related bom_reference_designators  records
  --  those records are still expected to show on the window after implementation
  --
 /* DELETE FROM bom_reference_designators
  WHERE component_sequence_id  IN
     ( SELECT  component_sequence_id
       FROM  bom_inventory_components
       WHERE
       --fixed  for bug 1870813
        revised_item_sequence_id = p_revised_item_sequence_id
        ) ;
*/
 --  Delete the related bom_substitute_components
/*  DELETE FROM bom_substitute_components
  WHERE component_sequence_id  IN
     ( SELECT  component_sequence_id
       FROM  bom_inventory_components
       -- fixed  for bug 1870813
       WHERE  revised_item_sequence_id = p_revised_item_sequence_id
     ) ;
*/
 -- before delete the related bom_inventory_components records,
 -- make the old conponents active again.
  FOR i in 1..rev_comp_disable_date_tbl.count
  LOOP

    UPDATE bom_components_b--bom_inventory_components
    SET
                disable_date = rev_comp_disable_date_tbl(i).disable_date,
                last_update_date = sysdate,
                last_updated_by = userid,
                last_update_login = loginid,
                request_id = reqstid,
                program_application_id = appid,
                program_id = progid,
                program_update_date = sysdate
    WHERE component_sequence_id = rev_comp_disable_date_tbl(i).component_seq_id;
  END LOOP;
  -----------------------------------------------------------
  -- R12: Changes for Common BOM Enhancement
  -- Step 2.1: Reset Common Component Details that had been updated
  -- when implementing the revised item
  -----------------------------------------------------------
  IF isCommonedBom = 'Y'
  THEN
      -- For moved pending destination components
      Reset_Common_Comp_Details(
          x_Mesg_Token_Tbl => l_comn_Mesg_Token_Tbl
        , x_return_status  => l_comn_return_status);
      -- For copied pending destination components
      DELETE FROM bom_components_b
      WHERE implementation_date IS NULL -- as pending changes were copied to the new component
        AND (bill_sequence_id, old_component_sequence_id) IN
                (SELECT bsb.bill_sequence_id, rbcb.component_sequence_id
                   FROM bom_components_b rbcb, bom_structures_b bsb
                  WHERE bsb.bill_sequence_id <> p_bill_sequence_id
                    AND bsb.source_bill_sequence_id = p_bill_sequence_id
                    AND rbcb.bill_sequence_id = bsb.bill_sequence_id
                    AND rbcb.revised_item_sequence_id = p_revised_item_sequence_id);
  END IF;
  -----------------------------------------------------------
  -- R12: End Step 2.1: Changes for Common BOM Enhancement --
  -----------------------------------------------------------
 -- Delete the related bom_inventory_components whose
 --  eco_for_production   =  1.
  DELETE FROM bom_components_b--bom_inventory_components
  WHERE  revised_item_sequence_id = p_revised_item_sequence_id ;

 -- Delete the related eng revised _components whose
 --  eco_for_production   =  1.
 /* DELETE FROM eng_revised_components
  WHERE bill_sequence_id = p_bill_sequence_id
  AND   eco_for_production   =  1;
*/

END IF;

  IF p_bill_sequence_id <> -1 THEN
 -- Delete all the substitute resources assigned to the operations
 -- whose eco_for_production   =  1.
/*  DELETE FROM bom_sub_operation_resources
  WHERE operation_sequence_id IN
    (  SELECT operation_sequence_id
       FROM bom_operation_sequences
       WHERE  revised_item_sequence_id = p_revised_item_sequence_id
            );
*/
 -- Delete all the resources assigned to the operations whose
 -- eco_for_production   =  1.
 /*
  DELETE FROM bom_operation_resources
  WHERE operation_sequence_id IN
    (  SELECT operation_sequence_id
       FROM bom_operation_sequences
       WHERE  revised_item_sequence_id = p_revised_item_sequence_id
         );
 */
 -- before delete the related operation sequence records,
 -- make the old operation active again

  FOR i in 1..rev_op_disable_date_tbl.count
  LOOP
    UPDATE bom_operation_sequences
    SET
                disable_date = rev_op_disable_date_tbl(i).disable_date,
                last_update_date = sysdate,
                last_updated_by = userid,
                last_update_login = loginid,
                request_id = reqstid,
                program_application_id = appid,
                program_id = progid,
                program_update_date = sysdate
    WHERE operation_sequence_id = rev_op_disable_date_tbl(i).operation_seq_id;
  END LOOP;

 -- Delete the related operation sequence records
  DELETE FROM bom_operation_sequences
  WHERE  revised_item_sequence_id = p_revised_item_sequence_id;

 -- Delete the related revised operation sequence records
 /* DELETE FROM eng_revised_operations
  WHERE routing_sequence_id = p_routing_sequence_id
  AND   eco_for_production   =  1;
*/
 END IF;


--Delete the related routing revision record
--  DELETE FROM mtl_rtg_item_revisions
--  WHERE  inventory_item_id = p_revised_item
--  AND    organization_id   = p_organization_id
--  AND    process_revision  = p_new_routing_revision;


 Exception
      When others then
                        return_status := 1;
                        return_message  :=  substrb(sqlerrm, 1, 80);
     end;

 -- Generate new wip job names
 PROCEDURE Generate_New_Wip_Name
      (
       p_wip_entity_name   IN VARCHAR2
      ,p_organization_id   IN NUMBER
      ,x_wip_entity_name1  OUT NOCOPY VARCHAR2
      ,x_wip_entity_name2  OUT NOCOPY VARCHAR2
      ,x_return_status     OUT NOCOPY NUMBER
     )
  IS
  l_wip_entity_name  VARCHAR2(240);
  l_dummy VARCHAR2(1);
  i NUMBER :=0;
  l_count  NUMBER := 0;

  CURSOR wip_job_name_cur
     (  l_wip_entity_name IN VARCHAR2,
        l_organization_id IN NUMBER
     )
  IS
  SELECT '1'
  FROM DUAL
  WHERE NOT EXISTS
  (SELECT 1
   FROM  WIP_ENTITIES
   WHERE organization_id = l_organization_id
   AND   wip_entity_name = l_wip_entity_name)
  ;

  wip_job_name_rec wip_job_name_cur%rowtype;

BEGIN

    WHILE l_count <> 2
    LOOP
       i := i + 1;
       l_wip_entity_name := p_wip_entity_name ||'_' ||  to_char(i);
       l_dummy := 0;
       OPEN wip_job_name_cur
            (  l_wip_entity_name,
               p_organization_id
            );

       FETCH wip_job_name_cur INTO l_dummy;
       IF wip_job_name_cur%FOUND
       THEN
          l_count := l_count + 1;
          IF l_count = 1
          THEN x_wip_entity_name1 :=  l_wip_entity_name ;
          ELSIF  l_count = 2
          THEN x_wip_entity_name2 :=  l_wip_entity_name ;
          END IF;
       END IF;

       CLOSE  wip_job_name_cur;
    END LOOP;

    x_return_status := 0;

 END generate_new_wip_name;

Procedure implement_revised_item(
        revised_item in eng_revised_items.revised_item_sequence_id%type,
        trial_mode in number,
        max_messages in number, -- size of host arrays
        userid  in number,  -- user id
        reqstid in number,  -- concurrent request id
        appid   in number,  -- application id
        progid  in number,  -- program id
        loginid in number,  -- login id
        bill_sequence_id        OUT NOCOPY eng_revised_items.bill_sequence_id%type ,
        routing_sequence_id     OUT NOCOPY eng_revised_items.routing_sequence_id%type ,
        eco_for_production      OUT NOCOPY eng_revised_items.eco_for_production%type ,
        revision_high_date      OUT NOCOPY mtl_item_revisions.effectivity_date%type,
        rtg_revision_high_date  OUT NOCOPY mtl_rtg_item_revisions.effectivity_date%type,
        update_wip              OUT NOCOPY eng_revised_items.update_wip%type ,
        group_id1               OUT NOCOPY wip_job_schedule_interface.group_id%type,
        group_id2               OUT NOCOPY wip_job_schedule_interface.group_id%type,
        wip_job_name1           OUT NOCOPY wip_entities.wip_entity_name%type,
        wip_job_name2           OUT NOCOPY wip_entities.wip_entity_name%type,
        wip_job_name2_org_id    OUT NOCOPY wip_entities.organization_id%type,
        message_names OUT NOCOPY NameArray,
        token1 OUT NOCOPY NameArray,
        value1 OUT NOCOPY StringArray,
        translate1 OUT NOCOPY BooleanArray,
        token2 OUT NOCOPY NameArray,
        value2 OUT NOCOPY StringArray,
        translate2 OUT NOCOPY BooleanArray,
        msg_qty in OUT NOCOPY binary_integer,
        warnings in OUT NOCOPY number) is

  l_is_revised_item_change      NUMBER;
  l_now                         DATE;
  l_status_code                 NUMBER := 6;
  l_plm_or_erp_change           VARCHAR2(3);
  l_return_status               VARCHAR2(2000);
  l_msg_data                    VARCHAR2(2000);
  l_change_type_id              NUMBER;
  l_change_id                   NUMBER;
  l_approval_status             NUMBER;
  l_msg_count                   NUMBER := 0;
  l_message_name                VARCHAR2(50);
  l_message_desc                VARCHAR2(100);
  /*
  Cursor to fetch all the sub revised items diven the revised item sequence id
  In ERP, only one revised item exists.
  In PLM, sub revised items may exist given a parent revised item sequence id
  */

  CURSOR c_revised_items_all is
  SELECT *
  FROM eng_revised_items
  WHERE (revised_item_sequence_id = revised_item
  /*OR parent_revised_item_seq_id = revised_item*/)
  AND status_type <> 5; -- to remove cancelled revised items

  l_plsql_block VARCHAR2(2000);
  l_implementation_status VARCHAR2(30);

  abort_implementation exception;

BEGIN
        l_now := sysdate;

        -- Get the change id
        SELECT change_id
        INTO l_change_id
        FROM eng_revised_items
        WHERE revised_item_sequence_id = revised_item;

        -- Get whether it is a plm or erp change
        SELECT  nvl(plm_or_erp_change, 'PLM')
        INTO l_plm_or_erp_change
        FROM eng_engineering_changes
        WHERE change_id = l_change_id;

        -- Bug : 3446554 Determine the status code for PLM records
        IF(l_plm_or_erp_change = 'PLM')
        THEN
                -- In the PLM change lifecycle - 11.5.10 - the last phase will be implemented
                -- there will be only one implemented phase
                -- and scheduled phase is always followed by implemented
                -- All scheduled revised items will be picked for implementation on auto-implement

                SELECT els1.status_code
                INTO l_status_code
                FROM eng_lifecycle_statuses els1
                WHERE els1.entity_id1 = l_change_id
                AND els1.entity_name = 'ENG_CHANGE'
                AND els1.active_flag = 'Y' -- added for bug 3553682
                AND els1.sequence_number = (SELECT max(els2.sequence_number)
                                        FROM eng_lifecycle_statuses els2
                                        WHERE els2.entity_id1 = l_change_id
                                        AND els2.entity_name = 'ENG_CHANGE'
                                        AND els2.active_flag = 'Y');  -- added for bug 3553682

        END IF;

        FOR ri IN c_revised_items_all
        LOOP
               --   Check if change policy allows change order / revised item to be implemented
               Can_Implement_Item( p_change_line_id => ri.revised_item_sequence_id,
                                   x_implementation_status => l_implementation_status);

               IF l_implementation_status = 'NO' THEN
                    Raise abort_implementation;
               END IF;


                IF (ri.transfer_or_copy IS NULL)
                THEN
                        l_is_revised_item_change := 1;
                ELSE
                        l_is_revised_item_change := 2;
                END IF;

                --
                -- For PLM
                -- Check if the revised item is the parent
                -- then it has lifecycle phase change associalted with it
                --
                IF (ri.parent_revised_item_seq_id IS NULL
                        AND ri.transfer_or_copy IS NOT NULL
                        AND ri.enable_item_in_local_org IS NOT NULL)
                THEN
                        l_is_revised_item_change := 1;
                END IF;

                select approval_status_type into l_approval_status
                from   eng_engineering_changes
                where  change_id = l_change_id;

                -- First trying to implement the revised item attachment changes
                -- Changes For bug 3402607
                BEGIN
                l_return_status := FND_API.G_RET_STS_SUCCESS;
                /*ENG_ATTACHMENT_IMPLEMENTATION.Implement_Attachment_Change(
                        p_api_version   => 1.0
                        ,p_change_id    => l_change_id
                        ,p_rev_item_seq_id      =>revised_item
                        ,x_return_status        => l_return_status
                        ,x_msg_count            => l_msg_count
                        ,x_msg_data             => l_msg_data
                        ,P_APPROVAL_STATUS      => l_approval_status);*/
                    l_plsql_block := 'begin ENG_ATTACHMENT_IMPLEMENTATION.Implement_Attachment_Change('
                                    || '   p_api_version     => 1.0  '
                                    || ' , p_change_id       => :1   '
                                    || ' , p_rev_item_seq_id => :2   '
                                    || ' , x_return_status   => :3   '
                                    || ' , x_msg_count       => :4   '
                                    || ' , x_msg_data        => :5   '
                                    || ' , p_approval_status => :6); '
                                    || ' end;';
                    EXECUTE IMMEDIATE l_plsql_block USING IN l_change_id, IN revised_item, OUT l_return_status
                                                        , OUT l_msg_count, OUT l_msg_data, IN  l_approval_status;

                IF l_return_status = 'E' THEN
                  l_message_name := 'ENG_ATTACHMENT_IMP_ERROR';
                  l_message_desc := 'Attachment Changes implementation failed';
                  FND_FILE.PUT_LINE(FND_FILE.LOG, l_msg_data);
                END IF;

                EXCEPTION
                WHEN OTHERS THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Attachment Changes Implementation Failed'||SQLERRM);
                    l_message_name := 'ENG_ATTACHMENT_IMP_ERROR';
                    l_message_desc := 'Attachment Changes implementation failed';
                    goto error_block;
                END;

                -- Also implement item related document here. Both attachment changes and item related document
                -- changes do not have any date effectivity, that is why it is added here..only when attachment impl is successfull
                BEGIN
		IF (NVL(l_return_status, FND_API.G_RET_STS_ERROR) = FND_API.G_RET_STS_SUCCESS)
                  THEN
			  l_return_status := FND_API.G_RET_STS_SUCCESS;

			  l_plsql_block := 'begin ENG_RELATED_ENTITY_PKG.Implement_Relationship_Changes('
					    || '   p_api_version     => 1.0  '
					    || ' , p_change_id       => :1   '
					    || ' , p_entity_id       => :2   '
					    || ' , x_return_status   => :3   '
					    || ' , x_msg_count       => :4   '
					    || ' , x_msg_data        => :5); '
					    || ' end;';
			    EXECUTE IMMEDIATE l_plsql_block
			     USING IN l_change_id, IN revised_item,
			       OUT l_return_status, OUT l_msg_count, OUT l_msg_data;

			IF l_return_status = 'E' THEN
			  l_message_name := 'ENG_RELATED_ENTITY_IMP_ERROR';
			  l_message_desc := 'Related Entity Changes implementation failed';
			  FND_FILE.PUT_LINE(FND_FILE.LOG, l_msg_data);
			END IF;
                END IF;
                EXCEPTION
		-- Don't throw an exception when package not found.
		WHEN PLSQL_COMPILE_ERROR THEN
		    null;
		WHEN OTHERS THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Related Entity Changes Implementation Failed'||SQLERRM);
                    l_message_name := 'ENG_RELATED_ENTITY_IMP_ERROR';
                    l_message_desc := 'Related Entity Changes implementation failed';
                    goto error_block;
                END;

                << error_block >>
                  null;

                BEGIN
                  IF (NVL(l_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS)
                  THEN
                        msg_qty := msg_qty + 1;
                        token1(msg_qty) := null;
                        value1(msg_qty) := null;
                        translate1(msg_qty) := 0;
                        token2(msg_qty) := null;
                        value2(msg_qty) := null;
                        translate2(msg_qty) := 0;
                        message_names(msg_qty) := l_message_name;
                        FOR I IN 1..l_msg_count
                        LOOP
                                FND_FILE.NEW_LINE(FND_FILE.LOG);
                                FND_FILE.PUT_LINE(FND_FILE.LOG, l_message_desc);
                                FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MSG_PUB.get(I, 'F'));

                        END LOOP;
                  ELSE

                        implement_revised_item(
                         revised_item           => ri.revised_item_sequence_id
                        , trial_mode            => trial_mode
                        , max_messages          => max_messages
                        , userid                => userid
                        , reqstid               => reqstid
                        , appid                 => appid
                        , progid                => progid
                        , loginid               => loginid
                        , bill_sequence_id      => bill_sequence_id
                        , routing_sequence_id   => routing_sequence_id
                        , eco_for_production    => eco_for_production
                        , revision_high_date    => revision_high_date
                        , rtg_revision_high_date => rtg_revision_high_date
                        , update_wip            => update_wip
                        , group_id1             => group_id1
                        , group_id2             => group_id2
                        , wip_job_name1         => wip_job_name1
                        , wip_job_name2         => wip_job_name2
                        , wip_job_name2_org_id  => wip_job_name2_org_id
                        , message_names         => message_names
                        , token1                => token1
                        , value1                => value1
                        , translate1            => translate1
                        , token2                => token2
                        , value2                => value2
                        , translate2            => translate2
                        , msg_qty               => msg_qty
                        , warnings              => warnings
                        , p_is_lifecycle_phase_change => l_is_revised_item_change
                        , p_now                 => l_now
                        , p_status_code         => l_status_code) ;

                END IF;
                IF (msg_qty > warnings)
                THEN
                        exit;
                END IF;
             END;
        END LOOP;

END implement_revised_item;

--Bug No: 4767315 starts procedure to implement ecos wo any unimplemented revised items
--(deviating from basebug by putting procedure in pls file for easier maintenance. )
Procedure implement_eco_wo_revised_item(
		p_change_notice in varchar2,
		temp_organization_id in varchar2)
is
l_implement_header varchar2(1);

-- cursor for finding the ecos which can be implemented as all revised items are implemented
-- or to return values corresponding to the eco that is being manually implemented.

CURSOR C_IMPL_CUR IS
	select change_notice,change_id,organization_id,
	       nvl(plm_or_erp_change, 'PLM') l_plm_or_erp_change,
	       status_code curr_status_code
	    from eng_engineering_changes e
	    where to_char(e.organization_id) = temp_organization_id
	    AND ((p_change_notice IS NULL  and e.STATUS_TYPE = 4 )  -- scheduled
                OR (p_change_notice IS NOT NULL AND E.CHANGE_NOTICE = p_change_notice))
	    AND   e.APPROVAL_STATUS_TYPE <> 4 --eco rejected
	    and e.status_type not in (5,6)
	    and not exists (select 1 from eng_revised_items r
                   where r.change_notice = e.change_notice
                   and r.organization_id = e.organization_id
                   and r.status_type not in (5,6))
	    and exists (select 1 from eng_revised_items r1
                   where r1.change_notice = e.change_notice
                   and r1.organization_id = e.organization_id
                   and r1.status_type = 6);

IMPL C_IMPL_CUR%rowtype;

BEGIN
savepoint implement_eco_wo_revised_item;
-- Check if implementation of header is allowed or not for the current phase
OPEN C_IMPL_CUR;
loop
FETCH C_IMPL_CUR INTO IMPL;
EXIT WHEN C_IMPL_CUR%NOTFOUND;
l_implement_header:='T';
l_implement_header := check_header_impl_allowed(
		p_change_id => IMPL.change_id,
		p_change_notice => IMPL.change_notice,
		p_status_code => 6,
		p_curr_status_code => IMPL.curr_status_code,
		p_plm_or_erp_change => IMPL.l_plm_or_erp_change,
		p_request_id => fnd_global.conc_request_id);

-- If Header can be implemented, then go ahead.

IF (l_implement_header = 'T')
THEN
 -- update eco to status implemented
UPDATE
    ENG_ENGINEERING_CHANGES
    SET STATUS_TYPE = 6,
    STATUS_CODE=6,
    IMPLEMENTATION_DATE = SYSDATE,
    LAST_UPDATE_DATE = SYSDATE,
    LAST_UPDATED_BY = fnd_global.user_id,
    LAST_UPDATE_LOGIN = fnd_global.login_id,
    REQUEST_ID = fnd_global.conc_request_id,
    PROGRAM_APPLICATION_ID = fnd_global.prog_appl_id,
    PROGRAM_ID = fnd_global.conc_program_id,
    PROGRAM_UPDATE_DATE = SYSDATE,
    promote_status_code = null
WHERE CHANGE_NOTICE = IMPL.change_notice
    AND ORGANIZATION_ID = IMPL.organization_id;

-- Complete the last phase in the lifecycle

UPDATE
    eng_lifecycle_statuses
    SET start_date = nvl(start_date,sysdate), -- set the start date on implemented phase after promoting the header to implemented phase
    completion_date = sysdate,
    last_update_date = sysdate,
    last_updated_by = fnd_global.user_id,
    last_update_login = fnd_global.login_id
WHERE entity_name = 'ENG_CHANGE'
    AND entity_id1 =
    (
    SELECT
        change_id
    FROM eng_engineering_changes
    WHERE organization_id = IMPL.organization_id
        AND change_notice = IMPL.change_notice
    )
    AND active_flag = 'Y'
    AND sequence_number =
    (
    SELECT
        max(sequence_number)
    FROM eng_lifecycle_statuses
    WHERE entity_name = 'ENG_CHANGE'
        AND entity_id1 =
        (
        SELECT
            change_id
        FROM eng_engineering_changes
        WHERE organization_id = IMPL.organization_id
            AND change_notice = IMPL.change_notice
        ) );

END IF;
end loop;
close C_IMPL_CUR;
EXCEPTION
WHEN OTHERS THEN
    IF C_IMPL_CUR%ISOPEN THEN
      CLOSE C_IMPL_CUR;
    END IF;
rollback to savepoint implement_eco_wo_revised_item;
END implement_eco_wo_revised_item;

--Bug No: 4767315 fix ends
end ENGPKIMP;

/
