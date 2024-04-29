--------------------------------------------------------
--  DDL for Package ASO_DEFAULTING_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_DEFAULTING_UTIL" AUTHID CURRENT_USER AS
/* $Header: asovdhus.pls 120.1 2005/06/29 12:41:31 appldev noship $ */
-- Package name     : ASO_DEFAULTING_UTIL
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME  CONSTANT    VARCHAR2(50):=  'ASO_DEFAULTING_UTIL';


PROCEDURE  Api_Rec_To_Row_Type
          (
           P_Entity_Code                 IN        VARCHAR2,
           P_Quote_Header_Rec            IN        ASO_Quote_Pub.Qte_Header_Rec_Type
                                                   := ASO_Quote_Pub.G_Miss_Qte_Header_Rec,
           P_Header_Shipment_Rec         IN        ASO_Quote_Pub.Shipment_Rec_Type
                                                   := ASO_Quote_Pub.G_Miss_Shipment_Rec,
           P_Header_Payment_Rec          IN        ASO_Quote_Pub.Payment_Rec_Type
                                                   := ASO_Quote_Pub.G_Miss_Payment_Rec,
           P_Quote_Line_Rec              IN        ASO_Quote_Pub.Qte_Line_Rec_Type
                                                   := ASO_Quote_Pub.G_Miss_Qte_Line_Rec,
           P_Line_Shipment_Rec           IN        ASO_Quote_Pub.Shipment_Rec_Type
                                                   := ASO_Quote_Pub.G_Miss_Shipment_Rec,
           P_Line_Payment_Rec            IN        ASO_Quote_Pub.Payment_Rec_Type
                                                   := ASO_Quote_Pub.G_Miss_Payment_Rec,
           P_Control_Rec                 IN        ASO_Defaulting_Int.Control_Rec_Type
                                                   := ASO_Defaulting_Int.G_Miss_Control_Rec,
           P_OPP_QTE_HEADER_REC          IN        ASO_OPP_QTE_PUB.OPP_QTE_IN_REC_TYPE
                                                   := ASO_OPP_QTE_PUB.G_MISS_OPP_QTE_IN_REC,
           P_HEADER_MISC_REC             IN        ASO_DEFAULTING_INT.HEADER_MISC_REC_TYPE
                                                   := ASO_DEFAULTING_INT.G_MISS_HEADER_MISC_REC,
           P_HEADER_TAX_DETAIL_REC       IN        ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE
                                                   := ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_REC,
           P_LINE_MISC_REC               IN        ASO_DEFAULTING_INT.LINE_MISC_REC_TYPE
                                                   := ASO_DEFAULTING_INT.G_MISS_LINE_MISC_REC,
           P_LINE_TAX_DETAIL_REC         IN        ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE
                                                   := ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_REC,
           X_Qte_Header_Row_Rec          IN OUT NOCOPY /* file.sql.39 change */    ASO_AK_Quote_Header_V%Rowtype,
           X_Qte_Opportunity_Row_Rec     IN OUT NOCOPY /* file.sql.39 change */    ASO_AK_Quote_Oppty_V%Rowtype,
           X_Qte_Line_Row_Rec            IN OUT NOCOPY /* file.sql.39 change */    ASO_AK_Quote_Line_V%Rowtype);



PROCEDURE  ROW_TO_API_REC_TYPE
          (
           P_Entity_Code                      IN     VARCHAR2,
           P_Qte_Header_Row_Rec               IN     ASO_AK_Quote_Header_V%Rowtype,
           P_Qte_Opportunity_Row_Rec          IN     ASO_AK_Quote_Oppty_V%Rowtype,
           P_Qte_Line_Row_Rec                 IN     ASO_AK_Quote_Line_V%Rowtype,
           X_Quote_Header_Rec            IN OUT NOCOPY /* file.sql.39 change */      ASO_Quote_Pub.Qte_Header_Rec_Type,
           X_Header_Shipment_Rec         IN OUT NOCOPY /* file.sql.39 change */      ASO_Quote_Pub.Shipment_Rec_Type,
           X_Header_Payment_Rec          IN OUT NOCOPY /* file.sql.39 change */      ASO_Quote_Pub.Payment_Rec_Type,
           X_Quote_Line_Rec              IN OUT NOCOPY /* file.sql.39 change */      ASO_Quote_Pub.Qte_Line_Rec_Type,
           X_Line_Shipment_Rec           IN OUT NOCOPY /* file.sql.39 change */      ASO_Quote_Pub.Shipment_Rec_Type,
           X_Line_Payment_Rec            IN OUT NOCOPY /* file.sql.39 change */      ASO_Quote_Pub.Payment_Rec_Type,
           X_HEADER_MISC_REC             IN OUT NOCOPY /* file.sql.39 change */      ASO_DEFAULTING_INT.HEADER_MISC_REC_TYPE,
           X_HEADER_TAX_DETAIL_REC       IN OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE,
           X_LINE_MISC_REC               IN OUT NOCOPY /* file.sql.39 change */      ASO_DEFAULTING_INT.LINE_MISC_REC_TYPE,
           X_LINE_TAX_DETAIL_REC         IN OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE);


PROCEDURE  Initialize_Row_Type
         (
           P_Entity_Code                      IN     VARCHAR2,
           P_Qte_Header_Row_Rec               IN OUT NOCOPY /* file.sql.39 change */ ASO_AK_Quote_Header_V%Rowtype,
           P_Qte_Opportunity_Row_Rec          IN OUT NOCOPY /* file.sql.39 change */ ASO_AK_Quote_Oppty_V%Rowtype,
           P_Qte_Line_Row_Rec                 IN OUT NOCOPY /* file.sql.39 change */ ASO_AK_Quote_Line_V%Rowtype);



END ASO_DEFAULTING_UTIL;

 

/
