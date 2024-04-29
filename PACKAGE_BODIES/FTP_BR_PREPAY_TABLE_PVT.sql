--------------------------------------------------------
--  DDL for Package Body FTP_BR_PREPAY_TABLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTP_BR_PREPAY_TABLE_PVT" AS
/* $Header: ftpbpptb.pls 120.0 2005/06/06 19:11:23 appldev noship $ */

G_PKG_NAME constant varchar2(30) := 'FTP_BR_PREPAY_TABLE_PVT';

------------------------------------------------------------
-- PRIVATE SPECS
------------------------------------------------------------

PROCEDURE DeletePrepayTableRuleRecs(
  p_obj_def_id          in          number
);

PROCEDURE DeleteTblDimensionValueRecs(
  p_obj_def_id          in          number
);

PROCEDURE DeleteTblHypercubeRecs(
  p_obj_def_id          in          number
);


PROCEDURE CopyPrepayTableRuleRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);

PROCEDURE CopyTblDimensionValueRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);

PROCEDURE CopyTblHypercubeRecs(
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
  DeletePrepayTableRuleRecs(
    p_obj_def_id    => p_obj_def_id
  );

  DeleteTblDimensionValueRecs(
    p_obj_def_id    => p_obj_def_id
  );

  DeleteTblHypercubeRecs(
    p_obj_def_id    => p_obj_def_id
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

  g_api_name    constant varchar2(30) := 'CopyObjectDefinition';

BEGIN

  CopyPrepayTableRuleRecs(
    p_source_obj_def_id   => p_source_obj_def_id
    ,p_target_obj_def_id  => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
  );

  CopyTblDimensionValueRecs(
    p_source_obj_def_id   => p_source_obj_def_id
    ,p_target_obj_def_id  => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
  );

  CopyTblHypercubeRecs(
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
PROCEDURE DeletePrepayTableRuleRecs(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS
BEGIN

  delete from ftp_prepay_table_rule
  where object_definition_id = p_obj_def_id;

END DeletePrepayTableRuleRecs;


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
PROCEDURE DeleteTblDimensionValueRecs(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS
BEGIN

  delete from ftp_pp_tbl_dim_value
  where pptb_object_definition_id = p_obj_def_id;

END DeleteTblDimensionValueRecs;


--
-- PROCEDURE
--	 DeleteRedemptionCurveRecs
--
-- DESCRIPTION
--   Deletes Transfer Price Rule Definition records by performing deletes on records
--   in the FTP_PP_TBL_HYPERCUBE table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteTblHypercubeRecs(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS
BEGIN

  delete from ftp_pp_tbl_hypercube
  where object_definition_id = p_obj_def_id;

END DeleteTblHypercubeRecs;



--
-- PROCEDURE
--	 CopTransferPriceRuleRec
--
-- DESCRIPTION
--   Creates a new Transfer Price Rule Definition by copying records in the
--   FTP_PREPAY_TABLE_RULE table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyPrepayTableRuleRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
BEGIN

  insert into ftp_prepay_table_rule (
    object_definition_id
    ,pp_dim_type_code
    ,dim_display_seq
    ,num_nodes
    ,interpolation_flg
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,pptb_dimension_id
  ) select
    p_target_obj_def_id
    ,pp_dim_type_code
    ,dim_display_seq
    ,num_nodes
    ,interpolation_flg
    ,nvl(p_created_by,created_by)
    ,nvl(p_creation_date,creation_date)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.login_id
    ,FTP.FTP_PPTB_DIM_ID_SEQ.NEXTVAL
  from ftp_prepay_table_rule
  where object_definition_id = p_source_obj_def_id;

END CopyPrepayTableRuleRecs;


--
-- PROCEDURE
--	 CopyTblDimensionValueRecs
--
-- DESCRIPTION
--   Creates a new Transfer Price Rule Definition records by copying records in the
--   ftp_pp_tbl_dim_value table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyTblDimensionValueRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
BEGIN

  insert into ftp_pp_tbl_dim_value (
    pptb_object_definition_id
    ,pptb_dim_type_code
    ,type_display_seq
    ,type_value
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,pptb_dimension_value_id
  ) select
    p_target_obj_def_id
    ,pptb_dim_type_code
    ,type_display_seq
    ,type_value
    ,nvl(p_created_by,created_by)
    ,nvl(p_creation_date,creation_date)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.login_id
    ,FTP.FTP_PPTB_DIM_VALUE_ID_SEQ.NEXTVAL
  from ftp_pp_tbl_dim_value
  where pptb_object_definition_id = p_source_obj_def_id;

END CopyTblDimensionValueRecs;




--
-- PROCEDURE
--	 CopyTblHypercubeRecs
--
-- DESCRIPTION
--   Creates a new Transfer Price Rule Definition records by copying records in the
--   ftp_pp_tbl_hypercube table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyTblHypercubeRecs(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
BEGIN

  insert into ftp_pp_tbl_hypercube (
    object_definition_id
    ,original_term
    ,reprice_freq
    ,remain_term
    ,expired_term
    ,term_to_repr
    ,coupon_rate
    ,market_rate
    ,rate_difference
    ,rate_ratio
    ,prepayment_rate
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,pptb_hypercube_id
  ) select
    p_target_obj_def_id
    ,original_term
    ,reprice_freq
    ,remain_term
    ,expired_term
    ,term_to_repr
    ,coupon_rate
    ,market_rate
    ,rate_difference
    ,rate_ratio
    ,prepayment_rate
    ,nvl(p_created_by,created_by)
    ,nvl(p_creation_date,creation_date)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.login_id
    ,FTP.FTP_PPTB_HYPERCUBE_ID_SEQ.NEXTVAL
  from ftp_pp_tbl_hypercube
  where object_definition_id = p_source_obj_def_id;

END CopyTblHypercubeRecs;


END FTP_BR_PREPAY_TABLE_PVT;

/
