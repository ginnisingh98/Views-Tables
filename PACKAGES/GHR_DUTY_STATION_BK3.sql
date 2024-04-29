--------------------------------------------------------
--  DDL for Package GHR_DUTY_STATION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_DUTY_STATION_BK3" AUTHID CURRENT_USER as
/* $Header: ghdutapi.pkh 120.1 2005/10/02 01:57:45 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_duty_station_b >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_duty_station_b	(
    p_duty_station_id               in     number
   ,p_object_version_number         in     number
	);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_duty_station_a >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_duty_station_a	(
     p_duty_station_id               in     number
    ,p_object_version_number         in     number
	);

end ghr_duty_station_bk3;

 

/
