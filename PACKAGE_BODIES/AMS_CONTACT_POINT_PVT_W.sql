--------------------------------------------------------
--  DDL for Package Body AMS_CONTACT_POINT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CONTACT_POINT_PVT_W" as
  /* $Header: amswcptb.pls 115.3 2002/11/22 08:56:59 jieli ship $ */
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

  procedure create_contact_point(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_contact_point_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  VARCHAR2 := fnd_api.g_miss_char
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
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
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  NUMBER := 0-1962.0724
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p8_a0  VARCHAR2 := fnd_api.g_miss_char
    , p8_a1  VARCHAR2 := fnd_api.g_miss_char
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  VARCHAR2 := fnd_api.g_miss_char
    , p8_a4  VARCHAR2 := fnd_api.g_miss_char
    , p8_a5  VARCHAR2 := fnd_api.g_miss_char
    , p8_a6  NUMBER := 0-1962.0724
    , p8_a7  VARCHAR2 := fnd_api.g_miss_char
    , p9_a0  VARCHAR2 := fnd_api.g_miss_char
    , p9_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a0  VARCHAR2 := fnd_api.g_miss_char
    , p10_a1  DATE := fnd_api.g_miss_date
    , p10_a2  NUMBER := 0-1962.0724
    , p10_a3  VARCHAR2 := fnd_api.g_miss_char
    , p10_a4  VARCHAR2 := fnd_api.g_miss_char
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  VARCHAR2 := fnd_api.g_miss_char
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
    , p10_a8  VARCHAR2 := fnd_api.g_miss_char
    , p11_a0  VARCHAR2 := fnd_api.g_miss_char
    , p12_a0  VARCHAR2 := fnd_api.g_miss_char
    , p12_a1  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_ams_contact_point_rec ams_contact_point_pvt.contact_point_rec_type;
    ddp_ams_edi_rec ams_contact_point_pvt.edi_rec_type;
    ddp_ams_email_rec ams_contact_point_pvt.email_rec_type;
    ddp_ams_phone_rec ams_contact_point_pvt.phone_rec_type;
    ddp_ams_telex_rec ams_contact_point_pvt.telex_rec_type;
    ddp_ams_web_rec ams_contact_point_pvt.web_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ams_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p7_a0);
    ddp_ams_contact_point_rec.contact_point_type := p7_a1;
    ddp_ams_contact_point_rec.status := p7_a2;
    ddp_ams_contact_point_rec.owner_table_name := p7_a3;
    ddp_ams_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p7_a4);
    ddp_ams_contact_point_rec.primary_flag := p7_a5;
    ddp_ams_contact_point_rec.orig_system_reference := p7_a6;
    ddp_ams_contact_point_rec.content_source_type := p7_a7;
    ddp_ams_contact_point_rec.attribute_category := p7_a8;
    ddp_ams_contact_point_rec.attribute1 := p7_a9;
    ddp_ams_contact_point_rec.attribute2 := p7_a10;
    ddp_ams_contact_point_rec.attribute3 := p7_a11;
    ddp_ams_contact_point_rec.attribute4 := p7_a12;
    ddp_ams_contact_point_rec.attribute5 := p7_a13;
    ddp_ams_contact_point_rec.attribute6 := p7_a14;
    ddp_ams_contact_point_rec.attribute7 := p7_a15;
    ddp_ams_contact_point_rec.attribute8 := p7_a16;
    ddp_ams_contact_point_rec.attribute9 := p7_a17;
    ddp_ams_contact_point_rec.attribute10 := p7_a18;
    ddp_ams_contact_point_rec.attribute11 := p7_a19;
    ddp_ams_contact_point_rec.attribute12 := p7_a20;
    ddp_ams_contact_point_rec.attribute13 := p7_a21;
    ddp_ams_contact_point_rec.attribute14 := p7_a22;
    ddp_ams_contact_point_rec.attribute15 := p7_a23;
    ddp_ams_contact_point_rec.attribute16 := p7_a24;
    ddp_ams_contact_point_rec.attribute17 := p7_a25;
    ddp_ams_contact_point_rec.attribute18 := p7_a26;
    ddp_ams_contact_point_rec.attribute19 := p7_a27;
    ddp_ams_contact_point_rec.attribute20 := p7_a28;
    ddp_ams_contact_point_rec.contact_point_purpose := p7_a29;
    ddp_ams_contact_point_rec.primary_by_purpose := p7_a30;
    ddp_ams_contact_point_rec.created_by_module := p7_a31;
    ddp_ams_contact_point_rec.application_id := rosetta_g_miss_num_map(p7_a32);
    ddp_ams_contact_point_rec.actual_content_source := p7_a33;

    ddp_ams_edi_rec.edi_transaction_handling := p8_a0;
    ddp_ams_edi_rec.edi_id_number := p8_a1;
    ddp_ams_edi_rec.edi_payment_method := p8_a2;
    ddp_ams_edi_rec.edi_payment_format := p8_a3;
    ddp_ams_edi_rec.edi_remittance_method := p8_a4;
    ddp_ams_edi_rec.edi_remittance_instruction := p8_a5;
    ddp_ams_edi_rec.edi_tp_header_id := rosetta_g_miss_num_map(p8_a6);
    ddp_ams_edi_rec.edi_ece_tp_location_code := p8_a7;

    ddp_ams_email_rec.email_format := p9_a0;
    ddp_ams_email_rec.email_address := p9_a1;

    ddp_ams_phone_rec.phone_calling_calendar := p10_a0;
    ddp_ams_phone_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p10_a1);
    ddp_ams_phone_rec.timezone_id := rosetta_g_miss_num_map(p10_a2);
    ddp_ams_phone_rec.phone_area_code := p10_a3;
    ddp_ams_phone_rec.phone_country_code := p10_a4;
    ddp_ams_phone_rec.phone_number := p10_a5;
    ddp_ams_phone_rec.phone_extension := p10_a6;
    ddp_ams_phone_rec.phone_line_type := p10_a7;
    ddp_ams_phone_rec.raw_phone_number := p10_a8;

    ddp_ams_telex_rec.telex_number := p11_a0;

    ddp_ams_web_rec.web_type := p12_a0;
    ddp_ams_web_rec.url := p12_a1;


    -- here's the delegated call to the old PL/SQL routine
    ams_contact_point_pvt.create_contact_point(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ams_contact_point_rec,
      ddp_ams_edi_rec,
      ddp_ams_email_rec,
      ddp_ams_phone_rec,
      ddp_ams_telex_rec,
      ddp_ams_web_rec,
      x_contact_point_id);

    -- copy data back from the local OUT or IN-OUT args, if any













  end;

  procedure update_contact_point(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , px_object_version_number in OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  VARCHAR2 := fnd_api.g_miss_char
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
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
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  NUMBER := 0-1962.0724
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p8_a0  VARCHAR2 := fnd_api.g_miss_char
    , p8_a1  VARCHAR2 := fnd_api.g_miss_char
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  VARCHAR2 := fnd_api.g_miss_char
    , p8_a4  VARCHAR2 := fnd_api.g_miss_char
    , p8_a5  VARCHAR2 := fnd_api.g_miss_char
    , p8_a6  NUMBER := 0-1962.0724
    , p8_a7  VARCHAR2 := fnd_api.g_miss_char
    , p9_a0  VARCHAR2 := fnd_api.g_miss_char
    , p9_a1  VARCHAR2 := fnd_api.g_miss_char
    , p10_a0  VARCHAR2 := fnd_api.g_miss_char
    , p10_a1  DATE := fnd_api.g_miss_date
    , p10_a2  NUMBER := 0-1962.0724
    , p10_a3  VARCHAR2 := fnd_api.g_miss_char
    , p10_a4  VARCHAR2 := fnd_api.g_miss_char
    , p10_a5  VARCHAR2 := fnd_api.g_miss_char
    , p10_a6  VARCHAR2 := fnd_api.g_miss_char
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
    , p10_a8  VARCHAR2 := fnd_api.g_miss_char
    , p11_a0  VARCHAR2 := fnd_api.g_miss_char
    , p12_a0  VARCHAR2 := fnd_api.g_miss_char
    , p12_a1  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_ams_contact_point_rec ams_contact_point_pvt.contact_point_rec_type;
    ddp_ams_edi_rec ams_contact_point_pvt.edi_rec_type;
    ddp_ams_email_rec ams_contact_point_pvt.email_rec_type;
    ddp_ams_phone_rec ams_contact_point_pvt.phone_rec_type;
    ddp_ams_telex_rec ams_contact_point_pvt.telex_rec_type;
    ddp_ams_web_rec ams_contact_point_pvt.web_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ams_contact_point_rec.contact_point_id := rosetta_g_miss_num_map(p7_a0);
    ddp_ams_contact_point_rec.contact_point_type := p7_a1;
    ddp_ams_contact_point_rec.status := p7_a2;
    ddp_ams_contact_point_rec.owner_table_name := p7_a3;
    ddp_ams_contact_point_rec.owner_table_id := rosetta_g_miss_num_map(p7_a4);
    ddp_ams_contact_point_rec.primary_flag := p7_a5;
    ddp_ams_contact_point_rec.orig_system_reference := p7_a6;
    ddp_ams_contact_point_rec.content_source_type := p7_a7;
    ddp_ams_contact_point_rec.attribute_category := p7_a8;
    ddp_ams_contact_point_rec.attribute1 := p7_a9;
    ddp_ams_contact_point_rec.attribute2 := p7_a10;
    ddp_ams_contact_point_rec.attribute3 := p7_a11;
    ddp_ams_contact_point_rec.attribute4 := p7_a12;
    ddp_ams_contact_point_rec.attribute5 := p7_a13;
    ddp_ams_contact_point_rec.attribute6 := p7_a14;
    ddp_ams_contact_point_rec.attribute7 := p7_a15;
    ddp_ams_contact_point_rec.attribute8 := p7_a16;
    ddp_ams_contact_point_rec.attribute9 := p7_a17;
    ddp_ams_contact_point_rec.attribute10 := p7_a18;
    ddp_ams_contact_point_rec.attribute11 := p7_a19;
    ddp_ams_contact_point_rec.attribute12 := p7_a20;
    ddp_ams_contact_point_rec.attribute13 := p7_a21;
    ddp_ams_contact_point_rec.attribute14 := p7_a22;
    ddp_ams_contact_point_rec.attribute15 := p7_a23;
    ddp_ams_contact_point_rec.attribute16 := p7_a24;
    ddp_ams_contact_point_rec.attribute17 := p7_a25;
    ddp_ams_contact_point_rec.attribute18 := p7_a26;
    ddp_ams_contact_point_rec.attribute19 := p7_a27;
    ddp_ams_contact_point_rec.attribute20 := p7_a28;
    ddp_ams_contact_point_rec.contact_point_purpose := p7_a29;
    ddp_ams_contact_point_rec.primary_by_purpose := p7_a30;
    ddp_ams_contact_point_rec.created_by_module := p7_a31;
    ddp_ams_contact_point_rec.application_id := rosetta_g_miss_num_map(p7_a32);
    ddp_ams_contact_point_rec.actual_content_source := p7_a33;

    ddp_ams_edi_rec.edi_transaction_handling := p8_a0;
    ddp_ams_edi_rec.edi_id_number := p8_a1;
    ddp_ams_edi_rec.edi_payment_method := p8_a2;
    ddp_ams_edi_rec.edi_payment_format := p8_a3;
    ddp_ams_edi_rec.edi_remittance_method := p8_a4;
    ddp_ams_edi_rec.edi_remittance_instruction := p8_a5;
    ddp_ams_edi_rec.edi_tp_header_id := rosetta_g_miss_num_map(p8_a6);
    ddp_ams_edi_rec.edi_ece_tp_location_code := p8_a7;

    ddp_ams_email_rec.email_format := p9_a0;
    ddp_ams_email_rec.email_address := p9_a1;

    ddp_ams_phone_rec.phone_calling_calendar := p10_a0;
    ddp_ams_phone_rec.last_contact_dt_time := rosetta_g_miss_date_in_map(p10_a1);
    ddp_ams_phone_rec.timezone_id := rosetta_g_miss_num_map(p10_a2);
    ddp_ams_phone_rec.phone_area_code := p10_a3;
    ddp_ams_phone_rec.phone_country_code := p10_a4;
    ddp_ams_phone_rec.phone_number := p10_a5;
    ddp_ams_phone_rec.phone_extension := p10_a6;
    ddp_ams_phone_rec.phone_line_type := p10_a7;
    ddp_ams_phone_rec.raw_phone_number := p10_a8;

    ddp_ams_telex_rec.telex_number := p11_a0;

    ddp_ams_web_rec.web_type := p12_a0;
    ddp_ams_web_rec.url := p12_a1;


    -- here's the delegated call to the old PL/SQL routine
    ams_contact_point_pvt.update_contact_point(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ams_contact_point_rec,
      ddp_ams_edi_rec,
      ddp_ams_email_rec,
      ddp_ams_phone_rec,
      ddp_ams_telex_rec,
      ddp_ams_web_rec,
      px_object_version_number);

    -- copy data back from the local OUT or IN-OUT args, if any













  end;

end ams_contact_point_pvt_w;

/
