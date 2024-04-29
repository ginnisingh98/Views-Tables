--------------------------------------------------------
--  DDL for Package PQP_GB_OMP_EARNINGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_OMP_EARNINGS" AUTHID CURRENT_USER AS
/* $Header: pqpgboae.pkh 115.1 2002/12/03 11:29:48 cchappid noship $ */

-- Legislation Subgroup Code for all core objects
   g_template_leg_code       VARCHAR2(30):= 'GB';

------------------------------------------------------------------------
FUNCTION calculate_smp_average_earnings
           (p_assignment_id     IN NUMBER
           ,p_effective_date    IN DATE
           ,p_average_earnings  OUT NOCOPY NUMBER
           ,p_error_message     OUT NOCOPY VARCHAR2
           )
   RETURN NUMBER;
--
END pqp_gb_omp_earnings;

 

/
