--------------------------------------------------------
--  DDL for Package PAYVWELE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAYVWELE" AUTHID CURRENT_USER AS
/* $Header: payvwele.pkh 115.3 2003/05/09 17:32:14 rsirigir ship $ */
--
--
PROCEDURE forms_startup ( p_assignment_id NUMBER,
                          p_assignment_action_id NUMBER,
			  p_session_date DATE,
	                  p_action_date IN OUT NOCOPY  DATE,
			  p_per_month IN OUT  NOCOPY NUMBER,
		          p_per_qtd IN OUT  NOCOPY NUMBER,
			  p_per_ytd IN OUT  NOCOPY NUMBER,
			  p_asg_lr IN OUT  NOCOPY NUMBER,
			  p_asg_ptd IN OUT  NOCOPY NUMBER,
			  p_asg_month IN OUT  NOCOPY NUMBER,
			  p_asg_qtd IN OUT  NOCOPY NUMBER,
			  p_asg_ytd IN OUT  NOCOPY NUMBER,
			  p_asg_itd IN OUT  NOCOPY NUMBER,
			  p_asg_gre_itd IN OUT  NOCOPY NUMBER,
			  p_tax_unit_id IN OUT  NOCOPY NUMBER,
                          p_level      IN VARCHAR2,
                          p_legislation_code IN VARCHAR2);
--
FUNCTION get_tax_unit_id ( p_assignment_id NUMBER,
			   p_session_date  DATE ) RETURN NUMBER;
--
FUNCTION get_dim_id (p_dim_suffix IN VARCHAR2, p_legislation_code IN VARCHAR2) RETURN NUMBER;
--
FUNCTION get_action_date (p_assignment_action_id IN NUMBER) RETURN DATE;
--
FUNCTION get_fpd_or_atd(p_assignment_id IN NUMBER,
                        p_session_date IN DATE) RETURN DATE;
--
END payvwele;

 

/
