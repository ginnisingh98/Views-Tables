--------------------------------------------------------
--  DDL for Package Body ICX_PAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_PAGES_PKG" as
/* $Header: ICXPAGHB.pls 115.2 1999/11/23 18:44:46 pkm ship      $ */

--  ***********************************************
--	procedure INSERT_ROW
--  ***********************************************

procedure INSERT_ROW (
  x_rowid		in out varchar2,
  x_page_id		in number,
  x_page_code		in varchar2,
  x_main_region_id	in number,
  x_sequence_number	in number,
  x_page_type		in varchar2,
  x_user_id		in number,
  x_refresh_rate	in number,
  x_page_name		in varchar2,
  x_page_description	in varchar2,
  x_creation_date	in date,
  x_created_by		in number,
  x_last_update_date	in date,
  x_last_updated_by	in number,
  x_last_update_login	in number
) is

  cursor C is select ROWID from ICX_PAGES
    where PAGE_ID = X_PAGE_ID;

begin
  insert into ICX_PAGES (
    page_code,
    main_region_id,
    sequence_number,
    page_type,
    page_id,
    user_id,
    refresh_rate,
	page_name,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login
  ) values (
    x_page_code,
    x_main_region_id,
    x_sequence_number,
    x_page_type,
    x_page_id,
    x_user_id,
    x_refresh_rate,
	x_page_name,
    x_creation_date,
    x_created_by,
    x_last_update_date,
    x_last_updated_by,
    x_last_update_login
  );

  insert into ICX_PAGES_TL (
    page_id,
    page_name,
    page_description,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    language,
    source_lang
  ) select
    x_page_id,
    x_page_name,
    x_page_description,
    x_last_update_date,
    x_last_updated_by,
    x_creation_date,
    x_created_by,
    x_last_update_login,
    l.language_code,
    userenv('LANG')
  from fnd_languages l
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from ICX_PAGES_TL T
    where T.PAGE_ID = X_PAGE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

--  ***********************************************
--	procedure UPDATE_ROW
--  ***********************************************

procedure UPDATE_ROW (
  x_page_id		in number,
  x_page_code		in varchar2,
  x_main_region_id	in number,
  x_sequence_number	in number,
  x_page_type		in varchar2,
  x_user_id		in number,
  x_refresh_rate	in number,
  x_page_name		in varchar2,
  x_page_description	in varchar2,
  x_last_update_date	in date,
  x_last_updated_by	in number,
  x_last_update_login	in number
) is
begin
  update icx_pages set
    page_code		= x_page_code,
    main_region_id	= x_main_region_id,
    sequence_number	= x_sequence_number,
    page_type		= x_page_type,
    user_id		= x_user_id,
    refresh_rate	= x_refresh_rate,
    last_update_date	= x_last_update_date,
    last_updated_by	= x_last_updated_by,
    last_update_login	= x_last_update_login
  where page_id = x_page_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update icx_pages_tl set
    page_name		= x_page_name,
    page_description	= x_page_description,
    last_update_date	= x_last_update_date,
    last_updated_by	= x_last_updated_by,
    last_update_login	= x_last_update_login,
    source_lang		= userenv('LANG')
  where page_id = x_page_id
  and userenv('LANG') in (language, source_lang);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;


--  ***********************************************
--	procedure ADD_LANGUAGE
--  ***********************************************

procedure ADD_LANGUAGE
is
begin
  delete from ICX_PAGES_TL T
  where not exists
    (select NULL
    from ICX_PAGES B
    where B.PAGE_ID = T.PAGE_ID
    );

  update icx_pages_tl t set (
      page_name,
      page_description
    ) = (select
      b.page_name,
      b.page_description
    from icx_pages_tl b
    where b.page_id = t.page_id
    and b.language = t.source_lang)
  where (
      t.page_id,
      t.language
  ) in (select
      subt.page_id,
      subt.language
    from icx_pages_tl subb, icx_pages_tl subt
    where subb.page_id = subt.page_id
    and subb.language = subt.source_lang
    and (subb.page_name <> subt.page_name
      or (subb.page_name is null and subt.page_name is not null)
      or (subb.page_name is not null and subt.page_name is null)
      or subb.page_description <> subt.page_description
      or (subb.page_description is null and subt.page_description is not null)
      or (subb.page_description is not null and subt.page_description is null)
  ));

  insert into ICX_PAGES_TL (
    page_id,
    page_name,
    page_description,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    language,
    source_lang
  ) select
    b.page_id,
    b.page_name,
    b.page_description,
    b.last_update_date,
    b.last_updated_by,
    b.creation_date,
    b.created_by,
    b.last_update_login,
    l.language_code,
    b.source_lang
  from ICX_PAGES_TL b, FND_LANGUAGES l
  where l.installed_flag in ('I', 'B')
  and b.language = userenv('LANG')
  and not exists
    (select NULL
    from icx_pages_tl t
    where t.page_id = b.page_id
    and t.language = l.language_code);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  x_page_id			in varchar2,
  x_page_name		in varchar2,
  x_page_description	in varchar2
) is
begin

  update ICX_PAGES_tl set
    page_name			= X_PAGE_NAME,
	page_description	= X_PAGE_DESCRIPTION,
    SOURCE_LANG		     = userenv('LANG'),
    last_update_date         = sysdate,
    last_updated_by          = 1,
    last_update_login        = 0
  where page_id = X_PAGE_ID
  and userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_PAGE_ID		in	number,
  X_PAGE_CODE		in 	VARCHAR2,
  x_main_region_id	in number,
  x_sequence_number	in number,
  x_page_type		in varchar2,
  x_user_id		in number,
  x_refresh_rate	in number,
  x_page_name		in varchar2,
  x_page_description	in varchar2
) is
begin

  declare
     l_page_id    number := 0;
     row_id 	varchar2(64);

  begin

     select PAGE_ID into l_page_id
     from   ICX_PAGES
     where  PAGE_ID = X_PAGE_ID;

     icx_pages_pkg.UPDATE_ROW (
		x_page_id			=>	x_page_id,
		x_page_code			=>	x_page_code,
		x_main_region_id	=>	x_main_region_id,
		x_sequence_number	=>	x_sequence_number,
		x_page_type			=>	x_page_type,
		x_user_id			=>	x_user_id,
		x_refresh_rate		=>	x_refresh_rate,
		x_page_name			=>	x_page_name,
		x_page_description	=>	x_page_description,
		x_last_update_date	=>	sysdate,
		x_last_updated_by	=> 1,
		x_last_update_login	=> 0);

  exception
     when NO_DATA_FOUND then

       icx_pages_pkg.INSERT_ROW (
		X_ROWID				=>	row_id,
		x_page_id			=>	x_page_id,
		x_page_code			=>	x_page_code,
		x_main_region_id	=>	x_main_region_id,
		x_sequence_number	=>	x_sequence_number,
		x_page_type			=>	x_page_type,
		x_user_id			=>	x_user_id,
		x_refresh_rate		=>	x_refresh_rate,
		x_page_name			=>	x_page_name,
		x_page_description	=>	x_page_description,
		x_creation_date		=>	sysdate,
		x_created_by		=>	1,
		x_last_update_date	=>	sysdate,
		x_last_updated_by	=>	1,
		x_last_update_login	=>	0);
  end;
end LOAD_ROW;

end ICX_PAGES_PKG;

/
