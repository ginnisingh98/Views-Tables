--------------------------------------------------------
--  DDL for Package ASO_DEFAULTING_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_DEFAULTING_INT" AUTHID CURRENT_USER AS
/* $Header: asoidefs.pls 120.1 2005/06/29 12:33:13 appldev noship $ */
-- Start of Comments
-- Package name     : ASO_DEFAULTING_INT
-- Purpose          :
-- History          :
--    08-31-2004 hyang - created
-- NOTE             :
-- End of Comments

  TYPE Control_Rec_Type IS RECORD
  (
  	 Override_Trigger_Flag    VARCHAR2(1)   := FND_API.G_FALSE,
  	 Dependency_Flag	        VARCHAR2(1)   := FND_API.G_TRUE,
  	 Defaulting_Flag	        VARCHAR2(1)   := FND_API.G_TRUE,
  	 Application_Type_Code	  VARCHAR2(30)  := FND_API.G_MISS_CHAR,
  	 Defaulting_Flow_Code	    VARCHAR2(50)	:= FND_API.G_MISS_CHAR,
  	 Last_Update_Date         DATE          := FND_API.G_MISS_DATE,
  	 Object_Version_Number	  NUMBER		    := FND_API.G_MISS_NUM
  );

  G_MISS_CONTROL_REC          Control_Rec_Type;

  TYPE ATTRIBUTE_CODES_TBL_TYPE IS TABLE OF VARCHAR2(30)
                                INDEX BY BINARY_INTEGER;

  G_MISS_ATTRIBUTE_CODES_TBL  ATTRIBUTE_CODES_TBL_TYPE;

  TYPE ATTRIBUTE_IDS_TBL_TYPE IS TABLE OF NUMBER
                                INDEX BY BINARY_INTEGER;

  G_MISS_ATTRIBUTE_IDS_TBL  ATTRIBUTE_IDS_TBL_TYPE;

  -- Header miscellaneous record structure for forward compability.
  TYPE Header_Misc_Rec_Type IS RECORD
  (
  	 ATTRIBUTE1	  VARCHAR2(30)  := FND_API.G_MISS_CHAR
  );

  G_MISS_HEADER_MISC_REC        Header_Misc_Rec_Type;

  -- Line miscellaneous record structure for forward compability.
  TYPE Line_Misc_Rec_Type IS RECORD
  (
  	 ATTRIBUTE1	  VARCHAR2(30)  := FND_API.G_MISS_CHAR
  );

  G_MISS_LINE_MISC_REC          Line_Misc_Rec_Type;



  PROCEDURE Default_Entity (
    P_API_VERSION               IN        NUMBER,
    P_INIT_MSG_LIST             IN        VARCHAR2 := FND_API.G_FALSE,
    P_COMMIT                    IN        VARCHAR2 := FND_API.G_FALSE,
    P_CONTROL_REC               IN        CONTROL_REC_TYPE
                                            := G_MISS_CONTROL_REC,
    P_DATABASE_OBJECT_NAME      IN        VARCHAR2,
    P_TRIGGER_ATTRIBUTES_TBL    IN        ATTRIBUTE_CODES_TBL_TYPE
                                            := G_MISS_ATTRIBUTE_CODES_TBL,
    P_QUOTE_HEADER_REC          IN        ASO_QUOTE_PUB.QTE_HEADER_REC_TYPE
                                            := ASO_QUOTE_PUB.G_MISS_QTE_HEADER_REC,
    P_OPP_QTE_HEADER_REC        IN        ASO_OPP_QTE_PUB.OPP_QTE_IN_REC_TYPE
                                            := ASO_OPP_QTE_PUB.G_MISS_OPP_QTE_IN_REC,
    P_HEADER_MISC_REC           IN        HEADER_MISC_REC_TYPE
                                            := G_MISS_HEADER_MISC_REC,
    P_HEADER_SHIPMENT_REC       IN        ASO_QUOTE_PUB.SHIPMENT_REC_TYPE
                                            := ASO_QUOTE_PUB.G_MISS_SHIPMENT_REC,
    P_HEADER_PAYMENT_REC        IN        ASO_QUOTE_PUB.PAYMENT_REC_TYPE
                                            := ASO_QUOTE_PUB.G_MISS_PAYMENT_REC,
    P_HEADER_TAX_DETAIL_REC     IN        ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE
                                            := ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_REC,
    P_QUOTE_LINE_REC            IN        ASO_QUOTE_PUB.QTE_LINE_REC_TYPE
                                            := ASO_QUOTE_PUB.G_MISS_QTE_LINE_REC,
    P_LINE_MISC_REC             IN        LINE_MISC_REC_TYPE
                                            := G_MISS_LINE_MISC_REC,
    P_LINE_SHIPMENT_REC         IN        ASO_QUOTE_PUB.SHIPMENT_REC_TYPE
                                            := ASO_QUOTE_PUB.G_MISS_SHIPMENT_REC,
    P_LINE_PAYMENT_REC          IN        ASO_QUOTE_PUB.PAYMENT_REC_TYPE
                                            := ASO_QUOTE_PUB.G_MISS_PAYMENT_REC,
    P_LINE_TAX_DETAIL_REC       IN        ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE
                                            := ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_REC,
    X_QUOTE_HEADER_REC          OUT NOCOPY /* file.sql.39 change */       ASO_QUOTE_PUB.QTE_HEADER_REC_TYPE,
    X_HEADER_MISC_REC           OUT NOCOPY /* file.sql.39 change */       HEADER_MISC_REC_TYPE,
    X_HEADER_SHIPMENT_REC       OUT NOCOPY /* file.sql.39 change */       ASO_QUOTE_PUB.SHIPMENT_REC_TYPE,
    X_HEADER_PAYMENT_REC        OUT NOCOPY /* file.sql.39 change */       ASO_QUOTE_PUB.PAYMENT_REC_TYPE,
    X_HEADER_TAX_DETAIL_REC     OUT NOCOPY /* file.sql.39 change */       ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE,
    X_QUOTE_LINE_REC            OUT NOCOPY /* file.sql.39 change */       ASO_QUOTE_PUB.QTE_LINE_REC_TYPE,
    X_LINE_MISC_REC             OUT NOCOPY /* file.sql.39 change */       LINE_MISC_REC_TYPE,
    X_LINE_SHIPMENT_REC         OUT NOCOPY /* file.sql.39 change */       ASO_QUOTE_PUB.SHIPMENT_REC_TYPE,
    X_LINE_PAYMENT_REC          OUT NOCOPY /* file.sql.39 change */       ASO_QUOTE_PUB.PAYMENT_REC_TYPE,
    X_LINE_TAX_DETAIL_REC       OUT NOCOPY /* file.sql.39 change */       ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE,
    X_CHANGED_FLAG              OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    X_RETURN_STATUS             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    X_MSG_COUNT                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    X_MSG_DATA                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  );


END ASO_DEFAULTING_INT;

 

/
