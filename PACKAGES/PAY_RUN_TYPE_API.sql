--------------------------------------------------------
--  DDL for Package PAY_RUN_TYPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RUN_TYPE_API" AUTHID CURRENT_USER as
/* $Header: pyprtapi.pkh 120.1 2005/10/02 02:33:16 aroussel $ */
/*#
 * This package contains the Create Payroll API.
 * @rep:scope public
 * @rep:product pay
 * @rep:displayname Run Type
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_run_type >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates new run types.
 *
 * Created run types will then be used by the Payroll processes.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The business group where this record to be created should exist.
 *
 * <p><b>Post Success</b><br>
 * The run type will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the run type and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_run_type_name The name for the run type.
 * @param p_run_method The method for the run type, this will either be 'N',
 * 'C', 'P' or 'S'.
 * @param p_business_group_id Business Group of the Record.
 * @param p_legislation_code Legislation Code
 * @param p_shortname Short name for the run type
 * @param p_srs_flag If 'Y', then run type would be used in SRS definition.
 * @param p_run_information_category Developer Descriptive flexfield for Run
 * Type
 * @param p_run_information1 Developer Descriptive flexfield segment.
 * @param p_run_information2 Developer Descriptive flexfield segment.
 * @param p_run_information3 Developer Descriptive flexfield segment.
 * @param p_run_information4 Developer Descriptive flexfield segment.
 * @param p_run_information5 Developer Descriptive flexfield segment.
 * @param p_run_information6 Developer Descriptive flexfield segment.
 * @param p_run_information7 Developer Descriptive flexfield segment.
 * @param p_run_information8 Developer Descriptive flexfield segment.
 * @param p_run_information9 Developer Descriptive flexfield segment.
 * @param p_run_information10 Developer Descriptive flexfield segment.
 * @param p_run_information11 Developer Descriptive flexfield segment.
 * @param p_run_information12 Developer Descriptive flexfield segment.
 * @param p_run_information13 Developer Descriptive flexfield segment.
 * @param p_run_information14 Developer Descriptive flexfield segment.
 * @param p_run_information15 Developer Descriptive flexfield segment.
 * @param p_run_information16 Developer Descriptive flexfield segment.
 * @param p_run_information17 Developer Descriptive flexfield segment.
 * @param p_run_information18 Developer Descriptive flexfield segment.
 * @param p_run_information19 Developer Descriptive flexfield segment.
 * @param p_run_information20 Developer Descriptive flexfield segment.
 * @param p_run_information21 Developer Descriptive flexfield segment.
 * @param p_run_information22 Developer Descriptive flexfield segment.
 * @param p_run_information23 Developer Descriptive flexfield segment.
 * @param p_run_information24 Developer Descriptive flexfield segment.
 * @param p_run_information25 Developer Descriptive flexfield segment.
 * @param p_run_information26 Developer Descriptive flexfield segment.
 * @param p_run_information27 Developer Descriptive flexfield segment.
 * @param p_run_information28 Developer Descriptive flexfield segment.
 * @param p_run_information29 Developer Descriptive flexfield segment.
 * @param p_run_information30 Developer Descriptive flexfield segment.
 * @param p_run_type_id If p_validate is false, this uniquely identifies the
 * run type created. If p_validate is set to true, this parameter will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created run type. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created run type. If p_validate is true, then set
 * to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the run type. If p_validate is true, then the value will
 * be null.
 * @rep:displayname Create Run Type
 * @rep:category BUSINESS_ENTITY PAY_RUN_TYPE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_run_type
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_run_type_name                 in     varchar2
  ,p_run_method                    in     varchar2
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_shortname                     in     varchar2 default null
  ,p_srs_flag                      in     varchar2 default 'Y'
  ,p_run_information_category	   in     varchar2 default null
  ,p_run_information1		   in     varchar2 default null
  ,p_run_information2		   in     varchar2 default null
  ,p_run_information3		   in     varchar2 default null
  ,p_run_information4		   in	  varchar2 default null
  ,p_run_information5		   in     varchar2 default null
  ,p_run_information6		   in     varchar2 default null
  ,p_run_information7		   in     varchar2 default null
  ,p_run_information8		   in     varchar2 default null
  ,p_run_information9		   in	  varchar2 default null
  ,p_run_information10		   in     varchar2 default null
  ,p_run_information11		   in     varchar2 default null
  ,p_run_information12		   in     varchar2 default null
  ,p_run_information13		   in     varchar2 default null
  ,p_run_information14		   in	  varchar2 default null
  ,p_run_information15		   in     varchar2 default null
  ,p_run_information16		   in     varchar2 default null
  ,p_run_information17		   in     varchar2 default null
  ,p_run_information18		   in     varchar2 default null
  ,p_run_information19		   in	  varchar2 default null
  ,p_run_information20		   in     varchar2 default null
  ,p_run_information21		   in     varchar2 default null
  ,p_run_information22		   in     varchar2 default null
  ,p_run_information23		   in     varchar2 default null
  ,p_run_information24		   in	  varchar2 default null
  ,p_run_information25		   in     varchar2 default null
  ,p_run_information26		   in     varchar2 default null
  ,p_run_information27		   in     varchar2 default null
  ,p_run_information28		   in     varchar2 default null
  ,p_run_information29		   in	  varchar2 default null
  ,p_run_information30		   in     varchar2 default null
  ,p_run_type_id                      out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_run_type >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates run type.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The run type as identified by the in parameters p_run_type and
 * p_object_version_number must already exist.
 *
 * <p><b>Post Success</b><br>
 * Run type data will be updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the run type and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_run_type_id Identifier of the run type being updated.
 * @param p_object_version_number Pass in the current version number of the run
 * type to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated run type. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_business_group_id Business Group of the Record.
 * @param p_legislation_code Legislation Code
 * @param p_shortname Short name for the run type
 * @param p_srs_flag If 'Y', then run type would be used in SRS definition.
 * @param p_run_information_category Developer Descriptive flexfield for Run
 * Type
 * @param p_run_information1 Developer Descriptive flexfield segment.
 * @param p_run_information2 Developer Descriptive flexfield segment.
 * @param p_run_information3 Developer Descriptive flexfield segment.
 * @param p_run_information4 Developer Descriptive flexfield segment.
 * @param p_run_information5 Developer Descriptive flexfield segment.
 * @param p_run_information6 Developer Descriptive flexfield segment.
 * @param p_run_information7 Developer Descriptive flexfield segment.
 * @param p_run_information8 Developer Descriptive flexfield segment.
 * @param p_run_information9 Developer Descriptive flexfield segment.
 * @param p_run_information10 Developer Descriptive flexfield segment.
 * @param p_run_information11 Developer Descriptive flexfield segment.
 * @param p_run_information12 Developer Descriptive flexfield segment.
 * @param p_run_information13 Developer Descriptive flexfield segment.
 * @param p_run_information14 Developer Descriptive flexfield segment.
 * @param p_run_information15 Developer Descriptive flexfield segment.
 * @param p_run_information16 Developer Descriptive flexfield segment.
 * @param p_run_information17 Developer Descriptive flexfield segment.
 * @param p_run_information18 Developer Descriptive flexfield segment.
 * @param p_run_information19 Developer Descriptive flexfield segment.
 * @param p_run_information20 Developer Descriptive flexfield segment.
 * @param p_run_information21 Developer Descriptive flexfield segment.
 * @param p_run_information22 Developer Descriptive flexfield segment.
 * @param p_run_information23 Developer Descriptive flexfield segment.
 * @param p_run_information24 Developer Descriptive flexfield segment.
 * @param p_run_information25 Developer Descriptive flexfield segment.
 * @param p_run_information26 Developer Descriptive flexfield segment.
 * @param p_run_information27 Developer Descriptive flexfield segment.
 * @param p_run_information28 Developer Descriptive flexfield segment.
 * @param p_run_information29 Developer Descriptive flexfield segment.
 * @param p_run_information30 Developer Descriptive flexfield segment.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated run type row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated run type row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Run Type
 * @rep:category BUSINESS_ENTITY PAY_RUN_TYPE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_run_type
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_run_type_id                   in     number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_shortname                     in     varchar2 default hr_api.g_varchar2
  ,p_srs_flag                      in     varchar2 default hr_api.g_varchar2
  ,p_run_information_category	   in     varchar2 default hr_api.g_varchar2
  ,p_run_information1		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information2		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information3		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information4		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information5		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information6		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information7		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information8		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information9		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information10		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information11		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information12		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information13		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information14		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information15		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information16		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information17		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information18		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information19		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information20		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information21		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information22		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information23		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information24		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information25		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information26		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information27		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information28		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information29		   in     varchar2 default hr_api.g_varchar2
  ,p_run_information30		   in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_run_type >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a run type.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The run type as identified by the in parameters p_run_type and
 * p_object_version_number must already exist.
 *
 * <p><b>Post Success</b><br>
 * Rub type will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the run type and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_delete_mode Indicates which DateTrack mode to use when
 * deleting the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @param p_run_type_id Identifier of the run type being deleted.
 * @param p_object_version_number Pass in the current version number of the
 * organization payment method to be deleted. When the API completes if
 * p_validate is false, will be set to the new version number of the deleted
 * organization payment method. If p_validate is true will be set to the same
 * value which was passed in.
 * @param p_business_group_id Business Group of the Record.
 * @param p_legislation_code Legislation Code
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted run type row which now exists as of the
 * effective date. If p_validate is true or all row instances have been deleted
 * then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted run type row which now exists as of the
 * effective date. If p_validate is true or all row instances have been deleted
 * then set to null.
 * @rep:displayname Delete Run Type
 * @rep:category BUSINESS_ENTITY PAY_RUN_TYPE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_run_type
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_run_type_id                   in     number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
--

end pay_run_type_api;

 

/
