--------------------------------------------------------
--  DDL for Package Body ASO_SUP_TMPL_SECT_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_SUP_TMPL_SECT_MAP_PKG" AS
/* $Header: asospteb.pls 120.1.12010000.2 2015/08/11 05:32:47 akushwah ship $*/

/* procedure to insert INSERT_ROW */

PROCEDURE INSERT_ROW
(
  PX_ROWID              IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  PX_TEMPLATE_SECTION_MAP_ID       IN OUT NOCOPY /* file.sql.39 change */  NUMBER,
  P_created_by          IN NUMBER ,
  P_creation_date       IN DATE ,
  P_last_updated_by     IN NUMBER,
  P_last_update_date    IN DATE,
  P_last_update_login   IN NUMBER,
  P_TEMPLATE_ID         IN NUMBER,
  P_SECTION_ID          IN NUMBER,
  P_DISPLAY_SEQUENCE    IN NUMBER,
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
    from  ASO_SUP_TMPL_SECT_MAP
    where  TEMPLATE_SECTION_MAP_ID = PX_TEMPLATE_SECTION_MAP_ID ;

  cursor CU_TEMPLATE_SECTION_MAP_ID IS
    select ASO_SUP_TMPL_SECT_MAP_S.NEXTVAL from sys.dual;

Begin

  IF (PX_TEMPLATE_SECTION_MAP_ID IS NULL) OR (PX_TEMPLATE_SECTION_MAP_ID = FND_API.G_MISS_NUM) THEN
      OPEN  CU_TEMPLATE_SECTION_MAP_ID;
      FETCH CU_TEMPLATE_SECTION_MAP_ID INTO PX_TEMPLATE_SECTION_MAP_ID;
      CLOSE CU_TEMPLATE_SECTION_MAP_ID;

  END IF;

  insert into ASO_SUP_TMPL_SECT_MAP (
  TEMPLATE_SECTION_MAP_ID,
  TEMPLATE_ID,
  SECTION_ID ,
  DISPLAY_SEQUENCE,
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
  ATTRIBUTE15 ,
   ATTRIBUTE16,
  ATTRIBUTE17,
  ATTRIBUTE18,
  ATTRIBUTE19,
  ATTRIBUTE20)
values
  (
  PX_TEMPLATE_SECTION_MAP_ID,
  P_TEMPLATE_ID,
  P_SECTION_ID ,
  P_DISPLAY_SEQUENCE,
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
   P_ATTRIBUTE16,
  P_ATTRIBUTE17,
  P_ATTRIBUTE18,
  P_ATTRIBUTE19,
  P_ATTRIBUTE20
  ) ;


  open c;
  fetch c into PX_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;


/* procedure to Update Row */

PROCEDURE UPDATE_ROW
(
  P_TEMPLATE_SECTION_MAP_ID       IN NUMBER,
  P_last_updated_by     IN NUMBER,
  P_last_update_date    IN DATE,
  P_last_update_login   IN NUMBER,
  P_SECTION_ID          IN NUMBER,
  P_TEMPLATE_ID         IN NUMBER,
  P_DISPLAY_SEQUENCE    IN NUMBER,
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

  update ASO_SUP_TMPL_SECT_MAP
  set
  TEMPLATE_ID   = P_TEMPLATE_ID,
  SECTION_ID     = P_SECTION_ID,
  DISPLAY_SEQUENCE = P_DISPLAY_SEQUENCE,
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
where  TEMPLATE_SECTION_MAP_ID = P_TEMPLATE_SECTION_MAP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;


End UPDATE_ROW;

/* procedure to Delete Row */


procedure DELETE_ROW (
  P_TEMPLATE_SECTION_MAP_ID IN NUMBER

)

IS

Begin

 delete from ASO_SUP_TMPL_SECT_MAP
  where  TEMPLATE_SECTION_MAP_ID = P_TEMPLATE_SECTION_MAP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;


End Delete_row;


/* procedure to Lock Row */

PROCEDURE LOCK_ROW
(
  P_TEMPLATE_SECTION_MAP_ID       IN NUMBER,
  P_created_by          IN NUMBER ,
  P_creation_date       IN DATE ,
  P_last_updated_by     IN NUMBER,
  P_last_update_date    IN DATE,
  P_last_update_login   IN NUMBER,
  P_TEMPLATE_ID        IN NUMBER,
  P_SECTION_ID          IN NUMBER,
  P_DISPLAY_SEQUENCE    IN NUMBER,
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
  a.TEMPLATE_SECTION_MAP_ID ,
  a.TEMPLATE_ID,
  a.SECTION_ID ,
  a.DISPLAY_SEQUENCE,
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

 from  ASO_SUP_TMPL_SECT_MAP a
 where a.TEMPLATE_SECTION_MAP_ID = P_TEMPLATE_SECTION_MAP_ID
 for update of a.TEMPLATE_SECTION_MAP_ID nowait;

recinfo i_csr%rowtype;


  l_Item_ID         NUMBER ;
  l_Org_ID          NUMBER ;

  l_return_status   VARCHAR2(1) ;

BEGIN


  l_Item_ID := P_TEMPLATE_SECTION_MAP_ID ;

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
          ((recinfo.TEMPLATE_SECTION_MAP_ID = P_TEMPLATE_SECTION_MAP_ID)
           OR ((recinfo.TEMPLATE_SECTION_MAP_ID is null) AND (P_TEMPLATE_SECTION_MAP_ID is null)))
      AND ((recinfo.TEMPLATE_ID = P_TEMPLATE_ID)
           OR ((recinfo.TEMPLATE_ID is null) AND (P_TEMPLATE_ID is null)))
      AND ((recinfo.SECTION_ID = P_SECTION_ID)
           OR ((recinfo.SECTION_ID is null) AND (P_SECTION_ID is null)))
      AND ((recinfo.DISPLAY_SEQUENCE = P_DISPLAY_SEQUENCE)
           OR ((recinfo.DISPLAY_SEQUENCE is null) AND (P_DISPLAY_SEQUENCE is null)))
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

 return;

End Lock_Row;



END; -- Package Body ASO_SUP_TMPL_SECT_MAP_PKG

/
