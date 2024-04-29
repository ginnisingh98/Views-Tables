--------------------------------------------------------
--  DDL for Package Body OKL_IRH_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_IRH_PVT_W" as
  /* $Header: OKLIIRHB.pls 120.1 2005/07/11 10:25:40 smadhava noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy okl_irh_pvt.okl_irhv_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).item_residual_id := a0(indx);
          t(ddindx).orig_item_residual_id := a1(indx);
          t(ddindx).object_version_number := a2(indx);
          t(ddindx).inventory_item_id := a3(indx);
          t(ddindx).organization_id := a4(indx);
          t(ddindx).category_id := a5(indx);
          t(ddindx).category_set_id := a6(indx);
          t(ddindx).resi_category_set_id := a7(indx);
          t(ddindx).category_type_code := a8(indx);
          t(ddindx).residual_type_code := a9(indx);
          t(ddindx).currency_code := a10(indx);
          t(ddindx).sts_code := a11(indx);
          t(ddindx).effective_from_date := a12(indx);
          t(ddindx).effective_to_date := a13(indx);
          t(ddindx).org_id := a14(indx);
          t(ddindx).created_by := a15(indx);
          t(ddindx).creation_date := a16(indx);
          t(ddindx).last_updated_by := a17(indx);
          t(ddindx).last_update_date := a18(indx);
          t(ddindx).last_update_login := a19(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t okl_irh_pvt.okl_irhv_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
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
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_NUMBER_TABLE();
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
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).item_residual_id;
          a1(indx) := t(ddindx).orig_item_residual_id;
          a2(indx) := t(ddindx).object_version_number;
          a3(indx) := t(ddindx).inventory_item_id;
          a4(indx) := t(ddindx).organization_id;
          a5(indx) := t(ddindx).category_id;
          a6(indx) := t(ddindx).category_set_id;
          a7(indx) := t(ddindx).resi_category_set_id;
          a8(indx) := t(ddindx).category_type_code;
          a9(indx) := t(ddindx).residual_type_code;
          a10(indx) := t(ddindx).currency_code;
          a11(indx) := t(ddindx).sts_code;
          a12(indx) := t(ddindx).effective_from_date;
          a13(indx) := t(ddindx).effective_to_date;
          a14(indx) := t(ddindx).org_id;
          a15(indx) := t(ddindx).created_by;
          a16(indx) := t(ddindx).creation_date;
          a17(indx) := t(ddindx).last_updated_by;
          a18(indx) := t(ddindx).last_update_date;
          a19(indx) := t(ddindx).last_update_login;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy okl_irh_pvt.okl_irh_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).item_residual_id := a0(indx);
          t(ddindx).orig_item_residual_id := a1(indx);
          t(ddindx).object_version_number := a2(indx);
          t(ddindx).inventory_item_id := a3(indx);
          t(ddindx).organization_id := a4(indx);
          t(ddindx).category_id := a5(indx);
          t(ddindx).category_set_id := a6(indx);
          t(ddindx).resi_category_set_id := a7(indx);
          t(ddindx).category_type_code := a8(indx);
          t(ddindx).residual_type_code := a9(indx);
          t(ddindx).currency_code := a10(indx);
          t(ddindx).sts_code := a11(indx);
          t(ddindx).effective_from_date := a12(indx);
          t(ddindx).effective_to_date := a13(indx);
          t(ddindx).org_id := a14(indx);
          t(ddindx).created_by := a15(indx);
          t(ddindx).creation_date := a16(indx);
          t(ddindx).last_updated_by := a17(indx);
          t(ddindx).last_update_date := a18(indx);
          t(ddindx).last_update_login := a19(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t okl_irh_pvt.okl_irh_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
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
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_NUMBER_TABLE();
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
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).item_residual_id;
          a1(indx) := t(ddindx).orig_item_residual_id;
          a2(indx) := t(ddindx).object_version_number;
          a3(indx) := t(ddindx).inventory_item_id;
          a4(indx) := t(ddindx).organization_id;
          a5(indx) := t(ddindx).category_id;
          a6(indx) := t(ddindx).category_set_id;
          a7(indx) := t(ddindx).resi_category_set_id;
          a8(indx) := t(ddindx).category_type_code;
          a9(indx) := t(ddindx).residual_type_code;
          a10(indx) := t(ddindx).currency_code;
          a11(indx) := t(ddindx).sts_code;
          a12(indx) := t(ddindx).effective_from_date;
          a13(indx) := t(ddindx).effective_to_date;
          a14(indx) := t(ddindx).org_id;
          a15(indx) := t(ddindx).created_by;
          a16(indx) := t(ddindx).creation_date;
          a17(indx) := t(ddindx).last_updated_by;
          a18(indx) := t(ddindx).last_update_date;
          a19(indx) := t(ddindx).last_update_login;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

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
    , p5_a12  DATE
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  NUMBER
    , p5_a16  DATE
    , p5_a17  NUMBER
    , p5_a18  DATE
    , p5_a19  NUMBER
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
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  NUMBER
  )

  as
    ddp_irhv_rec okl_irh_pvt.okl_irhv_rec;
    ddx_irhv_rec okl_irh_pvt.okl_irhv_rec;
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


    -- here's the delegated call to the old PL/SQL routine
    okl_irh_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_irhv_rec,
      ddx_irhv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_irhv_rec.item_residual_id;
    p6_a1 := ddx_irhv_rec.orig_item_residual_id;
    p6_a2 := ddx_irhv_rec.object_version_number;
    p6_a3 := ddx_irhv_rec.inventory_item_id;
    p6_a4 := ddx_irhv_rec.organization_id;
    p6_a5 := ddx_irhv_rec.category_id;
    p6_a6 := ddx_irhv_rec.category_set_id;
    p6_a7 := ddx_irhv_rec.resi_category_set_id;
    p6_a8 := ddx_irhv_rec.category_type_code;
    p6_a9 := ddx_irhv_rec.residual_type_code;
    p6_a10 := ddx_irhv_rec.currency_code;
    p6_a11 := ddx_irhv_rec.sts_code;
    p6_a12 := ddx_irhv_rec.effective_from_date;
    p6_a13 := ddx_irhv_rec.effective_to_date;
    p6_a14 := ddx_irhv_rec.org_id;
    p6_a15 := ddx_irhv_rec.created_by;
    p6_a16 := ddx_irhv_rec.creation_date;
    p6_a17 := ddx_irhv_rec.last_updated_by;
    p6_a18 := ddx_irhv_rec.last_update_date;
    p6_a19 := ddx_irhv_rec.last_update_login;
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
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_irhv_tbl okl_irh_pvt.okl_irhv_tbl;
    ddx_irhv_tbl okl_irh_pvt.okl_irhv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_irh_pvt_w.rosetta_table_copy_in_p1(ddp_irhv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_irh_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_irhv_tbl,
      ddx_irhv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_irh_pvt_w.rosetta_table_copy_out_p1(ddx_irhv_tbl, p6_a0
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
    , p5_a12  DATE
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  NUMBER
    , p5_a16  DATE
    , p5_a17  NUMBER
    , p5_a18  DATE
    , p5_a19  NUMBER
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
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  NUMBER
  )

  as
    ddp_irhv_rec okl_irh_pvt.okl_irhv_rec;
    ddx_irhv_rec okl_irh_pvt.okl_irhv_rec;
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


    -- here's the delegated call to the old PL/SQL routine
    okl_irh_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_irhv_rec,
      ddx_irhv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_irhv_rec.item_residual_id;
    p6_a1 := ddx_irhv_rec.orig_item_residual_id;
    p6_a2 := ddx_irhv_rec.object_version_number;
    p6_a3 := ddx_irhv_rec.inventory_item_id;
    p6_a4 := ddx_irhv_rec.organization_id;
    p6_a5 := ddx_irhv_rec.category_id;
    p6_a6 := ddx_irhv_rec.category_set_id;
    p6_a7 := ddx_irhv_rec.resi_category_set_id;
    p6_a8 := ddx_irhv_rec.category_type_code;
    p6_a9 := ddx_irhv_rec.residual_type_code;
    p6_a10 := ddx_irhv_rec.currency_code;
    p6_a11 := ddx_irhv_rec.sts_code;
    p6_a12 := ddx_irhv_rec.effective_from_date;
    p6_a13 := ddx_irhv_rec.effective_to_date;
    p6_a14 := ddx_irhv_rec.org_id;
    p6_a15 := ddx_irhv_rec.created_by;
    p6_a16 := ddx_irhv_rec.creation_date;
    p6_a17 := ddx_irhv_rec.last_updated_by;
    p6_a18 := ddx_irhv_rec.last_update_date;
    p6_a19 := ddx_irhv_rec.last_update_login;
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
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_irhv_tbl okl_irh_pvt.okl_irhv_tbl;
    ddx_irhv_tbl okl_irh_pvt.okl_irhv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_irh_pvt_w.rosetta_table_copy_in_p1(ddp_irhv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_irh_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_irhv_tbl,
      ddx_irhv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_irh_pvt_w.rosetta_table_copy_out_p1(ddx_irhv_tbl, p6_a0
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
    , p5_a12  DATE
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  NUMBER
    , p5_a16  DATE
    , p5_a17  NUMBER
    , p5_a18  DATE
    , p5_a19  NUMBER
  )

  as
    ddp_irhv_rec okl_irh_pvt.okl_irhv_rec;
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

    -- here's the delegated call to the old PL/SQL routine
    okl_irh_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_irhv_rec);

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
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
  )

  as
    ddp_irhv_tbl okl_irh_pvt.okl_irhv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_irh_pvt_w.rosetta_table_copy_in_p1(ddp_irhv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_irh_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_irhv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_irh_pvt_w;

/
