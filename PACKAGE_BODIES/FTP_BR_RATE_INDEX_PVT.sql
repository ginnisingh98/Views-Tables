--------------------------------------------------------
--  DDL for Package Body FTP_BR_RATE_INDEX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTP_BR_RATE_INDEX_PVT" AS
/* $Header: ftpbrrib.pls 120.1 2006/05/17 21:51:19 appldev noship $ */

--------------------------------------------------------------------------------
-- PRIVATE CONSTANTS
--------------------------------------------------------------------------------
G_PKG_NAME constant varchar2(30) := 'FTP_BR_RATE_INDEX_PVT';
--------------------------------------------------------------------------------
-- PRIVATE SPECIFICATIONS
--------------------------------------------------------------------------------
PROCEDURE DeleteRateIndexRuleRec(
  p_obj_def_id          in          number
);
PROCEDURE DeleteRIValuationCurveRecs(
  p_obj_def_id          in          number
);
PROCEDURE CopyRateIndexRuleRec(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);
PROCEDURE CopyRiValuationCurveRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);
--------------------------------------------------------------------------------
-- PUBLIC BODIES
--------------------------------------------------------------------------------
--
-- PROCEDURE
--       DeleteObjectDefinition
--
-- DESCRIPTION
--   Deletes all the details records of a Rate Index  Rule Definition.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteObjectDefinition(
  p_obj_def_id          in          number
)
--------------------------------------------------------------------------------
IS
  g_api_name    constant varchar2(30)   := 'DeleteObjectDefinition';
BEGIN
  DeleteRIValuationCurveRecs(
    p_obj_def_id     => p_obj_def_id
  );
  DeleteRateIndexRuleRec(
    p_obj_def_id     => p_obj_def_id
  );
EXCEPTION
  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, g_api_name);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
END DeleteObjectDefinition;
--
-- PROCEDURE
--       CopyObjectDefinition
--
-- DESCRIPTION
--   Creates all the detail records of a new Rate Index Rule Definition (target)
--   by copying the detail records of another Rate Index Rule Definition (source).
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyObjectDefinition(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
  g_api_name    constant varchar2(30)   := 'CopyObjectDefinition';
BEGIN
  CopyRateIndexRuleRec(
    p_source_obj_def_id   => p_source_obj_def_id
    ,p_target_obj_def_id  => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
);
  CopyRiValuationCurveRecs(
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
--------------------------------------------------------------------------------
-- PRIVATE BODIES
--------------------------------------------------------------------------------
--
-- PROCEDURE
--       DeleteRateIndexRuleRec
--
-- DESCRIPTION
--   Deletes a Rate Index Rule Definition by performing deletes on records
--   in the FTP_RATE_INDEX_RULE table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteRateIndexRuleRec(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS
BEGIN
  delete from ftp_rate_index_rule
  where object_definition_id = p_obj_def_id;
END DeleteRateIndexRuleRec;
--
-- PROCEDURE
--       DeleteRIValuationCurveRecs
--
-- DESCRIPTION
--   Deletes Rate Index Rule Definition records by performing deletes on records
--   in the FTP_RI_VALUATION_CURVE table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteRIValuationCurveRecs(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS
BEGIN
  delete from ftp_ri_valuation_curve
  where object_definition_id = p_obj_def_id;
END DeleteRIValuationCurveRecs;
--
-- PROCEDURE
--       CopyRateIndexRuleRec
--
-- DESCRIPTION
--   Creates a new Rate Index Rule Definition by copying records in the
--   FTP_RATE_INDEX_RULE table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyRateIndexRuleRec(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
BEGIN
  insert into ftp_rate_index_rule (
    object_definition_id
    ,currency
    ,interest_rate_code
    ,yield_cv_term
    ,yield_cv_term_mult
    ,element_number
    ,coefficient
    ,exponent
    ,val_yc_term
    ,val_yc_term_mult
    ,creation_date
    ,created_by
    ,last_updated_by
    ,last_update_date
    ,last_update_login
  ) select
    p_target_obj_def_id
     ,currency
     ,interest_rate_code
     ,yield_cv_term
     ,yield_cv_term_mult
     ,element_number
     ,coefficient
     ,exponent
     ,val_yc_term
     ,val_yc_term_mult
     ,nvl(p_creation_date,creation_date)
     ,nvl(p_created_by,created_by)
     ,FND_GLOBAL.user_id
     ,sysdate
     ,FND_GLOBAL.login_id
  from ftp_rate_index_rule
  where object_definition_id = p_source_obj_def_id;
END CopyRateIndexRuleRec;
--
-- PROCEDURE
--       CopyRiValuationCurveRecs
--
-- DESCRIPTION
--   Creates a new RI Valuation records by copying records in the
--   FTP_RI_VALUATION_CURVE table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyRiValuationCurveRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
BEGIN
  insert into ftp_ri_valuation_curve (
    object_definition_id
    ,currency
    ,interest_rate_code
    ,creation_date
    ,created_by
    ,last_updated_by
    ,last_update_date
    ,last_update_login
  ) select
    p_target_obj_def_id
    ,currency
    ,interest_rate_code
    ,nvl(p_creation_date,creation_date)
    ,nvl(p_created_by,created_by)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.login_id
  from ftp_ri_valuation_curve
  where object_definition_id = p_source_obj_def_id;
END CopyRiValuationCurveRecs;
END FTP_BR_RATE_INDEX_PVT;

/
