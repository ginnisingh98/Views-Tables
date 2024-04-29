--------------------------------------------------------
--  DDL for Package OTA_THG_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_THG_BK2" AUTHID CURRENT_USER as
/* $Header: otthgapi.pkh 120.1 2005/10/02 02:08:19 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< <UPDATE_HR_GL_FLEX_b >-------------------|
-- ----------------------------------------------------------------------------
--
 procedure update_hr_gl_flex_b
  (p_effective_date               in     date
  ,p_gl_default_segment_id        in     number
  ,p_object_version_number        in     number
  ,p_cross_charge_id              in     number
  ,p_segment                      in     varchar2
  ,p_segment_num                  in     number
  ,p_hr_data_source               in     varchar2
  ,p_constant                     in     varchar2
  ,p_hr_cost_segment              in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< <UPDATE_HR_GL_FLEX_a >-----------------------|
-- ----------------------------------------------------------------------------
--
 procedure update_hr_gl_flex_a
  (p_effective_date               in     date
  ,p_gl_default_segment_id        in     number
  ,p_object_version_number        in     number
  ,p_cross_charge_id              in     number
  ,p_segment                      in     varchar2
  ,p_segment_num                  in     number
  ,p_hr_data_source               in     varchar2
  ,p_constant                     in     varchar2
  ,p_hr_cost_segment              in     varchar2
  );
--
end OTA_THG_BK2 ;

 

/
