--------------------------------------------------------
--  DDL for Package Body FEM_DIMENSION_MIGRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_DIMENSION_MIGRATION_PKG" AS
-- $Header: femdimmig_pkb.plb 120.7 2008/02/07 00:47:50 gcheng ship $

/***************************************************************************
                    Copyright (c) 2005 Oracle Corporation
                           Redwood Shores, CA, USA
                             All rights reserved.
 ***************************************************************************
  FILENAME
    femdimmig_pkb.plb

  DESCRIPTION
    See femdimmig_pkh.pls for details

  HISTORY
   Penelope Brown 25-APR-05  Created
   Rob Flippo     25-JUL-06  Bug#5331497 insert_value_sets procedure
                             default_member_id, default_load_member_id and
                             default_hierarchy_obj_id should be null when
                             value_set is created, since these values all come
                             from sequence that is not identical between source
                             and target db
   mwickram       08-AUG-06  Bug 5287339 - DIMENSION HIERARCHY MIGRATION FAILS

 **************************************************************************/

-------------------------------
-- Declare package variables --
-------------------------------
   f_set_status  BOOLEAN;

   c_log_level_1  CONSTANT  NUMBER  := fnd_log.level_statement;
   c_log_level_2  CONSTANT  NUMBER  := fnd_log.level_procedure;
   c_log_level_3  CONSTANT  NUMBER  := fnd_log.level_event;
   c_log_level_4  CONSTANT  NUMBER  := fnd_log.level_exception;
   c_log_level_5  CONSTANT  NUMBER  := fnd_log.level_error;
   c_log_level_6  CONSTANT  NUMBER  := fnd_log.level_unexpected;

   v_log_level    NUMBER;

   gv_prg_msg      VARCHAR2(2000);
   gv_callstack    VARCHAR2(2000);

-- Global Variables for Post Processing information
   gv_rows_fetched                    NUMBER := 0;
   gv_rows_rejected                   NUMBER := 0;
   gv_rows_loaded                     NUMBER := 0;
   gv_temp_rows_rejected              NUMBER := 0;

   gv_request_id  NUMBER := fnd_global.conc_request_id;
   gv_apps_user_id     NUMBER := FND_GLOBAL.User_Id;
   gv_login_id    NUMBER := FND_GLOBAL.Login_Id;
   gv_pgm_id      NUMBER := FND_GLOBAL.Conc_Program_Id;
   gv_pgm_app_id  NUMBER := FND_GLOBAL.Prog_Appl_ID;
   gv_concurrent_status BOOLEAN;

   -- Execution Mode Clause for all Fetches against the interface tables
   --gv_exec_mode_clause VARCHAR2(100);

   -- Bulk Fetch profile no longer used
   -- Default limit for all BULK Fetches
   --gv_fetch_limit  NUMBER := NVL(FND_PROFILE.Value_Specific(
   --                         'FEM_BULK_FETCH_LIMIT',gv_apps_user_id,null,null),
   --                          c_fetch_limit);

   gv_dim_props_rec   DIMENSION_PROPS_REC;
   gv_src_dim_props_rec   DIMENSION_PROPS_REC;
   gv_db_link_name VARCHAR2(40);

-----------------------------------------------
-- Declare private procedures and functions --
-----------------------------------------------

FUNCTION GET_DIM_ATTR_SQL(p_version_mode    IN VARCHAR2,
                          p_source_db_link  IN VARCHAR2,
                          p_dim_varchar_lbl IN VARCHAR2) RETURN VARCHAR2;

FUNCTION GET_DIM_HIER_RULE_SQL(p_dim_varchar_lbl   IN VARCHAR2,
                               p_folder_name       IN VARCHAR2,
                               p_hier_obj_name     IN VARCHAR2,
                               p_hier_obj_def_name IN VARCHAR2,
                               p_source_db_link    IN VARCHAR2,
                               p_eff_start_date    IN DATE,
                               p_eff_end_date      IN DATE) RETURN VARCHAR2;

FUNCTION GET_DIM_HIER_SQL(p_hier_obj_name     IN VARCHAR2,
                          p_hier_obj_def_name IN VARCHAR2,
                          p_hier_obj_def_id   IN NUMBER,
                          p_dim_varchar_lbl   IN VARCHAR2,
                          p_source_db_link    IN VARCHAR2) RETURN VARCHAR2;

FUNCTION GET_HIER_DG_SQL(p_hier_obj_name  IN VARCHAR2,
                         p_source_db_link IN VARCHAR2) RETURN VARCHAR2;

FUNCTION GET_HIER_VS_SQL(p_hier_obj_name  IN VARCHAR2,
                         p_source_db_link IN VARCHAR2) RETURN VARCHAR2;


FUNCTION GET_INSERT_B_SQL(p_source_db_link  IN VARCHAR2,
                          p_dim_varchar_lbl IN VARCHAR2) RETURN VARCHAR2;

FUNCTION GET_INSERT_DIM_GRP_B_SQL(p_source_db_link IN VARCHAR2) RETURN VARCHAR2;

FUNCTION GET_INSERT_DIM_GRP_TL_SQL(p_source_db_link IN VARCHAR2) RETURN VARCHAR2;

FUNCTION GET_INSERT_TL_SQL(p_source_db_link  IN VARCHAR2,
                           p_dim_varchar_lbl IN VARCHAR2) RETURN VARCHAR2;


FUNCTION VALIDATE_DB_LINK(p_db_link IN VARCHAR2) RETURN VARCHAR2;


PROCEDURE GET_DIMENSION_INFO(p_dim_name             IN VARCHAR2,
                             p_source_user_dim_name IN VARCHAR2,
                             p_source_db_link       IN VARCHAR2);

PROCEDURE GET_PUT_MESSAGES (p_msg_count       IN   NUMBER,
                            p_msg_data        IN   VARCHAR2);

PROCEDURE INSERT_CALENDARS(p_source_db_link IN VARCHAR2);

PROCEDURE INSERT_VALUE_SETS(p_source_db_link IN VARCHAR2);

PROCEDURE POST_PROCESS_HIERARCHY(p_execution_status IN VARCHAR2);

PROCEDURE POST_PROCESS_MEMBERS(p_execution_status IN VARCHAR2);

PROCEDURE PRE_PROCESS_HIERARCHY(p_source_db_link             IN   VARCHAR2,
                                p_dim_varchar_lbl            IN   VARCHAR2,
                                p_hier_obj_name              IN   VARCHAR2,
                                p_hier_obj_def_name          IN   VARCHAR2,
                                p_source_user_dim_name       IN   VARCHAR2,
                                x_folder_name                OUT  NOCOPY VARCHAR2,
                                x_hier_obj_id                OUT  NOCOPY NUMBER);

PROCEDURE PRE_PROCESS_MEMBERS(p_source_db_link             IN   VARCHAR2,
                              p_dim_varchar_lbl            IN   VARCHAR2,
                              p_autoload_dims              IN   VARCHAR2,
                              p_migrate_dependent_dims     IN   VARCHAR2,
                              p_version_mode               IN   VARCHAR2,
                              p_version_disp_cd            IN   VARCHAR2,
                              p_version_name               IN   VARCHAR2,
                              p_source_user_dim_name       IN   VARCHAR2,
                              p_hier_obj_name              IN   VARCHAR2,
                              p_hier_obj_def_name          IN   VARCHAR2);

PROCEDURE PROCESS_HIERARCHY(p_dim_varchar_lbl      IN  VARCHAR2,
                            p_folder_name          IN  VARCHAR2,
                            p_hier_obj_id          IN  NUMBER,
                            p_hier_obj_name        IN  VARCHAR2,
                            p_hier_obj_def_name    IN  VARCHAR2,
                            p_source_db_link       IN  VARCHAR2,
                            p_source_user_dim_name IN  VARCHAR2);

PROCEDURE PROCESS_MEMBERS(p_dim_varchar_lbl IN   VARCHAR2,
                          p_version_mode    IN   VARCHAR2,
                          p_source_db_link  IN   VARCHAR2);

PROCEDURE REGISTER_PROCESS_EXECUTION(p_object_id         IN  NUMBER,
                                     p_obj_def_id        IN  NUMBER,
                                     p_execution_mode    IN  VARCHAR2);

PROCEDURE UPDATE_CALP_ATTRIBUTES(p_source_db_link IN VARCHAR2);

PROCEDURE VALIDATE_PARAMETERS(p_source_db_link          IN   VARCHAR2,
                              p_autoload_dims           IN   VARCHAR2,
                              p_migrate_dependent_dims  IN   VARCHAR2,
                              p_version_mode            IN   VARCHAR2,
                              p_version_disp_cd         IN   VARCHAR2,
                              p_version_name            IN   VARCHAR2,
                              p_source_user_dim_name    IN   VARCHAR2,
                              p_hier_obj_name           IN   VARCHAR2,
                              p_hier_obj_def_name       IN   VARCHAR2);



-----------------------------------------------
-- Validate dbLink --
-----------------------------------------------
FUNCTION VALIDATE_DB_LINK(p_db_link IN VARCHAR2) RETURN VARCHAR2 IS

c_func_name        VARCHAR2(30) := 'VALIDATE_DB_LINK';

l_db_link_name     VARCHAR2(40);
l_db_link_sql      VARCHAR2(100);

BEGIN

--Validate dbLink Parameter supplied is registered in FEM

SELECT DB_LINK_NAME
INTO gv_db_link_name
FROM FEM_DB_LINKS_VL
WHERE UPPER(DATABASE_LINK) = UPPER(p_db_link);

--Validate dbLink is functioning properly
l_db_link_sql   := 'SELECT SYSDATE FROM DUAL@'||p_db_link;

EXECUTE IMMEDIATE l_db_link_sql;

RETURN 'VALID';

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE e_db_link_not_registered;
  WHEN OTHERS THEN
    RAISE e_db_link_not_functional;
END;







-----------------------------------------------
-- Get Dimension Info --
-----------------------------------------------
PROCEDURE GET_DIMENSION_INFO(p_dim_name IN VARCHAR2,
                             p_source_user_dim_name IN VARCHAR2,
                             p_source_db_link  IN VARCHAR2)

IS

l_temp_dim_name    VARCHAR2(150);

l_chk_dim_name_sql  VARCHAR2(1000) := 'SELECT DIMENSION_NAME ' ||
                                      'FROM FEM_DIMENSIONS_TL '||'@'||p_source_db_link||' '||
                                      'WHERE UPPER(DIMENSION_NAME) = UPPER(:src_dim_name)';
l_dim_name_sql   VARCHAR2(2000) := 'SELECT DIMENSION_ID, '||
       'USER_DEFINED_FLAG, '||
       'GROUP_USE_CODE, '||
       'VALUE_SET_REQUIRED_FLAG, '||
       'MEMBER_B_TABLE_NAME, '||
       'ATTRIBUTE_TABLE_NAME, '||
       'MEMBER_DISPLAY_CODE_COL, '||
       'MEMBER_NAME_COL, '||
       'MEMBER_DESCRIPTION_COL, '||
       'MEMBER_TL_TABLE_NAME, '||
       'MEMBER_COL, '||
       'DECODE(LOADER_OBJECT_DEF_ID, NULL, NULL, LOADER_OBJECT_DEF_ID+ 700), '||
       'HIERARCHY_TABLE_NAME, '||
       'DECODE(HIERARCHY_TABLE_NAME, NULL, NULL, HIERARCHY_TABLE_NAME||''_T'')'||
'FROM   FEM_XDIM_DIMENSIONS_VL '||'@'||p_source_db_link||' '||
'WHERE  DIMENSION_NAME = :p_source_user_dim_name';

BEGIN

SELECT DIMENSION_ID,
       DECODE(LOADER_OBJECT_DEF_ID, NULL, NULL, LOADER_OBJECT_DEF_ID+ 700),
       USER_DEFINED_FLAG,
       GROUP_USE_CODE,
       SIMPLE_DIMENSION_FLAG,
       VALUE_SET_REQUIRED_FLAG,
       INTF_MEMBER_B_TABLE_NAME,
       INTF_MEMBER_TL_TABLE_NAME,
       INTF_ATTRIBUTE_TABLE_NAME,
       MEMBER_B_TABLE_NAME,
       ATTRIBUTE_TABLE_NAME,
       MEMBER_DISPLAY_CODE_COL,
       MEMBER_NAME_COL,
       MEMBER_DESCRIPTION_COL,
       MEMBER_TL_TABLE_NAME,
       MEMBER_COL,
       HIERARCHY_TABLE_NAME,
       DECODE(HIERARCHY_TABLE_NAME, NULL, NULL, HIERARCHY_TABLE_NAME||'_T')
INTO   gv_dim_props_rec.DIMENSION_ID,
       gv_dim_props_rec.MIGRATION_OBJ_DEF_ID,
       gv_dim_props_rec.USER_DEFINED_FLAG,
       gv_dim_props_rec.GROUP_USE_CODE,
       gv_dim_props_rec.SIMPLE_DIMENSION_FLAG,
       gv_dim_props_rec.VALUE_SET_REQUIRED_FLAG,
       gv_dim_props_rec.INTF_MEMBER_B_TABLE_NAME,
       gv_dim_props_rec.INTF_MEMBER_TL_TABLE_NAME,
       gv_dim_props_rec.INTF_ATTRIBUTE_TABLE_NAME,
       gv_dim_props_rec.MEMBER_B_TABLE_NAME,
       gv_dim_props_rec.ATTRIBUTE_TABLE_NAME,
       gv_dim_props_rec.MEMBER_DISPLAY_CODE_COL,
       gv_dim_props_rec.MEMBER_NAME_COL,
       gv_dim_props_rec.MEMBER_DESCRIPTION_COL,
       gv_dim_props_rec.MEMBER_TL_TABLE_NAME,
       gv_dim_props_rec.MEMBER_COL,
       gv_dim_props_rec.HIERARCHY_TABLE_NAME,
       gv_dim_props_rec.HIERARCHY_INTF_TABLE_NAME
FROM   FEM_XDIM_DIMENSIONS_VL
WHERE  DIMENSION_VARCHAR_LABEL = UPPER(p_dim_name);


IF (gv_dim_props_rec.MIGRATION_OBJ_DEF_ID IS NULL) THEN
  RAISE e_dimension_not_supported;
END IF;

IF (p_source_user_dim_name IS NOT NULL AND gv_dim_props_rec.USER_DEFINED_FLAG = 'N') THEN
  RAISE e_dim_not_user_extensible;
ELSIF (p_source_user_dim_name IS NOT NULL AND gv_dim_props_rec.USER_DEFINED_FLAG = 'Y') THEN
  BEGIN

    EXECUTE IMMEDIATE l_chk_dim_name_sql INTO l_temp_dim_name USING p_source_user_dim_name;

    IF (SQL%FOUND) THEN
      EXECUTE IMMEDIATE l_dim_name_sql
      INTO   gv_src_dim_props_rec.DIMENSION_ID,
             gv_src_dim_props_rec.USER_DEFINED_FLAG,
             gv_src_dim_props_rec.GROUP_USE_CODE,
             gv_src_dim_props_rec.VALUE_SET_REQUIRED_FLAG,
             gv_src_dim_props_rec.MEMBER_B_TABLE_NAME,
             gv_src_dim_props_rec.ATTRIBUTE_TABLE_NAME,
             gv_src_dim_props_rec.MEMBER_DISPLAY_CODE_COL,
             gv_src_dim_props_rec.MEMBER_NAME_COL,
             gv_src_dim_props_rec.MEMBER_DESCRIPTION_COL,
             gv_src_dim_props_rec.MEMBER_TL_TABLE_NAME,
             gv_src_dim_props_rec.MEMBER_COL,
             gv_src_dim_props_rec.MIGRATION_OBJ_DEF_ID,
             gv_src_dim_props_rec.HIERARCHY_TABLE_NAME,
             gv_src_dim_props_rec.HIERARCHY_INTF_TABLE_NAME
     USING p_source_user_dim_name;

    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE e_src_dim_not_user_extensible;
  END;

END IF;


IF (gv_src_dim_props_rec.USER_DEFINED_FLAG = 'N') THEN
  RAISE e_src_dim_not_user_extensible;
END IF;

IF (gv_src_dim_props_rec.DIMENSION_ID IS NULL) THEN
   gv_src_dim_props_rec.DIMENSION_ID := gv_dim_props_rec.DIMENSION_ID;
   gv_src_dim_props_rec.GROUP_USE_CODE := gv_dim_props_rec.GROUP_USE_CODE;
   gv_src_dim_props_rec.VALUE_SET_REQUIRED_FLAG:= gv_dim_props_rec.VALUE_SET_REQUIRED_FLAG;
   gv_src_dim_props_rec.MEMBER_B_TABLE_NAME := gv_dim_props_rec.MEMBER_B_TABLE_NAME;
   gv_src_dim_props_rec.ATTRIBUTE_TABLE_NAME := gv_dim_props_rec.ATTRIBUTE_TABLE_NAME;
   gv_src_dim_props_rec.MEMBER_DISPLAY_CODE_COL := gv_dim_props_rec.MEMBER_DISPLAY_CODE_COL;
   gv_src_dim_props_rec.MEMBER_NAME_COL := gv_dim_props_rec.MEMBER_NAME_COL;
   gv_src_dim_props_rec.MEMBER_DESCRIPTION_COL := gv_dim_props_rec.MEMBER_DESCRIPTION_COL;
   gv_src_dim_props_rec.MEMBER_TL_TABLE_NAME := gv_dim_props_rec.MEMBER_TL_TABLE_NAME;
   gv_src_dim_props_rec.MEMBER_COL := gv_dim_props_rec.MEMBER_COL;
   gv_src_dim_props_rec.MIGRATION_OBJ_DEF_ID := gv_dim_props_rec.MIGRATION_OBJ_DEF_ID;
   gv_src_dim_props_rec.HIERARCHY_TABLE_NAME := gv_dim_props_rec.HIERARCHY_TABLE_NAME;
   gv_src_dim_props_rec.HIERARCHY_INTF_TABLE_NAME := gv_dim_props_rec.HIERARCHY_INTF_TABLE_NAME;


END IF;

BEGIN

SELECT object_id
INTO gv_dim_props_rec.MIGRATION_OBJ_ID
FROM fem_object_definition_b
WHERE object_definition_id = gv_dim_props_rec.MIGRATION_OBJ_DEF_ID
AND object_id IN (SELECT object_id FROM fem_object_catalog_b
WHERE object_type_code = 'DIM_MEMBER_MIGRATION');

SELECT object_id
INTO gv_src_dim_props_rec.MIGRATION_OBJ_ID
FROM fem_object_definition_b
WHERE object_definition_id = gv_src_dim_props_rec.MIGRATION_OBJ_DEF_ID
AND object_id IN (SELECT object_id FROM fem_object_catalog_b
WHERE object_type_code = 'DIM_MEMBER_MIGRATION');

EXCEPTION

WHEN NO_DATA_FOUND THEN
  RAISE e_invalid_obj_def;
END;

EXCEPTION

WHEN NO_DATA_FOUND THEN
  RAISE e_invalid_dimension;
END;


-----------------------------------------------
-- Validate parameters --
-----------------------------------------------

PROCEDURE validate_parameters(p_source_db_link          IN  VARCHAR2,
                              p_autoload_dims           IN  VARCHAR2,
                              p_migrate_dependent_dims  IN  VARCHAR2,
                              p_version_mode            IN  VARCHAR2,
                              p_version_disp_cd         IN   VARCHAR2,
                              p_version_name            IN   VARCHAR2,
                              p_source_user_dim_name    IN  VARCHAR2,
                              p_hier_obj_name           IN  VARCHAR2,
                              p_hier_obj_def_name  IN  VARCHAR2)
IS

l_chk_version_name_sql     VARCHAR2(1000) := 'SELECT VERSION_NAME ' ||
                                             'FROM FEM_DIM_ATTR_VERSIONS_TL '||'@'||p_source_db_link||' '||
                                             'WHERE UPPER(VERSION_NAME) = UPPER(:p_version_name)';

l_chk_version_disp_cd_sql  VARCHAR2(1000) := 'SELECT VERSION_DISPLAY_CODE' ||
                                             'FROM FEM_DIM_ATTR_VERSIONS_B '||'@'||p_source_db_link||' '||
                                             'WHERE UPPER(VERSION_DISPLAY_CODE) = UPPER(:p_version_disp_cd)';

l_temp_version_name  VARCHAR2(150);
l_temp_version_disp_cd  VARCHAR2(150);

BEGIN


IF (p_version_mode IS NULL OR p_version_mode NOT IN ('ALL', 'DEFAULT', 'NEW')) THEN
  RAISE e_invalid_version_param;
ELSIF (p_version_mode = 'NEW') THEN
  IF (p_version_disp_cd IS NULL OR p_version_name IS NULL) THEN
    RAISE e_missing_version_params;
  ELSE
      BEGIN

        EXECUTE IMMEDIATE l_chk_version_name_sql INTO l_temp_version_name USING p_version_name;

        IF (SQL%FOUND) THEN
          RAISE e_invalid_version_name;
        END IF;

        EXECUTE IMMEDIATE l_chk_version_disp_cd_sql INTO l_temp_version_disp_cd USING p_version_disp_cd;

        IF (SQL%FOUND) THEN
          RAISE e_invalid_version_display_code;
        END IF;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         --version name is good--
         NULL;
     END;
  END IF;
END IF;

--TO DO:  VALIDATE HIER PARAMS--
END;

-------------------------------------------------------------
--  Procedure for getting messages off the stack
-------------------------------------------------------------
PROCEDURE Get_Put_Messages (
   p_msg_count       IN   NUMBER,
   p_msg_data        IN   VARCHAR2
)
IS

v_msg_count        NUMBER;
v_msg_data         VARCHAR2(4000);
v_msg_out          NUMBER;
v_message          VARCHAR2(4000);

v_block  CONSTANT  VARCHAR2(80) :=
   'fem.plsql.fem_dim_member_loader_pkg.get_put_messages';

BEGIN

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.msg_count',
  p_msg_text => p_msg_count);

v_msg_data := p_msg_data;

IF (p_msg_count = 1)
THEN
   FND_MESSAGE.Set_Encoded(v_msg_data);
   v_message := FND_MESSAGE.Get;

   FEM_ENGINES_PKG.User_Message(
     p_msg_text => v_message);

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.msg_data',
     p_msg_text => v_message);

ELSIF (p_msg_count > 1)
THEN
   FOR i IN 1..p_msg_count
   LOOP
      FND_MSG_PUB.Get(
      p_msg_index => i,
      p_encoded => c_false,
      p_data => v_message,
      p_msg_index_out => v_msg_out);

      FEM_ENGINES_PKG.User_Message(
        p_msg_text => v_message);

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_2,
        p_module => v_block||'.msg_data',
        p_msg_text => v_message);

   END LOOP;
END IF;

   FND_MSG_PUB.Initialize;

END Get_Put_Messages;

-----------------------------------------------
-- Build Insert _B SQL --
-----------------------------------------------
FUNCTION get_insert_b_sql(p_source_db_link IN VARCHAR2, p_dim_varchar_lbl IN VARCHAR2) RETURN VARCHAR2

IS

l_dim_vc_select VARCHAR2(35) := ''''||p_dim_varchar_lbl||'''';
l_base_select VARCHAR2(35) := 'B.'||gv_src_dim_props_rec.MEMBER_DISPLAY_CODE_COL;
l_vs_select VARCHAR2(35) := 'VS.VALUE_SET_DISPLAY_CODE';
l_dg_select VARCHAR2(35) := 'DG.DIMENSION_GROUP_DISPLAY_CODE';
l_status_select VARCHAR2(10) := '''LOAD''';
l_batch_name_select VARCHAR2(30) := '''Y''';

l_base_from VARCHAR2(100) := gv_src_dim_props_rec.MEMBER_B_TABLE_NAME||'@'||p_source_db_link||' B';
l_vs_from VARCHAR2(100) := 'FEM_VALUE_SETS_B@'||p_source_db_link||' VS';
l_dim_grp_from VARCHAR2(100) := 'FEM_DIMENSION_GRPS_B@'||p_source_db_link||' DG';

l_base_vs_where VARCHAR2(35) := 'B.VALUE_SET_ID = VS.VALUE_SET_ID';
l_base_dg_where VARCHAR2(50) := 'B.DIMENSION_GROUP_ID = DG.DIMENSION_GROUP_ID(+)';

l_insert_table  VARCHAR2(100) := gv_dim_props_rec.INTF_MEMBER_B_TABLE_NAME;
l_comma1 VARCHAR2(2) := ', ';
l_semi VARCHAR2(1) := ';';
l_where_clause VARCHAR2(1000) := --' WHERE NOT EXISTS (SELECT 1 FROM '||l_insert_table||' INTF WHERE INTF.'||
                                -- gv_dim_props_rec.MEMBER_DISPLAY_CODE_COL||' = '||l_base_select||')'||
                                ' WHERE {{data_slice}}';


l_cal_period_select VARCHAR2(1000) := 'CA2.DATE_ASSIGN_VALUE, CA1.NUMBER_ASSIGN_VALUE, ''LOAD'', CAL.CALENDAR_DISPLAY_CODE, '||
                                      'DG.DIMENSION_GROUP_DISPLAY_CODE, ''Y''';

l_cal_period_from VARCHAR2(1000) := 'FEM_CAL_PERIODS_B@'||p_source_db_link||' B, FEM_DIM_ATTRIBUTES_B@'||
                      p_source_db_link||' DA1 , FEM_DIM_ATTRIBUTES_B@'||p_source_db_link||' DA2, FEM_DIMENSION_GRPS_B@'||
                      p_source_db_link||' DG, '||
                     'FEM_CAL_PERIODS_ATTR@'||p_source_db_link||' CA1, FEM_CAL_PERIODS_ATTR@'||p_source_db_link||' CA2,'||
                     ' FEM_CALENDARS_B@'||p_source_db_link||' CAL ';

l_cal_period_where VARCHAR2(1000) := 'WHERE B.CAL_PERIOD_ID = CA1.CAL_PERIOD_ID AND B.CAL_PERIOD_ID = CA2.CAL_PERIOD_ID'||
                      ' AND B.CALENDAR_ID = CAL.CALENDAR_ID AND CA1.ATTRIBUTE_ID = DA1.ATTRIBUTE_ID'||
                      ' AND CA2.ATTRIBUTE_ID = DA2.ATTRIBUTE_ID AND DA1.ATTRIBUTE_VARCHAR_LABEL = ''GL_PERIOD_NUM'''||
                      ' AND DA2.ATTRIBUTE_VARCHAR_LABEL = ''CAL_PERIOD_END_DATE'''||
                      ' AND B.DIMENSION_GROUP_ID = DG.DIMENSION_GROUP_ID(+) AND {{data_slice}}'||
                      ' AND CA1.AW_SNAPSHOT_FLAG = ''N'' AND CA2.AW_SNAPSHOT_FLAG = ''N''';


l_insert_sql VARCHAR2(32767);


BEGIN


IF (p_dim_varchar_lbl = 'CAL_PERIOD') THEN
  l_insert_sql := 'INSERT INTO '||l_insert_table||
'(SELECT '|| l_cal_period_select||
' FROM '|| l_cal_period_from||l_cal_period_where||')';

ELSE


l_base_select := l_base_select||l_comma1;
l_status_select := l_status_select||l_comma1;


IF (gv_src_dim_props_rec.VALUE_SET_REQUIRED_FLAG = 'Y') THEN
  l_vs_select := l_vs_select ||l_comma1;

ELSIF (gv_src_dim_props_rec.VALUE_SET_REQUIRED_FLAG = 'N') THEN
  l_vs_select := NULL;
  l_vs_from := NULL;
  l_base_vs_where := NULL;
END IF;

IF (gv_src_dim_props_rec.GROUP_USE_CODE = 'NOT_SUPPORTED') THEN
  l_dg_select := NULL;
  l_base_dg_where := NULL;
  l_dim_grp_from := NULL;
ELSE
  l_dg_select := l_dg_select||l_comma1;
END IF;

IF (gv_dim_props_rec.INTF_MEMBER_B_TABLE_NAME = 'FEM_SIMPLE_DIMS_B_T') THEN
  l_dim_vc_select := l_dim_vc_select||l_comma1;
ELSE
  l_dim_vc_select := NULL;
END IF;

IF (l_base_vs_where IS NULL AND l_base_dg_where IS NULL) THEN
  l_where_clause := l_where_clause;
ELSIF (l_base_vs_where IS NULL AND l_base_dg_where IS NOT NULL) THEN
  l_base_from := l_base_from||l_comma1;
  l_where_clause := l_where_clause||' AND '||l_base_dg_where;
ELSIF (l_base_vs_where IS NOT NULL AND l_base_dg_where IS NULL) THEN
  l_base_from := l_base_from||l_comma1;
  l_where_clause := l_where_clause||' AND '||l_base_vs_where;
ELSE
  l_base_from := l_base_from||l_comma1;
  l_vs_from := l_vs_from||l_comma1;
  l_where_clause := l_where_clause||' AND '||l_base_vs_where|| ' AND '||l_base_dg_where;
END IF;

l_insert_sql := 'INSERT INTO '||l_insert_table||
'(SELECT '|| l_dim_vc_select||l_base_select||
             l_vs_select||
             l_status_select||
             l_dg_select||
             l_batch_name_select||
' FROM '|| l_base_from||
           l_vs_from||
           l_dim_grp_from||l_where_clause||')';

END IF;


RETURN l_insert_sql;
END;














-----------------------------------------------
-- Build Insert _TL SQL --
-----------------------------------------------
FUNCTION get_insert_tl_sql(p_source_db_link IN VARCHAR2, p_dim_varchar_lbl IN VARCHAR2) RETURN VARCHAR2

IS

l_dim_vc_select VARCHAR2(35) := ''''||p_dim_varchar_lbl||'''';
l_tl_dc_select VARCHAR2(35) := 'B.'||gv_src_dim_props_rec.MEMBER_DISPLAY_CODE_COL;
l_vs_select VARCHAR2(35) := 'VS.VALUE_SET_DISPLAY_CODE';
l_status_select VARCHAR2(10) := '''LOAD''';
l_tl_lang_select VARCHAR2(35) := 'TL.LANGUAGE';
l_tl_name_select VARCHAR2(35) := 'TL.'||gv_src_dim_props_rec.MEMBER_NAME_COL;
l_tl_desc_select VARCHAR2(35) := 'TL.'||gv_src_dim_props_rec.MEMBER_DESCRIPTION_COL;
l_batch_name_select VARCHAR2(30) := '''Y''';

l_tl_from VARCHAR2(500):= gv_src_dim_props_rec.MEMBER_B_TABLE_NAME||'@'||p_source_db_link||' B, '||
                          gv_src_dim_props_rec.MEMBER_TL_TABLE_NAME||'@'||p_source_db_link||' TL';
l_vs_from VARCHAR2(100) := 'FEM_VALUE_SETS_B@'||p_source_db_link||' VS';

l_tl_vs_where VARCHAR2(100) := 'TL.VALUE_SET_ID = VS.VALUE_SET_ID';

l_insert_table  VARCHAR2(100) := gv_dim_props_rec.INTF_MEMBER_TL_TABLE_NAME;
l_comma1 VARCHAR2(2) := ', ';
l_semi VARCHAR2(1) := ';';
l_where_clause VARCHAR2(1000) := ' WHERE B.' ||gv_src_dim_props_rec.MEMBER_COL || ' = TL.'|| gv_src_dim_props_rec.MEMBER_COL||
                                --' AND NOT EXISTS (SELECT 1 FROM '||l_insert_table||' INTF WHERE INTF.'||
                                -- gv_dim_props_rec.MEMBER_DISPLAY_CODE_COL||' = '||l_tl_dc_select||')'||
                                ' AND {{data_slice}} AND EXISTS (SELECT 1 FROM FND_LANGUAGES L'||
                                ' WHERE TL.LANGUAGE = L.LANGUAGE_CODE AND L.INSTALLED_FLAG IN (''I'',''B''))';



l_cal_period_select VARCHAR2(1000) := 'CA2.DATE_ASSIGN_VALUE, CA1.NUMBER_ASSIGN_VALUE, TL.LANGUAGE, '||
                                     'TL.CAL_PERIOD_NAME, TL.DESCRIPTION, ''LOAD'', CAL.CALENDAR_DISPLAY_CODE, '||
                                      'DG.DIMENSION_GROUP_DISPLAY_CODE, ''Y''';

l_cal_period_from VARCHAR2(1000) := 'FEM_CAL_PERIODS_B@'||p_source_db_link||' B, FEM_CAL_PERIODS_TL@'||
                                    p_source_db_link||' TL, FEM_DIM_ATTRIBUTES_B@'||p_source_db_link||
                                    ' DA1 , FEM_DIM_ATTRIBUTES_B@'||p_source_db_link||' DA2, FEM_DIMENSION_GRPS_B@'||
                                    p_source_db_link||' DG, '||
                                    'FEM_CAL_PERIODS_ATTR@'||p_source_db_link||' CA1, FEM_CAL_PERIODS_ATTR@'||
                                    p_source_db_link||' CA2, FEM_CALENDARS_B@'||p_source_db_link||' CAL ';

l_cal_period_where VARCHAR2(1000) := 'WHERE B.CAL_PERIOD_ID = TL.CAL_PERIOD_ID AND B.CAL_PERIOD_ID = CA1.CAL_PERIOD_ID AND B.CAL_PERIOD_ID = CA2.CAL_PERIOD_ID'||
                      ' AND B.CALENDAR_ID = CAL.CALENDAR_ID AND CA1.ATTRIBUTE_ID = DA1.ATTRIBUTE_ID'||
                      ' AND CA2.ATTRIBUTE_ID = DA2.ATTRIBUTE_ID AND DA1.ATTRIBUTE_VARCHAR_LABEL = ''GL_PERIOD_NUM'''||
                      ' AND DA2.ATTRIBUTE_VARCHAR_LABEL = ''CAL_PERIOD_END_DATE'''||
                      ' AND B.DIMENSION_GROUP_ID = DG.DIMENSION_GROUP_ID(+) AND {{data_slice}}'||
                      ' AND CA1.AW_SNAPSHOT_FLAG = ''N'' AND CA2.AW_SNAPSHOT_FLAG = ''N'''||
                      ' AND EXISTS (SELECT 1 FROM FND_LANGUAGES L'||
                                ' WHERE TL.LANGUAGE = L.LANGUAGE_CODE AND L.INSTALLED_FLAG IN (''I'',''B''))';

l_insert_sql VARCHAR2(32767);


BEGIN


IF (p_dim_varchar_lbl = 'CAL_PERIOD') THEN
  l_insert_sql := 'INSERT INTO '||l_insert_table||
'(SELECT '|| l_cal_period_select||
' FROM '|| l_cal_period_from||l_cal_period_where||')';

ELSE

l_tl_dc_select  := l_tl_dc_select ||l_comma1;
l_tl_lang_select := l_tl_lang_select||l_comma1;
l_tl_name_select  := l_tl_name_select ||l_comma1;
l_tl_desc_select  := l_tl_desc_select ||l_comma1;
l_status_select := l_status_select||l_comma1;

IF (gv_dim_props_rec.INTF_MEMBER_TL_TABLE_NAME = 'FEM_SIMPLE_DIMS_TL_T') THEN
  l_dim_vc_select := l_dim_vc_select||l_comma1;
ELSE
  l_dim_vc_select := NULL;
END IF;

IF (gv_src_dim_props_rec.VALUE_SET_REQUIRED_FLAG = 'Y') THEN
  l_vs_select := l_vs_select ||l_comma1;

ELSIF (gv_src_dim_props_rec.VALUE_SET_REQUIRED_FLAG = 'N') THEN
  l_vs_select := NULL;
  l_vs_from := NULL;
  l_tl_vs_where := NULL;
END IF;

/*IF (gv_dim_props_rec.GROUP_USE_CODE = 'NOT_SUPPORTED') THEN
  l_dg_select := NULL;
  l_base_dg_where := NULL;
  l_dim_grp_from := NULL;
ELSE
  l_status_select := l_status_select||l_comma1;
END IF;*/

IF (l_tl_vs_where IS NULL) THEN
  l_where_clause := l_where_clause;
ELSE
  l_tl_from := l_tl_from||l_comma1;
  l_where_clause := l_where_clause||' AND '||l_tl_vs_where;
END IF;

l_insert_sql := 'INSERT INTO '||l_insert_table||
'(SELECT '|| l_dim_vc_select||l_tl_dc_select||
             l_vs_select||
             l_tl_lang_select||
             l_tl_name_select||
             l_tl_desc_select||
             l_status_select||
             l_batch_name_select||
' FROM '|| l_tl_from||
           l_vs_from||l_where_clause||')';

END IF;


RETURN l_insert_sql;
END;





-----------------------------------------------
-- Build Insert _ATTR SQL --
-----------------------------------------------
FUNCTION get_dim_attr_sql(p_version_mode  IN VARCHAR2, p_source_db_link IN VARCHAR2,p_dim_varchar_lbl IN VARCHAR2)
RETURN VARCHAR2

IS

l_insert_clause VARCHAR2(100) :=
  ' INSERT INTO '|| gv_dim_props_rec.INTF_ATTRIBUTE_TABLE_NAME;

l_insert_cols  VARCHAR2(2000) :=
  ' ( '||gv_dim_props_rec.MEMBER_DISPLAY_CODE_COL||', ATTRIBUTE_VARCHAR_LABEL,'||
  ' ATTRIBUTE_ASSIGN_VALUE, ATTR_ASSIGN_VS_DISPLAY_CODE, STATUS, CREATED_BY_DIM_MIGRATION_FLAG,'||
  ' CALPATTR_CAL_DISPLAY_CODE, CALPATTR_DIMGRP_DISPLAY_CODE, CALPATTR_END_DATE, CALPATTR_PERIOD_NUM,'||
  ' VERSION_DISPLAY_CODE'||
  ' {{vs_insert_col}} {{calp_insert_col}} )';

l_calp_insert_cols VARCHAR2(500) :=
  ' ,CAL_PERIOD_END_DATE, CAL_PERIOD_NUMBER, CALENDAR_DISPLAY_CODE, DIMENSION_GROUP_DISPLAY_CODE';

l_shared_vc_insert VARCHAR2(50) := 'DIMENSION_VARCHAR_LABEL';
l_shared_member_col VARCHAR2(50) :=
  ' ,MEMBER_CODE';

l_vs_insert_cols  VARCHAR2(50) :=
  ' ,VALUE_SET_DISPLAY_CODE';

l_select_clause  VARCHAR2(2000) :=
  ' ( SELECT {{vc_select_clause}}'||
  ' B.'|| gv_src_dim_props_rec.MEMBER_DISPLAY_CODE_COL||
  ' ,DA.ATTRIBUTE_VARCHAR_LABEL'||
  ' ,DECODE(DA.ATTRIBUTE_VALUE_COLUMN_NAME'||
  '   ,''DATE_ASSIGN_VALUE'', TO_CHAR(ATTR.DATE_ASSIGN_VALUE, ''{{icx_date_format}}'')'||
  '   ,''NUMBER_ASSIGN_VALUE'', TO_CHAR(ATTR.NUMBER_ASSIGN_VALUE)'||
  '   ,''VARCHAR_ASSIGN_VALUE'', ATTR.VARCHAR_ASSIGN_VALUE'||
  '   ,''DIM_ATTRIBUTE_NUMERIC_MEMBER'', FEM_DIMENSION_UTIL_PKG.Get_Dim_Member_Display_Code@'||p_source_db_link||'('||
  '     DA.ATTRIBUTE_DIMENSION_ID'||
  '     ,TO_CHAR(ATTR.DIM_ATTRIBUTE_NUMERIC_MEMBER)'||
  '     ,ATTR.DIM_ATTRIBUTE_VALUE_SET_ID)'||
  '   ,''DIM_ATTRIBUTE_VARCHAR_MEMBER'', FEM_DIMENSION_UTIL_PKG.Get_Dim_Member_Display_Code@'||p_source_db_link||'('||
  '     DA.ATTRIBUTE_DIMENSION_ID'||
  '     ,ATTR.DIM_ATTRIBUTE_VARCHAR_MEMBER'||
  '     ,ATTR.DIM_ATTRIBUTE_VALUE_SET_ID)'||
  ' ) AS ATTR_ASSIGN_VALUE'||
  ' ,DECODE(DA.ATTRIBUTE_DATA_TYPE_CODE'||
  '   ,''DIMENSION'', DECODE(ATTR.DIM_ATTRIBUTE_VALUE_SET_ID'||
  '     ,NULL,NULL'||
  '     ,FEM_MIR_PKG.Get_Dim_Member_Display_Code@'||p_source_db_link||'('||
  '       ''VALUE_SET'',ATTR.DIM_ATTRIBUTE_VALUE_SET_ID)'||
  '   )'||
  '   ,NULL'||
  ' ) AS ATTR_ASSIGN_VS_DISPLAY_CODE'||
  ' ,DECODE(DA.ATTRIBUTE_DIMENSION_ID, 1, ''UPDATE'', ''LOAD'')'||
  ' ,''Y'''||
  ' ,NULL AS CALPATTR_CAL_DISPLAY_CODE'||
  ' ,NULL AS CALPATTR_DIMGRP_DISPLAY_CODE'||
  ' ,NULL AS CALPATTR_END_DATE'||
  ' ,NULL AS CALP_ATTR_PERIOD_NUM'||
  ' ,AV.VERSION_DISPLAY_CODE'||
  ' {{vs_select_clause}} {{calp_select_clause}}';

l_dim_vc_select VARCHAR2(50) := ''''||p_dim_varchar_lbl||''''||',';

l_calp_select VARCHAR2(500) :=
  ' ,CA2.DATE_ASSIGN_VALUE, CA1.NUMBER_ASSIGN_VALUE, CAL.CALENDAR_DISPLAY_CODE'||
  ' ,DG.DIMENSION_GROUP_DISPLAY_CODE';

l_vs_select_clause VARCHAR2(50) :=
  ' ,VS.VALUE_SET_DISPLAY_CODE';

l_from_clause  VARCHAR2(2000) :=
  ' FROM '|| gv_src_dim_props_rec.MEMBER_B_TABLE_NAME||'@'||p_source_db_link||' B'||
  ' ,'||gv_src_dim_props_rec.ATTRIBUTE_TABLE_NAME||'@'||p_source_db_link||' ATTR'||
  ' ,FEM_DIM_ATTRIBUTES_B@'||p_source_db_link||' DA'||
  ' ,FEM_DIM_ATTR_VERSIONS_B@'||p_source_db_link||' AV'||
  ' {{vs_from_table}} {{calp_from_clause}}';

l_vs_from_table VARCHAR2(100) :=
  ' ,FEM_VALUE_SETS_B@'||p_source_db_link||' VS';

l_calp_from VARCHAR2(1000) :=
  ' ,FEM_DIM_ATTRIBUTES_B@'||p_source_db_link||' DA1'||
  ' ,FEM_DIM_ATTRIBUTES_B@'||p_source_db_link||' DA2'||
  ' ,FEM_DIMENSION_GRPS_B@'||p_source_db_link||' DG'||
  ' ,FEM_CAL_PERIODS_ATTR@'||p_source_db_link||' CA1'||
  ' ,FEM_CAL_PERIODS_ATTR@'||p_source_db_link||' CA2'||
  ' ,FEM_CALENDARS_B@'||p_source_db_link||' CAL';

l_where_clause VARCHAR2(2000) :=
  ' WHERE B.'|| gv_src_dim_props_rec.MEMBER_COL||'= ATTR.'||gv_src_dim_props_rec.MEMBER_COL||
  ' AND DA.ATTRIBUTE_ID = ATTR.ATTRIBUTE_ID'||
  ' AND ATTR.VERSION_ID = AV.VERSION_ID'||
  ' AND DA.DIMENSION_ID = '||gv_src_dim_props_rec.DIMENSION_ID||
  ' AND {{data_slice}}'||
  ' {{default_where_clause}} {{vs_where_clause}} {{calp_where_clause}} )';

l_default_where_clause VARCHAR2(50) :=
  ' AND AV.DEFAULT_VERSION_FLAG = ''Y''';

l_vs_where_clause VARCHAR2(50) :=
  ' AND ATTR.VALUE_SET_ID = VS.VALUE_SET_ID';

l_calp_where VARCHAR2(1000) :=
  ' AND B.CAL_PERIOD_ID = CA1.CAL_PERIOD_ID'||
  ' AND B.CAL_PERIOD_ID = CA2.CAL_PERIOD_ID'||
  ' AND B.CALENDAR_ID = CAL.CALENDAR_ID'||
  ' AND CA1.ATTRIBUTE_ID = DA1.ATTRIBUTE_ID'||
  ' AND CA2.ATTRIBUTE_ID = DA2.ATTRIBUTE_ID'||
  ' AND DA1.ATTRIBUTE_VARCHAR_LABEL = ''GL_PERIOD_NUM'''||
  ' AND DA2.ATTRIBUTE_VARCHAR_LABEL = ''CAL_PERIOD_END_DATE'''||
  ' AND B.DIMENSION_GROUP_ID = DG.DIMENSION_GROUP_ID(+)'||
  ' AND CA1.AW_SNAPSHOT_FLAG = ''N'''||
  ' AND CA2.AW_SNAPSHOT_FLAG = ''N''';

l_insert_sql  VARCHAR2(32767);

l_icx_date_format VARCHAR2(50);

BEGIN

      l_icx_date_format := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');

      l_select_clause := REPLACE(l_select_clause,'{{icx_date_format}}',l_icx_date_format);

      IF (p_dim_varchar_lbl = 'CAL_PERIOD') THEN

        l_insert_cols := REPLACE(l_insert_cols, gv_dim_props_rec.MEMBER_DISPLAY_CODE_COL||', ', '');
        l_insert_cols := REPLACE(l_insert_cols, '{{calp_insert_col}}', l_calp_insert_cols);
        l_select_clause := REPLACE(l_select_clause,'{{calp_select_clause}}',l_calp_select);
        l_select_clause := REPLACE(l_select_clause,'B.'|| gv_src_dim_props_rec.MEMBER_DISPLAY_CODE_COL ||',' , '');
        l_from_clause := REPLACE(l_from_clause,'{{calp_from_clause}}', l_calp_from);
        l_where_clause := REPLACE(l_where_clause,'{{calp_where_clause}}', l_calp_where);
      else
        l_insert_cols := REPLACE(l_insert_cols, '{{calp_insert_col}}','');
        l_select_clause := REPLACE(l_select_clause,'{{calp_select_clause}}','');
        l_from_clause := REPLACE(l_from_clause,'{{calp_from_clause}}', '');
        l_where_clause := REPLACE(l_where_clause,'{{calp_where_clause}}', '');

      END IF;

      IF (gv_dim_props_rec.INTF_ATTRIBUTE_TABLE_NAME = 'FEM_SHARED_ATTR_T') THEN
        l_insert_cols := REPLACE(l_insert_cols, gv_dim_props_rec.MEMBER_DISPLAY_CODE_COL,
                                 l_shared_vc_insert||l_shared_member_col);
        l_select_clause := REPLACE(l_select_clause,'{{vc_select_clause}}',l_dim_vc_select);
      ELSE
        l_select_clause := REPLACE(l_select_clause,'{{vc_select_clause}}','');

      END IF;

      IF (gv_src_dim_props_rec.VALUE_SET_REQUIRED_FLAG = 'Y') THEN
         l_insert_cols := REPLACE(l_insert_cols,'{{vs_insert_col}}',l_vs_insert_cols);
         l_select_clause := REPLACE(l_select_clause,'{{vs_select_clause}}',l_vs_select_clause);
         l_from_clause := REPLACE(l_from_clause,'{{vs_from_table}}', l_vs_from_table);
         l_where_clause := REPLACE(l_where_clause,'{{vs_where_clause}}', l_vs_where_clause);
      ELSE
         l_insert_cols := REPLACE(l_insert_cols,'{{vs_insert_col}}','');
         l_select_clause := REPLACE(l_select_clause,'{{vs_select_clause}}','');
         l_from_clause := REPLACE(l_from_clause,'{{vs_from_table}}', '');
         l_where_clause := REPLACE(l_where_clause,'{{vs_where_clause}}', '');
      END IF;

     IF (p_version_mode = 'DEFAULT') THEN
        l_where_clause := REPLACE(l_where_clause,'{{default_where_clause}}', l_default_where_clause);
     ELSIF (p_version_mode = 'ALL') THEN
        l_where_clause := REPLACE(l_where_clause,'{{default_where_clause}}', '');
     END IF;

l_insert_sql := l_insert_clause||l_insert_cols||l_select_clause||l_from_clause||l_where_clause;


RETURN l_insert_sql;

END;

-----------------------------------------------
-- Build Get Attribute Assignment Value --
-----------------------------------------------

FUNCTION get_attr_assign_value(p_source_db_link IN VARCHAR2,
                               p_dimension_id IN NUMBER,
                               p_value IN VARCHAR2 ) RETURN VARCHAR2

IS

l_table_name  VARCHAR2(30);
l_display_code_col  VARCHAR2(30);
l_member_col   VARCHAR2(30);
l_xdim_table  VARCHAR2(100) := 'FEM_XDIM_DIMENSIONS@'||p_source_db_link;
l_dim_sql VARCHAR2(500) := 'SELECT MEMBER_B_TABLE_NAME,'||
                       ' MEMBER_DISPLAY_CODE_COL,'||
                       ' MEMBER_COL '||
                       ' FROM '||l_xdim_table||
                       ' WHERE DIMENSION_ID = :attr_dimension_id';

l_attr_dc_sql VARCHAR2(2000);
l_display_code_val  VARCHAR2(1000);
l_attr_column_name  VARCHAR2(30);

BEGIN


EXECUTE IMMEDIATE l_dim_sql INTO l_table_name, l_display_code_col, l_member_col USING p_dimension_id;

l_attr_dc_sql := 'SELECT '||l_display_code_col ||
              ' FROM '||l_table_name ||
              ' WHERE '||l_member_col||' = :value';

EXECUTE IMMEDIATE l_attr_dc_sql INTO l_display_code_val USING p_value;

RETURN l_display_code_val;

EXCEPTION

WHEN NO_DATA_FOUND THEN
  RETURN p_value;

END;

-----------------------------------------------
-- Update Cal Period Attribute Assignments --
-----------------------------------------------

PROCEDURE update_calp_attributes(p_source_db_link IN VARCHAR2)

IS

l_attr_assign_value  VARCHAR2(1000);
l_cal_display_code  VARCHAR2(150);
l_dim_grp_display_code VARCHAR2(150);
l_calp_end_date  DATE;
l_calp_period_num NUMBER;

l_calp_intf_attr_sql VARCHAR2(1000) :=
'SELECT ATTRIBUTE_ASSIGN_VALUE '||
' FROM '||gv_dim_props_rec.INTF_ATTRIBUTE_TABLE_NAME||
' WHERE STATUS = ''UPDATE''';

l_select_sql VARCHAR2(2000) :=
'SELECT CAL.CALENDAR_DISPLAY_CODE,'||
' DG.DIMENSION_GROUP_DISPLAY_CODE,'||
' ATTR.NUMBER_ASSIGN_VALUE AS GL_PERIOD_NUM,'||
' ATTR1.DATE_ASSIGN_VALUE AS CAL_PERIOD_END_DATE'||
' FROM   FEM_CALENDARS_B@'||p_source_db_link||' CAL,'||
' FEM_DIMENSION_GRPS_B@'||p_source_db_link||' DG,'||
' FEM_CAL_PERIODS_B@'||p_source_db_link||' CP,'||
' FEM_CAL_PERIODS_ATTR@'||p_source_db_link||' ATTR,'||
' FEM_DIM_ATTRIBUTES_B@'||p_source_db_link||' DA,'||
' FEM_DIM_ATTR_VERSIONS_B@'||p_source_db_link||' AV,'||
' FEM_CAL_PERIODS_ATTR@'||p_source_db_link||' ATTR1,'||
' FEM_DIM_ATTRIBUTES_B@'||p_source_db_link||' DA1,'||
' FEM_DIM_ATTR_VERSIONS_B@'||p_source_db_link||' AV1'||
' WHERE  CP.CAL_PERIOD_ID = :cal_period_id'||
' AND    CP.CALENDAR_ID = CAL.CALENDAR_ID'||
' AND    DG.DIMENSION_GROUP_ID = CP.DIMENSION_GROUP_ID'||
' AND    ATTR.ATTRIBUTE_ID = DA.ATTRIBUTE_ID'||
' AND    ATTR.CAL_PERIOD_ID = CP.CAL_PERIOD_ID'||
' AND    DA.ATTRIBUTE_VARCHAR_LABEL = ''GL_PERIOD_NUM'''||
' AND    ATTR.VERSION_ID = AV.VERSION_ID'||
' AND    AV.DEFAULT_VERSION_FLAG = ''Y'''||
' AND    ATTR1.ATTRIBUTE_ID = DA1.ATTRIBUTE_ID'||
' AND    ATTR1.CAL_PERIOD_ID = CP.CAL_PERIOD_ID'||
' AND    DA1.ATTRIBUTE_VARCHAR_LABEL = ''CAL_PERIOD_END_DATE'''||
' AND    ATTR1.VERSION_ID = AV1.VERSION_ID'||
' AND    AV1.DEFAULT_VERSION_FLAG = ''Y''';

l_update_sql VARCHAR2(1000):= 'UPDATE '||gv_dim_props_rec.INTF_ATTRIBUTE_TABLE_NAME||
                ' SET ATTRIBUTE_ASSIGN_VALUE = NULL,'||
                ' CALPATTR_CAL_DISPLAY_CODE = :cal_display_code,'||
                ' CALPATTR_DIMGRP_DISPLAY_CODE = :dim_grp_display_code,'||
                ' CALPATTR_END_DATE = :calp_end_date,'||
                ' CALPATTR_PERIOD_NUM = :calp_period_num,'||
                ' STATUS = ''LOAD'''||
                ' WHERE ATTRIBUTE_ASSIGN_VALUE = :cal_period_id'||
                ' AND STATUS = ''UPDATE'' AND CREATED_BY_DIM_MIGRATION_FLAG = ''Y''';

TYPE UPDATE_CALP_CURSOR_TYPE IS REF CURSOR;

update_calp_cur UPDATE_CALP_CURSOR_TYPE;

BEGIN

OPEN update_calp_cur FOR l_calp_intf_attr_sql;

LOOP

FETCH update_calp_cur INTO l_attr_assign_value;

EXIT WHEN update_calp_cur%NOTFOUND;

EXECUTE IMMEDIATE l_select_sql
INTO    l_cal_display_code,
        l_dim_grp_display_code,
        l_calp_period_num,
        l_calp_end_date
USING   l_attr_assign_value;


EXECUTE IMMEDIATE l_update_sql
USING   l_cal_display_code,
        l_dim_grp_display_code,
        l_calp_end_date,
        l_calp_period_num,
        l_attr_assign_value;

COMMIT;

END LOOP;

END;



-----------------------------------------------
-- Build Insert _HIER SQL --
-----------------------------------------------
FUNCTION get_dim_hier_sql(p_hier_obj_name IN VARCHAR2,
                          p_hier_obj_def_name IN VARCHAR2,
                          p_hier_obj_def_id IN NUMBER,
                          p_dim_varchar_lbl IN VARCHAR2,
                          p_source_db_link IN VARCHAR2) RETURN VARCHAR2

IS

l_insert_clause VARCHAR2(100) := 'INSERT INTO '|| gv_dim_props_rec.HIERARCHY_INTF_TABLE_NAME;

l_insert_cols  VARCHAR2(500) := '(HIERARCHY_OBJECT_NAME, HIERARCHY_OBJ_DEF_DISPLAY_NAME, DISPLAY_ORDER_NUM, WEIGHTING_PCT, STATUS, LANGUAGE, CREATED_BY_DIM_MIGRATION_FLAG {{dc_insert}} {{vs_insert}} {{calp_insert}})';

l_dc_insert VARCHAR2(100) := ', PARENT_DISPLAY_CODE, CHILD_DISPLAY_CODE';

l_calp_insert VARCHAR2(500) := ', CALENDAR_DISPLAY_CODE, PARENT_DIM_GRP_DISPLAY_CODE, CHILD_DIM_GRP_DISPLAY_CODE, PARENT_CAL_PERIOD_NUMBER, PARENT_CAL_PERIOD_END_DATE, CHILD_CAL_PERIOD_NUMBER, CHILD_CAL_PERIOD_END_DATE';

l_vs_insert VARCHAR2(100) := ', PARENT_VALUE_SET_DISPLAY_CODE, CHILD_VALUE_SET_DISPLAY_CODE';


l_select_clause  VARCHAR2(1500) := '(SELECT '''||p_hier_obj_name||''', '''||p_hier_obj_def_name||''','||
                                   ' HIER.DISPLAY_ORDER_NUM, HIER.WEIGHTING_PCT, ''LOAD'', '''||USERENV('LANG')||''', ''Y'' {{dc_select}} {{vs_select}} {{calp_select}}';


l_dc_select VARCHAR2(100) := ', B1.'||gv_src_dim_props_rec.MEMBER_DISPLAY_CODE_COL||', B2.'||gv_src_dim_props_rec.MEMBER_DISPLAY_CODE_COL;

l_vs_select VARCHAR2(100) := ', VS1.VALUE_SET_DISPLAY_CODE, VS2.VALUE_SET_DISPLAY_CODE';


l_calp_select VARCHAR2(500) := ', CAL.CALENDAR_DISPLAY_CODE, DG1.DIMENSION_GROUP_DISPLAY_CODE, DG2.DIMENSION_GROUP_DISPLAY_CODE, CA1.NUMBER_ASSIGN_VALUE, CA2.DATE_ASSIGN_VALUE, CA3.NUMBER_ASSIGN_VALUE, CA4.DATE_ASSIGN_VALUE';


l_from_clause  VARCHAR2(2000) := ' FROM '|| gv_src_dim_props_rec.HIERARCHY_TABLE_NAME||'@'||p_source_db_link||' HIER {{dc_from}} {{vs_from}} {{calp_from}}';

l_dc_from VARCHAR2(150) := ', '|| gv_src_dim_props_rec.MEMBER_B_TABLE_NAME||'@'||p_source_db_link||'  B1, '||gv_src_dim_props_rec.MEMBER_B_TABLE_NAME||'@'||p_source_db_link||' B2';

l_vs_from VARCHAR2(150) := ', FEM_VALUE_SETS_B@'||p_source_db_link||' VS1, FEM_VALUE_SETS_B@'||p_source_db_link||'  VS2';

l_calp_from VARCHAR2(1000) := ', FEM_CAL_PERIODS_B@'||p_source_db_link||' B1, FEM_CAL_PERIODS_B@'||p_source_db_link||
                                    ' B2, FEM_DIM_ATTRIBUTES_B@'||p_source_db_link||
                                    ' DA1 , FEM_DIM_ATTRIBUTES_B@'||p_source_db_link||' DA2, FEM_DIM_ATTRIBUTES_B@'||
                                    p_source_db_link||' DA3 , FEM_DIM_ATTRIBUTES_B@'||p_source_db_link||' DA4, FEM_DIMENSION_GRPS_B@'||
                                    p_source_db_link||' DG1, FEM_DIMENSION_GRPS_B@'||p_source_db_link||' DG2, '||
                                    'FEM_CAL_PERIODS_ATTR@'||p_source_db_link||' CA1, FEM_CAL_PERIODS_ATTR@'||
                                    p_source_db_link||' CA2, FEM_CAL_PERIODS_ATTR@'||p_source_db_link||' CA3, FEM_CAL_PERIODS_ATTR@'||
                                    p_source_db_link||' CA4, FEM_CALENDARS_B@'||p_source_db_link||' CAL ';

l_where_clause VARCHAR2(1500) := ' WHERE HIER.hierarchy_obj_def_id = '||p_hier_obj_def_id||' AND HIER.single_depth_flag = ''Y'''||' AND {{data_slice}} {{dc_where}} {{vs_where}} {{calp_where}})';

l_vs_where VARCHAR2(100) := ' AND  HIER.PARENT_VALUE_SET_ID = VS1.VALUE_SET_ID AND HIER.CHILD_VALUE_SET_ID = VS2.VALUE_SET_ID';

l_dc_where VARCHAR2(200) := ' AND  HIER.PARENT_ID = B1.'||gv_src_dim_props_rec.MEMBER_COL||' AND HIER.CHILD_ID = B2.'||gv_src_dim_props_rec.MEMBER_COL;

l_calp_where VARCHAR2(1000) := ' AND HIER.PARENT_ID = B1.CAL_PERIOD_ID'||
' AND HIER.CHILD_ID = B2.CAL_PERIOD_ID'||
' AND B1.CAL_PERIOD_ID = CA1.CAL_PERIOD_ID'||
' AND B1.CAL_PERIOD_ID = CA2.CAL_PERIOD_ID'||
' AND B2.CAL_PERIOD_ID = CA3.CAL_PERIOD_ID'||
' AND B2.CAL_PERIOD_ID = CA4.CAL_PERIOD_ID'||
' AND B1.CALENDAR_ID = CAL.CALENDAR_ID'||
' AND B2.CALENDAR_ID = CAL.CALENDAR_ID'||
' AND CA1.ATTRIBUTE_ID = DA1.ATTRIBUTE_ID'||
' AND CA2.ATTRIBUTE_ID = DA2.ATTRIBUTE_ID'||
' AND CA3.ATTRIBUTE_ID = DA3.ATTRIBUTE_ID'||
' AND CA4.ATTRIBUTE_ID = DA4.ATTRIBUTE_ID'||
' AND DA1.ATTRIBUTE_VARCHAR_LABEL = ''GL_PERIOD_NUM'''||
' AND DA2.ATTRIBUTE_VARCHAR_LABEL = ''CAL_PERIOD_END_DATE'''||
' AND DA3.ATTRIBUTE_VARCHAR_LABEL = ''GL_PERIOD_NUM'''||
' AND DA4.ATTRIBUTE_VARCHAR_LABEL = ''CAL_PERIOD_END_DATE'''||
' AND B1.DIMENSION_GROUP_ID = DG1.DIMENSION_GROUP_ID(+)'||
' AND B2.DIMENSION_GROUP_ID = DG2.DIMENSION_GROUP_ID(+)'||
' AND CA1.AW_SNAPSHOT_FLAG = ''N'''||
' AND CA2.AW_SNAPSHOT_FLAG = ''N'''||
' AND CA3.AW_SNAPSHOT_FLAG = ''N'''||
' AND CA4.AW_SNAPSHOT_FLAG = ''N''';

l_insert_sql  VARCHAR2(32767);

BEGIN

IF p_dim_varchar_lbl <> 'CAL_PERIOD' THEN
l_insert_cols := REPLACE(l_insert_cols, '{{dc_insert}}', l_dc_insert);
l_insert_cols := REPLACE(l_insert_cols, '{{calp_insert}}', '');

l_select_clause:= REPLACE(l_select_clause, '{{dc_select}}', l_dc_select);
l_select_clause:= REPLACE(l_select_clause, '{{calp_select}}', '');

l_from_clause:= REPLACE(l_from_clause, '{{dc_from}}', l_dc_from);
l_from_clause:= REPLACE(l_from_clause, '{{calp_from}}', '');

l_where_clause:= REPLACE(l_where_clause, '{{dc_where}}', l_dc_where);
l_where_clause:= REPLACE(l_where_clause, '{{calp_where}}', '');

ELSE
l_insert_cols := REPLACE(l_insert_cols, '{{calp_insert}}', l_calp_insert);
l_insert_cols := REPLACE(l_insert_cols, '{{dc_insert}}', '');
l_select_clause:= REPLACE(l_select_clause, '{{calp_select}}', l_calp_select);
l_select_clause:= REPLACE(l_select_clause, '{{dc_select}}', '');

l_from_clause:= REPLACE(l_from_clause, '{{calp_from}}', l_calp_from);
l_from_clause:= REPLACE(l_from_clause, '{{dc_from}}', '');

l_where_clause:= REPLACE(l_where_clause, '{{calp_where}}', l_calp_where);
l_where_clause:= REPLACE(l_where_clause, '{{dc_where}}', '');


END IF;

IF (gv_dim_props_rec.VALUE_SET_REQUIRED_FLAG = 'Y') THEN

l_insert_cols := REPLACE(l_insert_cols, '{{vs_insert}}', l_vs_insert);
l_select_clause:= REPLACE(l_select_clause, '{{vs_select}}', l_vs_select);
l_from_clause:= REPLACE(l_from_clause, '{{vs_from}}', l_vs_from);
l_where_clause:= REPLACE(l_where_clause, '{{vs_where}}', l_vs_where);

ELSE
l_insert_cols := REPLACE(l_insert_cols, '{{vs_insert}}', '');
l_select_clause:= REPLACE(l_select_clause, '{{vs_select}}', '');
l_from_clause:= REPLACE(l_from_clause, '{{vs_from}}','');
l_where_clause:= REPLACE(l_where_clause, '{{vs_where}}', '');

END IF;


l_insert_sql := l_insert_clause||l_insert_cols||l_select_clause||l_from_clause||l_where_clause;


RETURN l_insert_sql;

END;





-----------------------------------------------
-- Build Insert Hier Rule SQL --
-----------------------------------------------
FUNCTION get_dim_hier_rule_sql(p_dim_varchar_lbl IN VARCHAR2,
                               p_folder_name IN VARCHAR2,
                               p_hier_obj_name IN VARCHAR2,
                               p_hier_obj_def_name IN VARCHAR2,
                               p_source_db_link IN VARCHAR2,
                               p_eff_start_date IN DATE,
                               p_eff_end_date IN DATE) RETURN VARCHAR2

IS

l_eff_start_date_str VARCHAR2(100) := 'NULL';
l_eff_end_date_str VARCHAR2(100) := 'NULL';

l_insert_clause VARCHAR2(100) := 'INSERT INTO FEM_HIERARCHIES_T';


l_select_clause  VARCHAR2(1500);

l_from_clause  VARCHAR2(500) := ' FROM FEM_HIERARCHIES@'||p_source_db_link;

l_where_clause VARCHAR2(1500) := ' WHERE HIERARCHY_OBJ_ID = :hier_obj_id)';

l_insert_sql  VARCHAR2(32767);

l_eff_start_date VARCHAR2(50);
l_eff_end_date VARCHAR2(50);

l_folder_name  VARCHAR2(200);

BEGIN


IF (p_eff_start_date IS NOT NULL) THEN
  l_eff_start_date := FND_DATE.date_to_canonical(p_eff_start_date);

  l_eff_start_date_str := 'TO_DATE('||''''||l_eff_start_date||''''||','||'''YYYY/MM/DD HH24:MI:SS'''||')';

END IF;


IF (p_eff_end_date IS NOT NULL) THEN
  l_eff_end_date := FND_DATE.date_to_canonical(p_eff_end_date);

  l_eff_end_date_str := 'TO_DATE('||''''||l_eff_end_date||''''||','||'''YYYY/MM/DD HH24:MI:SS'''||')';
END IF;

l_folder_name := REPLACE(p_folder_name, '''', '''''');

l_select_clause := '(SELECT '''||p_hier_obj_name||''', '''||l_folder_name||''','||
                                   ''''||USERENV('LANG')||''', '''||p_dim_varchar_lbl||''','||
                                   ' HIERARCHY_TYPE_CODE, GROUP_SEQUENCE_ENFORCED_CODE, MULTI_TOP_FLAG, MULTI_VALUE_SET_FLAG,'||
                                   ' HIERARCHY_USAGE_CODE, FLATTENED_ROWS_FLAG, ''LOAD'', '''||p_hier_obj_def_name||''','||
                                   l_eff_start_date_str||', '||l_eff_end_date_str||', NULL, ''Y''';

l_insert_sql := l_insert_clause||l_select_clause||l_from_clause||l_where_clause;

RETURN l_insert_sql;

END;


-----------------------------------------------
-- Build Insert Hier Valuesets SQL --
-----------------------------------------------
FUNCTION get_hier_vs_sql(p_hier_obj_name IN VARCHAR2, p_source_db_link IN VARCHAR2) RETURN VARCHAR2

IS

l_insert_clause VARCHAR2(100) := 'INSERT INTO FEM_HIER_VALUE_SETS_T';

l_insert_select VARCHAR2(1500) := '(SELECT '''||p_hier_obj_name||''', VS.VALUE_SET_DISPLAY_CODE, '''||USERENV('LANG')||''', ''LOAD'', ''Y''';


l_insert_from   VARCHAR2(200) := ' FROM FEM_HIER_VALUE_SETS@'||p_source_db_link||
                                 ' HVS, FEM_VALUE_SETS_B@'||p_source_db_link||' VS';
l_insert_where  VARCHAR2(500) := ' WHERE HVS.HIERARCHY_OBJ_ID = :hier_obj_id'||
                                 ' AND HVS.VALUE_SET_ID = VS.VALUE_SET_ID)';

l_insert_sql VARCHAR2(32767) := l_insert_clause || l_insert_select || l_insert_from || l_insert_where;

BEGIN
RETURN l_insert_sql;
END;


-----------------------------------------------
-- Build Insert Hier Dimension Group SQL --
-----------------------------------------------
FUNCTION get_hier_dg_sql(p_hier_obj_name IN VARCHAR2, p_source_db_link IN VARCHAR2) RETURN VARCHAR2

IS

l_insert_clause VARCHAR2(100) := 'INSERT INTO FEM_HIER_DIM_GRPS_T';

l_insert_select VARCHAR2(1500) := '(SELECT '''||p_hier_obj_name||''', '''||USERENV('LANG')||''', ''LOAD'', DG.DIMENSION_GROUP_DISPLAY_CODE, ''Y''';


l_insert_from   VARCHAR2(200) := ' FROM FEM_HIER_DIMENSION_GRPS@'||p_source_db_link||
                                 ' HDG, FEM_DIMENSION_GRPS_B@'||p_source_db_link||' DG';
l_insert_where  VARCHAR2(500) := ' WHERE HDG.HIERARCHY_OBJ_ID = :hier_obj_id'||
                                 ' AND HDG.DIMENSION_GROUP_ID = DG.DIMENSION_GROUP_ID)';

l_insert_sql VARCHAR2(32767) := l_insert_clause || l_insert_select || l_insert_from || l_insert_where;

BEGIN
RETURN l_insert_sql;
END;

-----------------------------------------------
-- Build Insert Dimension Groups _B SQL --
-----------------------------------------------
FUNCTION get_insert_dim_grp_b_sql(p_source_db_link IN VARCHAR2) RETURN VARCHAR2

IS

l_insert_clause VARCHAR2(100) := 'INSERT INTO FEM_DIMENSION_GRPS_B_T';
l_insert_select VARCHAR2(200) := ' (SELECT B.DIMENSION_GROUP_DISPLAY_CODE, D.DIMENSION_VARCHAR_LABEL,'||
                                 'B.DIMENSION_GROUP_SEQ, ''LOAD'', B.TIME_GROUP_TYPE_CODE, ''Y''';

l_insert_from   VARCHAR2(200) := ' FROM FEM_DIMENSION_GRPS_B@'||p_source_db_link||
                                 ' B, FEM_DIMENSIONS_B@'||p_source_db_link||' D';
l_insert_where  VARCHAR2(500) := ' WHERE B.DIMENSION_ID = D.DIMENSION_ID'||
                                 ' AND D.DIMENSION_ID = :dimension_id'||
                                 ' AND NOT EXISTS (SELECT 1 FROM FEM_DIMENSION_GRPS_B_T'||
                                 ' WHERE DIMENSION_GROUP_DISPLAY_CODE = B.DIMENSION_GROUP_DISPLAY_CODE'||
                                 ' AND DIMENSION_VARCHAR_LABEL = D.DIMENSION_VARCHAR_LABEL'||
                                 ' AND DIMENSION_GROUP_SEQ = B.DIMENSION_GROUP_SEQ))';

l_insert_sql VARCHAR2(32767) := l_insert_clause || l_insert_select || l_insert_from || l_insert_where;

BEGIN
RETURN l_insert_sql;
END;




-----------------------------------------------
-- Build Insert Dimension Groups _TL SQL --
-----------------------------------------------
FUNCTION get_insert_dim_grp_tl_sql(p_source_db_link IN VARCHAR2) RETURN VARCHAR2

IS

l_insert_clause VARCHAR2(100) := 'INSERT INTO FEM_DIMENSION_GRPS_TL_T';
l_insert_select VARCHAR2(200) := ' (SELECT B.DIMENSION_GROUP_DISPLAY_CODE, TL.LANGUAGE,'||
                                 ' TL.DIMENSION_GROUP_NAME, TL.DESCRIPTION, ''LOAD'','||
                                 ' D.DIMENSION_VARCHAR_LABEL, ''Y''';

l_insert_from   VARCHAR2(200) := ' FROM FEM_DIMENSION_GRPS_B@'||p_source_db_link||
                                 ' B, FEM_DIMENSION_GRPS_TL@'||p_source_db_link||
                                 ' TL, FEM_DIMENSIONS_B@'||p_source_db_link||' D';
l_insert_where  VARCHAR2(1000) := ' WHERE B.DIMENSION_GROUP_ID = TL.DIMENSION_GROUP_ID'||
                                 ' AND B.DIMENSION_ID = D.DIMENSION_ID'||
                                -- ' AND B.DIMENSION_ID = TL.DIMENSION_ID'||
                                 ' AND TL.DIMENSION_ID = :dimension_id'||
                                 ' AND EXISTS (SELECT 1 FROM FND_LANGUAGES L'||
                                 ' WHERE TL.LANGUAGE = L.LANGUAGE_CODE AND L.INSTALLED_FLAG IN (''I'',''B''))'||
                                 ' AND NOT EXISTS (SELECT 1 FROM FEM_DIMENSION_GRPS_TL_T'||
                                 ' WHERE DIMENSION_GROUP_DISPLAY_CODE = B.DIMENSION_GROUP_DISPLAY_CODE'||
                                 ' AND DIMENSION_VARCHAR_LABEL = D.DIMENSION_VARCHAR_LABEL'||
                                 ' AND LANGUAGE = TL.LANGUAGE'||
                                 ' AND DIMENSION_GROUP_NAME = TL.DIMENSION_GROUP_NAME))';

l_insert_sql VARCHAR2(32767) := l_insert_clause || l_insert_select || l_insert_from || l_insert_where;

BEGIN

RETURN l_insert_sql;

END;




------------------------------------------------------------------------------
-- Insert Value Sets --
-- 7/25/2006 Bug#5331497 default_member_id, default_load_member_id and
--                       default_hierarchy_obj_id should be null when value_set
--                       is created, since these values all come from sequence
--                       that is not identical between source and target db
-------------------------------------------------------------------------------

PROCEDURE insert_value_sets(p_source_db_link IN VARCHAR2)

IS

l_row_id  rowid_type; --ROWID;
l_default_member_id  number_type; --FEM_VALUE_SETS_B.DEFAULT_MEMBER_ID%TYPE;
l_vs_dc  varchar2_150_type; --FEM_VALUE_SETS_B.VALUE_SET_DISPLAY_CODE%TYPE;
l_default_hier_obj_id  number_type; --FEM_VALUE_SETS_B.DEFAULT_HIERARCHY_OBJ_ID%TYPE;
l_read_only_flag  flag_type; --FEM_VALUE_SETS_B.READ_ONLY_FLAG%TYPE;
l_vs_id  number_type; --FEM_VALUE_SETS_B.VALUE_SET_ID%TYPE;
l_vs_name varchar2_150_type; --FEM_VALUE_SETS_TL.VALUE_SET_NAME%TYPE;
l_vs_desc desc_type; --FEM_VALUE_SETS_TL.DESCRIPTION%TYPE;
l_mbr_last_row NUMBER;
l_dup_vs_name VARCHAR2(150);

l_vs_sql VARCHAR2(1000) :=
'SELECT ROW_ID, FEM_VALUE_SETS_B_S.NEXTVAL,'||
'       VALUE_SET_NAME, DESCRIPTION, null,'||
'       VALUE_SET_DISPLAY_CODE,'||
'       null,'||
'       READ_ONLY_FLAG'||
' FROM   FEM_VALUE_SETS_VL@'||p_source_db_link||' A'||
' WHERE  A.DIMENSION_ID = '||gv_src_dim_props_rec.DIMENSION_ID||
' AND    NOT EXISTS (SELECT 1'||
'                  FROM FEM_VALUE_SETS_VL'||
'                  WHERE VALUE_SET_DISPLAY_CODE = A.VALUE_SET_DISPLAY_CODE)';

TYPE INSERT_VS_CURSOR_TYPE IS REF CURSOR;

insert_vs_cur INSERT_VS_CURSOR_TYPE;

BEGIN

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => c_block||'.l_vs_sql',
  p_msg_text => l_vs_sql);

OPEN insert_vs_cur FOR l_vs_sql;

loop

FETCH insert_vs_cur BULK COLLECT INTO
l_row_id,
l_vs_id,
l_vs_name,
l_vs_desc,
l_default_member_id,
l_vs_dc,
l_default_hier_obj_id,
l_read_only_flag
LIMIT 10000;

      l_mbr_last_row := l_vs_id.LAST;

      IF (l_mbr_last_row IS NULL)
      THEN
         EXIT;
      END IF;

     FOR i IN 1..l_mbr_last_row
      LOOP


BEGIN

SELECT VALUE_SET_NAME
INTO l_dup_vs_name
FROM FEM_VALUE_SETS_VL
WHERE VALUE_SET_NAME = l_vs_name(i);

    IF (SQL%FOUND) THEN
      FEM_ENGINES_PKG.TECH_MESSAGE
      (p_severity => c_log_level_2,
       p_module => c_block||'.insert_value_sets',
       p_msg_text => 'Duplicate vs name found in db '|| l_dup_vs_name);
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --VS IS GOOD--
      NULL;
  END;

FEM_VALUE_SETS_PKG.INSERT_ROW(X_ROWID => l_row_id(i),
                              X_VALUE_SET_ID => l_vs_id(i),
                              X_DEFAULT_LOAD_MEMBER_ID => null,
                              X_DEFAULT_MEMBER_ID => null,
                              X_OBJECT_VERSION_NUMBER => 1,
                              X_DEFAULT_HIERARCHY_OBJ_ID => null,
                              X_READ_ONLY_FLAG => l_read_only_flag(i),
                              X_VALUE_SET_DISPLAY_CODE => l_vs_dc(i),
                              X_DIMENSION_ID => gv_src_dim_props_rec.DIMENSION_ID,
                              X_VALUE_SET_NAME => l_vs_name(i),
                              X_DESCRIPTION => l_vs_desc(i),
                              X_CREATION_DATE => sysdate,
                              X_CREATED_BY => gv_apps_user_id,
                              X_LAST_UPDATE_DATE => sysdate,
                              X_LAST_UPDATED_BY => gv_apps_user_id,
                              X_LAST_UPDATE_LOGIN => gv_login_id);

 END LOOP;
end loop;

END;





-----------------------------------------------
-- Insert Calendars --
-----------------------------------------------

PROCEDURE insert_calendars(p_source_db_link IN VARCHAR2)

IS

l_row_id  rowid_type;
l_cal_dc  varchar2_150_type;
l_read_only_flag  flag_type;
l_personal_flag  flag_type;
l_enabled_flag  flag_type;
l_cal_id  number_type; --FEM_VALUE_SETS_B.VALUE_SET_ID%TYPE;
l_cal_name varchar2_150_type; --FEM_VALUE_SETS_TL.VALUE_SET_NAME%TYPE;
l_cal_desc desc_type; --FEM_VALUE_SETS_TL.DESCRIPTION%TYPE;
l_mbr_last_row NUMBER;
l_dup_cal_name VARCHAR2(150);

l_cal_sql VARCHAR2(1000) :=
'SELECT ROW_ID, FEM_CALENDARS_B_S.NEXTVAL,'||
'       CALENDAR_NAME, DESCRIPTION, ENABLED_FLAG,'||
'       CALENDAR_DISPLAY_CODE,'||
'       PERSONAL_FLAG,'||
'       READ_ONLY_FLAG'||
' FROM   FEM_CALENDARS_VL@'||p_source_db_link||' A'||
' WHERE  NOT EXISTS (SELECT 1'||
'                  FROM FEM_CALENDARS_VL'||
'                  WHERE CALENDAR_DISPLAY_CODE = A.CALENDAR_DISPLAY_CODE)';

TYPE INSERT_CAL_CURSOR_TYPE IS REF CURSOR;

insert_cal_cur INSERT_CAL_CURSOR_TYPE;

BEGIN

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => c_block||'.l_cal_sql',
  p_msg_text => l_cal_sql);

OPEN insert_cal_cur FOR l_cal_sql;

loop

FETCH insert_cal_cur BULK COLLECT INTO
l_row_id,
l_cal_id,
l_cal_name,
l_cal_desc,
l_enabled_flag,
l_cal_dc,
l_personal_flag,
l_read_only_flag
LIMIT 10000;

      l_mbr_last_row := l_cal_id.LAST;

      IF (l_mbr_last_row IS NULL)
      THEN
         EXIT;
      END IF;

     FOR i IN 1..l_mbr_last_row
      LOOP

BEGIN

SELECT CALENDAR_NAME
INTO l_dup_cal_name
FROM FEM_CALENDARS_VL
WHERE CALENDAR_NAME = l_cal_name(i);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN

      --CALENDAR CAN BE INSERTED--

FEM_CALENDARS_PKG.INSERT_ROW (
  X_ROWID  => l_row_id(i),
  X_CALENDAR_ID => l_cal_id(i),
  X_READ_ONLY_FLAG => l_read_only_flag(i),
  X_PERSONAL_FLAG => l_personal_flag(i),
  X_ENABLED_FLAG => l_enabled_flag(i),
  X_CALENDAR_DISPLAY_CODE => l_cal_dc(i),
  X_OBJECT_VERSION_NUMBER => 1,
  X_CALENDAR_NAME => l_cal_name(i),
  X_DESCRIPTION => l_cal_desc(i),
  X_CREATION_DATE => sysdate,
  X_CREATED_BY => gv_apps_user_id,
  X_LAST_UPDATE_DATE => sysdate,
  X_LAST_UPDATED_BY => gv_apps_user_id,
  X_LAST_UPDATE_LOGIN => gv_login_id);
  END;

 END LOOP;
end loop;

END;

-----------------------------------------------
-- Process Execution --
-----------------------------------------------
PROCEDURE register_process_execution (p_object_id IN NUMBER
                                     ,p_obj_def_id IN NUMBER
                                     ,p_execution_mode IN VARCHAR2)
IS

      v_API_return_status  VARCHAR2(30);
      v_exec_state       VARCHAR2(30); -- NORMAL, RESTART, RERUN
      v_num_msg          NUMBER;
      v_stmt_type        fem_pl_tables.statement_type%TYPE;
      i                  PLS_INTEGER;
      v_msg_count        NUMBER;
      v_msg_data         VARCHAR2(4000);
      v_previous_request_id NUMBER;
      v_exec_lock_exists  VARCHAR2(5);
      v_calling_context VARCHAR2(15);


      Exec_Lock_Exists   EXCEPTION;
      e_pl_register_req_failed  EXCEPTION;
      e_exec_lock_failed  EXCEPTION;


   BEGIN
      --x_completion_status := 'SUCCESS';

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => c_log_level_2,
         p_module   => c_block||'.'||'Register_process_execution',
         p_msg_text => 'BEGIN');

   -- Call the FEM_PL_PKG.Register_Request API procedure to register
   -- the concurrent request in FEM_PL_REQUESTS.

      FEM_PL_PKG.Register_Request
        (P_API_VERSION            => c_api_version,
         P_COMMIT                 => c_false,
         P_CAL_PERIOD_ID          => null,
         P_LEDGER_ID              => null,
         P_DATASET_IO_OBJ_DEF_ID  => null,
         P_OUTPUT_DATASET_CODE    => null,
         P_SOURCE_SYSTEM_CODE     => null,
         P_EFFECTIVE_DATE         => null,
         P_RULE_SET_OBJ_DEF_ID    => null,
         P_RULE_SET_NAME          => null,
         P_REQUEST_ID             => gv_request_id,
         P_USER_ID                => gv_apps_user_id,
         P_LAST_UPDATE_LOGIN      => gv_login_id,
         P_PROGRAM_ID             => gv_pgm_id,
         P_PROGRAM_LOGIN_ID       => gv_login_id,
         P_PROGRAM_APPLICATION_ID => gv_pgm_app_id,
         P_EXEC_MODE_CODE         => p_execution_mode,
         P_DIMENSION_ID           => null,
         P_TABLE_NAME             => null,
         P_HIERARCHY_NAME         => null,
         X_MSG_COUNT              => v_msg_count,
         X_MSG_DATA               => v_msg_data,
         X_RETURN_STATUS          => v_API_return_status);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => c_log_level_1,
            p_module   => c_block||'.'||'Register_request.v_api_return_status',
            p_msg_text => v_API_return_status);

      IF v_API_return_status NOT IN  ('S') THEN
         RAISE e_pl_register_req_failed;
      END IF;
   -- Check for process locks and process overlaps and register
   -- the execution in FEM_PL_OBJECT_EXECUTIONS, obtaining an execution lock.


      FEM_PL_PKG.obj_execution_lock_exists
        (p_object_id => p_object_id,
         p_exec_object_definition_id => p_obj_def_id,
         p_calling_context => v_calling_context,
         x_exec_lock_exists => v_exec_lock_exists,
         x_exec_state => v_exec_state,
         X_prev_request_id =>  v_previous_request_id,
         x_msg_count => v_msg_count,
         x_msg_data => v_msg_data);


      FEM_PL_PKG.Register_Object_Execution
        (P_API_VERSION               => c_api_version,
         P_COMMIT                    => c_false,
         P_REQUEST_ID                => gv_request_id,
         P_OBJECT_ID                 => p_object_id,
         P_EXEC_OBJECT_DEFINITION_ID => p_obj_def_id,
         P_USER_ID                   => gv_apps_user_id,
         P_LAST_UPDATE_LOGIN         => gv_login_id,
         P_EXEC_MODE_CODE            => p_execution_mode,
         X_EXEC_STATE                => v_exec_state,
         X_PREV_REQUEST_ID           => v_previous_request_id,
         X_MSG_COUNT                 => v_msg_count,
         X_MSG_DATA                  => v_msg_data,
         X_RETURN_STATUS             => v_API_return_status);

      IF v_API_return_status NOT IN  ('S') THEN
      -- Lock exists or API call failed
         RAISE e_exec_lock_failed;
      END IF;

      FEM_PL_PKG.Register_Object_Def
        (P_API_VERSION               => c_api_version,
         P_COMMIT                    => c_false,
         P_REQUEST_ID                => gv_request_id,
         P_OBJECT_ID                 => p_object_id,
         P_OBJECT_DEFINITION_ID      => p_obj_def_id,
         P_USER_ID                   => gv_apps_user_id,
         P_LAST_UPDATE_LOGIN         => gv_login_id,
         X_MSG_COUNT                 => v_msg_count,
         X_MSG_DATA                  => v_msg_data,
         X_RETURN_STATUS             => v_API_return_status);

      IF v_API_return_status NOT IN  ('S') THEN
      -- Lock exists or API call failed
         RAISE e_exec_lock_failed;
      END IF;

   -- Successful completion

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => c_log_level_1,
         p_module   => c_block||'.'||'Register_process_execution',
         p_msg_text => 'END');

      COMMIT;

   EXCEPTION
      WHEN e_pl_register_req_failed THEN
         -- get errors from the stack
         Get_Put_Messages (
            p_msg_count => v_msg_count,
            p_msg_data => v_msg_data);

         -- display user message
         FEM_ENGINES_PKG.USER_MESSAGE
         (P_APP_NAME => c_fem
         ,P_MSG_NAME => G_PL_REG_REQUEST_ERR);

      FEM_ENGINES_PKG.USER_MESSAGE
       (P_APP_NAME => c_fem
       ,P_MSG_NAME => G_PL_MIGRATION_ERROR);

         --x_completion_status := 'ERROR';

         RAISE e_pl_registration_failed;

      WHEN e_exec_lock_failed THEN
         -- get errors from the stack
            Get_Put_Messages (
               p_msg_count => v_msg_count,
               p_msg_data => v_msg_data);

         FEM_ENGINES_PKG.USER_MESSAGE
         (P_APP_NAME => c_fem
         ,P_MSG_NAME => G_PL_OBJ_EXEC_LOCK_ERR);


         FEM_ENGINES_PKG.Tech_Message
           (p_severity => c_log_level_1,
            p_module   => c_block||'.'||'Register_process_execution',
            p_msg_text => 'raising Exec_Lock_failed');

         FEM_PL_PKG.Unregister_Request(
            P_API_VERSION               => c_api_version,
            P_COMMIT                    => c_true,
            P_REQUEST_ID                => gv_request_id,
            X_MSG_COUNT                 => v_msg_count,
            X_MSG_DATA                  => v_msg_data,
            X_RETURN_STATUS             => v_API_return_status);
      -- Technical messages have already been logged by the API;

         --x_completion_status := 'ERROR';

         RAISE e_pl_registration_failed;

   END Register_Process_Execution;

-----------------------------------------------
-- Pre-Process Members --
-----------------------------------------------
PROCEDURE PRE_PROCESS_MEMBERS(p_source_db_link             IN   VARCHAR2,
                              p_dim_varchar_lbl            IN   VARCHAR2,
                              p_autoload_dims              IN   VARCHAR2,
                              p_migrate_dependent_dims     IN   VARCHAR2,
                              p_version_mode               IN   VARCHAR2,
                              p_version_disp_cd            IN   VARCHAR2,
                              p_version_name               IN   VARCHAR2,
                              p_source_user_dim_name       IN   VARCHAR2,
                              p_hier_obj_name              IN   VARCHAR2,
                              p_hier_obj_def_name          IN   VARCHAR2)

IS

c_proc_name VARCHAR2(30):= 'pre_process_members';

l_verify_db_link      VARCHAR2(10);
l_error_code          VARCHAR2(10);
l_return_code         VARCHAR2(10);
l_pl_exec_status      VARCHAR2(30);
l_dim_obj_id          NUMBER;
l_delete_b_sql        VARCHAR2(200);
l_delete_tl_sql       VARCHAR2(200);
l_delete_attr_sql     VARCHAR2(200);
l_delete_dg_b_sql     VARCHAR2(200);
l_delete_dg_tl_sql    VARCHAR2(200);

BEGIN

l_verify_db_link := validate_db_link(p_source_db_link);

--TO DO:  CHECK LANGUAGE SETTINGS -- TGT SESSION LANG MUST BE INSTALLED IN SRC')--

validate_parameters(p_source_db_link => p_source_db_link,
                    p_autoload_dims => p_autoload_dims,
                    p_migrate_dependent_dims => p_migrate_dependent_dims,
                    p_version_mode => p_version_mode,
                    p_version_disp_cd => p_version_disp_cd,
                    p_version_name => p_version_name,
                    p_source_user_dim_name => p_source_user_dim_name,
                    p_hier_obj_name => p_hier_obj_name,
                    p_hier_obj_def_name => p_hier_obj_def_name);



get_dimension_info(p_dim_varchar_lbl,
                   p_source_user_dim_name,
                   p_source_db_link);


register_process_execution(p_object_id => gv_dim_props_rec.MIGRATION_OBJ_ID,
                           p_obj_def_id => gv_dim_props_rec.MIGRATION_OBJ_DEF_ID,
                           p_execution_mode => 'S');


--delete existing data (move to procedure)
l_delete_b_sql := 'DELETE FROM '||gv_dim_props_rec.INTF_MEMBER_B_TABLE_NAME||
                  ' WHERE CREATED_BY_DIM_MIGRATION_FLAG = ''Y''';

l_delete_tl_sql := 'DELETE FROM '||gv_dim_props_rec.INTF_MEMBER_TL_TABLE_NAME||
                   ' WHERE CREATED_BY_DIM_MIGRATION_FLAG = ''Y''';

l_delete_attr_sql := 'DELETE FROM '||gv_dim_props_rec.INTF_ATTRIBUTE_TABLE_NAME||
                     ' WHERE CREATED_BY_DIM_MIGRATION_FLAG = ''Y''';

l_delete_dg_b_sql := 'DELETE FROM FEM_DIMENSION_GRPS_B_T'||
                     ' WHERE DIMENSION_VARCHAR_LABEL = :dim_varchar_lbl AND CREATED_BY_DIM_MIGRATION_FLAG = ''Y''';

l_delete_dg_tl_sql := 'DELETE FROM FEM_DIMENSION_GRPS_TL_T'||
                     ' WHERE DIMENSION_VARCHAR_LABEL = :dim_varchar_lbl AND CREATED_BY_DIM_MIGRATION_FLAG = ''Y''';

IF (gv_dim_props_rec.INTF_MEMBER_B_TABLE_NAME IS NOT NULL) THEN

  FEM_ENGINES_PKG.TECH_MESSAGE
   (p_severity => c_log_level_2,
    p_module => c_block||'.l_delete_b_sql',
    p_msg_text => l_delete_b_sql);

  EXECUTE IMMEDIATE l_delete_b_sql;
END IF;

IF (gv_dim_props_rec.INTF_MEMBER_TL_TABLE_NAME IS NOT NULL) THEN

  FEM_ENGINES_PKG.TECH_MESSAGE
   (p_severity => c_log_level_2,
    p_module => c_block||'.l_delete_tl_sql',
    p_msg_text => l_delete_tl_sql);

  EXECUTE IMMEDIATE l_delete_tl_sql;
END IF;

IF (gv_dim_props_rec.INTF_ATTRIBUTE_TABLE_NAME IS NOT NULL) THEN

  FEM_ENGINES_PKG.TECH_MESSAGE
   (p_severity => c_log_level_2,
    p_module => c_block||'.l_delete_attr_sql',
    p_msg_text => l_delete_attr_sql);

  EXECUTE IMMEDIATE l_delete_attr_sql;
END IF;


  FEM_ENGINES_PKG.TECH_MESSAGE
   (p_severity => c_log_level_2,
    p_module => c_block||'.l_delete_dg_b_sql',
    p_msg_text => l_delete_dg_b_sql);

EXECUTE IMMEDIATE l_delete_dg_b_sql USING p_dim_varchar_lbl;


  FEM_ENGINES_PKG.TECH_MESSAGE
   (p_severity => c_log_level_2,
    p_module => c_block||'.l_delete_dg_tl_sql',
    p_msg_text => l_delete_dg_tl_sql);

EXECUTE IMMEDIATE l_delete_dg_tl_sql USING p_dim_varchar_lbl;

COMMIT;


EXCEPTION

WHEN e_dimension_not_supported THEN
         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_DIM_NOT_SUPPORTED
          ,P_TOKEN1 => 'DIM_NAME'
          ,P_VALUE1 => p_dim_varchar_lbl);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_DIM_NOT_SUPPORTED
          ,P_TOKEN1 => 'DIM_NAME'
          ,P_VALUE1 => p_dim_varchar_lbl);

         RAISE e_main_terminate;

WHEN e_invalid_dimension THEN
         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_INVALID_DIMENSION
          ,P_TOKEN1 => 'DIM_LBL'
          ,P_VALUE1 => p_dim_varchar_lbl);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_INVALID_DIMENSION
          ,P_TOKEN1 => 'DIM_LBL'
          ,P_VALUE1 => p_dim_varchar_lbl);

         RAISE e_main_terminate;

WHEN e_db_link_not_registered THEN
         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_DB_LINK_NOT_REGISTERED
          ,P_TOKEN1 => 'DB_LINK'
          ,P_VALUE1 => p_source_db_link);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_DB_LINK_NOT_REGISTERED
          ,P_TOKEN1 => 'DB_LINK'
          ,P_VALUE1 => p_source_db_link);

         RAISE e_main_terminate;

WHEN e_db_link_not_functional THEN
         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_DB_LINK_NOT_FUNCTIONAL
          ,P_TOKEN1 => 'DB_LINK'
          ,P_VALUE1 => p_source_db_link);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_DB_LINK_NOT_FUNCTIONAL
          ,P_TOKEN1 => 'DB_LINK'
          ,P_VALUE1 => p_source_db_link);

         RAISE e_main_terminate;

WHEN e_invalid_version_param THEN
        FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_INVALID_VERSION_PARAM
          ,P_TOKEN1 => 'VERSION_NAME'
          ,P_VALUE1 => p_version_name);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_INVALID_VERSION_PARAM
          ,P_TOKEN1 => 'VERSION_NAME'
          ,P_VALUE1 => p_version_name);

         RAISE e_main_terminate;


WHEN e_dim_not_user_extensible THEN
        FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_USER_DIM_MISMATCH
          ,P_TOKEN1 => 'USER_DIM_NAME'
          ,P_VALUE1 => p_source_user_dim_name
          ,P_TOKEN2 => 'DIM_NAME'
          ,P_VALUE2 => p_dim_varchar_lbl);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_USER_DIM_MISMATCH
          ,P_TOKEN1 => 'USER_DIM_NAME'
          ,P_VALUE1 => p_source_user_dim_name
          ,P_TOKEN2 => 'DIM_NAME'
          ,P_VALUE2 => p_dim_varchar_lbl);

         RAISE e_main_terminate;


WHEN e_src_dim_not_user_extensible THEN
        FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_INVALID_SRC_USER_DIM
          ,P_TOKEN1 => 'USER_DIM_NAME'
          ,P_VALUE1 => p_source_user_dim_name);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_INVALID_SRC_USER_DIM
          ,P_TOKEN1 => 'USER_DIM_NAME'
          ,P_VALUE1 => p_source_user_dim_name);

         RAISE e_main_terminate;


WHEN e_missing_version_params THEN
        FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_MISSING_VERSION_PARAM);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_MISSING_VERSION_PARAM);

         RAISE e_main_terminate;


WHEN e_invalid_obj_def THEN
        FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_UNHANDLED_ERROR
          ,P_TOKEN1 => 'MIGR_PROG'
          ,P_VALUE1 => 'Dimension Member Migration'
          ,P_TOKEN2 => 'SQLERRM'
          ,P_VALUE2 => SQLERRM);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_UNHANDLED_ERROR
          ,P_TOKEN1 => 'MIGR_PROG'
          ,P_VALUE1 => 'Dimension Member Migration'
          ,P_TOKEN2 => 'SQLERRM'
          ,P_VALUE2 => SQLERRM);

         RAISE e_main_terminate;


WHEN e_invalid_version_display_code THEN
        FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_INVALID_VERSION_DISP_CD
          ,P_TOKEN1 => 'VERSION_CODE'
          ,P_VALUE1 => p_version_disp_cd);


         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_INVALID_VERSION_DISP_CD
          ,P_TOKEN1 => 'VERSION_CODE'
          ,P_VALUE1 => p_version_disp_cd);

         RAISE e_main_terminate;


WHEN e_invalid_version_name THEN
        FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_INVALID_VERSION_NAME
          ,P_TOKEN1 => 'VERSION_NAME'
          ,P_VALUE1 => p_version_name);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_INVALID_VERSION_NAME
          ,P_TOKEN1 => 'VERSION_NAME'
          ,P_VALUE1 => p_version_name);

         RAISE e_main_terminate;


WHEN OTHERS THEN
        FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_UNHANDLED_ERROR
          ,P_TOKEN1 => 'MIGR_PROG'
          ,P_VALUE1 => 'Dimension Member Migration'
          ,P_TOKEN2 => 'SQLERRM'
          ,P_VALUE2 => SQLERRM);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_UNHANDLED_ERROR
          ,P_TOKEN1 => 'MIGR_PROG'
          ,P_VALUE1 => 'Dimension Member Migration'
          ,P_TOKEN2 => 'SQLERRM'
          ,P_VALUE2 => SQLERRM);

         RAISE e_main_terminate;


END;


-----------------------------------------------
-- Process Members --
-----------------------------------------------

PROCEDURE PROCESS_MEMBERS(p_dim_varchar_lbl           IN   VARCHAR2,
p_version_mode               IN   VARCHAR2,
p_source_db_link  IN VARCHAR2)

IS

c_proc_name VARCHAR2(30):= 'process_members';

l_insert_b_sql VARCHAR2(32767);
l_insert_tl_sql VARCHAR2(32767);
l_insert_attr_sql  VARCHAR2(32767);

l_insert_dim_grp_b_sql VARCHAR2(32767);
l_insert_dim_grp_tl_sql VARCHAR2(32767);

l_mp_status VARCHAR2(160);
l_mp_exception VARCHAR2(160);
l_attr_sql  VARCHAR2(1000);
sql_length number;
l_data_table VARCHAR2(100);
l_max_value NUMBER;
l_min_value NUMBER;
l_condition VARCHAR2(100);
l_synonym VARCHAR2(200);


BEGIN


l_insert_b_sql := get_insert_b_sql(p_source_db_link, p_dim_varchar_lbl);

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => c_block||'.l_insert_b_sql',
  p_msg_text => l_insert_b_sql);


l_insert_tl_sql := get_insert_tl_sql(p_source_db_link, p_dim_varchar_lbl);

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => c_block||'.l_insert_tl_sql',
  p_msg_text => l_insert_tl_sql);

l_insert_attr_sql := get_dim_attr_sql(p_version_mode, p_source_db_link, p_dim_varchar_lbl);

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => c_block||'.l_insert_attr_sql',
  p_msg_text => l_insert_attr_sql);

l_insert_dim_grp_b_sql := get_insert_dim_grp_b_sql(p_source_db_link);

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => c_block||'.l_insert_dim_grp_b_sql',
  p_msg_text => l_insert_dim_grp_b_sql);

l_insert_dim_grp_tl_sql := get_insert_dim_grp_tl_sql(p_source_db_link);

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => c_block||'.l_insert_dim_grp_tl_sql',
  p_msg_text => l_insert_dim_grp_tl_sql);


insert_value_sets(p_source_db_link);
COMMIT;

IF (p_dim_varchar_lbl = 'CAL_PERIOD') THEN
  insert_calendars(p_source_db_link);
  COMMIT;
END IF;


BEGIN

EXECUTE IMMEDIATE l_insert_dim_grp_b_sql USING gv_src_dim_props_rec.DIMENSION_ID;
COMMIT;

EXECUTE IMMEDIATE l_insert_dim_grp_tl_sql USING gv_src_dim_props_rec.DIMENSION_ID;
COMMIT;

EXCEPTION
WHEN OTHERS THEN
  RAISE e_main_terminate;
END;


IF (gv_src_dim_props_rec.MEMBER_B_TABLE_NAME IS NOT NULL) THEN
     fem_multi_proc_pkg.MASTER
         (X_PRG_STAT => l_mp_status,
          X_EXCEPTION_CODE => l_mp_exception,
          P_RULE_ID => gv_src_dim_props_rec.MIGRATION_OBJ_ID,
          P_ENG_STEP => 'ALL',
          P_DATA_TABLE => gv_src_dim_props_rec.MEMBER_B_TABLE_NAME,
          P_ENG_SQL => l_insert_b_sql,
          P_TABLE_ALIAS => 'B',
          P_RUN_NAME => 'PROCESS MEMBERS B',
          P_ENG_PRG => 'FEM_DIM_MEMBER_MIGRATION_PKG.PROCESS_MEMBERS',
          P_CONDITION => NULL,
          P_FAILED_REQ_ID => NULL
          ,P_SOURCE_DB_LINK => p_source_db_link
         );


         IF l_mp_status NOT IN ('COMPLETE:NORMAL') THEN
           IF l_mp_exception IN ('FEM_MP_NO_DATA_SLICES_ERR') THEN
              null;
           ELSE
              RAISE e_insert_b_exception;
           END IF;
         END IF;

END IF;

IF (gv_src_dim_props_rec.MEMBER_TL_TABLE_NAME IS NOT NULL) THEN

     fem_multi_proc_pkg.MASTER
         (X_PRG_STAT => l_mp_status,
          X_EXCEPTION_CODE => l_mp_exception,
          P_RULE_ID => gv_src_dim_props_rec.MIGRATION_OBJ_ID,
          P_ENG_STEP => 'ALL',
          P_DATA_TABLE => gv_src_dim_props_rec.MEMBER_TL_TABLE_NAME,
          P_ENG_SQL => l_insert_tl_sql,
          P_TABLE_ALIAS => 'TL',
          P_RUN_NAME => 'PROCESS MEMBERS TL',
          P_ENG_PRG => 'FEM_DIM_MEMBER_MIGRATION_PKG.PROCESS_MEMBERS',
          P_CONDITION => NULL,
          P_FAILED_REQ_ID => NULL,
          P_SOURCE_DB_LINK => p_source_db_link
         );

         IF l_mp_status NOT IN ('COMPLETE:NORMAL') THEN
           IF l_mp_exception IN ('FEM_MP_NO_DATA_SLICES_ERR') THEN
              null;
           ELSE
              RAISE e_insert_tl_exception;
           END IF;
         END IF;

END IF;

IF (gv_src_dim_props_rec.ATTRIBUTE_TABLE_NAME IS NOT NULL) THEN

      fem_multi_proc_pkg.MASTER
         (X_PRG_STAT => l_mp_status,
          X_EXCEPTION_CODE => l_mp_exception,
          P_RULE_ID => gv_src_dim_props_rec.MIGRATION_OBJ_ID,
          P_ENG_STEP => 'ALL',
          P_DATA_TABLE => gv_src_dim_props_rec.ATTRIBUTE_TABLE_NAME,
          P_ENG_SQL => l_insert_attr_sql,
          P_TABLE_ALIAS => 'ATTR',
          P_RUN_NAME => 'PROCESS MEMBERS ATTR',
          P_ENG_PRG => 'FEM_DIM_MEMBER_MIGRATION_PKG.PROCESS_MEMBERS',
          P_CONDITION => NULL,
          P_FAILED_REQ_ID => NULL,
          P_SOURCE_DB_LINK => p_source_db_link
         );

         IF l_mp_status NOT IN ('COMPLETE:NORMAL') THEN
           IF l_mp_exception IN ('FEM_MP_NO_DATA_SLICES_ERR') THEN
              null;
           ELSE
              RAISE e_insert_attr_exception;
           END IF;
         END IF;

    update_calp_attributes(p_source_db_link);

END IF;





EXCEPTION
  WHEN e_insert_b_exception THEN
        FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_INSERT_ERROR
          ,P_TOKEN1 => 'TABLE_NAME'
          ,P_VALUE1 => gv_dim_props_rec.INTF_MEMBER_B_TABLE_NAME);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_INSERT_ERROR
          ,P_TOKEN1 => 'TABLE_NAME'
          ,P_VALUE1 => gv_dim_props_rec.INTF_MEMBER_B_TABLE_NAME);

        RAISE e_main_terminate;

  WHEN e_insert_tl_exception THEN
        FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_INSERT_ERROR
          ,P_TOKEN1 => 'TABLE_NAME'
          ,P_VALUE1 => gv_dim_props_rec.INTF_MEMBER_TL_TABLE_NAME);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_INSERT_ERROR
          ,P_TOKEN1 => 'TABLE_NAME'
          ,P_VALUE1 => gv_dim_props_rec.INTF_MEMBER_TL_TABLE_NAME);
RAISE e_main_terminate;

  WHEN e_insert_attr_exception THEN
        FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_INSERT_ERROR
          ,P_TOKEN1 => 'TABLE_NAME'
          ,P_VALUE1 => gv_dim_props_rec.INTF_ATTRIBUTE_TABLE_NAME);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_INSERT_ERROR
          ,P_TOKEN1 => 'TABLE_NAME'
          ,P_VALUE1 => gv_dim_props_rec.INTF_ATTRIBUTE_TABLE_NAME);

RAISE e_main_terminate;

  WHEN e_terminate THEN

    RAISE e_main_terminate;

END PROCESS_MEMBERS;



-----------------------------------------------
-- Pre-Process Hierarchy --
-----------------------------------------------
PROCEDURE PRE_PROCESS_HIERARCHY(
                          p_source_db_link             IN   VARCHAR2,
                          p_dim_varchar_lbl            IN   VARCHAR2,
                          p_hier_obj_name              IN   VARCHAR2,
                          p_hier_obj_def_name          IN   VARCHAR2,
                          p_source_user_dim_name       IN   VARCHAR2,
                          x_folder_name                OUT  NOCOPY VARCHAR2,
                          x_hier_obj_id                OUT  NOCOPY NUMBER)

IS

c_proc_name VARCHAR2(30):= 'pre_process_hierarchy';

l_verify_db_link   VARCHAR2(10);
l_error_code       VARCHAR2(10);
l_return_code      VARCHAR2(10);
l_pl_exec_status   VARCHAR2(30);
l_dim_obj_id       NUMBER;
l_delete_b_sql     VARCHAR2(200);
l_delete_tl_sql    VARCHAR2(200);
l_delete_attr_sql  VARCHAR2(200);
l_delete_dg_b_sql     VARCHAR2(200);
l_delete_dg_tl_sql    VARCHAR2(200);
l_hier_obj_id  NUMBER;
l_delete_hier_rule_sql VARCHAR2(200);
l_delete_hier_sql VARCHAR2(200);
l_delete_hier_vs_sql VARCHAR2(200);
l_delete_hier_dg_sql VARCHAR2(200);
l_folder_name   VARCHAR2(150);


l_hier_rule_sql VARCHAR2(1000):= 'SELECT A.OBJECT_ID, B.FOLDER_NAME'||
' FROM FEM_OBJECT_CATALOG_VL@'||p_source_db_link||' A,'||
' FEM_FOLDERS_VL@'||p_source_db_link||' B'||
' WHERE A.OBJECT_TYPE_CODE = ''HIERARCHY'''||
' AND A.FOLDER_ID = B.FOLDER_ID'||
' AND A.OBJECT_NAME = :hier_obj_name';


BEGIN

l_verify_db_link := validate_db_link(p_source_db_link);

--TO DO:  CHECK LANGUAGE SETTINGS -- TGT SESSION LANG MUST BE INSTALLED IN SRC')--

--validate hierarchy--
--MUST ALSO CHECK TO MAKE SURE HIERARCHY DOES NOT EXIST IN TARGET WHEN NO VERSION IS SPECIFIED--
BEGIN

  --is dimension hierarchy supported? need to fail if not!!!--
get_dimension_info(p_dim_varchar_lbl,
                   p_source_user_dim_name,
                   p_source_db_link);

IF (gv_dim_props_rec.HIERARCHY_TABLE_NAME IS NULL) THEN
  RAISE e_dim_hier_not_supported;
END IF;

EXECUTE IMMEDIATE l_hier_rule_sql
INTO l_hier_obj_id, l_folder_name
USING p_hier_obj_name;

x_hier_obj_id := l_hier_obj_id;
x_folder_name := l_folder_name;

EXCEPTION

WHEN NO_DATA_FOUND THEN

   RAISE e_invalid_hierarchy;

END;
-- end validate hierarchy--


register_process_execution(p_object_id => 2000,
                           p_obj_def_id => 2000,
                           p_execution_mode => 'S');


--delete existing data (move to procedure)
l_delete_hier_rule_sql := 'DELETE FROM FEM_HIERARCHIES_T'||
                  ' WHERE HIERARCHY_OBJECT_NAME = :hier_obj_name AND CREATED_BY_DIM_MIGRATION_FLAG = ''Y''';

l_delete_hier_sql := 'DELETE FROM '||gv_dim_props_rec.HIERARCHY_INTF_TABLE_NAME||
                   ' WHERE HIERARCHY_OBJECT_NAME = :hier_obj_name AND CREATED_BY_DIM_MIGRATION_FLAG = ''Y''';

l_delete_hier_vs_sql := 'DELETE FROM FEM_HIER_VALUE_SETS_T'||
                     ' WHERE HIERARCHY_OBJECT_NAME = :hier_obj_name AND CREATED_BY_DIM_MIGRATION_FLAG = ''Y''';

l_delete_hier_dg_sql := 'DELETE FROM FEM_HIER_DIM_GRPS_T'||
                     ' WHERE HIERARCHY_OBJECT_NAME = :hier_obj_name AND CREATED_BY_DIM_MIGRATION_FLAG = ''Y''';

EXECUTE IMMEDIATE l_delete_hier_rule_sql USING p_hier_obj_name;
EXECUTE IMMEDIATE l_delete_hier_sql USING p_hier_obj_name;
EXECUTE IMMEDIATE l_delete_hier_vs_sql USING p_hier_obj_name;
EXECUTE IMMEDIATE l_delete_hier_dg_sql USING p_hier_obj_name;

COMMIT;
--End delete


EXCEPTION

WHEN e_dimension_not_supported THEN
         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_DIM_NOT_SUPPORTED
          ,P_TOKEN1 => 'DIM_NAME'
          ,P_VALUE1 => p_dim_varchar_lbl);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_DIM_NOT_SUPPORTED
          ,P_TOKEN1 => 'DIM_NAME'
          ,P_VALUE1 => p_dim_varchar_lbl);

         RAISE e_main_terminate;

WHEN e_invalid_dimension THEN
         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_INVALID_DIMENSION
          ,P_TOKEN1 => 'DIM_LBL'
          ,P_VALUE1 => p_dim_varchar_lbl);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_INVALID_DIMENSION
          ,P_TOKEN1 => 'DIM_LBL'
          ,P_VALUE1 => p_dim_varchar_lbl);

         RAISE e_main_terminate;

WHEN e_db_link_not_registered THEN
         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_DB_LINK_NOT_REGISTERED
          ,P_TOKEN1 => 'DB_LINK'
          ,P_VALUE1 => p_source_db_link);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_DB_LINK_NOT_REGISTERED
          ,P_TOKEN1 => 'DB_LINK'
          ,P_VALUE1 => p_source_db_link);

         RAISE e_main_terminate;

WHEN e_db_link_not_functional THEN
         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_DB_LINK_NOT_FUNCTIONAL
          ,P_TOKEN1 => 'DB_LINK'
          ,P_VALUE1 => p_source_db_link);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_DB_LINK_NOT_FUNCTIONAL
          ,P_TOKEN1 => 'DB_LINK'
          ,P_VALUE1 => p_source_db_link);

         RAISE e_main_terminate;


WHEN e_dim_not_user_extensible THEN
        FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_USER_DIM_MISMATCH
          ,P_TOKEN1 => 'USER_DIM_NAME'
          ,P_VALUE1 => p_source_user_dim_name);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_USER_DIM_MISMATCH
          ,P_TOKEN1 => 'USER_DIM_NAME'
          ,P_VALUE1 => p_source_user_dim_name);

         RAISE e_main_terminate;


WHEN e_src_dim_not_user_extensible THEN
        FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_INVALID_SRC_USER_DIM
          ,P_TOKEN1 => 'USER_DIM_NAME'
          ,P_VALUE1 => p_source_user_dim_name);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_INVALID_SRC_USER_DIM
          ,P_TOKEN1 => 'USER_DIM_NAME'
          ,P_VALUE1 => p_source_user_dim_name);

         RAISE e_main_terminate;


WHEN e_invalid_hierarchy THEN
        FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_INVALID_HIERARCHY
          ,P_TOKEN1 => 'HIER'
          ,P_VALUE1 => p_hier_obj_name);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_INVALID_HIERARCHY
          ,P_TOKEN1 => 'HIER'
          ,P_VALUE1 => p_hier_obj_name);

         RAISE e_main_terminate;

WHEN e_dim_hier_not_supported THEN

        FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_DIM_HIER_NOT_SUPPORTED
          ,P_TOKEN1 => 'DIM_NAME'
          ,P_VALUE1 => p_dim_varchar_lbl);


         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_DIM_HIER_NOT_SUPPORTED
          ,P_TOKEN1 => 'DIM_NAME'
          ,P_VALUE1 => p_dim_varchar_lbl);

         RAISE e_main_terminate;

WHEN OTHERS THEN
          FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_UNHANDLED_ERROR
          ,P_TOKEN1 => 'MIGR_PROG'
          ,P_VALUE1 => 'Dimension Hierarchy Migration'
          ,P_TOKEN2 => 'SQLERRM'
          ,P_VALUE2 => SQLERRM);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_UNHANDLED_ERROR
          ,P_TOKEN1 => 'MIGR_PROG'
          ,P_VALUE1 => 'Dimension Hierarchy Migration'
          ,P_TOKEN2 => 'SQLERRM'
          ,P_VALUE2 => SQLERRM);

         RAISE e_main_terminate;

END;
-----------------------------------------------
-- Process Hierarchy --
-----------------------------------------------

PROCEDURE process_hierarchy(p_dim_varchar_lbl IN VARCHAR2,
                            p_folder_name IN VARCHAR2,
                            p_hier_obj_id   IN NUMBER,
                            p_hier_obj_name IN VARCHAR2,
                            p_hier_obj_def_name IN VARCHAR2,
                            p_source_db_link  IN VARCHAR2,
                            p_source_user_dim_name IN VARCHAR2)

IS

c_proc_name VARCHAR2(30) := 'process_hierarchy';

TYPE HIER_VERSIONS_TYPE IS REF CURSOR;

hier_versions_cur HIER_VERSIONS_TYPE;

l_hier_obj_id  NUMBER;
l_hier_obj_def_id NUMBER;
l_insert_hier_sql  VARCHAR2(32767);
l_insert_hier_rule_sql  VARCHAR2(32767);
l_insert_hier_vs_sql VARCHAR2(32767);
l_insert_hier_dg_sql VARCHAR2(32767);
l_mp_status VARCHAR2(160);
l_mp_exception VARCHAR2(160);
l_hier_obj_def_name  VARCHAR2(150);
l_eff_start_date DATE;
l_eff_end_date DATE;
l_target_obj_id NUMBER;
l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data     VARCHAR2(4000);

l_hier_rule_sql VARCHAR2(1000):= 'SELECT A.OBJECT_ID'||
' FROM FEM_OBJECT_CATALOG_VL@'||p_source_db_link||' A'||
' WHERE A.OBJECT_TYPE_CODE = ''HIERARCHY'''||
' AND A.OBJECT_NAME = :hier_obj_name';

l_hier_version_sql VARCHAR2(1000):= 'SELECT B.OBJECT_DEFINITION_ID,'||
' B.DISPLAY_NAME,'||
' B.EFFECTIVE_START_DATE,'||
' B.EFFECTIVE_END_DATE'||
' FROM FEM_OBJECT_DEFINITION_VL@'||p_source_db_link||' B'||
' WHERE B.OBJECT_ID = :hier_obj_id'||'{{version_where}}';


l_hier_version_where VARCHAR2(100) := ' AND B.DISPLAY_NAME = :hier_obj_def_name';

BEGIN

--Check to see if hierarchy rule exists in target system.
BEGIN

SELECT OBJECT_ID
INTO l_target_obj_id
FROM FEM_OBJECT_CATALOG_VL
WHERE OBJECT_NAME = p_hier_obj_name;

EXCEPTION

WHEN NO_DATA_FOUND THEN
   NULL;
END;

--FEM_HIERARCHIES_T--
IF (p_hier_obj_def_name IS NOT NULL) THEN

BEGIN

l_hier_version_sql := REPLACE(l_hier_version_sql, '{{version_where}}', l_hier_version_where);

  FEM_ENGINES_PKG.TECH_MESSAGE
   (p_severity => c_log_level_2,
    p_module => c_block||'.l_hier_version_sql',
    p_msg_text => l_hier_version_sql);


EXECUTE IMMEDIATE l_hier_version_sql
INTO l_hier_obj_def_id, l_hier_obj_def_name, l_eff_start_date, l_eff_end_date
USING p_hier_obj_id, p_hier_obj_def_name;

EXCEPTION

WHEN NO_DATA_FOUND THEN

   RAISE e_invalid_hierarchy_version;

END;

--CHECK FOR OVERLAPPING EFFECTIVE DATES IF RULE EXISTS IN TARGET--
IF (l_target_obj_id IS NOT NULL) THEN
  /*FEM_BUSINESS_RULE_PVT.CheckOverlapObjDefs(l_target_obj_id,
                                            NULL,
                                            l_eff_start_date,
                                            l_eff_end_date,
                                            FND_API.G_FALSE,
                                            l_return_status,
                                            l_msg_count,
                                            l_msg_data);*/
  FEM_BUSINESS_RULE_PVT.CheckOverlapObjDefs(
    p_api_version           => 1.0
    ,p_init_msg_list        => FND_API.G_FALSE
    ,x_return_status        => l_return_status
    ,x_msg_count            => l_msg_count
    ,x_msg_data             => l_msg_data
    ,p_obj_id               => l_target_obj_id
    ,p_exclude_obj_def_id   => null
    ,p_effective_start_date => l_eff_start_date
    ,p_effective_end_date   => l_eff_end_date
  );

  IF (l_return_status <> 'S') THEN
    l_eff_start_date := NULL;
    l_eff_end_date := NULL;
  END IF;
END IF;


l_insert_hier_rule_sql := get_dim_hier_rule_sql(p_dim_varchar_lbl,
                                                p_folder_name,
                                                p_hier_obj_name,
                                                p_hier_obj_def_name,
                                                p_source_db_link,
                                                l_eff_start_date,
                                                l_eff_end_date);


l_insert_hier_sql := get_dim_hier_sql(p_hier_obj_name,
                                      p_hier_obj_def_name,
                                      l_hier_obj_def_id,
                                      p_dim_varchar_lbl,
                                      p_source_db_link);




  FEM_ENGINES_PKG.TECH_MESSAGE
   (p_severity => c_log_level_2,
    p_module => c_block||'.l_insert_hier_rule_sql',
    p_msg_text => l_insert_hier_rule_sql);

EXECUTE IMMEDIATE l_insert_hier_rule_sql USING p_hier_obj_id;
COMMIT;

--IF DUPLICATE DATA EXISTS THROW ERROR B/C IT CAME FROM SOME OTHER DATA SOURCE--

     fem_multi_proc_pkg.MASTER
         (X_PRG_STAT => l_mp_status,
          X_EXCEPTION_CODE => l_mp_exception,
          P_RULE_ID => 2000,
          P_ENG_STEP => 'ALL',
          P_DATA_TABLE => gv_src_dim_props_rec.HIERARCHY_TABLE_NAME,
          P_ENG_SQL => l_insert_hier_sql,
          P_TABLE_ALIAS => 'HIER',
          P_RUN_NAME => 'PROCESS MEMBERS HIER',
          P_ENG_PRG => 'FEM_DIM_MEMBER_MIGRATION_PKG.PROCESS_MEMBERS',
          P_CONDITION => NULL,
          P_FAILED_REQ_ID => NULL,
          P_SOURCE_DB_LINK => p_source_db_link);

         IF l_mp_status NOT IN ('COMPLETE:NORMAL') THEN
           IF l_mp_exception IN ('FEM_MP_NO_DATA_SLICES_ERR') THEN
              null;
           ELSE
              RAISE e_terminate;
           END IF;
         END IF;


ELSE --no version specified
--IF NO VERSION SPECIFIED, THEN HIERARCHY MUST NOT EXIST IN TARGET--
IF (l_target_obj_id IS NOT NULL) THEN
  RAISE e_target_hierarchy_exists;
END IF;

l_hier_version_sql := REPLACE(l_hier_version_sql, '{{version_where}}', '');

  FEM_ENGINES_PKG.TECH_MESSAGE
   (p_severity => c_log_level_2,
    p_module => c_block||'.l_hier_version_sql',
    p_msg_text => l_hier_version_sql);

--CURSOR NEEDED TO RETRIEVE ALL VERSIONS--

OPEN hier_versions_cur FOR l_hier_version_sql USING p_hier_obj_id;

LOOP

FETCH hier_versions_cur
INTO l_hier_obj_def_id,
     l_hier_obj_def_name,
     l_eff_start_date,
     l_eff_end_date;


EXIT WHEN hier_versions_cur%NOTFOUND;

l_insert_hier_rule_sql := get_dim_hier_rule_sql(p_dim_varchar_lbl,
                                                p_folder_name,
                                                p_hier_obj_name,
                                                l_hier_obj_def_name,
                                                p_source_db_link,
                                                l_eff_start_date,
                                                l_eff_end_date);


l_insert_hier_sql := get_dim_hier_sql(p_hier_obj_name,
                                      l_hier_obj_def_name,
                                      l_hier_obj_def_id,
                                      p_dim_varchar_lbl,
                                      p_source_db_link);



  FEM_ENGINES_PKG.TECH_MESSAGE
   (p_severity => c_log_level_2,
    p_module => c_block||'.l_insert_hier_rule_sql',
    p_msg_text => l_insert_hier_rule_sql);

EXECUTE IMMEDIATE l_insert_hier_rule_sql USING p_hier_obj_id;
COMMIT;

--IF DUPLICATE DATA EXISTS THROW ERROR B/C IT CAME FROM SOME OTHER DATA SOURCE--

  FEM_ENGINES_PKG.TECH_MESSAGE
   (p_severity => c_log_level_2,
    p_module => c_block||'.l_insert_hier_sql',
    p_msg_text => l_insert_hier_sql);


     fem_multi_proc_pkg.MASTER
         (X_PRG_STAT => l_mp_status,
          X_EXCEPTION_CODE => l_mp_exception,
          P_RULE_ID => 2000,
          P_ENG_STEP => 'ALL',
          P_DATA_TABLE => gv_src_dim_props_rec.HIERARCHY_TABLE_NAME,
          P_ENG_SQL => l_insert_hier_sql,
          P_TABLE_ALIAS => 'HIER',
          P_RUN_NAME => 'PROCESS MEMBERS HIER',
          P_ENG_PRG => 'FEM_DIM_MEMBER_MIGRATION_PKG.PROCESS_MEMBERS',
          P_CONDITION => NULL,
          P_FAILED_REQ_ID => NULL
          ,P_SOURCE_DB_LINK => p_source_db_link
         );

         IF l_mp_status NOT IN ('COMPLETE:NORMAL') THEN
           IF l_mp_exception IN ('FEM_MP_NO_DATA_SLICES_ERR') THEN
              null;
           ELSE
              RAISE e_insert_hier_exception;
           END IF;
         END IF;

  END LOOP;
END IF;


--process value sets and dimension groups--
l_insert_hier_vs_sql := get_hier_vs_sql(p_hier_obj_name,
                                        p_source_db_link);
  FEM_ENGINES_PKG.TECH_MESSAGE
   (p_severity => c_log_level_2,
    p_module => c_block||'.l_insert_hier_vs_sql',
    p_msg_text => l_insert_hier_vs_sql);

l_insert_hier_dg_sql := get_hier_dg_sql(p_hier_obj_name, p_source_db_link);


  FEM_ENGINES_PKG.TECH_MESSAGE
   (p_severity => c_log_level_2,
    p_module => c_block||'.l_insert_hier_dg_sql',
    p_msg_text => l_insert_hier_dg_sql);

EXECUTE IMMEDIATE l_insert_hier_vs_sql USING p_hier_obj_id;
COMMIT;

EXECUTE IMMEDIATE l_insert_hier_dg_sql USING p_hier_obj_id;
COMMIT;

--end process value sets and dimension groups--

EXCEPTION

WHEN e_invalid_hierarchy THEN

        FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_INVALID_HIERARCHY
          ,P_TOKEN1 => 'HIER'
          ,P_VALUE1 => p_hier_obj_name);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_INVALID_HIERARCHY
          ,P_TOKEN1 => 'HIER'
          ,P_VALUE1 => p_hier_obj_name);

         RAISE e_main_terminate;

WHEN e_insert_hier_exception THEN

        FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_INSERT_ERROR
          ,P_TOKEN1 => 'TABLE_NAME'
          ,P_VALUE1 => gv_dim_props_rec.HIERARCHY_INTF_TABLE_NAME);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_INSERT_ERROR
          ,P_TOKEN1 => 'TABLE_NAME'
          ,P_VALUE1 => gv_dim_props_rec.HIERARCHY_INTF_TABLE_NAME);

         RAISE e_main_terminate;

WHEN e_invalid_hierarchy_version THEN

        FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_INVALID_HIER_VERSION
          ,P_TOKEN1 => 'HIER_VERSION'
          ,P_VALUE1 => p_hier_obj_def_name);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_INVALID_HIER_VERSION
          ,P_TOKEN1 => 'HIER_VERSION'
          ,P_VALUE1 => p_hier_obj_def_name);

         RAISE e_main_terminate;

WHEN e_terminate THEN
        FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_UNHANDLED_ERROR
          ,P_TOKEN1 => 'MIGR_PROG'
          ,P_VALUE1 => 'Dimension Hierarchy Migration'
          ,P_TOKEN2 => 'SQLERRM'
          ,P_VALUE2 => SQLERRM);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_UNHANDLED_ERROR
          ,P_TOKEN1 => 'MIGR_PROG'
          ,P_VALUE1 => 'Dimension Hierarchy Migration'
          ,P_TOKEN2 => 'SQLERRM'
          ,P_VALUE2 => SQLERRM);

         RAISE e_main_terminate;

WHEN e_target_hierarchy_exists THEN
        FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_HIERARCHY_RULE_EXISTS
          ,P_TOKEN1 => 'HIER_NAME'
          ,P_VALUE1 => p_hier_obj_name);


         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_HIERARCHY_RULE_EXISTS
          ,P_TOKEN1 => 'HIER_NAME'
          ,P_VALUE1 => p_hier_obj_name);

         RAISE e_main_terminate;

END;

-----------------------------------------------
-- Post-Process Members --
-----------------------------------------------

PROCEDURE POST_PROCESS_HIERARCHY(p_execution_status IN VARCHAR2)

IS

   v_msg_count NUMBER;
   v_msg_data VARCHAR2(4000);
   v_API_return_status VARCHAR2(30);

BEGIN

   ------------------------------------
   -- Update Object Execution Errors --
   ------------------------------------
   /*FEM_PL_PKG.Update_Obj_Exec_Errors(
     P_API_VERSION               => c_api_version,
     P_COMMIT                    => c_true,
     P_REQUEST_ID                => gv_request_id,
     P_OBJECT_ID                 => gv_dim_props_rec.MIGRATION_OBJ_ID,
     P_USER_ID                   => gv_apps_user_id,
     P_LAST_UPDATE_LOGIN         => null,
     X_MSG_COUNT                 => v_msg_count,
     X_MSG_DATA                  => v_msg_data,
     X_RETURN_STATUS             => v_API_return_status);

   IF v_API_return_status NOT IN ('S') THEN
      RAISE e_post_process;
   END IF;*/

   ------------------------------------
   -- Update Object Execution Status --
   ------------------------------------
   FEM_PL_PKG.Update_Obj_Exec_Status(
     P_API_VERSION               => c_api_version,
     P_COMMIT                    => c_true,
     P_REQUEST_ID                => gv_request_id,
     P_OBJECT_ID                 => gv_dim_props_rec.MIGRATION_OBJ_ID,
     P_EXEC_STATUS_CODE          => p_execution_status,
     P_USER_ID                   => gv_apps_user_id,
     P_LAST_UPDATE_LOGIN         => null,
     X_MSG_COUNT                 => v_msg_count,
     X_MSG_DATA                  => v_msg_data,
     X_RETURN_STATUS             => v_API_return_status);

   IF v_API_return_status NOT IN ('S') THEN
      RAISE e_post_process;
   END IF;

   ---------------------------
   -- Update Request Status --
   ---------------------------
   FEM_PL_PKG.Update_Request_Status(
     P_API_VERSION               => c_api_version,
     P_COMMIT                    => c_true,
     P_REQUEST_ID                => gv_request_id,
     P_EXEC_STATUS_CODE          => p_execution_status,
     P_USER_ID                   => gv_apps_user_id,
     P_LAST_UPDATE_LOGIN         => null,
     X_MSG_COUNT                 => v_msg_count,
     X_MSG_DATA                  => v_msg_data,
     X_RETURN_STATUS             => v_API_return_status);

   IF v_API_return_status NOT IN ('S') THEN
      RAISE e_post_process;
   END IF;

   IF (p_execution_status = 'SUCCESS') THEN
    gv_concurrent_status := fnd_concurrent.set_completion_status('NORMAL',null);
   ELSE
    gv_concurrent_status := fnd_concurrent.set_completion_status('ERROR',null);
   END IF;

EXCEPTION
   WHEN e_post_process THEN
      -- get messages from the stack
      Get_Put_Messages (
         p_msg_count => v_msg_count,
         p_msg_data => v_msg_data);

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => c_block||'.'||'Eng_Master_Post_Proc',
        p_msg_text => 'Post Process failed');

      FEM_ENGINES_PKG.USER_MESSAGE
       (P_APP_NAME => c_fem
       ,P_MSG_NAME => G_PL_MIGRATION_ERROR);

END POST_PROCESS_HIERARCHY;


-----------------------------------------------
-- Migrate Members --
-----------------------------------------------
PROCEDURE MIGRATE_MEMBERS(x_retcode                   OUT  NOCOPY  VARCHAR2,
                          x_errug                     OUT  NOCOPY  VARCHAR2,
                          p_source_db_link            IN   VARCHAR2,
                          p_dim_varchar_lbl           IN   VARCHAR2,
                      --    p_version_mode              IN   VARCHAR2,
                      --    p_version_disp_cd           IN   VARCHAR2,
                      --    p_version_name              IN   VARCHAR2,
                      --     p_version_desc              IN   VARCHAR2,
                          p_source_user_dim_name      IN   VARCHAR2)
IS

BEGIN

MIGRATE_MEMBERS(x_retcode => x_retcode,
                x_errug => x_errug,
                p_source_db_link => p_source_db_link,
                p_dim_varchar_lbl => p_dim_varchar_lbl,
                p_autoload_dims => 'NO',
                p_migrate_dependent_dims => 'NO',
                p_version_mode => 'DEFAULT',
                p_version_disp_cd => NULL,
                p_version_name => NULL,
                p_version_desc => NULL,
                p_hier_obj_name=> NULL,
                p_hier_obj_def_name => NULL,
                p_source_user_dim_name => p_source_user_dim_name);

END MIGRATE_MEMBERS;


PROCEDURE MIGRATE_HIERARCHY(x_retcode                   OUT  NOCOPY  VARCHAR2,
                            x_errug                     OUT  NOCOPY  VARCHAR2,
                            p_source_db_link            IN   VARCHAR2,
                            p_dim_varchar_lbl           IN   VARCHAR2,
                            p_hier_obj_name             IN   VARCHAR2,
                            p_hier_obj_def_name         IN   VARCHAR2,
                            p_source_user_dim_name      IN   VARCHAR2)
IS



l_hier_obj_id NUMBER;
l_folder_name VARCHAR2(150);


BEGIN

   FEM_ENGINES_PKG.User_Message(
     p_msg_text => 'Migrating Hierarchy...');


PRE_PROCESS_HIERARCHY(p_source_db_link,
                      p_dim_varchar_lbl,
                      p_hier_obj_name,
                      p_hier_obj_def_name,
                      p_source_user_dim_name,
                      l_folder_name,
                      l_hier_obj_id);


process_hierarchy(p_dim_varchar_lbl,
                  l_folder_name,
                  l_hier_obj_id,
                  p_hier_obj_name,
                  p_hier_obj_def_name,
                  p_source_db_link,
                  p_source_user_dim_name);

POST_PROCESS_HIERARCHY('SUCCESS');

EXCEPTION

WHEN e_main_terminate THEN

  gv_concurrent_status := fnd_concurrent.set_completion_status('ERROR',null);
  POST_PROCESS_HIERARCHY('ERROR_RERUN');

END MIGRATE_HIERARCHY;


PROCEDURE MIGRATE_MEMBERS(x_retcode                   OUT  NOCOPY  VARCHAR2,
                          x_errug                     OUT  NOCOPY  VARCHAR2,
                          p_source_db_link            IN   VARCHAR2,
                          p_dim_varchar_lbl           IN   VARCHAR2,
                          p_autoload_dims             IN   VARCHAR2,
                          p_migrate_dependent_dims    IN   VARCHAR2,
                          p_version_mode              IN   VARCHAR2,
                          p_version_disp_cd           IN   VARCHAR2,
                          p_version_name              IN   VARCHAR2,
                          p_version_desc              IN   VARCHAR2,
                          p_hier_obj_name             IN   VARCHAR2,
                          p_hier_obj_def_name         IN   VARCHAR2,
                          p_source_user_dim_name      IN   VARCHAR2)
IS



l_dim_obj_def_id  NUMBER;
l_return_status NUMBER;

BEGIN

   FEM_ENGINES_PKG.User_Message(
     p_msg_text => 'Migrating Members...');


   PRE_PROCESS_MEMBERS(
                          p_source_db_link => p_source_db_link,
                          p_dim_varchar_lbl  => p_dim_varchar_lbl,
                          p_autoload_dims  => 'NO',
                          p_migrate_dependent_dims  => 'NO',
                          p_version_mode  => p_version_mode,
                          p_version_disp_cd  => p_version_disp_cd,
                          p_version_name  => p_version_name,
                          p_source_user_dim_name => p_source_user_dim_name,
                          p_hier_obj_name => p_hier_obj_name,
                          p_hier_obj_def_name => p_hier_obj_def_name);


   PROCESS_MEMBERS(p_dim_varchar_lbl, p_version_mode, p_source_db_link);


   POST_PROCESS_MEMBERS('SUCCESS');

EXCEPTION

WHEN e_main_terminate THEN

  gv_concurrent_status := fnd_concurrent.set_completion_status('ERROR',null);
  POST_PROCESS_MEMBERS('ERROR_RERUN');

  -- UPDATE PL EXECUTION

END MIGRATE_MEMBERS;


-----------------------------------------------
-- Post-Process Members --
-----------------------------------------------

PROCEDURE POST_PROCESS_MEMBERS(p_execution_status IN VARCHAR2)

IS

   v_msg_count NUMBER;
   v_msg_data VARCHAR2(4000);
   v_API_return_status VARCHAR2(30);

BEGIN

   ------------------------------------
   -- Update Object Execution Errors --
   ------------------------------------
   /*FEM_PL_PKG.Update_Obj_Exec_Errors(
     P_API_VERSION               => c_api_version,
     P_COMMIT                    => c_true,
     P_REQUEST_ID                => gv_request_id,
     P_OBJECT_ID                 => gv_dim_props_rec.MIGRATION_OBJ_ID,
     P_USER_ID                   => gv_apps_user_id,
     P_LAST_UPDATE_LOGIN         => null,
     X_MSG_COUNT                 => v_msg_count,
     X_MSG_DATA                  => v_msg_data,
     X_RETURN_STATUS             => v_API_return_status);

   IF v_API_return_status NOT IN ('S') THEN
      RAISE e_post_process;
   END IF;*/

   ------------------------------------
   -- Update Object Execution Status --
   ------------------------------------
   FEM_PL_PKG.Update_Obj_Exec_Status(
     P_API_VERSION               => c_api_version,
     P_COMMIT                    => c_true,
     P_REQUEST_ID                => gv_request_id,
     P_OBJECT_ID                 => gv_dim_props_rec.MIGRATION_OBJ_ID,
     P_EXEC_STATUS_CODE          => p_execution_status,
     P_USER_ID                   => gv_apps_user_id,
     P_LAST_UPDATE_LOGIN         => null,
     X_MSG_COUNT                 => v_msg_count,
     X_MSG_DATA                  => v_msg_data,
     X_RETURN_STATUS             => v_API_return_status);

   IF v_API_return_status NOT IN ('S') THEN
      RAISE e_post_process;
   END IF;

   ---------------------------
   -- Update Request Status --
   ---------------------------
   FEM_PL_PKG.Update_Request_Status(
     P_API_VERSION               => c_api_version,
     P_COMMIT                    => c_true,
     P_REQUEST_ID                => gv_request_id,
     P_EXEC_STATUS_CODE          => p_execution_status,
     P_USER_ID                   => gv_apps_user_id,
     P_LAST_UPDATE_LOGIN         => null,
     X_MSG_COUNT                 => v_msg_count,
     X_MSG_DATA                  => v_msg_data,
     X_RETURN_STATUS             => v_API_return_status);

   IF v_API_return_status NOT IN ('S') THEN
      RAISE e_post_process;
   END IF;

   IF (p_execution_status = 'SUCCESS') THEN
    gv_concurrent_status := fnd_concurrent.set_completion_status('NORMAL',null);
   ELSE
    gv_concurrent_status := fnd_concurrent.set_completion_status('ERROR',null);
   END IF;

EXCEPTION
   WHEN e_post_process THEN
      -- get messages from the stack
      Get_Put_Messages (
         p_msg_count => v_msg_count,
         p_msg_data => v_msg_data);

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => c_block||'.'||'Eng_Master_Post_Proc',
        p_msg_text => 'Post Process failed');

      FEM_ENGINES_PKG.USER_MESSAGE
       (P_APP_NAME => c_fem
       ,P_MSG_NAME => G_PL_MIGRATION_ERROR);

END POST_PROCESS_MEMBERS;


END FEM_DIMENSION_MIGRATION_PKG;

/
