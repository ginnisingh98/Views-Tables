--------------------------------------------------------
--  DDL for Package Body IEX_DEL_SUB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_DEL_SUB_PVT" AS
/* $Header: iexpdlsb.pls 120.1 2006/05/30 17:27:03 scherkas noship $ */

    l_api_version_number 	CONSTANT NUMBER   := 1.0;

   /* ------------------------------------------------------------------------------
					PROCEDURE ADD_REC
   ------------------------------------------------------------------------------ */
--   PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE Add_rec  (p_api_version         IN  NUMBER	,
                       p_init_msg_list       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                       p_commit		   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                       p_validation_level    IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
                       x_return_status       OUT NOCOPY VARCHAR2	,
                       x_msg_count           OUT NOCOPY NUMBER	,
                       x_msg_data            OUT NOCOPY VARCHAR2	,
			     p_source_module	   IN	 VARCHAR2	,
			     p_id_tbl		   IN  IEX_UTILITIES.t_numbers,
                       p_del_id		   IN  Number	,
                       p_object_code	   IN  Varchar2	,
                       p_object_id	     	   IN  IEX_DEL_ASSETS.object_id%TYPE      )
   IS

   	l_api_name varchar2(50) := 'Add_Rec';
   	nCount     NUMBER;

   BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT Add_Rec;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call(l_api_version_number,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean(p_init_msg_list)
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Beginning of API body
      --

      nCount := p_id_tbl.Count;

	-- Delinquency Assets Form
      if p_source_module = 'IEXDLAST' then
            FOR i IN 1..nCount
            LOOP
                BEGIN
                    Update IEX_DEL_ASSETS
                        SET ACTIVE_YN      = 'Y'
                        where asset_id     = p_id_tbl(i)
                        AND delinquency_id = p_del_id
                        AND object_id      = p_object_id
                        AND object_code    = p_object_code;

                    IF sql%NOTFOUND THEN
                        BEGIN
                          INSERT INTO IEX_DEL_ASSETS
                           (DEL_ASSET_ID          ,
                            LAST_UPDATE_DATE      ,
                            LAST_UPDATED_BY       ,
                            LAST_UPDATE_LOGIN     ,
                            CREATION_DATE         ,
                            CREATED_BY            ,
                            OBJECT_VERSION_NUMBER ,
                            ASSET_ID              ,
                            OBJECT_CODE           ,
                            OBJECT_ID             ,
                            ACTIVE_YN             ,
                            DELINQUENCY_ID)
                          VALUES
                           (IEX_DEL_ASSETS_S.NEXTVAL    ,
                            sysdate     ,
                            FND_GLOBAL.USER_ID,
                            FND_GLOBAL.LOGIN_ID,
                            sysdate     ,
                            FND_GLOBAL.USER_ID,
                            1     ,
                            p_id_tbl(i),
                            p_object_code   ,
                            p_object_id ,
                            'Y'     ,
                            p_del_id);

                        EXCEPTION
                            WHEN Others then
                                -- Error Handling for Others
--                                IF PG_DEBUG < 10  THEN
                                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                                   IEX_DEBUG_PUB.LOGMESSAGE
						('Add_rec: ' || '[ ' || p_source_module ||' ] - ADD Records Exception - INSERT >>
							'  || SQLCODE || ' >> ' || SQLERRM);
                                END IF;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                RollBack to Add_Rec;
                        END;
                    END IF;

                Exception
                    WHEN OTHERS then
                        -- Error Handling for Others
--                        IF PG_DEBUG < 10  THEN
                        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                           IEX_DEBUG_PUB.LOGMESSAGE
					('Add_rec: ' || '[ ' || p_source_module ||' ] - ADD Records Exception - UPDATE >>
						'  || SQLCODE || ' >> ' || SQLERRM);
                        END IF;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        RollBack to Add_Rec ;
               END;
            END LOOP;

        Elsif p_source_module = 'IEXWOCNT' then
            FOR i IN 1..nCount
            LOOP
                BEGIN
                    Update IEX_WRITEOFF_CONTRACTS
                    SET ACTIVE_YN      = 'Y'
                    where contract_id  = p_id_tbl(i)
                    AND delinquency_id = p_del_id
                    AND object_id      = p_object_id
                    AND object_code    = p_object_code;

                    IF sql%NOTFOUND THEN

                      BEGIN
                          INSERT INTO IEX_WRITEOFF_CONTRACTS
                           (WRITEOFF_CONTRACT_ID  ,
                            LAST_UPDATE_DATE      ,
                            LAST_UPDATED_BY       ,
                            LAST_UPDATE_LOGIN     ,
                            CREATION_DATE         ,
                            CREATED_BY            ,
                            OBJECT_VERSION_NUMBER ,
                            CONTRACT_ID           ,
                            OBJECT_CODE           ,
                            OBJECT_ID             ,
                            ACTIVE_YN             ,
                            DELINQUENCY_ID)
                          VALUES
                           (IEX_WRITEOFF_CONTRACTS_S.NEXTVAL,
                            sysdate     ,
                            FND_GLOBAL.USER_ID,
                            FND_GLOBAL.LOGIN_ID,
                            sysdate     ,
                            FND_GLOBAL.USER_ID,
                            1     ,
                            p_id_tbl(i),
                            p_object_code   ,
                            p_object_id ,
                            'Y'     ,
                            p_del_id);
                      EXCEPTION
                            WHEN Others then
                                -- Error Handling for Others
--                                IF PG_DEBUG < 10  THEN
                                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                                   IEX_DEBUG_PUB.LOGMESSAGE
						('Add_rec: ' || '[ ' || p_source_module ||' ] - ADD Records Exception - INSERT >>
							'  || SQLCODE || ' >> ' || SQLERRM);
                                END IF;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                RollBack to Add_rec ;
                      END;
                    END IF;
                Exception
                    WHEN OTHERS then
                        -- Error Handling for Others
--                        IF PG_DEBUG < 10  THEN
                        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                           IEX_DEBUG_PUB.LOGMESSAGE
					('Add_rec: ' || '[ ' || p_source_module ||' ] - ADD Records Exception - UPDATE >>
							'  || SQLCODE || ' >> ' || SQLERRM);
                        END IF;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        RollBack to Add_rec ;
               END;

            END LOOP;

        Elsif p_source_module = 'IEXWOINV' then
            FOR i IN 1..nCount
            LOOP
                Begin
                    Update IEX_WRITEOFF_INVOICES
                    SET ACTIVE_YN            = 'Y'
                    where lease_inv_line_id  = p_id_tbl(i)
                    AND delinquency_id       = p_del_id
                    AND object_id            = p_object_id
                    AND object_code          = p_object_code;

                    IF sql%NOTFOUND THEN

                    BEGIN
                        INSERT INTO IEX_WRITEOFF_INVOICES
                           (WRITEOFF_INVOICE_ID   ,
                            LAST_UPDATE_DATE      ,
                            LAST_UPDATED_BY       ,
                            LAST_UPDATE_LOGIN     ,
                            CREATION_DATE         ,
                            CREATED_BY            ,
                            OBJECT_VERSION_NUMBER ,
                            LEASE_INV_LINE_ID     ,
                            OBJECT_CODE           ,
                            OBJECT_ID             ,
                            ACTIVE_YN             ,
                            DELINQUENCY_ID)
                        VALUES
                           (IEX_WRITEOFF_INVOICES_S.NEXTVAL,
                            sysdate,
                            FND_GLOBAL.USER_ID,
                            FND_GLOBAL.LOGIN_ID,
                            sysdate,
                            FND_GLOBAL.USER_ID,
                            1,
                            p_id_tbl(i),
                            p_object_code,
                            p_object_id,
                            'Y',
                            p_del_id);
                        EXCEPTION
                            WHEN Others then
                                -- Error Handling for Others
--                                IF PG_DEBUG < 10  THEN
                                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                                   IEX_DEBUG_PUB.LOGMESSAGE
						('Add_rec: ' || '[ ' || p_source_module ||' ] - ADD Records Exception - INSERT >>
							'  || SQLCODE || ' >> ' || SQLERRM);
                                END IF;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                RollBack to Add_rec;
                        END;
                    END IF;

                Exception
                    WHEN OTHERS then
                        -- Error Handling for Others
--                        IF PG_DEBUG < 10  THEN
                        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                           IEX_DEBUG_PUB.LOGMESSAGE
					('Add_rec: ' || '[ ' || p_source_module ||' ] - ADD Records Exception - INSERT >>
						'  || SQLCODE || ' >> ' || SQLERRM);
                        END IF;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        RollBack to Add_rec;
               END;

            END LOOP;
      END IF; -- p_object_type

        -- Standard check for p_commit
      IF FND_API.to_Boolean(p_commit)
      THEN
          COMMIT WORK;
	ELSE
	    ROLLBACK TO ADD_REC ;
      END IF;

      -- Debug Message
      IEX_DEBUG_PUB.LogMessage('PUB: ' || l_api_name || ' end');
      IEX_DEBUG_PUB.LogMessage('End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => as_utility_pvt.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

   END Add_rec ;

   /* ------------------------------------------------------------------------------
					PROCEDURE REMOVE_REC
   ------------------------------------------------------------------------------ */
   PROCEDURE Remove_rec(p_api_version        IN  NUMBER,
                       p_init_msg_list       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                       p_commit		   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                       p_validation_level    IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
                       x_return_status       OUT NOCOPY VARCHAR2,
                       x_msg_count           OUT NOCOPY NUMBER,
                       x_msg_data            OUT NOCOPY VARCHAR2,
			     p_source_module	   IN	 VARCHAR2,
                       p_id_tbl	   	   IN  IEX_UTILITIES.t_numbers)
   IS

   	l_api_name varchar2(50) := 'remove_Rec';
   	nCount     NUMBER;

   BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT remove_Rec;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call(l_api_version_number,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean(p_init_msg_list)
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	nCount := p_id_tbl.count ;

	-- Delinquency Assets Form
      If p_source_module = 'IEXDLAST' then
	   FORALL cnt in 1..nCount
	   	 UPDATE IEX_DEL_ASSETS
	    	SET ACTIVE_YN = 'N'
	    	WHERE DEL_ASSET_ID = p_id_tbl(cnt) ;

      Elsif p_source_module = 'IEXWOCNT' then
	   FORALL cnt in 1..nCount
	   	UPDATE IEX_WRITEOFF_CONTRACTS
	    	SET ACTIVE_YN = 'N'
	    	WHERE WRITEOFF_CONTRACT_ID = p_id_tbl(cnt) ;

      Elsif p_source_module = 'IEXWOINV' then
	   FORALL cnt in 1..nCount
	   	UPDATE IEX_WRITEOFF_INVOICES
	    	SET ACTIVE_YN = 'N'
	    	WHERE WRITEOFF_INVOICE_ID = p_id_tbl(cnt) ;

	End If ;

        -- Standard check for p_commit
      IF FND_API.to_Boolean(p_commit)
      THEN
          COMMIT WORK;
	ELSE
	    ROLLBACK TO REMOVE_REC ;
      END IF;

      -- Debug Message
      IEX_DEBUG_PUB.LogMessage('PUB: ' || l_api_name || ' end');
      IEX_DEBUG_PUB.LogMessage('End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
--              IF PG_DEBUG < 10  THEN
              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 IEX_DEBUG_PUB.LOGMESSAGE
			('Remove_rec: ' || '[ ' || p_source_module ||' ] - REMOVE Records Exception  >> '
					|| SQLCODE || ' >> ' || SQLERRM);
              END IF;
		  rollback to remove_rec ;
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => as_utility_pvt.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

   END REMOVE_REC ;

   /* ------------------------------------------------------------------------------
					PROCEDURE ADD_ALL_REC
   ------------------------------------------------------------------------------ */
   PROCEDURE Add_All_rec(p_api_version        IN  NUMBER	,
                       p_init_msg_list       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                       p_commit		   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                       p_validation_level    IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
                       x_return_status       OUT NOCOPY VARCHAR2	,
                       x_msg_count           OUT NOCOPY NUMBER	,
                       x_msg_data            OUT NOCOPY VARCHAR2	,
			     p_source_module	   IN	 VARCHAR2	,
                       p_del_id		   IN  Number	,
                       p_object_code	   IN  Varchar2	,
                       p_object_id	     	   IN  Number	)
   IS
   	l_api_name varchar2(50) := 'add_all_Rec';
	v_id_tbl	IEX_UTILITIES.T_NUMBERS ;
   BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT add_all_Rec;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call(l_api_version_number,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean(p_init_msg_list)
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Delinquency Assets Form
      If p_source_module = 'IEXDLAST' then
	   -- Bulk Collect all the Asset Ids and call add lines
	   select asset_id
	   	BULK COLLECT INTO v_id_tbl
	   from iex_available_assets_v  ;
	   /*   MODIFY  */
	   -- where delinquency_id = p_del_id ;
	   -- and joins to contracts view.
      Elsif p_source_module = 'IEXWOCNT' then
	   -- Select id from Left Side Bali Spread for WriteOff Contract
	   --select contract_id
	   --	BULK COLLECT INTO v_id_tbl
	   --from iex_available_assets_v
	   --where delinquency_id = p_del_id ;
	   Null ;
      Elsif p_source_module = 'IEXWOINV' then
	   -- Select id from Left Side Bali Spread for WriteOff Invoice
	   --select asset_id
	   --	BULK COLLECT INTO v_id_tbl
	   --from iex_available_assets_v
	   --where delinquency_id = p_del_id ;
	   Null ;

	End If ;

    	Add_rec   (p_api_version      ,
                 p_init_msg_list 	,
                 p_commit		,
                 p_validation_level ,
                 x_return_status    ,
                 x_msg_count        ,
                 x_msg_data         ,
		     p_source_module	,
                 v_id_tbl	     	,
                 p_del_id		,
                 p_object_code	,
                 p_object_id	     	);

      -- Debug Message
      IEX_DEBUG_PUB.LogMessage('PUB: ' || l_api_name || ' end');
      IEX_DEBUG_PUB.LogMessage('End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
--              IF PG_DEBUG < 10  THEN
              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 IEX_DEBUG_PUB.LOGMESSAGE
			('Add_All_rec: ' || '[ ' || p_source_module ||' ] - ADD ALL Records Exception  >> '
					|| SQLCODE || ' >> ' || SQLERRM);
              END IF;
		  rollback to remove_rec ;
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => as_utility_pvt.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

   END ADD_ALL_REC ;

   /* ------------------------------------------------------------------------------
					PROCEDURE REMOVE_ALL_REC
   ------------------------------------------------------------------------------ */
   PROCEDURE Remove_All_rec(
			     p_api_version         IN  NUMBER	,
                       p_init_msg_list       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                       p_commit		   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                       p_validation_level    IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
                       x_return_status       OUT NOCOPY VARCHAR2	,
                       x_msg_count           OUT NOCOPY NUMBER	,
                       x_msg_data            OUT NOCOPY VARCHAR2	,
			     p_source_module	   IN	 VARCHAR2	,
                       p_del_id	   	   IN  Number 	)

  IS
   	l_api_name varchar2(50) := 'remove_all_Rec';
   BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT remove_all_Rec;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call(l_api_version_number,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean(p_init_msg_list)
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      If p_source_module = 'IEXDLAST' then
	    UPDATE IEX_DEL_ASSETS
	    	SET ACTIVE_YN = 'N'
	    WHERE DELINQUENCY_ID = p_del_id ;

      Elsif p_source_module = 'IEXWOCNT' then
	    UPDATE IEX_WRITEOFF_CONTRACTS
	    	SET ACTIVE_YN = 'N'
	    WHERE DELINQUENCY_ID = p_del_id ;

      Elsif p_source_module = 'IEXWOINV' then
	    UPDATE IEX_WRITEOFF_INVOICES
	    	SET ACTIVE_YN = 'N'
	    WHERE DELINQUENCY_ID = p_del_id ;

	End IF ;
        -- Standard check for p_commit
      IF FND_API.to_Boolean(p_commit)
      THEN
          COMMIT WORK;
	ELSE
	    ROLLBACK TO REMOVE_ALL_REC ;
      END IF;

      -- Debug Message
      IEX_DEBUG_PUB.LogMessage('PUB: ' || l_api_name || ' end');
      IEX_DEBUG_PUB.LogMessage('End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
--              IF PG_DEBUG < 10  THEN
              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 IEX_DEBUG_PUB.LOGMESSAGE
			('Remove_All_rec: ' || '[ ' || p_source_module ||' ] - REMOVE ALL Records Exception  >> '
					|| SQLCODE || ' >> ' || SQLERRM);
              END IF;
		  rollback to remove_rec ;
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => as_utility_pvt.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


   END REMOVE_ALL_REC ;


   PROCEDURE Start_Workflow(
	  p_api_version         IN  NUMBER := 1.0,
        p_init_msg_list       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit		      IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_validation_level    IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
        x_return_status       OUT NOCOPY VARCHAR2	,
        x_msg_count           OUT NOCOPY NUMBER	,
        x_msg_data            OUT NOCOPY VARCHAR2	,
	  p_user_id			IN  NUMBER		,
	  p_asset_info	      IN  VARCHAR2	,
        p_asset_addl_info	IN  Varchar2 	,
        p_delinquency_id      IN  Number    )
   IS
        l_result       		VARCHAR2(10);
        itemtype       		VARCHAR2(10);
        itemkey       		VARCHAR2(30);
        workflowprocess       VARCHAR2(30);

        l_error_msg     	VARCHAR2(2000);
        l_return_status       VARCHAR2(20);
        l_msg_count     	NUMBER;
        l_msg_data     		VARCHAR2(2000);
        l_api_name     		VARCHAR2(100) := 'START_WORKFLOW';
        l_api_version_number  CONSTANT NUMBER   := 1;

        l_manager_name        varchar2(240)  ;
        l_manager_id          Number         ;
        l_user_name           Varchar2(100)  ;

        CURSOR  manager_cur
        IS
        SELECT  b.user_id, b.user_name
        FROM    JTF_RS_RESOURCE_EXTNS a ,
                JTF_RS_RESOURCE_EXTNS b
        WHERE   b.source_id = a.source_mgr_id
        AND     a.user_id = p_user_id ;

        CURSOR  owner_cur
        IS
        SELECT  user_name
        FROM    JTF_RS_RESOURCE_EXTNS
        WHERE   user_id = p_user_id ;

    BEGIN
--	IF PG_DEBUG < 10  THEN
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	   IEX_DEBUG_PUB.LOGMESSAGE('Start_Workflow: ' || ' ');
	END IF;
--	IF PG_DEBUG < 10  THEN
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	   IEX_DEBUG_PUB.LOGMESSAGE('Start_Workflow: ' || '************  Start Workflow   Message Log Start  **********');
	END IF;

--	IF PG_DEBUG < 10  THEN
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	   IEX_DEBUG_PUB.LOGMESSAGE('Start_Workflow: ' || 'Addl Notification Info >> ' || p_asset_addl_info);
	END IF;
--	IF PG_DEBUG < 10  THEN
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	   IEX_DEBUG_PUB.LOGMESSAGE('Start_Workflow: ' || 'Passed User Id >> ' || Nvl(to_char(p_user_id), 'NULL'));
	END IF;

      -- Standard Start of API savepoint
      SAVEPOINT DEL_ASSET;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

--	IF PG_DEBUG < 10  THEN
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	   IEX_DEBUG_PUB.LOGMESSAGE('Start_Workflow: ' || 'Stage 1');
	END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IEX_DEBUG_PUB.LogMessage('Public API: ' || l_api_name || ' start');

      IEX_DEBUG_PUB.LogMessage('Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
--	IF PG_DEBUG < 10  THEN
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	   IEX_DEBUG_PUB.LOGMESSAGE('Start_Workflow: ' || 'Stage 2');
	END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      itemtype          := 'IEXDLAST';
      workflowprocess   := 'DELINQUENCY_ASSET';

	select IEX_DEL_WF_S.NEXTVAL
	Into Itemkey
	from dual ;

      BEGIN

	  OPEN Owner_cur	;
	  FETCH owner_Cur
	  INTO l_user_name ;

	  CLOSE owner_cur ;

        OPEN Manager_Cur ;

        FETCH   Manager_Cur
        INTO    l_manager_id,
                l_manager_name ;

        CLOSE Manager_Cur ;

	  if l_manager_id is NULL then
--		IF PG_DEBUG < 10  THEN
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		   IEX_DEBUG_PUB.LOGMESSAGE('Start_Workflow: ' || 'Setting Manager Id With Owner Id');
		END IF;
		l_manager_id 	:= p_user_id 	;
		l_manager_name 	:= l_user_name 	;
	  else
--		IF PG_DEBUG < 10  THEN
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		   IEX_DEBUG_PUB.LOGMESSAGE('Start_Workflow: ' || 'Manager Id Not Null >> ' || NVL(l_manager_id, 'NULL'));
		END IF;
	  End IF ;
--	  IF PG_DEBUG < 10  THEN
	  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	     IEX_DEBUG_PUB.LOGMESSAGE('Start_Workflow: ' || 'Owner Id ' || to_char(p_user_id) || ' Owner Name ' || l_user_name);
	  END IF;
--	  IF PG_DEBUG < 10  THEN
	  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	     IEX_DEBUG_PUB.LOGMESSAGE('Start_Workflow: ' || 'Manager Id ' || to_char(l_manager_id) || ' Manager Name ' || l_manager_name);
	  END IF;
      Exception
          WHEN OTHERS THEN
--              IF PG_DEBUG < 10  THEN
              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 IEX_DEBUG_PUB.LOGMESSAGE
			    ('Start_Workflow: ' || 'Getting Manager Information - '
                        || SQLCODE || ' >> ' || SQLERRM);
              END IF;
		      rollback to DEL_ASSET ;

              x_return_status := 'F';
              commit;
      End ;

--	IF PG_DEBUG < 10  THEN
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	   IEX_DEBUG_PUB.LOGMESSAGE('Start_Workflow: ' || 'Before Create Process');
	END IF;
--	IF PG_DEBUG < 10  THEN
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	   IEX_DEBUG_PUB.LOGMESSAGE('Start_Workflow: ' || 'Item Type ' || itemtype || ' Item Key ' || itemkey || ' process ' || workflowprocess);
	END IF;

      wf_engine.createprocess  (
                itemtype => itemtype,
              	itemkey  => itemkey,
              	process  => workflowprocess);
      --DBMS_OUTPUT.PUT_LINE('CREATE PROCESS, itemkey = ' || itemkey);

      -- User Id
      wf_engine.setitemattrnumber(
                itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'OWNER_ID',
                avalue   =>   p_user_id);
      -- Manager Name
      wf_engine.setitemattrtext(
                itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'OWNER_NAME',
                avalue   =>   l_user_name);


      -- Manager Id
      wf_engine.setitemattrnumber(
                itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'MANAGER_ID',
                avalue   =>   l_manager_id);
      -- Manager Name
      wf_engine.setitemattrtext(
                itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'MANAGER_NAME',
                avalue   =>   l_manager_name);
--	IF PG_DEBUG < 10  THEN
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	   IEX_DEBUG_PUB.LOGMESSAGE('Start_Workflow: ' || 'Stage 6');
	END IF;

      -- Passed asset Information from Form
      wf_engine.setitemattrtext(
                itemtype =>  itemtype,
                itemkey  =>   itemkey,
                aname    =>   'ASSET_INFO',
                avalue   =>   P_asset_info);

      -- Passed Additional asset Information from Form
      wf_engine.setitemattrtext(
                itemtype =>  itemtype,
                itemkey  =>  itemkey,
                aname    =>  'ASSET_ADDL_INFO',
                avalue   =>  p_asset_addl_info);

      wf_engine.startprocess(
                itemtype =>   itemtype,
                itemkey  =>   itemkey);
      --DBMS_OUTPUT.PUT_LINE('START PROCESS');
      --DBMS_OUTPUT.PUT_LINE('ITEMKEY '||itemkey);

      wf_engine.ItemStatus(  itemtype =>   ItemType,
                             itemkey   =>  ItemKey,
                             status   =>   l_return_status,
                             result   =>   l_result);

--	IF PG_DEBUG < 10  THEN
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	   IEX_DEBUG_PUB.LOGMESSAGE('Start_Workflow: ' || 'Return Status >> ' || l_return_status);
	END IF;

      if l_return_status = 'COMPLETE' OR l_return_status = 'ACTIVE' THEN
        x_return_status := 'S';
        commit;
      else
        x_return_status := 'F';
      end if;
      --DBMS_OUTPUT.PUT_LINE('GET ITEM STATUS = ' || l_return_status);
      --DBMS_OUTPUT.PUT_LINE('GET ITEM result = ' || l_result);

      -- Debug Message
      IEX_DEBUG_PUB.LogMessage('PUB: ' || l_api_name || ' end');
      IEX_DEBUG_PUB.LogMessage('End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

--	  IF PG_DEBUG < 10  THEN
	  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	     IEX_DEBUG_PUB.LOGMESSAGE('Start_Workflow: ' || '************  Start Workflow   Message Log End  **********');
	  END IF;

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => as_utility_pvt.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
	----------------------------------
	END start_workflow;
END IEX_DEL_SUB_PVT ;

/
