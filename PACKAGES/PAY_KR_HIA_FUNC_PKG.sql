--------------------------------------------------------
--  DDL for Package PAY_KR_HIA_FUNC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_HIA_FUNC_PKG" AUTHID CURRENT_USER as
/* $Header: pykrhiafn.pkh 120.0 2005/05/29 10:46:05 appldev noship $ */

    /*************************************************************************
     * This function is used to get the comma-separated concatenation of
     * all business places under a HI Business Place
     *************************************************************************/

    function get_concat_bp_names (
        p_payroll_action_id      in number,
        p_hi_bp_number           in varchar2,
        p_trunc_length           in number
        ) return varchar2;

end pay_kr_hia_func_pkg;

 

/
