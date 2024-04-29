--------------------------------------------------------
--  DDL for Package Body FTP_BR_ROM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTP_BR_ROM_PVT" AS
/* $Header: ftpromb.pls 120.0.12000000.1 2007/07/27 12:08:24 shishank noship $ */


G_PKG_NAME constant varchar2(30) := 'FTP_BR_ROM_PVT';


---------------------------------------------------------------------
-- Deletes all the details records of a Prepayment Table Definition.
---------------------------------------------------------------------

PROCEDURE DeleteObjectDefinition(
  p_obj_def_id          in          number
)
IS

  g_api_name    constant varchar2(30)   := 'DeleteObjectDefinition';

BEGIN

	DELETE FROM FTP_RATE_OUTPUT_MAPPING_RULE
	WHERE object_definition_id = p_obj_def_id;

EXCEPTION

  WHEN OTHERS THEN
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, g_api_name);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

END DeleteObjectDefinition;



----------------------------------------------------------------------------
-- Creates all the detail records of a new Prepayment Table Rule Definition (target)
-- by copying the detail records of another Prepayment Table Rule Definition (source).
--
-- IN Parameters
-- p_source_obj_def_id    - Source Object Definition ID.
-- p_target_obj_def_id    - Target Object Definition ID.
-- p_created_by           - FND User ID (optional).
-- p_creation_date        - System Date (optional).
----------------------------------------------------------------------------
PROCEDURE CopyObjectDefinition(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
IS

  g_api_name    constant varchar2(30)   := 'CopyObjectDefinition';

BEGIN

  INSERT INTO FTP_RATE_OUTPUT_MAPPING_RULE  (
    OBJECT_DEFINITION_ID,
    FTP_ACCOUNT_TABLE_NAME,
    TRANSFER_RATE_COL_NAME,
    MATCHED_SPREAD_COL_NAME,
    REMAINING_TERM_COL_NAME,
    HIST_OAS_COL_NAME,
    HIST_STAT_SPREAD_COL_NAME,
    CUR_OAS_COL_NAME,
    CUR_STAT_SPREAD_COL_NAME,
    ADJUSTMENT_SPRD_COL_NAME,
    ADJUSTMENT_AMOUNT_COL_NAME,
    SELECT_ALL_TABS_FLG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
     )
    SELECT
    p_target_obj_def_id,
    FTP_ACCOUNT_TABLE_NAME,
    TRANSFER_RATE_COL_NAME,
    MATCHED_SPREAD_COL_NAME,
    REMAINING_TERM_COL_NAME,
    HIST_OAS_COL_NAME,
    HIST_STAT_SPREAD_COL_NAME,
    CUR_OAS_COL_NAME,
    CUR_STAT_SPREAD_COL_NAME,
    ADJUSTMENT_SPRD_COL_NAME,
    ADJUSTMENT_AMOUNT_COL_NAME,
    SELECT_ALL_TABS_FLG,
    NVL(p_creation_date,CREATION_DATE),
    NVL(p_created_by,CREATED_BY),
    FND_GLOBAL.user_id,
    SYSDATE,
    FND_GLOBAL.login_id
  FROM FTP_RATE_OUTPUT_MAPPING_RULE
  WHERE OBJECT_DEFINITION_ID = p_source_obj_def_id;

EXCEPTION

  WHEN OTHERS THEN
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, g_api_name);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

END CopyObjectDefinition;


END FTP_BR_ROM_PVT;


/
