--------------------------------------------------------
--  DDL for Package Body FEM_FACTOR_TABLES_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_FACTOR_TABLES_UTIL_PKG" AS
/* $Header: FEMFACTTABB.pls 120.1 2008/02/20 06:45:26 jcliving noship $ */

   c_module_pkg CONSTANT VARCHAR2(80) := 'fem.plsql.FEM_FACTOR_TABLE_UTIL';
   g_pkg_name   CONSTANT VARCHAR2(30) := 'FEM_FACTOR_TABLE_UTIL';

   FUNCTION is_matching_dimension_leaf (p_object_definition_id IN NUMBER,
                                        p_level_num IN NUMBER) RETURN VARCHAR2 IS


     l_api_name  CONSTANT  VARCHAR2(30) := 'is_matching_dimension_leaf';
     l_api_version CONSTANT NUMBER      :=  1.0;

     l_count NUMBER := 0;
     l_leaf_flag VARCHAR2(10) :='Y';

   BEGIN

     FEM_ENGINES_PKG.Tech_Message (
           p_severity  => fnd_log.level_procedure
           ,p_module   => c_module_pkg||'.'||l_api_name
           ,p_msg_text => 'Begining Function'
       );

     SELECT count(*) into l_count
     FROM   fem_factor_table_dims
     WHERE  object_definition_id = p_object_definition_id
     AND    dim_usage_code = 'MATCH'
     AND    level_num > p_level_num;

     IF l_count > 0 THEN
       l_leaf_flag := 'N';
     END IF;

     RETURN l_leaf_flag;

   END is_matching_dimension_leaf;


   PROCEDURE delete_member (p_object_definition_id IN NUMBER,
                            p_row_num IN NUMBER) IS

     CURSOR c_del_mem_list IS
     SELECT row_num
     FROM   fem_factor_table_fctrs
     WHERE  object_definition_id = p_object_definition_id
     CONNECT BY prior row_num = parent_row_num
     START WITH row_num = p_row_num;

     l_api_name  CONSTANT  VARCHAR2(30) := 'delete_member';
     l_api_version CONSTANT NUMBER      :=  1.0;

     l_row_num NUMBER;


   BEGIN

     FEM_ENGINES_PKG.Tech_Message (
      p_severity  => fnd_log.level_procedure
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => 'Beginning Function'
     );

     FOR row_num_rec IN c_del_mem_list LOOP
       DELETE FROM fem_factor_table_fctrs
       WHERE row_num = row_num_rec.row_num;
     END LOOP;

     FEM_ENGINES_PKG.Tech_Message (
      p_severity  => fnd_log.level_procedure
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => 'Ending Function'
     );

   EXCEPTION
     WHEN OTHERS THEN
       FEM_ENGINES_PKG.Tech_Message (
        p_severity  => fnd_log.level_unexpected
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => SQLERRM
          );
       fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
       RAISE fnd_api.g_exc_unexpected_error;

   END delete_member;

--------------------------------------------------------------------------------
--
-- PROCEDURE
--   CopyObjectDefintion
--
-- DESCRIPTION
--   Duplicates all the parameters associated with a Factor table Version(source)
--   into the new Factor Table rule Version (target)
--   NOTE:  It does not copy the Factor table Rule Version record into
--   FEM_OBJECT_DEFINITION_VL.
--   These records must already exist, this procedure shall only duplicate the
--   rule version data in rule specific tables.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID.
--   p_creation_date        - System Date.
--
--------------------------------------------------------------------------------

   PROCEDURE CopyObjectDefinition (p_source_obj_def_id  IN NUMBER,
                                   p_target_obj_def_id  IN NUMBER,
                                   p_created_by         IN NUMBER,
                                   p_creation_date      IN DATE )

   IS

    l_api_name  CONSTANT  VARCHAR2(30) := 'CopyObjectDefinition';
    l_api_version CONSTANT NUMBER      :=  1.0;

    CURSOR c_ft_dims IS
      SELECT
        object_definition_id,
        level_num,
        dimension_id,
        dim_usage_code,
        force_percent_flag,
        hier_object_id,
        hier_obj_def_id,
        hier_group_id,
        hier_relation_code
      FROM fem_factor_table_dims
      WHERE object_definition_id = p_source_obj_def_id;

    CURSOR c_ft_fctrs IS
      SELECT
        object_definition_id,
        row_num,
        parent_row_num,
        level_num,
        dim_member,
        factor_value
      FROM fem_factor_table_fctrs
      WHERE object_definition_id =  p_source_obj_def_id;

   BEGIN
     FEM_ENGINES_PKG.Tech_Message (
      p_severity  => fnd_log.level_procedure
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => 'Beginng Function'
     );

     INSERT INTO fem_factor_tables
     (
       object_definition_id,
       factor_type,
       created_by,
       creation_date,
       last_updated_by,
       last_update_login,
       last_update_date,
       object_version_number
     )
     SELECT
       p_target_obj_def_id  AS object_definition_id,
       factor_type,
       p_created_by,
       p_creation_date,
       fnd_global.user_id,
       fnd_global.login_id,
       sysdate,
       0
     FROM fem_factor_tables
     WHERE object_definition_id = p_source_obj_def_id;

     FOR c_dim_rec IN c_ft_dims LOOP
       INSERT INTO fem_factor_table_dims
       (
         object_definition_id,
         level_num,
         dimension_id,
         dim_usage_code,
         force_percent_flag,
         hier_object_id,
         hier_obj_def_id,
         hier_group_id,
         hier_relation_code,
         creation_date,
         created_by,
         last_updated_by,
         last_update_login,
         last_update_date,
         object_version_number
       )
       VALUES
       (
         p_target_obj_def_id,
         c_dim_rec.level_num,
         c_dim_rec.dimension_id,
         c_dim_rec.dim_usage_code,
         c_dim_rec.force_percent_flag,
         c_dim_rec.hier_object_id,
         c_dim_rec.hier_obj_def_id,
         c_dim_rec.hier_group_id,
         c_dim_rec.hier_relation_code,
         p_creation_date,
         p_created_by,
         fnd_global.user_id,
         fnd_global.login_id,
         sysdate,
         0
       );
     END LOOP;

     FOR c_ft_fctrs_rec IN c_ft_fctrs LOOP
       INSERT INTO fem_factor_table_fctrs
       (
         object_definition_id,
         row_num,
         parent_row_num,
         level_num,
         dim_member,
         factor_value,
         creation_date,
         created_by,
         last_updated_by,
         last_update_login,
         last_update_date,
         object_version_number
       )
       VALUES
       (
         p_target_obj_def_id,
         c_ft_fctrs_rec.row_num,
         c_ft_fctrs_rec.parent_row_num,
         c_ft_fctrs_rec.level_num,
         c_ft_fctrs_rec.dim_member,
         c_ft_fctrs_rec.factor_value,
         p_creation_date,
         p_created_by,
         fnd_global.login_id,
         fnd_global.user_id,
         sysdate,
         0
       );
     END LOOP;


     FEM_ENGINES_PKG.Tech_Message (
      p_severity  => fnd_log.level_procedure
      ,p_module   => c_module_pkg||'.'||l_api_name
      ,p_msg_text => 'Ending Function'
     );

   END CopyObjectDefinition;

   PROCEDURE DeleteObjectDefinition ( p_obj_def_id  IN NUMBER ) IS

     l_ver_count NUMBER := 0;
     l_object_id NUMBER;
     l_api_name  CONSTANT  VARCHAR2(30) := 'DeleteObjectDefinition';
     l_api_version CONSTANT NUMBER      :=  1.0;

   BEGIN

     DELETE FROM fem_factor_table_fctrs
     WHERE object_definition_id = p_obj_def_id;

     DELETE FROM fem_factor_tables
     WHERE object_definition_id = p_obj_def_id;

     DELETE FROM fem_factor_table_dims
     WHERE object_definition_id = p_obj_def_id;

   END DeleteObjectDefinition;

  PROCEDURE VALIDATE_HIERARCHY (x_valid_flag OUT NOCOPY VARCHAR2,p_hier_obj_id IN NUMBER,p_dimension_id IN NUMBER) IS
   l_valid_flag varchar2(1);
   BEGIN
    select nvl((select 'Y' from FEM_HIERARCHIES where hierarchy_obj_id  = p_hier_obj_id and dimension_id = p_dimension_id),'N') into  l_valid_flag from dual;
    x_valid_flag := l_valid_flag;
  END VALIDATE_HIERARCHY;

  PROCEDURE VALIDATE_GROUP (x_valid_flag OUT NOCOPY VARCHAR2,p_hier_obj_id IN NUMBER,p_group_id IN NUMBER) IS
   l_valid_flag varchar2(1);
   BEGIN
    select nvl((select 'Y' from FEM_HIER_DIMENSION_GRPS where hierarchy_obj_id  = p_hier_obj_id and dimension_group_id = p_group_id),'N') into  l_valid_flag from dual;
    x_valid_flag := l_valid_flag;
  END VALIDATE_GROUP;

  PROCEDURE VALIDATE_DIM_MEMBER(x_valid_flag OUT NOCOPY VARCHAR2,p_hier_object_id IN NUMBER,p_group_id IN NUMBER,p_dimension_id IN NUMBER,p_member_id IN NUMBER) IS
   l_query varchar2(2000);
   l_main_query varchar2(2000);
   l_valid_flag varchar2(1);
   l_member_table_name varchar2(50);
   l_member_col varchar2(50);
   BEGIN

   if (p_hier_object_id is null OR length(trim(p_hier_object_id)) = 0) then
    x_valid_flag := 'Y';
    return;
   end if;

   select member_b_table_name,member_col into l_member_table_name,l_member_col from fem_xdim_dimensions where dimension_id = p_dimension_id;
   l_query := 'select ''Y'' from ' || l_member_table_name ||
            ' WHERE DIMENSION_GROUP_ID IN (SELECT DIMENSION_GROUP_ID FROM FEM_HIER_DIMENSION_GRPS WHERE HIERARCHY_OBJ_ID = ' || p_hier_object_id ||
            ') AND DIMENSION_GROUP_ID = ' || p_group_id ||
            ' AND ' || l_member_col || ' = ' || p_member_id ;

   l_main_query:= 'select nvl((' || l_query || '),''N'') from dual';
   execute immediate l_main_query into l_valid_flag;

   x_valid_flag := l_valid_flag;

  END VALIDATE_DIM_MEMBER;

  PROCEDURE GET_HIER_OBJ_DEF_ID(x_hier_obj_def_id OUT NOCOPY VARCHAR2,p_hier_obj_id IN VARCHAR2,p_hier_name IN VARCHAR2) IS
   l_hier_obj_def_id NUMBER;
   BEGIN

    select nvl((select object_definition_id from fem_object_definition_vl where object_id = p_hier_obj_id and display_name = p_hier_name),-1) into l_hier_obj_def_id from dual;
    x_hier_obj_def_id := l_hier_obj_def_id;

  END GET_HIER_OBJ_DEF_ID;
END fem_factor_tables_util_pkg;

/
