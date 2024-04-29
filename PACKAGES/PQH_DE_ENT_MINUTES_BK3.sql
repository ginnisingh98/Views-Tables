--------------------------------------------------------
--  DDL for Package PQH_DE_ENT_MINUTES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_ENT_MINUTES_BK3" AUTHID CURRENT_USER as
/* $Header: pqetmapi.pkh 120.0 2005/05/29 01:52:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Delete_ENT_MINUTES_b >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Delete_ENT_MINUTES_b
  (P_ENT_MINUTES_ID                  In     Number
  ,p_object_version_number         In     number);

Procedure Delete_ENT_MINUTES_a
  (P_ENT_MINUTES_ID                  In     Number
  ,p_object_version_number         In     number);

end PQH_DE_ENT_MINUTES_BK3;

 

/
