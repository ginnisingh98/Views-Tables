--------------------------------------------------------
--  DDL for Package Body PN_SPACE_ASSIGN_EMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_SPACE_ASSIGN_EMP_PKG" AS
/* $Header: PNSPEMPB.pls 120.7 2005/12/01 03:32:06 appldev ship $ */

-------------------------------------------------------------------------------
-- PROCDURE     : Insert_Row
-- DESCRIPTION  : inserts a row in pn_space_assign_emp_all
-- SCOPE        : PUBLIC
-- INVOKED FROM :
-- RETURNS      : NONE
-- HISTORY      :
-- 14-DEC-04 STripath  o Modified for Portfolio Status Enh BUG# 4030816.
--                       Added code to check loc is contigious assignable
--                       betn assign start and end dates.
-- 28-APR-05 piagrawa  o Bug 4284035 - Replaced pn_space_assign_emp with _ALL
-- 28-NOV-05 pikhar    o fetched org_id using cursor
-------------------------------------------------------------------------------
PROCEDURE Insert_Row (
          x_rowid                         IN OUT NOCOPY VARCHAR2,
          x_emp_space_assign_id           IN OUT NOCOPY NUMBER,
          x_attribute1                    IN     VARCHAR2,
          x_attribute2                    IN     VARCHAR2,
          x_attribute3                    IN     VARCHAR2,
          x_attribute4                    IN     VARCHAR2,
          x_attribute5                    IN     VARCHAR2,
          x_attribute6                    IN     VARCHAR2,
          x_attribute7                    IN     VARCHAR2,
          x_attribute8                    IN     VARCHAR2,
          x_attribute9                    IN     VARCHAR2,
          x_attribute10                   IN     VARCHAR2,
          x_attribute11                   IN     VARCHAR2,
          x_attribute12                   IN     VARCHAR2,
          x_attribute13                   IN     VARCHAR2,
          x_attribute14                   IN     VARCHAR2,
          x_attribute15                   IN     VARCHAR2,
          x_location_id                   IN     NUMBER,
          x_person_id                     IN     NUMBER,
          x_project_id                    IN     NUMBER,
          x_task_id                       IN     NUMBER,
          x_emp_assign_start_date         IN     DATE,
          x_emp_assign_end_date           IN     DATE,
          x_cost_center_code              IN     VARCHAR2,
          x_allocated_area_pct            IN     NUMBER,
          x_allocated_area                IN     NUMBER,
          x_utilized_area                 IN     NUMBER,
          x_emp_space_comments            IN     VARCHAR2,
          x_attribute_category            IN     VARCHAR2,
          x_creation_date                 IN     DATE,
          x_created_by                    IN     NUMBER,
          x_last_update_date              IN     DATE,
          x_last_updated_by               IN     NUMBER,
          x_last_update_login             IN     NUMBER,
          x_org_id                        IN     NUMBER,
          x_source                        IN     VARCHAR2
        )
IS

   CURSOR c IS
      SELECT ROWID
      FROM pn_space_assign_emp_all
      WHERE emp_space_assign_id = x_emp_space_assign_id;

   l_err_msg    VARCHAR2(30);
   l_asgn_mode  VARCHAR2(30);

   CURSOR org_cur IS
     SELECT org_id
     FROM   pn_locations_all
     WHERE  location_id = x_location_id;

   l_org_id NUMBER;

BEGIN

   pnp_debug_pkg.debug ('PN_SPACE_ASSIGN_EMP_PKG.INSERT_ROW (+) SpcAsgnId: '
                        ||x_emp_space_assign_id||', LocId: '||x_location_id
                        ||', StrDt: '||TO_CHAR(x_emp_assign_start_date,'MM/DD/YYYY')
                        ||', EndDt: '||TO_CHAR(x_emp_assign_end_date, 'MM/DD/YYYY')
                        ||', CC: '||x_cost_center_code||', PerId: '||x_person_id);

   -- Check if location is contigious Employee/CC Assignable betn assign start and end dates.
   IF x_person_id IS NOT NULL THEN
      l_asgn_mode := 'EMP';
   ELSE
      l_asgn_mode := 'CC';
   END IF;
   pnt_locations_pkg.Check_Location_Gaps(
                          p_loc_id     => x_location_id
                         ,p_str_dt     => x_emp_assign_start_date
                         ,p_end_dt     => NVL(x_emp_assign_end_date, TO_DATE('12/31/4712','MM/DD/YYYY'))
                         ,p_asgn_mode  => l_asgn_mode
                         ,p_err_msg    => l_err_msg
                          );

   IF l_err_msg IS NOT NULL THEN
      fnd_message.set_name('PN', 'PN_INVALID_SPACE_ASSGN_DATE');
      app_exception.raise_exception;
   END IF;

   pn_space_assign_emp_pkg.check_dupemp_assign(p_person_id      => x_person_id,
                                               p_cost_cntr_code => x_cost_center_code,
                                               p_loc_id         => x_location_id,
                                               p_assgn_str_dt   => x_emp_assign_start_date);

   -------------------------------------------------------
   -- Select the nextval for emp space assign id
   -------------------------------------------------------

   IF x_org_id IS NULL THEN
    FOR rec IN org_cur LOOP
      l_org_id := rec.org_id;
    END LOOP;
   ELSE
    l_org_id := x_org_id;
   END IF;

   IF (x_emp_space_assign_id IS NULL) THEN

      SELECT  pn_space_assign_emp_s.NEXTVAL
      INTO    x_emp_space_assign_id
      FROM    DUAL;
   END IF;

   INSERT INTO pn_space_assign_emp_all
   (
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
               emp_space_assign_id,
               location_id,
               person_id,
               project_id,
               task_id,
               emp_assign_start_date,
               emp_assign_end_date,
               cost_center_code,
               allocated_area_pct,
               allocated_area,
               utilized_area,
               emp_space_comments,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login,
               attribute_category,
               org_id,
               source
   )
   VALUES
   (
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
               x_emp_space_assign_id,
               x_location_id,
               x_person_id,
               x_project_id,
               x_task_id,
               x_emp_assign_start_date,
               x_emp_assign_end_date,
               x_cost_center_code,
               x_allocated_area_pct,
               x_allocated_area,
               x_utilized_area,
               x_emp_space_comments,
               x_last_update_date,
               x_last_updated_by,
               x_creation_date,
               x_created_by,
               x_last_update_login,
               x_attribute_category,
               l_org_id,
               x_source
   );

   OPEN c;
      FETCH c INTO x_rowid;
      IF (c%NOTFOUND) THEN
         CLOSE c;
         RAISE NO_DATA_FOUND;
      END IF;
   CLOSE C;

   pnp_debug_pkg.debug ('PN_SPACE_ASSIGN_EMP_PKG.INSERT_ROW (-) SpcAsgnId: '
                        ||x_emp_space_assign_id||', LocId: '||x_location_id
                        ||', StrDt: '||TO_CHAR(x_emp_assign_start_date,'MM/DD/YYYY')
                        ||', EndDt: '||TO_CHAR(x_emp_assign_end_date, 'MM/DD/YYYY')
                        ||', CC: '||x_cost_center_code||', PerId: '||x_person_id);

END Insert_Row;

-----------------------------------------------------------------------
-- PROCDURE : Lock_Row
-----------------------------------------------------------------------

PROCEDURE Lock_Row (
          x_emp_space_assign_id           IN     NUMBER,
          x_attribute1                    IN     VARCHAR2,
          x_attribute2                    IN     VARCHAR2,
          x_attribute3                    IN     VARCHAR2,
          x_attribute4                    IN     VARCHAR2,
          x_attribute5                    IN     VARCHAR2,
          x_attribute6                    IN     VARCHAR2,
          x_attribute7                    IN     VARCHAR2,
          x_attribute8                    IN     VARCHAR2,
          x_attribute9                    IN     VARCHAR2,
          x_attribute10                   IN     VARCHAR2,
          x_attribute11                   IN     VARCHAR2,
          x_attribute12                   IN     VARCHAR2,
          x_attribute13                   IN     VARCHAR2,
          x_attribute14                   IN     VARCHAR2,
          x_attribute15                   IN     VARCHAR2,
          x_location_id                   IN     NUMBER,
          x_person_id                     IN     NUMBER,
          x_project_id                    IN     NUMBER,
          x_task_id                       IN     NUMBER,
          x_emp_assign_start_date         IN     DATE,
          x_emp_assign_end_date           IN     DATE,
          x_cost_center_code              IN     VARCHAR2,
          x_allocated_area_pct            IN     NUMBER,
          x_allocated_area                IN     NUMBER,
          x_utilized_area                 IN     NUMBER,
          x_emp_space_comments            IN     VARCHAR2,
          x_attribute_category            IN     VARCHAR2)
IS

   CURSOR c1 IS
      SELECT *
      FROM   pn_space_assign_emp_all
      WHERE  emp_space_assign_id = x_emp_space_assign_id
      FOR UPDATE OF emp_space_assign_id NOWAIT;

BEGIN

   pnp_debug_pkg.debug ('PN_SPACE_ASSIGN_EMP_PKG.LOCK_ROW (+) SpcAsgnId: '
                        ||x_emp_space_assign_id);

   OPEN c1;
      FETCH c1 INTO tlempinfo;
      IF (c1%NOTFOUND) THEN
         CLOSE c1;
         RETURN;
      END IF;
   CLOSE c1;

   IF NOT (tlempinfo.EMP_SPACE_ASSIGN_ID = X_EMP_SPACE_ASSIGN_ID) THEN
      pn_var_rent_pkg.lock_row_exception('EMP_SPACE_ASSIGN_ID',tlempinfo.EMP_SPACE_ASSIGN_ID);
   END IF;

   IF NOT ((tlempinfo.location_id = x_location_id)
       OR ((tlempinfo.location_id IS NULL) AND (x_location_id IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('LOCATION_ID',tlempinfo.location_id);
   END IF;

   IF NOT ((TLEMPINFO.person_id = x_person_id)
       OR ((tlempinfo.person_id IS NULL) AND (x_person_id IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PERSON_ID',tlempinfo.person_id);
   END IF;

   IF NOT ((tlempinfo.project_id = x_project_id)
       OR ((tlempinfo.project_id IS NULL) AND (x_project_id IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PROJECT_ID',tlempinfo.project_id);
   END IF;

   IF NOT ((tlempinfo.task_id = x_task_id)
       OR ((tlempinfo.task_id IS NULL) AND (x_task_id IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('TASK_ID',tlempinfo.task_id);
   END IF;

   IF NOT ((trunc(tlempinfo.emp_assign_end_date) = TRUNC(x_emp_assign_end_date))
       OR ((tlempinfo.emp_assign_end_date IS NULL) AND (x_emp_assign_end_date IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('EMP_ASSIGN_END_DATE',tlempinfo.emp_assign_end_date);
   END IF;

   IF NOT ((tlempinfo.cost_center_code = x_cost_center_code)
       OR ((tlempinfo.cost_center_code IS NULL) AND (x_cost_center_code IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('COST_CENTER_CODE',tlempinfo.cost_center_code);
   END IF;

   IF NOT ((tlempinfo.allocated_area_pct = x_allocated_area_pct)
       OR ((tlempinfo.allocated_area_pct IS NULL) AND (x_allocated_area_pct IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ALLOCATED_AREA_PCT',tlempinfo.allocated_area_pct);
   END IF;

   IF NOT ((tlempinfo.allocated_area = x_allocated_area)
       OR ((tlempinfo.allocated_area IS NULL) AND (x_allocated_area IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ALLOCATED_AREA',tlempinfo.allocated_area);
   END IF;

   IF NOT ((tlempinfo.utilized_area = x_utilized_area)
       OR ((tlempinfo.utilized_area IS NULL) AND (x_utilized_area IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('UTILIZED_AREA',tlempinfo.utilized_area);
   END IF;

   IF NOT ((tlempinfo.emp_space_comments = x_emp_space_comments)
       OR ((tlempinfo.emp_space_comments IS NULL) AND (x_emp_space_comments IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('EMP_SPACE_COMMENTS',tlempinfo.emp_space_comments);
   END IF;

   IF NOT ((tlempinfo.attribute_category = x_attribute_category)
       OR ((tlempinfo.attribute_category IS NULL) AND (x_attribute_category IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE_CATEGORY',tlempinfo.attribute_category);
   END IF;

   IF NOT ((tlempinfo.attribute1 = x_attribute1)
       OR ((tlempinfo.attribute1 IS NULL) AND (x_attribute1 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE1',tlempinfo.attribute1);
   END IF;

   IF NOT ((tlempinfo.attribute2 = x_attribute2)
       OR ((tlempinfo.attribute2 IS NULL) AND (x_attribute2 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE2',tlempinfo.attribute2);
   END IF;

   IF NOT ((tlempinfo.attribute3 = x_attribute3)
       OR ((tlempinfo.attribute3 IS NULL) AND (x_attribute3 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE3',tlempinfo.attribute3);
   END IF;

   IF NOT ((tlempinfo.attribute4 = x_attribute4)
       OR ((tlempinfo.attribute4 IS NULL) AND (x_attribute4 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE4',tlempinfo.attribute4);
   END IF;

   IF NOT ((tlempinfo.attribute5 = x_attribute5)
       OR ((tlempinfo.attribute5 IS NULL) AND (x_attribute5 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE5',tlempinfo.attribute5);
   END IF;

   IF NOT ((tlempinfo.attribute6 = x_attribute6)
       OR ((tlempinfo.attribute6 IS NULL) AND (x_attribute6 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE6',tlempinfo.attribute6);
   END IF;

   IF NOT ((tlempinfo.attribute7 = x_attribute7)
       OR ((tlempinfo.attribute7 IS NULL) AND (x_attribute7 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE7',tlempinfo.attribute7);
   END IF;

   IF NOT ((tlempinfo.attribute8 = x_attribute8)
       OR ((tlempinfo.attribute8 IS NULL) AND (x_attribute8 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE8',tlempinfo.attribute8);
   END IF;

   IF NOT ((tlempinfo.attribute9 = x_attribute9)
       OR ((tlempinfo.attribute9 IS NULL) AND (x_attribute9 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE9',tlempinfo.attribute9);
   END IF;

   IF NOT ((tlempinfo.attribute10 = x_attribute10)
       OR ((tlempinfo.attribute10 IS NULL) AND (x_attribute10 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE10',tlempinfo.attribute10);
   END IF;

   IF NOT ((tlempinfo.attribute11 = x_attribute11)
       OR ((tlempinfo.attribute11 IS NULL) AND (x_attribute11 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE11',tlempinfo.attribute11);
   END IF;

   IF NOT ((tlempinfo.attribute12 = x_attribute12)
       OR ((tlempinfo.attribute12 IS NULL) AND (x_attribute12 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE12',tlempinfo.attribute12);
   END IF;

   IF NOT ((tlempinfo.attribute13 = x_attribute13)
       OR ((tlempinfo.attribute13 IS NULL) AND (x_attribute13 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE13',tlempinfo.attribute13);
   END IF;

   IF NOT ((tlempinfo.attribute14 = x_attribute14)
       OR ((tlempinfo.attribute14 IS NULL) AND (x_attribute14 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE14',tlempinfo.attribute14);
   END IF;

   IF NOT ((tlempinfo.attribute15 = x_attribute15)
       OR ((tlempinfo.attribute15 IS NULL) AND (x_attribute15 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE15',tlempinfo.attribute15);
   END IF;

   pnp_debug_pkg.debug ('PN_SPACE_ASSIGN_EMP_PKG.LOCK_ROW (-) SpcAsgnId: '
                        ||x_emp_space_assign_id);

END Lock_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : Update_Row
-- DESCRIPTION  : updates a row in pn_space_assign_emp_all
-- SCOPE        : PUBLIC
-- INVOKED FROM :
-- RETURNS      : NONE
-- HISTORY      :
-- 14-DEC-04 STripath  o Modified for Portfolio Status Enh BUG# 4030816.
--                       Added code to check loc is contigious assignable
--                       betn assign start and end dates.
-- 01-JUL-05 hrodda    o Bug 4284035 - Replaced pn_space_assign_emp
--                       with _ALL table.
-- 08-SEP-05 Hareesha  o Modified insert statement to include org_id.
-------------------------------------------------------------------------------
PROCEDURE Update_Row (
          x_emp_space_assign_id           IN     NUMBER,
          x_attribute1                    IN     VARCHAR2,
          x_attribute2                    IN     VARCHAR2,
          x_attribute3                    IN     VARCHAR2,
          x_attribute4                    IN     VARCHAR2,
          x_attribute5                    IN     VARCHAR2,
          x_attribute6                    IN     VARCHAR2,
          x_attribute7                    IN     VARCHAR2,
          x_attribute8                    IN     VARCHAR2,
          x_attribute9                    IN     VARCHAR2,
          x_attribute10                   IN     VARCHAR2,
          x_attribute11                   IN     VARCHAR2,
          x_attribute12                   IN     VARCHAR2,
          x_attribute13                   IN     VARCHAR2,
          x_attribute14                   IN     VARCHAR2,
          x_attribute15                   IN     VARCHAR2,
          x_location_id                   IN     NUMBER,
          x_person_id                     IN     NUMBER,
          x_project_id                    IN     NUMBER,
          x_task_id                       IN     NUMBER,
          x_emp_assign_start_date         IN     DATE,
          x_emp_assign_end_date           IN     DATE,
          x_cost_center_code              IN     VARCHAR2,
          x_allocated_area_pct            IN     NUMBER,
          x_allocated_area                IN     NUMBER,
          x_utilized_area                 IN     NUMBER,
          x_emp_space_comments            IN     VARCHAR2,
          x_attribute_category            IN     VARCHAR2,
          x_last_update_date              IN     DATE,
          x_last_updated_by               IN     NUMBER,
          x_last_update_login             IN     NUMBER,
          x_update_correct_option         IN     VARCHAR2,
          x_changed_start_date            OUT NOCOPY DATE,
          x_source                        IN     VARCHAR2
          )
IS

   l_emp_space_assign_id           NUMBER;
   l_err_msg                       VARCHAR2(30);
   l_asgn_mode                     VARCHAR2(30);

   BEGIN

   pnp_debug_pkg.debug ('PN_SPACE_ASSIGN_EMP_PKG.UPDATE_ROW (+) SpcAsgnId: '
                        ||x_emp_space_assign_id||', Mode: '||x_update_correct_option||', LocId: '||x_location_id
                        ||', StrDt: '||TO_CHAR(x_emp_assign_start_date,'MM/DD/YYYY')
                        ||', EndDt: '||TO_CHAR(x_emp_assign_end_date, 'MM/DD/YYYY')
                        ||', CC: '||x_cost_center_code||', PerId: '||x_person_id);

   -- Check if location is contigious Employee/CC Assignable betn assign start and end dates.
   IF (x_location_id <> tlempinfo.location_id) OR
      (x_emp_assign_start_date <> tlempinfo.emp_assign_start_date) OR
      (NVL(x_emp_assign_end_date, TO_DATE('12/31/4712','MM/DD/YYYY')) <>
       NVL(tlempinfo.emp_assign_end_date, TO_DATE('12/31/4712','MM/DD/YYYY')))
   THEN
      IF x_person_id IS NOT NULL THEN
         l_asgn_mode := 'EMP';
      ELSE
         l_asgn_mode := 'CC';
      END IF;
      pnt_locations_pkg.Check_Location_Gaps(
                          p_loc_id     => x_location_id
                         ,p_str_dt     => x_emp_assign_start_date
                         ,p_end_dt     => NVL(x_emp_assign_end_date, TO_DATE('12/31/4712','MM/DD/YYYY'))
                         ,p_asgn_mode  => l_asgn_mode
                         ,p_err_msg    => l_err_msg
                          );

      IF l_err_msg IS NOT NULL THEN
         fnd_message.set_name('PN', 'PN_INVALID_SPACE_ASSGN_DATE');
         app_exception.raise_exception;
      END IF;
   END IF;

   IF ((x_person_id IS NULL AND
        x_cost_center_code <> tlempinfo.cost_center_code) OR
       (x_person_id IS NOT NULL AND
        x_person_id <> tlempinfo.person_id)) THEN

       pn_space_assign_emp_pkg.check_dupemp_assign(p_person_id      => x_person_id,
                                                   p_cost_cntr_code => x_cost_center_code,
                                                   p_loc_id         => x_location_id,
                                                   p_assgn_str_dt   => x_emp_assign_start_date);
   END IF;

   IF x_update_correct_option = 'UPDATE' THEN


      SELECT  pn_space_assign_emp_s.NEXTVAL
      INTO    l_emp_space_assign_id
      FROM    DUAL;

      INSERT INTO pn_space_assign_emp_all
      (
             emp_space_assign_id,
             location_id,
             person_id,
             project_id,
             task_id,
             emp_assign_start_date,
             emp_assign_end_date,
             cost_center_code,
             allocated_area_pct,
             allocated_area,
             utilized_area,
             emp_space_comments,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
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
             source,
             org_id
      )
      VALUES
      (
             l_emp_space_assign_id,
             tlempinfo.location_id,
             tlempinfo.person_id,
             tlempinfo.project_id,
             tlempinfo.task_id,
             tlempinfo.emp_assign_start_date,
             (x_emp_assign_start_date - 1),
             tlempinfo.cost_center_code,
             tlempinfo.allocated_area_pct,
             tlempinfo.allocated_area,
             tlempinfo.utilized_area,
             tlempinfo.emp_space_comments,
             tlempinfo.last_update_date,
             tlempinfo.last_updated_by,
             tlempinfo.creation_date,
             tlempinfo.created_by,
             tlempinfo.last_update_login,
             tlempinfo.attribute_category,
             tlempinfo.attribute1,
             tlempinfo.attribute2,
             tlempinfo.attribute3,
             tlempinfo.attribute4,
             tlempinfo.attribute5,
             tlempinfo.attribute6,
             tlempinfo.attribute7,
             tlempinfo.attribute8,
             tlempinfo.attribute9,
             tlempinfo.attribute10,
             tlempinfo.attribute11,
             tlempinfo.attribute12,
             tlempinfo.attribute13,
             tlempinfo.attribute14,
             tlempinfo.attribute15,
             tlempinfo.source,
             tlempinfo.org_id
      );

   END IF;

   UPDATE pn_space_assign_emp_all
   SET    attribute1                      = x_attribute1,
          attribute2                      = x_attribute2,
          attribute3                      = x_attribute3,
          attribute4                      = x_attribute4,
          attribute5                      = x_attribute5,
          attribute6                      = x_attribute6,
          attribute7                      = x_attribute7,
          attribute8                      = x_attribute8,
          attribute9                      = x_attribute9,
          attribute10                     = x_attribute10,
          attribute11                     = x_attribute11,
          attribute12                     = x_attribute12,
          attribute13                     = x_attribute13,
          attribute14                     = x_attribute14,
          attribute15                     = x_attribute15,
          location_id                     = x_location_id,
          person_id                       = x_person_id,
          project_id                      = x_project_id,
          task_id                         = x_task_id,
          emp_assign_start_date           = x_emp_assign_start_date,
          emp_assign_end_date             = x_emp_assign_end_date,
          cost_center_code                = x_cost_center_code,
          allocated_area_pct              = x_allocated_area_pct,
          allocated_area                  = x_allocated_area,
          utilized_area                   = x_utilized_area,
          emp_space_comments              = x_emp_space_comments,
          attribute_category              = x_attribute_category,
          emp_space_assign_id             = x_emp_space_assign_id,
          last_update_date                = x_last_update_date,
          last_updated_by                 = x_last_updated_by,
          last_update_login               = x_last_update_login,
          source                          = x_source
   WHERE  emp_space_assign_id             = x_emp_space_assign_id;

   x_changed_start_date := x_emp_assign_start_date ;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   EXCEPTION
      WHEN OTHERS THEN
      app_exception.raise_exception;

   pnp_debug_pkg.debug ('PN_SPACE_ASSIGN_EMP_PKG.UPDATE_ROW (-) SpcAsgnId: '
                        ||x_emp_space_assign_id||', Mode: '||x_update_correct_option||', LocId: '||x_location_id
                        ||', StrDt: '||TO_CHAR(x_emp_assign_start_date,'MM/DD/YYYY')
                        ||', EndDt: '||TO_CHAR(x_emp_assign_end_date, 'MM/DD/YYYY')
                        ||', CC: '||x_cost_center_code||', PerId: '||x_person_id);

END Update_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : Delete_Row
-- DESCRIPTION  : deletes a row from pn_space_assign_emp_all
-- SCOPE        : PUBLIC
-- INVOKED FROM :
-- RETURNS      : NONE
-- HISTORY      :
-- 01-JUL-05 hareesha    o Bug 4284035 - Replaced pn_space_assign_emp
--                          with _ALL table.
-- 25-Aug-05 hareesha    o Bug 4551258 - Addeed cursor emp_space_assign_id_exists
--                         Only if a record exists with the given
--                         emp_space_assign_id does the delete is called.
-- 30-AUG-05 Hareesha    o Bug 4551258 - Removed the cursor emp_space_assign_id_exists
--                         which was added previously inorder to fix the
--                         no_data_found error coming up.
-------------------------------------------------------------------------------
PROCEDURE delete_row(x_emp_space_assign_id IN NUMBER) IS

BEGIN

   pnp_debug_pkg.debug ('PN_SPACE_ASSIGN_EMP_PKG.DELETE_ROW (+) SpcAsgnId: '
                        ||x_emp_space_assign_id);

   DELETE FROM pn_space_assign_emp_all
   WHERE emp_space_assign_id = x_emp_space_assign_id;


   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   pnp_debug_pkg.debug ('PN_SPACE_ASSIGN_EMP_PKG.DELETE_ROW (-) SpcAsgnId: '
                        ||x_emp_space_assign_id);

END delete_row;

-------------------------------------------------------------------------------
-- PROCEDURE : check_office_assign_gaps
-- PURPOSE   : This procedure is being called from INSERT_ROW, UPDATE_ROW
--             of employee_fdr_blk, customer_fdr_blk of PNTSPACE form.
--             It checks for the gaps between office definition and stops
--             the user from assinging an office during that gap interval.
-- IN PARAM  : Location Id, Actice_start_date, Active_end_date.
-- History   :
-- 27-DEC-02   Mrinal Misra   o Mrinal Misra
-- 10-JAN-03   Mrinal Misra   o Modified to run FOR LOOP one lesser
--                              count by 1..loctn_tab.count-1.
-- 01-JUL-05   hrodda         o Bug 4284035 - Replaced pn_locations
--                              with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE check_office_assign_gaps(p_loc_id IN NUMBER,
                                   p_str_dt IN DATE,
                                   p_end_dt IN DATE) IS

   TYPE loctn_rec IS RECORD(
      location_id          pn_locations.location_id%TYPE,
      active_start_date    DATE,
      active_end_date      DATE);

   TYPE loc_type IS
      TABLE OF loctn_rec
      INDEX BY BINARY_INTEGER;

   loctn_tab                 loc_type;
   l_rec_num                 NUMBER;
   l_diff                    NUMBER;
   l_date                    DATE;
   l_err_flag                VARCHAR2(1);

   CURSOR get_loctn_dates IS
      SELECT location_id,
             active_start_date,
             active_end_date
      FROM   pn_locations_all
      WHERE  active_end_date   >= p_str_dt
      AND    active_start_date <= p_end_dt
      AND    location_id        = p_loc_id
      ORDER BY active_start_date;

   CURSOR check_loctn_gap(l_date IN DATE) IS
      SELECT 'Y'
      FROM   DUAL
      WHERE NOT EXISTS (SELECT NULL
                    FROM   pn_locations_all
                    WHERE  l_date BETWEEN active_start_date AND active_end_date
                    AND    location_id =  p_loc_id);

BEGIN

   pnp_debug_pkg.debug ('PN_SPACE_ASSIGN_EMP_PKG.check_office_assign_gaps(+)');

   loctn_tab.delete;
   l_rec_num := 0;
   l_err_flag := 'N';

   IF p_str_dt IS NOT NULL THEN
      OPEN check_loctn_gap(p_str_dt);
      FETCH check_loctn_gap INTO l_err_flag;
      CLOSE check_loctn_gap;

      IF l_err_flag = 'Y' THEN
         fnd_message.set_name('PN', 'PN_ASGN_LOCN_NOT_EFFC_MSG');
         app_exception.raise_exception;
      END IF;
   END IF;

   IF p_end_dt IS NOT NULL THEN
      OPEN check_loctn_gap(p_end_dt);
      FETCH check_loctn_gap INTO l_err_flag;
      CLOSE check_loctn_gap;

      IF l_err_flag = 'Y' THEN
         fnd_message.set_name('PN', 'PN_ASGN_LOCN_NOT_EFFC_MSG');
         app_exception.raise_exception;
      END IF;
   END IF;

   IF p_end_dt IS NOT NULL AND p_str_dt IS NOT NULL THEN
      FOR loc_rec IN get_loctn_dates LOOP
         l_rec_num :=  NVL(loctn_tab.COUNT,0) + 1;
         loctn_tab(l_rec_num) := loc_rec;
      END LOOP;

      IF NVL(l_rec_num,0) > 1 THEN
         FOR i in 1..loctn_tab.COUNT-1 LOOP

            SELECT loctn_tab(i+1).active_start_date -
                   loctn_tab(i).active_end_date
            INTO   l_diff
            FROM   DUAL;

            IF l_diff > 1 THEN
               l_err_flag := 'Y';
               EXIT;
            END IF;
         END LOOP;

      ELSIF NVL(l_rec_num,0) = 0 THEN
         l_err_flag := 'Y';
      END IF;

      IF l_err_flag = 'Y' THEN
         fnd_message.set_name('PN', 'PN_ASGN_LOCN_NOT_EFFC_MSG');
         app_exception.raise_exception;
      END IF;
   END IF;

   pnp_debug_pkg.debug ('PN_SPACE_ASSIGN_EMP_PKG.check_office_assign_gaps(-)');

END check_office_assign_gaps;

-------------------------------------------------------------------------------
-- PROCEDURE : check_dupemp_assign
-- PURPOSE   : The procedure checks to see if there exists another assignment
--             record for person id/cost center code, for the same date range.
--             If there exists one then it stops user from doing the assignment.
-- IN PARAM  : Person Id, Cost Center Code, Location Id,
--             Employee Assignment Start Date.
-- History   :
-- 16-JAN-03  Mrinal    o Created.
-- 22-JAN-03  Mrinal    o Modified WHERE clause of check_emp_assignment,
--                        check_ccd_assignment cursor to check for
--                        exisitng assignment.
-- 22-FEB-05  ftanudja  o Removed check for duplicate cost center code.#4116762
-------------------------------------------------------------------------------
PROCEDURE check_dupemp_assign(p_person_id      IN NUMBER,
                              p_cost_cntr_code IN VARCHAR2,
                              p_loc_id         IN NUMBER,
                              p_assgn_str_dt   IN DATE) IS

  l_err_flag       VARCHAR2(1) := 'N';

  CURSOR check_emp_assignment IS
     SELECT 'Y'
     FROM   DUAL
     WHERE  EXISTS (SELECT NULL
                    FROM   pn_space_assign_emp_all
                    WHERE  person_id = p_person_id
                    AND    location_id = p_loc_id
                    AND    cost_center_code = p_cost_cntr_code
                    AND    emp_assign_start_date <= p_assgn_str_dt
                    AND    NVL(emp_assign_end_date, TO_DATE('12/31/4712', 'MM/DD/YYYY'))
                           >= p_assgn_str_dt);

  CURSOR check_ccd_assignment IS
     SELECT 'Y'
     FROM   DUAL
     WHERE  EXISTS (SELECT NULL
                    FROM   pn_space_assign_emp_all
                    WHERE  cost_center_code = p_cost_cntr_code
                    AND    location_id = p_loc_id
                    AND    emp_assign_start_date <= p_assgn_str_dt
                    AND    person_id is null
                    AND    NVL(emp_assign_end_date, TO_DATE('12/31/4712', 'MM/DD/YYYY'))
                           >= p_assgn_str_dt);
BEGIN
   l_err_flag := 'N';

   OPEN check_emp_assignment;
   FETCH check_emp_assignment INTO l_err_flag;
   CLOSE check_emp_assignment;

   IF NVL(l_err_flag,'N') = 'Y' THEN
      fnd_message.set_name('PN', 'PN_SPASGN_EMPLOYEE_OVRLAP_MSG');
      app_exception.raise_exception;
   END IF;

END check_dupemp_assign;

-------------------------------------------------------------------------------
-- PROCDURE     : get_Least_st_date_assignment
-- PURPOSE      : Returns the emp_space_assign_id having the least_st_date to
--                diff between the original-assignment and
--                system-generated assignment
-- HISTORY      :
-- 20-JUL-05  hareesha o created bug #4116645
-------------------------------------------------------------------------------
FUNCTION get_least_st_date_assignment
(p_loc_id  IN NUMBER,
 p_emp_id  IN NUMBER,
 p_cc_code IN VARCHAR2)
RETURN NUMBER IS

   l_emp_space_assign_id  NUMBER := -1;

   CURSOR get_person_assign_id( p_loc    IN NUMBER
                               ,p_person IN NUMBER) IS
      SELECT emp_space_assign_id
      FROM   pn_space_assign_emp_all
      WHERE  location_id = p_loc
      AND    person_id   = p_person
      AND    emp_assign_start_date =
             (SELECT MIN(emp_assign_start_date)
              FROM pn_space_assign_emp_all
              WHERE location_id = p_loc
              AND   person_id   = p_person);

    CURSOR get_cc_assign_id( p_loc IN NUMBER
                            ,p_cc  IN VARCHAR2) IS
       SELECT emp_space_assign_id
       FROM   pn_space_assign_emp_all
       WHERE  location_id = p_loc
       AND    cost_center_code = p_cc
       AND    emp_assign_start_date =
              (SELECT MIN(emp_assign_start_date)
               FROM pn_space_assign_emp_all
               WHERE location_id = p_loc
               AND   cost_center_code = p_cc);

BEGIN
   pnp_debug_pkg.debug ('PN_SPACE_ASSIGN_EMP_PKG.GET_LEAST_ST_DATE_ASSIGNMENT(+)');

   IF p_emp_id IS NOT NULL THEN
      FOR emp IN get_person_assign_id(p_loc_id, p_emp_id) LOOP
         l_emp_space_assign_id := emp.emp_space_assign_id;
      END LOOP;
   ELSIF p_cc_code IS NOT NULL THEN
      FOR emp IN get_cc_assign_id(p_loc_id, p_cc_code) LOOP
         l_emp_space_assign_id := emp.emp_space_assign_id;
      END LOOP;
   END IF;

   pnp_debug_pkg.debug ('PN_SPACE_ASSIGN_EMP_PKG.GET_LEAST_ST_DATE_ASSIGNMENT(-)');

   RETURN l_emp_space_assign_id;

END get_Least_st_date_assignment;

END pn_space_assign_emp_pkg;

/
