--------------------------------------------------------
--  DDL for Package AME_TRANS_TYPE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_TRANS_TYPE_BK1" AUTHID CURRENT_USER as
/* $Header: amacaapi.pkh 120.1.12010000.2 2019/09/12 11:53:09 jaakhtar ship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< create_ame_transaction_type_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_transaction_type_b
  (p_application_name      in     varchar2
  ,p_fnd_application_id    in     number
  ,p_transaction_type_id   in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------< create_ame_transaction_type_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_transaction_type_a
  (p_application_name      in     varchar2
  ,p_fnd_application_id    in     number
  ,p_transaction_type_id   in     varchar2
  ,p_application_id        in     number
  ,p_object_version_number in     number
  ,p_start_date            in     date
  ,p_end_date              in     date
  );
--
end ame_trans_type_bk1;

/
