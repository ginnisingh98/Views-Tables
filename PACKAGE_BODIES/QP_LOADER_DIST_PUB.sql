--------------------------------------------------------
--  DDL for Package Body QP_LOADER_DIST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_LOADER_DIST_PUB" as
/* $Header: QPXPLDDB.pls 120.1 2006/06/21 09:35:22 rnayani noship $ */

function p_detect_dup_mapping_cols(p_segment_id in number,
                                   p_prc_context_id in number,
                                   p_segment_mapping_column in varchar2,
                                   p_segment_code in varchar2,
                                   p_action in varchar2) return number
is
   dummy  varchar2(1);
begin
  select 'x'
  into dummy
  from qp_segments_b a, qp_prc_contexts_b b
  where a.prc_context_id = b.prc_context_id and
        a.prc_context_id = p_prc_context_id and
        segment_mapping_column = p_segment_mapping_column and
        segment_code <> p_segment_code and
        rownum = 1;
  --
  insert into qp_upgrade_errors
    (creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     error_type,
     error_desc,
     error_module) values
    (sysdate,
     fnd_global.user_id,
     sysdate,
     fnd_global.user_id,
     'ATTRIBUTE_MANAGER_LCT_UPLOAD',
     substr('Seeded attribute '|| upper(p_segment_code) ||
     ' mapped to '|| p_segment_mapping_column ||
     ' is already used. ' || p_action||' this Attribute,'||
     ' its PTE-Links and Mapping rules manually.'||
     ' Refer to Pricing Implementation Guide for this Attribute''s details.',1,200),
     'Attribute Manager');
  --
  return(0);
exception
  when no_data_found then
    return(-1);
end;
--
procedure qp_prc_contexts_translate_row (
	x_prc_context_code in varchar2,
	x_prc_context_type in varchar2,
	x_seeded_flag in varchar2,
	x_enabled_flag in varchar2,
	x_application_id in varchar2,
	x_seeded_prc_context_name in varchar2,
	x_seeded_description in varchar2,
	x_custom_mode in varchar2,
	x_last_update_date in varchar2,
	x_owner in varchar2
)
is
begin

--Bug#5237456 RAVI
--Seeded data does not contain application ID
--	if x_application_id = '661' then

		update qp_prc_contexts_tl set
			user_prc_context_name = decode(seeded_prc_context_name, user_prc_context_name, x_seeded_prc_context_name, user_prc_context_name),
		  	--seeded_prc_context_name = nvl(seeded_prc_context_name, x_seeded_prc_context_name),
		  	seeded_prc_context_name = nvl(x_seeded_prc_context_name, seeded_prc_context_name),
			user_description = decode(seeded_description, user_description, x_seeded_description, user_description),
		  	--seeded_description = nvl(seeded_description, x_seeded_description),
		  	seeded_description = nvl(x_seeded_description, seeded_description),
		  	last_update_date = nvl(to_date(x_last_update_date,'YYYY/MM/DD'),sysdate),
		  	last_updated_by = decode(x_owner, 'SEED', 1, 'ORACLE', 1, 3),
		  	last_update_login = 0,
		  	source_lang = userenv('LANG')
	  		where prc_context_id =
			(select prc_context_id from qp_prc_contexts_b
	  			where prc_context_code = x_prc_context_code
				and prc_context_type = x_prc_context_type)
		  	and userenv('LANG') in (language, source_lang);

--Bug#5237456 RAVI
--Seeded data does not contain application ID
--	end if;

end qp_prc_contexts_translate_row;

procedure qp_prc_contexts_load_row (
	x_prc_context_code in varchar2,
	x_prc_context_type in varchar2,
	x_seeded_flag in varchar2,
	x_enabled_flag in varchar2,
	x_application_id in varchar2,
	x_seeded_prc_context_name in varchar2,
	x_seeded_description in varchar2,
	x_custom_mode in varchar2,
	x_last_update_date in varchar2,
	x_owner in varchar2
)
is
	l_prc_context_id		number := null;
	l_prc_context_s			number;
	l_user_id 				number := 3;

begin



	if (x_owner in ('SEED','ORACLE')) then
			l_user_id := 1;
	end if;

	begin
		select prc_context_id into l_prc_context_id from qp_prc_contexts_b
		  	where prc_context_code = x_prc_context_code
			and prc_context_type = x_prc_context_type
			and rownum = 1;

		if x_application_id = '661' then
		 	update qp_prc_contexts_b set
				seeded_flag = x_seeded_flag,
				enabled_flag = x_enabled_flag,
		      	last_updated_by = l_user_id,
		      	last_update_date = nvl(to_date(x_last_update_date,'YYYY/MM/DD'),sysdate),
		      	last_update_login = 0
		 		where prc_context_id = l_prc_context_id;

			update qp_prc_contexts_tl set
				user_prc_context_name = decode(seeded_prc_context_name, user_prc_context_name, x_seeded_prc_context_name, user_prc_context_name),
			  	seeded_prc_context_name = nvl(seeded_prc_context_name, x_seeded_prc_context_name),
				user_description = decode(seeded_description, user_description, x_seeded_description, user_description),
			  	seeded_description = nvl(seeded_description, x_seeded_description),
			  	last_update_date = nvl(to_date(x_last_update_date,'YYYY/MM/DD'),sysdate),
			  	last_updated_by = l_user_id,
			  	last_update_login = 0,
			  	source_lang = userenv('LANG')
		 		where prc_context_id = l_prc_context_id
			  	and userenv('LANG') in (language, source_lang);
		end if;

	exception
		when no_data_found then
			select qp_prc_contexts_s.nextval into l_prc_context_s from dual;
			begin
	       	insert into qp_prc_contexts_b (
				prc_context_id,
				prc_context_code,
				prc_context_type,
				seeded_flag,
				enabled_flag,
				creation_date,
		     	created_by,
		     	last_update_date,
		     	last_update_login,
		     	last_updated_by
				) values (
				l_prc_context_s,
				x_prc_context_code,
				x_prc_context_type,
				x_seeded_flag,
				x_enabled_flag,
			   	sysdate,
				l_user_id,
				nvl(to_date(x_last_update_date,'YYYY/MM/DD'),sysdate),
			   	0,
				l_user_id
				);
				commit;

	       	insert into qp_prc_contexts_tl (
				prc_context_id,
			  	seeded_prc_context_name,
			  	user_prc_context_name,
			  	seeded_description,
			  	user_description,
		  		source_lang,
		  		language,
				creation_date,
		     	created_by,
		     	last_update_date,
		     	last_update_login,
		     	last_updated_by
				)  select
				l_prc_context_s,
			  	x_seeded_prc_context_name,
			  	x_seeded_prc_context_name,
			  	x_seeded_description,
			  	x_seeded_description,
				userenv('LANG'),
		  		l.language_code,
			   	sysdate,
			   	l_user_id,
				nvl(to_date(x_last_update_date,'YYYY/MM/DD'),sysdate),
			   	0,
				l_user_id
	  			from fnd_languages l
	  			where l.installed_flag in ('I', 'B')
	  			and not exists
			    (select null
		  		from qp_prc_contexts_tl t
		  		where t.prc_context_id = l_prc_context_id
			    and t.language = l.language_code);
				commit;
			exception
				when others then
					null;
			end;
	when others then
		null;
	end;

end qp_prc_contexts_load_row;


procedure qp_segments_translate_row (
	x_segment_code in varchar2,
	x_prc_context_code in varchar2,
	x_prc_context_type in varchar2,
	x_availability_in_basic in varchar2,
	x_application_id in varchar2,
	x_segment_mapping_column in varchar2,
	x_seeded_flag in varchar2,
	x_seeded_precedence in varchar2,
	x_flex_value_set_name in varchar2,
	x_seeded_format_type in varchar2,
	x_seeded_segment_name in varchar2,
	x_seeded_description in varchar2,
	x_custom_mode in varchar2,
	x_last_update_date in varchar2,
	x_owner in varchar2
)
is
  l_segment_id       number;
  l_prc_context_id   number;
begin
	begin
          select segment_id,
                 prc_context_id
          into l_segment_id,
               l_prc_context_id
          from qp_segments_b
          where segment_code = x_segment_code and
                prc_context_id = (select prc_context_id from qp_prc_contexts_b
			  	  where prc_context_code = x_prc_context_code and
                                  prc_context_type = x_prc_context_type);
          if p_detect_dup_mapping_cols( l_segment_id,
                                        l_prc_context_id,
                                        x_segment_mapping_column,
                                        x_segment_code,
                                        'Update') = -1 then
	    update qp_segments_tl
            set user_segment_name = decode(seeded_segment_name, user_segment_name,
                                           x_seeded_segment_name, user_segment_name),
	  	--seeded_segment_name = nvl(seeded_segment_name, x_seeded_segment_name),
	  	seeded_segment_name = nvl(x_seeded_segment_name, seeded_segment_name),
	        user_description = decode(seeded_description, user_description,
                                      x_seeded_segment_name, user_description),
                --seeded_description = nvl(seeded_description, x_seeded_description),
                seeded_description = nvl(x_seeded_description, seeded_description),
	  	last_update_date = nvl(to_date(x_last_update_date,'YYYY/MM/DD'),sysdate),
	  	last_updated_by = decode(x_owner, 'SEED', 1, 'ORACLE', 1, 3),
	  	last_update_login = 0,
	  	source_lang = userenv('LANG')
             where segment_id =  l_segment_id and
                   userenv('LANG') in (language, source_lang);
          end if;
	exception
	when others then
		null;
	end;

end qp_segments_translate_row;

procedure qp_segments_load_row (
	x_segment_code in varchar2,
	x_prc_context_code in varchar2,
	x_prc_context_type in varchar2,
	x_availability_in_basic in varchar2,
	x_application_id in varchar2,
	x_segment_mapping_column in varchar2,
	x_seeded_flag in varchar2,
	x_seeded_precedence in varchar2,
	x_flex_value_set_name in varchar2,
	x_seeded_format_type in varchar2,
	x_seeded_segment_name in varchar2,
	x_seeded_description in varchar2,
	x_required_flag in varchar2,
	x_custom_mode in varchar2,
	x_last_update_date in varchar2,
	x_owner in varchar2
)
is
  l_prc_context_id    number;
  l_segment_id        number;
  l_segment_s         number;
  l_user_id           number := 3;
  l_valueset_id       number;
  nc                  number;
begin
	if (x_owner in ('SEED','ORACLE')) then
 		l_user_id := 1;
	end if;

	begin
		select flex_value_set_id into l_valueset_id from fnd_flex_value_sets
			where flex_value_set_name = x_flex_value_set_name;
	exception
		when others then
			null;
	end;

	begin
		select prc_context_id into l_prc_context_id from qp_prc_contexts_b
			where prc_context_code = x_prc_context_code
			and prc_context_type = x_prc_context_type
			and rownum = 1;
	exception
		when others then
			null;
	end;

	if l_prc_context_id is not null then

		begin
			select segment_id into l_segment_id from qp_segments_b
				where segment_code = x_segment_code
				and prc_context_id = l_prc_context_id;

                        if p_detect_dup_mapping_cols( l_segment_id,
                                                      l_prc_context_id,
                                                      x_segment_mapping_column,
                                                      x_segment_code, 'Update') = -1 then
		   	  update qp_segments_b set
				availability_in_basic = x_availability_in_basic,
				application_id = x_application_id,
				segment_mapping_column = x_segment_mapping_column,
				seeded_flag = x_seeded_flag,
				user_precedence = decode(seeded_precedence, user_precedence,
                                                         x_seeded_precedence, user_precedence),
				seeded_precedence = x_seeded_precedence,
				user_valueset_id = l_valueset_id,
				seeded_valueset_id = l_valueset_id,
				user_format_type = decode(seeded_format_type, user_format_type,
                                                          x_seeded_format_type, user_format_type),
				required_flag = decode (last_updated_by, 1, x_required_flag, required_Flag),
				seeded_format_type = x_seeded_format_type,
		   		last_updated_by = l_user_id,
				last_update_date = nvl(to_date(x_last_update_date,'YYYY/MM/DD'),sysdate),
				last_update_login = 0
				where segment_id = l_segment_id;

			  update qp_segments_tl set
				user_segment_name = decode(seeded_segment_name, user_segment_name,
                                                           x_seeded_segment_name, user_segment_name),
			  	seeded_segment_name = nvl(seeded_segment_name, x_seeded_segment_name),
                                user_description = decode(seeded_description,
user_description,
                                                           x_seeded_description
, user_description),
                                seeded_description = nvl(seeded_description, x_seeded_description),
			  	last_update_date = nvl(to_date(x_last_update_date,'YYYY/MM/DD'),sysdate),
			  	last_updated_by = l_user_id,
			  	last_update_login = 0,
			  	source_lang = userenv('LANG')
				where segment_id = l_segment_id
			  	and userenv('LANG') in (language, source_lang);
                        end if;
		exception
			when no_data_found then
                           select qp_segments_s.nextval
                           into l_segment_s
                           from dual;
                           begin
                                if p_detect_dup_mapping_cols( l_segment_id,
                                                              l_prc_context_id,
                                                              x_segment_mapping_column,
                                                              x_segment_code,'Add') = -1 then
		         	  insert into qp_segments_b (
						segment_id,
						segment_code,
						prc_context_id,
						availability_in_basic,
						application_id,
						segment_mapping_column,
						seeded_flag,
						seeded_precedence,
						user_precedence,
						seeded_valueset_id,
						user_valueset_id,
						seeded_format_type,
						user_format_type,
						required_flag,
						creation_date,
                                                created_by,
                                                last_update_date,
                                                last_update_login,
                                                last_updated_by
						) values (
						l_segment_s,
						x_segment_code,
						l_prc_context_id,
						x_availability_in_basic,
						x_application_id,
						x_segment_mapping_column,
						x_seeded_flag,
						x_seeded_precedence,
						x_seeded_precedence,
						l_valueset_id,
						l_valueset_id,
						x_seeded_format_type,
						x_seeded_format_type,
						x_required_flag,
					   	sysdate,
					   	l_user_id,
						nvl(to_date(x_last_update_date,'YYYY/MM/DD'),sysdate),
					   	0,
						l_user_id
						);
                                  commit;
                                  ---
			       	  insert into qp_segments_tl (
						segment_id,
					  	seeded_segment_name,
					  	user_segment_name,
						seeded_description,
						user_description,
				  		source_lang,
				  		language,
						creation_date,
                                                created_by,
                                                last_update_date,
                                                last_update_login,
                                                last_updated_by
						) select
                                                  l_segment_s,
                                                  x_seeded_segment_name,
                                                  x_seeded_segment_name,
						  x_seeded_description,
						  x_seeded_description,
                                                  userenv('LANG'),
                                                  l.language_code,
                                                  sysdate,
                                                  l_user_id,
                                                  nvl(to_date(x_last_update_date,'YYYY/MM/DD'),sysdate),
                                                  0,
                                                  l_user_id
			  			  from fnd_languages l
			  			  where l.installed_flag in ('I', 'B') and
			  			        not exists (select null
                                                                    from qp_segments_tl t
                                                                    where t.segment_id = l_segment_id and
                                                                          t.language = l.language_code);
                                  commit;
                                end if;
			exception
				when others then
					null;
			end;
		when others then
			null;
		end;

	end if;

end qp_segments_load_row;

end qp_loader_dist_pub;

/
