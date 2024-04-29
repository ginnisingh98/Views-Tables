--------------------------------------------------------
--  DDL for Package IBE_WORKFLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_WORKFLOW_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVWFS.pls 120.3 2005/11/14 03:10:59 knachiap noship $ */
/*==============================================================================
| NAME
|    ibe_workflow_pvt
|
| MODIFICATION HISTORY
|  03/23/99	  hjaganat	Created
|  08/23/00   hjaganat  Modifications for Order Status Alerts
|                                       	completed
|  09/06/00   hjaganat	Modifications for Contracts completed
|  09/07/00   hjaganat	Modifications for Sales Assistance
|                                       	completed
|  07/14/01   Dkhanna -  Modified for Template Mapping FrameWork.
|  10/26/01   Ashukla -  Modified for Quote Publish.
|  11/29/01   Ashukla -  Modified for bug2104272
|  12/27/01   Ashukla -  Modified for bug2077446
|  02/18/02   ljanakir - Modified for bug2223507
|					     Added p_salesrep_user_id parameter for the procedure
|                        NotifyForSalesAssistance
|  03/13/03   ljanakir - Modified for bug 2111316
|                        Added the procedure NotifyForgetLogin
|  09/27/02   batoleti - Added Notify_End_Working procedure.
|  10/01/02   batoleti - Added Notify_Finish_Sharing procedure.
|  10/04/02   batoleti - Added NotifyForSharedCart  procedure.
|  10/07/02   batoleti - Added Notify_Access_Change procedure.
|  12/12/02   SCHAK      Bug # 2691704     Modified for NOCOPY Changes.
|  07/22/03   batoleti   Added Return Order Notification procedure.
/  08/26/03  abhandar    changed getUserType(),Get_Name_Details() and NotifyRegistration()
/                        Added Generate_Approval_Msg()
|  01/May/05  Knachiap   MACD Notification Change for Cart/Checkout
|  06/02/05   abairy	 Added Generate_Credential_Msg procedure
|  14/Nov/05  Knachiap   Line Type for Quote
===============================================================================
*/

PROCEDURE NotifyForQuotePublish(
	p_api_version       IN   NUMBER,
	p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
	p_Msite_Id          IN   NUMBER,
	p_quote_id          IN   VARCHAR2,
	p_Req_Name          IN   Varchar2,
	p_Send_Name         IN   Varchar2,
	p_Email_Address     IN   Varchar2,
	p_url               IN   Varchar2,
	x_return_status     OUT NOCOPY  VARCHAR2,
	x_msg_count         OUT NOCOPY  NUMBER,
	x_msg_data          OUT NOCOPY  VARCHAR2
     );

PROCEDURE NotifyRegistration(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_first_name 		IN	VARCHAR2,
	p_last_name 		IN	VARCHAR2,
	p_login_name 		IN	VARCHAR2,
	p_password 		    IN	VARCHAR2,
    p_usertype          IN  VARCHAR2,
	p_email_address 	IN	VARCHAR2,
	p_event_type 		IN	VARCHAR2,
	p_language		    IN	VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
	);


PROCEDURE NotifyRegistration (
	p_api_version		IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
	p_Msite_Id		IN	NUMBER,
	p_first_name 		IN	VARCHAR2,
	p_last_name 		IN	VARCHAR2,
	p_login_name 		IN	VARCHAR2,
	p_password		    IN	VARCHAR2,
    p_usertype          IN  VARCHAR2,
	p_email_address	    IN	VARCHAR2,
	p_event_type 		IN	VARCHAR2,
	p_language		IN	VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
	);



PROCEDURE NotifyForgetLogin(
     p_api_version       IN   NUMBER,
     p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
     p_Msite_Id          IN   NUMBER,
     p_first_name        IN   VARCHAR2,
     p_last_name         IN   VARCHAR2,
     p_login_name        IN   VARCHAR2,
     p_password          IN   VARCHAR2,
     p_email_address     IN   VARCHAR2,
     x_return_status     OUT NOCOPY  VARCHAR2,
     x_msg_count         OUT NOCOPY  NUMBER,
     x_msg_data          OUT NOCOPY  VARCHAR2
     );


PROCEDURE NotifyOrderStatus(
	p_api_version		IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
	p_quote_id		IN	NUMBER,
	p_status 		IN	VARCHAR2,
	p_errmsg_count		IN	NUMBER,
	p_errmsg_data		IN	VARCHAR2,
	p_sharee_partyId        IN  NUMBER := NULL,
	x_return_status	        OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
	);

PROCEDURE NotifyOrderStatus(
	p_api_version		IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
	p_msite_id		IN 	NUMBER,
	p_quote_id		IN	NUMBER,
	p_status 			IN	VARCHAR2,
	p_errmsg_count		IN	NUMBER,
	p_errmsg_data		IN	VARCHAR2,
	p_sharee_partyId    IN   NUMBER,
	x_return_status     OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
	);

PROCEDURE NotifyReturnOrderStatus(
	p_api_version     IN NUMBER,
	p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE,
     p_party_id        IN NUMBER,
     p_order_header_id IN NUMBER,
	p_errmsg_count    IN NUMBER,
	p_errmsg_data     IN VARCHAR2,
	x_return_status   OUT NOCOPY	VARCHAR2,
	x_msg_count       OUT NOCOPY	NUMBER,
	x_msg_data        OUT NOCOPY	VARCHAR2
      );

PROCEDURE get_contact_details_for_order(
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE ,
    p_commit             IN  VARCHAR2 := FND_API.G_FALSE ,
    p_order_id           IN  NUMBER,
    x_contact_party_id   OUT NOCOPY NUMBER,
    x_contact_first_name OUT NOCOPY VARCHAR2,
    x_contact_mid_name   OUT NOCOPY VARCHAR2,
    x_contact_last_name  OUT NOCOPY VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2
    );

PROCEDURE Notify_cancel_order(
    p_api_version       IN  NUMBER,
    p_init_msg_list	    IN  VARCHAR2 := FND_API.G_FALSE,
    p_order_id          IN  NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
	);

PROCEDURE NotifyForContractsChange(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_quote_id          IN  NUMBER,
	p_contract_id		IN	NUMBER,
	p_customer_comments	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
	p_salesrep_email_id	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
	);

PROCEDURE NotifyForContractsChange(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_msite_id		IN	NUMBER,
	p_quote_id		IN	NUMBER,
	p_contract_id  	        IN	NUMBER,
	p_customer_comments	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
	p_salesrep_email_id	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
);

APPROVED CONSTANT NUMBER  :=  0;
REJECTED CONSTANT NUMBER  :=  1;
CANCELLED CONSTANT NUMBER :=  2;

PROCEDURE NotifyForContractsStatus(
        p_api_version          IN      NUMBER,
        p_init_msg_list        IN      VARCHAR2 := FND_API.G_FALSE,
        p_quote_id             IN      NUMBER,
        p_contract_id          IN      NUMBER,
        p_contract_status      IN      NUMBER,
        x_return_status        OUT NOCOPY     VARCHAR2,
        x_msg_count            OUT NOCOPY     NUMBER,
        x_msg_data             OUT NOCOPY     VARCHAR2
);


PROCEDURE NotifyForSalesAssistance (
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_quote_id		IN	NUMBER,
	p_customer_comments	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
	p_salesrep_email_id	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
	p_reason_code		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
	p_salesrep_user_id  IN   NUMBER   := NULL,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
	);

PROCEDURE NotifyForSalesAssistance (
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_msite_id		IN      NUMBER,
	p_quote_id		IN	NUMBER,
	p_customer_comments	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
	p_salesrep_email_id	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
	p_reason_code		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
	p_salesrep_user_id  IN   NUMBER   := NULL,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
	);


PROCEDURE Notifyforsharedcart (
	p_api_version      IN  NUMBER,
	p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
    p_Quote_Header_id  IN  NUMBER,
 	p_emailAddress     IN  VARCHAR2,
	p_quoteShareeNum   IN  NUMBER,
	p_privilegeType    IN  VARCHAR2,
  	p_url              IN  VARCHAR2,
	p_comments         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
	x_return_status    OUT NOCOPY VARCHAR2,
	x_msg_count        OUT NOCOPY NUMBER,
	x_msg_data         OUT NOCOPY VARCHAR2
	);

PROCEDURE NotifyForSharedCart (
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_Msite_id           	IN 	NUMBER,
    p_Quote_Header_id       IN   	NUMBER,
 	p_emailAddress          IN   	VARCHAR2,
	p_quoteShareeNum	IN	NUMBER,
	p_privilegeType         IN   	VARCHAR2,
  	p_url                   IN   	VARCHAR2,
	p_comments              IN   	VARCHAR2 := FND_API.G_MISS_CHAR,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
	);

PROCEDURE Notify_End_working(
    p_api_version       IN  NUMBER,
    p_init_msg_list	    IN  VARCHAR2 := FND_API.G_FALSE,
    p_quote_header_id   IN  NUMBER,
    p_party_id          IN  NUMBER,
    p_cust_account_id   IN  NUMBER,
    p_retrieval_number  IN  NUMBER,
    p_minisite_id       IN  NUMBER,
    p_url               IN  VARCHAR2,
    p_notes             IN  VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
    );

PROCEDURE Notify_Finish_Sharing(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2,
    p_quote_access_rec  IN  IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_REC_TYPE,
    p_minisite_id       IN  NUMBER,
    p_url               IN  VARCHAR2,
    p_context_code      IN  varchar2,
    p_shared_by_partyid IN  NUMBER := FND_API.G_MISS_NUM,
    p_notes             IN  VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
    );

PROCEDURE Notify_Shared_Cart  (
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2,
    p_quote_access_rec   IN  Ibe_Quote_Saveshare_pvt.QUOTE_ACCESS_Rec_Type,  --of the recepient
    p_minisite_id        IN  NUMBER,
    p_url                IN  VARCHAR2,
    p_shared_by_party_id IN  NUMBER := FND_API.G_MISS_NUM,
    p_notes              IN  VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
    );

PROCEDURE Notify_access_change(
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2,
    p_quote_access_rec   IN  IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_REC_TYPE, --of the recepient
    p_minisite_id        IN  NUMBER,
    p_url                IN  VARCHAR2,
    p_old_accesslevel    IN  VARCHAR2,
    p_shared_by_party_id IN  NUMBER := FND_API.G_MISS_NUM,
    p_notes              IN  VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
    );

PROCEDURE Notify_view_shared_cart(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2,
    p_quote_access_rec  IN  IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_REC_TYPE, --of the recepient
    p_minisite_id       IN  NUMBER,
    p_url               IN  VARCHAR2,
    p_sent_by_party_id  IN  NUMBER  ,
    p_notes             IN  VARCHAR2,
    p_owner_party_id    IN  NUMBER  := FND_API.G_MISS_NUM,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
    );

PROCEDURE ParseThisString (
	p_string_in		IN	VARCHAR2,
	p_string_out		OUT NOCOPY	VARCHAR2,
	p_string_left		OUT NOCOPY	VARCHAR2
	);

PROCEDURE ParseThisString1 (
	p_string_in		IN	VARCHAR2,
	p_string_out		OUT NOCOPY	VARCHAR2,
	p_string_left		OUT NOCOPY	VARCHAR2
	);

FUNCTION AddSpaces (
	p_num_in			IN	NUMBER
) RETURN VARCHAR2;

PROCEDURE GenerateHeader(
	document_id		IN		VARCHAR2,
	display_type		IN		VARCHAR2,
	document		IN 	OUT NOCOPY	VARCHAR2,
	document_type		IN	OUT NOCOPY	VARCHAR2
	);

PROCEDURE GenerateDetail(
	document_id   IN VARCHAR2,
	display_type  IN VARCHAR2,
	document      IN OUT NOCOPY VARCHAR2,
	document_type IN OUT NOCOPY VARCHAR2
	);

PROCEDURE GenerateOrderDetailHeader(
	document_id    IN             VARCHAR2,
	display_type	IN             VARCHAR2,
	document	     IN OUT NOCOPY	VARCHAR2,
	document_type	IN OUT NOCOPY	VARCHAR2
     );

PROCEDURE GenerateReturnDetail(
	P_item_key	IN              VARCHAR2,
	p_tax_flag	IN              VARCHAR2,
	x_document	IN	OUT NOCOPY	VARCHAR2
     );



--Quote_flag: To decide the context in which this API is called. If quote flag is true then the API will provide
--quote details else API will provide order details.
--Tax_Flag: If quote flag is true then the API will provide line details(of order or quote) with tax
--else API will provide line details without tax.
  PROCEDURE Generate_Detail(
	P_item_key   IN VARCHAR2,
    p_quote_flag IN VARCHAR2,
    p_tax_flag   IN VARCHAR2,
	x_document   OUT NOCOPY VARCHAR2
	);
--Procedure to generate order line information in the notification with tax details.
--Document_type: HTML or Text.
--Document: the line detail text that is printed in the notification.
PROCEDURE Generate_order_Detail_wtax(
	document_id     IN  VARCHAR2,
	display_type    IN  VARCHAR2,
	document        IN  OUT NOCOPY VARCHAR2,
	document_type   IN  OUT NOCOPY	VARCHAR2
	);
--Procedure to generate order line information in the notification without tax details.
--Document_type: HTML or Text.
--Document: the line detail text that is printed in the notification.
PROCEDURE Generate_order_Detail_notax(
	document_id    IN  VARCHAR2,
	display_type   IN  VARCHAR2,
	document       IN  OUT NOCOPY VARCHAR2,
	document_type  IN  OUT NOCOPY VARCHAR2
	);

--Procedure to generate quote line information in the notification with tax details.
--Document_type: HTML or Text.
--Document: the line detail text that is printed in the notification.

PROCEDURE Generate_quote_Detail_wtax(
	document_id    IN  VARCHAR2,
	display_type   IN  VARCHAR2,
	document       IN  OUT NOCOPY VARCHAR2,
	document_type  IN  OUT NOCOPY VARCHAR2
	);

--Procedure to generate quote line information in the notification without tax details.
--Document_type: HTML or Text.
--Document: the line detail text that is printed in the notification.
PROCEDURE Generate_quote_Detail_notax(
	document_id    IN  VARCHAR2,
	display_type   IN  VARCHAR2,
	document       IN  OUT NOCOPY VARCHAR2,
	document_type  IN  OUT NOCOPY VARCHAR2
	);

--Procedure to generate return order line information in the notification with tax details.
--Document_type: HTML or Text.
--Document: the return line detail text that is printed in the notification.

PROCEDURE Generate_rtn_ord_Detail_wtax(
	document_id     IN  VARCHAR2,
	display_type    IN  VARCHAR2,
	document        IN  OUT NOCOPY VARCHAR2,
	document_type   IN  OUT NOCOPY	VARCHAR2
	);

--Procedure to generate return order line information in the notification without tax details.
--Document_type: HTML or Text.
--Document: the return line detail text that is printed in the notification.

PROCEDURE Generate_rtn_ord_Detail_notax(
	document_id    IN  VARCHAR2,
	display_type   IN  VARCHAR2,
	document       IN  OUT NOCOPY VARCHAR2,
	document_type  IN  OUT NOCOPY VARCHAR2
	);



PROCEDURE GenerateFooter(
	document_id		IN		VARCHAR2,
	display_type		IN		VARCHAR2,
	document		IN 	OUT NOCOPY	VARCHAR2,
	document_type		IN	OUT NOCOPY	VARCHAR2
	);

PROCEDURE GenerateQuoteHeader(
	document_id		IN		VARCHAR2,
	display_type		IN		VARCHAR2,
	document		IN 	OUT NOCOPY	VARCHAR2,
	document_type		IN	OUT NOCOPY	VARCHAR2
	);

PROCEDURE GenerateQuoteDetail(
	document_id		IN		VARCHAR2,
	display_type		IN		VARCHAR2,
	document		IN 	OUT NOCOPY	VARCHAR2,
	document_type		IN	OUT NOCOPY	VARCHAR2
	);

PROCEDURE GenerateQuoteFooter(
	document_id		IN		VARCHAR2,
	display_type		IN		VARCHAR2,
	document		IN 	OUT NOCOPY	VARCHAR2,
	document_type		IN	OUT NOCOPY	VARCHAR2
	);

PROCEDURE GenerateAssistHeader(
	document_id		IN		VARCHAR2,
	display_type		IN		VARCHAR2,
	document		IN 	OUT NOCOPY	VARCHAR2,
	document_type		IN	OUT NOCOPY	VARCHAR2
	);



PROCEDURE GetFirstName(
	document_id		IN		VARCHAR2,
	display_type		IN		VARCHAR2,
	document		IN 	OUT NOCOPY	VARCHAR2,
	document_type		IN	OUT NOCOPY	VARCHAR2
	);

PROCEDURE GetLastName(
	document_id		IN		VARCHAR2,
	display_type		IN		VARCHAR2,
	document		IN 	OUT NOCOPY	VARCHAR2,
	document_type		IN	OUT NOCOPY	VARCHAR2
	);


PROCEDURE GetTitle(
	document_id		IN		VARCHAR2,
	display_type		IN		VARCHAR2,
	document		IN 	OUT NOCOPY	VARCHAR2,
	document_type		IN	OUT NOCOPY	VARCHAR2
	);


PROCEDURE GetContractRef(
	document_id		IN		VARCHAR2,
	display_type		IN		VARCHAR2,
	document		IN 	OUT NOCOPY	VARCHAR2,
	document_type		IN	OUT NOCOPY	VARCHAR2
	);


PROCEDURE GetCartName(
	document_id		IN		VARCHAR2,
	display_type		IN		VARCHAR2,
	document		IN 	OUT NOCOPY	VARCHAR2,
	document_type		IN	OUT NOCOPY	VARCHAR2
	);



PROCEDURE Selector (
	itemtype		IN	VARCHAR2,
	itemkey			IN	VARCHAR2,
	actid			IN 	NUMBER,
	funcmode		IN	VARCHAR2,
	result			OUT NOCOPY	VARCHAR2
	);


Procedure getUserType(
		  pPartyId  IN NUMBER,
          pUserType OUT NOCOPY Varchar2);

PROCEDURE Get_Name_details(p_party_id         	IN  HZ_PARTIES.PARTY_ID%TYPE,
                           p_user_type          	IN  VARCHAR2 := FND_API.G_MISS_CHAR,
                           p_sharee_number      	IN  NUMBER := null ,
                           x_contact_first_name 	OUT NOCOPY HZ_PARTIES.PERSON_FIRST_NAME%TYPE,
                           x_contact_last_name  	OUT NOCOPY HZ_PARTIES.PERSON_LAST_NAME%TYPE,
                           x_party_id           	OUT NOCOPY HZ_PARTIES.PARTY_ID%TYPE);

--added by abhandar 08/26/2003:new procedure
 PROCEDURE Generate_Approval_Msg(
        document_id     IN  VARCHAR2,
        display_type    IN  VARCHAR2,
        document        IN  OUT NOCOPY VARCHAR2,
        document_type   IN  OUT NOCOPY VARCHAR2
 );

 PROCEDURE Generate_Credential_Msg(
         document_id     IN  VARCHAR2,
         display_type    IN  VARCHAR2,
         document        IN  OUT NOCOPY VARCHAR2,
         document_type   IN  OUT NOCOPY VARCHAR2
 );

PROCEDURE get_speciality_store_name(
        document_id     IN  VARCHAR2,
        display_type    IN  VARCHAR2,
        document        IN  OUT NOCOPY VARCHAR2,
        document_type   IN  OUT NOCOPY VARCHAR2
 );

PROCEDURE get_fnd_lkpup_value(
        document_id     IN  VARCHAR2,
        display_type    IN  VARCHAR2,
        document        IN  OUT NOCOPY VARCHAR2,
        document_type   IN  OUT NOCOPY VARCHAR2
 );

PROCEDURE get_FND_message(
	document_id     IN  VARCHAR2,
	display_type    IN  VARCHAR2,
	document        IN  OUT NOCOPY VARCHAR2,
	document_type   IN  OUT NOCOPY	VARCHAR2
);

PROCEDURE get_date(
	document_id     IN  VARCHAR2,
	display_type    IN  VARCHAR2,
	document        IN  OUT NOCOPY VARCHAR2,
	document_type   IN  OUT NOCOPY	VARCHAR2
);

PROCEDURE get_sales_assist_rsn_meaning(
        document_id     IN  VARCHAR2,
        display_type    IN  VARCHAR2,
        document        IN  OUT NOCOPY VARCHAR2,
        document_type   IN  OUT NOCOPY VARCHAR2
);

TYPE NotifLineType is Record
  (
    Action       VARCHAR2(30),
    Product      VARCHAR2(495),
    UOM          VARCHAR2(25),
    Quantity     NUMBER,
    Shippable    VARCHAR2(1),
    NetAmount    NUMBER,
    Periodicity  VARCHAR2(37),
    TaxAmount    NUMBER,
    LastItem VARCHAR2(1));
  TYPE Notif_Line_Tbl_Type IS table OF NotifLineType INDEX BY BINARY_INTEGER;

FUNCTION buildDocument
(
  notif_line_tbl IN Notif_Line_Tbl_Type,
  view_net_price_flag VARCHAR2,
  view_line_type_flag VARCHAR2,
  tax_flag VARCHAR2
) return VARCHAR2;

PROCEDURE ParseString (
	p_string_in	IN	VARCHAR2,
	p_string_len     IN NUMBER := 12,
	p_string_out	OUT NOCOPY	VARCHAR2,
	p_string_left	OUT NOCOPY	VARCHAR2
);

END ibe_workflow_pvt;

 

/
