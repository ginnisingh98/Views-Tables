--------------------------------------------------------
--  DDL for Package Body GR_DOCUMENT_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_DOCUMENT_CODES_PKG" AS
/*$Header: GRHIDCB.pls 115.13 2002/10/28 19:12:23 mgrosser ship $*/
PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_document_code IN VARCHAR2,
				  p_user_id IN NUMBER,
				  p_document_version IN NUMBER,
				  p_document_description IN VARCHAR2,
				  p_document_history_flag IN VARCHAR2,
				  p_allow_user_override IN VARCHAR2,
				  p_document_date_format IN VARCHAR2,
				  p_print_ingredients_flag IN VARCHAR2,
				  p_ingredient_header_label IN VARCHAR2,
				  p_ingredient_conc_ind IN VARCHAR2,
				  p_cas_number_seq IN NUMBER,
				  p_msds_name_seq IN NUMBER,
				  p_concentration_seq IN NUMBER,
				  p_hmis_code_seq IN NUMBER,
				  p_nfpa_code_seq IN NUMBER,
				  p_user_code_seq IN NUMBER,
				  p_eec_number_seq IN NUMBER,
				  p_hazard_symbol_seq IN NUMBER,
				  p_risk_phrase_seq IN NUMBER,
				  p_safety_phrase_seq IN NUMBER,
				  p_print_toxic_info_flag IN VARCHAR2,
				  p_toxic_header_label IN VARCHAR2,
				  p_toxic_cas_number_seq IN NUMBER,
				  p_toxic_msds_name_seq IN NUMBER,
				  p_toxic_route_seq IN NUMBER,
				  p_toxic_species_seq IN NUMBER,
				  p_toxic_exposure_seq IN NUMBER,
				  p_toxic_dose_seq IN NUMBER,
				  p_toxic_note_seq IN NUMBER,
				  p_print_exposure_flag IN VARCHAR2,
				  p_exposure_header_label IN VARCHAR2,
				  p_exposure_cas_number_seq IN NUMBER,
				  p_exposure_msds_name_seq IN NUMBER,
				  p_exposure_authority_seq IN NUMBER,
				  p_exposure_type_seq IN NUMBER,
				  p_exposure_dose_seq IN NUMBER,
				  p_exposure_note_seq IN NUMBER,
				  p_include_qc_data_flag IN VARCHAR2,
				  p_prop_65_conc_ind IN VARCHAR2,
				  p_sara_312_conc_ind IN VARCHAR2,
				  p_print_rtk_on_document IN VARCHAR2,
				  p_rtk_header IN VARCHAR2,
				  p_print_all_state_indicator IN VARCHAR2,
				  p_approval_process_flag IN VARCHAR2,
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
				  x_msg_data OUT NOCOPY VARCHAR2)
	IS
/*   Alpha Variables */

L_RETURN_STATUS VARCHAR2(1) := 'S';
L_KEY_EXISTS 	VARCHAR2(1);
L_MSG_DATA 		VARCHAR2(2000);
L_ROWID 		VARCHAR2(18);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;

/*   Exceptions */

FOREIGN_KEY_ERROR 	EXCEPTION;
LABEL_EXISTS_ERROR 	EXCEPTION;
ROW_MISSING_ERROR 	EXCEPTION;

/* Declare cursors */

BEGIN

/*     Initialization Routine */

   SAVEPOINT Insert_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*	  Now call the check foreign key procedure */

   Check_Foreign_Keys
			     (p_document_code,
				  p_user_id,
				  p_document_version,
				  p_document_description,
				  p_document_history_flag,
				  p_allow_user_override,
				  p_document_date_format,
				  p_print_ingredients_flag,
				  p_ingredient_header_label,
				  p_ingredient_conc_ind,
				  p_cas_number_seq,
				  p_msds_name_seq,
				  p_concentration_seq,
				  p_hmis_code_seq,
				  p_nfpa_code_seq,
				  p_user_code_seq,
				  p_eec_number_seq,
				  p_hazard_symbol_seq,
				  p_risk_phrase_seq,
				  p_safety_phrase_seq,
				  p_print_toxic_info_flag,
				  p_toxic_header_label,
				  p_toxic_cas_number_seq,
				  p_toxic_msds_name_seq,
				  p_toxic_route_seq,
				  p_toxic_species_seq,
				  p_toxic_exposure_seq,
				  p_toxic_dose_seq,
				  p_toxic_note_seq,
				  p_print_exposure_flag,
				  p_exposure_header_label,
				  p_exposure_cas_number_seq,
				  p_exposure_msds_name_seq,
				  p_exposure_authority_seq,
				  p_exposure_type_seq,
				  p_exposure_dose_seq,
				  p_exposure_note_seq,
				  p_include_qc_data_flag,
				  p_prop_65_conc_ind,
				  p_sara_312_conc_ind,
				  p_print_rtk_on_document,
				  p_rtk_header,
				  p_print_all_state_indicator,
				  p_approval_process_flag,
				  p_attribute_category,
				  p_attribute1,
				  p_attribute2,
				  p_attribute3,
				  p_attribute4,
				  p_attribute5,
				  p_attribute6,
				  p_attribute7,
				  p_attribute8,
				  p_attribute9,
				  p_attribute10,
				  p_attribute11,
				  p_attribute12,
				  p_attribute13,
				  p_attribute14,
				  p_attribute15,
				  p_attribute16,
				  p_attribute17,
				  p_attribute18,
				  p_attribute19,
				  p_attribute20,
				  p_attribute21,
				  p_attribute22,
				  p_attribute23,
				  p_attribute24,
				  p_attribute25,
				  p_attribute26,
				  p_attribute27,
				  p_attribute28,
				  p_attribute29,
				  p_attribute30,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);
   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   END IF;

/* 	   Now check the primary key doesn't already exist */

   Check_Primary_Key
   	   	   		 (p_document_code,
				  'F',
				  l_rowid,
				  l_key_exists);

   IF FND_API.To_Boolean(l_key_exists) THEN
   	  RAISE Label_Exists_Error;
   END IF;

   INSERT INTO gr_document_codes
   		  	     (document_code,
				  user_id,
				  document_version,
				  document_description,
				  document_history_flag,
				  allow_user_override,
				  document_date_format,
				  print_ingredients_flag,
				  ingredient_header_label,
				  ingredient_conc_ind,
				  cas_number_seq,
				  msds_name_seq,
				  concentration_seq,
				  hmis_code_seq,
				  nfpa_code_seq,
				  user_code_seq,
				  eec_number_seq,
				  hazard_symbol_seq,
				  risk_phrase_seq,
				  safety_phrase_seq,
				  print_toxic_info_flag,
				  toxic_header_label,
				  toxic_cas_number_seq,
				  toxic_msds_name_seq,
				  toxic_route_seq,
				  toxic_species_seq,
				  toxic_exposure_seq,
				  toxic_dose_seq,
				  toxic_note_seq,
				  print_exposure_flag,
				  exposure_header_label,
				  exposure_cas_number_seq,
				  exposure_msds_name_seq,
				  exposure_authority_seq,
				  exposure_type_seq,
				  exposure_dose_seq,
				  exposure_note_seq,
				  include_qc_data_flag,
				  prop_65_conc_ind,
				  sara_312_conc_ind,
				  print_rtk_on_document,
				  rtk_header,
				  print_all_state_indicator,
				  approval_process_flag,
				  attribute_category,
				  attribute1,
				  attribute2,
				  attribute3,
				  attribute4,
				  attribute5,
				  attribute6,
				  attribute7,
				  attribute8,
				  attribute9,
				  attribute10,
				  attribute11,
				  attribute12,
				  attribute13,
				  attribute14,
				  attribute15,
				  attribute16,
				  attribute17,
				  attribute18,
				  attribute19,
				  attribute20,
				  attribute21,
				  attribute22,
				  attribute23,
				  attribute24,
				  attribute25,
				  attribute26,
				  attribute27,
				  attribute28,
				  attribute29,
				  attribute30,
				  created_by,
				  creation_date,
				  last_updated_by,
				  last_update_date,
				  last_update_login)
          VALUES
		         (p_document_code,
				  p_user_id,
				  p_document_version,
				  p_document_description,
				  p_document_history_flag,
				  p_allow_user_override,
				  p_document_date_format,
				  p_print_ingredients_flag,
				  p_ingredient_header_label,
				  p_ingredient_conc_ind,
				  p_cas_number_seq,
				  p_msds_name_seq,
				  p_concentration_seq,
				  p_hmis_code_seq,
				  p_nfpa_code_seq,
				  p_user_code_seq,
				  p_eec_number_seq,
				  p_hazard_symbol_seq,
				  p_risk_phrase_seq,
				  p_safety_phrase_seq,
				  p_print_toxic_info_flag,
				  p_toxic_header_label,
				  p_toxic_cas_number_seq,
				  p_toxic_msds_name_seq,
				  p_toxic_route_seq,
				  p_toxic_species_seq,
				  p_toxic_exposure_seq,
				  p_toxic_dose_seq,
				  p_toxic_note_seq,
				  p_print_exposure_flag,
				  p_exposure_header_label,
				  p_exposure_cas_number_seq,
				  p_exposure_msds_name_seq,
				  p_exposure_authority_seq,
				  p_exposure_type_seq,
				  p_exposure_dose_seq,
				  p_exposure_note_seq,
				  p_include_qc_data_flag,
				  p_prop_65_conc_ind,
				  p_sara_312_conc_ind,
				  p_print_rtk_on_document,
				  p_rtk_header,
				  p_print_all_state_indicator,
				  p_approval_process_flag,
		          p_attribute_category,
				  p_attribute1,
				  p_attribute2,
				  p_attribute3,
				  p_attribute4,
				  p_attribute5,
				  p_attribute6,
				  p_attribute7,
				  p_attribute8,
				  p_attribute9,
				  p_attribute10,
				  p_attribute11,
				  p_attribute12,
				  p_attribute13,
				  p_attribute14,
				  p_attribute15,
				  p_attribute16,
				  p_attribute17,
				  p_attribute18,
				  p_attribute19,
				  p_attribute20,
				  p_attribute21,
				  p_attribute22,
				  p_attribute23,
				  p_attribute24,
				  p_attribute25,
				  p_attribute26,
				  p_attribute27,
				  p_attribute28,
				  p_attribute29,
				  p_attribute30,
				  p_created_by,
				  p_creation_date,
				  p_last_updated_by,
				  p_last_update_date,
				  p_last_update_login);

/*   Now get the row id of the inserted record */

   Check_Primary_Key
   	   	   		 (p_document_code,
				  'F',
				  l_rowid,
				  l_key_exists);

   IF FND_API.To_Boolean(l_key_exists) THEN
   	  x_rowid := l_rowid;
   ELSE
   	  RAISE Row_Missing_Error;
   END IF;

/*   Check the commit flag and if set, then commit the work. */

   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

EXCEPTION

   WHEN Foreign_Key_Error THEN
      ROLLBACK TO SAVEPOINT Insert_Row;
	  x_return_status := l_return_status;
	  x_oracle_error := l_oracle_error;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_FOREIGN_KEY_ERROR');
      FND_MESSAGE.SET_TOKEN('TEXT',
         		            l_msg_data,
            			    FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
         APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
      END IF;

   WHEN Label_Exists_Error THEN
      ROLLBACK TO SAVEPOINT Insert_Row;
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_EXISTS');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            p_document_code,
            			    FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
         APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
      END IF;

   WHEN Row_Missing_Error THEN
      ROLLBACK TO SAVEPOINT Insert_Row;
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_NO_RECORD_INSERTED');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            p_document_code,
            			    FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
         APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Insert_Row;
	  x_return_status := 'U';
	  x_oracle_error := SQLCODE;
	  l_msg_data := SUBSTR(SQLERRM, 1, 200);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_data,
	                        FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
         APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
      END IF;

END Insert_Row;

PROCEDURE Update_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_document_code IN VARCHAR2,
				  p_user_id IN NUMBER,
				  p_document_version IN NUMBER,
				  p_document_description IN VARCHAR2,
				  p_document_history_flag IN VARCHAR2,
				  p_allow_user_override IN VARCHAR2,
				  p_document_date_format IN VARCHAR2,
				  p_print_ingredients_flag IN VARCHAR2,
				  p_ingredient_header_label IN VARCHAR2,
				  p_ingredient_conc_ind IN VARCHAR2,
				  p_cas_number_seq IN NUMBER,
				  p_msds_name_seq IN NUMBER,
				  p_concentration_seq IN NUMBER,
				  p_hmis_code_seq IN NUMBER,
				  p_nfpa_code_seq IN NUMBER,
				  p_user_code_seq IN NUMBER,
				  p_eec_number_seq IN NUMBER,
				  p_hazard_symbol_seq IN NUMBER,
				  p_risk_phrase_seq IN NUMBER,
				  p_safety_phrase_seq IN NUMBER,
				  p_print_toxic_info_flag IN VARCHAR2,
				  p_toxic_header_label IN VARCHAR2,
				  p_toxic_cas_number_seq IN NUMBER,
				  p_toxic_msds_name_seq IN NUMBER,
				  p_toxic_route_seq IN NUMBER,
				  p_toxic_species_seq IN NUMBER,
				  p_toxic_exposure_seq IN NUMBER,
				  p_toxic_dose_seq IN NUMBER,
				  p_toxic_note_seq IN NUMBER,
				  p_print_exposure_flag IN VARCHAR2,
				  p_exposure_header_label IN VARCHAR2,
				  p_exposure_cas_number_seq IN NUMBER,
				  p_exposure_msds_name_seq IN NUMBER,
				  p_exposure_authority_seq IN NUMBER,
				  p_exposure_type_seq IN NUMBER,
				  p_exposure_dose_seq IN NUMBER,
				  p_exposure_note_seq IN NUMBER,
				  p_include_qc_data_flag IN VARCHAR2,
				  p_prop_65_conc_ind IN VARCHAR2,
				  p_sara_312_conc_ind IN VARCHAR2,
				  p_print_rtk_on_document IN VARCHAR2,
				  p_rtk_header IN VARCHAR2,
				  p_print_all_state_indicator IN VARCHAR2,
				  p_approval_process_flag IN VARCHAR2,
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
				  x_msg_data OUT NOCOPY VARCHAR2)
   IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;

/*   Exceptions */

FOREIGN_KEY_ERROR EXCEPTION;
ROW_MISSING_ERROR EXCEPTION;

BEGIN

/*       Initialization Routine */

   SAVEPOINT Update_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*	  Now call the check foreign key procedure */

   Check_Foreign_Keys
			     (p_document_code,
				  p_user_id,
				  p_document_version,
				  p_document_description,
				  p_document_history_flag,
				  p_allow_user_override,
				  p_document_date_format,
				  p_print_ingredients_flag,
				  p_ingredient_header_label,
				  p_ingredient_conc_ind,
				  p_cas_number_seq,
				  p_msds_name_seq,
				  p_concentration_seq,
				  p_hmis_code_seq,
				  p_nfpa_code_seq,
				  p_user_code_seq,
				  p_eec_number_seq,
				  p_hazard_symbol_seq,
				  p_risk_phrase_seq,
				  p_safety_phrase_seq,
				  p_print_toxic_info_flag,
				  p_toxic_header_label,
				  p_toxic_cas_number_seq,
				  p_toxic_msds_name_seq,
				  p_toxic_route_seq,
				  p_toxic_species_seq,
				  p_toxic_exposure_seq,
				  p_toxic_dose_seq,
				  p_toxic_note_seq,
				  p_print_exposure_flag,
				  p_exposure_header_label,
				  p_exposure_cas_number_seq,
				  p_exposure_msds_name_seq,
				  p_exposure_authority_seq,
				  p_exposure_type_seq,
				  p_exposure_dose_seq,
				  p_exposure_note_seq,
				  p_include_qc_data_flag,
				  p_prop_65_conc_ind,
				  p_sara_312_conc_ind,
				  p_print_rtk_on_document,
				  p_rtk_header,
				  p_print_all_state_indicator,
				  p_approval_process_flag,
				  p_attribute_category,
				  p_attribute1,
				  p_attribute2,
				  p_attribute3,
				  p_attribute4,
				  p_attribute5,
				  p_attribute6,
				  p_attribute7,
				  p_attribute8,
				  p_attribute9,
				  p_attribute10,
				  p_attribute11,
				  p_attribute12,
				  p_attribute13,
				  p_attribute14,
				  p_attribute15,
				  p_attribute16,
				  p_attribute17,
				  p_attribute18,
				  p_attribute19,
				  p_attribute20,
				  p_attribute21,
				  p_attribute22,
				  p_attribute23,
				  p_attribute24,
				  p_attribute25,
				  p_attribute26,
				  p_attribute27,
				  p_attribute28,
				  p_attribute29,
				  p_attribute30,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   ELSE
      UPDATE gr_document_codes
      SET	 document_code				  	 = p_document_code,
			 user_id	  					 = p_user_id,
			 document_version	  			 = p_document_version,
			 document_description	  		 = p_document_description,
			 document_history_flag	  		 = p_document_history_flag,
			 allow_user_override	  		 = p_allow_user_override,
			 document_date_format	  		 = p_document_date_format,
			 print_ingredients_flag	  		 = p_print_ingredients_flag,
			 ingredient_header_label	  	 = p_ingredient_header_label,
			 ingredient_conc_ind	  		 = p_ingredient_conc_ind,
			 cas_number_seq	  				 = p_cas_number_seq,
			 msds_name_seq	  				 = p_msds_name_seq,
			 concentration_seq	  			 = p_concentration_seq,
			 hmis_code_seq	  				 = p_hmis_code_seq,
			 nfpa_code_seq				  	 = p_nfpa_code_seq,
			 user_code_seq	  				 = p_user_code_seq,
			 eec_number_seq	  				 = p_eec_number_seq,
			 hazard_symbol_seq	  			 = p_hazard_symbol_seq,
			 risk_phrase_seq	  			 = p_risk_phrase_seq,
			 safety_phrase_seq	  			 = p_safety_phrase_seq,
			 print_toxic_info_flag	  		 = p_print_toxic_info_flag,
			 toxic_header_label	  			 = p_toxic_header_label,
			 toxic_cas_number_seq	  		 = p_toxic_cas_number_seq,
			 toxic_msds_name_seq	  		 = p_toxic_msds_name_seq,
			 toxic_route_seq	  			 = p_toxic_route_seq,
		         toxic_species_seq                               = p_toxic_species_seq,
			 toxic_exposure_seq	  			 = p_toxic_exposure_seq,
			 toxic_dose_seq	  				 = p_toxic_dose_seq,
			 toxic_note_seq	  				 = p_toxic_note_seq,
			 print_exposure_flag	  		 = p_print_exposure_flag,
			 exposure_header_label	  		 = p_exposure_header_label,
			 exposure_cas_number_seq	  	 = p_exposure_cas_number_seq,
			 exposure_msds_name_seq	  	 	 = p_exposure_msds_name_seq,
			 exposure_authority_seq	  		 = p_exposure_authority_seq,
			 exposure_type_seq	  			 = p_exposure_type_seq,
			 exposure_dose_seq	  			 = p_exposure_dose_seq,
			 exposure_note_seq	  			 = p_exposure_note_seq,
			 include_qc_data_flag	  		 = p_include_qc_data_flag,
			 prop_65_conc_ind	  			 = p_prop_65_conc_ind,
			 sara_312_conc_ind	  			 = p_sara_312_conc_ind,
			 print_rtk_on_document	  		 = p_print_rtk_on_document,
			 rtk_header	  					 = p_rtk_header,
			 print_all_state_indicator	  	 = p_print_all_state_indicator,
			 approval_process_flag	  		 = p_approval_process_flag,
			 attribute_category				 = p_attribute_category,
			 attribute1						 = p_attribute1,
			 attribute2						 = p_attribute2,
			 attribute3						 = p_attribute3,
			 attribute4						 = p_attribute4,
			 attribute5						 = p_attribute5,
			 attribute6						 = p_attribute6,
			 attribute7						 = p_attribute7,
			 attribute8						 = p_attribute8,
			 attribute9						 = p_attribute9,
			 attribute10					 = p_attribute10,
			 attribute11					 = p_attribute11,
			 attribute12					 = p_attribute12,
			 attribute13					 = p_attribute13,
			 attribute14					 = p_attribute14,
			 attribute15					 = p_attribute15,
			 attribute16					 = p_attribute16,
			 attribute17					 = p_attribute17,
			 attribute18					 = p_attribute18,
			 attribute19					 = p_attribute19,
			 attribute20					 = p_attribute20,
			 attribute21					 = p_attribute11,
			 attribute22					 = p_attribute22,
			 attribute23					 = p_attribute23,
			 attribute24					 = p_attribute24,
			 attribute25					 = p_attribute25,
			 attribute26					 = p_attribute26,
			 attribute27					 = p_attribute27,
			 attribute28					 = p_attribute28,
			 attribute29					 = p_attribute29,
			 attribute30					 = p_attribute30,
			 created_by						 = p_created_by,
			 creation_date					 = p_creation_date,
			 last_updated_by				 = p_last_updated_by,
			 last_update_date				 = p_last_update_date,
			 last_update_login				 = p_last_update_login
	  WHERE  rowid = p_rowid;
	  IF SQL%NOTFOUND THEN
	     RAISE Row_Missing_Error;
	  END IF;
   END IF;

/*   Check the commit flag and if set, then commit the work. */

   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

EXCEPTION

   WHEN Foreign_Key_Error THEN
      ROLLBACK TO SAVEPOINT Update_Row;
	  x_return_status := l_return_status;
	  x_oracle_error := l_oracle_error;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_FOREIGN_KEY_ERROR');
      FND_MESSAGE.SET_TOKEN('TEXT',
         		            l_msg_data,
            			    FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
         APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
      END IF;

   WHEN Row_Missing_Error THEN
      ROLLBACK TO SAVEPOINT Update_Row;
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_NO_RECORD_INSERTED');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            p_document_code,
            			    FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
         APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Update_Row;
	  x_return_status := 'U';
	  x_oracle_error := SQLCODE;
	  l_msg_data := SUBSTR(SQLERRM, 1, 200);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_data,
	                        FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
         APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
      END IF;

END Update_Row;

PROCEDURE Lock_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_document_code IN VARCHAR2,
				  p_user_id IN NUMBER,
				  p_document_version IN NUMBER,
				  p_document_description IN VARCHAR2,
				  p_document_history_flag IN VARCHAR2,
				  p_allow_user_override IN VARCHAR2,
				  p_document_date_format IN VARCHAR2,
				  p_print_ingredients_flag IN VARCHAR2,
				  p_ingredient_header_label IN VARCHAR2,
				  p_ingredient_conc_ind IN VARCHAR2,
				  p_cas_number_seq IN NUMBER,
				  p_msds_name_seq IN NUMBER,
				  p_concentration_seq IN NUMBER,
				  p_hmis_code_seq IN NUMBER,
				  p_nfpa_code_seq IN NUMBER,
				  p_user_code_seq IN NUMBER,
				  p_eec_number_seq IN NUMBER,
				  p_hazard_symbol_seq IN NUMBER,
				  p_risk_phrase_seq IN NUMBER,
				  p_safety_phrase_seq IN NUMBER,
				  p_print_toxic_info_flag IN VARCHAR2,
				  p_toxic_header_label IN VARCHAR2,
				  p_toxic_cas_number_seq IN NUMBER,
				  p_toxic_msds_name_seq IN NUMBER,
				  p_toxic_route_seq IN NUMBER,
				  p_toxic_species_seq IN NUMBER,
				  p_toxic_exposure_seq IN NUMBER,
				  p_toxic_dose_seq IN NUMBER,
				  p_toxic_note_seq IN NUMBER,
				  p_print_exposure_flag IN VARCHAR2,
				  p_exposure_header_label IN VARCHAR2,
				  p_exposure_cas_number_seq IN NUMBER,
				  p_exposure_msds_name_seq IN NUMBER,
				  p_exposure_authority_seq IN NUMBER,
				  p_exposure_type_seq IN NUMBER,
				  p_exposure_dose_seq IN NUMBER,
				  p_exposure_note_seq IN NUMBER,
				  p_include_qc_data_flag IN VARCHAR2,
				  p_prop_65_conc_ind IN VARCHAR2,
				  p_sara_312_conc_ind IN VARCHAR2,
				  p_print_rtk_on_document IN VARCHAR2,
				  p_rtk_header IN VARCHAR2,
				  p_print_all_state_indicator IN VARCHAR2,
				  p_approval_process_flag IN VARCHAR2,
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
				  x_return_status OUT NOCOPY  VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
   IS

/*  Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);

/*  Number Variables */

L_ORACLE_ERROR	  NUMBER;

/*   Exceptions */

NO_DATA_FOUND_ERROR 		EXCEPTION;
ROW_ALREADY_LOCKED_ERROR 	EXCEPTION;
PRAGMA EXCEPTION_INIT(ROW_ALREADY_LOCKED_ERROR,-54);

/*   Define the cursors */

CURSOR c_lock_document
 IS
   SELECT	*
   FROM		gr_document_codes
   WHERE	rowid = p_rowid
   FOR UPDATE NOWAIT;
LockDocumentRcd	  c_lock_document%ROWTYPE;

BEGIN

/*      Initialization Routine */

   SAVEPOINT Lock_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*	   Now lock the record */

   OPEN c_lock_document;
   FETCH c_lock_document INTO LockDocumentRcd;
   IF c_lock_document%NOTFOUND THEN
	  CLOSE c_lock_document;
	  RAISE No_Data_Found_Error;
   END IF;
   CLOSE c_lock_document;

   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

EXCEPTION

   WHEN No_Data_Found_Error THEN
      ROLLBACK TO SAVEPOINT Lock_Row;
	  x_return_status := 'E';
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_RECORD_NOT_FOUND');
	  FND_MESSAGE.SET_TOKEN('CODE',
	                        p_document_code,
							FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
         APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
      END IF;

   WHEN Row_Already_Locked_Error THEN
      ROLLBACK TO SAVEPOINT Lock_Row;
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_ROW_IS_LOCKED');
      IF FND_API.To_Boolean(p_called_by_form) THEN
         APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Lock_Row;
	  x_return_status := 'U';
	  x_oracle_error := SQLCODE;
	  l_msg_data := SUBSTR(SQLERRM, 1, 200);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_data,
	                        FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
         APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
      END IF;

END Lock_Row;

PROCEDURE Delete_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_document_code IN VARCHAR2,
				  p_user_id IN NUMBER,
				  p_document_version IN NUMBER,
				  p_document_description IN VARCHAR2,
				  p_document_history_flag IN VARCHAR2,
				  p_allow_user_override IN VARCHAR2,
				  p_document_date_format IN VARCHAR2,
				  p_print_ingredients_flag IN VARCHAR2,
				  p_ingredient_header_label IN VARCHAR2,
				  p_ingredient_conc_ind IN VARCHAR2,
				  p_cas_number_seq IN NUMBER,
				  p_msds_name_seq IN NUMBER,
				  p_concentration_seq IN NUMBER,
				  p_hmis_code_seq IN NUMBER,
				  p_nfpa_code_seq IN NUMBER,
				  p_user_code_seq IN NUMBER,
				  p_eec_number_seq IN NUMBER,
				  p_hazard_symbol_seq IN NUMBER,
				  p_risk_phrase_seq IN NUMBER,
				  p_safety_phrase_seq IN NUMBER,
				  p_print_toxic_info_flag IN VARCHAR2,
				  p_toxic_header_label IN VARCHAR2,
				  p_toxic_cas_number_seq IN NUMBER,
				  p_toxic_msds_name_seq IN NUMBER,
				  p_toxic_route_seq IN NUMBER,
				  p_toxic_species_seq IN NUMBER,
				  p_toxic_exposure_seq IN NUMBER,
				  p_toxic_dose_seq IN NUMBER,
				  p_toxic_note_seq IN NUMBER,
				  p_print_exposure_flag IN VARCHAR2,
				  p_exposure_header_label IN VARCHAR2,
				  p_exposure_cas_number_seq IN NUMBER,
				  p_exposure_msds_name_seq IN NUMBER,
				  p_exposure_authority_seq IN NUMBER,
				  p_exposure_type_seq IN NUMBER,
				  p_exposure_dose_seq IN NUMBER,
				  p_exposure_note_seq IN NUMBER,
				  p_include_qc_data_flag IN VARCHAR2,
				  p_prop_65_conc_ind IN VARCHAR2,
				  p_sara_312_conc_ind IN VARCHAR2,
				  p_print_rtk_on_document IN VARCHAR2,
				  p_rtk_header IN VARCHAR2,
				  p_print_all_state_indicator IN VARCHAR2,
				  p_approval_process_flag IN VARCHAR2,
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
				  x_msg_data OUT NOCOPY VARCHAR2)
   IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_CALLED_BY_FORM  VARCHAR2(1);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;

/*   Exceptions */

CHECK_INTEGRITY_ERROR EXCEPTION;
ROW_MISSING_ERROR	  EXCEPTION;
PRAGMA EXCEPTION_INIT(Row_Missing_Error,100);

BEGIN

/*   Initialization Routine */

   SAVEPOINT Delete_Row;
   x_return_status := 'S';
   l_called_by_form := 'F';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*  Now call the check integrity procedure */

   Check_Integrity
			     (l_called_by_form,
				  p_document_code,
				  p_user_id,
				  p_document_version,
				  p_document_description,
				  p_document_history_flag,
				  p_allow_user_override,
				  p_document_date_format,
				  p_print_ingredients_flag,
				  p_ingredient_header_label,
				  p_ingredient_conc_ind,
				  p_cas_number_seq,
				  p_msds_name_seq,
				  p_concentration_seq,
				  p_hmis_code_seq,
				  p_nfpa_code_seq,
				  p_user_code_seq,
				  p_eec_number_seq,
				  p_hazard_symbol_seq,
				  p_risk_phrase_seq,
				  p_safety_phrase_seq,
				  p_print_toxic_info_flag,
				  p_toxic_header_label,
				  p_toxic_cas_number_seq,
				  p_toxic_msds_name_seq,
				  p_toxic_route_seq,
				  p_toxic_species_seq,
				  p_toxic_exposure_seq,
				  p_toxic_dose_seq,
				  p_toxic_note_seq,
				  p_print_exposure_flag,
				  p_exposure_header_label,
				  p_exposure_cas_number_seq,
				  p_exposure_msds_name_seq,
				  p_exposure_authority_seq,
				  p_exposure_type_seq,
				  p_exposure_dose_seq,
				  p_exposure_note_seq,
				  p_include_qc_data_flag,
				  p_prop_65_conc_ind,
				  p_sara_312_conc_ind,
				  p_print_rtk_on_document,
				  p_rtk_header,
				  p_print_all_state_indicator,
				  p_approval_process_flag,
				  p_attribute_category,
				  p_attribute1,
				  p_attribute2,
				  p_attribute3,
				  p_attribute4,
				  p_attribute5,
				  p_attribute6,
				  p_attribute7,
				  p_attribute8,
				  p_attribute9,
				  p_attribute10,
				  p_attribute11,
				  p_attribute12,
				  p_attribute13,
				  p_attribute14,
				  p_attribute15,
				  p_attribute16,
				  p_attribute17,
				  p_attribute18,
				  p_attribute19,
				  p_attribute20,
				  p_attribute21,
				  p_attribute22,
				  p_attribute23,
				  p_attribute24,
				  p_attribute25,
				  p_attribute26,
				  p_attribute27,
				  p_attribute28,
				  p_attribute29,
				  p_attribute30,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Check_Integrity_Error;
   END IF;

   DELETE FROM gr_document_codes
   WHERE  	   rowid = p_rowid;

/*   Check the commit flag and if set, then commit the work. */

   IF FND_API.TO_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

EXCEPTION

   WHEN Check_Integrity_Error THEN
      ROLLBACK TO SAVEPOINT Delete_Row;
	  x_return_status := l_return_status;
	  x_oracle_error := l_oracle_error;
      IF FND_API.To_Boolean(p_called_by_form) THEN
         APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
      END IF;

   WHEN Row_Missing_Error THEN
      ROLLBACK TO SAVEPOINT Delete_Row;
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            p_document_code,
            			    FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
         APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Delete_Row;
	  x_return_status := 'U';
	  x_oracle_error := SQLCODE;
	  l_msg_data := SUBSTR(SQLERRM, 1, 200);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_data,
	                        FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
         APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
      END IF;

END Delete_Row;

PROCEDURE Check_Foreign_Keys
	   			 (p_document_code IN VARCHAR2,
				  p_user_id IN NUMBER,
				  p_document_version IN NUMBER,
				  p_document_description IN VARCHAR2,
				  p_document_history_flag IN VARCHAR2,
				  p_allow_user_override IN VARCHAR2,
				  p_document_date_format IN VARCHAR2,
				  p_print_ingredients_flag IN VARCHAR2,
				  p_ingredient_header_label IN VARCHAR2,
				  p_ingredient_conc_ind IN VARCHAR2,
				  p_cas_number_seq IN NUMBER,
				  p_msds_name_seq IN NUMBER,
				  p_concentration_seq IN NUMBER,
				  p_hmis_code_seq IN NUMBER,
				  p_nfpa_code_seq IN NUMBER,
				  p_user_code_seq IN NUMBER,
				  p_eec_number_seq IN NUMBER,
				  p_hazard_symbol_seq IN NUMBER,
				  p_risk_phrase_seq IN NUMBER,
				  p_safety_phrase_seq IN NUMBER,
				  p_print_toxic_info_flag IN VARCHAR2,
				  p_toxic_header_label IN VARCHAR2,
				  p_toxic_cas_number_seq IN NUMBER,
				  p_toxic_msds_name_seq IN NUMBER,
				  p_toxic_route_seq IN NUMBER,
				  p_toxic_species_seq IN NUMBER,
				  p_toxic_exposure_seq IN NUMBER,
				  p_toxic_dose_seq IN NUMBER,
				  p_toxic_note_seq IN NUMBER,
				  p_print_exposure_flag IN VARCHAR2,
				  p_exposure_header_label IN VARCHAR2,
				  p_exposure_cas_number_seq IN NUMBER,
				  p_exposure_msds_name_seq IN NUMBER,
				  p_exposure_authority_seq IN NUMBER,
				  p_exposure_type_seq IN NUMBER,
				  p_exposure_dose_seq IN NUMBER,
				  p_exposure_note_seq IN NUMBER,
				  p_include_qc_data_flag IN VARCHAR2,
				  p_prop_65_conc_ind IN VARCHAR2,
				  p_sara_312_conc_ind IN VARCHAR2,
				  p_print_rtk_on_document IN VARCHAR2,
				  p_rtk_header IN VARCHAR2,
				  p_print_all_state_indicator IN VARCHAR2,
				  p_approval_process_flag IN VARCHAR2,
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
				  x_msg_data OUT NOCOPY VARCHAR2)
   IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_ROWID			  VARCHAR2(18);
L_KEY_EXISTS	  VARCHAR2(1);
L_HEADING		  VARCHAR2(30);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;

/*   Define the cursors */
/*	 Main Headings  */

CURSOR c_get_main_heading
 IS
   SELECT	mh.main_heading_code
   FROM		gr_main_headings_b mh
   WHERE	mh.main_heading_code = l_heading;
MainHdgRcd		c_get_main_heading%ROWTYPE;

/*  User ID */

CURSOR c_get_user_id
 IS
   SELECT	fnu.user_id
   FROM		fnd_user fnu
   WHERE	fnu.user_id = p_user_id;
UserRcd				c_get_user_id%ROWTYPE;

BEGIN

/*   Initialization Routine */

   SAVEPOINT Check_Foreign_Keys;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*   Check the main heading code for ingredient print */

   IF p_ingredient_header_label IS NOT NULL THEN
      l_heading := p_ingredient_header_label;
      OPEN c_get_main_heading;
      FETCH c_get_main_heading INTO MainHdgRcd;
      IF c_get_main_heading%NOTFOUND THEN
         x_return_status := 'E';
	     FND_MESSAGE.SET_NAME('GR',
	                          'GR_RECORD_NOT_FOUND');
	     FND_MESSAGE.SET_TOKEN('CODE',
	                           l_heading,
			   				   FALSE);
	     l_msg_data := l_msg_data || FND_MESSAGE.Get || ' ';
	  END IF;
      CLOSE c_get_main_heading;
   END IF;

/*   Check the main heading code for toxic print */

   IF p_toxic_header_label IS NOT NULL THEN
      l_heading := p_toxic_header_label;
      OPEN c_get_main_heading;
      FETCH c_get_main_heading INTO MainHdgRcd;
      IF c_get_main_heading%NOTFOUND THEN
         x_return_status := 'E';
	     FND_MESSAGE.SET_NAME('GR',
	                          'GR_RECORD_NOT_FOUND');
	     FND_MESSAGE.SET_TOKEN('CODE',
	                           l_heading,
			   				   FALSE);
	     l_msg_data := l_msg_data || FND_MESSAGE.Get || ' ';
	  END IF;
      CLOSE c_get_main_heading;
   END IF;

/*   Check the main heading code for exposure print */

   IF p_exposure_header_label IS NOT NULL THEN
      l_heading := p_exposure_header_label;
      OPEN c_get_main_heading;
      FETCH c_get_main_heading INTO MainHdgRcd;
      IF c_get_main_heading%NOTFOUND THEN
         x_return_status := 'E';
	     FND_MESSAGE.SET_NAME('GR',
	                          'GR_RECORD_NOT_FOUND');
	     FND_MESSAGE.SET_TOKEN('CODE',
	                           l_heading,
			   				   FALSE);
	     l_msg_data := l_msg_data || FND_MESSAGE.Get || ' ';
	  END IF;
      CLOSE c_get_main_heading;
   END IF;

/*   Check the user id */

   OPEN c_get_user_id;
   FETCH c_get_user_id INTO UserRcd;
   IF c_get_user_id%NOTFOUND THEN
      x_return_status := 'E';
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_RECORD_NOT_FOUND');
	  FND_MESSAGE.SET_TOKEN('CODE',
	                        p_user_id,
							FALSE);
	  l_msg_data := l_msg_data || FND_MESSAGE.Get || ' ';
   END IF;
   CLOSE c_get_user_id;

   IF x_return_status <> 'S' THEN
      x_msg_data := l_msg_data;
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Check_Foreign_Keys;
	  x_return_status := 'U';
	  x_oracle_error := SQLCODE;
	  l_msg_data := SUBSTR(SQLERRM, 1, 200);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_data,
	                        FALSE);
	  x_msg_data := FND_MESSAGE.Get;

END Check_Foreign_Keys;

PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
	   			  p_document_code IN VARCHAR2,
				  p_user_id IN NUMBER,
				  p_document_version IN NUMBER,
				  p_document_description IN VARCHAR2,
				  p_document_history_flag IN VARCHAR2,
				  p_allow_user_override IN VARCHAR2,
				  p_document_date_format IN VARCHAR2,
				  p_print_ingredients_flag IN VARCHAR2,
				  p_ingredient_header_label IN VARCHAR2,
				  p_ingredient_conc_ind IN VARCHAR2,
				  p_cas_number_seq IN NUMBER,
				  p_msds_name_seq IN NUMBER,
				  p_concentration_seq IN NUMBER,
				  p_hmis_code_seq IN NUMBER,
				  p_nfpa_code_seq IN NUMBER,
				  p_user_code_seq IN NUMBER,
				  p_eec_number_seq IN NUMBER,
				  p_hazard_symbol_seq IN NUMBER,
				  p_risk_phrase_seq IN NUMBER,
				  p_safety_phrase_seq IN NUMBER,
				  p_print_toxic_info_flag IN VARCHAR2,
				  p_toxic_header_label IN VARCHAR2,
				  p_toxic_cas_number_seq IN NUMBER,
				  p_toxic_msds_name_seq IN NUMBER,
				  p_toxic_route_seq IN NUMBER,
				  p_toxic_species_seq IN NUMBER,
				  p_toxic_exposure_seq IN NUMBER,
				  p_toxic_dose_seq IN NUMBER,
				  p_toxic_note_seq IN NUMBER,
				  p_print_exposure_flag IN VARCHAR2,
				  p_exposure_header_label IN VARCHAR2,
				  p_exposure_cas_number_seq IN NUMBER,
				  p_exposure_msds_name_seq IN NUMBER,
				  p_exposure_authority_seq IN NUMBER,
				  p_exposure_type_seq IN NUMBER,
				  p_exposure_dose_seq IN NUMBER,
				  p_exposure_note_seq IN NUMBER,
				  p_include_qc_data_flag IN VARCHAR2,
				  p_prop_65_conc_ind IN VARCHAR2,
				  p_sara_312_conc_ind IN VARCHAR2,
				  p_print_rtk_on_document IN VARCHAR2,
				  p_rtk_header IN VARCHAR2,
				  p_print_all_state_indicator IN VARCHAR2,
				  p_approval_process_flag IN VARCHAR2,
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
				  x_msg_data OUT NOCOPY VARCHAR2)
   IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_CODE_BLOCK	  VARCHAR2(100);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;
L_RECORD_COUNT	  NUMBER;

/*	 Define the Cursors */
/* 	 Dispatch Histories */

CURSOR c_get_disp_history
 IS
   SELECT	COUNT(*)
   FROM		gr_dispatch_histories
   WHERE	document_code = p_document_code;

/*	 Document Print */

CURSOR c_get_doc_print
 IS
   SELECT	COUNT(*)
   FROM		gr_document_print
   WHERE	document_code = p_document_code;

/*	 Item Document Details */

CURSOR c_get_item_doc_dtls
 IS
   SELECT	COUNT(*)
   FROM		gr_item_document_dtls
   WHERE	document_code = p_document_code;

/*	 Item Document Statuses */

CURSOR c_get_item_doc_statuses
 IS
   SELECT	COUNT(*)
   FROM		gr_item_doc_statuses
   WHERE	document_code = p_document_code;

/*	 Recipient Documents */

CURSOR c_get_recipient_docs
 IS
   SELECT	COUNT(*)
   FROM		gr_recipient_documents
   WHERE	document_code = p_document_code;

/*	 Recipient Information */

CURSOR c_get_recipient_info
 IS
   SELECT	COUNT(*)
   FROM		gr_recipient_info
   WHERE	document_code = p_document_code;

BEGIN

/*     Initialization Routine */

   SAVEPOINT Check_Integrity;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

   FND_MESSAGE.SET_NAME('GR',
                        'GR_INTEGRITY_HEADER');
   FND_MESSAGE.SET_TOKEN('CODE',
                         p_document_code,
						 FALSE);
   l_msg_data := FND_MESSAGE.Get;

/* 	Now read the cursors to make sure the item code isn't used. */
/*  Dispatch Histories */

   l_record_count := 0;
   l_code_block := 'c_get_disp_history';
   OPEN c_get_disp_history;
   FETCH c_get_disp_history INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_dispatch_history, ';
   END IF;
   CLOSE c_get_disp_history;

/*    Document Print */

   l_record_count := 0;
   l_code_block := 'c_get_doc_print';
   OPEN c_get_doc_print;
   FETCH c_get_doc_print INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_document_print, ';
   END IF;
   CLOSE c_get_doc_print;

/*   Item Document Details */

   l_record_count := 0;
   l_code_block := 'c_get_item_doc_dtls';
   OPEN c_get_item_doc_dtls;
   FETCH c_get_item_doc_dtls INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_item_document_details, ';
   END IF;
   CLOSE c_get_item_doc_dtls;

/*  Item Document Statuses */

   l_record_count := 0;
   l_code_block := 'c_get_item_doc_statuses';
   OPEN c_get_item_doc_statuses;
   FETCH c_get_item_doc_statuses INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_item_doc_statuses, ';
   END IF;
   CLOSE c_get_item_doc_statuses;

/*  Recipient Documents */

   l_record_count := 0;
   l_code_block := 'c_get_recipient_docs';
   OPEN c_get_recipient_docs;
   FETCH c_get_recipient_docs INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_recipient_docs, ';
   END IF;
   CLOSE c_get_recipient_docs;

/*  Recipient Info */

   l_record_count := 0;
   l_code_block := 'c_get_recipient_info';
   OPEN c_get_recipient_info;
   FETCH c_get_recipient_info INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_recipient_info, ';
   END IF;
   CLOSE c_get_recipient_info;

/*	 Now sort out the error messaging */

   IF l_return_status <> 'S' THEN
      x_return_status := l_return_status;
	  x_msg_data := l_msg_data;
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Check_Integrity;
	  x_return_status := 'U';
	  x_oracle_error := SQLCODE;
	  l_msg_data := SUBSTR(SQLERRM, 1, 200);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_data,
	                        FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
         APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
      END IF;

END Check_Integrity;

PROCEDURE Check_Primary_Key
/*		  p_document_code is the document code to check.
**		  p_called_by_form is 'T' if called by a form or 'F' if not.
**		  x_rowid is the row id of the record if found.
**		  x_key_exists is 'T' is the record is found, 'F' if not.
*/
		  		 	(p_document_code IN VARCHAR2,
					 p_called_by_form IN VARCHAR2,
					 x_rowid OUT NOCOPY VARCHAR2,
					 x_key_exists OUT NOCOPY VARCHAR2)
  IS
/*	Alphanumeric variables	 */

L_MSG_DATA VARCHAR2(80);

/*		Declare any variables and the cursor */


CURSOR c_get_document_rowid
 IS
   SELECT dc.rowid
   FROM	  gr_document_codes dc
   WHERE  dc.document_code = p_document_code;
DocumentRecord			   c_get_document_rowid%ROWTYPE;

BEGIN

   x_key_exists := 'F';
   l_msg_data := p_document_code;
   OPEN c_get_document_rowid;
   FETCH c_get_document_rowid INTO DocumentRecord;
   IF c_get_document_rowid%FOUND THEN
      x_key_exists := 'T';
	  x_rowid := DocumentRecord.rowid;
   ELSE
      x_key_exists := 'F';
   END IF;
   CLOSE c_get_document_rowid;

EXCEPTION

	WHEN Others THEN
	  l_msg_data := SUBSTR(SQLERRM, 1, 200);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_data,
	                        FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  END IF;

END Check_Primary_Key;

END GR_DOCUMENT_CODES_PKG;

/
