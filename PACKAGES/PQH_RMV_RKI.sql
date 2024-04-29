--------------------------------------------------------
--  DDL for Package PQH_RMV_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RMV_RKI" AUTHID CURRENT_USER as
/* $Header: pqrmvrhi.pkh 120.2 2005/06/23 03:42 srenukun noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_node_value_id                in number
  ,p_rate_matrix_node_id          in number
  ,p_short_code                   in varchar2
  ,p_char_value1                  in varchar2
  ,p_char_value2                  in varchar2
  ,p_char_value3                  in varchar2
  ,p_char_value4                  in varchar2
  ,p_number_value1                in number
  ,p_number_value2                in number
  ,p_number_value3                in number
  ,p_number_value4                in number
  ,p_date_value1                  in date
  ,p_date_value2                  in date
  ,p_date_value3                  in date
  ,p_date_value4                  in date
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_object_version_number        in number
  );
end pqh_rmv_rki;

 

/
