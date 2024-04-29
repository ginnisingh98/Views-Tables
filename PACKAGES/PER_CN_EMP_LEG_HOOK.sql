--------------------------------------------------------
--  DDL for Package PER_CN_EMP_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CN_EMP_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: pecnlhpp.pkh 120.0 2005/05/31 06:54:46 appldev noship $ */

  g_package  VARCHAR2(33) := 'per_cn_emp_leg_hook.';

/* Removed p_per_information14,p_per_information15 w.r.t bug 3075230*/
 PROCEDURE check_employee( p_business_group_id    IN NUMBER
		          ,p_national_identifier  IN VARCHAR2
   		          ,p_person_type_id       IN NUMBER
   		          ,p_hire_date            IN DATE
                          ,p_per_information4     IN VARCHAR2
                          ,p_per_information5     IN VARCHAR2
                          ,p_per_information6     IN VARCHAR2
                          ,p_per_information7     IN VARCHAR2
                          ,p_per_information8     IN VARCHAR2
                          ,p_per_information10    IN VARCHAR2
                          ,p_per_information11    IN VARCHAR2
                          ,p_per_information12    IN VARCHAR2
                          ,p_per_information17    IN VARCHAR2) ;
--
/* Removed p_per_information14,p_per_information15 w.r.t bug 3075230*/
 PROCEDURE check_applicant(p_business_group_id    IN NUMBER
		          ,p_national_identifier  IN VARCHAR2
   		          ,p_person_type_id       IN NUMBER
   		          ,p_date_received        IN DATE
                          ,p_per_information4     IN VARCHAR2
                          ,p_per_information5     IN VARCHAR2
                          ,p_per_information6     IN VARCHAR2
                          ,p_per_information7     IN VARCHAR2
                          ,p_per_information8     IN VARCHAR2
                          ,p_per_information10    IN VARCHAR2
                          ,p_per_information11    IN VARCHAR2
                          ,p_per_information12    IN VARCHAR2
                          ,p_per_information17    IN VARCHAR2);
--
/* Removed p_per_information14,p_per_information15 w.r.t bug 3075230*/
PROCEDURE check_person   (p_national_identifier  IN VARCHAR2
   		          ,p_person_type_id       IN NUMBER
   		          ,p_effective_date       IN DATE
			  ,p_person_id            IN NUMBER
                          ,p_per_information4     IN VARCHAR2
                          ,p_per_information5     IN VARCHAR2
                          ,p_per_information6     IN VARCHAR2
                          ,p_per_information7     IN VARCHAR2
                          ,p_per_information8     IN VARCHAR2
                          ,p_per_information10    IN VARCHAR2
                          ,p_per_information11    IN VARCHAR2
                          ,p_per_information12    IN VARCHAR2
                          ,p_per_information17    IN VARCHAR2);
			  --
END per_cn_emp_leg_hook;

 

/
