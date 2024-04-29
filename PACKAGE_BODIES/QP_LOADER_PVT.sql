--------------------------------------------------------
--  DDL for Package Body QP_LOADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_LOADER_PVT" as
/* $Header: QPXVLDQB.pls 120.1 2005/06/08 17:09:28 appldev  $ */

-- ==================================================
-- Constants and Types.
-- ==================================================
g_date_mask             VARCHAR2(100) := 'YYYY/MM/DD HH24:MI:SS';
g_default_lud           DATE;


-- ==================================================
-- Functions and Procedures.
-- ==================================================


function UPLOAD_TEST(
  p_file_id     in number,
  p_file_lud    in date,
  p_db_id       in number,
  p_db_lud      in date,
  p_custom_mode in varchar2)
return boolean is
  l_db_id number;
  l_file_id number;
  l_original_seed_data_window date;
  retcode boolean;
begin
  -- CUSTOM_MODE=FORCE trumps all.
  if (p_custom_mode = 'FORCE') then
    retcode := TRUE;
    return retcode;
  end if;

  -- Handle cases where data was previously up/downloaded with
  -- 'SEED'/1 owner instead of 'ORACLE'/2, but DOES have a version
  -- date.  These rows can be distinguished by the lud timestamp;
  -- Rows without versions were uploaded with sysdate, rows with
  -- versions were uploaded with a date (with time truncated) from
  -- the file.

  -- Check file row for SEED/version
  l_file_id := p_file_id;
  if ((l_file_id in (0,1)) and (p_file_lud = trunc(p_file_lud)) and
      (p_file_lud < sysdate - .1)) then
    l_file_id := 2;
  end if;

  -- Check db row for SEED/version.
  -- NOTE: if db ludate < seed_data_window, then consider this to be
  -- original seed data, never touched by FNDLOAD, even if it doesn't
  -- have a timestamp.
  l_db_id := p_db_id;
  l_original_seed_data_window := to_date('01/01/1990','MM/DD/YYYY');
  if ((l_db_id in (0,1)) and (p_db_lud = trunc(p_db_lud)) and
      (p_db_lud > l_original_seed_data_window)) then
    l_db_id := 2;
  end if;

  if (l_file_id in (0,1)) then
    -- File owner is old FNDLOAD.
    if (l_db_id in (0,1)) then
      -- DB owner is also old FNDLOAD.
      -- Over-write, but only if file ludate >= db ludate.
      if (p_file_lud >= p_db_lud) then
        retcode := TRUE;
      else
        retcode := FALSE;
      end if;
    else
      retcode := FALSE;
    end if;
  elsif (l_file_id = 2) then
    -- File owner is new FNDLOAD.  Over-write if:
    -- 1. Db owner is old FNDLOAD, or
    -- 2. Db owner is new FNDLOAD, and file date >= db date
    if ((l_db_id in (0,1)) or
	((l_db_id = 2) and (p_file_lud >= p_db_lud))) then
      retcode :=  TRUE;
    else
      retcode := FALSE;
    end if;
  else
    -- File owner is USER.  Over-write if:
    -- 1. Db owner is old or new FNDLOAD, or
    -- 2. File date >= db date
    if ((l_db_id in (0,1,2)) or
	(p_file_lud >= p_db_lud)) then
      retcode := TRUE;
    else
      retcode := FALSE;
    end if;
  end if;

  if (retcode = FALSE) then
    fnd_message.set_name('FND', 'FNDLOAD_CUSTOMIZED');
  end if;
  return retcode;
end UPLOAD_TEST;

FUNCTION is_upload_allowed(p_custom_mode                  IN VARCHAR2,
			   p_file_owner                   IN VARCHAR2,
			   p_file_last_update_date        IN VARCHAR2,
			   p_db_last_updated_by           IN NUMBER,
			   p_db_last_update_date          IN DATE,
			   x_file_who                     IN OUT nocopy who_type)
  RETURN BOOLEAN
  IS
     l_db_who     who_type;
     l_file_owner VARCHAR2(100);
     l_db_owner   VARCHAR2(100);
     l_return     BOOLEAN;
BEGIN
   --
   -- Set File (Source) WHO.
   --
   BEGIN
      l_file_owner                 := p_file_owner;
      x_file_who.last_updated_by   := fnd_load_util.owner_id(l_file_owner);
      --
      -- Remove the time component from file LUD. We used to use Sysdate for
      -- NULL case, but it is better to use a fixed date.
      --
      x_file_who.last_update_date  := Trunc(Nvl(To_date(p_file_last_update_date,
							g_date_mask),
						g_default_lud));
      x_file_who.last_update_login := 0;
      x_file_who.created_by        := x_file_who.last_updated_by;
      x_file_who.creation_date     := x_file_who.last_update_date;
   EXCEPTION
      WHEN OTHERS THEN
	 l_file_owner                 := 'SEED'; -- 1
	 x_file_who.last_updated_by   := fnd_load_util.owner_id(l_file_owner);
	 x_file_who.last_update_date  := Trunc(g_default_lud);
	 x_file_who.last_update_login := 0;
	 x_file_who.created_by        := x_file_who.last_updated_by;
	 x_file_who.creation_date     := x_file_who.last_update_date;
   END;

   --
   -- Set DB (Destination) WHO
   --
   l_db_who.last_updated_by   := Nvl(p_db_last_updated_by,
				     x_file_who.last_updated_by);
   l_db_owner                 := fnd_load_util.owner_name(l_db_who.last_updated_by);
   l_db_who.last_update_date  := Nvl(p_db_last_update_date,
				     x_file_who.last_update_date - 1);
   l_db_who.last_update_login := 0;
   l_db_who.created_by        := l_db_who.last_updated_by;
   l_db_who.creation_date     := l_db_who.last_update_date;

   --
   -- Check if UPLOAD is allowed. i.e. no customizations.
   --
   -- Return TRUE  if
   -- - custom_mode = 'FORCE'.
   -- - db (destination) is owned by SEED but file (source)is not owned by SEED.
   -- - owners are same but destination is older.
   --
   --  IF ((p_custom_mode = 'FORCE') OR
   --   ((l_db_who.last_updated_by = 1) AND
   --   (x_file_who.last_updated_by <> 1)) OR
   --   ((l_db_who.last_updated_by = x_file_who.last_updated_by) AND
   --   (l_db_who.last_update_date <= x_file_who.last_update_date)))

   l_return := fnd_load_util.upload_test
     (p_file_id     => x_file_who.last_updated_by,
      p_file_lud    => x_file_who.last_update_date,
      p_db_id       => l_db_who.last_updated_by,
      p_db_lud      => l_db_who.last_update_date,
      p_custom_mode => p_custom_mode);

   IF (l_return IS NULL) THEN
      l_return := FALSE;
   END IF;

   RETURN(l_return);
EXCEPTION
   WHEN OTHERS THEN
      RETURN(FALSE);
END is_upload_allowed;

Procedure qp_pte_source_sys_load_row (
	x_pte_code in varchar2,
	x_application_short_name in varchar2,
	x_enabled_flag in varchar2,
	x_custom_mode in varchar2,
	x_last_update_date in varchar2,
	x_owner in varchar2
)
is
        l_user_id number := 0;
        l_pte_source_system_id number;
        l_db_last_updated_by   NUMBER;
        l_db_last_update_date  DATE;
        l_db_who     who_type;

begin

        if (x_owner = 'SEED') then
                l_user_id := 1;
        end if;

        begin
          select last_updated_by, last_update_date  into l_db_last_updated_by, l_db_last_update_date
          from qp_pte_source_systems
          where pte_code = x_pte_code
                and application_short_name = x_application_short_name
                and rownum = 1;

          IF (NOT is_upload_allowed
              (p_custom_mode                  => x_custom_mode,
               p_file_owner                   => x_owner,
               p_file_last_update_date        => x_last_update_date,
               p_db_last_updated_by           => l_db_last_updated_by,
               p_db_last_update_date          => l_db_last_update_date,
               x_file_who                     => l_db_who))
          THEN
               null;
          else
               update qp_pte_source_systems
               set enabled_flag = x_enabled_flag,
                   last_updated_by = l_user_id,
                   last_update_date =to_date(x_last_update_date,'YYYY/MM/DD'),
                   last_update_login = 0
               where pte_code = x_pte_code
                     and application_short_name = x_application_short_name;

          END IF;

        exception
          when no_data_found then
          begin

             select qp_pte_source_system_s.nextval into l_pte_source_system_id from dual;

             insert into qp_pte_source_systems
                  (pte_source_system_id,
                   pte_code,
                   application_short_name,
                   enabled_flag,
                   creation_date,
                   created_by,
                   last_update_date,
                   last_update_login,
                   last_updated_by)
             values
                  (l_pte_source_system_id,
                   x_pte_code,
                   x_application_short_name,
                   x_enabled_flag,
                   sysdate,
                   l_user_id,
                   to_date(x_last_update_date,'YYYY/MM/DD'),
                   0,
                   l_user_id);
         end;
        end;
end qp_pte_source_sys_load_row;

Procedure qp_pte_ss_fn_area_load_row (
	x_pte_code in varchar2,
	x_application_short_name in varchar2,
	x_functional_area_id in varchar2,
	x_enabled_flag in varchar2,
	x_seeded_flag in varchar2,
	x_custom_mode in varchar2,
	x_last_update_date in varchar2,
	x_owner in varchar2
)
is
        l_user_id number := 0;
        l_pte_source_system_id number;
        l_pte_sourcesystem_fnarea_id number;
        l_db_last_updated_by   NUMBER;
        l_db_last_update_date  DATE;
        l_db_who     who_type;

begin

        if (x_owner = 'SEED') then
                l_user_id := 1;
        end if;

        begin
          select pte_source_system_id into l_pte_source_system_id
          from qp_pte_source_systems
          where pte_code = x_pte_code
                and application_short_name = x_application_short_name
                and rownum = 1;
        exception
          when others then
               null;
        end;

        if l_pte_source_system_id is not null then
           begin
               select pte_sourcesystem_fnarea_id,last_updated_by, last_update_date
               into l_pte_sourcesystem_fnarea_id, l_db_last_updated_by, l_db_last_update_date
               from QP_SOURCESYSTEM_FNAREA_MAP
               where pte_source_system_id = l_pte_source_system_id
                     and functional_area_id = x_functional_area_id
                     and rownum = 1;

               IF (NOT is_upload_allowed
                   (p_custom_mode                  => x_custom_mode,
                    p_file_owner                   => x_owner,
                    p_file_last_update_date        => x_last_update_date,
                    p_db_last_updated_by           => l_db_last_updated_by,
                    p_db_last_update_date          => l_db_last_update_date,
                    x_file_who                     => l_db_who))
               THEN
                    null;
               else
                    update QP_SOURCESYSTEM_FNAREA_MAP
                    set     enabled_flag = x_enabled_flag,
                            seeded_flag = x_seeded_flag,
                            last_updated_by = l_user_id,
                            last_update_date =to_date(x_last_update_date,'YYYY/MM/DD'),
                            last_update_login = 0
                    where   pte_sourcesystem_fnarea_id = l_pte_sourcesystem_fnarea_id;

               END IF;

           exception
             when no_data_found then
             begin

               select qp_pte_ss_fnarea_id_s.nextval into l_pte_sourcesystem_fnarea_id from dual;

               insert into QP_SOURCESYSTEM_FNAREA_MAP ( pte_sourcesystem_fnarea_id,
                                                        pte_source_system_id,
                                                        functional_area_id,
                                                        enabled_flag,
                                                        seeded_flag,
                                                        creation_date,
                                                        created_by,
                                                        last_update_date,
                                                        last_update_login,
                                                        last_updated_by)
                                                values (l_pte_sourcesystem_fnarea_id,
                                                        l_pte_source_system_id,
                                                        x_functional_area_id,
                                                        x_enabled_flag,
                                                        x_seeded_flag,
                                                        sysdate,
                                                        l_user_id,
                                                        to_date(x_last_update_date,'YYYY/MM/DD'),
                                                        0,
                                                        l_user_id);

             end;
           end;
        end if;
end qp_pte_ss_fn_area_load_row;

procedure qp_pte_req_types_translate_row (
	x_pte_code in varchar2,
	x_request_type_code in varchar2,
	x_order_level_global_struct in varchar2,
	x_line_level_global_struct in varchar2,
	x_order_level_view_name in varchar2,
	x_line_level_view_name in varchar2,
	x_enabled_flag in varchar2,
	x_request_type_desc in varchar2,
	x_custom_mode in varchar2,
	x_last_update_date in varchar2,
	x_owner in varchar2
)
is
begin

	update qp_pte_request_types_tl set
	  	request_type_desc = nvl(x_request_type_desc, request_type_desc),
	  	last_update_date = to_date(x_last_update_date,'YYYY/MM/DD'),
	  	last_updated_by = decode(x_owner, 'SEED', 1, 0),
	  	last_update_login = 0,
	  	source_lang = userenv('LANG')
	  	where request_type_code = x_request_type_code
	  	and userenv('LANG') in (language, source_lang);

end qp_pte_req_types_translate_row;

procedure qp_pte_req_types_load_row (
	x_pte_code in varchar2,
	x_request_type_code in varchar2,
	x_order_level_global_struct in varchar2,
	x_line_level_global_struct in varchar2,
	x_order_level_view_name in varchar2,
	x_line_level_view_name in varchar2,
	x_enabled_flag in varchar2,
	x_request_type_desc in varchar2,
	x_custom_mode in varchar2,
	x_last_update_date in varchar2,
	x_owner in varchar2
)
is
    l_user_id 			number := 0;

begin

	if (x_owner = 'SEED') then
 		l_user_id := 1;
	end if;

	update qp_pte_request_types_b set
		order_level_global_struct = x_order_level_global_struct,
		line_level_global_struct = x_line_level_global_struct,
		order_level_view_name = x_order_level_view_name,
		line_level_view_name = x_line_level_view_name,
		enabled_flag = x_enabled_flag,
		last_updated_by = l_user_id,
		last_update_date = to_date(x_last_update_date ,'YYYY/MM/DD'),
		last_update_login = 0
		where request_type_code = x_request_type_code
		and pte_code = x_pte_code;

	if sql%notfound then
       	insert into qp_pte_request_types_b (
			request_type_code,
			pte_code,
			order_level_global_struct,
			line_level_global_struct,
			order_level_view_name,
			line_level_view_name,
			enabled_flag,
			creation_date,
	     	created_by,
	     	last_update_date,
	     	last_update_login,
	     	last_updated_by
			) values (
			x_request_type_code,
			x_pte_code,
			x_order_level_global_struct,
			x_line_level_global_struct,
			x_order_level_view_name,
			x_line_level_view_name,
			x_enabled_flag,
		   	sysdate,
		   	l_user_id,
		   	to_date(x_last_update_date,'YYYY/MM/DD'),
                        0,
			l_user_id
			);

       	insert into qp_pte_request_types_tl (
			request_type_code,
	  		request_type_desc,
	  		source_lang,
	  		language,
			creation_date,
	     	created_by,
	     	last_update_date,
	     	last_update_login,
	     	last_updated_by
			)  select
			x_request_type_code,
			x_request_type_desc,
			userenv('LANG'),
	  		l.language_code,
		   	sysdate,
		   	l_user_id,
		   	to_date(x_last_update_date,'YYYY/MM/DD'),
                        0,
			l_user_id
  			from fnd_languages l
  			where l.installed_flag in ('I', 'B')
  			and not exists
		    (select null
		    	from qp_pte_request_types_tl t,
		    	qp_pte_request_types_b b
		    	where t.request_type_code = x_request_type_code
		    	and t.language = l.language_code);

	else
		update qp_pte_request_types_tl set
		  	request_type_desc = nvl(x_request_type_desc, request_type_desc),
		  	last_update_date=to_date(x_last_update_date,'YYYY/MM/DD'),
		  	last_updated_by = l_user_id,
		  	last_update_login = 0,
		  	source_lang = userenv('LANG')
		  	where request_type_code = x_request_type_code
		  	and userenv('LANG') in (language, source_lang);
	end if;

end qp_pte_req_types_load_row;

end qp_loader_pvt;

/
