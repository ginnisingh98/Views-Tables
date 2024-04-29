--------------------------------------------------------
--  DDL for Package Body ENG_NEW_ITEM_REQ_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_NEW_ITEM_REQ_UTIL" AS
/* $Header: ENGUNIRB.pls 120.14.12010000.9 2013/07/03 07:49:12 evwang ship $ */


G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ENG_NEW_ITEM_REQ_UTIL';
G_NIR_ICC_OPTION              CONSTANT VARCHAR2(30) := 'C';
G_NIR_IND_ITEM_OPTION              CONSTANT VARCHAR2(30) := 'I';


PROCEDURE Create_New_Item_Request
(
  x_return_status     OUT NOCOPY VARCHAR2,
  change_number       IN VARCHAR2, --10
  change_name         IN VARCHAR2, --240
  change_type_code    IN VARCHAR2, --80
  item_number         IN VARCHAR2, --240
  organization_code   IN VARCHAR2, --3
  requestor_user_name IN VARCHAR2, --100
  batch_id            IN NUMBER := null
)
IS

    l_change_id                   NUMBER ;

BEGIN

    Create_New_Item_Request
    ( x_return_status     => x_return_status
    , x_change_id         => l_change_id
    , change_number       => change_number
    , change_name         => change_name
    , change_type_code    => change_type_code
    , item_number         => item_number
    , organization_code   => organization_code
    , requestor_user_name => requestor_user_name
    , batch_id            => batch_id
    ) ;

END Create_New_Item_Request ;


-- Added in R12
-- Item API will put returned NIR change id
-- to Item Open Interface table
PROCEDURE Create_New_Item_Request
(
    x_return_status     OUT NOCOPY VARCHAR2,
    x_change_id         OUT NOCOPY NUMBER,
    change_number       IN VARCHAR2, --10
    change_name         IN VARCHAR2, --240
    change_type_code    IN VARCHAR2, --80
    item_number         IN VARCHAR2 ,--240
    organization_code   IN VARCHAR2, --3
    requestor_user_name IN VARCHAR2, --100
    batch_id            IN NUMBER default null
)
IS
    l_return_status varchar2(1);
    l_msg_count number := 0;
    l_eco_rec                       ENG_ECO_Pub.Eco_Rec_Type;
    l_out_eco_rec                   ENG_Eco_PUB.Eco_Rec_Type := ENG_ECO_Pub.G_MISS_ECO_REC;
    l_out_eco_rev_tbl               ENG_Eco_PUB.Eco_Revision_Tbl_Type := ENG_ECO_Pub.G_MISS_ECO_REVISION_TBL;
    l_out_rev_item_tbl              ENG_Eco_PUB.Revised_Item_Tbl_Type := ENG_ECO_Pub.G_MISS_REVISED_ITEM_TBL;
    l_out_rev_comp_tbl              BOM_BO_PUB.Rev_Component_Tbl_Type := ENG_ECO_Pub.G_MISS_REV_COMPONENT_TBL;
    l_out_ref_des_tbl               BOM_BO_PUB.Ref_Designator_Tbl_Type := ENG_ECO_Pub.G_MISS_REF_DESIGNATOR_TBL;
    l_out_sub_comp_tbl              BOM_BO_PUB.Sub_Component_Tbl_Type := ENG_ECO_Pub.G_MISS_SUB_COMPONENT_TBL;
    l_out_rev_operation_tbl         Bom_Rtg_Pub.Rev_Operation_Tbl_Type := ENG_ECO_Pub.G_MISS_REV_OPERATION_TBL;
    l_out_rev_op_resource_tbl       Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type := ENG_ECO_Pub.G_MISS_REV_OP_RESOURCE_TBL;
    l_out_rev_sub_resource_tbl      Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type := ENG_ECO_Pub.G_MISS_REV_SUB_RESOURCE_TBL;
    l_message_text varchar2(2000);
    l_entity_index number;
    l_entity_id varchar2(10);
    l_message_type varchar2(30);
    change_mgmt_type_name varchar2(80);
    l_change_order_type_id number;
    stat_name varchar2(80);

    l_type_id                     NUMBER;
    l_auto_number_method          eng_change_order_types.AUTO_NUMBERING_METHOD%TYPE;
    l_change_number               eng_engineering_changes.CHANGE_NOTICE%TYPE := NULL;

    l_change_type_name            eng_change_order_types_tl.type_name%TYPE := NULL;
    l_hist_rec_row_id             VARCHAR2(100);
    l_change_mgmt_type_id eng_change_order_types_tl.change_order_type_id%TYPE;

    CURSOR c_change_type_detail(l_change_order_type_id IN NUMBER)
    IS
        SELECT ecotv1.change_order_type_id change_mgmt_type_id,
            ecotv2.change_order_type_id,
            ecotv2.auto_numbering_method,
            ecotv1.auto_numbering_method change_mgmt_method
        FROM eng_change_order_types_vl  ecotv1, eng_change_order_types_vl ecotv2
        WHERE ecotv1.change_order_type_id  = l_change_order_type_id
        AND ecotv1.TYPE_CLASSIFICATION= 'CATEGORY'
        AND ecotv1.change_mgmt_type_code = ecotv2.change_mgmt_type_code
        AND ecotv2.type_name = change_type_code
        AND ecotv2.TYPE_CLASSIFICATION = 'HEADER';



    CURSOR c_change_id (p_change_notice IN VARCHAR2, p_org_code IN VARCHAR2)
    IS
        SELECT CHANGE_ID
        FROM   mtl_parameters org_param
             , eng_engineering_changes eng_change
        WHERE eng_change.change_notice =  p_change_notice
        AND eng_change.organization_id = org_param.organization_id
        AND org_param.organization_code = p_org_code;

    CURSOR c_first_status (cp_change_mgmt_type_id IN eng_change_order_types_tl.change_order_type_id%TYPE)
    IS
               SELECT  a.status_name INTO stat_name
               FROM  eng_change_statuses_vl a,   eng_lifecycle_statuses b
               WHERE a.status_code = b.status_code
               AND b.entity_name='ENG_CHANGE_TYPE'
               AND b.entity_id1 = cp_change_mgmt_type_id
               ORDER BY b.sequence_number;

L_TRANSACTION_TYPE varchar2(80) :='CREATE';

-- bug 15831337: skip nir explosion flag
l_skip_nir_expl VARCHAR2(1);

BEGIN

    --  l_eco_rec.eco_name := change_number;
    l_eco_rec.eco_name := '';
    l_eco_rec.organization_code := organization_code;
    l_eco_rec.description := change_name;
    l_eco_rec.change_type_code := change_type_code;

    -- Bug : 5140579     Removed the hardcoding and getting following values from database. Priority need not be hardcoded.
--    select status_name into stat_name FROM ENG_CHANGE_STATUSES_VL where status_code=1;    --   1 = Open

     -- Bug : 5282713    We need to get the first status of this change type.
     --select change_order_type_id into l_change_mgmt_type_id from eng_change_order_types_tl where type_name = change_type_code and language = userenv('LANG');


     --Bug 8242706(base bug7587290): If NIR type and Change Order Type has got same name, Creation of NIR is failing.
 	                          -- validaton on NIR type included in the select query.

 	      SELECT ECOT.change_order_type_id
 	      INTO   l_change_mgmt_type_id
 	      FROM   eng_change_order_types_tl ECOT,
 	             ENG_CHANGE_ORDER_TYPES ECO
 	      WHERE  ECOT.CHANGE_ORDER_TYPE_ID=ECO.CHANGE_ORDER_TYPE_ID
 	         AND ECO.CHANGE_MGMT_TYPE_CODE= 'NEW_ITEM_REQUEST'
 	         AND ECOT.type_name           = change_type_code
 	         AND ECOT.language            = userenv('LANG');

       -- Get the first phase
     OPEN c_first_status(l_change_mgmt_type_id);
     LOOP
          FETCH c_first_status INTO stat_name;    --   Get only the first record;
          IF (c_first_status%NOTFOUND) THEN
               stat_name := NULL;
          ELSE
               EXIT;
          END IF;
     END LOOP;
     CLOSE c_first_status;

     IF stat_name IS NULL THEN
          select status_name into stat_name FROM ENG_CHANGE_STATUSES_VL where status_code=1;    --   1 = Open
     END IF;


    select change_order_type, change_order_type_id
      into change_mgmt_type_name, l_change_order_type_id
      FROM ENG_CHANGE_ORDER_TYPES_VL
     WHERE change_mgmt_type_code='NEW_ITEM_REQUEST'
       AND type_classification='CATEGORY';

    l_eco_rec.change_management_type := change_mgmt_type_name;
    l_eco_rec.status_name := stat_name;
    l_eco_rec.priority_code := NULL;

    l_eco_rec.reason_code := NULL;
    l_eco_rec.approval_list_name := NULL;
    l_eco_rec.eco_department_name := NULL;
    l_eco_rec.cancellation_comments := NULL;
    l_eco_rec.eng_implementation_cost := NULL;
    l_eco_rec.mfg_implementation_cost := NULL;
    l_eco_rec.requestor := requestor_user_name;
    /*Commented for bug 13721297,the default value for assignee will be handle in Eng_Default_ECO.Attribute_Defaulting*/
    --l_eco_rec.assignee := requestor_user_name;
    l_eco_rec.organization_hierarchy := NULL;
    l_eco_rec.return_status := NULL;
   -- l_eco_rec.pk1_name := item_number;
   -- l_eco_rec.pk2_name := organization_code;
    l_eco_rec.plm_or_erp_change := 'PLM';
    l_eco_rec.transaction_type := L_TRANSACTION_TYPE;

    FOR CTD IN c_change_type_detail(l_change_order_type_id)
    LOOP
        IF (CTD.auto_numbering_method = 'INH_PAR')
        THEN
                l_type_id := CTD.change_mgmt_type_id;
                l_auto_number_method := CTD.change_mgmt_method;
        ELSE
                l_type_id := CTD.change_order_type_id;
                l_auto_number_method := CTD.auto_numbering_method;
        END IF;

        IF (l_auto_number_method = 'USR_ENT')
        THEN
                l_change_number := null;
        ELSIF (l_auto_number_method = 'SEQ_GEN')
        THEN

                select alpha_prefix||next_available_number
                INTO l_change_number
                from eng_auto_number_ecn
                where change_type_id = l_type_id;
-- Bug 5283630  Not necessary to update here. It is anyway done in Eng_Eco_Pub.Autogen_Change_Number() called from Process_Eco()
--                update eng_auto_number_ecn
--                set next_available_number = next_available_number+1
--                where change_type_id = l_type_id;
        END IF;
    END LOOP;

   -- bug 15831337: skip nir explosion flag
		if (ENG_Eco_PVT.G_Skip_NIR_Expl = chr(0)) then
	        ENG_Eco_PVT.G_Skip_NIR_Expl := FND_API.G_TRUE;
		end if;
		l_skip_nir_expl :=ENG_Eco_PVT.G_Skip_NIR_Expl;


    if l_change_number is not null
    then

        Eng_Eco_Pub.Process_Eco (
            p_init_msg_list         => TRUE,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            p_ECO_rec               => l_eco_rec,
            p_eco_revision_tbl      => l_out_eco_rev_tbl,
            p_revised_item_tbl      => l_out_rev_item_tbl,
            p_rev_component_tbl     => l_out_rev_comp_tbl,
            p_ref_designator_tbl    => l_out_ref_des_tbl,
            p_sub_component_tbl     => l_out_sub_comp_tbl,
            p_rev_operation_tbl     => l_out_rev_operation_tbl,
            p_rev_op_resource_tbl   => l_out_rev_op_resource_tbl,
            p_rev_sub_resource_tbl  => l_out_rev_sub_resource_tbl,
            x_ECO_rec               => l_out_eco_rec,
            x_eco_revision_tbl      => l_out_eco_rev_tbl,
            x_revised_item_tbl      => l_out_rev_item_tbl,
            x_rev_component_tbl     => l_out_rev_comp_tbl,
            x_ref_designator_tbl    => l_out_ref_des_tbl,
            x_sub_component_tbl     => l_out_sub_comp_tbl,
            x_rev_operation_tbl     => l_out_rev_operation_tbl,
            x_rev_op_resource_tbl   => l_out_rev_op_resource_tbl,
            x_rev_sub_resource_tbl  => l_out_rev_sub_resource_tbl,
            -- bug 15831337: skip nir explosion flag
            p_skip_nir_expl         => l_skip_nir_expl
        );

        IF batch_id IS NOT NULL AND l_return_status = FND_API.G_RET_STS_SUCCESS
        THEN

            l_change_number := l_out_eco_rec.Eco_Name ;

            FOR l_rec IN c_change_id( l_change_number, organization_code)
            LOOP
               x_change_id := l_rec.CHANGE_ID ;
            END LOOP ;


            IF x_change_id IS NOT NULL
            THEN
                ENG_CHANGE_IMPORT_UTIL.INSERT_IMPORT_CHANGE_ROW (
                X_ROWID => l_hist_rec_row_id,
                X_BATCH_ID => batch_id,
                X_CHANGE_ID => x_change_id,
                X_CREATION_DATE => SYSDATE,
                X_CREATED_BY => FND_GLOBAL.user_id,
                X_LAST_UPDATE_DATE => SYSDATE,
                X_LAST_UPDATED_BY => FND_GLOBAL.user_id,
                X_LAST_UPDATE_LOGIN => FND_GLOBAL.login_id
                )  ;
            END IF ;

        END IF ;

   else
       l_return_status := 'G';
   end if;

   x_return_status := l_return_status;


END Create_New_Item_Request ;

PROCEDURE CREATE_NEW_ITEM_REQUESTS(P_BATCH_ID           IN         NUMBER,
                                   P_NIR_OPTION         IN         VARCHAR2,
                                    x_return_status     OUT NOCOPY VARCHAR2,
                                    x_msg_data          OUT NOCOPY VARCHAR2,
                                    x_msg_count         OUT NOCOPY NUMBER)
IS

TYPE ICC_TABLE IS TABLE of VARCHAR2(80);
TYPE CHANGE_TYPE_TABLE IS TABLE OF VARCHAR2(80);
TYPE ORGANIZATION_TABLE IS TABLE OF NUMBER;
TYPE NIR_COUNT is TABLE OF NUMBER;
TYPE NIR_CHANGE_TABLE IS TABLE OF NUMBER;
TYPE ITEMS_TABLE IS TABLE OF NUMBER;
TYPE SUB_DESC IS RECORD(SUBJECT_LEVEL NUMBER,
			ENTITY_NAME VARCHAR2(80),
			PARENT_ENTITY_NAME VARCHAR2(80)
			);
TYPE SUB_DESC_TABLE IS TABLE OF SUB_DESC;
TYPE TRANSACTION_TABLE IS TABLE OF VARCHAR2(80);

l_icc_array ICC_TABLE;
l_change_type_array CHANGE_TYPE_TABLE;
l_nir_count NIR_COUNT;
l_org_array ORGANIZATION_TABLE;
l_change_ids_array NIR_CHANGE_TABLE;
l_change_ids_array_all NIR_CHANGE_TABLE; -- bug 14376801
l_item_ids_array ITEMS_TABLE;
l_sub_desc_array SUB_DESC_TABLE;
l_transaction_array TRANSACTION_TABLE;
l_nir_created NUMBER;
l_change_type_code_num NUMBER;
l_change_type_code VARCHAR2(80);

l_change_id NUMBER;
l_req_name VARCHAR2(30);
l_subject_level NUMBER;
l_process_flag NUMBER :=5;
L_TRANSACTION_TYPE varchar2(80) :='CREATE';
l_dynamic_sql    varchar2(2000);
dumm_status     number;
l_error_text    VARCHAR2(80);
l_return_status VARCHAR2(1);
l_err_text      VARCHAR2(240) :=null;
l_org_id         NUMBER;
l_prev_org_id    NUMBER;
l_org_code       VARCHAR2(80);
--count number;
temp_change_line_id number;
l_nir_line_sequence ENG_CHANGE_LINES.SEQUENCE_NUMBER%TYPE;

     CURSOR cur_change_lines IS
          select
               change_line_id,
               change_id,
               FND_GLOBAL.USER_ID created_by,
               sysdate creation_date,
               FND_GLOBAL.USER_ID last_updated_by,
               sysdate last_update_date,
               FND_GLOBAL.USER_ID last_update_login,
               (select change_order_type_id from eng_change_order_types where TYPE_CLASSIFICATION='LINE'
                AND CHANGE_MGMT_TYPE_CODE = 'NEW_ITEM_REQUEST' AND ROWNUM=1) change_type_id,
               1 status_code,
               1 APPROVAL_STATUS_TYPE
          from mtl_system_items_interface msii
          where msii.set_process_id = p_batch_id
          and msii.process_flag = l_process_flag
--        and msii.transaction_type=L_TRANSACTION_TYPE
          ;

 BEGIN
x_return_status := 'S';

SAVEPOINT CREATE_NEW_ITEM_REQUESTS;
/*
SELECT DISTINCT MSII.ITEM_CATALOG_GROUP_ID,
       eng_types.type_name,
       msii.organization_id
 bulk collect  INTO l_icc_array ,
       l_change_type_array,
       l_org_array
  FROM MTL_SYSTEM_ITEMS_INTERFACE msii,
       MTL_ITEM_CATALOG_GROUPS_VL micg,
       ENG_CHANGE_ORDER_TYPES_VL eng_types,
       MTL_PARAMETERS mp
 WHERE msii.set_process_id=P_BATCH_ID
   AND PROCESS_FLAG = l_process_flag
   AND msii.ITEM_CATALOG_GROUP_ID = micg.ITEM_CATALOG_GROUP_ID
--   AND micg.NEW_ITEM_REQ_CHANGE_TYPE_ID = eng_types.change_order_type_id
   AND
        (SELECT
       TO_NUMBER(SUBSTR(NEW_ITEM_REQ_CHANGE_TYPE_ID, INSTR(NEW_ITEM_REQ_CHANGE_TYPE_ID, '$$', 2)+2)) AS NEW_ITEM_REQ_CHANGE_TYPE_ID
       FROM
       (
         SELECT
           MIN( CASE WHEN micgb.NEW_ITEM_REQUEST_REQD = 'Y' AND ( PRIOR micgb.NEW_ITEM_REQUEST_REQD IS NULL OR PRIOR micgb.NEW_ITEM_REQUEST_REQD = 'I' )
                     THEN '$$'||LPad(LEVEL, 6, '0')||'$$'|| micgb.NEW_ITEM_REQ_CHANGE_TYPE_ID
                     ELSE NULL
                END
              ) NEW_ITEM_REQ_CHANGE_TYPE_ID

         FROM MTL_ITEM_CATALOG_GROUPS_B  micgb
         CONNECT BY PRIOR micgb.PARENT_CATALOG_GROUP_ID = micgb.ITEM_CATALOG_GROUP_ID
         START WITH micgb.ITEM_CATALOG_GROUP_ID = ITEM_CATALOG_GROUP_ID
         )) = eng_types.change_order_type_id
   AND mp.organization_id = msii.organization_id
--   AND msii.TRANSACTION_TYPE = L_TRANSACTION_TYPE
   order by organization_id;
*/
--Bug 6162913
--   The above query was not working correctly because the ITEM_CATALOG_GROUP_ID taken is not from the MSII table.
--   Modified the following query for using the ego_item_cat_denorm_hier table
/*
SELECT DISTINCT MSII.ITEM_CATALOG_GROUP_ID ,-- msii.segment1,
       eng_types.type_name,
       msii.organization_id
BULK COLLECT INTO l_icc_array ,
       l_change_type_array,
       l_org_array
FROM MTL_SYSTEM_ITEMS_INTERFACE msii,
       ENG_CHANGE_ORDER_TYPES_VL eng_types,
       MTL_PARAMETERS mp,
       ego_item_cat_denorm_hier heir,
       mtl_item_catalog_groups_b micgb
 WHERE msii.set_process_id = P_BATCH_ID
   AND PROCESS_FLAG = l_process_flag
   AND mp.organization_id = msii.organization_id
   AND msii.item_catalog_group_id = heir.CHILD_CATALOG_GROUP_ID and
       eng_types.change_order_type_id = micgb.NEW_ITEM_REQ_CHANGE_TYPE_ID and
       micgb.item_catalog_group_id = heir.PARENT_CATALOG_GROUP_ID
ORDER BY organization_id;
*/

SELECT DISTINCT MSII.ITEM_CATALOG_GROUP_ID,
       (
         SELECT
           MIN( CASE WHEN micgb.NEW_ITEM_REQUEST_REQD = 'Y' AND ( PRIOR micgb.NEW_ITEM_REQUEST_REQD IS NULL OR PRIOR micgb.NEW_ITEM_REQUEST_REQD = 'I' )
                     THEN '$$'||LPad(LEVEL, 6, '0')||'$$'|| micgb.NEW_ITEM_REQ_CHANGE_TYPE_ID
                     ELSE NULL
                END
              ) NEW_ITEM_REQ_CHANGE_TYPE_ID

         FROM MTL_ITEM_CATALOG_GROUPS_B  micgb
         CONNECT BY PRIOR micgb.PARENT_CATALOG_GROUP_ID = micgb.ITEM_CATALOG_GROUP_ID
         START WITH micgb.ITEM_CATALOG_GROUP_ID = msii.ITEM_CATALOG_GROUP_ID
         ) AS type_name,
       msii.organization_id
 bulk collect  INTO l_icc_array ,
       l_change_type_array,
       l_org_array
  FROM MTL_SYSTEM_ITEMS_INTERFACE msii,
     --  ENG_CHANGE_ORDER_TYPES eng_types,
       MTL_PARAMETERS mp
 WHERE msii.set_process_id=P_BATCH_ID
   AND PROCESS_FLAG = l_process_flag
   AND mp.organization_id = msii.organization_id
   order by organization_id;




  -- Bug 10412328, change the l_req_name initialization part from party_name to user_name
  --select party_name into l_req_name from ego_user_v where user_name = FND_GLOBAL.USER_NAME;
  l_req_name := FND_GLOBAL.USER_NAME;

   if P_NIR_OPTION = G_NIR_ICC_OPTION
   then
     l_change_ids_array := NIR_CHANGE_TABLE();
     for i in l_icc_array.FIRST .. l_icc_array.LAST
     LOOP
     l_org_id := l_org_array(i);
     if l_prev_org_id IS NULL OR l_org_id <> l_prev_org_id
     then
          select organization_code
            into l_org_code
            from mtl_parameters mp
           where mp.organization_id = l_org_id;
     l_prev_org_id :=  l_org_id;
     end if;

    l_change_type_code_num := TO_NUMBER(SUBSTR(l_change_type_array(i), INSTR(l_change_type_array(i), '$$', 2)+2));
    SELECT  eng_types.type_name into l_change_type_code FROM ENG_CHANGE_ORDER_TYPES_VL eng_types WHERE eng_types.change_order_type_id =  l_change_type_code_num;

      Create_New_Item_Request( x_return_status => l_return_status,
                               x_change_id     => l_change_id,
                               change_number   => l_icc_array(i),
                               change_name     => l_icc_array(i),
                               change_type_code=> l_change_type_code,
                               item_number     => null,
                               ORGANIZATION_CODE=>l_org_code,
                               requestor_user_name => l_req_name,
                               batch_id            => p_batch_id) ;

      if l_return_status = 'G'
      then
               update mtl_system_items_interface msii
                  set process_flag= 3
                where  msii.set_process_id = P_BATCH_ID
                  AND PROCESS_FLAG = l_process_flag
                  AND msii.ITEM_CATALOG_GROUP_ID =  l_icc_array(i)
--                  AND msii.TRANSACTION_TYPE = L_TRANSACTION_TYPE
                    ;

               select transaction_id
    bulk collect into l_transaction_array
                 from mtl_system_items_interface msii
                where msii.set_process_id = P_BATCH_ID
                  AND PROCESS_FLAG = 3
                  AND msii.ITEM_CATALOG_GROUP_ID =  l_icc_array(i)
--                  AND msii.TRANSACTION_TYPE = L_TRANSACTION_TYPE
                  ;
                  for trans_i in l_transaction_array.FIRST .. l_transaction_array.LAST
                  LOOP
                    dumm_status  := INVPUOPI.mtl_log_interface_err(
                                  l_org_array(i), -- Row specific
                               FND_GLOBAL.USER_ID,
                               FND_GLOBAL.LOGIN_ID,
                               FND_GLOBAL.PROG_APPL_ID,
                               FND_GLOBAL.CONC_PROGRAM_ID,
                               FND_GLOBAL.CONC_REQUEST_ID
                              ,l_transaction_array(i) -- Row specific
                              ,l_err_text -- This is a dummy variable, if u want to pass message text and not name, assign the text to it
                              ,'ITEM_NUMBER' -- Column Name on which error occured
                              ,'MTL_SYSTEM_ITEMS_INTERFACE'
                              ,'INV_IOI_NO_AUTO_NIR' -- Message Name, If u want to specify the text directly, pass this as 'INV_IOI_ERR'
                              ,l_error_text);
                  END LOOP;
        -- x_return_status := 'S';
      else
        --x_return_status := l_return_status;
        l_change_ids_array.extend;
        l_change_ids_array(l_change_ids_array.last):=l_change_id;

      END IF;
     END LOOP;
      forall count IN l_change_ids_array.FIRST .. l_change_ids_array.LAST
        UPDATE MTL_SYSTEM_ITEMS_INTERFACE
               set change_id = l_change_ids_array(count)
             WHERE ITEM_CATALOG_GROUP_ID = l_icc_array(count)
            AND ORGANIZATION_ID = l_org_array(count)
            AND set_process_id = p_batch_id
            AND PROCESS_FLAG = l_process_flag
--	          AND TRANSACTION_TYPE =L_TRANSACTION_TYPE
               ;
   ELSE

     l_change_ids_array_all := NIR_CHANGE_TABLE(); --bug 14376801
     for i in l_icc_array.FIRST .. l_icc_array.LAST
     LOOP
     l_org_id := l_org_array(i);

     if  l_prev_org_id is null OR l_org_id <> l_prev_org_id
     then
       select organization_code
         into l_org_code
         from mtl_parameters mp
        where mp.organization_id = l_org_id;
     l_prev_org_id :=  l_org_id;
     end if;
         l_change_ids_array := NIR_CHANGE_TABLE();
        select inventory_item_id ,transaction_id
         bulk collect   into l_item_ids_array,l_transaction_array
           FROM MTL_SYSTEM_ITEMS_INTERFACE
          where ITEM_CATALOG_GROUP_ID = l_icc_array(i)
            AND ORGANIZATION_ID = l_org_array(i)
            AND set_process_id = p_batch_id
            AND PROCESS_FLAG = l_process_flag
--            AND TRANSACTION_TYPE =L_TRANSACTION_TYPE
            ;
l_change_type_code_num := TO_NUMBER(SUBSTR(l_change_type_array(i), INSTR(l_change_type_array(i), '$$', 2)+2));
 SELECT  eng_types.type_name into l_change_type_code FROM ENG_CHANGE_ORDER_TYPES_VL eng_types WHERE eng_types.change_order_type_id =  l_change_type_code_num;
        for x in l_item_ids_array.FIRST .. l_item_ids_array.LAST
        loop



           Create_New_Item_Request( x_return_status => l_return_status,
                               x_change_id     => l_change_id,
                               change_number   => to_char(l_item_ids_array(x)),
                               change_name     => 'Change '|| to_char(l_item_ids_array(x)),
                               change_type_code=> l_change_type_code,
                               item_number     => null,
                               ORGANIZATION_CODE=>l_org_code,
                               requestor_user_name => l_req_name,
                               batch_id            => p_batch_id) ;

           if  l_return_status = 'G'
           then
              dumm_status  := INVPUOPI.mtl_log_interface_err(
                               l_org_array(i), -- Row specific
                               FND_GLOBAL.USER_ID,
                               FND_GLOBAL.LOGIN_ID,
                               FND_GLOBAL.PROG_APPL_ID,
                               FND_GLOBAL.CONC_PROGRAM_ID,
                               FND_GLOBAL.CONC_REQUEST_ID
                              ,l_transaction_array(i) -- Row specific
                              ,l_err_text -- This is a dummy variable, if u want to pass message text and not name, assign the text to it
                              ,'ITEM_NUMBER' -- Column Name on which error occured
                              ,'MTL_SYSTEM_ITEMS_INTERFACE'
                              ,'INV_IOI_NO_AUTO_NIR' -- Message Name, If u want to specify the text directly, pass this as 'INV_IOI_ERR'
                              ,l_error_text);

           else
            l_change_ids_array.extend;
            l_change_ids_array(l_change_ids_array.last):=l_change_id;

            l_change_ids_array_all.extend; --bug 14376801
            l_change_ids_array_all(l_change_ids_array_all.last):=l_change_id; --bug 14376801
           end if;
        END LOOP;

        forall count in l_change_ids_array.FIRST .. l_change_ids_array.LAST
            UPDATE MTL_SYSTEM_ITEMS_INTERFACE
               set change_id = l_change_ids_array(count)
             WHERE ITEM_CATALOG_GROUP_ID = l_icc_array(i)
            AND ORGANIZATION_ID = l_org_array(i)
            AND set_process_id = p_batch_id
            AND PROCESS_FLAG = l_process_flag
--            AND TRANSACTION_TYPE =L_TRANSACTION_TYPE
            AND INVENTORY_ITEM_ID = l_item_ids_array(count);
     END LOOP;

  END IF;

  update mtl_system_items_interface  msii
     set change_line_id = ENG_CHANGE_LINES_S.nextval
     where msii.set_process_id = p_batch_id
  and msii.process_flag= l_process_flag
--  and msii.transaction_type=L_TRANSACTION_TYPE
  and change_id is not null;

/*   --   Commented for bug 6189094 because sequence number is hardcoded, for multiple items in NIr sequence number should be differnent
insert into eng_change_lines
(  change_line_id              ,
  change_id                   ,
  created_by                  ,
  creation_date               ,
  last_updated_by             ,
  last_update_date            ,
  last_update_login           ,
  sequence_number             ,
  change_type_id              ,
  status_code                 ,
  APPROVAL_STATUS_TYPE
 )
(
select
msii.change_line_id,
msii.change_id,
FND_GLOBAL.USER_ID,
sysdate,
FND_GLOBAL.USER_ID,
sysdate,
FND_GLOBAL.USER_ID,
10,
(select change_order_type_id from eng_change_order_types where TYPE_CLASSIFICATION='LINE'
 AND CHANGE_MGMT_TYPE_CODE = 'NEW_ITEM_REQUEST' AND ROWNUM=1) TYPE_ID,
1 ,
1
from mtl_system_items_interface msii
where msii.set_process_id = p_batch_id
  and msii.process_flag = l_process_flag
--  and msii.transaction_type=L_TRANSACTION_TYPE
  );
*/
l_nir_line_sequence := 10;
     FOR cur_chg_line IN cur_change_lines
     LOOP
         INSERT INTO eng_change_lines
          ( change_line_id              ,
            change_id                   ,
            created_by                  ,
            creation_date               ,
            last_updated_by             ,
            last_update_date            ,
            last_update_login           ,
            sequence_number             ,
            change_type_id              ,
            status_code                 ,
            APPROVAL_STATUS_TYPE
           )
          VALUES
           (
               cur_chg_line.change_line_id,
               cur_chg_line.change_id,
               cur_chg_line.created_by,
               cur_chg_line.creation_date,
               cur_chg_line.last_updated_by,
               cur_chg_line.last_update_date,
               cur_chg_line.last_update_login,
               l_nir_line_sequence,
               cur_chg_line.change_type_id,
               cur_chg_line.status_code,
               cur_chg_line.APPROVAL_STATUS_TYPE
           );
           l_nir_line_sequence := l_nir_line_sequence + 10;
     END LOOP;

insert into eng_change_lines_tl
(  change_line_id              ,
  created_by                  ,
  creation_date               ,
  last_updated_by             ,
  last_update_date            ,
  last_update_login           ,
  language                    ,
  source_lang                 ,
  name
 )
(
select
msii.change_line_id,
FND_GLOBAL.USER_ID,
sysdate,
FND_GLOBAL.USER_ID,
sysdate,
FND_GLOBAL.USER_ID,
LANGS.LANGUAGE_CODE,
USERENV('LANG'),
msii.change_line_id
from mtl_system_items_interface msii,
     FND_LANGUAGES LANGS
where msii.set_process_id = p_batch_id
  and msii.process_flag = l_process_flag
--  and msii.transaction_type=L_TRANSACTION_TYPE
  AND LANGS.installed_flag IN ('B','I'));

SELECT subject_level, entity_name, parent_entity_name
BULK COLLECT INTO l_sub_desc_array
  FROM eng_subject_entities ese, eng_subjects_b esb
 WHERE ese.subject_id=esb.subject_id
   AND esb.subject_internal_name='EGO_NEW_ITEM'
   ORDER BY subject_level ;

for sub_count in l_sub_desc_array.FIRST .. l_sub_desc_array.LAST
LOOP
l_dynamic_sql := 'insert into ENG_CHANGE_SUBJECTS '||
		'(change_subject_id , change_id , change_line_id , entity_name,';
if l_sub_desc_array(sub_count).ENTITY_NAME = 'EGO_CATALOG_GROUP'
then
	l_dynamic_sql := l_dynamic_sql || 'pk1_value, ';
elsif l_sub_desc_array(sub_count).ENTITY_NAME = 'EGO_ITEM'
THEN
	l_dynamic_sql := l_dynamic_sql || 'pk1_value,pk2_value, ';
elsif l_sub_desc_array(sub_count).ENTITY_NAME = 'EGO_ITEM_REVISION'
then
	l_dynamic_sql := l_dynamic_sql || 'pk1_value,pk2_value, pk3_value, ';
end if;

l_dynamic_sql := l_dynamic_sql || ' subject_level, created_by, creation_date ,' ||
		' last_updated_by, last_update_date, last_update_login)'
		|| ' (SELECT ENG_CHANGE_SUBJECTS_S.nextval , '||
		' MSII.CHANGE_ID, MSII.CHANGE_LINE_ID, ''' || l_sub_desc_array(sub_count).entity_name ||''',';
if l_sub_desc_array(sub_count).ENTITY_NAME = 'EGO_CATALOG_GROUP'
then
l_dynamic_sql := l_dynamic_sql || 'MSII.ITEM_CATALOG_GROUP_ID ';
elsif l_sub_desc_array(sub_count).ENTITY_NAME = 'EGO_ITEM'
THEN
	l_dynamic_sql := l_dynamic_sql || 'MSII.INVENTORY_ITEM_ID,MSII.ORGANIZATION_ID ';
elsif l_sub_desc_array(sub_count).ENTITY_NAME = 'EGO_ITEM_REVISION'
then
	l_dynamic_sql := l_dynamic_sql || 'MSII.INVENTORY_ITEM_ID,MSII.ORGANIZATION_ID,MIRI.REVISION_ID ';
end if;
  l_dynamic_sql := l_dynamic_sql ||
				' , '  || l_sub_desc_array(sub_count).SUBJECT_LEVEL ||
				' , FND_GLOBAL.USER_ID, SYSDATE ' ||
                                ' , FND_GLOBAL.USER_ID, SYSDATE'||
				' , FND_GLOBAL.USER_ID FROM MTL_SYSTEM_ITEMS_INTERFACE MSII';

if l_sub_desc_array(sub_count).ENTITY_NAME = 'EGO_ITEM_REVISION'
then
	l_dynamic_sql := l_dynamic_sql ||' ,MTL_ITEM_REVISIONS_INTERFACE MIRI '||
					' WHERE MSII.INVENTORY_ITEM_ID = MIRI.INVENTORY_ITEM_ID ' ||
					' AND MSII.ORGANIZATION_ID = MIRI.ORGANIZATION_ID ' ||
				        ' AND MSII.SET_PROCESS_ID = MIRI.SET_PROCESS_ID ' ;
ELSE
	l_dynamic_sql := l_dynamic_sql || ' WHERE 1=1';
END IF;
	l_dynamic_sql := l_dynamic_sql || ' AND msii.set_process_id = :1 AND msii.PROCESS_FLAG = :2 '
--				      || ' AND msii.TRANSACTION_TYPE = :3 ' ||
                           || ')';
--EXECUTE IMMEDIATE l_dynamic_sql USING p_batch_id,l_process_flag,L_TRANSACTION_TYPE;

EXECUTE IMMEDIATE l_dynamic_sql USING p_batch_id,l_process_flag;

END LOOP;

--   Bug 6162913
--   Added the following because the items approval status is not getting updated in the NIR newly created from the excel import flow
--   The query in the ENG_NIR_UTIL_PKG.set_nir_item_approval_status() is returning no rows because change subjects are not yet created.
--   This is requuired because the lifecycle is created first and the subjects were getting created later
--   So we have to reset the Item approval status again after creating the NIR.

    --bug 14376801 begin
    if P_NIR_OPTION = G_NIR_ICC_OPTION
    then
      for l_nir_created IN l_change_ids_array.FIRST .. l_change_ids_array.LAST
      LOOP

               ENG_NIR_UTIL_PKG.set_nir_item_approval_status (l_change_ids_array(l_nir_created),
							  Eng_Workflow_Util.G_REQUESTED,
							  x_return_status => x_return_status,
							  x_msg_count => x_msg_count,
							  x_msg_data => x_msg_data);
     END LOOP;
    else  --bug 14376801 [for P_NIR_OPTION is I, use l_change_ids_array_all]
      for l_nir_created IN l_change_ids_array_all.FIRST .. l_change_ids_array_all.LAST
      LOOP
               ENG_NIR_UTIL_PKG.set_nir_item_approval_status (l_change_ids_array_all(l_nir_created),
                Eng_Workflow_Util.G_REQUESTED,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);
      END LOOP;
    end if;
    --bug 14376801 end

EXCEPTION
WHEN  OTHERS THEN

    x_return_status := 'U';
    x_msg_count := 1;
    x_msg_data := SQLERRM;
    rollback to CREATE_NEW_ITEM_REQUESTS;

END CREATE_NEW_ITEM_REQUESTS;

END ENG_NEW_ITEM_REQ_UTIL;

/
