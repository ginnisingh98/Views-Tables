--------------------------------------------------------
--  DDL for Package GHR_DUT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_DUT_RKD" AUTHID CURRENT_USER as
/* $Header: ghdutrhi.pkh 120.1 2006/06/09 09:36:46 ygnanapr noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete	(
	 p_duty_station_id               in     number
        ,p_object_version_number         in     number
 );

end ghr_dut_rkd;

/
