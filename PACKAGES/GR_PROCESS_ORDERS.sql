--------------------------------------------------------
--  DDL for Package GR_PROCESS_ORDERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_PROCESS_ORDERS" AUTHID CURRENT_USER AS
/*$Header: GRPORDRS.pls 115.20 2003/08/20 20:45:54 methomas ship $*/

/*
**	Global Alpha variables
*/
G_PKG_NAME			    CONSTANT VARCHAR2(30) := 'GR_PROCESS_DOCUMENTS';
G_BATCH_NUMBER		            GR_SELECTION_HEADER.batch_no%TYPE;
G_RECIPIENT_CODE	            GR_RECIPIENT_INFO.recipient_code%TYPE;
G_ITEM_CODE			    GR_ITEM_GENERAL.item_code%TYPE;
G_SHIPMENT_NUMBER     	            OP_BILL_LAD.bol_no%TYPE;

G_NO_CUSTOMER_PRINT	 	    VARCHAR2(1);
G_DEFAULT_COUNTRY	            FND_TERRITORIES.territory_code%TYPE;
G_DEFAULT_DOCUMENT	 	    GR_DOCUMENT_CODES.document_code%TYPE;
G_DEFAULT_ORGN	                    SY_ORGN_MST.orgn_code%TYPE;
G_DEFAULT_WHSE		            MTL_PARAMETERS.process_orgn_code%TYPE;
G_DEFAULT_ORGID		            MTL_PARAMETERS.organization_id%TYPE;

G_CUST_NAME			    OP_CUST_MST.cust_name%TYPE;
G_ADDR1				    SY_ADDR_MST_V.addr1%TYPE;
G_ADDR2				    SY_ADDR_MST_V.addr2%TYPE;
G_ADDR3				    SY_ADDR_MST_V.addr3%TYPE;
G_ADDR4				    SY_ADDR_MST_V.addr4%TYPE;
G_STATE_CODE			    SY_ADDR_MST_V.state_code%TYPE;
G_COUNTRY_CODE			    SY_ADDR_MST_V.country_code%TYPE;
G_POSTAL_CODE			    SY_ADDR_MST_V.postal_code%TYPE;

/*
**	Global numeric variables
*/
G_ORDER_NUMBER        	OP_ORDR_DTL.order_id%TYPE;
G_ORDER_LINE			GR_ORDER_INFO_V.line_no%TYPE;
G_LINE_NUMBER			GR_WORK_WORKSHEETS.text_line_number%TYPE;
G_SESSION_ID			GR_WORK_WORKSHEETS.session_id%TYPE;

/*  17-Jun-2003   Mercy Thomas BUG 2932007 - Added the following Global Variables for Document Management  */

G_ORDER_NO              GR_ORDER_INFO_V.order_no%TYPE;
G_DOC_ITEM_CODE         GR_ITEM_GENERAL.ITEM_CODE%TYPE;
G_REPORT_TYPE           NUMBER:=0;
G_COVER_LETTER          VARCHAR2(2) := 'N';

/*  17-Jun-2003   Mercy Thomas BUG 2932007 - End of code changes */

/*
**	Global concurrent request return values
*/
G_PRINT_STATUS				BOOLEAN;
G_CONCURRENT_ID				NUMBER;

/*
**	Global cursors
**
**	Get the batch header information
*/
CURSOR g_get_batch_status
 IS
   SELECT	sh.status,
            sh.order_from,
			   sh.order_to,
			   sh.shipment_from,
			   sh.shipment_to,
			   sh.shipment_date_from,
			   sh.shipment_date_to,
			   sh.orgn_code,
			   sh.whse_code,
			   sh.territory_code
   FROM		gr_selection_header sh
   WHERE	   sh.batch_no = g_batch_number;
GlobalBatchHeader		g_get_batch_status%ROWTYPE;
/*
**	Get the item general information
*/
CURSOR g_get_item_safety
 IS
   SELECT	ig1.primary_cas_number,
            ig1.formula_source_indicator,
			   ig1.ingredient_flag,
			   ig1.print_ingredient_phrases_flag
   FROM		gr_item_general ig1
   WHERE	   ig1.item_code = g_item_code;
GlobalSafetyRecord			g_get_item_safety%ROWTYPE;
/*
**	Get the generic item information
*/
CURSOR g_get_generic_item
 IS
   SELECT	ig1.primary_cas_number,
			   ig1.formula_source_indicator,
			   ig1.ingredient_flag,
			   ig1.print_ingredient_phrases_flag,
			   ig1.item_code,
			   gi.item_no,
			   gi.default_document_name_flag
   FROM		gr_item_general ig1,
			   gr_generic_items_b gi
   WHERE	   gi.item_no = g_item_code
   AND		gi.item_code = ig1.item_code;
GlobalGenericRecord		g_get_generic_item%ROWTYPE;
/*
**	Get the recipient information
*/
CURSOR g_get_recipient
 IS
   SELECT	ri.recipient_code,
			ri.recipient_name,
   			ri.document_code,
            ri.document_print_frequency,
			ri.disclosure_code,
			ri.region_code,
			ri.territory_code,
			ri.shipping_address,
			ri.invoice_address,
			ri.additional_address_flag,
			cp.language
   FROM		gr_recipient_info ri,
			gr_country_profiles cp
   WHERE	ri.recipient_code = g_recipient_code
   AND		ri.territory_code = cp.territory_code;
GlobalRecipient			g_get_recipient%ROWTYPE;
/*
**	Get the country profile info
*/
CURSOR g_get_country_profile
 IS
   SELECT	cp.label_code_exposure,
			   cp.label_code_toxic,
			   cp.disclosure_code,
			   cp.language,
			   cp.document_code
   FROM		gr_country_profiles cp
   WHERE	   cp.territory_code = g_default_country;
GlobalCountryRecord		g_get_country_profile%ROWTYPE;
/*   Bug #2286375 GK
**	Get the recipient other addresses
*/
CURSOR g_get_other_addresses
 IS
   SELECT	ra.addr_id,
			am.addr1
   FROM		gr_recipient_addresses ra,
			sy_addr_mst_v am
   WHERE	ra.recipient_code = g_recipient_code
   AND		ra.addr_id = am.addr_id;
GlobalOtherAddrRecord	g_get_other_addresses%ROWTYPE;


/*
**	Get the region language details
*/
CURSOR g_get_region_language
 IS
   SELECT	rl.language
   FROM		gr_region_languages rl
   WHERE	rl.region_code = GlobalRecipient.region_code;
GlobalRgnLangRecord		g_get_region_language%ROWTYPE;

/*
**		Process_all_flag values: 0 - Do not process all.
**								 1 - Process all, accept selections.
**								 2 - Rerun the batch.
**								 3 - Restart the batch.
*/
   PROCEDURE Build_OPM_Selections
				(errbuf OUT NOCOPY  VARCHAR2,
				 retcode OUT NOCOPY  VARCHAR2,
   		    p_commit IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
				 p_batch_number IN NUMBER,
				 p_process_all_flag IN NUMBER,
				 p_printer IN VARCHAR2,
				 p_user_print_style IN VARCHAR2,
				 p_number_of_copies IN NUMBER,
				 p_return_status OUT NOCOPY  VARCHAR2,
				 p_msg_count OUT NOCOPY  NUMBER,
				 p_msg_data OUT NOCOPY  VARCHAR2);
   PROCEDURE Process_Selections
				(errbuf OUT NOCOPY  VARCHAR2,
				 retcode OUT NOCOPY  VARCHAR2,
				 p_commit IN VARCHAR2,
				 p_called_by_form IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
				 p_batch_number IN NUMBER,
				 p_process_all_flag IN NUMBER,
				 p_printer IN VARCHAR2,
				 p_user_print_style IN VARCHAR2,
				 p_number_of_copies IN NUMBER,
				 x_return_status OUT NOCOPY  VARCHAR2,
				 x_msg_count OUT NOCOPY  NUMBER,
				 x_msg_data OUT NOCOPY  VARCHAR2);
   PROCEDURE Update_Dispatch_History
				(errbuf OUT NOCOPY  VARCHAR2,
				 retcode OUT NOCOPY  VARCHAR2,
				 p_commit IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
				 p_batch_number IN NUMBER,
				 x_return_status OUT NOCOPY  VARCHAR2,
				 x_msg_count OUT NOCOPY  NUMBER,
				 x_msg_data OUT NOCOPY  VARCHAR2);
   PROCEDURE Print_Recipients
				(errbuf OUT NOCOPY  VARCHAR2,
				 retcode OUT NOCOPY  VARCHAR2,
				 p_recipient_from IN VARCHAR2,
				 p_recipient_to IN VARCHAR2,
				 p_item_code_from IN VARCHAR2,
				 p_item_code_to IN VARCHAR2,
				 p_changed_after IN VARCHAR2,
				 p_printer IN VARCHAR2,
				 p_user_print_style IN VARCHAR2,
				 p_number_of_copies IN NUMBER,
				 p_items_to_print IN VARCHAR2,
				 x_return_status OUT NOCOPY  VARCHAR2,
				 x_msg_count OUT NOCOPY  NUMBER,
				 x_msg_data OUT NOCOPY  VARCHAR2);
   PROCEDURE Insert_Selection_Row
				(p_message_code IN VARCHAR2,
				 p_token_name IN VARCHAR2,
				 p_token_value IN VARCHAR2,
				 p_order_id IN NUMBER,
				 p_order_line_number IN NUMBER,
				 p_document_code IN VARCHAR2,
				 p_print_flag IN VARCHAR2,
				 p_cust_no IN VARCHAR2,
				 p_shipment_no IN VARCHAR2,
				 x_return_status OUT NOCOPY  VARCHAR2);
   PROCEDURE Check_Selected_Line
				(x_return_status OUT NOCOPY  VARCHAR2,
                 x_msg_count OUT NOCOPY  NUMBER,
                 x_msg_data OUT NOCOPY  VARCHAR2);
   PROCEDURE Read_And_Print_Cover_Letter
				(p_language_code IN VARCHAR2,
				 p_item_code IN VARCHAR2,
				 p_recipient_code IN VARCHAR2,
				 p_print_address IN VARCHAR2,
				 p_order_no IN NUMBER,
				 p_other_addr_id IN NUMBER,
				 x_return_status OUT NOCOPY  VARCHAR2);
   PROCEDURE Print_Document_Selection
                (p_document_code IN VARCHAR2,
				 p_item_code IN VARCHAR2,
				 p_language_code IN VARCHAR2,
				 p_disclosure_code IN VARCHAR2,
				 x_return_status OUT NOCOPY  VARCHAR2);
   PROCEDURE Insert_Work_Row
				(p_item_code IN VARCHAR2,
				 p_print_font IN VARCHAR2,
				 p_print_size IN NUMBER,
				 p_text_line IN VARCHAR2,
				 p_line_type IN VARCHAR2,
				 x_return_status OUT NOCOPY  VARCHAR2);
   PROCEDURE Submit_Print_Request
		      (p_printer IN VARCHAR2,
				 p_user_print_style IN VARCHAR2,
				 p_number_of_copies IN NUMBER,
				 p_default_document IN VARCHAR2,
				 p_language_code IN VARCHAR2,
				 x_return_status OUT NOCOPY  VARCHAR2);
   PROCEDURE Handle_Error_Messages
				(p_message_code IN VARCHAR2,
				 p_token_name IN VARCHAR2,
				 p_token_value IN VARCHAR2,
				 x_msg_count IN OUT NOCOPY  NUMBER,
				 x_msg_data IN OUT NOCOPY  VARCHAR2,
				 x_return_status OUT NOCOPY  VARCHAR2);
END GR_PROCESS_ORDERS;

 

/
