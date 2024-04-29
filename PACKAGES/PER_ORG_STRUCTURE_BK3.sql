--------------------------------------------------------
--  DDL for Package PER_ORG_STRUCTURE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ORG_STRUCTURE_BK3" AUTHID CURRENT_USER AS
/* $Header: peorsapi.pkh 120.2 2005/10/22 01:24:14 aroussel noship $ */

procedure delete_org_structure_b
    (p_validate                     in  boolean
    ,p_organization_structure_id    in  number
    ,p_object_version_number        in  number
    );

procedure delete_org_structure_a
  (p_validate                    in  boolean
  ,p_organization_structure_id   in  number
  ,p_object_version_number       in  number
  );

end per_org_structure_bk3;

 

/
