--------------------------------------------------------
--  DDL for Package Body CN_IMP_HIERARCHY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_IMP_HIERARCHY_PVT" AS
-- $Header: cnvimhib.pls 120.3 2005/09/19 00:58:03 kjayapau noship $

G_PKG_NAME               CONSTANT VARCHAR2(30) := 'CN_IMP_HIERARCHY_PVT';
G_FILE_NAME              CONSTANT VARCHAR2(12) := 'cnvimhib.pls';

-- ========================================================
--  Utility Modules
-- ========================================================
-- --------------------------------------------------------+
--  seterr_imp_hierarchy
--
--  This procedure will set error in cn_imp_lines(cn_hierarchy_imp_v)
--  with passed in status and error code
-- --------------------------------------------------------+
PROCEDURE seterr_imp_hierarchy
  (p_hier_record IN imp_hier_rec_type,
   p_status_code IN VARCHAR2,
   p_error_code  IN VARCHAR2,
   p_error_msg   IN VARCHAR2,
   x_failed_row IN OUT NOCOPY NUMBER,
   x_processed_row IN OUT NOCOPY NUMBER) IS
      PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

   UPDATE cn_hierarchy_imp_v
     SET status_code = p_status_code, error_code = p_error_code,
     error_msg = p_error_msg
     WHERE
     (start_date =
      Decode(p_hier_record.start_date,FND_API.G_MISS_CHAR,start_date,
	     p_hier_record.start_date)
      )
     AND
     (Nvl(end_date,FND_API.g_miss_char) =
      Decode(p_hier_record.end_date,
	     FND_API.G_MISS_CHAR,Nvl(end_date,FND_API.g_miss_char) ,
	     NULL,FND_API.g_miss_char,
	     p_hier_record.end_date)
      )
     AND
     (hierarchy_name =
      Decode(p_hier_record.hierarchy_name,FND_API.G_MISS_CHAR,hierarchy_name,
	     p_hier_record.hierarchy_name)
      )
     AND
     (Upper(hierarchy_value) =
      Decode(p_hier_record.hierarchy_value,FND_API.G_MISS_CHAR,
	     Upper(hierarchy_value),p_hier_record.hierarchy_value)
      )
     AND
     (Upper(primary_key) =
      Decode(p_hier_record.primary_key,FND_API.G_MISS_CHAR,Upper(primary_key),
	     p_hier_record.primary_key)
      )
     AND
     (Upper(base_table_name) =
      Decode(p_hier_record.base_table_name,FND_API.G_MISS_CHAR,
	     Upper(base_table_name),p_hier_record.base_table_name)
      )
     AND
     (hierarchy_type=
      Decode(p_hier_record.hierarchy_type,FND_API.G_MISS_CHAR,hierarchy_type,
	     p_hier_record.hierarchy_type)
      )
     AND
     (imp_line_id =
      Decode(p_hier_record.imp_line_id,FND_API.G_MISS_NUM,imp_line_id,
	     p_hier_record.imp_line_id)
      )
     AND (imp_header_id = p_hier_record.imp_header_id)
     AND status_code = 'STAGE'
     ;

   x_failed_row := x_failed_row + SQL%rowcount;
   x_processed_row := x_processed_row + SQL%rowcount;

   IF (SQL%ROWCOUNT=0) THEN
      RAISE NO_DATA_FOUND;
   END IF;
   COMMIT;

   CN_IMPORT_PVT.update_imp_headers
     (p_imp_header_id => p_hier_record.imp_header_id,
      p_status_code => 'IMPORT_FAIL',
      p_failed_row => x_failed_row,
      p_processed_row => x_processed_row);

END seterr_imp_hierarchy;

-- --------------------------------------------------------+
--  Imp_Hierarchy_Type
--
--  This procedure will import one hierarchy type
-- --------------------------------------------------------+
PROCEDURE Imp_Hierarchy_Type
  (p_imp_header_id IN NUMBER,
   p_hier_record   IN OUT NOCOPY imp_hier_rec_type,
   x_dimension_id OUT NOCOPY NUMBER,
   x_base_table_id OUT NOCOPY NUMBER,
   x_primary_key_id OUT NOCOPY NUMBER,
   x_hier_value_id OUT NOCOPY NUMBER,
   x_error_msg OUT NOCOPY VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2,
   x_failed_row IN OUT NOCOPY NUMBER,
   x_processed_row IN OUT NOCOPY NUMBER,
   p_org_id  IN NUMBER) IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Imp_Hierarchy_Type';
      l_stage_status cn_imp_lines.status_code%TYPE := 'STAGE';
      l_message       VARCHAR2(2000);
      l_error_code    VARCHAR2(30);
      l_msg_count     NUMBER := 0;
      l_dummy         NUMBER;
      l_description   VARCHAR2(2000) := null;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  Imp_Hierarchy_Type ;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;

   cn_message_pkg.debug
     ('Start Import Hierarchy Type : ' || p_hier_record.hierarchy_type);

   -- Get BASE_TABLE_NAME,PRIMARY_KEY,HIERARCHY_VALUE
   BEGIN
      SELECT DISTINCT Upper(BASE_TABLE_NAME) BASE_TABLE_NAME,
	Upper(primary_key) PRIMARY_KEY,
	Upper(hierarchy_value) HIERARCHY_VALUE
	INTO p_hier_record.base_table_name,p_hier_record.primary_key,
	p_hier_record.hierarchy_value
	FROM cn_hierarchy_imp_v
	WHERE imp_header_id = p_imp_header_id
	AND status_code = l_stage_status
	AND hierarchy_type = p_hier_record.hierarchy_type
	   ;
   EXCEPTION
      -- Check if has multiple BASE_TABLE_NAME,PRIMARY_KEY,HIERARCHY_VALUE for
      -- the same hierarchy type within this import
      WHEN TOO_MANY_ROWS THEN
	 l_message := fnd_message.get_string('CN','CN_HIER_MULTI_BTBL');
	 l_error_code := 'CN_HIER_MULTI_BTBL';
	 p_hier_record.base_table_name := fnd_api.G_MISS_CHAR ;
	 p_hier_record.primary_key  := fnd_api.G_MISS_CHAR ;
	 p_hier_record.hierarchy_value := fnd_api.G_MISS_CHAR ;
	 RAISE FND_API.g_exc_error;
   END;
   cn_message_pkg.debug('-- Base table = ' || p_hier_record.base_table_name);

   -- Get IDs for BASE_TABLE_NAME
   BEGIN
      SELECT table_id INTO x_base_table_id
	FROM cn_obj_tables_v WHERE name = p_hier_record.base_table_name and org_id=p_org_id
	;
   EXCEPTION
      -- base table not exist in cn_obj_tables_v
      WHEN NO_DATA_FOUND THEN
	 l_message := fnd_message.get_string('CN','CN_HIER_NF_BTBL');
	 l_error_code := 'CN_HIER_NF_BTBL';
	 RAISE FND_API.g_exc_error;
   END;
   cn_message_pkg.debug('-- Base table ID = ' || x_base_table_id);

   -- Get IDs for PRIMARY_KEY
   BEGIN
      SELECT column_id INTO x_primary_key_id
	FROM cn_obj_columns_v
	WHERE name = p_hier_record.primary_key AND table_id = x_base_table_id and org_id=p_org_id
	;
   EXCEPTION
      -- primary_key not exist
      WHEN NO_DATA_FOUND THEN
	 l_message := fnd_message.get_string('CN','CN_HIER_NF_PKEY');
	 l_error_code := 'CN_HIER_NF_PKEY';
	 RAISE FND_API.g_exc_error;
   END;
   cn_message_pkg.debug('-- PK ID = ' || x_primary_key_id);

   -- Get IDs for HIERARCHY_VALUE
   BEGIN
      SELECT column_id INTO x_hier_value_id
	FROM cn_obj_columns_v
	WHERE name = p_hier_record.hierarchy_value
	AND table_id = x_base_table_id and org_id=p_org_id
	;
   EXCEPTION
      -- hierarchy_value not exist
      WHEN NO_DATA_FOUND THEN
	 l_message := fnd_message.get_string('CN','CN_HIER_NF_HIERVAL');
	 l_error_code := 'CN_HIER_NF_HIERVAL';
	 RAISE FND_API.g_exc_error;
   END;
   cn_message_pkg.debug('-- Hier value ID = ' || x_hier_value_id);

   -- Create new hierarchy type if not exist
   BEGIN
      SELECT dimension_id INTO x_dimension_id FROM cn_dimensions_vl
	WHERE name = p_hier_record.hierarchy_type and org_id=p_org_id;
   EXCEPTION
      WHEN no_data_found THEN
	 BEGIN
	    -- for new Hierarchy Type, it's base_table should exist in
	    -- cn_base_tables_v, if not, means other Hierarchy Type already use
	    -- this table
	    SELECT 1 INTO l_dummy FROM cn_base_tables_v
	      WHERE table_id = x_base_table_id
	      AND name = p_hier_record.base_table_name and org_id=p_org_id
	      ;
	 EXCEPTION
	    WHEN no_data_found THEN
	       l_message := fnd_message.get_string('CN','CN_HIER_DUP_BTBL');
	       l_error_code := 'CN_HIER_DUP_BTBL';
	       RAISE FND_API.g_exc_error;
	 END;

	 cn_dim_hierarchies_pvt.Create_Hierarchy_Type
	   (p_api_version   => 1.0,
	    p_init_msg_list => FND_API.G_TRUE,
	    p_name          => p_hier_record.hierarchy_type,
	    p_base_table_id => x_base_table_id,
	    p_primary_key_id => x_primary_key_id,
	    p_user_column_id => x_hier_value_id,
            p_org_id => p_org_id,
            p_description => l_description,
	    x_return_status  => x_return_status,
	    x_msg_count      => l_msg_count,
	    x_msg_data       => l_message,
	    x_dimension_id   => x_dimension_id);
	 IF x_return_status <> FND_API.g_ret_sts_success THEN
	    l_error_code := 'CN_HIER_FAIL_CREATE';
	    IF l_msg_count > 1 THEN
	       l_message :=
		 fnd_msg_pub.get(p_msg_index => fnd_msg_pub.G_FIRST);
	    END IF;
	    RAISE FND_API.g_exc_error;
	 END IF;
   END;
   cn_message_pkg.debug('-- dimension ID = ' || x_dimension_id);

   -- Check created/existed hierarchy type has same base table,pk,
   -- hier_value within the import data
   BEGIN
      SELECT 1 INTO l_dummy FROM cn_obj_columns_v
	WHERE table_id = x_base_table_id
	AND dimension_id = x_dimension_id
	AND column_id = x_primary_key_id
	AND primary_key = 'Y' and org_id=p_org_id
	;
      SELECT 1 INTO l_dummy FROM cn_obj_columns_v
	WHERE table_id = x_base_table_id
	AND column_id = x_hier_value_id
	AND user_column_name = 'Y' and org_id=p_org_id
	;
   EXCEPTION
      WHEN no_data_found THEN
	 l_message := fnd_message.get_string('CN','CN_HIER_NOTMATCH');
	 l_error_code := 'CN_HIER_NOTMATCH';
	 RAISE FND_API.g_exc_error;
   END;

   x_error_msg := l_message;

   cn_message_pkg.debug
     ('End Import Hierarchy Type : ' || p_hier_record.hierarchy_type ||
      ' dimension_id = ' || x_dimension_id );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Imp_Hierarchy_Type ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      x_error_msg := l_message;
      seterr_imp_hierarchy
	(p_hier_record => p_hier_record,
	 p_status_code => 'FAIL',
	 p_error_code  => l_error_code,
	 p_error_msg   => l_message,
	 x_failed_row => x_failed_row,
	 x_processed_row => x_processed_row);
      cn_message_pkg.write
	(p_message_text => l_message ,
	 p_message_type => 'ERROR');
      cn_message_pkg.write
	(p_message_text =>
	 ' All record with hierarchy type = ' || p_hier_record.hierarchy_type
	 || ' and base table = ' || p_hier_record.BASE_TABLE_NAME
	 || ' and primary key = ' || p_hier_record.primary_key
	 || ' and hierarchy value = ' || p_hier_record.hierarchy_value
	 || ' are treated as failed records.' ,
	 p_message_type => 'ERROR');

   WHEN OTHERS THEN
      ROLLBACK TO Imp_Hierarchy_Type ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      cn_message_pkg.set_error(l_api_name,'Unexpected error');
      l_error_code := SQLCODE;
      l_message := SUBSTR (SQLERRM , 1 , 2000);
      x_error_msg := l_message;
      seterr_imp_hierarchy
	(p_hier_record => p_hier_record,
	 p_status_code => 'FAIL',
	 p_error_code  => l_error_code,
	 p_error_msg   => l_message,
	 x_failed_row => x_failed_row,
	 x_processed_row => x_processed_row);
      cn_message_pkg.write
	(p_message_text => l_message ,
	 p_message_type => 'ERROR');
      cn_message_pkg.write
	(p_message_text =>
	 ' All record with hierarchy type = ' || p_hier_record.hierarchy_type
	 || ' and base table = ' || p_hier_record.BASE_TABLE_NAME
	 || ' and primary key = ' || p_hier_record.primary_key
	 || ' and hierarchy value = ' || p_hier_record.hierarchy_value
	 || ' are treated as failed records.' ,
	 p_message_type => 'ERROR');

END  Imp_Hierarchy_Type;

-- --------------------------------------------------------+
--  Imp_Head_Hierarchy
--
--  This procedure will import one head hierarchy
-- --------------------------------------------------------+
PROCEDURE Imp_Head_Hierarchy
  (p_imp_header_id IN NUMBER,
   p_hier_record   IN imp_hier_rec_type,
   p_dimension_id IN NUMBER,
   x_head_hierarchy_id OUT NOCOPY NUMBER,
   x_error_msg OUT NOCOPY VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2,
   x_failed_row IN OUT NOCOPY NUMBER,
   x_processed_row IN OUT NOCOPY NUMBER,
   p_org_id IN NUMBER) IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Imp_Head_Hierarchy';
      l_stage_status cn_imp_lines.status_code%TYPE := 'STAGE';
      l_message       VARCHAR2(2000);
      l_error_code    VARCHAR2(30);
      l_msg_count     NUMBER := 0;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  Imp_Head_Hierarchy ;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;

   cn_message_pkg.debug
     ('Start Import Head Hierarchy : ' || p_hier_record.hierarchy_name);
   -- Create new head hierarchy if not exist
   BEGIN
      SELECT head_hierarchy_id INTO x_head_hierarchy_id
	FROM cn_head_hierarchies
	WHERE name = p_hier_record.hierarchy_name
	AND dimension_id = p_dimension_id
        AND org_id  = p_org_id
	      ;
   EXCEPTION
      WHEN no_data_found THEN
	 cn_dim_hierarchies_pvt.Create_Head_Hierarchy
	   (p_api_version   => 1.0,
	    p_init_msg_list => FND_API.G_TRUE,
	    p_name          => p_hier_record.hierarchy_name,
	    p_dimension_id => p_dimension_id,
            p_org_id  => p_org_id,
	    x_return_status  => x_return_status,
	    x_msg_count      => l_msg_count,
	    x_msg_data       => l_message,
	    x_head_hierarchy_id   => x_head_hierarchy_id);
	 IF x_return_status <> FND_API.g_ret_sts_success THEN
	    l_error_code := 'CN_HIER_FAIL_CREATE';
	    IF l_msg_count > 1 THEN
	       l_message :=
		 fnd_msg_pub.get(p_msg_index => fnd_msg_pub.G_FIRST);
	    END IF;
	    RAISE FND_API.g_exc_error;
	 END IF;
   END;

   x_error_msg := l_message;

   cn_message_pkg.debug
     ('End Import Head Hierarchy : ' || p_hier_record.hierarchy_name ||
      ' head_hierarchy_id = ' || x_head_hierarchy_id );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Imp_Head_Hierarchy ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      x_error_msg := l_message;
      seterr_imp_hierarchy
	(p_hier_record => p_hier_record,
	 p_status_code => 'FAIL',
	 p_error_code  => l_error_code,
	 p_error_msg   => l_message,
	 x_failed_row => x_failed_row,
	 x_processed_row => x_processed_row);
      cn_message_pkg.write
	(p_message_text => l_message ,
	 p_message_type => 'ERROR');
      cn_message_pkg.write
	(p_message_text =>
	 ' All record with hierarchy type = ' || p_hier_record.hierarchy_type
	 || ' and Hierarchy name = ' || p_hier_record.hierarchy_name
	 || ' are treated as failed records.' ,
	 p_message_type => 'ERROR');

   WHEN OTHERS THEN
      ROLLBACK TO Imp_Head_Hierarchy ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      cn_message_pkg.set_error(l_api_name,'Unexpected error');
      l_error_code := SQLCODE;
      l_message := SUBSTR (SQLERRM , 1 , 2000);
      x_error_msg := l_message;
      seterr_imp_hierarchy
	(p_hier_record => p_hier_record,
	 p_status_code => 'FAIL',
	 p_error_code  => l_error_code,
	 p_error_msg   => l_message,
	 x_failed_row => x_failed_row,
	 x_processed_row => x_processed_row);
      cn_message_pkg.write
	(p_message_text => l_message ,
	 p_message_type => 'ERROR');
      cn_message_pkg.write
	(p_message_text =>
	 ' All record with hierarchy type = ' || p_hier_record.hierarchy_type
	 || ' and Hierarchy name = ' || p_hier_record.hierarchy_name
	 || ' are treated as failed records.' ,
	 p_message_type => 'ERROR');

END  Imp_Head_Hierarchy;

-- --------------------------------------------------------+
--  Imp_Dim_Hierarchy
--
--  This procedure will import one dim hierarchy
-- --------------------------------------------------------+
PROCEDURE Imp_Dim_Hierarchy
  (p_imp_header_id IN NUMBER,
   p_hier_record   IN imp_hier_rec_type,
   p_head_hierarchy_id IN NUMBER,
   x_dim_hierarchy_id OUT NOCOPY NUMBER,
   x_error_msg OUT NOCOPY VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2,
   x_failed_row IN OUT NOCOPY NUMBER,
   x_processed_row IN OUT NOCOPY NUMBER,
   p_org_id IN NUMBER) IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Imp_Dim_Hierarchy';
      l_stage_status cn_imp_lines.status_code%TYPE := 'STAGE';
      l_message       VARCHAR2(2000);
      l_error_code    VARCHAR2(30);
      l_msg_count     NUMBER := 0;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  Imp_Dim_Hierarchy ;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;

   cn_message_pkg.debug
     ('Start Import Dim Hierarchy : ' || p_hier_record.start_date
      || p_hier_record.end_date);
   -- Create new dim hierarchy if not exist
   BEGIN
      SELECT dim_hierarchy_id INTO x_dim_hierarchy_id
	FROM cn_dim_hierarchies
	WHERE header_dim_hierarchy_id = p_head_hierarchy_id
        AND org_id  = p_org_id
	AND start_date = To_date(p_hier_record.start_date, 'DD/MM/YYYY')
	AND Nvl(end_date,FND_API.g_miss_date) =
	Nvl(To_date(p_hier_record.end_date, 'DD/MM/YYYY'),FND_API.g_miss_date)
	;

   EXCEPTION
      WHEN no_data_found THEN
	 cn_dim_hierarchies_pvt.Create_Dim_Hierarchy
	   (p_api_version   => 1.0,
	    p_init_msg_list => FND_API.G_TRUE,
	    p_head_hierarchy_id  => p_head_hierarchy_id,
	    p_start_date     => To_date(p_hier_record.start_date, 'DD/MM/YYYY'),
	    p_end_date       => To_date(p_hier_record.end_date, 'DD/MM/YYYY'),
	    p_root_node      => NULL,
            p_org_id  =>  p_org_id,
	    x_return_status  => x_return_status,
	    x_msg_count      => l_msg_count,
	    x_msg_data       => l_message,
	    x_dim_hierarchy_id   => x_dim_hierarchy_id);
	 IF x_return_status <> FND_API.g_ret_sts_success THEN
	    l_error_code := 'CN_HIER_FAIL_CREATE';
	    IF l_msg_count > 1 THEN
	       l_message :=
		 fnd_msg_pub.get(p_msg_index => fnd_msg_pub.G_FIRST);
	    END IF;
	    RAISE FND_API.g_exc_error;
	 END IF;
   END;

   x_error_msg := l_message;

   cn_message_pkg.debug
     ('End Import Dim Hierarchy : ' || p_hier_record.start_date ||
      p_hier_record.end_date || ' dim_hierarchy_id = ' || x_dim_hierarchy_id );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Imp_Dim_Hierarchy ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      x_error_msg := l_message;
      seterr_imp_hierarchy
	(p_hier_record => p_hier_record,
	 p_status_code => 'FAIL',
	 p_error_code  => l_error_code,
	 p_error_msg   => l_message,
	 x_failed_row => x_failed_row,
	 x_processed_row => x_processed_row);
      cn_message_pkg.write
	(p_message_text => l_message ,
	 p_message_type => 'ERROR');
      cn_message_pkg.write
	(p_message_text =>
	 ' All record with hierarchy type = ' || p_hier_record.hierarchy_type
	 || ' and Hierarchy name = ' || p_hier_record.hierarchy_name
	 || ' Start Date = ' || p_hier_record.start_date
	 || ' End Date = ' || p_hier_record.end_date
	 || ' are treated as failed records.' ,
	 p_message_type => 'ERROR');

   WHEN OTHERS THEN
      ROLLBACK TO Imp_Dim_Hierarchy ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      cn_message_pkg.set_error(l_api_name,'Unexpected error');
      l_error_code := SQLCODE;
      l_message := SUBSTR (SQLERRM , 1 , 2000);
      x_error_msg := l_message;
      seterr_imp_hierarchy
	(p_hier_record => p_hier_record,
	 p_status_code => 'FAIL',
	 p_error_code  => l_error_code,
	 p_error_msg   => l_message,
	 x_failed_row => x_failed_row,
	 x_processed_row => x_processed_row);
      cn_message_pkg.write
	(p_message_text => l_message ,
	 p_message_type => 'ERROR');
      cn_message_pkg.write
	(p_message_text =>
	 ' All record with hierarchy type = ' || p_hier_record.hierarchy_type
	 || ' and Hierarchy name = ' || p_hier_record.hierarchy_name
	 || ' Start Date = ' || p_hier_record.start_date
	 || ' End Date = ' || p_hier_record.end_date
	 || ' are treated as failed records.' ,
	 p_message_type => 'ERROR');

END  Imp_Dim_Hierarchy;

-- --------------------------------------------------------+
--  Imp_Hierarchy_Node
--
--  This procedure will import one dim hierarchy
-- --------------------------------------------------------+
PROCEDURE Imp_Hierarchy_Node
  (p_imp_header_id IN NUMBER,
   p_hier_record   IN imp_hier_rec_type,
   p_dim_hierarchy_id  IN NUMBER,
   p_def_base_name IN VARCHAR2,
   p_header_list IN VARCHAR2,
   p_sql_stmt IN VARCHAR2,
   x_error_msg OUT NOCOPY VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2,
   x_failed_row IN OUT NOCOPY NUMBER,
   x_processed_row IN OUT NOCOPY NUMBER,
   p_org_id IN NUMBER) IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Imp_Hierarchy_Node';
      l_stage_status cn_imp_lines.status_code%TYPE := 'STAGE';
      l_message       VARCHAR2(2000);
      l_error_code    VARCHAR2(30);
      l_msg_count     NUMBER := 0;
      l_dummy         NUMBER;

      l_sql_stmt     VARCHAR2(8000);

      -- Cursor to get hierarchy nodes
      CURSOR c_hierarchy_node_csr
	(l_hier_type cn_hierarchy_imp_v.hierarchy_type%TYPE,
	 l_base_tbl cn_hierarchy_imp_v.base_table_name%TYPE,
	 l_hier_name cn_hierarchy_imp_v.hierarchy_name%TYPE,
	 l_start_date cn_hierarchy_imp_v.start_date%TYPE,
	 l_end_date cn_hierarchy_imp_v.end_date%TYPE)
	IS
	   SELECT
	     imp_line_id,
	     imp_header_id,
	     status_code,
	     error_code,
	     record_num,
	     trim(parent_node_name) PARENT_NODE_NAME,
	     trim(default_node_flag) DEFAULT_NODE_FLAG,
	     trim(node_name) NODE_NAME
	     FROM CN_HIERARCHY_IMP_V
	     WHERE imp_header_id = p_imp_header_id
	     AND status_code = l_stage_status
	     AND hierarchy_type = l_hier_type
	     AND BASE_TABLE_NAME = l_base_tbl
	     AND hierarchy_name = l_hier_name
	     AND start_date = l_start_date
	     AND Nvl(end_date,FND_API.g_miss_char) =
	     Nvl(l_end_date,FND_API.g_miss_char)
	     ORDER BY level_num
	     ;

      TYPE refcurtype IS ref CURSOR;
      node_csr        refcurtype;
      l_parent_ext_id cn_hierarchy_nodes.external_id%TYPE ;
      l_parent_value_id cn_hierarchy_nodes.value_id%TYPE ;
      l_external_id cn_hierarchy_nodes.external_id%TYPE ;
      l_value_id cn_hierarchy_nodes.value_id%TYPE ;

BEGIN
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;

   cn_message_pkg.debug('Start Import Hier Node.');

   FOR l_hierarchy_node_csr IN
     c_hierarchy_node_csr
     (p_hier_record.hierarchy_type,p_hier_record.BASE_TABLE_NAME,
      p_hier_record.hierarchy_name,p_hier_record.start_date,
      p_hier_record.end_date)
     LOOP
     BEGIN
	l_parent_value_id := NULL;
	l_parent_ext_id := NULL;
	l_external_id := NULL;
	l_value_id := NULL;

	cn_message_pkg.debug
	  ('-- Importing Parent = ' || l_hierarchy_node_csr.parent_node_name
	   || ' ; Child = ' || l_hierarchy_node_csr.node_name);

	IF l_hierarchy_node_csr.parent_node_name IS NOT NULL THEN
	   -- parent_node_name must be null for default Base Node
	   IF l_hierarchy_node_csr.default_node_flag = 'Y' THEN
	      l_message := fnd_message.get_string('CN','CN_HIER_NN_DFLTNODE');
	      l_error_code := 'CN_HIER_NN_DFLTNODE';
	      RAISE FND_API.g_exc_error;
	   END IF;

	   -- Get value id of parent Node
           BEGIN
	      IF l_hierarchy_node_csr.parent_node_name <> p_def_base_name THEN
		 SELECT value_id INTO l_parent_value_id
		   FROM cn_hierarchy_nodes
		   WHERE dim_hierarchy_id = p_dim_hierarchy_id
                   AND  org_id  = p_org_id
		   AND name = l_hierarchy_node_csr.parent_node_name;
	       ELSE
		 SELECT value_id INTO l_parent_value_id
		   FROM cn_hierarchy_nodes
		   WHERE dim_hierarchy_id = p_dim_hierarchy_id
                   AND  org_id  = p_org_id
		   AND external_id IS NULL;
	      END IF;
	   EXCEPTION
	      WHEN no_data_found THEN
		 -- parent_node not exist in cn_hierarchy_nodes
                 l_message :=
                   fnd_message.get_string('CN','CN_HIER_NF_PARENT_NODE');
                 l_error_code := 'CN_HIER_NF_PARENT_NODE';
                 RAISE FND_API.g_exc_error;
	   END;
	END IF;
	cn_message_pkg.debug
	  ('---- Parent node ID = ' || l_parent_value_id ||
	   ' ; Child node = ' || l_hierarchy_node_csr.node_name);
	-- Get external id of Node, skip default base node .
	-- create edge if not exist
	IF  l_hierarchy_node_csr.node_name <> p_def_base_name THEN
	   cn_message_pkg.debug
	     ('---- SELECT ' || p_hier_record.primary_key ||
	      ' FROM ' || p_hier_record.base_table_name ||
	      ' WHERE ' || p_hier_record.hierarchy_value ||
	      ' = ''' || l_hierarchy_node_csr.node_name ||'''');
	   OPEN node_csr FOR
	     'SELECT ' || p_hier_record.primary_key ||
	     ' FROM ' || p_hier_record.base_table_name ||
	     ' WHERE ' || p_hier_record.hierarchy_value ||
	     ' = :1' using l_hierarchy_node_csr.node_name;
	   LOOP
	      FETCH node_csr INTO l_external_id;
	      EXIT WHEN node_csr%notfound;

	      cn_message_pkg.debug('Node ID = ' || l_external_id);

	   END LOOP;
	   IF node_csr%rowcount = 0 THEN
	      l_message :=
		fnd_message.get_string('CN','CN_HIER_NF_NODE');
	      l_error_code := 'CN_HIER_NF_NODE';
	      RAISE FND_API.g_exc_error;
	   END IF;
	   CLOSE node_csr;

	   -- Create hierarchy edge while not exist
	   BEGIN
	      SELECT value_id INTO l_value_id
		FROM cn_hierarchy_nodes
		WHERE dim_hierarchy_id = p_dim_hierarchy_id
                AND  org_id  = p_org_id
		AND name = l_hierarchy_node_csr.node_name
		AND external_id = l_external_id;

	      SELECT 1 INTO l_dummy
		FROM cn_hierarchy_edges
		WHERE dim_hierarchy_id = p_dim_hierarchy_id
		AND value_id = l_value_id and org_id=p_org_id
		AND ((l_parent_value_id IS NULL AND parent_value_id IS NULL) OR
		     (l_parent_value_id IS NOT NULL AND
		      parent_value_id IS NOT NULL AND
		      parent_value_id = l_parent_value_id))
			;
	   EXCEPTION
	      WHEN no_data_found THEN
		 cn_dim_hierarchies_pvt.Create_Edge
		   (p_api_version   => 1.0,
		    p_init_msg_list => FND_API.G_TRUE,
		    p_dim_hierarchy_id => p_dim_hierarchy_id,
		    p_parent_value_id => l_parent_value_id,
		    p_name => l_hierarchy_node_csr.node_name,
		    p_external_id => l_external_id,
                    p_org_id  =>  p_org_id,
		    x_return_status  => x_return_status,
		    x_msg_count      => l_msg_count,
		    x_msg_data       => l_message,
		    x_value_id   => l_value_id);

		 IF x_return_status <> FND_API.g_ret_sts_success THEN
		    l_error_code := 'CN_HIER_FAIL_CREATE';
		    IF l_msg_count > 1 THEN
		       l_message :=
			 fnd_msg_pub.get(p_msg_index => fnd_msg_pub.G_FIRST);
		    END IF;
		    RAISE FND_API.g_exc_error;
		 END IF;
		 cn_message_pkg.debug('---- new edge created ');
		 -- Create success
		 COMMIT;
	   END;
	END IF;

	-- create complete or default node or edge exists
	CN_IMPORT_PVT.update_imp_lines
	  (p_imp_line_id => l_hierarchy_node_csr.imp_line_id,
	   p_status_code => 'COMPLETE',
	   p_error_code  => '');

	x_processed_row := x_processed_row + 1;

     EXCEPTION
	WHEN FND_API.g_exc_error THEN
	   x_failed_row := x_failed_row + 1;
	   x_processed_row := x_processed_row + 1;
	   x_return_status := FND_API.G_RET_STS_ERROR ;
	   x_error_msg := l_message;
	   CN_IMPORT_PVT.update_imp_lines
	     (p_imp_line_id => l_hierarchy_node_csr.imp_line_id,
	      p_status_code => 'FAIL',
	      p_error_code  => l_error_code,
	      p_error_msg   => l_message);
	   CN_IMPORT_PVT.update_imp_headers
	     (p_imp_header_id => p_imp_header_id,
	      p_status_code => 'IMPORT_FAIL',
	      p_failed_row => x_failed_row,
	      p_processed_row => x_processed_row);
	   cn_message_pkg.write
	     (p_message_text    => 'Record ' ||
	      l_hierarchy_node_csr.record_num || ':' || l_message,
	      p_message_type    => 'ERROR');
	   CN_IMPORT_PVT.write_error_rec
	     (p_imp_header_id => p_imp_header_id,
	      p_imp_line_id => l_hierarchy_node_csr.imp_line_id,
	      p_header_list => p_header_list,
	      p_sql_stmt => p_sql_stmt);
	WHEN OTHERS THEN
	   x_failed_row := x_failed_row + 1;
	   x_processed_row := x_processed_row + 1;
	   x_return_status := FND_API.G_RET_STS_ERROR ;
	   l_error_code := SQLCODE;
	   l_message := SUBSTR (SQLERRM , 1 , 2000);
	   x_error_msg := l_message;
	   CN_IMPORT_PVT.update_imp_lines
	     (p_imp_line_id => l_hierarchy_node_csr.imp_line_id,
	      p_status_code => 'FAIL',
	      p_error_code  => l_error_code,
	      p_error_msg   => l_message);
	   CN_IMPORT_PVT.update_imp_headers
	     (p_imp_header_id => p_imp_header_id,
	      p_status_code => 'IMPORT_FAIL',
	      p_failed_row => x_failed_row,
	      p_processed_row => x_processed_row);
	   cn_message_pkg.write
	     (p_message_text    => 'Record ' ||
	      l_hierarchy_node_csr.record_num || ':' || l_message,
	      p_message_type    => 'ERROR');
	   CN_IMPORT_PVT.write_error_rec
	     (p_imp_header_id => p_imp_header_id,
	      p_imp_line_id => l_hierarchy_node_csr.imp_line_id,
	      p_header_list => p_header_list,
	      p_sql_stmt => p_sql_stmt);
     END;

   END LOOP; -- end c_hierarchy_node_csr loop

   x_error_msg := l_message;

   cn_message_pkg.debug('End Import Hier Node. ');

END  Imp_Hierarchy_Node;

-- Start of comments
--    API name        : Hierarchy_Import
--    Type            : Private.
--    Function        : programtransfer data from staging table into
--                      cn_dimension_vl,cn_head_hierarchies,cn_dim_hierarchies
--                      cn_hierarchy_nodes, cn_hierarchy_edges
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_imp_header_id           IN    NUMBER,
--    OUT             : errbuf         OUT VARCHAR2       Required
--                      retcode        OUTVARCHAR2     Optional
--    Version :         Current version       1.0
--
--    Notes           : Note text
--
-- End of comments

PROCEDURE Hierarchy_Import
 ( errbuf                     OUT NOCOPY   VARCHAR2,
   retcode                    OUT NOCOPY   VARCHAR2,
   p_imp_header_id           IN    NUMBER ,
   p_org_id			IN NUMBER
   ) IS
      l_api_name     CONSTANT VARCHAR2(30) := 'Hierarchy_Import';

      l_stage_status cn_imp_lines.status_code%TYPE := 'STAGE';
      l_imp_header  cn_imp_headers_pvt.imp_headers_rec_type
	:= cn_imp_headers_pvt.G_MISS_IMP_HEADERS_REC;
      l_processed_row NUMBER := 0;
      l_failed_row    NUMBER := 0;
      l_message       VARCHAR2(2000);
      l_error_code    VARCHAR2(30);
      l_header_list   VARCHAR2(2000);
      l_sql_stmt      VARCHAR2(2000);
      err_num         NUMBER;
      l_return_status VARCHAR2(50);
      l_msg_count     NUMBER := 0;
      l_process_audit_id cn_process_audits.process_audit_id%TYPE;

      l_dimension_id  cn_dimensions_all_b.dimension_id%TYPE;
      l_head_hierarchy_id cn_head_hierarchies.head_hierarchy_id%TYPE;
      l_dim_hierarchy_id cn_dim_hierarchies.dim_hierarchy_id%TYPE;
      l_hier_record   imp_hier_rec_type;
      l_base_tbl_id        cn_obj_tables_v.table_id%TYPE;
      l_primary_key_id     cn_obj_columns_v.column_id%TYPE;
      l_hier_value_id      cn_obj_columns_v.column_id%TYPE;
      l_def_base_name      cn_hierarchy_nodes.name%TYPE;

      -- cursor to get all record missed required field
      CURSOR c_miss_required_csr IS
	 SELECT imp_line_id,record_num FROM cn_hierarchy_imp_v
	   WHERE imp_header_id = p_imp_header_id
	   AND status_code = l_stage_status
	   AND (hierarchy_type IS NULL OR BASE_TABLE_NAME IS NULL OR
		primary_key IS NULL OR hierarchy_value IS NULL OR
		hierarchy_name IS NULL OR start_date IS NULL OR
		default_node_flag IS NULL OR node_name IS NULL)
	   ;

      -- cursor to get all record with wrong default_node_flag
      CURSOR c_err_dflt_node_csr IS
	 SELECT imp_line_id,record_num FROM cn_hierarchy_imp_v
	   WHERE imp_header_id = p_imp_header_id
	   AND status_code = l_stage_status
	   AND default_node_flag <> 'Y'
	   AND default_node_flag <> 'N'
	   ;

      -- Cursor to get distinct base_table_name from stage table
      CURSOR c_base_table_csr IS
	 SELECT DISTINCT
	   Upper(base_table_name) BASE_TABLE_NAME
	   FROM CN_HIERARCHY_IMP_V
	   WHERE imp_header_id = p_imp_header_id
	   AND status_code = l_stage_status
	   ;

      -- Cursor to get distinct HIERARCHY_TYPE from stage table
      CURSOR c_hierarchy_type_csr IS
	 SELECT DISTINCT
	   trim(hierarchy_type) HIERARCHY_TYPE
	   FROM CN_HIERARCHY_IMP_V
	   WHERE imp_header_id = p_imp_header_id
	   AND status_code = l_stage_status
	   ;

      l_hierarchy_type_csr c_hierarchy_type_csr%ROWTYPE;

      -- Cursor to get distinct head_hierarchy for one hierarchy_type
      CURSOR c_head_hierarchy_csr
	(l_hier_type cn_hierarchy_imp_v.hierarchy_type%TYPE) IS
	   SELECT DISTINCT
	     trim(hierarchy_name) HIERARCHY_NAME,
	     trim(start_date) START_DATE,
	     trim(end_date) end_date
	     FROM CN_HIERARCHY_IMP_V
	     WHERE imp_header_id = p_imp_header_id
	     AND status_code = l_stage_status
	     AND hierarchy_type = l_hier_type
	     ;

      -- Cursor to get distinct dim_hierarchy for one hierarchy_type,head_hier
      CURSOR c_dim_hierarchy_csr
	(l_hier_type cn_hierarchy_imp_v.hierarchy_type%TYPE,
	 l_head_hier cn_hierarchy_imp_v.hierarchy_name%TYPE ) IS
	   SELECT DISTINCT
	     trim(start_date) START_DATE,
	     trim(end_date) end_date
	     FROM CN_HIERARCHY_IMP_V
	     WHERE imp_header_id = p_imp_header_id
	     AND status_code = l_stage_status
	     AND hierarchy_type = l_hier_type
	     AND hierarchy_name = l_head_hier
	     ;

      l_dummy  NUMBER;
      l_tmp    VARCHAR2(30);
      l_parent_node_name cn_hierarchy_imp_v.parent_node_name%TYPE;

BEGIN

   --  Initialize API return status to success
   l_return_status  := FND_API.G_RET_STS_SUCCESS;
   retcode := 0 ;

   -- Get imp_header info
   SELECT name, status_code,server_flag,imp_map_id, source_column_num,
     import_type_code
     INTO l_imp_header.name ,l_imp_header.status_code ,
     l_imp_header.server_flag, l_imp_header.imp_map_id,
     l_imp_header.source_column_num,l_imp_header.import_type_code
     FROM cn_imp_headers
     WHERE imp_header_id = p_imp_header_id;

   l_hier_record.imp_header_id := p_imp_header_id;

   -- open process audit batch
   cn_message_pkg.begin_batch
     ( x_process_type	=> l_imp_header.import_type_code,
       x_parent_proc_audit_id  => p_imp_header_id ,
       x_process_audit_id      =>  l_process_audit_id,
       x_request_id	       => null,
       p_org_id =>  p_org_id);

   cn_message_pkg.write
     (p_message_text    => 'HIERARCHY: Start Transfer Data. imp_header_id = '
      || To_char(p_imp_header_id),
      p_message_type    => 'MILESTONE');

   -- Get source column name list and target column dynamic sql statement
   CN_IMPORT_PVT.build_error_rec
     (p_imp_header_id => p_imp_header_id,
      x_header_list => l_header_list,
      x_sql_stmt => l_sql_stmt);

   -- -----------------------------------------------------------+
   -- Check for all required field
   FOR l_miss_required_csr IN c_miss_required_csr LOOP
      l_failed_row := l_failed_row + 1;
      l_processed_row := l_processed_row + 1;
      l_error_code := 'CN_IMP_MISS_REQUIRED';
      l_message := fnd_message.get_string('CN','CN_IMP_MISS_REQUIRED');
      CN_IMPORT_PVT.update_imp_lines
	(p_imp_line_id => l_miss_required_csr.imp_line_id,
	 p_status_code => 'FAIL',
	 p_error_code  => l_error_code,
	 p_error_msg   => l_message);
      CN_IMPORT_PVT.update_imp_headers
	(p_imp_header_id => p_imp_header_id,
	 p_status_code => 'IMPORT_FAIL',
	 p_failed_row => l_failed_row);
      cn_message_pkg.write
	(p_message_text    => 'Record ' ||
	 To_char(l_miss_required_csr.record_num) || ':' || l_message,
	 p_message_type    => 'ERROR');
      CN_IMPORT_PVT.write_error_rec
	(p_imp_header_id => p_imp_header_id,
	 p_imp_line_id => l_miss_required_csr.imp_line_id,
	 p_header_list => l_header_list,
	 p_sql_stmt => l_sql_stmt);

      retcode := 2;
      errbuf := l_message;
   END LOOP;

   -- -----------------------------------------------------------+
   -- Check input of DEFAULT_NODE_FLAG must be 'Y' or 'N',
   FOR l_err_dflt_node_csr IN c_err_dflt_node_csr LOOP
      l_failed_row := l_failed_row + 1;
      l_processed_row := l_processed_row + 1;
      l_error_code := 'CN_HIER_ERR_NODEFLAG';
      l_message := fnd_message.get_string('CN','CN_HIER_ERR_NODEFLAG');
      CN_IMPORT_PVT.update_imp_lines
	(p_imp_line_id => l_err_dflt_node_csr.imp_line_id,
	 p_status_code => 'FAIL',
	 p_error_code  => l_error_code,
	 p_error_msg   => l_message);
      CN_IMPORT_PVT.update_imp_headers
	(p_imp_header_id => p_imp_header_id,
	 p_status_code => 'IMPORT_FAIL',
	 p_failed_row => l_failed_row);
      cn_message_pkg.write
	(p_message_text    => 'Record ' ||
	 To_char(l_err_dflt_node_csr.record_num) || ':' || l_message,
	 p_message_type    => 'ERROR');
      CN_IMPORT_PVT.write_error_rec
	(p_imp_header_id => p_imp_header_id,
	 p_imp_line_id => l_err_dflt_node_csr.imp_line_id,
	 p_header_list => l_header_list,
	 p_sql_stmt => l_sql_stmt);

      retcode := 2;
      errbuf := l_message;
   END LOOP;

   -- -----------------------------------------------------------+
   -- Check if have multiple hierarchy for same base table within this import
   FOR l_base_table_csr IN c_base_table_csr LOOP
      BEGIN
	 l_hier_record.base_table_name := l_base_table_csr.base_table_name;
	 SELECT DISTINCT trim(hierarchy_type) hierarchy_type
	   INTO l_tmp
	   FROM CN_HIERARCHY_IMP_V
	   WHERE imp_header_id = p_imp_header_id
	   AND status_code = l_stage_status
	   AND BASE_TABLE_NAME = l_base_table_csr.BASE_TABLE_NAME
	   ;
      EXCEPTION
	 WHEN TOO_MANY_ROWS THEN
	    l_message := fnd_message.get_string('CN','CN_HIER_MULTI_BTBL');
	    seterr_imp_hierarchy
	      (p_hier_record => l_hier_record,
	       p_status_code => 'FAIL',
	       p_error_code  => 'CN_HIER_MULTI_BTBL',
	       p_error_msg   => l_message,
	       x_failed_row => l_failed_row,
	       x_processed_row => l_processed_row);

	    cn_message_pkg.write
	      (p_message_text => l_message ,
	       p_message_type => 'ERROR');
	    cn_message_pkg.write
	      (p_message_text =>
	       ' All record with base table = ' ||
	       l_hier_record.base_table_name ||
	       ' are treated as failed records.' ,
	       p_message_type => 'ERROR');

	    retcode := 2;
	    errbuf := l_message;
      END;
   END LOOP;

   -- -----------------------------------------------------------------+
   -- ----------------------- Hierarchy Type --------------------------+
   -- -----------------------------------------------------------------+
   OPEN c_hierarchy_type_csr;
   LOOP
      FETCH c_hierarchy_type_csr INTO l_hierarchy_type_csr;
      EXIT WHEN c_hierarchy_type_csr%notfound;
      l_hier_record := G_MISS_IMP_HIER_REC;
      l_hier_record.imp_header_id := p_imp_header_id;
      l_hier_record.hierarchy_type := l_hierarchy_type_csr.hierarchy_type;

      -- Import hierarchy type
      Imp_Hierarchy_Type
	(p_imp_header_id => p_imp_header_id,
	 p_hier_record   => l_hier_record,
	 x_dimension_id  => l_dimension_id,
	 x_base_table_id => l_base_tbl_id,
	 x_primary_key_id => l_primary_key_id,
	 x_hier_value_id => l_hier_value_id,
	 x_error_msg     => l_message,
	 x_return_status => l_return_status,
	 x_failed_row => l_failed_row,
	 x_processed_row => l_processed_row,
         p_org_id => p_org_id);

      IF l_return_status <> FND_API.g_ret_sts_success THEN
	 retcode := 2;
	 errbuf := l_message;
	 GOTO end_hier_type_loop;
      END IF;

      -- ---------------------------------------------------------------+
      -- --------------------- Head Hierarchy --------------------------+
      -- ---------------------------------------------------------------+
      FOR l_head_hierarchy IN
	c_head_hierarchy_csr(l_hier_record.hierarchy_type) LOOP

	 l_hier_record.hierarchy_name := l_head_hierarchy.hierarchy_name;

	 -- Import head hierarchy
	 Imp_Head_Hierarchy
	   (p_imp_header_id => p_imp_header_id,
	    p_hier_record   => l_hier_record,
	    p_dimension_id  => l_dimension_id,
	    x_head_hierarchy_id => l_head_hierarchy_id,
	    x_error_msg     => l_message,
	    x_return_status => l_return_status,
	    x_failed_row => l_failed_row,
	    x_processed_row => l_processed_row,
            p_org_id => p_org_id);

	 IF l_return_status <> FND_API.g_ret_sts_success THEN
	    retcode := 2;
	    errbuf := l_message;
	    GOTO end_head_hier_loop;
	 END IF;

      FOR l_dim_hierarchy IN
	c_dim_hierarchy_csr
	(l_hier_record.hierarchy_type,l_hier_record.hierarchy_name) LOOP
	   -- ---------------------------------------------------------------+
	   -- --------------------- Dim Hierarchy ---------------------------+
	   -- ---------------------------------------------------------------+
	   l_hier_record.start_date := l_dim_hierarchy.start_date;
	   l_hier_record.end_date := l_dim_hierarchy.end_date;
	   -- Import dim hierarchy
	   Imp_Dim_Hierarchy
	     (p_imp_header_id => p_imp_header_id,
	      p_hier_record   => l_hier_record,
	      p_head_hierarchy_id => l_head_hierarchy_id,
	      x_dim_hierarchy_id => l_dim_hierarchy_id,
	      x_error_msg     => l_message,
	      x_return_status => l_return_status,
	      x_failed_row => l_failed_row,
	      x_processed_row => l_processed_row,
              p_org_id => p_org_id);

	   IF l_return_status <> FND_API.g_ret_sts_success THEN
	      retcode := 2;
	      errbuf := l_message;
	      GOTO end_dim_hier_loop;
	   END IF;
	   -- ---------------------------------------------------------------+
	   -- --------------------- Hierarchy Node---------------------------+
	   -- ---------------------------------------------------------------+
           BEGIN
	      l_parent_node_name := 'temp';
	      -- Get default base node name from CSV file
	      SELECT trim(node_name),trim(parent_node_name)
		INTO l_def_base_name,l_parent_node_name
		FROM cn_hierarchy_imp_v
		WHERE imp_header_id = p_imp_header_id
		AND status_code = l_stage_status
		AND hierarchy_type = l_hier_record.hierarchy_type
		AND hierarchy_name = l_hier_record.hierarchy_name
		AND start_date = l_hier_record.start_date
		AND Nvl(end_date,FND_API.g_miss_char) =
		Nvl(l_hier_record.end_date,FND_API.g_miss_char)
		AND default_node_flag = 'Y'
		;
	      -- parent_node_name must be null if default_node_flag = 'Y'
	      IF l_parent_node_name IS NOT NULL THEN
		 l_message :=
		   fnd_message.get_string('CN','CN_HIER_WRONG_DEFNODE');
		 l_error_code := 'CN_HIER_WRONG_DEFNODE';
		 seterr_imp_hierarchy
		   (p_hier_record => l_hier_record,
		    p_status_code => 'FAIL',
		    p_error_code  => l_error_code,
		    p_error_msg   => l_message,
		    x_failed_row => l_failed_row,
		    x_processed_row => l_processed_row);

		 cn_message_pkg.write
		   (p_message_text => l_message ,
		    p_message_type => 'ERROR');
		 cn_message_pkg.write
		   (p_message_text =>
		    ' All record with hierarchy type = '
		    ||l_hier_record.hierarchy_type
		    || ' and Hierarchy name = ' || l_hier_record.hierarchy_name
		    || ' Start Date = ' || l_hier_record.start_date
		    || ' End Date = ' || l_hier_record.end_date
		    || ' are treated as failed records.' ,
		    p_message_type => 'ERROR');
		 retcode := 2;
		 errbuf := l_message;
		 GOTO end_dim_hier_loop;
	      END IF;

	      cn_message_pkg.debug('Def base node = ' || l_def_base_name);

	   EXCEPTION
	      WHEN no_data_found THEN
		 -- get default name from DB
		 SELECT name INTO l_def_base_name
		   FROM cn_hierarchy_nodes
		   WHERE dim_hierarchy_id = l_dim_hierarchy_id and org_id=p_org_id
		   AND external_id IS NULL ;

	      WHEN too_many_rows THEN
		 l_message :=
		   fnd_message.get_string('CN','CN_HIER_MULTI_DEFNODE');
		 l_error_code := 'CN_HIER_MULTI_DEFNODE';
		 seterr_imp_hierarchy
		   (p_hier_record => l_hier_record,
		    p_status_code => 'FAIL',
		    p_error_code  => l_error_code,
		    p_error_msg   => l_message,
		    x_failed_row => l_failed_row,
		    x_processed_row => l_processed_row);

		 cn_message_pkg.write
		   (p_message_text => l_message ,
		    p_message_type => 'ERROR');
		 cn_message_pkg.write
		   (p_message_text =>
		    ' All record with hierarchy type = '
		    ||l_hier_record.hierarchy_type
		    || ' and Hierarchy name = ' || l_hier_record.hierarchy_name
		    || ' Start Date = ' || l_hier_record.start_date
		    || ' End Date = ' || l_hier_record.end_date
		    || ' are treated as failed records.' ,
		    p_message_type => 'ERROR');
		 retcode := 2;
		 errbuf := l_message;
		 GOTO end_dim_hier_loop;
	   END;

	   -- Import hierarchy nodes
	   Imp_Hierarchy_Node
	     (p_imp_header_id => p_imp_header_id,
	      p_hier_record   => l_hier_record,
	      p_dim_hierarchy_id => l_dim_hierarchy_id,
	      p_def_base_name => l_def_base_name,
	      p_header_list => l_header_list,
	      p_sql_stmt => l_sql_stmt,
	      x_error_msg     => l_message,
	      x_return_status => l_return_status,
	      x_failed_row => l_failed_row,
	      x_processed_row => l_processed_row,
              p_org_id  => p_org_id);

	   IF l_return_status <> FND_API.g_ret_sts_success THEN
	      retcode := 2;
	      errbuf := l_message;
	      GOTO end_dim_hier_loop;
	   END IF;

	   << end_dim_hier_loop >>
	     NULL ;
	END LOOP; -- end Dim Hierarchy Loop

	<< end_head_hier_loop >>
	  NULL;
	END LOOP; -- end Head Hierarchy Loop

	<< end_hier_type_loop >>
	  NULL;
   END LOOP; -- end c_hierarchy_type_csr
   IF c_hierarchy_type_csr%rowcount = 0 THEN
      l_processed_row := 0;
   END IF;
   CLOSE c_hierarchy_type_csr;
   IF l_failed_row = 0 AND retcode = 0 THEN
      -- update update_imp_headers
      CN_IMPORT_PVT.update_imp_headers
	(p_imp_header_id => p_imp_header_id,
	 p_status_code => 'COMPLETE',
	 p_processed_row => l_processed_row,
	 p_failed_row => l_failed_row);
   END IF;
   cn_message_pkg.write
     (p_message_text    => 'HIERARCHY: End Transfer Data. imp_header_id = ' ||
      To_char(p_imp_header_id),
      p_message_type    => 'MILESTONE');

   -- close process batch
   cn_message_pkg.end_batch(l_process_audit_id);

   -- Commit all imports
   COMMIT;

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      retcode := 2 ;
      cn_message_pkg.end_batch(l_process_audit_id);
      FND_MSG_PUB.count_and_get
	(p_count   =>  l_msg_count ,
	 p_data    =>  errbuf   ,
	 p_encoded => FND_API.G_FALSE
	 );

   WHEN OTHERS THEN
      err_num :=  SQLCODE;
      IF err_num = -6501 THEN
	 retcode := 2 ;
	 errbuf := fnd_program.message;
       ELSE
	 retcode := 2 ;
	 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
	 END IF;
	 FND_MSG_PUB.count_and_get
	   (p_count   =>  l_msg_count ,
	    p_data    =>  errbuf   ,
	    p_encoded => FND_API.G_FALSE
	    );
      END IF;
      cn_message_pkg.set_error(l_api_name,errbuf);
      cn_message_pkg.end_batch(l_process_audit_id);

END Hierarchy_Import;

END CN_IMP_HIERARCHY_PVT;

/
