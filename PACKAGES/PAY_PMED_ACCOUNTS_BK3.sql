--------------------------------------------------------
--  DDL for Package PAY_PMED_ACCOUNTS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PMED_ACCOUNTS_BK3" AUTHID CURRENT_USER as
/* $Header: pypmaapi.pkh 120.1 2005/10/02 02:32:53 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_pmed_accounts_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pmed_accounts_b
  (
   p_source_id                      in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_pmed_accounts_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pmed_accounts_a
  (
   p_source_id                      in  number
  ,p_object_version_number          in  number
  );
--
end pay_pmed_accounts_bk3;

 

/
