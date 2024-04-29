--------------------------------------------------------
--  DDL for Package HR_OBJECTIVE_LIBRARY_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_OBJECTIVE_LIBRARY_BK3" AUTHID CURRENT_USER as
/* $Header: pepmlapi.pkh 120.5 2006/10/20 04:03:46 tpapired noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< Delete_Library_Objective_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_library_objective_b
  (p_objective_id                  in   number
  ,p_object_version_number         in   number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< Delete_Library_Objective_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_library_objective_a
  (p_objective_id                  in   number
  ,p_object_version_number         in   number
  );
--
end HR_OBJECTIVE_LIBRARY_BK3;

 

/
