--------------------------------------------------------
--  DDL for Package PQH_RMN_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RMN_RKU" AUTHID CURRENT_USER as
/* $Header: pqrmnrhi.pkh 120.0 2005/05/29 02:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_rate_matrix_node_id          in number
  ,p_short_code                   in varchar2
  ,p_pl_id                        in number
  ,p_level_number                 in number
  ,p_criteria_short_code          in varchar2
  ,p_node_name                    in varchar2
  ,p_parent_node_id               in number
  ,p_eligy_prfl_id                in number
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_object_version_number        in number
  ,p_short_code_o                 in varchar2
  ,p_pl_id_o                      in number
  ,p_level_number_o               in number
  ,p_criteria_short_code_o        in varchar2
  ,p_node_name_o                  in varchar2
  ,p_parent_node_id_o             in number
  ,p_eligy_prfl_id_o              in number
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_object_version_number_o      in number
  );
--
end pqh_rmn_rku;

 

/
