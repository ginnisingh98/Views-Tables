--------------------------------------------------------
--  DDL for Package Body WMS_LABEL_FIELD_VARIABLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_LABEL_FIELD_VARIABLES_PKG" as
/* $Header: WMSLBFVB.pls 120.2 2005/06/22 09:17:48 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID 	 IN OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2,  -- NOCOPY added as a part of Bug# 4380449
  X_LABEL_FORMAT_ID	in 	NUMBER,
  X_LABEL_FIELD_ID	in 	NUMBER,
  X_FIELD_VARIABLE_NAME in      VARCHAR2,
  X_FIELD_VARIABLE_DESCRIPTION  in      VARCHAR2,
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
  cursor C is select ROWID from WMS_LABEL_FIELD_VARIABLES
    where LABEL_FORMAT_ID = X_LABEL_FORMAT_ID
    AND   LABEL_FIELD_ID  = X_LABEL_FIELD_ID
    ;
begin
  insert into WMS_LABEL_FIELD_VARIABLES (
  LABEL_FORMAT_ID,
  LABEL_FIELD_ID,
  FIELD_VARIABLE_NAME,
  FIELD_VARIABLE_DESCRIPTION,
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
  X_LABEL_FIELD_ID,
  X_FIELD_VARIABLE_NAME,
  X_FIELD_VARIABLE_DESCRIPTION,
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
  X_LABEL_FIELD_ID	in 	NUMBER,
  X_FIELD_VARIABLE_NAME in      VARCHAR2,
  X_FIELD_VARIABLE_DESCRIPTION  in      VARCHAR2,
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
     FIELD_VARIABLE_NAME,
     FIELD_VARIABLE_DESCRIPTION,
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
    from WMS_LABEL_FIELD_VARIABLES
    where LABEL_FORMAT_ID = X_LABEL_FORMAT_ID
    AND   LABEL_FIELD_ID  = X_LABEL_FIELD_ID
    for update of LABEL_FORMAT_ID nowait;
  recinfo c%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if ( ((recinfo.FIELD_VARIABLE_NAME = X_FIELD_VARIABLE_NAME)
           OR ((recinfo.FIELD_VARIABLE_NAME is null) AND (X_FIELD_VARIABLE_NAME is null)))
      AND ((recinfo.FIELD_VARIABLE_DESCRIPTION = X_FIELD_VARIABLE_DESCRIPTION)
           OR ((recinfo.FIELD_VARIABLE_DESCRIPTION is null) AND (X_FIELD_VARIABLE_DESCRIPTION is null)))
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
  X_LABEL_FIELD_ID	in 	NUMBER,
  X_FIELD_VARIABLE_NAME in      VARCHAR2,
  X_FIELD_VARIABLE_DESCRIPTION  in      VARCHAR2,
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
begin
  update WMS_LABEL_FIELD_VARIABLES
    set FIELD_VARIABLE_NAME   = X_FIELD_VARIABLE_NAME,
    FIELD_VARIABLE_DESCRIPTION 	= X_FIELD_VARIABLE_DESCRIPTION,
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
  where LABEL_FORMAT_ID = X_LABEL_FORMAT_ID
  AND   FIELD_VARIABLE_NAME  = X_FIELD_VARIABLE_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_ROWID     IN VARCHAR2
) is
begin
  delete from WMS_LABEL_FIELD_VARIABLES
  where ROWID = X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
   null;
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
   X_LABEL_FORMAT_ID          in  VARCHAR2 ,
   X_LABEL_FIELD_ID           in  VARCHAR2 ,
   X_OWNER                    in  VARCHAR2 ,
   X_LABEL_FORMAT_NAME        in  VARCHAR2 ,
   X_FORMAT_DESCRIPTION        in  VARCHAR2
   ) IS
BEGIN
   NULL;
END translate_row;

PROCEDURE LOAD_ROW (
  X_LABEL_FORMAT_ID	in 	NUMBER,
  X_OWNER               in      VARCHAR2,
  X_LABEL_FIELD_ID	in 	NUMBER,
  X_FIELD_VARIABLE_NAME in      VARCHAR2,
  X_FIELD_VARIABLE_DESCRIPTION  in      VARCHAR2,
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

  ) IS
BEGIN
   DECLARE
      l_label_format_id	         NUMBER;
      l_label_field_id	         NUMBER;
      l_user_id                  NUMBER := 0;
      l_row_id                   VARCHAR2(64);
      l_sysdate                  DATE;
   BEGIN
      IF (x_owner = 'SEED') THEN
	 l_user_id := 1;
      END IF;
      --
      SELECT Sysdate INTO l_sysdate FROM dual;
      l_label_format_id := fnd_number.canonical_to_number(x_label_format_id);
      l_label_field_id 	:= fnd_number.canonical_to_number(x_label_field_id);

      wms_label_field_variables_pkg.update_row
	(
 	  x_label_format_id           => l_label_format_id
 	 ,x_label_field_id           => l_label_field_id
	 ,x_field_variable_name        => x_field_variable_name
	 ,x_field_variable_description       => x_field_variable_description
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
       wms_label_field_variables_pkg.insert_row
        (
	  x_rowid                    => l_row_id
 	 , x_label_format_id         => l_label_format_id
 	 ,x_label_field_id           => l_label_field_id
	 ,x_field_variable_name        => x_field_variable_name
	 ,x_field_variable_description       => x_field_variable_description
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
end WMS_LABEL_FIELD_VARIABLES_PKG;

/
