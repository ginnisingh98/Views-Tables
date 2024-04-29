--------------------------------------------------------
--  DDL for Package Body HZ_CONTACT_POINT_V2PUB_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CONTACT_POINT_V2PUB_JW" as
  /* $Header: ARH2CPJB.pls 120.3 2005/06/18 04:27:35 jhuang noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_contact_point_1(p_init_msg_list  VARCHAR2
    , x_contact_point_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  VARCHAR2 := null
    , p2_a1  VARCHAR2 := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  VARCHAR2 := null
    , p2_a4  VARCHAR2 := null
    , p2_a5  VARCHAR2 := null
    , p2_a6  NUMBER := null
    , p2_a7  VARCHAR2 := null
    , p3_a0  VARCHAR2 := null
    , p3_a1  VARCHAR2 := null
    , p4_a0  VARCHAR2 := null
    , p4_a1  DATE := null
    , p4_a2  NUMBER := null
    , p4_a3  VARCHAR2 := null
    , p4_a4  VARCHAR2 := null
    , p4_a5  VARCHAR2 := null
    , p4_a6  VARCHAR2 := null
    , p4_a7  VARCHAR2 := null
    , p4_a8  VARCHAR2 := null
    , p5_a0  VARCHAR2 := null
    , p6_a0  VARCHAR2 := null
    , p6_a1  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_edi_rec hz_contact_point_v2pub.edi_rec_type;
    ddp_email_rec hz_contact_point_v2pub.email_rec_type;
    ddp_phone_rec hz_contact_point_v2pub.phone_rec_type;
    ddp_telex_rec hz_contact_point_v2pub.telex_rec_type;
    ddp_web_rec hz_contact_point_v2pub.web_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_edi_rec.edi_transaction_handling := p2_a0;
    ddp_edi_rec.edi_id_number := p2_a1;
    ddp_edi_rec.edi_payment_method := p2_a2;
    ddp_edi_rec.edi_payment_format := p2_a3;
    ddp_edi_rec.edi_remittance_method := p2_a4;
    ddp_edi_rec.edi_remittance_instruction := p2_a5;
    ddp_edi_rec.edi_tp_header_id := rosetta_g_miss_num_map(p2_a6);
    ddp_edi_rec.edi_ece_tp_location_code := p2_a7;

    ddp_email_rec.email_format := p3_a0;
    ddp_email_rec.email_address := p3_a1;

    ddp_phone_rec.phone_calling_calendar := p4_a0;
    ddp_phone_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p4_a1);
    ddp_phone_rec.timezone_id := rosetta_g_miss_num_map(p4_a2);
    ddp_phone_rec.phone_area_code := p4_a3;
    ddp_phone_rec.phone_country_code := p4_a4;
    ddp_phone_rec.phone_number := p4_a5;
    ddp_phone_rec.phone_extension := p4_a6;
    ddp_phone_rec.phone_line_type := p4_a7;
    ddp_phone_rec.raw_phone_number := p4_a8;

    ddp_telex_rec.telex_number := p5_a0;

    ddp_web_rec.web_type := p6_a0;
    ddp_web_rec.url := p6_a1;





    -- here's the delegated call to the old PL/SQL routine
    hz_contact_point_v2pub.create_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_edi_rec,
      ddp_email_rec,
      ddp_phone_rec,
      ddp_telex_rec,
      ddp_web_rec,
      x_contact_point_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any










  end;

  procedure create_edi_contact_point_2(p_init_msg_list  VARCHAR2
    , x_contact_point_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  VARCHAR2 := null
    , p2_a1  VARCHAR2 := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  VARCHAR2 := null
    , p2_a4  VARCHAR2 := null
    , p2_a5  VARCHAR2 := null
    , p2_a6  NUMBER := null
    , p2_a7  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_edi_rec hz_contact_point_v2pub.edi_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_edi_rec.edi_transaction_handling := p2_a0;
    ddp_edi_rec.edi_id_number := p2_a1;
    ddp_edi_rec.edi_payment_method := p2_a2;
    ddp_edi_rec.edi_payment_format := p2_a3;
    ddp_edi_rec.edi_remittance_method := p2_a4;
    ddp_edi_rec.edi_remittance_instruction := p2_a5;
    ddp_edi_rec.edi_tp_header_id := rosetta_g_miss_num_map(p2_a6);
    ddp_edi_rec.edi_ece_tp_location_code := p2_a7;





    -- here's the delegated call to the old PL/SQL routine
    hz_contact_point_v2pub.create_edi_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_edi_rec,
      x_contact_point_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure create_web_contact_point_3(p_init_msg_list  VARCHAR2
    , x_contact_point_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  VARCHAR2 := null
    , p2_a1  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_web_rec hz_contact_point_v2pub.web_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_web_rec.web_type := p2_a0;
    ddp_web_rec.url := p2_a1;





    -- here's the delegated call to the old PL/SQL routine
    hz_contact_point_v2pub.create_web_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_web_rec,
      x_contact_point_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure create_eft_contact_point_4(p_init_msg_list  VARCHAR2
    , x_contact_point_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  NUMBER := null
    , p2_a1  NUMBER := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_eft_rec hz_contact_point_v2pub.eft_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_eft_rec.eft_transmission_program_id := rosetta_g_miss_num_map(p2_a0);
    ddp_eft_rec.eft_printing_program_id := rosetta_g_miss_num_map(p2_a1);
    ddp_eft_rec.eft_user_number := p2_a2;
    ddp_eft_rec.eft_swift_code := p2_a3;





    -- here's the delegated call to the old PL/SQL routine
    hz_contact_point_v2pub.create_eft_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_eft_rec,
      x_contact_point_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure create_phone_contact_point_5(p_init_msg_list  VARCHAR2
    , x_contact_point_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  VARCHAR2 := null
    , p2_a1  DATE := null
    , p2_a2  NUMBER := null
    , p2_a3  VARCHAR2 := null
    , p2_a4  VARCHAR2 := null
    , p2_a5  VARCHAR2 := null
    , p2_a6  VARCHAR2 := null
    , p2_a7  VARCHAR2 := null
    , p2_a8  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_phone_rec hz_contact_point_v2pub.phone_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_phone_rec.phone_calling_calendar := p2_a0;
    ddp_phone_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p2_a1);
    ddp_phone_rec.timezone_id := rosetta_g_miss_num_map(p2_a2);
    ddp_phone_rec.phone_area_code := p2_a3;
    ddp_phone_rec.phone_country_code := p2_a4;
    ddp_phone_rec.phone_number := p2_a5;
    ddp_phone_rec.phone_extension := p2_a6;
    ddp_phone_rec.phone_line_type := p2_a7;
    ddp_phone_rec.raw_phone_number := p2_a8;





    -- here's the delegated call to the old PL/SQL routine
    hz_contact_point_v2pub.create_phone_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_phone_rec,
      x_contact_point_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure create_telex_contact_point_6(p_init_msg_list  VARCHAR2
    , x_contact_point_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_telex_rec hz_contact_point_v2pub.telex_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_telex_rec.telex_number := p2_a0;





    -- here's the delegated call to the old PL/SQL routine
    hz_contact_point_v2pub.create_telex_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_telex_rec,
      x_contact_point_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure create_email_contact_point_7(p_init_msg_list  VARCHAR2
    , x_contact_point_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  VARCHAR2 := null
    , p2_a1  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_email_rec hz_contact_point_v2pub.email_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_email_rec.email_format := p2_a0;
    ddp_email_rec.email_address := p2_a1;





    -- here's the delegated call to the old PL/SQL routine
    hz_contact_point_v2pub.create_email_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_email_rec,
      x_contact_point_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure update_contact_point_8(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  VARCHAR2 := null
    , p2_a1  VARCHAR2 := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  VARCHAR2 := null
    , p2_a4  VARCHAR2 := null
    , p2_a5  VARCHAR2 := null
    , p2_a6  NUMBER := null
    , p2_a7  VARCHAR2 := null
    , p3_a0  VARCHAR2 := null
    , p3_a1  VARCHAR2 := null
    , p4_a0  VARCHAR2 := null
    , p4_a1  DATE := null
    , p4_a2  NUMBER := null
    , p4_a3  VARCHAR2 := null
    , p4_a4  VARCHAR2 := null
    , p4_a5  VARCHAR2 := null
    , p4_a6  VARCHAR2 := null
    , p4_a7  VARCHAR2 := null
    , p4_a8  VARCHAR2 := null
    , p5_a0  VARCHAR2 := null
    , p6_a0  VARCHAR2 := null
    , p6_a1  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_edi_rec hz_contact_point_v2pub.edi_rec_type;
    ddp_email_rec hz_contact_point_v2pub.email_rec_type;
    ddp_phone_rec hz_contact_point_v2pub.phone_rec_type;
    ddp_telex_rec hz_contact_point_v2pub.telex_rec_type;
    ddp_web_rec hz_contact_point_v2pub.web_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_edi_rec.edi_transaction_handling := p2_a0;
    ddp_edi_rec.edi_id_number := p2_a1;
    ddp_edi_rec.edi_payment_method := p2_a2;
    ddp_edi_rec.edi_payment_format := p2_a3;
    ddp_edi_rec.edi_remittance_method := p2_a4;
    ddp_edi_rec.edi_remittance_instruction := p2_a5;
    ddp_edi_rec.edi_tp_header_id := rosetta_g_miss_num_map(p2_a6);
    ddp_edi_rec.edi_ece_tp_location_code := p2_a7;

    ddp_email_rec.email_format := p3_a0;
    ddp_email_rec.email_address := p3_a1;

    ddp_phone_rec.phone_calling_calendar := p4_a0;
    ddp_phone_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p4_a1);
    ddp_phone_rec.timezone_id := rosetta_g_miss_num_map(p4_a2);
    ddp_phone_rec.phone_area_code := p4_a3;
    ddp_phone_rec.phone_country_code := p4_a4;
    ddp_phone_rec.phone_number := p4_a5;
    ddp_phone_rec.phone_extension := p4_a6;
    ddp_phone_rec.phone_line_type := p4_a7;
    ddp_phone_rec.raw_phone_number := p4_a8;

    ddp_telex_rec.telex_number := p5_a0;

    ddp_web_rec.web_type := p6_a0;
    ddp_web_rec.url := p6_a1;





    -- here's the delegated call to the old PL/SQL routine
    hz_contact_point_v2pub.update_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_edi_rec,
      ddp_email_rec,
      ddp_phone_rec,
      ddp_telex_rec,
      ddp_web_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any










  end;

  procedure update_edi_contact_point_9(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  VARCHAR2 := null
    , p2_a1  VARCHAR2 := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  VARCHAR2 := null
    , p2_a4  VARCHAR2 := null
    , p2_a5  VARCHAR2 := null
    , p2_a6  NUMBER := null
    , p2_a7  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_edi_rec hz_contact_point_v2pub.edi_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_edi_rec.edi_transaction_handling := p2_a0;
    ddp_edi_rec.edi_id_number := p2_a1;
    ddp_edi_rec.edi_payment_method := p2_a2;
    ddp_edi_rec.edi_payment_format := p2_a3;
    ddp_edi_rec.edi_remittance_method := p2_a4;
    ddp_edi_rec.edi_remittance_instruction := p2_a5;
    ddp_edi_rec.edi_tp_header_id := rosetta_g_miss_num_map(p2_a6);
    ddp_edi_rec.edi_ece_tp_location_code := p2_a7;





    -- here's the delegated call to the old PL/SQL routine
    hz_contact_point_v2pub.update_edi_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_edi_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure update_web_contact_point_10(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  VARCHAR2 := null
    , p2_a1  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_web_rec hz_contact_point_v2pub.web_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_web_rec.web_type := p2_a0;
    ddp_web_rec.url := p2_a1;





    -- here's the delegated call to the old PL/SQL routine
    hz_contact_point_v2pub.update_web_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_web_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure update_eft_contact_point_11(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  NUMBER := null
    , p2_a1  NUMBER := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_eft_rec hz_contact_point_v2pub.eft_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_eft_rec.eft_transmission_program_id := rosetta_g_miss_num_map(p2_a0);
    ddp_eft_rec.eft_printing_program_id := rosetta_g_miss_num_map(p2_a1);
    ddp_eft_rec.eft_user_number := p2_a2;
    ddp_eft_rec.eft_swift_code := p2_a3;





    -- here's the delegated call to the old PL/SQL routine
    hz_contact_point_v2pub.update_eft_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_eft_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure update_phone_contact_point_12(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  VARCHAR2 := null
    , p2_a1  DATE := null
    , p2_a2  NUMBER := null
    , p2_a3  VARCHAR2 := null
    , p2_a4  VARCHAR2 := null
    , p2_a5  VARCHAR2 := null
    , p2_a6  VARCHAR2 := null
    , p2_a7  VARCHAR2 := null
    , p2_a8  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_phone_rec hz_contact_point_v2pub.phone_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_phone_rec.phone_calling_calendar := p2_a0;
    ddp_phone_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p2_a1);
    ddp_phone_rec.timezone_id := rosetta_g_miss_num_map(p2_a2);
    ddp_phone_rec.phone_area_code := p2_a3;
    ddp_phone_rec.phone_country_code := p2_a4;
    ddp_phone_rec.phone_number := p2_a5;
    ddp_phone_rec.phone_extension := p2_a6;
    ddp_phone_rec.phone_line_type := p2_a7;
    ddp_phone_rec.raw_phone_number := p2_a8;





    -- here's the delegated call to the old PL/SQL routine
    hz_contact_point_v2pub.update_phone_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_phone_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure update_telex_contact_point_13(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_telex_rec hz_contact_point_v2pub.telex_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_telex_rec.telex_number := p2_a0;





    -- here's the delegated call to the old PL/SQL routine
    hz_contact_point_v2pub.update_telex_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_telex_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure update_email_contact_point_14(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  NUMBER := null
    , p1_a34  VARCHAR2 := null
    , p2_a0  VARCHAR2 := null
    , p2_a1  VARCHAR2 := null
  )
  as
    ddp_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddp_email_rec hz_contact_point_v2pub.email_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p1_a0);
    ddp_contact_point_rec.contact_point_type := p1_a1;
    ddp_contact_point_rec.status := p1_a2;
    ddp_contact_point_rec.owner_table_name := p1_a3;
    ddp_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p1_a4);
    ddp_contact_point_rec.primary_flag := p1_a5;
    ddp_contact_point_rec.orig_system_reference := p1_a6;
    ddp_contact_point_rec.orig_system := p1_a7;
    ddp_contact_point_rec.content_source_type := p1_a8;
    ddp_contact_point_rec.attribute_category := p1_a9;
    ddp_contact_point_rec.attribute1 := p1_a10;
    ddp_contact_point_rec.attribute2 := p1_a11;
    ddp_contact_point_rec.attribute3 := p1_a12;
    ddp_contact_point_rec.attribute4 := p1_a13;
    ddp_contact_point_rec.attribute5 := p1_a14;
    ddp_contact_point_rec.attribute6 := p1_a15;
    ddp_contact_point_rec.attribute7 := p1_a16;
    ddp_contact_point_rec.attribute8 := p1_a17;
    ddp_contact_point_rec.attribute9 := p1_a18;
    ddp_contact_point_rec.attribute10 := p1_a19;
    ddp_contact_point_rec.attribute11 := p1_a20;
    ddp_contact_point_rec.attribute12 := p1_a21;
    ddp_contact_point_rec.attribute13 := p1_a22;
    ddp_contact_point_rec.attribute14 := p1_a23;
    ddp_contact_point_rec.attribute15 := p1_a24;
    ddp_contact_point_rec.attribute16 := p1_a25;
    ddp_contact_point_rec.attribute17 := p1_a26;
    ddp_contact_point_rec.attribute18 := p1_a27;
    ddp_contact_point_rec.attribute19 := p1_a28;
    ddp_contact_point_rec.attribute20 := p1_a29;
    ddp_contact_point_rec.contact_point_purpose := p1_a30;
    ddp_contact_point_rec.primary_by_purpose := p1_a31;
    ddp_contact_point_rec.created_by_module := p1_a32;
    ddp_contact_point_rec.application_id := rosetta_g_miss_num_map(p1_a33);
    ddp_contact_point_rec.actual_content_source := p1_a34;

    ddp_email_rec.email_format := p2_a0;
    ddp_email_rec.email_address := p2_a1;





    -- here's the delegated call to the old PL/SQL routine
    hz_contact_point_v2pub.update_email_contact_point(p_init_msg_list,
      ddp_contact_point_rec,
      ddp_email_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure get_contact_point_rec_15(p_init_msg_list  VARCHAR2
    , p_contact_point_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  NUMBER
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  VARCHAR2
    , p2_a13 out nocopy  VARCHAR2
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  VARCHAR2
    , p2_a21 out nocopy  VARCHAR2
    , p2_a22 out nocopy  VARCHAR2
    , p2_a23 out nocopy  VARCHAR2
    , p2_a24 out nocopy  VARCHAR2
    , p2_a25 out nocopy  VARCHAR2
    , p2_a26 out nocopy  VARCHAR2
    , p2_a27 out nocopy  VARCHAR2
    , p2_a28 out nocopy  VARCHAR2
    , p2_a29 out nocopy  VARCHAR2
    , p2_a30 out nocopy  VARCHAR2
    , p2_a31 out nocopy  VARCHAR2
    , p2_a32 out nocopy  VARCHAR2
    , p2_a33 out nocopy  NUMBER
    , p2_a34 out nocopy  VARCHAR2
    , p3_a0 out nocopy  VARCHAR2
    , p3_a1 out nocopy  VARCHAR2
    , p3_a2 out nocopy  VARCHAR2
    , p3_a3 out nocopy  VARCHAR2
    , p3_a4 out nocopy  VARCHAR2
    , p3_a5 out nocopy  VARCHAR2
    , p3_a6 out nocopy  NUMBER
    , p3_a7 out nocopy  VARCHAR2
    , p4_a0 out nocopy  VARCHAR2
    , p4_a1 out nocopy  VARCHAR2
    , p5_a0 out nocopy  VARCHAR2
    , p5_a1 out nocopy  DATE
    , p5_a2 out nocopy  NUMBER
    , p5_a3 out nocopy  VARCHAR2
    , p5_a4 out nocopy  VARCHAR2
    , p5_a5 out nocopy  VARCHAR2
    , p5_a6 out nocopy  VARCHAR2
    , p5_a7 out nocopy  VARCHAR2
    , p5_a8 out nocopy  VARCHAR2
    , p6_a0 out nocopy  VARCHAR2
    , p7_a0 out nocopy  VARCHAR2
    , p7_a1 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddx_edi_rec hz_contact_point_v2pub.edi_rec_type;
    ddx_email_rec hz_contact_point_v2pub.email_rec_type;
    ddx_phone_rec hz_contact_point_v2pub.phone_rec_type;
    ddx_telex_rec hz_contact_point_v2pub.telex_rec_type;
    ddx_web_rec hz_contact_point_v2pub.web_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    hz_contact_point_v2pub.get_contact_point_rec(p_init_msg_list,
      p_contact_point_id,
      ddx_contact_point_rec,
      ddx_edi_rec,
      ddx_email_rec,
      ddx_phone_rec,
      ddx_telex_rec,
      ddx_web_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_contact_point_rec.contact_point_id);
    p2_a1 := ddx_contact_point_rec.contact_point_type;
    p2_a2 := ddx_contact_point_rec.status;
    p2_a3 := ddx_contact_point_rec.owner_table_name;
    p2_a4 := rosetta_g_miss_num_map(ddx_contact_point_rec.owner_table_id);
    p2_a5 := ddx_contact_point_rec.primary_flag;
    p2_a6 := ddx_contact_point_rec.orig_system_reference;
    p2_a7 := ddx_contact_point_rec.orig_system;
    p2_a8 := ddx_contact_point_rec.content_source_type;
    p2_a9 := ddx_contact_point_rec.attribute_category;
    p2_a10 := ddx_contact_point_rec.attribute1;
    p2_a11 := ddx_contact_point_rec.attribute2;
    p2_a12 := ddx_contact_point_rec.attribute3;
    p2_a13 := ddx_contact_point_rec.attribute4;
    p2_a14 := ddx_contact_point_rec.attribute5;
    p2_a15 := ddx_contact_point_rec.attribute6;
    p2_a16 := ddx_contact_point_rec.attribute7;
    p2_a17 := ddx_contact_point_rec.attribute8;
    p2_a18 := ddx_contact_point_rec.attribute9;
    p2_a19 := ddx_contact_point_rec.attribute10;
    p2_a20 := ddx_contact_point_rec.attribute11;
    p2_a21 := ddx_contact_point_rec.attribute12;
    p2_a22 := ddx_contact_point_rec.attribute13;
    p2_a23 := ddx_contact_point_rec.attribute14;
    p2_a24 := ddx_contact_point_rec.attribute15;
    p2_a25 := ddx_contact_point_rec.attribute16;
    p2_a26 := ddx_contact_point_rec.attribute17;
    p2_a27 := ddx_contact_point_rec.attribute18;
    p2_a28 := ddx_contact_point_rec.attribute19;
    p2_a29 := ddx_contact_point_rec.attribute20;
    p2_a30 := ddx_contact_point_rec.contact_point_purpose;
    p2_a31 := ddx_contact_point_rec.primary_by_purpose;
    p2_a32 := ddx_contact_point_rec.created_by_module;
    p2_a33 := rosetta_g_miss_num_map(ddx_contact_point_rec.application_id);
    p2_a34 := ddx_contact_point_rec.actual_content_source;

    p3_a0 := ddx_edi_rec.edi_transaction_handling;
    p3_a1 := ddx_edi_rec.edi_id_number;
    p3_a2 := ddx_edi_rec.edi_payment_method;
    p3_a3 := ddx_edi_rec.edi_payment_format;
    p3_a4 := ddx_edi_rec.edi_remittance_method;
    p3_a5 := ddx_edi_rec.edi_remittance_instruction;
    p3_a6 := rosetta_g_miss_num_map(ddx_edi_rec.edi_tp_header_id);
    p3_a7 := ddx_edi_rec.edi_ece_tp_location_code;

    p4_a0 := ddx_email_rec.email_format;
    p4_a1 := ddx_email_rec.email_address;

    p5_a0 := ddx_phone_rec.phone_calling_calendar;
    p5_a1 := ddx_phone_rec.last_contact_dt_time;
    p5_a2 := rosetta_g_miss_num_map(ddx_phone_rec.timezone_id);
    p5_a3 := ddx_phone_rec.phone_area_code;
    p5_a4 := ddx_phone_rec.phone_country_code;
    p5_a5 := ddx_phone_rec.phone_number;
    p5_a6 := ddx_phone_rec.phone_extension;
    p5_a7 := ddx_phone_rec.phone_line_type;
    p5_a8 := ddx_phone_rec.raw_phone_number;

    p6_a0 := ddx_telex_rec.telex_number;

    p7_a0 := ddx_web_rec.web_type;
    p7_a1 := ddx_web_rec.url;



  end;

  procedure get_edi_contact_point_16(p_init_msg_list  VARCHAR2
    , p_contact_point_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  NUMBER
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  VARCHAR2
    , p2_a13 out nocopy  VARCHAR2
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  VARCHAR2
    , p2_a21 out nocopy  VARCHAR2
    , p2_a22 out nocopy  VARCHAR2
    , p2_a23 out nocopy  VARCHAR2
    , p2_a24 out nocopy  VARCHAR2
    , p2_a25 out nocopy  VARCHAR2
    , p2_a26 out nocopy  VARCHAR2
    , p2_a27 out nocopy  VARCHAR2
    , p2_a28 out nocopy  VARCHAR2
    , p2_a29 out nocopy  VARCHAR2
    , p2_a30 out nocopy  VARCHAR2
    , p2_a31 out nocopy  VARCHAR2
    , p2_a32 out nocopy  VARCHAR2
    , p2_a33 out nocopy  NUMBER
    , p2_a34 out nocopy  VARCHAR2
    , p3_a0 out nocopy  VARCHAR2
    , p3_a1 out nocopy  VARCHAR2
    , p3_a2 out nocopy  VARCHAR2
    , p3_a3 out nocopy  VARCHAR2
    , p3_a4 out nocopy  VARCHAR2
    , p3_a5 out nocopy  VARCHAR2
    , p3_a6 out nocopy  NUMBER
    , p3_a7 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddx_edi_rec hz_contact_point_v2pub.edi_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    hz_contact_point_v2pub.get_edi_contact_point(p_init_msg_list,
      p_contact_point_id,
      ddx_contact_point_rec,
      ddx_edi_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_contact_point_rec.contact_point_id);
    p2_a1 := ddx_contact_point_rec.contact_point_type;
    p2_a2 := ddx_contact_point_rec.status;
    p2_a3 := ddx_contact_point_rec.owner_table_name;
    p2_a4 := rosetta_g_miss_num_map(ddx_contact_point_rec.owner_table_id);
    p2_a5 := ddx_contact_point_rec.primary_flag;
    p2_a6 := ddx_contact_point_rec.orig_system_reference;
    p2_a7 := ddx_contact_point_rec.orig_system;
    p2_a8 := ddx_contact_point_rec.content_source_type;
    p2_a9 := ddx_contact_point_rec.attribute_category;
    p2_a10 := ddx_contact_point_rec.attribute1;
    p2_a11 := ddx_contact_point_rec.attribute2;
    p2_a12 := ddx_contact_point_rec.attribute3;
    p2_a13 := ddx_contact_point_rec.attribute4;
    p2_a14 := ddx_contact_point_rec.attribute5;
    p2_a15 := ddx_contact_point_rec.attribute6;
    p2_a16 := ddx_contact_point_rec.attribute7;
    p2_a17 := ddx_contact_point_rec.attribute8;
    p2_a18 := ddx_contact_point_rec.attribute9;
    p2_a19 := ddx_contact_point_rec.attribute10;
    p2_a20 := ddx_contact_point_rec.attribute11;
    p2_a21 := ddx_contact_point_rec.attribute12;
    p2_a22 := ddx_contact_point_rec.attribute13;
    p2_a23 := ddx_contact_point_rec.attribute14;
    p2_a24 := ddx_contact_point_rec.attribute15;
    p2_a25 := ddx_contact_point_rec.attribute16;
    p2_a26 := ddx_contact_point_rec.attribute17;
    p2_a27 := ddx_contact_point_rec.attribute18;
    p2_a28 := ddx_contact_point_rec.attribute19;
    p2_a29 := ddx_contact_point_rec.attribute20;
    p2_a30 := ddx_contact_point_rec.contact_point_purpose;
    p2_a31 := ddx_contact_point_rec.primary_by_purpose;
    p2_a32 := ddx_contact_point_rec.created_by_module;
    p2_a33 := rosetta_g_miss_num_map(ddx_contact_point_rec.application_id);
    p2_a34 := ddx_contact_point_rec.actual_content_source;

    p3_a0 := ddx_edi_rec.edi_transaction_handling;
    p3_a1 := ddx_edi_rec.edi_id_number;
    p3_a2 := ddx_edi_rec.edi_payment_method;
    p3_a3 := ddx_edi_rec.edi_payment_format;
    p3_a4 := ddx_edi_rec.edi_remittance_method;
    p3_a5 := ddx_edi_rec.edi_remittance_instruction;
    p3_a6 := rosetta_g_miss_num_map(ddx_edi_rec.edi_tp_header_id);
    p3_a7 := ddx_edi_rec.edi_ece_tp_location_code;



  end;

  procedure get_eft_contact_point_17(p_init_msg_list  VARCHAR2
    , p_contact_point_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  NUMBER
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  VARCHAR2
    , p2_a13 out nocopy  VARCHAR2
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  VARCHAR2
    , p2_a21 out nocopy  VARCHAR2
    , p2_a22 out nocopy  VARCHAR2
    , p2_a23 out nocopy  VARCHAR2
    , p2_a24 out nocopy  VARCHAR2
    , p2_a25 out nocopy  VARCHAR2
    , p2_a26 out nocopy  VARCHAR2
    , p2_a27 out nocopy  VARCHAR2
    , p2_a28 out nocopy  VARCHAR2
    , p2_a29 out nocopy  VARCHAR2
    , p2_a30 out nocopy  VARCHAR2
    , p2_a31 out nocopy  VARCHAR2
    , p2_a32 out nocopy  VARCHAR2
    , p2_a33 out nocopy  NUMBER
    , p2_a34 out nocopy  VARCHAR2
    , p3_a0 out nocopy  NUMBER
    , p3_a1 out nocopy  NUMBER
    , p3_a2 out nocopy  VARCHAR2
    , p3_a3 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddx_eft_rec hz_contact_point_v2pub.eft_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    hz_contact_point_v2pub.get_eft_contact_point(p_init_msg_list,
      p_contact_point_id,
      ddx_contact_point_rec,
      ddx_eft_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_contact_point_rec.contact_point_id);
    p2_a1 := ddx_contact_point_rec.contact_point_type;
    p2_a2 := ddx_contact_point_rec.status;
    p2_a3 := ddx_contact_point_rec.owner_table_name;
    p2_a4 := rosetta_g_miss_num_map(ddx_contact_point_rec.owner_table_id);
    p2_a5 := ddx_contact_point_rec.primary_flag;
    p2_a6 := ddx_contact_point_rec.orig_system_reference;
    p2_a7 := ddx_contact_point_rec.orig_system;
    p2_a8 := ddx_contact_point_rec.content_source_type;
    p2_a9 := ddx_contact_point_rec.attribute_category;
    p2_a10 := ddx_contact_point_rec.attribute1;
    p2_a11 := ddx_contact_point_rec.attribute2;
    p2_a12 := ddx_contact_point_rec.attribute3;
    p2_a13 := ddx_contact_point_rec.attribute4;
    p2_a14 := ddx_contact_point_rec.attribute5;
    p2_a15 := ddx_contact_point_rec.attribute6;
    p2_a16 := ddx_contact_point_rec.attribute7;
    p2_a17 := ddx_contact_point_rec.attribute8;
    p2_a18 := ddx_contact_point_rec.attribute9;
    p2_a19 := ddx_contact_point_rec.attribute10;
    p2_a20 := ddx_contact_point_rec.attribute11;
    p2_a21 := ddx_contact_point_rec.attribute12;
    p2_a22 := ddx_contact_point_rec.attribute13;
    p2_a23 := ddx_contact_point_rec.attribute14;
    p2_a24 := ddx_contact_point_rec.attribute15;
    p2_a25 := ddx_contact_point_rec.attribute16;
    p2_a26 := ddx_contact_point_rec.attribute17;
    p2_a27 := ddx_contact_point_rec.attribute18;
    p2_a28 := ddx_contact_point_rec.attribute19;
    p2_a29 := ddx_contact_point_rec.attribute20;
    p2_a30 := ddx_contact_point_rec.contact_point_purpose;
    p2_a31 := ddx_contact_point_rec.primary_by_purpose;
    p2_a32 := ddx_contact_point_rec.created_by_module;
    p2_a33 := rosetta_g_miss_num_map(ddx_contact_point_rec.application_id);
    p2_a34 := ddx_contact_point_rec.actual_content_source;

    p3_a0 := rosetta_g_miss_num_map(ddx_eft_rec.eft_transmission_program_id);
    p3_a1 := rosetta_g_miss_num_map(ddx_eft_rec.eft_printing_program_id);
    p3_a2 := ddx_eft_rec.eft_user_number;
    p3_a3 := ddx_eft_rec.eft_swift_code;



  end;

  procedure get_web_contact_point_18(p_init_msg_list  VARCHAR2
    , p_contact_point_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  NUMBER
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  VARCHAR2
    , p2_a13 out nocopy  VARCHAR2
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  VARCHAR2
    , p2_a21 out nocopy  VARCHAR2
    , p2_a22 out nocopy  VARCHAR2
    , p2_a23 out nocopy  VARCHAR2
    , p2_a24 out nocopy  VARCHAR2
    , p2_a25 out nocopy  VARCHAR2
    , p2_a26 out nocopy  VARCHAR2
    , p2_a27 out nocopy  VARCHAR2
    , p2_a28 out nocopy  VARCHAR2
    , p2_a29 out nocopy  VARCHAR2
    , p2_a30 out nocopy  VARCHAR2
    , p2_a31 out nocopy  VARCHAR2
    , p2_a32 out nocopy  VARCHAR2
    , p2_a33 out nocopy  NUMBER
    , p2_a34 out nocopy  VARCHAR2
    , p3_a0 out nocopy  VARCHAR2
    , p3_a1 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddx_web_rec hz_contact_point_v2pub.web_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    hz_contact_point_v2pub.get_web_contact_point(p_init_msg_list,
      p_contact_point_id,
      ddx_contact_point_rec,
      ddx_web_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_contact_point_rec.contact_point_id);
    p2_a1 := ddx_contact_point_rec.contact_point_type;
    p2_a2 := ddx_contact_point_rec.status;
    p2_a3 := ddx_contact_point_rec.owner_table_name;
    p2_a4 := rosetta_g_miss_num_map(ddx_contact_point_rec.owner_table_id);
    p2_a5 := ddx_contact_point_rec.primary_flag;
    p2_a6 := ddx_contact_point_rec.orig_system_reference;
    p2_a7 := ddx_contact_point_rec.orig_system;
    p2_a8 := ddx_contact_point_rec.content_source_type;
    p2_a9 := ddx_contact_point_rec.attribute_category;
    p2_a10 := ddx_contact_point_rec.attribute1;
    p2_a11 := ddx_contact_point_rec.attribute2;
    p2_a12 := ddx_contact_point_rec.attribute3;
    p2_a13 := ddx_contact_point_rec.attribute4;
    p2_a14 := ddx_contact_point_rec.attribute5;
    p2_a15 := ddx_contact_point_rec.attribute6;
    p2_a16 := ddx_contact_point_rec.attribute7;
    p2_a17 := ddx_contact_point_rec.attribute8;
    p2_a18 := ddx_contact_point_rec.attribute9;
    p2_a19 := ddx_contact_point_rec.attribute10;
    p2_a20 := ddx_contact_point_rec.attribute11;
    p2_a21 := ddx_contact_point_rec.attribute12;
    p2_a22 := ddx_contact_point_rec.attribute13;
    p2_a23 := ddx_contact_point_rec.attribute14;
    p2_a24 := ddx_contact_point_rec.attribute15;
    p2_a25 := ddx_contact_point_rec.attribute16;
    p2_a26 := ddx_contact_point_rec.attribute17;
    p2_a27 := ddx_contact_point_rec.attribute18;
    p2_a28 := ddx_contact_point_rec.attribute19;
    p2_a29 := ddx_contact_point_rec.attribute20;
    p2_a30 := ddx_contact_point_rec.contact_point_purpose;
    p2_a31 := ddx_contact_point_rec.primary_by_purpose;
    p2_a32 := ddx_contact_point_rec.created_by_module;
    p2_a33 := rosetta_g_miss_num_map(ddx_contact_point_rec.application_id);
    p2_a34 := ddx_contact_point_rec.actual_content_source;

    p3_a0 := ddx_web_rec.web_type;
    p3_a1 := ddx_web_rec.url;



  end;

  procedure get_phone_contact_point_19(p_init_msg_list  VARCHAR2
    , p_contact_point_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  NUMBER
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  VARCHAR2
    , p2_a13 out nocopy  VARCHAR2
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  VARCHAR2
    , p2_a21 out nocopy  VARCHAR2
    , p2_a22 out nocopy  VARCHAR2
    , p2_a23 out nocopy  VARCHAR2
    , p2_a24 out nocopy  VARCHAR2
    , p2_a25 out nocopy  VARCHAR2
    , p2_a26 out nocopy  VARCHAR2
    , p2_a27 out nocopy  VARCHAR2
    , p2_a28 out nocopy  VARCHAR2
    , p2_a29 out nocopy  VARCHAR2
    , p2_a30 out nocopy  VARCHAR2
    , p2_a31 out nocopy  VARCHAR2
    , p2_a32 out nocopy  VARCHAR2
    , p2_a33 out nocopy  NUMBER
    , p2_a34 out nocopy  VARCHAR2
    , p3_a0 out nocopy  VARCHAR2
    , p3_a1 out nocopy  DATE
    , p3_a2 out nocopy  NUMBER
    , p3_a3 out nocopy  VARCHAR2
    , p3_a4 out nocopy  VARCHAR2
    , p3_a5 out nocopy  VARCHAR2
    , p3_a6 out nocopy  VARCHAR2
    , p3_a7 out nocopy  VARCHAR2
    , p3_a8 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddx_phone_rec hz_contact_point_v2pub.phone_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    hz_contact_point_v2pub.get_phone_contact_point(p_init_msg_list,
      p_contact_point_id,
      ddx_contact_point_rec,
      ddx_phone_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_contact_point_rec.contact_point_id);
    p2_a1 := ddx_contact_point_rec.contact_point_type;
    p2_a2 := ddx_contact_point_rec.status;
    p2_a3 := ddx_contact_point_rec.owner_table_name;
    p2_a4 := rosetta_g_miss_num_map(ddx_contact_point_rec.owner_table_id);
    p2_a5 := ddx_contact_point_rec.primary_flag;
    p2_a6 := ddx_contact_point_rec.orig_system_reference;
    p2_a7 := ddx_contact_point_rec.orig_system;
    p2_a8 := ddx_contact_point_rec.content_source_type;
    p2_a9 := ddx_contact_point_rec.attribute_category;
    p2_a10 := ddx_contact_point_rec.attribute1;
    p2_a11 := ddx_contact_point_rec.attribute2;
    p2_a12 := ddx_contact_point_rec.attribute3;
    p2_a13 := ddx_contact_point_rec.attribute4;
    p2_a14 := ddx_contact_point_rec.attribute5;
    p2_a15 := ddx_contact_point_rec.attribute6;
    p2_a16 := ddx_contact_point_rec.attribute7;
    p2_a17 := ddx_contact_point_rec.attribute8;
    p2_a18 := ddx_contact_point_rec.attribute9;
    p2_a19 := ddx_contact_point_rec.attribute10;
    p2_a20 := ddx_contact_point_rec.attribute11;
    p2_a21 := ddx_contact_point_rec.attribute12;
    p2_a22 := ddx_contact_point_rec.attribute13;
    p2_a23 := ddx_contact_point_rec.attribute14;
    p2_a24 := ddx_contact_point_rec.attribute15;
    p2_a25 := ddx_contact_point_rec.attribute16;
    p2_a26 := ddx_contact_point_rec.attribute17;
    p2_a27 := ddx_contact_point_rec.attribute18;
    p2_a28 := ddx_contact_point_rec.attribute19;
    p2_a29 := ddx_contact_point_rec.attribute20;
    p2_a30 := ddx_contact_point_rec.contact_point_purpose;
    p2_a31 := ddx_contact_point_rec.primary_by_purpose;
    p2_a32 := ddx_contact_point_rec.created_by_module;
    p2_a33 := rosetta_g_miss_num_map(ddx_contact_point_rec.application_id);
    p2_a34 := ddx_contact_point_rec.actual_content_source;

    p3_a0 := ddx_phone_rec.phone_calling_calendar;
    p3_a1 := ddx_phone_rec.last_contact_dt_time;
    p3_a2 := rosetta_g_miss_num_map(ddx_phone_rec.timezone_id);
    p3_a3 := ddx_phone_rec.phone_area_code;
    p3_a4 := ddx_phone_rec.phone_country_code;
    p3_a5 := ddx_phone_rec.phone_number;
    p3_a6 := ddx_phone_rec.phone_extension;
    p3_a7 := ddx_phone_rec.phone_line_type;
    p3_a8 := ddx_phone_rec.raw_phone_number;



  end;

  procedure get_telex_contact_point_20(p_init_msg_list  VARCHAR2
    , p_contact_point_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  NUMBER
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  VARCHAR2
    , p2_a13 out nocopy  VARCHAR2
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  VARCHAR2
    , p2_a21 out nocopy  VARCHAR2
    , p2_a22 out nocopy  VARCHAR2
    , p2_a23 out nocopy  VARCHAR2
    , p2_a24 out nocopy  VARCHAR2
    , p2_a25 out nocopy  VARCHAR2
    , p2_a26 out nocopy  VARCHAR2
    , p2_a27 out nocopy  VARCHAR2
    , p2_a28 out nocopy  VARCHAR2
    , p2_a29 out nocopy  VARCHAR2
    , p2_a30 out nocopy  VARCHAR2
    , p2_a31 out nocopy  VARCHAR2
    , p2_a32 out nocopy  VARCHAR2
    , p2_a33 out nocopy  NUMBER
    , p2_a34 out nocopy  VARCHAR2
    , p3_a0 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddx_telex_rec hz_contact_point_v2pub.telex_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    hz_contact_point_v2pub.get_telex_contact_point(p_init_msg_list,
      p_contact_point_id,
      ddx_contact_point_rec,
      ddx_telex_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_contact_point_rec.contact_point_id);
    p2_a1 := ddx_contact_point_rec.contact_point_type;
    p2_a2 := ddx_contact_point_rec.status;
    p2_a3 := ddx_contact_point_rec.owner_table_name;
    p2_a4 := rosetta_g_miss_num_map(ddx_contact_point_rec.owner_table_id);
    p2_a5 := ddx_contact_point_rec.primary_flag;
    p2_a6 := ddx_contact_point_rec.orig_system_reference;
    p2_a7 := ddx_contact_point_rec.orig_system;
    p2_a8 := ddx_contact_point_rec.content_source_type;
    p2_a9 := ddx_contact_point_rec.attribute_category;
    p2_a10 := ddx_contact_point_rec.attribute1;
    p2_a11 := ddx_contact_point_rec.attribute2;
    p2_a12 := ddx_contact_point_rec.attribute3;
    p2_a13 := ddx_contact_point_rec.attribute4;
    p2_a14 := ddx_contact_point_rec.attribute5;
    p2_a15 := ddx_contact_point_rec.attribute6;
    p2_a16 := ddx_contact_point_rec.attribute7;
    p2_a17 := ddx_contact_point_rec.attribute8;
    p2_a18 := ddx_contact_point_rec.attribute9;
    p2_a19 := ddx_contact_point_rec.attribute10;
    p2_a20 := ddx_contact_point_rec.attribute11;
    p2_a21 := ddx_contact_point_rec.attribute12;
    p2_a22 := ddx_contact_point_rec.attribute13;
    p2_a23 := ddx_contact_point_rec.attribute14;
    p2_a24 := ddx_contact_point_rec.attribute15;
    p2_a25 := ddx_contact_point_rec.attribute16;
    p2_a26 := ddx_contact_point_rec.attribute17;
    p2_a27 := ddx_contact_point_rec.attribute18;
    p2_a28 := ddx_contact_point_rec.attribute19;
    p2_a29 := ddx_contact_point_rec.attribute20;
    p2_a30 := ddx_contact_point_rec.contact_point_purpose;
    p2_a31 := ddx_contact_point_rec.primary_by_purpose;
    p2_a32 := ddx_contact_point_rec.created_by_module;
    p2_a33 := rosetta_g_miss_num_map(ddx_contact_point_rec.application_id);
    p2_a34 := ddx_contact_point_rec.actual_content_source;

    p3_a0 := ddx_telex_rec.telex_number;



  end;

  procedure get_email_contact_point_21(p_init_msg_list  VARCHAR2
    , p_contact_point_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  NUMBER
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  VARCHAR2
    , p2_a13 out nocopy  VARCHAR2
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  VARCHAR2
    , p2_a21 out nocopy  VARCHAR2
    , p2_a22 out nocopy  VARCHAR2
    , p2_a23 out nocopy  VARCHAR2
    , p2_a24 out nocopy  VARCHAR2
    , p2_a25 out nocopy  VARCHAR2
    , p2_a26 out nocopy  VARCHAR2
    , p2_a27 out nocopy  VARCHAR2
    , p2_a28 out nocopy  VARCHAR2
    , p2_a29 out nocopy  VARCHAR2
    , p2_a30 out nocopy  VARCHAR2
    , p2_a31 out nocopy  VARCHAR2
    , p2_a32 out nocopy  VARCHAR2
    , p2_a33 out nocopy  NUMBER
    , p2_a34 out nocopy  VARCHAR2
    , p3_a0 out nocopy  VARCHAR2
    , p3_a1 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    ddx_email_rec hz_contact_point_v2pub.email_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    hz_contact_point_v2pub.get_email_contact_point(p_init_msg_list,
      p_contact_point_id,
      ddx_contact_point_rec,
      ddx_email_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_contact_point_rec.contact_point_id);
    p2_a1 := ddx_contact_point_rec.contact_point_type;
    p2_a2 := ddx_contact_point_rec.status;
    p2_a3 := ddx_contact_point_rec.owner_table_name;
    p2_a4 := rosetta_g_miss_num_map(ddx_contact_point_rec.owner_table_id);
    p2_a5 := ddx_contact_point_rec.primary_flag;
    p2_a6 := ddx_contact_point_rec.orig_system_reference;
    p2_a7 := ddx_contact_point_rec.orig_system;
    p2_a8 := ddx_contact_point_rec.content_source_type;
    p2_a9 := ddx_contact_point_rec.attribute_category;
    p2_a10 := ddx_contact_point_rec.attribute1;
    p2_a11 := ddx_contact_point_rec.attribute2;
    p2_a12 := ddx_contact_point_rec.attribute3;
    p2_a13 := ddx_contact_point_rec.attribute4;
    p2_a14 := ddx_contact_point_rec.attribute5;
    p2_a15 := ddx_contact_point_rec.attribute6;
    p2_a16 := ddx_contact_point_rec.attribute7;
    p2_a17 := ddx_contact_point_rec.attribute8;
    p2_a18 := ddx_contact_point_rec.attribute9;
    p2_a19 := ddx_contact_point_rec.attribute10;
    p2_a20 := ddx_contact_point_rec.attribute11;
    p2_a21 := ddx_contact_point_rec.attribute12;
    p2_a22 := ddx_contact_point_rec.attribute13;
    p2_a23 := ddx_contact_point_rec.attribute14;
    p2_a24 := ddx_contact_point_rec.attribute15;
    p2_a25 := ddx_contact_point_rec.attribute16;
    p2_a26 := ddx_contact_point_rec.attribute17;
    p2_a27 := ddx_contact_point_rec.attribute18;
    p2_a28 := ddx_contact_point_rec.attribute19;
    p2_a29 := ddx_contact_point_rec.attribute20;
    p2_a30 := ddx_contact_point_rec.contact_point_purpose;
    p2_a31 := ddx_contact_point_rec.primary_by_purpose;
    p2_a32 := ddx_contact_point_rec.created_by_module;
    p2_a33 := rosetta_g_miss_num_map(ddx_contact_point_rec.application_id);
    p2_a34 := ddx_contact_point_rec.actual_content_source;

    p3_a0 := ddx_email_rec.email_format;
    p3_a1 := ddx_email_rec.email_address;



  end;

end hz_contact_point_v2pub_jw;

/
