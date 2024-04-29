--------------------------------------------------------
--  DDL for Package Body PAY_HOURS_BY_RATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_HOURS_BY_RATE" AS
/* $Header: payhoursbyrate.pkb 120.1 2006/04/13 14:39 ahanda noship $ */
/* ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
   *                   Chertsey, England.                           *
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

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   01-FEB-2005  ahanda      115.0  4118279  Created
   13-APR-2006  ahanda      115.1           Added logic to get amount and return

*/

  FUNCTION get_input_value(p_element_type_id  in number
                          ,p_input_value_name in varchar2)
  RETURN NUMBER
  IS
    cursor c_input_value_id is
      select piv.input_value_id
        from pay_input_values_f piv
       where piv.name = p_input_value_name
         and piv.element_type_id = p_element_type_id;

    ln_input_value_id NUMBER;

  BEGIN
    open c_input_value_id;
    fetch c_input_value_id into ln_input_value_id;
    close c_input_value_id;

    return(ln_input_value_id);
  END get_input_value;

  FUNCTION get_result_value(p_run_result_id   in number
                           ,p_element_type_id in number
                           ,p_mode            in varchar2)
  RETURN NUMBER
  IS

    cursor c_get_run_result(cp_run_result_id  in number
                           ,cp_input_value_id in number) is
      select prrv.result_value
       from pay_run_result_values prrv
       where prrv.run_result_id = cp_run_result_id
         and prrv.input_value_id = cp_input_value_id;

    ln_return NUMBER;

  BEGIN
    hr_utility.trace('Called get_result_value');
    hr_utility.trace('p_mode='           ||p_mode);
    hr_utility.trace('p_run_result_id='  ||p_run_result_id);
    hr_utility.trace('p_element_type_id='||p_element_type_id);

    /*****************************************************************
    ** The element_type_id passed to the package will always be the
    ** seeded element, so, it will have the Hours, Rate and
    ** Multiple input values.
    ** We are checking to see if the input value package variable
    ** is null and also the element_type_id passed is the same as
    ** before to ensure that we only call this once. Reason to check
    ** for element is that this view/package is global so could be
    ** called for different element type_id for diff legislation.
    *****************************************************************/
    if (gn_element_type_id = -1 or
        gn_element_type_id <> p_element_type_id or
        gn_hour_input_value_id is null) then

       hr_utility.trace('Called Input Value');
       gn_amt_input_value_id  := get_input_value(p_element_type_id, 'Pay Value');
       gn_rate_input_value_id := get_input_value(p_element_type_id, 'Rate');
       gn_hour_input_value_id := get_input_value(p_element_type_id, 'Hours');
       gn_mult_input_value_id := get_input_value(p_element_type_id, 'Multiple');
       gn_element_type_id     := p_element_type_id;
    end if;

    hr_utility.trace('gn_run_result_id='  ||gn_run_result_id);
    /*****************************************************************
    ** Check if the run_result_id passed to it has change other we
    ** return from the cached information.
    *****************************************************************/
    if gn_run_result_id = -1 or gn_run_result_id <> p_run_result_id then
       gn_run_result_id     := p_run_result_id;
       gn_amt_result_value  := null;
       gn_rate_result_value := null;
       gn_hour_result_value := null;
       gn_mult_result_value := null;

       hr_utility.trace('Called Run Result');
       open c_get_run_result(p_run_result_id, gn_rate_input_value_id);
       fetch c_get_run_result into gn_rate_result_value;
       close c_get_run_result;

       open c_get_run_result(p_run_result_id, gn_hour_input_value_id);
       fetch c_get_run_result into gn_hour_result_value;
       close c_get_run_result;

       open c_get_run_result(p_run_result_id, gn_mult_input_value_id);
       fetch c_get_run_result into gn_mult_result_value;
       close c_get_run_result;

       open c_get_run_result(p_run_result_id, gn_amt_input_value_id);
       fetch c_get_run_result into gn_amt_result_value;
       close c_get_run_result;
    end if;

    if p_mode = 'Rate' then
       ln_return := gn_rate_result_value;
    elsif p_mode = 'Hours' then
       ln_return := gn_hour_result_value;
    elsif p_mode = 'Multiple' then
       ln_return := gn_mult_result_value;
    elsif p_mode = 'Pay Value' then
       ln_return := gn_amt_result_value;
    end if;

    hr_utility.trace('Exiting get_result_value - ln_return='|| ln_return);
    return(ln_return);

  END get_result_value;

BEGIN
  gn_amt_input_value_id  := null;
  gn_rate_input_value_id := null;
  gn_hour_input_value_id := null;
  gn_mult_input_value_id := null;
  gn_element_type_id     := -1;
  gn_run_result_id       := -1;


END pay_hours_by_rate;

/
