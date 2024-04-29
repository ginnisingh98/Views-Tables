--------------------------------------------------------
--  DDL for Package PQH_RTM_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RTM_RKU" AUTHID CURRENT_USER as
/* $Header: pqrtmrhi.pkh 120.2 2006/01/05 15:27:46 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_role_template_id               in number
 ,p_role_id                        in number
 ,p_transaction_category_id        in number
 ,p_template_id                    in number
 ,p_enable_flag                    in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_role_id_o                      in number
 ,p_transaction_category_id_o      in number
 ,p_template_id_o                  in number
 ,p_enable_flag_o                  in varchar2
 ,p_object_version_number_o        in number
  );
--
end pqh_rtm_rku;

 

/
