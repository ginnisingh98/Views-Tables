--------------------------------------------------------
--  DDL for Package Body JTF_TERR_JSP_LOV_RECS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_JSP_LOV_RECS_PUB_W" as
  /* $Header: jtfwjlvb.pls 120.0 2005/06/02 18:23:17 appldev ship $ */
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

  procedure rosetta_table_copy_in_p2(t OUT NOCOPY jtf_terr_jsp_lov_recs_pub.lov_output_tbl_type, a0 JTF_VARCHAR2_TABLE_2000
    , a1 JTF_VARCHAR2_TABLE_2000
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_VARCHAR2_TABLE_2000
    , a6 JTF_VARCHAR2_TABLE_2000
    , a7 JTF_VARCHAR2_TABLE_2000
    , a8 JTF_VARCHAR2_TABLE_2000
    , a9 JTF_VARCHAR2_TABLE_2000
    , a10 JTF_VARCHAR2_TABLE_2000
    , a11 JTF_VARCHAR2_TABLE_2000
    , a12 JTF_VARCHAR2_TABLE_2000
    , a13 JTF_VARCHAR2_TABLE_2000
    , a14 JTF_VARCHAR2_TABLE_2000
    , a15 JTF_VARCHAR2_TABLE_2000
    , a16 JTF_VARCHAR2_TABLE_2000
    , a17 JTF_VARCHAR2_TABLE_2000
    , a18 JTF_VARCHAR2_TABLE_2000
    , a19 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).column1 := a0(indx);
          t(ddindx).column2 := a1(indx);
          t(ddindx).column3 := a2(indx);
          t(ddindx).column4 := a3(indx);
          t(ddindx).column5 := a4(indx);
          t(ddindx).column6 := a5(indx);
          t(ddindx).column7 := a6(indx);
          t(ddindx).column8 := a7(indx);
          t(ddindx).column9 := a8(indx);
          t(ddindx).column10 := a9(indx);
          t(ddindx).column11 := a10(indx);
          t(ddindx).column12 := a11(indx);
          t(ddindx).column13 := a12(indx);
          t(ddindx).column14 := a13(indx);
          t(ddindx).column15 := a14(indx);
          t(ddindx).filter1 := a15(indx);
          t(ddindx).filter2 := a16(indx);
          t(ddindx).filter3 := a17(indx);
          t(ddindx).filter4 := a18(indx);
          t(ddindx).filter5 := a19(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t jtf_terr_jsp_lov_recs_pub.lov_output_tbl_type, a0 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , a1 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , a2 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , a3 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , a4 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , a5 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , a6 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , a7 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , a8 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , a9 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , a10 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , a11 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , a12 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , a13 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , a14 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , a15 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , a16 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , a17 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , a18 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , a19 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_2000();
    a1 := JTF_VARCHAR2_TABLE_2000();
    a2 := JTF_VARCHAR2_TABLE_2000();
    a3 := JTF_VARCHAR2_TABLE_2000();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_VARCHAR2_TABLE_2000();
    a6 := JTF_VARCHAR2_TABLE_2000();
    a7 := JTF_VARCHAR2_TABLE_2000();
    a8 := JTF_VARCHAR2_TABLE_2000();
    a9 := JTF_VARCHAR2_TABLE_2000();
    a10 := JTF_VARCHAR2_TABLE_2000();
    a11 := JTF_VARCHAR2_TABLE_2000();
    a12 := JTF_VARCHAR2_TABLE_2000();
    a13 := JTF_VARCHAR2_TABLE_2000();
    a14 := JTF_VARCHAR2_TABLE_2000();
    a15 := JTF_VARCHAR2_TABLE_2000();
    a16 := JTF_VARCHAR2_TABLE_2000();
    a17 := JTF_VARCHAR2_TABLE_2000();
    a18 := JTF_VARCHAR2_TABLE_2000();
    a19 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_VARCHAR2_TABLE_2000();
      a1 := JTF_VARCHAR2_TABLE_2000();
      a2 := JTF_VARCHAR2_TABLE_2000();
      a3 := JTF_VARCHAR2_TABLE_2000();
      a4 := JTF_VARCHAR2_TABLE_2000();
      a5 := JTF_VARCHAR2_TABLE_2000();
      a6 := JTF_VARCHAR2_TABLE_2000();
      a7 := JTF_VARCHAR2_TABLE_2000();
      a8 := JTF_VARCHAR2_TABLE_2000();
      a9 := JTF_VARCHAR2_TABLE_2000();
      a10 := JTF_VARCHAR2_TABLE_2000();
      a11 := JTF_VARCHAR2_TABLE_2000();
      a12 := JTF_VARCHAR2_TABLE_2000();
      a13 := JTF_VARCHAR2_TABLE_2000();
      a14 := JTF_VARCHAR2_TABLE_2000();
      a15 := JTF_VARCHAR2_TABLE_2000();
      a16 := JTF_VARCHAR2_TABLE_2000();
      a17 := JTF_VARCHAR2_TABLE_2000();
      a18 := JTF_VARCHAR2_TABLE_2000();
      a19 := JTF_VARCHAR2_TABLE_2000();
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
        a19.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).column1;
          a1(indx) := t(ddindx).column2;
          a2(indx) := t(ddindx).column3;
          a3(indx) := t(ddindx).column4;
          a4(indx) := t(ddindx).column5;
          a5(indx) := t(ddindx).column6;
          a6(indx) := t(ddindx).column7;
          a7(indx) := t(ddindx).column8;
          a8(indx) := t(ddindx).column9;
          a9(indx) := t(ddindx).column10;
          a10(indx) := t(ddindx).column11;
          a11(indx) := t(ddindx).column12;
          a12(indx) := t(ddindx).column13;
          a13(indx) := t(ddindx).column14;
          a14(indx) := t(ddindx).column15;
          a15(indx) := t(ddindx).filter1;
          a16(indx) := t(ddindx).filter2;
          a17(indx) := t(ddindx).filter3;
          a18(indx) := t(ddindx).filter4;
          a19(indx) := t(ddindx).filter5;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p3(t OUT NOCOPY jtf_terr_jsp_lov_recs_pub.lov_disp_format_tbl_type, a0 JTF_NUMBER_TABLE
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
          t(ddindx).column_number := a0(indx);
          t(ddindx).column_display_enable := a1(indx);
          t(ddindx).column_search_enable := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t jtf_terr_jsp_lov_recs_pub.lov_disp_format_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY JTF_VARCHAR2_TABLE_100
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
          a0(indx) := t(ddindx).column_number;
          a1(indx) := t(ddindx).column_display_enable;
          a2(indx) := t(ddindx).column_search_enable;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure get_lov_records(p_range_low  NUMBER
    , p_range_high  NUMBER
    , p_record_group_name  VARCHAR2
    , p3_a0  VARCHAR2
    , p3_a1  VARCHAR2
    , p3_a2  VARCHAR2
    , p3_a3  VARCHAR2
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  VARCHAR2
    , p3_a7  VARCHAR2
    , p3_a8  VARCHAR2
    , p3_a9  VARCHAR2
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  VARCHAR2
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  VARCHAR2
    , p3_a18  VARCHAR2
    , p3_a19  VARCHAR2
    , x_total_rows OUT NOCOPY  NUMBER
    , x_more_data_flag OUT NOCOPY  VARCHAR2
    , x_lov_ak_region OUT NOCOPY  VARCHAR2
    , p7_a0 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p7_a1 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p7_a2 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p7_a3 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p7_a4 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p7_a5 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p7_a6 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p7_a7 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p7_a8 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p7_a9 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p7_a10 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p7_a11 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p7_a12 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p7_a13 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p7_a14 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p7_a15 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p7_a16 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p7_a17 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p7_a18 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p7_a19 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p8_a0 OUT NOCOPY JTF_NUMBER_TABLE
    , p8_a1 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p8_a2 OUT NOCOPY JTF_VARCHAR2_TABLE_100
  )
  as
    ddp_in_filter_lov_rec jtf_terr_jsp_lov_recs_pub.lov_inout_rec_type;
    ddx_result_tbl jtf_terr_jsp_lov_recs_pub.lov_output_tbl_type;
    ddx_disp_format_tbl jtf_terr_jsp_lov_recs_pub.lov_disp_format_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT NOCOPY args, if any



    ddp_in_filter_lov_rec.column1 := p3_a0;
    ddp_in_filter_lov_rec.column2 := p3_a1;
    ddp_in_filter_lov_rec.column3 := p3_a2;
    ddp_in_filter_lov_rec.column4 := p3_a3;
    ddp_in_filter_lov_rec.column5 := p3_a4;
    ddp_in_filter_lov_rec.column6 := p3_a5;
    ddp_in_filter_lov_rec.column7 := p3_a6;
    ddp_in_filter_lov_rec.column8 := p3_a7;
    ddp_in_filter_lov_rec.column9 := p3_a8;
    ddp_in_filter_lov_rec.column10 := p3_a9;
    ddp_in_filter_lov_rec.column11 := p3_a10;
    ddp_in_filter_lov_rec.column12 := p3_a11;
    ddp_in_filter_lov_rec.column13 := p3_a12;
    ddp_in_filter_lov_rec.column14 := p3_a13;
    ddp_in_filter_lov_rec.column15 := p3_a14;
    ddp_in_filter_lov_rec.filter1 := p3_a15;
    ddp_in_filter_lov_rec.filter2 := p3_a16;
    ddp_in_filter_lov_rec.filter3 := p3_a17;
    ddp_in_filter_lov_rec.filter4 := p3_a18;
    ddp_in_filter_lov_rec.filter5 := p3_a19;






    -- here's the delegated call to the old PL/SQL routine
    jtf_terr_jsp_lov_recs_pub.get_lov_records(p_range_low,
      p_range_high,
      p_record_group_name,
      ddp_in_filter_lov_rec,
      x_total_rows,
      x_more_data_flag,
      x_lov_ak_region,
      ddx_result_tbl,
      ddx_disp_format_tbl);

    -- copy data back from the local OUT NOCOPY or IN-OUT NOCOPY args, if any







    jtf_terr_jsp_lov_recs_pub_w.rosetta_table_copy_out_p2(ddx_result_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      );

    jtf_terr_jsp_lov_recs_pub_w.rosetta_table_copy_out_p3(ddx_disp_format_tbl, p8_a0
      , p8_a1
      , p8_a2
      );
  end;

end jtf_terr_jsp_lov_recs_pub_w;

/
