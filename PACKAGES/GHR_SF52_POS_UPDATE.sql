--------------------------------------------------------
--  DDL for Package GHR_SF52_POS_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_SF52_POS_UPDATE" AUTHID CURRENT_USER AS
/* $Header: ghpauppo.pkh 115.7 2004/01/28 21:37:45 ajose ship $ */

-- create the record types here
type position_data_rec_type is record
(position_id               per_positions.position_id%TYPE,
 organization_id           per_organization_units.organization_id%TYPE,
 job_id           	   per_positions.job_id%TYPE,
 agency_code_subelement    per_position_definitions.segment1%TYPE,
 location_id               hr_locations.location_id%TYPE,
 effective_end_date	   date,
 effective_date            date,
 datetrack_mode          varchar2(30)
);

type org_info_rec_type is record
        (information1   hr_organization_information.org_information1%type
        ,information2   hr_organization_information.org_information2%type
        ,information3   hr_organization_information.org_information3%type
        ,information4   hr_organization_information.org_information4%type
        ,information5   hr_organization_information.org_information5%type
        );

 TYPE segment_tab_type IS TABLE of VARCHAR2(60) INDEX by BINARY_INTEGER;


procedure update_position_info
(p_pos_data_rec    IN position_data_rec_type
) ;

Function pos_return_update_mode
  (p_position_id     IN     hr_all_positions_f.position_id%type,
   p_effective_date  IN     date )
 RETURN varchar2;

-- JH Added to update Position's Location during Update to HR.
PROCEDURE update_positions_location
 (p_position_id        IN       hr_all_positions_f.position_id%TYPE,
  p_location_id        IN       hr_all_positions_f.location_id%TYPE,
  p_effective_date     IN       date);

end ghr_sf52_pos_update;


 

/
