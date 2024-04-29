--------------------------------------------------------
--  DDL for Package Body CSD_REPAIR_ACTUALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_REPAIR_ACTUALS_PVT" as
/* $Header: csdvactb.pls 120.1 2008/02/09 01:02:32 takwong ship $ csdvactb.pls*/

-- ---------------------------------------------------------
-- Define global variables
-- ---------------------------------------------------------
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdvactb.pls';

-- Global variable for storing the debug level
G_debug_level number   := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

/*--------------------------------------------------------------------*/
/* procedure name: CREATE_REPAIR_ACTUALS                              */
/* description : procedure used to Create Repair Actuals              */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Actuals UI                              */
/* Input Parm  :                                                      */
/*   p_api_version       NUMBER    Req Api Version number             */
/*   p_init_msg_list     VARCHAR2  Opt Initialize message stack       */
/*   p_commit            VARCHAR2  Opt Commits in API                 */
/*   p_validation_level  NUMBER    Opt validation steps               */
/*   px_CSD_REPAIR_ACTUALS_REC REC Req Actuals Record                 */
/* Output Parm :                                                      */
/*   x_return_status     VARCHAR2      Return status after the call.  */
/*   x_msg_count         NUMBER        Number of messages in stack    */
/*   x_msg_data          VARCHAR2      Mesg. text if x_msg_count >= 1 */
/* Change Hist :                                                      */
/*   08/11/03  travikan  Initial Creation.                            */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
    PROCEDURE CREATE_REPAIR_ACTUALS(
        P_Api_Version                IN            NUMBER,
        P_Commit                     IN            VARCHAR2,
        P_Init_Msg_List              IN            VARCHAR2,
        p_validation_level           IN            NUMBER,
        px_CSD_REPAIR_ACTUALS_REC    IN OUT NOCOPY CSD_REPAIR_ACTUALS_REC_TYPE,
        X_Return_Status              OUT    NOCOPY VARCHAR2,
        X_Msg_Count                  OUT    NOCOPY NUMBER,
        X_Msg_Data                   OUT    NOCOPY VARCHAR2
        )

     IS
     -- Variables used in FND Log
     l_stat_level   number   := FND_LOG.LEVEL_STATEMENT;
     l_proc_level   number   := FND_LOG.LEVEL_PROCEDURE;
     l_event_level  number   := FND_LOG.LEVEL_EVENT;
     l_excep_level  number   := FND_LOG.LEVEL_EXCEPTION;
     l_error_level  number   := FND_LOG.LEVEL_ERROR;
     l_unexp_level  number   := FND_LOG.LEVEL_UNEXPECTED;
     l_mod_name     varchar2(2000) := 'csd.plsql.CSD_REPAIR_ACTUALS_PVT.CREATE_REPAIR_ACTUALS';

     l_api_name               CONSTANT VARCHAR2(30)   := 'CREATE_REPAIR_ACTUALS';
     l_api_version            CONSTANT NUMBER         := 1.0;
     l_msg_count              NUMBER;
     l_msg_data               VARCHAR2(100);
     l_msg_index              NUMBER;
     l_dummy                  VARCHAR2(1);
     l_incident_id            NUMBER := NULL;
     l_api_return_status      VARCHAR2(3);

     l_act_count              NUMBER;

    BEGIN
          -- Standard Start of API savepoint
          SAVEPOINT CREATE_REPAIR_ACTUALS;

          -- Standard call to check for call compatibility.
          IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                               p_api_version,
                                               l_api_name,
                                               G_PKG_NAME)
          THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

           -- Initialize message list if p_init_msg_list is set to TRUE.
           IF FND_API.to_Boolean( p_init_msg_list ) THEN
               FND_MSG_PUB.initialize;
           END IF;

           -- Initialize API return status to success
           x_return_status := FND_API.G_RET_STS_SUCCESS;

           -- Api body starts
           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'At the Beginning of create_repair_actuals');
           END IF;

           -- Dump the in parameters in the log file
           -- if the debug level > 5
           -- If fnd_profile.value('CSD_DEBUG_LEVEL') > 5 then
--         if (g_debug > 5) then
--               csd_gen_utility_pvt.dump_actuals_rec
--                        ( p_CSD_REPAIR_ACTUALS_REC => px_CSD_REPAIR_ACTUALS_REC);
--         end if;

           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Begin Check reqd parameter');
           END IF;

           -- Check the required parameter
           CSD_PROCESS_UTIL.Check_Reqd_Param
           ( p_param_value    => px_CSD_REPAIR_ACTUALS_REC.repair_line_id,
             p_param_name     => 'REPAIR_LINE_ID',
             p_api_name       => l_api_name);

           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'End Check reqd parameter');
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Begin Validate Repair Line id');
           END IF;

           -- Validate the repair line ID
           IF NOT( CSD_PROCESS_UTIL.Validate_rep_line_id
                           ( p_repair_line_id  => px_CSD_REPAIR_ACTUALS_REC.repair_line_id )) THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;

           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'End Validate Repair Line id');
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Check if there is only one Actual Header per Repair Order');
           END IF;

           Begin
             select count(*)
               into l_act_count
               from csd_repair_actuals
              where repair_line_id = px_CSD_REPAIR_ACTUALS_REC.repair_line_id;
           Exception
           when others then
                IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                     FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'Others exception error :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
                END IF;
           End;

           IF l_act_count > 0 then
              IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                   FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'Actuals already exists for the repair line Id: '||px_CSD_REPAIR_ACTUALS_REC.repair_line_id);
              END IF;

              FND_MESSAGE.SET_NAME('CSD','CSD_API_ACTUALS_EXISTS');
              FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',px_CSD_REPAIR_ACTUALS_REC.repair_line_id);
              FND_MSG_PUB.ADD;

              IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level) THEN
                FND_LOG.MESSAGE(Fnd_Log.Level_Error,l_mod_name, FALSE);
              END IF;

              RAISE FND_API.G_EXC_ERROR;
          End IF;

          -- Assigning object version number
          px_CSD_REPAIR_ACTUALS_REC.OBJECT_VERSION_NUMBER := 1;

          --
          -- API body
          --
          IF ( Fnd_Log.Level_Procedure >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Procedure,l_mod_name,'Call to CSD_REPAIR_ACTUALS_PKG.Insert_Row');
          END IF;

          BEGIN

          -- Invoke table handler(CSD_REPAIR_ACTUALS_PKG.Insert_Row)
          CSD_REPAIR_ACTUALS_PKG.Insert_Row(
              px_REPAIR_ACTUAL_ID      => px_CSD_REPAIR_ACTUALS_REC.REPAIR_ACTUAL_ID
             ,p_OBJECT_VERSION_NUMBER  => px_CSD_REPAIR_ACTUALS_REC.OBJECT_VERSION_NUMBER
             ,p_REPAIR_LINE_ID         => px_CSD_REPAIR_ACTUALS_REC.REPAIR_LINE_ID
             ,p_CREATED_BY             => FND_GLOBAL.USER_ID
             ,p_CREATION_DATE          => SYSDATE
             ,p_LAST_UPDATED_BY        => FND_GLOBAL.USER_ID
             ,p_LAST_UPDATE_DATE       => SYSDATE
             ,p_LAST_UPDATE_LOGIN      => FND_GLOBAL.CONC_LOGIN_ID
             ,p_ATTRIBUTE_CATEGORY     => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE_CATEGORY
             ,p_ATTRIBUTE1             => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE1
             ,p_ATTRIBUTE2             => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE2
             ,p_ATTRIBUTE3             => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE3
             ,p_ATTRIBUTE4             => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE4
             ,p_ATTRIBUTE5             => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE5
             ,p_ATTRIBUTE6             => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE6
             ,p_ATTRIBUTE7             => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE7
             ,p_ATTRIBUTE8             => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE8
             ,p_ATTRIBUTE9             => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE9
             ,p_ATTRIBUTE10            => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE10
             ,p_ATTRIBUTE11            => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE11
             ,p_ATTRIBUTE12            => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE12
             ,p_ATTRIBUTE13            => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE13
             ,p_ATTRIBUTE14            => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE14
             ,p_ATTRIBUTE15            => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE15
             ,p_BILL_TO_ACCOUNT_ID     => px_CSD_REPAIR_ACTUALS_REC.BILL_TO_ACCOUNT_ID
             ,p_BILL_TO_PARTY_ID       => px_CSD_REPAIR_ACTUALS_REC.BILL_TO_PARTY_ID
             ,p_BILL_TO_PARTY_SITE_ID  => px_CSD_REPAIR_ACTUALS_REC.BILL_TO_PARTY_SITE_ID
             );

          EXCEPTION
              WHEN OTHERS THEN
                   IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                      FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'Others exception n CSD_REPAIR_ACTUALS_PKG.Insert_Row Call :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
                   END IF;
                   x_return_status := FND_API.G_RET_STS_ERROR;
          END;

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
              END IF;

          --
          -- End of API body
          --

          -- Standard check of p_commit.
          IF FND_API.To_Boolean( p_commit ) THEN
               COMMIT WORK;
          END IF;

          -- Standard call to get message count and IF count is  get message info.
          FND_MSG_PUB.Count_And_Get
               (p_count  =>  x_msg_count,
                p_data   =>  x_msg_data );
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'In FND_API.G_EXC_ERROR exception');
              END IF;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              ROLLBACK TO CREATE_REPAIR_ACTUALS;
              FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'In FND_API.G_EXC_UNEXPECTED_ERROR exception ');
              END IF;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              ROLLBACK TO CREATE_REPAIR_ACTUALS;
              FND_MSG_PUB.Count_And_Get
                    ( p_count  =>  x_msg_count,
                      p_data   =>  x_msg_data );
        WHEN OTHERS THEN
              IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'In OTHERS exception');
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'Sql Err Msg :'||SQLERRM );
              END IF;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              ROLLBACK TO CREATE_REPAIR_ACTUALS;
                  IF  FND_MSG_PUB.Check_Msg_Level
                      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                  THEN
                      FND_MSG_PUB.Add_Exc_Msg
                      (G_PKG_NAME ,
                       l_api_name  );
                  END IF;
                      FND_MSG_PUB.Count_And_Get
                      (p_count  =>  x_msg_count,
                       p_data   =>  x_msg_data );

    End CREATE_REPAIR_ACTUALS;


/*--------------------------------------------------------------------*/
/* procedure name: UPDATE_REPAIR_ACTUALS                              */
/* description : procedure used to Update Repair Actuals              */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Actuals UI                              */
/* Input Parm  :                                                      */
/*   p_api_version       NUMBER    Req Api Version number             */
/*   p_init_msg_list     VARCHAR2  Opt Initialize message stack       */
/*   p_commit            VARCHAR2  Opt Commits in API                 */
/*   p_validation_level  NUMBER    Opt validation steps               */
/*   px_CSD_REPAIR_ACTUALS_REC REC Req Actuals Record                 */
/* Output Parm :                                                      */
/*   x_return_status     VARCHAR2      Return status after the call.  */
/*   x_msg_count         NUMBER        Number of messages in stack    */
/*   x_msg_data          VARCHAR2      Mesg. text if x_msg_count >= 1 */
/* Change Hist :                                                      */
/*   08/11/03  travikan  Initial Creation.                            */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
    PROCEDURE UPDATE_REPAIR_ACTUALS(
        P_Api_Version                IN            NUMBER,
        P_Commit                     IN            VARCHAR2,
        P_Init_Msg_List              IN            VARCHAR2,
        p_validation_level           IN            NUMBER,
        px_CSD_REPAIR_ACTUALS_REC    IN OUT NOCOPY CSD_REPAIR_ACTUALS_REC_TYPE,
        X_Return_Status              OUT    NOCOPY VARCHAR2,
        X_Msg_Count                  OUT    NOCOPY NUMBER,
        X_Msg_Data                   OUT    NOCOPY VARCHAR2
        )

     IS
      -- Variables used in FND Log
      l_stat_level   number   := FND_LOG.LEVEL_STATEMENT;
      l_proc_level   number   := FND_LOG.LEVEL_PROCEDURE;
      l_event_level  number   := FND_LOG.LEVEL_EVENT;
      l_excep_level  number   := FND_LOG.LEVEL_EXCEPTION;
      l_error_level  number   := FND_LOG.LEVEL_ERROR;
      l_unexp_level  number   := FND_LOG.LEVEL_UNEXPECTED;
      l_mod_name     varchar2(2000) := 'csd.plsql.CSD_REPAIR_ACTUALS_PVT.UPDATE_REPAIR_ACTUALS';

      l_api_name               CONSTANT VARCHAR2(30)   := 'UPDATE_REPAIR_ACTUALS';
      l_api_version            CONSTANT NUMBER         := 1.0;
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2(100);
      l_msg_index              NUMBER;
      l_api_return_status      VARCHAR2(3);

      l_actual_id              NUMBER;
      l_obj_ver_num            NUMBER;

      CURSOR repair_actual(p_actual_id IN NUMBER) IS
      SELECT
         a.repair_actual_id,
         a.object_version_number
      FROM csd_repair_actuals a,
           csd_repairs b
      WHERE a.repair_line_id = b.repair_line_id
        and a.repair_actual_id  = p_actual_id;

    BEGIN
          -- Standard Start of API savepoint
          SAVEPOINT UPDATE_REPAIR_ACTUALS;

          -- Standard call to check for call compatibility.
          IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                               p_api_version,
                                               l_api_name,
                                               G_PKG_NAME)
          THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

           -- Initialize message list if p_init_msg_list is set to TRUE.
           IF FND_API.to_Boolean( p_init_msg_list ) THEN
               FND_MSG_PUB.initialize;
           END IF;

           -- Initialize API return status to success
           x_return_status := FND_API.G_RET_STS_SUCCESS;

           -- Api body starts
           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'At the Beginning of update_repair_actual_lines');
           END IF;

           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Begin Check reqd parameter');
           END IF;

           -- Check the required parameter
           CSD_PROCESS_UTIL.Check_Reqd_Param
           ( p_param_value    => px_CSD_REPAIR_ACTUALS_REC.repair_actual_id,
             p_param_name     => 'REPAIR_ACTUAL_ID',
             p_api_name       => l_api_name);

           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'End Check reqd parameter');
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Begin Validate Repair Line id');
           END IF;

           -- Validate the repair line ID
           IF NOT( CSD_PROCESS_UTIL.Validate_rep_line_id
                           ( p_repair_line_id  => px_CSD_REPAIR_ACTUALS_REC.repair_line_id )) THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;

           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'End Validate Repair Line id');
           END IF;

           IF NVL(px_CSD_REPAIR_ACTUALS_REC.repair_actual_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN

            OPEN  repair_actual(px_CSD_REPAIR_ACTUALS_REC.repair_actual_id);
            FETCH repair_actual
             INTO l_actual_id,
                  l_obj_ver_num;

             IF repair_actual%NOTFOUND THEN
              FND_MESSAGE.SET_NAME('CSD','CSD_API_ACTUALS_MISSING');
              FND_MESSAGE.SET_TOKEN('REPAIR_ACTUAL_ID',l_actual_id);
              FND_MSG_PUB.ADD;
              IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level) THEN
                FND_LOG.MESSAGE(Fnd_Log.Level_Error,l_mod_name, FALSE);
              END IF;
              RAISE FND_API.G_EXC_ERROR;
             END IF;

             IF repair_actual%ISOPEN THEN
              CLOSE repair_actual;
             END IF;

           END IF;

           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Validate Object Version Number');
           END IF;

           IF NVL(px_CSD_REPAIR_ACTUALS_REC.object_version_number,FND_API.G_MISS_NUM) <>l_obj_ver_num  THEN

              -- Modified the message name for bugfix 3281321. vkjain.
              -- FND_MESSAGE.SET_NAME('CSD','CSD_OBJ_VER_MISMATCH');
              FND_MESSAGE.SET_NAME('CSD','CSD_ACT_OBJ_VER_MISMATCH');
              -- FND_MESSAGE.SET_TOKEN('REPAIR_ACTUAL_ID',l_actual_id);
              FND_MSG_PUB.ADD;
              IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level) THEN
                FND_LOG.MESSAGE(Fnd_Log.Level_Error,l_mod_name, FALSE);
              END IF;
              RAISE FND_API.G_EXC_ERROR;
           END IF;


          -- Assigning object version number
          px_CSD_REPAIR_ACTUALS_REC.object_version_number := l_obj_ver_num+1;

          --
          -- API body
          --
          IF ( Fnd_Log.Level_Procedure >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Procedure,l_mod_name,'Call to CSD_REPAIR_ACTUALS_PKG.Update_Row');
          END IF;

          BEGIN

          -- Invoke table handler(CSD_REPAIR_ACTUALS_PKG.Update_Row)
          CSD_REPAIR_ACTUALS_PKG.Update_Row(
              p_REPAIR_ACTUAL_ID       => px_CSD_REPAIR_ACTUALS_REC.REPAIR_ACTUAL_ID
             ,p_OBJECT_VERSION_NUMBER  => px_CSD_REPAIR_ACTUALS_REC.OBJECT_VERSION_NUMBER
             ,p_REPAIR_LINE_ID         => px_CSD_REPAIR_ACTUALS_REC.REPAIR_LINE_ID
             ,p_CREATED_BY             => FND_API.G_MISS_NUM
             ,p_CREATION_DATE          => FND_API.G_MISS_DATE
             ,p_LAST_UPDATED_BY        => FND_GLOBAL.USER_ID
             ,p_LAST_UPDATE_DATE       => SYSDATE
             ,p_LAST_UPDATE_LOGIN      => FND_GLOBAL.CONC_LOGIN_ID
             ,p_ATTRIBUTE_CATEGORY     => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE_CATEGORY
             ,p_ATTRIBUTE1             => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE1
             ,p_ATTRIBUTE2             => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE2
             ,p_ATTRIBUTE3             => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE3
             ,p_ATTRIBUTE4             => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE4
             ,p_ATTRIBUTE5             => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE5
             ,p_ATTRIBUTE6             => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE6
             ,p_ATTRIBUTE7             => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE7
             ,p_ATTRIBUTE8             => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE8
             ,p_ATTRIBUTE9             => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE9
             ,p_ATTRIBUTE10            => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE10
             ,p_ATTRIBUTE11            => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE11
             ,p_ATTRIBUTE12            => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE12
             ,p_ATTRIBUTE13            => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE13
             ,p_ATTRIBUTE14            => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE14
             ,p_ATTRIBUTE15            => px_CSD_REPAIR_ACTUALS_REC.ATTRIBUTE15
             ,p_BILL_TO_ACCOUNT_ID     => px_CSD_REPAIR_ACTUALS_REC.BILL_TO_ACCOUNT_ID
             ,p_BILL_TO_PARTY_ID       => px_CSD_REPAIR_ACTUALS_REC.BILL_TO_PARTY_ID
             ,p_BILL_TO_PARTY_SITE_ID  => px_CSD_REPAIR_ACTUALS_REC.BILL_TO_PARTY_SITE_ID
             );
          --
          -- End of API body.
          --

          EXCEPTION
              WHEN OTHERS THEN
                   IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                      FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'Others exception in CSD_REPAIR_ACTUALS_PKG.Update_Row Call :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
                   END IF;
                   x_return_status := FND_API.G_RET_STS_ERROR;
          END;

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
              END IF;

          --
          -- End of API body
          --

          -- Standard check of p_commit.
          IF FND_API.To_Boolean( p_commit ) THEN
               COMMIT WORK;
          END IF;

          -- Standard call to get message count and IF count is  get message info.
          FND_MSG_PUB.Count_And_Get
               (p_count  =>  x_msg_count,
                p_data   =>  x_msg_data );
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'In FND_API.G_EXC_ERROR exception');
              END IF;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              ROLLBACK TO UPDATE_REPAIR_ACTUALS;
              FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'In FND_API.G_EXC_UNEXPECTED_ERROR exception ');
              END IF;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              ROLLBACK TO UPDATE_REPAIR_ACTUALS;
              FND_MSG_PUB.Count_And_Get
                    ( p_count  =>  x_msg_count,
                      p_data   =>  x_msg_data );
        WHEN OTHERS THEN
              IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'In OTHERS exception');
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'Sql Err Msg :'||SQLERRM );
              END IF;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              ROLLBACK TO UPDATE_REPAIR_ACTUALS;
                  IF  FND_MSG_PUB.Check_Msg_Level
                      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                  THEN
                      FND_MSG_PUB.Add_Exc_Msg
                      (G_PKG_NAME ,
                       l_api_name  );
                  END IF;
                      FND_MSG_PUB.Count_And_Get
                      (p_count  =>  x_msg_count,
                       p_data   =>  x_msg_data );
    End UPDATE_REPAIR_ACTUALS;


/*--------------------------------------------------------------------*/
/* procedure name: DELETE_REPAIR_ACTUALS                              */
/* description : procedure used to Delete Repair Actuals              */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Actuals UI                              */
/* Input Parm  :                                                      */
/*   p_api_version       NUMBER    Req Api Version number             */
/*   p_init_msg_list     VARCHAR2  Opt Initialize message stack       */
/*   p_commit            VARCHAR2  Opt Commits in API                 */
/*   p_validation_level  NUMBER    Opt validation steps               */
/*   px_CSD_REPAIR_ACTUALS_REC REC Req Actuals Record                 */
/* Output Parm :                                                      */
/*   x_return_status     VARCHAR2      Return status after the call.  */
/*   x_msg_count         NUMBER        Number of messages in stack    */
/*   x_msg_data          VARCHAR2      Mesg. text if x_msg_count >= 1 */
/* Change Hist :                                                      */
/*   08/11/03  travikan  Initial Creation.                            */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
    PROCEDURE DELETE_REPAIR_ACTUALS(
        P_Api_Version                IN            NUMBER,
        P_Commit                     IN            VARCHAR2,
        P_Init_Msg_List              IN            VARCHAR2,
        p_validation_level           IN            NUMBER,
        px_CSD_REPAIR_ACTUALS_REC    IN OUT NOCOPY CSD_REPAIR_ACTUALS_REC_TYPE,
        X_Return_Status              OUT    NOCOPY VARCHAR2,
        X_Msg_Count                  OUT    NOCOPY NUMBER,
        X_Msg_Data                   OUT    NOCOPY VARCHAR2
        )

     IS
       -- Variables used in FND Log
       l_stat_level   number   := FND_LOG.LEVEL_STATEMENT;
       l_proc_level   number   := FND_LOG.LEVEL_PROCEDURE;
       l_event_level  number   := FND_LOG.LEVEL_EVENT;
       l_excep_level  number   := FND_LOG.LEVEL_EXCEPTION;
       l_error_level  number   := FND_LOG.LEVEL_ERROR;
       l_unexp_level  number   := FND_LOG.LEVEL_UNEXPECTED;
       l_mod_name     varchar2(2000) := 'csd.plsql.CSD_REPAIR_ACTUALS_PVT.DELETE_REPAIR_ACTUALS';

       l_api_name               CONSTANT VARCHAR2(30)   := 'DELETE_REPAIR_ACTUALS';
       l_api_version            CONSTANT NUMBER         := 1.0;
       l_msg_count              NUMBER;
       l_msg_data               VARCHAR2(100);
       l_msg_index              NUMBER;

       l_actual_id              NUMBER;
       l_obj_ver_num            NUMBER;
       l_act_line_count         NUMBER;

      CURSOR repair_actual(p_actual_id IN NUMBER) IS
      SELECT
         a.repair_actual_id,
         a.object_version_number
      FROM csd_repair_actuals a,
           csd_repairs b
      WHERE a.repair_line_id = b.repair_line_id
        and a.repair_actual_id  = p_actual_id;

    BEGIN
          -- Standard Start of API savepoint
          SAVEPOINT DELETE_REPAIR_ACTUALS;

          -- Standard call to check for call compatibility.
          IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                               p_api_version,
                                               l_api_name,
                                               G_PKG_NAME)
          THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

           -- Initialize message list if p_init_msg_list is set to TRUE.
           IF FND_API.to_Boolean( p_init_msg_list ) THEN
               FND_MSG_PUB.initialize;
           END IF;

           -- Initialize API return status to success
           x_return_status := FND_API.G_RET_STS_SUCCESS;

           -- Api body starts
           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'At the Beginning of delete_repair_actual_lines');
           END IF;

           -- Dump the in parameters in the log file
           -- if the debug level > 5
           -- If fnd_profile.value('CSD_DEBUG_LEVEL') > 5 then
           /* TBD
    	   if (g_debug > 5) then
              csd_gen_utility_pvt.dump_actuals_rec
                       ( p_CSD_REPAIR_ACTUALS_REC => px_CSD_REPAIR_ACTUALS_REC);
           end if;
           */
           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Begin Check reqd paramete');
           END IF;

           -- Check the required parameter
           CSD_PROCESS_UTIL.Check_Reqd_Param
           ( p_param_value    => px_CSD_REPAIR_ACTUALS_REC.repair_actual_id,
             p_param_name     => 'REPAIR_ACTUAL_ID',
             p_api_name       => l_api_name);

           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'End Check reqd parameter');
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Begin Validate Repair Line id');
           END IF;

           -- Validate the repair line ID
           IF NOT( CSD_PROCESS_UTIL.Validate_rep_line_id
                           ( p_repair_line_id  => px_CSD_REPAIR_ACTUALS_REC.repair_line_id )) THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;

           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'End Validate Repair Line id');
           END IF;

           IF NVL(px_CSD_REPAIR_ACTUALS_REC.repair_actual_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN

            OPEN  repair_actual(px_CSD_REPAIR_ACTUALS_REC.repair_actual_id);
            FETCH repair_actual
             INTO l_actual_id,
                  l_obj_ver_num;

             IF repair_actual%NOTFOUND THEN
              FND_MESSAGE.SET_NAME('CSD','CSD_API_ACTUALS_MISSING');
              FND_MESSAGE.SET_TOKEN('REPAIR_ACTUAL_ID',l_actual_id);
              FND_MSG_PUB.ADD;
              IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level) THEN
                FND_LOG.MESSAGE(Fnd_Log.Level_Error,l_mod_name, FALSE);
              END IF;
              RAISE FND_API.G_EXC_ERROR;
             END IF;

             IF repair_actual%ISOPEN THEN
              CLOSE repair_actual;
             END IF;

           END IF;

           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Validate Object Version Number');
           END IF;

           IF NVL(px_CSD_REPAIR_ACTUALS_REC.object_version_number,FND_API.G_MISS_NUM) <>l_obj_ver_num  THEN
             IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Object Version Number does not match'
			   || ' for the Repair Actual ID = ' || l_actual_id);
             END IF;

              -- Modified the message name for bugfix 3281321. vkjain.
              -- FND_MESSAGE.SET_NAME('CSD','CSD_OBJ_VER_MISMATCH');
              FND_MESSAGE.SET_NAME('CSD','CSD_ACT_OBJ_VER_MISMATCH');
              -- FND_MESSAGE.SET_TOKEN('REPAIR_ACTUAL_ID',l_actual_id);
              FND_MSG_PUB.ADD;
              IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level) THEN
                FND_LOG.MESSAGE(Fnd_Log.Level_Error,l_mod_name, FALSE);
              END IF;
              RAISE FND_API.G_EXC_ERROR;
           END IF;


           BEGIN
             SELECT count(*)
               INTO l_act_line_count
               FROM csd_repair_actual_lines
              WHERE repair_actual_id = l_actual_id;
           EXCEPTION
             WHEN OTHERS THEN
                  IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                      FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'Others exception error :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
                  END IF;
          END;

          IF l_act_line_count > 0 THEN
             IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Actual Lines exists for the Repair Order');
             END IF;

            FND_MESSAGE.SET_NAME('CSD','CSD_ACTUAL_LINE_EXISTS');
              FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID', px_CSD_REPAIR_ACTUALS_REC.REPAIR_LINE_ID);
              FND_MSG_PUB.ADD;
              IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level) THEN
                FND_LOG.MESSAGE(Fnd_Log.Level_Error,l_mod_name, FALSE);
              END IF;
              RAISE FND_API.G_EXC_ERROR;
           END IF;


          --
          -- API body
          --
          IF ( Fnd_Log.Level_Procedure >= G_debug_level) THEN
               FND_LOG.STRING(Fnd_Log.Level_Procedure,l_mod_name,'Call to  CSD_REPAIR_ACTUALS_PKG.Delete_Row');
          END IF;

          BEGIN

          -- Invoke table handler(CSD_REPAIR_ACTUALS_PKG.Delete_Row)
          CSD_REPAIR_ACTUALS_PKG.Delete_Row(
              p_REPAIR_ACTUAL_ID       => px_CSD_REPAIR_ACTUALS_REC.REPAIR_ACTUAL_ID
             ,p_OBJECT_VERSION_NUMBER  => px_CSD_REPAIR_ACTUALS_REC.OBJECT_VERSION_NUMBER);

          EXCEPTION
              WHEN OTHERS THEN
                   IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                      FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'Others exception error :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
                   END IF;
                   x_return_status := FND_API.G_RET_STS_ERROR;
          END;

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
              END IF;

          --
          -- End of API body
          --

          -- Standard check of p_commit.
          IF FND_API.To_Boolean( p_commit ) THEN
               COMMIT WORK;
          END IF;

          -- Standard call to get message count and IF count is  get message info.
          FND_MSG_PUB.Count_And_Get
               (p_count  =>  x_msg_count,
                p_data   =>  x_msg_data );
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'In FND_API.G_EXC_ERROR exception');
              END IF;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              ROLLBACK TO DELETE_REPAIR_ACTUALS;
              FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'In FND_API.G_EXC_UNEXPECTED_ERROR exception ');
              END IF;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              ROLLBACK TO DELETE_REPAIR_ACTUALS;
              FND_MSG_PUB.Count_And_Get
                    ( p_count  =>  x_msg_count,
                      p_data   =>  x_msg_data );
        WHEN OTHERS THEN
              IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'In OTHERS exception');
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'Sql Err Msg :'||SQLERRM );
              END IF;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              ROLLBACK TO DELETE_REPAIR_ACTUALS;
                  IF  FND_MSG_PUB.Check_Msg_Level
                      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                  THEN
                      FND_MSG_PUB.Add_Exc_Msg
                      (G_PKG_NAME ,
                       l_api_name  );
                  END IF;
                      FND_MSG_PUB.Count_And_Get
                      (p_count  =>  x_msg_count,
                       p_data   =>  x_msg_data );
    End DELETE_REPAIR_ACTUALS;

/*--------------------------------------------------------------------*/
/* procedure name: LOCK_REPAIR_ACTUALS                                */
/* description : procedure used to Lock Repair Actuals              */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Actuals UI                              */
/* Input Parm  :                                                      */
/*   p_api_version       NUMBER    Req Api Version number             */
/*   p_init_msg_list     VARCHAR2  Opt Initialize message stack       */
/*   p_commit            VARCHAR2  Opt Commits in API                 */
/*   p_validation_level  NUMBER    Opt validation steps               */
/*   px_CSD_REPAIR_ACTUALS_REC REC Req Actuals Record                 */
/* Output Parm :                                                      */
/*   x_return_status     VARCHAR2      Return status after the call.  */
/*   x_msg_count         NUMBER        Number of messages in stack    */
/*   x_msg_data          VARCHAR2      Mesg. text if x_msg_count >= 1 */
/* Change Hist :                                                      */
/*   08/11/03  travikan  Initial Creation.                            */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
    PROCEDURE LOCK_REPAIR_ACTUALS(
        P_Api_Version                IN            NUMBER,
        P_Commit                     IN            VARCHAR2,
        P_Init_Msg_List              IN            VARCHAR2,
        p_validation_level           IN            NUMBER,
        px_CSD_REPAIR_ACTUALS_REC    IN OUT NOCOPY CSD_REPAIR_ACTUALS_REC_TYPE,
        X_Return_Status              OUT    NOCOPY VARCHAR2,
        X_Msg_Count                  OUT    NOCOPY NUMBER,
        X_Msg_Data                   OUT    NOCOPY VARCHAR2
        )
    IS
     -- Variables used in FND Log
     l_stat_level   number   := FND_LOG.LEVEL_STATEMENT;
     l_proc_level   number   := FND_LOG.LEVEL_PROCEDURE;
     l_event_level  number   := FND_LOG.LEVEL_EVENT;
     l_excep_level  number   := FND_LOG.LEVEL_EXCEPTION;
     l_error_level  number   := FND_LOG.LEVEL_ERROR;
     l_unexp_level  number   := FND_LOG.LEVEL_UNEXPECTED;
     l_mod_name     varchar2(2000) := 'csd.plsql.CSD_REPAIR_ACTUALS_PVT.LOCK_REPAIR_ACTUALS';

     l_api_name               CONSTANT VARCHAR2(30)   := 'LOCK_REPAIR_ACTUALS';
     l_api_version            CONSTANT NUMBER         := 1.0;
     l_msg_count              NUMBER;
     l_msg_data               VARCHAR2(100);
     l_msg_index              NUMBER;

    BEGIN
          -- Standard Start of API savepoint
          SAVEPOINT LOCK_REPAIR_ACTUALS;

          -- Standard call to check for call compatibility.
          IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                               p_api_version,
                                               l_api_name,
                                               G_PKG_NAME)
          THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

           -- Initialize message list if p_init_msg_list is set to TRUE.
           IF FND_API.to_Boolean( p_init_msg_list ) THEN
               FND_MSG_PUB.initialize;
           END IF;

           -- Initialize API return status to success
           x_return_status := FND_API.G_RET_STS_SUCCESS;

           -- Api body starts
           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'At the Beginning of lock_repair_actual_lines');
           END IF;
           -- Dump the in parameters in the log file
           -- if the debug level > 5
           -- If fnd_profile.value('CSD_DEBUG_LEVEL') > 5 then
--            if (g_debug > 5) then
--               csd_gen_utility_pvt.dump_actuals_rec
--                        ( p_CSD_REPAIR_ACTUALS_REC => px_CSD_REPAIR_ACTUALS_REC);
--            end if;

           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Begin Check reqd parameter');
           END IF;

           -- Check the required parameter
           CSD_PROCESS_UTIL.Check_Reqd_Param
           ( p_param_value    => px_CSD_REPAIR_ACTUALS_REC.repair_actual_id,
             p_param_name     => 'REPAIR_ACTUAL_ID',
             p_api_name       => l_api_name);

           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'End Check reqd parameter');
           END IF;

          --
          -- API body
          --
          IF ( Fnd_Log.Level_Procedure >= G_debug_level) THEN
               FND_LOG.STRING(Fnd_Log.Level_Procedure,l_mod_name,'Call to CSD_REPAIR_ACTUALS_PKG.Lock_Row');
          END IF;

          BEGIN

          -- Invoke table handler(CSD_REPAIR_ACTUALS_PKG.Lock_Row)
          CSD_REPAIR_ACTUALS_PKG.Lock_Row(
              p_REPAIR_ACTUAL_ID       => px_CSD_REPAIR_ACTUALS_REC.REPAIR_ACTUAL_ID
             ,p_OBJECT_VERSION_NUMBER  => px_CSD_REPAIR_ACTUALS_REC.OBJECT_VERSION_NUMBER);

          EXCEPTION
              WHEN OTHERS THEN
                   IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                      FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'Others exception in CSD_REPAIR_ACTUALS_PKG.Lock_Row Call :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
                   END IF;
                   x_return_status := FND_API.G_RET_STS_ERROR;
          END;

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
              END IF;

          --
          -- End of API body
          --

          -- Standard check of p_commit.
          IF FND_API.To_Boolean( p_commit ) THEN
               COMMIT WORK;
          END IF;

          -- Standard call to get message count and IF count is  get message info.
          FND_MSG_PUB.Count_And_Get
               (p_count  =>  x_msg_count,
                p_data   =>  x_msg_data );
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'In FND_API.G_EXC_ERROR exception');
              END IF;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              ROLLBACK TO LOCK_REPAIR_ACTUALS;
              FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'In FND_API.G_EXC_UNEXPECTED_ERROR exception ');
              END IF;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              ROLLBACK TO LOCK_REPAIR_ACTUALS;
              FND_MSG_PUB.Count_And_Get
                    ( p_count  =>  x_msg_count,
                      p_data   =>  x_msg_data );
        WHEN OTHERS THEN
              IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'In OTHERS exception');
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'Sql Err Msg :'||SQLERRM );
              END IF;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              ROLLBACK TO LOCK_REPAIR_ACTUALS;
                  IF  FND_MSG_PUB.Check_Msg_Level
                      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                  THEN
                      FND_MSG_PUB.Add_Exc_Msg
                      (G_PKG_NAME ,
                       l_api_name  );
                  END IF;
                      FND_MSG_PUB.Count_And_Get
                      (p_count  =>  x_msg_count,
                       p_data   =>  x_msg_data );

    END LOCK_REPAIR_ACTUALS;

End CSD_REPAIR_ACTUALS_PVT;

/
