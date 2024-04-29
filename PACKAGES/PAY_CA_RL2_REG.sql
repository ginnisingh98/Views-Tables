--------------------------------------------------------
--  DDL for Package PAY_CA_RL2_REG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_RL2_REG" AUTHID CURRENT_USER as
/* $Header: pycarl2.pkh 120.0.12000000.1 2007/01/17 17:19:48 appldev noship $ */
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
   08-OCT-2002  ssouresr    115.0           Created.
   30-DEC-2003  ssattini    115.1  3163968  Added get_label function
   22-Jan-2004  ssattini    115.2           Added function get_primary_address
                                            and Record type PrimaryAddress.
*/

procedure range_cursor (pactid in  number,
                        sqlstr out nocopy varchar2);

procedure action_creation (pactid in number,
                           stperson in number,
                           endperson in number,
                           chunk in number);

procedure sort_action (payactid   in     varchar2,
                       sqlstr     in out nocopy varchar2,
                       len        out nocopy    number);

function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2;

pragma restrict_references(get_parameter, WNDS, WNPS);

function get_label(p_lookup_type in varchar2,
                   p_lookup_code in varchar2) return varchar2;
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

end pay_ca_rl2_reg;

 

/
