--------------------------------------------------------
--  DDL for Package PQH_TTM_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TTM_RKU" AUTHID CURRENT_USER as
/* $Header: pqttmrhi.pkh 120.0 2005/05/29 02:51:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_transaction_template_id        in number
 ,p_enable_flag                    in varchar2
 ,p_template_id                    in number
 ,p_transaction_id                 in number
 ,p_transaction_category_id        in number
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_enable_flag_o                  in varchar2
 ,p_template_id_o                  in number
 ,p_transaction_id_o               in number
 ,p_transaction_category_id_o      in number
 ,p_object_version_number_o        in number
  );
--
end pqh_ttm_rku;

 

/
