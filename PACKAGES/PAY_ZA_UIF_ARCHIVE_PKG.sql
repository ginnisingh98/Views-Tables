--------------------------------------------------------
--  DDL for Package PAY_ZA_UIF_ARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ZA_UIF_ARCHIVE_PKG" AUTHID CURRENT_USER as
/* $Header: pyzauifa.pkh 120.0.12010000.1 2008/07/28 00:06:37 appldev ship $ */
/*+======================================================================+
  |       Copyright (c) 2002 Oracle Corporation                          |
  |                           All rights reserved.                       |
  +======================================================================+
  SQL Script File name : pyzauifa.pkh
  Description          : This sql script seeds the Package that creates
                        the UIF Archive code

  Change List:
  ------------

  Name           Date        Version Bug     Text
  -------------- ----------- ------- ------  ----------------------------
  L.Kloppers     21-Apr-2002   115.0 2266156 Initial Version
  L.Kloppers     06-May-2002   115.1 2266156 Added p_effective_date parameter
                                             to function get_balance_value
  L.Kloppers     09-May-2002   115.2 2266156 Added range_cursor_mag for UIF File
  Nirupa S       09-dec-2002   115.4 2686708 Added NOCOPY
  Nageswara Rao  24-JAN-2003   115.5 2654703 Added new funtion
                                             get_uif_total_remu_sub_uif
 ========================================================================
*/
type char240_data_type_table is table of varchar2(240)
     index by binary_integer;


procedure get_parameters
(
   p_payroll_action_id in  number,
   p_token_name        in  varchar2,
   p_token_value       out nocopy varchar2
);

function get_balance_value
   (
   p_assignment_id in per_all_assignments_f.assignment_id%type,
   p_balance_name in pay_balance_types.balance_name%type,
   p_dimension in pay_balance_dimensions.dimension_name%type,
   p_effective_date in date
   )
return number;

procedure range_cursor
(
   pactid in  number,
   sqlstr out nocopy varchar2
);

procedure range_cursor_mag
(
   pactid in  number,
   sqlstr out nocopy varchar2
);

procedure action_creation
(
   pactid    in number,
   stperson  in number,
   endperson in number,
   chunk     in number
);

procedure archive_data
(
   p_assactid       in number,
   p_effective_date in date
);

function process_uif_ref_no
(
   p_employer_uif_ref_no in varchar2
)  return varchar2;

procedure archinit
(
   p_payroll_action_id in number
);

function get_parameter
(
   name        in varchar2,
   parameter_list varchar2
)  return varchar2;
pragma restrict_references(get_parameter, WNDS, WNPS);


function names
(
   name   varchar2
)  return varchar2;
pragma restrict_references(names, WNDS, WNPS);

function clean
(
   name   varchar2
)  return varchar2;


function get_uif_employer_count return number;

function get_uif_total_gross_tax_rem return number;

function get_uif_total_remu_sub_uif return number;  /* Bug 2654703 */

function get_uif_total_uif_contrib return number;


function set_size
(
   p_code  in varchar2,
   p_type  in varchar2,
   p_value in varchar2
)  return varchar2;

function za_power
(
   p_number in number,
   p_power  in number
)  return number;

function za_to_char
(
   p_number in number,
   p_format in varchar2 default '&&&'
)  return varchar2;


end pay_za_uif_archive_pkg;

/
