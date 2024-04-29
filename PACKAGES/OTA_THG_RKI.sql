--------------------------------------------------------
--  DDL for Package OTA_THG_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_THG_RKI" AUTHID CURRENT_USER as
/* $Header: otthgrhi.pkh 120.0 2005/05/29 07:44:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_gl_default_segment_id        in number
  ,p_cross_charge_id              in number
  ,p_segment                      in varchar2
  ,p_segment_num                  in number
  ,p_hr_data_source                   in varchar2
  ,p_constant                     in varchar2
  ,p_hr_cost_segment              in varchar2
  ,p_object_version_number        in number
  );
end ota_thg_rki;

 

/