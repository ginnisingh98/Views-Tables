--------------------------------------------------------
--  DDL for Package CS_INCIDENTLINKS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_INCIDENTLINKS_PUB_W" AUTHID CURRENT_USER as
  /* $Header: cswpsrls.pls 115.7 2004/02/04 19:43:34 aneemuch noship $ */
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
  );
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
  );
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
  );
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
  );
end cs_incidentlinks_pub_w;

 

/
