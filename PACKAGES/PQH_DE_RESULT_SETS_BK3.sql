--------------------------------------------------------
--  DDL for Package PQH_DE_RESULT_SETS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_RESULT_SETS_BK3" AUTHID CURRENT_USER as
/* $Header: pqrssapi.pkh 120.0 2005/05/29 02:37:45 appldev noship $ */

--
-- ----------------------------------------------------------------------------
-- |-------------------------< Delete_RESULT_SETS_b >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Delete_RESULT_SETS_b
  (p_RESULT_SET_ID                 In     Number
  ,p_object_version_number         In     number);

Procedure Delete_RESULT_SETS_a
  (p_RESULT_SET_ID                 In     Number
  ,p_object_version_number         In     number);

end PQH_DE_RESULT_SETS_BK3;

 

/
