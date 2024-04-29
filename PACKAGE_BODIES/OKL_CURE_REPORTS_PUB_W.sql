--------------------------------------------------------
--  DDL for Package Body OKL_CURE_REPORTS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CURE_REPORTS_PUB_W" as
  /* $Header: OKLUCRTB.pls 115.2 2003/10/07 18:00:48 pdevaraj noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_cure_reports_pub.crtv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_2000
    , a9 JTF_DATE_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_VARCHAR2_TABLE_300
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_300
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_300
    , a26 JTF_VARCHAR2_TABLE_300
    , a27 JTF_VARCHAR2_TABLE_300
    , a28 JTF_VARCHAR2_TABLE_300
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_DATE_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_DATE_TABLE
    , a37 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).cure_report_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).report_number := a1(indx);
          t(ddindx).report_type := a2(indx);
          t(ddindx).report_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).vendor_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).vendor_site_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).vendor_contact_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).approval_status := a7(indx);
          t(ddindx).approval_reason := a8(indx);
          t(ddindx).expiration_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).currency_code := a10(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).attribute_category := a17(indx);
          t(ddindx).attribute1 := a18(indx);
          t(ddindx).attribute2 := a19(indx);
          t(ddindx).attribute3 := a20(indx);
          t(ddindx).attribute4 := a21(indx);
          t(ddindx).attribute5 := a22(indx);
          t(ddindx).attribute6 := a23(indx);
          t(ddindx).attribute7 := a24(indx);
          t(ddindx).attribute8 := a25(indx);
          t(ddindx).attribute9 := a26(indx);
          t(ddindx).attribute10 := a27(indx);
          t(ddindx).attribute11 := a28(indx);
          t(ddindx).attribute12 := a29(indx);
          t(ddindx).attribute13 := a30(indx);
          t(ddindx).attribute14 := a31(indx);
          t(ddindx).attribute15 := a32(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a34(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a36(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a37(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_cure_reports_pub.crtv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_300
    , a18 out nocopy JTF_VARCHAR2_TABLE_300
    , a19 out nocopy JTF_VARCHAR2_TABLE_300
    , a20 out nocopy JTF_VARCHAR2_TABLE_300
    , a21 out nocopy JTF_VARCHAR2_TABLE_300
    , a22 out nocopy JTF_VARCHAR2_TABLE_300
    , a23 out nocopy JTF_VARCHAR2_TABLE_300
    , a24 out nocopy JTF_VARCHAR2_TABLE_300
    , a25 out nocopy JTF_VARCHAR2_TABLE_300
    , a26 out nocopy JTF_VARCHAR2_TABLE_300
    , a27 out nocopy JTF_VARCHAR2_TABLE_300
    , a28 out nocopy JTF_VARCHAR2_TABLE_300
    , a29 out nocopy JTF_VARCHAR2_TABLE_300
    , a30 out nocopy JTF_VARCHAR2_TABLE_300
    , a31 out nocopy JTF_VARCHAR2_TABLE_300
    , a32 out nocopy JTF_VARCHAR2_TABLE_300
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_DATE_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_DATE_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_2000();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_VARCHAR2_TABLE_300();
    a18 := JTF_VARCHAR2_TABLE_300();
    a19 := JTF_VARCHAR2_TABLE_300();
    a20 := JTF_VARCHAR2_TABLE_300();
    a21 := JTF_VARCHAR2_TABLE_300();
    a22 := JTF_VARCHAR2_TABLE_300();
    a23 := JTF_VARCHAR2_TABLE_300();
    a24 := JTF_VARCHAR2_TABLE_300();
    a25 := JTF_VARCHAR2_TABLE_300();
    a26 := JTF_VARCHAR2_TABLE_300();
    a27 := JTF_VARCHAR2_TABLE_300();
    a28 := JTF_VARCHAR2_TABLE_300();
    a29 := JTF_VARCHAR2_TABLE_300();
    a30 := JTF_VARCHAR2_TABLE_300();
    a31 := JTF_VARCHAR2_TABLE_300();
    a32 := JTF_VARCHAR2_TABLE_300();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_DATE_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_DATE_TABLE();
    a37 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_2000();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_VARCHAR2_TABLE_300();
      a18 := JTF_VARCHAR2_TABLE_300();
      a19 := JTF_VARCHAR2_TABLE_300();
      a20 := JTF_VARCHAR2_TABLE_300();
      a21 := JTF_VARCHAR2_TABLE_300();
      a22 := JTF_VARCHAR2_TABLE_300();
      a23 := JTF_VARCHAR2_TABLE_300();
      a24 := JTF_VARCHAR2_TABLE_300();
      a25 := JTF_VARCHAR2_TABLE_300();
      a26 := JTF_VARCHAR2_TABLE_300();
      a27 := JTF_VARCHAR2_TABLE_300();
      a28 := JTF_VARCHAR2_TABLE_300();
      a29 := JTF_VARCHAR2_TABLE_300();
      a30 := JTF_VARCHAR2_TABLE_300();
      a31 := JTF_VARCHAR2_TABLE_300();
      a32 := JTF_VARCHAR2_TABLE_300();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_DATE_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_DATE_TABLE();
      a37 := JTF_NUMBER_TABLE();
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
        a20.extend(t.count);
        a21.extend(t.count);
        a22.extend(t.count);
        a23.extend(t.count);
        a24.extend(t.count);
        a25.extend(t.count);
        a26.extend(t.count);
        a27.extend(t.count);
        a28.extend(t.count);
        a29.extend(t.count);
        a30.extend(t.count);
        a31.extend(t.count);
        a32.extend(t.count);
        a33.extend(t.count);
        a34.extend(t.count);
        a35.extend(t.count);
        a36.extend(t.count);
        a37.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).cure_report_id);
          a1(indx) := t(ddindx).report_number;
          a2(indx) := t(ddindx).report_type;
          a3(indx) := t(ddindx).report_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).vendor_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).vendor_site_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).vendor_contact_id);
          a7(indx) := t(ddindx).approval_status;
          a8(indx) := t(ddindx).approval_reason;
          a9(indx) := t(ddindx).expiration_date;
          a10(indx) := t(ddindx).currency_code;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a16(indx) := t(ddindx).program_update_date;
          a17(indx) := t(ddindx).attribute_category;
          a18(indx) := t(ddindx).attribute1;
          a19(indx) := t(ddindx).attribute2;
          a20(indx) := t(ddindx).attribute3;
          a21(indx) := t(ddindx).attribute4;
          a22(indx) := t(ddindx).attribute5;
          a23(indx) := t(ddindx).attribute6;
          a24(indx) := t(ddindx).attribute7;
          a25(indx) := t(ddindx).attribute8;
          a26(indx) := t(ddindx).attribute9;
          a27(indx) := t(ddindx).attribute10;
          a28(indx) := t(ddindx).attribute11;
          a29(indx) := t(ddindx).attribute12;
          a30(indx) := t(ddindx).attribute13;
          a31(indx) := t(ddindx).attribute14;
          a32(indx) := t(ddindx).attribute15;
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a34(indx) := t(ddindx).creation_date;
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a36(indx) := t(ddindx).last_update_date;
          a37(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure insert_cure_reports(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_300
    , p5_a18 JTF_VARCHAR2_TABLE_300
    , p5_a19 JTF_VARCHAR2_TABLE_300
    , p5_a20 JTF_VARCHAR2_TABLE_300
    , p5_a21 JTF_VARCHAR2_TABLE_300
    , p5_a22 JTF_VARCHAR2_TABLE_300
    , p5_a23 JTF_VARCHAR2_TABLE_300
    , p5_a24 JTF_VARCHAR2_TABLE_300
    , p5_a25 JTF_VARCHAR2_TABLE_300
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p5_a27 JTF_VARCHAR2_TABLE_300
    , p5_a28 JTF_VARCHAR2_TABLE_300
    , p5_a29 JTF_VARCHAR2_TABLE_300
    , p5_a30 JTF_VARCHAR2_TABLE_300
    , p5_a31 JTF_VARCHAR2_TABLE_300
    , p5_a32 JTF_VARCHAR2_TABLE_300
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_DATE_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_DATE_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_crtv_tbl okl_cure_reports_pub.crtv_tbl_type;
    ddx_crtv_tbl okl_cure_reports_pub.crtv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cure_reports_pub_w.rosetta_table_copy_in_p2(ddp_crtv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_cure_reports_pub.insert_cure_reports(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_crtv_tbl,
      ddx_crtv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_cure_reports_pub_w.rosetta_table_copy_out_p2(ddx_crtv_tbl, p6_a0
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
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      , p6_a37
      );
  end;

  procedure insert_cure_reports(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  DATE
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
  )

  as
    ddp_crtv_rec okl_cure_reports_pub.crtv_rec_type;
    ddx_crtv_rec okl_cure_reports_pub.crtv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_crtv_rec.cure_report_id := rosetta_g_miss_num_map(p5_a0);
    ddp_crtv_rec.report_number := p5_a1;
    ddp_crtv_rec.report_type := p5_a2;
    ddp_crtv_rec.report_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_crtv_rec.vendor_id := rosetta_g_miss_num_map(p5_a4);
    ddp_crtv_rec.vendor_site_id := rosetta_g_miss_num_map(p5_a5);
    ddp_crtv_rec.vendor_contact_id := rosetta_g_miss_num_map(p5_a6);
    ddp_crtv_rec.approval_status := p5_a7;
    ddp_crtv_rec.approval_reason := p5_a8;
    ddp_crtv_rec.expiration_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_crtv_rec.currency_code := p5_a10;
    ddp_crtv_rec.object_version_number := rosetta_g_miss_num_map(p5_a11);
    ddp_crtv_rec.org_id := rosetta_g_miss_num_map(p5_a12);
    ddp_crtv_rec.request_id := rosetta_g_miss_num_map(p5_a13);
    ddp_crtv_rec.program_application_id := rosetta_g_miss_num_map(p5_a14);
    ddp_crtv_rec.program_id := rosetta_g_miss_num_map(p5_a15);
    ddp_crtv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_crtv_rec.attribute_category := p5_a17;
    ddp_crtv_rec.attribute1 := p5_a18;
    ddp_crtv_rec.attribute2 := p5_a19;
    ddp_crtv_rec.attribute3 := p5_a20;
    ddp_crtv_rec.attribute4 := p5_a21;
    ddp_crtv_rec.attribute5 := p5_a22;
    ddp_crtv_rec.attribute6 := p5_a23;
    ddp_crtv_rec.attribute7 := p5_a24;
    ddp_crtv_rec.attribute8 := p5_a25;
    ddp_crtv_rec.attribute9 := p5_a26;
    ddp_crtv_rec.attribute10 := p5_a27;
    ddp_crtv_rec.attribute11 := p5_a28;
    ddp_crtv_rec.attribute12 := p5_a29;
    ddp_crtv_rec.attribute13 := p5_a30;
    ddp_crtv_rec.attribute14 := p5_a31;
    ddp_crtv_rec.attribute15 := p5_a32;
    ddp_crtv_rec.created_by := rosetta_g_miss_num_map(p5_a33);
    ddp_crtv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_crtv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a35);
    ddp_crtv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_crtv_rec.last_update_login := rosetta_g_miss_num_map(p5_a37);


    -- here's the delegated call to the old PL/SQL routine
    okl_cure_reports_pub.insert_cure_reports(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_crtv_rec,
      ddx_crtv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_crtv_rec.cure_report_id);
    p6_a1 := ddx_crtv_rec.report_number;
    p6_a2 := ddx_crtv_rec.report_type;
    p6_a3 := ddx_crtv_rec.report_date;
    p6_a4 := rosetta_g_miss_num_map(ddx_crtv_rec.vendor_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_crtv_rec.vendor_site_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_crtv_rec.vendor_contact_id);
    p6_a7 := ddx_crtv_rec.approval_status;
    p6_a8 := ddx_crtv_rec.approval_reason;
    p6_a9 := ddx_crtv_rec.expiration_date;
    p6_a10 := ddx_crtv_rec.currency_code;
    p6_a11 := rosetta_g_miss_num_map(ddx_crtv_rec.object_version_number);
    p6_a12 := rosetta_g_miss_num_map(ddx_crtv_rec.org_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_crtv_rec.request_id);
    p6_a14 := rosetta_g_miss_num_map(ddx_crtv_rec.program_application_id);
    p6_a15 := rosetta_g_miss_num_map(ddx_crtv_rec.program_id);
    p6_a16 := ddx_crtv_rec.program_update_date;
    p6_a17 := ddx_crtv_rec.attribute_category;
    p6_a18 := ddx_crtv_rec.attribute1;
    p6_a19 := ddx_crtv_rec.attribute2;
    p6_a20 := ddx_crtv_rec.attribute3;
    p6_a21 := ddx_crtv_rec.attribute4;
    p6_a22 := ddx_crtv_rec.attribute5;
    p6_a23 := ddx_crtv_rec.attribute6;
    p6_a24 := ddx_crtv_rec.attribute7;
    p6_a25 := ddx_crtv_rec.attribute8;
    p6_a26 := ddx_crtv_rec.attribute9;
    p6_a27 := ddx_crtv_rec.attribute10;
    p6_a28 := ddx_crtv_rec.attribute11;
    p6_a29 := ddx_crtv_rec.attribute12;
    p6_a30 := ddx_crtv_rec.attribute13;
    p6_a31 := ddx_crtv_rec.attribute14;
    p6_a32 := ddx_crtv_rec.attribute15;
    p6_a33 := rosetta_g_miss_num_map(ddx_crtv_rec.created_by);
    p6_a34 := ddx_crtv_rec.creation_date;
    p6_a35 := rosetta_g_miss_num_map(ddx_crtv_rec.last_updated_by);
    p6_a36 := ddx_crtv_rec.last_update_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_crtv_rec.last_update_login);
  end;

  procedure lock_cure_reports(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_300
    , p5_a18 JTF_VARCHAR2_TABLE_300
    , p5_a19 JTF_VARCHAR2_TABLE_300
    , p5_a20 JTF_VARCHAR2_TABLE_300
    , p5_a21 JTF_VARCHAR2_TABLE_300
    , p5_a22 JTF_VARCHAR2_TABLE_300
    , p5_a23 JTF_VARCHAR2_TABLE_300
    , p5_a24 JTF_VARCHAR2_TABLE_300
    , p5_a25 JTF_VARCHAR2_TABLE_300
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p5_a27 JTF_VARCHAR2_TABLE_300
    , p5_a28 JTF_VARCHAR2_TABLE_300
    , p5_a29 JTF_VARCHAR2_TABLE_300
    , p5_a30 JTF_VARCHAR2_TABLE_300
    , p5_a31 JTF_VARCHAR2_TABLE_300
    , p5_a32 JTF_VARCHAR2_TABLE_300
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
  )

  as
    ddp_crtv_tbl okl_cure_reports_pub.crtv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cure_reports_pub_w.rosetta_table_copy_in_p2(ddp_crtv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_cure_reports_pub.lock_cure_reports(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_crtv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_cure_reports(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
  )

  as
    ddp_crtv_rec okl_cure_reports_pub.crtv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_crtv_rec.cure_report_id := rosetta_g_miss_num_map(p5_a0);
    ddp_crtv_rec.report_number := p5_a1;
    ddp_crtv_rec.report_type := p5_a2;
    ddp_crtv_rec.report_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_crtv_rec.vendor_id := rosetta_g_miss_num_map(p5_a4);
    ddp_crtv_rec.vendor_site_id := rosetta_g_miss_num_map(p5_a5);
    ddp_crtv_rec.vendor_contact_id := rosetta_g_miss_num_map(p5_a6);
    ddp_crtv_rec.approval_status := p5_a7;
    ddp_crtv_rec.approval_reason := p5_a8;
    ddp_crtv_rec.expiration_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_crtv_rec.currency_code := p5_a10;
    ddp_crtv_rec.object_version_number := rosetta_g_miss_num_map(p5_a11);
    ddp_crtv_rec.org_id := rosetta_g_miss_num_map(p5_a12);
    ddp_crtv_rec.request_id := rosetta_g_miss_num_map(p5_a13);
    ddp_crtv_rec.program_application_id := rosetta_g_miss_num_map(p5_a14);
    ddp_crtv_rec.program_id := rosetta_g_miss_num_map(p5_a15);
    ddp_crtv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_crtv_rec.attribute_category := p5_a17;
    ddp_crtv_rec.attribute1 := p5_a18;
    ddp_crtv_rec.attribute2 := p5_a19;
    ddp_crtv_rec.attribute3 := p5_a20;
    ddp_crtv_rec.attribute4 := p5_a21;
    ddp_crtv_rec.attribute5 := p5_a22;
    ddp_crtv_rec.attribute6 := p5_a23;
    ddp_crtv_rec.attribute7 := p5_a24;
    ddp_crtv_rec.attribute8 := p5_a25;
    ddp_crtv_rec.attribute9 := p5_a26;
    ddp_crtv_rec.attribute10 := p5_a27;
    ddp_crtv_rec.attribute11 := p5_a28;
    ddp_crtv_rec.attribute12 := p5_a29;
    ddp_crtv_rec.attribute13 := p5_a30;
    ddp_crtv_rec.attribute14 := p5_a31;
    ddp_crtv_rec.attribute15 := p5_a32;
    ddp_crtv_rec.created_by := rosetta_g_miss_num_map(p5_a33);
    ddp_crtv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_crtv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a35);
    ddp_crtv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_crtv_rec.last_update_login := rosetta_g_miss_num_map(p5_a37);

    -- here's the delegated call to the old PL/SQL routine
    okl_cure_reports_pub.lock_cure_reports(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_crtv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_cure_reports(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_300
    , p5_a18 JTF_VARCHAR2_TABLE_300
    , p5_a19 JTF_VARCHAR2_TABLE_300
    , p5_a20 JTF_VARCHAR2_TABLE_300
    , p5_a21 JTF_VARCHAR2_TABLE_300
    , p5_a22 JTF_VARCHAR2_TABLE_300
    , p5_a23 JTF_VARCHAR2_TABLE_300
    , p5_a24 JTF_VARCHAR2_TABLE_300
    , p5_a25 JTF_VARCHAR2_TABLE_300
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p5_a27 JTF_VARCHAR2_TABLE_300
    , p5_a28 JTF_VARCHAR2_TABLE_300
    , p5_a29 JTF_VARCHAR2_TABLE_300
    , p5_a30 JTF_VARCHAR2_TABLE_300
    , p5_a31 JTF_VARCHAR2_TABLE_300
    , p5_a32 JTF_VARCHAR2_TABLE_300
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_DATE_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_DATE_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_crtv_tbl okl_cure_reports_pub.crtv_tbl_type;
    ddx_crtv_tbl okl_cure_reports_pub.crtv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cure_reports_pub_w.rosetta_table_copy_in_p2(ddp_crtv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_cure_reports_pub.update_cure_reports(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_crtv_tbl,
      ddx_crtv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_cure_reports_pub_w.rosetta_table_copy_out_p2(ddx_crtv_tbl, p6_a0
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
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      , p6_a37
      );
  end;

  procedure update_cure_reports(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  DATE
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
  )

  as
    ddp_crtv_rec okl_cure_reports_pub.crtv_rec_type;
    ddx_crtv_rec okl_cure_reports_pub.crtv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_crtv_rec.cure_report_id := rosetta_g_miss_num_map(p5_a0);
    ddp_crtv_rec.report_number := p5_a1;
    ddp_crtv_rec.report_type := p5_a2;
    ddp_crtv_rec.report_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_crtv_rec.vendor_id := rosetta_g_miss_num_map(p5_a4);
    ddp_crtv_rec.vendor_site_id := rosetta_g_miss_num_map(p5_a5);
    ddp_crtv_rec.vendor_contact_id := rosetta_g_miss_num_map(p5_a6);
    ddp_crtv_rec.approval_status := p5_a7;
    ddp_crtv_rec.approval_reason := p5_a8;
    ddp_crtv_rec.expiration_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_crtv_rec.currency_code := p5_a10;
    ddp_crtv_rec.object_version_number := rosetta_g_miss_num_map(p5_a11);
    ddp_crtv_rec.org_id := rosetta_g_miss_num_map(p5_a12);
    ddp_crtv_rec.request_id := rosetta_g_miss_num_map(p5_a13);
    ddp_crtv_rec.program_application_id := rosetta_g_miss_num_map(p5_a14);
    ddp_crtv_rec.program_id := rosetta_g_miss_num_map(p5_a15);
    ddp_crtv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_crtv_rec.attribute_category := p5_a17;
    ddp_crtv_rec.attribute1 := p5_a18;
    ddp_crtv_rec.attribute2 := p5_a19;
    ddp_crtv_rec.attribute3 := p5_a20;
    ddp_crtv_rec.attribute4 := p5_a21;
    ddp_crtv_rec.attribute5 := p5_a22;
    ddp_crtv_rec.attribute6 := p5_a23;
    ddp_crtv_rec.attribute7 := p5_a24;
    ddp_crtv_rec.attribute8 := p5_a25;
    ddp_crtv_rec.attribute9 := p5_a26;
    ddp_crtv_rec.attribute10 := p5_a27;
    ddp_crtv_rec.attribute11 := p5_a28;
    ddp_crtv_rec.attribute12 := p5_a29;
    ddp_crtv_rec.attribute13 := p5_a30;
    ddp_crtv_rec.attribute14 := p5_a31;
    ddp_crtv_rec.attribute15 := p5_a32;
    ddp_crtv_rec.created_by := rosetta_g_miss_num_map(p5_a33);
    ddp_crtv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_crtv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a35);
    ddp_crtv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_crtv_rec.last_update_login := rosetta_g_miss_num_map(p5_a37);


    -- here's the delegated call to the old PL/SQL routine
    okl_cure_reports_pub.update_cure_reports(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_crtv_rec,
      ddx_crtv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_crtv_rec.cure_report_id);
    p6_a1 := ddx_crtv_rec.report_number;
    p6_a2 := ddx_crtv_rec.report_type;
    p6_a3 := ddx_crtv_rec.report_date;
    p6_a4 := rosetta_g_miss_num_map(ddx_crtv_rec.vendor_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_crtv_rec.vendor_site_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_crtv_rec.vendor_contact_id);
    p6_a7 := ddx_crtv_rec.approval_status;
    p6_a8 := ddx_crtv_rec.approval_reason;
    p6_a9 := ddx_crtv_rec.expiration_date;
    p6_a10 := ddx_crtv_rec.currency_code;
    p6_a11 := rosetta_g_miss_num_map(ddx_crtv_rec.object_version_number);
    p6_a12 := rosetta_g_miss_num_map(ddx_crtv_rec.org_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_crtv_rec.request_id);
    p6_a14 := rosetta_g_miss_num_map(ddx_crtv_rec.program_application_id);
    p6_a15 := rosetta_g_miss_num_map(ddx_crtv_rec.program_id);
    p6_a16 := ddx_crtv_rec.program_update_date;
    p6_a17 := ddx_crtv_rec.attribute_category;
    p6_a18 := ddx_crtv_rec.attribute1;
    p6_a19 := ddx_crtv_rec.attribute2;
    p6_a20 := ddx_crtv_rec.attribute3;
    p6_a21 := ddx_crtv_rec.attribute4;
    p6_a22 := ddx_crtv_rec.attribute5;
    p6_a23 := ddx_crtv_rec.attribute6;
    p6_a24 := ddx_crtv_rec.attribute7;
    p6_a25 := ddx_crtv_rec.attribute8;
    p6_a26 := ddx_crtv_rec.attribute9;
    p6_a27 := ddx_crtv_rec.attribute10;
    p6_a28 := ddx_crtv_rec.attribute11;
    p6_a29 := ddx_crtv_rec.attribute12;
    p6_a30 := ddx_crtv_rec.attribute13;
    p6_a31 := ddx_crtv_rec.attribute14;
    p6_a32 := ddx_crtv_rec.attribute15;
    p6_a33 := rosetta_g_miss_num_map(ddx_crtv_rec.created_by);
    p6_a34 := ddx_crtv_rec.creation_date;
    p6_a35 := rosetta_g_miss_num_map(ddx_crtv_rec.last_updated_by);
    p6_a36 := ddx_crtv_rec.last_update_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_crtv_rec.last_update_login);
  end;

  procedure delete_cure_reports(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_300
    , p5_a18 JTF_VARCHAR2_TABLE_300
    , p5_a19 JTF_VARCHAR2_TABLE_300
    , p5_a20 JTF_VARCHAR2_TABLE_300
    , p5_a21 JTF_VARCHAR2_TABLE_300
    , p5_a22 JTF_VARCHAR2_TABLE_300
    , p5_a23 JTF_VARCHAR2_TABLE_300
    , p5_a24 JTF_VARCHAR2_TABLE_300
    , p5_a25 JTF_VARCHAR2_TABLE_300
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p5_a27 JTF_VARCHAR2_TABLE_300
    , p5_a28 JTF_VARCHAR2_TABLE_300
    , p5_a29 JTF_VARCHAR2_TABLE_300
    , p5_a30 JTF_VARCHAR2_TABLE_300
    , p5_a31 JTF_VARCHAR2_TABLE_300
    , p5_a32 JTF_VARCHAR2_TABLE_300
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
  )

  as
    ddp_crtv_tbl okl_cure_reports_pub.crtv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cure_reports_pub_w.rosetta_table_copy_in_p2(ddp_crtv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_cure_reports_pub.delete_cure_reports(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_crtv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_cure_reports(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
  )

  as
    ddp_crtv_rec okl_cure_reports_pub.crtv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_crtv_rec.cure_report_id := rosetta_g_miss_num_map(p5_a0);
    ddp_crtv_rec.report_number := p5_a1;
    ddp_crtv_rec.report_type := p5_a2;
    ddp_crtv_rec.report_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_crtv_rec.vendor_id := rosetta_g_miss_num_map(p5_a4);
    ddp_crtv_rec.vendor_site_id := rosetta_g_miss_num_map(p5_a5);
    ddp_crtv_rec.vendor_contact_id := rosetta_g_miss_num_map(p5_a6);
    ddp_crtv_rec.approval_status := p5_a7;
    ddp_crtv_rec.approval_reason := p5_a8;
    ddp_crtv_rec.expiration_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_crtv_rec.currency_code := p5_a10;
    ddp_crtv_rec.object_version_number := rosetta_g_miss_num_map(p5_a11);
    ddp_crtv_rec.org_id := rosetta_g_miss_num_map(p5_a12);
    ddp_crtv_rec.request_id := rosetta_g_miss_num_map(p5_a13);
    ddp_crtv_rec.program_application_id := rosetta_g_miss_num_map(p5_a14);
    ddp_crtv_rec.program_id := rosetta_g_miss_num_map(p5_a15);
    ddp_crtv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_crtv_rec.attribute_category := p5_a17;
    ddp_crtv_rec.attribute1 := p5_a18;
    ddp_crtv_rec.attribute2 := p5_a19;
    ddp_crtv_rec.attribute3 := p5_a20;
    ddp_crtv_rec.attribute4 := p5_a21;
    ddp_crtv_rec.attribute5 := p5_a22;
    ddp_crtv_rec.attribute6 := p5_a23;
    ddp_crtv_rec.attribute7 := p5_a24;
    ddp_crtv_rec.attribute8 := p5_a25;
    ddp_crtv_rec.attribute9 := p5_a26;
    ddp_crtv_rec.attribute10 := p5_a27;
    ddp_crtv_rec.attribute11 := p5_a28;
    ddp_crtv_rec.attribute12 := p5_a29;
    ddp_crtv_rec.attribute13 := p5_a30;
    ddp_crtv_rec.attribute14 := p5_a31;
    ddp_crtv_rec.attribute15 := p5_a32;
    ddp_crtv_rec.created_by := rosetta_g_miss_num_map(p5_a33);
    ddp_crtv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_crtv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a35);
    ddp_crtv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_crtv_rec.last_update_login := rosetta_g_miss_num_map(p5_a37);

    -- here's the delegated call to the old PL/SQL routine
    okl_cure_reports_pub.delete_cure_reports(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_crtv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_cure_reports(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_300
    , p5_a18 JTF_VARCHAR2_TABLE_300
    , p5_a19 JTF_VARCHAR2_TABLE_300
    , p5_a20 JTF_VARCHAR2_TABLE_300
    , p5_a21 JTF_VARCHAR2_TABLE_300
    , p5_a22 JTF_VARCHAR2_TABLE_300
    , p5_a23 JTF_VARCHAR2_TABLE_300
    , p5_a24 JTF_VARCHAR2_TABLE_300
    , p5_a25 JTF_VARCHAR2_TABLE_300
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p5_a27 JTF_VARCHAR2_TABLE_300
    , p5_a28 JTF_VARCHAR2_TABLE_300
    , p5_a29 JTF_VARCHAR2_TABLE_300
    , p5_a30 JTF_VARCHAR2_TABLE_300
    , p5_a31 JTF_VARCHAR2_TABLE_300
    , p5_a32 JTF_VARCHAR2_TABLE_300
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
  )

  as
    ddp_crtv_tbl okl_cure_reports_pub.crtv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cure_reports_pub_w.rosetta_table_copy_in_p2(ddp_crtv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_cure_reports_pub.validate_cure_reports(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_crtv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_cure_reports(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
  )

  as
    ddp_crtv_rec okl_cure_reports_pub.crtv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_crtv_rec.cure_report_id := rosetta_g_miss_num_map(p5_a0);
    ddp_crtv_rec.report_number := p5_a1;
    ddp_crtv_rec.report_type := p5_a2;
    ddp_crtv_rec.report_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_crtv_rec.vendor_id := rosetta_g_miss_num_map(p5_a4);
    ddp_crtv_rec.vendor_site_id := rosetta_g_miss_num_map(p5_a5);
    ddp_crtv_rec.vendor_contact_id := rosetta_g_miss_num_map(p5_a6);
    ddp_crtv_rec.approval_status := p5_a7;
    ddp_crtv_rec.approval_reason := p5_a8;
    ddp_crtv_rec.expiration_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_crtv_rec.currency_code := p5_a10;
    ddp_crtv_rec.object_version_number := rosetta_g_miss_num_map(p5_a11);
    ddp_crtv_rec.org_id := rosetta_g_miss_num_map(p5_a12);
    ddp_crtv_rec.request_id := rosetta_g_miss_num_map(p5_a13);
    ddp_crtv_rec.program_application_id := rosetta_g_miss_num_map(p5_a14);
    ddp_crtv_rec.program_id := rosetta_g_miss_num_map(p5_a15);
    ddp_crtv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_crtv_rec.attribute_category := p5_a17;
    ddp_crtv_rec.attribute1 := p5_a18;
    ddp_crtv_rec.attribute2 := p5_a19;
    ddp_crtv_rec.attribute3 := p5_a20;
    ddp_crtv_rec.attribute4 := p5_a21;
    ddp_crtv_rec.attribute5 := p5_a22;
    ddp_crtv_rec.attribute6 := p5_a23;
    ddp_crtv_rec.attribute7 := p5_a24;
    ddp_crtv_rec.attribute8 := p5_a25;
    ddp_crtv_rec.attribute9 := p5_a26;
    ddp_crtv_rec.attribute10 := p5_a27;
    ddp_crtv_rec.attribute11 := p5_a28;
    ddp_crtv_rec.attribute12 := p5_a29;
    ddp_crtv_rec.attribute13 := p5_a30;
    ddp_crtv_rec.attribute14 := p5_a31;
    ddp_crtv_rec.attribute15 := p5_a32;
    ddp_crtv_rec.created_by := rosetta_g_miss_num_map(p5_a33);
    ddp_crtv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_crtv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a35);
    ddp_crtv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_crtv_rec.last_update_login := rosetta_g_miss_num_map(p5_a37);

    -- here's the delegated call to the old PL/SQL routine
    okl_cure_reports_pub.validate_cure_reports(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_crtv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_cure_reports_pub_w;

/
