--------------------------------------------------------
--  DDL for Package HR_PERSON_DEPLOYMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_DEPLOYMENT_API" AUTHID CURRENT_USER as
/* $Header: hrpdtapi.pkh 120.5 2007/10/01 10:00:52 ghshanka noship $ */
/*#
 * This package contains global deployment APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Person Deployment
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_person_deployment >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new employee deployment record.
 *
 * The API creates a record that tracks a proposed period when an employee will
 * work in a different business group from the one the employee works in
 * presently. The status of the record will automatically be marked as DRAFT.
 * It will hold details that will be used in the assignment record in
 * the destination business group.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The employee must already exist in the specified business group. The
 * specified destination business group must already exist, and the assignment
 * information provided must be valid on the specified start date.
 *
 * <p><b>Post Success</b><br>
 * The deployment proposal is successfully created with a status of DRAFT.
 *
 * <p><b>Post Failure</b><br>
 * The deployment proposal is not inserted into the database and an error will
 * be raised
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_from_business_group_id Business group from which the employee is
 * coming. The employee must have an active period of service in this business
 * group.
 * @param p_to_business_group_id Business group in which the employee will be
 * working for this deployment.
 * @param p_from_person_id Identifies the person record in the source business
 * group.
 * @param p_to_person_id If specified, identifies the person record in the
 * destination business group which will track the deployment. If not
 * specified, indicated that a new person record will be created when the
 * deployment is initiated.
 * @param p_person_type_id The person type to be used for the person in the
 * destination business group when the deployment is initiated.
 * @param p_start_date The start date of the deployment.
 * @param p_end_date The end date of the deployment. Should be null for a
 * permanent deployment.
 * @param p_deployment_reason The reason for this deployment. Valid values must
 * exist in the HR_DEPLOYMENT_REASONS lookup type.
 * @param p_employee_number The employee number to be used for the person
 * record in the destination business group when the deployment is initiated.
 * @param p_leaving_reason The leaving reason to be used in the destination
 * business group when a temporary deployment is being ended. Should not be
 * entered for permanent deployments. Valid values must exist in the LEAV_REAS
 * lookup type.
 * @param p_leaving_person_type_id The person type of ex-employee to be used
 * in the destination business group when a temporary deployment is being
 * ended. Should not be entered for permanent deployments.
 * @param p_permanent Flag indicating whether the deployment is to be permanent
 * or temporary.
 * @param p_deplymt_policy_id This parameter is reserved for future releases.
 * Do not specify a value for this parameter.
 * @param p_organization_id The organization of the assignment to be created
 * in the destination business group when the deployment is initiated.
 * @param p_location_id The location of the assignment to be created
 * in the destination business group when the deployment is initiated.
 * @param p_job_id The job of the assignment to be created
 * in the destination business group when the deployment is initiated.
 * @param p_position_id The position of the assignment to be created
 * in the destination business group when the deployment is initiated.
 * @param p_grade_id The grade of the assignment to be created
 * in the destination business group when the deployment is initiated.
 * @param p_supervisor_id The supervisor of the assignment to be created
 * in the destination business group when the deployment is initiated.
 * @param p_supervisor_assignment_id The supervisor's assignment of the
 * assignment to be created in the destination business group
 * when the deployment is initiated.
 * @param p_retain_direct_reports Flag indicating whether the employee's
 * direct reports in the source business group need to be updated to the same
 * employee's record but in the destination business group. For permanent
 * deployments only.
 * @param p_payroll_id The payroll of the assignment to be created
 * in the destination business group when the deployment is initiated.
 * @param p_pay_basis_id The salary basis of the assignment to be created
 * in the destination business group when the deployment is initiated.
 * Do not enter a value for temporary deployments.
 * @param p_proposed_salary The salary of the assignment to be created
 * in the destination business group when the deployment is initiated.
 * Do not enter a value for temporary deployments.
 * @param p_people_group_id People Group key flexfield identifier for the
 * assignment to be created in the destination business group when the
 * deployment is initiated.
 * @param p_soft_coding_keyflex_id Soft Coded key flexfield identifier for the
 * assignment to be created in the destination business group when the
 * deployment is initiated.
 * @param p_assignment_status_type_id Assignment status of the assignment
 * to be created in the destination business group when the deployment
 * is initiated.
 * @param p_ass_status_change_reason Change reason to be recorded on the
 * assignment to be created in the destination business group when the
 * deployment is initiated. Valid values must exist in the EMP_ASSIGN_REASON
 * lookup type.
 * @param p_assignment_category Assignment category of the assignment
 * to be created in the destination business group when the deployment
 * is initiated.
 * @param p_per_information1 Developer descriptive flexfield segment.
 * @param p_per_information2 Developer descriptive flexfield segment.
 * @param p_per_information3 Developer descriptive flexfield segment.
 * @param p_per_information4 Developer descriptive flexfield segment.
 * @param p_per_information5 Developer descriptive flexfield segment.
 * @param p_per_information6 Developer descriptive flexfield segment.
 * @param p_per_information7 Developer descriptive flexfield segment.
 * @param p_per_information8 Developer descriptive flexfield segment.
 * @param p_per_information9 Developer descriptive flexfield segment.
 * @param p_per_information10 Developer descriptive flexfield segment.
 * @param p_per_information11 Developer descriptive flexfield segment.
 * @param p_per_information12 Developer descriptive flexfield segment.
 * @param p_per_information13 Developer descriptive flexfield segment.
 * @param p_per_information14 Developer descriptive flexfield segment.
 * @param p_per_information15 Developer descriptive flexfield segment.
 * @param p_per_information16 Developer descriptive flexfield segment.
 * @param p_per_information17 Developer descriptive flexfield segment.
 * @param p_per_information18 Developer descriptive flexfield segment.
 * @param p_per_information19 Developer descriptive flexfield segment.
 * @param p_per_information20 Developer descriptive flexfield segment.
 * @param p_per_information21 Developer descriptive flexfield segment.
 * @param p_per_information22 Developer descriptive flexfield segment.
 * @param p_per_information23 Developer descriptive flexfield segment.
 * @param p_per_information24 Developer descriptive flexfield segment.
 * @param p_per_information25 Developer descriptive flexfield segment.
 * @param p_per_information26 Developer descriptive flexfield segment.
 * @param p_per_information27 Developer descriptive flexfield segment.
 * @param p_per_information28 Developer descriptive flexfield segment.
 * @param p_per_information29 Developer descriptive flexfield segment.
 * @param p_per_information30 Developer descriptive flexfield segment.
 * @param p_person_deployment_id If p_validate is false, then this
 * uniquely identifies the deployment record created. If p_validate is true
 * then set to null.
 * @param p_object_version_number If p_validate is false, then set to
 * the version number of the created deployment. If p_validate is true,
 * then the value will be null.
 * @param p_policy_duration_warning In this release, always set to null.
 * @rep:displayname Create Person Deployment Proposal
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
--
procedure create_person_deployment
  (p_validate                      in     boolean    default false
  ,p_from_business_group_id        in     number
  ,p_to_business_group_id          in     number
  ,p_from_person_id                in     number
  ,p_to_person_id                  in     number     default null
  ,p_person_type_id                in     number     default null
  ,p_start_date                    in     date
  ,p_end_date                      in     date       default null
  ,p_deployment_reason             in     varchar2   default null
  ,p_employee_number               in     varchar2   default null
  ,p_leaving_reason                in     varchar2   default null
  ,p_leaving_person_type_id        in     number     default null
  ,p_permanent                     in     varchar2   default null
  ,p_deplymt_policy_id             in     number     default null
  ,p_organization_id               in     number
  ,p_location_id                   in     number     default null
  ,p_job_id                        in     number     default null
  ,p_position_id                   in     number     default null
  ,p_grade_id                      in     number     default null
  ,p_supervisor_id                 in     number     default null
  ,p_supervisor_assignment_id      in     number     default null
  ,p_retain_direct_reports         in     varchar2   default null
  ,p_payroll_id                    in     number     default null
  ,p_pay_basis_id                  in     number     default null
  ,p_proposed_salary               in     varchar2   default null
  ,p_people_group_id               in     number     default null
  ,p_soft_coding_keyflex_id        in     number     default null
  ,p_assignment_status_type_id     in     number     default null
  ,p_ass_status_change_reason      in     varchar2   default null
  ,p_assignment_category           in     varchar2   default null
  ,p_per_information1              in     varchar2   default null
  ,p_per_information2              in     varchar2   default null
  ,p_per_information3              in     varchar2   default null
  ,p_per_information4              in     varchar2   default null
  ,p_per_information5              in     varchar2   default null
  ,p_per_information6              in     varchar2   default null
  ,p_per_information7              in     varchar2   default null
  ,p_per_information8              in     varchar2   default null
  ,p_per_information9              in     varchar2   default null
  ,p_per_information10             in     varchar2   default null
  ,p_per_information11             in     varchar2   default null
  ,p_per_information12             in     varchar2   default null
  ,p_per_information13             in     varchar2   default null
  ,p_per_information14             in     varchar2   default null
  ,p_per_information15             in     varchar2   default null
  ,p_per_information16             in     varchar2   default null
  ,p_per_information17             in     varchar2   default null
  ,p_per_information18             in     varchar2   default null
  ,p_per_information19             in     varchar2   default null
  ,p_per_information20             in     varchar2   default null
  ,p_per_information21             in     varchar2   default null
  ,p_per_information22             in     varchar2   default null
  ,p_per_information23             in     varchar2   default null
  ,p_per_information24             in     varchar2   default null
  ,p_per_information25             in     varchar2   default null
  ,p_per_information26             in     varchar2   default null
  ,p_per_information27             in     varchar2   default null
  ,p_per_information28             in     varchar2   default null
  ,p_per_information29             in     varchar2   default null
  ,p_per_information30             in     varchar2   default null
  ,p_person_deployment_id             out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_policy_duration_warning          out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_person_deployment >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an existing employee deployment record.
 *
 * The API cannot be used to update the type of deployment or the source and
 * destination business groups.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources
 *
 * <p><b>Prerequisites</b><br>
 * The deployment record must already exist. The assignment information
 * provided must be valid on the deployment start date.
 *
 * <p><b>Post Success</b><br>
 * The deployment record will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The deployment record will not have been updated, and an error will
 * be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_deployment_id Identifies the deployment record to update.
 * @param p_object_version_number Pass in the current version number of the
 * deployment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated deployment.
 * If p_validate is true will be set to the same value which was passed in.
 * @param p_to_person_id If specified, identifies the person record in the
 * destination business group which will track the deployment. If not
 * specified, indicated that a new person record will be created when the
 * deployment is initiated.
 * @param p_person_type_id The person type to be used for the person in the
 * destination business group when the deployment is initiated.
 * @param p_start_date The start date of the deployment.
 * @param p_end_date The end date of the deployment. Should be null for a
 * permanent deployment.
 * @param p_deployment_reason The reason for this deployment. Valid values must
 * exist in the HR_DEPLOYMENT_REASONS lookup type.
 * @param p_employee_number The employee number to be used for the person
 * record in the destination business group when the deployment is initiated.
 * @param p_leaving_reason The leaving reason to be used in the destination
 * business group when a temporary deployment is being ended. Should not be
 * entered for permanent deployments. Valid values must exist in the LEAV_REAS
 * lookup type.
 * @param p_leaving_person_type_id The person type of ex-employee to be used
 * in the destination business group when a temporary deployment is being
 * ended. Should not be entered for permanent deployments.
 * @param p_status This parameter is reserved for future releases.
 * Do not specify a value for this parameter.
 * @param p_status_change_reason This parameter is reserved for future
 * releases.Do not specify a value for this parameter.
 * @param p_deplymt_policy_id This parameter is reserved for future releases.
 * Do not specify a value for this parameter.
 * @param p_organization_id The organization of the assignment to be created
 * in the destination business group when the deployment is initiated.
 * @param p_location_id The location of the assignment to be created
 * in the destination business group when the deployment is initiated.
 * @param p_job_id The job of the assignment to be created
 * in the destination business group when the deployment is initiated.
 * @param p_position_id The position of the assignment to be created
 * in the destination business group when the deployment is initiated.
 * @param p_grade_id The grade of the assignment to be created
 * in the destination business group when the deployment is initiated.
 * @param p_supervisor_id The supervisor of the assignment to be created
 * in the destination business group when the deployment is initiated.
 * @param p_supervisor_assignment_id The supervisor's assignment of the
 * assignment to be created in the destination business group
 * when the deployment is initiated.
 * @param p_retain_direct_reports Flag indicating whether the employee's
 * direct reports in the source business group need to be updated to the same
 * employee's record but in the destination business group. For permanent
 * deployments only.
 * @param p_payroll_id The payroll of the assignment to be created
 * in the destination business group when the deployment is initiated.
 * @param p_pay_basis_id The salary basis of the assignment to be created
 * in the destination business group when the deployment is initiated.
 * @param p_proposed_salary The salary of the assignment to be created
 * in the destination business group when the deployment is initiated.
 * Do not enter a value for temporary deployments.
 * @param p_people_group_id People Group key flexfield identifier for the
 * assignment to be created in the destination business group when the
 * deployment is initiated.
 * @param p_soft_coding_keyflex_id Soft Coded key flexfield identifier for the
 * assignment to be created in the destination business group when the
 * deployment is initiated.
 * @param p_assignment_status_type_id Assignment status of the assignment
 * to be created in the destination business group when the deployment
 * is initiated.
 * @param p_ass_status_change_reason Change reason to be recorded on the
 * assignment to be created in the destination business group when the
 * deployment is initiated. Valid values must exist in the EMP_ASSIGN_REASON
 * lookup type.
 * @param p_assignment_category Assignment category of the assignment
 * to be created in the destination business group when the deployment
 * is initiated.
 * @param p_per_information1 Developer descriptive flexfield segment.
 * @param p_per_information2 Developer descriptive flexfield segment.
 * @param p_per_information3 Developer descriptive flexfield segment.
 * @param p_per_information4 Developer descriptive flexfield segment.
 * @param p_per_information5 Developer descriptive flexfield segment.
 * @param p_per_information6 Developer descriptive flexfield segment.
 * @param p_per_information7 Developer descriptive flexfield segment.
 * @param p_per_information8 Developer descriptive flexfield segment.
 * @param p_per_information9 Developer descriptive flexfield segment.
 * @param p_per_information10 Developer descriptive flexfield segment.
 * @param p_per_information11 Developer descriptive flexfield segment.
 * @param p_per_information12 Developer descriptive flexfield segment.
 * @param p_per_information13 Developer descriptive flexfield segment.
 * @param p_per_information14 Developer descriptive flexfield segment.
 * @param p_per_information15 Developer descriptive flexfield segment.
 * @param p_per_information16 Developer descriptive flexfield segment.
 * @param p_per_information17 Developer descriptive flexfield segment.
 * @param p_per_information18 Developer descriptive flexfield segment.
 * @param p_per_information19 Developer descriptive flexfield segment.
 * @param p_per_information20 Developer descriptive flexfield segment.
 * @param p_per_information21 Developer descriptive flexfield segment.
 * @param p_per_information22 Developer descriptive flexfield segment.
 * @param p_per_information23 Developer descriptive flexfield segment.
 * @param p_per_information24 Developer descriptive flexfield segment.
 * @param p_per_information25 Developer descriptive flexfield segment.
 * @param p_per_information26 Developer descriptive flexfield segment.
 * @param p_per_information27 Developer descriptive flexfield segment.
 * @param p_per_information28 Developer descriptive flexfield segment.
 * @param p_per_information29 Developer descriptive flexfield segment.
 * @param p_per_information30 Developer descriptive flexfield segment.
 * @param p_policy_duration_warning In this release, always set to null.
 * @rep:displayname Update Person Deployment.
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_person_deployment
  (p_validate                      in     boolean    default false
  ,p_person_deployment_id          in     number
  ,p_object_version_number         in out nocopy number
  ,p_to_person_id                  in     number     default hr_api.g_number
  ,p_person_type_id                in     number     default hr_api.g_number
  ,p_start_date                    in     date       default hr_api.g_date
  ,p_end_date                      in     date       default hr_api.g_date
  ,p_deployment_reason             in     varchar2   default hr_api.g_varchar2
  ,p_employee_number               in     varchar2   default hr_api.g_varchar2
  ,p_leaving_reason                in     varchar2   default hr_api.g_varchar2
  ,p_leaving_person_type_id        in     number     default hr_api.g_number
  ,p_status                        in     varchar2   default hr_api.g_varchar2
  ,p_status_change_reason          in     varchar2   default hr_api.g_varchar2
  ,p_deplymt_policy_id             in     number     default hr_api.g_number
  ,p_organization_id               in     number     default hr_api.g_number
  ,p_location_id                   in     number     default hr_api.g_number
  ,p_job_id                        in     number     default hr_api.g_number
  ,p_position_id                   in     number     default hr_api.g_number
  ,p_grade_id                      in     number     default hr_api.g_number
  ,p_supervisor_id                 in     number     default hr_api.g_number
  ,p_supervisor_assignment_id      in     number     default hr_api.g_number
  ,p_retain_direct_reports         in     varchar2   default hr_api.g_varchar2
  ,p_payroll_id                    in     number     default hr_api.g_number
  ,p_pay_basis_id                  in     number     default hr_api.g_number
  ,p_proposed_salary               in     varchar2   default hr_api.g_varchar2
  ,p_people_group_id               in     number     default hr_api.g_number
  ,p_soft_coding_keyflex_id        in     number     default hr_api.g_number
  ,p_assignment_status_type_id     in     number     default hr_api.g_number
  ,p_ass_status_change_reason      in     varchar2   default hr_api.g_varchar2
  ,p_assignment_category           in     varchar2   default hr_api.g_varchar2
  ,p_per_information1              in     varchar2   default hr_api.g_varchar2
  ,p_per_information2              in     varchar2   default hr_api.g_varchar2
  ,p_per_information3              in     varchar2   default hr_api.g_varchar2
  ,p_per_information4              in     varchar2   default hr_api.g_varchar2
  ,p_per_information5              in     varchar2   default hr_api.g_varchar2
  ,p_per_information6              in     varchar2   default hr_api.g_varchar2
  ,p_per_information7              in     varchar2   default hr_api.g_varchar2
  ,p_per_information8              in     varchar2   default hr_api.g_varchar2
  ,p_per_information9              in     varchar2   default hr_api.g_varchar2
  ,p_per_information10             in     varchar2   default hr_api.g_varchar2
  ,p_per_information11             in     varchar2   default hr_api.g_varchar2
  ,p_per_information12             in     varchar2   default hr_api.g_varchar2
  ,p_per_information13             in     varchar2   default hr_api.g_varchar2
  ,p_per_information14             in     varchar2   default hr_api.g_varchar2
  ,p_per_information15             in     varchar2   default hr_api.g_varchar2
  ,p_per_information16             in     varchar2   default hr_api.g_varchar2
  ,p_per_information17             in     varchar2   default hr_api.g_varchar2
  ,p_per_information18             in     varchar2   default hr_api.g_varchar2
  ,p_per_information19             in     varchar2   default hr_api.g_varchar2
  ,p_per_information20             in     varchar2   default hr_api.g_varchar2
  ,p_per_information21             in     varchar2   default hr_api.g_varchar2
  ,p_per_information22             in     varchar2   default hr_api.g_varchar2
  ,p_per_information23             in     varchar2   default hr_api.g_varchar2
  ,p_per_information24             in     varchar2   default hr_api.g_varchar2
  ,p_per_information25             in     varchar2   default hr_api.g_varchar2
  ,p_per_information26             in     varchar2   default hr_api.g_varchar2
  ,p_per_information27             in     varchar2   default hr_api.g_varchar2
  ,p_per_information28             in     varchar2   default hr_api.g_varchar2
  ,p_per_information29             in     varchar2   default hr_api.g_varchar2
  ,p_per_information30             in     varchar2   default hr_api.g_varchar2
  ,p_policy_duration_warning          out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_person_deployment >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a deployment record.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The deployment record already exists and is in DRAFT or COMPLETE status.
 * If the deployment status is ACTIVE, the record cannot be deleted.
 *
 * <p><b>Post Success</b><br>
 * The deployment record is successfully removed from the database.
 *
 * <p><b>Post Failure</b><br>
 * The deployment is not deleted and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_deployment_id Identifies the deployment record to be
 * deleted.
 * @param p_object_version_number Current version number of the deployment
 * to be deleted.
 * @rep:displayname Delete Person Deployment
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_person_deployment
  (p_validate                      in     boolean    default false
  ,p_person_deployment_id          in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< initiate_deployment >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API initiates a deployment for an employee.
 *
 * If the person already exists in the destination business group, the API
 * converts the person to an employee. If the person does not exists, a new
 * employee is created. If the deployment is permanent, the employee record
 * in the source business group is terminated. If the deployment is temporary,
 * the assignments are suspended but the employee is not terminated.
 * If they exists, deployment EIT and deployment contact records are used to
 * create EITs and contacts in the destination business group.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The deployment record specified exists, and there does not exists another
 * deployment of ACTIVE status that overlaps the start or end dates.
 *
 * <p><b>Post Success</b><br>
 * The employee is created, or person converted to an employee, and assignment
 * is created in the destination business group. The employment is terminated
 * or assignmemts suspended in the source business group.
 *
 * <p><b>Post Failure</b><br>
 * The person and assignment records are not processed and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_deployment_id Identifies the deployment record to process.
 * @param p_object_version_number Pass in the current version number of the
 * deployment to be initiated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated deployment.
 * If p_validate is true will be set to the same value which was passed in.
 * @param p_host_person_id Identifes the person record created or updated
 * in the destination business group.
 * @param p_host_per_ovn If p_validate is false, then set to the version
 * number of the person created or updated in the destination business group.
 * If p_validate is true, then set to null.
 * @param p_host_assignment_id Identifies the assignment record that was
 * created in the destination business group for this deployment.
 * @param p_host_asg_ovn If p_validate is false, then set to the version
 * number of the assignment created or updated in the destination
 * business group. If p_validate is true, then set to null.
 * @param p_already_applicant_warning If set to true, then the person already
 * exists in the destination business group and has applicant records.
 * @rep:displayname Initiate Deployment
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure initiate_deployment
  (p_validate                      in     boolean    default false
  ,p_person_deployment_id          in     number
  ,p_object_version_number         in out   nocopy number
  ,p_host_person_id                     out nocopy number
  ,p_host_per_ovn                       out nocopy number
  ,p_host_assignment_id                 out nocopy number
  ,p_host_asg_ovn                       out nocopy number
  ,p_already_applicant_warning          out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< change_deployment_dates >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the start or end date of an active deployment.
 *
 * The API is used to keep synchronization between the start of the person
 * and assignment records in the destination business group and the suspension
 * of the assignments in the source business group.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The deployment exists, with status ACTIVE, and is a temporary deployment.
 *
 * <p><b>Post Success</b><br>
 * The person and assignment start dates in the destination business group are
 * changed and the date the source business group assignments are suspended
 * is changed.
 *
 * <p><b>Post Failure</b><br>
 * No changes are made to person or assignment records and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_deployment_id Identifies the deployment record to update.
 * @param p_object_version_number Pass in the current version number of the
 * deployment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated deployment.
 * @param p_start_date The new start date of the deployment.
 * @param p_end_date The new end date of the deployment.
 * @param p_deplymt_policy_id This parameter is reserved for future releases.
 * Do not specify a value for this parameter.
 * @rep:displayname Update Active Deployment Dates
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure change_deployment_dates
  (p_validate                      in     boolean    default false
  ,p_person_deployment_id          in     number
  ,p_object_version_number         in out nocopy     number
  ,p_start_date                    in     date       default hr_api.g_date
  ,p_end_date                      in     date       default hr_api.g_date
  ,p_deplymt_policy_id             in     number     default hr_api.g_number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< return_from_deployment >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API processes the return of an employee from a temporary deployment.
 *
 * The API terminates the employment in the destination business group and
 * activates the assignments in the source busineess group.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The deployment exists, is temporary, and has status of ACTIVE.
 *
 * <p><b>Post Success</b><br>
 * The employment is the destination business group is terminated successfully,
 * and the assignments in the source business group are activated.
 *
 * <p><b>Post Failure</b><br>
 * The database records are not updated and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_deployment_id Identifies the deployment record to initiate
 * the return.
 * @param p_object_version_number Pass in the current version number of the
 * deployment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated deployment.
 * @param p_end_date The end date of the deployment.
 * @param p_leaving_reason The leaving reason to use in the termination of the
 * employment in the destination business group.
 * Valid values must exist in the LEAV_REAS lookup type.
 * @param p_leaving_person_type_id The person type of ex-employee to be used
 * in the destination business group.
 * @rep:displayname Initiate Return from Deployment
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure return_from_deployment
  (p_validate                      in     boolean    default false
  ,p_person_deployment_id          in     number
  ,p_object_version_number         in out nocopy     number
  ,p_end_date                      in     date       default hr_api.g_date
  ,p_leaving_reason                in     varchar2   default hr_api.g_varchar2
  ,p_leaving_person_type_id        in     number     default hr_api.g_number
  );
--
end HR_PERSON_DEPLOYMENT_API;

/
