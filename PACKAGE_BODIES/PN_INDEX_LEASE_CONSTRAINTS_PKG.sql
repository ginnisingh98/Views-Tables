--------------------------------------------------------
--  DDL for Package Body PN_INDEX_LEASE_CONSTRAINTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_INDEX_LEASE_CONSTRAINTS_PKG" AS
-- $Header: PNTINLCB.pls 120.3 2007/01/30 10:39:43 pseeram ship $


/*============================================================================+
|                Copyright (c) 2001 Oracle Corporation
|                   Redwood Shores, California, USA
|                        All rights reserved.
| DESCRIPTION
|
|  These procedures consist are used a table handlers for the
|  PN_INDEX_LEASE_CONSTRAINTS table.
|  They include:
|         INSERT_ROW - insert a row into PN_INDEX_LEASE_CONSTRAINTS.
|         DELETE_ROW - deletes a row from PN_INDEX_LEASE_CONSTRAINTS.
|         UPDATE_ROW - updates a row from PN_INDEX_LEASE_CONSTRAINTS.
|         LOCKS_ROW - will check if a row has been modified since being
|                     queried by form.
|
|
| HISTORY
| 11-APR-2001  jbreyes        o Created
| 13-DEC-2001  Mrinal Misra   o Added dbdrv command.
| 15-JAN-2002  Mrinal Misra   o In dbdrv command changed phase=pls to phase=plb.
|                               Added checkfile.Ref. Bug# 2184724.
| 09-JUL-2002  ftanudja       o added x_org_id parameter in insert_row for
|                               shared serv. enh.
| 23-JUL-2002  ftanudja       o changed lock_row to comply with new standards
| 05-Jul-2005  hrodda         o overloaded delete_row proc to take PK as parameter
| 19-JAN-2007  Prabnhakar     o Modified the update_row update where condition.
+============================================================================*/

-------------------------------------------------------------------------------
-- PROCDURE : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 04-JUL-05  hrodda  o Bug 4284035 - Replaced pn_index_lease_constraints with
--                      _ALL table.
-------------------------------------------------------------------------------
PROCEDURE insert_row (
    x_rowid                 IN OUT NOCOPY  VARCHAR2
   ,x_org_id                IN             NUMBER
   ,x_index_constraint_id   IN OUT NOCOPY  NUMBER
   ,x_index_lease_id        IN             NUMBER
   ,x_scope                 IN             VARCHAR2
   ,x_last_update_date      IN             DATE
   ,x_last_updated_by       IN             NUMBER
   ,x_creation_date         IN             DATE
   ,x_created_by            IN             NUMBER
   ,x_minimum_amount        IN             NUMBER
   ,x_maximum_amount        IN             NUMBER
   ,x_minimum_percent       IN             NUMBER
   ,x_maximum_percent       IN             NUMBER
   ,x_last_update_login     IN             NUMBER
   ,x_attribute_category    IN             VARCHAR2
   ,x_attribute1            IN             VARCHAR2
   ,x_attribute2            IN             VARCHAR2
   ,x_attribute3            IN             VARCHAR2
   ,x_attribute4            IN             VARCHAR2
   ,x_attribute5            IN             VARCHAR2
   ,x_attribute6            IN             VARCHAR2
   ,x_attribute7            IN             VARCHAR2
   ,x_attribute8            IN             VARCHAR2
   ,x_attribute9            IN             VARCHAR2
   ,x_attribute10           IN             VARCHAR2
   ,x_attribute11           IN             VARCHAR2
   ,x_attribute12           IN             VARCHAR2
   ,x_attribute13           IN             VARCHAR2
   ,x_attribute14           IN             VARCHAR2
   ,x_attribute15           IN             VARCHAR2
) IS
   CURSOR c IS
      SELECT ROWID
      FROM pn_index_lease_constraints_all
      WHERE index_constraint_id = x_index_constraint_id;

   l_return_status   VARCHAR2 (30) := NULL;
   l_rowid           VARCHAR2 (18) := NULL;

   CURSOR org_cur IS
     SELECT org_id FROM pn_index_leases_all WHERE index_lease_id = x_index_lease_id;
   l_org_ID NUMBER;

BEGIN

   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_CONSTRAINTS_PKG.insert_row (+)');
   /* If no INDEX_CONSTRAINT_ID is provided, get one from sequence */

   IF (x_index_constraint_id IS NULL) THEN
      SELECT pn_index_lease_constraints_s.NEXTVAL
      INTO x_index_constraint_id
      FROM DUAL;
   END IF;

    IF x_org_id IS NULL THEN
      FOR rec IN org_cur LOOP
        l_org_id := rec.org_id;
      END LOOP;
    ELSE
      l_org_id := x_org_id;
    END IF;

   pn_index_lease_constraints_pkg.check_unq_constraint_scope (
      l_return_status
      ,x_index_constraint_id
      ,x_index_lease_id
      ,x_scope
   );

   IF (l_return_status IS NOT NULL) THEN
      app_exception.raise_exception;
   END IF;

   INSERT INTO pn_index_lease_constraints_all
   (
       index_constraint_id
      ,org_id
      ,index_lease_id
      ,scope
      ,last_update_date
      ,last_updated_by
      ,creation_date
      ,created_by
      ,minimum_amount
      ,maximum_amount
      ,minimum_percent
      ,maximum_percent
      ,last_update_login
      ,attribute_category
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
   )
   VALUES
   (
      x_index_constraint_id
      ,l_org_id
      ,x_index_lease_id
      ,x_scope
      ,x_last_update_date
      ,x_last_updated_by
      ,x_creation_date
      ,x_created_by
      ,x_minimum_amount
      ,x_maximum_amount
      ,x_minimum_percent
      ,x_maximum_percent
      ,x_last_update_login
      ,x_attribute_category
      ,x_attribute1
      ,x_attribute2
      ,x_attribute3
      ,x_attribute4
      ,x_attribute5
      ,x_attribute6
      ,x_attribute7
      ,x_attribute8
      ,x_attribute9
      ,x_attribute10
      ,x_attribute11
      ,x_attribute12
      ,x_attribute13
      ,x_attribute14
      ,x_attribute15
   );

   /* Check if a valid record was created. */
   OPEN c;
      FETCH c INTO x_rowid;
      IF (c%NOTFOUND) THEN
         CLOSE c;
         RAISE NO_DATA_FOUND;
      END IF;
   CLOSE c;

   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_CONSTRAINTS_PKG.insert_row (-)');
END insert_row;


-------------------------------------------------------------------------------
-- PROCDURE     : UPDATE_ROW
-- INVOKED FROM : UPDATE_ROW procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 04-JUL-05  hrodda    o Bug 4284035 - Replaced pn_index_lease_constraints with
--                       _ALL table.
-- 19-JAN-07  Prabhakar o Bug #5768023
--                        Modified the update where condition based on
--                        index_constraint_id.
-------------------------------------------------------------------------------
PROCEDURE update_row
(
    x_rowid                 IN   VARCHAR2
   ,x_index_constraint_id   IN   NUMBER
   ,x_index_lease_id        IN   NUMBER
   ,x_scope                 IN   VARCHAR2
   ,x_last_update_date      IN   DATE
   ,x_last_updated_by       IN   NUMBER
   ,x_minimum_amount        IN   NUMBER
   ,x_maximum_amount        IN   NUMBER
   ,x_minimum_percent       IN   NUMBER
   ,x_maximum_percent       IN   NUMBER
   ,x_last_update_login     IN   NUMBER
   ,x_attribute_category    IN   VARCHAR2
   ,x_attribute1            IN   VARCHAR2
   ,x_attribute2            IN   VARCHAR2
   ,x_attribute3            IN   VARCHAR2
   ,x_attribute4            IN   VARCHAR2
   ,x_attribute5            IN   VARCHAR2
   ,x_attribute6            IN   VARCHAR2
   ,x_attribute7            IN   VARCHAR2
   ,x_attribute8            IN   VARCHAR2
   ,x_attribute9            IN   VARCHAR2
   ,x_attribute10           IN   VARCHAR2
   ,x_attribute11           IN   VARCHAR2
   ,x_attribute12           IN   VARCHAR2
   ,x_attribute13           IN   VARCHAR2
   ,x_attribute14           IN   VARCHAR2
   ,x_attribute15           IN   VARCHAR2
)
IS
   l_return_status   VARCHAR2 (30) := NULL;
BEGIN

   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_CONSTRAINTS_PKG.update_row (+)');

   pn_index_lease_constraints_pkg.check_unq_constraint_scope (
      l_return_status
      ,x_index_constraint_id
      ,x_index_lease_id
      ,x_scope
   );

   IF (l_return_status IS NOT NULL) THEN
      app_exception.raise_exception;
   END IF;

   UPDATE pn_index_lease_constraints_all
   SET
       index_lease_id = x_index_lease_id
      ,scope = x_scope
      ,last_update_date = x_last_update_date
      ,last_updated_by = x_last_updated_by
      ,minimum_amount = x_minimum_amount
      ,maximum_amount = x_maximum_amount
      ,minimum_percent = x_minimum_percent
      ,maximum_percent = x_maximum_percent
      ,last_update_login = x_last_update_login
      ,attribute_category = x_attribute_category
      ,attribute1 = x_attribute1
      ,attribute2 = x_attribute2
      ,attribute3 = x_attribute3
      ,attribute4 = x_attribute4
      ,attribute5 = x_attribute5
      ,attribute6 = x_attribute6
      ,attribute7 = x_attribute7
      ,attribute8 = x_attribute8
      ,attribute9 = x_attribute9
      ,attribute10 = x_attribute10
      ,attribute11 = x_attribute11
      ,attribute12 = x_attribute12
      ,attribute13 = x_attribute13
      ,attribute14 = x_attribute14
      ,attribute15 = x_attribute15
   WHERE index_constraint_id = x_index_constraint_id;


   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_CONSTRAINTS_PKG.update_row (-)');

END update_row;

-------------------------------------------------------------------------------
-- PROCDURE     : lock_row
-- INVOKED FROM : lock_row procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 04-JUL-05  hrodda  o Bug 4284035 - Replaced pn_index_lease_constraints with
--                      _ALL table and changed the where clause for the cursor.
-------------------------------------------------------------------------------
PROCEDURE lock_row
(
   x_rowid                 IN   VARCHAR2
   ,x_index_constraint_id   IN   NUMBER
   ,x_index_lease_id        IN   NUMBER
   ,x_scope                 IN   VARCHAR2
   ,x_minimum_amount        IN   NUMBER
   ,x_maximum_amount        IN   NUMBER
   ,x_minimum_percent       IN   NUMBER
   ,x_maximum_percent       IN   NUMBER
   ,x_attribute_category    IN   VARCHAR2
   ,x_attribute1            IN   VARCHAR2
   ,x_attribute2            IN   VARCHAR2
   ,x_attribute3            IN   VARCHAR2
   ,x_attribute4            IN   VARCHAR2
   ,x_attribute5            IN   VARCHAR2
   ,x_attribute6            IN   VARCHAR2
   ,x_attribute7            IN   VARCHAR2
   ,x_attribute8            IN   VARCHAR2
   ,x_attribute9            IN   VARCHAR2
   ,x_attribute10           IN   VARCHAR2
   ,x_attribute11           IN   VARCHAR2
   ,x_attribute12           IN   VARCHAR2
   ,x_attribute13           IN   VARCHAR2
   ,x_attribute14           IN   VARCHAR2
   ,x_attribute15           IN   VARCHAR2
)
IS
   CURSOR c1 IS
      SELECT        *
      FROM pn_index_lease_constraints_all
      WHERE index_constraint_id = x_index_constraint_id
      FOR UPDATE OF index_constraint_id NOWAIT;

   tlinfo   c1%ROWTYPE;
BEGIN

   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_CONSTRAINTS_PKG.lock_row (+)');
   OPEN c1;
      FETCH c1 INTO tlinfo;
      IF (c1%NOTFOUND) THEN
         CLOSE c1;
         RETURN;
      END IF;
   CLOSE c1;

   IF NOT (tlinfo.index_constraint_id = x_index_constraint_id) THEN
      pn_var_rent_pkg.lock_row_exception('INDEX_CONSTRAINT_ID',tlinfo.index_constraint_id);
   END IF;

   IF NOT (tlinfo.index_lease_id = x_index_lease_id) THEN
      pn_var_rent_pkg.lock_row_exception('INDEX_LEASE_ID',tlinfo.index_lease_id);
   END IF;

   IF NOT (tlinfo.scope = x_scope) THEN
      pn_var_rent_pkg.lock_row_exception('SCOPE',tlinfo.scope);
   END IF;

   IF NOT ((tlinfo.minimum_amount = x_minimum_amount)
        OR ((tlinfo.minimum_amount IS NULL) AND x_minimum_amount IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('MINIMUM_AMOUNT',tlinfo.minimum_amount);
   END IF;

   IF NOT ((tlinfo.maximum_amount = x_maximum_amount)
        OR ((tlinfo.maximum_amount IS NULL) AND x_maximum_amount IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('MAXIMUM_AMOUNT',tlinfo.maximum_amount);
   END IF;

   IF NOT ((tlinfo.minimum_percent = x_minimum_percent)
        OR ((tlinfo.minimum_percent IS NULL) AND x_minimum_percent IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('MINIMUM_PERCENT',tlinfo.minimum_percent);
   END IF;

   IF NOT ((tlinfo.maximum_percent = x_maximum_percent)
        OR ((tlinfo.maximum_percent IS NULL) AND x_maximum_percent IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('MAXIMUM_PERCENT',tlinfo.maximum_percent);
   END IF;

   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_CONSTRAINTS_PKG.lock_row (-)');
END lock_row;


-------------------------------------------------------------------------------
-- PROCDURE     : delete_row
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 04-JUL-05  hrodda  o Bug 4284035 - Replaced pn_index_lease_constraints with
--                      _ALL table.
-------------------------------------------------------------------------------
PROCEDURE delete_row
(
   x_rowid   IN   VARCHAR2
)
IS
BEGIN
   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_CONSTRAINTS_PKG.delete_row (+)');

   DELETE FROM pn_index_lease_constraints_all
   WHERE  ROWID = x_rowid;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_CONSTRAINTS_PKG.delete_row (-)');
END delete_row;


-------------------------------------------------------------------------------
-- PROCDURE     : delete_row
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : deletes the row
-- NOTE         : overrided delete_row procedure to take PK as in parameter
-- HISTORY      :
-- 04-JUL-05  hrodda  o Created.
-------------------------------------------------------------------------------
PROCEDURE delete_row (
    x_index_constraint_id  IN   NUMBER
)
IS
BEGIN
   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_CONSTRAINTS_PKG.delete_row (+)');
      DELETE FROM pn_index_lease_constraints_all
      WHERE index_constraint_id = x_index_constraint_id;

      IF (SQL%NOTFOUND) THEN
         RAISE NO_DATA_FOUND;
      END IF;

   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_CONSTRAINTS_PKG.delete_row (-)');
END delete_row;


-------------------------------------------------------------------------------
-- PROCDURE     : check_unq_constraint_scope
-- INVOKED FROM : insert_row and update_row procedure
-- PURPOSE      : Checks unique constraint.
-- HISTORY      :
-- 04-JUL-05  hrodda  o Bug 4284035 - Replaced pn_index_lease_constraints with
--                      _ALL table.
-------------------------------------------------------------------------------
PROCEDURE check_unq_constraint_scope
(
   x_return_status          IN OUT NOCOPY  VARCHAR2
   ,x_index_constraint_id   IN             NUMBER
   ,x_index_lease_id        IN             NUMBER
   ,x_scope                 IN             VARCHAR2
)
IS
   l_dummy   NUMBER;
BEGIN
   SELECT 1
   INTO l_dummy
   FROM DUAL
   WHERE NOT EXISTS ( SELECT 1
                      FROM pn_index_lease_constraints_all
                      WHERE (scope = x_scope)
                      AND (index_lease_id = x_index_lease_id)
                      AND (   (x_index_constraint_id IS NULL)
                            OR (index_constraint_id <> x_index_constraint_id)
                          ));
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
   fnd_message.set_name ('PN', 'PN_DUP_INDEX_LEASE_NUMBER');
   x_return_status := 'E';
END check_unq_constraint_scope;
END pn_index_lease_constraints_pkg;

/
