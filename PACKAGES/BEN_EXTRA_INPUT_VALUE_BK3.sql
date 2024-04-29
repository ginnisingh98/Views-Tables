--------------------------------------------------------
--  DDL for Package BEN_EXTRA_INPUT_VALUE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXTRA_INPUT_VALUE_BK3" AUTHID CURRENT_USER as
/* $Header: beeivapi.pkh 120.0 2005/05/28 02:16:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_extra_input_value_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_extra_input_value_b
  (
   p_extra_input_value_id           in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_extra_input_value_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_extra_input_value_a
  (
   p_extra_input_value_id           in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_extra_input_value_bk3;

 

/
