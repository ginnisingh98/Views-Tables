--------------------------------------------------------
--  DDL for Package QP_PRICE_BOOK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_PRICE_BOOK_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPXUPBKS.pls 120.19.12010000.3 2009/09/04 07:27:05 kdurgasi ship $ */

/** PDF output format type   */
  G_TYPE_PDF CONSTANT VARCHAR2(50) := 'PDF';
  /** RTF output format type   */
  G_TYPE_RTF CONSTANT VARCHAR2(50) := 'RTF';
  /** Excel output format type */
  G_TYPE_EXCEL CONSTANT VARCHAR2(50) := 'EXCEL';
  /** XML output format type */
  G_TYPE_XML CONSTANT VARCHAR2(50) := 'XML';
  /** HTML output format type */
  G_TYPE_HTML CONSTANT VARCHAR2(50) := 'HTML';
  /** UIX output format type */
  G_TYPE_UIX CONSTANT VARCHAR2(50) := 'UIX';
  /** AWT output format type - not supported in this version */
  G_TYPE_AWT CONSTANT VARCHAR2(50) := 'AWT';
  /** Text output format type */
  G_TYPE_TEXT CONSTANT VARCHAR2(50) := 'TEXT';
  /** XSL-FO Format Type**/
  G_TYPE_XSL_FO CONSTANT VARCHAR2(50) := 'XSL-FO';
  /** Text output format type */
  G_DATA_FILE_NOT_FOUND CONSTANT VARCHAR2(50) := '0';

  G_EXT_PDF CONSTANT VARCHAR2(50) := 'pdf';
  G_EXT_HTML CONSTANT VARCHAR2(50) := 'htm';
  G_EXT_EXCEL CONSTANT VARCHAR2(50) := 'xls';
  G_EXT_RTF CONSTANT VARCHAR2(50) := 'rtf';

  G_MIME_PDF CONSTANT VARCHAR2(50) := 'application/pdf';
  G_MIME_HTML CONSTANT VARCHAR2(50) := 'text/html';
  G_MIME_EXCEL CONSTANT VARCHAR2(50) := 'application/excel';
  G_MIME_RTF CONSTANT VARCHAR2(50) := 'application/rtf';

  G_FILE_NAME_PREFIX CONSTANT VARCHAR2(50) := 'pricebook';

TYPE NUMBER_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE VARCHAR30_TYPE IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE VARCHAR_TYPE IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE VARCHAR2000_TYPE IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
TYPE FLAG_TYPE IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

TYPE price_book_message_rec IS RECORD (message_type  VARCHAR2(1) := 'E',
                                       message_code  VARCHAR2(30),
                                       message_text  VARCHAR2(2000),
                                       pb_input_header_id    NUMBER := NULL,
                                       price_book_header_id  NUMBER := NULL,
                                       price_book_line_id    NUMBER := NULL);

TYPE price_book_messages_tbl IS TABLE OF price_book_message_rec
  INDEX BY BINARY_INTEGER;

TYPE pb_input_lines_tbl IS TABLE OF qp_pb_input_lines%ROWTYPE
  INDEX BY BINARY_INTEGER;

PROCEDURE Insert_Price_Book_Messages(
                  p_price_book_messages_tbl IN  price_book_messages_tbl);

PROCEDURE Convert_PB_Input_Value_to_Id (
    p_pb_input_header_rec IN OUT NOCOPY QP_PRICE_BOOK_PUB.pb_input_header_rec);

PROCEDURE Default_PB_Input_Criteria (
    p_pb_input_header_rec IN OUT NOCOPY QP_PRICE_BOOK_PUB.pb_input_header_rec);

PROCEDURE DEFAULT_CUST_ACCOUNT_ID
(
  p_customer_attr_value IN VARCHAR2,
  x_cust_account_id OUT NOCOPY VARCHAR2
);

PROCEDURE Validate_PB_Inp_Criteria_Wrap(
                       p_pb_input_header_id IN NUMBER,
                       x_return_status      OUT NOCOPY VARCHAR2,
                       x_return_text        IN OUT NOCOPY VARCHAR2);

PROCEDURE Insert_Price_Book_Header(
                  p_pb_input_header_rec IN qp_pb_input_headers_vl%ROWTYPE,
                  x_price_book_header_id OUT NOCOPY NUMBER);

FUNCTION value_to_meaning( p_code IN VARCHAR2,p_type IN VARCHAR2)  RETURN VARCHAR2;

FUNCTION get_attribute_name(p_context_code in varchar2
                           ,p_attribute_code in varchar2
                           ,p_attribute_type in varchar2) return varchar2;

FUNCTION get_product_value(p_attribute_code in varchar2
                           ,p_attribute_value_code in varchar2
                           ,p_org_id in varchar2) return varchar2;

FUNCTION get_customer_value(p_attribute_code in varchar2,
                            p_attribute_value_code in varchar2) return varchar2;

FUNCTION get_customer_name(p_customer_id in varchar2) return varchar2;

FUNCTION get_operating_unit(p_orgid in number) return varchar2;

FUNCTION get_context_name (p_context in varchar2,p_attribute_type in varchar2) return varchar2;

FUNCTION get_item_description(p_item_number in  number,p_pb_header_id in number) return varchar2;

FUNCTION get_item_category (p_item_category in number )  return varchar2;

FUNCTION get_item_cat_description (p_item_category in number) return varchar2;

FUNCTION get_item_number(p_item_number in number, p_pb_header_id in number) return varchar2;

FUNCTION get_customer_number (p_item_number in number,p_pb_header_id in number) return varchar2;

FUNCTION get_customer_item_desc (p_item_number in number,p_pb_header_id in number) return varchar2;

FUNCTION get_attribute_value_common(p_attribute_type in varchar2
                                   ,p_context in varchar2
                                   ,p_attribute in varchar2
                                   ,p_attribute_value in varchar2
                                   ,p_comparison_operator in varchar2 default '=') return varchar2;

FUNCTION get_list_name (p_list_header_id in number)return varchar2;

FUNCTION get_currency_name (p_currency_code  in varchar2) return varchar2;
/** KDURGASI **/
FUNCTION get_content_type (p_document_type  in varchar2) return varchar2;

FUNCTION get_document_name (p_pb_input_header_id in number, p_document_type in varchar2) return varchar2;
/** KDURGASI **/
PROCEDURE Delete_PriceBook_info(p_price_book_header_id in number) ;

PROCEDURE Delete_Input_Criteria(p_pb_input_header_id in number);

-- Added by SNIMMAGA
FUNCTION Get_Processing_BatchSize RETURN NATURAL;

PROCEDURE INSERT_PB_TL_RECORDS
(
  p_pb_input_header_id IN VARCHAR2,
  p_price_book_name IN VARCHAR2,
  p_pl_agr_bsa_name IN VARCHAR2
);

PROCEDURE CATGI_HEADER_CONVERSIONS
(
  p_org_id IN NUMBER,
  p_pricing_effective_date IN DATE,
  p_limit_products_by_code IN VARCHAR2,
  p_price_based_on_code IN VARCHAR2,
  p_customer_id IN VARCHAR2,
  p_item_number IN VARCHAR2,
  p_item_number_cust IN VARCHAR2,
  p_item_id IN VARCHAR2,
  p_item_category_name IN VARCHAR2,
  p_item_category_id IN VARCHAR2,
  p_price_list_name IN VARCHAR2,
  p_price_list_id IN VARCHAR2,
  p_agreement_name IN VARCHAR2,
  p_agreement_id IN VARCHAR2,
  p_bsa_name IN VARCHAR2,
  p_bsa_id IN VARCHAR2,
  x_prod_attr_value OUT NOCOPY VARCHAR2,
  x_pl_agr_bsa_id OUT NOCOPY VARCHAR2,
  x_pl_agr_bsa_name OUT NOCOPY VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_return_text OUT NOCOPY VARCHAR2
);

PROCEDURE GET_CONTEXT_CODE
(
  p_context_name IN VARCHAR2,
  p_attribute_type IN VARCHAR2,
  x_context_code OUT NOCOPY VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_return_text OUT NOCOPY VARCHAR2
);

PROCEDURE GET_ATTRIBUTE_CODE
(
  p_context_code IN VARCHAR2,
  p_attribute_name IN VARCHAR2,
  p_attribute_type IN VARCHAR2,
  x_attribute_code OUT NOCOPY VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_return_text OUT NOCOPY VARCHAR2
);

PROCEDURE GET_ATTRIBUTE_VALUE_CODE
(
  p_context_code IN VARCHAR2,
  p_attribute_code IN VARCHAR2,
  p_attribute_value_name IN VARCHAR2,
  p_attribute_type IN VARCHAR2,
  x_attribute_value_code OUT NOCOPY VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_return_text OUT NOCOPY VARCHAR2
);

PROCEDURE PUBLISH_AND_DELIVER_CP
(
  err_buff                OUT NOCOPY VARCHAR2,
  retcode                 OUT NOCOPY NUMBER,
  p_pb_input_header_id NUMBER,
  p_price_book_id NUMBER,
  p_servlet_url IN VARCHAR2 DEFAULT NULL
);

PROCEDURE PUBLISH_AND_DELIVER
(
  p_pb_input_header_id IN NUMBER,
  p_price_book_header_id IN NUMBER,
  p_servlet_url IN VARCHAR2 DEFAULT NULL,
  x_return_status OUT NOCOPY VARCHAR2,
  x_return_status_text OUT NOCOPY VARCHAR2
);

PROCEDURE SEND_SYNC_CATALOG
(
  p_price_book_header_id IN NUMBER,
  x_return_status OUT NOCOPY VARCHAR2,
  x_return_status_text OUT NOCOPY VARCHAR2
);

PROCEDURE GENERATE_PUBLISH_PRICE_BOOK_WF
(
  itemtype   in VARCHAR2,
  itemkey    in VARCHAR2,
  actid      in NUMBER,
  funcmode   in VARCHAR2,
  resultout  in OUT NOCOPY VARCHAR2
);

PROCEDURE CATSO_SELECTOR
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
);

PROCEDURE SET_XML_CONTEXT
(
  p_user_name               IN VARCHAR2,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_return_text             IN OUT NOCOPY VARCHAR2
);

PROCEDURE CATGI_UPDATE_PUBLISH_OPTIONS
(
  p_price_book_name     IN VARCHAR2,
  p_customer_attr_value IN NUMBER,
  p_effective_date      IN DATE,
  p_price_book_type_code IN VARCHAR2,
  p_dlv_xml_site_id     IN NUMBER,
  p_generation_time_code IN VARCHAR2,
  p_gen_schedule_date   IN DATE,
  x_pb_input_header_id  OUT NOCOPY NUMBER,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_return_text         IN OUT NOCOPY VARCHAR2
);

PROCEDURE CATGI_POST_INSERT_PROCESSING
(
  p_pb_input_header_id  IN NUMBER,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_return_text         IN OUT NOCOPY VARCHAR2
);

PROCEDURE CATGI_UPDATE_CUST_ACCOUNT_ID
(
  p_pb_input_header_id  IN NUMBER,
  p_cust_account_id     IN NUMBER,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_return_text         IN OUT NOCOPY VARCHAR2
);

FUNCTION GET_PTE_CODE(p_request_type_code VARCHAR2) RETURN VARCHAR2;
/** KDURGASI **/
PROCEDURE GENERATE_PRICE_BOOK_XML
(
  p_price_book_hdr_id	IN NUMBER,
  p_document_content_type IN VARCHAR2,
  p_document_name	IN VARCHAR2,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_return_text         OUT NOCOPY VARCHAR2
);
/** KDURGASI **/
---------------------------------------------------------

END QP_PRICE_BOOK_UTIL;

/
