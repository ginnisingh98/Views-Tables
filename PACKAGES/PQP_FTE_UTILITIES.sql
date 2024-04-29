--------------------------------------------------------
--  DDL for Package PQP_FTE_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_FTE_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: pqftepkg.pkh 120.0 2005/05/29 01:47:56 appldev noship $ */

TYPE t_asg_details IS TABLE OF per_all_assignments_f.assignment_id%TYPE
    INDEX BY BINARY_INTEGER;

--
-- Set_FTE_Value
-- Calculate FTE and write to database.
PROCEDURE set_fte_value
  (p_assignment_id                IN            NUMBER
  ,p_business_group_id            IN            NUMBER
  ,p_calculation_date             IN            DATE
  ,p_fte_value                    IN            NUMBER
  );


-- Get_Fte_Value
-- Query and return the effective FTE
FUNCTION get_fte_value
  (p_assignment_id                IN            NUMBER
  ,p_calculation_date             IN            DATE
  ) RETURN NUMBER;


-- Update_FTE_For_Assignment
-- Calculate FTE and write to database for a single assignment
PROCEDURE update_fte_for_assignment
  (p_assignment_id                IN            NUMBER
  ,p_effective_date               IN            DATE
  );


--  Update_FTE_For_Assignment_Set
--  Calculate FTE and write to database for multiple assigments
PROCEDURE update_fte_for_assignment_set
  (ERRBUF                            OUT NOCOPY VARCHAR2
  ,RETCODE                           OUT NOCOPY NUMBER
  ,p_contract_type                IN            VARCHAR2
  ,p_payroll_id                   IN            NUMBER
  ,p_calculation_date             IN            VARCHAR2
  ,p_trace                        IN            VARCHAR2
  );

END pqp_fte_utilities;

 

/
