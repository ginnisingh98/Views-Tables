--------------------------------------------------------
--  DDL for Package PERFRPHR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PERFRPHR" AUTHID CURRENT_USER AS
/* $Header: perfrphr.pkh 120.0.12000000.1 2007/01/22 03:14:22 appldev noship $ */

FUNCTION get_emp_total (p_effective_date    IN DATE,
                        p_est_id            IN NUMBER   DEFAULT NULL,
                        p_ent_id            IN NUMBER   DEFAULT NULL,
                        p_sex               IN VARCHAR2 DEFAULT NULL,
                        p_udt_column        IN VARCHAR2,
                        p_include_suspended IN VARCHAR2 DEFAULT 'N') RETURN NUMBER;

PROCEDURE run_pre_hire (errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY NUMBER,
                        p_business_group_id IN NUMBER DEFAULT NULL,
                        p_establishment_id  IN NUMBER DEFAULT NULL,
                        p_person_id         IN NUMBER DEFAULT NULL,
                        p_contact_name      IN VARCHAR2 DEFAULT NULL,
                        p_contact_telephone IN VARCHAR2 DEFAULT NULL,
                        p_fax               IN VARCHAR2 DEFAULT NULL,
                        p_email_address     IN VARCHAR2 DEFAULT NULL,
                        p_dads              IN VARCHAR2 DEFAULT NULL,
                        p_pmf5              IN VARCHAR2 DEFAULT NULL,
                     -- p_prem              IN VARCHAR2 DEFAULT NULL,
                        p_date              IN VARCHAR2 DEFAULT NULL,
                        p_batch             IN VARCHAR2 DEFAULT NULL,
                        p_acknowledgement   IN VARCHAR2 DEFAULT NULL);

/* Bug 4106045 */
FUNCTION convert_uppercase(p_input_string  varchar2)
                           return varchar2;
/* Bug 4106045 */

end PERFRPHR;

 

/
