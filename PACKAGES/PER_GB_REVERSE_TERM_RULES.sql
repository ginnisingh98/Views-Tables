--------------------------------------------------------
--  DDL for Package PER_GB_REVERSE_TERM_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_GB_REVERSE_TERM_RULES" AUTHID CURRENT_USER AS
/* $Header: pegbrtmr.pkh 120.0.12010000.1 2010/04/14 09:30:18 npannamp noship $ */


PROCEDURE VALIDATE_REVERSE_TERMINATION(p_person_id          		IN NUMBER
									  ,p_actual_termination_date 	IN DATE
									   );
END;

/
