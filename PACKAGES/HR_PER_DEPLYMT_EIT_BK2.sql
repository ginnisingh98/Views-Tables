--------------------------------------------------------
--  DDL for Package HR_PER_DEPLYMT_EIT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PER_DEPLYMT_EIT_BK2" AUTHID CURRENT_USER as
/* $Header: hrpdeapi.pkh 120.1 2006/05/08 02:24:05 adhunter noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_per_deplymt_eit_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_per_deplymt_eit_b
  (p_per_deplymt_eit_id             in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_per_deplymt_eit_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_per_deplymt_eit_a
  (p_per_deplymt_eit_id             in     number
  ,p_object_version_number         in     number
  );
--
end HR_PER_DEPLYMT_EIT_BK2;

 

/
