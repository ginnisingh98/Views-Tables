--------------------------------------------------------
--  DDL for Package PER_POS_STRUCTURE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_POS_STRUCTURE_BK3" AUTHID CURRENT_USER AS
/* $Header: pepstapi.pkh 120.2 2005/10/22 01:24:54 aroussel noship $ */

procedure delete_pos_structure_b
    (p_validate                     in  boolean
    ,p_position_structure_id    in  number
    ,p_object_version_number        in  number
    );

procedure delete_pos_structure_a
  (p_validate                    in  boolean
  ,p_position_structure_id   in  number
  ,p_object_version_number       in  number
  );

end per_pos_structure_bk3;

 

/
