--------------------------------------------------------
--  DDL for Package PQH_DE_RESULT_SETS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_RESULT_SETS_BK2" AUTHID CURRENT_USER as
/* $Header: pqrssapi.pkh 120.0 2005/05/29 02:37:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Update_RESULT_SETS_b >-------------------------|
-- ----------------------------------------------------------------------------
--

procedure Update_RESULT_SETS_b
 ( p_effective_date               in     date
  ,p_result_set_id                in     number
  ,p_object_version_number        in     number
  ,p_gradual_value_number_from    in     number
  ,p_gradual_value_number_to      in     number
  ,p_grade_id                     in     number
  ) ;

procedure Update_RESULT_SETS_a
  ( p_effective_date               in     date
  ,p_result_set_id                in     number
  ,p_object_version_number        in  number
  ,p_gradual_value_number_from    in     number
  ,p_gradual_value_number_to      in     number
  ,p_grade_id                     in     number
  ) ;

end PQH_DE_RESULT_SETS_BK2;

 

/
