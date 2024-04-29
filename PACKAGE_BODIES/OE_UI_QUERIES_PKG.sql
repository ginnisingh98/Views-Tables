--------------------------------------------------------
--  DDL for Package Body OE_UI_QUERIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_UI_QUERIES_PKG" as
/* $Header: OEXVUIQB.pls 120.1 2005/09/06 14:44:53 jvicenti noship $ */
procedure INSERT_ROW (
  X_QUERY_ID in NUMBER,
  X_PUBLIC_FLAG in VARCHAR2,
  X_LINES_WHERE_CLAUSE in VARCHAR2,
  X_HEADERS_WHERE_CLAUSE in VARCHAR2,
  X_ADV_HDR_WHERE_CLAUSE in VARCHAR2,
  X_ADV_LIN_WHERE_CLAUSE in VARCHAR2,
  X_HOLDS_WHERE_CLAUSE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ORG_ACCESS_TYPE in VARCHAR2 default NULL,
  X_ORG_ID in NUMBER default NULL
) is
  X_ROWID ROWID;
  cursor C is select ROWID from OE_UI_QUERIES_TL
    where QUERY_ID = X_QUERY_ID
    and LANGUAGE = userenv('LANG')
    ;
begin
  insert into OE_UI_QUERIES_TL (
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PUBLIC_FLAG,
    LINES_WHERE_CLAUSE,
    QUERY_ID,
    NAME,
    HEADERS_WHERE_CLAUSE,
    ADV_HDR_WHERE_CLAUSE,
    ADV_LIN_WHERE_CLAUSE,
    HOLDS_WHERE_CLAUSE,
    LANGUAGE,
    SOURCE_LANG,
    ORG_ACCESS_TYPE,
    ORG_ID
  ) Values
  ( X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_PUBLIC_FLAG,
    X_LINES_WHERE_CLAUSE,
    X_QUERY_ID,
    X_NAME,
    X_HEADERS_WHERE_CLAUSE,
    X_ADV_HDR_WHERE_CLAUSE,
    X_ADV_LIN_WHERE_CLAUSE,
    X_HOLDS_WHERE_CLAUSE,
    USERENV('LANG'),
    USERENV('LANG'),
    X_ORG_ACCESS_TYPE,
    X_ORG_ID
   );
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
    from OE_UI_QUERIES_TL
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
  update OE_UI_QUERIES_TL set
    DELETE_FLAG = X_DELETE_FLAG,
    PUBLIC_FLAG = X_PUBLIC_FLAG,
    NAME = X_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = Userenv('LANG')
  where QUERY_ID = X_QUERY_ID
  and userenv('LANG') = LANGUAGE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_QUERY_ID in NUMBER
) is
begin
  delete from OE_UI_QUERIES_TL
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
BEGIN
  Select oe_ui_query_columns_s.nextval
  Into   l_column_id
  From   dual;
 INSERT INTO OE_UI_QUERY_COLUMNS
    (
     COLUMN_ID,
     QUERY_ID,
     QUERY_COLUMN_INDEX_ID,
     COLUMN_NAME,
     COLUMN_VALUE,
     COLUMN_TYPE,
     OVERRIDE_FLAG,
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
    Null,
    sysdate,
    FND_GLOBAL.USER_ID,
    sysdate,
    FND_GLOBAL.USER_ID
    );

END INSERT_ROW_COLUMNS;


procedure ADD_LANGUAGE
is
begin
  Null;
end ADD_LANGUAGE;

end OE_UI_QUERIES_PKG;

/
