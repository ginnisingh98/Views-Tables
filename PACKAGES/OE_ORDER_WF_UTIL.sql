--------------------------------------------------------
--  DDL for Package OE_ORDER_WF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_WF_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUOWFS.pls 120.0.12010000.3 2009/06/24 14:54:54 snimmaga ship $ */

G_PKG_NAME       CONSTANT VARCHAR2(30) := 'OE_ORDER_WF_UTIL';

PROCEDURE Set_Notification_Approver(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2);

PROCEDURE Set_Header_User_Key
( p_header_rec IN OE_Order_PUB.Header_Rec_Type
);

PROCEDURE Set_Line_User_Key
( p_line_rec IN OE_Order_PUB.Line_Rec_Type
);

PROCEDURE Set_Header_Descriptor(document_id in varchar2,
                            display_type in varchar2,
                            document in out NOCOPY /* file.sql.39 change */ varchar2,
                            document_type in out NOCOPY /* file.sql.39 change */ varchar2
);


PROCEDURE Set_Line_Descriptor(document_id in varchar2,
                            display_type in varchar2,
                            document in out NOCOPY /* file.sql.39 change */ varchar2,
                            document_type in out NOCOPY /* file.sql.39 change */ varchar2
);


PROCEDURE Start_Flow
(  p_itemtype in varchar2
,  p_itemkey  in varchar2
);

PROCEDURE Start_LineFork
(  p_itemkey  in varchar2
);

PROCEDURE CreateStart_HdrProcess
( p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type
);

PROCEDURE Create_HdrWorkItem
(  p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type
);

PROCEDURE CreateStart_LineFork
( p_line_rec                    IN  OE_Order_PUB.Line_Rec_Type
);

PROCEDURE CreateStart_LineProcess
( p_Line_rec                    IN  OE_Order_PUB.Line_Rec_Type
);



PROCEDURE Create_LineWorkItem
(  p_Line_rec                   IN  OE_Order_PUB.Line_Rec_Type,
   p_item_type 			  IN VARCHAR2
);

PROCEDURE Create_LineFork
(  p_Line_rec                   IN  OE_Order_PUB.Line_Rec_Type
);

FUNCTION Get_Wf_Item_type
(  p_Line_rec                   IN  OE_Order_PUB.Line_Rec_Type
) RETURN VARCHAR2;

PROCEDURE Start_All_Flows;

PROCEDURE Clear_FlowStart_Globals;

PROCEDURE Delete_Row
(  p_type      IN   VARCHAR2
,  p_id        IN   NUMBER
);

PROCEDURE Update_Flow_Status_Code
( p_header_id        IN NUMBER DEFAULT NULL,
  p_line_id          IN NUMBER DEFAULT NULL,
  p_flow_status_code IN VARCHAR2,
  p_item_type        IN VARCHAR2 DEFAULT NULL,
  p_sales_document_type_code IN VARCHAR2 DEFAULT NULL,
  x_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE Update_Quote_Blanket
( p_item_type        IN VARCHAR2,
  p_item_key         IN VARCHAR2,
  p_flow_status_code IN VARCHAR2 DEFAULT NULL,
  p_open_flag        IN VARCHAR2 DEFAULT NULL,
  p_draft_submitted_flag IN VARCHAR2 DEFAULT NULL,
  x_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE Create_WorkItem_Upgrade
(p_item_type      IN VARCHAR2,
 p_item_key       IN VARCHAR2,
 p_process_name   IN VARCHAR2,
 p_transaction_number       IN NUMBER,
 p_sales_document_type_code IN VARCHAR2,
 p_user_id       IN NUMBER,
 p_resp_id       IN NUMBER,
 p_appl_id       IN NUMBER,
 p_org_id        IN NUMBER
);

PROCEDURE CreateStart_HdrInternal
( p_item_type IN VARCHAR2,
  p_header_id IN NUMBER,
  p_transaction_number IN NUMBER,
  p_sales_document_type_code IN VARCHAR2
);

PROCEDURE Create_HdrWorkItemInternal
(p_item_type IN VARCHAR2,
 p_header_id IN NUMBER,
 p_transaction_number IN NUMBER,
 p_sales_document_type_code IN VARCHAR2
);

PROCEDURE Set_Negotiate_Hdr_User_Key
(p_header_id IN NUMBER,
 p_sales_document_type_code IN VARCHAR2,
 p_transaction_number IN NUMBER);

PROCEDURE Set_Blanket_Hdr_User_Key
(p_header_id IN NUMBER,
 p_transaction_number IN NUMBER);


Procedure Set_transaction_Details(document_id   in      varchar2,
                                 display_type   in      varchar2,
                                 document       in out  NOCOPY varchar2,
                                 document_type  in out  NOCOPY varchar2);

procedure build_quote_doc ( p_item_type      in varchar2,
                            p_item_key       in varchar2,
                            p_display_type   in varchar2,
                            p_x_document     in out  NOCOPY varchar2
                             );

procedure build_blanket_doc ( p_item_type    in varchar2,
                            p_item_key       in varchar2,
                            p_display_type   in varchar2,
                            p_x_document     in out  NOCOPY varchar2
                             );
function check_credit_hold (p_hold_entity_code     IN      varchar2,
                            p_hold_entity_id       IN      number
                            )
                            RETURN VARCHAR2;

PROCEDURE Complete_eligible_and_Book
                ( p_api_version_number          IN   NUMBER
                , p_init_msg_list               IN   VARCHAR2 := FND_API.G_FALSE
                , p_header_id                   IN   NUMBER
                , x_return_status               OUT  NOCOPY VARCHAR2
                , x_msg_count                   OUT  NOCOPY NUMBER
                , x_msg_data                    OUT  NOCOPY VARCHAR2
                );

END OE_Order_WF_Util;

/
