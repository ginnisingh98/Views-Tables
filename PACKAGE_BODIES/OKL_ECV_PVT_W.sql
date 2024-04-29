--------------------------------------------------------
--  DDL for Package Body OKL_ECV_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ECV_PVT_W" as
  /* $Header: OKLIECVB.pls 120.1 2005/10/30 04:58:45 appldev noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy okl_ecv_pvt.okl_ecv_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_500
    , a22 JTF_VARCHAR2_TABLE_500
    , a23 JTF_VARCHAR2_TABLE_500
    , a24 JTF_VARCHAR2_TABLE_500
    , a25 JTF_VARCHAR2_TABLE_500
    , a26 JTF_VARCHAR2_TABLE_500
    , a27 JTF_VARCHAR2_TABLE_500
    , a28 JTF_VARCHAR2_TABLE_500
    , a29 JTF_VARCHAR2_TABLE_500
    , a30 JTF_VARCHAR2_TABLE_500
    , a31 JTF_VARCHAR2_TABLE_500
    , a32 JTF_VARCHAR2_TABLE_500
    , a33 JTF_VARCHAR2_TABLE_500
    , a34 JTF_VARCHAR2_TABLE_500
    , a35 JTF_VARCHAR2_TABLE_500
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).criterion_value_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).criteria_id := a2(indx);
          t(ddindx).data_type_code := a3(indx);
          t(ddindx).source_yn := a4(indx);
          t(ddindx).value_type_code := a5(indx);
          t(ddindx).operator_code := a6(indx);
          t(ddindx).crit_cat_value1 := a7(indx);
          t(ddindx).crit_cat_value2 := a8(indx);
          t(ddindx).crit_cat_numval1 := a9(indx);
          t(ddindx).crit_cat_numval2 := a10(indx);
          t(ddindx).crit_cat_dateval1 := a11(indx);
          t(ddindx).crit_cat_dateval2 := a12(indx);
          t(ddindx).validate_record := a13(indx);
          t(ddindx).adjustment_factor := a14(indx);
          t(ddindx).created_by := a15(indx);
          t(ddindx).creation_date := a16(indx);
          t(ddindx).last_updated_by := a17(indx);
          t(ddindx).last_update_date := a18(indx);
          t(ddindx).last_update_login := a19(indx);
          t(ddindx).attribute_category := a20(indx);
          t(ddindx).attribute1 := a21(indx);
          t(ddindx).attribute2 := a22(indx);
          t(ddindx).attribute3 := a23(indx);
          t(ddindx).attribute4 := a24(indx);
          t(ddindx).attribute5 := a25(indx);
          t(ddindx).attribute6 := a26(indx);
          t(ddindx).attribute7 := a27(indx);
          t(ddindx).attribute8 := a28(indx);
          t(ddindx).attribute9 := a29(indx);
          t(ddindx).attribute10 := a30(indx);
          t(ddindx).attribute11 := a31(indx);
          t(ddindx).attribute12 := a32(indx);
          t(ddindx).attribute13 := a33(indx);
          t(ddindx).attribute14 := a34(indx);
          t(ddindx).attribute15 := a35(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t okl_ecv_pvt.okl_ecv_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_VARCHAR2_TABLE_300
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_500
    , a22 out nocopy JTF_VARCHAR2_TABLE_500
    , a23 out nocopy JTF_VARCHAR2_TABLE_500
    , a24 out nocopy JTF_VARCHAR2_TABLE_500
    , a25 out nocopy JTF_VARCHAR2_TABLE_500
    , a26 out nocopy JTF_VARCHAR2_TABLE_500
    , a27 out nocopy JTF_VARCHAR2_TABLE_500
    , a28 out nocopy JTF_VARCHAR2_TABLE_500
    , a29 out nocopy JTF_VARCHAR2_TABLE_500
    , a30 out nocopy JTF_VARCHAR2_TABLE_500
    , a31 out nocopy JTF_VARCHAR2_TABLE_500
    , a32 out nocopy JTF_VARCHAR2_TABLE_500
    , a33 out nocopy JTF_VARCHAR2_TABLE_500
    , a34 out nocopy JTF_VARCHAR2_TABLE_500
    , a35 out nocopy JTF_VARCHAR2_TABLE_500
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_VARCHAR2_TABLE_300();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_500();
    a22 := JTF_VARCHAR2_TABLE_500();
    a23 := JTF_VARCHAR2_TABLE_500();
    a24 := JTF_VARCHAR2_TABLE_500();
    a25 := JTF_VARCHAR2_TABLE_500();
    a26 := JTF_VARCHAR2_TABLE_500();
    a27 := JTF_VARCHAR2_TABLE_500();
    a28 := JTF_VARCHAR2_TABLE_500();
    a29 := JTF_VARCHAR2_TABLE_500();
    a30 := JTF_VARCHAR2_TABLE_500();
    a31 := JTF_VARCHAR2_TABLE_500();
    a32 := JTF_VARCHAR2_TABLE_500();
    a33 := JTF_VARCHAR2_TABLE_500();
    a34 := JTF_VARCHAR2_TABLE_500();
    a35 := JTF_VARCHAR2_TABLE_500();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_VARCHAR2_TABLE_300();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_500();
      a22 := JTF_VARCHAR2_TABLE_500();
      a23 := JTF_VARCHAR2_TABLE_500();
      a24 := JTF_VARCHAR2_TABLE_500();
      a25 := JTF_VARCHAR2_TABLE_500();
      a26 := JTF_VARCHAR2_TABLE_500();
      a27 := JTF_VARCHAR2_TABLE_500();
      a28 := JTF_VARCHAR2_TABLE_500();
      a29 := JTF_VARCHAR2_TABLE_500();
      a30 := JTF_VARCHAR2_TABLE_500();
      a31 := JTF_VARCHAR2_TABLE_500();
      a32 := JTF_VARCHAR2_TABLE_500();
      a33 := JTF_VARCHAR2_TABLE_500();
      a34 := JTF_VARCHAR2_TABLE_500();
      a35 := JTF_VARCHAR2_TABLE_500();
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
          a0(indx) := t(ddindx).criterion_value_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).criteria_id;
          a3(indx) := t(ddindx).data_type_code;
          a4(indx) := t(ddindx).source_yn;
          a5(indx) := t(ddindx).value_type_code;
          a6(indx) := t(ddindx).operator_code;
          a7(indx) := t(ddindx).crit_cat_value1;
          a8(indx) := t(ddindx).crit_cat_value2;
          a9(indx) := t(ddindx).crit_cat_numval1;
          a10(indx) := t(ddindx).crit_cat_numval2;
          a11(indx) := t(ddindx).crit_cat_dateval1;
          a12(indx) := t(ddindx).crit_cat_dateval2;
          a13(indx) := t(ddindx).validate_record;
          a14(indx) := t(ddindx).adjustment_factor;
          a15(indx) := t(ddindx).created_by;
          a16(indx) := t(ddindx).creation_date;
          a17(indx) := t(ddindx).last_updated_by;
          a18(indx) := t(ddindx).last_update_date;
          a19(indx) := t(ddindx).last_update_login;
          a20(indx) := t(ddindx).attribute_category;
          a21(indx) := t(ddindx).attribute1;
          a22(indx) := t(ddindx).attribute2;
          a23(indx) := t(ddindx).attribute3;
          a24(indx) := t(ddindx).attribute4;
          a25(indx) := t(ddindx).attribute5;
          a26(indx) := t(ddindx).attribute6;
          a27(indx) := t(ddindx).attribute7;
          a28(indx) := t(ddindx).attribute8;
          a29(indx) := t(ddindx).attribute9;
          a30(indx) := t(ddindx).attribute10;
          a31(indx) := t(ddindx).attribute11;
          a32(indx) := t(ddindx).attribute12;
          a33(indx) := t(ddindx).attribute13;
          a34(indx) := t(ddindx).attribute14;
          a35(indx) := t(ddindx).attribute15;
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
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  NUMBER
    , p5_a10  NUMBER
    , p5_a11  DATE
    , p5_a12  DATE
    , p5_a13  VARCHAR2
    , p5_a14  NUMBER
    , p5_a15  NUMBER
    , p5_a16  DATE
    , p5_a17  NUMBER
    , p5_a18  DATE
    , p5_a19  NUMBER
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
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  VARCHAR2
    , p5_a34  VARCHAR2
    , p5_a35  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  NUMBER
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
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
  )

  as
    ddp_ecv_rec okl_ecv_pvt.okl_ecv_rec;
    ddx_ecv_rec okl_ecv_pvt.okl_ecv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ecv_rec.criterion_value_id := p5_a0;
    ddp_ecv_rec.object_version_number := p5_a1;
    ddp_ecv_rec.criteria_id := p5_a2;
    ddp_ecv_rec.data_type_code := p5_a3;
    ddp_ecv_rec.source_yn := p5_a4;
    ddp_ecv_rec.value_type_code := p5_a5;
    ddp_ecv_rec.operator_code := p5_a6;
    ddp_ecv_rec.crit_cat_value1 := p5_a7;
    ddp_ecv_rec.crit_cat_value2 := p5_a8;
    ddp_ecv_rec.crit_cat_numval1 := p5_a9;
    ddp_ecv_rec.crit_cat_numval2 := p5_a10;
    ddp_ecv_rec.crit_cat_dateval1 := p5_a11;
    ddp_ecv_rec.crit_cat_dateval2 := p5_a12;
    ddp_ecv_rec.validate_record := p5_a13;
    ddp_ecv_rec.adjustment_factor := p5_a14;
    ddp_ecv_rec.created_by := p5_a15;
    ddp_ecv_rec.creation_date := p5_a16;
    ddp_ecv_rec.last_updated_by := p5_a17;
    ddp_ecv_rec.last_update_date := p5_a18;
    ddp_ecv_rec.last_update_login := p5_a19;
    ddp_ecv_rec.attribute_category := p5_a20;
    ddp_ecv_rec.attribute1 := p5_a21;
    ddp_ecv_rec.attribute2 := p5_a22;
    ddp_ecv_rec.attribute3 := p5_a23;
    ddp_ecv_rec.attribute4 := p5_a24;
    ddp_ecv_rec.attribute5 := p5_a25;
    ddp_ecv_rec.attribute6 := p5_a26;
    ddp_ecv_rec.attribute7 := p5_a27;
    ddp_ecv_rec.attribute8 := p5_a28;
    ddp_ecv_rec.attribute9 := p5_a29;
    ddp_ecv_rec.attribute10 := p5_a30;
    ddp_ecv_rec.attribute11 := p5_a31;
    ddp_ecv_rec.attribute12 := p5_a32;
    ddp_ecv_rec.attribute13 := p5_a33;
    ddp_ecv_rec.attribute14 := p5_a34;
    ddp_ecv_rec.attribute15 := p5_a35;


    -- here's the delegated call to the old PL/SQL routine
    okl_ecv_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ecv_rec,
      ddx_ecv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_ecv_rec.criterion_value_id;
    p6_a1 := ddx_ecv_rec.object_version_number;
    p6_a2 := ddx_ecv_rec.criteria_id;
    p6_a3 := ddx_ecv_rec.data_type_code;
    p6_a4 := ddx_ecv_rec.source_yn;
    p6_a5 := ddx_ecv_rec.value_type_code;
    p6_a6 := ddx_ecv_rec.operator_code;
    p6_a7 := ddx_ecv_rec.crit_cat_value1;
    p6_a8 := ddx_ecv_rec.crit_cat_value2;
    p6_a9 := ddx_ecv_rec.crit_cat_numval1;
    p6_a10 := ddx_ecv_rec.crit_cat_numval2;
    p6_a11 := ddx_ecv_rec.crit_cat_dateval1;
    p6_a12 := ddx_ecv_rec.crit_cat_dateval2;
    p6_a13 := ddx_ecv_rec.validate_record;
    p6_a14 := ddx_ecv_rec.adjustment_factor;
    p6_a15 := ddx_ecv_rec.created_by;
    p6_a16 := ddx_ecv_rec.creation_date;
    p6_a17 := ddx_ecv_rec.last_updated_by;
    p6_a18 := ddx_ecv_rec.last_update_date;
    p6_a19 := ddx_ecv_rec.last_update_login;
    p6_a20 := ddx_ecv_rec.attribute_category;
    p6_a21 := ddx_ecv_rec.attribute1;
    p6_a22 := ddx_ecv_rec.attribute2;
    p6_a23 := ddx_ecv_rec.attribute3;
    p6_a24 := ddx_ecv_rec.attribute4;
    p6_a25 := ddx_ecv_rec.attribute5;
    p6_a26 := ddx_ecv_rec.attribute6;
    p6_a27 := ddx_ecv_rec.attribute7;
    p6_a28 := ddx_ecv_rec.attribute8;
    p6_a29 := ddx_ecv_rec.attribute9;
    p6_a30 := ddx_ecv_rec.attribute10;
    p6_a31 := ddx_ecv_rec.attribute11;
    p6_a32 := ddx_ecv_rec.attribute12;
    p6_a33 := ddx_ecv_rec.attribute13;
    p6_a34 := ddx_ecv_rec.attribute14;
    p6_a35 := ddx_ecv_rec.attribute15;
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
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_300
    , p5_a8 JTF_VARCHAR2_TABLE_300
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
  )

  as
    ddp_ecv_tbl okl_ecv_pvt.okl_ecv_tbl;
    ddx_ecv_tbl okl_ecv_pvt.okl_ecv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ecv_pvt_w.rosetta_table_copy_in_p1(ddp_ecv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_ecv_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ecv_tbl,
      ddx_ecv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_ecv_pvt_w.rosetta_table_copy_out_p1(ddx_ecv_tbl, p6_a0
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
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  NUMBER
    , p5_a10  NUMBER
    , p5_a11  DATE
    , p5_a12  DATE
    , p5_a13  VARCHAR2
    , p5_a14  NUMBER
    , p5_a15  NUMBER
    , p5_a16  DATE
    , p5_a17  NUMBER
    , p5_a18  DATE
    , p5_a19  NUMBER
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
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  VARCHAR2
    , p5_a34  VARCHAR2
    , p5_a35  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  NUMBER
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
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
  )

  as
    ddp_ecv_rec okl_ecv_pvt.okl_ecv_rec;
    ddx_ecv_rec okl_ecv_pvt.okl_ecv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ecv_rec.criterion_value_id := p5_a0;
    ddp_ecv_rec.object_version_number := p5_a1;
    ddp_ecv_rec.criteria_id := p5_a2;
    ddp_ecv_rec.data_type_code := p5_a3;
    ddp_ecv_rec.source_yn := p5_a4;
    ddp_ecv_rec.value_type_code := p5_a5;
    ddp_ecv_rec.operator_code := p5_a6;
    ddp_ecv_rec.crit_cat_value1 := p5_a7;
    ddp_ecv_rec.crit_cat_value2 := p5_a8;
    ddp_ecv_rec.crit_cat_numval1 := p5_a9;
    ddp_ecv_rec.crit_cat_numval2 := p5_a10;
    ddp_ecv_rec.crit_cat_dateval1 := p5_a11;
    ddp_ecv_rec.crit_cat_dateval2 := p5_a12;
    ddp_ecv_rec.validate_record := p5_a13;
    ddp_ecv_rec.adjustment_factor := p5_a14;
    ddp_ecv_rec.created_by := p5_a15;
    ddp_ecv_rec.creation_date := p5_a16;
    ddp_ecv_rec.last_updated_by := p5_a17;
    ddp_ecv_rec.last_update_date := p5_a18;
    ddp_ecv_rec.last_update_login := p5_a19;
    ddp_ecv_rec.attribute_category := p5_a20;
    ddp_ecv_rec.attribute1 := p5_a21;
    ddp_ecv_rec.attribute2 := p5_a22;
    ddp_ecv_rec.attribute3 := p5_a23;
    ddp_ecv_rec.attribute4 := p5_a24;
    ddp_ecv_rec.attribute5 := p5_a25;
    ddp_ecv_rec.attribute6 := p5_a26;
    ddp_ecv_rec.attribute7 := p5_a27;
    ddp_ecv_rec.attribute8 := p5_a28;
    ddp_ecv_rec.attribute9 := p5_a29;
    ddp_ecv_rec.attribute10 := p5_a30;
    ddp_ecv_rec.attribute11 := p5_a31;
    ddp_ecv_rec.attribute12 := p5_a32;
    ddp_ecv_rec.attribute13 := p5_a33;
    ddp_ecv_rec.attribute14 := p5_a34;
    ddp_ecv_rec.attribute15 := p5_a35;


    -- here's the delegated call to the old PL/SQL routine
    okl_ecv_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ecv_rec,
      ddx_ecv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_ecv_rec.criterion_value_id;
    p6_a1 := ddx_ecv_rec.object_version_number;
    p6_a2 := ddx_ecv_rec.criteria_id;
    p6_a3 := ddx_ecv_rec.data_type_code;
    p6_a4 := ddx_ecv_rec.source_yn;
    p6_a5 := ddx_ecv_rec.value_type_code;
    p6_a6 := ddx_ecv_rec.operator_code;
    p6_a7 := ddx_ecv_rec.crit_cat_value1;
    p6_a8 := ddx_ecv_rec.crit_cat_value2;
    p6_a9 := ddx_ecv_rec.crit_cat_numval1;
    p6_a10 := ddx_ecv_rec.crit_cat_numval2;
    p6_a11 := ddx_ecv_rec.crit_cat_dateval1;
    p6_a12 := ddx_ecv_rec.crit_cat_dateval2;
    p6_a13 := ddx_ecv_rec.validate_record;
    p6_a14 := ddx_ecv_rec.adjustment_factor;
    p6_a15 := ddx_ecv_rec.created_by;
    p6_a16 := ddx_ecv_rec.creation_date;
    p6_a17 := ddx_ecv_rec.last_updated_by;
    p6_a18 := ddx_ecv_rec.last_update_date;
    p6_a19 := ddx_ecv_rec.last_update_login;
    p6_a20 := ddx_ecv_rec.attribute_category;
    p6_a21 := ddx_ecv_rec.attribute1;
    p6_a22 := ddx_ecv_rec.attribute2;
    p6_a23 := ddx_ecv_rec.attribute3;
    p6_a24 := ddx_ecv_rec.attribute4;
    p6_a25 := ddx_ecv_rec.attribute5;
    p6_a26 := ddx_ecv_rec.attribute6;
    p6_a27 := ddx_ecv_rec.attribute7;
    p6_a28 := ddx_ecv_rec.attribute8;
    p6_a29 := ddx_ecv_rec.attribute9;
    p6_a30 := ddx_ecv_rec.attribute10;
    p6_a31 := ddx_ecv_rec.attribute11;
    p6_a32 := ddx_ecv_rec.attribute12;
    p6_a33 := ddx_ecv_rec.attribute13;
    p6_a34 := ddx_ecv_rec.attribute14;
    p6_a35 := ddx_ecv_rec.attribute15;
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
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_300
    , p5_a8 JTF_VARCHAR2_TABLE_300
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
  )

  as
    ddp_ecv_tbl okl_ecv_pvt.okl_ecv_tbl;
    ddx_ecv_tbl okl_ecv_pvt.okl_ecv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ecv_pvt_w.rosetta_table_copy_in_p1(ddp_ecv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_ecv_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ecv_tbl,
      ddx_ecv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_ecv_pvt_w.rosetta_table_copy_out_p1(ddx_ecv_tbl, p6_a0
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
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  NUMBER
    , p5_a10  NUMBER
    , p5_a11  DATE
    , p5_a12  DATE
    , p5_a13  VARCHAR2
    , p5_a14  NUMBER
    , p5_a15  NUMBER
    , p5_a16  DATE
    , p5_a17  NUMBER
    , p5_a18  DATE
    , p5_a19  NUMBER
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
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  VARCHAR2
    , p5_a34  VARCHAR2
    , p5_a35  VARCHAR2
  )

  as
    ddp_ecv_rec okl_ecv_pvt.okl_ecv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ecv_rec.criterion_value_id := p5_a0;
    ddp_ecv_rec.object_version_number := p5_a1;
    ddp_ecv_rec.criteria_id := p5_a2;
    ddp_ecv_rec.data_type_code := p5_a3;
    ddp_ecv_rec.source_yn := p5_a4;
    ddp_ecv_rec.value_type_code := p5_a5;
    ddp_ecv_rec.operator_code := p5_a6;
    ddp_ecv_rec.crit_cat_value1 := p5_a7;
    ddp_ecv_rec.crit_cat_value2 := p5_a8;
    ddp_ecv_rec.crit_cat_numval1 := p5_a9;
    ddp_ecv_rec.crit_cat_numval2 := p5_a10;
    ddp_ecv_rec.crit_cat_dateval1 := p5_a11;
    ddp_ecv_rec.crit_cat_dateval2 := p5_a12;
    ddp_ecv_rec.validate_record := p5_a13;
    ddp_ecv_rec.adjustment_factor := p5_a14;
    ddp_ecv_rec.created_by := p5_a15;
    ddp_ecv_rec.creation_date := p5_a16;
    ddp_ecv_rec.last_updated_by := p5_a17;
    ddp_ecv_rec.last_update_date := p5_a18;
    ddp_ecv_rec.last_update_login := p5_a19;
    ddp_ecv_rec.attribute_category := p5_a20;
    ddp_ecv_rec.attribute1 := p5_a21;
    ddp_ecv_rec.attribute2 := p5_a22;
    ddp_ecv_rec.attribute3 := p5_a23;
    ddp_ecv_rec.attribute4 := p5_a24;
    ddp_ecv_rec.attribute5 := p5_a25;
    ddp_ecv_rec.attribute6 := p5_a26;
    ddp_ecv_rec.attribute7 := p5_a27;
    ddp_ecv_rec.attribute8 := p5_a28;
    ddp_ecv_rec.attribute9 := p5_a29;
    ddp_ecv_rec.attribute10 := p5_a30;
    ddp_ecv_rec.attribute11 := p5_a31;
    ddp_ecv_rec.attribute12 := p5_a32;
    ddp_ecv_rec.attribute13 := p5_a33;
    ddp_ecv_rec.attribute14 := p5_a34;
    ddp_ecv_rec.attribute15 := p5_a35;

    -- here's the delegated call to the old PL/SQL routine
    okl_ecv_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ecv_rec);

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
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_300
    , p5_a8 JTF_VARCHAR2_TABLE_300
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
  )

  as
    ddp_ecv_tbl okl_ecv_pvt.okl_ecv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ecv_pvt_w.rosetta_table_copy_in_p1(ddp_ecv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_ecv_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ecv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  function validate_record(p0_a0 in out nocopy  NUMBER
    , p0_a1 in out nocopy  NUMBER
    , p0_a2 in out nocopy  NUMBER
    , p0_a3 in out nocopy  VARCHAR2
    , p0_a4 in out nocopy  VARCHAR2
    , p0_a5 in out nocopy  VARCHAR2
    , p0_a6 in out nocopy  VARCHAR2
    , p0_a7 in out nocopy  VARCHAR2
    , p0_a8 in out nocopy  VARCHAR2
    , p0_a9 in out nocopy  NUMBER
    , p0_a10 in out nocopy  NUMBER
    , p0_a11 in out nocopy  DATE
    , p0_a12 in out nocopy  DATE
    , p0_a13 in out nocopy  VARCHAR2
    , p0_a14 in out nocopy  NUMBER
    , p0_a15 in out nocopy  NUMBER
    , p0_a16 in out nocopy  DATE
    , p0_a17 in out nocopy  NUMBER
    , p0_a18 in out nocopy  DATE
    , p0_a19 in out nocopy  NUMBER
    , p0_a20 in out nocopy  VARCHAR2
    , p0_a21 in out nocopy  VARCHAR2
    , p0_a22 in out nocopy  VARCHAR2
    , p0_a23 in out nocopy  VARCHAR2
    , p0_a24 in out nocopy  VARCHAR2
    , p0_a25 in out nocopy  VARCHAR2
    , p0_a26 in out nocopy  VARCHAR2
    , p0_a27 in out nocopy  VARCHAR2
    , p0_a28 in out nocopy  VARCHAR2
    , p0_a29 in out nocopy  VARCHAR2
    , p0_a30 in out nocopy  VARCHAR2
    , p0_a31 in out nocopy  VARCHAR2
    , p0_a32 in out nocopy  VARCHAR2
    , p0_a33 in out nocopy  VARCHAR2
    , p0_a34 in out nocopy  VARCHAR2
    , p0_a35 in out nocopy  VARCHAR2
  ) return varchar2

  as
    ddp_ecv_rec okl_ecv_pvt.okl_ecv_rec;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval varchar2(4000);
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_ecv_rec.criterion_value_id := p0_a0;
    ddp_ecv_rec.object_version_number := p0_a1;
    ddp_ecv_rec.criteria_id := p0_a2;
    ddp_ecv_rec.data_type_code := p0_a3;
    ddp_ecv_rec.source_yn := p0_a4;
    ddp_ecv_rec.value_type_code := p0_a5;
    ddp_ecv_rec.operator_code := p0_a6;
    ddp_ecv_rec.crit_cat_value1 := p0_a7;
    ddp_ecv_rec.crit_cat_value2 := p0_a8;
    ddp_ecv_rec.crit_cat_numval1 := p0_a9;
    ddp_ecv_rec.crit_cat_numval2 := p0_a10;
    ddp_ecv_rec.crit_cat_dateval1 := p0_a11;
    ddp_ecv_rec.crit_cat_dateval2 := p0_a12;
    ddp_ecv_rec.validate_record := p0_a13;
    ddp_ecv_rec.adjustment_factor := p0_a14;
    ddp_ecv_rec.created_by := p0_a15;
    ddp_ecv_rec.creation_date := p0_a16;
    ddp_ecv_rec.last_updated_by := p0_a17;
    ddp_ecv_rec.last_update_date := p0_a18;
    ddp_ecv_rec.last_update_login := p0_a19;
    ddp_ecv_rec.attribute_category := p0_a20;
    ddp_ecv_rec.attribute1 := p0_a21;
    ddp_ecv_rec.attribute2 := p0_a22;
    ddp_ecv_rec.attribute3 := p0_a23;
    ddp_ecv_rec.attribute4 := p0_a24;
    ddp_ecv_rec.attribute5 := p0_a25;
    ddp_ecv_rec.attribute6 := p0_a26;
    ddp_ecv_rec.attribute7 := p0_a27;
    ddp_ecv_rec.attribute8 := p0_a28;
    ddp_ecv_rec.attribute9 := p0_a29;
    ddp_ecv_rec.attribute10 := p0_a30;
    ddp_ecv_rec.attribute11 := p0_a31;
    ddp_ecv_rec.attribute12 := p0_a32;
    ddp_ecv_rec.attribute13 := p0_a33;
    ddp_ecv_rec.attribute14 := p0_a34;
    ddp_ecv_rec.attribute15 := p0_a35;

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := okl_ecv_pvt.validate_record(ddp_ecv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddp_ecv_rec.criterion_value_id;
    p0_a1 := ddp_ecv_rec.object_version_number;
    p0_a2 := ddp_ecv_rec.criteria_id;
    p0_a3 := ddp_ecv_rec.data_type_code;
    p0_a4 := ddp_ecv_rec.source_yn;
    p0_a5 := ddp_ecv_rec.value_type_code;
    p0_a6 := ddp_ecv_rec.operator_code;
    p0_a7 := ddp_ecv_rec.crit_cat_value1;
    p0_a8 := ddp_ecv_rec.crit_cat_value2;
    p0_a9 := ddp_ecv_rec.crit_cat_numval1;
    p0_a10 := ddp_ecv_rec.crit_cat_numval2;
    p0_a11 := ddp_ecv_rec.crit_cat_dateval1;
    p0_a12 := ddp_ecv_rec.crit_cat_dateval2;
    p0_a13 := ddp_ecv_rec.validate_record;
    p0_a14 := ddp_ecv_rec.adjustment_factor;
    p0_a15 := ddp_ecv_rec.created_by;
    p0_a16 := ddp_ecv_rec.creation_date;
    p0_a17 := ddp_ecv_rec.last_updated_by;
    p0_a18 := ddp_ecv_rec.last_update_date;
    p0_a19 := ddp_ecv_rec.last_update_login;
    p0_a20 := ddp_ecv_rec.attribute_category;
    p0_a21 := ddp_ecv_rec.attribute1;
    p0_a22 := ddp_ecv_rec.attribute2;
    p0_a23 := ddp_ecv_rec.attribute3;
    p0_a24 := ddp_ecv_rec.attribute4;
    p0_a25 := ddp_ecv_rec.attribute5;
    p0_a26 := ddp_ecv_rec.attribute6;
    p0_a27 := ddp_ecv_rec.attribute7;
    p0_a28 := ddp_ecv_rec.attribute8;
    p0_a29 := ddp_ecv_rec.attribute9;
    p0_a30 := ddp_ecv_rec.attribute10;
    p0_a31 := ddp_ecv_rec.attribute11;
    p0_a32 := ddp_ecv_rec.attribute12;
    p0_a33 := ddp_ecv_rec.attribute13;
    p0_a34 := ddp_ecv_rec.attribute14;
    p0_a35 := ddp_ecv_rec.attribute15;

    return ddrosetta_retval;
  end;

end okl_ecv_pvt_w;

/
