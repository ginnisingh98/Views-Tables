--------------------------------------------------------
--  DDL for Package PAY_ES_RUN_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ES_RUN_TYPES" AUTHID CURRENT_USER AS
/* $Header: pyesrunt.pkh 120.0 2005/05/29 04:38:58 appldev noship $ */

PROCEDURE rebuild_run_types(errbuf  OUT NOCOPY  VARCHAR2
                           ,retcode OUT NOCOPY  VARCHAR2
                           ,p_business_group_id VARCHAR2);
--
PROCEDURE create_element_run_type_usages(p_effective_date      IN  DATE
                                        ,p_element_name        IN  VARCHAR2
                                        ,p_element_type_id     IN  NUMBER
                                        ,p_legislation_code    IN  VARCHAR2
                                        ,p_business_gr_id      IN  NUMBER);
--
END pay_es_run_types;

 

/
