--------------------------------------------------------
--  DDL for Package GR_ITEM_DOCUMENT_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_ITEM_DOCUMENT_DTLS_PKG" AUTHID CURRENT_USER AS
/*$Header: GRHIIDDS.pls 115.4 2002/10/25 20:30:36 methomas ship $*/
	   PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_document_code IN VARCHAR2,
				  p_phrase_code IN VARCHAR2,
				  p_display_order IN NUMBER,
				  p_main_heading_code IN VARCHAR2,
				  p_sub_heading_code IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_print_font IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  p_phrase_group_code IN VARCHAR2,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Update_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_document_code IN VARCHAR2,
				  p_phrase_code IN VARCHAR2,
				  p_display_order IN NUMBER,
				  p_main_heading_code IN VARCHAR2,
				  p_sub_heading_code IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_print_font IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  p_phrase_group_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Lock_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_document_code IN VARCHAR2,
				  p_phrase_code IN VARCHAR2,
				  p_display_order IN NUMBER,
				  p_main_heading_code IN VARCHAR2,
				  p_sub_heading_code IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_print_font IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  p_phrase_group_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Delete_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_document_code IN VARCHAR2,
				  p_phrase_code IN VARCHAR2,
				  p_display_order IN NUMBER,
				  p_main_heading_code IN VARCHAR2,
				  p_sub_heading_code IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_print_font IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  p_phrase_group_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
/*
**		p delete option has one of five values
**		'I' - Delete all rows for the specified item.
**		'D' - Delete all rows for the specified document.
**		'P' - Delete all rows for the specified phrase.
*/
	   PROCEDURE Delete_Rows
	             (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_delete_option IN VARCHAR2,
	              p_item_code IN VARCHAR2,
				  p_document_code IN VARCHAR2,
				  p_phrase_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Foreign_Keys
	   			 (p_item_code IN VARCHAR2,
				  p_document_code IN VARCHAR2,
				  p_phrase_code IN VARCHAR2,
				  p_display_order IN NUMBER,
				  p_main_heading_code IN VARCHAR2,
				  p_sub_heading_code IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_print_font IN VARCHAR2,
				  p_phrase_group_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_document_code IN VARCHAR2,
				  p_phrase_code IN VARCHAR2,
				  p_display_order IN NUMBER,
				  p_main_heading_code IN VARCHAR2,
				  p_sub_heading_code IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_print_font IN VARCHAR2,
				  p_phrase_group_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Primary_Key
	   			 (p_item_code IN VARCHAR2,
	   			  p_document_code IN VARCHAR2,
				  p_phrase_code IN VARCHAR2,
				  p_display_order IN NUMBER,
				  p_called_by_form IN VARCHAR2,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_key_exists OUT NOCOPY VARCHAR2);
END GR_ITEM_DOCUMENT_DTLS_PKG;

 

/
