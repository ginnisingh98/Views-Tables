--------------------------------------------------------
--  DDL for Package HR_AUTHORIA_MAPPING_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AUTHORIA_MAPPING_BK2" AUTHID CURRENT_USER as
/* $Header: hrammapi.pkh 120.1 2005/10/02 01:58:49 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< UPDATE_AUTHORIA_MAPPING_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_AUTHORIA_MAPPING_b
  (p_authoria_mapping_id           in     number
  ,p_pl_id                         in     number
  ,p_plip_id                       in     number
  ,p_open_enrollment_flag          in     varchar2
  ,p_target_page                   in     varchar2
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< UPDATE_AUTHORIA_MAPPING_a >------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_AUTHORIA_MAPPING_a
  (p_authoria_mapping_id           in     number
  ,p_pl_id                         in     number
  ,p_plip_id                       in     number
  ,p_open_enrollment_flag          in     varchar2
  ,p_target_page                   in     varchar2
  ,p_object_version_number         in     number
  );
--

--
end HR_AUTHORIA_MAPPING_BK2;

 

/
