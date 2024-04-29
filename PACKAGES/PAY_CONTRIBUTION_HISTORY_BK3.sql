--------------------------------------------------------
--  DDL for Package PAY_CONTRIBUTION_HISTORY_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CONTRIBUTION_HISTORY_BK3" AUTHID CURRENT_USER as
/* $Header: pyconapi.pkh 115.1 99/09/30 13:47:38 porting ship  $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Contribution_History_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Contribution_History_b
  (
   p_contr_history_id               in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Contribution_History_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Contribution_History_a
  (
   p_contr_history_id               in  number
  ,p_object_version_number          in  number
  );
--
end pay_Contribution_History_bk3;

 

/
