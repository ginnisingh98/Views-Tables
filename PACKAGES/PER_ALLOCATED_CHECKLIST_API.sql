--------------------------------------------------------
--  DDL for Package PER_ALLOCATED_CHECKLIST_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ALLOCATED_CHECKLIST_API" AUTHID CURRENT_USER as
/* $Header: pepacapi.pkh 120.2 2005/12/13 03:15:03 lsilveir noship $ */
/*#
 * This package contains APIs for maintaining allocated checklists.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Allocated Checklist
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_alloc_checklist >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new allocated checklist. These are checklists that are
 * attached to a person or an assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * A valid person ID must be passed in to the API. Additionally an optional
 * assignment ID can be passed in.
 *
 * <p><b>Post Success</b><br>
 * The API creates the allocated checklist successfully in the database.
 *
 * <p><b>Post Failure</b><br>
 * The allocated checklist is not created in the database and an error is
 * raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date The date on which the checklist is allocated.
 * @param p_checklist_id The setup checklist used to build this allocated
 * checklist.
 * @param p_person_id The person to whom this checklist is to be allocated.
 * @param p_assignment_id The assignment to which this checklist is to be
 * allocated.
 * @param p_checklist_name The allocated checklist name.
 * @param p_description The allocated checklist description.
 * @param p_checklist_category The checklist category.
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
 * @param p_allocated_checklist_id If p_validate is false, then this
 * uniquely identifies the allocated checklist created. If p_validate
 * is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created allocated checklist. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Allocated Checklist
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:category BUSINESS_ENTITY PER_CWK
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure CREATE_ALLOC_CHECKLIST
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_checklist_id                  in     number   default null
  ,p_person_id                     in     number
  ,p_assignment_id                 in     number   default null
  ,p_checklist_name                in     varchar2 default null
  ,p_description                   in     varchar2 default null
  ,p_checklist_category            in     varchar2 default null
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
  ,p_information_category          in     varchar2 default null
  ,p_information1                  in     varchar2 default null
  ,p_information2                  in     varchar2 default null
  ,p_information3                  in     varchar2 default null
  ,p_information4                  in     varchar2 default null
  ,p_information5                  in     varchar2 default null
  ,p_information6                  in     varchar2 default null
  ,p_information7                  in     varchar2 default null
  ,p_information8                  in     varchar2 default null
  ,p_information9                  in     varchar2 default null
  ,p_information10                 in     varchar2 default null
  ,p_information11                 in     varchar2 default null
  ,p_information12                 in     varchar2 default null
  ,p_information13                 in     varchar2 default null
  ,p_information14                 in     varchar2 default null
  ,p_information15                 in     varchar2 default null
  ,p_information16                 in     varchar2 default null
  ,p_information17                 in     varchar2 default null
  ,p_information18                 in     varchar2 default null
  ,p_information19                 in     varchar2 default null
  ,p_information20                 in     varchar2 default null
  ,p_allocated_checklist_id        out nocopy   number
  ,p_object_version_number         out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_alloc_checklist >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an existing Allocated Checklist. These are checklists that
 * are attached to a person or an assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The allocated checklist that is to be updated must already exist.
 *
 * <p><b>Post Success</b><br>
 * The API updates the allocated checklist successfully in the database.
 *
 * <p><b>Post Failure</b><br>
 * The allocated checklist is not updated in the database and an error is
 * raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date The date on which the allocated checklist is
 * updated.
 * @param p_allocated_checklist_id Identifies the allocated checklist to
 * be updated.
 * @param p_checklist_id The setup checklist used to build this checklist.
 * @param p_person_id The person to whom this checklist is allocated.
 * @param p_assignment_id The assignment to which this checklist is allocated.
 * @param p_checklist_name The allocated checklist name.
 * @param p_description The allocated checklist description.
 * @param p_checklist_category The checklist category.
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
 * @param p_object_version_number Pass in the current version number of the
 * allocated checklist to be updated. When the API completes if p_validate
 * is false, it will be set to the new version number of the updated allocated
 * checklist. If p_validate is true it will be set to the same value which was
 * passed in.
 * @rep:displayname Update Allocated Checklist
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:category BUSINESS_ENTITY PER_CWK
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure UPDATE_ALLOC_CHECKLIST
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_allocated_checklist_id        in     number
  ,p_checklist_id                  in     number default null
  ,p_person_id                     in     number default null
  ,p_assignment_id                 in     number default null
  ,p_checklist_name                in     varchar2 default null
  ,p_description                   in     varchar2 default null
  ,p_checklist_category            in     varchar2 default null
--
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
  ,p_information_category          in     varchar2 default null
  ,p_information1                  in     varchar2 default null
  ,p_information2                  in     varchar2 default null
  ,p_information3                  in     varchar2 default null
  ,p_information4                  in     varchar2 default null
  ,p_information5                  in     varchar2 default null
  ,p_information6                  in     varchar2 default null
  ,p_information7                  in     varchar2 default null
  ,p_information8                  in     varchar2 default null
  ,p_information9                  in     varchar2 default null
  ,p_information10                 in     varchar2 default null
  ,p_information11                 in     varchar2 default null
  ,p_information12                 in     varchar2 default null
  ,p_information13                 in     varchar2 default null
  ,p_information14                 in     varchar2 default null
  ,p_information15                 in     varchar2 default null
  ,p_information16                 in     varchar2 default null
  ,p_information17                 in     varchar2 default null
  ,p_information18                 in     varchar2 default null
  ,p_information19                 in     varchar2 default null
  ,p_information20                 in     varchar2 default null
  ,p_object_version_number         in out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_alloc_checklist >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an existing Allocated Checklist. These are checklists that
 * are attached to a person or an assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The allocated checklist that is to be deleted must already exist.
 *
 * <p><b>Post Success</b><br>
 * The API deletes the allocated checklist successfully from the database.
 *
 * <p><b>Post Failure</b><br>
 * The allocated checklist is not deleted from the database and an error is
 * raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_allocated_checklist_id Identifies the allocated checklist to be
 * deleted.
 * @param p_object_version_number Current version number of the allocated
 * checklist to be deleted.
 * @rep:displayname Delete Allocated Checklist.
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:category BUSINESS_ENTITY PER_CWK
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure DELETE_ALLOC_CHECKLIST
  (p_validate                      in     boolean  default false
  ,p_allocated_checklist_id        in     number
  ,p_object_version_number         in     number
  );


end PER_ALLOCATED_CHECKLIST_API;

 

/
