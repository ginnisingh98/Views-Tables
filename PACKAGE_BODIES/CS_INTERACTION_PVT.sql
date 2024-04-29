--------------------------------------------------------
--  DDL for Package Body CS_INTERACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_INTERACTION_PVT" AS
/* $Header: csvcib.pls 115.0 99/07/16 09:05:08 porting s $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CS_Interaction_PVT';

------------------------------------------------------------------------------
--  Procedure	: Create_Interaction
--  Type	: Private API
--  Usage	: Creates a customer interaction record in the table
--		  CS_INTERACTIONS
--  Pre-reqs	: None
------------------------------------------------------------------------------

PROCEDURE Create_Interaction
  ( p_api_version		IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit			IN	VARCHAR2 DEFAULT fnd_api.g_false,
    p_validation_level		IN	NUMBER   DEFAULT fnd_api.g_valid_level_full,
    x_return_status		OUT	VARCHAR2,
    x_msg_count			OUT	NUMBER,
    x_msg_data			OUT	VARCHAR2,
    p_resp_appl_id		IN	NUMBER   DEFAULT NULL,
    p_resp_id			IN	NUMBER   DEFAULT NULL,
    p_user_id			IN	NUMBER,
    p_login_id			IN	NUMBER   DEFAULT NULL,
    p_org_id			IN	NUMBER   DEFAULT NULL,
    p_customer_id		IN	NUMBER,
    p_contact_id		IN	NUMBER   DEFAULT NULL,
    p_contact_lastname		IN	VARCHAR2 DEFAULT NULL,
    p_contact_firstname		IN	VARCHAR2 DEFAULT NULL,
    p_phone_area_code		IN	VARCHAR2 DEFAULT NULL,
    p_phone_number		IN	VARCHAR2 DEFAULT NULL,
    p_phone_extension		IN	VARCHAR2 DEFAULT NULL,
    p_fax_area_code		IN	VARCHAR2 DEFAULT NULL,
    p_fax_number		IN	VARCHAR2 DEFAULT NULL,
    p_email_address		IN	VARCHAR2 DEFAULT NULL,
    p_interaction_type_code	IN	VARCHAR2,
    p_interaction_category_code	IN	VARCHAR2,
    p_interaction_method_code	IN	VARCHAR2,
    p_interaction_date		IN	DATE,
    p_interaction_document_code	IN	VARCHAR2 DEFAULT NULL,
    p_source_document_id	IN	NUMBER   DEFAULT NULL,
    p_source_document_name	IN	VARCHAR2 DEFAULT NULL,
    p_reference_form		IN	VARCHAR2 DEFAULT NULL,
    p_source_document_status	IN	VARCHAR2 DEFAULT NULL,
    p_employee_id		IN	NUMBER   DEFAULT NULL,
    p_public_flag		IN	VARCHAR2 DEFAULT NULL,
    p_follow_up_action		IN	VARCHAR2 DEFAULT NULL,
    p_notes			IN	VARCHAR2 DEFAULT NULL,
    p_parent_interaction_id	IN	NUMBER   DEFAULT NULL,
    p_attribute1		IN	VARCHAR2 DEFAULT NULL,
    p_attribute2		IN	VARCHAR2 DEFAULT NULL,
    p_attribute3		IN	VARCHAR2 DEFAULT NULL,
    p_attribute4		IN	VARCHAR2 DEFAULT NULL,
    p_attribute5		IN	VARCHAR2 DEFAULT NULL,
    p_attribute6		IN	VARCHAR2 DEFAULT NULL,
    p_attribute7		IN	VARCHAR2 DEFAULT NULL,
    p_attribute8		IN	VARCHAR2 DEFAULT NULL,
    p_attribute9		IN	VARCHAR2 DEFAULT NULL,
    p_attribute10		IN	VARCHAR2 DEFAULT NULL,
    p_attribute11		IN	VARCHAR2 DEFAULT NULL,
    p_attribute12		IN	VARCHAR2 DEFAULT NULL,
    p_attribute13		IN	VARCHAR2 DEFAULT NULL,
    p_attribute14		IN	VARCHAR2 DEFAULT NULL,
    p_attribute15		IN	VARCHAR2 DEFAULT NULL,
    p_attribute_category	IN	VARCHAR2 DEFAULT NULL,
    x_interaction_id		OUT	NUMBER )
  IS
     l_api_name		CONSTANT VARCHAR2(30) := 'Create_Interaction';
     l_api_version	CONSTANT NUMBER       := 1.0;
     l_api_name_full	CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
     l_return_status	VARCHAR2(1);

     l_org_id			NUMBER   := p_org_id;
     l_phone_area_code		VARCHAR2(10);
     l_phone_number		VARCHAR2(25);
     l_phone_extension		VARCHAR2(20);
     l_fax_area_code		VARCHAR2(10);
     l_fax_number		VARCHAR2(25);
     l_email_address		VARCHAR2(240);
     l_source_document_id	NUMBER   := p_source_document_id;
     l_source_document_name	VARCHAR2(80);
     l_reference_form		VARCHAR2(2000);
     l_source_document_status	VARCHAR2(80);
     l_follow_up_action		VARCHAR2(80);
     l_notes			VARCHAR2(2000);
     l_interaction_id		NUMBER;
     l_parent_id		NUMBER   := p_parent_interaction_id;
BEGIN
   -- Standard start of API savepoint
   SAVEPOINT create_interaction_pvt;

   -- Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
				      l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE
   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;

   -------------------------------------------------------------------------
   -- Apply business-rule validation to all required and passed parameters
   -- if validation level is set to FULL. Skip business-rule validation to
   -- all non-Service parameters if validation level is set to INT.
   -------------------------------------------------------------------------
   IF (p_validation_level > fnd_api.g_valid_level_none) THEN

      IF (p_validation_level > g_valid_level_int) THEN

	 -- Validate user and login session IDs
	 --------------------------------------
	 IF (p_user_id IS NULL) THEN
	    cs_core_util.add_null_parameter_msg(l_api_name_full, 'p_user_id');
	    RAISE fnd_api.g_exc_error;
	  ELSE
	    cs_core_util.validate_who_info
	      ( p_api_name		=> l_api_name_full,
		p_parameter_name_usr	=> 'p_user_id',
		p_parameter_name_log	=> 'p_login_id',
		p_user_id		=> p_user_id,
		p_login_id		=> p_login_id,
		x_return_status		=> l_return_status );
	    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	       RAISE fnd_api.g_exc_error;
	    END IF;
	 END IF;

	 -- Validate operating unit ID
	 -----------------------------
	 IF cs_core_util.is_multiorg_enabled THEN
	    IF (p_org_id IS NULL) THEN
	       cs_core_util.add_null_parameter_msg(l_api_name_full,
						   'p_org_id');
	       RAISE fnd_api.g_exc_error;
	     ELSE
	       cs_core_util.validate_operating_unit
		 ( p_api_name		=> l_api_name_full,
		   p_parameter_name	=> 'p_org_id',
		   p_org_id		=> p_org_id,
		   x_return_status	=> l_return_status );
	       IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
		  RAISE fnd_api.g_exc_error;
	       END IF;
	    END IF;
	  ELSE
	    IF (p_org_id IS NOT NULL) THEN
	       cs_core_util.add_param_ignored_msg(l_api_name_full, 'p_org_id');
	       l_org_id := NULL;
	    END IF;
	 END IF;

	 -- Validate customer ID
	 -----------------------
	 IF (p_customer_id IS NULL) THEN
	    cs_core_util.add_null_parameter_msg(l_api_name_full,
						'p_customer_id');
	    RAISE fnd_api.g_exc_error;
	  ELSE
	    cs_core_util.validate_customer
	      ( p_api_name		=> l_api_name_full,
		p_parameter_name	=> 'p_customer_id',
		p_customer_id	=> p_customer_id,
		x_return_status	=> l_return_status );
	    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	       RAISE fnd_api.g_exc_error;
	    END IF;
	 END IF;

	 -- Validate contact ID
	 ----------------------
	 IF (p_contact_id IS NOT NULL) THEN
	    cs_core_util.validate_customer_contact
	      ( p_api_name		=> l_api_name_full,
		p_parameter_name	=> 'p_contact_id',
		p_customer_contact_id	=> p_contact_id,
		p_customer_id		=> p_customer_id,
		p_org_id		=> l_org_id,
		x_return_status		=> l_return_status );
	    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	       RAISE fnd_api.g_exc_error;
	    END IF;
	 END IF;

	 -- Validate employee ID
	 -----------------------
	 IF (p_employee_id IS NOT NULL) THEN
	    cs_core_util.validate_person
	      ( p_api_name		=> l_api_name_full,
		p_parameter_name	=> 'p_employee_id',
		p_person_id		=> p_employee_id,
		x_return_status		=> l_return_status );
	    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	       RAISE fnd_api.g_exc_error;
	    END IF;
	 END IF;

      END IF;	/* p_validation_level > g_valid_level_int */

      -- Validate interaction type code
      ---------------------------------
      IF (p_interaction_type_code IS NULL) THEN
	 cs_core_util.add_null_parameter_msg(l_api_name_full,
					     'p_interaction_type_code');
	 RAISE fnd_api.g_exc_error;
       ELSE
	 cs_core_util.validate_lookup_code
	   ( p_api_name		=> l_api_name_full,
	     p_parameter_name	=> 'p_interaction_type_code',
	     p_lookup_code	=> p_interaction_type_code,
	     p_lookup_type	=> 'INTERACTION_TYPE',
	     x_return_status	=> l_return_status );
	 IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	    RAISE fnd_api.g_exc_error;
	 END IF;
      END IF;

      -- Validate interaction category code
      -------------------------------------
      IF (p_interaction_category_code IS NULL) THEN
	 cs_core_util.add_null_parameter_msg(l_api_name_full,
					     'p_interaction_category_code');
	 RAISE fnd_api.g_exc_error;
       ELSE
	 cs_core_util.validate_lookup_code
	   ( p_api_name		=> l_api_name_full,
	     p_parameter_name	=> 'p_interaction_category_code',
	     p_lookup_code	=> p_interaction_category_code,
	     p_lookup_type	=> 'INTERACTION_CATEGORY',
	     x_return_status	=> l_return_status );
	 IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	    RAISE fnd_api.g_exc_error;
	 END IF;
      END IF;

      -- Validate interaction method code
      -----------------------------------
      IF (p_interaction_method_code IS NULL) THEN
	 cs_core_util.add_null_parameter_msg(l_api_name_full,
					     'p_interaction_method_code');
	 RAISE fnd_api.g_exc_error;
       ELSE
	 cs_core_util.validate_lookup_code
	   ( p_api_name		=> l_api_name_full,
	     p_parameter_name	=> 'p_interaction_method_code',
	     p_lookup_code	=> p_interaction_method_code,
	     p_lookup_type	=> 'INTERACTION_METHOD',
	     x_return_status	=> l_return_status );
	 IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	    RAISE fnd_api.g_exc_error;
	 END IF;
      END IF;

      -- Validate interaction date
      ----------------------------
      IF (p_interaction_date IS NULL) THEN
	 cs_core_util.add_null_parameter_msg(l_api_name_full,
					     'p_interaction_date');
	 RAISE fnd_api.g_exc_error;
      END IF;

      -- Validate interaction document code
      -------------------------------------
      IF (p_interaction_document_code IS NOT NULL) THEN
	 cs_core_util.validate_lookup_code
	   ( p_api_name		=> l_api_name_full,
	     p_parameter_name	=> 'p_interaction_document_code',
	     p_lookup_code	=> p_interaction_document_code,
	     p_lookup_type	=> 'INTERACTION_DOCUMENT',
	     x_return_status	=> l_return_status );
	 IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	    RAISE fnd_api.g_exc_error;
	 END IF;
	 --
	 -- Validate document number when document type is not null
	 --
	 IF (p_source_document_name IS NOT NULL) then
	    cs_core_util.trunc_string_length(l_api_name_full, 'p_source_document_name',
				p_source_document_name, 80,
				l_source_document_name);
	    --
	    -- Validate document form and status when document number is not
	    -- null
	    --
	    IF (p_reference_form IS NOT NULL) then
	       cs_core_util.trunc_string_length(l_api_name_full, 'p_reference_form',
				   p_reference_form, 2000, l_reference_form);
	    END IF;
	    IF (p_source_document_status IS NOT NULL) then
	       cs_core_util.trunc_string_length(l_api_name_full, 'p_source_document_status',
				   p_source_document_status, 80,
				   l_source_document_status);
	    END IF;
	  ELSE
	    --
	    -- Ignore document form and status when document number is null
	    --
	    IF (p_reference_form IS NOT NULL) then
	       cs_core_util.add_param_ignored_msg(l_api_name_full,
						  'p_reference_form');
	    END IF;
	    IF (p_source_document_status IS NOT NULL) then
	       cs_core_util.add_param_ignored_msg(l_api_name_full,
						  'p_source_document_status');
	    END IF;
	 END IF;
       ELSE
	 --
	 -- Ignore document ID, number, form and status when document type is
	 -- null
	 --
	 IF (p_source_document_id IS NOT NULL) THEN
	    cs_core_util.add_param_ignored_msg(l_api_name_full,
					       'p_source_document_id');
	    l_source_document_id := NULL;
	 END IF;
	 IF (p_source_document_name IS NOT NULL) THEN
	    cs_core_util.add_param_ignored_msg(l_api_name_full,
					       'p_source_document_name');
	 END IF;
	 IF (p_reference_form IS NOT NULL) then
	    cs_core_util.add_param_ignored_msg(l_api_name_full,
					       'p_reference_form');
	 END IF;
	 IF (p_source_document_status IS NOT NULL) then
	    cs_core_util.add_param_ignored_msg(l_api_name_full,
					       'p_source_document_status');
	 END IF;
      END IF;	/* p_interaction_document_code IS NOT NULL */

      -- Validate public flag
      -----------------------
      IF (p_public_flag <> 'Y') AND (p_public_flag <> 'N') THEN
	 cs_core_util.add_invalid_argument_msg(l_api_name_full, p_public_flag,
					       'p_public_flag');
	 RAISE fnd_api.g_exc_error;
      END IF;

      -- Validate parent interaction ID
      ---------------------------------
      IF (p_parent_interaction_id IS NOT NULL) THEN
	 cs_interaction_utl.validate_parent_interaction
	   ( p_api_name			=> l_api_name_full,
	     p_parameter_name		=> 'p_parent_interaction_id',
	     p_parent_interaction_id	=> p_parent_interaction_id,
	     p_org_id			=> l_org_id,
	     x_return_status		=> l_return_status );
	 IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	    RAISE fnd_api.g_exc_error;
	 END IF;
      END IF;

      -- Validate descriptive flexfield values
      ----------------------------------------
      IF ((p_attribute1 || p_attribute2 || p_attribute3 || p_attribute4 ||
	   p_attribute5 || p_attribute6 || p_attribute7 || p_attribute8 ||
	   p_attribute9 || p_attribute10 || p_attribute11 || p_attribute12 ||
	   p_attribute13 || p_attribute14 || p_attribute15 ||
	   p_attribute_category) IS NOT NULL) THEN
	 cs_core_util.validate_desc_flex
	   ( p_api_name		=> l_api_name_full,
	     p_desc_flex_name	=> 'CS_INTERACTIONS',
	     p_column_name1	=> 'ATTRIBUTE1',
	     p_column_name2	=> 'ATTRIBUTE2',
	     p_column_name3	=> 'ATTRIBUTE3',
	     p_column_name4	=> 'ATTRIBUTE4',
	     p_column_name5	=> 'ATTRIBUTE5',
	     p_column_name6	=> 'ATTRIBUTE6',
	     p_column_name7	=> 'ATTRIBUTE7',
	     p_column_name8	=> 'ATTRIBUTE8',
	     p_column_name9	=> 'ATTRIBUTE9',
	     p_column_name10	=> 'ATTRIBUTE10',
	     p_column_name11	=> 'ATTRIBUTE11',
	     p_column_name12	=> 'ATTRIBUTE12',
	     p_column_name13	=> 'ATTRIBUTE13',
	     p_column_name14	=> 'ATTRIBUTE14',
	     p_column_name15	=> 'ATTRIBUTE15',
	     p_column_value1	=> p_attribute1,
	     p_column_value2	=> p_attribute2,
	     p_column_value3	=> p_attribute3,
	     p_column_value4	=> p_attribute4,
	     p_column_value5	=> p_attribute5,
	     p_column_value6	=> p_attribute6,
	     p_column_value7	=> p_attribute7,
	     p_column_value8	=> p_attribute8,
	     p_column_value9	=> p_attribute9,
	     p_column_value10	=> p_attribute10,
	     p_column_value11	=> p_attribute11,
	     p_column_value12	=> p_attribute12,
	     p_column_value13	=> p_attribute13,
	     p_column_value14	=> p_attribute14,
	     p_column_value15	=> p_attribute15,
	     p_context_value	=> p_attribute_category,
	     p_resp_appl_id	=> p_resp_appl_id,
	     p_resp_id		=> p_resp_id,
	     x_return_status	=> l_return_status);
	 IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	    RAISE fnd_api.g_exc_error;
	 END IF;
      END IF;

      -- Validate string lengths
      --------------------------
      IF (p_phone_area_code IS NOT NULL) then
	 cs_core_util.trunc_string_length(l_api_name_full, 'p_phone_area_code',
					  p_phone_area_code, 10,
					  l_phone_area_code);
      END IF;
      IF (p_phone_number IS NOT NULL) then
	 cs_core_util.trunc_string_length(l_api_name_full, 'p_phone_number',
					  p_phone_number, 25, l_phone_number);
      END IF;
      IF (p_phone_extension IS NOT NULL) then
	 cs_core_util.trunc_string_length(l_api_name_full, 'p_phone_extension',
					  p_phone_extension, 20,
					  l_phone_extension);
      END IF;
      IF (p_fax_area_code IS NOT NULL) then
	 cs_core_util.trunc_string_length(l_api_name_full, 'p_fax_area_code',
					  p_fax_area_code, 10,
					  l_fax_area_code);
      END IF;
      IF (p_fax_number IS NOT NULL) then
	 cs_core_util.trunc_string_length(l_api_name_full, 'p_fax_number',
					  p_fax_number, 25, l_fax_number);
      END IF;
      IF (p_email_address IS NOT NULL) then
	 cs_core_util.trunc_string_length(l_api_name_full, 'p_email_address',
					  p_email_address, 240,
					  l_email_address);
      END IF;
      IF (p_follow_up_action IS NOT NULL) then
	 cs_core_util.trunc_string_length(l_api_name_full,
					  'p_follow_up_action',
					  p_follow_up_action, 80,
					  l_follow_up_action);
      END IF;
      IF (p_notes IS NOT NULL) then
	 cs_core_util.trunc_string_length(l_api_name_full, 'p_notes', p_notes,
					  2000, l_notes);
      END IF;

    ELSE

      l_phone_area_code		:= p_phone_area_code;
      l_phone_number		:= p_phone_number;
      l_phone_extension		:= p_phone_extension;
      l_fax_area_code		:= p_fax_area_code;
      l_fax_number		:= p_fax_number;
      l_email_address		:= p_email_address;
      l_source_document_name	:= p_source_document_name;
      l_reference_form		:= p_reference_form;
      l_source_document_status	:= p_source_document_status;
      l_follow_up_action	:= p_follow_up_action;
      l_notes			:= p_notes;

   END IF;	/* p_validation_level > fnd_api.g_valid_level_none */

   -------------------------------------------------------------------------
   -- Perform the database operation. Generate the interaction ID from the
   -- sequence, then insert the sequence number and passed in attributes
   -- into the CS_INTERACTIONS table.
   -------------------------------------------------------------------------
   SELECT cs_interactions_s.NEXTVAL INTO l_interaction_id FROM dual;

   --
   -- Default parent interaction ID if missing
   --
   IF (p_parent_interaction_id IS NULL) THEN
      l_parent_id := l_interaction_id;
   END IF;

   INSERT INTO cs_interactions
     ( interaction_id,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       org_id,
       customer_id,
       contact_id,
       contact_lastname,
       contact_firstname,
       phone_area_code,
       phone_number,
       phone_extension,
       fax_area_code,
       fax_number,
       email_address,
       interaction_type_code,
       interaction_category_code,
       interaction_method_code,
       interaction_date,
       interaction_document_code,
       source_document_id,
       source_document_name,
       reference_form,
       source_document_status,
       employee_id,
       public_flag,
       follow_up_action,
       notes,
       parent_interaction_id,
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
       attribute_category )
   VALUES
     ( l_interaction_id,
       p_user_id,
       Sysdate,
       p_user_id,
       Sysdate,
       p_login_id,
       l_org_id,
       p_customer_id,
       p_contact_id,
       p_contact_lastname,
       p_contact_firstname,
       l_phone_area_code,
       l_phone_number,
       l_phone_extension,
       l_fax_area_code,
       l_fax_number,
       l_email_address,
       p_interaction_type_code,
       p_interaction_category_code,
       p_interaction_method_code,
       p_interaction_date,
       p_interaction_document_code,
       l_source_document_id,
       l_source_document_name,
       l_reference_form,
       l_source_document_status,
       p_employee_id,
       p_public_flag,
       l_follow_up_action,
       l_notes,
       l_parent_id,
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
       p_attribute_category );

   --
   -- Set OUT value
   --
   x_interaction_id := l_interaction_id;

   -- Standard check of p_commit
   IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
   fnd_msg_pub.count_and_get
     ( p_count	=> x_msg_count,
       p_data	=> x_msg_data );
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_interaction_pvt;
      x_return_status := fnd_api.g_ret_sts_error ;
      fnd_msg_pub.count_and_get
	( p_count	=> x_msg_count,
	  p_data	=> x_msg_data );
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_interaction_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      fnd_msg_pub.count_and_get
	( p_count	=> x_msg_count,
	  p_data	=> x_msg_data );
   WHEN OTHERS THEN
      ROLLBACK TO create_interaction_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get
	( p_count	=> x_msg_count,
	  p_data	=> x_msg_data );
END Create_Interaction;

END CS_Interaction_PVT;

/
