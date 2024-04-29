--------------------------------------------------------
--  DDL for Package Body OKL_OKC_MIGRATION_A_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_OKC_MIGRATION_A_PVT_W" as
  /* $Header: OKLEOMAB.pls 120.4 2005/08/04 03:17:32 manumanu noship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy okl_okc_migration_a_pvt.catv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_2000
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_100
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
    , a26 JTF_VARCHAR2_TABLE_500
    , a27 JTF_VARCHAR2_TABLE_500
    , a28 JTF_VARCHAR2_TABLE_500
    , a29 JTF_VARCHAR2_TABLE_500
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_DATE_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_DATE_TABLE
    , a35 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := a0(indx);
          t(ddindx).chr_id := a1(indx);
          t(ddindx).cle_id := a2(indx);
          t(ddindx).cat_id := a3(indx);
          t(ddindx).object_version_number := a4(indx);
          t(ddindx).sfwt_flag := a5(indx);
          t(ddindx).sav_sae_id := a6(indx);
          t(ddindx).sav_sav_release := a7(indx);
          t(ddindx).sbt_code := a8(indx);
          t(ddindx).dnz_chr_id := a9(indx);
          t(ddindx).comments := a10(indx);
          t(ddindx).fulltext_yn := a11(indx);
          t(ddindx).variation_description := a12(indx);
          t(ddindx).name := a13(indx);
          t(ddindx).attribute_category := a14(indx);
          t(ddindx).attribute1 := a15(indx);
          t(ddindx).attribute2 := a16(indx);
          t(ddindx).attribute3 := a17(indx);
          t(ddindx).attribute4 := a18(indx);
          t(ddindx).attribute5 := a19(indx);
          t(ddindx).attribute6 := a20(indx);
          t(ddindx).attribute7 := a21(indx);
          t(ddindx).attribute8 := a22(indx);
          t(ddindx).attribute9 := a23(indx);
          t(ddindx).attribute10 := a24(indx);
          t(ddindx).attribute11 := a25(indx);
          t(ddindx).attribute12 := a26(indx);
          t(ddindx).attribute13 := a27(indx);
          t(ddindx).attribute14 := a28(indx);
          t(ddindx).attribute15 := a29(indx);
          t(ddindx).cat_type := a30(indx);
          t(ddindx).created_by := a31(indx);
          t(ddindx).creation_date := a32(indx);
          t(ddindx).last_updated_by := a33(indx);
          t(ddindx).last_update_date := a34(indx);
          t(ddindx).last_update_login := a35(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t okl_okc_migration_a_pvt.catv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_300
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a26 out nocopy JTF_VARCHAR2_TABLE_500
    , a27 out nocopy JTF_VARCHAR2_TABLE_500
    , a28 out nocopy JTF_VARCHAR2_TABLE_500
    , a29 out nocopy JTF_VARCHAR2_TABLE_500
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_DATE_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_DATE_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_2000();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_300();
    a13 := JTF_VARCHAR2_TABLE_200();
    a14 := JTF_VARCHAR2_TABLE_100();
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
    a26 := JTF_VARCHAR2_TABLE_500();
    a27 := JTF_VARCHAR2_TABLE_500();
    a28 := JTF_VARCHAR2_TABLE_500();
    a29 := JTF_VARCHAR2_TABLE_500();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_DATE_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_DATE_TABLE();
    a35 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_2000();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_300();
      a13 := JTF_VARCHAR2_TABLE_200();
      a14 := JTF_VARCHAR2_TABLE_100();
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
      a26 := JTF_VARCHAR2_TABLE_500();
      a27 := JTF_VARCHAR2_TABLE_500();
      a28 := JTF_VARCHAR2_TABLE_500();
      a29 := JTF_VARCHAR2_TABLE_500();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_DATE_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_DATE_TABLE();
      a35 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id;
          a1(indx) := t(ddindx).chr_id;
          a2(indx) := t(ddindx).cle_id;
          a3(indx) := t(ddindx).cat_id;
          a4(indx) := t(ddindx).object_version_number;
          a5(indx) := t(ddindx).sfwt_flag;
          a6(indx) := t(ddindx).sav_sae_id;
          a7(indx) := t(ddindx).sav_sav_release;
          a8(indx) := t(ddindx).sbt_code;
          a9(indx) := t(ddindx).dnz_chr_id;
          a10(indx) := t(ddindx).comments;
          a11(indx) := t(ddindx).fulltext_yn;
          a12(indx) := t(ddindx).variation_description;
          a13(indx) := t(ddindx).name;
          a14(indx) := t(ddindx).attribute_category;
          a15(indx) := t(ddindx).attribute1;
          a16(indx) := t(ddindx).attribute2;
          a17(indx) := t(ddindx).attribute3;
          a18(indx) := t(ddindx).attribute4;
          a19(indx) := t(ddindx).attribute5;
          a20(indx) := t(ddindx).attribute6;
          a21(indx) := t(ddindx).attribute7;
          a22(indx) := t(ddindx).attribute8;
          a23(indx) := t(ddindx).attribute9;
          a24(indx) := t(ddindx).attribute10;
          a25(indx) := t(ddindx).attribute11;
          a26(indx) := t(ddindx).attribute12;
          a27(indx) := t(ddindx).attribute13;
          a28(indx) := t(ddindx).attribute14;
          a29(indx) := t(ddindx).attribute15;
          a30(indx) := t(ddindx).cat_type;
          a31(indx) := t(ddindx).created_by;
          a32(indx) := t(ddindx).creation_date;
          a33(indx) := t(ddindx).last_updated_by;
          a34(indx) := t(ddindx).last_update_date;
          a35(indx) := t(ddindx).last_update_login;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_okc_migration_a_pvt.rgpv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_2000
    , a11 JTF_VARCHAR2_TABLE_100
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
    , a26 JTF_VARCHAR2_TABLE_500
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_DATE_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_DATE_TABLE
    , a31 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).sfwt_flag := a2(indx);
          t(ddindx).rgd_code := a3(indx);
          t(ddindx).sat_code := a4(indx);
          t(ddindx).rgp_type := a5(indx);
          t(ddindx).cle_id := a6(indx);
          t(ddindx).chr_id := a7(indx);
          t(ddindx).dnz_chr_id := a8(indx);
          t(ddindx).parent_rgp_id := a9(indx);
          t(ddindx).comments := a10(indx);
          t(ddindx).attribute_category := a11(indx);
          t(ddindx).attribute1 := a12(indx);
          t(ddindx).attribute2 := a13(indx);
          t(ddindx).attribute3 := a14(indx);
          t(ddindx).attribute4 := a15(indx);
          t(ddindx).attribute5 := a16(indx);
          t(ddindx).attribute6 := a17(indx);
          t(ddindx).attribute7 := a18(indx);
          t(ddindx).attribute8 := a19(indx);
          t(ddindx).attribute9 := a20(indx);
          t(ddindx).attribute10 := a21(indx);
          t(ddindx).attribute11 := a22(indx);
          t(ddindx).attribute12 := a23(indx);
          t(ddindx).attribute13 := a24(indx);
          t(ddindx).attribute14 := a25(indx);
          t(ddindx).attribute15 := a26(indx);
          t(ddindx).created_by := a27(indx);
          t(ddindx).creation_date := a28(indx);
          t(ddindx).last_updated_by := a29(indx);
          t(ddindx).last_update_date := a30(indx);
          t(ddindx).last_update_login := a31(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_okc_migration_a_pvt.rgpv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a26 out nocopy JTF_VARCHAR2_TABLE_500
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_DATE_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_DATE_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_2000();
    a11 := JTF_VARCHAR2_TABLE_100();
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
    a26 := JTF_VARCHAR2_TABLE_500();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_DATE_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_DATE_TABLE();
    a31 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_2000();
      a11 := JTF_VARCHAR2_TABLE_100();
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
      a26 := JTF_VARCHAR2_TABLE_500();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_DATE_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_DATE_TABLE();
      a31 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).sfwt_flag;
          a3(indx) := t(ddindx).rgd_code;
          a4(indx) := t(ddindx).sat_code;
          a5(indx) := t(ddindx).rgp_type;
          a6(indx) := t(ddindx).cle_id;
          a7(indx) := t(ddindx).chr_id;
          a8(indx) := t(ddindx).dnz_chr_id;
          a9(indx) := t(ddindx).parent_rgp_id;
          a10(indx) := t(ddindx).comments;
          a11(indx) := t(ddindx).attribute_category;
          a12(indx) := t(ddindx).attribute1;
          a13(indx) := t(ddindx).attribute2;
          a14(indx) := t(ddindx).attribute3;
          a15(indx) := t(ddindx).attribute4;
          a16(indx) := t(ddindx).attribute5;
          a17(indx) := t(ddindx).attribute6;
          a18(indx) := t(ddindx).attribute7;
          a19(indx) := t(ddindx).attribute8;
          a20(indx) := t(ddindx).attribute9;
          a21(indx) := t(ddindx).attribute10;
          a22(indx) := t(ddindx).attribute11;
          a23(indx) := t(ddindx).attribute12;
          a24(indx) := t(ddindx).attribute13;
          a25(indx) := t(ddindx).attribute14;
          a26(indx) := t(ddindx).attribute15;
          a27(indx) := t(ddindx).created_by;
          a28(indx) := t(ddindx).creation_date;
          a29(indx) := t(ddindx).last_updated_by;
          a30(indx) := t(ddindx).last_update_date;
          a31(indx) := t(ddindx).last_update_login;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p7(t out nocopy okl_okc_migration_a_pvt.qa_msg_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).severity := a0(indx);
          t(ddindx).name := a1(indx);
          t(ddindx).description := a2(indx);
          t(ddindx).package_name := a3(indx);
          t(ddindx).procedure_name := a4(indx);
          t(ddindx).error_status := a5(indx);
          t(ddindx).data := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t okl_okc_migration_a_pvt.qa_msg_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_2000();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_2000();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_2000();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).severity;
          a1(indx) := t(ddindx).name;
          a2(indx) := t(ddindx).description;
          a3(indx) := t(ddindx).package_name;
          a4(indx) := t(ddindx).procedure_name;
          a5(indx) := t(ddindx).error_status;
          a6(indx) := t(ddindx).data;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

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
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  NUMBER
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
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  NUMBER
    , p5_a32  DATE
    , p5_a33  NUMBER
    , p5_a34  DATE
    , p5_a35  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
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
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
  )

  as
    ddp_catv_rec okl_okc_migration_a_pvt.catv_rec_type;
    ddx_catv_rec okl_okc_migration_a_pvt.catv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_catv_rec.id := p5_a0;
    ddp_catv_rec.chr_id := p5_a1;
    ddp_catv_rec.cle_id := p5_a2;
    ddp_catv_rec.cat_id := p5_a3;
    ddp_catv_rec.object_version_number := p5_a4;
    ddp_catv_rec.sfwt_flag := p5_a5;
    ddp_catv_rec.sav_sae_id := p5_a6;
    ddp_catv_rec.sav_sav_release := p5_a7;
    ddp_catv_rec.sbt_code := p5_a8;
    ddp_catv_rec.dnz_chr_id := p5_a9;
    ddp_catv_rec.comments := p5_a10;
    ddp_catv_rec.fulltext_yn := p5_a11;
    ddp_catv_rec.variation_description := p5_a12;
    ddp_catv_rec.name := p5_a13;
    ddp_catv_rec.attribute_category := p5_a14;
    ddp_catv_rec.attribute1 := p5_a15;
    ddp_catv_rec.attribute2 := p5_a16;
    ddp_catv_rec.attribute3 := p5_a17;
    ddp_catv_rec.attribute4 := p5_a18;
    ddp_catv_rec.attribute5 := p5_a19;
    ddp_catv_rec.attribute6 := p5_a20;
    ddp_catv_rec.attribute7 := p5_a21;
    ddp_catv_rec.attribute8 := p5_a22;
    ddp_catv_rec.attribute9 := p5_a23;
    ddp_catv_rec.attribute10 := p5_a24;
    ddp_catv_rec.attribute11 := p5_a25;
    ddp_catv_rec.attribute12 := p5_a26;
    ddp_catv_rec.attribute13 := p5_a27;
    ddp_catv_rec.attribute14 := p5_a28;
    ddp_catv_rec.attribute15 := p5_a29;
    ddp_catv_rec.cat_type := p5_a30;
    ddp_catv_rec.created_by := p5_a31;
    ddp_catv_rec.creation_date := p5_a32;
    ddp_catv_rec.last_updated_by := p5_a33;
    ddp_catv_rec.last_update_date := p5_a34;
    ddp_catv_rec.last_update_login := p5_a35;


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_a_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_catv_rec,
      ddx_catv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_catv_rec.id;
    p6_a1 := ddx_catv_rec.chr_id;
    p6_a2 := ddx_catv_rec.cle_id;
    p6_a3 := ddx_catv_rec.cat_id;
    p6_a4 := ddx_catv_rec.object_version_number;
    p6_a5 := ddx_catv_rec.sfwt_flag;
    p6_a6 := ddx_catv_rec.sav_sae_id;
    p6_a7 := ddx_catv_rec.sav_sav_release;
    p6_a8 := ddx_catv_rec.sbt_code;
    p6_a9 := ddx_catv_rec.dnz_chr_id;
    p6_a10 := ddx_catv_rec.comments;
    p6_a11 := ddx_catv_rec.fulltext_yn;
    p6_a12 := ddx_catv_rec.variation_description;
    p6_a13 := ddx_catv_rec.name;
    p6_a14 := ddx_catv_rec.attribute_category;
    p6_a15 := ddx_catv_rec.attribute1;
    p6_a16 := ddx_catv_rec.attribute2;
    p6_a17 := ddx_catv_rec.attribute3;
    p6_a18 := ddx_catv_rec.attribute4;
    p6_a19 := ddx_catv_rec.attribute5;
    p6_a20 := ddx_catv_rec.attribute6;
    p6_a21 := ddx_catv_rec.attribute7;
    p6_a22 := ddx_catv_rec.attribute8;
    p6_a23 := ddx_catv_rec.attribute9;
    p6_a24 := ddx_catv_rec.attribute10;
    p6_a25 := ddx_catv_rec.attribute11;
    p6_a26 := ddx_catv_rec.attribute12;
    p6_a27 := ddx_catv_rec.attribute13;
    p6_a28 := ddx_catv_rec.attribute14;
    p6_a29 := ddx_catv_rec.attribute15;
    p6_a30 := ddx_catv_rec.cat_type;
    p6_a31 := ddx_catv_rec.created_by;
    p6_a32 := ddx_catv_rec.creation_date;
    p6_a33 := ddx_catv_rec.last_updated_by;
    p6_a34 := ddx_catv_rec.last_update_date;
    p6_a35 := ddx_catv_rec.last_update_login;
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
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  NUMBER
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
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  NUMBER
    , p5_a32  DATE
    , p5_a33  NUMBER
    , p5_a34  DATE
    , p5_a35  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
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
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
  )

  as
    ddp_catv_rec okl_okc_migration_a_pvt.catv_rec_type;
    ddx_catv_rec okl_okc_migration_a_pvt.catv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_catv_rec.id := p5_a0;
    ddp_catv_rec.chr_id := p5_a1;
    ddp_catv_rec.cle_id := p5_a2;
    ddp_catv_rec.cat_id := p5_a3;
    ddp_catv_rec.object_version_number := p5_a4;
    ddp_catv_rec.sfwt_flag := p5_a5;
    ddp_catv_rec.sav_sae_id := p5_a6;
    ddp_catv_rec.sav_sav_release := p5_a7;
    ddp_catv_rec.sbt_code := p5_a8;
    ddp_catv_rec.dnz_chr_id := p5_a9;
    ddp_catv_rec.comments := p5_a10;
    ddp_catv_rec.fulltext_yn := p5_a11;
    ddp_catv_rec.variation_description := p5_a12;
    ddp_catv_rec.name := p5_a13;
    ddp_catv_rec.attribute_category := p5_a14;
    ddp_catv_rec.attribute1 := p5_a15;
    ddp_catv_rec.attribute2 := p5_a16;
    ddp_catv_rec.attribute3 := p5_a17;
    ddp_catv_rec.attribute4 := p5_a18;
    ddp_catv_rec.attribute5 := p5_a19;
    ddp_catv_rec.attribute6 := p5_a20;
    ddp_catv_rec.attribute7 := p5_a21;
    ddp_catv_rec.attribute8 := p5_a22;
    ddp_catv_rec.attribute9 := p5_a23;
    ddp_catv_rec.attribute10 := p5_a24;
    ddp_catv_rec.attribute11 := p5_a25;
    ddp_catv_rec.attribute12 := p5_a26;
    ddp_catv_rec.attribute13 := p5_a27;
    ddp_catv_rec.attribute14 := p5_a28;
    ddp_catv_rec.attribute15 := p5_a29;
    ddp_catv_rec.cat_type := p5_a30;
    ddp_catv_rec.created_by := p5_a31;
    ddp_catv_rec.creation_date := p5_a32;
    ddp_catv_rec.last_updated_by := p5_a33;
    ddp_catv_rec.last_update_date := p5_a34;
    ddp_catv_rec.last_update_login := p5_a35;


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_a_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_catv_rec,
      ddx_catv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_catv_rec.id;
    p6_a1 := ddx_catv_rec.chr_id;
    p6_a2 := ddx_catv_rec.cle_id;
    p6_a3 := ddx_catv_rec.cat_id;
    p6_a4 := ddx_catv_rec.object_version_number;
    p6_a5 := ddx_catv_rec.sfwt_flag;
    p6_a6 := ddx_catv_rec.sav_sae_id;
    p6_a7 := ddx_catv_rec.sav_sav_release;
    p6_a8 := ddx_catv_rec.sbt_code;
    p6_a9 := ddx_catv_rec.dnz_chr_id;
    p6_a10 := ddx_catv_rec.comments;
    p6_a11 := ddx_catv_rec.fulltext_yn;
    p6_a12 := ddx_catv_rec.variation_description;
    p6_a13 := ddx_catv_rec.name;
    p6_a14 := ddx_catv_rec.attribute_category;
    p6_a15 := ddx_catv_rec.attribute1;
    p6_a16 := ddx_catv_rec.attribute2;
    p6_a17 := ddx_catv_rec.attribute3;
    p6_a18 := ddx_catv_rec.attribute4;
    p6_a19 := ddx_catv_rec.attribute5;
    p6_a20 := ddx_catv_rec.attribute6;
    p6_a21 := ddx_catv_rec.attribute7;
    p6_a22 := ddx_catv_rec.attribute8;
    p6_a23 := ddx_catv_rec.attribute9;
    p6_a24 := ddx_catv_rec.attribute10;
    p6_a25 := ddx_catv_rec.attribute11;
    p6_a26 := ddx_catv_rec.attribute12;
    p6_a27 := ddx_catv_rec.attribute13;
    p6_a28 := ddx_catv_rec.attribute14;
    p6_a29 := ddx_catv_rec.attribute15;
    p6_a30 := ddx_catv_rec.cat_type;
    p6_a31 := ddx_catv_rec.created_by;
    p6_a32 := ddx_catv_rec.creation_date;
    p6_a33 := ddx_catv_rec.last_updated_by;
    p6_a34 := ddx_catv_rec.last_update_date;
    p6_a35 := ddx_catv_rec.last_update_login;
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
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  NUMBER
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
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  NUMBER
    , p5_a32  DATE
    , p5_a33  NUMBER
    , p5_a34  DATE
    , p5_a35  NUMBER
  )

  as
    ddp_catv_rec okl_okc_migration_a_pvt.catv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_catv_rec.id := p5_a0;
    ddp_catv_rec.chr_id := p5_a1;
    ddp_catv_rec.cle_id := p5_a2;
    ddp_catv_rec.cat_id := p5_a3;
    ddp_catv_rec.object_version_number := p5_a4;
    ddp_catv_rec.sfwt_flag := p5_a5;
    ddp_catv_rec.sav_sae_id := p5_a6;
    ddp_catv_rec.sav_sav_release := p5_a7;
    ddp_catv_rec.sbt_code := p5_a8;
    ddp_catv_rec.dnz_chr_id := p5_a9;
    ddp_catv_rec.comments := p5_a10;
    ddp_catv_rec.fulltext_yn := p5_a11;
    ddp_catv_rec.variation_description := p5_a12;
    ddp_catv_rec.name := p5_a13;
    ddp_catv_rec.attribute_category := p5_a14;
    ddp_catv_rec.attribute1 := p5_a15;
    ddp_catv_rec.attribute2 := p5_a16;
    ddp_catv_rec.attribute3 := p5_a17;
    ddp_catv_rec.attribute4 := p5_a18;
    ddp_catv_rec.attribute5 := p5_a19;
    ddp_catv_rec.attribute6 := p5_a20;
    ddp_catv_rec.attribute7 := p5_a21;
    ddp_catv_rec.attribute8 := p5_a22;
    ddp_catv_rec.attribute9 := p5_a23;
    ddp_catv_rec.attribute10 := p5_a24;
    ddp_catv_rec.attribute11 := p5_a25;
    ddp_catv_rec.attribute12 := p5_a26;
    ddp_catv_rec.attribute13 := p5_a27;
    ddp_catv_rec.attribute14 := p5_a28;
    ddp_catv_rec.attribute15 := p5_a29;
    ddp_catv_rec.cat_type := p5_a30;
    ddp_catv_rec.created_by := p5_a31;
    ddp_catv_rec.creation_date := p5_a32;
    ddp_catv_rec.last_updated_by := p5_a33;
    ddp_catv_rec.last_update_date := p5_a34;
    ddp_catv_rec.last_update_login := p5_a35;

    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_a_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_catv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  NUMBER
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
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  NUMBER
    , p5_a28  DATE
    , p5_a29  NUMBER
    , p5_a30  DATE
    , p5_a31  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
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
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  DATE
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  DATE
    , p6_a31 out nocopy  NUMBER
  )

  as
    ddp_rgpv_rec okl_okc_migration_a_pvt.rgpv_rec_type;
    ddx_rgpv_rec okl_okc_migration_a_pvt.rgpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rgpv_rec.id := p5_a0;
    ddp_rgpv_rec.object_version_number := p5_a1;
    ddp_rgpv_rec.sfwt_flag := p5_a2;
    ddp_rgpv_rec.rgd_code := p5_a3;
    ddp_rgpv_rec.sat_code := p5_a4;
    ddp_rgpv_rec.rgp_type := p5_a5;
    ddp_rgpv_rec.cle_id := p5_a6;
    ddp_rgpv_rec.chr_id := p5_a7;
    ddp_rgpv_rec.dnz_chr_id := p5_a8;
    ddp_rgpv_rec.parent_rgp_id := p5_a9;
    ddp_rgpv_rec.comments := p5_a10;
    ddp_rgpv_rec.attribute_category := p5_a11;
    ddp_rgpv_rec.attribute1 := p5_a12;
    ddp_rgpv_rec.attribute2 := p5_a13;
    ddp_rgpv_rec.attribute3 := p5_a14;
    ddp_rgpv_rec.attribute4 := p5_a15;
    ddp_rgpv_rec.attribute5 := p5_a16;
    ddp_rgpv_rec.attribute6 := p5_a17;
    ddp_rgpv_rec.attribute7 := p5_a18;
    ddp_rgpv_rec.attribute8 := p5_a19;
    ddp_rgpv_rec.attribute9 := p5_a20;
    ddp_rgpv_rec.attribute10 := p5_a21;
    ddp_rgpv_rec.attribute11 := p5_a22;
    ddp_rgpv_rec.attribute12 := p5_a23;
    ddp_rgpv_rec.attribute13 := p5_a24;
    ddp_rgpv_rec.attribute14 := p5_a25;
    ddp_rgpv_rec.attribute15 := p5_a26;
    ddp_rgpv_rec.created_by := p5_a27;
    ddp_rgpv_rec.creation_date := p5_a28;
    ddp_rgpv_rec.last_updated_by := p5_a29;
    ddp_rgpv_rec.last_update_date := p5_a30;
    ddp_rgpv_rec.last_update_login := p5_a31;


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_a_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_rec,
      ddx_rgpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_rgpv_rec.id;
    p6_a1 := ddx_rgpv_rec.object_version_number;
    p6_a2 := ddx_rgpv_rec.sfwt_flag;
    p6_a3 := ddx_rgpv_rec.rgd_code;
    p6_a4 := ddx_rgpv_rec.sat_code;
    p6_a5 := ddx_rgpv_rec.rgp_type;
    p6_a6 := ddx_rgpv_rec.cle_id;
    p6_a7 := ddx_rgpv_rec.chr_id;
    p6_a8 := ddx_rgpv_rec.dnz_chr_id;
    p6_a9 := ddx_rgpv_rec.parent_rgp_id;
    p6_a10 := ddx_rgpv_rec.comments;
    p6_a11 := ddx_rgpv_rec.attribute_category;
    p6_a12 := ddx_rgpv_rec.attribute1;
    p6_a13 := ddx_rgpv_rec.attribute2;
    p6_a14 := ddx_rgpv_rec.attribute3;
    p6_a15 := ddx_rgpv_rec.attribute4;
    p6_a16 := ddx_rgpv_rec.attribute5;
    p6_a17 := ddx_rgpv_rec.attribute6;
    p6_a18 := ddx_rgpv_rec.attribute7;
    p6_a19 := ddx_rgpv_rec.attribute8;
    p6_a20 := ddx_rgpv_rec.attribute9;
    p6_a21 := ddx_rgpv_rec.attribute10;
    p6_a22 := ddx_rgpv_rec.attribute11;
    p6_a23 := ddx_rgpv_rec.attribute12;
    p6_a24 := ddx_rgpv_rec.attribute13;
    p6_a25 := ddx_rgpv_rec.attribute14;
    p6_a26 := ddx_rgpv_rec.attribute15;
    p6_a27 := ddx_rgpv_rec.created_by;
    p6_a28 := ddx_rgpv_rec.creation_date;
    p6_a29 := ddx_rgpv_rec.last_updated_by;
    p6_a30 := ddx_rgpv_rec.last_update_date;
    p6_a31 := ddx_rgpv_rec.last_update_login;
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  NUMBER
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
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  NUMBER
    , p5_a28  DATE
    , p5_a29  NUMBER
    , p5_a30  DATE
    , p5_a31  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
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
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  DATE
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  DATE
    , p6_a31 out nocopy  NUMBER
  )

  as
    ddp_rgpv_rec okl_okc_migration_a_pvt.rgpv_rec_type;
    ddx_rgpv_rec okl_okc_migration_a_pvt.rgpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rgpv_rec.id := p5_a0;
    ddp_rgpv_rec.object_version_number := p5_a1;
    ddp_rgpv_rec.sfwt_flag := p5_a2;
    ddp_rgpv_rec.rgd_code := p5_a3;
    ddp_rgpv_rec.sat_code := p5_a4;
    ddp_rgpv_rec.rgp_type := p5_a5;
    ddp_rgpv_rec.cle_id := p5_a6;
    ddp_rgpv_rec.chr_id := p5_a7;
    ddp_rgpv_rec.dnz_chr_id := p5_a8;
    ddp_rgpv_rec.parent_rgp_id := p5_a9;
    ddp_rgpv_rec.comments := p5_a10;
    ddp_rgpv_rec.attribute_category := p5_a11;
    ddp_rgpv_rec.attribute1 := p5_a12;
    ddp_rgpv_rec.attribute2 := p5_a13;
    ddp_rgpv_rec.attribute3 := p5_a14;
    ddp_rgpv_rec.attribute4 := p5_a15;
    ddp_rgpv_rec.attribute5 := p5_a16;
    ddp_rgpv_rec.attribute6 := p5_a17;
    ddp_rgpv_rec.attribute7 := p5_a18;
    ddp_rgpv_rec.attribute8 := p5_a19;
    ddp_rgpv_rec.attribute9 := p5_a20;
    ddp_rgpv_rec.attribute10 := p5_a21;
    ddp_rgpv_rec.attribute11 := p5_a22;
    ddp_rgpv_rec.attribute12 := p5_a23;
    ddp_rgpv_rec.attribute13 := p5_a24;
    ddp_rgpv_rec.attribute14 := p5_a25;
    ddp_rgpv_rec.attribute15 := p5_a26;
    ddp_rgpv_rec.created_by := p5_a27;
    ddp_rgpv_rec.creation_date := p5_a28;
    ddp_rgpv_rec.last_updated_by := p5_a29;
    ddp_rgpv_rec.last_update_date := p5_a30;
    ddp_rgpv_rec.last_update_login := p5_a31;


    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_a_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_rec,
      ddx_rgpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_rgpv_rec.id;
    p6_a1 := ddx_rgpv_rec.object_version_number;
    p6_a2 := ddx_rgpv_rec.sfwt_flag;
    p6_a3 := ddx_rgpv_rec.rgd_code;
    p6_a4 := ddx_rgpv_rec.sat_code;
    p6_a5 := ddx_rgpv_rec.rgp_type;
    p6_a6 := ddx_rgpv_rec.cle_id;
    p6_a7 := ddx_rgpv_rec.chr_id;
    p6_a8 := ddx_rgpv_rec.dnz_chr_id;
    p6_a9 := ddx_rgpv_rec.parent_rgp_id;
    p6_a10 := ddx_rgpv_rec.comments;
    p6_a11 := ddx_rgpv_rec.attribute_category;
    p6_a12 := ddx_rgpv_rec.attribute1;
    p6_a13 := ddx_rgpv_rec.attribute2;
    p6_a14 := ddx_rgpv_rec.attribute3;
    p6_a15 := ddx_rgpv_rec.attribute4;
    p6_a16 := ddx_rgpv_rec.attribute5;
    p6_a17 := ddx_rgpv_rec.attribute6;
    p6_a18 := ddx_rgpv_rec.attribute7;
    p6_a19 := ddx_rgpv_rec.attribute8;
    p6_a20 := ddx_rgpv_rec.attribute9;
    p6_a21 := ddx_rgpv_rec.attribute10;
    p6_a22 := ddx_rgpv_rec.attribute11;
    p6_a23 := ddx_rgpv_rec.attribute12;
    p6_a24 := ddx_rgpv_rec.attribute13;
    p6_a25 := ddx_rgpv_rec.attribute14;
    p6_a26 := ddx_rgpv_rec.attribute15;
    p6_a27 := ddx_rgpv_rec.created_by;
    p6_a28 := ddx_rgpv_rec.creation_date;
    p6_a29 := ddx_rgpv_rec.last_updated_by;
    p6_a30 := ddx_rgpv_rec.last_update_date;
    p6_a31 := ddx_rgpv_rec.last_update_login;
  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  NUMBER
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
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  NUMBER
    , p5_a28  DATE
    , p5_a29  NUMBER
    , p5_a30  DATE
    , p5_a31  NUMBER
  )

  as
    ddp_rgpv_rec okl_okc_migration_a_pvt.rgpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rgpv_rec.id := p5_a0;
    ddp_rgpv_rec.object_version_number := p5_a1;
    ddp_rgpv_rec.sfwt_flag := p5_a2;
    ddp_rgpv_rec.rgd_code := p5_a3;
    ddp_rgpv_rec.sat_code := p5_a4;
    ddp_rgpv_rec.rgp_type := p5_a5;
    ddp_rgpv_rec.cle_id := p5_a6;
    ddp_rgpv_rec.chr_id := p5_a7;
    ddp_rgpv_rec.dnz_chr_id := p5_a8;
    ddp_rgpv_rec.parent_rgp_id := p5_a9;
    ddp_rgpv_rec.comments := p5_a10;
    ddp_rgpv_rec.attribute_category := p5_a11;
    ddp_rgpv_rec.attribute1 := p5_a12;
    ddp_rgpv_rec.attribute2 := p5_a13;
    ddp_rgpv_rec.attribute3 := p5_a14;
    ddp_rgpv_rec.attribute4 := p5_a15;
    ddp_rgpv_rec.attribute5 := p5_a16;
    ddp_rgpv_rec.attribute6 := p5_a17;
    ddp_rgpv_rec.attribute7 := p5_a18;
    ddp_rgpv_rec.attribute8 := p5_a19;
    ddp_rgpv_rec.attribute9 := p5_a20;
    ddp_rgpv_rec.attribute10 := p5_a21;
    ddp_rgpv_rec.attribute11 := p5_a22;
    ddp_rgpv_rec.attribute12 := p5_a23;
    ddp_rgpv_rec.attribute13 := p5_a24;
    ddp_rgpv_rec.attribute14 := p5_a25;
    ddp_rgpv_rec.attribute15 := p5_a26;
    ddp_rgpv_rec.created_by := p5_a27;
    ddp_rgpv_rec.creation_date := p5_a28;
    ddp_rgpv_rec.last_updated_by := p5_a29;
    ddp_rgpv_rec.last_update_date := p5_a30;
    ddp_rgpv_rec.last_update_login := p5_a31;

    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_a_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure execute_qa_check_list(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_qcl_id  NUMBER
    , p_chr_id  NUMBER
    , p7_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddx_msg_tbl okl_okc_migration_a_pvt.msg_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    okl_okc_migration_a_pvt.execute_qa_check_list(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_qcl_id,
      p_chr_id,
      ddx_msg_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_okc_migration_a_pvt_w.rosetta_table_copy_out_p7(ddx_msg_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      );
  end;

end okl_okc_migration_a_pvt_w;

/
