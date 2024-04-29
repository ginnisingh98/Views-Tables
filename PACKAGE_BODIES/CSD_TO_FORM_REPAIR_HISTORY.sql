--------------------------------------------------------
--  DDL for Package Body CSD_TO_FORM_REPAIR_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_TO_FORM_REPAIR_HISTORY" AS
  /* $Header: csdgdrhb.pls 115.9 2002/11/12 21:30:58 sangigup ship $*/
  -- Start of Comments
  -- Package name     : CSD_TO_FORM_REPAIR_HISTORY
  -- Purpose          : Takes all parameters from the FORM and construct those parameters into a record for calling
  --                    the prviate API in the CSD_REPAIR_HISTORY_PVT package.
  -- History          : 11/17/1999, Created by Raghavan
  -- NOTE             :
  -- End of Comments

g_debug NUMBER := csd_gen_utility_pvt.g_debug_level;

PROCEDURE Validate_And_Write (
      P_Api_Version_Number           IN   NUMBER,
      P_Init_Msg_List                IN   VARCHAR2     := FND_API.G_FALSE,
      P_Commit                       IN   VARCHAR2     := FND_API.G_FALSE,
      p_validation_level             IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
      p_action_code                  IN   NUMBER,    /* 0 = insert, 1 = update, 2 = delete */
      px_REPAIR_HISTORY_ID   OUT NOCOPY NUMBER ,
      p_OBJECT_VERSION_NUMBER    in NUMBER            := FND_API.G_MISS_NUM,
      p_REQUEST_ID    in NUMBER            := FND_API.G_MISS_NUM,
      p_PROGRAM_ID    in NUMBER            := FND_API.G_MISS_NUM,
      p_PROGRAM_APPLICATION_ID    in NUMBER            := FND_API.G_MISS_NUM,
      p_PROGRAM_UPDATE_DATE    in DATE            := FND_API.G_MISS_DATE,
      p_CREATED_BY    in NUMBER                   := FND_API.G_MISS_NUM,
      p_CREATION_DATE   in  DATE                  := FND_API.G_MISS_DATE,
      p_LAST_UPDATED_BY   in  NUMBER     :=  FND_API.G_MISS_NUM,
      p_LAST_UPDATE_DATE    in DATE     :=  FND_API.G_MISS_DATE,
      p_REPAIR_LINE_ID    in NUMBER := FND_API.G_MISS_NUM,
      p_EVENT_CODE    in VARCHAR2,
      p_EVENT_DATE    in DATE,
      p_QUANTITY    in NUMBER    := FND_API.G_MISS_NUM,
      p_PARAMN1    in NUMBER    := FND_API.G_MISS_NUM,
      p_PARAMN2    in NUMBER  := FND_API.G_MISS_NUM,
      p_PARAMN3    in NUMBER  := FND_API.G_MISS_NUM,
      p_PARAMN4    in NUMBER  := FND_API.G_MISS_NUM,
      p_PARAMN5    in NUMBER  := FND_API.G_MISS_NUM,
      p_PARAMN6    in NUMBER  := FND_API.G_MISS_NUM,
      p_PARAMN7    in NUMBER  := FND_API.G_MISS_NUM,
      p_PARAMN8    in NUMBER  := FND_API.G_MISS_NUM,
      p_PARAMN9    in NUMBER  := FND_API.G_MISS_NUM,
      p_PARAMN10   in NUMBER  := FND_API.G_MISS_NUM,
      p_PARAMC1    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_PARAMC2    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_PARAMC3    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_PARAMC4    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_PARAMC5    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_PARAMC6    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_PARAMC7    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_PARAMC8    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_PARAMC9    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_PARAMC10   in  VARCHAR2  := FND_API.G_MISS_CHAR,
      p_PARAMD1    in DATE  := FND_API.G_MISS_DATE,
      p_PARAMD2    in DATE  := FND_API.G_MISS_DATE,
      p_PARAMD3    in DATE  := FND_API.G_MISS_DATE,
      p_PARAMD4    in DATE  := FND_API.G_MISS_DATE,
      p_PARAMD5    in DATE  := FND_API.G_MISS_DATE,
      p_PARAMD6    in DATE  := FND_API.G_MISS_DATE,
      p_PARAMD7    in DATE  := FND_API.G_MISS_DATE,
      p_PARAMD8    in DATE  := FND_API.G_MISS_DATE,
      p_PARAMD9    in DATE  := FND_API.G_MISS_DATE,
      p_PARAMD10   in  DATE  := FND_API.G_MISS_DATE,
      p_ATTRIBUTE_CATEGORY    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE1    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE2    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE3    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE4    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE5    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE6    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE7    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE8    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE9    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE10    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE11    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE12    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE13    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE14    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_ATTRIBUTE15    in VARCHAR2  := FND_API.G_MISS_CHAR,
      p_LAST_UPDATE_LOGIN    in NUMBER  := FND_API.G_MISS_CHAR,
      X_Return_Status              OUT NOCOPY  VARCHAR2  ,
      X_Msg_Count                  OUT NOCOPY  NUMBER ,
      X_Msg_Data                   OUT NOCOPY  VARCHAR2
     )
  IS
      l_repair_hist_rec CSD_REPAIR_HISTORY_PVT.REPH_Rec_Type;
      p_temp_repair_line_id number;

  BEGIN
      -- initiate X_Msg_Count
      X_Msg_Count := 0;

      -- check p_action_code
      if p_action_code not in (0, 1, 2) then
          X_Return_Status := FND_API.G_RET_STS_ERROR;
          X_Msg_Count := X_Msg_Count + 1;
          X_Msg_Data := 'Invalid action codes should indicate an Insert, Delete or Update action.';
         GOTO end_job;
      end if;


    L_REPAIR_HIST_REC.REPAIR_HISTORY_ID         :=       px_repair_history_id;
    L_REPAIR_HIST_REC.OBJECT_VERSION_NUMBER     :=        p_OBJECT_VERSION_NUMBER   ;
    L_REPAIR_HIST_REC.REQUEST_ID                :=        p_REQUEST_ID   ;
    L_REPAIR_HIST_REC.PROGRAM_ID                :=        p_PROGRAM_ID  ;
    L_REPAIR_HIST_REC.PROGRAM_APPLICATION_ID    :=        p_PROGRAM_APPLICATION_ID ;
    L_REPAIR_HIST_REC.PROGRAM_UPDATE_DATE       :=        p_PROGRAM_UPDATE_DATE   ;
    L_REPAIR_HIST_REC.CREATED_BY                :=        p_CREATED_BY    ;
    L_REPAIR_HIST_REC.CREATION_DATE             :=        p_CREATION_DATE;
    L_REPAIR_HIST_REC.LAST_UPDATED_BY           :=        p_LAST_UPDATED_BY ;
    L_REPAIR_HIST_REC.LAST_UPDATE_DATE          :=        p_LAST_UPDATE_DATE ;
    L_REPAIR_HIST_REC.REPAIR_LINE_ID            :=        p_REPAIR_LINE_ID  ;
    L_REPAIR_HIST_REC.EVENT_CODE                :=        p_EVENT_CODE    ;
    L_REPAIR_HIST_REC.EVENT_DATE                :=        p_EVENT_DATE   ;
    L_REPAIR_HIST_REC.QUANTITY                  :=        p_QUANTITY    ;
    L_REPAIR_HIST_REC.PARAMN1                   :=        p_PARAMN1    ;
    L_REPAIR_HIST_REC.PARAMN2                   :=        p_PARAMN2   ;
    L_REPAIR_HIST_REC.PARAMN3                   :=        p_PARAMN3  ;
    L_REPAIR_HIST_REC.PARAMN4                   :=        p_PARAMN4 ;
    L_REPAIR_HIST_REC.PARAMN5                   :=        p_PARAMN5;
    L_REPAIR_HIST_REC.PARAMN6                   :=        p_PARAMN6 ;
    L_REPAIR_HIST_REC.PARAMN7                   :=        p_PARAMN7;
    L_REPAIR_HIST_REC.PARAMN8                   :=        p_PARAMN8;
    L_REPAIR_HIST_REC.PARAMN9                   :=        p_PARAMN9 ;
    L_REPAIR_HIST_REC.PARAMN10                  :=        p_PARAMN10;
    L_REPAIR_HIST_REC.PARAMC1                   :=        p_PARAMC1 ;
    L_REPAIR_HIST_REC.PARAMC2  :=         p_PARAMC2;
    L_REPAIR_HIST_REC.PARAMC3 :=          p_PARAMC3;
    L_REPAIR_HIST_REC.PARAMC4  :=         p_PARAMC4;
    L_REPAIR_HIST_REC.PARAMC5  :=         p_PARAMC5;
    L_REPAIR_HIST_REC.PARAMC6 :=          p_PARAMC6;
    L_REPAIR_HIST_REC.PARAMC7   :=        p_PARAMC7;
    L_REPAIR_HIST_REC.PARAMC8  :=         p_PARAMC8;
    L_REPAIR_HIST_REC.PARAMC9   :=        p_PARAMC9;
    L_REPAIR_HIST_REC.PARAMC10      :=        p_PARAMC10 ;
    L_REPAIR_HIST_REC.PARAMD1       :=        p_PARAMD1 ;
    L_REPAIR_HIST_REC.PARAMD2       :=        p_PARAMD2;
    L_REPAIR_HIST_REC.PARAMD3       :=        p_PARAMD3;
    L_REPAIR_HIST_REC.PARAMD4       :=        p_PARAMD4 ;
    L_REPAIR_HIST_REC.PARAMD5       :=        p_PARAMD5;
    L_REPAIR_HIST_REC.PARAMD6       :=        p_PARAMD6;
    L_REPAIR_HIST_REC.PARAMD7       :=        p_PARAMD7 ;
    L_REPAIR_HIST_REC.PARAMD8       :=        p_PARAMD8;
    L_REPAIR_HIST_REC.PARAMD9       :=        p_PARAMD9 ;
    L_REPAIR_HIST_REC.PARAMD10      :=        p_PARAMD10 ;
    L_REPAIR_HIST_REC.ATTRIBUTE_CATEGORY     :=       p_ATTRIBUTE_CATEGORY ;
    L_REPAIR_HIST_REC.ATTRIBUTE1    :=        p_ATTRIBUTE1   ;
    L_REPAIR_HIST_REC.ATTRIBUTE2    :=        p_ATTRIBUTE2  ;
    L_REPAIR_HIST_REC.ATTRIBUTE3    :=        p_ATTRIBUTE3;
    L_REPAIR_HIST_REC.ATTRIBUTE4    :=        p_ATTRIBUTE4 ;
    L_REPAIR_HIST_REC.ATTRIBUTE5    :=        p_ATTRIBUTE5 ;
    L_REPAIR_HIST_REC.ATTRIBUTE6    :=        p_ATTRIBUTE6;
    L_REPAIR_HIST_REC.ATTRIBUTE7    :=        p_ATTRIBUTE7;
    L_REPAIR_HIST_REC.ATTRIBUTE8    :=        p_ATTRIBUTE8;
    L_REPAIR_HIST_REC.ATTRIBUTE9    :=        p_ATTRIBUTE9;
    L_REPAIR_HIST_REC.ATTRIBUTE10   :=        p_ATTRIBUTE10 ;
    L_REPAIR_HIST_REC.ATTRIBUTE11   :=        p_ATTRIBUTE11;
    L_REPAIR_HIST_REC.ATTRIBUTE12   :=        p_ATTRIBUTE12;
    L_REPAIR_HIST_REC.ATTRIBUTE13   :=        p_ATTRIBUTE13;
    L_REPAIR_HIST_REC.ATTRIBUTE14   :=        p_ATTRIBUTE14;
    L_REPAIR_HIST_REC.ATTRIBUTE15   :=        p_ATTRIBUTE15;
    L_REPAIR_HIST_REC.LAST_UPDATE_LOGIN   :=          p_LAST_UPDATE_LOGIN ;

       if p_action_code = 0 then
          -- call the private insert (create) procedure
IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write before CSD_REPAIR_HISTORY_PVT.Create_repair_history call');
END IF;


           CSD_REPAIR_HISTORY_PVT.Create_repair_history(
               P_Api_Version_Number    => p_api_version_number,
               P_Init_Msg_List         => p_init_msg_list,
               P_Commit                => p_commit,
               p_validation_level      => p_validation_level,
               P_reph_rec               => l_repair_hist_rec,
               X_REPAIR_HISTORY_ID     => p_temp_repair_line_id,
               X_Return_Status         => x_return_status,
               X_Msg_Count             => x_msg_count,
               X_Msg_Data              => x_msg_data
               );

IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write after CSD_REPAIR_HISTORY_PVT.Create_repair_history  x_return_status'||x_return_status);
END IF;

      elsif p_action_code = 1 then
          -- call the private update procedure

IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write before CSD_REPAIR_HISTORY_PVT.Update_repair_history call');
END IF;


           CSD_REPAIR_HISTORY_PVT.update_repair_history(
               P_Api_Version_Number    => p_api_version_number,
               P_Init_Msg_List         => p_init_msg_list,
               P_Commit                => p_commit,
               p_validation_level      => p_validation_level,
               P_reph_rec               => l_repair_hist_rec,
               X_Return_Status         => x_return_status,
               X_Msg_Count             => x_msg_count,
               X_Msg_Data              => x_msg_data
               );

IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write after CSD_REPAIR_HISTORY_PVT.Update_repair_history  x_return_status'||x_return_status);
END IF;


      else
        -- call the private delete procedure

IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write before CSD_REPAIR_HISTORY_PVT.Delete_repair_history call');
END IF;



           CSD_REPAIR_HISTORY_PVT.delete_repair_history(
               P_Api_Version_Number    => p_api_version_number,
               P_Init_Msg_List         => p_init_msg_list,
               P_Commit                => p_commit,
               p_validation_level      => p_validation_level,
               P_reph_rec               => l_repair_hist_rec,
               X_Return_Status         => x_return_status,
               X_Msg_Count             => x_msg_count,
               X_Msg_Data              => x_msg_data
               );

IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write after CSD_REPAIR_HISTORY_PVT.Delete_repair_history  x_return_status'||x_return_status);
END IF;


        end if;

     px_repair_history_id := p_temp_repair_line_id;

      <<end_job>>
          null;

  END Validate_And_Write;

  END CSD_TO_FORM_REPAIR_HISTORY;

/
