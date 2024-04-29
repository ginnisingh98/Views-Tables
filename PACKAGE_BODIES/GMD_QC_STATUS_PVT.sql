--------------------------------------------------------
--  DDL for Package Body GMD_QC_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_QC_STATUS_PVT" as
/* $Header: GMDVSTPB.pls 115.2 2003/02/27 14:53:05 srastogi noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_STATUS_CODE in NUMBER,
  X_ENTITY_TYPE in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_STATUS_TYPE in NUMBER,
  X_VERSION_ENABLED in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_ATTRIBUTE21 in VARCHAR2,
  X_ATTRIBUTE22 in VARCHAR2,
  X_ATTRIBUTE23 in VARCHAR2,
  X_ATTRIBUTE24 in VARCHAR2,
  X_ATTRIBUTE25 in VARCHAR2,
  X_ATTRIBUTE26 in VARCHAR2,
  X_ATTRIBUTE27 in VARCHAR2,
  X_ATTRIBUTE28 in VARCHAR2,
  X_ATTRIBUTE29 in VARCHAR2,
  X_ATTRIBUTE30 in VARCHAR2,
  X_DELETE_MARK in NUMBER,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_UPDATEABLE in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from GMD_QC_STATUS_B
    where STATUS_CODE = X_STATUS_CODE
    and ENTITY_TYPE = X_ENTITY_TYPE
    ;
begin
  insert into GMD_QC_STATUS_B (
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE3,
    ATTRIBUTE15,
    ATTRIBUTE16,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE1,
    ATTRIBUTE2,
    STATUS_TYPE,
    VERSION_ENABLED,
    ENTITY_TYPE,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE17,
    ATTRIBUTE18,
    ATTRIBUTE19,
    ATTRIBUTE20,
    ATTRIBUTE21,
    ATTRIBUTE22,
    ATTRIBUTE23,
    ATTRIBUTE24,
    ATTRIBUTE25,
    ATTRIBUTE26,
    ATTRIBUTE27,
    ATTRIBUTE28,
    ATTRIBUTE29,
    ATTRIBUTE30,
    DELETE_MARK,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE14,
    STATUS_CODE,
    UPDATEABLE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE3,
    X_ATTRIBUTE15,
    X_ATTRIBUTE16,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_STATUS_TYPE,
    X_VERSION_ENABLED,
    X_ENTITY_TYPE,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE17,
    X_ATTRIBUTE18,
    X_ATTRIBUTE19,
    X_ATTRIBUTE20,
    X_ATTRIBUTE21,
    X_ATTRIBUTE22,
    X_ATTRIBUTE23,
    X_ATTRIBUTE24,
    X_ATTRIBUTE25,
    X_ATTRIBUTE26,
    X_ATTRIBUTE27,
    X_ATTRIBUTE28,
    X_ATTRIBUTE29,
    X_ATTRIBUTE30,
    X_DELETE_MARK,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE14,
    X_STATUS_CODE,
    X_UPDATEABLE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into GMD_QC_STATUS_TL (
    LAST_UPDATED_BY,
    STATUS_CODE,
    MEANING,
    ENTITY_TYPE,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATED_BY,
    X_STATUS_CODE,
    X_MEANING,
    X_ENTITY_TYPE,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from GMD_QC_STATUS_TL T
    where T.STATUS_CODE = X_STATUS_CODE
    and T.ENTITY_TYPE = X_ENTITY_TYPE
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
  X_STATUS_CODE in NUMBER,
  X_ENTITY_TYPE in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_STATUS_TYPE in NUMBER,
  X_VERSION_ENABLED in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_ATTRIBUTE21 in VARCHAR2,
  X_ATTRIBUTE22 in VARCHAR2,
  X_ATTRIBUTE23 in VARCHAR2,
  X_ATTRIBUTE24 in VARCHAR2,
  X_ATTRIBUTE25 in VARCHAR2,
  X_ATTRIBUTE26 in VARCHAR2,
  X_ATTRIBUTE27 in VARCHAR2,
  X_ATTRIBUTE28 in VARCHAR2,
  X_ATTRIBUTE29 in VARCHAR2,
  X_ATTRIBUTE30 in VARCHAR2,
  X_DELETE_MARK in NUMBER,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_UPDATEABLE in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE3,
      ATTRIBUTE15,
      ATTRIBUTE16,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE1,
      ATTRIBUTE2,
      STATUS_TYPE,
      VERSION_ENABLED,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19,
      ATTRIBUTE20,
      ATTRIBUTE21,
      ATTRIBUTE22,
      ATTRIBUTE23,
      ATTRIBUTE24,
      ATTRIBUTE25,
      ATTRIBUTE26,
      ATTRIBUTE27,
      ATTRIBUTE28,
      ATTRIBUTE29,
      ATTRIBUTE30,
      DELETE_MARK,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE14,
      UPDATEABLE
    from GMD_QC_STATUS_B
    where STATUS_CODE = X_STATUS_CODE
    and ENTITY_TYPE = X_ENTITY_TYPE
    for update of STATUS_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      MEANING,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from GMD_QC_STATUS_TL
    where STATUS_CODE = X_STATUS_CODE
    and ENTITY_TYPE = X_ENTITY_TYPE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of STATUS_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.ATTRIBUTE16 = X_ATTRIBUTE16)
           OR ((recinfo.ATTRIBUTE16 is null) AND (X_ATTRIBUTE16 is null)))
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
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND (recinfo.STATUS_TYPE = X_STATUS_TYPE)
      AND (recinfo.VERSION_ENABLED = X_VERSION_ENABLED)
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE17 = X_ATTRIBUTE17)
           OR ((recinfo.ATTRIBUTE17 is null) AND (X_ATTRIBUTE17 is null)))
      AND ((recinfo.ATTRIBUTE18 = X_ATTRIBUTE18)
           OR ((recinfo.ATTRIBUTE18 is null) AND (X_ATTRIBUTE18 is null)))
      AND ((recinfo.ATTRIBUTE19 = X_ATTRIBUTE19)
           OR ((recinfo.ATTRIBUTE19 is null) AND (X_ATTRIBUTE19 is null)))
      AND ((recinfo.ATTRIBUTE20 = X_ATTRIBUTE20)
           OR ((recinfo.ATTRIBUTE20 is null) AND (X_ATTRIBUTE20 is null)))
      AND ((recinfo.ATTRIBUTE21 = X_ATTRIBUTE21)
           OR ((recinfo.ATTRIBUTE21 is null) AND (X_ATTRIBUTE21 is null)))
      AND ((recinfo.ATTRIBUTE22 = X_ATTRIBUTE22)
           OR ((recinfo.ATTRIBUTE22 is null) AND (X_ATTRIBUTE22 is null)))
      AND ((recinfo.ATTRIBUTE23 = X_ATTRIBUTE23)
           OR ((recinfo.ATTRIBUTE23 is null) AND (X_ATTRIBUTE23 is null)))
      AND ((recinfo.ATTRIBUTE24 = X_ATTRIBUTE24)
           OR ((recinfo.ATTRIBUTE24 is null) AND (X_ATTRIBUTE24 is null)))
      AND ((recinfo.ATTRIBUTE25 = X_ATTRIBUTE25)
           OR ((recinfo.ATTRIBUTE25 is null) AND (X_ATTRIBUTE25 is null)))
      AND ((recinfo.ATTRIBUTE26 = X_ATTRIBUTE26)
           OR ((recinfo.ATTRIBUTE26 is null) AND (X_ATTRIBUTE26 is null)))
      AND ((recinfo.ATTRIBUTE27 = X_ATTRIBUTE27)
           OR ((recinfo.ATTRIBUTE27 is null) AND (X_ATTRIBUTE27 is null)))
      AND ((recinfo.ATTRIBUTE28 = X_ATTRIBUTE28)
           OR ((recinfo.ATTRIBUTE28 is null) AND (X_ATTRIBUTE28 is null)))
      AND ((recinfo.ATTRIBUTE29 = X_ATTRIBUTE29)
           OR ((recinfo.ATTRIBUTE29 is null) AND (X_ATTRIBUTE29 is null)))
      AND ((recinfo.ATTRIBUTE30 = X_ATTRIBUTE30)
           OR ((recinfo.ATTRIBUTE30 is null) AND (X_ATTRIBUTE30 is null)))
      AND (recinfo.DELETE_MARK = X_DELETE_MARK)
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND (recinfo.UPDATEABLE = X_UPDATEABLE)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.MEANING = X_MEANING)
          AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
      ) then
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
  X_STATUS_CODE in NUMBER,
  X_ENTITY_TYPE in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_STATUS_TYPE in NUMBER,
  X_VERSION_ENABLED in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_ATTRIBUTE21 in VARCHAR2,
  X_ATTRIBUTE22 in VARCHAR2,
  X_ATTRIBUTE23 in VARCHAR2,
  X_ATTRIBUTE24 in VARCHAR2,
  X_ATTRIBUTE25 in VARCHAR2,
  X_ATTRIBUTE26 in VARCHAR2,
  X_ATTRIBUTE27 in VARCHAR2,
  X_ATTRIBUTE28 in VARCHAR2,
  X_ATTRIBUTE29 in VARCHAR2,
  X_ATTRIBUTE30 in VARCHAR2,
  X_DELETE_MARK in NUMBER,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_UPDATEABLE in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update GMD_QC_STATUS_B set
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    ATTRIBUTE16 = X_ATTRIBUTE16,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    STATUS_TYPE = X_STATUS_TYPE,
    VERSION_ENABLED = X_VERSION_ENABLED,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE17 = X_ATTRIBUTE17,
    ATTRIBUTE18 = X_ATTRIBUTE18,
    ATTRIBUTE19 = X_ATTRIBUTE19,
    ATTRIBUTE20 = X_ATTRIBUTE20,
    ATTRIBUTE21 = X_ATTRIBUTE21,
    ATTRIBUTE22 = X_ATTRIBUTE22,
    ATTRIBUTE23 = X_ATTRIBUTE23,
    ATTRIBUTE24 = X_ATTRIBUTE24,
    ATTRIBUTE25 = X_ATTRIBUTE25,
    ATTRIBUTE26 = X_ATTRIBUTE26,
    ATTRIBUTE27 = X_ATTRIBUTE27,
    ATTRIBUTE28 = X_ATTRIBUTE28,
    ATTRIBUTE29 = X_ATTRIBUTE29,
    ATTRIBUTE30 = X_ATTRIBUTE30,
    DELETE_MARK = X_DELETE_MARK,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    UPDATEABLE = X_UPDATEABLE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where STATUS_CODE = X_STATUS_CODE
  and ENTITY_TYPE = X_ENTITY_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update GMD_QC_STATUS_TL set
    MEANING = X_MEANING,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where STATUS_CODE = X_STATUS_CODE
  and ENTITY_TYPE = X_ENTITY_TYPE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_STATUS_CODE in NUMBER,
  X_ENTITY_TYPE in VARCHAR2
) is
begin
  delete from GMD_QC_STATUS_TL
  where STATUS_CODE = X_STATUS_CODE
  and ENTITY_TYPE = X_ENTITY_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from GMD_QC_STATUS_B
  where STATUS_CODE = X_STATUS_CODE
  and ENTITY_TYPE = X_ENTITY_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from GMD_QC_STATUS_TL T
  where not exists
    (select NULL
    from GMD_QC_STATUS_B B
    where B.STATUS_CODE = T.STATUS_CODE
    and B.ENTITY_TYPE = T.ENTITY_TYPE
    );

  update GMD_QC_STATUS_TL T set (
      MEANING,
      DESCRIPTION
    ) = (select
      B.MEANING,
      B.DESCRIPTION
    from GMD_QC_STATUS_TL B
    where B.STATUS_CODE = T.STATUS_CODE
    and B.ENTITY_TYPE = T.ENTITY_TYPE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.STATUS_CODE,
      T.ENTITY_TYPE,
      T.LANGUAGE
  ) in (select
      SUBT.STATUS_CODE,
      SUBT.ENTITY_TYPE,
      SUBT.LANGUAGE
    from GMD_QC_STATUS_TL SUBB, GMD_QC_STATUS_TL SUBT
    where SUBB.STATUS_CODE = SUBT.STATUS_CODE
    and SUBB.ENTITY_TYPE = SUBT.ENTITY_TYPE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.MEANING <> SUBT.MEANING
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into GMD_QC_STATUS_TL (
    LAST_UPDATED_BY,
    STATUS_CODE,
    MEANING,
    ENTITY_TYPE,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATED_BY,
    B.STATUS_CODE,
    B.MEANING,
    B.ENTITY_TYPE,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GMD_QC_STATUS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GMD_QC_STATUS_TL T
    where T.STATUS_CODE = B.STATUS_CODE
    and T.ENTITY_TYPE = B.ENTITY_TYPE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

/* Two more procedures for NLS translation */
PROCEDURE TRANSLATE_ROW (
                             X_UPDATEABLE        IN   VARCHAR2
                            ,X_STATUS_TYPE       IN   NUMBER
                            ,X_VERSION_ENABLED   IN   VARCHAR2
                            ,X_DELETE_MARK       IN   NUMBER
 		            ,X_STATUS_CODE       IN   NUMBER
 		            ,X_ENTITY_TYPE       IN   VARCHAR2
 		            ,X_DESCRIPTION       IN   VARCHAR2
 	                    ,X_MEANING           IN   VARCHAR2
 		            ,X_USER_ID           IN   NUMBER
 	                 ) IS
BEGIN
 	UPDATE GMD_QC_STATUS_TL SET
 	        /* Bug 2478592 - Thomas Daniel */
 	        /* Added the update to the meaning column */
    	        MEANING		  = X_MEANING,
 		DESCRIPTION       = X_DESCRIPTION,
 		SOURCE_LANG       = USERENV('LANG'),
 		LAST_UPDATE_DATE  = sysdate,
 		LAST_UPDATED_BY   = X_USER_ID,
 		LAST_UPDATE_LOGIN = 0
 	WHERE (STATUS_CODE = X_STATUS_CODE)
 	AND   (ENTITY_TYPE = X_ENTITY_TYPE)
 	AND   (USERENV('LANG') IN (LANGUAGE, SOURCE_LANG));

END TRANSLATE_ROW;


PROCEDURE LOAD_ROW (
                       X_UPDATEABLE        IN   VARCHAR2
                      ,X_STATUS_TYPE       IN   NUMBER
                      ,X_VERSION_ENABLED   IN   VARCHAR2
                      ,X_DELETE_MARK       IN   NUMBER
  		      ,X_STATUS_CODE       IN   NUMBER
  		      ,X_ENTITY_TYPE       IN   VARCHAR2
  		      ,X_DESCRIPTION       IN   VARCHAR2
  	              ,X_MEANING           IN   VARCHAR2
 		      ,X_USER_ID           IN   NUMBER
  	            ) IS

  CURSOR Cur_rowid IS
	 SELECT rowid
	 FROM GMD_QC_STATUS_TL
	 WHERE (STATUS_CODE = X_STATUS_CODE)
	 AND   (ENTITY_TYPE = X_ENTITY_TYPE);

  l_user_id	   NUMBER	DEFAULT 1 ;
  l_row_id	   VARCHAR2(64)           ;
  l_return_status  VARCHAR2(1)            ;

BEGIN
	l_user_id := X_USER_ID;

	OPEN Cur_rowid;
	FETCH Cur_rowid INTO l_row_id;

	IF Cur_rowid%FOUND THEN
	    GMD_QC_STATUS_PVT.UPDATE_ROW (
              X_STATUS_CODE          => X_STATUS_CODE         ,
              X_ENTITY_TYPE          => X_ENTITY_TYPE         ,
              X_VERSION_ENABLED      => X_VERSION_ENABLED     ,
              X_UPDATEABLE           => X_UPDATEABLE          ,
              X_ATTRIBUTE_CATEGORY   => NULL                  ,
              X_ATTRIBUTE1           => NULL                  ,
              X_ATTRIBUTE2           => NULL                  ,
              X_ATTRIBUTE3           => NULL                  ,
              X_ATTRIBUTE4           => NULL                  ,
              X_ATTRIBUTE5           => NULL                  ,
              X_ATTRIBUTE6           => NULL                  ,
              X_ATTRIBUTE7           => NULL                  ,
              X_ATTRIBUTE8           => NULL                  ,
              X_ATTRIBUTE9           => NULL                  ,
              X_ATTRIBUTE10          => NULL                  ,
              X_ATTRIBUTE11          => NULL                  ,
              X_ATTRIBUTE12          => NULL                  ,
              X_ATTRIBUTE13          => NULL                  ,
              X_ATTRIBUTE14          => NULL                  ,
              X_ATTRIBUTE15          => NULL                  ,
              X_ATTRIBUTE16          => NULL                  ,
              X_ATTRIBUTE17          => NULL                  ,
              X_ATTRIBUTE18          => NULL                  ,
              X_ATTRIBUTE19          => NULL                  ,
              X_ATTRIBUTE20          => NULL                  ,
              X_ATTRIBUTE21          => NULL                  ,
              X_ATTRIBUTE22          => NULL                  ,
              X_ATTRIBUTE23          => NULL                  ,
              X_ATTRIBUTE24          => NULL                  ,
              X_ATTRIBUTE25          => NULL                  ,
              X_ATTRIBUTE26          => NULL                  ,
              X_ATTRIBUTE27          => NULL                  ,
              X_ATTRIBUTE28          => NULL                  ,
              X_ATTRIBUTE29          => NULL                  ,
              X_ATTRIBUTE30          => NULL                  ,
              X_DESCRIPTION          => X_DESCRIPTION         ,
              X_MEANING              => X_MEANING             ,
              X_LAST_UPDATE_DATE     => sysdate               ,
              X_LAST_UPDATED_BY      => l_user_id             ,
              X_LAST_UPDATE_LOGIN    => 0                     ,
              X_DELETE_MARK          => X_DELETE_MARK         ,
              X_STATUS_TYPE          => X_STATUS_TYPE
            );
	ELSE
           GMD_QC_STATUS_PVT.INSERT_ROW (
              X_ROWID               => l_row_id               ,
              X_STATUS_CODE         => X_STATUS_CODE          ,
              X_ENTITY_TYPE         => X_ENTITY_TYPE          ,
              X_VERSION_ENABLED     => X_VERSION_ENABLED      ,
              X_UPDATEABLE          => X_UPDATEABLE           ,
              X_ATTRIBUTE_CATEGORY  => NULL                   ,
              X_ATTRIBUTE1          => NULL                   ,
              X_ATTRIBUTE2          => NULL                   ,
              X_ATTRIBUTE3          => NULL                   ,
              X_ATTRIBUTE4          => NULL                   ,
              X_ATTRIBUTE5          => NULL                   ,
              X_ATTRIBUTE6          => NULL                   ,
              X_ATTRIBUTE7          => NULL                   ,
              X_ATTRIBUTE8          => NULL                   ,
              X_ATTRIBUTE9          => NULL                   ,
              X_ATTRIBUTE10         => NULL                   ,
              X_ATTRIBUTE11         => NULL                   ,
              X_ATTRIBUTE12         => NULL                   ,
              X_ATTRIBUTE13         => NULL                   ,
              X_ATTRIBUTE14         => NULL                   ,
              X_ATTRIBUTE15         => NULL                   ,
              X_ATTRIBUTE16         => NULL                   ,
              X_ATTRIBUTE17         => NULL                   ,
              X_ATTRIBUTE18         => NULL                   ,
              X_ATTRIBUTE19         => NULL                   ,
              X_ATTRIBUTE20         => NULL                   ,
              X_ATTRIBUTE21         => NULL                   ,
              X_ATTRIBUTE22         => NULL                   ,
              X_ATTRIBUTE23         => NULL                   ,
              X_ATTRIBUTE24         => NULL                   ,
              X_ATTRIBUTE25         => NULL                   ,
              X_ATTRIBUTE26         => NULL                   ,
              X_ATTRIBUTE27         => NULL                   ,
              X_ATTRIBUTE28         => NULL                   ,
              X_ATTRIBUTE29         => NULL                   ,
              X_ATTRIBUTE30         => NULL                   ,
              X_DESCRIPTION         => X_DESCRIPTION          ,
              X_MEANING             => X_MEANING              ,
              X_CREATION_DATE       => sysdate                ,
              X_CREATED_BY          => l_user_id              ,
              X_LAST_UPDATE_DATE    => sysdate                ,
              X_LAST_UPDATED_BY     => l_user_id              ,
              X_LAST_UPDATE_LOGIN   => 0                      ,
              X_DELETE_MARK         => X_DELETE_MARK          ,
              X_STATUS_TYPE         => X_STATUS_TYPE
              );
        END IF;

        CLOSE Cur_rowid;

END LOAD_ROW;

end GMD_QC_STATUS_PVT;

/
