--------------------------------------------------------
--  DDL for Package PAY_PAYRG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYRG_PKG" AUTHID CURRENT_USER as
/* $Header: pypayreg.pkh 120.0.12000000.1 2007/01/17 23:29:55 appldev noship $ */
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
   09-JAN-1999  meshah      40.0            Created.
   15-AUG-2000  ahanda      115.1           Added commit before exit stmt.
   21-DEC-2001  meshah      115.2           Adding dbdrv.
   19-dec-2002  tclewis     115.3           Added nocopy
   27-DEC-2002  meshah      115.7           fixed gscc warning.
   29-OCT-2004  tclewis     115.8           added function sort_option.

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
                        len        out    nocopy number
                      );
function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2;

function sort_option  (c_option_name    in varchar2,
                        c_assignment_id  in number,
                        c_effective_date in date,
                        c_tax_unit_id    in number) return varchar2;


pragma restrict_references(get_parameter, WNDS, WNPS);
--
end pay_payrg_pkg;

 

/
