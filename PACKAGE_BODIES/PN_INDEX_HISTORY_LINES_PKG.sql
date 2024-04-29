--------------------------------------------------------
--  DDL for Package Body PN_INDEX_HISTORY_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_INDEX_HISTORY_LINES_PKG" AS
-- $Header: PNTINHLB.pls 115.6 2002/11/12 23:06:12 stripath ship $

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
|   15-JAN-2002  Mrinal Misra   o In dbdrv command changed phase=pls to phase=plb.
|                                 Added checkfile.Ref. Bug# 2184724.
+===========================================================================*/

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
   ) IS
      CURSOR c IS
         SELECT ROWID
           FROM pn_index_history_lines
          WHERE index_line_id = x_index_line_id;

      l_return_status   VARCHAR2 (30) := NULL;
      l_rowid           VARCHAR2 (18) := NULL;
   BEGIN

--PNP_DEBUG_PKG.debug (' PN_INDEX_HISTORY_LINES_PKG.insert_row (+)');
-- If no INDEX_LINE_ID is provided, get one from sequence
      IF (x_index_line_id IS NULL) THEN
         SELECT pn_index_history_lines_s.NEXTVAL
           INTO x_index_line_id
           FROM DUAL;
      END IF;

      check_unq_index_line (l_return_status, x_index_id, x_index_line_id, x_index_date);

      IF (l_return_status IS NOT NULL) THEN
         app_exception.raise_exception;
      END IF;

      INSERT INTO pn_index_history_lines
        (index_line_id
        ,last_update_date
        ,last_updated_by
        ,creation_date
        ,created_by
        ,index_id
        ,index_date
        ,last_update_login
        ,index_figure
        ,index_estimate
        ,index_unadj_1
        ,index_unadj_2
        ,index_seasonally_unadj_1
        ,index_seasonally_unadj_2
        ,updated_flag
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
      VALUES (x_index_line_id
             ,x_last_update_date
             ,x_last_updated_by
             ,x_creation_date
             ,x_created_by
             ,x_index_id
             ,x_index_date
             ,x_last_update_login
             ,x_index_figure
             ,x_index_estimate
             ,x_index_unadj_1
             ,x_index_unadj_2
             ,x_index_seasonally_unadj_1
             ,x_index_seasonally_unadj_2
             ,x_updated_flag
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


-- Check if a valid record was created.
      OPEN c;
      FETCH c INTO x_rowid;

      IF (c%NOTFOUND) THEN
         CLOSE c;
         RAISE NO_DATA_FOUND;
      END IF;

      CLOSE c;

--PNP_DEBUG_PKG.debug (' PN_INDEX_HISTORY_LINES_PKG.insert_row (-)');
   END insert_row;


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
   ) IS
      l_return_status   VARCHAR2 (30) := NULL;
   BEGIN

--PNP_DEBUG_PKG.debug (' PN_INDEX_HISTORY_LINES_PKG.update_row (+)');

      check_unq_index_line (l_return_status, x_index_id, x_index_line_id, x_index_date);

      IF (l_return_status IS NOT NULL) THEN
         app_exception.raise_exception;
      END IF;

      UPDATE pn_index_history_lines
         SET last_update_date = x_last_update_date
            ,last_updated_by = x_last_updated_by
            ,index_id = x_index_id
            ,index_date = x_index_date
            ,last_update_login = x_last_update_login
            ,index_figure = x_index_figure
            ,index_estimate = x_index_estimate
            ,index_unadj_1 = x_index_unadj_1
            ,index_unadj_2 = x_index_unadj_2
            ,index_seasonally_unadj_1 = x_index_seasonally_unadj_1
            ,index_seasonally_unadj_2 = x_index_seasonally_unadj_2
            ,updated_flag = x_updated_flag
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
       WHERE ROWID = x_rowid;

      IF (SQL%NOTFOUND) THEN
         RAISE NO_DATA_FOUND;
      END IF;

--PNP_DEBUG_PKG.debug (' PN_INDEX_HISTORY_LINES_PKG.update_row (-)');
   END update_row;


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
   ) IS
      CURSOR c1 IS
         SELECT        *
                  FROM pn_index_history_lines
                 WHERE ROWID = x_rowid
         FOR UPDATE OF index_line_id NOWAIT;

      tlinfo   c1%ROWTYPE;
   BEGIN

--PNP_DEBUG_PKG.debug (' PN_INDEX_HISTORY_LINES_PKG.lock_row (+)');
      OPEN c1;
      FETCH c1 INTO tlinfo;

      IF (c1%NOTFOUND) THEN
         CLOSE c1;
         RETURN;
      END IF;

      CLOSE c1;

      IF (    (tlinfo.index_line_id = x_index_line_id)
          AND (tlinfo.index_id = x_index_id)
          AND (tlinfo.index_date = x_index_date)
          AND (   (tlinfo.index_figure = x_index_figure)
               OR (    (tlinfo.index_figure IS NULL)
                   AND x_index_figure IS NULL
                  )
              )
          AND (   (tlinfo.index_estimate = x_index_estimate)
               OR (    (tlinfo.index_estimate IS NULL)
                   AND x_index_estimate IS NULL
                  )
              )
          AND (   (tlinfo.index_unadj_1 = x_index_unadj_1)
               OR (    (tlinfo.index_unadj_1 IS NULL)
                   AND x_index_unadj_1 IS NULL
                  )
              )
          AND (   (tlinfo.index_unadj_2 = x_index_unadj_2)
               OR (    (tlinfo.index_unadj_2 IS NULL)
                   AND x_index_unadj_2 IS NULL
                  )
              )
          AND (   (tlinfo.index_seasonally_unadj_1 = x_index_seasonally_unadj_1)
               OR (    (tlinfo.index_seasonally_unadj_1 IS NULL)
                   AND x_index_seasonally_unadj_1 IS NULL
                  )
              )
          AND (   (tlinfo.index_seasonally_unadj_2 = x_index_seasonally_unadj_2)
               OR (    (tlinfo.index_seasonally_unadj_2 IS NULL)
                   AND x_index_seasonally_unadj_2 IS NULL
                  )
              )
         ) THEN
         NULL;
      ELSE
         fnd_message.set_name ('FND', 'FORM_RECORD_CHANGED');
         app_exception.raise_exception;
      END IF;

--PNP_DEBUG_PKG.debug (' PN_INDEX_HISTORY_LINES_PKG.lock_row (-)');
   END lock_row;


------------------------------------------------------------------------
-- PROCEDURE : DELETE_ROW
------------------------------------------------------------------------
   PROCEDURE delete_row (
      x_rowid   IN   VARCHAR2
   ) IS
   BEGIN

--PNP_DEBUG_PKG.debug (' PN_INDEX_HISTORY_LINES_PKG.delete_row (+)');
      DELETE FROM pn_index_history_lines
            WHERE ROWID = x_rowid;

      IF (SQL%NOTFOUND) THEN
         RAISE NO_DATA_FOUND;
      END IF;

--PNP_DEBUG_PKG.debug (' PN_INDEX_HISTORY_LINES_PKG.delete_row (-)');
   END delete_row;

   PROCEDURE check_unq_index_line (
      x_return_status   IN OUT NOCOPY   VARCHAR2
     ,x_index_id        IN       NUMBER
     ,x_index_line_id   IN       NUMBER
     ,x_index_date      IN       DATE
   ) IS
      l_dummy   NUMBER;
   BEGIN
      SELECT 1
        INTO l_dummy
        FROM DUAL
       WHERE NOT EXISTS ( SELECT 1
                            FROM pn_index_history_lines
                           WHERE (TO_CHAR (index_date, 'MON-RRRR') =
                                                        TO_CHAR (x_index_date, 'MON-RRRR')
                                 )
                             AND (index_id = x_index_id)
                             AND (   (x_index_line_id IS NULL)
                                  OR (index_line_id <> x_index_line_id)
                                 ));
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         fnd_message.set_name ('PN', 'PN_DUP_INDEX_HIST_LINE');

--         fnd_message.set_token ('MONTH', x_index_date);
         x_return_status := 'E';
   END check_unq_index_line;
END pn_index_history_lines_pkg;

/
