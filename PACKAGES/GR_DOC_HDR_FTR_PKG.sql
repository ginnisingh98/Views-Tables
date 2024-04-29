--------------------------------------------------------
--  DDL for Package GR_DOC_HDR_FTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_DOC_HDR_FTR_PKG" AUTHID CURRENT_USER AS
/*$Header: GRHIDHFS.pls 115.1 2002/10/28 23:02:38 mgrosser noship $*/
	   PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_document_code IN VARCHAR2,
				  p_line_type IN NUMBER,
				  p_line_no IN NUMBER,
				  p_left_label_code IN VARCHAR2,
				  p_right_label_code IN VARCHAR2,
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
				  p_document_code IN VARCHAR2,
				  p_line_type IN NUMBER,
				  p_line_no IN NUMBER,
				  p_left_label_code IN VARCHAR2,
				  p_right_label_code IN VARCHAR2,
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
				  p_document_code IN VARCHAR2,
				  p_line_type IN NUMBER,
				  p_line_no IN NUMBER,
				  p_left_label_code IN VARCHAR2,
				  p_right_label_code IN VARCHAR2,
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
				  p_document_code IN VARCHAR2,
				  p_line_type IN NUMBER,
				  p_line_no IN NUMBER,
				  p_left_label_code IN VARCHAR2,
				  p_right_label_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);

	   PROCEDURE Check_Foreign_Keys
	   			 (p_document_code IN VARCHAR2,
				  p_left_label_code IN VARCHAR2,
				  p_right_label_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
				  p_document_code IN VARCHAR2,
				  p_line_type IN NUMBER,
				  p_line_no IN NUMBER,
				  p_left_label_code IN VARCHAR2,
				  p_right_label_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Primary_Key
	   			 (p_document_code IN VARCHAR2,
				  p_line_type IN NUMBER,
				  p_line_no IN NUMBER,
				  p_left_label_code IN VARCHAR2,
				  p_right_label_code IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_key_exists OUT NOCOPY VARCHAR2);
END GR_DOC_HDR_FTR_PKG;

 

/
