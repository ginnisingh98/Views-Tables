--------------------------------------------------------
--  DDL for Package Body CN_DIMENSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_DIMENSIONS_PKG" as
-- $Header: cndidimb.pls 120.7 2006/01/13 03:58:07 hanaraya noship $


  -- Procedure Name
  --   insert_row
  -- History
  --   12/28/93		Paul Mitchell		Created

  procedure INSERT_ROW (
  X_DIMENSION_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_SOURCE_TABLE_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  --R12 MOAC Changes--Start
  X_ORG_ID	in NUMBER
--R12 MOAC Changes--End
) is
begin
  insert into CN_DIMENSIONS_ALL_B (
    DIMENSION_ID,
    DESCRIPTION,
    SOURCE_TABLE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    --R12 MOAC Changes--Start
    ORG_ID
     --R12 MOAC Changes--End
  ) values (
    X_DIMENSION_ID,
    X_DESCRIPTION,
    X_SOURCE_TABLE_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
     --R12 MOAC Changes--Start
    X_ORG_ID
     --R12 MOAC Changes--End
  );

  insert into CN_DIMENSIONS_ALL_TL (
    DIMENSION_ID,
    NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
     --R12 MOAC Changes--Start
    ORG_ID,
     --R12 MOAC Changes--End
    LANGUAGE,

    SOURCE_LANG

  ) select
    X_DIMENSION_ID,
    X_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    --R12 MOAC Changes--Start
    X_ORG_ID,
    --R12 MOAC Changes--End
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CN_DIMENSIONS_ALL_TL T
    where T.DIMENSION_ID = X_DIMENSION_ID
     and T.LANGUAGE = L.language_code AND
     ORG_ID = X_ORG_ID
     );



end INSERT_ROW;


  -- Procedure Name
  --   update_row
  -- Purpose
  --   Update a row in cn_dimensions.
  -- History
  --   12/28/93		Paul Mitchell		Created

procedure UPDATE_ROW (
  X_DIMENSION_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_SOURCE_TABLE_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  --R12 MOAC Changes--Start
  X_ORG_ID	in NUMBER,
--R12 MOAC Changes--End
  X_OBJECT_VERSION_NUMBER in out NOCOPY  CN_DIMENSIONS.OBJECT_VERSION_NUMBER%TYPE
) is
begin

X_OBJECT_VERSION_NUMBER := X_OBJECT_VERSION_NUMBER + 1;

  update CN_DIMENSIONS_ALL_B set
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
  where DIMENSION_ID = x_dimension_id AND
  --R12 MOAC Changes--Start
   ORG_ID = X_ORG_ID;
--R12 MOAC Changes--End



  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CN_DIMENSIONS_ALL_TL set
    NAME = X_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DIMENSION_ID = x_dimension_id
  --R12 MOAC Changes--Start
   and ORG_ID = X_ORG_ID
--R12 MOAC Changes--End
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);


  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;



  -- Procedure Name
  --   delete_row
  -- Purpose
  --   Delete a row from cn_dimensions.
  -- History
  --   12/28/93		Paul Mitchell		Created
--  PROCEDURE delete_row(
--	X_rowid		 varchar2) IS

procedure DELETE_ROW (
  X_DIMENSION_ID in NUMBER,
  --R12 MOAC Changes--Start
  X_ORG_ID	in NUMBER
--R12 MOAC Changes--End
) is
   l_env_org_id number;
   l_table_id   number;
begin
   -- get environment org ID
   select X_ORG_ID
     into l_env_org_id from dual;

   -- clean up cn_objects and remove pointers to non-existent dimension ID
   select source_table_id into l_table_id
     from cn_dimensions where dimension_id = X_DIMENSION_ID
     --R12 MOAC Changes--Start
     and org_id = X_ORG_ID;
     --R12 MOAC Changes--End

   update cn_objects set dimension_id = null,
          primary_key = null, user_column_name = null
    where table_id = l_table_id
    --R12 MOAC Changes--Start
     and org_id = X_ORG_ID;
     --R12 MOAC Changes--End

   -- remove dangling head hierarchies, dim hierarchies and tree fragments
   delete from cn_hierarchy_nodes e where dim_hierarchy_id in
     (select d.dim_hierarchy_id
        from cn_dim_hierarchies d, cn_head_hierarchies h
       where h.dimension_id = X_DIMENSION_ID
       --R12 MOAC Changes--Start
     and h.org_id = X_ORG_ID
     and h.org_id = d.org_id
     --R12 MOAC Changes--End
         and d.header_dim_hierarchy_id = h.head_hierarchy_id);
   delete from cn_hierarchy_edges e where dim_hierarchy_id in
     (select d.dim_hierarchy_id
        from cn_dim_hierarchies d, cn_head_hierarchies h
       where h.dimension_id = X_DIMENSION_ID
       --R12 MOAC Changes--Start
     and h.org_id = X_ORG_ID
     and h.org_id = d.org_id
     --R12 MOAC Changes--End
         and d.header_dim_hierarchy_id = h.head_hierarchy_id);
   delete from cn_dim_hierarchies d where header_dim_hierarchy_id in
     (select head_hierarchy_id from cn_head_hierarchies
       where dimension_id = X_DIMENSION_ID
       --R12 MOAC Changes--Start
     and  org_id = X_ORG_ID);
     --R12 MOAC Changes--End

   -- delete from cn_head_hierarchies and dimensions - handle MLS delete
   delete from CN_HEAD_HIERARCHIES_ALL_TL
    where dimension_id = X_DIMENSION_ID
      and ORG_ID = X_ORG_ID;

   delete from CN_HEAD_HIERARCHIES_ALL_B
    where dimension_id = X_DIMENSION_ID
      and ORG_ID = X_ORG_ID;

   delete from CN_DIMENSIONS_ALL_TL
    where dimension_id = X_DIMENSION_ID
      and ORG_ID = X_ORG_ID;

   delete from CN_DIMENSIONS_ALL_B
    where dimension_id = X_DIMENSION_ID
      and ORG_ID = X_ORG_ID;

   if (sql%notfound) then
      fnd_message.set_name('CN', 'CN_RECORD_DELETED');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_error;
   end if;

end DELETE_ROW;




procedure ADD_LANGUAGE
is
begin
  delete from CN_DIMENSIONS_ALL_TL T
  where not exists
    (select NULL
    from CN_DIMENSIONS_ALL_B B
    where B.DIMENSION_ID = T.dimension_id
    and   B.ORG_ID = T.ORG_ID
    );

  update CN_DIMENSIONS_ALL_TL T set (
      NAME
    ) = (select
      B.NAME
    from CN_DIMENSIONS_ALL_TL B
    where B.DIMENSION_ID = T.DIMENSION_ID
    and B.LANGUAGE = T.source_lang
    and   B.ORG_ID = T.ORG_ID
	 )
  where (
      T.DIMENSION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DIMENSION_ID,
      SUBT.LANGUAGE
    from CN_DIMENSIONS_ALL_TL SUBB, CN_DIMENSIONS_ALL_TL SUBT
    where SUBB.DIMENSION_ID = SUBT.DIMENSION_ID
    and SUBB.LANGUAGE = SUBT.source_lang
    and   SUBB.ORG_ID = SUBT.ORG_ID
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
	 ));

  insert into CN_DIMENSIONS_ALL_TL (
    ORG_ID,
    DIMENSION_ID,
    NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ORG_ID,
    B.DIMENSION_ID,
    B.NAME,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CN_DIMENSIONS_ALL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CN_DIMENSIONS_ALL_TL T
    where T.DIMENSION_ID = B.DIMENSION_ID
    and T.LANGUAGE = L.language_code
    and   T.ORG_ID = B.ORG_ID
    );

end ADD_LANGUAGE;

-- --------------------------------------------------------------------+
-- Procedure : LOAD_ROW
-- Description : Called by FNDLOAD to upload seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+
PROCEDURE LOAD_ROW
  ( x_dimension_id IN NUMBER,
    x_org_id in NUMBER, -- R12 change
    x_description IN VARCHAR2,
    x_source_table_id IN NUMBER,
    x_name IN VARCHAR2,
    x_owner IN VARCHAR2) IS
       user_id NUMBER;

BEGIN
   -- Validate input data
   IF (x_dimension_id IS NULL) OR (x_source_table_id IS NULL)
     OR (x_name IS NULL) THEN
      GOTO end_load_row;
   END IF;

   IF (x_owner IS NOT NULL) AND (x_owner = 'SEED') THEN
      user_id := 1;
    ELSE
      user_id := 0;
   END IF;
   -- Load The record to _B table
   UPDATE  cn_dimensions_all_b SET
     description = x_description,
     source_table_id = x_source_table_id,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0
     WHERE dimension_id = x_dimension_id
     AND org_id = x_org_id; --R12 change

   IF (SQL%NOTFOUND) THEN
      -- Insert new record to _B table
      INSERT INTO cn_dimensions_all_b
	(dimension_id,
     org_id, -- R12 change
	 description,
	 source_table_id,
	 creation_date,
	 created_by,
	 last_update_date,
	 last_updated_by,
	 last_update_login
	 ) VALUES
	(x_dimension_id,
	 x_org_id, -- R12 change
	 x_description,
	 x_source_table_id,
	 sysdate,
	 user_id,
	 sysdate,
	 user_id,
	 0
	 );
   END IF;
   -- Load The record to _TL table
   UPDATE cn_dimensions_all_tl SET
     name = x_name,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0,
     source_lang = userenv('LANG')
     WHERE dimension_id = x_dimension_id
     AND org_id = x_org_id --R12 change
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

   IF (SQL%NOTFOUND) THEN
      -- Insert new record to _TL table
      INSERT INTO cn_dimensions_all_tl
	(dimension_id,
	 org_id, -- R12 change
	 name,
	 creation_date,
	 created_by,
	 last_update_date,
	 last_updated_by,
	 last_update_login,
	 language,
	 source_lang)
	SELECT
	x_dimension_id,
	x_org_id, -- R12 change
	x_name,
	sysdate,
	user_id,
	sysdate,
	user_id,
	0,
	l.language_code,
	userenv('LANG')
	FROM fnd_languages l
	WHERE l.installed_flag IN ('I', 'B')
	AND NOT EXISTS
	(SELECT NULL
	 FROM cn_dimensions_all_tl t
	 WHERE t.dimension_id = x_dimension_id
	 AND t.org_id = x_org_id --R12 change
	 AND t.language = l.language_code);
   END IF;
   << end_load_row >>
     NULL;
END LOAD_ROW ;

-- --------------------------------------------------------------------+
-- Procedure : TRANSLATE_ROW
-- Description : Called by FNDLOAD to translate seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+
PROCEDURE TRANSLATE_ROW
  ( x_dimension_id IN NUMBER,
    x_name IN VARCHAR2,
    x_owner IN VARCHAR2) IS
       user_id NUMBER;
BEGIN
    -- Validate input data
   IF (x_dimension_id IS NULL) OR (x_name IS NULL) THEN
      GOTO end_translate_row;
   END IF;

   IF (x_owner IS NOT NULL) AND (x_owner = 'SEED') THEN
      user_id := 1;
    ELSE
      user_id := 0;
   END IF;
   -- Update the translation
   UPDATE cn_dimensions_all_tl SET
     name = x_name,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0,
     source_lang = userenv('LANG')
     WHERE dimension_id = x_dimension_id
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

   << end_translate_row >>
     NULL;
END TRANSLATE_ROW ;

  FUNCTION New_Dimension RETURN NUMBER IS
      Ret_Val NUMBER(15);
    BEGIN

      SELECT cn_dimensions_s.nextval INTO Ret_Val FROM dual;

      RETURN Ret_Val;

    END New_Dimension;



END CN_DIMENSIONS_PKG;

/
