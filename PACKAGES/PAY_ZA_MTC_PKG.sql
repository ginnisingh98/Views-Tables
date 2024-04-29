--------------------------------------------------------
--  DDL for Package PAY_ZA_MTC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ZA_MTC_PKG" AUTHID CURRENT_USER as
/* $Header: pyzamtc.pkh 120.2.12010000.2 2009/11/19 06:45:44 rbabla ship $ */

------------------------------------------------------------------------------
-- NAME
--   update_certificate_number
-- PURPOSE
--   Issues manual Tax Certificate Numbers
-- ARGUMENTS
--   p_errmsg         - returned error message
--   p_errcode        - returned error code
--   p_asg_action_id  - the assignment action id to process
--   p_tax_cert_no    - the tax certificate number used in update
--   p_asg_id         - the assignment id to process
-- NOTES
--
------------------------------------------------------------------------------

Procedure update_certificate_number
          (
           p_errmsg        out nocopy varchar2,
           p_errcode       out nocopy varchar2,
           p_bgid          in  number,
           p_payroll_id    in  number,
           p_tax_year      in  varchar2,
           p_pay_action_id in  varchar2,
           p_asg_id        in  number,
           p_asg_action_id in  number,
           p_tax_cert_no   in  varchar2
          );

Procedure upd_certificate_num_EOY2010
          (
           p_errmsg            out nocopy varchar2,
           p_errcode           out nocopy varchar2,
           p_bgid              in  number,
           p_legal_entity_id   in  number,
           p_tax_year          in  varchar2,
           p_payroll           in  number,
           p_pay_action_id     in  number,
           p_asg_id            in  number,
           p_temp_cert_no      in  varchar2,
           p_tax_cert_no       in  varchar2
          );

End pay_za_mtc_pkg;

/
