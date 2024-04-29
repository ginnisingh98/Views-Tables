--------------------------------------------------------
--  DDL for Package PER_US_EEO5_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_US_EEO5_PKG" AUTHID CURRENT_USER AS
/* $Header: peuseeo5.pkh 120.1.12000000.1 2007/02/06 14:47:40 appldev noship $ */

/*****************************************************************************
 Name      : get_sum
 Purpose   : function to sum of the employees.
*****************************************************************************/
FUNCTION get_sum(p_no_cons_wmale_emps   IN NUMBER
                ,p_no_cons_bmale_emps   IN NUMBER
		,p_no_cons_hmale_emps   IN NUMBER
		,p_no_cons_amale_emps   IN NUMBER
		,p_no_cons_imale_emps   IN NUMBER
		,p_no_cons_wfemale_emps IN NUMBER
		,p_no_cons_bfemale_emps IN NUMBER
		,p_no_cons_hfemale_emps IN NUMBER
		,p_no_cons_afemale_emps IN NUMBER
		,p_no_cons_ifemale_emps IN NUMBER) RETURN NUMBER;

/*****************************************************************************
 Name      : generate_xml_data
 Purpose   : Procedure is called from concurrent program EEO5 Reporting.
*****************************************************************************/
PROCEDURE generate_xml_data(errbuf                   OUT NOCOPY VARCHAR2
                           ,retcode                  OUT NOCOPY NUMBER
                           ,p_reporting_year         IN NUMBER
                           ,p_type_agency            IN VARCHAR2
                           ,p_total_enrollments      IN NUMBER
                           ,p_business_group_id      IN NUMBER
                           );


END per_us_eeo5_pkg;

 

/
