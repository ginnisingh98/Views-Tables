--------------------------------------------------------
--  DDL for Package HRFRBSOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRFRBSOC" AUTHID CURRENT_USER as
/* $Header: hrfrbsoc.pkh 115.4 2003/05/19 15:12:17 jheer noship $ */
--
PROCEDURE run_bs (errbuf              OUT NOCOPY VARCHAR2
                 ,retcode             OUT NOCOPY NUMBER
                 ,p_business_group_id IN NUMBER
                 ,p_template_id       IN NUMBER
                 ,p_year              IN NUMBER
                 ,p_company_id        IN NUMBER DEFAULT NULL
                 ,p_establishment_id  IN NUMBER DEFAULT NULL
                 ,p_process_name      IN VARCHAR2
                 ,p_debug             IN VARCHAR2);
--
PROCEDURE delete_gsp(errbuf              OUT NOCOPY VARCHAR2
                    ,retcode             OUT NOCOPY NUMBER
                    ,p_process_run_id    IN  NUMBER);
--
end hrfrbsoc;

 

/
