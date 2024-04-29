--------------------------------------------------------
--  DDL for Package PER_SUCCESSION_PLAN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SUCCESSION_PLAN_BK3" 
AUTHID CURRENT_USER AS
/* $Header: pesucapi.pkh 120.3.12010000.3 2010/02/13 19:29:42 schowdhu ship $*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_succession_plan_b >------------------------|
-- ----------------------------------------------------------------------------
--
   PROCEDURE delete_succession_plan_b (
      p_succession_plan_id      IN   NUMBER,
      p_object_version_number   IN   NUMBER
   );

-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_succession_plan_a >------------------------|
-- ----------------------------------------------------------------------------
--
   PROCEDURE delete_succession_plan_a (
      p_succession_plan_id      IN   NUMBER,
      p_object_version_number   IN   NUMBER
   );
END per_succession_plan_bk3;

/
