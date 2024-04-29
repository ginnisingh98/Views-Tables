--------------------------------------------------------
--  DDL for Package HR_BALANCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_BALANCES" AUTHID CURRENT_USER AS
/* $Header: pybalnce.pkh 120.0 2005/05/29 03:15:33 appldev noship $ */
--
  /*
/*

   ******************************************************************
   *                                                                *
   *  Copyright (C) 1989 Oracle Corporation UK Ltd.,                *
   *                   Richmond, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

    Name        : hr_balances

    Description : This package holds procedures and functions related to the
                  following tables :

                  PAY_ELEMENT_TYPES_F
                  PAY_INPUT_VALUES_F
		  PAY_SUB_CLASSIFICATION_RULES_F
                  PAY_BALANCE_FEEDS_F
                  PAY_BALANCE_TYPES
                  PAY_BALANCE_CLASSIFCIATIONS
                  PAY_DEFINED_BALANCES

    Uses        : hr_utility
    Used By     : hr_input_values
		: hr_elements

    Change List
    -----------
    Date        Name          Vers    Bug No     Description
    ----        ----          ----    ------     -----------
    07-DEC-92   NLBarlow       1.00              Added comments.
    29-DEC-92   NLBarlow       1.01              Added business group
                                                 and legislation code.
    11-JAN-93   NLBarlow       1.02              Added startup code.
    20-JAN-93   NLBarlow       1.03              Change in Standards.
    08-FEB-93   NLBarlow       1.04              Added Delete Next Change
                                                 and optimised.
    11-MAR-93   HMINTON        1.05              Added exit at end.
    28-MAR-94   R.Neale       40.02	         Added header info
    08-NOV-99   meshah        115.1              Added new function decode_balance.
--
  */
/*
    NAME
        ins_balance_feed
    DESCRIPTION
        Insert balance feeds.
*/
--
	PROCEDURE ins_balance_feed
                  (p_option                        in varchar2,
                   p_input_value_id                in number,
                   p_element_type_id               in number,
                   p_primary_classification_id     in number,
                   p_sub_classification_id         in number,
                   p_sub_classification_rule_id    in number,
                   p_balance_type_id               in number,
                   p_scale                         in varchar2,
                   p_session_date                  in date,
                   p_business_group                in varchar2,
		   p_legislation_code              in varchar2,
		   p_mode                          in varchar2);
--
/*
    NAME
        upd_balance_feed
    DESCRIPTION
        Updated balance feeds.
*/
--
	PROCEDURE upd_balance_feed
                  (p_option                        in varchar2,
                   p_balance_feed_id               in number,
                   p_primary_classification_id     in number,
                   p_sub_classification_id         in number,
                   p_balance_type_id               in number,
                   p_scale                         in varchar2,
		   p_legislation_code              in varchar2);
--
/*
    NAME
    chk_del_balance_feed
    DESCRIPTION
    checks to see if it is permissable to delete balance feeds displayed on
    the element type form. This will not be allowed if the balance feed has
    been created by a balance classification.
*/
    PROCEDURE chk_del_balance_feed
              (p_balance_feed_id        in number,
               p_balance_type_id        in number);
/*
    NAME
        del_balance_feed
    DESCRIPTION
        Delete  balance feeds.
*/
--
	PROCEDURE del_balance_feed
                  (p_option              	   in varchar2,
                   p_delete_mode                   in varchar2,
                   p_balance_feed_id               in number,
                   p_input_value_id                in number,
                   p_element_type_id               in number,
                   p_primary_classification_id     in number,
                   p_sub_classification_id         in number,
                   p_sub_classification_rule_id    in number,
                   p_balance_type_id               in number,
                   p_session_date          	   in date,
                   p_effective_end_date            in date,
                   p_legislation_code      	   in varchar2,
                   p_mode                          in varchar2);
--
/*
    NAME
        del_balance_type_cascade
    DESCRIPTION
        Cascade delete children records of balance type record,
        Balance dimensions, Balance classifications, Balance feeds.
*/
--
	PROCEDURE del_balance_type_cascade
                  (p_balance_type_id               in number,
                   p_legislation_code              in varchar2,
                   p_mode                          in varchar2);
--
/*
    NAME
        chk_ins_sub_class_rules
    DESCRIPTION
        Checks to see if it is ok to insert a sub classification rule. If it
        is then a new end date will be returned. This will be either the last
        end date of the element type or the last date the rule will not
        overlap with another sub_classification_rule.
*/
FUNCTION        chk_ins_sub_class_rules(
				p_sub_class_rule_id	number,
                                p_element_type_id       number,
                                p_classification_id     number,
                                p_session_date          date) return date;
--
--
/*
    NAME
        chk_ins_balance_feed
    DESCRIPTION
        Checks to see if it is ok to insert a manual balance feed. If it
        is then a new end date will be returned. This will be either the last
        end date of the element type or the last date the feed will not
        overlap with another balance feed.
*/
FUNCTION        chk_ins_balance_feed(
                                p_balance_feed_id       number,
                                p_input_value_id        number,
                                p_balance_type_id       number,
                                p_session_date          date) return date;
--

/*
    NAME
        decode_balance
    DESCRIPTION
        This function looks in the table pay_balance_types_tl for balance type id passed to
        the function. This function is called for the creation of the view
        pay_us_earnings_amounts_v which is in the payusblv.odf.
*/

FUNCTION        decode_balance( p_balance_type_id       number) return varchar2;
--

END hr_balances;

 

/
