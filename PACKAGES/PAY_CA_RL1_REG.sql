--------------------------------------------------------
--  DDL for Package PAY_CA_RL1_REG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_RL1_REG" AUTHID CURRENT_USER as
/* $Header: pycarrrg.pkh 120.0 2005/05/29 03:44:26 appldev noship $ */
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
   06-JAn-2000  mmukherj    110.0              Created.
   26-Dec-2001  vpandya     115.1           Added function get_rl1_message and
                                            dbdrv lines.
   08-Jan-2002  vpandya     115.2           Added one more parameter p_hire_dt
                                            in the function get_rl1_message.
   16-Aug-2002  vpandya     115.3           Added parameter p_termination_dt
                                            in the function get_rl1_message.
   06-Nov-2002  vpandya     115.4           Added function get_primary_address
                                            and Record type PrimaryAddress.
   06-Nov-2002  vpandya     115.5           Added address_line_5 in the
                                            PrimaryAddress record type to get
                                            country.
   08-Nov-2002  vpandya     115.6           Added address_line_6 which returns
                                            Country Name where as line 5 returns
                                            Country Code.
   02-DEC-2002  vpandya     115.7           Added nocopy with out parameter
                                            as per GSCC.
   03-DEC-2002  vpandya     115.8           Modified structure PrimaryAddress
                                            added city, province and postal code
   03-SEP-2004  vpandya     115.9           Added get_label function to fix
                                            NLS bug#3810959.
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
function get_rl1_message(p_tax_year        in varchar2,
                         p_emp_dob         in varchar2,
                         p_hire_dt         in varchar2,
                         p_termination_dt  in varchar2) return varchar2;
--
/* Get Primary Address */
/* Address lines 1,2,3 are normal address lines */
/* Address Line 4 = City + Province Code + Postal Code */
/* Address Line 5 = Country Code */
/* Address Line 6 = Country Name */
/* Address Line 7 = Town or City */
/* Address Line 8 = Province Code */
/* Address Line 9 = Postal Code */

TYPE PrimaryAddress IS RECORD (
     addr_line_1 varchar2(240) := NULL,
     addr_line_2 varchar2(240) := NULL,
     addr_line_3 varchar2(240) := NULL,
     addr_line_4 varchar2(240) := NULL,
     addr_line_5 varchar2(240) := NULL,
     addr_line_6 varchar2(240) := NULL,
     city        varchar2(240) := NULL,
     province    varchar2(240) := NULL,
     postal_code varchar2(240) := NULL);

function get_primary_address(p_person_id       in Number,
                             p_effective_date  in date
                            ) return PrimaryAddress;

function get_label(p_lookup_type in varchar2,
                    p_lookup_code in varchar2) return varchar2;

function get_label(p_lookup_type in varchar2,
                    p_lookup_code in varchar2,
                    p_person_language in varchar2 ) return varchar2;

end pay_ca_rl1_reg;

 

/
