--------------------------------------------------------
--  DDL for Package PQP_CPYTAXRUL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_CPYTAXRUL" AUTHID CURRENT_USER AS
/* $Header: pqtrulcp.pkh 115.1 2003/02/14 19:21:29 tmehra noship $ */


PROCEDURE COPY_TAX_RULES (
 errbuf                OUT NOCOPY VARCHAR2,
 retcode               OUT NOCOPY NUMBER,
 p_classification_name IN  pay_element_classifications.classification_name%type,
 p_source_category     IN  pay_taxability_rules.tax_category%type,
 p_target_category     IN  pay_taxability_rules.tax_category%type,
 p_source_state_code   IN  pay_us_states.state_code%type,
 p_target_state_code   IN  pay_us_states.state_code%type
  );

END PQP_CPYTAXRUL;

 

/
