--------------------------------------------------------
--  DDL for Package IBE_LEAD_IMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_LEAD_IMPORT_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVLIMS.pls 120.0 2005/05/30 03:24:56 appldev noship $ */

  Type t_genref is REF CURSOR;

  Type G_Leads_Rec is Record
  (
      Quote_Header_ID	      ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID%TYPE,
      phone_id		      hz_contact_points.contact_point_id%TYPE,
      party_id		      hz_parties.party_id%TYPE,
      party_name              hz_parties.party_name%TYPE,
      party_type              hz_parties.party_type%TYPE,
      party_site_id	      hz_party_sites.party_site_id%TYPE,
      rel_party_id	      hz_parties.party_id%TYPE,
      org_contact_id          hz_org_contacts.org_contact_ID%TYPE,
      contact_role_code	      VARCHAR2(30),
      notes                   varchar2(2000),
      currency_code	      VARCHAR2(15),
      order_id		      NUMBER,
      order_num               oe_order_headers.order_number%TYPE,
      order_creation_date     oe_order_headers.creation_date%TYPE,
      promo_code              ams_source_codes.SOURCE_CODE%TYPE,
      total_amount            NUMBER,
      lead_description        varchar2(2000),
      SOURCE_PRIMARY_REFERENCE varchar2(240),
      SOURCE_SECONDARY_REFERENCE varchar2(240),
      SOURCE_PROMOTION_ID 	ASO_QUOTE_HEADERS_ALL.marketing_source_code_id%type
  );

  Type G_Lead_Line_Rec is Record
  (
      quote_header_id	      ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID%TYPE,
      inventory_item_id	      ASO_QUOTE_LINES_ALL.INVENTORY_ITEM_ID%TYPE,
      organization_id	      ASO_QUOTE_LINES_ALL.INVENTORY_ITEM_ID%TYPE,
      uom_code		      ASO_QUOTE_LINES_ALL.UOM_CODE%TYPE,
      quantity		      ASO_QUOTE_LINES_ALL.QUANTITY%TYPE,
      part_no		      Varchar2(255),
      product_description     Varchar2(2000),
      line_price              ASO_QUOTE_LINES_ALL.LINE_QUOTE_PRICE%TYPE,
      promotion_id            ASO_QUOTE_LINES_ALL.marketing_source_code_id%type
  );

  Type G_Lead_Line_Tbl is Table of G_Lead_Line_Rec Index By Binary_Integer;

  G_ORDER_LEAD CONSTANT VARCHAR2(10) := 'ORDER';
  G_QUOTE_LEAD CONSTANT VARCHAR2(10) := 'QUOTE';

  G_COMPLETE_IMPORT CONSTANT VARCHAR2(15) := 'COMPLETE';
  G_INCREMENTAL_IMPORT CONSTANT VARCHAR2(15) := 'INCREMENTAL';

  procedure write_log
  (
      p_status       IN NUMBER,
      p_lead_type    IN VARCHAR2,
      p_begin_date   IN DATE,
      p_end_date     IN DATE,
      p_import_mode  IN VARCHAR2,
      x_log_id	     OUT NOCOPY NUMBER
  );

  procedure update_log
  (
      p_status	     IN NUMBER,
      p_log_id	     IN NUMBER,
      p_num_success  IN NUMBER,
      p_num_failed   IN NUMBER,
      p_num_total    IN NUMBER,
      p_elapsed_time IN NUMBER
  );

  procedure insert_log_details
  (
      p_message	     IN VARCHAR2,
      p_header_rec   IN G_LEADS_REC,
      p_status_flag  IN VARCHAR2,
      p_purge_flag   IN VARCHAR2,
      p_log_id	     IN NUMBER
  );

  procedure parseInput
  (
	 p_inString IN VARCHAR2,
	 p_Type     IN VARCHAR2,
	 p_keyString IN VARCHAR2,
	 p_number   IN NUMBER,
	 x_QueryString OUT NOCOPY VARCHAR2
   );

  procedure get_Quotes_records
 (
      p_begin_date	IN DATE,
      p_end_date	IN DATE,
      p_party_number    IN VARCHAR2,
      p_promo_code      IN VARCHAR2,
      p_role_exclusion  IN VARCHAR2,
      x_quote_records   OUT NOCOPY t_genref
  );

  procedure get_Quote_Line_Records
  (
      p_quote_header_id IN NUMBER,
      x_quote_lines     OUT NOCOPY t_genref
  );

  procedure get_Order_Records
  (
      p_begin_date	IN DATE,
      p_end_date	IN DATE,
      p_party_number    IN VARCHAR2,
      p_promo_code      IN VARCHAR2,
      p_role_exclusion  IN VARCHAR2,
      x_order_records   OUT NOCOPY t_genref
  );

  procedure get_Order_line_Records
  (
      p_order_header_id	IN NUMBER,
      x_Order_lines     OUT NOCOPY t_genref
  );

  procedure get_date_period
  (
      p_lead_type  IN VARCHAR2,
      p_begin_date IN  DATE,
      p_end_date   IN  DATE,
      x_import_mode OUT NOCOPY VARCHAR2,
      x_begin_Date OUT NOCOPY DATE,
      x_end_date   OUT NOCOPY DATE
  );

  procedure create_order_leads
  (
      p_retcode	   		OUT NOCOPY NUMBER,
      p_errmsg	   		OUT NOCOPY VARCHAR2,
      p_begin_date 		IN VARCHAR2,
      p_end_date   		IN VARCHAR2,
      p_debug_flag 		IN VARCHAR2,
      p_purge_flag 		IN VARCHAR2,
      p_write_detail_log 	IN VARCHAR2,
      p_party_number            IN VARCHAR2,
      p_promo_code              IN VARCHAR2,
      p_role_exclusion          IN VARCHAR2
  );

  procedure create_quote_leads
  (
      p_retcode    		OUT NOCOPY NUMBER,
      p_errmsg     		OUT NOCOPY VARCHAR2,
      p_begin_date 		IN VARCHAR2,
      p_end_date   		IN VARCHAR2,
      p_debug_flag 		IN VARCHAR2,
      p_purge_flag 		IN VARCHAR2,
      p_write_detail_log 	IN VARCHAR2,
      p_party_number            IN VARCHAR2,
      p_promo_code              IN VARCHAR2,
      p_role_exclusion          IN VARCHAR2

  );

  procedure process_sales_lead_import(
	p_header_rec		IN G_LEADS_REC,
	p_lines_rec_tbl		IN G_LEAD_LINE_TBL,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_data		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER
  );

  procedure create_sales_lead(
      p_header_rec              IN G_LEADS_REC,
      p_lines_rec_tbl           IN G_LEAD_LINE_TBL,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_data                OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_sales_lead_id           OUT NOCOPY NUMBER,
      x_sales_lead_line_out_tbl OUT NOCOPY AS_SALES_LEADS_PUB.SALES_LEAD_LINE_OUT_TBL_TYPE,
      x_sales_lead_cnt_out_tbl  OUT NOCOPY AS_SALES_LEADS_PUB.SALES_LEAD_CNT_OUT_TBL_TYPE
  );

  procedure create_LeadAndNotes(
      p_sales_lead_id		IN  NUMBER,
      p_lead_note		IN  VARCHAR2,
      p_party_id		IN  NUMBER,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_data                OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER
  );

  procedure rank_sales_lead(
      p_sales_lead_id		IN  NUMBER,
      x_return_Status           OUT NOCOPY VARCHAR2,
      x_msg_data                OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_rank_id                 OUT NOCOPY NUMBER,
      x_score                   OUT NOCOPY NUMBER
  );

  /*procedure Assign_Sales_Team(
      p_sales_lead_id           IN  NUMBER,
      x_return_status           OUT VARCHAR2,
      x_msg_data                OUT VARCHAR2,
      x_msg_count               OUT NUMBER,
      x_access_id               OUT NUMBER
  );


  procedure create_Sales_Team(
      p_sales_lead_id		IN  NUMBER,
      p_party_id		IN  NUMBER,
      p_party_site_id		IN  NUMBER,
      x_return_status           OUT VARCHAR2,
      x_msg_data                OUT VARCHAR2,
      x_msg_count               OUT NUMBER,
      x_access_id               OUT NUMBER
  );*/

  procedure create_interest(
      p_party_id		IN NUMBER,
      p_party_site_id		IN NUMBER,
      p_lines_tbl		IN G_LEAD_LINE_TBL,
      p_contact_id		IN  NUMBER,
      p_party_type		IN  VARCHAR2,
      x_return_status		OUT NOCOPY VARCHAR2,
      x_msg_data		OUT NOCOPY VARCHAR2,
      x_msg_count		OUT NOCOPY NUMBER
  );

  procedure Build_Sales_Team(
      p_sales_lead_id		IN NUMBER,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_data                OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER
  );

  procedure Import_Quote_Lead(
      p_quote_header_id 	IN NUMBER,
      x_return_status		OUT NOCOPY VARCHAR2,
      X_msg_data		OUT NOCOPY VARCHAR2,
      x_msg_count		OUT NOCOPY NUMBER
  );

  procedure Import_Order_Lead(
      p_quote_header_id		IN NUMBER,
      x_return_status		OUT NOCOPY VARCHAR2,
      x_msg_data		OUT NOCOPY VARCHAR2,
      x_msg_count		OUT NOCOPY NUMBER
  );

  procedure print_Parameter(
	p_begin_date		IN VARCHAR2,
	p_end_date		IN VARCHAR2,
	p_debug_flag		IN VARCHAR2,
	p_purge_flag		IN VARCHAR2,
	p_write_detail_log	IN VARCHAR2);

   procedure printOutput( p_message IN VARCHAR2);

   procedure sendEmail(
	p_lead_type		IN VARCHAR2,
	p_status		IN VARCHAR2,
	p_log_id		IN VARCHAR2,
	p_num_total		IN NUMBER,
	p_num_failed		IN NUMBER,
	p_num_success		IN NUMBER,
	p_begin_date		IN DATE,
	p_end_date		IN DATE,
	p_elapsed_time		IN NUMBER,
	p_debug_flag		IN VARCHAR2,
	p_purge_flag		IN VARCHAR2,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2);
end;

 

/
