--------------------------------------------------------
--  DDL for Package PYUSDAR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PYUSDAR_PKG" AUTHID CURRENT_USER as
/* $Header: pyusdar.pkh 115.7 2004/06/08 13:19:25 rmonge ship $ */
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
   11-DEC-2001  asasthan    110.2  2122711   Added dbdrv
   18-MAR-1999  kkawol      110.1            Added get _parameter.
   05-JAN-1999  kkawol      110.0   715891   Created.
   17-JAN_2002  tclewis     115.3            Added procedure archive_action_creation for
                                             the deposit advice process that runs off of
                                             the external process archive.
   18-FEB-2003 tclewis      115.4            Added NOCOPY directive.
   16-JAN-04 rmonge         115.6            Changed the package name to
                                             pay_us_deposit_advice_pkg
   08-JUN-04    rmonge      115.7            Cahnged the name back to pyusdar_pkg.  There is
                                             a new file payuslivearchive.pkh/pkb that
                                             delivers the package pay_us_deposit_advice_pkg.
                                             All new changes/modifications should be done
                                             to pay_us_deposit_advice_pkg. DO NOT MAKE
                                             CHANGES to this file.  This package is provided
                                             for compatilibity reasons.
--
*/
procedure range_cursor ( pactid in  number,
                         sqlstr out NOCOPY varchar2
                       );
procedure action_creation ( pactid in number,
                            stperson in number,
                            endperson in number,
                            chunk in number
                          );

procedure archive_action_creation ( pactid in number,
                            stperson in number,
                            endperson in number,
                            chunk in number
                          );

procedure sort_action ( procname   in     varchar2,
                        sqlstr     in out NOCOPY varchar2,
                        len        out    NOCOPY number
                      );
function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2;
pragma restrict_references(get_parameter, WNDS, WNPS);
--
end pyusdar_pkg;

 

/
