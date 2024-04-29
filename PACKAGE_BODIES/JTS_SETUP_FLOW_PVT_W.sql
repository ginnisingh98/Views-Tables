--------------------------------------------------------
--  DDL for Package Body JTS_SETUP_FLOW_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTS_SETUP_FLOW_PVT_W" as
  /* $Header: jtswcsfb.pls 115.5 2002/04/10 18:10:26 pkm ship    $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).flow_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).flow_name := a1(indx);
          t(ddindx).flow_code := a2(indx);
          t(ddindx).parent_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).level := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).flow_sequence := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).overview_url := a6(indx);
          t(ddindx).diagnostics_url := a7(indx);
          t(ddindx).dpf_code := a8(indx);
          t(ddindx).dpf_asn := a9(indx);
          t(ddindx).num_steps := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).flow_type := a11(indx);
          t(ddindx).has_child_flag := a12(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        a8.extend(t.count);
        a9.extend(t.count);
        a10.extend(t.count);
        a11.extend(t.count);
        a12.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).flow_id);
          a1(indx) := t(ddindx).flow_name;
          a2(indx) := t(ddindx).flow_code;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).parent_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).level);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).flow_sequence);
          a6(indx) := t(ddindx).overview_url;
          a7(indx) := t(ddindx).diagnostics_url;
          a8(indx) := t(ddindx).dpf_code;
          a9(indx) := t(ddindx).dpf_asn;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).num_steps);
          a11(indx) := t(ddindx).flow_type;
          a12(indx) := t(ddindx).has_child_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).flow_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).flow_name := a1(indx);
          t(ddindx).flow_code := a2(indx);
          t(ddindx).parent_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).level := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).flow_sequence := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).overview_url := a6(indx);
          t(ddindx).diagnostics_url := a7(indx);
          t(ddindx).dpf_code := a8(indx);
          t(ddindx).dpf_asn := a9(indx);
          t(ddindx).num_steps := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).flow_type := a11(indx);
          t(ddindx).has_child_flag := a12(indx);
          t(ddindx).version_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).complete_flag := a14(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).created_by_name := a17(indx);
          t(ddindx).last_updated_by_name := a18(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        a8.extend(t.count);
        a9.extend(t.count);
        a10.extend(t.count);
        a11.extend(t.count);
        a12.extend(t.count);
        a13.extend(t.count);
        a14.extend(t.count);
        a15.extend(t.count);
        a16.extend(t.count);
        a17.extend(t.count);
        a18.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).flow_id);
          a1(indx) := t(ddindx).flow_name;
          a2(indx) := t(ddindx).flow_code;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).parent_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).level);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).flow_sequence);
          a6(indx) := t(ddindx).overview_url;
          a7(indx) := t(ddindx).diagnostics_url;
          a8(indx) := t(ddindx).dpf_code;
          a9(indx) := t(ddindx).dpf_asn;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).num_steps);
          a11(indx) := t(ddindx).flow_type;
          a12(indx) := t(ddindx).has_child_flag;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).version_id);
          a14(indx) := t(ddindx).complete_flag;
          a15(indx) := t(ddindx).creation_date;
          a16(indx) := t(ddindx).last_update_date;
          a17(indx) := t(ddindx).created_by_name;
          a18(indx) := t(ddindx).last_updated_by_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure rosetta_table_copy_in_p9(t out jts_setup_flow_pvt.root_setup_flow_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).flow_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).flow_name := a1(indx);
          t(ddindx).flow_type := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t jts_setup_flow_pvt.root_setup_flow_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_VARCHAR2_TABLE_100
    , a2 out JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).flow_id);
          a1(indx) := t(ddindx).flow_name;
          a2(indx) := t(ddindx).flow_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure get_flow_root_flows(p_api_version  NUMBER
    , p1_a0 out JTF_NUMBER_TABLE
    , p1_a1 out JTF_VARCHAR2_TABLE_100
    , p1_a2 out JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_flow_tbl jts_setup_flow_pvt.root_setup_flow_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    jts_setup_flow_pvt.get_flow_root_flows(p_api_version,
      ddx_flow_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    jts_setup_flow_pvt_w.rosetta_table_copy_out_p9(ddx_flow_tbl, p1_a0
      , p1_a1
      , p1_a2
      );
  end;

  procedure get_module_root_flows(p_api_version  NUMBER
    , p1_a0 out JTF_NUMBER_TABLE
    , p1_a1 out JTF_VARCHAR2_TABLE_100
    , p1_a2 out JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_flow_tbl jts_setup_flow_pvt.root_setup_flow_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    jts_setup_flow_pvt.get_module_root_flows(p_api_version,
      ddx_flow_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    jts_setup_flow_pvt_w.rosetta_table_copy_out_p9(ddx_flow_tbl, p1_a0
      , p1_a1
      , p1_a2
      );
  end;

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
  )

  as
    ddx_flow_tbl jts_setup_flow_pvt.setup_flow_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    jts_setup_flow_pvt.get_flow_hiearchy(p_api_version,
      p_flow_id,
      ddx_flow_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    jts_setup_flow_pvt_w.rosetta_table_copy_out_p7(ddx_flow_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      , p2_a8
      , p2_a9
      , p2_a10
      , p2_a11
      , p2_a12
      );
  end;

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
  )

  as
    ddx_flow_tbl jts_setup_flow_pvt.flow_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    -- here's the delegated call to the old PL/SQL routine
    jts_setup_flow_pvt.get_flow_data_hiearchy(p_api_version,
      p_flow_id,
      p_version_id,
      ddx_flow_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    jts_setup_flow_pvt_w.rosetta_table_copy_out_p8(ddx_flow_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      );
  end;

end jts_setup_flow_pvt_w;

/
