--------------------------------------------------------
--  DDL for Package Body IBY_DBCCARD_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_DBCCARD_PVT_W" as
  /* $Header: ibyrdmnb.pls 115.1 2002/11/20 01:21:04 jleybovi noship $ */
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

  procedure rosetta_table_copy_in_p13(t out nocopy iby_dbccard_pvt.summary_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
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
          t(ddindx).totalamt := rosetta_g_miss_num_map(a2(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p13;
  procedure rosetta_table_copy_out_p13(t iby_dbccard_pvt.summary_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).columnid);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).totaltrxn);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).totalamt);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p13;

  procedure rosetta_table_copy_in_p14(t out nocopy iby_dbccard_pvt.trxnsum_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).columnid := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).totalreq := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).totalsuc := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).totalfail := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).totalpend := rosetta_g_miss_num_map(a4(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p14;
  procedure rosetta_table_copy_out_p14(t iby_dbccard_pvt.trxnsum_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).columnid);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).totalreq);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).totalsuc);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).totalfail);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).totalpend);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p14;

  procedure rosetta_table_copy_in_p15(t out nocopy iby_dbccard_pvt.trxnfail_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).columnid := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).status := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).cause := a2(indx);
          t(ddindx).totaltrxn := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).totalamt := rosetta_g_miss_num_map(a4(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p15;
  procedure rosetta_table_copy_out_p15(t iby_dbccard_pvt.trxnfail_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).columnid);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).status);
          a2(indx) := t(ddindx).cause;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).totaltrxn);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).totalamt);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p15;

  procedure get_trxn_summary(payee_id  VARCHAR2
    , period  VARCHAR2
    , p2_a0 out nocopy JTF_NUMBER_TABLE
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a3 out nocopy JTF_NUMBER_TABLE
    , p3_a4 out nocopy JTF_NUMBER_TABLE
  )
  as
    ddsummary_tbl iby_dbccard_pvt.summary_tbl_type;
    ddtrxnsum_tbl iby_dbccard_pvt.trxnsum_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    -- here's the delegated call to the old PL/SQL routine
    iby_dbccard_pvt.get_trxn_summary(payee_id,
      period,
      ddsummary_tbl,
      ddtrxnsum_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any


    iby_dbccard_pvt_w.rosetta_table_copy_out_p13(ddsummary_tbl, p2_a0
      , p2_a1
      , p2_a2
      );

    iby_dbccard_pvt_w.rosetta_table_copy_out_p14(ddtrxnsum_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      );
  end;

  procedure get_failure_summary(payee_id  VARCHAR2
    , period  VARCHAR2
    , p2_a0 out nocopy JTF_NUMBER_TABLE
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a3 out nocopy JTF_NUMBER_TABLE
    , p2_a4 out nocopy JTF_NUMBER_TABLE
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a3 out nocopy JTF_NUMBER_TABLE
    , p3_a4 out nocopy JTF_NUMBER_TABLE
  )
  as
    ddauthfail_tbl iby_dbccard_pvt.trxnfail_tbl_type;
    ddsettfail_tbl iby_dbccard_pvt.trxnfail_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    -- here's the delegated call to the old PL/SQL routine
    iby_dbccard_pvt.get_failure_summary(payee_id,
      period,
      ddauthfail_tbl,
      ddsettfail_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any


    iby_dbccard_pvt_w.rosetta_table_copy_out_p15(ddauthfail_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      );

    iby_dbccard_pvt_w.rosetta_table_copy_out_p15(ddsettfail_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      );
  end;

  procedure get_cardtype_summary(payee_id  VARCHAR2
    , period  VARCHAR2
    , p2_a0 out nocopy JTF_NUMBER_TABLE
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a3 out nocopy JTF_NUMBER_TABLE
    , p2_a4 out nocopy JTF_NUMBER_TABLE
  )
  as
    ddcardtype_tbl iby_dbccard_pvt.trxnfail_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    iby_dbccard_pvt.get_cardtype_summary(payee_id,
      period,
      ddcardtype_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any


    iby_dbccard_pvt_w.rosetta_table_copy_out_p15(ddcardtype_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      );
  end;

  procedure get_processor_summary(payee_id  VARCHAR2
    , period  VARCHAR2
    , p2_a0 out nocopy JTF_NUMBER_TABLE
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a3 out nocopy JTF_NUMBER_TABLE
    , p2_a4 out nocopy JTF_NUMBER_TABLE
  )
  as
    ddprocessor_tbl iby_dbccard_pvt.trxnfail_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    iby_dbccard_pvt.get_processor_summary(payee_id,
      period,
      ddprocessor_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any


    iby_dbccard_pvt_w.rosetta_table_copy_out_p15(ddprocessor_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      );
  end;

end iby_dbccard_pvt_w;

/
