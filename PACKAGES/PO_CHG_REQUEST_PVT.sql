--------------------------------------------------------
--  DDL for Package PO_CHG_REQUEST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CHG_REQUEST_PVT" AUTHID CURRENT_USER AS
/* $Header: POXPCHGS.pls 120.2.12010000.5 2014/04/22 09:18:10 pneralla ship $ */

  G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'PO_CHG_REQUEST_PVT';
  G_FILE_NAME CONSTANT    VARCHAR2(30) := 'POSCHORB.pls';

 procedure process_supplier_signature (
         p_api_version            IN  NUMBER,
         p_Init_Msg_List          IN  VARCHAR2,
         x_return_status          OUT NOCOPY VARCHAR2,
         x_notification_id        OUT NOCOPY NUMBER,
         p_po_header_id         IN  number,
         p_revision_num         IN  number,
         p_document_subtype       IN  VARCHAR2,
         p_document_number        IN  VARCHAR2,
         p_org_id                 IN  NUMBER,
         p_Agent_Id               IN  NUMBER,
         p_supplier_user_id       IN  number) ;

 procedure save_request(
          p_api_version             IN  NUMBER    ,
          p_Init_Msg_List           IN  VARCHAR2  ,
          x_return_status           OUT NOCOPY VARCHAR2,
          p_po_header_id        IN  number,
          p_po_release_id          IN  number,
          p_revision_num           IN  number,
          p_po_change_requests     IN  pos_chg_rec_tbl,
          x_request_group_id        OUT NOCOPY NUMBER,
          p_chn_int_cont_num        IN  varchar2 default null,
          p_chn_source              IN  varchar2 default null,
          p_chn_requestor_username  in  varchar2 default null,
          p_user_id                 IN  number default null,
          p_login_id                IN  number default null);


 /* This procedure will post acceptance request record cancellation
    request at shipments level
    also process change requests at line and shipments level
    Call time phase pricing api for new price
    The record will be split to Lines  Shipments  Distributions
    and will call document submission check for core PO

 */
 /*
 procedure process_supplier_request (
           p_po_header_id        IN  number,
           p_po_release_id        IN  number,
           p_revision_num         IN  number,
           p_po_change_requests   IN  pos_chg_rec_tbl,
           x_online_report_id     OUT NOCOPY number,
           x_pos_errors             out NOCOPY POS_ERR_TYPE,
           p_chn_int_cont_num       IN  varchar2 default null,
           p_chn_source             IN  varchar2 default null,
           p_chn_requestor_username in  varchar2 default null,
           p_user_id                IN  number default null,
           p_login_id               IN  number default null,
           p_last_upd_date          IN  date default null) ;
*/
-- This procedure will update the po attributes in core po tables
-- set the po to IN PROCESS and set the new flag on po_headers_all

procedure process_supplier_request (
           p_po_header_id        IN  number,
           p_po_release_id        IN  number,
           p_revision_num         IN  number,
           p_po_change_requests   IN  pos_chg_rec_tbl,
           x_online_report_id     OUT NOCOPY number,
           x_pos_errors             out NOCOPY POS_ERR_TYPE,
           p_chn_int_cont_num       IN  varchar2 default null,
           p_chn_source             IN  varchar2 default null,
           p_chn_requestor_username in  varchar2 default null,
           p_user_id                IN  number default null,
           p_login_id               IN  number default null,
           p_last_upd_date          IN  date default null,
           p_mpoc                   IN varchar2 default FND_API.G_FALSE) ;



 procedure update_po_attributes(
          p_po_header_id           IN  number,
          p_po_release_id          IN  number,
          p_revision_num           IN  number,
          p_chg_request_grp_id     IN  number,
          x_return_status          OUT NOCOPY varchar2,
          p_chn_requestor_username IN  varchar2 default null,
          p_user_id                IN  number default null,
          p_login_id               IN  number default null);

 procedure validate_change_request (
          p_api_version             IN   NUMBER,
          p_init_msg_list           IN   VARCHAR2 := FND_API.G_FALSE,
          x_return_status           OUT  NOCOPY VARCHAR2,
          x_msg_data                OUT  NOCOPY VARCHAR2,
          p_po_header_id            IN   number,
          p_po_release_id           IN   number,
          p_revision_num            IN   number,
          p_po_change_requests      IN   OUT NOCOPY pos_chg_rec_tbl,
          x_online_report_id        OUT  NOCOPY number,
           x_pos_errors             OUT  NOCOPY POS_ERR_TYPE,
           x_doc_check_error_msg    OUT  NOCOPY Doc_Check_Return_Type);


 function ifLineChangable(
             p_po_line_id         IN  number)
             return varchar2;

 procedure validateCancelRequest(
           p_api_version        IN     NUMBER,
           p_init_msg_list      IN     VARCHAR2 := FND_API.G_FALSE,
           x_return_status      OUT    NOCOPY VARCHAR2,
           p_po_header_id       IN     NUMBER,
           p_po_release_id      IN     NUMBER);




 procedure getShipmentStatus(
           p_line_location_id   IN     NUMBER,
           p_po_header_id       IN     NUMBER,
           p_po_release_id      IN     NUMBER,
           p_revision_num       IN     NUMBER,
           x_msg_code           OUT NOCOPY VARCHAR2,
           x_msg_display        OUT NOCOPY VARCHAR2,
           x_note               OUT NOCOPY LONG);

 procedure save_cancel_request(
          p_api_version          IN NUMBER    ,
          p_Init_Msg_List        IN VARCHAR2  ,
          x_return_status        OUT NOCOPY VARCHAR2,
          p_po_header_id        IN  number,
          p_po_release_id       IN  number,
          p_revision_num        IN  number,
          p_po_change_requests  IN  pos_chg_rec_tbl,
          x_request_group_id     OUT NOCOPY NUMBER);

 procedure validate_change_request (
           p_api_version             IN   NUMBER,
           p_init_msg_list           IN   VARCHAR2 := FND_API.G_FALSE,
           x_return_status           OUT  NOCOPY VARCHAR2,
           x_msg_data                OUT  NOCOPY VARCHAR2,
           p_po_header_id            IN   NUMBER,
           p_po_release_id           IN   NUMBER,
           p_revision_num            IN   NUMBER,
           p_po_change_requests      IN OUT NOCOPY pos_chg_rec_tbl,
           x_online_report_id        OUT  NOCOPY number,
           x_pos_errors             OUT  NOCOPY POS_ERR_TYPE);

 procedure getLineAttrs(
           p_from_header_id     IN  NUMBER,
           p_un_number_id       IN  NUMBER,
           p_haz_class_id       IN  NUMBER,
           x_ga_number          OUT NOCOPY VARCHAR2,
           x_un_number          OUT NOCOPY VARCHAR2,
           x_haz_class_desc     OUT NOCOPY VARCHAR2);

 procedure cancel_change_request (
           p_api_version             IN   NUMBER,
           p_init_msg_list           IN   VARCHAR2 := FND_API.G_FALSE,
           x_return_status           OUT  NOCOPY VARCHAR2,
           p_po_header_id            IN   NUMBER,
           p_po_release_id           IN   NUMBER,
           p_po_line_id              IN   NUMBER,
           p_po_line_location_id     IN   NUMBER);


  /****************************************************************
    **  This function will create a pos_change_rec type object.
    **  Each field corresponds to a column in the POS_CHANGE_REQUESTS table.
    **  Note that the not null columns are required parameters and
    **  nullable columns are defined with default null.
    **  Recommondation : Use named parameter invocation to send in
    **  only the fields that matter.
    **
    **  NOTE:  If the pos_change_rec object has changed,
    **  a new parameter has to be added.
    **/


 function   create_pos_change_rec (
      p_Action_Type                      IN    VARCHAR2, --(30),
      p_Initiator                        IN    VARCHAR2, --(30),
      p_Document_Type                    IN    VARCHAR2, --(30),
      p_Request_Level                    IN    VARCHAR2, --(30),
      p_Request_Status                   IN    VARCHAR2, --(30),
      p_Document_Header_Id               IN    NUMBER,
      p_Request_Reason                   IN    VARCHAR2  default null, --(2000),
      p_PO_Release_Id                    IN    NUMBER  default null,
      p_Document_Num                     IN    VARCHAR2  default null, --(20),
      p_Document_Revision_Num            IN    NUMBER  default null,
      p_Document_Line_Id                 IN    NUMBER  default null,
      p_Document_Line_Number             IN    NUMBER  default null,
      p_Document_Line_Location_Id        IN    NUMBER  default null,
      p_Document_Shipment_Number         IN    NUMBER  default null,
      p_Document_Distribution_id         IN    NUMBER  default null,
      p_Document_Distribution_Number     IN    NUMBER  default null,
      p_Parent_Line_Location_Id          IN    NUMBER  default null,
      p_Old_Quantity                     IN    NUMBER  default null,
      p_New_Quantity                     IN    NUMBER  default null,
      p_Old_Promised_Date                IN    DATE  default null,
      p_New_Promised_Date                IN    DATE  default null,
      p_Old_Supplier_Part_Number         IN    VARCHAR2  default null, --(25),
      p_New_Supplier_Part_Number         IN    VARCHAR2  default null, --(25),
      p_Old_Price                        IN    NUMBER  default null,
      p_New_Price                        IN    NUMBER  default null,
      p_Old_Supplier_Reference_Num       IN    VARCHAR2  default null, --(30),
      p_New_Supplier_Reference_Num       IN    VARCHAR2  default null, --(30),
      p_From_Header_id                   IN    NUMBER  default null,
      p_Recoverable_Tax                  IN    NUMBER  default null,
      p_Non_recoverable_tax              IN    NUMBER  default null,
      p_Ship_To_Location_id              IN    NUMBER  default null,
      p_Ship_To_Organization_Id          IN    NUMBER  default null,
      p_Old_Need_By_Date                 IN    DATE  default null,
      p_New_Need_By_Date                 IN    DATE  default null,
      p_Approval_Required_Flag           IN    VARCHAR2  default null, --(1),
      p_Parent_Change_request_Id         IN    NUMBER  default null,
      p_Requester_id                     IN    NUMBER  default null,
      p_Old_Supplier_Order_Number        IN    VARCHAR2  default null, --(25),
      p_New_Supplier_Order_Number        IN    VARCHAR2  default null, --(25),
      p_Old_Supplier_Order_Line_Num      IN    VARCHAR2  default null, --(25),
      p_New_Supplier_Order_Line_Num      IN    VARCHAR2  default null  , --(25),
      p_Additional_changes               IN    VARCHAR2  default null, --(2000),
      p_old_Start_date                   IN    DATE   default null,
      p_new_Start_date                   IN    DATE   default null,
      p_old_Expiration_date              IN    DATE   default null,
      p_new_Expiration_date              IN    DATE   default null,
      p_old_Amount                       IN    NUMBER  default null,
      p_new_Amount                       IN    NUMBER  default null,
      p_SUPPLIER_DOC_REF                 IN    varchar2  default null, --(256),
      p_SUPPLIER_LINE_REF                IN    varchar2  default null, --(256),
      p_SUPPLIER_SHIPMENT_REF            IN    varchar2   default null, --(256)
/* << Complex work changes for R12 >>*/
      p_NEW_PROGRESS_TYPE                IN  varchar2   default null,
      p_NEW_PAY_DESCRIPTION              IN  varchar2   default null

 ) return pos_chg_rec;

 function getMaxShipmentNum (
 	p_po_line_id IN NUMBER)
 	return NUMBER;

 function getLastUpdateDate (
 	p_header_id IN NUMBER,
 	p_release_id IN NUMBER)
	return DATE;
 procedure validate_shipment_cancel (
             p_po_header_id           IN  number,
             p_po_release_id          IN  number,
             p_po_change_requests     IN  pos_chg_rec_tbl,
             x_pos_errors             OUT NOCOPY POS_ERR_TYPE,
             x_ret_sts                OUT NOCOPY VARCHAR2
             );

procedure validate_ship_inv_cancel (
             p_po_header_id           IN  number,
             p_po_change_requests     IN  pos_chg_rec_tbl,
             x_pos_errors             OUT NOCOPY POS_ERR_TYPE,
             x_ret_sts		      OUT NOCOPY VARCHAR2
             );

/*Added for bug#14155598*/
procedure IS_ASN_EXIST(
             p_po_header_id           IN  number,
             p_po_release_id          IN  number,
             p_po_change_requests     IN  pos_chg_rec_tbl,
             x_pos_errors             OUT NOCOPY POS_ERR_TYPE,
             x_ret_sts                OUT NOCOPY VARCHAR2
             );
/*For bug:18095918 */
procedure validate_shipment_split (
            p_po_header_id           IN  number,
            p_po_release_id          IN  number,
            p_po_line_location_id    IN  number,
            x_pos_errors             OUT NOCOPY POS_ERR_TYPE,
            x_ret_sts		     OUT NOCOPY varchar2
            );


 END PO_CHG_REQUEST_PVT;

/
