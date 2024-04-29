--------------------------------------------------------
--  DDL for Package Body OKL_LEASE_RATE_SETS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEASE_RATE_SETS_PVT_W" as
  /* $Header: OKLELRSB.pls 120.1 2005/09/30 11:00:09 asawanka noship $ */
  procedure rosetta_table_copy_in_p22(t out nocopy okl_lease_rate_sets_pvt.okl_number_table, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p22;
  procedure rosetta_table_copy_out_p22(t okl_lease_rate_sets_pvt.okl_number_table, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p22;

  procedure create_lease_rate_set(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  DATE
    , p5_a9  DATE
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  NUMBER
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  DATE
    , p5_a16  NUMBER
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
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  VARCHAR2
    , p5_a34  NUMBER
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  NUMBER
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
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  DATE
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  DATE
    , p7_a18  NUMBER
    , p7_a19  DATE
    , p7_a20  NUMBER
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  NUMBER
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  DATE
    , p8_a4 out nocopy  DATE
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  NUMBER
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  NUMBER
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  NUMBER
    , p8_a14 out nocopy  NUMBER
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  NUMBER
    , p8_a17 out nocopy  DATE
    , p8_a18 out nocopy  NUMBER
    , p8_a19 out nocopy  DATE
    , p8_a20 out nocopy  NUMBER
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  VARCHAR2
    , p8_a24 out nocopy  VARCHAR2
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  VARCHAR2
    , p8_a27 out nocopy  VARCHAR2
    , p8_a28 out nocopy  VARCHAR2
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  VARCHAR2
    , p8_a31 out nocopy  VARCHAR2
    , p8_a32 out nocopy  VARCHAR2
    , p8_a33 out nocopy  VARCHAR2
    , p8_a34 out nocopy  VARCHAR2
    , p8_a35 out nocopy  VARCHAR2
    , p8_a36 out nocopy  VARCHAR2
    , p8_a37 out nocopy  NUMBER
  )

  as
    ddp_lrtv_rec okl_lease_rate_sets_pvt.lrtv_rec_type;
    ddx_lrtv_rec okl_lease_rate_sets_pvt.lrtv_rec_type;
    ddp_lrvv_rec okl_lease_rate_sets_pvt.okl_lrvv_rec;
    ddx_lrvv_rec okl_lease_rate_sets_pvt.okl_lrvv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lrtv_rec.id := p5_a0;
    ddp_lrtv_rec.object_version_number := p5_a1;
    ddp_lrtv_rec.sfwt_flag := p5_a2;
    ddp_lrtv_rec.try_id := p5_a3;
    ddp_lrtv_rec.pdt_id := p5_a4;
    ddp_lrtv_rec.rate := p5_a5;
    ddp_lrtv_rec.frq_code := p5_a6;
    ddp_lrtv_rec.arrears_yn := p5_a7;
    ddp_lrtv_rec.start_date := p5_a8;
    ddp_lrtv_rec.end_date := p5_a9;
    ddp_lrtv_rec.name := p5_a10;
    ddp_lrtv_rec.description := p5_a11;
    ddp_lrtv_rec.created_by := p5_a12;
    ddp_lrtv_rec.creation_date := p5_a13;
    ddp_lrtv_rec.last_updated_by := p5_a14;
    ddp_lrtv_rec.last_update_date := p5_a15;
    ddp_lrtv_rec.last_update_login := p5_a16;
    ddp_lrtv_rec.attribute_category := p5_a17;
    ddp_lrtv_rec.attribute1 := p5_a18;
    ddp_lrtv_rec.attribute2 := p5_a19;
    ddp_lrtv_rec.attribute3 := p5_a20;
    ddp_lrtv_rec.attribute4 := p5_a21;
    ddp_lrtv_rec.attribute5 := p5_a22;
    ddp_lrtv_rec.attribute6 := p5_a23;
    ddp_lrtv_rec.attribute7 := p5_a24;
    ddp_lrtv_rec.attribute8 := p5_a25;
    ddp_lrtv_rec.attribute9 := p5_a26;
    ddp_lrtv_rec.attribute10 := p5_a27;
    ddp_lrtv_rec.attribute11 := p5_a28;
    ddp_lrtv_rec.attribute12 := p5_a29;
    ddp_lrtv_rec.attribute13 := p5_a30;
    ddp_lrtv_rec.attribute14 := p5_a31;
    ddp_lrtv_rec.attribute15 := p5_a32;
    ddp_lrtv_rec.sts_code := p5_a33;
    ddp_lrtv_rec.org_id := p5_a34;
    ddp_lrtv_rec.currency_code := p5_a35;
    ddp_lrtv_rec.lrs_type_code := p5_a36;
    ddp_lrtv_rec.end_of_term_id := p5_a37;
    ddp_lrtv_rec.orig_rate_set_id := p5_a38;


    ddp_lrvv_rec.rate_set_version_id := p7_a0;
    ddp_lrvv_rec.object_version_number := p7_a1;
    ddp_lrvv_rec.arrears_yn := p7_a2;
    ddp_lrvv_rec.effective_from_date := p7_a3;
    ddp_lrvv_rec.effective_to_date := p7_a4;
    ddp_lrvv_rec.rate_set_id := p7_a5;
    ddp_lrvv_rec.end_of_term_ver_id := p7_a6;
    ddp_lrvv_rec.std_rate_tmpl_ver_id := p7_a7;
    ddp_lrvv_rec.adj_mat_version_id := p7_a8;
    ddp_lrvv_rec.version_number := p7_a9;
    ddp_lrvv_rec.lrs_rate := p7_a10;
    ddp_lrvv_rec.rate_tolerance := p7_a11;
    ddp_lrvv_rec.residual_tolerance := p7_a12;
    ddp_lrvv_rec.deferred_pmts := p7_a13;
    ddp_lrvv_rec.advance_pmts := p7_a14;
    ddp_lrvv_rec.sts_code := p7_a15;
    ddp_lrvv_rec.created_by := p7_a16;
    ddp_lrvv_rec.creation_date := p7_a17;
    ddp_lrvv_rec.last_updated_by := p7_a18;
    ddp_lrvv_rec.last_update_date := p7_a19;
    ddp_lrvv_rec.last_update_login := p7_a20;
    ddp_lrvv_rec.attribute_category := p7_a21;
    ddp_lrvv_rec.attribute1 := p7_a22;
    ddp_lrvv_rec.attribute2 := p7_a23;
    ddp_lrvv_rec.attribute3 := p7_a24;
    ddp_lrvv_rec.attribute4 := p7_a25;
    ddp_lrvv_rec.attribute5 := p7_a26;
    ddp_lrvv_rec.attribute6 := p7_a27;
    ddp_lrvv_rec.attribute7 := p7_a28;
    ddp_lrvv_rec.attribute8 := p7_a29;
    ddp_lrvv_rec.attribute9 := p7_a30;
    ddp_lrvv_rec.attribute10 := p7_a31;
    ddp_lrvv_rec.attribute11 := p7_a32;
    ddp_lrvv_rec.attribute12 := p7_a33;
    ddp_lrvv_rec.attribute13 := p7_a34;
    ddp_lrvv_rec.attribute14 := p7_a35;
    ddp_lrvv_rec.attribute15 := p7_a36;
    ddp_lrvv_rec.standard_rate := p7_a37;


    -- here's the delegated call to the old PL/SQL routine
    okl_lease_rate_sets_pvt.create_lease_rate_set(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lrtv_rec,
      ddx_lrtv_rec,
      ddp_lrvv_rec,
      ddx_lrvv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lrtv_rec.id;
    p6_a1 := ddx_lrtv_rec.object_version_number;
    p6_a2 := ddx_lrtv_rec.sfwt_flag;
    p6_a3 := ddx_lrtv_rec.try_id;
    p6_a4 := ddx_lrtv_rec.pdt_id;
    p6_a5 := ddx_lrtv_rec.rate;
    p6_a6 := ddx_lrtv_rec.frq_code;
    p6_a7 := ddx_lrtv_rec.arrears_yn;
    p6_a8 := ddx_lrtv_rec.start_date;
    p6_a9 := ddx_lrtv_rec.end_date;
    p6_a10 := ddx_lrtv_rec.name;
    p6_a11 := ddx_lrtv_rec.description;
    p6_a12 := ddx_lrtv_rec.created_by;
    p6_a13 := ddx_lrtv_rec.creation_date;
    p6_a14 := ddx_lrtv_rec.last_updated_by;
    p6_a15 := ddx_lrtv_rec.last_update_date;
    p6_a16 := ddx_lrtv_rec.last_update_login;
    p6_a17 := ddx_lrtv_rec.attribute_category;
    p6_a18 := ddx_lrtv_rec.attribute1;
    p6_a19 := ddx_lrtv_rec.attribute2;
    p6_a20 := ddx_lrtv_rec.attribute3;
    p6_a21 := ddx_lrtv_rec.attribute4;
    p6_a22 := ddx_lrtv_rec.attribute5;
    p6_a23 := ddx_lrtv_rec.attribute6;
    p6_a24 := ddx_lrtv_rec.attribute7;
    p6_a25 := ddx_lrtv_rec.attribute8;
    p6_a26 := ddx_lrtv_rec.attribute9;
    p6_a27 := ddx_lrtv_rec.attribute10;
    p6_a28 := ddx_lrtv_rec.attribute11;
    p6_a29 := ddx_lrtv_rec.attribute12;
    p6_a30 := ddx_lrtv_rec.attribute13;
    p6_a31 := ddx_lrtv_rec.attribute14;
    p6_a32 := ddx_lrtv_rec.attribute15;
    p6_a33 := ddx_lrtv_rec.sts_code;
    p6_a34 := ddx_lrtv_rec.org_id;
    p6_a35 := ddx_lrtv_rec.currency_code;
    p6_a36 := ddx_lrtv_rec.lrs_type_code;
    p6_a37 := ddx_lrtv_rec.end_of_term_id;
    p6_a38 := ddx_lrtv_rec.orig_rate_set_id;


    p8_a0 := ddx_lrvv_rec.rate_set_version_id;
    p8_a1 := ddx_lrvv_rec.object_version_number;
    p8_a2 := ddx_lrvv_rec.arrears_yn;
    p8_a3 := ddx_lrvv_rec.effective_from_date;
    p8_a4 := ddx_lrvv_rec.effective_to_date;
    p8_a5 := ddx_lrvv_rec.rate_set_id;
    p8_a6 := ddx_lrvv_rec.end_of_term_ver_id;
    p8_a7 := ddx_lrvv_rec.std_rate_tmpl_ver_id;
    p8_a8 := ddx_lrvv_rec.adj_mat_version_id;
    p8_a9 := ddx_lrvv_rec.version_number;
    p8_a10 := ddx_lrvv_rec.lrs_rate;
    p8_a11 := ddx_lrvv_rec.rate_tolerance;
    p8_a12 := ddx_lrvv_rec.residual_tolerance;
    p8_a13 := ddx_lrvv_rec.deferred_pmts;
    p8_a14 := ddx_lrvv_rec.advance_pmts;
    p8_a15 := ddx_lrvv_rec.sts_code;
    p8_a16 := ddx_lrvv_rec.created_by;
    p8_a17 := ddx_lrvv_rec.creation_date;
    p8_a18 := ddx_lrvv_rec.last_updated_by;
    p8_a19 := ddx_lrvv_rec.last_update_date;
    p8_a20 := ddx_lrvv_rec.last_update_login;
    p8_a21 := ddx_lrvv_rec.attribute_category;
    p8_a22 := ddx_lrvv_rec.attribute1;
    p8_a23 := ddx_lrvv_rec.attribute2;
    p8_a24 := ddx_lrvv_rec.attribute3;
    p8_a25 := ddx_lrvv_rec.attribute4;
    p8_a26 := ddx_lrvv_rec.attribute5;
    p8_a27 := ddx_lrvv_rec.attribute6;
    p8_a28 := ddx_lrvv_rec.attribute7;
    p8_a29 := ddx_lrvv_rec.attribute8;
    p8_a30 := ddx_lrvv_rec.attribute9;
    p8_a31 := ddx_lrvv_rec.attribute10;
    p8_a32 := ddx_lrvv_rec.attribute11;
    p8_a33 := ddx_lrvv_rec.attribute12;
    p8_a34 := ddx_lrvv_rec.attribute13;
    p8_a35 := ddx_lrvv_rec.attribute14;
    p8_a36 := ddx_lrvv_rec.attribute15;
    p8_a37 := ddx_lrvv_rec.standard_rate;
  end;

  procedure update_lease_rate_set(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  DATE
    , p5_a9  DATE
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  NUMBER
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  DATE
    , p5_a16  NUMBER
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
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  VARCHAR2
    , p5_a34  NUMBER
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  NUMBER
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
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  DATE
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  DATE
    , p7_a18  NUMBER
    , p7_a19  DATE
    , p7_a20  NUMBER
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  NUMBER
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  DATE
    , p8_a4 out nocopy  DATE
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  NUMBER
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  NUMBER
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  NUMBER
    , p8_a14 out nocopy  NUMBER
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  NUMBER
    , p8_a17 out nocopy  DATE
    , p8_a18 out nocopy  NUMBER
    , p8_a19 out nocopy  DATE
    , p8_a20 out nocopy  NUMBER
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  VARCHAR2
    , p8_a24 out nocopy  VARCHAR2
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  VARCHAR2
    , p8_a27 out nocopy  VARCHAR2
    , p8_a28 out nocopy  VARCHAR2
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  VARCHAR2
    , p8_a31 out nocopy  VARCHAR2
    , p8_a32 out nocopy  VARCHAR2
    , p8_a33 out nocopy  VARCHAR2
    , p8_a34 out nocopy  VARCHAR2
    , p8_a35 out nocopy  VARCHAR2
    , p8_a36 out nocopy  VARCHAR2
    , p8_a37 out nocopy  NUMBER
  )

  as
    ddp_lrtv_rec okl_lease_rate_sets_pvt.lrtv_rec_type;
    ddx_lrtv_rec okl_lease_rate_sets_pvt.lrtv_rec_type;
    ddp_lrvv_rec okl_lease_rate_sets_pvt.okl_lrvv_rec;
    ddx_lrvv_rec okl_lease_rate_sets_pvt.okl_lrvv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lrtv_rec.id := p5_a0;
    ddp_lrtv_rec.object_version_number := p5_a1;
    ddp_lrtv_rec.sfwt_flag := p5_a2;
    ddp_lrtv_rec.try_id := p5_a3;
    ddp_lrtv_rec.pdt_id := p5_a4;
    ddp_lrtv_rec.rate := p5_a5;
    ddp_lrtv_rec.frq_code := p5_a6;
    ddp_lrtv_rec.arrears_yn := p5_a7;
    ddp_lrtv_rec.start_date := p5_a8;
    ddp_lrtv_rec.end_date := p5_a9;
    ddp_lrtv_rec.name := p5_a10;
    ddp_lrtv_rec.description := p5_a11;
    ddp_lrtv_rec.created_by := p5_a12;
    ddp_lrtv_rec.creation_date := p5_a13;
    ddp_lrtv_rec.last_updated_by := p5_a14;
    ddp_lrtv_rec.last_update_date := p5_a15;
    ddp_lrtv_rec.last_update_login := p5_a16;
    ddp_lrtv_rec.attribute_category := p5_a17;
    ddp_lrtv_rec.attribute1 := p5_a18;
    ddp_lrtv_rec.attribute2 := p5_a19;
    ddp_lrtv_rec.attribute3 := p5_a20;
    ddp_lrtv_rec.attribute4 := p5_a21;
    ddp_lrtv_rec.attribute5 := p5_a22;
    ddp_lrtv_rec.attribute6 := p5_a23;
    ddp_lrtv_rec.attribute7 := p5_a24;
    ddp_lrtv_rec.attribute8 := p5_a25;
    ddp_lrtv_rec.attribute9 := p5_a26;
    ddp_lrtv_rec.attribute10 := p5_a27;
    ddp_lrtv_rec.attribute11 := p5_a28;
    ddp_lrtv_rec.attribute12 := p5_a29;
    ddp_lrtv_rec.attribute13 := p5_a30;
    ddp_lrtv_rec.attribute14 := p5_a31;
    ddp_lrtv_rec.attribute15 := p5_a32;
    ddp_lrtv_rec.sts_code := p5_a33;
    ddp_lrtv_rec.org_id := p5_a34;
    ddp_lrtv_rec.currency_code := p5_a35;
    ddp_lrtv_rec.lrs_type_code := p5_a36;
    ddp_lrtv_rec.end_of_term_id := p5_a37;
    ddp_lrtv_rec.orig_rate_set_id := p5_a38;


    ddp_lrvv_rec.rate_set_version_id := p7_a0;
    ddp_lrvv_rec.object_version_number := p7_a1;
    ddp_lrvv_rec.arrears_yn := p7_a2;
    ddp_lrvv_rec.effective_from_date := p7_a3;
    ddp_lrvv_rec.effective_to_date := p7_a4;
    ddp_lrvv_rec.rate_set_id := p7_a5;
    ddp_lrvv_rec.end_of_term_ver_id := p7_a6;
    ddp_lrvv_rec.std_rate_tmpl_ver_id := p7_a7;
    ddp_lrvv_rec.adj_mat_version_id := p7_a8;
    ddp_lrvv_rec.version_number := p7_a9;
    ddp_lrvv_rec.lrs_rate := p7_a10;
    ddp_lrvv_rec.rate_tolerance := p7_a11;
    ddp_lrvv_rec.residual_tolerance := p7_a12;
    ddp_lrvv_rec.deferred_pmts := p7_a13;
    ddp_lrvv_rec.advance_pmts := p7_a14;
    ddp_lrvv_rec.sts_code := p7_a15;
    ddp_lrvv_rec.created_by := p7_a16;
    ddp_lrvv_rec.creation_date := p7_a17;
    ddp_lrvv_rec.last_updated_by := p7_a18;
    ddp_lrvv_rec.last_update_date := p7_a19;
    ddp_lrvv_rec.last_update_login := p7_a20;
    ddp_lrvv_rec.attribute_category := p7_a21;
    ddp_lrvv_rec.attribute1 := p7_a22;
    ddp_lrvv_rec.attribute2 := p7_a23;
    ddp_lrvv_rec.attribute3 := p7_a24;
    ddp_lrvv_rec.attribute4 := p7_a25;
    ddp_lrvv_rec.attribute5 := p7_a26;
    ddp_lrvv_rec.attribute6 := p7_a27;
    ddp_lrvv_rec.attribute7 := p7_a28;
    ddp_lrvv_rec.attribute8 := p7_a29;
    ddp_lrvv_rec.attribute9 := p7_a30;
    ddp_lrvv_rec.attribute10 := p7_a31;
    ddp_lrvv_rec.attribute11 := p7_a32;
    ddp_lrvv_rec.attribute12 := p7_a33;
    ddp_lrvv_rec.attribute13 := p7_a34;
    ddp_lrvv_rec.attribute14 := p7_a35;
    ddp_lrvv_rec.attribute15 := p7_a36;
    ddp_lrvv_rec.standard_rate := p7_a37;


    -- here's the delegated call to the old PL/SQL routine
    okl_lease_rate_sets_pvt.update_lease_rate_set(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lrtv_rec,
      ddx_lrtv_rec,
      ddp_lrvv_rec,
      ddx_lrvv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lrtv_rec.id;
    p6_a1 := ddx_lrtv_rec.object_version_number;
    p6_a2 := ddx_lrtv_rec.sfwt_flag;
    p6_a3 := ddx_lrtv_rec.try_id;
    p6_a4 := ddx_lrtv_rec.pdt_id;
    p6_a5 := ddx_lrtv_rec.rate;
    p6_a6 := ddx_lrtv_rec.frq_code;
    p6_a7 := ddx_lrtv_rec.arrears_yn;
    p6_a8 := ddx_lrtv_rec.start_date;
    p6_a9 := ddx_lrtv_rec.end_date;
    p6_a10 := ddx_lrtv_rec.name;
    p6_a11 := ddx_lrtv_rec.description;
    p6_a12 := ddx_lrtv_rec.created_by;
    p6_a13 := ddx_lrtv_rec.creation_date;
    p6_a14 := ddx_lrtv_rec.last_updated_by;
    p6_a15 := ddx_lrtv_rec.last_update_date;
    p6_a16 := ddx_lrtv_rec.last_update_login;
    p6_a17 := ddx_lrtv_rec.attribute_category;
    p6_a18 := ddx_lrtv_rec.attribute1;
    p6_a19 := ddx_lrtv_rec.attribute2;
    p6_a20 := ddx_lrtv_rec.attribute3;
    p6_a21 := ddx_lrtv_rec.attribute4;
    p6_a22 := ddx_lrtv_rec.attribute5;
    p6_a23 := ddx_lrtv_rec.attribute6;
    p6_a24 := ddx_lrtv_rec.attribute7;
    p6_a25 := ddx_lrtv_rec.attribute8;
    p6_a26 := ddx_lrtv_rec.attribute9;
    p6_a27 := ddx_lrtv_rec.attribute10;
    p6_a28 := ddx_lrtv_rec.attribute11;
    p6_a29 := ddx_lrtv_rec.attribute12;
    p6_a30 := ddx_lrtv_rec.attribute13;
    p6_a31 := ddx_lrtv_rec.attribute14;
    p6_a32 := ddx_lrtv_rec.attribute15;
    p6_a33 := ddx_lrtv_rec.sts_code;
    p6_a34 := ddx_lrtv_rec.org_id;
    p6_a35 := ddx_lrtv_rec.currency_code;
    p6_a36 := ddx_lrtv_rec.lrs_type_code;
    p6_a37 := ddx_lrtv_rec.end_of_term_id;
    p6_a38 := ddx_lrtv_rec.orig_rate_set_id;


    p8_a0 := ddx_lrvv_rec.rate_set_version_id;
    p8_a1 := ddx_lrvv_rec.object_version_number;
    p8_a2 := ddx_lrvv_rec.arrears_yn;
    p8_a3 := ddx_lrvv_rec.effective_from_date;
    p8_a4 := ddx_lrvv_rec.effective_to_date;
    p8_a5 := ddx_lrvv_rec.rate_set_id;
    p8_a6 := ddx_lrvv_rec.end_of_term_ver_id;
    p8_a7 := ddx_lrvv_rec.std_rate_tmpl_ver_id;
    p8_a8 := ddx_lrvv_rec.adj_mat_version_id;
    p8_a9 := ddx_lrvv_rec.version_number;
    p8_a10 := ddx_lrvv_rec.lrs_rate;
    p8_a11 := ddx_lrvv_rec.rate_tolerance;
    p8_a12 := ddx_lrvv_rec.residual_tolerance;
    p8_a13 := ddx_lrvv_rec.deferred_pmts;
    p8_a14 := ddx_lrvv_rec.advance_pmts;
    p8_a15 := ddx_lrvv_rec.sts_code;
    p8_a16 := ddx_lrvv_rec.created_by;
    p8_a17 := ddx_lrvv_rec.creation_date;
    p8_a18 := ddx_lrvv_rec.last_updated_by;
    p8_a19 := ddx_lrvv_rec.last_update_date;
    p8_a20 := ddx_lrvv_rec.last_update_login;
    p8_a21 := ddx_lrvv_rec.attribute_category;
    p8_a22 := ddx_lrvv_rec.attribute1;
    p8_a23 := ddx_lrvv_rec.attribute2;
    p8_a24 := ddx_lrvv_rec.attribute3;
    p8_a25 := ddx_lrvv_rec.attribute4;
    p8_a26 := ddx_lrvv_rec.attribute5;
    p8_a27 := ddx_lrvv_rec.attribute6;
    p8_a28 := ddx_lrvv_rec.attribute7;
    p8_a29 := ddx_lrvv_rec.attribute8;
    p8_a30 := ddx_lrvv_rec.attribute9;
    p8_a31 := ddx_lrvv_rec.attribute10;
    p8_a32 := ddx_lrvv_rec.attribute11;
    p8_a33 := ddx_lrvv_rec.attribute12;
    p8_a34 := ddx_lrvv_rec.attribute13;
    p8_a35 := ddx_lrvv_rec.attribute14;
    p8_a36 := ddx_lrvv_rec.attribute15;
    p8_a37 := ddx_lrvv_rec.standard_rate;
  end;

  procedure version_lease_rate_set(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  DATE
    , p5_a9  DATE
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  NUMBER
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  DATE
    , p5_a16  NUMBER
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
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  VARCHAR2
    , p5_a34  NUMBER
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  NUMBER
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
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  DATE
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  DATE
    , p7_a18  NUMBER
    , p7_a19  DATE
    , p7_a20  NUMBER
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  NUMBER
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  DATE
    , p8_a4 out nocopy  DATE
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  NUMBER
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  NUMBER
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  NUMBER
    , p8_a14 out nocopy  NUMBER
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  NUMBER
    , p8_a17 out nocopy  DATE
    , p8_a18 out nocopy  NUMBER
    , p8_a19 out nocopy  DATE
    , p8_a20 out nocopy  NUMBER
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  VARCHAR2
    , p8_a24 out nocopy  VARCHAR2
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  VARCHAR2
    , p8_a27 out nocopy  VARCHAR2
    , p8_a28 out nocopy  VARCHAR2
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  VARCHAR2
    , p8_a31 out nocopy  VARCHAR2
    , p8_a32 out nocopy  VARCHAR2
    , p8_a33 out nocopy  VARCHAR2
    , p8_a34 out nocopy  VARCHAR2
    , p8_a35 out nocopy  VARCHAR2
    , p8_a36 out nocopy  VARCHAR2
    , p8_a37 out nocopy  NUMBER
  )

  as
    ddp_lrtv_rec okl_lease_rate_sets_pvt.lrtv_rec_type;
    ddx_lrtv_rec okl_lease_rate_sets_pvt.lrtv_rec_type;
    ddp_lrvv_rec okl_lease_rate_sets_pvt.okl_lrvv_rec;
    ddx_lrvv_rec okl_lease_rate_sets_pvt.okl_lrvv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lrtv_rec.id := p5_a0;
    ddp_lrtv_rec.object_version_number := p5_a1;
    ddp_lrtv_rec.sfwt_flag := p5_a2;
    ddp_lrtv_rec.try_id := p5_a3;
    ddp_lrtv_rec.pdt_id := p5_a4;
    ddp_lrtv_rec.rate := p5_a5;
    ddp_lrtv_rec.frq_code := p5_a6;
    ddp_lrtv_rec.arrears_yn := p5_a7;
    ddp_lrtv_rec.start_date := p5_a8;
    ddp_lrtv_rec.end_date := p5_a9;
    ddp_lrtv_rec.name := p5_a10;
    ddp_lrtv_rec.description := p5_a11;
    ddp_lrtv_rec.created_by := p5_a12;
    ddp_lrtv_rec.creation_date := p5_a13;
    ddp_lrtv_rec.last_updated_by := p5_a14;
    ddp_lrtv_rec.last_update_date := p5_a15;
    ddp_lrtv_rec.last_update_login := p5_a16;
    ddp_lrtv_rec.attribute_category := p5_a17;
    ddp_lrtv_rec.attribute1 := p5_a18;
    ddp_lrtv_rec.attribute2 := p5_a19;
    ddp_lrtv_rec.attribute3 := p5_a20;
    ddp_lrtv_rec.attribute4 := p5_a21;
    ddp_lrtv_rec.attribute5 := p5_a22;
    ddp_lrtv_rec.attribute6 := p5_a23;
    ddp_lrtv_rec.attribute7 := p5_a24;
    ddp_lrtv_rec.attribute8 := p5_a25;
    ddp_lrtv_rec.attribute9 := p5_a26;
    ddp_lrtv_rec.attribute10 := p5_a27;
    ddp_lrtv_rec.attribute11 := p5_a28;
    ddp_lrtv_rec.attribute12 := p5_a29;
    ddp_lrtv_rec.attribute13 := p5_a30;
    ddp_lrtv_rec.attribute14 := p5_a31;
    ddp_lrtv_rec.attribute15 := p5_a32;
    ddp_lrtv_rec.sts_code := p5_a33;
    ddp_lrtv_rec.org_id := p5_a34;
    ddp_lrtv_rec.currency_code := p5_a35;
    ddp_lrtv_rec.lrs_type_code := p5_a36;
    ddp_lrtv_rec.end_of_term_id := p5_a37;
    ddp_lrtv_rec.orig_rate_set_id := p5_a38;


    ddp_lrvv_rec.rate_set_version_id := p7_a0;
    ddp_lrvv_rec.object_version_number := p7_a1;
    ddp_lrvv_rec.arrears_yn := p7_a2;
    ddp_lrvv_rec.effective_from_date := p7_a3;
    ddp_lrvv_rec.effective_to_date := p7_a4;
    ddp_lrvv_rec.rate_set_id := p7_a5;
    ddp_lrvv_rec.end_of_term_ver_id := p7_a6;
    ddp_lrvv_rec.std_rate_tmpl_ver_id := p7_a7;
    ddp_lrvv_rec.adj_mat_version_id := p7_a8;
    ddp_lrvv_rec.version_number := p7_a9;
    ddp_lrvv_rec.lrs_rate := p7_a10;
    ddp_lrvv_rec.rate_tolerance := p7_a11;
    ddp_lrvv_rec.residual_tolerance := p7_a12;
    ddp_lrvv_rec.deferred_pmts := p7_a13;
    ddp_lrvv_rec.advance_pmts := p7_a14;
    ddp_lrvv_rec.sts_code := p7_a15;
    ddp_lrvv_rec.created_by := p7_a16;
    ddp_lrvv_rec.creation_date := p7_a17;
    ddp_lrvv_rec.last_updated_by := p7_a18;
    ddp_lrvv_rec.last_update_date := p7_a19;
    ddp_lrvv_rec.last_update_login := p7_a20;
    ddp_lrvv_rec.attribute_category := p7_a21;
    ddp_lrvv_rec.attribute1 := p7_a22;
    ddp_lrvv_rec.attribute2 := p7_a23;
    ddp_lrvv_rec.attribute3 := p7_a24;
    ddp_lrvv_rec.attribute4 := p7_a25;
    ddp_lrvv_rec.attribute5 := p7_a26;
    ddp_lrvv_rec.attribute6 := p7_a27;
    ddp_lrvv_rec.attribute7 := p7_a28;
    ddp_lrvv_rec.attribute8 := p7_a29;
    ddp_lrvv_rec.attribute9 := p7_a30;
    ddp_lrvv_rec.attribute10 := p7_a31;
    ddp_lrvv_rec.attribute11 := p7_a32;
    ddp_lrvv_rec.attribute12 := p7_a33;
    ddp_lrvv_rec.attribute13 := p7_a34;
    ddp_lrvv_rec.attribute14 := p7_a35;
    ddp_lrvv_rec.attribute15 := p7_a36;
    ddp_lrvv_rec.standard_rate := p7_a37;


    -- here's the delegated call to the old PL/SQL routine
    okl_lease_rate_sets_pvt.version_lease_rate_set(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lrtv_rec,
      ddx_lrtv_rec,
      ddp_lrvv_rec,
      ddx_lrvv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lrtv_rec.id;
    p6_a1 := ddx_lrtv_rec.object_version_number;
    p6_a2 := ddx_lrtv_rec.sfwt_flag;
    p6_a3 := ddx_lrtv_rec.try_id;
    p6_a4 := ddx_lrtv_rec.pdt_id;
    p6_a5 := ddx_lrtv_rec.rate;
    p6_a6 := ddx_lrtv_rec.frq_code;
    p6_a7 := ddx_lrtv_rec.arrears_yn;
    p6_a8 := ddx_lrtv_rec.start_date;
    p6_a9 := ddx_lrtv_rec.end_date;
    p6_a10 := ddx_lrtv_rec.name;
    p6_a11 := ddx_lrtv_rec.description;
    p6_a12 := ddx_lrtv_rec.created_by;
    p6_a13 := ddx_lrtv_rec.creation_date;
    p6_a14 := ddx_lrtv_rec.last_updated_by;
    p6_a15 := ddx_lrtv_rec.last_update_date;
    p6_a16 := ddx_lrtv_rec.last_update_login;
    p6_a17 := ddx_lrtv_rec.attribute_category;
    p6_a18 := ddx_lrtv_rec.attribute1;
    p6_a19 := ddx_lrtv_rec.attribute2;
    p6_a20 := ddx_lrtv_rec.attribute3;
    p6_a21 := ddx_lrtv_rec.attribute4;
    p6_a22 := ddx_lrtv_rec.attribute5;
    p6_a23 := ddx_lrtv_rec.attribute6;
    p6_a24 := ddx_lrtv_rec.attribute7;
    p6_a25 := ddx_lrtv_rec.attribute8;
    p6_a26 := ddx_lrtv_rec.attribute9;
    p6_a27 := ddx_lrtv_rec.attribute10;
    p6_a28 := ddx_lrtv_rec.attribute11;
    p6_a29 := ddx_lrtv_rec.attribute12;
    p6_a30 := ddx_lrtv_rec.attribute13;
    p6_a31 := ddx_lrtv_rec.attribute14;
    p6_a32 := ddx_lrtv_rec.attribute15;
    p6_a33 := ddx_lrtv_rec.sts_code;
    p6_a34 := ddx_lrtv_rec.org_id;
    p6_a35 := ddx_lrtv_rec.currency_code;
    p6_a36 := ddx_lrtv_rec.lrs_type_code;
    p6_a37 := ddx_lrtv_rec.end_of_term_id;
    p6_a38 := ddx_lrtv_rec.orig_rate_set_id;


    p8_a0 := ddx_lrvv_rec.rate_set_version_id;
    p8_a1 := ddx_lrvv_rec.object_version_number;
    p8_a2 := ddx_lrvv_rec.arrears_yn;
    p8_a3 := ddx_lrvv_rec.effective_from_date;
    p8_a4 := ddx_lrvv_rec.effective_to_date;
    p8_a5 := ddx_lrvv_rec.rate_set_id;
    p8_a6 := ddx_lrvv_rec.end_of_term_ver_id;
    p8_a7 := ddx_lrvv_rec.std_rate_tmpl_ver_id;
    p8_a8 := ddx_lrvv_rec.adj_mat_version_id;
    p8_a9 := ddx_lrvv_rec.version_number;
    p8_a10 := ddx_lrvv_rec.lrs_rate;
    p8_a11 := ddx_lrvv_rec.rate_tolerance;
    p8_a12 := ddx_lrvv_rec.residual_tolerance;
    p8_a13 := ddx_lrvv_rec.deferred_pmts;
    p8_a14 := ddx_lrvv_rec.advance_pmts;
    p8_a15 := ddx_lrvv_rec.sts_code;
    p8_a16 := ddx_lrvv_rec.created_by;
    p8_a17 := ddx_lrvv_rec.creation_date;
    p8_a18 := ddx_lrvv_rec.last_updated_by;
    p8_a19 := ddx_lrvv_rec.last_update_date;
    p8_a20 := ddx_lrvv_rec.last_update_login;
    p8_a21 := ddx_lrvv_rec.attribute_category;
    p8_a22 := ddx_lrvv_rec.attribute1;
    p8_a23 := ddx_lrvv_rec.attribute2;
    p8_a24 := ddx_lrvv_rec.attribute3;
    p8_a25 := ddx_lrvv_rec.attribute4;
    p8_a26 := ddx_lrvv_rec.attribute5;
    p8_a27 := ddx_lrvv_rec.attribute6;
    p8_a28 := ddx_lrvv_rec.attribute7;
    p8_a29 := ddx_lrvv_rec.attribute8;
    p8_a30 := ddx_lrvv_rec.attribute9;
    p8_a31 := ddx_lrvv_rec.attribute10;
    p8_a32 := ddx_lrvv_rec.attribute11;
    p8_a33 := ddx_lrvv_rec.attribute12;
    p8_a34 := ddx_lrvv_rec.attribute13;
    p8_a35 := ddx_lrvv_rec.attribute14;
    p8_a36 := ddx_lrvv_rec.attribute15;
    p8_a37 := ddx_lrvv_rec.standard_rate;
  end;

  procedure create_lrs_gen_lrf(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  DATE
    , p5_a9  DATE
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  NUMBER
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  DATE
    , p5_a16  NUMBER
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
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  VARCHAR2
    , p5_a34  NUMBER
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  NUMBER
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
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  DATE
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  DATE
    , p7_a18  NUMBER
    , p7_a19  DATE
    , p7_a20  NUMBER
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  NUMBER
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  DATE
    , p8_a4 out nocopy  DATE
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  NUMBER
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  NUMBER
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  NUMBER
    , p8_a14 out nocopy  NUMBER
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  NUMBER
    , p8_a17 out nocopy  DATE
    , p8_a18 out nocopy  NUMBER
    , p8_a19 out nocopy  DATE
    , p8_a20 out nocopy  NUMBER
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  VARCHAR2
    , p8_a24 out nocopy  VARCHAR2
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  VARCHAR2
    , p8_a27 out nocopy  VARCHAR2
    , p8_a28 out nocopy  VARCHAR2
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  VARCHAR2
    , p8_a31 out nocopy  VARCHAR2
    , p8_a32 out nocopy  VARCHAR2
    , p8_a33 out nocopy  VARCHAR2
    , p8_a34 out nocopy  VARCHAR2
    , p8_a35 out nocopy  VARCHAR2
    , p8_a36 out nocopy  VARCHAR2
    , p8_a37 out nocopy  NUMBER
  )

  as
    ddp_lrtv_rec okl_lease_rate_sets_pvt.lrtv_rec_type;
    ddx_lrtv_rec okl_lease_rate_sets_pvt.lrtv_rec_type;
    ddp_lrvv_rec okl_lease_rate_sets_pvt.okl_lrvv_rec;
    ddx_lrvv_rec okl_lease_rate_sets_pvt.okl_lrvv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lrtv_rec.id := p5_a0;
    ddp_lrtv_rec.object_version_number := p5_a1;
    ddp_lrtv_rec.sfwt_flag := p5_a2;
    ddp_lrtv_rec.try_id := p5_a3;
    ddp_lrtv_rec.pdt_id := p5_a4;
    ddp_lrtv_rec.rate := p5_a5;
    ddp_lrtv_rec.frq_code := p5_a6;
    ddp_lrtv_rec.arrears_yn := p5_a7;
    ddp_lrtv_rec.start_date := p5_a8;
    ddp_lrtv_rec.end_date := p5_a9;
    ddp_lrtv_rec.name := p5_a10;
    ddp_lrtv_rec.description := p5_a11;
    ddp_lrtv_rec.created_by := p5_a12;
    ddp_lrtv_rec.creation_date := p5_a13;
    ddp_lrtv_rec.last_updated_by := p5_a14;
    ddp_lrtv_rec.last_update_date := p5_a15;
    ddp_lrtv_rec.last_update_login := p5_a16;
    ddp_lrtv_rec.attribute_category := p5_a17;
    ddp_lrtv_rec.attribute1 := p5_a18;
    ddp_lrtv_rec.attribute2 := p5_a19;
    ddp_lrtv_rec.attribute3 := p5_a20;
    ddp_lrtv_rec.attribute4 := p5_a21;
    ddp_lrtv_rec.attribute5 := p5_a22;
    ddp_lrtv_rec.attribute6 := p5_a23;
    ddp_lrtv_rec.attribute7 := p5_a24;
    ddp_lrtv_rec.attribute8 := p5_a25;
    ddp_lrtv_rec.attribute9 := p5_a26;
    ddp_lrtv_rec.attribute10 := p5_a27;
    ddp_lrtv_rec.attribute11 := p5_a28;
    ddp_lrtv_rec.attribute12 := p5_a29;
    ddp_lrtv_rec.attribute13 := p5_a30;
    ddp_lrtv_rec.attribute14 := p5_a31;
    ddp_lrtv_rec.attribute15 := p5_a32;
    ddp_lrtv_rec.sts_code := p5_a33;
    ddp_lrtv_rec.org_id := p5_a34;
    ddp_lrtv_rec.currency_code := p5_a35;
    ddp_lrtv_rec.lrs_type_code := p5_a36;
    ddp_lrtv_rec.end_of_term_id := p5_a37;
    ddp_lrtv_rec.orig_rate_set_id := p5_a38;


    ddp_lrvv_rec.rate_set_version_id := p7_a0;
    ddp_lrvv_rec.object_version_number := p7_a1;
    ddp_lrvv_rec.arrears_yn := p7_a2;
    ddp_lrvv_rec.effective_from_date := p7_a3;
    ddp_lrvv_rec.effective_to_date := p7_a4;
    ddp_lrvv_rec.rate_set_id := p7_a5;
    ddp_lrvv_rec.end_of_term_ver_id := p7_a6;
    ddp_lrvv_rec.std_rate_tmpl_ver_id := p7_a7;
    ddp_lrvv_rec.adj_mat_version_id := p7_a8;
    ddp_lrvv_rec.version_number := p7_a9;
    ddp_lrvv_rec.lrs_rate := p7_a10;
    ddp_lrvv_rec.rate_tolerance := p7_a11;
    ddp_lrvv_rec.residual_tolerance := p7_a12;
    ddp_lrvv_rec.deferred_pmts := p7_a13;
    ddp_lrvv_rec.advance_pmts := p7_a14;
    ddp_lrvv_rec.sts_code := p7_a15;
    ddp_lrvv_rec.created_by := p7_a16;
    ddp_lrvv_rec.creation_date := p7_a17;
    ddp_lrvv_rec.last_updated_by := p7_a18;
    ddp_lrvv_rec.last_update_date := p7_a19;
    ddp_lrvv_rec.last_update_login := p7_a20;
    ddp_lrvv_rec.attribute_category := p7_a21;
    ddp_lrvv_rec.attribute1 := p7_a22;
    ddp_lrvv_rec.attribute2 := p7_a23;
    ddp_lrvv_rec.attribute3 := p7_a24;
    ddp_lrvv_rec.attribute4 := p7_a25;
    ddp_lrvv_rec.attribute5 := p7_a26;
    ddp_lrvv_rec.attribute6 := p7_a27;
    ddp_lrvv_rec.attribute7 := p7_a28;
    ddp_lrvv_rec.attribute8 := p7_a29;
    ddp_lrvv_rec.attribute9 := p7_a30;
    ddp_lrvv_rec.attribute10 := p7_a31;
    ddp_lrvv_rec.attribute11 := p7_a32;
    ddp_lrvv_rec.attribute12 := p7_a33;
    ddp_lrvv_rec.attribute13 := p7_a34;
    ddp_lrvv_rec.attribute14 := p7_a35;
    ddp_lrvv_rec.attribute15 := p7_a36;
    ddp_lrvv_rec.standard_rate := p7_a37;


    -- here's the delegated call to the old PL/SQL routine
    okl_lease_rate_sets_pvt.create_lrs_gen_lrf(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lrtv_rec,
      ddx_lrtv_rec,
      ddp_lrvv_rec,
      ddx_lrvv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lrtv_rec.id;
    p6_a1 := ddx_lrtv_rec.object_version_number;
    p6_a2 := ddx_lrtv_rec.sfwt_flag;
    p6_a3 := ddx_lrtv_rec.try_id;
    p6_a4 := ddx_lrtv_rec.pdt_id;
    p6_a5 := ddx_lrtv_rec.rate;
    p6_a6 := ddx_lrtv_rec.frq_code;
    p6_a7 := ddx_lrtv_rec.arrears_yn;
    p6_a8 := ddx_lrtv_rec.start_date;
    p6_a9 := ddx_lrtv_rec.end_date;
    p6_a10 := ddx_lrtv_rec.name;
    p6_a11 := ddx_lrtv_rec.description;
    p6_a12 := ddx_lrtv_rec.created_by;
    p6_a13 := ddx_lrtv_rec.creation_date;
    p6_a14 := ddx_lrtv_rec.last_updated_by;
    p6_a15 := ddx_lrtv_rec.last_update_date;
    p6_a16 := ddx_lrtv_rec.last_update_login;
    p6_a17 := ddx_lrtv_rec.attribute_category;
    p6_a18 := ddx_lrtv_rec.attribute1;
    p6_a19 := ddx_lrtv_rec.attribute2;
    p6_a20 := ddx_lrtv_rec.attribute3;
    p6_a21 := ddx_lrtv_rec.attribute4;
    p6_a22 := ddx_lrtv_rec.attribute5;
    p6_a23 := ddx_lrtv_rec.attribute6;
    p6_a24 := ddx_lrtv_rec.attribute7;
    p6_a25 := ddx_lrtv_rec.attribute8;
    p6_a26 := ddx_lrtv_rec.attribute9;
    p6_a27 := ddx_lrtv_rec.attribute10;
    p6_a28 := ddx_lrtv_rec.attribute11;
    p6_a29 := ddx_lrtv_rec.attribute12;
    p6_a30 := ddx_lrtv_rec.attribute13;
    p6_a31 := ddx_lrtv_rec.attribute14;
    p6_a32 := ddx_lrtv_rec.attribute15;
    p6_a33 := ddx_lrtv_rec.sts_code;
    p6_a34 := ddx_lrtv_rec.org_id;
    p6_a35 := ddx_lrtv_rec.currency_code;
    p6_a36 := ddx_lrtv_rec.lrs_type_code;
    p6_a37 := ddx_lrtv_rec.end_of_term_id;
    p6_a38 := ddx_lrtv_rec.orig_rate_set_id;


    p8_a0 := ddx_lrvv_rec.rate_set_version_id;
    p8_a1 := ddx_lrvv_rec.object_version_number;
    p8_a2 := ddx_lrvv_rec.arrears_yn;
    p8_a3 := ddx_lrvv_rec.effective_from_date;
    p8_a4 := ddx_lrvv_rec.effective_to_date;
    p8_a5 := ddx_lrvv_rec.rate_set_id;
    p8_a6 := ddx_lrvv_rec.end_of_term_ver_id;
    p8_a7 := ddx_lrvv_rec.std_rate_tmpl_ver_id;
    p8_a8 := ddx_lrvv_rec.adj_mat_version_id;
    p8_a9 := ddx_lrvv_rec.version_number;
    p8_a10 := ddx_lrvv_rec.lrs_rate;
    p8_a11 := ddx_lrvv_rec.rate_tolerance;
    p8_a12 := ddx_lrvv_rec.residual_tolerance;
    p8_a13 := ddx_lrvv_rec.deferred_pmts;
    p8_a14 := ddx_lrvv_rec.advance_pmts;
    p8_a15 := ddx_lrvv_rec.sts_code;
    p8_a16 := ddx_lrvv_rec.created_by;
    p8_a17 := ddx_lrvv_rec.creation_date;
    p8_a18 := ddx_lrvv_rec.last_updated_by;
    p8_a19 := ddx_lrvv_rec.last_update_date;
    p8_a20 := ddx_lrvv_rec.last_update_login;
    p8_a21 := ddx_lrvv_rec.attribute_category;
    p8_a22 := ddx_lrvv_rec.attribute1;
    p8_a23 := ddx_lrvv_rec.attribute2;
    p8_a24 := ddx_lrvv_rec.attribute3;
    p8_a25 := ddx_lrvv_rec.attribute4;
    p8_a26 := ddx_lrvv_rec.attribute5;
    p8_a27 := ddx_lrvv_rec.attribute6;
    p8_a28 := ddx_lrvv_rec.attribute7;
    p8_a29 := ddx_lrvv_rec.attribute8;
    p8_a30 := ddx_lrvv_rec.attribute9;
    p8_a31 := ddx_lrvv_rec.attribute10;
    p8_a32 := ddx_lrvv_rec.attribute11;
    p8_a33 := ddx_lrvv_rec.attribute12;
    p8_a34 := ddx_lrvv_rec.attribute13;
    p8_a35 := ddx_lrvv_rec.attribute14;
    p8_a36 := ddx_lrvv_rec.attribute15;
    p8_a37 := ddx_lrvv_rec.standard_rate;
  end;

  procedure update_lrs_gen_lrf(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  DATE
    , p5_a9  DATE
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  NUMBER
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  DATE
    , p5_a16  NUMBER
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
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  VARCHAR2
    , p5_a34  NUMBER
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  NUMBER
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
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  DATE
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  DATE
    , p7_a18  NUMBER
    , p7_a19  DATE
    , p7_a20  NUMBER
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  NUMBER
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  DATE
    , p8_a4 out nocopy  DATE
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  NUMBER
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  NUMBER
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  NUMBER
    , p8_a14 out nocopy  NUMBER
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  NUMBER
    , p8_a17 out nocopy  DATE
    , p8_a18 out nocopy  NUMBER
    , p8_a19 out nocopy  DATE
    , p8_a20 out nocopy  NUMBER
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  VARCHAR2
    , p8_a24 out nocopy  VARCHAR2
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  VARCHAR2
    , p8_a27 out nocopy  VARCHAR2
    , p8_a28 out nocopy  VARCHAR2
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  VARCHAR2
    , p8_a31 out nocopy  VARCHAR2
    , p8_a32 out nocopy  VARCHAR2
    , p8_a33 out nocopy  VARCHAR2
    , p8_a34 out nocopy  VARCHAR2
    , p8_a35 out nocopy  VARCHAR2
    , p8_a36 out nocopy  VARCHAR2
    , p8_a37 out nocopy  NUMBER
  )

  as
    ddp_lrtv_rec okl_lease_rate_sets_pvt.lrtv_rec_type;
    ddx_lrtv_rec okl_lease_rate_sets_pvt.lrtv_rec_type;
    ddp_lrvv_rec okl_lease_rate_sets_pvt.okl_lrvv_rec;
    ddx_lrvv_rec okl_lease_rate_sets_pvt.okl_lrvv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lrtv_rec.id := p5_a0;
    ddp_lrtv_rec.object_version_number := p5_a1;
    ddp_lrtv_rec.sfwt_flag := p5_a2;
    ddp_lrtv_rec.try_id := p5_a3;
    ddp_lrtv_rec.pdt_id := p5_a4;
    ddp_lrtv_rec.rate := p5_a5;
    ddp_lrtv_rec.frq_code := p5_a6;
    ddp_lrtv_rec.arrears_yn := p5_a7;
    ddp_lrtv_rec.start_date := p5_a8;
    ddp_lrtv_rec.end_date := p5_a9;
    ddp_lrtv_rec.name := p5_a10;
    ddp_lrtv_rec.description := p5_a11;
    ddp_lrtv_rec.created_by := p5_a12;
    ddp_lrtv_rec.creation_date := p5_a13;
    ddp_lrtv_rec.last_updated_by := p5_a14;
    ddp_lrtv_rec.last_update_date := p5_a15;
    ddp_lrtv_rec.last_update_login := p5_a16;
    ddp_lrtv_rec.attribute_category := p5_a17;
    ddp_lrtv_rec.attribute1 := p5_a18;
    ddp_lrtv_rec.attribute2 := p5_a19;
    ddp_lrtv_rec.attribute3 := p5_a20;
    ddp_lrtv_rec.attribute4 := p5_a21;
    ddp_lrtv_rec.attribute5 := p5_a22;
    ddp_lrtv_rec.attribute6 := p5_a23;
    ddp_lrtv_rec.attribute7 := p5_a24;
    ddp_lrtv_rec.attribute8 := p5_a25;
    ddp_lrtv_rec.attribute9 := p5_a26;
    ddp_lrtv_rec.attribute10 := p5_a27;
    ddp_lrtv_rec.attribute11 := p5_a28;
    ddp_lrtv_rec.attribute12 := p5_a29;
    ddp_lrtv_rec.attribute13 := p5_a30;
    ddp_lrtv_rec.attribute14 := p5_a31;
    ddp_lrtv_rec.attribute15 := p5_a32;
    ddp_lrtv_rec.sts_code := p5_a33;
    ddp_lrtv_rec.org_id := p5_a34;
    ddp_lrtv_rec.currency_code := p5_a35;
    ddp_lrtv_rec.lrs_type_code := p5_a36;
    ddp_lrtv_rec.end_of_term_id := p5_a37;
    ddp_lrtv_rec.orig_rate_set_id := p5_a38;


    ddp_lrvv_rec.rate_set_version_id := p7_a0;
    ddp_lrvv_rec.object_version_number := p7_a1;
    ddp_lrvv_rec.arrears_yn := p7_a2;
    ddp_lrvv_rec.effective_from_date := p7_a3;
    ddp_lrvv_rec.effective_to_date := p7_a4;
    ddp_lrvv_rec.rate_set_id := p7_a5;
    ddp_lrvv_rec.end_of_term_ver_id := p7_a6;
    ddp_lrvv_rec.std_rate_tmpl_ver_id := p7_a7;
    ddp_lrvv_rec.adj_mat_version_id := p7_a8;
    ddp_lrvv_rec.version_number := p7_a9;
    ddp_lrvv_rec.lrs_rate := p7_a10;
    ddp_lrvv_rec.rate_tolerance := p7_a11;
    ddp_lrvv_rec.residual_tolerance := p7_a12;
    ddp_lrvv_rec.deferred_pmts := p7_a13;
    ddp_lrvv_rec.advance_pmts := p7_a14;
    ddp_lrvv_rec.sts_code := p7_a15;
    ddp_lrvv_rec.created_by := p7_a16;
    ddp_lrvv_rec.creation_date := p7_a17;
    ddp_lrvv_rec.last_updated_by := p7_a18;
    ddp_lrvv_rec.last_update_date := p7_a19;
    ddp_lrvv_rec.last_update_login := p7_a20;
    ddp_lrvv_rec.attribute_category := p7_a21;
    ddp_lrvv_rec.attribute1 := p7_a22;
    ddp_lrvv_rec.attribute2 := p7_a23;
    ddp_lrvv_rec.attribute3 := p7_a24;
    ddp_lrvv_rec.attribute4 := p7_a25;
    ddp_lrvv_rec.attribute5 := p7_a26;
    ddp_lrvv_rec.attribute6 := p7_a27;
    ddp_lrvv_rec.attribute7 := p7_a28;
    ddp_lrvv_rec.attribute8 := p7_a29;
    ddp_lrvv_rec.attribute9 := p7_a30;
    ddp_lrvv_rec.attribute10 := p7_a31;
    ddp_lrvv_rec.attribute11 := p7_a32;
    ddp_lrvv_rec.attribute12 := p7_a33;
    ddp_lrvv_rec.attribute13 := p7_a34;
    ddp_lrvv_rec.attribute14 := p7_a35;
    ddp_lrvv_rec.attribute15 := p7_a36;
    ddp_lrvv_rec.standard_rate := p7_a37;


    -- here's the delegated call to the old PL/SQL routine
    okl_lease_rate_sets_pvt.update_lrs_gen_lrf(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lrtv_rec,
      ddx_lrtv_rec,
      ddp_lrvv_rec,
      ddx_lrvv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lrtv_rec.id;
    p6_a1 := ddx_lrtv_rec.object_version_number;
    p6_a2 := ddx_lrtv_rec.sfwt_flag;
    p6_a3 := ddx_lrtv_rec.try_id;
    p6_a4 := ddx_lrtv_rec.pdt_id;
    p6_a5 := ddx_lrtv_rec.rate;
    p6_a6 := ddx_lrtv_rec.frq_code;
    p6_a7 := ddx_lrtv_rec.arrears_yn;
    p6_a8 := ddx_lrtv_rec.start_date;
    p6_a9 := ddx_lrtv_rec.end_date;
    p6_a10 := ddx_lrtv_rec.name;
    p6_a11 := ddx_lrtv_rec.description;
    p6_a12 := ddx_lrtv_rec.created_by;
    p6_a13 := ddx_lrtv_rec.creation_date;
    p6_a14 := ddx_lrtv_rec.last_updated_by;
    p6_a15 := ddx_lrtv_rec.last_update_date;
    p6_a16 := ddx_lrtv_rec.last_update_login;
    p6_a17 := ddx_lrtv_rec.attribute_category;
    p6_a18 := ddx_lrtv_rec.attribute1;
    p6_a19 := ddx_lrtv_rec.attribute2;
    p6_a20 := ddx_lrtv_rec.attribute3;
    p6_a21 := ddx_lrtv_rec.attribute4;
    p6_a22 := ddx_lrtv_rec.attribute5;
    p6_a23 := ddx_lrtv_rec.attribute6;
    p6_a24 := ddx_lrtv_rec.attribute7;
    p6_a25 := ddx_lrtv_rec.attribute8;
    p6_a26 := ddx_lrtv_rec.attribute9;
    p6_a27 := ddx_lrtv_rec.attribute10;
    p6_a28 := ddx_lrtv_rec.attribute11;
    p6_a29 := ddx_lrtv_rec.attribute12;
    p6_a30 := ddx_lrtv_rec.attribute13;
    p6_a31 := ddx_lrtv_rec.attribute14;
    p6_a32 := ddx_lrtv_rec.attribute15;
    p6_a33 := ddx_lrtv_rec.sts_code;
    p6_a34 := ddx_lrtv_rec.org_id;
    p6_a35 := ddx_lrtv_rec.currency_code;
    p6_a36 := ddx_lrtv_rec.lrs_type_code;
    p6_a37 := ddx_lrtv_rec.end_of_term_id;
    p6_a38 := ddx_lrtv_rec.orig_rate_set_id;


    p8_a0 := ddx_lrvv_rec.rate_set_version_id;
    p8_a1 := ddx_lrvv_rec.object_version_number;
    p8_a2 := ddx_lrvv_rec.arrears_yn;
    p8_a3 := ddx_lrvv_rec.effective_from_date;
    p8_a4 := ddx_lrvv_rec.effective_to_date;
    p8_a5 := ddx_lrvv_rec.rate_set_id;
    p8_a6 := ddx_lrvv_rec.end_of_term_ver_id;
    p8_a7 := ddx_lrvv_rec.std_rate_tmpl_ver_id;
    p8_a8 := ddx_lrvv_rec.adj_mat_version_id;
    p8_a9 := ddx_lrvv_rec.version_number;
    p8_a10 := ddx_lrvv_rec.lrs_rate;
    p8_a11 := ddx_lrvv_rec.rate_tolerance;
    p8_a12 := ddx_lrvv_rec.residual_tolerance;
    p8_a13 := ddx_lrvv_rec.deferred_pmts;
    p8_a14 := ddx_lrvv_rec.advance_pmts;
    p8_a15 := ddx_lrvv_rec.sts_code;
    p8_a16 := ddx_lrvv_rec.created_by;
    p8_a17 := ddx_lrvv_rec.creation_date;
    p8_a18 := ddx_lrvv_rec.last_updated_by;
    p8_a19 := ddx_lrvv_rec.last_update_date;
    p8_a20 := ddx_lrvv_rec.last_update_login;
    p8_a21 := ddx_lrvv_rec.attribute_category;
    p8_a22 := ddx_lrvv_rec.attribute1;
    p8_a23 := ddx_lrvv_rec.attribute2;
    p8_a24 := ddx_lrvv_rec.attribute3;
    p8_a25 := ddx_lrvv_rec.attribute4;
    p8_a26 := ddx_lrvv_rec.attribute5;
    p8_a27 := ddx_lrvv_rec.attribute6;
    p8_a28 := ddx_lrvv_rec.attribute7;
    p8_a29 := ddx_lrvv_rec.attribute8;
    p8_a30 := ddx_lrvv_rec.attribute9;
    p8_a31 := ddx_lrvv_rec.attribute10;
    p8_a32 := ddx_lrvv_rec.attribute11;
    p8_a33 := ddx_lrvv_rec.attribute12;
    p8_a34 := ddx_lrvv_rec.attribute13;
    p8_a35 := ddx_lrvv_rec.attribute14;
    p8_a36 := ddx_lrvv_rec.attribute15;
    p8_a37 := ddx_lrvv_rec.standard_rate;
  end;

  procedure version_lrs_gen_lrf(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  DATE
    , p5_a9  DATE
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  NUMBER
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  DATE
    , p5_a16  NUMBER
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
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  VARCHAR2
    , p5_a34  NUMBER
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  NUMBER
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
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  DATE
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  DATE
    , p7_a18  NUMBER
    , p7_a19  DATE
    , p7_a20  NUMBER
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  NUMBER
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  DATE
    , p8_a4 out nocopy  DATE
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  NUMBER
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  NUMBER
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  NUMBER
    , p8_a14 out nocopy  NUMBER
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  NUMBER
    , p8_a17 out nocopy  DATE
    , p8_a18 out nocopy  NUMBER
    , p8_a19 out nocopy  DATE
    , p8_a20 out nocopy  NUMBER
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  VARCHAR2
    , p8_a24 out nocopy  VARCHAR2
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  VARCHAR2
    , p8_a27 out nocopy  VARCHAR2
    , p8_a28 out nocopy  VARCHAR2
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  VARCHAR2
    , p8_a31 out nocopy  VARCHAR2
    , p8_a32 out nocopy  VARCHAR2
    , p8_a33 out nocopy  VARCHAR2
    , p8_a34 out nocopy  VARCHAR2
    , p8_a35 out nocopy  VARCHAR2
    , p8_a36 out nocopy  VARCHAR2
    , p8_a37 out nocopy  NUMBER
  )

  as
    ddp_lrtv_rec okl_lease_rate_sets_pvt.lrtv_rec_type;
    ddx_lrtv_rec okl_lease_rate_sets_pvt.lrtv_rec_type;
    ddp_lrvv_rec okl_lease_rate_sets_pvt.okl_lrvv_rec;
    ddx_lrvv_rec okl_lease_rate_sets_pvt.okl_lrvv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lrtv_rec.id := p5_a0;
    ddp_lrtv_rec.object_version_number := p5_a1;
    ddp_lrtv_rec.sfwt_flag := p5_a2;
    ddp_lrtv_rec.try_id := p5_a3;
    ddp_lrtv_rec.pdt_id := p5_a4;
    ddp_lrtv_rec.rate := p5_a5;
    ddp_lrtv_rec.frq_code := p5_a6;
    ddp_lrtv_rec.arrears_yn := p5_a7;
    ddp_lrtv_rec.start_date := p5_a8;
    ddp_lrtv_rec.end_date := p5_a9;
    ddp_lrtv_rec.name := p5_a10;
    ddp_lrtv_rec.description := p5_a11;
    ddp_lrtv_rec.created_by := p5_a12;
    ddp_lrtv_rec.creation_date := p5_a13;
    ddp_lrtv_rec.last_updated_by := p5_a14;
    ddp_lrtv_rec.last_update_date := p5_a15;
    ddp_lrtv_rec.last_update_login := p5_a16;
    ddp_lrtv_rec.attribute_category := p5_a17;
    ddp_lrtv_rec.attribute1 := p5_a18;
    ddp_lrtv_rec.attribute2 := p5_a19;
    ddp_lrtv_rec.attribute3 := p5_a20;
    ddp_lrtv_rec.attribute4 := p5_a21;
    ddp_lrtv_rec.attribute5 := p5_a22;
    ddp_lrtv_rec.attribute6 := p5_a23;
    ddp_lrtv_rec.attribute7 := p5_a24;
    ddp_lrtv_rec.attribute8 := p5_a25;
    ddp_lrtv_rec.attribute9 := p5_a26;
    ddp_lrtv_rec.attribute10 := p5_a27;
    ddp_lrtv_rec.attribute11 := p5_a28;
    ddp_lrtv_rec.attribute12 := p5_a29;
    ddp_lrtv_rec.attribute13 := p5_a30;
    ddp_lrtv_rec.attribute14 := p5_a31;
    ddp_lrtv_rec.attribute15 := p5_a32;
    ddp_lrtv_rec.sts_code := p5_a33;
    ddp_lrtv_rec.org_id := p5_a34;
    ddp_lrtv_rec.currency_code := p5_a35;
    ddp_lrtv_rec.lrs_type_code := p5_a36;
    ddp_lrtv_rec.end_of_term_id := p5_a37;
    ddp_lrtv_rec.orig_rate_set_id := p5_a38;


    ddp_lrvv_rec.rate_set_version_id := p7_a0;
    ddp_lrvv_rec.object_version_number := p7_a1;
    ddp_lrvv_rec.arrears_yn := p7_a2;
    ddp_lrvv_rec.effective_from_date := p7_a3;
    ddp_lrvv_rec.effective_to_date := p7_a4;
    ddp_lrvv_rec.rate_set_id := p7_a5;
    ddp_lrvv_rec.end_of_term_ver_id := p7_a6;
    ddp_lrvv_rec.std_rate_tmpl_ver_id := p7_a7;
    ddp_lrvv_rec.adj_mat_version_id := p7_a8;
    ddp_lrvv_rec.version_number := p7_a9;
    ddp_lrvv_rec.lrs_rate := p7_a10;
    ddp_lrvv_rec.rate_tolerance := p7_a11;
    ddp_lrvv_rec.residual_tolerance := p7_a12;
    ddp_lrvv_rec.deferred_pmts := p7_a13;
    ddp_lrvv_rec.advance_pmts := p7_a14;
    ddp_lrvv_rec.sts_code := p7_a15;
    ddp_lrvv_rec.created_by := p7_a16;
    ddp_lrvv_rec.creation_date := p7_a17;
    ddp_lrvv_rec.last_updated_by := p7_a18;
    ddp_lrvv_rec.last_update_date := p7_a19;
    ddp_lrvv_rec.last_update_login := p7_a20;
    ddp_lrvv_rec.attribute_category := p7_a21;
    ddp_lrvv_rec.attribute1 := p7_a22;
    ddp_lrvv_rec.attribute2 := p7_a23;
    ddp_lrvv_rec.attribute3 := p7_a24;
    ddp_lrvv_rec.attribute4 := p7_a25;
    ddp_lrvv_rec.attribute5 := p7_a26;
    ddp_lrvv_rec.attribute6 := p7_a27;
    ddp_lrvv_rec.attribute7 := p7_a28;
    ddp_lrvv_rec.attribute8 := p7_a29;
    ddp_lrvv_rec.attribute9 := p7_a30;
    ddp_lrvv_rec.attribute10 := p7_a31;
    ddp_lrvv_rec.attribute11 := p7_a32;
    ddp_lrvv_rec.attribute12 := p7_a33;
    ddp_lrvv_rec.attribute13 := p7_a34;
    ddp_lrvv_rec.attribute14 := p7_a35;
    ddp_lrvv_rec.attribute15 := p7_a36;
    ddp_lrvv_rec.standard_rate := p7_a37;


    -- here's the delegated call to the old PL/SQL routine
    okl_lease_rate_sets_pvt.version_lrs_gen_lrf(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lrtv_rec,
      ddx_lrtv_rec,
      ddp_lrvv_rec,
      ddx_lrvv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lrtv_rec.id;
    p6_a1 := ddx_lrtv_rec.object_version_number;
    p6_a2 := ddx_lrtv_rec.sfwt_flag;
    p6_a3 := ddx_lrtv_rec.try_id;
    p6_a4 := ddx_lrtv_rec.pdt_id;
    p6_a5 := ddx_lrtv_rec.rate;
    p6_a6 := ddx_lrtv_rec.frq_code;
    p6_a7 := ddx_lrtv_rec.arrears_yn;
    p6_a8 := ddx_lrtv_rec.start_date;
    p6_a9 := ddx_lrtv_rec.end_date;
    p6_a10 := ddx_lrtv_rec.name;
    p6_a11 := ddx_lrtv_rec.description;
    p6_a12 := ddx_lrtv_rec.created_by;
    p6_a13 := ddx_lrtv_rec.creation_date;
    p6_a14 := ddx_lrtv_rec.last_updated_by;
    p6_a15 := ddx_lrtv_rec.last_update_date;
    p6_a16 := ddx_lrtv_rec.last_update_login;
    p6_a17 := ddx_lrtv_rec.attribute_category;
    p6_a18 := ddx_lrtv_rec.attribute1;
    p6_a19 := ddx_lrtv_rec.attribute2;
    p6_a20 := ddx_lrtv_rec.attribute3;
    p6_a21 := ddx_lrtv_rec.attribute4;
    p6_a22 := ddx_lrtv_rec.attribute5;
    p6_a23 := ddx_lrtv_rec.attribute6;
    p6_a24 := ddx_lrtv_rec.attribute7;
    p6_a25 := ddx_lrtv_rec.attribute8;
    p6_a26 := ddx_lrtv_rec.attribute9;
    p6_a27 := ddx_lrtv_rec.attribute10;
    p6_a28 := ddx_lrtv_rec.attribute11;
    p6_a29 := ddx_lrtv_rec.attribute12;
    p6_a30 := ddx_lrtv_rec.attribute13;
    p6_a31 := ddx_lrtv_rec.attribute14;
    p6_a32 := ddx_lrtv_rec.attribute15;
    p6_a33 := ddx_lrtv_rec.sts_code;
    p6_a34 := ddx_lrtv_rec.org_id;
    p6_a35 := ddx_lrtv_rec.currency_code;
    p6_a36 := ddx_lrtv_rec.lrs_type_code;
    p6_a37 := ddx_lrtv_rec.end_of_term_id;
    p6_a38 := ddx_lrtv_rec.orig_rate_set_id;


    p8_a0 := ddx_lrvv_rec.rate_set_version_id;
    p8_a1 := ddx_lrvv_rec.object_version_number;
    p8_a2 := ddx_lrvv_rec.arrears_yn;
    p8_a3 := ddx_lrvv_rec.effective_from_date;
    p8_a4 := ddx_lrvv_rec.effective_to_date;
    p8_a5 := ddx_lrvv_rec.rate_set_id;
    p8_a6 := ddx_lrvv_rec.end_of_term_ver_id;
    p8_a7 := ddx_lrvv_rec.std_rate_tmpl_ver_id;
    p8_a8 := ddx_lrvv_rec.adj_mat_version_id;
    p8_a9 := ddx_lrvv_rec.version_number;
    p8_a10 := ddx_lrvv_rec.lrs_rate;
    p8_a11 := ddx_lrvv_rec.rate_tolerance;
    p8_a12 := ddx_lrvv_rec.residual_tolerance;
    p8_a13 := ddx_lrvv_rec.deferred_pmts;
    p8_a14 := ddx_lrvv_rec.advance_pmts;
    p8_a15 := ddx_lrvv_rec.sts_code;
    p8_a16 := ddx_lrvv_rec.created_by;
    p8_a17 := ddx_lrvv_rec.creation_date;
    p8_a18 := ddx_lrvv_rec.last_updated_by;
    p8_a19 := ddx_lrvv_rec.last_update_date;
    p8_a20 := ddx_lrvv_rec.last_update_login;
    p8_a21 := ddx_lrvv_rec.attribute_category;
    p8_a22 := ddx_lrvv_rec.attribute1;
    p8_a23 := ddx_lrvv_rec.attribute2;
    p8_a24 := ddx_lrvv_rec.attribute3;
    p8_a25 := ddx_lrvv_rec.attribute4;
    p8_a26 := ddx_lrvv_rec.attribute5;
    p8_a27 := ddx_lrvv_rec.attribute6;
    p8_a28 := ddx_lrvv_rec.attribute7;
    p8_a29 := ddx_lrvv_rec.attribute8;
    p8_a30 := ddx_lrvv_rec.attribute9;
    p8_a31 := ddx_lrvv_rec.attribute10;
    p8_a32 := ddx_lrvv_rec.attribute11;
    p8_a33 := ddx_lrvv_rec.attribute12;
    p8_a34 := ddx_lrvv_rec.attribute13;
    p8_a35 := ddx_lrvv_rec.attribute14;
    p8_a36 := ddx_lrvv_rec.attribute15;
    p8_a37 := ddx_lrvv_rec.standard_rate;
  end;

  procedure create_lrs_gen_lrf_submit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  DATE
    , p5_a9  DATE
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  NUMBER
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  DATE
    , p5_a16  NUMBER
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
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  VARCHAR2
    , p5_a34  NUMBER
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  NUMBER
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
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  DATE
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  DATE
    , p7_a18  NUMBER
    , p7_a19  DATE
    , p7_a20  NUMBER
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  NUMBER
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  DATE
    , p8_a4 out nocopy  DATE
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  NUMBER
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  NUMBER
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  NUMBER
    , p8_a14 out nocopy  NUMBER
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  NUMBER
    , p8_a17 out nocopy  DATE
    , p8_a18 out nocopy  NUMBER
    , p8_a19 out nocopy  DATE
    , p8_a20 out nocopy  NUMBER
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  VARCHAR2
    , p8_a24 out nocopy  VARCHAR2
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  VARCHAR2
    , p8_a27 out nocopy  VARCHAR2
    , p8_a28 out nocopy  VARCHAR2
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  VARCHAR2
    , p8_a31 out nocopy  VARCHAR2
    , p8_a32 out nocopy  VARCHAR2
    , p8_a33 out nocopy  VARCHAR2
    , p8_a34 out nocopy  VARCHAR2
    , p8_a35 out nocopy  VARCHAR2
    , p8_a36 out nocopy  VARCHAR2
    , p8_a37 out nocopy  NUMBER
  )

  as
    ddp_lrtv_rec okl_lease_rate_sets_pvt.lrtv_rec_type;
    ddx_lrtv_rec okl_lease_rate_sets_pvt.lrtv_rec_type;
    ddp_lrvv_rec okl_lease_rate_sets_pvt.okl_lrvv_rec;
    ddx_lrvv_rec okl_lease_rate_sets_pvt.okl_lrvv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lrtv_rec.id := p5_a0;
    ddp_lrtv_rec.object_version_number := p5_a1;
    ddp_lrtv_rec.sfwt_flag := p5_a2;
    ddp_lrtv_rec.try_id := p5_a3;
    ddp_lrtv_rec.pdt_id := p5_a4;
    ddp_lrtv_rec.rate := p5_a5;
    ddp_lrtv_rec.frq_code := p5_a6;
    ddp_lrtv_rec.arrears_yn := p5_a7;
    ddp_lrtv_rec.start_date := p5_a8;
    ddp_lrtv_rec.end_date := p5_a9;
    ddp_lrtv_rec.name := p5_a10;
    ddp_lrtv_rec.description := p5_a11;
    ddp_lrtv_rec.created_by := p5_a12;
    ddp_lrtv_rec.creation_date := p5_a13;
    ddp_lrtv_rec.last_updated_by := p5_a14;
    ddp_lrtv_rec.last_update_date := p5_a15;
    ddp_lrtv_rec.last_update_login := p5_a16;
    ddp_lrtv_rec.attribute_category := p5_a17;
    ddp_lrtv_rec.attribute1 := p5_a18;
    ddp_lrtv_rec.attribute2 := p5_a19;
    ddp_lrtv_rec.attribute3 := p5_a20;
    ddp_lrtv_rec.attribute4 := p5_a21;
    ddp_lrtv_rec.attribute5 := p5_a22;
    ddp_lrtv_rec.attribute6 := p5_a23;
    ddp_lrtv_rec.attribute7 := p5_a24;
    ddp_lrtv_rec.attribute8 := p5_a25;
    ddp_lrtv_rec.attribute9 := p5_a26;
    ddp_lrtv_rec.attribute10 := p5_a27;
    ddp_lrtv_rec.attribute11 := p5_a28;
    ddp_lrtv_rec.attribute12 := p5_a29;
    ddp_lrtv_rec.attribute13 := p5_a30;
    ddp_lrtv_rec.attribute14 := p5_a31;
    ddp_lrtv_rec.attribute15 := p5_a32;
    ddp_lrtv_rec.sts_code := p5_a33;
    ddp_lrtv_rec.org_id := p5_a34;
    ddp_lrtv_rec.currency_code := p5_a35;
    ddp_lrtv_rec.lrs_type_code := p5_a36;
    ddp_lrtv_rec.end_of_term_id := p5_a37;
    ddp_lrtv_rec.orig_rate_set_id := p5_a38;


    ddp_lrvv_rec.rate_set_version_id := p7_a0;
    ddp_lrvv_rec.object_version_number := p7_a1;
    ddp_lrvv_rec.arrears_yn := p7_a2;
    ddp_lrvv_rec.effective_from_date := p7_a3;
    ddp_lrvv_rec.effective_to_date := p7_a4;
    ddp_lrvv_rec.rate_set_id := p7_a5;
    ddp_lrvv_rec.end_of_term_ver_id := p7_a6;
    ddp_lrvv_rec.std_rate_tmpl_ver_id := p7_a7;
    ddp_lrvv_rec.adj_mat_version_id := p7_a8;
    ddp_lrvv_rec.version_number := p7_a9;
    ddp_lrvv_rec.lrs_rate := p7_a10;
    ddp_lrvv_rec.rate_tolerance := p7_a11;
    ddp_lrvv_rec.residual_tolerance := p7_a12;
    ddp_lrvv_rec.deferred_pmts := p7_a13;
    ddp_lrvv_rec.advance_pmts := p7_a14;
    ddp_lrvv_rec.sts_code := p7_a15;
    ddp_lrvv_rec.created_by := p7_a16;
    ddp_lrvv_rec.creation_date := p7_a17;
    ddp_lrvv_rec.last_updated_by := p7_a18;
    ddp_lrvv_rec.last_update_date := p7_a19;
    ddp_lrvv_rec.last_update_login := p7_a20;
    ddp_lrvv_rec.attribute_category := p7_a21;
    ddp_lrvv_rec.attribute1 := p7_a22;
    ddp_lrvv_rec.attribute2 := p7_a23;
    ddp_lrvv_rec.attribute3 := p7_a24;
    ddp_lrvv_rec.attribute4 := p7_a25;
    ddp_lrvv_rec.attribute5 := p7_a26;
    ddp_lrvv_rec.attribute6 := p7_a27;
    ddp_lrvv_rec.attribute7 := p7_a28;
    ddp_lrvv_rec.attribute8 := p7_a29;
    ddp_lrvv_rec.attribute9 := p7_a30;
    ddp_lrvv_rec.attribute10 := p7_a31;
    ddp_lrvv_rec.attribute11 := p7_a32;
    ddp_lrvv_rec.attribute12 := p7_a33;
    ddp_lrvv_rec.attribute13 := p7_a34;
    ddp_lrvv_rec.attribute14 := p7_a35;
    ddp_lrvv_rec.attribute15 := p7_a36;
    ddp_lrvv_rec.standard_rate := p7_a37;


    -- here's the delegated call to the old PL/SQL routine
    okl_lease_rate_sets_pvt.create_lrs_gen_lrf_submit(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lrtv_rec,
      ddx_lrtv_rec,
      ddp_lrvv_rec,
      ddx_lrvv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lrtv_rec.id;
    p6_a1 := ddx_lrtv_rec.object_version_number;
    p6_a2 := ddx_lrtv_rec.sfwt_flag;
    p6_a3 := ddx_lrtv_rec.try_id;
    p6_a4 := ddx_lrtv_rec.pdt_id;
    p6_a5 := ddx_lrtv_rec.rate;
    p6_a6 := ddx_lrtv_rec.frq_code;
    p6_a7 := ddx_lrtv_rec.arrears_yn;
    p6_a8 := ddx_lrtv_rec.start_date;
    p6_a9 := ddx_lrtv_rec.end_date;
    p6_a10 := ddx_lrtv_rec.name;
    p6_a11 := ddx_lrtv_rec.description;
    p6_a12 := ddx_lrtv_rec.created_by;
    p6_a13 := ddx_lrtv_rec.creation_date;
    p6_a14 := ddx_lrtv_rec.last_updated_by;
    p6_a15 := ddx_lrtv_rec.last_update_date;
    p6_a16 := ddx_lrtv_rec.last_update_login;
    p6_a17 := ddx_lrtv_rec.attribute_category;
    p6_a18 := ddx_lrtv_rec.attribute1;
    p6_a19 := ddx_lrtv_rec.attribute2;
    p6_a20 := ddx_lrtv_rec.attribute3;
    p6_a21 := ddx_lrtv_rec.attribute4;
    p6_a22 := ddx_lrtv_rec.attribute5;
    p6_a23 := ddx_lrtv_rec.attribute6;
    p6_a24 := ddx_lrtv_rec.attribute7;
    p6_a25 := ddx_lrtv_rec.attribute8;
    p6_a26 := ddx_lrtv_rec.attribute9;
    p6_a27 := ddx_lrtv_rec.attribute10;
    p6_a28 := ddx_lrtv_rec.attribute11;
    p6_a29 := ddx_lrtv_rec.attribute12;
    p6_a30 := ddx_lrtv_rec.attribute13;
    p6_a31 := ddx_lrtv_rec.attribute14;
    p6_a32 := ddx_lrtv_rec.attribute15;
    p6_a33 := ddx_lrtv_rec.sts_code;
    p6_a34 := ddx_lrtv_rec.org_id;
    p6_a35 := ddx_lrtv_rec.currency_code;
    p6_a36 := ddx_lrtv_rec.lrs_type_code;
    p6_a37 := ddx_lrtv_rec.end_of_term_id;
    p6_a38 := ddx_lrtv_rec.orig_rate_set_id;


    p8_a0 := ddx_lrvv_rec.rate_set_version_id;
    p8_a1 := ddx_lrvv_rec.object_version_number;
    p8_a2 := ddx_lrvv_rec.arrears_yn;
    p8_a3 := ddx_lrvv_rec.effective_from_date;
    p8_a4 := ddx_lrvv_rec.effective_to_date;
    p8_a5 := ddx_lrvv_rec.rate_set_id;
    p8_a6 := ddx_lrvv_rec.end_of_term_ver_id;
    p8_a7 := ddx_lrvv_rec.std_rate_tmpl_ver_id;
    p8_a8 := ddx_lrvv_rec.adj_mat_version_id;
    p8_a9 := ddx_lrvv_rec.version_number;
    p8_a10 := ddx_lrvv_rec.lrs_rate;
    p8_a11 := ddx_lrvv_rec.rate_tolerance;
    p8_a12 := ddx_lrvv_rec.residual_tolerance;
    p8_a13 := ddx_lrvv_rec.deferred_pmts;
    p8_a14 := ddx_lrvv_rec.advance_pmts;
    p8_a15 := ddx_lrvv_rec.sts_code;
    p8_a16 := ddx_lrvv_rec.created_by;
    p8_a17 := ddx_lrvv_rec.creation_date;
    p8_a18 := ddx_lrvv_rec.last_updated_by;
    p8_a19 := ddx_lrvv_rec.last_update_date;
    p8_a20 := ddx_lrvv_rec.last_update_login;
    p8_a21 := ddx_lrvv_rec.attribute_category;
    p8_a22 := ddx_lrvv_rec.attribute1;
    p8_a23 := ddx_lrvv_rec.attribute2;
    p8_a24 := ddx_lrvv_rec.attribute3;
    p8_a25 := ddx_lrvv_rec.attribute4;
    p8_a26 := ddx_lrvv_rec.attribute5;
    p8_a27 := ddx_lrvv_rec.attribute6;
    p8_a28 := ddx_lrvv_rec.attribute7;
    p8_a29 := ddx_lrvv_rec.attribute8;
    p8_a30 := ddx_lrvv_rec.attribute9;
    p8_a31 := ddx_lrvv_rec.attribute10;
    p8_a32 := ddx_lrvv_rec.attribute11;
    p8_a33 := ddx_lrvv_rec.attribute12;
    p8_a34 := ddx_lrvv_rec.attribute13;
    p8_a35 := ddx_lrvv_rec.attribute14;
    p8_a36 := ddx_lrvv_rec.attribute15;
    p8_a37 := ddx_lrvv_rec.standard_rate;
  end;

  procedure update_lrs_gen_lrf_submit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  DATE
    , p5_a9  DATE
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  NUMBER
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  DATE
    , p5_a16  NUMBER
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
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  VARCHAR2
    , p5_a34  NUMBER
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  NUMBER
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
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  DATE
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  DATE
    , p7_a18  NUMBER
    , p7_a19  DATE
    , p7_a20  NUMBER
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  NUMBER
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  DATE
    , p8_a4 out nocopy  DATE
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  NUMBER
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  NUMBER
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  NUMBER
    , p8_a14 out nocopy  NUMBER
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  NUMBER
    , p8_a17 out nocopy  DATE
    , p8_a18 out nocopy  NUMBER
    , p8_a19 out nocopy  DATE
    , p8_a20 out nocopy  NUMBER
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  VARCHAR2
    , p8_a24 out nocopy  VARCHAR2
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  VARCHAR2
    , p8_a27 out nocopy  VARCHAR2
    , p8_a28 out nocopy  VARCHAR2
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  VARCHAR2
    , p8_a31 out nocopy  VARCHAR2
    , p8_a32 out nocopy  VARCHAR2
    , p8_a33 out nocopy  VARCHAR2
    , p8_a34 out nocopy  VARCHAR2
    , p8_a35 out nocopy  VARCHAR2
    , p8_a36 out nocopy  VARCHAR2
    , p8_a37 out nocopy  NUMBER
  )

  as
    ddp_lrtv_rec okl_lease_rate_sets_pvt.lrtv_rec_type;
    ddx_lrtv_rec okl_lease_rate_sets_pvt.lrtv_rec_type;
    ddp_lrvv_rec okl_lease_rate_sets_pvt.okl_lrvv_rec;
    ddx_lrvv_rec okl_lease_rate_sets_pvt.okl_lrvv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lrtv_rec.id := p5_a0;
    ddp_lrtv_rec.object_version_number := p5_a1;
    ddp_lrtv_rec.sfwt_flag := p5_a2;
    ddp_lrtv_rec.try_id := p5_a3;
    ddp_lrtv_rec.pdt_id := p5_a4;
    ddp_lrtv_rec.rate := p5_a5;
    ddp_lrtv_rec.frq_code := p5_a6;
    ddp_lrtv_rec.arrears_yn := p5_a7;
    ddp_lrtv_rec.start_date := p5_a8;
    ddp_lrtv_rec.end_date := p5_a9;
    ddp_lrtv_rec.name := p5_a10;
    ddp_lrtv_rec.description := p5_a11;
    ddp_lrtv_rec.created_by := p5_a12;
    ddp_lrtv_rec.creation_date := p5_a13;
    ddp_lrtv_rec.last_updated_by := p5_a14;
    ddp_lrtv_rec.last_update_date := p5_a15;
    ddp_lrtv_rec.last_update_login := p5_a16;
    ddp_lrtv_rec.attribute_category := p5_a17;
    ddp_lrtv_rec.attribute1 := p5_a18;
    ddp_lrtv_rec.attribute2 := p5_a19;
    ddp_lrtv_rec.attribute3 := p5_a20;
    ddp_lrtv_rec.attribute4 := p5_a21;
    ddp_lrtv_rec.attribute5 := p5_a22;
    ddp_lrtv_rec.attribute6 := p5_a23;
    ddp_lrtv_rec.attribute7 := p5_a24;
    ddp_lrtv_rec.attribute8 := p5_a25;
    ddp_lrtv_rec.attribute9 := p5_a26;
    ddp_lrtv_rec.attribute10 := p5_a27;
    ddp_lrtv_rec.attribute11 := p5_a28;
    ddp_lrtv_rec.attribute12 := p5_a29;
    ddp_lrtv_rec.attribute13 := p5_a30;
    ddp_lrtv_rec.attribute14 := p5_a31;
    ddp_lrtv_rec.attribute15 := p5_a32;
    ddp_lrtv_rec.sts_code := p5_a33;
    ddp_lrtv_rec.org_id := p5_a34;
    ddp_lrtv_rec.currency_code := p5_a35;
    ddp_lrtv_rec.lrs_type_code := p5_a36;
    ddp_lrtv_rec.end_of_term_id := p5_a37;
    ddp_lrtv_rec.orig_rate_set_id := p5_a38;


    ddp_lrvv_rec.rate_set_version_id := p7_a0;
    ddp_lrvv_rec.object_version_number := p7_a1;
    ddp_lrvv_rec.arrears_yn := p7_a2;
    ddp_lrvv_rec.effective_from_date := p7_a3;
    ddp_lrvv_rec.effective_to_date := p7_a4;
    ddp_lrvv_rec.rate_set_id := p7_a5;
    ddp_lrvv_rec.end_of_term_ver_id := p7_a6;
    ddp_lrvv_rec.std_rate_tmpl_ver_id := p7_a7;
    ddp_lrvv_rec.adj_mat_version_id := p7_a8;
    ddp_lrvv_rec.version_number := p7_a9;
    ddp_lrvv_rec.lrs_rate := p7_a10;
    ddp_lrvv_rec.rate_tolerance := p7_a11;
    ddp_lrvv_rec.residual_tolerance := p7_a12;
    ddp_lrvv_rec.deferred_pmts := p7_a13;
    ddp_lrvv_rec.advance_pmts := p7_a14;
    ddp_lrvv_rec.sts_code := p7_a15;
    ddp_lrvv_rec.created_by := p7_a16;
    ddp_lrvv_rec.creation_date := p7_a17;
    ddp_lrvv_rec.last_updated_by := p7_a18;
    ddp_lrvv_rec.last_update_date := p7_a19;
    ddp_lrvv_rec.last_update_login := p7_a20;
    ddp_lrvv_rec.attribute_category := p7_a21;
    ddp_lrvv_rec.attribute1 := p7_a22;
    ddp_lrvv_rec.attribute2 := p7_a23;
    ddp_lrvv_rec.attribute3 := p7_a24;
    ddp_lrvv_rec.attribute4 := p7_a25;
    ddp_lrvv_rec.attribute5 := p7_a26;
    ddp_lrvv_rec.attribute6 := p7_a27;
    ddp_lrvv_rec.attribute7 := p7_a28;
    ddp_lrvv_rec.attribute8 := p7_a29;
    ddp_lrvv_rec.attribute9 := p7_a30;
    ddp_lrvv_rec.attribute10 := p7_a31;
    ddp_lrvv_rec.attribute11 := p7_a32;
    ddp_lrvv_rec.attribute12 := p7_a33;
    ddp_lrvv_rec.attribute13 := p7_a34;
    ddp_lrvv_rec.attribute14 := p7_a35;
    ddp_lrvv_rec.attribute15 := p7_a36;
    ddp_lrvv_rec.standard_rate := p7_a37;


    -- here's the delegated call to the old PL/SQL routine
    okl_lease_rate_sets_pvt.update_lrs_gen_lrf_submit(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lrtv_rec,
      ddx_lrtv_rec,
      ddp_lrvv_rec,
      ddx_lrvv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lrtv_rec.id;
    p6_a1 := ddx_lrtv_rec.object_version_number;
    p6_a2 := ddx_lrtv_rec.sfwt_flag;
    p6_a3 := ddx_lrtv_rec.try_id;
    p6_a4 := ddx_lrtv_rec.pdt_id;
    p6_a5 := ddx_lrtv_rec.rate;
    p6_a6 := ddx_lrtv_rec.frq_code;
    p6_a7 := ddx_lrtv_rec.arrears_yn;
    p6_a8 := ddx_lrtv_rec.start_date;
    p6_a9 := ddx_lrtv_rec.end_date;
    p6_a10 := ddx_lrtv_rec.name;
    p6_a11 := ddx_lrtv_rec.description;
    p6_a12 := ddx_lrtv_rec.created_by;
    p6_a13 := ddx_lrtv_rec.creation_date;
    p6_a14 := ddx_lrtv_rec.last_updated_by;
    p6_a15 := ddx_lrtv_rec.last_update_date;
    p6_a16 := ddx_lrtv_rec.last_update_login;
    p6_a17 := ddx_lrtv_rec.attribute_category;
    p6_a18 := ddx_lrtv_rec.attribute1;
    p6_a19 := ddx_lrtv_rec.attribute2;
    p6_a20 := ddx_lrtv_rec.attribute3;
    p6_a21 := ddx_lrtv_rec.attribute4;
    p6_a22 := ddx_lrtv_rec.attribute5;
    p6_a23 := ddx_lrtv_rec.attribute6;
    p6_a24 := ddx_lrtv_rec.attribute7;
    p6_a25 := ddx_lrtv_rec.attribute8;
    p6_a26 := ddx_lrtv_rec.attribute9;
    p6_a27 := ddx_lrtv_rec.attribute10;
    p6_a28 := ddx_lrtv_rec.attribute11;
    p6_a29 := ddx_lrtv_rec.attribute12;
    p6_a30 := ddx_lrtv_rec.attribute13;
    p6_a31 := ddx_lrtv_rec.attribute14;
    p6_a32 := ddx_lrtv_rec.attribute15;
    p6_a33 := ddx_lrtv_rec.sts_code;
    p6_a34 := ddx_lrtv_rec.org_id;
    p6_a35 := ddx_lrtv_rec.currency_code;
    p6_a36 := ddx_lrtv_rec.lrs_type_code;
    p6_a37 := ddx_lrtv_rec.end_of_term_id;
    p6_a38 := ddx_lrtv_rec.orig_rate_set_id;


    p8_a0 := ddx_lrvv_rec.rate_set_version_id;
    p8_a1 := ddx_lrvv_rec.object_version_number;
    p8_a2 := ddx_lrvv_rec.arrears_yn;
    p8_a3 := ddx_lrvv_rec.effective_from_date;
    p8_a4 := ddx_lrvv_rec.effective_to_date;
    p8_a5 := ddx_lrvv_rec.rate_set_id;
    p8_a6 := ddx_lrvv_rec.end_of_term_ver_id;
    p8_a7 := ddx_lrvv_rec.std_rate_tmpl_ver_id;
    p8_a8 := ddx_lrvv_rec.adj_mat_version_id;
    p8_a9 := ddx_lrvv_rec.version_number;
    p8_a10 := ddx_lrvv_rec.lrs_rate;
    p8_a11 := ddx_lrvv_rec.rate_tolerance;
    p8_a12 := ddx_lrvv_rec.residual_tolerance;
    p8_a13 := ddx_lrvv_rec.deferred_pmts;
    p8_a14 := ddx_lrvv_rec.advance_pmts;
    p8_a15 := ddx_lrvv_rec.sts_code;
    p8_a16 := ddx_lrvv_rec.created_by;
    p8_a17 := ddx_lrvv_rec.creation_date;
    p8_a18 := ddx_lrvv_rec.last_updated_by;
    p8_a19 := ddx_lrvv_rec.last_update_date;
    p8_a20 := ddx_lrvv_rec.last_update_login;
    p8_a21 := ddx_lrvv_rec.attribute_category;
    p8_a22 := ddx_lrvv_rec.attribute1;
    p8_a23 := ddx_lrvv_rec.attribute2;
    p8_a24 := ddx_lrvv_rec.attribute3;
    p8_a25 := ddx_lrvv_rec.attribute4;
    p8_a26 := ddx_lrvv_rec.attribute5;
    p8_a27 := ddx_lrvv_rec.attribute6;
    p8_a28 := ddx_lrvv_rec.attribute7;
    p8_a29 := ddx_lrvv_rec.attribute8;
    p8_a30 := ddx_lrvv_rec.attribute9;
    p8_a31 := ddx_lrvv_rec.attribute10;
    p8_a32 := ddx_lrvv_rec.attribute11;
    p8_a33 := ddx_lrvv_rec.attribute12;
    p8_a34 := ddx_lrvv_rec.attribute13;
    p8_a35 := ddx_lrvv_rec.attribute14;
    p8_a36 := ddx_lrvv_rec.attribute15;
    p8_a37 := ddx_lrvv_rec.standard_rate;
  end;

  procedure version_lrs_gen_lrf_submit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  DATE
    , p5_a9  DATE
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  NUMBER
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  DATE
    , p5_a16  NUMBER
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
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  VARCHAR2
    , p5_a34  NUMBER
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  NUMBER
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
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  DATE
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  DATE
    , p7_a18  NUMBER
    , p7_a19  DATE
    , p7_a20  NUMBER
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  NUMBER
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  DATE
    , p8_a4 out nocopy  DATE
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  NUMBER
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  NUMBER
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  NUMBER
    , p8_a14 out nocopy  NUMBER
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  NUMBER
    , p8_a17 out nocopy  DATE
    , p8_a18 out nocopy  NUMBER
    , p8_a19 out nocopy  DATE
    , p8_a20 out nocopy  NUMBER
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  VARCHAR2
    , p8_a24 out nocopy  VARCHAR2
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  VARCHAR2
    , p8_a27 out nocopy  VARCHAR2
    , p8_a28 out nocopy  VARCHAR2
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  VARCHAR2
    , p8_a31 out nocopy  VARCHAR2
    , p8_a32 out nocopy  VARCHAR2
    , p8_a33 out nocopy  VARCHAR2
    , p8_a34 out nocopy  VARCHAR2
    , p8_a35 out nocopy  VARCHAR2
    , p8_a36 out nocopy  VARCHAR2
    , p8_a37 out nocopy  NUMBER
  )

  as
    ddp_lrtv_rec okl_lease_rate_sets_pvt.lrtv_rec_type;
    ddx_lrtv_rec okl_lease_rate_sets_pvt.lrtv_rec_type;
    ddp_lrvv_rec okl_lease_rate_sets_pvt.okl_lrvv_rec;
    ddx_lrvv_rec okl_lease_rate_sets_pvt.okl_lrvv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lrtv_rec.id := p5_a0;
    ddp_lrtv_rec.object_version_number := p5_a1;
    ddp_lrtv_rec.sfwt_flag := p5_a2;
    ddp_lrtv_rec.try_id := p5_a3;
    ddp_lrtv_rec.pdt_id := p5_a4;
    ddp_lrtv_rec.rate := p5_a5;
    ddp_lrtv_rec.frq_code := p5_a6;
    ddp_lrtv_rec.arrears_yn := p5_a7;
    ddp_lrtv_rec.start_date := p5_a8;
    ddp_lrtv_rec.end_date := p5_a9;
    ddp_lrtv_rec.name := p5_a10;
    ddp_lrtv_rec.description := p5_a11;
    ddp_lrtv_rec.created_by := p5_a12;
    ddp_lrtv_rec.creation_date := p5_a13;
    ddp_lrtv_rec.last_updated_by := p5_a14;
    ddp_lrtv_rec.last_update_date := p5_a15;
    ddp_lrtv_rec.last_update_login := p5_a16;
    ddp_lrtv_rec.attribute_category := p5_a17;
    ddp_lrtv_rec.attribute1 := p5_a18;
    ddp_lrtv_rec.attribute2 := p5_a19;
    ddp_lrtv_rec.attribute3 := p5_a20;
    ddp_lrtv_rec.attribute4 := p5_a21;
    ddp_lrtv_rec.attribute5 := p5_a22;
    ddp_lrtv_rec.attribute6 := p5_a23;
    ddp_lrtv_rec.attribute7 := p5_a24;
    ddp_lrtv_rec.attribute8 := p5_a25;
    ddp_lrtv_rec.attribute9 := p5_a26;
    ddp_lrtv_rec.attribute10 := p5_a27;
    ddp_lrtv_rec.attribute11 := p5_a28;
    ddp_lrtv_rec.attribute12 := p5_a29;
    ddp_lrtv_rec.attribute13 := p5_a30;
    ddp_lrtv_rec.attribute14 := p5_a31;
    ddp_lrtv_rec.attribute15 := p5_a32;
    ddp_lrtv_rec.sts_code := p5_a33;
    ddp_lrtv_rec.org_id := p5_a34;
    ddp_lrtv_rec.currency_code := p5_a35;
    ddp_lrtv_rec.lrs_type_code := p5_a36;
    ddp_lrtv_rec.end_of_term_id := p5_a37;
    ddp_lrtv_rec.orig_rate_set_id := p5_a38;


    ddp_lrvv_rec.rate_set_version_id := p7_a0;
    ddp_lrvv_rec.object_version_number := p7_a1;
    ddp_lrvv_rec.arrears_yn := p7_a2;
    ddp_lrvv_rec.effective_from_date := p7_a3;
    ddp_lrvv_rec.effective_to_date := p7_a4;
    ddp_lrvv_rec.rate_set_id := p7_a5;
    ddp_lrvv_rec.end_of_term_ver_id := p7_a6;
    ddp_lrvv_rec.std_rate_tmpl_ver_id := p7_a7;
    ddp_lrvv_rec.adj_mat_version_id := p7_a8;
    ddp_lrvv_rec.version_number := p7_a9;
    ddp_lrvv_rec.lrs_rate := p7_a10;
    ddp_lrvv_rec.rate_tolerance := p7_a11;
    ddp_lrvv_rec.residual_tolerance := p7_a12;
    ddp_lrvv_rec.deferred_pmts := p7_a13;
    ddp_lrvv_rec.advance_pmts := p7_a14;
    ddp_lrvv_rec.sts_code := p7_a15;
    ddp_lrvv_rec.created_by := p7_a16;
    ddp_lrvv_rec.creation_date := p7_a17;
    ddp_lrvv_rec.last_updated_by := p7_a18;
    ddp_lrvv_rec.last_update_date := p7_a19;
    ddp_lrvv_rec.last_update_login := p7_a20;
    ddp_lrvv_rec.attribute_category := p7_a21;
    ddp_lrvv_rec.attribute1 := p7_a22;
    ddp_lrvv_rec.attribute2 := p7_a23;
    ddp_lrvv_rec.attribute3 := p7_a24;
    ddp_lrvv_rec.attribute4 := p7_a25;
    ddp_lrvv_rec.attribute5 := p7_a26;
    ddp_lrvv_rec.attribute6 := p7_a27;
    ddp_lrvv_rec.attribute7 := p7_a28;
    ddp_lrvv_rec.attribute8 := p7_a29;
    ddp_lrvv_rec.attribute9 := p7_a30;
    ddp_lrvv_rec.attribute10 := p7_a31;
    ddp_lrvv_rec.attribute11 := p7_a32;
    ddp_lrvv_rec.attribute12 := p7_a33;
    ddp_lrvv_rec.attribute13 := p7_a34;
    ddp_lrvv_rec.attribute14 := p7_a35;
    ddp_lrvv_rec.attribute15 := p7_a36;
    ddp_lrvv_rec.standard_rate := p7_a37;


    -- here's the delegated call to the old PL/SQL routine
    okl_lease_rate_sets_pvt.version_lrs_gen_lrf_submit(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lrtv_rec,
      ddx_lrtv_rec,
      ddp_lrvv_rec,
      ddx_lrvv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lrtv_rec.id;
    p6_a1 := ddx_lrtv_rec.object_version_number;
    p6_a2 := ddx_lrtv_rec.sfwt_flag;
    p6_a3 := ddx_lrtv_rec.try_id;
    p6_a4 := ddx_lrtv_rec.pdt_id;
    p6_a5 := ddx_lrtv_rec.rate;
    p6_a6 := ddx_lrtv_rec.frq_code;
    p6_a7 := ddx_lrtv_rec.arrears_yn;
    p6_a8 := ddx_lrtv_rec.start_date;
    p6_a9 := ddx_lrtv_rec.end_date;
    p6_a10 := ddx_lrtv_rec.name;
    p6_a11 := ddx_lrtv_rec.description;
    p6_a12 := ddx_lrtv_rec.created_by;
    p6_a13 := ddx_lrtv_rec.creation_date;
    p6_a14 := ddx_lrtv_rec.last_updated_by;
    p6_a15 := ddx_lrtv_rec.last_update_date;
    p6_a16 := ddx_lrtv_rec.last_update_login;
    p6_a17 := ddx_lrtv_rec.attribute_category;
    p6_a18 := ddx_lrtv_rec.attribute1;
    p6_a19 := ddx_lrtv_rec.attribute2;
    p6_a20 := ddx_lrtv_rec.attribute3;
    p6_a21 := ddx_lrtv_rec.attribute4;
    p6_a22 := ddx_lrtv_rec.attribute5;
    p6_a23 := ddx_lrtv_rec.attribute6;
    p6_a24 := ddx_lrtv_rec.attribute7;
    p6_a25 := ddx_lrtv_rec.attribute8;
    p6_a26 := ddx_lrtv_rec.attribute9;
    p6_a27 := ddx_lrtv_rec.attribute10;
    p6_a28 := ddx_lrtv_rec.attribute11;
    p6_a29 := ddx_lrtv_rec.attribute12;
    p6_a30 := ddx_lrtv_rec.attribute13;
    p6_a31 := ddx_lrtv_rec.attribute14;
    p6_a32 := ddx_lrtv_rec.attribute15;
    p6_a33 := ddx_lrtv_rec.sts_code;
    p6_a34 := ddx_lrtv_rec.org_id;
    p6_a35 := ddx_lrtv_rec.currency_code;
    p6_a36 := ddx_lrtv_rec.lrs_type_code;
    p6_a37 := ddx_lrtv_rec.end_of_term_id;
    p6_a38 := ddx_lrtv_rec.orig_rate_set_id;


    p8_a0 := ddx_lrvv_rec.rate_set_version_id;
    p8_a1 := ddx_lrvv_rec.object_version_number;
    p8_a2 := ddx_lrvv_rec.arrears_yn;
    p8_a3 := ddx_lrvv_rec.effective_from_date;
    p8_a4 := ddx_lrvv_rec.effective_to_date;
    p8_a5 := ddx_lrvv_rec.rate_set_id;
    p8_a6 := ddx_lrvv_rec.end_of_term_ver_id;
    p8_a7 := ddx_lrvv_rec.std_rate_tmpl_ver_id;
    p8_a8 := ddx_lrvv_rec.adj_mat_version_id;
    p8_a9 := ddx_lrvv_rec.version_number;
    p8_a10 := ddx_lrvv_rec.lrs_rate;
    p8_a11 := ddx_lrvv_rec.rate_tolerance;
    p8_a12 := ddx_lrvv_rec.residual_tolerance;
    p8_a13 := ddx_lrvv_rec.deferred_pmts;
    p8_a14 := ddx_lrvv_rec.advance_pmts;
    p8_a15 := ddx_lrvv_rec.sts_code;
    p8_a16 := ddx_lrvv_rec.created_by;
    p8_a17 := ddx_lrvv_rec.creation_date;
    p8_a18 := ddx_lrvv_rec.last_updated_by;
    p8_a19 := ddx_lrvv_rec.last_update_date;
    p8_a20 := ddx_lrvv_rec.last_update_login;
    p8_a21 := ddx_lrvv_rec.attribute_category;
    p8_a22 := ddx_lrvv_rec.attribute1;
    p8_a23 := ddx_lrvv_rec.attribute2;
    p8_a24 := ddx_lrvv_rec.attribute3;
    p8_a25 := ddx_lrvv_rec.attribute4;
    p8_a26 := ddx_lrvv_rec.attribute5;
    p8_a27 := ddx_lrvv_rec.attribute6;
    p8_a28 := ddx_lrvv_rec.attribute7;
    p8_a29 := ddx_lrvv_rec.attribute8;
    p8_a30 := ddx_lrvv_rec.attribute9;
    p8_a31 := ddx_lrvv_rec.attribute10;
    p8_a32 := ddx_lrvv_rec.attribute11;
    p8_a33 := ddx_lrvv_rec.attribute12;
    p8_a34 := ddx_lrvv_rec.attribute13;
    p8_a35 := ddx_lrvv_rec.attribute14;
    p8_a36 := ddx_lrvv_rec.attribute15;
    p8_a37 := ddx_lrvv_rec.standard_rate;
  end;

  procedure enddate_lease_rate_set(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_lrv_id_tbl JTF_NUMBER_TABLE
    , p_end_date  DATE
  )

  as
    ddp_lrv_id_tbl okl_lease_rate_sets_pvt.okl_number_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_lease_rate_sets_pvt_w.rosetta_table_copy_in_p22(ddp_lrv_id_tbl, p_lrv_id_tbl);


    -- here's the delegated call to the old PL/SQL routine
    okl_lease_rate_sets_pvt.enddate_lease_rate_set(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lrv_id_tbl,
      p_end_date);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end okl_lease_rate_sets_pvt_w;

/
