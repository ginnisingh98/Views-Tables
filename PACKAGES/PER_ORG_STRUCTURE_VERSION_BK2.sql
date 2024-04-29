--------------------------------------------------------
--  DDL for Package PER_ORG_STRUCTURE_VERSION_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ORG_STRUCTURE_VERSION_BK2" AUTHID CURRENT_USER AS
/* $Header: peosvapi.pkh 120.2 2005/10/22 01:24:23 aroussel noship $ */

PROCEDURE update_org_structure_version_b
  (p_validate                      in     boolean
  ,p_effective_date                 in     date
  ,p_date_from                      in     date
  ,p_version_number                 in     number
  ,p_copy_structure_version_id      in     number
  ,p_date_to                        in     date
  ,p_request_id                     in     number
  ,p_program_application_id         in     number
  ,p_program_id                     in     number
  ,p_program_update_date            in     date
  ,p_topnode_pos_ctrl_enabled_fla   in     varchar2
  ,p_org_structure_version_id       in     number
  ,p_object_version_number          in     number
  );

PROCEDURE update_org_structure_version_a
  (p_validate                      in     boolean
  ,p_effective_date                 in     date
  ,p_date_from                      in     date
  ,p_version_number                 in     number
  ,p_copy_structure_version_id      in     number
  ,p_date_to                        in     date
  ,p_request_id                     in     number
  ,p_program_application_id         in     number
  ,p_program_id                     in     number
  ,p_program_update_date            in     date
  ,p_topnode_pos_ctrl_enabled_fla   in     varchar2
  ,p_org_structure_version_id       in     number
  ,p_object_version_number          in     number
  ,p_gap_warning                    in     boolean
  );
end per_org_structure_version_bk2;

 

/
