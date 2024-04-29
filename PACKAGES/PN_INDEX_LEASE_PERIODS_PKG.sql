--------------------------------------------------------
--  DDL for Package PN_INDEX_LEASE_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_INDEX_LEASE_PERIODS_PKG" AUTHID CURRENT_USER AS
-- $Header: PNTINLPS.pls 120.3 2007/03/14 12:57:37 pseeram ship $

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
|         LOCKS_ROW  - will check if a row has been modified since being
|                     queried by form.
|
|
| HISTORY
| 21-MAY-2001  jbreyes   o Created
| 13-DEC-2001  Mrinal    o Added dbdrv command.
| 09-JUL-2002  ftanudja  o added x_org_id param in insert_row for
|                          shared services enh.
| 12-Aug-2002  psidhu    o Added parameter x_carry_forward_flag to
|                          procedure update_row_calc.
| 05-Jul-2005  hrodda    o overloaded delete_row proc to take PK as parameter
| 09-NOV-2006  Prabhakar o Added index_multiplier to insert/update/lock.
+===========================================================================*/
/**** SPECIFICATIONS ****/
------------------------------------------------------------------------
-- PROCEDURE : INSERT_ROW
------------------------------------------------------------------------
   PROCEDURE insert_row (
      x_rowid                       IN OUT NOCOPY   VARCHAR2
     ,x_org_id                      IN       NUMBER  DEFAULT NULL
     ,x_index_period_id             IN OUT NOCOPY   NUMBER
     ,x_index_lease_id              IN       NUMBER
     ,x_line_number                 IN  OUT NOCOPY  NUMBER
     ,x_assessment_date             IN       DATE
     ,x_last_update_date            IN       DATE
     ,x_last_updated_by             IN       NUMBER
     ,x_creation_date               IN       DATE
     ,x_created_by                  IN       NUMBER
     ,x_basis_start_date            IN       DATE
     ,x_basis_end_date              IN       DATE
     ,x_index_finder_date           IN       DATE
     ,x_current_index_line_id       IN       NUMBER
     ,x_current_index_line_value    IN       NUMBER
     ,x_previous_index_line_id      IN       NUMBER
     ,x_previous_index_line_value   IN       NUMBER
     ,x_current_basis               IN       NUMBER
     ,x_relationship                IN       VARCHAR2
     ,x_index_percent_change        IN       NUMBER
     ,x_basis_percent_change        IN       NUMBER
     ,x_unconstraint_rent_due       IN       NUMBER
     ,x_constraint_rent_due         IN       NUMBER
     ,x_last_update_login           IN       NUMBER
     ,x_attribute_category          IN       VARCHAR2
     ,x_attribute1                  IN       VARCHAR2
     ,x_attribute2                  IN       VARCHAR2
     ,x_attribute3                  IN       VARCHAR2
     ,x_attribute4                  IN       VARCHAR2
     ,x_attribute5                  IN       VARCHAR2
     ,x_attribute6                  IN       VARCHAR2
     ,x_attribute7                  IN       VARCHAR2
     ,x_attribute8                  IN       VARCHAR2
     ,x_attribute9                  IN       VARCHAR2
     ,x_attribute10                 IN       VARCHAR2
     ,x_attribute11                 IN       VARCHAR2
     ,x_attribute12                 IN       VARCHAR2
     ,x_attribute13                 IN       VARCHAR2
     ,x_attribute14                 IN       VARCHAR2
     ,x_attribute15                 IN       VARCHAR2
     ,x_index_multiplier            IN       NUMBER);


------------------------------------------------------------------------
-- PROCEDURE : UPDATE_ROW
------------------------------------------------------------------------
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
     ,x_constraint_applied_percent  IN   NUMBER);




------------------------------------------------------------------------
-- PROCEDURE : UPDATE_CALCULATIONS
------------------------------------------------------------------------
   PROCEDURE update_row_calc (
      x_rowid                       IN            VARCHAR2
      ,x_calculate                      IN             VARCHAR2
      ,x_updated_flag                   IN             VARCHAR2
     ,x_index_period_id             IN            NUMBER
     ,x_index_lease_id              IN            NUMBER
     ,x_line_number                 IN            NUMBER
     ,x_assessment_date             IN            DATE
     ,x_last_update_date            IN            DATE
     ,x_last_updated_by             IN            NUMBER
     ,x_basis_start_date            IN            DATE
     ,x_basis_end_date              IN            DATE
     ,x_index_finder_date           IN            DATE
     ,x_current_index_line_id       IN OUT NOCOPY        NUMBER
     ,x_current_index_line_value    IN OUT NOCOPY        NUMBER
     ,x_previous_index_line_id      IN OUT NOCOPY        NUMBER
     ,x_previous_index_line_value   IN OUT NOCOPY        NUMBER
     ,x_current_basis               IN OUT NOCOPY        NUMBER
     ,x_relationship                IN            VARCHAR2
     ,x_index_percent_change        IN OUT NOCOPY        NUMBER
     ,x_basis_percent_change        IN            NUMBER
     ,x_unconstraint_rent_due       IN OUT NOCOPY        NUMBER
     ,x_constraint_rent_due         IN OUT NOCOPY        NUMBER
     ,x_last_update_login           IN            NUMBER
     ,x_attribute_category          IN            VARCHAR2
     ,x_attribute1                  IN            VARCHAR2
     ,x_attribute2                  IN            VARCHAR2
     ,x_attribute3                  IN            VARCHAR2
     ,x_attribute4                  IN            VARCHAR2
     ,x_attribute5                  IN            VARCHAR2
     ,x_attribute6                  IN            VARCHAR2
     ,x_attribute7                  IN            VARCHAR2
     ,x_attribute8                  IN            VARCHAR2
     ,x_attribute9                  IN            VARCHAR2
     ,x_attribute10                 IN            VARCHAR2
     ,x_attribute11                 IN            VARCHAR2
     ,x_attribute12                 IN            VARCHAR2
     ,x_attribute13                 IN            VARCHAR2
     ,x_attribute14                 IN            VARCHAR2
     ,x_attribute15                 IN            VARCHAR2
     ,x_carry_forward_flag          IN            VARCHAR2
     ,x_index_multiplier            IN            NUMBER
     ,x_constraint_applied_amount   IN   NUMBER
     ,x_constraint_applied_percent  IN   NUMBER);


------------------------------------------------------------------------
-- PROCEDURE : LOCK_ROW
------------------------------------------------------------------------
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
     ,x_constraint_applied_percent  IN   NUMBER);


------------------------------------------------------------------------
-- PROCEDURE : DELETE_ROW
------------------------------------------------------------------------
   PROCEDURE delete_row (x_rowid IN VARCHAR2);

-------------------------------------------------------------------------------
-- PROCDURE     : delete_row
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : deletes the row
-- NOTE         : overloaded this procedure to take PK as In parameter
-- HISTORY      :
-- 04-JUL-05  hrodda   o Bug 4284035 - Created
-------------------------------------------------------------------------------
   PROCEDURE delete_row (x_index_period_id IN NUMBER);


END pn_index_lease_periods_pkg;

/
