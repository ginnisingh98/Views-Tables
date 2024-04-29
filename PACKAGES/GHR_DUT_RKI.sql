--------------------------------------------------------
--  DDL for Package GHR_DUT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_DUT_RKI" AUTHID CURRENT_USER as
/* $Header: ghdutrhi.pkh 120.1 2006/06/09 09:36:46 ygnanapr noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_insert >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert	(
   p_duty_station_id 	           in  number
  ,p_effective_start_date          in  date
  ,p_effective_end_date            in  date
  ,p_locality_pay_area_id          in  number
  ,p_leo_pay_area_code             in  varchar2
  ,p_name                          in  varchar2
  ,p_duty_station_code             in  varchar2
  ,p_msa_code                      in  varchar2
  ,p_cmsa_code                     in  varchar2
  ,p_state_or_country_code         in  varchar2
  ,p_county_code                   in  varchar2
  ,p_is_duty_station               in  varchar2
  ,p_effective_date                in  date
  ,p_object_version_number         in number
	);

end ghr_dut_rki;

/
