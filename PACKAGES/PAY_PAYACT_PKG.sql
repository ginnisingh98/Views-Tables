--------------------------------------------------------
--  DDL for Package PAY_PAYACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYACT_PKG" AUTHID CURRENT_USER as
/* $Header: pypayact.pkh 120.0.12010000.1 2008/07/27 23:19:16 appldev ship $ */
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
   Date         Name        Vers           Bug No   Description
   -----------  ----------  -----          -------  -----------------------------------
   05-APR-1999  meshah      40.0/110.0              Created.
   04-AUG-1999  rmonge      40.0/110.1              Modified Package Body
                                                    adchkdrv compliant.
   23-SEP-2003  sdahiya     115.3          3037633  Added nocopy changes.
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
                        len        out nocopy   number
                      );
function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2;
pragma restrict_references(get_parameter, WNDS, WNPS);
--
end pay_payact_pkg;

/
