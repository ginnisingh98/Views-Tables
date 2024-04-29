--------------------------------------------------------
--  DDL for Package HR_DE_ORGANIZATION_LINKS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DE_ORGANIZATION_LINKS_API" AUTHID CURRENT_USER as
/* $Header: hrordapi.pkh 120.1 2005/10/02 02:04:52 aroussel $ */
/*#
 * This package contains APIs to maintain organization links for Germany.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Organization Link for Germany
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< create_link >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an organization link for Germany.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The two organizations to be linked must exist.
 *
 * <p><b>Post Success</b><br>
 * The organization link is successfully created in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the organization link and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_parent_organization_id Parent organization.
 * @param p_child_organization_id Child organization.
 * @param p_org_link_type Type of organization link. Valid values exist in the
 * 'DE_LINK_TYPE' lookup type.
 * @param p_org_link_information_categor This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
 * @param p_org_link_information1 Developer descriptive flexfield segment.
 * @param p_org_link_information2 Developer descriptive flexfield segment.
 * @param p_org_link_information3 Developer descriptive flexfield segment.
 * @param p_org_link_information4 Developer descriptive flexfield segment.
 * @param p_org_link_information5 Developer descriptive flexfield segment.
 * @param p_org_link_information6 Developer descriptive flexfield segment.
 * @param p_org_link_information7 Developer descriptive flexfield segment.
 * @param p_org_link_information8 Developer descriptive flexfield segment.
 * @param p_org_link_information9 Developer descriptive flexfield segment.
 * @param p_org_link_information10 Developer descriptive flexfield segment.
 * @param p_org_link_information11 Developer descriptive flexfield segment.
 * @param p_org_link_information12 Developer descriptive flexfield segment.
 * @param p_org_link_information13 Developer descriptive flexfield segment.
 * @param p_org_link_information14 Developer descriptive flexfield segment.
 * @param p_org_link_information15 Developer descriptive flexfield segment.
 * @param p_org_link_information16 Developer descriptive flexfield segment.
 * @param p_org_link_information17 Developer descriptive flexfield segment.
 * @param p_org_link_information18 Developer descriptive flexfield segment.
 * @param p_org_link_information19 Developer descriptive flexfield segment.
 * @param p_org_link_information20 Developer descriptive flexfield segment.
 * @param p_org_link_information21 Developer descriptive flexfield segment.
 * @param p_org_link_information22 Developer descriptive flexfield segment.
 * @param p_org_link_information23 Developer descriptive flexfield segment.
 * @param p_org_link_information24 Developer descriptive flexfield segment.
 * @param p_org_link_information25 Developer descriptive flexfield segment.
 * @param p_org_link_information26 Developer descriptive flexfield segment.
 * @param p_org_link_information27 Developer descriptive flexfield segment.
 * @param p_org_link_information28 Developer descriptive flexfield segment.
 * @param p_org_link_information29 Developer descriptive flexfield segment.
 * @param p_org_link_information30 Developer descriptive flexfield segment.
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
 * @param p_organization_link_id If p_validate is false, then set to the
 * identifier of the organization link. If p_validate is true, then set to
 * nulll.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created organization link. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Organization Link for Germany
 * @rep:category BUSINESS_ENTITY HR_ORGANIZATION_LINK
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_link
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_parent_organization_id         in     number
  ,p_child_organization_id          in     number
  ,p_org_link_type                  in     varchar2
  ,p_org_link_information_categor   in     varchar2 default null
  ,p_org_link_information1          in     varchar2 default null
  ,p_org_link_information2          in     varchar2 default null
  ,p_org_link_information3          in     varchar2 default null
  ,p_org_link_information4          in     varchar2 default null
  ,p_org_link_information5          in     varchar2 default null
  ,p_org_link_information6          in     varchar2 default null
  ,p_org_link_information7          in     varchar2 default null
  ,p_org_link_information8          in     varchar2 default null
  ,p_org_link_information9          in     varchar2 default null
  ,p_org_link_information10         in     varchar2 default null
  ,p_org_link_information11         in     varchar2 default null
  ,p_org_link_information12         in     varchar2 default null
  ,p_org_link_information13         in     varchar2 default null
  ,p_org_link_information14         in     varchar2 default null
  ,p_org_link_information15         in     varchar2 default null
  ,p_org_link_information16         in     varchar2 default null
  ,p_org_link_information17         in     varchar2 default null
  ,p_org_link_information18         in     varchar2 default null
  ,p_org_link_information19         in     varchar2 default null
  ,p_org_link_information20         in     varchar2 default null
  ,p_org_link_information21         in     varchar2 default null
  ,p_org_link_information22         in     varchar2 default null
  ,p_org_link_information23         in     varchar2 default null
  ,p_org_link_information24         in     varchar2 default null
  ,p_org_link_information25         in     varchar2 default null
  ,p_org_link_information26         in     varchar2 default null
  ,p_org_link_information27         in     varchar2 default null
  ,p_org_link_information28         in     varchar2 default null
  ,p_org_link_information29         in     varchar2 default null
  ,p_org_link_information30         in     varchar2 default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_attribute21                    in     varchar2 default null
  ,p_attribute22                    in     varchar2 default null
  ,p_attribute23                    in     varchar2 default null
  ,p_attribute24                    in     varchar2 default null
  ,p_attribute25                    in     varchar2 default null
  ,p_attribute26                    in     varchar2 default null
  ,p_attribute27                    in     varchar2 default null
  ,p_attribute28                    in     varchar2 default null
  ,p_attribute29                    in     varchar2 default null
  ,p_attribute30                    in     varchar2 default null
  ,p_organization_link_id              out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< update_link >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an organization link for Germany.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The organization link record must exist.
 *
 * <p><b>Post Success</b><br>
 * The organization link is successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the organization link and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_organization_link_id Identifier of the organization link record to
 * be updated.
 * @param p_org_link_information_categor This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
 * @param p_org_link_information1 Developer descriptive flexfield segment.
 * @param p_org_link_information2 Developer descriptive flexfield segment.
 * @param p_org_link_information3 Developer descriptive flexfield segment.
 * @param p_org_link_information4 Developer descriptive flexfield segment.
 * @param p_org_link_information5 Developer descriptive flexfield segment.
 * @param p_org_link_information6 Developer descriptive flexfield segment.
 * @param p_org_link_information7 Developer descriptive flexfield segment.
 * @param p_org_link_information8 Developer descriptive flexfield segment.
 * @param p_org_link_information9 Developer descriptive flexfield segment.
 * @param p_org_link_information10 Developer descriptive flexfield segment.
 * @param p_org_link_information11 Developer descriptive flexfield segment.
 * @param p_org_link_information12 Developer descriptive flexfield segment.
 * @param p_org_link_information13 Developer descriptive flexfield segment.
 * @param p_org_link_information14 Developer descriptive flexfield segment.
 * @param p_org_link_information15 Developer descriptive flexfield segment.
 * @param p_org_link_information16 Developer descriptive flexfield segment.
 * @param p_org_link_information17 Developer descriptive flexfield segment.
 * @param p_org_link_information18 Developer descriptive flexfield segment.
 * @param p_org_link_information19 Developer descriptive flexfield segment.
 * @param p_org_link_information20 Developer descriptive flexfield segment.
 * @param p_org_link_information21 Developer descriptive flexfield segment.
 * @param p_org_link_information22 Developer descriptive flexfield segment.
 * @param p_org_link_information23 Developer descriptive flexfield segment.
 * @param p_org_link_information24 Developer descriptive flexfield segment.
 * @param p_org_link_information25 Developer descriptive flexfield segment.
 * @param p_org_link_information26 Developer descriptive flexfield segment.
 * @param p_org_link_information27 Developer descriptive flexfield segment.
 * @param p_org_link_information28 Developer descriptive flexfield segment.
 * @param p_org_link_information29 Developer descriptive flexfield segment.
 * @param p_org_link_information30 Developer descriptive flexfield segment.
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
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the updated link. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Update Organization Link for Germany
 * @rep:category BUSINESS_ENTITY HR_ORGANIZATION_LINK
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_link
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_organization_link_id           in     number
  ,p_org_link_information_categor   in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information1          in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information2          in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information3          in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information4          in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information5          in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information6          in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information7          in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information8          in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information9          in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information10         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information11         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information12         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information13         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information14         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information15         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information16         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information17         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information18         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information19         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information20         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information21         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information22         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information23         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information24         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information25         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information26         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information27         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information28         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information29         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information30         in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category             in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute21                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                    in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< delete_link >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an existing organization link for Germany.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The organization link record must exist.
 *
 * <p><b>Post Success</b><br>
 * The organization link record is successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the organization link and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_organization_link_id Unique identifier of the link record.
 * @param p_object_version_number Current version number of the link to be
 * deleted.
 * @rep:displayname Delete Organization Link for Germany
 * @rep:category BUSINESS_ENTITY HR_ORGANIZATION_LINK
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_link
  (p_validate                       in     boolean  default false
  ,p_organization_link_id           in     number
  ,p_object_version_number          in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------------< lck >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--   This API locks an existing organization link.
--
-- Prerequisites:
--
--   The organization link record must exist.
--
-- In Parameters:
--
--   Name                           Reqd Type     Description
--   p_organization_link_id         Yes  number   PK of the record.
--   p_object_version_number        Yes  number   OVN of the record.
--
-- Post Success:
--
--   When the organization link has been sucessfully locked, the
--   following out parameters are set:
--
--   Name                           Type     Description
--
-- Post Failure:
--
--   The API does not lock the organization link and raises an error.
--
-- Access Status:
--
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (p_organization_link_id           in     number
  ,p_object_version_number          in     number
  );
--
end hr_de_organization_links_api;

 

/
