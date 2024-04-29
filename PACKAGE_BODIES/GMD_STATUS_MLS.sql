--------------------------------------------------------
--  DDL for Package Body GMD_STATUS_MLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_STATUS_MLS" as
/* $Header: GMDSMLSB.pls 115.8 2003/10/24 06:30:11 gmangari noship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_STATUS_CODE in VARCHAR2,
  X_VERSION_ENABLED in VARCHAR2,
  X_UPDATEABLE in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_ATTRIBUTE16 in VARCHAR2,
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
  X_DESCRIPTION in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_STATUS_TYPE in VARCHAR2
) is
  cursor C is select ROWID from GMD_STATUS_B
    where STATUS_CODE = X_STATUS_CODE
    ;
begin
  -- BEGIN BUG#3131047 Sastry
  -- Insert into the table only if no rows are present.
  OPEN c;
  FETCH c into X_ROWID;
  IF (c%notfound) THEN
  -- END BUG#3131047
    insert into GMD_STATUS_B (
      VERSION_ENABLED,
      STATUS_CODE,
      UPDATEABLE,
      ATTRIBUTE_CATEGORY,
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
      ATTRIBUTE16,
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
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      DELETE_MARK,
      STATUS_TYPE
     ) values (
      X_VERSION_ENABLED,
      X_STATUS_CODE,
      X_UPDATEABLE,
      X_ATTRIBUTE_CATEGORY,
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
      X_ATTRIBUTE16,
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
      X_CREATION_DATE,
      X_CREATED_BY,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_LOGIN,
      X_DELETE_MARK,
      X_STATUS_TYPE
      );
  -- BEGIN BUG#3131047 Sastry
  END IF;
  Close c;
  -- END BUG#3131047

    insert into GMD_STATUS_TL (
      MEANING,
      STATUS_CODE,
      DESCRIPTION,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LANGUAGE,
      SOURCE_LANG
     ) select
      X_MEANING,
      X_STATUS_CODE,
      X_DESCRIPTION,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATE_LOGIN,
      X_LAST_UPDATED_BY,
      X_CREATION_DATE,
      X_CREATED_BY,
      L.LANGUAGE_CODE,
      userenv('LANG')
    from FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
    and not exists
    (select NULL
    from GMD_STATUS_TL T
    where T.STATUS_CODE = X_STATUS_CODE
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
  X_STATUS_CODE in VARCHAR2,
  X_VERSION_ENABLED in VARCHAR2,
  X_UPDATEABLE in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_ATTRIBUTE16 in VARCHAR2,
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
  X_DESCRIPTION in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DELETE_MARK in NUMBER,
  X_STATUS_TYPE in VARCHAR2
) is
  cursor c is select
      VERSION_ENABLED,
      UPDATEABLE,
      ATTRIBUTE_CATEGORY,
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
      ATTRIBUTE16,
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
      STATUS_TYPE
    from GMD_STATUS_B
    where STATUS_CODE = X_STATUS_CODE
    for update of STATUS_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION,
      MEANING,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from GMD_STATUS_TL
    where STATUS_CODE = X_STATUS_CODE
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
  if (    (recinfo.VERSION_ENABLED = X_VERSION_ENABLED)
      AND (recinfo.UPDATEABLE = X_UPDATEABLE)
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
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
      AND ((recinfo.ATTRIBUTE16 = X_ATTRIBUTE16)
           OR ((recinfo.ATTRIBUTE16 is null) AND (X_ATTRIBUTE16 is null)))
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
      AND ((recinfo.DELETE_MARK = X_DELETE_MARK)
           OR ((recinfo.DELETE_MARK is null) AND (X_DELETE_MARK is null)))
      AND ((recinfo.STATUS_TYPE = X_STATUS_TYPE)
           OR ((recinfo.STATUS_TYPE is null) AND (X_STATUS_TYPE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DESCRIPTION = X_DESCRIPTION)
          AND (tlinfo.MEANING = X_MEANING)
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
  X_STATUS_CODE in VARCHAR2,
  X_VERSION_ENABLED in VARCHAR2,
  X_UPDATEABLE in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_ATTRIBUTE16 in VARCHAR2,
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
  X_DESCRIPTION in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_STATUS_TYPE in VARCHAR2
  ) is
begin
  update GMD_STATUS_B set
    VERSION_ENABLED = X_VERSION_ENABLED,
    UPDATEABLE = X_UPDATEABLE,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
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
    ATTRIBUTE16 = X_ATTRIBUTE16,
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
    STATUS_TYPE = X_STATUS_TYPE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where STATUS_CODE = X_STATUS_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update GMD_STATUS_TL set
    DESCRIPTION = X_DESCRIPTION,
    MEANING = X_MEANING,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where STATUS_CODE = X_STATUS_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_STATUS_CODE in VARCHAR2
) is
begin
  delete from GMD_STATUS_TL
  where STATUS_CODE = X_STATUS_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from GMD_STATUS_B
  where STATUS_CODE = X_STATUS_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from GMD_STATUS_TL T
  where not exists
    (select NULL
    from GMD_STATUS_B B
    where B.STATUS_CODE = T.STATUS_CODE
    );

  update GMD_STATUS_TL T set (
      DESCRIPTION,
      MEANING
    ) = (select
      B.DESCRIPTION,
      B.MEANING
    from GMD_STATUS_TL B
    where B.STATUS_CODE = T.STATUS_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.STATUS_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.STATUS_CODE,
      SUBT.LANGUAGE
    from GMD_STATUS_TL SUBB, GMD_STATUS_TL SUBT
    where SUBB.STATUS_CODE = SUBT.STATUS_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or SUBB.MEANING <> SUBT.MEANING
  ));

  insert into GMD_STATUS_TL (
    MEANING,
    STATUS_CODE,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.MEANING,
    B.STATUS_CODE,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GMD_STATUS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GMD_STATUS_TL T
    where T.STATUS_CODE = B.STATUS_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

  /* Two more procedures for NLS translation */
 PROCEDURE TRANSLATE_ROW (
                             X_UPDATEABLE        IN   VARCHAR2
                            ,X_STATUS_TYPE       IN   VARCHAR2
                            ,X_VERSION_ENABLED   IN   VARCHAR2
                            ,X_DELETE_MARK       IN   NUMBER
 		            ,X_STATUS_CODE       IN   VARCHAR2
 		            ,X_DESCRIPTION       IN   VARCHAR2
 	                    ,X_MEANING           IN   VARCHAR2
 	                    ,X_OWNER		 IN   NUMBER
 	                 ) IS
 BEGIN
 	UPDATE GMD_STATUS_TL SET
 	        /* Bug 2478592 - Thomas Daniel */
 	        /* Added the update to the meaning column */
    	        MEANING		  = X_MEANING,
 		DESCRIPTION       = X_DESCRIPTION,
 		SOURCE_LANG       = USERENV('LANG'),
 		LAST_UPDATE_DATE  = sysdate,
 		LAST_UPDATED_BY   = X_owner,
 		LAST_UPDATE_LOGIN = 0
 	WHERE (STATUS_CODE = X_STATUS_CODE)
 	AND   (USERENV('LANG') IN (LANGUAGE, SOURCE_LANG));

 END TRANSLATE_ROW;

 PROCEDURE LOAD_ROW (
                       X_UPDATEABLE        IN   VARCHAR2
                      ,X_STATUS_TYPE       IN   VARCHAR2
                      ,X_VERSION_ENABLED   IN   VARCHAR2
                      ,X_DELETE_MARK       IN   NUMBER
  		      ,X_STATUS_CODE       IN   VARCHAR2
  		      ,X_DESCRIPTION       IN   VARCHAR2
  	              ,X_MEANING           IN   VARCHAR2
  	              ,X_OWNER		   IN   NUMBER
  	            ) IS

  CURSOR Cur_rowid IS
	 SELECT rowid
	 FROM GMD_STATUS_TL
	 WHERE (STATUS_CODE = X_STATUS_CODE);

  l_row_id	   VARCHAR2(64)           ;
  l_return_status  VARCHAR2(1)            ;

 BEGIN
	OPEN Cur_rowid;
	FETCH Cur_rowid INTO l_row_id;

	IF Cur_rowid%FOUND THEN
	    GMD_STATUS_MLS.UPDATE_ROW (
              X_STATUS_CODE          => X_STATUS_CODE         ,
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
              X_LAST_UPDATED_BY      => X_owner               ,
              X_LAST_UPDATE_LOGIN    => 0                     ,
              X_DELETE_MARK          => X_DELETE_MARK         ,
              X_STATUS_TYPE          => X_STATUS_TYPE
            );
	ELSE
           GMD_STATUS_MLS.INSERT_ROW (
              X_ROWID               => l_row_id               ,
              X_STATUS_CODE         => X_STATUS_CODE          ,
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
              X_CREATED_BY          => X_owner                ,
              X_LAST_UPDATE_DATE    => sysdate                ,
              X_LAST_UPDATED_BY     => X_owner                ,
              X_LAST_UPDATE_LOGIN   => 0                      ,
              X_DELETE_MARK         => X_DELETE_MARK          ,
              X_STATUS_TYPE         => X_STATUS_TYPE
              );
        END IF;

        CLOSE Cur_rowid;

 END LOAD_ROW;


end GMD_STATUS_MLS;

/
