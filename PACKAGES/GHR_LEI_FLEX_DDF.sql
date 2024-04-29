--------------------------------------------------------
--  DDL for Package GHR_LEI_FLEX_DDF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_LEI_FLEX_DDF" AUTHID CURRENT_USER as
/* $Header: ghleiddf.pkh 115.5 2002/01/09 10:24:48 pkm ship      $ */
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
--    2) If when the refence field value is null and not all
--       the attribute arguments are not null(i.e. attribute
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
procedure ddf
	(
		p_location_extra_info_id	in	number	,
		p_information_type		in	varchar2	,
		p_location_id			in	number	,
		p_request_id			in	number	,
		p_program_application_id	in	number	,
		p_program_id			in	number	,
		p_program_update_date		in	date		,
		p_lei_attribute_category	in	varchar2	,
		p_lei_attribute1			in	varchar2	,
		p_lei_attribute2			in	varchar2	,
		p_lei_attribute3			in	varchar2	,
		p_lei_attribute4			in	varchar2	,
		p_lei_attribute5			in	varchar2	,
		p_lei_attribute6			in	varchar2	,
		p_lei_attribute7			in	varchar2	,
		p_lei_attribute8			in	varchar2	,
		p_lei_attribute9			in	varchar2	,
		p_lei_attribute10			in	varchar2	,
		p_lei_attribute11			in	varchar2	,
		p_lei_attribute12			in	varchar2	,
		p_lei_attribute13			in	varchar2	,
		p_lei_attribute14			in	varchar2	,
		p_lei_attribute15			in	varchar2	,
		p_lei_attribute16			in	varchar2	,
		p_lei_attribute17			in	varchar2	,
		p_lei_attribute18			in	varchar2	,
		p_lei_attribute19			in	varchar2	,
		p_lei_attribute20			in	varchar2	,
		p_lei_information_category	in	varchar2	,
		p_lei_information1		in	varchar2	,
		p_lei_information2		in	varchar2	,
		p_lei_information3		in	varchar2	,
		p_lei_information4		in	varchar2	,
		p_lei_information5		in	varchar2	,
		p_lei_information6		in	varchar2	,
		p_lei_information7		in	varchar2	,
		p_lei_information8		in	varchar2	,
		p_lei_information9		in	varchar2	,
		p_lei_information10		in	varchar2	,
		p_lei_information11		in	varchar2	,
		p_lei_information12		in	varchar2	,
		p_lei_information13		in	varchar2	,
		p_lei_information14		in	varchar2	,
		p_lei_information15		in	varchar2	,
		p_lei_information16		in	varchar2	,
		p_lei_information17		in	varchar2	,
		p_lei_information18		in	varchar2	,
		p_lei_information19		in	varchar2	,
		p_lei_information20		in	varchar2	,
		p_lei_information21		in	varchar2	,
		p_lei_information22		in	varchar2	,
		p_lei_information23		in	varchar2	,
		p_lei_information24		in	varchar2	,
		p_lei_information25		in	varchar2	,
		p_lei_information26		in	varchar2	,
		p_lei_information27		in	varchar2	,
		p_lei_information28		in	varchar2	,
		p_lei_information29		in	varchar2	,
		p_lei_information30		in	varchar2
	);
--
end ghr_lei_flex_ddf;

 

/
