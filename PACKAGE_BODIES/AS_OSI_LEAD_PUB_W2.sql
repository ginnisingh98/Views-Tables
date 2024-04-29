--------------------------------------------------------
--  DDL for Package Body AS_OSI_LEAD_PUB_W2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_OSI_LEAD_PUB_W2" as
  /* $Header: asxolpbb.pls 115.2 2002/12/10 01:32:38 kichan ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure osi_ccs_fetch(p_api_version_number  NUMBER
    , p1_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a1 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_osi_ccs_tbl as_osi_lead_pub.osi_ccs_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    as_osi_lead_pub.osi_ccs_fetch(p_api_version_number,
      ddp_osi_ccs_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    as_osi_lead_pub_w.rosetta_table_copy_out_p22(ddp_osi_ccs_tbl, p1_a0
      , p1_a1
      );
  end;

  procedure osi_ovm_fetch(p_api_version_number  NUMBER
    , p1_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a1 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_osi_ovm_tbl as_osi_lead_pub.osi_ovm_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    as_osi_lead_pub.osi_ovm_fetch(p_api_version_number,
      ddp_osi_ovm_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    as_osi_lead_pub_w.rosetta_table_copy_out_p26(ddp_osi_ovm_tbl, p1_a0
      , p1_a1
      );
  end;

end as_osi_lead_pub_w2;

/
