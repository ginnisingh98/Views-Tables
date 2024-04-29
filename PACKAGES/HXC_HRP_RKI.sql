--------------------------------------------------------
--  DDL for Package HXC_HRP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HRP_RKI" AUTHID CURRENT_USER as
/* $Header: hxchrprhi.pkh 120.0 2005/05/29 05:38:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_recurring_period_id          in number
  ,p_name                         in varchar2
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_period_type                  in varchar2
  ,p_duration_in_days             in number
  ,p_object_version_number        in number
  );
end hxc_hrp_rki;

 

/
