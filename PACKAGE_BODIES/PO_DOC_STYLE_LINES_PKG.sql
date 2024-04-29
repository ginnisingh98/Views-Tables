--------------------------------------------------------
--  DDL for Package Body PO_DOC_STYLE_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOC_STYLE_LINES_PKG" AS
  /* $Header: PO_DOC_STYLE_LINES_PKG.plb 120.2 2006/06/21 07:29:46 scolvenk noship $ */

  g_pkg_name CONSTANT VARCHAR2(30) := 'PO_DOC_STYLE_LINES_PKG';




 PROCEDURE TRANSLATE_ROW(
               X_STYLE_ID IN NUMBER,
	       X_DOCUMENT_SUBTYPE in VARCHAR2,
	       X_DISPLAY_NAME in VARCHAR2,
	       X_OWNER     in VARCHAR2,
	       X_LAST_UPDATE_DATE in VARCHAR2,
	       X_CUSTOM_MODE in VARCHAR2)
IS

  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

  begin

    f_luby := fnd_load_util.owner_id(X_OWNER);
    f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'DD/MM/YYYY'), sysdate);

    select DECODE(LAST_UPDATED_BY, -1, 1, LAST_UPDATED_BY), LAST_UPDATE_DATE
    into  db_luby, db_ludate
    from PO_DOC_STYLE_LINES_TL
    where style_id   = X_STYLE_ID
    and  document_subtype   = X_DOCUMENT_SUBTYPE
    and  language = userenv('LANG') ;

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then


     update po_doc_style_lines_tl
        set   source_lang              =  userenv('LANG')
             ,display_name             =  X_DISPLAY_NAME
             ,last_updated_by          =  f_luby
             ,last_update_login        =  0
             ,last_update_date         =  f_ludate
       where style_id = X_STYLE_ID
         and document_subtype = X_DOCUMENT_SUBTYPE
         and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    end if;

  exception
   when no_data_found then
      -- Do not insert missing translations, skip this row
      null;
  end TRANSLATE_ROW;




procedure UPDATE_ROW(
                      X_STYLE_ID       in NUMBER,
	              X_DOCUMENT_SUBTYPE in VARCHAR2,
                      X_ENABLED_FLAG     in VARCHAR2,
		      X_DISPLAY_NAME     in VARCHAR2,
                      X_LAST_UPDATE_DATE in DATE,
                      X_LAST_UPDATED_BY in NUMBER,
                      X_LAST_UPDATE_LOGIN in NUMBER) IS

begin
	update po_doc_style_lines_b
	set   enabled_flag              = X_ENABLED_FLAG
	      ,last_updated_by          = X_LAST_UPDATED_BY
	      ,last_update_login        = 0
	      ,last_update_date         = X_LAST_UPDATE_DATE
	where style_id = X_STYLE_ID
	and document_subtype = X_DOCUMENT_SUBTYPE;

	if (sql%notfound) then
	    raise no_data_found;
	end if;

	update po_doc_style_lines_tl
	set   source_lang              =  userenv('LANG')
	     ,display_name             =  X_DISPLAY_NAME
	     ,last_updated_by          =  X_LAST_UPDATED_BY
	     ,last_update_login        =  X_LAST_UPDATE_LOGIN
	     ,last_update_date         =  X_LAST_UPDATE_DATE
	where style_id = X_STYLE_ID
	 and document_subtype = X_DOCUMENT_SUBTYPE
	 and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

	if (sql%notfound) then
	  raise no_data_found;
	end if;
end UPDATE_ROW;

procedure INSERT_ROW(
                      X_STYLE_ID       in NUMBER,
	              X_DOCUMENT_SUBTYPE in VARCHAR2,
                      X_ENABLED_FLAG     in VARCHAR2,
		      X_DISPLAY_NAME     in VARCHAR2,
                      X_LAST_UPDATE_DATE in DATE,
                      X_LAST_UPDATED_BY in NUMBER,
                      X_LAST_UPDATE_LOGIN in NUMBER) IS
begin


	insert into po_doc_style_lines_b (
	 style_id
	,document_subtype
	,enabled_flag
	,creation_date
	,created_by
	,last_updated_by
	,last_update_login
	,last_update_date)
	values (
	 X_STYLE_ID
	,X_DOCUMENT_SUBTYPE
	,X_ENABLED_FLAG
	,X_LAST_UPDATE_DATE
	,X_LAST_UPDATED_BY
	,X_LAST_UPDATED_BY
	,X_LAST_UPDATE_LOGIN
	,X_LAST_UPDATE_DATE);


	insert into po_doc_style_lines_tl (
	 style_id
	,document_subtype
	,language
	,source_lang
	,display_name
	,creation_date
	,created_by
	,last_updated_by
	,last_update_login
	,last_update_date)
	select
	X_STYLE_ID
	,X_DOCUMENT_SUBTYPE
	,l.language_code
	,userenv('LANG')
	,X_DISPLAY_NAME
	,X_LAST_UPDATE_DATE
	,X_LAST_UPDATED_BY
	,X_LAST_UPDATED_BY
	,X_LAST_UPDATE_LOGIN
	,X_LAST_UPDATE_DATE
	from fnd_languages l
	where l.installed_flag in ('I', 'B')
	and not exists
	    (select null
	     from po_doc_style_lines_tl t
	     where t.language = l.language_code
	       and t.style_id = X_STYLE_ID
	       and t.document_subtype =X_DOCUMENT_SUBTYPE);



end INSERT_ROW;

PROCEDURE LOAD_ROW(
                      X_STYLE_ID         in NUMBER,
	              X_DOCUMENT_SUBTYPE in VARCHAR2,
                      X_ENABLED_FLAG     in VARCHAR2,
		      X_DISPLAY_NAME     in VARCHAR2,
                      X_OWNER            in VARCHAR2,
                      X_LAST_UPDATE_DATE in DATE,
                      X_CUSTOM_MODE      in VARCHAR2) IS

	l_row_id    varchar2(64);
	l_category_id number;
	f_luby    number;  -- entity owner in file
	f_ludate  date;    -- entity update date in file
	db_luby   number;  -- entity owner in db
	db_ludate date;    -- entity update date in db

begin

	  f_luby := fnd_load_util.owner_id(X_OWNER);
	  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'DD/MM/YYYY'), sysdate);

	  select LAST_UPDATED_BY, LAST_UPDATE_DATE
	  into  db_luby, db_ludate
	  from  po_doc_style_lines_tl
	  where style_id = X_STYLE_ID
	  and document_subtype =X_DOCUMENT_SUBTYPE
          and language = userenv('LANG') ;


	    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
					  db_ludate, X_CUSTOM_MODE)) then

		UPDATE_ROW(
		      X_STYLE_ID         => X_STYLE_ID,
	              X_DOCUMENT_SUBTYPE => X_DOCUMENT_SUBTYPE,
                      X_ENABLED_FLAG     => X_ENABLED_FLAG,
		      X_DISPLAY_NAME     => X_DISPLAY_NAME,
                      X_LAST_UPDATE_DATE => f_ludate ,
                      X_LAST_UPDATED_BY  => f_luby,
                      X_LAST_UPDATE_LOGIN => 0);
	    end if;

	     exception
	       when NO_DATA_FOUND then

		INSERT_ROW(
		      X_STYLE_ID         => X_STYLE_ID,
	              X_DOCUMENT_SUBTYPE => X_DOCUMENT_SUBTYPE,
                      X_ENABLED_FLAG     => X_ENABLED_FLAG,
		      X_DISPLAY_NAME     => X_DISPLAY_NAME,
                      X_LAST_UPDATE_DATE => f_ludate,
                      X_LAST_UPDATED_BY  => f_luby,
                      X_LAST_UPDATE_LOGIN => 0);
end LOAD_ROW;

procedure ADD_LANGUAGE
IS

begin

delete from po_doc_style_lines_tl T
  where not exists
    (select NULL
    from po_doc_style_lines_b B
    where B.STYLE_ID = T.STYLE_ID
    and  B.DOCUMENT_SUBTYPE = T.DOCUMENT_SUBTYPE);

 update po_doc_style_lines_tl T
 set (
      DISPLAY_NAME
     ) = (select
      DISPLAY_NAME
    from po_doc_style_lines_tl B
    where B.STYLE_ID = T.STYLE_ID
    and  B.DOCUMENT_SUBTYPE = T.DOCUMENT_SUBTYPE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.STYLE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.STYLE_ID,
      SUBT.LANGUAGE
    from po_doc_style_lines_tl SUBB,
         po_doc_style_lines_tl SUBT
    where SUBB.STYLE_ID = SUBT.STYLE_ID
    and SUBB.DOCUMENT_SUBTYPE = SUBT.DOCUMENT_SUBTYPE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and  SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
  );
        --Bug5237451: Last_update_date was not updated properly

	insert into po_doc_style_lines_tl (
	 style_id
	,document_subtype
	,language
	,source_lang
	,display_name
	,last_update_date         --Bug5237451
	,creation_date
	,created_by
	,last_updated_by
       )
	select
	 B.STYLE_ID
	,B.DOCUMENT_SUBTYPE
	,l.language_code
	,userenv('LANG')
	,B.DISPLAY_NAME
	,B.LAST_UPDATE_DATE
	,B.CREATION_DATE          --Bug5237451
	,B.CREATED_BY
	,B.LAST_UPDATED_BY
	from fnd_languages l, po_doc_style_lines_tl B
	where l.installed_flag in ('I', 'B')
	and  B.LANGUAGE = userenv('LANG')
	and not exists
	    (select null
	     from po_doc_style_lines_tl t
	     where t.language = l.language_code
	       and t.style_id = B.STYLE_ID
	       and t.document_subtype =B.DOCUMENT_SUBTYPE);


   end ADD_LANGUAGE;


END PO_DOC_STYLE_LINES_PKG;

/
