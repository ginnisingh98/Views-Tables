--------------------------------------------------------
--  DDL for Package Body DPP_EXECUTIONDETAILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_EXECUTIONDETAILS_PVT" AS
/* $Header: dppvexeb.pls 120.10.12010000.2 2010/04/21 11:33:07 anbbalas ship $ */

-- Package name     : DPP_EXECUTIONDETAILS_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'DPP_EXECUTIONDETAILS_PVT';
G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
G_FILE_NAME     CONSTANT VARCHAR2(14) := 'dppvexeb.pls';

---------------------------------------------------------------------
-- PROCEDURE
--    UUpdate_ExecutionDetails
--
-- PURPOSE
--    Update Execution Details
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Update_ExecutionDetails(
    p_api_version   	 		IN 	  NUMBER
   ,p_init_msg_list	     	IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         		IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level	 	IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     	OUT 	NOCOPY  VARCHAR2
   ,x_msg_count	         	OUT 	NOCOPY  NUMBER
   ,x_msg_data	         	OUT 	NOCOPY  VARCHAR2
   ,p_EXE_UPDATE_rec	 		IN OUT NOCOPY  DPP_EXE_UPDATE_REC_TYPE
   ,p_status_Update_tbl	  IN OUT  NOCOPY dpp_status_Update_tbl_type
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Update_ExecutionDetails';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
l_module                CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_EXECUTIONDETAILS_PVT.UPDATE_EXECUTIONDETAILS';

l_return_status         VARCHAR2(30);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);

l_exe_update_rec        DPP_EXECUTIONDETAILS_PVT.DPP_EXE_UPDATE_REC_TYPE     :=     p_EXE_UPDATE_rec;
l_status_Update_tbl     DPP_EXECUTIONDETAILS_PVT.dpp_status_Update_tbl_type  :=     p_status_Update_tbl;
l_update_count 					NUMBER;

l_process_code          VARCHAR2(30);

BEGIN

-- Standard begin of API savepoint
    SAVEPOINT  Update_ExecutionDetails_PVT;
-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
      p_api_version,
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

   -- Debug Message
   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_PROCEDURE, l_module, 'Private API: ' || l_api_name || 'start');

-- Initialize API return status to sucess
    l_return_status := FND_API.G_RET_STS_SUCCESS;

--
-- API body
--
  --Convert the execution status to upper case
    l_exe_update_rec.execution_status := UPPER(l_exe_update_rec.execution_status);
	BEGIN
		SELECT process_code
		  INTO l_process_code
		  FROM dpp_execution_details
		 WHERE execution_detail_id = l_exe_update_rec.execution_detail_id;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_EXCEPTION, l_module, 'Invalid Execution Detail ID: ' || l_exe_update_rec.execution_detail_id);
		RAISE FND_API.G_EXC_ERROR;
	END;

    UPDATE DPP_EXECUTION_DETAILS
       SET execution_end_date = sysdate
        ,execution_status = DECODE(execution_status,'WARNING', execution_status, l_exe_update_rec.execution_status)
        ,last_update_date = sysdate
        ,last_updated_by = l_exe_update_rec.Last_Updated_By
        ,provider_process_id = l_exe_update_rec.Provider_Process_Id
        ,provider_process_instance_id = l_exe_update_rec.Provider_Process_Instance_id
        ,output_xml = DECODE(execution_status,'WARNING',NVL(output_xml, XMLType(l_exe_update_rec.Output_XML)),XMLType(l_exe_update_rec.Output_XML))
        ,object_version_number = object_version_number + 1
    WHERE  transaction_header_id = l_exe_update_rec.transaction_header_id
    AND    execution_detail_id = l_exe_update_rec.Execution_Detail_ID;
    l_update_count := SQL%ROWCOUNT;
		IF SQL%ROWCOUNT = 0 THEN
			l_return_status := FND_API.G_RET_STS_ERROR;
			DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Invalid Execution Detail ID: ' || l_exe_update_rec.Execution_Detail_ID);
		END IF;

    FOR i IN l_status_Update_tbl.FIRST..l_status_Update_tbl.LAST
    LOOP
    IF l_process_code = 'UPDTPO' THEN
        UPDATE dpp_transaction_lines_all
        SET UPDATE_PURCHASING_DOCS = l_status_Update_tbl(i).Update_Status
            ,object_version_number = object_version_number + 1
						,last_update_date = sysdate
						,last_updated_by = l_exe_update_rec.Last_Updated_By
        WHERE transaction_header_id = l_EXE_UPDATE_rec.Transaction_Header_ID
        AND transaction_line_id = l_status_Update_tbl(i).transaction_line_id;

    ELSIF l_process_code = 'NTFYPO' THEN
        UPDATE dpp_transaction_lines_all
        SET NOTIFY_PURCHASING_DOCS = l_status_Update_tbl(i).Update_Status
            ,object_version_number = object_version_number + 1
						,last_update_date = sysdate
						,last_updated_by = l_exe_update_rec.Last_Updated_By
        WHERE transaction_header_id = l_EXE_UPDATE_rec.Transaction_Header_ID
        AND transaction_line_id = l_status_Update_tbl(i).transaction_line_id;

    ELSIF l_process_code = 'INVC' THEN
        UPDATE dpp_transaction_lines_all
        SET UPDATE_INVENTORY_COSTING = l_status_Update_tbl(i).Update_Status
            ,object_version_number = object_version_number + 1
						,last_update_date = sysdate
						,last_updated_by = l_exe_update_rec.Last_Updated_By
        WHERE transaction_header_id = l_EXE_UPDATE_rec.Transaction_Header_ID
        AND transaction_line_id = l_status_Update_tbl(i).transaction_line_id;

    ELSIF l_process_code = 'UPDTLP' THEN
        UPDATE dpp_transaction_lines_all
        SET UPDATE_ITEM_LIST_PRICE = l_status_Update_tbl(i).Update_Status
            ,object_version_number = object_version_number + 1
						,last_update_date = sysdate
						,last_updated_by = l_exe_update_rec.Last_Updated_By
        WHERE transaction_header_id = l_EXE_UPDATE_rec.Transaction_Header_ID
        AND transaction_line_id = l_status_Update_tbl(i).transaction_line_id;

    ELSIF l_process_code = 'INPL' THEN
        UPDATE dpp_transaction_lines_all
        SET NOTIFY_INBOUND_PRICELIST = l_status_Update_tbl(i).Update_Status
            ,object_version_number = object_version_number + 1
						,last_update_date = sysdate
						,last_updated_by = l_exe_update_rec.Last_Updated_By
        WHERE transaction_header_id = l_EXE_UPDATE_rec.Transaction_Header_ID
        AND transaction_line_id = l_status_Update_tbl(i).transaction_line_id;

    ELSIF l_process_code = 'OUTPL' THEN
        UPDATE dpp_transaction_lines_all
        SET NOTIFY_OUTBOUND_PRICELIST = l_status_Update_tbl(i).Update_Status
            ,object_version_number = object_version_number + 1
						,last_update_date = sysdate
						,last_updated_by = l_exe_update_rec.Last_Updated_By
        WHERE transaction_header_id = l_EXE_UPDATE_rec.Transaction_Header_ID
        AND transaction_line_id = l_status_Update_tbl(i).transaction_line_id;

   ELSIF l_process_code = 'DSTRINVCL' THEN
        UPDATE dpp_transaction_lines_all
        SET supp_dist_claim_status = l_status_Update_tbl(i).Update_Status
            ,object_version_number = object_version_number + 1
						,last_update_date = sysdate
						,last_updated_by = l_exe_update_rec.Last_Updated_By
        WHERE transaction_header_id = l_EXE_UPDATE_rec.Transaction_Header_ID
        AND transaction_line_id = l_status_Update_tbl(i).transaction_line_id;

   ELSIF l_process_code = 'CUSTINVCL' THEN
        UPDATE DPP_customer_claims_all
        SET supplier_claim_created = l_status_Update_tbl(i).Update_Status
            ,object_version_number = object_version_number + 1
						,last_update_date = sysdate
						,last_updated_by = l_exe_update_rec.Last_Updated_By
        WHERE transaction_header_id = l_EXE_UPDATE_rec.Transaction_Header_ID
        AND customer_inv_line_id = l_status_Update_tbl(i).transaction_line_id;

   ELSIF l_process_code = 'CUSTCL' THEN
        UPDATE DPP_customer_claims_all
        SET customer_claim_created = l_status_Update_tbl(i).Update_Status
            ,object_version_number = object_version_number + 1
						,last_update_date = sysdate
						,last_updated_by = l_exe_update_rec.Last_Updated_By
        WHERE transaction_header_id = l_EXE_UPDATE_rec.Transaction_Header_ID
        AND customer_inv_line_id = l_status_Update_tbl(i).transaction_line_id;

    ELSIF l_process_code = 'PROMO' THEN
        UPDATE dpp_transaction_lines_all
        SET NOTIFY_PROMOTIONS_PRICELIST = l_status_Update_tbl(i).Update_Status
            ,object_version_number = object_version_number + 1
						,last_update_date = sysdate
						,last_updated_by = l_exe_update_rec.Last_Updated_By
        WHERE transaction_header_id = l_EXE_UPDATE_rec.Transaction_Header_ID
        AND transaction_line_id = l_status_Update_tbl(i).transaction_line_id;
    END IF;
    END LOOP;

   x_return_status := l_return_status;
-- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;
   -- Debug Message
   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_PROCEDURE, l_module, 'Private API: ' || l_api_name || 'end');

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );

--Exception Handling
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Update_ExecutionDetails_PVT;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
   IF x_msg_count > 1 THEN
	    FOR I IN 1..x_msg_count LOOP
	        x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
	    END LOOP;
   END IF;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Update_ExecutionDetails_PVT;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
   IF x_msg_count > 1 THEN
	    FOR I IN 1..x_msg_count LOOP
	        x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
	    END LOOP;
 END IF;
WHEN OTHERS THEN
   ROLLBACK TO Update_ExecutionDetails_PVT;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'DPP_EXECUTIONDETAILS_PVT.Update_ExecutionDetails');
      fnd_message.set_token('ERRNO', sqlcode);
      fnd_message.set_token('REASON', sqlerrm);
      fnd_msg_pub.add;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
  IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
  END IF;
  END Update_ExecutionDetails;

---------------------------------------------------------------------
-- PROCEDURE
--    Update_ESB_InstanceID
--
-- PURPOSE
--    Update ESB Instance ID
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Update_ESB_InstanceID(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	   IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	   OUT 	NOCOPY  VARCHAR2
   ,x_msg_count	       OUT 	NOCOPY  NUMBER
   ,x_msg_data	       OUT 	NOCOPY  VARCHAR2
   ,p_execution_detail_id	 IN NUMBER
   ,p_esb_instance_id		   IN VARCHAR2
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Update_ESB_InstanceID';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
l_module                CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_EXECUTIONDETAILS_PVT.UPDATE_ESB_INSTANCEID';

l_return_status         VARCHAR2(30);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);

l_update_count					NUMBER;

BEGIN

-- Standard begin of API savepoint
    SAVEPOINT  Update_ESB_InstanceID_PVT;
-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
      p_api_version,
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

   -- Debug Message
   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_PROCEDURE, l_module, 'Private API: ' || l_api_name || 'start');

-- Initialize API return status to sucess
    l_return_status := FND_API.G_RET_STS_SUCCESS;

--
-- API body
--
		UPDATE dpp_execution_details
		SET    last_update_date = sysdate,
					 last_updated_by = fnd_global.user_id,
					 esb_instance_id = p_esb_instance_id,
					 object_version_number = object_version_number + 1
		WHERE  execution_detail_id = p_execution_detail_id;

    l_update_count := SQL%ROWCOUNT;
		IF SQL%ROWCOUNT = 0 THEN
			l_return_status := FND_API.G_RET_STS_ERROR;
			DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Invalid Execution Detail ID: ' || p_Execution_Detail_ID);
		END IF;

   x_return_status := l_return_status;
-- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;
   -- Debug Message
   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_PROCEDURE, l_module, 'Private API: ' || l_api_name || 'end');

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );

--Exception Handling
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Update_ESB_InstanceID_PVT;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
   IF x_msg_count > 1 THEN
	    FOR I IN 1..x_msg_count LOOP
	        x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
	    END LOOP;
   END IF;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Update_ESB_InstanceID_PVT;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
   IF x_msg_count > 1 THEN
	    FOR I IN 1..x_msg_count LOOP
	        x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
	    END LOOP;
 END IF;
WHEN OTHERS THEN
   ROLLBACK TO Update_ESB_InstanceID_PVT;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'DPP_EXECUTIONDETAILS_PVT.Update_ESB_InstanceID');
      fnd_message.set_token('ERRNO', sqlcode);
      fnd_message.set_token('REASON', sqlerrm);
      fnd_msg_pub.add;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
  IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
  END IF;
END Update_ESB_InstanceID;

END DPP_ExecutionDetails_PVT;

/
