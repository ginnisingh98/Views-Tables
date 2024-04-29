--------------------------------------------------------
--  DDL for Package Body OZF_VOLUME_OFFER_QUAL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_VOLUME_OFFER_QUAL_PVT_W" as
  /* $Header: ozfwvoqb.pls 120.1 2006/07/24 21:08:00 rssharma noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_high date := to_date('01/01/+4710', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_low date := to_date('01/01/-4710', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d > rosetta_g_mistake_date_high then return fnd_api.g_miss_date; end if;
    if d < rosetta_g_mistake_date_low then return fnd_api.g_miss_date; end if;
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

  procedure create_vo_qualifier(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  VARCHAR2 := fnd_api.g_miss_char
    , p7_a1  VARCHAR2 := fnd_api.g_miss_char
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  DATE := fnd_api.g_miss_date
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
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
  )

  as
    ddp_qualifiers_rec ozf_offer_pvt.qualifiers_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_qualifiers_rec.qualifier_context := p7_a0;
    ddp_qualifiers_rec.qualifier_attribute := p7_a1;
    ddp_qualifiers_rec.qualifier_attr_value := p7_a2;
    ddp_qualifiers_rec.qualifier_attr_value_to := p7_a3;
    ddp_qualifiers_rec.comparison_operator_code := p7_a4;
    ddp_qualifiers_rec.qualifier_grouping_no := rosetta_g_miss_num_map(p7_a5);
    ddp_qualifiers_rec.list_line_id := rosetta_g_miss_num_map(p7_a6);
    ddp_qualifiers_rec.list_header_id := rosetta_g_miss_num_map(p7_a7);
    ddp_qualifiers_rec.qualifier_id := rosetta_g_miss_num_map(p7_a8);
    ddp_qualifiers_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a9);
    ddp_qualifiers_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a10);
    ddp_qualifiers_rec.activity_market_segment_id := rosetta_g_miss_num_map(p7_a11);
    ddp_qualifiers_rec.operation := p7_a12;
    ddp_qualifiers_rec.context := p7_a13;
    ddp_qualifiers_rec.attribute1 := p7_a14;
    ddp_qualifiers_rec.attribute2 := p7_a15;
    ddp_qualifiers_rec.attribute3 := p7_a16;
    ddp_qualifiers_rec.attribute4 := p7_a17;
    ddp_qualifiers_rec.attribute5 := p7_a18;
    ddp_qualifiers_rec.attribute6 := p7_a19;
    ddp_qualifiers_rec.attribute7 := p7_a20;
    ddp_qualifiers_rec.attribute8 := p7_a21;
    ddp_qualifiers_rec.attribute9 := p7_a22;
    ddp_qualifiers_rec.attribute10 := p7_a23;
    ddp_qualifiers_rec.attribute11 := p7_a24;
    ddp_qualifiers_rec.attribute12 := p7_a25;
    ddp_qualifiers_rec.attribute13 := p7_a26;
    ddp_qualifiers_rec.attribute14 := p7_a27;
    ddp_qualifiers_rec.attribute15 := p7_a28;

    -- here's the delegated call to the old PL/SQL routine
    ozf_volume_offer_qual_pvt.create_vo_qualifier(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qualifiers_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure update_vo_qualifier(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  VARCHAR2 := fnd_api.g_miss_char
    , p7_a1  VARCHAR2 := fnd_api.g_miss_char
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  DATE := fnd_api.g_miss_date
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
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
  )

  as
    ddp_qualifiers_rec ozf_offer_pvt.qualifiers_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_qualifiers_rec.qualifier_context := p7_a0;
    ddp_qualifiers_rec.qualifier_attribute := p7_a1;
    ddp_qualifiers_rec.qualifier_attr_value := p7_a2;
    ddp_qualifiers_rec.qualifier_attr_value_to := p7_a3;
    ddp_qualifiers_rec.comparison_operator_code := p7_a4;
    ddp_qualifiers_rec.qualifier_grouping_no := rosetta_g_miss_num_map(p7_a5);
    ddp_qualifiers_rec.list_line_id := rosetta_g_miss_num_map(p7_a6);
    ddp_qualifiers_rec.list_header_id := rosetta_g_miss_num_map(p7_a7);
    ddp_qualifiers_rec.qualifier_id := rosetta_g_miss_num_map(p7_a8);
    ddp_qualifiers_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a9);
    ddp_qualifiers_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a10);
    ddp_qualifiers_rec.activity_market_segment_id := rosetta_g_miss_num_map(p7_a11);
    ddp_qualifiers_rec.operation := p7_a12;
    ddp_qualifiers_rec.context := p7_a13;
    ddp_qualifiers_rec.attribute1 := p7_a14;
    ddp_qualifiers_rec.attribute2 := p7_a15;
    ddp_qualifiers_rec.attribute3 := p7_a16;
    ddp_qualifiers_rec.attribute4 := p7_a17;
    ddp_qualifiers_rec.attribute5 := p7_a18;
    ddp_qualifiers_rec.attribute6 := p7_a19;
    ddp_qualifiers_rec.attribute7 := p7_a20;
    ddp_qualifiers_rec.attribute8 := p7_a21;
    ddp_qualifiers_rec.attribute9 := p7_a22;
    ddp_qualifiers_rec.attribute10 := p7_a23;
    ddp_qualifiers_rec.attribute11 := p7_a24;
    ddp_qualifiers_rec.attribute12 := p7_a25;
    ddp_qualifiers_rec.attribute13 := p7_a26;
    ddp_qualifiers_rec.attribute14 := p7_a27;
    ddp_qualifiers_rec.attribute15 := p7_a28;

    -- here's the delegated call to the old PL/SQL routine
    ozf_volume_offer_qual_pvt.update_vo_qualifier(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qualifiers_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end ozf_volume_offer_qual_pvt_w;

/
