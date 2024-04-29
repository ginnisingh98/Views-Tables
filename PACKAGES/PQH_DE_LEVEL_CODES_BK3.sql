--------------------------------------------------------
--  DDL for Package PQH_DE_LEVEL_CODES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_LEVEL_CODES_BK3" AUTHID CURRENT_USER as
/* $Header: pqlcdapi.pkh 120.0 2005/05/29 02:10:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Delete_LEVEL_CODES_b >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Delete_LEVEL_CODES_b
  (p_level_code_id                 in     number
  ,p_object_version_number         in     number
  );

Procedure Delete_LEVEL_CODES_a
  (p_level_code_id                 in     number
  ,p_object_version_number         in     number
  );

end PQH_DE_LEVEL_CODES_BK3;

 

/
