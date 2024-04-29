--------------------------------------------------------
--  DDL for Package OE_RETROBILL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_RETROBILL_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVRTOS.pls 120.2.12000000.1 2007/01/16 22:12:27 appldev ship $ */

Type retrobill_line_rec is Record
(original_line_id             NUMBER,
 original_header_id           NUMBER,
 retrobill_line_id            NUMBER,
 retrobill_header_id          NUMBER,
 retrobill_qty	              NUMBER,
 operation                    VARCHAR2(15)
);

Procedure Get_Retrobilled_Sum(p_header_id     IN  NUMBER,
                              p_line_id       IN  NUMBER,
                              p_curr_retro_id IN  NUMBER DEFAULT -999,
                              x_usp_sum       OUT NOCOPY NUMBER,
                              x_ulp_sum       OUT NOCOPY NUMBER);

Procedure Get_Return_Price(p_header_id IN NUMBER,
                           p_line_id   IN NUMBER,
			   p_ordered_qty IN NUMBER,--bug3540728
			   p_pricing_qty IN NUMBER, --bug3540728
                           p_usp       IN NUMBER,
                           p_ulp       IN NUMBER,
                           x_usp       OUT NOCOPY NUMBER,
                           x_ulp       OUT NOCOPY NUMBER,
			   x_ulp_ppqty OUT NOCOPY NUMBER,--bug3540728
			   x_usp_ppqty OUT NOCOPY NUMBER); --bug3540728

Type retrobill_tbl_type is Table of retrobill_line_rec index by Binary_Integer;

PROCEDURE Process_Retrobill_Request
(p_retrobill_request_rec         IN  OE_RETROBILL_REQUESTS%ROWTYPE
,p_retrobill_tbl                 IN  RETROBILL_TBL_TYPE
,x_created_retrobill_request_id  OUT NOCOPY NUMBER
,x_msg_count	                 OUT NOCOPY NUMBER
,x_msg_data	                 OUT NOCOPY VARCHAR2
,x_return_status                 OUT NOCOPY VARCHAR2
,x_retrun_status_text	         OUT NOCOPY VARCHAR2
 --bug5003256
,x_error_count                   OUT NOCOPY NUMBER);

G_RETROBILL_ORDER_SOURCE_ID NUMBER:=27;

PROCEDURE Update_Retrobill_Lines(p_operation IN VARCHAR2);

PROCEDURE Get_Most_Recent_Retro_Adj
(p_key_header_id IN NUMBER,
 p_key_line_id   IN NUMBER,
 p_adjustment_level IN VARCHAR2,
 x_retro_exists OUT NOCOPY BOOLEAN, --bug3738043
 x_line_adj_tbl OUT NOCOPY OE_ORDER_PUB.LINE_ADJ_TBL_TYPE);

PROCEDURE  Process_Retrobill_Adjustments(p_operation IN VARCHAR2);



PROCEDURE Preprocess_Adjustments(p_orig_sys_document_ref IN NUMBER
                                 ,p_orig_sys_line_ref IN NUMBER
				 ,p_header_id IN NUMBER --bug3738043
                                 ,p_line_id IN NUMBER);

PROCEDURE Get_Last_Retro_HdrID(p_header_id IN NUMBER,
                                x_header_id OUT NOCOPY NUMBER);

PROCEDURE Get_Last_Retro_LinID(p_line_id IN NUMBER,
                                x_line_id OUT NOCOPY NUMBER);
--retro{

PROCEDURE Oe_Build_Retrobill_Tbl(p_request_session_id   IN NUMBER,
                                 p_retrobill_event      IN VARCHAR2,
                                 p_description          IN VARCHAR2,
                                 p_order_type_id        IN NUMBER,
                                 p_retrobill_request_id IN NUMBER,
                                 p_reason_code          IN VARCHAR2,
                                 p_retrobill_mode       IN VARCHAR2,
				 p_sold_to_org_id       IN NUMBER,
				 p_inventory_item_id    IN NUMBER,
                                 x_return_status        OUT NOCOPY VARCHAR2,
                                 x_msg_count            OUT NOCOPY NUMBER,
                                 x_msg_data             OUT NOCOPY VARCHAR2,
                                 x_return_status_text   OUT NOCOPY VARCHAR2,
                                 x_retrobill_request_id OUT NOCOPY NUMBER,
				 --bug5003256
                                 x_error_count          OUT NOCOPY NUMBER);

PROCEDURE Oe_Retrobill_Conc_Pgm(errbuf                  OUT NOCOPY VARCHAR2,
                                retcode                 OUT NOCOPY NUMBER,
                                p_request_session_id    IN VARCHAR2,
                                p_retrobill_event       IN VARCHAR2,
                                p_description           IN VARCHAR2,
                                p_order_type_id         IN VARCHAR2,
                                p_retrobill_request_id  IN VARCHAR2,
                                p_reason_code           IN VARCHAR2,
                                p_retrobill_mode        IN VARCHAR2,
				p_sold_to_org_id        IN NUMBER,
				p_inventory_item_id     IN NUMBER
                                );
FUNCTION Retrobill_Enabled RETURN BOOLEAN;

PROCEDURE Interface_Retrobilled_RMA
(  p_line_rec    IN    OE_Order_PUB.Line_Rec_Type
,  p_header_rec  IN    OE_Order_PUB.Header_Rec_Type
,  x_return_status     OUT NOCOPY VARCHAR2
,  x_result_out        OUT NOCOPY  VARCHAR2
);

--Procedure for the api based validation template Return Retrobilled Line
--skubendr{
PROCEDURE Return_Retrobilled_Line_Check
( p_application_id                IN   NUMBER,
  p_entity_short_name             IN   VARCHAR2,
  p_validation_entity_short_name  IN   VARCHAR2,
  p_validation_tmplt_short_name   IN   VARCHAR2,
  p_record_set_short_name         IN   VARCHAR2,
  p_scope                         IN   VARCHAR2,
  x_result                        OUT  NOCOPY NUMBER
);

--Procedure for Purging Retrobill Requests and associated Headers/Lines
PROCEDURE Oe_Retrobill_Purge
( errbuf                          OUT NOCOPY VARCHAR2,
  retcode                         OUT NOCOPY NUMBER,
  p_org_id                        IN   VARCHAR2, --rt moac
  p_retrobill_request_id          IN   VARCHAR2,
  p_creation_date_from            IN   VARCHAR2,
  p_creation_date_to              IN   VARCHAR2,
  p_execution_date_from           IN   VARCHAR2,
  p_execution_date_to             IN   VARCHAR2,
  p_purge_preview_orders          IN   VARCHAR2
);
--skubendr}

--bug3654144
PROCEDURE Update_Invalid_Diff_Adj;

FUNCTION Invoice_Number(p_order_number IN NUMBER,p_line_id IN NUMBER,p_order_type_id IN NUMBER) RETURN VARCHAR2;

FUNCTION Get_First_Line_Price_List_Id RETURN NUMBER;

--bug3738043
FUNCTION Get_Retro_Pricing_Phase_Count RETURN NUMBER;

-- 3661895 Start
PROCEDURE Get_Line_Adjustments
 (p_line_rec         IN  OE_Order_Pub.Line_Rec_Type
 ,x_line_adjustments OUT NOCOPY OE_Header_Adj_Util.Line_Adjustments_Tab_Type
 );
-- 3661895 End
--skubendr{
 G_RETROBILL_REQUEST_REC OE_RETROBILL_REQUESTS%ROWTYPE;
--skubendr}
G_FIRST_LINE_PRICE_LIST_ID NUMBER;
G_FIRST_LINE_DELETED varchar2(1);
G_FIRST_LINE_PL_ASSIGNED varchar2(1);
--retro}


End  OE_RETROBILL_PVT;

 

/
