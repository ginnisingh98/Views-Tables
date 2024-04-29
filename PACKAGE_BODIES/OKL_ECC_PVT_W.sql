--------------------------------------------------------
--  DDL for Package Body OKL_ECC_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ECC_PVT_W" as
  /* $Header: OKLIECCB.pls 120.1 2005/10/30 04:58:33 appldev noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy okl_ecc_pvt.okl_eccv_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_2000
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_2000
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).crit_cat_def_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).ecc_ac_flag := a2(indx);
          t(ddindx).orig_crit_cat_def_id := a3(indx);
          t(ddindx).crit_cat_name := a4(indx);
          t(ddindx).crit_cat_desc := a5(indx);
          t(ddindx).sfwt_flag := a6(indx);
          t(ddindx).value_type_code := a7(indx);
          t(ddindx).data_type_code := a8(indx);
          t(ddindx).enabled_yn := a9(indx);
          t(ddindx).seeded_yn := a10(indx);
          t(ddindx).function_id := a11(indx);
          t(ddindx).source_yn := a12(indx);
          t(ddindx).sql_statement := a13(indx);
          t(ddindx).created_by := a14(indx);
          t(ddindx).creation_date := a15(indx);
          t(ddindx).last_updated_by := a16(indx);
          t(ddindx).last_update_date := a17(indx);
          t(ddindx).last_update_login := a18(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t okl_ecc_pvt.okl_eccv_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_2000();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_2000();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_2000();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_2000();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).crit_cat_def_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).ecc_ac_flag;
          a3(indx) := t(ddindx).orig_crit_cat_def_id;
          a4(indx) := t(ddindx).crit_cat_name;
          a5(indx) := t(ddindx).crit_cat_desc;
          a6(indx) := t(ddindx).sfwt_flag;
          a7(indx) := t(ddindx).value_type_code;
          a8(indx) := t(ddindx).data_type_code;
          a9(indx) := t(ddindx).enabled_yn;
          a10(indx) := t(ddindx).seeded_yn;
          a11(indx) := t(ddindx).function_id;
          a12(indx) := t(ddindx).source_yn;
          a13(indx) := t(ddindx).sql_statement;
          a14(indx) := t(ddindx).created_by;
          a15(indx) := t(ddindx).creation_date;
          a16(indx) := t(ddindx).last_updated_by;
          a17(indx) := t(ddindx).last_update_date;
          a18(indx) := t(ddindx).last_update_login;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy okl_ecc_pvt.okl_eccb_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_2000
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).crit_cat_def_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).crit_cat_name := a2(indx);
          t(ddindx).ecc_ac_flag := a3(indx);
          t(ddindx).orig_crit_cat_def_id := a4(indx);
          t(ddindx).value_type_code := a5(indx);
          t(ddindx).data_type_code := a6(indx);
          t(ddindx).enabled_yn := a7(indx);
          t(ddindx).seeded_yn := a8(indx);
          t(ddindx).function_id := a9(indx);
          t(ddindx).source_yn := a10(indx);
          t(ddindx).sql_statement := a11(indx);
          t(ddindx).created_by := a12(indx);
          t(ddindx).creation_date := a13(indx);
          t(ddindx).last_updated_by := a14(indx);
          t(ddindx).last_update_date := a15(indx);
          t(ddindx).last_update_login := a16(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t okl_ecc_pvt.okl_eccb_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_2000
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_2000();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_2000();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).crit_cat_def_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).crit_cat_name;
          a3(indx) := t(ddindx).ecc_ac_flag;
          a4(indx) := t(ddindx).orig_crit_cat_def_id;
          a5(indx) := t(ddindx).value_type_code;
          a6(indx) := t(ddindx).data_type_code;
          a7(indx) := t(ddindx).enabled_yn;
          a8(indx) := t(ddindx).seeded_yn;
          a9(indx) := t(ddindx).function_id;
          a10(indx) := t(ddindx).source_yn;
          a11(indx) := t(ddindx).sql_statement;
          a12(indx) := t(ddindx).created_by;
          a13(indx) := t(ddindx).creation_date;
          a14(indx) := t(ddindx).last_updated_by;
          a15(indx) := t(ddindx).last_update_date;
          a16(indx) := t(ddindx).last_update_login;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_ecc_pvt.okl_ecctl_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_2000
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
          t(ddindx).crit_cat_def_id := a0(indx);
          t(ddindx).language := a1(indx);
          t(ddindx).source_lang := a2(indx);
          t(ddindx).sfwt_flag := a3(indx);
          t(ddindx).crit_cat_desc := a4(indx);
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
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_ecc_pvt.okl_ecctl_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
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
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_2000();
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
          a0(indx) := t(ddindx).crit_cat_def_id;
          a1(indx) := t(ddindx).language;
          a2(indx) := t(ddindx).source_lang;
          a3(indx) := t(ddindx).sfwt_flag;
          a4(indx) := t(ddindx).crit_cat_desc;
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
  end rosetta_table_copy_out_p5;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  NUMBER
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  NUMBER
    , p5_a15  DATE
    , p5_a16  NUMBER
    , p5_a17  DATE
    , p5_a18  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  DATE
    , p6_a18 out nocopy  NUMBER
  )

  as
    ddp_eccv_rec okl_ecc_pvt.okl_eccv_rec;
    ddx_eccv_rec okl_ecc_pvt.okl_eccv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_eccv_rec.crit_cat_def_id := p5_a0;
    ddp_eccv_rec.object_version_number := p5_a1;
    ddp_eccv_rec.ecc_ac_flag := p5_a2;
    ddp_eccv_rec.orig_crit_cat_def_id := p5_a3;
    ddp_eccv_rec.crit_cat_name := p5_a4;
    ddp_eccv_rec.crit_cat_desc := p5_a5;
    ddp_eccv_rec.sfwt_flag := p5_a6;
    ddp_eccv_rec.value_type_code := p5_a7;
    ddp_eccv_rec.data_type_code := p5_a8;
    ddp_eccv_rec.enabled_yn := p5_a9;
    ddp_eccv_rec.seeded_yn := p5_a10;
    ddp_eccv_rec.function_id := p5_a11;
    ddp_eccv_rec.source_yn := p5_a12;
    ddp_eccv_rec.sql_statement := p5_a13;
    ddp_eccv_rec.created_by := p5_a14;
    ddp_eccv_rec.creation_date := p5_a15;
    ddp_eccv_rec.last_updated_by := p5_a16;
    ddp_eccv_rec.last_update_date := p5_a17;
    ddp_eccv_rec.last_update_login := p5_a18;


    -- here's the delegated call to the old PL/SQL routine
    okl_ecc_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_eccv_rec,
      ddx_eccv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_eccv_rec.crit_cat_def_id;
    p6_a1 := ddx_eccv_rec.object_version_number;
    p6_a2 := ddx_eccv_rec.ecc_ac_flag;
    p6_a3 := ddx_eccv_rec.orig_crit_cat_def_id;
    p6_a4 := ddx_eccv_rec.crit_cat_name;
    p6_a5 := ddx_eccv_rec.crit_cat_desc;
    p6_a6 := ddx_eccv_rec.sfwt_flag;
    p6_a7 := ddx_eccv_rec.value_type_code;
    p6_a8 := ddx_eccv_rec.data_type_code;
    p6_a9 := ddx_eccv_rec.enabled_yn;
    p6_a10 := ddx_eccv_rec.seeded_yn;
    p6_a11 := ddx_eccv_rec.function_id;
    p6_a12 := ddx_eccv_rec.source_yn;
    p6_a13 := ddx_eccv_rec.sql_statement;
    p6_a14 := ddx_eccv_rec.created_by;
    p6_a15 := ddx_eccv_rec.creation_date;
    p6_a16 := ddx_eccv_rec.last_updated_by;
    p6_a17 := ddx_eccv_rec.last_update_date;
    p6_a18 := ddx_eccv_rec.last_update_login;
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_300
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_2000
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_DATE_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_DATE_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_DATE_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_eccv_tbl okl_ecc_pvt.okl_eccv_tbl;
    ddx_eccv_tbl okl_ecc_pvt.okl_eccv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ecc_pvt_w.rosetta_table_copy_in_p1(ddp_eccv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_ecc_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_eccv_tbl,
      ddx_eccv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_ecc_pvt_w.rosetta_table_copy_out_p1(ddx_eccv_tbl, p6_a0
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
      );
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  NUMBER
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  NUMBER
    , p5_a15  DATE
    , p5_a16  NUMBER
    , p5_a17  DATE
    , p5_a18  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  DATE
    , p6_a18 out nocopy  NUMBER
  )

  as
    ddp_eccv_rec okl_ecc_pvt.okl_eccv_rec;
    ddx_eccv_rec okl_ecc_pvt.okl_eccv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_eccv_rec.crit_cat_def_id := p5_a0;
    ddp_eccv_rec.object_version_number := p5_a1;
    ddp_eccv_rec.ecc_ac_flag := p5_a2;
    ddp_eccv_rec.orig_crit_cat_def_id := p5_a3;
    ddp_eccv_rec.crit_cat_name := p5_a4;
    ddp_eccv_rec.crit_cat_desc := p5_a5;
    ddp_eccv_rec.sfwt_flag := p5_a6;
    ddp_eccv_rec.value_type_code := p5_a7;
    ddp_eccv_rec.data_type_code := p5_a8;
    ddp_eccv_rec.enabled_yn := p5_a9;
    ddp_eccv_rec.seeded_yn := p5_a10;
    ddp_eccv_rec.function_id := p5_a11;
    ddp_eccv_rec.source_yn := p5_a12;
    ddp_eccv_rec.sql_statement := p5_a13;
    ddp_eccv_rec.created_by := p5_a14;
    ddp_eccv_rec.creation_date := p5_a15;
    ddp_eccv_rec.last_updated_by := p5_a16;
    ddp_eccv_rec.last_update_date := p5_a17;
    ddp_eccv_rec.last_update_login := p5_a18;


    -- here's the delegated call to the old PL/SQL routine
    okl_ecc_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_eccv_rec,
      ddx_eccv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_eccv_rec.crit_cat_def_id;
    p6_a1 := ddx_eccv_rec.object_version_number;
    p6_a2 := ddx_eccv_rec.ecc_ac_flag;
    p6_a3 := ddx_eccv_rec.orig_crit_cat_def_id;
    p6_a4 := ddx_eccv_rec.crit_cat_name;
    p6_a5 := ddx_eccv_rec.crit_cat_desc;
    p6_a6 := ddx_eccv_rec.sfwt_flag;
    p6_a7 := ddx_eccv_rec.value_type_code;
    p6_a8 := ddx_eccv_rec.data_type_code;
    p6_a9 := ddx_eccv_rec.enabled_yn;
    p6_a10 := ddx_eccv_rec.seeded_yn;
    p6_a11 := ddx_eccv_rec.function_id;
    p6_a12 := ddx_eccv_rec.source_yn;
    p6_a13 := ddx_eccv_rec.sql_statement;
    p6_a14 := ddx_eccv_rec.created_by;
    p6_a15 := ddx_eccv_rec.creation_date;
    p6_a16 := ddx_eccv_rec.last_updated_by;
    p6_a17 := ddx_eccv_rec.last_update_date;
    p6_a18 := ddx_eccv_rec.last_update_login;
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_300
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_2000
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_DATE_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_DATE_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_DATE_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_eccv_tbl okl_ecc_pvt.okl_eccv_tbl;
    ddx_eccv_tbl okl_ecc_pvt.okl_eccv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ecc_pvt_w.rosetta_table_copy_in_p1(ddp_eccv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_ecc_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_eccv_tbl,
      ddx_eccv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_ecc_pvt_w.rosetta_table_copy_out_p1(ddx_eccv_tbl, p6_a0
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
      );
  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  NUMBER
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  NUMBER
    , p5_a15  DATE
    , p5_a16  NUMBER
    , p5_a17  DATE
    , p5_a18  NUMBER
  )

  as
    ddp_eccv_rec okl_ecc_pvt.okl_eccv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_eccv_rec.crit_cat_def_id := p5_a0;
    ddp_eccv_rec.object_version_number := p5_a1;
    ddp_eccv_rec.ecc_ac_flag := p5_a2;
    ddp_eccv_rec.orig_crit_cat_def_id := p5_a3;
    ddp_eccv_rec.crit_cat_name := p5_a4;
    ddp_eccv_rec.crit_cat_desc := p5_a5;
    ddp_eccv_rec.sfwt_flag := p5_a6;
    ddp_eccv_rec.value_type_code := p5_a7;
    ddp_eccv_rec.data_type_code := p5_a8;
    ddp_eccv_rec.enabled_yn := p5_a9;
    ddp_eccv_rec.seeded_yn := p5_a10;
    ddp_eccv_rec.function_id := p5_a11;
    ddp_eccv_rec.source_yn := p5_a12;
    ddp_eccv_rec.sql_statement := p5_a13;
    ddp_eccv_rec.created_by := p5_a14;
    ddp_eccv_rec.creation_date := p5_a15;
    ddp_eccv_rec.last_updated_by := p5_a16;
    ddp_eccv_rec.last_update_date := p5_a17;
    ddp_eccv_rec.last_update_login := p5_a18;

    -- here's the delegated call to the old PL/SQL routine
    okl_ecc_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_eccv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_300
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_2000
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_DATE_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_NUMBER_TABLE
  )

  as
    ddp_eccv_tbl okl_ecc_pvt.okl_eccv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ecc_pvt_w.rosetta_table_copy_in_p1(ddp_eccv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_ecc_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_eccv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_ecc_pvt_w;

/
