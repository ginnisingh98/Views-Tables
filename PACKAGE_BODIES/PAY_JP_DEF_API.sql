--------------------------------------------------------
--  DDL for Package Body PAY_JP_DEF_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_DEF_API" as
/* $Header: pyjpdefa.pkb 120.0.12000000.3 2007/05/10 03:18:53 ttagawa noship $ */
--
-- Constants
--
c_package		constant varchar2(31) := 'pay_jp_def_api.';
--
-- Private Functions/Procedures
--
-- |---------------------------------------------------------------------------|
-- |-----------------------------< to_canonical >------------------------------|
-- |---------------------------------------------------------------------------|
function to_canonical(p_number in number) return varchar2
is
begin
	if p_number is not null then
		if p_number = hr_api.g_number then
			return hr_api.g_varchar2;
		else
			return fnd_number.number_to_canonical(p_number);
		end if;
	end if;
	--
	return null;
end to_canonical;
--
function to_canonical(p_date in date) return varchar2
is
begin
	if p_date is not null then
		if p_date = hr_api.g_date then
			return hr_api.g_varchar2;
		else
			return fnd_date.date_to_canonical(p_date);
		end if;
	end if;
	--
	return null;
end to_canonical;
-- |---------------------------------------------------------------------------|
-- |------------------------------< create_pact >------------------------------|
-- |---------------------------------------------------------------------------|
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
	P_OBJECT_VERSION_NUMBER		out nocopy number)
is
begin
	pay_action_information_api.create_action_information(
		P_VALIDATE			=> P_VALIDATE,
		P_ACTION_CONTEXT_ID		=> p_payroll_action_id,
		P_ACTION_CONTEXT_TYPE		=> 'PA',
		P_ACTION_INFORMATION_CATEGORY	=> 'JP_DEF_PACT',
		P_EFFECTIVE_DATE		=> p_effective_date,
		P_ACTION_INFORMATION1		=> to_canonical(P_PAYROLL_ID),
		P_ACTION_INFORMATION2		=> to_canonical(P_ORGANIZATION_ID),
		P_ACTION_INFORMATION3		=> P_SUBMISSION_PERIOD_STATUS,
		P_ACTION_INFORMATION4		=> to_canonical(P_SUBMISSION_START_DATE),
		P_ACTION_INFORMATION5		=> to_canonical(P_SUBMISSION_END_DATE),
		P_ACTION_INFORMATION6		=> P_TAX_OFFICE_NAME,
		P_ACTION_INFORMATION7		=> P_SALARY_PAYER_NAME,
		P_ACTION_INFORMATION8		=> P_SALARY_PAYER_ADDRESS,
		P_ACTION_INFORMATION_ID		=> p_action_information_id,
		P_OBJECT_VERSION_NUMBER		=> p_object_version_number);
end create_pact;
-- |---------------------------------------------------------------------------|
-- |------------------------------< update_pact >------------------------------|
-- |---------------------------------------------------------------------------|
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
	p_return_status			out nocopy varchar2)
is
	l_rec		pay_jp_def_pact_v%rowtype;
begin
	pay_action_information_swi.update_action_information(
		P_VALIDATE			=> P_VALIDATE,
		P_ACTION_INFORMATION_ID		=> p_action_information_id,
		P_OBJECT_VERSION_NUMBER		=> p_object_version_number,
		P_ACTION_INFORMATION3		=> P_SUBMISSION_PERIOD_STATUS,
		P_ACTION_INFORMATION4		=> to_canonical(P_SUBMISSION_START_DATE),
		P_ACTION_INFORMATION5		=> to_canonical(P_SUBMISSION_END_DATE),
		P_ACTION_INFORMATION6		=> P_TAX_OFFICE_NAME,
		P_ACTION_INFORMATION7		=> P_SALARY_PAYER_NAME,
		P_ACTION_INFORMATION8		=> P_SALARY_PAYER_ADDRESS,
		p_return_status			=> p_return_status);
end update_pact;
-- |---------------------------------------------------------------------------|
-- |-----------------------------< create_assact >-----------------------------|
-- |---------------------------------------------------------------------------|
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
	P_OBJECT_VERSION_NUMBER		out nocopy number)
is
begin
	pay_action_information_api.create_action_information(
		P_VALIDATE			=> P_VALIDATE,
		P_ACTION_CONTEXT_ID		=> p_assignment_action_id,
		P_ACTION_CONTEXT_TYPE		=> 'AAP',
		P_ACTION_INFORMATION_CATEGORY	=> 'JP_DEF_ASSACT',
		P_EFFECTIVE_DATE		=> p_effective_date,
		P_ASSIGNMENT_ID			=> p_assignment_id,
		P_ACTION_INFORMATION1		=> P_TAX_TYPE,
		P_ACTION_INFORMATION2		=> P_TRANSACTION_STATUS,
		P_ACTION_INFORMATION3		=> to_canonical(P_FINALIZED_DATE),
		P_ACTION_INFORMATION4		=> to_canonical(P_FINALIZED_BY),
		P_ACTION_INFORMATION5		=> P_USER_COMMENTS,
		P_ACTION_INFORMATION6		=> P_ADMIN_COMMENTS,
		P_ACTION_INFORMATION7		=> P_TRANSFER_STATUS,
		P_ACTION_INFORMATION8		=> to_canonical(P_EXPIRY_DATE),
		P_ACTION_INFORMATION_ID		=> p_action_information_id,
		P_OBJECT_VERSION_NUMBER		=> p_object_version_number);
end create_assact;
-- |---------------------------------------------------------------------------|
-- |-----------------------------< update_assact >-----------------------------|
-- |---------------------------------------------------------------------------|
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
	P_EXPIRY_DATE			in date		default hr_api.g_date)
is
begin
	pay_action_information_api.update_action_information(
		P_VALIDATE			=> P_VALIDATE,
		P_ACTION_INFORMATION_ID		=> p_action_information_id,
		P_OBJECT_VERSION_NUMBER		=> p_object_version_number,
		P_ACTION_INFORMATION2		=> P_TRANSACTION_STATUS,
		P_ACTION_INFORMATION3		=> to_canonical(P_FINALIZED_DATE),
		P_ACTION_INFORMATION4		=> to_canonical(P_FINALIZED_BY),
		P_ACTION_INFORMATION5		=> P_USER_COMMENTS,
		P_ACTION_INFORMATION6		=> P_ADMIN_COMMENTS,
		P_ACTION_INFORMATION7		=> P_TRANSFER_STATUS,
		P_ACTION_INFORMATION8		=> to_canonical(P_EXPIRY_DATE));
end update_assact;
--
-- When detail entities in composite association is changed,
-- parent entity (assact in this case) is also updated.
-- When trying to save detail entities, parent entity "assact"
-- is updated at first. So "check_submission_period" procedure
-- is implemented for this "Save" case at the moment.
--
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
	p_return_status			out nocopy varchar2)
is
	l_api_updating		boolean;
	l_transaction_status	varchar2(30) := p_transaction_status;
begin
	if l_transaction_status = hr_api.g_varchar2 then
		l_api_updating := pay_aif_shd.api_updating(
					p_action_information_id		=> p_action_information_id,
					p_object_version_number		=> p_object_version_number);
		--
		if not l_api_updating then
			hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
			hr_utility.raise_error;
		else
			l_transaction_status := pay_aif_shd.g_old_rec.action_information2;
		end if;
	end if;
	--
	-- Currently, update operation against assact is not allowed
	-- except for "Save" case.
	--
	if l_transaction_status <> 'N' then
		fnd_message.set_encoded('This operation is not supported at the moment.');
		fnd_message.raise_error;
	else
		pay_jp_def_ss.check_submission_period(p_action_information_id);
	end if;
	--
	pay_action_information_swi.update_action_information(
		P_VALIDATE			=> P_VALIDATE,
		P_ACTION_INFORMATION_ID		=> p_action_information_id,
		P_OBJECT_VERSION_NUMBER		=> p_object_version_number,
		P_ACTION_INFORMATION2		=> P_TRANSACTION_STATUS,
		P_ACTION_INFORMATION3		=> to_canonical(P_FINALIZED_DATE),
		P_ACTION_INFORMATION4		=> to_canonical(P_FINALIZED_BY),
		P_ACTION_INFORMATION5		=> P_USER_COMMENTS,
		P_ACTION_INFORMATION6		=> P_ADMIN_COMMENTS,
		P_ACTION_INFORMATION7		=> P_TRANSFER_STATUS,
		P_ACTION_INFORMATION8		=> to_canonical(P_EXPIRY_DATE),
		p_return_status			=> p_return_status);
end update_assact;
-- |---------------------------------------------------------------------------|
-- |------------------------------< create_emp >-------------------------------|
-- |---------------------------------------------------------------------------|
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
	P_OBJECT_VERSION_NUMBER		out nocopy number)
is
begin
	pay_action_information_api.create_action_information(
		P_VALIDATE			=> P_VALIDATE,
		P_ACTION_CONTEXT_ID		=> p_assignment_action_id,
		P_ACTION_CONTEXT_TYPE		=> 'AAP',
		P_ACTION_INFORMATION_CATEGORY	=> 'JP_DEF_EMP',
		P_EFFECTIVE_DATE		=> p_effective_date,
		P_ASSIGNMENT_ID			=> p_assignment_id,
		P_ACTION_INFORMATION1		=> P_LAST_NAME_KANA,
		P_ACTION_INFORMATION2		=> P_FIRST_NAME_KANA,
		P_ACTION_INFORMATION3		=> P_LAST_NAME,
		P_ACTION_INFORMATION4		=> P_FIRST_NAME,
		P_ACTION_INFORMATION5		=> to_canonical(P_DATE_OF_BIRTH),
		P_ACTION_INFORMATION6		=> to_canonical(P_DATE_OF_DEATH),
		P_ACTION_INFORMATION7		=> P_SEX,
		P_ACTION_INFORMATION8		=> P_POSTAL_CODE,
		P_ACTION_INFORMATION9		=> P_ADDRESS,
		P_ACTION_INFORMATION10		=> to_canonical(P_HOUSEHOLD_HEAD_CTR_ID),
		P_ACTION_INFORMATION11		=> P_HOUSEHOLD_HEAD_FULL_NAME,
		P_ACTION_INFORMATION12		=> P_HOUSEHOLD_HEAD_CONTACT_TYPE,
		P_ACTION_INFORMATION13		=> P_MARRIED_FLAG,
		P_ACTION_INFORMATION14		=> to_canonical(P_CHANGE_DATE),
		P_ACTION_INFORMATION15		=> P_CHANGE_REASON,
		P_ACTION_INFORMATION16		=> P_DISABILITY_TYPE,
		P_ACTION_INFORMATION17		=> P_DISABILITY_DETAILS,
		P_ACTION_INFORMATION18		=> P_AGED_TYPE,
		P_ACTION_INFORMATION19		=> P_AGED_DETAILS,
		P_ACTION_INFORMATION20		=> P_WIDOW_TYPE,
		P_ACTION_INFORMATION21		=> P_WIDOW_DETAILS,
		P_ACTION_INFORMATION22		=> P_WORKING_STUDENT_TYPE,
		P_ACTION_INFORMATION23		=> P_WORKING_STUDENT_DETAILS,
		P_ACTION_INFORMATION_ID		=> p_action_information_id,
		P_OBJECT_VERSION_NUMBER		=> p_object_version_number);
end create_emp;
-- |---------------------------------------------------------------------------|
-- |------------------------------< update_emp >-------------------------------|
-- |---------------------------------------------------------------------------|
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
	p_return_status			out nocopy varchar2)
is
begin
	pay_action_information_swi.update_action_information(
		P_VALIDATE			=> P_VALIDATE,
		P_ACTION_INFORMATION_ID		=> p_action_information_id,
		P_OBJECT_VERSION_NUMBER		=> p_object_version_number,
		P_ACTION_INFORMATION14		=> to_canonical(P_CHANGE_DATE),
		P_ACTION_INFORMATION15		=> P_CHANGE_REASON,
		P_ACTION_INFORMATION16		=> P_DISABILITY_TYPE,
		P_ACTION_INFORMATION17		=> P_DISABILITY_DETAILS,
		P_ACTION_INFORMATION18		=> P_AGED_TYPE,
		P_ACTION_INFORMATION19		=> P_AGED_DETAILS,
		P_ACTION_INFORMATION20		=> P_WIDOW_TYPE,
		P_ACTION_INFORMATION21		=> P_WIDOW_DETAILS,
		P_ACTION_INFORMATION22		=> P_WORKING_STUDENT_TYPE,
		P_ACTION_INFORMATION23		=> P_WORKING_STUDENT_DETAILS,
		p_return_status			=> p_return_status);
end update_emp;
-- |---------------------------------------------------------------------------|
-- |-----------------------------< create_entry >------------------------------|
-- |---------------------------------------------------------------------------|
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
	P_OBJECT_VERSION_NUMBER		out nocopy number)
is
begin
	pay_action_information_api.create_action_information(
		P_VALIDATE			=> P_VALIDATE,
		P_ACTION_CONTEXT_ID		=> p_assignment_action_id,
		P_ACTION_CONTEXT_TYPE		=> 'AAP',
		P_ACTION_INFORMATION_CATEGORY	=> 'JP_DEF_ENTRY',
		P_EFFECTIVE_DATE		=> p_effective_date,
		P_ASSIGNMENT_ID			=> p_assignment_id,
		P_ACTION_INFORMATION1		=> P_STATUS,
		P_ACTION_INFORMATION2		=> P_DATETRACK_UPDATE_MODE,
		P_ACTION_INFORMATION3		=> to_canonical(P_ELEMENT_ENTRY_ID),
		P_ACTION_INFORMATION4		=> to_canonical(P_EE_OBJECT_VERSION_NUMBER),
		P_ACTION_INFORMATION5		=> P_DISABILITY_TYPE,
		P_ACTION_INFORMATION6		=> P_DISABILITY_TYPE_O,
		P_ACTION_INFORMATION7		=> P_AGED_TYPE,
		P_ACTION_INFORMATION8		=> P_AGED_TYPE_O,
		P_ACTION_INFORMATION9		=> P_WIDOW_TYPE,
		P_ACTION_INFORMATION10		=> P_WIDOW_TYPE_O,
		P_ACTION_INFORMATION11		=> P_WORKING_STUDENT_TYPE,
		P_ACTION_INFORMATION12		=> P_WORKING_STUDENT_TYPE_O,
		P_ACTION_INFORMATION13		=> P_SPOUSE_DEP_TYPE,
		P_ACTION_INFORMATION14		=> P_SPOUSE_DEP_TYPE_O,
		P_ACTION_INFORMATION15		=> P_SPOUSE_DISABILITY_TYPE,
		P_ACTION_INFORMATION16		=> P_SPOUSE_DISABILITY_TYPE_O,
		P_ACTION_INFORMATION17		=> to_canonical(P_NUM_DEPS),
		P_ACTION_INFORMATION18		=> to_canonical(P_NUM_DEPS_O),
		P_ACTION_INFORMATION19		=> to_canonical(P_NUM_AGEDS),
		P_ACTION_INFORMATION20		=> to_canonical(P_NUM_AGEDS_O),
		P_ACTION_INFORMATION21		=> to_canonical(P_NUM_AGED_PARENTS_LT),
		P_ACTION_INFORMATION22		=> to_canonical(P_NUM_AGED_PARENTS_LT_O),
		P_ACTION_INFORMATION23		=> to_canonical(P_NUM_SPECIFIEDS),
		P_ACTION_INFORMATION24		=> to_canonical(P_NUM_SPECIFIEDS_O),
		P_ACTION_INFORMATION25		=> to_canonical(P_NUM_DISABLEDS),
		P_ACTION_INFORMATION26		=> to_canonical(P_NUM_DISABLEDS_O),
		P_ACTION_INFORMATION27		=> to_canonical(P_NUM_SVR_DISABLEDS),
		P_ACTION_INFORMATION28		=> to_canonical(P_NUM_SVR_DISABLEDS_O),
		P_ACTION_INFORMATION29		=> to_canonical(P_NUM_SVR_DISABLEDS_LT),
		P_ACTION_INFORMATION30		=> to_canonical(P_NUM_SVR_DISABLEDS_LT_O),
		P_ACTION_INFORMATION_ID		=> p_action_information_id,
		P_OBJECT_VERSION_NUMBER		=> p_object_version_number);
end create_entry;
-- |---------------------------------------------------------------------------|
-- |-----------------------------< update_entry >------------------------------|
-- |---------------------------------------------------------------------------|
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
	P_NUM_SVR_DISABLEDS_LT		in number	default hr_api.g_number)
is
begin
	pay_action_information_api.update_action_information(
		P_VALIDATE			=> P_VALIDATE,
		P_ACTION_INFORMATION_ID		=> p_action_information_id,
		P_OBJECT_VERSION_NUMBER		=> p_object_version_number,
		P_ACTION_INFORMATION1		=> P_STATUS,
		P_ACTION_INFORMATION3		=> to_canonical(P_ELEMENT_ENTRY_ID),
		P_ACTION_INFORMATION4		=> to_canonical(P_EE_OBJECT_VERSION_NUMBER),
		P_ACTION_INFORMATION5		=> P_DISABILITY_TYPE,
		P_ACTION_INFORMATION7		=> P_AGED_TYPE,
		P_ACTION_INFORMATION9		=> P_WIDOW_TYPE,
		P_ACTION_INFORMATION11		=> P_WORKING_STUDENT_TYPE,
		P_ACTION_INFORMATION13		=> P_SPOUSE_DEP_TYPE,
		P_ACTION_INFORMATION15		=> P_SPOUSE_DISABILITY_TYPE,
		P_ACTION_INFORMATION17		=> to_canonical(P_NUM_DEPS),
		P_ACTION_INFORMATION19		=> to_canonical(P_NUM_AGEDS),
		P_ACTION_INFORMATION21		=> to_canonical(P_NUM_AGED_PARENTS_LT),
		P_ACTION_INFORMATION23		=> to_canonical(P_NUM_SPECIFIEDS),
		P_ACTION_INFORMATION25		=> to_canonical(P_NUM_DISABLEDS),
		P_ACTION_INFORMATION27		=> to_canonical(P_NUM_SVR_DISABLEDS),
		P_ACTION_INFORMATION29		=> to_canonical(P_NUM_SVR_DISABLEDS_LT));
end update_entry;
-- |---------------------------------------------------------------------------|
-- |------------------------------< create_dep >-------------------------------|
-- |---------------------------------------------------------------------------|
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
	P_OBJECT_VERSION_NUMBER		out nocopy number)
is
begin
	pay_action_information_api.create_action_information(
		P_VALIDATE			=> P_VALIDATE,
		P_ACTION_CONTEXT_ID		=> p_assignment_action_id,
		P_ACTION_CONTEXT_TYPE		=> 'AAP',
		P_ACTION_INFORMATION_CATEGORY	=> 'JP_DEF_DEP',
		P_EFFECTIVE_DATE		=> p_effective_date,
		P_ASSIGNMENT_ID			=> p_assignment_id,
		P_ACTION_INFORMATION1		=> P_STATUS,
		P_ACTION_INFORMATION2		=> P_DATETRACK_UPDATE_MODE,
		P_ACTION_INFORMATION3		=> P_DATETRACK_DELETE_MODE,
		P_ACTION_INFORMATION4		=> to_canonical(P_CONTACT_EXTRA_INFO_ID),
		P_ACTION_INFORMATION5		=> to_canonical(P_CEI_OBJECT_VERSION_NUMBER),
		P_ACTION_INFORMATION6		=> to_canonical(P_CONTACT_RELATIONSHIP_ID),
		P_ACTION_INFORMATION7		=> P_LAST_NAME_KANA,
		P_ACTION_INFORMATION8		=> P_FIRST_NAME_KANA,
		P_ACTION_INFORMATION9		=> P_LAST_NAME,
		P_ACTION_INFORMATION10		=> P_FIRST_NAME,
		P_ACTION_INFORMATION11		=> P_CONTACT_TYPE,
		P_ACTION_INFORMATION12		=> to_canonical(P_DATE_OF_BIRTH),
		P_ACTION_INFORMATION13		=> to_canonical(P_DATE_OF_DEATH),
		P_ACTION_INFORMATION14		=> P_ADDRESS,
		P_ACTION_INFORMATION15		=> to_canonical(P_CHANGE_DATE),
		P_ACTION_INFORMATION16		=> P_CHANGE_REASON,
		P_ACTION_INFORMATION17		=> P_DEP_TYPE,
		P_ACTION_INFORMATION18		=> P_DEP_TYPE_O,
		P_ACTION_INFORMATION19		=> P_OCCUPATION,
		P_ACTION_INFORMATION20		=> P_OCCUPATION_O,
		P_ACTION_INFORMATION21		=> to_canonical(P_ESTIMATED_ANNUAL_INCOME),
		P_ACTION_INFORMATION22		=> to_canonical(P_ESTIMATED_ANNUAL_INCOME_O),
		P_ACTION_INFORMATION23		=> P_DISABILITY_TYPE,
		P_ACTION_INFORMATION24		=> P_DISABILITY_TYPE_O,
		P_ACTION_INFORMATION25		=> P_DISABILITY_DETAILS,
		P_ACTION_INFORMATION26		=> P_DISABILITY_DETAILS_O,
		P_ACTION_INFORMATION_ID		=> p_action_information_id,
		P_OBJECT_VERSION_NUMBER		=> p_object_version_number);
end create_dep;
--
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
	p_return_status			out nocopy varchar2)
is
begin
	pay_action_information_swi.create_action_information(
		P_VALIDATE			=> P_VALIDATE,
		P_ACTION_INFORMATION_ID		=> p_action_information_id,
		P_ACTION_CONTEXT_ID		=> p_assignment_action_id,
		P_ACTION_CONTEXT_TYPE		=> 'AAP',
		P_ACTION_INFORMATION_CATEGORY	=> 'JP_DEF_DEP',
		P_EFFECTIVE_DATE		=> p_effective_date,
		P_ASSIGNMENT_ID			=> p_assignment_id,
		P_ACTION_INFORMATION1		=> P_STATUS,
		P_ACTION_INFORMATION2		=> P_DATETRACK_UPDATE_MODE,
		P_ACTION_INFORMATION3		=> P_DATETRACK_DELETE_MODE,
		P_ACTION_INFORMATION4		=> to_canonical(P_CONTACT_EXTRA_INFO_ID),
		P_ACTION_INFORMATION5		=> to_canonical(P_CEI_OBJECT_VERSION_NUMBER),
		P_ACTION_INFORMATION6		=> to_canonical(P_CONTACT_RELATIONSHIP_ID),
		P_ACTION_INFORMATION7		=> P_LAST_NAME_KANA,
		P_ACTION_INFORMATION8		=> P_FIRST_NAME_KANA,
		P_ACTION_INFORMATION9		=> P_LAST_NAME,
		P_ACTION_INFORMATION10		=> P_FIRST_NAME,
		P_ACTION_INFORMATION11		=> P_CONTACT_TYPE,
		P_ACTION_INFORMATION12		=> to_canonical(P_DATE_OF_BIRTH),
		P_ACTION_INFORMATION13		=> to_canonical(P_DATE_OF_DEATH),
		P_ACTION_INFORMATION14		=> P_ADDRESS,
		P_ACTION_INFORMATION15		=> to_canonical(P_CHANGE_DATE),
		P_ACTION_INFORMATION16		=> P_CHANGE_REASON,
		P_ACTION_INFORMATION17		=> P_DEP_TYPE,
		P_ACTION_INFORMATION18		=> P_DEP_TYPE_O,
		P_ACTION_INFORMATION19		=> P_OCCUPATION,
		P_ACTION_INFORMATION20		=> P_OCCUPATION_O,
		P_ACTION_INFORMATION21		=> to_canonical(P_ESTIMATED_ANNUAL_INCOME),
		P_ACTION_INFORMATION22		=> to_canonical(P_ESTIMATED_ANNUAL_INCOME_O),
		P_ACTION_INFORMATION23		=> P_DISABILITY_TYPE,
		P_ACTION_INFORMATION24		=> P_DISABILITY_TYPE_O,
		P_ACTION_INFORMATION25		=> P_DISABILITY_DETAILS,
		P_ACTION_INFORMATION26		=> P_DISABILITY_DETAILS_O,
		P_OBJECT_VERSION_NUMBER		=> p_object_version_number,
		p_return_status			=> p_return_status);
end create_dep;
-- |---------------------------------------------------------------------------|
-- |------------------------------< update_dep >-------------------------------|
-- |---------------------------------------------------------------------------|
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
	P_DISABILITY_DETAILS		in varchar2	default hr_api.g_varchar2)
is
begin
	pay_action_information_api.update_action_information(
		P_VALIDATE			=> P_VALIDATE,
		P_ACTION_INFORMATION_ID		=> p_action_information_id,
		P_OBJECT_VERSION_NUMBER		=> p_object_version_number,
		P_ACTION_INFORMATION1		=> P_STATUS,
		P_ACTION_INFORMATION4		=> to_canonical(P_CONTACT_EXTRA_INFO_ID),
		P_ACTION_INFORMATION5		=> to_canonical(P_CEI_OBJECT_VERSION_NUMBER),
		P_ACTION_INFORMATION15		=> to_canonical(P_CHANGE_DATE),
		P_ACTION_INFORMATION16		=> P_CHANGE_REASON,
		P_ACTION_INFORMATION17		=> P_DEP_TYPE,
		P_ACTION_INFORMATION19		=> P_OCCUPATION,
		P_ACTION_INFORMATION21		=> to_canonical(P_ESTIMATED_ANNUAL_INCOME),
		P_ACTION_INFORMATION23		=> P_DISABILITY_TYPE,
		P_ACTION_INFORMATION25		=> P_DISABILITY_DETAILS);
end update_dep;
--
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
	p_return_status			out nocopy varchar2)
is
begin
	pay_action_information_swi.update_action_information(
		P_VALIDATE			=> P_VALIDATE,
		P_ACTION_INFORMATION_ID		=> p_action_information_id,
		P_OBJECT_VERSION_NUMBER		=> p_object_version_number,
		P_ACTION_INFORMATION1		=> P_STATUS,
		P_ACTION_INFORMATION4		=> to_canonical(P_CONTACT_EXTRA_INFO_ID),
		P_ACTION_INFORMATION5		=> to_canonical(P_CEI_OBJECT_VERSION_NUMBER),
		P_ACTION_INFORMATION15		=> to_canonical(P_CHANGE_DATE),
		P_ACTION_INFORMATION16		=> P_CHANGE_REASON,
		P_ACTION_INFORMATION17		=> P_DEP_TYPE,
		P_ACTION_INFORMATION19		=> P_OCCUPATION,
		P_ACTION_INFORMATION21		=> to_canonical(P_ESTIMATED_ANNUAL_INCOME),
		P_ACTION_INFORMATION23		=> P_DISABILITY_TYPE,
		P_ACTION_INFORMATION25		=> P_DISABILITY_DETAILS,
		p_return_status			=> p_return_status);
end update_dep;
-- |---------------------------------------------------------------------------|
-- |-----------------------------< create_dep_oe >-----------------------------|
-- |---------------------------------------------------------------------------|
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
	P_OBJECT_VERSION_NUMBER		out nocopy number)
is
begin
	pay_action_information_api.create_action_information(
		P_VALIDATE			=> P_VALIDATE,
		P_ACTION_CONTEXT_ID		=> p_assignment_action_id,
		P_ACTION_CONTEXT_TYPE		=> 'AAP',
		P_ACTION_INFORMATION_CATEGORY	=> 'JP_DEF_DEP_OE',
		P_EFFECTIVE_DATE		=> p_effective_date,
		P_ASSIGNMENT_ID			=> p_assignment_id,
		P_ACTION_INFORMATION1		=> P_STATUS,
		P_ACTION_INFORMATION2		=> P_DATETRACK_UPDATE_MODE,
		P_ACTION_INFORMATION3		=> P_DATETRACK_DELETE_MODE,
		P_ACTION_INFORMATION4		=> to_canonical(P_CONTACT_EXTRA_INFO_ID),
		P_ACTION_INFORMATION5		=> to_canonical(P_CEI_OBJECT_VERSION_NUMBER),
		P_ACTION_INFORMATION6		=> to_canonical(P_CONTACT_RELATIONSHIP_ID),
		P_ACTION_INFORMATION7		=> P_LAST_NAME_KANA,
		P_ACTION_INFORMATION8		=> P_FIRST_NAME_KANA,
		P_ACTION_INFORMATION9		=> P_LAST_NAME,
		P_ACTION_INFORMATION10		=> P_FIRST_NAME,
		P_ACTION_INFORMATION11		=> P_CONTACT_TYPE,
		P_ACTION_INFORMATION12		=> to_canonical(P_DATE_OF_BIRTH),
		P_ACTION_INFORMATION13		=> to_canonical(P_DATE_OF_DEATH),
		P_ACTION_INFORMATION14		=> P_ADDRESS,
		P_ACTION_INFORMATION15		=> to_canonical(P_CHANGE_DATE),
		P_ACTION_INFORMATION16		=> P_CHANGE_REASON,
		P_ACTION_INFORMATION17		=> P_OCCUPATION,
		P_ACTION_INFORMATION18		=> P_OCCUPATION_O,
		P_ACTION_INFORMATION19		=> to_canonical(P_OE_CONTACT_RELATIONSHIP_ID),
		P_ACTION_INFORMATION20		=> P_OE_FULL_NAME,
		P_ACTION_INFORMATION21		=> P_OE_CONTACT_TYPE,
		P_ACTION_INFORMATION22		=> P_OE_ADDRESS,
		P_ACTION_INFORMATION23		=> to_canonical(P_OE_CONTACT_RELATIONSHIP_ID_O),
		P_ACTION_INFORMATION_ID		=> p_action_information_id,
		P_OBJECT_VERSION_NUMBER		=> p_object_version_number);
end create_dep_oe;
--
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
	p_return_status			out nocopy varchar2)
is
begin
	pay_action_information_swi.create_action_information(
		P_VALIDATE			=> P_VALIDATE,
		P_ACTION_INFORMATION_ID		=> p_action_information_id,
		P_ACTION_CONTEXT_ID		=> p_assignment_action_id,
		P_ACTION_CONTEXT_TYPE		=> 'AAP',
		P_ACTION_INFORMATION_CATEGORY	=> 'JP_DEF_DEP_OE',
		P_EFFECTIVE_DATE		=> p_effective_date,
		P_ASSIGNMENT_ID			=> p_assignment_id,
		P_ACTION_INFORMATION1		=> P_STATUS,
		P_ACTION_INFORMATION2		=> P_DATETRACK_UPDATE_MODE,
		P_ACTION_INFORMATION3		=> P_DATETRACK_DELETE_MODE,
		P_ACTION_INFORMATION4		=> to_canonical(P_CONTACT_EXTRA_INFO_ID),
		P_ACTION_INFORMATION5		=> to_canonical(P_CEI_OBJECT_VERSION_NUMBER),
		P_ACTION_INFORMATION6		=> to_canonical(P_CONTACT_RELATIONSHIP_ID),
		P_ACTION_INFORMATION7		=> P_LAST_NAME_KANA,
		P_ACTION_INFORMATION8		=> P_FIRST_NAME_KANA,
		P_ACTION_INFORMATION9		=> P_LAST_NAME,
		P_ACTION_INFORMATION10		=> P_FIRST_NAME,
		P_ACTION_INFORMATION11		=> P_CONTACT_TYPE,
		P_ACTION_INFORMATION12		=> to_canonical(P_DATE_OF_BIRTH),
		P_ACTION_INFORMATION13		=> to_canonical(P_DATE_OF_DEATH),
		P_ACTION_INFORMATION14		=> P_ADDRESS,
		P_ACTION_INFORMATION15		=> to_canonical(P_CHANGE_DATE),
		P_ACTION_INFORMATION16		=> P_CHANGE_REASON,
		P_ACTION_INFORMATION17		=> P_OCCUPATION,
		P_ACTION_INFORMATION18		=> P_OCCUPATION_O,
		P_ACTION_INFORMATION19		=> to_canonical(P_OE_CONTACT_RELATIONSHIP_ID),
		P_ACTION_INFORMATION20		=> P_OE_FULL_NAME,
		P_ACTION_INFORMATION21		=> P_OE_CONTACT_TYPE,
		P_ACTION_INFORMATION22		=> P_OE_ADDRESS,
		P_ACTION_INFORMATION23		=> to_canonical(P_OE_CONTACT_RELATIONSHIP_ID_O),
		P_OBJECT_VERSION_NUMBER		=> p_object_version_number,
		p_return_status			=> p_return_status);
end create_dep_oe;
-- |---------------------------------------------------------------------------|
-- |-----------------------------< update_dep_oe >-----------------------------|
-- |---------------------------------------------------------------------------|
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
	P_OE_ADDRESS			in varchar2	default hr_api.g_varchar2)
is
begin
	pay_action_information_api.update_action_information(
		P_VALIDATE			=> P_VALIDATE,
		P_ACTION_INFORMATION_ID		=> p_action_information_id,
		P_OBJECT_VERSION_NUMBER		=> p_object_version_number,
		P_ACTION_INFORMATION1		=> P_STATUS,
		P_ACTION_INFORMATION4		=> to_canonical(P_CONTACT_EXTRA_INFO_ID),
		P_ACTION_INFORMATION5		=> to_canonical(P_CEI_OBJECT_VERSION_NUMBER),
		P_ACTION_INFORMATION15		=> to_canonical(P_CHANGE_DATE),
		P_ACTION_INFORMATION16		=> P_CHANGE_REASON,
		P_ACTION_INFORMATION17		=> P_OCCUPATION,
		P_ACTION_INFORMATION19		=> to_canonical(P_OE_CONTACT_RELATIONSHIP_ID),
		P_ACTION_INFORMATION20		=> P_OE_FULL_NAME,
		P_ACTION_INFORMATION21		=> P_OE_CONTACT_TYPE,
		P_ACTION_INFORMATION22		=> P_OE_ADDRESS);
end update_dep_oe;
--
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
	p_return_status			out nocopy varchar2)
is
begin
	pay_action_information_swi.update_action_information(
		P_VALIDATE			=> P_VALIDATE,
		P_ACTION_INFORMATION_ID		=> p_action_information_id,
		P_OBJECT_VERSION_NUMBER		=> p_object_version_number,
		P_ACTION_INFORMATION1		=> P_STATUS,
		P_ACTION_INFORMATION4		=> to_canonical(P_CONTACT_EXTRA_INFO_ID),
		P_ACTION_INFORMATION5		=> to_canonical(P_CEI_OBJECT_VERSION_NUMBER),
		P_ACTION_INFORMATION15		=> to_canonical(P_CHANGE_DATE),
		P_ACTION_INFORMATION16		=> P_CHANGE_REASON,
		P_ACTION_INFORMATION17		=> P_OCCUPATION,
		P_ACTION_INFORMATION19		=> to_canonical(P_OE_CONTACT_RELATIONSHIP_ID),
		P_ACTION_INFORMATION20		=> P_OE_FULL_NAME,
		P_ACTION_INFORMATION21		=> P_OE_CONTACT_TYPE,
		P_ACTION_INFORMATION22		=> P_OE_ADDRESS,
		p_return_status			=> p_return_status);
end update_dep_oe;
-- |---------------------------------------------------------------------------|
-- |-----------------------------< create_dep_os >-----------------------------|
-- |---------------------------------------------------------------------------|
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
	P_OBJECT_VERSION_NUMBER		out nocopy number)
is
begin
	pay_action_information_api.create_action_information(
		P_VALIDATE			=> P_VALIDATE,
		P_ACTION_CONTEXT_ID		=> p_assignment_action_id,
		P_ACTION_CONTEXT_TYPE		=> 'AAP',
		P_ACTION_INFORMATION_CATEGORY	=> 'JP_DEF_DEP_OS',
		P_EFFECTIVE_DATE		=> p_effective_date,
		P_ASSIGNMENT_ID			=> p_assignment_id,
		P_ACTION_INFORMATION1		=> P_STATUS,
		P_ACTION_INFORMATION2		=> P_DATETRACK_UPDATE_MODE,
		P_ACTION_INFORMATION3		=> P_DATETRACK_DELETE_MODE,
		P_ACTION_INFORMATION4		=> to_canonical(P_CONTACT_EXTRA_INFO_ID),
		P_ACTION_INFORMATION5		=> to_canonical(P_CEI_OBJECT_VERSION_NUMBER),
		P_ACTION_INFORMATION6		=> to_canonical(P_CONTACT_RELATIONSHIP_ID),
		P_ACTION_INFORMATION7		=> P_LAST_NAME_KANA,
		P_ACTION_INFORMATION8		=> P_FIRST_NAME_KANA,
		P_ACTION_INFORMATION9		=> P_LAST_NAME,
		P_ACTION_INFORMATION10		=> P_FIRST_NAME,
		P_ACTION_INFORMATION11		=> P_CONTACT_TYPE,
		P_ACTION_INFORMATION12		=> to_canonical(P_DATE_OF_BIRTH),
		P_ACTION_INFORMATION13		=> to_canonical(P_DATE_OF_DEATH),
		P_ACTION_INFORMATION14		=> P_OCCUPATION,
		P_ACTION_INFORMATION15		=> P_OCCUPATION_O,
		P_ACTION_INFORMATION16		=> P_OS_SALARY_PAYER_NAME,
		P_ACTION_INFORMATION17		=> P_OS_SALARY_PAYER_NAME_O,
		P_ACTION_INFORMATION18		=> P_OS_SALARY_PAYER_ADDRESS,
		P_ACTION_INFORMATION19		=> P_OS_SALARY_PAYER_ADDRESS_O,
		P_ACTION_INFORMATION_ID		=> p_action_information_id,
		P_OBJECT_VERSION_NUMBER		=> p_object_version_number);
end create_dep_os;
--
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
	p_return_status			out nocopy varchar2)
is
begin
	pay_action_information_swi.create_action_information(
		P_VALIDATE			=> P_VALIDATE,
		P_ACTION_INFORMATION_ID		=> p_action_information_id,
		P_ACTION_CONTEXT_ID		=> p_assignment_action_id,
		P_ACTION_CONTEXT_TYPE		=> 'AAP',
		P_ACTION_INFORMATION_CATEGORY	=> 'JP_DEF_DEP_OS',
		P_EFFECTIVE_DATE		=> p_effective_date,
		P_ASSIGNMENT_ID			=> p_assignment_id,
		P_ACTION_INFORMATION1		=> P_STATUS,
		P_ACTION_INFORMATION2		=> P_DATETRACK_UPDATE_MODE,
		P_ACTION_INFORMATION3		=> P_DATETRACK_DELETE_MODE,
		P_ACTION_INFORMATION4		=> to_canonical(P_CONTACT_EXTRA_INFO_ID),
		P_ACTION_INFORMATION5		=> to_canonical(P_CEI_OBJECT_VERSION_NUMBER),
		P_ACTION_INFORMATION6		=> to_canonical(P_CONTACT_RELATIONSHIP_ID),
		P_ACTION_INFORMATION7		=> P_LAST_NAME_KANA,
		P_ACTION_INFORMATION8		=> P_FIRST_NAME_KANA,
		P_ACTION_INFORMATION9		=> P_LAST_NAME,
		P_ACTION_INFORMATION10		=> P_FIRST_NAME,
		P_ACTION_INFORMATION11		=> P_CONTACT_TYPE,
		P_ACTION_INFORMATION12		=> to_canonical(P_DATE_OF_BIRTH),
		P_ACTION_INFORMATION13		=> to_canonical(P_DATE_OF_DEATH),
		P_ACTION_INFORMATION14		=> P_OCCUPATION,
		P_ACTION_INFORMATION15		=> P_OCCUPATION_O,
		P_ACTION_INFORMATION16		=> P_OS_SALARY_PAYER_NAME,
		P_ACTION_INFORMATION17		=> P_OS_SALARY_PAYER_NAME_O,
		P_ACTION_INFORMATION18		=> P_OS_SALARY_PAYER_ADDRESS,
		P_ACTION_INFORMATION19		=> P_OS_SALARY_PAYER_ADDRESS_O,
		P_OBJECT_VERSION_NUMBER		=> p_object_version_number,
		p_return_status			=> p_return_status);
end create_dep_os;
-- |---------------------------------------------------------------------------|
-- |-----------------------------< update_dep_os >-----------------------------|
-- |---------------------------------------------------------------------------|
procedure update_dep_os(
	P_VALIDATE			in boolean	default false,
	P_ACTION_INFORMATION_ID		in number,
	P_OBJECT_VERSION_NUMBER		in out nocopy number,
	P_STATUS			in varchar2	default hr_api.g_varchar2,
	P_CONTACT_EXTRA_INFO_ID		in number	default hr_api.g_number,
	P_CEI_OBJECT_VERSION_NUMBER	in number	default hr_api.g_number,
	P_OCCUPATION			in varchar2	default hr_api.g_varchar2,
	P_OS_SALARY_PAYER_NAME		in varchar2	default hr_api.g_varchar2,
	P_OS_SALARY_PAYER_ADDRESS	in varchar2	default hr_api.g_varchar2)
is
begin
	pay_action_information_api.update_action_information(
		P_VALIDATE			=> P_VALIDATE,
		P_ACTION_INFORMATION_ID		=> p_action_information_id,
		P_OBJECT_VERSION_NUMBER		=> p_object_version_number,
		P_ACTION_INFORMATION1		=> P_STATUS,
		P_ACTION_INFORMATION4		=> to_canonical(P_CONTACT_EXTRA_INFO_ID),
		P_ACTION_INFORMATION5		=> to_canonical(P_CEI_OBJECT_VERSION_NUMBER),
		P_ACTION_INFORMATION14		=> P_OCCUPATION,
		P_ACTION_INFORMATION16		=> P_OS_SALARY_PAYER_NAME,
		P_ACTION_INFORMATION18		=> P_OS_SALARY_PAYER_ADDRESS);
end update_dep_os;
--
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
	p_return_status			out nocopy varchar2)
is
begin
	pay_action_information_swi.update_action_information(
		P_VALIDATE			=> P_VALIDATE,
		P_ACTION_INFORMATION_ID		=> p_action_information_id,
		P_OBJECT_VERSION_NUMBER		=> p_object_version_number,
		P_ACTION_INFORMATION1		=> P_STATUS,
		P_ACTION_INFORMATION4		=> to_canonical(P_CONTACT_EXTRA_INFO_ID),
		P_ACTION_INFORMATION5		=> to_canonical(P_CEI_OBJECT_VERSION_NUMBER),
		P_ACTION_INFORMATION14		=> P_OCCUPATION,
		P_ACTION_INFORMATION16		=> P_OS_SALARY_PAYER_NAME,
		P_ACTION_INFORMATION18		=> P_OS_SALARY_PAYER_ADDRESS,
		p_return_status			=> p_return_status);
end update_dep_os;
--
end pay_jp_def_api;

/
