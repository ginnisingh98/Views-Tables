--------------------------------------------------------
--  DDL for Package HZ_BUSINESS_EVENT_V2PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_BUSINESS_EVENT_V2PVT" AUTHID CURRENT_USER AS
/*$Header: ARH2BESS.pls 120.9 2006/03/24 07:27:30 svemuri ship $ */


-- HZ_PARTY_V2PUB

  PROCEDURE create_person_event (
    p_person_rec           IN     hz_party_v2pub.person_rec_type
  );

  PROCEDURE update_person_event (
    p_person_rec           IN     hz_party_v2pub.person_rec_type,
    p_old_person_rec       IN     hz_party_v2pub.person_rec_type
  );

  PROCEDURE create_group_event (
    p_group_rec            IN     hz_party_v2pub.group_rec_type
  );

  PROCEDURE update_group_event (
    p_group_rec            IN     hz_party_v2pub.group_rec_type,
    p_old_group_rec        IN     hz_party_v2pub.group_rec_type
  );

  PROCEDURE create_organization_event (
    p_organization_rec     IN     hz_party_v2pub.organization_rec_type
  );

  PROCEDURE update_organization_event (
    p_organization_rec     IN     hz_party_v2pub.organization_rec_type,
    p_old_organization_rec IN     hz_party_v2pub.organization_rec_type
  );

  -- HZ_RELATIONSHIP_V2PUB

  PROCEDURE create_relationship_event (
    p_relationship_rec     IN     hz_relationship_v2pub.relationship_rec_type,
    p_party_created        IN     VARCHAR2
  );

  PROCEDURE update_relationship_event (
    p_relationship_rec     IN     hz_relationship_v2pub.relationship_rec_type,
    p_old_relationship_rec IN     hz_relationship_v2pub.relationship_rec_type
  );

  -- HZ_PARTY_SITE_V2PUB

  PROCEDURE create_party_site_event (
    p_party_site_rec       IN     hz_party_site_v2pub.party_site_rec_type
  );

  PROCEDURE update_party_site_event (
    p_party_site_rec       IN     hz_party_site_v2pub.party_site_rec_type,
    p_old_party_site_rec   IN     hz_party_site_v2pub.party_site_rec_type
  );

  PROCEDURE create_party_site_use_event (
    p_party_site_use_rec   IN     hz_party_site_v2pub.party_site_use_rec_type
  );

  PROCEDURE update_party_site_use_event (
    p_party_site_use_rec       IN     hz_party_site_v2pub.party_site_use_rec_type,
    p_old_party_site_use_rec   IN     hz_party_site_v2pub.party_site_use_rec_type
);

  -- HZ_PARTY_CONTACT_V2PUB

  PROCEDURE create_org_contact_event (
    p_org_contact_rec      IN     hz_party_contact_v2pub.org_contact_rec_type

  );

  PROCEDURE update_org_contact_event (
    p_org_contact_rec      IN     hz_party_contact_v2pub.org_contact_rec_type,
    p_old_org_contact_rec  IN     hz_party_contact_v2pub.org_contact_rec_type
  );

  PROCEDURE create_org_contact_role_event (
    p_org_contact_role_rec IN hz_party_contact_v2pub.org_contact_role_rec_type
  );

  PROCEDURE update_org_contact_role_event (
    p_org_contact_role_rec      IN hz_party_contact_v2pub.org_contact_role_rec_type,
    p_old_org_contact_role_rec  IN hz_party_contact_v2pub.org_contact_role_rec_type
  );

  --HZ_LOCATION_V2PUB

  PROCEDURE create_location_event (
    p_location_rec         IN     hz_location_v2pub.location_rec_type
  );

  PROCEDURE update_location_event (
    p_location_rec         IN     hz_location_v2pub.location_rec_type,
    p_old_location_rec     IN     hz_location_v2pub.location_rec_type
  );

  -- HZ_CONTACT_POINT_V2PUB

  -- Bug 2116225: Bank consolidation support.  The next two declarations are
  -- new for bank support.
  PROCEDURE create_contact_point_event (
    p_contact_point_rec     IN   hz_contact_point_v2pub.contact_point_rec_type,
    p_edi_rec               IN   hz_contact_point_v2pub.edi_rec_type,
    p_eft_rec               IN   hz_contact_point_v2pub.eft_rec_type,
    p_email_rec             IN   hz_contact_point_v2pub.email_rec_type,
    p_phone_rec             IN   hz_contact_point_v2pub.phone_rec_type,
    p_telex_rec             IN   hz_contact_point_v2pub.telex_rec_type,
    p_web_rec               IN   hz_contact_point_v2pub.web_rec_type
  );

  PROCEDURE update_contact_point_event (
    p_contact_point_rec     IN   hz_contact_point_v2pub.contact_point_rec_type,
    p_old_contact_point_rec IN   hz_contact_point_v2pub.contact_point_rec_type,
    p_edi_rec               IN   hz_contact_point_v2pub.edi_rec_type,
    p_old_edi_rec           IN   hz_contact_point_v2pub.edi_rec_type,
    p_eft_rec               IN   hz_contact_point_v2pub.eft_rec_type,
    p_old_eft_rec           IN   hz_contact_point_v2pub.eft_rec_type,
    p_email_rec             IN   hz_contact_point_v2pub.email_rec_type,
    p_old_email_rec         IN   hz_contact_point_v2pub.email_rec_type,
    p_phone_rec             IN   hz_contact_point_v2pub.phone_rec_type,
    p_old_phone_rec         IN   hz_contact_point_v2pub.phone_rec_type,
    p_telex_rec             IN   hz_contact_point_v2pub.telex_rec_type,
    p_old_telex_rec         IN   hz_contact_point_v2pub.telex_rec_type,
    p_web_rec               IN   hz_contact_point_v2pub.web_rec_type,
    p_old_web_rec           IN   hz_contact_point_v2pub.web_rec_type
  );


  -- HZ_CONTACT_PREFERENCE_V2PUB

  PROCEDURE create_contact_prefer_event (
    p_contact_preference_rec IN hz_contact_preference_v2pub.contact_preference_rec_type
  );

  PROCEDURE update_contact_prefer_event (
    p_contact_preference_rec     IN hz_contact_preference_v2pub.contact_preference_rec_type,
    p_old_contact_preference_rec IN hz_contact_preference_v2pub.contact_preference_rec_type
  );

  -- HZ_CUST_ACCOUNT_V2PUB

  PROCEDURE create_cust_account_event (
    p_cust_account_rec       IN  hz_cust_account_v2pub.cust_account_rec_type,
    p_person_rec             IN  hz_party_v2pub.person_rec_type,
    p_customer_profile_rec   IN  hz_customer_profile_v2pub.customer_profile_rec_type,
    p_create_profile_amt     IN  VARCHAR2
  );

  PROCEDURE create_cust_account_event (
    p_cust_account_rec       IN  hz_cust_account_v2pub.cust_account_rec_type,
    p_organization_rec       IN  hz_party_v2pub.organization_rec_type,
    p_customer_profile_rec   IN  hz_customer_profile_v2pub.customer_profile_rec_type,
    p_create_profile_amt     IN  VARCHAR2
  );

  PROCEDURE update_cust_account_event (
    p_cust_account_rec       IN  hz_cust_account_v2pub.cust_account_rec_type,
    p_old_cust_account_rec   IN  hz_cust_account_v2pub.cust_account_rec_type
  );

  PROCEDURE create_cust_acct_relate_event (
    p_cust_acct_relate_rec IN hz_cust_account_v2pub.cust_acct_relate_rec_type
  );

  PROCEDURE update_cust_acct_relate_event (
    p_cust_acct_relate_rec     IN hz_cust_account_v2pub.cust_acct_relate_rec_type,
    p_old_cust_acct_relate_rec IN hz_cust_account_v2pub.cust_acct_relate_rec_type
  );

  -- HZ_CUSTOMER_PROFILE_V2PUB

  PROCEDURE create_customer_profile_event (
    p_customer_profile_rec   IN  hz_customer_profile_v2pub.customer_profile_rec_type,
    p_create_profile_amt     IN  VARCHAR2
  );

  PROCEDURE update_customer_profile_event (
    p_customer_profile_rec       IN  hz_customer_profile_v2pub.customer_profile_rec_type,
    p_old_customer_profile_rec   IN  hz_customer_profile_v2pub.customer_profile_rec_type
  );

  PROCEDURE create_cust_profile_amt_event (
    p_cust_profile_amt_rec   IN  hz_customer_profile_v2pub.cust_profile_amt_rec_type
  );

  PROCEDURE update_cust_profile_amt_event (
    p_cust_profile_amt_rec       IN  hz_customer_profile_v2pub.cust_profile_amt_rec_type,
    p_old_cust_profile_amt_rec   IN  hz_customer_profile_v2pub.cust_profile_amt_rec_type
  );

  -- HZ_CUST_ACCOUNT_SITE_V2PUB

  PROCEDURE create_cust_acct_site_event (
    p_cust_acct_site_rec IN hz_cust_account_site_v2pub.cust_acct_site_rec_type
  );

  PROCEDURE update_cust_acct_site_event (
    p_cust_acct_site_rec     IN hz_cust_account_site_v2pub.cust_acct_site_rec_type,
    p_old_cust_acct_site_rec IN hz_cust_account_site_v2pub.cust_acct_site_rec_type
  );

  PROCEDURE create_cust_site_use_event (
    p_cust_site_use_rec    IN     hz_cust_account_site_v2pub.cust_site_use_rec_type,
    p_customer_profile_rec IN     hz_customer_profile_v2pub.customer_profile_rec_type,
    p_create_profile       IN     VARCHAR2,
    p_create_profile_amt   IN     VARCHAR2
  );

  PROCEDURE update_cust_site_use_event (
    p_cust_site_use_rec     IN hz_cust_account_site_v2pub.cust_site_use_rec_type,
    p_old_cust_site_use_rec IN hz_cust_account_site_v2pub.cust_site_use_rec_type
  );

  -- HZ_CUST_ACCOUNT_ROLE_V2PUB

  PROCEDURE create_cust_account_role_event (
    p_cust_account_role_rec   IN    hz_cust_account_role_v2pub.cust_account_role_rec_type
  );

  PROCEDURE update_cust_account_role_event (
    p_cust_account_role_rec     IN     hz_cust_account_role_v2pub.cust_account_role_rec_type,
    p_old_cust_account_role_rec IN     hz_cust_account_role_v2pub.cust_account_role_rec_type
  );

  PROCEDURE create_role_resp_event (
    p_role_responsibility_rec IN     hz_cust_account_role_v2pub.role_responsibility_rec_type
  );

  PROCEDURE update_role_resp_event (
    p_role_responsibility_rec     IN     hz_cust_account_role_v2pub.role_responsibility_rec_type,
    p_old_role_responsibility_rec IN     hz_cust_account_role_v2pub.role_responsibility_rec_type
  );

  -- HZ_CLASSIFICATION_V2PUB

  PROCEDURE create_class_category_event (
    p_class_category_rec          IN     hz_classification_v2pub.class_category_rec_type
  );

  PROCEDURE update_class_category_event (
    p_class_category_rec          IN     hz_classification_v2pub.class_category_rec_type,
    p_old_class_category_rec      IN     hz_classification_v2pub.class_category_rec_type
  );

  PROCEDURE create_class_code_event (
    p_class_code_rec          IN     hz_classification_v2pub.class_code_rec_type
  );

  PROCEDURE update_class_code_event (
    p_class_code_rec          IN     hz_classification_v2pub.class_code_rec_type,
    p_old_class_code_rec      IN     hz_classification_v2pub.class_code_rec_type
  );

  PROCEDURE create_class_code_rel_event (
    p_class_code_relation_rec     IN     hz_classification_v2pub.class_code_relation_rec_type
  );

  PROCEDURE update_class_code_rel_event (
    p_class_code_relation_rec     IN     hz_classification_v2pub.class_code_relation_rec_type,
    p_old_class_code_relation_rec IN     hz_classification_v2pub.class_code_relation_rec_type
  );

  PROCEDURE create_code_assignment_event (
    p_code_assignment_rec         IN     hz_classification_v2pub.code_assignment_rec_type
  );

  PROCEDURE update_code_assignment_event (
    p_code_assignment_rec         IN     hz_classification_v2pub.code_assignment_rec_type,
    p_old_code_assignment_rec     IN     hz_classification_v2pub.code_assignment_rec_type
  );

  PROCEDURE create_class_cat_use_event (
    p_class_category_use_rec      IN     hz_classification_v2pub.class_category_use_rec_type
  );

  PROCEDURE update_class_cat_use_event (
    p_class_category_use_rec      IN     hz_classification_v2pub.class_category_use_rec_type,
    p_old_class_category_use_rec  IN     hz_classification_v2pub.class_category_use_rec_type
  );

  -- HZ_PERSON_INFO_V2PUB

  PROCEDURE create_person_language_event (
    p_person_language_rec  IN     hz_person_info_v2pub.person_language_rec_type
  );

  PROCEDURE update_person_language_event (
    p_person_language_rec     IN     hz_person_info_v2pub.person_language_rec_type,
    p_old_person_language_rec IN     hz_person_info_v2pub.person_language_rec_type
  );

  PROCEDURE create_citizenship_event (
    p_citizenship_rec     IN     hz_person_info_v2pub.citizenship_rec_type
  );

  PROCEDURE update_citizenship_event (
    p_citizenship_rec     IN     hz_person_info_v2pub.citizenship_rec_type,
    p_old_citizenship_rec IN     hz_person_info_v2pub.citizenship_rec_type
  );

  PROCEDURE create_education_event (
     p_education_rec      IN     hz_person_info_v2pub.education_rec_type

  );

  PROCEDURE update_education_event (
     p_education_rec      IN     hz_person_info_v2pub.education_rec_type,
     p_old_education_rec  IN     hz_person_info_v2pub.education_rec_type
  );

  PROCEDURE create_emp_history_event (
     p_emp_history_rec    IN     hz_person_info_v2pub.employment_history_rec_type

  );

  PROCEDURE update_emp_history_event (
     p_emp_history_rec     IN     hz_person_info_v2pub.employment_history_rec_type,
     p_old_emp_history_rec IN     hz_person_info_v2pub.employment_history_rec_type

  );

  PROCEDURE create_person_interest_event (
     p_per_interest_rec     IN    hz_person_info_v2pub.person_interest_rec_type
  );

  PROCEDURE update_person_interest_event  (
     p_per_interest_rec     IN    hz_person_info_v2pub.person_interest_rec_type,
     p_old_per_interest_rec IN    hz_person_info_v2pub.person_interest_rec_type
  );

  PROCEDURE create_work_class_event   (
     p_work_class_rec          IN    hz_person_info_v2pub.work_class_rec_type
  );

  PROCEDURE update_work_class_event  (
      p_work_class_rec         IN    hz_person_info_v2pub.work_class_rec_type,
      p_old_work_class_rec     IN    hz_person_info_v2pub.work_class_rec_type
  );


  -- HZ_CUST_ACCT_INFO_PUB
/* Bug No : 4580024

  PROCEDURE create_bill_pref_event
  ( p_billing_preferences_rec   IN hz_cust_acct_info_pub.billing_preferences_rec_type);

  PROCEDURE update_bill_pref_event
  ( p_billing_preferences_rec   IN hz_cust_acct_info_pub.billing_preferences_rec_type);

  PROCEDURE create_bank_acct_uses_event
  ( p_bank_acct_uses_rec   IN  hz_cust_acct_info_pub.bank_acct_uses_rec_type );

  PROCEDURE update_bank_acct_uses_event
  ( p_bank_acct_uses_rec   IN  hz_cust_acct_info_pub.bank_acct_uses_rec_type );

  PROCEDURE create_suspension_act_event
  ( p_suspension_activity_rec   IN  hz_cust_acct_info_pub.suspension_activity_rec_type );

  PROCEDURE update_suspension_act_event
  ( p_suspension_activity_rec   IN  hz_cust_acct_info_pub.suspension_activity_rec_type );

Bug No : 4580024 */

  -- HZ_ORG_INFO_PUB

  PROCEDURE create_stock_markets_event
  ( p_stock_markets_rec IN hz_org_info_pub.stock_markets_rec_type );

  PROCEDURE update_stock_markets_event
  ( p_stock_markets_rec IN hz_org_info_pub.stock_markets_rec_type );

  PROCEDURE create_sec_issued_event
  ( p_security_issued_rec IN hz_org_info_pub.security_issued_rec_type );

  PROCEDURE update_sec_issued_event
  ( p_security_issued_rec IN hz_org_info_pub.security_issued_rec_type );

  PROCEDURE create_fin_reports_event
  ( p_financial_reports_rec IN hz_organization_info_v2pub.financial_report_rec_type );

  PROCEDURE update_fin_reports_event
  ( p_financial_reports_rec IN hz_organization_info_v2pub.financial_report_rec_type,
    p_old_financial_reports_rec IN hz_organization_info_v2pub.financial_report_rec_type );

  PROCEDURE create_fin_numbers_event
  ( p_financial_numbers_rec IN hz_organization_info_v2pub.financial_number_rec_type );

  PROCEDURE update_fin_numbers_event
  ( p_financial_numbers_rec IN hz_organization_info_v2pub.financial_number_rec_type,
    p_old_financial_numbers_rec IN hz_organization_info_v2pub.financial_number_rec_type );

  PROCEDURE create_certifications_event
  ( p_certifications_rec IN hz_org_info_pub.certifications_rec_type );

  PROCEDURE update_certifications_event
  ( p_certifications_rec IN hz_org_info_pub.certifications_rec_type );


  -- hz_party_info_v2pub

  PROCEDURE create_credit_ratings_event
  (p_credit_ratings_rec IN hz_party_info_v2pub.credit_rating_rec_type);

  PROCEDURE update_credit_ratings_event
  (p_credit_ratings_rec IN hz_party_info_v2pub.credit_rating_rec_type,
   p_old_credit_ratings_rec IN hz_party_info_v2pub.credit_rating_rec_type);

  PROCEDURE create_fin_profile_event
  (p_financial_profile_rec IN hz_party_info_pub.financial_profile_rec_type);

  PROCEDURE update_fin_profile_event
  (p_financial_profile_rec IN hz_party_info_pub.financial_profile_rec_type);

  -- hz_orig_system_reference

   PROCEDURE create_orig_system_ref_event (
    p_orig_sys_reference_rec	  IN HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE
  );

  PROCEDURE update_orig_system_ref_event (
    p_orig_sys_reference_rec	  IN HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE,
    p_old_orig_sys_reference_re   IN HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE
  );


END hz_business_event_v2pvt;

 

/
