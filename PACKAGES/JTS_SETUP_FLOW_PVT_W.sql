--------------------------------------------------------
--  DDL for Package JTS_SETUP_FLOW_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTS_SETUP_FLOW_PVT_W" AUTHID CURRENT_USER as
  /* $Header: jtswcsfs.pls 115.5 2002/04/10 18:10:28 pkm ship    $ */
  procedure rosetta_table_copy_in_p7(t out jts_setup_flow_pvt.setup_flow_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p7(t jts_setup_flow_pvt.setup_flow_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_VARCHAR2_TABLE_100
    , a2 out JTF_VARCHAR2_TABLE_100
    , a3 out JTF_NUMBER_TABLE
    , a4 out JTF_NUMBER_TABLE
    , a5 out JTF_NUMBER_TABLE
    , a6 out JTF_VARCHAR2_TABLE_300
    , a7 out JTF_VARCHAR2_TABLE_300
    , a8 out JTF_VARCHAR2_TABLE_100
    , a9 out JTF_VARCHAR2_TABLE_100
    , a10 out JTF_NUMBER_TABLE
    , a11 out JTF_VARCHAR2_TABLE_100
    , a12 out JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p8(t out jts_setup_flow_pvt.flow_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_DATE_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p8(t jts_setup_flow_pvt.flow_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_VARCHAR2_TABLE_100
    , a2 out JTF_VARCHAR2_TABLE_100
    , a3 out JTF_NUMBER_TABLE
    , a4 out JTF_NUMBER_TABLE
    , a5 out JTF_NUMBER_TABLE
    , a6 out JTF_VARCHAR2_TABLE_300
    , a7 out JTF_VARCHAR2_TABLE_300
    , a8 out JTF_VARCHAR2_TABLE_100
    , a9 out JTF_VARCHAR2_TABLE_100
    , a10 out JTF_NUMBER_TABLE
    , a11 out JTF_VARCHAR2_TABLE_100
    , a12 out JTF_VARCHAR2_TABLE_100
    , a13 out JTF_NUMBER_TABLE
    , a14 out JTF_VARCHAR2_TABLE_100
    , a15 out JTF_DATE_TABLE
    , a16 out JTF_DATE_TABLE
    , a17 out JTF_VARCHAR2_TABLE_100
    , a18 out JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p9(t out jts_setup_flow_pvt.root_setup_flow_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p9(t jts_setup_flow_pvt.root_setup_flow_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_VARCHAR2_TABLE_100
    , a2 out JTF_VARCHAR2_TABLE_100
    );

  procedure get_flow_root_flows(p_api_version  NUMBER
    , p1_a0 out JTF_NUMBER_TABLE
    , p1_a1 out JTF_VARCHAR2_TABLE_100
    , p1_a2 out JTF_VARCHAR2_TABLE_100
  );
  procedure get_module_root_flows(p_api_version  NUMBER
    , p1_a0 out JTF_NUMBER_TABLE
    , p1_a1 out JTF_VARCHAR2_TABLE_100
    , p1_a2 out JTF_VARCHAR2_TABLE_100
  );
  procedure get_flow_hiearchy(p_api_version  NUMBER
    , p_flow_id  NUMBER
    , p2_a0 out JTF_NUMBER_TABLE
    , p2_a1 out JTF_VARCHAR2_TABLE_100
    , p2_a2 out JTF_VARCHAR2_TABLE_100
    , p2_a3 out JTF_NUMBER_TABLE
    , p2_a4 out JTF_NUMBER_TABLE
    , p2_a5 out JTF_NUMBER_TABLE
    , p2_a6 out JTF_VARCHAR2_TABLE_300
    , p2_a7 out JTF_VARCHAR2_TABLE_300
    , p2_a8 out JTF_VARCHAR2_TABLE_100
    , p2_a9 out JTF_VARCHAR2_TABLE_100
    , p2_a10 out JTF_NUMBER_TABLE
    , p2_a11 out JTF_VARCHAR2_TABLE_100
    , p2_a12 out JTF_VARCHAR2_TABLE_100
  );
  procedure get_flow_data_hiearchy(p_api_version  NUMBER
    , p_flow_id  NUMBER
    , p_version_id  NUMBER
    , p3_a0 out JTF_NUMBER_TABLE
    , p3_a1 out JTF_VARCHAR2_TABLE_100
    , p3_a2 out JTF_VARCHAR2_TABLE_100
    , p3_a3 out JTF_NUMBER_TABLE
    , p3_a4 out JTF_NUMBER_TABLE
    , p3_a5 out JTF_NUMBER_TABLE
    , p3_a6 out JTF_VARCHAR2_TABLE_300
    , p3_a7 out JTF_VARCHAR2_TABLE_300
    , p3_a8 out JTF_VARCHAR2_TABLE_100
    , p3_a9 out JTF_VARCHAR2_TABLE_100
    , p3_a10 out JTF_NUMBER_TABLE
    , p3_a11 out JTF_VARCHAR2_TABLE_100
    , p3_a12 out JTF_VARCHAR2_TABLE_100
    , p3_a13 out JTF_NUMBER_TABLE
    , p3_a14 out JTF_VARCHAR2_TABLE_100
    , p3_a15 out JTF_DATE_TABLE
    , p3_a16 out JTF_DATE_TABLE
    , p3_a17 out JTF_VARCHAR2_TABLE_100
    , p3_a18 out JTF_VARCHAR2_TABLE_100
  );
end jts_setup_flow_pvt_w;

 

/
