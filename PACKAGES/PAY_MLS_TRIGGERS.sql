--------------------------------------------------------
--  DDL for Package PAY_MLS_TRIGGERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MLS_TRIGGERS" AUTHID CURRENT_USER AS
/* $Header: pymlstrg.pkh 120.0.12000000.1 2007/01/17 22:44:39 appldev noship $ */

 /*
   Global data structures to store trigger actions.
   This is required to avoid mutating/constraining errors
*/

  TYPE r_pur is record ( USER_ROW_ID               pay_user_rows_f.user_row_id%type,
                         row_low_range_or_name_n pay_user_rows_f.row_low_range_or_name%type,
                         row_low_range_or_name_o pay_user_rows_f.row_low_range_or_name%type) ;

  TYPE t_pur is table of r_pur index by binary_integer ;

  TYPE r_pbc is record ( balance_category_id    pay_balance_categories_f.balance_category_id%type,
                         user_category_name_n pay_balance_categories_f.user_category_name%type,
                         user_category_name_o pay_balance_categories_f.user_category_name%type) ;

  TYPE t_pbc is table of r_pbc index by binary_integer ;

  TYPE r_fml is record ( formula_id      ff_formulas_f.formula_id%type,
                         formula_name_o  ff_formulas_f.formula_name%type,
                         formula_name_n  ff_formulas_f.formula_name%type,
                         description_o   ff_formulas_f.description%type,
                         description_n   ff_formulas_f.description%type)  ;

  TYPE t_fml is table of r_fml index by binary_integer ;

  TYPE r_glb is record ( global_id            ff_globals_f.global_id%type,
                         global_description_o ff_globals_f.global_description%type,
                         global_description_n ff_globals_f.global_description%type,
                         global_name_o        ff_globals_f.global_name%type,
                         global_name_n        ff_globals_f.global_name%type) ;

  TYPE t_glb is table of r_glb index by binary_integer ;

  TYPE t_del is table of number index by binary_integer;

  --
  -- Table to hold information for deleted rows
  --

  l_pur_del  t_del ;
  l_pbc_del  t_del ;
  l_fml_del  t_del ;
  l_glb_del  t_del ;


  --
  -- table to hold information about inserted records
  --
  l_pur  t_pur ;
  l_pbc  t_pbc ;
  l_fml  t_fml ;
  l_glb  t_glb ;


/* End of variable declaration */
  procedure pur_ari ( p_user_row_id               in pay_user_rows_f.user_row_id%type,
                         p_row_low_range_or_name_n in pay_user_rows_f.row_low_range_or_name%type,
                         p_row_low_range_or_name_o in pay_user_rows_f.row_low_range_or_name%type) ;

  procedure pur_brd ( p_user_row_id in pay_user_rows_f.user_row_id%type ) ;

  procedure pur_asi ;

  procedure pur_asd ;

  procedure pbc_ari (p_balance_category_id     in pay_balance_categories_f.balance_category_id%type,
                        p_user_category_name_n  in pay_balance_categories_f.user_category_name%type,
                        p_user_category_name_o  in pay_balance_categories_f.user_category_name%type) ;

  procedure pbc_brd (p_balance_category_id in pay_balance_categories_f.balance_category_id%type) ;

  procedure pbc_asi  ;

  procedure pbc_asd  ;

  procedure glb_ari ( p_global_id            in ff_globals_f.global_id%type,
                         p_global_description_o in ff_globals_f.global_description%type,
                         p_global_description_n in ff_globals_f.global_description%type,
                         p_global_name_o        in ff_globals_f.global_name%type,
                         p_global_name_n        in ff_globals_f.global_name%type) ;

  procedure glb_brd (p_global_id             in ff_globals_f.global_id%type) ;

  procedure glb_asi  ;

  procedure glb_asd  ;

  procedure fml_ari ( p_formula_id      in ff_formulas_f.formula_id%type,
                       p_formula_name_o    in ff_formulas_f.formula_name%type,
                       p_formula_name_n    in ff_formulas_f.formula_name%type,
                       p_description_o     in ff_formulas_f.description%type,
                       p_description_n     in ff_formulas_f.description%type) ;

  procedure fml_brd (p_formula_id       in ff_formulas_f.formula_id%type) ;

  procedure fml_asi  ;

  procedure fml_asd  ;

  procedure set_dml_status (status  in varchar2);

END pay_mls_triggers ;




 

/
