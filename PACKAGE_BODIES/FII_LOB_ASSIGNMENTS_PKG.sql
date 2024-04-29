--------------------------------------------------------
--  DDL for Package Body FII_LOB_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_LOB_ASSIGNMENTS_PKG" AS
/*$Header: FIILOBAB.pls 115.2 2003/01/11 00:31:02 ilavenil noship $*/
   PROCEDURE insert_row(x_rowid IN OUT NOCOPY VARCHAR2,
                        x_line_of_business IN VARCHAR2,
                        x_company_cost_center_org_id IN NUMBER,
                        x_last_update_date IN DATE,
                        x_last_updated_by IN NUMBER,
                        x_created_by IN NUMBER,
                        x_creation_date IN DATE,
                        x_last_update_login IN NUMBER)
     IS
       l_last_update_date date;
       l_last_updated_by number(15);
       l_created_by number(15);
       l_creation_date date;
       l_last_update_login number(15);
   BEGIN
      l_last_update_date := nvl(x_last_update_date, sysdate);
      l_last_updated_by := nvl(x_last_updated_by, fnd_global.user_id);
      l_created_by := nvl(x_created_by, fnd_global.user_id);
      l_creation_date := nvl(x_creation_date, sysdate);
      l_last_update_login := nvl(x_last_update_login, fnd_global.login_id);

      INSERT INTO fii_lob_assignments
        (line_of_business, company_cost_center_org_id,
         creation_date, created_by, last_update_date, last_updated_by, last_update_login)
        VALUES
        (x_line_of_business, x_company_cost_center_org_id,
         l_creation_date, l_created_by, l_last_update_date, l_last_updated_by, l_last_update_login)
        RETURN ROWID INTO x_rowid;
   END insert_row;

   PROCEDURE update_row(x_rowid IN VARCHAR2,
                        x_line_of_business IN VARCHAR2,
                        x_company_cost_center_org_id IN NUMBER,
                        x_last_update_date IN DATE,
                        x_last_updated_by IN NUMBER,
                        x_last_update_login IN NUMBER)
     IS
       l_last_update_date date;
       l_last_updated_by number(15);
       l_last_update_login number(15);
   BEGIN
      l_last_update_date := nvl(x_last_update_date, sysdate);
      l_last_updated_by := nvl(x_last_updated_by, fnd_global.user_id);
      l_last_update_login := nvl(x_last_update_login, fnd_global.login_id);

      IF x_rowid IS NOT NULL THEN
         UPDATE fii_lob_assignments
           SET
           company_cost_center_org_id = x_company_cost_center_org_id,
           last_update_date = l_last_update_date,
           last_updated_by = l_last_updated_by,
           last_update_login = l_last_update_login
           WHERE ROWID = x_rowid;
       ELSE
         UPDATE fii_lob_assignments
           SET
           company_cost_center_org_id = x_company_cost_center_org_id,
           last_update_date = l_last_update_date,
           last_updated_by = l_last_updated_by,
           last_update_login = l_last_update_login
           WHERE line_of_business = x_line_of_business;
      END IF;

      IF SQL%notfound THEN
         RAISE no_data_found;
      END IF;
   END update_row;


   PROCEDURE delete_row(x_rowid IN VARCHAR2,
                        x_line_of_business IN VARCHAR2)
     IS
   BEGIN
      IF x_rowid  IS NOT NULL THEN
         DELETE FROM fii_lob_assignments
           WHERE ROWID = x_rowid;
       ELSE
         DELETE FROM fii_lob_assignments
           WHERE line_of_business = x_line_of_business;
      END IF;

      IF SQL%notfound THEN
         RAISE no_data_found;
      END IF;
   END delete_row;

   PROCEDURE lock_row(x_rowid IN VARCHAR2,
                      x_line_of_business IN VARCHAR2,
                      x_company_cost_center_org_id IN NUMBER)
     IS
        CURSOR c_lob IS
           SELECT *
             FROM fii_lob_assignments
             WHERE ROWID = x_rowid
             FOR UPDATE OF company_cost_center_org_id nowait;
        recinfo c_lob%ROWTYPE;
   BEGIN
      OPEN c_lob;
      FETCH c_lob INTO recinfo;
      IF c_lob%notfound THEN
         CLOSE c_lob;
         fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
         app_exception.raise_exception;
      END IF;
      CLOSE c_lob;

      IF recinfo.line_of_business = x_line_of_business AND
        recinfo.company_cost_center_org_id = x_company_cost_center_org_id THEN
         RETURN;
       ELSE
         fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
         app_exception.raise_exception;
      END IF;
   END lock_row;

END fii_lob_assignments_pkg;

/
