--------------------------------------------------------
--  DDL for Package OE_ELECMSGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ELECMSGS_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVELMS.pls 120.2 2005/09/15 04:27:04 kmuruges ship $ */

G_PKG_NAME VARCHAR2(15) := 'OE_ELECMSGS_PVT';

Type Elec_Msgs_Summary_Type IS RECORD
     (  order_source_id		number,
	orig_sys_document_Ref 	varchar2(50),
	sold_to_org_id		number,
	order_number		number,
        order_type_id           number,
     	num_msgs		number,
	creation_date		date,
	last_update_date	date,
	last_transaction_type	varchar2(30),
        last_transaction_message varchar2(2000),
        last_transaction_status varchar2(240),
        org_id number);

Type Elec_Msgs_Summary_Tbl IS table Of Elec_Msgs_Summary_Type index by binary_integer;

PROCEDURE do_query (p_elec_msgs_tbl	   IN OUT NOCOPY /* file.sql.39 change */ Elec_Msgs_Summary_Tbl,
                   p_order_source_id       IN     NUMBER,
                   p_orig_sys_document_ref IN     VARCHAR2,
                   p_sold_to_org_id        IN     NUMBER,
                   p_transaction_type      IN     VARCHAR2,
                   p_start_date_from       IN     DATE,
                   p_start_date_to         IN     DATE,
                   p_update_date_from      IN     DATE,
                   p_update_date_to        IN     DATE,
                   p_message_status_code   IN     VARCHAR2
);

PROCEDURE Create_History_Entry (
          p_order_source_id	IN	NUMBER,
          p_sold_to_org_id	IN	NUMBER,
          p_orig_sys_document_ref   IN	VARCHAR2,
          p_transaction_type	IN	VARCHAR2,
          p_document_id 	IN	NUMBER,
          p_parent_document_id 	IN	NUMBER DEFAULT NULL,
          p_org_id		IN	NUMBER DEFAULT NULL,
          p_change_sequence	IN	VARCHAR2 DEFAULT NULL,
          p_itemtype    	IN	VARCHAR2 DEFAULT NULL,
          p_itemkey		IN	VARCHAR2 DEFAULT NULL,
          p_order_number	IN	NUMBER	DEFAULT NULL,
          p_order_type_id	IN	NUMBER	DEFAULT NULL,
          p_status		IN	VARCHAR2 DEFAULT NULL,
          p_message_text	IN	VARCHAR2 DEFAULT NULL,
          p_request_id          IN      NUMBER DEFAULT NULL,
          p_header_id           IN      NUMBER DEFAULT NULL,
          p_document_disposition IN     VARCHAR2 DEFAULT NULL,
          p_last_update_itemkey IN     VARCHAR2 DEFAULT NULL,
          x_return_status       OUT NOCOPY VARCHAR2);

PROCEDURE Update_History_Entry (
          p_order_source_id	IN	NUMBER,
          p_sold_to_org_id	IN	NUMBER,
          p_orig_sys_document_ref   IN	VARCHAR2,
          p_transaction_type	IN	VARCHAR2,
          p_document_id 	IN	NUMBER,
          p_parent_document_id 	IN	NUMBER DEFAULT NULL,
          p_org_id		IN	NUMBER DEFAULT NULL,
          p_change_sequence	IN	VARCHAR2 DEFAULT NULL,
          p_itemtype    	IN	VARCHAR2 DEFAULT NULL,
          p_itemkey		IN	VARCHAR2 DEFAULT NULL,
          p_order_number	IN	NUMBER	DEFAULT NULL,
          p_order_type_id	IN	NUMBER	DEFAULT NULL,
          p_status		IN	VARCHAR2 DEFAULT NULL,
          p_message_text	IN	VARCHAR2 DEFAULT NULL,
          p_request_id          IN      NUMBER DEFAULT NULL,
          p_header_id           IN      NUMBER DEFAULT NULL,
          p_document_disposition IN     VARCHAR2 DEFAULT NULL,
          p_last_update_itemkey IN     VARCHAR2 DEFAULT NULL,
          x_return_status       OUT NOCOPY VARCHAR2);

FUNCTION  Find_History_Entry (
          p_order_source_id     IN      NUMBER,
          p_orig_sys_document_ref IN    VARCHAR2,
          p_sold_to_org_id      IN      NUMBER,
          p_transaction_type    IN      VARCHAR2,
          p_document_id         IN      NUMBER,
          x_last_itemkey        OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
          x_last_request_id     OUT NOCOPY /* file.sql.39 change */     NUMBER)
RETURN BOOLEAN;

FUNCTION  Find_Parent_Document_Id (
          p_order_source_id     IN      NUMBER,
          p_orig_sys_document_ref IN    VARCHAR2,
          p_sold_to_org_id      IN      NUMBER,
          p_org_id              IN      NUMBER)
RETURN NUMBER;

PROCEDURE Open_Interface_Purge_Conc_Pgm
(  errbuf                          	OUT NOCOPY /* file.sql.39 change */ VARCHAR,
   retcode                         	OUT NOCOPY /* file.sql.39 change */ NUMBER,
   p_operating_unit                     IN  NUMBER DEFAULT NULL,
   p_view_name			        IN  VARCHAR2,
--   p_sold_to_org_id                   	IN  NUMBER,
   p_customer_number                    IN  NUMBER,
   p_order_source_id			IN  NUMBER,
   p_default_org_id                     IN  NUMBER DEFAULT NULL,
   p_process_null_org_id                IN  VARCHAR2 DEFAULT NULL,
   p_orig_sys_document_ref_from         IN  VARCHAR2,
   p_orig_sys_document_ref_to           IN  VARCHAR2,
   p_purge_child_tables                 IN  VARCHAR2 DEFAULT NULL
 );

PROCEDURE OEEM_SELECTOR
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
);

PROCEDURE Create_Or_Update_Hist_WF (
          p_itemtype            IN	VARCHAR2,
	  p_itemkey    		IN	VARCHAR2,
	  p_actid               IN      NUMBER,
	  p_funcmode            IN      VARCHAR2,
	  p_x_result            IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2);

PROCEDURE Initialize_EM_Access_List (X_Access_List OUT NOCOPY OE_GLOBALS.ACCESS_LIST);

PROCEDURE Add_Access(Function_Name VARCHAR2);

END OE_ELECMSGS_PVT;

 

/
