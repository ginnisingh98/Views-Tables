--------------------------------------------------------
--  DDL for Package Body ASO_PRICE_RLTSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_PRICE_RLTSHIPS_PKG" as
/* $Header: asotprlb.pls 120.1 2005/06/29 12:40:08 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_PRICE_RLTSHIPS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_PRICE_RELATIONSHIPS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asotprlb.pls';

PROCEDURE Insert_Row(
          px_ADJ_RELATIONSHIP_ID  IN OUT NOCOPY /* file.sql.39 change */  NUMBER,
          p_CREATION_DATE                  DATE,
          p_CREATED_BY                   NUMBER,
          p_LAST_UPDATE_DATE         DATE,
          p_LAST_UPDATED_BY         NUMBER,
          p_LAST_UPDATE_LOGIN      NUMBER,
          p_PROGRAM_APPLICATION_ID NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_REQUEST_ID     NUMBER,
          p_QUOTE_LINE_ID  NUMBER,
          p_PRICE_ADJUSTMENT_ID  NUMBER,
          p_RLTD_PRICE_ADJ_ID  NUMBER,
		p_quote_shipment_id  NUMBER := NULL,
          p_OBJECT_VERSION_NUMBER  NUMBER
		)
IS
   CURSOR C2 IS SELECT ASO_PRICE_RELATIONSHIPS_S.nextval FROM sys.dual;
BEGIN
   If (px_ADJ_RELATIONSHIP_ID IS NULL) OR (px_ADJ_RELATIONSHIP_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_ADJ_RELATIONSHIP_ID;
       CLOSE C2;
   End If;
   INSERT INTO ASO_PRICE_ADJ_RELATIONSHIPS(
           ADJ_RELATIONSHIP_ID,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           QUOTE_LINE_ID,
	   PRICE_ADJUSTMENT_ID,
	   RLTD_PRICE_ADJ_ID,
	   quote_shipment_id,
           OBJECT_VERSION_NUMBER
          ) VALUES (
           px_ADJ_RELATIONSHIP_ID,
           ASO_UTILITY_PVT.decode( p_CREATION_DATE, FND_API.G_MISS_DATE, NULL, p_CREATION_DATE),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           ASO_UTILITY_PVT.decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_REQUEST_ID, FND_API.G_MISS_NUM, NULL, p_REQUEST_ID),
           decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_APPLICATION_ID),
           decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_ID),
           ASO_UTILITY_PVT.decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, p_PROGRAM_UPDATE_DATE),
           decode( p_QUOTE_LINE_ID, FND_API.G_MISS_NUM, NULL, p_QUOTE_LINE_ID),
           decode( p_PRICE_ADJUSTMENT_ID, FND_API.G_MISS_NUM, NULL, p_PRICE_ADJUSTMENT_ID),
           decode( p_RLTD_PRICE_ADJ_ID, FND_API.G_MISS_NUM, NULL, p_RLTD_PRICE_ADJ_ID),
		 decode( p_quote_shipment_id, FND_API.G_MISS_NUM, NULL,p_quote_shipment_id),
           decode ( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM,1,NULL,1, p_OBJECT_VERSION_NUMBER)
				   );
End Insert_Row;

PROCEDURE Update_Row(
          p_ADJ_RELATIONSHIP_ID     NUMBER,
          p_CREATION_DATE           DATE,
          p_CREATED_BY              NUMBER,
          p_LAST_UPDATE_DATE        DATE,
          p_LAST_UPDATED_BY         NUMBER,
          p_LAST_UPDATE_LOGIN       NUMBER,
          p_PROGRAM_APPLICATION_ID  NUMBER,
          p_PROGRAM_ID              NUMBER,
          p_PROGRAM_UPDATE_DATE     DATE,
          p_REQUEST_ID              NUMBER,
          p_QUOTE_LINE_ID           NUMBER,
          p_PRICE_ADJUSTMENT_ID     NUMBER,
          p_RLTD_PRICE_ADJ_ID       NUMBER,
		p_quote_shipment_id       NUMBER,
          p_OBJECT_VERSION_NUMBER  NUMBER
		)

 IS
 BEGIN
    Update ASO_PRICE_ADJ_RELATIONSHIPS
    SET
              CREATION_DATE = ASO_UTILITY_PVT.decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = ASO_UTILITY_PVT.decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              REQUEST_ID = decode( p_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID, p_REQUEST_ID),
              PROGRAM_APPLICATION_ID = decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, PROGRAM_APPLICATION_ID, p_PROGRAM_APPLICATION_ID),
              PROGRAM_ID = decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, PROGRAM_ID, p_PROGRAM_ID),
              PROGRAM_UPDATE_DATE = ASO_UTILITY_PVT.decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, PROGRAM_UPDATE_DATE, p_PROGRAM_UPDATE_DATE),
              QUOTE_LINE_ID = decode( p_QUOTE_LINE_ID, FND_API.G_MISS_NUM,
QUOTE_LINE_ID, p_QUOTE_LINE_ID),
	      PRICE_ADJUSTMENT_ID = decode( p_PRICE_ADJUSTMENT_ID, FND_API.G_MISS_NUM, PRICE_ADJUSTMENT_ID, p_PRICE_ADJUSTMENT_ID),
	      RLTD_PRICE_ADJ_ID = decode( p_RLTD_PRICE_ADJ_ID, FND_API.G_MISS_NUM, RLTD_PRICE_ADJ_ID, p_RLTD_PRICE_ADJ_ID),
		  quote_shipment_id  =  decode( p_quote_shipment_id, FND_API.G_MISS_NUM , quote_shipment_id,p_quote_shipment_id),
		  OBJECT_VERSION_NUMBER = decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, nvl(OBJECT_VERSION_NUMBER,0)+1, nvl(p_OBJECT_VERSION_NUMBER, nvl(OBJECT_VERSION_NUMBER,0))+1)
    where ADJ_RELATIONSHIP_ID = p_ADJ_RELATIONSHIP_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_ADJ_RELATIONSHIP_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM ASO_PRICE_ADJ_RELATIONSHIPS
    WHERE ADJ_RELATIONSHIP_ID = p_ADJ_RELATIONSHIP_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          --p_OBJECT_VERSION_NUMBER  NUMBER,
          p_ADJ_RELATIONSHIP_ID  NUMBER,
          p_CREATION_DATE                  DATE,
          p_CREATED_BY                   NUMBER,
          p_LAST_UPDATE_DATE         DATE,
          p_LAST_UPDATED_BY         NUMBER,
          p_LAST_UPDATE_LOGIN      NUMBER,
          p_PROGRAM_APPLICATION_ID NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_REQUEST_ID     NUMBER,
          p_QUOTE_LINE_ID  NUMBER,
          p_PRICE_ADJUSTMENT_ID  NUMBER,
          p_RLTD_PRICE_ADJ_ID  NUMBER,
		p_quote_shipment_id                        NUMBER)
 IS
   CURSOR C IS
        SELECT ADJ_RELATIONSHIP_ID,
	   --OBJECT_VERSION_NUMBER,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN,
PROGRAM_APPLICATION_ID,
PROGRAM_ID,
PROGRAM_UPDATE_DATE,
REQUEST_ID,
QUOTE_LINE_ID,
PRICE_ADJUSTMENT_ID,
RLTD_PRICE_ADJ_ID,
quote_shipment_id
         FROM ASO_PRICE_ADJ_RELATIONSHIPS
        WHERE ADJ_RELATIONSHIP_ID =  p_ADJ_RELATIONSHIP_ID
        FOR UPDATE of ADJ_RELATIONSHIP_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    If (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
    CLOSE C;
    if (
/*
           (      Recinfo.ADJ_RELATIONSHIP_ID = p_ADJ_RELATIONSHIP_ID)
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND
*/
	  (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
/*
      AND
       (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
         OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
             AND (  p_OBJECT_VERSION_NUMBER IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.REQUEST_ID = p_REQUEST_ID)
            OR (    ( Recinfo.REQUEST_ID IS NULL )
                AND (  p_REQUEST_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_APPLICATION_ID = p_PROGRAM_APPLICATION_ID)
            OR (    ( Recinfo.PROGRAM_APPLICATION_ID IS NULL )
                AND (  p_PROGRAM_APPLICATION_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_ID = p_PROGRAM_ID)
            OR (    ( Recinfo.PROGRAM_ID IS NULL )
                AND (  p_PROGRAM_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_UPDATE_DATE = p_PROGRAM_UPDATE_DATE)
            OR (    ( Recinfo.PROGRAM_UPDATE_DATE IS NULL )
                AND (  p_PROGRAM_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.QUOTE_LINE_ID = p_QUOTE_LINE_ID)
            OR (    ( Recinfo.QUOTE_LINE_ID IS NULL )
                AND (  p_QUOTE_LINE_ID IS NULL )))
       AND (    ( Recinfo.PRICE_ADJUSTMENT_ID = p_PRICE_ADJUSTMENT_ID)
            OR (    ( Recinfo.PRICE_ADJUSTMENT_ID IS NULL )
                AND (  p_PRICE_ADJUSTMENT_ID IS NULL )))
       AND (    ( Recinfo.RLTD_PRICE_ADJ_ID = p_RLTD_PRICE_ADJ_ID)
            OR (    ( Recinfo.RLTD_PRICE_ADJ_ID IS NULL )
                AND (  p_RLTD_PRICE_ADJ_ID IS NULL )))
	 AND (    ( Recinfo.quote_shipment_id  = p_quote_shipment_id)
		   OR (    ( Recinfo.quote_shipment_id  IS NULL )
 		    AND (  p_quote_shipment_id IS NULL )))

*/
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End ASO_PRICE_RLTSHIPS_PKG;

/
