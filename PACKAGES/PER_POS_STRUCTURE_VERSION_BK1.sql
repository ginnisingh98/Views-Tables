--------------------------------------------------------
--  DDL for Package PER_POS_STRUCTURE_VERSION_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_POS_STRUCTURE_VERSION_BK1" AUTHID CURRENT_USER AS
/* $Header: pepsvapi.pkh 120.2 2005/10/22 01:25:03 aroussel noship $ */

PROCEDURE create_pos_structure_version_b
  (p_validate                      in     boolean
  ,p_effective_date                 in     date
  ,p_position_structure_id      in     number
  ,p_date_from                      in     date
  ,p_version_number                 in     number
  ,p_copy_structure_version_id      in     number
  ,p_date_to                        in     date
  ,p_request_id                     in     number
  ,p_program_application_id         in     number
  ,p_program_id                     in     number
  ,p_program_update_date            in     date
);

PROCEDURE create_pos_structure_version_a
  (p_validate                      in     boolean
  ,p_effective_date                 in     date
  ,p_position_structure_id      in     number
  ,p_date_from                      in     date
  ,p_version_number                 in     number
  ,p_copy_structure_version_id      in     number
  ,p_date_to                        in     date
  ,p_request_id                     in     number
  ,p_program_application_id         in     number
  ,p_program_id                     in     number
  ,p_program_update_date            in     date
  ,p_pos_structure_version_id       in     number
  ,p_object_version_number          in     number
  ,p_gap_warning                    in     boolean
  );
end per_pos_structure_version_bk1;

 

/
