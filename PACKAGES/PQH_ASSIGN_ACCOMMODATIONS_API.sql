--------------------------------------------------------
--  DDL for Package PQH_ASSIGN_ACCOMMODATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ASSIGN_ACCOMMODATIONS_API" AUTHID CURRENT_USER as
/* $Header: pqasaapi.pkh 120.1 2005/10/02 02:25:29 aroussel $ */
/*#
 * This package contains APIs to create, update and delete an employee's
 * accommodation row.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Assign Accommodation for France
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_assign_accommodation >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new accommodation assignment, recording the employee
 * accommodated.
 *
 * API associates an employee to an accommodation starting from the effective
 * date.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Accommodation and the employee must exist as of the effective date.
 *
 * <p><b>Post Success</b><br>
 * A new accommodation assignment record is created in the database.
 *
 * <p><b>Post Failure</b><br>
 * An accommodation assignment record is not created in the database and an
 * error is raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the Date Track operation comes into
 * force
 * @param p_business_group_id Identifies the business group for which the
 * accommodation assignment is created
 * @param p_assignment_id Identifies the employee assignment to which the
 * accommodation is assigned. Must be a valid 'Employee' assignment as of the
 * effective date.
 * @param p_accommodation_given Flag denoting whether the employee is
 * accommodated or not.
 * @param p_temporary_assignment Flag denoting whether the accommodation is
 * being temporarily or permanently assigned. Valid values are identified by
 * lookup type 'PQH_ACCO_ASSIGN_TYPE'
 * @param p_accommodation_id Identifies the accommodation which is being
 * assigned. It references PQH_ACCOMMODATIONS_F table
 * @param p_acceptance_date Date on which the employee accepted the
 * accommodation assignment.
 * @param p_moving_date Date on which the employee will move in to the
 * accommodation.
 * @param p_refusal_date Date on which employee refused the accommodation
 * assignment.
 * @param p_comments Comment text
 * @param p_indemnity_entitlement Flag denoting whether the employee is
 * eligible to be paid the indemnity for accommodation.
 * @param p_indemnity_amount Indemnity amount to be paid to the employee, if
 * not accommodated.
 * @param p_type_of_payment Identifies the type of the payment. Value can only
 * be not null if accommodation_given parameter is set to false.
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_information1 Developer descriptive flexfield segment.
 * @param p_information2 Developer descriptive flexfield segment.
 * @param p_information3 Developer descriptive flexfield segment.
 * @param p_information4 Developer descriptive flexfield segment.
 * @param p_information5 Developer descriptive flexfield segment.
 * @param p_information6 Developer descriptive flexfield segment.
 * @param p_information7 Developer descriptive flexfield segment.
 * @param p_information8 Developer descriptive flexfield segment.
 * @param p_information9 Developer descriptive flexfield segment.
 * @param p_information10 Developer descriptive flexfield segment.
 * @param p_information11 Developer descriptive flexfield segment.
 * @param p_information12 Developer descriptive flexfield segment.
 * @param p_information13 Developer descriptive flexfield segment.
 * @param p_information14 Developer descriptive flexfield segment.
 * @param p_information15 Developer descriptive flexfield segment.
 * @param p_information16 Developer descriptive flexfield segment.
 * @param p_information17 Developer descriptive flexfield segment.
 * @param p_information18 Developer descriptive flexfield segment.
 * @param p_information19 Developer descriptive flexfield segment.
 * @param p_information20 Developer descriptive flexfield segment.
 * @param p_information21 Developer descriptive flexfield segment.
 * @param p_information22 Developer descriptive flexfield segment.
 * @param p_information23 Developer descriptive flexfield segment.
 * @param p_information24 Developer descriptive flexfield segment.
 * @param p_information25 Developer descriptive flexfield segment.
 * @param p_information26 Developer descriptive flexfield segment.
 * @param p_information27 Developer descriptive flexfield segment.
 * @param p_information28 Developer descriptive flexfield segment.
 * @param p_information29 Developer descriptive flexfield segment.
 * @param p_information30 Developer descriptive flexfield segment.
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
 * @param p_reason_for_no_acco Reason for not assigning accommodation to the
 * employee, for example, refusal or unavailable. Valid values are identified
 * by the lookup type 'PQH_ACC_REASON_FOR_NO_ACCO'. Value can only be not null
 * if accommodation_given parameter is set to false.
 * @param p_indemnity_currency Currency in terms of which indemnity amount is
 * provided. This references the FND_CURRENCIES table. Value can only be not
 * null if accommodation_given parameter is set to false.
 * @param p_assignment_acco_id The process returns the unique accommodation
 * assignment identifier generated for the new record
 * @param p_object_version_number If p_validate is false, the process returns
 * the version number of the created accommodation assignment record. If
 * p_validate is true, it returns null.
 * @param p_effective_start_date If p_validate is false, the process returns
 * the earliest effective start date for the accommodation assignment record
 * created. If p_validate is true, it returns null
 * @param p_effective_end_date If p_validate is false, the process returns the
 * effective end date for the created accommodation assignment record. If
 * p_validate is true, it returns null
 * @rep:displayname Create Accommodation Assignment
 * @rep:category BUSINESS_ENTITY PQH_EMPLOYEE_ACCOMMODATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_assign_accommodation
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_assignment_id                  in     number
  ,p_accommodation_given            in     varchar2
  ,p_temporary_assignment           in     varchar2 default null
  ,p_accommodation_id               in     number   default null
  ,p_acceptance_date                in     date     default null
  ,p_moving_date                    in     date     default null
  ,p_refusal_date                   in     date     default null
  ,p_comments                       in     varchar2 default null
  ,p_indemnity_entitlement          in     varchar2 default null
  ,p_indemnity_amount               in     number   default null
  ,p_type_of_payment                in     varchar2 default null
  ,p_information_category           in     varchar2 default null
  ,p_information1                   in     varchar2 default null
  ,p_information2                   in     varchar2 default null
  ,p_information3                   in     varchar2 default null
  ,p_information4                   in     varchar2 default null
  ,p_information5                   in     varchar2 default null
  ,p_information6                   in     varchar2 default null
  ,p_information7                   in     varchar2 default null
  ,p_information8                   in     varchar2 default null
  ,p_information9                   in     varchar2 default null
  ,p_information10                  in     varchar2 default null
  ,p_information11                  in     varchar2 default null
  ,p_information12                  in     varchar2 default null
  ,p_information13                  in     varchar2 default null
  ,p_information14                  in     varchar2 default null
  ,p_information15                  in     varchar2 default null
  ,p_information16                  in     varchar2 default null
  ,p_information17                  in     varchar2 default null
  ,p_information18                  in     varchar2 default null
  ,p_information19                  in     varchar2 default null
  ,p_information20                  in     varchar2 default null
  ,p_information21                  in     varchar2 default null
  ,p_information22                  in     varchar2 default null
  ,p_information23                  in     varchar2 default null
  ,p_information24                  in     varchar2 default null
  ,p_information25                  in     varchar2 default null
  ,p_information26                  in     varchar2 default null
  ,p_information27                  in     varchar2 default null
  ,p_information28                  in     varchar2 default null
  ,p_information29                  in     varchar2 default null
  ,p_information30                  in     varchar2 default null
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
  ,p_reason_for_no_acco             in     varchar2 default null
  ,p_indemnity_currency             in     varchar2 default null
  ,p_assignment_acco_id                out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_assign_accommodation >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API validates the record when an existing accommodation assignment is
 * changed and updates the record in the database.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The accommodation assignment record must exist with the specified object
 * version number.
 *
 * <p><b>Post Success</b><br>
 * The existing accommodation assignment record is updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The accommodation assignment is not updated in the database and an error is
 * raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the Date Track operation comes into
 * force
 * @param p_datetrack_mode Indicates which Date Track mode to use when updating
 * the record. It can either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT.Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change
 * @param p_assignment_acco_id Unique accommodation assignment identifier
 * generated for this record when created as primary key
 * @param p_object_version_number Passes the current version number of the
 * assign accommodation to be updated. When the API completes if p_validate is
 * false, the process returns the new version number of the updated assign
 * accommodation. If p_validate is true, it returns the same value which was
 * passed in
 * @param p_business_group_id Identifies the business group for which the
 * accommodation assignment is created
 * @param p_assignment_id Identifies the assignment for which the accommodation
 * assignment is created
 * @param p_accommodation_given Flag denoting whether the employee is
 * accommodated or not.
 * @param p_temporary_assignment Flag denoting whether the accommodation is
 * being temporarily or permanently assigned. Valid values are identified by
 * lookup type 'PQH_ACCO_ASSIGN_TYPE'
 * @param p_accommodation_id Identifies the accommodation which is being
 * assigned. It references PQH_ACCOMMODATIONS_F table
 * @param p_acceptance_date Date on which the employee accepted the
 * accommodation assignment.
 * @param p_moving_date Date on which the employee will move in to the
 * accommodation.
 * @param p_refusal_date Date on which employee refused the accommodation
 * assignment.
 * @param p_comments Comment text
 * @param p_indemnity_entitlement Flag denoting whether the employee is
 * eligible to be paid the indemnity for accommodation.
 * @param p_indemnity_amount Indemnity amount to be paid to the employee, if
 * not accommodated.
 * @param p_type_of_payment Identifies the type of the payment. Value can only
 * be not null if accommodation_given parameter is set to false.
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_information1 Developer descriptive flexfield segment.
 * @param p_information2 Developer descriptive flexfield segment.
 * @param p_information3 Developer descriptive flexfield segment.
 * @param p_information4 Developer descriptive flexfield segment.
 * @param p_information5 Developer descriptive flexfield segment.
 * @param p_information6 Developer descriptive flexfield segment.
 * @param p_information7 Developer descriptive flexfield segment.
 * @param p_information8 Developer descriptive flexfield segment.
 * @param p_information9 Developer descriptive flexfield segment.
 * @param p_information10 Developer descriptive flexfield segment.
 * @param p_information11 Developer descriptive flexfield segment.
 * @param p_information12 Developer descriptive flexfield segment.
 * @param p_information13 Developer descriptive flexfield segment.
 * @param p_information14 Developer descriptive flexfield segment.
 * @param p_information15 Developer descriptive flexfield segment.
 * @param p_information16 Developer descriptive flexfield segment.
 * @param p_information17 Developer descriptive flexfield segment.
 * @param p_information18 Developer descriptive flexfield segment.
 * @param p_information19 Developer descriptive flexfield segment.
 * @param p_information20 Developer descriptive flexfield segment.
 * @param p_information21 Developer descriptive flexfield segment.
 * @param p_information22 Developer descriptive flexfield segment.
 * @param p_information23 Developer descriptive flexfield segment.
 * @param p_information24 Developer descriptive flexfield segment.
 * @param p_information25 Developer descriptive flexfield segment.
 * @param p_information26 Developer descriptive flexfield segment.
 * @param p_information27 Developer descriptive flexfield segment.
 * @param p_information28 Developer descriptive flexfield segment.
 * @param p_information29 Developer descriptive flexfield segment.
 * @param p_information30 Developer descriptive flexfield segment.
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
 * @param p_reason_for_no_acco Describes the reason for not assigning
 * accommodation to the employee, for example, refusal or unavailable. Value
 * can only be not null if accommodation_given parameter is set to false. Valid
 * values are identified by the lookup type 'PQH_ACC_REASON_FOR_NO_ACCO'
 * @param p_indemnity_currency Currency in terms of which indemnity amount is
 * provided. Value can only be not null if accommodation_given parameter is set
 * to false.
 * @param p_effective_start_date If p_validate is false, the process returns
 * the earliest effective start date for the accommodation assignment record
 * updated. If p_validate is true, it returns null
 * @param p_effective_end_date If p_validate is false, the process returns the
 * effective end date for the updated accommodation assignment record. If
 * p_validate is true, the process returns null
 * @rep:displayname Update Accommodation Assignment
 * @rep:category BUSINESS_ENTITY PQH_EMPLOYEE_ACCOMMODATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_assign_accommodation
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_assignment_acco_id           in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_accommodation_given          in     varchar2  default hr_api.g_varchar2
  ,p_temporary_assignment         in     varchar2  default hr_api.g_varchar2
  ,p_accommodation_id             in     number    default hr_api.g_number
  ,p_acceptance_date              in     date      default hr_api.g_date
  ,p_moving_date                  in     date      default hr_api.g_date
  ,p_refusal_date                 in     date      default hr_api.g_date
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_indemnity_entitlement        in     varchar2  default hr_api.g_varchar2
  ,p_indemnity_amount             in     number    default hr_api.g_number
  ,p_type_of_payment              in     varchar2  default hr_api.g_varchar2
  ,p_information_category         in     varchar2  default hr_api.g_varchar2
  ,p_information1                 in     varchar2  default hr_api.g_varchar2
  ,p_information2                 in     varchar2  default hr_api.g_varchar2
  ,p_information3                 in     varchar2  default hr_api.g_varchar2
  ,p_information4                 in     varchar2  default hr_api.g_varchar2
  ,p_information5                 in     varchar2  default hr_api.g_varchar2
  ,p_information6                 in     varchar2  default hr_api.g_varchar2
  ,p_information7                 in     varchar2  default hr_api.g_varchar2
  ,p_information8                 in     varchar2  default hr_api.g_varchar2
  ,p_information9                 in     varchar2  default hr_api.g_varchar2
  ,p_information10                in     varchar2  default hr_api.g_varchar2
  ,p_information11                in     varchar2  default hr_api.g_varchar2
  ,p_information12                in     varchar2  default hr_api.g_varchar2
  ,p_information13                in     varchar2  default hr_api.g_varchar2
  ,p_information14                in     varchar2  default hr_api.g_varchar2
  ,p_information15                in     varchar2  default hr_api.g_varchar2
  ,p_information16                in     varchar2  default hr_api.g_varchar2
  ,p_information17                in     varchar2  default hr_api.g_varchar2
  ,p_information18                in     varchar2  default hr_api.g_varchar2
  ,p_information19                in     varchar2  default hr_api.g_varchar2
  ,p_information20                in     varchar2  default hr_api.g_varchar2
  ,p_information21                in     varchar2  default hr_api.g_varchar2
  ,p_information22                in     varchar2  default hr_api.g_varchar2
  ,p_information23                in     varchar2  default hr_api.g_varchar2
  ,p_information24                in     varchar2  default hr_api.g_varchar2
  ,p_information25                in     varchar2  default hr_api.g_varchar2
  ,p_information26                in     varchar2  default hr_api.g_varchar2
  ,p_information27                in     varchar2  default hr_api.g_varchar2
  ,p_information28                in     varchar2  default hr_api.g_varchar2
  ,p_information29                in     varchar2  default hr_api.g_varchar2
  ,p_information30                in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_reason_for_no_acco           in     varchar2  default hr_api.g_varchar2
  ,p_indemnity_currency           in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_assign_accommodation >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an accommodation assignment.
 *
 * Deleting the accommodation assignment makes the accommodation vacant and new
 * assignment can be created for a different employee.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The accommodation assignment must exist with the specified object version
 * number.
 *
 * <p><b>Post Success</b><br>
 * This accommodation assignment record is deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The accommodation assignment record is not deleted from the database and an
 * error is raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the Date Track operation comes into
 * force
 * @param p_datetrack_mode Indicates which Date Track mode to use when deleting
 * the record. It can be either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change
 * @param p_assignment_acco_id Unique assign accommodation identifier generated
 * for this record while created as Primary Key
 * @param p_object_version_number Current version number of the accommodation
 * record to be deleted
 * @param p_effective_start_date If p_validate is false, the process returns
 * the earliest effective start date for the accommodation assignment record
 * created. If p_validate is true, it returns null
 * @param p_effective_end_date If p_validate is false, the process returns the
 * effective end date for the created accommodation assignment record. If
 * p_validate is true, it returns null
 * @rep:displayname Delete Accommodation Assignment
 * @rep:category BUSINESS_ENTITY PQH_EMPLOYEE_ACCOMMODATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_assign_accommodation
  (p_validate                         in     boolean  default false
  ,p_effective_date                   in     date
  ,p_datetrack_mode                   in     varchar2
  ,p_assignment_acco_id               in     number
  ,p_object_version_number            in out nocopy number
  ,p_effective_start_date                out nocopy date
  ,p_effective_end_date                  out nocopy date
  );

--
end pqh_assign_accommodations_api;

 

/
