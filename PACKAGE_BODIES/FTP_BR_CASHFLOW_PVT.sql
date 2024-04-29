--------------------------------------------------------
--  DDL for Package Body FTP_BR_CASHFLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTP_BR_CASHFLOW_PVT" AS
/* $Header: ftpcflob.pls 120.0 2005/06/06 18:58:54 appldev noship $ */

G_PKG_NAME constant varchar2(30) := 'FTP_BR_CASHFLOW_PVT';

------------------------------------------------------------
-- PRIVATE SPECS
------------------------------------------------------------

PROCEDURE DeleteCorrectionProcRuleRecs(
  p_obj_def_id          in          number
);

PROCEDURE DeleteCorrectionProcTblsRecs(
  p_obj_def_id          in          number
);

PROCEDURE CopyCorrectionProcRuleRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);
PROCEDURE CopyCorrectionProcTblsRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);

----------------------------------------
-- PUBLIC BODIES ------
----------------------------------------

---------------------------------------------------------------------
-- Deletes all the details records of a Cash Flow Table Definition.
---------------------------------------------------------------------

PROCEDURE DeleteObjectDefinition(
  p_obj_def_id          in          number
)
IS

  g_api_name    constant varchar2(30)   := 'DeleteObjectDefinition';

BEGIN
  DeleteCorrectionProcRuleRecs(
    p_obj_def_id    => p_obj_def_id
  );

  DeleteCorrectionProcTblsRecs(
    p_obj_def_id    => p_obj_def_id
  );

EXCEPTION

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, g_api_name);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

END DeleteObjectDefinition;



----------------------------------------------------------------------------
-- Creates all the detail records of a new Cash Flow Table Rule Definition (target)
-- by copying the detail records of another Cash Flow Table Rule Definition (source).
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

  g_api_name    constant varchar2(30) := 'CopyObjectDefinition';

BEGIN

  CopyCorrectionProcRuleRecs(
    p_source_obj_def_id   => p_source_obj_def_id
    ,p_target_obj_def_id  => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
  );

  CopyCorrectionProcTblsRecs(
    p_source_obj_def_id   => p_source_obj_def_id
    ,p_target_obj_def_id  => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
  );

EXCEPTION

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, g_api_name);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

END CopyObjectDefinition;



----------------------------------------
-- PRIVATE BODIES ----------------------
----------------------------------------

--------------------------------------------------------------------------------
PROCEDURE DeleteCorrectionProcRuleRecs(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS
BEGIN

  delete from ftp_correction_proc_rule
  where object_definition_id = p_obj_def_id;

END DeleteCorrectionProcRuleRecs;



--------------------------------------------------------------------------------
PROCEDURE DeleteCorrectionProcTblsRecs(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS
BEGIN

  delete from ftp_correction_proc_tbls
  where object_definition_id = p_obj_def_id;

END DeleteCorrectionProcTblsRecs;





--------------------------------------------------------------------------------
PROCEDURE CopyCorrectionProcRuleRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
BEGIN
  insert into ftp_correction_proc_rule (
    OBJECT_DEFINITION_ID
    ,FILTER_OBJECT_ID
    ,CREATION_DATE
    ,CREATED_BY
    ,LAST_UPDATED_BY
    ,LAST_UPDATE_DATE
    ,LAST_UPDATE_LOGIN
    ,PREVIEW_FLAG
  ) select
    p_target_obj_def_id
    ,FILTER_OBJECT_ID
    ,nvl(p_creation_date,creation_date)
    ,nvl(p_created_by,created_by)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.user_id
    ,PREVIEW_FLAG
  from ftp_correction_proc_rule
  where object_definition_id = p_source_obj_def_id;

END CopyCorrectionProcRuleRecs;


--
-- PROCEDURE
--	 CopyCorrectionProcTblsRecs
--
-- DESCRIPTION
--   Creates a new Cash Flow Edits Definition records by copying records in the
--   ftp_correction_proc_tbls table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyCorrectionProcTblsRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
BEGIN

  insert into ftp_correction_proc_tbls (
    OBJECT_DEFINITION_ID
    ,TABLE_NAME
    ,CREATION_DATE
    ,CREATED_BY
    ,LAST_UPDATED_BY
    ,LAST_UPDATE_DATE
    ,LAST_UPDATE_LOGIN
  ) select
    p_target_obj_def_id
    ,TABLE_NAME
    ,nvl(p_creation_date,creation_date)
    ,nvl(p_created_by,created_by)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.user_id
  from ftp_correction_proc_tbls
  where OBJECT_DEFINITION_ID = p_source_obj_def_id;

END CopyCorrectionProcTblsRecs;


END FTP_BR_CASHFLOW_PVT;

/
