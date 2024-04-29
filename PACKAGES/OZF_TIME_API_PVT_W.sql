--------------------------------------------------------
--  DDL for Package OZF_TIME_API_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_TIME_API_PVT_W" AUTHID CURRENT_USER as
  /* $Header: ozfwtias.pls 115.0 2004/03/10 01:45:21 mkothari noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy ozf_time_api_pvt.g_period_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p0(t ozf_time_api_pvt.g_period_tbl_type, a0 out nocopy JTF_NUMBER_TABLE);

  function is_quarter_allowed(p_start_date  date
    , p_end_date  date
  ) return char;
  function is_period_range_valid(p_start_date  date
    , p_end_date  date
  ) return char;
end ozf_time_api_pvt_w;

 

/
