--------------------------------------------------------
--  DDL for Package Body OKL_ECO_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ECO_PVT_W" as
  /* $Header: OKLIECOB.pls 120.1 2005/10/30 04:58:42 appldev noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy okl_eco_pvt.okl_eco_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).object_class_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).crit_cat_def_id := a2(indx);
          t(ddindx).object_class_code := a3(indx);
          t(ddindx).is_applicable := a4(indx);
          t(ddindx).created_by := a5(indx);
          t(ddindx).creation_date := a6(indx);
          t(ddindx).last_updated_by := a7(indx);
          t(ddindx).last_update_date := a8(indx);
          t(ddindx).last_update_login := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t okl_eco_pvt.okl_eco_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).object_class_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).crit_cat_def_id;
          a3(indx) := t(ddindx).object_class_code;
          a4(indx) := t(ddindx).is_applicable;
          a5(indx) := t(ddindx).created_by;
          a6(indx) := t(ddindx).creation_date;
          a7(indx) := t(ddindx).last_updated_by;
          a8(indx) := t(ddindx).last_update_date;
          a9(indx) := t(ddindx).last_update_login;
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
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  NUMBER
    , p5_a6  DATE
    , p5_a7  NUMBER
    , p5_a8  DATE
    , p5_a9  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  NUMBER
  )

  as
    ddp_eco_rec okl_eco_pvt.okl_eco_rec;
    ddx_eco_rec okl_eco_pvt.okl_eco_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_eco_rec.object_class_id := p5_a0;
    ddp_eco_rec.object_version_number := p5_a1;
    ddp_eco_rec.crit_cat_def_id := p5_a2;
    ddp_eco_rec.object_class_code := p5_a3;
    ddp_eco_rec.is_applicable := p5_a4;
    ddp_eco_rec.created_by := p5_a5;
    ddp_eco_rec.creation_date := p5_a6;
    ddp_eco_rec.last_updated_by := p5_a7;
    ddp_eco_rec.last_update_date := p5_a8;
    ddp_eco_rec.last_update_login := p5_a9;


    -- here's the delegated call to the old PL/SQL routine
    okl_eco_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_eco_rec,
      ddx_eco_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_eco_rec.object_class_id;
    p6_a1 := ddx_eco_rec.object_version_number;
    p6_a2 := ddx_eco_rec.crit_cat_def_id;
    p6_a3 := ddx_eco_rec.object_class_code;
    p6_a4 := ddx_eco_rec.is_applicable;
    p6_a5 := ddx_eco_rec.created_by;
    p6_a6 := ddx_eco_rec.creation_date;
    p6_a7 := ddx_eco_rec.last_updated_by;
    p6_a8 := ddx_eco_rec.last_update_date;
    p6_a9 := ddx_eco_rec.last_update_login;
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_eco_tbl okl_eco_pvt.okl_eco_tbl;
    ddx_eco_tbl okl_eco_pvt.okl_eco_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_eco_pvt_w.rosetta_table_copy_in_p1(ddp_eco_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_eco_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_eco_tbl,
      ddx_eco_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_eco_pvt_w.rosetta_table_copy_out_p1(ddx_eco_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
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
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  NUMBER
    , p5_a6  DATE
    , p5_a7  NUMBER
    , p5_a8  DATE
    , p5_a9  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  NUMBER
  )

  as
    ddp_eco_rec okl_eco_pvt.okl_eco_rec;
    ddx_eco_rec okl_eco_pvt.okl_eco_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_eco_rec.object_class_id := p5_a0;
    ddp_eco_rec.object_version_number := p5_a1;
    ddp_eco_rec.crit_cat_def_id := p5_a2;
    ddp_eco_rec.object_class_code := p5_a3;
    ddp_eco_rec.is_applicable := p5_a4;
    ddp_eco_rec.created_by := p5_a5;
    ddp_eco_rec.creation_date := p5_a6;
    ddp_eco_rec.last_updated_by := p5_a7;
    ddp_eco_rec.last_update_date := p5_a8;
    ddp_eco_rec.last_update_login := p5_a9;


    -- here's the delegated call to the old PL/SQL routine
    okl_eco_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_eco_rec,
      ddx_eco_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_eco_rec.object_class_id;
    p6_a1 := ddx_eco_rec.object_version_number;
    p6_a2 := ddx_eco_rec.crit_cat_def_id;
    p6_a3 := ddx_eco_rec.object_class_code;
    p6_a4 := ddx_eco_rec.is_applicable;
    p6_a5 := ddx_eco_rec.created_by;
    p6_a6 := ddx_eco_rec.creation_date;
    p6_a7 := ddx_eco_rec.last_updated_by;
    p6_a8 := ddx_eco_rec.last_update_date;
    p6_a9 := ddx_eco_rec.last_update_login;
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_eco_tbl okl_eco_pvt.okl_eco_tbl;
    ddx_eco_tbl okl_eco_pvt.okl_eco_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_eco_pvt_w.rosetta_table_copy_in_p1(ddp_eco_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_eco_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_eco_tbl,
      ddx_eco_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_eco_pvt_w.rosetta_table_copy_out_p1(ddx_eco_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
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
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  NUMBER
    , p5_a6  DATE
    , p5_a7  NUMBER
    , p5_a8  DATE
    , p5_a9  NUMBER
  )

  as
    ddp_eco_rec okl_eco_pvt.okl_eco_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_eco_rec.object_class_id := p5_a0;
    ddp_eco_rec.object_version_number := p5_a1;
    ddp_eco_rec.crit_cat_def_id := p5_a2;
    ddp_eco_rec.object_class_code := p5_a3;
    ddp_eco_rec.is_applicable := p5_a4;
    ddp_eco_rec.created_by := p5_a5;
    ddp_eco_rec.creation_date := p5_a6;
    ddp_eco_rec.last_updated_by := p5_a7;
    ddp_eco_rec.last_update_date := p5_a8;
    ddp_eco_rec.last_update_login := p5_a9;

    -- here's the delegated call to the old PL/SQL routine
    okl_eco_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_eco_rec);

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
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
  )

  as
    ddp_eco_tbl okl_eco_pvt.okl_eco_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_eco_pvt_w.rosetta_table_copy_in_p1(ddp_eco_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_eco_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_eco_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_eco_pvt_w;

/
