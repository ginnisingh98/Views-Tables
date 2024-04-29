--------------------------------------------------------
--  DDL for Package Body FEM_BR_STAT_LOOKUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_BR_STAT_LOOKUP_PVT" AS
/* $Header: FEMVSTATLKPB.pls 120.0 2006/06/29 09:06:26 asadadek noship $ */

G_PKG_NAME constant varchar2(30) := 'FEM_BR_STAT_LOOKUP_PVT';


PROCEDURE DeleteObjectDefinition(p_obj_def_id NUMBER) IS
BEGIN

    -- First delete the Lookup join.
     DELETE FROM fem_stat_lookup_rel WHERE STAT_LOOKUP_OBJ_DEF_ID = p_obj_def_id;
    --Then delete the Lookup Details.
     DELETE FROM fem_stat_lookups WHERE STAT_LOOKUP_OBJ_DEF_ID = p_obj_def_id;

EXCEPTION

  WHEN others THEN
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'DeleteObjectDefinition');
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END;


PROCEDURE CopyObjectDefinition(p_source_obj_def_id  IN NUMBER,
                               p_target_obj_def_id  IN NUMBER,
                               p_created_by         IN NUMBER,
                               p_creation_date      IN DATE) IS
BEGIN
    --First copy the Lookup Details.
    INSERT INTO fem_stat_lookups( stat_lookup_obj_def_id,
                                  stat_lookup_table,
                                  related_to_table,
                                  stat_lookup_column,
                                  condition_obj_def_id,
                                  created_by,
                                  creation_date,
                                  last_updated_by,
                                  last_update_date,
                                  last_update_login,
                                  object_version_number)
                                  SELECT p_target_obj_def_id,
                                         stat_lookup_table,
                                         related_to_table,
                                         stat_lookup_column,
                                         condition_obj_def_id,
                                         p_created_by,
                                         p_creation_date,
                                         FND_GLOBAL.user_id,
                                         SYSDATE,
                                         FND_GLOBAL.login_id,
                                         0
                                  FROM fem_stat_lookups
                                  WHERE stat_lookup_obj_def_id = p_source_obj_def_id;

    --Thereafter join the Lookup Join.
     INSERT INTO fem_stat_lookup_rel( stat_lookup_obj_def_id,
                                      stat_lookup_tbl_col,
                                      relational_operand,
                                      related_to_tbl_col,
                                      value,
                                      created_by,
                                      creation_date,
                                      last_updated_by,
                                      last_update_date,
                                      last_update_login,
                                      object_version_number)
                                  SELECT p_target_obj_def_id,
                                         stat_lookup_tbl_col,
                                         relational_operand,
                                         related_to_tbl_col,
                                         value,
                                         p_created_by,
                                         p_creation_date,
                                         FND_GLOBAL.user_id,
                                         SYSDATE,
                                         FND_GLOBAL.login_id,
                                         0
                                  FROM fem_stat_lookup_rel
                                  WHERE stat_lookup_obj_def_id = p_source_obj_def_id;

EXCEPTION

  WHEN others THEN
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'CopyObjectDefinition');
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END;


END fem_br_stat_lookup_pvt;

/
