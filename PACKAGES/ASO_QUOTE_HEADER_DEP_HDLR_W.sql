--------------------------------------------------------
--  DDL for Package ASO_QUOTE_HEADER_DEP_HDLR_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_QUOTE_HEADER_DEP_HDLR_W" AUTHID CURRENT_USER AS
/* $Header: asovqwhs.pls 120.2 2005/08/10 18:26:11 appldev noship $ */
-- Start of Comments
-- Package name     : ASO_QUOTE_HEADER_DEP_HDLR_W



PROCEDURE Get_Dependent_Attributes_Sets
  (
      X_Q_CONTRACT_ID                 OUT NOCOPY jtf_number_table
  ,   X_Q_CUST_ACCOUNT_ID             OUT NOCOPY jtf_number_table
  ,   X_Q_CUST_PARTY_ID               OUT NOCOPY jtf_number_table
  ,   X_Q_INV_TO_CUST_ACCT_ID         OUT NOCOPY jtf_number_table
  ,   X_Q_INV_TO_PTY_SITE_ID          OUT NOCOPY jtf_number_table
  ,   X_Q_ORDER_TYPE_ID               OUT NOCOPY jtf_number_table
  ,   X_Q_ORG_ID                      OUT NOCOPY jtf_number_table
  ,   X_Q_PRICE_LIST_ID               OUT NOCOPY jtf_number_table
  ,   X_Q_RESOURCE_ID                 OUT NOCOPY jtf_number_table
  ,   X_Q_SHIP_TO_CUST_ACCT_ID        OUT NOCOPY jtf_number_table
  ,   X_Q_SHIP_TO_PARTY_SITE_ID       OUT NOCOPY jtf_number_table
  ,   X_RETURN_STATUS                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  ,   X_MSG_COUNT                     OUT NOCOPY /* file.sql.39 change */ NUMBER
  ,   X_MSG_DATA                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


END ASO_QUOTE_HEADER_DEP_HDLR_W;


 

/
