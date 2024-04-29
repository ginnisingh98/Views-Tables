--------------------------------------------------------
--  DDL for Package Body OKL_VP_JTF_PARTY_NAME_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_JTF_PARTY_NAME_PUB_W" as
  /* $Header: OKLUCTSB.pls 115.7 2003/10/02 23:18:23 manumanu noship $ */
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

  procedure get_party(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  VARCHAR2
    , p_cle_id  VARCHAR2
    , p_role_code  VARCHAR2
    , p_intent  VARCHAR2
    , p9_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_party_tab okl_vp_jtf_party_name_pub.party_tab_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    okl_vp_jtf_party_name_pub.get_party(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      p_cle_id,
      p_role_code,
      p_intent,
      ddx_party_tab);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    okl_vp_jtf_party_name_pvt_w.rosetta_table_copy_out_p1(ddx_party_tab, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      );
  end;

end okl_vp_jtf_party_name_pub_w;

/
