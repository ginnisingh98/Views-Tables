--------------------------------------------------------
--  DDL for Package Body OKL_MISC_TRANS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_MISC_TRANS_PUB_W" as
  /* $Header: OKLUMSCB.pls 120.2 2005/10/30 04:48:52 appldev noship $ */
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

  procedure create_misc_dstr_line(p_api_version  NUMBER
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
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
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
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  DATE
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
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
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tclv_rec okl_misc_trans_pub.tclv_rec_type;
    ddx_tclv_rec okl_misc_trans_pub.tclv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tclv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tclv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tclv_rec.sty_id := rosetta_g_miss_num_map(p5_a2);
    ddp_tclv_rec.rct_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tclv_rec.btc_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tclv_rec.tcn_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tclv_rec.khr_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tclv_rec.kle_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tclv_rec.before_transfer_yn := p5_a8;
    ddp_tclv_rec.line_number := rosetta_g_miss_num_map(p5_a9);
    ddp_tclv_rec.description := p5_a10;
    ddp_tclv_rec.amount := rosetta_g_miss_num_map(p5_a11);
    ddp_tclv_rec.currency_code := p5_a12;
    ddp_tclv_rec.gl_reversal_yn := p5_a13;
    ddp_tclv_rec.attribute_category := p5_a14;
    ddp_tclv_rec.attribute1 := p5_a15;
    ddp_tclv_rec.attribute2 := p5_a16;
    ddp_tclv_rec.attribute3 := p5_a17;
    ddp_tclv_rec.attribute4 := p5_a18;
    ddp_tclv_rec.attribute5 := p5_a19;
    ddp_tclv_rec.attribute6 := p5_a20;
    ddp_tclv_rec.attribute7 := p5_a21;
    ddp_tclv_rec.attribute8 := p5_a22;
    ddp_tclv_rec.attribute9 := p5_a23;
    ddp_tclv_rec.attribute10 := p5_a24;
    ddp_tclv_rec.attribute11 := p5_a25;
    ddp_tclv_rec.attribute12 := p5_a26;
    ddp_tclv_rec.attribute13 := p5_a27;
    ddp_tclv_rec.attribute14 := p5_a28;
    ddp_tclv_rec.attribute15 := p5_a29;
    ddp_tclv_rec.tcl_type := p5_a30;
    ddp_tclv_rec.created_by := rosetta_g_miss_num_map(p5_a31);
    ddp_tclv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a32);
    ddp_tclv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a33);
    ddp_tclv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_tclv_rec.org_id := rosetta_g_miss_num_map(p5_a35);
    ddp_tclv_rec.program_id := rosetta_g_miss_num_map(p5_a36);
    ddp_tclv_rec.program_application_id := rosetta_g_miss_num_map(p5_a37);
    ddp_tclv_rec.request_id := rosetta_g_miss_num_map(p5_a38);
    ddp_tclv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tclv_rec.last_update_login := rosetta_g_miss_num_map(p5_a40);
    ddp_tclv_rec.avl_id := rosetta_g_miss_num_map(p5_a41);
    ddp_tclv_rec.bkt_id := rosetta_g_miss_num_map(p5_a42);
    ddp_tclv_rec.kle_id_new := rosetta_g_miss_num_map(p5_a43);
    ddp_tclv_rec.percentage := rosetta_g_miss_num_map(p5_a44);
    ddp_tclv_rec.accrual_rule_yn := p5_a45;


    -- here's the delegated call to the old PL/SQL routine
    okl_misc_trans_pub.create_misc_dstr_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tclv_rec,
      ddx_tclv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tclv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tclv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_tclv_rec.sty_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_tclv_rec.rct_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_tclv_rec.btc_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_tclv_rec.tcn_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_tclv_rec.khr_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_tclv_rec.kle_id);
    p6_a8 := ddx_tclv_rec.before_transfer_yn;
    p6_a9 := rosetta_g_miss_num_map(ddx_tclv_rec.line_number);
    p6_a10 := ddx_tclv_rec.description;
    p6_a11 := rosetta_g_miss_num_map(ddx_tclv_rec.amount);
    p6_a12 := ddx_tclv_rec.currency_code;
    p6_a13 := ddx_tclv_rec.gl_reversal_yn;
    p6_a14 := ddx_tclv_rec.attribute_category;
    p6_a15 := ddx_tclv_rec.attribute1;
    p6_a16 := ddx_tclv_rec.attribute2;
    p6_a17 := ddx_tclv_rec.attribute3;
    p6_a18 := ddx_tclv_rec.attribute4;
    p6_a19 := ddx_tclv_rec.attribute5;
    p6_a20 := ddx_tclv_rec.attribute6;
    p6_a21 := ddx_tclv_rec.attribute7;
    p6_a22 := ddx_tclv_rec.attribute8;
    p6_a23 := ddx_tclv_rec.attribute9;
    p6_a24 := ddx_tclv_rec.attribute10;
    p6_a25 := ddx_tclv_rec.attribute11;
    p6_a26 := ddx_tclv_rec.attribute12;
    p6_a27 := ddx_tclv_rec.attribute13;
    p6_a28 := ddx_tclv_rec.attribute14;
    p6_a29 := ddx_tclv_rec.attribute15;
    p6_a30 := ddx_tclv_rec.tcl_type;
    p6_a31 := rosetta_g_miss_num_map(ddx_tclv_rec.created_by);
    p6_a32 := ddx_tclv_rec.creation_date;
    p6_a33 := rosetta_g_miss_num_map(ddx_tclv_rec.last_updated_by);
    p6_a34 := ddx_tclv_rec.last_update_date;
    p6_a35 := rosetta_g_miss_num_map(ddx_tclv_rec.org_id);
    p6_a36 := rosetta_g_miss_num_map(ddx_tclv_rec.program_id);
    p6_a37 := rosetta_g_miss_num_map(ddx_tclv_rec.program_application_id);
    p6_a38 := rosetta_g_miss_num_map(ddx_tclv_rec.request_id);
    p6_a39 := ddx_tclv_rec.program_update_date;
    p6_a40 := rosetta_g_miss_num_map(ddx_tclv_rec.last_update_login);
    p6_a41 := rosetta_g_miss_num_map(ddx_tclv_rec.avl_id);
    p6_a42 := rosetta_g_miss_num_map(ddx_tclv_rec.bkt_id);
    p6_a43 := rosetta_g_miss_num_map(ddx_tclv_rec.kle_id_new);
    p6_a44 := rosetta_g_miss_num_map(ddx_tclv_rec.percentage);
    p6_a45 := ddx_tclv_rec.accrual_rule_yn;
  end;

  procedure create_misc_transaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_2000
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_VARCHAR2_TABLE_200
    , p6_a8 JTF_NUMBER_TABLE
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  DATE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
  )

  as
    ddp_jrnl_hdr_rec okl_misc_trans_pvt.jrnl_hdr_rec_type;
    ddp_jrnl_line_tbl okl_misc_trans_pvt.jrnl_line_tbl_type;
    ddx_jrnl_hdr_rec okl_misc_trans_pvt.jrnl_hdr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_jrnl_hdr_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_jrnl_hdr_rec.khr_id := rosetta_g_miss_num_map(p5_a1);
    ddp_jrnl_hdr_rec.pdt_id := rosetta_g_miss_num_map(p5_a2);
    ddp_jrnl_hdr_rec.amount := rosetta_g_miss_num_map(p5_a3);
    ddp_jrnl_hdr_rec.tsu_code := p5_a4;
    ddp_jrnl_hdr_rec.currency_code := p5_a5;
    ddp_jrnl_hdr_rec.trx_number := p5_a6;
    ddp_jrnl_hdr_rec.description := p5_a7;
    ddp_jrnl_hdr_rec.date_transaction_occurred := rosetta_g_miss_date_in_map(p5_a8);

    okl_misc_trans_pvt_w.rosetta_table_copy_in_p14(ddp_jrnl_line_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_misc_trans_pub.create_misc_transaction(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_jrnl_hdr_rec,
      ddp_jrnl_line_tbl,
      ddx_jrnl_hdr_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_jrnl_hdr_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_jrnl_hdr_rec.khr_id);
    p7_a2 := rosetta_g_miss_num_map(ddx_jrnl_hdr_rec.pdt_id);
    p7_a3 := rosetta_g_miss_num_map(ddx_jrnl_hdr_rec.amount);
    p7_a4 := ddx_jrnl_hdr_rec.tsu_code;
    p7_a5 := ddx_jrnl_hdr_rec.currency_code;
    p7_a6 := ddx_jrnl_hdr_rec.trx_number;
    p7_a7 := ddx_jrnl_hdr_rec.description;
    p7_a8 := ddx_jrnl_hdr_rec.date_transaction_occurred;
  end;

  procedure update_misc_transaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_2000
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_VARCHAR2_TABLE_200
    , p6_a8 JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
  )

  as
    ddp_jrnl_hdr_rec okl_misc_trans_pvt.jrnl_hdr_rec_type;
    ddp_jrnl_line_tbl okl_misc_trans_pvt.jrnl_line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_jrnl_hdr_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_jrnl_hdr_rec.khr_id := rosetta_g_miss_num_map(p5_a1);
    ddp_jrnl_hdr_rec.pdt_id := rosetta_g_miss_num_map(p5_a2);
    ddp_jrnl_hdr_rec.amount := rosetta_g_miss_num_map(p5_a3);
    ddp_jrnl_hdr_rec.tsu_code := p5_a4;
    ddp_jrnl_hdr_rec.currency_code := p5_a5;
    ddp_jrnl_hdr_rec.trx_number := p5_a6;
    ddp_jrnl_hdr_rec.description := p5_a7;
    ddp_jrnl_hdr_rec.date_transaction_occurred := rosetta_g_miss_date_in_map(p5_a8);

    okl_misc_trans_pvt_w.rosetta_table_copy_in_p14(ddp_jrnl_line_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_misc_trans_pub.update_misc_transaction(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_jrnl_hdr_rec,
      ddp_jrnl_line_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end okl_misc_trans_pub_w;

/
