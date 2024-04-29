--------------------------------------------------------
--  DDL for Package SSPWSMAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."SSPWSMAT_PKG" AUTHID CURRENT_USER as
/* $Header: sspwsmat.pkh 120.1 2005/06/15 04:09:03 tukumar noship $ */

 procedure calculate_smp_form_fields
 (
  p_due_date            in date,
  p_ewc                 in out NOCOPY date,
  p_earliest_mpp_start  in out NOCOPY date,
  p_qw                  in out NOCOPY date,
  p_cont_emp_start_date in out NOCOPY date
 );

  procedure calculate_sap_form_fields
 (
  p_due_date            in date,
  p_matching_date       in date,
  p_earliest_mpp_start  in out NOCOPY date,
  p_qw                  in out NOCOPY date,
  p_cont_emp_start_date in out NOCOPY date
 );

  procedure calculate_pab_form_fields
 (
  p_due_date            in date,
  p_ewc                 in out NOCOPY date,
  p_qw                  in out NOCOPY date,
  p_cont_emp_start_date in out NOCOPY date
 );

  procedure calculate_pad_form_fields
 (
  p_matching_date       in date,
  p_qw                  in out NOCOPY date,
  p_cont_emp_start_date in out NOCOPY date
 );

 procedure get_latest_absence_date
 (
  p_maternity_id           in     number,
  p_absence_attendance_id  in out NOCOPY number,
  p_abs_end_date           in out NOCOPY date,
  p_rec_found              in out NOCOPY boolean
 );

procedure upd_abse_end_date
 (
  p_maternity_id in number,
  p_absence_attendance_id in number,
  p_absence_end_date in date
 );

END SSPWSMAT_PKG;

 

/
