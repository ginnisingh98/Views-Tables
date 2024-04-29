--------------------------------------------------------
--  DDL for Package HR_PER_DEPLYMT_EIT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PER_DEPLYMT_EIT_BK1" AUTHID CURRENT_USER as
/* $Header: hrpdeapi.pkh 120.1 2006/05/08 02:24:05 adhunter noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_per_deplymt_eit_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_per_deplymt_eit_b
  (p_person_deployment_id          in     number
  ,p_person_extra_info_id          in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_per_deplymt_eit_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_per_deplymt_eit_a
  (p_person_deployment_id          in     number
  ,p_person_extra_info_id          in     number
  ,p_per_deplymt_eit_id            in     number
  ,p_object_version_number         in     number
  );
--
end HR_PER_DEPLYMT_EIT_BK1;

 

/
