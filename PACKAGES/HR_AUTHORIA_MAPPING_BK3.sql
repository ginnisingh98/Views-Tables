--------------------------------------------------------
--  DDL for Package HR_AUTHORIA_MAPPING_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AUTHORIA_MAPPING_BK3" AUTHID CURRENT_USER as
/* $Header: hrammapi.pkh 120.1 2005/10/02 01:58:49 aroussel $ */
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< DELETE_AUTHORIA_MAPPING_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_AUTHORIA_MAPPING_b
  (p_authoria_mapping_id           in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< DELETE_AUTHORIA_MAPPING_a >------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_AUTHORIA_MAPPING_a
  (p_authoria_mapping_id           in     number
  ,p_object_version_number         in     number
  );

--
end HR_AUTHORIA_MAPPING_BK3;

 

/
