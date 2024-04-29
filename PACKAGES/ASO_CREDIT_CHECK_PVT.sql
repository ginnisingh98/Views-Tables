--------------------------------------------------------
--  DDL for Package ASO_CREDIT_CHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_CREDIT_CHECK_PVT" AUTHID CURRENT_USER as
/* $Header: asoiqccs.pls 120.1 2005/06/29 12:35:22 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_credit_check_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

--
--
-- Record types
-- ASO_QUOTE_PUB.Qte_Header_Rec_type
--
--
--
-- API
-- CREDIT_CHECK
--

-- this procedure is used to perform internal and external credit check for a customer
-- the input needed is Quote Header Record.
-- The following are the values that have to be populated in the header record.
-- Quote Header Id, Currency Code, Org Id, Total Quote Price, Invoice to Cust Party Id,
-- Invoice to Cust Party Name, Invoice to Cust Acct Number, Invoice to Address1,
-- Invoice to Address2 , Invoice to Address3 , Invoice to Address4, Invoice to County,
-- Invoice to City, Invoice to Province, Invoice to State, Invoice to Country Code,
-- Invoice to Country, Invoice to Postal Code, Invoice Party Site Id, Invoice to Cust Account Id.

-- Subha Madapusi - Quote Credit Check.

PROCEDURE Credit_Check(
  P_API_VERSION		          IN	NUMBER,
  P_INIT_MSG_LIST	          IN	VARCHAR2  := FND_API.G_FALSE,
  P_COMMIT		          IN 	VARCHAR2  := FND_API.G_FALSE,
  P_QTE_HEADER_REC                IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
  X_RESULT_OUT                    OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  X_CC_HOLD_COMMENT               OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  X_RETURN_STATUS	          OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
  X_MSG_COUNT		          OUT NOCOPY /* file.sql.39 change */  	NUMBER,
  X_MSG_DATA		          OUT NOCOPY /* file.sql.39 change */  	VARCHAR2
);

--subha madapusi - quote credit check end.

End ASO_CREDIT_CHECK_PVT;

 

/
