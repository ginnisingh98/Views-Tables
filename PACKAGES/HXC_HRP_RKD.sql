--------------------------------------------------------
--  DDL for Package HXC_HRP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HRP_RKD" AUTHID CURRENT_USER as
/* $Header: hxchrprhi.pkh 120.0 2005/05/29 05:38:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_recurring_period_id          in number
  ,p_name_o                       in varchar2
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_period_type_o                in varchar2
  ,p_duration_in_days_o           in number
  ,p_object_version_number_o      in number
  );
--
end hxc_hrp_rkd;

 

/
