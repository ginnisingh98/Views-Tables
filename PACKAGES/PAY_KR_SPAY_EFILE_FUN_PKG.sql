--------------------------------------------------------
--  DDL for Package PAY_KR_SPAY_EFILE_FUN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_SPAY_EFILE_FUN_PKG" AUTHID CURRENT_USER as
/* $Header: pykrspen.pkh 120.1.12010000.2 2010/02/26 03:38:16 pnethaga ship $ */

level_cnt number;

   FUNCTION get_prev_emp_count (
      p_assignment_action_id IN NUMBER
   )
      RETURN NUMBER;
---------------------------------------------
    function get_sep_pay_amount (
        p_assact      in number,
        p_amount      in number
    ) return number;
    -- Bug 9409509
     function get_nsep_pay_amount (
        p_assact      in number,
        p_amount      in number
    ) return number;
     function get_archive_item( p_assact in number) return varchar2;
    -- End of Bug 9409509
end pay_kr_spay_efile_fun_pkg;

/
