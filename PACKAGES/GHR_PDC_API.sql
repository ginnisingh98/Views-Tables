--------------------------------------------------------
--  DDL for Package GHR_PDC_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PDC_API" AUTHID CURRENT_USER AS
/* $Header: ghpdcapi.pkh 120.2 2005/10/02 01:58:10 aroussel $ */
/*#
 * This package contains the procedures for creating, updating, and deleting
 * GHR Position Description Classification records.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Position Description Classification
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< create_pdc >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the Position Description Classification.
 *
 * This API creates the Position Description Classification record in the
 * GHR_PD_CLASSIFICATIONS table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Position Description ID is passed
 *
 * <p><b>Post Success</b><br>
 * Position Description Classification is created.
 *
 * <p><b>Post Failure</b><br>
 * An application error is raised and processing is terminated
 * @param p_validate If true, then only validation is performed and the
 * database remains unchanged. If false, then all validation checks pass and
 * the database is modified.
 * @param p_pd_classification_id If p_validate is false, then this uniquely
 * identifies the Position Description Classification created. If p_validate is
 * true, then set to null.
 * @param p_position_description_id {@rep:casecolumn
 * GHR_POSITION_DESCRIPTIONS.POSITION_DESCRIPTION_ID}
 * @param p_class_grade_by Class grade by. Valid values are defined by
 * 'GHR_US_CLASS_GRADE_BY' lookup type.
 * @param p_official_title Official Title
 * @param p_pay_plan Pay Plan. Valid values are defined in the table
 * GHR_PAY_PLANS
 * @param p_occupational_code Occupational series. Valid values are defined by
 * 'GHR_US_OCC_SERIES' lookup code.
 * @param p_grade_level Grade or Level. Valid values are defined by
 * 'GHR_US_GRADE_OR_LEVEL' lookup type.
 * @param p_pdc_object_version_number If p_validate is false, then sets the
 * version number of the created Position Description Classification. If
 * p_validate is true, then the value is null.
 * @rep:displayname Create Position Description Classification
 * @rep:category BUSINESS_ENTITY GHR_POSITION_DESCRIPTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_pdc(
	p_validate IN BOOLEAN default false,
	p_pd_classification_id OUT NOCOPY ghr_pd_classifications.pd_classification_id%TYPE,
	p_position_description_id IN number,
	p_class_grade_by IN ghr_pd_classifications.class_grade_by%TYPE,
        p_official_title  IN ghr_pd_classifications.official_title%TYPE,
	p_pay_plan   IN  ghr_pd_classifications.pay_plan%TYPE,
	p_occupational_code IN ghr_pd_classifications.occupational_code%TYPE,
	p_grade_level	IN   ghr_pd_classifications.grade_level%TYPE,
	p_pdc_object_version_number out NOCOPY number);
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< update_pdc >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the Position Description Classification.
 *
 * This API updates the Position Description Classification record in the
 * GHR_PD_CLASSIFICATIONS table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Position Description ID is passed
 *
 * <p><b>Post Success</b><br>
 * Position Description Classification is updated.
 *
 * <p><b>Post Failure</b><br>
 * An application error is raised and processing is terminated
 * @param p_validate If true, then only validation is performed and the
 * database remains unchanged. If false, then all validation checks pass the
 * database is modified.
 * @param p_pd_classification_id Identifies the Position Description
 * Classification record to modify
 * @param p_position_description_id {@rep:casecolumn
 * GHR_POSITION_DESCRIPTIONS.POSITION_DESCRIPTION_ID}
 * @param p_class_grade_by Class grade by. Valid values are defined by
 * 'GHR_US_CLASS_GRADE_BY' lookup type.
 * @param p_official_title Official Title
 * @param p_pay_plan Pay Plan. Valid values are defined in the table
 * GHR_PAY_PLANS
 * @param p_occupational_code Occupational series. Valid values are defined by
 * 'GHR_US_OCC_SERIES' lookup code.
 * @param p_grade_level Grade or Level. Valid values are defined by
 * 'GHR_US_GRADE_OR_LEVEL' lookup type.
 * @param p_pdc_object_version_number Pass in the current version number of the
 * Position Description Classification that you are updating. When the API
 * completes, if p_validate is false, sets the new version number of the
 * updated Position Description Classification. If p_validate is true, sets the
 * same value passed in.
 * @rep:displayname Update Position Description Classification
 * @rep:category BUSINESS_ENTITY GHR_POSITION_DESCRIPTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_pdc
(
	p_validate IN BOOLEAN default false,
	p_pd_classification_id  IN ghr_pd_classifications.pd_classification_id%TYPE,
	p_position_description_id IN ghr_position_descriptions.position_description_id%TYPE,
	p_class_grade_by IN ghr_pd_classifications.class_grade_by%TYPE,
              p_official_title  IN ghr_pd_classifications.official_title%TYPE,
	p_pay_plan   IN  ghr_pd_classifications.pay_plan%TYPE,
	p_occupational_code IN ghr_pd_classifications.occupational_code%TYPE,
	p_grade_level	IN   ghr_pd_classifications.grade_level%TYPE,
	p_pdc_object_version_number in out NOCOPY number);
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< delete_pdc >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the Position Description Classification.
 *
 * This API deletes the Position Description Classification record from the
 * GHR_PD_CLASSIFICATIONS table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Position Description Classification ID is passed.
 *
 * <p><b>Post Success</b><br>
 * Position Description Classification is deleted.
 *
 * <p><b>Post Failure</b><br>
 * An application error is raised and processing is terminated
 * @param p_validate If true, then only validation is performed and the
 * database remains unchanged. If false, then all validation checks pass the
 * database is modified.
 * @param p_pd_classification_id Identifies the Position Description
 * Classification record to delete
 * @param p_pdc_object_version_number Current version number of the Position
 * Description Classification to be deleted.
 * @rep:displayname Delete Position Description Classification
 * @rep:category BUSINESS_ENTITY GHR_POSITION_DESCRIPTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE delete_pdc
(       p_validate IN BOOLEAN default false,
	p_pd_classification_id  IN ghr_pd_classifications.pd_classification_id%TYPE,
	p_pdc_object_version_number in  number);

end ghr_pdc_api;

 

/
