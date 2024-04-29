--------------------------------------------------------
--  DDL for Package Body OE_PAYMENT_TYPES_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PAYMENT_TYPES_UTIL" as
/* $Header: OEXUPMTB.pls 120.1 2005/07/15 05:20:42 ppnair noship $ */

  PROCEDURE Insert_Row(X_Rowid                  IN OUT NOCOPY 	 VARCHAR2,
                       p_name                	VARCHAR2,
                       p_description            VARCHAR2,
                       p_payment_type_id        NUMBER,
                       p_payment_type_code      VARCHAR2,
                       p_receipt_method_id      NUMBER,
                       p_start_date_active      DATE,
                       p_end_date_active        DATE,
                       p_enabled_flag           VARCHAR2,
                       p_defer_payment          VARCHAR2,
                       p_credit_check_flag      VARCHAR2,
                       p_org_id                	NUMBER  ,
                       p_Last_Update_Date       DATE,
                       p_Last_Updated_By        NUMBER  ,
                       p_Creation_Date          DATE ,
                       p_Created_By             NUMBER ,
                       p_Last_Update_Login      NUMBER,
                       p_program_application_id NUMBER,
                       p_program_id         	NUMBER,
                       p_request_id         	NUMBER,
                       p_program_update_date    DATE ,
                       p_Context 	        VARCHAR2,
                       p_Attribute1             VARCHAR2,
                       p_Attribute2             VARCHAR2,
                       p_Attribute3             VARCHAR2,
                       p_Attribute4             VARCHAR2,
                       p_Attribute5             VARCHAR2,
                       p_Attribute6             VARCHAR2,
                       p_Attribute7             VARCHAR2,
                       p_Attribute8             VARCHAR2,
                       p_Attribute9             VARCHAR2,
                       p_Attribute10            VARCHAR2,
                       p_Attribute11            VARCHAR2,
                       p_Attribute12            VARCHAR2,
                       p_Attribute13            VARCHAR2,
                       p_Attribute14            VARCHAR2,
                       p_Attribute15            VARCHAR2
  ) IS
  --  CURSOR C IS SELECT rowid FROM oe_system_parameters_all
                 /** WHERE nvl(org_id, -99) = nvl(X_Organization_Id, -99); **/
                -- NVL of -99 is removed as per SSA
                -- WHERE org_id = X_Organization_Id;
   --              WHERE nvl(org_id, -99) = nvl(X_Organization_Id, -99);

l_language		VARCHAR2(4);
l_source_lang		VARCHAR2(4);
l_org_id number := 0;

BEGIN

/*
SELECT USERENV('LANG'),USERENV('LANG')
INTO   l_language,l_source_lang
FROM   DUAL;
*/

l_org_id := p_org_id;

if l_org_id is null then

    OE_GLOBALS.Set_Context;
    l_org_id := OE_GLOBALS.G_ORG_ID;

end if;

INSERT INTO oe_payment_types_tl
(payment_type_code
,language
,source_lang
,name
,description
,creation_date
,created_by
,last_update_date
,last_updated_by
,last_update_login
,program_application_id
,program_id
,request_id
,program_update_date
,org_id
)
SELECT
p_payment_type_code
,L.LANGUAGE_CODE
,userenv('LANG')
,p_name
,p_description
,p_creation_date
,p_created_by
,p_last_update_date
,p_last_updated_by
,p_last_update_login
,p_program_application_id
,p_program_id
,p_request_id
,p_program_update_date
,p_org_id
FROM FND_LANGUAGES L
WHERE L.INSTALLED_FLAG IN ('I', 'B')
and not exists
( select null
  from oe_payment_types_tl t
  where t.org_id = p_org_id
  and t.payment_type_code = p_payment_type_code
  and t.language = L.LANGUAGE_CODE);

INSERT INTO oe_payment_types_all
(payment_type_code
,start_date_active
,end_date_active
,enabled_flag
,defer_payment_processing_flag
,credit_check_flag
,receipt_method_id
,org_id
,creation_date
,created_by
,last_update_date
,last_updated_by
,last_update_login
,program_application_id
,program_id
,request_id
,context
,attribute1
,attribute2
,attribute3
,attribute4
,attribute5
,attribute6
,attribute7
,attribute8
,attribute9
,attribute10
,attribute11
,attribute12
,attribute13
,attribute14
,attribute15
,program_update_date
)
VALUES(
p_payment_type_code
,p_start_date_active
,p_end_date_active
,p_enabled_flag
,p_defer_payment
,p_credit_check_flag
,p_receipt_method_id
,p_org_id
,p_creation_date
,p_created_by
,p_last_update_date
,p_last_updated_by
,p_last_update_login
,p_program_application_id
,p_program_id
,p_request_id
,p_context
,p_attribute1
,p_attribute2
,p_attribute3
,p_attribute4
,p_attribute5
,p_attribute6
,p_attribute7
,p_attribute8
,p_attribute9
,p_attribute10
,p_attribute11
,p_attribute12
,p_attribute13
,p_attribute14
,p_attribute15
,p_program_update_date
);

END Insert_Row;



  PROCEDURE Lock_Row  (p_name                	VARCHAR2,
                       p_description            VARCHAR2,
                       p_payment_type_id        NUMBER,
                       p_payment_type_code      VARCHAR2,
                       p_receipt_method         VARCHAR2,
                       p_start_date_active      DATE,
                       p_end_date_active        DATE,
                       p_enabled_flag           VARCHAR2,
                       p_defer_payment          VARCHAR2,
                       p_credit_check_flag      VARCHAR2,
                       p_org_id                	NUMBER  ,
                       p_Context 	        VARCHAR2,
                       p_Attribute1             VARCHAR2,
                       p_Attribute2             VARCHAR2,
                       p_Attribute3             VARCHAR2,
                       p_Attribute4             VARCHAR2,
                       p_Attribute5             VARCHAR2,
                       p_Attribute6             VARCHAR2,
                       p_Attribute7             VARCHAR2,
                       p_Attribute8             VARCHAR2,
                       p_Attribute9             VARCHAR2,
                       p_Attribute10            VARCHAR2,
                       p_Attribute11            VARCHAR2,
                       p_Attribute12            VARCHAR2,
                       p_Attribute13            VARCHAR2,
                       p_Attribute14            VARCHAR2,
                       p_Attribute15            VARCHAR2

  ) IS
    CURSOR C IS
        SELECT *
        FROM   oe_payment_types_all
        WHERE  payment_type_code = p_payment_type_code
        AND    nvl(org_id,-1) = nvl(p_org_id,-1)
        FOR UPDATE OF PAYMENT_TYPE_CODE NOWAIT;

     CURSOR C1 IS
        SELECT name,description,payment_type_code,
               decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
        FROM oe_payment_types_tl
        WHERE payment_type_code = p_payment_type_code
        AND nvl(org_id,-1) = nvl(p_org_id,-1)
        AND   userenv('LANG') in (LANGUAGE, SOURCE_LANG)
        FOR UPDATE OF PAYMENT_TYPE_CODE NOWAIT;

    Recinfo C%ROWTYPE;
    RECORD_CHANGED EXCEPTION;
    l_org_id number := 0;
  BEGIN

   l_org_id := p_org_id;

   if l_org_id is null then

      OE_GLOBALS.Set_Context;
      l_org_id := OE_GLOBALS.G_ORG_ID;

   end if;

    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;

  IF ( ((recinfo.payment_type_code = p_payment_type_code)
           OR ((recinfo.payment_type_code is null) AND (p_payment_type_code is null)))
     -- AND ((recinfo.receipt_method = p_receipt_method)
     --      OR ((recinfo.receipt_method is null) AND (p_receipt_method is null)))
      AND ((recinfo.start_date_active = p_start_date_active)
           OR ((recinfo.start_date_active is null) AND (p_start_date_active is null)))
      AND ((recinfo.end_date_active = p_end_date_active)
           OR ((recinfo.end_date_active is null) AND (p_end_date_active is null)))
      AND ((recinfo.defer_payment_processing_flag = p_defer_payment)
           OR ((recinfo.defer_payment_processing_flag is null) AND (p_defer_payment is null)))
      AND ((recinfo.credit_check_flag = p_credit_check_flag)
           OR ((recinfo.credit_check_flag is null) AND (p_credit_check_flag is null)))
      AND ((recinfo.org_id = p_org_id)
           OR ((recinfo.org_id is null) AND (p_org_id is null)))
      AND ((recinfo.context = p_context)
           OR ((recinfo.context is null) AND (p_context is null)))
      AND ((recinfo.attribute1 = p_attribute1)
           OR ((recinfo.attribute1 is null) AND (p_attribute1 is null)))
      AND ((recinfo.attribute2 = p_attribute2)
           OR ((recinfo.attribute2 is null) AND (p_attribute2 is null)))
      AND ((recinfo.attribute3 = p_attribute3)
           OR ((recinfo.attribute3 is null) AND (p_attribute3 is null)))
      AND ((recinfo.attribute4 = p_attribute4)
           OR ((recinfo.attribute4 is null) AND (p_attribute4 is null)))
      AND ((recinfo.attribute5 = p_attribute5)
           OR ((recinfo.attribute5 is null) AND (p_attribute5 is null)))

      AND ((recinfo.attribute6 = p_attribute6)
           OR ((recinfo.attribute6 is null) AND (p_attribute6 is null)))
      AND ((recinfo.attribute7 = p_attribute7)
           OR ((recinfo.attribute7 is null) AND (p_attribute7 is null)))
      AND ((recinfo.attribute8 = p_attribute8)
           OR ((recinfo.attribute8 is null) AND (p_attribute8 is null)))
      AND ((recinfo.attribute9 = p_attribute9)
           OR ((recinfo.attribute9 is null) AND (p_attribute9 is null)))
      AND ((recinfo.attribute10 = p_attribute10)
           OR ((recinfo.attribute10 is null) AND (p_attribute10 is null)))
      AND ((recinfo.attribute11 = p_attribute11)
           OR ((recinfo.attribute11 is null) AND (p_attribute11 is null)))
      AND ((recinfo.attribute12 = p_attribute12)
           OR ((recinfo.attribute12 is null) AND (p_attribute12 is null)))
      AND ((recinfo.attribute13 = p_attribute13)
           OR ((recinfo.attribute13 is null) AND (p_attribute13 is null)))
      AND ((recinfo.attribute14 = p_attribute14)
           OR ((recinfo.attribute14 is null) AND (p_attribute14 is null)))
      AND ((recinfo.attribute15 = p_attribute15)
           OR ((recinfo.attribute15 is null) AND (p_attribute15 is null)))

  ) THEN
    null;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;

  FOR tlinfo IN C1 LOOP
    if (tlinfo.BASELANG = 'Y') then
      IF ((tlinfo.name = p_name)
          AND ((tlinfo.description = p_description)
           OR ((tlinfo.description is null) AND (p_description is null)))
          AND (recinfo.payment_type_code = p_payment_type_code)
         ) THEN
         null;
      ELSE
         fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
         app_exception.raise_exception;
      END IF;
    END IF;
  END LOOP;


EXCEPTION
  WHEN RECORD_CHANGED THEN
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.Raise_Exception;
  WHEN OTHERS THEN
    raise;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid         		VARCHAR2,
                       p_name                	VARCHAR2,
                       p_description            VARCHAR2,
                       p_payment_type_id        NUMBER,
                       p_payment_type_code      VARCHAR2,
                       p_receipt_method_id      NUMBER,
                       p_start_date_active      DATE,
                       p_end_date_active        DATE,
                       p_enabled_flag           VARCHAR2,
                       p_defer_payment          VARCHAR2,
                       p_credit_check_flag      VARCHAR2,
                       p_org_id                	NUMBER  ,
                       p_Last_Update_Date       DATE,
                       p_Last_Updated_By        NUMBER  ,
                       p_Creation_Date          DATE ,
                       p_Created_By             NUMBER ,
                       p_Last_Update_Login      NUMBER,
                       p_program_application_id NUMBER,
                       p_program_id         	NUMBER,
                       p_request_id         	NUMBER,
                       p_program_update_date    DATE ,
                       p_Context 	        VARCHAR2,
                       p_Attribute1             VARCHAR2,
                       p_Attribute2             VARCHAR2,
                       p_Attribute3             VARCHAR2,
                       p_Attribute4             VARCHAR2,
                       p_Attribute5             VARCHAR2,
                       p_Attribute6             VARCHAR2,
                       p_Attribute7             VARCHAR2,
                       p_Attribute8             VARCHAR2,
                       p_Attribute9             VARCHAR2,
                       p_Attribute10            VARCHAR2,
                       p_Attribute11            VARCHAR2,
                       p_Attribute12            VARCHAR2,
                       p_Attribute13            VARCHAR2,
                       p_Attribute14            VARCHAR2,
                       p_Attribute15            VARCHAR2
                      ) IS
BEGIN


    UPDATE oe_payment_types_tl
    SET
       org_id          = p_org_id,
       payment_type_code	= p_payment_type_code,
       name		        = p_name,
       description		= p_description,
       last_update_date         = p_Last_Update_Date,
       last_updated_by          = p_Last_Updated_By,
       last_update_login        = p_Last_Update_Login,
       source_lang              = userenv('LANG')
    WHERE nvl(org_id,-1) = nvl(p_org_id, -1)
    AND  payment_type_code = p_payment_type_code
    AND userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    UPDATE oe_payment_types_all
    SET
     	payment_type_code	= p_payment_type_code,
	start_date_active	= p_start_date_active,
	end_date_active		= p_end_date_active,
	enabled_flag		= p_enabled_flag,
	defer_payment_processing_flag	= p_defer_payment,
        credit_check_flag	= p_credit_check_flag,
        last_update_date        = p_Last_Update_Date,
        last_updated_by         = p_Last_Updated_By,
        last_update_login       = p_Last_Update_Login,
	receipt_method_id	= p_receipt_method_id,
	org_id			= p_org_id,
	context              	= p_Context,
       	attribute1              = p_Attribute1,
      	attribute2              = p_Attribute2,
       	attribute3              = p_Attribute3,
       	attribute4              = p_Attribute4,
       	attribute5              = p_Attribute5,
       	attribute6              = p_Attribute6,
       	attribute7              = p_Attribute7,
       	attribute8              = p_Attribute8,
       	attribute9              = p_Attribute9,
       	attribute10             = p_Attribute10,
       	attribute11             = p_Attribute11,
       	attribute12             = p_Attribute12,
       	attribute13             = p_Attribute13,
       	attribute14             = p_Attribute14,
       	attribute15             = p_Attribute15
    WHERE nvl(org_id,-1) = nvl(p_org_id,-1)
    AND   payment_type_code = p_payment_type_code;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
END Update_Row;

PROCEDURE Delete_Row(p_payment_type_id IN NUMBER,
                     p_payment_type_code IN VARCHAR2,
                     p_org_id in NUMBER) IS
  l_org_id number := 0;
  BEGIN

l_org_id := p_org_id;

if l_org_id is null then

    OE_GLOBALS.Set_Context;
    l_org_id := OE_GLOBALS.G_ORG_ID;

end if;


    DELETE FROM oe_payment_types_tl
    WHERE nvl(org_id,-1) = nvl(l_org_id,-1)
    AND payment_type_code = p_payment_type_code;

    DELETE FROM oe_payment_types_all
    WHERE nvl(org_id,-1) = nvl(l_org_id,-1)
    AND payment_type_code = p_payment_type_code;


    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
END Delete_Row;


PROCEDURE Translate_Row(p_payment_type_id in VARCHAR2,
                        p_payment_type_code in VARCHAR2,
                        p_name in VARCHAR2,
                        p_description in VARCHAR2,
                        p_owner in varchar2,
                        p_org_id in varchar2) IS
   l_user_id number :=0;
BEGIN
   l_user_id :=fnd_load_util.owner_id(p_owner); --seed data version changes
   UPDATE oe_payment_types_tl
    SET
       payment_type_code	= p_payment_type_code,
       name		        = p_name,
       description		= p_description,
       last_update_date         = sysdate,
       --last_updated_by          = decode(p_owner, 'SEED', 1, 0),
       last_updated_by          = l_user_id,
       last_update_login        = 0,
       source_lang = userenv('LANG')
    WHERE nvl(org_id,-1) = nvl(p_org_id,-1)
    AND   payment_type_code = p_payment_type_code
    AND userenv('LANG') in (LANGUAGE, SOURCE_LANG);

END Translate_Row;

PROCEDURE LOAD_ROW( x_payment_type_id  in NUMBER,
                      x_payment_type_code in VARCHAR2,
                      x_request_id        in NUMBER,
                      x_start_date_active in VARCHAR2,
                      x_end_date_active   in VARCHAR2,
                      x_enabled_flag      in VARCHAR2,
                      x_defer_processing_flag in VARCHAR2,
                      x_credit_check_flag in VARCHAR2,
                      x_receipt_method_id in NUMBER,
                      x_context           in VARCHAR2,
                      x_attribute1        in VARCHAR2,
                      x_attribute2        in VARCHAR2,
                      x_attribute3        in VARCHAR2,
                      x_attribute4        in VARCHAR2,
                      x_attribute5        in VARCHAR2,
                      x_attribute6        in VARCHAR2,
                      x_attribute7        in VARCHAR2,
                      x_attribute8        in VARCHAR2,
                      x_attribute9        in VARCHAR2,
                      x_attribute10        in VARCHAR2,
                      x_attribute11        in VARCHAR2,
                      x_attribute12        in VARCHAR2,
                      x_attribute13        in VARCHAR2,
                      x_attribute14        in VARCHAR2,
                      x_attribute15        in VARCHAR2,
                      x_name               in VARCHAR2,
                      x_description        in VARCHAR2,
                      x_last_update_date   in VARCHAR2,
                      x_last_updated_by    in NUMBER,
                      x_last_update_login  in NUMBER,
                      x_owner              in VARCHAR2,
                      x_org_id             in NUMBER) IS
l_user_id number := 0;
l_payment_type_id number := 0;
l_org_id number := 0;
l_rowid varchar2(240) := NULL;
l_db_user_id number := 0;
l_valid_release boolean :=false;
BEGIN

   IF x_owner = 'SEED' THEN
      l_user_id := 1;
   END IF;

   l_user_id :=fnd_load_util.owner_id(x_owner); --seed data version

     select org_id,last_updated_by into l_org_id,l_db_user_id
     from oe_payment_types_all
     where payment_type_code = x_payment_type_code
     and nvl(org_id,-1) = nvl(x_org_id,-1)
     and rownum = 1;
     --seed data version start
     if (l_db_user_id <= l_user_id)
           or (l_db_user_id in (0,1,2)
              and l_user_id in (0,1,2))       then
	  l_valid_release :=true ;
     end if;
     if l_valid_release then
     --seed data version end
      Update_Row(X_Rowid => l_rowid,
                       p_name => x_name,
                       p_description => x_description,
                       p_payment_type_id => l_payment_type_id,
                       p_payment_type_code => x_payment_type_code,
                       p_receipt_method_id => x_receipt_method_id,
                       p_start_date_active => x_start_date_active,
                       p_end_date_active   => x_end_date_active,
                       p_enabled_flag      => x_enabled_flag,
                       p_defer_payment     => x_defer_processing_flag,
                       p_credit_check_flag => x_credit_check_flag,
                       p_org_id            => l_org_id,
                       p_Last_Update_Date  => sysdate,
                       p_Last_Updated_By   => l_user_id,
                       p_Creation_Date     => NULL,
                       p_Created_By        => NULL,
                       p_Last_Update_Login => 0,
                       p_program_application_id => NULL,
                       p_program_id         	=> NULL,
                       p_request_id         	=> x_request_id,
                       p_program_update_date    => NULL,
                       p_Context 	        => x_context,
                       p_Attribute1             => x_attribute1,
                       p_Attribute2             => x_attribute2,
                       p_Attribute3             => x_attribute3,
                       p_Attribute4             => x_attribute4,
                       p_Attribute5             => x_attribute5,
                       p_Attribute6             => x_attribute6,
                       p_Attribute7             => x_attribute7,
                       p_Attribute8             => x_attribute8,
                       p_Attribute9             => x_attribute9,
                       p_Attribute10            => x_attribute10,
                       p_Attribute11            => x_attribute11,
                       p_Attribute12            => x_attribute12,
                       p_Attribute13            => x_attribute13,
                       p_Attribute14            => x_attribute14,
                       p_Attribute15            => x_attribute15 );
       end if;
      exception

         when no_data_found then

           Begin

              Insert_Row(X_Rowid => l_rowid,
                       p_name => x_name,
                       p_description => x_description,
                       p_payment_type_id => x_payment_type_id,
                       p_payment_type_code => x_payment_type_code,
                       p_receipt_method_id => x_receipt_method_id,
                       p_start_date_active => x_start_date_active,
                       p_end_date_active   => x_end_date_active,
                       p_enabled_flag      => x_enabled_flag,
                       p_defer_payment     => x_defer_processing_flag,
                       p_credit_check_flag => x_credit_check_flag,
                       p_org_id            => x_org_id,
                       p_Last_Update_Date  => sysdate,
                       p_Last_Updated_By   => l_user_id,
                       p_Creation_Date     => sysdate,
                       p_Created_By        => l_user_id,
                       p_Last_Update_Login => 0,
                       p_program_application_id => NULL,
                       p_program_id         	=> NULL,
                       p_request_id         	=> x_request_id,
                       p_program_update_date    => NULL,
                       p_Context 	        => x_context,
                       p_Attribute1             => x_attribute1,
                       p_Attribute2             => x_attribute2,
                       p_Attribute3             => x_attribute3,
                       p_Attribute4             => x_attribute4,
                       p_Attribute5             => x_attribute5,
                       p_Attribute6             => x_attribute6,
                       p_Attribute7             => x_attribute7,
                       p_Attribute8             => x_attribute8,
                       p_Attribute9             => x_attribute9,
                       p_Attribute10            => x_attribute10,
                       p_Attribute11            => x_attribute11,
                       p_Attribute12            => x_attribute12,
                       p_Attribute13            => x_attribute13,
                       p_Attribute14            => x_attribute14,
                       p_Attribute15            => x_attribute15 );

             Exception

                 when others then
                      raise;

             END;


END LOAD_ROW;

Procedure Copy_Payment_Types(p_from_org_id in number,
                             p_to_org_id in number) is
Cursor
get_payment_types is
select payment_type_code,
       request_id,
       start_date_active,
       end_date_active,
       enabled_flag,
       defer_payment_processing_flag,
       credit_check_flag,
       receipt_method_id,
       context,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15,
       name,
       description,
       last_update_date,
       last_updated_by,
       last_update_login
from oe_payment_types_vl optv
where nvl(org_id, -1) = nvl(p_from_org_id, -1)
and not exists (
select null
from oe_payment_types_all opta
where opta.payment_type_code = optv.payment_type_code
and nvl(opta.org_id, -1) = nvl(p_to_org_id, -1) );

x_owner varchar2(30) := NULL;

Begin

  IF nvl(p_from_org_id, -1) <> nvl(p_to_org_id, -1) THEN

    for payment_type_rec in get_payment_types loop

       IF payment_type_rec.last_updated_by = 1 THEN
            x_owner := 'SEED';

       END IF;

       LOAD_ROW(x_payment_type_id => NULL,
                      x_payment_type_code => payment_type_rec.payment_type_code,
                      x_request_id        => payment_type_rec.request_id,
                      x_start_date_active => payment_type_rec.start_date_active,
                      x_end_date_active   => payment_type_rec.end_date_active,
                      x_enabled_flag      => payment_type_rec.enabled_flag,
                      x_defer_processing_flag => payment_type_rec.defer_payment_processing_flag,
                      x_credit_check_flag => payment_type_rec.credit_check_flag,
                      x_receipt_method_id => payment_type_rec.receipt_method_id,
                      x_context           => payment_type_rec.context,
                      x_attribute1        => payment_type_rec.attribute1,
                      x_attribute2        => payment_type_rec.attribute2,
                      x_attribute3        => payment_type_rec.attribute3,
                      x_attribute4        => payment_type_rec.attribute4,
                      x_attribute5        => payment_type_rec.attribute5,
                      x_attribute6        => payment_type_rec.attribute6,
                      x_attribute7        => payment_type_rec.attribute7,
                      x_attribute8        => payment_type_rec.attribute8,
                      x_attribute9        => payment_type_rec.attribute9,
                      x_attribute10       => payment_type_rec.attribute10,
                      x_attribute11       => payment_type_rec.attribute11,
                      x_attribute12       => payment_type_rec.attribute12,
                      x_attribute13       => payment_type_rec.attribute13,
                      x_attribute14       => payment_type_rec.attribute14,
                      x_attribute15       => payment_type_rec.attribute15,
                      x_name              => payment_type_rec.name,
                      x_description       => payment_type_rec.description,
                      x_last_update_date  => sysdate,
                      x_last_updated_by   => payment_type_rec.last_updated_by,
                      x_last_update_login => payment_type_rec.last_update_login,
                      x_owner             => x_owner,
                      x_org_id            => p_to_org_id);

    END LOOP;

  END IF;

END Copy_Payment_Types;

procedure ADD_LANGUAGE
is
begin
  delete from OE_PAYMENT_TYPES_TL T
  where not exists
    (select NULL
    from OE_PAYMENT_TYPES_ALL B
    where B.PAYMENT_TYPE_CODE = T.PAYMENT_TYPE_CODE
    and   NVL(B.ORG_ID, -1) = NVL(T.ORG_ID, -1)
    );

  update OE_PAYMENT_TYPES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from OE_PAYMENT_TYPES_TL B
    where B.PAYMENT_TYPE_CODE = T.PAYMENT_TYPE_CODE
    and NVL(B.ORG_ID, -1) = NVL(T.ORG_ID, -1)
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PAYMENT_TYPE_CODE,
      NVL(T.ORG_ID,-1),
      T.LANGUAGE
  ) in (select
      SUBT.PAYMENT_TYPE_CODE,
      NVL(SUBT.ORG_ID, -1),
      SUBT.LANGUAGE
    from OE_PAYMENT_TYPES_TL SUBB, OE_PAYMENT_TYPES_TL SUBT
    where SUBB.PAYMENT_TYPE_CODE = SUBT.PAYMENT_TYPE_CODE
    and NVL(SUBB.ORG_ID, -1) = NVL(SUBT.ORG_ID, -1)
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into OE_PAYMENT_TYPES_TL (
    PAYMENT_TYPE_CODE,
    ORG_ID,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    REQUEST_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PAYMENT_TYPE_CODE,
    B.ORG_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.PROGRAM_APPLICATION_ID,
    B.PROGRAM_ID,
    B.REQUEST_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from OE_PAYMENT_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from OE_PAYMENT_TYPES_TL T
    where T.PAYMENT_TYPE_CODE = B.PAYMENT_TYPE_CODE
    and nvl(T.ORG_ID, -1) = NVL(B.ORG_ID, -1)
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

END OE_PAYMENT_TYPES_UTIL;

/
