--------------------------------------------------------
--  DDL for Package Body OZF_FUND_EXTENSION_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_FUND_EXTENSION_PVT_W" as
  /* $Header: ozfwfexb.pls 115.5 2004/04/20 06:18:05 rimehrot noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure validate_delete_fund(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_object_id  NUMBER
    , p_object_version_number  NUMBER
    , p5_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_dependent_object_tbl ams_utility_pvt.dependent_objects_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    ozf_fund_extension_pvt.validate_delete_fund(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_object_id,
      p_object_version_number,
      ddx_dependent_object_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    ams_utility_pvt_w.rosetta_table_copy_out_p45(ddx_dependent_object_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      );



  end;

end ozf_fund_extension_pvt_w;

/
