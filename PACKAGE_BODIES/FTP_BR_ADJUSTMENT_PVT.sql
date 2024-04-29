--------------------------------------------------------
--  DDL for Package Body FTP_BR_ADJUSTMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTP_BR_ADJUSTMENT_PVT" AS
/* $Header: ftpadjb.pls 120.1.12000000.1 2007/07/27 12:08:20 shishank noship $ */


G_PKG_NAME constant varchar2(30) := 'FTP_BR_ADJUSTMENT_PVT';

--------------------------------------------------------------------------------
-- PRIVATE SPECS
--------------------------------------------------------------------------------

PROCEDURE DeleteAdjustmentRuleRec(
  p_obj_def_id          in          number
);

PROCEDURE DeleteAddOnRateDtlRecs(
  p_obj_def_id          in          number
);

PROCEDURE  DeleteConditionRecs  (
  p_obj_def_id          in          number
);

PROCEDURE CopyAdjustmentRuleRec(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);

PROCEDURE CopyAddOnRateDtlRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);

PROCEDURE CopyConditionRecs (
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);
----------------------------------------
-- PUBLIC BODIES ------
----------------------------------------

PROCEDURE DeleteObjectDefinition(
  p_obj_def_id          in          number
)
IS

  g_api_name    constant varchar2(30)   := 'DeleteObjectDefinition';

BEGIN
  DeleteAdjustmentRuleRec(
    p_obj_def_id    => p_obj_def_id
  );

  DeleteAddOnRateDtlRecs(
    p_obj_def_id    => p_obj_def_id
  );

 DeleteConditionRecs  (
  p_obj_def_id      => p_obj_def_id
 );

EXCEPTION

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, g_api_name);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

END DeleteObjectDefinition;



----------------------------------------------------------------------------
-- Copy  Procedure
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

  CopyAdjustmentRuleRec(
    p_source_obj_def_id   => p_source_obj_def_id
    ,p_target_obj_def_id  => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date

  );

  CopyAddOnRateDtlRecs(
     p_source_obj_def_id   => p_source_obj_def_id
    ,p_target_obj_def_id  => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
  );


  CopyConditionRecs (
  p_source_obj_def_id    => p_source_obj_def_id
  ,p_target_obj_def_id   => p_target_obj_def_id
  ,p_created_by          => p_created_by
  ,p_creation_date       => p_creation_date
);

EXCEPTION

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, g_api_name);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
 END CopyObjectDefinition;



----------------------------------------
-- PRIVATE BODIES ----------------------
----------------------------------------


PROCEDURE DeleteAdjustmentRuleRec(
  p_obj_def_id in number
)
IS
BEGIN

  delete from FTP_ADJUSTMENT_RULE
  where object_definition_id = p_obj_def_id;

END DeleteAdjustmentRuleRec;



PROCEDURE DeleteAddOnRateDtlRecs(
  p_obj_def_id in number
)
IS
BEGIN

  delete from FTP_ADD_ON_RATE_DTL
  where object_definition_id = p_obj_def_id;

END DeleteAddOnRateDtlRecs;


PROCEDURE DeleteConditionRecs(
  p_obj_def_id in number
)
IS
BEGIN

 delete from ftp_tp_pp_conditions
  where object_definition_id = p_obj_def_id;


END DeleteConditionRecs;

------------------------------------------------------
-- Copy Bodies
------------------------------------------------------


PROCEDURE CopyAdjustmentRuleRec(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
IS
BEGIN

insert into FTP_ADJUSTMENT_RULE (
 object_definition_id,
 line_item_id,
 currency,
 cond_sequence,
 adjustment_type_code,
 calc_method_code,
 reference_term_code,
 lookup_method_code,
 assignment_date_code,
 interest_rate_code,
 break_funding_rate,
 minimum_charge,
 break_funding_amt,
 rate_spread,
 created_by,
 creation_date,
 last_updated_by,
 last_update_date,
 last_update_login,
 object_version_number
  )
  select
 p_target_obj_def_id,
 line_item_id,
 currency,
 cond_sequence,
 adjustment_type_code,
 calc_method_code,
 reference_term_code,
 lookup_method_code,
 assignment_date_code,
 interest_rate_code,
 break_funding_rate,
 minimum_charge,
 break_funding_amt,
 rate_spread,
 nvl(p_created_by,created_by),
 nvl(p_creation_date,creation_date),
 FND_GLOBAL.user_id,
 sysdate,
 FND_GLOBAL.login_id,
 object_version_number

  from FTP_ADJUSTMENT_RULE
  where object_definition_id = p_source_obj_def_id;

END CopyAdjustmentRuleRec;

PROCEDURE CopyAddOnRateDtlRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
IS
BEGIN

insert into FTP_ADD_ON_RATE_DTL (
	add_on_rate_dtl_id,
	object_definition_id,
	line_item_id,
	currency,
	cond_sequence,
	term,
	mult,
	rate,
	amount,
	formula,
	term_point,
	term_multiplier,
	coefficient,
	created_by,
	creation_date,
	last_updated_by,
	last_update_date,
	last_update_login,
	object_version_number
    ) select
	FUN_TRX_TYPES_B_S.nextval,
        p_target_obj_def_id,
	line_item_id,
	currency,
	cond_sequence,
	term,
	mult,
	rate,
	amount,
	formula,
	term_point,
	term_multiplier,
	coefficient,
	nvl(p_created_by,created_by),
	nvl(p_creation_date,creation_date),
	FND_GLOBAL.user_id,
	sysdate,
	FND_GLOBAL.login_id,
	object_version_number
   from FTP_ADD_ON_RATE_DTL
   where object_definition_id = p_source_obj_def_id;

END CopyAddOnRateDtlRecs;



PROCEDURE CopyConditionRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
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


END ftp_br_adjustment_pvt ;


/
