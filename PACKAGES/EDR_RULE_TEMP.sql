--------------------------------------------------------
--  DDL for Package EDR_RULE_TEMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_RULE_TEMP" AUTHID CURRENT_USER AS
/* $Header: EDRTEMPS.pls 120.2.12000000.1 2007/01/18 05:55:44 appldev ship $ */


TYPE edr_array_date IS TABLE OF DATE;


/* obtain rule details for a transaction, insert into temp tables */
PROCEDURE GET_DETAILS_TRANS ( p_trans_id  IN  VARCHAR2, p_input_var IN VARCHAR2 ) ;


/* obtain rule details for a rule, insert into temp tables */
PROCEDURE GET_DETAILS_RULE ( p_trans_name  IN  VARCHAR2, p_rule_name IN VARCHAR2 ) ;


/* clear relevant rows in temp tables for a transaction */
PROCEDURE CLEAR_DETAILS_TRANS (	p_trans_id    IN VARCHAR2 ) ;


/* clear relevant rows in temp tables for a rule */
PROCEDURE CLEAR_DETAILS_RULE (	p_trans_id   	IN VARCHAR2,
				p_rule_id	IN VARCHAR2
				);

/* due to empty temp table, take event key as input to generate rows */
PROCEDURE GET_TVAR_RULE_DETAIL ( p_trans_var  IN  VARCHAR2 ) ;

/* due to empty temp table, take event key as input to generate rows */
PROCEDURE GET_RVAR_RULE_DETAIL ( p_trans_rule  IN  VARCHAR2 ) ;


/* 3016075: event key changed to instance id, use it to find input var */
PROCEDURE GET_TRANS_RULES ( p_trans_config_id  IN  VARCHAR2 ) ;

/* 3016075: event key changed to instance id, use it to find input var */
PROCEDURE GET_RULE_DETAIL ( p_rule_config_id  IN  VARCHAR2 ) ;

--This API is used to set the transaction details in the temp tables
--for the specified transaction ID and variable name.
PROCEDURE SET_TRANSACTION_DETAILS(P_TRANSACTION_ID IN VARCHAR2,
                                  P_VARIABLE_NAME  IN VARCHAR2);

--This API is used to set the rule details in the temp tables
--for the specified transaction ID and rule ID.
PROCEDURE SET_RULE_DETAILS(P_TRANSACTION_ID IN VARCHAR2,
                           P_RULE_ID        IN VARCHAR2);

--This function returns the specified display date in String format.
FUNCTION DISPLAY_DATE(P_DATE IN DATE)
RETURN VARCHAR2;

PROCEDURE CHECK_AND_SYNC_RULE_TABLE(P_TRANSACTION_ID IN VARCHAR2);

END EDR_RULE_TEMP;

 

/
