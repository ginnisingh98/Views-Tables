--------------------------------------------------------
--  DDL for Package Body OZF_TERR_LEVELS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_TERR_LEVELS_PVT" AS
/*$Header: ozfvtlvb.pls 120.2.12010000.2 2008/08/08 09:31:51 ateotia ship $*/
/*---------------------------------------------------------------------
-- PROCEDURE
--
--
-- HISTORY
--   03/07/00     mpande      Created.
--   07/12/2001   mpande      Updated .
--                            We want to delete the hierarchy and then recreate it after creation
--   11/04/2002   yzhao       change to ozf tables/views
--   06/09/2005   kdass       Bug 4415878 SQL Repository Fix - removed update_terr_levels as it is not used anywhere
--   01-Aug-2008  ateotia     Bug # 5723438 fixed.
--                            FP:11510-R12 5533277 - TERRITORY DETAIL'S END DATE IS NOT WORKING
---------------------------------------------------------------------
*/
   g_pkg_name   CONSTANT VARCHAR2 (30) := 'OZF_TERR_LEVELS_PVT';
   G_DEBUG      BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
   g_bulk_limit  CONSTANT NUMBER := 1000;  -- yzhao: Sep 8,2005 bulk fetch limit. It should get from profile.


   TYPE terrIdTbl       IS TABLE OF jtf_terr_all.terr_id%TYPE;


/*---------------------------------------------------------------------
-- PROCEDURE
--
--
-- HISTORY
--
--    this pacakage is called from the concurrent process manager
--    p_start_node_id: if specified, import territory level for that node
--                     if not specified, import all territory levels under Trade Management
--------------------------------------------------------------------------*/
   PROCEDURE create_terr_hierarchy (
      errbuf               OUT NOCOPY      VARCHAR2
     ,retcode              OUT NOCOPY      NUMBER
     ,p_start_node_id      IN       NUMBER
   ) IS
      x_return_status   VARCHAR2 (10);
      x_msg_data        VARCHAR2 (240);
      x_msg_count       NUMBER;
      x_index           NUMBER;
      l_hierarchy_id    NUMBER;
      l_start_node_id   NUMBER;

      -- Bug # 5723438 fixed by ateotia (+)
      /* CURSOR c_hier_exists (l_start_node_id IN NUMBER) IS
         SELECT DISTINCT heirarchy_id
                    FROM ozf_terr_levels_all
                   WHERE heirarchy_id = l_start_node_id; */
      -- Bug # 5723438 fixed by ateotia (-)
   BEGIN


      x_return_status            := fnd_api.g_ret_sts_success;
      ozf_utility_pvt.write_conc_log ('Import Territory Hierarchy: begin process');

      IF g_debug  THEN
         ozf_utility_pvt.debug_message ('create_terr_hierarchy: p_start_node_id=' || p_start_node_id);
      END IF;

      IF p_start_node_id IS NOT NULL THEN

          -- Bug # 5723438 fixed by ateotia (+)
          -- Removed the delete step, instead the records are inserted & then duplicates are removed later.
          /* OPEN c_hier_exists (p_start_node_id);
          FETCH c_hier_exists INTO l_start_node_id;

          -- if no hierarchy found then insert
          -- 07/13/2001 mpande if found then delete and recreate it .
          IF c_hier_exists%FOUND THEN
             CLOSE c_hier_exists;
             ozf_terr_levels_pvt.delete_terr_levels (
                p_api_version        => 1.0
               ,p_init_msg_list      => fnd_api.g_true
               ,p_commit             => fnd_api.g_false
               ,p_validation_level   => fnd_api.g_valid_level_full
               ,x_return_status      => x_return_status
               ,x_msg_data           => x_msg_data
               ,x_msg_count          => x_msg_count
               ,p_hierarchy_id       => l_start_node_id
             );

             IF x_return_status <> fnd_api.g_ret_sts_success THEN
                  ozf_utility_pvt.write_conc_log ('   Failed to delete existing levels for terr_id ' || l_start_node_id);
                  ---write all messages in the concurrent manager log
                  IF (x_msg_count > 0) THEN
                     FOR i IN 1 .. x_msg_count
                     LOOP
                        x_msg_data                 := fnd_msg_pub.get (i, fnd_api.g_false);
                        ozf_utility_pvt.write_conc_log (' delete_terr_levels returns error. Msg count='
                                                         || i
                                                         || '-'
                                                         || x_msg_data);
                     --DBMS_OUTPUT.put_line (   'message :' || x_msg_data);
                     END LOOP;
                  END IF;
                  RAISE fnd_api.g_exc_unexpected_error;
             END IF;
          ELSE
             CLOSE c_hier_exists; */

          -- Update active_flag to 'N' for all OZF Territories to identify the old territories.
          ozf_utility_pvt.write_conc_log ('Update active_flag to N for all OZF Territories to identify the old territories.');

          UPDATE ozf_terr_levels_all
          SET active_flag = 'N';

          ozf_utility_pvt.write_conc_log ('Territory Insertion Call');
          ozf_terr_levels_pvt.insert_terr_levels (
                    p_api_version        => 1.0
                   ,p_init_msg_list      => fnd_api.g_true
                   ,p_commit             => fnd_api.g_false
                   ,p_validation_level   => fnd_api.g_valid_level_full
                   ,x_return_status      => x_return_status
                   ,x_msg_data           => x_msg_data
                   ,x_msg_count          => x_msg_count
                   ,p_start_node_id      => p_start_node_id
          );
          -- END IF;
      ELSE
         -- Update active_flag to 'N' for all OZF Territories to identify the old territories.
         ozf_utility_pvt.write_conc_log ('Update active_flag to N for all OZF Territories to identify the old territories.');

         UPDATE ozf_terr_levels_all
         SET active_flag = 'N';

         ozf_utility_pvt.write_conc_log ('Bulk Territories Insertion Call');
	 -- Bug # 5723438 fixed by ateotia (-)

	 ozf_terr_levels_pvt.bulk_insert_terr_levels (
              p_api_version        => 1.0
             ,p_init_msg_list      => fnd_api.g_true
             ,p_commit             => fnd_api.g_false
             ,p_validation_level   => fnd_api.g_valid_level_full
             ,x_return_status      => x_return_status
             ,x_msg_data           => x_msg_data
             ,x_msg_count          => x_msg_count
         );
      END IF;    -- IF p_start_node_id IS NOT NULL THEN

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
          ozf_utility_pvt.write_conc_log ('   Failed to insert levels for terr_id ' || l_start_node_id);
          ---write all messages in the concurrent manager log
          IF (x_msg_count > 0) THEN
             FOR i IN 1 .. x_msg_count
             LOOP
                x_msg_data                 := fnd_msg_pub.get (i, fnd_api.g_false);
                ozf_utility_pvt.write_conc_log (' insert_terr_levels returns error. Msg count='
                                                 || i
                                                 || '-'
                                                 || x_msg_data);
             --DBMS_OUTPUT.put_line (   'message :' || x_msg_data);
             END LOOP;
          END IF;
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      ozf_utility_pvt.write_conc_log ('Import Territory Hierarchy: SUCCESS');
   EXCEPTION
      WHEN OTHERS THEN
         ozf_utility_pvt.write_conc_log ('Import Territory Hierarchy: EXCEPTION');
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false
           ,p_count=> x_msg_count
           ,p_data=> x_msg_data
         );
   END create_terr_hierarchy;


/*---------------------------------------------------------------------
-- PROCEDURE
--
--
-- HISTORY
--    03/07/00  mpande  Created.
-- this pacakage is called from the above create_terr_hier program
--------------------------------------------------------------------------*/
   PROCEDURE insert_terr_levels (
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,p_start_node_id      IN       NUMBER
   ) IS
      l_api_name      CONSTANT VARCHAR2 (30) := 'Insert_terr_levels';
      l_api_version   CONSTANT NUMBER        := 1.0;
      l_org_id                 NUMBER;
      l_insert_count           NUMBER;
      l_terr_level_id          NUMBER;
      l_terr_level             NUMBER;
      l_full_name     CONSTANT VARCHAR2 (60) :=    g_pkg_name
                                                || '.'
                                                || l_api_name;
      l_terr_id                NUMBER;
      l_terr_type_id           NUMBER;


-- Cursor for getting the org_id

      CURSOR org_csr IS
         SELECT NVL (SUBSTRB (USERENV ('CLIENT_INFO'), 1, 10), -99)
           FROM DUAL;

      CURSOR c_get_seq IS
         SELECT ozf_terr_levels_all_s.NEXTVAL
           FROM DUAL;


-- cursor to check uniqueness
      CURSOR c_terr_id (l_terr_id IN NUMBER) IS
         SELECT terr_id
               ,territory_type_id
           FROM jtf_terr_all jtf
          WHERE jtf.terr_id = l_terr_id
            AND jtf.parent_territory_id = 1;


-- cursor to check territory type exists for each territory
      CURSOR c_terr_type (l_terr_id IN NUMBER) IS
         SELECT territory_type_id
           FROM jtf_terr_all jtf
          WHERE jtf.terr_id = l_terr_id;

      CURSOR c_level_value (p_hierarchy_id IN NUMBER, p_terr_type_id IN NUMBER) IS
         SELECT olv.level_depth
           FROM ozf_terr_levels_all olv
          WHERE olv.heirarchy_id = p_hierarchy_id
            AND olv.terr_type_id = p_terr_type_id;


-- cursor to import territories
      CURSOR c_get_terr_levels (l_start_node_id NUMBER) IS
         SELECT DISTINCT creation_date
                        ,created_by
                        ,last_update_date
                        ,last_updated_by
                        ,last_update_login
                        ,program_application_id
                        ,program_id
                        ,program_update_date
                        ,request_id
                        ,territory_type_id
                        ,TO_NUMBER (LEVEL) level_depth
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
                        ,org_id
                        ,terr_id
                        ,parent_territory_id
			-- Bug # 5723438 fixed by ateotia (+)
			,end_date_active
                        ,name
                        ,enabled_flag
			-- Bug # 5723438 fixed by ateotia (-)
                    FROM jtf_terr_all

      -- 07/13/2001 mpande removed the where condition instead put a error message so that the user sets the
      -- territory type properly
--     WHERE  TERRITORY_TYPE_ID is not null
              CONNECT BY parent_territory_id = PRIOR terr_id
              START WITH terr_id = l_start_node_id;
   BEGIN
      SAVEPOINT insert_terr_levels;

      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status            := fnd_api.g_ret_sts_success;

      ozf_utility_pvt.write_conc_log('**********Start of Hierarchy Insert*******' );
      ozf_utility_pvt.write_conc_log('**********Territory Details *******' );

      -- API body
      -- check this for each record
      OPEN c_terr_id (p_start_node_id);
      FETCH c_terr_id INTO l_terr_id, l_terr_type_id;
      ozf_utility_pvt.write_conc_log('l_terr_id:=' || l_terr_id );
      ozf_utility_pvt.write_conc_log('l_terr_type_id:=' || l_terr_type_id );
      CLOSE c_terr_id;

      IF l_terr_id IS NULL THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_TERR_ID_NOT_FOUND');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      IF l_terr_type_id IS NULL THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_TERR_TYPE_ID_NOT_FOUND');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;


------------check for data integrity---------------------------
      FOR l_terr_level_rec IN c_get_terr_levels (p_start_node_id)
      LOOP
         -- check the territory type exists  for each record -- 07/13/2001 mpande
         -- initialize the variable
         l_terr_type_id             := NULL;
         OPEN c_terr_type (l_terr_level_rec.terr_id);
         FETCH c_terr_type INTO l_terr_type_id;
         CLOSE c_terr_type;

         IF l_terr_type_id IS NULL THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name ('OZF', 'OZF_TERR_TYPE_ID_NOT_FOUND');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         -- Record level validation
         ozf_utility_pvt.debug_message (   l_full_name
                                        || ': begin');

                 -- 07/13/2001 mpande added . We want ot purge all the hierarchy that was created for the territories that
              -- are now a part of this new hierarchy
         -- note no territory can be a part of 2 hierarchies
         IF l_terr_level_rec.terr_id <> p_start_node_id THEN
            DELETE FROM ozf_terr_levels_all
                  WHERE heirarchy_id = l_terr_level_rec.terr_id;
         END IF;

         --DBMS_OUTPUT.put_line ( 'TT:= '|| l_terr_level_rec.territory_type_id    || 'LD = ' || l_terr_level_rec.level_depth );
         -- 07/13/2001 mpande check that in the same hierarchy , terr_type do not appear in 2 diifernet levels
     l_terr_level := NULL;
         OPEN c_level_value (p_start_node_id, l_terr_level_rec.territory_type_id);
         FETCH c_level_value INTO l_terr_level;
         CLOSE c_level_value;

         --DBMS_OUTPUT.put_line (l_terr_level);

         -- Bug # 5723438 fixed by ateotia (+)
	 -- Commented not to check for level_depth while insertion
         /* IF      l_terr_level IS NOT NULL
             AND l_terr_level <> l_terr_level_rec.level_depth THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name ('OZF', 'OZF_TERR_TYPE_DUPLICATE_RECORD');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF; */
	 -- Bug # 5723438 fixed by ateotia (-)

         OPEN c_get_seq;
         FETCH c_get_seq INTO l_terr_level_id;
         CLOSE c_get_seq;

	 ozf_utility_pvt.write_conc_log('******* Insert into OZF Schema *******');
         INSERT INTO ozf_terr_levels_all
                     (terr_level_id
                     ,creation_date
                     ,created_by
                     ,last_update_date
                     ,last_updated_by
                     ,last_update_login
                     ,program_application_id
                     ,program_id
                     ,program_update_date
                     ,request_id
                     ,terr_type_id
                     ,level_depth
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
                     ,org_id
                     ,territory_id
                     ,parent_territory_id
                     ,object_version_number
                     ,heirarchy_id
		     -- Bug # 5723438 fixed by ateotia (+)
                     ,hierarchy_name
		     ,end_date_active
                     ,enabled_flag
		     -- Bug # 5723438 fixed by ateotia (-)
                     )
              VALUES (l_terr_level_id
                     ,SYSDATE
                     ,fnd_global.user_id
                     ,SYSDATE
                     ,fnd_global.user_id
                     ,fnd_global.conc_login_id
                     ,l_terr_level_rec.program_application_id
                     ,l_terr_level_rec.program_id
                     ,l_terr_level_rec.program_update_date
                     ,l_terr_level_rec.request_id
                     ,l_terr_level_rec.territory_type_id
                     ,l_terr_level_rec.level_depth
                     ,l_terr_level_rec.attribute1
                     ,l_terr_level_rec.attribute2
                     ,l_terr_level_rec.attribute3
                     ,l_terr_level_rec.attribute4
                     ,l_terr_level_rec.attribute5
                     ,l_terr_level_rec.attribute6
                     ,l_terr_level_rec.attribute7
                     ,l_terr_level_rec.attribute8
                     ,l_terr_level_rec.attribute9
                     ,l_terr_level_rec.attribute10
                     ,l_terr_level_rec.attribute11
                     ,l_terr_level_rec.attribute12
                     ,l_terr_level_rec.attribute13
                     ,l_terr_level_rec.attribute14
                     ,l_terr_level_rec.attribute15
                     ,l_org_id
                     ,l_terr_level_rec.terr_id
                     ,l_terr_level_rec.parent_territory_id
                     ,1
                     ,p_start_node_id
		     -- Bug # 5723438 fixed by ateotia (+)
		     ,l_terr_level_rec.name
		     ,l_terr_level_rec.end_date_active
                     ,l_terr_level_rec.enabled_flag
		     -- Bug # 5723438 fixed by ateotia (-)
                     );

         ozf_utility_pvt.write_conc_log('******* Delete Duplicates *******');
	 -- Bug # 5723438 fixed by ateotia (+)
	 DELETE from ozf_terr_levels_all
            WHERE active_flag = 'N'
            AND territory_id = l_terr_level_rec.terr_id
            AND parent_territory_id = l_terr_level_rec.parent_territory_id;
	 -- Bug # 5723438 fixed by ateotia (-)

         IF SQL%FOUND THEN
            l_insert_count             := SQL%ROWCOUNT;
            x_return_status            := fnd_api.g_ret_sts_success;
         END IF;

         x_return_status            := fnd_api.g_ret_sts_success;
      END LOOP;

      IF      fnd_api.to_boolean (p_commit)
          AND x_return_status = fnd_api.g_ret_sts_success THEN
         COMMIT;
      END IF;

      fnd_msg_pub.count_and_get (
         p_encoded=> fnd_api.g_false
        ,p_count=> x_msg_count
        ,p_data=> x_msg_data
      );
      ozf_utility_pvt.debug_message (   l_full_name
                                     || ': end');
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO insert_terr_levels;
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false
           ,p_count=> x_msg_count
           ,p_data=> x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO insert_terr_levels;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false
           ,p_count=> x_msg_count
           ,p_data=> x_msg_data
         );
      WHEN OTHERS THEN
         ROLLBACK TO insert_terr_levels;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false
           ,p_count=> x_msg_count
           ,p_data=> x_msg_data
         );
   END insert_terr_levels;


/*---------------------------------------------------------------------
-- PROCEDURE
--
--
-- HISTORY
--    09/21/05  yzhao  Created.
--    this pacakage is called from the above create_terr_hier program
--    to import all hierarchy levels defined under 'Trade Management'
--------------------------------------------------------------------------*/
   PROCEDURE bulk_insert_terr_levels (
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
   ) IS
      l_api_name      CONSTANT VARCHAR2 (30)                 := 'bulk_insert_terr_levels';
      l_api_version   CONSTANT NUMBER                        := 1.0;
      l_full_name     CONSTANT VARCHAR2 (60)                 :=    g_pkg_name
                                                                || '.'
                                                                || l_api_name;

      l_terrIDTbl     terrIdTbl;

      -- same as value set OZF_SRS_TERR_HIER_START_NODE used for concurrent program start node parameter
      CURSOR c_get_all_root_nodes IS
        SELECT JTR.TERR_ID
        FROM JTF_TERR_ALL JTR , JTF_TERR_USGS_ALL JTU , JTF_SOURCES_ALL JSE
        WHERE  JTU.TERR_ID = JTR.TERR_ID
          AND JTU.SOURCE_ID = JSE.SOURCE_ID
          AND JTU.SOURCE_ID = -1003
          AND JTR.PARENT_TERRITORY_ID = 1
          AND NVL(JTR.ORG_ID, -99) = NVL(JTU.ORG_ID, NVL(JTR.ORG_ID, -99))
          AND JSE.ORG_ID IS NULL
          AND JTR.TERRITORY_TYPE_ID IS NOT NULL
          AND NVL(JTR.ORG_ID, NVL(TO_NUMBER(DECODE(SUBSTR(USERENV('CLIENT_INFO'),1,1),' ' , NULL, SUBSTR(USERENV('CLIENT_INFO'),1,10))),-99)) =
          NVL(TO_NUMBER(DECODE(SUBSTR(USERENV('CLIENT_INFO'),1,1),' ', NULL, SUBSTR(USERENV('CLIENT_INFO'),1,10))),-99);

   BEGIN
     OPEN c_get_all_root_nodes;
     LOOP
         FETCH c_get_all_root_nodes BULK COLLECT INTO l_terrIdTbl LIMIT g_bulk_limit;
         FOR i IN NVL(l_terrIdTbl.FIRST, 1) .. NVL(l_terrIdTbl.LAST, 0) LOOP
             ozf_terr_levels_pvt.insert_terr_levels (
                    p_api_version        => 1.0
                   ,p_init_msg_list      => fnd_api.g_true
                   ,p_commit             => fnd_api.g_false
                   ,p_validation_level   => fnd_api.g_valid_level_full
                   ,x_return_status      => x_return_status
                   ,x_msg_data           => x_msg_data
                   ,x_msg_count          => x_msg_count
                   ,p_start_node_id      => l_terrIdTbl(i)
             );
             IF x_return_status <> fnd_api.g_ret_sts_success THEN
                ozf_utility_pvt.write_conc_log('   /****** Failed to bulk insert level for hier id ' || l_terrIdTbl(i));
             ELSE
                ozf_utility_pvt.debug_message('   D: ' || l_api_name || '   successfully insert levels for terr id' || l_terrIdTbl(i));
             END IF;
         END LOOP;  -- FOR i IN NVL(l_terrIdTbl.FIRST, 1) .. NVL(l_terrIdTbl.LAST, 0) LOOP

         EXIT WHEN c_get_all_root_nodes%NOTFOUND;
     END LOOP;  -- bulk fetch loop
   END bulk_insert_terr_levels;



/*---------------------------------------------------------------------
-- PROCEDURE
--
--
-- HISTORY
--    03/07/00  mpande  Created.
--------------------------------------------------------------------------*/

   PROCEDURE delete_terr_levels (
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,p_hierarchy_id       IN       NUMBER
   ) IS
      l_api_name      CONSTANT VARCHAR2 (30)                 := 'Delete_terr_levels';
      l_api_version   CONSTANT NUMBER                        := 1.0;
      l_org_id                 NUMBER;
      l_insert_count           NUMBER;
      l_terr_level_rec         ozf_terr_levels_all%ROWTYPE;
      l_full_name     CONSTANT VARCHAR2 (60)                 :=    g_pkg_name
                                                                || '.'
                                                                || l_api_name;
      l_terr_level_id          NUMBER;
      l_terr_count             NUMBER;

--cursor changed later because now once allocation is done to a heirarchy you cannot update the resord
 /* mpadne 07/13/2001 -- we will delete all records for that hierarhcy and recreate it
      CURSOR c_delete_terr (l_hierarchy_id IN NUMBER) IS
         SELECT *
           FROM ozf_terr_levels_all a
          WHERE a.heirarchy_id = l_hierarchy_id;
 */

   BEGIN
      SAVEPOINT delete_terr_levels;

      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status            := fnd_api.g_ret_sts_success;

      -- 07/13/2001 mpande delete the whole hierarchy structure to recreate it
      DELETE FROM ozf_terr_levels_all
            WHERE heirarchy_id = p_hierarchy_id;
       -- API body
      /*
       FOR l_terr_level_rec IN c_delete_terr (p_hierarchy_id)
       LOOP
          ozf_utility_pvt.debug_message (   l_full_name
                                         || ': begin');

          DELETE FROM ozf_terr_levels_all
                WHERE terr_level_id = l_terr_level_rec.terr_level_id;
       END LOOP;

       IF fnd_api.to_boolean (p_commit) THEN
          COMMIT;
       END IF;
       */

      fnd_msg_pub.count_and_get (
         p_encoded=> fnd_api.g_false
        ,p_count=> x_msg_count
        ,p_data=> x_msg_data
      );
      ozf_utility_pvt.debug_message (   l_full_name
                                     || ': end');
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO delete_terr_levels;
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false
           ,p_count=> x_msg_count
           ,p_data=> x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO delete_terr_levels;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false
           ,p_count=> x_msg_count
           ,p_data=> x_msg_data
         );
      WHEN OTHERS THEN
         ROLLBACK TO delete_terr_levels;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false
           ,p_count=> x_msg_count
           ,p_data=> x_msg_data
         );
   END delete_terr_levels;
END;

/
