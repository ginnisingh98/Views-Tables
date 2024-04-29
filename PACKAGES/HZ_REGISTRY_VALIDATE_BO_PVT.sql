--------------------------------------------------------
--  DDL for Package HZ_REGISTRY_VALIDATE_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_REGISTRY_VALIDATE_BO_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHBRGVS.pls 120.6.12010000.2 2009/06/25 22:10:55 awu ship $ */

TYPE boc_tbl IS TABLE OF HZ_BUS_OBJ_DEFINITIONS.BUSINESS_OBJECT_CODE%TYPE;
TYPE cbc_tbl IS TABLE OF HZ_BUS_OBJ_DEFINITIONS.CHILD_BO_CODE%TYPE;
TYPE tmf_tbl IS TABLE OF HZ_BUS_OBJ_DEFINITIONS.TCA_MANDATED_FLAG%TYPE;
TYPE umf_tbl IS TABLE OF HZ_BUS_OBJ_DEFINITIONS.USER_MANDATED_FLAG%TYPE;
TYPE rnf_tbl IS TABLE OF HZ_BUS_OBJ_DEFINITIONS.ROOT_NODE_FLAG%TYPE;
TYPE ent_tbl IS TABLE OF HZ_BUS_OBJ_DEFINITIONS.ENTITY_NAME%TYPE;

TYPE completeness_rec_type IS RECORD(
  business_object_code                       boc_tbl,
  child_bo_code                              cbc_tbl,
  tca_mandated_flag                          tmf_tbl,
  user_mandated_flag                         umf_tbl,
  root_node_flag                             rnf_tbl,
  entity_name                                ent_tbl
);

-- PROCEDURE validate_parent_id
--
-- DESCRIPTION
--     Validates parent id of business object.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     px_parent_id             Parent Id.
--     px_parent_os             Parent original system.
--     px_parent_osr            Parent original system reference.
--     p_person_obj_type        Parent object type.
--   OUT:
--     x_return_status          Return status after the call. The status can
--                              be FND_API.G_RET_STS_SUCCESS (success),
--                              FND_API.G_RET_STS_ERROR (error),
--                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
--     x_msg_count              Return total number of message.
--     x_msg_data               Return message content.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE validate_parent_id(
  px_parent_id                 IN OUT NOCOPY NUMBER,
  px_parent_os                 IN OUT NOCOPY VARCHAR2,
  px_parent_osr                IN OUT NOCOPY VARCHAR2,
  p_parent_obj_type            IN            VARCHAR2,
  x_return_status              OUT NOCOPY    VARCHAR2,
  x_msg_count                  OUT NOCOPY    NUMBER,
  x_msg_data                   OUT NOCOPY    VARCHAR2
);

-- PROCEDURE validate_ssm_id
--
-- DESCRIPTION
--     Validates Id, original system and original system reference of business object.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     px_id                    Id.
--     px_os                    Original system.
--     px_osr                   Original system reference.
--     p_org_id                 Org_Id for customer account site, customer account
--                              site use and customer account relationship.
--     p_obj_type               Business object type.
--     p_create_or_update       Flag to indicate create or update.
--   OUT:
--     x_return_status          Return status after the call. The status can
--                              be FND_API.G_RET_STS_SUCCESS (success),
--                              FND_API.G_RET_STS_ERROR (error),
--                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
--     x_msg_count              Return total number of message.
--     x_msg_data               Return message content.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE validate_ssm_id(
  px_id                        IN OUT NOCOPY NUMBER,
  px_os                        IN OUT NOCOPY VARCHAR2,
  px_osr                       IN OUT NOCOPY VARCHAR2,
  p_org_id                     IN            NUMBER := NULL,
  p_obj_type                   IN            VARCHAR2,
  p_create_or_update           IN            VARCHAR2,
  x_return_status              OUT NOCOPY    VARCHAR2,
  x_msg_count                  OUT NOCOPY    NUMBER,
  x_msg_data                   OUT NOCOPY    VARCHAR2
);

-- PROCEDURE check_contact_pref_op
--
-- DESCRIPTION
--     Check the operation of contact preference based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_contact_level_table_id Contact level table Id.
--     p_contact_level_table    Contact level table.
--     p_contact_type           Contact preference type.
--     p_preference_code        Contact preference code.
--     p_preference_start_date  Contact preference start date.
--     p_preference_end_date    Contact preference end date.
--   IN/OUT:
--     px_contact_pref_id       Contact preference Id.
--   OUT:
--     x_object_version_number  Object version number of contact preference.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE check_contact_pref_op(
  p_contact_level_table_id     IN     NUMBER,
  p_contact_level_table        IN     VARCHAR2,
  px_contact_pref_id           IN OUT NOCOPY NUMBER,
  p_contact_type               IN     VARCHAR2,
  p_preference_code            IN     VARCHAR2,
  p_preference_start_date      IN     DATE,
  p_preference_end_date        IN     DATE,
  x_object_version_number      OUT NOCOPY NUMBER
);

-- PROCEDURE check_language_op
--
-- DESCRIPTION
--     Check the operation of person language based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_party_id               Party Id.
--     p_language_name          Language name.
--   IN/OUT:
--     px_language_use_ref_id   Language use reference Id.
--   OUT:
--     x_object_version_number  Object version number of person language.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE check_language_op(
  p_party_id                   IN     NUMBER,
  px_language_use_ref_id       IN OUT NOCOPY NUMBER,
  p_language_name              IN     VARCHAR2,
  x_object_version_number      OUT NOCOPY NUMBER
);

-- PROCEDURE check_education_op
--
-- DESCRIPTION
--     Check the operation of education based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_party_id               Party Id.
--     p_course_major           Course major.
--     p_school_attended_name   Name of attended school.
--     p_degree_received        Received degree.
--   IN/OUT:
--     px_education_id          Education Id.
--   OUT:
--     x_object_version_number  Object version number of education.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE check_education_op(
  p_party_id                   IN     NUMBER,
  px_education_id              IN OUT NOCOPY NUMBER,
  p_course_major               IN     VARCHAR2,
  p_school_attended_name       IN     VARCHAR2,
  p_degree_received            IN     VARCHAR2,
  x_object_version_number      OUT NOCOPY NUMBER
);

-- PROCEDURE check_citizenship_op
--
-- DESCRIPTION
--     Check the operation of citizenship based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_party_id               Party Id.
--     p_country_code           Country code.
--   IN/OUT:
--     px_citizenship_id        Citizenship Id.
--   OUT:
--     x_object_version_number  Object version number of citizenship.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE check_citizenship_op(
  p_party_id                   IN     NUMBER,
  px_citizenship_id            IN OUT NOCOPY NUMBER,
  p_country_code               IN     VARCHAR2,
  x_object_version_number      OUT NOCOPY NUMBER
);

-- PROCEDURE check_employ_hist_op
--
-- DESCRIPTION
--     Check the operation of employment history based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_party_id               Party Id.
--     p_employed_by_name_company   Name of company.
--     p_employed_as_title      Job title.
--     p_begin_date             Begin date.
--   IN/OUT:
--     px_emp_hist_id           Employment history Id.
--   OUT:
--     x_object_version_number  Object version number of employment history.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE check_employ_hist_op(
  p_party_id                   IN     NUMBER,
  px_emp_hist_id               IN OUT NOCOPY NUMBER,
  p_employed_by_name_company   IN     VARCHAR2,
  p_employed_as_title          IN     VARCHAR2,
  p_begin_date                 IN     DATE,
  x_object_version_number      OUT NOCOPY NUMBER
);

-- PROCEDURE check_work_class_op
--
-- DESCRIPTION
--     Check the operation of work class based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_party_id               Party Id.
--     p_work_class_name        Name of work class.
--   IN/OUT:
--     px_work_class_id         Work class Id.
--   OUT:
--     x_object_version_number  Object version number of work class.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE check_work_class_op(
  p_employ_hist_id             IN     NUMBER,
  px_work_class_id             IN OUT NOCOPY NUMBER,
  p_work_class_name            IN     VARCHAR2,
  x_object_version_number      OUT NOCOPY NUMBER
);

-- PROCEDURE check_interest_op
--
-- DESCRIPTION
--     Check the operation of person interest based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_party_id               Party Id.
--     p_interest_type_code     Interest type code.
--     p_sub_interest_type_code Sub-interest type code.
--     p_interest_name          Name of interest.
--   IN/OUT:
--     px_interest_id           Person interest Id.
--   OUT:
--     x_object_version_number  Object version number of person interest.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE check_interest_op(
  p_party_id                   IN     NUMBER,
  px_interest_id               IN OUT NOCOPY NUMBER,
  p_interest_type_code         IN     VARCHAR2,
  p_sub_interest_type_code     IN     VARCHAR2,
  p_interest_name              IN     VARCHAR2,
  x_object_version_number      OUT NOCOPY NUMBER
);

-- PROCEDURE check_party_site_use_op
--
-- DESCRIPTION
--     Check the operation of party site use based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_party_site_id          Party site Id.
--     p_site_use_type          Site use type.
--   IN/OUT:
--     px_party_site_use_id     Party site use Id.
--   OUT:
--     x_object_version_number  Object version number of party site use.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE check_party_site_use_op(
  p_party_site_id              IN     NUMBER,
  px_party_site_use_id         IN OUT NOCOPY NUMBER,
  p_site_use_type              IN     VARCHAR2,
  x_object_version_number      OUT NOCOPY NUMBER
);

-- PROCEDURE check_relationship_op
--
-- DESCRIPTION
--     Check the operation of relationship based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_subject_id             Subject Id.
--     p_object_id              Object Id.
--     p_relationship_type      Relationship type.
--     p_relationship_code      Relationship code.
--   IN/OUT:
--     px_relationship_id       Relationship Id.
--   OUT:
--     x_object_version_number  Object version number of relationship.
--     x_party_object_version_number  Object version number of relationship party.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE check_relationship_op(
  p_subject_id                 IN     NUMBER,
  p_object_id                  IN     NUMBER,
  px_relationship_id           IN OUT NOCOPY NUMBER,
  p_relationship_type          IN     VARCHAR2,
  p_relationship_code          IN     VARCHAR2,
  x_object_version_number      OUT NOCOPY NUMBER,
  x_party_obj_version_number   OUT NOCOPY NUMBER
);

-- PROCEDURE check_org_contact_role_op
--
-- DESCRIPTION
--     Check the operation of org contact role based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_org_contact_id         Org contact Id.
--     p_role_type              Role type.
--   IN/OUT:
--     px_org_contact_role_id   Org contact role Id.
--   OUT:
--     x_object_version_number  Object version number of org contact role.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE check_org_contact_role_op(
  p_org_contact_id             IN     NUMBER,
  px_org_contact_role_id       IN OUT NOCOPY NUMBER,
  p_role_type                  IN     VARCHAR2,
  x_object_version_number      OUT NOCOPY NUMBER
);

-- PROCEDURE check_certification_op
--
-- DESCRIPTION
--     Check the operation of certification based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_party_id               Party Id.
--     p_certification_name     Name of certification.
--   IN/OUT:
--     px_certification_id      Certification Id.
--   OUT:
--     x_last_update_date       Last update date of certification.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE check_certification_op(
  p_party_id                   IN     NUMBER,
  px_certification_id          IN OUT NOCOPY NUMBER,
  p_certification_name         IN     VARCHAR2,
  x_last_update_date           OUT NOCOPY DATE,
  x_return_status              OUT NOCOPY VARCHAR2
);

-- PROCEDURE check_financial_prof_op
--
-- DESCRIPTION
--     Check the operation of financial profile based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_party_id               Party Id.
--     p_financial_profile_id   Financial profile Id.
--   OUT:
--     x_last_update_date       Last update date of financial profile.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE check_financial_prof_op(
  p_party_id                   IN     NUMBER,
  p_financial_profile_id       IN     NUMBER,
  x_last_update_date           OUT NOCOPY DATE,
  x_return_status              OUT NOCOPY VARCHAR2
);

-- PROCEDURE check_code_assign_op
--
-- DESCRIPTION
--     Check the operation of classification based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_owner_table_name       Owner table name.
--     p_owner_table_id         Owner table Id.
--     p_class_category         Class category.
--     p_class_code             Class code.
--   IN/OUT:
--     px_code_assignment_id    Code assignment Id.
--   OUT:
--     x_object_version_number  Object version number of classification.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE check_code_assign_op(
  p_owner_table_name           IN     VARCHAR2,
  p_owner_table_id             IN     NUMBER,
  px_code_assignment_id        IN OUT NOCOPY NUMBER,
  p_class_category             IN     VARCHAR2,
  p_class_code                 IN     VARCHAR2,
  x_object_version_number      OUT NOCOPY NUMBER
);

-- PROCEDURE check_party_pref_op
--
-- DESCRIPTION
--     Check the operation of party preference based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_party_id               Party Id.
--     p_module                 Module.
--     p_category               Category.
--     p_preference_code        Preference code.
--   OUT:
--     x_object_version_number  Object version number of party preference.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE check_party_pref_op(
  p_party_id                   IN     NUMBER,
  p_module                     IN     VARCHAR2,
  p_category                   IN     VARCHAR2,
  p_preference_code            IN     VARCHAR2,
  x_object_version_number      OUT NOCOPY NUMBER
);

-- PROCEDURE check_credit_rating_op
--
-- DESCRIPTION
--     Check the operation of credit rating based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_party_id               Party Id.
--     p_rating_organization    Rating organization.
--     p_rated_as_of_date       Rated date.
--   IN/OUT:
--     px_credit_rating_id      Credit rating Id.
--   OUT:
--     x_object_version_number  Object version number of credit rating.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE check_credit_rating_op(
  p_party_id                   IN     NUMBER,
  px_credit_rating_id          IN OUT NOCOPY NUMBER,
  p_rating_organization        IN     VARCHAR2,
  p_rated_as_of_date           IN     DATE,
  x_object_version_number      OUT NOCOPY NUMBER
);

-- PROCEDURE check_fin_report_op
--
-- DESCRIPTION
--     Check the operation of financial report based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_party_id               Party Id.
--     p_type_of_financial_report  Type of financial report.
--     p_document_reference     Document reference.
--     p_date_report_issued     Report issued date.
--     p_issued_period          Issued period.
--   IN/OUT:
--     px_fin_report_id         Financial report Id.
--   OUT:
--     x_object_version_number  Object version number of financial report.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE check_fin_report_op(
  p_party_id                   IN     NUMBER,
  px_fin_report_id             IN OUT NOCOPY NUMBER,
  p_type_of_financial_report   IN     VARCHAR2,
  p_document_reference         IN     VARCHAR2,
  p_date_report_issued         IN     DATE,
  p_issued_period              IN     VARCHAR2,
  x_object_version_number      OUT NOCOPY NUMBER
);

-- PROCEDURE check_fin_number_op
--
-- DESCRIPTION
--     Check the operation of financial number based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_fin_report_id          Financial report Id.
--     p_financial_number_name  Name of financial number.
--   IN/OUT:
--     px_fin_number_id         Financial number Id.
--   OUT:
--     x_object_version_number  Object version number of financial number.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE check_fin_number_op(
  p_fin_report_id              IN     NUMBER,
  px_fin_number_id             IN OUT NOCOPY NUMBER,
  p_financial_number_name      IN     VARCHAR2,
  x_object_version_number      OUT NOCOPY NUMBER
);

-- PROCEDURE check_role_resp_op
--
-- DESCRIPTION
--     Check the operation of role responsibility based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_cust_acct_contact_id   Customer account contact Id.
--     p_responsibility_type    Role responsibility type.
--   IN/OUT:
--     px_responsibility_id     Role responsibility Id.
--   OUT:
--     x_object_version_number  Object version number of role responsibility.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE check_role_resp_op(
  p_cust_acct_contact_id       IN     NUMBER,
  px_responsibility_id         IN OUT NOCOPY NUMBER,
  p_responsibility_type        IN     VARCHAR2,
  x_object_version_number      OUT NOCOPY NUMBER
);

-- PROCEDURE check_cust_profile_op
--
-- DESCRIPTION
--     Check the operation of customer profile based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_cust_acct_id           Customer account Id.
--     p_site_use_id            Customer site use Id.
--     p_profile_class_id       Profile class Id.
--   IN/OUT:
--     px_cust_acct_profile_id  Customer profile Id.
--   OUT:
--     x_object_version_number  Object version number of customer profile.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE check_cust_profile_op(
  p_cust_acct_id               IN     NUMBER,
  px_cust_acct_profile_id      IN OUT NOCOPY NUMBER,
  p_site_use_id                IN     NUMBER,
  p_profile_class_id           IN     NUMBER,
  x_object_version_number      OUT NOCOPY NUMBER
);

-- PROCEDURE check_cust_profile_amt_op
--
-- DESCRIPTION
--     Check the operation of customer profile amount based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_cust_profile_id        Customer profile Id.
--     p_currency_code          Currency code.
--   IN/OUT:
--     px_cust_acct_prof_amt_id Customer profile amount Id.
--   OUT:
--     x_object_version_number  Object version number of customer profile amount.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE check_cust_profile_amt_op(
  p_cust_profile_id            IN     NUMBER,
  px_cust_acct_prof_amt_id     IN OUT NOCOPY NUMBER,
  p_currency_code              IN     VARCHAR2,
  x_object_version_number      OUT NOCOPY NUMBER
);

-- PROCEDURE check_cust_acct_relate_op
--
-- DESCRIPTION
--     Check the operation of customer account relationship based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_cust_acct_id           Customer account Id.
--     p_related_cust_acct_id   Related customer account Id.
--   OUT:
--     x_object_version_number  Object version number of customer account relationship.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE check_cust_acct_relate_op(
  p_cust_acct_id               IN     NUMBER,
  p_related_cust_acct_id       IN     NUMBER,
  p_org_id                     IN     NUMBER,
  x_object_version_number      OUT NOCOPY NUMBER
);

-- PROCEDURE check_payment_method_op
--
-- DESCRIPTION
--     Check the operation of payment method based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_cust_receipt_method_id Payment method Id.
--   OUT:
--     x_last_update_date       Last update date of payment method.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE check_payment_method_op(
  p_cust_receipt_method_id     IN     NUMBER,
  x_last_update_date           OUT NOCOPY DATE
);

-- FUNCTION check_bo_op
--
-- DESCRIPTION
--     Return the operation of business object based on pass in parameter.
--     Return value can be 'C' (create) or 'U' (update)
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_entity_id              Business object Id.
--     p_entity_os              Business object original system.
--     p_entity_osr             Business object original system reference.
--     p_entity_type            Business object type.
--     p_cp_type                Contact point type.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

FUNCTION check_bo_op(
  p_entity_id                  IN     NUMBER,
  p_entity_os                  IN     VARCHAR2,
  p_entity_osr                 IN     VARCHAR2,
  p_entity_type                IN     VARCHAR2,
  p_cp_type                    IN     VARCHAR2 := NULL,
  p_parent_id                  IN     NUMBER,
  p_parent_obj_type            IN     VARCHAR2
) RETURN VARCHAR2;


-- PROCEDURE check_party_usage_op
--
-- DESCRIPTION
--     Checks if a row exists in  party_usg_assigments table for agiven
--      party_id and party_usages_code.
--     If exists Return last_update_date value. otherwise null.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--    p_party_id              id of a party for whicch party_usage was created.
--    p_party_usage_code         seeded usage code.
-- OUT:
--    x_last_update_date       last_update_date column.
--    x_return_status              status of the call
-- NOTES
--
-- MODIFICATION HISTORY
--
--   01-Mar-2006    Hadi Alatasi   o Created.

PROCEDURE check_party_usage_op(
    p_party_id                   IN     NUMBER,
    p_party_usage_code          IN     VARCHAR2,
    x_last_update_date           OUT NOCOPY DATE,
    x_return_status              OUT NOCOPY VARCHAR2
  );

-- FUNCTION get_owner_table_name
--
-- DESCRIPTION
--     Return the owner table name based on object type.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_obj_type               Object type.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

FUNCTION get_owner_table_name(
  p_obj_type                   IN     VARCHAR2
) RETURN VARCHAR2;

-- FUNCTION get_parent_object_type
--
-- DESCRIPTION
--     Return the object type based on parent table and Id.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_parent_table_name      Parent table name.
--     p_parent_id              Parent Id.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

FUNCTION get_parent_object_type(
  p_parent_table_name         IN     VARCHAR2,
  p_parent_id                 IN     NUMBER
) RETURN VARCHAR2;

-- FUNCTION is_cp_bo_comp
--
-- DESCRIPTION
--     Return true if contact point object is complete.  Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_phone_objs             List of phone business objects.
--     p_email_objs             List of email business objects.
--     p_telex_objs             List of telex business objects.
--     p_web_objs               List of web business objects.
--     p_edi_objs               List of edi business objects.
--     p_eft_objs               List of eft business objects.
--     p_sms_objs               List of sms business objects.
--     p_bus_object             Business object structure for contact point.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

FUNCTION is_cp_bo_comp(
    p_phone_objs              IN     HZ_PHONE_CP_BO_TBL,
    p_email_objs              IN     HZ_EMAIL_CP_BO_TBL,
    p_telex_objs              IN     HZ_TELEX_CP_BO_TBL,
    p_web_objs                IN     HZ_WEB_CP_BO_TBL,
    p_edi_objs                IN     HZ_EDI_CP_BO_TBL,
    p_eft_objs                IN     HZ_EFT_CP_BO_TBL,
    p_sms_objs                IN     HZ_SMS_CP_BO_TBL,
    p_bus_object              IN     COMPLETENESS_REC_TYPE
) RETURN BOOLEAN;

-- FUNCTION is_ps_bo_comp
--
-- DESCRIPTION
--     Return true if party site object is complete.  Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_ps_objs                List of party site business objects.
--     p_bus_object             Business object structure for party site.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

FUNCTION is_ps_bo_comp(
    p_ps_objs                 IN     HZ_PARTY_SITE_BO_TBL,
    p_bus_object              IN     COMPLETENESS_REC_TYPE
) RETURN BOOLEAN;

-- FUNCTION is_person_bo_comp
--
-- DESCRIPTION
--     Return true if person object is complete.  Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_person_obj             Person business objects.
--     p_bus_object             Business object structure for person.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

FUNCTION is_person_bo_comp(
    p_person_obj              IN     HZ_PERSON_BO,
    p_bus_object              IN     COMPLETENESS_REC_TYPE
) RETURN BOOLEAN;

-- FUNCTION is_org_bo_comp
--
-- DESCRIPTION
--     Return true if organization object is complete.  Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_organization_obj       Organization business objects.
--     p_bus_object             Business object structure for organization.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

FUNCTION is_org_bo_comp(
    p_organization_obj        IN     HZ_ORGANIZATION_BO,
    p_bus_object              IN     COMPLETENESS_REC_TYPE
) RETURN BOOLEAN;

-- FUNCTION is_oc_bo_comp
--
-- DESCRIPTION
--     Return true if org contact object is complete.  Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_oc_objs                List of organization contact business objects.
--     p_bus_object             Business object structure for organization contact.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

FUNCTION is_oc_bo_comp(
    p_oc_objs                 IN     HZ_ORG_CONTACT_BO_TBL,
    p_bus_object              IN     COMPLETENESS_REC_TYPE
) RETURN BOOLEAN;

-- FUNCTION is_cac_bo_comp
--
-- DESCRIPTION
--     Return true if customer account contact object is complete.
--     Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_cac_objs               List of customer account contact business objects.
--     p_bus_object             Business object structure for customer account contact.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

FUNCTION is_cac_bo_comp(
    p_cac_objs                IN     HZ_CUST_ACCT_CONTACT_BO_TBL,
    p_bus_object              IN     COMPLETENESS_REC_TYPE
) RETURN BOOLEAN;

-- FUNCTION is_cas_bo_comp
--
-- DESCRIPTION
--     Return true if customer account site object is complete.
--     Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_cas_objs               List of customer account site business objects.
--     p_bus_object             Business object structure for customer account site.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

FUNCTION is_cas_bo_comp(
    p_cas_objs                IN     HZ_CUST_ACCT_SITE_BO_TBL,
    p_bus_object              IN     COMPLETENESS_REC_TYPE
) RETURN BOOLEAN;

-- FUNCTION is_ca_bo_comp
--
-- DESCRIPTION
--     Return true if customer account object is complete.  Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_ca_objs                List of customer account business objects.
--     p_bus_object             Business object structure for customer account.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

FUNCTION is_ca_bo_comp(
    p_ca_objs                 IN     HZ_CUST_ACCT_BO_TBL,
    p_bus_object              IN     COMPLETENESS_REC_TYPE
) RETURN BOOLEAN;

-- FUNCTION is_pca_bo_comp
--
-- DESCRIPTION
--     Return true if person customer object is complete.  Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_person_obj             Person business object.
--     p_ca_objs                List of customer account objects.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

FUNCTION is_pca_bo_comp(
    p_person_obj              IN     HZ_PERSON_BO,
    p_ca_objs                 IN     HZ_CUST_ACCT_BO_TBL
) RETURN BOOLEAN;

-- FUNCTION is_oca_bo_comp
--
-- DESCRIPTION
--     Return true if organization customer object is complete.
--     Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_org_obj                Organization business object.
--     p_ca_objs                List of customer account objects.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

FUNCTION is_oca_bo_comp(
    p_org_obj                 IN     HZ_ORGANIZATION_BO,
    p_ca_objs                 IN     HZ_CUST_ACCT_BO_TBL
) RETURN BOOLEAN;

-- FUNCTION get_bus_object_struct
--
-- DESCRIPTION
--     Get contact point business object structure.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_bus_object_code        Business object code, such as 'PARTY_SITE',
--                              'ORG_CONTACT'
--   OUT:
--     x_bus_object             Business object structure.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE get_bus_obj_struct(
    p_bus_object_code         IN         VARCHAR2,
    x_bus_object              OUT NOCOPY COMPLETENESS_REC_TYPE
);

-- FUNCTION get_cp_bus_obj_struct
--
-- DESCRIPTION
--     Get contact point business object structure.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_phone_code             'PHONE'.
--     p_email_code             'EMAIL'.
--     p_telex_code             'TLX'.
--     p_web_code               'WEB'.
--     p_edi_code               'EDI'.
--     p_eft_code               'EFT'.
--     p_sms_code               'SMS'.
--   OUT:
--     x_bus_object             Contact point business object structure.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

PROCEDURE get_cp_bus_obj_struct(
    p_phone_code              IN         VARCHAR2,
    p_email_code              IN         VARCHAR2,
    p_telex_code              IN         VARCHAR2,
    p_web_code                IN         VARCHAR2,
    p_edi_code                IN         VARCHAR2,
    p_eft_code                IN         VARCHAR2,
    p_sms_code                IN         VARCHAR2,
    x_bus_object              OUT NOCOPY COMPLETENESS_REC_TYPE
);

-- FUNCTION get_id_from_ososr
--
-- DESCRIPTION
--     Get TCA Id based on original system and original system reference.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_os                     Original system
--     p_osr                    Original system reference
--     p_owner_table_name       Owner table name
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

FUNCTION get_id_from_ososr(
    p_os                      IN VARCHAR2,
    p_osr                     IN VARCHAR2,
    p_owner_table_name        IN VARCHAR2
) RETURN NUMBER;

-- FUNCTION is_cas_v2_bo_comp
--
-- DESCRIPTION
--     Return true if customer account site object is complete.
--     Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_cas_v2_objs               List of customer account site business objects.
--     p_bus_object             Business object structure for customer account site.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   1-FEB-2008    vsegu   o Created.

FUNCTION is_cas_v2_bo_comp(
    p_cas_v2_objs                IN     HZ_CUST_ACCT_SITE_V2_BO_TBL,
    p_bus_object              IN     COMPLETENESS_REC_TYPE
) RETURN BOOLEAN;

-- FUNCTION is_ca_v2_bo_comp
--
-- DESCRIPTION
--     Return true if customer account object is complete.  Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_ca_v2_objs                List of customer account business objects.
--     p_bus_object             Business object structure for customer account.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   1-FEB-2008    vsegu   o Created.

FUNCTION is_ca_v2_bo_comp(
    p_ca_v2_objs                 IN     HZ_CUST_ACCT_V2_BO_TBL,
    p_bus_object              IN     COMPLETENESS_REC_TYPE
) RETURN BOOLEAN;

-- FUNCTION is_pca_v2_bo_comp
--
-- DESCRIPTION
--     Return true if person customer object is complete.  Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_person_obj             Person business object.
--     p_ca_v2_objs                List of customer account objects.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   1-Feb-2008    vsegu     o Created.

FUNCTION is_pca_v2_bo_comp(
    p_person_obj              IN     HZ_PERSON_BO,
    p_ca_v2_objs              IN     HZ_CUST_ACCT_V2_BO_TBL
) RETURN BOOLEAN;

-- FUNCTION is_oca_v2_bo_comp
--
-- DESCRIPTION
--     Return true if organization customer object is complete.
--     Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_org_obj                Organization business object.
--     p_ca_v2_objs                List of customer account objects.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   1-Feb-2008    vsegu      o Created.

FUNCTION is_oca_v2_bo_comp(
    p_org_obj                 IN     HZ_ORGANIZATION_BO,
    p_ca_v2_objs              IN     HZ_CUST_ACCT_V2_BO_TBL
) RETURN BOOLEAN;

END HZ_REGISTRY_VALIDATE_BO_PVT;

/
