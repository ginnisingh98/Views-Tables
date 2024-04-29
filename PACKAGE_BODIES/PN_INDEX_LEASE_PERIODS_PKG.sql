--------------------------------------------------------
--  DDL for Package Body PN_INDEX_LEASE_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_INDEX_LEASE_PERIODS_PKG" AS
-- $Header: PNTINLPB.pls 120.4 2007/03/14 12:58:14 pseeram ship $

/*============================================================================+
|                Copyright (c) 2001 Oracle Corporation
|                   Redwood Shores, California, USA
|                        All rights reserved.
| DESCRIPTION
|
|  These procedures consist are used a table handlers for the
|  PN_INDEX_LEASE_PERIODS table.
|  They include:
|         INSERT_ROW - insert a row into PN_INDEX_LEASE_PERIODS.
|         DELETE_ROW - deletes a row from PN_INDEX_LEASE_PERIODS.
|         UPDATE_ROW - updates a row from PN_INDEX_LEASE_PERIODS.
|         LOCKS_ROW - will check if a row has been modified since
|                     being queried by form.
|
|
| HISTORY
| 21-MAY-2001  jbreyes        o Created
| 13-DEC-2001  Mrinal Misra   o Added dbdrv command.
| 15-JAN-2002  Mrinal Misra   o In dbdrv command changed phase=pls to phase=plb
|                                 Added checkfile.Ref. Bug# 2184724.
| 09-JUL-2002  ftanudja       o added x_org_id param in insert_row for
|                               shared services enh.
| 23-JUL-2002  ftanudja       o changed lock_row comply with new standards.
| 02-Aug-2002  psidhu         o added parameters op_constraint_applied_amount
|                               and op_carry_forward_amount in call to
|                               pn_index_amount_pkg.calculate_period. Added call
|                               to pn_index_amount_pkg.calculate_subsequent_periods.
| 20-Oct-2002  psidhu         o added parameters op_constraint_applied_percent
|                               and op_carry_forward_percent in call to
|                               procedure pn_index_amount_pkg.calculate_period.
| 05-Jul-2005  hrodda         o overloaded delete_row proc to take PK as parameter
| 09-NOV-2006  Prabhakar      o Added index_multiplier to insert/update/lock.
+============================================================================*/

-------------------------------------------------------------------------------
-- PROCDURE : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 04-JUL-05  hrodda   o Bug 4284035 - Replaced pn_index_lease_periods with
--                       _ALL table.
-- 09-NOV-06  Prabhakar o Added index_multiplier to insert_row.
-------------------------------------------------------------------------------
PROCEDURE insert_row
(
    x_rowid                       IN OUT NOCOPY    VARCHAR2
   ,x_org_id                      IN               NUMBER
   ,x_index_period_id             IN OUT NOCOPY    NUMBER
   ,x_index_lease_id              IN               NUMBER
   ,x_line_number                 IN OUT NOCOPY    NUMBER
   ,x_assessment_date             IN               DATE
   ,x_last_update_date            IN               DATE
   ,x_last_updated_by             IN               NUMBER
   ,x_creation_date               IN               DATE
   ,x_created_by                  IN               NUMBER
   ,x_basis_start_date            IN               DATE
   ,x_basis_end_date              IN               DATE
   ,x_index_finder_date           IN               DATE
   ,x_current_index_line_id       IN               NUMBER
   ,x_current_index_line_value    IN               NUMBER
   ,x_previous_index_line_id      IN               NUMBER
   ,x_previous_index_line_value   IN               NUMBER
   ,x_current_basis               IN               NUMBER
   ,x_relationship                IN               VARCHAR2
   ,x_index_percent_change        IN               NUMBER
   ,x_basis_percent_change        IN               NUMBER
   ,x_unconstraint_rent_due       IN               NUMBER
   ,x_constraint_rent_due         IN               NUMBER
   ,x_last_update_login           IN               NUMBER
   ,x_attribute_category          IN               VARCHAR2
   ,x_attribute1                  IN               VARCHAR2
   ,x_attribute2                  IN               VARCHAR2
   ,x_attribute3                  IN               VARCHAR2
   ,x_attribute4                  IN               VARCHAR2
   ,x_attribute5                  IN               VARCHAR2
   ,x_attribute6                  IN               VARCHAR2
   ,x_attribute7                  IN               VARCHAR2
   ,x_attribute8                  IN               VARCHAR2
   ,x_attribute9                  IN               VARCHAR2
   ,x_attribute10                 IN               VARCHAR2
   ,x_attribute11                 IN               VARCHAR2
   ,x_attribute12                 IN               VARCHAR2
   ,x_attribute13                 IN               VARCHAR2
   ,x_attribute14                 IN               VARCHAR2
   ,x_attribute15                 IN               VARCHAR2
   ,x_index_multiplier            IN               NUMBER)
IS
   CURSOR c IS
      SELECT ROWID
      FROM pn_index_lease_periods_all
      WHERE index_period_id = x_index_period_id;

   l_return_status   VARCHAR2 (30) := NULL;
   l_rowid           VARCHAR2 (18) := NULL;

   CURSOR org_cur IS
     SELECT org_id FROM pn_index_leases_all WHERE index_lease_id = x_index_lease_id;
   l_org_ID NUMBER;

BEGIN

   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_PERIODS_PKG.insert_row (+)');
   /* If no INDEX_PERIOD_ID is provided, get one from sequence */
   IF (x_index_period_id IS NULL) THEN
      SELECT pn_index_lease_periods_s.NEXTVAL
      INTO x_index_period_id
      FROM DUAL;
   END IF;


   /* if no line number is passed derived on from existing list. */

   IF x_line_number IS NULL THEN
      SELECT NVL(MAX (line_number),0) + 1
      INTO x_line_number
      FROM pn_index_lease_periods_all a
      WHERE index_lease_id = x_index_lease_id
      AND a.org_id = x_org_id;
   END IF;

   IF x_org_id IS NULL THEN
      FOR rec IN org_cur LOOP
         l_org_id := rec.org_id;
      END LOOP;
   ELSE
      l_org_id := x_org_id;
   END IF;

   INSERT INTO pn_index_lease_periods_all
   (
       index_period_id
      ,org_id
      ,index_lease_id
      ,line_number
      ,assessment_date
      ,last_update_date
      ,last_updated_by
      ,creation_date
      ,created_by
      ,basis_start_date
      ,basis_end_date
      ,index_finder_date
      ,current_index_line_id
      ,current_index_line_value
      ,previous_index_line_id
      ,previous_index_line_value
      ,current_basis
      ,relationship
      ,index_percent_change
      ,basis_percent_change
      ,unconstraint_rent_due
      ,constraint_rent_due
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
      ,index_multiplier)
   VALUES
   (
        x_index_period_id
       ,l_org_id
       ,x_index_lease_id
       ,x_line_number
       ,x_assessment_date
       ,x_last_update_date
       ,x_last_updated_by
       ,x_creation_date
       ,x_created_by
       ,x_basis_start_date
       ,x_basis_end_date
       ,x_index_finder_date
       ,x_current_index_line_id
       ,x_current_index_line_value
       ,x_previous_index_line_id
       ,x_previous_index_line_value
       ,x_current_basis
       ,x_relationship
       ,x_index_percent_change
       ,x_basis_percent_change
       ,x_unconstraint_rent_due
       ,x_constraint_rent_due
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
       ,x_index_multiplier);


   /* Check if a valid record was created. */
   OPEN c;
      FETCH c INTO x_rowid;
      IF (c%NOTFOUND)
      THEN
         CLOSE c;
         RAISE NO_DATA_FOUND;
      END IF;
   CLOSE c;
   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_PERIODS_PKG.insert_row (-)');
END insert_row;


-------------------------------------------------------------------------------
-- PROCDURE : update_row
-- INVOKED FROM : update_row procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 04-JUL-05  hrodda   o Bug 4284035 - Replaced pn_index_lease_periods with
--                       _ALL table.Also changed the where clause
-- 09-NOV-06  Prabhakar o Added index_multiplier to update_row.
-------------------------------------------------------------------------------
PROCEDURE update_row (
   x_rowid                       IN   VARCHAR2
   ,x_index_period_id             IN   NUMBER
   ,x_index_lease_id              IN   NUMBER
   ,x_line_number                 IN   NUMBER
   ,x_assessment_date             IN   DATE
   ,x_last_update_date            IN   DATE
   ,x_last_updated_by             IN   NUMBER
   ,x_basis_start_date            IN   DATE
   ,x_basis_end_date              IN   DATE
   ,x_index_finder_date           IN   DATE
   ,x_current_index_line_id       IN   NUMBER
   ,x_current_index_line_value    IN   NUMBER
   ,x_previous_index_line_id      IN   NUMBER
   ,x_previous_index_line_value   IN   NUMBER
   ,x_current_basis               IN   NUMBER
   ,x_relationship                IN   VARCHAR2
   ,x_index_percent_change        IN   NUMBER
   ,x_basis_percent_change        IN   NUMBER
   ,x_unconstraint_rent_due       IN   NUMBER
   ,x_constraint_rent_due         IN   NUMBER
   ,x_last_update_login           IN   NUMBER
   ,x_attribute_category          IN   VARCHAR2
   ,x_attribute1                  IN   VARCHAR2
   ,x_attribute2                  IN   VARCHAR2
   ,x_attribute3                  IN   VARCHAR2
   ,x_attribute4                  IN   VARCHAR2
   ,x_attribute5                  IN   VARCHAR2
   ,x_attribute6                  IN   VARCHAR2
   ,x_attribute7                  IN   VARCHAR2
   ,x_attribute8                  IN   VARCHAR2
   ,x_attribute9                  IN   VARCHAR2
   ,x_attribute10                 IN   VARCHAR2
   ,x_attribute11                 IN   VARCHAR2
   ,x_attribute12                 IN   VARCHAR2
   ,x_attribute13                 IN   VARCHAR2
   ,x_attribute14                 IN   VARCHAR2
   ,x_attribute15                 IN   VARCHAR2
   ,x_index_multiplier            IN   NUMBER
   ,x_constraint_applied_amount   IN   NUMBER
   ,x_constraint_applied_percent  IN   NUMBER)
IS
   l_return_status   VARCHAR2 (30) := NULL;
BEGIN

   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_PERIODS_PKG.update_row (+)');
   IF (l_return_status IS NOT NULL)
   THEN
      app_exception.raise_exception;
   END IF;

   UPDATE pn_index_lease_periods_all
   SET index_lease_id = x_index_lease_id
       ,line_number = x_line_number
       ,assessment_date = x_assessment_date
       ,last_update_date = x_last_update_date
       ,last_updated_by = x_last_updated_by
       ,basis_start_date = x_basis_start_date
       ,basis_end_date = x_basis_end_date
       ,index_finder_date = x_index_finder_date
       ,current_index_line_id = x_current_index_line_id
       ,current_index_line_value = x_current_index_line_value
       ,previous_index_line_id = x_previous_index_line_id
       ,previous_index_line_value = x_previous_index_line_value
       ,current_basis = x_current_basis
       ,relationship = x_relationship
       ,index_percent_change = x_index_percent_change
       ,basis_percent_change = x_basis_percent_change
       ,unconstraint_rent_due = x_unconstraint_rent_due
       ,constraint_rent_due = x_constraint_rent_due
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
       ,index_multiplier = x_index_multiplier
       ,constraint_applied_amount = x_constraint_applied_amount
       ,constraint_applied_percent = x_constraint_applied_percent
    WHERE pn_index_lease_periods_all.index_period_id = x_index_period_id;


   IF (SQL%NOTFOUND)
   THEN
      RAISE NO_DATA_FOUND;
   END IF;

   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_PERIODS_PKG.update_row (-)');
END update_row;

-------------------------------------------------------------------------------
-- PROCDURE     : update_row_calc
-- INVOKED FROM : update_row_calc procedure
-- PURPOSE      :
-- HISTORY      :
-- 04-JUL-05  hrodda   o Bug 4284035 - Replaced pn_index_lease_periods with
--                       _ALL table.Also changed the where clause
-- 09-NOV-06  Prabhakar o added index_multiplier.
-------------------------------------------------------------------------------
PROCEDURE update_row_calc (
   x_rowid                       IN                 VARCHAR2
   ,x_calculate                   IN                 VARCHAR2
   ,x_updated_flag                IN                 VARCHAR2
   ,x_index_period_id             IN                 NUMBER
   ,x_index_lease_id              IN                 NUMBER
   ,x_line_number                 IN                 NUMBER
   ,x_assessment_date             IN                 DATE
   ,x_last_update_date            IN                 DATE
   ,x_last_updated_by             IN                 NUMBER
   ,x_basis_start_date            IN                 DATE
   ,x_basis_end_date              IN                 DATE
   ,x_index_finder_date           IN                 DATE
   ,x_current_index_line_id       IN  OUT NOCOPY     NUMBER
   ,x_current_index_line_value    IN  OUT NOCOPY     NUMBER
   ,x_previous_index_line_id      IN  OUT NOCOPY     NUMBER
   ,x_previous_index_line_value   IN  OUT NOCOPY     NUMBER
   ,x_current_basis               IN  OUT NOCOPY     NUMBER
   ,x_relationship                IN                 VARCHAR2
   ,x_index_percent_change        IN  OUT NOCOPY     NUMBER
   ,x_basis_percent_change        IN                 NUMBER
   ,x_unconstraint_rent_due       IN  OUT NOCOPY     NUMBER
   ,x_constraint_rent_due         IN  OUT NOCOPY     NUMBER
   ,x_last_update_login           IN                 NUMBER
   ,x_attribute_category          IN                 VARCHAR2
   ,x_attribute1                  IN                 VARCHAR2
   ,x_attribute2                  IN                 VARCHAR2
   ,x_attribute3                  IN                 VARCHAR2
   ,x_attribute4                  IN                 VARCHAR2
   ,x_attribute5                  IN                 VARCHAR2
   ,x_attribute6                  IN                 VARCHAR2
   ,x_attribute7                  IN                 VARCHAR2
   ,x_attribute8                  IN                 VARCHAR2
   ,x_attribute9                  IN                 VARCHAR2
   ,x_attribute10                 IN                 VARCHAR2
   ,x_attribute11                 IN                 VARCHAR2
   ,x_attribute12                 IN                 VARCHAR2
   ,x_attribute13                 IN                 VARCHAR2
   ,x_attribute14                 IN                 VARCHAR2
   ,x_attribute15                 IN                 VARCHAR2
   ,x_carry_forward_flag          IN                 VARCHAR2
   ,x_index_multiplier            IN                 NUMBER
   ,x_constraint_applied_amount   IN                 NUMBER
   ,x_constraint_applied_percent  IN                 NUMBER)
IS
   l_return_status         VARCHAR2 (30) := NULL;
   l_calc_exists           NUMBER        := NULL;
   l_msg                   VARCHAR2(2000);
   l_previous_index_amount NUMBER := NULL;
   l_previous_asmt_date    DATE   := NULL;
   l_carry_forward_amount       pn_index_lease_periods.carry_forward_amount%type := null;
   l_constraint_applied_amount  pn_index_lease_periods.constraint_applied_amount%type := null;
   l_constraint_applied_percent pn_index_lease_periods.constraint_applied_percent%type :=null;
   l_carry_forward_percent      pn_index_lease_periods.carry_forward_percent%type;

BEGIN

   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_PERIODS_PKG.update_row_calc (+)');
   IF (l_return_status IS NOT NULL)
   THEN
      app_exception.raise_exception;
   END IF;


   UPDATE pn_index_lease_periods_all
   SET index_lease_id = x_index_lease_id
      ,line_number = x_line_number
      ,assessment_date = x_assessment_date
      ,last_update_date = x_last_update_date
      ,last_updated_by = x_last_updated_by
      ,basis_start_date = x_basis_start_date
      ,basis_end_date = x_basis_end_date
      ,index_finder_date = x_index_finder_date
      ,current_index_line_id = x_current_index_line_id
      ,current_index_line_value = x_current_index_line_value
      ,previous_index_line_id = x_previous_index_line_id
      ,previous_index_line_value = x_previous_index_line_value
      ,current_basis = x_current_basis
      ,relationship = x_relationship
      ,index_percent_change = x_index_percent_change
      ,basis_percent_change = x_basis_percent_change
      ,unconstraint_rent_due = x_unconstraint_rent_due
      ,constraint_rent_due = x_constraint_rent_due
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
      ,index_multiplier = x_index_multiplier
      ,constraint_applied_amount = x_constraint_applied_amount
      ,constraint_applied_percent = x_constraint_applied_percent
   WHERE pn_index_lease_periods_all.index_period_id = x_index_period_id;


   IF (SQL%NOTFOUND)
   THEN
      RAISE NO_DATA_FOUND;
   END IF;



   IF x_calculate <> 'CALCULATE' THEN

      l_calc_exists := pn_index_lease_common_pkg.find_if_calc_exists(x_index_lease_id);

      IF l_calc_exists IS NOT NULL  THEN

         pn_index_amount_pkg.calculate_period
         (
            ip_index_lease_id        => x_index_lease_id,
            ip_index_lease_period_id => x_index_period_id,
            ip_recalculate           => 'Y',
            op_current_basis          => x_current_basis,
            op_unconstraint_rent_due       => x_unconstraint_rent_due,
            op_constraint_rent_due    => x_constraint_rent_due,
            op_index_percent_change     => x_index_percent_change,
            op_current_index_line_id    => x_current_index_line_id,
            op_current_index_line_value => x_current_index_line_value,
            op_previous_index_line_id   => x_previous_index_line_id,
            op_previous_index_line_value => x_previous_index_line_value,
            op_previous_index_amount    => l_previous_index_amount,
            op_previous_asmt_date       => l_previous_asmt_date,
            op_constraint_applied_amount   => l_constraint_applied_amount,
            op_carry_forward_amount     => l_carry_forward_amount,
            op_constraint_applied_percent => l_constraint_applied_percent,
            op_carry_forward_percent => l_carry_forward_percent,
            op_msg                   => l_msg
         );


         UPDATE pn_index_lease_periods_all
         SET index_lease_id = x_index_lease_id
            ,line_number = x_line_number
            ,assessment_date = x_assessment_date
            ,last_update_date = x_last_update_date
            ,last_updated_by = x_last_updated_by
            ,basis_start_date = x_basis_start_date
            ,basis_end_date = x_basis_end_date
            ,index_finder_date = x_index_finder_date
            ,current_index_line_id = x_current_index_line_id
            ,current_index_line_value = x_current_index_line_value
            ,previous_index_line_id = x_previous_index_line_id
            ,previous_index_line_value = x_previous_index_line_value
            ,current_basis = x_current_basis
            ,relationship = x_relationship
            ,index_percent_change = x_index_percent_change
            ,basis_percent_change = x_basis_percent_change
            ,unconstraint_rent_due = x_unconstraint_rent_due
            ,constraint_rent_due = x_constraint_rent_due
            ,constraint_applied_amount = l_constraint_applied_amount
            ,carry_forward_amount = l_carry_forward_amount
            ,constraint_applied_percent = l_constraint_applied_percent
            ,carry_forward_percent = l_carry_forward_percent
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
            ,index_multiplier = x_index_multiplier
         WHERE index_period_id = x_index_period_id;



         IF (SQL%NOTFOUND)
         THEN
            RAISE NO_DATA_FOUND;
         END IF;

         IF x_carry_forward_flag = 'Y' THEN
            pn_index_amount_pkg.calculate_subsequent_periods(
                          p_index_lease_id  => x_index_lease_id ,
                          p_assessment_date => x_assessment_date);
         END IF;

      END IF;

   END IF;

   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_PERIODS_PKG.update_row_calc (-)');
END update_row_calc;


-------------------------------------------------------------------------------
-- PROCDURE     : lock_row
-- INVOKED FROM : lock_row procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 04-JUL-05  hrodda   o Bug 4284035 - Replaced pn_index_lease_periods with
--                       _ALL table.Also changed the where clause
-- 09-NOV-2006 Prabhakar o Added index_multiplier to lock_row.
-------------------------------------------------------------------------------
PROCEDURE lock_row (
   x_rowid                       IN   VARCHAR2
   ,x_index_period_id             IN   NUMBER
   ,x_index_lease_id              IN   NUMBER
   ,x_line_number                 IN   NUMBER
   ,x_assessment_date             IN   DATE
   ,x_basis_start_date            IN   DATE
   ,x_basis_end_date              IN   DATE
   ,x_index_finder_date           IN   DATE
   ,x_current_index_line_id       IN   NUMBER
   ,x_current_index_line_value    IN   NUMBER
   ,x_previous_index_line_id      IN   NUMBER
   ,x_previous_index_line_value   IN   NUMBER
   ,x_current_basis               IN   NUMBER
   ,x_relationship                IN   VARCHAR2
   ,x_index_percent_change        IN   NUMBER
   ,x_basis_percent_change        IN   NUMBER
   ,x_unconstraint_rent_due       IN   NUMBER
   ,x_constraint_rent_due         IN   NUMBER
   ,x_attribute_category          IN   VARCHAR2
   ,x_attribute1                  IN   VARCHAR2
   ,x_attribute2                  IN   VARCHAR2
   ,x_attribute3                  IN   VARCHAR2
   ,x_attribute4                  IN   VARCHAR2
   ,x_attribute5                  IN   VARCHAR2
   ,x_attribute6                  IN   VARCHAR2
   ,x_attribute7                  IN   VARCHAR2
   ,x_attribute8                  IN   VARCHAR2
   ,x_attribute9                  IN   VARCHAR2
   ,x_attribute10                 IN   VARCHAR2
   ,x_attribute11                 IN   VARCHAR2
   ,x_attribute12                 IN   VARCHAR2
   ,x_attribute13                 IN   VARCHAR2
   ,x_attribute14                 IN   VARCHAR2
   ,x_attribute15                 IN   VARCHAR2
   ,x_index_multiplier            IN   NUMBER
   ,x_constraint_applied_amount   IN   NUMBER
   ,x_constraint_applied_percent  IN   NUMBER)
IS
   CURSOR c1 IS
      SELECT        *
      FROM pn_index_lease_periods_all
      WHERE index_period_id = x_index_period_id
      FOR UPDATE OF index_period_id NOWAIT;

   tlinfo   c1%ROWTYPE;
BEGIN

   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_PERIODS_PKG.lock_row (+)');
   OPEN c1;
      FETCH c1 INTO tlinfo;
      IF (c1%NOTFOUND)
      THEN
         CLOSE c1;
         RETURN;
      END IF;
   CLOSE c1;

   IF NOT (tlinfo.index_period_id = x_index_period_id) THEN
      pn_var_rent_pkg.lock_row_exception('INDEX_PERIOD_ID',tlinfo.index_period_id);
   END IF;

   IF NOT (tlinfo.index_lease_id = x_index_lease_id) THEN
      pn_var_rent_pkg.lock_row_exception('INDEX_LEASE_ID',tlinfo.index_lease_id);
   END IF;

   IF NOT (tlinfo.line_number = x_line_number) THEN
      pn_var_rent_pkg.lock_row_exception('LINE_NUMBER',tlinfo.line_number);
   END IF;

   IF NOT (tlinfo.assessment_date = x_assessment_date) THEN
      pn_var_rent_pkg.lock_row_exception('ASSESSMENT_DATE',tlinfo.assessment_date);
   END IF;

   IF NOT ((tlinfo.basis_start_date = x_basis_start_date)
        OR ((tlinfo.basis_start_date IS NULL) AND x_basis_start_date IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('BASIS_START_DATE',tlinfo.basis_start_date);
   END IF;

   IF NOT ((tlinfo.basis_end_date = x_basis_end_date)
        OR ((tlinfo.basis_end_date IS NULL) AND x_basis_end_date IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('BASIS_END_DATE',tlinfo.basis_end_date);
   END IF;

   IF NOT ((tlinfo.index_finder_date = x_index_finder_date)
        OR ((tlinfo.index_finder_date IS NULL) AND x_index_finder_date IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('INDEX_FINDER_DATE',tlinfo.index_finder_date);
   END IF;

   IF NOT ((tlinfo.current_index_line_id = x_current_index_line_id)
        OR ((tlinfo.current_index_line_id IS NULL) AND x_current_index_line_id IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('CURRENT_INDEX_LINE_ID',tlinfo.current_index_line_id);
   END IF;

   IF NOT ((tlinfo.current_index_line_value = x_current_index_line_value)
        OR ((tlinfo.current_index_line_value IS NULL) AND x_current_index_line_value IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('CURRENT_INDEX_LINE_VALUE',tlinfo.current_index_line_value);
   END IF;

   IF NOT ((tlinfo.previous_index_line_id = x_previous_index_line_id)
        OR ((tlinfo.previous_index_line_id IS NULL) AND x_previous_index_line_id IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('PREVIOUS_INDEX_LINE_ID',tlinfo.previous_index_line_id);
   END IF;

   IF NOT ((tlinfo.previous_index_line_value = x_previous_index_line_value)
        OR ((tlinfo.previous_index_line_value IS NULL) AND x_previous_index_line_value IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('PREVIOUS_INDEX_LINE_VALUE',tlinfo.previous_index_line_value);
   END IF;

   IF NOT ((tlinfo.current_basis = x_current_basis)
        OR ((tlinfo.current_basis IS NULL) AND x_current_basis IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('CURRENT_BASIS',tlinfo.current_basis);
   END IF;

   IF NOT ((tlinfo.relationship = x_relationship)
        OR ((tlinfo.relationship IS NULL) AND x_relationship IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('RELATIONSHIP',tlinfo.relationship);
   END IF;

   IF NOT ((tlinfo.index_percent_change = x_index_percent_change)
        OR ((tlinfo.index_percent_change IS NULL) AND x_index_percent_change IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('INDEX_PERCENT_CHANGE',tlinfo.index_percent_change);
   END IF;

   IF NOT ((tlinfo.basis_percent_change = x_basis_percent_change)
        OR ((tlinfo.basis_percent_change IS NULL) AND x_basis_percent_change IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('BASIS_PERCENT_CHANGE',tlinfo.basis_percent_change);
   END IF;

   IF NOT ((tlinfo.unconstraint_rent_due = x_unconstraint_rent_due)
        OR ((tlinfo.unconstraint_rent_due IS NULL) AND x_unconstraint_rent_due IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('UNCONSTRAINT_RENT_DUE',tlinfo.unconstraint_rent_due);
   END IF;

   IF NOT ((tlinfo.constraint_rent_due = x_constraint_rent_due)
        OR ((tlinfo.constraint_rent_due IS NULL) AND x_constraint_rent_due IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('CONSTRAINT_RENT_DUE',tlinfo.constraint_rent_due);
   END IF;

   IF NOT ((tlinfo.index_multiplier = x_index_multiplier)
        OR ((tlinfo.index_multiplier IS NULL) AND x_index_multiplier IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('CONSTRAINT_RENT_DUE',tlinfo.index_multiplier);
   END IF;

   IF NOT ((tlinfo.constraint_applied_amount = x_constraint_applied_amount)
        OR ((tlinfo.constraint_applied_amount IS NULL) AND x_constraint_applied_amount IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('CONSTRAINT_RENT_DUE',tlinfo.constraint_applied_amount);
   END IF;

   IF NOT ((tlinfo.constraint_applied_percent = x_constraint_applied_percent)
        OR ((tlinfo.constraint_applied_percent IS NULL) AND x_constraint_applied_percent IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('CONSTRAINT_RENT_DUE',tlinfo.constraint_applied_percent);
   END IF;

   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_PERIODS_PKG.lock_row (-)');
END lock_row;


-------------------------------------------------------------------------------
-- PROCDURE     : delete_row
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 04-JUL-05  hrodda   o Bug 4284035 - Replaced pn_index_lease_periods with
--                       _ALL table.
-------------------------------------------------------------------------------
PROCEDURE delete_row (x_rowid IN VARCHAR2)
IS
BEGIN
   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_PERIODS_PKG.delete_row (+)');
   DELETE FROM pn_index_lease_periods_all
   WHERE ROWID = x_rowid;

   IF (SQL%NOTFOUND)
   THEN
      RAISE NO_DATA_FOUND;
   END IF;

   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_PERIODS_PKG.delete_row (-)');
END delete_row;

-------------------------------------------------------------------------------
-- PROCDURE     : delete_row
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : deletes the row
-- NOTE         : overloaded this procedure to take PK as In parameter
-- HISTORY      :
-- 04-JUL-05  hrodda   o Bug 4284035 - Created
-------------------------------------------------------------------------------
PROCEDURE delete_row (x_index_period_id IN NUMBER)
IS
BEGIN
   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_PERIODS_PKG.delete_row (+)');
   DELETE FROM pn_index_lease_periods_all
   WHERE index_period_id = x_index_period_id;

   IF (SQL%NOTFOUND)
   THEN
      RAISE NO_DATA_FOUND;
   END IF;

   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASE_PERIODS_PKG.delete_row (-)');
END delete_row;



END pn_index_lease_periods_pkg;

/
