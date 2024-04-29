--------------------------------------------------------
--  DDL for Package Body ASO_SUP_TEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_SUP_TEMPLATE_PKG" AS
/* $Header: asosptmb.pls 120.4.12010000.3 2015/02/10 08:52:38 akushwah ship $*/

/* procedure to insert INSERT_ROW */

PROCEDURE INSERT_ROW
(
  PX_ROWID              IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  PX_TEMPLATE_ID        IN OUT NOCOPY /* file.sql.39 change */  NUMBER,
  P_created_by          IN NUMBER ,
  P_creation_date       IN DATE ,
  P_last_updated_by     IN NUMBER,
  P_last_update_date    IN DATE,
  P_last_update_login   IN NUMBER,
  P_TEMPLATE_NAME       IN VARCHAR2,
  P_DESCRIPTION         IN VARCHAR2 := NULL,
  P_TEMPLATE_LEVEL      IN VARCHAR2,
  P_TEMPLATE_CONTEXT    IN VARCHAR2,
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
    from  ASO_SUP_TEMPLATE_B
    where  TEMPLATE_ID = PX_TEMPLATE_ID ;

  cursor CU_TEMPLATE_ID IS
    select ASO_SUP_TEMPLATE_B_S.NEXTVAL from sys.dual;

Begin

  IF (PX_TEMPLATE_ID IS NULL) OR (PX_TEMPLATE_ID = FND_API.G_MISS_NUM) THEN
      OPEN CU_TEMPLATE_ID;
      FETCH CU_TEMPLATE_ID INTO PX_TEMPLATE_ID;
      CLOSE CU_TEMPLATE_ID;

  END IF;

  -- added new column as per bug 2940126

  insert into ASO_SUP_TEMPLATE_B (
  TEMPLATE_ID,
  created_by  ,
  creation_date ,
  last_updated_by ,
  last_update_date ,
  last_update_login ,
  TEMPLATE_LEVEL,
  TEMPLATE_CONTEXT,
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
  PX_TEMPLATE_ID,
  P_created_by  ,
  P_creation_date ,
  P_last_updated_by ,
  P_last_update_date ,
  P_last_update_login,
  P_TEMPLATE_LEVEL,
  P_TEMPLATE_CONTEXT,
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
  P_ATTRIBUTE16,
  P_ATTRIBUTE17,
  P_ATTRIBUTE18,
  P_ATTRIBUTE19,
  P_ATTRIBUTE20
  );

  insert into ASO_SUP_TEMPLATE_TL (
    TEMPLATE_ID,
    LANGUAGE,
    SOURCE_LANG,
    TEMPLATE_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN
  ) select
    PX_TEMPLATE_ID,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    P_TEMPLATE_NAME,
    P_DESCRIPTION,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    P_CREATION_DATE,
    P_CREATED_BY,
    P_LAST_UPDATE_LOGIN
  from  FND_LANGUAGES  L
  where  L.INSTALLED_FLAG in ('I', 'B')
  and  not exists
         ( select 'x'
           from  ASO_SUP_TEMPLATE_TL  T
           where  T.TEMPLATE_ID = PX_TEMPLATE_ID
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
  P_TEMPLATE_ID        IN NUMBER,
  P_last_updated_by     IN NUMBER,
  P_last_update_date    IN DATE,
  P_last_update_login   IN NUMBER,
  P_TEMPLATE_NAME      IN VARCHAR2,
  P_DESCRIPTION         IN VARCHAR2,
  P_TEMPLATE_LEVEL      IN VARCHAR2,
  P_TEMPLATE_CONTEXT    IN VARCHAR2,
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
  P_ATTRIBUTE16         IN VARCHAR2,
  P_ATTRIBUTE17         IN VARCHAR2,
  P_ATTRIBUTE18         IN VARCHAR2,
  P_ATTRIBUTE19         IN VARCHAR2,
  P_ATTRIBUTE20         IN VARCHAR2

)

IS

Begin
   -- added new column as per bug 2940126
  update ASO_SUP_TEMPLATE_B
  set
  last_updated_by = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
  last_update_date = ASO_UTILITY_PVT.decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
  last_update_login = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
  template_level =   decode(P_TEMPLATE_LEVEL,FND_API.G_MISS_CHAR, template_level,P_TEMPLATE_LEVEL),
  template_context = decode(P_TEMPLATE_CONTEXT,FND_API.G_MISS_CHAR,template_context,P_TEMPLATE_CONTEXT),
  context = decode(P_context,FND_API.G_MISS_CHAR,context,P_context),
  ATTRIBUTE1 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, ATTRIBUTE1, p_ATTRIBUTE1),
  ATTRIBUTE2 = decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, ATTRIBUTE2, p_ATTRIBUTE2),
  ATTRIBUTE3 = decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, ATTRIBUTE3, p_ATTRIBUTE3),
  ATTRIBUTE4 = decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, ATTRIBUTE4, p_ATTRIBUTE4),
  ATTRIBUTE5 = decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, ATTRIBUTE5, p_ATTRIBUTE5),
  ATTRIBUTE6 = decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, ATTRIBUTE6, p_ATTRIBUTE6),
  ATTRIBUTE7 = decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, ATTRIBUTE7, p_ATTRIBUTE7),
  ATTRIBUTE8 = decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, ATTRIBUTE8, p_ATTRIBUTE8),
  ATTRIBUTE9 = decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, ATTRIBUTE9, p_ATTRIBUTE9),
  ATTRIBUTE10 = decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, ATTRIBUTE10, p_ATTRIBUTE10),
  ATTRIBUTE11 = decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, ATTRIBUTE11, p_ATTRIBUTE11),
  ATTRIBUTE12 = decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, ATTRIBUTE12, p_ATTRIBUTE12),
  ATTRIBUTE13 = decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, ATTRIBUTE13, p_ATTRIBUTE13),
  ATTRIBUTE14 = decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, ATTRIBUTE14, p_ATTRIBUTE14),
  ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, p_ATTRIBUTE15),
  ATTRIBUTE16 = decode( p_ATTRIBUTE16, FND_API.G_MISS_CHAR, ATTRIBUTE16, p_ATTRIBUTE16),
  ATTRIBUTE17 = decode( p_ATTRIBUTE17, FND_API.G_MISS_CHAR, ATTRIBUTE17, p_ATTRIBUTE17),
  ATTRIBUTE18 = decode( p_ATTRIBUTE18, FND_API.G_MISS_CHAR, ATTRIBUTE18, p_ATTRIBUTE18),
  ATTRIBUTE19 = decode( p_ATTRIBUTE19, FND_API.G_MISS_CHAR, ATTRIBUTE19, p_ATTRIBUTE19),
  ATTRIBUTE20 = decode( p_ATTRIBUTE20, FND_API.G_MISS_CHAR, ATTRIBUTE20, p_ATTRIBUTE20)
where  TEMPLATE_ID = P_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

update ASO_SUP_TEMPLATE_TL
 set
  TEMPLATE_NAME = decode(P_TEMPLATE_NAME,FND_API.G_MISS_CHAR,template_name,P_TEMPLATE_NAME),
  DESCRIPTION    = decode(P_DESCRIPTION,FND_API.G_MISS_CHAR,description,P_DESCRIPTION),
  LAST_UPDATE_DATE = ASO_UTILITY_PVT.decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
  LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
  LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
  SOURCE_LANG = userenv('LANG')
where  TEMPLATE_ID = P_TEMPLATE_ID
    and  userenv('LANG') in (LANGUAGE, SOURCE_LANG) ;

  if (sql%notfound) then
    raise no_data_found;
  end if;


End UPDATE_ROW;


procedure DELETE_ROW (
  P_TEMPLATE_ID IN NUMBER

)

IS

Begin

 delete from ASO_SUP_TEMPLATE_TL
  where  TEMPLATE_ID = P_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;


  delete from ASO_SUP_TEMPLATE_B
  where  TEMPLATE_ID = P_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

End Delete_row;

PROCEDURE LOCK_ROW
(
  P_TEMPLATE_ID        IN NUMBER,
  P_created_by          IN NUMBER ,
  P_creation_date       IN DATE ,
  P_last_updated_by     IN NUMBER,
  P_last_update_date    IN DATE,
  P_last_update_login   IN NUMBER,
  P_TEMPLATE_NAME      IN VARCHAR2,
  P_DESCRIPTION         IN VARCHAR2,
  P_TEMPLATE_LEVEL     IN VARCHAR2,
  P_TEMPLATE_CONTEXT    IN VARCHAR2,
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
  -- Start : code change done for Bug 20470801
  P_ATTRIBUTE16		IN VARCHAR2,
  P_ATTRIBUTE17		IN VARCHAR2,
  P_ATTRIBUTE18		IN VARCHAR2,
  P_ATTRIBUTE19		IN VARCHAR2,
  P_ATTRIBUTE20		IN VARCHAR2
  -- End : code change done for Bug 20470801

)

IS

CURSOR i_csr is
SELECT
  a.TEMPLATE_ID ,
  created_by  ,
  creation_date ,
  last_updated_by ,
  last_update_date ,
  last_update_login ,
  template_level,
  template_context,
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
  ATTRIBUTE15 ,
  -- Start : code change done for Bug 20470801
  ATTRIBUTE16 ,
  ATTRIBUTE17 ,
  ATTRIBUTE18 ,
  ATTRIBUTE19 ,
  ATTRIBUTE20
  -- End : code change done for Bug 20470801

 from  ASO_SUP_TEMPLATE_B a
 where a.TEMPLATE_ID = P_TEMPLATE_ID
 for update of a.TEMPLATE_ID nowait;

recinfo i_csr%rowtype;

  cursor c1 is
    select
      TEMPLATE_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from  ASO_SUP_TEMPLATE_TL
    where TEMPLATE_ID = P_TEMPLATE_ID
    for update of TEMPLATE_ID nowait;

  l_Item_ID         NUMBER ;
  l_Org_ID          NUMBER ;

  l_return_status   VARCHAR2(1) ;

  -- Start : code change done for Bug 20470801
  Cursor C_Template_level Is
  Select Template_level
  From aso_sup_template_vl
  Where template_id = P_TEMPLATE_ID;

  l_Template_level varchar2(100);
  -- End : code change done for Bug 20470801

BEGIN


  l_Item_ID := P_TEMPLATE_ID ;

  open i_csr;

  fetch i_csr into recinfo;

  if (i_csr%notfound) then
    close i_csr;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;

  close i_csr;

  -- Start : code change done for Bug 20470801
  If P_TEMPLATE_LEVEL Is Null Then
     Open C_Template_level;
     Fetch C_Template_level Into l_Template_level;
     Close C_Template_level;
  Else
     l_Template_level := P_TEMPLATE_LEVEL;
  End If;
  -- End : code change done for Bug 20470801

-- Do not compare to the B table column;
-- only compare to TL column (c1 cursor below).

  if (
          ((recinfo.TEMPLATE_ID = P_TEMPLATE_ID)
           OR ((recinfo.TEMPLATE_ID is null) AND (P_TEMPLATE_ID is null)))
      AND ((recinfo.CREATED_BY = P_CREATED_BY)
           OR ((recinfo.CREATED_BY is null) AND (P_CREATED_BY is null)))

      -- Start : code change done for Bug 20470801
      /* AND ((recinfo.CREATION_DATE = P_CREATION_DATE)
           OR ((recinfo.CREATION_DATE is null) AND (P_CREATION_DATE is null))) */
      AND ((TRUNC(recinfo.CREATION_DATE) = TRUNC(P_CREATION_DATE))
           OR ((recinfo.CREATION_DATE is null) AND (P_CREATION_DATE is null)))
      -- End : code change done for Bug 20470801

      AND ((recinfo.LAST_UPDATED_BY = P_LAST_UPDATED_BY)
           OR ((recinfo.LAST_UPDATED_BY is null) AND (P_LAST_UPDATED_BY is null)))

      -- Start : code change done for Bug 20470801
      /* AND ((recinfo.LAST_UPDATE_DATE = P_LAST_UPDATE_DATE)
           OR ((recinfo.LAST_UPDATE_DATE is null) AND (P_LAST_UPDATE_DATE is null))) */
      AND ((TRUNC(recinfo.LAST_UPDATE_DATE) = TRUNC(P_LAST_UPDATE_DATE))
           OR ((recinfo.LAST_UPDATE_DATE is null) AND (P_LAST_UPDATE_DATE is null)))
      -- End : code change done for Bug 20470801

      AND ((recinfo.LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN)
           OR ((recinfo.LAST_UPDATE_LOGIN is null) AND (P_LAST_UPDATE_LOGIN is null)))

      -- Start : code change done for Bug 20470801
      /* -- added new column as per bug 2940126
	 AND ((recinfo.TEMPLATE_LEVEL  = P_TEMPLATE_LEVEL )
	  OR ((recinfo.TEMPLATE_LEVEL  is null) AND (P_TEMPLATE_LEVEL  is null))) */

      AND ((recinfo.TEMPLATE_LEVEL  = l_Template_level )
       OR ((recinfo.TEMPLATE_LEVEL  is null) AND (l_Template_level is null)))
      -- End : code change done for Bug 20470801

      AND ((recinfo.TEMPLATE_CONTEXT  = P_TEMPLATE_CONTEXT )
       OR ((recinfo.TEMPLATE_CONTEXT  is null) AND (P_TEMPLATE_CONTEXT  is null)))


	 AND ((recinfo.CONTEXT = P_CONTEXT)
           OR ((recinfo.CONTEXT is null) AND (P_CONTEXT is null)))
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
      -- Start : code change done for Bug 20470801
      AND ((recinfo.ATTRIBUTE16 = P_ATTRIBUTE16)
           OR ((recinfo.ATTRIBUTE16 is null) AND (P_ATTRIBUTE16 is null)))
      AND ((recinfo.ATTRIBUTE17 = P_ATTRIBUTE17)
           OR ((recinfo.ATTRIBUTE17 is null) AND (P_ATTRIBUTE17 is null)))
      AND ((recinfo.ATTRIBUTE18 = P_ATTRIBUTE18)
           OR ((recinfo.ATTRIBUTE18 is null) AND (P_ATTRIBUTE18 is null)))
      AND ((recinfo.ATTRIBUTE19 = P_ATTRIBUTE19)
           OR ((recinfo.ATTRIBUTE19 is null) AND (P_ATTRIBUTE19 is null)))
      AND ((recinfo.ATTRIBUTE20 = P_ATTRIBUTE20)
           OR ((recinfo.ATTRIBUTE20 is null) AND (P_ATTRIBUTE20 is null)))
      -- End : code change done for Bug 20470801
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.TEMPLATE_NAME = P_TEMPLATE_NAME)
               OR ((tlinfo.TEMPLATE_NAME is null) AND (P_TEMPLATE_NAME is null)))
           AND ((tlinfo.DESCRIPTION = P_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (P_DESCRIPTION is null)))

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

  delete from ASO_SUP_TEMPLATE_TL T
  where not exists
        ( select NULL
          from  ASO_SUP_TEMPLATE_B  B
          where  B.TEMPLATE_ID = T.TEMPLATE_ID
        );

  update ASO_SUP_TEMPLATE_TL T set (
      TEMPLATE_NAME,
      DESCRIPTION
    ) = ( select
      B.TEMPLATE_NAME,
      B.DESCRIPTION
    from  ASO_SUP_TEMPLATE_TL  B
    where  B.TEMPLATE_ID = T.TEMPLATE_ID
      and  B.LANGUAGE = T.SOURCE_LANG )
  where (
      T.TEMPLATE_ID,
      T.LANGUAGE
  ) in ( select
      SUBT.TEMPLATE_ID,
      SUBT.LANGUAGE
    from  ASO_SUP_TEMPLATE_TL  SUBB,
          ASO_SUP_TEMPLATE_TL  SUBT
    where  SUBB.TEMPLATE_ID = SUBT.TEMPLATE_ID
      and  SUBB.LANGUAGE = SUBT.SOURCE_LANG
      and  ( SUBB.TEMPLATE_NAME <> SUBT.TEMPLATE_NAME
           or ( SUBB.TEMPLATE_NAME is null     and SUBT.TEMPLATE_NAME is not null )
           or ( SUBB.TEMPLATE_NAME is not null and SUBT.TEMPLATE_NAME is null ) )
      and  ( SUBB.DESCRIPTION <> SUBT.DESCRIPTION
           or ( SUBB.DESCRIPTION is null     and SUBT.DESCRIPTION is not null )
           or ( SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null ) )

    );

  insert into ASO_SUP_TEMPLATE_TL (
    TEMPLATE_ID,
    LANGUAGE,
    SOURCE_LANG,
    TEMPLATE_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN
  ) select
    B.TEMPLATE_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG,
    B.TEMPLATE_NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN
  from  ASO_SUP_TEMPLATE_TL    B,
        FND_LANGUAGES        L
  where  L.INSTALLED_FLAG in ('I', 'B')
    and  B.LANGUAGE = userenv('LANG')
    and  not exists
         ( select NULL
           from  ASO_SUP_TEMPLATE_TL  T
           where  T.TEMPLATE_ID = B.TEMPLATE_ID
             and  T.LANGUAGE = L.LANGUAGE_CODE );

end ADD_LANGUAGE;


/* Procedure for Load_Row */

procedure LOAD_ROW (
  P_TEMPLATE_ID        IN NUMBER,
  P_created_by          IN NUMBER ,
  P_creation_date       IN DATE ,
  P_last_updated_by     IN NUMBER,
  P_last_update_date    IN DATE,
  P_last_update_login   IN NUMBER,
  P_TEMPLATE_NAME      IN VARCHAR2,
  P_DESCRIPTION         IN VARCHAR2,
  P_TEMPLATE_LEVEL      IN VARCHAR2,
  P_TEMPLATE_CONTEXT    IN VARCHAR2,
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
  P_ATTRIBUTE16         IN VARCHAR2,
  P_ATTRIBUTE17         IN VARCHAR2,
  P_ATTRIBUTE18         IN VARCHAR2,
  P_ATTRIBUTE19         IN VARCHAR2,
  P_ATTRIBUTE20         IN VARCHAR2,
  X_OWNER               IN VARCHAR2)

IS

begin

  declare
     user_id            number := 0;
     row_id             varchar2(64);
     l_TEMPLATE_id NUMBER := p_TEMPLATE_id;

  begin

     if (X_OWNER = 'SEED') then
        user_id := -1;
     end if;

ASO_SUP_TEMPLATE_PKG.UPDATE_ROW (
  P_TEMPLATE_ID => P_TEMPLATE_ID,
  P_LAST_UPDATE_DATE => sysdate,
  P_LAST_UPDATED_BY => user_id,
  P_LAST_UPDATE_LOGIN => 0,
  P_TEMPLATE_NAME => P_TEMPLATE_NAME,
  P_DESCRIPTION    => P_DESCRIPTION,
  P_TEMPLATE_LEVEL     =>  P_TEMPLATE_LEVEL,
  P_TEMPLATE_CONTEXT => P_TEMPLATE_CONTEXT,
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

 ASO_SUP_TEMPLATE_PKG.INSERT_ROW (
  PX_ROWID => row_id,
  PX_TEMPLATE_ID => L_TEMPLATE_ID,
  P_CREATION_DATE => sysdate,
  P_CREATED_BY => user_id,
  P_LAST_UPDATE_DATE => sysdate,
  P_LAST_UPDATED_BY => user_id,
  P_LAST_UPDATE_LOGIN => 0,
  P_TEMPLATE_NAME  => P_TEMPLATE_NAME,
  P_DESCRIPTION     => P_DESCRIPTION,
  P_TEMPLATE_LEVEL      => P_TEMPLATE_LEVEL,
  P_TEMPLATE_CONTEXT => P_TEMPLATE_CONTEXT,
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
   P_TEMPLATE_ID IN NUMBER,
   P_TEMPLATE_NAME IN VARCHAR2,
   P_DESCRIPTION in VARCHAR2,
   X_OWNER in VARCHAR2)

IS

begin

    -- only update rows that have not been altered by user

    update ASO_SUP_TEMPLATE_TL
    set  TEMPLATE_NAME = P_TEMPLATE_NAME,
         DESCRIPTION = P_DESCRIPTION,
         source_lang = userenv('LANG'),
         last_update_date = sysdate,
         last_updated_by = fnd_load_util.owner_id(X_OWNER),
         last_update_login = 0
  where TEMPLATE_ID = P_TEMPLATE_ID
    and userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

  Procedure LOAD_SEED_ROW (
  PX_TEMPLATE_ID             IN NUMBER ,
  P_TEMPLATE_NAME            IN VARCHAR2,
  P_DESCRIPTION              IN VARCHAR2,
  P_TEMPLATE_LEVEL           IN VARCHAR2,
  P_TEMPLATE_CONTEXT         IN VARCHAR2,
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
       l_template_id NUMBER;
       l_template_scope_id   NUMBER;
       row_id VARCHAR2(32767);
       row_id1 VARCHAR2(32767);

cursor get_templates is
   SELECT template_id
   FROM ASO_SUP_TEMPLATE_tl
   WHERE TEMPLATE_ID = PX_TEMPLATE_ID;
BEGIN
    if (P_UPLOAD_MODE = 'NLS') then

	      ASO_SUP_TEMPLATE_PKG.TRANSLATE_ROW (
               P_TEMPLATE_ID    => PX_TEMPLATE_ID ,
               P_TEMPLATE_NAME  => P_TEMPLATE_NAME,
               P_DESCRIPTION    => P_DESCRIPTION,
               X_OWNER          => P_OWNER);

     else

       if (fnd_load_util.owner_id(P_OWNER) = 120 ) then

        open get_templates;
        loop
        fetch get_templates into l_template_id;
        if get_templates%FOUND THEN
        -- this means template already exists
           ASO_SUP_TEMPLATE_PKG.UPDATE_ROW (
             P_TEMPLATE_ID             => PX_TEMPLATE_ID,
             P_LAST_UPDATE_DATE         => sysdate ,
             P_LAST_UPDATED_BY          => fnd_load_util.owner_id(P_OWNER) ,
             P_LAST_UPDATE_LOGIN        => fnd_load_util.owner_id(P_OWNER) ,
             P_TEMPLATE_NAME            => P_TEMPLATE_NAME,
             P_DESCRIPTION              => P_DESCRIPTION,
             P_TEMPLATE_LEVEL           => P_TEMPLATE_LEVEL,
             P_TEMPLATE_CONTEXT         => P_TEMPLATE_CONTEXT,
             p_context                  => p_context,
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
           elsif get_templates%NOTFOUND THEN
           -- this means this is a new template
             l_TEMPLATE_ID := PX_TEMPLATE_ID;
           ASO_SUP_TEMPLATE_PKG.INSERT_ROW (
             PX_ROWID                   => row_id,
             PX_TEMPLATE_ID             => l_TEMPLATE_ID,
             P_CREATION_DATE            => sysdate ,
             P_CREATED_BY               => fnd_load_util.owner_id(P_OWNER) ,
             P_LAST_UPDATE_DATE         => sysdate ,
             P_LAST_UPDATED_BY          => fnd_load_util.owner_id(P_OWNER) ,
             P_LAST_UPDATE_LOGIN        => fnd_load_util.owner_id(P_OWNER) ,
             P_TEMPLATE_NAME            => P_TEMPLATE_NAME,
             P_DESCRIPTION              => P_DESCRIPTION,
             P_TEMPLATE_LEVEL           => P_TEMPLATE_LEVEL,
             P_TEMPLATE_CONTEXT         => P_TEMPLATE_CONTEXT,
             p_context                  => p_context,
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
             close get_templates;
       end if;
   end if;  -- end if the NLS check
 END LOAD_SEED_ROW;
END; -- Package Body ASO_SUP_TEMPLATE_PKG

/
