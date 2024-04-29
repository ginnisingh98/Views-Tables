--------------------------------------------------------
--  DDL for Package OE_ORDER_PURGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_PURGE_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVPURS.pls 120.5.12000000.1 2007/01/16 22:12:08 appldev ship $ */

TYPE	SELECTED_IDS_TBL IS TABLE OF NUMBER
INDEX BY BINARY_INTEGER;

--	Start of Comments
--	API name    :	Select_Purge_Orders
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This procedure is called from concurrent request Create
--					Purge set(Submitted from Order Organizer). It will make
--					a table of records for ids from CLOB structure.
--	Parameters	:	p_dummy1		IN VARCHAR2
--					p_dummy2		IN VARCHAR2
--					p_purge_set_id	IN NUMBER
--						Purge set id
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--
PROCEDURE Select_Purge_Orders
(
p_dummy1 OUT NOCOPY VARCHAR2,

p_dummy2 OUT NOCOPY VARCHAR2,

	p_purge_set_id    IN NUMBER
);

--	Start of Comments
--	API name    :	Selected_Ids_Purge
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This procedure is called from procedure select_purge_orders
--					It will create records in OE_PURGE_ORDERS for passed
--					selected ids.
--	Parameters	:	p_purge_set_id	IN NUMBER
--						Purge set id
--					p_selected_ids_tbl	IN SELECTED_IDS_TBL
--						Table with header ids of orders to be purged.
--					p_count_selected	IN NUMBER
--						Number of ids selected.
--					p_orders_per_commit	IN NUMBER
--						Number of orders per commit.
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--
PROCEDURE select_ids_purge
(
	p_purge_set_id   	IN NUMBER
,	p_selected_ids_tbl  IN SELECTED_IDS_TBL
,	p_count_selected  	IN NUMBER
,	p_orders_per_commit	IN NUMBER
);

--	Start of Comments
--	API name    :	Select_where_cond_purge
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This procedure is called from concurrent program Order
--					Purge Selection. It will select the orders based upon
--					specified where criteria and create records in
--					oe_purge_orders
--	Parameters	:	ERRBUF	OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--					RETCODE	OUT NOCOPY /* file.sql.39 change */	VARCHAR2
--					p_purge_set_name	IN	VARCHAR2
--						purge set name.
--					p_purge_set_description	IN	VARCHAR2
--						purge set description
--					p_order_number_low	IN	NUMBER
--						order number range low.
--					p_order_number_high	IN	NUMBER
--						order number range high.
--					p_order_type_id	IN	NUMBER
--						order type id.
--					p_order_category	IN	VARCHAR2
--						order category code.
--					p_customer_id	IN	NUMBER
--						customer id.
--					p_ordered_date_low	IN	DATE
--						ordered date low.
--					p_ordered_date_high	IN	DATE
--						ordered date high.
--					p_creation_date_low	IN	DATE
--						creation date low.
--					p_creation_date_high	IN	DATE
--						creation date high.
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--
PROCEDURE select_where_cond_purge
(       ERRBUF OUT NOCOPY VARCHAR2
,       RETCODE OUT NOCOPY VARCHAR2
,       p_organization_id       IN      NUMBER
,	p_purge_set_name	IN	VARCHAR2
,	p_purge_set_description	IN	VARCHAR2
,	p_order_number_low	IN	NUMBER
,	p_order_number_high	IN	NUMBER
,	p_order_type_id		IN	NUMBER
,	p_order_category	IN	VARCHAR2
,	p_customer_id		IN	NUMBER
,	p_ordered_date_low	IN	VARCHAR2
,	p_ordered_date_high	IN	VARCHAR2
,	p_creation_date_low	IN	VARCHAR2
,	p_creation_date_high	IN	VARCHAR2
,	p_dummy			IN	VARCHAR2   	DEFAULT NULL
,       p_include_contractual_orders  IN       VARCHAR2 DEFAULT NULL
);

--      Start of Comments
--      API name    :   Select_Where_Cond_Purge_Quote
--      Type        :   Private
--      Pre-reqs    :   None.
--      Function    :   This procedure is called from concurrent program Quote
--                      Purge Selection. It will select the quote based upon
--                      specified where criteria and create records in
--                      oe_purge_orders
--      Parameters  :   ERRBUF  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--                      RETCODE OUT NOCOPY /* file.sql.39 change */     VARCHAR2
--                      p_purge_set_name        IN      VARCHAR2
--                              purge set name.
--                      p_purge_set_description IN      VARCHAR2
--                              purge set description
--                      p_quote_number_low      IN      NUMBER
--                              quote number range low.
--                      p_quote_number_high     IN      NUMBER
--                              quote number range high.
--                      p_order_type_id         IN      NUMBER
--                              order type id.
--                      p_customer_id           IN      NUMBER
--                              customer id.
--                      p_quote_date_low        IN      DATE
--                              quote date low.
--                      p_quote_date_high       IN      DATE
--                               quote date high.
--                      p_creation_date_low     IN      DATE
--                              creation date low.
--                      p_creation_date_high    IN      DATE
--                               creation date high.
--                      p_offer_exp_date_low    IN      DATE
--                               offer expiration date low.
--                      p_offer_exp_date_high   IN      DATE
--                              offer expiration date high.
--                      p_purge_exp_quotes      IN      VARCHAR2
--                              purge expired quotes flag.
--                      p_purge_lost_quotes     IN      VARCHAR2
--                              purge lost quotes flag.
--
--      Version     :   Current version = 1.0
--                  Initial version = 1.0
--      End of Comments
--

Procedure Select_Where_Cond_Purge_Quote
(
        ERRBUF                          OUT NOCOPY /* file.sql.39 change */     VARCHAR2
,       RETCODE                         OUT NOCOPY /* file.sql.39 change */     VARCHAR2
,       p_organization_id               IN      NUMBER
,       p_purge_set_name                IN      VARCHAR2
,       p_purge_set_description         IN      VARCHAR2
,       p_quote_number_low              IN      NUMBER
,       p_quote_number_high             IN      NUMBER
,       p_order_type_id                 IN      NUMBER
,       p_customer_id                   IN      NUMBER
,       p_quote_date_low                IN      VARCHAR2
,       p_quote_date_high               IN      VARCHAR2
,       p_creation_date_low             IN      VARCHAR2
,       p_creation_date_high            IN      VARCHAR2
,       p_offer_exp_date_low            IN      VARCHAR2
,       p_offer_exp_date_high           IN      VARCHAR2
,       p_purge_exp_quotes              IN      VARCHAR2
,       p_purge_lost_quotes             IN      VARCHAR2
);


--	Start of Comments
--	API name    :	Insert_Purge_Set
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This procedure inserts a record in oe_purge_sets table.
--					It converts the passed table of ids t a CLOB before
--					inserting it into the table.
--	Parameters	:	p_purge_set_name	IN VARCHAR2
--						Purge set name
--					p_purge_set_description	IN VARCHAR2
--						purge set name
--					p_purge_set_request_id	IN NUMBER
--						Request id of concurrent request for creation of purge
--						set
--					p_purge_set_submit_datetime	IN DATE
--						DATETIME of create purge set submission.
--					p_selected_ids	IN	SELECTED_IDS_TBL
--						Table of header ids. It will be passed from multi select
--					p_count_selected	IN	NUMBER
--						Number of orders selected
--					p_where_condition	IN	VARCHAR2
--						Where condition for the selection. It will be passed
--						when order purge selection request is submitted.
--					p_created_by		IN	NUMBER
--						Created by.
--					p_last_updated_by	IN	NUMBER
--						Last updated by.
--					x_purge_set_id		OUT NOCOPY /* file.sql.39 change */	NUMBER
--						generated purge set id.
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--
PROCEDURE Insert_Purge_Set
(
	p_purge_set_name 			IN VARCHAR2
,	p_purge_set_description 	IN VARCHAR2
,	p_purge_set_request_Id 		IN NUMBER
,	p_purge_set_submit_datetime IN DATE
,	p_selected_ids  			IN SELECTED_IDS_TBL
,	p_count_selected 			IN NUMBER
,	p_where_condition 			IN VARCHAR2
,	p_created_by      			IN NUMBER
,	p_last_updated_by 			IN NUMBER
, x_purge_set_id OUT NOCOPY NUMBER

);


--      Start of Comments
--      API name        :       Check_And_Get_Detail
--      Type            :       Private
--      Pre-reqs        :       None.
--      Function        :       This procedure calls diffrent procedures to verify whether
--                                      order can be purged or not. Then it inserts a record in
--                                      table oe_purge_orders with error messages. It will check
--                                      if an order is open, open invoice exists, open RMA exists.
--      Parameters      :       p_purge_set_id  IN NUMBER
--                                              Purge set id
--                                      p_header_id     IN NUMBER
--                                              header id.
--                                      p_order_number  IN NUMBER
--                                              Order number
--                                      p_order_type_name       IN VARCHAR2
--                                              order type
--                                      p_customer_id   IN NUMBER
--                                              customer id.
--                                      p_price_list_id IN NUMBER
--                                              price list id
--                                      p_quote_number  IN NUMBER
--                                              quote number
--                                      p_flow_status_code IN varchar2(30)
--                                              flow status code
--                                      p_upgraded_flag IN varchar2(1)
--                                              upgraded flag
--                                      p_expiration_date IN DATE
--                                              expiration date
--      Version     	:   	Current version = 1.1
--                  	    	Initial version = 1.0
--      End of Comments
--

Procedure check_and_get_detail
(
        p_purge_set_id          IN NUMBER
,       p_header_id             IN NUMBER
,       p_order_number          IN NUMBER
,       p_order_type_name       IN VARCHAR2
,       p_customer_number       IN NUMBER
,       p_price_list_id         IN NUMBER
,       p_quote_number          IN NUMBER       DEFAULT NULL
,       p_flow_status_code      IN VARCHAR2     DEFAULT NULL
,       p_upgraded_flag         IN VARCHAR2     DEFAULT NULL
,       p_expiration_date       IN DATE         DEFAULT NULL
);


--	Start of Comments
--	API name    :	Delete_Purge_Set
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This procedure is called from the form to delete a purge
--					set. It will check if the purge set is purged or if there
--					are any orders in the set have been purged, if yes it will
--					return false, else the purge set will be deleted and true
--					will be return.
--	Parameters	:	p_purge_set_id	IN NUMBER
--						Purge set id
--					x_return_status	IN VARCHAR2
--						Return status, will be FND_API.G_FALSE if the purge set
--						can not be deleted, eill be FND_API.G_TRUE if the purge
--						set is deleted.
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--
Procedure delete_purge_set
(
	p_purge_set_id 	IN 	NUMBER
, x_return_status OUT NOCOPY VARCHAR2);

--      Start of Comments
--      API name        :       Check_Open_Quotes
--      Type            :       Private
--      Pre-reqs        :       None.
--      Function        :       This function checks if the quote is open. It will return
--                              FND_API.G_FALSE if the quote is open, else will return
--                              FND_API.G_TRUE.
--      Parameters      :       p_header_id  IN NUMBER
--                              Header id
--      Version         :       Current version = 1.0
--                              Initial version = 1.0
--      End of Comments
--

FUNCTION Check_Open_Quotes
(
        p_header_id            IN NUMBER
)
RETURN VARCHAR2;


--	Start of Comments
--	API name    :	Check_Open_Orders
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This function checks if the order is open. It will return
--					FND_API.G_FALSE if the order is open, else will return
--					FND_API.G_TRUE.
--	Parameters	:	p_order_number	IN NUMBER
--						Order Number
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--

FUNCTION Check_Open_Orders
(
	--for Bug # 4516769
	p_header_id          IN NUMBER
)
RETURN VARCHAR2;

--	Start of Comments
--	API name    :	Check_Open_Invoiced_Orders
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This function checks if there are any open invoices against
--					a order . It will return FND_API.G_FALSE if an open invoive
--					exists for the order, else will return FND_API.G_TRUE.
--	Parameters	:	p_order_number	IN VARCHAR2
--						Order Number
--					p_order_type_name	IN	VARCHAR2
--						Order Type
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--

FUNCTION check_open_invoiced_orders
(
	p_order_number            IN VARCHAR2
,	p_order_type_name         IN VARCHAR2 )
RETURN VARCHAR2;

--	Start of Comments
--	API name    :	Check_Open_Returns
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This function checks if there are any open returns for
--					a order . It will return FND_API.G_FALSE if an open returns
--					exists for the order, else will return FND_API.G_TRUE.
--	Parameters	:	p_order_number	IN NUMBER
--						Order Number
--					p_order_type_name	IN	VARCHAR2
--						Order Type
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--
FUNCTION check_open_returns
(
	p_order_number           IN NUMBER
,	p_order_type_name        IN VARCHAR2 )
RETURN VARCHAR2;


--	Start of Comments
--	API name    :	Check_Open_RMA_Receipts
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This function checks if there are any open RMA receipts for
--				all Return Lines in the order(Return/Mixed). It will return -- 				FND_API.G_FALSE if open receipts exists,
--				else will return FND_API.G_TRUE.
--	Version     :	Current version = 1.0
--  	            	Initial version = 1.0
--	End of Comments
--
PROCEDURE Check_Open_RMA_Receipts
( p_header_id        IN    NUMBER,
x_return_status OUT NOCOPY VARCHAR2,

x_message OUT NOCOPY VARCHAR2);




--	Start of Comments
--	API name    :	Submit_Purge
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This pricedure will be called from concurrent request when
--					a purge set is submitted for purge. It will call various
--					APIs to delete the records and will update the purged flag
--					on OE_PURGE_ORDERS, and purge set purged flag on
--					OE_PURGE_SETS table.
--	Parameters	:	p_dummy1	IN VARCHAR2
--					p_dummy2	IN VARCHAR2
--					p_purge_set_id	IN	NUMBER
--						purge set id
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--

--
--  As per the MOAC changes the 'Order Purge Job' would be MULTI Organizational concurrent Request.
--  But the organization_id is not passed as this would be always passed as NULL.
--
Procedure  submit_purge
(       p_dummy1 		IN VARCHAR2
,	p_dummy2 		IN VARCHAR2
, 	p_purge_set_id	IN NUMBER
);

--	Start of Comments
--	API name    :	OE_Purge_Headers
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This pricedure will call APIs to delete header related
--					tables and will delete the record from OE_ORDER_HEADERS
--	Parameters	:	p_purge_set_id	IN NUMBER
--					p_header_id	IN NUMBER
--					x_return_status	OUT NOCOPY /* file.sql.39 change */	VARCHAR2
--						return status, will be FND_API.G_RET_STS_SUCCESS if the
--						delete is successful else will be
--						FND_API.G_RET_STS_ERROR
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--

PROCEDURE oe_purge_headers
(
	p_purge_set_id 	IN	NUMBER
,	p_header_id  		IN	NUMBER
, x_return_status OUT NOCOPY VARCHAR2

);

--	Start of Comments
--	API name    :	OE_Purge_Lines
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This pricedure will call APIs to delete line related
--					tables and will delete the record from OE_ORDER_LINES
--	Parameters	:	p_purge_set_id	IN NUMBER
--					p_header_id	IN NUMBER
--					x_return_status	OUT NOCOPY /* file.sql.39 change */	VARCHAR2
--						return status, will be FND_API.G_RET_STS_SUCCESS if the
--						delete is successful else will be
--						FND_API.G_RET_STS_ERROR
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--
PROCEDURE oe_purge_lines
(
	p_purge_set_id 	IN	NUMBER
,	p_header_id		IN	NUMBER
, x_return_status OUT NOCOPY VARCHAR2

);

--	Start of Comments
--	API name    :	OE_Purge_Header_Adj
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This function will delete the records from price adjustment
--					tables for header id.
--					will return FND_API.G_RET_STS_SUCCESS if the records are
--					deleted, else will return FND_API.G_RET_STS_UNEXP_ERROR
--	Parameters	:	p_purge_set_id	IN NUMBER
--					p_header_id	IN NUMBER
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--
FUNCTION OE_Purge_Header_Adj
(
	p_purge_set_id 	IN 	NUMBER
,	p_header_id		IN	NUMBER)

RETURN VARCHAR2 ;

--	Start of Comments
--	API name    :	OE_Purge_Line_Adj
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This function will delete the records from price adjustment
--					tables for line id.
--					will return FND_API.G_RET_STS_SUCCESS if the records are
--					deleted, else will return FND_API.G_RET_STS_UNEXP_ERROR
--	Parameters	:	p_purge_set_id	IN NUMBER
--					p_line_id	IN NUMBER
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--
FUNCTION OE_Purge_Line_Adj
(
	p_purge_set_id 	IN 	NUMBER
,	p_header_id		IN	NUMBER
,	p_line_id			IN	NUMBER)
RETURN VARCHAR2;

--	Start of Comments
--	API name    :	OE_Purge_Price_Attribs
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This function will delete the records from
--					OE_ORDER_PRICE_ATTRIBS table for header id.
--					will return FND_API.G_RET_STS_SUCCESS if the records are
--					deleted, else will return FND_API.G_RET_STS_UNEXP_ERROR
--	Parameters	:	p_purge_set_id	IN NUMBER
--					p_header_id	IN NUMBER
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--
FUNCTION OE_Purge_Price_Attribs
(
	p_purge_set_id 	IN 	NUMBER
,	p_header_id		IN	NUMBER)
RETURN VARCHAR2;

--	Start of Comments
--	API name    :	OE_Purge_Order_Sales_Credits
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This function will delete the records from sales credits
--					tables for header id.
--					will return FND_API.G_RET_STS_SUCCESS if the records are
--					deleted, else will return FND_API.G_RET_STS_UNEXP_ERROR
--	Parameters	:	p_purge_set_id	IN NUMBER
--					p_header_id	IN NUMBER
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--

FUNCTION OE_Purge_Order_Sales_Credits
(
	p_purge_set_id 	IN 	NUMBER
,	p_header_id		IN	NUMBER)
RETURN VARCHAR2;

--	Start of Comments
--	API name    :	OE_Purge_Line_Sales_Credits
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This function will delete the records from sales credits
--					tables for line id.
--					will return FND_API.G_RET_STS_SUCCESS if the records are
--					deleted, else will return FND_API.G_RET_STS_UNEXP_ERROR
--	Parameters	:	p_purge_set_id	IN NUMBER
--					p_line_id	IN NUMBER
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--
FUNCTION OE_Purge_Line_Sales_Credits
(
	p_purge_set_id 	IN 	NUMBER
,	p_header_id		IN	NUMBER
,	p_line_id			IN	NUMBER)
RETURN VARCHAR2;

--	Start of Comments
--	API name    :	OE_Purge_Order_Sets
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This function will delete the records from oe_sets
--					tables for header id.
--					will return FND_API.G_RET_STS_SUCCESS if the records are
--					deleted, else will return FND_API.G_RET_STS_UNEXP_ERROR
--	Parameters	:	p_purge_set_id	IN NUMBER
--					p_header_id	IN NUMBER
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--

FUNCTION OE_Purge_Order_Sets
(
	p_purge_set_id 	IN 	NUMBER
,	p_header_id		IN	NUMBER)
RETURN VARCHAR2;

--	Start of Comments
--	API name    :	OE_Purge_Line_Sets
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This function will delete the records from OE_LINE_SETS
--					tables for line id.
--					will return FND_API.G_RET_STS_SUCCESS if the records are
--					deleted, else will return FND_API.G_RET_STS_UNEXP_ERROR
--	Parameters	:	p_purge_set_id	IN NUMBER
--					p_line_id	IN NUMBER
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--

FUNCTION OE_Purge_Line_Sets
(
	p_purge_set_id 	IN 	NUMBER
,	p_header_id		IN	NUMBER
,	p_line_id			IN	NUMBER)
RETURN VARCHAR2;

--	Start of Comments
--	API name    :	OE_Purge_Order_Holds
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This function will delete the records from Holds
--					tables for header id.
--					will return FND_API.G_RET_STS_SUCCESS if the records are
--					deleted, else will return FND_API.G_RET_STS_UNEXP_ERROR
--	Parameters	:	p_purge_set_id	IN NUMBER
--					p_header_id	IN NUMBER
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--

FUNCTION OE_Purge_Order_Holds
(
	p_purge_set_id 	IN 	NUMBER
,	p_header_id		IN	NUMBER)
RETURN VARCHAR2;


--	Start of Comments
--	API name    :	OE_Purge_RMA_Line_Receipts
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This function will delete RMA line receipts in PO Tables,
--				will return FND_API.G_RET_STS_SUCCESS if the records are
--				deleted, else will return FND_API.G_RET_STS_UNEXP_ERROR
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--

FUNCTION OE_Purge_RMA_Line_Receipts
(    p_purge_set_id      IN   NUMBER
,    p_header_id         IN   NUMBER
,    p_line_id           IN   NUMBER)
RETURN VARCHAR2;


--   Start of Comments
--   API name    :  OE_Purge_RMA_Line_Lot_Srl
--   Type        :  Private
--   Pre-reqs  :    None.
--   Function  :    This function will delete RMA line lot and serial number
--                  records in OM Tables,
--                  will return FND_API.G_RET_STS_SUCCESS if the records are
--                  deleted, else will return FND_API.G_RET_STS_UNEXP_ERROR
--   Version     :  Current version = 1.0
--               Initial version = 1.0
--   End of Comments
--

FUNCTION OE_Purge_RMA_Line_Lot_Srl
(    p_purge_set_id      IN   NUMBER
,    p_header_id         IN   NUMBER
,    p_line_id           IN   NUMBER)
RETURN VARCHAR2;


--	Start of Comments
--	API name    :	record_errors
--	Type        :	Private
--	Pre-reqs	:	None.
--	Function	:	This procedure will be called to record the errors
--					encountered during delete.
--	Parameters	:	p_return_status	IN VARCHAR2
--					p_purge_set_id	IN NUMBER
--					p_header_id		IN	NUMBER
--					p_error_message	IN	VARCHAR2
--	Version     :	Current version = 1.0
--  	            Initial version = 1.0
--	End of Comments
--

PROCEDURE record_errors
(
	p_return_status	IN VARCHAR2
,	p_purge_set_id		IN NUMBER
,	p_header_id		IN NUMBER
,	p_error_message	IN VARCHAR2
) ;

--      Purge Changes for 11i.10

--      Function    : Check_Open_PO_Reqs_Dropship
--      Description : This function checks if there are any open
--                    PO/Requsitions associated with drop ship order lines.
--                    It will call an API provided by Purchasing. If this API
--                    returns that the PO/Requsition associated with any of
--                    the drop ship order line is open, the order will be marked
--                    for not to be purged, with message OE_PURGE_OPEN_PO_REQ.
--

Function Check_Open_PO_Reqs_Dropship
( p_header_id           IN           NUMBER
) RETURN VARCHAR2;

-- added for multiple payments
FUNCTION OE_Purge_Header_Payments
( p_purge_set_id  	IN      NUMBER
, p_header_id           IN      NUMBER)
RETURN VARCHAR2;

-- added for multiple payments
FUNCTION OE_Purge_Line_Payments
( p_purge_set_id  	IN      NUMBER
, p_header_id           IN      NUMBER
, p_line_id		IN      NUMBER)
RETURN VARCHAR2;


-- This procedure is called from the OEXOEPUR.pld .
-- This checks if the Order is eligible for Purging.

PROCEDURE check_is_purgable(  p_purge_set_id          IN NUMBER
                            , p_header_id             IN NUMBER
                            , p_order_number          IN NUMBER
                            , p_order_type_name       IN VARCHAR2
			    , p_quote_number          IN NUMBER
			    , p_is_purgable           OUT NOCOPY VARCHAR2
			    , p_error_message         OUT NOCOPY VARCHAR2 );


END oe_order_purge_pvt;  -- specification

 

/
