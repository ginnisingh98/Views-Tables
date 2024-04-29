--------------------------------------------------------
--  DDL for Package PER_POS_STRUCTURE_VERSION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_POS_STRUCTURE_VERSION_BK3" AUTHID CURRENT_USER AS
/* $Header: pepsvapi.pkh 120.2 2005/10/22 01:25:03 aroussel noship $ */

PROCEDURE delete_pos_structure_version_b
   (  p_validate                     IN BOOLEAN
     ,p_pos_structure_version_id     IN number
     ,p_object_version_number        IN number );

PROCEDURE delete_pos_structure_version_a
   (  p_validate                     IN BOOLEAN
     ,p_pos_structure_version_id     IN number
     ,p_object_version_number        IN number );
end per_pos_structure_version_bk3;

 

/
