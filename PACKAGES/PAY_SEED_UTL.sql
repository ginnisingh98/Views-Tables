--------------------------------------------------------
--  DDL for Package PAY_SEED_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SEED_UTL" AUTHID CURRENT_USER AS
/* $Header: pyseedutl.pkh 120.1.12010000.1 2008/09/26 14:15:10 asnell noship $ */
PROCEDURE PLOG ( p_message IN varchar2 ) ;

FUNCTION get_creator_id (
             p_creator_type     in VARCHAR2
            ,p_creator_name1    in VARCHAR2
            ,p_creator_name2    in VARCHAR2
            ,p_legislation_code in VARCHAR2 )
         return NUMBER;

FUNCTION get_parameter_value (
             p_parameter_name     in VARCHAR2
            ,p_value_name1        in VARCHAR2
            ,p_value_name2        in VARCHAR2
            ,p_legislation_code   in VARCHAR2 )
         return VARCHAR2;

FUNCTION id_to_name (
             p_legislation_code   in VARCHAR2
            ,p_context            in VARCHAR2
            ,p_column             in VARCHAR2
            ,p_column_value       in VARCHAR2 )
         return VARCHAR2;

PROCEDURE uncompile_formulas ( p_route_id in number default null
                              ,p_user_name in varchar2 default null
                              ,p_legislation_code in varchar2 default null
                              ,p_formula_id in number default null);


END PAY_SEED_UTL;

/
