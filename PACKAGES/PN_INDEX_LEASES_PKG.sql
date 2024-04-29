--------------------------------------------------------
--  DDL for Package PN_INDEX_LEASES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_INDEX_LEASES_PKG" AUTHID CURRENT_USER AS
-- $Header: PNTINLES.pls 120.3 2007/01/02 07:45:24 pseeram ship $

/*============================================================================+
|                Copyright (c) 2001 Oracle Corporation
|                   Redwood Shores, California, USA
|                        All rights reserved.
| DESCRIPTION
|
|  These procedures consist are used a table handlers for the PN_INDEX_LEASES
|  table. They include:
|         INSERT_ROW - insert a row into PN_INDEX_LEASES.
|         DELETE_ROW - deletes a row from PN_INDEX_LEASES.
|         UPDATE_ROW - updates a row from PN_INDEX_LEASES.
|         LOCKS_ROW - will check if a row has been modified since being queried
|                     by form.
|
|
| HISTORY
| 10-APR-01    jbreyes   o Created
| 15-JUN-01    jbreyes   o Added new column BASE_INDEX_LINE_ID
| 21-JUN-01    jbreyes   o Added new column INDEX_FINDER_MONTHS
| 07-AUG-01    psidhu    o Added new columns AGGEGATION_FLAG and
|                          GROSS_FLAG
| 10-DEC-2001  Mrinal    o Added dbdrv command.
| 17-Jul-2002  Psidhu    o Added currency_code as a parameter to
|                          insert_row, update_row and lock_row.
| 09-JUL-02    ftanudja  o added x_org_id param in insert_row
|                          for shared serv enh.
| 05-AUG-02    psidhu    o added x_carry_forward_flag parameter to
|                          insert_row,update_row and lock_row.
| 17-MAY-04    vmmehta   o added x_retain_initial_flag parameter to
|                          insert_row,update_row and lock_row.
| 05-JUL-05    hrodda    o overloaded delete_row proc to take PK as parameter
| 14-AUG-06    pikhar    o Added vr_nbp_flag to insert/update/lock
| 09-NOV-06    Prabhakar o Added index_multiplier to insert/update/lock
| 08-NOV-06    Prabhakar o Added proration_rule and pn_proration_period_start_date
|                          to insert/update/lock.
+===========================================================================*/


------------------------------------------------------------------------
-- PROCEDURE : INSERT_ROW
------------------------------------------------------------------------
   PROCEDURE insert_row (
      x_rowid                   IN OUT NOCOPY   VARCHAR2
     ,x_org_id                  IN       NUMBER DEFAULT NULL
     ,x_index_lease_id          IN OUT NOCOPY   NUMBER
     ,x_lease_id                IN       NUMBER
     ,x_index_id                IN       NUMBER
     ,x_commencement_date       IN       DATE
     ,x_termination_date        IN       DATE
     ,x_index_lease_number      IN OUT NOCOPY   VARCHAR2
     ,x_last_update_date        IN       DATE
     ,x_last_updated_by         IN       NUMBER
     ,x_creation_date           IN       DATE
     ,x_created_by              IN       NUMBER
     ,x_location_id             IN       NUMBER
     ,x_term_template_id        IN       NUMBER
     ,x_abstracted_by           IN       NUMBER
     ,x_assessment_date         IN       DATE
     ,x_assessment_interval     IN       NUMBER
     ,x_spread_frequency        IN       VARCHAR2
     ,x_relationship_default    IN       VARCHAR2
     ,x_basis_percent_default   IN       NUMBER
     ,x_initial_basis           IN       NUMBER
     ,x_base_index              IN       NUMBER
     ,x_base_index_line_id      IN       NUMBER
     ,x_index_finder_method     IN       VARCHAR2
     ,x_index_finder_months     IN       NUMBER
     ,x_negative_rent_type      IN       VARCHAR2
     ,x_increase_on             IN       VARCHAR2
     ,x_basis_type              IN       VARCHAR2
     ,x_reference_period        IN       VARCHAR2
     ,x_base_year               IN       DATE
     ,x_leased_area             IN       NUMBER
     ,x_rounding_flag           IN       VARCHAR2
     ,x_aggregation_flag        IN       VARCHAR2
     ,x_gross_flag              IN       VARCHAR2
     ,x_last_update_login       IN       NUMBER
     ,x_attribute_category      IN       VARCHAR2
     ,x_attribute1              IN       VARCHAR2
     ,x_attribute2              IN       VARCHAR2
     ,x_attribute3              IN       VARCHAR2
     ,x_attribute4              IN       VARCHAR2
     ,x_attribute5              IN       VARCHAR2
     ,x_attribute6              IN       VARCHAR2
     ,x_attribute7              IN       VARCHAR2
     ,x_attribute8              IN       VARCHAR2
     ,x_attribute9              IN       VARCHAR2
     ,x_attribute10             IN       VARCHAR2
     ,x_attribute11             IN       VARCHAR2
     ,x_attribute12             IN       VARCHAR2
     ,x_attribute13             IN       VARCHAR2
     ,x_attribute14             IN       VARCHAR2
     ,x_attribute15             IN       VARCHAR2
     ,x_agreement_category      IN       VARCHAR2
     ,x_agreement_attribute1    IN       VARCHAR2
     ,x_agreement_attribute2    IN       VARCHAR2
     ,x_agreement_attribute3    IN       VARCHAR2
     ,x_agreement_attribute4    IN       VARCHAR2
     ,x_agreement_attribute5    IN       VARCHAR2
     ,x_agreement_attribute6    IN       VARCHAR2
     ,x_agreement_attribute7    IN       VARCHAR2
     ,x_agreement_attribute8    IN       VARCHAR2
     ,x_agreement_attribute9    IN       VARCHAR2
     ,x_agreement_attribute10   IN       VARCHAR2
     ,x_agreement_attribute11   IN       VARCHAR2
     ,x_agreement_attribute12   IN       VARCHAR2
     ,x_agreement_attribute13   IN       VARCHAR2
     ,x_agreement_attribute14   IN       VARCHAR2
     ,x_agreement_attribute15   IN       VARCHAR2
     ,x_currency_code           IN       VARCHAR2
     ,x_carry_forward_flag      IN       VARCHAR2
     ,x_retain_initial_basis_flag  IN    VARCHAR2 DEFAULT NULL
     ,x_vr_nbp_flag             IN       VARCHAR2
     ,x_index_multiplier        IN       NUMBER
     ,x_proration_rule          IN       VARCHAR2
     ,x_proration_period_start_date IN   DATE);

------------------------------------------------------------------------
-- PROCEDURE : UPDATE_ROW
------------------------------------------------------------------------
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
     ,x_retain_initial_basis_flag  IN    VARCHAR2 DEFAULT NULL
     ,x_vr_nbp_flag             IN       VARCHAR2
     ,x_index_multiplier        IN       NUMBER
     ,x_proration_rule          IN       VARCHAR2
     ,x_proration_period_start_date IN   DATE);

------------------------------------------------------------------------
-- PROCEDURE : LOCK_ROW
------------------------------------------------------------------------
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
     ,x_retain_initial_basis_flag  IN    VARCHAR2 DEFAULT NULL
     ,x_vr_nbp_flag             IN       VARCHAR2
     ,x_index_multiplier        IN       NUMBER
     ,x_proration_rule          IN       VARCHAR2
     ,x_proration_period_start_date IN   DATE);

------------------------------------------------------------------------
-- PROCEDURE : DELETE_ROW
------------------------------------------------------------------------
   PROCEDURE delete_row (
      x_rowid   IN   VARCHAR2);

-------------------------------------------------------------------------------
-- PROCDURE     : delete_row
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : deletes the row
-- NOTE         : overload delete_row to take PK as IN paramter instead of ROWID
-- HISTORY      :
-- 04-JUL-05  hrodda o Bug 4284035 - Created
-------------------------------------------------------------------------------
   PROCEDURE delete_row (
      x_index_lease_id   IN   NUMBER);



------------------------------------------------------------------------
-- PROCEDURE : CHECK_UNQ_INDEX_LEASE_NUMBER
------------------------------------------------------------------------
   PROCEDURE check_unq_index_lease_number (
      x_return_status        IN OUT NOCOPY   VARCHAR2
     ,x_index_lease_id       IN       NUMBER
     ,x_index_lease_number   IN       VARCHAR2);
END pn_index_leases_pkg;

/
