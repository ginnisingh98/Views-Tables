--------------------------------------------------------
--  DDL for Package HR_OBJECTIVES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_OBJECTIVES_BK3" AUTHID CURRENT_USER as
/* $Header: peobjapi.pkh 120.6 2006/05/05 07:17:16 tpapired noship $*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_objective_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_objective_b
  (p_objective_id                       in number,
   p_object_version_number              in number
  );

-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_objective_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_objective_a
  (p_objective_id                       in number,
   p_object_version_number              in number
  );
end hr_objectives_bk3;

 

/
