--------------------------------------------------------
--  DDL for Package Body ASO_SUP_COMPONENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_SUP_COMPONENT_PKG" AS
/* $Header: asospcob.pls 120.4.12010000.2 2015/08/11 05:40:35 akushwah ship $*/

/* procedure to insert INSERT_ROW */

PROCEDURE INSERT_ROW
(
  PX_ROWID              IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  PX_COMPONENT_ID       IN OUT NOCOPY /* file.sql.39 change */  NUMBER,
  P_created_by          IN NUMBER ,
  P_creation_date       IN DATE ,
  P_last_updated_by     IN NUMBER,
  P_last_update_date    IN DATE,
  P_last_update_login   IN NUMBER,
  P_COMPONENT_TYPE      IN VARCHAR2,
  P_COMPONENT_NAME      IN VARCHAR2,
  P_MANDATORY_FLAG      IN VARCHAR2 := 'N',
  P_RESPONSE_TYPE       IN VARCHAR2 := 'TEXT',
  P_DESCRIPTION         IN VARCHAR2 := NULL,
  P_INSTRUCTION         IN VARCHAR2 := NULL,
  P_CONTEXT             IN VARCHAR2 := NULL,
  P_ATTRIBUTE1          IN VARCHAR2 := NULL,
  P_ATTRIBUTE2          IN VARCHAR2 := NULL,
  P_ATTRIBUTE3          IN VARCHAR2 := NULL,
  P_ATTRIBUTE4          IN VARCHAR2 := NULL,
  P_ATTRIBUTE5          IN VARCHAR2 := NULL,
  P_ATTRIBUTE6          IN VARCHAR2 := NULL,
  P_ATTRIBUTE7          IN VARCHAR2 := NULL,
  P_ATTRIBUTE8          IN VARCHAR2 := NULL,
  P_ATTRIBUTE9          IN VARCHAR2 := NULL,
  P_ATTRIBUTE10         IN VARCHAR2 := NULL,
  P_ATTRIBUTE11         IN VARCHAR2 := NULL,
  P_ATTRIBUTE12         IN VARCHAR2 := NULL,
  P_ATTRIBUTE13         IN VARCHAR2 := NULL,
  P_ATTRIBUTE14         IN VARCHAR2 := NULL,
  P_ATTRIBUTE15         IN VARCHAR2 := NULL,
  P_ATTRIBUTE16         IN VARCHAR2 := NULL,
  P_ATTRIBUTE17         IN VARCHAR2 := NULL,
  P_ATTRIBUTE18         IN VARCHAR2 := NULL,
  P_ATTRIBUTE19         IN VARCHAR2 := NULL,
  P_ATTRIBUTE20         IN VARCHAR2 := NULL
)

IS

  cursor c is
    select ROWID
    from  ASO_SUP_COMPONENT_B
    where  COMPONENT_ID = PX_COMPONENT_ID ;

  cursor CU_COMPONENT_ID IS
    select ASO_SUP_COMPONENT_B_S.NEXTVAL from sys.dual;

Begin

  IF (PX_COMPONENT_ID IS NULL) OR (PX_COMPONENT_ID = FND_API.G_MISS_NUM) THEN
      OPEN CU_COMPONENT_ID;
      FETCH CU_COMPONENT_ID INTO PX_COMPONENT_ID;
      CLOSE CU_COMPONENT_ID;

  END IF;

  insert into ASO_SUP_COMPONENT_B (
  COMPONENT_ID,
  COMPONENT_TYPE,
  MANDATORY_FLAG,
  RESPONSE_TYPE,
  created_by  ,
  creation_date ,
  last_updated_by ,
  last_update_date ,
  last_update_login ,
  CONTEXT,
  ATTRIBUTE1 ,
  ATTRIBUTE2 ,
  ATTRIBUTE3 ,
  ATTRIBUTE4 ,
  ATTRIBUTE5 ,
  ATTRIBUTE6 ,
  ATTRIBUTE7 ,
  ATTRIBUTE8 ,
  ATTRIBUTE9 ,
  ATTRIBUTE10 ,
  ATTRIBUTE11 ,
  ATTRIBUTE12 ,
  ATTRIBUTE13 ,
  ATTRIBUTE14 ,
  ATTRIBUTE15,
  ATTRIBUTE16,
  ATTRIBUTE17,
  ATTRIBUTE18,
  ATTRIBUTE19,
  ATTRIBUTE20 )
values
  (
  PX_COMPONENT_ID,
  P_COMPONENT_TYPE,
  P_MANDATORY_FLAG,
  P_RESPONSE_TYPE,
  P_created_by  ,
  P_creation_date ,
  P_last_updated_by ,
  P_last_update_date ,
  P_last_update_login,
  P_CONTEXT,
  P_ATTRIBUTE1 ,
  P_ATTRIBUTE2 ,
  P_ATTRIBUTE3 ,
  P_ATTRIBUTE4 ,
  P_ATTRIBUTE5 ,
  P_ATTRIBUTE6 ,
  P_ATTRIBUTE7 ,
  P_ATTRIBUTE8 ,
  P_ATTRIBUTE9 ,
  P_ATTRIBUTE10 ,
  P_ATTRIBUTE11 ,
  P_ATTRIBUTE12 ,
  P_ATTRIBUTE13 ,
  P_ATTRIBUTE14 ,
  P_ATTRIBUTE15,
  P_ATTRIBUTE16 ,
  P_ATTRIBUTE17 ,
  P_ATTRIBUTE18 ,
  P_ATTRIBUTE19 ,
  P_ATTRIBUTE20
  );

  insert into ASO_SUP_COMPONENT_TL (
    COMPONENT_ID,
    LANGUAGE,
    SOURCE_LANG,
    COMPONENT_NAME,
    DESCRIPTION,
    INSTRUCTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN
  ) select
    PX_COMPONENT_ID,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    P_COMPONENT_NAME,
    P_DESCRIPTION,
    P_INSTRUCTION,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    P_CREATION_DATE,
    P_CREATED_BY,
    P_LAST_UPDATE_LOGIN
  from  FND_LANGUAGES  L
  where  L.INSTALLED_FLAG in ('I', 'B')
  and  not exists
         ( select 'x'
           from  ASO_SUP_COMPONENT_TL  T
           where  T.COMPONENT_ID = PX_COMPONENT_ID
             and  T.LANGUAGE = L.LANGUAGE_CODE );

  open c;
  fetch c into PX_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;


PROCEDURE UPDATE_ROW
(
  P_COMPONENT_ID        IN NUMBER,
  P_last_updated_by     IN NUMBER,
  P_last_update_date    IN DATE,
  P_last_update_login   IN NUMBER,
  P_COMPONENT_TYPE      IN VARCHAR2,
  P_COMPONENT_NAME      IN VARCHAR2,
  P_MANDATORY_FLAG      IN VARCHAR2 ,
  P_RESPONSE_TYPE       IN VARCHAR2 ,
  P_DESCRIPTION         IN VARCHAR2 ,
  P_INSTRUCTION         IN VARCHAR2 ,
  P_CONTEXT             IN VARCHAR2,
  P_ATTRIBUTE1          IN VARCHAR2,
  P_ATTRIBUTE2          IN VARCHAR2,
  P_ATTRIBUTE3          IN VARCHAR2,
  P_ATTRIBUTE4          IN VARCHAR2,
  P_ATTRIBUTE5          IN VARCHAR2,
  P_ATTRIBUTE6          IN VARCHAR2,
  P_ATTRIBUTE7          IN VARCHAR2,
  P_ATTRIBUTE8          IN VARCHAR2,
  P_ATTRIBUTE9          IN VARCHAR2,
  P_ATTRIBUTE10         IN VARCHAR2,
  P_ATTRIBUTE11         IN VARCHAR2,
  P_ATTRIBUTE12         IN VARCHAR2,
  P_ATTRIBUTE13         IN VARCHAR2,
  P_ATTRIBUTE14         IN VARCHAR2,
  P_ATTRIBUTE15         IN VARCHAR2,
  p_ATTRIBUTE16     IN   VARCHAR2,
  p_ATTRIBUTE17  IN   VARCHAR2,
  p_ATTRIBUTE18  IN  VARCHAR2,
  p_ATTRIBUTE19  IN   VARCHAR2,
  p_ATTRIBUTE20  IN  VARCHAR2
)


IS

Begin

  update ASO_SUP_COMPONENT_B
  set
  COMPONENT_TYPE = P_COMPONENT_TYPE,
  MANDATORY_FLAG = P_MANDATORY_FLAG,
  RESPONSE_TYPE  =  P_RESPONSE_TYPE,
  last_updated_by = P_last_updated_by,
  last_update_date = P_last_update_date,
  last_update_login = P_last_update_login,
  context = P_context,
  ATTRIBUTE1 = P_ATTRIBUTE1,
  ATTRIBUTE2 = P_ATTRIBUTE2,
  ATTRIBUTE3 = P_ATTRIBUTE3,
  ATTRIBUTE4 = P_ATTRIBUTE4,
  ATTRIBUTE5 = P_ATTRIBUTE5,
  ATTRIBUTE6 = P_ATTRIBUTE6,
  ATTRIBUTE7 = P_ATTRIBUTE7,
  ATTRIBUTE8 = P_ATTRIBUTE8,
  ATTRIBUTE9 = P_ATTRIBUTE9,
  ATTRIBUTE10 = P_ATTRIBUTE10,
  ATTRIBUTE11 = P_ATTRIBUTE11,
  ATTRIBUTE12 = P_ATTRIBUTE12,
  ATTRIBUTE13 = P_ATTRIBUTE13,
  ATTRIBUTE14 = P_ATTRIBUTE14,
  ATTRIBUTE15 = P_ATTRIBUTE15,
  ATTRIBUTE16 = P_ATTRIBUTE16,
  ATTRIBUTE17 = P_ATTRIBUTE17,
  ATTRIBUTE18 = P_ATTRIBUTE18,
  ATTRIBUTE19 = P_ATTRIBUTE19,
  ATTRIBUTE20 = P_ATTRIBUTE20
where  COMPONENT_ID = P_COMPONENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

update ASO_SUP_COMPONENT_TL
 set
  COMPONENT_NAME = P_COMPONENT_NAME,
  DESCRIPTION    = P_DESCRIPTION,
  INSTRUCTION    = P_INSTRUCTION,
  LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
  LAST_UPDATED_BY = P_LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN,
  SOURCE_LANG = userenv('LANG')
where  COMPONENT_ID = P_COMPONENT_ID
    and  userenv('LANG') in (LANGUAGE, SOURCE_LANG) ;

  if (sql%notfound) then
    raise no_data_found;
  end if;


End UPDATE_ROW;


procedure DELETE_ROW (
  P_COMPONENT_ID IN NUMBER

)

IS

Begin

 delete from ASO_SUP_COMPONENT_TL
  where  COMPONENT_ID = P_COMPONENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;


  delete from ASO_SUP_COMPONENT_B
  where  COMPONENT_ID = P_COMPONENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

End Delete_row;

PROCEDURE LOCK_ROW
(
  P_COMPONENT_ID        IN NUMBER,
  P_created_by          IN NUMBER ,
  P_creation_date       IN DATE ,
  P_last_updated_by     IN NUMBER,
  P_last_update_date    IN DATE,
  P_last_update_login   IN NUMBER,
  P_COMPONENT_TYPE      IN VARCHAR2,
  P_COMPONENT_NAME      IN VARCHAR2,
  P_MANDATORY_FLAG      IN VARCHAR2 ,
  P_RESPONSE_TYPE       IN VARCHAR2 ,
  P_DESCRIPTION         IN VARCHAR2 ,
  P_INSTRUCTION         IN VARCHAR2 ,
  P_CONTEXT             IN VARCHAR2,
  P_ATTRIBUTE1          IN VARCHAR2,
  P_ATTRIBUTE2          IN VARCHAR2,
  P_ATTRIBUTE3          IN VARCHAR2,
  P_ATTRIBUTE4          IN VARCHAR2,
  P_ATTRIBUTE5          IN VARCHAR2,
  P_ATTRIBUTE6          IN VARCHAR2,
  P_ATTRIBUTE7          IN VARCHAR2,
  P_ATTRIBUTE8          IN VARCHAR2,
  P_ATTRIBUTE9          IN VARCHAR2,
  P_ATTRIBUTE10         IN VARCHAR2,
  P_ATTRIBUTE11         IN VARCHAR2,
  P_ATTRIBUTE12         IN VARCHAR2,
  P_ATTRIBUTE13         IN VARCHAR2,
  P_ATTRIBUTE14         IN VARCHAR2,
  P_ATTRIBUTE15         IN VARCHAR2
)

IS

CURSOR i_csr is
SELECT
  a.COMPONENT_ID ,
  a.COMPONENT_TYPE,
  a.MANDATORY_FLAG ,
  a.RESPONSE_TYPE,
  created_by  ,
  creation_date ,
  last_updated_by ,
  last_update_date ,
  last_update_login ,
  context,
  ATTRIBUTE1 ,
  ATTRIBUTE2 ,
  ATTRIBUTE3 ,
  ATTRIBUTE4 ,
  ATTRIBUTE5 ,
  ATTRIBUTE6 ,
  ATTRIBUTE7 ,
  ATTRIBUTE8 ,
  ATTRIBUTE9 ,
  ATTRIBUTE10 ,
  ATTRIBUTE11 ,
  ATTRIBUTE12 ,
  ATTRIBUTE13 ,
  ATTRIBUTE14 ,
  ATTRIBUTE15

 from  ASO_SUP_COMPONENT_B a
 where a.COMPONENT_ID = P_COMPONENT_ID
 for update of a.COMPONENT_ID nowait;

recinfo i_csr%rowtype;

  cursor c1 is
    select
      COMPONENT_NAME,
      DESCRIPTION,
      INSTRUCTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from  ASO_SUP_COMPONENT_TL
    where COMPONENT_ID = P_COMPONENT_ID
    for update of COMPONENT_ID nowait;

  l_Item_ID         NUMBER ;
  l_Org_ID          NUMBER ;

  l_return_status   VARCHAR2(1) ;

BEGIN


  l_Item_ID := P_COMPONENT_ID ;

  open i_csr;

  fetch i_csr into recinfo;

  if (i_csr%notfound) then
    close i_csr;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;

  close i_csr;

-- Do not compare to the B table column;
-- only compare to TL column (c1 cursor below).

  if (
          ((recinfo.COMPONENT_ID = P_COMPONENT_ID)
           OR ((recinfo.COMPONENT_ID is null) AND (P_COMPONENT_ID is null)))
      AND ((recinfo.COMPONENT_TYPE = P_COMPONENT_TYPE)
           OR ((recinfo.COMPONENT_TYPE is null) AND (P_COMPONENT_TYPE is null)))
      AND ((recinfo.MANDATORY_FLAG = P_MANDATORY_FLAG)
           OR ((recinfo.MANDATORY_FLAG is null) AND (P_MANDATORY_FLAG is null)))
      AND ((recinfo.RESPONSE_TYPE = P_RESPONSE_TYPE)
           OR ((recinfo.RESPONSE_TYPE is null) AND (P_RESPONSE_TYPE is null)))
      AND ((recinfo.CREATED_BY = P_CREATED_BY)
           OR ((recinfo.CREATED_BY is null) AND (P_CREATED_BY is null)))

	  -- Start : code change done for Bug 20867578
      /* AND ((recinfo.CREATION_DATE = P_CREATION_DATE)
           OR ((recinfo.CREATION_DATE is null) AND (P_CREATION_DATE is null))) */

	  AND ((TRUNC(recinfo.CREATION_DATE) = TRUNC(P_CREATION_DATE))
           OR ((recinfo.CREATION_DATE is null) AND (P_CREATION_DATE is null)))
      -- End : code change done for Bug 20867578

	  AND ((recinfo.LAST_UPDATED_BY = P_LAST_UPDATED_BY)
           OR ((recinfo.LAST_UPDATED_BY is null) AND (P_LAST_UPDATED_BY is null)))

	  -- Start : code change done for Bug 20867578
	  /* AND ((recinfo.LAST_UPDATE_DATE = P_LAST_UPDATE_DATE)
           OR ((recinfo.LAST_UPDATE_DATE is null) AND (P_LAST_UPDATE_DATE is null))) */

	  AND ((TRUNC(recinfo.LAST_UPDATE_DATE) = TRUNC(P_LAST_UPDATE_DATE))
          OR ((recinfo.LAST_UPDATE_DATE is null) AND (P_LAST_UPDATE_DATE is null)))
	  -- End : code change done for Bug 20867578

	  AND ((recinfo.LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN)
           OR ((recinfo.LAST_UPDATE_LOGIN is null) AND (P_LAST_UPDATE_LOGIN is null)))

	  -- Start : code change done for Bug 20867578
	  /* AND ((recinfo.CONTEXT = P_CONTEXT)
           OR ((recinfo.CONTEXT is null) AND (P_CONTEXT is null))) */

         AND ((NVL(recinfo.CONTEXT,0) = NVL(P_CONTEXT,0))
           OR ((recinfo.CONTEXT is null) AND (P_CONTEXT is null)))
	  -- End : code change done for Bug 20867578

	  AND ((recinfo.ATTRIBUTE1 = P_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (P_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = P_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (P_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = P_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (P_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = P_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (P_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = P_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (P_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = P_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (P_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = P_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (P_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = P_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (P_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = P_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (P_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = P_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (P_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = P_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (P_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = P_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (P_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = P_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (P_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = P_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (P_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = P_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (P_ATTRIBUTE15 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.COMPONENT_NAME = P_COMPONENT_NAME)
               OR ((tlinfo.COMPONENT_NAME is null) AND (P_COMPONENT_NAME is null)))
           AND ((tlinfo.DESCRIPTION = P_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (P_DESCRIPTION is null)))
           AND ((tlinfo.INSTRUCTION = P_INSTRUCTION)
               OR ((tlinfo.INSTRUCTION  is null) AND (P_INSTRUCTION  is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;

  return;

End Lock_Row;


/* procedure for ADD_LANGUAGE */

procedure ADD_LANGUAGE
is
begin

  delete from ASO_SUP_COMPONENT_TL T
  where not exists
        ( select NULL
          from  ASO_SUP_COMPONENT_B  B
          where  B.COMPONENT_ID = T.COMPONENT_ID
        );

  update ASO_SUP_COMPONENT_TL T set (
      COMPONENT_NAME,
      DESCRIPTION,
      INSTRUCTION
    ) = ( select
      B.COMPONENT_NAME,
      B.DESCRIPTION,
      B.INSTRUCTION
    from  ASO_SUP_COMPONENT_TL  B
    where  B.COMPONENT_ID = T.COMPONENT_ID
      and  B.LANGUAGE = T.SOURCE_LANG )
  where (
      T.COMPONENT_ID,
      T.LANGUAGE
  ) in ( select
      SUBT.COMPONENT_ID,
      SUBT.LANGUAGE
    from  ASO_SUP_COMPONENT_TL  SUBB,
          ASO_SUP_COMPONENT_TL  SUBT
    where  SUBB.COMPONENT_ID = SUBT.COMPONENT_ID
      and  SUBB.LANGUAGE = SUBT.SOURCE_LANG
      and  ( SUBB.COMPONENT_NAME <> SUBT.COMPONENT_NAME
           or ( SUBB.COMPONENT_NAME is null     and SUBT.COMPONENT_NAME is not null )
           or ( SUBB.COMPONENT_NAME is not null and SUBT.COMPONENT_NAME is null ) )
      and  ( SUBB.DESCRIPTION <> SUBT.DESCRIPTION
           or ( SUBB.DESCRIPTION is null     and SUBT.DESCRIPTION is not null )
           or ( SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null ) )
      and  ( SUBB.INSTRUCTION <> SUBT.INSTRUCTION
           or ( SUBB.INSTRUCTION is null     and SUBT.INSTRUCTION is not null )
           or ( SUBB.INSTRUCTION is not null and SUBT.INSTRUCTION is null ) )
    );

  insert into ASO_SUP_COMPONENT_TL (
    COMPONENT_ID,
    LANGUAGE,
    SOURCE_LANG,
    COMPONENT_NAME,
    DESCRIPTION,
    INSTRUCTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN
  ) select
    B.COMPONENT_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG,
    B.COMPONENT_NAME,
    B.DESCRIPTION,
    B.INSTRUCTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN
  from  ASO_SUP_COMPONENT_TL    B,
        FND_LANGUAGES        L
  where  L.INSTALLED_FLAG in ('I', 'B')
    and  B.LANGUAGE = userenv('LANG')
    and  not exists
         ( select NULL
           from  ASO_SUP_COMPONENT_TL  T
           where  T.COMPONENT_ID = B.COMPONENT_ID
             and  T.LANGUAGE = L.LANGUAGE_CODE );

end ADD_LANGUAGE;


/* Procedure for Load_Row */

procedure LOAD_ROW (
  P_COMPONENT_ID        IN NUMBER,
  P_created_by          IN NUMBER ,
  P_creation_date       IN DATE ,
  P_last_updated_by     IN NUMBER,
  P_last_update_date    IN DATE,
  P_last_update_login   IN NUMBER,
  P_COMPONENT_TYPE      IN VARCHAR2,
  P_COMPONENT_NAME      IN VARCHAR2,
  P_MANDATORY_FLAG      IN VARCHAR2 := 'N',
  P_RESPONSE_TYPE       IN VARCHAR2 := NULL,
  P_DESCRIPTION         IN VARCHAR2 := NULL,
  P_INSTRUCTION         IN VARCHAR2 := NULL,
  P_CONTEXT             IN VARCHAR2 := NULL,
  P_ATTRIBUTE1          IN VARCHAR2 := NULL,
  P_ATTRIBUTE2          IN VARCHAR2 := NULL,
  P_ATTRIBUTE3          IN VARCHAR2 := NULL,
  P_ATTRIBUTE4          IN VARCHAR2 := NULL,
  P_ATTRIBUTE5          IN VARCHAR2 := NULL,
  P_ATTRIBUTE6          IN VARCHAR2 := NULL,
  P_ATTRIBUTE7          IN VARCHAR2 := NULL,
  P_ATTRIBUTE8          IN VARCHAR2 := NULL,
  P_ATTRIBUTE9          IN VARCHAR2 := NULL,
  P_ATTRIBUTE10         IN VARCHAR2 := NULL,
  P_ATTRIBUTE11         IN VARCHAR2 := NULL,
  P_ATTRIBUTE12         IN VARCHAR2 := NULL,
  P_ATTRIBUTE13         IN VARCHAR2 := NULL,
  P_ATTRIBUTE14         IN VARCHAR2 := NULL,
  P_ATTRIBUTE15         IN VARCHAR2 := NULL,
  P_ATTRIBUTE16         IN VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE17         IN VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE18         IN VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE19         IN VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE20         IN VARCHAR2 DEFAULT NULL,
  X_OWNER               IN VARCHAR2)

IS

begin

  declare
     user_id            number := 0;
     row_id             varchar2(64);
     l_component_id NUMBER := p_component_id;

  begin

     if (X_OWNER = 'SEED') then
        user_id := -1;
     end if;

ASO_SUP_COMPONENT_PKG.UPDATE_ROW (
  P_COMPONENT_ID => P_COMPONENT_ID,
  P_LAST_UPDATE_DATE => sysdate,
  P_LAST_UPDATED_BY => user_id,
  P_LAST_UPDATE_LOGIN => 0,
  P_COMPONENT_TYPE => P_COMPONENT_TYPE,
  P_COMPONENT_NAME => P_COMPONENT_NAME,
  P_MANDATORY_FLAG => P_MANDATORY_FLAG,
  P_RESPONSE_TYPE  => P_RESPONSE_TYPE,
  P_DESCRIPTION    => P_DESCRIPTION,
  P_INSTRUCTION    => P_INSTRUCTION,
  p_context    => P_context,
  P_ATTRIBUTE1 => P_ATTRIBUTE1,
  P_ATTRIBUTE2 => P_ATTRIBUTE2,
  P_ATTRIBUTE3 => P_ATTRIBUTE3,
  P_ATTRIBUTE4 => P_ATTRIBUTE4,
  P_ATTRIBUTE5 => P_ATTRIBUTE5,
  P_ATTRIBUTE6 => P_ATTRIBUTE6,
  P_ATTRIBUTE7 => P_ATTRIBUTE7,
  P_ATTRIBUTE8 => P_ATTRIBUTE8,
  P_ATTRIBUTE9 => P_ATTRIBUTE9,
  P_ATTRIBUTE10 => P_ATTRIBUTE10,
  P_ATTRIBUTE11 => P_ATTRIBUTE11,
  P_ATTRIBUTE12 => P_ATTRIBUTE12,
  P_ATTRIBUTE13 => P_ATTRIBUTE13,
  P_ATTRIBUTE14 => P_ATTRIBUTE14,
  P_ATTRIBUTE15 => P_ATTRIBUTE15,
  P_ATTRIBUTE16 => P_ATTRIBUTE16,
  P_ATTRIBUTE17 => P_ATTRIBUTE17,
  P_ATTRIBUTE18 => P_ATTRIBUTE18,
  P_ATTRIBUTE19 => P_ATTRIBUTE19,
  P_ATTRIBUTE20 => P_ATTRIBUTE20
  );

 exception

   when NO_DATA_FOUND then

 ASO_SUP_COMPONENT_PKG.INSERT_ROW (
  PX_ROWID => row_id,
  PX_COMPONENT_ID => L_COMPONENT_ID,
  P_CREATION_DATE => sysdate,
  P_CREATED_BY => user_id,
  P_LAST_UPDATE_DATE => sysdate,
  P_LAST_UPDATED_BY => user_id,
  P_LAST_UPDATE_LOGIN => 0,
  P_COMPONENT_TYPE  => P_COMPONENT_TYPE,
  P_COMPONENT_NAME  => P_COMPONENT_NAME,
  P_MANDATORY_FLAG  => P_MANDATORY_FLAG,
  P_RESPONSE_TYPE   => P_RESPONSE_TYPE,
  P_DESCRIPTION     => P_DESCRIPTION,
  P_INSTRUCTION     => P_INSTRUCTION,
  p_context    => P_context,
  P_ATTRIBUTE1 => P_ATTRIBUTE1,
  P_ATTRIBUTE2 => P_ATTRIBUTE2,
  P_ATTRIBUTE3 => P_ATTRIBUTE3,
  P_ATTRIBUTE4 => P_ATTRIBUTE4,
  P_ATTRIBUTE5 => P_ATTRIBUTE5,
  P_ATTRIBUTE6 => P_ATTRIBUTE6,
  P_ATTRIBUTE7 => P_ATTRIBUTE7,
  P_ATTRIBUTE8 => P_ATTRIBUTE8,
  P_ATTRIBUTE9 => P_ATTRIBUTE9,
  P_ATTRIBUTE10 => P_ATTRIBUTE10,
  P_ATTRIBUTE11 => P_ATTRIBUTE11,
  P_ATTRIBUTE12 => P_ATTRIBUTE12,
  P_ATTRIBUTE13 => P_ATTRIBUTE13,
  P_ATTRIBUTE14 => P_ATTRIBUTE14,
  P_ATTRIBUTE15 => P_ATTRIBUTE15,
  P_ATTRIBUTE16 => P_ATTRIBUTE16,
  P_ATTRIBUTE17 => P_ATTRIBUTE17,
  P_ATTRIBUTE18 => P_ATTRIBUTE18,
  P_ATTRIBUTE19 => P_ATTRIBUTE19,
  P_ATTRIBUTE20 => P_ATTRIBUTE20
  );
 end;

end LOAD_ROW;

/* Translation procedure */

procedure TRANSLATE_ROW (
   P_COMPONENT_ID IN NUMBER,
   P_COMPONENT_NAME IN VARCHAR2,
   P_DESCRIPTION in VARCHAR2,
   P_INSTRUCTION IN VARCHAR2,
   X_OWNER in VARCHAR2)

IS
 l_user_id     number := 0;
begin

    l_user_id  := fnd_load_util.owner_id(X_OWNER);

    update ASO_SUP_COMPONENT_TL
    set  COMPONENT_NAME = P_COMPONENT_NAME,
         DESCRIPTION = P_DESCRIPTION,
         INSTRUCTION = P_INSTRUCTION,
         source_lang = userenv('LANG'),
         last_update_date = sysdate,
         last_updated_by = l_user_id,
         last_update_login = 0
    where COMPONENT_ID = P_COMPONENT_ID
    and userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;


PROCEDURE LOAD_SEED_ROW  (
 P_COMPONENT_ID             IN NUMBER,
 P_COMPONENT_TYPE           IN VARCHAR2,
 P_COMPONENT_NAME           IN VARCHAR2,
 P_MANDATORY_FLAG           IN VARCHAR2,
 P_RESPONSE_TYPE            IN VARCHAR2,
 P_DESCRIPTION              IN VARCHAR2,
 P_INSTRUCTION              IN VARCHAR2,
 P_COMP_DISPLAY_SEQUENCE    IN NUMBER,
 P_COMP_SECTION_ID          IN NUMBER,
 P_PRESENTATION_STYLE       IN VARCHAR2,
 P_SECTION_COMPONENT_TYPE   IN VARCHAR2,
 P_Child_component_id       IN NUMBER,
 P_Sub_Section_id           IN NUMBER,
 P_Default_Response_id      IN NUMBER,
  p_context                  IN VARCHAR2,
  P_OWNER                    IN VARCHAR2,
  P_UPLOAD_MODE              IN VARCHAR2,
  P_ATTRIBUTE1               IN VARCHAR2,
  P_ATTRIBUTE2               IN VARCHAR2,
  P_ATTRIBUTE3               IN VARCHAR2,
  P_ATTRIBUTE4               IN VARCHAR2,
  P_ATTRIBUTE5               IN VARCHAR2,
  P_ATTRIBUTE6               IN VARCHAR2,
  P_ATTRIBUTE7               IN VARCHAR2,
  P_ATTRIBUTE8               IN VARCHAR2,
  P_ATTRIBUTE9               IN VARCHAR2,
  P_ATTRIBUTE10              IN VARCHAR2,
  P_ATTRIBUTE11              IN VARCHAR2,
  P_ATTRIBUTE12              IN VARCHAR2,
  P_ATTRIBUTE13              IN VARCHAR2,
  P_ATTRIBUTE14              IN VARCHAR2,
  P_ATTRIBUTE15              IN VARCHAR2,
  P_ATTRIBUTE16              IN VARCHAR2,
  P_ATTRIBUTE17              IN VARCHAR2,
  P_ATTRIBUTE18              IN VARCHAR2,
  P_ATTRIBUTE19              IN VARCHAR2,
  P_ATTRIBUTE20              IN VARCHAR2
  )

is
 l_user_id	number := 0;
 l_COMPONENT_ID NUMBER;
 l_SECT_COMP_MAP_ID NUMBER;
 row_id VARCHAR2(32767);
 row_id1 VARCHAR2(32767);

 cursor get_components is
 SELECT COMPONENT_ID
 FROM ASO_SUP_COMPONENT_TL
 WHERE COMPONENT_ID = P_COMPONENT_ID;

 cursor get_mappings is
 select sect_comp_map_id
 from aso_sup_sect_comp_map
 where section_id = P_COMP_SECTION_ID
 and component_id = P_COMPONENT_ID;

 begin
      if (P_UPLOAD_MODE = 'NLS') then

             ASO_SUP_COMPONENT_PKG.TRANSLATE_ROW (
                 P_COMPONENT_ID    => P_COMPONENT_ID,
                 P_COMPONENT_NAME  => P_COMPONENT_NAME,
                 P_DESCRIPTION     => P_DESCRIPTION,
                 P_INSTRUCTION     => P_INSTRUCTION,
                 X_OWNER           => P_OWNER) ;

	 else


          if ( fnd_load_util.owner_id(P_OWNER) = 120 ) then

           l_user_id  := fnd_load_util.owner_id(P_OWNER);

         open get_components;
         loop
          fetch get_components into l_COMPONENT_ID;
          if get_components%FOUND THEN
          -- this means component already exists
           ASO_SUP_COMPONENT_PKG.UPDATE_ROW (
             P_COMPONENT_ID            => P_COMPONENT_ID,
             P_LAST_UPDATE_DATE         => sysdate ,
             P_LAST_UPDATED_BY          => l_user_id ,
             P_LAST_UPDATE_LOGIN        => l_user_id ,
             P_COMPONENT_TYPE           => P_COMPONENT_TYPE,
             P_COMPONENT_NAME           => P_COMPONENT_NAME,
             P_MANDATORY_FLAG           => P_MANDATORY_FLAG,
             P_RESPONSE_TYPE            => P_RESPONSE_TYPE,
             P_DESCRIPTION              => P_DESCRIPTION,
             P_INSTRUCTION              => P_INSTRUCTION,
             p_context                  => P_CONTEXT,
             P_ATTRIBUTE1               => P_ATTRIBUTE1,
             P_ATTRIBUTE2               => P_ATTRIBUTE2,
             P_ATTRIBUTE3               => P_ATTRIBUTE3,
             P_ATTRIBUTE4               => P_ATTRIBUTE4,
             P_ATTRIBUTE5               => P_ATTRIBUTE5,
             P_ATTRIBUTE6               => P_ATTRIBUTE6,
             P_ATTRIBUTE7               => P_ATTRIBUTE7,
             P_ATTRIBUTE8               => P_ATTRIBUTE8,
             P_ATTRIBUTE9               => P_ATTRIBUTE9,
             P_ATTRIBUTE10              => P_ATTRIBUTE10,
             P_ATTRIBUTE11              => P_ATTRIBUTE11,
             P_ATTRIBUTE12              => P_ATTRIBUTE12,
             P_ATTRIBUTE13              => P_ATTRIBUTE13,
             P_ATTRIBUTE14              => P_ATTRIBUTE14,
             P_ATTRIBUTE15              => P_ATTRIBUTE15,
             P_ATTRIBUTE16              => P_ATTRIBUTE16,
             P_ATTRIBUTE17              => P_ATTRIBUTE17,
             P_ATTRIBUTE18              => P_ATTRIBUTE18,
             P_ATTRIBUTE19              => P_ATTRIBUTE19,
             P_ATTRIBUTE20              => P_ATTRIBUTE20
              );
             exit;
             elsif get_components%NOTFOUND THEN
             -- THIS MEANS THIS IS A NEW COMPONENT
             l_COMPONENT_ID := P_COMPONENT_ID;
             ASO_SUP_COMPONENT_PKG.INSERT_ROW (
             PX_ROWID                   => row_id,
             PX_COMPONENT_ID            => l_COMPONENT_ID,
             P_CREATION_DATE            => sysdate ,
             P_CREATED_BY               => l_user_id ,
             P_LAST_UPDATE_DATE         => sysdate ,
             P_LAST_UPDATED_BY          => l_user_id ,
             P_LAST_UPDATE_LOGIN        => l_user_id ,
             P_COMPONENT_TYPE           => P_COMPONENT_TYPE,
             P_COMPONENT_NAME           => P_COMPONENT_NAME,
             P_MANDATORY_FLAG           => P_MANDATORY_FLAG,
             P_RESPONSE_TYPE            => P_RESPONSE_TYPE,
             P_DESCRIPTION              => P_DESCRIPTION,
             P_INSTRUCTION              => P_INSTRUCTION,
             p_context                  => P_CONTEXT,
             P_ATTRIBUTE1               => P_ATTRIBUTE1,
             P_ATTRIBUTE2               => P_ATTRIBUTE2,
             P_ATTRIBUTE3               => P_ATTRIBUTE3,
             P_ATTRIBUTE4               => P_ATTRIBUTE4,
             P_ATTRIBUTE5               => P_ATTRIBUTE5,
             P_ATTRIBUTE6               => P_ATTRIBUTE6,
             P_ATTRIBUTE7               => P_ATTRIBUTE7,
             P_ATTRIBUTE8               => P_ATTRIBUTE8,
             P_ATTRIBUTE9               => P_ATTRIBUTE9,
             P_ATTRIBUTE10              => P_ATTRIBUTE10,
             P_ATTRIBUTE11              => P_ATTRIBUTE11,
             P_ATTRIBUTE12              => P_ATTRIBUTE12,
             P_ATTRIBUTE13              => P_ATTRIBUTE13,
             P_ATTRIBUTE14              => P_ATTRIBUTE14,
             P_ATTRIBUTE15              => P_ATTRIBUTE15,
             P_ATTRIBUTE16              => P_ATTRIBUTE16,
             P_ATTRIBUTE17              => P_ATTRIBUTE17,
             P_ATTRIBUTE18              => P_ATTRIBUTE18,
             P_ATTRIBUTE19              => P_ATTRIBUTE19,
             P_ATTRIBUTE20              => P_ATTRIBUTE20
              );
             exit;
             end if;
             end loop;
             close get_components;

             open get_mappings;
             loop
             fetch get_mappings into l_SECT_COMP_MAP_ID;
             if get_mappings%FOUND THEN
             -- this means the component has already been used in this section
                ASO_SUP_SECT_COMP_MAP_PKG.UPDATE_ROW (
                    P_SECT_COMP_MAP_ID        => l_SECT_COMP_MAP_ID ,
                    P_LAST_UPDATE_DATE         => sysdate ,
                    P_LAST_UPDATED_BY          => l_user_id ,
                    P_LAST_UPDATE_LOGIN        => l_user_id ,
                    P_SECTION_ID               => P_COMP_SECTION_ID,
                    P_DISPLAY_SEQUENCE         => P_COMP_DISPLAY_SEQUENCE,
                    P_COMPONENT_ID             => P_COMPONENT_ID,
                    P_PRESENTATION_STYLE       => P_PRESENTATION_STYLE,
                    P_SECTION_COMPONENT_TYPE   => P_SECTION_COMPONENT_TYPE,
                    P_Child_component_id       => P_CHILD_COMPONENT_ID,
                    P_Sub_Section_id           => P_SUB_SECTION_ID,
                    P_Default_Response_id      => P_DEFAULT_RESPONSE_ID,
                    p_context                  => P_CONTEXT,
                    P_ATTRIBUTE1               => P_ATTRIBUTE1,
                    P_ATTRIBUTE2               => P_ATTRIBUTE2,
                    P_ATTRIBUTE3               => P_ATTRIBUTE3,
                    P_ATTRIBUTE4               => P_ATTRIBUTE4,
                    P_ATTRIBUTE5               => P_ATTRIBUTE5,
                    P_ATTRIBUTE6               => P_ATTRIBUTE6,
                    P_ATTRIBUTE7               => P_ATTRIBUTE7,
                    P_ATTRIBUTE8               => P_ATTRIBUTE8,
                    P_ATTRIBUTE9               => P_ATTRIBUTE9,
                    P_ATTRIBUTE10              => P_ATTRIBUTE10,
                    P_ATTRIBUTE11              => P_ATTRIBUTE11,
                    P_ATTRIBUTE12              => P_ATTRIBUTE12,
                    P_ATTRIBUTE13              => P_ATTRIBUTE13,
                    P_ATTRIBUTE14              => P_ATTRIBUTE14,
                    P_ATTRIBUTE15              => P_ATTRIBUTE15,
                    P_ATTRIBUTE16              => P_ATTRIBUTE16,
                    P_ATTRIBUTE17              => P_ATTRIBUTE17,
                    P_ATTRIBUTE18              => P_ATTRIBUTE18,
                    P_ATTRIBUTE19              => P_ATTRIBUTE19,
                    P_ATTRIBUTE20              => P_ATTRIBUTE20
                   );
                   exit;
             elsif get_mappings%NOTFOUND THEN
             -- this means the component has NOT been used in this section

                ASO_SUP_SECT_COMP_MAP_PKG.INSERT_ROW (
                    PX_ROWID                   => row_id1,
                    PX_SECT_COMP_MAP_ID        => l_SECT_COMP_MAP_ID ,
                    P_CREATION_DATE            => sysdate ,
                    P_CREATED_BY               => l_user_id ,
                    P_LAST_UPDATE_DATE         => sysdate ,
                    P_LAST_UPDATED_BY          => l_user_id ,
                    P_LAST_UPDATE_LOGIN        => l_user_id ,
                    P_SECTION_ID               => P_COMP_SECTION_ID,
                    P_DISPLAY_SEQUENCE         => P_COMP_DISPLAY_SEQUENCE,
                    P_COMPONENT_ID             => P_COMPONENT_ID,
                    P_PRESENTATION_STYLE       => P_PRESENTATION_STYLE,
                    P_SECTION_COMPONENT_TYPE   => P_SECTION_COMPONENT_TYPE,
                    P_Child_component_id       => P_CHILD_COMPONENT_ID,
                    P_Sub_Section_id           => P_SUB_SECTION_ID,
                    P_Default_Response_id      => P_DEFAULT_RESPONSE_ID,
                    p_context                  => P_CONTEXT,
                    P_ATTRIBUTE1               => P_ATTRIBUTE1,
                    P_ATTRIBUTE2               => P_ATTRIBUTE2,
                    P_ATTRIBUTE3               => P_ATTRIBUTE3,
                    P_ATTRIBUTE4               => P_ATTRIBUTE4,
                    P_ATTRIBUTE5               => P_ATTRIBUTE5,
                    P_ATTRIBUTE6               => P_ATTRIBUTE6,
                    P_ATTRIBUTE7               => P_ATTRIBUTE7,
                    P_ATTRIBUTE8               => P_ATTRIBUTE8,
                    P_ATTRIBUTE9               => P_ATTRIBUTE9,
                    P_ATTRIBUTE10              => P_ATTRIBUTE10,
                    P_ATTRIBUTE11              => P_ATTRIBUTE11,
                    P_ATTRIBUTE12              => P_ATTRIBUTE12,
                    P_ATTRIBUTE13              => P_ATTRIBUTE13,
                    P_ATTRIBUTE14              => P_ATTRIBUTE14,
                    P_ATTRIBUTE15              => P_ATTRIBUTE15,
                    P_ATTRIBUTE16              => P_ATTRIBUTE16,
                    P_ATTRIBUTE17              => P_ATTRIBUTE17,
                    P_ATTRIBUTE18              => P_ATTRIBUTE18,
                    P_ATTRIBUTE19              => P_ATTRIBUTE19,
                    P_ATTRIBUTE20              => P_ATTRIBUTE20
                   );
                EXIT;
                end if;
                end loop;
                close get_mappings;
          end if;
       end if; -- end if for the NLS check
END LOAD_SEED_ROW;


END; -- Package Body ASO_SUP_COMPONENT_PKG

/
