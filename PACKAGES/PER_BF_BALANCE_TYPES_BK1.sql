--------------------------------------------------------
--  DDL for Package PER_BF_BALANCE_TYPES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BF_BALANCE_TYPES_BK1" AUTHID CURRENT_USER as
/* $Header: pebbtapi.pkh 120.1 2005/10/02 02:12:04 aroussel $ */
--
--
--  create_balance_type_b
--
procedure create_balance_type_b
  (
   p_input_value_id               in     number
  ,p_business_group_id            in     number
  ,p_displayed_name               in     varchar2
  ,p_internal_name                in     varchar2
  ,p_uom                          in     varchar2
  ,p_currency                     in     varchar2
  ,p_category                     in     varchar2
  ,p_date_from                    in     date
  ,p_date_to                      in     date
  ,p_effective_date               in     date
  );
--
-- create_balance_types_a
--
procedure create_balance_type_a
  (
   p_balance_type_id              in     number
  ,p_object_version_number        in     number
  ,p_input_value_id               in     number
  ,p_business_group_id            in     number
  ,p_displayed_name               in     varchar2
  ,p_internal_name                in     varchar2
  ,p_uom                          in     varchar2
  ,p_currency                     in     varchar2
  ,p_category                     in     varchar2
  ,p_date_from                    in     date
  ,p_date_to                      in     date
  ,p_effective_date               in     date
  );
--
End per_bf_balance_types_bk1;

 

/
