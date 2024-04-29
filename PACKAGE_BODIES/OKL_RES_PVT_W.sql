--------------------------------------------------------
--  DDL for Package Body OKL_RES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RES_PVT_W" as
  /* $Header: OKLIRESB.pls 120.0 2005/07/08 14:23:26 smadhava noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy okl_res_pvt.okl_res_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).resi_cat_object_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).resi_category_set_id := a2(indx);
          t(ddindx).created_by := a3(indx);
          t(ddindx).creation_date := a4(indx);
          t(ddindx).last_updated_by := a5(indx);
          t(ddindx).last_update_date := a6(indx);
          t(ddindx).last_update_login := a7(indx);
          t(ddindx).inventory_item_id := a8(indx);
          t(ddindx).organization_id := a9(indx);
          t(ddindx).category_id := a10(indx);
          t(ddindx).category_set_id := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t okl_res_pvt.okl_res_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).resi_cat_object_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).resi_category_set_id;
          a3(indx) := t(ddindx).created_by;
          a4(indx) := t(ddindx).creation_date;
          a5(indx) := t(ddindx).last_updated_by;
          a6(indx) := t(ddindx).last_update_date;
          a7(indx) := t(ddindx).last_update_login;
          a8(indx) := t(ddindx).inventory_item_id;
          a9(indx) := t(ddindx).organization_id;
          a10(indx) := t(ddindx).category_id;
          a11(indx) := t(ddindx).category_set_id;
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
    , p5_a4  DATE
    , p5_a5  NUMBER
    , p5_a6  DATE
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  NUMBER
    , p5_a11  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
  )

  as
    ddp_res_rec okl_res_pvt.okl_res_rec;
    ddx_res_rec okl_res_pvt.okl_res_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_res_rec.resi_cat_object_id := p5_a0;
    ddp_res_rec.object_version_number := p5_a1;
    ddp_res_rec.resi_category_set_id := p5_a2;
    ddp_res_rec.created_by := p5_a3;
    ddp_res_rec.creation_date := p5_a4;
    ddp_res_rec.last_updated_by := p5_a5;
    ddp_res_rec.last_update_date := p5_a6;
    ddp_res_rec.last_update_login := p5_a7;
    ddp_res_rec.inventory_item_id := p5_a8;
    ddp_res_rec.organization_id := p5_a9;
    ddp_res_rec.category_id := p5_a10;
    ddp_res_rec.category_set_id := p5_a11;


    -- here's the delegated call to the old PL/SQL routine
    okl_res_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_res_rec,
      ddx_res_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_res_rec.resi_cat_object_id;
    p6_a1 := ddx_res_rec.object_version_number;
    p6_a2 := ddx_res_rec.resi_category_set_id;
    p6_a3 := ddx_res_rec.created_by;
    p6_a4 := ddx_res_rec.creation_date;
    p6_a5 := ddx_res_rec.last_updated_by;
    p6_a6 := ddx_res_rec.last_update_date;
    p6_a7 := ddx_res_rec.last_update_login;
    p6_a8 := ddx_res_rec.inventory_item_id;
    p6_a9 := ddx_res_rec.organization_id;
    p6_a10 := ddx_res_rec.category_id;
    p6_a11 := ddx_res_rec.category_set_id;
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
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_res_tbl okl_res_pvt.okl_res_tbl;
    ddx_res_tbl okl_res_pvt.okl_res_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_res_pvt_w.rosetta_table_copy_in_p1(ddp_res_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_res_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_res_tbl,
      ddx_res_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_res_pvt_w.rosetta_table_copy_out_p1(ddx_res_tbl, p6_a0
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
    , p5_a4  DATE
    , p5_a5  NUMBER
    , p5_a6  DATE
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  NUMBER
    , p5_a11  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
  )

  as
    ddp_res_rec okl_res_pvt.okl_res_rec;
    ddx_res_rec okl_res_pvt.okl_res_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_res_rec.resi_cat_object_id := p5_a0;
    ddp_res_rec.object_version_number := p5_a1;
    ddp_res_rec.resi_category_set_id := p5_a2;
    ddp_res_rec.created_by := p5_a3;
    ddp_res_rec.creation_date := p5_a4;
    ddp_res_rec.last_updated_by := p5_a5;
    ddp_res_rec.last_update_date := p5_a6;
    ddp_res_rec.last_update_login := p5_a7;
    ddp_res_rec.inventory_item_id := p5_a8;
    ddp_res_rec.organization_id := p5_a9;
    ddp_res_rec.category_id := p5_a10;
    ddp_res_rec.category_set_id := p5_a11;


    -- here's the delegated call to the old PL/SQL routine
    okl_res_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_res_rec,
      ddx_res_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_res_rec.resi_cat_object_id;
    p6_a1 := ddx_res_rec.object_version_number;
    p6_a2 := ddx_res_rec.resi_category_set_id;
    p6_a3 := ddx_res_rec.created_by;
    p6_a4 := ddx_res_rec.creation_date;
    p6_a5 := ddx_res_rec.last_updated_by;
    p6_a6 := ddx_res_rec.last_update_date;
    p6_a7 := ddx_res_rec.last_update_login;
    p6_a8 := ddx_res_rec.inventory_item_id;
    p6_a9 := ddx_res_rec.organization_id;
    p6_a10 := ddx_res_rec.category_id;
    p6_a11 := ddx_res_rec.category_set_id;
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
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_res_tbl okl_res_pvt.okl_res_tbl;
    ddx_res_tbl okl_res_pvt.okl_res_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_res_pvt_w.rosetta_table_copy_in_p1(ddp_res_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_res_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_res_tbl,
      ddx_res_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_res_pvt_w.rosetta_table_copy_out_p1(ddx_res_tbl, p6_a0
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
    , p5_a4  DATE
    , p5_a5  NUMBER
    , p5_a6  DATE
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  NUMBER
    , p5_a11  NUMBER
  )

  as
    ddp_res_rec okl_res_pvt.okl_res_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_res_rec.resi_cat_object_id := p5_a0;
    ddp_res_rec.object_version_number := p5_a1;
    ddp_res_rec.resi_category_set_id := p5_a2;
    ddp_res_rec.created_by := p5_a3;
    ddp_res_rec.creation_date := p5_a4;
    ddp_res_rec.last_updated_by := p5_a5;
    ddp_res_rec.last_update_date := p5_a6;
    ddp_res_rec.last_update_login := p5_a7;
    ddp_res_rec.inventory_item_id := p5_a8;
    ddp_res_rec.organization_id := p5_a9;
    ddp_res_rec.category_id := p5_a10;
    ddp_res_rec.category_set_id := p5_a11;

    -- here's the delegated call to the old PL/SQL routine
    okl_res_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_res_rec);

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
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
  )

  as
    ddp_res_tbl okl_res_pvt.okl_res_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_res_pvt_w.rosetta_table_copy_in_p1(ddp_res_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_res_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_res_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_res_pvt_w;

/
