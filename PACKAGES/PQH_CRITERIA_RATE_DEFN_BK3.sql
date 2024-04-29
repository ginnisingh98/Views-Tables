--------------------------------------------------------
--  DDL for Package PQH_CRITERIA_RATE_DEFN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CRITERIA_RATE_DEFN_BK3" AUTHID CURRENT_USER as
/* $Header: pqcrdapi.pkh 120.6 2006/03/14 11:28:41 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_criteria_rate_defn_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_criteria_rate_defn_b
  (p_effective_date                in     date
  ,p_criteria_rate_defn_id         in     number
  ,p_object_version_number         in     number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_criteria_rate_defn_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_criteria_rate_defn_a
  (p_effective_date                in     date
  ,p_criteria_rate_defn_id         in     number
  ,p_object_version_number         in     number
  );
--
end pqh_criteria_rate_defn_bk3;

 

/
