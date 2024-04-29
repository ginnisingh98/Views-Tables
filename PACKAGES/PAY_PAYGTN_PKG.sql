--------------------------------------------------------
--  DDL for Package PAY_PAYGTN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYGTN_PKG" AUTHID CURRENT_USER as
/* $Header: pypaygtn.pkh 120.2.12010000.1 2008/07/27 23:19:24 appldev ship $ */
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
   21-NOV-1999  ssarma      40.0              Created.
   04-FEB-2004  schauhan    115.4             Added oserror exit and nocopy to make
                                             it gscc standard
   09-DEC-2004  sgajula     115.5  3800371   Added procedures for Implementing BRA
   07-APR-2006  rdhingra    115.6  5148084   Added level_cnt, cursor GTN_XML_Transmitter
                                             and Procedure create_gtn_xml_data

*/

-- 'level_cnt' will allow the cursors to select function results,
-- whether it is a standard fuction such as to_char or a function
-- defined in a package (with the correct pragma restriction).
level_cnt	NUMBER;

CURSOR GTN_XML_Transmitter IS
    SELECT 'PAYROLL_ACTION_ID=P',
           pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
      FROM dual;

procedure range_cursor ( pactid in  number,
                         sqlstr out nocopy varchar2
                       );
procedure action_create_bra(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number);
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
Procedure ARCHIVE_DEINIT(p_payroll_action_id IN NUMBER);
Procedure ARCHIVE_CODE (p_payroll_action_id                 IN NUMBER
	     	       ,p_chunk_number                       IN NUMBER);
Procedure ARCHIVE_INIT(p_payroll_action_id IN NUMBER);

PROCEDURE CREATE_GTN_XML_DATA;

pragma restrict_references(get_parameter, WNDS, WNPS);
--
end pay_paygtn_pkg;

/
