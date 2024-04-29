--------------------------------------------------------
--  DDL for Package AME_TRANS_TYPE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_TRANS_TYPE_BK2" AUTHID CURRENT_USER as
/* $Header: amacaapi.pkh 120.1.12010000.2 2019/09/12 11:53:09 jaakhtar ship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< update_ame_transaction_type_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_transaction_type_b
  (p_application_name            in     varchar2
  ,p_application_id              in     number
  ,p_object_version_number       in     number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------< update_ame_transaction_type_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_transaction_type_a
  (p_application_name            in     varchar2
  ,p_application_id              in     number
  ,p_object_version_number       in     number
  ,p_start_date                  in     date
  ,p_end_date                    in     date
  );
--
end ame_trans_type_bk2;

/
