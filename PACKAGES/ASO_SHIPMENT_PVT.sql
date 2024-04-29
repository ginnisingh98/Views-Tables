--------------------------------------------------------
--  DDL for Package ASO_SHIPMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_SHIPMENT_PVT" AUTHID CURRENT_USER as
/* $Header: asovshps.pls 120.1 2005/06/29 12:45:09 appldev ship $ */
-- Start of Comments
--
-- NAME
--   ASO_SHIPMENT_PVT
--
-- PURPOSE


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Shipment
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--
--   OUT:
--       x_return_status           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */  NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--   Version : Current version 1.0

--   End of Comments
--

PROCEDURE Delete_shipment(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_qte_line_rec               IN   aso_quote_pub.qte_line_rec_type
				:= ASO_QUOTE_PUB.G_MISS_QTE_LINE_REC,
    p_shipment_rec               IN   aso_quote_pub.shipment_rec_type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    );

FUNCTION Get_Ship_To_site_Id (
		p_qte_header_id		NUMBER,
		p_qte_line_id		NUMBER,
		p_shipment_id		NUMBER) RETURN NUMBER;
FUNCTION Get_Ship_To_party_site_Id (
          p_qte_header_id          NUMBER,
          p_qte_line_id       NUMBER,
          p_shipment_id       NUMBER) RETURN NUMBER;

FUNCTION Get_invoice_to_party_site_id (	p_qte_header_id		NUMBER,
				        p_qte_line_id		NUMBER
					) RETURN NUMBER;

FUNCTION Get_cust_to_party_site_id (
          p_qte_header_id          NUMBER,
          p_qte_line_id       NUMBER
          ) RETURN NUMBER;

/*FUNCTION Get_cust_acct_id (
                p_qte_header_id         NUMBER,
                p_qte_line_id           NUMBER,
                p_shipment_id           NUMBER) RETURN NUMBER;
*/


FUNCTION Get_party_name (
		p_party_id		NUMBER,
		p_party_type    VARCHAR2
		) RETURN VARCHAR2;
        FUNCTION Get_party_first_name (
		p_party_id		NUMBER,
		p_party_type    VARCHAR2
		) RETURN VARCHAR2;
        FUNCTION Get_party_mid_name (
		p_party_id		NUMBER,
		p_party_type    VARCHAR2
		) RETURN VARCHAR2;
        FUNCTION Get_party_last_name (
		p_party_id		NUMBER,
		p_party_type    VARCHAR2
		) RETURN VARCHAR2;

FUNCTION Get_ship_from_org_id (
		  p_qte_header_id		NUMBER,
            p_qte_line_id		NUMBER
            ) RETURN NUMBER;

FUNCTION Get_ship_method_code(p_qte_header_id  NUMBER, p_qte_line_id NUMBER) RETURN VARCHAR2;

FUNCTION Get_demand_class_code(p_qte_header_id  NUMBER, p_qte_line_id NUMBER) RETURN VARCHAR2;

FUNCTION Get_ship_to_party_site_id(p_qte_header_id  NUMBER, p_qte_line_id NUMBER) RETURN NUMBER;

FUNCTION Get_ship_to_cust_account_id(p_qte_header_id  NUMBER, p_qte_line_id NUMBER) RETURN NUMBER;


END ASO_SHIPMENT_PVT;




 

/
