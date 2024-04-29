--------------------------------------------------------
--  DDL for Package PN_INDEX_HISTORY_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_INDEX_HISTORY_HEADERS_PKG" AUTHID CURRENT_USER AS
-- $Header: PNTINHHS.pls 115.4 2002/11/12 23:06:01 stripath ship $

/*============================================================================+
|                Copyright (c) 2001 Oracle Corporation
|                   Redwood Shores, California, USA
|                        All rights reserved.
| DESCRIPTION
|
|  These procedures consist are used a table handlers for the PN_INDEX_HISTORY_HEADERS table.
|  They include:
|         INSERT_ROW - insert a row into PN_INDEX_HISTORY_HEADERS.
|         DELETE_ROW - deletes a row from PN_INDEX_HISTORY_HEADERS.
|         UPDATE_ROW - updates a row from PN_INDEX_HISTORY_HEADERS.
|         LOCKS_ROW - will check if a row has been modified since being queried by form.
|
|
| HISTORY
|   24-APR-01 jbreyes        - Created
|   13-DEC-01 Mrinal Misra   - Added dbdrv command.
==============================================================================*/


/**** SPECIFICATIONS ****/
------------------------------------------------------------------------
-- PROCEDURE : INSERT_ROW
------------------------------------------------------------------------
   PROCEDURE insert_row (
      x_rowid                IN OUT NOCOPY   VARCHAR2
     ,x_index_id             IN OUT NOCOPY   NUMBER
     ,x_last_update_date     IN       DATE
     ,x_last_updated_by      IN       NUMBER
     ,x_creation_date        IN       DATE
     ,x_created_by           IN       NUMBER
     ,x_name                 IN       VARCHAR2
     ,x_last_update_login    IN       NUMBER
     ,x_source               IN       VARCHAR2
     ,x_comments             IN       VARCHAR2
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
   );


------------------------------------------------------------------------
-- PROCEDURE : UPDATE_ROW
------------------------------------------------------------------------
   PROCEDURE update_row (
      x_rowid                IN   VARCHAR2
     ,x_index_id             IN   NUMBER
     ,x_last_update_date     IN   DATE
     ,x_last_updated_by      IN   NUMBER
     ,x_name                 IN   VARCHAR2
     ,x_last_update_login    IN   NUMBER
     ,x_source               IN   VARCHAR2
     ,x_comments             IN   VARCHAR2
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
-- PROCEDURE : LOCK_ROW
------------------------------------------------------------------------
   PROCEDURE lock_row (
      x_rowid                IN   VARCHAR2
     ,x_index_id             IN   NUMBER
     ,x_name                 IN   VARCHAR2
     ,x_source               IN   VARCHAR2
     ,x_comments             IN   VARCHAR2
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
   PROCEDURE delete_row (
      x_rowid   IN   VARCHAR2
   );


------------------------------------------------------------------------
-- PROCEDURE : check_unique_index_type
------------------------------------------------------------------------
   PROCEDURE check_unq_index_type (
      x_return_status   IN OUT NOCOPY   VARCHAR2
     ,x_index_id        IN       NUMBER
     ,x_name            IN       VARCHAR2
   );
END pn_index_history_headers_pkg;

 

/
