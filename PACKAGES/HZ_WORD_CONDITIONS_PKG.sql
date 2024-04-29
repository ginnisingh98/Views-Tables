--------------------------------------------------------
--  DDL for Package HZ_WORD_CONDITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_WORD_CONDITIONS_PKG" AUTHID CURRENT_USER as
/*$Header: ARHDQWCS.pls 120.3 2005/10/30 04:19:34 appldev noship $ */
TYPE vlisttype IS TABLE of  VARCHAR2(255) INDEX BY BINARY_INTEGER ;
gbl_condition_rec  vlisttype ;

/*** This will assume that any comparison that we perform on the attributes, will be on the basis
         of the value returned by  get_gbl_condition_rec_value
****/
FUNCTION  tca_eval_condition_rec(
                                   p_input_str IN VARCHAR2,
                                   p_token_str IN VARCHAR2,
                                   p_repl_str  IN VARCHAR2,
                                   p_condition_id  IN NUMBER,
                                   p_user_spec_cond_val  IN VARCHAR2
			     	           )
RETURN VARCHAR2 ;

/*** This will be used to determine if this attribute is a condition attribute ***/
FUNCTION is_a_cond_attrib (p_attribute_id  IN  NUMBER )
RETURN BOOLEAN ;


/*** This will be used by search/staging  to populate the global condition record ***/
PROCEDURE set_gbl_condition_rec (p_attribute_id  IN  NUMBER, p_attribute_value IN VARCHAR2) ;

/*** This will be used to return the value of  condition record  *****/
FUNCTION get_gbl_condition_rec_value( p_entity IN VARCHAR2, p_attribute_name IN VARCHAR2 )
RETURN VARCHAR2 ;

/********* This will be a wrapper on top of the condition function, that would be used by
           HZ_TRANS_PKG, so that the user does not have to modify word_replace directly.
           A user who wants to seed a new condition function would write code here.
*****************/

FUNCTION evaluate_condition (
                                p_input_str IN VARCHAR2,
                                p_token_str IN VARCHAR2,
                                p_repl_str  IN VARCHAR2,
                                p_condition_id  IN NUMBER,
                                p_user_spec_cond_val  IN VARCHAR2
)
RETURN BOOLEAN ;


END; -- Package Specification HZ_WORD_CONDITIONS_PKG


 

/
