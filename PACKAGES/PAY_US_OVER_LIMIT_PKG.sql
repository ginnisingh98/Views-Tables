--------------------------------------------------------
--  DDL for Package PAY_US_OVER_LIMIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_OVER_LIMIT_PKG" AUTHID CURRENT_USER as
/* $Header: pyusoltm.pkh 120.0.12010000.1 2008/07/27 23:54:31 appldev ship $ */
/*
   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
--
   Name        :This package defines the cursors needed for OLT to run Multi-Threaded
--
   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   01-DEC-2001  irgonzal    115.0  2045352  Created.
   05-FEB-2002  meshah      115.1           Added checkfile entry to the file.
   18-MAY-2003  vgunasek    115.3  2938556  Added no copy for the out parameters.
   02-JUN-2003  vgunasek    115.4  2938556  Added change history.

--
*/
procedure range_cursor ( pactid in  number,
                         sqlstr out nocopy varchar2
                       );

procedure action_creation ( pactid in number,
                            stperson in number,
                            endperson in number,
                            chunk in number
                          );

procedure sort_action ( pactid   in     varchar2,
                        sqlstr     in out nocopy varchar2,
                        len        out   nocopy  number
                      );

function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2;

pragma restrict_references(get_parameter, WNDS, WNPS);
--
end pay_us_over_limit_pkg;

/
