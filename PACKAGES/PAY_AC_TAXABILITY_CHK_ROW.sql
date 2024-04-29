--------------------------------------------------------
--  DDL for Package PAY_AC_TAXABILITY_CHK_ROW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AC_TAXABILITY_CHK_ROW" AUTHID CURRENT_USER as
/* $Header: paytaxrulchkrow.pkh 120.0 2005/09/10 03:51 psnellin noship $ */

/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Package Body Name : pay_ac_taxability_chk_row
    Package File Name : paytaxrulchkrow.pkb
    Description : This package declares functions and procedures
                  which supports US and CA taxability rules upload
                  via spread sheet loader.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    21-JUN-04   fusman      115.0             Created
 *******************************************************************/


 -- Package Variables


  /************************************************************
  ** Function called for US Federal Context is passed
  ************************************************************/
  FUNCTION get_taxability_rule_row
                 (p_legislation_code  IN  VARCHAR2,
                  p_tax_type          IN  VARCHAR2,
                  p_tax_category    IN  VARCHAR2,
                  p_classification_id IN NUMBER,
                  p_jurisdiction_code IN  VARCHAR2)
  RETURN VARCHAR2;

  FUNCTION get_county_city_name
             (p_jurisdiction_code IN  VARCHAR2,
              p_county_or_city    IN  VARCHAR2)
  RETURN VARCHAR2;

  FUNCTION get_state_name
           (p_jurisdiction_code IN  VARCHAR2)
  RETURN VARCHAR2;
end pay_ac_taxability_chk_row;

 

/
