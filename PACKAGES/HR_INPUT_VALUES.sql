--------------------------------------------------------
--  DDL for Package HR_INPUT_VALUES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_INPUT_VALUES" AUTHID CURRENT_USER as
/* $Header: pyinpval.pkh 115.0 99/07/17 06:09:25 porting ship $ */
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
    Name        : hr_input_values
--
    Description : This package holds procedures and functions related to the
                  following tables :
--
                  PAY_INPUT_VALUES_F
--
    Uses        : hr_input_values
		: hr_balances
    Used By     : db_elements
		: hr_elements
--
    Test List
    ---------
    Procedure                     Name       Date        Test Id Status
    +----------------------------+----------+-----------+-------+--------------+
    chk_input_values              M Dyer     27-Nov-1992  1      Completed
    chk_input_values              M Dyer     09-Dec-1992  2      Completed
    +--------------------------------------------------------------------------+
    chk_max_and_min               M Dyer     27-Nov-1992  1      Completed
    +--------------------------------------------------------------------------+
    chk_hot_defaults		  M Dyer     08-Dec-1992  1	 Not complete
    +--------------------------------------------------------------------------+
    chk_entry_default (function)  M Dyer     08-Dec-1992  1      Not complete
    +--------------------------------------------------------------------------+
    ins_3p_input_values		  M Dyer     08-Dec-1992  1      Complete
    +--------------------------------------------------------------------------+
    chk_del_input_values	  M Dyer     08-Dec-1992  1      Not complete
    +--------------------------------------------------------------------------+
    create_link_input_value	  M Dyer     08-Dec-1992  1 	 Complete
    +--------------------------------------------------------------------------+
    chk_upd_input_values	  M Dyer     08-Dec-1992  1	 Not complete
    +--------------------------------------------------------------------------+
    del_3p_input_values           M Dyer     08-Dec-1992  1      Not complete


    Change List
    -----------
    Date         Name          Vers    Bug No     Description
    +-----------+-------------+-------+----------+-----------------------------+     27-Nov-92   M Dyer         30.0              Created with chk_input_values                                                  and chk_max_and_min
     08-Dec-92   M Dyer 	30.0		  Created other input value
						  procedures.
     09-Dec-92   M Dyer		30.1		Added standard link conditions
						to chk_input_values.
     11-MAR-93   N Khan         30.2             Added 'exit' to the end

    +-----------+-------------+-------+----------+-----------------------------+*/
--
 /*
 NAME
  chk_input_value
 DESCRIPTION
  Checks attributes of inserted and update input values for concurrence
  with business rules.
 */
--
 PROCEDURE chk_input_value(p_element_type_id         in number,
			   p_legislation_code	     in varchar2,
                           p_val_start_date     in date,
                           p_val_end_date       in date,
			   p_insert_update_flag in varchar2,
			   p_input_value_id          in number,
			   p_rowid                   in varchar2,
			   p_recurring_flag          in varchar2,
			   p_mandatory_flag	     in varchar2,
			   p_hot_default_flag	     in varchar2,
                           p_standard_link_flag      in varchar2,
			   p_classification_type     in varchar2,
			   p_name                    in varchar2,
			   p_uom                     in varchar2,
			   p_min_value               in varchar2,
			   p_max_value               in varchar2,
			   p_default_value           in varchar2,
			   p_lookup_type             in varchar2,
			   p_formula_id              in number,
			   p_generate_db_items_flag  in varchar2,
			   p_warning_or_error        in varchar2);
--
 /*
 NAME
  chk_entry_default
 DESCRIPTION
  This function will check if all entries for an element link and an input
  value have a default value. This is called in situations where we need to
  check for defaults because of hot defaulting. This function will return TRUE
  if any nulls are found in the selected entries.
 */
--
FUNCTION chk_entry_default(f_input_value_id     in number,
                        f_element_link_id       in number,
                        f_val_start_date        in date,
                        f_val_end_date          in date) return BOOLEAN;
--
--
 /*
 NAME
  chk_link_hot_defaults
 DESCRIPTION
  This procedure checks whether all link_input_values and entry values have
  defaults if a hot defaulted default value is made null. It calls the function chk_entry_default
  */
--
PROCEDURE chk_link_hot_defaults(p_update_mode           in varchar2,
                                p_val_start_date        in date,
                                p_val_end_date          in date,
                                p_input_value_id        in number,
                                p_element_link_id       in number,
                                p_default_delete        in varchar2,
                                p_min_delete            in varchar2,
                                p_max_delete            in varchar2);
 /*
 NAME
  chk_hot_defaults
 DESCRIPTION
  This procedure checks whether all link_input_values and entry values have
  defaults if a hot defaulted default value is made null. It calls the function
  chk_entry_default
  */
--
PROCEDURE chk_hot_defaults(p_update_mode                in varchar2,
                                p_val_start_date        in date,
                                p_val_end_date          in date,
                                p_input_value_id        in number,
                                p_element_type_id       in number,
                                p_default_deleted       in varchar2,
                                p_min_deleted           in varchar2,
                                p_max_deleted           in varchar2);
--
 /*
 NAME
  chk_del_input_value
 DESCRIPTION
  Checks whether an input value can be deleted. This consists of checking
  if various child records exist for this input value.
 */
--
PROCEDURE chk_del_input_values(p_delete_mode            in varchar2,
                                p_val_start_date        in date,
                                p_val_end_date          in date,
                                p_input_value_id        in number);
--
 /*
 NAME
  chk_field_update
 DESCRIPTION
  A general function for input values that forces correction for a particular
  field over the lifetime of a complete input value. It should be called after
  the postfield datetrack trigger.
 */
FUNCTION       chk_field_update(
                        p_input_value_id        in number,
                        p_val_start_date        in date,
                        p_val_end_date          in date,
                        p_update_mode           in varchar2) return BOOLEAN;
--
--
 /*
 NAME
  get_pay_value_name
 DESCRIPTION
  gets pay value from translation table.
  */
--
FUNCTION        get_pay_value_name(p_legislation_code   varchar2)
                                        return varchar2;
--
 /*
 NAME
  chk_upd_input_value
 DESCRIPTION
  Checks whether an input value can be updated. Some values can be updated
  under any circumstances and others can only be updated if certain conditions
  exist. For instance if there are no links in existence. This procedure calls
  chk_hot_defaults.
 */
--
PROCEDURE chk_upd_input_values( p_update_mode		in varchar2,
                                p_val_start_date	in date,
                                p_val_end_date		in date,
                                p_classification_type	in varchar2,
                                p_old_name		in varchar2,
                                p_name			in varchar2,
                                p_input_value_id	in number,
                                p_element_type_id	in number,
                                p_old_uom		in varchar2,
                                p_uom			in varchar2,
                                p_old_db_items_flag	in varchar2,
                                p_db_items_flag		in varchar2,
                                p_old_default_value	in varchar2,
                                p_default_value		in varchar2,
                                p_old_min_value		in varchar2,
                                p_min_value		in varchar2,
                                p_old_max_value		in varchar2,
                                p_max_value		in varchar2,
                                p_old_error_flag	in varchar2,
                                p_error_flag		in varchar2,
                                p_old_mandatory_flag	in varchar2,
                                p_mandatory_flag	in varchar2,
                                p_old_formula_id        in number,
                                p_formula_id            in number,
                                p_old_lookup_type       in varchar2,
                                p_lookup_type           in varchar2,
				p_business_group_id	in number,
                                p_legislation_code 	in varchar2);
--
 /*
 NAME
  create_link_input_value
 DESCRIPTION
  This procedure creates links under two circumstances.
  1. When a new link has been created.
  2. When a new input value is created and there are already existing links
  This behaviour is controlled by the p_insert_type parameter which can take the
  values 'INSERT_LINK' or 'INSERT_INPUT_VALUE'.
  */
--
PROCEDURE
          create_link_input_value(p_insert_type            varchar2,
                                  p_element_link_id        number,
                                  p_input_value_id         number,
                                  p_input_value_name       varchar2,
                                  p_costable_type          varchar2,
                                  p_validation_start_date  date,
                                  p_validation_end_date    date,
                                  p_default_value          varchar2,
                                  p_max_value              varchar2,
                                  p_min_value              varchar2,
                                  p_warning_or_error_flag  varchar2,
                                  p_hot_default_flag       varchar2,
                                  p_legislation_code       varchar2,
                                  p_pay_value_name         varchar2,
                                  p_element_type_id        number);
--
 /*
 NAME
  ins_3p_input_values
 DESCRIPTION
  This procedure controls the third party inserts when an input value is
  created manually. (Rather than being created at the same time as an element
  type.) It calls the procedures create_link_input_value and
  hr_balances.ins_balance_feed.
  */
--
PROCEDURE	ins_3p_input_values(p_val_start_date	in date,
				p_val_end_date		in date,
				p_element_type_id	in number,
				p_primary_classification_id in number,
				p_input_value_id	in number,
				p_default_value		in varchar2,
				p_max_value		in varchar2,
				p_min_value		in varchar2,
				p_warning_or_error_flag	in varchar2,
				p_input_value_name	in varchar2,
                                p_db_items_flag         in varchar2,
				p_costable_type	   	in varchar2,
				p_hot_default_flag	in varchar2,
				p_business_group_id	in number,
				p_legislation_code	in varchar2,
				p_startup_mode		in varchar2);
--
 /*
 NAME
  upd_3p_input_values
 DESCRIPTION
  This procedure should be called on post delete. When the name has been
  updated and create database items is set to Yes then the database items
  will be dropped and recreated. This will fail if it is unable to drop the
  database items.
  */
PROCEDURE	upd_3p_input_values(p_input_value_id 	in number,
				    p_val_start_date	in date,
				    p_old_name		in varchar2,
				    p_name		in varchar2,
				    p_db_items_flag	in varchar2,
				    p_old_db_items_flag	in varchar2);
--
--
 /*
 NAME
  del_3p_input_values
 DESCRIPTION
  This procedure does the necessary cascade deletes when deleting an input
  value. This only deletes balance feeds. It calls the procedure -
  hr.balances.del_balance_feed.
  */
--
PROCEDURE       del_3p_input_values(p_delete_mode       in varchar2,
                                    p_input_value_id    in number,
                                    p_db_items_flag     in varchar2,
                                    p_val_end_date      in date,
                                    p_session_date      in date,
				    p_startup_mode	in varchar2);
--
end hr_input_values;

 

/
