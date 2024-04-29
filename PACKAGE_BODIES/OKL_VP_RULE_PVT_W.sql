--------------------------------------------------------
--  DDL for Package Body OKL_VP_RULE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_RULE_PVT_W" as
  /* $Header: OKLERLGB.pls 120.6 2005/10/20 18:48:08 smereddy noship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy okl_vp_rule_pvt.vrs_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_500
    , a4 JTF_VARCHAR2_TABLE_500
    , a5 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).rul_id := a0(indx);
          t(ddindx).rgd_code := a1(indx);
          t(ddindx).rul_code := a2(indx);
          t(ddindx).rule_info1 := a3(indx);
          t(ddindx).rule_info2 := a4(indx);
          t(ddindx).rle_code := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t okl_vp_rule_pvt.vrs_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_500
    , a4 out nocopy JTF_VARCHAR2_TABLE_500
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_500();
    a4 := JTF_VARCHAR2_TABLE_500();
    a5 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_500();
      a4 := JTF_VARCHAR2_TABLE_500();
      a5 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).rul_id;
          a1(indx) := t(ddindx).rgd_code;
          a2(indx) := t(ddindx).rul_code;
          a3(indx) := t(ddindx).rule_info1;
          a4(indx) := t(ddindx).rule_info2;
          a5(indx) := t(ddindx).rle_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_rule_group(p_api_version  NUMBER
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
    ddp_rgpv_rec okl_vp_rule_pvt.rgpv_rec_type;
    ddx_rgpv_rec okl_vp_rule_pvt.rgpv_rec_type;
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
    okl_vp_rule_pvt.create_rule_group(p_api_version,
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

  procedure update_rule_group(p_api_version  NUMBER
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
    ddp_rgpv_rec okl_vp_rule_pvt.rgpv_rec_type;
    ddx_rgpv_rec okl_vp_rule_pvt.rgpv_rec_type;
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
    okl_vp_rule_pvt.update_rule_group(p_api_version,
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

  procedure delete_rule_group(p_api_version  NUMBER
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
    ddp_rgpv_rec okl_vp_rule_pvt.rgpv_rec_type;
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
    okl_vp_rule_pvt.delete_rule_group(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure process_vrs_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_rgp_id  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_VARCHAR2_TABLE_100
    , p7_a2 JTF_VARCHAR2_TABLE_100
    , p7_a3 JTF_VARCHAR2_TABLE_500
    , p7_a4 JTF_VARCHAR2_TABLE_500
    , p7_a5 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_vrs_tbl okl_vp_rule_pvt.vrs_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    okl_vp_rule_pvt_w.rosetta_table_copy_in_p3(ddp_vrs_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_vp_rule_pvt.process_vrs_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      p_rgp_id,
      ddp_vrs_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end okl_vp_rule_pvt_w;

/
