--------------------------------------------------------
--  DDL for Package IRC_RECRUITING_SITES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_RECRUITING_SITES_API" AUTHID CURRENT_USER as
/* $Header: irrseapi.pkh 120.2.12010000.3 2010/03/05 12:49:51 sbadiger ship $ */
/*#
 * This package contains APIs for recruiting sites.
 * @rep:scope public
 * @rep:product irc
 * @rep:displayname Recruiting Site
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_recruiting_site >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a recruiting site.
 *
 * A recruiting site has information necessary to post adverts to third
 * parties.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The recruiting site will be created in the database
 *
 * <p><b>Post Failure</b><br>
 * The recruiting site will not be created in the database and an error will be
 * raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_site_name The name of the recruiting site
 * @param p_date_from The date from which the recruiting site can be used
 * @param p_date_to The last date on which the recruiting site can be used
 * @param p_posting_username The username for posting adverts to the third
 * party recruiting site
 * @param p_posting_password The password for posting adverts to the third
 * party recruiting site
 * @param p_internal Indicates that the recruiting site is for posting internal
 * vacancies (Y or N)
 * @param p_external Indicates that the recruiting site is for posting external
 * vacancies (Y or N)
 * @param p_third_party Indicates that the recruiting site is a third party
 * recruiting site (Y or N)
 * @param p_redirection_url Reserved for future use
 * @param p_posting_url The URL for posting adverts to the third party
 * recruiting site
 * @param p_posting_cost The cost of posting to the third party recruiting site
 * @param p_posting_cost_period The period that the cost of posting covers.
 * Valid values are defined by 'IRC_POSTING_COST_FREQ' lookup type.
 * @param p_posting_cost_currency The currency that the cost of posting is in
 * @param p_stylesheet The optional XML stylesheet for conversion of the data
 * format for posting to the third party recruiting site
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_recruiting_site_id If p_validate is false, then this uniquely
 * identifies the recruiting site created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created recruiting site. If p_validate is true, then
 * the value will be null.
 * @param p_posting_impl_class Posting Implementation Class Name
 * @rep:displayname Create Recruiting Site
 * @rep:category BUSINESS_ENTITY IRC_RECRUITING_SITE
 * @rep:category BUSINESS_ENTITY IRC_RECRUITING_3RD_PARTY_SITE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure CREATE_RECRUITING_SITE
  (p_validate                      in     boolean  default false
  ,p_language_code                 in  varchar2   default hr_api.userenv_lang
  ,p_effective_date                in     date
  ,p_site_name                     in     varchar2
  ,p_date_from                      in date default null
  ,p_date_to                        in date default null
  ,p_posting_username               in varchar2 default null
  ,p_posting_password               in varchar2 default null
  ,p_internal                      in     varchar2  default 'N'
  ,p_external                      in     varchar2  default 'N'
  ,p_third_party                   in     varchar2 default 'Y'
  ,p_redirection_url               in     varchar2 default null
  ,p_posting_url                   in     varchar2 default null
  ,p_posting_cost                  in     number   default null
  ,p_posting_cost_period           in     varchar2 default null
  ,p_posting_cost_currency         in     varchar2 default null
  ,p_stylesheet           in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_recruiting_site_id               out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_posting_impl_class            in     varchar2 default null
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_recruiting_site >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a recruiting site.
 *
 * A recruiting site has information necessary to post adverts to third
 * parties.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The recruiting site must already exist
 *
 * <p><b>Post Success</b><br>
 * The recruiting site will be updated in the database
 *
 * <p><b>Post Failure</b><br>
 * The recruiting site will not be updated in the database and an error will be
 * raised
 * @param p_recruiting_site_id Identifies the recruiting site
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_site_name The name of the recruiting site
 * @param p_date_from The date from which the recruiting site can be used
 * @param p_date_to The last date on which the recruiting site can be used
 * @param p_posting_username The username for posting adverts to the third
 * party recruiting site
 * @param p_posting_password The password for posting adverts to the third
 * party recruiting site
 * @param p_internal Indicates that the recruiting site is for posting internal
 * vacancies (Y or N)
 * @param p_external Indicates that the recruiting site is for posting external
 * vacancies (Y or N)
 * @param p_third_party Indicates that the recruiting site is a third party
 * recruiting site (Y or N)
 * @param p_redirection_url Reserved for future use
 * @param p_posting_url The URL for posting adverts to the third party
 * recruiting site
 * @param p_posting_cost The cost of posting to the third party recruiting site
 * @param p_posting_cost_period The period that the cost of posting covers.
 * Valid values are defined by 'IRC_POSTING_COST_FREQ' lookup type.
 * @param p_posting_cost_currency The currency that the cost of posting is in
 * @param p_stylesheet The optional XML stylesheet for conversion of the data
 * format for posting to the third party recruiting site
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_object_version_number Pass in the current version number of the
 * recruiting site to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated recruiting site.
 * If p_validate is true will be set to the same value which was passed in.
 * @param p_posting_impl_class Posting Implementation Class Name
 * @rep:displayname Update Recruiting Site
 * @rep:category BUSINESS_ENTITY IRC_RECRUITING_SITE
 * @rep:category BUSINESS_ENTITY IRC_RECRUITING_3RD_PARTY_SITE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure UPDATE_RECRUITING_SITE
  (p_recruiting_site_id            in     number
  ,p_validate                      in     boolean  default false
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_effective_date                in     date
  ,p_site_name                     in     varchar2 default hr_api.g_varchar2
  ,p_date_from                     in     date default hr_api.g_date
  ,p_date_to                       in     date default hr_api.g_date
  ,p_posting_username              in     varchar2 default hr_api.g_varchar2
  ,p_posting_password              in     varchar2 default hr_api.g_varchar2
  ,p_internal                      in     varchar2 default hr_api.g_varchar2
  ,p_external                      in     varchar2 default hr_api.g_varchar2
  ,p_third_party                   in     varchar2 default hr_api.g_varchar2
  ,p_redirection_url               in     varchar2 default hr_api.g_varchar2
  ,p_posting_url                   in     varchar2 default hr_api.g_varchar2
  ,p_posting_cost                  in     number   default hr_api.g_number
  ,p_posting_cost_period           in     varchar2 default hr_api.g_varchar2
  ,p_posting_cost_currency         in     varchar2 default hr_api.g_varchar2
  ,p_stylesheet           in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ,p_posting_impl_class            in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_recruiting_site >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API will delete a recruiting site.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The recruiting site must already exist
 *
 * <p><b>Post Success</b><br>
 * The recruiting site will be deleted from the database
 *
 * <p><b>Post Failure</b><br>
 * The recruiting site will not be deleted from the database and an error will
 * be raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_recruiting_site_id Identifies the recruiting site
 * @param p_object_version_number Current version number of the recruiting site
 * to be deleted.
 * @rep:displayname Delete Recruiting Site
 * @rep:category BUSINESS_ENTITY IRC_RECRUITING_SITE
 * @rep:category BUSINESS_ENTITY IRC_RECRUITING_3RD_PARTY_SITE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure DELETE_RECRUITING_SITE
  (p_validate                      in     boolean  default false
  ,p_recruiting_site_id            in     number
  ,p_object_version_number         in     number
  );
--
end IRC_RECRUITING_SITES_API;

/
