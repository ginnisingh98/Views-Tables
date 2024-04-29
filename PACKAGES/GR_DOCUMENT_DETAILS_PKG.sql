--------------------------------------------------------
--  DDL for Package GR_DOCUMENT_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_DOCUMENT_DETAILS_PKG" AUTHID CURRENT_USER AS
/*$Header: GRHIDDS.pls 115.5 2002/10/28 19:40:07 mgrosser ship $*/
	   PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_text_line_number IN NUMBER,
				  p_document_text_id IN NUMBER,
				  p_print_font IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_text_line IN VARCHAR2,
				  p_line_type IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Update_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_text_line_number IN NUMBER,
				  p_document_text_id IN NUMBER,
				  p_print_font IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_text_line IN VARCHAR2,
				  p_line_type IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Lock_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_text_line_number IN NUMBER,
				  p_document_text_id IN NUMBER,
				  p_print_font IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_text_line IN VARCHAR2,
				  p_line_type IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Delete_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_text_line_number IN NUMBER,
				  p_document_text_id IN NUMBER,
				  p_print_font IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_text_line IN VARCHAR2,
				  p_line_type IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Delete_Rows
				 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_document_text_id IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Foreign_Keys
	   			 (p_text_line_number IN NUMBER,
				  p_document_text_id IN NUMBER,
				  p_print_font IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_text_line IN VARCHAR2,
				  p_line_type IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
				  p_text_line_number IN NUMBER,
				  p_document_text_id IN NUMBER,
				  p_print_font IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_text_line IN VARCHAR2,
				  p_line_type IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Primary_Key
	   			 (p_document_text_id IN NUMBER,
				  p_text_line_number IN NUMBER,
				  p_called_by_form IN VARCHAR2,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_key_exists OUT NOCOPY VARCHAR2);
END GR_DOCUMENT_DETAILS_PKG;

 

/
