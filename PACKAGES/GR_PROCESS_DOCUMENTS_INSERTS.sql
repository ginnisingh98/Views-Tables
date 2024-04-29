--------------------------------------------------------
--  DDL for Package GR_PROCESS_DOCUMENTS_INSERTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_PROCESS_DOCUMENTS_INSERTS" AUTHID CURRENT_USER AS
/* $Header: GRPDOCIS.pls 115.1 2002/10/30 17:26:02 gkelly noship $ */

   PROCEDURE Worksheet_Insert_Row
          (p_line_number IN OUT NOCOPY NUMBER,
           p_output_type IN VARCHAR2,
           p_user_id IN NUMBER,
           p_current_date IN DATE,
           p_language_code IN VARCHAR2,
           p_session_id IN NUMBER,
           p_item_code IN VARCHAR2,
           p_print_font IN VARCHAR2,
           p_print_size IN NUMBER,
           p_text_line IN VARCHAR2,
           p_line_type IN VARCHAR2,
           x_return_status OUT NOCOPY VARCHAR2);


   PROCEDURE Document_Insert_Row
          (p_line_number IN OUT NOCOPY NUMBER,
           p_output_type IN VARCHAR2,
           p_document_text_id IN NUMBER,
           p_user_id IN NUMBER,
           p_current_date IN DATE,
           p_session_id IN NUMBER,
           p_item_code IN VARCHAR2,
           p_print_font IN VARCHAR2,
           p_print_size IN NUMBER,
           p_text_line IN VARCHAR2,
           p_line_type IN VARCHAR2,
           x_return_status OUT NOCOPY VARCHAR2,
           x_msg_data OUT NOCOPY VARCHAR2);


   PROCEDURE Insert_Work_Row
          (p_session_id IN NUMBER,
           p_document_code IN VARCHAR2,
           p_main_heading_code IN VARCHAR2,
           p_main_display_order IN NUMBER,
           p_sub_heading_code IN VARCHAR2,
           p_sub_display_order IN NUMBER,
           p_record_type IN VARCHAR2,
           p_label_or_phrase_code IN VARCHAR2,
           p_concentration_percent IN NUMBER,
           p_label_class IN VARCHAR2,
           p_phrase_hierarchy IN NUMBER,
           p_phrase_type IN VARCHAR2,
           p_print_flag IN VARCHAR2,
           p_source_itemcode IN VARCHAR2,
           p_structure_display_order IN NUMBER,
           x_return_status OUT NOCOPY VARCHAR2,
           x_msg_data OUT NOCOPY VARCHAR2);


   PROCEDURE Insert_Data_Record
          (p_line_number IN OUT NOCOPY NUMBER,
           p_line_type IN VARCHAR2,
           p_output_type IN VARCHAR2,
           p_user_id IN NUMBER,
           p_current_date IN DATE,
           p_language_code IN VARCHAR2,
           p_document_text_id IN NUMBER,
           p_session_id IN NUMBER,
           p_document_item IN VARCHAR2,
           p_print_font IN VARCHAR2,
           p_print_size IN NUMBER,
           p_text_line_1 IN VARCHAR2,
           p_text_line_2 IN VARCHAR2,
           p_source_action IN VARCHAR2,
           x_return_status OUT NOCOPY VARCHAR2);


   PROCEDURE Insert_Gr_Work_Worksheets
          (p_output_type IN VARCHAR2,
           p_line_number IN OUT NOCOPY NUMBER,
           p_session_id IN NUMBER,
           p_item_code IN VARCHAR2,
           p_print_font IN VARCHAR2,
           p_print_size IN NUMBER,
           p_text_line IN VARCHAR2,
           p_line_type IN VARCHAR2,
           x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE Insert_XML_Data
          (p_line_number IN OUT NOCOPY NUMBER,
           p_output_type IN VARCHAR2,
           p_user_id IN NUMBER,
           p_current_date IN DATE,
           p_language_code IN VARCHAR2,
           p_document_text_id IN NUMBER,
           p_session_id IN NUMBER,
           p_document_item IN VARCHAR2,
           p_print_font  IN VARCHAR2,
           p_print_size  IN NUMBER,
           p_value IN  VARCHAR2,
           p_line_type IN  VARCHAR2,
           p_source IN VARCHAR2,
           x_return_status OUT NOCOPY VARCHAR2);


END GR_PROCESS_DOCUMENTS_INSERTS;


 

/
