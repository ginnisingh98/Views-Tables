--------------------------------------------------------
--  DDL for Package Body DPP_LOG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_LOG_PVT" AS
/* $Header: dppvlogb.pls 120.6.12010000.3 2010/04/26 07:08:40 pvaramba ship $ */
-- Package name     : DPP_LOG_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'DPP_LOG_PVT';
G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

---------------------------------------------------------------------
-- PROCEDURE
--    Insert_HeaderLog
--
-- PURPOSE
--    Insert Header Log
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Insert_HeaderLog(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	     IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level	 IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     OUT 	NOCOPY  VARCHAR2
   ,x_msg_count	         OUT 	NOCOPY  NUMBER
   ,x_msg_data	         OUT 	NOCOPY  VARCHAR2
   ,p_txn_hdr_rec	     IN    dpp_cst_hdr_rec_type
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Insert_HeaderLog';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_txn_hdr_rec           DPP_LOG_PVT.dpp_cst_hdr_rec_type := p_txn_hdr_rec;

l_profile_option_value 	VARCHAR2(150);

BEGIN

-- Standard begin of API savepoint
    SAVEPOINT  Insert_HeaderLog_PVT;
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


   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_PROCEDURE, 'dpp.plsql.' || L_FULL_NAME,  'Private API: ' || l_api_name || 'start');

-- Initialize API return status to sucess
 x_return_status := FND_API.G_RET_STS_SUCCESS;

--
-- API body
--

	l_profile_option_value := fnd_profile.VALUE('DPP_AUDIT_ENABLED');

	IF l_profile_option_value = 'Y' THEN

		-- Log has Agreement Status, Headers has Transaction Status
		INSERT INTO DPP_TRANSACTION_HEADERS_LOG
		(
		LOG_ID, LOG_MODE, TRANSACTION_HEADER_ID, REF_DOCUMENT_NUMBER, VENDOR_CONTACT_ID, CONTACT_EMAIL_ADDRESS,
		CONTACT_PHONE, DAYS_COVERED, TRANSACTION_STATUS, ORG_ID, CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE,
		LAST_UPDATED_BY, LAST_UPDATE_LOGIN, ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4,
		ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12,
		ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15, ATTRIBUTE16, ATTRIBUTE17, ATTRIBUTE18, ATTRIBUTE19,
		ATTRIBUTE20, ATTRIBUTE21, ATTRIBUTE22, ATTRIBUTE23, ATTRIBUTE24, ATTRIBUTE25, ATTRIBUTE26, ATTRIBUTE27,
		ATTRIBUTE28, ATTRIBUTE29, ATTRIBUTE30,EFFECTIVE_START_DATE, VENDOR_SITE_ID, VENDOR_ID, LAST_REFRESHED_BY,
		LAST_REFRESHED_DATE, TRX_CURRENCY)
		VALUES
		(DPP_HEADERS_LOG_ID_SEQ.nextval,l_txn_hdr_rec.LOG_MODE,l_txn_hdr_rec.TRANSACTION_HEADER_ID,
		l_txn_hdr_rec.REF_DOCUMENT_NUMBER, l_txn_hdr_rec.VENDOR_CONTACT_ID, l_txn_hdr_rec.CONTACT_EMAIL_ADDRESS,
		l_txn_hdr_rec.CONTACT_PHONE, l_txn_hdr_rec.DAYS_COVERED, l_txn_hdr_rec.TRANSACTION_STATUS,
		l_txn_hdr_rec.ORG_ID, l_txn_hdr_rec.CREATION_DATE, l_txn_hdr_rec.CREATED_BY, l_txn_hdr_rec.LAST_UPDATE_DATE,
		l_txn_hdr_rec.LAST_UPDATED_BY, l_txn_hdr_rec.LAST_UPDATE_LOGIN, l_txn_hdr_rec.ATTRIBUTE_CATEGORY,
		l_txn_hdr_rec.ATTRIBUTE1, l_txn_hdr_rec.ATTRIBUTE2, l_txn_hdr_rec.ATTRIBUTE3, l_txn_hdr_rec.ATTRIBUTE4,
		l_txn_hdr_rec.ATTRIBUTE5, l_txn_hdr_rec.ATTRIBUTE6, l_txn_hdr_rec.ATTRIBUTE7, l_txn_hdr_rec.ATTRIBUTE8,
		l_txn_hdr_rec.ATTRIBUTE9, l_txn_hdr_rec.ATTRIBUTE10, l_txn_hdr_rec.ATTRIBUTE11, l_txn_hdr_rec.ATTRIBUTE12,
		l_txn_hdr_rec.ATTRIBUTE13, l_txn_hdr_rec.ATTRIBUTE14, l_txn_hdr_rec.ATTRIBUTE15, l_txn_hdr_rec.ATTRIBUTE16,
		l_txn_hdr_rec.ATTRIBUTE17, l_txn_hdr_rec.ATTRIBUTE18, l_txn_hdr_rec.ATTRIBUTE19,
		l_txn_hdr_rec.ATTRIBUTE20, l_txn_hdr_rec.ATTRIBUTE21, l_txn_hdr_rec.ATTRIBUTE22,
		l_txn_hdr_rec.ATTRIBUTE23, l_txn_hdr_rec.ATTRIBUTE24, l_txn_hdr_rec.ATTRIBUTE25,
		l_txn_hdr_rec.ATTRIBUTE26, l_txn_hdr_rec.ATTRIBUTE27,
		l_txn_hdr_rec.ATTRIBUTE28, l_txn_hdr_rec.ATTRIBUTE29, l_txn_hdr_rec.ATTRIBUTE30,
		l_txn_hdr_rec.EFFECTIVE_START_DATE, l_txn_hdr_rec.VENDOR_SITE_ID, l_txn_hdr_rec.VENDOR_ID,
		l_txn_hdr_rec.LAST_REFRESHED_BY,
		l_txn_hdr_rec.LAST_REFRESHED_DATE, l_txn_hdr_rec.TRX_CURRENCY);


   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Debug Profile Option Value: ' || l_profile_option_value || '. Record inserted into DPP_TRANSACTION_HEADERS_LOG.');

	ELSE

   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Debug Profile Option Value: ' || l_profile_option_value || '. No Logging.');

	END IF;

    -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Private API: ' || l_api_name || 'end');

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );

--Exception Handling
    EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO INSERT_HEADERLOG_PVT;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO INSERT_HEADERLOG_PVT;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
WHEN OTHERS THEN
   ROLLBACK TO INSERT_HEADERLOG_PVT;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
   fnd_message.set_token('ROUTINE', 'DPP_LOG_PVT.Insert_HeaderLog');
   fnd_message.set_token('ERRNO', sqlcode);
   fnd_message.set_token('REASON', sqlerrm);
   FND_MSG_PUB.ADD;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );

END Insert_HeaderLog;

PROCEDURE Insert_LinesLog(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	     IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level	 IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     OUT 	NOCOPY  VARCHAR2
   ,x_msg_count	         OUT 	NOCOPY  NUMBER
   ,x_msg_data	         OUT 	NOCOPY  VARCHAR2
   ,p_txn_lines_tbl	     IN    dpp_txn_line_tbl_type
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Insert_LinesLog';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_txn_lines_tbl			dpp_txn_line_tbl_type := p_txn_lines_tbl;
l_profile_option_value 	VARCHAR2(150);

BEGIN

-- Standard begin of API savepoint
    SAVEPOINT  Insert_LinesLog_PVT;
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


   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_PROCEDURE, 'dpp.plsql.' || L_FULL_NAME,  'Private API: ' || l_api_name || 'start');

-- Initialize API return status to sucess
 x_return_status := FND_API.G_RET_STS_SUCCESS;

--
-- API body
--

	l_profile_option_value := fnd_profile.VALUE('DPP_AUDIT_ENABLED');

	IF l_profile_option_value = 'Y' THEN

		FOR i in l_txn_lines_tbl.FIRST..l_txn_lines_tbl.LAST
		LOOP
			INSERT INTO DPP_TRANSACTION_LINES_LOG
			(
			LOG_ID, LOG_MODE, TRANSACTION_LINE_ID, SUPPLIER_PART_NUM, INVENTORY_ITEM_ID, PRIOR_PRICE,
			CHANGE_TYPE, CHANGE_VALUE, COVERED_INVENTORY, APPROVED_INVENTORY, ORG_ID,
			CREATION_DATE, CREATED_BY,
			LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3,
			ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10,
			ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15, ATTRIBUTE16, ATTRIBUTE17, ATTRIBUTE18, ATTRIBUTE19,
			ATTRIBUTE20, ATTRIBUTE21, ATTRIBUTE22, ATTRIBUTE23, ATTRIBUTE24, ATTRIBUTE25, ATTRIBUTE26, ATTRIBUTE27,
			ATTRIBUTE28, ATTRIBUTE29, ATTRIBUTE30,
			CLAIM_AMOUNT, UPDATE_PURCHASING_DOCS, NOTIFY_PURCHASING_DOCS,
			UPDATE_INVENTORY_COSTING, UPDATE_ITEM_LIST_PRICE, SUPP_DIST_CLAIM_STATUS, ONHAND_INVENTORY,
			MANUALLY_ADJUSTED, NOTIFY_INBOUND_PRICELIST, NOTIFY_OUTBOUND_PRICELIST,NOTIFY_PROMOTIONS_PRICELIST
			)
			VALUES
			(
			DPP_LINES_LOG_ID_SEQ.nextval,l_txn_lines_tbl(i).LOG_MODE, l_txn_lines_tbl(i).TRANSACTION_LINE_ID,
			l_txn_lines_tbl(i).SUPPLIER_PART_NUM, l_txn_lines_tbl(i).INVENTORY_ITEM_ID, l_txn_lines_tbl(i).PRIOR_PRICE,
			l_txn_lines_tbl(i).CHANGE_TYPE, l_txn_lines_tbl(i).CHANGE_VALUE, l_txn_lines_tbl(i).COVERED_INVENTORY,
			l_txn_lines_tbl(i).APPROVED_INVENTORY, l_txn_lines_tbl(i).ORG_ID,
			l_txn_lines_tbl(i).CREATION_DATE, l_txn_lines_tbl(i).CREATED_BY,
			l_txn_lines_tbl(i).LAST_UPDATE_DATE, l_txn_lines_tbl(i).LAST_UPDATED_BY, l_txn_lines_tbl(i).LAST_UPDATE_LOGIN,
			l_txn_lines_tbl(i).ATTRIBUTE_CATEGORY, l_txn_lines_tbl(i).ATTRIBUTE1, l_txn_lines_tbl(i).ATTRIBUTE2,
			l_txn_lines_tbl(i).ATTRIBUTE3,
			l_txn_lines_tbl(i).ATTRIBUTE4, l_txn_lines_tbl(i).ATTRIBUTE5, l_txn_lines_tbl(i).ATTRIBUTE6,
			l_txn_lines_tbl(i).ATTRIBUTE7, l_txn_lines_tbl(i).ATTRIBUTE8, l_txn_lines_tbl(i).ATTRIBUTE9,
			l_txn_lines_tbl(i).ATTRIBUTE10,
			l_txn_lines_tbl(i).ATTRIBUTE11, l_txn_lines_tbl(i).ATTRIBUTE12, l_txn_lines_tbl(i).ATTRIBUTE13,
			l_txn_lines_tbl(i).ATTRIBUTE14, l_txn_lines_tbl(i).ATTRIBUTE15,
			l_txn_lines_tbl(i).ATTRIBUTE16, l_txn_lines_tbl(i).ATTRIBUTE17, l_txn_lines_tbl(i).ATTRIBUTE18,
			l_txn_lines_tbl(i).ATTRIBUTE19,
			l_txn_lines_tbl(i).ATTRIBUTE20, l_txn_lines_tbl(i).ATTRIBUTE21, l_txn_lines_tbl(i).ATTRIBUTE22,
			l_txn_lines_tbl(i).ATTRIBUTE23, l_txn_lines_tbl(i).ATTRIBUTE24, l_txn_lines_tbl(i).ATTRIBUTE25,
			l_txn_lines_tbl(i).ATTRIBUTE26, l_txn_lines_tbl(i).ATTRIBUTE27,
			l_txn_lines_tbl(i).ATTRIBUTE28, l_txn_lines_tbl(i).ATTRIBUTE29, l_txn_lines_tbl(i).ATTRIBUTE30,
			l_txn_lines_tbl(i).CLAIM_AMOUNT, l_txn_lines_tbl(i).UPDATE_PURCHASING_DOCS,
			l_txn_lines_tbl(i).NOTIFY_PURCHASING_DOCS,
			l_txn_lines_tbl(i).UPDATE_INVENTORY_COSTING, l_txn_lines_tbl(i).UPDATE_ITEM_LIST_PRICE,
			l_txn_lines_tbl(i).SUPP_DIST_CLAIM_STATUS, l_txn_lines_tbl(i).ONHAND_INVENTORY,
			l_txn_lines_tbl(i).MANUALLY_ADJUSTED, l_txn_lines_tbl(i).NOTIFY_INBOUND_PRICELIST,
			l_txn_lines_tbl(i).NOTIFY_OUTBOUND_PRICELIST, l_txn_lines_tbl(i).NOTIFY_PROMOTIONS_PRICELIST
			);
		END LOOP;


   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Debug Profile Option Value: ' || l_profile_option_value || '. Record(s) inserted into DPP_TRANSACTION_LINES_LOG.');

	 ELSE

		DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Debug Profile Option Value: ' || l_profile_option_value || '. No Logging.');

   END IF;

    -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Private API: ' || l_api_name || 'end');

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );

--Exception Handling
EXCEPTION

WHEN OTHERS THEN
   ROLLBACK TO INSERT_LINESLOG_PVT;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
   fnd_message.set_token('ROUTINE', 'DPP_LOG_PVT.Insert_LinesLog');
   fnd_message.set_token('ERRNO', sqlcode);
   fnd_message.set_token('REASON', sqlerrm);
   FND_MSG_PUB.ADD;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
END Insert_LinesLog;

PROCEDURE Insert_ClaimsLog(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	     IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level	 IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     OUT 	NOCOPY  VARCHAR2
   ,x_msg_count	         OUT 	NOCOPY  NUMBER
   ,x_msg_data	         OUT 	NOCOPY  VARCHAR2
   ,p_claim_lines_tbl	     IN    dpp_claim_line_tbl_type
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Insert_ClaimsLog';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_claim_lines_tbl dpp_claim_line_tbl_type := p_claim_lines_tbl;
l_profile_option_value 	VARCHAR2(150);

BEGIN

-- Standard begin of API savepoint
    SAVEPOINT  Insert_ClaimsLog_PVT;
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


   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_PROCEDURE, 'dpp.plsql.' || L_FULL_NAME,  'Private API: ' || l_api_name || 'start');

-- Initialize API return status to sucess
 x_return_status := FND_API.G_RET_STS_SUCCESS;

--
-- API body
--

	l_profile_option_value := fnd_profile.VALUE('DPP_AUDIT_ENABLED');

	IF l_profile_option_value = 'Y' THEN

		FOR i in l_claim_lines_tbl.FIRST..l_claim_lines_tbl.LAST
		LOOP
			INSERT INTO DPP_CUSTOMER_CLAIMS_LOG
			(
			LOG_ID, LOG_MODE, CUSTOMER_INV_LINE_ID, INVENTORY_ITEM_ID, CUSTOMER_NEW_PRICE,
			REPORTED_INVENTORY, CUST_CLAIM_AMT, DEBIT_MEMO_NUMBER, CUSTOMER_CLAIM_ID,
			CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
			ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6,
			ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13,
			ATTRIBUTE14, ATTRIBUTE15, ATTRIBUTE16, ATTRIBUTE17, ATTRIBUTE18, ATTRIBUTE19,
			ATTRIBUTE20, ATTRIBUTE21, ATTRIBUTE22, ATTRIBUTE23, ATTRIBUTE24, ATTRIBUTE25, ATTRIBUTE26, ATTRIBUTE27,
			ATTRIBUTE28, ATTRIBUTE29, ATTRIBUTE30,SUPP_CLAIM_AMT, SUPP_CUST_CLAIM_ID,CUST_ACCOUNT_ID,
			CUSTOMER_CLAIM_CREATED,SUPPLIER_CLAIM_CREATED, ORG_ID, TRX_CURRENCY
			)
			VALUES
			(
			DPP_CLAIMS_LOG_ID_SEQ.nextval,l_claim_lines_tbl(i).LOG_MODE, l_claim_lines_tbl(i).CUSTOMER_INV_LINE_ID,
			l_claim_lines_tbl(i).INVENTORY_ITEM_ID, l_claim_lines_tbl(i).CUSTOMER_NEW_PRICE,
			l_claim_lines_tbl(i).REPORTED_INVENTORY, l_claim_lines_tbl(i).CUST_CLAIM_AMT,
			l_claim_lines_tbl(i).DEBIT_MEMO_NUMBER, l_claim_lines_tbl(i).CUSTOMER_CLAIM_ID,
			l_claim_lines_tbl(i).CREATION_DATE, l_claim_lines_tbl(i).CREATED_BY, l_claim_lines_tbl(i).LAST_UPDATE_DATE,
			l_claim_lines_tbl(i).LAST_UPDATED_BY, l_claim_lines_tbl(i).LAST_UPDATE_LOGIN,
			l_claim_lines_tbl(i).ATTRIBUTE_CATEGORY, l_claim_lines_tbl(i).ATTRIBUTE1, l_claim_lines_tbl(i).ATTRIBUTE2,
			l_claim_lines_tbl(i).ATTRIBUTE3, l_claim_lines_tbl(i).ATTRIBUTE4, l_claim_lines_tbl(i).ATTRIBUTE5,
			l_claim_lines_tbl(i).ATTRIBUTE6,
			l_claim_lines_tbl(i).ATTRIBUTE7, l_claim_lines_tbl(i).ATTRIBUTE8, l_claim_lines_tbl(i).ATTRIBUTE9,
			l_claim_lines_tbl(i).ATTRIBUTE10, l_claim_lines_tbl(i).ATTRIBUTE11, l_claim_lines_tbl(i).ATTRIBUTE12,
			l_claim_lines_tbl(i).ATTRIBUTE13,
			l_claim_lines_tbl(i).ATTRIBUTE14, l_claim_lines_tbl(i).ATTRIBUTE15, l_claim_lines_tbl(i).ATTRIBUTE16,
			l_claim_lines_tbl(i).ATTRIBUTE17, l_claim_lines_tbl(i).ATTRIBUTE18, l_claim_lines_tbl(i).ATTRIBUTE19,
			l_claim_lines_tbl(i).ATTRIBUTE20, l_claim_lines_tbl(i).ATTRIBUTE21, l_claim_lines_tbl(i).ATTRIBUTE22,
			l_claim_lines_tbl(i).ATTRIBUTE23, l_claim_lines_tbl(i).ATTRIBUTE24, l_claim_lines_tbl(i).ATTRIBUTE25,
			l_claim_lines_tbl(i).ATTRIBUTE26, l_claim_lines_tbl(i).ATTRIBUTE27,
			l_claim_lines_tbl(i).ATTRIBUTE28, l_claim_lines_tbl(i).ATTRIBUTE29, l_claim_lines_tbl(i).ATTRIBUTE30,
			l_claim_lines_tbl(i).SUPP_CLAIM_AMT, l_claim_lines_tbl(i).SUPP_CUST_CLAIM_ID,
			l_claim_lines_tbl(i).CUST_ACCOUNT_ID,l_claim_lines_tbl(i).CUSTOMER_CLAIM_CREATED,
			l_claim_lines_tbl(i).SUPPLIER_CLAIM_CREATED, l_claim_lines_tbl(i).ORG_ID, l_claim_lines_tbl(i).TRX_CURRENCY
			);
		END LOOP;


   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Debug Profile Option Value: ' || l_profile_option_value || '. Record(s) inserted into DPP_CUSTOMER_CLAIMS_LOG.');

	 ELSE

		 DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Debug Profile Option Value: ' || l_profile_option_value || '. No Logging.');

   END IF;

    -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Private API: ' || l_api_name || 'end');

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );

--Exception Handling
    EXCEPTION

WHEN OTHERS THEN
   ROLLBACK TO INSERT_CLAIMSLOG_PVT;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
   fnd_message.set_token('ROUTINE', 'DPP_LOG_PVT.Insert_ClaimsLog');
   fnd_message.set_token('ERRNO', sqlcode);
   fnd_message.set_token('REASON', sqlerrm);
   FND_MSG_PUB.ADD;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
END Insert_ClaimsLog;

END DPP_LOG_PVT;

/
