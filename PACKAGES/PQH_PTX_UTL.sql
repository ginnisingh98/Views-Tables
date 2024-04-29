--------------------------------------------------------
--  DDL for Package PQH_PTX_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PTX_UTL" AUTHID CURRENT_USER as
/* $Header: pqptxutl.pkh 120.0.12010000.1 2008/07/28 13:05:53 appldev ship $ */
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_attributes >------------------------|
-- ----------------------------------------------------------------------------

procedure delete_attributes
(
 p_query_str        in    varchar2,
 p_attrib_prv_tab   out nocopy   pqh_prvcalc.t_attname_priv
);

-- ----------------------------------------------------------------------------
-- |--------------------------< fetch_position >------------------------------|
-- ----------------------------------------------------------------------------

procedure fetch_position
(
 p_position_transaction_id    out nocopy pqh_position_transactions.position_transaction_id%TYPE,
 p_position_id                in pqh_position_transactions.position_id%TYPE,
 p_action_date                in date,
  p_review_flag                in pqh_position_transactions.review_flag%type
);
--
--PROCEDURE create_shadow_record(p_position_transaction_id number,p_position_id number);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< populate_pei >------------------------------|
-- ----------------------------------------------------------------------------

procedure populate_pei
(
 p_position_transaction_id    in pqh_position_transactions.position_transaction_id%TYPE,
 p_position_id                in pqh_position_transactions.position_id%TYPE,
 p_populated                  in out nocopy varchar2
);

-- ----------------------------------------------------------------------------
-- |------------------------< alter_session_push >------------------------|
-- ----------------------------------------------------------------------------
procedure alter_session_push;


-- ----------------------------------------------------------------------------
-- |------------------------< apply_transaction >------------------------|
-- ----------------------------------------------------------------------------

function apply_transaction
(  p_transaction_id    in pqh_position_transactions.position_transaction_id%TYPE ,
   p_validate_only		in varchar2 default 'NO'
) return varchar2;

--------------------------------------------------------------------------------

FUNCTION reject_notification ( p_transaction_id in number) RETURN varchar2 ;

--------------------------------------------------------------------------------

FUNCTION back_notification ( p_transaction_id in number) RETURN varchar2 ;

--------------------------------------------------------------------------------

FUNCTION override_notification ( p_transaction_id in number) RETURN varchar2 ;

--------------------------------------------------------------------------------

FUNCTION apply_notification ( p_transaction_id in number) RETURN varchar2 ;

--------------------------------------------------------------------------------

FUNCTION warning_notification ( p_transaction_id in number) RETURN varchar2 ;

--------------------------------------------------------------------------------

FUNCTION fyi_notification (p_transaction_id in number) RETURN varchar2;

--------------------------------------------------------------------------------

FUNCTION respond_notification (p_transaction_id in number) RETURN varchar2;

--------------------------------------------------------------------------------

FUNCTION set_status
(
 p_transaction_category_id       IN    pqh_transaction_categories.transaction_category_id%TYPE,
 p_transaction_id                IN    pqh_worksheets.worksheet_id%TYPE,
 p_status                        IN    pqh_worksheets.transaction_status%TYPE
) RETURN varchar2;

---------------------------------------------------------------------------------

procedure create_ptx_shadow(p_position_transaction_id number);

--------------------------------------------------------------------------------

procedure create_pte_shadow(p_position_transaction_id number);

-------------------------------------------------------------------------------

procedure refresh_ptx(p_transaction_category_id number, p_position_transaction_id number, p_items_changed out nocopy varchar2);

-------------------------------------------------------------------------------

procedure apply_sit(p_position_transaction_id number, p_position_id number, p_txn_type varchar2);
--
-- ----------------------------------------------------------------------------
-- |---------------------< populate_job_requirements >------------------------|
-- ----------------------------------------------------------------------------
--
procedure populate_job_requirements
(
 p_position_transaction_id    in pqh_position_transactions.position_transaction_id%TYPE,
 p_position_id                in pqh_position_transactions.position_id%TYPE,
 p_populated                  in out nocopy varchar2
);
--
--------------------------------------------------------------------------------

procedure create_tjr_shadow(p_position_transaction_id number);

--------------------------------------------------------------------------------
procedure refresh_pte(p_transaction_category_id number, p_position_transaction_id number,
  p_position_id number, p_pte_changed out nocopy varchar2);

-------------------------------------------------------------------------------

procedure refresh_tjr(p_transaction_category_id number, p_position_transaction_id number,  p_position_id number, p_tjr_changed out nocopy varchar2);
--
-- ---------------------------------------------------------------------------
-- --------------------------< chk_resesrved_fte >----------------------------
-- ---------------------------------------------------------------------------
--
Procedure chk_reserved_fte
  (p_position_id               in number
  ,p_fte                       in number
  ,p_position_type             in varchar2
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  );
--
--
-- ---------------------------------------------------------------------------
-- --------------------------< apply_ptx_budgets >----------------------------
-- ---------------------------------------------------------------------------
--
procedure apply_ptx_budgets(p_position_transaction_id number);
--
end pqh_ptx_utl;

/
