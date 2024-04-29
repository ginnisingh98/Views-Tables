--------------------------------------------------------
--  DDL for Package Body CSD_REPAIR_TYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_REPAIR_TYPES_PVT" as
/* $Header: csdvrtdb.pls 120.0 2005/06/30 21:09:42 vkjain noship $ */

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'CSD_REPAIR_TYPES_PVT';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'csdvrtdb.pls';

/*--------------------------------------------------*/
/* procedure name: Get_Start_Flow_Status            */
/* description   : The procedure returns the start  */
/*                 flow status and status or        */
/*                 a given repair type.             */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Get_Start_Flow_Status
(
   x_return_status             OUT  NOCOPY    VARCHAR2,
   x_msg_count                 OUT  NOCOPY    NUMBER,
   x_msg_data                  OUT  NOCOPY    VARCHAR2,
   p_repair_type_id 		 IN             NUMBER,
   x_start_flow_status_id 	 OUT  NOCOPY    NUMBER,
   x_start_flow_status_code    OUT  NOCOPY    VARCHAR2,
   x_start_flow_status_meaning OUT  NOCOPY    VARCHAR2,
   x_status_code 		       OUT  NOCOPY    VARCHAR2
) IS

-- CONSTANTS --
 lc_mod_name              CONSTANT VARCHAR2(100)  := 'csd.plsql.CSD_REPAIR_TYPES_PVT.get_start_flow_status';
 lc_api_name              CONSTANT VARCHAR2(30)   := 'Get_Start_Flow_Status';
 lc_api_version           CONSTANT NUMBER         := 1.0;
 lc_FLOW_STATUS_LOOKUP_TYPE CONSTANT VARCHAR2(30)   := 'CSD_REPAIR_FLOW_STATUS';

-- VARIABLES --
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(100);
 l_msg_index              NUMBER;
 l_dummy	              VARCHAR2(1) := null;
 l_obj_ver_num		  NUMBER := 1;
 l_rowid		        ROWID;

-- CURSORS --
CURSOR cursor_get_start_status IS
 SELECT  RT_B.START_FLOW_STATUS_ID,
     	   FS_B.FLOW_STATUS_CODE START_FLOW_STATUS_CODE,
	   FS_LKUP.MEANING START_FLOW_STATUS_MEANING,
	   FS_B.STATUS_CODE STATUS_CODE
 FROM    CSD_REPAIR_TYPES_B RT_B,
         CSD_FLOW_STATUSES_B FS_B,
         FND_LOOKUPS FS_LKUP
 WHERE   RT_B.REPAIR_TYPE_ID = p_repair_type_id AND
         FS_B.FLOW_STATUS_ID = RT_B.START_FLOW_STATUS_ID AND
         FS_LKUP.lookup_type = lc_FLOW_STATUS_LOOKUP_TYPE   AND
         FS_LKUP.enabled_flag = 'Y' AND
         TRUNC(SYSDATE) BETWEEN
         TRUNC(NVL(FS_LKUP.start_date_active, SYSDATE)) AND
         TRUNC(NVL(FS_LKUP.end_date_active, SYSDATE)) AND
         FS_LKUP.lookup_code = FS_B.FLOW_STATUS_CODE;

BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT  Get_Start_Flow_Status;

       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name || '.BEGIN',
              'Entered Get_Start_Flow_Status');
       END IF;

       -- Initialize API return status to success
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       -- Api body starts

       -- Check the required parameters
       if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name,
                       'Checking required parameters');
       end if;

       -- Check the required parameters
       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value	  => p_repair_type_id,
         p_param_name	  => 'P_REPAIR_TYPE_ID',
         p_api_name	  => lc_api_name);

       -- Initialize the out parameter.
       x_start_flow_status_id := NULL;

       -- This will never return more than one rows,
       -- as repair_type_id is unique.
       FOR irow IN cursor_get_start_status LOOP
          x_start_flow_status_id := irow.start_flow_status_id;
          x_start_flow_status_code := irow.start_flow_status_code;
          x_start_flow_status_meaning := irow.start_flow_status_meaning;
          x_status_code := irow.status_code;
       END LOOP;

       IF x_start_flow_status_id IS NULL THEN
          -- Unable to get the start status of the repair type.
          -- For the repair type, either the start status has
          -- not been defined or is not active.
          FND_MESSAGE.Set_Name('CSD', 'CSD_RT_START_STATUS_NOT_FOUND');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

      -- Api body ends here

      -- Standard call to get message count and IF count is  get message info.
      FND_MSG_PUB.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data   =>  x_msg_data );

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, lc_mod_name || '.END',
                       'Leaving Get_Start_Flow_Status');
      END IF;

  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Get_Start_Flow_Status;
          x_return_status := FND_API.G_RET_STS_ERROR;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, lc_mod_name,
                             'EXC_ERROR['||x_msg_data||']');
          END IF;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Get_Start_Flow_Status;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          -- save message in fnd stack
          IF  FND_MSG_PUB.Check_Msg_Level
              (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, lc_mod_name,
                                 'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
              end if;
              FND_MSG_PUB.Add_Exc_Msg
              (G_PKG_NAME ,
               lc_api_name  );
          END IF;

          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );

          -- save message in debug log
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, lc_mod_name,
                             'EXC_UNEXPECTED_ERROR['||x_msg_data||']');
          END IF;

    WHEN OTHERS THEN
          ROLLBACK TO Get_Start_Flow_Status;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          -- save message in fnd stack
          IF  FND_MSG_PUB.Check_Msg_Level
              (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, lc_mod_name,
                                 'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
              end if;
              FND_MSG_PUB.Add_Exc_Msg
              (G_PKG_NAME ,
               lc_api_name  );
          END IF;

          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data );

          -- save message in debug log
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              -- create a seeded message
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, lc_mod_name,
                             'SQL Message['||sqlerrm||']' );
          END IF;

  END Get_Start_Flow_Status;

End CSD_REPAIR_TYPES_PVT;

/
