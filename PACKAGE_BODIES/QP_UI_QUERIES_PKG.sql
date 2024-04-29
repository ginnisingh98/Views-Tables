--------------------------------------------------------
--  DDL for Package Body QP_UI_QUERIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_UI_QUERIES_PKG" as
/* $Header: QPXVUIQB.pls 120.0 2005/06/02 01:06:00 appldev noship $ */
procedure INSERT_ROW (
  X_QUERY_ID in NUMBER,
  X_PUBLIC_FLAG in VARCHAR2,
  X_LINES_WHERE_CLAUSE in VARCHAR2,
  X_HEADERS_WHERE_CLAUSE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  X_ROWID ROWID;
  cursor C is select ROWID from QP_UI_QUERIES_TL
    where QUERY_ID = X_QUERY_ID
    and LANGUAGE = userenv('LANG')
    ;
begin
  insert into QP_UI_QUERIES_TL (
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PUBLIC_FLAG,
    LINES_WHERE,
    QUERY_ID,
    NAME,
    HEADER_WHERE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_PUBLIC_FLAG,
    X_LINES_WHERE_CLAUSE,
    X_QUERY_ID,
    X_NAME,
    X_HEADERS_WHERE_CLAUSE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from QP_UI_QUERIES_TL T
    where T.QUERY_ID = X_QUERY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_QUERY_ID in NUMBER,
  X_PUBLIC_FLAG in VARCHAR2 DEFAULT NULL,
  X_NAME in VARCHAR2 DEFAULT NULL
) is
  cursor c1 is select
      PUBLIC_FLAG,
      NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from QP_UI_QUERIES_TL
    where QUERY_ID = X_QUERY_ID
    for update of QUERY_ID nowait;
begin
  for tlinfo in c1 loop
    if x_public_flag is not null and x_name is not null then
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
          AND (tlinfo.PUBLIC_FLAG = X_PUBLIC_FLAG)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_QUERY_ID in NUMBER,
  X_DELETE_FLAG in VARCHAR2,
  X_PUBLIC_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update QP_UI_QUERIES_TL set
    DELETE_FLAG = X_DELETE_FLAG,
    PUBLIC_FLAG = X_PUBLIC_FLAG,
    NAME = X_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = Userenv('LANG')
  where QUERY_ID = X_QUERY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_QUERY_ID in NUMBER
) is
begin
  delete from QP_UI_QUERIES_TL
  where QUERY_ID = X_QUERY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure Insert_Columns(
  p_header_column_tbl IN UI_TREE_TBL,
  p_query_id        IN Number
) is
  i Number;
Begin
  if p_header_column_tbl.count>0 then
   for i in p_header_column_tbl.first .. p_header_column_tbl.last loop
     Insert_row_columns
		  (
		  p_header_column_tbl(i).column_name,
		  p_header_column_tbl(i).column_value,
		  p_header_column_tbl(i).column_type,
		  p_header_column_tbl(i).column_index_id,
		  p_query_id
		  );

    end loop;
   end if;

end Insert_columns;

procedure INSERT_ROW_COLUMNS(
  p_column_name IN varchar2,
  p_column_value  IN varchar2,
  p_column_data_type   IN varchar2,
  p_column_index_id   IN  number,
  p_query_id       IN     number
) IS
 l_column_id Number;
 l_record_exist  Number;
BEGIN
  select count(*)
    into l_record_exist
    from qp_ui_query_columns
   where query_id = p_query_id
     and query_column_index_id = p_column_index_id;

  if l_record_exist > 0 then
     return;
  end if;

  Select qp_ui_query_columns_s.nextval
  Into   l_column_id
  From   dual;

 INSERT INTO QP_UI_QUERY_COLUMNS
    (
     COLUMN_ID,
     QUERY_ID,
     QUERY_COLUMN_INDEX_ID,
     COLUMN_NAME,
     COLUMN_VALUE,
     COLUMN_TYPE,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY
    )
   VALUES
   (l_column_id,
    p_query_id,
    p_column_index_id,
    p_column_name,
    p_column_value,
    p_column_data_type,
    sysdate,
    FND_GLOBAL.USER_ID,
    sysdate,
    FND_GLOBAL.USER_ID
    );

END INSERT_ROW_COLUMNS;

procedure ADD_LANGUAGE
is
begin

  update QP_UI_QUERIES_TL T set (
      NAME
    ) = (select
      B.NAME
    from QP_UI_QUERIES_TL B
    where B.QUERY_ID = T.QUERY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.QUERY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.QUERY_ID,
      SUBT.LANGUAGE
    from QP_UI_QUERIES_TL SUBB, QP_UI_QUERIES_TL SUBT
    where SUBB.QUERY_ID = SUBT.QUERY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
  ));

  insert into QP_UI_QUERIES_TL (
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PUBLIC_FLAG,
    LINES_WHERE,
    QUERY_ID,
    NAME,
    HEADER_WHERE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.PUBLIC_FLAG,
    B.LINES_WHERE,
    B.QUERY_ID,
    B.NAME,
    B.HEADER_WHERE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from QP_UI_QUERIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from QP_UI_QUERIES_TL T
    where T.QUERY_ID = B.QUERY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;

end QP_UI_QUERIES_PKG;

/
