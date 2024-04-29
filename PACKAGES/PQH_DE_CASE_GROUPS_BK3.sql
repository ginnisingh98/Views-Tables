--------------------------------------------------------
--  DDL for Package PQH_DE_CASE_GROUPS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_CASE_GROUPS_BK3" AUTHID CURRENT_USER as
/* $Header: pqcgnapi.pkh 120.0 2005/05/29 01:42:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Delete_CASE_GROUPS_b >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Delete_CASE_GROUPS_b
  (p_CASE_GROUP_ID                 In     Number
  ,p_object_version_number         In     number);

Procedure Delete_CASE_GROUPS_a
  (p_CASE_GROUP_ID                 In     Number
  ,p_object_version_number         In     number);

end PQH_DE_CASE_GROUPS_BK3;

 

/
