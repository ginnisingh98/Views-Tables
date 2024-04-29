--------------------------------------------------------
--  DDL for Package HR_AUTHORIA_MAPPING_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AUTHORIA_MAPPING_BK1" AUTHID CURRENT_USER as
/* $Header: hrammapi.pkh 120.1 2005/10/02 01:58:49 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< CREATE_AUTHORIA_MAPPING_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_AUTHORIA_MAPPING_b
  (
   p_pl_id                         in     number
  ,p_plip_id                       in     number
  ,p_open_enrollment_flag          in     varchar2
  ,p_target_page                   in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< CREATE_AUTHORIA_MAPPING_a >------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_AUTHORIA_MAPPING_a
  (
   p_pl_id                         in     number
  ,p_plip_id                       in     number
  ,p_open_enrollment_flag          in     varchar2
  ,p_target_page                   in     varchar2
  );
--
--
end HR_AUTHORIA_MAPPING_BK1;

 

/
