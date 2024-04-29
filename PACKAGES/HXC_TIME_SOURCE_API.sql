--------------------------------------------------------
--  DDL for Package HXC_TIME_SOURCE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIME_SOURCE_API" AUTHID CURRENT_USER as
/* $Header: hxchtsapi.pkh 120.1 2005/10/02 02:06:59 aroussel $ */
/*#
 * This package contains Time Source APIs.
 * @rep:scope public
 * @rep:product hxt
 * @rep:displayname Time Source
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_time_source >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This package creates Time Source.
 *
 * This API creates details of applications or devices that are registered to
 * deposit data into the Time Store.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The Time Source will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The Time Source will not be inserted and an application error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_time_source_id Primary Key from sequence.
 * @param p_object_version_number If P_VALIDATE is false, then the value is set
 * to the version number of the created Time Source. If P_VALIDATE is true,
 * then the value will be null.
 * @param p_name Name of Time Source.
 * @rep:displayname Create Time Source
 * @rep:category BUSINESS_ENTITY HXC_TIME_INPUT_SOURCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_time_source
  (p_validate                       in  boolean   default false
  ,p_time_source_id                 in  out nocopy hxc_time_sources.time_source_id%TYPE
  ,p_object_version_number          in  out nocopy hxc_time_sources.object_version_number%TYPE
  ,p_name                           in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_time_source >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an existing Time Source with a given name and application.
 *
 * This API updates DATA_APPROVAL_RULE.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * The Time Source must exist.
 *
 * <p><b>Post Success</b><br>
 * The Time Source will be updated successfully in the database.
 *
 * <p><b>Post Failure</b><br>
 * The Time Source will not be updated and an application error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_time_source_id Primary Key from sequence.
 * @param p_object_version_number Pass in the current version number of the
 * Time Source to be updated. When the API completes, if P_VALIDATE is false,
 * then the value will be set to the new version number of the updated Time
 * Source. If P_VALIDATE is true, then the value will be set to the same value.
 * @param p_name Name of Time Source.
 * @rep:displayname Update Time Source
 * @rep:category BUSINESS_ENTITY HXC_TIME_INPUT_SOURCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_time_source
  (p_validate                       in  boolean   default false
  ,p_time_source_id                 in  hxc_time_sources.time_source_id%TYPE
  ,p_object_version_number          in  out nocopy hxc_time_sources.object_version_number%TYPE
  ,p_name                           in     hxc_time_sources.name%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_time_source >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an existing Time Source.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * The Time Source must exist.
 *
 * <p><b>Post Success</b><br>
 * The Time Source will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The Time Source will not be deleted and an application error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_time_source_id Primary Key from sequence.
 * @param p_object_version_number Current version number of the Time Source to
 * be deleted.
 * @rep:displayname Delete Time Source
 * @rep:category BUSINESS_ENTITY HXC_TIME_INPUT_SOURCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_time_source
  (p_validate                       in  boolean  default false
  ,p_time_source_id                 in  hxc_time_sources.time_source_id%TYPE
  ,p_object_version_number          in  hxc_time_sources.object_version_number%TYPE
  );
--
--
END hxc_time_source_api;

 

/
