--------------------------------------------------------
--  DDL for Package Body HZ_DYN_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DYN_VALIDATION" AS
/*$Header: ARHDVSB.pls 120.5 2005/10/30 03:52:05 appldev noship $ */

  -- declaration of private global variables
  g_debug_count         NUMBER := 0;
  --g_debug               BOOLEAN := FALSE;

  -- local error pragma
  compile_error         EXCEPTION;
  PRAGMA EXCEPTION_INIT (compile_error, -6550);

  /*=======================================================================+
   | PRIVATE PROCEDURE enable_debug                                        |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Turn on debug mode.                                                 |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.enable_debug                                       |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   12-NOV-2001    J. del Callar      Created.                          |
   +=======================================================================*/

  /*PROCEDURE enable_debug IS
  BEGIN
    g_debug_count := g_debug_count + 1;
    IF g_debug_count = 1 THEN
      IF fnd_profile.value('HZ_API_FILE_DEBUG_ON') = 'Y' OR
         fnd_profile.value('HZ_API_DBMS_DEBUG_ON') = 'Y'
      THEN
         hz_utility_v2pub.enable_debug;
         g_debug := TRUE;
      END IF;
    END IF;
  END enable_debug;
  */


  /*=======================================================================+
   | PRIVATE PROCEDURE disable_debug                                       |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Turn off debug mode.                                                |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.disable_debug                                      |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   12-NOV-2001    J. del Callar      Created.                          |
   +=======================================================================*/

  /*PROCEDURE disable_debug IS
  BEGIN
    IF g_debug THEN
      g_debug_count := g_debug_count - 1;
      IF g_debug_count = 0 THEN
        hz_utility_v2pub.disable_debug;
        g_debug := FALSE;
      END IF;
    END IF;
  END disable_debug;
  */


  /*=======================================================================+
   | PRIVATE PROCEDURE create_party_gt                                     |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Used to insert a record into the party global temporary table.      |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_party_v2pub.party_rec_type                                       |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   12-NOV-2001    J. del Callar      Created.                          |
   +=======================================================================*/

  FUNCTION create_party_gt (x_party IN hz_party_v2pub.party_rec_type)
  RETURN NUMBER IS
    CURSOR partyidcur IS
      SELECT hz_party_val_gt_s.NEXTVAL
      FROM   DUAL;

    l_party_id NUMBER(15);
    l_debug_prefix    VARCHAR2(30) := '';
  BEGIN
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'create party',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;


    -- Get the party ID.
    OPEN partyidcur;
    FETCH partyidcur INTO l_party_id;
    IF partyidcur%NOTFOUND THEN
      -- Close the cursor and raise an error if the group ID could not be
      -- selected from the sequence.
      CLOSE partyidcur;

      fnd_message.set_name('AR', 'HZ_DV_ID_NOT_FOUND');
      fnd_message.set_token('SEQUENCE', 'hz_party_val_gt_s');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE partyidcur;

    -- Stage the data into the party temporary table.
    INSERT INTO hz_party_val_gt (temp_id,
                                 party_number,
                                 validated_flag,
                                 orig_system_reference,
                                 status,
                                 category_code,
                                 salutation,
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
                                 attribute24)
    VALUES (l_party_id,
            x_party.party_number,
            x_party.validated_flag,
            x_party.orig_system_reference,
            x_party.status,
            x_party.category_code,
            x_party.salutation,
            x_party.attribute_category,
            x_party.attribute1,
            x_party.attribute2,
            x_party.attribute3,
            x_party.attribute4,
            x_party.attribute5,
            x_party.attribute6,
            x_party.attribute7,
            x_party.attribute8,
            x_party.attribute9,
            x_party.attribute10,
            x_party.attribute11,
            x_party.attribute12,
            x_party.attribute13,
            x_party.attribute14,
            x_party.attribute15,
            x_party.attribute16,
            x_party.attribute17,
            x_party.attribute18,
            x_party.attribute19,
            x_party.attribute20,
            x_party.attribute21,
            x_party.attribute22,
            x_party.attribute23,
            x_party.attribute24);

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'  returning party ID='||l_party_id,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

    RETURN l_party_id;
  END create_party_gt;


  /*=======================================================================+
   | PRIVATE PROCEDURE create_relationship_gt                              |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Used to insert a record into the relationship global temporary      |
   |   table.                                                              |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_relationship_v2pub.relationship_rec_type                         |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   12-NOV-2001    J. del Callar      Created.                          |
   +=======================================================================*/

  FUNCTION create_relationship_gt (
    x_relationship IN hz_relationship_v2pub.relationship_rec_type,
    x_temp_id      IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    CURSOR relidcur IS
      SELECT hz_relationship_val_gt_s.NEXTVAL
      FROM   DUAL;

    l_relationship_id NUMBER(15);
    l_party_id        NUMBER(15);
    l_debug_prefix    VARCHAR2(30) := '';
  BEGIN
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'create relationship',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

    -- Create the party record
    l_party_id := create_party_gt(x_relationship.party_rec);

    -- Get the relationship ID.
    IF x_temp_id IS NOT NULL THEN
      l_relationship_id := x_temp_id;
    ELSE
      OPEN relidcur;
      FETCH relidcur INTO l_relationship_id;
      IF relidcur%NOTFOUND THEN
        -- Close the cursor and raise an error if the relationship ID
        -- could not be selected from the sequence.
        CLOSE relidcur;

        fnd_message.set_name('AR', 'HZ_DV_ID_NOT_FOUND');
        fnd_message.set_token('SEQUENCE', 'hz_relationship_val_gt_s');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE relidcur;
    END IF;

    -- Create the relationship record.
    INSERT INTO hz_relationship_val_gt(temp_id,
                                       temp_party_id,
                                       subject_id,
                                       subject_type,
                                       subject_table_name,
                                       object_id,
                                       object_type,
                                       object_table_name,
                                       relationship_code,
                                       relationship_type,
                                       comments,
                                       start_date,
                                       end_date,
                                       status,
                                       content_source_type,
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
                                       created_by_module,
                                       application_id)
    VALUES (l_relationship_id,
            l_party_id,
            x_relationship.subject_id,
            x_relationship.subject_type,
            x_relationship.subject_table_name,
            x_relationship.object_id,
            x_relationship.object_type,
            x_relationship.object_table_name,
            x_relationship.relationship_code,
            x_relationship.relationship_type,
            x_relationship.comments,
            x_relationship.start_date,
            x_relationship.end_date,
            x_relationship.status,
            x_relationship.content_source_type,
            x_relationship.attribute_category,
            x_relationship.attribute1,
            x_relationship.attribute2,
            x_relationship.attribute3,
            x_relationship.attribute4,
            x_relationship.attribute5,
            x_relationship.attribute6,
            x_relationship.attribute7,
            x_relationship.attribute8,
            x_relationship.attribute9,
            x_relationship.attribute10,
            x_relationship.attribute11,
            x_relationship.attribute12,
            x_relationship.attribute13,
            x_relationship.attribute14,
            x_relationship.attribute15,
            x_relationship.attribute16,
            x_relationship.attribute17,
            x_relationship.attribute18,
            x_relationship.attribute19,
            x_relationship.attribute20,
            x_relationship.created_by_module,
            x_relationship.application_id);

    RETURN l_relationship_id;
  END create_relationship_gt;


  /*=======================================================================+
   | PRIVATE PROCEDURE exec_procedure                                      |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Execute a dynamic procedure call.                                   |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   12-NOV-2001    J. del Callar      Created.                          |
   |   23-JAN-2004    Rajesh Jose        Bug 2776412                       |
   +=======================================================================*/

  PROCEDURE exec_procedure (x_profile_name IN VARCHAR2,
                            x_temp_id      IN NUMBER) IS
    l_exec_string       VARCHAR2(300);
    l_procedure_name    VARCHAR2(240) := NULL;
    l_debug_prefix      VARCHAR2(30) := '';
    -- Added for Bug 2776412
    l_return_status     VARCHAR2(1);
  BEGIN
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'exec_procedure (' || x_profile_name|| ',' || x_temp_id || ')',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

    -- initialize API return status to success
    l_return_status := fnd_api.g_ret_sts_success;

    -- get the name of the procedure being executed.
    l_procedure_name := fnd_profile.value(x_profile_name);

    -- raise an error if no value is set for the profile option.
    IF l_procedure_name IS NULL THEN
      fnd_message.set_name('AR', 'HZ_DV_NULL_PROFILE_VALUE');
      fnd_message.set_token('PROFILE', x_profile_name);
      fnd_msg_pub.add;
      RAISE hz_dyn_validation.null_profile_value;
    END IF;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'  l_procedure_name=' || l_procedure_name,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

    -- Create the execution string.

    l_exec_string := 'BEGIN ' || l_procedure_name ||
                     '(' ||x_temp_id|| ',:l_return_status); END;'; -- Bug 2776412

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'  Executing: ' || l_exec_string,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

    -- Execute the dynamic call.
    EXECUTE IMMEDIATE l_exec_string USING IN OUT l_return_status; -- Bug 2776412

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
       RAISE hz_dyn_validation.execution_error;
    END IF;


  EXCEPTION
    -- Catch instances where the procedure specified in the profile option
    -- has not been defined in the database.
    WHEN compile_error THEN
      fnd_message.set_name('AR', 'HZ_DV_EXEC_ERROR');
      fnd_message.set_token('PROCEDURE', l_procedure_name);
      fnd_message.set_token('ERRM', SQLERRM);
      fnd_msg_pub.add;
      RAISE hz_dyn_validation.execution_error;

  END exec_procedure;


  /*=======================================================================+
   | PUBLIC PROCEDURE validate_organization                                |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate an organization given the name of the validation procedure |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_party_v2pub.organization_rec_type                                |
   | MODIFICATION HISTORY                                                  |
   |   12-NOV-2001    J. del Callar      Created.                          |
   +=======================================================================*/

  PROCEDURE validate_organization (
    x_organization       IN hz_party_v2pub.organization_rec_type,
    x_validation_profile IN VARCHAR2,
    x_temp_id            IN NUMBER DEFAULT NULL
  ) IS
    CURSOR orgidcur IS
      SELECT hz_org_profile_val_gt_s.NEXTVAL
      FROM   DUAL;

    l_org_profile_id NUMBER(15);
    l_party_id       NUMBER(15);
    l_debug_prefix   VARCHAR2(30) := '';
  BEGIN
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'validate_organization, x_validation_profile='
                             || x_validation_profile,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

    -- Check the profile option name.
    -- Raise an error if it is not an "allowed" profile option.
    IF x_validation_profile <> 'HZ_BANK_VALIDATION_PROCEDURE'
       AND x_validation_profile <> 'HZ_BANK_BRANCH_VALIDATION_PROCEDURE'
    THEN
      fnd_message.set_name('AR', 'HZ_DV_INVALID_PROFILE_OPTION');
      fnd_message.set_token('PROFILE', x_validation_profile);
      fnd_msg_pub.add;
      RAISE hz_dyn_validation.invalid_profile_option;
    END IF;

    -- Create the party record
    l_party_id := create_party_gt(x_organization.party_rec);

    -- Get the org profile ID.
    IF x_temp_id IS NOT NULL THEN
      l_org_profile_id := x_temp_id;
    ELSE
      OPEN orgidcur;
      FETCH orgidcur INTO l_org_profile_id;
      IF orgidcur%NOTFOUND THEN
        -- Close the cursor and raise an error if the group ID could not be
        -- selected from the sequence.
        CLOSE orgidcur;

        fnd_message.set_name('AR', 'HZ_DV_ID_NOT_FOUND');
        fnd_message.set_token('SEQUENCE', 'hz_org_profile_val_gt_s');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE orgidcur;
    END IF;

   -- Bug 3814832
    DELETE FROM  hz_org_profile_val_gt;
    -- create the org profile record
    INSERT INTO hz_org_profile_val_gt(organization_name,
                                      temp_id,
                                      temp_party_id,
                                      duns_number_c,
                                      enquiry_duns,
                                      ceo_name,
                                      ceo_title,
                                      principal_name,
                                      principal_title,
                                      legal_status,
                                      control_yr,
                                      employees_total,
                                      hq_branch_ind,
                                      branch_flag,
                                      oob_ind,
                                      line_of_business,
                                      cong_dist_code,
                                      sic_code,
                                      import_ind,
                                      export_ind,
                                      labor_surplus_ind,
                                      debarment_ind,
                                      minority_owned_ind,
                                      minority_owned_type,
                                      woman_owned_ind,
                                      disadv_8a_ind,
                                      small_bus_ind,
                                      rent_own_ind,
                                      debarments_count,
                                      debarments_date,
                                      failure_score,
                                      failure_score_natnl_percentile,
                                      failure_score_override_code,
                                      failure_score_commentary,
                                      global_failure_score,
                                      db_rating,
                                      credit_score,
                                      credit_score_commentary,
                                      paydex_score,
                                      paydex_three_months_ago,
                                      paydex_norm,
                                      best_time_contact_begin,
                                      best_time_contact_end,
                                      organization_name_phonetic,
                                      tax_reference,
                                      gsa_indicator_flag,
                                      jgzz_fiscal_code,
                                      analysis_fy,
                                      fiscal_yearend_month,
                                      curr_fy_potential_revenue,
                                      next_fy_potential_revenue,
                                      year_established,
                                      mission_statement,
                                      organization_type,
                                      business_scope,
                                      corporation_class,
                                      known_as,
                                      known_as2,
                                      known_as3,
                                      known_as4,
                                      known_as5,
                                      local_bus_iden_type,
                                      local_bus_identifier,
                                      pref_functional_currency,
                                      registration_type,
                                      total_employees_text,
                                      total_employees_ind,
                                      total_emp_est_ind,
                                      total_emp_min_ind,
                                      parent_sub_ind,
                                      incorp_year,
                                      sic_code_type,
                                      public_private_ownership_flag,
                                      internal_flag,
                                      local_activity_code_type,
                                      local_activity_code,
                                      emp_at_primary_adr,
                                      emp_at_primary_adr_text,
                                      emp_at_primary_adr_est_ind,
                                      emp_at_primary_adr_min_ind,
                                      high_credit,
                                      avg_high_credit,
                                      total_payments,
                                      credit_score_class,
                                      credit_score_natl_percentile,
                                      credit_score_incd_default,
                                      credit_score_age,
                                      credit_score_date,
                                      credit_score_commentary2,
                                      credit_score_commentary3,
                                      credit_score_commentary4,
                                      credit_score_commentary5,
                                      credit_score_commentary6,
                                      credit_score_commentary7,
                                      credit_score_commentary8,
                                      credit_score_commentary9,
                                      credit_score_commentary10,
                                      failure_score_class,
                                      failure_score_incd_default,
                                      failure_score_age,
                                      failure_score_date,
                                      failure_score_commentary2,
                                      failure_score_commentary3,
                                      failure_score_commentary4,
                                      failure_score_commentary5,
                                      failure_score_commentary6,
                                      failure_score_commentary7,
                                      failure_score_commentary8,
                                      failure_score_commentary9,
                                      failure_score_commentary10,
                                      maximum_credit_recommendation,
                                      maximum_credit_currency_code,
                                      displayed_duns_party_id,
                                      content_source_type,
                                      content_source_number,
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
                                      created_by_module,
                                      application_id)
    VALUES (x_organization.organization_name,
            l_org_profile_id,
            l_party_id,
            x_organization.duns_number_c,
            x_organization.enquiry_duns,
            x_organization.ceo_name,
            x_organization.ceo_title,
            x_organization.principal_name,
            x_organization.principal_title,
            x_organization.legal_status,
            x_organization.control_yr,
            x_organization.employees_total,
            x_organization.hq_branch_ind,
            x_organization.branch_flag,
            x_organization.oob_ind,
            x_organization.line_of_business,
            x_organization.cong_dist_code,
            x_organization.sic_code,
            x_organization.import_ind,
            x_organization.export_ind,
            x_organization.labor_surplus_ind,
            x_organization.debarment_ind,
            x_organization.minority_owned_ind,
            x_organization.minority_owned_type,
            x_organization.woman_owned_ind,
            x_organization.disadv_8a_ind,
            x_organization.small_bus_ind,
            x_organization.rent_own_ind,
            x_organization.debarments_count,
            x_organization.debarments_date,
            x_organization.failure_score,
            x_organization.failure_score_natnl_percentile,
            x_organization.failure_score_override_code,
            x_organization.failure_score_commentary,
            x_organization.global_failure_score,
            x_organization.db_rating,
            x_organization.credit_score,
            x_organization.credit_score_commentary,
            x_organization.paydex_score,
            x_organization.paydex_three_months_ago,
            x_organization.paydex_norm,
            x_organization.best_time_contact_begin,
            x_organization.best_time_contact_end,
            x_organization.organization_name_phonetic,
            x_organization.tax_reference,
            x_organization.gsa_indicator_flag,
            x_organization.jgzz_fiscal_code,
            x_organization.analysis_fy,
            x_organization.fiscal_yearend_month,
            x_organization.curr_fy_potential_revenue,
            x_organization.next_fy_potential_revenue,
            x_organization.year_established,
            x_organization.mission_statement,
            x_organization.organization_type,
            x_organization.business_scope,
            x_organization.corporation_class,
            x_organization.known_as,
            x_organization.known_as2,
            x_organization.known_as3,
            x_organization.known_as4,
            x_organization.known_as5,
            x_organization.local_bus_iden_type,
            x_organization.local_bus_identifier,
            x_organization.pref_functional_currency,
            x_organization.registration_type,
            x_organization.total_employees_text,
            x_organization.total_employees_ind,
            x_organization.total_emp_est_ind,
            x_organization.total_emp_min_ind,
            x_organization.parent_sub_ind,
            x_organization.incorp_year,
            x_organization.sic_code_type,
            x_organization.public_private_ownership_flag,
            x_organization.internal_flag,
            x_organization.local_activity_code_type,
            x_organization.local_activity_code,
            x_organization.emp_at_primary_adr,
            x_organization.emp_at_primary_adr_text,
            x_organization.emp_at_primary_adr_est_ind,
            x_organization.emp_at_primary_adr_min_ind,
            x_organization.high_credit,
            x_organization.avg_high_credit,
            x_organization.total_payments,
            x_organization.credit_score_class,
            x_organization.credit_score_natl_percentile,
            x_organization.credit_score_incd_default,
            x_organization.credit_score_age,
            x_organization.credit_score_date,
            x_organization.credit_score_commentary2,
            x_organization.credit_score_commentary3,
            x_organization.credit_score_commentary4,
            x_organization.credit_score_commentary5,
            x_organization.credit_score_commentary6,
            x_organization.credit_score_commentary7,
            x_organization.credit_score_commentary8,
            x_organization.credit_score_commentary9,
            x_organization.credit_score_commentary10,
            x_organization.failure_score_class,
            x_organization.failure_score_incd_default,
            x_organization.failure_score_age,
            x_organization.failure_score_date,
            x_organization.failure_score_commentary2,
            x_organization.failure_score_commentary3,
            x_organization.failure_score_commentary4,
            x_organization.failure_score_commentary5,
            x_organization.failure_score_commentary6,
            x_organization.failure_score_commentary7,
            x_organization.failure_score_commentary8,
            x_organization.failure_score_commentary9,
            x_organization.failure_score_commentary10,
            x_organization.maximum_credit_recommendation,
            x_organization.maximum_credit_currency_code,
            x_organization.displayed_duns_party_id,
            x_organization.content_source_type,
            x_organization.content_source_number,
            x_organization.attribute_category,
            x_organization.attribute1,
            x_organization.attribute2,
            x_organization.attribute3,
            x_organization.attribute4,
            x_organization.attribute5,
            x_organization.attribute6,
            x_organization.attribute7,
            x_organization.attribute8,
            x_organization.attribute9,
            x_organization.attribute10,
            x_organization.attribute11,
            x_organization.attribute12,
            x_organization.attribute13,
            x_organization.attribute14,
            x_organization.attribute15,
            x_organization.attribute16,
            x_organization.attribute17,
            x_organization.attribute18,
            x_organization.attribute19,
            x_organization.attribute20,
            x_organization.created_by_module,
            x_organization.application_id);

    -- Execute dynamic call.
    exec_procedure(x_validation_profile, l_org_profile_id);

  END validate_organization;


  /*=======================================================================+
   | PUBLIC PROCEDURE validate_group                                       |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate a group given the name of the validation procedure         |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_party_v2pub.group_rec_type                                       |
   | MODIFICATION HISTORY                                                  |
   |   12-NOV-2001    J. del Callar      Created.                          |
   +=======================================================================*/

  PROCEDURE validate_group (
    x_group              IN hz_party_v2pub.group_rec_type,
    x_validation_profile IN VARCHAR2,
    x_temp_id            IN NUMBER DEFAULT NULL
  ) IS
    CURSOR grpidcur IS
      SELECT hz_group_val_gt_s.NEXTVAL
      FROM   DUAL;

    l_group_id    NUMBER(15);
    l_party_id    NUMBER(15);
    l_debug_prefix   VARCHAR2(30) := '';
  BEGIN
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'validate_group, x_validation_profile='
                             || x_validation_profile,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

    -- Check the profile option name.
    -- Raise an error if it is not an "allowed" profile option.
    IF x_validation_profile <> 'HZ_BANKING_GROUP_VALIDATION_PROCEDURE'
    THEN
      fnd_message.set_name('AR', 'HZ_DV_INVALID_PROFILE_OPTION');
      fnd_message.set_token('PROFILE', x_validation_profile);
      fnd_msg_pub.add;
      RAISE hz_dyn_validation.invalid_profile_option;
    END IF;

    -- Create the party record
    l_party_id := create_party_gt(x_group.party_rec);

    -- Get the group ID.
    IF x_temp_id IS NOT NULL THEN
      l_group_id := x_temp_id;
    ELSE
      OPEN grpidcur;
      FETCH grpidcur INTO l_group_id;

      IF grpidcur%NOTFOUND THEN
        -- Close the cursor and raise an error if the group ID could not be
        -- selected from the sequence.
        CLOSE grpidcur;

        fnd_message.set_name('AR', 'HZ_DV_ID_NOT_FOUND');
        fnd_message.set_token('SEQUENCE', 'hz_group_val_gt_s');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE grpidcur;
    END IF;

    -- Bug 3814832
    DELETE FROM hz_group_val_gt;
    -- Create the group record.
    INSERT INTO hz_group_val_gt(group_name,
                                temp_id,
                                temp_party_id,
                                group_type,
                                created_by_module,
                                application_id)
    VALUES (x_group.group_name,
            l_group_id,
            l_party_id,
            x_group.group_type,
            x_group.created_by_module,
            x_group.application_id);

    -- Execute dynamic call.
    exec_procedure(x_validation_profile, l_group_id);

  END validate_group;


  /*=======================================================================+
   | PUBLIC PROCEDURE validate_relationship                                |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate a relationship given the name of the validation procedure  |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_relationship_v2pub.relationship_rec_type                         |
   | MODIFICATION HISTORY                                                  |
   |   12-NOV-2001    J. del Callar      Created.                          |
   +=======================================================================*/

  PROCEDURE validate_relationship (
    x_relationship       IN hz_relationship_v2pub.relationship_rec_type,
    x_validation_profile IN VARCHAR2,
    x_temp_id            IN NUMBER DEFAULT NULL
  ) IS
    l_relationship_id  NUMBER(15);
    l_debug_prefix    VARCHAR2(30) := '';
  BEGIN
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'validate_relationship_member, x_validation_prof='
                             || x_validation_profile,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

    -- Check the profile option name.
    -- Raise an error if it is not an "allowed" profile option.
    IF x_validation_profile NOT IN
        ('HZ_BANKING_GROUP_MEMBER_VALIDATION_PROCEDURE',
         'HZ_CLEARINGHOUSE_ASSIGNMENT_VALIDATION_PROCEDURE')
    THEN
      fnd_message.set_name('AR', 'HZ_DV_INVALID_PROFILE_OPTION');
      fnd_message.set_token('PROFILE', x_validation_profile);
      fnd_msg_pub.add;
      RAISE hz_dyn_validation.invalid_profile_option;
    END IF;

    -- Create the relationship (includes the sub-party, if any).
    l_relationship_id := create_relationship_gt(x_relationship, x_temp_id);

    -- Execute dynamic call.
    exec_procedure(x_validation_profile, l_relationship_id);

  END validate_relationship;


  /*=======================================================================+
   | PUBLIC PROCEDURE validate_org_contact                                 |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate an organization contact given the name of the validation   |
   |   procedure                                                           |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_party_contact_v2pub.org_contact_rec_type                         |
   | MODIFICATION HISTORY                                                  |
   |   12-NOV-2001    J. del Callar      Created.                          |
   +=======================================================================*/

  PROCEDURE validate_org_contact (
    x_org_contact        IN hz_party_contact_v2pub.org_contact_rec_type,
    x_validation_profile IN VARCHAR2,
    x_temp_id            IN NUMBER DEFAULT NULL
  ) IS
    CURSOR ocidcur IS
      SELECT hz_contact_val_gt_s.NEXTVAL
      FROM   DUAL;

    l_org_contact_id    NUMBER(15);
    l_relationship_id   NUMBER(15);
    l_debug_prefix      VARCHAR2(30) := '';
  BEGIN
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'validate_org_contact, x_validation_profile='|| x_validation_profile,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

    -- Check the profile option name.
    -- Raise an error if it is not an "allowed" profile option.
    IF x_validation_profile <> 'HZ_BANK_BRANCH_CONTACT_VALIDATION_PROCEDURE'
       AND x_validation_profile <> 'HZ_BANK_CONTACT_VALIDATION_PROCEDURE'
    THEN
      fnd_message.set_name('AR', 'HZ_DV_INVALID_PROFILE_OPTION');
      fnd_message.set_token('PROFILE', x_validation_profile);
      fnd_msg_pub.add;
      RAISE hz_dyn_validation.invalid_profile_option;
    END IF;

    -- Create the relationship record
    l_relationship_id :=
      create_relationship_gt(x_org_contact.party_rel_rec);

    -- Get the org_contact ID.
    IF x_temp_id IS NOT NULL THEN
      l_org_contact_id := x_temp_id;
    ELSE
      OPEN ocidcur;
      FETCH ocidcur INTO l_org_contact_id;

      IF ocidcur%NOTFOUND THEN
        -- Close the cursor and raise an error if the org_contact ID could not
        -- be selected from the sequence.
        CLOSE ocidcur;

        fnd_message.set_name('AR', 'HZ_DV_ID_NOT_FOUND');
        fnd_message.set_token('SEQUENCE', 'hz_contact_val_gt_s');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE ocidcur;
    END IF;

    -- Bug 3814832
    DELETE FROM hz_org_contact_val_gt;
    -- Create the org_contact record.
    INSERT INTO hz_org_contact_val_gt(temp_id,
                                      temp_party_id,
                                      comments,
                                      contact_number,
                                      department_code,
                                      department,
                                      title,
                                      job_title,
                                      decision_maker_flag,
                                      job_title_code,
                                      reference_use_flag,
                                      rank,
                                      party_site_id,
                                      orig_system_reference,
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
                                      created_by_module,
                                      application_id)
    VALUES (l_org_contact_id,
            l_relationship_id,
            x_org_contact.comments,
            x_org_contact.contact_number,
            x_org_contact.department_code,
            x_org_contact.department,
            x_org_contact.title,
            x_org_contact.job_title,
            x_org_contact.decision_maker_flag,
            x_org_contact.job_title_code,
            x_org_contact.reference_use_flag,
            x_org_contact.rank,
            x_org_contact.party_site_id,
            x_org_contact.orig_system_reference,
            x_org_contact.attribute_category,
            x_org_contact.attribute1,
            x_org_contact.attribute2,
            x_org_contact.attribute3,
            x_org_contact.attribute4,
            x_org_contact.attribute5,
            x_org_contact.attribute6,
            x_org_contact.attribute7,
            x_org_contact.attribute8,
            x_org_contact.attribute9,
            x_org_contact.attribute10,
            x_org_contact.attribute11,
            x_org_contact.attribute12,
            x_org_contact.attribute13,
            x_org_contact.attribute14,
            x_org_contact.attribute15,
            x_org_contact.attribute16,
            x_org_contact.attribute17,
            x_org_contact.attribute18,
            x_org_contact.attribute19,
            x_org_contact.attribute20,
            x_org_contact.created_by_module,
            x_org_contact.application_id);

    -- Execute dynamic call.
    exec_procedure(x_validation_profile, l_org_contact_id);

  END validate_org_contact;


  /*=======================================================================+
   | PUBLIC PROCEDURE validate_party_site                                  |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate a party site given the name of the validation procedure    |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_party_site_v2pub.party_site_rec_type                             |
   | MODIFICATION HISTORY                                                  |
   |   11-13-2001    J. del Callar      Created.                           |
   +=======================================================================*/

  PROCEDURE validate_party_site (
    x_party_site         IN hz_party_site_v2pub.party_site_rec_type,
    x_validation_profile IN VARCHAR2,
    x_temp_id            IN NUMBER DEFAULT NULL
  ) IS
    CURSOR psidcur IS
      SELECT hz_party_site_val_gt_s.NEXTVAL
      FROM   DUAL;

    l_party_site_id  NUMBER(15);
    l_debug_prefix   VARCHAR2(30) := '';
  BEGIN
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'validate_party_site, x_validation_profile='|| x_validation_profile,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

    -- Check the profile option name.
    -- Raise an error if it is not an "allowed" profile option.
    IF x_validation_profile <> 'HZ_BANK_BRANCH_SITE_VALIDATION_PROCEDURE'
       AND x_validation_profile <> 'HZ_BANK_SITE_VALIDATION_PROCEDURE'
    THEN
      fnd_message.set_name('AR', 'HZ_DV_INVALID_PROFILE_OPTION');
      fnd_message.set_token('PROFILE', x_validation_profile);
      fnd_msg_pub.add;
      RAISE hz_dyn_validation.invalid_profile_option;
    END IF;

    -- Get the party_site ID.
    IF x_temp_id IS NOT NULL THEN
      l_party_site_id := x_temp_id;
    ELSE
      OPEN psidcur;
      FETCH psidcur INTO l_party_site_id;

      IF psidcur%NOTFOUND THEN
        -- Close the cursor and raise an error if the party_site ID could not
        -- be selected from the sequence.
        CLOSE psidcur;

        fnd_message.set_name('AR', 'HZ_DV_ID_NOT_FOUND');
        fnd_message.set_token('SEQUENCE', 'hz_party_site_val_gt_s');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE psidcur;
    END IF;

    -- Bug 3814832
    DELETE FROM hz_party_site_val_gt;
    -- Create the party_site record.
    INSERT INTO hz_party_site_val_gt(temp_id,
                                     party_id,
                                     location_id,
                                     party_site_number,
                                     orig_system_reference,
                                     mailstop,
                                     identifying_address_flag,
                                     status,
                                     party_site_name,
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
                                     language,
                                     addressee,
                                     created_by_module,
                                     application_id)
    VALUES (l_party_site_id,
            x_party_site.party_id,
            x_party_site.location_id,
            x_party_site.party_site_number,
            x_party_site.orig_system_reference,
            x_party_site.mailstop,
            x_party_site.identifying_address_flag,
            x_party_site.status,
            x_party_site.party_site_name,
            x_party_site.attribute_category,
            x_party_site.attribute1,
            x_party_site.attribute2,
            x_party_site.attribute3,
            x_party_site.attribute4,
            x_party_site.attribute5,
            x_party_site.attribute6,
            x_party_site.attribute7,
            x_party_site.attribute8,
            x_party_site.attribute9,
            x_party_site.attribute10,
            x_party_site.attribute11,
            x_party_site.attribute12,
            x_party_site.attribute13,
            x_party_site.attribute14,
            x_party_site.attribute15,
            x_party_site.attribute16,
            x_party_site.attribute17,
            x_party_site.attribute18,
            x_party_site.attribute19,
            x_party_site.attribute20,
            x_party_site.language,
            x_party_site.addressee,
            x_party_site.created_by_module,
            x_party_site.application_id);

    -- Execute dynamic call.
    exec_procedure(x_validation_profile, l_party_site_id);

  END validate_party_site;


  /*=======================================================================+
   | PUBLIC PROCEDURE validate_location                                    |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate a party site given the name of the validation procedure    |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_location_v2pub.location_rec_type                                 |
   | MODIFICATION HISTORY                                                  |
   |   11-13-2001    J. del Callar      Created.                           |
   +=======================================================================*/

  PROCEDURE validate_location (
    x_location           IN hz_location_v2pub.location_rec_type,
    x_validation_profile IN VARCHAR2,
    x_temp_id            IN NUMBER DEFAULT NULL
  ) IS
    CURSOR locidcur IS
      SELECT hz_location_val_gt_s.NEXTVAL
      FROM   DUAL;

    l_location_id  NUMBER(15);
    l_debug_prefix VARCHAR2(30) := '';
  BEGIN
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'validate_location, x_validation_profile='|| x_validation_profile,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

    -- Check the profile option name.
    -- Raise an error if it is not an "allowed" profile option.
    IF x_validation_profile <> 'HZ_BANK_BRANCH_LOCATION_VALIDATION_PROCEDURE'
       AND x_validation_profile <> 'HZ_BANK_LOCATION_VALIDATION_PROCEDURE'
    THEN
      fnd_message.set_name('AR', 'HZ_DV_INVALID_PROFILE_OPTION');
      fnd_message.set_token('PROFILE', x_validation_profile);
      fnd_msg_pub.add;
      RAISE hz_dyn_validation.invalid_profile_option;
    END IF;

    -- Get the location ID.
    IF x_temp_id IS NOT NULL THEN
      l_location_id := x_temp_id;
    ELSE
      OPEN locidcur;
      FETCH locidcur INTO l_location_id;

      IF locidcur%NOTFOUND THEN
        -- Close the cursor and raise an error if the location ID could not be
        -- selected from the sequence.
        CLOSE locidcur;

        fnd_message.set_name('AR', 'HZ_DV_ID_NOT_FOUND');
        fnd_message.set_token('SEQUENCE', 'hz_location_val_gt_s');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE locidcur;
    END IF;

    -- Bug 3814832
    DELETE FROM hz_location_val_gt;
    -- Create the location record.
    INSERT INTO hz_location_val_gt(temp_id,
				   orig_system_reference,
				   country,
				   address1,
				   address2,
				   address3,
				   address4,
				   city,
				   postal_code,
				   state,
				   province,
				   county,
				   address_key,
				   address_style,
				   validated_flag,
				   address_lines_phonetic,
				   po_box_number,
				   house_number,
				   street_suffix,
				   street,
				   street_number,
				   floor,
				   suite,
				   postal_plus4_code,
				   position,
				   location_directions,
				   address_effective_date,
				   address_expiration_date,
				   clli_code,
				   language,
				   short_description,
				   description,
				   loc_hierarchy_id,
				   sales_tax_geocode,
				   sales_tax_inside_city_limits,
				   fa_location_id,
				   content_source_type,
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
				   timezone_id,
				   created_by_module,
				   application_id)
    VALUES (l_location_id,
            x_location.orig_system_reference,
            x_location.country,
            x_location.address1,
            x_location.address2,
            x_location.address3,
            x_location.address4,
            x_location.city,
            x_location.postal_code,
            x_location.state,
            x_location.province,
            x_location.county,
            x_location.address_key,
            x_location.address_style,
            x_location.validated_flag,
            x_location.address_lines_phonetic,
            x_location.po_box_number,
            x_location.house_number,
            x_location.street_suffix,
            x_location.street,
            x_location.street_number,
            x_location.floor,
            x_location.suite,
            x_location.postal_plus4_code,
            x_location.position,
            x_location.location_directions,
            x_location.address_effective_date,
            x_location.address_expiration_date,
            x_location.clli_code,
            x_location.language,
            x_location.short_description,
            x_location.description,
            x_location.loc_hierarchy_id,
            x_location.sales_tax_geocode,
            x_location.sales_tax_inside_city_limits,
            x_location.fa_location_id,
            x_location.content_source_type,
            x_location.attribute_category,
            x_location.attribute1,
            x_location.attribute2,
            x_location.attribute3,
            x_location.attribute4,
            x_location.attribute5,
            x_location.attribute6,
            x_location.attribute7,
            x_location.attribute8,
            x_location.attribute9,
            x_location.attribute10,
            x_location.attribute11,
            x_location.attribute12,
            x_location.attribute13,
            x_location.attribute14,
            x_location.attribute15,
            x_location.attribute16,
            x_location.attribute17,
            x_location.attribute18,
            x_location.attribute19,
            x_location.attribute20,
            x_location.timezone_id,
            x_location.created_by_module,
            x_location.application_id);

    -- Execute dynamic call.
    exec_procedure(x_validation_profile, l_location_id);

  END validate_location;


  /*=======================================================================+
   | PUBLIC PROCEDURE validate_contact_point                               |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate a party site given the name of the validation procedure    |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_contact_point_v2pub.contact_point_rec_type                       |
   | MODIFICATION HISTORY                                                  |
   |   11-13-2001    J. del Callar      Created.                           |
   +=======================================================================*/

  PROCEDURE validate_contact_point (
    x_contact_point      IN hz_contact_point_v2pub.contact_point_rec_type,
    x_edi_contact        IN hz_contact_point_v2pub.edi_rec_type,
    x_eft_contact        IN hz_contact_point_v2pub.eft_rec_type,
    x_email_contact      IN hz_contact_point_v2pub.email_rec_type,
    x_phone_contact      IN hz_contact_point_v2pub.phone_rec_type,
    x_telex_contact      IN hz_contact_point_v2pub.telex_rec_type,
    x_web_contact        IN hz_contact_point_v2pub.web_rec_type,
    x_validation_profile IN VARCHAR2,
    x_temp_id            IN NUMBER DEFAULT NULL
  ) IS
    CURSOR psidcur IS
      SELECT hz_contact_point_val_gt_s.NEXTVAL
      FROM   DUAL;

    l_contact_point_id  NUMBER(15);
    l_debug_prefix      VARCHAR2(30) := '';
  BEGIN
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'validate_contact_point, x_validation_profile='|| x_validation_profile,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

    -- Check the profile option name.
    -- Raise an error if it is not an "allowed" profile option.
    IF x_validation_profile <> 'HZ_BANK_BRANCH_CONTACT_POINT_VALIDATION_PROCEDURE'
       AND x_validation_profile <> 'HZ_BANK_CONTACT_POINT_VALIDATION_PROCEDURE'
    THEN
      fnd_message.set_name('AR', 'HZ_DV_INVALID_PROFILE_OPTION');
      fnd_message.set_token('PROFILE', x_validation_profile);
      fnd_msg_pub.add;
      RAISE hz_dyn_validation.invalid_profile_option;
    END IF;

    -- Get the contact_point ID.
    IF x_temp_id IS NOT NULL THEN
      l_contact_point_id := x_temp_id;
    ELSE
      OPEN psidcur;
      FETCH psidcur INTO l_contact_point_id;

      IF psidcur%NOTFOUND THEN
        -- Close the cursor and raise an error if the contact point ID could
        -- not be selected from the sequence.
        CLOSE psidcur;

        fnd_message.set_name('AR', 'HZ_DV_ID_NOT_FOUND');
        fnd_message.set_token('SEQUENCE', 'hz_contact_point_val_gt_s');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE psidcur;
    END IF;

    -- Bug 3814832
    DELETE FROM hz_contact_point_val_gt;
    -- Create the contact_point record.
    INSERT INTO hz_contact_point_val_gt(temp_id,
                                        contact_point_type,
                                        status,
                                        owner_table_name,
                                        owner_table_id,
                                        primary_flag,
                                        orig_system_reference,
                                        content_source_type,
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
                                        contact_point_purpose,
                                        primary_by_purpose,
                                        created_by_module,
                                        application_id,
                                        edi_transaction_handling,
                                        edi_id_number,
                                        edi_payment_method,
                                        edi_payment_format,
                                        edi_remittance_method,
                                        edi_remittance_instruction,
                                        edi_tp_header_id,
                                        edi_ece_tp_location_code,
                                        eft_transmission_program_id,
                                        eft_printing_program_id,
                                        eft_user_number,
                                        eft_swift_code,
                                        email_format,
                                        email_address,
                                        phone_calling_calendar,
                                        last_contact_dt_time,
                                        timezone_id,
                                        phone_area_code,
                                        phone_country_code,
                                        phone_number,
                                        phone_extension,
                                        phone_line_type,
                                        raw_phone_number,
                                        telex_number,
                                        web_type,
                                        url)
    VALUES (l_contact_point_id,
            x_contact_point.contact_point_type,
            x_contact_point.status,
            x_contact_point.owner_table_name,
            x_contact_point.owner_table_id,
            x_contact_point.primary_flag,
            x_contact_point.orig_system_reference,
            x_contact_point.content_source_type,
            x_contact_point.attribute_category,
            x_contact_point.attribute1,
            x_contact_point.attribute2,
            x_contact_point.attribute3,
            x_contact_point.attribute4,
            x_contact_point.attribute5,
            x_contact_point.attribute6,
            x_contact_point.attribute7,
            x_contact_point.attribute8,
            x_contact_point.attribute9,
            x_contact_point.attribute10,
            x_contact_point.attribute11,
            x_contact_point.attribute12,
            x_contact_point.attribute13,
            x_contact_point.attribute14,
            x_contact_point.attribute15,
            x_contact_point.attribute16,
            x_contact_point.attribute17,
            x_contact_point.attribute18,
            x_contact_point.attribute19,
            x_contact_point.attribute20,
            x_contact_point.contact_point_purpose,
            x_contact_point.primary_by_purpose,
            x_contact_point.created_by_module,
            x_contact_point.application_id,
            x_edi_contact.edi_transaction_handling,
            x_edi_contact.edi_id_number,
            x_edi_contact.edi_payment_method,
            x_edi_contact.edi_payment_format,
            x_edi_contact.edi_remittance_method,
            x_edi_contact.edi_remittance_instruction,
            x_edi_contact.edi_tp_header_id,
            x_edi_contact.edi_ece_tp_location_code,
            x_eft_contact.eft_transmission_program_id,
            x_eft_contact.eft_printing_program_id,
            x_eft_contact.eft_user_number,
            x_eft_contact.eft_swift_code,
            x_email_contact.email_format,
            x_email_contact.email_address,
            x_phone_contact.phone_calling_calendar,
            x_phone_contact.last_contact_dt_time,
            x_phone_contact.timezone_id,
            x_phone_contact.phone_area_code,
            x_phone_contact.phone_country_code,
            x_phone_contact.phone_number,
            x_phone_contact.phone_extension,
            x_phone_contact.phone_line_type,
            x_phone_contact.raw_phone_number,
            x_telex_contact.telex_number,
            x_web_contact.web_type,
            x_web_contact.url);

    -- Execute dynamic call.
    exec_procedure(x_validation_profile, l_contact_point_id);

  END validate_contact_point;

END hz_dyn_validation;

/
