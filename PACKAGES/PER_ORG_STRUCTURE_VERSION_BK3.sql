--------------------------------------------------------
--  DDL for Package PER_ORG_STRUCTURE_VERSION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ORG_STRUCTURE_VERSION_BK3" AUTHID CURRENT_USER AS
/* $Header: peosvapi.pkh 120.2 2005/10/22 01:24:23 aroussel noship $ */

PROCEDURE delete_org_structure_version_b
   (  p_validate                     IN BOOLEAN
     ,p_org_structure_version_id     IN number
     ,p_object_version_number        IN number );

PROCEDURE delete_org_structure_version_a
   (  p_validate                     IN BOOLEAN
     ,p_org_structure_version_id     IN number
     ,p_object_version_number        IN number );
end per_org_structure_version_bk3;

 

/
