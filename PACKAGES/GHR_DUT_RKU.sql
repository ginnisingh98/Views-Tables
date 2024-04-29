--------------------------------------------------------
--  DDL for Package GHR_DUT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_DUT_RKU" AUTHID CURRENT_USER as
/* $Header: ghdutrhi.pkh 120.1 2006/06/09 09:36:46 ygnanapr noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update	(
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

end ghr_dut_rku;

/
