--------------------------------------------------------
--  DDL for Package GHR_DUTY_STATION_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_DUTY_STATION_BK2" AUTHID CURRENT_USER as
/* $Header: ghdutapi.pkh 120.1 2005/10/02 01:57:45 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_duty_station_b >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_duty_station_b	(
   p_duty_station_id 	           in  number
  ,p_effective_start_date          in  date
  ,p_effective_end_date            in  date
  ,p_locality_pay_area_id          in  number
  ,p_leo_pay_area_code             in  varchar2
  ,p_name                          in  varchar2
  ,p_duty_station_code             in  varchar2
  ,p_is_duty_station               in  varchar2
  ,p_effective_date		   in  date
  ,p_datetrack_update_mode       in  varchar2
  ,p_object_version_number       in number
	);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_duty_station_a >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_duty_station_a	(
     p_duty_station_id 	           in  number
  ,p_effective_start_date          in  date
  ,p_effective_end_date            in  date
  ,p_locality_pay_area_id          in  number
  ,p_leo_pay_area_code             in  varchar2
  ,p_name                          in  varchar2
  ,p_duty_station_code             in  varchar2
  ,p_is_duty_station               in  varchar2
  ,p_effective_date                in  date
  ,p_datetrack_update_mode	   in  varchar2
  ,p_object_version_number         in number
	);

end ghr_duty_station_bk2;

 

/
