--------------------------------------------------------
--  DDL for Package Body PAY_JP_ITAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_ITAX_PKG" as
/* $Header: pyjpitax.pkb 120.1 2006/05/30 09:12:07 sgottipa noship $ */
c_action_info_category_person	CONSTANT pay_action_information.action_information_category%type := 'JP_ITAX_PERSON';
c_action_info_category_arch	CONSTANT pay_action_information.action_information_category%type := 'JP_ITAX_ARCH';
c_action_info_category_tax	CONSTANT pay_action_information.action_information_category%type := 'JP_ITAX_TAX';
c_action_info_category_other	CONSTANT pay_action_information.action_information_category%type := 'JP_ITAX_OTHER';
c_action_info_category_other2	CONSTANT pay_action_information.action_information_category%type := 'JP_ITAX_OTHER2';
c_action_context_type		CONSTANT pay_action_information.action_context_type%type := 'AAP';
c_first_object_version_number	CONSTANT pay_action_information.object_version_number%type := 1;
c_enabled			CONSTANT VARCHAR2(80) := 'Enabled';
c_disabled			CONSTANT VARCHAR2(80) := 'Disabled';

FUNCTION NEXT_ACTION_INFORMATION_ID
RETURN number
IS
l_action_information_id	number;
BEGIN
	SELECT	pay_action_information_s.nextval
	INTO	l_action_information_id
	FROM	dual;

	RETURN l_action_information_id;
END NEXT_ACTION_INFORMATION_ID;

PROCEDURE CREATE_PERSON(
	p_assignment_action_id		in number,
	p_effective_date		in date,
	p_assignment_id			in number,
	p_value				in value_rec
)
IS
l_action_information_id			number;
BEGIN
	l_action_information_id := NEXT_ACTION_INFORMATION_ID;

	INSERT INTO PAY_JP_ITAX_PERSON_V
	(
		ACTION_INFORMATION_ID,
		ACTION_CONTEXT_ID,
		ACTION_CONTEXT_TYPE,
		EFFECTIVE_DATE,
		ASSIGNMENT_ID,
		OBJECT_VERSION_NUMBER,
		ACTION_INFORMATION_CATEGORY,
		EMPLOYEE_NUMBER,
		LAST_NAME_KANA,
		FIRST_NAME_KANA,
		LAST_NAME_KANJI,
		FIRST_NAME_KANJI,
		SEX,
		ADDRESS_ID,
		ADDRESS_KANA,
		ADDRESS_KANJI,
		COUNTRY,
		JP_DATE_START,
		LEAVING_REASON,
		DATE_OF_BIRTH,
		DATE_OF_BIRTH_MEIJI,
		DATE_OF_BIRTH_TAISHOU,
		DATE_OF_BIRTH_SHOUWA,
		DATE_OF_BIRTH_HEISEI,
		DATE_OF_BIRTH_YEAR,
		DATE_OF_BIRTH_MONTH,
		DATE_OF_BIRTH_DAY,
		EMPLOYMENT_DATE_YEAR,
		EMPLOYMENT_DATE_MONTH,
		EMPLOYMENT_DATE_DAY,
		ITAX_ORGANIZATION_ID,
		ACTUAL_TERMINATION_DATE,
		ORG_NAME,
		PAYROLL_NAME,
		DISTRICT_CODE,
		OPEN_DATE,
		CLOSE_DATE
	)
	VALUES
	(
		l_action_information_id,
		p_assignment_action_id,
		c_action_context_type,
		p_effective_date,
		p_assignment_id,
		c_first_object_version_number,
		c_action_info_category_person,
		p_value.p_action_information1,
		p_value.p_action_information2,
		p_value.p_action_information3,
		p_value.p_action_information4,
		p_value.p_action_information5,
		p_value.p_action_information6,
		p_value.p_action_information7,
		p_value.p_action_information8,
		p_value.p_action_information9,
		p_value.p_action_information10,
		p_value.p_action_information11,
		p_value.p_action_information12,
		p_value.p_action_information13,
		p_value.p_action_information14,
		p_value.p_action_information15,
		p_value.p_action_information16,
		p_value.p_action_information17,
		p_value.p_action_information18,
		p_value.p_action_information19,
		p_value.p_action_information20,
		p_value.p_action_information21,
		p_value.p_action_information22,
		p_value.p_action_information23,
		p_value.p_action_information24,
		p_value.p_action_information25,
		p_value.p_action_information26,
		p_value.p_action_information27,
		p_value.p_action_information28,
		p_value.p_action_information29,
		p_value.p_action_information30
	);
END CREATE_PERSON;

PROCEDURE CREATE_ARCH(
	p_assignment_action_id		in number,
	p_effective_date		in date,
	p_assignment_id			in number,
	p_value				in value_rec
)
IS
l_action_information_id			number;
BEGIN
	l_action_information_id := NEXT_ACTION_INFORMATION_ID;

	INSERT INTO PAY_JP_ITAX_ARCH_V
	(
		ACTION_INFORMATION_ID,
		ACTION_CONTEXT_ID,
		ACTION_CONTEXT_TYPE,
		EFFECTIVE_DATE,
		ASSIGNMENT_ID,
		OBJECT_VERSION_NUMBER,
		ACTION_INFORMATION_CATEGORY,
		PERSON_ID,
		ASSIGNMENT_ACTION_ID,
		PAYROLL_ID,
		REFERENCE_NUMBER,
		REFERENCE_NUMBER1,
		REFERENCE_NUMBER2,
		ACTION_SEQUENCE,
		EMPLOYER_ADDRESS,
		EMPLOYER_NAME,
		EMPLOYER_TELEPHONE_NUMBER,
		TAX_OFFICE_NUMBER,
		DATE_EARNED,
		EMPLOYMENT_CATEGORY,
		ITAX_CATEGORY,
		ITAX_YEA_CATEGORY,
		DESCRIPTION1,
		DESCRIPTION2,
		DESCRIPTION3,
		DESCRIPTION4,
		DESCRIPTION5,
		FILE_DESCRIPTION1,
		FILE_DESCRIPTION2,
		FILE_DESCRIPTION3,
		FILE_DESCRIPTION4,
		FILE_DESCRIPTION5,
		DESCRIPTION_KANJI,
		DESCRIPTION_KANA,
		FOR_FILE_DESCRIPTION_KANJI,
		FOR_FILE_DESCRIPTION_KANA,
		SUBMISSION_REQUIRED_FLAG
	)
	VALUES
	(
		l_action_information_id,
		p_assignment_action_id,
		c_action_context_type,
		p_effective_date,
		p_assignment_id,
		c_first_object_version_number,
		c_action_info_category_arch,
		p_value.p_action_information1,
		p_value.p_action_information2,
		p_value.p_action_information3,
		p_value.p_action_information4,
		p_value.p_action_information5,
		p_value.p_action_information6,
		p_value.p_action_information7,
		p_value.p_action_information8,
		p_value.p_action_information9,
		p_value.p_action_information10,
		p_value.p_action_information11,
		p_value.p_action_information12,
		p_value.p_action_information13,
		p_value.p_action_information14,
		p_value.p_action_information15,
		p_value.p_action_information16,
		p_value.p_action_information17,
		p_value.p_action_information18,
		p_value.p_action_information19,
		p_value.p_action_information20,
		p_value.p_action_information21,
		p_value.p_action_information22,
		p_value.p_action_information23,
		p_value.p_action_information24,
		p_value.p_action_information25,
		p_value.p_action_information26,
		p_value.p_action_information27,
		p_value.p_action_information28,
		p_value.p_action_information29,
		p_value.p_action_information30
	);
END CREATE_ARCH;

PROCEDURE CREATE_TAX(
	p_assignment_action_id		in number,
	p_effective_date		in date,
	p_assignment_id			in number,
	p_value				in value_rec
)
IS
l_action_information_id			number;
BEGIN
	l_action_information_id := NEXT_ACTION_INFORMATION_ID;

	INSERT INTO PAY_JP_ITAX_TAX_V
	(
		ACTION_INFORMATION_ID,
		ACTION_CONTEXT_ID,
		ACTION_CONTEXT_TYPE,
		EFFECTIVE_DATE,
		ASSIGNMENT_ID,
		OBJECT_VERSION_NUMBER,
		ACTION_INFORMATION_CATEGORY,
		TAXABLE_INCOME,
		NET_TAXABLE_INCOME,
		TOTAL_INCOME_EXEMPT,
		WITHHOLDING_ITAX,
		WITHHOLDING_ITAX2,
		SPOUSE_SPECIAL_EXEMPT,
		SOCIAL_INSURANCE_PREMIUM,
		MUTUAL_AID_PREMIUM,
		LIFE_INSURANCE_PREMIUM_EXEMPT,
		DAMAGE_INSURANCE_PREMIUM_EXEM,
		HOUSING_TAX_REDUCTION,
		ITAX_ADJUSTMENT2,
		SPOUSE_NET_TAXABLE_INCOME,
		PRIVATE_PENSION_PREMIUM,
		LONG_DAMAGE_INSURANCE_PREMIUM,
		DISASTER_TAX_REDUCTION,
		PREV_JOB_EMPLOYER_ADD_KANA,
		PREV_JOB_EMPLOYER_ADD_KANJI,
		PREV_JOB_EMPLOYER_NAME_KANA,
		PREV_JOB_EMPLOYER_NAME_KANJI,
		PREV_JOB_FOREIGN_ADDRESS,
		PREV_JOB_TAXABLE_INCOME,
		PREV_JOB_ITAX,
		PREV_JOB_SI_PREM,
		PREV_JOB_TERMINATION_YEAR,
		PREV_JOB_TERMINATION_MONTH,
		PREV_JOB_TERMINATION_DAY,
		HOUSING_RESIDENCE_YEAR,
		HOUSING_RESIDENCE_MONTH,
		HOUSING_RESIDENCE_DAY
	)
	VALUES
	(
		l_action_information_id,
		p_assignment_action_id,
		c_action_context_type,
		p_effective_date,
		p_assignment_id,
		c_first_object_version_number,
		c_action_info_category_tax,
		p_value.p_action_information1,
		p_value.p_action_information2,
		p_value.p_action_information3,
		p_value.p_action_information4,
		p_value.p_action_information5,
		p_value.p_action_information6,
		p_value.p_action_information7,
		p_value.p_action_information8,
		p_value.p_action_information9,
		p_value.p_action_information10,
		p_value.p_action_information11,
		p_value.p_action_information12,
		p_value.p_action_information13,
		p_value.p_action_information14,
		p_value.p_action_information15,
		p_value.p_action_information16,
		p_value.p_action_information17,
		p_value.p_action_information18,
		p_value.p_action_information19,
		p_value.p_action_information20,
		p_value.p_action_information21,
		p_value.p_action_information22,
		p_value.p_action_information23,
		p_value.p_action_information24,
		p_value.p_action_information25,
		p_value.p_action_information26,
		p_value.p_action_information27,
		p_value.p_action_information28,
		p_value.p_action_information29,
		p_value.p_action_information30
	);
END CREATE_TAX;

PROCEDURE CREATE_OTHER(
	p_assignment_action_id		in number,
	p_effective_date		in date,
	p_assignment_id			in number,
	p_value				in value_rec
)
IS
l_action_information_id			number;
BEGIN
	l_action_information_id := NEXT_ACTION_INFORMATION_ID;

	INSERT INTO PAY_JP_ITAX_OTHER_V
	(
		ACTION_INFORMATION_ID,
		ACTION_CONTEXT_ID,
		ACTION_CONTEXT_TYPE,
		EFFECTIVE_DATE,
		ASSIGNMENT_ID,
		OBJECT_VERSION_NUMBER,
		ACTION_INFORMATION_CATEGORY,
		DEPENDENT_SPOUSE_EXISTS_KOU,
		DEPENDENT_SPOUSE_NO_EXIST_KOU,
		DEPENDENT_SPOUSE_EXISTS_OTSU,
		DEPENDENT_SPOUSE_NO_EXIST_OTSU,
		AGED_SPOUSE_EXISTS,
		NUM_SPECIFIEDS_KOU,
		NUM_SPECIFIEDS_OTSU,
		NUM_AGED_PARENTS_PARTIAL,
		NUM_AGEDS_KOU,
		NUM_AGEDS_OTSU,
		NUM_DEPENDENTS_KOU,
		NUM_DEPENDENTS_OTSU,
		NUM_SPECIAL_DISABLEDS_PARTIAL,
		NUM_SPECIAL_DISABLEDS,
		NUM_DISABLEDS,
		HUSBAND_EXISTS,
		MINOR,
		OTSU,
		SPECIAL_DISABLED,
		DISABLED,
		AGED,
		WIDOW,
		SPECIAL_WIDOW,
		WIDOWER,
		WORKING_STUDENT,
		DECEASED_TERMINATION,
		DISASTERED,
		FOREIGNER,
		EMPLOYED,
		UNEMPLOYED
	)
	VALUES
	(
		l_action_information_id,
		p_assignment_action_id,
		c_action_context_type,
		p_effective_date,
		p_assignment_id,
		c_first_object_version_number,
		c_action_info_category_other,
		p_value.p_action_information1,
		p_value.p_action_information2,
		p_value.p_action_information3,
		p_value.p_action_information4,
		p_value.p_action_information5,
		p_value.p_action_information6,
		p_value.p_action_information7,
		p_value.p_action_information8,
		p_value.p_action_information9,
		p_value.p_action_information10,
		p_value.p_action_information11,
		p_value.p_action_information12,
		p_value.p_action_information13,
		p_value.p_action_information14,
		p_value.p_action_information15,
		p_value.p_action_information16,
		p_value.p_action_information17,
		p_value.p_action_information18,
		p_value.p_action_information19,
		p_value.p_action_information20,
		p_value.p_action_information21,
		p_value.p_action_information22,
		p_value.p_action_information23,
		p_value.p_action_information24,
		p_value.p_action_information25,
		p_value.p_action_information26,
		p_value.p_action_information27,
		p_value.p_action_information28,
		p_value.p_action_information29,
		p_value.p_action_information30
	);
END CREATE_OTHER;

PROCEDURE CREATE_OTHER2(
	p_assignment_action_id		in number,
	p_effective_date		in date,
	p_assignment_id			in number,
	p_value				in value_rec
)
IS
l_action_information_id			number;
BEGIN
	l_action_information_id := NEXT_ACTION_INFORMATION_ID;

	INSERT INTO PAY_JP_ITAX_OTHER_V2
	(
		ACTION_INFORMATION_ID,
		ACTION_CONTEXT_ID,
		ACTION_CONTEXT_TYPE,
		EFFECTIVE_DATE,
		ASSIGNMENT_ID,
		OBJECT_VERSION_NUMBER,
		ACTION_INFORMATION_CATEGORY,
		BUSINESS_GROUP_ID,
		PROCESS_FLAG,
		NEW_DESCRIPTION1,
		NEW_DESCRIPTION2,
		NEW_DESCRIPTION3,
		NEW_DESCRIPTION4,
		NEW_DESCRIPTION5,
		NEW_FILE_DESCRIPTION1,
		NEW_FILE_DESCRIPTION2,
		NEW_FILE_DESCRIPTION3,
		NEW_FILE_DESCRIPTION4,
		NEW_FILE_DESCRIPTION5,
		DESC_OVERRIDE_FLAG,
		FILE_DESC_OVERRIDE_FLAG,
		DESCRIPTION_KANJI_1,
		DESCRIPTION_KANJI_2,
		DESCRIPTION_KANA_1,
		DESCRIPTION_KANA_2,
		FILE_DESCRIPTION_KANJI_1,
		FILE_DESCRIPTION_KANJI_2,
		FILE_DESCRIPTION_KANA_1,
		FILE_DESCRIPTION_KANA_2,
		DESC_LINE1_KANJI,
		DESC_LINE1_KANA,
		ACTION_INFORMATION25,
		ACTION_INFORMATION26,
		ACTION_INFORMATION27,
		ACTION_INFORMATION28,
		ACTION_INFORMATION29,
		ACTION_INFORMATION30	)
	VALUES
	(
		l_action_information_id,
		p_assignment_action_id,
		c_action_context_type,
		p_effective_date,
		p_assignment_id,
		c_first_object_version_number,
		c_action_info_category_other2,
		p_value.p_action_information1,
		p_value.p_action_information2,
		p_value.p_action_information3,
		p_value.p_action_information4,
		p_value.p_action_information5,
		p_value.p_action_information6,
		p_value.p_action_information7,
		p_value.p_action_information8,
		p_value.p_action_information9,
		p_value.p_action_information10,
		p_value.p_action_information11,
		p_value.p_action_information12,
		p_value.p_action_information13,
		p_value.p_action_information14,
		p_value.p_action_information15,
		p_value.p_action_information16,
		p_value.p_action_information17,
		p_value.p_action_information18,
		p_value.p_action_information19,
		p_value.p_action_information20,
		p_value.p_action_information21,
		p_value.p_action_information22,
		p_value.p_action_information23,
		p_value.p_action_information24,
		p_value.p_action_information25,
		p_value.p_action_information26,
		p_value.p_action_information27,
		p_value.p_action_information28,
		p_value.p_action_information29,
		p_value.p_action_information30
	);
END CREATE_OTHER2;

PROCEDURE DELETE_ITAX(
	p_assignment_id		IN NUMBER,
	p_effective_date	IN DATE,
	p_swot_id		IN NUMBER,
	p_tax_type		IN VARCHAR2
)
IS
BEGIN
-- Fine Tuned the query to fix Bug# 5202835.
DELETE	PAY_ACTION_INFORMATION PAI
WHERE	PAI.ACTION_INFORMATION_CATEGORY in ('JP_ITAX_PERSON','JP_ITAX_ARCH','JP_ITAX_TAX','JP_ITAX_OTHER','JP_ITAX_OTHER2')
AND	PAI.ASSIGNMENT_ID = p_assignment_id
AND   EXISTS ( SELECT NULL
        FROM    PAY_ACTION_INFORMATION    PERSON,
                PAY_ACTION_INFORMATION      ARCH,
                PAY_ACTION_INFORMATION       TAX,
                PAY_ACTION_INFORMATION     OTHER,
                PAY_ACTION_INFORMATION    OTHER2
        WHERE   OTHER2.ACTION_INFORMATION_CATEGORY = 'JP_ITAX_OTHER2'
        AND     OTHER2.ACTION_CONTEXT_TYPE = 'AAP'
        AND     OTHER2.ASSIGNMENT_ID = p_assignment_id
	AND	to_char(OTHER2.EFFECTIVE_DATE,'YYYY') = to_char(p_effective_date,'YYYY')
	AND	OTHER2.EFFECTIVE_DATE <= p_effective_date
        AND     OTHER2.EFFECTIVE_DATE = PAI.EFFECTIVE_DATE
        AND     PERSON.ACTION_INFORMATION_CATEGORY = 'JP_ITAX_PERSON'
        AND     PERSON.ACTION_CONTEXT_TYPE = 'AAP'
        AND     PERSON.action_information24 = to_char(p_swot_id)
        AND     ARCH.ACTION_INFORMATION_CATEGORY = 'JP_ITAX_ARCH'
        AND     ARCH.ACTION_CONTEXT_TYPE = 'AAP'
        AND     ARCH.action_information14 = p_tax_type
        AND     PERSON.ACTION_CONTEXT_ID = ARCH.ACTION_CONTEXT_ID
        AND     PERSON.EFFECTIVE_DATE = ARCH.EFFECTIVE_DATE
        AND     TAX.ACTION_INFORMATION_CATEGORY = 'JP_ITAX_TAX'
        AND     TAX.ACTION_CONTEXT_TYPE = 'AAP'
        AND     PERSON.ACTION_CONTEXT_ID = TAX.ACTION_CONTEXT_ID
        AND     PERSON.EFFECTIVE_DATE = TAX.EFFECTIVE_DATE
        AND     OTHER.ACTION_INFORMATION_CATEGORY = 'JP_ITAX_OTHER'
        AND     OTHER.ACTION_CONTEXT_TYPE = 'AAP'
        AND     PERSON.ACTION_CONTEXT_ID = OTHER.ACTION_CONTEXT_ID
        AND     PERSON.EFFECTIVE_DATE = OTHER.EFFECTIVE_DATE
        AND     PERSON.ACTION_CONTEXT_ID = OTHER2.ACTION_CONTEXT_ID
        AND     PERSON.EFFECTIVE_DATE = OTHER2.EFFECTIVE_DATE
);

END DELETE_ITAX;

END;

/
