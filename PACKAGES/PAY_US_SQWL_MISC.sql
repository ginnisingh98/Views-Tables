--------------------------------------------------------
--  DDL for Package PAY_US_SQWL_MISC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_SQWL_MISC" AUTHID CURRENT_USER AS
/* $Header: pyussqmn.pkh 115.0 2002/03/16 08:22:46 pkm ship        $ */
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

    Name        : pay_us_sqwl_misc

    Description :

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    14-MAR-2002 asasthan    115.0
*/


  FUNCTION get_old_month3_count(
                p_asact_ctx_id      in number
               )
  RETURN VARCHAR2;

  FUNCTION get_old_month2_count(
                p_asact_ctx_id      in number
               )
  RETURN VARCHAR2;


  FUNCTION get_old_month1_count(
                p_asact_ctx_id      in number
               )
  RETURN VARCHAR2;

END pay_us_sqwl_misc;

 

/
