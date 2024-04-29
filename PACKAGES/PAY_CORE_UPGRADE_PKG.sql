--------------------------------------------------------
--  DDL for Package PAY_CORE_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CORE_UPGRADE_PKG" AUTHID CURRENT_USER AS
/* $Header: pycougpk.pkh 120.6.12010000.1 2008/07/27 22:23:48 appldev ship $ */

procedure upg_single_lat_bal_tab (p_person_id in number);
procedure upg_retro_proc_det_frm_ee (p_asg_id in number);
procedure qual_retro_proc_det_frm_ee(p_object_id in            number,
                          p_qualified    out nocopy varchar2
                         );
procedure chk_retro_by_ele_exists(p_exists out nocopy varchar2);
procedure chk_qpay_inclusions_exist (p_qpay_inclusions_exist out nocopy varchar2);
procedure upg_qpay_excl_tab (p_assignment_id in number);
procedure qual_qpay_excl_tab (p_object_id in            number,
                              p_qualified    out nocopy varchar2
                             );
procedure qual_enable_sparse_matrix (p_object_id in            number,
                                  p_qualified    out nocopy varchar2
                                 );
procedure upg_enable_sparse_matrix (p_person_id in number);
procedure qual_sparse_matrix_asg (p_object_id in            number,
                                  p_qualified    out nocopy varchar2
                                 );
procedure upg_sparse_matrix_rrvs (p_assignment_id in number);
procedure qual_latest_bal_pg(p_object_id in            number,
                          p_qualified    out nocopy varchar2
                         );
Procedure upgrade_latest_bal_pg (p_person_id  IN NUMBER);
procedure qual_timedef_baldate (p_object_id in            number,
                                p_qualified    out nocopy varchar2
                               );
procedure upg_timedef_baldate (p_asg_id in number);
procedure qual_remove_appl_alus(p_object_id in            number,
                                p_qualified    out nocopy varchar2
                               );
procedure remove_appl_alus(p_assignment_id in number);
END pay_core_upgrade_pkg;

/
