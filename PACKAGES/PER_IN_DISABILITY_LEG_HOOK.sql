--------------------------------------------------------
--  DDL for Package PER_IN_DISABILITY_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_IN_DISABILITY_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: peinlhdi.pkh 120.0 2005/05/31 10:14 appldev noship $*/

PROCEDURE emp_disability_create
             (p_effective_date   IN DATE
	     ,p_person_id        IN NUMBER
	     ,p_category         IN VARCHAR2
	     ,p_status           IN VARCHAR2
	     ,p_degree           IN NUMBER
	     ,p_dis_information1 IN VARCHAR2
	     );

PROCEDURE emp_disability_update
             (p_effective_date   IN DATE
             ,p_disability_id    IN NUMBER
	     ,p_category         IN VARCHAR2
             ,p_status           IN VARCHAR2
             ,p_degree           IN NUMBER
             ,p_dis_information1 IN VARCHAR2
	     );

END   per_in_disability_leg_hook;

 

/
