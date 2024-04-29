--------------------------------------------------------
--  DDL for Package PAY_JP_DEF_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_DEF_API" AUTHID CURRENT_USER as
/* $Header: pyjpdefa.pkh 120.0.12000000.3 2007/05/10 03:17:58 ttagawa noship $ */
-- |---------------------------------------------------------------------------|
-- |------------------------------< create_pact >------------------------------|
-- |---------------------------------------------------------------------------|
--  Access Status:
--  Internal Development Use Only
procedure create_pact(
	P_VALIDATE			in boolean	default null,
	P_PAYROLL_ACTION_ID		in number,
	P_EFFECTIVE_DATE		in date,
	P_PAYROLL_ID			in number	default null,
	P_ORGANIZATION_ID		in number	default null,
	P_SUBMISSION_PERIOD_STATUS	in varchar2	default null,
	P_SUBMISSION_START_DATE		in date		default null,
	P_SUBMISSION_END_DATE		in date		default null,
	P_TAX_OFFICE_NAME		in varchar2	default null,
	P_SALARY_PAYER_NAME		in varchar2	default null,
	P_SALARY_PAYER_ADDRESS		in varchar2	default null,
	P_ACTION_INFORMATION_ID		out nocopy number,
	P_OBJECT_VERSION_NUMBER		out nocopy number);
-- |---------------------------------------------------------------------------|
-- |------------------------------< update_pact >------------------------------|
-- |---------------------------------------------------------------------------|
--  Access Status:
--  Internal Development Use Only
procedure update_pact(
	P_VALIDATE			in number	default hr_api.g_false_num,
	P_ACTION_INFORMATION_ID		in number,
	P_OBJECT_VERSION_NUMBER		in out nocopy number,
	P_SUBMISSION_PERIOD_STATUS	in varchar2	default hr_api.g_varchar2,
	P_SUBMISSION_START_DATE		in date		default hr_api.g_date,
	P_SUBMISSION_END_DATE		in date		default hr_api.g_date,
	P_TAX_OFFICE_NAME		in varchar2	default hr_api.g_varchar2,
	P_SALARY_PAYER_NAME		in varchar2	default hr_api.g_varchar2,
	P_SALARY_PAYER_ADDRESS		in varchar2	default hr_api.g_varchar2,
	p_return_status			out nocopy varchar2);
-- |---------------------------------------------------------------------------|
-- |-----------------------------< create_assact >-----------------------------|
-- |---------------------------------------------------------------------------|
--  Access Status:
--  Internal Development Use Only
procedure create_assact(
	P_VALIDATE			in boolean	default false,
	P_ASSIGNMENT_ACTION_ID		in number,
	P_EFFECTIVE_DATE		in date,
	P_ASSIGNMENT_ID			in number,
	P_TAX_TYPE			in varchar2	default null,
	P_TRANSACTION_STATUS		in varchar2	default null,
	P_FINALIZED_DATE		in date		default null,
	P_FINALIZED_BY			in number	default null,
	P_USER_COMMENTS			in varchar2	default null,
	P_ADMIN_COMMENTS		in varchar2	default null,
	P_TRANSFER_STATUS		in varchar2	default null,
	P_EXPIRY_DATE			in date		default null,
	P_ACTION_INFORMATION_ID		out nocopy number,
	P_OBJECT_VERSION_NUMBER		out nocopy number);
-- |---------------------------------------------------------------------------|
-- |-----------------------------< update_assact >-----------------------------|
-- |---------------------------------------------------------------------------|
--  Access Status:
--  Internal Development Use Only
procedure update_assact(
	P_VALIDATE			in boolean	default false,
	P_ACTION_INFORMATION_ID		in number,
	P_OBJECT_VERSION_NUMBER		in out nocopy number,
	P_TRANSACTION_STATUS		in varchar2	default hr_api.g_varchar2,
	P_FINALIZED_DATE		in date		default hr_api.g_date,
	P_FINALIZED_BY			in number	default hr_api.g_number,
	P_USER_COMMENTS			in varchar2	default hr_api.g_varchar2,
	P_ADMIN_COMMENTS		in varchar2	default hr_api.g_varchar2,
	P_TRANSFER_STATUS		in varchar2	default hr_api.g_varchar2,
	P_EXPIRY_DATE			in date		default hr_api.g_date);
--  Access Status:
--  Internal Development Use Only
procedure update_assact(
	P_VALIDATE			in number	default hr_api.g_false_num,
	P_ACTION_INFORMATION_ID		in number,
	P_OBJECT_VERSION_NUMBER		in out nocopy number,
	P_TRANSACTION_STATUS		in varchar2	default hr_api.g_varchar2,
	P_FINALIZED_DATE		in date		default hr_api.g_date,
	P_FINALIZED_BY			in number	default hr_api.g_number,
	P_USER_COMMENTS			in varchar2	default hr_api.g_varchar2,
	P_ADMIN_COMMENTS		in varchar2	default hr_api.g_varchar2,
	P_TRANSFER_STATUS		in varchar2	default hr_api.g_varchar2,
	P_EXPIRY_DATE			in date		default hr_api.g_date,
	p_return_status			out nocopy varchar2);
-- |---------------------------------------------------------------------------|
-- |------------------------------< create_emp >-------------------------------|
-- |---------------------------------------------------------------------------|
--  Access Status:
--  Internal Development Use Only
procedure create_emp(
	P_VALIDATE			in boolean	default false,
	P_ASSIGNMENT_ACTION_ID		in number,
	P_EFFECTIVE_DATE		in date,
	P_ASSIGNMENT_ID			in number,
	P_LAST_NAME_KANA		in varchar2	default null,
	P_FIRST_NAME_KANA		in varchar2	default null,
	P_LAST_NAME			in varchar2	default null,
	P_FIRST_NAME			in varchar2	default null,
	P_DATE_OF_BIRTH			in date		default null,
	P_DATE_OF_DEATH			in date		default null,
	P_SEX				in varchar2	default null,
	P_POSTAL_CODE			in varchar2	default null,
	P_ADDRESS			in varchar2	default null,
	P_HOUSEHOLD_HEAD_CTR_ID		in number	default null,
	P_HOUSEHOLD_HEAD_FULL_NAME	in varchar2	default null,
	P_HOUSEHOLD_HEAD_CONTACT_TYPE	in varchar2	default null,
	P_MARRIED_FLAG			in varchar2	default null,
	P_CHANGE_DATE			in date		default null,
	P_CHANGE_REASON			in varchar2	default null,
	P_DISABILITY_TYPE		in varchar2	default null,
	P_DISABILITY_DETAILS		in varchar2	default null,
	P_AGED_TYPE			in varchar2	default null,
	P_AGED_DETAILS			in varchar2	default null,
	P_WIDOW_TYPE			in varchar2	default null,
	P_WIDOW_DETAILS			in varchar2	default null,
	P_WORKING_STUDENT_TYPE		in varchar2	default null,
	P_WORKING_STUDENT_DETAILS	in varchar2	default null,
	P_ACTION_INFORMATION_ID		out nocopy number,
	P_OBJECT_VERSION_NUMBER		out nocopy number);
-- |---------------------------------------------------------------------------|
-- |------------------------------< update_emp >-------------------------------|
-- |---------------------------------------------------------------------------|
--  Access Status:
--  Internal Development Use Only
procedure update_emp(
	P_VALIDATE			in number	default hr_api.g_false_num,
	P_ACTION_INFORMATION_ID		in number,
	P_OBJECT_VERSION_NUMBER		in out nocopy number,
	P_CHANGE_DATE			in date		default hr_api.g_date,
	P_CHANGE_REASON			in varchar2	default hr_api.g_varchar2,
	P_DISABILITY_TYPE		in varchar2	default hr_api.g_varchar2,
	P_DISABILITY_DETAILS		in varchar2	default hr_api.g_varchar2,
	P_AGED_TYPE			in varchar2	default hr_api.g_varchar2,
	P_AGED_DETAILS			in varchar2	default hr_api.g_varchar2,
	P_WIDOW_TYPE			in varchar2	default hr_api.g_varchar2,
	P_WIDOW_DETAILS			in varchar2	default hr_api.g_varchar2,
	P_WORKING_STUDENT_TYPE		in varchar2	default hr_api.g_varchar2,
	P_WORKING_STUDENT_DETAILS	in varchar2	default hr_api.g_varchar2,
	p_return_status			out nocopy varchar2);
-- |---------------------------------------------------------------------------|
-- |-----------------------------< create_entry >------------------------------|
-- |---------------------------------------------------------------------------|
--  Access Status:
--  Internal Development Use Only
procedure create_entry(
	P_VALIDATE			in boolean	default false,
	P_ASSIGNMENT_ACTION_ID		in number,
	P_EFFECTIVE_DATE		in date,
	P_ASSIGNMENT_ID			in number,
	P_STATUS			in varchar2	default null,
	P_DATETRACK_UPDATE_MODE		in varchar2	default null,
	P_ELEMENT_ENTRY_ID		in number	default null,
	P_EE_OBJECT_VERSION_NUMBER	in number	default null,
	P_DISABILITY_TYPE		in varchar2	default null,
	P_DISABILITY_TYPE_O		in varchar2	default null,
	P_AGED_TYPE			in varchar2	default null,
	P_AGED_TYPE_O			in varchar2	default null,
	P_WIDOW_TYPE			in varchar2	default null,
	P_WIDOW_TYPE_O			in varchar2	default null,
	P_WORKING_STUDENT_TYPE		in varchar2	default null,
	P_WORKING_STUDENT_TYPE_O	in varchar2	default null,
	P_SPOUSE_DEP_TYPE		in varchar2	default null,
	P_SPOUSE_DEP_TYPE_O		in varchar2	default null,
	P_SPOUSE_DISABILITY_TYPE	in varchar2	default null,
	P_SPOUSE_DISABILITY_TYPE_O	in varchar2	default null,
	P_NUM_DEPS			in number	default null,
	P_NUM_DEPS_O			in number	default null,
	P_NUM_AGEDS			in number	default null,
	P_NUM_AGEDS_O			in number	default null,
	P_NUM_AGED_PARENTS_LT		in number	default null,
	P_NUM_AGED_PARENTS_LT_O		in number	default null,
	P_NUM_SPECIFIEDS		in number	default null,
	P_NUM_SPECIFIEDS_O		in number	default null,
	P_NUM_DISABLEDS			in number	default null,
	P_NUM_DISABLEDS_O		in number	default null,
	P_NUM_SVR_DISABLEDS		in number	default null,
	P_NUM_SVR_DISABLEDS_O		in number	default null,
	P_NUM_SVR_DISABLEDS_LT		in number	default null,
	P_NUM_SVR_DISABLEDS_LT_O	in number	default null,
	P_ACTION_INFORMATION_ID		out nocopy number,
	P_OBJECT_VERSION_NUMBER		out nocopy number);
-- |---------------------------------------------------------------------------|
-- |-----------------------------< update_entry >------------------------------|
-- |---------------------------------------------------------------------------|
--  Access Status:
--  Internal Development Use Only
procedure update_entry(
	P_VALIDATE			in boolean	default false,
	P_ACTION_INFORMATION_ID		in number,
	P_OBJECT_VERSION_NUMBER		in out nocopy number,
	P_STATUS			in varchar2	default hr_api.g_varchar2,
	P_ELEMENT_ENTRY_ID		in number	default hr_api.g_number,
	P_EE_OBJECT_VERSION_NUMBER	in number	default hr_api.g_number,
	P_DISABILITY_TYPE		in varchar2	default hr_api.g_varchar2,
	P_AGED_TYPE			in varchar2	default hr_api.g_varchar2,
	P_WIDOW_TYPE			in varchar2	default hr_api.g_varchar2,
	P_WORKING_STUDENT_TYPE		in varchar2	default hr_api.g_varchar2,
	P_SPOUSE_DEP_TYPE		in varchar2	default hr_api.g_varchar2,
	P_SPOUSE_DISABILITY_TYPE	in varchar2	default hr_api.g_varchar2,
	P_NUM_DEPS			in number	default hr_api.g_number,
	P_NUM_AGEDS			in number	default hr_api.g_number,
	P_NUM_AGED_PARENTS_LT		in number	default hr_api.g_number,
	P_NUM_SPECIFIEDS		in number	default hr_api.g_number,
	P_NUM_DISABLEDS			in number	default hr_api.g_number,
	P_NUM_SVR_DISABLEDS		in number	default hr_api.g_number,
	P_NUM_SVR_DISABLEDS_LT		in number	default hr_api.g_number);
-- |---------------------------------------------------------------------------|
-- |------------------------------< create_dep >-------------------------------|
-- |---------------------------------------------------------------------------|
--  Access Status:
--  Internal Development Use Only
procedure create_dep(
	P_VALIDATE			in boolean	default false,
	P_ASSIGNMENT_ACTION_ID		in number,
	P_EFFECTIVE_DATE		in date,
	P_ASSIGNMENT_ID			in number,
	P_STATUS			in varchar2	default null,
	P_DATETRACK_UPDATE_MODE		in varchar2	default null,
	P_DATETRACK_DELETE_MODE		in varchar2	default null,
	P_CONTACT_EXTRA_INFO_ID		in number	default null,
	P_CEI_OBJECT_VERSION_NUMBER	in number	default null,
	P_CONTACT_RELATIONSHIP_ID	in number	default null,
	P_LAST_NAME_KANA		in varchar2	default null,
	P_FIRST_NAME_KANA		in varchar2	default null,
	P_LAST_NAME			in varchar2	default null,
	P_FIRST_NAME			in varchar2	default null,
	P_CONTACT_TYPE			in varchar2	default null,
	P_DATE_OF_BIRTH			in date		default null,
	P_DATE_OF_DEATH			in date		default null,
	P_ADDRESS			in varchar2	default null,
	P_CHANGE_DATE			in date		default null,
	P_CHANGE_REASON			in varchar2	default null,
	P_DEP_TYPE			in varchar2	default null,
	P_DEP_TYPE_O			in varchar2	default null,
	P_OCCUPATION			in varchar2	default null,
	P_OCCUPATION_O			in varchar2	default null,
	P_ESTIMATED_ANNUAL_INCOME	in number	default null,
	P_ESTIMATED_ANNUAL_INCOME_O	in number	default null,
	P_DISABILITY_TYPE		in varchar2	default null,
	P_DISABILITY_TYPE_O		in varchar2	default null,
	P_DISABILITY_DETAILS		in varchar2	default null,
	P_DISABILITY_DETAILS_O		in varchar2	default null,
	P_ACTION_INFORMATION_ID		out nocopy number,
	P_OBJECT_VERSION_NUMBER		out nocopy number);
--  Access Status:
--  Internal Development Use Only
procedure create_dep(
	P_VALIDATE			in number	default hr_api.g_false_num,
	P_ACTION_INFORMATION_ID		in number,
	P_ASSIGNMENT_ACTION_ID		in number,
	P_EFFECTIVE_DATE		in date,
	P_ASSIGNMENT_ID			in number,
	P_STATUS			in varchar2	default null,
	P_DATETRACK_UPDATE_MODE		in varchar2	default null,
	P_DATETRACK_DELETE_MODE		in varchar2	default null,
	P_CONTACT_EXTRA_INFO_ID		in number	default null,
	P_CEI_OBJECT_VERSION_NUMBER	in number	default null,
	P_CONTACT_RELATIONSHIP_ID	in number	default null,
	P_LAST_NAME_KANA		in varchar2	default null,
	P_FIRST_NAME_KANA		in varchar2	default null,
	P_LAST_NAME			in varchar2	default null,
	P_FIRST_NAME			in varchar2	default null,
	P_CONTACT_TYPE			in varchar2	default null,
	P_DATE_OF_BIRTH			in date		default null,
	P_DATE_OF_DEATH			in date		default null,
	P_ADDRESS			in varchar2	default null,
	P_CHANGE_DATE			in date		default null,
	P_CHANGE_REASON			in varchar2	default null,
	P_DEP_TYPE			in varchar2	default null,
	P_DEP_TYPE_O			in varchar2	default null,
	P_OCCUPATION			in varchar2	default null,
	P_OCCUPATION_O			in varchar2	default null,
	P_ESTIMATED_ANNUAL_INCOME	in number	default null,
	P_ESTIMATED_ANNUAL_INCOME_O	in number	default null,
	P_DISABILITY_TYPE		in varchar2	default null,
	P_DISABILITY_TYPE_O		in varchar2	default null,
	P_DISABILITY_DETAILS		in varchar2	default null,
	P_DISABILITY_DETAILS_O		in varchar2	default null,
	P_OBJECT_VERSION_NUMBER		out nocopy number,
	p_return_status			out nocopy varchar2);
-- |---------------------------------------------------------------------------|
-- |------------------------------< update_dep >-------------------------------|
-- |---------------------------------------------------------------------------|
--  Access Status:
--  Internal Development Use Only
procedure update_dep(
	P_VALIDATE			in boolean	default false,
	P_ACTION_INFORMATION_ID		in number,
	P_OBJECT_VERSION_NUMBER		in out nocopy number,
	P_STATUS			in varchar2	default hr_api.g_varchar2,
	P_CONTACT_EXTRA_INFO_ID		in number	default hr_api.g_number,
	P_CEI_OBJECT_VERSION_NUMBER	in number	default hr_api.g_number,
	P_CHANGE_DATE			in date		default hr_api.g_date,
	P_CHANGE_REASON			in varchar2	default hr_api.g_varchar2,
	P_DEP_TYPE			in varchar2	default hr_api.g_varchar2,
	P_OCCUPATION			in varchar2	default hr_api.g_varchar2,
	P_ESTIMATED_ANNUAL_INCOME	in number	default hr_api.g_number,
	P_DISABILITY_TYPE		in varchar2	default hr_api.g_varchar2,
	P_DISABILITY_DETAILS		in varchar2	default hr_api.g_varchar2);
--  Access Status:
--  Internal Development Use Only
procedure update_dep(
	P_VALIDATE			in number	default hr_api.g_false_num,
	P_ACTION_INFORMATION_ID		in number,
	P_OBJECT_VERSION_NUMBER		in out nocopy number,
	P_STATUS			in varchar2	default hr_api.g_varchar2,
	P_CONTACT_EXTRA_INFO_ID		in number	default hr_api.g_number,
	P_CEI_OBJECT_VERSION_NUMBER	in number	default hr_api.g_number,
	P_CHANGE_DATE			in date		default hr_api.g_date,
	P_CHANGE_REASON			in varchar2	default hr_api.g_varchar2,
	P_DEP_TYPE			in varchar2	default hr_api.g_varchar2,
	P_OCCUPATION			in varchar2	default hr_api.g_varchar2,
	P_ESTIMATED_ANNUAL_INCOME	in number	default hr_api.g_number,
	P_DISABILITY_TYPE		in varchar2	default hr_api.g_varchar2,
	P_DISABILITY_DETAILS		in varchar2	default hr_api.g_varchar2,
	p_return_status			out nocopy varchar2);
-- |---------------------------------------------------------------------------|
-- |-----------------------------< create_dep_oe >-----------------------------|
-- |---------------------------------------------------------------------------|
--  Access Status:
--  Internal Development Use Only
procedure create_dep_oe(
	P_VALIDATE			in boolean	default false,
	P_ASSIGNMENT_ACTION_ID		in number,
	P_EFFECTIVE_DATE		in date,
	P_ASSIGNMENT_ID			in number,
	P_STATUS			in varchar2	default null,
	P_DATETRACK_UPDATE_MODE		in varchar2	default null,
	P_DATETRACK_DELETE_MODE		in varchar2	default null,
	P_CONTACT_EXTRA_INFO_ID		in number	default null,
	P_CEI_OBJECT_VERSION_NUMBER	in number	default null,
	P_CONTACT_RELATIONSHIP_ID	in number	default null,
	P_LAST_NAME_KANA		in varchar2	default null,
	P_FIRST_NAME_KANA		in varchar2	default null,
	P_LAST_NAME			in varchar2	default null,
	P_FIRST_NAME			in varchar2	default null,
	P_CONTACT_TYPE			in varchar2	default null,
	P_DATE_OF_BIRTH			in date		default null,
	P_DATE_OF_DEATH			in date		default null,
	P_ADDRESS			in varchar2	default null,
	P_CHANGE_DATE			in date		default null,
	P_CHANGE_REASON			in varchar2	default null,
	P_OCCUPATION			in varchar2	default null,
	P_OCCUPATION_O			in varchar2	default null,
	P_OE_CONTACT_RELATIONSHIP_ID	in number	default null,
	P_OE_FULL_NAME			in varchar2	default null,
	P_OE_CONTACT_TYPE		in varchar2	default null,
	P_OE_ADDRESS			in varchar2	default null,
	P_OE_CONTACT_RELATIONSHIP_ID_O	in number	default null,
	P_ACTION_INFORMATION_ID		out nocopy number,
	P_OBJECT_VERSION_NUMBER		out nocopy number);
--  Access Status:
--  Internal Development Use Only
procedure create_dep_oe(
	P_VALIDATE			in number	default hr_api.g_false_num,
	P_ACTION_INFORMATION_ID		in number,
	P_ASSIGNMENT_ACTION_ID		in number,
	P_EFFECTIVE_DATE		in date,
	P_ASSIGNMENT_ID			in number,
	P_STATUS			in varchar2	default null,
	P_DATETRACK_UPDATE_MODE		in varchar2	default null,
	P_DATETRACK_DELETE_MODE		in varchar2	default null,
	P_CONTACT_EXTRA_INFO_ID		in number	default null,
	P_CEI_OBJECT_VERSION_NUMBER	in number	default null,
	P_CONTACT_RELATIONSHIP_ID	in number	default null,
	P_LAST_NAME_KANA		in varchar2	default null,
	P_FIRST_NAME_KANA		in varchar2	default null,
	P_LAST_NAME			in varchar2	default null,
	P_FIRST_NAME			in varchar2	default null,
	P_CONTACT_TYPE			in varchar2	default null,
	P_DATE_OF_BIRTH			in date		default null,
	P_DATE_OF_DEATH			in date		default null,
	P_ADDRESS			in varchar2	default null,
	P_CHANGE_DATE			in date		default null,
	P_CHANGE_REASON			in varchar2	default null,
	P_OCCUPATION			in varchar2	default null,
	P_OCCUPATION_O			in varchar2	default null,
	P_OE_CONTACT_RELATIONSHIP_ID	in number	default null,
	P_OE_FULL_NAME			in varchar2	default null,
	P_OE_CONTACT_TYPE		in varchar2	default null,
	P_OE_ADDRESS			in varchar2	default null,
	P_OE_CONTACT_RELATIONSHIP_ID_O	in number	default null,
	P_OBJECT_VERSION_NUMBER		out nocopy number,
	p_return_status			out nocopy varchar2);
-- |---------------------------------------------------------------------------|
-- |-----------------------------< update_dep_oe >-----------------------------|
-- |---------------------------------------------------------------------------|
--  Access Status:
--  Internal Development Use Only
procedure update_dep_oe(
	P_VALIDATE			in boolean	default false,
	P_ACTION_INFORMATION_ID		in number,
	P_OBJECT_VERSION_NUMBER		in out nocopy number,
	P_STATUS			in varchar2	default hr_api.g_varchar2,
	P_CONTACT_EXTRA_INFO_ID		in number	default hr_api.g_number,
	P_CEI_OBJECT_VERSION_NUMBER	in number	default hr_api.g_number,
	P_CHANGE_DATE			in date		default hr_api.g_date,
	P_CHANGE_REASON			in varchar2	default hr_api.g_varchar2,
	P_OCCUPATION			in varchar2	default hr_api.g_varchar2,
	P_OE_CONTACT_RELATIONSHIP_ID	in number	default hr_api.g_number,
	P_OE_FULL_NAME			in varchar2	default hr_api.g_varchar2,
	P_OE_CONTACT_TYPE		in varchar2	default hr_api.g_varchar2,
	P_OE_ADDRESS			in varchar2	default hr_api.g_varchar2);
--  Access Status:
--  Internal Development Use Only
procedure update_dep_oe(
	P_VALIDATE			in number	default hr_api.g_false_num,
	P_ACTION_INFORMATION_ID		in number,
	P_OBJECT_VERSION_NUMBER		in out nocopy number,
	P_STATUS			in varchar2	default hr_api.g_varchar2,
	P_CONTACT_EXTRA_INFO_ID		in number	default hr_api.g_number,
	P_CEI_OBJECT_VERSION_NUMBER	in number	default hr_api.g_number,
	P_CHANGE_DATE			in date		default hr_api.g_date,
	P_CHANGE_REASON			in varchar2	default hr_api.g_varchar2,
	P_OCCUPATION			in varchar2	default hr_api.g_varchar2,
	P_OE_CONTACT_RELATIONSHIP_ID	in number	default hr_api.g_number,
	P_OE_FULL_NAME			in varchar2	default hr_api.g_varchar2,
	P_OE_CONTACT_TYPE		in varchar2	default hr_api.g_varchar2,
	P_OE_ADDRESS			in varchar2	default hr_api.g_varchar2,
	p_return_status			out nocopy varchar2);
-- |---------------------------------------------------------------------------|
-- |-----------------------------< create_dep_os >-----------------------------|
-- |---------------------------------------------------------------------------|
--  Access Status:
--  Internal Development Use Only
procedure create_dep_os(
	P_VALIDATE			in boolean	default false,
	P_ASSIGNMENT_ACTION_ID		in number,
	P_EFFECTIVE_DATE		in date,
	P_ASSIGNMENT_ID			in number,
	P_STATUS			in varchar2	default null,
	P_DATETRACK_UPDATE_MODE		in varchar2	default null,
	P_DATETRACK_DELETE_MODE		in varchar2	default null,
	P_CONTACT_EXTRA_INFO_ID		in number	default null,
	P_CEI_OBJECT_VERSION_NUMBER	in number	default null,
	P_CONTACT_RELATIONSHIP_ID	in number	default null,
	P_LAST_NAME_KANA		in varchar2	default null,
	P_FIRST_NAME_KANA		in varchar2	default null,
	P_LAST_NAME			in varchar2	default null,
	P_FIRST_NAME			in varchar2	default null,
	P_CONTACT_TYPE			in varchar2	default null,
	P_DATE_OF_BIRTH			in date		default null,
	P_DATE_OF_DEATH			in date		default null,
	P_OCCUPATION			in varchar2	default null,
	P_OCCUPATION_O			in varchar2	default null,
	P_OS_SALARY_PAYER_NAME		in varchar2	default null,
	P_OS_SALARY_PAYER_NAME_O	in varchar2	default null,
	P_OS_SALARY_PAYER_ADDRESS	in varchar2	default null,
	P_OS_SALARY_PAYER_ADDRESS_O	in varchar2	default null,
	P_ACTION_INFORMATION_ID		out nocopy number,
	P_OBJECT_VERSION_NUMBER		out nocopy number);
--  Access Status:
--  Internal Development Use Only
procedure create_dep_os(
	P_VALIDATE			in number	default hr_api.g_false_num,
	P_ACTION_INFORMATION_ID		in number,
	P_ASSIGNMENT_ACTION_ID		in number,
	P_EFFECTIVE_DATE		in date,
	P_ASSIGNMENT_ID			in number,
	P_STATUS			in varchar2	default null,
	P_DATETRACK_UPDATE_MODE		in varchar2	default null,
	P_DATETRACK_DELETE_MODE		in varchar2	default null,
	P_CONTACT_EXTRA_INFO_ID		in number	default null,
	P_CEI_OBJECT_VERSION_NUMBER	in number	default null,
	P_CONTACT_RELATIONSHIP_ID	in number	default null,
	P_LAST_NAME_KANA		in varchar2	default null,
	P_FIRST_NAME_KANA		in varchar2	default null,
	P_LAST_NAME			in varchar2	default null,
	P_FIRST_NAME			in varchar2	default null,
	P_CONTACT_TYPE			in varchar2	default null,
	P_DATE_OF_BIRTH			in date		default null,
	P_DATE_OF_DEATH			in date		default null,
	P_OCCUPATION			in varchar2	default null,
	P_OCCUPATION_O			in varchar2	default null,
	P_OS_SALARY_PAYER_NAME		in varchar2	default null,
	P_OS_SALARY_PAYER_NAME_O	in varchar2	default null,
	P_OS_SALARY_PAYER_ADDRESS	in varchar2	default null,
	P_OS_SALARY_PAYER_ADDRESS_O	in varchar2	default null,
	P_OBJECT_VERSION_NUMBER		out nocopy number,
	p_return_status			out nocopy varchar2);
-- |---------------------------------------------------------------------------|
-- |-----------------------------< update_dep_os >-----------------------------|
-- |---------------------------------------------------------------------------|
--  Access Status:
--  Internal Development Use Only
procedure update_dep_os(
	P_VALIDATE			in boolean	default false,
	P_ACTION_INFORMATION_ID		in number,
	P_OBJECT_VERSION_NUMBER		in out nocopy number,
	P_STATUS			in varchar2	default hr_api.g_varchar2,
	P_CONTACT_EXTRA_INFO_ID		in number	default hr_api.g_number,
	P_CEI_OBJECT_VERSION_NUMBER	in number	default hr_api.g_number,
	P_OCCUPATION			in varchar2	default hr_api.g_varchar2,
	P_OS_SALARY_PAYER_NAME		in varchar2	default hr_api.g_varchar2,
	P_OS_SALARY_PAYER_ADDRESS	in varchar2	default hr_api.g_varchar2);
--  Access Status:
--  Internal Development Use Only
procedure update_dep_os(
	P_VALIDATE			in number	default hr_api.g_false_num,
	P_ACTION_INFORMATION_ID		in number,
	P_OBJECT_VERSION_NUMBER		in out nocopy number,
	P_STATUS			in varchar2	default hr_api.g_varchar2,
	P_CONTACT_EXTRA_INFO_ID		in number	default hr_api.g_number,
	P_CEI_OBJECT_VERSION_NUMBER	in number	default hr_api.g_number,
	P_OCCUPATION			in varchar2	default hr_api.g_varchar2,
	P_OS_SALARY_PAYER_NAME		in varchar2	default hr_api.g_varchar2,
	P_OS_SALARY_PAYER_ADDRESS	in varchar2	default hr_api.g_varchar2,
	p_return_status			out nocopy varchar2);
--
end pay_jp_def_api;

 

/
