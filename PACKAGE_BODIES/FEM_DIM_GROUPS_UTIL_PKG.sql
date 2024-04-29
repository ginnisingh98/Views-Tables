--------------------------------------------------------
--  DDL for Package Body FEM_DIM_GROUPS_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_DIM_GROUPS_UTIL_PKG" AS
/* $Header: fem_dimgrp_utl.plb 120.2 2005/07/21 10:09:30 appldev ship $ */
/*=======================================================================+
Copyright (c) 1995 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME
 |   fem_dimgrp_utl.plb
 |
 | DESCRIPTION
 |   Utility package for Dimension Groups (also known as "levels")
 |
 | MODIFICATION HISTORY
 |   Robert Flippo       06/03/2005 Created
 |   Robert Flippo       07/14/2005 Bug#4494300 OA Compliance issues
 |   Robert Flippo       07/20/2005 Bug#4504983 Changes requested by OGL
 |
 *=======================================================================*/

/* ***********************
** Package constants
** ***********************/


/* ***********************
** Package variables
** ***********************/
--dbms_utility.format_call_stack                 VARCHAR2(2000);

/* ***********************
** Package exceptions
** ***********************/

gv_prg_msg      VARCHAR2(2000);
gv_callstack    VARCHAR2(2000);


/*===========================================================================+
 | PROCEDURE
 |              Create_dim_group
 |
 | DESCRIPTION
 |                 Creates a new dimension group or returns the identifier
 |                 for an existing group if the input parameters
 |                 match an existing group
 |
 | SCOPE - PRIVATE
 |
 |
 | NOTES
 |   API logic is:
 |     IF user passes in a dimension group display_code that already
 |     exists the API returns the dimension_group_id and dimension_grp_seq
 |     for that group.  This is true even when the user provides a sequence
 |     as an input parameter that is different than the dim grp sequence
 |     of the existing group.
 |
 |     If the dimension group display code does not exist for that dimension,
 |     the API will create it.  If the user passes in a sequence that is already
 |     in use, the API will return an error.  If the user passes in a sequence
 |     that is not in use, or passes in null for the sequence, the API will
 |     create the group.  When null is passed in, it uses max+10 of the
 |     existing dimension group for that dimension as the value for the
 |     sequence.
 |
 | MODIFICATION HISTORY
 |   Rob Flippo  06/03/2005   Created
 |   Rob Flippo  07/20/2005   Bug#4504983 Changes requested by OGL
 +===========================================================================*/

PROCEDURE create_dim_group (x_dimension_group_id            OUT NOCOPY NUMBER
                           ,x_dim_group_sequence            OUT NOCOPY NUMBER
                           ,x_msg_count                     OUT NOCOPY NUMBER
                           ,x_msg_data                      OUT NOCOPY VARCHAR2
                           ,x_return_status                 OUT NOCOPY VARCHAR2
                           ,p_api_version                   IN  NUMBER     DEFAULT 1.0
                           ,p_init_msg_list                 IN  VARCHAR2   DEFAULT pc_false
                           ,p_commit                        IN  VARCHAR2   DEFAULT pc_false
                           ,p_encoded                       IN  VARCHAR2   DEFAULT pc_true
                           ,p_dimension_varchar_label       IN  VARCHAR2
                           ,p_dim_group_display_code        IN  VARCHAR2
                           ,p_dim_group_name                IN  VARCHAR2
                           ,p_dim_group_description         IN  VARCHAR2
                           ,p_dim_group_sequence            IN  NUMBER DEFAULT NULL
                           ,p_time_group_type_code          IN  VARCHAR2 DEFAULT NULL)
IS

c_api_name  CONSTANT VARCHAR2(30) := 'create_dim_group';
c_api_version  CONSTANT NUMBER := 1.0;
v_rowid VARCHAR2(100);
v_count NUMBER;

v_dimension_id                 NUMBER;
v_time_dimension_group_key     NUMBER;


-- Exceptions
e_invalid_dimension  EXCEPTION;
e_duplicate_display_code  EXCEPTION;
e_duplicate_name EXCEPTION;
e_duplicate_dimgrp_seq EXCEPTION;
e_invalid_time_group_type EXCEPTION;
e_dimgrp_already_exists EXCEPTION;


   BEGIN

      fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
      p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
      p_msg_text => 'Begin. '||
      ' P_DIMENSION_VARCHAR_LABEL:'||p_dimension_varchar_label||
      ' P_DIM_GROUP_DISPLAY_CODE:'||p_dim_group_display_code||
      ' P_DIM_GROUP_NAME:'||p_dim_group_name||
      ' P_DIM_GROUP_DESCRIPTION:'||p_dim_group_description||
      ' P_DIM_GROUP_SEQUENCE:'||p_dim_group_sequence||
      ' P_TIME_GROUP_TYPE_CODE:'||p_time_group_type_code||
      ' P_COMMIT: '||p_commit);

      /* Standard Start of API savepoint */
       SAVEPOINT  create_dim_group_pub;

      /* Standard call to check for call compatibility. */
      IF NOT FND_API.Compatible_API_Call (c_api_version,
                     p_api_version,
                     c_api_name,
                     pc_pkg_name)
      THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      /* Initialize API return status to success */
      x_return_status := pc_ret_sts_success;
      ---------------------------
      -- Verify the OA parameters
      ---------------------------
      FEM_Dimension_Util_Pkg.Validate_OA_Params (
         p_api_version => c_api_version,
         p_init_msg_list => p_init_msg_list,
         p_commit => p_commit,
         p_encoded => p_encoded,
         x_return_status => x_return_status);

      IF (x_return_status <> pc_ret_sts_success)
      THEN
         FND_MSG_PUB.Count_and_Get(
            p_encoded => pc_false,
            p_count => x_msg_count,
            p_data => x_msg_data);
      END IF;

      /* Validate that the Dimension Varchar Label support Dimension Groups */
      BEGIN
         SELECT B.dimension_id
         INTO v_dimension_id
         FROM fem_dimensions_b B, fem_xdim_dimensions X
         WHERE B.dimension_varchar_label = p_dimension_varchar_label
         AND B.dimension_id = X.dimension_id
         AND X.group_use_code IN ('OPTIONAL','REQUIRED');

      EXCEPTION
         WHEN no_data_found THEN
            RAISE e_invalid_dimension;
      END;

      /* check to see if there is an existing dimension_group
         for the specified dimension, display_code */
      BEGIN
         SELECT dimension_group_id,dimension_group_seq
         INTO x_dimension_group_id, x_dim_group_sequence
         FROM fem_dimension_grps_b
         WHERE dimension_id = v_dimension_id
         AND dimension_group_display_code = p_dim_group_display_code;

         IF x_dimension_group_id IS NOT NULL THEN
            RAISE e_dimgrp_already_exists;
         END IF;
       EXCEPTION
          WHEN no_data_found THEN null;
       END;

      /* Validate that the Dimension Group Name does not already exist
         in any language for the specified dimension*/
      SELECT count(*)
      INTO v_count
      FROM fem_dimension_grps_tl
      WHERE dimension_group_name = p_dim_group_name
      AND dimension_id = v_dimension_id;

      IF v_count > 0 THEN
         RAISE e_duplicate_name;
      END IF;  /* duplicate_name validation */

      /* Validate that the Dimension Group Sequence does not already exist
         for the specified dimension*/
      IF p_dim_group_sequence IS NOT NULL THEN
         SELECT count(*)
         INTO v_count
         FROM fem_dimension_grps_b
         WHERE dimension_group_seq = p_dim_group_sequence
         AND dimension_id = v_dimension_id;

         IF v_count > 0 THEN
            RAISE e_duplicate_dimgrp_seq;
         END IF;  /* duplicate_dimgrp_seq */
      END IF;

      /* For CAL_PERIOD dimension, verify that the TIME_GROUP_TYPE_CODE exists
         and get the time dimension group key sequence number*/
      IF p_dimension_varchar_label = 'CAL_PERIOD' THEN
         SELECT count(*)
         INTO v_count
         FROM fem_time_group_types_b
         WHERE time_group_type_code = p_time_group_type_code
         AND ENABLED_FLAG = 'Y'
         AND PERSONAL_FLAG = 'N';

         IF v_count = 0 THEN
            RAISE e_invalid_time_group_type;
         ELSE
            SELECT fem_time_dimension_group_key_s.nextval
            INTO v_time_dimension_group_key
            FROM dual;
         END IF;  /* time group type validation */
      END IF;

      SELECT fem_dimension_grps_b_s.nextval
      INTO x_dimension_group_id
      FROM dual;


      -- Get the next dimension_group_seq value if the user passes in null
      IF p_dim_group_sequence IS NULL THEN
         SELECT nvl(max(dimension_group_seq)+100,1000)
         INTO x_dim_group_sequence
         FROM fem_dimension_grps_b
         WHERE dimension_id = v_dimension_id;
      ELSE x_dim_group_sequence := p_dim_group_sequence;
      END IF;

      FEM_DIMENSION_GRPS_PKG.INSERT_ROW(
         X_ROWID => v_rowid
        ,X_DIMENSION_GROUP_ID => x_dimension_group_id
        ,X_TIME_DIMENSION_GROUP_KEY => v_time_dimension_group_key
        ,X_DIMENSION_ID => v_dimension_id
        ,X_DIMENSION_GROUP_SEQ => x_dim_group_sequence
        ,X_TIME_GROUP_TYPE_CODE => p_time_group_type_code
        ,X_READ_ONLY_FLAG => 'N'
        ,X_OBJECT_VERSION_NUMBER => 1
        ,X_PERSONAL_FLAG => 'N'
        ,X_ENABLED_FLAG => 'Y'
        ,X_DIMENSION_GROUP_DISPLAY_CODE => p_dim_group_display_code
        ,X_DIMENSION_GROUP_NAME => p_dim_group_name
        ,X_DESCRIPTION  => p_dim_group_description
        ,X_CREATION_DATE => sysdate
        ,X_CREATED_BY => pc_user_id
        ,X_LAST_UPDATE_DATE => sysdate
        ,X_LAST_UPDATED_BY => pc_user_id
        ,X_LAST_UPDATE_LOGIN => pc_last_update_login);


      IF FND_API.To_Boolean( p_commit ) THEN
         COMMIT WORK;
      END IF;


   EXCEPTION
      WHEN e_dimgrp_already_exists THEN null;


      WHEN e_invalid_dimension THEN
         ROLLBACK TO create_dim_group_pub;
         x_return_status := pc_ret_sts_error;
         x_dimension_group_id := -1;
         x_dim_group_sequence := -1;

         fem_engines_pkg.put_message(p_app_name =>'FEM'
         ,p_msg_name =>'FEM_DIMGRP_UTIL_INVALID_DIM'
         ,p_token1 => 'DIM_LABEL'
         ,p_value1 => p_dimension_varchar_label);

         FND_MSG_PUB.Count_And_Get
            (p_encoded => p_encoded,
             p_count => x_msg_count,
             p_data => x_msg_data);

      WHEN e_duplicate_display_code THEN
         ROLLBACK TO create_dim_group_pub;
         x_return_status := pc_ret_sts_error;
         fem_engines_pkg.put_message(p_app_name =>'FEM'
         ,p_msg_name =>'FEM_DIMGRP_UTIL_DUP_DC'
         ,p_token1 => 'DISPLAY_CODE'
         ,p_value1 => p_dim_group_display_code
         ,p_token2 => 'DIM_LABEL'
         ,p_value2 => p_dimension_varchar_label);

         FND_MSG_PUB.Count_And_Get
            (p_encoded => p_encoded,
             p_count => x_msg_count,
             p_data => x_msg_data);

      WHEN e_duplicate_name THEN
         ROLLBACK TO create_dim_group_pub;
         x_return_status := pc_ret_sts_error;
         x_dimension_group_id := -1;
         x_dim_group_sequence := -1;

         fem_engines_pkg.put_message(p_app_name =>'FEM'
         ,p_msg_name =>'FEM_DIMGRP_UTIL_DUP_NAME'
         ,p_token1 => 'NAME'
         ,p_value1 => p_dim_group_name
         ,p_token2 => 'DIM_LABEL'
         ,p_value2 => p_dimension_varchar_label);

         FND_MSG_PUB.Count_And_Get
            (p_encoded => p_encoded,
             p_count => x_msg_count,
             p_data => x_msg_data);

      WHEN e_duplicate_dimgrp_seq THEN
         ROLLBACK TO create_dim_group_pub;
         x_return_status := pc_ret_sts_error;
         x_dimension_group_id := -1;
         x_dim_group_sequence := -1;

         fem_engines_pkg.put_message(p_app_name =>'FEM'
         ,p_msg_name =>'FEM_DIMGRP_UTIL_DUP_SEQ'
         ,p_token1 => 'SEQUENCE'
         ,p_value1 => p_dim_group_sequence
         ,p_token2 => 'DIM_LABEL'
         ,p_value2 => p_dimension_varchar_label);

         FND_MSG_PUB.Count_And_Get
            (p_encoded => p_encoded,
             p_count => x_msg_count,
             p_data => x_msg_data);

      WHEN e_invalid_time_group_type THEN
         ROLLBACK TO create_dim_group_pub;
         x_return_status := pc_ret_sts_error;
         fem_engines_pkg.put_message(p_app_name =>'FEM'
         ,p_msg_name =>'FEM_DIMGRP_UTIL_INVALID_TIMGRP'
         ,p_token1 => 'TIME_GROUP'
         ,p_value1 => p_time_group_type_code);

         FND_MSG_PUB.Count_And_Get
            (p_encoded => p_encoded,
             p_count => x_msg_count,
             p_data => x_msg_data);


      WHEN OTHERS THEN
      /* Unexpected exceptions */
         x_return_status := pc_ret_sts_unexp_error;
         gv_prg_msg   := gv_prg_msg;
         gv_callstack := gv_callstack;

      /* Log the call stack and the Oracle error message to
      ** FND_LOG with the "unexpected exception" severity level. */

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => gv_prg_msg);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => gv_callstack);

      /* Log the Oracle error message to the stack. */
         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UNEXPECTED_ERROR',
            P_TOKEN1 => 'ERR_MSG',
            P_VALUE1 => gv_prg_msg);
         ROLLBACK TO create_dim_group_pub;

         FND_MSG_PUB.Count_And_Get
            (p_encoded => p_encoded,
             p_count => x_msg_count,
             p_data => x_msg_data);

END create_dim_group;


END FEM_DIM_GROUPS_UTIL_PKG;

/
