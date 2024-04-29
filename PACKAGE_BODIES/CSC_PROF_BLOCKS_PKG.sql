--------------------------------------------------------
--  DDL for Package Body CSC_PROF_BLOCKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PROF_BLOCKS_PKG" as
/* $Header: csctpvab.pls 120.4 2005/09/18 23:15:07 vshastry ship $ */
-- Start of Comments
-- Package name     : CSC_PROF_BLOCKS_PKG
-- Purpose          :
-- History          :
--	03 Nov 00 axsubram  Added  Translate_row,load_row (# 1487860)
--	03 Nov 00	axsubram	File name constant corrected to csctpvab.pls
--     6 Nov 2002 jamose  1159 Upgrade changes for table handlers
--                        Added seed condition and CSC_CORE_UTILS dependency removed
-- 18 Nov 02   jamose made changes for the NOCOPY and FND_API.G_MISS*
-- 19-07-2005 tpalaniv Modified the translate_row and load_row APIs to fetch last_updated_by using FND API
-- 19-09-2005 vshastry Bug 4596220. Added condition in insert row
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_PROF_BLOCKS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csctpvab.pls';

-- jamose
G_MISS_CHAR VARCHAR2(1) := FND_API.G_MISS_CHAR;
G_MISS_NUM NUMBER := FND_API.G_MISS_NUM;
G_MISS_DATE DATE := FND_API.G_MISS_DATE;

PROCEDURE Insert_Row(
          px_BLOCK_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    	 NUMBER,
          p_CREATION_DATE    	 DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE   DATE,
          p_LAST_UPDATE_LOGIN  NUMBER,
          p_BLOCK_NAME      VARCHAR2,
          p_DESCRIPTION     VARCHAR2,
          p_START_DATE_ACTIVE  DATE,
          p_END_DATE_ACTIVE DATE,
          p_SEEDED_FLAG     VARCHAR2,
          p_BLOCK_NAME_CODE VARCHAR2,
          p_OBJECT_CODE 	    VARCHAR2,
          p_SQL_STMNT_FOR_DRILLDOWN    VARCHAR2,
          p_SQL_STMNT       VARCHAR2,
          p_BATCH_SQL_STMNT VARCHAR2,
          p_SELECT_CLAUSE   VARCHAR2,
          p_CURRENCY_CODE   VARCHAR2,
          p_FROM_CLAUSE     VARCHAR2,
          p_WHERE_CLAUSE    VARCHAR2,
          p_OTHER_CLAUSE    VARCHAR2,
          p_BLOCK_LEVEL     VARCHAR2,
          x_OBJECT_VERSION_NUMBER OUT NOCOPY NUMBER,
          p_APPLICATION_ID  NUMBER)
 IS
 Cursor new_seq_csr IS  Select csc_prof_blocks_s.nextval
				from dual;

 l_object_version_number NUMBER := 1;
 ps_seeded_flag  Varchar2(3);
BEGIN

   /* added the below 2 lines for bug 4596220 */
   ps_seeded_flag := p_seeded_flag;
   IF NVL(p_seeded_flag, 'N') <> 'Y' THEN
      /* Added This If Condition for Bug 1944040*/
      If (p_Created_by=1) then
           ps_seeded_flag:='Y';
      Else
           ps_seeded_flag:='N';
      End If;
   END IF;

    If (px_BLOCK_ID IS NULL) OR (px_BLOCK_ID = G_MISS_NUM) then
 	Open new_seq_csr;
 	Fetch new_seq_csr into px_block_id;
 	Close new_seq_csr;
    End If;
  -- to_date(NULL) added to include timestamp during creation
  INSERT INTO CSC_PROF_BLOCKS_B(
           BLOCK_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
	   -- BLOCK_NAME,
           -- DESCRIPTION,
           START_DATE_ACTIVE,
           END_DATE_ACTIVE,
           SEEDED_FLAG,
           BLOCK_NAME_CODE,
	   OBJECT_CODE,
           SQL_STMNT_FOR_DRILLDOWN,
           SQL_STMNT,
	   BATCH_SQL_STMNT,
           SELECT_CLAUSE,
           CURRENCY_CODE,
           FROM_CLAUSE,
           WHERE_CLAUSE,
           OTHER_CLAUSE,
           BLOCK_LEVEL,
  	   OBJECT_VERSION_NUMBER,
           APPLICATION_ID)
    VALUES (
           px_BLOCK_ID,
           decode( p_CREATED_BY, G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, G_MISS_DATE, to_date(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE,G_MISS_DATE,to_date(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN,G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           -- decode( p_BLOCK_NAME, CSC_CORE_UTILS_PVT.G_MISS_CHAR, NULL, p_BLOCK_NAME),
           -- decode( p_DESCRIPTION, CSC_CORE_UTILS_PVT.G_MISS_CHAR, NULL, p_DESCRIPTION),
           decode( p_START_DATE_ACTIVE, G_MISS_DATE,to_date(NULL), p_START_DATE_ACTIVE),
           decode( p_END_DATE_ACTIVE, G_MISS_DATE,to_date(NULL), p_END_DATE_ACTIVE),
           decode( p_SEEDED_FLAG, G_MISS_CHAR, NULL, ps_SEEDED_FLAG),
           decode( p_BLOCK_NAME_CODE, G_MISS_CHAR, NULL, p_BLOCK_NAME_CODE),
           decode( p_OBJECT_CODE, G_MISS_CHAR, NULL, p_OBJECT_CODE),
           decode( p_SQL_STMNT_FOR_DRILLDOWN, G_MISS_CHAR, NULL, p_SQL_STMNT_FOR_DRILLDOWN),
           decode( p_SQL_STMNT, G_MISS_CHAR, NULL, p_SQL_STMNT),
	   decode( p_BATCH_SQL_STMNT, G_MISS_CHAR, NULL, p_BATCH_SQL_STMNT),
           decode( p_SELECT_CLAUSE, G_MISS_CHAR, NULL, p_SELECT_CLAUSE),
           decode( p_CURRENCY_CODE, G_MISS_CHAR, NULL, p_CURRENCY_CODE),
           decode( p_FROM_CLAUSE, G_MISS_CHAR, NULL, p_FROM_CLAUSE),
           decode( p_WHERE_CLAUSE, G_MISS_CHAR, NULL, p_WHERE_CLAUSE),
           decode( p_OTHER_CLAUSE, G_MISS_CHAR, NULL, p_Other_CLAUSE),
           decode( p_BLOCK_LEVEL, G_MISS_CHAR, NULL, p_BLOCK_LEVEL),
  	   l_object_version_number,
         decode( p_application_id, G_MISS_NUM, NULL, p_application_id)
 );

  -- assigning the out parameters
  x_object_version_number := l_object_version_number;

  INSERT INTO CSC_PROF_BLOCKS_TL (
    	   BLOCK_ID,
           BLOCK_NAME,
           DESCRIPTION,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           LANGUAGE,
           SOURCE_LANG )
    SELECT
           px_BLOCK_ID,
           decode( p_BLOCK_NAME, G_MISS_CHAR, NULL, p_BLOCK_NAME),
           decode( p_DESCRIPTION,G_MISS_CHAR, NULL, p_DESCRIPTION),
           p_CREATED_BY,
           p_CREATION_DATE,
           p_LAST_UPDATED_BY,
           p_LAST_UPDATE_DATE,
           p_LAST_UPDATE_LOGIN,
           L.LANGUAGE_CODE,
           userenv('LANG')
    FROM  FND_LANGUAGES L
    WHERE L.INSTALLED_FLAG in ('I', 'B')
    AND not exists
    (SELECT NULL
     FROM CSC_PROF_BLOCKS_TL T
     WHERE T.BLOCK_ID = PX_BLOCK_ID
     AND T.LANGUAGE = L.LANGUAGE_CODE);

End Insert_Row;

PROCEDURE Update_Row(
          p_BLOCK_ID    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_BLOCK_NAME    VARCHAR2,
          p_DESCRIPTION    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE,
          p_SEEDED_FLAG    VARCHAR2,
          p_BLOCK_NAME_CODE    VARCHAR2,
          p_OBJECT_CODE VARCHAR2,
          p_SQL_STMNT_FOR_DRILLDOWN    VARCHAR2,
          p_SQL_STMNT    VARCHAR2,
          p_BATCH_SQL_STMNT  VARCHAR2,
          p_SELECT_CLAUSE    VARCHAR2,
          p_CURRENCY_CODE    VARCHAR2,
          p_FROM_CLAUSE    VARCHAR2,
          p_WHERE_CLAUSE    VARCHAR2,
          p_OTHER_CLAUSE    VARCHAR2,
          p_BLOCK_LEVEL     VARCHAR2,
	  px_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER,
          p_APPLICATION_ID  NUMBER)
 IS
BEGIN
 /* Though we do not have any default null, for update case we need to preserve the
    the old values so an nvl has been used. By doing this we can avoid an excess null
    checking on the private api which are not really required for validation and no
    impact even if the api is called from not through priviate api -jamose

   */
  UPDATE CSC_PROF_BLOCKS_B
    SET
              LAST_UPDATED_BY = p_LAST_UPDATED_BY,
              LAST_UPDATE_DATE = p_LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN,
              -- BLOCK_NAME = decode( p_BLOCK_NAME, G_MISS_CHAR, BLOCK_NAME, p_BLOCK_NAME),
              -- DESCRIPTION = decode( p_DESCRIPTION, G_MISS_CHAR, DESCRIPTION, p_DESCRIPTION),
              START_DATE_ACTIVE = p_START_DATE_ACTIVE,
              END_DATE_ACTIVE = p_END_DATE_ACTIVE,
              SEEDED_FLAG = p_SEEDED_FLAG,
              BLOCK_NAME_CODE = p_BLOCK_NAME_CODE,
              OBJECT_CODE = p_OBJECT_CODE,
              SQL_STMNT_FOR_DRILLDOWN = p_SQL_STMNT_FOR_DRILLDOWN,
              SQL_STMNT = p_SQL_STMNT,
	      BATCH_SQL_STMNT = p_BATCH_SQL_STMNT,
              SELECT_CLAUSE = p_SELECT_CLAUSE,
              CURRENCY_CODE = p_CURRENCY_CODE,
              FROM_CLAUSE = p_FROM_CLAUSE,
              WHERE_CLAUSE = p_WHERE_CLAUSE,
              OTHER_CLAUSE =p_OTHER_CLAUSE,
              BLOCK_LEVEL = p_BLOCK_LEVEL,
  	          OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
              APPLICATION_ID = p_application_id
    where BLOCK_ID = p_BLOCK_ID
    RETURNING OBJECT_VERSION_NUMBER INTO px_OBJECT_VERSION_NUMBER;
    UPDATE CSC_PROF_BLOCKS_TL
    SET 	  BLOCK_NAME   = p_BLOCK_NAME,
		      DESCRIPTION  = p_DESCRIPTION,
    		  LAST_UPDATE_DATE  = p_LAST_UPDATE_DATE,
    		  LAST_UPDATED_BY   = p_LAST_UPDATED_BY,
    		  LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN,
    		  SOURCE_LANG  = userenv('LANG')
    WHERE BLOCK_ID = P_BLOCK_ID
    AND userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    if (sql%rowcount = 0) then
		raise no_Data_found;
	end if;

END Update_Row;

procedure LOCK_ROW (
  P_BLOCK_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select 'X'
    from CSC_PROF_BLOCKS_B
    where BLOCK_ID = P_BLOCK_ID
    and object_version_number = P_object_version_number
    for update of BLOCK_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      BLOCK_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CSC_PROF_BLOCKS_TL
    where BLOCK_ID = P_BLOCK_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of BLOCK_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  close c;
  return;
end LOCK_ROW;

procedure DELETE_ROW (
  P_BLOCK_ID  			 NUMBER,
  P_OBJECT_VERSION_NUMBER NUMBER
) is
begin
  delete from CSC_PROF_BLOCKS_TL
  where BLOCK_ID = P_BLOCK_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CSC_PROF_BLOCKS_B
  where BLOCK_ID = P_BLOCK_ID
  and OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CSC_PROF_BLOCKS_TL T
  where not exists
    (select NULL
    from CSC_PROF_BLOCKS_B B
    where B.BLOCK_ID = T.BLOCK_ID
    );

  update CSC_PROF_BLOCKS_TL T set (
      BLOCK_NAME,
      DESCRIPTION
    ) = (select
      B.BLOCK_NAME,
      B.DESCRIPTION
    from CSC_PROF_BLOCKS_TL B
    where B.BLOCK_ID = T.BLOCK_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.BLOCK_ID,
      T.LANGUAGE
  ) in (select
      SUBT.BLOCK_ID,
      SUBT.LANGUAGE
    from CSC_PROF_BLOCKS_TL SUBB, CSC_PROF_BLOCKS_TL SUBT
    where SUBB.BLOCK_ID = SUBT.BLOCK_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.BLOCK_NAME <> SUBT.BLOCK_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into CSC_PROF_BLOCKS_TL (
    BLOCK_ID,
    BLOCK_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.BLOCK_ID,
    B.BLOCK_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CSC_PROF_BLOCKS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CSC_PROF_BLOCKS_TL T
    where T.BLOCK_ID = B.BLOCK_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE Translate_Row(
		p_block_id	NUMBER,
		p_block_name	VARCHAR2,
		p_description	VARCHAR2,
		p_owner		VARCHAR2)
IS
Begin
   Update Csc_Prof_Blocks_TL set
      block_name        = nvl(p_block_name,block_name),
      description       = nvl(p_description,description),
      last_update_date  = sysdate,
      last_updated_by   = fnd_load_util.owner_id(p_owner),
      last_update_login = 0,
      source_lang       = userenv('LANG')
   Where block_id    = p_block_id
     and userenv('LANG') in (language, source_lang);

End Translate_Row;

PROCEDURE Load_Row(
          p_BLOCK_ID    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_BLOCK_NAME    VARCHAR2,
          p_DESCRIPTION    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE,
          p_SEEDED_FLAG    VARCHAR2,
          p_BLOCK_NAME_CODE    VARCHAR2,
          p_OBJECT_CODE VARCHAR2,
          p_SQL_STMNT_FOR_DRILLDOWN    VARCHAR2,
          p_SQL_STMNT    VARCHAR2,
	  p_BATCH_SQL_STMNT  VARCHAR2,
          p_SELECT_CLAUSE    VARCHAR2,
          p_CURRENCY_CODE    VARCHAR2,
          p_FROM_CLAUSE    VARCHAR2,
          p_WHERE_CLAUSE    VARCHAR2,
          p_OTHER_CLAUSE    VARCHAR2,
          p_BLOCK_LEVEL     VARCHAR2,
          px_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER,
          p_APPLICATION_ID NUMBER,
          p_owner          VARCHAR2)
IS

   l_user_id 	number := 0;
   l_block_id	number := G_MISS_NUM;
   l_object_version_number	number := 0;

		/** This is mainly for loading seed data . That is the
		reason, that l_check_id is being declared here, The check_id
		returned from insert_row is not used.

		2. Object_version_number is not passed . It is assumed that
			seed data would be run when other users are not using
			the system
		**/
BEGIN

   /* commented for R12 ATG Project
      if (p_owner = 'SEED') then
         l_user_id := 1;
      end if;
   */

   l_block_id := p_block_id ;

   Csc_Prof_Blocks_Pkg.Update_Row(
           	p_BLOCK_ID                 => p_block_id,
           	p_LAST_UPDATED_BY          => p_last_updated_by,
           	p_LAST_UPDATE_DATE         => p_last_update_date,
           	p_LAST_UPDATE_LOGIN        => 0,
           	p_BLOCK_NAME               => p_block_name,
           	p_DESCRIPTION              => p_description,
           	p_START_DATE_ACTIVE        => to_date(p_start_date_active,'YYYY/MM/DD'),
           	p_END_DATE_ACTIVE          => to_date(p_end_date_active,'YYYY/MM/DD'),
           	p_SEEDED_FLAG              => p_seeded_flag,
           	p_BLOCK_NAME_CODE          => p_block_name_code,
           	p_OBJECT_CODE              => p_object_code,
           	p_SQL_STMNT_FOR_DRILLDOWN  => p_sql_stmnt_for_drilldown,
           	p_SQL_STMNT                => p_sql_stmnt,
		p_BATCH_SQL_STMNT          => p_batch_sql_stmnt,
           	p_SELECT_CLAUSE            => p_select_clause,
           	p_CURRENCY_CODE            => p_currency_code,
           	p_FROM_CLAUSE              => p_from_clause,
           	p_WHERE_CLAUSE             => p_where_clause,
           	p_OTHER_CLAUSE             => p_other_clause,
                p_BLOCK_LEVEL              => p_block_level,
 	  	px_OBJECT_VERSION_NUMBER   => l_object_version_number,
                p_APPLICATION_ID           => p_application_id);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      Csc_Prof_Blocks_Pkg.Insert_Row(
                    px_BLOCK_ID           => l_block_id,
                    p_CREATED_BY          => p_last_updated_by,
                    p_CREATION_DATE    	  => p_last_update_date,
                    p_LAST_UPDATED_BY     => p_last_updated_by,
                    p_LAST_UPDATE_DATE    => p_last_update_date,
                    p_LAST_UPDATE_LOGIN   => 0,
                    p_BLOCK_NAME          => p_block_name,
                    p_DESCRIPTION         => p_description,
                    p_START_DATE_ACTIVE   => to_date(p_start_date_active,'YYYY/MM/DD'),
                    p_END_DATE_ACTIVE     => to_date(p_end_date_active,'YYYY/MM/DD'),
                    p_SEEDED_FLAG         => p_seeded_flag,
                    p_BLOCK_NAME_CODE     => p_block_name_code,
                    p_OBJECT_CODE         => p_object_code,
                    p_SQL_STMNT_FOR_DRILLDOWN => p_sql_stmnt_for_drilldown,
                    p_SQL_STMNT           => p_sql_stmnt,
		    p_BATCH_SQL_STMNT     => p_batch_sql_stmnt,
                    p_SELECT_CLAUSE       => p_select_clause,
                    p_CURRENCY_CODE       => p_currency_code,
                    p_FROM_CLAUSE         => p_from_clause,
                    p_WHERE_CLAUSE        => p_where_clause,
                    p_OTHER_CLAUSE        => p_other_clause,
                    p_BLOCK_LEVEL         => p_block_level,
                    x_OBJECT_VERSION_NUMBER   => l_object_version_number,
                    p_APPLICATION_ID          =>p_application_id);

END Load_Row;

End CSC_PROF_BLOCKS_PKG;

/
