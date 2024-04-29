--------------------------------------------------------
--  DDL for Package Body EAM_WO_DEFAULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WO_DEFAULT_PVT" AS
/* $Header: EAMVWODB.pls 120.23.12010000.3 2012/03/06 13:04:58 vboddapa ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWODB.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_WO_DEFAULT_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
--  15-May-2005    Anju Gupta		  Changes for IB/Transactable Assets
***************************************************************************/
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'EAM_WO_DEFAULT_PVT';

        /********************************************************************
        * Function      : get_wip_entity_id
        * Return        : NUMBER
        * Purpose       : Function will return wip_entity_id
        *
        **********************************************************************/


	FUNCTION get_wip_entity_id
        RETURN NUMBER
        IS
                l_wip_entity_id      NUMBER := NULL;
        BEGIN

                SELECT wip_entities_s.nextval
                INTO   l_wip_entity_id
                FROM   dual;

                RETURN l_wip_entity_id;

         EXCEPTION
                WHEN OTHERS THEN
                        RETURN NULL;

        END get_wip_entity_id;



        /********************************************************************
        * Function      : get_wip_entity_name_prefix
        * Return        : VARCHAR2
        * Purpose       : Function will return wip_entity_name_prefix
        *
        **********************************************************************/

        FUNCTION get_wip_entity_name_prefix
          (  p_organization_id IN  NUMBER
          )
        RETURN VARCHAR2
        IS
                l_wip_entity_name_prefix      VARCHAR2(30) := NULL;
        BEGIN

                SELECT work_order_prefix
                INTO   l_wip_entity_name_prefix
                FROM   wip_eam_parameters
                WHERE  organization_id = p_organization_id;

                RETURN l_wip_entity_name_prefix;

         EXCEPTION
                WHEN OTHERS THEN
                        RETURN NULL;

        END get_wip_entity_name_prefix;



        /********************************************************************
        * Function      : get_wip_entity_name
        * Return        : VARCHAR2
        * Purpose       : Function will return new work order name
        *
        **********************************************************************/

        FUNCTION get_wip_entity_name(p_org_id NUMBER,p_plan_maintenance VARCHAR2)
        RETURN VARCHAR2
        IS
                l_wip_entity_name      VARCHAR2(240) := NULL;
		l_wip_entity_count     NUMBER :=0;
		l_wip_entity_name_prefix      VARCHAR2(30) := NULL;
        BEGIN

		 IF nvl(p_plan_maintenance,'N') <> 'Y' THEN
			l_wip_entity_name_prefix :=get_wip_entity_name_prefix(p_org_id);
		END IF;
	LOOP
                SELECT wip_job_number_s.nextval
                INTO   l_wip_entity_name
                FROM   dual;

		l_wip_entity_name :=  l_wip_entity_name_prefix || l_wip_entity_name;

		select  count(*) into l_wip_entity_count from wip_entities
		where organization_id = p_org_id and wip_entity_name =l_wip_entity_name
		and rownum <= 1;

	EXIT WHEN l_wip_entity_count=0;
	END LOOP;

	 RETURN l_wip_entity_name;
         EXCEPTION
                WHEN OTHERS THEN
                        RETURN NULL;
        END get_wip_entity_name;




        /********************************************************************
        * Procedure     : get_flex_eam_wo
        **********************************************************************/


        PROCEDURE get_flex_eam_wo
          (  p_eam_wo_rec IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
           , x_eam_wo_rec OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
          )
        IS
        BEGIN

            --  In the future call Flex APIs for defaults
                x_eam_wo_rec := p_eam_wo_rec;

                IF p_eam_wo_rec.attribute_category =FND_API.G_MISS_CHAR THEN
                        x_eam_wo_rec.attribute_category := NULL;
                END IF;

                IF p_eam_wo_rec.attribute1 = FND_API.G_MISS_CHAR THEN
                        x_eam_wo_rec.attribute1  := NULL;
                END IF;

                IF p_eam_wo_rec.attribute2 = FND_API.G_MISS_CHAR THEN
                        x_eam_wo_rec.attribute2  := NULL;
                END IF;

                IF p_eam_wo_rec.attribute3 = FND_API.G_MISS_CHAR THEN
                        x_eam_wo_rec.attribute3  := NULL;
                END IF;

                IF p_eam_wo_rec.attribute4 = FND_API.G_MISS_CHAR THEN
                        x_eam_wo_rec.attribute4  := NULL;
                END IF;

                IF p_eam_wo_rec.attribute5 = FND_API.G_MISS_CHAR THEN
                        x_eam_wo_rec.attribute5  := NULL;
                END IF;

                IF p_eam_wo_rec.attribute6 = FND_API.G_MISS_CHAR THEN
                        x_eam_wo_rec.attribute6  := NULL;
                END IF;

                IF p_eam_wo_rec.attribute7 = FND_API.G_MISS_CHAR THEN
                        x_eam_wo_rec.attribute7  := NULL;
                END IF;

                IF p_eam_wo_rec.attribute8 = FND_API.G_MISS_CHAR THEN
                        x_eam_wo_rec.attribute8  := NULL;
                END IF;

                IF p_eam_wo_rec.attribute9 = FND_API.G_MISS_CHAR THEN
                        x_eam_wo_rec.attribute9  := NULL;
                END IF;

                IF p_eam_wo_rec.attribute10 = FND_API.G_MISS_CHAR THEN
                        x_eam_wo_rec.attribute10 := NULL;
                END IF;

                IF p_eam_wo_rec.attribute11 = FND_API.G_MISS_CHAR THEN
                        x_eam_wo_rec.attribute11 := NULL;
                END IF;

                IF p_eam_wo_rec.attribute12 = FND_API.G_MISS_CHAR THEN
                        x_eam_wo_rec.attribute12 := NULL;
                END IF;

                IF p_eam_wo_rec.attribute13 = FND_API.G_MISS_CHAR THEN
                        x_eam_wo_rec.attribute13 := NULL;
                END IF;

                IF p_eam_wo_rec.attribute14 = FND_API.G_MISS_CHAR THEN
                        x_eam_wo_rec.attribute14 := NULL;
                END IF;

                IF p_eam_wo_rec.attribute15 = FND_API.G_MISS_CHAR THEN
                        x_eam_wo_rec.attribute15 := NULL;
                END IF;

        END get_flex_eam_wo;


        /*********************************************************************
        * Procedure     : Attribute_Defaulting
        * Parameters IN : Work Order record
        * Parameters OUT NOCOPY: Work Order record after defaulting
        *                 Mesg_Token_Table
        *                 Return_Status
        * Purpose       : Attribute Defaulting will default the necessary null
        *                 attribute with appropriate values.
        **********************************************************************/

        PROCEDURE Attribute_Defaulting
        (  p_eam_wo_rec          IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
	, p_old_eam_wo_rec          IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_eam_wo_rec          OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status           OUT NOCOPY VARCHAR2
         )
        IS
          l_err_text              VARCHAR2(2000) := NULL;
          l_return_status         VARCHAR2(2);
          l_msg_count             NUMBER;
          l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
          l_out_Mesg_Token_Tbl    EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
          l_out_eam_wo_rec        EAM_PROCESS_WO_PUB.eam_wo_rec_type;
          l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
          l_job_type              NUMBER := 1;

          l_owning_department             NUMBER;
          l_priority                      NUMBER;
          l_material_account              NUMBER;
          l_material_overhead_account     NUMBER;
          l_resource_account              NUMBER;
          l_outside_processing_account    NUMBER;
          l_material_variance_account     NUMBER;
          l_resource_variance_account     NUMBER;
          l_osp_var_account               NUMBER;
          l_std_cost_adjustment_account   NUMBER;
          l_overhead_account              NUMBER;
          l_overhead_variance_account     NUMBER;
          l_issue_zero_cost_flag          VARCHAR2(1);

          l_class_code                    VARCHAR2(10);
          l_activity_cause                VARCHAR2(30);
          l_activity_type                 VARCHAR2(30);
          l_activity_source               VARCHAR2(30);
          l_shutdown_type                 VARCHAR2(30);
          l_notification_required         VARCHAR2(1);
          l_tagout_required               VARCHAR2(1);
          l_auto_firm_flag                VARCHAR2(10);
    	  l_activity_description	  VARCHAR2(240);


	  l_old_eam_wo_rec                EAM_PROCESS_WO_PUB.eam_wo_rec_type;
	  l_auto_firm_create_flag         VARCHAR2(1);

        BEGIN


		 EAM_WO_UTILITY_PVT.Query_Row(
                  p_wip_entity_id       => p_eam_wo_rec.wip_entity_id
                , p_organization_id     => p_eam_wo_rec.organization_id
                , x_eam_wo_rec          => l_old_eam_wo_rec
                , x_Return_status       => l_return_status
                );


                x_eam_wo_rec := p_eam_wo_rec;
                x_return_status := FND_API.G_RET_STS_SUCCESS;

                IF p_eam_wo_rec.wip_entity_id IS NULL OR
                   p_eam_wo_rec.wip_entity_id = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.wip_entity_id :=get_wip_entity_id;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('new wip_entity_id : ' || to_char(x_eam_wo_rec.wip_entity_id)); END IF;

                END IF;

                IF p_eam_wo_rec.wip_entity_name IS NULL OR
                   p_eam_wo_rec.wip_entity_name = FND_API.G_MISS_CHAR
                THEN
                      x_eam_wo_rec.wip_entity_name := get_wip_entity_name(p_eam_wo_rec.organization_id,p_eam_wo_rec.plan_maintenance);



IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('new wip_entity_name : ' || x_eam_wo_rec.wip_entity_name); END IF;

                END IF;

                -- Finding out whether Asset or Rebuild WO
                IF p_eam_wo_rec.maintenance_object_type = 2 THEN
                  -- Rebuild
                  l_job_type := 2;
                ELSIF p_eam_wo_rec.maintenance_object_type = 3 THEN
                  IF p_eam_wo_rec.rebuild_item_id is not null THEN
                    l_job_type :=2;
                  ELSE
                    l_job_type :=1;
                  END IF;
                END IF;


		IF (   p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
		            AND p_eam_wo_rec.class_code is null )
	        THEN
                        WIP_EAM_UTILS.DEFAULT_ACC_CLASS(
                         p_org_id            => p_eam_wo_rec.organization_id,
                         p_job_type          => l_job_type,
                         p_serial_number     => nvl(p_eam_wo_rec.rebuild_serial_number, p_eam_wo_rec.asset_number),
                         p_asset_group_id    => nvl(p_eam_wo_rec.rebuild_item_id, p_eam_wo_rec.asset_group_id),
                         p_parent_wo_id      => p_eam_wo_rec.parent_wip_entity_id,
                         p_asset_activity_id => p_eam_wo_rec.asset_activity_id,
                         p_project_id        => p_eam_wo_rec.project_id,
                         p_task_id           => p_eam_wo_rec.task_id,
                         x_class_code        => l_class_code,
                         x_return_status     => l_return_status,
                         x_msg_data          => l_err_text
                        );

                   IF l_class_code IS NOT NULL AND
                       l_class_code <> FND_API.G_MISS_CHAR
                   THEN
                      -- Default the WIP ACC Class
                       x_eam_wo_rec.class_code := l_class_code;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('new class_code : ' || x_eam_wo_rec.class_code); END IF;
                    END IF;

                END IF;

		IF p_eam_wo_rec.asset_activity_id is not null THEN

		/* Defaulting logic of work order description from activity description for bug# 3418828 */

		   IF ( p_eam_wo_rec.description IS NULL
			and p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE )
		   THEN
		        begin
				 SELECT description
				 INTO   l_activity_description
				 FROM   MTL_SYSTEM_ITEMS_KFV MSI, MTL_PARAMETERS MP
				 WHERE  MSI.inventory_item_id = p_eam_wo_rec.asset_activity_id
				 AND    MSI.organization_id = MP.ORGANIZATION_ID
				 AND    MP.MAINT_ORGANIZATION_ID = p_eam_wo_rec.organization_id
                                 AND rownum = 1;

				 x_eam_wo_rec.description := l_activity_description;

				 EXCEPTION
				 	WHEN OTHERS THEN
						NULL;
			 end;
		   END IF;

		/* end of fix */

                IF ( p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE /*OR
		        (p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE AND
			    NVL(p_eam_wo_rec.asset_activity_id,-1) <> NVL(l_old_eam_wo_rec.asset_activity_id,-1)) commented for BUG#5609642 */ ) THEN   --default if new workorder or activity is changed

														WIP_EAMWORKORDER_PVT.Get_EAM_Act_Cause_Default
														      (p_api_version               => 1,
														       p_init_msg_list             => FND_API.G_FALSE,
														       p_commit                    => FND_API.G_FALSE,
														       p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
														       x_return_status             => l_return_status,
														       x_msg_count                 => l_msg_count,
														       x_msg_data                  => l_err_text,
														       p_primary_item_id           => p_eam_wo_rec.asset_activity_id,
														       p_organization_id           => p_eam_wo_rec.organization_id,
														       p_maintenance_object_type   => p_eam_wo_rec.maintenance_object_type,
														       p_maintenance_object_id     => p_eam_wo_rec.maintenance_object_id,
														       p_rebuild_item_id           => p_eam_wo_rec.rebuild_item_id,
														       x_activity_cause_code       => l_activity_cause
														      );

														  IF l_activity_cause IS NOT NULL AND
														     l_activity_cause <> FND_API.G_MISS_CHAR AND
														     p_eam_wo_rec.activity_cause IS NULL /* Added for BUG#5609642 */
														  THEN
														    x_eam_wo_rec.activity_cause := l_activity_cause;

												IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('new activity_cause : ' || x_eam_wo_rec.activity_cause); END IF;
														  END IF;

														    WIP_EAMWORKORDER_PVT.Get_EAM_Act_Type_Default
														      (p_api_version               => 1,
														       p_init_msg_list             => FND_API.G_FALSE,
														       p_commit                    => FND_API.G_FALSE,
														       p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
														       x_return_status             => l_return_status,
														       x_msg_count                 => l_msg_count,
														       x_msg_data                  => l_err_text,
														       p_primary_item_id           => p_eam_wo_rec.asset_activity_id,
														       p_organization_id           => p_eam_wo_rec.organization_id,
														       p_maintenance_object_type   => p_eam_wo_rec.maintenance_object_type,
														       p_maintenance_object_id     => p_eam_wo_rec.maintenance_object_id,
														       p_rebuild_item_id           => p_eam_wo_rec.rebuild_item_id,
														       x_activity_type_code        => l_activity_type
														    );

														  IF l_activity_type IS NOT NULL AND
														     l_activity_type <> FND_API.G_MISS_CHAR AND
														     p_eam_wo_rec.activity_source IS NULL /* Added for BUG#5609642 */
														  THEN
														    x_eam_wo_rec.activity_type := l_activity_type;
												IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('new activity_type : ' || x_eam_wo_rec.activity_type); END IF;
														  END IF;

														    WIP_EAMWORKORDER_PVT.Get_EAM_Act_Source_Default
														      (p_api_version               => 1,
														       p_init_msg_list             => FND_API.G_FALSE,
														       p_commit                    => FND_API.G_FALSE,
														       p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
														       x_return_status             => l_return_status,
														       x_msg_count                 => l_msg_count,
														       x_msg_data                  => l_err_text,
														       p_primary_item_id           => p_eam_wo_rec.asset_activity_id,
														       p_organization_id           => p_eam_wo_rec.organization_id,
														       p_maintenance_object_type   => p_eam_wo_rec.maintenance_object_type,
														       p_maintenance_object_id     => p_eam_wo_rec.maintenance_object_id,
														       p_rebuild_item_id           => p_eam_wo_rec.rebuild_item_id,
														       x_activity_source_code      => l_activity_source
														    );

														  IF l_activity_source IS NOT NULL AND
														     l_activity_source <> FND_API.G_MISS_CHAR AND
														     p_eam_wo_rec.activity_source IS NULL /* Added for BUG#5609642 */
														  THEN
														    x_eam_wo_rec.activity_source := l_activity_source;
												IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('new activity_source : ' || x_eam_wo_rec.activity_source); END IF;
														  END IF;

														    WIP_EAMWORKORDER_PVT.Get_EAM_Shutdown_Default
														      (p_api_version               => 1,
														       p_init_msg_list             => FND_API.G_FALSE,
														       p_commit                    => FND_API.G_FALSE,
														       p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
														       x_return_status             => l_return_status,
														       x_msg_count                 => l_msg_count,
														       x_msg_data                  => l_err_text,
														       p_primary_item_id           => p_eam_wo_rec.asset_activity_id,
														       p_organization_id           => p_eam_wo_rec.organization_id,
														       p_maintenance_object_type   => p_eam_wo_rec.maintenance_object_type,
														       p_maintenance_object_id     => p_eam_wo_rec.maintenance_object_id,
														       p_rebuild_item_id           => p_eam_wo_rec.rebuild_item_id,
														       x_shutdown_type_code        => l_shutdown_type
														    );

														  IF l_shutdown_type IS NOT NULL AND
														     l_shutdown_type <> FND_API.G_MISS_CHAR AND
														      p_eam_wo_rec.shutdown_type IS NULL /* Added for BUG#5609642 */
														  THEN
														    x_eam_wo_rec.shutdown_type := l_shutdown_type;
												IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('new shutdown_type : ' || x_eam_wo_rec.shutdown_type); END IF;
														  END IF;

														    WIP_EAMWORKORDER_PVT.Get_EAM_Notification_Default
														      (p_api_version               => 1,
														       p_init_msg_list             => FND_API.G_FALSE,
														       p_commit                    => FND_API.G_FALSE,
														       p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
														       x_return_status             => l_return_status,
														       x_msg_count                 => l_msg_count,
														       x_msg_data                  => l_err_text,
														       p_primary_item_id           => p_eam_wo_rec.asset_activity_id,
														       p_organization_id           => p_eam_wo_rec.organization_id,
														       p_maintenance_object_type   => p_eam_wo_rec.maintenance_object_type,
														       p_maintenance_object_id     => p_eam_wo_rec.maintenance_object_id,
														       p_rebuild_item_id           => p_eam_wo_rec.rebuild_item_id,
														       x_notification_flag         => l_notification_required
														    );

														  IF l_notification_required IS NOT NULL AND
														     l_notification_required <> FND_API.G_MISS_CHAR AND
														     p_eam_wo_rec.notification_required IS NULL /* Added for BUG#5609642 */
														  THEN
														    x_eam_wo_rec.notification_required := l_notification_required;
												IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('new notification_required : ' || x_eam_wo_rec.notification_required); END IF;
														  END IF;

														    WIP_EAMWORKORDER_PVT.Get_EAM_Tagout_Default
														      (p_api_version               => 1,
														       p_init_msg_list             => FND_API.G_FALSE,
														       p_commit                    => FND_API.G_FALSE,
														       p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
														       x_return_status             => l_return_status,
														       x_msg_count                 => l_msg_count,
														       x_msg_data                  => l_err_text,
														       p_primary_item_id           => p_eam_wo_rec.asset_activity_id,
														       p_organization_id           => p_eam_wo_rec.organization_id,
														       p_maintenance_object_type   => p_eam_wo_rec.maintenance_object_type,
														       p_maintenance_object_id     => p_eam_wo_rec.maintenance_object_id,
														       p_rebuild_item_id           => p_eam_wo_rec.rebuild_item_id,
														       x_tagout_required           => l_tagout_required
														    );

														  IF l_tagout_required IS NOT NULL AND
														     l_tagout_required <> FND_API.G_MISS_CHAR AND
														     p_eam_wo_rec.tagout_required IS NULL /* Added for BUG#5609642 */
														  THEN
														    x_eam_wo_rec.tagout_required := l_tagout_required;
												IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('new tagout_default : ' || x_eam_wo_rec.tagout_required); END IF;
														  END IF;
                                  END IF;          --end of check for activity changed or workorder created
               END IF; -- End if for 'IF asset_activity_id_id is not null'



IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Defaulting owning department, priority, etc'); END IF;

                -- Defaulting Owning Dept, Priority.

		IF p_eam_wo_rec.asset_activity_id IS NOT NULL AND p_eam_wo_rec.asset_activity_id <> FND_API.G_MISS_NUM
                THEN
                    -- WO with Activity

											 IF ( p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE /* OR
												(p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE AND
												    NVL(p_eam_wo_rec.asset_activity_id,-1) <> NVL(l_old_eam_wo_rec.asset_activity_id,-1))Commented for BUG#5609642 */ ) THEN   --default if new workorder or activity is changed
											  BEGIN

											    IF p_eam_wo_rec.maintenance_object_type = 3
											    THEN
																					    -- Asset or Serialized Rebuild with activity
																					    SELECT
																						   nvl(p_eam_wo_rec.owning_department, nvl(eomd.owning_department_id, eomd_asset.owning_department_id))
																						 , nvl(p_eam_wo_rec.priority, meaa.priority_code)
																					    INTO
																						   l_owning_department
																						 , l_priority
																					    FROM
																						   mtl_eam_asset_activities meaa
																						 , eam_org_maint_defaults eomd
																						 , eam_org_maint_defaults eomd_asset
																					    WHERE
																						   meaa.maintenance_object_type = 3
																					      AND  eomd.object_type (+) = 60
																					      AND  eomd.object_id (+) = meaa.activity_association_id
																					      AND  eomd_asset.object_type (+) = 50
																					      AND  eomd_asset.organization_id (+) = p_eam_wo_rec.organization_id
																					      AND  eomd_asset.object_id (+) =  meaa.maintenance_object_id
																					      AND  meaa.asset_activity_id = p_eam_wo_rec.asset_activity_id
																					      AND  eomd.organization_id (+) = p_eam_wo_rec.organization_id
																					      AND  meaa.maintenance_object_id = p_eam_wo_rec.maintenance_object_id;


																					    IF l_owning_department IS NOT NULL AND
																					       l_owning_department <> FND_API.G_MISS_NUM AND
																					       p_eam_wo_rec.owning_department IS NULL /* Added for BUG#5609642 */
																					       THEN
																					      x_eam_wo_rec.owning_department := l_owning_department;
																					    END IF;

																					IF x_eam_wo_rec.owning_department IS NULL THEN
																						select default_department_id into x_eam_wo_rec.owning_department
																						  from WIP_EAM_PARAMETERS
																						  where organization_id = p_eam_wo_rec.organization_id;
																					    END IF;

																					    IF l_priority IS NOT NULL AND
																					       l_priority <> FND_API.G_MISS_NUM AND
																					        p_eam_wo_rec.priority IS NULL /* Added for BUG#5609642 */
																					       THEN
																					      x_eam_wo_rec.priority := l_priority;
																					    END IF;

											    ELSE
											    -- Rebuild with activity

																					      IF p_eam_wo_rec.maintenance_object_type = 2 THEN
																					      -- Non Serialized rebuild
																						SELECT
																						   nvl(p_eam_wo_rec.owning_department, eomd.owning_department_id)
																						 , nvl(p_eam_wo_rec.priority, meaa.priority_code)
																						INTO
																						   l_owning_department
																						 , l_priority
																						FROM
																						   mtl_eam_asset_activities meaa,
																						   eam_org_maint_defaults eomd
																						WHERE
																						       meaa.asset_activity_id = p_eam_wo_rec.asset_activity_id
																						  AND  eomd.object_type (+) = 40
																						  and  eomd.organization_id (+) = p_eam_wo_rec.organization_id
																						  and  eomd.object_id (+) = meaa.activity_association_id
																						  AND  meaa.maintenance_object_type = 2
																					  and  meaa.maintenance_object_id = p_eam_wo_rec.maintenance_object_id;

																						IF l_owning_department IS NOT NULL AND
																						   l_owning_department <> FND_API.G_MISS_NUM AND
																						   p_eam_wo_rec.owning_department IS NULL /* Added for BUG#5609642 */
																						   THEN
																						  x_eam_wo_rec.owning_department := l_owning_department;
																						END IF;

																						IF x_eam_wo_rec.owning_department IS NULL THEN
																								select default_department_id into x_eam_wo_rec.owning_department
																								  from WIP_EAM_PARAMETERS
																								  where organization_id = p_eam_wo_rec.organization_id;
 																					     END IF;

																						IF l_priority IS NOT NULL AND
																						   l_priority <> FND_API.G_MISS_NUM AND
																						   p_eam_wo_rec.priority IS NULL /* Added for BUG#5609642 */
																						   THEN
																						  x_eam_wo_rec.priority := l_priority;
																						END IF;

											    END IF;
											END IF;

											  EXCEPTION
											     WHEN NO_DATA_FOUND THEN

												  l_out_mesg_token_tbl := l_mesg_token_tbl;
												  EAM_ERROR_MESSAGE_PVT.Add_Error_Token
												  (  p_message_name  => 'EAM_WO_ASSET_ACTIVITY_ASSOC'
												   , p_token_tbl     => l_token_tbl
												   , p_mesg_token_tbl     => l_mesg_token_tbl
												   , x_mesg_token_tbl     => l_out_mesg_token_tbl
												   );
												  l_mesg_token_tbl := l_out_mesg_token_tbl;

												  x_return_status := FND_API.G_RET_STS_ERROR;
												  x_mesg_token_tbl := l_mesg_token_tbl ;

											     WHEN OTHERS THEN
												  EAM_ERROR_MESSAGE_PVT.Add_Error_Token
												  (  p_message_name       => NULL
												   , p_message_text       => G_PKG_NAME || SQLERRM
												   , x_mesg_token_Tbl     => x_mesg_token_tbl
												  );

												x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
											  END;
										       END IF;  --end of check for activity changed/workorder created

                ELSIF  x_eam_wo_rec.owning_department IS NULL and (p_eam_wo_rec.maintenance_object_type = 3)
                    -- Asset/Serialized rebuild WO without Activity

                THEN
							SELECT
							   p_eam_wo_rec.priority
							 , nvl(p_eam_wo_rec.owning_department, eomd.owning_department_id)
						    INTO
							   l_priority
							 , l_owning_department
						    FROM
							   csi_item_instances cii,
							   eam_org_maint_defaults eomd
						    WHERE
							   cii.instance_id = p_eam_wo_rec.maintenance_object_id
							   and eomd.object_type (+) = 50
							   and eomd.object_id (+) = cii.instance_id
							   and eomd.organization_id (+) = p_eam_wo_rec.organization_id;

						    IF l_owning_department IS NOT NULL AND
						       l_owning_department <> FND_API.G_MISS_NUM THEN
						      x_eam_wo_rec.owning_department := l_owning_department;
						    END IF;

						    IF l_priority IS NOT NULL AND
						       l_priority <> FND_API.G_MISS_NUM AND
						       p_eam_wo_rec.priority IS NULL /* Added for BUG#5609642 */
							THEN
						      x_eam_wo_rec.priority := l_priority;
						    END IF;

						    IF x_eam_wo_rec.owning_department IS NULL THEN
							select default_department_id into x_eam_wo_rec.owning_department
							  from WIP_EAM_PARAMETERS
							  where organization_id = p_eam_wo_rec.organization_id;
						    END IF;
        END IF;


IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Defaulting accounts'); END IF;


                -- Defaulting Accounts
                BEGIN
                    SELECT
                           material_account
                         , material_overhead_account
                         , resource_account
                         , outside_processing_account
                         , material_variance_account
                         , resource_variance_account
                         , outside_proc_variance_account
                         , std_cost_adjustment_account
                         , overhead_account
                         , overhead_variance_account
                    INTO
                           l_material_account
                         , l_material_overhead_account
                         , l_resource_account
                         , l_outside_processing_account
                         , l_material_variance_account
                         , l_resource_variance_account
                         , l_osp_var_account
                         , l_std_cost_adjustment_account
                         , l_overhead_account
                         , l_overhead_variance_account
                    FROM   wip_accounting_classes
                    WHERE
                           class_code      = x_eam_wo_rec.class_code
                      AND  organization_id = p_eam_wo_rec.organization_id;

                    x_eam_wo_rec.material_account := l_material_account;
                    x_eam_wo_rec.material_overhead_account := l_material_overhead_account;
                    x_eam_wo_rec.resource_account := l_resource_account;
                    x_eam_wo_rec.outside_processing_account := l_outside_processing_account;
                    x_eam_wo_rec.material_variance_account := l_material_variance_account;
                    x_eam_wo_rec.resource_variance_account := l_resource_variance_account;
                    x_eam_wo_rec.outside_proc_variance_account := l_osp_var_account;
                    x_eam_wo_rec.std_cost_adjustment_account := l_std_cost_adjustment_account;
                    x_eam_wo_rec.overhead_account := l_overhead_account;
                    x_eam_wo_rec.overhead_variance_account := l_overhead_variance_account;

                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN

                          l_out_mesg_token_tbl := l_mesg_token_tbl;
                          EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                          (  p_message_name  => 'EAM_WO_CLASS_CODE'
                           , p_token_tbl     => l_token_tbl
                           , p_mesg_token_tbl     => l_mesg_token_tbl
                           , x_mesg_token_tbl     => l_out_mesg_token_tbl
                           );
                          l_mesg_token_tbl := l_out_mesg_token_tbl;

                          x_return_status := FND_API.G_RET_STS_ERROR;
                          x_mesg_token_tbl := l_mesg_token_tbl ;

                     WHEN OTHERS THEN
                          EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                          (  p_message_name       => NULL
                           , p_message_text       => G_PKG_NAME || SQLERRM
                           , x_mesg_token_Tbl     => x_mesg_token_tbl
                          );

                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                  END;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Defaulting USER_DEFINED_STATUS_ID'); END IF;

		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Defaulting USER_DEFINED_STATUS_ID'); END IF;

		 --Default the User_Defined_Status_Id if it is not passed when creating a workorder. OR if system status is modified and neither the user_defined_status nor the pending flag are modfied
		 --Then also set the User_defined_status to the seeded status mapped to the System status
		 IF( p_eam_wo_rec.user_defined_status_id IS NULL  --create and user_defined_staus not provided
			 OR
			      (  p_eam_wo_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_UPDATE --workorder updated
			         AND (p_eam_wo_rec.status_type <> p_old_eam_wo_rec.status_type)   --system status updated
				 --netiher the user_defined_status nor the pending flag are modfied
				 AND NOT((p_eam_wo_rec.user_defined_status_id <> p_old_eam_wo_rec.user_defined_status_id) OR (NVL(p_eam_wo_rec.pending_flag,'N') <> NVL(p_old_eam_wo_rec.pending_flag,'N')))
			      )
		 )THEN
			    x_eam_wo_rec.user_defined_status_id := p_eam_wo_rec.status_type;    --set the user_defined_status_id to status_type since status_id for seeded statuses will be same as status_type

		 END IF; --end of check for defaulting user_defined_status

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Defaulting ISSUE_ZERO_COST_FLAG'); END IF;

                -- Defaulting ISSUE_ZERO_COST_FLAG
                IF p_eam_wo_rec.issue_zero_cost_flag IS NULL OR
                   p_eam_wo_rec.issue_zero_cost_flag = FND_API.G_MISS_CHAR
                THEN
                        SELECT
                               nvl(issue_zero_cost_flag,'N')
                        INTO   x_eam_wo_rec.issue_zero_cost_flag
                        FROM   wip_eam_parameters
                        WHERE  organization_id = p_eam_wo_rec.organization_id;

                END IF;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('PO creation time'); END IF;

                -- Defaulting PO creation time
                IF p_eam_wo_rec.po_creation_time IS NULL OR
                   p_eam_wo_rec.po_creation_time = FND_API.G_MISS_NUM
                THEN
                        SELECT
                               po_creation_time
                        INTO   x_eam_wo_rec.po_creation_time
                        FROM   wip_parameters
                        WHERE  organization_id = p_eam_wo_rec.organization_id;

                END IF;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Defaulting firm planned flag'); END IF;

                -- Defaulting Firm Planned Flag

                IF p_eam_wo_rec.firm_planned_flag IS NULL OR
                   p_eam_wo_rec.firm_planned_flag = FND_API.G_MISS_NUM
                THEN
                    x_eam_wo_rec.firm_planned_flag := 2;

		   -- Defaulting Firm Planned Flag when auto firm flag on create checked.
		   IF p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PUB.G_OPR_CREATE
		   THEN
		      select nvl(auto_firm_on_create,'N') into l_auto_firm_create_flag
                      from wip_eam_parameters
                      where organization_id = p_eam_wo_rec.organization_id;
                     IF l_auto_firm_create_flag = 'Y' THEN
                        x_eam_wo_rec.firm_planned_flag := 1;
                     END IF;
		   END IF;

                END IF;


                -- If updating a WO to relesed status and auto_firm_flag is
                -- turned on, then firm the WO. Also if WO is created directly
                -- in released status and auto firm is ON.
                IF (p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PUB.G_OPR_UPDATE
                    and p_eam_wo_rec.status_type = 3 and
                    l_old_eam_wo_rec.status_type in (1,6,17)
                   )  OR
                   (p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PUB.G_OPR_CREATE
                    and p_eam_wo_rec.status_type = 3
                   )
                THEN
                    select nvl(auto_firm_flag,'N') into l_auto_firm_flag
                      from wip_eam_parameters
                      where organization_id = p_eam_wo_rec.organization_id;
                    IF l_auto_firm_flag = 'Y' THEN
                      x_eam_wo_rec.firm_planned_flag := 1;
                    END IF;
                END IF;


                -- If updating a WO to relesaed status and auto_firm_flag is
                -- turned on, then set the WO scheduled dates to the old values
                -- . Otherwise, the date encompassment error will be thrown up.
                IF (p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PUB.G_OPR_UPDATE
                    and p_eam_wo_rec.status_type = 3
                    and l_old_eam_wo_rec.status_type in (1,6,17)
					and l_auto_firm_flag = 'Y'
                   )
				THEN

				  x_eam_wo_rec.scheduled_start_date := l_old_eam_wo_rec.scheduled_start_date;
				  x_eam_wo_rec.scheduled_completion_date := l_old_eam_wo_rec.scheduled_completion_date;

				END IF;


                -- Defaulting Manual Rebuild Flag

                IF p_eam_wo_rec.rebuild_item_id is not null AND
                   (p_eam_wo_rec.manual_rebuild_flag IS NULL OR
                    p_eam_wo_rec.manual_rebuild_flag = FND_API.G_MISS_CHAR)
                THEN
                    x_eam_wo_rec.manual_rebuild_flag := 'Y';

                END IF;


IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Defaulting scheduled start date and completion date from the PM Suggested Dates'); END IF;

                -- Defaulting Scheduled Dates from the PM Suggested Dates

                IF (p_eam_wo_rec.pm_suggested_start_date IS NOT NULL AND
                    p_eam_wo_rec.pm_suggested_start_date <> FND_API.G_MISS_DATE) OR
                   (p_eam_wo_rec.pm_suggested_end_date IS NOT NULL AND
                    p_eam_wo_rec.pm_suggested_end_date <> FND_API.G_MISS_DATE)
                THEN
                        x_eam_wo_rec.requested_start_date := p_eam_wo_rec.pm_suggested_start_date;
                        x_eam_wo_rec.due_date := p_eam_wo_rec.pm_suggested_end_date;

                END IF;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Defaulting scheduled start date and completion date'); END IF;


                -- Defaulting Requested Start Date

                IF p_eam_wo_rec.scheduled_start_date IS NOT NULL AND
                   p_eam_wo_rec.scheduled_start_date <> FND_API.G_MISS_DATE AND
                   p_eam_wo_rec.requested_start_date IS NULL AND
                   p_eam_wo_rec.due_date IS NULL and
				   x_eam_wo_rec.requested_start_date IS NULL and
				   x_eam_wo_rec.due_date IS NULL
                THEN
                        x_eam_wo_rec.requested_start_date := p_eam_wo_rec.scheduled_start_date;

                END IF;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Defaulting material_issue_by_mo flag'); END IF;

                -- Defaulting the MATERIAL_ISSUE_BY_MO flag

                IF p_eam_wo_rec.material_issue_by_mo IS NULL OR
                   p_eam_wo_rec.material_issue_by_mo = FND_API.G_MISS_CHAR
                THEN
                  select nvl(material_issue_by_mo,'N')
                    into x_eam_wo_rec.material_issue_by_mo
                    from wip_eam_parameters
                    where organization_id = p_eam_wo_rec.organization_id;
                END IF;

                -- Defaulting the job_quantity

                IF p_eam_wo_rec.job_quantity IS NULL OR
                   p_eam_wo_rec.job_quantity = FND_API.G_MISS_NUM
                THEN
                  x_eam_wo_rec.job_quantity := 1;
                END IF;

                -- Defaulting the wip_supply_type

                IF p_eam_wo_rec.wip_supply_type IS NULL OR
                   p_eam_wo_rec.wip_supply_type = FND_API.G_MISS_NUM
                THEN
                  x_eam_wo_rec.wip_supply_type := 7;
                END IF;


		-- Defaulting the FAILURE_CODE_REQUIRED flag .. bug # 4709084

                IF p_eam_wo_rec.failure_code_required IS NULL OR
                   p_eam_wo_rec.failure_code_required = FND_API.G_MISS_CHAR
                THEN
                   x_eam_wo_rec.failure_code_required := 'N';
                END IF;


                l_out_eam_wo_rec := x_eam_wo_rec;
                get_flex_eam_wo
                (  p_eam_wo_rec => x_eam_wo_rec
                 , x_eam_wo_rec => l_out_eam_wo_rec
                 );
                x_eam_wo_rec := l_out_eam_wo_rec;


             EXCEPTION
                WHEN OTHERS THEN
                     EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                     (  p_message_name       => NULL
                      , p_message_text       => G_PKG_NAME || SQLERRM
                      , x_mesg_token_Tbl     => x_mesg_token_tbl
                     );

                    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    END Attribute_Defaulting;




        PROCEDURE Conditional_Defaulting
        (  p_eam_wo_rec          IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_eam_wo_rec          OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status           OUT NOCOPY VARCHAR2
         )
        IS

             l_serial_number         varchar2(30);
             l_inventory_item_id     number;
             l_eam_item_type         number;

        BEGIN

               x_eam_wo_rec := p_eam_wo_rec;
               x_return_status := FND_API.G_RET_STS_SUCCESS;


               if (p_eam_wo_rec.maintenance_object_type = 3 and p_eam_wo_rec.maintenance_object_source = 1) then

                      select cii.serial_number
                           , cii.inventory_item_id
                           , msi.eam_item_type
                        into l_serial_number
                           , l_inventory_item_id
                           , l_eam_item_type
                        from csi_item_instances cii, mtl_system_items msi
                       where cii.last_vld_organization_id = msi.organization_id
                         and cii.inventory_item_id = msi.inventory_item_id
                         and cii.instance_id = p_eam_wo_rec.maintenance_object_id;

                       if l_eam_item_type = 1 then
                             x_eam_wo_rec.asset_number           := l_serial_number;
                       else
                             x_eam_wo_rec.rebuild_serial_number  := l_serial_number;
                       end if;

               elsif (p_eam_wo_rec.maintenance_object_type = 2) then

                      select inventory_item_id
                        into x_eam_wo_rec.rebuild_item_id
                        from mtl_system_items msi, mtl_parameters mp
                       where msi.organization_id = mp.organization_id
					   and   mp.maint_organization_id = p_eam_wo_rec.organization_id
                         and msi.inventory_item_id = p_eam_wo_rec.maintenance_object_id
                         and rownum = 1;

               end if;

                  EXCEPTION
                     WHEN OTHERS THEN

                          EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                          (  p_message_name       => NULL
                           , p_message_text       => G_PKG_NAME || SQLERRM
                           , x_mesg_token_Tbl     => x_mesg_token_tbl
                          );

                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        END Conditional_Defaulting;



        /******************************************************************
        * Procedure     : Populate_Null_Columns
        * Parameters IN : Work Order column record
        *                 Old Work Order Column Record
        * Parameters OUT NOCOPY: Work Order column record after populating
        * Purpose       : This procedure will look at the columns that the user
        *                 has not filled in and will assign those columns a
        *                 value from the old record.
        *                 This procedure is not called for CREATE
        ********************************************************************/
        PROCEDURE Populate_Null_Columns
        (  p_eam_wo_rec           IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , p_old_eam_wo_rec       IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_eam_wo_rec           OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
        )
        IS
        BEGIN
                x_eam_wo_rec := p_eam_wo_rec;
                x_eam_wo_rec := p_eam_wo_rec;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Processing null columns prior update'); END IF;


                IF p_eam_wo_rec.wip_entity_name IS NULL OR
                   p_eam_wo_rec.wip_entity_name = FND_API.G_MISS_CHAR
                THEN
                        x_eam_wo_rec.wip_entity_name := p_old_eam_wo_rec.wip_entity_name;
                END IF;

                IF p_eam_wo_rec.description IS NULL
                THEN
                        x_eam_wo_rec.description := p_old_eam_wo_rec.description;
                END IF;

		IF p_eam_wo_rec.description = FND_API.G_MISS_CHAR
		THEN
		    x_eam_wo_rec.description := NULL;
                END IF;

                IF p_eam_wo_rec.asset_number IS NULL
                THEN
                        x_eam_wo_rec.asset_number := p_old_eam_wo_rec.asset_number;
                END IF;

                IF p_eam_wo_rec.asset_group_id IS NULL
                THEN
                        x_eam_wo_rec.asset_group_id := p_old_eam_wo_rec.asset_group_id;
                END IF;

                IF p_eam_wo_rec.rebuild_serial_number IS NULL
                THEN
                        x_eam_wo_rec.rebuild_serial_number := p_old_eam_wo_rec.rebuild_serial_number;
                END IF;

                IF p_eam_wo_rec.eam_linear_location_id IS NULL OR
                   p_eam_wo_rec.eam_linear_location_id = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.eam_linear_location_id := p_old_eam_wo_rec.eam_linear_location_id;
                END IF;

                IF p_eam_wo_rec.rebuild_item_id IS NULL
                THEN
                        x_eam_wo_rec.rebuild_item_id := p_old_eam_wo_rec.rebuild_item_id;
                END IF;

		--if FND_API.G_MISS_xx is passed then set values to NULL
		IF p_eam_wo_rec.asset_number = FND_API.G_MISS_CHAR
		THEN
		       x_eam_wo_rec.asset_number := NULL;
		 END IF;

		 IF p_eam_wo_rec.rebuild_serial_number = FND_API.G_MISS_CHAR
		 THEN
		       x_eam_wo_rec.rebuild_serial_number := NULL;
		 END IF;

		 IF p_eam_wo_rec.asset_group_id = FND_API.G_MISS_NUM
		 THEN
		      x_eam_wo_rec.asset_group_id := NULL;
		  END IF;

		  IF p_eam_wo_rec.rebuild_item_id = FND_API.G_MISS_NUM
		  THEN
		      x_eam_wo_rec.rebuild_item_id := NULL;
		  END IF;

                IF p_eam_wo_rec.class_code IS NULL OR
                   p_eam_wo_rec.class_code = FND_API.G_MISS_CHAR
                THEN
                        x_eam_wo_rec.class_code := p_old_eam_wo_rec.class_code;
                END IF;

            IF p_eam_wo_rec.asset_activity_id IS NULL --OR p_eam_wo_rec.asset_activity_id = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.asset_activity_id := p_old_eam_wo_rec.asset_activity_id;
                END IF;

		IF  p_eam_wo_rec.asset_activity_id = FND_API.G_MISS_NUM THEN
			x_eam_wo_rec.asset_activity_id := NULL;
		END IF;


                IF p_eam_wo_rec.activity_type IS NULL
                THEN
                        x_eam_wo_rec.activity_type := p_old_eam_wo_rec.activity_type;
                END IF;

		IF p_eam_wo_rec.activity_type = FND_API.G_MISS_CHAR
		THEN
		     x_eam_wo_rec.activity_type := NULL;
                END IF;

                IF p_eam_wo_rec.activity_cause IS NULL
                THEN
                        x_eam_wo_rec.activity_cause := p_old_eam_wo_rec.activity_cause;
                END IF;

		IF p_eam_wo_rec.activity_cause = FND_API.G_MISS_CHAR
		THEN
		     x_eam_wo_rec.activity_cause := NULL;
                END IF;

                IF p_eam_wo_rec.activity_source IS NULL
                THEN
                        x_eam_wo_rec.activity_source := p_old_eam_wo_rec.activity_source;
                END IF;

		IF p_eam_wo_rec.activity_source = FND_API.G_MISS_CHAR
		THEN
		     x_eam_wo_rec.activity_source := NULL;
                END IF;

                IF p_eam_wo_rec.status_type IS NULL OR
                   p_eam_wo_rec.status_type = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.status_type := p_old_eam_wo_rec.status_type;
                END IF;

		IF p_eam_wo_rec.user_defined_status_id IS NULL OR
                   p_eam_wo_rec.user_defined_status_id = FND_API.G_MISS_NUM
                THEN
			x_eam_wo_rec.user_defined_status_id := p_old_eam_wo_rec.user_defined_status_id;
                END IF;

                IF p_eam_wo_rec.job_quantity IS NULL OR
                   p_eam_wo_rec.job_quantity = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.job_quantity := p_old_eam_wo_rec.job_quantity;
                END IF;

                IF p_eam_wo_rec.date_released IS NULL OR
                   p_eam_wo_rec.date_released = FND_API.G_MISS_DATE
                THEN
                        x_eam_wo_rec.date_released := p_old_eam_wo_rec.date_released;
                END IF;

                IF p_eam_wo_rec.owning_department IS NULL
                THEN
                        x_eam_wo_rec.owning_department := p_old_eam_wo_rec.owning_department;
                END IF;

                IF p_eam_wo_rec.owning_department = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.owning_department := NULL;
                END IF;

                IF p_eam_wo_rec.priority IS NULL
                THEN
                        x_eam_wo_rec.priority := p_old_eam_wo_rec.priority;
                END IF;

		IF p_eam_wo_rec.priority = FND_API.G_MISS_NUM
		THEN
		     x_eam_wo_rec.priority := NULL;
                END IF;

		 IF p_eam_wo_rec.work_order_type IS NULL
                THEN
                        x_eam_wo_rec.work_order_type := p_old_eam_wo_rec.work_order_type;
                END IF;

		IF p_eam_wo_rec.work_order_type = FND_API.G_MISS_CHAR
		THEN
		     x_eam_wo_rec.work_order_type := NULL;
                END IF;

                -- Requested Start Date and Due date will have to be handled
                -- together since only one of them can be not null
                IF (p_eam_wo_rec.requested_start_date IS NULL OR
                    p_eam_wo_rec.requested_start_date = FND_API.G_MISS_DATE) AND
                   (p_eam_wo_rec.due_date IS NULL OR
                    p_eam_wo_rec.due_date = FND_API.G_MISS_DATE)
                THEN
                        x_eam_wo_rec.requested_start_date := p_old_eam_wo_rec.requested_start_date;
                        x_eam_wo_rec.due_date := p_old_eam_wo_rec.due_date;
                END IF;


				/*
                -- PM Suggested Start Date and PM Suggested End date will have to be handled
                -- together since only one of them can be not null
                IF (p_eam_wo_rec.pm_suggested_start_date IS NULL OR
                    p_eam_wo_rec.pm_suggested_start_date = FND_API.G_MISS_DATE) AND
                   (p_eam_wo_rec.pm_suggested_end_date IS NULL OR
                    p_eam_wo_rec.pm_suggested_end_date = FND_API.G_MISS_DATE)
                THEN
                        x_eam_wo_rec.pm_suggested_start_date := p_old_eam_wo_rec.pm_suggested_start_date;
                        x_eam_wo_rec.pm_suggested_end_date := p_old_eam_wo_rec.pm_suggested_end_date;
                END IF;
				*/


                IF p_eam_wo_rec.pm_base_meter_reading IS NULL OR
                   p_eam_wo_rec.pm_base_meter_reading = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.pm_base_meter_reading := p_old_eam_wo_rec.pm_base_meter_reading;
                END IF;

                IF p_eam_wo_rec.pm_base_meter IS NULL OR
                   p_eam_wo_rec.pm_base_meter = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.pm_base_meter := p_old_eam_wo_rec.pm_base_meter;
                END IF;


                IF p_eam_wo_rec.shutdown_type IS NULL
                THEN
                        x_eam_wo_rec.shutdown_type := p_old_eam_wo_rec.shutdown_type;
                END IF;

		IF p_eam_wo_rec.shutdown_type = FND_API.G_MISS_CHAR
		THEN
		     x_eam_wo_rec.shutdown_type := NULL;
                END IF;

                IF p_eam_wo_rec.firm_planned_flag IS NULL OR
                   p_eam_wo_rec.firm_planned_flag = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.firm_planned_flag := p_old_eam_wo_rec.firm_planned_flag;
                END IF;

                IF p_eam_wo_rec.issue_zero_cost_flag IS NULL OR
                   p_eam_wo_rec.issue_zero_cost_flag = FND_API.G_MISS_CHAR
                THEN
                        x_eam_wo_rec.issue_zero_cost_flag := p_old_eam_wo_rec.issue_zero_cost_flag;
                END IF;

                IF p_eam_wo_rec.notification_required IS NULL OR
                   p_eam_wo_rec.notification_required = FND_API.G_MISS_CHAR
                THEN
                        x_eam_wo_rec.notification_required := p_old_eam_wo_rec.notification_required;
                END IF;

                IF p_eam_wo_rec.tagout_required IS NULL OR
                   p_eam_wo_rec.tagout_required = FND_API.G_MISS_CHAR
                THEN
                        x_eam_wo_rec.tagout_required := p_old_eam_wo_rec.tagout_required;
                END IF;

                IF p_eam_wo_rec.plan_maintenance IS NULL OR
                   p_eam_wo_rec.plan_maintenance = FND_API.G_MISS_CHAR
                THEN
                        x_eam_wo_rec.plan_maintenance := p_old_eam_wo_rec.plan_maintenance;
                END IF;

		/* commented for bug 5346446
                IF p_eam_wo_rec.project_id IS NULL OR
                   p_eam_wo_rec.project_id = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.project_id := p_old_eam_wo_rec.project_id;
                END IF;

                IF p_eam_wo_rec.task_id IS NULL OR
                   p_eam_wo_rec.task_id = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.task_id := p_old_eam_wo_rec.task_id;
                END IF;*/

		/* Added for bug#5346446 Start */
	        IF p_eam_wo_rec.project_id IS NULL THEN
                   x_eam_wo_rec.project_id := p_old_eam_wo_rec.project_id;
                ELSIF p_eam_wo_rec.project_id = FND_API.G_MISS_NUM THEN
                   x_eam_wo_rec.project_id := NULL;
                END IF;

                IF p_eam_wo_rec.task_id IS NULL THEN
                   x_eam_wo_rec.task_id := p_old_eam_wo_rec.task_id;
                ELSIF p_eam_wo_rec.task_id = FND_API.G_MISS_NUM THEN
                   x_eam_wo_rec.task_id := NULL;
                END IF;
                /* Added for bug#5346446 End */

                IF p_eam_wo_rec.end_item_unit_number IS NULL OR
                   p_eam_wo_rec.end_item_unit_number = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.end_item_unit_number := p_old_eam_wo_rec.end_item_unit_number;
                END IF;

                IF p_eam_wo_rec.schedule_group_id IS NULL OR
                   p_eam_wo_rec.schedule_group_id = FND_API.G_MISS_NUM
                THEN

               x_eam_wo_rec.schedule_group_id := p_old_eam_wo_rec.schedule_group_id;
                END IF;

                IF p_eam_wo_rec.bom_revision_date IS NULL OR
                   p_eam_wo_rec.bom_revision_date = FND_API.G_MISS_DATE
                THEN
                        x_eam_wo_rec.bom_revision_date := p_old_eam_wo_rec.bom_revision_date;
                END IF;

                IF p_eam_wo_rec.routing_revision_date IS NULL OR
                   p_eam_wo_rec.routing_revision_date = FND_API.G_MISS_DATE
                THEN
                        x_eam_wo_rec.routing_revision_date := p_old_eam_wo_rec.routing_revision_date;
                END IF;


                IF p_eam_wo_rec.alternate_routing_designator IS NULL OR
                   p_eam_wo_rec.alternate_routing_designator = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.alternate_routing_designator := p_old_eam_wo_rec.alternate_routing_designator;
                END IF;

                IF p_eam_wo_rec.alternate_bom_designator IS NULL OR
                   p_eam_wo_rec.alternate_bom_designator = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.alternate_bom_designator := p_old_eam_wo_rec.alternate_bom_designator;
                END IF;

                IF p_eam_wo_rec.routing_revision IS NULL OR
                   p_eam_wo_rec.routing_revision = FND_API.G_MISS_CHAR
                THEN
                        x_eam_wo_rec.routing_revision := p_old_eam_wo_rec.routing_revision;
                END IF;

                IF p_eam_wo_rec.bom_revision IS NULL OR
                   p_eam_wo_rec.bom_revision = FND_API.G_MISS_CHAR
                THEN
                        x_eam_wo_rec.bom_revision := p_old_eam_wo_rec.bom_revision;
                END IF;

                IF p_eam_wo_rec.manual_rebuild_flag IS NULL OR
                   p_eam_wo_rec.manual_rebuild_flag = FND_API.G_MISS_CHAR
                THEN
                        x_eam_wo_rec.manual_rebuild_flag := p_old_eam_wo_rec.manual_rebuild_flag;
                END IF;

                IF p_eam_wo_rec.material_account IS NULL OR
                   p_eam_wo_rec.material_account = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.material_account := p_old_eam_wo_rec.material_account;
                END IF;

                IF p_eam_wo_rec.material_overhead_account IS NULL OR
                   p_eam_wo_rec.material_overhead_account = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.material_overhead_account := p_old_eam_wo_rec.material_overhead_account;
                END IF;

                IF p_eam_wo_rec.resource_account IS NULL OR
                   p_eam_wo_rec.resource_account = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.resource_account := p_old_eam_wo_rec.resource_account;
                END IF;

                IF p_eam_wo_rec.outside_processing_account IS NULL OR
                   p_eam_wo_rec.outside_processing_account = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.outside_processing_account := p_old_eam_wo_rec.outside_processing_account;
                END IF;

                IF p_eam_wo_rec.material_variance_account IS NULL OR
                   p_eam_wo_rec.material_variance_account = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.material_variance_account := p_old_eam_wo_rec.material_variance_account;
                END IF;

                IF p_eam_wo_rec.resource_variance_account IS NULL OR
                   p_eam_wo_rec.resource_variance_account = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.resource_variance_account := p_old_eam_wo_rec.resource_variance_account;
                END IF;

                IF p_eam_wo_rec.outside_proc_variance_account IS NULL OR
                   p_eam_wo_rec.outside_proc_variance_account = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.outside_proc_variance_account := p_old_eam_wo_rec.outside_proc_variance_account;
                END IF;

                IF p_eam_wo_rec.std_cost_adjustment_account IS NULL OR
                   p_eam_wo_rec.std_cost_adjustment_account = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.std_cost_adjustment_account := p_old_eam_wo_rec.std_cost_adjustment_account;
                END IF;

                IF p_eam_wo_rec.overhead_account IS NULL OR
                   p_eam_wo_rec.overhead_account = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.overhead_account := p_old_eam_wo_rec.overhead_account;
                END IF;

                IF p_eam_wo_rec.overhead_variance_account IS NULL OR
                   p_eam_wo_rec.overhead_variance_account = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.overhead_variance_account := p_old_eam_wo_rec.overhead_variance_account;
                END IF;

                IF p_eam_wo_rec.scheduled_start_date IS NULL OR
                   p_eam_wo_rec.scheduled_start_date = FND_API.G_MISS_DATE
                THEN
                        x_eam_wo_rec.scheduled_start_date := p_old_eam_wo_rec.scheduled_start_date;
                END IF;

                IF p_eam_wo_rec.scheduled_completion_date IS NULL OR
                   p_eam_wo_rec.scheduled_completion_date = FND_API.G_MISS_DATE
                THEN
                        x_eam_wo_rec.scheduled_completion_date := p_old_eam_wo_rec.scheduled_completion_date;
                END IF;

                IF p_eam_wo_rec.common_bom_sequence_id IS NULL OR
                   p_eam_wo_rec.common_bom_sequence_id = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.common_bom_sequence_id := p_old_eam_wo_rec.common_bom_sequence_id;
                END IF;

                IF p_eam_wo_rec.common_routing_sequence_id IS NULL OR
                   p_eam_wo_rec.common_routing_sequence_id = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.common_routing_sequence_id := p_old_eam_wo_rec.common_routing_sequence_id;
                END IF;

                IF p_eam_wo_rec.source_line_id IS NULL OR
                   p_eam_wo_rec.source_line_id = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.source_line_id := p_old_eam_wo_rec.source_line_id;
                END IF;

                IF p_eam_wo_rec.source_code IS NULL OR
                   p_eam_wo_rec.source_code = FND_API.G_MISS_CHAR
                THEN
                        x_eam_wo_rec.source_code := p_old_eam_wo_rec.source_code;
                END IF;

                IF p_eam_wo_rec.gen_object_id IS NULL OR
                   p_eam_wo_rec.gen_object_id = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.gen_object_id := p_old_eam_wo_rec.gen_object_id;
                END IF;

                IF p_eam_wo_rec.maintenance_object_id IS NULL OR
                   p_eam_wo_rec.maintenance_object_id = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.maintenance_object_id := p_old_eam_wo_rec.maintenance_object_id;
                END IF;

                IF p_eam_wo_rec.maintenance_object_type IS NULL OR
                   p_eam_wo_rec.maintenance_object_type = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.maintenance_object_type := p_old_eam_wo_rec.maintenance_object_type;
                END IF;

                IF p_eam_wo_rec.maintenance_object_source IS NULL OR
                   p_eam_wo_rec.maintenance_object_source = FND_API.G_MISS_NUM
                THEN
                        x_eam_wo_rec.maintenance_object_source := p_old_eam_wo_rec.maintenance_object_source;
                END IF;

                --
                -- Populate Null or missng flex field columns
                --
                IF p_eam_wo_rec.attribute_category IS NULL
                THEN
                        x_eam_wo_rec.attribute_category := p_old_eam_wo_rec.attribute_category;

                END IF;

		IF p_eam_wo_rec.attribute_category = FND_API.G_MISS_CHAR
		THEN
		     x_eam_wo_rec.attribute_category := NULL;
                END IF;

                IF p_eam_wo_rec.attribute1 IS NULL
                THEN
                        x_eam_wo_rec.attribute1  := p_old_eam_wo_rec.attribute1;
                END IF;

		IF p_eam_wo_rec.attribute1 = FND_API.G_MISS_CHAR
		THEN
		     x_eam_wo_rec.attribute1 := NULL;
                END IF;

                IF p_eam_wo_rec.attribute2 IS NULL
                THEN
                        x_eam_wo_rec.attribute2  := p_old_eam_wo_rec.attribute2;
                END IF;

		IF p_eam_wo_rec.attribute2 = FND_API.G_MISS_CHAR
		THEN
		     x_eam_wo_rec.attribute2 := NULL;
                END IF;

                IF p_eam_wo_rec.attribute3  IS NULL
                THEN
                        x_eam_wo_rec.attribute3  := p_old_eam_wo_rec.attribute3;
                END IF;

		IF p_eam_wo_rec.attribute3 = FND_API.G_MISS_CHAR
		THEN
		     x_eam_wo_rec.attribute3 := NULL;
                END IF;

                IF p_eam_wo_rec.attribute4  IS NULL
                THEN
                        x_eam_wo_rec.attribute4  := p_old_eam_wo_rec.attribute4;
                END IF;

		IF p_eam_wo_rec.attribute4 = FND_API.G_MISS_CHAR
		THEN
		     x_eam_wo_rec.attribute4 := NULL;
                END IF;

                IF p_eam_wo_rec.attribute5  IS NULL
                THEN
                        x_eam_wo_rec.attribute5  := p_old_eam_wo_rec.attribute5;
                END IF;

		IF p_eam_wo_rec.attribute5 = FND_API.G_MISS_CHAR
		THEN
		     x_eam_wo_rec.attribute5 := NULL;
                END IF;

                IF p_eam_wo_rec.attribute6  IS NULL
                THEN
                        x_eam_wo_rec.attribute6  := p_old_eam_wo_rec.attribute6;
                END IF;

		IF p_eam_wo_rec.attribute6 = FND_API.G_MISS_CHAR
		THEN
		     x_eam_wo_rec.attribute6 := NULL;
                END IF;

                IF p_eam_wo_rec.attribute7  IS NULL
                THEN
                        x_eam_wo_rec.attribute7  := p_old_eam_wo_rec.attribute7;
                END IF;

		IF p_eam_wo_rec.attribute7 = FND_API.G_MISS_CHAR
		THEN
		     x_eam_wo_rec.attribute7 := NULL;
                END IF;

                IF p_eam_wo_rec.attribute8  IS NULL
                THEN
                        x_eam_wo_rec.attribute8  := p_old_eam_wo_rec.attribute8;
                END IF;

		IF p_eam_wo_rec.attribute8 = FND_API.G_MISS_CHAR
		THEN
		     x_eam_wo_rec.attribute8 := NULL;
                END IF;

                IF p_eam_wo_rec.attribute9  IS NULL
                THEN
                        x_eam_wo_rec.attribute9  := p_old_eam_wo_rec.attribute9;
                END IF;

		IF p_eam_wo_rec.attribute9 = FND_API.G_MISS_CHAR
		THEN
		     x_eam_wo_rec.attribute9 := NULL;
                END IF;

                IF p_eam_wo_rec.attribute10  IS NULL
                THEN
                        x_eam_wo_rec.attribute10 := p_old_eam_wo_rec.attribute10;
                END IF;

		IF p_eam_wo_rec.attribute10 = FND_API.G_MISS_CHAR
		THEN
		     x_eam_wo_rec.attribute10 := NULL;
                END IF;

                IF p_eam_wo_rec.attribute11  IS NULL
                THEN
                        x_eam_wo_rec.attribute11 := p_old_eam_wo_rec.attribute11;
                END IF;

		IF p_eam_wo_rec.attribute11 = FND_API.G_MISS_CHAR
		THEN
		     x_eam_wo_rec.attribute11 := NULL;
                END IF;

                IF p_eam_wo_rec.attribute12  IS NULL
                THEN
                        x_eam_wo_rec.attribute12 := p_old_eam_wo_rec.attribute12;
                END IF;

		IF p_eam_wo_rec.attribute12 = FND_API.G_MISS_CHAR
		THEN
		     x_eam_wo_rec.attribute12 := NULL;
                END IF;

                IF p_eam_wo_rec.attribute13  IS NULL
                THEN
                        x_eam_wo_rec.attribute13 := p_old_eam_wo_rec.attribute13;
                END IF;

		IF p_eam_wo_rec.attribute13 = FND_API.G_MISS_CHAR
		THEN
		     x_eam_wo_rec.attribute13 := NULL;
                END IF;

                IF p_eam_wo_rec.attribute14  IS NULL
                THEN
                        x_eam_wo_rec.attribute14 := p_old_eam_wo_rec.attribute14;
                END IF;

		IF p_eam_wo_rec.attribute14 = FND_API.G_MISS_CHAR
		THEN
		     x_eam_wo_rec.attribute14 := NULL;
                END IF;

                IF p_eam_wo_rec.attribute15  IS NULL
                THEN
                        x_eam_wo_rec.attribute15 := p_old_eam_wo_rec.attribute15;
                END IF;

		IF p_eam_wo_rec.attribute15 = FND_API.G_MISS_CHAR
		THEN
		     x_eam_wo_rec.attribute15 := NULL;
                END IF;

		-- Added for bug 12690042
                IF p_eam_wo_rec.parent_wip_entity_id = FND_API.G_MISS_NUM OR
                   p_eam_wo_rec.parent_wip_entity_id IS NULL
                THEN
                        x_eam_wo_rec.parent_wip_entity_id := p_old_eam_wo_rec.parent_wip_entity_id;
                END IF;

                -- MATERIAL_ISSUE_BY_MO flag
                IF p_eam_wo_rec.material_issue_by_mo = FND_API.G_MISS_CHAR OR
                   p_eam_wo_rec.material_issue_by_mo IS NULL
                THEN
                        x_eam_wo_rec.material_issue_by_mo := p_old_eam_wo_rec.material_issue_by_mo;
                END IF;

                IF p_eam_wo_rec.pending_flag = FND_API.G_MISS_CHAR OR
                   p_eam_wo_rec.pending_flag IS NULL
                THEN
                        x_eam_wo_rec.pending_flag := p_old_eam_wo_rec.pending_flag;
                END IF;

		IF p_eam_wo_rec.material_shortage_check_date = FND_API.G_MISS_DATE OR
                   p_eam_wo_rec.material_shortage_check_date IS NULL
                THEN
                        x_eam_wo_rec.material_shortage_check_date := p_old_eam_wo_rec.material_shortage_check_date;
                END IF;

		IF p_eam_wo_rec.material_shortage_flag = FND_API.G_MISS_NUM OR
                   p_eam_wo_rec.material_shortage_flag IS NULL
                THEN
                        x_eam_wo_rec.material_shortage_flag := p_old_eam_wo_rec.material_shortage_flag;
                END IF;

		IF p_eam_wo_rec.workflow_type = FND_API.G_MISS_NUM OR
                   p_eam_wo_rec.workflow_type IS NULL
                THEN
                        x_eam_wo_rec.workflow_type := p_old_eam_wo_rec.workflow_type;
                END IF;

		IF p_eam_wo_rec.warranty_claim_status = FND_API.G_MISS_NUM OR
                   p_eam_wo_rec.warranty_claim_status IS NULL
                THEN
                        x_eam_wo_rec.warranty_claim_status := p_old_eam_wo_rec.warranty_claim_status;
                END IF;

		IF p_eam_wo_rec.cycle_id = FND_API.G_MISS_NUM OR
                   p_eam_wo_rec.cycle_id IS NULL
                THEN
                        x_eam_wo_rec.cycle_id := p_old_eam_wo_rec.cycle_id;
                END IF;

		IF p_eam_wo_rec.seq_id = FND_API.G_MISS_NUM OR
                   p_eam_wo_rec.seq_id IS NULL
                THEN
                        x_eam_wo_rec.seq_id := p_old_eam_wo_rec.seq_id;
                END IF;

		IF p_eam_wo_rec.ds_scheduled_flag = FND_API.G_MISS_CHAR OR
                   p_eam_wo_rec.ds_scheduled_flag IS NULL
                THEN
                        x_eam_wo_rec.ds_scheduled_flag := p_old_eam_wo_rec.ds_scheduled_flag;
                END IF;

		IF p_eam_wo_rec.assignment_complete = FND_API.G_MISS_CHAR OR
		   p_eam_wo_rec.assignment_complete IS NULL
		THEN
			x_eam_wo_rec.assignment_complete := p_old_eam_wo_rec.assignment_complete;
		END IF;

		IF p_eam_wo_rec.warranty_active = FND_API.G_MISS_NUM OR
                   p_eam_wo_rec.warranty_active IS NULL
                THEN
                        x_eam_wo_rec.warranty_active := p_old_eam_wo_rec.warranty_active;
                END IF;

		-- Bug # 4709084 : Failure Analysis project.

		IF p_eam_wo_rec.failure_code_required IS NULL
                THEN
                        x_eam_wo_rec.failure_code_required := p_old_eam_wo_rec.failure_code_required;
                END IF;

		IF p_eam_wo_rec.failure_code_required = FND_API.G_MISS_CHAR
		THEN
		     x_eam_wo_rec.failure_code_required := 'N';  -- As NULL Is same as 'N'
                END IF;


IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Done processing null columns prior update'); END IF;

        END Populate_Null_Columns;

END EAM_WO_DEFAULT_PVT;

/
