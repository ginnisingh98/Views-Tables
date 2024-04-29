--------------------------------------------------------
--  DDL for Package Body CSD_TO_FORM_REPAIR_JOB_XREF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_TO_FORM_REPAIR_JOB_XREF" AS
  /* $Header: csdgdrjb.pls 115.13 2003/09/15 21:35:07 sragunat ship $*/
  -- Start of Comments
  -- Package name     : CSD_TO_FORM_REPAIR_JOB_XREF
  -- Purpose          : Takes all parameters from the FORM and construct those parameters into a record for calling
  --                    the prviate API in the CSD_REPAIR_HISTORY_PVT package.
  -- History          : 11/17/1999, Created by Raghavan
  -- History          : 12/26/2001, TRAVI added columns INVENTORY_ITEM_ID and ITEM_REVISION
  -- History          : 01/17/2002, TRAVI added column OBJECT_VERSION_NUMBER
  -- History          : 08/20/2003, Shiv Ragunathan, 11.5.10 Changes: Added
  -- History          :   parameters p_source_type_code, p_source_id1,
  -- History          :   p_ro_service_code_id, p_job_name to
  -- History          :   Validate_And_Write.
  -- NOTE             :
  -- End of Comments
g_debug NUMBER := csd_gen_utility_pvt.g_debug_level;
  -- travi changes
  PROCEDURE Validate_And_Write (
        P_Api_Version_Number           IN   NUMBER,
        P_Init_Msg_List                IN   VARCHAR2     := FND_API.G_FALSE,
        P_Commit                       IN   VARCHAR2     := FND_API.G_FALSE,
        p_validation_level             IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
        p_action_code                  IN   NUMBER,    /* 0 = insert, 1 = update, 2 = delete */
        px_REPAIR_JOB_XREF_ID   IN OUT NOCOPY NUMBER,
        p_CREATED_BY    NUMBER,
        p_CREATION_DATE    DATE,
        p_LAST_UPDATED_BY    NUMBER,
        p_LAST_UPDATE_DATE    DATE,
        p_LAST_UPDATE_LOGIN    NUMBER,
        p_REPAIR_LINE_ID    NUMBER,
        p_WIP_ENTITY_ID    NUMBER,
        p_GROUP_ID    NUMBER,
        p_ORGANIZATION_ID    NUMBER,
        p_QUANTITY    NUMBER,
        p_INVENTORY_ITEM_ID    NUMBER,
        p_ITEM_REVISION    VARCHAR2,
        p_SOURCE_TYPE_CODE 		VARCHAR2,
        p_SOURCE_ID1  			NUMBER,
        p_RO_SERVICE_CODE_ID 		NUMBER,
        p_JOB_NAME      		VARCHAR2,
        p_OBJECT_VERSION_NUMBER    	NUMBER,
        p_ATTRIBUTE_CATEGORY    	VARCHAR2,
        p_ATTRIBUTE1    VARCHAR2,
        p_ATTRIBUTE2    VARCHAR2,
        p_ATTRIBUTE3    VARCHAR2,
        p_ATTRIBUTE4    VARCHAR2,
        p_ATTRIBUTE5    VARCHAR2,
        p_ATTRIBUTE6    VARCHAR2,
        p_ATTRIBUTE7    VARCHAR2,
        p_ATTRIBUTE8    VARCHAR2,
        p_ATTRIBUTE9    VARCHAR2,
        p_ATTRIBUTE10    VARCHAR2,
        p_ATTRIBUTE11    VARCHAR2,
        p_ATTRIBUTE12    VARCHAR2,
        p_ATTRIBUTE13    VARCHAR2,
        p_ATTRIBUTE14    VARCHAR2,
        p_ATTRIBUTE15    VARCHAR2,
       p_quantity_completed NUMBER,
        X_Return_Status              OUT NOCOPY  VARCHAR2,
        X_Msg_Count                  OUT NOCOPY  NUMBER,
        X_Msg_Data                   OUT NOCOPY  VARCHAR2
       )
  IS
      l_repair_job_xref_rec CSD_REPAIR_JOB_XREF_PVT.REPJOBXREF_Rec_Type;

               l_Return_Status  varchar2(100);
               l_Msg_Count         number;
               l_Msg_Data              varchar2(100);
      p_temp_job_xref_id number;

  BEGIN
      -- initiate X_Msg_Count
      X_Msg_Count := 0;
-- travi changes
l_repair_job_xref_rec.REPAIR_JOB_XREF_ID  :=            px_REPAIR_JOB_XREF_ID   ;
l_repair_job_xref_rec.CREATED_BY         :=         p_CREATED_BY    ;
l_repair_job_xref_rec.CREATION_DATE     :=          p_CREATION_DATE;
l_repair_job_xref_rec.LAST_UPDATED_BY  :=           p_LAST_UPDATED_BY   ;
l_repair_job_xref_rec.LAST_UPDATE_DATE:=            p_LAST_UPDATE_DATE ;
l_repair_job_xref_rec.LAST_UPDATE_LOGIN:=           p_LAST_UPDATE_LOGIN    ;
l_repair_job_xref_rec.REPAIR_LINE_ID  :=            p_REPAIR_LINE_ID    ;
l_repair_job_xref_rec.WIP_ENTITY_ID  :=         p_WIP_ENTITY_ID    ;
l_repair_job_xref_rec.GROUP_ID      :=          p_GROUP_ID    ;
l_repair_job_xref_rec.ORGANIZATION_ID :=            p_ORGANIZATION_ID ;
l_repair_job_xref_rec.QUANTITY       :=         p_QUANTITY   ;
l_repair_job_xref_rec.INVENTORY_ITEM_ID       :=            p_INVENTORY_ITEM_ID   ;
l_repair_job_xref_rec.ITEM_REVISION :=          p_ITEM_REVISION;
l_repair_job_xref_rec.SOURCE_TYPE_CODE        :=         p_SOURCE_TYPE_CODE   ;
l_repair_job_xref_rec.SOURCE_ID1              :=         p_SOURCE_ID1;
l_repair_job_xref_rec.RO_SERVICE_CODE_ID      :=         p_RO_SERVICE_CODE_ID;
l_repair_job_xref_rec.JOB_NAME                :=         p_JOB_NAME;

-- travi l_repair_job_xref_rec.OBJECT_VERSION_NUMBER       :=           p_OBJECT_VERSION_NUMBER   ;

l_repair_job_xref_rec.ATTRIBUTE_CATEGORY :=         p_ATTRIBUTE_CATEGORY;
l_repair_job_xref_rec.ATTRIBUTE1        :=          p_ATTRIBUTE1   ;
l_repair_job_xref_rec.ATTRIBUTE2       :=           p_ATTRIBUTE2 ;
l_repair_job_xref_rec.ATTRIBUTE3      :=            p_ATTRIBUTE3  ;
l_repair_job_xref_rec.ATTRIBUTE4  :=            p_ATTRIBUTE4  ;
l_repair_job_xref_rec.ATTRIBUTE5 :=         p_ATTRIBUTE5  ;
l_repair_job_xref_rec.ATTRIBUTE6:=          p_ATTRIBUTE6  ;
l_repair_job_xref_rec.ATTRIBUTE7    :=          p_ATTRIBUTE7  ;
l_repair_job_xref_rec.ATTRIBUTE8   :=           p_ATTRIBUTE8  ;
l_repair_job_xref_rec.ATTRIBUTE9  :=            p_ATTRIBUTE9  ;
l_repair_job_xref_rec.ATTRIBUTE10:=         p_ATTRIBUTE10   ;
l_repair_job_xref_rec.ATTRIBUTE11      :=           p_ATTRIBUTE11   ;
l_repair_job_xref_rec.ATTRIBUTE12     :=            p_ATTRIBUTE12  ;
l_repair_job_xref_rec.ATTRIBUTE13   :=          p_ATTRIBUTE13 ;
l_repair_job_xref_rec.ATTRIBUTE14  :=           p_ATTRIBUTE14   ;
l_repair_job_xref_rec.ATTRIBUTE15 :=            p_ATTRIBUTE15  ;
l_repair_job_xref_rec.quantity_completed := p_quantity_completed;

      -- check p_action_code
      if p_action_code not in (0, 1, 2) then
          X_Return_Status := FND_API.G_RET_STS_ERROR;
          X_Msg_Count := X_Msg_Count + 1;
          X_Msg_Data := 'Invalid action codes should indicate an Insert, Delete or Update action.';
         GOTO end_job;
      end if;



       if p_action_code = 0 then
          -- call the private insert (create) procedure

         -- travi
        l_repair_job_xref_rec.OBJECT_VERSION_NUMBER := 1;
IF (g_debug > 0 ) THEN
        csd_gen_utility_pvt.add('CSD_TO_FORM_REPAIR_JOB_XREF.Validate_And_Write create OVN '||to_char(l_repair_job_xref_rec.OBJECT_VERSION_NUMBER));
END IF;


           CSD_REPAIR_JOB_XREF_PVT.Create_repjobxref(
               P_Api_Version_Number    => p_api_version_number,
               P_Init_Msg_List         => p_init_msg_list,
               P_Commit                => p_commit,
               p_validation_level      => p_validation_level,
               P_repjobxref_rec               => l_repair_job_xref_rec,
               X_REPAIR_JOB_XREF_ID     => p_temp_job_xref_id,
               X_Return_Status         => l_return_status,
               X_Msg_Count             => l_msg_count,
               X_Msg_Data              => l_msg_data
               );

      elsif p_action_code = 1 then
          -- call the private update procedure

         -- travi
        l_repair_job_xref_rec.OBJECT_VERSION_NUMBER := p_OBJECT_VERSION_NUMBER;
IF (g_debug > 0 ) THEN
        csd_gen_utility_pvt.add('CSD_TO_FORM_REPAIR_JOB_XREF.Validate_And_Write Update OVN '||to_char(l_repair_job_xref_rec.OBJECT_VERSION_NUMBER));
END IF;


           CSD_REPAIR_JOB_XREF_PVT.update_repjobxref(
               P_Api_Version_Number    => p_api_version_number,
               P_Init_Msg_List         => p_init_msg_list,
               P_Commit                => p_commit,
               p_validation_level      => p_validation_level,
               P_repjobxref_rec               => l_repair_job_xref_rec,
               X_Return_Status         => l_return_status,
               X_Msg_Count             => l_msg_count,
               X_Msg_Data              => l_msg_data
               );

      else
        -- call the private delete procedure

         -- travi
        l_repair_job_xref_rec.OBJECT_VERSION_NUMBER := p_OBJECT_VERSION_NUMBER;
IF (g_debug > 0 ) THEN
        csd_gen_utility_pvt.add('CSD_TO_FORM_REPAIR_JOB_XREF.Validate_And_Write Delete OVN '||to_char(l_repair_job_xref_rec.OBJECT_VERSION_NUMBER));
END IF;


           CSD_REPAIR_JOB_XREF_PVT.delete_repjobxref(
               P_Api_Version_Number    => p_api_version_number,
               P_Init_Msg_List         => p_init_msg_list,
               P_Commit                => p_commit,
               p_validation_level      => p_validation_level,
               P_repjobxref_rec        => l_repair_job_xref_rec,
               X_Return_Status         => l_return_status,
               X_Msg_Count             => l_msg_count,
               X_Msg_Data              => l_msg_data
               );
        end if;

     px_repair_job_xref_id := p_temp_job_xref_id;

      <<end_job>>
          null;

  END Validate_And_Write;

  END CSD_TO_FORM_REPAIR_JOB_XREF;

/
