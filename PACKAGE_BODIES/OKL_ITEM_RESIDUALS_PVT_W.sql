--------------------------------------------------------
--  DDL for Package Body OKL_ITEM_RESIDUALS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ITEM_RESIDUALS_PVT_W" as
  /* $Header: OKLEIRSB.pls 120.2 2005/07/22 10:10:33 smadhava noship $ */
  procedure rosetta_table_copy_in_p5(t out nocopy okl_item_residuals_pvt.lrs_ref_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := a0(indx);
          t(ddindx).name := a1(indx);
          t(ddindx).version := a2(indx);
          t(ddindx).object_version_number := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_item_residuals_pvt.lrs_ref_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id;
          a1(indx) := t(ddindx).name;
          a2(indx) := t(ddindx).version;
          a3(indx) := t(ddindx).object_version_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure create_irs(p_api_version  NUMBER
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
    , p5_a12  DATE
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  NUMBER
    , p5_a16  DATE
    , p5_a17  NUMBER
    , p5_a18  DATE
    , p5_a19  NUMBER
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  NUMBER
    , p6_a3  NUMBER
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p6_a9  DATE
    , p6_a10  DATE
    , p6_a11  NUMBER
    , p6_a12  DATE
    , p6_a13  NUMBER
    , p6_a14  DATE
    , p6_a15  NUMBER
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_DATE_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  NUMBER
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  DATE
    , p8_a13 out nocopy  DATE
    , p8_a14 out nocopy  NUMBER
    , p8_a15 out nocopy  NUMBER
    , p8_a16 out nocopy  DATE
    , p8_a17 out nocopy  NUMBER
    , p8_a18 out nocopy  DATE
    , p8_a19 out nocopy  NUMBER
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  NUMBER
    , p9_a3 out nocopy  NUMBER
    , p9_a4 out nocopy  NUMBER
    , p9_a5 out nocopy  NUMBER
    , p9_a6 out nocopy  NUMBER
    , p9_a7 out nocopy  VARCHAR2
    , p9_a8 out nocopy  VARCHAR2
    , p9_a9 out nocopy  DATE
    , p9_a10 out nocopy  DATE
    , p9_a11 out nocopy  NUMBER
    , p9_a12 out nocopy  DATE
    , p9_a13 out nocopy  NUMBER
    , p9_a14 out nocopy  DATE
    , p9_a15 out nocopy  NUMBER
    , p9_a16 out nocopy  VARCHAR2
    , p9_a17 out nocopy  VARCHAR2
    , p9_a18 out nocopy  VARCHAR2
    , p9_a19 out nocopy  VARCHAR2
    , p9_a20 out nocopy  VARCHAR2
    , p9_a21 out nocopy  VARCHAR2
    , p9_a22 out nocopy  VARCHAR2
    , p9_a23 out nocopy  VARCHAR2
    , p9_a24 out nocopy  VARCHAR2
    , p9_a25 out nocopy  VARCHAR2
    , p9_a26 out nocopy  VARCHAR2
    , p9_a27 out nocopy  VARCHAR2
    , p9_a28 out nocopy  VARCHAR2
    , p9_a29 out nocopy  VARCHAR2
    , p9_a30 out nocopy  VARCHAR2
    , p9_a31 out nocopy  VARCHAR2
  )

  as
    ddp_irhv_rec okl_item_residuals_pvt.okl_irhv_rec;
    ddp_icpv_rec okl_item_residuals_pvt.okl_icpv_rec;
    ddp_irv_tbl okl_item_residuals_pvt.okl_irv_tbl;
    ddx_irhv_rec okl_item_residuals_pvt.okl_irhv_rec;
    ddx_icpv_rec okl_item_residuals_pvt.okl_icpv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_irhv_rec.item_residual_id := p5_a0;
    ddp_irhv_rec.orig_item_residual_id := p5_a1;
    ddp_irhv_rec.object_version_number := p5_a2;
    ddp_irhv_rec.inventory_item_id := p5_a3;
    ddp_irhv_rec.organization_id := p5_a4;
    ddp_irhv_rec.category_id := p5_a5;
    ddp_irhv_rec.category_set_id := p5_a6;
    ddp_irhv_rec.resi_category_set_id := p5_a7;
    ddp_irhv_rec.category_type_code := p5_a8;
    ddp_irhv_rec.residual_type_code := p5_a9;
    ddp_irhv_rec.currency_code := p5_a10;
    ddp_irhv_rec.sts_code := p5_a11;
    ddp_irhv_rec.effective_from_date := p5_a12;
    ddp_irhv_rec.effective_to_date := p5_a13;
    ddp_irhv_rec.org_id := p5_a14;
    ddp_irhv_rec.created_by := p5_a15;
    ddp_irhv_rec.creation_date := p5_a16;
    ddp_irhv_rec.last_updated_by := p5_a17;
    ddp_irhv_rec.last_update_date := p5_a18;
    ddp_irhv_rec.last_update_login := p5_a19;

    ddp_icpv_rec.id := p6_a0;
    ddp_icpv_rec.object_version_number := p6_a1;
    ddp_icpv_rec.cat_id1 := p6_a2;
    ddp_icpv_rec.cat_id2 := p6_a3;
    ddp_icpv_rec.term_in_months := p6_a4;
    ddp_icpv_rec.residual_value_percent := p6_a5;
    ddp_icpv_rec.item_residual_id := p6_a6;
    ddp_icpv_rec.sts_code := p6_a7;
    ddp_icpv_rec.version_number := p6_a8;
    ddp_icpv_rec.start_date := p6_a9;
    ddp_icpv_rec.end_date := p6_a10;
    ddp_icpv_rec.created_by := p6_a11;
    ddp_icpv_rec.creation_date := p6_a12;
    ddp_icpv_rec.last_updated_by := p6_a13;
    ddp_icpv_rec.last_update_date := p6_a14;
    ddp_icpv_rec.last_update_login := p6_a15;
    ddp_icpv_rec.attribute_category := p6_a16;
    ddp_icpv_rec.attribute1 := p6_a17;
    ddp_icpv_rec.attribute2 := p6_a18;
    ddp_icpv_rec.attribute3 := p6_a19;
    ddp_icpv_rec.attribute4 := p6_a20;
    ddp_icpv_rec.attribute5 := p6_a21;
    ddp_icpv_rec.attribute6 := p6_a22;
    ddp_icpv_rec.attribute7 := p6_a23;
    ddp_icpv_rec.attribute8 := p6_a24;
    ddp_icpv_rec.attribute9 := p6_a25;
    ddp_icpv_rec.attribute10 := p6_a26;
    ddp_icpv_rec.attribute11 := p6_a27;
    ddp_icpv_rec.attribute12 := p6_a28;
    ddp_icpv_rec.attribute13 := p6_a29;
    ddp_icpv_rec.attribute14 := p6_a30;
    ddp_icpv_rec.attribute15 := p6_a31;

    okl_irv_pvt_w.rosetta_table_copy_in_p1(ddp_irv_tbl, p7_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_item_residuals_pvt.create_irs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_irhv_rec,
      ddp_icpv_rec,
      ddp_irv_tbl,
      ddx_irhv_rec,
      ddx_icpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddx_irhv_rec.item_residual_id;
    p8_a1 := ddx_irhv_rec.orig_item_residual_id;
    p8_a2 := ddx_irhv_rec.object_version_number;
    p8_a3 := ddx_irhv_rec.inventory_item_id;
    p8_a4 := ddx_irhv_rec.organization_id;
    p8_a5 := ddx_irhv_rec.category_id;
    p8_a6 := ddx_irhv_rec.category_set_id;
    p8_a7 := ddx_irhv_rec.resi_category_set_id;
    p8_a8 := ddx_irhv_rec.category_type_code;
    p8_a9 := ddx_irhv_rec.residual_type_code;
    p8_a10 := ddx_irhv_rec.currency_code;
    p8_a11 := ddx_irhv_rec.sts_code;
    p8_a12 := ddx_irhv_rec.effective_from_date;
    p8_a13 := ddx_irhv_rec.effective_to_date;
    p8_a14 := ddx_irhv_rec.org_id;
    p8_a15 := ddx_irhv_rec.created_by;
    p8_a16 := ddx_irhv_rec.creation_date;
    p8_a17 := ddx_irhv_rec.last_updated_by;
    p8_a18 := ddx_irhv_rec.last_update_date;
    p8_a19 := ddx_irhv_rec.last_update_login;

    p9_a0 := ddx_icpv_rec.id;
    p9_a1 := ddx_icpv_rec.object_version_number;
    p9_a2 := ddx_icpv_rec.cat_id1;
    p9_a3 := ddx_icpv_rec.cat_id2;
    p9_a4 := ddx_icpv_rec.term_in_months;
    p9_a5 := ddx_icpv_rec.residual_value_percent;
    p9_a6 := ddx_icpv_rec.item_residual_id;
    p9_a7 := ddx_icpv_rec.sts_code;
    p9_a8 := ddx_icpv_rec.version_number;
    p9_a9 := ddx_icpv_rec.start_date;
    p9_a10 := ddx_icpv_rec.end_date;
    p9_a11 := ddx_icpv_rec.created_by;
    p9_a12 := ddx_icpv_rec.creation_date;
    p9_a13 := ddx_icpv_rec.last_updated_by;
    p9_a14 := ddx_icpv_rec.last_update_date;
    p9_a15 := ddx_icpv_rec.last_update_login;
    p9_a16 := ddx_icpv_rec.attribute_category;
    p9_a17 := ddx_icpv_rec.attribute1;
    p9_a18 := ddx_icpv_rec.attribute2;
    p9_a19 := ddx_icpv_rec.attribute3;
    p9_a20 := ddx_icpv_rec.attribute4;
    p9_a21 := ddx_icpv_rec.attribute5;
    p9_a22 := ddx_icpv_rec.attribute6;
    p9_a23 := ddx_icpv_rec.attribute7;
    p9_a24 := ddx_icpv_rec.attribute8;
    p9_a25 := ddx_icpv_rec.attribute9;
    p9_a26 := ddx_icpv_rec.attribute10;
    p9_a27 := ddx_icpv_rec.attribute11;
    p9_a28 := ddx_icpv_rec.attribute12;
    p9_a29 := ddx_icpv_rec.attribute13;
    p9_a30 := ddx_icpv_rec.attribute14;
    p9_a31 := ddx_icpv_rec.attribute15;
  end;

  procedure update_version_irs(p_api_version  NUMBER
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
    , p5_a12  DATE
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  NUMBER
    , p5_a16  DATE
    , p5_a17  NUMBER
    , p5_a18  DATE
    , p5_a19  NUMBER
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  NUMBER
    , p6_a3  NUMBER
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p6_a9  DATE
    , p6_a10  DATE
    , p6_a11  NUMBER
    , p6_a12  DATE
    , p6_a13  NUMBER
    , p6_a14  DATE
    , p6_a15  NUMBER
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_DATE_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  NUMBER
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  DATE
    , p8_a13 out nocopy  DATE
    , p8_a14 out nocopy  NUMBER
    , p8_a15 out nocopy  NUMBER
    , p8_a16 out nocopy  DATE
    , p8_a17 out nocopy  NUMBER
    , p8_a18 out nocopy  DATE
    , p8_a19 out nocopy  NUMBER
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  NUMBER
    , p9_a3 out nocopy  NUMBER
    , p9_a4 out nocopy  NUMBER
    , p9_a5 out nocopy  NUMBER
    , p9_a6 out nocopy  NUMBER
    , p9_a7 out nocopy  VARCHAR2
    , p9_a8 out nocopy  VARCHAR2
    , p9_a9 out nocopy  DATE
    , p9_a10 out nocopy  DATE
    , p9_a11 out nocopy  NUMBER
    , p9_a12 out nocopy  DATE
    , p9_a13 out nocopy  NUMBER
    , p9_a14 out nocopy  DATE
    , p9_a15 out nocopy  NUMBER
    , p9_a16 out nocopy  VARCHAR2
    , p9_a17 out nocopy  VARCHAR2
    , p9_a18 out nocopy  VARCHAR2
    , p9_a19 out nocopy  VARCHAR2
    , p9_a20 out nocopy  VARCHAR2
    , p9_a21 out nocopy  VARCHAR2
    , p9_a22 out nocopy  VARCHAR2
    , p9_a23 out nocopy  VARCHAR2
    , p9_a24 out nocopy  VARCHAR2
    , p9_a25 out nocopy  VARCHAR2
    , p9_a26 out nocopy  VARCHAR2
    , p9_a27 out nocopy  VARCHAR2
    , p9_a28 out nocopy  VARCHAR2
    , p9_a29 out nocopy  VARCHAR2
    , p9_a30 out nocopy  VARCHAR2
    , p9_a31 out nocopy  VARCHAR2
  )

  as
    ddp_irhv_rec okl_item_residuals_pvt.okl_irhv_rec;
    ddp_icpv_rec okl_item_residuals_pvt.okl_icpv_rec;
    ddp_irv_tbl okl_item_residuals_pvt.okl_irv_tbl;
    ddx_irhv_rec okl_item_residuals_pvt.okl_irhv_rec;
    ddx_icpv_rec okl_item_residuals_pvt.okl_icpv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_irhv_rec.item_residual_id := p5_a0;
    ddp_irhv_rec.orig_item_residual_id := p5_a1;
    ddp_irhv_rec.object_version_number := p5_a2;
    ddp_irhv_rec.inventory_item_id := p5_a3;
    ddp_irhv_rec.organization_id := p5_a4;
    ddp_irhv_rec.category_id := p5_a5;
    ddp_irhv_rec.category_set_id := p5_a6;
    ddp_irhv_rec.resi_category_set_id := p5_a7;
    ddp_irhv_rec.category_type_code := p5_a8;
    ddp_irhv_rec.residual_type_code := p5_a9;
    ddp_irhv_rec.currency_code := p5_a10;
    ddp_irhv_rec.sts_code := p5_a11;
    ddp_irhv_rec.effective_from_date := p5_a12;
    ddp_irhv_rec.effective_to_date := p5_a13;
    ddp_irhv_rec.org_id := p5_a14;
    ddp_irhv_rec.created_by := p5_a15;
    ddp_irhv_rec.creation_date := p5_a16;
    ddp_irhv_rec.last_updated_by := p5_a17;
    ddp_irhv_rec.last_update_date := p5_a18;
    ddp_irhv_rec.last_update_login := p5_a19;

    ddp_icpv_rec.id := p6_a0;
    ddp_icpv_rec.object_version_number := p6_a1;
    ddp_icpv_rec.cat_id1 := p6_a2;
    ddp_icpv_rec.cat_id2 := p6_a3;
    ddp_icpv_rec.term_in_months := p6_a4;
    ddp_icpv_rec.residual_value_percent := p6_a5;
    ddp_icpv_rec.item_residual_id := p6_a6;
    ddp_icpv_rec.sts_code := p6_a7;
    ddp_icpv_rec.version_number := p6_a8;
    ddp_icpv_rec.start_date := p6_a9;
    ddp_icpv_rec.end_date := p6_a10;
    ddp_icpv_rec.created_by := p6_a11;
    ddp_icpv_rec.creation_date := p6_a12;
    ddp_icpv_rec.last_updated_by := p6_a13;
    ddp_icpv_rec.last_update_date := p6_a14;
    ddp_icpv_rec.last_update_login := p6_a15;
    ddp_icpv_rec.attribute_category := p6_a16;
    ddp_icpv_rec.attribute1 := p6_a17;
    ddp_icpv_rec.attribute2 := p6_a18;
    ddp_icpv_rec.attribute3 := p6_a19;
    ddp_icpv_rec.attribute4 := p6_a20;
    ddp_icpv_rec.attribute5 := p6_a21;
    ddp_icpv_rec.attribute6 := p6_a22;
    ddp_icpv_rec.attribute7 := p6_a23;
    ddp_icpv_rec.attribute8 := p6_a24;
    ddp_icpv_rec.attribute9 := p6_a25;
    ddp_icpv_rec.attribute10 := p6_a26;
    ddp_icpv_rec.attribute11 := p6_a27;
    ddp_icpv_rec.attribute12 := p6_a28;
    ddp_icpv_rec.attribute13 := p6_a29;
    ddp_icpv_rec.attribute14 := p6_a30;
    ddp_icpv_rec.attribute15 := p6_a31;

    okl_irv_pvt_w.rosetta_table_copy_in_p1(ddp_irv_tbl, p7_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_item_residuals_pvt.update_version_irs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_irhv_rec,
      ddp_icpv_rec,
      ddp_irv_tbl,
      ddx_irhv_rec,
      ddx_icpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddx_irhv_rec.item_residual_id;
    p8_a1 := ddx_irhv_rec.orig_item_residual_id;
    p8_a2 := ddx_irhv_rec.object_version_number;
    p8_a3 := ddx_irhv_rec.inventory_item_id;
    p8_a4 := ddx_irhv_rec.organization_id;
    p8_a5 := ddx_irhv_rec.category_id;
    p8_a6 := ddx_irhv_rec.category_set_id;
    p8_a7 := ddx_irhv_rec.resi_category_set_id;
    p8_a8 := ddx_irhv_rec.category_type_code;
    p8_a9 := ddx_irhv_rec.residual_type_code;
    p8_a10 := ddx_irhv_rec.currency_code;
    p8_a11 := ddx_irhv_rec.sts_code;
    p8_a12 := ddx_irhv_rec.effective_from_date;
    p8_a13 := ddx_irhv_rec.effective_to_date;
    p8_a14 := ddx_irhv_rec.org_id;
    p8_a15 := ddx_irhv_rec.created_by;
    p8_a16 := ddx_irhv_rec.creation_date;
    p8_a17 := ddx_irhv_rec.last_updated_by;
    p8_a18 := ddx_irhv_rec.last_update_date;
    p8_a19 := ddx_irhv_rec.last_update_login;

    p9_a0 := ddx_icpv_rec.id;
    p9_a1 := ddx_icpv_rec.object_version_number;
    p9_a2 := ddx_icpv_rec.cat_id1;
    p9_a3 := ddx_icpv_rec.cat_id2;
    p9_a4 := ddx_icpv_rec.term_in_months;
    p9_a5 := ddx_icpv_rec.residual_value_percent;
    p9_a6 := ddx_icpv_rec.item_residual_id;
    p9_a7 := ddx_icpv_rec.sts_code;
    p9_a8 := ddx_icpv_rec.version_number;
    p9_a9 := ddx_icpv_rec.start_date;
    p9_a10 := ddx_icpv_rec.end_date;
    p9_a11 := ddx_icpv_rec.created_by;
    p9_a12 := ddx_icpv_rec.creation_date;
    p9_a13 := ddx_icpv_rec.last_updated_by;
    p9_a14 := ddx_icpv_rec.last_update_date;
    p9_a15 := ddx_icpv_rec.last_update_login;
    p9_a16 := ddx_icpv_rec.attribute_category;
    p9_a17 := ddx_icpv_rec.attribute1;
    p9_a18 := ddx_icpv_rec.attribute2;
    p9_a19 := ddx_icpv_rec.attribute3;
    p9_a20 := ddx_icpv_rec.attribute4;
    p9_a21 := ddx_icpv_rec.attribute5;
    p9_a22 := ddx_icpv_rec.attribute6;
    p9_a23 := ddx_icpv_rec.attribute7;
    p9_a24 := ddx_icpv_rec.attribute8;
    p9_a25 := ddx_icpv_rec.attribute9;
    p9_a26 := ddx_icpv_rec.attribute10;
    p9_a27 := ddx_icpv_rec.attribute11;
    p9_a28 := ddx_icpv_rec.attribute12;
    p9_a29 := ddx_icpv_rec.attribute13;
    p9_a30 := ddx_icpv_rec.attribute14;
    p9_a31 := ddx_icpv_rec.attribute15;
  end;

  procedure create_version_irs(p_api_version  NUMBER
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
    , p5_a12  DATE
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  NUMBER
    , p5_a16  DATE
    , p5_a17  NUMBER
    , p5_a18  DATE
    , p5_a19  NUMBER
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  NUMBER
    , p6_a3  NUMBER
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p6_a9  DATE
    , p6_a10  DATE
    , p6_a11  NUMBER
    , p6_a12  DATE
    , p6_a13  NUMBER
    , p6_a14  DATE
    , p6_a15  NUMBER
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_DATE_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  NUMBER
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  DATE
    , p8_a13 out nocopy  DATE
    , p8_a14 out nocopy  NUMBER
    , p8_a15 out nocopy  NUMBER
    , p8_a16 out nocopy  DATE
    , p8_a17 out nocopy  NUMBER
    , p8_a18 out nocopy  DATE
    , p8_a19 out nocopy  NUMBER
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  NUMBER
    , p9_a3 out nocopy  NUMBER
    , p9_a4 out nocopy  NUMBER
    , p9_a5 out nocopy  NUMBER
    , p9_a6 out nocopy  NUMBER
    , p9_a7 out nocopy  VARCHAR2
    , p9_a8 out nocopy  VARCHAR2
    , p9_a9 out nocopy  DATE
    , p9_a10 out nocopy  DATE
    , p9_a11 out nocopy  NUMBER
    , p9_a12 out nocopy  DATE
    , p9_a13 out nocopy  NUMBER
    , p9_a14 out nocopy  DATE
    , p9_a15 out nocopy  NUMBER
    , p9_a16 out nocopy  VARCHAR2
    , p9_a17 out nocopy  VARCHAR2
    , p9_a18 out nocopy  VARCHAR2
    , p9_a19 out nocopy  VARCHAR2
    , p9_a20 out nocopy  VARCHAR2
    , p9_a21 out nocopy  VARCHAR2
    , p9_a22 out nocopy  VARCHAR2
    , p9_a23 out nocopy  VARCHAR2
    , p9_a24 out nocopy  VARCHAR2
    , p9_a25 out nocopy  VARCHAR2
    , p9_a26 out nocopy  VARCHAR2
    , p9_a27 out nocopy  VARCHAR2
    , p9_a28 out nocopy  VARCHAR2
    , p9_a29 out nocopy  VARCHAR2
    , p9_a30 out nocopy  VARCHAR2
    , p9_a31 out nocopy  VARCHAR2
  )

  as
    ddp_irhv_rec okl_item_residuals_pvt.okl_irhv_rec;
    ddp_icpv_rec okl_item_residuals_pvt.okl_icpv_rec;
    ddp_irv_tbl okl_item_residuals_pvt.okl_irv_tbl;
    ddx_irhv_rec okl_item_residuals_pvt.okl_irhv_rec;
    ddx_icpv_rec okl_item_residuals_pvt.okl_icpv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_irhv_rec.item_residual_id := p5_a0;
    ddp_irhv_rec.orig_item_residual_id := p5_a1;
    ddp_irhv_rec.object_version_number := p5_a2;
    ddp_irhv_rec.inventory_item_id := p5_a3;
    ddp_irhv_rec.organization_id := p5_a4;
    ddp_irhv_rec.category_id := p5_a5;
    ddp_irhv_rec.category_set_id := p5_a6;
    ddp_irhv_rec.resi_category_set_id := p5_a7;
    ddp_irhv_rec.category_type_code := p5_a8;
    ddp_irhv_rec.residual_type_code := p5_a9;
    ddp_irhv_rec.currency_code := p5_a10;
    ddp_irhv_rec.sts_code := p5_a11;
    ddp_irhv_rec.effective_from_date := p5_a12;
    ddp_irhv_rec.effective_to_date := p5_a13;
    ddp_irhv_rec.org_id := p5_a14;
    ddp_irhv_rec.created_by := p5_a15;
    ddp_irhv_rec.creation_date := p5_a16;
    ddp_irhv_rec.last_updated_by := p5_a17;
    ddp_irhv_rec.last_update_date := p5_a18;
    ddp_irhv_rec.last_update_login := p5_a19;

    ddp_icpv_rec.id := p6_a0;
    ddp_icpv_rec.object_version_number := p6_a1;
    ddp_icpv_rec.cat_id1 := p6_a2;
    ddp_icpv_rec.cat_id2 := p6_a3;
    ddp_icpv_rec.term_in_months := p6_a4;
    ddp_icpv_rec.residual_value_percent := p6_a5;
    ddp_icpv_rec.item_residual_id := p6_a6;
    ddp_icpv_rec.sts_code := p6_a7;
    ddp_icpv_rec.version_number := p6_a8;
    ddp_icpv_rec.start_date := p6_a9;
    ddp_icpv_rec.end_date := p6_a10;
    ddp_icpv_rec.created_by := p6_a11;
    ddp_icpv_rec.creation_date := p6_a12;
    ddp_icpv_rec.last_updated_by := p6_a13;
    ddp_icpv_rec.last_update_date := p6_a14;
    ddp_icpv_rec.last_update_login := p6_a15;
    ddp_icpv_rec.attribute_category := p6_a16;
    ddp_icpv_rec.attribute1 := p6_a17;
    ddp_icpv_rec.attribute2 := p6_a18;
    ddp_icpv_rec.attribute3 := p6_a19;
    ddp_icpv_rec.attribute4 := p6_a20;
    ddp_icpv_rec.attribute5 := p6_a21;
    ddp_icpv_rec.attribute6 := p6_a22;
    ddp_icpv_rec.attribute7 := p6_a23;
    ddp_icpv_rec.attribute8 := p6_a24;
    ddp_icpv_rec.attribute9 := p6_a25;
    ddp_icpv_rec.attribute10 := p6_a26;
    ddp_icpv_rec.attribute11 := p6_a27;
    ddp_icpv_rec.attribute12 := p6_a28;
    ddp_icpv_rec.attribute13 := p6_a29;
    ddp_icpv_rec.attribute14 := p6_a30;
    ddp_icpv_rec.attribute15 := p6_a31;

    okl_irv_pvt_w.rosetta_table_copy_in_p1(ddp_irv_tbl, p7_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_item_residuals_pvt.create_version_irs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_irhv_rec,
      ddp_icpv_rec,
      ddp_irv_tbl,
      ddx_irhv_rec,
      ddx_icpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddx_irhv_rec.item_residual_id;
    p8_a1 := ddx_irhv_rec.orig_item_residual_id;
    p8_a2 := ddx_irhv_rec.object_version_number;
    p8_a3 := ddx_irhv_rec.inventory_item_id;
    p8_a4 := ddx_irhv_rec.organization_id;
    p8_a5 := ddx_irhv_rec.category_id;
    p8_a6 := ddx_irhv_rec.category_set_id;
    p8_a7 := ddx_irhv_rec.resi_category_set_id;
    p8_a8 := ddx_irhv_rec.category_type_code;
    p8_a9 := ddx_irhv_rec.residual_type_code;
    p8_a10 := ddx_irhv_rec.currency_code;
    p8_a11 := ddx_irhv_rec.sts_code;
    p8_a12 := ddx_irhv_rec.effective_from_date;
    p8_a13 := ddx_irhv_rec.effective_to_date;
    p8_a14 := ddx_irhv_rec.org_id;
    p8_a15 := ddx_irhv_rec.created_by;
    p8_a16 := ddx_irhv_rec.creation_date;
    p8_a17 := ddx_irhv_rec.last_updated_by;
    p8_a18 := ddx_irhv_rec.last_update_date;
    p8_a19 := ddx_irhv_rec.last_update_login;

    p9_a0 := ddx_icpv_rec.id;
    p9_a1 := ddx_icpv_rec.object_version_number;
    p9_a2 := ddx_icpv_rec.cat_id1;
    p9_a3 := ddx_icpv_rec.cat_id2;
    p9_a4 := ddx_icpv_rec.term_in_months;
    p9_a5 := ddx_icpv_rec.residual_value_percent;
    p9_a6 := ddx_icpv_rec.item_residual_id;
    p9_a7 := ddx_icpv_rec.sts_code;
    p9_a8 := ddx_icpv_rec.version_number;
    p9_a9 := ddx_icpv_rec.start_date;
    p9_a10 := ddx_icpv_rec.end_date;
    p9_a11 := ddx_icpv_rec.created_by;
    p9_a12 := ddx_icpv_rec.creation_date;
    p9_a13 := ddx_icpv_rec.last_updated_by;
    p9_a14 := ddx_icpv_rec.last_update_date;
    p9_a15 := ddx_icpv_rec.last_update_login;
    p9_a16 := ddx_icpv_rec.attribute_category;
    p9_a17 := ddx_icpv_rec.attribute1;
    p9_a18 := ddx_icpv_rec.attribute2;
    p9_a19 := ddx_icpv_rec.attribute3;
    p9_a20 := ddx_icpv_rec.attribute4;
    p9_a21 := ddx_icpv_rec.attribute5;
    p9_a22 := ddx_icpv_rec.attribute6;
    p9_a23 := ddx_icpv_rec.attribute7;
    p9_a24 := ddx_icpv_rec.attribute8;
    p9_a25 := ddx_icpv_rec.attribute9;
    p9_a26 := ddx_icpv_rec.attribute10;
    p9_a27 := ddx_icpv_rec.attribute11;
    p9_a28 := ddx_icpv_rec.attribute12;
    p9_a29 := ddx_icpv_rec.attribute13;
    p9_a30 := ddx_icpv_rec.attribute14;
    p9_a31 := ddx_icpv_rec.attribute15;
  end;

  procedure change_lrs_sts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_confirm_yn  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  NUMBER
    , p6_a3  NUMBER
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p6_a9  DATE
    , p6_a10  DATE
    , p6_a11  NUMBER
    , p6_a12  DATE
    , p6_a13  NUMBER
    , p6_a14  DATE
    , p6_a15  NUMBER
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , x_change_sts out nocopy  VARCHAR2
  )

  as
    ddp_icpv_rec okl_item_residuals_pvt.okl_icpv_rec;
    ddx_lrs_list okl_item_residuals_pvt.lrs_ref_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_icpv_rec.id := p6_a0;
    ddp_icpv_rec.object_version_number := p6_a1;
    ddp_icpv_rec.cat_id1 := p6_a2;
    ddp_icpv_rec.cat_id2 := p6_a3;
    ddp_icpv_rec.term_in_months := p6_a4;
    ddp_icpv_rec.residual_value_percent := p6_a5;
    ddp_icpv_rec.item_residual_id := p6_a6;
    ddp_icpv_rec.sts_code := p6_a7;
    ddp_icpv_rec.version_number := p6_a8;
    ddp_icpv_rec.start_date := p6_a9;
    ddp_icpv_rec.end_date := p6_a10;
    ddp_icpv_rec.created_by := p6_a11;
    ddp_icpv_rec.creation_date := p6_a12;
    ddp_icpv_rec.last_updated_by := p6_a13;
    ddp_icpv_rec.last_update_date := p6_a14;
    ddp_icpv_rec.last_update_login := p6_a15;
    ddp_icpv_rec.attribute_category := p6_a16;
    ddp_icpv_rec.attribute1 := p6_a17;
    ddp_icpv_rec.attribute2 := p6_a18;
    ddp_icpv_rec.attribute3 := p6_a19;
    ddp_icpv_rec.attribute4 := p6_a20;
    ddp_icpv_rec.attribute5 := p6_a21;
    ddp_icpv_rec.attribute6 := p6_a22;
    ddp_icpv_rec.attribute7 := p6_a23;
    ddp_icpv_rec.attribute8 := p6_a24;
    ddp_icpv_rec.attribute9 := p6_a25;
    ddp_icpv_rec.attribute10 := p6_a26;
    ddp_icpv_rec.attribute11 := p6_a27;
    ddp_icpv_rec.attribute12 := p6_a28;
    ddp_icpv_rec.attribute13 := p6_a29;
    ddp_icpv_rec.attribute14 := p6_a30;
    ddp_icpv_rec.attribute15 := p6_a31;



    -- here's the delegated call to the old PL/SQL routine
    okl_item_residuals_pvt.change_lrs_sts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_confirm_yn,
      ddp_icpv_rec,
      ddx_lrs_list,
      x_change_sts);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_item_residuals_pvt_w.rosetta_table_copy_out_p5(ddx_lrs_list, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      );

  end;

  procedure remove_terms(p_api_version  NUMBER
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
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
  )

  as
    ddp_irv_tbl okl_item_residuals_pvt.okl_irv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_irv_pvt_w.rosetta_table_copy_in_p1(ddp_irv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_item_residuals_pvt.remove_terms(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_irv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_irs_submit(p_api_version  NUMBER
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
    , p5_a12  DATE
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  NUMBER
    , p5_a16  DATE
    , p5_a17  NUMBER
    , p5_a18  DATE
    , p5_a19  NUMBER
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  NUMBER
    , p6_a3  NUMBER
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p6_a9  DATE
    , p6_a10  DATE
    , p6_a11  NUMBER
    , p6_a12  DATE
    , p6_a13  NUMBER
    , p6_a14  DATE
    , p6_a15  NUMBER
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_DATE_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  NUMBER
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  DATE
    , p8_a13 out nocopy  DATE
    , p8_a14 out nocopy  NUMBER
    , p8_a15 out nocopy  NUMBER
    , p8_a16 out nocopy  DATE
    , p8_a17 out nocopy  NUMBER
    , p8_a18 out nocopy  DATE
    , p8_a19 out nocopy  NUMBER
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  NUMBER
    , p9_a3 out nocopy  NUMBER
    , p9_a4 out nocopy  NUMBER
    , p9_a5 out nocopy  NUMBER
    , p9_a6 out nocopy  NUMBER
    , p9_a7 out nocopy  VARCHAR2
    , p9_a8 out nocopy  VARCHAR2
    , p9_a9 out nocopy  DATE
    , p9_a10 out nocopy  DATE
    , p9_a11 out nocopy  NUMBER
    , p9_a12 out nocopy  DATE
    , p9_a13 out nocopy  NUMBER
    , p9_a14 out nocopy  DATE
    , p9_a15 out nocopy  NUMBER
    , p9_a16 out nocopy  VARCHAR2
    , p9_a17 out nocopy  VARCHAR2
    , p9_a18 out nocopy  VARCHAR2
    , p9_a19 out nocopy  VARCHAR2
    , p9_a20 out nocopy  VARCHAR2
    , p9_a21 out nocopy  VARCHAR2
    , p9_a22 out nocopy  VARCHAR2
    , p9_a23 out nocopy  VARCHAR2
    , p9_a24 out nocopy  VARCHAR2
    , p9_a25 out nocopy  VARCHAR2
    , p9_a26 out nocopy  VARCHAR2
    , p9_a27 out nocopy  VARCHAR2
    , p9_a28 out nocopy  VARCHAR2
    , p9_a29 out nocopy  VARCHAR2
    , p9_a30 out nocopy  VARCHAR2
    , p9_a31 out nocopy  VARCHAR2
  )

  as
    ddp_irhv_rec okl_item_residuals_pvt.okl_irhv_rec;
    ddp_icpv_rec okl_item_residuals_pvt.okl_icpv_rec;
    ddp_irv_tbl okl_item_residuals_pvt.okl_irv_tbl;
    ddx_irhv_rec okl_item_residuals_pvt.okl_irhv_rec;
    ddx_icpv_rec okl_item_residuals_pvt.okl_icpv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_irhv_rec.item_residual_id := p5_a0;
    ddp_irhv_rec.orig_item_residual_id := p5_a1;
    ddp_irhv_rec.object_version_number := p5_a2;
    ddp_irhv_rec.inventory_item_id := p5_a3;
    ddp_irhv_rec.organization_id := p5_a4;
    ddp_irhv_rec.category_id := p5_a5;
    ddp_irhv_rec.category_set_id := p5_a6;
    ddp_irhv_rec.resi_category_set_id := p5_a7;
    ddp_irhv_rec.category_type_code := p5_a8;
    ddp_irhv_rec.residual_type_code := p5_a9;
    ddp_irhv_rec.currency_code := p5_a10;
    ddp_irhv_rec.sts_code := p5_a11;
    ddp_irhv_rec.effective_from_date := p5_a12;
    ddp_irhv_rec.effective_to_date := p5_a13;
    ddp_irhv_rec.org_id := p5_a14;
    ddp_irhv_rec.created_by := p5_a15;
    ddp_irhv_rec.creation_date := p5_a16;
    ddp_irhv_rec.last_updated_by := p5_a17;
    ddp_irhv_rec.last_update_date := p5_a18;
    ddp_irhv_rec.last_update_login := p5_a19;

    ddp_icpv_rec.id := p6_a0;
    ddp_icpv_rec.object_version_number := p6_a1;
    ddp_icpv_rec.cat_id1 := p6_a2;
    ddp_icpv_rec.cat_id2 := p6_a3;
    ddp_icpv_rec.term_in_months := p6_a4;
    ddp_icpv_rec.residual_value_percent := p6_a5;
    ddp_icpv_rec.item_residual_id := p6_a6;
    ddp_icpv_rec.sts_code := p6_a7;
    ddp_icpv_rec.version_number := p6_a8;
    ddp_icpv_rec.start_date := p6_a9;
    ddp_icpv_rec.end_date := p6_a10;
    ddp_icpv_rec.created_by := p6_a11;
    ddp_icpv_rec.creation_date := p6_a12;
    ddp_icpv_rec.last_updated_by := p6_a13;
    ddp_icpv_rec.last_update_date := p6_a14;
    ddp_icpv_rec.last_update_login := p6_a15;
    ddp_icpv_rec.attribute_category := p6_a16;
    ddp_icpv_rec.attribute1 := p6_a17;
    ddp_icpv_rec.attribute2 := p6_a18;
    ddp_icpv_rec.attribute3 := p6_a19;
    ddp_icpv_rec.attribute4 := p6_a20;
    ddp_icpv_rec.attribute5 := p6_a21;
    ddp_icpv_rec.attribute6 := p6_a22;
    ddp_icpv_rec.attribute7 := p6_a23;
    ddp_icpv_rec.attribute8 := p6_a24;
    ddp_icpv_rec.attribute9 := p6_a25;
    ddp_icpv_rec.attribute10 := p6_a26;
    ddp_icpv_rec.attribute11 := p6_a27;
    ddp_icpv_rec.attribute12 := p6_a28;
    ddp_icpv_rec.attribute13 := p6_a29;
    ddp_icpv_rec.attribute14 := p6_a30;
    ddp_icpv_rec.attribute15 := p6_a31;

    okl_irv_pvt_w.rosetta_table_copy_in_p1(ddp_irv_tbl, p7_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_item_residuals_pvt.create_irs_submit(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_irhv_rec,
      ddp_icpv_rec,
      ddp_irv_tbl,
      ddx_irhv_rec,
      ddx_icpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddx_irhv_rec.item_residual_id;
    p8_a1 := ddx_irhv_rec.orig_item_residual_id;
    p8_a2 := ddx_irhv_rec.object_version_number;
    p8_a3 := ddx_irhv_rec.inventory_item_id;
    p8_a4 := ddx_irhv_rec.organization_id;
    p8_a5 := ddx_irhv_rec.category_id;
    p8_a6 := ddx_irhv_rec.category_set_id;
    p8_a7 := ddx_irhv_rec.resi_category_set_id;
    p8_a8 := ddx_irhv_rec.category_type_code;
    p8_a9 := ddx_irhv_rec.residual_type_code;
    p8_a10 := ddx_irhv_rec.currency_code;
    p8_a11 := ddx_irhv_rec.sts_code;
    p8_a12 := ddx_irhv_rec.effective_from_date;
    p8_a13 := ddx_irhv_rec.effective_to_date;
    p8_a14 := ddx_irhv_rec.org_id;
    p8_a15 := ddx_irhv_rec.created_by;
    p8_a16 := ddx_irhv_rec.creation_date;
    p8_a17 := ddx_irhv_rec.last_updated_by;
    p8_a18 := ddx_irhv_rec.last_update_date;
    p8_a19 := ddx_irhv_rec.last_update_login;

    p9_a0 := ddx_icpv_rec.id;
    p9_a1 := ddx_icpv_rec.object_version_number;
    p9_a2 := ddx_icpv_rec.cat_id1;
    p9_a3 := ddx_icpv_rec.cat_id2;
    p9_a4 := ddx_icpv_rec.term_in_months;
    p9_a5 := ddx_icpv_rec.residual_value_percent;
    p9_a6 := ddx_icpv_rec.item_residual_id;
    p9_a7 := ddx_icpv_rec.sts_code;
    p9_a8 := ddx_icpv_rec.version_number;
    p9_a9 := ddx_icpv_rec.start_date;
    p9_a10 := ddx_icpv_rec.end_date;
    p9_a11 := ddx_icpv_rec.created_by;
    p9_a12 := ddx_icpv_rec.creation_date;
    p9_a13 := ddx_icpv_rec.last_updated_by;
    p9_a14 := ddx_icpv_rec.last_update_date;
    p9_a15 := ddx_icpv_rec.last_update_login;
    p9_a16 := ddx_icpv_rec.attribute_category;
    p9_a17 := ddx_icpv_rec.attribute1;
    p9_a18 := ddx_icpv_rec.attribute2;
    p9_a19 := ddx_icpv_rec.attribute3;
    p9_a20 := ddx_icpv_rec.attribute4;
    p9_a21 := ddx_icpv_rec.attribute5;
    p9_a22 := ddx_icpv_rec.attribute6;
    p9_a23 := ddx_icpv_rec.attribute7;
    p9_a24 := ddx_icpv_rec.attribute8;
    p9_a25 := ddx_icpv_rec.attribute9;
    p9_a26 := ddx_icpv_rec.attribute10;
    p9_a27 := ddx_icpv_rec.attribute11;
    p9_a28 := ddx_icpv_rec.attribute12;
    p9_a29 := ddx_icpv_rec.attribute13;
    p9_a30 := ddx_icpv_rec.attribute14;
    p9_a31 := ddx_icpv_rec.attribute15;
  end;

  procedure update_version_irs_submit(p_api_version  NUMBER
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
    , p5_a12  DATE
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  NUMBER
    , p5_a16  DATE
    , p5_a17  NUMBER
    , p5_a18  DATE
    , p5_a19  NUMBER
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  NUMBER
    , p6_a3  NUMBER
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p6_a9  DATE
    , p6_a10  DATE
    , p6_a11  NUMBER
    , p6_a12  DATE
    , p6_a13  NUMBER
    , p6_a14  DATE
    , p6_a15  NUMBER
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_DATE_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  NUMBER
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  DATE
    , p8_a13 out nocopy  DATE
    , p8_a14 out nocopy  NUMBER
    , p8_a15 out nocopy  NUMBER
    , p8_a16 out nocopy  DATE
    , p8_a17 out nocopy  NUMBER
    , p8_a18 out nocopy  DATE
    , p8_a19 out nocopy  NUMBER
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  NUMBER
    , p9_a3 out nocopy  NUMBER
    , p9_a4 out nocopy  NUMBER
    , p9_a5 out nocopy  NUMBER
    , p9_a6 out nocopy  NUMBER
    , p9_a7 out nocopy  VARCHAR2
    , p9_a8 out nocopy  VARCHAR2
    , p9_a9 out nocopy  DATE
    , p9_a10 out nocopy  DATE
    , p9_a11 out nocopy  NUMBER
    , p9_a12 out nocopy  DATE
    , p9_a13 out nocopy  NUMBER
    , p9_a14 out nocopy  DATE
    , p9_a15 out nocopy  NUMBER
    , p9_a16 out nocopy  VARCHAR2
    , p9_a17 out nocopy  VARCHAR2
    , p9_a18 out nocopy  VARCHAR2
    , p9_a19 out nocopy  VARCHAR2
    , p9_a20 out nocopy  VARCHAR2
    , p9_a21 out nocopy  VARCHAR2
    , p9_a22 out nocopy  VARCHAR2
    , p9_a23 out nocopy  VARCHAR2
    , p9_a24 out nocopy  VARCHAR2
    , p9_a25 out nocopy  VARCHAR2
    , p9_a26 out nocopy  VARCHAR2
    , p9_a27 out nocopy  VARCHAR2
    , p9_a28 out nocopy  VARCHAR2
    , p9_a29 out nocopy  VARCHAR2
    , p9_a30 out nocopy  VARCHAR2
    , p9_a31 out nocopy  VARCHAR2
  )

  as
    ddp_irhv_rec okl_item_residuals_pvt.okl_irhv_rec;
    ddp_icpv_rec okl_item_residuals_pvt.okl_icpv_rec;
    ddp_irv_tbl okl_item_residuals_pvt.okl_irv_tbl;
    ddx_irhv_rec okl_item_residuals_pvt.okl_irhv_rec;
    ddx_icpv_rec okl_item_residuals_pvt.okl_icpv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_irhv_rec.item_residual_id := p5_a0;
    ddp_irhv_rec.orig_item_residual_id := p5_a1;
    ddp_irhv_rec.object_version_number := p5_a2;
    ddp_irhv_rec.inventory_item_id := p5_a3;
    ddp_irhv_rec.organization_id := p5_a4;
    ddp_irhv_rec.category_id := p5_a5;
    ddp_irhv_rec.category_set_id := p5_a6;
    ddp_irhv_rec.resi_category_set_id := p5_a7;
    ddp_irhv_rec.category_type_code := p5_a8;
    ddp_irhv_rec.residual_type_code := p5_a9;
    ddp_irhv_rec.currency_code := p5_a10;
    ddp_irhv_rec.sts_code := p5_a11;
    ddp_irhv_rec.effective_from_date := p5_a12;
    ddp_irhv_rec.effective_to_date := p5_a13;
    ddp_irhv_rec.org_id := p5_a14;
    ddp_irhv_rec.created_by := p5_a15;
    ddp_irhv_rec.creation_date := p5_a16;
    ddp_irhv_rec.last_updated_by := p5_a17;
    ddp_irhv_rec.last_update_date := p5_a18;
    ddp_irhv_rec.last_update_login := p5_a19;

    ddp_icpv_rec.id := p6_a0;
    ddp_icpv_rec.object_version_number := p6_a1;
    ddp_icpv_rec.cat_id1 := p6_a2;
    ddp_icpv_rec.cat_id2 := p6_a3;
    ddp_icpv_rec.term_in_months := p6_a4;
    ddp_icpv_rec.residual_value_percent := p6_a5;
    ddp_icpv_rec.item_residual_id := p6_a6;
    ddp_icpv_rec.sts_code := p6_a7;
    ddp_icpv_rec.version_number := p6_a8;
    ddp_icpv_rec.start_date := p6_a9;
    ddp_icpv_rec.end_date := p6_a10;
    ddp_icpv_rec.created_by := p6_a11;
    ddp_icpv_rec.creation_date := p6_a12;
    ddp_icpv_rec.last_updated_by := p6_a13;
    ddp_icpv_rec.last_update_date := p6_a14;
    ddp_icpv_rec.last_update_login := p6_a15;
    ddp_icpv_rec.attribute_category := p6_a16;
    ddp_icpv_rec.attribute1 := p6_a17;
    ddp_icpv_rec.attribute2 := p6_a18;
    ddp_icpv_rec.attribute3 := p6_a19;
    ddp_icpv_rec.attribute4 := p6_a20;
    ddp_icpv_rec.attribute5 := p6_a21;
    ddp_icpv_rec.attribute6 := p6_a22;
    ddp_icpv_rec.attribute7 := p6_a23;
    ddp_icpv_rec.attribute8 := p6_a24;
    ddp_icpv_rec.attribute9 := p6_a25;
    ddp_icpv_rec.attribute10 := p6_a26;
    ddp_icpv_rec.attribute11 := p6_a27;
    ddp_icpv_rec.attribute12 := p6_a28;
    ddp_icpv_rec.attribute13 := p6_a29;
    ddp_icpv_rec.attribute14 := p6_a30;
    ddp_icpv_rec.attribute15 := p6_a31;

    okl_irv_pvt_w.rosetta_table_copy_in_p1(ddp_irv_tbl, p7_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_item_residuals_pvt.update_version_irs_submit(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_irhv_rec,
      ddp_icpv_rec,
      ddp_irv_tbl,
      ddx_irhv_rec,
      ddx_icpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddx_irhv_rec.item_residual_id;
    p8_a1 := ddx_irhv_rec.orig_item_residual_id;
    p8_a2 := ddx_irhv_rec.object_version_number;
    p8_a3 := ddx_irhv_rec.inventory_item_id;
    p8_a4 := ddx_irhv_rec.organization_id;
    p8_a5 := ddx_irhv_rec.category_id;
    p8_a6 := ddx_irhv_rec.category_set_id;
    p8_a7 := ddx_irhv_rec.resi_category_set_id;
    p8_a8 := ddx_irhv_rec.category_type_code;
    p8_a9 := ddx_irhv_rec.residual_type_code;
    p8_a10 := ddx_irhv_rec.currency_code;
    p8_a11 := ddx_irhv_rec.sts_code;
    p8_a12 := ddx_irhv_rec.effective_from_date;
    p8_a13 := ddx_irhv_rec.effective_to_date;
    p8_a14 := ddx_irhv_rec.org_id;
    p8_a15 := ddx_irhv_rec.created_by;
    p8_a16 := ddx_irhv_rec.creation_date;
    p8_a17 := ddx_irhv_rec.last_updated_by;
    p8_a18 := ddx_irhv_rec.last_update_date;
    p8_a19 := ddx_irhv_rec.last_update_login;

    p9_a0 := ddx_icpv_rec.id;
    p9_a1 := ddx_icpv_rec.object_version_number;
    p9_a2 := ddx_icpv_rec.cat_id1;
    p9_a3 := ddx_icpv_rec.cat_id2;
    p9_a4 := ddx_icpv_rec.term_in_months;
    p9_a5 := ddx_icpv_rec.residual_value_percent;
    p9_a6 := ddx_icpv_rec.item_residual_id;
    p9_a7 := ddx_icpv_rec.sts_code;
    p9_a8 := ddx_icpv_rec.version_number;
    p9_a9 := ddx_icpv_rec.start_date;
    p9_a10 := ddx_icpv_rec.end_date;
    p9_a11 := ddx_icpv_rec.created_by;
    p9_a12 := ddx_icpv_rec.creation_date;
    p9_a13 := ddx_icpv_rec.last_updated_by;
    p9_a14 := ddx_icpv_rec.last_update_date;
    p9_a15 := ddx_icpv_rec.last_update_login;
    p9_a16 := ddx_icpv_rec.attribute_category;
    p9_a17 := ddx_icpv_rec.attribute1;
    p9_a18 := ddx_icpv_rec.attribute2;
    p9_a19 := ddx_icpv_rec.attribute3;
    p9_a20 := ddx_icpv_rec.attribute4;
    p9_a21 := ddx_icpv_rec.attribute5;
    p9_a22 := ddx_icpv_rec.attribute6;
    p9_a23 := ddx_icpv_rec.attribute7;
    p9_a24 := ddx_icpv_rec.attribute8;
    p9_a25 := ddx_icpv_rec.attribute9;
    p9_a26 := ddx_icpv_rec.attribute10;
    p9_a27 := ddx_icpv_rec.attribute11;
    p9_a28 := ddx_icpv_rec.attribute12;
    p9_a29 := ddx_icpv_rec.attribute13;
    p9_a30 := ddx_icpv_rec.attribute14;
    p9_a31 := ddx_icpv_rec.attribute15;
  end;

  procedure create_version_irs_submit(p_api_version  NUMBER
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
    , p5_a12  DATE
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  NUMBER
    , p5_a16  DATE
    , p5_a17  NUMBER
    , p5_a18  DATE
    , p5_a19  NUMBER
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  NUMBER
    , p6_a3  NUMBER
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p6_a9  DATE
    , p6_a10  DATE
    , p6_a11  NUMBER
    , p6_a12  DATE
    , p6_a13  NUMBER
    , p6_a14  DATE
    , p6_a15  NUMBER
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_DATE_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  NUMBER
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  DATE
    , p8_a13 out nocopy  DATE
    , p8_a14 out nocopy  NUMBER
    , p8_a15 out nocopy  NUMBER
    , p8_a16 out nocopy  DATE
    , p8_a17 out nocopy  NUMBER
    , p8_a18 out nocopy  DATE
    , p8_a19 out nocopy  NUMBER
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  NUMBER
    , p9_a3 out nocopy  NUMBER
    , p9_a4 out nocopy  NUMBER
    , p9_a5 out nocopy  NUMBER
    , p9_a6 out nocopy  NUMBER
    , p9_a7 out nocopy  VARCHAR2
    , p9_a8 out nocopy  VARCHAR2
    , p9_a9 out nocopy  DATE
    , p9_a10 out nocopy  DATE
    , p9_a11 out nocopy  NUMBER
    , p9_a12 out nocopy  DATE
    , p9_a13 out nocopy  NUMBER
    , p9_a14 out nocopy  DATE
    , p9_a15 out nocopy  NUMBER
    , p9_a16 out nocopy  VARCHAR2
    , p9_a17 out nocopy  VARCHAR2
    , p9_a18 out nocopy  VARCHAR2
    , p9_a19 out nocopy  VARCHAR2
    , p9_a20 out nocopy  VARCHAR2
    , p9_a21 out nocopy  VARCHAR2
    , p9_a22 out nocopy  VARCHAR2
    , p9_a23 out nocopy  VARCHAR2
    , p9_a24 out nocopy  VARCHAR2
    , p9_a25 out nocopy  VARCHAR2
    , p9_a26 out nocopy  VARCHAR2
    , p9_a27 out nocopy  VARCHAR2
    , p9_a28 out nocopy  VARCHAR2
    , p9_a29 out nocopy  VARCHAR2
    , p9_a30 out nocopy  VARCHAR2
    , p9_a31 out nocopy  VARCHAR2
  )

  as
    ddp_irhv_rec okl_item_residuals_pvt.okl_irhv_rec;
    ddp_icpv_rec okl_item_residuals_pvt.okl_icpv_rec;
    ddp_irv_tbl okl_item_residuals_pvt.okl_irv_tbl;
    ddx_irhv_rec okl_item_residuals_pvt.okl_irhv_rec;
    ddx_icpv_rec okl_item_residuals_pvt.okl_icpv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_irhv_rec.item_residual_id := p5_a0;
    ddp_irhv_rec.orig_item_residual_id := p5_a1;
    ddp_irhv_rec.object_version_number := p5_a2;
    ddp_irhv_rec.inventory_item_id := p5_a3;
    ddp_irhv_rec.organization_id := p5_a4;
    ddp_irhv_rec.category_id := p5_a5;
    ddp_irhv_rec.category_set_id := p5_a6;
    ddp_irhv_rec.resi_category_set_id := p5_a7;
    ddp_irhv_rec.category_type_code := p5_a8;
    ddp_irhv_rec.residual_type_code := p5_a9;
    ddp_irhv_rec.currency_code := p5_a10;
    ddp_irhv_rec.sts_code := p5_a11;
    ddp_irhv_rec.effective_from_date := p5_a12;
    ddp_irhv_rec.effective_to_date := p5_a13;
    ddp_irhv_rec.org_id := p5_a14;
    ddp_irhv_rec.created_by := p5_a15;
    ddp_irhv_rec.creation_date := p5_a16;
    ddp_irhv_rec.last_updated_by := p5_a17;
    ddp_irhv_rec.last_update_date := p5_a18;
    ddp_irhv_rec.last_update_login := p5_a19;

    ddp_icpv_rec.id := p6_a0;
    ddp_icpv_rec.object_version_number := p6_a1;
    ddp_icpv_rec.cat_id1 := p6_a2;
    ddp_icpv_rec.cat_id2 := p6_a3;
    ddp_icpv_rec.term_in_months := p6_a4;
    ddp_icpv_rec.residual_value_percent := p6_a5;
    ddp_icpv_rec.item_residual_id := p6_a6;
    ddp_icpv_rec.sts_code := p6_a7;
    ddp_icpv_rec.version_number := p6_a8;
    ddp_icpv_rec.start_date := p6_a9;
    ddp_icpv_rec.end_date := p6_a10;
    ddp_icpv_rec.created_by := p6_a11;
    ddp_icpv_rec.creation_date := p6_a12;
    ddp_icpv_rec.last_updated_by := p6_a13;
    ddp_icpv_rec.last_update_date := p6_a14;
    ddp_icpv_rec.last_update_login := p6_a15;
    ddp_icpv_rec.attribute_category := p6_a16;
    ddp_icpv_rec.attribute1 := p6_a17;
    ddp_icpv_rec.attribute2 := p6_a18;
    ddp_icpv_rec.attribute3 := p6_a19;
    ddp_icpv_rec.attribute4 := p6_a20;
    ddp_icpv_rec.attribute5 := p6_a21;
    ddp_icpv_rec.attribute6 := p6_a22;
    ddp_icpv_rec.attribute7 := p6_a23;
    ddp_icpv_rec.attribute8 := p6_a24;
    ddp_icpv_rec.attribute9 := p6_a25;
    ddp_icpv_rec.attribute10 := p6_a26;
    ddp_icpv_rec.attribute11 := p6_a27;
    ddp_icpv_rec.attribute12 := p6_a28;
    ddp_icpv_rec.attribute13 := p6_a29;
    ddp_icpv_rec.attribute14 := p6_a30;
    ddp_icpv_rec.attribute15 := p6_a31;

    okl_irv_pvt_w.rosetta_table_copy_in_p1(ddp_irv_tbl, p7_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_item_residuals_pvt.create_version_irs_submit(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_irhv_rec,
      ddp_icpv_rec,
      ddp_irv_tbl,
      ddx_irhv_rec,
      ddx_icpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddx_irhv_rec.item_residual_id;
    p8_a1 := ddx_irhv_rec.orig_item_residual_id;
    p8_a2 := ddx_irhv_rec.object_version_number;
    p8_a3 := ddx_irhv_rec.inventory_item_id;
    p8_a4 := ddx_irhv_rec.organization_id;
    p8_a5 := ddx_irhv_rec.category_id;
    p8_a6 := ddx_irhv_rec.category_set_id;
    p8_a7 := ddx_irhv_rec.resi_category_set_id;
    p8_a8 := ddx_irhv_rec.category_type_code;
    p8_a9 := ddx_irhv_rec.residual_type_code;
    p8_a10 := ddx_irhv_rec.currency_code;
    p8_a11 := ddx_irhv_rec.sts_code;
    p8_a12 := ddx_irhv_rec.effective_from_date;
    p8_a13 := ddx_irhv_rec.effective_to_date;
    p8_a14 := ddx_irhv_rec.org_id;
    p8_a15 := ddx_irhv_rec.created_by;
    p8_a16 := ddx_irhv_rec.creation_date;
    p8_a17 := ddx_irhv_rec.last_updated_by;
    p8_a18 := ddx_irhv_rec.last_update_date;
    p8_a19 := ddx_irhv_rec.last_update_login;

    p9_a0 := ddx_icpv_rec.id;
    p9_a1 := ddx_icpv_rec.object_version_number;
    p9_a2 := ddx_icpv_rec.cat_id1;
    p9_a3 := ddx_icpv_rec.cat_id2;
    p9_a4 := ddx_icpv_rec.term_in_months;
    p9_a5 := ddx_icpv_rec.residual_value_percent;
    p9_a6 := ddx_icpv_rec.item_residual_id;
    p9_a7 := ddx_icpv_rec.sts_code;
    p9_a8 := ddx_icpv_rec.version_number;
    p9_a9 := ddx_icpv_rec.start_date;
    p9_a10 := ddx_icpv_rec.end_date;
    p9_a11 := ddx_icpv_rec.created_by;
    p9_a12 := ddx_icpv_rec.creation_date;
    p9_a13 := ddx_icpv_rec.last_updated_by;
    p9_a14 := ddx_icpv_rec.last_update_date;
    p9_a15 := ddx_icpv_rec.last_update_login;
    p9_a16 := ddx_icpv_rec.attribute_category;
    p9_a17 := ddx_icpv_rec.attribute1;
    p9_a18 := ddx_icpv_rec.attribute2;
    p9_a19 := ddx_icpv_rec.attribute3;
    p9_a20 := ddx_icpv_rec.attribute4;
    p9_a21 := ddx_icpv_rec.attribute5;
    p9_a22 := ddx_icpv_rec.attribute6;
    p9_a23 := ddx_icpv_rec.attribute7;
    p9_a24 := ddx_icpv_rec.attribute8;
    p9_a25 := ddx_icpv_rec.attribute9;
    p9_a26 := ddx_icpv_rec.attribute10;
    p9_a27 := ddx_icpv_rec.attribute11;
    p9_a28 := ddx_icpv_rec.attribute12;
    p9_a29 := ddx_icpv_rec.attribute13;
    p9_a30 := ddx_icpv_rec.attribute14;
    p9_a31 := ddx_icpv_rec.attribute15;
  end;

end okl_item_residuals_pvt_w;

/
