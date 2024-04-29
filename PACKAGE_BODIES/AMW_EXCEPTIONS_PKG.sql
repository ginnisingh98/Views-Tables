--------------------------------------------------------
--  DDL for Package Body AMW_EXCEPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_EXCEPTIONS_PKG" as
/*$Header: amwexcpb.pls 120.0 2005/05/31 18:24:24 appldev noship $*/


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMW_EXCEPTIONS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amwexcpb.pls';
G_USER_ID NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID NUMBER := FND_GLOBAL.CONC_LOGIN_ID;


procedure insert_exception_header_row (
p_Exception_Id		IN Number,
p_Object_Type		IN Varchar2,
p_Old_pk1		IN Varchar2,
p_Old_pk2		IN Varchar2,
p_Old_pk3		IN Varchar2,
p_Old_pk4		IN Varchar2,
p_Old_pk5		IN Varchar2,
p_Old_pk6		IN Varchar2,
p_New_pk1		IN Varchar2,
p_New_pk2		IN Varchar2,
p_New_pk3		IN Varchar2,
p_New_pk4		IN Varchar2,
p_New_pk5		IN Varchar2,
p_New_pk6		IN Varchar2,
p_Transaction_Type	IN Varchar2,
p_Justification	        IN Varchar2,
p_person_party_id	IN Number,
p_existing_ex_id	IN Number,
p_commit		in varchar2 := FND_API.G_FALSE,
p_validation_level	IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list		IN VARCHAR2 := FND_API.G_FALSE,
x_return_status		out nocopy varchar2,
x_msg_count		out nocopy number,
x_msg_data		out nocopy varchar2
) is

  L_API_NAME CONSTANT VARCHAR2(30) := 'insert_exception_header_row';

  l_person_id number;
  l_header varchar2(4000);
  l_body varchar2(4000);
  l_notif_id number;
  l_ret_status  varchar2(30);
  l_nsp_disp_name  varchar2(100);
  l_sp_disp_name  varchar2(100);


  begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

if ( (p_Object_Type = 'PROCESS_VARIANT_ADD') AND (p_Transaction_Type = 'DELETE_EXIST') ) then
		delete from amw_exceptions_tl where exception_id IN
			(select exception_id from amw_exceptions_b
			where old_pk1 = p_Old_pk1 and new_pk1 = p_New_pk1
			and object_type = 'PROCESS_VARIANT_ADD');

		delete from amw_exceptions_reasons where exception_id IN
			(select exception_id from amw_exceptions_b
			where old_pk1 = p_Old_pk1 and new_pk1 = p_New_pk1
			and object_type = 'PROCESS_VARIANT_ADD');

		delete from amw_exceptions_b
		where old_pk1 = p_Old_pk1 and new_pk1 = p_New_pk1
		and object_type = 'PROCESS_VARIANT_ADD';

else

if p_existing_ex_id <> 0 then
		 delete from amw_exceptions_b where exception_id = p_existing_ex_id;
		 delete from amw_exceptions_tl where exception_id = p_existing_ex_id;
else
                 insert into amw_exceptions_b (
                 Exception_Id,
                 Object_Type,
                 Old_pk1,
                 Old_pk2,
                 Old_pk3,
                 Old_pk4,
                 Old_pk5,
                 Old_pk6,
                 New_pk1,
                 New_pk2,
                 New_pk3,
                 New_pk4,
                 New_pk5,
                 New_pk6,
                 Transaction_Type,
                 Transaction_Date,
                 End_Date,
                 Last_Update_Date,
                 Last_Updated_By,
                 Creation_Date,
                 Created_By,
                 Last_Update_Login,
                 OBJECT_VERSION_NUMBER
                 )
                 values
                 (
                 p_Exception_Id,
                 p_Object_Type,
                 decode(p_Old_pk1, 'IamNull', null, p_Old_pk1),
                 decode(p_Old_pk2, 'IamNull', null, p_Old_pk2),
                 decode(p_Old_pk3, 'IamNull', null, p_Old_pk3),
                 decode(p_Old_pk4, 'IamNull', null, p_Old_pk4),
                 p_Old_pk5,
                 p_Old_pk6,
                 decode(p_New_pk1, 'IamNull', null, p_New_pk1),
                 decode(p_New_pk2, 'IamNull', null, p_New_pk2),
                 decode(p_New_pk3, 'IamNull', null, p_New_pk3),
                 decode(p_New_pk4, 'IamNull', null, p_New_pk4),
                 p_New_pk5,
                 p_New_pk6,
                 p_Transaction_Type,
                 sysdate,
                 null,
                 sysdate,
                 G_USER_ID,
                 sysdate,
                 G_USER_ID,
                 G_LOGIN_ID,
                 1
                 );


                  insert into amw_exceptions_tl (
                  EXCEPTION_ID,
                  LANGUAGE,
                  SOURCE_LANG,
                  JUSTIFICATION,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_LOGIN,
		  OLD_PROCESS_NAME,
		  NEW_PROCESS_NAME
                  )	select
                 	p_Exception_Id,
                 	L.LANGUAGE_CODE,
                 	userenv('LANG'),
                 	p_Justification,
                 	sysdate,
                 	G_USER_ID,
                 	sysdate,
                 	G_USER_ID,
                 	G_LOGIN_ID,
			decode(p_Object_Type,'PROCESS',decode(p_Old_pk3, 'IamNull', null, amw_utility_pvt.get_process_name(p_Old_pk3)),null),
			decode(p_Object_Type,'PROCESS',decode(p_New_pk3, 'IamNull', null, amw_utility_pvt.get_process_name(p_New_pk3)),null)
                 	from FND_LANGUAGES L
                 	where L.INSTALLED_FLAG in ('I', 'B')
                 	and not exists
                 		(select NULL
                 		 from AMW_EXCEPTIONS_TL T
                 		 where T.EXCEPTION_ID = p_Exception_Id
                 		 and T.LANGUAGE = L.LANGUAGE_CODE);

end if;  -- p_existing_ex_id 0

-- send notification for process variation.
-- adding it here since specifying a variant always involves creation of exception
	if p_Transaction_Type = 'OVERALL_PROC_VAR' and p_Object_Type = 'PROCESS_VARIANT_ADD' then

	 l_person_id := 0;
	 if p_person_party_id <> 0 then

		select employee_id
		into l_person_id
		from AMW_EMPLOYEES_CURRENT_V
		where party_id = p_person_party_id;

		select watl.display_name
		into  l_nsp_disp_name
		from wf_activities_tl watl, wf_activities wa, amw_process ap
		where ap.process_id = p_Old_pk1
		and ap.name = wa.name
		and wa.item_type = 'AUDITMGR'
		and wa.end_date is null
		and watl.item_type = 'AUDITMGR'
		and watl.name = wa.name
		and watl.version = wa.version
		and watl.language = userenv('LANG');

		select watl.display_name
		into  l_sp_disp_name
		from wf_activities_tl watl, wf_activities wa, amw_process ap
		where ap.process_id = p_New_pk1
		and ap.name = wa.name
		and wa.item_type = 'AUDITMGR'
		and wa.end_date is null
		and watl.item_type = 'AUDITMGR'
		and watl.name = wa.name
		and watl.version = wa.version
		and watl.language = userenv('LANG');


		 fnd_message.set_name('AMW', 'AMW_PROC_VAR_HEAD');
		 l_header := fnd_message.get;

		 fnd_message.set_name('AMW', 'AMW_PROC_VAR_BODY');
	         fnd_message.set_token('STD', l_sp_disp_name);
	         fnd_message.set_token('NSTD', l_nsp_disp_name);
		 l_body := fnd_message.get;

		 AMW_Utility_PVT.send_wf_standalone_message(      p_subject		=> l_header,
								  p_body		=> l_body,
								  p_send_to_person_id	=> l_person_id,
								  x_notif_id		=> l_notif_id,
								  x_return_status	=> l_ret_status);
	 end if;
	end if;

end if; -- (p_Object_Type = 'PROCESS_VARIANT_ADD') AND (p_Transaction_Type = 'DELETE_EXIST')

exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);

end insert_exception_header_row;





procedure insert_exceptions_reasons_row (
p_EXCEPTION_ID          in number,
p_REASON_CODE           in varchar2,
p_existing_ex_id	IN Number,
p_commit		in varchar2 := FND_API.G_FALSE,
p_validation_level	IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list		IN VARCHAR2 := FND_API.G_FALSE,
x_return_status		out nocopy varchar2,
x_msg_count		out nocopy number,
x_msg_data		out nocopy varchar2
) is

  L_API_NAME CONSTANT VARCHAR2(30) := 'insert_exceptions_reasons_row';

  begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

if p_existing_ex_id <> 0 then
		 delete from amw_exceptions_reasons where exception_id = p_existing_ex_id;
else
                  insert into amw_exceptions_reasons (
                  EXCEPTION_ID,
                  REASON_CODE,
                  Last_Update_Date,
                  Last_Updated_By,
                  Creation_Date,
                  Created_By,
                  Last_Update_Login,
                  OBJECT_VERSION_NUMBER
                  )
                  values
                  (
                  p_EXCEPTION_ID,
                  p_REASON_CODE,
                  sysdate,
                  G_USER_ID,
                  sysdate,
                  G_USER_ID,
                  G_LOGIN_ID,
                  1
                  );
end if;  -- p_existing_ex_id 0

exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);

end insert_exceptions_reasons_row;


procedure ADD_LANGUAGE
is
begin
  delete from amw_exceptions_tl T
  where not exists
    (select NULL
    from amw_exceptions_b B
    where B.exception_id = T.exception_id
    );

  update amw_exceptions_tl T set (
      JUSTIFICATION
    ) = (select
      B.JUSTIFICATION
    from amw_exceptions_tl B
    where B.exception_id = T.exception_id
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.exception_id,
      T.LANGUAGE
  ) in (select
      SUBT.exception_id,
      SUBT.LANGUAGE
    from amw_exceptions_tl SUBB, amw_exceptions_tl SUBT
    where SUBB.exception_id = SUBT.exception_id
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.JUSTIFICATION <> SUBT.JUSTIFICATION
      or (SUBB.JUSTIFICATION is null and SUBT.JUSTIFICATION is not null)
      or (SUBB.JUSTIFICATION is not null and SUBT.JUSTIFICATION is null)
  ));


  insert into amw_exceptions_tl (
    exception_id,
    JUSTIFICATION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.exception_id,
    B.JUSTIFICATION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from amw_exceptions_tl B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from amw_exceptions_tl T
    where T.exception_id = B.exception_id
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


end AMW_EXCEPTIONS_PKG;

/
