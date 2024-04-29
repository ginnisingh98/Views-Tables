--------------------------------------------------------
--  DDL for Package PAY_MX_ISR_FORMAT37
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MX_ISR_FORMAT37" AUTHID CURRENT_USER AS
/* $Header: paymxformat37mt.pkh 120.0 2005/10/17 14:14:29 kthirmiy noship $ */

/*
 +=====================================================================+
 |              Copyright (c) 1997 Orcale Corporation                  |
 |                 Redwood Shores, California, USA                     |
 |                      All rights reserved.                           |
 +=====================================================================+
Name        : paymxformat37mt.pkh
Description : This package declares functions and procedures which are
              used to return values for the Format 37 Mexico ISR Tax report.

Change List
-----------

Version Date         Author          ER/CR No. Description of Change
--------+------------+---------------+---------+--------------------------
115.0   26-Sep-2005  kthirmiy                  Created
*/

function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2;

procedure range_cursor ( pactid in  number,
                         sqlstr out nocopy varchar2
                       );
procedure action_creation ( pactid in number,
                            stperson in number,
                            endperson in number,
                            chunk in number
                          );
end pay_mx_isr_format37;

 

/
