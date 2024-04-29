--------------------------------------------------------
--  DDL for Package PAY_CREATE_ELEMNT_TMPLT_RECORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CREATE_ELEMNT_TMPLT_RECORD" AUTHID CURRENT_USER as
/* $Header: paycreatetemplte.pkh 120.1 2005/06/13 17:17 pganguly noship $ */
--
/*
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation US Ltd.,                *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation USA Ltd, *
   *  USA.                                                          *
   *                                                                *
   ******************************************************************

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   02-MAY-2005  pganguly    115.0           Created.
   13-JUN-2005  pganguly    115.1           Added p_currency_code parameter
                                            in the earnings template.
*/
--
procedure create_elemnt_tmplt_usages(p_template_id         IN NUMBER,
                                     p_classification_type IN VARCHAR2,
                                     p_legislation_code    IN VARCHAR2);

procedure create_dedn_flat_amt_templ( p_legislation_code IN VARCHAR2,
                                      p_currency_code    IN VARCHAR2) ;

procedure create_dedn_pct_amt_templ( p_legislation_code IN VARCHAR2,
                                     p_currency_code    IN VARCHAR2) ;

procedure create_earn_flat_amt_templ( p_legislation_code IN VARCHAR2,
                                      p_currency_code    IN VARCHAR2);

procedure create_earn_hxr_amt_templ( p_legislation_code IN VARCHAR2,
                                      p_currency_code   IN VARCHAR2);

procedure create_earn_pct_amt_templ( p_legislation_code IN VARCHAR2,
                                      p_currency_code   IN VARCHAR2);

procedure create_all_templates(p_legislation_code IN VARCHAR2,
                               p_currency_code    IN VARCHAR2);

end pay_create_elemnt_tmplt_record;

 

/
