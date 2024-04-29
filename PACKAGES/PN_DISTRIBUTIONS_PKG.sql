--------------------------------------------------------
--  DDL for Package PN_DISTRIBUTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_DISTRIBUTIONS_PKG" 
-- $Header: PNTDISTS.pls 120.1 2005/07/25 06:50:23 appldev ship $

AUTHID CURRENT_USER AS

------------------------------------------------------------------------
-- PROCEDURE : INSERT_ROW
------------------------------------------------------------------------
   PROCEDURE insert_row (
      x_rowid                IN OUT NOCOPY   VARCHAR2
     ,x_distribution_id      IN OUT NOCOPY   NUMBER
     ,x_account_id           IN       NUMBER
     ,x_payment_term_id      IN       NUMBER
     ,x_term_template_id     IN       NUMBER
     ,x_account_class        IN       VARCHAR2
     ,x_percentage           IN       NUMBER
     ,x_line_number          IN OUT NOCOPY   NUMBER
     ,x_last_update_date     IN       DATE
     ,x_last_updated_by      IN       NUMBER
     ,x_creation_date        IN       DATE
     ,x_created_by           IN       NUMBER
     ,x_last_update_login    IN       NUMBER
     ,x_attribute_category   IN       VARCHAR2
     ,x_attribute1           IN       VARCHAR2
     ,x_attribute2           IN       VARCHAR2
     ,x_attribute3           IN       VARCHAR2
     ,x_attribute4           IN       VARCHAR2
     ,x_attribute5           IN       VARCHAR2
     ,x_attribute6           IN       VARCHAR2
     ,x_attribute7           IN       VARCHAR2
     ,x_attribute8           IN       VARCHAR2
     ,x_attribute9           IN       VARCHAR2
     ,x_attribute10          IN       VARCHAR2
     ,x_attribute11          IN       VARCHAR2
     ,x_attribute12          IN       VARCHAR2
     ,x_attribute13          IN       VARCHAR2
     ,x_attribute14          IN       VARCHAR2
     ,x_attribute15          IN       VARCHAR2
     ,x_org_id               IN       NUMBER default NULL
   );


------------------------------------------------------------------------
-- PROCEDURE : UPDATE_ROW
------------------------------------------------------------------------
   PROCEDURE update_row (
      x_rowid                IN   VARCHAR2
     ,x_distribution_id      IN   NUMBER
     ,x_account_id           IN   NUMBER
     ,x_payment_term_id      IN   NUMBER
     ,x_term_template_id     IN   NUMBER
     ,x_account_class        IN   VARCHAR2
     ,x_percentage           IN   NUMBER
     ,x_line_number          IN   NUMBER
     ,x_last_update_date     IN   DATE
     ,x_last_updated_by      IN   NUMBER
     ,x_last_update_login    IN   NUMBER
     ,x_attribute_category   IN   VARCHAR2
     ,x_attribute1           IN   VARCHAR2
     ,x_attribute2           IN   VARCHAR2
     ,x_attribute3           IN   VARCHAR2
     ,x_attribute4           IN   VARCHAR2
     ,x_attribute5           IN   VARCHAR2
     ,x_attribute6           IN   VARCHAR2
     ,x_attribute7           IN   VARCHAR2
     ,x_attribute8           IN   VARCHAR2
     ,x_attribute9           IN   VARCHAR2
     ,x_attribute10          IN   VARCHAR2
     ,x_attribute11          IN   VARCHAR2
     ,x_attribute12          IN   VARCHAR2
     ,x_attribute13          IN   VARCHAR2
     ,x_attribute14          IN   VARCHAR2
     ,x_attribute15          IN   VARCHAR2
     ,x_lease_change_id      IN   NUMBER DEFAULT NULL
   );


------------------------------------------------------------------------
-- PROCEDURE : LOCK_ROW
------------------------------------------------------------------------
   PROCEDURE lock_row (
      x_rowid                IN   VARCHAR2
     ,x_distribution_id      IN   NUMBER
     ,x_account_id           IN   NUMBER
     ,x_payment_term_id      IN   NUMBER
     ,x_term_template_id     IN   NUMBER
     ,x_account_class        IN   VARCHAR2
     ,x_percentage           IN   NUMBER
     ,x_line_number          IN   NUMBER
     ,x_attribute_category   IN   VARCHAR2
     ,x_attribute1           IN   VARCHAR2
     ,x_attribute2           IN   VARCHAR2
     ,x_attribute3           IN   VARCHAR2
     ,x_attribute4           IN   VARCHAR2
     ,x_attribute5           IN   VARCHAR2
     ,x_attribute6           IN   VARCHAR2
     ,x_attribute7           IN   VARCHAR2
     ,x_attribute8           IN   VARCHAR2
     ,x_attribute9           IN   VARCHAR2
     ,x_attribute10          IN   VARCHAR2
     ,x_attribute11          IN   VARCHAR2
     ,x_attribute12          IN   VARCHAR2
     ,x_attribute13          IN   VARCHAR2
     ,x_attribute14          IN   VARCHAR2
     ,x_attribute15          IN   VARCHAR2
   );


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
-- 04-JUL-05  piagrawa   o Bug 4284035 - Created
-------------------------------------------------------------------------------
   PROCEDURE delete_row (x_distribution_id IN NUMBER);

END pn_distributions_pkg;

 

/
