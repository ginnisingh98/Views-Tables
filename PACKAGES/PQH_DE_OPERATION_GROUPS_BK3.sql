--------------------------------------------------------
--  DDL for Package PQH_DE_OPERATION_GROUPS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_OPERATION_GROUPS_BK3" AUTHID CURRENT_USER as
/* $Header: pqopgapi.pkh 120.0 2005/05/29 02:13:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Delete_OPERATION_GROUPS_b >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Delete_OPERATION_GROUPS_b
  (p_operation_GROUP_ID                 In     Number
  ,p_object_version_number                In     number);

Procedure Delete_OPERATION_GROUPS_a
  (p_operation_GROUP_ID                 In     Number
  ,p_object_version_number                In     number);

end PQH_DE_OPERATION_GROUPS_BK3;

 

/
