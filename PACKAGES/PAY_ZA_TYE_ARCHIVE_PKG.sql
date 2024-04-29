--------------------------------------------------------
--  DDL for Package PAY_ZA_TYE_ARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ZA_TYE_ARCHIVE_PKG" authid current_user as
/* $Header: pyzatyea.pkh 120.0.12010000.1 2009/11/26 08:48:43 parusia noship $ */
/*+======================================================================+
  |       Copyright (c) 1998 Oracle Corporation South Africa Ltd         |
  |                Cape Town, Western Cape, South Africa                 |
  |                           All rights reserved.                       |
  +======================================================================+
  SQL Script File name : pyzatyea.pkh
  Description          : This sql script seeds the Package that creates
                         the Tax Year End Archive code

  Change List:
  ------------

  Name           Date        Version Bug     Text
  -------------- ----------- ------- ------  ------------------------------
  P.Arusia       17-Nov-2009 115.1   9117260 Initial Version as per TYE2010
 ==========================================================================
*/

procedure range_cursor     (pactid  in number,
                            sqlstr  out nocopy varchar2);

procedure action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) ;
--
procedure archive_data (p_assactid         in   number,
                        p_effective_date   in   date);

procedure archinit(p_payroll_action_id in number);

procedure archdinit(pactid in number);

function get_parameter
(
   name        in varchar2,
   parameter_list varchar2
)  return varchar2;

function sub_type(p_code number, user_name varchar2, p_balance_sequence number) return varchar2;

end pay_za_tye_archive_pkg;

/
