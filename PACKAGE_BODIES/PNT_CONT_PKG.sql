--------------------------------------------------------
--  DDL for Package Body PNT_CONT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNT_CONT_PKG" AS
  -- $Header: PNTCONTB.pls 120.2 2005/12/01 03:35:35 appldev ship $

-------------------------------------------------------------------------------
--  NAME         : check_unique_contact_name
--  DESCRIPTION  : This procedure ensures that contact name is unique.
--  INVOKED FROM :
--  ARGUMENTS    : IN : x_company_site_id, x_rowid, x_first_name,
--                      x_last_name, x_warning_flag, x_org_id
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--  16-JUN-98  Neeraj Tandon   o Created
--  21-JUN-05  piagrawa        o Bug 4284035 - Removed NVL
-------------------------------------------------------------------------------
PROCEDURE check_unique_contact_name ( x_rowid                          VARCHAR2,
                                      x_company_site_id                NUMBER,
                                      x_first_name                     VARCHAR2,
                                      x_last_name                      VARCHAR2,
                                      x_warning_flag     IN OUT NOCOPY VARCHAR2,
                                      x_org_id           IN            NUMBER
                                    ) IS
  dummy number;

BEGIN

   SELECT  1
   INTO    dummy
   FROM    dual
   WHERE   NOT EXISTS ( SELECT  1
                        FROM    pn_contacts_all c
                        WHERE   c.last_name         = x_last_name
                        AND     c.first_name        = x_first_name
                        AND     c.company_site_id   = x_company_site_id
                        AND     (( x_rowid is null) or (c.rowid <> x_rowid))
                        AND     org_id =  x_org_id
                     );
   EXCEPTION

    WHEN NO_DATA_FOUND then
      fnd_message.set_name ('PN','PN_DUP_COMPANY_CONTACT_NAME');
      x_warning_flag := 'W';

END check_unique_contact_name;

-------------------------------------------------------------------------------
--  NAME         : check_primary
--  DESCRIPTION  : This procedure ensures that there is only one primary contact
--                 for the company site
--  INVOKED FROM :
--  ARGUMENTS    : IN:     p_contact_id, p_company_site_id, p_org_id
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--  16-JUN-98  Neeraj Tandon   o Created
--  21-JUN-05  piagrawa        o Bug 4284035 - Removed NVL
-------------------------------------------------------------------------------
PROCEDURE check_primary ( p_contact_id       IN NUMBER,
                         p_company_site_id  IN NUMBER,
                          p_org_id           IN NUMBER
                        ) IS

  primary_count number;

BEGIN

  SELECT  count(1)
  INTO    primary_count
  FROM    pn_contacts_all pc
  WHERE   pc.company_site_id = p_company_site_id
  AND     pc.primary_flag    = 'Y'
  AND     ((p_contact_id is null) or pc.contact_id <> p_contact_id )
  AND     org_id  =  p_org_id;

  IF ( primary_count >= 1 ) THEN
    fnd_message.set_name('PN','PN_COMP_SITE_ONE_PRIM_CONTACT');
    APP_EXCEPTION.raise_exception;
  END IF;

END check_primary;

 -------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 21-JUN-05  piagrawa o Bug 4284035 - Replaced pn_contacts with _ALL table.
-- 28-NOV-05  pikhar   o fetched org_id using cursor
-------------------------------------------------------------------------------
PROCEDURE insert_row ( x_rowid                   IN OUT NOCOPY VARCHAR2,
                       x_contact_id              IN OUT NOCOPY NUMBER,
                       x_company_site_id                NUMBER,
                       x_last_name                      VARCHAR2,
                       x_created_by                     NUMBER,
                       x_creation_date                  DATE,
                       x_last_updated_by                NUMBER,
                       x_last_update_date               DATE,
                       x_last_update_login              NUMBER,
                       x_status                         VARCHAR2,
                       x_first_Name                     VARCHAR2,
                       x_job_title                      VARCHAR2,
                       x_mail_stop                      VARCHAR2,
                       x_email_address                  VARCHAR2,
                       x_primary_flag                   VARCHAR2,
                       x_company_or_location            VARCHAR2,
                       x_attribute_category             VARCHAR2,
                       x_attribute1                     VARCHAR2,
                       x_attribute2                     VARCHAR2,
                       x_attribute3                     VARCHAR2,
                       x_attribute4                     VARCHAR2,
                       x_attribute5                     VARCHAR2,
                       x_attribute6                     VARCHAR2,
                       x_attribute7                     VARCHAR2,
                       x_attribute8                     VARCHAR2,
                       x_attribute9                     VARCHAR2,
                       x_attribute10                    VARCHAR2,
                       x_attribute11                    VARCHAR2,
                       x_attribute12                    VARCHAR2,
                       x_attribute13                    VARCHAR2,
                       x_attribute14                    VARCHAR2,
                       x_attribute15                    VARCHAR2,
                       x_org_id                         NUMBER
                     )
IS
   CURSOR c IS
    SELECT rowid
    FROM   pn_contacts_all
    WHERE  contact_id = x_contact_id;

   CURSOR org_cur IS
    SELECT org_id
    FROM   pn_company_sites_all
    WHERE  company_site_id = x_company_site_id;

   l_org_id NUMBER;


BEGIN

   -----------------------------------------------------------------
   -- Allocate the sequence to the primary key contact_id
   -----------------------------------------------------------------

   IF x_org_id IS NULL AND x_company_site_id IS NOT NULL THEN
     FOR rec IN org_cur LOOP
       l_org_id := rec.org_id;
     END LOOP;
   ELSE
     l_org_id := x_org_id;
   END IF;

   SELECT  pn_contacts_s.nextval
   INTO    x_contact_id
   FROM    dual;

   INSERT INTO pn_contacts_all
   (
      contact_id,
      company_site_id,
      last_name,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      status,
      first_name,
      job_title,
      mail_stop,
      email_address,
      primary_flag,
      attribute_category,
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
      org_id
   )
   VALUES
   (
      x_contact_id,
      x_company_site_id,
      x_last_name,
      x_created_by,
      x_creation_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_update_login,
      x_status,
      x_first_name,
      x_job_title,
      x_mail_stop,
      x_email_address,
      x_primary_flag,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      l_org_id
   );
   OPEN C;
   FETCH C INTO x_rowid;
   IF (C%NOTFOUND) THEN
      CLOSE C;
      RAISE NO_DATA_FOUND;
   END IF;
   CLOSE C;

END insert_row;

 -------------------------------------------------------------------------------
-- PROCDURE     : update_row
-- INVOKED FROM : update_row procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 21-JUN-05  piagrawa o Bug 4284035 - Replaced pn_contacts with _ALL table.
--                       Also updated the where clause
-------------------------------------------------------------------------------
PROCEDURE update_row ( x_rowid                          VARCHAR2,
                       x_contact_id                     NUMBER,
                       x_company_site_id                NUMBER,
                       x_last_name                      VARCHAR2,
                       x_last_updated_by                NUMBER,
                       x_last_update_date               DATE,
                       x_last_update_login              NUMBER,
                       x_status                         VARCHAR2,
                       x_first_Name                     VARCHAR2,
                       x_job_title                      VARCHAR2,
                       x_mail_stop                      VARCHAR2,
                       x_email_address                  VARCHAR2,
                       x_primary_flag                   VARCHAR2,
                       x_attribute_category             VARCHAR2,
                       x_attribute1                     VARCHAR2,
                       x_attribute2                     VARCHAR2,
                       x_attribute3                     VARCHAR2,
                       x_attribute4                     VARCHAR2,
                       x_attribute5                     VARCHAR2,
                       x_attribute6                     VARCHAR2,
                       x_attribute7                     VARCHAR2,
                       x_attribute8                     VARCHAR2,
                       x_attribute9                     VARCHAR2,
                       x_attribute10                    VARCHAR2,
                       x_attribute11                    VARCHAR2,
                       x_attribute12                    VARCHAR2,
                       x_attribute13                    VARCHAR2,
                       x_attribute14                    VARCHAR2,
                       x_attribute15                    VARCHAR2
                     )
IS
BEGIN

   UPDATE pn_contacts_all
   SET
         last_name            = x_last_name,
         first_name           = x_first_name,
         status               = x_status,
         job_title            = x_job_title,
         mail_stop            = x_mail_stop,
         email_address        = x_email_address,
         primary_flag         = x_primary_flag,
         last_updated_by      = x_last_updated_by,
         last_update_date     = x_last_update_date,
         last_update_login    = x_last_update_login,
         attribute_category   = x_attribute_category,
         attribute1           = x_attribute1,
         attribute2           = x_attribute2,
         attribute3           = x_attribute3,
         attribute4           = x_attribute4,
         attribute5           = x_attribute5,
         attribute6           = x_attribute6,
         attribute7           = x_attribute7,
         attribute8           = x_attribute8,
         attribute9           = x_attribute9,
         attribute10          = x_attribute10,
         attribute11          = x_attribute11,
         attribute12          = x_attribute12,
         attribute13          = x_attribute13,
         attribute14          = x_attribute14,
         attribute15          = x_attribute15
   WHERE  contact_id           = x_contact_id;

   IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
   END IF;

END update_row;

-------------------------------------------------------------------------------
-- PROCDURE     : lock_row
-- INVOKED FROM : lock_row procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 21-JUN-05  piagrawa o Bug 4284035 - Replaced pn_contacts with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE lock_row  ( x_rowid                          VARCHAR2,
                      x_contact_id                     NUMBER,
                      x_last_name                      VARCHAR2,
                      x_status                         VARCHAR2,
                      x_first_Name                     VARCHAR2,
                      x_job_title                      VARCHAR2,
                      x_mail_stop                      VARCHAR2,
                      x_email_address                  VARCHAR2,
                      x_primary_flag                   VARCHAR2,
                      x_attribute_category             VARCHAR2,
                      x_attribute1                     VARCHAR2,
                      x_attribute2                     VARCHAR2,
                      x_attribute3                     VARCHAR2,
                      x_attribute4                     VARCHAR2,
                      x_attribute5                     VARCHAR2,
                      x_attribute6                     VARCHAR2,
                      x_attribute7                     VARCHAR2,
                      x_attribute8                     VARCHAR2,
                      x_attribute9                     VARCHAR2,
                      x_attribute10                    VARCHAR2,
                      x_attribute11                    VARCHAR2,
                      x_attribute12                    VARCHAR2,
                      x_attribute13                    VARCHAR2,
                      x_attribute14                    VARCHAR2,
                      x_attribute15                    VARCHAR2
                    )
IS
    CURSOR C IS
       SELECT *
       FROM   pn_contacts_all
       WHERE  ROWID = x_rowid
       FOR    UPDATE OF contact_id NOWAIT;

    Recinfo C%ROWTYPE;

  BEGIN

    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;

           IF NOT   (recinfo.last_name =  x_last_name) THEN
              pn_var_rent_pkg.lock_row_exception('last_name',Recinfo.last_name);
           END IF;
           IF NOT (recinfo.status =  x_status) THEN
              pn_var_rent_pkg.lock_row_exception('status',Recinfo.status);
           END IF;
           IF NOT (   (recinfo.first_name =  x_first_name)
                or ((recinfo.first_name is null) and (x_first_name is null))) THEN
              pn_var_rent_pkg.lock_row_exception('first_name',Recinfo.first_name);
           END IF;
           IF NOT (   (recinfo.job_title =  x_job_title)
                or ((recinfo.job_title is null) and (x_job_title is null))) THEN
              pn_var_rent_pkg.lock_row_exception('job_title',Recinfo.job_title);
           END IF;
           IF NOT (   (recinfo.mail_stop =  x_mail_stop)
                or ((recinfo.mail_stop is null) and (x_mail_stop is null))) THEN
              pn_var_rent_pkg.lock_row_exception('mail_stop',Recinfo.mail_stop);
           END IF;
           IF NOT (   (recinfo.email_address =  x_email_address)
                or ((recinfo.email_address is null) and (x_email_address is null))) THEN
              pn_var_rent_pkg.lock_row_exception('email_address',Recinfo.email_address);
           END IF;
           IF NOT (   (recinfo.primary_flag =  x_primary_flag)
                or ((recinfo.primary_flag is null) and (x_primary_flag is null))) THEN
              pn_var_rent_pkg.lock_row_exception('primary_flag',Recinfo.primary_flag);
           END IF;
           IF NOT (   (recinfo.attribute_category =  x_attribute_category)
                or ((recinfo.attribute_category is null) and (x_attribute_category is null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute_category',Recinfo.attribute_category);
           END IF;
           IF NOT (   (recinfo.attribute1 =  x_attribute1)
                or ((recinfo.attribute1 is null) and (x_attribute1 is null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute1',Recinfo.attribute1);
           END IF;
           IF NOT (   (recinfo.attribute2 =  x_attribute2)
                or ((recinfo.attribute2 is null) and (x_attribute2 is null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute2',Recinfo.attribute2);
           END IF;
           IF NOT (   (recinfo.attribute3 =  x_attribute3)
                or ((recinfo.attribute3 is null) and (x_attribute3 is null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute3',Recinfo.attribute3);
           END IF;
           IF NOT (   (recinfo.attribute4 =  x_attribute4)
                or ((recinfo.attribute4 is null) and (x_attribute4 is null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute4',Recinfo.attribute4);
           END IF;
           IF NOT (   (recinfo.attribute5 =  x_attribute5)
                or ((recinfo.attribute5 is null) and (x_attribute5 is null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute5',Recinfo.attribute5);
           END IF;
           IF NOT (   (recinfo.attribute6 =  x_attribute6)
                or ((recinfo.attribute6 is null) and (x_attribute6 is null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute6',Recinfo.attribute6);
           END IF;
           IF NOT (   (recinfo.attribute7 =  x_attribute7)
                or ((recinfo.attribute7 is null) and (x_attribute7 is null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute7',Recinfo.attribute7);
           END IF;
           IF NOT (   (recinfo.attribute8 =  x_attribute8)
                or ((recinfo.attribute8 is null) and (x_attribute8 is null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute8',Recinfo.attribute8);
           END IF;
           IF NOT (   (recinfo.attribute9 =  x_attribute9)
                or ((recinfo.attribute9 is null) and (x_attribute9 is null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute9',Recinfo.attribute9);
           END IF;
           IF NOT (   (recinfo.attribute10 =  x_attribute10)
                or ((recinfo.attribute10 is null) and (x_attribute10 is null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute10',Recinfo.attribute10);
           END IF;
           IF NOT (   (recinfo.attribute11 =  x_attribute11)
                or ((recinfo.attribute11 is null) and (x_attribute11 is null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute11',Recinfo.attribute11);
           END IF;
           IF NOT (   (recinfo.attribute12 =  x_attribute12)
                or ((recinfo.attribute12 is null) and (x_attribute12 is null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute12',Recinfo.attribute12);
           END IF;
           IF NOT (   (recinfo.attribute13 =  x_attribute13)
                or ((recinfo.attribute13 is null) and (x_attribute13 is null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute13',Recinfo.attribute13);
           END IF;
           IF NOT (   (recinfo.attribute14 =  x_attribute14)
                or ((recinfo.attribute14 is null) and (x_attribute14 is null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute14',Recinfo.attribute14);
           END IF;
           IF NOT (   (recinfo.attribute15 =  x_attribute15)
                or ((recinfo.attribute15 is null) and (x_attribute15 is null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute15',Recinfo.attribute15);
           END IF;

END lock_row;

-------------------------------------------------------------------------------
-- PROCDURE     : check_delete
-- INVOKED FROM :
-- PURPOSE      : This procedure ensures that contact row cannot be deleted if
--                phones exist for the contact (in pn_phones)
-- ARGUMENTS    : IN:     p_contact_id
-- RETURNS      : NONE
-- NOTES        : Used by client side code in PNSUCOMP.pll
-- HISTORY      :
-- 14-JUL-98  Neeraj   o Created
-- 21-JUN-05  piagrawa o Bug 4284035 - Replaced pn_phones with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE check_delete ( x_contact_id   NUMBER )
IS
  CURSOR pn_phones_cur IS
     SELECT 1
     FROM   pn_phones_all
     WHERE  contact_id = x_contact_id;

BEGIN
  FOR i in pn_phones_cur
  LOOP
    fnd_message.set_name ('PN', 'PN_PHONES_EXIST_CANNOT_DELETE');
    app_exception.raise_exception;
  END LOOP;

END check_delete;

 -------------------------------------------------------------------------------
-- PROCDURE     : delete_row
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 21-JUN-05  piagrawa o Bug 4284035 - Replaced pn_contacts,pn_phones with _ALL
--                       table.
-------------------------------------------------------------------------------
PROCEDURE delete_row
(
   x_contact_id   NUMBER
)
IS
BEGIN

   DELETE FROM pn_phones_all
   WHERE  contact_id = x_contact_id;

   DELETE FROM pn_contacts_all
   WHERE  contact_id = x_contact_id;

   IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
   END IF;

END delete_row;
--
--
END PNT_CONT_PKG;

/
