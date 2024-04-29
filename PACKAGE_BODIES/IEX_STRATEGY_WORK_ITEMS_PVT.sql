--------------------------------------------------------
--  DDL for Package Body IEX_STRATEGY_WORK_ITEMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_STRATEGY_WORK_ITEMS_PVT" as
/* $Header: iexvswib.pls 120.2.12010000.3 2008/10/20 09:38:32 pnaveenk ship $ */

G_PKG_NAME CONSTANT VARCHAR2(300):= 'IEX_strategy_work_items_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexvswib.pls';


-- Hint: Primary key needs to be returned.
--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE Create_strategy_work_items(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_TRUE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_strategy_work_item_Rec     IN    strategy_work_item_Rec_Type  := G_MISS_strategy_work_item_REC,
    X_WORK_ITEM_ID               OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(200) := 'Create_strategy_work_items';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_return_status_full      VARCHAR2(1);
v_WORK_ITEM_ID             iex_strategy_work_items.strategy_id%TYPE;
v_object_version_number    iex_strategy_work_items.object_version_number%TYPE;
v_rowid                    VARCHAR2(24);
--added by vimpi
l_msg_Count               number ;
l_msg_data                varchar2(200) ;
l_return_status           varchar2(200) ;


 Cursor c2 is SELECT iex_strategy_work_items_S.nextval from dual;

BEGIN
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_strategy_work_items_PVT.Create_strategy_work_items ******** ');
    END IF;
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_strategy_work_items_PVT;

          -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                           	               p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('Create_strategy_work_items: ' || 'After Compatibility Check');
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('IEX', 'IEX_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('Create_strategy_work_items: ' || 'After Global user Check');
      END IF;

      --object version Number
      v_object_version_number :=1;
       -- get work_item_id
       OPEN C2;
       FETCH C2 INTO v_work_item_id;
       CLOSE C2;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('Create_strategy_work_items: ' || 'After work_item_id Check and work_item_id is => '||v_work_item_id);
      END IF;

	--strategy Id check
       IF (P_strategy_work_item_rec.strategy_id IS NULL) OR
               (P_strategy_work_item_rec.strategy_id =FND_API.G_MISS_NUM) THEN
  	        fnd_message.set_name('IEX', 'IEX_API_ALL_MISSING_PARAM');
		    fnd_message.set_token('API_NAME', l_api_name);
		    fnd_message.set_token('MISSING_PARAM', 'strategy_id');
		    fnd_msg_pub.add;
              RAISE FND_API.G_EXC_ERROR;
		END IF;
--		IF PG_DEBUG < 10  THEN
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		   IEX_DEBUG_PUB.LogMessage ('Create_strategy_work_items: ' || 'After strategy id check');
		END IF;

	--resource Id check
       IF (P_strategy_work_item_rec.resource_id IS NULL) OR
               (P_strategy_work_item_rec.resource_id =FND_API.G_MISS_NUM) THEN
  	        fnd_message.set_name('IEX', 'IEX_API_ALL_MISSING_PARAM');
		    fnd_message.set_token('API_NAME', l_api_name);
		    fnd_message.set_token('MISSING_PARAM', 'resource_id');
		    fnd_msg_pub.add;
              RAISE FND_API.G_EXC_ERROR;
		END IF;
--		IF PG_DEBUG < 10  THEN
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		   IEX_DEBUG_PUB.LogMessage ('Create_strategy_work_items: ' || 'After resource id check');
		END IF;


--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          IEX_DEBUG_PUB.LogMessage('Create_strategy_work_items: ' || 'Before Calling iex_strategies_pkg.insert_row');
       END IF;

      -- Invoke table handler(IEX_STRATEGY_WORK_ITEMS_PKG.Insert_Row)
      IEX_STRATEGY_WORK_ITEMS_PKG.Insert_Row(
          x_rowid   =>v_rowid
         ,x_WORK_ITEM_ID  => v_WORK_ITEM_ID
         ,x_STRATEGY_ID  => p_strategy_work_item_rec.STRATEGY_ID
         ,x_RESOURCE_ID  => p_strategy_work_item_rec.RESOURCE_ID
         ,x_STATUS_CODE  => p_strategy_work_item_rec.STATUS_CODE
         ,x_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID
         ,x_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID
         ,x_CREATION_DATE  => SYSDATE
         ,x_CREATED_BY  => FND_GLOBAL.USER_ID
         ,x_PROGRAM_ID  => p_strategy_work_item_rec.PROGRAM_ID
         ,x_OBJECT_VERSION_NUMBER  => v_OBJECT_VERSION_NUMBER
         ,x_REQUEST_ID  => p_strategy_work_item_rec.REQUEST_ID
         ,x_LAST_UPDATE_DATE  => SYSDATE
         ,x_WORK_ITEM_TEMPLATE_ID  => p_strategy_work_item_rec.WORK_ITEM_TEMPLATE_ID
         ,x_PROGRAM_APPLICATION_ID => p_strategy_work_item_rec.PROGRAM_APPLICATION_ID
         ,x_PROGRAM_UPDATE_DATE => p_strategy_work_item_rec.PROGRAM_UPDATE_DATE
         ,x_EXECUTE_START => p_strategy_work_item_rec.EXECUTE_START
         ,x_EXECUTE_END => p_strategy_work_item_rec.EXECUTE_END
         ,x_SCHEDULE_START => p_strategy_work_item_rec.SCHEDULE_START
         ,x_SCHEDULE_END => p_strategy_work_item_rec.SCHEDULE_END
         ,x_STRATEGY_TEMP_ID  => p_strategy_work_item_rec.STRATEGY_TEMP_ID
         ,x_WORK_ITEM_ORDER  => p_strategy_work_item_rec.WORK_ITEM_ORDER
	 ,x_ESCALATED_YN  => p_strategy_work_item_rec.ESCALATED_YN
         );

         x_WORK_ITEM_ID := v_WORK_ITEM_ID;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

      --
      -- End of API body
      --
      -- added by vimpi for metaphor integration

     /* begin remove the check of profile, the procedure is doing nothing, ctlee 02/28/2005 */
     /*
	 IF( x_return_status = FND_API.G_RET_STS_SUCCESS) then
           IF (NVL(FND_PROFILE.VALUE('IEX_STRY_METAPHOR_CREATION'),'N') = 'Y') then
	   BEGIN
             --dbms_output.put_line('calinggggg create_uwq_itemmmmm');
            IEX_STRY_UWQ_PVT.Create_uwq_item(
             p_api_version             => 1.0,
             p_init_msg_list           => FND_API.G_TRUE,
             p_commit                  => p_commit,
             p_work_item_id            => v_work_item_id,
             P_strategy_work_item_Rec  => p_strategy_work_item_rec,
             x_return_status           => l_return_status,
             x_msg_count               => l_msg_count,
             x_msg_data                => l_msg_data) ;

	    --dbms_output.put_line('ERRRRRRRROS is '||l_msg_data) ;
	    if ( l_return_status = 'E') then
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.LogMessage('Create_strategy_work_items: ' ||  'No Data Found');
                END IF;
                 RAISE FND_API.G_EXC_ERROR;
            elsif ( l_return_status ='U') then
			 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			    IEX_DEBUG_PUB.LogMessage('Create_strategy_work_items: ' || 'Create UwqmProcedure failed');
			 END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    end if ;
          END;
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             IEX_DEBUG_PUB.LogMessage('Create_strategy_work_items: ' || 'In if metaphor');
          END IF;
        end if ;
 --end of profile enabled checking
       end if ;
     */
     /* end remove the check of profile, the procedure is doing nothing, ctlee 02/28/2005 */


      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage ('********* end of Procedure =>IEX_strategy_work_items_PVT.Create_strategy_work_items ******** ');
    END IF;
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_strategy_work_items;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_strategy_work_items(
  P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_TRUE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_strategy_work_item_Rec     IN    strategy_work_item_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    XO_OBJECT_VERSION_NUMBER     OUT NOCOPY  NUMBER
      )

 IS
/*
Cursor C_Get_strategy_work_items(WORK_ITEM_ID Number) IS
    Select rowid,
           WORK_ITEM_ID,
           STRATEGY_ID,
           COMPETENCE_ID,
           CATEGORY_TYPE,
           RESOURCE_ID,
           REQUIRED_YN,
           STATUS_CODE,
           PRIORITY_ID,
           PRE_EXECUTION_WAIT,
           POST_EXECUTION_WAIT,
           CLOSURE_DATE_LIMIT,
           EXECUTE_DATE_LIMIT,
           SEEDED_WORKFLOW_YN,
           WORKFLOW_ITEM_TYPE,
           WORKFLOW_PROCESS_NAME,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN,
           CREATION_DATE,
           CREATED_BY,
           PROGRAM_ID,
           OBJECT_VERSION_NUMBER,
           REQUEST_ID,
           WORK_TYPE,
           LAST_UPDATE_DATE,
           WORK_ITEM_TEMPLATE_ID
    From  IEX_STRATEGY_WORK_ITEMS
    -- Hint: Developer need to provide Where clause
    For Update NOWAIT;
*/
l_api_name                CONSTANT VARCHAR2(200) := 'Update_strategy_work_items';
l_api_version_number      CONSTANT NUMBER   := 2.0;

-- Local Variables
l_identity_sales_member_rec   AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_ref_strategy_work_item_rec  IEX_strategy_work_items_PVT.strategy_work_item_Rec_Type;
l_tar_strategy_work_item_rec  IEX_strategy_work_items_PVT.strategy_work_item_Rec_Type := P_strategy_work_item_Rec;

l_object_version_number IEX_strategy_work_items.object_version_number%TYPE:=P_strategy_work_item_Rec.object_version_number;
l_rowid  ROWID;
--added by vimpi
l_msg_Count               number ;
l_msg_data                varchar2(200) ;
l_return_status           varchar2(200) ;
  l_work_item_temp_id        number ;
  l_work_item_id        number ;
  l_strategy_id             number ;

BEGIN

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_strategy_work_items_PVT.update_strategy_work_items ******** ');
    END IF;
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_strategy_work_items_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;




      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      -- call locking table handler
      IEX_STRATEGY_WORK_ITEMS_PKG.lock_row (
         p_strategy_work_item_rec.WORK_ITEM_ID,
         l_object_version_number
      );

      -- Invoke table handler(IEX_STRATEGY_WORK_ITEMS_PKG.Update_Row)
      IEX_STRATEGY_WORK_ITEMS_PKG.Update_Row(
          x_WORK_ITEM_ID  => p_strategy_work_item_rec.WORK_ITEM_ID
         ,x_STRATEGY_ID  => p_strategy_work_item_rec.STRATEGY_ID
         ,x_RESOURCE_ID  => p_strategy_work_item_rec.RESOURCE_ID
         ,x_STATUS_CODE  => p_strategy_work_item_rec.STATUS_CODE
         ,x_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID
         ,x_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID
         ,x_PROGRAM_ID  => p_strategy_work_item_rec.PROGRAM_ID
         ,x_OBJECT_VERSION_NUMBER  => l_OBJECT_VERSION_NUMBER +1
         ,x_REQUEST_ID  => p_strategy_work_item_rec.REQUEST_ID
         ,x_LAST_UPDATE_DATE  => SYSDATE
         ,x_WORK_ITEM_TEMPLATE_ID  => p_strategy_work_item_rec.WORK_ITEM_TEMPLATE_ID
         ,x_PROGRAM_APPLICATION_ID => p_strategy_work_item_rec.PROGRAM_APPLICATION_ID
         ,x_PROGRAM_UPDATE_DATE => p_strategy_work_item_rec.PROGRAM_UPDATE_DATE
         ,x_EXECUTE_START => p_strategy_work_item_rec.EXECUTE_START
         ,x_EXECUTE_END => p_strategy_work_item_rec.EXECUTE_END
         ,x_SCHEDULE_START => p_strategy_work_item_rec.SCHEDULE_START
         ,x_SCHEDULE_END => p_strategy_work_item_rec.SCHEDULE_END
         ,x_STRATEGY_TEMP_ID  => p_strategy_work_item_rec.STRATEGY_TEMP_ID
         ,x_WORK_ITEM_ORDER  => p_strategy_work_item_rec.WORK_ITEM_ORDER
         ,x_ESCALATED_YN  => p_strategy_work_item_rec.ESCALATED_YN
         );
      --
      -- End of API body.
      --
       --Return Version number
      xo_object_version_number := l_object_version_number + 1;

      -- added by vimpi for metaphor integration

     /* begin remove the check of profile, the procedure is doing nothing, ctlee 02/28/2005 */
     /*
     IF( x_return_status = FND_API.G_RET_STS_SUCCESS) then
       IF (NVL(FND_PROFILE.VALUE('IEX_STRY_METAPHOR_CREATION'),'N') = 'Y') then
       BEGIN
       l_work_item_temp_id  := p_strategy_work_item_rec.WORK_ITEM_TEMPLATE_ID ;
       l_work_item_id  := p_strategy_work_item_rec.WORK_ITEM_ID ;
       l_strategy_id  := p_strategy_work_item_rec.STRATEGY_ID ;
	   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	      IEX_DEBUG_PUB.LogMessage('Update_strategy_work_items: ' || 'In VIMPIIIIIIII '||l_work_item_id);
	   END IF;
        IEX_STRY_UWQ_PVT.Update_uwq_item(
             p_api_version             => 1.0,
             p_init_msg_list           => FND_API.G_TRUE,
             p_commit                  => p_commit,
             p_work_item_id            => p_strategy_work_item_rec.WORK_ITEM_ID,
             P_strategy_work_item_Rec  =>  p_strategy_work_item_rec,
             x_return_status           => l_return_status,
             x_msg_count               => l_msg_count,
             x_msg_data                => l_msg_data) ;
            if ( l_return_status = 'E') then
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.LogMessage('Update_strategy_work_items: ' ||  'No Data Found');
                END IF;
                 RAISE FND_API.G_EXC_ERROR;
            elsif ( l_return_status ='U') then
			 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			    IEX_DEBUG_PUB.LogMessage('Update_strategy_work_items: ' || 'Create UwqmProcedure failed');
			 END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    end if ;
        END;
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('Update_strategy_work_items: ' || 'In if metaphor');
        END IF;
      end if ;
     --end of profile enabled checking
    end if ;
    */
     /* end remove the check of profile, the procedure is doing nothing, ctlee 02/28/2005 */

      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- added by vimpi for metaphor integration

/*	 IF( x_return_status = FND_API.G_RET_STS_SUCCESS) then
    IF (NVL(FND_PROFILE.VALUE('IEX_STRY_METAPHOR_CREATION'),'N') = 'Y') then
	BEGIN
        IEX_STRY_UWQ_PVT.Update_uwq_item(
             p_api_version             => 1.0,
             p_init_msg_list           => FND_API.G_TRUE,
             p_commit                  => FND_API.G_TRUE,
             p_work_item_id            => p_strategy_work_item_rec.WORK_ITEM_ID,
             P_strategy_work_item_Rec  =>  p_strategy_work_item_rec,
             x_return_status           => l_return_status,
             x_msg_count               => l_msg_count,
             x_msg_data                => l_msg_data) ;

	    EXCEPTION
            WHEN OTHERS THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                IEX_DEBUG_PUB.LogMessage( debug_msg => 'IEU_UWQM_ITEMS' || to_char(p_strategy_work_item_rec.work_item_id),   print_date => 'Y');
                END IF;
                AS_UTILITY_PVT.Set_Message(
                      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name      => 'IEX_METAPHOR_CREATION_FAILED',
                      p_token1        => 'WORK_ITEM ',
                      p_token1_value  =>  to_char(p_strategy_work_item_rec.work_item_id));
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END;
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     IEX_DEBUG_PUB.LogMessage('Update_strategy_work_items: ' || 'In if metaphor');
  END IF;
end if ;
 --end of profile enabled checking
end if ;
*/





      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage ('********* end of Procedure =>IEX_strategy_work_items_PVT.update_strategy_work_items ******** ');
    END IF;
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_strategy_work_items;


PROCEDURE Delete_strategy_work_items(
  P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    p_WORK_ITEM_ID               IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_strategy_work_items';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_strategy_work_items_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      -- Invoke table handler(IEX_STRATEGY_WORK_ITEMS_PKG.Delete_Row)
      IEX_STRATEGY_WORK_ITEMS_PKG.Delete_Row(p_WORK_ITEM_ID);

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_strategy_work_items;


End IEX_strategy_work_items_PVT;

/
