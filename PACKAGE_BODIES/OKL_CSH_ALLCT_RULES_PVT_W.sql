--------------------------------------------------------
--  DDL for Package Body OKL_CSH_ALLCT_RULES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CSH_ALLCT_RULES_PVT_W" as
  /* $Header: OKLECSAB.pls 120.1 2005/09/20 13:40:58 dkagrawa noship $ */
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

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
  )

  as
    ddp_cahv_rec okl_csh_allct_rules_pvt.cahv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_cahv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_cahv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_cahv_rec.name := p5_a2;
    ddp_cahv_rec.description := p5_a3;
    ddp_cahv_rec.sequence_number := rosetta_g_miss_num_map(p5_a4);
    ddp_cahv_rec.attribute_category := p5_a5;
    ddp_cahv_rec.attribute1 := p5_a6;
    ddp_cahv_rec.attribute2 := p5_a7;
    ddp_cahv_rec.attribute3 := p5_a8;
    ddp_cahv_rec.attribute4 := p5_a9;
    ddp_cahv_rec.attribute5 := p5_a10;
    ddp_cahv_rec.attribute6 := p5_a11;
    ddp_cahv_rec.attribute7 := p5_a12;
    ddp_cahv_rec.attribute8 := p5_a13;
    ddp_cahv_rec.attribute9 := p5_a14;
    ddp_cahv_rec.attribute10 := p5_a15;
    ddp_cahv_rec.attribute11 := p5_a16;
    ddp_cahv_rec.attribute12 := p5_a17;
    ddp_cahv_rec.attribute13 := p5_a18;
    ddp_cahv_rec.attribute14 := p5_a19;
    ddp_cahv_rec.attribute15 := p5_a20;
    ddp_cahv_rec.org_id := rosetta_g_miss_num_map(p5_a21);
    ddp_cahv_rec.cash_search_type := p5_a22;
    ddp_cahv_rec.created_by := rosetta_g_miss_num_map(p5_a23);
    ddp_cahv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_cahv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a25);
    ddp_cahv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_cahv_rec.last_update_login := rosetta_g_miss_num_map(p5_a27);

    -- here's the delegated call to the old PL/SQL routine
    okl_csh_allct_rules_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cahv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_csh_allct_rules_pvt_w;

/
