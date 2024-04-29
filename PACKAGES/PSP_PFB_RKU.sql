--------------------------------------------------------
--  DDL for Package PSP_PFB_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PFB_RKU" AUTHID CURRENT_USER as
/* $Header: PSPFBRHS.pls 120.0 2005/06/02 15:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_period_frequency_id          in number
  ,p_object_version_number        in number
  ,p_start_date                   in date
  ,p_unit_of_measure              in varchar2
  ,p_period_duration              in number
  ,p_report_type                  in varchar2
  ,p_object_version_number_o      in number
  ,p_start_date_o                 in date
  ,p_unit_of_measure_o            in varchar2
  ,p_period_duration_o            in number
  ,p_report_type_o                in varchar2
  );
--
end psp_pfb_rku;

 

/
