--------------------------------------------------------
--  DDL for Package Body CSC_PROF_TABLE_COLUMNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PROF_TABLE_COLUMNS_PKG" as
/* $Header: csctptcb.pls 120.2 2005/09/18 23:33:50 vshastry noship $ */
-- Start of Comments
-- Package name     : CSC_PROF_TABLE_COLUMNS_PKG
-- Purpose          :
-- History          : 25-Nov-02 JAmose Fnd_Api_G_MISS*,NOCOPY related changes
-- History          : 24-Feb-2003, Introduced new procedure delete_existing_row to
--                    delete before loading a row
-- 19-09-2005 vshastry Bug 4596220. Added condition in insert row
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_PROF_TABLE_COLUMNS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csctuvab.pls';

PROCEDURE Insert_Row(
          px_TABLE_COLUMN_ID   IN OUT NOCOPY NUMBER,
          p_BLOCK_ID    NUMBER,
          p_TABLE_NAME    VARCHAR2,
          p_COLUMN_NAME    VARCHAR2,
          p_LABEL    VARCHAR2,
          p_TABLE_ALIAS VARCHAR2,
          p_COLUMN_SEQUENCE NUMBER,
	       p_DRILLDOWN_COLUMN_FLAG VARCHAR2,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_SEEDED_FLAG   VARCHAR2,
          x_OBJECT_VERSION_NUMBER OUT NOCOPY NUMBER)

 IS
   CURSOR C2 IS SELECT CSC_PROF_TABLE_COLUMNS_S.nextval FROM sys.dual;
   l_object_version_number NUMBER := 1;
   ps_SEEDED_FLAG    Varchar2(3);
BEGIN

   /* added the below 2 lines for bug 4596220 */
   ps_seeded_flag := p_seeded_flag;
   IF NVL(p_seeded_flag, 'N') <> 'Y' THEN

   /* Added This If Condition for Bug 1944040*/
      If p_Created_by=1 then
           ps_seeded_flag:='Y';
      Else
           ps_seeded_flag:='N';
      End If;
   END IF;

   If (px_TABLE_COLUMN_ID IS NULL) OR (px_TABLE_COLUMN_ID = CSC_CORE_UTILS_PVT.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_TABLE_COLUMN_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSC_PROF_TABLE_COLUMNS_B(
           TABLE_COLUMN_ID,
           BLOCK_ID,
           TABLE_NAME,
           COLUMN_NAME,
           ALIAS_NAME,
           COLUMN_SEQUENCE,
	   DRILLDOWN_COLUMN_FLAG,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           SEEDED_FLAG,
           OBJECT_VERSION_NUMBER
          ) VALUES (
           px_TABLE_COLUMN_ID,
           decode( p_BLOCK_ID, CSC_CORE_UTILS_PVT.G_MISS_NUM, NULL, p_BLOCK_ID),
           decode( p_TABLE_NAME, CSC_CORE_UTILS_PVT.G_MISS_CHAR, NULL, p_TABLE_NAME),
           decode( p_COLUMN_NAME, CSC_CORE_UTILS_PVT.G_MISS_CHAR, NULL, p_COLUMN_NAME),
           decode( p_TABLE_ALIAS, CSC_CORE_UTILS_PVT.G_MISS_CHAR,NULL,p_TABLE_ALIAS),
           decode( p_COLUMN_SEQUENCE,CSC_CORE_UTILS_PVT.G_MISS_NUM,NULL,p_COLUMN_SEQUENCE),
	        decode( p_DRILLDOWN_COLUMN_FLAG,CSC_CORE_UTILS_PVT.G_MISS_CHAR,NULL,p_DRILLDOWN_COLUMN_FLAG),
           decode( p_LAST_UPDATE_DATE, CSC_CORE_UTILS_PVT.G_MISS_DATE, NULL, p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATED_BY, CSC_CORE_UTILS_PVT.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_CREATION_DATE, CSC_CORE_UTILS_PVT.G_MISS_DATE, NULL, p_CREATION_DATE),
           decode( p_CREATED_BY, CSC_CORE_UTILS_PVT.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_LAST_UPDATE_LOGIN, CSC_CORE_UTILS_PVT.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_SEEDED_FLAG, CSC_CORE_UTILS_PVT.G_MISS_CHAR,NULL,ps_SEEDED_FLAG),
           l_OBJECT_VERSION_NUMBER);

  -- assign out parameters
  x_object_version_number := l_object_version_number;

   INSERT INTO CSC_PROF_TABLE_COLUMNS_TL(
           TABLE_COLUMN_ID,
           LABEL,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           LANGUAGE,
           SOURCE_LANG
           ) select
           px_TABLE_COLUMN_ID,
    	     decode( p_LABEL, CSC_CORE_UTILS_PVT.G_MISS_CHAR, NULL, p_LABEL),
           decode( p_CREATED_BY, CSC_CORE_UTILS_PVT.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, CSC_CORE_UTILS_PVT.G_MISS_DATE, NULL, p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, CSC_CORE_UTILS_PVT.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, CSC_CORE_UTILS_PVT.G_MISS_DATE, NULL, p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, CSC_CORE_UTILS_PVT.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
    	     L.LANGUAGE_CODE,
           userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CSC_PROF_TABLE_COLUMNS_TL T
    where T.TABLE_COLUMN_ID = Px_TABLE_COLUMN_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);


End Insert_Row;

PROCEDURE Update_Row(
          p_TABLE_COLUMN_ID    NUMBER,
          p_BLOCK_ID    NUMBER,
          p_TABLE_NAME    VARCHAR2,
          p_COLUMN_NAME    VARCHAR2,
          p_LABEL    VARCHAR2,
          p_TABLE_ALIAS VARCHAR2,
          p_COLUMN_SEQUENCE NUMBER,
	       p_DRILLDOWN_COLUMN_FLAG VARCHAR2,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_SEEDED_FLAG    VARCHAR2,
          px_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER)

 IS
 BEGIN

    Update CSC_PROF_TABLE_COLUMNS_B
    SET
       BLOCK_ID = decode( p_BLOCK_ID, CSC_CORE_UTILS_PVT.G_MISS_NUM, BLOCK_ID, p_BLOCK_ID),
       TABLE_NAME = decode( p_TABLE_NAME, CSC_CORE_UTILS_PVT.G_MISS_CHAR, TABLE_NAME, p_TABLE_NAME),
       COLUMN_NAME = decode( p_COLUMN_NAME, CSC_CORE_UTILS_PVT.G_MISS_CHAR, COLUMN_NAME, p_COLUMN_NAME),
              -- LABEL = decode( p_LABEL, CSC_CORE_UTILS_PVT.G_MISS_CHAR, LABEL, p_LABEL),
	    ALIAS_NAME = decode(p_TABLE_ALIAS,CSC_CORE_UTILS_PVT.G_MISS_CHAR,ALIAS_NAME,p_TABLE_ALIAS),
	    COLUMN_SEQUENCE = decode(p_COLUMN_SEQUENCE, CSC_CORE_UTILS_PVT.G_MISS_NUM,COLUMN_SEQUENCE,p_COLUMN_SEQUENCE),
		 DRILLDOWN_COLUMN_FLAG = decode(p_DRILLDOWN_COLUMN_FLAG,CSC_CORE_UTILS_PVT.G_MISS_CHAR,DRILLDOWN_COLUMN_FLAG,p_DRILLDOWN_COLUMN_FLAG),
       LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, CSC_CORE_UTILS_PVT.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
       LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, CSC_CORE_UTILS_PVT.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
       LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, CSC_CORE_UTILS_PVT.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
       SEEDED_FLAG = decode( p_SEEDED_FLAG, CSC_CORE_UTILS_PVT.G_MISS_CHAR,SEEDED_FLAG, NVL(p_SEEDED_FLAG,SEEDED_FLAG)),
       OBJECT_VERSION_NUMBER = object_version_number + 1
    where TABLE_COLUMN_ID = p_TABLE_COLUMN_ID
    RETURNING OBJECT_VERSION_NUMBER INTO px_OBJECT_VERSION_NUMBER;

    Update CSC_PROF_TABLE_COLUMNS_TL
    SET
      LABEL = decode( p_LABEL, CSC_CORE_UTILS_PVT.G_MISS_CHAR, LABEL, p_LABEL),
      LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, CSC_CORE_UTILS_PVT.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
      LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, CSC_CORE_UTILS_PVT.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
      LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, CSC_CORE_UTILS_PVT.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
    	SOURCE_LANG = userenv('LANG')
    where TABLE_COLUMN_ID = P_TABLE_COLUMN_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

   if (sql%rowcount = 0 ) then
	 raise no_data_found;
   end if;
END Update_Row;

procedure LOCK_ROW (
  P_TABLE_COLUMN_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      BLOCK_ID,
      TABLE_NAME,
      ALIAS_NAME,
      COLUMN_NAME,
      COLUMN_SEQUENCE,
      OBJECT_VERSION_NUMBER
    from CSC_PROF_TABLE_COLUMNS_B
    where TABLE_COLUMN_ID = P_TABLE_COLUMN_ID
    and object_version_number = p_object_version_number
    for update of TABLE_COLUMN_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      LABEL,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CSC_PROF_TABLE_COLUMNS_TL
    where TABLE_COLUMN_ID = P_TABLE_COLUMN_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TABLE_COLUMN_ID nowait;
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
  P_TABLE_COLUMN_ID       NUMBER,
  P_OBJECT_VERSION_NUMBER NUMBER
) is
begin
  delete from CSC_PROF_TABLE_COLUMNS_TL
  where TABLE_COLUMN_ID = P_TABLE_COLUMN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CSC_PROF_TABLE_COLUMNS_B
  where TABLE_COLUMN_ID = P_TABLE_COLUMN_ID
  and OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

Procedure DELETE_EXISTING_ROW (
	p_BLOCK_ID 		NUMBER,
   p_TABLE_NAME 	VARCHAR2,
   p_COLUMN_NAME	VARCHAR2) IS
Begin
   DELETE FROM CSC_PROF_TABLE_COLUMNS_TL
     WHERE TABLE_COLUMN_ID IN (SELECT TABLE_COLUMN_ID FROM CSC_PROF_TABLE_COLUMNS_B
       WHERE BLOCK_ID = p_BLOCK_ID
       AND TABLE_NAME = p_TABLE_NAME
       AND COLUMN_NAME = p_COLUMN_NAME);
   IF (SQL%FOUND) THEN
      DELETE FROM CSC_PROF_TABLE_COLUMNS_B
         WHERE BLOCK_ID = p_BLOCK_ID
         AND TABLE_NAME = p_TABLE_NAME
         AND COLUMN_NAME = p_COLUMN_NAME ;
   END IF;
End Delete_Existing_Row;

procedure ADD_LANGUAGE
is
begin
  delete from CSC_PROF_TABLE_COLUMNS_TL T
  where not exists
    (select NULL
    from CSC_PROF_TABLE_COLUMNS_B B
    where B.TABLE_COLUMN_ID = T.TABLE_COLUMN_ID
    );

  update CSC_PROF_TABLE_COLUMNS_TL T set (
      LABEL
    ) = (select
      B.LABEL
    from CSC_PROF_TABLE_COLUMNS_TL B
    where B.TABLE_COLUMN_ID = T.TABLE_COLUMN_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TABLE_COLUMN_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TABLE_COLUMN_ID,
      SUBT.LANGUAGE
    from CSC_PROF_TABLE_COLUMNS_TL SUBB, CSC_PROF_TABLE_COLUMNS_TL SUBT
    where SUBB.TABLE_COLUMN_ID = SUBT.TABLE_COLUMN_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.LABEL <> SUBT.LABEL
      or (SUBB.LABEL is null and SUBT.LABEL is not null)
      or (SUBB.LABEL is not null and SUBT.LABEL is null)
  ));

  insert into CSC_PROF_TABLE_COLUMNS_TL (
    TABLE_COLUMN_ID,
    LABEL,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TABLE_COLUMN_ID,
    B.LABEL,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CSC_PROF_TABLE_COLUMNS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CSC_PROF_TABLE_COLUMNS_TL T
    where T.TABLE_COLUMN_ID = B.TABLE_COLUMN_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

Procedure TRANSLATE_ROW (
   p_LABEL 		in varchar2,
   p_TABLE_COLUMN_ID 	in number,
   p_OWNER 		in varchar2 ) is

Begin
     Update Csc_Prof_Table_Columns_TL set
          label = nvl(P_LABEL,label),
          last_update_date  = sysdate,
	  last_updated_by   = decode(p_OWNER,'SEED',1,0),
	  last_update_login = 0,
	  source_lang       = userenv('LANG')
     Where table_column_id = P_TABLE_COLUMN_ID
     and  userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

Procedure LOAD_ROW (
   p_TABLE_COLUMN_ID        in number,
   p_BLOCK_ID               in number,
   p_TABLE_NAME             in varchar2,
   p_COLUMN_NAME            in varchar2,
   p_LABEL                  in varchar2,
   p_ALIAS_NAME             in varchar2,
   p_COLUMN_SEQUENCE        in number,
   p_DRILLDOWN_COLUMN_FLAG  in varchar2,
   p_SEEDED_FLAG            in varchar2,
   p_last_update_date       IN DATE,
   p_last_updated_by        IN NUMBER,
   p_last_update_login      IN NUMBER
 ) is

 l_object_version_number number := 0;
 l_table_column_id       number := p_table_column_id;
Begin


  Csc_Prof_Table_Columns_Pkg.Update_Row(
   p_TABLE_COLUMN_ID        => P_TABLE_COLUMN_ID,
   p_BLOCK_ID               => P_BLOCK_ID,
   p_TABLE_NAME             => P_TABLE_NAME,
   p_COLUMN_NAME            => P_COLUMN_NAME,
   p_LABEL                  => P_LABEL,
   p_TABLE_ALIAS            => P_ALIAS_NAME,
   p_COLUMN_SEQUENCE        => P_COLUMN_SEQUENCE,
   p_drilldown_column_flag  => P_DRILLDOWN_COLUMN_FLAG,
   p_LAST_UPDATE_DATE       => p_last_update_date,
   p_LAST_UPDATED_BY        => p_last_updated_by,
   p_LAST_UPDATE_LOGIN      => p_last_update_login,
   p_SEEDED_FLAG            => p_SEEDED_FLAG,
   px_OBJECT_VERSION_NUMBER => l_object_version_number);

 Exception
  When no_data_found then
    /* Added this procedure not to cause the duplicate records while
    loading the seeded table columns. The reason being is if the seeded
    profile are changed it removes the records and recreates brand new
    records with new sequence number. So in the customer site it will
    introduce new set of records with diff sequence numbers. So the following
    procedure will check and will remove the existing record first before
    uploading new set of records -jamose */
   Csc_Prof_Table_Columns_Pkg.Delete_Existing_Row(
   	p_BLOCK_ID			=>p_block_id,
   	p_TABLE_NAME      =>p_table_name,
   	p_COLUMN_NAME     =>p_column_name
   	);

   Csc_Prof_Table_Columns_Pkg.Insert_Row(
      px_TABLE_COLUMN_ID      => l_table_column_id,
      p_BLOCK_ID              => P_block_id,
      p_TABLE_NAME            => P_table_name,
      p_COLUMN_NAME           => P_column_name,
      p_LABEL                 => P_label,
      p_TABLE_ALIAS           => P_alias_name,
      p_COLUMN_SEQUENCE       => P_column_sequence,
      p_drilldown_column_flag  =>P_drilldown_column_flag,
      p_LAST_UPDATE_DATE      => p_last_update_date,
      p_LAST_UPDATED_BY       => p_last_updated_by,
      p_CREATION_DATE         => p_last_update_date,
      p_CREATED_BY            => p_last_updated_by,
      p_LAST_UPDATE_LOGIN     => p_last_update_login,
      p_SEEDED_FLAG           => p_SEEDED_FLAG,
      x_OBJECT_VERSION_NUMBER => l_object_version_number);

End LOAD_ROW;


End CSC_PROF_TABLE_COLUMNS_PKG;

/
