--------------------------------------------------------
--  DDL for Package Body DPP_SLA_CLAIM_EXTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_SLA_CLAIM_EXTRACT_PUB" as
/* $Header: dppclexb.pls 120.6.12010000.3 2010/04/21 13:35:31 kansari ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          DPP_SLA_CLAIM_EXTRACT_PUB
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
G_PKG_NAME CONSTANT VARCHAR2(30):= 'DPP_SLA_CLAIM_EXTRACT_PUB';
G_FILE_NAME CONSTANT VARCHAR2(14) := 'dppsce.pls';

G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

---------------------------------------------------------------------
-- PROCEDURE
--    create_sla_extract
--
-- PURPOSE
--    This procedure creates
--
-- PARAMETERS
--    p_claim_line_tbl
--    x_return_status
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Create_SLA_Extract(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN    NUMBER   := FND_API.g_valid_level_full,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_claim_id                   IN   ozf_claims.claim_id%TYPE,
    p_claim_line_tbl             IN   claim_line_tbl_type,
    p_userid			 IN NUMBER
    )
IS
   L_API_NAME               CONSTANT VARCHAR2(30) := 'DPP_SLA_CLAIM_EXTRACT_PUB';
   L_API_VERSION_NUMBER     CONSTANT NUMBER   := 1.0;
   l_pvt_claim_rec          OZF_ClAIM_PVT.claim_rec_type;
   l_x_pvt_claim_rec        OZF_ClAIM_PVT.claim_rec_type;
   l_claim_line_tbl         claim_line_tbl_type := p_claim_line_tbl;
   --l_claim_line_rec         claim_line_rec_type ;
   l_error_index            NUMBER;
   l_transaction_header_id  DPP_TRANSACTION_HEADERS_ALL.transaction_header_id%TYPE;
   l_claim_type		    DPP_TRANSACTION_CLAIMS_ALL.CLAIM_TYPE%TYPE;
   l_transaction_line_id    DPP_TRANSACTION_LINES_ALL.transaction_line_id%TYPE;

   l_sql_statement	    VARCHAR2(200);
   l_sla_line_tbl_type 		sla_line_tbl_type;
   l_processed_flag DPP_XLA_HEADERS.PROCESSED_FLAG%TYPE := 'N';
   l_module 				CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_SLA_CLAIM_EXTRACT_PUB.CREATE_SLA_EXTRACT';

BEGIN
-- Standard Start of API savepoint
SAVEPOINT CREATE_SLA_Extract_PUB;
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
-- Debug Message

dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Public API: ' || l_api_name || ' pub start');

-- Initialize API return status to SUCCESS
x_return_status := FND_API.G_RET_STS_SUCCESS;
--
-- API body
--
   IF p_claim_line_tbl.count > 0 THEN

             BEGIN
		     SELECT TRANSACTION_HEADER_ID,
		     CLAIM_TYPE
		     INTO  l_transaction_header_id,
		           l_claim_type
		     FROM   DPP_TRANSACTION_CLAIMS_ALL
		     WHERE  CLAIM_ID=p_claim_id;

	     EXCEPTION

		  WHEN NO_DATA_FOUND THEN
		  dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'This is not a valid claim ');
		  FND_MESSAGE.set_name('DPP', 'DPP_INVALID_CLAIM');
		  FND_MESSAGE.set_token('CLAIM_ID', p_claim_id);
		  FND_MSG_PUB.add;
		  RAISE FND_API.G_EXC_ERROR;
	     END;

	     BEGIN
		     INSERT INTO DPP_XLA_HEADERS
		     (	TRANSACTION_HEADER_ID,
			PP_TRANSACTION_TYPE,
			BASE_TRANSACTION_HEADER_ID,
			PROCESSED_FLAG,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN
		     )
		     VALUES
		     (
			l_transaction_header_id,
			l_claim_type,
			p_claim_id,
			l_processed_flag,
			SYSDATE,
			p_userid,
			SYSDATE,
			p_userid,
			p_userid
		     );
  	  EXCEPTION
	  WHEN DUP_VAL_ON_INDEX THEN
	  FND_MESSAGE.set_name('DPP', 'DPP_DUPLICATE_HDR_EXTRACT');
	  FND_MESSAGE.set_token('TXN_HDR_ID', l_transaction_header_id);
	  FND_MESSAGE.set_token('BASE_TXN_HDR_ID', p_claim_id);
	  FND_MSG_PUB.add;
	  RAISE FND_API.G_EXC_ERROR;
	  END;

	   l_sla_line_tbl_type.delete;
	    FOR i IN p_claim_line_tbl.FIRST..p_claim_line_tbl.LAST LOOP

	        l_transaction_line_id:=NULL;

	      	BEGIN
			IF l_claim_type='SUPP_DSTR_CL' OR l_claim_type='SUPP_DSTR_INC_CL' THEN  --ANBBALAS: Included the condition l_claim_type='SUPP_DSTR_INC_CL' for Price Increase
				SELECT transaction_line_id
				INTO l_transaction_line_id
				FROM DPP_TRANSACTION_LINES_ALL
				WHERE transaction_header_id=l_transaction_header_id
				AND   inventory_item_id=p_claim_line_tbl(i).item_id
				AND   SUPP_DIST_CLAIM_ID=p_claim_line_tbl(i).claim_id;
			ELSIF l_claim_type='SUPP_CUST_CL' THEN
				SELECT 	CUSTOMER_INV_LINE_ID
				INTO l_transaction_line_id
				FROM DPP_CUSTOMER_CLAIMS_ALL
				WHERE transaction_header_id=l_transaction_header_id
				AND   inventory_item_id=p_claim_line_tbl(i).item_id
				AND   SUPP_CUST_CLAIM_ID=p_claim_line_tbl(i).claim_id
				AND   CUST_ACCOUNT_ID=p_claim_line_tbl(i).dpp_cust_account_id;
			ELSIF l_claim_type='CUST_CL' THEN
				SELECT 	CUSTOMER_INV_LINE_ID
				INTO l_transaction_line_id
				FROM DPP_CUSTOMER_CLAIMS_ALL
				WHERE transaction_header_id=l_transaction_header_id
				AND   inventory_item_id=p_claim_line_tbl(i).item_id
				AND   CUSTOMER_CLAIM_ID=p_claim_line_tbl(i).claim_id;
			END IF;
	      	EXCEPTION

			  WHEN NO_DATA_FOUND THEN
			  dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'This claim line does not exist in Price Protection ');
			  FND_MESSAGE.set_name('DPP', 'DPP_INVALID_CLAIM_LINE');
			  FND_MESSAGE.set_token('CLAIM_ID',p_claim_line_tbl(i).claim_id);
			  FND_MESSAGE.set_token('ITEM_ID',p_claim_line_tbl(i).item_id);
			  FND_MSG_PUB.add;
			  RAISE FND_API.G_EXC_ERROR;
	      	END;


	       l_sla_line_tbl_type(i).transaction_header_id:=l_transaction_header_id;
	       l_sla_line_tbl_type(i).transaction_line_id:=l_transaction_line_id;
	       l_sla_line_tbl_type(i).base_transaction_header_id:=p_claim_line_tbl(i).claim_id;
	       l_sla_line_tbl_type(i).base_transaction_line_id:=p_claim_line_tbl(i).claim_line_id;
	       l_sla_line_tbl_type(i).transaction_sub_type:=NULL;
	       l_sla_line_tbl_type(i).CREATION_DATE:=SYSDATE;
	       l_sla_line_tbl_type(i).CREATED_BY:=p_userid;
	       l_sla_line_tbl_type(i).LAST_UPDATE_DATE:=SYSDATE;
	       l_sla_line_tbl_type(i).LAST_UPDATED_BY:=p_userid;
	       l_sla_line_tbl_type(i).LAST_UPDATE_LOGIN:=p_userid;


	     END LOOP;

	   IF l_sla_line_tbl_type.count() >0 THEN

		FOR i in 1..l_sla_line_tbl_type.COUNT LOOP
		BEGIN
			INSERT INTO DPP_XLA_LINES
			(TRANSACTION_HEADER_ID,TRANSACTION_LINE_ID,
			BASE_TRANSACTION_HEADER_ID,
			BASE_TRANSACTION_LINE_ID,TRANSACTION_SUB_TYPE,
			CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,
			LAST_UPDATED_BY)
			VALUES (l_sla_line_tbl_type(i).transaction_header_id,
			l_sla_line_tbl_type(i).transaction_line_id,
			l_sla_line_tbl_type(i).base_transaction_header_id,
			l_sla_line_tbl_type(i).base_transaction_line_id,
			l_sla_line_tbl_type(i).transaction_sub_type,
			l_sla_line_tbl_type(i).creation_date,
			l_sla_line_tbl_type(i).created_by,
			l_sla_line_tbl_type(i).last_update_date,
			l_sla_line_tbl_type(i).last_updated_by
			);

		EXCEPTION
			  WHEN DUP_VAL_ON_INDEX THEN
			  FND_MESSAGE.set_name('DPP', 'DPP_DUPLICATE_LINE_EXTRACT');
			  FND_MESSAGE.set_token('TXN_HDR_ID', l_transaction_header_id);
			  FND_MESSAGE.set_token('BASE_TXN_HDR_ID', p_claim_id);
			  FND_MESSAGE.set_token('BASE_TXN_LINE_ID', l_sla_line_tbl_type(i).base_transaction_line_id);
			  FND_MSG_PUB.add;
			  RAISE FND_API.G_EXC_ERROR;
	  	END;
		END LOOP;
	   END IF;
     END IF;

   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
WHEN OZF_Utility_PVT.resource_locked THEN
   ROLLBACK TO CREATE_SLA_Extract_PUB;
   x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO CREATE_SLA_Extract_PUB;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO CREATE_SLA_Extract_PUB;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
WHEN OTHERS THEN
   ROLLBACK TO CREATE_SLA_Extract_PUB;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
   END IF;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
End Create_SLA_extract;
END DPP_SLA_CLAIM_EXTRACT_PUB;

/
