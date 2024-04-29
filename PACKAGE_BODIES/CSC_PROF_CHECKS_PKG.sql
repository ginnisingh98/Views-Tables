--------------------------------------------------------
--  DDL for Package Body CSC_PROF_CHECKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PROF_CHECKS_PKG" as
/* $Header: csctpckb.pls 120.3 2005/09/18 23:14:52 vshastry ship $ */
-- Start of Comments
-- Package name     : CSC_PROF_CHECKS_PKG
-- Purpose          :
-- History          :
--	03 Nov 00   axsubram  Added  Translate_row,load_row (# 1487864)
--	03 Nov 00	axsubram	File name constant corrected to csctpckb.pls
-- 07 Nov 02   jamose Upgrade table handler changes
-- 25 Nov 02   jamose Fnd_Api_G_MISS* changes to improve the performance
-- 19-07-2005 tpalaniv Modified the translate_row and load_row APIs to fetch last_updated_by using FND API
-- 19-09-2005 vshastry Bug 4596220. Added condition in insert row
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30)  := 'CSC_PROF_CHECKS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csctpckb.pls';

G_MISS_CHAR VARCHAR2(1) := FND_API.G_MISS_CHAR;
G_MISS_NUM NUMBER := FND_API.G_MISS_NUM;
G_MISS_DATE DATE := FND_API.G_MISS_DATE;

PROCEDURE Insert_Row(
          px_CHECK_ID   IN OUT NOCOPY NUMBER,
          p_CHECK_NAME    VARCHAR2,
          p_CHECK_NAME_CODE    VARCHAR2,
          p_DESCRIPTION    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE,
          p_SEEDED_FLAG    VARCHAR2,
          p_SELECT_TYPE    VARCHAR2,
          p_SELECT_BLOCK_ID    NUMBER,
          p_DATA_TYPE    VARCHAR2,
          p_FORMAT_MASK    VARCHAR2,
          p_THRESHOLD_GRADE    VARCHAR2,
          p_THRESHOLD_RATING_CODE    VARCHAR2,
          p_CHECK_UPPER_LOWER_FLAG    VARCHAR2,
          p_THRESHOLD_COLOR_CODE    VARCHAR2,
          p_CHECK_LEVEL             VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
	    x_OBJECT_VERSION_NUMBER OUT NOCOPY NUMBER,
          p_APPLICATION_ID     NUMBER
	)
 IS
   CURSOR C2 IS SELECT CSC_PROF_CHECKS_S.nextval FROM sys.dual;
l_object_version_number number := 1;
ps_SEEDED_FLAG    Varchar2(3);
BEGIN

   /* added the below 2 lines for bug 4596220 */
   ps_seeded_flag := p_seeded_flag;
   IF NVL(p_seeded_flag, 'N') <> 'Y' THEN

   /* Added This If Condition for Bug 1944040 */
      If p_Created_by=1 then
           ps_seeded_flag:='Y';
      Else
           ps_seeded_flag:='N';
      End If;
   END IF;

   If (px_CHECK_ID IS NULL) OR (px_CHECK_ID = G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_CHECK_ID;
       CLOSE C2;
   End If;

  -- to_date(NULL) added to include timestamp during creation
   INSERT INTO CSC_PROF_CHECKS_b(
           CHECK_ID,
           CHECK_NAME_CODE,
           START_DATE_ACTIVE,
           END_DATE_ACTIVE,
           SEEDED_FLAG,
           SELECT_TYPE,
           SELECT_BLOCK_ID,
           DATA_TYPE,
           FORMAT_MASK,
           THRESHOLD_GRADE,
           THRESHOLD_RATING_CODE,
           CHECK_UPPER_LOWER_FLAG,
           THRESHOLD_COLOR_CODE,
           CHECK_LEVEL,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
	   OBJECT_VERSION_NUMBER,
           APPLICATION_ID
          ) VALUES (
           px_CHECK_ID,
           decode( p_CHECK_NAME_CODE, G_MISS_CHAR, NULL, p_CHECK_NAME_CODE),
           decode( p_START_DATE_ACTIVE,G_MISS_DATE, to_date(NULL), p_START_DATE_ACTIVE),
           decode( p_END_DATE_ACTIVE, G_MISS_DATE,to_date(NULL), p_END_DATE_ACTIVE),
           decode( p_SEEDED_FLAG, G_MISS_CHAR, NULL, ps_SEEDED_FLAG),
           decode( p_SELECT_TYPE, G_MISS_CHAR, NULL, p_SELECT_TYPE),
           decode( p_SELECT_BLOCK_ID, G_MISS_NUM, NULL, p_SELECT_BLOCK_ID),
           decode( p_DATA_TYPE, G_MISS_CHAR, NULL, p_DATA_TYPE),
           decode( p_FORMAT_MASK, G_MISS_CHAR, NULL, p_FORMAT_MASK),
           decode( p_THRESHOLD_GRADE, G_MISS_CHAR, NULL, p_THRESHOLD_GRADE),
           decode( p_THRESHOLD_RATING_CODE, G_MISS_CHAR, NULL, p_THRESHOLD_RATING_CODE),
           decode( p_CHECK_UPPER_LOWER_FLAG, G_MISS_CHAR, NULL, p_CHECK_UPPER_LOWER_FLAG),
           decode( p_THRESHOLD_COLOR_CODE, G_MISS_CHAR, NULL, p_THRESHOLD_COLOR_CODE),
           decode( p_CHECK_LEVEL, G_MISS_CHAR, NULL, p_CHECK_LEVEL),
           decode( p_CREATED_BY, G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, G_MISS_DATE,to_date(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, G_MISS_DATE,to_date(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
	     l_OBJECT_VERSION_NUMBER,
           decode( p_APPLICATION_ID,G_MISS_NUM, NULL, p_APPLICATION_ID) );


   INSERT INTO CSC_PROF_CHECKS_TL(
	   CHECK_ID,
           CHECK_NAME,
           DESCRIPTION,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           LANGUAGE,
           SOURCE_LANG
          ) select
           Px_CHECK_ID,
           decode( p_CHECK_NAME, G_MISS_CHAR, NULL, p_CHECK_NAME),
           decode( p_DESCRIPTION,G_MISS_CHAR, NULL, p_DESCRIPTION),
           decode( p_CREATED_BY, G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, G_MISS_DATE,to_date(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, G_MISS_DATE,to_date(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           L.LANGUAGE_CODE,
           userenv('LANG')
     FROM FND_LANGUAGES L
    WHERE L.INSTALLED_FLAG in ('I', 'B')
    AND not exists
      (select NULL
       from CSC_PROF_CHECKS_TL T
       where T.CHECK_ID = Px_CHECK_ID
       and T.LANGUAGE = L.LANGUAGE_CODE);

    --set out parameters
    x_object_version_number := l_object_version_number;
End Insert_Row;

PROCEDURE Update_Row(
          p_CHECK_ID    NUMBER,
          p_CHECK_NAME    VARCHAR2,
          p_CHECK_NAME_CODE    VARCHAR2,
          p_DESCRIPTION    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE,
          p_SEEDED_FLAG    VARCHAR2,
          p_SELECT_TYPE    VARCHAR2,
          p_SELECT_BLOCK_ID    NUMBER,
          p_DATA_TYPE    VARCHAR2,
          p_FORMAT_MASK    VARCHAR2,
          p_THRESHOLD_GRADE    VARCHAR2,
          p_THRESHOLD_RATING_CODE    VARCHAR2,
          p_CHECK_UPPER_LOWER_FLAG    VARCHAR2,
          p_THRESHOLD_COLOR_CODE    VARCHAR2,
          p_CHECK_LEVEL             VARCHAR2,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
	       px_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER,
          p_APPLICATION_ID  NUMBER)

 IS
 BEGIN
    Update CSC_PROF_CHECKS_B
    SET
       CHECK_NAME_CODE = p_CHECK_NAME_CODE,
       START_DATE_ACTIVE = p_START_DATE_ACTIVE,
       END_DATE_ACTIVE = p_END_DATE_ACTIVE,
       SEEDED_FLAG = p_SEEDED_FLAG,
       SELECT_TYPE = p_SELECT_TYPE,
       SELECT_BLOCK_ID = p_SELECT_BLOCK_ID,
       DATA_TYPE = p_DATA_TYPE,
       FORMAT_MASK = p_FORMAT_MASK,
       THRESHOLD_GRADE = p_THRESHOLD_GRADE,
       THRESHOLD_RATING_CODE = p_THRESHOLD_RATING_CODE,
       CHECK_UPPER_LOWER_FLAG = p_CHECK_UPPER_LOWER_FLAG,
       THRESHOLD_COLOR_CODE = p_THRESHOLD_COLOR_CODE,
       CHECK_LEVEL = p_CHECK_LEVEL,
       LAST_UPDATED_BY = p_LAST_UPDATED_BY,
       LAST_UPDATE_DATE = p_LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN,
	    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
       APPLICATION_ID= p_APPLICATION_ID
    WHERE CHECK_ID = p_CHECK_ID
    RETURNING OBJECT_VERSION_NUMBER INTO px_object_version_number;

    UPDATE CSC_PROF_CHECKS_TL SET
        CHECK_NAME =  p_CHECK_NAME,
        DESCRIPTION = p_DESCRIPTION,
        LAST_UPDATED_BY = p_LAST_UPDATED_BY,
        LAST_UPDATE_DATE = p_LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN,
    	  SOURCE_LANG = userenv('LANG')
    WHERE CHECK_ID = P_CHECK_ID
    AND userenv('LANG') in (LANGUAGE, SOURCE_LANG);
    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;


procedure LOCK_ROW (
  P_CHECK_ID  NUMBER,
  P_OBJECT_VERSION_NUMBER NUMBER
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      CHECK_NAME_CODE,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      SEEDED_FLAG,
      SELECT_TYPE,
      SELECT_BLOCK_ID,
      DATA_TYPE,
      FORMAT_MASK,
      THRESHOLD_GRADE,
      THRESHOLD_RATING_CODE,
      THRESHOLD_COLOR_CODE,
      CHECK_LEVEL,
      CHECK_UPPER_LOWER_FLAG
    from CSC_PROF_CHECKS_B
    where CHECK_ID = P_CHECK_ID
    and object_version_number = P_OBJECT_VERSION_NUMBER
    for update of CHECK_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      CHECK_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CSC_PROF_CHECKS_TL
    where CHECK_ID = P_CHECK_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CHECK_ID nowait;
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
  P_CHECK_ID  NUMBER,
  P_OBJECT_VERSION_NUMBER NUMBER
) is
begin
  delete from CSC_PROF_CHECKS_TL
  where CHECK_ID = P_CHECK_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CSC_PROF_CHECKS_B
  where CHECK_ID = P_CHECK_ID
  and OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CSC_PROF_CHECKS_TL T
  where not exists
    (select NULL
    from CSC_PROF_CHECKS_B B
    where B.CHECK_ID = T.CHECK_ID
    );

  update CSC_PROF_CHECKS_TL T set (
      CHECK_NAME,
      DESCRIPTION
    ) = (select
      B.CHECK_NAME,
      B.DESCRIPTION
    from CSC_PROF_CHECKS_TL B
    where B.CHECK_ID = T.CHECK_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CHECK_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CHECK_ID,
      SUBT.LANGUAGE
    from CSC_PROF_CHECKS_TL SUBB, CSC_PROF_CHECKS_TL SUBT
    where SUBB.CHECK_ID = SUBT.CHECK_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CHECK_NAME <> SUBT.CHECK_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into CSC_PROF_CHECKS_TL (
    CHECK_ID,
    CHECK_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CHECK_ID,
    B.CHECK_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CSC_PROF_CHECKS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CSC_PROF_CHECKS_TL T
    where T.CHECK_ID = B.CHECK_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  P_CHECK_ID        NUMBER,
  p_CHECK_NAME      VARCHAR2,
  p_DESCRIPTION    	VARCHAR2,
  p_owner 		varchar2)
  IS
  BEGIN
	Update Csc_Prof_Checks_TL set
	     check_name        = p_check_name,
	     description       = nvl(p_description,description),
	     last_update_date  = sysdate,
	     last_updated_by   = fnd_load_util.owner_id(p_owner),
	     last_update_login = 0,
	     source_lang       = userenv('LANG')
	     Where check_id    = p_check_id
	    and  userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

PROCEDURE Load_Row(
          p_CHECK_ID    		NUMBER,
          p_CHECK_NAME    	VARCHAR2,
          p_CHECK_NAME_CODE   VARCHAR2,
          p_DESCRIPTION    	VARCHAR2,
          p_START_DATE_ACTIVE DATE,
          p_END_DATE_ACTIVE   DATE,
          p_SEEDED_FLAG    	VARCHAR2,
          p_SELECT_TYPE    	VARCHAR2,
          p_SELECT_BLOCK_ID   NUMBER,
          p_DATA_TYPE    	VARCHAR2,
          p_FORMAT_MASK    	VARCHAR2,
          p_THRESHOLD_GRADE   VARCHAR2,
          p_THRESHOLD_RATING_CODE    VARCHAR2,
          p_CHECK_UPPER_LOWER_FLAG   VARCHAR2,
          p_THRESHOLD_COLOR_CODE     VARCHAR2,
          p_CHECK_LEVEL              VARCHAR2,
          p_LAST_UPDATED_BY     NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN   NUMBER,
	  px_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER ,
          p_APPLICATION_ID      NUMBER,
       	  P_OWNER	VARCHAR2)
IS
	     l_user_id	number := 0;
	     l_check_id	number := G_MISS_NUM;
	     l_object_version_number	number := 0;

		/** This is mainly for loading seed data . That is the
		reason, that l_check_id is being declared here, The check_id
		returned from insert_row is not used.

		2. Object_version_number is not passed . It is assumed that
			seed data would be run when other users are not using
			the system
		**/
    BEGIN
		/*if (p_owner = 'SEED') then
			l_user_id := 1;
		end if; */

        l_check_id := p_check_id;

        Csc_Prof_Checks_Pkg.Update_Row(
 			p_CHECK_ID    		     => p_check_id,
 			p_CHECK_NAME    	     => p_check_name,
 			p_CHECK_NAME_CODE  	     => p_check_name_code,
 			p_DESCRIPTION    	     => p_description,
 			p_START_DATE_ACTIVE  => to_date(p_start_date_active,'YYYY/MM/DD'),
 			p_END_DATE_ACTIVE    => to_date(p_end_date_active,'YYYY/MM/DD'),
 			p_SEEDED_FLAG    	     => 'Y',
 			p_SELECT_TYPE    	     => p_select_type,
 			p_SELECT_BLOCK_ID        => p_select_block_id,
 			p_DATA_TYPE    	     => p_data_type,
 			p_FORMAT_MASK    	     => p_format_mask,
 			p_THRESHOLD_GRADE        => p_threshold_grade,
 			p_THRESHOLD_RATING_CODE  => p_threshold_rating_code,
 			p_CHECK_UPPER_LOWER_FLAG => p_check_upper_lower_flag,
 			p_THRESHOLD_COLOR_CODE   => p_threshold_color_code,
                        p_CHECK_LEVEL            => p_check_level,
 			p_LAST_UPDATED_BY    	=> p_LAST_UPDATED_BY,
 			p_LAST_UPDATE_DATE    	=> p_LAST_UPDATE_DATE,
 			p_LAST_UPDATE_LOGIN    	=> 0,
 		        px_OBJECT_VERSION_NUMBER => l_object_version_number,
                        p_APPLICATION_ID          => p_application_id );


   EXCEPTION
      WHEN NO_DATA_FOUND THEN

	    csc_prof_checks_pkg.insert_row(
 		px_CHECK_ID   	          => l_check_id ,
 		p_CHECK_NAME             => p_check_name,
 		p_CHECK_NAME_CODE        => p_check_name_code,
 		p_DESCRIPTION            => p_description,
 		p_START_DATE_ACTIVE  => to_date(p_start_date_active,'YYYY/MM/DD'),
 		p_END_DATE_ACTIVE    => to_date(p_end_date_active,'YYYY/MM/DD'),
 		p_SEEDED_FLAG            => 'Y',
 		p_SELECT_TYPE            => p_select_type,
 		p_SELECT_BLOCK_ID        => p_select_block_id,
 		p_DATA_TYPE    	     => p_data_type,
 		p_FORMAT_MASK    	     => p_format_mask,
 		p_THRESHOLD_GRADE        => p_threshold_grade,
 		p_THRESHOLD_RATING_CODE  => p_threshold_rating_code,
 		p_CHECK_UPPER_LOWER_FLAG => p_check_upper_lower_flag,
 		p_THRESHOLD_COLOR_CODE   => p_threshold_color_code,
                p_CHECK_LEVEL            => p_check_level,
 		p_CREATED_BY             => p_LAST_UPDATED_BY,
 		p_CREATION_DATE          => p_LAST_UPDATE_DATE,
 		p_LAST_UPDATED_BY        => p_LAST_UPDATED_BY,
 		p_LAST_UPDATE_DATE       => p_LAST_UPDATE_DATE,
 		p_LAST_UPDATE_LOGIN      => 0,
 		x_OBJECT_VERSION_NUMBER  => l_object_version_number,
                p_APPLICATION_ID          => p_application_id );

End Load_ROW;

End CSC_PROF_CHECKS_PKG;

/
