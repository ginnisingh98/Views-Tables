--------------------------------------------------------
--  DDL for Package Body JTF_RS_JSP_LOV_RECS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_JSP_LOV_RECS_PUB_W" as
  /* $Header: jtfrsjwb.pls 120.0 2005/05/11 08:20:26 appldev ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy jtf_rs_jsp_lov_recs_pub.lov_output_tbl_type, a0 JTF_VARCHAR2_TABLE_2000
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_VARCHAR2_TABLE_2000
    , a6 JTF_VARCHAR2_TABLE_2000
    , a7 JTF_VARCHAR2_TABLE_2000
    , a8 JTF_VARCHAR2_TABLE_2000
    , a9 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).display_value := a0(indx);
          t(ddindx).code_value := a1(indx);
          t(ddindx).aux_value1 := a2(indx);
          t(ddindx).aux_value2 := a3(indx);
          t(ddindx).aux_value3 := a4(indx);
          t(ddindx).ext_value1 := a5(indx);
          t(ddindx).ext_value2 := a6(indx);
          t(ddindx).ext_value3 := a7(indx);
          t(ddindx).ext_value4 := a8(indx);
          t(ddindx).ext_value5 := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t jtf_rs_jsp_lov_recs_pub.lov_output_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_2000
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , a9 out nocopy JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_2000();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_2000();
    a3 := JTF_VARCHAR2_TABLE_2000();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_VARCHAR2_TABLE_2000();
    a6 := JTF_VARCHAR2_TABLE_2000();
    a7 := JTF_VARCHAR2_TABLE_2000();
    a8 := JTF_VARCHAR2_TABLE_2000();
    a9 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_VARCHAR2_TABLE_2000();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_2000();
      a3 := JTF_VARCHAR2_TABLE_2000();
      a4 := JTF_VARCHAR2_TABLE_2000();
      a5 := JTF_VARCHAR2_TABLE_2000();
      a6 := JTF_VARCHAR2_TABLE_2000();
      a7 := JTF_VARCHAR2_TABLE_2000();
      a8 := JTF_VARCHAR2_TABLE_2000();
      a9 := JTF_VARCHAR2_TABLE_2000();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).display_value;
          a1(indx) := t(ddindx).code_value;
          a2(indx) := t(ddindx).aux_value1;
          a3(indx) := t(ddindx).aux_value2;
          a4(indx) := t(ddindx).aux_value3;
          a5(indx) := t(ddindx).ext_value1;
          a6(indx) := t(ddindx).ext_value2;
          a7(indx) := t(ddindx).ext_value3;
          a8(indx) := t(ddindx).ext_value4;
          a9(indx) := t(ddindx).ext_value5;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure get_lov_records(p_range_low  NUMBER
    , p_range_high  NUMBER
    , p_record_group_name  VARCHAR2
    , p_in_filter1  VARCHAR2
    , p_in_filter2  VARCHAR2
    , x_total_rows out nocopy  NUMBER
    , x_more_data_flag out nocopy  VARCHAR2
    , x_lov_ak_region out nocopy  VARCHAR2
    , p9_a0 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , x_ext_col_cnt out nocopy  NUMBER
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_in_filter_lov_rec jtf_rs_jsp_lov_recs_pub.lov_input_rec_type;
    ddx_result_tbl jtf_rs_jsp_lov_recs_pub.lov_output_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_in_filter_lov_rec.display_value := p3_a0;
    ddp_in_filter_lov_rec.code_value := p3_a1;
    ddp_in_filter_lov_rec.aux_value1 := p3_a2;
    ddp_in_filter_lov_rec.aux_value2 := p3_a3;
    ddp_in_filter_lov_rec.aux_value3 := p3_a4;








    -- here's the delegated call to the old PL/SQL routine
    jtf_rs_jsp_lov_recs_pub.get_lov_records(p_range_low,
      p_range_high,
      p_record_group_name,
      ddp_in_filter_lov_rec,
      p_in_filter1,
      p_in_filter2,
      x_total_rows,
      x_more_data_flag,
      x_lov_ak_region,
      ddx_result_tbl,
      x_ext_col_cnt);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    jtf_rs_jsp_lov_recs_pub_w.rosetta_table_copy_out_p2(ddx_result_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      );

  end;

end jtf_rs_jsp_lov_recs_pub_w;

/
