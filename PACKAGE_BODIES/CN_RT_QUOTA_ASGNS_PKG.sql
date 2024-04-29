--------------------------------------------------------
--  DDL for Package Body CN_RT_QUOTA_ASGNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_RT_QUOTA_ASGNS_PKG" AS
-- $Header: cnplirqab.pls 120.3 2006/01/10 04:27:22 rarajara ship $

   -- Date    Name                 Description
--------------------------------------------------------------------------------+
--  10-MAR-99 Kumar Sivasankaran    Created

   --  Name   : CN_RT_QUOTA_ASGNS_PKG
--  Purpose : Holds all server side packages used to insert a
--  rate quota asngs
--  Desc    : Begin Record is called at the start of the commit cycle.
--------------------------------------------------------------------------------+

   --------------------------------------------------------------------------------+
--
--                               PRIVATE VARIABLES
--
--------------------------------------------------------------------------------+
   g_temp_status_code            VARCHAR2 (30) := NULL;
   g_program_type                VARCHAR2 (30) := NULL;

--------------------------------------------------------------------------------+
--
--                               PRIVATE ROUTINES
--
--------------------------------------------------------------------------------+
-- Procedure Name
-- Get_UID
-- Purpose
--    Get the Sequence Number to Create a new rate quota Asgns
--------------------------------------------------------------------------------+
--
--     Procedure Get UID
--
--------------------------------------------------------------------------------+
   PROCEDURE get_uid (
      x_rt_quota_asgn_id         IN OUT NOCOPY NUMBER
   )
   IS
   BEGIN
      SELECT cn_rt_quota_asgns_s.NEXTVAL
        INTO x_rt_quota_asgn_id
        FROM SYS.DUAL;
   END get_uid;

--------------------------------------------------------------------------------+
--
--     Procedure Name Insert_Record
--
--------------------------------------------------------------------------------+
   PROCEDURE INSERT_RECORD (
      x_org_id                   IN       NUMBER,
      x_rowid                    IN OUT NOCOPY VARCHAR2,
      x_rt_quota_asgn_id         IN OUT NOCOPY NUMBER,
      x_calc_formula_id                   NUMBER,
      x_quota_id                          NUMBER,
      x_start_date                        DATE,
      x_end_date                          DATE,
      x_rate_schedule_id                  NUMBER,
      x_attribute_category                VARCHAR2,
      x_attribute1                        VARCHAR2,
      x_attribute2                        VARCHAR2,
      x_attribute3                        VARCHAR2,
      x_attribute4                        VARCHAR2,
      x_attribute5                        VARCHAR2,
      x_attribute6                        VARCHAR2,
      x_attribute7                        VARCHAR2,
      x_attribute8                        VARCHAR2,
      x_attribute9                        VARCHAR2,
      x_attribute10                       VARCHAR2,
      x_attribute11                       VARCHAR2,
      x_attribute12                       VARCHAR2,
      x_attribute13                       VARCHAR2,
      x_attribute14                       VARCHAR2,
      x_attribute15                       VARCHAR2,
      x_last_update_date                  DATE,
      x_last_updated_by                   NUMBER,
      x_creation_date                     DATE,
      x_created_by                        NUMBER,
      x_last_update_login                 NUMBER,
      x_object_version_number    IN OUT NOCOPY NUMBER
   )
   IS
   BEGIN
      -- Get Sequence Number
      get_uid (x_rt_quota_asgn_id);
      x_object_version_number := 1;

      INSERT INTO cn_rt_quota_asgns
                  (org_id,
                   rt_quota_asgn_id,
                   calc_formula_id,
                   quota_id,
                   start_date,
                   end_date,
                   rate_schedule_id,
                   attribute_category,
                   attribute1,
                   attribute2,
                   attribute3,
                   attribute4,
                   attribute5,
                   attribute6,
                   attribute7,
                   attribute8,
                   attribute9,
                   attribute10,
                   attribute11,
                   attribute12,
                   attribute13,
                   attribute14,
                   attribute15,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login,
                   object_version_number
                  )
           VALUES (x_org_id,
                   x_rt_quota_asgn_id,
                   x_calc_formula_id,
                   x_quota_id,
                   x_start_date,
                   x_end_date,
                   x_rate_schedule_id,
                   x_attribute_category,
                   x_attribute1,
                   x_attribute2,
                   x_attribute3,
                   x_attribute4,
                   x_attribute5,
                   x_attribute6,
                   x_attribute7,
                   x_attribute8,
                   x_attribute9,
                   x_attribute10,
                   x_attribute11,
                   x_attribute12,
                   x_attribute13,
                   x_attribute14,
                   x_attribute15,
                   x_last_update_date,
                   x_last_updated_by,
                   x_creation_date,
                   x_created_by,
                   x_last_update_login,
                   x_object_version_number
                  );

      -- Insert the srp quota assigns, if srp plan plans assgins
      cn_srp_rate_assigns_pkg.INSERT_RECORD (x_srp_plan_assign_id        => NULL,
                                             x_srp_quota_assign_id       => NULL,
                                             x_srp_rate_assign_id        => NULL,
                                             x_quota_id                  => x_quota_id,
                                             x_rate_schedule_id          => x_rate_schedule_id,
                                             x_rt_quota_asgn_id          => x_rt_quota_asgn_id,
                                             x_rate_tier_id              => NULL,
                                             x_commission_rate           => NULL,
                                             x_commission_amount         => NULL,
                                             x_disc_rate_table_flag      => NULL
                                            );
   END INSERT_RECORD;

   -- Procedure Name
   --  Lock_Record
   -- Purpose
   --    Lock db row after form record is changed
   -- Notes
   --    Only called from the form

   --------------------------------------------------------------------------------+
 --
--     Procedure Name Lock_Record
--
--------------------------------------------------------------------------------+
   PROCEDURE LOCK_RECORD (
      x_rowid                             VARCHAR2,
      x_rt_quota_asgn_id                  NUMBER,
      x_rate_schedule_id                  NUMBER,
      x_start_date                        DATE,
      x_end_date                          DATE
   )
   IS
      CURSOR c
      IS
         SELECT        *
                  FROM cn_rt_quota_asgns
                 WHERE rt_quota_asgn_id = x_rt_quota_asgn_id
         FOR UPDATE OF rt_quota_asgn_id NOWAIT;

      recinfo                       c%ROWTYPE;
   BEGIN
      OPEN c;

      FETCH c
       INTO recinfo;

      IF (c%NOTFOUND)
      THEN
         CLOSE c;

         fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
         app_exception.raise_exception;
      END IF;

      CLOSE c;

      IF (    (recinfo.rt_quota_asgn_id = x_rt_quota_asgn_id)
          AND (recinfo.rate_schedule_id = x_rate_schedule_id)
          AND (TRUNC (recinfo.start_date) = TRUNC (x_start_date))
          AND (TRUNC (recinfo.end_date) = TRUNC (x_end_date) OR (recinfo.end_date IS NULL AND x_end_date IS NULL))
         )
      THEN
         RETURN;
      ELSE
         fnd_message.set_name ('FND', 'FORM_RECORD_CHANGED');
         app_exception.raise_exception;
      END IF;
   END LOCK_RECORD;

-- Procedure Name
--   Update Record
-- Purpose
--
--------------------------------------------------------------------------------+
--
--        Procedure Name Update_Record
--
--------------------------------------------------------------------------------+
   PROCEDURE UPDATE_RECORD (
      x_rt_quota_asgn_id         IN OUT NOCOPY NUMBER,
      x_calc_formula_id                   NUMBER,
      x_quota_id                          NUMBER,
      x_start_date                        DATE,
      x_end_date                          DATE,
      x_rate_schedule_id                  NUMBER,
      x_attribute_category                VARCHAR2,
      x_attribute1                        VARCHAR2,
      x_attribute2                        VARCHAR2,
      x_attribute3                        VARCHAR2,
      x_attribute4                        VARCHAR2,
      x_attribute5                        VARCHAR2,
      x_attribute6                        VARCHAR2,
      x_attribute7                        VARCHAR2,
      x_attribute8                        VARCHAR2,
      x_attribute9                        VARCHAR2,
      x_attribute10                       VARCHAR2,
      x_attribute11                       VARCHAR2,
      x_attribute12                       VARCHAR2,
      x_attribute13                       VARCHAR2,
      x_attribute14                       VARCHAR2,
      x_attribute15                       VARCHAR2,
      x_last_update_date                  DATE,
      x_last_updated_by                   NUMBER,
      x_creation_date                     DATE,
      x_created_by                        NUMBER,
      x_last_update_login                 NUMBER,
      x_object_version_number    IN OUT NOCOPY NUMBER
   )
   IS
      CURSOR c
      IS
         SELECT        *
                  FROM cn_rt_quota_asgns_all
                 WHERE rt_quota_asgn_id = x_rt_quota_asgn_id
         FOR UPDATE OF rt_quota_asgn_id NOWAIT;

      recinfo                       c%ROWTYPE;
   BEGIN
      OPEN c;

      FETCH c
       INTO recinfo;

      CLOSE c;

      x_object_version_number := NVL (recinfo.object_version_number, 1) + 1;

      UPDATE cn_rt_quota_asgns
         SET start_date = x_start_date,
             end_date = x_end_date,
             rate_schedule_id = x_rate_schedule_id,
             calc_formula_id = x_calc_formula_id,
             attribute_category = x_attribute_category,
             attribute1 = x_attribute1,
             attribute2 = x_attribute2,
             attribute3 = x_attribute3,
             attribute4 = x_attribute4,
             attribute5 = x_attribute5,
             attribute6 = x_attribute6,
             attribute7 = x_attribute7,
             attribute8 = x_attribute8,
             attribute9 = x_attribute9,
             attribute10 = x_attribute10,
             attribute11 = x_attribute11,
             attribute12 = x_attribute12,
             attribute13 = x_attribute13,
             attribute14 = x_attribute15,
             attribute15 = x_attribute15,
             last_update_date = x_last_update_date,
             last_updated_by = x_last_updated_by,
             last_update_login = x_last_update_login,
             object_version_number = x_object_version_number
       WHERE rt_quota_asgn_id = x_rt_quota_asgn_id;

      IF (SQL%NOTFOUND)
      THEN
         RAISE NO_DATA_FOUND;
      END IF;

      -- set complan status
      cn_comp_plans_pkg.set_status (x_comp_plan_id          => NULL,
                                    x_quota_id              => x_quota_id,
                                    x_rate_schedule_id      => NULL,
                                    x_status_code           => 'INCOMPLETE',
                                    x_event                 => 'CHANGE_TIERS'
                                   );

      -- srp rate assigns
      IF (x_rate_schedule_id <> recinfo.rate_schedule_id) OR (x_calc_formula_id <> recinfo.calc_formula_id)
      THEN
         cn_srp_rate_assigns_pkg.DELETE_RECORD (x_srp_plan_assign_id      => NULL,
                                                x_srp_rate_assign_id      => NULL,
                                                x_quota_id                => x_quota_id,
                                                x_rate_schedule_id        => recinfo.rate_schedule_id,
                                                x_rt_quota_asgn_id        => x_rt_quota_asgn_id,
                                                x_rate_tier_id            => NULL
                                               );
         -- Srp Rate Assigs
         cn_srp_rate_assigns_pkg.INSERT_RECORD (x_srp_plan_assign_id        => NULL,
                                                x_srp_quota_assign_id       => NULL,
                                                x_srp_rate_assign_id        => NULL,
                                                x_quota_id                  => x_quota_id,
                                                x_rate_schedule_id          => x_rate_schedule_id,
                                                x_rt_quota_asgn_id          => x_rt_quota_asgn_id,
                                                x_rate_tier_id              => NULL,
                                                x_commission_rate           => NULL,
                                                x_commission_amount         => NULL,
                                                x_disc_rate_table_flag      => NULL
                                               );
      END IF;
   -- Update Record
   END UPDATE_RECORD;

-- Procedure Name

   -- Delete_Record
  -- Purpose
  --  Logic yet to be discussed
  --
  --
--------------------------------------------------------------------------------+
--
-- Procedure Name Insert Record
--
--------------------------------------------------------------------------------+
   PROCEDURE INSERT_RECORD (
      x_calc_formula_id          IN       NUMBER,
      x_quota_id                 IN       NUMBER
   )
   IS
      CURSOR calc_edge_curs (
         l_parent_id                         NUMBER
      )
      IS
         SELECT DISTINCT child_id
                    FROM cn_calc_edges
                   WHERE edge_type = 'FE' AND parent_id IN (SELECT calc_sql_exp_id
                                                              FROM cn_formula_inputs
                                                             WHERE calc_formula_id = l_parent_id
                                                            UNION
                                                            SELECT output_exp_id
                                                              FROM cn_calc_formulas
                                                             WHERE calc_formula_id = l_parent_id);

      TYPE stack_type IS TABLE OF cn_calc_formulas.calc_formula_id%TYPE;

      l_stack                       stack_type;
      l_parent_calc_formula_id      cn_calc_formulas.calc_formula_id%TYPE;
      l_child_calc_formula_id       cn_calc_formulas.calc_formula_id%TYPE;

      CURSOR rt_quota_asgn_curs (
         l_calc_formula_id                   NUMBER,
         l_quota_id                          NUMBER
      )
      IS
         SELECT rt_quota_asgn_id
           FROM cn_rt_quota_asgns
          WHERE quota_id = l_quota_id AND calc_formula_id = l_calc_formula_id;

      l_rt_quota_asgn_id            cn_rt_quota_asgns.rt_quota_asgn_id%TYPE;
   BEGIN
      l_stack := stack_type (x_calc_formula_id);

      WHILE (l_stack.COUNT > 0)
      LOOP
         l_parent_calc_formula_id := l_stack (l_stack.LAST);
         l_stack.DELETE (l_stack.LAST);

          -- clku, bug 2812184, only insert if we have not seen this quota/formula
         -- combination before
         OPEN rt_quota_asgn_curs (l_parent_calc_formula_id, x_quota_id);

         FETCH rt_quota_asgn_curs
          INTO l_rt_quota_asgn_id;

         IF rt_quota_asgn_curs%NOTFOUND
         THEN
            insert_node_record (l_parent_calc_formula_id, x_quota_id);
         END IF;

         CLOSE rt_quota_asgn_curs;

         OPEN calc_edge_curs (l_parent_calc_formula_id);

         LOOP
            FETCH calc_edge_curs
             INTO l_child_calc_formula_id;

            IF calc_edge_curs%FOUND
            THEN
               l_stack.EXTEND;
               l_stack (l_stack.LAST) := l_child_calc_formula_id;
            ELSE
               EXIT;
            END IF;
         END LOOP;

         CLOSE calc_edge_curs;
      END LOOP;
   END INSERT_RECORD;

--------------------------------------------------------------------------------+
--
-- Procedure Name Insert Node Record
--
--------------------------------------------------------------------------------+
   PROCEDURE insert_node_record (
      x_calc_formula_id          IN       NUMBER,
      x_quota_id                 IN       NUMBER
   )
   IS
      -- Procedure is use to call for inserting the record when you insert or
      -- Update the Quotas. Called from CN_QUOTAS_PKG
      -- cn_rt_quota-assings is a batch insert
      -- insert the srp_rate_assigns
      CURSOR srp_rate_insert_curs
      IS
         SELECT quota_id,
                rate_schedule_id,
                rt_quota_asgn_id
           FROM cn_rt_quota_asgns_all
          WHERE quota_id = x_quota_id AND calc_formula_id = x_calc_formula_id;

      recinfo                       srp_rate_insert_curs%ROWTYPE;

      --clku
      CURSOR rate_formula_date_curs
      IS
         SELECT start_date,
                end_date,
                rate_schedule_id
           FROM cn_rt_formula_asgns_all
          WHERE calc_formula_id = x_calc_formula_id;

      rt_date                       rate_formula_date_curs%ROWTYPE;
      l_quota_start_date            DATE := NULL;
      l_quota_end_date              DATE := NULL;
      l_rt_start_date               DATE := NULL;
      l_rt_end_date                 DATE := NULL;
      l_start_date                  DATE := NULL;
      l_end_date                    DATE := NULL;
      l_org_id                      NUMBER;
   BEGIN
      --clku
      SELECT start_date,
             end_date,
             org_id
        INTO l_quota_start_date,
             l_quota_end_date,
             l_org_id
        FROM cn_quotas_all
       WHERE quota_id = x_quota_id;

      FOR rt_date IN rate_formula_date_curs
      LOOP
         l_rt_start_date := rt_date.start_date;
         l_rt_end_date := rt_date.end_date;
         -- bug 3602452 - reinitialize variables
         l_start_date := NULL;
         l_end_date := NULL;

         -- 4 cases to get the overlap of l_rt_dates and l_quota_dates
         IF (l_rt_end_date IS NULL AND l_quota_end_date IS NULL)
         THEN
            IF TRUNC (l_rt_start_date) >= TRUNC (l_quota_start_date)
            THEN
               l_start_date := l_rt_start_date;
            ELSE
               l_start_date := l_quota_start_date;
            END IF;

            l_end_date := NULL;
         ELSIF (l_rt_end_date IS NULL AND (TRUNC (l_quota_end_date) > TRUNC (l_rt_start_date)))
         THEN
            IF TRUNC (l_rt_start_date) >= TRUNC (l_quota_start_date)
            THEN
               l_start_date := l_rt_start_date;
            ELSE
               l_start_date := l_quota_start_date;
            END IF;

            l_end_date := l_quota_end_date;
         ELSIF (l_quota_end_date IS NULL AND (TRUNC (l_rt_end_date) > TRUNC (l_quota_start_date)))
         THEN
            IF TRUNC (l_rt_start_date) >= TRUNC (l_quota_start_date)
            THEN
               l_start_date := l_rt_start_date;
            ELSE
               l_start_date := l_quota_start_date;
            END IF;

            l_end_date := l_rt_end_date;
         ELSIF ((TRUNC (l_rt_end_date) > TRUNC (l_quota_start_date)) OR (TRUNC (l_quota_end_date) > TRUNC (l_rt_start_date)))
         THEN
            IF TRUNC (l_rt_start_date) >= TRUNC (l_quota_start_date)
            THEN
               l_start_date := l_rt_start_date;
            ELSE
               l_start_date := l_quota_start_date;
            END IF;

            IF TRUNC (l_rt_end_date) <= TRUNC (l_quota_end_date)
            THEN
               l_end_date := l_rt_end_date;
            ELSE
               l_end_date := l_quota_end_date;
            END IF;
         END IF;

         -- we only insert if there are overlap
         -- clku, fix the date not overlap issue
         IF ((l_start_date IS NOT NULL) AND (TRUNC (l_start_date) <= TRUNC (NVL (l_end_date, l_start_date))))
         THEN
            INSERT INTO cn_rt_quota_asgns_all
                        (rt_quota_asgn_id,
                         calc_formula_id,
                         quota_id,
                         start_date,
                         end_date,
                         rate_schedule_id,
                         org_id
                        )
               SELECT cn_rt_quota_asgns_s.NEXTVAL,
                      x_calc_formula_id,
                      x_quota_id,
                      l_start_date,
                      l_end_date,
                      rt_date.rate_schedule_id,
                      l_org_id
                 FROM DUAL;
         END IF;
      END LOOP;                                                                                          -- for rt_date in rate_formula_date_curs LOOP

      OPEN srp_rate_insert_curs;

      LOOP
         FETCH srp_rate_insert_curs
          INTO recinfo;

         EXIT WHEN srp_rate_insert_curs%NOTFOUND;
         -- insert srp rate assigns for each insert int the rt_quota_assigns
         cn_srp_rate_assigns_pkg.INSERT_RECORD (x_srp_plan_assign_id        => NULL,
                                                x_srp_quota_assign_id       => NULL,
                                                x_srp_rate_assign_id        => NULL,
                                                x_quota_id                  => recinfo.quota_id,
                                                x_rate_schedule_id          => recinfo.rate_schedule_id,
                                                x_rt_quota_asgn_id          => recinfo.rt_quota_asgn_id,
                                                x_rate_tier_id              => NULL,
                                                x_commission_rate           => NULL,
                                                x_commission_amount         => NULL,
                                                x_disc_rate_table_flag      => NULL
                                               );
      END LOOP;

      CLOSE srp_rate_insert_curs;
   END insert_node_record;

--------------------------------------------------------------------------------+
--
-- Procedure Name delete Record
--
--------------------------------------------------------------------------------+
   PROCEDURE DELETE_RECORD (
      x_quota_id                 IN       NUMBER,
      x_calc_formula_id          IN       NUMBER,
      x_rt_quota_asgn_id         IN       NUMBER
   )
   IS
      -- Procedure is use to call for deleting the record when you update the
      -- Called from CN_QUOTAS_PKG
      -- The folllowing query is re-written as two queries for fixing the
      -- sql perf bug # 4932376
      --  CURSOR srp_rate_assigns_delete IS
      --   SELECT quota_id,
      --          rate_schedule_id,
      --          calc_formula_id
      --     FROM cn_rt_quota_asgns
      --    WHERE rt_quota_asgn_id = NVL (x_rt_quota_asgn_id, rt_quota_asgn_id)
      --    AND quota_id = NVL (x_quota_id, quota_id);


      CURSOR srp_rate_assigns_delete
      IS
         SELECT quota_id,
                rate_schedule_id,
                calc_formula_id
           FROM cn_rt_quota_asgns
          WHERE rt_quota_asgn_id = x_rt_quota_asgn_id AND quota_id = quota_id;

      CURSOR srp_rate_assigns_delete1
      IS
         SELECT quota_id,
                rate_schedule_id,
                calc_formula_id
           FROM cn_rt_quota_asgns
          WHERE rt_quota_asgn_id =  rt_quota_asgn_id AND quota_id = x_quota_id;

      recinfo                       srp_rate_assigns_delete%ROWTYPE;
   BEGIN
      IF x_rt_quota_asgn_id IS NOT NULL
      THEN
         OPEN srp_rate_assigns_delete;

         LOOP
            FETCH srp_rate_assigns_delete
             INTO recinfo;

            EXIT WHEN srp_rate_assigns_delete%NOTFOUND;
            -- delete srp rate assigns for each insert int the rt_quota_assigns
            cn_srp_rate_assigns_pkg.DELETE_RECORD (x_srp_plan_assign_id      => NULL,
                                                   x_srp_rate_assign_id      => NULL,
                                                   x_quota_id                => recinfo.quota_id,
                                                   x_rate_schedule_id        => recinfo.rate_schedule_id,
                                                   x_rt_quota_asgn_id        => x_rt_quota_asgn_id,
                                                   x_rate_tier_id            => NULL
                                                  );
         END LOOP;

         CLOSE srp_rate_assigns_delete;

         DELETE FROM cn_rt_quota_asgns
               WHERE rt_quota_asgn_id = x_rt_quota_asgn_id;

         cn_comp_plans_pkg.set_status (x_comp_plan_id          => NULL,
                                       x_quota_id              => x_quota_id,
                                       x_rate_schedule_id      => NULL,
                                       x_status_code           => 'INCOMPLETE',
                                       x_event                 => 'CHANGE_TIERS'
                                      );
      ELSIF x_quota_id IS NOT NULL
      THEN
         OPEN srp_rate_assigns_delete1;

         LOOP
            FETCH srp_rate_assigns_delete1
             INTO recinfo;

            EXIT WHEN srp_rate_assigns_delete1%NOTFOUND;
            -- delete srp rate assigns for each insert int the rt_quota_assigns
            cn_srp_rate_assigns_pkg.DELETE_RECORD (x_srp_plan_assign_id      => NULL,
                                                   x_srp_rate_assign_id      => NULL,
                                                   x_quota_id                => recinfo.quota_id,
                                                   x_rate_schedule_id        => recinfo.rate_schedule_id,
                                                   x_rate_tier_id            => NULL
                                                  );
         END LOOP;

         CLOSE srp_rate_assigns_delete1;

         -- drp rt Quota Asgns
         DELETE FROM cn_rt_quota_asgns
               WHERE quota_id = x_quota_id;
      END IF;
   END DELETE_RECORD;

--------------------------------------------------------------------------------+
--
--                             PUBLIC ROUTINES
--
--------------------------------------------------------------------------------+
   PROCEDURE begin_record (
      x_org_id                            NUMBER,
      x_operation                         VARCHAR2,
      x_rowid                    IN OUT NOCOPY VARCHAR2,
      x_rt_quota_asgn_id         IN OUT NOCOPY NUMBER,
      x_calc_formula_id                   NUMBER,
      x_quota_id                          NUMBER,
      x_start_date                        DATE,
      x_end_date                          DATE,
      x_rate_schedule_id                  NUMBER,
      x_attribute_category                VARCHAR2,
      x_attribute1                        VARCHAR2,
      x_attribute2                        VARCHAR2,
      x_attribute3                        VARCHAR2,
      x_attribute4                        VARCHAR2,
      x_attribute5                        VARCHAR2,
      x_attribute6                        VARCHAR2,
      x_attribute7                        VARCHAR2,
      x_attribute8                        VARCHAR2,
      x_attribute9                        VARCHAR2,
      x_attribute10                       VARCHAR2,
      x_attribute11                       VARCHAR2,
      x_attribute12                       VARCHAR2,
      x_attribute13                       VARCHAR2,
      x_attribute14                       VARCHAR2,
      x_attribute15                       VARCHAR2,
      x_last_update_date                  DATE,
      x_last_updated_by                   NUMBER,
      x_creation_date                     DATE,
      x_created_by                        NUMBER,
      x_last_update_login                 NUMBER,
      x_program_type                      VARCHAR2,
      x_object_version_number    IN OUT NOCOPY NUMBER
   )
   IS
   BEGIN
      -- Saves passing it around
      g_program_type := x_program_type;
      g_temp_status_code := 'COMPLETE';                                                                            -- Assume it is good to begin with

      IF x_operation = 'INSERT'
      THEN
         INSERT_RECORD (x_org_id,
                        x_rowid,
                        x_rt_quota_asgn_id,
                        x_calc_formula_id,
                        x_quota_id,
                        x_start_date,
                        x_end_date,
                        x_rate_schedule_id,
                        x_attribute_category,
                        x_attribute1,
                        x_attribute2,
                        x_attribute3,
                        x_attribute4,
                        x_attribute5,
                        x_attribute6,
                        x_attribute7,
                        x_attribute8,
                        x_attribute9,
                        x_attribute10,
                        x_attribute11,
                        x_attribute12,
                        x_attribute13,
                        x_attribute14,
                        x_attribute15,
                        x_last_update_date,
                        x_last_updated_by,
                        x_creation_date,
                        x_created_by,
                        x_last_update_login,
                        x_object_version_number
                       );
      ELSIF x_operation = 'UPDATE'
      THEN
         UPDATE_RECORD (x_rt_quota_asgn_id,
                        x_calc_formula_id,
                        x_quota_id,
                        x_start_date,
                        x_end_date,
                        x_rate_schedule_id,
                        x_attribute_category,
                        x_attribute1,
                        x_attribute2,
                        x_attribute3,
                        x_attribute4,
                        x_attribute5,
                        x_attribute6,
                        x_attribute7,
                        x_attribute8,
                        x_attribute9,
                        x_attribute10,
                        x_attribute11,
                        x_attribute12,
                        x_attribute13,
                        x_attribute14,
                        x_attribute15,
                        x_last_update_date,
                        x_last_updated_by,
                        x_creation_date,
                        x_created_by,
                        x_last_update_login,
                        x_object_version_number
                       );
      ELSIF x_operation = 'DELETE'
      THEN
         DELETE_RECORD (x_quota_id, x_calc_formula_id, x_rt_quota_asgn_id);
      ELSIF x_operation = 'LOCK'
      THEN
         LOCK_RECORD (x_rowid, x_rt_quota_asgn_id, x_rate_schedule_id, x_start_date, x_end_date);
      END IF;
   END begin_record;
END cn_rt_quota_asgns_pkg;

/
