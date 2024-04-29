--------------------------------------------------------
--  DDL for Package GR_DOCUMENT_HEADINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_DOCUMENT_HEADINGS_PKG" AUTHID CURRENT_USER AS
/*$Header: GRHIDHS.pls 115.6 2002/10/28 23:01:30 mgrosser ship $*/
	   PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_document_headings_seqno IN NUMBER,
				  p_document_code IN VARCHAR2,
				  p_main_heading_code IN VARCHAR2,
				  p_main_display_order IN NUMBER,
				  p_sub_heading_code IN VARCHAR2,
				  p_sub_display_order IN NUMBER,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_current_seq OUT NOCOPY NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Update_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_document_headings_seqno IN NUMBER,
				  p_document_code IN VARCHAR2,
				  p_main_heading_code IN VARCHAR2,
				  p_main_display_order IN NUMBER,
				  p_sub_heading_code IN VARCHAR2,
				  p_sub_display_order IN NUMBER,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);


	   PROCEDURE Update_Display_Columns
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_document_headings_seqno IN NUMBER,
				  p_main_display_order IN NUMBER,
				  p_sub_display_order IN NUMBER,
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
				  p_document_headings_seqno IN NUMBER,
				  p_document_code IN VARCHAR2,
				  p_main_heading_code IN VARCHAR2,
				  p_main_display_order IN NUMBER,
				  p_sub_heading_code IN VARCHAR2,
				  p_sub_display_order IN NUMBER,
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
				  p_document_headings_seqno IN NUMBER,
				  p_document_code IN VARCHAR2,
				  p_main_heading_code IN VARCHAR2,
				  p_main_display_order IN NUMBER,
				  p_sub_heading_code IN VARCHAR2,
				  p_sub_display_order IN NUMBER,
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
	              p_document_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Foreign_Keys
	   			 (p_document_headings_seqno IN NUMBER,
	   			  p_document_code IN VARCHAR2,
				  p_main_heading_code IN VARCHAR2,
				  p_main_display_order IN NUMBER,
				  p_sub_heading_code IN VARCHAR2,
				  p_sub_display_order IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
				  p_document_headings_seqno IN NUMBER,
				  p_document_code IN VARCHAR2,
				  p_main_heading_code IN VARCHAR2,
				  p_main_display_order IN NUMBER,
				  p_sub_heading_code IN VARCHAR2,
				  p_sub_display_order IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Primary_Key
	   			 (p_document_headings_seqno IN NUMBER,
				  p_called_by_form IN VARCHAR2,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_key_exists OUT NOCOPY VARCHAR2);

	   PROCEDURE Lock_Rows
	   			 (p_document_code IN VARCHAR2,
				  p_last_update_date IN DATE,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
END GR_DOCUMENT_HEADINGS_PKG;

 

/
