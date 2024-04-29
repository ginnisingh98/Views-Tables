--------------------------------------------------------
--  DDL for Package Body AS_CLASSIFICATION_HOOKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_CLASSIFICATION_HOOKS" as
/* $Header: asxccihb.pls 115.7 2002/11/06 00:39:49 appldev ship $ */


procedure update_selectable_flag(p_class_category in varchar2) is
begin

		update as_hz_class_code_denorm denorm
		set selectable_flag = 'N'
		where denorm.class_category = p_class_category
		      and selectable_flag = 'Y'
		      and exists (select 'x'
	                         from  hz_class_code_relations rel1,
				 hz_class_code_relations rel2,
				 fnd_lookup_values lv
				where (rel1.sub_class_code = denorm.class_code
				  or lv.lookup_code = rel1.sub_class_code)
				 and rel2.class_code = denorm.class_code
				  and lv.lookup_type = denorm.class_category
				 and denorm.class_category= rel1.class_category
				 and denorm.class_category= rel2.class_category
				 and denorm.class_category = p_class_category);
	Exception
	  When Others then
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,'Error in Upd sel flag:' || sqlerrm);
          FND_MSG_PUB.Add_Exc_Msg('AS_CLASSIFICATION_HOOKS', 'update_selectable_flag');
end;

procedure update_class_category_post(p_class_category in varchar2,
			   p_category_meaning in varchar2,
			   p_allow_leaf_node_only_flag in varchar2) is

begin
	AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Update Category Post Start');

	update  as_hz_class_code_denorm
	set class_category_meaning = p_category_meaning
	where class_category = p_class_category
	and language = userenv('LANG')
	and class_category_meaning <> p_category_meaning;

	if  p_allow_leaf_node_only_flag ='Y'
	then
		update_selectable_flag(p_class_category);
	else
		update as_hz_class_code_denorm denorm
		set selectable_flag = 'Y'
		where denorm.class_category = p_class_category
		and selectable_flag = 'N';
	end if;

	AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Update Category Post End');

	Exception
	  When Others then
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,'Error in Upd Category Post:' || sqlerrm);
          FND_MSG_PUB.Add_Exc_Msg('AS_CLASSIFICATION_HOOKS', 'update_class_category_post');


end;


procedure register_Lookup_code_post(p_lookup_type in varchar2,
			     p_lookup_code in varchar2,
			     p_meaning in varchar2,
			     p_description in varchar2,
			     p_enabled_flag in varchar2,
			     p_start_date_active in date,
			     p_end_date_active in date) is
begin

	INSERT INTO AS_HZ_CLASS_CODE_DENORM(
	CLASS_CATEGORY,
	CLASS_CATEGORY_MEANING,
	CLASS_CODE,
	CLASS_CODE_MEANING,
	CLASS_CODE_DESCRIPTION,
        ANCESTOR_CODE,
	ANCESTOR_MEANING,
	LANGUAGE,
	CONCAT_CLASS_CODE,
	CONCAT_CLASS_CODE_MEANING,
	CODE_LEVEL,
	START_DATE_ACTIVE,
	END_DATE_ACTIVE,
	ENABLED_FLAG,
	SELECTABLE_FLAG,
	SEGMENT1,
	SEGMENT2,
	SEGMENT3,
        SEGMENT4,
	SEGMENT5,
	SEGMENT6,
        SEGMENT7,
        SEGMENT8,
	SEGMENT9,
        SEGMENT10,
	SEGMENT1_MEANING,
	SEGMENT2_MEANING,
	SEGMENT3_MEANING,
        SEGMENT4_MEANING,
	SEGMENT5_MEANING,
	SEGMENT6_MEANING,
	SEGMENT7_MEANING,
        SEGMENT8_MEANING,
	SEGMENT9_MEANING,
	SEGMENT10_MEANING,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	LAST_UPDATE_DATE,
	REQUEST_ID,
	PROGRAM_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_UPDATE_DATE
    ) select
	p_lookup_type,
	meaning,
	p_lookup_code,
	p_meaning,
	p_description,
	p_lookup_code,
	p_meaning,
	userenv('LANG'),
	p_lookup_code,
	p_meaning,
	1,
	p_start_date_active,
	p_end_date_active,
	p_enabled_flag,
	'Y',
	'not used',
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	'not used',
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NVL(FND_GLOBAL.USER_ID,-1),
	SYSDATE,
	NVL(FND_GLOBAL.USER_ID,-1),
	NVL(FND_GLOBAL.LOGIN_ID,-1),
	SYSDATE,
	FND_GLOBAL.CONC_REQUEST_ID,
	FND_GLOBAL.CONC_PROGRAM_ID,
	FND_GLOBAL.PROG_APPL_ID,
	SYSDATE
	from fnd_lookup_types_vl
	where lookup_type = p_lookup_type;

	Exception
	  When Others then
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,'Error in Reg lookup code Post:' || sqlerrm);
          FND_MSG_PUB.Add_Exc_Msg('AS_CLASSIFICATION_HOOKS', 'register_lookup_code_post');

end;

-- private function
function get_class_code_level(p_class_category in varchar2, p_class_code in varchar2) return
varchar2 is
	cursor get_code_level_csr is
		select code_level
		from as_hz_class_code_denorm
		where class_category = p_class_category
		and class_code = p_class_code
		and ancestor_code = p_class_code
		and language = userenv('LANG');

l_code_level number;
begin
	open get_code_level_csr;
	fetch get_code_level_csr into l_code_level;
	close get_code_level_csr;

	return l_code_level;
end;

function get_code_meaning(p_type in varchar2, p_code in varchar2, p_language in varchar2) return varchar2 is
	cursor get_code_meaning_csr is
		select meaning
		from fnd_lookup_values
		where lookup_type = p_type
		and language = p_language
		and lookup_code  = p_code;

l_meaning varchar2(80);
begin
	open get_code_meaning_csr;
	fetch get_code_meaning_csr into l_meaning;
	if get_code_meaning_csr%FOUND
	then
		close get_code_meaning_csr;
		return(l_meaning);
	else
		close get_code_meaning_csr;
		return null;
	end if;


end;
function get_concat_meaning(p_type in varchar2, p_curr_code in varchar2,p_language in varchar2) return varchar2 is

	cursor get_class_code_hierarchy_csr(p_type varchar2,p_curr_code varchar2) is

		select a.class_code
		from (select class_code, sub_class_code from hz_class_code_relations
                      where
		      sysdate between start_date_active and nvl(end_date_active,sysdate)
		      and class_category = p_type) a
		start with sub_class_code = p_curr_code
		connect by sub_class_code =  prior class_code;


l_class_code varchar2(30);
l_sub_class_code varchar2(30);
l_level number;
l_curr_code varchar2(30);
l_concat_code varchar2(2000);
l_concat_meaning varchar2(2000);

begin

	l_concat_meaning := get_code_meaning(p_type,p_curr_code,p_language);
	open get_class_code_hierarchy_csr(p_type,p_curr_code);
	loop
		fetch get_class_code_hierarchy_csr into l_class_code;
		exit when get_class_code_hierarchy_csr%NOTFOUND;
		l_concat_meaning := get_code_meaning(p_type,l_class_code,p_language) ||'/'||l_concat_meaning;
	end loop;
	close get_class_code_hierarchy_csr;
	return l_concat_meaning;
end;
function get_concat_code(p_class_category in varchar2,p_curr_code in varchar2) return varchar2 is

	cursor get_class_code_hierarchy_csr is
		select a.class_code
		from (select class_code, sub_class_code from hz_class_code_relations
                      where
		      sysdate between start_date_active and nvl(end_date_active,sysdate)
		      and class_category = p_class_category) a
		start with sub_class_code = p_curr_code
		connect by sub_class_code =  prior class_code;


l_class_code varchar2(30);
l_sub_class_code varchar2(30);
l_level number;
l_curr_code varchar2(30);
l_concat_code varchar2(2000);

begin

	l_concat_code := p_curr_code;
	open get_class_code_hierarchy_csr;
	loop
		fetch get_class_code_hierarchy_csr into l_class_code;
		exit when get_class_code_hierarchy_csr%NOTFOUND;
		l_concat_code:= l_class_code ||'/'||l_concat_code;
	end loop;
	close get_class_code_hierarchy_csr;
	return l_concat_code;
end;

procedure update_concate_meaning(p_class_category in varchar2, p_curr_code in varchar2) is
	cursor get_language_csr is
		select language
		from fnd_lookup_types_tl
		where lookup_type = p_class_category;
l_language varchar2(30);
l_concat_meaning varchar2(2000);
begin
	open get_language_csr;
	loop
		fetch get_language_csr into l_language;
		l_concat_meaning := get_concat_meaning(p_class_category,p_curr_code,l_language);
		update as_hz_class_code_denorm
		set concat_class_code_meaning = l_concat_meaning
		where class_category = p_class_category
		and class_code = p_curr_code
		and language = l_language;
		exit when get_language_csr%NOTFOUND;
	end loop;
	close get_language_csr;
end;


procedure update_Lookup_code_post(p_lookup_type in varchar2,
			     p_lookup_code in varchar2,
			     p_meaning in varchar2,
			     p_description in varchar2,
			     p_enabled_flag in varchar2,
			     p_start_date_active in date,
			     p_end_date_active in date) is

	  cursor get_code_meaning_csr is
                select class_code_meaning
                from as_hz_class_code_denorm
                where class_category = p_lookup_type
                and class_code = p_lookup_code
                and ancestor_code = p_lookup_code
                and language = userenv('LANG');
l_old_meaning varchar2(80);

begin
	open get_code_meaning_csr;
	fetch get_code_meaning_csr into l_old_meaning;
	close get_code_meaning_csr;

	update as_hz_class_code_denorm
	set enabled_flag = p_enabled_flag,
		start_date_active = p_start_date_active,
		end_date_active = p_end_date_active
	where	class_category = p_lookup_type
	and	class_code = p_lookup_code;

	update as_hz_class_code_denorm
	set ancestor_meaning = p_meaning
	where	class_category = p_lookup_type
	and	ancestor_code = p_lookup_code
	and	language = userenv('LANG');

	-- Code meaning change related to language.
        --   Therefore, need to be handled seperately
        -- segment1 to 4 only used in total mode, not online mode,data change
        -- will not be maintained.

	update as_hz_class_code_denorm
	set
		class_code_meaning = p_meaning,
		class_code_description = p_description,
		segment1_meaning = 'not used',
		segment2_meaning = null,
		segment3_meaning = null,
		segment4_meaning = null
	where	class_category = p_lookup_type
	and     class_code = p_lookup_code
	and	language = userenv('LANG')
	and	(class_code_meaning <> p_meaning
		or nvl(class_code_description, '#@#') <> nvl(p_description, '#@#'));

	update as_hz_class_code_denorm
	set
         concat_class_code_meaning = replace(concat_class_code_meaning,l_old_meaning, p_meaning)
	where   class_category = p_lookup_type
	and     instr(concat_class_code_meaning,l_old_meaning)>0
        and     language = userenv('LANG');

	Exception
	  When Others then
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,'Error in Upd lookup code Post:' || sqlerrm);
          FND_MSG_PUB.Add_Exc_Msg('AS_CLASSIFICATION_HOOKS', 'update_lookup_code_post');

end;

-- private procedure
procedure insert_current_code_relation(p_class_category in varchar2,
				  p_class_code in varchar2,
				  p_sub_class_code in varchar2
				) is
	cursor get_leaf_node_flag_csr is
		select allow_leaf_node_only_Flag
		from hz_class_categories
		where class_category = p_class_category;
l_concat_code varchar2(500);
l_concat_meaning varchar2(2000);
l_leaf_node_flag varchar2(1);
l_code_level number;
begin
     l_concat_code := get_concat_code(p_class_category,p_sub_class_code);

     l_code_level := get_class_code_level(p_class_category,p_class_code);
     if l_code_level =1
     then

	-- update those rows inserted in register_lookup_code_post with code relations
	-- Due to language concern and func can't be called in the update,
        -- concat meaning will be handled seperately.

	update as_hz_class_code_denorm ccd
	set code_level = 2,
        concat_class_code = l_concat_code
	where class_category = p_class_category
	and class_code = p_sub_class_code;

	insert into as_hz_class_code_denorm (
	class_category,
	class_category_meaning,
	class_code,
	class_code_meaning,
	class_code_description,
        ancestor_code,
	ancestor_meaning,
	language,
	concat_class_code,
	concat_class_code_meaning,
	code_level,
	start_date_active,
	end_date_active,
	enabled_flag,
	selectable_flag,
	segment1,
	segment2,
	segment3,
        segment4,
	segment5,
	segment6,
	segment7,
        segment8,
	segment9,
        segment10,
	segment1_meaning,
	segment2_meaning,
	segment3_meaning,
        segment4_meaning,
	segment5_meaning,
	segment6_meaning,
	segment7_meaning,
        segment8_meaning,
	segment9_meaning,
	segment10_meaning,
	created_by,
	creation_date,
	last_updated_by,
	last_update_login,
	last_update_date,
	request_id,
	program_id,
	program_application_id,
	program_update_date
	)
	select
	class_category,
	class_category_meaning,
	p_sub_class_code,
	lv.meaning,
	lv.description,
        ancestor_code,
	ancestor_meaning,
	lv.language,
	l_concat_code,
        'temp-meaning',
	2,
	lv.start_date_active,
	lv.end_date_active,
	lv.enabled_flag,
	'Y',
	'not used',
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	'not used',
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	nvl(fnd_global.user_id,-1),
	sysdate,
	nvl(fnd_global.user_id,-1),
	nvl(fnd_global.login_id,-1),
	sysdate,
	fnd_global.conc_request_id,
	fnd_global.conc_program_id,
	fnd_global.prog_appl_id,
	sysdate
     from
	as_hz_class_code_denorm denorm,
	fnd_lookup_values lv
    where
	denorm.class_category = lv.lookup_type
	and 	denorm.language = lv.language
	and	denorm.class_category = p_class_category
	and	denorm.class_code = p_class_code
	and 	lv.lookup_code = p_sub_class_code
	and	denorm.code_level = 1;

  elsif	l_code_level =2
  then

	-- update those rows inserted in register_lookup_code_post with code relations
	update as_hz_class_code_denorm ccd
	set code_level = 3,
            concat_class_code = l_concat_code
	where class_code = p_sub_class_code
	and class_category = p_class_category;

	insert into as_hz_class_code_denorm (
	class_category,
	class_category_meaning,
	class_code,
	class_code_meaning,
	class_code_description,
        ancestor_code,
	ancestor_meaning,
	language,
	concat_class_code,
	concat_class_code_meaning,
	code_level,
	start_date_active,
	end_date_active,
	enabled_flag,
	selectable_flag,
	segment1,
	segment2,
	segment3,
        segment4,
	segment5,
	segment6,
	segment7,
        segment8,
	segment9,
        segment10,
	segment1_meaning,
	segment2_meaning,
	segment3_meaning,
        segment4_meaning,
	segment5_meaning,
	segment6_meaning,
	segment7_meaning,
        segment8_meaning,
	segment9_meaning,
	segment10_meaning,
	created_by,
	creation_date,
	last_updated_by,
	last_update_login,
	last_update_date,
	request_id,
	program_id,
	program_application_id,
	program_update_date
	)
	select
	class_category,
	class_category_meaning,
	p_sub_class_code,
	lv.meaning,
	lv.description,
        ancestor_code,
	ancestor_meaning,
	lv.language,
	l_concat_code,
	'temp-meaning',
	3,
	lv.start_date_active,
	lv.end_date_active,
	lv.enabled_flag,
	'Y',
	'not used',
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	'not used',
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	nvl(fnd_global.user_id,-1),
	sysdate,
	nvl(fnd_global.user_id,-1),
	nvl(fnd_global.login_id,-1),
	sysdate,
	fnd_global.conc_request_id,
	fnd_global.conc_program_id,
	fnd_global.prog_appl_id,
	sysdate
     from
	as_hz_class_code_denorm denorm,
	fnd_lookup_values lv
    where
	denorm.class_category = lv.lookup_type
	and 	denorm.language = lv.language
	and	denorm.class_category = p_class_category
	and	denorm.class_code = p_class_code
	and 	lv.lookup_code = p_sub_class_code
	and	denorm.code_level = 2;

  elsif	l_code_level =3
  then

	-- update those rows inserted in register_lookup_code_post with code relations
	update as_hz_class_code_denorm ccd
	set code_level = 4,
	    concat_class_code = l_concat_code
	where class_code = p_sub_class_code
	and class_category = p_class_category;

	insert into as_hz_class_code_denorm (
	class_category,
	class_category_meaning,
	class_code,
	class_code_meaning,
	class_code_description,
        ancestor_code,
	ancestor_meaning,
	language,
	concat_class_code,
	concat_class_code_meaning,
	code_level,
	start_date_active,
	end_date_active,
	enabled_flag,
	selectable_flag,
	segment1,
	segment2,
	segment3,
        segment4,
	segment5,
	segment6,
	segment7,
        segment8,
	segment9,
        segment10,
	segment1_meaning,
	segment2_meaning,
	segment3_meaning,
        segment4_meaning,
	segment5_meaning,
	segment6_meaning,
	segment7_meaning,
        segment8_meaning,
	segment9_meaning,
	segment10_meaning,
	created_by,
	creation_date,
	last_updated_by,
	last_update_login,
	last_update_date,
	request_id,
	program_id,
	program_application_id,
	program_update_date
	)
	select
	class_category,
	class_category_meaning,
	p_sub_class_code,
	lv.meaning,
	lv.description,
        ancestor_code,
	ancestor_meaning,
	lv.language,
	l_concat_code,
	'temp-meaning',
	4,
	lv.start_date_active,
	lv.end_date_active,
	lv.enabled_flag,
	'Y',
	segment1,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	segment1_meaning,
	  NULL,
        NULL,
        NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	nvl(fnd_global.user_id,-1),
	sysdate,
	nvl(fnd_global.user_id,-1),
	nvl(fnd_global.login_id,-1),
	sysdate,
	fnd_global.conc_request_id,
	fnd_global.conc_program_id,
	fnd_global.prog_appl_id,
	sysdate
     from
	as_hz_class_code_denorm denorm,
	fnd_lookup_values lv
    where
	denorm.class_category = lv.lookup_type
	and 	denorm.language = lv.language
	and	denorm.class_category = p_class_category
	and	denorm.class_code = p_class_code
	and 	lv.lookup_code = p_sub_class_code
	and	denorm.code_level = 3;
    end if;

    --    Due to language concern, meaning needs to be handled seperately.
    update_concate_meaning(p_class_category,p_sub_class_code);

    open get_leaf_node_flag_csr;
    fetch get_leaf_node_flag_csr into l_leaf_node_flag;
    close get_leaf_node_flag_csr;
    if l_leaf_node_flag = 'Y'
    then
	update_selectable_flag(p_class_category);
    end if;
end;

procedure create_class_code_rel_post(p_class_category in varchar2,
				  p_class_code in varchar2,
				  p_sub_class_code in varchar2,
				  p_start_date_active in date,
				  p_end_date_active in date
				) is
l_code_level number;
begin
	l_code_level := get_class_code_level(p_class_category,p_class_code);
	if l_code_level < 4
		and sysdate between p_start_date_active and nvl(p_end_date_active,sysdate)
	then
		insert_current_code_relation(p_class_category,p_class_code,p_sub_class_code);
	end if;

	-- no code level > 4 case, since we only allow 4 level
	if l_code_level = 4
	then
		-- delete extra data entered from register_lookup_code_post where level > 4 for sub code.
		delete
		from as_hz_class_code_denorm
		where class_category = p_class_category
		and class_code = p_sub_class_code
		and code_level = 1;
	end if;

	Exception
	  When Others then
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,'Error in Cre code rel Post:' || sqlerrm);
          FND_MSG_PUB.Add_Exc_Msg('AS_CLASSIFICATION_HOOKS', 'create_class_code_rel_post');

end;

procedure update_class_code_rel_post(p_class_category in varchar2,
				  p_class_code in varchar2,
				  p_sub_class_code in varchar2,
				  p_end_date_active in date) is
	cursor get_sub_sub_class_code is
		select sub_class_code
		from hz_class_code_relations
		where class_category = p_class_category
		and p_class_code = p_sub_class_code
		and sysdate between start_date_active and nvl(end_date_active,sysdate);

	cursor get_concat_meaning_csr is
		select lookup_code,language,as_classification_hooks.get_concat_meaning(lookup_type,lookup_code,language)
		from fnd_lookup_values
		where lookup_type = p_class_category;

	 cursor get_concat_code_csr is
                select lookup_code,as_classification_hooks.get_concat_code(lookup_type,lookup_code)
                from fnd_lookup_values
                where lookup_type = p_class_category;

	cursor code_relation_exist_csr is
		select 'x'
		from as_hz_class_code_denorm
		where class_category = p_class_category
		and class_code = p_sub_class_code
		and ancestor_code = p_class_code
		and language = userenv('LANG');

l_code_level number;
l_sub_sub_code varchar2(30);
l_concat_meaning varchar2(2000);
l_concat_code varchar2(500);
l_class_code varchar2(30);
l_language varchar2(30);
l_tmp varchar2(1);
begin

	open get_concat_code_csr;
                loop
                        fetch get_concat_code_csr into l_class_code,l_concat_code;
                        exit when get_concat_code_csr%NOTFOUND;
                        update as_hz_class_code_denorm
                        set concat_class_code = l_concat_code
                        where class_category = p_class_category
                        and class_code = l_class_code;

                end loop;
        close get_concat_code_csr;
	open get_concat_meaning_csr;
		loop
			fetch get_concat_meaning_csr into l_class_code,l_language,l_concat_meaning;
			exit when get_concat_meaning_csr%NOTFOUND;
			update as_hz_class_code_denorm
			set concat_class_code_meaning = l_concat_meaning
			where class_category = p_class_category
			and class_code = l_class_code
			and language = l_language;
		end loop;
	close get_concat_meaning_csr;

	l_code_level := get_class_code_level(p_class_category,p_sub_class_code);
	if nvl(p_end_date_active,sysdate) < sysdate
	then
	-- end date a relationship will not affect any rows with code_level=1
	-- since level = 1 means self relationship only

		if l_code_level =2
		then
		-- for example, code relation from parent to child like 1->2->3->4,
		-- if end date relation between 1 and 2, the hierarchy will look like 1, 2->3->4
		-- code relation 1->2, 1->3, 1->4 need to be deleted

			delete
			from as_hz_class_code_denorm
			where class_category = p_class_category
			and ancestor_code = p_class_code
			and class_code <> p_class_code;

			update as_hz_class_code_denorm
                        set code_level = code_level-1
                        where class_category = p_class_category
                        and code_level <> 1;

		-- if end date relation between 2 and 3, the hierarchy will look like 1->2,3->4
		-- code relation 1->3,1->4, 2->3,2->4 need to be deleted.
		-- since maximum level = 4, we only need to set 3 to level 1 and 4 to level 2
		elsif	l_code_level = 3
		then
			open get_sub_sub_class_code;
			fetch get_sub_sub_class_code into l_sub_sub_code;
			close get_sub_sub_class_code;

			delete
			from as_hz_class_code_denorm
			where class_category = p_class_category
			and ancestor_code <> p_sub_class_code
			and class_code = p_sub_class_code
			  or (class_code = l_sub_sub_code and ancestor_code not in (l_sub_sub_code,p_sub_class_code));

			update as_hz_class_code_denorm
                        set code_level = 1
                        where class_category = p_class_category
                        and class_code = p_sub_class_code;

                        update as_hz_class_code_denorm
                        set code_level = 2
                        where class_category = p_class_category
                        and class_code = l_sub_sub_code;

		-- if end date relation between 3 and 4, the hierarchy will look like 1->2->3, 4
		-- relation 1->4,2->4,3->4 need to be deleted

		elsif	l_code_level = 4
		then
			delete
			from as_hz_class_code_denorm
			where class_category = p_class_category
			and class_code = p_sub_class_code
			and ancestor_code<>p_sub_class_code;

			 update as_hz_class_code_denorm
                        set code_level = 1
                        where class_category = p_class_category
                        and class_code = p_sub_class_code
                        and ancestor_code = p_sub_class_code;

		end if;
	end if;

	-- if end_date is change to active again
	if nvl(p_end_date_active,sysdate) >= sysdate
	then
		open code_relation_exist_csr;
		fetch code_relation_exist_csr into l_tmp;
		if code_relation_exist_csr%NOTFOUND
		then
			insert_current_code_relation(p_class_category,p_class_code,p_sub_class_code);
		end if;
		close code_relation_exist_csr;
	end if;
	Exception
	  When Others then
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,'Error in Upd code rel Post:' || sqlerrm);
          FND_MSG_PUB.Add_Exc_Msg('AS_CLASSIFICATION_HOOKS', 'update_class_code_rel_post');

end;

END AS_CLASSIFICATION_HOOKS;

/
