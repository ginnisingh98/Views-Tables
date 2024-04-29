--------------------------------------------------------
--  DDL for Package PAY_TAXABILITY_RULES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_TAXABILITY_RULES_API" AUTHID CURRENT_USER as
/* $Header: paytxabltyrulapi.pkh 120.0 2005/05/29 11:51 appldev noship $ */


  FUNCTION check_taxability_rule_exists
                  (p_jurisdiction         IN VARCHAR2
                  ,p_legislation_code     IN VARCHAR2
                  ,p_classification_id    IN NUMBER default null
                  ,p_tax_category         IN VARCHAR2 default null
                  ,p_tax_type             IN VARCHAR2 default null
                  ,p_secondary_classification_id IN NUMBER default null
                  )
  RETURN VARCHAR2;

  Procedure create_taxability_rules
                ( p_validate                IN BOOLEAN
                ,p_jurisdiction             IN VARCHAR2
                ,p_tax_type                 IN VARCHAR2 default null
                ,p_tax_category             IN VARCHAR2 default null
                ,p_classification_id        IN  NUMBER default null
                ,p_taxability_rules_date_id IN NUMBER
                ,p_legislation_code         IN  VARCHAR2
                ,p_status                   IN  VARCHAR2
                ,p_secondary_classification_id IN NUMBER default null);


  Procedure update_taxability_rules
                ( p_validate                IN BOOLEAN
                ,p_jurisdiction             IN VARCHAR2
                ,p_tax_type                 IN VARCHAR2 default null
                ,p_tax_category             IN VARCHAR2 default null
                ,p_classification_id        IN  NUMBER  default null
                ,p_taxability_rules_date_id IN NUMBER
                ,p_legislation_code         IN  VARCHAR2
                ,p_status                   IN  VARCHAR2
                ,p_secondary_classification_id IN NUMBER default null
                ) ;


/***********************************************************
** We will never be deleting the data in pay_taxability_rules
** table. We will be updating the status to 'D' if the value
** already exists.
**
** Commenting out the delete becasue of the reason mentioned
** above.
Procedure delete_taxability_rules
                ( p_validate                IN BOOLEAN
                ,p_jurisdiction             IN VARCHAR2
                ,p_tax_type                 IN VARCHAR2
                ,p_tax_category             IN VARCHAR2
                ,p_classification_id        IN  NUMBER
                ,p_taxability_rules_date_id IN NUMBER
                ,p_legislation_code         IN  VARCHAR2
                ,p_status                   IN  VARCHAR2);
***********************************************************/


end pay_taxability_rules_api;

 

/
