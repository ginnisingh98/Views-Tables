--------------------------------------------------------
--  DDL for Package Body AS_INTEREST_CODES_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_INTEREST_CODES_PUB_W" as
  /* $Header: asxwincb.pls 115.0 2003/10/09 14:52:57 gbatra noship $ */
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

  procedure create_interest_code(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_interest_code_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  NUMBER := 0-1962.0724
    , p7_a38  NUMBER := 0-1962.0724
  )

  as
    ddp_interest_code_rec as_interest_codes_pub.interest_code_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_interest_code_rec.interest_code_id := rosetta_g_miss_num_map(p7_a0);
    ddp_interest_code_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_interest_code_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_interest_code_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_interest_code_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_interest_code_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_interest_code_rec.request_id := rosetta_g_miss_num_map(p7_a6);
    ddp_interest_code_rec.program_application_id := rosetta_g_miss_num_map(p7_a7);
    ddp_interest_code_rec.program_id := rosetta_g_miss_num_map(p7_a8);
    ddp_interest_code_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_interest_code_rec.interest_type_id := rosetta_g_miss_num_map(p7_a10);
    ddp_interest_code_rec.parent_interest_code_id := rosetta_g_miss_num_map(p7_a11);
    ddp_interest_code_rec.master_enabled_flag := p7_a12;
    ddp_interest_code_rec.category_id := rosetta_g_miss_num_map(p7_a13);
    ddp_interest_code_rec.category_set_id := rosetta_g_miss_num_map(p7_a14);
    ddp_interest_code_rec.pf_item_id := rosetta_g_miss_num_map(p7_a15);
    ddp_interest_code_rec.pf_organization_id := rosetta_g_miss_num_map(p7_a16);
    ddp_interest_code_rec.currency_code := p7_a17;
    ddp_interest_code_rec.price := rosetta_g_miss_num_map(p7_a18);
    ddp_interest_code_rec.attribute_category := p7_a19;
    ddp_interest_code_rec.attribute1 := p7_a20;
    ddp_interest_code_rec.attribute2 := p7_a21;
    ddp_interest_code_rec.attribute3 := p7_a22;
    ddp_interest_code_rec.attribute4 := p7_a23;
    ddp_interest_code_rec.attribute5 := p7_a24;
    ddp_interest_code_rec.attribute6 := p7_a25;
    ddp_interest_code_rec.attribute7 := p7_a26;
    ddp_interest_code_rec.attribute8 := p7_a27;
    ddp_interest_code_rec.attribute9 := p7_a28;
    ddp_interest_code_rec.attribute10 := p7_a29;
    ddp_interest_code_rec.attribute11 := p7_a30;
    ddp_interest_code_rec.attribute12 := p7_a31;
    ddp_interest_code_rec.attribute13 := p7_a32;
    ddp_interest_code_rec.attribute14 := p7_a33;
    ddp_interest_code_rec.attribute15 := p7_a34;
    ddp_interest_code_rec.code := p7_a35;
    ddp_interest_code_rec.description := p7_a36;
    ddp_interest_code_rec.prod_cat_set_id := rosetta_g_miss_num_map(p7_a37);
    ddp_interest_code_rec.prod_cat_id := rosetta_g_miss_num_map(p7_a38);


    -- here's the delegated call to the old PL/SQL routine
    as_interest_codes_pub.create_interest_code(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_interest_code_rec,
      x_interest_code_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_interest_code(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  NUMBER := 0-1962.0724
    , p7_a38  NUMBER := 0-1962.0724
  )

  as
    ddp_interest_code_rec as_interest_codes_pub.interest_code_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_interest_code_rec.interest_code_id := rosetta_g_miss_num_map(p7_a0);
    ddp_interest_code_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_interest_code_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_interest_code_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_interest_code_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_interest_code_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_interest_code_rec.request_id := rosetta_g_miss_num_map(p7_a6);
    ddp_interest_code_rec.program_application_id := rosetta_g_miss_num_map(p7_a7);
    ddp_interest_code_rec.program_id := rosetta_g_miss_num_map(p7_a8);
    ddp_interest_code_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_interest_code_rec.interest_type_id := rosetta_g_miss_num_map(p7_a10);
    ddp_interest_code_rec.parent_interest_code_id := rosetta_g_miss_num_map(p7_a11);
    ddp_interest_code_rec.master_enabled_flag := p7_a12;
    ddp_interest_code_rec.category_id := rosetta_g_miss_num_map(p7_a13);
    ddp_interest_code_rec.category_set_id := rosetta_g_miss_num_map(p7_a14);
    ddp_interest_code_rec.pf_item_id := rosetta_g_miss_num_map(p7_a15);
    ddp_interest_code_rec.pf_organization_id := rosetta_g_miss_num_map(p7_a16);
    ddp_interest_code_rec.currency_code := p7_a17;
    ddp_interest_code_rec.price := rosetta_g_miss_num_map(p7_a18);
    ddp_interest_code_rec.attribute_category := p7_a19;
    ddp_interest_code_rec.attribute1 := p7_a20;
    ddp_interest_code_rec.attribute2 := p7_a21;
    ddp_interest_code_rec.attribute3 := p7_a22;
    ddp_interest_code_rec.attribute4 := p7_a23;
    ddp_interest_code_rec.attribute5 := p7_a24;
    ddp_interest_code_rec.attribute6 := p7_a25;
    ddp_interest_code_rec.attribute7 := p7_a26;
    ddp_interest_code_rec.attribute8 := p7_a27;
    ddp_interest_code_rec.attribute9 := p7_a28;
    ddp_interest_code_rec.attribute10 := p7_a29;
    ddp_interest_code_rec.attribute11 := p7_a30;
    ddp_interest_code_rec.attribute12 := p7_a31;
    ddp_interest_code_rec.attribute13 := p7_a32;
    ddp_interest_code_rec.attribute14 := p7_a33;
    ddp_interest_code_rec.attribute15 := p7_a34;
    ddp_interest_code_rec.code := p7_a35;
    ddp_interest_code_rec.description := p7_a36;
    ddp_interest_code_rec.prod_cat_set_id := rosetta_g_miss_num_map(p7_a37);
    ddp_interest_code_rec.prod_cat_id := rosetta_g_miss_num_map(p7_a38);

    -- here's the delegated call to the old PL/SQL routine
    as_interest_codes_pub.update_interest_code(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_interest_code_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end as_interest_codes_pub_w;

/
