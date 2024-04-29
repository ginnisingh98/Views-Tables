--------------------------------------------------------
--  DDL for Package OTA_THG_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_THG_RKD" AUTHID CURRENT_USER as
/* $Header: otthgrhi.pkh 120.0 2005/05/29 07:44:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_gl_default_segment_id        in number
  ,p_cross_charge_id_o            in number
  ,p_segment_o                    in varchar2
  ,p_segment_num_o                in number
  ,p_hr_data_source_o                 in varchar2
  ,p_constant_o                   in varchar2
  ,p_hr_cost_segment_o            in varchar2
  ,p_object_version_number_o      in number
  );
--
end ota_thg_rkd;

 

/
