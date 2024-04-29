--------------------------------------------------------
--  DDL for Package Body WMS_LABEL_FORMATS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_LABEL_FORMATS_PKG" as
/* $Header: WMSLBFMB.pls 120.2 2005/06/22 09:25:52 appldev ship $ */

   TRACE_LEVEL	CONSTANT NUMBER := 2;
   TRACE_PROMPT CONSTANT VARCHAR2(10) := 'LB_FORMATS';
procedure INSERT_ROW (
  X_ROWID 	 IN OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2,  -- NOCOPY added as a part of Bug# 4380449
  X_LABEL_FORMAT_ID	in 	NUMBER,
  X_LABEL_FORMAT_NAME   in      VARCHAR2,
  X_FORMAT_DESCRIPTION  in      VARCHAR2,
  X_DOCUMENT_ID		in 	NUMBER,
  X_DEFAULT_FORMAT_FLAG	in      VARCHAR2,
  X_FORMAT_DISABLE_DATE in      VARCHAR2,
  X_LAST_UPDATE_DATE 	in DATE,
  X_LAST_UPDATED_BY 	in NUMBER,
  X_LAST_UPDATE_LOGIN 	in NUMBER,
  X_CREATED_BY          in NUMBER,
  X_CREATION_DATE       in DATE,
  X_REQUEST_ID		in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID		in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE,
  X_ATTRIBUTE_CATEGORY 	in VARCHAR2,
  X_ATTRIBUTE1 		in VARCHAR2,
  X_ATTRIBUTE2 		in VARCHAR2,
  X_ATTRIBUTE3 		in VARCHAR2,
  X_ATTRIBUTE4 		in VARCHAR2,
  X_ATTRIBUTE5 		in VARCHAR2,
  X_ATTRIBUTE6 		in VARCHAR2,
  X_ATTRIBUTE7 		in VARCHAR2,
  X_ATTRIBUTE8 		in VARCHAR2,
  X_ATTRIBUTE9 		in VARCHAR2,
  X_ATTRIBUTE10 	in VARCHAR2,
  X_ATTRIBUTE11 	in VARCHAR2,
  X_ATTRIBUTE12 	in VARCHAR2,
  X_ATTRIBUTE13 	in VARCHAR2,
  X_ATTRIBUTE14 	in VARCHAR2,
  X_ATTRIBUTE15 	in VARCHAR2
) is
  cursor C is select ROWID from WMS_LABEL_FORMATS
    where LABEL_FORMAT_ID = X_LABEL_FORMAT_ID
    ;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
  insert into WMS_LABEL_FORMATS (
  LABEL_FORMAT_ID,
  LABEL_FORMAT_NAME  ,
  FORMAT_DESCRIPTION,
  DOCUMENT_ID	,
  DEFAULT_FORMAT_FLAG,
  FORMAT_DISABLE_DATE,
  LAST_UPDATE_DATE ,
  LAST_UPDATED_BY ,
  LAST_UPDATE_LOGIN,
  CREATED_BY      ,
  CREATION_DATE  ,
  REQUEST_ID	,
  PROGRAM_APPLICATION_ID,
  PROGRAM_ID		,
  PROGRAM_UPDATE_DATE,
  ATTRIBUTE_CATEGORY,
  ATTRIBUTE1 	,
  ATTRIBUTE2 ,
  ATTRIBUTE3 ,
  ATTRIBUTE4 ,
  ATTRIBUTE5 ,
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
  ) values (
  X_LABEL_FORMAT_ID	,
  X_LABEL_FORMAT_NAME ,
  X_FORMAT_DESCRIPTION,
  X_DOCUMENT_ID	,
  X_DEFAULT_FORMAT_FLAG,
  X_FORMAT_DISABLE_DATE,
  X_LAST_UPDATE_DATE ,
  X_LAST_UPDATED_BY ,
  X_LAST_UPDATE_LOGIN,
  X_CREATED_BY      ,
  X_CREATION_DATE  ,
  X_REQUEST_ID	,
  X_PROGRAM_APPLICATION_ID,
  X_PROGRAM_ID		,
  X_PROGRAM_UPDATE_DATE,
  X_ATTRIBUTE_CATEGORY,
  X_ATTRIBUTE1 	,
  X_ATTRIBUTE2 ,
  X_ATTRIBUTE3 ,
  X_ATTRIBUTE4 ,
  X_ATTRIBUTE5 ,
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

end INSERT_ROW;

procedure LOCK_ROW (
  X_LABEL_FORMAT_ID	in 	NUMBER,
  X_LABEL_FORMAT_NAME   in      VARCHAR2,
  X_FORMAT_DESCRIPTION  in      VARCHAR2,
  X_DOCUMENT_ID		in 	NUMBER,
  X_DEFAULT_FORMAT_FLAG	in      VARCHAR2,
  X_FORMAT_DISABLE_DATE in      VARCHAR2,
  X_LAST_UPDATE_DATE 	in DATE,
  X_LAST_UPDATED_BY 	in NUMBER,
  X_LAST_UPDATE_LOGIN 	in NUMBER,
  X_CREATED_BY          in NUMBER,
  X_CREATION_DATE       in DATE,
  X_REQUEST_ID		in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID		in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE,
  X_ATTRIBUTE_CATEGORY 	in VARCHAR2,
  X_ATTRIBUTE1 		in VARCHAR2,
  X_ATTRIBUTE2 		in VARCHAR2,
  X_ATTRIBUTE3 		in VARCHAR2,
  X_ATTRIBUTE4 		in VARCHAR2,
  X_ATTRIBUTE5 		in VARCHAR2,
  X_ATTRIBUTE6 		in VARCHAR2,
  X_ATTRIBUTE7 		in VARCHAR2,
  X_ATTRIBUTE8 		in VARCHAR2,
  X_ATTRIBUTE9 		in VARCHAR2,
  X_ATTRIBUTE10 	in VARCHAR2,
  X_ATTRIBUTE11 	in VARCHAR2,
  X_ATTRIBUTE12 	in VARCHAR2,
  X_ATTRIBUTE13 	in VARCHAR2,
  X_ATTRIBUTE14 	in VARCHAR2,
  X_ATTRIBUTE15 	in VARCHAR2
) is
  cursor c is select
      LABEL_FORMAT_NAME,
      FORMAT_DESCRIPTION,
      DOCUMENT_ID,
      DEFAULT_FORMAT_FLAG,
      FORMAT_DISABLE_DATE,
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
      ATTRIBUTE15
    from WMS_LABEL_FORMATS
    where LABEL_FORMAT_ID = X_LABEL_FORMAT_ID
    for update of LABEL_FORMAT_ID nowait;
  recinfo c%rowtype;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.DOCUMENT_ID = X_DOCUMENT_ID)
      AND ((recinfo.LABEL_FORMAT_NAME = X_LABEL_FORMAT_NAME)
           OR ((recinfo.LABEL_FORMAT_NAME is null) AND (X_LABEL_FORMAT_NAME is null)))
      AND ((recinfo.FORMAT_DESCRIPTION = X_FORMAT_DESCRIPTION)
           OR ((recinfo.FORMAT_DESCRIPTION is null) AND (X_FORMAT_DESCRIPTION is null)))
      AND ((recinfo.DEFAULT_FORMAT_FLAG = X_DEFAULT_FORMAT_FLAG)
           OR ((recinfo.DEFAULT_FORMAT_FLAG is null) AND (X_DEFAULT_FORMAT_FLAG is null)))
     AND ((recinfo.FORMAT_DISABLE_DATE = x_FORMAT_DISABLE_DATE)
             OR ((recinfo.FORMAT_DISABLE_DATE IS NULL)
            AND (x_FORMAT_DISABLE_DATE IS NULL)))

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
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_LABEL_FORMAT_ID	in 	NUMBER,
  X_LABEL_FORMAT_NAME   in      VARCHAR2,
  X_FORMAT_DESCRIPTION  in      VARCHAR2,
  X_DOCUMENT_ID		in 	NUMBER,
  X_DEFAULT_FORMAT_FLAG	in      VARCHAR2,
  X_FORMAT_DISABLE_DATE in      VARCHAR2,
  X_LAST_UPDATE_DATE 	in DATE,
  X_LAST_UPDATED_BY 	in NUMBER,
  X_LAST_UPDATE_LOGIN 	in NUMBER,
  X_CREATED_BY          in NUMBER,
  X_CREATION_DATE       in DATE,
  X_REQUEST_ID		in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID		in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE,
  X_ATTRIBUTE_CATEGORY 	in VARCHAR2,
  X_ATTRIBUTE1 		in VARCHAR2,
  X_ATTRIBUTE2 		in VARCHAR2,
  X_ATTRIBUTE3 		in VARCHAR2,
  X_ATTRIBUTE4 		in VARCHAR2,
  X_ATTRIBUTE5 		in VARCHAR2,
  X_ATTRIBUTE6 		in VARCHAR2,
  X_ATTRIBUTE7 		in VARCHAR2,
  X_ATTRIBUTE8 		in VARCHAR2,
  X_ATTRIBUTE9 		in VARCHAR2,
  X_ATTRIBUTE10 	in VARCHAR2,
  X_ATTRIBUTE11 	in VARCHAR2,
  X_ATTRIBUTE12 	in VARCHAR2,
  X_ATTRIBUTE13 	in VARCHAR2,
  X_ATTRIBUTE14 	in VARCHAR2,
  X_ATTRIBUTE15 	in VARCHAR2
) is
l_msg    varchar2(2000);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
  IF (l_debug = 1) THEN
     INV_LOG_UTIL.trace(' X_LABEL_FORMAT_ID: '||X_LABEL_FORMAT_ID , TRACE_PROMPT, TRACE_LEVEL);
  END IF;
  update WMS_LABEL_FORMATS
     set DOCUMENT_ID 	= X_DOCUMENT_ID,
    LABEL_FORMAT_NAME   = X_LABEL_FORMAT_NAME,
    FORMAT_DESCRIPTION 	= X_FORMAT_DESCRIPTION,
    DEFAULT_FORMAT_FLAG = X_DEFAULT_FORMAT_FLAG,
    FORMAT_DISABLE_DATE = X_FORMAT_DISABLE_DATE,
    ATTRIBUTE_CATEGORY 	= X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 		= X_ATTRIBUTE1,
    ATTRIBUTE2 		= X_ATTRIBUTE2,
    ATTRIBUTE3 		= X_ATTRIBUTE3,
    ATTRIBUTE4 		= X_ATTRIBUTE4,
    ATTRIBUTE5 		= X_ATTRIBUTE5,
    ATTRIBUTE6 		= X_ATTRIBUTE6,
    ATTRIBUTE7 		= X_ATTRIBUTE7,
    ATTRIBUTE8 		= X_ATTRIBUTE8,
    ATTRIBUTE9 		= X_ATTRIBUTE9,
    ATTRIBUTE10 	= X_ATTRIBUTE10,
    ATTRIBUTE11 	= X_ATTRIBUTE11,
    ATTRIBUTE12 	= X_ATTRIBUTE12,
    ATTRIBUTE13 	= X_ATTRIBUTE13,
    ATTRIBUTE14 	= X_ATTRIBUTE14,
    ATTRIBUTE15 	= X_ATTRIBUTE15,
    LAST_UPDATE_DATE 	= X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY 	= X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN 	= X_LAST_UPDATE_LOGIN,
    CREATED_BY          = X_CREATED_BY,
   CREATION_DATE       = X_CREATION_DATE
  where LABEL_FORMAT_ID = X_LABEL_FORMAT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_LABEL_FORMAT_ID in NUMBER
) is
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
  delete from WMS_LABEL_FORMATS
  where LABEL_FORMAT_ID = X_LABEL_FORMAT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
   null;
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
   X_LABEL_FORMAT_ID          in  VARCHAR2 ,
   X_OWNER                    in  VARCHAR2 ,
   X_LABEL_FORMAT_NAME        in  VARCHAR2 ,
   X_FORMAT_DESCRIPTION        in  VARCHAR2
   ) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   NULL;
END translate_row;

PROCEDURE LOAD_ROW (
  X_LABEL_FORMAT_ID	in 	VARCHAR2,
  X_OWNER               in      VARCHAR2,
  X_LABEL_FORMAT_NAME   in      VARCHAR2,
  X_FORMAT_DESCRIPTION  in      VARCHAR2,
  X_DOCUMENT_ID		in 	VARCHAR2,
  X_DEFAULT_FORMAT_FLAG	in      VARCHAR2,
  X_FORMAT_DISABLE_DATE in      VARCHAR2,
  X_ATTRIBUTE_CATEGORY 	in      VARCHAR2,
  X_ATTRIBUTE1 		in      VARCHAR2,
  X_ATTRIBUTE2 		in      VARCHAR2,
  X_ATTRIBUTE3 		in      VARCHAR2,
  X_ATTRIBUTE4 		in      VARCHAR2,
  X_ATTRIBUTE5 		in      VARCHAR2,
  X_ATTRIBUTE6 		in      VARCHAR2,
  X_ATTRIBUTE7 		in      VARCHAR2,
  X_ATTRIBUTE8 		in      VARCHAR2,
  X_ATTRIBUTE9 		in      VARCHAR2,
  X_ATTRIBUTE10 	in      VARCHAR2,
  X_ATTRIBUTE11 	in      VARCHAR2,
  X_ATTRIBUTE12 	in      VARCHAR2,
  X_ATTRIBUTE13 	in      VARCHAR2,
  X_ATTRIBUTE14 	in      VARCHAR2,
  X_ATTRIBUTE15 	in      VARCHAR2

  ) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   DECLARE
      l_label_format_id	         NUMBER;
      l_document_id              NUMBER;
      l_user_id                  NUMBER := 0;
      l_row_id                   VARCHAR2(64);
      l_sysdate                  DATE;
      l_format_disable_date      NUMBER :=0;
      l_msg     VARCHAR2(2000);

   BEGIN

      IF (x_owner = 'SEED') THEN
	 l_user_id := 1;
      END IF;
      --
      SELECT Sysdate INTO l_sysdate FROM dual;
      l_label_format_id := fnd_number.canonical_to_number(x_label_format_id);
      l_document_id 	:= fnd_number.canonical_to_number(x_document_id);
   --dbms_output.put_line('load_row():l_label_format_id  : ' ||l_label_format_id);
IF (l_debug = 1) THEN
   INV_LOG_UTIL.trace(' load_row():l_label_format_id  : '||l_label_format_id , TRACE_PROMPT, TRACE_LEVEL);
END IF;

  l_msg := 'LOAD_ROW(): ' ||l_label_format_id;
      wms_label_formats_pkg.update_row
	(
 	  x_label_format_id           => l_label_format_id
	 ,x_label_format_name        => x_label_format_name
	 ,x_format_description       => x_format_description
	 ,x_document_id 	     => l_document_id
         ,x_default_format_flag      => x_default_format_flag
         ,x_format_disable_date      => x_format_disable_date
	 ,x_last_update_date         => l_sysdate
	 ,x_last_updated_by          => l_user_id
	 ,x_last_update_login        => 0
         ,x_created_by                => l_user_id
         ,x_creation_date             => l_sysdate
	 ,x_request_id		     => null
	 ,x_program_application_id   => null
	 ,x_program_id		     => null
	 ,x_program_update_date      => null
	 ,x_attribute_category	     => x_attribute_category
	 ,x_attribute1 		     => x_attribute1
	 ,x_attribute2 		     => x_attribute2
	 ,x_attribute3 		     => x_attribute3
	 ,x_attribute4 		     => x_attribute4
	 ,x_attribute5 		     => x_attribute5
	 ,x_attribute6 		     => x_attribute6
	 ,x_attribute7               => x_attribute7
	 ,x_attribute8 		     => x_attribute8
	 ,x_attribute9 		     => x_attribute9
	 ,x_attribute10		     => x_attribute10
	 ,x_attribute11		     => x_attribute11
	 ,x_attribute12		     => x_attribute12
	 ,x_attribute13		     => x_attribute13
	 ,x_attribute14		     => x_attribute14
	 ,x_attribute15		     => x_attribute15
	);
   EXCEPTION
     WHEN no_data_found THEN
       wms_label_formats_pkg.insert_row
        (
	  x_rowid                    => l_row_id
 	 , x_label_format_id         => l_label_format_id
	 ,x_label_format_name        => x_label_format_name
	 ,x_format_description       => x_format_description
	 ,x_document_id 	     => l_document_id
         ,x_default_format_flag      => x_default_format_flag
         ,x_format_disable_date      => x_format_disable_date
	 ,x_last_update_date         => l_sysdate
	 ,x_last_updated_by          => l_user_id
	 ,x_last_update_login        => 0
         ,x_created_by                => l_user_id
         ,x_creation_date             => l_sysdate
	 ,x_request_id		     => null
	 ,x_program_application_id   => null
	 ,x_program_id		     => null
	 ,x_program_update_date      => null
	 ,x_attribute_category	     => x_attribute_category
	 ,x_attribute1 		     => x_attribute1
	 ,x_attribute2 		     => x_attribute2
	 ,x_attribute3 		     => x_attribute3
	 ,x_attribute4 		     => x_attribute4
	 ,x_attribute5 		     => x_attribute5
	 ,x_attribute6 		     => x_attribute6
	 ,x_attribute7               => x_attribute7
	 ,x_attribute8 		     => x_attribute8
	 ,x_attribute9 		     => x_attribute9
	 ,x_attribute10		     => x_attribute10
	 ,x_attribute11		     => x_attribute11
	 ,x_attribute12		     => x_attribute12
	 ,x_attribute13		     => x_attribute13
	 ,x_attribute14		     => x_attribute14
	 ,x_attribute15		     => x_attribute15
	 );
   END;
END load_row;
end WMS_LABEL_FORMATS_PKG;

/
