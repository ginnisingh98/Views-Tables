--------------------------------------------------------
--  DDL for Package Body AS_INTEREST_TYPES_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_INTEREST_TYPES_PUB_W" as
  /* $Header: asxwinyb.pls 115.0 2003/10/09 14:52:58 gbatra noship $ */
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

  procedure create_interest_type(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_interest_type_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_interest_type_rec as_interest_types_pub.interest_type_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_interest_type_rec.interest_type_id := rosetta_g_miss_num_map(p7_a0);
    ddp_interest_type_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_interest_type_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_interest_type_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_interest_type_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_interest_type_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_interest_type_rec.master_enabled_flag := p7_a6;
    ddp_interest_type_rec.interest_type := p7_a7;
    ddp_interest_type_rec.company_classification_flag := p7_a8;
    ddp_interest_type_rec.contact_interest_flag := p7_a9;
    ddp_interest_type_rec.lead_classification_flag := p7_a10;
    ddp_interest_type_rec.expected_purchase_flag := p7_a11;
    ddp_interest_type_rec.current_environment_flag := p7_a12;
    ddp_interest_type_rec.enabled_flag := p7_a13;
    ddp_interest_type_rec.org_id := rosetta_g_miss_num_map(p7_a14);
    ddp_interest_type_rec.description := p7_a15;
    ddp_interest_type_rec.prod_cat_set_id := rosetta_g_miss_num_map(p7_a16);
    ddp_interest_type_rec.prod_cat_id := rosetta_g_miss_num_map(p7_a17);


    -- here's the delegated call to the old PL/SQL routine
    as_interest_types_pub.create_interest_type(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_interest_type_rec,
      x_interest_type_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_interest_type(p_api_version_number  NUMBER
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
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_interest_type_rec as_interest_types_pub.interest_type_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_interest_type_rec.interest_type_id := rosetta_g_miss_num_map(p7_a0);
    ddp_interest_type_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_interest_type_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_interest_type_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_interest_type_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_interest_type_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_interest_type_rec.master_enabled_flag := p7_a6;
    ddp_interest_type_rec.interest_type := p7_a7;
    ddp_interest_type_rec.company_classification_flag := p7_a8;
    ddp_interest_type_rec.contact_interest_flag := p7_a9;
    ddp_interest_type_rec.lead_classification_flag := p7_a10;
    ddp_interest_type_rec.expected_purchase_flag := p7_a11;
    ddp_interest_type_rec.current_environment_flag := p7_a12;
    ddp_interest_type_rec.enabled_flag := p7_a13;
    ddp_interest_type_rec.org_id := rosetta_g_miss_num_map(p7_a14);
    ddp_interest_type_rec.description := p7_a15;
    ddp_interest_type_rec.prod_cat_set_id := rosetta_g_miss_num_map(p7_a16);
    ddp_interest_type_rec.prod_cat_id := rosetta_g_miss_num_map(p7_a17);

    -- here's the delegated call to the old PL/SQL routine
    as_interest_types_pub.update_interest_type(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_interest_type_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end as_interest_types_pub_w;

/
