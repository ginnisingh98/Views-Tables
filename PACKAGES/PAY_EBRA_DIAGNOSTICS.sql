--------------------------------------------------------
--  DDL for Package PAY_EBRA_DIAGNOSTICS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EBRA_DIAGNOSTICS" AUTHID CURRENT_USER AS
/* $Header: payrundiag.pkh 120.0 2005/05/29 10:49:45 appldev noship $ */
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

    Name        : pay_us_ebra_diagnostics

    Description :  package to Validate Balance Reporting Architecure


    Change List
    -----------
     Date        Name      Vers    Bug No  Description
     ----        ----      ------  ------- -----------
     19-aug-2004 djoshi    115.0           Created.
     26-aug-2004 djoshi    115.1           Removed Year as Parameter
     16-sep-2004 djoshi    115.2           Added parameter
                                           p_attribute_balance
*/


PROCEDURE ebra_diagnostics
           (errbuf                OUT nocopy    varchar2,
            retcode               OUT nocopy    number,
            p_output_file_type    IN      VARCHAR2,
            p_attribute_balance   IN      VARCHAR2
           );



end pay_ebra_diagnostics;

 

/
