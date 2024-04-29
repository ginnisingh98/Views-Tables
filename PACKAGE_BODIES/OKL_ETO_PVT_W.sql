--------------------------------------------------------
--  DDL for Package Body OKL_ETO_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ETO_PVT_W" as
  /* $Header: OKLIETOB.pls 120.0 2005/07/07 10:38:40 viselvar noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy okl_eto_pvt.okl_eto_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_500
    , a10 JTF_VARCHAR2_TABLE_500
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
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_DATE_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).end_of_term_obj_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).inventory_item_id := a2(indx);
          t(ddindx).organization_id := a3(indx);
          t(ddindx).category_id := a4(indx);
          t(ddindx).category_set_id := a5(indx);
          t(ddindx).resi_category_set_id := a6(indx);
          t(ddindx).end_of_term_ver_id := a7(indx);
          t(ddindx).attribute_category := a8(indx);
          t(ddindx).attribute1 := a9(indx);
          t(ddindx).attribute2 := a10(indx);
          t(ddindx).attribute3 := a11(indx);
          t(ddindx).attribute4 := a12(indx);
          t(ddindx).attribute5 := a13(indx);
          t(ddindx).attribute6 := a14(indx);
          t(ddindx).attribute7 := a15(indx);
          t(ddindx).attribute8 := a16(indx);
          t(ddindx).attribute9 := a17(indx);
          t(ddindx).attribute10 := a18(indx);
          t(ddindx).attribute11 := a19(indx);
          t(ddindx).attribute12 := a20(indx);
          t(ddindx).attribute13 := a21(indx);
          t(ddindx).attribute14 := a22(indx);
          t(ddindx).attribute15 := a23(indx);
          t(ddindx).created_by := a24(indx);
          t(ddindx).creation_date := a25(indx);
          t(ddindx).last_updated_by := a26(indx);
          t(ddindx).last_update_date := a27(indx);
          t(ddindx).last_update_login := a28(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t okl_eto_pvt.okl_eto_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_500
    , a10 out nocopy JTF_VARCHAR2_TABLE_500
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
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_DATE_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_500();
    a10 := JTF_VARCHAR2_TABLE_500();
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
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_DATE_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_500();
      a10 := JTF_VARCHAR2_TABLE_500();
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
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_DATE_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).end_of_term_obj_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).inventory_item_id;
          a3(indx) := t(ddindx).organization_id;
          a4(indx) := t(ddindx).category_id;
          a5(indx) := t(ddindx).category_set_id;
          a6(indx) := t(ddindx).resi_category_set_id;
          a7(indx) := t(ddindx).end_of_term_ver_id;
          a8(indx) := t(ddindx).attribute_category;
          a9(indx) := t(ddindx).attribute1;
          a10(indx) := t(ddindx).attribute2;
          a11(indx) := t(ddindx).attribute3;
          a12(indx) := t(ddindx).attribute4;
          a13(indx) := t(ddindx).attribute5;
          a14(indx) := t(ddindx).attribute6;
          a15(indx) := t(ddindx).attribute7;
          a16(indx) := t(ddindx).attribute8;
          a17(indx) := t(ddindx).attribute9;
          a18(indx) := t(ddindx).attribute10;
          a19(indx) := t(ddindx).attribute11;
          a20(indx) := t(ddindx).attribute12;
          a21(indx) := t(ddindx).attribute13;
          a22(indx) := t(ddindx).attribute14;
          a23(indx) := t(ddindx).attribute15;
          a24(indx) := t(ddindx).created_by;
          a25(indx) := t(ddindx).creation_date;
          a26(indx) := t(ddindx).last_updated_by;
          a27(indx) := t(ddindx).last_update_date;
          a28(indx) := t(ddindx).last_update_login;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  NUMBER
    , p5_a25  DATE
    , p5_a26  NUMBER
    , p5_a27  DATE
    , p5_a28  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
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
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  NUMBER
  )

  as
    ddp_eto_rec okl_eto_pvt.okl_eto_rec;
    ddx_eto_rec okl_eto_pvt.okl_eto_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_eto_rec.end_of_term_obj_id := p5_a0;
    ddp_eto_rec.object_version_number := p5_a1;
    ddp_eto_rec.inventory_item_id := p5_a2;
    ddp_eto_rec.organization_id := p5_a3;
    ddp_eto_rec.category_id := p5_a4;
    ddp_eto_rec.category_set_id := p5_a5;
    ddp_eto_rec.resi_category_set_id := p5_a6;
    ddp_eto_rec.end_of_term_ver_id := p5_a7;
    ddp_eto_rec.attribute_category := p5_a8;
    ddp_eto_rec.attribute1 := p5_a9;
    ddp_eto_rec.attribute2 := p5_a10;
    ddp_eto_rec.attribute3 := p5_a11;
    ddp_eto_rec.attribute4 := p5_a12;
    ddp_eto_rec.attribute5 := p5_a13;
    ddp_eto_rec.attribute6 := p5_a14;
    ddp_eto_rec.attribute7 := p5_a15;
    ddp_eto_rec.attribute8 := p5_a16;
    ddp_eto_rec.attribute9 := p5_a17;
    ddp_eto_rec.attribute10 := p5_a18;
    ddp_eto_rec.attribute11 := p5_a19;
    ddp_eto_rec.attribute12 := p5_a20;
    ddp_eto_rec.attribute13 := p5_a21;
    ddp_eto_rec.attribute14 := p5_a22;
    ddp_eto_rec.attribute15 := p5_a23;
    ddp_eto_rec.created_by := p5_a24;
    ddp_eto_rec.creation_date := p5_a25;
    ddp_eto_rec.last_updated_by := p5_a26;
    ddp_eto_rec.last_update_date := p5_a27;
    ddp_eto_rec.last_update_login := p5_a28;


    -- here's the delegated call to the old PL/SQL routine
    okl_eto_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_eto_rec,
      ddx_eto_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_eto_rec.end_of_term_obj_id;
    p6_a1 := ddx_eto_rec.object_version_number;
    p6_a2 := ddx_eto_rec.inventory_item_id;
    p6_a3 := ddx_eto_rec.organization_id;
    p6_a4 := ddx_eto_rec.category_id;
    p6_a5 := ddx_eto_rec.category_set_id;
    p6_a6 := ddx_eto_rec.resi_category_set_id;
    p6_a7 := ddx_eto_rec.end_of_term_ver_id;
    p6_a8 := ddx_eto_rec.attribute_category;
    p6_a9 := ddx_eto_rec.attribute1;
    p6_a10 := ddx_eto_rec.attribute2;
    p6_a11 := ddx_eto_rec.attribute3;
    p6_a12 := ddx_eto_rec.attribute4;
    p6_a13 := ddx_eto_rec.attribute5;
    p6_a14 := ddx_eto_rec.attribute6;
    p6_a15 := ddx_eto_rec.attribute7;
    p6_a16 := ddx_eto_rec.attribute8;
    p6_a17 := ddx_eto_rec.attribute9;
    p6_a18 := ddx_eto_rec.attribute10;
    p6_a19 := ddx_eto_rec.attribute11;
    p6_a20 := ddx_eto_rec.attribute12;
    p6_a21 := ddx_eto_rec.attribute13;
    p6_a22 := ddx_eto_rec.attribute14;
    p6_a23 := ddx_eto_rec.attribute15;
    p6_a24 := ddx_eto_rec.created_by;
    p6_a25 := ddx_eto_rec.creation_date;
    p6_a26 := ddx_eto_rec.last_updated_by;
    p6_a27 := ddx_eto_rec.last_update_date;
    p6_a28 := ddx_eto_rec.last_update_login;
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
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_500
    , p5_a10 JTF_VARCHAR2_TABLE_500
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
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_eto_tbl okl_eto_pvt.okl_eto_tbl;
    ddx_eto_tbl okl_eto_pvt.okl_eto_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_eto_pvt_w.rosetta_table_copy_in_p1(ddp_eto_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_eto_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_eto_tbl,
      ddx_eto_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_eto_pvt_w.rosetta_table_copy_out_p1(ddx_eto_tbl, p6_a0
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
      );
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  NUMBER
    , p5_a25  DATE
    , p5_a26  NUMBER
    , p5_a27  DATE
    , p5_a28  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
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
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  NUMBER
  )

  as
    ddp_eto_rec okl_eto_pvt.okl_eto_rec;
    ddx_eto_rec okl_eto_pvt.okl_eto_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_eto_rec.end_of_term_obj_id := p5_a0;
    ddp_eto_rec.object_version_number := p5_a1;
    ddp_eto_rec.inventory_item_id := p5_a2;
    ddp_eto_rec.organization_id := p5_a3;
    ddp_eto_rec.category_id := p5_a4;
    ddp_eto_rec.category_set_id := p5_a5;
    ddp_eto_rec.resi_category_set_id := p5_a6;
    ddp_eto_rec.end_of_term_ver_id := p5_a7;
    ddp_eto_rec.attribute_category := p5_a8;
    ddp_eto_rec.attribute1 := p5_a9;
    ddp_eto_rec.attribute2 := p5_a10;
    ddp_eto_rec.attribute3 := p5_a11;
    ddp_eto_rec.attribute4 := p5_a12;
    ddp_eto_rec.attribute5 := p5_a13;
    ddp_eto_rec.attribute6 := p5_a14;
    ddp_eto_rec.attribute7 := p5_a15;
    ddp_eto_rec.attribute8 := p5_a16;
    ddp_eto_rec.attribute9 := p5_a17;
    ddp_eto_rec.attribute10 := p5_a18;
    ddp_eto_rec.attribute11 := p5_a19;
    ddp_eto_rec.attribute12 := p5_a20;
    ddp_eto_rec.attribute13 := p5_a21;
    ddp_eto_rec.attribute14 := p5_a22;
    ddp_eto_rec.attribute15 := p5_a23;
    ddp_eto_rec.created_by := p5_a24;
    ddp_eto_rec.creation_date := p5_a25;
    ddp_eto_rec.last_updated_by := p5_a26;
    ddp_eto_rec.last_update_date := p5_a27;
    ddp_eto_rec.last_update_login := p5_a28;


    -- here's the delegated call to the old PL/SQL routine
    okl_eto_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_eto_rec,
      ddx_eto_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_eto_rec.end_of_term_obj_id;
    p6_a1 := ddx_eto_rec.object_version_number;
    p6_a2 := ddx_eto_rec.inventory_item_id;
    p6_a3 := ddx_eto_rec.organization_id;
    p6_a4 := ddx_eto_rec.category_id;
    p6_a5 := ddx_eto_rec.category_set_id;
    p6_a6 := ddx_eto_rec.resi_category_set_id;
    p6_a7 := ddx_eto_rec.end_of_term_ver_id;
    p6_a8 := ddx_eto_rec.attribute_category;
    p6_a9 := ddx_eto_rec.attribute1;
    p6_a10 := ddx_eto_rec.attribute2;
    p6_a11 := ddx_eto_rec.attribute3;
    p6_a12 := ddx_eto_rec.attribute4;
    p6_a13 := ddx_eto_rec.attribute5;
    p6_a14 := ddx_eto_rec.attribute6;
    p6_a15 := ddx_eto_rec.attribute7;
    p6_a16 := ddx_eto_rec.attribute8;
    p6_a17 := ddx_eto_rec.attribute9;
    p6_a18 := ddx_eto_rec.attribute10;
    p6_a19 := ddx_eto_rec.attribute11;
    p6_a20 := ddx_eto_rec.attribute12;
    p6_a21 := ddx_eto_rec.attribute13;
    p6_a22 := ddx_eto_rec.attribute14;
    p6_a23 := ddx_eto_rec.attribute15;
    p6_a24 := ddx_eto_rec.created_by;
    p6_a25 := ddx_eto_rec.creation_date;
    p6_a26 := ddx_eto_rec.last_updated_by;
    p6_a27 := ddx_eto_rec.last_update_date;
    p6_a28 := ddx_eto_rec.last_update_login;
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
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_500
    , p5_a10 JTF_VARCHAR2_TABLE_500
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
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_eto_tbl okl_eto_pvt.okl_eto_tbl;
    ddx_eto_tbl okl_eto_pvt.okl_eto_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_eto_pvt_w.rosetta_table_copy_in_p1(ddp_eto_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_eto_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_eto_tbl,
      ddx_eto_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_eto_pvt_w.rosetta_table_copy_out_p1(ddx_eto_tbl, p6_a0
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
      );
  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  NUMBER
    , p5_a25  DATE
    , p5_a26  NUMBER
    , p5_a27  DATE
    , p5_a28  NUMBER
  )

  as
    ddp_eto_rec okl_eto_pvt.okl_eto_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_eto_rec.end_of_term_obj_id := p5_a0;
    ddp_eto_rec.object_version_number := p5_a1;
    ddp_eto_rec.inventory_item_id := p5_a2;
    ddp_eto_rec.organization_id := p5_a3;
    ddp_eto_rec.category_id := p5_a4;
    ddp_eto_rec.category_set_id := p5_a5;
    ddp_eto_rec.resi_category_set_id := p5_a6;
    ddp_eto_rec.end_of_term_ver_id := p5_a7;
    ddp_eto_rec.attribute_category := p5_a8;
    ddp_eto_rec.attribute1 := p5_a9;
    ddp_eto_rec.attribute2 := p5_a10;
    ddp_eto_rec.attribute3 := p5_a11;
    ddp_eto_rec.attribute4 := p5_a12;
    ddp_eto_rec.attribute5 := p5_a13;
    ddp_eto_rec.attribute6 := p5_a14;
    ddp_eto_rec.attribute7 := p5_a15;
    ddp_eto_rec.attribute8 := p5_a16;
    ddp_eto_rec.attribute9 := p5_a17;
    ddp_eto_rec.attribute10 := p5_a18;
    ddp_eto_rec.attribute11 := p5_a19;
    ddp_eto_rec.attribute12 := p5_a20;
    ddp_eto_rec.attribute13 := p5_a21;
    ddp_eto_rec.attribute14 := p5_a22;
    ddp_eto_rec.attribute15 := p5_a23;
    ddp_eto_rec.created_by := p5_a24;
    ddp_eto_rec.creation_date := p5_a25;
    ddp_eto_rec.last_updated_by := p5_a26;
    ddp_eto_rec.last_update_date := p5_a27;
    ddp_eto_rec.last_update_login := p5_a28;

    -- here's the delegated call to the old PL/SQL routine
    okl_eto_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_eto_rec);

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
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_500
    , p5_a10 JTF_VARCHAR2_TABLE_500
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
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
  )

  as
    ddp_eto_tbl okl_eto_pvt.okl_eto_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_eto_pvt_w.rosetta_table_copy_in_p1(ddp_eto_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_eto_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_eto_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_eto_pvt_w;

/
