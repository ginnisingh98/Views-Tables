--------------------------------------------------------
--  DDL for Package PQH_DE_OPERATIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_OPERATIONS_BK3" AUTHID CURRENT_USER as
/* $Header: pqoplapi.pkh 120.0 2005/05/29 02:14:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Delete_OPERATIONS_b >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Delete_OPERATIONS_b
  (p_OPERATION_ID                    In     Number
  ,p_object_version_number           In     number);

Procedure Delete_OPERATIONS_a
  (p_OPERATION_ID                    In     Number
  ,p_object_version_number           In     number);

end PQH_DE_OPERATIONS_BK3;

 

/
