--------------------------------------------------------
--  DDL for Package HR_ELC_RESULT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ELC_RESULT_API" AUTHID CURRENT_USER as
/* $Header: peersapi.pkh 120.1 2005/10/02 02:16:48 aroussel $ */
/*#
 * This API updates the election candidate record with the election results and
 * creates roles for the candidates.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Election Result
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_election_result >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an election candidate role record with the results of an
 * election.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Election Candidate and supplementary role must exist.
 *
 * <p><b>Post Success</b><br>
 * Election candidate record updated with results.
 *
 * <p><b>Post Failure</b><br>
 * Election candidate record is not updated with results and error is returned.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_job_id Uniquely identifies the Supplementary Role of the candidate.
 * @param p_person_id Uniquely identifies the person (candidate) for whom the
 * process enters election results.
 * @param p_start_date Start date for the candidate's supplementary role.
 * @param p_end_date End date for the candidate's suupplementary role.
 * @param p_primary_contact_flag Flag specifying if this person is a primary
 * contact for the representative body.
 * @param p_election_candidate_id Uniquely identifies the election candidate
 * record the process updates with election results.
 * @param p_ovn_election_candidates Pass in the current version number of the
 * election candidate role record to be updated with election results. When the
 * API completes if p_validate is false, will be set to the new version number
 * of the updated election candidate role. If p_validate is true will be set to
 * the same value which was passed in.
 * @param p_business_group_id Uniquely identifies the business group associated
 * with the election candidate.
 * @param p_election_id Uniquely identifies the election for which the process
 * updates results.
 * @param p_rank The rank of the candidate in the election.
 * @param p_role_id If p_validate is false, then this uniquely identifies the
 * created role for the candidate. If p_validate is true, then set to null.
 * @param p_ovn_per_roles If p_validate is false, then set to the version
 * number of the created role for the candidate. If p_validate is true, then
 * the value will be null..
 * @rep:displayname Create Election Result
 * @rep:category BUSINESS_ENTITY PER_WORK_COUNCIL_ELECTION
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_election_result
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_job_id                        in     number
  ,p_person_id                     in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_primary_contact_flag          in     varchar2
  ,p_election_candidate_id         in     number
  ,p_ovn_election_candidates        in out nocopy number
  ,p_business_group_id             in     number
  ,p_election_id                   in     number
  ,p_rank                          in     number
  ,p_role_id                          out nocopy number
  ,p_ovn_per_roles           out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_election_result >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates election result information in an election candidate role
 * record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Election result must already exist.
 *
 * <p><b>Post Success</b><br>
 * Election Result updated.
 *
 * <p><b>Post Failure</b><br>
 * Election result not updated and error returned.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_role_id Uniquely identifies the candidate's supplementary role
 * (from per_roles).
 * @param p_ovn_per_roles Pass in the current version number of the per_roles
 * record to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated per_roles record. If p_validate
 * is true will be set to the same value which was passed in.
 * @param p_job_id Uniquely identifies the supplementary role of the candidate.
 * @param p_person_id Person ID of the election candidate.
 * @param p_start_date Start date for the candidate's supplementary role.
 * @param p_end_date End date for the candidate's suupplementary role.
 * @param p_primary_contact_flag Flag specifying if this person is a primary
 * contact for the representative body.
 * @param p_election_candidate_id Uniquely identifies the election candidate
 * record the process updates with election results.
 * @param p_business_group_id Uniquely identifies the business group associated
 * with the election candidate.
 * @param p_election_id Election id
 * @param p_ovn_election_candidates Pass in the current version number of the
 * election candidate role record to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * election candidate role record. If p_validate is true will be set to the
 * same value which was passed in..
 * @param p_rank Rank of the candidate in election.
 * @rep:displayname Update Election Result
 * @rep:category BUSINESS_ENTITY PER_WORK_COUNCIL_ELECTION
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_election_result
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_role_id                       in     number
  ,p_ovn_per_roles                 in out nocopy number
  ,p_job_id                        in     number   default hr_api.g_number
  ,p_person_id                     in     number   default hr_api.g_number
  ,p_start_date                    in     date     default hr_api.g_date
  ,p_end_date                      in     date     default hr_api.g_date
  ,p_primary_contact_flag          in     varchar2 default hr_api.g_varchar2
  ,p_election_candidate_id         in     number   default hr_api.g_number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_election_id                   in     number   default hr_api.g_number
  ,p_ovn_election_candidates       in out nocopy number
  ,p_rank                          in     number   default hr_api.g_number
  );
--
end hr_elc_result_api;

 

/
