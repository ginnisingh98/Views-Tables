--------------------------------------------------------
--  DDL for Package CSP_PART_SEARCH_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PART_SEARCH_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cspvsrcws.pls 120.0.12010000.3 2013/08/20 09:54:49 vmandava noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy csp_part_search_pvt.required_parts_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p2(t csp_part_search_pvt.required_parts_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    );

  procedure search(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p0_a2 JTF_NUMBER_TABLE
    , p1_a0  VARCHAR2
    , p1_a1  NUMBER
    , p1_a2  NUMBER
    , p1_a3  NUMBER
    , p1_a4  NUMBER
    , p1_a5  NUMBER
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  NUMBER
    , p1_a9  DATE
    , p1_a10  VARCHAR2
    , p1_a11  NUMBER
    , p1_a12  NUMBER
    , p1_a13  VARCHAR2
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  NUMBER
    , p1_a17  NUMBER
    , p1_a18  NUMBER
    , p1_a19  NUMBER
    , p1_a20  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  VARCHAR2
  );
  function get_arrival_time(p_cutoff  date
    , p_cutoff_tz  NUMBER
    , p_lead_time  NUMBER
    , p_lead_time_uom  VARCHAR2
    , p_intransit_time  NUMBER
    , p_delivery_time  date
    , p_safety_zone  NUMBER
    , p_location_id  NUMBER
    , p_location_source  VARCHAR2
    , p_organization_id  NUMBER
    , p_subinventory_code  VARCHAR2
  ) return date;
  function get_cutoff_time(p_cutoff  date
    , p_cutoff_tz  NUMBER
  ) return date;
end csp_part_search_pvt_w;

/
