--------------------------------------------------------
--  DDL for Package GHR_DUTY_STATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_DUTY_STATION_API" AUTHID CURRENT_USER as
/* $Header: ghdutapi.pkh 120.1 2005/10/02 01:57:45 aroussel $ */
/*#
 * This package contains Duty Station APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Duty Station
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_duty_station >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new Duty Station.
 *
 * This API Inserts a Duty Station record in the ghr_duty_stations_f table. If
 * p_validate is set to false, it inserts a new record into the table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The State or Country code and the County code must be present to create a
 * new duty station. Before creating a duty station, the user should confirm
 * that the corresponding State or Country code and the County code exist in
 * the ghr_duty_stations_f table. For non-US duty stations, the State or
 * Country code and the County code are the same. Also, the locality pay area
 * should be present in ghr_locality_pay_areas_f as of the duty station
 * creation effective date.
 *
 * <p><b>Post Success</b><br>
 * The Duty Station record is successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The Duty Station record is not created and the process raises an error
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_duty_station_id {@rep:casecolumn
 * GHR_DUTY_STATIONS_F.DUTY_STATION_ID}
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created duty station. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created duty station. If p_validate is true, then
 * set to null.
 * @param p_locality_pay_area_id {@rep:casecolumn
 * GHR_DUTY_STATIONS_F.LOCALITY_PAY_AREA_ID}
 * @param p_leo_pay_area_code {@rep:casecolumn
 * GHR_DUTY_STATIONS_F.LEO_PAY_AREA_CODE}
 * @param p_name {@rep:casecolumn GHR_DUTY_STATIONS_F.NAME}
 * @param p_duty_station_code {@rep:casecolumn
 * GHR_DUTY_STATIONS_F.DUTY_STATION_CODE}
 * @param p_msa_code {@rep:casecolumn GHR_DUTY_STATIONS_F.MSA_CODE}
 * @param p_cmsa_code {@rep:casecolumn GHR_DUTY_STATIONS_F.CMSA_CODE}
 * @param p_state_or_country_code State or Country code, first 2 characters of
 * duty station code.
 * @param p_county_code {@rep:casecolumn GHR_DUTY_STATIONS_F.COUNTY_CODE}
 * @param p_is_duty_station Indicates if row is a Duty Station. If code only
 * contains a State code, it is not a Duty Station.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Duty Station. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Duty Station
 * @rep:category BUSINESS_ENTITY GHR_DUTY_STATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_duty_station
  (p_validate                      in  boolean   default false
  ,p_duty_station_id 	           OUT nocopy number
  ,p_effective_start_date          out nocopy date
  ,p_effective_end_date            out nocopy date
  ,p_locality_pay_area_id          in  number
  ,p_leo_pay_area_code             in  varchar2 default null
  ,p_name                          in  varchar2 default null
  ,p_duty_station_code             in  varchar2
  ,p_msa_code                      in  varchar2 default null
  ,p_cmsa_code                     in  varchar2 default null
  ,p_state_or_country_code         in  varchar2
  ,p_county_code                   in  varchar2 default null
  ,p_is_duty_station               in  varchar2 default 'Y'
  ,p_effective_date                in  date
  ,p_object_version_number        out  nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_duty_station >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the modified Duty Station details.
 *
 * This API updates Name, CMSA_code, MSA_code, Locality_pay_area_id,
 * Leo_pay_area_id, Is_duty_station flag of an existing Duty Station record.
 * The DateTrack mode determines how the process updates the rows.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Duty Station record should exists as of the effective date.
 *
 * <p><b>Post Success</b><br>
 * The API updates the modified Duty Station details.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Duty Station record and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_duty_station_id {@rep:casecolumn
 * GHR_DUTY_STATIONS_F.DUTY_STATION_ID}
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated duty station row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated duty station row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_locality_pay_area_id {@rep:casecolumn
 * GHR_DUTY_STATIONS_F.LOCALITY_PAY_AREA_ID}
 * @param p_leo_pay_area_code {@rep:casecolumn
 * GHR_DUTY_STATIONS_F.LEO_PAY_AREA_CODE}
 * @param p_name {@rep:casecolumn GHR_DUTY_STATIONS_F.NAME}
 * @param p_duty_station_code {@rep:casecolumn
 * GHR_DUTY_STATIONS_F.DUTY_STATION_CODE}
 * @param p_msa_code {@rep:casecolumn GHR_DUTY_STATIONS_F.MSA_CODE}
 * @param p_cmsa_code {@rep:casecolumn GHR_DUTY_STATIONS_F.CMSA_CODE}
 * @param p_state_or_country_code State or Country code, first 2 characters of
 * duty station code.
 * @param p_county_code {@rep:casecolumn GHR_DUTY_STATIONS_F.COUNTY_CODE}
 * @param p_is_duty_station Indicates if row is a Duty Station. If code only
 * contains a State code, it is not a Duty Station.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_object_version_number Pass in the current version number of the
 * duty station to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated duty station. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Duty Station
 * @rep:category BUSINESS_ENTITY GHR_DUTY_STATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_duty_station
  (p_validate                      in     boolean  default false
  ,p_duty_station_id 	           in  number
  ,p_effective_start_date          out nocopy date
  ,p_effective_end_date            out nocopy  date
  ,p_locality_pay_area_id          in  number
  ,p_leo_pay_area_code             in  varchar2 default hr_api.g_varchar2
  ,p_name                          in  varchar2 default hr_api.g_varchar2
  ,p_duty_station_code             in  varchar2
  ,p_msa_code                      in varchar2
  ,p_cmsa_code                     in varchar2
  ,p_state_or_country_code         in varchar2
  ,p_county_code                   in varchar2
  ,p_is_duty_station               in  varchar2 default hr_api.g_varchar2
  ,p_effective_date                in  date
  ,p_datetrack_update_mode	   in  varchar2
  ,p_object_version_number       IN out nocopy number
   );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_duty_station >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API end dates the existing Duty Station record.
 *
 * This API allows DateTrack modes other than ZAP. This process allows users
 * only to end date, not purge duty stations.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * To end date a Duty Station, ensure that no active assignments containing a
 * Location with the Duty Station exist after the Duty Station end date. If
 * active assignments exist, delete them before end dating the Duty Station
 * record.
 *
 * <p><b>Post Success</b><br>
 * The Duty Station record is end dated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not end date the Duty Station record and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_duty_station_id {@rep:casecolumn
 * GHR_DUTY_STATIONS_F.DUTY_STATION_ID}
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the Deleted Duty Station row which now exists as of
 * the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective End Date for the deleted Duty Station row which now exists as of
 * the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @param p_object_version_number Current version number of the Duty Station to
 * be deleted.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when deleting
 * the record. You must set to either DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @rep:displayname Delete Existing Duty Station
 * @rep:category BUSINESS_ENTITY GHR_DUTY_STATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_duty_station
  (p_validate                      in     boolean  default false
  ,p_duty_station_id               in     number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number         in     number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  );
end ghr_duty_station_api;

 

/
