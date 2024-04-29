--------------------------------------------------------
--  DDL for Package Body CS_INCIDENTLINKS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_INCIDENTLINKS_PUB_W" as
  /* $Header: cswpsrlb.pls 115.7 2004/02/04 19:43:43 aneemuch noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_incidentlink(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , p_org_id  NUMBER
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  NUMBER
    , p8_a4  VARCHAR2
    , p8_a5  VARCHAR2
    , p8_a6  NUMBER
    , p8_a7  VARCHAR2
    , p8_a8  NUMBER
    , p8_a9  NUMBER
    , p8_a10  NUMBER
    , p8_a11  DATE
    , p8_a12  VARCHAR2
    , p8_a13  VARCHAR2
    , p8_a14  VARCHAR2
    , p8_a15  VARCHAR2
    , p8_a16  VARCHAR2
    , p8_a17  VARCHAR2
    , p8_a18  VARCHAR2
    , p8_a19  VARCHAR2
    , p8_a20  VARCHAR2
    , p8_a21  VARCHAR2
    , p8_a22  VARCHAR2
    , p8_a23  VARCHAR2
    , p8_a24  VARCHAR2
    , p8_a25  VARCHAR2
    , p8_a26  VARCHAR2
    , p8_a27  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
    , x_reciprocal_link_id out nocopy  NUMBER
    , x_link_id out nocopy  NUMBER
  )

  as
    ddp_link_rec cs_incidentlinks_pub.cs_incident_link_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_link_rec.link_id := p8_a0;
    ddp_link_rec.subject_id := p8_a1;
    ddp_link_rec.subject_type := p8_a2;
    ddp_link_rec.object_id := p8_a3;
    ddp_link_rec.object_number := p8_a4;
    ddp_link_rec.object_type := p8_a5;
    ddp_link_rec.link_type_id := p8_a6;
    ddp_link_rec.link_type := p8_a7;
    ddp_link_rec.request_id := p8_a8;
    ddp_link_rec.program_application_id := p8_a9;
    ddp_link_rec.program_id := p8_a10;
    ddp_link_rec.program_update_date := rosetta_g_miss_date_in_map(p8_a11);
    ddp_link_rec.link_segment1 := p8_a12;
    ddp_link_rec.link_segment2 := p8_a13;
    ddp_link_rec.link_segment3 := p8_a14;
    ddp_link_rec.link_segment4 := p8_a15;
    ddp_link_rec.link_segment5 := p8_a16;
    ddp_link_rec.link_segment6 := p8_a17;
    ddp_link_rec.link_segment7 := p8_a18;
    ddp_link_rec.link_segment8 := p8_a19;
    ddp_link_rec.link_segment9 := p8_a20;
    ddp_link_rec.link_segment10 := p8_a21;
    ddp_link_rec.link_segment11 := p8_a22;
    ddp_link_rec.link_segment12 := p8_a23;
    ddp_link_rec.link_segment13 := p8_a24;
    ddp_link_rec.link_segment14 := p8_a25;
    ddp_link_rec.link_segment15 := p8_a26;
    ddp_link_rec.link_context := p8_a27;







    -- here's the delegated call to the old PL/SQL routine
    cs_incidentlinks_pub.create_incidentlink(p_api_version,
      p_init_msg_list,
      p_commit,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      p_org_id,
      ddp_link_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_object_version_number,
      x_reciprocal_link_id,
      x_link_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure create_incidentlink(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , p_org_id  NUMBER
    , p_link_id  NUMBER
    , p_subject_id  NUMBER
    , p_subject_type  VARCHAR2
    , p_object_id  NUMBER
    , p_object_number  VARCHAR2
    , p_object_type  VARCHAR2
    , p_link_type_id  NUMBER
    , p_link_type  VARCHAR2
    , p_request_id  NUMBER
    , p_program_application_id  NUMBER
    , p_program_id  NUMBER
    , p_program_update_date  date
    , p_from_incident_id  NUMBER
    , p_from_incident_number  VARCHAR2
    , p_to_incident_id  NUMBER
    , p_to_incident_number  VARCHAR2
    , p_link_segment1  VARCHAR2
    , p_link_segment2  VARCHAR2
    , p_link_segment3  VARCHAR2
    , p_link_segment4  VARCHAR2
    , p_link_segment5  VARCHAR2
    , p_link_segment6  VARCHAR2
    , p_link_segment7  VARCHAR2
    , p_link_segment8  VARCHAR2
    , p_link_segment9  VARCHAR2
    , p_link_segment10  VARCHAR2
    , p_link_segment11  VARCHAR2
    , p_link_segment12  VARCHAR2
    , p_link_segment13  VARCHAR2
    , p_link_segment14  VARCHAR2
    , p_link_segment15  VARCHAR2
    , p_link_context  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_reciprocal_link_id out nocopy  NUMBER
    , x_object_version_number out nocopy  NUMBER
    , x_link_id out nocopy  NUMBER
  )

  as
    ddp_program_update_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



















    ddp_program_update_date := rosetta_g_miss_date_in_map(p_program_update_date);



























    -- here's the delegated call to the old PL/SQL routine
    cs_incidentlinks_pub.create_incidentlink(p_api_version,
      p_init_msg_list,
      p_commit,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      p_org_id,
      p_link_id,
      p_subject_id,
      p_subject_type,
      p_object_id,
      p_object_number,
      p_object_type,
      p_link_type_id,
      p_link_type,
      p_request_id,
      p_program_application_id,
      p_program_id,
      ddp_program_update_date,
      p_from_incident_id,
      p_from_incident_number,
      p_to_incident_id,
      p_to_incident_number,
      p_link_segment1,
      p_link_segment2,
      p_link_segment3,
      p_link_segment4,
      p_link_segment5,
      p_link_segment6,
      p_link_segment7,
      p_link_segment8,
      p_link_segment9,
      p_link_segment10,
      p_link_segment11,
      p_link_segment12,
      p_link_segment13,
      p_link_segment14,
      p_link_segment15,
      p_link_context,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_reciprocal_link_id,
      x_object_version_number,
      x_link_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













































  end;

  procedure update_incidentlink(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , p_org_id  NUMBER
    , p_link_id  NUMBER
    , p_object_version_number  NUMBER
    , p10_a0  NUMBER
    , p10_a1  NUMBER
    , p10_a2  VARCHAR2
    , p10_a3  NUMBER
    , p10_a4  VARCHAR2
    , p10_a5  VARCHAR2
    , p10_a6  NUMBER
    , p10_a7  VARCHAR2
    , p10_a8  NUMBER
    , p10_a9  NUMBER
    , p10_a10  NUMBER
    , p10_a11  DATE
    , p10_a12  VARCHAR2
    , p10_a13  VARCHAR2
    , p10_a14  VARCHAR2
    , p10_a15  VARCHAR2
    , p10_a16  VARCHAR2
    , p10_a17  VARCHAR2
    , p10_a18  VARCHAR2
    , p10_a19  VARCHAR2
    , p10_a20  VARCHAR2
    , p10_a21  VARCHAR2
    , p10_a22  VARCHAR2
    , p10_a23  VARCHAR2
    , p10_a24  VARCHAR2
    , p10_a25  VARCHAR2
    , p10_a26  VARCHAR2
    , p10_a27  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_link_rec cs_incidentlinks_pub.cs_incident_link_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_link_rec.link_id := p10_a0;
    ddp_link_rec.subject_id := p10_a1;
    ddp_link_rec.subject_type := p10_a2;
    ddp_link_rec.object_id := p10_a3;
    ddp_link_rec.object_number := p10_a4;
    ddp_link_rec.object_type := p10_a5;
    ddp_link_rec.link_type_id := p10_a6;
    ddp_link_rec.link_type := p10_a7;
    ddp_link_rec.request_id := p10_a8;
    ddp_link_rec.program_application_id := p10_a9;
    ddp_link_rec.program_id := p10_a10;
    ddp_link_rec.program_update_date := rosetta_g_miss_date_in_map(p10_a11);
    ddp_link_rec.link_segment1 := p10_a12;
    ddp_link_rec.link_segment2 := p10_a13;
    ddp_link_rec.link_segment3 := p10_a14;
    ddp_link_rec.link_segment4 := p10_a15;
    ddp_link_rec.link_segment5 := p10_a16;
    ddp_link_rec.link_segment6 := p10_a17;
    ddp_link_rec.link_segment7 := p10_a18;
    ddp_link_rec.link_segment8 := p10_a19;
    ddp_link_rec.link_segment9 := p10_a20;
    ddp_link_rec.link_segment10 := p10_a21;
    ddp_link_rec.link_segment11 := p10_a22;
    ddp_link_rec.link_segment12 := p10_a23;
    ddp_link_rec.link_segment13 := p10_a24;
    ddp_link_rec.link_segment14 := p10_a25;
    ddp_link_rec.link_segment15 := p10_a26;
    ddp_link_rec.link_context := p10_a27;





    -- here's the delegated call to the old PL/SQL routine
    cs_incidentlinks_pub.update_incidentlink(p_api_version,
      p_init_msg_list,
      p_commit,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      p_org_id,
      p_link_id,
      p_object_version_number,
      ddp_link_rec,
      x_return_status,
      x_object_version_number,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure update_incidentlink(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , p_org_id  NUMBER
    , p_link_id  NUMBER
    , p_object_version_number  NUMBER
    , p_subject_id  NUMBER
    , p_subject_type  VARCHAR2
    , p_link_type_id  NUMBER
    , p_link_type  VARCHAR2
    , p_object_id  NUMBER
    , p_object_number  VARCHAR2
    , p_object_type  VARCHAR2
    , p_request_id  NUMBER
    , p_program_application_id  NUMBER
    , p_program_id  NUMBER
    , p_program_update_date  date
    , p_from_incident_id  NUMBER
    , p_from_incident_number  VARCHAR2
    , p_to_incident_id  NUMBER
    , p_to_incident_number  VARCHAR2
    , p_link_segment1  VARCHAR2
    , p_link_segment2  VARCHAR2
    , p_link_segment3  VARCHAR2
    , p_link_segment4  VARCHAR2
    , p_link_segment5  VARCHAR2
    , p_link_segment6  VARCHAR2
    , p_link_segment7  VARCHAR2
    , p_link_segment8  VARCHAR2
    , p_link_segment9  VARCHAR2
    , p_link_segment10  VARCHAR2
    , p_link_segment11  VARCHAR2
    , p_link_segment12  VARCHAR2
    , p_link_segment13  VARCHAR2
    , p_link_segment14  VARCHAR2
    , p_link_segment15  VARCHAR2
    , p_link_context  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_program_update_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




















    ddp_program_update_date := rosetta_g_miss_date_in_map(p_program_update_date);

























    -- here's the delegated call to the old PL/SQL routine
    cs_incidentlinks_pub.update_incidentlink(p_api_version,
      p_init_msg_list,
      p_commit,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      p_org_id,
      p_link_id,
      p_object_version_number,
      p_subject_id,
      p_subject_type,
      p_link_type_id,
      p_link_type,
      p_object_id,
      p_object_number,
      p_object_type,
      p_request_id,
      p_program_application_id,
      p_program_id,
      ddp_program_update_date,
      p_from_incident_id,
      p_from_incident_number,
      p_to_incident_id,
      p_to_incident_number,
      p_link_segment1,
      p_link_segment2,
      p_link_segment3,
      p_link_segment4,
      p_link_segment5,
      p_link_segment6,
      p_link_segment7,
      p_link_segment8,
      p_link_segment9,
      p_link_segment10,
      p_link_segment11,
      p_link_segment12,
      p_link_segment13,
      p_link_segment14,
      p_link_segment15,
      p_link_context,
      x_return_status,
      x_object_version_number,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












































  end;

end cs_incidentlinks_pub_w;

/
