--------------------------------------------------------
--  DDL for Package HR_DFLEX_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DFLEX_UTILITY" AUTHID CURRENT_USER as
/* $Header: hrdfutil.pkh 120.0.12000000.1 2007/01/22 14:46:18 appldev ship $ */
--
--
-- Package Variables
--
-- ----------------------------------------------------------------------------
-- |       create varray for ignore descriptive flex field validation         |
-- ----------------------------------------------------------------------------
--
type l_ignore_dfcode_varray is varray(30) of varchar2(40);
procedure create_ignore_df_validation(p_rec in out nocopy l_ignore_dfcode_varray);
--
-------------------------------------------------------------------------------
-- |    check ignore array with descriptive flex currently being processed    |
-------------------------------------------------------------------------------
--
function check_ignore_df_varray(p_structure in varchar2) return boolean;
--
-------------------------------------------------------------------------------
-- |                              clear varray                                |
-------------------------------------------------------------------------------
--
procedure remove_ignore_df_validation;
--
-- ----------------------------------------------------------------------------
-- |---------------------< ins_or_upd_descflex_attribs >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure can be called by any row handler which involves the
--   insert/update of descriptive flexfield or developer descriptive attributes
--   for a given entity.
--
--   For each DF or DDF column both the column name and the value should be
--   provided. The order in which these columns are provided is not significant
--   and does not have to correspond to database table ordering.
--
-- Prerequisites:
--   A valid appl_short_name (application short name)
--   A valid desc_flex_name  (a valid descriptive flexfield)
--   Valid descriptive flexfield structure information has been defined frozen and
--   compiled.
--
-- In Parameters:
--   Name                    Reqd Type     Description
--   ====                    ==== ====     ===========
--   p_appl_short_name       Yes  varchar2 Name of application descriptive flex structure
--                                         is linked to
--   p_descflex_name         Yes  varchar2 Descriptive flexfield name
--   p_attribute_category    Yes  varchar2 Context value for the DF Context field
--   p_attribute_name1-30    No   varchar2 Descriptive flex attribute column names used
--                                         in selected structure
--   p_attribute_value1-30   No   varchar2 Descriptive flex attribute values for selected
--                                         structure
--
-- Post Success:
--   The process succeeds. No parameters are returned.
--
-- Post Failure:
--   The process raises an error and stops execution.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure ins_or_upd_descflex_attribs
  (p_appl_short_name               in     varchar2
  ,p_descflex_name                 in     varchar2
  ,p_attribute_category            in     varchar2
  ,p_attribute1_name               in     varchar2 default null
  ,p_attribute1_value              in     varchar2 default null
  ,p_attribute2_name               in     varchar2 default null
  ,p_attribute2_value              in     varchar2 default null
  ,p_attribute3_name               in     varchar2 default null
  ,p_attribute3_value              in     varchar2 default null
  ,p_attribute4_name               in     varchar2 default null
  ,p_attribute4_value              in     varchar2 default null
  ,p_attribute5_name               in     varchar2 default null
  ,p_attribute5_value              in     varchar2 default null
  ,p_attribute6_name               in     varchar2 default null
  ,p_attribute6_value              in     varchar2 default null
  ,p_attribute7_name               in     varchar2 default null
  ,p_attribute7_value              in     varchar2 default null
  ,p_attribute8_name               in     varchar2 default null
  ,p_attribute8_value              in     varchar2 default null
  ,p_attribute9_name               in     varchar2 default null
  ,p_attribute9_value              in     varchar2 default null
  ,p_attribute10_name              in     varchar2 default null
  ,p_attribute10_value             in     varchar2 default null
  ,p_attribute11_name              in     varchar2 default null
  ,p_attribute11_value             in     varchar2 default null
  ,p_attribute12_name              in     varchar2 default null
  ,p_attribute12_value             in     varchar2 default null
  ,p_attribute13_name              in     varchar2 default null
  ,p_attribute13_value             in     varchar2 default null
  ,p_attribute14_name              in     varchar2 default null
  ,p_attribute14_value             in     varchar2 default null
  ,p_attribute15_name              in     varchar2 default null
  ,p_attribute15_value             in     varchar2 default null
  ,p_attribute16_name              in     varchar2 default null
  ,p_attribute16_value             in     varchar2 default null
  ,p_attribute17_name              in     varchar2 default null
  ,p_attribute17_value             in     varchar2 default null
  ,p_attribute18_name              in     varchar2 default null
  ,p_attribute18_value             in     varchar2 default null
  ,p_attribute19_name              in     varchar2 default null
  ,p_attribute19_value             in     varchar2 default null
  ,p_attribute20_name              in     varchar2 default null
  ,p_attribute20_value             in     varchar2 default null
  ,p_attribute21_name              in     varchar2 default null
  ,p_attribute21_value             in     varchar2 default null
  ,p_attribute22_name              in     varchar2 default null
  ,p_attribute22_value             in     varchar2 default null
  ,p_attribute23_name              in     varchar2 default null
  ,p_attribute23_value             in     varchar2 default null
  ,p_attribute24_name              in     varchar2 default null
  ,p_attribute24_value             in     varchar2 default null
  ,p_attribute25_name              in     varchar2 default null
  ,p_attribute25_value             in     varchar2 default null
  ,p_attribute26_name              in     varchar2 default null
  ,p_attribute26_value             in     varchar2 default null
  ,p_attribute27_name              in     varchar2 default null
  ,p_attribute27_value             in     varchar2 default null
  ,p_attribute28_name              in     varchar2 default null
  ,p_attribute28_value             in     varchar2 default null
  ,p_attribute29_name              in     varchar2 default null
  ,p_attribute29_value             in     varchar2 default null
  ,p_attribute30_name              in     varchar2 default null
  ,p_attribute30_value             in     varchar2 default null
  );
end hr_dflex_utility;

 

/
