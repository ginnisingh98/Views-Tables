--------------------------------------------------------
--  DDL for Package PY_ZA_TAX_CERTIFICATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PY_ZA_TAX_CERTIFICATES" AUTHID CURRENT_USER as
/* $Header: pyzatcer.pkh 120.3.12010000.1 2008/07/28 00:05:39 appldev ship $ */
/*
-- +======================================================================+
-- |       Copyright (c) 1998 Oracle Corporation South Africa Ltd         |
-- |                Cape Town, Western Cape, South Africa                 |
-- |                           All rights reserved.                       |
-- +======================================================================+
-- SQL Script File Name : pyzatcer.pkh
-- Description          : This sql script seeds the py_za_tax_certificates
--                        package for the ZA localisation. This package
--                        is used in the Tax Certificate reports.
--
-- Change List:
-- ------------
--
-- Name           Date        Version Bug     Text
-- -------------- ----------- ------- ------- -----------------------------
-- F.D. Loubser   08-May-2000   110.0         Initial version
--
-- J.N. Louw      24-Aug-2000   115.0         Updated for ZAPatch11i.01
-- F.D. Loubser   11-Sep-2000   115.1         Updated for CBO
-- L. Kloppers    12 Sep 2002   115.2 2224332 Added Function get_sars_code to return correct SARS Code
--                                            in case of a Director or Foreign Income
-- Nageswara      17-Feb-2004   115.3 3396163 commented 'serverout on' - GSCC
   A. Mahanty     18-May-2006   115.5 5231652 the unused procedure get_tax_data
                                              commented out
-- ========================================================================
*/
---------------------------------------------------------------------------
-- Global variables
---------------------------------------------------------------------------
g_assignment_id pay_assignment_actions.assignment_id%type;
g_tax_status    pay_run_result_values.result_value%type;

---------------------------------------------------------------------------
-- This function is used to populate the temporary table for the IRP5 and
-- IT3A reports
-- It returns the sequence number of the temporary values
---------------------------------------------------------------------------
function populate_temporary_table
(
   p_irp5_indicator    in varchar2,
   p_payroll_action_id in varchar2,
   p_employee          in number
)  return number;

---------------------------------------------------------------------------
-- This function is used to indicate whether the Certificate is an IRP5 or
-- an IT3A
---------------------------------------------------------------------------
function irp5_indicator
(
   p_assignment_action_id in number
)  return varchar2;
pragma restrict_references(irp5_indicator, WNDS, WNPS);

---------------------------------------------------------------------------
-- This function is used to retrieve the Tax Status, Tax Directive Number
-- and Tax Directive Value Input Values from the ZA_Tax element
---------------------------------------------------------------------------
/* Bug 5231652
procedure get_tax_data
(
   assignment_id          in     number,
   assignment_action_id   in     number,
   date_earned            in     date,
   p_tax_status           in out nocopy varchar2,
   p_directive_number     in out nocopy varchar2,
   p_directive_value      in out nocopy number,
   p_lump_sum_indicator   in     varchar2
);
*/

function get_sars_code
(
   p_sars_code    in     varchar2,
   p_tax_status   in     varchar2,
   p_nature       in     varchar2
)  return varchar2;


end py_za_tax_certificates;

/
