--------------------------------------------------------
--  DDL for Package Body IEU_UWQ_TASK_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_UWQ_TASK_INFO_PKG" AS
/* $Header: IEUTAINB.pls 115.14 2003/11/25 18:59:43 dolee noship $ */

--Purpose:  This package will be used for displaying information within the work panel
--Created by: Don-May Lee dated 12/9/02
-- changed data to header type..

 procedure ieu_uwq_task_notes (
        p_resource_id                IN  NUMBER,
        p_language                   IN  VARCHAR2,
        p_source_lang              	 IN  VARCHAR2,
        p_action_key                 IN  VARCHAR2,
        p_workitem_data_list   		 IN  SYSTEM.ACTION_INPUT_DATA_NST default null,
        x_notes_data_list          	 OUT NOCOPY SYSTEM.app_info_header_nst,
        x_msg_count                	 OUT NOCOPY NUMBER,
        x_msg_data                   OUT NOCOPY VARCHAR2,
        x_return_status              OUT NOCOPY VARCHAR2
        ) IS

l_ctr                     binary_integer;
l_name                    varchar2(500);
l_value                   varchar2(1996);
l_party_id                number;
l_customer_id             number;
l_task_id                 number;
l_note_context_type_id    number;
l_party_type              varchar2(100);
l_source_type             varchar2(100);

l_notes                   VARCHAR2(2000);

l_curr_rec                VARCHAR2(3000);
l_new_line                VARCHAR2(30);

l_fnd_user_id             NUMBER;
l_object_code             VARCHAR2(30);
l_object_id               NUMBER;

l_months                  number;
l_from_date               date;
l_cur_ind                 VARCHAR2(10);
l_count                   number :=0;


cursor C_note_details_months(p_fnd_user_id NUMBER,
                              p_object_id NUMBER,
                              p_object_code varchar2,
                              p_from_date date) is
select notes, source_name USER_NAME, creation_date, note_type_meaning
from (
SELECT b.rowid ,b.jtf_note_id ,b.creation_date ,
b.created_by ,b.last_update_date ,b.last_updated_by ,
b.last_update_login ,tl.notes ,
b.entered_by ,b.entered_date ,b.source_object_id ,b.source_object_code ,
c.note_context_type_id ,c.note_context_type ,b.note_status ,fnd_status.meaning ,
res.source_name ,b.note_type ,fnd_type.meaning note_type_meaning
FROM jtf_notes_b b, jtf_notes_tl tl, jtf_note_contexts c, fnd_lookups fnd_status,
fnd_lookups fnd_type, jtf_rs_resource_extns res
WHERE b.jtf_note_id = tl.jtf_note_id and tl.language = userenv('LANG')
and b.jtf_note_id = c.jtf_note_id and b.note_type = fnd_type.lookup_code(+)
and fnd_type.lookup_type(+) = 'JTF_NOTE_TYPE'
and b.note_status = fnd_status.lookup_code(+)
and fnd_status.lookup_type(+) = 'JTF_NOTE_STATUS'
and res.user_id(+) = b.created_by
)
where NOTE_CONTEXT_TYPE  = p_object_code
and NOTE_CONTEXT_TYPE_ID = p_object_id
and creation_date > p_from_date
order by creation_date desc;

cursor C_Customer_Notes(p_fnd_user_id NUMBER,
                        p_object_id NUMBER,
                        p_object_code varchar2,
                        p_from_date date) is
select notes, source_name USER_NAME, creation_date, note_type_meaning
from (
SELECT b.rowid ,b.jtf_note_id ,b.creation_date ,
b.created_by ,b.last_update_date ,b.last_updated_by ,
b.last_update_login ,tl.notes ,
b.entered_by ,b.entered_date ,b.source_object_id ,b.source_object_code ,
c.note_context_type_id ,c.note_context_type ,b.note_status ,fnd_status.meaning ,
res.source_name ,b.note_type ,fnd_type.meaning note_type_meaning
FROM jtf_notes_b b, jtf_notes_tl tl, jtf_note_contexts c, fnd_lookups fnd_status,
fnd_lookups fnd_type, jtf_rs_resource_extns res
WHERE b.jtf_note_id = tl.jtf_note_id and tl.language = userenv('LANG')
and b.jtf_note_id = c.jtf_note_id and b.note_type = fnd_type.lookup_code(+)
and fnd_type.lookup_type(+) = 'JTF_NOTE_TYPE'
and b.note_status = fnd_status.lookup_code(+)
and fnd_status.lookup_type(+) = 'JTF_NOTE_STATUS'
and res.user_id(+) = b.created_by
)
where NOTE_CONTEXT_TYPE   LIKE p_object_code
and NOTE_CONTEXT_TYPE_ID in (select customer_id
                                 from jtf_tasks_b
                                 where task_id= p_object_id
                                )
and creation_date > p_from_date
order by creation_date desc;

cursor C_Contact_Notes(p_fnd_user_id NUMBER,
                        p_object_id NUMBER,
                        p_object_code varchar2,
                        p_context_type_id number,
                        p_from_date date) is
select notes, source_name USER_NAME, creation_date, note_type_meaning
from (
SELECT b.rowid ,b.jtf_note_id ,b.creation_date ,
b.created_by ,b.last_update_date ,b.last_updated_by ,
b.last_update_login ,tl.notes ,
b.entered_by ,b.entered_date ,b.source_object_id ,b.source_object_code ,
c.note_context_type_id ,c.note_context_type ,b.note_status ,fnd_status.meaning ,
res.source_name ,b.note_type ,fnd_type.meaning note_type_meaning
FROM jtf_notes_b b, jtf_notes_tl tl, jtf_note_contexts c, fnd_lookups fnd_status,
fnd_lookups fnd_type, jtf_rs_resource_extns res
WHERE b.jtf_note_id = tl.jtf_note_id and tl.language = userenv('LANG')
and b.jtf_note_id = c.jtf_note_id and b.note_type = fnd_type.lookup_code(+)
and fnd_type.lookup_type(+) = 'JTF_NOTE_TYPE'
and b.note_status = fnd_status.lookup_code(+)
and fnd_status.lookup_type(+) = 'JTF_NOTE_STATUS'
and res.user_id(+) = b.created_by
)
where NOTE_CONTEXT_TYPE  like p_object_code
and NOTE_CONTEXT_TYPE_ID = p_context_type_id
and creation_date > p_from_date
order by creation_date desc;

cursor C_note_context_id(p_object_id NUMBER) is
select contact_id
from jtf_task_contacts
where task_id =  p_object_id
and (primary_flag is null or primary_flag = 'Y')
order by primary_flag;

BEGIN

x_notes_data_list  := SYSTEM.app_info_header_nst();

l_new_line := '          ';
l_curr_rec := null;
l_object_code := 'TASK';
FOR I IN 1.. p_workitem_data_list.COUNT LOOP
    l_name := p_workitem_data_list(i).name;
    l_value := p_workitem_data_list(i).value;

            ------ Get field name and value of your records ------

    if     l_name = 'TASK_ID'   then
          l_task_id :=  l_value ;
    end if;
END LOOP;


l_fnd_user_id := fnd_profile.value('USER_ID');
l_curr_rec := null;
l_ctr := 1;



if  p_action_key in ('ieu_uwq_prof_task_notes','ieu_uwq_prof_cust_notes', 'ieu_uwq_prof_cont_notes') then  -- begin of main "if"

    if l_task_id is not null then
        l_object_id := l_task_id;
        l_months    := nvl(FND_PROFILE.VALUE('IEU_DEFAULT_NOTE_MONTHS'), 1);
        l_from_date := add_months(sysdate, -1 * l_months );
        l_cur_ind := 'MON'  ;
    else
      return;
    end if;

end if;


if l_object_id is not null and l_cur_ind = 'MON' then
  if p_action_key in ('ieu_uwq_prof_task_notes')  then
    l_object_code := 'TASK';
    for c2_rec in  C_note_details_months (l_fnd_user_id,
                                           l_object_id,
                                           l_object_code,
                                           l_from_date)
    LOOP


        l_curr_rec :=
' *** ' || to_char(c2_rec.creation_date,'DD-MON-RRRR HH:MI:SS') || ' *** ' || '
' || ' *** ' || c2_rec.USER_NAME   || ' *** ' || '
' || ' *** ' || c2_rec.note_type_meaning || ' *** ' || '
' || c2_rec.notes;
        x_notes_data_list.EXTEND;
        x_notes_data_list(x_notes_data_list.LAST) := SYSTEM.APP_INFO_HEADER_OBJ( l_curr_rec);
        l_ctr := l_ctr + 1;
    END LOOP;
  elsif p_action_key in ('ieu_uwq_prof_cust_notes')  then
      l_object_code := 'PARTY%';
      for c2_rec in  C_Customer_Notes(l_fnd_user_id,
                                       l_object_id,
                                       l_object_code,
                                       l_from_date)
      LOOP

            l_curr_rec :=
' *** ' || to_char(c2_rec.creation_date,'DD-MON-RRRR HH:MI:SS') || ' *** ' || '
' || ' *** ' || c2_rec.USER_NAME   || ' *** ' || '
' || ' *** ' || c2_rec.note_type_meaning || ' *** ' || '
' || c2_rec.notes;
            x_notes_data_list.EXTEND;
            x_notes_data_list(x_notes_data_list.LAST) := SYSTEM.APP_INFO_HEADER_OBJ( l_curr_rec);
            l_ctr := l_ctr + 1;
      END LOOP;
  elsif p_action_key in ('ieu_uwq_prof_cont_notes')  then
       l_object_code := 'PARTY%';
       OPEN C_note_context_id(l_object_id);
       FETCH C_note_context_id INTO l_note_context_type_id;
       CLOSE C_note_context_id;
       for c2_rec in  C_Contact_Notes(l_fnd_user_id,
                                       l_object_id,
                                       l_object_code,
                                       l_note_context_type_id,
                                       l_from_date)
       LOOP
            l_curr_rec :=
' *** ' || to_char(c2_rec.creation_date,'DD-MON-RRRR HH:MI:SS') || ' *** ' || '
' || ' *** ' || c2_rec.USER_NAME   || ' *** ' || '
' || ' *** ' || c2_rec.note_type_meaning || ' *** ' || '
' || c2_rec.notes;
            x_notes_data_list.EXTEND;
            x_notes_data_list(x_notes_data_list.LAST) := SYSTEM.APP_INFO_HEADER_OBJ( l_curr_rec);
            l_ctr := l_ctr + 1;
        END LOOP;
  end if;
end if;


 x_return_status	:=fnd_api.g_ret_sts_success;

fnd_msg_pub.Count_And_Get(p_count => x_msg_count,
                           p_data  => x_msg_data);

EXCEPTION

when fnd_api.g_exc_error  then
    x_return_status:=fnd_api.g_ret_sts_error;

when fnd_api.g_exc_unexpected_error  then
    x_return_status:=fnd_api.g_ret_sts_unexp_error;

when others then
    x_return_status:=fnd_api.g_ret_sts_unexp_error;

    fnd_msg_pub.Count_And_Get(p_count => x_msg_count,
                           p_data  => x_msg_data);



end ieu_uwq_task_notes;
END ieu_uwq_task_info_pkg;

/
