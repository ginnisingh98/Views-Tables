--------------------------------------------------------
--  DDL for Package PQH_FR_STAT_SITUATIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_STAT_SITUATIONS_BK3" AUTHID CURRENT_USER as
/* $Header: pqstsapi.pkh 120.2 2005/10/28 17:50:11 deenath noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_statutory_situation_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_statutory_situation_b
(
   p_statutory_situation_id         in     number
  ,p_object_version_number          in     number
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_statutory_situation_a>-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_statutory_situation_a
(
   p_statutory_situation_id         in     number
  ,p_object_version_number          in     number
);

--
end pqh_fr_stat_situations_bk3;

 

/
