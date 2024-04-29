--------------------------------------------------------
--  DDL for Package GHR_POI_FLEX_DDF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_POI_FLEX_DDF" AUTHID CURRENT_USER as
/* $Header: ghpoiddf.pkh 120.1 2005/06/22 04:21:11 sumarimu noship $ */
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
procedure ddf
	(
		p_position_extra_info_id	in	number	,
		p_position_id			in	number	,
		p_information_type		in	varchar2	,
		p_request_id			in	number	,
		p_program_application_id	in	number	,
		p_program_id			in	number	,
		p_program_update_date		in	date		,
		p_poei_attribute_category	in	varchar2	,
		p_poei_attribute1			in	varchar2	,
		p_poei_attribute2			in	varchar2	,
		p_poei_attribute3			in	varchar2	,
		p_poei_attribute4			in	varchar2	,
		p_poei_attribute5			in	varchar2	,
		p_poei_attribute6			in	varchar2	,
		p_poei_attribute7			in	varchar2	,
		p_poei_attribute8			in	varchar2	,
		p_poei_attribute9			in	varchar2	,
		p_poei_attribute10		in	varchar2	,
		p_poei_attribute11		in	varchar2	,
		p_poei_attribute12		in	varchar2	,
		p_poei_attribute13		in	varchar2	,
		p_poei_attribute14		in	varchar2	,
		p_poei_attribute15		in	varchar2	,
		p_poei_attribute16		in	varchar2	,
		p_poei_attribute17		in	varchar2	,
		p_poei_attribute18		in	varchar2	,
		p_poei_attribute19		in	varchar2	,
		p_poei_attribute20		in	varchar2	,
		p_poei_information_category	in	varchar2	,
		p_poei_information1		in	varchar2	,
		p_poei_information2		in	varchar2	,
		p_poei_information3		in	varchar2	,
		p_poei_information4		in	varchar2	,
		p_poei_information5		in	varchar2	,
		p_poei_information6		in	varchar2	,
		p_poei_information7		in	varchar2	,
		p_poei_information8		in	varchar2	,
		p_poei_information9		in	varchar2	,
		p_poei_information10		in	varchar2	,
		p_poei_information11		in	varchar2	,
		p_poei_information12		in	varchar2	,
		p_poei_information13		in	varchar2	,
		p_poei_information14		in	varchar2	,
		p_poei_information15		in	varchar2	,
		p_poei_information16		in	varchar2	,
		p_poei_information17		in	varchar2	,
		p_poei_information18		in	varchar2	,
		p_poei_information19		in	varchar2	,
		p_poei_information20		in	varchar2	,
		p_poei_information21		in	varchar2	,
		p_poei_information22		in	varchar2	,
		p_poei_information23		in	varchar2	,
		p_poei_information24		in	varchar2	,
		p_poei_information25		in	varchar2	,
		p_poei_information26		in	varchar2	,
		p_poei_information27		in	varchar2	,
		p_poei_information28		in	varchar2	,
		p_poei_information29		in	varchar2	,
		p_poei_information30		in	varchar2
	);

	procedure create_ddf
	(
		p_position_id			in	number	,
		p_information_type		in	varchar2	,
		p_poei_attribute_category	in	varchar2	,
		p_poei_attribute1		in	varchar2	,
		p_poei_attribute2		in	varchar2	,
		p_poei_attribute3		in	varchar2	,
		p_poei_attribute4		in	varchar2	,
		p_poei_attribute5		in	varchar2	,
		p_poei_attribute6		in	varchar2	,
		p_poei_attribute7		in	varchar2	,
		p_poei_attribute8		in	varchar2	,
		p_poei_attribute9		in	varchar2	,
		p_poei_attribute10		in	varchar2	,
		p_poei_attribute11		in	varchar2	,
		p_poei_attribute12		in	varchar2	,
		p_poei_attribute13		in	varchar2	,
		p_poei_attribute14		in	varchar2	,
		p_poei_attribute15		in	varchar2	,
		p_poei_attribute16		in	varchar2	,
		p_poei_attribute17		in	varchar2	,
		p_poei_attribute18		in	varchar2	,
		p_poei_attribute19		in	varchar2	,
		p_poei_attribute20		in	varchar2	,
		p_poei_information_category	in	varchar2	,
		p_poei_information1		in	varchar2	,
		p_poei_information2		in	varchar2	,
		p_poei_information3		in	varchar2	,
		p_poei_information4		in	varchar2	,
		p_poei_information5		in	varchar2	,
		p_poei_information6		in	varchar2	,
		p_poei_information7		in	varchar2	,
		p_poei_information8		in	varchar2	,
		p_poei_information9		in	varchar2	,
		p_poei_information10		in	varchar2	,
		p_poei_information11		in	varchar2	,
		p_poei_information12		in	varchar2	,
		p_poei_information13		in	varchar2	,
		p_poei_information14		in	varchar2	,
		p_poei_information15		in	varchar2	,
		p_poei_information16		in	varchar2	,
		p_poei_information17		in	varchar2	,
		p_poei_information18		in	varchar2	,
		p_poei_information19		in	varchar2	,
		p_poei_information20		in	varchar2	,
		p_poei_information21		in	varchar2	,
		p_poei_information22		in	varchar2	,
		p_poei_information23		in	varchar2	,
		p_poei_information24		in	varchar2	,
		p_poei_information25		in	varchar2	,
		p_poei_information26		in	varchar2	,
		p_poei_information27		in	varchar2	,
		p_poei_information28		in	varchar2	,
		p_poei_information29		in	varchar2	,
		p_poei_information30		in	varchar2
	);

-- -----------------------------------------------------------------------------------------
-- |-----------------------------------< chk_date_from >-----------------------------------|
-- -----------------------------------------------------------------------------------------
-- {Start of Comments}
--
--  Description:
--    This procedure validates the date_from ddf.
--
--  Pre Conditions:
--    None.
--
--  In Arguments:
--    p_position_description_id
--    p_date_from
--
--  Post Success:
--    Processing of the calling api continues.
--
--  Post Failure:
--    Processing stops and error raised.
--
--  Developer Implementation Notes:
--    Developer defined.
--
--  Access Status:
--    Internal Development Use Only.
--
--  {End of Comments}
-- -----------------------------------------------------------------------------
--
procedure chk_date_from
  (p_position_description_id    in  ghr_position_descriptions.position_description_id%TYPE
  ,p_date_from                 in  per_position_extra_info.poei_information1%TYPE
  );
--
-- -----------------------------------------------------------------------------------------
-- |----------------------------------< chk_pos_desc_id>-----------------------------------|
-- -----------------------------------------------------------------------------------------
-- {Start of Comments}
--
--  Description:
--    This procedure validates the pos_desc_id ddf.
--
--  Pre Conditions:
--    None.
--
--  In Arguments:
--    p_position_extra_info_id
--    p_pos_desc_id
--
--  Post Success:
--    Processing of the calling api continues.
--
--  Post Failure:
--    Processing stops and error raised.
--
--  Developer Implementation Notes:
--    Developer defined.
--
--  Access Status:
--    Internal Development Use Only.
--
--  {End of Comments}
-- -----------------------------------------------------------------------------
--
procedure chk_pos_desc_id
  (p_position_extra_info_id  in  per_position_extra_info.position_extra_info_id%TYPE
  ,p_pos_desc_id             in  per_position_extra_info.poei_information3%TYPE
  );
--
-- -----------------------------------------------------------------------------------------
-- |-----------------------------------< chk_date_to >-------------------------------------|
-- -----------------------------------------------------------------------------------------
-- {Start of Comments}
--
--  Description:
--    This procedure validates the date_to ddf.
--
--  Pre Conditions:
--    None.
--
--  In Arguments:
--    p_position_extra_info_id
--    p_date_to
--    p_date_from
--
--  Post Success:
--    Processing of the calling api continues.
--
--  Post Failure:
--    Processing stops and error raised.
--
--  Developer Implementation Notes:
--    Developer defined.
--
--  Access Status:
--    Internal Development Use Only.
--
--  {End of Comments}
-- -----------------------------------------------------------------------------
--
procedure chk_date_to
  (p_position_extra_info_id  in  per_position_extra_info.position_extra_info_id%TYPE
  ,p_date_to                 in  per_position_extra_info.poei_information2%TYPE
  ,p_date_from               in  per_position_extra_info.poei_information1%TYPE
  );
--
end ghr_poi_flex_ddf;

 

/
