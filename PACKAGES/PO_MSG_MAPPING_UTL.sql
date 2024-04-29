--------------------------------------------------------
--  DDL for Package PO_MSG_MAPPING_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_MSG_MAPPING_UTL" AUTHID CURRENT_USER AS
/* $Header: PO_MSG_MAPPING_UTL.pls 120.1 2006/01/31 10:00 jinwang noship $ */

-- constants for column_value_key and tokenx_value_keys in type msg_rec_type
-- header level keys
c_rate_type CONSTANT VARCHAR2(30) := 'C_RATE_TYPE';
c_agent_name CONSTANT VARCHAR2(30) := 'C_AGENT_NAME';
c_ship_to_location CONSTANT VARCHAR2(30) := 'C_SHIP_TO_LOCATION';
c_bill_to_location CONSTANT VARCHAR2(30) := 'C_BILL_TO_LOCATION';
c_payment_terms CONSTANT VARCHAR2(30) := 'C_PAYMENT_TERMS';
c_vendor_name CONSTANT VARCHAR2(30) := 'C_VENDOR_NAME';
c_vendor_site_code CONSTANT VARCHAR2(30) := 'C_VENDOR_SITE_CODE';
c_vendor_contact CONSTANT VARCHAR2(30) := 'C_VENDOR_CONTACT';
c_style_display_name CONSTANT VARCHAR2(30) := 'C_STYLE_DISPLAY_NAME';
c_from_rfq_num CONSTANT VARCHAR2(30) := 'C_FROM_RFQ_NUM';

-- line level keys
c_item CONSTANT VARCHAR2(30) := 'C_ITEM';
c_item_desc CONSTANT VARCHAR2(30) := 'C_ITEM_DESC';
c_job_business_group_name CONSTANT VARCHAR2(30) := 'C_JOB_BUSINESS_GROUP_NAME';
c_job_name CONSTANT VARCHAR2(30) := 'C_JOB_NAME';
c_category CONSTANT VARCHAR2(30) := 'C_CATEGORY';
c_ip_category CONSTANT VARCHAR2(30) := 'C_IP_CATEGORY';
c_uom_code CONSTANT VARCHAR2(30) := 'C_UOM_CODE';
c_line_type CONSTANT VARCHAR2(30) := 'C_LINE_TYPE';
c_un_number CONSTANT VARCHAR2(30) := 'C_UN_NUMBER';
c_hazard_class CONSTANT VARCHAR2(30) := 'C_HAZARD_CLASS';
c_template_name CONSTANT VARCHAR2(30) := 'C_TEMPLATE_NAME';
c_amount CONSTANT VARCHAR2(30) := 'C_AMOUNT';
c_unit_price CONSTANT VARCHAR2(30) := 'C_UNIT_PRICE';
c_line_num CONSTANT VARCHAR2(30) := 'C_LINE_NUM';
c_quantity CONSTANT VARCHAR2(30) := 'C_QUANTITY';
c_item_revision CONSTANT VARCHAR2(30) := 'C_ITEM_REVISION';
c_ga_flag CONSTANT VARCHAR2(30) := 'C_GA_FLAG';
c_negotiated_flag CONSTANT VARCHAR2(30) := 'C_NEGOTIATED_FLAG';
c_created_language CONSTANT VARCHAR2(30) := 'C_CREATED_LANGUAGE';

-- line location level keys
c_ship_to_organization_code CONSTANT VARCHAR2(30) := 'C_SHIP_TO_ORGANIZATION_CODE';
c_loc_ship_to_location CONSTANT VARCHAR2(30) := 'C_LOC_SHIP_TO_LOCATION';
c_receiving_routing CONSTANT VARCHAR2(30) := 'C_RECEIVING_ROUTING';
c_tax_code_id CONSTANT VARCHAR2(30) := 'C_TAX_CODE_ID';
c_price_discount CONSTANT VARCHAR2(30) := 'C_PRICE_DISCOUNT';
c_style_id CONSTANT VARCHAR2(30) := 'C_STYLE_ID';
c_start_date CONSTANT VARCHAR2(30) := 'C_START_DATE';

TYPE msg_rec_type IS RECORD
(
  app_name                 VARCHAR2(30),
  message_name             VARCHAR2(30),
  column_name              VARCHAR2(30),
  column_value_key         VARCHAR2(100),
  num_of_tokens            NUMBER,
  token1_name              VARCHAR2(100),
  token1_value_key         VARCHAR2(100),
  token2_name              VARCHAR2(100),
  token2_value_key         VARCHAR2(200),
  token3_name              VARCHAR2(100),
  token3_value_key         VARCHAR2(200),
  token4_name              VARCHAR2(100),
  token4_value_key         VARCHAR2(200),
  token5_name              VARCHAR2(100),
  token5_value_key         VARCHAR2(200),
  token6_name              VARCHAR2(100),
  token6_value_key         VARCHAR2(200),
  column_value             VARCHAR2(4000),
  token1_value             VARCHAR2(200),
  token2_value             VARCHAR2(200),
  token3_value             VARCHAR2(200),
  token4_value             VARCHAR2(200),
  token5_value             VARCHAR2(200),
  token6_value             VARCHAR2(200)
);

TYPE msg_mapping_list IS TABLE OF msg_rec_type
  INDEX BY pls_integer;

TYPE msg_mapping_context_list IS TABLE OF msg_mapping_list
  INDEX BY VARCHAR2(25);

PROCEDURE find_msg
( p_context IN VARCHAR2,
  p_id      IN NUMBER,
  x_msg_exists OUT NOCOPY VARCHAR2,
  x_msg_rec    OUT NOCOPY msg_rec_type
);

END PO_MSG_MAPPING_UTL;

 

/
