--------------------------------------------------------
--  DDL for Package PAY_YREND_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_YREND_REPORTS_PKG" AUTHID CURRENT_USER as
/* $Header: pyusw2cu.pkh 120.0.12010000.2 2008/08/06 08:40:47 ubhat ship $ */
/*
   ******************************************************************
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
   09-JAN-1999  meshah      40.0              Created.
   24-DEC-2001  meshah      115.1             dbdrv command.
   09-DEC-2003  asasthan    115.2             nocopy changes.
   12-MAY-2008  keyazawa    115.3  5896290  added deinitialize_code
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
procedure sort_action ( payactid   in     varchar2,
                        sqlstr     in out nocopy varchar2,
                        len        out nocopy number
                      );
function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2;
--
procedure deinitialize_code(
  p_payroll_action_id in number);
--
end pay_yrend_reports_pkg;

/
