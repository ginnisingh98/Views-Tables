--------------------------------------------------------
--  DDL for Package GR_PHRASES_TL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_PHRASES_TL_PKG" AUTHID CURRENT_USER AS
/*$Header: GRHIPHTS.pls 115.7 2002/10/28 19:54:07 methomas ship $*/
	   PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_phrase_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_key_word1 IN VARCHAR2,
				  p_key_word2 IN VARCHAR2,
				  p_key_word3 IN VARCHAR2,
				  p_key_word4 IN VARCHAR2,
				  p_key_word5 IN VARCHAR2,
				  p_key_word6 IN VARCHAR2,
				  p_phrase_text IN VARCHAR2,
				  p_print_font IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_image_pathname IN VARCHAR2,
				  p_image_print_location IN VARCHAR2,
				  p_attribute_category IN VARCHAR2,
				  p_attribute1 IN VARCHAR2,
				  p_attribute2 IN VARCHAR2,
				  p_attribute3 IN VARCHAR2,
				  p_attribute4 IN VARCHAR2,
				  p_attribute5 IN VARCHAR2,
				  p_attribute6 IN VARCHAR2,
				  p_attribute7 IN VARCHAR2,
				  p_attribute8 IN VARCHAR2,
				  p_attribute9 IN VARCHAR2,
				  p_attribute10 IN VARCHAR2,
				  p_attribute11 IN VARCHAR2,
				  p_attribute12 IN VARCHAR2,
				  p_attribute13 IN VARCHAR2,
				  p_attribute14 IN VARCHAR2,
				  p_attribute15 IN VARCHAR2,
				  p_attribute16 IN VARCHAR2,
				  p_attribute17 IN VARCHAR2,
				  p_attribute18 IN VARCHAR2,
				  p_attribute19 IN VARCHAR2,
				  p_attribute20 IN VARCHAR2,
				  p_attribute21 IN VARCHAR2,
				  p_attribute22 IN VARCHAR2,
				  p_attribute23 IN VARCHAR2,
				  p_attribute24 IN VARCHAR2,
				  p_attribute25 IN VARCHAR2,
				  p_attribute26 IN VARCHAR2,
				  p_attribute27 IN VARCHAR2,
				  p_attribute28 IN VARCHAR2,
				  p_attribute29 IN VARCHAR2,
				  p_attribute30 IN VARCHAR2,
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
				  p_phrase_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_key_word1 IN VARCHAR2,
				  p_key_word2 IN VARCHAR2,
				  p_key_word3 IN VARCHAR2,
				  p_key_word4 IN VARCHAR2,
				  p_key_word5 IN VARCHAR2,
				  p_key_word6 IN VARCHAR2,
				  p_phrase_text IN VARCHAR2,
				  p_print_font IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_image_pathname IN VARCHAR2,
				  p_image_print_location IN VARCHAR2,
				  p_attribute_category IN VARCHAR2,
				  p_attribute1 IN VARCHAR2,
				  p_attribute2 IN VARCHAR2,
				  p_attribute3 IN VARCHAR2,
				  p_attribute4 IN VARCHAR2,
				  p_attribute5 IN VARCHAR2,
				  p_attribute6 IN VARCHAR2,
				  p_attribute7 IN VARCHAR2,
				  p_attribute8 IN VARCHAR2,
				  p_attribute9 IN VARCHAR2,
				  p_attribute10 IN VARCHAR2,
				  p_attribute11 IN VARCHAR2,
				  p_attribute12 IN VARCHAR2,
				  p_attribute13 IN VARCHAR2,
				  p_attribute14 IN VARCHAR2,
				  p_attribute15 IN VARCHAR2,
				  p_attribute16 IN VARCHAR2,
				  p_attribute17 IN VARCHAR2,
				  p_attribute18 IN VARCHAR2,
				  p_attribute19 IN VARCHAR2,
				  p_attribute20 IN VARCHAR2,
				  p_attribute21 IN VARCHAR2,
				  p_attribute22 IN VARCHAR2,
				  p_attribute23 IN VARCHAR2,
				  p_attribute24 IN VARCHAR2,
				  p_attribute25 IN VARCHAR2,
				  p_attribute26 IN VARCHAR2,
				  p_attribute27 IN VARCHAR2,
				  p_attribute28 IN VARCHAR2,
				  p_attribute29 IN VARCHAR2,
				  p_attribute30 IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Add_Language
	             (p_commit IN VARCHAR2,
	              p_called_by_form IN VARCHAR2,
				  p_phrase_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Lock_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_phrase_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_key_word1 IN VARCHAR2,
				  p_key_word2 IN VARCHAR2,
				  p_key_word3 IN VARCHAR2,
				  p_key_word4 IN VARCHAR2,
				  p_key_word5 IN VARCHAR2,
				  p_key_word6 IN VARCHAR2,
				  p_phrase_text IN VARCHAR2,
				  p_print_font IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_image_pathname IN VARCHAR2,
				  p_image_print_location IN VARCHAR2,
				  p_attribute_category IN VARCHAR2,
				  p_attribute1 IN VARCHAR2,
				  p_attribute2 IN VARCHAR2,
				  p_attribute3 IN VARCHAR2,
				  p_attribute4 IN VARCHAR2,
				  p_attribute5 IN VARCHAR2,
				  p_attribute6 IN VARCHAR2,
				  p_attribute7 IN VARCHAR2,
				  p_attribute8 IN VARCHAR2,
				  p_attribute9 IN VARCHAR2,
				  p_attribute10 IN VARCHAR2,
				  p_attribute11 IN VARCHAR2,
				  p_attribute12 IN VARCHAR2,
				  p_attribute13 IN VARCHAR2,
				  p_attribute14 IN VARCHAR2,
				  p_attribute15 IN VARCHAR2,
				  p_attribute16 IN VARCHAR2,
				  p_attribute17 IN VARCHAR2,
				  p_attribute18 IN VARCHAR2,
				  p_attribute19 IN VARCHAR2,
				  p_attribute20 IN VARCHAR2,
				  p_attribute21 IN VARCHAR2,
				  p_attribute22 IN VARCHAR2,
				  p_attribute23 IN VARCHAR2,
				  p_attribute24 IN VARCHAR2,
				  p_attribute25 IN VARCHAR2,
				  p_attribute26 IN VARCHAR2,
				  p_attribute27 IN VARCHAR2,
				  p_attribute28 IN VARCHAR2,
				  p_attribute29 IN VARCHAR2,
				  p_attribute30 IN VARCHAR2,
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
				  p_phrase_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_key_word1 IN VARCHAR2,
				  p_key_word2 IN VARCHAR2,
				  p_key_word3 IN VARCHAR2,
				  p_key_word4 IN VARCHAR2,
				  p_key_word5 IN VARCHAR2,
				  p_key_word6 IN VARCHAR2,
				  p_phrase_text IN VARCHAR2,
				  p_print_font IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_image_pathname IN VARCHAR2,
				  p_image_print_location IN VARCHAR2,
				  p_attribute_category IN VARCHAR2,
				  p_attribute1 IN VARCHAR2,
				  p_attribute2 IN VARCHAR2,
				  p_attribute3 IN VARCHAR2,
				  p_attribute4 IN VARCHAR2,
				  p_attribute5 IN VARCHAR2,
				  p_attribute6 IN VARCHAR2,
				  p_attribute7 IN VARCHAR2,
				  p_attribute8 IN VARCHAR2,
				  p_attribute9 IN VARCHAR2,
				  p_attribute10 IN VARCHAR2,
				  p_attribute11 IN VARCHAR2,
				  p_attribute12 IN VARCHAR2,
				  p_attribute13 IN VARCHAR2,
				  p_attribute14 IN VARCHAR2,
				  p_attribute15 IN VARCHAR2,
				  p_attribute16 IN VARCHAR2,
				  p_attribute17 IN VARCHAR2,
				  p_attribute18 IN VARCHAR2,
				  p_attribute19 IN VARCHAR2,
				  p_attribute20 IN VARCHAR2,
				  p_attribute21 IN VARCHAR2,
				  p_attribute22 IN VARCHAR2,
				  p_attribute23 IN VARCHAR2,
				  p_attribute24 IN VARCHAR2,
				  p_attribute25 IN VARCHAR2,
				  p_attribute26 IN VARCHAR2,
				  p_attribute27 IN VARCHAR2,
				  p_attribute28 IN VARCHAR2,
				  p_attribute29 IN VARCHAR2,
				  p_attribute30 IN VARCHAR2,
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
	              p_phrase_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Foreign_Keys
	   			 (p_phrase_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_key_word1 IN VARCHAR2,
				  p_key_word2 IN VARCHAR2,
				  p_key_word3 IN VARCHAR2,
				  p_key_word4 IN VARCHAR2,
				  p_key_word5 IN VARCHAR2,
				  p_key_word6 IN VARCHAR2,
				  p_phrase_text IN VARCHAR2,
				  p_print_font IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_image_pathname IN VARCHAR2,
				  p_image_print_location IN VARCHAR2,
				  p_attribute_category IN VARCHAR2,
				  p_attribute1 IN VARCHAR2,
				  p_attribute2 IN VARCHAR2,
				  p_attribute3 IN VARCHAR2,
				  p_attribute4 IN VARCHAR2,
				  p_attribute5 IN VARCHAR2,
				  p_attribute6 IN VARCHAR2,
				  p_attribute7 IN VARCHAR2,
				  p_attribute8 IN VARCHAR2,
				  p_attribute9 IN VARCHAR2,
				  p_attribute10 IN VARCHAR2,
				  p_attribute11 IN VARCHAR2,
				  p_attribute12 IN VARCHAR2,
				  p_attribute13 IN VARCHAR2,
				  p_attribute14 IN VARCHAR2,
				  p_attribute15 IN VARCHAR2,
				  p_attribute16 IN VARCHAR2,
				  p_attribute17 IN VARCHAR2,
				  p_attribute18 IN VARCHAR2,
				  p_attribute19 IN VARCHAR2,
				  p_attribute20 IN VARCHAR2,
				  p_attribute21 IN VARCHAR2,
				  p_attribute22 IN VARCHAR2,
				  p_attribute23 IN VARCHAR2,
				  p_attribute24 IN VARCHAR2,
				  p_attribute25 IN VARCHAR2,
				  p_attribute26 IN VARCHAR2,
				  p_attribute27 IN VARCHAR2,
				  p_attribute28 IN VARCHAR2,
				  p_attribute29 IN VARCHAR2,
				  p_attribute30 IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
				  p_phrase_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_key_word1 IN VARCHAR2,
				  p_key_word2 IN VARCHAR2,
				  p_key_word3 IN VARCHAR2,
				  p_key_word4 IN VARCHAR2,
				  p_key_word5 IN VARCHAR2,
				  p_key_word6 IN VARCHAR2,
				  p_phrase_text IN VARCHAR2,
				  p_print_font IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_image_pathname IN VARCHAR2,
				  p_image_print_location IN VARCHAR2,
				  p_attribute_category IN VARCHAR2,
				  p_attribute1 IN VARCHAR2,
				  p_attribute2 IN VARCHAR2,
				  p_attribute3 IN VARCHAR2,
				  p_attribute4 IN VARCHAR2,
				  p_attribute5 IN VARCHAR2,
				  p_attribute6 IN VARCHAR2,
				  p_attribute7 IN VARCHAR2,
				  p_attribute8 IN VARCHAR2,
				  p_attribute9 IN VARCHAR2,
				  p_attribute10 IN VARCHAR2,
				  p_attribute11 IN VARCHAR2,
				  p_attribute12 IN VARCHAR2,
				  p_attribute13 IN VARCHAR2,
				  p_attribute14 IN VARCHAR2,
				  p_attribute15 IN VARCHAR2,
				  p_attribute16 IN VARCHAR2,
				  p_attribute17 IN VARCHAR2,
				  p_attribute18 IN VARCHAR2,
				  p_attribute19 IN VARCHAR2,
				  p_attribute20 IN VARCHAR2,
				  p_attribute21 IN VARCHAR2,
				  p_attribute22 IN VARCHAR2,
				  p_attribute23 IN VARCHAR2,
				  p_attribute24 IN VARCHAR2,
				  p_attribute25 IN VARCHAR2,
				  p_attribute26 IN VARCHAR2,
				  p_attribute27 IN VARCHAR2,
				  p_attribute28 IN VARCHAR2,
				  p_attribute29 IN VARCHAR2,
				  p_attribute30 IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Primary_Key
		  		 (p_phrase_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_key_exists OUT NOCOPY VARCHAR2);
	PROCEDURE translate_row (
				X_IMAGE_PRINT_LOCATION IN VARCHAR2
				,X_PHRASE_CODE IN VARCHAR2
				,X_LANGUAGE IN VARCHAR2
				,X_SOURCE_LANG IN VARCHAR2
				,X_KEY_WORD1 IN VARCHAR2
				,X_KEY_WORD2 IN VARCHAR2
				,X_KEY_WORD3 IN VARCHAR2
				,X_KEY_WORD4 IN VARCHAR2
				,X_KEY_WORD5 IN VARCHAR2
				,X_KEY_WORD6 IN VARCHAR2
				,X_PHRASE_TEXT IN VARCHAR2
				,X_PRINT_FONT IN VARCHAR2
				,X_PRINT_SIZE IN NUMBER
				,X_IMAGE_PATHNAME IN VARCHAR2
				);

	PROCEDURE load_row (
				X_IMAGE_PRINT_LOCATION IN VARCHAR2
				,X_PHRASE_CODE IN VARCHAR2
				,X_LANGUAGE IN VARCHAR2
				,X_SOURCE_LANG IN VARCHAR2
				,X_KEY_WORD1 IN VARCHAR2
				,X_KEY_WORD2 IN VARCHAR2
				,X_KEY_WORD3 IN VARCHAR2
				,X_KEY_WORD4 IN VARCHAR2
				,X_KEY_WORD5 IN VARCHAR2
				,X_KEY_WORD6 IN VARCHAR2
				,X_PHRASE_TEXT IN VARCHAR2
				,X_PRINT_FONT IN VARCHAR2
				,X_PRINT_SIZE IN NUMBER
				,X_IMAGE_PATHNAME IN VARCHAR2
				);

	   PROCEDURE New_Language;

END GR_PHRASES_TL_PKG;

 

/