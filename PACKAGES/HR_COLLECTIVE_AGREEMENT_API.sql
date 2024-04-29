--------------------------------------------------------
--  DDL for Package HR_COLLECTIVE_AGREEMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_COLLECTIVE_AGREEMENT_API" AUTHID CURRENT_USER as
/* $Header: hrcagapi.pkh 120.3.12010000.2 2008/08/06 08:35:07 ubhat ship $ */
/*#
 * This package contains APIs which maintain collective agreements.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Collective Agreement
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< attach_plan_years >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
--   This procedure will attach plan years to the plan created for the
--   collective agreement.
--
-- Prerequisites:
--   This is a private function and can only be called from the api.
--
-- In Parameters:
--
--   effective date
--   business group id
--   plan id
--
-- Post Success:
--   Plan Years attached to plan.
--
-- Post Failure:
--   If the process fails a error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- ----------------------------------------------------------------------------
--
PROCEDURE attach_plan_years
  (p_effective_date    IN DATE
  ,p_business_group_id IN NUMBER
  ,p_pl_id             IN NUMBER);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_collective_agreement >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a collective agreement.
 *
 * A collective agreement is a set of terms and conditions of employment which
 * have been collectively agreed, usually through a process of negotiation, by
 * the parties which participate in the employment relationship. This normally
 * means that representatives of trades unions, employers and potentially
 * employees have formed a tri-partite body to specifically agree the terms of
 * employment. Collective agreements may be formed at various levels; they may
 * span multiple industries, or particular industries, or a specific industrial
 * sector, or they may even be specific to a particular employer or type of
 * employee within an industry. As such an employee or employer may be 'covered
 * by' multiple collective agreements at any one time.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The organizations and their signatories which are parties bound by this
 * collective agreement must exist on the effective date.
 *
 * <p><b>Post Success</b><br>
 * The collective agreement is created.
 *
 * <p><b>Post Failure</b><br>
 * The collective agreement is not created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_collective_agreement_id If p_validate is false, then this uniquely
 * identifies the collective agreement created. If p_validate is true, then set
 * to null.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id The business group of the record.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created collective agreement. If p_validate is true,
 * then the value will be null.
 * @param p_name The name of the collective agreement.
 * @param p_status Indicates whether the collective agreement is active or not.
 * Valid values are defined by the 'CAGR_STATUS' lookup type.
 * @param p_cag_number The reference number of the collective agreement.
 * @param p_description This description of the collective agreement in terms
 * of its purpose and the groups of people it covers.
 * @param p_end_date The date until which the collective agreement is in
 * effect.
 * @param p_employer_organization_id Uniquely identifies the employer
 * organization which agreed and is bound by this agreement.
 * @param p_employer_signatory The person who signed the agreement on behalf of
 * the employer.
 * @param p_bargaining_organization_id Uniquely identifies the bargaining
 * organization (trade union) which agreed and is bound by this agreement.
 * @param p_bargaining_unit_signatory The name of the person who signed the
 * agreement on behalf of bargaining unit.
 * @param p_jurisdiction The jurisdiction of the collective agreement.
 * @param p_authorizing_body The name of the public or official body which
 * authorized the agreement.
 * @param p_authorized_date The date the collective agreement was authorized by
 * the authorizing body.
 * @param p_cag_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_cag_information1 Developer Descriptive flexfield segment.
 * @param p_cag_information2 Developer Descriptive flexfield segment.
 * @param p_cag_information3 Developer Descriptive flexfield segment.
 * @param p_cag_information4 Developer Descriptive flexfield segment.
 * @param p_cag_information5 Developer Descriptive flexfield segment.
 * @param p_cag_information6 Developer Descriptive flexfield segment.
 * @param p_cag_information7 Developer Descriptive flexfield segment.
 * @param p_cag_information8 Developer Descriptive flexfield segment.
 * @param p_cag_information9 Developer Descriptive flexfield segment.
 * @param p_cag_information10 Developer Descriptive flexfield segment.
 * @param p_cag_information11 Developer Descriptive flexfield segment.
 * @param p_cag_information12 Developer Descriptive flexfield segment.
 * @param p_cag_information13 Developer Descriptive flexfield segment.
 * @param p_cag_information14 Developer Descriptive flexfield segment.
 * @param p_cag_information15 Developer Descriptive flexfield segment.
 * @param p_cag_information16 Developer Descriptive flexfield segment.
 * @param p_cag_information17 Developer Descriptive flexfield segment.
 * @param p_cag_information18 Developer Descriptive flexfield segment.
 * @param p_cag_information19 Developer Descriptive flexfield segment.
 * @param p_cag_information20 Developer Descriptive flexfield segment.
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
 * @rep:displayname Create Collective Agreement
 * @rep:category BUSINESS_ENTITY PER_COLLECTIVE_AGREEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_collective_agreement
  (p_validate                       in  boolean   default false
  ,p_collective_agreement_id        out nocopy number
  ,p_effective_date                 in  date
  ,p_business_group_id              in  number
  ,p_object_version_number          out nocopy number
  ,p_name                           in  varchar2
  ,p_status                         in  varchar2
  ,p_cag_number                     in  number    default null
  ,p_description                    in  varchar2  default null
  ,p_end_date                       in  date      default null
  ,p_employer_organization_id       in  number    default null
  ,p_employer_signatory             in  varchar2  default null
  ,p_bargaining_organization_id     in  number    default null
  ,p_bargaining_unit_signatory      in  varchar2  default null
  ,p_jurisdiction                   in  varchar2  default null
  ,p_authorizing_body               in  varchar2  default null
  ,p_authorized_date                in  date      default null
  ,p_cag_information_category       in  varchar2  default null
  ,p_cag_information1               in  varchar2  default null
  ,p_cag_information2               in  varchar2  default null
  ,p_cag_information3               in  varchar2  default null
  ,p_cag_information4               in  varchar2  default null
  ,p_cag_information5               in  varchar2  default null
  ,p_cag_information6               in  varchar2  default null
  ,p_cag_information7               in  varchar2  default null
  ,p_cag_information8               in  varchar2  default null
  ,p_cag_information9               in  varchar2  default null
  ,p_cag_information10              in  varchar2  default null
  ,p_cag_information11              in  varchar2  default null
  ,p_cag_information12              in  varchar2  default null
  ,p_cag_information13              in  varchar2  default null
  ,p_cag_information14              in  varchar2  default null
  ,p_cag_information15              in  varchar2  default null
  ,p_cag_information16              in  varchar2  default null
  ,p_cag_information17              in  varchar2  default null
  ,p_cag_information18              in  varchar2  default null
  ,p_cag_information19              in  varchar2  default null
  ,p_cag_information20              in  varchar2  default null
  ,p_attribute_category             in  varchar2  default null
  ,p_attribute1                     in  varchar2  default null
  ,p_attribute2                     in  varchar2  default null
  ,p_attribute3                     in  varchar2  default null
  ,p_attribute4                     in  varchar2  default null
  ,p_attribute5                     in  varchar2  default null
  ,p_attribute6                     in  varchar2  default null
  ,p_attribute7                     in  varchar2  default null
  ,p_attribute8                     in  varchar2  default null
  ,p_attribute9                     in  varchar2  default null
  ,p_attribute10                    in  varchar2  default null
  ,p_attribute11                    in  varchar2  default null
  ,p_attribute12                    in  varchar2  default null
  ,p_attribute13                    in  varchar2  default null
  ,p_attribute14                    in  varchar2  default null
  ,p_attribute15                    in  varchar2  default null
  ,p_attribute16                    in  varchar2  default null
  ,p_attribute17                    in  varchar2  default null
  ,p_attribute18                    in  varchar2  default null
  ,p_attribute19                    in  varchar2  default null
  ,p_attribute20                    in  varchar2  default null
  );
  /*
(
   p_validate                       in boolean    default false
  ,p_collective_agreement_id        out nocopy number
  ,p_effective_date                 in  date
  ,p_business_group_id              in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_name                           in  varchar2  default null
  ,p_status                         in  varchar2  default null
  ,p_cag_number                     in  number    default null
  ,p_description                    in  varchar2  default null
  ,p_end_date                       in  date      default null
  ,p_employer_organization_id       in  number    default null
  ,p_employer_signatory             in  varchar2  default null
  ,p_bargaining_organization_id     in  number    default null
  ,p_bargaining_unit_signatory      in  varchar2  default null
  ,p_jurisdiction                   in  varchar2  default null
  ,p_authorizing_body               in  varchar2  default null
  ,p_authorized_date                in  date      default null
  ,p_cag_information_category       in  varchar2  default null
  ,p_cag_information1               in  varchar2  default null
  ,p_cag_information2               in  varchar2  default null
  ,p_cag_information3               in  varchar2  default null
  ,p_cag_information4               in  varchar2  default null
  ,p_cag_information5               in  varchar2  default null
  ,p_cag_information6               in  varchar2  default null
  ,p_cag_information7               in  varchar2  default null
  ,p_cag_information8               in  varchar2  default null
  ,p_cag_information9               in  varchar2  default null
  ,p_cag_information10              in  varchar2  default null
  ,p_cag_information11              in  varchar2  default null
  ,p_cag_information12              in  varchar2  default null
  ,p_cag_information13              in  varchar2  default null
  ,p_cag_information14              in  varchar2  default null
  ,p_cag_information15              in  varchar2  default null
  ,p_cag_information16              in  varchar2  default null
  ,p_cag_information17              in  varchar2  default null
  ,p_cag_information18              in  varchar2  default null
  ,p_cag_information19              in  varchar2  default null
  ,p_cag_information20              in  varchar2  default null
  ,p_attribute_category             in  varchar2  default null
  ,p_attribute1                     in  varchar2  default null
  ,p_attribute2                     in  varchar2  default null
  ,p_attribute3                     in  varchar2  default null
  ,p_attribute4                     in  varchar2  default null
  ,p_attribute5                     in  varchar2  default null
  ,p_attribute6                     in  varchar2  default null
  ,p_attribute7                     in  varchar2  default null
  ,p_attribute8                     in  varchar2  default null
  ,p_attribute9                     in  varchar2  default null
  ,p_attribute10                    in  varchar2  default null
  ,p_attribute11                    in  varchar2  default null
  ,p_attribute12                    in  varchar2  default null
  ,p_attribute13                    in  varchar2  default null
  ,p_attribute14                    in  varchar2  default null
  ,p_attribute15                    in  varchar2  default null
  ,p_attribute16                    in  varchar2  default null
  ,p_attribute17                    in  varchar2  default null
  ,p_attribute18                    in  varchar2  default null
  ,p_attribute19                    in  varchar2  default null
  ,p_attribute20                    in  varchar2  default null
 ); */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_collective_agreement >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a collective agreement.
 *
 * A collective agreement is a set of terms and conditions of employment which
 * have been collectively agreed, usually through a process of negotiation, by
 * the parties which participate in the employment relationship. This normally
 * means that representatives of trades unions, employers and potentially
 * employees have formed a tri-partite body to specifically agree the terms of
 * employment. Collective agreements may be formed at various levels; they may
 * span multiple industries, or particular industries, or a specific industrial
 * sector, or they may even be specific to a particular employer or type of
 * employee within an industry. As such an employee or employer may be 'covered
 * by' multiple collective agreements at any one time.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The collective agreement to be updated must exist.
 *
 * <p><b>Post Success</b><br>
 * The collective agreement is updated.
 *
 * <p><b>Post Failure</b><br>
 * The collective agreement is not updated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_collective_agreement_id Uniquely identifies the collective
 * agreement to be updated.
 * @param p_business_group_id Business Group of Record
 * @param p_object_version_number Pass in the current version number of the
 * collective agreement to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated collective
 * agreement. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_name The name of the collective agreement.
 * @param p_status Indicates whether the collective agreement is active or not.
 * Valid values are defined by the 'CAGR_STATUS' lookup type.
 * @param p_cag_number The number of the collective agreement.
 * @param p_description This description of the collective agreement in terms
 * of its purpose and the groups of people it covers.
 * @param p_start_date The date upon which the collective agreement comes into
 * effect.
 * @param p_end_date The date until which the collective agreement is in
 * effect.
 * @param p_employer_organization_id Uniquely identifies the employer
 * organization which agreed and is bound by this agreement.
 * @param p_employer_signatory The person who signed the agreement on behalf of
 * the employer.
 * @param p_bargaining_organization_id Uniquely identifies the bargaining
 * organization (trade union) which is agreed and bound by this agreement.
 * @param p_bargaining_unit_signatory The name of the person who signed the
 * agreement on behalf of the bargaining unit.
 * @param p_jurisdiction The jurisdiction of the collective agreement.
 * @param p_authorizing_body The name of the public or official body which
 * authorized the agreement.
 * @param p_authorized_date The date the collective agreement was authorized by
 * the authorizing body.
 * @param p_cag_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_cag_information1 Developer Descriptive flexfield segment.
 * @param p_cag_information2 Developer Descriptive flexfield segment.
 * @param p_cag_information3 Developer Descriptive flexfield segment.
 * @param p_cag_information4 Developer Descriptive flexfield segment.
 * @param p_cag_information5 Developer Descriptive flexfield segment.
 * @param p_cag_information6 Developer Descriptive flexfield segment.
 * @param p_cag_information7 Developer Descriptive flexfield segment.
 * @param p_cag_information8 Developer Descriptive flexfield segment.
 * @param p_cag_information9 Developer Descriptive flexfield segment.
 * @param p_cag_information10 Developer Descriptive flexfield segment.
 * @param p_cag_information11 Developer Descriptive flexfield segment.
 * @param p_cag_information12 Developer Descriptive flexfield segment.
 * @param p_cag_information13 Developer Descriptive flexfield segment.
 * @param p_cag_information14 Developer Descriptive flexfield segment.
 * @param p_cag_information15 Developer Descriptive flexfield segment.
 * @param p_cag_information16 Developer Descriptive flexfield segment.
 * @param p_cag_information17 Developer Descriptive flexfield segment.
 * @param p_cag_information18 Developer Descriptive flexfield segment.
 * @param p_cag_information19 Developer Descriptive flexfield segment.
 * @param p_cag_information20 Developer Descriptive flexfield segment.
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
 * @rep:displayname Update Collective Agreement
 * @rep:category BUSINESS_ENTITY PER_COLLECTIVE_AGREEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_collective_agreement
  (
   p_validate                       in boolean    default false
  ,p_collective_agreement_id        in  number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_status                         in  varchar2  default hr_api.g_varchar2
  ,p_cag_number                     in  number    default hr_api.g_number
  ,p_description                    in  varchar2  default hr_api.g_varchar2
  ,p_start_date                     in  date      default hr_api.g_date
  ,p_end_date                       in  date      default hr_api.g_date
  ,p_employer_organization_id       in  number    default hr_api.g_number
  ,p_employer_signatory             in  varchar2  default hr_api.g_varchar2
  ,p_bargaining_organization_id     in  number    default hr_api.g_number
  ,p_bargaining_unit_signatory      in  varchar2  default hr_api.g_varchar2
  ,p_jurisdiction                   in  varchar2  default hr_api.g_varchar2
  ,p_authorizing_body               in  varchar2  default hr_api.g_varchar2
  ,p_authorized_date                in  date      default hr_api.g_date
  ,p_cag_information_category       in  varchar2  default hr_api.g_varchar2
  ,p_cag_information1               in  varchar2  default hr_api.g_varchar2
  ,p_cag_information2               in  varchar2  default hr_api.g_varchar2
  ,p_cag_information3               in  varchar2  default hr_api.g_varchar2
  ,p_cag_information4               in  varchar2  default hr_api.g_varchar2
  ,p_cag_information5               in  varchar2  default hr_api.g_varchar2
  ,p_cag_information6               in  varchar2  default hr_api.g_varchar2
  ,p_cag_information7               in  varchar2  default hr_api.g_varchar2
  ,p_cag_information8               in  varchar2  default hr_api.g_varchar2
  ,p_cag_information9               in  varchar2  default hr_api.g_varchar2
  ,p_cag_information10              in  varchar2  default hr_api.g_varchar2
  ,p_cag_information11              in  varchar2  default hr_api.g_varchar2
  ,p_cag_information12              in  varchar2  default hr_api.g_varchar2
  ,p_cag_information13              in  varchar2  default hr_api.g_varchar2
  ,p_cag_information14              in  varchar2  default hr_api.g_varchar2
  ,p_cag_information15              in  varchar2  default hr_api.g_varchar2
  ,p_cag_information16              in  varchar2  default hr_api.g_varchar2
  ,p_cag_information17              in  varchar2  default hr_api.g_varchar2
  ,p_cag_information18              in  varchar2  default hr_api.g_varchar2
  ,p_cag_information19              in  varchar2  default hr_api.g_varchar2
  ,p_cag_information20              in  varchar2  default hr_api.g_varchar2
  ,p_attribute_category             in  varchar2  default hr_api.g_varchar2
  ,p_attribute1                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute2                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute3                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute4                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute5                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute6                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute7                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute8                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute9                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute10                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute11                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute12                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute13                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute14                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute15                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute16                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute17                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute18                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute19                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute20                    in  varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_collective_agreement >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a collective agreement.
 *
 * A collective agreement is a set of terms and conditions of employment which
 * have been collectively agreed, usually through a process of negotiation, by
 * the parties which participate in the employment relationship. This normally
 * means that representatives of trades unions, employers and potentially
 * employees have formed a tri-partite body to specifically agree the terms of
 * employment. Collective agreements may be formed at various levels; they may
 * span multiple industries, or particular industries, or a specific industrial
 * sector, or they may even be specific to a particular employer or type of
 * employee within an industry. As such an employee or employer may be 'covered
 * by' multiple collective agreements at any one time.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The collective agreement to be deleted must exist.
 *
 * <p><b>Post Success</b><br>
 * The collective agreement is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The collective agreement is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_collective_agreement_id Uniquely identifies the collective
 * agreement to be deleted.
 * @param p_object_version_number Current version number of the collective
 * agreement to be deleted.
 * @rep:displayname Delete Collective Agreement
 * @rep:category BUSINESS_ENTITY PER_COLLECTIVE_AGREEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_collective_agreement
  (
   p_validate                       in boolean        default false
  ,p_collective_agreement_id        in  number
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_collective_agreement_id                 Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--
-- Post Success:
--
--   Name                           Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (
    p_collective_agreement_id                 in number
   ,p_object_version_number        in number
  );
--
end hr_collective_agreement_api;

/
