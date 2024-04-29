--------------------------------------------------------
--  DDL for Package PAY_FI_ARCHIVE_TEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FI_ARCHIVE_TEL" AUTHID CURRENT_USER AS
/* $Header: pyfitela.pkh 120.1.12000000.2 2007/03/14 08:13:34 dbehera noship $ */

FUNCTION GET_PARAMETER(p_parameter_string IN VARCHAR2
                      ,p_token            IN VARCHAR2
                      ,p_segment_number   IN NUMBER default NULL ) RETURN VARCHAR2;



   PROCEDURE GET_ALL_PARAMETERS(
        p_payroll_action_id IN   NUMBER    					-- In parameter
       ,p_business_group_id OUT  NOCOPY NUMBER    			-- Core parameter
       ,p_effective_date	OUT  NOCOPY Date				-- Core parameter
       ,p_pension_ins_num OUT  NOCOPY VARCHAR2      		-- User parameter
       ,p_legal_employer_id OUT  NOCOPY NUMBER      		-- User parameter
       ,p_local_unit_id  	OUT  NOCOPY NUMBER     			-- User parameter
       ,p_annual_report     OUT  NOCOPY VARCHAR2            -- User parameter
       ,p_ref_date	OUT  NOCOPY Date					-- User parameter
       ,p_archive			OUT  NOCOPY  VARCHAR2           -- User parameter
       );



PROCEDURE RANGE_CODE (p_payroll_action_id    IN    NUMBER
                     ,p_sql    OUT   NOCOPY VARCHAR2) ;

PROCEDURE ASSIGNMENT_ACTION_CODE (p_payroll_action_id     IN NUMBER
                                 ,p_start_person          IN NUMBER
                                 ,p_end_person            IN NUMBER
                                 ,p_chunk                 IN NUMBER);

PROCEDURE INITIALIZATION_CODE(p_payroll_action_id IN NUMBER);


FUNCTION GET_DEFINED_BALANCE_ID(p_user_name IN VARCHAR2) RETURN NUMBER;

PROCEDURE ARCHIVE_CODE(p_assignment_action_id IN NUMBER
                      ,p_effective_date       IN DATE);


END PAY_FI_ARCHIVE_TEL;

 

/
