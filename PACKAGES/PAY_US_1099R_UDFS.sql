--------------------------------------------------------
--  DDL for Package PAY_US_1099R_UDFS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_1099R_UDFS" AUTHID CURRENT_USER AS
/* $Header: py99udfs.pkh 120.0.12010000.1 2008/07/27 21:59:13 appldev ship $ */
/*
+======================================================================+
|                Copyright (c) 1996 Oracle Corporation                 |
|                   Redwood Shores, California, USA                    |
|                        All rights reserved.                          |
+======================================================================+

    Name        : pay_us_1099R_udfs
    Filename    : py99udfs.pkh
    Purpose     : creates user defined functions for 1099R

    Change List
    -----------
    Date        Name            Vers    Bug No  Description
    ----        ----            ----    ------  -----------
    3/10        HEKIM           40.0            Created.
    23-MAY-97   M.Reid          40.1            Removed show errors.
    12-NOV-02   D.Joshi        115.2            Added CFS_control Total
                                                for all other Payable
    18-nov-02   djoshi         115.3            Added dbdrv command
    02-dec-02   djoshi         115.4            No Copy added to all
                                                out Parameter
    30-OCT-2003 jgoswami       115.6            Added GET_1099R_ITEM_DATA,
                                                format_pub1220_address.
    06-NOV-2003 jgoswami       115.7            Added format_1099r_wv_address
    13-NOV-2003 jgoswami       115.8   3241256  Added GET_1099R_TRANSMITTER_VALUE
*/
  --
  --
  TYPE numeric_data_table IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;

  gt_combined_filer_state_payees numeric_data_table;
  gt_CFS_control_total_1  numeric_data_table;
  gt_CFS_control_total_2  numeric_data_table;
  gt_CFS_control_total_3  numeric_data_table;
  gt_CFS_control_total_4  numeric_data_table;
  gt_CFS_control_total_5  numeric_data_table;
  gt_CFS_control_total_6  numeric_data_table;
  gt_CFS_control_total_8  numeric_data_table;
  gt_CFS_control_total_9  numeric_data_table;
  gt_CFS_SIT_total        numeric_data_table;
  gt_CFS_LIT_total        numeric_data_table;
  --
  FUNCTION init_global_1099R_tables(p_dummy in VARCHAR2) RETURN VARCHAR2;
  --
  FUNCTION get_1099R_state_payee_count(p_state in VARCHAR2) RETURN NUMBER;
  --
  FUNCTION state_1099R_specs(  p_state    in VARCHAR2,
                               p_amount_1 in NUMBER,
                               p_amount_2 in NUMBER,
                               p_amount_3 in NUMBER,
                               p_amount_4 in NUMBER,
                               p_amount_5 in NUMBER,
                               p_amount_6 in NUMBER,
			       p_amount_8 in NUMBER,
			       p_amount_9 in NUMBER,
			       p_SIT      in NUMBER,
			       p_LIT      in NUMBER,
			       p_SEIN     in VARCHAR2,
		               p_state_taxable in NUMBER) RETURN VARCHAR2;
  --
  FUNCTION get_1099R_name_control (p_name in VARCHAR2) RETURN VARCHAR2;
  --
  FUNCTION get_1099R_NE_SEIN (p_SEIN in VARCHAR2) RETURN VARCHAR2;
  --
  FUNCTION get_1099R_state_total(p_state in VARCHAR2,
                                 p_type in VARCHAR2 )  RETURN VARCHAR2;
  --
  FUNCTION combined_filer_1099R_state (p_state in VARCHAR2) RETURN VARCHAR2;
  --
  FUNCTION get_1099R_state_code (p_state in VARCHAR2) RETURN VARCHAR2;

FUNCTION Get_1099R_value(
                   p_assignment_action_id     number, -- context
                   p_tax_unit_id              number,-- context
                   sp_out_1               OUT nocopy varchar2,
                   sp_out_2               OUT nocopy varchar2,
                   sp_out_3               OUT nocopy varchar2,
                   sp_out_4               OUT nocopy varchar2,
                   sp_out_5               OUT nocopy varchar2,
                   sp_out_6               OUT nocopy varchar2,
                   sp_out_7               OUT nocopy varchar2,
                   sp_out_8               OUT nocopy varchar2,
                   sp_out_9               OUT nocopy varchar2,
                   sp_out_10              OUT nocopy varchar2)
RETURN VARCHAR2;

FUNCTION Get_1099R_ny_value(
                   p_assignment_action_id     number, -- context
                   p_tax_unit_id              number,-- context
                   p_state               in varchar2)
RETURN VARCHAR2;


--
-- Function GET_1099R_ITEM_DATA is a generalized function which can be
-- used to get data for a given item_type.
-- Function to Get Payee Latest Address
--
/*
    Parameters :
               p_effective_date -
                           This parameter indicates the year for the function.
               p_item_name   -  'EE_ADDRESS'
                                identifies Employee Address required for
                                Employee record.
               p_report_type - This parameter will have the type of the report.
                               eg: '1099R'
               p_format -    This parameter will have the format to be printed
                             on 1099R. eg:'PUB1220','MMREF'
                             ( Will be used when we move the formatting from formula to function)
               p_record_name - This parameter will have the particular
                               record name. eg: B for PUB1220
               p_validate - This parameter will check whether it wants to
                            validate the error condition or override the
                            checking.
                                'N'- Override
                                'Y'- Check
               p_exclude_from_output -
                           This parameter gives the information on
                           whether the record has to be printed or not.
                           'Y'- Do not print.
                           'N'- Print.
              sp_out_1 -  This out parameter returns Employee Location Address
              sp_out_2 -  This out parameter returns Employee Deliver Address
              sp_out_3 -  This out parameter returns Employee City
              sp_out_4 -  This out parameter returns State
              sp_out_5 -  This out parameter returns Zip Code
              sp_out_6 -  This out parameter returns Zip Code Extension
              sp_out_7 -  This out parameter returns Foreign State/Province
              sp_out_8 -  This out parameter returns Foreign Postal Code
              sp_out_9 -  This out parameter returns Foreign Country Code
              sp_out_10 - This parameter is returns  Employee Number
*/

FUNCTION GET_1099R_ITEM_DATA(
                   p_assignment_id        IN  number,
                   p_date_earned          IN  date,
                   p_tax_unit_id          IN  number,
                   p_effective_date       IN  varchar2,
                   p_item_name            IN  varchar2,
                   p_report_type          IN  varchar2,
                   p_format               IN  varchar2,
                   p_report_qualifier     IN  varchar2,
                   p_record_name          IN  varchar2,
                   p_input_1              IN  varchar2,
                   p_input_2              IN  varchar2,
                   p_input_3              IN  varchar2,
                   p_input_4              IN  varchar2,
                   p_input_5              IN  varchar2,
                   p_validate             IN  varchar2,
                   p_exclude_from_output  OUT nocopy varchar2,
                   sp_out_1               OUT nocopy varchar2,
                   sp_out_2               OUT nocopy varchar2,
                   sp_out_3               OUT nocopy varchar2,
                   sp_out_4               OUT nocopy varchar2,
                   sp_out_5               OUT nocopy varchar2,
                   sp_out_6               OUT nocopy varchar2,
                   sp_out_7               OUT nocopy varchar2,
                   sp_out_8               OUT nocopy varchar2,
                   sp_out_9               OUT nocopy varchar2,
                   sp_out_10              OUT nocopy varchar2
                                   ) RETURN VARCHAR2 ;

--
-- Procedure to Format Employee Address
--
PROCEDURE  format_pub1220_address(
                   p_name                 IN  varchar2,
                   p_locality_company_id  IN  varchar2,
                   p_emp_number           IN  varchar2,
                   p_address_line_1       IN  varchar2,
                   p_address_line_2       IN  varchar2,
                   p_address_line_3       IN  varchar2,
                   p_town_or_city         IN  varchar2,
                   p_state                IN  varchar2,
                   p_postal_code          IN  varchar2,
                   p_country              IN  varchar2,
                   p_country_name         IN  varchar2,
                   p_region_1             IN  varchar2,
                   p_region_2             IN  varchar2,
                   p_valid_address        IN  varchar2,
                   p_item_name            IN  varchar2,
                   p_report_type          IN  varchar2,
                   p_record_name          IN  varchar2,
                   p_validate             IN  varchar2,
                   p_local_code           IN  varchar2,
                   p_exclude_from_output  OUT nocopy varchar2,
                   sp_out_1               IN OUT nocopy varchar2,
                   sp_out_2               IN OUT nocopy varchar2,
                   sp_out_3               IN OUT nocopy varchar2,
                   sp_out_4               IN OUT nocopy varchar2,
                   sp_out_5               IN OUT nocopy varchar2,
                   sp_out_6               IN OUT nocopy varchar2,
                   sp_out_7               IN OUT nocopy varchar2,
                   sp_out_8               IN OUT nocopy varchar2,
                   sp_out_9               IN OUT nocopy varchar2,
                   sp_out_10              IN OUT nocopy varchar2 ) ;
--
PROCEDURE  format_1099r_wv_address(
                   p_name                 IN  varchar2,
                   p_locality_company_id  IN  varchar2,
                   p_emp_number           IN  varchar2,
                   p_address_line_1       IN  varchar2,
                   p_address_line_2       IN  varchar2,
                   p_address_line_3       IN  varchar2,
                   p_town_or_city         IN  varchar2,
                   p_state                IN  varchar2,
                   p_postal_code          IN  varchar2,
                   p_country              IN  varchar2,
                   p_country_name         IN  varchar2,
                   p_region_1             IN  varchar2,
                   p_region_2             IN  varchar2,
                   p_valid_address        IN  varchar2,
                   p_item_name            IN  varchar2,
                   p_report_type          IN  varchar2,
                   p_record_name          IN  varchar2,
                   p_validate             IN  varchar2,
                   p_local_code           IN  varchar2,
                   p_exclude_from_output  OUT nocopy varchar2,
                   sp_out_1               IN OUT nocopy varchar2,
                   sp_out_2               IN OUT nocopy varchar2,
                   sp_out_3               IN OUT nocopy varchar2,
                   sp_out_4               IN OUT nocopy varchar2,
                   sp_out_5               IN OUT nocopy varchar2,
                   sp_out_6               IN OUT nocopy varchar2,
                   sp_out_7               IN OUT nocopy varchar2,
                   sp_out_8               IN OUT nocopy varchar2,
                   sp_out_9               IN OUT nocopy varchar2,
                   sp_out_10              IN OUT nocopy varchar2 ) ;
--
FUNCTION Get_1099R_Transmitter_Value(
                   p_payroll_action_id    in varchar2,
                   p_state                in varchar2,
                   sp_out_1               IN OUT nocopy varchar2,
                   sp_out_2               IN OUT nocopy varchar2,
                   sp_out_3               IN OUT nocopy varchar2,
                   sp_out_4               IN OUT nocopy varchar2,
                   sp_out_5               IN OUT nocopy varchar2,
                   sp_out_6               IN OUT nocopy varchar2,
                   sp_out_7               IN OUT nocopy varchar2,
                   sp_out_8               IN OUT nocopy varchar2,
                   sp_out_9               IN OUT nocopy varchar2,
                   sp_out_10              IN OUT nocopy varchar2)
RETURN VARCHAR2;

--
--
END pay_us_1099R_udfs;

/
