--------------------------------------------------------
--  DDL for Package Body FTP_BR_PREPAYMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTP_BR_PREPAYMENT_PVT" AS
/* $Header: ftpbppab.pls 120.1 2005/10/24 03:24:12 appldev noship $ */

G_PKG_NAME constant varchar2(30) := 'FTP_BR_PREPAYMENT_PVT';

--------------------------------------------------------------------------------
-- PRIVATE SPECS
--------------------------------------------------------------------------------

PROCEDURE DeletePrepaymentAssumptionRecs(
  p_obj_def_id          in          number
);

PROCEDURE DeleteRateDefinitionRecs(
  p_obj_def_id          in          number
);

PROCEDURE DeleteConditionRecs(
  p_obj_def_id          in          number
);

PROCEDURE CopyPrepaymentAssumptionRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);

PROCEDURE CopyRateDefinitionRecs(
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
----------------------------------------
-- PUBLIC BODIES ------
----------------------------------------

---------------------------------------------------------------------
-- Deletes all the details records of a Prepayment Table Definition.
---------------------------------------------------------------------

PROCEDURE DeleteObjectDefinition(
  p_obj_def_id          in          number
)
IS

  g_api_name    constant varchar2(30)   := 'DeleteObjectDefinition';

BEGIN
  DeletePrepaymentAssumptionRecs(
    p_obj_def_id    => p_obj_def_id
  );

  DeleteRateDefinitionRecs(
    p_obj_def_id    => p_obj_def_id
  );

 DeleteConditionRecs(
    p_obj_def_id     => p_obj_def_id
  );

EXCEPTION

  when others then
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

  CopyPrepaymentAssumptionRecs(
    p_source_obj_def_id   => p_source_obj_def_id
    ,p_target_obj_def_id  => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
    --,x_target_ppr_assumption_id
  );

  CopyRateDefinitionRecs(
    p_source_obj_def_id   => p_source_obj_def_id
    ,p_target_obj_def_id  => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
    --,p_target_ppr_assumption_id => p_target_ppr_assumption_id
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



----------------------------------------
-- PRIVATE BODIES ----------------------
----------------------------------------

--
-- PROCEDURE
--       DeletePrepaymentAssumptionRecs
--
-- DESCRIPTION
--   Deletes a Prepayment Rule Definition by performing deletes on records
--   in the FTP_PREPAYMENT_RULE table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeletePrepaymentAssumptionRecs(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS
BEGIN

  delete from ftp_prepayment_rule
  where object_definition_id = p_obj_def_id;

END DeletePrepaymentAssumptionRecs;


--
-- PROCEDURE
--       DeleteUnpricedAccountRecs
--
-- DESCRIPTION
--   Deletes Prepayment Rule Definition records by performing deletes on records
--   in the FTP_PP_ORGDATE_ASSUMP table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteRateDefinitionRecs(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS
BEGIN

  delete from ftp_pp_orgdate_assump
  where object_definition_id = p_obj_def_id;

END DeleteRateDefinitionRecs;


--
-- PROCEDURE
--       DeleteConditionRecs
--
-- DESCRIPTION
--   Deletes Prepayment Rule Definition records by performing deletes on records

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
--       CopTransferPriceRuleRec
--
-- DESCRIPTION
--   Creates a new Prepayment Rule Definition by copying records in the
--   FTP_PREPAYMENT_RULE table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyPrepaymentAssumptionRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS

BEGIN

  insert into ftp_prepayment_rule (
    object_definition_id
    ,line_item_id
    ,currency
    ,cond_sequence
    ,calc_method_code
    ,portfolio_flg
    ,quote_code
    ,rate_term_code
    ,interest_rate_code
    ,seasonality_flg
    ,rate_spread
    ,jan_coeff
    ,feb_coeff
    ,mar_coeff
    ,apr_coeff
    ,may_coeff
    ,jun_coeff
    ,jul_coeff
    ,aug_coeff
    ,sep_coeff
    ,oct_coeff
    ,nov_coeff
    ,dec_coeff
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,ppr_assumption_id
  ) select
    p_target_obj_def_id
    ,line_item_id
    ,currency
    ,cond_sequence
    ,calc_method_code
    ,portfolio_flg
    ,quote_code
    ,rate_term_code
    ,interest_rate_code
    ,seasonality_flg
    ,rate_spread
    ,jan_coeff
    ,feb_coeff
    ,mar_coeff
    ,apr_coeff
    ,may_coeff
    ,jun_coeff
    ,jul_coeff
    ,aug_coeff
    ,sep_coeff
    ,oct_coeff
    ,nov_coeff
    ,dec_coeff
    ,nvl(p_created_by,created_by)
    ,nvl(p_creation_date,creation_date)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.login_id
    ,FTP.FTP_PPR_ASSUMPTION_ID_SEQ.NEXTVAL
  from ftp_prepayment_rule
  where object_definition_id = p_source_obj_def_id;

END CopyPrepaymentAssumptionRecs;


--
-- PROCEDURE
--       CopyRateDefinitionRecs
--
-- DESCRIPTION
--   Creates a new Prepayment Rule Definition records by copying records in the
--   ftp_pp_orgdate_assump
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyRateDefinitionRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
-- Declare program variables as shown above

   v_ppr_id    FTP_PREPAYMENT_RULE.PPR_ASSUMPTION_ID%TYPE;
   v_obj_id    FTP_PREPAYMENT_RULE.OBJECT_DEFINITION_ID%TYPE;
   v_ln_id     FTP_PREPAYMENT_RULE.LINE_ITEM_ID%TYPE;
   v_currency  FTP_PREPAYMENT_RULE.CURRENCY%TYPE;
   v_seq       FTP_PREPAYMENT_RULE.COND_SEQUENCE%TYPE;

   CURSOR cur_ppr IS
   SELECT PPR_ASSUMPTION_ID, OBJECT_DEFINITION_ID,
   LINE_ITEM_ID,CURRENCY, COND_SEQUENCE
   FROM FTP_PREPAYMENT_RULE
   WHERE OBJECT_DEFINITION_ID = p_target_obj_def_id;

BEGIN
   OPEN cur_ppr ; -- open cursor

   LOOP
   FETCH cur_ppr INTO v_ppr_id, v_obj_id,v_ln_id, v_currency, v_seq;
   EXIT WHEN cur_ppr%NOTFOUND;

   insert into ftp_pp_orgdate_assump (
    object_definition_id
    ,line_item_id
    ,currency
    ,cond_sequence
    ,origination_date
    ,const_prepay_rate
    ,prepay_tbl_object_id
    ,burnout_factor
    ,arc_coeff_1
    ,arc_coeff_2
    ,arc_coeff_3
    ,arc_coeff_4
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,ppr_assumption_id
   ) select
    p_target_obj_def_id
    ,line_item_id
    ,currency
    ,cond_sequence
    ,origination_date
    ,const_prepay_rate
    ,prepay_tbl_object_id
    ,burnout_factor
    ,arc_coeff_1
    ,arc_coeff_2
    ,arc_coeff_3
    ,arc_coeff_4
    ,nvl(p_created_by,created_by)
    ,nvl(p_creation_date,creation_date)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.login_id
    ,v_ppr_id
   from ftp_pp_orgdate_assump
   where object_definition_id = p_source_obj_def_id
   and line_item_id = v_ln_id
   and currency = v_currency
   and cond_sequence = v_seq;

  END LOOP;
  CLOSE cur_ppr ;

END CopyRateDefinitionRecs;

--
-- PROCEDURE
--       CopyConditionRecs
--
-- DESCRIPTION
--   Creates a new Prepayment Rule Definition records by copying records in the
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


END FTP_BR_PREPAYMENT_PVT;

/
