--------------------------------------------------------
--  DDL for Package ASO_CHECK_TCA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_CHECK_TCA_PVT" AUTHID CURRENT_USER as
/* $Header: asovctcs.pls 120.4 2005/10/17 15:23:44 vtariker ship $ */
-- Package name     : ASO_CHECK_TCA_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE check_tca(
    p_api_version         IN     NUMBER,
    p_init_msg_list       IN     VARCHAR2  := FND_API.g_false,
    P_Qte_Rec             IN OUT NOCOPY  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    P_Header_Shipment_Tbl IN OUT NOCOPY  ASO_QUOTE_PUB.Shipment_Tbl_Type,
                              /*   := ASO_QUOTE_PUB.G_MISS_shipment_TBL, */
    P_Operation_Code      IN     VARCHAR2  := FND_API.G_MISS_CHAR,
    p_application_type_code IN     VARCHAR2  := FND_API.G_MISS_CHAR,
    x_return_status       OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
    x_msg_count           OUT NOCOPY /* file.sql.39 change */      NUMBER,
    x_msg_data            OUT NOCOPY /* file.sql.39 change */      VARCHAR2
);


PROCEDURE check_header_account_info(
    p_api_version         IN     NUMBER,
    p_init_msg_list       IN     VARCHAR2  := FND_API.g_false,
    p_cust_account_id     IN     NUMBER,
    P_Qte_Rec             IN OUT NOCOPY  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
				            /* := ASO_QUOTE_PUB.G_MISS_QTE_HEADER_REC, */
    P_Header_Shipment_Tbl IN OUT NOCOPY  ASO_QUOTE_PUB.Shipment_Tbl_Type,
				            /* := ASO_QUOTE_PUB.G_MISS_shipment_TBL,*/
    x_return_status       OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
    x_msg_count           OUT NOCOPY /* file.sql.39 change */      NUMBER,
    x_msg_data            OUT NOCOPY /* file.sql.39 change */      VARCHAR2);

PROCEDURE check_line_account_info(
    p_api_version         IN     NUMBER,
    p_init_msg_list       IN     VARCHAR2  := FND_API.g_false,
    p_cust_account_id     IN     NUMBER,
    P_Qte_Line_Rec        IN OUT NOCOPY  ASO_QUOTE_PUB.Qte_Line_Rec_Type,
                                 /*:= ASO_QUOTE_PUB.G_MISS_qte_line_REC, */
    P_Line_Shipment_Tbl   IN OUT NOCOPY  ASO_QUOTE_PUB.Shipment_Tbl_Type,
                                 /*:= ASO_QUOTE_PUB.G_MISS_shipment_TBL,*/
    p_application_type_code IN  VARCHAR2  := FND_API.G_MISS_CHAR,
    x_return_status       OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
    x_msg_count           OUT NOCOPY /* file.sql.39 change */      NUMBER,
    x_msg_data            OUT NOCOPY /* file.sql.39 change */      VARCHAR2);


PROCEDURE Customer_Account(
    p_api_version       IN      NUMBER,
    p_init_msg_list     IN      VARCHAR2  := FND_API.g_false,
    p_commit            IN      VARCHAR2  := FND_API.g_false,
    p_Party_Id          IN      NUMBER,
    p_error_ret         IN      VARCHAR2    := FND_API.G_TRUE,
    p_calling_api_flag  IN      NUMBER     := 0,
    x_Cust_Acct_Id      OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_return_status     OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count         OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data          OUT NOCOPY /* file.sql.39 change */       VARCHAR2);


 PROCEDURE Customer_Account_Site(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
    p_commit            IN  VARCHAR2  := FND_API.g_false,
    p_party_site_id     IN  NUMBER,
    p_acct_site_type    IN  VARCHAR2,
    p_cust_account_id   IN  NUMBER,
    x_cust_acct_site_id OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_site_use_id       OUT NOCOPY /* file.sql.39 change */   NUMBER);


PROCEDURE Cust_Acct_Relationship(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
    p_commit            IN  VARCHAR2  := FND_API.g_false,
    p_sold_to_cust_account	IN NUMBER,
    p_related_cust_account	IN NUMBER,
    p_relationship_type		IN VARCHAR2,
    x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2);


PROCEDURE Cust_Acct_Contact_Addr(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
    p_commit            IN  VARCHAR2  := FND_API.g_false,
    p_party_site_id     IN  NUMBER,
    p_role_type    	IN  VARCHAR2,
    p_cust_account_id   IN  NUMBER,
    p_party_id          IN NUMBER,
    p_cust_account_site IN NUMBER,
    x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_cust_account_role_id      OUT NOCOPY /* file.sql.39 change */   number);


PROCEDURE Assign_Customer_Accounts(
    p_init_msg_list     IN      VARCHAR2  := FND_API.G_FALSE,
    p_qte_header_id     IN      NUMBER,
    p_calling_api_flag  IN      NUMBER    := 0,
    x_return_status     OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
    x_msg_count         OUT NOCOPY /* file.sql.39 change */      NUMBER,
    x_msg_data          OUT NOCOPY /* file.sql.39 change */      VARCHAR2);


PROCEDURE Populate_Acct_Party (
    p_init_msg_list     IN      VARCHAR2  := FND_API.G_FALSE,
    p_hdr_cust_acct_id  IN      NUMBER,
    p_hdr_party_id      IN      NUMBER,
    p_party_site_id     IN      NUMBER,
    p_cust_account_id   IN OUT NOCOPY  NUMBER,
    p_cust_party_id     IN OUT NOCOPY  NUMBER,
    x_return_status     OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
    x_msg_count         OUT NOCOPY /* file.sql.39 change */      NUMBER,
    x_msg_data          OUT NOCOPY /* file.sql.39 change */      VARCHAR2);


PROCEDURE Check_Customer_Accounts(
    p_init_msg_list     IN    VARCHAR2  := FND_API.G_FALSE,
    p_qte_header_id     IN    NUMBER,
    x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2);


END ASO_CHECK_TCA_PVT;

 

/
