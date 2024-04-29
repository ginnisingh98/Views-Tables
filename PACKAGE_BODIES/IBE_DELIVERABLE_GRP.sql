--------------------------------------------------------
--  DDL for Package Body IBE_DELIVERABLE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_DELIVERABLE_GRP" AS
/* $Header: IBEGDLVB.pls 120.0 2005/05/30 03:31:26 appldev noship $ */

/*
===================================================================
--             Copyright (c) 1999 Oracle Corporation            --
--                Redwood Shores, California, USA               --
--                     All rights reserved.                     --
------------------------------------------------------------------


-----------------------------------------------------------
-- PACKAGE
--	 IBE_Deliverable_GRP
--
-- PROCEDURES
--    save_deliverable
--    delete_deliverable
--	 list_deliverable
-- HISTORY
--    11/27/99	wxyu	Created
--    05/17/01	G. Zhang Modified to support DB Media
--    05/13/02  YAXU modified to support updateing the item_type
--    11/14/02  abhandar modified to support updateing the applicable_to

--   12/31/02    SCHAK       Modified for NOCOPY (Bug # 2691704) Changes.
--   03/01/03    SCHAK       Modified for NOCOPY changes.

================================================================================
  */

g_amv_api_version CONSTANT NUMBER := 1.0;

TYPE DlvCurTyp IS REF CURSOR;

PROCEDURE list_deliverable (
                            p_api_version            IN   NUMBER,
                            p_init_msg_list          IN   VARCHAR2 := FND_API.g_false,
  x_return_status          OUT NOCOPY  VARCHAR2,
  x_msg_count              OUT NOCOPY  NUMBER,
  x_msg_data               OUT NOCOPY  VARCHAR2,
  p_item_type              IN   VARCHAR2,
  p_item_applicable_to     IN   VARCHAR2,
  p_search_type            IN   VARCHAR2,
  p_search_value           IN   VARCHAR2,
  p_start_id               IN   NUMBER,
  p_batch_size             IN   NUMBER,
  x_row_count              OUT NOCOPY  NUMBER,
  x_dlv_id_tbl             OUT NOCOPY  NUMBER_TABLE,
  x_acc_name_tbl           OUT NOCOPY  VARCHAR2_TABLE_100,
  x_dsp_name_tbl           OUT NOCOPY  VARCHAR2_TABLE_300,
  x_item_type_tbl          OUT NOCOPY  VARCHAR2_TABLE_100,
  x_appl_to_tbl            OUT NOCOPY  VARCHAR2_TABLE_100,
  x_keyword_tbl            OUT NOCOPY  VARCHAR2_TABLE_300,
  x_desc_tbl               OUT NOCOPY  VARCHAR2_TABLE_2000,
  x_version_tbl            OUT NOCOPY  NUMBER_TABLE,
  x_file_name_tbl          OUT NOCOPY  VARCHAR2_TABLE_300,

  --added by G. Zhang 05/17/01 5:42PM
  x_file_id_tbl          OUT NOCOPY  NUMBER_TABLE ) IS

BEGIN

  list_deliverable(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    NULL,
    p_item_type,
    p_item_applicable_to,
    p_search_type,
    p_search_value,
    p_start_id,
    p_batch_size,
    x_row_count,
    x_dlv_id_tbl,
    x_acc_name_tbl,
    x_dsp_name_tbl,
    x_item_type_tbl,
    x_appl_to_tbl,
    x_keyword_tbl,
    x_desc_tbl,
    x_version_tbl,
    x_file_name_tbl,

    --added by G. Zhang  05/17/01 5:42PM
    x_file_id_tbl
                  );

END list_deliverable;


PROCEDURE list_deliverable (
                            p_api_version            IN   NUMBER,
                            p_init_msg_list          IN   VARCHAR2 := FND_API.g_false,
  x_return_status          OUT NOCOPY  VARCHAR2,
  x_msg_count              OUT NOCOPY  NUMBER,
  x_msg_data               OUT NOCOPY  VARCHAR2,
  p_category_id			IN	NUMBER,
  p_item_type			IN	VARCHAR2,
  p_item_applicable_to	        IN      VARCHAR2,
  p_search_type			IN	VARCHAR2,
  p_search_value		IN	VARCHAR2,
  p_start_id			IN	NUMBER,
  p_batch_size			IN 	NUMBER,
  x_row_count			OUT NOCOPY	NUMBER,
  x_dlv_id_tbl			OUT NOCOPY	NUMBER_TABLE,
  x_acc_name_tbl		OUT NOCOPY	VARCHAR2_TABLE_100,
  x_dsp_name_tbl		OUT NOCOPY	VARCHAR2_TABLE_300,
  x_item_type_tbl		OUT NOCOPY	VARCHAR2_TABLE_100,
  x_appl_to_tbl			OUT NOCOPY	VARCHAR2_TABLE_100,
  x_keyword_tbl			OUT NOCOPY	VARCHAR2_TABLE_300,
  x_desc_tbl			OUT NOCOPY	VARCHAR2_TABLE_2000,
  x_version_tbl			OUT NOCOPY	NUMBER_TABLE,
  x_file_name_tbl		OUT NOCOPY	VARCHAR2_TABLE_300,

  --added by G. Zhang  05/17/01 5:42PM
  x_file_id_tbl		OUT NOCOPY	NUMBER_TABLE ) IS

  l_api_name CONSTANT VARCHAR2(30) := 'list_deliverable';
  l_full_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_return_status VARCHAR2(1);

  l_dlv_cv DlvCurTyp;
  l_flag NUMBER := 0;
  l_search_value VARCHAR2(240);
  sql_cond VARCHAR2(480) := 'FROM ibe_dsp_amv_items_v WHERE application_id = :appl_id ';
  sql_stmt VARCHAR2(960);

  start_pnt NUMBER;
  end_pnt NUMBER;

  l_dlv_id_tbl JTF_NUMBER_TABLE;
  l_acc_name_tbl JTF_VARCHAR2_TABLE_100;
  l_dsp_name_tbl JTF_VARCHAR2_TABLE_300;
  l_item_type_tbl JTF_VARCHAR2_TABLE_100;
  l_appl_to_tbl JTF_VARCHAR2_TABLE_100;
  l_keyword_tbl JTF_VARCHAR2_TABLE_300;
  l_desc_tbl JTF_VARCHAR2_TABLE_2000;
  l_version_tbl JTF_NUMBER_TABLE;
  l_file_name_tbl JTF_VARCHAR2_TABLE_300;

  --added by G. Zhang 05/17/01 5:42PM
  l_file_id_tbl JTF_NUMBER_TABLE;

  l_index NUMBER;
  l_count NUMBER;

  l_appl_id NUMBER;

  l_item_applicable_to VARCHAR2(30) := p_item_applicable_to;
BEGIN

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

  IF p_start_id < -1 OR p_batch_size < 0
    OR (p_start_id = -1 AND p_batch_size = 0) THEN
    FND_MESSAGE.set_name('IBE', 'IBE_DSP_QUERY_INVLD');
    FND_MESSAGE.set_token('0', TO_CHAR(p_start_id));
    FND_MESSAGE.set_token('1', TO_CHAR(p_batch_size));
    FND_MSG_PUB.add;
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF p_category_id IS NOT NULL
    AND TRIM(p_item_applicable_to) <> 'CATEGORY' THEN
    FND_MESSAGE.set_name('IBE', 'IBE_DSP_AVAIL_INVLD');
    FND_MESSAGE.set_token('0', TO_CHAR(p_category_id));
    FND_MESSAGE.set_token('1', p_item_applicable_to);
    FND_MSG_PUB.add;
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF TRIM(p_item_type) IS NOT NULL THEN
    l_flag := 1;
    sql_cond := sql_cond || 'AND deliverable_type_code = :item_type ';
  END IF;

  IF TRIM(p_item_applicable_to) IS NOT NULL THEN
    l_flag := l_flag + 10;
    sql_cond := sql_cond || 'AND applicable_to_code = :appl_to ';
  END IF;

  IF TRIM(p_search_type) IS NOT NULL AND TRIM(p_search_value) IS NOT NULL THEN
    l_flag := l_flag + 100;
    l_search_value := '%' || LOWER(TRIM(p_search_value)) || '%';
    sql_cond := sql_cond || 'AND LOWER(' || p_search_type || ') LIKE :value ';
  END IF;

  IF p_category_id IS NOT NULL THEN
    l_flag := l_flag + 1000;
    sql_cond := sql_cond
      || 'AND item_id NOT IN (SELECT item_id ' ||
      ' FROM ibe_dsp_tpl_ctg '
      || 'WHERE category_id = :ctg_id) ';
  END IF;

  -- dbms_output.put_line('resp_appl_id=' || FND_GLOBAL.resp_appl_id);

  -- fnd_global.apps_initialize(fnd_global.user_id, fnd_global.resp_id, 671);
  -- l_appl_id := FND_GLOBAL.resp_appl_id;
  l_appl_id := 671;

  -- Get Total Row Number
  sql_stmt := 'SELECT COUNT(*) ' || sql_cond;
  IF l_flag = 1111 THEN
    OPEN l_dlv_cv FOR sql_stmt USING l_appl_id,
      p_item_type, p_item_applicable_to, l_search_value, p_category_id;
  ELSIF l_flag = 1110 THEN
    OPEN l_dlv_cv FOR sql_stmt USING l_appl_id,
      p_item_applicable_to, l_search_value, p_category_id;
  ELSIF l_flag = 1101 THEN
    OPEN l_dlv_cv FOR sql_stmt USING l_appl_id,
      p_item_type, l_search_value, p_category_id;
  ELSIF l_flag = 1100 THEN
    OPEN l_dlv_cv FOR sql_stmt USING l_appl_id,
      l_search_value, p_category_id;
  ELSIF l_flag = 1011 THEN
    OPEN l_dlv_cv FOR sql_stmt USING l_appl_id,
      p_item_type, p_item_applicable_to, p_category_id;
  ELSIF l_flag = 1010 THEN
    OPEN l_dlv_cv FOR sql_stmt USING l_appl_id,
      p_item_applicable_to, p_category_id;
  ELSIF l_flag = 1001 THEN
    OPEN l_dlv_cv FOR sql_stmt USING l_appl_id,
      p_item_type, p_category_id;
  ELSIF l_flag = 1000 THEN
    OPEN l_dlv_cv FOR sql_stmt USING l_appl_id,
      p_category_id;
  ELSIF l_flag = 111 THEN
    OPEN l_dlv_cv FOR sql_stmt USING l_appl_id,
      p_item_type, p_item_applicable_to, l_search_value;
  ELSIF l_flag = 110 THEN
    OPEN l_dlv_cv FOR sql_stmt USING l_appl_id,
      p_item_applicable_to, l_search_value;
  ELSIF l_flag = 101 THEN
    OPEN l_dlv_cv FOR sql_stmt USING l_appl_id,
      p_item_type, l_search_value;
  ELSIF l_flag = 100 THEN
    OPEN l_dlv_cv FOR sql_stmt USING l_appl_id,
      l_search_value;
  ELSIF l_flag = 11 THEN
    OPEN l_dlv_cv FOR sql_stmt USING l_appl_id,
      p_item_type, p_item_applicable_to;
  ELSIF l_flag = 10 THEN
    OPEN l_dlv_cv FOR sql_stmt USING l_appl_id,
      p_item_applicable_to;
  ELSIF l_flag = 1 THEN
    OPEN l_dlv_cv FOR sql_stmt USING l_appl_id,
      p_item_type;
  ELSE
    OPEN l_dlv_cv FOR sql_stmt USING l_appl_id;
  END IF;

  FETCH l_dlv_cv INTO x_row_count;
  CLOSE l_dlv_cv;

  IF x_row_count = 0 THEN
    FND_MSG_PUB.count_and_get(
      p_encoded      =>   FND_API.g_false,
      p_count        =>   x_msg_count,
      p_data         =>   x_msg_data
                             );
      RETURN;
  END IF;

  x_dlv_id_tbl := NULL;
  x_acc_name_tbl := NULL;
  x_dsp_name_tbl := NULL;
  x_item_type_tbl := NULL;
  x_appl_to_tbl := NULL;
  x_desc_tbl := NULL;
  x_keyword_tbl := NULL;
  x_file_name_tbl := NULL;

  --added by G. Zhang 05/17/01 5:42PM
  x_file_id_tbl :=NULL;

  x_version_tbl := NULL;

  -- Get matched rows
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

  sql_stmt := 'BEGIN '
    || 'SELECT item_id, access_name, item_name, deliverable_type_code, '

    --modified by G. Zhang 05/17/01 5:42PM
    || 'applicable_to_code, description, keyword, file_name, file_id, '

    || 'object_version_number '
    || 'BULK COLLECT INTO :id_tbl, :acc_tbl, :dsp_tbl, :type_tbl, '

    --modified by G. Zhang 05/17/01 5:42PM
    || ':appl_tbl, :desc_tbl, :key_tbl, :file_tbl, :file_id_tbl, :version_tbl '

    || 'FROM (SELECT * '
    || sql_cond
    || 'ORDER BY item_name ) '
    || 'WHERE ROWNUM <= :row_num '
    || '; END;';

  -- dbms_output.put_line('sql_cond=' || sql_cond);
  -- dbms_output.put_line('row_num=' || end_pnt);
  -- dbms_output.put_line('sql_stmt=' || sql_stmt);

  IF l_flag = 1111 THEN
    EXECUTE IMMEDIATE sql_stmt USING
      OUT l_dlv_id_tbl, OUT l_acc_name_tbl, OUT l_dsp_name_tbl,
      OUT l_item_type_tbl, OUT l_appl_to_tbl, OUT l_desc_tbl,

      --modified by G. Zhang 05/17/01 5:42PM
      OUT l_keyword_tbl, OUT l_file_name_tbl, OUT l_file_id_tbl, OUT l_version_tbl,

      l_appl_id,
      p_item_type, p_item_applicable_to, l_search_value,
      p_category_id,
      end_pnt;
  ELSIF l_flag = 1110 THEN
    EXECUTE IMMEDIATE sql_stmt USING
      OUT l_dlv_id_tbl, OUT l_acc_name_tbl, OUT l_dsp_name_tbl,
      OUT l_item_type_tbl, OUT l_appl_to_tbl, OUT l_desc_tbl,

      --modified by G. Zhang 05/17/01 5:42PM
      OUT l_keyword_tbl, OUT l_file_name_tbl, OUT l_file_id_tbl, OUT l_version_tbl,

      l_appl_id,
      p_item_applicable_to, l_search_value,
      p_category_id,
      end_pnt;
  ELSIF l_flag = 1101 THEN
    EXECUTE IMMEDIATE sql_stmt USING
      OUT l_dlv_id_tbl, OUT l_acc_name_tbl, OUT l_dsp_name_tbl,
      OUT l_item_type_tbl, OUT l_appl_to_tbl, OUT l_desc_tbl,

      --modified by G. Zhang 05/17/01 5:42PM
      OUT l_keyword_tbl, OUT l_file_name_tbl, OUT l_file_id_tbl, OUT l_version_tbl,

      l_appl_id,
      p_item_type, l_search_value,
      p_category_id,
      end_pnt;
  ELSIF l_flag = 1100 THEN
    EXECUTE IMMEDIATE sql_stmt USING
      OUT l_dlv_id_tbl, OUT l_acc_name_tbl, OUT l_dsp_name_tbl,
      OUT l_item_type_tbl, OUT l_appl_to_tbl, OUT l_desc_tbl,

      --modified by G. Zhang 05/17/01 5:42PM
      OUT l_keyword_tbl, OUT l_file_name_tbl, OUT l_file_id_tbl, OUT l_version_tbl,

      l_appl_id,
      l_search_value,
      p_category_id,
      end_pnt;
  ELSIF l_flag = 1011 THEN
    EXECUTE IMMEDIATE sql_stmt USING
      OUT l_dlv_id_tbl, OUT l_acc_name_tbl, OUT l_dsp_name_tbl,
      OUT l_item_type_tbl, OUT l_appl_to_tbl, OUT l_desc_tbl,

      --modified by G. 3
      OUT l_keyword_tbl, OUT l_file_name_tbl, OUT l_file_id_tbl, OUT l_version_tbl,

      l_appl_id,
      p_item_type, p_item_applicable_to,
      p_category_id,
      end_pnt;
  ELSIF l_flag = 1010 THEN
    EXECUTE IMMEDIATE sql_stmt USING
      OUT l_dlv_id_tbl, OUT l_acc_name_tbl, OUT l_dsp_name_tbl,
      OUT l_item_type_tbl, OUT l_appl_to_tbl, OUT l_desc_tbl,

      --modified by G. Zhang 05/17/01 5:42PM
      OUT l_keyword_tbl, OUT l_file_name_tbl, OUT l_file_id_tbl, OUT l_version_tbl,

      l_appl_id,
      p_item_applicable_to,
      p_category_id,
      end_pnt;
  ELSIF l_flag = 1001 THEN
    EXECUTE IMMEDIATE sql_stmt USING
      OUT l_dlv_id_tbl, OUT l_acc_name_tbl, OUT l_dsp_name_tbl,
      OUT l_item_type_tbl, OUT l_appl_to_tbl, OUT l_desc_tbl,

      --added by G. Zhang 05/17/01 5:42PM
      OUT l_keyword_tbl, OUT l_file_name_tbl, OUT l_file_id_tbl, OUT l_version_tbl,

      l_appl_id,
      p_item_type,
      p_category_id,
      end_pnt;
  ELSIF l_flag = 1000 THEN
    EXECUTE IMMEDIATE sql_stmt USING
      OUT l_dlv_id_tbl, OUT l_acc_name_tbl, OUT l_dsp_name_tbl,
      OUT l_item_type_tbl, OUT l_appl_to_tbl, OUT l_desc_tbl,

      --modified by G. Zhang 05/17/01 5:42PM
      OUT l_keyword_tbl, OUT l_file_name_tbl, OUT l_file_id_tbl, OUT l_version_tbl,

      l_appl_id,
      p_category_id,
      end_pnt;
  ELSIF l_flag = 111 THEN
    EXECUTE IMMEDIATE sql_stmt USING
      OUT l_dlv_id_tbl, OUT l_acc_name_tbl, OUT l_dsp_name_tbl,
      OUT l_item_type_tbl, OUT l_appl_to_tbl, OUT l_desc_tbl,

      --modified by G. Zhang 05/17/01 5:42PM
      OUT l_keyword_tbl, OUT l_file_name_tbl, OUT l_file_id_tbl, OUT l_version_tbl,

      l_appl_id,
      p_item_type, p_item_applicable_to, l_search_value, end_pnt;
  ELSIF l_flag = 110 THEN
    EXECUTE IMMEDIATE sql_stmt USING
      OUT l_dlv_id_tbl, OUT l_acc_name_tbl, OUT l_dsp_name_tbl,
      OUT l_item_type_tbl, OUT l_appl_to_tbl, OUT l_desc_tbl,

      --modified by G. Zhang 05/17/01 5:42PM
      OUT l_keyword_tbl, OUT l_file_name_tbl, OUT l_file_id_tbl, OUT l_version_tbl,

      l_appl_id,
      p_item_applicable_to, l_search_value, end_pnt;
  ELSIF l_flag = 101 THEN
    EXECUTE IMMEDIATE sql_stmt USING
      OUT l_dlv_id_tbl, OUT l_acc_name_tbl, OUT l_dsp_name_tbl,
      OUT l_item_type_tbl, OUT l_appl_to_tbl, OUT l_desc_tbl,

      --modified by G. Zhang 05/17/01 5:42PM
      OUT l_keyword_tbl, OUT l_file_name_tbl, OUT l_file_id_tbl, OUT l_version_tbl,

      l_appl_id,
      p_item_type, l_search_value, end_pnt;
  ELSIF l_flag = 100 THEN
    EXECUTE IMMEDIATE sql_stmt USING
      OUT l_dlv_id_tbl, OUT l_acc_name_tbl, OUT l_dsp_name_tbl,
      OUT l_item_type_tbl, OUT l_appl_to_tbl, OUT l_desc_tbl,

      --modified by G. Zhang 05/17/01 5:42PM
      OUT l_keyword_tbl, OUT l_file_name_tbl, OUT l_file_id_tbl, OUT l_version_tbl,

      l_appl_id,
      l_search_value, end_pnt;
  ELSIF l_flag = 11 THEN
    EXECUTE IMMEDIATE sql_stmt USING
      OUT l_dlv_id_tbl, OUT l_acc_name_tbl, OUT l_dsp_name_tbl,
      OUT l_item_type_tbl, OUT l_appl_to_tbl, OUT l_desc_tbl,

      --modified by G. Zhang 05/17/01 5:42PM
      OUT l_keyword_tbl, OUT l_file_name_tbl, OUT l_file_id_tbl, OUT l_version_tbl,

      l_appl_id,
      p_item_type, p_item_applicable_to, end_pnt;
  ELSIF l_flag = 10 THEN
    EXECUTE IMMEDIATE sql_stmt USING
      OUT l_dlv_id_tbl, OUT l_acc_name_tbl, OUT l_dsp_name_tbl,
      OUT l_item_type_tbl, OUT l_appl_to_tbl, OUT l_desc_tbl,

      --modified by G. Zhang 05/17/01 5:42PM
      OUT l_keyword_tbl, OUT l_file_name_tbl, OUT l_file_id_tbl, OUT l_version_tbl,

      l_appl_id,
      p_item_applicable_to, end_pnt;
  ELSIF l_flag = 1 THEN
    EXECUTE IMMEDIATE sql_stmt USING
      OUT l_dlv_id_tbl, OUT l_acc_name_tbl, OUT l_dsp_name_tbl,
      OUT l_item_type_tbl, OUT l_appl_to_tbl, OUT l_desc_tbl,

      --modified by G. Zhang 05/17/01 5:42PM
      OUT l_keyword_tbl, OUT l_file_name_tbl, OUT l_file_id_tbl, OUT l_version_tbl,

      l_appl_id,
      p_item_type, end_pnt;
  ELSE
    EXECUTE IMMEDIATE sql_stmt USING
      OUT l_dlv_id_tbl, OUT l_acc_name_tbl, OUT l_dsp_name_tbl,
      OUT l_item_type_tbl, OUT l_appl_to_tbl, OUT l_desc_tbl,

      --modified by G. Zhang 05/17/01 5:42PM
      OUT l_keyword_tbl, OUT l_file_name_tbl, OUT l_file_id_tbl, OUT l_version_tbl,

      l_appl_id,
      end_pnt;
  END IF;

  -- dbms_output.put_line('executed');

  IF l_dlv_id_tbl IS NOT NULL AND start_pnt <= l_dlv_id_tbl.COUNT THEN
    x_dlv_id_tbl := NUMBER_TABLE(l_dlv_id_tbl(start_pnt));
    x_acc_name_tbl := VARCHAR2_TABLE_100(l_acc_name_tbl(start_pnt));
    x_dsp_name_tbl := VARCHAR2_TABLE_300(l_dsp_name_tbl(start_pnt));
    x_item_type_tbl := VARCHAR2_TABLE_100(l_item_type_tbl(start_pnt));
    x_appl_to_tbl := VARCHAR2_TABLE_100(l_appl_to_tbl(start_pnt));
    x_desc_tbl := VARCHAR2_TABLE_2000(l_desc_tbl(start_pnt));
    x_keyword_tbl := VARCHAR2_TABLE_300(l_keyword_tbl(start_pnt));
    x_file_name_tbl := VARCHAR2_TABLE_300(l_file_name_tbl(start_pnt));

    --added by G. Zhang 05/17/01 5:42PM
    x_file_id_tbl := NUMBER_TABLE(l_file_id_tbl(start_pnt));

    x_version_tbl := NUMBER_TABLE(l_version_tbl(start_pnt));

    l_count := 1;
    FOR l_index IN start_pnt+1..l_dlv_id_tbl.COUNT LOOP
      IF l_index > end_pnt THEN
        EXIT;
      END IF;
      x_dlv_id_tbl.EXTEND;
      x_acc_name_tbl.EXTEND;
      x_dsp_name_tbl.EXTEND;
      x_item_type_tbl.EXTEND;
      x_appl_to_tbl.EXTEND;
      x_desc_tbl.EXTEND;
      x_keyword_tbl.EXTEND;
      x_file_name_tbl.EXTEND;

      --added by G. Zhang 05/17/01 5:42PM
      x_file_id_tbl.EXTEND;

      x_version_tbl.EXTEND;

      l_count := l_count + 1;
      x_dlv_id_tbl(l_count) := l_dlv_id_tbl(l_index);
      x_acc_name_tbl(l_count) := l_acc_name_tbl(l_index);
      x_dsp_name_tbl(l_count) := l_dsp_name_tbl(l_index);
      x_item_type_tbl(l_count) := l_item_type_tbl(l_index);
      x_appl_to_tbl(l_count) := l_appl_to_tbl(l_index);
      x_desc_tbl(l_count) := l_desc_tbl(l_index);
      x_keyword_tbl(l_count) := l_keyword_tbl(l_index);
      x_file_name_tbl(l_count) := l_file_name_tbl(l_index);

      --added by G. Zhang 05/17/01 5:42PM
      x_file_id_tbl(l_count) := l_file_id_tbl(l_index);

      x_version_tbl(l_count) := l_version_tbl(l_index);
    END LOOP;
  END IF;

  /*
     -- Get matchined rows
	IF p_start_id > -1 THEN
		IF p_start_id >= x_row_count THEN
			RETURN;
		END IF;

		start_pnt := p_start_id;
		IF p_batch_size > 0 THEN
			end_pnt := p_start_id + p_batch_size;
		ELSE
			end_pnt := x_row_count;
		END IF;
	ELSE
		end_pnt := x_row_count;
		start_pnt := end_pnt - p_batch_size;
		IF start_pnt < 0 THEN
			start_pnt := 0;
		END IF;
	END IF;

     IF l_flag = 111 THEN
		OPEN l_dlv_cv FOR sql_stmt USING FND_GLOBAL.resp_appl_id,
			p_item_type, p_item_applicable_to, l_search_value, end_pnt;
	ELSIF l_flag = 110 THEN
		OPEN l_dlv_cv FOR sql_stmt USING FND_GLOBAL.resp_appl_id,
			p_item_applicable_to, l_search_value, end_pnt;
	ELSIF l_flag = 101 THEN
		OPEN l_dlv_cv FOR sql_stmt USING FND_GLOBAL.resp_appl_id,
			p_item_type, l_search_value, end_pnt;
	ELSIF l_flag = 100 THEN
		OPEN l_dlv_cv FOR sql_stmt USING FND_GLOBAL.resp_appl_id,
			l_search_value, end_pnt;
	ELSIF l_flag = 11 THEN
		OPEN l_dlv_cv FOR sql_stmt USING FND_GLOBAL.resp_appl_id,
			p_item_type, p_item_applicable_to, end_pnt;
	ELSIF l_flag = 10 THEN
		OPEN l_dlv_cv FOR sql_stmt USING FND_GLOBAL.resp_appl_id,
			p_item_applicable_to, end_pnt;
	ELSIF l_flag = 1 THEN
		OPEN l_dlv_cv FOR sql_stmt USING FND_GLOBAL.resp_appl_id,
			p_item_type, end_pnt;
	ELSE
		OPEN l_dlv_cv FOR sql_stmt USING FND_GLOBAL.resp_appl_id, end_pnt;
	END IF;

	IF start_pnt > 0 THEN
		FETCH l_dlv_cv BULK COLLECT INTO l_dlv_id_tbl, l_acc_name_tbl,
			l_dsp_name_tbl, l_item_type_tbl, l_appl_to_tbl, l_desc_tbl,
			l_keyword_tbl, l_file_name_tbl, l_version_tbl LIMIT start_pnt;
		IF l_dlv_cv%NOTFOUND THEN
			CLOSE l_dlv_cv;
			RETURN;
		END IF;
	END IF;

	FETCH l_dlv_cv BULK COLLECT INTO x_dlv_id_tbl, x_acc_name_tbl,
		x_dsp_name_tbl, x_item_type_tbl, x_appl_to_tbl, x_desc_tbl,
		x_keyword_tbl, x_file_name_tbl, x_version_tbl;
	CLOSE l_dlv_cv;
*/

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.count_and_get(
    p_encoded      =>   FND_API.g_false,
    p_count        =>   x_msg_count,
    p_data         =>   x_msg_data
                           );

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

     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
       FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
     END IF;

     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

END list_deliverable;


---------------------------------------------------------------------
-- PROCEDURE
--    save_deliverable
--
-- PURPOSE
--    Save a logical deliverable
--
-- PARAMETERS
--    p_deliverable_rec:	The logical deliverables to be saved
--
-- NOTES
--    1. Insert a new deliverable if deliverable_id is null; update otherwise
--    2. Raise an exception if access_name or display_name is missing;
--	    or access_name is not unique
--	 3. Raise an exception if item_type or item_applicable_to is missing
--	    or invalid (create)
--	 4. Raise an exception if the deliverable doesn't exist; or the version
--	    doesn't match (update)
--    5. Raise an exception for any other errors

---------------------------------------------------------------------
PROCEDURE save_deliverable (
                            p_api_version			IN	NUMBER,
                            p_init_msg_list		IN	VARCHAR2 := FND_API.g_false,
  p_commit				IN	VARCHAR2 := FND_API.g_false,
  x_return_status		OUT NOCOPY	VARCHAR2,
  x_msg_count			OUT NOCOPY	NUMBER,
  x_msg_data			OUT NOCOPY	VARCHAR2,
  p_deliverable_rec		IN OUT NOCOPY DELIVERABLE_REC_TYPE ) IS

  l_api_name CONSTANT VARCHAR2(30) := 'save_deliverable';
  l_full_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_operation_type VARCHAR2(10) := 'INSERT';

  l_deliverable_id NUMBER;
  l_item_rec JTF_AMV_ITEM_PUB.ITEM_REC_TYPE;
  l_return_status VARCHAR2(1);

  l_appl_id NUMBER;

  l_temp NUMBER;
BEGIN

  -- Standard start of API savepoint
  SAVEPOINT save_deliverable_grp;

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

  l_item_rec.external_access_flag := NULL;
  l_item_rec.text_string := NULL;
  l_item_rec.language_code := NULL;
  l_item_rec.status_code := NULL;
  l_item_rec.effective_start_date := NULL;
  l_item_rec.EXPIRATION_DATE := NULL;
  l_item_rec.ITEM_TYPE := NULL;
  l_item_rec.URL_STRING := NULL;
  l_item_rec.PUBLICATION_DATE := NULL;
  l_item_rec.PRIORITY := NULL;
  l_item_rec.CONTENT_TYPE_ID := NULL;
  l_item_rec.OWNER_ID := NULL;
  l_item_rec.DEFAULT_APPROVER_ID := NULL;
  l_item_rec.ITEM_DESTINATION_TYPE := NULL;

  l_item_rec.creation_date := NULL;
  l_item_rec.created_by := NULL;
  l_item_rec.last_update_date := NULL;
  l_item_rec.last_updated_by := NULL;
  l_item_rec.last_update_login := NULL;

  -- fnd_global.apps_initialize(fnd_global.user_id, fnd_global.resp_id, 671);
  -- l_appl_id := FND_GLOBAL.resp_appl_id;
  l_appl_id := 671;

  l_item_rec.application_id := l_appl_id;

  /*
			p_deliverable_rec.x_action_status
				:= FND_API.g_ret_sts_error;
			*/

  l_item_rec.item_id
  := p_deliverable_rec.deliverable_id;
  l_item_rec.item_name
    := TRIM(p_deliverable_rec.display_name);
  l_item_rec.access_name
    := TRIM(p_deliverable_rec.access_name);
  l_item_rec.description := p_deliverable_rec.description;
  l_item_rec.object_version_number
    := p_deliverable_rec.object_version_number;

  IF NOT IBE_DSPMGRVALIDATION_GRP.check_deliverable_accessname(
    l_item_rec.item_id, l_item_rec.access_name) THEN
    RAISE FND_API.g_exc_error;
  END IF;

  IF l_item_rec.item_id IS NOT NULL THEN
    -- Update an existing deliverable
    l_operation_type := 'UPDATE';
  END IF;

  IF (l_operation_type = 'INSERT') THEN
    l_item_rec.deliverable_type_code
      := TRIM(p_deliverable_rec.item_type);
    l_item_rec.applicable_to_code
      := TRIM(p_deliverable_rec.item_applicable_to);

    -- new validation code for enhancement 2317704
    l_temp := IBE_DSPMGRVALIDATION_GRP.check_media_object(
	 p_operation => 'CREATE',
	 p_access_name => l_item_rec.access_name,
	 p_deliverable_type_code => l_item_rec.deliverable_type_code,
	 p_applicable_to_code => l_item_rec.applicable_to_code);
    IF l_temp < 0  THEN
	 RAISE FND_API.g_exc_error;
    END IF;
    -- end for enhancement 2317704
    JTF_AMV_ITEM_PUB.create_item(
      p_api_version		=> g_amv_api_version,
      x_return_status	=> l_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      p_item_rec		=> l_item_rec,
      x_item_id			=> l_deliverable_id
                                );

    IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    IF TRIM(p_deliverable_rec.keywords) IS NOT NULL THEN
      JTF_AMV_ITEM_PUB.add_itemkeyword(
        p_api_version		=> g_amv_api_version,
        x_return_status	=> l_return_status,
        x_msg_count		=> x_msg_count,
        x_msg_data		=> x_msg_data,
        p_item_id			=> l_deliverable_id,
        p_keyword	=> p_deliverable_rec.keywords
                                      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;
    END IF;

    p_deliverable_rec.deliverable_id := l_deliverable_id;
    p_deliverable_rec.object_version_number := 1;

  ELSE
--    05/13/02  YAXU modified to support updateing the item_type
    l_item_rec.deliverable_type_code := TRIM(p_deliverable_rec.item_type);
    IF l_item_rec.deliverable_type_code IS NULL THEN
       l_item_rec.deliverable_type_code := FND_API.g_miss_char;
    END IF;
   -- modified by abhandar to update the 'applicable to' also
   --l_item_rec.applicable_to_code  := FND_API.g_miss_char;
   l_item_rec.applicable_to_code := TRIM(p_deliverable_rec.item_applicable_to);
    IF l_item_rec.applicable_to_code IS NULL THEN
       l_item_rec.applicable_to_code := FND_API.g_miss_char;
    END IF;

    -- new validation code for enhancement 2317704
    l_temp := IBE_DSPMGRVALIDATION_GRP.check_media_object(
	 p_operation => 'UPDATE',
	 p_access_name => l_item_rec.access_name,
	 p_deliverable_type_code => l_item_rec.deliverable_type_code,
	 p_applicable_to_code => l_item_rec.applicable_to_code);
    IF l_temp < 0 THEN
	 RAISE FND_API.g_exc_error;
    END IF;
    -- end for enhancement 2317704
    JTF_AMV_ITEM_PUB.update_item(
      p_api_version       => g_amv_api_version,
      x_return_status     => l_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data,
      p_item_rec          => l_item_rec
                                );

    IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    -- Delete existing keywords
    JTF_AMV_ITEM_PUB.delete_itemkeyword(
      p_api_version		=> g_amv_api_version,
      x_return_status	=> l_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      p_item_id	=> p_deliverable_rec.deliverable_id,
      p_keyword_tab		=> NULL
                                       );

    IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    IF TRIM(p_deliverable_rec.keywords) IS NOT NULL THEN
      JTF_AMV_ITEM_PUB.add_itemkeyword(
        p_api_version		=> g_amv_api_version,
        x_return_status	=> l_return_status,
        x_msg_count		=> x_msg_count,
        x_msg_data		=> x_msg_data,
        p_item_id => p_deliverable_rec.deliverable_id,
        p_keyword			=> p_deliverable_rec.keywords
                                      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;
    END IF;

    -- update the object_version_number
    p_deliverable_rec.object_version_number :=
      p_deliverable_rec.object_version_number + 1;

  END IF;

  p_deliverable_rec.x_action_status
    := FND_API.g_ret_sts_success;

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
     ROLLBACK TO save_deliverable_grp;
     x_return_status := FND_API.g_ret_sts_error;
     p_deliverable_rec.x_action_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

   WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO save_deliverable_grp;
     x_return_status := FND_API.g_ret_sts_unexp_error;
     p_deliverable_rec.x_action_status := FND_API.g_ret_sts_unexp_error;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

   WHEN OTHERS THEN
     ROLLBACK TO save_deliverable_grp;
     x_return_status := FND_API.g_ret_sts_unexp_error;
     p_deliverable_rec.x_action_status := FND_API.g_ret_sts_unexp_error;

     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
       FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
     END IF;

     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

END save_deliverable;


---------------------------------------------------------------------
-- PROCEDURE
--    save_deliverable
--
-- PURPOSE
--    Save a collection of logical deliverables
--
-- PARAMETERS
--    p_deliverable_tbl: A collection of the logical deliverables to be saved
--
-- NOTES
--    1. Insert a new deliverable if deliverable_id is null; update otherwise
--    2. Raise an exception if access_name or display_name is missing;
--       or access_name is not unique
--    3. Raise an exception if item_type or item_applicable_to is missing
--       or invalid (create)
--    4. Raise an exception if the deliverable doesn't exist; or the version
--       doesn't match (update)
--    5. Raise an exception for any other errors

---------------------------------------------------------------------
PROCEDURE save_deliverable (
                            p_api_version            IN   NUMBER,
                            p_init_msg_list          IN   VARCHAR2 := FND_API.g_false,
  p_commit                 IN   VARCHAR2 := FND_API.g_false,
  x_return_status          OUT NOCOPY  VARCHAR2,
  x_msg_count              OUT NOCOPY  NUMBER,
  x_msg_data               OUT NOCOPY  VARCHAR2,
  p_deliverable_tbl        IN OUT NOCOPY DELIVERABLE_TBL_TYPE ) IS

  l_api_name CONSTANT VARCHAR2(30) := 'save_deliverable';
  l_full_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_return_status VARCHAR2(1);

  l_index NUMBER;

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT save_deliverable_grp;

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

  IF p_deliverable_tbl IS NOT NULL THEN
    FOR l_index IN 1..p_deliverable_tbl.COUNT LOOP

      save_deliverable(
        p_api_version       => p_api_version,
        x_return_status     => l_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_deliverable_rec	=> p_deliverable_tbl(l_index)
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
     ROLLBACK TO save_deliverable_grp;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

   WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO save_deliverable_grp;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );


   WHEN OTHERS THEN
     ROLLBACK TO save_deliverable_grp;
     x_return_status := FND_API.g_ret_sts_unexp_error ;

     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
       FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
     END IF;

     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

END save_deliverable;


---------------------------------------------------------------------
-- PROCEDURE
--    save_deliverable
--
-- PURPOSE
--    Save a logical deliverable with the default attachment for all-site
--	 and all-language
--
-- PARAMETERS
--    p_dlv_ath_rec: A logical deliverable with the default attachment
--	 for all-site and all-language to be saved
--
-- NOTES
--    1. Insert a new deliverable if deliverable_id is null; update otherwise
--    2. Raise an exception if access_name or display_name is missing;
--       or access_name is not unique
--    3. Raise an exception if item_type or item_applicable_to is missing
--       or invalid (create)
--    4. Raise an exception if the deliverable doesn't exist; or the version
--       doesn't match (update)
--	 5. If creating/updating deliverable succeeds, update the default
--	    attachment for all-site and all-language
--	 6. Raise an exception if fails to create an attachment, or all-site
--	    and all-language mappings. Only undo the changes made to attachment
--	    physicalmap tables
--	 7. Raise an exception if chosen default attachment is invalid, e.g.,
--	    it's not associated with the given deliverable.
--    8. Raise an exception for any other errors

---------------------------------------------------------------------
PROCEDURE save_deliverable (
                            p_api_version            IN   NUMBER,
                            p_init_msg_list          IN   VARCHAR2 := FND_API.g_false,
  p_commit                 IN   VARCHAR2 := FND_API.g_false,
  x_return_status          OUT NOCOPY  VARCHAR2,
  x_msg_count              OUT NOCOPY  NUMBER,
  x_msg_data               OUT NOCOPY  VARCHAR2,
  p_dlv_ath_rec            IN OUT NOCOPY DLV_ATH_REC_TYPE ) IS

  l_api_name CONSTANT VARCHAR2(30) := 'save_deliverable';
  l_full_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_operation_type VARCHAR2(10) := 'INSERT';
  l_create_attachment VARCHAR2(1) := FND_API.g_false;
  l_delete_mapping VARCHAR2(1) := FND_API.g_false;
  l_create_mapping VARCHAR2(1) := FND_API.g_false;
  l_attachment_id NUMBER;

  l_deliverable_rec DELIVERABLE_REC_TYPE;
  l_attachment_rec IBE_Attachment_GRP.ATTACHMENT_REC_TYPE;
  l_language_code_tbl IBE_PhysicalMap_GRP.LANGUAGE_CODE_TBL_TYPE
    := IBE_PhysicalMap_GRP.LANGUAGE_CODE_TBL_TYPE(NULL);

  l_return_status VARCHAR2(1);

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT save_deliverable_grp;

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

  IF p_dlv_ath_rec.deliverable_id IS NOT NULL THEN
    -- Update an existing deliverable
    l_operation_type := 'UPDATE';
  END IF;

  l_deliverable_rec.deliverable_id := p_dlv_ath_rec.deliverable_id;
  l_deliverable_rec.access_name := p_dlv_ath_rec.access_name;
  l_deliverable_rec.display_name := p_dlv_ath_rec.display_name;
  l_deliverable_rec.item_type := p_dlv_ath_rec.item_type;
  l_deliverable_rec.item_applicable_to := p_dlv_ath_rec.item_applicable_to;
  l_deliverable_rec.keywords := p_dlv_ath_rec.keywords;
  l_deliverable_rec.description := p_dlv_ath_rec.description;
  l_deliverable_rec.object_version_number := p_dlv_ath_rec.object_version_number;
  l_deliverable_rec.x_action_status := NULL;

  save_deliverable(
    p_api_version			=> p_api_version,
    x_return_status		=> l_return_status,
    x_msg_count			=> x_msg_count,
    x_msg_data			=> x_msg_data,
    p_deliverable_rec		=> l_deliverable_rec
                  );

  p_dlv_ath_rec.deliverable_id := l_deliverable_rec.deliverable_id;
  p_dlv_ath_rec.object_version_number := l_deliverable_rec.object_version_number;
  p_dlv_ath_rec.x_action_status := l_deliverable_rec.x_action_status;

  IF l_return_status = FND_API.g_ret_sts_error THEN
    RAISE FND_API.g_exc_error;
  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- Update/Create default attachment for all-site and all-language

  BEGIN

    SAVEPOINT save_one_attachment_grp;

    IF l_operation_type = 'INSERT' THEN

      -- Create an attachment for all-site and all-language if any
      IF TRIM(p_dlv_ath_rec.ath_file_name) IS NOT NULL THEN
        l_create_attachment := FND_API.g_true;
        l_create_mapping := FND_API.g_true;

      END IF;

    ELSE

      -- Update the default attachment for the existing deliverable

      IF TRIM(p_dlv_ath_rec.ath_file_name) IS NULL THEN
        l_delete_mapping := FND_API.g_true;

      ELSE

        -- Check if it's an existing attachment
        -- If so, validate it! Update all-site and all-lang mappings
        -- if it's the new default
        -- If not, delete all-site and all-lang mappings if any
        -- and create the new attachment with all-site and all-lang
        -- mappings

        --modified by G. Zhang 05/23/01 10:57AM
        l_attachment_id := IBE_DSPMGRVALIDATION_GRP.check_attachment_exists(
          p_dlv_ath_rec.deliverable_id,p_dlv_ath_rec.ath_file_id,p_dlv_ath_rec.ath_file_name);

        IF l_attachment_id IS NOT NULL THEN
          -- existing attachment
          -- validate it!
          --modified by G. Zhang 05/23/01 10:57AM
          --IF NOT IBE_DSPMGRVALIDATION_GRP.check_attachment_deliverable(
          --	l_attachment_id, p_dlv_ath_rec.deliverable_id) THEN
          --	-- invalid attachment for the given deliverable
          --	RAISE FND_API.g_exc_error;
          --END  IF;

          IF NOT IBE_DSPMGRVALIDATION_GRP.check_default_attachment(
            l_attachment_id) THEN
            l_delete_mapping := FND_API.g_true;
            l_create_mapping := FND_API.g_true;
          END IF;

        ELSE
          -- new attachment
          l_create_attachment := FND_API.g_true;
          l_delete_mapping := FND_API.g_true;
          l_create_mapping := FND_API.g_true;
        END IF;

      END IF;

    END IF;

    IF l_create_attachment = FND_API.g_true THEN
      l_attachment_rec.attachment_id := NULL;
      l_attachment_rec.deliverable_id := p_dlv_ath_rec.deliverable_id;
      l_attachment_rec.file_name := p_dlv_ath_rec.ath_file_name;

      --added by G. Zhang 05/17/01 5:42PM
      l_attachment_rec.file_id := p_dlv_ath_rec.ath_file_id;

	--added by G. Zhang 08/01/01 6:15PM
	--fix bug#1911212
	l_attachment_rec.application_id := 671;
      l_attachment_rec.attachment_used_by := 'ITEM';

      l_attachment_rec.object_version_number := NULL;
      l_attachment_rec.x_action_status := NULL;
      IBE_Attachment_GRP.save_attachment(

        p_api_version            => p_api_version,
        x_return_status          => l_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data,
        p_attachment_rec         => l_attachment_rec
                                        );

      IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

      l_attachment_id := l_attachment_rec.attachment_id;
    END IF;

    IF l_delete_mapping = FND_API.g_true THEN
      -- Delete all-site and all-lang mapping for this deliverable
      IBE_PhysicalMap_GRP.delete_dlv_all_all(
        p_deliverable_id         => p_dlv_ath_rec.deliverable_id
                                            );
    END IF;

    IF l_create_mapping = FND_API.g_true THEN
      -- Create all-site and all-lang mapping for this default attachment
      IBE_PhysicalMap_GRP.save_physicalmap(
        p_api_version            => p_api_version,
        x_return_status          => l_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data,
        p_attachment_id          => l_attachment_id,
        p_msite_id               => NULL,
        p_language_code_tbl      => l_language_code_tbl
                                          );

      IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;
    END IF;

    p_dlv_ath_rec.x_ath_action_status := FND_API.g_ret_sts_success;

  EXCEPTION

     WHEN FND_API.g_exc_error THEN
       ROLLBACK TO save_one_attachment_grp;
       p_dlv_ath_rec.x_ath_action_status := FND_API.g_ret_sts_error;
       x_return_status := FND_API.g_ret_sts_error;

     WHEN FND_API.g_exc_unexpected_error THEN
       ROLLBACK TO save_one_attachment_grp;
       p_dlv_ath_rec.x_ath_action_status := FND_API.g_ret_sts_unexp_error;
       x_return_status := FND_API.g_ret_sts_unexp_error;

     WHEN OTHERS THEN
       ROLLBACK TO save_one_attachment_grp;
       p_dlv_ath_rec.x_ath_action_status := FND_API.g_ret_sts_unexp_error;
       x_return_status := FND_API.g_ret_sts_unexp_error ;

       IF FND_MSG_PUB.check_msg_level(
         FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
       END IF;
  END;

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
     ROLLBACK TO save_deliverable_grp;
     x_return_status := FND_API.g_ret_sts_error;
     p_dlv_ath_rec.x_action_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

   WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO save_deliverable_grp;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     p_dlv_ath_rec.x_action_status := FND_API.g_ret_sts_unexp_error;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

   WHEN OTHERS THEN
     ROLLBACK TO save_deliverable_grp;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     p_dlv_ath_rec.x_action_status := FND_API.g_ret_sts_unexp_error;

     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
       FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
     END IF;

     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

END save_deliverable;


---------------------------------------------------------------------
-- PROCEDURE
--    save_deliverable
--
-- PURPOSE
--    Save a collection of logical deliverables with the default attachments
--	 for all-site and all-language
--
-- PARAMETERS
--    p_dlv_ath_tbl: A collection of logical deliverables with the default
--	 attachments for all-site and all-language to be saved
--
-- NOTES
--    1. Insert a new deliverable if deliverable_id is null; update otherwise
--    2. Raise an exception if access_name or display_name is missing;
--       or access_name is not unique
--    3. Raise an exception if item_type or item_applicable_to is missing
--       or invalid (create)
--    4. Raise an exception if the deliverable doesn't exist; or the version
--       doesn't match (update)
--    5. If creating/updating deliverable succeeds, update the default
--       attachment for all-site and all-language
--    6. Raise an exception if fails to create an attachment, or all-site
--       and all-language mappings. Only undo the changes made to attachment
--       physicalmap tables
--    7. Raise an exception if chosen default attachment is invalid, e.g.,
--       it's not associated with the given deliverable.
--    8. Raise an exception for any other errors

---------------------------------------------------------------------
PROCEDURE save_deliverable (
                            p_api_version            IN   NUMBER,
                            p_init_msg_list          IN   VARCHAR2 := FND_API.g_false,
  p_commit                 IN   VARCHAR2 := FND_API.g_false,
  x_return_status          OUT NOCOPY  VARCHAR2,
  x_msg_count              OUT NOCOPY  NUMBER,
  x_msg_data               OUT NOCOPY  VARCHAR2,
  p_dlv_ath_tbl        	IN OUT NOCOPY DLV_ATH_TBL_TYPE ) IS

  l_api_name CONSTANT VARCHAR2(30) := 'save_deliverable';
  l_full_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_return_status VARCHAR2(1);

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT save_deliverable_grp;

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

  IF p_dlv_ath_tbl IS NOT NULL THEN
    FOR l_index IN 1..p_dlv_ath_tbl.COUNT LOOP

      save_deliverable(
        p_api_version       => p_api_version,
        x_return_status     => l_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_dlv_ath_rec   	=> p_dlv_ath_tbl(l_index)
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
     ROLLBACK TO save_deliverable_grp;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

   WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO save_deliverable_grp;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
         p_data    => x_msg_data
                              );

   WHEN OTHERS THEN
     ROLLBACK TO save_deliverable_grp;
     x_return_status := FND_API.g_ret_sts_unexp_error ;

     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
       FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
     END IF;

     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
                              );

END save_deliverable;


---------------------------------------------------------------------
-- PROCEDURE
--    delete_deliverable
--
-- PURPOSE
--    Delete a collection of logical deliverables
--
-- PARAMETERS
--    p_dlv_id_ver_tbl: A collection of IDs and versions of the logical
--		deliverables to be deleted
--
-- NOTES
--    1. Delete all the deliverables and associated physical attachments along
--	    with all the associations
--	 2. Raise an exception if the deliverable doesn't exist; or the version
--	    doesn't match
--    3. A logical deliverable is not allowed to be deleted if it's currently
-- 	    in use unless the caller has the right privilege
--    4. Raise an exception for any other errors
---------------------------------------------------------------------
PROCEDURE delete_deliverable (
                              p_api_version            IN   NUMBER,
                              p_init_msg_list          IN   VARCHAR2 := FND_API.g_false,
  p_commit                 IN   VARCHAR2  := FND_API.g_false,
  x_return_status          OUT NOCOPY  VARCHAR2,
  x_msg_count              OUT NOCOPY  NUMBER,
  x_msg_data               OUT NOCOPY  VARCHAR2,
  p_dlv_id_ver_tbl		IN OUT NOCOPY DLV_ID_VER_TBL_TYPE ) IS

  l_api_name CONSTANT VARCHAR2(30) := 'delete_deliverable';
  l_full_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_index NUMBER;

  l_return_status VARCHAR2(1);

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT delete_deliverable_grp;

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

  -- Check if the deliverable exists
  IF p_dlv_id_ver_tbl IS NOT NULL THEN
    FOR l_index IN 1..p_dlv_id_ver_tbl.COUNT LOOP
BEGIN

  -- Standard start of API savepoint
  SAVEPOINT delete_one_deliverable_grp;

  IF NOT IBE_DSPMGRVALIDATION_GRP.check_deliverable_exists(
    p_dlv_id_ver_tbl(l_index).deliverable_id,
    p_dlv_id_ver_tbl(l_index).object_version_number) THEN
    RAISE FND_API.g_exc_error;
  END IF;

  -- Delete from the section tables
  IBE_DSP_SECTION_GRP.update_deliverable_to_null(
    p_api_version			=> p_api_version,
    p_deliverable_id =>	p_dlv_id_ver_tbl(l_index).deliverable_id,
    x_return_status		=> l_return_status,
    x_msg_count			=> x_msg_count,
    x_msg_data			=> x_msg_data
                                                );

  IF l_return_status = FND_API.g_ret_sts_error THEN
    RAISE FND_API.g_exc_error;
  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- Delete all the associated display contexts
  IBE_DisplayContext_GRP.delete_deliverable(
    p_dlv_id_ver_tbl(l_index).deliverable_id
                                           );

  -- Delete all the associated template categories
  IBE_TplCategory_GRP.delete_deliverable(
    p_dlv_id_ver_tbl(l_index).deliverable_id
                                        );

  -- Delete all the associated logical contents
  IBE_LogicalContent_GRP.delete_deliverable(
    p_dlv_id_ver_tbl(l_index).deliverable_id
                                           );

  -- Delete all the associated physical_site_language mappings
  IBE_PhysicalMap_GRP.delete_deliverable(
    p_dlv_id_ver_tbl(l_index).deliverable_id
                                        );

  -- Delete the item
  JTF_AMV_ITEM_PUB.delete_item(
    p_api_version		=> g_amv_api_version,
    x_return_status	=> l_return_status,
    x_msg_count		=> x_msg_count,
    x_msg_data		=> x_msg_data,
    p_item_id			=> p_dlv_id_ver_tbl(l_index).deliverable_id
                              );

  IF l_return_status = FND_API.g_ret_sts_error THEN
    RAISE FND_API.g_exc_error;
  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  p_dlv_id_ver_tbl(l_index).x_action_status
    := FND_API.g_ret_sts_success;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
     ROLLBACK TO delete_one_deliverable_grp;
     IF x_return_status <> FND_API.g_ret_sts_unexp_error THEN
       x_return_status := FND_API.g_ret_sts_error;
     END IF;
     p_dlv_id_ver_tbl(l_index).x_action_status
       := FND_API.g_ret_sts_error;

   WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO delete_one_deliverable_grp;
     x_return_status := FND_API.g_ret_sts_unexp_error;
     p_dlv_id_ver_tbl(l_index).x_action_status
       := FND_API.g_ret_sts_unexp_error;

   WHEN OTHERS THEN
     ROLLBACK TO delete_one_deliverable_grp;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     p_dlv_id_ver_tbl(l_index).x_action_status
       := FND_API.g_ret_sts_unexp_error;

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

EXCEPTION

   WHEN FND_API.g_exc_error THEN
     ROLLBACK TO delete_deliverable_grp;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.count_and_get(
       p_encoded      =>   FND_API.g_false,
       p_count        =>   x_msg_count,
       p_data         =>   x_msg_data
                              );

   WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO delete_deliverable_grp;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     FND_MSG_PUB.count_and_get(
       p_encoded      =>   FND_API.g_false,
       p_count        =>   x_msg_count,
       p_data         =>   x_msg_data
                              );

   WHEN OTHERS THEN
     ROLLBACK TO delete_deliverable_grp;
     x_return_status := FND_API.g_ret_sts_unexp_error ;

     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
       FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
     END IF;

     FND_MSG_PUB.count_and_get(
       p_encoded      =>   FND_API.g_false,
       p_count        =>   x_msg_count,
       p_data         =>   x_msg_data
                              );

 END delete_deliverable;

END IBE_Deliverable_GRP;

/
