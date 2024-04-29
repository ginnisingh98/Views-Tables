--------------------------------------------------------
--  DDL for Package Body IBU_EBLAST_PREF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBU_EBLAST_PREF_PKG" AS
/* $Header: ibueblab.pls 115.3 2002/12/03 22:04:49 mkcyee noship $ */
-- =============================================================================================
procedure create_preference(
                            p_party_id   in  NUMBER,
                            p_preference_code   in  VARCHAR2,

                            x_contact_preference_id OUT NOCOPY NUMBER,
                            x_return_status         OUT NOCOPY VARCHAR2,
                            x_msg_count             OUT NOCOPY NUMBER,
                            x_msg_data              OUT NOCOPY VARCHAR2  )
IS
p_contact_preference_rec HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE;
BEGIN
  p_contact_preference_rec.contact_preference_id := FND_API.G_MISS_NUM;
  p_contact_preference_rec.contact_level_table := 'HZ_PARTIES';
  p_contact_preference_rec.contact_level_table_id := p_party_id;
  p_contact_preference_rec.contact_type := 'EMAIL';
  p_contact_preference_rec.preference_code := p_preference_code;
  p_contact_preference_rec.preference_topic_type := FND_API.G_MISS_CHAR;
  p_contact_preference_rec.preference_topic_type_id := FND_API.G_MISS_NUM;
  p_contact_preference_rec.preference_topic_type_code := FND_API.G_MISS_CHAR;
  p_contact_preference_rec.preference_start_date := sysdate;
  p_contact_preference_rec.preference_end_date := FND_API.G_MISS_DATE;
  p_contact_preference_rec.preference_start_time_hr := FND_API.G_MISS_NUM;
  p_contact_preference_rec.preference_end_time_hr := FND_API.G_MISS_NUM;
  p_contact_preference_rec.preference_start_time_mi := FND_API.G_MISS_NUM;
  p_contact_preference_rec.preference_end_time_mi := FND_API.G_MISS_NUM;
  p_contact_preference_rec.max_no_of_interactions := FND_API.G_MISS_NUM;
  p_contact_preference_rec.max_no_of_interact_uom_code := FND_API.G_MISS_CHAR;
  p_contact_preference_rec.requested_by := 'INTERNAL';
  p_contact_preference_rec.reason_code := FND_API.G_MISS_CHAR;
  p_contact_preference_rec.status := FND_API.G_MISS_CHAR;
  p_contact_preference_rec.created_by_module := 'ISUPPORT PROFILE';
  p_contact_preference_rec.application_id := 672;

-- Now call the stored program
  hz_contact_preference_v2pub.create_contact_preference(FND_API.G_TRUE,p_contact_preference_rec,x_contact_preference_id,x_return_status,x_msg_count,x_msg_data);

-- Output the results
/*dbms_output.put_line('x_contact_preference_id = '||TO_CHAR(x_contact_preference_id));
  dbms_output.put_line(SubStr('x_return_status = '||x_return_status,1,255));
  dbms_output.put_line('x_msg_count = '||TO_CHAR(x_msg_count));
  dbms_output.put_line(SubStr('x_msg_data = '||x_msg_data,1,255));*/
EXCEPTION
    WHEN OTHERS THEN
  --dbms_output.put_line('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM);
        RAISE;
end create_preference;
-- ==============================================================================
procedure update_preference(p_contact_preference_id  IN  NUMBER,
                           p_preference_code         IN  VARCHAR2,
                           p_object_version_number   IN OUT NOCOPY NUMBER,

                           x_return_status           OUT NOCOPY VARCHAR2,
                           x_msg_count               OUT NOCOPY NUMBER,
                           x_msg_data                OUT NOCOPY VARCHAR2)
IS
p_contact_preference_rec HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE;
BEGIN
  p_contact_preference_rec.contact_preference_id := p_contact_preference_id;
  p_contact_preference_rec.preference_code := p_preference_code;
  p_object_version_number := p_object_version_number;

-- Now call the stored program
  hz_contact_preference_v2pub.update_contact_preference(FND_API.G_TRUE,p_contact_preference_rec,p_object_version_number,x_return_status,x_msg_count,x_msg_data);

-- Output the results
  /*dbms_output.put_line('p_object_version_number = '||TO_CHAR(p_object_version_number));
  dbms_output.put_line(SubStr('x_return_status = '||x_return_status,1,255));
  dbms_output.put_line('x_msg_count = '||TO_CHAR(x_msg_count));
  dbms_output.put_line(SubStr('x_msg_data = '||x_msg_data,1,255));*/
EXCEPTION
    WHEN OTHERS THEN
      --dbms_output.put_line('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM);
        RAISE;
end update_preference;

-- ==============================================================

end ibu_eblast_pref_pkg;

/
