--------------------------------------------------------
--  DDL for Package AHL_MC_PATH_POSITION_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_MC_PATH_POSITION_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLWPOSS.pls 120.1 2008/02/29 07:54:36 sathapli ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ahl_mc_path_position_pvt.path_position_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    );
  procedure rosetta_table_copy_out_p1(t ahl_mc_path_position_pvt.path_position_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    );

  procedure create_position_id(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_DATE_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_DATE_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_VARCHAR2_TABLE_100
    , p7_a14 JTF_VARCHAR2_TABLE_200
    , p7_a15 JTF_VARCHAR2_TABLE_200
    , p7_a16 JTF_VARCHAR2_TABLE_200
    , p7_a17 JTF_VARCHAR2_TABLE_200
    , p7_a18 JTF_VARCHAR2_TABLE_200
    , p7_a19 JTF_VARCHAR2_TABLE_200
    , p7_a20 JTF_VARCHAR2_TABLE_200
    , p7_a21 JTF_VARCHAR2_TABLE_200
    , p7_a22 JTF_VARCHAR2_TABLE_200
    , p7_a23 JTF_VARCHAR2_TABLE_200
    , p7_a24 JTF_VARCHAR2_TABLE_200
    , p7_a25 JTF_VARCHAR2_TABLE_200
    , p7_a26 JTF_VARCHAR2_TABLE_200
    , p7_a27 JTF_VARCHAR2_TABLE_200
    , p7_a28 JTF_VARCHAR2_TABLE_200
    , p_position_ref_meaning  VARCHAR2
    , p_position_ref_code  VARCHAR2
    , x_position_id out nocopy  NUMBER
  );
  function get_posref_by_path(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_DATE_TABLE
    , p0_a3 JTF_NUMBER_TABLE
    , p0_a4 JTF_DATE_TABLE
    , p0_a5 JTF_NUMBER_TABLE
    , p0_a6 JTF_NUMBER_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_NUMBER_TABLE
    , p0_a9 JTF_VARCHAR2_TABLE_100
    , p0_a10 JTF_VARCHAR2_TABLE_100
    , p0_a11 JTF_NUMBER_TABLE
    , p0_a12 JTF_NUMBER_TABLE
    , p0_a13 JTF_VARCHAR2_TABLE_100
    , p0_a14 JTF_VARCHAR2_TABLE_200
    , p0_a15 JTF_VARCHAR2_TABLE_200
    , p0_a16 JTF_VARCHAR2_TABLE_200
    , p0_a17 JTF_VARCHAR2_TABLE_200
    , p0_a18 JTF_VARCHAR2_TABLE_200
    , p0_a19 JTF_VARCHAR2_TABLE_200
    , p0_a20 JTF_VARCHAR2_TABLE_200
    , p0_a21 JTF_VARCHAR2_TABLE_200
    , p0_a22 JTF_VARCHAR2_TABLE_200
    , p0_a23 JTF_VARCHAR2_TABLE_200
    , p0_a24 JTF_VARCHAR2_TABLE_200
    , p0_a25 JTF_VARCHAR2_TABLE_200
    , p0_a26 JTF_VARCHAR2_TABLE_200
    , p0_a27 JTF_VARCHAR2_TABLE_200
    , p0_a28 JTF_VARCHAR2_TABLE_200
    , p_code_flag  VARCHAR2
  ) return varchar2;
  procedure check_pos_ref_path(p_from_csi_id  NUMBER
    , p_to_csi_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  function encode(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_DATE_TABLE
    , p0_a3 JTF_NUMBER_TABLE
    , p0_a4 JTF_DATE_TABLE
    , p0_a5 JTF_NUMBER_TABLE
    , p0_a6 JTF_NUMBER_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_NUMBER_TABLE
    , p0_a9 JTF_VARCHAR2_TABLE_100
    , p0_a10 JTF_VARCHAR2_TABLE_100
    , p0_a11 JTF_NUMBER_TABLE
    , p0_a12 JTF_NUMBER_TABLE
    , p0_a13 JTF_VARCHAR2_TABLE_100
    , p0_a14 JTF_VARCHAR2_TABLE_200
    , p0_a15 JTF_VARCHAR2_TABLE_200
    , p0_a16 JTF_VARCHAR2_TABLE_200
    , p0_a17 JTF_VARCHAR2_TABLE_200
    , p0_a18 JTF_VARCHAR2_TABLE_200
    , p0_a19 JTF_VARCHAR2_TABLE_200
    , p0_a20 JTF_VARCHAR2_TABLE_200
    , p0_a21 JTF_VARCHAR2_TABLE_200
    , p0_a22 JTF_VARCHAR2_TABLE_200
    , p0_a23 JTF_VARCHAR2_TABLE_200
    , p0_a24 JTF_VARCHAR2_TABLE_200
    , p0_a25 JTF_VARCHAR2_TABLE_200
    , p0_a26 JTF_VARCHAR2_TABLE_200
    , p0_a27 JTF_VARCHAR2_TABLE_200
    , p0_a28 JTF_VARCHAR2_TABLE_200
  ) return varchar2;
end ahl_mc_path_position_pvt_w;

/
