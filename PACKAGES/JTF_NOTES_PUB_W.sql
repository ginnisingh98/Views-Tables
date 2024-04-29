--------------------------------------------------------
--  DDL for Package JTF_NOTES_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_NOTES_PUB_W" AUTHID CURRENT_USER as
  /* $Header: jtfntsws.pls 120.2 2006/04/26 23:06 mpadhiar ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy jtf_notes_pub.jtf_note_contexts_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t jtf_notes_pub.jtf_note_contexts_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    );

  procedure create_note(p_parent_note_id  NUMBER
    , p_jtf_note_id  NUMBER
    , p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_org_id  NUMBER
    , p_source_object_id  NUMBER
    , p_source_object_code  VARCHAR2
    , p_notes  VARCHAR2
    , p_notes_detail  VARCHAR2
    , p_note_status  VARCHAR2
    , p_entered_by  NUMBER
    , p_entered_date  date
    , x_jtf_note_id out nocopy  NUMBER
    , p_last_update_date  date
    , p_last_updated_by  NUMBER
    , p_creation_date  date
    , p_created_by  NUMBER
    , p_last_update_login  NUMBER
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_context  VARCHAR2
    , p_note_type  VARCHAR2
    , p40_a0 JTF_NUMBER_TABLE
    , p40_a1 JTF_NUMBER_TABLE
    , p40_a2 JTF_VARCHAR2_TABLE_300
    , p40_a3 JTF_NUMBER_TABLE
    , p40_a4 JTF_DATE_TABLE
    , p40_a5 JTF_NUMBER_TABLE
    , p40_a6 JTF_DATE_TABLE
    , p40_a7 JTF_NUMBER_TABLE
    , p40_a8 JTF_NUMBER_TABLE
  );
  procedure update_note(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_jtf_note_id  NUMBER
    , p_entered_by  NUMBER
    , p_last_updated_by  NUMBER
    , p_last_update_date  date
    , p_last_update_login  NUMBER
    , p_notes  VARCHAR2
    , p_notes_detail  VARCHAR2
    , p_append_flag  VARCHAR2
    , p_note_status  VARCHAR2
    , p_note_type  VARCHAR2
    , p17_a0 JTF_NUMBER_TABLE
    , p17_a1 JTF_NUMBER_TABLE
    , p17_a2 JTF_VARCHAR2_TABLE_300
    , p17_a3 JTF_NUMBER_TABLE
    , p17_a4 JTF_DATE_TABLE
    , p17_a5 JTF_NUMBER_TABLE
    , p17_a6 JTF_DATE_TABLE
    , p17_a7 JTF_NUMBER_TABLE
    , p17_a8 JTF_NUMBER_TABLE
  );
  procedure create_note_context(p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , p_jtf_note_id  NUMBER
    , p_last_update_date  date
    , p_last_updated_by  NUMBER
    , p_creation_date  date
    , p_created_by  NUMBER
    , p_last_update_login  NUMBER
    , p_note_context_type_id  NUMBER
    , p_note_context_type  VARCHAR2
    , x_note_context_id out nocopy  NUMBER
  );
  procedure update_note_context(p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , p_note_context_id  NUMBER
    , p_jtf_note_id  NUMBER
    , p_note_context_type_id  NUMBER
    , p_note_context_type  VARCHAR2
    , p_last_updated_by  NUMBER
    , p_last_update_date  date
    , p_last_update_login  NUMBER
  );
  procedure secure_create_note(p_parent_note_id  NUMBER
    , p_jtf_note_id  NUMBER
    , p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_org_id  NUMBER
    , p_source_object_id  NUMBER
    , p_source_object_code  VARCHAR2
    , p_notes  VARCHAR2
    , p_notes_detail  VARCHAR2
    , p_note_status  VARCHAR2
    , p_entered_by  NUMBER
    , p_entered_date  date
    , x_jtf_note_id out nocopy  NUMBER
    , p_last_update_date  date
    , p_last_updated_by  NUMBER
    , p_creation_date  date
    , p_created_by  NUMBER
    , p_last_update_login  NUMBER
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_context  VARCHAR2
    , p_note_type  VARCHAR2
    , p40_a0 JTF_NUMBER_TABLE
    , p40_a1 JTF_NUMBER_TABLE
    , p40_a2 JTF_VARCHAR2_TABLE_300
    , p40_a3 JTF_NUMBER_TABLE
    , p40_a4 JTF_DATE_TABLE
    , p40_a5 JTF_NUMBER_TABLE
    , p40_a6 JTF_DATE_TABLE
    , p40_a7 JTF_NUMBER_TABLE
    , p40_a8 JTF_NUMBER_TABLE
    , p_use_aol_security  VARCHAR2
  );
  procedure secure_update_note(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_jtf_note_id  NUMBER
    , p_entered_by  NUMBER
    , p_last_updated_by  NUMBER
    , p_last_update_date  date
    , p_last_update_login  NUMBER
    , p_notes  VARCHAR2
    , p_notes_detail  VARCHAR2
    , p_append_flag  VARCHAR2
    , p_note_status  VARCHAR2
    , p_note_type  VARCHAR2
    , p17_a0 JTF_NUMBER_TABLE
    , p17_a1 JTF_NUMBER_TABLE
    , p17_a2 JTF_VARCHAR2_TABLE_300
    , p17_a3 JTF_NUMBER_TABLE
    , p17_a4 JTF_DATE_TABLE
    , p17_a5 JTF_NUMBER_TABLE
    , p17_a6 JTF_DATE_TABLE
    , p17_a7 JTF_NUMBER_TABLE
    , p17_a8 JTF_NUMBER_TABLE
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_context  VARCHAR2
    , p_use_aol_security  VARCHAR2
  );
end jtf_notes_pub_w;

 

/
