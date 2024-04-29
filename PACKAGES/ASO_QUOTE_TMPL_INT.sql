--------------------------------------------------------
--  DDL for Package ASO_QUOTE_TMPL_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_QUOTE_TMPL_INT" AUTHID CURRENT_USER AS
/* $Header: asoiqtms.pls 120.1 2005/06/29 12:35:29 appldev ship $ */

-- Start of Comments
-- Package name     : ASO_QUOTE_TMPL_INT
-- Purpose          :
-- End of Comments


TYPE LIST_TEMPLATE_TBL_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

G_Miss_List_Template_Tbl         LIST_TEMPLATE_TBL_TYPE;


PROCEDURE Add_Template_To_Quote(
    P_API_VERSION_NUMBER    IN   NUMBER,
    P_INIT_MSG_LIST         IN   VARCHAR2                                 := FND_API.G_FALSE,
    P_COMMIT                IN   VARCHAR2                                 := FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN   NUMBER                                   := FND_API.G_VALID_LEVEL_FULL,
    P_TEMPLATE_ID_TBL       IN   LIST_TEMPLATE_TBL_TYPE,
    P_QUOTE_HEADER_ID       IN   NUMBER,
    P_CONTROL_REC           IN   ASO_QUOTE_PUB.CONTROL_REC_TYPE           := ASO_QUOTE_PUB.G_MISS_control_REC,
    P_LAST_UPDATE_DATE      IN   DATE,
    X_RETURN_STATUS         OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_MSG_DATA              OUT NOCOPY /* file.sql.39 change */    VARCHAR2
);

PROCEDURE Add_Template_To_Quote(
    P_API_VERSION_NUMBER    IN   NUMBER,
    P_INIT_MSG_LIST         IN   VARCHAR2                                 := FND_API.G_FALSE,
    P_COMMIT                IN   VARCHAR2                                 := FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN   NUMBER                                   := FND_API.G_VALID_LEVEL_FULL,
    P_TEMPLATE_ID_TBL       IN   LIST_TEMPLATE_TBL_TYPE,
    P_QTE_HEADER_REC        IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_CONTROL_REC           IN   ASO_QUOTE_PUB.CONTROL_REC_TYPE           := ASO_QUOTE_PUB.G_MISS_control_REC,
    X_RETURN_STATUS         OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY /* file.sql.39 change */    NUMBER,
    X_MSG_DATA              OUT NOCOPY /* file.sql.39 change */    VARCHAR2
);


END; -- ASO_QUOTE_TMPL_INT


 

/
