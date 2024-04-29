--------------------------------------------------------
--  DDL for Package Body AMS_LIST_PURGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_PURGE_PVT" AS
/* $Header: amsvimcb.pls 120.5 2006/04/05 06:12:05 bmuthukr ship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30):='AMS_List_Purge_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='amsvimcb.pls';



/*****************************************************************************/
-- Procedure
--   Purge_Expired_List_Headers
--
-- Purpose
--   Purge imported list headers which is expired or has usage as 0 or less
--
-- Note
--
-- History
--   05/18/2001    yxliu      created
--   12/12/2001    yxliu      add logic to purge ams_list_entries
--                            add parameter force_purge_flag
--   01/10/2002    yxliu      add delete cancelled imp list headers
-------------------------------------------------------------------------------
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Purge_Expired_List_Headers
(
    force_purge_flag  IN VARCHAR2 := FND_API.g_false,
    x_return_status OUT NOCOPY   VARCHAR2,
    x_msg_count     OUT NOCOPY   NUMBER,
    x_msg_data      OUT NOCOPY   VARCHAR2
)
IS
   l_api_name      CONSTANT VARCHAR2(30)  := 'Purge_Expired_List_Headers';

   CURSOR c_all_imp_list_rec IS
   SELECT import_list_header_id, object_version_number,
          creation_date, expiry_date, usage
     FROM ams_imp_list_headers_all
    WHERE rented_list_flag = 'R'
      and status_code <> 'PURGED';

--   l_all_imp_list_rec c_all_imp_list_rec%ROWTYPE;

   l_import_list_header_id    NUMBER;
   l_object_version           NUMBER;
   l_creation_date            DATE;
   l_expiry_date              DATE;
   l_usage                    NUMBER;

   l_grace_date               DATE;
   l_lookup_code              VARCHAR2(30);
   l_arc_log_used_by          VARCHAR2(30) := 'IMPH';
   l_upd_status_code          VARCHAR2(30);

    CURSOR c_list_entries_rec_int (c_imp_header_id NUMBER) IS
    SELECT DISTINCT b.list_header_id
      FROM ams_list_select_actions a, ams_list_headers_all b
     WHERE a.incl_object_id = c_imp_header_id
       AND a.arc_incl_object_from = 'IMPH'
       AND a.action_used_by_id = b.list_header_id
       AND (b.list_type <> 'TARGET' OR b.status_code <> 'LOCKED');

    CURSOR c_list_entries_force_rec_int (c_imp_header_id NUMBER) IS
    SELECT DISTINCT b.list_header_id
      FROM ams_list_select_actions a, ams_list_headers_all b
     WHERE a.incl_object_id = c_imp_header_id
       AND a.arc_incl_object_from = 'IMPH'
       AND a.action_used_by_id = b.list_header_id;

    CURSOR c_list_entries_rec1 (c_imp_header_id NUMBER, c_list_header_id NUMBER) IS
    SELECT a.list_header_id, a.list_entry_id
      FROM ams_list_entries a, ams_imp_source_lines b
     WHERE a.list_header_id = c_list_header_id
       AND a.imp_source_line_id = b.import_source_line_id
       AND b.import_list_header_id = c_imp_header_id
     ORDER BY a.list_header_id;

   l_list_entries_rec c_list_entries_rec1%ROWTYPE;

    CURSOR c_list_entries_rec2 (c_list_header_id NUMBER, c_imp_header_id NUMBER, c_usage NUMBER) IS
    SELECT a.list_header_id, a.list_entry_id
      FROM ams_list_entries a, ams_imp_source_lines b
     WHERE a.list_header_id = c_list_header_id
       AND a.imp_source_line_id = b.import_source_line_id
       AND b.import_list_header_id = c_imp_header_id
       AND b.current_usage >= c_usage
     ORDER BY a.list_header_id;

   l_list_header_id_temp     NUMBER  := -1;
   l_list_size_temp          NUMBER  := 0;

   l_list_entry_tbl         t_rec_table;
   l_list_header_tbl        t_rec_table;
   l_list_size_tbl          t_rec_table;
   l_entry_iterator         NUMBER := 1;
   l_list_iterator          NUMBER := 0;

   l_force_purge_flag  VARCHAR2(1) := 'N'; -- default not to force purge

   CURSOR c_usage_rec ( p_imp_header_id NUMBER) IS
   SELECT current_usage
     FROM ams_imp_source_lines
    WHERE import_list_header_id = p_imp_header_id;

   CURSOR c_get_usr_status (p_lookup_code VARCHAR2) IS
   SELECT user_status_id
     FROM ams_user_statuses_b
    WHERE system_status_code = p_lookup_code
      AND system_status_type = 'AMS_IMPORT_STATUS';

   l_current_usage          NUMBER := null;
   l_status_id              NUMBER := 0;
   l_list_header_id         NUMBER;
BEGIN
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.Debug_Message(l_api_name||': Start ');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_lookup_code := 'PURGED';

  IF force_purge_flag = 'Y' THEN
     l_force_purge_flag := force_purge_flag;
  END IF;

  -- Get all import list headers
  FOR l_all_imp_list_rec IN c_all_imp_list_rec
  LOOP
     l_import_list_header_id := l_all_imp_list_rec.import_list_header_id;
     l_object_version := l_all_imp_list_rec.object_version_number;
     l_creation_date := l_all_imp_list_rec.creation_date;
     l_expiry_date := l_all_imp_list_rec.expiry_date;
     l_usage := l_all_imp_list_rec.usage;

     -- Create the Savepoint
     SAVEPOINT Purge_Expired_List_Header;

     IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_Utility_PVT.Debug_Message(l_api_name||': l_import_list_header_id:' || l_import_list_header_id );
     AMS_Utility_PVT.Debug_Message(l_api_name||': l_expiry_date:' || l_expiry_date );
     AMS_Utility_PVT.Debug_Message(l_api_name||': l_usage:' || l_usage );
     AMS_Utility_PVT.Debug_Message(l_api_name||': l_force_purge_flag:' || l_force_purge_flag );
     END IF;

     IF l_expiry_date IS NULL AND l_usage IS NULL THEN
        -- get grace period from profile, default 60
	l_grace_date := l_creation_date + NVL(fnd_profile.VALUE('AMS_BUDGET_ADJ_GRACE_PERIOD'), 60);

        IF l_grace_date <= SYSDATE THEN

           IF (AMS_DEBUG_HIGH_ON) THEN
             AMS_Utility_PVT.Debug_Message(l_api_name||': ' || l_import_list_header_id ||' grace period passed');
           END IF;

           -- Delete from ams_imp_source_lines
           IF (AMS_DEBUG_HIGH_ON) THEN
             AMS_Utility_PVT.debug_message(l_api_name||': delete from source lines');
           END IF;
           DELETE FROM ams_imp_source_lines
           WHERE import_list_header_id = l_import_list_header_id;
        END IF;
     ELSIF l_expiry_date IS NOT NULL AND l_expiry_date <= SYSDATE THEN

         IF (AMS_DEBUG_HIGH_ON) THEN
           AMS_Utility_PVT.Debug_Message(l_api_name||': ' || l_import_list_header_id ||' expiry date passed');
         END IF;

         -- Add logic to delete from ams_list_entries
         IF (AMS_DEBUG_HIGH_ON) THEN
           AMS_Utility_PVT.debug_message(l_api_name||': delete from list entries');
         END IF;

         IF l_force_purge_flag <> 'Y' THEN
            IF (AMS_DEBUG_HIGH_ON) THEN
              AMS_Utility_PVT.debug_message(l_api_name||': non force purge');
            END IF;
          OPEN c_list_entries_rec_int(l_import_list_header_id);
          LOOP
	    FETCH c_list_entries_rec_int INTO l_list_header_id;
	    EXIT WHEN c_list_entries_rec_int%NOTFOUND;

            OPEN c_list_entries_rec1(l_import_list_header_id,l_list_header_id);
            LOOP
               FETCH c_list_entries_rec1 INTO l_list_entries_rec;
               EXIT WHEN c_list_entries_rec1%NOTFOUND;

               l_list_entry_tbl(l_entry_iterator) := l_list_entries_rec.list_entry_id;
	       l_entry_iterator := l_entry_iterator + 1;

               IF l_list_header_id_temp = -1 THEN
                  l_list_header_id_temp := l_list_entries_rec.list_header_id;
                  l_list_size_temp := 1;
                  l_list_iterator :=  1;
               ELSIF l_list_entries_rec.list_header_id = l_list_header_id_temp THEN
                  l_list_size_temp := l_list_size_temp + 1;
               ELSE
                  l_list_header_tbl(l_list_iterator) := l_list_header_id_temp;
                  l_list_size_tbl(l_list_iterator) := l_list_size_temp;
                  l_list_iterator :=  l_list_iterator + 1;
                  l_list_header_id_temp := l_list_entries_rec.list_header_id;
                  l_list_size_temp := 1;
               END IF;
            END LOOP;
            CLOSE c_list_entries_rec1;
	  END LOOP;
	  CLOSE c_list_entries_rec_int;

            IF l_list_header_id_temp <> -1 THEN
               l_list_header_tbl(l_list_iterator) := l_list_header_id_temp;
               l_list_size_tbl(l_list_iterator) := l_list_size_temp;
            END IF;
         ELSE  -- force purge
            IF (AMS_DEBUG_HIGH_ON) THEN
              AMS_Utility_PVT.debug_message(l_api_name||': force purge expiry passed');
              AMS_Utility_PVT.debug_message(l_api_name||': force purge expiry passed l_import_list_header_id:'||l_import_list_header_id);
            END IF;

          OPEN c_list_entries_force_rec_int(l_import_list_header_id);
          LOOP
	    FETCH c_list_entries_force_rec_int INTO l_list_header_id;
	    EXIT WHEN c_list_entries_force_rec_int%NOTFOUND;

	    OPEN c_list_entries_rec1(l_import_list_header_id,l_list_header_id);
            LOOP
               FETCH c_list_entries_rec1 INTO l_list_entries_rec;
               EXIT WHEN c_list_entries_rec1%NOTFOUND;

               l_list_entry_tbl(l_entry_iterator) := l_list_entries_rec.list_entry_id;
	       l_entry_iterator := l_entry_iterator + 1;

               IF l_list_header_id_temp = -1 THEN
                  l_list_header_id_temp := l_list_entries_rec.list_header_id;
                  l_list_size_temp := 1;
                  l_list_iterator :=  1;
               ELSIF l_list_entries_rec.list_header_id = l_list_header_id_temp THEN
                  l_list_size_temp := l_list_size_temp + 1;
               ELSE
                  l_list_header_tbl(l_list_iterator) := l_list_header_id_temp;
                  l_list_size_tbl(l_list_iterator) := l_list_size_temp;
                  l_list_iterator :=  l_list_iterator + 1;
                  l_list_header_id_temp := l_list_entries_rec.list_header_id;
                  l_list_size_temp := 1;
               END IF;
            END LOOP;
            CLOSE c_list_entries_rec1;
	  END LOOP;
	  CLOSE c_list_entries_force_rec_int;

            IF l_list_header_id_temp <> -1 THEN
               l_list_header_tbl(l_list_iterator) := l_list_header_id_temp;
               l_list_size_tbl(l_list_iterator) := l_list_size_temp;
            END IF;
         END IF;

         IF (AMS_DEBUG_HIGH_ON) THEN
           AMS_Utility_PVT.debug_message(l_api_name||': bulk update on entries');
           AMS_Utility_PVT.debug_message('After collecting the data l_entry_iterator:'||l_entry_iterator);
           AMS_Utility_PVT.debug_message('After collecting the data l_list_entry_tbl.count:'||l_list_entry_tbl.count);
         END IF;

         -- Do bulk delete from list entries
         IF l_entry_iterator > 1 THEN
            FORALL i IN l_list_entry_tbl.first .. l_list_entry_tbl.last
               DELETE FROM ams_list_entries
                WHERE  list_entry_id = l_list_entry_tbl(i);
         END IF;

         IF (AMS_DEBUG_HIGH_ON) THEN
           AMS_Utility_PVT.debug_message(l_api_name||': bulk update on list headers');
         END IF;
         -- Do bulk update on list headers
         --IF l_list_iterator > 0 THEN
         IF l_list_size_tbl.last > 0
         THEN
            FORALL i IN l_list_size_tbl.first .. l_list_size_tbl.last
              UPDATE ams_list_headers_all
                 SET (no_of_rows_in_list
                   , no_of_rows_active
                   , last_update_date )=(select count(1),
                                        sum(decode(enabled_flag,'Y',1,0)),
                                        sysdate
                                        from ams_list_entries
                                        where list_header_id = l_list_header_tbl(i) )
               WHERE list_header_id = l_list_header_tbl(i);
         END IF;

         -- Delete from ams_imp_source_lines
         DELETE FROM ams_imp_source_lines
          WHERE import_list_header_id = l_import_list_header_id;
         IF (AMS_DEBUG_HIGH_ON) THEN
           AMS_Utility_PVT.debug_message(l_api_name||': force purge expiry_date passed count of ams_imp_source_lines_deleted:'||sql%rowcount);
         END IF;

         -- Delete from ams_party_sources
         DELETE FROM ams_party_sources
          WHERE import_list_header_id = l_import_list_header_id
            AND used_flag = 'N';
         IF (AMS_DEBUG_HIGH_ON) THEN
           AMS_Utility_PVT.debug_message(l_api_name||': force purge expiry_date passed count of ams_party_sources:'||sql%rowcount);
         END IF;
     ELSIF l_usage IS NOT NULL THEN  -- check usage
         IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.Debug_Message(l_api_name||': ' || l_import_list_header_id || ': usage is ' ||l_usage);
         END IF;

         -- Add logic to delete from ams_list_entries
         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message(l_api_name||': delete from list entries:' || l_force_purge_flag);
         END IF;

         IF l_force_purge_flag <> 'Y' THEN
	       IF (AMS_DEBUG_HIGH_ON) THEN
                 AMS_Utility_PVT.debug_message(l_api_name||': non force purge');
               END IF;

            OPEN c_list_entries_rec_int(l_import_list_header_id);
	    LOOP
	       FETCH c_list_entries_rec_int INTO l_list_header_id;
	       EXIT WHEN c_list_entries_rec_int%NOTFOUND;
	       OPEN c_list_entries_rec2(l_list_header_id, l_import_list_header_id, l_usage);
               LOOP
                  FETCH c_list_entries_rec2 INTO l_list_entries_rec;
                  EXIT WHEN c_list_entries_rec2%NOTFOUND;
                  l_list_entry_tbl(l_entry_iterator) := l_list_entries_rec.list_entry_id;
	          l_entry_iterator := l_entry_iterator + 1;

                  IF l_list_header_id_temp = -1 THEN
                     l_list_header_id_temp := l_list_entries_rec.list_header_id;
                     l_list_size_temp := 1;
                     l_list_iterator :=  1;
                  ELSIF l_list_entries_rec.list_header_id = l_list_header_id_temp THEN
                     l_list_size_temp := l_list_size_temp + 1;
                  ELSE
                     l_list_header_tbl(l_list_iterator) := l_list_header_id_temp;
                     l_list_size_tbl(l_list_iterator) := l_list_size_temp;
                     l_list_iterator :=  l_list_iterator + 1;
                     l_list_header_id_temp := l_list_entries_rec.list_header_id;
                     l_list_size_temp := 1;
                  END IF;
               END LOOP;
               CLOSE c_list_entries_rec2;
             END LOOP;
	     CLOSE c_list_entries_rec_int;

               IF l_list_header_id_temp <> -1 THEN
                  l_list_header_tbl(l_list_iterator) := l_list_header_id_temp;
                  l_list_size_tbl(l_list_iterator) := l_list_size_temp;
               END IF;
         ELSE
               IF (AMS_DEBUG_HIGH_ON) THEN
                 AMS_Utility_PVT.debug_message(l_api_name||': usage is not null and force purge');
               END IF;

             OPEN c_list_entries_force_rec_int(l_import_list_header_id);
             LOOP
  	       FETCH c_list_entries_force_rec_int INTO l_list_header_id;
	       EXIT WHEN c_list_entries_force_rec_int%NOTFOUND;

	       OPEN c_list_entries_rec2(l_list_header_id, l_import_list_header_id, l_usage);
               LOOP
                  FETCH c_list_entries_rec2 INTO l_list_entries_rec;
                  EXIT WHEN c_list_entries_rec2%NOTFOUND;

                  l_list_entry_tbl(l_entry_iterator) := l_list_entries_rec.list_entry_id;
	          l_entry_iterator := l_entry_iterator + 1;

                  IF l_list_header_id_temp = -1 THEN
                     l_list_header_id_temp := l_list_entries_rec.list_header_id;
                     l_list_size_temp := 1;
                  ELSIF l_list_entries_rec.list_header_id = l_list_header_id_temp THEN
                     l_list_size_temp := l_list_size_temp + 1;
                  ELSE
                     l_list_header_tbl(l_list_iterator) := l_list_header_id_temp;
                     l_list_size_tbl(l_list_iterator) := l_list_size_temp;
                     l_list_iterator :=  l_list_iterator + 1;
                     l_list_header_id_temp := l_list_entries_rec.list_header_id;
                     l_list_size_temp := 1;
                  END IF;
               END LOOP;
               CLOSE c_list_entries_rec2;
	     END LOOP;
	     CLOSE c_list_entries_force_rec_int;

               IF l_list_header_id_temp <> -1 THEN
                  l_list_header_tbl(l_list_iterator) := l_list_header_id_temp;
                  l_list_size_tbl(l_list_iterator) := l_list_size_temp;
               END IF;
         END IF;
         -- Do bulk delete from list entries
         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message(l_api_name||': l_entry_iterator=' || l_entry_iterator);
            AMS_Utility_PVT.debug_message(l_api_name||': l_list_entry_tbl.count=' || l_list_entry_tbl.count);
         END IF;
         IF l_entry_iterator > 1 THEN
            FORALL i IN l_list_entry_tbl.first .. l_list_entry_tbl.last
               DELETE FROM ams_list_entries
                WHERE  list_entry_id = l_list_entry_tbl(i);
         END IF;
         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message(l_api_name||': bulk update on list headers');
         END IF;
         IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_Utility_PVT.debug_message(l_api_name||': l_list_size_tbl.last=' || l_list_size_tbl.last);
         END IF;
            -- Do bulk update on list headers
            --IF l_list_iterator > 0 THEN
            IF l_list_size_tbl.last > 0 THEN
              FORALL i IN l_list_size_tbl.first .. l_list_size_tbl.last
                UPDATE ams_list_headers_all
                   SET (no_of_rows_in_list
                     , no_of_rows_active
                     , last_update_date )=(select count(1),
                                        sum(decode(enabled_flag,'Y',1,0)),
                                        sysdate
                                        from ams_list_entries
                                        where list_header_id = l_list_header_tbl(i) )
                WHERE list_header_id = l_list_header_tbl(i);
            END IF;

         IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_Utility_PVT.debug_message(l_api_name||': deleting from ams_party_sources');
         END IF;

         -- Delete from ams_party_sources
         DELETE FROM ams_party_sources
         WHERE used_flag = 'N'
         AND import_source_line_id IN (
             SELECT import_source_line_id
             FROM ams_imp_source_lines
             WHERE import_list_header_id = l_import_list_header_id
             AND current_usage >= l_usage);
         IF (AMS_DEBUG_HIGH_ON) THEN
           AMS_Utility_PVT.debug_message(l_api_name||': count of ams_party_sources deleted:'||sql%rowcount);
         END IF;

            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_Utility_PVT.debug_message(l_api_name||': deleting from ams_imp_source_lines');
            END IF;

         -- Delete from ams_imp_source_lines
         DELETE FROM ams_imp_source_lines
         WHERE import_list_header_id = l_import_list_header_id
         AND current_usage >= l_usage;

     END IF;

     IF (AMS_DEBUG_HIGH_ON) THEN
           AMS_Utility_PVT.debug_message(l_api_name||': count of ams_imp_source_lines deleted:'||sql%rowcount);
          AMS_Utility_PVT.Debug_Message(l_api_name||': Delete log and update ams_imp_list_headers_all ');
     END IF;

     OPEN C_get_usr_status(l_lookup_code);
     FETCH C_get_usr_status INTO l_status_id;
     CLOSE C_get_usr_status;

     l_upd_status_code := NULL;
     -- Update ams_imp_list_headers_all, only when all the lines are purged.
     UPDATE ams_imp_list_headers_all a
         SET status_code = l_lookup_code,
	     user_status_id = l_status_id,
             status_date = SYSDATE,
             object_version_number = l_object_version + 1,
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id
       WHERE a.import_list_header_id = l_import_list_header_id
         AND a.object_version_number = l_object_version
         AND NOT EXISTS (
             SELECT import_source_line_id
             FROM ams_imp_source_lines b
             WHERE b.import_list_header_id = a.import_list_header_id)
       RETURNING status_code INTO l_upd_status_code;

     IF (AMS_DEBUG_HIGH_ON) THEN
          AMS_Utility_PVT.Debug_Message(l_api_name||': l_upd_status_code=' || l_upd_status_code);
     END IF;
     IF l_upd_status_code = l_lookup_code
     THEN
          -- Delete from ams_act_logs
          DELETE FROM ams_act_logs
           WHERE arc_act_log_used_by = l_arc_log_used_by
             AND act_log_used_by_id = l_import_list_header_id;
     IF (AMS_DEBUG_HIGH_ON) THEN
           AMS_Utility_PVT.debug_message(l_api_name||': count of ams_act_logs deleted:'||sql%rowcount);
     END IF;
     END IF;

   COMMIT WORK; --commit after every import header purge

  --Reset all temp vars/tabs
   l_list_header_id_temp := -1;
   l_list_size_temp      := 0;

   l_list_entry_tbl.delete;
   l_list_header_tbl.delete;
   l_list_size_tbl.delete;
   l_entry_iterator      := 1;
   l_list_iterator       := 0;

   END LOOP;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.Debug_Message(l_api_name||': Delete cancelld imp list headers ');

   END IF;
   DELETE FROM ams_imp_list_headers_all
    WHERE status_code  = 'CANCELLED';

   -- If no errors, commit the work
   COMMIT WORK;
   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.Debug_Message(l_api_name||': End ');
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.Debug_Message(l_api_name||' failed on ' ||l_import_list_header_id );
      AMS_Utility_PVT.Debug_Message(l_api_name|| SQLERRM||'-'||SQLCODE);

      END IF;
      IF (c_all_imp_list_rec%ISOPEN) THEN
         CLOSE c_all_imp_list_rec;
      END IF;
      ROLLBACK TO Purge_Expired_List_Header;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_IMP_ERR_PURGE');
         FND_MSG_PUB.add;
      END IF;

END Purge_Expired_List_Headers;

/*****************************************************************************/
-- Procedure
--   Purge_List_Import
--
-- Purpose
--   This procedure is created to as a concurrent program which
--   will call the Purge_Expired_List_Headers and will return errors if any
--
-- Notes
--
--
-- History
--   05/18/2001      yxliu    created
------------------------------------------------------------------------------

PROCEDURE Purge_List_Import
(
    errbuf        OUT NOCOPY    VARCHAR2,
    retcode       OUT NOCOPY    NUMBER,
    force_purge_flag in VARCHAR2 := FND_API.G_FALSE
)
IS
   l_return_status    VARCHAR2(1) ;
   l_msg_count        NUMBER ;
   l_msg_data         VARCHAR2(2000);
BEGIN

   FND_MSG_PUB.initialize;
   -- Call the procedure to purge expired list headers

   Purge_Expired_List_Headers
   (   force_purge_flag => force_purge_flag,
       x_return_status   =>  l_return_status,
       x_msg_count       =>  l_msg_count,
       x_msg_data        =>  l_msg_data);

   -- Write_log ;
   Ams_Utility_Pvt.Write_Conc_log ;
   IF(l_return_status = FND_API.G_RET_STS_SUCCESS)THEN
      retcode := 0;
   ELSE
      retcode := 1;
      errbuf := l_msg_data ;
   END IF;
END Purge_List_Import;

/*****************************************************************************/
-- Procedure
--   Purge_Purged_Target
--
-- Purpose
--   Purge target group list headers which has purge_flag = Y and
--   send_out_date has passed
--
-- Note
--
-- History
--   05/21/2001    yxliu      created
-------------------------------------------------------------------------------
PROCEDURE Purge_Purged_Target
(
    x_return_status OUT NOCOPY   VARCHAR2,
    x_msg_count     OUT NOCOPY   NUMBER,
    x_msg_data      OUT NOCOPY   VARCHAR2
)
IS
   l_api_name      CONSTANT VARCHAR2(30)  := 'Purge_Purged_Target';

   CURSOR c_all_target_rec(p_list_type in VARCHAR2, p_list_status in VARCHAR2)
       IS
   SELECT list_header_id, status_code, object_version_number, purge_flag,
          sent_out_date
     FROM ams_list_headers_all
    WHERE list_type = p_list_type
      AND upper(status_code) <> p_list_status;


    CURSOR c_get_user_status_id ( c_status_code in varchar2) IS
SELECT user_status_id
       FROM ams_user_statuses_vl
       WHERE system_status_type = 'AMS_LIST_STATUS'
       AND system_status_code = c_status_code
       AND enabled_flag = 'Y'
       AND default_flag = 'Y';

   l_all_target_rec c_all_target_rec%ROWTYPE;

   l_list_header_id           NUMBER;
   l_purge_flag               VARCHAR2(1);
   l_sent_out_date            DATE;
   l_object_version           NUMBER;
   l_list_status              VARCHAR2(30);
   l_user_status_id           NUMBER;

   l_grace_date               DATE;
   l_lookup_type              VARCHAR2(30);
   l_lookup_status            VARCHAR2(30);

   l_return_status            VARCHAR2(1);
   l_msg_count                NUMBER;
   l_msg_data                 VARCHAR2(2000);

BEGIN
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.Debug_Message(l_api_name||' Start ');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- get lookup_code for type 'TARGET'
  l_lookup_type := null;
  SELECT lookup_code INTO l_lookup_type
    FROM ams_lookups
   WHERE lookup_type = 'AMS_LIST_TYPE'
     AND lookup_code = 'TARGET';

  -- get lookup_code for status 'ARCHIVED'
  l_lookup_status := null;
  SELECT lookup_code INTO l_lookup_status
    FROM ams_lookups
   WHERE lookup_type = 'AMS_LIST_STATUS'
     AND lookup_code = 'ARCHIVED';



  -- Get all target group list headers
  OPEN c_all_target_rec(l_lookup_type, l_lookup_status);
  LOOP
     FETCH c_all_target_rec INTO l_all_target_rec;
     EXIT WHEN c_all_target_rec%NOTFOUND;

     l_list_header_id := l_all_target_rec.list_header_id;
     l_list_status := l_all_target_rec.status_code;
     l_purge_flag := l_all_target_rec.purge_flag;
     l_sent_out_date := l_all_target_rec.sent_out_date;
     l_object_version := l_all_target_rec.object_version_number;

     -- Create the Savepoint
     SAVEPOINT Purge_Purged_Target;

     --IF l_purge_flag = 'Y' THEN -- No need to consider purge flag.

        IF l_sent_out_date is NOT NULL THEN

           -- get grace period from profile, default 30
           l_grace_date := l_sent_out_date +
                       NVL(fnd_profile.VALUE('AMS_BUDGET_ADJ_GRACE_PERIOD'), 180); --should be defaulted to 180.
           IF SYSDATE >= l_grace_date THEN
              IF (AMS_DEBUG_HIGH_ON) THEN

              AMS_Utility_PVT.Debug_Message(l_api_name||' Purge list header ID ' || l_list_header_id);
              END IF;
              -- Delete from ams_list_entries
              DELETE FROM ams_list_entries
               WHERE list_header_id = l_list_header_id;

	        -- initialize any default values

              --Should set the values for the summary cols to zero. there wont be any entries in the list entries table.
              /*
	      -- Update ams_list_headers_all
              UPDATE ams_list_headers_all
                 SET (no_of_rows_in_list
                   , no_of_rows_active
		   , NO_OF_ROWS_DUPLICATES
		   , NO_OF_ROWS_INACTIVE
                   , last_update_date )=(select count(1),
                                        sum(decode(enabled_flag,'Y',1,0)),
					sum(decode(marked_as_duplicate_flag,'Y',1,0)),
					sum(decode(enabled_flag,'Y',0,1)),
                                        sysdate
                                        from ams_list_entries
                                        where list_header_id = l_list_header_id)

               WHERE list_header_id = l_list_header_id;*/


	      OPEN c_get_user_status_id (l_lookup_status);
	      FETCH c_get_user_status_id  INTO l_user_status_id;
	      CLOSE c_get_user_status_id ;

              UPDATE ams_list_headers_all
                 SET no_of_rows_in_list           = 0,
                     no_of_rows_active            = 0,
                     no_of_rows_inactive          = 0,
                     no_of_rows_in_ctrl_group     = 0,
                     no_of_rows_random            = 0,
                     no_of_rows_duplicates        = 0,
                     no_of_rows_manually_entered  = 0,
                     no_of_rows_suppressed        = 0,
                     no_of_rows_fatigued          = 0,
                     tca_failed_records           = 0,
	             no_of_rows_initially_selected= 0,
   		     object_version_number = l_object_version + 1,
                     status_code = l_lookup_status,
		     user_status_id = l_user_status_id,
                     status_date = SYSDATE,
                     archived_by = FND_GLOBAL.user_id,
                     archived_date = SYSDATE,
                     last_update_date = SYSDATE,
                     last_updated_by = FND_GLOBAL.user_id
               WHERE list_header_id = l_list_header_id;
           END IF; -- if sysdate >= l_grace_date
        END IF; -- if l_sent_out_date is not null
    -- END IF; -- if l_purged_flag = y

     -- If no errors, commit the work
     COMMIT WORK;

  END LOOP;
  CLOSE c_all_target_rec;

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_Utility_PVT.Debug_Message(l_api_name||' End ');

  END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF (c_all_target_rec%ISOPEN) THEN
         CLOSE c_all_target_rec;
      END IF;
      ROLLBACK TO Purge_Purged_Target;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_IMP_ERR_PURGE');
         FND_MSG_PUB.add;
      END IF;

END Purge_Purged_Target;

/*****************************************************************************/
-- Procedure
--   Purge_Target_Group
--
-- Purpose
--   This procedure is created to as a concurrent program which
--   will call the Purge_Purged_Target and will return errors if any
--
-- Notes
--
--
-- History
--   05/21/2001      yxliu    created
------------------------------------------------------------------------------

PROCEDURE Purge_Target_Group
(   errbuf        OUT NOCOPY    VARCHAR2,
    retcode       OUT NOCOPY    NUMBER
)
IS
   l_return_status    VARCHAR2(1) ;
   l_msg_count        NUMBER ;
   l_msg_data         VARCHAR2(2000);
BEGIN

   FND_MSG_PUB.initialize;
   -- Call the procedure to purge purged target

   Purge_Purged_Target
   (   x_return_status   =>  l_return_status,
       x_msg_count       =>  l_msg_count,
       x_msg_data        =>  l_msg_data);

   -- Write_log ;
   Ams_Utility_Pvt.Write_Conc_log ;
   IF(l_return_status = FND_API.G_RET_STS_SUCCESS)THEN
      retcode := 0;
   ELSE
      retcode := 1;
      errbuf := l_msg_data ;
   END IF;
END Purge_Target_Group;

/*****************************************************************************/
-- Procedure
--   Increase_Usage
--
-- Purpose
--   increase usage of related source lines by 1
--
-- Note
--
-- History
--   12/13/2001    yxliu      created
-------------------------------------------------------------------------------
PROCEDURE Increase_Usage
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
    p_commit            IN  VARCHAR2  := FND_API.g_false,
    p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

    x_return_status     OUT NOCOPY   VARCHAR2,
    x_msg_count         OUT NOCOPY   NUMBER,
    x_msg_data          OUT NOCOPY   VARCHAR2,
    p_list_header_id    IN    NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Increase_Usage';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   CURSOR c_source_line_rec(p_list_header_id IN NUMBER) IS
   SELECT lines.import_source_line_id, lines.object_version_number,
          lines.current_usage
     FROM ams_imp_source_lines lines, ams_list_entries entries
    WHERE entries.list_header_id = p_list_header_id
	AND ENTRIES.enabled_flag = 'Y'
      AND lines.import_source_line_id = entries.imp_source_line_id;

   l_source_line_rec c_source_line_rec%ROWTYPE;

   l_source_line_id_tbl         t_rec_table;
   l_current_usage_tbl          t_rec_table;
   l_object_version_tbl         t_rec_table;
   l_iterator                  NUMBER := 1;

BEGIN

  SAVEPOINT increase_usage;

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_Utility_PVT.Debug_Message(l_full_name||': Start ');

  END IF;

  IF FND_API.to_boolean(p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.compatible_api_call(
        l_api_version,
        p_api_version,
        l_api_name,
        g_pkg_name
  ) THEN
     RAISE FND_API.g_exc_unexpected_error;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get all related source line ids
  OPEN c_source_line_rec(p_list_header_id);
  LOOP
     FETCH c_source_line_rec INTO l_source_line_rec;
     EXIT WHEN c_source_line_rec%NOTFOUND;

     l_source_line_id_tbl(l_iterator) := l_source_line_rec.import_source_line_id;
     l_object_version_tbl(l_iterator) := l_source_line_rec.object_version_number + 1;
     IF l_source_line_rec.current_usage IS NOT NULL THEN
        l_current_usage_tbl(l_iterator) := l_source_line_rec.current_usage + 1;
     ELSE
        l_current_usage_tbl(l_iterator) := 1;
     END IF;

     l_iterator := l_iterator + 1;
  END LOOP;
  CLOSE c_source_line_rec;

  IF l_iterator > 1 THEN
     FORALL i IN l_source_line_id_tbl.first .. l_source_line_id_tbl.last
        UPDATE ams_imp_source_lines SET
               current_usage = l_current_usage_tbl(i)
             , object_version_number = l_object_version_tbl(i)
             , last_update_date = SYSDATE
             , last_updated_by = FND_GLOBAL.user_id
             , last_update_login = FND_GLOBAL.conc_login_id
         WHERE import_source_line_id = l_source_line_id_tbl(i);
  END IF;

  IF FND_API.to_boolean(p_commit) THEN
     COMMIT;
  END IF;

  FND_MSG_PUB.count_and_get(
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
  );

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_Utility_PVT.debug_message(l_full_name ||': end');

  END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_Pvt.Debug_Message('Error in increase usage '|| sqlerrm);
      END IF;

      IF(c_source_line_rec%ISOPEN)then
         CLOSE c_source_line_rec;
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
          p_encoded         =>      FND_API.G_FALSE
        );

END Increase_Usage;

PROCEDURE delete_list_info(p_id_tbl IN ams_list_purge_pvt.l_id_tbl%type,
                           x_return_status           OUT NOCOPY VARCHAR2,
                           x_msg_count               OUT NOCOPY NUMBER,
                           x_msg_data                OUT NOCOPY VARCHAR2) is
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FORALL i in  1 .. p_id_tbl.count
   DELETE from ams_act_logs
    WHERE act_log_used_by_id = p_id_tbl(i);

   FORALL i in  1 .. p_id_tbl.count
   DELETE from ams_list_select_actions
    WHERE action_used_by_id = p_id_tbl(i);

   FORALL i in  1 .. p_id_tbl.count
   DELETE from ams_list_rule_usages
    WHERE list_header_id  = p_id_tbl(i);

   FORALL i in  1 .. p_id_tbl.count
   DELETE from ams_query_condition_value value
    WHERE EXISTS (SELECT 1
                    FROM ams_query_temp_inst_cond_assoc assoc,
                         ams_query_template_instance inst
                   WHERE assoc.template_instance_id = inst.template_instance_id
                     AND value.assoc_id = assoc.assoc_id
                     AND inst.instance_used_by_id = p_id_tbl(i));

   FORALL i in  1 .. p_id_tbl.count
   DELETE from AMS_QUERY_TEMP_INST_COND_ASSOC assoc
    WHERE EXISTS (SELECT 1
                    FROM ams_query_template_instance inst
                   WHERE assoc.template_instance_id = inst.template_instance_id
                     AND inst.instance_used_by_id = p_id_tbl(i));

   FORALL i in  1 .. p_id_tbl.count
   DELETE from ams_query_template_instance
    WHERE instance_used_by_id = p_id_tbl(i);

   UPDATE ams_query_template_all qt
      SET in_use_flag = 'N'
    WHERE NOT EXISTS (SELECT 1
   	                FROM ams_query_template_instance inst
                       WHERE qt.template_id = inst.template_id
			 AND inst.instance_used_by_id is not null);


   UPDATE ams_query_condition cond
      SET condition_in_use_flag = 'N'
    WHERE NOT EXISTS (SELECT 1
                        FROM ams_query_template_instance inst
    		       WHERE cond.template_id = inst.template_id
  		         AND inst.instance_used_by_id is not null);

   FORALL i in  1 .. p_id_tbl.count
   DELETE from ams_list_headers_all
    WHERE list_header_id = p_id_tbl(i);

EXCEPTION
   WHEN others then
      x_return_status := 'E';
      x_msg_count := 1;
      x_msg_data := sqlcode||'  '||sqlerrm;
      raise;
END delete_list_info;

--bmuthukr added delete_list_manager and delete_list_worker procedures
--for bug 5095777.
PROCEDURE delete_list_manager (x_errbuf         OUT NOCOPY VARCHAR2
                             , x_retcode        OUT NOCOPY VARCHAR2
                             , p_list_header_id IN         NUMBER
                             , p_batch_size     IN         NUMBER DEFAULT 1000
                             , p_num_workers    IN         NUMBER DEFAULT 3) IS

CURSOR c_get_list_header_status IS
SELECT status_code
  FROM ams_list_headers_all
 WHERE list_header_id = p_list_header_id;

CURSOR c_is_used_in_sel IS
SELECT list_header_id
  FROM ams_list_select_actions
 WHERE arc_incl_object_from='LIST'
   AND incl_object_id = p_list_header_id;

CURSOR c_is_used_in_act IS
SELECT list_header_id
  FROM ams_act_lists
 WHERE list_act_type IN ('TARGET','LIST')
   AND list_header_id = p_list_header_id;

CURSOR c_get_list_headers(l_request_id number) IS
SELECT list_header_id, list_name
  FROM ams_list_headers_vl
 WHERE request_id = l_request_id;

l_list_header_id          number;
l_list_header_status      varchar2(100);
x_return_status              varchar2(1) := FND_API.G_RET_STS_SUCCESS;
x_msg_data                varchar2(2000);
x_msg_count                  number;
l_sel_id             number := null;
l_act_id                  number := null;
l_errbuf                  varchar2(32767);
l_retcode                 number;
l_conc_request_id         number;
l_children_done           boolean := false;
--TYPE l_num_tbl IS table of number index by binary_integer;
--l_header_id_tbl  l_num_tbl;
l_header_id_tbl ams_list_purge_pvt.l_id_tbl%type;
type l_char_tbl  is table of  varchar2(1000) index by binary_integer;
l_list_name_tbl l_char_tbl;

BEGIN
   fnd_file.put_line(fnd_file.log,'Execution of Delete List entries master concurrent program started.');
   l_conc_request_id := FND_GLOBAL.conc_request_id();
   fnd_file.put_line(fnd_file.log,'Concurrent request id is '||l_conc_request_id);
   if p_list_header_id is not null then
      fnd_file.put_line(fnd_file.log,'List header id is '||p_list_header_id);
      -- Do the in use checks here before updating
      -- if it fails go back...
      OPEN c_get_list_header_status;
      FETCH c_get_list_header_status INTO l_list_header_status;
      CLOSE c_get_list_header_status;
      if l_list_header_status = 'DELETED' then
         UPDATE ams_list_headers_all
            SET request_id = l_conc_request_id,user_status_id = 314
          WHERE list_header_id = p_list_header_id;
         fnd_file.put_line(fnd_file.log,'List header status is already DELETED');
      else
         fnd_file.put_line(fnd_file.log,'List header status is not DELETED. Checking if its in use');
         OPEN c_is_used_in_sel;
         FETCH c_is_used_in_sel into l_sel_id;
         CLOSE c_is_used_in_sel;
         OPEN c_is_used_in_act;
         FETCH c_is_used_in_act into l_act_id;
         CLOSE c_is_used_in_act;
         if ((l_sel_id is not null) or (l_act_id is not null)) then -- This list is in use. Dont proceed
            fnd_file.put_line(fnd_file.log,'This list is in use. Could not be deleted.');
            return;
         else
            fnd_file.put_line(fnd_file.log,'This list is not in use. Could be deleted.');
            UPDATE ams_list_headers_all
               SET request_id = l_conc_request_id, status_code = 'DELETED', user_status_id = 314
             WHERE list_header_id = p_list_header_id;
         end if;
      end if;
   else
      fnd_file.put_line(fnd_file.log,'No list header id passed. So all the entries for lists in DELETED status will be deleted');
      update ams_list_headers_all
         set request_id = l_conc_request_id
       where status_code = 'DELETED';
   end if;
   fnd_file.put_line(fnd_file.log,'Submitting sub requests');
   ad_conc_utils_pkg.submit_subrequests( x_errbuf                      => l_errbuf
                                       , x_retcode                     => l_retcode
                                       , x_workerconc_app_shortname    => 'AMS'
                                       , x_workerconc_progname         => 'AMSDEWKR'
                                       , x_batch_size                  => p_batch_size
                                       , x_num_workers                 => p_num_workers
                                       , x_argument4                   => l_conc_request_id
                                       );
   if l_children_done then
      fnd_file.put_line(fnd_file.log,'children done');
   else
      fnd_file.put_line(fnd_file.log,'children not done');
   end if;
   l_children_done := FND_CONCURRENT.children_done ( parent_request_id   => l_conc_request_id
                                                   , recursive_flag      => 'N'
                                                   , interval            => 15
                                                   );

   fnd_file.put_line(fnd_file.log,'Sub requests completed.');

   fnd_file.put_line(fnd_file.log,'L ret code is '||l_retcode);

   if l_children_done then
      fnd_file.put_line(fnd_file.log,'children done');
   else
      fnd_file.put_line(fnd_file.log,'children not done');
   end if;


   IF ((l_retcode <> ad_conc_utils_pkg.conc_fail) AND
       (l_children_done)) then
      fnd_file.put_line(fnd_file.log,'Entries deleted successfully. Need to delete from other tables.');
      OPEN c_get_list_headers(l_conc_request_id);
      LOOP
         fnd_file.put_line(fnd_file.log,'Entries deleted successfully. Need to delete from other tables. Total count of header rec is '||l_header_id_tbl.count);
         FETCH c_get_list_headers BULK COLLECT INTO l_header_id_tbl,l_list_name_tbl LIMIT 1000;

         delete_list_info(p_id_tbl => l_header_id_tbl,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data  => x_msg_data);

         FOR i in  1 .. l_header_id_tbl.count
	 LOOP
            fnd_file.put_line(fnd_file.log,'List '||l_list_name_tbl(i)||' is deleted');
         END LOOP;

	 COMMIT;

	 EXIT WHEN c_get_list_headers%NOTFOUND;
      END LOOP;
      CLOSE C_GET_LIST_HEADERS;

   END IF;
   commit;
   fnd_file.put_line(fnd_file.log,'Delete Entries concurrent program executed successfully.');
   x_retcode := ad_conc_utils_pkg.conc_success;
EXCEPTION
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'Error while executing Delete Entries concurrent program '||sqlerrm);
    x_retcode := ad_conc_utils_pkg.conc_fail;
    x_errbuf  := SQLERRM;
    RAISE;
END delete_list_manager;

PROCEDURE delete_list_worker( x_errbuf       OUT NOCOPY VARCHAR2
                            , x_retcode      OUT NOCOPY VARCHAR2
                            , x_batch_size   IN         NUMBER
                            , x_worker_id    IN         NUMBER
                            , x_num_workers  IN         NUMBER
                            , x_argument4    IN         VARCHAR2) IS

l_worker_id            NUMBER;
l_product              VARCHAR2(30) := 'AMS';
l_table_name           VARCHAR2(30) := 'AMS_LIST_ENTRIES';
l_update_name          VARCHAR2(30);
l_status               VARCHAR2(30);
l_industry             VARCHAR2(30);
l_restatus             BOOLEAN;
l_table_owner          VARCHAR2(30);
l_any_rows_to_process  BOOLEAN;
l_start_rowid          ROWID;
l_end_rowid            ROWID;
l_rows_processed       NUMBER;
BEGIN

  l_restatus := fnd_installation.get_app_info ( l_product, l_status, l_industry, l_table_owner );

  IF (( l_restatus = FALSE ) OR
      ( l_table_owner IS NULL))
  THEN
    RAISE_APPLICATION_ERROR(-20001, 'Cannot get schema name for product: '|| l_product );
  END IF;

  FND_FILE.PUT_LINE( FND_FILE.LOG, 'X_Worker_Id: '|| x_worker_id );
  FND_FILE.PUT_LINE( FND_FILE.LOG, 'X_Num_Workers: '|| x_num_workers );
  FND_FILE.PUT_LINE( FND_FILE.LOG, 'Concurrent request id is '|| x_argument4);


  l_update_name := x_argument4;

  Begin
    ad_parallel_updates_pkg.initialize_rowid_range
    (
      ad_parallel_updates_pkg.ROWID_RANGE
    , l_table_owner
    , l_table_name
    , l_update_name
    , x_worker_id
    , x_num_workers
    , x_batch_size
    , 0
    );

    ad_parallel_updates_pkg.get_rowid_range
    (
      l_start_rowid
    , l_end_rowid
    , l_any_rows_to_process
    , x_batch_size
    , TRUE
    );

    WHILE ( l_any_rows_to_process = TRUE )
    LOOP
      DELETE /*+ rowid(entries) */
         AMS_LIST_ENTRIES entries
	   WHERE list_header_id IN (select list_header_id from ams_list_headers_all
                                     where request_id = x_argument4)
             AND ROWID BETWEEN l_start_rowid AND l_end_rowid;

      ad_parallel_updates_pkg.processed_rowid_range
      (
        l_rows_processed
      , l_end_rowid
      );

      COMMIT;

      ad_parallel_updates_pkg.get_rowid_range
      (
        l_start_rowid
      , l_end_rowid
      , l_any_rows_to_process
      , x_batch_size
      , FALSE
      );
    END LOOP;
    x_retcode := ad_conc_utils_pkg.conc_success;
    EXCEPTION
      WHEN OTHERS   THEN
      x_retcode := ad_conc_utils_pkg.conc_fail;
      x_errbuf  := SQLERRM;
      RAISE;
  END;
EXCEPTION
  WHEN OTHERS  THEN
      x_retcode := ad_conc_utils_pkg.conc_fail;
      x_errbuf  := SQLERRM;
      RAISE;
END delete_list_worker;

PROCEDURE delete_entries_soft  (p_list_header_id_tbl      IN  AMS_LIST_PURGE_PVT.l_list_header_id_tbl%type,
                		x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2) is

type num_tbl is table of number index by binary_integer;
l_header_id_tbl  num_tbl;
l_request_id_tbl num_tbl;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR i in 1..p_list_header_id_tbl.count
   LOOP
      l_header_id_tbl(i) := p_list_header_id_tbl(i).l_list_header_id;
   END LOOP;

   FORALL i in 1 .. l_header_id_tbl.count
   UPDATE ams_list_headers_all
      SET status_code = 'DELETED', user_status_id = 314
    WHERE list_header_id = l_header_id_tbl(i);

   COMMIT;

   FOR i in  1 .. p_list_header_id_tbl.count
   LOOP
      l_request_id_tbl(i) := FND_REQUEST.SUBMIT_REQUEST(
  			 application => 'AMS',
			 program     => 'AMSDEMGR',
			 argument1   => p_list_header_id_tbl(i).l_LIST_HEADER_id,
			 argument2   => 1000,
			 argument3   => 3);
   END LOOP;

   COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'E';
      x_msg_data := sqlcode||'   '||sqlerrm;
      raise;
END delete_entries_soft;


PROCEDURE delete_entries_online(p_list_header_id_tbl      IN  AMS_LIST_PURGE_PVT.l_list_header_id_tbl%type,
               		      x_return_status           OUT NOCOPY VARCHAR2,
                              x_msg_count               OUT NOCOPY NUMBER,
                              x_msg_data                OUT NOCOPY VARCHAR2) is

l_header_id_tbl ams_list_purge_pvt.l_id_tbl%type;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR i in 1..p_list_header_id_tbl.count
   LOOP
      l_header_id_tbl(i) := p_list_header_id_tbl(i).l_list_header_id;
   END LOOP;

   --l_header_id_tbl := p_list_header_id_tbl.l_list_header_id;

   FORALL i in  1 .. l_header_id_tbl.count
   DELETE from ams_list_entries
    WHERE list_header_id = l_header_id_tbl(i);

   delete_list_info(p_id_tbl => l_header_id_tbl,
                    x_return_status => x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data  => x_msg_data);

   COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'E';
      x_msg_data := sqlcode||'   '||sqlerrm;
      raise;
END delete_entries_online;

PROCEDURE purge_entries_manager (x_errbuf         OUT NOCOPY VARCHAR2
                               , x_retcode        OUT NOCOPY VARCHAR2
                               , p_list_type      IN         VARCHAR2
                               , p_cr_date_from   IN         VARCHAR2
                               , p_cr_date_to     IN         VARCHAR2
                               , p_batch_size     IN         NUMBER DEFAULT 1000
                               , p_num_workers    IN         NUMBER DEFAULT 3) IS



CURSOR c_get_list_headers(l_request_id number) IS
SELECT list_header_id, list_name
  FROM ams_list_headers_vl
 WHERE request_id = l_request_id;

l_list_header_id          number;
l_list_header_status      varchar2(100);
x_return_status           varchar2(1) := FND_API.G_RET_STS_SUCCESS;
x_msg_data                varchar2(2000);
x_msg_count               number;
l_errbuf                  varchar2(32767);
l_retcode                 number;
l_conc_request_id         number;
l_children_done           boolean := false;

--TYPE l_num_tbl IS table of number index by binary_integer;
--l_header_id_tbl  l_num_tbl;

l_header_id_tbl ams_list_purge_pvt.l_id_tbl%type;

type l_char_tbl  is table of  varchar2(1000) index by binary_integer;
l_list_name_tbl    l_char_tbl;
l_start_date       date;
l_end_date         date;

BEGIN

   fnd_file.put_line(fnd_file.log,'Execution of Purge list and target group entries master concurrent program started.');
   l_conc_request_id := FND_GLOBAL.conc_request_id();


   fnd_file.put_line(fnd_file.log,'Concurrent request id is '||l_conc_request_id);
   fnd_file.put_line(fnd_file.log,'Created from date is '||p_cr_date_from);
   fnd_file.put_line(fnd_file.log,'Created to date is '||p_cr_date_to);

   l_start_date          := to_date(p_cr_date_from,'YYYY/MM/DD HH24:MI:SS');
   l_end_date            := to_date(p_cr_date_to,  'YYYY/MM/DD HH24:MI:SS');

   if p_list_type is not null then
      fnd_file.put_line(fnd_file.log,'Type chosen is '||p_list_type);
      UPDATE ams_list_headers_all head
         SET request_id = l_conc_request_id,last_update_date = sysdate
       WHERE status_code in ('AVAILABLE','LOCKED')
         AND trunc(creation_date) between trunc(l_start_date) AND trunc(l_end_date)
	 AND list_type = p_list_type
	 AND not exists (SELECT 1
	                   FROM AMS_LIST_SRC_TYPES type
                          WHERE head.list_source_type = type.source_type_code
			    AND nvl(type.remote_flag,'N') = 'Y') ;
        -- AND nvl(remote_gen_flag,'N') = 'N';
   else
      fnd_file.put_line(fnd_file.log,'Type is not chosen. All the matching list and target group will be purged. ' );
      UPDATE ams_list_headers_all head
         SET request_id = l_conc_request_id,last_update_date = sysdate
       WHERE status_code in ('AVAILABLE','LOCKED')
         AND trunc(creation_date) between trunc(l_start_date) AND trunc(l_end_date)
	 AND not exists (SELECT 1
	                   FROM AMS_LIST_SRC_TYPES type
                          WHERE head.list_source_type = type.source_type_code
			    AND nvl(type.remote_flag,'N') = 'Y') ;
--	 AND nvl(remote_gen_flag,'N') = 'N';
   end if;

   fnd_file.put_line(fnd_file.log,'Submitting sub requests');
   ad_conc_utils_pkg.submit_subrequests( x_errbuf                      => l_errbuf
                                       , x_retcode                     => l_retcode
                                       , x_workerconc_app_shortname    => 'AMS'
                                       , x_workerconc_progname         => 'AMSPEWKR'
                                       , x_batch_size                  => p_batch_size
                                       , x_num_workers                 => p_num_workers
                                       , x_argument4                   => l_conc_request_id
                                       );

   if l_children_done then
      fnd_file.put_line(fnd_file.log,'children done');
   else
      fnd_file.put_line(fnd_file.log,'children not done');
   end if;

   l_children_done := fnd_concurrent.children_done ( parent_request_id   => l_conc_request_id
                                                   , recursive_flag      => 'N'
                                                   , interval            => 15
                                                   );

   fnd_file.put_line(fnd_file.log,'Sub requests submitted.');

   fnd_file.put_line(fnd_file.log,'ret code is '||l_retcode);

   if l_children_done then
      fnd_file.put_line(fnd_file.log,'children done');
   else
      fnd_file.put_line(fnd_file.log,'children not done');
   end if;


   IF ((l_retcode <> ad_conc_utils_pkg.conc_fail) AND
       (l_children_done)) then

      fnd_file.put_line(fnd_file.log,'Entries purged successfully. Need to purge from ams_act_logs.');

      OPEN c_get_list_headers(l_conc_request_id);
      LOOP
         FETCH c_get_list_headers BULK COLLECT INTO l_header_id_tbl, l_list_name_tbl LIMIT 1000;

         FORALL i in  1 .. l_header_id_tbl.count
         DELETE from ams_act_logs
          WHERE act_log_used_by_id = l_header_id_tbl(i);

         FORALL i in  1 .. l_header_id_tbl.count
         UPDATE ams_list_headers_all
	    SET status_code = 'PURGED',
	        user_status_id = 313,
		no_of_rows_in_list           = 0,
      		no_of_rows_active            = 0,
      		no_of_rows_inactive          = 0,
      		no_of_rows_in_ctrl_group     = 0,
      		no_of_rows_random            = 0,

      		no_of_rows_duplicates        = 0,
      		no_of_rows_manually_entered  = 0,
      		no_of_rows_suppressed        = 0,
      		NO_OF_ROWS_FATIGUED          = 0,
		TCA_FAILED_RECORDS           = 0,
		no_of_rows_initially_selected= 0,
 		object_version_number = object_version_number + 1,
                status_date = SYSDATE,
                archived_by = FND_GLOBAL.user_id,
                archived_date = SYSDATE,
                last_update_date = SYSDATE,
                last_updated_by = FND_GLOBAL.user_id
          WHERE list_header_id = l_header_id_tbl(i);

         FOR i in  1 .. l_header_id_tbl.count
	 LOOP
            fnd_file.put_line(fnd_file.log,'Entries for list/target group '||l_list_name_tbl(i)||' is deleted');
         END LOOP;

	 COMMIT;

	 EXIT WHEN c_get_list_headers%NOTFOUND;
      END LOOP;
      CLOSE c_get_list_headers;

   END IF;
   commit;

   fnd_file.put_line(fnd_file.log,'Purge List and Target group entries concurrent program executed successfully.');

   x_retcode := ad_conc_utils_pkg.conc_success;
EXCEPTION
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'Error while executing purge entries concurrent program '||sqlerrm);
    x_retcode := ad_conc_utils_pkg.conc_fail;
    x_errbuf  := SQLERRM;
    RAISE;
END purge_entries_manager;


PROCEDURE purge_entries_worker ( x_errbuf       OUT NOCOPY VARCHAR2
                               , x_retcode      OUT NOCOPY VARCHAR2
                               , x_batch_size   IN         NUMBER
                               , x_worker_id    IN         NUMBER
                               , x_num_workers  IN         NUMBER
                               , x_argument4    IN         VARCHAR2) IS

l_worker_id            NUMBER;
l_product              VARCHAR2(30) := 'AMS';
l_table_name           VARCHAR2(30) := 'AMS_LIST_ENTRIES';
l_update_name          VARCHAR2(30);
l_status               VARCHAR2(30);
l_industry             VARCHAR2(30);
l_restatus             BOOLEAN;
l_table_owner          VARCHAR2(30);
l_any_rows_to_process  BOOLEAN;
l_start_rowid          ROWID;
l_end_rowid            ROWID;
l_rows_processed       NUMBER;
BEGIN

  l_restatus := fnd_installation.get_app_info ( l_product, l_status, l_industry, l_table_owner );

  IF (( l_restatus = FALSE ) OR
      ( l_table_owner IS NULL))
  THEN
    RAISE_APPLICATION_ERROR(-20001, 'Cannot get schema name for product: '|| l_product );
  END IF;

  FND_FILE.PUT_LINE( FND_FILE.LOG, 'X_Worker_Id: '|| x_worker_id );
  FND_FILE.PUT_LINE( FND_FILE.LOG, 'X_Num_Workers: '|| x_num_workers );
  FND_FILE.PUT_LINE( FND_FILE.LOG, 'Concurrent request id is '|| x_argument4);


  l_update_name := x_argument4;

  Begin
    ad_parallel_updates_pkg.initialize_rowid_range
    (
      ad_parallel_updates_pkg.ROWID_RANGE
    , l_table_owner
    , l_table_name
    , l_update_name
    , x_worker_id
    , x_num_workers
    , x_batch_size
    , 0
    );

    ad_parallel_updates_pkg.get_rowid_range
    (
      l_start_rowid
    , l_end_rowid
    , l_any_rows_to_process
    , x_batch_size
    , TRUE
    );

    WHILE ( l_any_rows_to_process = TRUE )
    LOOP
      DELETE /*+ rowid(entries) */
         AMS_LIST_ENTRIES entries
	   WHERE list_header_id IN (select list_header_id from ams_list_headers_all
                                     where request_id = x_argument4)
             AND ROWID BETWEEN l_start_rowid AND l_end_rowid;

      ad_parallel_updates_pkg.processed_rowid_range
      (
        l_rows_processed
      , l_end_rowid
      );

      COMMIT;

      ad_parallel_updates_pkg.get_rowid_range
      (
        l_start_rowid
      , l_end_rowid
      , l_any_rows_to_process
      , x_batch_size
      , FALSE
      );
    END LOOP;
    x_retcode := ad_conc_utils_pkg.conc_success;
    EXCEPTION
      WHEN OTHERS   THEN
      x_retcode := ad_conc_utils_pkg.conc_fail;
      x_errbuf  := SQLERRM;
      RAISE;
  END;
EXCEPTION
  WHEN OTHERS  THEN
      x_retcode := ad_conc_utils_pkg.conc_fail;
      x_errbuf  := SQLERRM;
      RAISE;
END purge_entries_worker;

END AMS_List_Purge_PVT;

/
