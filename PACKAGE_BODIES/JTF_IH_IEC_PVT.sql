--------------------------------------------------------
--  DDL for Package Body JTF_IH_IEC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_IH_IEC_PVT" AS
/* $Header: JTFIHPAB.pls 115.14 2004/07/28 12:32:02 vekrishn ship $ */

-- Sub-Program Unit Declarations

-----------------------------++++++-------------------------------
--
--  API name    : GET_MEDIA_IDS
--  Type        : Private
--
--  Version     : Initial version 1.0
--
-----------------------------++++++-------------------------------
-- Create media items
-- Modified by IAleshin 08-Mar-2004 Enh# 3491849 JTH.R: IH CHANGES TO
--                                  SUPPORT FTC ABANDONMENT REGULATIONS
-- 05/24/1971 IAleshin - Fixed Bug#3646665 - DBIB9TST AO PRIVATE CLOSE API
--                       NEEDS TO BE ABLE TO SET THE SERVER GROUP ID.
--
G_PKG_NAME CONSTANT VARCHAR2(30) := 'JTF_IH_IEC_PVT';

PROCEDURE GET_MEDIA_IDS
  ( P_COUNT     IN  NUMBER
  , X_MEDIA_IDS OUT NOCOPY MEDIA_ID_CURSOR
  )
IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  l_media_id           NUMBER;
  l_null               CHAR(1);

  l_media_id_tab       MEDIA_ID_TAB;
  l_media_id_cursor    MEDIA_ID_CURSOR;
  l_media_id_stmt      VARCHAR2(4000);

  l_user_id            NUMBER;
  l_login_id           NUMBER;

  -- Perf variables
  l_duration_perf           NUMBER;
  l_direction_perf          VARCHAR2(240);
  l_media_item_type_perf    VARCHAR2(80);
  l_active_perf             VARCHAR2(1);
  l_ao_update_pending_perf  VARCHAR2(1);
  l_soft_closed_perf        VARCHAR2(1);

BEGIN

   -- Perf variables
   l_duration_perf           := 0;
   l_direction_perf          := 'OUTBOUND';
   l_media_item_type_perf    := 'TELEPHONE';
   l_active_perf             := 'Y';
   l_ao_update_pending_perf  := 'Y';
   l_soft_closed_perf        := 'N';

   l_user_id := NVL(FND_GLOBAL.user_id,-1);
   l_login_id := NVL(FND_GLOBAL.conc_login_id,-1);

   -- dbms_output.put_line('About to Enter Loop');

   for L in 1..P_COUNT
   Loop

      SELECT JTF_IH_MEDIA_ITEMS_S1.NextVal into l_media_id FROM dual;
      --  dbms_output.put_line('Media ID Returned: ' || to_char(l_media_id));

      INSERT INTO jtf_ih_media_items
      (
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN,
         MEDIA_ID,
         DURATION,
         DIRECTION,
         --END_DATE_TIME,
         SOURCE_ITEM_CREATE_DATE_TIME,
         SOURCE_ITEM_ID,
         START_DATE_TIME,
         SOURCE_ID,
         MEDIA_ITEM_TYPE,
         MEDIA_ITEM_REF,
         MEDIA_DATA,
         MEDIA_ABANDON_FLAG,
         MEDIA_TRANSFERRED_FLAG,
         ACTIVE,
         SERVER_GROUP_ID,
         DNIS,
         ANI,
         CLASSIFICATION,
         -- Enh# 3491849
         AO_UPDATE_PENDING,
         SOFT_CLOSED
      )
      VALUES
      (
         l_user_id,
         Sysdate,
         l_user_id,
         Sysdate,
         l_login_id,
         l_media_id,
         l_duration_perf,
         l_direction_perf,
         --Sysdate,
         NULL,
         NULL,
         Sysdate,
         NULL,
         l_media_item_type_perf,
         NULL,
         NULL,
         NULL,
         NULL,
         l_active_perf,
         NULL,
         NULL,
         NULL,
         NULL,
         l_ao_update_pending_perf,
         l_soft_closed_perf
      );

      l_media_id_tab(L) := l_media_id;
      --   dbms_output.put_line('Media Item Inserted');

   End Loop;

   l_media_id_stmt := 'Select ';

   -- dbms_output.put_line('Starting Cursor statement construction loop');
   for L in 1..l_media_id_tab.count
   loop
      l_media_id_stmt := l_media_id_stmt || l_media_id_tab(L);
      if( L <> l_media_id_tab.count )then
         l_media_id_stmt := l_media_id_stmt ||',';
      end if;
   end loop;
   l_media_id_stmt := l_media_id_stmt || ' from dual order by 1';

   -- dbms_output.put_line('Cursor statement construction complete');
   -- dbms_output.put_line('statement length = ' || to_char(length(l_media_id_stmt)));

   Open l_media_id_cursor for l_media_id_stmt;
   -- dbms_output.put_line('Cursor opened');
   X_MEDIA_IDS := l_media_id_cursor;
   commit;
   return;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      -- Get messages and log these.
      raise_application_error( -20000, 'Error Inserting Media Item. - Get IDS Failed',TRUE);

END GET_MEDIA_IDS;


-- Created by IAleshin 08-Mar-2004 Enh# 3491849 JTH.R: IH CHANGES TO
--                                 SUPPORT FTC ABANDONMENT REGULATIONS
--
PROCEDURE CLOSE_AO_CALL
(
   p_Media_id		IN NUMBER,
   p_Hard_Close 	IN VARCHAR2,
   p_source_item_id IN NUMBER ,
   p_address 		IN VARCHAR2,
   p_start_date_time IN DATE ,
   p_end_date_time IN DATE,
   p_duration  	IN NUMBER,
   p_media_abandon_flag IN VARCHAR2,
   x_Commit 		IN	VARCHAR2,
   x_return_status	OUT NOCOPY	VARCHAR2,
   x_msg_count		OUT NOCOPY	NUMBER,
   x_msg_data		OUT NOCOPY	VARCHAR2,
   -- Enh# 3646665
   p_Server_Group_ID IN NUMBER  DEFAULT NULL
)
AS
   l_ao_update_pending VARCHAR2(1);
   l_soft_closed VARCHAR2(1);
   l_start_date_time DATE;
   l_end_date_time DATE;
   p_Media JTF_IH_PUB.media_rec_type;
   l_api_name   CONSTANT VARCHAR2(30) := 'CLOSE_AO_CALL';
   l_Hard_Close 	VARCHAR2(2);
   l_Commit VARCHAR2(10);

   -- l_ao_update_pending_perf
   l_ao_update_pending_perf VARCHAR2(1);

BEGIN

   -- Perf fix for literal Usage
   l_ao_update_pending_perf := 'N';

   l_Hard_Close := NVL(p_Hard_Close,'N');
   l_Commit := NVL(x_Commit,FND_API.G_FALSE);

   SAVEPOINT close_ao_call;
   -- Get current ao_update_pending and soft_closed values for current Media_Id
   --
   SELECT ao_update_pending, soft_closed, start_date_time, end_date_time
     INTO l_ao_update_pending, l_soft_closed, l_start_date_time, l_end_date_time
   FROM JTF_IH_MEDIA_ITEMS WHERE Media_Id = p_Media_id;

   -- Set up parameters for Media Item.
   --
   p_Media.media_id := p_Media_id;
   p_Media.direction := 'OUTBOUND';
   p_Media.media_item_type := 'TELEPHONE';
   p_Media.source_item_id := p_source_item_id;
   p_Media.address	:= p_address;
   p_Media.media_abandon_flag := p_media_abandon_flag;
   p_Media.server_group_id := p_Server_Group_ID;

   IF p_start_date_time IS NOT NULL THEN
      p_Media.start_date_time := p_start_date_time;
   END IF;

   IF p_end_date_time IS NOT NULL THEN
      p_Media.end_date_time := p_end_date_time;
   END IF;

   IF p_duration IS NOT NULL THEN
      p_Media.duration := p_duration;
   END IF;

   -- Update AO_UPDATE_PENDING flag to 'N' for Media Item ID passed
   --
   -- l_ao_update_pending_perf
   UPDATE jtf_ih_media_items SET ao_update_pending = l_ao_update_pending_perf
      WHERE Media_ID = p_Media_id;

   -- If MI should be hard closed then call JTF_IH_PUB.Close_MediaItem
   -- else JTF_IH_PUB.Update_MediaItem
   --
   IF l_Hard_Close = 'Y' OR l_soft_closed = 'Y' THEN
      JTF_IH_PUB.close_mediaitem(
         p_api_version => 1.0,
         p_init_msg_list => FND_API.G_TRUE,
         p_commit => l_Commit,
         p_resp_appl_id => fnd_global.resp_appl_id,
         p_resp_id => fnd_global.resp_id,
         p_user_id => fnd_global.user_id,
         p_login_id => fnd_global.login_id,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_media_rec => p_Media
      );
   ELSE
      JTF_IH_PUB.update_mediaitem(
         p_api_version => 1.0,
         p_init_msg_list => FND_API.G_TRUE,
         p_commit => l_Commit,
         p_resp_appl_id => fnd_global.resp_appl_id,
         p_resp_id => fnd_global.resp_id,
         p_user_id => fnd_global.user_id,
         p_login_id => fnd_global.login_id,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_media_rec => p_Media
      );
   END IF;
   IF x_return_status <> 'S' THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF l_Commit = FND_API.G_TRUE THEN
      COMMIT WORK;
   END IF;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO close_ao_call;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
         ( p_count => x_msg_count,
           p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');

   WHEN OTHERS THEN
      ROLLBACK TO close_ao_call;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
      				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
END;

END JTF_IH_IEC_PVT;

/
