--------------------------------------------------------
--  DDL for Package Body FTP_BR_TRANSFER_PRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTP_BR_TRANSFER_PRICE_PVT" AS
/* $Header: ftptprub.pls 120.0 2005/06/06 19:20:40 appldev noship $ */
--------------------------------------------------------------------------------
-- PRIVATE CONSTANTS
--------------------------------------------------------------------------------

G_PKG_NAME constant varchar2(30) := 'FTP_BR_TRANSFER_PRICE_PVT';

--------------------------------------------------------------------------------
-- PRIVATE SPECIFICATIONS
--------------------------------------------------------------------------------

PROCEDURE DeleteTransferPriceRuleRec(
  p_obj_def_id          in          number
);

PROCEDURE DeleteUnpricedAccountRecs(
  p_obj_def_id          in          number
);

PROCEDURE DeleteRedemptionCurveRecs(
  p_obj_def_id          in          number
);

PROCEDURE DeleteConditionRecs(
  p_obj_def_id          in          number
);

PROCEDURE CopyTransferPriceRuleRec(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);

PROCEDURE CopyUnpricedAccountRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);

PROCEDURE CopyRedemptionCurveRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);

PROCEDURE CopyConditionRecs(
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
--	 DeleteObjectDefinition
--
-- DESCRIPTION
--   Deletes all the details records of a Transfer Price Rule Definition.
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

  DeleteUnpricedAccountRecs(
    p_obj_def_id     => p_obj_def_id
  );

  DeleteRedemptionCurveRecs(
    p_obj_def_id     => p_obj_def_id
  );

  DeleteConditionRecs(
    p_obj_def_id     => p_obj_def_id
  );

  DeleteTransferPriceRuleRec(
    p_obj_def_id     => p_obj_def_id
  );

EXCEPTION

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, g_api_name);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

END DeleteObjectDefinition;


--
-- PROCEDURE
--	 CopyObjectDefinition
--
-- DESCRIPTION
--   Creates all the detail records of a new Transfer Price Rule Definition (target)
--   by copying the detail records of another Transfer Price Rule Definition (source).
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

  CopyTransferPriceRuleRec(
    p_source_obj_def_id   => p_source_obj_def_id
    ,p_target_obj_def_id  => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
  );

  CopyUnpricedAccountRecs(
    p_source_obj_def_id   => p_source_obj_def_id
    ,p_target_obj_def_id  => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
  );

  CopyRedemptionCurveRecs(
    p_source_obj_def_id   => p_source_obj_def_id
    ,p_target_obj_def_id  => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
  );

  CopyConditionRecs(
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
--	 DeleteTransferPriceRuleRec
--
-- DESCRIPTION
--   Deletes a Transfer Price Rule Definition by performing deletes on records
--   in the FTP_TRANSFER_PRICE_RULE table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteTransferPriceRuleRec(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS
BEGIN

  delete from ftp_transfer_price_rule
  where object_definition_id = p_obj_def_id;

END DeleteTransferPriceRuleRec;


--
-- PROCEDURE
--	 DeleteUnpricedAccountRecs
--
-- DESCRIPTION
--   Deletes Transfer Price Rule Definition records by performing deletes on records
--   in the FTP_TP_UNPRICED_ACCT_DTL table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteUnpricedAccountRecs(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS
BEGIN

  delete from ftp_tp_unpriced_acct_dtl
  where object_definition_id = p_obj_def_id;

END DeleteUnpricedAccountRecs;


--
-- PROCEDURE
--	 DeleteRedemptionCurveRecs
--
-- DESCRIPTION
--   Deletes Transfer Price Rule Definition records by performing deletes on records
--   in the FTP_TP_REDEMPT_CURVE_DTL table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteRedemptionCurveRecs(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS
BEGIN

  delete from ftp_tp_redempt_curve_dtl
  where object_definition_id = p_obj_def_id;

END DeleteRedemptionCurveRecs;


--
-- PROCEDURE
--	 DeleteConditionRecs
--
-- DESCRIPTION
--   Deletes Transfer Price Rule Definition records by performing deletes on records

--   in the FTP_TP_PP_CONDITIONS table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteConditionRecs(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS
BEGIN

  delete from ftp_tp_pp_conditions
  where object_definition_id = p_obj_def_id;

END DeleteConditionRecs;


--
-- PROCEDURE
--	 CopTransferPriceRuleRec
--
-- DESCRIPTION
--   Creates a new Transfer Price Rule Definition by copying records in the
--   FTP_TRANSFER_PRICE_RULE table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyTransferPriceRuleRec(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
BEGIN

  insert into ftp_transfer_price_rule (
    object_definition_id
    ,line_item_id
    ,currency
    ,cond_sequence
    ,data_source_code
    ,tp_calc_method_code
    ,gross_rate_flg
    ,interest_rate_code
    ,yield_curve_term
    ,yield_curve_mult
    ,historical_term
    ,historical_mult
    ,assignment_date_code
    ,option_cost_method_code
    ,target_bal_code
    ,rate_spread
    ,lag_term
    ,lag_mult
    ,across_org_unit_flg
    ,mid_period_reprice_flg
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
  ) select
    p_target_obj_def_id
    ,line_item_id
    ,currency
    ,cond_sequence
    ,data_source_code
    ,tp_calc_method_code
    ,gross_rate_flg
    ,interest_rate_code
    ,yield_curve_term
    ,yield_curve_mult
    ,historical_term
    ,historical_mult
    ,assignment_date_code
    ,option_cost_method_code
    ,target_bal_code
    ,rate_spread
    ,lag_term
    ,lag_mult
    ,across_org_unit_flg
    ,mid_period_reprice_flg
    ,nvl(p_created_by,created_by)
    ,nvl(p_creation_date,creation_date)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.login_id
  from ftp_transfer_price_rule
  where object_definition_id = p_source_obj_def_id;

END CopyTransferPriceRuleRec;


--
-- PROCEDURE
--	 CopyUnpricedAccountRecs
--
-- DESCRIPTION
--   Creates a new Transfer Price Rule Definition records by copying records in the
--   FTP_TP_UNPPRICED_ACCT_DTL table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyUnpricedAccountRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
BEGIN

  insert into ftp_tp_unpriced_acct_dtl (
    object_definition_id
    ,line_item_id
    ,currency
    ,cond_sequence
    ,source_line_item_id
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
  ) select
    p_target_obj_def_id
    ,line_item_id
    ,currency
    ,cond_sequence
    ,source_line_item_id
    ,nvl(p_created_by,created_by)
    ,nvl(p_creation_date,creation_date)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.login_id
  from ftp_tp_unpriced_acct_dtl
  where object_definition_id = p_source_obj_def_id;

END CopyUnpricedAccountRecs;




--
-- PROCEDURE
--	 CopyRedemptionCurveRecs
--
-- DESCRIPTION
--   Creates a new Transfer Price Rule Definition records by copying records in the
--   FTP_TP_REDEMPT_CURVE_DTL table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyRedemptionCurveRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
BEGIN

  insert into ftp_tp_redempt_curve_dtl (
    object_definition_id
    ,line_item_id
    ,currency
    ,cond_sequence
    ,interest_rate_code
    ,interest_rate_term
    ,interest_rate_term_mult
    ,percentage
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
  ) select
    p_target_obj_def_id
    ,line_item_id
    ,currency
    ,cond_sequence
    ,interest_rate_code
    ,interest_rate_term
    ,interest_rate_term_mult
    ,percentage
    ,nvl(p_created_by,created_by)
    ,nvl(p_creation_date,creation_date)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.login_id
  from ftp_tp_redempt_curve_dtl
  where object_definition_id = p_source_obj_def_id;

END CopyRedemptionCurveRecs;


--
-- PROCEDURE
--	 CopyConditionRecs
--
-- DESCRIPTION
--   Creates a new Transfer Price Rule Definition records by copying records in the
--   FTP_TP_PP_CONDITIONS table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyConditionRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
BEGIN

  insert into ftp_tp_pp_conditions (
    object_definition_id
    ,line_item_id
    ,currency
    ,cond_sequence
    ,cond_order
    ,level_num
    ,table_name
    ,column_name
    ,column_data_type
    ,compare_type
    ,comparator
    ,logical
    ,r_from
    ,r_to
    ,left_paren
    ,right_paren
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
  ) select
    p_target_obj_def_id
    ,line_item_id
    ,currency
    ,cond_sequence
    ,cond_order
    ,level_num
    ,table_name
    ,column_name
    ,column_data_type
    ,compare_type
    ,comparator
    ,logical
    ,r_from
    ,r_to
    ,left_paren
    ,right_paren
    ,nvl(p_created_by,created_by)
    ,nvl(p_creation_date,creation_date)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.login_id
  from ftp_tp_pp_conditions
  where object_definition_id = p_source_obj_def_id;

END CopyConditionRecs;

END FTP_BR_TRANSFER_PRICE_PVT;


/
