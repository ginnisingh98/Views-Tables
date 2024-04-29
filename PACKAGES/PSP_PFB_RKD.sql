--------------------------------------------------------
--  DDL for Package PSP_PFB_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PFB_RKD" AUTHID CURRENT_USER as
/* $Header: PSPFBRHS.pls 120.0 2005/06/02 15:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_period_frequency_id          in number
  ,p_object_version_number_o      in number
  ,p_start_date_o                 in date
  ,p_unit_of_measure_o            in varchar2
  ,p_period_duration_o            in number
  ,p_report_type_o                in varchar2
  );
--
end psp_pfb_rkd;

 

/
