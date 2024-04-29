--------------------------------------------------------
--  DDL for Package PAY_HOURS_BY_RATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_HOURS_BY_RATE" AUTHID CURRENT_USER AS
/* $Header: payhoursbyrate.pkh 120.1 2006/04/13 14:38 ahanda noship $ */
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
   13-APR-2006  ahanda      115.1           Added global variables for amount

*/

  gn_amt_input_value_id  NUMBER;
  gn_rate_input_value_id NUMBER;
  gn_hour_input_value_id NUMBER;
  gn_mult_input_value_id NUMBER;

  gn_amt_result_value    NUMBER;
  gn_rate_result_value   NUMBER;
  gn_hour_result_value   NUMBER;
  gn_mult_result_value   NUMBER;

  gn_element_type_id     NUMBER;
  gn_run_result_id       NUMBER;

  /******************************************************************
  ** Function used in the pay_hours_by_rate_v to return the value
  ** depending on the mode i.e. Hours, Rate and Multiple
  ******************************************************************/
  FUNCTION get_result_value(p_run_result_id   in number
                           ,p_element_type_id in number
                           ,p_mode            in varchar2)
  RETURN NUMBER;

END pay_hours_by_rate;

 

/
