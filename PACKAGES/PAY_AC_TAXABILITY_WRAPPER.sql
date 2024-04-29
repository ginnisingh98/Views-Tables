--------------------------------------------------------
--  DDL for Package PAY_AC_TAXABILITY_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AC_TAXABILITY_WRAPPER" AUTHID CURRENT_USER as
/* $Header: payactxabltywrap.pkh 120.1 2005/12/26 22:32 sudedas noship $ */


  PROCEDURE create_taxability_rules
                (p_classification_id        IN NUMBER
                ,p_tax_category             IN VARCHAR2
                ,p_jurisdiction             IN VARCHAR2 default null
                ,p_legislation_code         IN VARCHAR2 default null
                ,p_input_tax_type_value1    IN VARCHAR2 default null
                ,p_input_tax_type_value2    IN VARCHAR2 default null
                ,p_input_tax_type_value3    IN VARCHAR2 default null
                ,p_input_tax_type_value4    IN VARCHAR2 default null
                ,p_input_tax_type_value5    IN VARCHAR2 default null
                ,p_input_tax_type_value6    IN VARCHAR2 default null
                ,p_input_tax_type_value7    IN VARCHAR2 default null
                ,p_input_tax_type_value8    IN VARCHAR2 default null
                ,p_input_tax_type_value9    IN VARCHAR2 default null
                ,p_input_tax_type_value10   IN VARCHAR2 default null
                ,p_input_tax_type_value11   IN VARCHAR2 default null
                ,p_spreadsheet_identifier   IN VARCHAR2 default null
                );

end pay_ac_taxability_wrapper;

 

/
