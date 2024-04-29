--------------------------------------------------------
--  DDL for Package PAY_AU_TAX_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_TAX_INFO_PKG" AUTHID CURRENT_USER as
/* $Header: pyautinf.pkh 120.0.12010000.1 2008/10/16 07:47:42 keyazawa noship $ */
--
procedure set_eev_upd_mode(
  p_assignment_id  in number,
  p_session_date   in date,
  p_scl_upd_mode   in varchar2,
  p_scl_upd_esd    in date,
  p_eev_upd_esd    in date,
  p_update_mode    out nocopy varchar2,
  p_effective_date out nocopy date,
  p_warning        out nocopy varchar2);
--
end pay_au_tax_info_pkg;

/
