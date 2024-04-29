--------------------------------------------------------
--  DDL for Package Body QP_RLTD_MODIFIER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_RLTD_MODIFIER_PVT" as
/* $Header: QPXVRMDB.pls 120.1 2005/06/16 00:29:56 appldev  $ */

PROCEDURE Insert_Row(
  X_RLTD_MODIFIER_ID    IN OUT NOCOPY /* file.sql.39 change */  NUMBER
, X_CREATION_DATE                  DATE
, X_CREATED_BY                     NUMBER
, X_LAST_UPDATE_DATE               DATE
, X_LAST_UPDATED_BY                NUMBER
, X_LAST_UPDATE_LOGIN              NUMBER
, X_RLTD_MODIFIER_GRP_NO                NUMBER
, X_FROM_RLTD_MODIFIER_ID               NUMBER
, X_TO_RLTD_MODIFIER_ID         NUMBER
, X_RLTD_MODIFIER_GRP_TYPE         VARCHAR2
, X_CONTEXT                        VARCHAR2
, X_ATTRIBUTE1                     VARCHAR2
, X_ATTRIBUTE2                     VARCHAR2
, X_ATTRIBUTE3                     VARCHAR2
, X_ATTRIBUTE4                     VARCHAR2
, X_ATTRIBUTE5                     VARCHAR2
, X_ATTRIBUTE6                     VARCHAR2
, X_ATTRIBUTE7                     VARCHAR2
, X_ATTRIBUTE8                     VARCHAR2
, X_ATTRIBUTE9                     VARCHAR2
, X_ATTRIBUTE10                    VARCHAR2
, X_ATTRIBUTE11                    VARCHAR2
, X_ATTRIBUTE12                    VARCHAR2
, X_ATTRIBUTE13                    VARCHAR2
, X_ATTRIBUTE14                    VARCHAR2
, X_ATTRIBUTE15                    VARCHAR2
) IS

cursor C is select RLTD_MODIFIER_ID from QP_RLTD_MODIFIERS
		where RLTD_MODIFIER_ID = X_RLTD_MODIFIER_ID;



BEGIN


insert into QP_RLTD_MODIFIERS
(
  RLTD_MODIFIER_ID
, CREATION_DATE
, CREATED_BY
, LAST_UPDATE_DATE
, LAST_UPDATED_BY
, LAST_UPDATE_LOGIN
, RLTD_MODIFIER_GRP_NO
, FROM_RLTD_MODIFIER_ID
, TO_RLTD_MODIFIER_ID
, RLTD_MODIFIER_GRP_TYPE
, CONTEXT
, ATTRIBUTE1
, ATTRIBUTE2
, ATTRIBUTE3
, ATTRIBUTE4
, ATTRIBUTE5
, ATTRIBUTE6
, ATTRIBUTE7
, ATTRIBUTE8
, ATTRIBUTE9
, ATTRIBUTE10
, ATTRIBUTE11
, ATTRIBUTE12
, ATTRIBUTE13
, ATTRIBUTE14
, ATTRIBUTE15
)
values
(
  X_RLTD_MODIFIER_ID
, X_CREATION_DATE
, X_CREATED_BY
, X_LAST_UPDATE_DATE
, X_LAST_UPDATED_BY
, X_LAST_UPDATE_LOGIN
, X_RLTD_MODIFIER_GRP_NO
, X_FROM_RLTD_MODIFIER_ID
, X_TO_RLTD_MODIFIER_ID
, X_RLTD_MODIFIER_GRP_TYPE
, X_CONTEXT
, X_ATTRIBUTE1
, X_ATTRIBUTE2
, X_ATTRIBUTE3
, X_ATTRIBUTE4
, X_ATTRIBUTE5
, X_ATTRIBUTE6
, X_ATTRIBUTE7
, X_ATTRIBUTE8
, X_ATTRIBUTE9
, X_ATTRIBUTE10
, X_ATTRIBUTE11
, X_ATTRIBUTE12
, X_ATTRIBUTE13
, X_ATTRIBUTE14
, X_ATTRIBUTE15
);

open C;

fetch C into X_RLTD_MODIFIER_ID;
if (C%notfound) then
close C;
raise NO_DATA_FOUND;
end if;
close C;
end Insert_Row;

PROCEDURE Lock_Row(
  X_RLTD_MODIFIER_ID    IN OUT NOCOPY /* file.sql.39 change */  NUMBER
, X_CREATION_DATE                  DATE
, X_CREATED_BY                     NUMBER
, X_LAST_UPDATE_DATE               DATE
, X_LAST_UPDATED_BY                NUMBER
, X_LAST_UPDATE_LOGIN              NUMBER
, X_RLTD_MODIFIER_GRP_NO                NUMBER
, X_FROM_RLTD_MODIFIER_ID               NUMBER
, X_TO_RLTD_MODIFIER_ID         NUMBER
, X_RLTD_MODIFIER_GRP_TYPE         VARCHAR2
, X_CONTEXT                        VARCHAR2
, X_ATTRIBUTE1                     VARCHAR2
, X_ATTRIBUTE2                     VARCHAR2
, X_ATTRIBUTE3                     VARCHAR2
, X_ATTRIBUTE4                     VARCHAR2
, X_ATTRIBUTE5                     VARCHAR2
, X_ATTRIBUTE6                     VARCHAR2
, X_ATTRIBUTE7                     VARCHAR2
, X_ATTRIBUTE8                     VARCHAR2
, X_ATTRIBUTE9                     VARCHAR2
, X_ATTRIBUTE10                    VARCHAR2
, X_ATTRIBUTE11                    VARCHAR2
, X_ATTRIBUTE12                    VARCHAR2
, X_ATTRIBUTE13                    VARCHAR2
, X_ATTRIBUTE14                    VARCHAR2
, X_ATTRIBUTE15                    VARCHAR2
) IS


cursor C is select * from QP_RLTD_MODIFIERS
	where RLTD_MODIFIER_ID = X_RLTD_MODIFIER_ID
	for update of RLTD_MODIFIER_ID nowait;
Recinfo C%ROWTYPE;


BEGIN

open C;

fetch C into Recinfo;

if (C%notfound) then

close C;
FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
APP_EXCEPTION.Raise_Exception;

end if;

close C;

if (
( Recinfo.RLTD_MODIFIER_ID =  X_RLTD_MODIFIER_ID )

AND (   ( Recinfo.CREATION_DATE = X_CREATION_DATE )
	OR ( (Recinfo.CREATION_DATE IS NULL)
	AND (X_CREATION_DATE IS NULL)))

AND (   ( Recinfo.CREATED_BY = X_CREATED_BY)
	OR ( (Recinfo.CREATED_BY IS NULL)
	AND (X_CREATED_BY IS NULL)))

AND (   ( Recinfo.LAST_UPDATE_DATE = X_LAST_UPDATE_DATE)
	OR ( (Recinfo.LAST_UPDATE_DATE IS NULL)
	AND (X_LAST_UPDATE_DATE IS NULL)))

AND (   ( Recinfo.LAST_UPDATED_BY = X_LAST_UPDATED_BY)
	OR ( (Recinfo.LAST_UPDATED_BY IS NULL)
	AND (X_LAST_UPDATED_BY IS NULL)))

AND (   ( Recinfo.LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN)
	OR ( (Recinfo.LAST_UPDATE_LOGIN IS NULL)
	AND (X_LAST_UPDATE_LOGIN IS NULL)))

AND (   ( Recinfo.RLTD_MODIFIER_GRP_NO = X_RLTD_MODIFIER_GRP_NO )
	OR ( (Recinfo.RLTD_MODIFIER_GRP_NO IS NULL)
	AND (X_RLTD_MODIFIER_GRP_NO IS NULL)))

AND (   ( Recinfo.FROM_RLTD_MODIFIER_ID = X_FROM_RLTD_MODIFIER_ID )
	OR ( (Recinfo.FROM_RLTD_MODIFIER_ID IS NULL)
	AND (X_FROM_RLTD_MODIFIER_ID IS NULL)))

AND (   ( Recinfo.TO_RLTD_MODIFIER_ID = X_TO_RLTD_MODIFIER_ID )
	OR ( (Recinfo.TO_RLTD_MODIFIER_ID IS NULL)
	AND (X_TO_RLTD_MODIFIER_ID IS NULL)))

AND (   ( Recinfo.RLTD_MODIFIER_GRP_TYPE = X_RLTD_MODIFIER_GRP_TYPE )
	OR ( (Recinfo.RLTD_MODIFIER_GRP_TYPE IS NULL)
	AND (X_RLTD_MODIFIER_GRP_TYPE IS NULL)))

AND (   ( Recinfo.CONTEXT = X_CONTEXT )
	OR ( (Recinfo.CONTEXT IS NULL)
	AND (X_CONTEXT IS NULL)))

AND (   ( Recinfo.ATTRIBUTE1 = X_ATTRIBUTE1 )
	OR ( (Recinfo.ATTRIBUTE1 IS NULL)
	AND (X_ATTRIBUTE1 IS NULL)))

AND (   ( Recinfo.ATTRIBUTE2 = X_ATTRIBUTE2 )
	OR ( (Recinfo.ATTRIBUTE2 IS NULL)
	AND (X_ATTRIBUTE2 IS NULL)))

AND (   ( Recinfo.ATTRIBUTE3 = X_ATTRIBUTE3 )
	OR ( (Recinfo.ATTRIBUTE3 IS NULL)
	AND (X_ATTRIBUTE3 IS NULL)))

AND (   ( Recinfo.ATTRIBUTE4 = X_ATTRIBUTE4 )
	OR ( (Recinfo.ATTRIBUTE4 IS NULL)
	AND (X_ATTRIBUTE4 IS NULL)))

AND (   ( Recinfo.ATTRIBUTE5 = X_ATTRIBUTE5 )
	OR ( (Recinfo.ATTRIBUTE5 IS NULL)
	AND (X_ATTRIBUTE5 IS NULL)))

AND (   ( Recinfo.ATTRIBUTE6 = X_ATTRIBUTE6 )
	OR ( (Recinfo.ATTRIBUTE6 IS NULL)
	AND (X_ATTRIBUTE6 IS NULL)))

AND (   ( Recinfo.ATTRIBUTE7 = X_ATTRIBUTE7 )
	OR ( (Recinfo.ATTRIBUTE7 IS NULL)
	AND (X_ATTRIBUTE7 IS NULL)))

AND (   ( Recinfo.ATTRIBUTE8 = X_ATTRIBUTE8 )
	OR ( (Recinfo.ATTRIBUTE8 IS NULL)
	AND (X_ATTRIBUTE8 IS NULL)))

AND (   ( Recinfo.ATTRIBUTE9 = X_ATTRIBUTE9 )
	OR ( (Recinfo.ATTRIBUTE9 IS NULL)
	AND (X_ATTRIBUTE9 IS NULL)))

AND (   ( Recinfo.ATTRIBUTE10 = X_ATTRIBUTE10 )
	OR ( (Recinfo.ATTRIBUTE10 IS NULL)
	AND (X_ATTRIBUTE10 IS NULL)))

AND (   ( Recinfo.ATTRIBUTE11 = X_ATTRIBUTE11 )
	OR ( (Recinfo.ATTRIBUTE11 IS NULL)
	AND (X_ATTRIBUTE11 IS NULL)))

AND (   ( Recinfo.ATTRIBUTE12 = X_ATTRIBUTE12 )
	OR ( (Recinfo.ATTRIBUTE12 IS NULL)
	AND (X_ATTRIBUTE12 IS NULL)))

AND (   ( Recinfo.ATTRIBUTE13 = X_ATTRIBUTE13 )
	OR ( (Recinfo.ATTRIBUTE13 IS NULL)
	AND (X_ATTRIBUTE13 IS NULL)))

AND (   ( Recinfo.ATTRIBUTE14 = X_ATTRIBUTE14 )
	OR ( (Recinfo.ATTRIBUTE14 IS NULL)
	AND (X_ATTRIBUTE14 IS NULL)))

AND (   ( Recinfo.ATTRIBUTE15 = X_ATTRIBUTE15 )
	OR ( (Recinfo.ATTRIBUTE15 IS NULL)
	AND (X_ATTRIBUTE15 IS NULL)))

) then

return;

else

FND_MESSAGE.Set_Name('FND','FORM_RECORD_CHANGED');
APP_EXCEPTION.Raise_Exception;

end if;

end Lock_Row;


PROCEDURE Update_Row(
  X_RLTD_MODIFIER_ID    IN OUT NOCOPY /* file.sql.39 change */  NUMBER
, X_CREATION_DATE                  DATE
, X_CREATED_BY                     NUMBER
, X_LAST_UPDATE_DATE               DATE
, X_LAST_UPDATED_BY                NUMBER
, X_LAST_UPDATE_LOGIN              NUMBER
, X_RLTD_MODIFIER_GRP_NO                NUMBER
, X_FROM_RLTD_MODIFIER_ID               NUMBER
, X_TO_RLTD_MODIFIER_ID         NUMBER
, X_RLTD_MODIFIER_GRP_TYPE         VARCHAR2
, X_CONTEXT                        VARCHAR2
, X_ATTRIBUTE1                     VARCHAR2
, X_ATTRIBUTE2                     VARCHAR2
, X_ATTRIBUTE3                     VARCHAR2
, X_ATTRIBUTE4                     VARCHAR2
, X_ATTRIBUTE5                     VARCHAR2
, X_ATTRIBUTE6                     VARCHAR2
, X_ATTRIBUTE7                     VARCHAR2
, X_ATTRIBUTE8                     VARCHAR2
, X_ATTRIBUTE9                     VARCHAR2
, X_ATTRIBUTE10                    VARCHAR2
, X_ATTRIBUTE11                    VARCHAR2
, X_ATTRIBUTE12                    VARCHAR2
, X_ATTRIBUTE13                    VARCHAR2
, X_ATTRIBUTE14                    VARCHAR2
, X_ATTRIBUTE15                    VARCHAR2
) IS
begin

UPDATE QP_RLTD_MODIFIERS
SET
  RLTD_MODIFIER_ID			=	X_RLTD_MODIFIER_ID
, CREATION_DATE			=	X_CREATION_DATE
, CREATED_BY				=	X_CREATED_BY
, LAST_UPDATE_DATE			=	X_LAST_UPDATE_DATE
, LAST_UPDATED_BY			=	X_LAST_UPDATED_BY
, LAST_UPDATE_LOGIN			=	X_LAST_UPDATE_LOGIN
, RLTD_MODIFIER_GRP_NO		=	X_RLTD_MODIFIER_GRP_NO
, FROM_RLTD_MODIFIER_ID		=	X_FROM_RLTD_MODIFIER_ID
, TO_RLTD_MODIFIER_ID		=	X_TO_RLTD_MODIFIER_ID
, RLTD_MODIFIER_GRP_TYPE      =    X_RLTD_MODIFIER_GRP_TYPE
, ATTRIBUTE3				=	X_ATTRIBUTE3
, ATTRIBUTE4				=	X_ATTRIBUTE4
, ATTRIBUTE5				=	X_ATTRIBUTE5
, ATTRIBUTE6				=	X_ATTRIBUTE6
, ATTRIBUTE7				=	X_ATTRIBUTE7
, ATTRIBUTE8				=	X_ATTRIBUTE8
, ATTRIBUTE9				=	X_ATTRIBUTE9
, ATTRIBUTE10				=	X_ATTRIBUTE10
, ATTRIBUTE11				=	X_ATTRIBUTE11
, ATTRIBUTE12				=	X_ATTRIBUTE12
, ATTRIBUTE13				=	X_ATTRIBUTE13
, ATTRIBUTE14				=	X_ATTRIBUTE14
, ATTRIBUTE15				=	X_ATTRIBUTE15
WHERE RLTD_MODIFIER_ID = X_RLTD_MODIFIER_ID;

if (sql%notfound) then
raise no_data_found;
end if;

END Update_Row;




PROCEDURE Delete_Row(
X_TO_RLTD_MODIFIER_ID	NUMBER
) IS
begin

delete from QP_RLTD_MODIFIERS
where TO_RLTD_MODIFIER_ID= X_TO_RLTD_MODIFIER_ID;

if (SQL%NOTFOUND) then
	Raise NO_DATA_FOUND;
end if;


END Delete_Row;




END QP_RLTD_MODIFIER_PVT;

/
