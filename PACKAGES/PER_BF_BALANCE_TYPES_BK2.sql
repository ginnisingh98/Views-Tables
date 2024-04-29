--------------------------------------------------------
--  DDL for Package PER_BF_BALANCE_TYPES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BF_BALANCE_TYPES_BK2" AUTHID CURRENT_USER as
/* $Header: pebbtapi.pkh 120.1 2005/10/02 02:12:04 aroussel $ */
--
--  update_balance_type_b
--
Procedure update_balance_type_b
 ( p_balance_type_id              in number
  ,p_input_value_id               in number
  ,p_displayed_name               in varchar2
  ,p_internal_name                in varchar2
  ,p_uom                          in varchar2
  ,p_currency                     in varchar2
  ,p_category                     in varchar2
  ,p_date_from                    in date
  ,p_date_to                      in date
  ,p_effective_date               in date
  ,p_object_version_number        in number
  );
--
--  update_balance_type_a
--
Procedure update_balance_type_a
 ( p_balance_type_id              in number
  ,p_input_value_id               in number
  ,p_displayed_name               in varchar2
  ,p_internal_name                in varchar2
  ,p_uom                          in varchar2
  ,p_currency                     in varchar2
  ,p_category                     in varchar2
  ,p_date_from                    in date
  ,p_date_to                      in date
  ,p_effective_date               in date
  ,p_object_version_number        in number
  );
--
End per_bf_balance_types_bk2;

 

/
