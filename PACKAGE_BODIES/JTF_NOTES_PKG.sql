--------------------------------------------------------
--  DDL for Package Body JTF_NOTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_NOTES_PKG" as
/* $Header: jtfnttbb.pls 120.1.12010000.2 2009/05/26 11:44:25 ipananil ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_JTF_NOTE_ID in NUMBER,
  X_SOURCE_OBJECT_CODE in VARCHAR2,
  X_NOTE_STATUS in VARCHAR2,
  X_ENTERED_BY in NUMBER,
  X_ENTERED_DATE in DATE,
  X_NOTE_TYPE in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_CONTEXT in VARCHAR2,
  X_PARENT_NOTE_ID in NUMBER,
  X_SOURCE_OBJECT_ID in NUMBER,
  X_NOTES in VARCHAR2,
  X_NOTES_DETAIL in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_NOTES_B
    where JTF_NOTE_ID = X_JTF_NOTE_ID
    ;
begin
  insert into JTF_NOTES_B (
    SOURCE_OBJECT_CODE,
    NOTE_STATUS,
    ENTERED_BY,
    ENTERED_DATE,
    NOTE_TYPE,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    CONTEXT,
    JTF_NOTE_ID,
    PARENT_NOTE_ID,
    SOURCE_OBJECT_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_SOURCE_OBJECT_CODE,
    X_NOTE_STATUS,
    X_ENTERED_BY,
    X_ENTERED_DATE,
    X_NOTE_TYPE,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_CONTEXT,
    X_JTF_NOTE_ID,
    X_PARENT_NOTE_ID,
    X_SOURCE_OBJECT_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTF_NOTES_TL (
    JTF_NOTE_ID,
    NOTES,
    NOTES_DETAIL,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_JTF_NOTE_ID,
    X_NOTES,
    EMPTY_CLOB(),
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B');

 If X_Notes_Detail is not null then
    JTF_NOTES_PUB.writedatatolob(X_JTF_NOTE_ID,X_NOTES_DETAIL);

end If;

   INSERT INTO JTF_NOTE_CONTEXTS
    ( NOTE_CONTEXT_ID,
	 JTF_NOTE_ID,
	 NOTE_CONTEXT_TYPE_ID,
	 NOTE_CONTEXT_TYPE,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 LAST_UPDATE_LOGIN)
  VALUES (
     jtf_notes_s.nextval,
	x_jtf_note_id,
	x_source_object_id,
	x_source_object_code,
	x_creation_date,
	x_created_by,
	x_last_update_date,
	x_last_updated_by,
	x_last_update_login
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
  X_JTF_NOTE_ID in NUMBER,
  X_SOURCE_OBJECT_CODE in VARCHAR2,
  X_NOTE_STATUS in VARCHAR2,
  X_ENTERED_BY in NUMBER,
  X_ENTERED_DATE in DATE,
  X_NOTE_TYPE in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_CONTEXT in VARCHAR2,
  X_PARENT_NOTE_ID in NUMBER,
  X_SOURCE_OBJECT_ID in NUMBER,
  X_NOTES in VARCHAR2,
  X_NOTES_DETAIL in VARCHAR2
) is
  cursor c is select
      SOURCE_OBJECT_CODE,
      NOTE_STATUS,
      ENTERED_BY,
      ENTERED_DATE,
      NOTE_TYPE,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      CONTEXT,
      PARENT_NOTE_ID,
      SOURCE_OBJECT_ID
    from JTF_NOTES_B
    where JTF_NOTE_ID = X_JTF_NOTE_ID
    for update of JTF_NOTE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NOTES,
      NOTES_DETAIL,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_NOTES_TL
    where JTF_NOTE_ID = X_JTF_NOTE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of JTF_NOTE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.SOURCE_OBJECT_CODE = X_SOURCE_OBJECT_CODE)
      AND ((recinfo.NOTE_STATUS = X_NOTE_STATUS)
           OR ((recinfo.NOTE_STATUS is null) AND (X_NOTE_STATUS is null)))
      AND (recinfo.ENTERED_BY = X_ENTERED_BY)
      AND (recinfo.ENTERED_DATE = X_ENTERED_DATE)
      AND ((recinfo.NOTE_TYPE = X_NOTE_TYPE)
           OR ((recinfo.NOTE_TYPE is null) AND (X_NOTE_TYPE is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.CONTEXT = X_CONTEXT)
           OR ((recinfo.CONTEXT is null) AND (X_CONTEXT is null)))
      AND ((recinfo.PARENT_NOTE_ID = X_PARENT_NOTE_ID)
           OR ((recinfo.PARENT_NOTE_ID is null) AND (X_PARENT_NOTE_ID is null)))
      AND (recinfo.SOURCE_OBJECT_ID = X_SOURCE_OBJECT_ID)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if     (tlinfo.NOTES = X_NOTES) then
		/*
          AND ((DBMS_LOB.COMPARE(tlinfo.NOTES_DETAIL , X_NOTES_DETAIL,DBMS_LOB.GETLENGTH(X_NOTES_DETAIL),1,1) = 0)
               OR ((tlinfo.NOTES_DETAIL is null) AND (X_NOTES_DETAIL is null)))
      )then */
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_JTF_NOTE_ID in NUMBER,
  X_SOURCE_OBJECT_CODE in VARCHAR2,
  X_NOTE_STATUS in VARCHAR2,
  X_ENTERED_BY in NUMBER,
  X_ENTERED_DATE in DATE,
  X_NOTE_TYPE in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_CONTEXT in VARCHAR2,
  X_PARENT_NOTE_ID in NUMBER,
  X_SOURCE_OBJECT_ID in NUMBER,
  X_NOTES in VARCHAR2,
  X_NOTES_DETAIL in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_NOTES_B set
    SOURCE_OBJECT_CODE = X_SOURCE_OBJECT_CODE,
    NOTE_STATUS = X_NOTE_STATUS,
    ENTERED_BY = X_ENTERED_BY,
    ENTERED_DATE = X_ENTERED_DATE,
    NOTE_TYPE = X_NOTE_TYPE,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    CONTEXT = X_CONTEXT,
    PARENT_NOTE_ID = X_PARENT_NOTE_ID,
    SOURCE_OBJECT_ID = X_SOURCE_OBJECT_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where JTF_NOTE_ID = X_JTF_NOTE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_NOTES_TL set
    NOTES = X_NOTES,
    NOTES_DETAIL = X_NOTES_DETAIL,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where JTF_NOTE_ID = X_JTF_NOTE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_JTF_NOTE_ID in NUMBER
) is
begin
  delete from JTF_NOTES_TL
  where JTF_NOTE_ID = X_JTF_NOTE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_NOTES_B
  where JTF_NOTE_ID = X_JTF_NOTE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin

/** Commented for now for the bug #4229850
  delete from JTF_NOTES_TL T
  where not exists
    (select NULL
    from JTF_NOTES_B B
    where B.JTF_NOTE_ID = T.JTF_NOTE_ID
    );

  update JTF_NOTES_TL T set (
      NOTES,
      NOTES_DETAIL
    ) = (select
      B.NOTES,
      B.NOTES_DETAIL
    from JTF_NOTES_TL B
    where B.JTF_NOTE_ID = T.JTF_NOTE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.JTF_NOTE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.JTF_NOTE_ID,
      SUBT.LANGUAGE
    from JTF_NOTES_TL SUBB, JTF_NOTES_TL SUBT
    where SUBB.JTF_NOTE_ID = SUBT.JTF_NOTE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NOTES <> SUBT.NOTES
      or (( DBMS_LOB.COMPARE(SUBB.NOTES_DETAIL, SUBT.NOTES_DETAIL,DBMS_LOB.GETLENGTH(SUBB.NOTES_DETAIL),1,1)) <> 0)
      or (SUBB.NOTES_DETAIL is null and SUBT.NOTES_DETAIL is not null)
      or (SUBB.NOTES_DETAIL is not null and SUBT.NOTES_DETAIL is null)
  ));
**/
/* Commented the code for Perf. Bug 4229850  */
/*
  insert into JTF_NOTES_TL (
    JTF_NOTE_ID,
    NOTES,
    NOTES_DETAIL,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.JTF_NOTE_ID,
    B.NOTES,
    B.NOTES_DETAIL,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_NOTES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_NOTES_TL T
    where T.JTF_NOTE_ID = B.JTF_NOTE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
*/
--
-- Added this code Perf. Bug 3723927
--
insert /*+ append parallel(tl) */  into JTF_NOTES_TL tl
  (
    JTF_NOTE_ID,
    NOTES,
    NOTES_DETAIL,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  )
SELECT /*+ parallel(v) parallel(t) use_nl(t) */ v.*
FROM ( SELECT /*+ no_merge ordered parallel(b) */
    B.JTF_NOTE_ID,
    B.NOTES,
    B.NOTES_DETAIL,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_NOTES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
 ) v, JTF_NOTES_TL t
where t.JTF_NOTE_ID(+) = v.JTF_NOTE_ID
  AND t.language(+) = v.language_code
  AND t.JTF_NOTE_ID is null;

end ADD_LANGUAGE;


PROCEDURE writeDatatoLob
    (X_jtf_note_id NUMBER,
     X_BUFFER VARCHAR2)
Is
 lob_loc CLOB;
 Position INTEGER := 1;
 Buffer VARCHAR2(32767);

 cursor c1 is
    select notes_detail
    from jtf_notes_tl
    where jtf_note_id = x_jtf_note_id
    for update;
Begin

  for i in c1
  loop
     DBMS_LOB.WRITE(i.notes_detail,length(X_BUFFER),position,x_buffer);
  end loop;
End WriteDataToLob;

FUNCTION get_note_context_value( p_note_context_type IN VARCHAR2
                               , p_note_context_type_id IN NUMBER )
  RETURN VARCHAR2 IS
  l_note_context_value   VARCHAR2(240);
  l_select_id            jtf_objects_b.select_id%TYPE;
  l_select_name          jtf_objects_b.select_name%TYPE;
  l_tablename            jtf_objects_b.from_table%TYPE;
  l_where_clause         jtf_objects_b.where_clause%TYPE;
  v_cursor               NUMBER;
  v_create_string        VARCHAR2(3000);
  v_numrows              NUMBER;

  CURSOR cur_object IS
    SELECT select_id
         , select_name
         , from_table
         , where_clause
      FROM jtf_objects_vl a
         , jtf_object_usages b
     WHERE a.object_code = p_note_context_type
       AND a.object_code = b.object_code
       AND b.object_user_code = 'NOTES';
BEGIN
  OPEN cur_object;

  FETCH cur_object
   INTO l_select_id, l_select_name, l_tablename, l_where_clause;

  CLOSE cur_object;

  v_cursor := DBMS_SQL.open_cursor;

  IF l_where_clause IS NOT NULL THEN
    v_create_string :=
         'SELECT '
      || l_select_name
      || '  FROM '
      || l_tablename
      || ' WHERE  '
      || l_select_id
      || ' = :note_context_type_id'
      || ' AND  '
      || l_where_clause;
  ELSE
    v_create_string :=
         'SELECT '
      || l_select_name
      || '  FROM '
      || l_tablename
      || ' WHERE  '
      || l_select_id
      || ' = :note_context_type_id';
  END IF;

  DBMS_SQL.parse(v_cursor, v_create_string, DBMS_SQL.v7);

  DBMS_SQL.bind_variable(v_cursor, 'note_context_type_id', p_note_context_type_id);
  DBMS_SQL.define_column(v_cursor, 1, l_note_context_value, 80);

  v_numrows := DBMS_SQL.EXECUTE(v_cursor);
  v_numrows := DBMS_SQL.fetch_rows(v_cursor);

  DBMS_SQL.column_value(v_cursor, 1, l_note_context_value);
  DBMS_SQL.close_cursor(v_cursor);

  RETURN l_note_context_value;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_note_context_value;

procedure LOAD_ROW (
  X_OWNER in  VARCHAR2,
  X_JTF_NOTE_ID in NUMBER,
  X_SOURCE_OBJECT_CODE in VARCHAR2,
  X_SOURCE_OBJECT_ID in NUMBER,
  X_SOURCE_NUMBER in VARCHAR2,
  X_NOTE_STATUS in VARCHAR2,
  X_NOTE_TYPE_MEANING in VARCHAR2,
  X_NOTE_TYPE in VARCHAR2,
  X_CONTEXT in VARCHAR2,
  X_PARENT_NOTE_ID in NUMBER,
  X_SOURCE_OBJECT_MEANING in VARCHAR2,
  X_NOTES in VARCHAR2,
  X_NOTES_DETAIL in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2

) IS
begin
declare
	user_id			NUMBER := 0;
	row_id			VARCHAR2(64);
	l_api_version		NUMBER := 1.0;
	l_return_status		VARCHAR2(1);
	l_msg_count		NUMBER;
	l_msg_data		VARCHAR2(100);
	l_init_msg_list		VARCHAR2(1) := 'F';
	l_commit		VARCHAR2(1) := 'F';
	l_validation_level 	NUMBER := 100;
  	l_jtf_note_id 		NUMBER;
  	l_source_object_code    VARCHAR2(240);
	l_source_object_id	NUMBER;
	l_source_number	        VARCHAR2(4000);
  	l_note_status		VARCHAR2(1);
	l_note_type_meaning	VARCHAR2(80);
  	l_object_version_number NUMBER;
	l_note_type             VARCHAR2(30);
 	l_context		VARCHAR2(240);
	l_parent_note_id	NUMBER;
	l_source_object_meaning VARCHAR2(30);
	l_notes			VARCHAR2(4000);
	l_notes_detail		VARCHAR2(32000);
  	l_last_update_date	DATE;
	l_last_updated_by	NUMBER;
	l_last_update_login	NUMBER;
	l_creation_date		DATE;
	l_created_by		NUMBER;
    l_entered_by        NUMBER;
begin
	if (x_owner = 'SEED') then
		user_id := -1;
	end if;
  	l_jtf_note_id:= X_JTF_NOTE_ID;
  	l_object_version_number := 1;
	l_source_object_id	    :=X_SOURCE_OBJECT_ID;
  	l_source_object_code    :=X_SOURCE_OBJECT_CODE;
	--l_source_number	        :=X_SOURCE_NUMBER;
  	l_note_status		:=X_NOTE_STATUS;
	--l_note_type_meaning     :=X_NOTE_TYPE_MEANING;
  	l_object_version_number := 1;
	l_note_type             :=X_NOTE_TYPE;
 	l_context		:=X_CONTEXT;
	l_parent_note_id	:=X_PARENT_NOTE_ID;
	--l_source_object_meaning :=X_SOURCE_OBJECT_MEANING;
	l_notes			:=X_NOTES;
    l_notes_detail:= NULL;
  	l_last_update_date 	:= sysdate;
	l_last_updated_by 	:= user_id;
	l_last_update_login 	:= 0;
    l_entered_by:= user_id;
       UPDATE_ROW (
  			X_JTF_NOTE_ID =>l_jtf_note_id,
 			X_SOURCE_OBJECT_CODE=>l_source_object_code,
  			X_NOTE_STATUS =>l_note_status,
  			X_ENTERED_BY  =>l_entered_by,
  			X_ENTERED_DATE => sysdate,
  			X_NOTE_TYPE =>l_note_type,
            X_ATTRIBUTE1 => null,
            X_ATTRIBUTE2=> null,
            X_ATTRIBUTE3 => null,
            X_ATTRIBUTE4 => null,
            X_ATTRIBUTE5 => null,
            X_ATTRIBUTE6 => null,
            X_ATTRIBUTE7 => null,
            X_ATTRIBUTE8 => null,
            X_ATTRIBUTE9 => null,
            X_ATTRIBUTE10 => null,
            X_ATTRIBUTE11 => null,
            X_ATTRIBUTE12 => null,
            X_ATTRIBUTE13 => null,
            X_ATTRIBUTE14 => null,
            X_ATTRIBUTE15 => null,
  			X_CONTEXT =>l_context,
  			X_PARENT_NOTE_ID =>l_parent_note_id,
  			X_SOURCE_OBJECT_ID =>l_source_object_id,
  			X_NOTES => l_notes,
  			X_NOTES_DETAIL => l_notes_detail,
  			X_LAST_UPDATE_DATE =>l_last_update_date,
  			X_LAST_UPDATED_BY =>l_last_updated_by,
  			X_LAST_UPDATE_LOGIN =>l_last_update_login
			);

	EXCEPTION
		when no_data_found then
			l_creation_date := sysdate;
			l_created_by := user_id;

            INSERT_ROW (
            X_ROWID => row_id,
            X_JTF_NOTE_ID =>l_jtf_note_id ,
            X_SOURCE_OBJECT_CODE =>l_source_object_code,
            X_NOTE_STATUS =>l_note_status,
            X_ENTERED_BY =>l_entered_by,
            X_ENTERED_DATE => sysdate,
            X_NOTE_TYPE =>l_note_type,
            X_ATTRIBUTE1 => null,
            X_ATTRIBUTE2 => null,
            X_ATTRIBUTE3 => null,
            X_ATTRIBUTE4 => null,
            X_ATTRIBUTE5 => null,
            X_ATTRIBUTE6 => null,
            X_ATTRIBUTE7 => null,
            X_ATTRIBUTE8 => null,
            X_ATTRIBUTE9 => null,
            X_ATTRIBUTE10 => null,
            X_ATTRIBUTE11 => null,
            X_ATTRIBUTE12 => null,
            X_ATTRIBUTE13 => null,
            X_ATTRIBUTE14 => null,
            X_ATTRIBUTE15 => null,
            X_CONTEXT  => l_context,
            X_PARENT_NOTE_ID => l_parent_note_id,
            X_SOURCE_OBJECT_ID => l_source_object_id,
            X_NOTES => l_notes,
            X_NOTES_DETAIL => l_notes_detail,
            X_CREATION_DATE => l_creation_date,
            X_CREATED_BY => l_created_by,
            X_LAST_UPDATE_DATE =>sysdate,
            X_LAST_UPDATED_BY => l_last_updated_by,
            X_LAST_UPDATE_LOGIN =>l_last_update_login);

	end;
end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_JTF_NOTE_ID in NUMBER,
  X_NOTES in VARCHAR2,
  X_NOTES_DETAIL in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2
) IS

begin
	UPDATE jtf_notes_tl SET
		notes=X_NOTES,
		notes_detail = X_NOTES_DETAIL,
		last_update_date = sysdate,
		last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
		last_update_login = 0,
		source_lang = userenv('LANG')
	WHERE userenv('LANG') in (LANGUAGE, SOURCE_LANG) AND
		jtf_note_id = X_JTF_NOTE_ID;
end TRANSLATE_ROW;



end JTF_NOTES_PKG;

/
