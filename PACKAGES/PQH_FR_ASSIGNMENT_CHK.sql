--------------------------------------------------------
--  DDL for Package PQH_FR_ASSIGNMENT_CHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_ASSIGNMENT_CHK" AUTHID CURRENT_USER AS
/* $Header: pqasgchk.pkh 120.0 2005/05/29 01:25 appldev noship $ */
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

procedure chk_Identifier(p_identifier in Varchar2);

procedure chk_percent_affected(p_percent_effected in varchar2, p_person_id in number, p_effective_date in date, p_assignment_id number default Null);

procedure chk_position(p_position_id in Number,
                       p_person_id in Number,
                       p_effective_date in DATE);

procedure chk_tot_percent_affected(p_percent_effected in varchar2,
                                   p_person_id in number,
                                   p_effective_date in date,
                                   p_assignment_id number default Null);

procedure chk_type(p_type in varchar2,
                   p_person_id in Number,
                   p_effective_date in DATE,
                   p_position_id in Number);

procedure chk_Primary_affectation(p_person_id in number,
                                  p_effective_date in date,
                                  p_admin_career_id in number);

procedure chk_situation(p_person_id in Number,
                        p_effective_date in DATE);


END PQH_FR_ASSIGNMENT_CHK;

 

/
