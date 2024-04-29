--------------------------------------------------------
--  DDL for Package PYUDET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PYUDET" AUTHID CURRENT_USER as
/* $Header: pyudet.pkh 120.2.12010000.1 2008/07/27 23:46:57 appldev ship $

 Copyright (c) Oracle Corporation 1995. All rights reserved

 Name          : pyudet
 Description   : Start Of Year Process, used to change Tax Basis to
                 Cumlative, clear Previous Tax Paid and Taxable Pay,
                 uplift Tax Codes or read new Tax Codes from tape.
 Author        : Barry Goodsell
 Date Created  : 15-Aug-95
 Uses          : hr_entry_api, hr_utility

 Change List
 -----------
 Date        Name            Vers     Bug No   Description
 +-----------+---------------+--------+--------+-----------------------+
  15-Aug-95   B.Goodsell      40.0              First Created

  19-Sep-95   B.Goodsell      40.1              Debugging

  09-Oct-95   B.Goodsell      40.2              Edits required for
                                                release
  04-Nov-96   R.Thirlby       40.3              Added p_request_id for SOY
                                                Resume functionality
  01-Dec-00   A.Mills         110.2             Added commit.
  12-Sep-01   KThampan        115.3   1988081   Added p_authority parameter to
                                                hold the value of Authority
  23-Jan-03   GButler	      115.5   2709102   Added nocopy qualifier to
  					        out params on run_process.
  					        GSCC fixes.
  18-MAY-05   KThampan        115.6             Added p_p6_request_id to
                                                hold fnd_request id of
                                                the P6/P9 upload process.
  29-OCT-2007 Dinesh C.       115.8  2626560    Change for SOY 08-09.
 +-----------+---------------+--------+--------+-----------------------+
*/
--
 ---------------------------------------------------------------------
 -- NAME                                                            --
 -- pyudet.run_process                                              --
 --                                                                 --
 -- DESCRIPTION                                                     --
 -- The main procedure called from the SRS screen                   --
 ---------------------------------------------------------------------
--
procedure run_process (
   errbuf                       out  nocopy   varchar2,
   retcode                      out  nocopy   varchar2,
   p_request_id                 in      number default null,
   p_mode                       in      number,
   p_effective_date             in      date,
   p_business_group_id          in      number,
   p_payroll_id                 in      number,
   p_authority                  in      varchar2 default null,
   p_p6_request_id              in      number default null,
   p_validate_only              in      VARCHAR2 DEFAULT 'GB_VALIDATE_COMMIT'); /*Added soy 08-09*/
--
end pyudet;

/
