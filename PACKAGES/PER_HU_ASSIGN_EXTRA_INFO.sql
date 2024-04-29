--------------------------------------------------------
--  DDL for Package PER_HU_ASSIGN_EXTRA_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_HU_ASSIGN_EXTRA_INFO" AUTHID CURRENT_USER as
/* $Header: pehuaeip.pkh 120.0.12000000.1 2007/01/21 23:14:16 appldev ship $ */

procedure create_hu_assign_extra_info
  (p_assignment_id                 number
  ,p_information_type              varchar2
  ,p_aei_information_category      varchar2
  ,p_aei_information2              varchar2
  ,p_aei_information3              varchar2
  );
--
procedure update_hu_assign_extra_info
  (p_assignment_extra_info_id      number
  ,p_aei_information_category      varchar2
  ,p_aei_information2              varchar2
  ,p_aei_information3              varchar2
  );
--
end per_hu_assign_extra_info;

 

/
