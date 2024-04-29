--------------------------------------------------------
--  DDL for Package PAY_CA_PAYRG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_PAYRG_PKG" AUTHID CURRENT_USER as
/* $Header: pycapreg.pkh 120.0.12010000.1 2008/07/27 22:14:53 appldev ship $ */
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
   29-OCT-1999  jgoswami    110.0              Created.
   Based on pypayreg.pkh 110.1 99/08/04 rthakur ( Originally created by meshah).
   30-MAR-2001  jgoswami    115.1           Changed package name from
                                            pay_payrg_pkg to pay_ca_payrg_pkg
                                            as it was conflicting with pypayreg.pkh

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
                        len        out nocopy    number
                      );
function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2;
pragma restrict_references(get_parameter, WNDS, WNPS);
--
FUNCTION hours_bal_name (p_hours_balance  IN NUMBER)
RETURN VARCHAR2;

end pay_ca_payrg_pkg;

/
