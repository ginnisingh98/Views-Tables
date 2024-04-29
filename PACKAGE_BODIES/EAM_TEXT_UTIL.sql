--------------------------------------------------------
--  DDL for Package Body EAM_TEXT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_TEXT_UTIL" AS
/* $Header: EAMVTIUB.pls 120.9 2006/09/20 15:00:19 sdandapa noship $*/


-- -----------------------------------------------------------------------------
--  				Private Globals
-- -----------------------------------------------------------------------------
  g_pkg_name    CONSTANT VARCHAR2(30):= 'eam_text_util';

  g_Prod_Short_Name	CONSTANT  VARCHAR2(30)  :=  'EAM';
  g_Prod_Schema		VARCHAR2(30);
  g_Index_Owner		VARCHAR2(30);

  g_Indexing_Context	VARCHAR2(30)    :=  'SYNC_INDEX';

  g_installed		BOOLEAN;
  g_inst_status		VARCHAR2(1);
  g_industry		VARCHAR2(1);

  g_DB_Version_Num	NUMBER        :=  NULL;
  g_DB_Version_Str	VARCHAR2(30)  :=  NULL;
  g_compatibility       VARCHAR2(30)  :=  NULL;
  l_DB_Version_Str       VARCHAR2(30)  :=  NULL;
  l_DB_Numeric_Character VARCHAR2(30)  :=  NULL;

  -- Global debug flag
  G_DEBUG VARCHAR2(1) := NVL(fnd_profile.value('EAM_DEBUG'), 'N');

  -- Variable used to buffer text strings before writing into LOB.
  g_Buffer			VARCHAR2(32767);
  g_Buffer_Length		INTEGER;

  -- Document section tags
  Tag_asset_number		CONSTANT  VARCHAR2(30)  :=  'tagassetnumber';
  Tag_begin_asset_number	CONSTANT  VARCHAR2(30)  :=  '<'  || Tag_asset_number || '>';
  Tag_end_asset_number		CONSTANT  VARCHAR2(30)  :=  '</' || Tag_asset_number || '>';
  Tag_work_order             CONSTANT  VARCHAR2(30)  :=  'tagworkorder';
  Tag_begin_work_order	CONSTANT  VARCHAR2(30)  :=  '<'  || Tag_work_order || '>';
  Tag_end_work_order	CONSTANT  VARCHAR2(30)  :=  '</' || Tag_work_order || '>';

-- -----------------------------------------------------------------------------
--  				Set_Context
-- -----------------------------------------------------------------------------

PROCEDURE Set_Context ( p_context  IN  VARCHAR2 )
IS
BEGIN
    g_Indexing_Context := p_context;
END Set_Context;


-- -----------------------------------------------------------------------------
--				Append_VARCHAR_to_LOB
-- -----------------------------------------------------------------------------

PROCEDURE Append_VARCHAR_to_LOB
(
   x_tlob      IN OUT NOCOPY  CLOB
,  p_string    IN             VARCHAR2
,  p_action    IN             VARCHAR2  DEFAULT  'APPEND'
)
IS
   start_writing	BOOLEAN  :=  TRUE;
   l_offset		INTEGER  :=  1;
   l_Max_Length		INTEGER  :=  32767;
   l_String_Length	INTEGER;
BEGIN

   IF ( p_action = 'BEGIN' ) THEN

      -- Empty the LOB, if this is the first chunk of text to append
      DBMS_LOB.Trim ( lob_loc => x_tlob, newlen => 0 );

      g_Buffer := p_string;
      g_Buffer_Length := -1;

   ELSIF ( p_action IN ('APPEND', 'END') ) THEN

      start_writing := ( g_Buffer_Length = -1 );
      IF ( start_writing ) THEN
         g_Buffer_Length := Length (g_Buffer);
      END IF;

      l_String_Length := Length (p_string);

      -- Write buffer to LOB if required

      IF ( g_Buffer_Length + l_String_Length >= l_Max_Length ) THEN
         IF ( start_writing ) THEN
            DBMS_LOB.Write (  lob_loc  =>  x_tlob
                           ,  amount   =>  Length (g_Buffer)
                           ,  offset   =>  l_offset
                           ,  buffer   =>  g_Buffer
                           );
         ELSE
            DBMS_LOB.WriteAppend (  lob_loc  =>  x_tlob
                                 ,  amount   =>  Length (g_Buffer)
                                 ,  buffer   =>  g_Buffer
                                 );
         END IF;

         -- Reset buffer
         g_Buffer := p_string;
         g_Buffer_Length := Length (g_Buffer);
      ELSE
         g_Buffer := g_Buffer || p_string;
         g_Buffer_Length := g_Buffer_Length + l_String_Length;
      END IF;  -- Max_Length reached

      IF ( p_action = 'END' ) THEN
         start_writing := ( g_Buffer_Length = -1 );
         IF ( start_writing ) THEN
            DBMS_LOB.Write (  lob_loc  =>  x_tlob
                           ,  amount   =>  Length (g_Buffer)
                           ,  offset   =>  l_offset
                           ,  buffer   =>  g_Buffer
                           );
         ELSE
            DBMS_LOB.WriteAppend (  lob_loc  =>  x_tlob
                                 ,  amount   =>  Length (g_Buffer)
                                 ,  buffer   =>  g_Buffer
                                 );
         END IF;
         -- Reset buffer
         g_Buffer := '';
         g_Buffer_Length := -1;
      END IF;

   END IF;  -- p_action

END Append_VARCHAR_to_LOB;



-- -----------------------------------------------------------------------------
--  				Get_Asset_Text
---		 Procedure called from the Intermedia index for asset to find the text on which index has to be created
-- -----------------------------------------------------------------------------

PROCEDURE Get_Asset_Text
(
   p_rowid          IN             ROWID
 , p_output_type    IN             VARCHAR2
 , x_tlob           IN OUT NOCOPY  CLOB
 , x_tchar          IN OUT NOCOPY  VARCHAR2
)
IS
   l_api_name		CONSTANT    VARCHAR2(30)  :=  'Get_Asset_Text';
   l_return_status	VARCHAR2(1);
   l_instance_id	NUMBER;
   l_org_id		NUMBER;
   l_eam_item_type      NUMBER;
   l_criticality_code   NUMBER;
   l_buffer		VARCHAR2(32767);

   CURSOR Attribute(p_instance_id NUMBER) IS
   SELECT
        attribute_category ||' '|| c_attribute1  ||' '|| c_attribute2 ||' '|| c_attribute3
	||' '|| c_attribute4 ||' '|| c_attribute5 ||' '|| c_attribute6 ||' '|| c_attribute7
	||' '|| c_attribute8 ||' '|| c_attribute9 ||' '|| c_attribute10 ||' '|| c_attribute11
	||' '|| c_attribute12 ||' '|| c_attribute13 ||' '|| c_attribute14 ||' '|| c_attribute15
	||' '|| c_attribute16 ||' '|| c_attribute17 ||' '|| c_attribute18 ||' '|| c_attribute19
	||' '|| c_attribute20 ||' '|| d_attribute1 ||' '|| d_attribute2 ||' '|| d_attribute3
	||' '|| d_attribute4 ||' '|| d_attribute5 ||' '|| d_attribute6 ||' '|| d_attribute7
	||' '|| d_attribute8 ||' '|| d_attribute9 ||' '|| d_attribute10 ||' '|| n_attribute1
	||' '|| n_attribute2 ||' '|| n_attribute3 ||' '|| n_attribute4 ||' '|| n_attribute5
	||' '|| n_attribute6 ||' '|| n_attribute7 ||' '|| n_attribute8 ||' '|| n_attribute9
	||' '|| n_attribute10 as value
     FROM mtl_eam_asset_attr_values meaav
    WHERE meaav.maintenance_object_id = p_instance_id;

   CURSOR lookup_meaning(p_lookup_type VARCHAR2, p_lookup_code NUMBER) IS
   SELECT meaning
     FROM fnd_lookup_values
    WHERE lookup_type = p_lookup_type
      AND lookup_code = p_lookup_code;

   /* Search based on Activity and meter will be enabled in future

   CURSOR Activity(p_instance_id NUMBER) IS
   SELECT
        msi.concatenated_segments as value
      FROM
          mtl_system_items_b_kfv   msi
        , mtl_eam_asset_activities meaa
      WHERE
            meaa.maintenance_object_id = p_instance_id
	AND meaa.maintenance_object_type = 3
	AND meaa.asset_activity_id = msi.inventory_item_id
	AND rownum = 1;

   -- Meter are now migrated to counter's schema...
   -- following query needs to be changed
   CURSOR Meter(p_instance_id NUMBER) IS
   SELECT
        em.meter_name as value
      FROM
          eam_asset_meters eam
        , eam_meters em
      WHERE
            eam.maintenance_object_id = p_instance_id
	AND eam.maintenance_object_type = 3
	AND eam.meter_id = em.meter_id;
    */

BEGIN

   -----------------------------------------------------------
   -- Get CII Data
   -----------------------------------------------------------
   l_buffer := NULL;

   BEGIN

      SELECT
         eat.instance_id, cii.last_vld_organization_id, msi.eam_item_type , cii.asset_criticality_code,
	 Tag_begin_asset_number ||' '|| cii.instance_number ||' '|| cii.instance_description ||' '||
	 Tag_end_asset_number ||' '|| cii.serial_number ||' '|| msi.concatenated_segments ||' '||
	 msi.description ||' '|| mck.concatenated_segments ||' '|| msi.description ||' '||
	 cii.context ||' '|| cii.attribute1 ||' '|| cii.attribute2 ||' '|| cii.attribute3 ||' '||
	 cii.attribute4 ||' '|| cii.attribute5 ||' '|| cii.attribute6 ||' '|| cii.attribute7 ||' '||
	 cii.attribute8 ||' '|| cii.attribute9 ||' '|| cii.attribute10 ||' '|| cii.attribute11
	 ||' '|| cii.attribute12 ||' '|| cii.attribute13 ||' '|| cii.attribute14 ||' '||
	 cii.attribute15 ||' '|| cii.attribute16 ||' '|| cii.attribute17 ||' '|| cii.attribute18
	 ||' '|| cii.attribute19 ||' '|| cii.attribute20 ||' '|| cii.attribute21 ||' '||
	 cii.attribute22 ||' '|| cii.attribute23 ||' '|| cii.attribute24 ||' '|| cii.attribute25
	 ||' '|| cii.attribute26 ||' '|| cii.attribute27 ||' '|| cii.attribute28 ||' '||
	 cii.attribute29 ||' '|| cii.attribute30 ||' '|| msi.attribute_category ||' '||
	 msi.attribute1  ||' '|| msi.attribute2 ||' '|| msi.attribute3 ||' '|| msi.attribute4
	 ||' '|| msi.attribute5 ||' '|| msi.attribute6 ||' '|| msi.attribute7 ||' '||
	 msi.attribute8 ||' '|| msi.attribute9 ||' '|| msi.attribute10 ||' '|| msi.attribute11
	 ||' '|| msi.attribute12 ||' '|| msi.attribute13 ||' '|| msi.attribute14 ||' '||
	 msi.attribute15
      INTO
         l_instance_id, l_org_id, l_eam_item_type, l_criticality_code, l_buffer
      FROM
         eam_asset_text         eat
       , csi_item_instances     cii
       , mtl_system_items_b_kfv msi
       , mtl_categories_kfv     mck
      WHERE
           eat.rowid = p_rowid
       AND eat.instance_id = cii.instance_id
       AND nvl(cii.active_start_date, sysdate-1) <= sysdate
       AND nvl(cii.active_end_date, sysdate+1) >= sysdate
       AND cii.inventory_item_id = msi.inventory_item_id
       AND cii.last_vld_organization_id = msi.organization_id
       AND msi.serial_number_control_code <> 1
       AND cii.category_id = mck.category_id(+);

   EXCEPTION
      WHEN no_data_found THEN
         /*IF (g_Debug) THEN
	   Debug(p_rowid, null,  '** 0: ' || SQLERRM);
	 END IF;*/
	 Raise;
   END;

   IF ( p_output_type = 'VARCHAR2' ) THEN
      x_tchar := l_buffer;
   ELSE
      Append_VARCHAR_to_LOB (x_tlob, ' ', 'BEGIN');
      Append_VARCHAR_to_LOB (x_tlob, l_buffer);
   END IF;

   -- Get the Maintenance Attributes of the Asset -------------------
   l_buffer := NULL;
   BEGIN
      SELECT bd.department_code ||' '|| mel.location_codes ||' '|| eomd.accounting_class_code
        INTO l_buffer
	FROM eam_org_maint_defaults eomd, bom_departments bd, mtl_eam_locations mel,
	     mtl_parameters mp
       WHERE mp.organization_id = l_org_id AND mp.maint_organization_id = eomd.organization_id
         AND eomd.object_id = l_instance_id AND eomd.object_type = 50
         AND eomd.owning_department_id = bd.department_id (+) AND eomd.area_id = mel.location_id(+);

      IF ( p_output_type = 'VARCHAR2' ) THEN
         x_tchar := x_tchar ||' '||l_buffer;
      ELSE
         Append_VARCHAR_to_LOB (x_tlob, l_buffer);
      END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
       null;
    END;

   -- Get the Asset Type -------------------------------------------
   l_buffer := NULL;
   FOR asset_type in lookup_meaning('MTL_EAM_ASSET_TYPE', l_eam_item_type) LOOP
     l_buffer := l_buffer ||' '|| asset_type.meaning;
   END LOOP;

   IF ( p_output_type = 'VARCHAR2' ) THEN
      x_tchar := x_tchar ||' '||l_buffer;
   ELSE
      Append_VARCHAR_to_LOB (x_tlob, l_buffer);
   END IF;

   -- Get the Asset criticality code ---------------------------------
   l_buffer := NULL;
   FOR asset_criticality in lookup_meaning('MTL_EAM_ASSET_CRITICALITY', l_criticality_code) LOOP
     l_buffer := l_buffer ||' '|| asset_criticality.meaning;
   END LOOP;

   IF ( p_output_type = 'VARCHAR2' ) THEN
      x_tchar := x_tchar ||' '||l_buffer;
   ELSE
      Append_VARCHAR_to_LOB (x_tlob, l_buffer);
   END IF;

   -- Get the Asset Attributes Details ------------------------------
   l_buffer := NULL;
   FOR attribute_value in Attribute(l_instance_id) LOOP
     l_buffer := l_buffer ||' '|| attribute_value.value;
   END LOOP;

   IF ( p_output_type = 'VARCHAR2' ) THEN
      x_tchar := x_tchar ||' '||l_buffer;
   ELSE
      Append_VARCHAR_to_LOB (x_tlob, l_buffer);
   END IF;

   /* As per the TDD review, we will add this feature in the future
   -- Get the Activities Associated Details ------------------------------
   l_buffer := NULL;
   FOR activity_name in Activity(l_gen_object_id) LOOP
     l_buffer := l_buffer ||' '|| activity_name.value;
   END LOOP;

   IF ( p_output_type = 'VARCHAR2' ) THEN
      x_tchar := x_tchar ||' '||l_buffer;
   ELSE
      Append_VARCHAR_to_LOB (x_tlob, l_buffer);
   END IF;


   -- Get the Meters Associated Details ------------------------------------
   l_buffer := NULL;
   FOR meter_name in Meter(l_gen_object_id) LOOP
     l_buffer := l_buffer ||' '|| meter_name.value;
   END LOOP;

   IF ( p_output_type = 'VARCHAR2' ) THEN
      x_tchar := x_tchar ||' '||l_buffer;
   ELSE
      Append_VARCHAR_to_LOB (x_tlob, l_buffer);
   END IF;
*/

   Append_VARCHAR_to_LOB (x_tlob, ' ', 'END');


EXCEPTION

   WHEN others THEN
      --eam_text_util.Log_Error ('SQL_ERROR', SQLERRM);
      --IF (g_Debug) THEN Debug(l_item_id, l_org_id, l_item_code, '** 9: ' || SQLERRM); END IF;
      RAISE;

END Get_Asset_Text;


-- -----------------------------------------------------------------------------
--  				Get_Wo_Text
--           Procedure called from the Intermedia index for work ordersto find the text on which index has to be created
-- -----------------------------------------------------------------------------

PROCEDURE Get_Wo_Text
(
   p_rowid          IN             ROWID
 , p_output_type    IN             VARCHAR2
 , x_tlob           IN OUT NOCOPY  CLOB
 , x_tchar          IN OUT NOCOPY  VARCHAR2
)
IS
   l_api_name		CONSTANT    VARCHAR2(30)  :=  'Get_Wo_Text';
   l_return_status	VARCHAR2(1);
   l_wip_entity_id	NUMBER;
   l_org_id		NUMBER;
   l_priority              NUMBER;
   l_work_order_type      NUMBER;
   l_activity_type           VARCHAR2(30);
   l_activity_cause      VARCHAR2(30);
   l_activity_source     VARCHAR2(30);
   l_maint_obj_type     NUMBER;

   l_buffer		VARCHAR2(32767);

   CURSOR Operation(p_wip_entity_id NUMBER) IS
   SELECT
		wo.operation_seq_num||' '||bd.department_code as value
    FROM WIP_OPERATIONS wo,BOM_DEPARTMENTS bd
    WHERE wo.wip_entity_id=p_wip_entity_id
    AND wo.department_id=bd.department_id;

    CURSOR Resource_Details(p_wip_entity_id NUMBER) IS
    SELECT
         br.resource_code as value
    FROM WIP_OPERATION_RESOURCES wor,BOM_RESOURCES br
    WHERE wor.wip_entity_id= p_wip_entity_id
    AND wor.resource_id = br.resource_id;

    CURSOR Employee(p_wip_entity_id NUMBER) IS
    SELECT
         ppf.full_name as value
    FROM WIP_OP_RESOURCE_INSTANCES wori,
                BOM_RESOURCE_EMPLOYEES bre,PER_ALL_PEOPLE_F ppf
    WHERE wori.wip_entity_id = p_wip_entity_id
    AND wori.instance_id = bre.instance_id
    AND bre.person_id = ppf.person_id;


   CURSOR Work_Order(p_wip_entity_id NUMBER,p_maint_obj_type NUMBER,p_org_id NUMBER) IS
   SELECT (Tag_begin_work_order ||' '||we.wip_entity_name||
		    ' '||wdj.description||' '||cii.instance_number||' '||msik.concatenated_segments||' '||
                     cii.serial_number||' '||msik1.concatenated_segments||' '||Tag_end_work_order||
                     ' '||bd.department_code||' '||PJM_PROJECT.ALL_PROJ_IDTONUM(wdj.project_id)||' '||
		    PJM_PROJECT.ALL_TASK_IDTONUM(wdj.task_id)) as value
   FROM  WIP_ENTITIES we,WIP_DISCRETE_JOBS wdj,CSI_ITEM_INSTANCES cii,
                 EAM_WORK_ORDER_DETAILS ewod,
		 BOM_DEPARTMENTS bd, MTL_SYSTEM_ITEMS_B_KFV msik, MTL_SYSTEM_ITEMS_B_KFV msik1,
		 MTL_PARAMETERS mp
   WHERE we.wip_entity_id = p_wip_entity_id
   AND we.wip_entity_id = wdj.wip_entity_id
   AND wdj.wip_entity_id = ewod.wip_entity_id
   AND wdj.owning_department = bd.department_id(+)
   AND msik1.organization_id(+)=wdj.organization_id
  AND msik1.inventory_item_id(+)=wdj.primary_item_id
  AND msik.inventory_item_id=NVL(wdj.rebuild_item_id,wdj.asset_group_id)
  AND msik.organization_id = mp.organization_id
  AND cii.instance_id(+)=DECODE(wdj.maintenance_object_type,p_maint_obj_type,wdj.maintenance_object_id,NULL)
  AND mp.maint_organization_id = p_org_id;

   CURSOR lookup_meaning(p_lookup_type VARCHAR2, p_lookup_code VARCHAR2) IS
   SELECT meaning
     FROM fnd_lookup_values
    WHERE lookup_type = p_lookup_type
      AND lookup_code = p_lookup_code;

    CURSOR status(p_wip_entity_id NUMBER) IS
    SELECT NVL(ewst.user_defined_status,flv.meaning) as value
    FROM EAM_WORK_ORDER_DETAILS ewod, EAM_WO_STATUSES_B ewsb,
                 EAM_WO_STATUSES_TL ewst,FND_LOOKUP_VALUES flv
		 WHERE ewod.wip_entity_id = p_wip_entity_id
                  AND ewod.user_defined_status_id  = ewsb.status_id
		  AND ewsb.status_id = ewst.status_id(+)
		  AND flv.lookup_type(+) = 'WIP_JOB_STATUS'
		  AND flv.lookup_code(+) = ewsb.status_id;


BEGIN

   -----------------------------------------------------------
   -- Get WO Data
   -----------------------------------------------------------
   l_buffer := NULL;

   BEGIN

      SELECT
         ewot.wip_entity_id,ewot.organization_id,wdj.priority,wdj.work_order_type,
	   wdj.activity_type,wdj.activity_cause,wdj.activity_source
      INTO
         l_wip_entity_id,l_org_id,l_priority,l_work_order_type,l_activity_type,l_activity_cause,l_activity_source
      FROM
         eam_work_order_text ewot,wip_discrete_jobs wdj
      WHERE
           ewot.rowid = p_rowid
	   AND ewot.wip_entity_id = wdj.wip_entity_id;

   EXCEPTION
      WHEN no_data_found THEN
	 Raise;
   END;


   -- Get the Work Order details -------------------
   l_buffer := NULL;

   l_maint_obj_type := 3;
   FOR work_details in Work_Order(l_wip_entity_id,l_maint_obj_type,l_org_id)
    LOOP
    l_buffer := l_buffer ||' '|| work_details.value;
     EXIT;       --return after first row
   END LOOP;

   IF ( p_output_type = 'VARCHAR2' ) THEN
      x_tchar := l_buffer;
   ELSE
      Append_VARCHAR_to_LOB (x_tlob, ' ', 'BEGIN');
      Append_VARCHAR_to_LOB (x_tlob, l_buffer);
   END IF;

 -- Get the work order status details in all the langauges so that text search fetches the correct work order
 -- irrespective of the current language of the user. To fetch status for all languages we are fetching from
 -- base tables instaed of view
   l_buffer := NULL;
   FOR status_details in Status(l_wip_entity_id) LOOP
     l_buffer := l_buffer ||' '|| status_details.value;
   END LOOP;

   IF ( p_output_type = 'VARCHAR2' ) THEN
      x_tchar := x_tchar ||' '||l_buffer;
   ELSE
      Append_VARCHAR_to_LOB (x_tlob, l_buffer);
   END IF;

   -- Get the Operation details -------------------------------------------
   l_buffer := NULL;
   FOR op_details in Operation(l_wip_entity_id) LOOP
     l_buffer := l_buffer ||' '|| op_details.value;
   END LOOP;

   IF ( p_output_type = 'VARCHAR2' ) THEN
      x_tchar := x_tchar ||' '||l_buffer;
   ELSE
      Append_VARCHAR_to_LOB (x_tlob, l_buffer);
   END IF;

   -- Get the Resource details ---------------------------------
   l_buffer := NULL;
   FOR res_details in Resource_Details(l_wip_entity_id) LOOP
     l_buffer := l_buffer ||' '|| res_details.value;
   END LOOP;

   IF ( p_output_type = 'VARCHAR2' ) THEN
      x_tchar := x_tchar ||' '||l_buffer;
   ELSE
      Append_VARCHAR_to_LOB (x_tlob, l_buffer);
   END IF;

   -- Get the Employee Details ------------------------------
   l_buffer := NULL;
   FOR emp_details in Employee(l_wip_entity_id) LOOP
     l_buffer := l_buffer ||' '|| emp_details.value;
   END LOOP;

   IF ( p_output_type = 'VARCHAR2' ) THEN
      x_tchar := x_tchar ||' '||l_buffer;
   ELSE
      Append_VARCHAR_to_LOB (x_tlob, l_buffer);
   END IF;

--Get the Work Order Priority details--------------
   l_buffer := NULL;
   FOR lookup_details in lookup_meaning('WIP_EAM_ACTIVITY_PRIORITY',TO_CHAR(l_priority)) LOOP
     l_buffer := l_buffer ||' '|| lookup_details.meaning;
   END LOOP;

   IF ( p_output_type = 'VARCHAR2' ) THEN
      x_tchar := x_tchar ||' '||l_buffer;
   ELSE
      Append_VARCHAR_to_LOB (x_tlob, l_buffer);
   END IF;

--Get the Work Order Type details--------------
   l_buffer := NULL;
   FOR lookup_details in lookup_meaning('WIP_EAM_WORK_ORDER_TYPE',TO_CHAR(l_work_order_type)) LOOP
     l_buffer := l_buffer ||' '|| lookup_details.meaning;
   END LOOP;

   IF ( p_output_type = 'VARCHAR2' ) THEN
      x_tchar := x_tchar ||' '||l_buffer;
   ELSE
      Append_VARCHAR_to_LOB (x_tlob, l_buffer);
   END IF;

--Get the Activity Type details--------------
   l_buffer := NULL;
   FOR lookup_details in lookup_meaning('MTL_EAM_ACTIVITY_TYPE',l_activity_type) LOOP
     l_buffer := l_buffer ||' '|| lookup_details.meaning;
   END LOOP;

   IF ( p_output_type = 'VARCHAR2' ) THEN
      x_tchar := x_tchar ||' '||l_buffer;
   ELSE
      Append_VARCHAR_to_LOB (x_tlob, l_buffer);
   END IF;

--Get the Activity Cause details--------------
   l_buffer := NULL;
   FOR lookup_details in lookup_meaning('MTL_EAM_ACTIVITY_CAUSE',l_activity_cause) LOOP
     l_buffer := l_buffer ||' '|| lookup_details.meaning;
   END LOOP;

   IF ( p_output_type = 'VARCHAR2' ) THEN
      x_tchar := x_tchar ||' '||l_buffer;
   ELSE
      Append_VARCHAR_to_LOB (x_tlob, l_buffer);
   END IF;

--Get the Activity Source details--------------
   l_buffer := NULL;
   FOR lookup_details in lookup_meaning('MTL_EAM_ACTIVITY_SOURCE',l_activity_source) LOOP
     l_buffer := l_buffer ||' '|| lookup_details.meaning;
   END LOOP;

   IF ( p_output_type = 'VARCHAR2' ) THEN
      x_tchar := x_tchar ||' '||l_buffer;
   ELSE
      Append_VARCHAR_to_LOB (x_tlob, l_buffer);
   END IF;


--End the LOB
   Append_VARCHAR_to_LOB (x_tlob, ' ', 'END');


EXCEPTION
   WHEN others THEN
      RAISE;
END Get_Wo_Text;


-- -----------------------------------------------------------------------------
--  				Process_Asset_DML_Opn
---		Procedure to insert / update / delete records in eam_asset_text
-- -----------------------------------------------------------------------------
PROCEDURE Process_Asset_DML_Opn
(
   p_event                IN  VARCHAR2
,  p_instance_id          IN  NUMBER
,  p_last_update_date     IN  VARCHAR2    DEFAULT  FND_API.G_MISS_DATE
,  p_last_updated_by      IN  VARCHAR2    DEFAULT  FND_API.G_MISS_NUM
,  p_last_update_login    IN  VARCHAR2    DEFAULT  FND_API.G_MISS_NUM
)
IS
   l_text_ins        VARCHAR2(1);
   l_text_upd        VARCHAR2(1);
   l_count           NUMBER;
BEGIN
   l_text_ins        :=  '1';
   l_text_upd        :=  '2';

   SELECT count(instance_id) INTO l_count
    FROM eam_asset_text WHERE instance_id = p_instance_id AND rownum = 1;

   IF ( p_event = 'UPDATE' OR p_event = 'INSERT' ) THEN
     IF (l_count = 1) THEN
      UPDATE eam_asset_text
         SET text                   =  l_text_upd
           , last_update_date       =  SYSDATE
           , last_updated_by        =  DECODE(p_last_updated_by,   FND_API.G_MISS_NUM, last_updated_by, p_last_updated_by)
           , last_update_login      =  DECODE(p_last_update_login, FND_API.G_MISS_NUM, last_update_login, p_last_update_login)
       WHERE instance_id  = p_instance_id;

     ELSIF (l_count = 0) THEN

      INSERT INTO eam_asset_text
      (
          instance_id
        , text
        , creation_date
        , created_by
        , last_update_date
        , last_updated_by
        , last_update_login
      )
      values (
        p_instance_id
        , l_text_ins
        , SYSDATE
        , fnd_global.user_id
        , SYSDATE
        , DECODE(p_last_updated_by,   FND_API.G_MISS_NUM, fnd_global.user_id,   p_last_updated_by)
        , DECODE(p_last_update_login, FND_API.G_MISS_NUM, fnd_global.login_id, p_last_update_login));
     END IF;
   ELSIF ( p_event = 'DELETE' ) THEN
      DELETE FROM eam_asset_text
      WHERE p_instance_id = p_instance_id;

   END IF;  -- p_event
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
  null;
END Process_Asset_DML_Opn;




-- -----------------------------------------------------------------------------
--  				Process_Asset_Update_Event
---		Procedure called when an asset is create/updated
-- -----------------------------------------------------------------------------
PROCEDURE Process_Asset_Update_Event
(
   p_event                IN  VARCHAR2    DEFAULT  NULL
,  p_instance_id          IN  NUMBER
,  p_commit               IN  VARCHAR2    DEFAULT  FND_API.G_FALSE
,  p_last_update_date     IN  VARCHAR2    DEFAULT  FND_API.G_MISS_DATE
,  p_last_updated_by      IN  VARCHAR2    DEFAULT  FND_API.G_MISS_NUM
,  p_last_update_login    IN  VARCHAR2    DEFAULT  FND_API.G_MISS_NUM
)
IS
   l_eam             VARCHAR2(5);
   l_ctx             VARCHAR2(8);
   l_table           VARCHAR2(25);
   l_index           VARCHAR2(25);
   l_status          VARCHAR2(15);
   l_count           NUMBER;
BEGIN

  IF (p_instance_id <> -1 AND p_event IS NOT NULL) THEN
    /* Perform DML operation */
    Process_Asset_DML_Opn(   p_event
			  ,  p_instance_id
			  ,  p_last_update_date
			  ,  p_last_updated_by
			  ,  p_last_update_login  );
     IF (p_commit = FND_API.G_TRUE) THEN
       COMMIT;
     END IF;
   END IF;

   /* If Text index exists execute sync up */
   IF (p_commit = FND_API.G_TRUE OR p_instance_id = -1) THEN

     l_eam := 'EAM';
     l_ctx := 'CTXSYS';
     l_table := 'EAM_ASSET_TEXT';
     l_index :=	'EAM_ASSET_TEXT_CTX1';
     l_status :=  'VALID';
     SELECT count(*) into l_count
       FROM all_indexes
      WHERE (owner = l_eam OR owner = USER OR owner = l_ctx)
	AND table_name = l_table AND index_name = l_index
	AND status = l_status AND domidx_status = l_status AND domidx_opstatus = l_status;
     IF (l_count > 0) THEN
	EXECUTE IMMEDIATE
	   ' BEGIN                             '||
	   ' eam_text_util.Sync_Index(''EAM_ASSET_TEXT_CTX1''); '||
	   ' END;';
	   /* Calling sync_index would cause database commit. Should be called after commit */
     END IF;
   END IF;

EXCEPTION

   WHEN others THEN
      --Raise_Application_Error (-20001, 'Process_Asset_Update_Event: ' || SQLERRM);
      RAISE;

END Process_Asset_Update_Event;

-- -----------------------------------------------------------------------------
--  				Process_Wo_DML_Opn
---		Procedure to insert / update / delete records in eam_work_order_text
-- -----------------------------------------------------------------------------
PROCEDURE Process_Wo_Dml_Opn
 (
   p_event                          IN              VARCHAR2,
   p_wip_entity_id            IN        NUMBER,
   p_organization_id        IN        NUMBER
,  p_last_update_date     IN  DATE    DEFAULT  FND_API.G_MISS_DATE
,  p_last_updated_by      IN  NUMBER    DEFAULT  FND_API.G_MISS_NUM
,  p_last_update_login    IN  NUMBER   DEFAULT  FND_API.G_MISS_NUM
)
IS
   l_text_ins        VARCHAR2(1)  :=  '1';
   l_text_upd        VARCHAR2(1)  :=  '2';
BEGIN

   IF ( p_event = 'UPDATE' ) THEN
      UPDATE eam_work_order_text
         SET text                   =  l_text_upd
           , last_update_date       =  SYSDATE
           , last_updated_by        =  FND_GLOBAL.user_id
           , last_update_login      =  FND_GLOBAL.login_id
       WHERE wip_entity_id = p_wip_entity_id;

   ELSIF ( p_event = 'INSERT' ) THEN
      INSERT INTO eam_work_order_text
      (
          organization_id
	, wip_entity_id
        , text
        , creation_date
        , created_by
        , last_update_date
        , last_updated_by
        , last_update_login
       )
     values
     (
       p_organization_id,
       p_wip_entity_id,
       l_text_ins,
       SYSDATE,
       FND_GLOBAL.user_id,
       SYSDATE,
       FND_GLOBAL.user_id,
       FND_GLOBAL.login_id
      );
   END IF;  -- p_event


EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
	NULL;
 END Process_Wo_Dml_Opn;

-- -----------------------------------------------------------------------------
--  				Process_Wo_Event
---   Proedure called when a workorder  is created/updated
-- -----------------------------------------------------------------------------

PROCEDURE Process_Wo_Event
(
   p_event                IN        VARCHAR2 DEFAULT  NULL,
   p_wip_entity_id        IN        NUMBER,
   p_organization_id      IN        NUMBER   DEFAULT  NULL
,  p_commit               IN  VARCHAR2    DEFAULT  FND_API.G_FALSE
,  p_last_update_date     IN  DATE    DEFAULT  FND_API.G_MISS_DATE
,  p_last_updated_by      IN  NUMBER    DEFAULT  FND_API.G_MISS_NUM
,  p_last_update_login    IN  NUMBER   DEFAULT  FND_API.G_MISS_NUM
)
IS
   l_eam             VARCHAR2(5);
   l_ctx             VARCHAR2(8);
   l_table           VARCHAR2(25);
   l_index           VARCHAR2(30);
   l_status          VARCHAR2(15);
   l_count           NUMBER;

BEGIN

    /* Perform DML Operation */
   IF (p_wip_entity_id <> -1 AND p_event IS NOT NULL) THEN
      Process_Wo_Dml_Opn
	     (p_event,
	      p_wip_entity_id,
	      p_organization_id,
	      p_last_update_date,
	      p_last_updated_by,
	      p_last_update_login
	      );

    END IF;

   /* If Text index exists execute sync up */
   IF (p_commit = FND_API.G_TRUE OR p_wip_entity_id = -1) THEN
     l_eam := 'EAM';
     l_ctx := 'CTXSYS';
     l_table := 'EAM_WORK_ORDER_TEXT';
     l_index :=	'EAM_WORK_ORDER_TEXT_CTX1';
     l_status :=  'VALID';
     SELECT count(*) into l_count
       FROM all_indexes
      WHERE (owner = l_eam OR owner = USER OR owner = l_ctx)
	AND table_name = l_table AND index_name = l_index
	AND status = l_status AND domidx_status = l_status AND domidx_opstatus = l_status;
     IF (l_count > 0) THEN
       EXECUTE IMMEDIATE
	   ' BEGIN                             '||
	   ' eam_text_util.Sync_Index(''EAM_WORK_ORDER_TEXT_CTX1''); '||
	   ' END;';
     END IF;
   END IF;

EXCEPTION
   WHEN others THEN
      RAISE;
END Process_Wo_Event;

/***
*****   Procedure called when a status code is updated from User Defined Statuses form
***/
PROCEDURE Process_Status_Update_Event
(
   p_event                IN        VARCHAR2  DEFAULT  NULL,
   p_status_id        IN        NUMBER
,  p_commit               IN  VARCHAR2    DEFAULT  FND_API.G_FALSE
,  p_last_update_date     IN  DATE    DEFAULT  FND_API.G_MISS_DATE
,  p_last_updated_by      IN  NUMBER    DEFAULT  FND_API.G_MISS_NUM
,  p_last_update_login    IN  NUMBER   DEFAULT  FND_API.G_MISS_NUM
 ,  x_return_status     IN OUT NOCOPY VARCHAR2
)
IS
   l_eam             VARCHAR2(5);
   l_ctx             VARCHAR2(8);
   l_table           VARCHAR2(25);
   l_index           VARCHAR2(30);
   l_status          VARCHAR2(15);
   l_count           NUMBER;

   CURSOR workorders(l_status_id NUMBER) IS
		   SELECT ewod.wip_entity_id,ewod.organization_id
		   FROM EAM_WORK_ORDER_DETAILS ewod
		   WHERE ewod.user_defined_status_id = l_status_id;

BEGIN

    /* Perform DML Operation */
   IF (p_status_id <> -1) THEN
         FOR wo in workorders(p_status_id) LOOP
			      Process_Wo_Dml_Opn
				     ('UPDATE',
				      wo.wip_entity_id,
				      wo.organization_id,
				      p_last_update_date,
				      p_last_updated_by,
				      p_last_update_login
				      );
	 END LOOP;
    END IF;

   /* If Text index exists execute sync up */
   IF (p_commit = FND_API.G_TRUE OR p_status_id = -1) THEN

		     l_eam := 'EAM';
		     l_ctx := 'CTXSYS';
		     l_table := 'EAM_WORK_ORDER_TEXT';
		     l_index :=	'EAM_WORK_ORDER_TEXT_CTX1';
		     l_status :=  'VALID';

		     SELECT count(*) into l_count
		       FROM all_indexes
		      WHERE (owner = l_eam OR owner = USER OR owner = l_ctx)
			AND table_name = l_table AND index_name = l_index
			AND status = l_status AND domidx_status = l_status AND domidx_opstatus = l_status;

		     IF (l_count > 0) THEN
		       EXECUTE IMMEDIATE
			   ' BEGIN                             '||
			   ' eam_text_util.Sync_Index(''EAM_WORK_ORDER_TEXT_CTX1''); '||
			   ' END;';
		     END IF;

   END IF;

EXCEPTION
	   WHEN others THEN
	      RAISE;
END Process_Status_Update_Event;

-- -----------------------------------------------------------------------------
--  				Sync_Index
---	Procedure called when the intermedia  index has to be updated
-- -----------------------------------------------------------------------------
PROCEDURE Sync_Index ( p_idx_name  IN  VARCHAR2)
IS
BEGIN
   AD_CTX_DDL.Sync_Index ( idx_name  =>  g_Index_Owner ||'.'|| p_idx_name);
END Sync_Index;


-- -----------------------------------------------------------------------------
--				  get_Prod_Schema
-- -----------------------------------------------------------------------------

FUNCTION get_Prod_Schema
RETURN VARCHAR2
IS
BEGIN
   RETURN (g_Prod_Schema);
END get_Prod_Schema;

-- -----------------------------------------------------------------------------
--				get_DB_Version_Num
-- -----------------------------------------------------------------------------

FUNCTION get_DB_Version_Num
RETURN NUMBER
IS
BEGIN
   RETURN (g_DB_Version_Num);
END get_DB_Version_Num;

FUNCTION get_DB_Version_Str
RETURN VARCHAR2
IS
BEGIN
   RETURN (g_DB_Version_Str);
END get_DB_Version_Str;


-- *****************************************************************************
-- **                      Package initialization block                       **
-- *****************************************************************************

BEGIN

   ------------------------------------------------------------------
   -- Determine index schema and store in a private global variable
   ------------------------------------------------------------------

   g_installed := FND_INSTALLATION.Get_App_Info ('EAM', g_inst_status, g_industry, g_Prod_Schema);
   g_Index_Owner := g_Prod_Schema;

   -------------------------
   -- Determine DB version
   -------------------------

   DBMS_UTILITY.db_Version (g_DB_Version_Str, g_compatibility);
   l_DB_Version_Str := SUBSTR(g_DB_Version_Str, 1, INSTR(g_DB_Version_Str, '.', 1, 2) - 1);
   SELECT SUBSTR(VALUE,0,1) into l_DB_Numeric_Character
     FROM V$NLS_PARAMETERS
    WHERE PARAMETER = 'NLS_NUMERIC_CHARACTERS';
   g_DB_Version_Num := TO_NUMBER( REPLACE(l_DB_Version_Str, '.', l_DB_Numeric_Character) );


END eam_text_util;



/

  GRANT EXECUTE ON "APPS"."EAM_TEXT_UTIL" TO "CTXSYS";
