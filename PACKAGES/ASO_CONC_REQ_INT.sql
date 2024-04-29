--------------------------------------------------------
--  DDL for Package ASO_CONC_REQ_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_CONC_REQ_INT" AUTHID CURRENT_USER as
/* $Header: asoiprqs.pls 120.1 2005/06/29 12:35:09 appldev ship $*/

Procedure Submit_price_tax_req(
		P_Api_Version_Number	IN	NUMBER,
		P_Init_Msg_List          IN	VARCHAR2       := FND_API.G_FALSE,
		p_qte_header_rec		IN	ASO_QUOTE_PUB.Qte_Header_Rec_Type,
		p_control_rec			IN	ASO_QUOTE_PUB.Control_Rec_Type :=ASO_QUOTE_PUB.G_Miss_Control_Rec,
		x_request_id		 OUT NOCOPY /* file.sql.39 change */  Number,
		x_return_status	 OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
		x_msg_count		 OUT NOCOPY /* file.sql.39 change */  Number,
		x_msg_data		 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
           );

procedure batch_pricing(
          errbuf				 OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
		retcode				 OUT NOCOPY /* file.sql.39 change */  Number,
  		p_quote_header_id			IN	Number,
          p_header_pricing_event		IN	VARCHAR2,
		p_pricing_request_type		IN	VARCHAR2,
		p_calculate_tax_flag		IN	VARCHAR2,
		p_calc_freight_charge_flag	IN	VARCHAR2,
		p_price_mode				IN	VARCHAR2,
		p_auto_version_flag			IN	VARCHAR2,
          p_copy_task_flag			IN	VARCHAR2,
          p_copy_notes_flag			IN	VARCHAR2,
          p_copy_att_flag			IN	VARCHAR2,
		p_PRICING_STATUS_INDICATOR	IN	VARCHAR2,
		p_TAX_STATUS_INDICATOR		IN	VARCHAR2,
          p_DEPENDENCY_FLAG             IN   VARCHAR2,
          p_DEFAULTING_FLAG             IN   VARCHAR2,
          p_DEFAULTING_FWK_FLAG         IN   VARCHAR2,
          p_APPLICATION_TYPE_CODE       IN   VARCHAR2
          );

Procedure  Cancel_price_tax_req(
		P_Api_Version_Number     IN   NUMBER,
		P_Init_Msg_List          IN   VARCHAR2       := FND_API.G_FALSE,
          p_qte_header_rec		IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
          x_return_status	 OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
	     x_msg_count		 OUT NOCOPY /* file.sql.39 change */   Number,
          x_msg_data		 OUT NOCOPY /* file.sql.39 change */   VARCHAR2
          );

Procedure Get_Workflow_Role(
          p_user_id                    IN   Number,
          x_wf_role                    OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
          x_notification_preference    OUT NOCOPY /* file.sql.39 change */   VARCHAR2
          );

procedure Update_price_req_id(
          p_quote_header_id            IN   Number
          );

Procedure Send_notification(
          p_quote_header_id            IN   Number,
          p_subject       	         IN   VARCHAR2,
          p_body          	         IN   VARCHAR2
          );

Procedure Lock_Exists (
          p_quote_header_id            IN 	Number,
	     x_status	                   OUT NOCOPY /* file.sql.39 change */ 	 VARCHAR2
          );

PROCEDURE quote_detail_url (
          p_quote_header_id            IN   Number,
          p_display_type               IN   VARCHAR2,
          x_document                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2);

PROCEDURE qte_detail_url (
    document_id                 IN       VARCHAR2,
    display_type                IN       VARCHAR2,
    document                    IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    document_type               IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );

END ASO_CONC_REQ_INT;


 

/
