--------------------------------------------------------
--  DDL for Package ASO_SECURITY_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_SECURITY_INT" AUTHID CURRENT_USER AS
/* $Header: asoisecs.pls 120.1.12010000.2 2011/02/01 18:27:30 rassharm ship $ */

-- Start of Comments
-- Package name : ASO_SECURITY_INT
-- Purpose      : API methods for implementing Quoting Security
-- End of Comments


SUBTYPE Qte_Access_Rec_Type IS aso_quote_pub.Qte_Access_Rec_Type;

G_MISS_QTE_ACCESS_REC           Qte_Access_Rec_Type;

SUBTYPE Qte_Access_Tbl_Type IS aso_quote_pub.Qte_Access_Tbl_Type;

--TYPE Qte_Access_Tbl_Type IS TABLE OF Qte_Access_Rec_Type INDEX BY BINARY_INTEGER;

G_MISS_QTE_ACCESS_TBL           Qte_Access_Tbl_Type;


FUNCTION Get_Quote_Access
(
    P_RESOURCE_ID                IN   NUMBER,
    P_QUOTE_NUMBER               IN   NUMBER
) RETURN VARCHAR2;

PROCEDURE Add_Resource
(
    P_INIT_MSG_LIST              IN      VARCHAR2     := FND_API.G_FALSE,
    P_COMMIT                     IN      VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Access_Tbl             IN      Qte_Access_Tbl_Type,
    X_Qte_Access_Tbl             OUT NOCOPY /* file.sql.39 change */     Qte_Access_Tbl_Type,
    X_RETURN_STATUS              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    X_msg_count                  OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_msg_data                   OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);

PROCEDURE Add_Resource
(
    P_INIT_MSG_LIST              IN      VARCHAR2     := FND_API.G_FALSE,
    P_COMMIT                     IN      VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Access_Tbl             IN      Qte_Access_Tbl_Type,
    p_call_from_oafwk_flag       IN      VARCHAR2,
    X_Qte_Access_Tbl             OUT NOCOPY /* file.sql.39 change */     Qte_Access_Tbl_Type,
    X_RETURN_STATUS              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    X_msg_count                  OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_msg_data                   OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);

PROCEDURE Delete_Resource
(
    P_INIT_MSG_LIST              IN      VARCHAR2     := FND_API.G_FALSE,
    P_COMMIT                     IN      VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Access_Tbl             IN      Qte_Access_Tbl_Type,
    X_RETURN_STATUS              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    X_msg_count                  OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_msg_data                   OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);

PROCEDURE Add_SalesRep_QuoteCreator
(
    P_INIT_MSG_LIST              IN      VARCHAR2     := FND_API.G_FALSE,
    P_COMMIT                     IN      VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Rec             IN      ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_RETURN_STATUS              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    X_msg_count                  OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_msg_data                   OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);

END;

/
