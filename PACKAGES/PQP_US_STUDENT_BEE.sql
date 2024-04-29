--------------------------------------------------------
--  DDL for Package PQP_US_STUDENT_BEE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_US_STUDENT_BEE" AUTHID CURRENT_USER as
/* $Header: pqusstbe.pkh 120.0 2005/05/29 02:14:46 appldev noship $
  +============================================================================+
  |   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved     |
  |                                                                            |
  |   Description : Package and procedures to support Batch Element Entry      |
  |                 process for Student Eearnings.                             |
  |                                                                            |
  |   Change List                                                              |
  +============+=========+=======+========+====================================+
  |Date        |Name     |Ver    |Bug No  |Description                         |
  +============+=========+=======+========+====================================+
  |23-SEP-2004 |tmehra   |115.1  |        |Created                             |
  |10-DEC-2004 |tmehra   |115.1  |        |Fixed the GSCC warning.             |
  |10-FEB-2005 |hgattu   |115.3  |4094250 |                                    |
  |14-FEB-2005 |hgattu   |115.4  |4180797 |                                    |
  |            |         |       |4181127 |                                    |
  |07-MAR-2005 |rpinjala |115.5  |4219848 |                                    |
  |21-APR-2005 |rpinjala |115.6  |4272173 |                                    |
  |            |         |       |        |                                    |
  |            |         |       |        |                                    |
  |            |         |       |        |                                    |
  +============+=========+=======+========+====================================+
*/

-- =============================================================================
-- ~ Create_Student_Batch_Entry : create student earnings batch header
-- =============================================================================
procedure Create_Student_Batch_Entry
         (errbuf              out nocopy varchar2
         ,retcode             out nocopy number
         ,p_effective_date     in varchar2
         ,p_earnings_type      in varchar2
         ,p_selection_criteria in varchar2
         ,p_business_group_id  in varchar2
         ,p_is_asg_set         in varchar2
         ,p_assignment_set     in varchar2
         ,p_is_ssn             in varchar2
         ,p_ssn                in varchar2
         ,p_is_person_group    in varchar2
         ,p_person_group_id    in varchar2
         ,p_element_type_id    in varchar2
          );
end;

 

/
