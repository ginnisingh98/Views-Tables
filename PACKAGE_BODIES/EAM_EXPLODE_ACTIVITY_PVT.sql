--------------------------------------------------------
--  DDL for Package Body EAM_EXPLODE_ACTIVITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_EXPLODE_ACTIVITY_PVT" AS
/* $Header: EAMVEXAB.pls 120.4 2006/09/08 11:44:12 cboppana noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVEXAB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_EXPLODE_ACTIVITY_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/


PROCEDURE EXPLODE_ACTIVITY
( p_validation_level        IN  NUMBER
, p_eam_wo_rec              IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
, p_eam_op_tbl              IN  EAM_PROCESS_WO_PUB.eam_op_tbl_type
, p_eam_op_network_tbl      IN  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
, p_eam_res_tbl             IN  EAM_PROCESS_WO_PUB.eam_res_tbl_type
, p_eam_res_inst_tbl        IN  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
, p_eam_sub_res_tbl         IN  EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
, p_eam_res_usage_tbl       IN  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
, p_eam_mat_req_tbl         IN  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
, x_eam_wo_rec              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
, x_eam_op_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type
, x_eam_op_network_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
, x_eam_res_tbl             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
, x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
, x_eam_sub_res_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
, x_eam_res_usage_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
, x_eam_mat_req_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
, x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
, x_return_status           OUT NOCOPY VARCHAR2
)
IS
--Bug#3342391 : Added a local variable
l_common_routing_seq_id NUMBER ;
l_routing_available CHAR := 'N';
l_wip_entity_id NUMBER;
l_organization_id NUMBER;

l_eam_wo_rec             EAM_PROCESS_WO_PUB.eam_wo_rec_type := p_eam_wo_rec;
l_eam_op_tbl             EAM_PROCESS_WO_PUB.eam_op_tbl_type := p_eam_op_tbl;
l_eam_op_network_tbl     EAM_PROCESS_WO_PUB.eam_op_network_tbl_type := p_eam_op_network_tbl;
l_eam_res_tbl            EAM_PROCESS_WO_PUB.eam_res_tbl_type := p_eam_res_tbl;
l_eam_res_inst_tbl       EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type := p_eam_res_inst_tbl;
l_eam_sub_res_tbl        EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type := p_eam_sub_res_tbl;
l_eam_res_usage_tbl      EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type := p_eam_res_usage_tbl;
l_eam_mat_req_tbl        EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type := p_eam_mat_req_tbl;
l_eam_di_tbl             EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

l_out_eam_wo_rec             EAM_PROCESS_WO_PUB.eam_wo_rec_type := p_eam_wo_rec;
l_out_eam_op_tbl             EAM_PROCESS_WO_PUB.eam_op_tbl_type := p_eam_op_tbl;
l_out_eam_op_network_tbl     EAM_PROCESS_WO_PUB.eam_op_network_tbl_type := p_eam_op_network_tbl;
l_out_eam_res_tbl            EAM_PROCESS_WO_PUB.eam_res_tbl_type := p_eam_res_tbl;
l_out_eam_res_inst_tbl       EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type := p_eam_res_inst_tbl;
l_out_eam_sub_res_tbl        EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type := p_eam_sub_res_tbl;
l_out_eam_res_usage_tbl      EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type := p_eam_res_usage_tbl;
l_out_eam_mat_req_tbl        EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type := p_eam_mat_req_tbl;
l_out_eam_di_tbl             EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

/* Error Handling Variables */
l_token_tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
l_mesg_token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
l_out_mesg_token_tbl    EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
l_other_token_tbl       EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);
l_error_code            NUMBER;

/* Others */
l_return_status         VARCHAR2(1) ;
l_bo_return_status      VARCHAR2(1) ;
l_process_children      BOOLEAN := TRUE ;
l_valid_transaction     BOOLEAN := TRUE ;
l_bill_sequence_id      NUMBER;

-- Fix for Bug 3686343
p_rout_rev_datetime         DATE := NVL(p_eam_wo_rec.routing_revision_date,p_eam_wo_rec.scheduled_start_date);
p_bom_rev_datetime          DATE := NVL(p_eam_wo_rec.bom_revision_date,p_eam_wo_rec.scheduled_start_date);
-- Fix for Bug 3686343

j                       NUMBER := l_eam_op_tbl.COUNT;
k                       NUMBER := l_eam_res_tbl.COUNT;
m                       NUMBER := l_eam_op_network_tbl.COUNT;
n                       NUMBER := l_eam_mat_req_tbl.COUNT;

l_count                 NUMBER := 0;
l_count1                NUMBER := 0;


l_group_id NUMBER;

l_def_return_status VARCHAR2(1);
l_def_msg_count NUMBER;
l_def_msg_data  VARCHAR2(1000);


        CURSOR ActivityOP IS
        SELECT
                 p_eam_wo_rec.batch_id           batch_id
               , p_eam_wo_rec.header_id          header_id
               , p_eam_wo_rec.wip_entity_id    WIP_ENTITY_ID
               , p_eam_wo_rec.organization_id  ORGANIZATION_ID
               , BOS.OPERATION_SEQUENCE_ID     OPERATION_SEQUENCE_ID
               , BOS.OPERATION_SEQ_NUM         OPERATION_SEQ_NUM
               , BOS.STANDARD_OPERATION_ID     STANDARD_OPERATION_ID
               , BOS.DEPARTMENT_ID             DEPARTMENT_ID
               , BOS.OPERATION_DESCRIPTION     DESCRIPTION
	       , BOS.LONG_DESCRIPTION          LONG_DESCRIPTION
               , 0                             MINIMUM_TRANSFER_QUANTITY
               , 1                             COUNT_POINT_TYPE
               , 1                             BACKFLUSH_FLAG
               , BOS.SHUTDOWN_TYPE             SHUTDOWN_TYPE
               , nvl(p_eam_wo_rec.scheduled_start_date,SYSDATE) START_DATE
               , nvl(p_eam_wo_rec.scheduled_completion_date,SYSDATE) COMPLETION_DATE
               , BOS.ATTRIBUTE_CATEGORY        ATTRIBUTE_CATEGORY
               , BOS.ATTRIBUTE1                ATTRIBUTE1
               , BOS.ATTRIBUTE2                ATTRIBUTE2
               , BOS.ATTRIBUTE3                ATTRIBUTE3
               , BOS.ATTRIBUTE4                ATTRIBUTE4
               , BOS.ATTRIBUTE5                ATTRIBUTE5
               , BOS.ATTRIBUTE6                ATTRIBUTE6
               , BOS.ATTRIBUTE7                ATTRIBUTE7
               , BOS.ATTRIBUTE8                ATTRIBUTE8
               , BOS.ATTRIBUTE9                ATTRIBUTE9
               , BOS.ATTRIBUTE10               ATTRIBUTE10
               , BOS.ATTRIBUTE11               ATTRIBUTE11
               , BOS.ATTRIBUTE12               ATTRIBUTE12
               , BOS.ATTRIBUTE13               ATTRIBUTE13
               , BOS.ATTRIBUTE14               ATTRIBUTE14
               , BOS.ATTRIBUTE15               ATTRIBUTE15
               , null                          RETURN_STATUS
               , 1                             TRANSACTION_TYPE
-- Bug 3262984 : For adding attachments from the activity to the workorder on explosion
--  one of the entities requires common_routing_sequence_id as a primary key.Hence being added to the query.
               , BORT.COMMON_ROUTING_SEQUENCE_ID COMMON_ROUTING_SEQUENCE_ID
	       , BOS.X_COORDINATE
	       , BOS.Y_COORDINATE
         FROM    BOM_OPERATION_SEQUENCES BOS
               , BOM_OPERATIONAL_ROUTINGS BORT
        WHERE    BORT.assembly_item_id      = p_eam_wo_rec.asset_activity_id
          AND    BORT.organization_id       = p_eam_wo_rec.organization_id
          AND    BOS.ROUTING_SEQUENCE_ID    = BORT.COMMON_ROUTING_SEQUENCE_ID  -- agaurav- Changed ROUTING_SEQUENCE_ID to COMMON_ROUTING_SEQUENCE_ID
          AND    NVL(BOS.OPERATION_TYPE, 1) = 1
          AND    BOS.EFFECTIVITY_DATE <=  p_rout_rev_datetime
          AND    NVL(BOS.DISABLE_DATE, p_rout_rev_datetime + 2) >= p_rout_rev_datetime
          AND    BOS.IMPLEMENTATION_DATE IS NOT NULL
		  AND (      ( p_eam_wo_rec.alternate_routing_designator is not null
                     AND nvl(BORT.ALTERNATE_ROUTING_DESIGNATOR,'null_routing_designator') = nvl(p_eam_wo_rec.alternate_routing_designator,'null_routing_designator') )
              OR  ( p_eam_wo_rec.alternate_routing_designator is null
                     AND nvl(BORT.ALTERNATE_ROUTING_DESIGNATOR,'null_routing_designator') =  nvl(p_eam_wo_rec.alternate_routing_designator,'null_routing_designator') )
           ) ;
        -- agaurav - Added the check for alternate_routing_designator so that the
	    --             - operations are copied either from the primary or alternate routing.




            /* Resource information from BOM to WIP */


        CURSOR ActivityRES IS
        SELECT
                 p_eam_wo_rec.batch_id           batch_id
               , p_eam_wo_rec.header_id          header_id
               , p_eam_wo_rec.wip_entity_id      WIP_ENTITY_ID
               , p_eam_wo_rec.organization_id    ORGANIZATION_ID
               , BOS.OPERATION_SEQ_NUM           OPERATION_SEQ_NUM
               , BOS.DEPARTMENT_ID               DEPARTMENT_ID
               , BOR.RESOURCE_SEQ_NUM            RESOURCE_SEQ_NUM
               , BOR.RESOURCE_ID                 RESOURCE_ID
               , BR.UNIT_OF_MEASURE              UOM_CODE
               , BOR.BASIS_TYPE                  BASIS_TYPE
               , BOR.USAGE_RATE_OR_AMOUNT        USAGE_RATE_OR_AMOUNT
               , BOR.ACTIVITY_ID                 ACTIVITY_ID
               , BOR.SCHEDULE_FLAG               SCHEDULED_FLAG
               , BOR.ASSIGNED_UNITS              ASSIGNED_UNITS
	       --added for bug 4363800 decode statement to select 2,3 as eAM supports only 2 or 3
               , DECODE(BOR.AUTOCHARGE_TYPE,1,2,4,3,3,3,2)		 AUTOCHARGE_TYPE         -- Fix for Bug 3823415
               , BOR.STANDARD_RATE_FLAG          STANDARD_RATE_FLAG
               , 0                               APPLIED_RESOURCE_UNITS
               , 0                               APPLIED_RESOURCE_VALUE
               , nvl(p_eam_wo_rec.scheduled_start_date,SYSDATE) START_DATE
               , nvl(p_eam_wo_rec.scheduled_completion_date,SYSDATE) COMPLETION_DATE
               , 0                               REPLACEMENT_GROUP_NUM
               , BOR.SCHEDULE_SEQ_NUM            SCHEDULE_SEQ_NUM
               , BOR.SUBSTITUTE_GROUP_NUM        SUBSTITUTE_GROUP_NUM
               , BOR.ATTRIBUTE_CATEGORY          ATTRIBUTE_CATEGORY
               , BOR.ATTRIBUTE1                  ATTRIBUTE1
               , BOR.ATTRIBUTE2                  ATTRIBUTE2
               , BOR.ATTRIBUTE3                  ATTRIBUTE3
               , BOR.ATTRIBUTE4                  ATTRIBUTE4
               , BOR.ATTRIBUTE5                  ATTRIBUTE5
               , BOR.ATTRIBUTE6                  ATTRIBUTE6
               , BOR.ATTRIBUTE7                  ATTRIBUTE7
               , BOR.ATTRIBUTE8                  ATTRIBUTE8
               , BOR.ATTRIBUTE9                  ATTRIBUTE9
               , BOR.ATTRIBUTE10                 ATTRIBUTE10
               , BOR.ATTRIBUTE11                 ATTRIBUTE11
               , BOR.ATTRIBUTE12                 ATTRIBUTE12
               , BOR.ATTRIBUTE13                 ATTRIBUTE13
               , BOR.ATTRIBUTE14                 ATTRIBUTE14
               , BOR.ATTRIBUTE15                 ATTRIBUTE15
               , null                            RETURN_STATUS
               , 1                               TRANSACTION_TYPE
         FROM    BOM_RESOURCES            BR
               , BOM_OPERATION_RESOURCES  BOR
               , BOM_OPERATION_SEQUENCES  BOS
               , BOM_OPERATIONAL_ROUTINGS BORT
        WHERE    BORT.assembly_item_id      = p_eam_wo_rec.asset_activity_id
          AND    BORT.organization_id       = p_eam_wo_rec.organization_id
          AND    BOS.ROUTING_SEQUENCE_ID    = BORT.COMMON_ROUTING_SEQUENCE_ID   -- agaurav- Changed ROUTING_SEQUENCE_ID to COMMON_ROUTING_SEQUENCE_ID
          AND    BOS.OPERATION_SEQUENCE_ID = BOR.OPERATION_SEQUENCE_ID
          AND    BOS.EFFECTIVITY_DATE      <=  p_rout_rev_datetime
          AND    NVL(BOS.DISABLE_DATE, p_rout_rev_datetime + 2) >= p_rout_rev_datetime
          AND    BOR.RESOURCE_ID           = BR.RESOURCE_ID
          AND    BR.ORGANIZATION_ID       = p_eam_wo_rec.organization_id
          AND    (BOR.ACD_TYPE IS NULL OR BOR.ACD_TYPE <> 3)
		  AND (      ( p_eam_wo_rec.alternate_routing_designator is not null
                     AND nvl(BORT.ALTERNATE_ROUTING_DESIGNATOR,'null_routing_designator') = nvl(p_eam_wo_rec.alternate_routing_designator,'null_routing_designator') )
              OR  ( p_eam_wo_rec.alternate_routing_designator is null
                     AND nvl(BORT.ALTERNATE_ROUTING_DESIGNATOR,'null_routing_designator') =  nvl(p_eam_wo_rec.alternate_routing_designator,'null_routing_designator') )
           ) ;
        -- agaurav - Added the check for alternate_routing_designator so that the
	    --             - operations are copied either from the primary or alternate routing.



     /* NETWORKS from activity BOM to WIP */
        CURSOR ActivityOPN IS
        SELECT
                 p_eam_wo_rec.batch_id           batch_id
               , p_eam_wo_rec.header_id          header_id
               , p_eam_wo_rec.wip_entity_id      WIP_ENTITY_ID
               , p_eam_wo_rec.organization_id    ORGANIZATION_ID
               , BOS_FROM.OPERATION_SEQ_NUM      PRIOR_OPERATION
               , BOS_TO.OPERATION_SEQ_NUM        NEXT_OPERATION
               , BON.ATTRIBUTE_CATEGORY          ATTRIBUTE_CATEGORY
               , BON.ATTRIBUTE1                  ATTRIBUTE1
               , BON.ATTRIBUTE2                  ATTRIBUTE2
               , BON.ATTRIBUTE3                  ATTRIBUTE3
               , BON.ATTRIBUTE4                  ATTRIBUTE4
               , BON.ATTRIBUTE5                  ATTRIBUTE5
               , BON.ATTRIBUTE6                  ATTRIBUTE6
               , BON.ATTRIBUTE7                  ATTRIBUTE7
               , BON.ATTRIBUTE8                  ATTRIBUTE8
               , BON.ATTRIBUTE9                  ATTRIBUTE9
               , BON.ATTRIBUTE10                 ATTRIBUTE10
               , BON.ATTRIBUTE11                 ATTRIBUTE11
               , BON.ATTRIBUTE12                 ATTRIBUTE12
               , BON.ATTRIBUTE13                 ATTRIBUTE13
               , BON.ATTRIBUTE14                 ATTRIBUTE14
               , BON.ATTRIBUTE15                 ATTRIBUTE15
               , null                            RETURN_STATUS
               , 1                               TRANSACTION_TYPE
         FROM    BOM_OPERATION_NETWORKS  BON
               , BOM_OPERATION_SEQUENCES BOS_FROM
               , BOM_OPERATION_SEQUENCES BOS_TO
               , BOM_OPERATIONAL_ROUTINGS BORT
        WHERE    BORT.assembly_item_id        = p_eam_wo_rec.asset_activity_id
          AND    BORT.organization_id         = p_eam_wo_rec.organization_id
          AND    BOS_FROM.ROUTING_SEQUENCE_ID = BORT.COMMON_ROUTING_SEQUENCE_ID    -- agaurav- Changed ROUTING_SEQUENCE_ID to COMMON_ROUTING_SEQUENCE_ID
          AND    BOS_TO.ROUTING_SEQUENCE_ID = BORT.COMMON_ROUTING_SEQUENCE_ID        -- agaurav- Changed ROUTING_SEQUENCE_ID to COMMON_ROUTING_SEQUENCE_ID
          AND    BOS_FROM.EFFECTIVITY_DATE      <=  p_rout_rev_datetime
          AND    NVL(BOS_FROM.DISABLE_DATE, p_rout_rev_datetime + 2) >= p_rout_rev_datetime
          AND    BOS_TO.EFFECTIVITY_DATE      <=  p_rout_rev_datetime
          AND    NVL(BOS_TO.DISABLE_DATE, p_rout_rev_datetime + 2) >= p_rout_rev_datetime
          AND    BON.FROM_OP_SEQ_ID    = BOS_FROM.OPERATION_SEQUENCE_ID
          AND    BON.TO_OP_SEQ_ID      = BOS_TO.OPERATION_SEQUENCE_ID
          AND    NVL(BON.EFFECTIVITY_DATE, SYSDATE-2) < SYSDATE
          AND    NVL(BON.DISABLE_DATE, SYSDATE+2) > SYSDATE
          -- agaurav - Added the check for alternate_routing_designator so that the
	  --             - operations are copied either from the primary or alternate routing.
		  AND (      ( p_eam_wo_rec.alternate_routing_designator is not null
                     AND nvl(BORT.ALTERNATE_ROUTING_DESIGNATOR,'null_routing_designator') = nvl(p_eam_wo_rec.alternate_routing_designator,'null_routing_designator') )
              OR  ( p_eam_wo_rec.alternate_routing_designator is null
                     AND nvl(BORT.ALTERNATE_ROUTING_DESIGNATOR,'null_routing_designator') =  nvl(p_eam_wo_rec.alternate_routing_designator,'null_routing_designator') )
           )
          -- Bugfix 3556118 : There should not be any operation as part of the
          -- network that is outside it's effectivity dates. If there is even
          -- one such operation, then don't create any networks.
          AND NOT EXISTS (
            select 1
              FROM    BOM_OPERATION_NETWORKS  BON
               , BOM_OPERATION_SEQUENCES BOS_FROM
               , BOM_OPERATION_SEQUENCES BOS_TO
               , BOM_OPERATIONAL_ROUTINGS BORT
              WHERE    BORT.assembly_item_id        = p_eam_wo_rec.asset_activity_id
                AND    BORT.organization_id         = p_eam_wo_rec.organization_id
                AND    BOS_FROM.ROUTING_SEQUENCE_ID = BORT.COMMON_ROUTING_SEQUENCE_ID
                -- agaurav- Changed ROUTING_SEQUENCE_ID to COMMON_ROUTING_SEQUENCE_ID
                AND    BOS_TO.ROUTING_SEQUENCE_ID = BORT.COMMON_ROUTING_SEQUENCE_ID
                -- agaurav- Changed ROUTING_SEQUENCE_ID to COMMON_ROUTING_SEQUENCE_ID
                AND (   p_rout_rev_datetime NOT BETWEEN BOS_FROM.EFFECTIVITY_DATE AND
                                                NVL(BOS_FROM.DISABLE_DATE, p_rout_rev_datetime)
                   OR   p_rout_rev_datetime NOT BETWEEN BOS_TO.EFFECTIVITY_DATE AND
                                                NVL(BOS_TO.DISABLE_DATE, p_rout_rev_datetime)
                )
                AND    BON.FROM_OP_SEQ_ID    = BOS_FROM.OPERATION_SEQUENCE_ID
                AND    BON.TO_OP_SEQ_ID      = BOS_TO.OPERATION_SEQUENCE_ID
                AND    NVL(BON.EFFECTIVITY_DATE, SYSDATE-2) < SYSDATE
                AND    NVL(BON.DISABLE_DATE, SYSDATE+2) > SYSDATE
                -- agaurav - Added the check for alternate_routing_designator so that the
                --             - operations are copied either from the primary or alternate routing.
                AND (      ( p_eam_wo_rec.alternate_routing_designator is not null
                     AND
                     nvl(BORT.ALTERNATE_ROUTING_DESIGNATOR,'null_routing_designator') =
                     nvl(p_eam_wo_rec.alternate_routing_designator,'null_routing_designator') )
                OR  ( p_eam_wo_rec.alternate_routing_designator is null
                     AND
                     nvl(BORT.ALTERNATE_ROUTING_DESIGNATOR,'null_routing_designator') =
                     nvl(p_eam_wo_rec.alternate_routing_designator,'null_routing_designator') )
                )
          );



    cursor ActivityREQ(v_grpID NUMBER) is
        -- This is a union of 2 queries. One for which the material operation
        -- seq num is 1 and the second for the case when op seq num <> 1
        (SELECT
                 p_eam_wo_rec.batch_id           batch_id
               , p_eam_wo_rec.header_id          header_id
               , null                            row_id
               , p_eam_wo_rec.wip_entity_id      WIP_ENTITY_ID
               , p_eam_wo_rec.organization_id    ORGANIZATION_ID
               , BE.OPERATION_SEQ_NUM            OPERATION_SEQ_NUM
               , BE.COMPONENT_ITEM_ID            INVENTORY_ITEM_ID
               , BE.COMPONENT_QUANTITY           QUANTITY_PER_ASSEMBLY
               , to_number(null)                 DEPARTMENT_ID
               , BIC.WIP_SUPPLY_TYPE             WIP_SUPPLY_TYPE
               ,  nvl(p_eam_wo_rec.scheduled_start_date,SYSDATE) DATE_REQUIRED
               , extended_quantity               REQUIRED_QUANTITY
--fix for 3550864.
               , null                            REQUESTED_QUANTITY
--fix for 3571180
               ,null                             RELEASED_QUANTITY
               , 0                               QUANTITY_ISSUED
               , NVL(BIC.SUPPLY_SUBINVENTORY, MSI.WIP_SUPPLY_SUBINVENTORY)                              SUPPLY_SUBINVENTORY
               , DECODE(BIC.SUPPLY_SUBINVENTORY, NULL, MSI.WIP_SUPPLY_LOCATOR_ID,BIC.SUPPLY_LOCATOR_ID) SUPPLY_LOCATOR_ID
               , wip_constants.SUPPLY_NET        MRP_NET_FLAG
               , 0                               MPS_REQUIRED_QUANTITY
               , null /*bugfix#5059638 nvl(p_eam_wo_rec.scheduled_start_date,SYSDATE)*/ MPS_DATE_REQUIRED
               , BIC.COMPONENT_SEQUENCE_ID       COMPONENT_SEQUENCE_ID
               , BIC.COMPONENT_REMARKS           COMMENTS
               , BIC.ATTRIBUTE_CATEGORY          ATTRIBUTE_CATEGORY
               , BIC.ATTRIBUTE1                  ATTRIBUTE1
               , BIC.ATTRIBUTE2                  ATTRIBUTE2
               , BIC.ATTRIBUTE3                  ATTRIBUTE3
               , BIC.ATTRIBUTE4                  ATTRIBUTE4
               , BIC.ATTRIBUTE5                  ATTRIBUTE5
               , BIC.ATTRIBUTE6                  ATTRIBUTE6
               , BIC.ATTRIBUTE7                  ATTRIBUTE7
               , BIC.ATTRIBUTE8                  ATTRIBUTE8
               , BIC.ATTRIBUTE9                  ATTRIBUTE9
               , BIC.ATTRIBUTE10                 ATTRIBUTE10
               , BIC.ATTRIBUTE11                 ATTRIBUTE11
               , BIC.ATTRIBUTE12                 ATTRIBUTE12
               , BIC.ATTRIBUTE13                 ATTRIBUTE13
               , BIC.ATTRIBUTE14                 ATTRIBUTE14
               , BIC.ATTRIBUTE15                 ATTRIBUTE15
               , BE.AUTO_REQUEST_MATERIAL        AUTO_REQUEST_MATERIAL
               , BIC.SUGGESTED_VENDOR_NAME       SUGGESTED_VENDOR_NAME
               , BIC.VENDOR_ID                   VENDOR_ID
               , BIC.UNIT_PRICE                  UNIT_PRICE
               , null                            REQUEST_ID
               , null                            PROGRAM_APPLICATION_ID
               , null                            PROGRAM_ID
               , null                            PROGRAM_UPDATE_DATE
               , null                            RETURN_STATUS
               , 1                               TRANSACTION_TYPE
        FROM     BOM_EXPLOSION_TEMP BE
               , BOM_INVENTORY_COMPONENTS BIC
               , MTL_SYSTEM_ITEMS MSI
        WHERE    BE.GROUP_ID              = v_grpID
         AND     BE.COMPONENT_SEQUENCE_ID = BIC.COMPONENT_SEQUENCE_ID
         AND     BE.COMPONENT_ITEM_ID     = MSI.INVENTORY_ITEM_ID
         AND     BE.COMPONENT_ITEM_ID    <> p_eam_wo_rec.asset_activity_id --EXCLUDE ASSY IF IT IS IN THE TABLE
         AND     MSI.ORGANIZATION_ID      = p_eam_wo_rec.organization_id
         AND     BE.OPERATION_SEQ_NUM     = 1)

       UNION

       (SELECT
                 p_eam_wo_rec.batch_id           batch_id
               , p_eam_wo_rec.header_id          header_id
               , null                            row_id
               , p_eam_wo_rec.wip_entity_id      WIP_ENTITY_ID
               , p_eam_wo_rec.organization_id    ORGANIZATION_ID
               , BE.OPERATION_SEQ_NUM            OPERATION_SEQ_NUM
               , BE.COMPONENT_ITEM_ID            INVENTORY_ITEM_ID
               , BE.COMPONENT_QUANTITY           QUANTITY_PER_ASSEMBLY
               , BOS.DEPARTMENT_ID               DEPARTMENT_ID
               , BIC.WIP_SUPPLY_TYPE             WIP_SUPPLY_TYPE
               ,  nvl(p_eam_wo_rec.scheduled_start_date,SYSDATE) DATE_REQUIRED
               , extended_quantity               REQUIRED_QUANTITY
   --fix for 3550864.
               , null                            REQUESTED_QUANTITY
   --fix for 3572280
               , null                            RELEASED_QUANTITY
               , 0                               QUANTITY_ISSUED
               , NVL(BIC.SUPPLY_SUBINVENTORY, MSI.WIP_SUPPLY_SUBINVENTORY)                              SUPPLY_SUBINVENTORY
               , DECODE(BIC.SUPPLY_SUBINVENTORY, NULL, MSI.WIP_SUPPLY_LOCATOR_ID,BIC.SUPPLY_LOCATOR_ID) SUPPLY_LOCATOR_ID
               , wip_constants.SUPPLY_NET        MRP_NET_FLAG
               , 0                               MPS_REQUIRED_QUANTITY
               , null /*bugfix#5059638 nvl(p_eam_wo_rec.scheduled_start_date,SYSDATE)*/ MPS_DATE_REQUIRED
               , BIC.COMPONENT_SEQUENCE_ID       COMPONENT_SEQUENCE_ID
               , BIC.COMPONENT_REMARKS           COMMENTS
               , BIC.ATTRIBUTE_CATEGORY          ATTRIBUTE_CATEGORY
               , BIC.ATTRIBUTE1                  ATTRIBUTE1
               , BIC.ATTRIBUTE2                  ATTRIBUTE2
               , BIC.ATTRIBUTE3                  ATTRIBUTE3
               , BIC.ATTRIBUTE4                  ATTRIBUTE4
               , BIC.ATTRIBUTE5                  ATTRIBUTE5
               , BIC.ATTRIBUTE6                  ATTRIBUTE6
               , BIC.ATTRIBUTE7                  ATTRIBUTE7
               , BIC.ATTRIBUTE8                  ATTRIBUTE8
               , BIC.ATTRIBUTE9                  ATTRIBUTE9
               , BIC.ATTRIBUTE10                 ATTRIBUTE10
               , BIC.ATTRIBUTE11                 ATTRIBUTE11
               , BIC.ATTRIBUTE12                 ATTRIBUTE12
               , BIC.ATTRIBUTE13                 ATTRIBUTE13
               , BIC.ATTRIBUTE14                 ATTRIBUTE14
               , BIC.ATTRIBUTE15                 ATTRIBUTE15
               , BE.AUTO_REQUEST_MATERIAL        AUTO_REQUEST_MATERIAL
               , BIC.SUGGESTED_VENDOR_NAME       SUGGESTED_VENDOR_NAME
               , BIC.VENDOR_ID                   VENDOR_ID
               , BIC.UNIT_PRICE                  UNIT_PRICE
               , null                            REQUEST_ID
               , null                            PROGRAM_APPLICATION_ID
               , null                            PROGRAM_ID
               , null                            PROGRAM_UPDATE_DATE
               , null                            RETURN_STATUS
               , 1                               TRANSACTION_TYPE
        FROM     BOM_EXPLOSION_TEMP BE
               , BOM_INVENTORY_COMPONENTS BIC
               , BOM_OPERATIONAL_ROUTINGS BORT
               , BOM_OPERATION_SEQUENCES  BOS
               , MTL_SYSTEM_ITEMS MSI
        WHERE    BE.GROUP_ID              = v_grpID
         AND     BE.COMPONENT_SEQUENCE_ID = BIC.COMPONENT_SEQUENCE_ID
         AND     BE.COMPONENT_ITEM_ID     = MSI.INVENTORY_ITEM_ID
         AND     BE.COMPONENT_ITEM_ID    <> p_eam_wo_rec.asset_activity_id --EXCLUDE ASSY IF IT IS IN THE TABLE
         AND     MSI.ORGANIZATION_ID      = p_eam_wo_rec.organization_id
         AND     BORT.assembly_item_id      = p_eam_wo_rec.asset_activity_id
         AND     BORT.organization_id       = p_eam_wo_rec.organization_id
         AND     BOS.ROUTING_SEQUENCE_ID    = BORT.COMMON_ROUTING_SEQUENCE_ID
         AND     BOS.EFFECTIVITY_DATE      <=  p_bom_rev_datetime
         AND     NVL(BOS.DISABLE_DATE, p_bom_rev_datetime + 2) >= p_bom_rev_datetime
         AND     BE.OPERATION_SEQ_NUM       = BIC.OPERATION_SEQ_NUM
         AND     BOS.OPERATION_SEQ_NUM      = BIC.OPERATION_SEQ_NUM
         AND     NVL(BOS.OPERATION_TYPE, 1) = 1
         AND     BOS.EFFECTIVITY_DATE <=  p_bom_rev_datetime
         AND     NVL(BOS.DISABLE_DATE, p_bom_rev_datetime + 2) >= p_bom_rev_datetime
         AND     BOS.IMPLEMENTATION_DATE IS NOT NULL
         AND     (( p_eam_wo_rec.alternate_routing_designator is not null
                    AND nvl(BORT.ALTERNATE_ROUTING_DESIGNATOR,'null_routing_designator') =
                      nvl(p_eam_wo_rec.alternate_routing_designator,'null_routing_designator')
                  )
                  OR
                  ( p_eam_wo_rec.alternate_routing_designator is null
                    AND nvl(BORT.ALTERNATE_ROUTING_DESIGNATOR,'null_routing_designator') =
                      nvl(p_eam_wo_rec.alternate_routing_designator,'null_routing_designator')
                  )
                 )
         AND     BE.OPERATION_SEQ_NUM <> 1);

matreqrec ActivityREQ%ROWTYPE;

BEGIN


IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug('Starting Activity Explosion'); end if;


-- **************************** OPERATIONS ******************
IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug('Exploding Operations'); end if;
    FOR oprec IN ActivityOP LOOP

        j:=j+1; --counter for operations
               l_eam_op_tbl(j).BATCH_ID :=oprec.BATCH_ID;
               l_eam_op_tbl(j).HEADER_ID :=oprec.HEADER_ID;
               l_eam_op_tbl(j).WIP_ENTITY_ID :=oprec.WIP_ENTITY_ID;
               l_eam_op_tbl(j).ORGANIZATION_ID :=oprec.ORGANIZATION_ID;
               l_eam_op_tbl(j).OPERATION_SEQUENCE_ID :=oprec.OPERATION_SEQUENCE_ID;
               l_eam_op_tbl(j).OPERATION_SEQ_NUM :=oprec.OPERATION_SEQ_NUM;
               l_eam_op_tbl(j).STANDARD_OPERATION_ID :=oprec.STANDARD_OPERATION_ID;
               l_eam_op_tbl(j).DEPARTMENT_ID :=oprec.DEPARTMENT_ID;
               l_eam_op_tbl(j).DESCRIPTION :=oprec.DESCRIPTION;
               l_eam_op_tbl(j).LONG_DESCRIPTION :=oprec.LONG_DESCRIPTION;
               l_eam_op_tbl(j).MINIMUM_TRANSFER_QUANTITY :=oprec.MINIMUM_TRANSFER_QUANTITY;
               l_eam_op_tbl(j).COUNT_POINT_TYPE :=oprec.COUNT_POINT_TYPE;
               l_eam_op_tbl(j).BACKFLUSH_FLAG :=oprec.BACKFLUSH_FLAG;
               l_eam_op_tbl(j).SHUTDOWN_TYPE :=oprec.SHUTDOWN_TYPE;
               l_eam_op_tbl(j).START_DATE :=oprec.START_DATE;
               l_eam_op_tbl(j).COMPLETION_DATE :=oprec.COMPLETION_DATE;
               l_eam_op_tbl(j).Attribute_Category :=oprec.Attribute_Category;
               l_eam_op_tbl(j).Attribute1 :=oprec.Attribute1;
               l_eam_op_tbl(j).Attribute2 :=oprec.Attribute2;
               l_eam_op_tbl(j).Attribute3 :=oprec.Attribute3;
               l_eam_op_tbl(j).Attribute4 :=oprec.Attribute4;
               l_eam_op_tbl(j).Attribute5 :=oprec.Attribute5;
               l_eam_op_tbl(j).Attribute6 :=oprec.Attribute6;
               l_eam_op_tbl(j).Attribute7 :=oprec.Attribute7;
               l_eam_op_tbl(j).Attribute8 :=oprec.Attribute8;
               l_eam_op_tbl(j).Attribute9 :=oprec.Attribute9;
               l_eam_op_tbl(j).Attribute10 :=oprec.Attribute10;
               l_eam_op_tbl(j).Attribute11 :=oprec.Attribute11;
               l_eam_op_tbl(j).Attribute12 :=oprec.Attribute12;
               l_eam_op_tbl(j).Attribute13 :=oprec.Attribute13;
               l_eam_op_tbl(j).Attribute14 :=oprec.Attribute14;
               l_eam_op_tbl(j).Attribute15 :=oprec.Attribute15;
	       l_eam_op_tbl(j).X_POS       :=oprec.X_COORDINATE;
               l_eam_op_tbl(j).Y_POS       :=oprec.Y_COORDINATE;
               l_eam_op_tbl(j).RETURN_STATUS :=oprec.RETURN_STATUS;
               l_eam_op_tbl(j).TRANSACTION_TYPE :=oprec.TRANSACTION_TYPE;

    END LOOP;



-- **************************** RESOURCES ******************
IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug('Exploding Resource Requirements'); end if;
    FOR resrec IN ActivityRES LOOP


        k:=k+1; --counter for resources

                l_eam_res_tbl(k).BATCH_ID := resrec.BATCH_ID;
                l_eam_res_tbl(k).HEADER_ID := resrec.HEADER_ID;
                l_eam_res_tbl(k).WIP_ENTITY_ID := resrec.WIP_ENTITY_ID;
                l_eam_res_tbl(k).ORGANIZATION_ID := resrec.ORGANIZATION_ID;
                l_eam_res_tbl(k).OPERATION_SEQ_NUM := resrec.OPERATION_SEQ_NUM;
                l_eam_res_tbl(k).DEPARTMENT_ID := resrec.DEPARTMENT_ID;
                l_eam_res_tbl(k).RESOURCE_SEQ_NUM := resrec.RESOURCE_SEQ_NUM;
                l_eam_res_tbl(k).RESOURCE_ID := resrec.RESOURCE_ID;
                l_eam_res_tbl(k).UOM_CODE := resrec.UOM_CODE;
                l_eam_res_tbl(k).BASIS_TYPE := resrec.BASIS_TYPE;
                l_eam_res_tbl(k).USAGE_RATE_OR_AMOUNT := resrec.USAGE_RATE_OR_AMOUNT;
                l_eam_res_tbl(k).ACTIVITY_ID := resrec.ACTIVITY_ID;
                l_eam_res_tbl(k).SCHEDULED_FLAG := resrec.SCHEDULED_FLAG;
                l_eam_res_tbl(k).ASSIGNED_UNITS := resrec.ASSIGNED_UNITS;
                l_eam_res_tbl(k).AUTOCHARGE_TYPE := resrec.AUTOCHARGE_TYPE;
                l_eam_res_tbl(k).STANDARD_RATE_FLAG := resrec.STANDARD_RATE_FLAG;
                l_eam_res_tbl(k).APPLIED_RESOURCE_UNITS := resrec.APPLIED_RESOURCE_UNITS;
                l_eam_res_tbl(k).APPLIED_RESOURCE_VALUE := resrec.APPLIED_RESOURCE_VALUE;
                l_eam_res_tbl(k).START_DATE := resrec.START_DATE;
                l_eam_res_tbl(k).COMPLETION_DATE := resrec.COMPLETION_DATE;
                l_eam_res_tbl(k).SCHEDULE_SEQ_NUM := resrec.SCHEDULE_SEQ_NUM;
                l_eam_res_tbl(k).SUBSTITUTE_GROUP_NUM := resrec.SUBSTITUTE_GROUP_NUM;
                l_eam_res_tbl(k).REPLACEMENT_GROUP_NUM := resrec.REPLACEMENT_GROUP_NUM;
                l_eam_res_tbl(k).ATTRIBUTE_CATEGORY := resrec.ATTRIBUTE_CATEGORY;
                l_eam_res_tbl(k).ATTRIBUTE1 := resrec.ATTRIBUTE1;
                l_eam_res_tbl(k).ATTRIBUTE2 := resrec.ATTRIBUTE2;
                l_eam_res_tbl(k).ATTRIBUTE3 := resrec.ATTRIBUTE3;
                l_eam_res_tbl(k).ATTRIBUTE4 := resrec.ATTRIBUTE4;
                l_eam_res_tbl(k).ATTRIBUTE5 := resrec.ATTRIBUTE5;
                l_eam_res_tbl(k).ATTRIBUTE6 := resrec.ATTRIBUTE6;
                l_eam_res_tbl(k).ATTRIBUTE7 := resrec.ATTRIBUTE7;
                l_eam_res_tbl(k).ATTRIBUTE8 := resrec.ATTRIBUTE8;
                l_eam_res_tbl(k).ATTRIBUTE9 := resrec.ATTRIBUTE9;
                l_eam_res_tbl(k).ATTRIBUTE10 := resrec.ATTRIBUTE10;
                l_eam_res_tbl(k).ATTRIBUTE11 := resrec.ATTRIBUTE11;
                l_eam_res_tbl(k).ATTRIBUTE12 := resrec.ATTRIBUTE12;
                l_eam_res_tbl(k).ATTRIBUTE13 := resrec.ATTRIBUTE13;
                l_eam_res_tbl(k).ATTRIBUTE14 := resrec.ATTRIBUTE14;
                l_eam_res_tbl(k).ATTRIBUTE15 := resrec.ATTRIBUTE15;
                l_eam_res_tbl(k).RETURN_STATUS := resrec.RETURN_STATUS;
                l_eam_res_tbl(k).TRANSACTION_TYPE := resrec.TRANSACTION_TYPE;

    END LOOP;


-- **************************** OPERATION NETWORKS ******************
IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug('Exploding Operation Networks'); end if;
    FOR opnetworkrec IN ActivityOPN LOOP

        m:=m+1; --counter for operation networks

                l_eam_op_network_tbl(m).BATCH_ID   := opnetworkrec.BATCH_ID;
                l_eam_op_network_tbl(m).HEADER_ID   := opnetworkrec.HEADER_ID;
                l_eam_op_network_tbl(m).WIP_ENTITY_ID   := opnetworkrec.WIP_ENTITY_ID;
                l_eam_op_network_tbl(m).ORGANIZATION_ID := opnetworkrec.ORGANIZATION_ID;
                l_eam_op_network_tbl(m).PRIOR_OPERATION := opnetworkrec.PRIOR_OPERATION;
                l_eam_op_network_tbl(m).NEXT_OPERATION  := opnetworkrec.NEXT_OPERATION;
                l_eam_op_network_tbl(m).ATTRIBUTE_CATEGORY := opnetworkrec.ATTRIBUTE_CATEGORY;
                l_eam_op_network_tbl(m).ATTRIBUTE1 := opnetworkrec.ATTRIBUTE1;
                l_eam_op_network_tbl(m).ATTRIBUTE2 := opnetworkrec.ATTRIBUTE2;
                l_eam_op_network_tbl(m).ATTRIBUTE3 := opnetworkrec.ATTRIBUTE3;
                l_eam_op_network_tbl(m).ATTRIBUTE4 := opnetworkrec.ATTRIBUTE4;
                l_eam_op_network_tbl(m).ATTRIBUTE5 := opnetworkrec.ATTRIBUTE5;
                l_eam_op_network_tbl(m).ATTRIBUTE6 := opnetworkrec.ATTRIBUTE6;
                l_eam_op_network_tbl(m).ATTRIBUTE7 := opnetworkrec.ATTRIBUTE7;
                l_eam_op_network_tbl(m).ATTRIBUTE8 := opnetworkrec.ATTRIBUTE8;
                l_eam_op_network_tbl(m).ATTRIBUTE9 := opnetworkrec.ATTRIBUTE9;
                l_eam_op_network_tbl(m).ATTRIBUTE10 := opnetworkrec.ATTRIBUTE10;
                l_eam_op_network_tbl(m).ATTRIBUTE11 := opnetworkrec.ATTRIBUTE11;
                l_eam_op_network_tbl(m).ATTRIBUTE12 := opnetworkrec.ATTRIBUTE12;
                l_eam_op_network_tbl(m).ATTRIBUTE13 := opnetworkrec.ATTRIBUTE13;
                l_eam_op_network_tbl(m).ATTRIBUTE14 := opnetworkrec.ATTRIBUTE14;
                l_eam_op_network_tbl(m).ATTRIBUTE15 := opnetworkrec.ATTRIBUTE15;
                l_eam_op_network_tbl(m).RETURN_STATUS := opnetworkrec.RETURN_STATUS;
                l_eam_op_network_tbl(m).TRANSACTION_TYPE := opnetworkrec.TRANSACTION_TYPE;
    END LOOP;


IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug('Exploding Material Requirements'); end if;

    BEGIN

      --delete any previous explosions as effectivity/disable dates could be changed
      --make sure the records are not locked.


    select
    bom_explosion_temp_s.nextval
    into l_group_id
    from dual;



IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug('Explosion Group Id = ' || l_group_id); end if;


    bompexpl.exploder_userexit
            ( item_id            =>  l_eam_wo_rec.asset_activity_id
            , org_id             =>  l_eam_wo_rec.organization_id
            , grp_id             =>  l_group_id
            , rev_date           =>  TO_CHAR(nvl(p_eam_wo_rec.bom_revision_date,nvl(p_eam_wo_rec.scheduled_start_date,
	                                        p_eam_wo_rec.scheduled_completion_date)),'YYYY/MM/DD HH24:MI:SS')
            , alt_desg           =>  l_eam_wo_rec.alternate_bom_designator
            , err_msg            =>  l_err_text
            , error_code         =>  l_error_code
            );


        if(l_error_code <> 0) then
          raise fnd_api.G_EXC_UNEXPECTED_ERROR;
        else
          x_return_status := fnd_api.g_ret_sts_success;
        end if;


        open ActivityREQ(v_grpID => l_group_id);
        loop

          fetch ActivityREQ into matreqrec;
          <<start_loop_processing>>
          if(ActivityREQ%NOTFOUND) then
            close ActivityREQ;
            exit;
          end if;

      n := n + 1;

IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug('Fetching ' || matreqrec.INVENTORY_ITEM_ID); end if;

                l_eam_mat_req_tbl(n).BATCH_ID := matreqrec.BATCH_ID;
                l_eam_mat_req_tbl(n).HEADER_ID := matreqrec.HEADER_ID;
                l_eam_mat_req_tbl(n).WIP_ENTITY_ID := matreqrec.WIP_ENTITY_ID;
                l_eam_mat_req_tbl(n).ORGANIZATION_ID := matreqrec.ORGANIZATION_ID;
                l_eam_mat_req_tbl(n).OPERATION_SEQ_NUM := matreqrec.OPERATION_SEQ_NUM;
                l_eam_mat_req_tbl(n).INVENTORY_ITEM_ID := matreqrec.INVENTORY_ITEM_ID;
                l_eam_mat_req_tbl(n).QUANTITY_PER_ASSEMBLY := matreqrec.QUANTITY_PER_ASSEMBLY;
                l_eam_mat_req_tbl(n).DEPARTMENT_ID := matreqrec.DEPARTMENT_ID;
                l_eam_mat_req_tbl(n).WIP_SUPPLY_TYPE := matreqrec.WIP_SUPPLY_TYPE;
                l_eam_mat_req_tbl(n).DATE_REQUIRED := matreqrec.DATE_REQUIRED;
                l_eam_mat_req_tbl(n).REQUIRED_QUANTITY := matreqrec.REQUIRED_QUANTITY;
--fix for 3550864.
                l_eam_mat_req_tbl(n).REQUESTED_QUANTITY := matreqrec.REQUESTED_QUANTITY;
--fix for 35722280
                l_eam_mat_req_tbl(n).RELEASED_QUANTITY := matreqrec.RELEASED_QUANTITY;
                l_eam_mat_req_tbl(n).QUANTITY_ISSUED := matreqrec.QUANTITY_ISSUED;
                l_eam_mat_req_tbl(n).SUPPLY_SUBINVENTORY := matreqrec.SUPPLY_SUBINVENTORY;
                l_eam_mat_req_tbl(n).SUPPLY_LOCATOR_ID := matreqrec.SUPPLY_LOCATOR_ID;
                l_eam_mat_req_tbl(n).MRP_NET_FLAG := matreqrec.MRP_NET_FLAG;
                l_eam_mat_req_tbl(n).MPS_REQUIRED_QUANTITY := matreqrec.MPS_REQUIRED_QUANTITY;
                l_eam_mat_req_tbl(n).MPS_DATE_REQUIRED := matreqrec.MPS_DATE_REQUIRED;
                l_eam_mat_req_tbl(n).SUGGESTED_VENDOR_NAME := matreqrec.SUGGESTED_VENDOR_NAME;
                l_eam_mat_req_tbl(n).VENDOR_ID := matreqrec.VENDOR_ID;
                l_eam_mat_req_tbl(n).UNIT_PRICE := matreqrec.UNIT_PRICE;
                l_eam_mat_req_tbl(n).AUTO_REQUEST_MATERIAL := matreqrec.AUTO_REQUEST_MATERIAL;
                l_eam_mat_req_tbl(n).COMPONENT_SEQUENCE_ID := matreqrec.COMPONENT_SEQUENCE_ID;
                l_eam_mat_req_tbl(n).COMMENTS := matreqrec.COMMENTS;
                l_eam_mat_req_tbl(n).ATTRIBUTE_CATEGORY := matreqrec.ATTRIBUTE_CATEGORY;
                l_eam_mat_req_tbl(n).ATTRIBUTE1 := matreqrec.ATTRIBUTE1;
                l_eam_mat_req_tbl(n).ATTRIBUTE2 := matreqrec.ATTRIBUTE2;
                l_eam_mat_req_tbl(n).ATTRIBUTE3 := matreqrec.ATTRIBUTE3;
                l_eam_mat_req_tbl(n).ATTRIBUTE4 := matreqrec.ATTRIBUTE4;
                l_eam_mat_req_tbl(n).ATTRIBUTE5 := matreqrec.ATTRIBUTE5;
                l_eam_mat_req_tbl(n).ATTRIBUTE6 := matreqrec.ATTRIBUTE6;
                l_eam_mat_req_tbl(n).ATTRIBUTE7 := matreqrec.ATTRIBUTE7;
                l_eam_mat_req_tbl(n).ATTRIBUTE8 := matreqrec.ATTRIBUTE8;
                l_eam_mat_req_tbl(n).ATTRIBUTE9 := matreqrec.ATTRIBUTE9;
                l_eam_mat_req_tbl(n).ATTRIBUTE10 := matreqrec.ATTRIBUTE10;
                l_eam_mat_req_tbl(n).ATTRIBUTE11 := matreqrec.ATTRIBUTE11;
                l_eam_mat_req_tbl(n).ATTRIBUTE12 := matreqrec.ATTRIBUTE12;
                l_eam_mat_req_tbl(n).ATTRIBUTE13 := matreqrec.ATTRIBUTE13;
                l_eam_mat_req_tbl(n).ATTRIBUTE14 := matreqrec.ATTRIBUTE14;
                l_eam_mat_req_tbl(n).ATTRIBUTE15 := matreqrec.ATTRIBUTE15;
                l_eam_mat_req_tbl(n).RETURN_STATUS := matreqrec.RETURN_STATUS;
                l_eam_mat_req_tbl(n).TRANSACTION_TYPE := matreqrec.TRANSACTION_TYPE;

    end loop;

        delete bom_explosion_temp
         where group_id = l_group_id;

    declare
      l_owning_department number;
      l_min_op_seq_num    number;
    begin

      if l_eam_op_tbl.count = 0 and l_eam_wo_rec.status_type = 3 then
      -- create a default operation

        l_owning_department := p_eam_wo_rec.owning_department;
        if p_eam_wo_rec.owning_department is null then
          WIP_EAMWORKORDER_PVT.Get_EAM_Owning_Dept_Default
          (   p_api_version               => 1.0,
              p_init_msg_list             => FND_API.G_FALSE,
              p_commit                    => FND_API.G_FALSE,
              p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
              x_return_status             => l_def_return_status,
              x_msg_count                 => l_def_msg_count,
              x_msg_data                  => l_def_msg_data,
              p_primary_item_id           => p_eam_wo_rec.asset_activity_id,
              p_organization_id           => p_eam_wo_rec.organization_id,
              p_maintenance_object_type   => p_eam_wo_rec.maintenance_object_type,
              p_maintenance_object_id     => p_eam_wo_rec.maintenance_object_id,
              p_rebuild_item_id           => p_eam_wo_rec.rebuild_item_id,
              x_owning_department_id      => l_owning_department
          );
          l_eam_op_tbl(1).department_id := l_owning_department;
        end if;

        l_eam_op_tbl(1).WIP_ENTITY_ID                 := p_eam_wo_rec.wip_entity_id;
        l_eam_op_tbl(1).ORGANIZATION_ID               := p_eam_wo_rec.organization_id;
        l_eam_op_tbl(1).OPERATION_SEQ_NUM             := 10;
        l_eam_op_tbl(1).STANDARD_OPERATION_ID         := null;
        l_eam_op_tbl(1).DEPARTMENT_ID                 := l_owning_department;
        l_eam_op_tbl(1).OPERATION_SEQUENCE_ID         := null;
        fnd_message.set_name('EAM', 'EAM_WO_DEFAULT_OP');
        l_eam_op_tbl(1).DESCRIPTION                   := SUBSTRB(fnd_message.get, 1, 240);
        l_eam_op_tbl(1).MINIMUM_TRANSFER_QUANTITY     := 1;
        l_eam_op_tbl(1).COUNT_POINT_TYPE              := 1;
        l_eam_op_tbl(1).BACKFLUSH_FLAG                := 1;
        l_eam_op_tbl(1).SHUTDOWN_TYPE                 := null;
        l_eam_op_tbl(1).START_DATE                    := p_eam_wo_rec.scheduled_start_date;
        l_eam_op_tbl(1).COMPLETION_DATE               := p_eam_wo_rec.scheduled_completion_date;
        l_eam_op_tbl(1).TRANSACTION_TYPE              := 1;
        l_eam_op_tbl(1).return_status                 := null;

      end if;

      if l_eam_op_tbl.count <> 0 then

        l_min_op_seq_num := l_eam_op_tbl(1).operation_seq_num;
        l_owning_department := l_eam_op_tbl(1).department_id;
        for i in l_eam_op_tbl.first .. l_eam_op_tbl.last loop
        if l_eam_op_tbl(i).operation_seq_num < l_min_op_seq_num then
          l_min_op_seq_num := l_eam_op_tbl(i).operation_seq_num;
          l_owning_department := l_eam_op_tbl(i).department_id;
        end if;
        end loop;

      end if;

      if l_eam_mat_req_tbl.count <> 0 and l_eam_op_tbl.count <> 0 then

        for i in l_eam_mat_req_tbl.first .. l_eam_mat_req_tbl.last loop
        if l_eam_mat_req_tbl(i).operation_seq_num = 1 then
          l_eam_mat_req_tbl(i).operation_seq_num := l_min_op_seq_num;
          l_eam_mat_req_tbl(i).department_id := l_owning_department;
        end if;
        end loop;

      end if;

    end;


    x_return_status := fnd_api.g_ret_sts_success;

    exception
      when others then
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('EAM', 'EAM_UNEXPECTED_ERROR');
        fnd_message.set_token('ERROR_TEXT', SQLERRM);

    end;


IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug('Activity Explosion completed'); end if;

    begin

        select bill_sequence_id
          into l_bill_sequence_id
          from bom_bill_of_materials
         where organization_id= l_eam_wo_rec.organization_id
           and assembly_item_id = l_eam_wo_rec.asset_activity_id
           and (l_eam_wo_rec.alternate_bom_designator is null
            or (l_eam_wo_rec.alternate_bom_designator is not null
           and alternate_bom_designator = l_eam_wo_rec.alternate_bom_designator));

     -- Fix for Bug 2787347  Activities having routing and no BOM are failing
    exception

         when others then
       IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug('BOM not present hence no attachments need to be copied from Activity BOM'); end if;

       x_return_status := fnd_api.g_ret_sts_success;

    -- Fix for Bug 2787347  Activities having routing and no BOM are failing

    end;


IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug('Coping attachment'); end if;

    COPY_ATTACHMENT
    ( p_organization_id                => l_eam_wo_rec.organization_id
    , p_asset_activity_id              => l_eam_wo_rec.asset_activity_id
    , p_wip_entity_id                  => l_eam_wo_rec.wip_entity_id
    , p_bill_sequence_id               => l_bill_sequence_id
    , x_error_message                  => l_other_message
    , x_return_status                  => l_return_status
    );

  --Bug#3342391 : Calling copy attachment for each of the operations exploded from the asset activity.
  FOR activityOpRec IN ActivityOP LOOP
    l_common_routing_seq_id := activityOpRec.COMMON_ROUTING_SEQUENCE_ID ;
    l_organization_id := activityOpRec.ORGANIZATION_ID;
    l_wip_entity_id := activityOpRec.WIP_ENTITY_ID;
    l_routing_available := 'Y';

    COPY_ATTACHMENT
    ( p_organization_id                => l_organization_id
    , p_asset_activity_id              => NULL
    , p_wip_entity_id                  => l_wip_entity_id
    , p_bill_sequence_id               => NULL
    , x_error_message                  => l_other_message
    , x_return_status                  => l_return_status
    , p_common_routing_sequence_id     => NULL
    , p_operation_sequence_id          => activityOpRec.OPERATION_SEQUENCE_ID
    , p_operation_sequence_num         => activityOpRec.OPERATION_SEQ_NUM
    );

  END LOOP;

   --Bug#3342391 : The copy attachment procedure is being called to copy the attachments attached to the routing
   IF (l_routing_available = 'Y') THEN
     COPY_ATTACHMENT
      ( p_organization_id                => l_organization_id
      , p_asset_activity_id              => NULL
      , p_wip_entity_id                  => l_wip_entity_id
      , p_bill_sequence_id               => NULL
      , x_error_message                  => l_other_message
      , x_return_status                  => l_return_status
      , p_common_routing_sequence_id     => l_common_routing_seq_id
      , p_operation_sequence_id          => NULL
      , p_operation_sequence_num         => NULL
      );
    END IF;

        x_eam_wo_rec                   := l_eam_wo_rec;
        x_eam_op_tbl                   := l_eam_op_tbl;
        x_eam_op_network_tbl           := l_eam_op_network_tbl;
        x_eam_res_tbl                  := l_eam_res_tbl;
        x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
        x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
        x_eam_mat_req_tbl              := l_eam_mat_req_tbl;

END EXPLODE_ACTIVITY;


--Bug#3342391: Modified the function definition to pass 3 new parameters and default it to null
--    for backward compatibility.The parameters contain the operation_sequence_id and operations_sequence_number
--    and common_routing_sequence_id
PROCEDURE COPY_ATTACHMENT
( p_organization_id         IN  NUMBER
, p_asset_activity_id       IN  NUMBER
, p_wip_entity_id           IN  NUMBER
, p_bill_sequence_id        IN  NUMBER
, x_error_message           OUT NOCOPY VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, p_common_routing_sequence_id IN NUMBER := NULL
, p_operation_sequence_id  IN NUMBER := NULL
, p_operation_sequence_num IN NUMBER := NULL
)
IS

begin

if (p_asset_activity_id) is not null then

  fnd_attached_documents2_pkg.copy_attachments(
    X_from_entity_name      =>  'MTL_SYSTEM_ITEMS',
    X_from_pk1_value        =>  p_organization_id,
    X_from_pk2_value        =>  p_asset_activity_id,
    X_from_pk3_value        =>  '',
    X_from_pk4_value        =>  '',
    X_from_pk5_value        =>  '',
    X_to_entity_name        =>  'EAM_WORK_ORDERS',
    X_to_pk1_value          =>  p_organization_id,
    X_to_pk2_value          =>  p_wip_entity_id,
    X_to_pk3_value          =>  '',
    X_to_pk4_value          =>  '',
    X_to_pk5_value          =>  '',
    X_created_by            =>  FND_GLOBAL.USER_ID,
    X_last_update_login     =>  '',
    X_program_application_id=>  '',
    X_program_id            =>  '',
    X_request_id            =>  ''
     );

end if;

if (p_bill_sequence_id) is not null then

   fnd_attached_documents2_pkg.copy_attachments(
    X_from_entity_name      =>  'BOM_BILL_OF_MATERIALS',
    X_from_pk1_value        =>  p_bill_sequence_id,
    X_from_pk2_value        =>  '',
    X_from_pk3_value        =>  '',
    X_from_pk4_value        =>  '',
    X_from_pk5_value        =>  '',
    X_to_entity_name        =>  'EAM_WORK_ORDERS',
    X_to_pk1_value          =>  p_organization_id,
    X_to_pk2_value          =>  p_wip_entity_id,
    X_to_pk3_value          =>  '',
    X_to_pk4_value          =>  '',
    X_to_pk5_value          =>  '',
    X_created_by            =>  FND_GLOBAL.USER_ID,
    X_last_update_login     =>  '',
    X_program_application_id=>  '',
    X_program_id            =>  '',
    X_request_id            =>  ''
     );
end if;

--Bug#3342391: Adding the code to copy the attachment from the routing header and each of the operations under it.
  IF (p_common_routing_sequence_id) IS NOT NULL THEN
    -- Copy the attachment from the routing header.
    FND_ATTACHED_DOCUMENTS2_PKG.COPY_ATTACHMENTS(
	X_from_entity_name      =>  'BOM_OPERATIONAL_ROUTINGS',
	X_from_pk1_value        =>  p_common_routing_sequence_id,
	X_from_pk2_value        =>  '',
	X_from_pk3_value        =>  '',
	X_from_pk4_value        =>  '',
	X_from_pk5_value        =>  '',
	X_to_entity_name        =>  'EAM_WORK_ORDERS',
	X_to_pk1_value          =>  p_organization_id,
	X_to_pk2_value          =>  p_wip_entity_id,
	X_to_pk3_value          =>  '',
	X_to_pk4_value          =>  '',
	X_to_pk5_value          =>  '',
	X_created_by            =>  FND_GLOBAL.USER_ID,
	X_last_update_login     =>  '',
	X_program_application_id=>  '',
	X_program_id            =>  '',
	X_request_id            =>  ''
	 );
   END IF;

   -- Copy the attachment for each of the operations
   IF p_operation_sequence_id IS NOT NULL THEN
			   FND_ATTACHED_DOCUMENTS2_PKG.COPY_ATTACHMENTS(
			    X_from_entity_name      =>  'BOM_OPERATION_SEQUENCES',
			    X_from_pk1_value        =>  p_operation_sequence_id,
			    X_from_pk2_value        =>  '',
			    X_from_pk3_value        =>  '',
			    X_from_pk4_value        =>  '',
			    X_from_pk5_value        =>  '',
			    X_to_entity_name        =>  'EAM_DISCRETE_OPERATIONS',
			    X_to_pk1_value          =>  p_wip_entity_id,
			    X_to_pk2_value          =>  p_operation_sequence_num ,
			    X_to_pk3_value          =>  p_organization_id,
			    X_to_pk4_value          =>  '',
			    X_to_pk5_value          =>  '',
			    X_created_by            =>  FND_GLOBAL.USER_ID,
                            X_last_update_login     =>  '',
			    X_program_application_id=>  '',
			    X_program_id            =>  '',
			    X_request_id            =>  ''
			    );

    END IF;


    x_return_status := fnd_api.g_ret_sts_success;

    exception
      when others then
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('EAM', 'EAM_UNEXPECTED_ERROR');
        fnd_message.set_token('ERROR_TEXT', SQLERRM);

END COPY_ATTACHMENT;


END EAM_EXPLODE_ACTIVITY_PVT;

/
