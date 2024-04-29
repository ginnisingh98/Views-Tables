--------------------------------------------------------
--  DDL for Package OTA_THG_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_THG_API" AUTHID CURRENT_USER as
/* $Header: otthgapi.pkh 120.1 2005/10/02 02:08:19 aroussel $ */
/*#
 * This API maintains the detail mappings between Oracle General Ledger's Chart
 * of Account keyflex segments and Oracle Human Resources Cost Allocation
 * keyflex segments.
 * @rep:scope public
 * @rep:product ota
 * @rep:displayname General Ledger Flexfield
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_hr_gl_flex >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates details that enable internal cross charging by mapping
 * Chart of Account details from Oracle General Ledger to Oracle Human
 * Resources.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The Chart of Account Keyflex segments and Cost Allocations keyflex segments
 * should exist.
 *
 * <p><b>Post Success</b><br>
 * The details to enable cross charging will be created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the mapping, and raises an error.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_cross_charge_id Foreign key to OTA_CROSS_CHARGES.
 * @param p_segment Name of the segment in the accounting flexfield structure
 * to which this record applies.
 * @param p_segment_num Number of the segment in the accounting flexfield
 * structure to which this record is applied.
 * @param p_hr_data_source Name of the table on which this segment is based.
 * @param p_constant Constant value for this segment.
 * @param p_hr_cost_segment Cost Segment from Pay Cost Allocation Keyflex.
 * @param p_gl_default_segment_id If p_validate is false, then this uniquely
 * identifies the mapping created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created mapping. If p_validate is true, then the value
 * will be null.
 * @param p_validate If true, then only validation will be performed and the
 * database remains unchanged. If false, then all validation checks pass and
 * the database will be modified.
 * @rep:displayname Create HR General Ledger Flexfield
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_CROSS_CHARGE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_hr_gl_flex
  (p_effective_date               in     date
  ,p_cross_charge_id              in     number
  ,p_segment                      in     varchar2
  ,p_segment_num                  in     number
  ,p_hr_data_source               in     varchar2 default null
  ,p_constant                     in     varchar2 default null
  ,p_hr_cost_segment              in     varchar2 default null
  ,p_gl_default_segment_id             out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_validate                     in     boolean    default false
);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_hr_gl_flex >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates details that enable internal cross charging by mapping
 * Chart of Account details from Oracle General Ledger to Oracle Human
 * Resources.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The mapping between Chart of Account details from Oracle General Ledger to
 * Oracle Human Resources should exist.
 *
 * <p><b>Post Success</b><br>
 * The mapping is successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the mapping details, and raises an error.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_gl_default_segment_id This parameter uniquely identifies the record
 * being updated.
 * @param p_object_version_number Pass in the current version number of the
 * mapping detail to be updated. When the API completes, if p_validate is
 * false, will be set to the new version number of the updated mapping detail.
 * If p_validate is true will be set to the same value which is passed in.
 * @param p_cross_charge_id Foreign key to OTA_CROSS_CHARGES.
 * @param p_segment Name of the segment in the accounting flexfield structure
 * to which this record applies.
 * @param p_segment_num Number of the segment in the accounting flexfield
 * structure to which this record applies.
 * @param p_hr_data_source Name of the table on which this segment is based.
 * @param p_constant Constant value for this segment.
 * @param p_hr_cost_segment Cost Segment from Pay Cost Allocation Keyflex.
 * @param p_validate If true, then only validation will be performed and the
 * database remains unchanged. If false, then all validation checks pass and
 * the database will be modified.
 * @rep:displayname Update HR General Ledger Flexfield
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_CROSS_CHARGE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_hr_gl_flex
  (p_effective_date               in     date
  ,p_gl_default_segment_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_cross_charge_id              in     number    default hr_api.g_number
  ,p_segment                      in     varchar2  default hr_api.g_varchar2
  ,p_segment_num                  in     number    default hr_api.g_number
  ,p_hr_data_source               in     varchar2  default hr_api.g_varchar2
  ,p_constant                     in     varchar2  default hr_api.g_varchar2
  ,p_hr_cost_segment              in     varchar2  default hr_api.g_varchar2
  ,p_validate                     in     boolean    default false
  );


end OTA_THG_API;

 

/
