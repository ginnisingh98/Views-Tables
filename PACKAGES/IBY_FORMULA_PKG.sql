--------------------------------------------------------
--  DDL for Package IBY_FORMULA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_FORMULA_PKG" AUTHID CURRENT_USER AS
/*$Header: ibyforms.pls 115.7 2002/11/19 00:19:52 jleybovi ship $*/

/*
** This packge manages payee formulas, creation, modification
** loading , and deletion.
*/


    /* Record definition to store formula header information */
    TYPE risk_formula IS RECORD ( id number(15),
                                  name VARCHAR2(80),
                                  description VARCHAR2(240),
                                  flag number(15));

    TYPE formula_table IS TABLE OF risk_formula INDEX BY BINARY_INTEGER;

    /* Record definition to store Factor associated with formulas */
    TYPE risk_factor IS RECORD ( name VARCHAR2(30),
                                 weight number(15));

    TYPE factor_table IS TABLE OF risk_factor INDEX BY BINARY_INTEGER;

    /*
    ** Name : getPayeeFormula
    ** Purpose : Retrieves the payee Formula records into o_RiskFormula
    **           corresponding to payeeid.
    */
    Procedure getPayeeFormulas( i_payeeid in VARCHAR2,
                                o_RiskFormula out nocopy formula_table);

    /*
    ** Name : createFormula
    ** Purpose : Creates a new formula in the database for the payee Id passed
    **           and returns back the formula Is as output parameter.
    */
    Procedure createFormula( i_payeeId in VARCHAR2,
                             i_name in VARCHAR2,
                             i_description in VARCHAR2,
                             i_flag in integer,
                             i_count in integer,
                             i_Factors in factor_table,
                             o_id out nocopy integer);

    /*
    ** Name : modifyFormula
    ** Purpose : modifies the formula information corresponding to the
    **           formulaId with the passed information in the database.
    */
    Procedure modifyFormula( i_id in integer,
                             i_name in VARCHAR2,
                             i_description in VARCHAR2,
                             i_flag in integer,
                             i_count in integer,
                             i_Factors in factor_table);

    /*
    ** Name : deleteFormula
    ** Purpose : deletes the formula corresponding to the formulaId
    **           from the database.
    */
    Procedure deleteFormula( i_id in integer);

    /*
    ** Name : loadFormula
    ** Purpose : Retrievs  the Formula information and loads the
    **           factors of the formula into o_Factors
    **           corresponding to formulaId.
    */
    Procedure loadFormula( i_formulaId in integer,
                           o_name out nocopy varchar2,
                           o_description out nocopy varchar2,
                           o_flag out nocopy integer,
                           o_Factors out nocopy factor_table);

end iby_formula_pkg;


 

/
