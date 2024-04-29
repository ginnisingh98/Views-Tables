--------------------------------------------------------
--  DDL for Package Body IBY_DBCCARD_GRAPH_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_DBCCARD_GRAPH_PVT_W" as
  /* $Header: ibyrdghb.pls 115.1 2002/11/16 01:42:18 jleybovi noship $ */
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

  procedure rosetta_table_copy_in_p12(t out nocopy iby_dbccard_graph_pvt.hourlyvol_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).columnid := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).totaltrxn := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).time := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p12;
  procedure rosetta_table_copy_out_p12(t iby_dbccard_graph_pvt.hourlyvol_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).columnid);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).totaltrxn);
          a2(indx) := t(ddindx).time;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p12;

  procedure rosetta_table_copy_in_p13(t out nocopy iby_dbccard_graph_pvt.trxntrends_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).month := a0(indx);
          t(ddindx).value := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).type := a2(indx);
          t(ddindx).tdate := rosetta_g_miss_date_in_map(a3(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p13;
  procedure rosetta_table_copy_out_p13(t iby_dbccard_graph_pvt.trxntrends_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_DATE_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).month;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).value);
          a2(indx) := t(ddindx).type;
          a3(indx) := t(ddindx).tdate;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p13;

  procedure rosetta_table_copy_in_p14(t out nocopy iby_dbccard_graph_pvt.trends_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := iby_dbccard_graph_pvt.trends_tbl_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := iby_dbccard_graph_pvt.trends_tbl_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).month := a0(indx);
          t(ddindx).value := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).type := a2(indx);
          t(ddindx).tdate := rosetta_g_miss_date_in_map(a3(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p14;
  procedure rosetta_table_copy_out_p14(t iby_dbccard_graph_pvt.trends_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
    a3 := null;
  elsif t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_DATE_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).month;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).value);
          a2(indx) := t(ddindx).type;
          a3(indx) := t(ddindx).tdate;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p14;

  procedure get_hourly_volume(payee_id  VARCHAR2
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_NUMBER_TABLE
    , p1_a2 out nocopy JTF_VARCHAR2_TABLE_100
  )
  as
    ddhourlyvol_tbl iby_dbccard_graph_pvt.hourlyvol_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    iby_dbccard_graph_pvt.get_hourly_volume(payee_id,
      ddhourlyvol_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any

    iby_dbccard_graph_pvt_w.rosetta_table_copy_out_p12(ddhourlyvol_tbl, p1_a0
      , p1_a1
      , p1_a2
      );
  end;

  procedure get_trxn_trends(payee_id  VARCHAR2
    , output_type  VARCHAR2
    , p2_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a3 out nocopy JTF_DATE_TABLE
  )
  as
    ddtrxntrend_tbl iby_dbccard_graph_pvt.trxntrends_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    iby_dbccard_graph_pvt.get_trxn_trends(payee_id,
      output_type,
      ddtrxntrend_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any


    iby_dbccard_graph_pvt_w.rosetta_table_copy_out_p13(ddtrxntrend_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      );
  end;

  procedure get_processor_trends(payee_id  VARCHAR2
    , output_type  VARCHAR2
    , p2_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a3 out nocopy JTF_DATE_TABLE
  )
  as
    ddtrxntrend_tbl iby_dbccard_graph_pvt.trxntrends_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    iby_dbccard_graph_pvt.get_processor_trends(payee_id,
      output_type,
      ddtrxntrend_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any


    iby_dbccard_graph_pvt_w.rosetta_table_copy_out_p13(ddtrxntrend_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      );
  end;

  procedure get_subtype_trends(payee_id  VARCHAR2
    , output_type  VARCHAR2
    , p2_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a3 out nocopy JTF_DATE_TABLE
  )
  as
    ddtrxntrend_tbl iby_dbccard_graph_pvt.trxntrends_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    iby_dbccard_graph_pvt.get_subtype_trends(payee_id,
      output_type,
      ddtrxntrend_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any


    iby_dbccard_graph_pvt_w.rosetta_table_copy_out_p13(ddtrxntrend_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      );
  end;

  procedure get_failure_trends(payee_id  VARCHAR2
    , output_type  VARCHAR2
    , p2_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a3 out nocopy JTF_DATE_TABLE
  )
  as
    ddtrxntrend_tbl iby_dbccard_graph_pvt.trxntrends_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    iby_dbccard_graph_pvt.get_failure_trends(payee_id,
      output_type,
      ddtrxntrend_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any


    iby_dbccard_graph_pvt_w.rosetta_table_copy_out_p13(ddtrxntrend_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      );
  end;

end iby_dbccard_graph_pvt_w;

/
