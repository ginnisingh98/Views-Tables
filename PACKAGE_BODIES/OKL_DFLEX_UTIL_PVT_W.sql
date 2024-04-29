--------------------------------------------------------
--  DDL for Package Body OKL_DFLEX_UTIL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_DFLEX_UTIL_PVT_W" as
  /* $Header: OKLEDFUB.pls 120.1 2005/11/25 10:33:55 dkagrawa noship $ */
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

  procedure validate_desc_flex(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_appl_short_name  VARCHAR2
    , p_descflex_name  VARCHAR2
    , p_segment_partial_name  VARCHAR2
    , p8_a0  VARCHAR2 := fnd_api.g_miss_char
    , p8_a1  VARCHAR2 := fnd_api.g_miss_char
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  VARCHAR2 := fnd_api.g_miss_char
    , p8_a4  VARCHAR2 := fnd_api.g_miss_char
    , p8_a5  VARCHAR2 := fnd_api.g_miss_char
    , p8_a6  VARCHAR2 := fnd_api.g_miss_char
    , p8_a7  VARCHAR2 := fnd_api.g_miss_char
    , p8_a8  VARCHAR2 := fnd_api.g_miss_char
    , p8_a9  VARCHAR2 := fnd_api.g_miss_char
    , p8_a10  VARCHAR2 := fnd_api.g_miss_char
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
    , p8_a12  VARCHAR2 := fnd_api.g_miss_char
    , p8_a13  VARCHAR2 := fnd_api.g_miss_char
    , p8_a14  VARCHAR2 := fnd_api.g_miss_char
    , p8_a15  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_segment_values_rec okl_dflex_util_pvt.dff_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_segment_values_rec.attribute_category := p8_a0;
    ddp_segment_values_rec.attribute1 := p8_a1;
    ddp_segment_values_rec.attribute2 := p8_a2;
    ddp_segment_values_rec.attribute3 := p8_a3;
    ddp_segment_values_rec.attribute4 := p8_a4;
    ddp_segment_values_rec.attribute5 := p8_a5;
    ddp_segment_values_rec.attribute6 := p8_a6;
    ddp_segment_values_rec.attribute7 := p8_a7;
    ddp_segment_values_rec.attribute8 := p8_a8;
    ddp_segment_values_rec.attribute9 := p8_a9;
    ddp_segment_values_rec.attribute10 := p8_a10;
    ddp_segment_values_rec.attribute11 := p8_a11;
    ddp_segment_values_rec.attribute12 := p8_a12;
    ddp_segment_values_rec.attribute13 := p8_a13;
    ddp_segment_values_rec.attribute14 := p8_a14;
    ddp_segment_values_rec.attribute15 := p8_a15;

    -- here's the delegated call to the old PL/SQL routine
    okl_dflex_util_pvt.validate_desc_flex(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_appl_short_name,
      p_descflex_name,
      p_segment_partial_name,
      ddp_segment_values_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_contract_add_info(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p6_a0  VARCHAR2 := fnd_api.g_miss_char
    , p6_a1  VARCHAR2 := fnd_api.g_miss_char
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  VARCHAR2 := fnd_api.g_miss_char
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  VARCHAR2 := fnd_api.g_miss_char
    , p6_a6  VARCHAR2 := fnd_api.g_miss_char
    , p6_a7  VARCHAR2 := fnd_api.g_miss_char
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_add_info_rec okl_dflex_util_pvt.dff_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_add_info_rec.attribute_category := p6_a0;
    ddp_add_info_rec.attribute1 := p6_a1;
    ddp_add_info_rec.attribute2 := p6_a2;
    ddp_add_info_rec.attribute3 := p6_a3;
    ddp_add_info_rec.attribute4 := p6_a4;
    ddp_add_info_rec.attribute5 := p6_a5;
    ddp_add_info_rec.attribute6 := p6_a6;
    ddp_add_info_rec.attribute7 := p6_a7;
    ddp_add_info_rec.attribute8 := p6_a8;
    ddp_add_info_rec.attribute9 := p6_a9;
    ddp_add_info_rec.attribute10 := p6_a10;
    ddp_add_info_rec.attribute11 := p6_a11;
    ddp_add_info_rec.attribute12 := p6_a12;
    ddp_add_info_rec.attribute13 := p6_a13;
    ddp_add_info_rec.attribute14 := p6_a14;
    ddp_add_info_rec.attribute15 := p6_a15;

    -- here's the delegated call to the old PL/SQL routine
    okl_dflex_util_pvt.update_contract_add_info(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      ddp_add_info_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure update_line_add_info(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_cle_id  NUMBER
    , p6_a0  VARCHAR2 := fnd_api.g_miss_char
    , p6_a1  VARCHAR2 := fnd_api.g_miss_char
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  VARCHAR2 := fnd_api.g_miss_char
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  VARCHAR2 := fnd_api.g_miss_char
    , p6_a6  VARCHAR2 := fnd_api.g_miss_char
    , p6_a7  VARCHAR2 := fnd_api.g_miss_char
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_add_info_rec okl_dflex_util_pvt.dff_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_add_info_rec.attribute_category := p6_a0;
    ddp_add_info_rec.attribute1 := p6_a1;
    ddp_add_info_rec.attribute2 := p6_a2;
    ddp_add_info_rec.attribute3 := p6_a3;
    ddp_add_info_rec.attribute4 := p6_a4;
    ddp_add_info_rec.attribute5 := p6_a5;
    ddp_add_info_rec.attribute6 := p6_a6;
    ddp_add_info_rec.attribute7 := p6_a7;
    ddp_add_info_rec.attribute8 := p6_a8;
    ddp_add_info_rec.attribute9 := p6_a9;
    ddp_add_info_rec.attribute10 := p6_a10;
    ddp_add_info_rec.attribute11 := p6_a11;
    ddp_add_info_rec.attribute12 := p6_a12;
    ddp_add_info_rec.attribute13 := p6_a13;
    ddp_add_info_rec.attribute14 := p6_a14;
    ddp_add_info_rec.attribute15 := p6_a15;

    -- here's the delegated call to the old PL/SQL routine
    okl_dflex_util_pvt.update_line_add_info(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_cle_id,
      ddp_add_info_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end okl_dflex_util_pvt_w;

/
