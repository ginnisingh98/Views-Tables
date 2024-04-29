--------------------------------------------------------
--  DDL for Package PQH_DE_LEVEL_NUMBERS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_LEVEL_NUMBERS_BK3" AUTHID CURRENT_USER as
/* $Header: pqgvnapi.pkh 120.0 2005/05/29 02:01:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Delete_LEVEL_NUMBERS_b >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Delete_LEVEL_NUMBERS_b
  (p_LEVEL_NUMBER_ID               In     Number
  ,p_object_version_number         In     number);

Procedure Delete_LEVEL_NUMBERS_a
  (p_LEVEL_NUMBER_ID               In     Number
  ,p_object_version_number         In     number);

end PQH_DE_LEVEL_NUMBERS_BK3;

 

/
