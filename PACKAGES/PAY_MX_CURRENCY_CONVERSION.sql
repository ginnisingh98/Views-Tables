--------------------------------------------------------
--  DDL for Package PAY_MX_CURRENCY_CONVERSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MX_CURRENCY_CONVERSION" AUTHID CURRENT_USER AS
/* $Header: paymxcurrconv.pkh 120.0 2005/09/29 13:59:13 vmehta noship $ */
--
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1996 Oracle Corporation.                        *
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

    Name        : pay_mx_currency_conversion

    Description : Package to change currency code for Mexico
                  ( MXP to MXN )

    Change List
    -----------
     Date        Name      Vers    Bug No    Description
     ----        ----      ------  -------   -----------
     19-Aug-2005 vpandya   115.0             Created

*/

  PROCEDURE currency_mxp_to_mxn
             (errbuf                      OUT NOCOPY VARCHAR2
             ,retcode                     OUT NOCOPY NUMBER
             ,p_business_group_id         IN  NUMBER
             ,p_conv_curr_code            IN  VARCHAR2
             );

  FUNCTION get_converted_curr_code ( p_business_group_id NUMBER )
    RETURN VARCHAR2;

end pay_mx_currency_conversion;

 

/
