--------------------------------------------------------
--  DDL for Package Body OKL_TRANS_ACCT_OPT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TRANS_ACCT_OPT_PVT_W" as
  /* $Header: OKLETACB.pls 120.1 2005/07/12 09:11:18 dkagrawa noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure get_trx_acct_opt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
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
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  DATE
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  DATE
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_taov_rec okl_trans_acct_opt_pvt.taov_rec_type;
    ddx_taov_rec okl_trans_acct_opt_pvt.taov_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_taov_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_taov_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_taov_rec.try_id := rosetta_g_miss_num_map(p5_a2);
    ddp_taov_rec.unearned_ccid := rosetta_g_miss_num_map(p5_a3);
    ddp_taov_rec.rev_ccid := rosetta_g_miss_num_map(p5_a4);
    ddp_taov_rec.freight_ccid := rosetta_g_miss_num_map(p5_a5);
    ddp_taov_rec.rec_ccid := rosetta_g_miss_num_map(p5_a6);
    ddp_taov_rec.clearing_ccid := rosetta_g_miss_num_map(p5_a7);
    ddp_taov_rec.tax_ccid := rosetta_g_miss_num_map(p5_a8);
    ddp_taov_rec.unbilled_ccid := rosetta_g_miss_num_map(p5_a9);
    ddp_taov_rec.attribute_category := p5_a10;
    ddp_taov_rec.attribute1 := p5_a11;
    ddp_taov_rec.attribute2 := p5_a12;
    ddp_taov_rec.attribute3 := p5_a13;
    ddp_taov_rec.attribute4 := p5_a14;
    ddp_taov_rec.attribute5 := p5_a15;
    ddp_taov_rec.attribute6 := p5_a16;
    ddp_taov_rec.attribute7 := p5_a17;
    ddp_taov_rec.attribute8 := p5_a18;
    ddp_taov_rec.attribute9 := p5_a19;
    ddp_taov_rec.attribute10 := p5_a20;
    ddp_taov_rec.attribute11 := p5_a21;
    ddp_taov_rec.attribute12 := p5_a22;
    ddp_taov_rec.attribute13 := p5_a23;
    ddp_taov_rec.attribute14 := p5_a24;
    ddp_taov_rec.attribute15 := p5_a25;
    ddp_taov_rec.org_id := rosetta_g_miss_num_map(p5_a26);
    ddp_taov_rec.created_by := rosetta_g_miss_num_map(p5_a27);
    ddp_taov_rec.creation_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_taov_rec.last_updated_by := rosetta_g_miss_num_map(p5_a29);
    ddp_taov_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_taov_rec.last_update_login := rosetta_g_miss_num_map(p5_a31);
    ddp_taov_rec.post_to_gl_yn := p5_a32;


    -- here's the delegated call to the old PL/SQL routine
    okl_trans_acct_opt_pvt.get_trx_acct_opt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_taov_rec,
      ddx_taov_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_taov_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_taov_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_taov_rec.try_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_taov_rec.unearned_ccid);
    p6_a4 := rosetta_g_miss_num_map(ddx_taov_rec.rev_ccid);
    p6_a5 := rosetta_g_miss_num_map(ddx_taov_rec.freight_ccid);
    p6_a6 := rosetta_g_miss_num_map(ddx_taov_rec.rec_ccid);
    p6_a7 := rosetta_g_miss_num_map(ddx_taov_rec.clearing_ccid);
    p6_a8 := rosetta_g_miss_num_map(ddx_taov_rec.tax_ccid);
    p6_a9 := rosetta_g_miss_num_map(ddx_taov_rec.unbilled_ccid);
    p6_a10 := ddx_taov_rec.attribute_category;
    p6_a11 := ddx_taov_rec.attribute1;
    p6_a12 := ddx_taov_rec.attribute2;
    p6_a13 := ddx_taov_rec.attribute3;
    p6_a14 := ddx_taov_rec.attribute4;
    p6_a15 := ddx_taov_rec.attribute5;
    p6_a16 := ddx_taov_rec.attribute6;
    p6_a17 := ddx_taov_rec.attribute7;
    p6_a18 := ddx_taov_rec.attribute8;
    p6_a19 := ddx_taov_rec.attribute9;
    p6_a20 := ddx_taov_rec.attribute10;
    p6_a21 := ddx_taov_rec.attribute11;
    p6_a22 := ddx_taov_rec.attribute12;
    p6_a23 := ddx_taov_rec.attribute13;
    p6_a24 := ddx_taov_rec.attribute14;
    p6_a25 := ddx_taov_rec.attribute15;
    p6_a26 := rosetta_g_miss_num_map(ddx_taov_rec.org_id);
    p6_a27 := rosetta_g_miss_num_map(ddx_taov_rec.created_by);
    p6_a28 := ddx_taov_rec.creation_date;
    p6_a29 := rosetta_g_miss_num_map(ddx_taov_rec.last_updated_by);
    p6_a30 := ddx_taov_rec.last_update_date;
    p6_a31 := rosetta_g_miss_num_map(ddx_taov_rec.last_update_login);
    p6_a32 := ddx_taov_rec.post_to_gl_yn;
  end;

  procedure updt_trx_acct_opt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
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
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  DATE
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  DATE
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_taov_rec okl_trans_acct_opt_pvt.taov_rec_type;
    ddx_taov_rec okl_trans_acct_opt_pvt.taov_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_taov_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_taov_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_taov_rec.try_id := rosetta_g_miss_num_map(p5_a2);
    ddp_taov_rec.unearned_ccid := rosetta_g_miss_num_map(p5_a3);
    ddp_taov_rec.rev_ccid := rosetta_g_miss_num_map(p5_a4);
    ddp_taov_rec.freight_ccid := rosetta_g_miss_num_map(p5_a5);
    ddp_taov_rec.rec_ccid := rosetta_g_miss_num_map(p5_a6);
    ddp_taov_rec.clearing_ccid := rosetta_g_miss_num_map(p5_a7);
    ddp_taov_rec.tax_ccid := rosetta_g_miss_num_map(p5_a8);
    ddp_taov_rec.unbilled_ccid := rosetta_g_miss_num_map(p5_a9);
    ddp_taov_rec.attribute_category := p5_a10;
    ddp_taov_rec.attribute1 := p5_a11;
    ddp_taov_rec.attribute2 := p5_a12;
    ddp_taov_rec.attribute3 := p5_a13;
    ddp_taov_rec.attribute4 := p5_a14;
    ddp_taov_rec.attribute5 := p5_a15;
    ddp_taov_rec.attribute6 := p5_a16;
    ddp_taov_rec.attribute7 := p5_a17;
    ddp_taov_rec.attribute8 := p5_a18;
    ddp_taov_rec.attribute9 := p5_a19;
    ddp_taov_rec.attribute10 := p5_a20;
    ddp_taov_rec.attribute11 := p5_a21;
    ddp_taov_rec.attribute12 := p5_a22;
    ddp_taov_rec.attribute13 := p5_a23;
    ddp_taov_rec.attribute14 := p5_a24;
    ddp_taov_rec.attribute15 := p5_a25;
    ddp_taov_rec.org_id := rosetta_g_miss_num_map(p5_a26);
    ddp_taov_rec.created_by := rosetta_g_miss_num_map(p5_a27);
    ddp_taov_rec.creation_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_taov_rec.last_updated_by := rosetta_g_miss_num_map(p5_a29);
    ddp_taov_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_taov_rec.last_update_login := rosetta_g_miss_num_map(p5_a31);
    ddp_taov_rec.post_to_gl_yn := p5_a32;


    -- here's the delegated call to the old PL/SQL routine
    okl_trans_acct_opt_pvt.updt_trx_acct_opt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_taov_rec,
      ddx_taov_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_taov_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_taov_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_taov_rec.try_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_taov_rec.unearned_ccid);
    p6_a4 := rosetta_g_miss_num_map(ddx_taov_rec.rev_ccid);
    p6_a5 := rosetta_g_miss_num_map(ddx_taov_rec.freight_ccid);
    p6_a6 := rosetta_g_miss_num_map(ddx_taov_rec.rec_ccid);
    p6_a7 := rosetta_g_miss_num_map(ddx_taov_rec.clearing_ccid);
    p6_a8 := rosetta_g_miss_num_map(ddx_taov_rec.tax_ccid);
    p6_a9 := rosetta_g_miss_num_map(ddx_taov_rec.unbilled_ccid);
    p6_a10 := ddx_taov_rec.attribute_category;
    p6_a11 := ddx_taov_rec.attribute1;
    p6_a12 := ddx_taov_rec.attribute2;
    p6_a13 := ddx_taov_rec.attribute3;
    p6_a14 := ddx_taov_rec.attribute4;
    p6_a15 := ddx_taov_rec.attribute5;
    p6_a16 := ddx_taov_rec.attribute6;
    p6_a17 := ddx_taov_rec.attribute7;
    p6_a18 := ddx_taov_rec.attribute8;
    p6_a19 := ddx_taov_rec.attribute9;
    p6_a20 := ddx_taov_rec.attribute10;
    p6_a21 := ddx_taov_rec.attribute11;
    p6_a22 := ddx_taov_rec.attribute12;
    p6_a23 := ddx_taov_rec.attribute13;
    p6_a24 := ddx_taov_rec.attribute14;
    p6_a25 := ddx_taov_rec.attribute15;
    p6_a26 := rosetta_g_miss_num_map(ddx_taov_rec.org_id);
    p6_a27 := rosetta_g_miss_num_map(ddx_taov_rec.created_by);
    p6_a28 := ddx_taov_rec.creation_date;
    p6_a29 := rosetta_g_miss_num_map(ddx_taov_rec.last_updated_by);
    p6_a30 := ddx_taov_rec.last_update_date;
    p6_a31 := rosetta_g_miss_num_map(ddx_taov_rec.last_update_login);
    p6_a32 := ddx_taov_rec.post_to_gl_yn;
  end;

end okl_trans_acct_opt_pvt_w;

/
