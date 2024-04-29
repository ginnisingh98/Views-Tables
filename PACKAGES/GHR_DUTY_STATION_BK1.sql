--------------------------------------------------------
--  DDL for Package GHR_DUTY_STATION_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_DUTY_STATION_BK1" AUTHID CURRENT_USER as
/* $Header: ghdutapi.pkh 120.1 2005/10/02 01:57:45 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_duty_station_b >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure create_duty_station_b	(
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
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_duty_station_a >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure create_duty_station_a	(
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

end ghr_duty_station_bk1;

 

/
