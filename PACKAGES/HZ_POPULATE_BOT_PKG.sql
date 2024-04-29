--------------------------------------------------------
--  DDL for Package HZ_POPULATE_BOT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_POPULATE_BOT_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHPBOTS.pls 120.2 2006/03/06 18:12:44 acng noship $ */

  -- for HZ_WORK_CLASS
  PROCEDURE pop_hz_work_class(p_operation IN VARCHAR2, p_work_class_id IN NUMBER);

  -- for HZ_ROLE_RESPONSIBILITY
  PROCEDURE pop_hz_role_responsibility(p_operation IN VARCHAR2, p_responsibility_id IN NUMBER);

  -- for HZ_RELATIONSHIPS
  PROCEDURE pop_hz_relationships(p_operation IN VARCHAR2, p_RELATIONSHIP_ID IN NUMBER);

  -- for HZ_PERSON_PROFILES
  PROCEDURE pop_hz_person_profiles(p_operation IN VARCHAR2, p_person_profile_id IN NUMBER);

  -- for HZ_PERSON_LANGUAGE
  PROCEDURE pop_hz_person_language(p_operation IN VARCHAR2, p_language_use_reference_id IN NUMBER);

  -- for HZ_PERSON_INTEREST
  PROCEDURE pop_hz_person_interest(p_operation IN VARCHAR2, p_person_interest_id IN NUMBER);

  -- for HZ_PARTY_SITE_USES
  PROCEDURE pop_hz_party_site_uses(p_operation IN VARCHAR2, p_party_site_use_id IN NUMBER);

  -- for HZ_PARTY_SITES
  PROCEDURE pop_hz_party_sites(p_operation IN VARCHAR2, p_party_site_id IN NUMBER);

  -- for HZ_PARTY_PREFERENCES
  PROCEDURE pop_hz_party_preferences(p_operation IN VARCHAR2, p_party_preference_id IN NUMBER);

  -- for HZ_ORG_CONTACT_ROLES
  PROCEDURE pop_hz_org_contact_roles(p_operation IN VARCHAR2, p_org_contact_role_id IN NUMBER);

  -- for HZ_ORG_CONTACTS
  PROCEDURE pop_hz_org_contacts(p_operation IN VARCHAR2, p_org_contact_id IN NUMBER);

  -- for HZ_ORGANIZATION_PROFILES
  PROCEDURE pop_hz_organization_profiles(p_operation IN VARCHAR2, p_ORGANIZATION_PROFILE_ID IN NUMBER);

  -- for HZ_LOCATIONS
  PROCEDURE pop_hz_locations(p_operation IN VARCHAR2, p_LOCATION_ID IN NUMBER);

  -- for HZ_FINANCIAL_REPORTS
  PROCEDURE pop_hz_financial_reports(p_operation IN VARCHAR2, p_FINANCIAL_REPORT_ID IN NUMBER);

  -- for HZ_FINANCIAL_PROFILE
  PROCEDURE pop_hz_financial_profile(p_operation IN VARCHAR2, p_FINANCIAL_PROFILE_ID IN NUMBER);

  -- for HZ_FINANCIAL_NUMBERS
  PROCEDURE pop_hz_financial_numbers(p_operation IN VARCHAR2, p_FINANCIAL_NUMBER_ID IN NUMBER);

  -- for HZ_EMPLOYMENT_HISTORY
  PROCEDURE pop_hz_employment_history(p_operation IN VARCHAR2, p_EMPLOYMENT_HISTORY_ID IN NUMBER);

  -- for HZ_EDUCATION
  PROCEDURE pop_hz_education(p_operation IN VARCHAR2, p_EDUCATION_ID IN NUMBER);

  -- for HZ_CUST_SITE_USES_ALL
  PROCEDURE pop_hz_cust_site_uses_all(p_operation IN VARCHAR2, p_site_use_id IN NUMBER);

  -- for HZ_CUST_PROFILE_AMTS
  PROCEDURE pop_hz_cust_profile_amts(p_operation IN VARCHAR2, p_cust_acct_profile_amt_id IN NUMBER);

  -- for HZ_CUST_ACCT_SITES_ALL
  PROCEDURE pop_hz_cust_acct_sites_all(p_operation IN VARCHAR2, p_cust_acct_site_id IN NUMBER);

  -- for HZ_CUST_ACCT_RELATE_ALL
  PROCEDURE pop_hz_cust_acct_relate_all(p_operation IN VARCHAR2, p_cust_acct_relate_id IN NUMBER);

  -- for HZ_CUST_ACCOUNT_ROLES
  PROCEDURE pop_hz_cust_account_roles(p_operation IN VARCHAR2, p_cust_account_role_id IN NUMBER);

  -- for HZ_CUST_ACCOUNTS
  PROCEDURE pop_hz_cust_accounts(p_operation IN VARCHAR2, p_cust_account_id IN NUMBER);

  -- for HZ_CUSTOMER_PROFILES
  PROCEDURE pop_hz_customer_profiles(p_operation IN VARCHAR2, p_cust_account_profile_id IN NUMBER);

  -- for HZ_CREDIT_RATINGS
  PROCEDURE pop_hz_credit_ratings(p_operation IN VARCHAR2, p_credit_rating_id IN NUMBER);

  -- for HZ_CONTACT_PREFERENCES
  PROCEDURE pop_hz_contact_preferences(p_operation IN VARCHAR2, p_contact_preference_id IN NUMBER);

  -- for HZ_CONTACT_POINTS
  PROCEDURE pop_hz_contact_points(p_operation IN VARCHAR2, p_contact_point_id IN NUMBER);

  -- for HZ_CODE_ASSIGNMENTS
  PROCEDURE pop_hz_code_assignments(p_operation IN VARCHAR2, p_code_assignment_id IN NUMBER);

  -- for HZ_CITIZENSHIP
  PROCEDURE pop_hz_citizenship(p_operation IN VARCHAR2, p_citizenship_id IN NUMBER);

  -- for HZ_CERTIFICATIONS
  PROCEDURE pop_hz_certifications(p_operation IN VARCHAR2, p_certification_id IN NUMBER);

  -- for HZ_PARTY_USG_ASSIGNMENTS
  PROCEDURE pop_HZ_PARTY_USG_ASSIGNMENTS(p_operation IN VARCHAR2, p_PARTY_USG_ASSIGNMENT_ID IN NUMBER);

  -- for extensibility
  PROCEDURE pop_hz_extensibility(p_operation IN VARCHAR2, p_object_type IN VARCHAR2, p_extension_id IN NUMBER);

  -- for RA_CUST_RECEIPT_METHODS
  PROCEDURE pop_ra_cust_receipt_methods(p_operation IN VARCHAR2, p_cust_receipt_method_id IN NUMBER);

END HZ_POPULATE_BOT_PKG;

 

/
