--------------------------------------------------------
--  DDL for Package Body OKL_DRV_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_DRV_PVT_W" as
  /* $Header: OKLIDRVB.pls 120.0 2007/04/27 09:18:48 gkhuntet noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_high date := to_date('01/01/+4710', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_low date := to_date('01/01/-4710', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d > rosetta_g_mistake_date_high then return fnd_api.g_miss_date; end if;
    if d < rosetta_g_mistake_date_low then return fnd_api.g_miss_date; end if;
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_drv_pvt.drv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_500
    , a12 JTF_VARCHAR2_TABLE_500
    , a13 JTF_VARCHAR2_TABLE_500
    , a14 JTF_VARCHAR2_TABLE_500
    , a15 JTF_VARCHAR2_TABLE_500
    , a16 JTF_VARCHAR2_TABLE_500
    , a17 JTF_VARCHAR2_TABLE_500
    , a18 JTF_VARCHAR2_TABLE_500
    , a19 JTF_VARCHAR2_TABLE_500
    , a20 JTF_VARCHAR2_TABLE_500
    , a21 JTF_VARCHAR2_TABLE_500
    , a22 JTF_VARCHAR2_TABLE_500
    , a23 JTF_VARCHAR2_TABLE_500
    , a24 JTF_VARCHAR2_TABLE_500
    , a25 JTF_VARCHAR2_TABLE_500
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_DATE_TABLE
    , a30 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).disb_rule_vendor_site_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).disb_rule_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).vendor_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).vendor_site_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).invoice_seq_start := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).invoice_seq_end := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).next_inv_seq := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).attribute_category := a10(indx);
          t(ddindx).attribute1 := a11(indx);
          t(ddindx).attribute2 := a12(indx);
          t(ddindx).attribute3 := a13(indx);
          t(ddindx).attribute4 := a14(indx);
          t(ddindx).attribute5 := a15(indx);
          t(ddindx).attribute6 := a16(indx);
          t(ddindx).attribute7 := a17(indx);
          t(ddindx).attribute8 := a18(indx);
          t(ddindx).attribute9 := a19(indx);
          t(ddindx).attribute10 := a20(indx);
          t(ddindx).attribute11 := a21(indx);
          t(ddindx).attribute12 := a22(indx);
          t(ddindx).attribute13 := a23(indx);
          t(ddindx).attribute14 := a24(indx);
          t(ddindx).attribute15 := a25(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a27(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a29(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a30(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_drv_pvt.drv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_500
    , a12 out nocopy JTF_VARCHAR2_TABLE_500
    , a13 out nocopy JTF_VARCHAR2_TABLE_500
    , a14 out nocopy JTF_VARCHAR2_TABLE_500
    , a15 out nocopy JTF_VARCHAR2_TABLE_500
    , a16 out nocopy JTF_VARCHAR2_TABLE_500
    , a17 out nocopy JTF_VARCHAR2_TABLE_500
    , a18 out nocopy JTF_VARCHAR2_TABLE_500
    , a19 out nocopy JTF_VARCHAR2_TABLE_500
    , a20 out nocopy JTF_VARCHAR2_TABLE_500
    , a21 out nocopy JTF_VARCHAR2_TABLE_500
    , a22 out nocopy JTF_VARCHAR2_TABLE_500
    , a23 out nocopy JTF_VARCHAR2_TABLE_500
    , a24 out nocopy JTF_VARCHAR2_TABLE_500
    , a25 out nocopy JTF_VARCHAR2_TABLE_500
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_DATE_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_500();
    a12 := JTF_VARCHAR2_TABLE_500();
    a13 := JTF_VARCHAR2_TABLE_500();
    a14 := JTF_VARCHAR2_TABLE_500();
    a15 := JTF_VARCHAR2_TABLE_500();
    a16 := JTF_VARCHAR2_TABLE_500();
    a17 := JTF_VARCHAR2_TABLE_500();
    a18 := JTF_VARCHAR2_TABLE_500();
    a19 := JTF_VARCHAR2_TABLE_500();
    a20 := JTF_VARCHAR2_TABLE_500();
    a21 := JTF_VARCHAR2_TABLE_500();
    a22 := JTF_VARCHAR2_TABLE_500();
    a23 := JTF_VARCHAR2_TABLE_500();
    a24 := JTF_VARCHAR2_TABLE_500();
    a25 := JTF_VARCHAR2_TABLE_500();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_DATE_TABLE();
    a30 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_500();
      a12 := JTF_VARCHAR2_TABLE_500();
      a13 := JTF_VARCHAR2_TABLE_500();
      a14 := JTF_VARCHAR2_TABLE_500();
      a15 := JTF_VARCHAR2_TABLE_500();
      a16 := JTF_VARCHAR2_TABLE_500();
      a17 := JTF_VARCHAR2_TABLE_500();
      a18 := JTF_VARCHAR2_TABLE_500();
      a19 := JTF_VARCHAR2_TABLE_500();
      a20 := JTF_VARCHAR2_TABLE_500();
      a21 := JTF_VARCHAR2_TABLE_500();
      a22 := JTF_VARCHAR2_TABLE_500();
      a23 := JTF_VARCHAR2_TABLE_500();
      a24 := JTF_VARCHAR2_TABLE_500();
      a25 := JTF_VARCHAR2_TABLE_500();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_DATE_TABLE();
      a30 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).disb_rule_vendor_site_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).disb_rule_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).vendor_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).vendor_site_id);
          a5(indx) := t(ddindx).start_date;
          a6(indx) := t(ddindx).end_date;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_seq_start);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_seq_end);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).next_inv_seq);
          a10(indx) := t(ddindx).attribute_category;
          a11(indx) := t(ddindx).attribute1;
          a12(indx) := t(ddindx).attribute2;
          a13(indx) := t(ddindx).attribute3;
          a14(indx) := t(ddindx).attribute4;
          a15(indx) := t(ddindx).attribute5;
          a16(indx) := t(ddindx).attribute6;
          a17(indx) := t(ddindx).attribute7;
          a18(indx) := t(ddindx).attribute8;
          a19(indx) := t(ddindx).attribute9;
          a20(indx) := t(ddindx).attribute10;
          a21(indx) := t(ddindx).attribute11;
          a22(indx) := t(ddindx).attribute12;
          a23(indx) := t(ddindx).attribute13;
          a24(indx) := t(ddindx).attribute14;
          a25(indx) := t(ddindx).attribute15;
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a27(indx) := t(ddindx).creation_date;
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a29(indx) := t(ddindx).last_update_date;
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  DATE
    , p6_a30 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
  )

  as
    ddp_drv_rec okl_drv_pvt.drv_rec_type;
    ddx_drv_rec okl_drv_pvt.drv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_drv_rec.disb_rule_vendor_site_id := rosetta_g_miss_num_map(p5_a0);
    ddp_drv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_drv_rec.disb_rule_id := rosetta_g_miss_num_map(p5_a2);
    ddp_drv_rec.vendor_id := rosetta_g_miss_num_map(p5_a3);
    ddp_drv_rec.vendor_site_id := rosetta_g_miss_num_map(p5_a4);
    ddp_drv_rec.start_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_drv_rec.end_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_drv_rec.invoice_seq_start := rosetta_g_miss_num_map(p5_a7);
    ddp_drv_rec.invoice_seq_end := rosetta_g_miss_num_map(p5_a8);
    ddp_drv_rec.next_inv_seq := rosetta_g_miss_num_map(p5_a9);
    ddp_drv_rec.attribute_category := p5_a10;
    ddp_drv_rec.attribute1 := p5_a11;
    ddp_drv_rec.attribute2 := p5_a12;
    ddp_drv_rec.attribute3 := p5_a13;
    ddp_drv_rec.attribute4 := p5_a14;
    ddp_drv_rec.attribute5 := p5_a15;
    ddp_drv_rec.attribute6 := p5_a16;
    ddp_drv_rec.attribute7 := p5_a17;
    ddp_drv_rec.attribute8 := p5_a18;
    ddp_drv_rec.attribute9 := p5_a19;
    ddp_drv_rec.attribute10 := p5_a20;
    ddp_drv_rec.attribute11 := p5_a21;
    ddp_drv_rec.attribute12 := p5_a22;
    ddp_drv_rec.attribute13 := p5_a23;
    ddp_drv_rec.attribute14 := p5_a24;
    ddp_drv_rec.attribute15 := p5_a25;
    ddp_drv_rec.created_by := rosetta_g_miss_num_map(p5_a26);
    ddp_drv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_drv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a28);
    ddp_drv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_drv_rec.last_update_login := rosetta_g_miss_num_map(p5_a30);


    -- here's the delegated call to the old PL/SQL routine
    okl_drv_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_drv_rec,
      ddx_drv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_drv_rec.disb_rule_vendor_site_id);
    p6_a1 := rosetta_g_miss_num_map(ddx_drv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_drv_rec.disb_rule_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_drv_rec.vendor_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_drv_rec.vendor_site_id);
    p6_a5 := ddx_drv_rec.start_date;
    p6_a6 := ddx_drv_rec.end_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_drv_rec.invoice_seq_start);
    p6_a8 := rosetta_g_miss_num_map(ddx_drv_rec.invoice_seq_end);
    p6_a9 := rosetta_g_miss_num_map(ddx_drv_rec.next_inv_seq);
    p6_a10 := ddx_drv_rec.attribute_category;
    p6_a11 := ddx_drv_rec.attribute1;
    p6_a12 := ddx_drv_rec.attribute2;
    p6_a13 := ddx_drv_rec.attribute3;
    p6_a14 := ddx_drv_rec.attribute4;
    p6_a15 := ddx_drv_rec.attribute5;
    p6_a16 := ddx_drv_rec.attribute6;
    p6_a17 := ddx_drv_rec.attribute7;
    p6_a18 := ddx_drv_rec.attribute8;
    p6_a19 := ddx_drv_rec.attribute9;
    p6_a20 := ddx_drv_rec.attribute10;
    p6_a21 := ddx_drv_rec.attribute11;
    p6_a22 := ddx_drv_rec.attribute12;
    p6_a23 := ddx_drv_rec.attribute13;
    p6_a24 := ddx_drv_rec.attribute14;
    p6_a25 := ddx_drv_rec.attribute15;
    p6_a26 := rosetta_g_miss_num_map(ddx_drv_rec.created_by);
    p6_a27 := ddx_drv_rec.creation_date;
    p6_a28 := rosetta_g_miss_num_map(ddx_drv_rec.last_updated_by);
    p6_a29 := ddx_drv_rec.last_update_date;
    p6_a30 := rosetta_g_miss_num_map(ddx_drv_rec.last_update_login);
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_DATE_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_drv_tbl okl_drv_pvt.drv_tbl_type;
    ddx_drv_tbl okl_drv_pvt.drv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_drv_pvt_w.rosetta_table_copy_in_p2(ddp_drv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_drv_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_drv_tbl,
      ddx_drv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_drv_pvt_w.rosetta_table_copy_out_p2(ddx_drv_tbl, p6_a0
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
      );
  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
  )

  as
    ddp_drv_rec okl_drv_pvt.drv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_drv_rec.disb_rule_vendor_site_id := rosetta_g_miss_num_map(p5_a0);
    ddp_drv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_drv_rec.disb_rule_id := rosetta_g_miss_num_map(p5_a2);
    ddp_drv_rec.vendor_id := rosetta_g_miss_num_map(p5_a3);
    ddp_drv_rec.vendor_site_id := rosetta_g_miss_num_map(p5_a4);
    ddp_drv_rec.start_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_drv_rec.end_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_drv_rec.invoice_seq_start := rosetta_g_miss_num_map(p5_a7);
    ddp_drv_rec.invoice_seq_end := rosetta_g_miss_num_map(p5_a8);
    ddp_drv_rec.next_inv_seq := rosetta_g_miss_num_map(p5_a9);
    ddp_drv_rec.attribute_category := p5_a10;
    ddp_drv_rec.attribute1 := p5_a11;
    ddp_drv_rec.attribute2 := p5_a12;
    ddp_drv_rec.attribute3 := p5_a13;
    ddp_drv_rec.attribute4 := p5_a14;
    ddp_drv_rec.attribute5 := p5_a15;
    ddp_drv_rec.attribute6 := p5_a16;
    ddp_drv_rec.attribute7 := p5_a17;
    ddp_drv_rec.attribute8 := p5_a18;
    ddp_drv_rec.attribute9 := p5_a19;
    ddp_drv_rec.attribute10 := p5_a20;
    ddp_drv_rec.attribute11 := p5_a21;
    ddp_drv_rec.attribute12 := p5_a22;
    ddp_drv_rec.attribute13 := p5_a23;
    ddp_drv_rec.attribute14 := p5_a24;
    ddp_drv_rec.attribute15 := p5_a25;
    ddp_drv_rec.created_by := rosetta_g_miss_num_map(p5_a26);
    ddp_drv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_drv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a28);
    ddp_drv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_drv_rec.last_update_login := rosetta_g_miss_num_map(p5_a30);

    -- here's the delegated call to the old PL/SQL routine
    okl_drv_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_drv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
  )

  as
    ddp_drv_tbl okl_drv_pvt.drv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_drv_pvt_w.rosetta_table_copy_in_p2(ddp_drv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_drv_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_drv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  DATE
    , p6_a30 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
  )

  as
    ddp_drv_rec okl_drv_pvt.drv_rec_type;
    ddx_drv_rec okl_drv_pvt.drv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_drv_rec.disb_rule_vendor_site_id := rosetta_g_miss_num_map(p5_a0);
    ddp_drv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_drv_rec.disb_rule_id := rosetta_g_miss_num_map(p5_a2);
    ddp_drv_rec.vendor_id := rosetta_g_miss_num_map(p5_a3);
    ddp_drv_rec.vendor_site_id := rosetta_g_miss_num_map(p5_a4);
    ddp_drv_rec.start_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_drv_rec.end_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_drv_rec.invoice_seq_start := rosetta_g_miss_num_map(p5_a7);
    ddp_drv_rec.invoice_seq_end := rosetta_g_miss_num_map(p5_a8);
    ddp_drv_rec.next_inv_seq := rosetta_g_miss_num_map(p5_a9);
    ddp_drv_rec.attribute_category := p5_a10;
    ddp_drv_rec.attribute1 := p5_a11;
    ddp_drv_rec.attribute2 := p5_a12;
    ddp_drv_rec.attribute3 := p5_a13;
    ddp_drv_rec.attribute4 := p5_a14;
    ddp_drv_rec.attribute5 := p5_a15;
    ddp_drv_rec.attribute6 := p5_a16;
    ddp_drv_rec.attribute7 := p5_a17;
    ddp_drv_rec.attribute8 := p5_a18;
    ddp_drv_rec.attribute9 := p5_a19;
    ddp_drv_rec.attribute10 := p5_a20;
    ddp_drv_rec.attribute11 := p5_a21;
    ddp_drv_rec.attribute12 := p5_a22;
    ddp_drv_rec.attribute13 := p5_a23;
    ddp_drv_rec.attribute14 := p5_a24;
    ddp_drv_rec.attribute15 := p5_a25;
    ddp_drv_rec.created_by := rosetta_g_miss_num_map(p5_a26);
    ddp_drv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_drv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a28);
    ddp_drv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_drv_rec.last_update_login := rosetta_g_miss_num_map(p5_a30);


    -- here's the delegated call to the old PL/SQL routine
    okl_drv_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_drv_rec,
      ddx_drv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_drv_rec.disb_rule_vendor_site_id);
    p6_a1 := rosetta_g_miss_num_map(ddx_drv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_drv_rec.disb_rule_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_drv_rec.vendor_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_drv_rec.vendor_site_id);
    p6_a5 := ddx_drv_rec.start_date;
    p6_a6 := ddx_drv_rec.end_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_drv_rec.invoice_seq_start);
    p6_a8 := rosetta_g_miss_num_map(ddx_drv_rec.invoice_seq_end);
    p6_a9 := rosetta_g_miss_num_map(ddx_drv_rec.next_inv_seq);
    p6_a10 := ddx_drv_rec.attribute_category;
    p6_a11 := ddx_drv_rec.attribute1;
    p6_a12 := ddx_drv_rec.attribute2;
    p6_a13 := ddx_drv_rec.attribute3;
    p6_a14 := ddx_drv_rec.attribute4;
    p6_a15 := ddx_drv_rec.attribute5;
    p6_a16 := ddx_drv_rec.attribute6;
    p6_a17 := ddx_drv_rec.attribute7;
    p6_a18 := ddx_drv_rec.attribute8;
    p6_a19 := ddx_drv_rec.attribute9;
    p6_a20 := ddx_drv_rec.attribute10;
    p6_a21 := ddx_drv_rec.attribute11;
    p6_a22 := ddx_drv_rec.attribute12;
    p6_a23 := ddx_drv_rec.attribute13;
    p6_a24 := ddx_drv_rec.attribute14;
    p6_a25 := ddx_drv_rec.attribute15;
    p6_a26 := rosetta_g_miss_num_map(ddx_drv_rec.created_by);
    p6_a27 := ddx_drv_rec.creation_date;
    p6_a28 := rosetta_g_miss_num_map(ddx_drv_rec.last_updated_by);
    p6_a29 := ddx_drv_rec.last_update_date;
    p6_a30 := rosetta_g_miss_num_map(ddx_drv_rec.last_update_login);
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_DATE_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_drv_tbl okl_drv_pvt.drv_tbl_type;
    ddx_drv_tbl okl_drv_pvt.drv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_drv_pvt_w.rosetta_table_copy_in_p2(ddp_drv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_drv_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_drv_tbl,
      ddx_drv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_drv_pvt_w.rosetta_table_copy_out_p2(ddx_drv_tbl, p6_a0
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
      );
  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
  )

  as
    ddp_drv_rec okl_drv_pvt.drv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_drv_rec.disb_rule_vendor_site_id := rosetta_g_miss_num_map(p5_a0);
    ddp_drv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_drv_rec.disb_rule_id := rosetta_g_miss_num_map(p5_a2);
    ddp_drv_rec.vendor_id := rosetta_g_miss_num_map(p5_a3);
    ddp_drv_rec.vendor_site_id := rosetta_g_miss_num_map(p5_a4);
    ddp_drv_rec.start_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_drv_rec.end_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_drv_rec.invoice_seq_start := rosetta_g_miss_num_map(p5_a7);
    ddp_drv_rec.invoice_seq_end := rosetta_g_miss_num_map(p5_a8);
    ddp_drv_rec.next_inv_seq := rosetta_g_miss_num_map(p5_a9);
    ddp_drv_rec.attribute_category := p5_a10;
    ddp_drv_rec.attribute1 := p5_a11;
    ddp_drv_rec.attribute2 := p5_a12;
    ddp_drv_rec.attribute3 := p5_a13;
    ddp_drv_rec.attribute4 := p5_a14;
    ddp_drv_rec.attribute5 := p5_a15;
    ddp_drv_rec.attribute6 := p5_a16;
    ddp_drv_rec.attribute7 := p5_a17;
    ddp_drv_rec.attribute8 := p5_a18;
    ddp_drv_rec.attribute9 := p5_a19;
    ddp_drv_rec.attribute10 := p5_a20;
    ddp_drv_rec.attribute11 := p5_a21;
    ddp_drv_rec.attribute12 := p5_a22;
    ddp_drv_rec.attribute13 := p5_a23;
    ddp_drv_rec.attribute14 := p5_a24;
    ddp_drv_rec.attribute15 := p5_a25;
    ddp_drv_rec.created_by := rosetta_g_miss_num_map(p5_a26);
    ddp_drv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_drv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a28);
    ddp_drv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_drv_rec.last_update_login := rosetta_g_miss_num_map(p5_a30);

    -- here's the delegated call to the old PL/SQL routine
    okl_drv_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_drv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
  )

  as
    ddp_drv_tbl okl_drv_pvt.drv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_drv_pvt_w.rosetta_table_copy_in_p2(ddp_drv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_drv_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_drv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
  )

  as
    ddp_drv_rec okl_drv_pvt.drv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_drv_rec.disb_rule_vendor_site_id := rosetta_g_miss_num_map(p5_a0);
    ddp_drv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_drv_rec.disb_rule_id := rosetta_g_miss_num_map(p5_a2);
    ddp_drv_rec.vendor_id := rosetta_g_miss_num_map(p5_a3);
    ddp_drv_rec.vendor_site_id := rosetta_g_miss_num_map(p5_a4);
    ddp_drv_rec.start_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_drv_rec.end_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_drv_rec.invoice_seq_start := rosetta_g_miss_num_map(p5_a7);
    ddp_drv_rec.invoice_seq_end := rosetta_g_miss_num_map(p5_a8);
    ddp_drv_rec.next_inv_seq := rosetta_g_miss_num_map(p5_a9);
    ddp_drv_rec.attribute_category := p5_a10;
    ddp_drv_rec.attribute1 := p5_a11;
    ddp_drv_rec.attribute2 := p5_a12;
    ddp_drv_rec.attribute3 := p5_a13;
    ddp_drv_rec.attribute4 := p5_a14;
    ddp_drv_rec.attribute5 := p5_a15;
    ddp_drv_rec.attribute6 := p5_a16;
    ddp_drv_rec.attribute7 := p5_a17;
    ddp_drv_rec.attribute8 := p5_a18;
    ddp_drv_rec.attribute9 := p5_a19;
    ddp_drv_rec.attribute10 := p5_a20;
    ddp_drv_rec.attribute11 := p5_a21;
    ddp_drv_rec.attribute12 := p5_a22;
    ddp_drv_rec.attribute13 := p5_a23;
    ddp_drv_rec.attribute14 := p5_a24;
    ddp_drv_rec.attribute15 := p5_a25;
    ddp_drv_rec.created_by := rosetta_g_miss_num_map(p5_a26);
    ddp_drv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_drv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a28);
    ddp_drv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_drv_rec.last_update_login := rosetta_g_miss_num_map(p5_a30);

    -- here's the delegated call to the old PL/SQL routine
    okl_drv_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_drv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
  )

  as
    ddp_drv_tbl okl_drv_pvt.drv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_drv_pvt_w.rosetta_table_copy_in_p2(ddp_drv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_drv_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_drv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_drv_pvt_w;

/
