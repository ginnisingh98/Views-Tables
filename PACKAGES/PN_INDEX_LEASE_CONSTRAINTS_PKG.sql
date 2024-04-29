--------------------------------------------------------
--  DDL for Package PN_INDEX_LEASE_CONSTRAINTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_INDEX_LEASE_CONSTRAINTS_PKG" AUTHID CURRENT_USER AS
-- $Header: PNTINLCS.pls 120.1 2005/07/26 07:03:47 appldev ship $


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
| 11-APR-2001  jbreyes   o Created
| 13-DEC-2001  Mrinal    o Added dbdrv command.
| 09-JUL-2002  ftanudja  o added x_org_id param in insert_row for
|                          shared serv. enh.
| 05-Jul-2005  hrodda    o overloaded delete_row proc to take PK as parameter
+============================================================================*/


/**** SPECIFICATIONS ****/


-----------------------------------------------------------------------
-- PROCEDURE : INSERT_ROW
------------------------------------------------------------------------
   PROCEDURE insert_row (
      x_rowid                 IN OUT NOCOPY   VARCHAR2
     ,x_org_id                IN       NUMBER  DEFAULT NULL
     ,x_index_constraint_id   IN OUT NOCOPY   NUMBER
     ,x_index_lease_id        IN       NUMBER
     ,x_scope                 IN       VARCHAR2
     ,x_last_update_date      IN       DATE
     ,x_last_updated_by       IN       NUMBER
     ,x_creation_date         IN       DATE
     ,x_created_by            IN       NUMBER
     ,x_minimum_amount        IN       NUMBER
     ,x_maximum_amount        IN       NUMBER
     ,x_minimum_percent       IN       NUMBER
     ,x_maximum_percent       IN       NUMBER
     ,x_last_update_login     IN       NUMBER
     ,x_attribute_category    IN       VARCHAR2
     ,x_attribute1            IN       VARCHAR2
     ,x_attribute2            IN       VARCHAR2
     ,x_attribute3            IN       VARCHAR2
     ,x_attribute4            IN       VARCHAR2
     ,x_attribute5            IN       VARCHAR2
     ,x_attribute6            IN       VARCHAR2
     ,x_attribute7            IN       VARCHAR2
     ,x_attribute8            IN       VARCHAR2
     ,x_attribute9            IN       VARCHAR2
     ,x_attribute10           IN       VARCHAR2
     ,x_attribute11           IN       VARCHAR2
     ,x_attribute12           IN       VARCHAR2
     ,x_attribute13           IN       VARCHAR2
     ,x_attribute14           IN       VARCHAR2
     ,x_attribute15           IN       VARCHAR2
   );


------------------------------------------------------------------------
-- PROCEDURE : UPDATE_ROW
------------------------------------------------------------------------
   PROCEDURE update_row (
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
   );


------------------------------------------------------------------------
-- PROCEDURE : LOCK_ROW
------------------------------------------------------------------------
   PROCEDURE lock_row (
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
   );


-------------------------------------------------------------------------------
-- PROCEDURE : DELETE_ROW
-------------------------------------------------------------------------------
   PROCEDURE delete_row (
      x_rowid   IN   VARCHAR2
   );

-------------------------------------------------------------------------------
-- PROCDURE     : delete_row
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : deletes the row
-- NOTE         : overrided delete_row procedure to take PK as in parameter
-- HISTORY      :
-- 04-JUL-05  hrodda  o Created.
-------------------------------------------------------------------------------
    PROCEDURE delete_row (
      x_index_constraint_id   IN   NUMBER
   );


   ----------------------------------------------------------------------------
-- PROCEDURE : create_check_unique_constraint_scope
-------------------------------------------------------------------------------
   PROCEDURE check_unq_constraint_scope (
      x_return_status         IN OUT NOCOPY   VARCHAR2
     ,x_index_constraint_id   IN       NUMBER
     ,x_index_lease_id        IN       NUMBER
     ,x_scope                 IN       VARCHAR2
   );
END;

 

/
