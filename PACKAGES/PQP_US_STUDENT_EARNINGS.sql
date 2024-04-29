--------------------------------------------------------
--  DDL for Package PQP_US_STUDENT_EARNINGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_US_STUDENT_EARNINGS" AUTHID CURRENT_USER as
/* $Header: pqustrfe.pkh 120.0 2005/05/29 02:15:22 appldev noship $
  +============================================================================+
  |   Copyright (c) Oracle Corporation 1991,1992,1993.                         |
  |                  All rights reserved                                       |
  |   Description : Package and procedures to support Batch Element Entry      |
  |                 process for Student Eearnings.                             |
  |                                                                            |
  |   Change List                                                              |
  +=============+=========+=======+========+===================================+
  | Date        |Name     | Ver   |Bug No  |Description                        |
  +=============+=========+=======+========+===================================+
  | 23-SEP-2004 |tmehra   |115.0  |        |Created                            |
  | 14-FEB-2005 |hgattu   |115.1  |4180797 |                                   |
  |             |         |       |4181127 |                                   |
  | 21-MAR-2005 |rpinjala |115.2  |        |Added comments to the header       |
  | 21-APR-2005 |rpinjala |115.3  |4272173 |Added comments to the header       |
  |             |         |       |        |                                   |
  +=============+=========+=======+========+===================================+
*/

-- =============================================================================
-- ~ Transfer_Student_Earnings: This procedure is called to transfer the
-- ~ students earnings into the Financial Aid table IGF_SE_PAYMENT by calling
-- ~ the procedure igf_se_payment_pub. Each payroll action in Oracle Payroll
-- ~ will generate a row in the table IGF_SE_PAYMENT.
-- =============================================================================
procedure Transfer_Student_Earnings
         (errbuf               out nocopy varchar2
         ,retcode              out nocopy number
         ,p_begin_date_paid    in varchar2
         ,p_end_date_paid      in varchar2
         ,p_earnings_type      in varchar2
         ,p_selection_criteria in varchar2
         ,p_business_group_id  in varchar2
         ,p_is_asg_set         in varchar2
         ,p_assignment_set     in varchar2
         ,p_is_ssn             in varchar2
         ,p_ssn                in varchar2
         ,p_is_person_group    in varchar2
         ,p_person_group_id    in varchar2
         ,p_element_selection  in varchar2
         ,p_is_element_name    in varchar2
         ,p_element_type_id    in varchar2
         ,p_is_element_set     in varchar2
         ,p_element_set_id     in varchar2
          );

end;


 

/
