--------------------------------------------------------
--  DDL for Package PAY_ZA_IRP5_ARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ZA_IRP5_ARCHIVE_PKG" AUTHID CURRENT_USER as
/* $Header: pyzaarch.pkh 120.1.12010000.1 2008/07/28 00:02:38 appldev ship $ */
/*+======================================================================+
  |       Copyright (c) 1998 Oracle Corporation South Africa Ltd         |
  |                Cape Town, Western Cape, South Africa                 |
  |                           All rights reserved.                       |
  +======================================================================+
  SQL Script File name : pyzaarch.pkb
  Description          : This sql script seeds the Package that creates
                        the IRP5 Archive code

  Change List:
  ------------

  Name           Date        Version Bug     Text
  -------------- ----------- ------- ------  ------------------------------
  N. Bristow     23-Jun-1999   110.0         Initial Version created from
                                             pyusarch.pkb
  F.D. Loubser   29-Mar-2000   110.1         Added payroll_id insert on
                                             payroll_action_id
  F.D. Loubser   01-Jun-2000   110.2         Added za_to_char function
  F.D. Loubser   18-Jul-2000   110.3         Limit initials to 5 characters
  R.Kingham      23-Aug-2000   110.11 34307  Changed boolean to true to cater
                                             for ass_sets with exclude assignments. See TAR34307
  R.Kingham      25-Nov-2000   110.12 37293  The above fix created problems for Assignment Sets
                                             with assignments set to Include.
                                             See TAR37293 for comments
  F.D. Loubser   19-Nov-2001   115.2         Added dbdrv line
  L.Kloppers     12-Sep-2002   115.3 2224332 Modified Function set_size to accept two extra
                                             non-mandatory parameters: Tax Status and Nature of
                                             Person
  L.Kloppers     27-Nov-2002   115.4 2686708 Added nocopy to out parameters
 ========================================================================
*/
type char240_data_type_table is table of varchar2(240)
     index by binary_integer;

max_num    varchar2(30) := 'START';
g_nature   varchar2(1);
g_3696     number;
g_3699     number;
level_cnt  number;

procedure range_cursor
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

procedure archinit
(
   p_payroll_action_id in number
);

procedure archdinit
(
   p_payroll_action_id in number
);

function get_parameter
(
   name        in varchar2,
   parameter_list varchar2
)  return varchar2;
pragma restrict_references(get_parameter, WNDS, WNPS);

function get_lump_sum
(
   p_assid    in number,     -- The Assignment ID
   p_assactid in number,     -- The Assignment Action ID of a Payroll Run
   p_index    in number      -- Identifies the balance we are looking for
)  return varchar2;
--pragma restrict_references(get_lump_sum, WNDS);

function initials
(
   name   varchar2
)  return varchar2;
pragma restrict_references(initials, WNDS, WNPS);

function names
(
   name   varchar2
)  return varchar2;
pragma restrict_references(names, WNDS, WNPS);

function clean
(
   name   varchar2
)  return varchar2;

function get_size return number;

function get_employer_count return number;

function get_employer_code return number;

function get_employer_amounts return number;

function get_file_count return number;

function gen_x
(
   p_code      in varchar2,
   p_bg_id     in varchar2,
   p_tax_year  in varchar2,
   p_test_flag in varchar2
)  return varchar2;

function cert_num
(
   p_bg       number,
   p_tax_year varchar2,
   p_pay      varchar2,
   p_ass      number
)  return varchar2;

function set_size
(
   p_code         in varchar2,
   p_type         in varchar2,
   p_value        in varchar2,
   p_tax_status   in varchar2 default 'A',
   p_nature       in varchar2 default 'A'
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

function put_nature
(
   p_nature in varchar2
)  return varchar2;

function put_3696
(
   p_3696 in number
)  return varchar2;

function put_3699
(
   p_3699 in number
)  return varchar2;

function get_stored_values
(
   p_nature out nocopy varchar2,
   p_3699   out nocopy number,
   p_3696   out nocopy number
)  return varchar2;

end pay_za_irp5_archive_pkg;

/
