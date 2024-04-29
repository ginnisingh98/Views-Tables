--------------------------------------------------------
--  DDL for Package Body PN_INDEX_LEASES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_INDEX_LEASES_PKG" AS
-- $Header: PNTINLEB.pls 120.4 2007/01/02 07:46:02 pseeram ship $

/*============================================================================+
|                Copyright (c) 2001 Oracle Corporation
|                   Redwood Shores, California, USA
|                        All rights reserved.
| DESCRIPTION
|
|  These procedures consist are used a table handlers for the PN_INDEX_LEASES table.
|  They include:
|         INSERT_ROW - insert a row into PN_INDEX_LEASES.
|         DELETE_ROW - deletes a row from PN_INDEX_LEASES.
|         UPDATE_ROW - updates a row from PN_INDEX_LEASES.
|         LOCKS_ROW - will check if a row has been modified since being queried by form.
|
|
| HISTORY
| 10-APR-01  jbreyes   o Created
| 15-JUN-01  jbreyes   o Added new column BASE_INDEX_LINE_ID
| 21-JUN-01  jbreyes   o Added new column INDEX_FINDER_MONTHS
| 07-AUG-01  psidhu    o Added new columns AGGEGATION_FLAG and GROSS_FLAG
| 13-DEC-01  Mrinal    o Added dbdrv command.
| 15-JAN-02  Mrinal    o In dbdrv command changed phase=pls to phase=plb.
|                        Added checkfile.Ref. Bug# 2184724.
| 17-Jul-02  Psidhu    o Added currency_code as a parameter to insert_row,
|                        update_row and lock_row.
| 09-JUL-02  ftanudja  o added x_org_id param in insert_row for
|                        shared services enh.
| 23-JUL-02  ftanudja  o changed lock_row to comply with new standards
| 05-AUG-02  psidhu    o added x_carry_forward_flag parameter to insert_row,
|                        update_row and lock_row.
| 17-MAY-04  vmmehta   o added x_retain_initial_flag parameter to insert_row,
|                        update_row and lock_row.
| 05-Jul-05  hrodda    o overloaded delete_row proc to take PK as parameter
| 14-AUG-06  pikhar    o Added vr_nbp_flag to insert/update/lock
| 09-NOV-06  prabhakar o Added index_multiplier to insert/update/lock
+===========================================================================*/

-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 04-JUL-05  hrodda o Bug 4284035 - Replaced pn_index_leases with _ALL table.
-- 14-AUG-06  pikhar o Added vr_nbp_flag to insert
-- 09-NOV-06  prabhakar o Added index_multiplier to insert_row
-- 08-DEC-06  Prabhakar o Added proration_rule and proration_period_start_date.
-------------------------------------------------------------------------------
PROCEDURE insert_row (
   x_rowid                   IN OUT NOCOPY   VARCHAR2
   ,x_org_id                  IN              NUMBER
   ,x_index_lease_id          IN OUT NOCOPY   NUMBER
   ,x_lease_id                IN              NUMBER
   ,x_index_id                IN              NUMBER
   ,x_commencement_date       IN              DATE
   ,x_termination_date        IN              DATE
   ,x_index_lease_number      IN OUT NOCOPY   VARCHAR2
   ,x_last_update_date        IN              DATE
   ,x_last_updated_by         IN              NUMBER
   ,x_creation_date           IN              DATE
   ,x_created_by              IN              NUMBER
   ,x_location_id             IN              NUMBER
   ,x_term_template_id        IN              NUMBER
   ,x_abstracted_by           IN              NUMBER
   ,x_assessment_date         IN              DATE
   ,x_assessment_interval     IN              NUMBER
   ,x_spread_frequency        IN              VARCHAR2
   ,x_relationship_default    IN              VARCHAR2
   ,x_basis_percent_default   IN              NUMBER
   ,x_initial_basis           IN              NUMBER
   ,x_base_index              IN              NUMBER
   ,x_base_index_line_id      IN              NUMBER
   ,x_index_finder_method     IN              VARCHAR2
   ,x_index_finder_months     IN              NUMBER
   ,x_negative_rent_type      IN              VARCHAR2
   ,x_increase_on             IN              VARCHAR2
   ,x_basis_type              IN              VARCHAR2
   ,x_reference_period        IN              VARCHAR2
   ,x_base_year               IN              DATE
   ,x_leased_area             IN              NUMBER
   ,x_rounding_flag           IN              VARCHAR2
   ,x_aggregation_flag        IN              VARCHAR2
   ,x_gross_flag              IN              VARCHAR2
   ,x_last_update_login       IN              NUMBER
   ,x_attribute_category      IN              VARCHAR2
   ,x_attribute1              IN              VARCHAR2
   ,x_attribute2              IN              VARCHAR2
   ,x_attribute3              IN              VARCHAR2
   ,x_attribute4              IN              VARCHAR2
   ,x_attribute5              IN              VARCHAR2
   ,x_attribute6              IN              VARCHAR2
   ,x_attribute7              IN              VARCHAR2
   ,x_attribute8              IN              VARCHAR2
   ,x_attribute9              IN              VARCHAR2
   ,x_attribute10             IN              VARCHAR2
   ,x_attribute11             IN              VARCHAR2
   ,x_attribute12             IN              VARCHAR2
   ,x_attribute13             IN              VARCHAR2
   ,x_attribute14             IN              VARCHAR2
   ,x_attribute15             IN              VARCHAR2
   ,x_agreement_category      IN              VARCHAR2
   ,x_agreement_attribute1    IN              VARCHAR2
   ,x_agreement_attribute2    IN              VARCHAR2
   ,x_agreement_attribute3    IN              VARCHAR2
   ,x_agreement_attribute4    IN              VARCHAR2
   ,x_agreement_attribute5    IN              VARCHAR2
   ,x_agreement_attribute6    IN              VARCHAR2
   ,x_agreement_attribute7    IN              VARCHAR2
   ,x_agreement_attribute8    IN              VARCHAR2
   ,x_agreement_attribute9    IN              VARCHAR2
   ,x_agreement_attribute10   IN              VARCHAR2
   ,x_agreement_attribute11   IN              VARCHAR2
   ,x_agreement_attribute12   IN              VARCHAR2
   ,x_agreement_attribute13   IN              VARCHAR2
   ,x_agreement_attribute14   IN              VARCHAR2
   ,x_agreement_attribute15   IN              VARCHAR2
   ,x_currency_code           IN              VARCHAR2
   ,x_carry_forward_flag      IN              VARCHAR2
   ,x_retain_initial_basis_flag  IN           VARCHAR2
   ,x_vr_nbp_flag             IN              VARCHAR2
   ,x_index_multiplier        IN              NUMBER
   ,x_proration_rule          IN              VARCHAR2
   ,x_proration_period_start_date IN          DATE)
IS
   CURSOR c IS
      SELECT ROWID
      FROM pn_index_leases_all
      WHERE index_lease_id = x_index_lease_id;

   l_return_status   VARCHAR2 (30) := NULL;
   l_rowid           VARCHAR2 (18) := NULL;

   CURSOR org_cur IS
     SELECT org_id FROM pn_leases_all WHERE lease_id = x_lease_id;
   l_org_ID NUMBER;

BEGIN

   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASES_PKG.insert_row (+)');

   /* If no INDEX_LEASE_ID is provided, get one from sequence */

   IF (x_index_lease_id IS NULL)
   THEN
      SELECT pn_index_leases_s.NEXTVAL
      INTO x_index_lease_id
      FROM DUAL;
   END IF;


   /* If no index lease number  is provided, use system generated index lease id */

   IF (x_index_lease_number IS NULL)
   THEN
      x_index_lease_number := x_index_lease_id;
   END IF;

   pn_index_leases_pkg.check_unq_index_lease_number (
      l_return_status
     ,x_index_lease_id
     ,x_index_lease_number);

   IF (l_return_status IS NOT NULL)
   THEN
      app_exception.raise_exception;
   END IF;

   IF x_org_id IS NULL THEN
     FOR rec IN org_cur LOOP
        l_org_id := rec.org_id;
     END LOOP;
   ELSE
     l_org_id := x_org_id;
   END IF;

   INSERT INTO pn_index_leases_all
   (
      index_lease_id
      ,org_id
      ,lease_id
      ,index_id
      ,commencement_date
      ,termination_date
      ,index_lease_number
      ,last_update_date
      ,last_updated_by
      ,creation_date
      ,created_by
      ,location_id
      ,term_template_id
      ,abstracted_by
      ,assessment_date
      ,assessment_interval
      ,spread_frequency
      ,relationship_default
      ,basis_percent_default
      ,initial_basis
      ,base_index
      ,base_index_line_id
      ,index_finder_method
      ,index_finder_months
      ,negative_rent_type
      ,increase_on
      ,basis_type
      ,reference_period
      ,base_year
      ,leased_area
      ,rounding_flag
      ,aggregation_flag
      ,gross_flag
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
      ,agreement_category
      ,agreement_attribute1
      ,agreement_attribute2
      ,agreement_attribute3
      ,agreement_attribute4
      ,agreement_attribute5
      ,agreement_attribute6
      ,agreement_attribute7
      ,agreement_attribute8
      ,agreement_attribute9
      ,agreement_attribute10
      ,agreement_attribute11
      ,agreement_attribute12
      ,agreement_attribute13
      ,agreement_attribute14
      ,agreement_attribute15
      ,currency_code
      ,carry_forward_flag
      ,retain_initial_basis_flag
      ,vr_nbp_flag
      ,index_multiplier
      ,proration_rule
      ,proration_period_start_date )
   VALUES
   (
       x_index_lease_id
      ,l_org_ID
      ,x_lease_id
      ,x_index_id
      ,x_commencement_date
      ,x_termination_date
      ,x_index_lease_number
      ,x_last_update_date
      ,x_last_updated_by
      ,x_creation_date
      ,x_created_by
      ,x_location_id
      ,x_term_template_id
      ,x_abstracted_by
      ,x_assessment_date
      ,x_assessment_interval
      ,x_spread_frequency
      ,x_relationship_default
      ,x_basis_percent_default
      ,x_initial_basis
      ,x_base_index
      ,x_base_index_line_id
      ,x_index_finder_method
      ,x_index_finder_months
      ,x_negative_rent_type
      ,x_increase_on
      ,x_basis_type
      ,x_reference_period
      ,x_base_year
      ,x_leased_area
      ,x_rounding_flag
      ,x_aggregation_flag
      ,x_gross_flag
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
      ,x_agreement_category
      ,x_agreement_attribute1
      ,x_agreement_attribute2
      ,x_agreement_attribute3
      ,x_agreement_attribute4
      ,x_agreement_attribute5
      ,x_agreement_attribute6
      ,x_agreement_attribute7
      ,x_agreement_attribute8
      ,x_agreement_attribute9
      ,x_agreement_attribute10
      ,x_agreement_attribute11
      ,x_agreement_attribute12
      ,x_agreement_attribute13
      ,x_agreement_attribute14
      ,x_agreement_attribute15
      ,x_currency_code
      ,x_carry_forward_flag
      ,x_retain_initial_basis_flag
      ,x_vr_nbp_flag
      ,x_index_multiplier
      ,x_proration_rule
      ,x_proration_period_start_date );


   -- Check if a valid record was created.
   OPEN c;
      FETCH c INTO x_rowid;
      IF (c%NOTFOUND)
      THEN
         CLOSE c;
         RAISE NO_DATA_FOUND;
      END IF;
   CLOSE c;

END insert_row;


-------------------------------------------------------------------------------
-- PROCDURE     : update_row
-- INVOKED FROM : update_row procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 04-JUL-05  hrodda o Bug 4284035 - Replaced pn_index_leases with _ALL table
--                     and changed the where clause.
-- 14-AUG-06  pikhar o Added vr_nbp_flag to update
-- 09-NOV-06  prabhakar o Added index_multiplier to update_row.
-- 08-NOV-06  Prabhakar o Added proration_rule and pn_proration_period_start_date.
-------------------------------------------------------------------------------
PROCEDURE update_row (
    x_rowid                   IN   VARCHAR2
   ,x_index_lease_id          IN   NUMBER
   ,x_lease_id                IN   NUMBER
   ,x_index_id                IN   NUMBER
   ,x_commencement_date       IN   DATE
   ,x_termination_date        IN   DATE
   ,x_index_lease_number      IN   VARCHAR2
   ,x_last_update_date        IN   DATE
   ,x_last_updated_by         IN   NUMBER
   ,x_location_id             IN   NUMBER
   ,x_term_template_id        IN   NUMBER
   ,x_abstracted_by           IN   NUMBER
   ,x_assessment_date         IN   DATE
   ,x_assessment_interval     IN   NUMBER
   ,x_spread_frequency        IN   VARCHAR2
   ,x_relationship_default    IN   VARCHAR2
   ,x_basis_percent_default   IN   NUMBER
   ,x_initial_basis           IN   NUMBER
   ,x_base_index              IN   NUMBER
   ,x_base_index_line_id      IN   NUMBER
   ,x_index_finder_method     IN   VARCHAR2
   ,x_index_finder_months     IN   NUMBER
   ,x_negative_rent_type      IN   VARCHAR2
   ,x_increase_on             IN   VARCHAR2
   ,x_basis_type              IN   VARCHAR2
   ,x_reference_period        IN   VARCHAR2
   ,x_base_year               IN   DATE
   ,x_leased_area             IN   NUMBER
   ,x_rounding_flag           IN   VARCHAR2
   ,x_aggregation_flag        IN   VARCHAR2
   ,x_gross_flag              IN   VARCHAR2
   ,x_last_update_login       IN   NUMBER
   ,x_attribute_category      IN   VARCHAR2
   ,x_attribute1              IN   VARCHAR2
   ,x_attribute2              IN   VARCHAR2
   ,x_attribute3              IN   VARCHAR2
   ,x_attribute4              IN   VARCHAR2
   ,x_attribute5              IN   VARCHAR2
   ,x_attribute6              IN   VARCHAR2
   ,x_attribute7              IN   VARCHAR2
   ,x_attribute8              IN   VARCHAR2
   ,x_attribute9              IN   VARCHAR2
   ,x_attribute10             IN   VARCHAR2
   ,x_attribute11             IN   VARCHAR2
   ,x_attribute12             IN   VARCHAR2
   ,x_attribute13             IN   VARCHAR2
   ,x_attribute14             IN   VARCHAR2
   ,x_attribute15             IN   VARCHAR2
   ,x_agreement_category      IN   VARCHAR2
   ,x_agreement_attribute1    IN   VARCHAR2
   ,x_agreement_attribute2    IN   VARCHAR2
   ,x_agreement_attribute3    IN   VARCHAR2
   ,x_agreement_attribute4    IN   VARCHAR2
   ,x_agreement_attribute5    IN   VARCHAR2
   ,x_agreement_attribute6    IN   VARCHAR2
   ,x_agreement_attribute7    IN   VARCHAR2
   ,x_agreement_attribute8    IN   VARCHAR2
   ,x_agreement_attribute9    IN   VARCHAR2
   ,x_agreement_attribute10   IN   VARCHAR2
   ,x_agreement_attribute11   IN   VARCHAR2
   ,x_agreement_attribute12   IN   VARCHAR2
   ,x_agreement_attribute13   IN   VARCHAR2
   ,x_agreement_attribute14   IN   VARCHAR2
   ,x_agreement_attribute15   IN   VARCHAR2
   ,x_currency_code           IN   VARCHAR2
   ,x_carry_forward_flag      IN   VARCHAR2
   ,x_retain_initial_basis_flag  IN    VARCHAR2
   ,x_vr_nbp_flag             IN VARCHAR2
   ,x_index_multiplier        IN   NUMBER
   ,x_proration_rule          IN       VARCHAR2
   ,x_proration_period_start_date IN   DATE)
IS
   l_return_status   VARCHAR2 (30) := NULL;
BEGIN
   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASES_PKG.update_row (+)');
   pn_index_leases_pkg.check_unq_index_lease_number (
   l_return_status
   ,x_index_lease_id
   ,x_index_lease_number);

   IF (l_return_status IS NOT NULL)
   THEN
   app_exception.raise_exception;
   END IF;


   UPDATE pn_index_leases_all
   SET lease_id                  = x_lease_id
      ,index_id                  = x_index_id
      ,commencement_date         = x_commencement_date
      ,termination_date          = x_termination_date
      ,index_lease_number        = x_index_lease_number
      ,last_update_date          = x_last_update_date
      ,last_updated_by           = x_last_updated_by
      ,location_id               = x_location_id
      ,term_template_id          = x_term_template_id
      ,abstracted_by             = x_abstracted_by
      ,assessment_date           = x_assessment_date
      ,assessment_interval       = x_assessment_interval
      ,spread_frequency          = x_spread_frequency
      ,relationship_default      = x_relationship_default
      ,basis_percent_default     = x_basis_percent_default
      ,initial_basis             = x_initial_basis
      ,base_index                = x_base_index
      ,base_index_line_id        = x_base_index_line_id
      ,index_finder_method       = x_index_finder_method
      ,index_finder_months       = x_index_finder_months
      ,negative_rent_type        = x_negative_rent_type
      ,increase_on               = x_increase_on
      ,basis_type                = x_basis_type
      ,reference_period          = x_reference_period
      ,base_year                 = x_base_year
      ,leased_area               = x_leased_area
      ,rounding_flag             = x_rounding_flag
      ,aggregation_flag          = x_aggregation_flag
      ,gross_flag                = x_gross_flag
      ,last_update_login         = x_last_update_login
      ,attribute_category        = x_attribute_category
      ,attribute1                = x_attribute1
      ,attribute2                = x_attribute2
      ,attribute3                = x_attribute3
      ,attribute4                = x_attribute4
      ,attribute5                = x_attribute5
      ,attribute6                = x_attribute6
      ,attribute7                = x_attribute7
      ,attribute8                = x_attribute8
      ,attribute9                = x_attribute9
      ,attribute10               = x_attribute10
      ,attribute11               = x_attribute11
      ,attribute12               = x_attribute12
      ,attribute13               = x_attribute13
      ,attribute14               = x_attribute14
      ,attribute15               = x_attribute15
      ,agreement_category        = x_agreement_category
      ,agreement_attribute1      = x_agreement_attribute1
      ,agreement_attribute2      = x_agreement_attribute2
      ,agreement_attribute3      = x_agreement_attribute3
      ,agreement_attribute4      = x_agreement_attribute4
      ,agreement_attribute5      = x_agreement_attribute5
      ,agreement_attribute6      = x_agreement_attribute6
      ,agreement_attribute7      = x_agreement_attribute7
      ,agreement_attribute8      = x_agreement_attribute8
      ,agreement_attribute9      = x_agreement_attribute9
      ,agreement_attribute10     = x_agreement_attribute10
      ,agreement_attribute11     = x_agreement_attribute11
      ,agreement_attribute12     = x_agreement_attribute12
      ,agreement_attribute13     = x_agreement_attribute13
      ,agreement_attribute14     = x_agreement_attribute14
      ,agreement_attribute15     = x_agreement_attribute15
      ,currency_code             = x_currency_code
      ,carry_forward_flag        = x_carry_forward_flag
      ,retain_initial_basis_flag = x_retain_initial_basis_flag
      ,vr_nbp_flag               = x_vr_nbp_flag
      ,index_multiplier          = x_index_multiplier
      ,proration_rule            = x_proration_rule
      ,proration_period_start_date = x_proration_period_start_date
   WHERE index_lease_id = x_index_lease_id;

   IF (SQL%NOTFOUND)
   THEN
   RAISE NO_DATA_FOUND;
   END IF;

   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASES_PKG.update_row (-)');
END update_row;


-------------------------------------------------------------------------------
-- PROCDURE     : lock_row
-- INVOKED FROM : lock_row procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 04-JUL-05  hrodda o Bug 4284035 - Replaced pn_index_leases with _ALL table
--                     and changed the where clause.
-- 14-AUG-06  pikhar o Added vr_nbp_flag to lock
-- 09-NOV-06  prabhakar o Added index_multiplier to lock_row.
-- 08-NOV-06  Prabhakar o Added proration_rule and pn_proration_period_start_date.
-------------------------------------------------------------------------------
PROCEDURE lock_row (
   x_rowid                   IN   VARCHAR2
  ,x_index_lease_id          IN   NUMBER
  ,x_lease_id                IN   NUMBER
  ,x_index_id                IN   NUMBER
  ,x_commencement_date       IN   DATE
  ,x_termination_date        IN   DATE
  ,x_index_lease_number      IN   VARCHAR2
  ,x_location_id             IN   NUMBER
  ,x_term_template_id        IN   NUMBER
  ,x_abstracted_by           IN   NUMBER
  ,x_assessment_date         IN   DATE
  ,x_assessment_interval     IN   NUMBER
  ,x_spread_frequency        IN   VARCHAR2
  ,x_relationship_default    IN   VARCHAR2
  ,x_basis_percent_default   IN   NUMBER
  ,x_initial_basis           IN   NUMBER
  ,x_base_index              IN   NUMBER
  ,x_base_index_line_id      IN   NUMBER
  ,x_index_finder_method     IN   VARCHAR2
  ,x_index_finder_months     IN   NUMBER
  ,x_negative_rent_type      IN   VARCHAR2
  ,x_increase_on             IN   VARCHAR2
  ,x_basis_type              IN   VARCHAR2
  ,x_reference_period        IN   VARCHAR2
  ,x_base_year               IN   DATE
  ,x_leased_area             IN   NUMBER
  ,x_rounding_flag           IN   VARCHAR2
  ,x_aggregation_flag        IN   VARCHAR2
  ,x_gross_flag              IN   VARCHAR2
  ,x_attribute_category      IN   VARCHAR2
  ,x_attribute1              IN   VARCHAR2
  ,x_attribute2              IN   VARCHAR2
  ,x_attribute3              IN   VARCHAR2
  ,x_attribute4              IN   VARCHAR2
  ,x_attribute5              IN   VARCHAR2
  ,x_attribute6              IN   VARCHAR2
  ,x_attribute7              IN   VARCHAR2
  ,x_attribute8              IN   VARCHAR2
  ,x_attribute9              IN   VARCHAR2
  ,x_attribute10             IN   VARCHAR2
  ,x_attribute11             IN   VARCHAR2
  ,x_attribute12             IN   VARCHAR2
  ,x_attribute13             IN   VARCHAR2
  ,x_attribute14             IN   VARCHAR2
  ,x_attribute15             IN   VARCHAR2
  ,x_agreement_category      IN   VARCHAR2
  ,x_agreement_attribute1    IN   VARCHAR2
  ,x_agreement_attribute2    IN   VARCHAR2
  ,x_agreement_attribute3    IN   VARCHAR2
  ,x_agreement_attribute4    IN   VARCHAR2
  ,x_agreement_attribute5    IN   VARCHAR2
  ,x_agreement_attribute6    IN   VARCHAR2
  ,x_agreement_attribute7    IN   VARCHAR2
  ,x_agreement_attribute8    IN   VARCHAR2
  ,x_agreement_attribute9    IN   VARCHAR2
  ,x_agreement_attribute10   IN   VARCHAR2
  ,x_agreement_attribute11   IN   VARCHAR2
  ,x_agreement_attribute12   IN   VARCHAR2
  ,x_agreement_attribute13   IN   VARCHAR2
  ,x_agreement_attribute14   IN   VARCHAR2
  ,x_agreement_attribute15   IN   VARCHAR2
  ,x_currency_code           IN   VARCHAR2
  ,x_carry_forward_flag      IN   VARCHAR2
  ,x_retain_initial_basis_flag  IN    VARCHAR2
  ,x_vr_nbp_flag             IN VARCHAR2
  ,x_index_multiplier        IN   NUMBER
  ,x_proration_rule          IN       VARCHAR2
  ,x_proration_period_start_date IN   DATE)
IS

   CURSOR c1 IS
      SELECT        *
      FROM pn_index_leases_all
      WHERE INDEX_LEASE_ID = x_index_lease_id
      FOR UPDATE OF index_lease_id NOWAIT;

   tlinfo   c1%ROWTYPE;
BEGIN

   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASES_PKG.lock_row (+)');
   OPEN c1;
      FETCH c1 INTO tlinfo;
      IF (c1%NOTFOUND)
      THEN
         CLOSE c1;
         RETURN;
      END IF;
   CLOSE c1;

   IF NOT (tlinfo.index_lease_id = x_index_lease_id) THEN
      pn_var_rent_pkg.lock_row_exception('INDEX_LEASE_ID',tlinfo.index_lease_id);
   END IF;

   IF NOT (tlinfo.lease_id = x_lease_id) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_ID',tlinfo.lease_id);
   END IF;

   IF NOT (tlinfo.index_id = x_index_id) THEN
      pn_var_rent_pkg.lock_row_exception('INDEX_ID',tlinfo.index_id);
   END IF;

   IF NOT (tlinfo.commencement_date = x_commencement_date) THEN
      pn_var_rent_pkg.lock_row_exception('COMMENCEMENT_DATE',tlinfo.commencement_date);
   END IF;

   IF NOT (tlinfo.termination_date = x_termination_date) THEN
      pn_var_rent_pkg.lock_row_exception('tERMINATION_DATE',tlinfo.termination_date);
   END IF;

   IF NOT (tlinfo.index_lease_number = x_index_lease_number) THEN
      pn_var_rent_pkg.lock_row_exception('inDEX_LEASE_NUMBER',tlinfo.index_lease_number);
   END IF;

   IF NOT ((tlinfo.location_id = x_location_id)
       OR ((tlinfo.location_id IS NULL) AND x_location_id IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('loCATION_ID',tlinfo.location_id);
   END IF;

   IF NOT ((tlinfo.term_template_id = x_term_template_id)
        OR ((tlinfo.term_template_id IS NULL) AND x_term_template_id IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('TERM_TEMPLATE_ID',tlinfo.term_template_id);
   END IF;

   IF NOT ((tlinfo.abstracted_by = x_abstracted_by)
        OR ((tlinfo.abstracted_by IS NULL) AND x_abstracted_by IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('ABSTRACTED_BY',tlinfo.abstracted_by);
   END IF;

   IF NOT ((tlinfo.assessment_date = x_assessment_date)
        OR ((tlinfo.assessment_date IS NULL) AND x_assessment_date IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('ASSESSMENT_DATE',tlinfo.assessment_date);
   END IF;

   IF NOT ((tlinfo.assessment_interval = x_assessment_interval)
        OR ((tlinfo.assessment_interval IS NULL) AND x_assessment_interval IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('ASSESSMENT_INTERVAL',tlinfo.assessment_interval);
   END IF;

   IF NOT ((tlinfo.spread_frequency = x_spread_frequency)
        OR ((tlinfo.spread_frequency IS NULL) AND x_spread_frequency IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('SPREAD_FREQUENCY',tlinfo.spread_frequency);
   END IF;

   IF NOT ((tlinfo.relationship_default = x_relationship_default)
        OR ((tlinfo.relationship_default IS NULL) AND x_relationship_default IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('RELATIONSHIP_DEFAULT',tlinfo.relationship_default);
   END IF;

   IF NOT ((tlinfo.basis_percent_default = x_basis_percent_default)
        OR ((tlinfo.basis_percent_default IS NULL) AND x_basis_percent_default IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('BASIS_PERCENT_DEFAULT',tlinfo.basis_percent_default);
   END IF;

   IF NOT ((tlinfo.initial_basis = x_initial_basis)
        OR ((tlinfo.initial_basis IS NULL) AND x_initial_basis IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('INITIAL_BASIS',tlinfo.initial_basis);
   END IF;

   IF NOT ((tlinfo.base_index = x_base_index)
        OR ((tlinfo.base_index IS NULL) AND x_base_index IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('BASE_INDEX',tlinfo.base_index);
   END IF;

   IF NOT ((tlinfo.base_index_line_id = x_base_index_line_id)
        OR ((tlinfo.base_index_line_id IS NULL) AND x_base_index_line_id IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('BASE_INDEX_LINE_ID',tlinfo.base_index_line_id);
   END IF;

   IF NOT ((tlinfo.index_finder_method = x_index_finder_method)
        OR ((tlinfo.index_finder_method IS NULL) AND x_index_finder_method IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('INDEX_FINDER_METHOD',tlinfo.index_finder_method);
   END IF;

   IF NOT ((tlinfo.index_finder_months = x_index_finder_months)
        OR ((tlinfo.index_finder_months IS NULL) AND x_index_finder_months IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('INDEX_FINDER_MONTHS',tlinfo.index_finder_months);
   END IF;

   IF NOT ((tlinfo.negative_rent_type = x_negative_rent_type)
        OR ((tlinfo.negative_rent_type IS NULL) AND x_negative_rent_type IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('NEGATIVE_RENT_TYPE',tlinfo.negative_rent_type);
   END IF;

   IF NOT ((tlinfo.increase_on = x_increase_on)
        OR ((tlinfo.increase_on IS NULL) AND x_increase_on IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('INCREASE_ON',tlinfo.increase_on);
   END IF;

   IF NOT ((tlinfo.basis_type = x_basis_type)
        OR ((tlinfo.basis_type IS NULL) AND x_basis_type IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('BASIS_TYPE',tlinfo.basis_type);
   END IF;

   IF NOT ((tlinfo.reference_period = x_reference_period)
        OR ((tlinfo.reference_period IS NULL) AND x_reference_period IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('REFERENCE_PERIOD',tlinfo.reference_period);
   END IF;

   IF NOT ((tlinfo.base_year = x_base_year)
        OR ((tlinfo.base_year IS NULL) AND x_base_year IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('BASE_YEAR',tlinfo.base_year);
   END IF;

   IF NOT ((tlinfo.leased_area = x_leased_area)
        OR ((tlinfo.leased_area IS NULL) AND x_leased_area IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('LEASED_AREA',tlinfo.leased_area);
   END IF;

   IF NOT ((tlinfo.rounding_flag = x_rounding_flag)
        OR ((tlinfo.rounding_flag IS NULL) AND x_rounding_flag IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('ROUNDING_FLAG',tlinfo.rounding_flag);
   END IF;

   IF NOT ((tlinfo.aggregation_flag = x_aggregation_flag)
        OR ((tlinfo.aggregation_flag IS NULL) AND x_aggregation_flag IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('AGGREGATION_FLAG',tlinfo.aggregation_flag);
   END IF;

   IF NOT ((tlinfo.gross_flag = x_gross_flag)
        OR ((tlinfo.gross_flag IS NULL) AND x_gross_flag IS NULL)) THEN
      pn_var_rent_pkg.lock_row_exception('GROSS_FLAG',tlinfo.gross_flag);
   END IF;

   IF NOT ((tlinfo.AGREEMENT_CATEGORY = X_AGREEMENT_CATEGORY)
        OR ((tlinfo.AGREEMENT_CATEGORY IS NULL) AND (X_AGREEMENT_CATEGORY IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('AGREEMENT_CATEGORY',tlinfo.AGREEMENT_CATEGORY);
   END IF;

   IF NOT ((tlinfo.AGREEMENT_ATTRIBUTE1 = X_AGREEMENT_ATTRIBUTE1)
        OR ((tlinfo.AGREEMENT_ATTRIBUTE1 IS NULL) AND (X_AGREEMENT_ATTRIBUTE1 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('AGREEMENT_ATTRIBUTE1',tlinfo.AGREEMENT_ATTRIBUTE1);
   END IF;

   IF NOT ((tlinfo.AGREEMENT_ATTRIBUTE2 = X_AGREEMENT_ATTRIBUTE2)
        OR ((tlinfo.AGREEMENT_ATTRIBUTE2 IS NULL) AND (X_AGREEMENT_ATTRIBUTE2 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('AGREEMENT_ATTRIBUTE2',tlinfo.AGREEMENT_ATTRIBUTE2);
   END IF;

   IF NOT ((tlinfo.AGREEMENT_ATTRIBUTE3 = X_AGREEMENT_ATTRIBUTE3)
        OR ((tlinfo.AGREEMENT_ATTRIBUTE3 IS NULL) AND (X_AGREEMENT_ATTRIBUTE3 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('AGREEMENT_ATTRIBUTE3',tlinfo.AGREEMENT_ATTRIBUTE3);
   END IF;

   IF NOT ((tlinfo.AGREEMENT_ATTRIBUTE4 = X_AGREEMENT_ATTRIBUTE4)
        OR ((tlinfo.AGREEMENT_ATTRIBUTE4 IS NULL) AND (X_AGREEMENT_ATTRIBUTE4 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('AGREEMENT_ATTRIBUTE4',tlinfo.AGREEMENT_ATTRIBUTE4);
   END IF;

   IF NOT ((tlinfo.AGREEMENT_ATTRIBUTE5 = X_AGREEMENT_ATTRIBUTE5)
        OR ((tlinfo.AGREEMENT_ATTRIBUTE5 IS NULL) AND (X_AGREEMENT_ATTRIBUTE5 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('AGREEMENT_ATTRIBUTE5',tlinfo.AGREEMENT_ATTRIBUTE5);
   END IF;

   IF NOT ((tlinfo.AGREEMENT_ATTRIBUTE6 = X_AGREEMENT_ATTRIBUTE6)
        OR ((tlinfo.AGREEMENT_ATTRIBUTE6 IS NULL) AND (X_AGREEMENT_ATTRIBUTE6 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('AGREEMENT_ATTRIBUTE6',tlinfo.AGREEMENT_ATTRIBUTE6);
   END IF;

   IF NOT ((tlinfo.AGREEMENT_ATTRIBUTE7 = X_AGREEMENT_ATTRIBUTE7)
        OR ((tlinfo.AGREEMENT_ATTRIBUTE7 IS NULL) AND (X_AGREEMENT_ATTRIBUTE7 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('AGREEMENT_ATTRIBUTE7',tlinfo.AGREEMENT_ATTRIBUTE7);
   END IF;

   IF NOT ((tlinfo.AGREEMENT_ATTRIBUTE8 = X_AGREEMENT_ATTRIBUTE8)
        OR ((tlinfo.AGREEMENT_ATTRIBUTE8 IS NULL) AND (X_AGREEMENT_ATTRIBUTE8 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('AGREEMENT_ATTRIBUTE8',tlinfo.AGREEMENT_ATTRIBUTE8);
   END IF;

   IF NOT ((tlinfo.AGREEMENT_ATTRIBUTE9 = X_AGREEMENT_ATTRIBUTE9)
        OR ((tlinfo.AGREEMENT_ATTRIBUTE9 IS NULL) AND (X_AGREEMENT_ATTRIBUTE9 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('AGREEMENT_ATTRIBUTE9',tlinfo.AGREEMENT_ATTRIBUTE9);
   END IF;

   IF NOT ((tlinfo.AGREEMENT_ATTRIBUTE10 = X_AGREEMENT_ATTRIBUTE10)
        OR ((tlinfo.AGREEMENT_ATTRIBUTE10 IS NULL) AND (X_AGREEMENT_ATTRIBUTE10 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('AGREEMENT_ATTRIBUTE10',tlinfo.AGREEMENT_ATTRIBUTE10);
   END IF;

   IF NOT ((tlinfo.AGREEMENT_ATTRIBUTE11 = X_AGREEMENT_ATTRIBUTE11)
        OR ((tlinfo.AGREEMENT_ATTRIBUTE11 IS NULL) AND (X_AGREEMENT_ATTRIBUTE11 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('AGREEMENT_ATTRIBUTE11',tlinfo.AGREEMENT_ATTRIBUTE11);
   END IF;

   IF NOT ((tlinfo.AGREEMENT_ATTRIBUTE12 = X_AGREEMENT_ATTRIBUTE12)
        OR ((tlinfo.AGREEMENT_ATTRIBUTE12 IS NULL) AND (X_AGREEMENT_ATTRIBUTE12 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('AGREEMENT_ATTRIBUTE12',tlinfo.AGREEMENT_ATTRIBUTE12);
   END IF;

   IF NOT ((tlinfo.AGREEMENT_ATTRIBUTE13 = X_AGREEMENT_ATTRIBUTE13)
        OR ((tlinfo.AGREEMENT_ATTRIBUTE13 IS NULL) AND (X_AGREEMENT_ATTRIBUTE13 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('AGREEMENT_ATTRIBUTE13',tlinfo.AGREEMENT_ATTRIBUTE13);
   END IF;

   IF NOT ((tlinfo.AGREEMENT_ATTRIBUTE14 = X_AGREEMENT_ATTRIBUTE14)
        OR ((tlinfo.AGREEMENT_ATTRIBUTE14 IS NULL) AND (X_AGREEMENT_ATTRIBUTE14 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('AGREEMENT_ATTRIBUTE14',tlinfo.AGREEMENT_ATTRIBUTE14);
   END IF;

   IF NOT ((tlinfo.AGREEMENT_ATTRIBUTE15 = X_AGREEMENT_ATTRIBUTE15)
        OR ((tlinfo.AGREEMENT_ATTRIBUTE15 IS NULL) AND (X_AGREEMENT_ATTRIBUTE15 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('AGREEMENT_ATTRIBUTE15',tlinfo.AGREEMENT_ATTRIBUTE15);
   END IF;

   IF NOT ((tlinfo.CURRENCY_CODE = X_CURRENCY_CODE)
        OR ((tlinfo.CURRENCY_CODE IS NULL) AND (X_CURRENCY_CODE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('CURRENCY_CODE',tlinfo.CURRENCY_CODE);
   END IF;

   IF NOT ((tlinfo.CARRY_FORWARD_FLAG = X_CARRY_FORWARD_FLAG)
        OR ((tlinfo.CARRY_FORWARD_FLAG IS NULL) AND (X_CARRY_FORWARD_FLAG IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('CARRY_FORWARD_FLAG',tlinfo.CARRY_FORWARD_FLAG);
   END IF;

   IF NOT ((tlinfo.RETAIN_INITIAL_BASIS_FLAG = X_RETAIN_INITIAL_BASIS_FLAG)
        OR ((tlinfo.RETAIN_INITIAL_BASIS_FLAG IS NULL) AND (X_RETAIN_INITIAL_BASIS_FLAG IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('RETAIN_INITIAL_BASIS_FLAG',tlinfo.RETAIN_INITIAL_BASIS_FLAG);
   END IF;

   IF NOT ((tlinfo.VR_NBP_FLAG = X_VR_NBP_FLAG)
        OR ((tlinfo.VR_NBP_FLAG IS NULL) AND (X_VR_NBP_FLAG IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('VR_NBP_FLAG',tlinfo.VR_NBP_FLAG);
   END IF;

   IF NOT ((tlinfo.INDEX_MULTIPLIER = X_INDEX_MULTIPLIER)
        OR ((tlinfo.INDEX_MULTIPLIER IS NULL) AND (X_INDEX_MULTIPLIER IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('VR_NBP_FLAG',tlinfo.INDEX_MULTIPLIER);
   END IF;

   IF NOT ((tlinfo.PRORATION_RULE = X_PRORATION_RULE)
        OR ((tlinfo.PRORATION_RULE IS NULL) AND (X_PRORATION_RULE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('VR_NBP_FLAG',tlinfo.PRORATION_RULE);
   END IF;

   IF NOT ((tlinfo.PRORATION_PERIOD_START_DATE = X_PRORATION_PERIOD_START_DATE)
        OR ((tlinfo.PRORATION_PERIOD_START_DATE IS NULL) AND (X_PRORATION_PERIOD_START_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('VR_NBP_FLAG',tlinfo.PRORATION_PERIOD_START_DATE);
   END IF;

   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASES_PKG.lock_row (-)');

END lock_row;


-------------------------------------------------------------------------------
-- PROCDURE     : delete_row
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 04-JUL-05  hrodda o Bug 4284035 - Replaced pn_index_leases with _ALL table
--                     and changed the where clause.
-------------------------------------------------------------------------------
PROCEDURE delete_row (
   x_rowid   IN   VARCHAR2)
IS
BEGIN
   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASES_PKG.delete_row (+)');
   DELETE FROM pn_index_leases_all
   WHERE ROWID = x_rowid;

   IF (SQL%NOTFOUND)
   THEN
      RAISE NO_DATA_FOUND;
   END IF;
   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASES_PKG.delete_row (-)');
END delete_row;

-------------------------------------------------------------------------------
-- PROCDURE     : delete_row
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : deletes the row
-- NOTE         : overload delete_row to take PK as IN paramter instead of ROWID
-- HISTORY      :
-- 04-JUL-05  hrodda o Bug 4284035 - Created
-------------------------------------------------------------------------------
PROCEDURE delete_row (
x_index_lease_id   IN   NUMBER) IS
BEGIN
   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASES_PKG.delete_row (+)');
   DELETE FROM pn_index_leases_all
   WHERE index_lease_id = x_index_lease_id;

   IF (SQL%NOTFOUND)
   THEN
      RAISE NO_DATA_FOUND;
   END IF;

   PNP_DEBUG_PKG.debug (' PN_INDEX_LEASES_PKG.delete_row (-)');
END delete_row;



-------------------------------------------------------------------------------
-- PROCDURE     : check_unq_index_lease_number
-- INVOKED FROM : update_row and insert_row procedure
-- PURPOSE      : checks unique index number
-- HISTORY      :
-- 04-JUL-05  hrodda o Bug 4284035 - Replace pn_index_leases with _ALL tables
-------------------------------------------------------------------------------
PROCEDURE check_unq_index_lease_number (
    x_return_status        IN OUT NOCOPY  VARCHAR2
   ,x_index_lease_id       IN             NUMBER
   ,x_index_lease_number   IN             VARCHAR2)
IS
   l_dummy   NUMBER;
BEGIN
   SELECT 1
   INTO l_dummy
   FROM DUAL
   WHERE NOT EXISTS ( SELECT 1
                      FROM pn_index_leases_all
                      WHERE (index_lease_number = x_index_lease_number)
                      AND (   (x_index_lease_id IS NULL)
                      OR (index_lease_id <> x_index_lease_id)));
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
      fnd_message.set_name ('PN', 'PN_DUP_INDEX_LEASE_NUMBER');

      --fnd_message.set_token('INDEX_LEASE_NUMBER', x_INDEX_LEASE_NUMBER);
      x_return_status := 'E';
END check_unq_index_lease_number;


END pn_index_leases_pkg;



/
