--------------------------------------------------------
--  DDL for Package PN_INDEX_HISTORY_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_INDEX_HISTORY_LINES_PKG" AUTHID CURRENT_USER AS
-- $Header: PNTINHLS.pls 115.4 2002/11/12 23:06:22 stripath ship $


/*============================================================================+
|                Copyright (c) 2001 Oracle Corporation
|                   Redwood Shores, California, USA
|                        All rights reserved.
| DESCRIPTION
|
|  These procedures consist are used a table handlers for the PN_INDEX_HISTORY_LINES table.
|  They include:
|         INSERT_ROW - insert a row into PN_INDEX_HISTORY_LINES.
|         DELETE_ROW - deletes a row from PN_INDEX_HISTORY_LINES.
|         UPDATE_ROW - updates a row from PN_INDEX_HISTORY_LINES.
|         LOCKS_ROW - will check if a row has been modified since being queried by form.
|
|
| HISTORY
|   24-APR-2001  jbreyes        o Created
|   13-DEC-2001  Mrinal Misra   o Added dbdrv command.
+===========================================================================*/
/**** SPECIFICATIONS ****/
------------------------------------------------------------------------
-- PROCEDURE : INSERT_ROW
------------------------------------------------------------------------
   PROCEDURE insert_row (
      x_rowid                      IN OUT NOCOPY   VARCHAR2
     ,x_index_line_id              IN OUT NOCOPY   NUMBER
     ,x_last_update_date           IN       DATE
     ,x_last_updated_by            IN       NUMBER
     ,x_creation_date              IN       DATE
     ,x_created_by                 IN       NUMBER
     ,x_index_id                   IN       NUMBER
     ,x_index_date                 IN       DATE
     ,x_last_update_login          IN       NUMBER
     ,x_index_figure               IN       NUMBER
     ,x_index_estimate             IN       NUMBER
     ,x_index_unadj_1              IN       NUMBER
     ,x_index_unadj_2              IN       NUMBER
     ,x_index_seasonally_unadj_1   IN       NUMBER
     ,x_index_seasonally_unadj_2   IN       NUMBER
     ,x_updated_flag               IN       VARCHAR2
     ,x_attribute_category         IN       VARCHAR2
     ,x_attribute1                 IN       VARCHAR2
     ,x_attribute2                 IN       VARCHAR2
     ,x_attribute3                 IN       VARCHAR2
     ,x_attribute4                 IN       VARCHAR2
     ,x_attribute5                 IN       VARCHAR2
     ,x_attribute6                 IN       VARCHAR2
     ,x_attribute7                 IN       VARCHAR2
     ,x_attribute8                 IN       VARCHAR2
     ,x_attribute9                 IN       VARCHAR2
     ,x_attribute10                IN       VARCHAR2
     ,x_attribute11                IN       VARCHAR2
     ,x_attribute12                IN       VARCHAR2
     ,x_attribute13                IN       VARCHAR2
     ,x_attribute14                IN       VARCHAR2
     ,x_attribute15                IN       VARCHAR2
   );


------------------------------------------------------------------------
-- PROCEDURE : UPDATE_ROW
------------------------------------------------------------------------
   PROCEDURE update_row (
      x_rowid                      IN   VARCHAR2
     ,x_index_line_id              IN   NUMBER
     ,x_last_update_date           IN   DATE
     ,x_last_updated_by            IN   NUMBER
     ,x_index_id                   IN   NUMBER
     ,x_index_date                 IN   DATE
     ,x_last_update_login          IN   NUMBER
     ,x_index_figure               IN   NUMBER
     ,x_index_estimate             IN   NUMBER
     ,x_index_unadj_1              IN   NUMBER
     ,x_index_unadj_2              IN   NUMBER
     ,x_index_seasonally_unadj_1   IN   NUMBER
     ,x_index_seasonally_unadj_2   IN   NUMBER
     ,x_updated_flag               IN   VARCHAR2
     ,x_attribute_category         IN   VARCHAR2
     ,x_attribute1                 IN   VARCHAR2
     ,x_attribute2                 IN   VARCHAR2
     ,x_attribute3                 IN   VARCHAR2
     ,x_attribute4                 IN   VARCHAR2
     ,x_attribute5                 IN   VARCHAR2
     ,x_attribute6                 IN   VARCHAR2
     ,x_attribute7                 IN   VARCHAR2
     ,x_attribute8                 IN   VARCHAR2
     ,x_attribute9                 IN   VARCHAR2
     ,x_attribute10                IN   VARCHAR2
     ,x_attribute11                IN   VARCHAR2
     ,x_attribute12                IN   VARCHAR2
     ,x_attribute13                IN   VARCHAR2
     ,x_attribute14                IN   VARCHAR2
     ,x_attribute15                IN   VARCHAR2
   );


------------------------------------------------------------------------
-- PROCEDURE : LOCK_ROW
------------------------------------------------------------------------
   PROCEDURE lock_row (
      x_rowid                      IN   VARCHAR2
     ,x_index_line_id              IN   NUMBER
     ,x_index_id                   IN   NUMBER
     ,x_index_date                 IN   DATE
     ,x_index_figure               IN   NUMBER
     ,x_index_estimate             IN   NUMBER
     ,x_index_unadj_1              IN   NUMBER
     ,x_index_unadj_2              IN   NUMBER
     ,x_index_seasonally_unadj_1   IN   NUMBER
     ,x_index_seasonally_unadj_2   IN   NUMBER
     ,x_updated_flag               IN   VARCHAR2
     ,x_attribute_category         IN   VARCHAR2
     ,x_attribute1                 IN   VARCHAR2
     ,x_attribute2                 IN   VARCHAR2
     ,x_attribute3                 IN   VARCHAR2
     ,x_attribute4                 IN   VARCHAR2
     ,x_attribute5                 IN   VARCHAR2
     ,x_attribute6                 IN   VARCHAR2
     ,x_attribute7                 IN   VARCHAR2
     ,x_attribute8                 IN   VARCHAR2
     ,x_attribute9                 IN   VARCHAR2
     ,x_attribute10                IN   VARCHAR2
     ,x_attribute11                IN   VARCHAR2
     ,x_attribute12                IN   VARCHAR2
     ,x_attribute13                IN   VARCHAR2
     ,x_attribute14                IN   VARCHAR2
     ,x_attribute15                IN   VARCHAR2
   );


------------------------------------------------------------------------
-- PROCEDURE : DELETE_ROW
------------------------------------------------------------------------
   PROCEDURE delete_row (
      x_rowid   IN   VARCHAR2
   );


------------------------------------------------------------------------
-- PROCEDURE : create_check_unique_index Line
------------------------------------------------------------------------


   PROCEDURE check_unq_index_line (
      x_return_status   IN OUT NOCOPY   VARCHAR2
     ,x_index_id        IN       NUMBER
     ,x_index_line_id   IN       NUMBER
     ,x_index_date      IN       DATE
   );
END pn_index_history_lines_pkg;

 

/
