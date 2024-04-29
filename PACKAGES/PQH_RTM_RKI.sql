--------------------------------------------------------
--  DDL for Package PQH_RTM_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RTM_RKI" AUTHID CURRENT_USER as
/* $Header: pqrtmrhi.pkh 120.2 2006/01/05 15:27:46 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_role_template_id               in number
 ,p_role_id                        in number
 ,p_transaction_category_id        in number
 ,p_template_id                    in number
 ,p_enable_flag                    in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
  );
end pqh_rtm_rki;

 

/
