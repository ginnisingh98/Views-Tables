--------------------------------------------------------
--  DDL for Package Body JTF_TERR_JSP_REPORTS_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_JSP_REPORTS_W" as
  /* $Header: jtfwjrpb.pls 120.0 2005/06/02 18:23:18 appldev ship $ */
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

  procedure rosetta_table_copy_in_p1(t OUT NOCOPY jtf_terr_jsp_reports.report_out_tbl_type, a0 JTF_VARCHAR2_TABLE_2000
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
  if a0 is not null and a0.count=0 then
    t := jtf_terr_jsp_reports.report_out_tbl_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := jtf_terr_jsp_reports.report_out_tbl_type();
      t.extend(a0.count);
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
          t(ddindx).column16 := a15(indx);
          t(ddindx).column17 := a16(indx);
          t(ddindx).column18 := a17(indx);
          t(ddindx).column19 := a18(indx);
          t(ddindx).column20 := a19(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t jtf_terr_jsp_reports.report_out_tbl_type, a0 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
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
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
    a3 := null;
    a4 := null;
    a5 := null;
    a6 := null;
    a7 := null;
    a8 := null;
    a9 := null;
    a10 := null;
    a11 := null;
    a12 := null;
    a13 := null;
    a14 := null;
    a15 := null;
    a16 := null;
    a17 := null;
    a18 := null;
    a19 := null;
  elsif t.count = 0 then
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
          a15(indx) := t(ddindx).column16;
          a16(indx) := t(ddindx).column17;
          a17(indx) := t(ddindx).column18;
          a18(indx) := t(ddindx).column19;
          a19(indx) := t(ddindx).column20;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure report_control(p_report  VARCHAR2
    , p_param1  VARCHAR2
    , p_param2  VARCHAR2
    , p_param3  VARCHAR2
    , p_param4  VARCHAR2
    , p_param5  VARCHAR2
    , p6_a0 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p6_a1 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p6_a2 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p6_a3 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p6_a4 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p6_a5 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p6_a6 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p6_a7 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p6_a8 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p6_a9 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p6_a10 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p6_a11 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p6_a12 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p6_a13 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p6_a14 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p6_a15 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p6_a16 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p6_a17 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p6_a18 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p6_a19 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
  )
  as
    ddx_result_tbl jtf_terr_jsp_reports.report_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    jtf_terr_jsp_reports.report_control(p_report,
      p_param1,
      p_param2,
      p_param3,
      p_param4,
      p_param5,
      ddx_result_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any






    jtf_terr_jsp_reports_w.rosetta_table_copy_out_p1(ddx_result_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      );
  end;

end jtf_terr_jsp_reports_w;

/
