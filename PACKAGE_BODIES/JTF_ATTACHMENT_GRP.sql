--------------------------------------------------------
--  DDL for Package Body JTF_ATTACHMENT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_ATTACHMENT_GRP" AS
/* $Header: JTFGATHB.pls 115.16 2004/07/09 18:49:12 applrt ship $ */
g_amv_api_version CONSTANT NUMBER := 1.0;

TYPE AthCurTyp IS REF CURSOR;

--modifed by G. Zhang 05/09/2001 04:06PM
g_view_name CONSTANT VARCHAR2(48) := 'jtf_amv_attachments a';

PROCEDURE list_attachment (
  p_api_version            IN   NUMBER,
  p_init_msg_list          IN   VARCHAR2 := FND_API.g_false,
  x_return_status          OUT  VARCHAR2,
  x_msg_count              OUT  NUMBER,
  x_msg_data               OUT  VARCHAR2,

  --added by G. Zhang 04/30/2001 11:18AM
  p_appl_id	IN	NUMBER := 671,

  p_deliverable_id         IN   NUMBER,
  p_start_id               IN   NUMBER,
  p_batch_size             IN   NUMBER,
  x_row_count              OUT  NUMBER,
  x_ath_id_tbl             OUT  NUMBER_TABLE,
  x_dlv_id_tbl             OUT  NUMBER_TABLE,
  x_file_name_tbl          OUT  VARCHAR2_TABLE_300,

  --added by G. Zhang 04/30/2001 11:18AM
  x_file_id_tbl		OUT     NUMBER_TABLE,
  x_file_ext_tbl		OUT	VARCHAR2_TABLE_20,
  x_dsp_width_tbl		OUT 	NUMBER_TABLE,
  x_dsp_height_tbl	OUT 	NUMBER_TABLE,

  x_version_tbl            OUT  NUMBER_TABLE ) IS

  l_api_name CONSTANT VARCHAR2(30) := 'list_attachment';
  l_full_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_return_status VARCHAR2(1);

  l_ath_cv AthCurTyp;
  l_flag NUMBER := 0;

  --modified by G. Zhang 05/09/2001 04:06PM
  sql_cond VARCHAR2(240) := 'FROM ' || g_view_name
                            || ' WHERE a.application_id = :appl_id AND EXISTS (SELECT NULL FROM jtf_dsp_lgl_phys_map m WHERE a.attachment_id = m.attachment_id) ';
  sql_stmt VARCHAR2(960);

  start_pnt NUMBER;
  end_pnt   NUMBER;
  l_index   NUMBER;
  l_count   NUMBER;

  l_ath_id_tbl    JTF_NUMBER_TABLE;
  l_dlv_id_tbl    JTF_NUMBER_TABLE;
  l_file_name_tbl JTF_VARCHAR2_TABLE_300;

  --added by G. Zhang 04/30/2001 11:18AM
  l_file_id_tbl JTF_NUMBER_TABLE;
  l_file_ext_tbl JTF_VARCHAR2_TABLE_100;
  l_dsp_width_tbl JTF_NUMBER_TABLE;
  l_dsp_height_tbl JTF_NUMBER_TABLE;

  l_version_tbl   JTF_NUMBER_TABLE;
BEGIN
  -- Standard call to check for call compatibility
  IF NOT FND_API.compatible_api_call(
    g_api_version,
    p_api_version,
    l_api_name,
    g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API rturn status to success
  x_return_status := FND_API.g_ret_sts_success;

  -- API body

  IF p_start_id < -1 OR p_batch_size < 0
    OR (p_start_id = -1 AND p_batch_size = 0) THEN
    FND_MESSAGE.set_name('JTF', 'JTF_DSP_QUERY_INVLD');
    FND_MESSAGE.set_token('0', p_start_id);
    FND_MESSAGE.set_token('1', p_batch_size);
    FND_MSG_PUB.add;
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF p_deliverable_id IS NOT NULL THEN
    l_flag := 1;
    --modified by G. Zhang 05/09/2001 04:06PM
    sql_cond := sql_cond  || 'AND a.attachment_used_by_id = :dlv_id ';
  END IF;

  -- fnd_global.apps_initialize(fnd_global.user_id, fnd_global.resp_id, 671);
  -- l_appl_id := FND_GLOBAL.resp_appl_id;

  -- Get Total Row Number
  --modified by G. Zhang 05/09/2001 04:06PM
  sql_stmt := 'SELECT COUNT(*) ' || sql_cond;
  IF l_flag = 1 THEN
    OPEN l_ath_cv FOR sql_stmt
    USING p_appl_id,p_deliverable_id;
  ELSE
    OPEN l_ath_cv FOR sql_stmt USING p_appl_id;
  END IF;

  FETCH l_ath_cv INTO x_row_count;
  CLOSE l_ath_cv;

  IF x_row_count = 0 THEN
    FND_MSG_PUB.count_and_get(
      p_encoded      =>   FND_API.g_false,
      p_count        =>   x_msg_count,
      p_data         =>   x_msg_data
                             );
    RETURN;
  END IF;

  x_ath_id_tbl := NULL;
  x_dlv_id_tbl := NULL;
  x_file_name_tbl := NULL;

  --added by G. Zhang 04/30/2001 11:18AM
  x_file_id_tbl :=NULL;
  x_file_ext_tbl :=NULL;
  x_dsp_width_tbl :=NULL;
  x_dsp_height_tbl :=NULL;

  x_version_tbl := NULL;

  -- Get matchined rows
  IF p_start_id > -1 THEN
    IF p_start_id >= x_row_count THEN
      FND_MSG_PUB.count_and_get(
        p_encoded      =>   FND_API.g_false,
        p_count        =>   x_msg_count,
        p_data         =>   x_msg_data
                               );
      RETURN;
    END IF;

    start_pnt := p_start_id + 1;
    IF p_batch_size > 0 THEN
      end_pnt := p_start_id + p_batch_size;
    ELSE
      end_pnt := x_row_count;
    END IF;
  ELSE
    end_pnt := x_row_count;
    start_pnt := end_pnt - p_batch_size + 1;
    IF start_pnt < 1 THEN
      start_pnt := 1;
    END IF;
  END IF;

  -- modified by G. Zhang 04/30/2001 11:18AM
  sql_stmt := 'BEGIN '
    || 'SELECT attachment_id, attachment_used_by_id, file_name, file_id, file_extension, display_width, display_height, '
    || 'object_version_number '
    || 'BULK COLLECT INTO :id_tbl, :dlv_id_tbl, :file_tbl, :file_id_tbl, :file_ext_tbl, :dsp_width_tbl, :dsp_height_tbl, :version_tbl '
    || 'FROM (SELECT a.attachment_id, a.attachment_used_by_id, a.file_name, a.file_id, a.file_extension, a.display_width, a.display_height, a.object_version_number '
    || sql_cond
    || 'ORDER BY a.file_name ) '
    || 'WHERE ROWNUM <= :row_num '
    || '; END;';

  -- dbms_output.put_line('sql_cond=' || sql_cond);
  -- dbms_output.put_line('sql_stmt=' || sql_stmt);

  IF l_flag = 1 THEN
    EXECUTE IMMEDIATE sql_stmt USING
      OUT l_ath_id_tbl, OUT l_dlv_id_tbl, OUT l_file_name_tbl,

      --added by G. Zhang 04/30/2001 11:18AM
      OUT l_file_id_tbl, OUT l_file_ext_tbl, OUT l_dsp_width_tbl, OUT l_dsp_height_tbl,

      OUT l_version_tbl,

      --modified by G. Zhang 04/30/2001 11:18AM
      p_appl_id, p_deliverable_id, end_pnt;

  ELSE
    EXECUTE IMMEDIATE sql_stmt USING
      OUT l_ath_id_tbl, OUT l_dlv_id_tbl, OUT l_file_name_tbl,

      --added by G. Zhang 04/30/2001 11:18AM
      OUT l_file_id_tbl, OUT l_file_ext_tbl, OUT l_dsp_width_tbl, OUT l_dsp_height_tbl,

      OUT l_version_tbl,

      --modified by G. Zhang 04/30/2001 11:18AM
      p_appl_id,  end_pnt;

  END IF;

  -- dbms_output.put_line('executed');

  IF l_ath_id_tbl IS NOT NULL AND start_pnt <= l_ath_id_tbl.COUNT THEN
    x_ath_id_tbl := NUMBER_TABLE(l_ath_id_tbl(start_pnt));
    x_dlv_id_tbl := NUMBER_TABLE(l_dlv_id_tbl(start_pnt));
    x_file_name_tbl := VARCHAR2_TABLE_300(l_file_name_tbl(start_pnt));

    --added by G. Zhang 04/30/2001 11:18AM
    x_file_id_tbl := NUMBER_TABLE(l_file_id_tbl(start_pnt));
    x_file_ext_tbl := VARCHAR2_TABLE_20(l_file_ext_tbl(start_pnt));
    x_dsp_width_tbl := NUMBER_TABLE(l_dsp_width_tbl(start_pnt));
    x_dsp_height_tbl := NUMBER_TABLE(l_dsp_height_tbl(start_pnt));

    x_version_tbl := NUMBER_TABLE(l_version_tbl(start_pnt));

    l_count := 1;
    FOR l_index IN start_pnt+1..l_ath_id_tbl.COUNT LOOP
      IF l_index > end_pnt THEN
        EXIT;
      END IF;
      x_ath_id_tbl.EXTEND;
      x_dlv_id_tbl.EXTEND;
      x_file_name_tbl.EXTEND;

      --added by G. Zhang 04/30/2001 11:18AM
      x_file_id_tbl.EXTEND;
      x_file_ext_tbl.EXTEND;
      x_dsp_width_tbl.EXTEND;
      x_dsp_height_tbl.EXTEND;

      x_version_tbl.EXTEND;

      l_count := l_count + 1;
      x_ath_id_tbl(l_count) := l_ath_id_tbl(l_index);
      x_dlv_id_tbl(l_count) := l_dlv_id_tbl(l_index);
      x_file_name_tbl(l_count) := l_file_name_tbl(l_index);

      --added by G. Zhang 04/30/2001 11:18AM
      x_file_id_tbl(l_count) := l_file_id_tbl(l_index);
      x_file_ext_tbl(l_count) := l_file_ext_tbl(l_index);
      x_dsp_width_tbl(l_count) := l_dsp_width_tbl(l_index);
      x_dsp_height_tbl(l_count) := l_dsp_height_tbl(l_index);

      x_version_tbl(l_count) := l_version_tbl(l_index);
    END LOOP;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.count_and_get(
    p_encoded      =>   FND_API.g_false,
    p_count        =>   x_msg_count,
    p_data         =>   x_msg_data
                           );

  -- dbms_output.put_line('reached where');

EXCEPTION

   WHEN FND_API.g_exc_unexpected_error THEN
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

   WHEN OTHERS THEN
     x_return_status := FND_API.g_ret_sts_unexp_error ;

     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN			FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
     END IF;

     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

END list_attachment;


---------------------------------------------------------------------+
--+PROCEDURE
--    save_attachment
--+
-- PURPOSE
--    Save a physical attachment
--+
-- PARAMETERS
--    p_attachment_rec: the physical attachment to be saved
--+
-- NOTES
--   1. Insert a new attachment if the attachment_id is null; Update otherwise
--   2. Raise an exception if file_name is null or not unique
--   3. Raise an exception if the deliverable doesn't exist (create)
--   4. Raise an exception if the attachment doesn't exist; or the version
--	doesn't match (update)
--   5. Raise an exception for any other errors
---------------------------------------------------------------------+
PROCEDURE save_attachment (
  p_api_version			IN 	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.g_false,
  p_commit				IN	VARCHAR2 := FND_API.g_false,
  x_return_status		OUT	VARCHAR2,
  x_msg_count			OUT	NUMBER,
  x_msg_data			OUT	VARCHAR2,
  p_attachment_rec		IN OUT ATTACHMENT_REC_TYPE ) IS

  l_api_name CONSTANT VARCHAR2(30) := 'save_attachment';
  l_full_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_operation_type VARCHAR2(10) := 'INSERT';

  l_attachment_id NUMBER;
  l_act_attachment_rec JTF_AMV_ATTACHMENT_PUB.ACT_ATTACHMENT_REC_TYPE;
  l_return_status VARCHAR2(1);
  l_appl_id NUMBER;
BEGIN
  -- Standard start of API savepoint
  SAVEPOINT save_attachment_grp;

  -- Standard call to check for call compatibility
  IF NOT FND_API.compatible_api_call(
    g_api_version,
    p_api_version,
    l_api_name,
    g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API rturn status to success
  x_return_status := FND_API.g_ret_sts_success;

  -- API body

  l_act_attachment_rec.LAST_UPDATE_DATE := NULL;
  l_act_attachment_rec.LAST_UPDATED_BY := NULL;
  l_act_attachment_rec.CREATION_DATE := NULL;
  l_act_attachment_rec.CREATED_BY := NULL;
  l_act_attachment_rec.LAST_UPDATE_LOGIN := NULL;

  l_act_attachment_rec.OWNER_USER_ID := NULL;
  l_act_attachment_rec.VERSION := NULL;

-- comment out by G. Zhang 04/30/2001 11:18AM
--  l_act_attachment_rec.ENABLED_FLAG := 'N';
--  l_act_attachment_rec.CAN_FULFILL_ELECTRONIC_FLAG := 'N';
--  l_act_attachment_rec.FILE_ID := NULL;
--  l_act_attachment_rec.FILE_EXTENSION := NULL;
--  l_act_attachment_rec.KEYWORDS := NULL;
--  l_act_attachment_rec.DISPLAY_WIDTH := NULL;
--  l_act_attachment_rec.DISPLAY_HEIGHT := NULL;
--  l_act_attachment_rec.DISPLAY_LOCATION := NULL;
--  l_act_attachment_rec.LINK_TO := NULL;
--  l_act_attachment_rec.LINK_URL := NULL;
--  l_act_attachment_rec.SEND_FOR_PREVIEW_FLAG := NULL;
--  l_act_attachment_rec.ATTACHMENT_TYPE := NULL;
--  l_act_attachment_rec.LANGUAGE_CODE := NULL;
--  l_act_attachment_rec.DESCRIPTION := NULL;
--  l_act_attachment_rec.DEFAULT_STYLE_SHEET := NULL;
--  l_act_attachment_rec.DISPLAY_RULE_ID := NULL;
--  l_act_attachment_rec.DISPLAY_PROGRAM := NULL;
--  l_act_attachment_rec.ATTRIBUTE_CATEGORY := NULL;
--  l_act_attachment_rec.ATTRIBUTE1 := NULL;
--  l_act_attachment_rec.ATTRIBUTE2 := NULL;
--  l_act_attachment_rec.ATTRIBUTE3 := NULL;
--  l_act_attachment_rec.ATTRIBUTE4 := NULL;
--  l_act_attachment_rec.ATTRIBUTE5 := NULL;
--  l_act_attachment_rec.ATTRIBUTE6 := NULL;
--  l_act_attachment_rec.ATTRIBUTE7 := NULL;
--  l_act_attachment_rec.ATTRIBUTE8 := NULL;
--  l_act_attachment_rec.ATTRIBUTE9 := NULL;
--  l_act_attachment_rec.ATTRIBUTE10 := NULL;
--  l_act_attachment_rec.ATTRIBUTE11 := NULL;
--  l_act_attachment_rec.ATTRIBUTE12 := NULL;
--  l_act_attachment_rec.ATTRIBUTE13 := NULL;
--  l_act_attachment_rec.ATTRIBUTE14 := NULL;
--  l_act_attachment_rec.ATTRIBUTE15 := NULL;
--  l_act_attachment_rec.DISPLAY_URL := 'not in use';

-- Modified by G. Zhang 04/30/2001 11:18AM
  l_act_attachment_rec.ENABLED_FLAG := p_attachment_rec.ENABLED_FLAG;
  l_act_attachment_rec.CAN_FULFILL_ELECTRONIC_FLAG := p_attachment_rec.CAN_FULFILL_ELECTRONIC_FLAG;
  IF p_attachment_rec.FILE_ID > 0 THEN
  	l_act_attachment_rec.FILE_ID := p_attachment_rec.FILE_ID;
  ELSE
  	l_act_attachment_rec.FILE_ID := NULL;
  END IF;
  l_act_attachment_rec.FILE_EXTENSION := p_attachment_rec.FILE_EXTENSION;
  l_act_attachment_rec.KEYWORDS := p_attachment_rec.KEYWORDS;
  l_act_attachment_rec.DISPLAY_WIDTH := p_attachment_rec.DISPLAY_WIDTH;
  l_act_attachment_rec.DISPLAY_HEIGHT := p_attachment_rec.DISPLAY_HEIGHT;
  l_act_attachment_rec.DISPLAY_LOCATION := p_attachment_rec.DISPLAY_LOCATION;
  l_act_attachment_rec.LINK_TO := p_attachment_rec.LINK_TO;
  l_act_attachment_rec.LINK_URL := p_attachment_rec.LINK_URL;
  l_act_attachment_rec.SEND_FOR_PREVIEW_FLAG := p_attachment_rec.SEND_FOR_PREVIEW_FLAG;
  l_act_attachment_rec.ATTACHMENT_TYPE := p_attachment_rec.ATTACHMENT_TYPE;
  l_act_attachment_rec.LANGUAGE_CODE := p_attachment_rec.LANGUAGE_CODE;
  l_act_attachment_rec.DESCRIPTION := p_attachment_rec.DESCRIPTION;
  l_act_attachment_rec.DEFAULT_STYLE_SHEET := p_attachment_rec.DEFAULT_STYLE_SHEET;
  l_act_attachment_rec.DISPLAY_RULE_ID := p_attachment_rec.DISPLAY_RULE_ID;
  l_act_attachment_rec.DISPLAY_PROGRAM := p_attachment_rec.DISPLAY_PROGRAM;
  l_act_attachment_rec.ATTRIBUTE_CATEGORY := p_attachment_rec.ATTRIBUTE_CATEGORY;
  l_act_attachment_rec.ATTRIBUTE1 := p_attachment_rec.ATTRIBUTE1;
  l_act_attachment_rec.ATTRIBUTE2 := p_attachment_rec.ATTRIBUTE2;
  l_act_attachment_rec.ATTRIBUTE3 := p_attachment_rec.ATTRIBUTE3;
  l_act_attachment_rec.ATTRIBUTE4 := p_attachment_rec.ATTRIBUTE4;
  l_act_attachment_rec.ATTRIBUTE5 := p_attachment_rec.ATTRIBUTE5;
  l_act_attachment_rec.ATTRIBUTE6 := p_attachment_rec.ATTRIBUTE6;
  l_act_attachment_rec.ATTRIBUTE7 := p_attachment_rec.ATTRIBUTE7;
  l_act_attachment_rec.ATTRIBUTE8 := p_attachment_rec.ATTRIBUTE8;
  l_act_attachment_rec.ATTRIBUTE9 := p_attachment_rec.ATTRIBUTE9;
  l_act_attachment_rec.ATTRIBUTE10 := p_attachment_rec.ATTRIBUTE10;
  l_act_attachment_rec.ATTRIBUTE11 := p_attachment_rec.ATTRIBUTE11;
  l_act_attachment_rec.ATTRIBUTE12 := p_attachment_rec.ATTRIBUTE12;
  l_act_attachment_rec.ATTRIBUTE13 := p_attachment_rec.ATTRIBUTE13;
  l_act_attachment_rec.ATTRIBUTE14 := p_attachment_rec.ATTRIBUTE14;
  l_act_attachment_rec.ATTRIBUTE15 := p_attachment_rec.ATTRIBUTE15;
  l_act_attachment_rec.DISPLAY_URL := p_attachment_rec.DISPLAY_URL;

  -- fnd_global.apps_initialize(fnd_global.user_id, fnd_global.resp_id, 671);
  -- l_appl_id := FND_GLOBAL.resp_appl_id;
  -- comment out by G. Zhang 04/30/2001 11:18AM
  --l_appl_id := 671;
  --l_act_attachment_rec.APPLICATION_ID := l_appl_id;
  --l_act_attachment_rec.ATTACHMENT_USED_BY := 'ITEM';

  -- modified by G. Zhang 04/30/2001 11:18AM
  l_act_attachment_rec.APPLICATION_ID := p_attachment_rec.APPLICATION_ID;
  l_act_attachment_rec.ATTACHMENT_USED_BY := p_attachment_rec.ATTACHMENT_USED_BY;

  l_act_attachment_rec.attachment_id := p_attachment_rec.attachment_id;
  l_act_attachment_rec.file_name := TRIM(p_attachment_rec.file_name);
  l_act_attachment_rec.object_version_number := p_attachment_rec.object_version_number;
  -- BUG # 1715934 - need ability to have one attachment
  -- being used by mutiple items.
  --IF NOT JTF_DSPMGRVALIDATION_GRP.check_attachment_filename(
  --  l_act_attachment_rec.attachment_id,
  --  l_act_attachment_rec.file_name) THEN
  --  RAISE FND_API.g_exc_error;
  --END IF;

  --added by G. Zhang 04/30/2001 11:18AM
  IF l_act_attachment_rec.APPLICATION_ID IS NULL THEN
  	RAISE FND_API.g_exc_error;
  END IF;
  IF l_act_attachment_rec.ATTACHMENT_USED_BY IS NULL THEN
  	RAISE FND_API.g_exc_error;
  END IF;

  IF l_act_attachment_rec.attachment_id IS NOT NULL THEN
    -- Update an existing attachment
    l_operation_type := 'UPDATE';
  ELSE
    IF NOT JTF_DSPMGRVALIDATION_GRP.check_deliverable_exists(
      p_attachment_rec.deliverable_id) THEN
      RAISE FND_API.g_exc_error;
    END IF;
  END IF;

  IF (l_operation_type = 'INSERT') THEN
    l_act_attachment_rec.attachment_used_by_id := p_attachment_rec.deliverable_id;

    JTF_AMV_ATTACHMENT_PUB.create_act_attachment(
      p_api_version		=> g_amv_api_version,
      x_return_status	=> l_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data		=> x_msg_data,
      p_act_attachment_rec => l_act_attachment_rec,
      x_act_attachment_id	=> l_attachment_id
                                                );

    IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    -- update the attachment_id and object_version_number
    p_attachment_rec.attachment_id := l_attachment_id;
    p_attachment_rec.object_version_number := 1;

  ELSE

    l_act_attachment_rec.attachment_used_by_id
      := FND_API.G_MISS_NUM;

    JTF_AMV_ATTACHMENT_PUB.update_act_attachment(
      p_api_version       => g_amv_api_version,
      x_return_status     => l_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data,
      p_act_attachment_rec => l_act_attachment_rec
                                                );

    IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    -- update the object_version_number
    p_attachment_rec.object_version_number :=
      p_attachment_rec.object_version_number + 1;

  END IF;

  p_attachment_rec.x_action_status
    := FND_API.g_ret_sts_success;

  -- Check if the caller requested to commit ,
  -- If p_commit set to true, commit the transaction
  IF  FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.count_and_get(
    p_encoded		=>	FND_API.g_false,
    p_count		=>	x_msg_count,
    p_data		=>	x_msg_data
                           );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
     ROLLBACK TO save_attachment_grp;
     x_return_status := FND_API.g_ret_sts_error;
     p_attachment_rec.x_action_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.count_and_get(
       p_encoded      =>   FND_API.g_false,
       p_count        =>   x_msg_count,
       p_data         =>   x_msg_data
                              );

   WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO save_attachment_grp;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     p_attachment_rec.x_action_status := FND_API.g_ret_sts_unexp_error;
     FND_MSG_PUB.count_and_get(
       p_encoded      =>   FND_API.g_false,
       p_count        =>   x_msg_count,
       p_data         =>   x_msg_data
                              );

   WHEN OTHERS THEN
     ROLLBACK TO save_attachment_grp;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     p_attachment_rec.x_action_status := FND_API.g_ret_sts_unexp_error;

     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
       FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
     END IF;

     FND_MSG_PUB.count_and_get(
       p_encoded		=>	FND_API.g_false,
       p_count		=>	x_msg_count,
       p_data		=>	x_msg_data
                              );

END save_attachment;


---------------------------------------------------------------------
-- PROCEDURE
--    save_attachment
--
-- PURPOSE
--    Save a collection of physical attachments
--
-- PARAMETERS
--    p_attachment_tbl: A collection of the physical attachments to be saved
--
-- NOTES
--    1. Insert a new attachment if the attachment_id is null; Update otherwise
--    2. Raise an exception if file_name is null or not unique
--    3. Raise an exception if the deliverable doesn't exist (create)
--    4. Raise an exception if the attachment doesn't exist; or the version
--       doesn't match (update)
--    5. Raise an exception for any other errors
---------------------------------------------------------------------
PROCEDURE save_attachment (
                           p_api_version            IN   NUMBER,
                           p_init_msg_list          IN   VARCHAR2 := FND_API.g_false,
  p_commit                 IN   VARCHAR2 := FND_API.g_false,
  x_return_status          OUT  VARCHAR2,
  x_msg_count              OUT  NUMBER,
  x_msg_data               OUT  VARCHAR2,
  p_attachment_tbl         IN OUT ATTACHMENT_TBL_TYPE ) IS

  l_api_name CONSTANT VARCHAR2(30) := 'save_attachment';
  l_full_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_return_status VARCHAR2(1);

  l_index NUMBER;

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT save_attachment_grp;

  -- Standard call to check for call compatibility
  IF NOT FND_API.compatible_api_call(
    g_api_version,
    p_api_version,
    l_api_name,
    g_pkg_name
                                    ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API rturn status to success
  x_return_status := FND_API.g_ret_sts_success;

  -- API body

  IF p_attachment_tbl IS NOT NULL THEN
    FOR l_index IN 1..p_attachment_tbl.COUNT LOOP

      save_attachment(
        p_api_version		=> p_api_version,
        x_return_status	=> l_return_status,
        x_msg_count		=> x_msg_count,
        x_msg_data		=> x_msg_data,
        p_attachment_rec	=> p_attachment_tbl(l_index)
                     );


      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error
        AND x_return_status <> FND_API.g_ret_sts_unexp_error THEN
        x_return_status := FND_API.g_ret_sts_error;
      END IF;

    END LOOP;
  END IF;

  -- Check if the caller requested to commit ,
  -- If p_commit set to true, commit the transaction
  IF  FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.count_and_get(
    p_encoded      =>   FND_API.g_false,
    p_count        =>   x_msg_count,
    p_data         =>   x_msg_data
                           );


EXCEPTION

   WHEN FND_API.g_exc_error THEN
     ROLLBACK TO save_attachment_grp;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.count_and_get(
       p_encoded      =>   FND_API.g_false,
       p_count        =>   x_msg_count,
       p_data         =>   x_msg_data
                              );

   WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO save_attachment_grp;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     FND_MSG_PUB.count_and_get(
       p_encoded      =>   FND_API.g_false,
       p_count        =>   x_msg_count,
         p_data         =>   x_msg_data
                              );

   WHEN OTHERS THEN
     ROLLBACK TO save_attachment_grp;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     FND_MSG_PUB.count_and_get(
       p_encoded      =>   FND_API.g_false,
       p_count        =>   x_msg_count,
       p_data         =>   x_msg_data
                              );

     x_return_status := FND_API.g_ret_sts_unexp_error ;

     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
       FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
     END IF;

     FND_MSG_PUB.count_and_get(
       p_encoded      =>   FND_API.g_false,
       p_count        =>   x_msg_count,
       p_data         =>   x_msg_data
                              );

END save_attachment;


-------------------------------------------------------------------
-- PROCEDURE
--    delete_attachment
--
-- PURPOSE
--    Delete a collection of physical attachments
--
-- PARAMETERS
--    p_ath_id_ver_tbl: A collection of IDs and versions of the physical
--	 attachments to be deleted
--
-- NOTES
--    1. Delete all the attachments and associated physical_site_language
--	    mappings
--	 2. Raise an exception if the attachment doesn't exist; or the version
--	    doesn't match
--    3. Raise an exception for any other errors
---------------------------------------------------------------------
PROCEDURE delete_attachment (
                             p_api_version			IN	NUMBER,
                             p_init_msg_list		IN	VARCHAR2 := FND_API.g_false,
  p_commit				IN	VARCHAR2  := FND_API.g_false,
  x_return_status		OUT	VARCHAR2,
  x_msg_count			OUT	NUMBER,
  x_msg_data			OUT	VARCHAR2,
  p_ath_id_ver_tbl		IN OUT ATH_ID_VER_TBL_TYPE ) IS

  l_api_name CONSTANT VARCHAR2(30) := 'delete_attachment';
  l_full_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_index NUMBER;

  l_return_status VARCHAR2(1);

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT save_attachment_grp;

  -- Standard call to check for call compatibility
  IF NOT FND_API.compatible_api_call(
    g_api_version,
    p_api_version,
    l_api_name,
    g_pkg_name
                                    ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API rturn status to success
  x_return_status := FND_API.g_ret_sts_success;

  -- API body

  IF p_ath_id_ver_tbl IS NOT NULL THEN
    FOR l_index IN 1..p_ath_id_ver_tbl.COUNT LOOP
BEGIN

  -- Standard start of API savepoint
  SAVEPOINT delete_one_attachment_grp;

  /*
			p_ath_id_ver_tbl(l_index).x_action_status
				:= FND_API.g_ret_sts_error;
			*/

  IF NOT JTF_DSPMGRVALIDATION_GRP.check_attachment_exists(
  p_ath_id_ver_tbl(l_index).attachment_id,
  p_ath_id_ver_tbl(l_index).object_version_number) THEN
  RAISE FND_API.g_exc_error;
  END IF;

  JTF_PhysicalMap_GRP.delete_attachment(
    p_ath_id_ver_tbl(l_index).attachment_id
                                       );

  -- Delete the attachment
  JTF_AMV_ATTACHMENT_PUB.delete_act_attachment(
    p_api_version		=> g_amv_api_version,
    x_return_status	=> l_return_status,
    x_msg_count		=> x_msg_count,
    x_msg_data		=> x_msg_data,
    p_act_attachment_id	=> p_ath_id_ver_tbl(l_index).attachment_id,
    p_object_version	=> p_ath_id_ver_tbl(l_index).object_version_number
                                              );

  IF l_return_status = FND_API.g_ret_sts_error THEN
    RAISE FND_API.g_exc_error;
  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  p_ath_id_ver_tbl(l_index).x_action_status
    := FND_API.g_ret_sts_success;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
     ROLLBACK TO delete_one_attachment_grp;
     IF x_return_status <> FND_API.g_ret_sts_unexp_error THEN
       x_return_status := FND_API.g_ret_sts_error;
     END IF;
     p_ath_id_ver_tbl(l_index).x_action_status
       := FND_API.g_ret_sts_error;

   WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO delete_one_attachment_grp;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     p_ath_id_ver_tbl(l_index).x_action_status
       := FND_API.g_ret_sts_unexp_error ;

   WHEN OTHERS THEN
     ROLLBACK TO delete_one_attachment_grp;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     p_ath_id_ver_tbl(l_index).x_action_status
       := FND_API.g_ret_sts_unexp_error ;
     IF FND_MSG_PUB.check_msg_level(
       FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
       FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
     END IF;

END;
    END LOOP;
  END IF;

  -- Check if the caller requested to commit ,
  -- If p_commit set to true, commit the transaction
  IF  FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.count_and_get(
    p_encoded      =>   FND_API.g_false,
    p_count        =>   x_msg_count,
    p_data         =>   x_msg_data
                           );
  -- x_msg_count := FND_MSG_PUB.count_msg();
  -- x_msg_data := FND_MSG_PUB.get(FND_MSG_PUB.g_last, FND_API.g_false);

EXCEPTION

   WHEN FND_API.g_exc_error THEN
     ROLLBACK TO delete_attachment_grp;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.count_and_get(
       p_encoded      =>   FND_API.g_false,
       p_count        =>   x_msg_count,
       p_data         =>   x_msg_data
                              );

   WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO delete_attachment_grp;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     FND_MSG_PUB.count_and_get(
       p_encoded      =>   FND_API.g_false,
       p_count        =>   x_msg_count,
       p_data         =>   x_msg_data
                              );

   WHEN OTHERS THEN
     ROLLBACK TO delete_attachment_grp;
     x_return_status := FND_API.g_ret_sts_unexp_error ;

     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
       FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
     END IF;

     FND_MSG_PUB.count_and_get(
       p_encoded      =>   FND_API.g_false,
       p_count        =>   x_msg_count,
       p_data         =>   x_msg_data
                              );

END delete_attachment;


END JTF_Attachment_GRP;

/
