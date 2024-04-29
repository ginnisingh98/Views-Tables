--------------------------------------------------------
--  DDL for Package Body HR_BALANCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_BALANCES" AS
/* $Header: pybalnce.pkb 120.1 2005/08/31 08:39:23 susivasu noship $ */
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
--
    Name        : hr_balances
--
    Description : This package holds procedures and functions related to the
                  following tables :
--
                  PAY_ELEMENT_TYPES_F
                  PAY_INPUT_VALUES_F
                  PAY_SUB_CLASSIFICATION_RULES_F
                  PAY_BALANCE_FEEDS_F
                  PAY_BALANCE_TYPES
                  PAY_BALANCE_CLASSIFCIATIONS
                  PAY_DEFINED_BALANCES
--
    Uses        : hr_utility
    Used By     : n/a
--
    Test List
    ---------
    Procedure                     Name       Date        Test Id Status
    +----------------------------+----------+-----------+-------+------------+
    get_pay_value                 NLBarlow   03-DEC-92    1      Completed
    +------------------------------------------------------------------------+
    ins_balance_feed              NLBarlow   03-DEC-92    1      Completed
    +------------------------------------------------------------------------+
    upd_balance_feed              NLBarlow   03-DEC-92    1      Completed
    +------------------------------------------------------------------------+
    chk_del_balance_feed	  M Dyer     05-Mar-93    1	 Completed
    +------------------------------------------------------------------------+
    del_balance_feed              NLBarlow   03-DEC-92    1      Completed
    +------------------------------------------------------------------------+
    del_balance_type_cascade      NLBarlow   01-DEC-92    1      Completed
    +------------------------------------------------------------------------+
--
--
    Change List
    -----------
    Date        Name          Vers    Bug No     Description
    ----        ----          ----    ------     -----------
    07-DEC-92   NLBarlow       1.00              Prepared for ARCS.
    29-DEC-92   NLBarlow       1.01              Added business group
                                                 and legislation code.
    11-JAN-93   NLBarlow       1.02              Added startup logic.
    20-JAN-93   NLBarlow       1.03              Change in standards.
    08-FEB-93   NLBarlow       1.04              Added Delete Next Change
                                                 and optimised.
    24-FEB-93   M DYER	       1.06  		 Corrected message name
						 for HR_6185_BAL_FEED_EXISTS
    05-Mar-93   M DYER	       30.22  		 Added chk_del_balance_feed
						 procedure.
    11-MAR-93   H MINTON       30.23             Added exit to last line.
    18-MAR-93   NLBarlow       30.24             Trunced sysdates and
                                                 validation on primary
                                                 bal class
    15-JUL-93   M Dyer	       30.25	B82 	 changed behaviour of
						 ownership details for startup
					  	 records.
    03-Aug-93   M Dyer	       40.00		 Added chk_ins_balance_feeds
						 and chk_ins_sub_class_rules
						 These check the max end date
						 for insert and next change
						 delete on these records.
    16-Aug-93   M Kaddir       30.31/   B203     Replaced function
                                40.01            GET_PAY_VALUE with a call
                                                 to HR_INPUT_VALUES.GET_PAY_
                                                 VALUE_NAME to use HR_LOOKUPS
                                                 for Pay Value instead of
                                                 PAY_NAME_TRANSLATIONS
    28-MAR-94   R Neale        40.02             Added header info
    01-MAR-99   J. Moyano     115.1              MLS changes. Added references
                                                 to _TL tables.
    15-FEB-00   A. Logue      115.4              Utf8 Support.  Input Value
                                                 names extended to 80.
    29-MAR-01   M.Reid        115.5              Added index hints for
                                                 balance_type_pk
    01-OCT-2002 RThirlby      115.6              Bug 2595797 - Updated
                                                 ins_balance_feed to have an
                                                 option 'INS_PRIMARY_BALANCE
                                                 _FEED' used in balance form to
                                                 insert a feed when a primary
                                                 balance is inserted.
    16-OCT-2002 RThirlby      115.7              Updated del_balnce_type_cascade
                                                 to ensure defined_balance
                                                 child rows are deleted prior
                                                 to deleting the defined bal.
    03-DEC-2002 ALogue        115.8    2667222   Performance fixes in
                                                 chk_del_balance_feed.
                                                 Assumes Pay Value input values
                                                 have untranslated name in base
                                                 table.
    31-AUG-2005 Adkumar       115.9    4571260   Changed call to
                                                 hr_balances.ins_balance_feed
                                                 for option=INS_MANUAL_FEED
                                                 to insert business group id
                                                 and legislation code as passed
                                                 by user as parameter instead of
                                                 inserting BG and legislation
                                                 of Element.

--
  */
--
    PROCEDURE ins_application_ownership
              (p_balance_feed_id               in varchar2,
	       p_input_value_id			in number,
	       p_balance_type_id		in number) IS
/*
    NAME
        ins_application_ownership
    DESCRIPTION
        Insert startup data into hr_application_ownerships.
    NOTE (M Dyer)
	Changes in the way child records in startup mode work mean that we
	no longer want to derive the ownership of the balance feeds from the
	current session. Instead we want to derive it from the record that is
	responsible for creating the balance feed. If a balance feed is created
	from the element type form then it will inherit the ownerships of the
	input value record this will be clear because the balance_id will be
	null. If the balance feed is created from the balance type form then
	the input value id will be null.
*/
--
    BEGIN
--
    hr_utility.set_location('ins_application_ownership', 1);
--
    if p_input_value_id is null then
    -- We want the balance feed to inherit the ownership of the balance type
--
    INSERT INTO hr_application_ownerships
    (KEY_NAME,PRODUCT_NAME,KEY_VALUE)
    SELECT 'BALANCE_FEED_ID',
           AO.PRODUCT_NAME,
           p_balance_feed_id
    FROM   hr_application_ownerships AO
    WHERE  ao.key_name = 'BALANCE_TYPE_ID'
    AND	   ao.key_value = to_char(p_balance_type_id);
--
    elsif p_balance_type_id is null then
--
    hr_utility.set_location('ins_application_ownership', 2);
--
    INSERT INTO hr_application_ownerships
    (KEY_NAME,PRODUCT_NAME,KEY_VALUE)
    SELECT 'BALANCE_FEED_ID',
           AO.PRODUCT_NAME,
           p_balance_feed_id
    FROM   hr_application_ownerships AO
    WHERE  ao.key_name = 'INPUT_VALUE_ID'
    AND    ao.key_value = to_char(p_input_value_id);
--
    end if;
--
    END ins_application_ownership;
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
               p_mode                          in varchar2) IS
/*
    NAME
        ins_balance_feed
    DESCRIPTION
        Insert balance feeds.
*/
--
-- Declare local variables
--
v_sequence      number;
v_feed          number;
v_pay_value     varchar2(80);
l_new_end_date date;
--
-- Declare local cursors
--
        CURSOR cur_get_pay_pay_value IS
                SELECT  /*+ INDEX (BT PAY_BALANCE_TYPES_PK)  */
                        pay_balance_feeds_s.nextval a_balance_feed_id,
                        iv.effective_start_date     a_effective_start_date,
                        iv.effective_end_date       a_effective_end_date,
                        iv.input_value_id           a_input_value_id,
                        bc.balance_type_id          a_balance_type_id,
                        bc.scale                    a_scale,
                        iv.business_group_id        a_business_group_id,
                        iv.legislation_code         a_legislation_code,
                        iv.legislation_subgroup     a_legislation_subgroup,
                        iv.last_updated_by          a_last_updated_by,
                        iv.last_update_login        a_last_update_login,
                        iv.created_by               a_created_by
                FROM    pay_balance_types           bt,
                        pay_balance_classifications bc,
                        pay_element_types_f         et,
                        pay_input_values_f          iv
                WHERE   iv.input_value_id        = p_input_value_id
                AND     et.element_type_id       = iv.element_type_id
                AND     et.effective_start_date <= p_session_date
                AND     et.effective_end_date   >= p_session_date
                AND     bc.classification_id     = p_primary_classification_id
                AND     bt.balance_type_id       = bc.balance_type_id
                AND     nvl(bt.business_group_id,nvl(p_business_group,0))
                            = nvl(p_business_group,0)
                AND     nvl(bt.legislation_code,nvl(p_legislation_code,' '))
                            = nvl(p_legislation_code,' ')
                AND     substr(iv.uom,1,1) = substr(bt.balance_uom,1,1)
                AND     ((bt.balance_uom = 'M'
                          AND et.output_currency_code = bt.currency_code)
                         OR bt.balance_uom <> 'M')
		FOR UPDATE;
--
	CURSOR cur_check_pay_pay_value IS
		SELECT  feed.balance_feed_id
        	FROM    pay_balance_feeds_f         feed,
                        pay_balance_types           bt,
                        pay_balance_classifications bc,
                        pay_element_types_f         et,
                        pay_input_values_f          iv
        	WHERE   iv.input_value_id        = p_input_value_id
        	AND     et.element_type_id       = iv.element_type_id
                AND     et.effective_start_date <= p_session_date
                AND     et.effective_end_date   >= p_session_date
        	AND     bc.classification_id     = p_primary_classification_id
        	AND     bt.balance_type_id       = bc.balance_type_id
                AND     nvl(bt.business_group_id,nvl(p_business_group,0))
                            = nvl(p_business_group,0)
                AND     nvl(bt.legislation_code,nvl(p_legislation_code,' '))
                            = nvl(p_legislation_code,' ')
                AND     substr(iv.uom,1,1) = substr(bt.balance_uom,1,1)
        	AND     ((bt.balance_uom = 'M'
                	  AND et.output_currency_code = bt.currency_code)
                	 OR bt.balance_uom <> 'M')
        	AND     feed.input_value_id        = iv.input_value_id
        	AND     feed.balance_type_id       = bt.balance_type_id
		AND	feed.effective_start_date <= iv.effective_end_date
		AND	feed.effective_end_date   >= iv.effective_start_date;
--
        CURSOR cur_get_per_pay_value_prim IS
                SELECT  /*+ INDEX (BT PAY_BALANCE_TYPES_PK)  */
                        pay_balance_feeds_s.nextval a_balance_feed_id,
                        iv.effective_start_date     a_effective_start_date,
                        iv.effective_end_date       a_effective_end_date,
                        iv.input_value_id           a_input_value_id,
                        bc.balance_type_id          a_balance_type_id,
                        bc.scale                    a_scale,
                        iv.business_group_id        a_business_group_id,
                        iv.legislation_code         a_legislation_code,
                        iv.legislation_subgroup     a_legislation_subgroup,
                        iv.last_updated_by          a_last_updated_by,
                        iv.last_update_login        a_last_update_login,
                        iv.created_by               a_created_by
                FROM    pay_balance_types           bt,
                        pay_balance_classifications bc,
                        pay_element_types_f         et,
                        pay_input_values_f          iv
                WHERE   iv.input_value_id        = p_input_value_id
                AND     et.element_type_id       = iv.element_type_id
                AND     et.effective_start_date <= p_session_date
                AND     et.effective_end_date   >= p_session_date
                AND     bc.classification_id     = p_primary_classification_id
                AND     bt.balance_type_id       = bc.balance_type_id
                AND     nvl(bt.business_group_id,nvl(p_business_group,0))
                            = nvl(p_business_group,0)
                AND     nvl(bt.legislation_code,nvl(p_legislation_code,' '))
                            = nvl(p_legislation_code,' ')
                AND     substr(iv.uom,1,1) = substr(bt.balance_uom,1,1)
                AND     ((bt.balance_uom = 'M'
                          AND et.output_currency_code = bt.currency_code)
                         OR bt.balance_uom <> 'M')
                FOR UPDATE;
--
	CURSOR cur_check_per_pay_value_prim IS
                SELECT  feed.balance_feed_id
                FROM    pay_balance_feeds_f         feed,
                        pay_balance_types           bt,
                        pay_balance_classifications bc,
                        pay_element_types_f         et,
                        pay_input_values_f          iv
                WHERE   iv.input_value_id        = p_input_value_id
                AND     et.element_type_id       = iv.element_type_id
                AND     et.effective_start_date <= p_session_date
                AND     et.effective_end_date   >= p_session_date
                AND     bc.classification_id     = p_primary_classification_id
                AND     bt.balance_type_id       = bc.balance_type_id
                AND     nvl(bt.business_group_id,nvl(p_business_group,0))
                            = nvl(p_business_group,0)
                AND     nvl(bt.legislation_code,nvl(p_legislation_code,' '))
                            = nvl(p_legislation_code,' ')
                AND     substr(iv.uom,1,1) = substr(bt.balance_uom,1,1)
                AND     ((bt.balance_uom = 'M'
                          AND et.output_currency_code = bt.currency_code)
                         OR bt.balance_uom <> 'M')
                AND     feed.input_value_id        = iv.input_value_id
                AND     feed.balance_type_id       = bt.balance_type_id
                AND     feed.effective_start_date <= iv.effective_end_date
                AND     feed.effective_end_date   >= iv.effective_start_date;
--
        CURSOR cur_get_per_pay_value_sub IS
                SELECT  /*+ INDEX (BT PAY_BALANCE_TYPES_PK)  */
                        pay_balance_feeds_s.nextval a_balance_feed_id,
                        scr.effective_start_date    a_effective_start_date,
                        scr.effective_end_date      a_effective_end_date,
                        iv.input_value_id           a_input_value_id,
                        bc.balance_type_id          a_balance_type_id,
                        bc.scale                    a_scale,
                        iv.business_group_id        a_business_group_id,
                        iv.legislation_code         a_legislation_code,
                        iv.legislation_subgroup     a_legislation_subgroup,
                        iv.last_updated_by          a_last_updated_by,
                        iv.last_update_login        a_last_update_login,
                        iv.created_by               a_created_by
                FROM    pay_balance_types              bt,
                        pay_balance_classifications    bc,
                        pay_element_types_f            et,
                        pay_sub_classification_rules_f scr,
                        pay_input_values_f             iv
                WHERE   iv.input_value_id        = p_input_value_id
                AND     scr.element_type_id      = iv.element_type_id
                AND     iv.effective_start_date <= scr.effective_end_date
                AND     iv.effective_end_date   >= scr.effective_start_date
                AND     et.element_type_id       = iv.element_type_id
                AND     et.effective_start_date <= p_session_date
                AND     et.effective_end_date   >= p_session_date
                AND     bc.classification_id     = scr.classification_id
                AND     bt.balance_type_id       = bc.balance_type_id
                AND     nvl(bt.business_group_id,nvl(p_business_group,0))
                            = nvl(p_business_group,0)
                AND     nvl(bt.legislation_code,nvl(p_legislation_code,' '))
                            = nvl(p_legislation_code,' ')
                AND     substr(iv.uom,1,1) = substr(bt.balance_uom,1,1)
                AND     ((bt.balance_uom = 'M'
                          AND et.output_currency_code = bt.currency_code)
                         OR bt.balance_uom <> 'M')
		FOR UPDATE;
--
        CURSOR cur_check_per_pay_value_sub IS
                SELECT  feed.balance_feed_id
                FROM    pay_balance_feeds_f            feed,
                        pay_balance_types              bt,
                        pay_balance_classifications    bc,
                        pay_element_types_f            et,
                        pay_sub_classification_rules_f scr,
                        pay_input_values_f             iv
                WHERE   iv.input_value_id        = p_input_value_id
                AND     scr.element_type_id      = iv.element_type_id
                AND     iv.effective_end_date   >= scr.effective_start_date
                AND     iv.effective_start_date <= scr.effective_end_date
                AND     et.element_type_id       = iv.element_type_id
                AND     et.effective_start_date <= p_session_date
                AND     et.effective_end_date   >= p_session_date
                AND     bc.classification_id     = scr.classification_id
                AND     bt.balance_type_id       = bc.balance_type_id
                AND     nvl(bt.business_group_id,nvl(p_business_group,0))
                            = nvl(p_business_group,0)
                AND     nvl(bt.legislation_code,nvl(p_legislation_code,' '))
                            = nvl(p_legislation_code,' ')
                AND     substr(iv.uom,1,1) = substr(bt.balance_uom,1,1)
                AND     ((bt.balance_uom = 'M'
                          AND et.output_currency_code = bt.currency_code)
                         OR bt.balance_uom <> 'M')
                AND     feed.input_value_id        = iv.input_value_id
                AND     feed.balance_type_id       = bt.balance_type_id
                AND     feed.effective_start_date <= scr.effective_end_date
                AND     feed.effective_end_date   >= scr.effective_start_date;
--
        CURSOR cur_lock_manual_feed IS
                SELECT  iv.input_value_id,
                        et.element_type_id,
                        bt.balance_type_id
                FROM    pay_balance_types bt,
                        pay_element_types_f et,
                        pay_input_values_f iv
                WHERE   iv.input_value_id = p_input_value_id
                AND     et.element_type_id = iv.element_type_id
                AND     et.effective_start_date <= p_session_date
                AND     et.effective_end_date   >= p_session_date
                AND     bt.balance_type_id = p_balance_type_id
                AND     substr(iv.uom,1,1) = substr(bt.balance_uom,1,1)
                AND     ((bt.balance_uom = 'M'
                          AND et.output_currency_code = bt.currency_code)
                         OR bt.balance_uom <> 'M');
--
        CURSOR cur_check_manual_feed IS
                SELECT  feed.balance_feed_id
                FROM    pay_balance_feeds_f feed,
                        pay_balance_types bt,
                        pay_element_types_f et,
                        pay_input_values_f iv
                WHERE   iv.input_value_id        = p_input_value_id
                AND     et.element_type_id       = iv.element_type_id
                AND     et.effective_start_date <= p_session_date
                AND     et.effective_end_date   >= p_session_date
                AND     bt.balance_type_id       = p_balance_type_id
                AND     substr(iv.uom,1,1) = substr(bt.balance_uom,1,1)
                AND     ((bt.balance_uom = 'M'
                          AND et.output_currency_code = bt.currency_code)
                         OR bt.balance_uom <> 'M')
                AND     feed.input_value_id        = iv.input_value_id
                AND     feed.balance_type_id       = bt.balance_type_id
                AND     feed.effective_start_date <= iv.effective_end_date
                AND     feed.effective_end_date   >= iv.effective_start_date;
--
	CURSOR cur_lock_sub_class_rule IS
                SELECT  iv.input_value_id,
                        et.element_type_id,
                        scr.sub_classification_rule_id,
			bc.balance_classification_id,
			bt.balance_type_id
                FROM    pay_balance_types              bt,
                        pay_balance_classifications    bc,
                        pay_element_types_f            et,
                        pay_input_values_f_tl          iv_tl,
                        pay_input_values_f             iv,
                        pay_sub_classification_rules_f scr
                WHERE   iv_tl.input_value_id = iv.input_value_id
                and     userenv('LANG')          = iv_tl.language
                AND     scr.sub_classification_rule_id
                        = p_sub_classification_rule_id
                AND     iv.element_type_id       = scr.element_type_id
                AND     iv_tl.name               = v_pay_value
                AND     iv.effective_start_date <= scr.effective_end_date
                AND     iv.effective_end_date   >= scr.effective_start_date
                AND     et.element_type_id       = iv.element_type_id
                AND     et.effective_start_date <= p_session_date
                AND     et.effective_end_date   >= p_session_date
                AND     bc.classification_id     = scr.classification_id
                AND     bt.balance_type_id       = bc.balance_type_id
                AND     nvl(bt.business_group_id,nvl(p_business_group,0))
                            = nvl(p_business_group,0)
                AND     nvl(bt.legislation_code,nvl(p_legislation_code,' '))
                            = nvl(p_legislation_code,' ')
                AND     substr(iv.uom,1,1) = substr(bt.balance_uom,1,1)
                AND     ((bt.balance_uom = 'M'
                          AND bt.currency_code = et.output_currency_code)
                         OR bt.balance_uom <> 'M')
                FOR UPDATE;
--
        CURSOR cur_check_sub_class_rule IS
                SELECT  feed.balance_feed_id
                FROM    pay_balance_feeds              feed,
                        pay_balance_types              bt,
                        pay_balance_classifications    bc,
                        pay_element_types_f            et,
                        pay_input_values_f_tl          iv_tl,
                        pay_input_values_f             iv,
                        pay_sub_classification_rules_f scr
                WHERE   iv_tl.input_value_id = iv.input_value_id
                and     userenv('LANG')          = iv_tl.language
                and     scr.sub_classification_rule_id
                        = p_sub_classification_rule_id
                AND     iv.element_type_id       = scr.element_type_id
                AND     iv_tl.name               = v_pay_value
                AND     iv.effective_start_date <= scr.effective_end_date
                AND     iv.effective_end_date   >= scr.effective_start_date
                AND     et.element_type_id       = iv.element_type_id
                AND     et.effective_start_date <= p_session_date
                AND     et.effective_end_date   >= p_session_date
                AND     bc.classification_id     = scr.classification_id
                AND     bt.balance_type_id       = bc.balance_type_id
                AND     nvl(bt.business_group_id,nvl(p_business_group,0))
                            = nvl(p_business_group,0)
                AND     nvl(bt.legislation_code,nvl(p_legislation_code,' '))
                            = nvl(p_legislation_code,' ')
                AND     substr(iv.uom,1,1) = substr(bt.balance_uom,1,1)
                AND     ((bt.balance_uom = 'M'
                          AND bt.currency_code = et.output_currency_code)
                         OR bt.balance_uom <> 'M')
                AND     feed.input_value_id        = iv.input_value_id
                AND     feed.balance_type_id       = bt.balance_type_id
                AND     feed.effective_start_date <= scr.effective_end_date
                AND     feed.effective_end_date   >= scr.effective_start_date;
--
        CURSOR cur_iv_sub_class_rule IS
                SELECT  iv.input_value_id       a_input_value_id,
                        scr.effective_start_date a_effective_start_date,
                        scr.effective_end_date  a_effective_end_date,
                        iv.uom                  a_uom,
                        et.output_currency_code a_output_currency_code,
                        iv.business_group_id    a_business_group_id,
                        iv.legislation_code     a_legislation_code,
                        iv.legislation_subgroup a_legislation_subgroup
                FROM    pay_element_types_f et,
                        pay_input_values_f_tl iv_tl,
                        pay_input_values_f iv,
                        pay_sub_classification_rules_f scr
                WHERE   iv_tl.input_value_id = iv.input_value_id
                and     userenv('LANG')       = iv_tl.language
                and     scr.sub_classification_rule_id
                        = p_sub_classification_rule_id
                AND     iv.element_type_id = scr.element_type_id
                AND     iv_tl.name            = v_pay_value
                AND     nvl(iv.business_group_id,nvl(p_business_group,0))
                            = nvl(p_business_group,0)
                AND     nvl(iv.legislation_code,nvl(p_legislation_code,' '))
                            = nvl(p_legislation_code,' ')
                AND     iv.effective_end_date   >= scr.effective_start_date
                AND     iv.effective_start_date <= scr.effective_end_date
                AND     et.element_type_id       = iv.element_type_id
                AND     et.effective_start_date <= p_session_date
                AND     et.effective_end_date   >= p_session_date;
--
        CURSOR cur_bt_sub_class_rule (c_uom		     varchar2,
				      c_output_currency_code varchar2) IS
                SELECT  pay_balance_feeds_s.nextval a_balance_feed_id,
                        bc.balance_type_id          a_balance_type_id,
                        bc.scale                    a_scale,
                        bc.last_updated_by          a_last_updated_by,
                        bc.last_update_login        a_last_update_login,
                        bc.created_by               a_created_by
                FROM    pay_balance_types bt,
                        pay_balance_classifications bc,
                        pay_sub_classification_rules_f scr
                WHERE   scr.sub_classification_rule_id
                        = p_sub_classification_rule_id
                AND     bc.classification_id = scr.classification_id
                AND     bt.balance_type_id = bc.balance_type_id
                AND     nvl(bt.business_group_id,nvl(p_business_group,0))
                            = nvl(p_business_group,0)
                AND     nvl(bt.legislation_code,nvl(p_legislation_code,' '))
                            = nvl(p_legislation_code,' ')
                AND     substr(bt.balance_uom,1,1) = substr(c_uom,1,1)
                AND     ((bt.balance_uom = 'M'
                          AND bt.currency_code = c_output_currency_code)
                         OR bt.balance_uom <> 'M');
--
        CURSOR cur_lock_primary_bal_class IS
                SELECT  iv.input_value_id,
                        et.element_type_id,
                        bt.balance_type_id
                FROM    pay_balance_types   bt,
                        pay_input_values_f_tl iv_tl,
                        pay_input_values_f  iv,
                        pay_element_types_f et
                WHERE   iv_tl.input_value_id = iv.input_value_id
                and     userenv('LANG')          = iv_tl.language
                and     et.classification_id     = p_primary_classification_id
                AND     et.effective_start_date <= p_session_date
                AND     et.effective_end_date   >= p_session_date
                AND     nvl(et.business_group_id,nvl(p_business_group,0))
                            = nvl(p_business_group,0)
                AND     nvl(et.legislation_code,nvl(p_legislation_code,' '))
                            = nvl(p_legislation_code,' ')
                AND     iv.element_type_id = et.element_type_id
                AND     iv_tl.name = v_pay_value
                AND     bt.balance_type_id = p_balance_type_id
                AND     substr(iv.uom,1,1) = substr(bt.balance_uom,1,1)
                AND     ((bt.balance_uom = 'M'
                          AND et.output_currency_code = bt.currency_code)
                         OR bt.balance_uom <> 'M')
                FOR UPDATE;
--
        CURSOR cur_check_primary_bal_class IS
                SELECT  feed.balance_feed_id
                FROM    pay_balance_feeds_f feed,
                        pay_balance_types   bt,
                        pay_input_values_f_tl iv_tl,
                        pay_input_values_f  iv,
                        pay_element_types_f et
                WHERE   iv_tl.input_value_id = iv.input_value_id
                and     userenv('LANG') = iv_tl.language
                and     et.classification_id     = p_primary_classification_id
                AND     et.effective_start_date <= p_session_date
                AND     et.effective_end_date   >= p_session_date
                AND     nvl(et.business_group_id,nvl(p_business_group,0))
                            = nvl(p_business_group,0)
                AND     nvl(et.legislation_code,nvl(p_legislation_code,' '))
                            = nvl(p_legislation_code,' ')
                AND     iv.element_type_id       = et.element_type_id
                AND     iv_tl.name               = v_pay_value
                AND     iv.effective_start_date <= p_session_date
                AND     iv.effective_end_date   >= p_session_date
                AND     bt.balance_type_id = p_balance_type_id
                AND     substr(iv.uom,1,1) = substr(bt.balance_uom,1,1)
                AND     ((bt.balance_uom = 'M'
                          AND et.output_currency_code = bt.currency_code)
                         OR bt.balance_uom <> 'M')
                AND     feed.input_value_id  = iv.input_value_id
                AND     feed.balance_type_id = bt.balance_type_id
                AND     feed.effective_start_date <=
                        (SELECT max(iv.effective_end_date)
                         FROM   pay_input_values_f iv1
                         WHERE  iv1.input_value_id = iv.input_value_id
                         GROUP BY iv1.input_value_id)
                AND     feed.effective_end_date >=
                        (SELECT min(iv2.effective_start_date)
                         FROM   pay_input_values_f iv2
                         WHERE  iv2.input_value_id = iv.input_value_id
                         GROUP BY iv2.input_value_id);
--
        CURSOR cur_iv_primary_bal_class IS
                SELECT  iv.input_value_id       a_input_value_id,
                        min(iv.effective_start_date) a_effective_start_date,
                        max(iv.effective_end_date)   a_effective_end_date,
                        iv.uom                  a_uom,
                        et.output_currency_code a_output_currency_code,
                        iv.business_group_id    a_business_group_id,
                        iv.legislation_code     a_legislation_code,
                        iv.legislation_subgroup a_legislation_subgroup
                FROM    pay_balance_types bt,
                        pay_input_values_f_tl iv_tl,
                        pay_input_values_f iv,
                        pay_element_types_f et
                WHERE   iv_tl.input_value_id = iv.input_value_id
                and     userenv('LANG') = iv_tl.language
                and     et.classification_id     = p_primary_classification_id
                AND     et.effective_start_date <= p_session_date
                AND     et.effective_end_date   >= p_session_date
                AND     nvl(et.business_group_id,nvl(p_business_group,0))
                            = nvl(p_business_group,0)
                AND     nvl(et.legislation_code,nvl(p_legislation_code,' '))
                            = nvl(p_legislation_code,' ')
                AND     iv.element_type_id = et.element_type_id
                AND     iv_tl.name         = v_pay_value
                AND     bt.balance_type_id = p_balance_type_id
                AND     substr(iv.uom,1,1) = substr(bt.balance_uom,1,1)
                AND     ((bt.balance_uom = 'M'
                          AND et.output_currency_code = bt.currency_code)
                         OR bt.balance_uom <> 'M')
GROUP BY iv.input_value_id, iv.uom, et.output_currency_code,
         iv.business_group_id, iv.legislation_code, iv.legislation_subgroup;
--
        CURSOR cur_lock_sub_bal_class IS
                SELECT  iv.input_value_id,
                        et.element_type_id,
                        scr.sub_classification_rule_id,
                        bt.balance_type_id
                FROM    pay_balance_types   bt,
                        pay_element_types_f et,
                        pay_input_values_f_tl iv_tl,
                        pay_input_values_f  iv,
                        pay_sub_classification_rules_f scr
                WHERE   iv_tl.input_value_id = iv.input_value_id
                and     userenv('LANG') = iv_tl.language
                and     scr.classification_id = p_sub_classification_id
                AND     iv.element_type_id = scr.element_type_id
                AND     iv_tl.name = v_pay_value
                AND     nvl(iv.business_group_id,nvl(p_business_group,0))
                            = nvl(p_business_group,0)
                AND     nvl(iv.legislation_code,nvl(p_legislation_code,' '))
                            = nvl(p_legislation_code,' ')
                AND     iv.effective_end_date   >= scr.effective_start_date
                AND     iv.effective_start_date <= scr.effective_end_date
                AND     et.element_type_id = iv.element_type_id
                AND     bt.balance_type_id = p_balance_type_id
                AND     substr(iv.uom,1,1) = substr(bt.balance_uom,1,1)
                AND     ((bt.balance_uom = 'M'
                          AND et.output_currency_code = bt.currency_code)
                         OR bt.balance_uom <> 'M')
                FOR UPDATE;
--
        CURSOR cur_check_sub_bal_class IS
                SELECT  feed.balance_feed_id
                FROM    pay_balance_feeds_f feed,
                        pay_balance_types   bt,
                        pay_element_types_f et,
                        pay_input_values_f_tl iv_tl,
                        pay_input_values_f  iv,
                        pay_sub_classification_rules_f scr
                WHERE   iv_tl.input_value_id = iv.input_value_id
                and     userenv('LANG') = iv_tl.language
                and     scr.classification_id = p_sub_classification_id
                AND     iv.element_type_id = scr.element_type_id
                AND     iv_tl.name = v_pay_value
                AND     nvl(iv.business_group_id,nvl(p_business_group,0))
                            = nvl(p_business_group,0)
                AND     nvl(iv.legislation_code,nvl(p_legislation_code,' '))
                            = nvl(p_legislation_code,' ')
                AND     iv.effective_end_date   >= scr.effective_start_date
                AND     iv.effective_start_date <= scr.effective_end_date
                AND     et.element_type_id       = iv.element_type_id
                AND     et.effective_end_date   >= p_session_date
                AND     et.effective_start_date <= p_session_date
                AND     bt.balance_type_id       = p_balance_type_id
                AND     substr(iv.uom,1,1)       = substr(bt.balance_uom,1,1)
                AND     ((bt.balance_uom = 'M'
                          AND et.output_currency_code = bt.currency_code)
                         OR bt.balance_uom <> 'M')
		AND     feed.input_value_id        = iv.input_value_id
                AND     feed.balance_type_id       = bt.balance_type_id
                AND     feed.effective_start_date <= scr.effective_end_date
                AND     feed.effective_end_date   >= scr.effective_start_date;
--
        CURSOR cur_iv_sub_bal_class IS
                SELECT  iv.input_value_id       a_input_value_id,
                        scr.effective_start_date a_effective_start_date,
                        scr.effective_end_date   a_effective_end_date,
                        iv.uom                  a_uom,
                        et.output_currency_code a_output_currency_code,
                        iv.business_group_id    a_business_group_id,
                        iv.legislation_code     a_legislation_code,
                        iv.legislation_subgroup a_legislation_subgroup
                FROM    pay_balance_types   bt,
                        pay_element_types_f et,
                        pay_input_values_f_tl iv_tl,
                        pay_input_values_f  iv,
                        pay_sub_classification_rules_f scr
                WHERE   iv_tl.input_value_id = iv.input_value_id
                and     userenv('LANG') = iv_tl.language
                and     scr.classification_id = p_sub_classification_id
                AND     iv.element_type_id = scr.element_type_id
                AND     iv_tl.name = v_pay_value
                AND     nvl(iv.business_group_id,nvl(p_business_group,0))
                            = nvl(p_business_group,0)
                AND     nvl(iv.legislation_code,nvl(p_legislation_code,' '))
                            = nvl(p_legislation_code,' ')
                AND     iv.effective_end_date   >= scr.effective_start_date
                AND     iv.effective_start_date <= scr.effective_end_date
                AND     et.element_type_id       = iv.element_type_id
                AND     et.effective_end_date   >= p_session_date
                AND     et.effective_start_date <= p_session_date
                AND     bt.balance_type_id = p_balance_type_id
                AND     substr(iv.uom,1,1) = substr(bt.balance_uom,1,1)
                AND     ((bt.balance_uom = 'M'
                          AND et.output_currency_code = bt.currency_code)
                         OR bt.balance_uom <> 'M');
--
BEGIN
--
v_feed         := -1;
--
-- When payroll element created, pay value input value created, create feeds
-- for all balances associated with primary classification.
--
        hr_utility.set_location('ins_balance_feed', 1);
--
IF p_option = 'INS_PAY_PAY_VALUE' THEN
--
        hr_utility.set_location('INS_PAY_PAY_VALUE', 1);
--
        IF (p_input_value_id is not NULL AND
            p_primary_classification_id is not NULL AND
            p_session_date is not NULL AND
            p_legislation_code is not NULL AND
            p_mode is not NULL) THEN
--
--		Lock all relevant records.
--
	        hr_utility.set_location('INS_PAY_PAY_VALUE', 2);
--
		FOR lock_rec IN cur_get_pay_pay_value LOOP
                	NULL;
        	END LOOP;
--
--		Check for overlap.
--
	        hr_utility.set_location('INS_PAY_PAY_VALUE', 3);
--
		OPEN cur_check_pay_pay_value;
		FETCH cur_check_pay_pay_value INTO v_feed;
--
		IF cur_check_pay_pay_value%FOUND THEN
			hr_utility.set_message (801,'HR_6185_BAL_FEED_EXISTS');
			hr_utility.raise_error;
--
		END IF;
		CLOSE cur_check_pay_pay_value;
--
	        hr_utility.set_location('INS_PAY_PAY_VALUE', 4);
--
                FOR get_rec IN cur_get_pay_pay_value LOOP
--
                INSERT INTO pay_balance_feeds_f
                       (balance_feed_id,
                        effective_start_date,
                        effective_end_date,
                        input_value_id,
                        balance_type_id,
                        scale,
                        business_group_id,
                        legislation_code,
                        legislation_subgroup,
                        last_update_date,
                        last_updated_by,
                        last_update_login,
                        created_by,
                        creation_date)
                VALUES (get_rec.a_balance_feed_id,
                        get_rec.a_effective_start_date,
                        get_rec.a_effective_end_date,
                        get_rec.a_input_value_id,
                        get_rec.a_balance_type_id,
                        get_rec.a_scale,
                        get_rec.a_business_group_id,
                        get_rec.a_legislation_code,
                        get_rec.a_legislation_subgroup,
                        trunc(sysdate),
                        get_rec.a_last_updated_by,
                        get_rec.a_last_update_login,
                        get_rec.a_created_by,
                        trunc(sysdate));
--
                IF p_mode <> 'USER' THEN
                        ins_application_ownership(get_rec.a_balance_feed_id,
						  get_rec.a_input_value_id,
						  NULL);
                END IF;
--
                END LOOP;
--
	ELSE
--
	hr_utility.set_message (801,'PAY_6541_PRO_INVALID_ARGS');
	hr_utility.raise_error;
--
	END IF;
--
-- When pay value input value created for personnel element, create feeds
-- for primary and sub classifications for associated balances.
--
ELSIF p_option = 'INS_PER_PAY_VALUE' THEN
--
        hr_utility.set_location('INS_PER_PAY_VALUE', 1);
--
        IF     (p_input_value_id is not NULL AND
                p_primary_classification_id is not NULL AND
                p_session_date is not NULL AND
                p_legislation_code is not NULL AND
                p_mode is not NULL) THEN
--
-- Insert against primary classifications
--
--              Lock all relevant records.
--
                hr_utility.set_location('INS_PER_PAY_VALUE', 2);
--
                FOR lock_rec IN cur_get_per_pay_value_prim LOOP
                        NULL;
                END LOOP;
--
--              Check for overlap.
--
                hr_utility.set_location('INS_PER_PAY_VALUE', 3);
--
                OPEN cur_check_per_pay_value_prim;
                FETCH cur_check_per_pay_value_prim INTO v_feed;
--
                IF cur_check_per_pay_value_prim%FOUND THEN
                        hr_utility.set_message (801,'HR_6185_BAL_FEED_EXISTS');
                        hr_utility.raise_error;
--
                END IF;
                CLOSE cur_check_per_pay_value_prim;
--
                hr_utility.set_location('INS_PER_PAY_VALUE', 4);
--
                FOR get_rec IN cur_get_per_pay_value_prim LOOP
--
                INSERT INTO pay_balance_feeds_f
                       (balance_feed_id,
                        effective_start_date,
                        effective_end_date,
                        input_value_id,
                        balance_type_id,
                        scale,
                        business_group_id,
                        legislation_code,
                        legislation_subgroup,
                        last_update_date,
                        last_updated_by,
                        last_update_login,
                        created_by,
                        creation_date)
                VALUES (get_rec.a_balance_feed_id,
                        get_rec.a_effective_start_date,
                        get_rec.a_effective_end_date,
                        get_rec.a_input_value_id,
                        get_rec.a_balance_type_id,
                        get_rec.a_scale,
                        get_rec.a_business_group_id,
                        get_rec.a_legislation_code,
                        get_rec.a_legislation_subgroup,
                        trunc(sysdate),
                        get_rec.a_last_updated_by,
                        get_rec.a_last_update_login,
                        get_rec.a_created_by,
                        trunc(sysdate));
--
                IF p_mode <> 'USER' THEN
                        ins_application_ownership(get_rec.a_balance_feed_id,
						  get_rec.a_input_value_id,
						  NULL);
                END IF;
--
                END LOOP;
--
-- AND
--
-- Insert against sub classifications
--
--              Lock all relevant records.
--
                hr_utility.set_location('INS_PER_PAY_VALUE', 5);
--
                FOR lock_rec IN cur_get_per_pay_value_sub LOOP
                        NULL;
                END LOOP;
--
--              Check for overlap.
--
                hr_utility.set_location('INS_PER_PAY_VALUE', 6);
--
                OPEN cur_check_per_pay_value_sub;
                FETCH cur_check_per_pay_value_sub INTO v_feed;
--
                IF cur_check_per_pay_value_sub%FOUND THEN
                        hr_utility.set_message (801,'HR_6185_BAL_FEED_EXISTS');
                        hr_utility.raise_error;
--
                END IF;
                CLOSE cur_check_per_pay_value_sub;
--
                hr_utility.set_location('INS_PER_PAY_VALUE', 7);
--
                FOR get_rec IN cur_get_per_pay_value_sub LOOP
--
                INSERT INTO pay_balance_feeds_f
                       (balance_feed_id,
                        effective_start_date,
                        effective_end_date,
                        input_value_id,
                        balance_type_id,
                        scale,
                        business_group_id,
                        legislation_code,
                        legislation_subgroup,
                        last_update_date,
                        last_updated_by,
                        last_update_login,
                        created_by,
                        creation_date)
                VALUES (get_rec.a_balance_feed_id,
                        get_rec.a_effective_start_date,
                        get_rec.a_effective_end_date,
                        get_rec.a_input_value_id,
                        get_rec.a_balance_type_id,
                        get_rec.a_scale,
                        get_rec.a_business_group_id,
                        get_rec.a_legislation_code,
                        get_rec.a_legislation_subgroup,
                        trunc(sysdate),
                        get_rec.a_last_updated_by,
                        get_rec.a_last_update_login,
                        get_rec.a_created_by,
                        trunc(sysdate));
--
                IF p_mode <> 'USER' THEN
                        ins_application_ownership(get_rec.a_balance_feed_id,
						  get_rec.a_input_value_id,
						  NULL);
                END IF;
--
                END LOOP;
--
        ELSE
--
        hr_utility.set_message (801,'PAY_6541_PRO_INVALID_ARGS');
        hr_utility.raise_error;
--
	END IF;
--
-- Manually create a balance feed against primary clasification and selected
-- balance.
--
ELSIF p_option = 'INS_MANUAL_FEED' THEN
--
        hr_utility.set_location('INS_MANUAL_FEED', 1);
--
	IF (p_input_value_id is not NULL AND
	    p_balance_type_id is not NULL AND
            p_scale is not NULL AND
            p_mode is not NULL) THEN
--
--              Lock all relevant records.
--
                hr_utility.set_location('INS_MANUAL_FEED', 2);
--
                FOR lock_rec IN cur_lock_manual_feed LOOP
                        NULL;
                END LOOP;
--
--              Check for overlap.
--
                hr_utility.set_location('INS_MANUAL_FEED', 3);
--
                OPEN cur_check_manual_feed;
                FETCH cur_check_manual_feed INTO v_feed;
--
                IF cur_check_manual_feed%FOUND THEN
                        hr_utility.set_message (801,'HR_6185_BAL_FEED_EXISTS');
                        hr_utility.raise_error;
--
                END IF;
                CLOSE cur_check_manual_feed;
--
	    IF p_session_date is not NULL THEN
--
                hr_utility.set_location('INS_MANUAL_FEED', 4);
--
		SELECT	pay_balance_feeds_s.nextval
		INTO	v_sequence
		FROM 	sys.dual;
--
                INSERT INTO pay_balance_feeds_f
		       (balance_feed_id,
			effective_start_date,
			effective_end_date,
			input_value_id,
			balance_type_id,
			scale,
			business_group_id,
			legislation_code,
			legislation_subgroup,
			last_update_date,
			last_updated_by,
			last_update_login,
			created_by,
			creation_date)
                SELECT  v_sequence,
                        p_session_date,
                        max(iv.effective_end_date),
                        iv.input_value_id,
                        bt.balance_type_id,
                        p_scale,
                        nvl(p_business_group,iv.business_group_id),
                        decode(p_business_group,NULL,nvl(p_legislation_code,iv.legislation_code),NULL),
                        iv.legislation_subgroup,
                        trunc(sysdate),
                        iv.last_updated_by,
                        iv.last_update_login,
                        iv.created_by,
                        trunc(sysdate)
                FROM    pay_input_values_f iv,
                        pay_element_types_f et,
                        pay_balance_types bt
                WHERE   iv.input_value_id = p_input_value_id
                AND     et.element_type_id = iv.element_type_id
                AND     p_session_date between et.effective_start_date
                                           and et.effective_end_date
                AND     bt.balance_type_id = p_balance_type_id
                AND     substr(iv.uom,1,1) = substr(bt.balance_uom,1,1)
                AND     ((bt.balance_uom = 'M'
                          AND et.output_currency_code = bt.currency_code)
                         OR bt.balance_uom <> 'M')
GROUP BY iv.input_value_id, bt.balance_type_id,
	 iv.business_group_id, iv.legislation_code, iv.legislation_subgroup,
	 iv.last_updated_by, iv.last_update_login, iv.created_by;
--
                IF p_mode <> 'USER' THEN
                        ins_application_ownership(v_sequence,
						  NULL,
						  p_balance_type_id);
                END IF;
--
	    END IF;
--
        ELSE
--
        hr_utility.set_message (801,'PAY_6541_PRO_INVALID_ARGS');
        hr_utility.raise_error;
--
        END IF;
--
-- On adding sub classication rule to an element, create balance feeds for
-- the pay value against all balances feed by classification.
--
ELSIF p_option = 'INS_SUB_CLASS_RULE' THEN
--
        hr_utility.set_location('INS_SUB_CLASS_RULE', 1);
--
        IF (p_sub_classification_rule_id is not NULL AND
            p_session_date is not NULL AND
            p_legislation_code is not NULL AND
            p_mode is not NULL) THEN
--
         v_pay_value := hr_input_values.get_pay_value_name(p_legislation_code);
--
--              Lock all relevant records.
--
                hr_utility.set_location('INS_SUB_CLASS_RULE', 2);
--
		FOR lock_rec IN cur_lock_sub_class_rule LOOP
	        	NULL;
		END LOOP;
--
	hr_utility.set_location('INS_SUB_CLASS_RULE', 3);
--
                OPEN cur_check_sub_class_rule;
                FETCH cur_check_sub_class_rule INTO v_feed;
--
                IF cur_check_sub_class_rule%FOUND THEN
                        hr_utility.set_message (801,'HR_6185_BAL_FEED_EXISTS');
                        hr_utility.raise_error;
--
                END IF;
                CLOSE cur_check_sub_class_rule;
--
        hr_utility.set_location('INS_SUB_CLASS_RULE', 4);
--
	FOR iv_rec IN cur_iv_sub_class_rule LOOP
--
                hr_utility.set_location('INS_SUB_CLASS_RULE', 5);
--
       		FOR bt_rec IN cur_bt_sub_class_rule
                   (iv_rec.a_uom, iv_rec.a_output_currency_code) LOOP
--
                hr_utility.set_location('INS_SUB_CLASS_RULE', 6);
--
                INSERT INTO pay_balance_feeds_f
                       (balance_feed_id,
                        effective_start_date,
                        effective_end_date,
                        input_value_id,
                        balance_type_id,
                        scale,
                        business_group_id,
                        legislation_code,
                        legislation_subgroup,
                        last_update_date,
                        last_updated_by,
                        last_update_login,
                        created_by,
                        creation_date)
                SELECT  bt_rec.a_balance_feed_id,
                        iv_rec.a_effective_start_date,
                        iv_rec.a_effective_end_date,
                        iv_rec.a_input_value_id,
                        bt_rec.a_balance_type_id,
                        bt_rec.a_scale,
                        iv_rec.a_business_group_id,
                        iv_rec.a_legislation_code,
                        iv_rec.a_legislation_subgroup,
                        trunc(sysdate),
                        bt_rec.a_last_updated_by,
                        bt_rec.a_last_update_login,
                        bt_rec.a_created_by,
                        trunc(sysdate)
                FROM    sys.dual;
--
                IF p_mode <> 'USER' THEN
                        ins_application_ownership(bt_rec.a_balance_feed_id,
						  iv_rec.a_input_value_id,
						  NULL);
                END IF;
--
        	END LOOP;
--
	END LOOP;
--
        ELSE
--
        hr_utility.set_message (801,'PAY_6541_PRO_INVALID_ARGS');
        hr_utility.raise_error;
--
	END IF;
--
-- When balance classification created feeds for all elements with pay value
-- input values associated with classification (primary or sub).
--
ELSIF p_option = 'INS_PRIMARY_BAL_CLASS' THEN
--
        hr_utility.set_location('INS_PRIMARY_BAL_CLASS', 1);
--
        IF (p_primary_classification_id is not NULL AND
            p_balance_type_id is not NULL AND
            p_scale is not NULL AND
            p_session_date is not NULL AND
            p_legislation_code is not NULL AND
            p_mode is not NULL) THEN
--
         v_pay_value := hr_input_values.get_pay_value_name(p_legislation_code);
--
--              Lock all relevant records.
--
                hr_utility.set_location('INS_PRIMARY_BAL_CLASS', 2);
--
        	FOR lock_rec IN cur_lock_primary_bal_class LOOP
                	NULL;
        	END LOOP;
--
                hr_utility.set_location('INS_PRIMARY_BAL_CLASS', 3);
--
                OPEN cur_check_primary_bal_class;
                FETCH cur_check_primary_bal_class INTO v_feed;
--
                IF cur_check_primary_bal_class%FOUND THEN
                        hr_utility.set_message (801,'HR_6185_BAL_FEED_EXISTS');
                        hr_utility.raise_error;
--
                END IF;
                CLOSE cur_check_primary_bal_class;
--
                hr_utility.set_location('INS_PRIMARY_BAL_CLASS', 4);
--
        <<bal_loop>>
        FOR iv_rec IN cur_iv_primary_bal_class LOOP
--
                EXIT bal_loop WHEN iv_rec.a_effective_start_date IS NULL
                                OR iv_rec.a_effective_end_date IS NULL;
--
                SELECT  pay_balance_feeds_s.nextval
                INTO    v_sequence
                FROM    sys.dual;
--
                INSERT INTO pay_balance_feeds_f
                       (balance_feed_id,
                        effective_start_date,
                        effective_end_date,
                        input_value_id,
                        balance_type_id,
                        scale,
                        business_group_id,
                        legislation_code,
                        legislation_subgroup,
                        last_update_date,
                        last_updated_by,
                        last_update_login,
                        created_by,
                        creation_date)
                SELECT  v_sequence,
                        iv_rec.a_effective_start_date,
                        iv_rec.a_effective_end_date,
                        iv_rec.a_input_value_id,
                        p_balance_type_id,
                        p_scale,
                        iv_rec.a_business_group_id,
                        iv_rec.a_legislation_code,
                        iv_rec.a_legislation_subgroup,
                        trunc(sysdate),
                        -1,
                        -1,
                        -1,
                        trunc(sysdate)
                FROM    sys.dual;
--
                IF p_mode <> 'USER' THEN
                        ins_application_ownership(v_sequence,
						  NULL,
						  p_balance_type_id);
                END IF;
--
        END LOOP bal_loop;
--
        ELSE
--
        hr_utility.set_message (801,'PAY_6541_PRO_INVALID_ARGS');
        hr_utility.raise_error;
--
	END IF;
--
ELSIF p_option = 'INS_SUB_BAL_CLASS' THEN
--
        hr_utility.set_location('INS_SUB_BAL_CLASS', 1);
--
        IF (p_sub_classification_id is not NULL AND
            p_balance_type_id is not NULL AND
            p_scale is not NULL AND
            p_session_date is not NULL AND
            p_legislation_code is not NULL AND
            p_mode is not NULL) THEN
--
         v_pay_value := hr_input_values.get_pay_value_name(p_legislation_code);
		l_new_end_date := NULL;
--
--              Lock all relevant records.
--
                hr_utility.set_location('INS_SUB_BAL_CLASS', 2);
--
        	FOR lock_rec IN cur_lock_sub_bal_class LOOP
                	NULL;
        	END LOOP;
--
	        hr_utility.set_location('INS_SUB_BAL_CLASS', 3);
--
		for feed_rec in cur_check_sub_bal_class loop
--
                        hr_utility.set_message (801,'HR_6185_BAL_FEED_EXISTS');
                        hr_utility.raise_error;
--
		end loop;
--
                hr_utility.set_location('INS_SUB_BAL_CLASS', 4);
--
        FOR iv_rec IN cur_iv_sub_bal_class LOOP
--
                SELECT  pay_balance_feeds_s.nextval
                INTO    v_sequence
                FROM    sys.dual;
--
                INSERT INTO pay_balance_feeds_f
                       (balance_feed_id,
                        effective_start_date,
                        effective_end_date,
                        input_value_id,
                        balance_type_id,
                        scale,
                        business_group_id,
                        legislation_code,
                        legislation_subgroup,
                        last_update_date,
                        last_updated_by,
                        last_update_login,
                        created_by,
                        creation_date)
                SELECT  v_sequence,
                        iv_rec.a_effective_start_date,
                        least(nvl(l_new_end_date,iv_rec.a_effective_end_date),
				iv_rec.a_effective_end_date),
                        iv_rec.a_input_value_id,
                        p_balance_type_id,
                        p_scale,
                        iv_rec.a_business_group_id,
                        iv_rec.a_legislation_code,
                        iv_rec.a_legislation_subgroup,
                        trunc(sysdate),
                        -1,
                        -1,
                        -1,
                        trunc(sysdate)
                FROM    sys.dual;
--
                IF p_mode <> 'USER' THEN
                        ins_application_ownership(v_sequence,
						  NULL,
						  p_balance_type_id);
                END IF;
--
        END LOOP;
--
        ELSE
--
        hr_utility.set_message (801,'PAY_6541_PRO_INVALID_ARGS');
        hr_utility.raise_error;
--
	END IF;
--
-- This is very similar to INS_MANUAL_FEED, except the data mode (i.e. generic
-- data has null BG and null LEG_code, startup data has not null LEG_CODE and
-- null BG and user data has null LEG_CODE and not null BG), is determined
-- by the data mode of the balance_type_id rather than the input_valud_id.
--
ELSIF p_option = 'INS_PRIMARY_BALANCE_FEED' THEN
        hr_utility.set_location('INS_PRIMARY_BALANCE_FEED', 1);
--
        IF (p_input_value_id is not NULL AND
            p_balance_type_id is not NULL AND
            p_scale is not NULL AND
            p_mode is not NULL) THEN
--
--              Lock all relevant records.
--
                hr_utility.set_location('INS_PRIMARY_BALANCE_FEED', 2);
--
                FOR lock_rec IN cur_lock_manual_feed LOOP
                        NULL;
                END LOOP;
--
--              Check for overlap.
--
                hr_utility.set_location('INS_PRIMARY_BALANCE_FEED', 3);
--
                OPEN cur_check_manual_feed;
                FETCH cur_check_manual_feed INTO v_feed;
--
                IF cur_check_manual_feed%FOUND THEN
                        hr_utility.set_message (801,'HR_6185_BAL_FEED_EXISTS');
                        hr_utility.raise_error;
--
                END IF;
                CLOSE cur_check_manual_feed;
--
            IF p_session_date is not NULL THEN
--
                hr_utility.set_location('INS_PRIMARY_BALANCE_FEED', 4);
--
                SELECT  pay_balance_feeds_s.nextval
                INTO    v_sequence
                FROM    sys.dual;
--
                hr_utility.set_location('INS_PRIMARY_BALANCE_FEED', 5);
--
                INSERT INTO pay_balance_feeds_f
                       (balance_feed_id,
                        effective_start_date,
                        effective_end_date,
                        input_value_id,
                        balance_type_id,
                        scale,
                       business_group_id,
                        legislation_code,
                        legislation_subgroup,
                        last_update_date,
                        last_updated_by,
                        last_update_login,
                        created_by,
                        creation_date)
                SELECT  v_sequence,
                        p_session_date,
                        max(iv.effective_end_date),
                        iv.input_value_id,
                        bt.balance_type_id,
                        p_scale,
                        bt.business_group_id,
                        bt.legislation_code,
                        bt.legislation_subgroup,
                        trunc(sysdate),
                        bt.last_updated_by,
                        bt.last_update_login,
                        bt.created_by,
                        trunc(sysdate)
                FROM    pay_input_values_f iv,
                        pay_element_types_f et,
                        pay_balance_types bt
                WHERE   iv.input_value_id = p_input_value_id
                AND     et.element_type_id = iv.element_type_id
                AND     p_session_date between et.effective_start_date
                                           and et.effective_end_date
                AND     bt.balance_type_id = p_balance_type_id
                AND     substr(iv.uom,1,1) = substr(bt.balance_uom,1,1)
                AND     ((bt.balance_uom = 'M'
                          AND et.output_currency_code = bt.currency_code)
                         OR bt.balance_uom <> 'M')
                GROUP BY iv.input_value_id,       bt.balance_type_id
                ,        bt.business_group_id,    bt.legislation_code
                ,        bt.legislation_subgroup, bt.last_updated_by
                ,        bt.last_update_login,    bt.created_by;
--
                hr_utility.set_location('INS_PRIMARY_BALANCE_FEED', 6);
--
                IF p_mode <> 'USER' THEN
                        ins_application_ownership(v_sequence,
                                                  NULL,
                                                  p_balance_type_id);
                END IF;
                hr_utility.set_location('INS_PRIMARY_BALANCE_FEED', 7);
--
            END IF;
            hr_utility.set_location('INS_PRIMARY_BALANCE_FEED', 8);
--
        ELSE
--
        hr_utility.set_location('INS_PRIMARY_BALANCE_FEED', 9);
        hr_utility.set_message (801,'PAY_6541_PRO_INVALID_ARGS');
        hr_utility.raise_error;
--
        END IF;
--
END IF;
--
--
    END ins_balance_feed;
--
    PROCEDURE upd_balance_feed
              (p_option                        in varchar2,
               p_balance_feed_id               in number,
               p_primary_classification_id     in number,
               p_sub_classification_id         in number,
               p_balance_type_id               in number,
               p_scale                         in varchar2,
	       p_legislation_code              in varchar2) IS
/*
    NAME
        upd_balance_feed
    DESCRIPTION
        Updated balance feeds.
*/
--
-- Declare local variables
--
v_pay_value     varchar2(80);
--
BEGIN
--
	hr_utility.set_location('upd_balance_feed', 1);
--
IF p_option = 'UPD_MANUAL_FEED' THEN
--
        hr_utility.set_location('UPD_MANUAL_FEED', 1);
--
	IF     (p_balance_feed_id is not NULL AND
                p_scale is not NULL) THEN
--
                UPDATE pay_balance_feeds_f
                SET scale = p_scale
                WHERE balance_feed_id = p_balance_feed_id;
--
        ELSE
--
        hr_utility.set_message (801,'PAY_6541_PRO_INVALID_ARGS');
        hr_utility.raise_error;
--
	END IF;
--
ELSIF p_option = 'UPD_PRIMARY_BAL_CLASS' THEN
--
        hr_utility.set_location('UPD_PRIMARY_BAL_CLASS', 1);
--
	IF     (p_primary_classification_id is not NULL AND
                p_balance_type_id is not NULL AND
                p_scale is not NULL AND
	        p_legislation_code is not NULL) THEN
--
         v_pay_value := hr_input_values.get_pay_value_name(p_legislation_code);
--
                UPDATE pay_balance_feeds_f
                SET scale = p_scale
                WHERE balance_type_id = p_balance_type_id
                AND   input_value_id in
                       (SELECT  iv.input_value_id
                        FROM    pay_input_values_f iv,
                                pay_element_types_f et
                        WHERE   iv.element_type_id = et.element_type_id
                        and     et.classification_id
                                = p_primary_classification_id
                	AND     iv.name = 'Pay Value');
--
        ELSE
--
        hr_utility.set_message (801,'PAY_6541_PRO_INVALID_ARGS');
        hr_utility.raise_error;
--
	END IF;
--
ELSIF p_option = 'UPD_SUB_BAL_CLASS' THEN
--
        hr_utility.set_location('UPD_SUB_BAL_CLASS', 1);
--
	IF  (p_sub_classification_id is not NULL AND
             p_balance_type_id is not NULL AND
             p_scale is not NULL AND
	     p_legislation_code is not NULL) THEN
--
         v_pay_value := hr_input_values.get_pay_value_name(p_legislation_code);
--
                UPDATE pay_balance_feeds_f
                SET scale = p_scale
                WHERE balance_type_id = p_balance_type_id
                AND   input_value_id in
                       (SELECT  iv.input_value_id
                        FROM    pay_input_values_f iv,
                                pay_sub_classification_rules_f scr
                        WHERE   iv.element_type_id = scr.element_type_id
                        and     scr.classification_id
                                = p_sub_classification_id
                	AND     iv.name = 'Pay Value'
                        AND     iv.effective_end_date
                                >= scr.effective_start_date
                        AND     iv.effective_start_date
                                <= scr.effective_end_date);
--
        ELSE
--
        hr_utility.set_message (801,'PAY_6541_PRO_INVALID_ARGS');
        hr_utility.raise_error;
--
	END IF;
--
END IF;
--
    END upd_balance_feed;
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
	      (p_balance_feed_id	in number,
	       p_balance_type_id	in number) is
--
    l_balance_name	varchar2(80) := NULL;
--
    begin
--
	begin
--
	select b_tl.balance_name
	into l_balance_name
	from pay_balance_types_tl b_tl,
             pay_balance_types b
	where b_tl.balance_type_id = b.balance_type_id
        and userenv('LANG') = b_tl.language
        and b.balance_type_id = p_balance_type_id
	and exists
		(select 1
		from pay_balance_classifications bc
		where b.balance_type_id = bc.balance_type_id);
--
	exception
		when NO_DATA_FOUND then NULL;
	end;
--
    if l_balance_name is not NULL then
	hr_utility.set_message(801, 'PAY_6608_BAL_NO_BF_DEL');
	hr_utility.set_message_token('BALANCE', l_balance_name);
	hr_utility.raise_error;
    end if;
--
    end chk_del_balance_feed;
--
    PROCEDURE del_balance_feed
              (p_option                        in varchar2,
	       p_delete_mode                   in varchar2,
               p_balance_feed_id               in number,
	       p_input_value_id                in number,
	       p_element_type_id               in number,
               p_primary_classification_id     in number,
               p_sub_classification_id         in number,
	       p_sub_classification_rule_id    in number,
               p_balance_type_id               in number,
               p_session_date     	       in date,
               p_effective_end_date            in date,
	       p_legislation_code              in varchar2,
               p_mode                          in varchar2) IS
/*
    NAME
        del_balance_feed
    DESCRIPTION
        Delete  balance feeds.
*/
-- declare local variables
--
v_pay_value	varchar(80);
--
BEGIN
--
        hr_utility.set_location('del_balance_feed', 1);
--
IF p_option = 'DEL_MANUAL_FEED' THEN
--
        hr_utility.set_location('DEL_MANUAL_FEED', 1);
--
	IF p_balance_feed_id is not NULL THEN
		IF p_delete_mode = 'ZAP' THEN
--
                        IF p_mode <> 'USER' THEN
                            DELETE FROM hr_application_ownerships
                            WHERE  KEY_NAME  = 'BALANCE_FEED_ID'
                            AND    KEY_VALUE = p_balance_feed_id;
                        END IF;
--
                        DELETE FROM pay_balance_feeds_f
                        WHERE balance_feed_id = p_balance_feed_id;
--
		ELSIF (p_delete_mode = 'DELETE' AND
                        p_session_date is not NULL) THEN
--
		        UPDATE pay_balance_feeds_f
                        SET   effective_end_date = p_session_date
                        WHERE balance_feed_id = p_balance_feed_id
                        AND   effective_start_date <= p_session_date
                        AND   effective_end_date >= p_session_date;
--
                        DELETE FROM pay_balance_feeds_f
                        WHERE  balance_feed_id = p_balance_feed_id
                        AND    effective_start_date > p_session_date;
--
		ELSIF (p_delete_mode = 'DELETE_NEXT_CHANGE' AND
                        p_effective_end_date is not NULL AND
                        p_session_date is not NULL) THEN
--
                        UPDATE pay_balance_feeds_f
                        SET   effective_end_date = p_effective_end_date
                        WHERE balance_feed_id = p_balance_feed_id
                        AND   effective_start_date <= p_session_date
                        AND   effective_end_date >= p_session_date;
--
                        DELETE FROM pay_balance_feeds_f
                        WHERE  balance_feed_id = p_balance_feed_id
                        AND    effective_start_date > p_session_date;
--
        	ELSE
--
        	hr_utility.set_message (801,'PAY_6541_PRO_INVALID_ARGS');
        	hr_utility.raise_error;
--
		END IF;
--
        ELSE
--
        hr_utility.set_message (801,'PAY_6541_PRO_INVALID_ARGS');
        hr_utility.raise_error;
--
	END IF;
--
ELSIF p_option = 'DEL_INPUT_VALUE' THEN
--
        hr_utility.set_location('DEL_INPUT_VALUE', 1);
--
        IF p_input_value_id is not NULL THEN
                IF p_delete_mode = 'ZAP' THEN
--
                        IF p_mode <> 'USER' THEN
                            DELETE FROM hr_application_ownerships
                            WHERE  KEY_NAME  = 'BALANCE_FEED_ID'
                            AND    KEY_VALUE IN
                                  (SELECT balance_feed_id
                                   FROM   pay_balance_feeds_f
                                   WHERE  input_value_id = p_input_value_id);
                        END IF;
--
                        DELETE FROM pay_balance_feeds_f
                        WHERE input_value_id = p_input_value_id;
--
                ELSIF (p_delete_mode = 'DELETE' AND
                        p_session_date is not NULL) then
--
                        UPDATE pay_balance_feeds_f
                        SET   effective_end_date = p_session_date
                        WHERE input_value_id = p_input_value_id
                        AND   effective_start_date <= p_session_date
                        AND   effective_end_date >= p_session_date;
--
                        DELETE FROM pay_balance_feeds_f
                        WHERE  input_value_id = p_input_value_id
                        AND    effective_start_date > p_session_date;
--
                ELSIF (p_delete_mode = 'DELETE_NEXT_CHANGE' AND
                        p_effective_end_date is not NULL AND
                        p_session_date is not NULL) then
--
			hr_utility.trace(to_char(p_effective_end_date));
			hr_utility.trace(to_char(p_input_value_id));
			hr_utility.trace(to_char(p_session_date));
--
                        UPDATE pay_balance_feeds_f
                        SET    effective_end_date = p_effective_end_date
                        WHERE input_value_id = p_input_value_id
                        AND   effective_start_date <= p_session_date
                        AND   effective_end_date >= p_session_date;
--
                        DELETE FROM pay_balance_feeds_f
                        WHERE  input_value_id = p_input_value_id
                        AND    effective_start_date > p_session_date;
--
		ELSE
--
                hr_utility.set_message (801,'PAY_6541_PRO_INVALID_ARGS');
                hr_utility.raise_error;
--
                END IF;
--
        ELSE
--
        hr_utility.set_message (801,'PAY_6541_PRO_INVALID_ARGS');
        hr_utility.raise_error;
--
        END IF;
--
ELSIF p_option = 'DEL_SUB_CLASS_RULE' THEN
--
        hr_utility.set_location('DEL_SUB_CLASS_RULE', 1);
--
        IF (p_element_type_id is not NULL AND
            p_sub_classification_id is not NULL AND
	    p_legislation_code is not NULL) THEN
--
         v_pay_value := hr_input_values.get_pay_value_name(p_legislation_code);
--
                IF p_delete_mode = 'ZAP' THEN
--
                        IF p_mode <> 'USER' THEN
                            DELETE FROM hr_application_ownerships
                            WHERE  KEY_NAME  = 'BALANCE_FEED_ID'
                            AND    KEY_VALUE IN
                               (SELECT  feed.balance_feed_id
                                FROM    pay_balance_feeds_f feed,
                                        pay_input_values_f iv,
                                        pay_balance_classifications bc
                                WHERE   iv.element_type_id = p_element_type_id
                                AND     iv.name = 'Pay Value'
                                AND     feed.input_value_id = iv.input_value_id
                                AND     bc.classification_id
                                        = p_sub_classification_id
                                AND     feed.balance_type_id
                                        = bc.balance_type_id);
                        END IF;
--
                        DELETE FROM pay_balance_feeds_f
                        WHERE balance_feed_id in
                               (SELECT  feed.balance_feed_id
                                FROM    pay_balance_feeds_f feed,
                                        pay_input_values_f iv,
                                        pay_balance_classifications bc
                                WHERE   iv.element_type_id = p_element_type_id
                                AND     iv.name = 'Pay Value'
                                AND     feed.input_value_id = iv.input_value_id
                                AND     bc.classification_id
                                        = p_sub_classification_id
                                AND     feed.balance_type_id
                                        = bc.balance_type_id);
--
                ELSIF (p_delete_mode = 'DELETE' AND
                       p_session_date is not NULL) THEN
--
                        UPDATE pay_balance_feeds_f
                        SET   effective_end_date = p_session_date
                        WHERE balance_feed_id in
                               (SELECT  feed.balance_feed_id
                                FROM    pay_balance_feeds_f feed,
                                        pay_input_values_f iv,
                                        pay_balance_classifications bc
                                WHERE   iv.element_type_id = p_element_type_id
                                AND     iv.name = 'Pay Value'
                                AND     feed.input_value_id = iv.input_value_id
                                AND     bc.classification_id
                                        = p_sub_classification_id
                                AND     feed.balance_type_id
                                        = bc.balance_type_id)
                        AND     effective_start_date <= p_session_date
                        AND     effective_end_date >= p_session_date;
--
                        DELETE FROM pay_balance_feeds_f
                        WHERE balance_feed_id in
                               (SELECT  feed.balance_feed_id
                                FROM    pay_balance_feeds_f feed,
                                        pay_input_values_f iv,
                                        pay_balance_classifications bc
                                WHERE   iv.element_type_id = p_element_type_id
                                AND     iv.name = 'Pay Value'
                                AND     feed.input_value_id = iv.input_value_id
                                AND     bc.classification_id
                                        = p_sub_classification_id
                                AND     feed.balance_type_id
                                        = bc.balance_type_id)
                        AND   effective_start_date > p_session_date;
--
                ELSIF (p_delete_mode = 'DELETE_NEXT_CHANGE' AND
                       p_effective_end_date is not NULL AND
                       p_session_date is not NULL) THEN
--
                        UPDATE pay_balance_feeds_f
                        SET   effective_end_date = p_effective_end_date
                        WHERE balance_feed_id in
                               (SELECT  feed.balance_feed_id
                                FROM    pay_balance_feeds_f feed,
                                        pay_input_values_f iv,
                                        pay_balance_classifications bc
                                WHERE   iv.element_type_id = p_element_type_id
                                AND     iv.name = 'Pay Value'
                                AND     feed.input_value_id = iv.input_value_id
                                AND     bc.classification_id
                                        = p_sub_classification_id
                                AND     feed.balance_type_id
                                        = bc.balance_type_id)
                        AND     effective_start_date <= p_session_date
                        AND     effective_end_date >= p_session_date;
--
                        DELETE FROM pay_balance_feeds_f
                        WHERE balance_feed_id in
                               (SELECT  feed.balance_feed_id
                                FROM    pay_balance_feeds_f feed,
                                        pay_input_values_f iv,
                                        pay_balance_classifications bc
                                WHERE   iv.element_type_id = p_element_type_id
                                AND     iv.name = 'Pay Value'
                                AND     feed.input_value_id = iv.input_value_id
                                AND     bc.classification_id
                                        = p_sub_classification_id
                                AND     feed.balance_type_id
                                        = bc.balance_type_id)
                        AND   effective_start_date > p_session_date;
--
		ELSE
--
                hr_utility.set_message (801,'PAY_6541_PRO_INVALID_ARGS');
                hr_utility.raise_error;
--
                END IF;
--
	ELSE
--
        hr_utility.set_message (801,'PAY_6541_PRO_INVALID_ARGS');
        hr_utility.raise_error;
--
        END IF;
--
ELSIF p_option = 'DEL_PRIMARY_BAL_CLASS' THEN
--
        hr_utility.set_location('DEL_PRIMARY_BAL_CLASS', 1);
--
        IF (p_primary_classification_id is not NULL AND
            p_balance_type_id is not NULL AND
            p_legislation_code is not NULL) THEN
                IF p_delete_mode = 'ZAP' THEN
--
         v_pay_value := hr_input_values.get_pay_value_name(p_legislation_code);
--
                        IF p_mode <> 'USER' THEN
                            DELETE FROM hr_application_ownerships
                            WHERE  KEY_NAME  = 'BALANCE_FEED_ID'
                            AND    KEY_VALUE IN
                             (SELECT balance_feed_id
                              FROM   pay_balance_feeds_f
                              WHERE  balance_type_id = p_balance_type_id
                              AND    input_value_id IN
                               (SELECT  iv.input_value_id
                                FROM    pay_input_values_f iv,
                                        pay_element_types_f et
                                WHERE   iv.element_type_id = et.element_type_id
                                and     et.classification_id
                                        = p_primary_classification_id
                                AND     iv.name = 'Pay Value'));
                        END IF;
--
                        DELETE FROM pay_balance_feeds_f
                        WHERE   balance_type_id = p_balance_type_id
                        AND     input_value_id in
                               (SELECT  iv.input_value_id
                                FROM    pay_input_values_f iv,
                                        pay_element_types_f et
                                WHERE   iv.element_type_id = et.element_type_id
                                and     et.classification_id
                                        = p_primary_classification_id
                                AND     iv.name = 'Pay Value');
--
                ELSE
--
                hr_utility.set_message (801,'PAY_6541_PRO_INVALID_ARGS');
                hr_utility.raise_error;
--
                END IF;
--
	ELSE
--
        hr_utility.set_message (801,'PAY_6541_PRO_INVALID_ARGS');
        hr_utility.raise_error;
--
	END IF;
--
ELSIF p_option = 'DEL_SUB_BAL_CLASS' THEN
--
        hr_utility.set_location('DEL_SUB_BAL_CLASS', 1);
--
        IF (p_sub_classification_id is not NULL AND
            p_balance_type_id is not NULL AND
	    p_legislation_code is not NULL) THEN
        	IF p_delete_mode = 'ZAP' THEN
--
         v_pay_value := hr_input_values.get_pay_value_name(p_legislation_code);
--
                       IF p_mode <> 'USER' THEN
                            DELETE FROM hr_application_ownerships
                            WHERE  KEY_NAME  = 'BALANCE_FEED_ID'
                            AND    KEY_VALUE IN
                             (SELECT balance_feed_id
                              FROM   pay_balance_feeds_f
                              WHERE  balance_type_id = p_balance_type_id
                              AND    input_value_id IN
                               (SELECT  iv.input_value_id
                                FROM    pay_input_values_f iv,
                                        pay_sub_classification_rules_f scr
                                WHERE   iv.element_type_id = scr.element_type_id
                                and     scr.classification_id
                                        = p_sub_classification_id
                                AND     iv.name = 'Pay Value'
                                AND     iv.effective_end_date
                                        >= scr.effective_start_date
                                AND     iv.effective_start_date
                                        <= scr.effective_end_date));
                       END IF;
--
                       DELETE FROM pay_balance_feeds_f
                       WHERE   balance_type_id = p_balance_type_id
                       AND     input_value_id in
                               (SELECT  iv.input_value_id
                                FROM    pay_input_values_f iv,
                                        pay_sub_classification_rules_f scr
                                WHERE   iv.element_type_id = scr.element_type_id
                                and     scr.classification_id
                                        = p_sub_classification_id
                                AND     iv.name = 'Pay Value'
                                AND     iv.effective_end_date
                                        >= scr.effective_start_date
                                AND     iv.effective_start_date
                                        <= scr.effective_end_date);
--
		ELSE
--
                hr_utility.set_message (801,'PAY_6541_PRO_INVALID_ARGS');
                hr_utility.raise_error;
--
                END IF;
--
        ELSE
--
        hr_utility.set_message (801,'PAY_6541_PRO_INVALID_ARGS');
        hr_utility.raise_error;
--
        END IF;
--
ELSE
--
hr_utility.set_message (801,'PAY_6541_PRO_INVALID_ARGS');
hr_utility.raise_error;
--
END IF;
--
    END del_balance_feed;
--
    PROCEDURE del_balance_type_cascade
	      (p_balance_type_id       in number,
	       p_legislation_code      in varchar2,
               p_mode                  in varchar2) IS
/*
    NAME
        del_balance_type_cascade
    DESCRIPTION
        Cascade delete children records of balance type record,
	Balance dimensions, Balance classifications, Balance feeds.
        Also delete of pay_balance_attributes when a defined balance is
        deleted.
*/
--
   cursor get_def_bals(p_bal_type number)
   is
   select db.defined_balance_id
   from   pay_defined_balances db
   where  db.balance_type_id = p_bal_type;
   --
BEGIN
--
	hr_utility.set_location('del_balance_type_cascade', 1);
--
IF p_balance_type_id is not NULL THEN
--
  for each_def_bal in get_def_bals(p_balance_type_id) loop
  --
  -- call chk_delete_defined_balance, which will delete org_pay_methods,
  -- backpay rules, and balance attributes.
  --
    pay_defined_balances_pkg.chk_delete_defined_balance
                            (each_def_bal.defined_balance_id);
    --
    DELETE FROM pay_defined_balances
    WHERE defined_balance_id = each_def_bal.defined_balance_id;
    --
  end loop;
--
    DELETE FROM pay_balance_classifications
    WHERE balance_type_id = p_balance_type_id;
--
    IF p_mode <> 'USER' THEN
        DELETE FROM hr_application_ownerships
        WHERE  KEY_NAME  = 'BALANCE_FEED_ID'
        AND    KEY_VALUE IN
              (SELECT balance_feed_id
               FROM  pay_balance_feeds_f
               WHERE balance_type_id = p_balance_type_id);
    END IF;
--
    DELETE FROM pay_balance_feeds_f
    WHERE balance_type_id = p_balance_type_id;
--
ELSE
--
    hr_utility.set_message (801,'PAY_6541_PRO_INVALID_ARGS');
    hr_utility.raise_error;
--
END IF;
--
    END del_balance_type_cascade;
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
FUNCTION	chk_ins_sub_class_rules(
				p_sub_class_rule_id	number,
				p_element_type_id	number,
				p_classification_id	number,
			        p_session_date		date) return date is
--
	l_greatest_date	date := NULL;
--
CURSOR get_dup_class_rules(p_element_type_id	number,
			   p_classification_id	number) is
	select subcr.effective_start_date start_date,
		subcr.effective_end_date end_date
	from pay_sub_classification_rules_f subcr
	where p_element_type_id = subcr.element_type_id
	and subcr.sub_classification_rule_id <> p_sub_class_rule_id
	and p_classification_id = subcr.classification_id
	order by subcr.effective_start_date;
begin
--
  -- loop through all the duplicate sub classification rules. If they only
  -- start in the future then we need to record the first start date we come to
  -- as this -1 will be the effective_end_date of the new rule.

	for subcr_rec in get_dup_class_rules(
				p_element_type_id,
				p_classification_id) loop
--
		if p_session_date between subcr_rec.start_date and
		subcr_rec.end_date then
--
    		    hr_utility.set_message(801,'PAY_6602_ELEMENT_NO_DUP_SUBCR');
    	   	    hr_utility.raise_error;
--
		else
		    l_greatest_date := subcr_rec.start_date - 1;
		    exit;
		end if;
	end loop;
--
   -- If the greatest rule date is still null then the greatest end date will
   -- be the last end date of the element type
	if l_greatest_date is null then
--
	    select max(et.effective_end_date)
	    into l_greatest_date
	    from pay_element_types_f et
	    where p_element_type_id = et.element_type_id;
--
	end if;
--
	return(l_greatest_date);
--
end chk_ins_sub_class_rules;
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
FUNCTION	chk_ins_balance_feed(
				p_balance_feed_id	number,
				p_input_value_id	number,
				p_balance_type_id	number,
			        p_session_date		date) return date is
--
	l_greatest_date	date := NULL;
--
CURSOR get_dup_balance_feeds(p_input_value_id	number,
			   p_balance_type_id	number) is
	select bf.effective_start_date start_date,
	bf.effective_end_date end_date
	from pay_balance_feeds_f bf
	where p_input_value_id = bf.input_value_id
	and p_balance_feed_id <> bf.balance_feed_id
	and p_balance_type_id = bf.balance_type_id
	order by bf.effective_start_date;
begin
--
  -- loop through all the duplicate balance feeds. If they only
  -- start in the future then we need to record the first start date we come to
  -- as this -1 will be the effective_end_date of the new rule.

	for bf_rec in get_dup_balance_feeds(
				p_input_value_id,
				p_balance_type_id) loop
--
		if p_session_date between bf_rec.start_date and
		   bf_rec.end_date then
--
    		    hr_utility.set_message(801,'HR_6185_BAL_FEED_EXISTS');
    	   	    hr_utility.raise_error;
--
		else
		    l_greatest_date := bf_rec.start_date - 1;
		    exit;
		end if;
	end loop;
--
   -- If the greatest rule date is still null then the greatest end date will
   -- be the last end date of the input value
	if l_greatest_date is null then
--
	    select max(iv.effective_end_date)
	    into l_greatest_date
	    from pay_input_values_f iv
	    where p_input_value_id = iv.input_value_id;
--
	end if;
--
	return(l_greatest_date);
--
end chk_ins_balance_feed;

/*
    NAME
        decode_balance
    DESCRIPTION
        This function looks in the table pay_balance_types_tl for balance type id passed to
        the function. This function is called for the creation of the view
        pay_us_earnings_amounts_v which is in the payusblv.odf.
*/

function DECODE_balance ( p_balance_type_id      number) return varchar2 is
--
cursor csr_balance is
         select    balance_name
         from      pay_balance_types_tl pbt
         where     balance_type_id      = p_balance_type_id
               and language = USERENV('LANG') ;
--
v_balance_name          varchar2(80) := null;
--
begin
--
-- Only open the cursor if the parameter is not null
--
	if p_balance_type_id is not null then
  --
  		open csr_balance;
  		fetch csr_balance into v_balance_name;
  		close csr_balance;
  --
	end if;

	return v_balance_name;

end decode_balance;
--
END hr_balances;

/
