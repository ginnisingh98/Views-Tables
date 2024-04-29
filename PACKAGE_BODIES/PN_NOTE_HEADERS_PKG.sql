--------------------------------------------------------
--  DDL for Package Body PN_NOTE_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_NOTE_HEADERS_PKG" AS
  -- $Header: PNTNOTHB.pls 115.10 2004/05/26 07:03:43 abanerje ship $

------------------------------------------------------------------
-- PROCEDURE : INSERT_ROW
------------------------------------------------------------------
procedure INSERT_ROW
        (
                X_ROWID                         IN OUT NOCOPY VARCHAR2,
                X_NOTE_HEADER_ID                IN OUT NOCOPY NUMBER,
                X_LEASE_ID                      IN            NUMBER,
                X_NOTE_TYPE_LOOKUP_CODE         IN            VARCHAR2,
                X_NOTE_DATE                     IN            DATE,
                X_CREATION_DATE                 IN            DATE,
                X_CREATED_BY                    IN            NUMBER,
                X_LAST_UPDATE_DATE              IN            DATE,
                X_LAST_UPDATED_BY               IN            NUMBER,
                X_LAST_UPDATE_LOGIN             IN            NUMBER,
		X_ATTRIBUTE_CATEGORY            IN            VARCHAR2, --3626177
                X_ATTRIBUTE1          		IN 	      VARCHAR2,
  		X_ATTRIBUTE2          		IN 	      VARCHAR2,
  		X_ATTRIBUTE3          		IN 	      VARCHAR2,
  		X_ATTRIBUTE4          		IN 	      VARCHAR2,
  		X_ATTRIBUTE5          		IN 	      VARCHAR2,
  		X_ATTRIBUTE6          		IN 	      VARCHAR2,
  		X_ATTRIBUTE7          		IN 	      VARCHAR2,
  		X_ATTRIBUTE8          		IN 	      VARCHAR2,
  		X_ATTRIBUTE9          		IN 	      VARCHAR2,
  		X_ATTRIBUTE10         		IN 	      VARCHAR2,
  		X_ATTRIBUTE11         		IN 	      VARCHAR2,
  		X_ATTRIBUTE12         		IN 	      VARCHAR2,
  		X_ATTRIBUTE13         		IN 	      VARCHAR2,
  		X_ATTRIBUTE14         		IN 	      VARCHAR2,
  		X_ATTRIBUTE15         		IN 	      VARCHAR2
        ) is
   cursor C is
      select ROWID
      from   PN_NOTE_HEADERS
      where  NOTE_HEADER_ID = X_NOTE_HEADER_ID;
BEGIN

   IF (X_NOTE_HEADER_ID IS NULL) THEN
      select PN_NOTE_HEADERS_S.nextval
      into   X_NOTE_HEADER_ID
      from   dual;
   END IF;

   insert into PN_NOTE_HEADERS
   (
                NOTE_HEADER_ID,
                NOTE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN,
                CREATED_BY,
                CREATION_DATE,
                NOTE_TYPE_LOOKUP_CODE,
                LEASE_ID,
		ATTRIBUTE_CATEGORY, --3626177
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
		ATTRIBUTE15
   )
   values
   (
                X_NOTE_HEADER_ID,
                X_NOTE_DATE,
                X_LAST_UPDATED_BY,
                X_LAST_UPDATE_DATE,
                X_LAST_UPDATE_LOGIN,
                X_CREATED_BY,
                X_CREATION_DATE,
                X_NOTE_TYPE_LOOKUP_CODE,
                X_LEASE_ID,
		X_ATTRIBUTE_CATEGORY, --3626177
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
    		X_ATTRIBUTE15

   );

   open c;
   fetch c into X_ROWID;
   if (c%notfound) then
      close c;
      raise no_data_found;
   end if;
   close c;

END INSERT_ROW;

------------------------------------------------------------------
-- PROCEDURE : LOCK_ROW
------------------------------------------------------------------
PROCEDURE LOCK_ROW
        (
                X_NOTE_HEADER_ID                in NUMBER,
                X_LEASE_ID                      in NUMBER,
                X_NOTE_DATE                     in DATE,
                X_NOTE_TYPE_LOOKUP_CODE         in VARCHAR2,
		X_ATTRIBUTE_CATEGORY            in VARCHAR2, --3626177
                X_ATTRIBUTE1          		in VARCHAR2,
  		X_ATTRIBUTE2          		in VARCHAR2,
  		X_ATTRIBUTE3          		in VARCHAR2,
  		X_ATTRIBUTE4          		in VARCHAR2,
  		X_ATTRIBUTE5          		in VARCHAR2,
  		X_ATTRIBUTE6          		in VARCHAR2,
  		X_ATTRIBUTE7          		in VARCHAR2,
  		X_ATTRIBUTE8          		in VARCHAR2,
  		X_ATTRIBUTE9          		in VARCHAR2,
  		X_ATTRIBUTE10         		in VARCHAR2,
  		X_ATTRIBUTE11         		in VARCHAR2,
  		X_ATTRIBUTE12         		in VARCHAR2,
  		X_ATTRIBUTE13         		in VARCHAR2,
  		X_ATTRIBUTE14         		in VARCHAR2,
  		X_ATTRIBUTE15         		in VARCHAR2
        )
is
   cursor c1 is
      select *
      from   PN_NOTE_HEADERS
      where  NOTE_HEADER_ID = X_NOTE_HEADER_ID
      for update of NOTE_HEADER_ID nowait;

   tlinfo c1%rowtype;

BEGIN
   open c1;
   fetch c1 into tlinfo;
   if (c1%notfound) then
      close c1;
      return;
   end if;
   close c1;
   --3626177

   IF NOT (tlinfo.NOTE_HEADER_ID = X_NOTE_HEADER_ID) THEN
        PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('NOTE_HEADER_ID',tlinfo.NOTE_HEADER_ID);
   END IF;

   IF NOT ((tlinfo.NOTE_TYPE_LOOKUP_CODE = X_NOTE_TYPE_LOOKUP_CODE)
          OR ((tlinfo.NOTE_TYPE_LOOKUP_CODE is null) AND (X_NOTE_TYPE_LOOKUP_CODE is null))) THEN
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('NOTE_TYPE_LOOKUP_CODE',tlinfo.NOTE_TYPE_LOOKUP_CODE);
   END IF;

   IF NOT ((tlinfo.NOTE_DATE = X_NOTE_DATE)
        OR ((tlinfo.NOTE_DATE is null) AND (X_NOTE_DATE is null))) THEN
        PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('NOTE_DATE',tlinfo.NOTE_DATE);
   END IF;

   IF NOT ((tlinfo.LEASE_ID = X_LEASE_ID)
        OR ((tlinfo.LEASE_ID is null) AND (X_LEASE_ID is null))) THEN
        PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('LEASE_ID',tlinfo.LEASE_ID);
   END IF;


   IF NOT ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
        OR ((tlinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null))) THEN
        PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE_CATEGORY',tlinfo.ATTRIBUTE_CATEGORY);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
        OR ((tlinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null))) THEN
        PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE1',tlinfo.ATTRIBUTE1);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
        OR ((tlinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null))) THEN
        PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE2',tlinfo.ATTRIBUTE2);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
        OR ((tlinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null))) THEN
        PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE3',tlinfo.ATTRIBUTE3);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
        OR ((tlinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null))) THEN
        PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE4',tlinfo.ATTRIBUTE4);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
        OR ((tlinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null))) THEN
        PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE5',tlinfo.ATTRIBUTE5);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
        OR ((tlinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null))) THEN
        PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE6',tlinfo.ATTRIBUTE6);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
        OR ((tlinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null))) THEN
        PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE7',tlinfo.ATTRIBUTE7);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
        OR ((tlinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null))) THEN
        PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE8',tlinfo.ATTRIBUTE8);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
        OR ((tlinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null))) THEN
        PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE9',tlinfo.ATTRIBUTE9);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
        OR ((tlinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null))) THEN
        PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE10',tlinfo.ATTRIBUTE10);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
        OR ((tlinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null))) THEN
        PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE11',tlinfo.ATTRIBUTE11);
   END IF;


   IF NOT ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
        OR ((tlinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null))) THEN
        PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE12',tlinfo.ATTRIBUTE12);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
        OR ((tlinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null))) THEN
        PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE13',tlinfo.ATTRIBUTE13);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
        OR ((tlinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null))) THEN
        PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE14',tlinfo.ATTRIBUTE14);
   END IF;


   IF NOT ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
        OR ((tlinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null))) THEN
        PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE15',tlinfo.ATTRIBUTE15);
   END IF;

   RETURN;
END LOCK_ROW;

------------------------------------------------------------------
-- PROCEDURE : UPDATE_ROW
------------------------------------------------------------------
procedure UPDATE_ROW
        (
                X_NOTE_HEADER_ID                in NUMBER,
                X_LEASE_ID                      in NUMBER,
                X_NOTE_TYPE_LOOKUP_CODE         in VARCHAR2,
                X_NOTE_DATE                     in        DATE,
                X_LAST_UPDATE_DATE              in DATE,
                X_LAST_UPDATED_BY               in NUMBER,
                X_LAST_UPDATE_LOGIN             in NUMBER,
		X_ATTRIBUTE_CATEGORY            in VARCHAR2, --3626177
                X_ATTRIBUTE1          		in VARCHAR2,
  		X_ATTRIBUTE2          		in VARCHAR2,
  		X_ATTRIBUTE3          		in VARCHAR2,
  		X_ATTRIBUTE4          		in VARCHAR2,
  		X_ATTRIBUTE5          		in VARCHAR2,
  		X_ATTRIBUTE6          		in VARCHAR2,
  		X_ATTRIBUTE7          		in VARCHAR2,
  		X_ATTRIBUTE8          		in VARCHAR2,
  		X_ATTRIBUTE9          		in VARCHAR2,
  		X_ATTRIBUTE10         		in VARCHAR2,
  		X_ATTRIBUTE11         		in VARCHAR2,
  		X_ATTRIBUTE12         		in VARCHAR2,
  		X_ATTRIBUTE13         		in VARCHAR2,
  		X_ATTRIBUTE14         		in VARCHAR2,
  		X_ATTRIBUTE15         		in VARCHAR2
        )
IS
BEGIN
   update PN_NOTE_HEADERS
      set LEASE_ID                        = X_LEASE_ID,
          NOTE_DATE                       = X_NOTE_DATE,
          NOTE_TYPE_LOOKUP_CODE           = X_NOTE_TYPE_LOOKUP_CODE,
          LAST_UPDATE_DATE                = X_LAST_UPDATE_DATE,
          LAST_UPDATED_BY                 = X_LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN               = X_LAST_UPDATE_LOGIN,
	  ATTRIBUTE_CATEGORY              = X_ATTRIBUTE_CATEGORY, --3626177
          ATTRIBUTE1          		  = X_ATTRIBUTE1,
      	  ATTRIBUTE2          		  = X_ATTRIBUTE2,
      	  ATTRIBUTE3          		  = X_ATTRIBUTE3,
      	  ATTRIBUTE4          		  = X_ATTRIBUTE4,
      	  ATTRIBUTE5          		  = X_ATTRIBUTE5,
      	  ATTRIBUTE6          		  = X_ATTRIBUTE6,
      	  ATTRIBUTE7          		  = X_ATTRIBUTE7,
      	  ATTRIBUTE8          		  = X_ATTRIBUTE8,
      	  ATTRIBUTE9          		  = X_ATTRIBUTE9,
      	  ATTRIBUTE10         		  = X_ATTRIBUTE10,
      	  ATTRIBUTE11         		  = X_ATTRIBUTE11,
      	  ATTRIBUTE12         		  = X_ATTRIBUTE12,
      	  ATTRIBUTE13         		  = X_ATTRIBUTE13,
      	  ATTRIBUTE14         		  = X_ATTRIBUTE14,
	  ATTRIBUTE15         		  = X_ATTRIBUTE15
    where NOTE_HEADER_ID = X_NOTE_HEADER_ID;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

END UPDATE_ROW;

------------------------------------------------------------------
-- PROCEDURE : DELETE_ROW
------------------------------------------------------------------
PROCEDURE DELETE_ROW
        (
                X_NOTE_HEADER_ID in NUMBER
        )
is
   cursor c is
      select note_detail_id
      from   pn_note_details
      where  note_header_id = X_NOTE_HEADER_ID
      for update of note_detail_id nowait;
BEGIN
   -- first we need to delete the note detail rows.
   FOR i IN C LOOP
      PN_NOTE_DETAILS_PKG.DELETE_ROW (X_NOTE_DETAIL_ID =>i.note_detail_id);
   END LOOP;

   delete from PN_NOTE_HEADERS where NOTE_HEADER_ID = X_NOTE_HEADER_ID;

   if (sql%notfound) then
      raise no_data_found;
   end if;

END DELETE_ROW;

END PN_NOTE_HEADERS_PKG;

/
