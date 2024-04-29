--------------------------------------------------------
--  DDL for Package OE_BULK_TAX_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BULK_TAX_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEBUTAXS.pls 120.0.12010000.5 2009/01/09 04:32:28 smanian noship $ */
/*#
* This API contains the utilities used in tax calculation.
* @rep:scope            private
* @rep:product          ONT
* @rep:lifecycle        active
* @rep:displayname      Order Management Tax Utility API
* @rep:category         BUSINESS_ENTITY ONT_SALES_ORDER
*/

G_CURRENCY_CODE   VARCHAR2(15);
G_MINIMUM_ACCOUNTABLE_UNIT NUMBER;
G_PRECISION       NUMBER(1);

TYPE TAX_NUMBER_TBL_TYPE IS TABLE OF NUMBER
INDEX BY BINARY_INTEGER;

G_TAX_LINE_ID     TAX_NUMBER_TBL_TYPE;
G_TAX_LINE_VALUE  TAX_NUMBER_TBL_TYPE;
G_MISS_TAX_NUMBER_TBL TAX_NUMBER_TBL_TYPE;

TYPE Line_Adj_Rec_Type IS RECORD
(PRICE_ADJUSTMENT_ID  OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,CREATED_BY           OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,CREATION_DATE        OE_WSH_BULK_GRP.T_DATE := OE_WSH_BULK_GRP.T_DATE()
,LAST_UPDATE_DATE     OE_WSH_BULK_GRP.T_DATE := OE_WSH_BULK_GRP.T_DATE()
,LAST_UPDATED_BY      OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,HEADER_ID            OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,LINE_ID              OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,TAX_CODE             OE_WSH_BULK_GRP.T_V50 := OE_WSH_BULK_GRP.T_V50()
,OPERAND              OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,ADJUSTED_AMOUNT      OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,TAX_RATE_ID          OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()--bug7685103
,AUTOMATIC_FLAG       OE_WSH_BULK_GRP.T_V1 := OE_WSH_BULK_GRP.T_V1()
,LIST_LINE_TYPE_CODE  OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
,ARITHMETIC_OPERATOR  OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
);

G_LINE_ADJ_REC        Line_Adj_Rec_Type;

/*#
* This procedure populates the default tax code on order lines when no tax code has been specified.
* @rep:scope	 	private
* @rep:lifecycle	active
* @rep:category	        BUSINESS_ENTITY	ONT_SALES_ORDER
* @rep:displayname	Get Default Tax Code
*/
PROCEDURE Get_Default_Tax_Code;

/*#
* This procedure calculates the tax amount for order lines.
* @param                p_post_insert Input parameter that specifies whether the tax amount will be updated before or after the order lines have been inserted.
* @rep:scope	 	private
* @rep:lifecycle	active
* @rep:category	        BUSINESS_ENTITY	ONT_SALES_ORDER
* @rep:displayname	Calculate Tax
*/
PROCEDURE Calculate_Tax
          (p_post_insert            IN    BOOLEAN
          );

/*#
* This procedure extends the size of the global price adjustment record.
* @param                p_count Input parameter that specifies how far to extend the record.
* @param                p_adj_rec Input parameter containing the global adjustment record to be extended
* @rep:scope	 	private
* @rep:lifecycle	active
* @rep:category	        BUSINESS_ENTITY	ONT_SALES_ORDER
* @rep:displayname	Extend Adjustment Record
*/
PROCEDURE Extend_Adj_Rec
        (p_count               IN NUMBER
        ,p_adj_rec            IN OUT NOCOPY LINE_ADJ_REC_TYPE
        );

/*#
* This procedure inserts the price adjustment records that are associated with the tax on each line.
* @param                p_post_insert Input parameter that specifies whether the tax amount will be updated calculated before or after the order lines have been inserted.
* @rep:scope	 	private
* @rep:lifecycle	active
* @rep:category	        BUSINESS_ENTITY	ONT_SALES_ORDER
* @rep:displayname	Insert Tax Records
*/
PROCEDURE Insert_Tax_Records
        (p_post_insert            IN    BOOLEAN
        );

/*#
* This procedure marks header and line records for error.
* @param                p_header_index Input parameter containing the index value for the header to be marked for error
* @rep:scope	 	private
* @rep:lifecycle	active
* @rep:category	        BUSINESS_ENTITY	ONT_SALES_ORDER
* @rep:displayname	Handle Error
*/
PROCEDURE Handle_Error
        (p_header_index               IN NUMBER
---bug 7653825        ,p_line_index                 IN NUMBER
        );

/*#
* This procedure handles tax code retrieval and validation errors
* @param                p_index Input parameter containing the index value for the line
* @param                p_header_index Input parameter containing the index value for the header
* @rep:scope	 	private
* @rep:lifecycle	active
* @rep:category	        BUSINESS_ENTITY	ONT_SALES_ORDER
* @rep:displayname	Handle Tax Code Error
*/
PROCEDURE Handle_Tax_Code_Error(p_index IN NUMBER,
                                p_header_index IN NUMBER,
				x_index_inc OUT NOCOPY NUMBER);

END OE_BULK_TAX_UTIL;

/
