--------------------------------------------------------
--  DDL for Package GHR_PEI_FLEX_DDF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PEI_FLEX_DDF" AUTHID CURRENT_USER as
/* $Header: ghpeiddf.pkh 120.0.12010000.1 2008/07/28 10:36:49 appldev ship $ */
--
-- -----------------------------------------------------------------------------
-- |-------------------------------< ddf >--------------------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
--  Description:
--    This procedure controls the validation processing required for
--    developer descriptive flexfields by calling the relevant validation
--    procedures. These are called dependant on the value of the relevant
--    entity reference field value.
--
--  Pre Conditions:
--    A fully validated entity record structure.
--
--  In Arguments:
--    p_rec (Record structure for relevant entity).
--
--  Post Success:
--    Processing of the calling api continues.
--
--  Post Failure:
--    A failure can only occur under two circumstances:
--    1) The value of reference field is not supported.
--    2) If when the reference field value is null and not all
--       the information arguments are not null(i.e. information
--       arguments cannot be set without a corresponding reference
--       field value).
--
--  Developer Implementation Notes:
--    Developer defined.
--
--  Access Status:
--    Internal Development Use Only.
--
--  {End of Comments}
-- -----------------------------------------------------------------------------
/*
procedure ddf
  (p_rec   in pe_pei_shd.g_rec_type
  );
*/
procedure ddf
(
		p_person_extra_info_id		in	number	,
		p_person_id				in	number	,
		p_information_type		in	varchar2	,
		p_request_id			in	number	,
		p_program_application_id	in	number	,
		p_program_id			in	number	,
		p_program_update_date		in	date		,
		p_pei_attribute_category	in	varchar2	,
		p_pei_attribute1			in	varchar2	,
		p_pei_attribute2			in	varchar2	,
		p_pei_attribute3			in	varchar2	,
		p_pei_attribute4			in	varchar2	,
		p_pei_attribute5			in	varchar2	,
		p_pei_attribute6			in	varchar2	,
		p_pei_attribute7			in	varchar2	,
		p_pei_attribute8			in	varchar2	,
		p_pei_attribute9			in	varchar2	,
		p_pei_attribute10			in	varchar2	,
		p_pei_attribute11			in	varchar2	,
		p_pei_attribute12			in	varchar2	,
		p_pei_attribute13			in	varchar2	,
		p_pei_attribute14			in	varchar2	,
		p_pei_attribute15			in	varchar2	,
		p_pei_attribute16			in	varchar2	,
		p_pei_attribute17			in	varchar2	,
		p_pei_attribute18			in	varchar2	,
		p_pei_attribute19			in	varchar2	,
		p_pei_attribute20			in	varchar2	,
		p_pei_information_category	in	varchar2	,
		p_pei_information1		in	varchar2	,
		p_pei_information2		in	varchar2	,
		p_pei_information3		in	varchar2	,
		p_pei_information4		in	varchar2	,
		p_pei_information5		in	varchar2	,
		p_pei_information6		in	varchar2	,
		p_pei_information7		in	varchar2	,
		p_pei_information8		in	varchar2	,
		p_pei_information9		in	varchar2	,
		p_pei_information10		in	varchar2	,
		p_pei_information11		in	varchar2	,
		p_pei_information12		in	varchar2	,
		p_pei_information13		in	varchar2	,
		p_pei_information14		in	varchar2	,
		p_pei_information15		in	varchar2	,
		p_pei_information16		in	varchar2	,
		p_pei_information17		in	varchar2	,
		p_pei_information18		in	varchar2	,
		p_pei_information19		in	varchar2	,
		p_pei_information20		in	varchar2	,
		p_pei_information21		in	varchar2	,
		p_pei_information22		in	varchar2	,
		p_pei_information23		in	varchar2	,
		p_pei_information24		in	varchar2	,
		p_pei_information25		in	varchar2	,
		p_pei_information26		in	varchar2	,
		p_pei_information27		in	varchar2	,
		p_pei_information28		in	varchar2	,
		p_pei_information29		in	varchar2	,
		p_pei_information30		in	varchar2
	);

-- |-------------------------< chk_ins_routing_group_info >--------------------------|
-- ----------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that the if the person is :
--       Already assigned to this routing group.
--       If he the Reviewer/ Requestor/ Authorizer/ Approver combination is valid.
--	   If the Person is already assigned a Defualt routing group.
--  Pre-conditions :
--    p_person_id is valid
--
--  In Parameters :
--    p_information_type
--    p_person_id
--	p_pei_information3
--	p_pei_information4
--	p_pei_information5
--	p_pei_information6
--	p_pei_information7
--	p_pei_information8
--	p_pei_information9
--	p_pei_information10
--
--  Post Success :
--    Processing continues if the Person is not already a member of the routing
--    group.
--    If his roles of Reviewer/ Requestor/ Authorizer/ Approver/ Personnelist combination is valid.
--    If his Default Routing group is valid
--
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    Person has a duplicate Routing group.
--    An application error will also be raised and processing is terminated if
--    his roles of Reviewer/ Requestor/ Authorizer/ Approver/ Personnelist combination is invalid.
--    If he is already a Defaulted to a routing group.
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_routing_group_info
 (p_person_extra_info_id in per_people_extra_info.person_extra_info_id%TYPE
 ,p_information_type in  per_people_extra_info.information_type%TYPE
 ,p_person_id        in  per_people_extra_info.person_id%TYPE
 ,p_pei_information3 in per_people_extra_info.pei_information3%TYPE
 ,p_pei_information4 in per_people_extra_info.pei_information4%TYPE
 ,p_pei_information5 in per_people_extra_info.pei_information5%TYPE
 ,p_pei_information6 in per_people_extra_info.pei_information6%TYPE
 ,p_pei_information7 in per_people_extra_info.pei_information7%TYPE
 ,p_pei_information8 in per_people_extra_info.pei_information8%TYPE
 ,p_pei_information9 in per_people_extra_info.pei_information9%TYPE
 ,p_pei_information10 in per_people_extra_info.pei_information10%TYPE
);
--
Procedure chk_oghr_roles
 (p_person_extra_info_id in per_people_extra_info.person_extra_info_id%TYPE
 ,p_information_type in  per_people_extra_info.information_type%TYPE
 ,p_person_id        in  per_people_extra_info.person_id%TYPE
 ,p_pei_information3 in per_people_extra_info.pei_information3%TYPE
 ,p_pei_information4 in per_people_extra_info.pei_information4%TYPE
 ,p_pei_information5 in per_people_extra_info.pei_information5%TYPE
 ,p_pei_information6 in per_people_extra_info.pei_information6%TYPE
 ,p_pei_information7 in per_people_extra_info.pei_information7%TYPE
 ,p_pei_information8 in per_people_extra_info.pei_information8%TYPE
 ,p_pei_information9 in per_people_extra_info.pei_information9%TYPE
 ,p_pei_information10 in per_people_extra_info.pei_information10%TYPE
 );
--
--
end ghr_pei_flex_ddf;

/
