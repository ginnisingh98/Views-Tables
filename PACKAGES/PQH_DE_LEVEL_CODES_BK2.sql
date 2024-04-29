--------------------------------------------------------
--  DDL for Package PQH_DE_LEVEL_CODES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_LEVEL_CODES_BK2" AUTHID CURRENT_USER as
/* $Header: pqlcdapi.pkh 120.0 2005/05/29 02:10:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< <Update_LEVEL_CODES_b >-------------------------|
-- ----------------------------------------------------------------------------
--

procedure Update_LEVEL_CODES_b
  (p_effective_date             in  date
  ,p_level_code_id                in     number
  ,p_object_version_number        in     number
  ,p_level_number_id              in     number
  ,p_level_code                   in     varchar2
  ,p_description                  in     varchar2
  ,p_gradual_value_number         in     number
  );


procedure Update_LEVEL_CODES_a
 (p_effective_date                in     date
  ,p_level_code_id                in     number
  ,p_object_version_number        in     number
  ,p_level_number_id              in     number
  ,p_level_code                   in     varchar2
  ,p_description                  in     varchar2
  ,p_gradual_value_number         in     number
  );


end PQH_DE_LEVEL_CODES_BK2;

 

/
