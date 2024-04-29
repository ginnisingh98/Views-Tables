--------------------------------------------------------
--  DDL for Package CSI_GIS_INSTANCE_LOC_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_GIS_INSTANCE_LOC_PUB_W" AUTHID CURRENT_USER as
  /* $Header: csiwgils.pls 120.0.12010000.2 2008/11/13 11:30:01 somitra noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy csi_gis_instance_loc_pub.csi_instance_geoloc_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t csi_gis_instance_loc_pub.csi_instance_geoloc_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure createupdate_inst_geoloc_info(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_VARCHAR2_TABLE_100
    , p2_a2 JTF_VARCHAR2_TABLE_100
    , p2_a3 JTF_VARCHAR2_TABLE_100
    , p2_a4 JTF_VARCHAR2_TABLE_100
    , p_asset_context  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end csi_gis_instance_loc_pub_w;

/
