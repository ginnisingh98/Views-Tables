--------------------------------------------------------
--  DDL for Package PQH_SITUATIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_SITUATIONS_BK3" AUTHID CURRENT_USER as
/* $Header: pqlosapi.pkh 120.1 2005/10/02 02:26:58 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------<  delete_situation_b  >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_situation_b
  (p_situation_id                   in     number
  ,p_object_version_number          in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------<  delete_situations_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_situation_a
  (p_situation_id                   in     number
  ,p_object_version_number          in     number
  );
--
end pqh_situations_bk3;

 

/
