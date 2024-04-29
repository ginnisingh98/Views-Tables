--------------------------------------------------------
--  DDL for Package Body OKL_FE_EO_TERM_OPTIONS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FE_EO_TERM_OPTIONS_PVT_W" as
  /* $Header: OKLEEOTB.pls 120.0 2005/07/07 10:37:19 viselvar noship $ */
  procedure rosetta_table_copy_in_p9(t out nocopy okl_fe_eo_term_options_pvt.invalid_object_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).obj_id := a0(indx);
          t(ddindx).obj_name := a1(indx);
          t(ddindx).obj_version := a2(indx);
          t(ddindx).obj_type := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t okl_fe_eo_term_options_pvt.invalid_object_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).obj_id;
          a1(indx) := t(ddindx).obj_name;
          a2(indx) := t(ddindx).obj_version;
          a3(indx) := t(ddindx).obj_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure get_item_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_end_of_term_id  NUMBER
    , p_version  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a24 out nocopy JTF_NUMBER_TABLE
    , p7_a25 out nocopy JTF_DATE_TABLE
    , p7_a26 out nocopy JTF_NUMBER_TABLE
    , p7_a27 out nocopy JTF_DATE_TABLE
    , p7_a28 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_eto_tbl okl_fe_eo_term_options_pvt.okl_eto_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    okl_fe_eo_term_options_pvt.get_item_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_end_of_term_id,
      p_version,
      ddx_eto_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_eto_pvt_w.rosetta_table_copy_out_p1(ddx_eto_tbl, p7_a0
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
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      );
  end;

  procedure get_eo_term_values(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_end_of_term_id  NUMBER
    , p_version  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a21 out nocopy JTF_NUMBER_TABLE
    , p7_a22 out nocopy JTF_DATE_TABLE
    , p7_a23 out nocopy JTF_NUMBER_TABLE
    , p7_a24 out nocopy JTF_DATE_TABLE
    , p7_a25 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_etv_tbl okl_fe_eo_term_options_pvt.okl_etv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    okl_fe_eo_term_options_pvt.get_eo_term_values(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_end_of_term_id,
      p_version,
      ddx_etv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_etv_pvt_w.rosetta_table_copy_out_p1(ddx_etv_tbl, p7_a0
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
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      );
  end;

  procedure get_end_of_term_option(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_eot_id  NUMBER
    , p_version  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  DATE
    , p7_a12 out nocopy  DATE
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  VARCHAR2
    , p7_a24 out nocopy  VARCHAR2
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  VARCHAR2
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  NUMBER
    , p7_a30 out nocopy  DATE
    , p7_a31 out nocopy  NUMBER
    , p7_a32 out nocopy  DATE
    , p7_a33 out nocopy  NUMBER
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  DATE
    , p8_a4 out nocopy  DATE
    , p8_a5 out nocopy  VARCHAR2
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  VARCHAR2
    , p8_a13 out nocopy  VARCHAR2
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  VARCHAR2
    , p8_a17 out nocopy  VARCHAR2
    , p8_a18 out nocopy  VARCHAR2
    , p8_a19 out nocopy  VARCHAR2
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  NUMBER
    , p8_a24 out nocopy  DATE
    , p8_a25 out nocopy  NUMBER
    , p8_a26 out nocopy  DATE
    , p8_a27 out nocopy  NUMBER
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_NUMBER_TABLE
    , p9_a7 out nocopy JTF_NUMBER_TABLE
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a24 out nocopy JTF_NUMBER_TABLE
    , p9_a25 out nocopy JTF_DATE_TABLE
    , p9_a26 out nocopy JTF_NUMBER_TABLE
    , p9_a27 out nocopy JTF_DATE_TABLE
    , p9_a28 out nocopy JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a21 out nocopy JTF_NUMBER_TABLE
    , p10_a22 out nocopy JTF_DATE_TABLE
    , p10_a23 out nocopy JTF_NUMBER_TABLE
    , p10_a24 out nocopy JTF_DATE_TABLE
    , p10_a25 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_ethv_rec okl_fe_eo_term_options_pvt.okl_ethv_rec;
    ddx_eve_rec okl_fe_eo_term_options_pvt.okl_eve_rec;
    ddx_eto_tbl okl_fe_eo_term_options_pvt.okl_eto_tbl;
    ddx_etv_tbl okl_fe_eo_term_options_pvt.okl_etv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    okl_fe_eo_term_options_pvt.get_end_of_term_option(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_eot_id,
      p_version,
      ddx_ethv_rec,
      ddx_eve_rec,
      ddx_eto_tbl,
      ddx_etv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_ethv_rec.end_of_term_id;
    p7_a1 := ddx_ethv_rec.object_version_number;
    p7_a2 := ddx_ethv_rec.end_of_term_name;
    p7_a3 := ddx_ethv_rec.end_of_term_desc;
    p7_a4 := ddx_ethv_rec.org_id;
    p7_a5 := ddx_ethv_rec.currency_code;
    p7_a6 := ddx_ethv_rec.eot_type_code;
    p7_a7 := ddx_ethv_rec.product_id;
    p7_a8 := ddx_ethv_rec.category_type_code;
    p7_a9 := ddx_ethv_rec.orig_end_of_term_id;
    p7_a10 := ddx_ethv_rec.sts_code;
    p7_a11 := ddx_ethv_rec.effective_from_date;
    p7_a12 := ddx_ethv_rec.effective_to_date;
    p7_a13 := ddx_ethv_rec.attribute_category;
    p7_a14 := ddx_ethv_rec.attribute1;
    p7_a15 := ddx_ethv_rec.attribute2;
    p7_a16 := ddx_ethv_rec.attribute3;
    p7_a17 := ddx_ethv_rec.attribute4;
    p7_a18 := ddx_ethv_rec.attribute5;
    p7_a19 := ddx_ethv_rec.attribute6;
    p7_a20 := ddx_ethv_rec.attribute7;
    p7_a21 := ddx_ethv_rec.attribute8;
    p7_a22 := ddx_ethv_rec.attribute9;
    p7_a23 := ddx_ethv_rec.attribute10;
    p7_a24 := ddx_ethv_rec.attribute11;
    p7_a25 := ddx_ethv_rec.attribute12;
    p7_a26 := ddx_ethv_rec.attribute13;
    p7_a27 := ddx_ethv_rec.attribute14;
    p7_a28 := ddx_ethv_rec.attribute15;
    p7_a29 := ddx_ethv_rec.created_by;
    p7_a30 := ddx_ethv_rec.creation_date;
    p7_a31 := ddx_ethv_rec.last_updated_by;
    p7_a32 := ddx_ethv_rec.last_update_date;
    p7_a33 := ddx_ethv_rec.last_update_login;

    p8_a0 := ddx_eve_rec.end_of_term_ver_id;
    p8_a1 := ddx_eve_rec.object_version_number;
    p8_a2 := ddx_eve_rec.version_number;
    p8_a3 := ddx_eve_rec.effective_from_date;
    p8_a4 := ddx_eve_rec.effective_to_date;
    p8_a5 := ddx_eve_rec.sts_code;
    p8_a6 := ddx_eve_rec.end_of_term_id;
    p8_a7 := ddx_eve_rec.attribute_category;
    p8_a8 := ddx_eve_rec.attribute1;
    p8_a9 := ddx_eve_rec.attribute2;
    p8_a10 := ddx_eve_rec.attribute3;
    p8_a11 := ddx_eve_rec.attribute4;
    p8_a12 := ddx_eve_rec.attribute5;
    p8_a13 := ddx_eve_rec.attribute6;
    p8_a14 := ddx_eve_rec.attribute7;
    p8_a15 := ddx_eve_rec.attribute8;
    p8_a16 := ddx_eve_rec.attribute9;
    p8_a17 := ddx_eve_rec.attribute10;
    p8_a18 := ddx_eve_rec.attribute11;
    p8_a19 := ddx_eve_rec.attribute12;
    p8_a20 := ddx_eve_rec.attribute13;
    p8_a21 := ddx_eve_rec.attribute14;
    p8_a22 := ddx_eve_rec.attribute15;
    p8_a23 := ddx_eve_rec.created_by;
    p8_a24 := ddx_eve_rec.creation_date;
    p8_a25 := ddx_eve_rec.last_updated_by;
    p8_a26 := ddx_eve_rec.last_update_date;
    p8_a27 := ddx_eve_rec.last_update_login;

    okl_eto_pvt_w.rosetta_table_copy_out_p1(ddx_eto_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      , p9_a26
      , p9_a27
      , p9_a28
      );

    okl_etv_pvt_w.rosetta_table_copy_out_p1(ddx_etv_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      , p10_a13
      , p10_a14
      , p10_a15
      , p10_a16
      , p10_a17
      , p10_a18
      , p10_a19
      , p10_a20
      , p10_a21
      , p10_a22
      , p10_a23
      , p10_a24
      , p10_a25
      );
  end;

  procedure insert_end_of_term_option(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  NUMBER
    , p5_a8  VARCHAR2
    , p5_a9  NUMBER
    , p5_a10  VARCHAR2
    , p5_a11  DATE
    , p5_a12  DATE
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
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  NUMBER
    , p5_a30  DATE
    , p5_a31  NUMBER
    , p5_a32  DATE
    , p5_a33  NUMBER
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  VARCHAR2
    , p6_a3  DATE
    , p6_a4  DATE
    , p6_a5  VARCHAR2
    , p6_a6  NUMBER
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p6_a9  VARCHAR2
    , p6_a10  VARCHAR2
    , p6_a11  VARCHAR2
    , p6_a12  VARCHAR2
    , p6_a13  VARCHAR2
    , p6_a14  VARCHAR2
    , p6_a15  VARCHAR2
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  NUMBER
    , p6_a24  DATE
    , p6_a25  NUMBER
    , p6_a26  DATE
    , p6_a27  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_VARCHAR2_TABLE_100
    , p7_a9 JTF_VARCHAR2_TABLE_500
    , p7_a10 JTF_VARCHAR2_TABLE_500
    , p7_a11 JTF_VARCHAR2_TABLE_500
    , p7_a12 JTF_VARCHAR2_TABLE_500
    , p7_a13 JTF_VARCHAR2_TABLE_500
    , p7_a14 JTF_VARCHAR2_TABLE_500
    , p7_a15 JTF_VARCHAR2_TABLE_500
    , p7_a16 JTF_VARCHAR2_TABLE_500
    , p7_a17 JTF_VARCHAR2_TABLE_500
    , p7_a18 JTF_VARCHAR2_TABLE_500
    , p7_a19 JTF_VARCHAR2_TABLE_500
    , p7_a20 JTF_VARCHAR2_TABLE_500
    , p7_a21 JTF_VARCHAR2_TABLE_500
    , p7_a22 JTF_VARCHAR2_TABLE_500
    , p7_a23 JTF_VARCHAR2_TABLE_500
    , p7_a24 JTF_NUMBER_TABLE
    , p7_a25 JTF_DATE_TABLE
    , p7_a26 JTF_NUMBER_TABLE
    , p7_a27 JTF_DATE_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_VARCHAR2_TABLE_100
    , p8_a6 JTF_VARCHAR2_TABLE_500
    , p8_a7 JTF_VARCHAR2_TABLE_500
    , p8_a8 JTF_VARCHAR2_TABLE_500
    , p8_a9 JTF_VARCHAR2_TABLE_500
    , p8_a10 JTF_VARCHAR2_TABLE_500
    , p8_a11 JTF_VARCHAR2_TABLE_500
    , p8_a12 JTF_VARCHAR2_TABLE_500
    , p8_a13 JTF_VARCHAR2_TABLE_500
    , p8_a14 JTF_VARCHAR2_TABLE_500
    , p8_a15 JTF_VARCHAR2_TABLE_500
    , p8_a16 JTF_VARCHAR2_TABLE_500
    , p8_a17 JTF_VARCHAR2_TABLE_500
    , p8_a18 JTF_VARCHAR2_TABLE_500
    , p8_a19 JTF_VARCHAR2_TABLE_500
    , p8_a20 JTF_VARCHAR2_TABLE_500
    , p8_a21 JTF_NUMBER_TABLE
    , p8_a22 JTF_DATE_TABLE
    , p8_a23 JTF_NUMBER_TABLE
    , p8_a24 JTF_DATE_TABLE
    , p8_a25 JTF_NUMBER_TABLE
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  VARCHAR2
    , p9_a3 out nocopy  VARCHAR2
    , p9_a4 out nocopy  NUMBER
    , p9_a5 out nocopy  VARCHAR2
    , p9_a6 out nocopy  VARCHAR2
    , p9_a7 out nocopy  NUMBER
    , p9_a8 out nocopy  VARCHAR2
    , p9_a9 out nocopy  NUMBER
    , p9_a10 out nocopy  VARCHAR2
    , p9_a11 out nocopy  DATE
    , p9_a12 out nocopy  DATE
    , p9_a13 out nocopy  VARCHAR2
    , p9_a14 out nocopy  VARCHAR2
    , p9_a15 out nocopy  VARCHAR2
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
    , p9_a29 out nocopy  NUMBER
    , p9_a30 out nocopy  DATE
    , p9_a31 out nocopy  NUMBER
    , p9_a32 out nocopy  DATE
    , p9_a33 out nocopy  NUMBER
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  VARCHAR2
    , p10_a3 out nocopy  DATE
    , p10_a4 out nocopy  DATE
    , p10_a5 out nocopy  VARCHAR2
    , p10_a6 out nocopy  NUMBER
    , p10_a7 out nocopy  VARCHAR2
    , p10_a8 out nocopy  VARCHAR2
    , p10_a9 out nocopy  VARCHAR2
    , p10_a10 out nocopy  VARCHAR2
    , p10_a11 out nocopy  VARCHAR2
    , p10_a12 out nocopy  VARCHAR2
    , p10_a13 out nocopy  VARCHAR2
    , p10_a14 out nocopy  VARCHAR2
    , p10_a15 out nocopy  VARCHAR2
    , p10_a16 out nocopy  VARCHAR2
    , p10_a17 out nocopy  VARCHAR2
    , p10_a18 out nocopy  VARCHAR2
    , p10_a19 out nocopy  VARCHAR2
    , p10_a20 out nocopy  VARCHAR2
    , p10_a21 out nocopy  VARCHAR2
    , p10_a22 out nocopy  VARCHAR2
    , p10_a23 out nocopy  NUMBER
    , p10_a24 out nocopy  DATE
    , p10_a25 out nocopy  NUMBER
    , p10_a26 out nocopy  DATE
    , p10_a27 out nocopy  NUMBER
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_NUMBER_TABLE
    , p11_a3 out nocopy JTF_NUMBER_TABLE
    , p11_a4 out nocopy JTF_NUMBER_TABLE
    , p11_a5 out nocopy JTF_NUMBER_TABLE
    , p11_a6 out nocopy JTF_NUMBER_TABLE
    , p11_a7 out nocopy JTF_NUMBER_TABLE
    , p11_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a24 out nocopy JTF_NUMBER_TABLE
    , p11_a25 out nocopy JTF_DATE_TABLE
    , p11_a26 out nocopy JTF_NUMBER_TABLE
    , p11_a27 out nocopy JTF_DATE_TABLE
    , p11_a28 out nocopy JTF_NUMBER_TABLE
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_NUMBER_TABLE
    , p12_a3 out nocopy JTF_NUMBER_TABLE
    , p12_a4 out nocopy JTF_NUMBER_TABLE
    , p12_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a21 out nocopy JTF_NUMBER_TABLE
    , p12_a22 out nocopy JTF_DATE_TABLE
    , p12_a23 out nocopy JTF_NUMBER_TABLE
    , p12_a24 out nocopy JTF_DATE_TABLE
    , p12_a25 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_ethv_rec okl_fe_eo_term_options_pvt.okl_ethv_rec;
    ddp_eve_rec okl_fe_eo_term_options_pvt.okl_eve_rec;
    ddp_eto_tbl okl_fe_eo_term_options_pvt.okl_eto_tbl;
    ddp_etv_tbl okl_fe_eo_term_options_pvt.okl_etv_tbl;
    ddx_ethv_rec okl_fe_eo_term_options_pvt.okl_ethv_rec;
    ddx_eve_rec okl_fe_eo_term_options_pvt.okl_eve_rec;
    ddx_eto_tbl okl_fe_eo_term_options_pvt.okl_eto_tbl;
    ddx_etv_tbl okl_fe_eo_term_options_pvt.okl_etv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ethv_rec.end_of_term_id := p5_a0;
    ddp_ethv_rec.object_version_number := p5_a1;
    ddp_ethv_rec.end_of_term_name := p5_a2;
    ddp_ethv_rec.end_of_term_desc := p5_a3;
    ddp_ethv_rec.org_id := p5_a4;
    ddp_ethv_rec.currency_code := p5_a5;
    ddp_ethv_rec.eot_type_code := p5_a6;
    ddp_ethv_rec.product_id := p5_a7;
    ddp_ethv_rec.category_type_code := p5_a8;
    ddp_ethv_rec.orig_end_of_term_id := p5_a9;
    ddp_ethv_rec.sts_code := p5_a10;
    ddp_ethv_rec.effective_from_date := p5_a11;
    ddp_ethv_rec.effective_to_date := p5_a12;
    ddp_ethv_rec.attribute_category := p5_a13;
    ddp_ethv_rec.attribute1 := p5_a14;
    ddp_ethv_rec.attribute2 := p5_a15;
    ddp_ethv_rec.attribute3 := p5_a16;
    ddp_ethv_rec.attribute4 := p5_a17;
    ddp_ethv_rec.attribute5 := p5_a18;
    ddp_ethv_rec.attribute6 := p5_a19;
    ddp_ethv_rec.attribute7 := p5_a20;
    ddp_ethv_rec.attribute8 := p5_a21;
    ddp_ethv_rec.attribute9 := p5_a22;
    ddp_ethv_rec.attribute10 := p5_a23;
    ddp_ethv_rec.attribute11 := p5_a24;
    ddp_ethv_rec.attribute12 := p5_a25;
    ddp_ethv_rec.attribute13 := p5_a26;
    ddp_ethv_rec.attribute14 := p5_a27;
    ddp_ethv_rec.attribute15 := p5_a28;
    ddp_ethv_rec.created_by := p5_a29;
    ddp_ethv_rec.creation_date := p5_a30;
    ddp_ethv_rec.last_updated_by := p5_a31;
    ddp_ethv_rec.last_update_date := p5_a32;
    ddp_ethv_rec.last_update_login := p5_a33;

    ddp_eve_rec.end_of_term_ver_id := p6_a0;
    ddp_eve_rec.object_version_number := p6_a1;
    ddp_eve_rec.version_number := p6_a2;
    ddp_eve_rec.effective_from_date := p6_a3;
    ddp_eve_rec.effective_to_date := p6_a4;
    ddp_eve_rec.sts_code := p6_a5;
    ddp_eve_rec.end_of_term_id := p6_a6;
    ddp_eve_rec.attribute_category := p6_a7;
    ddp_eve_rec.attribute1 := p6_a8;
    ddp_eve_rec.attribute2 := p6_a9;
    ddp_eve_rec.attribute3 := p6_a10;
    ddp_eve_rec.attribute4 := p6_a11;
    ddp_eve_rec.attribute5 := p6_a12;
    ddp_eve_rec.attribute6 := p6_a13;
    ddp_eve_rec.attribute7 := p6_a14;
    ddp_eve_rec.attribute8 := p6_a15;
    ddp_eve_rec.attribute9 := p6_a16;
    ddp_eve_rec.attribute10 := p6_a17;
    ddp_eve_rec.attribute11 := p6_a18;
    ddp_eve_rec.attribute12 := p6_a19;
    ddp_eve_rec.attribute13 := p6_a20;
    ddp_eve_rec.attribute14 := p6_a21;
    ddp_eve_rec.attribute15 := p6_a22;
    ddp_eve_rec.created_by := p6_a23;
    ddp_eve_rec.creation_date := p6_a24;
    ddp_eve_rec.last_updated_by := p6_a25;
    ddp_eve_rec.last_update_date := p6_a26;
    ddp_eve_rec.last_update_login := p6_a27;

    okl_eto_pvt_w.rosetta_table_copy_in_p1(ddp_eto_tbl, p7_a0
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
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      );

    okl_etv_pvt_w.rosetta_table_copy_in_p1(ddp_etv_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      );





    -- here's the delegated call to the old PL/SQL routine
    okl_fe_eo_term_options_pvt.insert_end_of_term_option(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ethv_rec,
      ddp_eve_rec,
      ddp_eto_tbl,
      ddp_etv_tbl,
      ddx_ethv_rec,
      ddx_eve_rec,
      ddx_eto_tbl,
      ddx_etv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := ddx_ethv_rec.end_of_term_id;
    p9_a1 := ddx_ethv_rec.object_version_number;
    p9_a2 := ddx_ethv_rec.end_of_term_name;
    p9_a3 := ddx_ethv_rec.end_of_term_desc;
    p9_a4 := ddx_ethv_rec.org_id;
    p9_a5 := ddx_ethv_rec.currency_code;
    p9_a6 := ddx_ethv_rec.eot_type_code;
    p9_a7 := ddx_ethv_rec.product_id;
    p9_a8 := ddx_ethv_rec.category_type_code;
    p9_a9 := ddx_ethv_rec.orig_end_of_term_id;
    p9_a10 := ddx_ethv_rec.sts_code;
    p9_a11 := ddx_ethv_rec.effective_from_date;
    p9_a12 := ddx_ethv_rec.effective_to_date;
    p9_a13 := ddx_ethv_rec.attribute_category;
    p9_a14 := ddx_ethv_rec.attribute1;
    p9_a15 := ddx_ethv_rec.attribute2;
    p9_a16 := ddx_ethv_rec.attribute3;
    p9_a17 := ddx_ethv_rec.attribute4;
    p9_a18 := ddx_ethv_rec.attribute5;
    p9_a19 := ddx_ethv_rec.attribute6;
    p9_a20 := ddx_ethv_rec.attribute7;
    p9_a21 := ddx_ethv_rec.attribute8;
    p9_a22 := ddx_ethv_rec.attribute9;
    p9_a23 := ddx_ethv_rec.attribute10;
    p9_a24 := ddx_ethv_rec.attribute11;
    p9_a25 := ddx_ethv_rec.attribute12;
    p9_a26 := ddx_ethv_rec.attribute13;
    p9_a27 := ddx_ethv_rec.attribute14;
    p9_a28 := ddx_ethv_rec.attribute15;
    p9_a29 := ddx_ethv_rec.created_by;
    p9_a30 := ddx_ethv_rec.creation_date;
    p9_a31 := ddx_ethv_rec.last_updated_by;
    p9_a32 := ddx_ethv_rec.last_update_date;
    p9_a33 := ddx_ethv_rec.last_update_login;

    p10_a0 := ddx_eve_rec.end_of_term_ver_id;
    p10_a1 := ddx_eve_rec.object_version_number;
    p10_a2 := ddx_eve_rec.version_number;
    p10_a3 := ddx_eve_rec.effective_from_date;
    p10_a4 := ddx_eve_rec.effective_to_date;
    p10_a5 := ddx_eve_rec.sts_code;
    p10_a6 := ddx_eve_rec.end_of_term_id;
    p10_a7 := ddx_eve_rec.attribute_category;
    p10_a8 := ddx_eve_rec.attribute1;
    p10_a9 := ddx_eve_rec.attribute2;
    p10_a10 := ddx_eve_rec.attribute3;
    p10_a11 := ddx_eve_rec.attribute4;
    p10_a12 := ddx_eve_rec.attribute5;
    p10_a13 := ddx_eve_rec.attribute6;
    p10_a14 := ddx_eve_rec.attribute7;
    p10_a15 := ddx_eve_rec.attribute8;
    p10_a16 := ddx_eve_rec.attribute9;
    p10_a17 := ddx_eve_rec.attribute10;
    p10_a18 := ddx_eve_rec.attribute11;
    p10_a19 := ddx_eve_rec.attribute12;
    p10_a20 := ddx_eve_rec.attribute13;
    p10_a21 := ddx_eve_rec.attribute14;
    p10_a22 := ddx_eve_rec.attribute15;
    p10_a23 := ddx_eve_rec.created_by;
    p10_a24 := ddx_eve_rec.creation_date;
    p10_a25 := ddx_eve_rec.last_updated_by;
    p10_a26 := ddx_eve_rec.last_update_date;
    p10_a27 := ddx_eve_rec.last_update_login;

    okl_eto_pvt_w.rosetta_table_copy_out_p1(ddx_eto_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      , p11_a13
      , p11_a14
      , p11_a15
      , p11_a16
      , p11_a17
      , p11_a18
      , p11_a19
      , p11_a20
      , p11_a21
      , p11_a22
      , p11_a23
      , p11_a24
      , p11_a25
      , p11_a26
      , p11_a27
      , p11_a28
      );

    okl_etv_pvt_w.rosetta_table_copy_out_p1(ddx_etv_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      , p12_a9
      , p12_a10
      , p12_a11
      , p12_a12
      , p12_a13
      , p12_a14
      , p12_a15
      , p12_a16
      , p12_a17
      , p12_a18
      , p12_a19
      , p12_a20
      , p12_a21
      , p12_a22
      , p12_a23
      , p12_a24
      , p12_a25
      );
  end;

  procedure update_end_of_term_option(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  DATE
    , p5_a4  DATE
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  VARCHAR2
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
    , p5_a23  NUMBER
    , p5_a24  DATE
    , p5_a25  NUMBER
    , p5_a26  DATE
    , p5_a27  NUMBER
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_VARCHAR2_TABLE_100
    , p6_a9 JTF_VARCHAR2_TABLE_500
    , p6_a10 JTF_VARCHAR2_TABLE_500
    , p6_a11 JTF_VARCHAR2_TABLE_500
    , p6_a12 JTF_VARCHAR2_TABLE_500
    , p6_a13 JTF_VARCHAR2_TABLE_500
    , p6_a14 JTF_VARCHAR2_TABLE_500
    , p6_a15 JTF_VARCHAR2_TABLE_500
    , p6_a16 JTF_VARCHAR2_TABLE_500
    , p6_a17 JTF_VARCHAR2_TABLE_500
    , p6_a18 JTF_VARCHAR2_TABLE_500
    , p6_a19 JTF_VARCHAR2_TABLE_500
    , p6_a20 JTF_VARCHAR2_TABLE_500
    , p6_a21 JTF_VARCHAR2_TABLE_500
    , p6_a22 JTF_VARCHAR2_TABLE_500
    , p6_a23 JTF_VARCHAR2_TABLE_500
    , p6_a24 JTF_NUMBER_TABLE
    , p6_a25 JTF_DATE_TABLE
    , p6_a26 JTF_NUMBER_TABLE
    , p6_a27 JTF_DATE_TABLE
    , p6_a28 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_VARCHAR2_TABLE_100
    , p7_a6 JTF_VARCHAR2_TABLE_500
    , p7_a7 JTF_VARCHAR2_TABLE_500
    , p7_a8 JTF_VARCHAR2_TABLE_500
    , p7_a9 JTF_VARCHAR2_TABLE_500
    , p7_a10 JTF_VARCHAR2_TABLE_500
    , p7_a11 JTF_VARCHAR2_TABLE_500
    , p7_a12 JTF_VARCHAR2_TABLE_500
    , p7_a13 JTF_VARCHAR2_TABLE_500
    , p7_a14 JTF_VARCHAR2_TABLE_500
    , p7_a15 JTF_VARCHAR2_TABLE_500
    , p7_a16 JTF_VARCHAR2_TABLE_500
    , p7_a17 JTF_VARCHAR2_TABLE_500
    , p7_a18 JTF_VARCHAR2_TABLE_500
    , p7_a19 JTF_VARCHAR2_TABLE_500
    , p7_a20 JTF_VARCHAR2_TABLE_500
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_DATE_TABLE
    , p7_a23 JTF_NUMBER_TABLE
    , p7_a24 JTF_DATE_TABLE
    , p7_a25 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  DATE
    , p8_a4 out nocopy  DATE
    , p8_a5 out nocopy  VARCHAR2
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  VARCHAR2
    , p8_a13 out nocopy  VARCHAR2
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  VARCHAR2
    , p8_a17 out nocopy  VARCHAR2
    , p8_a18 out nocopy  VARCHAR2
    , p8_a19 out nocopy  VARCHAR2
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  NUMBER
    , p8_a24 out nocopy  DATE
    , p8_a25 out nocopy  NUMBER
    , p8_a26 out nocopy  DATE
    , p8_a27 out nocopy  NUMBER
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_NUMBER_TABLE
    , p9_a7 out nocopy JTF_NUMBER_TABLE
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a24 out nocopy JTF_NUMBER_TABLE
    , p9_a25 out nocopy JTF_DATE_TABLE
    , p9_a26 out nocopy JTF_NUMBER_TABLE
    , p9_a27 out nocopy JTF_DATE_TABLE
    , p9_a28 out nocopy JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a21 out nocopy JTF_NUMBER_TABLE
    , p10_a22 out nocopy JTF_DATE_TABLE
    , p10_a23 out nocopy JTF_NUMBER_TABLE
    , p10_a24 out nocopy JTF_DATE_TABLE
    , p10_a25 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_eve_rec okl_fe_eo_term_options_pvt.okl_eve_rec;
    ddp_eto_tbl okl_fe_eo_term_options_pvt.okl_eto_tbl;
    ddp_etv_tbl okl_fe_eo_term_options_pvt.okl_etv_tbl;
    ddx_eve_rec okl_fe_eo_term_options_pvt.okl_eve_rec;
    ddx_eto_tbl okl_fe_eo_term_options_pvt.okl_eto_tbl;
    ddx_etv_tbl okl_fe_eo_term_options_pvt.okl_etv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_eve_rec.end_of_term_ver_id := p5_a0;
    ddp_eve_rec.object_version_number := p5_a1;
    ddp_eve_rec.version_number := p5_a2;
    ddp_eve_rec.effective_from_date := p5_a3;
    ddp_eve_rec.effective_to_date := p5_a4;
    ddp_eve_rec.sts_code := p5_a5;
    ddp_eve_rec.end_of_term_id := p5_a6;
    ddp_eve_rec.attribute_category := p5_a7;
    ddp_eve_rec.attribute1 := p5_a8;
    ddp_eve_rec.attribute2 := p5_a9;
    ddp_eve_rec.attribute3 := p5_a10;
    ddp_eve_rec.attribute4 := p5_a11;
    ddp_eve_rec.attribute5 := p5_a12;
    ddp_eve_rec.attribute6 := p5_a13;
    ddp_eve_rec.attribute7 := p5_a14;
    ddp_eve_rec.attribute8 := p5_a15;
    ddp_eve_rec.attribute9 := p5_a16;
    ddp_eve_rec.attribute10 := p5_a17;
    ddp_eve_rec.attribute11 := p5_a18;
    ddp_eve_rec.attribute12 := p5_a19;
    ddp_eve_rec.attribute13 := p5_a20;
    ddp_eve_rec.attribute14 := p5_a21;
    ddp_eve_rec.attribute15 := p5_a22;
    ddp_eve_rec.created_by := p5_a23;
    ddp_eve_rec.creation_date := p5_a24;
    ddp_eve_rec.last_updated_by := p5_a25;
    ddp_eve_rec.last_update_date := p5_a26;
    ddp_eve_rec.last_update_login := p5_a27;

    okl_eto_pvt_w.rosetta_table_copy_in_p1(ddp_eto_tbl, p6_a0
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

    okl_etv_pvt_w.rosetta_table_copy_in_p1(ddp_etv_tbl, p7_a0
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
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_fe_eo_term_options_pvt.update_end_of_term_option(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_eve_rec,
      ddp_eto_tbl,
      ddp_etv_tbl,
      ddx_eve_rec,
      ddx_eto_tbl,
      ddx_etv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddx_eve_rec.end_of_term_ver_id;
    p8_a1 := ddx_eve_rec.object_version_number;
    p8_a2 := ddx_eve_rec.version_number;
    p8_a3 := ddx_eve_rec.effective_from_date;
    p8_a4 := ddx_eve_rec.effective_to_date;
    p8_a5 := ddx_eve_rec.sts_code;
    p8_a6 := ddx_eve_rec.end_of_term_id;
    p8_a7 := ddx_eve_rec.attribute_category;
    p8_a8 := ddx_eve_rec.attribute1;
    p8_a9 := ddx_eve_rec.attribute2;
    p8_a10 := ddx_eve_rec.attribute3;
    p8_a11 := ddx_eve_rec.attribute4;
    p8_a12 := ddx_eve_rec.attribute5;
    p8_a13 := ddx_eve_rec.attribute6;
    p8_a14 := ddx_eve_rec.attribute7;
    p8_a15 := ddx_eve_rec.attribute8;
    p8_a16 := ddx_eve_rec.attribute9;
    p8_a17 := ddx_eve_rec.attribute10;
    p8_a18 := ddx_eve_rec.attribute11;
    p8_a19 := ddx_eve_rec.attribute12;
    p8_a20 := ddx_eve_rec.attribute13;
    p8_a21 := ddx_eve_rec.attribute14;
    p8_a22 := ddx_eve_rec.attribute15;
    p8_a23 := ddx_eve_rec.created_by;
    p8_a24 := ddx_eve_rec.creation_date;
    p8_a25 := ddx_eve_rec.last_updated_by;
    p8_a26 := ddx_eve_rec.last_update_date;
    p8_a27 := ddx_eve_rec.last_update_login;

    okl_eto_pvt_w.rosetta_table_copy_out_p1(ddx_eto_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      , p9_a26
      , p9_a27
      , p9_a28
      );

    okl_etv_pvt_w.rosetta_table_copy_out_p1(ddx_etv_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      , p10_a13
      , p10_a14
      , p10_a15
      , p10_a16
      , p10_a17
      , p10_a18
      , p10_a19
      , p10_a20
      , p10_a21
      , p10_a22
      , p10_a23
      , p10_a24
      , p10_a25
      );
  end;

  procedure create_version(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  DATE
    , p5_a4  DATE
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  VARCHAR2
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
    , p5_a23  NUMBER
    , p5_a24  DATE
    , p5_a25  NUMBER
    , p5_a26  DATE
    , p5_a27  NUMBER
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_VARCHAR2_TABLE_100
    , p6_a9 JTF_VARCHAR2_TABLE_500
    , p6_a10 JTF_VARCHAR2_TABLE_500
    , p6_a11 JTF_VARCHAR2_TABLE_500
    , p6_a12 JTF_VARCHAR2_TABLE_500
    , p6_a13 JTF_VARCHAR2_TABLE_500
    , p6_a14 JTF_VARCHAR2_TABLE_500
    , p6_a15 JTF_VARCHAR2_TABLE_500
    , p6_a16 JTF_VARCHAR2_TABLE_500
    , p6_a17 JTF_VARCHAR2_TABLE_500
    , p6_a18 JTF_VARCHAR2_TABLE_500
    , p6_a19 JTF_VARCHAR2_TABLE_500
    , p6_a20 JTF_VARCHAR2_TABLE_500
    , p6_a21 JTF_VARCHAR2_TABLE_500
    , p6_a22 JTF_VARCHAR2_TABLE_500
    , p6_a23 JTF_VARCHAR2_TABLE_500
    , p6_a24 JTF_NUMBER_TABLE
    , p6_a25 JTF_DATE_TABLE
    , p6_a26 JTF_NUMBER_TABLE
    , p6_a27 JTF_DATE_TABLE
    , p6_a28 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_VARCHAR2_TABLE_100
    , p7_a6 JTF_VARCHAR2_TABLE_500
    , p7_a7 JTF_VARCHAR2_TABLE_500
    , p7_a8 JTF_VARCHAR2_TABLE_500
    , p7_a9 JTF_VARCHAR2_TABLE_500
    , p7_a10 JTF_VARCHAR2_TABLE_500
    , p7_a11 JTF_VARCHAR2_TABLE_500
    , p7_a12 JTF_VARCHAR2_TABLE_500
    , p7_a13 JTF_VARCHAR2_TABLE_500
    , p7_a14 JTF_VARCHAR2_TABLE_500
    , p7_a15 JTF_VARCHAR2_TABLE_500
    , p7_a16 JTF_VARCHAR2_TABLE_500
    , p7_a17 JTF_VARCHAR2_TABLE_500
    , p7_a18 JTF_VARCHAR2_TABLE_500
    , p7_a19 JTF_VARCHAR2_TABLE_500
    , p7_a20 JTF_VARCHAR2_TABLE_500
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_DATE_TABLE
    , p7_a23 JTF_NUMBER_TABLE
    , p7_a24 JTF_DATE_TABLE
    , p7_a25 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  DATE
    , p8_a4 out nocopy  DATE
    , p8_a5 out nocopy  VARCHAR2
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  VARCHAR2
    , p8_a13 out nocopy  VARCHAR2
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  VARCHAR2
    , p8_a17 out nocopy  VARCHAR2
    , p8_a18 out nocopy  VARCHAR2
    , p8_a19 out nocopy  VARCHAR2
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  NUMBER
    , p8_a24 out nocopy  DATE
    , p8_a25 out nocopy  NUMBER
    , p8_a26 out nocopy  DATE
    , p8_a27 out nocopy  NUMBER
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_NUMBER_TABLE
    , p9_a7 out nocopy JTF_NUMBER_TABLE
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a24 out nocopy JTF_NUMBER_TABLE
    , p9_a25 out nocopy JTF_DATE_TABLE
    , p9_a26 out nocopy JTF_NUMBER_TABLE
    , p9_a27 out nocopy JTF_DATE_TABLE
    , p9_a28 out nocopy JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a21 out nocopy JTF_NUMBER_TABLE
    , p10_a22 out nocopy JTF_DATE_TABLE
    , p10_a23 out nocopy JTF_NUMBER_TABLE
    , p10_a24 out nocopy JTF_DATE_TABLE
    , p10_a25 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_eve_rec okl_fe_eo_term_options_pvt.okl_eve_rec;
    ddp_eto_tbl okl_fe_eo_term_options_pvt.okl_eto_tbl;
    ddp_etv_tbl okl_fe_eo_term_options_pvt.okl_etv_tbl;
    ddx_eve_rec okl_fe_eo_term_options_pvt.okl_eve_rec;
    ddx_eto_tbl okl_fe_eo_term_options_pvt.okl_eto_tbl;
    ddx_etv_tbl okl_fe_eo_term_options_pvt.okl_etv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_eve_rec.end_of_term_ver_id := p5_a0;
    ddp_eve_rec.object_version_number := p5_a1;
    ddp_eve_rec.version_number := p5_a2;
    ddp_eve_rec.effective_from_date := p5_a3;
    ddp_eve_rec.effective_to_date := p5_a4;
    ddp_eve_rec.sts_code := p5_a5;
    ddp_eve_rec.end_of_term_id := p5_a6;
    ddp_eve_rec.attribute_category := p5_a7;
    ddp_eve_rec.attribute1 := p5_a8;
    ddp_eve_rec.attribute2 := p5_a9;
    ddp_eve_rec.attribute3 := p5_a10;
    ddp_eve_rec.attribute4 := p5_a11;
    ddp_eve_rec.attribute5 := p5_a12;
    ddp_eve_rec.attribute6 := p5_a13;
    ddp_eve_rec.attribute7 := p5_a14;
    ddp_eve_rec.attribute8 := p5_a15;
    ddp_eve_rec.attribute9 := p5_a16;
    ddp_eve_rec.attribute10 := p5_a17;
    ddp_eve_rec.attribute11 := p5_a18;
    ddp_eve_rec.attribute12 := p5_a19;
    ddp_eve_rec.attribute13 := p5_a20;
    ddp_eve_rec.attribute14 := p5_a21;
    ddp_eve_rec.attribute15 := p5_a22;
    ddp_eve_rec.created_by := p5_a23;
    ddp_eve_rec.creation_date := p5_a24;
    ddp_eve_rec.last_updated_by := p5_a25;
    ddp_eve_rec.last_update_date := p5_a26;
    ddp_eve_rec.last_update_login := p5_a27;

    okl_eto_pvt_w.rosetta_table_copy_in_p1(ddp_eto_tbl, p6_a0
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

    okl_etv_pvt_w.rosetta_table_copy_in_p1(ddp_etv_tbl, p7_a0
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
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_fe_eo_term_options_pvt.create_version(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_eve_rec,
      ddp_eto_tbl,
      ddp_etv_tbl,
      ddx_eve_rec,
      ddx_eto_tbl,
      ddx_etv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddx_eve_rec.end_of_term_ver_id;
    p8_a1 := ddx_eve_rec.object_version_number;
    p8_a2 := ddx_eve_rec.version_number;
    p8_a3 := ddx_eve_rec.effective_from_date;
    p8_a4 := ddx_eve_rec.effective_to_date;
    p8_a5 := ddx_eve_rec.sts_code;
    p8_a6 := ddx_eve_rec.end_of_term_id;
    p8_a7 := ddx_eve_rec.attribute_category;
    p8_a8 := ddx_eve_rec.attribute1;
    p8_a9 := ddx_eve_rec.attribute2;
    p8_a10 := ddx_eve_rec.attribute3;
    p8_a11 := ddx_eve_rec.attribute4;
    p8_a12 := ddx_eve_rec.attribute5;
    p8_a13 := ddx_eve_rec.attribute6;
    p8_a14 := ddx_eve_rec.attribute7;
    p8_a15 := ddx_eve_rec.attribute8;
    p8_a16 := ddx_eve_rec.attribute9;
    p8_a17 := ddx_eve_rec.attribute10;
    p8_a18 := ddx_eve_rec.attribute11;
    p8_a19 := ddx_eve_rec.attribute12;
    p8_a20 := ddx_eve_rec.attribute13;
    p8_a21 := ddx_eve_rec.attribute14;
    p8_a22 := ddx_eve_rec.attribute15;
    p8_a23 := ddx_eve_rec.created_by;
    p8_a24 := ddx_eve_rec.creation_date;
    p8_a25 := ddx_eve_rec.last_updated_by;
    p8_a26 := ddx_eve_rec.last_update_date;
    p8_a27 := ddx_eve_rec.last_update_login;

    okl_eto_pvt_w.rosetta_table_copy_out_p1(ddx_eto_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      , p9_a26
      , p9_a27
      , p9_a28
      );

    okl_etv_pvt_w.rosetta_table_copy_out_p1(ddx_etv_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      , p10_a13
      , p10_a14
      , p10_a15
      , p10_a16
      , p10_a17
      , p10_a18
      , p10_a19
      , p10_a20
      , p10_a21
      , p10_a22
      , p10_a23
      , p10_a24
      , p10_a25
      );
  end;

  procedure invalid_objects(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_version_id  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_obj_tbl okl_fe_eo_term_options_pvt.invalid_object_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okl_fe_eo_term_options_pvt.invalid_objects(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_version_id,
      ddx_obj_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_fe_eo_term_options_pvt_w.rosetta_table_copy_out_p9(ddx_obj_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      );
  end;

  procedure calculate_start_date(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  DATE
    , p5_a4  DATE
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  VARCHAR2
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
    , p5_a23  NUMBER
    , p5_a24  DATE
    , p5_a25  NUMBER
    , p5_a26  DATE
    , p5_a27  NUMBER
    , x_cal_eff_from out nocopy  DATE
  )

  as
    ddp_eve_rec okl_fe_eo_term_options_pvt.okl_eve_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_eve_rec.end_of_term_ver_id := p5_a0;
    ddp_eve_rec.object_version_number := p5_a1;
    ddp_eve_rec.version_number := p5_a2;
    ddp_eve_rec.effective_from_date := p5_a3;
    ddp_eve_rec.effective_to_date := p5_a4;
    ddp_eve_rec.sts_code := p5_a5;
    ddp_eve_rec.end_of_term_id := p5_a6;
    ddp_eve_rec.attribute_category := p5_a7;
    ddp_eve_rec.attribute1 := p5_a8;
    ddp_eve_rec.attribute2 := p5_a9;
    ddp_eve_rec.attribute3 := p5_a10;
    ddp_eve_rec.attribute4 := p5_a11;
    ddp_eve_rec.attribute5 := p5_a12;
    ddp_eve_rec.attribute6 := p5_a13;
    ddp_eve_rec.attribute7 := p5_a14;
    ddp_eve_rec.attribute8 := p5_a15;
    ddp_eve_rec.attribute9 := p5_a16;
    ddp_eve_rec.attribute10 := p5_a17;
    ddp_eve_rec.attribute11 := p5_a18;
    ddp_eve_rec.attribute12 := p5_a19;
    ddp_eve_rec.attribute13 := p5_a20;
    ddp_eve_rec.attribute14 := p5_a21;
    ddp_eve_rec.attribute15 := p5_a22;
    ddp_eve_rec.created_by := p5_a23;
    ddp_eve_rec.creation_date := p5_a24;
    ddp_eve_rec.last_updated_by := p5_a25;
    ddp_eve_rec.last_update_date := p5_a26;
    ddp_eve_rec.last_update_login := p5_a27;


    -- here's the delegated call to the old PL/SQL routine
    okl_fe_eo_term_options_pvt.calculate_start_date(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_eve_rec,
      x_cal_eff_from);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end okl_fe_eo_term_options_pvt_w;

/
