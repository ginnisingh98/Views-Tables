--------------------------------------------------------
--  DDL for Package PER_ABSENCE_ATTENDANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ABSENCE_ATTENDANCES_PKG" AUTHID CURRENT_USER as
/* $Header: peaba01t.pkh 115.5 2003/08/13 05:31:55 ablinko ship $ */

/*
 Date         Name      Release   Description
|------------|---------|---------|--------------------------------------------|
 07-SEP-1998  JARTHURT  110.1     Added new parameters to the insert, update
                                  and lock routines to deal with a new DFF
 22-DEC-1998  A.MYERS   110.2     Bug 725730: Maternity update changes.
 11-AUG-2003  A.BLINKO  115.4     Bug 2829746: Added default_MPP_start_date
                                  Added parameter to get_due_date_2
|------------|---------|---------|--------------------------------------------|
*/

-- The following variable is set by procedure mpp_update_mode, and controls
-- whether the mpp date is updated or not when an absence change is made.
g_mpp_update_mode boolean := FALSE;
g_mpp_updated_date   date;

PROCEDURE mpp_update_mode(p_update_mode in number);

PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Absence_Attendance_Id         IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Absence_Attendance_Type_Id           NUMBER,
                     X_Abs_Attendance_Reason_Id             NUMBER,
                     X_Person_Id                            NUMBER,
                     X_Authorising_Person_Id                NUMBER,
                     X_Replacement_Person_Id                NUMBER,
                     X_Period_Of_Incapacity_Id              NUMBER,
                     X_Absence_Days                         NUMBER,
                     X_Absence_Hours                        NUMBER,
                     X_Comments                             VARCHAR2,
                     X_Date_End                             DATE,
                     X_Date_Notification                    DATE,
                     X_Date_Projected_End                   DATE,
                     X_Date_Projected_Start                 DATE,
                     X_Date_Start                           DATE,
                     X_Occurrence                           NUMBER,
                     X_Ssp1_Issued                          VARCHAR2,
                     X_Time_End                             VARCHAR2,
                     X_Time_Projected_End                   VARCHAR2,
                     X_Time_Projected_Start                 VARCHAR2,
                     X_Time_Start                           VARCHAR2,
                     X_Attribute_Category                   VARCHAR2,
                     X_Attribute1                           VARCHAR2,
                     X_Attribute2                           VARCHAR2,
                     X_Attribute3                           VARCHAR2,
                     X_Attribute4                           VARCHAR2,
                     X_Attribute5                           VARCHAR2,
                     X_Attribute6                           VARCHAR2,
                     X_Attribute7                           VARCHAR2,
                     X_Attribute8                           VARCHAR2,
                     X_Attribute9                           VARCHAR2,
                     X_Attribute10                          VARCHAR2,
                     X_Attribute11                          VARCHAR2,
                     X_Attribute12                          VARCHAR2,
                     X_Attribute13                          VARCHAR2,
                     X_Attribute14                          VARCHAR2,
                     X_Attribute15                          VARCHAR2,
                     X_Attribute16                          VARCHAR2,
                     X_Attribute17                          VARCHAR2,
                     X_Attribute18                          VARCHAR2,
                     X_Attribute19                          VARCHAR2,
                     X_Attribute20                          VARCHAR2,
                     X_Linked_Absence_id                    NUMBER,
		     X_Sickness_Start_Date                  DATE,
		     X_Sickness_End_Date                    DATE,
		     X_Accept_Late_Notif_Flag               VARCHAR2,
		     X_Reason_For_Late_Notification         VARCHAR2,
		     X_Pregnancy_Related_Illness            VARCHAR2,
		     X_Maternity_Id                         NUMBER,
                     X_Batch_Id                             NUMBER DEFAULT NULL,
                     X_Abs_Information_Category            VARCHAR2,
                     X_Abs_Information1                    VARCHAR2,
                     X_Abs_Information2                    VARCHAR2,
                     X_Abs_Information3                    VARCHAR2,
                     X_Abs_Information4                    VARCHAR2,
                     X_Abs_Information5                    VARCHAR2,
                     X_Abs_Information6                    VARCHAR2,
                     X_Abs_Information7                    VARCHAR2,
                     X_Abs_Information8                    VARCHAR2,
                     X_Abs_Information9                    VARCHAR2,
                     X_Abs_Information10                   VARCHAR2,
                     X_Abs_Information11                   VARCHAR2,
                     X_Abs_Information12                   VARCHAR2,
                     X_Abs_Information13                   VARCHAR2,
                     X_Abs_Information14                   VARCHAR2,
                     X_Abs_Information15                   VARCHAR2,
                     X_Abs_Information16                   VARCHAR2,
                     X_Abs_Information17                   VARCHAR2,
                     X_Abs_Information18                   VARCHAR2,
                     X_Abs_Information19                   VARCHAR2,
                     X_Abs_Information20                   VARCHAR2,
                     X_Abs_Information21                   VARCHAR2,
                     X_Abs_Information22                   VARCHAR2,
                     X_Abs_Information23                   VARCHAR2,
                     X_Abs_Information24                   VARCHAR2,
                     X_Abs_Information25                   VARCHAR2,
                     X_Abs_Information26                   VARCHAR2,
                     X_Abs_Information27                   VARCHAR2,
                     X_Abs_Information28                   VARCHAR2,
                     X_Abs_Information29                   VARCHAR2,
                     X_Abs_Information30                   VARCHAR2) ;

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Absence_Attendance_Id                  NUMBER,
                   X_Business_Group_Id                      NUMBER,
                   X_Absence_Attendance_Type_Id             NUMBER,
                   X_Abs_Attendance_Reason_Id               NUMBER,
                   X_Person_Id                              NUMBER,
                   X_Authorising_Person_Id                  NUMBER,
                   X_Replacement_Person_Id                  NUMBER,
                   X_Period_Of_Incapacity_Id                NUMBER,
                   X_Absence_Days                           NUMBER,
                   X_Absence_Hours                          NUMBER,
                   X_Comments                               VARCHAR2,
                   X_Date_End                               DATE,
                   X_Date_Notification                      DATE,
                   X_Date_Projected_End                     DATE,
                   X_Date_Projected_Start                   DATE,
                   X_Date_Start                             DATE,
                   X_Occurrence                             NUMBER,
                   X_Ssp1_Issued                            VARCHAR2,
                   X_Time_End                               VARCHAR2,
                   X_Time_Projected_End                     VARCHAR2,
                   X_Time_Projected_Start                   VARCHAR2,
                   X_Time_Start                             VARCHAR2,
                   X_Attribute_Category                     VARCHAR2,
                   X_Attribute1                             VARCHAR2,
                   X_Attribute2                             VARCHAR2,
                   X_Attribute3                             VARCHAR2,
                   X_Attribute4                             VARCHAR2,
                   X_Attribute5                             VARCHAR2,
                   X_Attribute6                             VARCHAR2,
                   X_Attribute7                             VARCHAR2,
                   X_Attribute8                             VARCHAR2,
                   X_Attribute9                             VARCHAR2,
                   X_Attribute10                            VARCHAR2,
                   X_Attribute11                            VARCHAR2,
                   X_Attribute12                            VARCHAR2,
                   X_Attribute13                            VARCHAR2,
                   X_Attribute14                            VARCHAR2,
                   X_Attribute15                            VARCHAR2,
                   X_Attribute16                            VARCHAR2,
                   X_Attribute17                            VARCHAR2,
                   X_Attribute18                            VARCHAR2,
                   X_Attribute19                            VARCHAR2,
                   X_Attribute20                            VARCHAR2,
                     X_Linked_Absence_id                    NUMBER,
		     X_Sickness_Start_Date                  DATE,
		     X_Sickness_End_Date                    DATE,
		     X_Accept_Late_Notif_Flag               VARCHAR2,
		     X_Reason_For_Late_Notification         VARCHAR2,
		     X_Pregnancy_Related_Illness            VARCHAR2,
		     X_Maternity_Id                         NUMBER,
                     X_Abs_Information_Category            VARCHAR2,
                     X_Abs_Information1                    VARCHAR2,
                     X_Abs_Information2                    VARCHAR2,
                     X_Abs_Information3                    VARCHAR2,
                     X_Abs_Information4                    VARCHAR2,
                     X_Abs_Information5                    VARCHAR2,
                     X_Abs_Information6                    VARCHAR2,
                     X_Abs_Information7                    VARCHAR2,
                     X_Abs_Information8                    VARCHAR2,
                     X_Abs_Information9                    VARCHAR2,
                     X_Abs_Information10                   VARCHAR2,
                     X_Abs_Information11                   VARCHAR2,
                     X_Abs_Information12                   VARCHAR2,
                     X_Abs_Information13                   VARCHAR2,
                     X_Abs_Information14                   VARCHAR2,
                     X_Abs_Information15                   VARCHAR2,
                     X_Abs_Information16                   VARCHAR2,
                     X_Abs_Information17                   VARCHAR2,
                     X_Abs_Information18                   VARCHAR2,
                     X_Abs_Information19                   VARCHAR2,
                     X_Abs_Information20                   VARCHAR2,
                     X_Abs_Information21                   VARCHAR2,
                     X_Abs_Information22                   VARCHAR2,
                     X_Abs_Information23                   VARCHAR2,
                     X_Abs_Information24                   VARCHAR2,
                     X_Abs_Information25                   VARCHAR2,
                     X_Abs_Information26                   VARCHAR2,
                     X_Abs_Information27                   VARCHAR2,
                     X_Abs_Information28                   VARCHAR2,
                     X_Abs_Information29                   VARCHAR2,
                     X_Abs_Information30                   VARCHAR2);

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Absence_Attendance_Id               NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Absence_Attendance_Type_Id          NUMBER,
                     X_Abs_Attendance_Reason_Id            NUMBER,
                     X_Person_Id                           NUMBER,
                     X_Authorising_Person_Id               NUMBER,
                     X_Replacement_Person_Id               NUMBER,
                     X_Period_Of_Incapacity_Id             NUMBER,
                     X_Absence_Days                        NUMBER,
                     X_Absence_Hours                       NUMBER,
                     X_Comments                            VARCHAR2,
                     X_Date_End                            DATE,
                     X_Date_Notification                   DATE,
                     X_Date_Projected_End                  DATE,
                     X_Date_Projected_Start                DATE,
                     X_Date_Start                          DATE,
                     X_Occurrence                          NUMBER,
                     X_Ssp1_Issued                         VARCHAR2,
                     X_Time_End                            VARCHAR2,
                     X_Time_Projected_End                  VARCHAR2,
                     X_Time_Projected_Start                VARCHAR2,
                     X_Time_Start                          VARCHAR2,
                     X_Attribute_Category                  VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Attribute16                         VARCHAR2,
                     X_Attribute17                         VARCHAR2,
                     X_Attribute18                         VARCHAR2,
                     X_Attribute19                         VARCHAR2,
                     X_Attribute20                         VARCHAR2,
                     X_Linked_Absence_id                    NUMBER,
		     X_Sickness_Start_Date                  DATE,
		     X_Sickness_End_Date                    DATE,
		     X_Accept_Late_Notif_Flag               VARCHAR2,
		     X_Reason_For_Late_Notification         VARCHAR2,
		     X_Pregnancy_Related_Illness            VARCHAR2,
		     X_Maternity_Id                         NUMBER,
                     X_Abs_Information_Category            VARCHAR2,
                     X_Abs_Information1                    VARCHAR2,
                     X_Abs_Information2                    VARCHAR2,
                     X_Abs_Information3                    VARCHAR2,
                     X_Abs_Information4                    VARCHAR2,
                     X_Abs_Information5                    VARCHAR2,
                     X_Abs_Information6                    VARCHAR2,
                     X_Abs_Information7                    VARCHAR2,
                     X_Abs_Information8                    VARCHAR2,
                     X_Abs_Information9                    VARCHAR2,
                     X_Abs_Information10                   VARCHAR2,
                     X_Abs_Information11                   VARCHAR2,
                     X_Abs_Information12                   VARCHAR2,
                     X_Abs_Information13                   VARCHAR2,
                     X_Abs_Information14                   VARCHAR2,
                     X_Abs_Information15                   VARCHAR2,
                     X_Abs_Information16                   VARCHAR2,
                     X_Abs_Information17                   VARCHAR2,
                     X_Abs_Information18                   VARCHAR2,
                     X_Abs_Information19                   VARCHAR2,
                     X_Abs_Information20                   VARCHAR2,
                     X_Abs_Information21                   VARCHAR2,
                     X_Abs_Information22                   VARCHAR2,
                     X_Abs_Information23                   VARCHAR2,
                     X_Abs_Information24                   VARCHAR2,
                     X_Abs_Information25                   VARCHAR2,
                     X_Abs_Information26                   VARCHAR2,
                     X_Abs_Information27                   VARCHAR2,
                     X_Abs_Information28                   VARCHAR2,
                     X_Abs_Information29                   VARCHAR2,
                     X_Abs_Information30                   VARCHAR2);

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

PROCEDURE Delete_Row(X_Rowid VARCHAR2, p_maternity_id in number);

procedure b_check_auth_de(p_date_start IN DATE,
                          p_proj_start IN DATE,
			  p_date_end IN DATE,
			  p_proj_end IN DATE,
                          p_sess In DATE,
                          p_auth_id IN NUMBER);

procedure b_check_rep_de(p_date_start In DATE,
                         p_date_proj_start IN DATE,
			 p_date_end IN DATE,
			 p_date_proj_end IN DATE,
                         p_sess IN DATE,
                         p_rep_id IN NUMBER);

function check_for_term(p_date IN DATE,
                        p_rep_per IN NUMBER) RETURN BOOLEAN;

function chk_rep_req(p_psn_id IN NUMBER,
                     p_dstart IN DATE,
                     p_proj_start IN DATE,
                     p_sess IN DATE) RETURN BOOLEAN;

procedure chk_type(p_abat_type In NUMBER,
                   p_dstart IN DATE,
                   p_eot IN DATE,
                   p_dend IN DATE,
                   p_abs_from IN DATE,
                   p_abs_to IN DATE);

procedure chk_proj(p_abat_type IN NUMBER,
                   p_proj_start IN DATE,
                   p_eot IN DATE,
                   p_proj_end IN DATE);

function chkab1(p_abat_id IN NUMBER,
                p_per_id IN NUMBER,
                p_abat_type In NUMBER,
                p_dstart IN DATE) RETURN BOOLEAN;

procedure chkab2(p_abat_id IN NUMBER,
                 p_per_id IN NUMBER,
                 p_abat_type IN NUMBER,
                 p_dstart IN DATE,
                 p_dend IN DATE,
                 p_eot IN DATE);

function chkab3(p_abat_id IN NUMBER,
                p_per_id IN NUMBER,
                p_abat_type IN NUMBER,
                p_dstart IN DATE,
                p_dend In DATE,
                p_eot IN DATE) RETURN BOOLEAN;

procedure b_elmnt_entry_dets(p_per_id IN NUMBER,
                             p_sdstart IN DATE,
                             p_abat_id IN NUMBER,
                             p_e_entry_id IN OUT NOCOPY NUMBER,
                             p_e_link_id IN OUT NOCOPY NUMBER,
                             p_cpay_id IN OUT NOCOPY NUMBER,
                             p_period_sdate IN OUT NOCOPY DATE,
                             p_period_edate IN OUT NOCOPY DATE);

procedure b_get_category(p_mean IN OUT NOCOPY VARCHAR2,
			 p_abcat IN VARCHAR2);

procedure get_defaults(p_tend IN VARCHAR2,
                       p_tstart IN VARCHAR2,
                       p_dend IN DATE,
                       p_dstart IN DATE,
                       p_hrs_def IN OUT NOCOPY NUMBER,
                       p_dys_hrs IN OUT NOCOPY NUMBER,
                       p_dys_def IN OUT NOCOPY NUMBER);

procedure get_ele_det1(p_bgroup_id IN NUMBER,
                       p_eltype IN NUMBER,
                       p_per_id IN NUMBER,
                       p_dstart IN DATE,
                       p_sess IN DATE,
                       p_ass_id IN OUT NOCOPY NUMBER,
                       p_ele_link IN OUT NOCOPY NUMBER,
                       p_pay_id IN OUT NOCOPY NUMBER,
                       p_test IN OUT NOCOPY VARCHAR2);

procedure get_ele_det2(p_eletype IN NUMBER,
                        p_abat_type IN NUMBER,
                        p_dstart IN DATE,
                        p_dele_name IN OUT NOCOPY VARCHAR2);

procedure get_period_dates(p_cpay_id IN NUMBER,
                           p_dstart In DATE,
                           p_prd_start IN OUT NOCOPY DATE,
                           p_prd_end IN OUT NOCOPY DATE,
                           p_test IN OUT NOCOPY VARCHAR2);

procedure get_run_tot(p_abat_type IN NUMBER,
                      p_per_id IN NUMBER,
                      p_db_itm IN OUT NOCOPY VARCHAR2,
                      p_ass_id IN OUT NOCOPY NUMBER);

function get_annual_balance(p_session_date IN DATE,
			p_abs_type_id  IN NUMBER,
                        p_ass_id IN  NUMBER)return NUMBER;

function is_emp_entitled (p_abs_att_type_id 	 	 NUMBER,
			      p_ass_id 			 NUMBER,
			      p_calculation_date	 DATE,
			      p_days_requested		 NUMBER,
                              p_hours_requested		 NUMBER)
                                                         return boolean;

procedure init_form(p_form_type IN OUT NOCOPY NUMBER,
                    p_per_id IN NUMBER,
                    p_sess IN DATE,
                    p_dstart IN OUT NOCOPY DATE,
                    p_dend IN OUT NOCOPY DATE);

procedure ins_ok(p_per_id IN NUMBER,
                 p_test IN OUT NOCOPY VARCHAR2);

procedure get_occur(p_bgroup_id IN NUMBER,
                    p_abat_type IN NUMBER,
                    p_per_id IN NUMBER,
                    p_occur IN OUT NOCOPY NUMBER);

function chk_serv_period(p_per_id in number,
			 p_curr_date_end in date,
			 p_proj_start in date) RETURN BOOLEAN;

procedure reset_MPP_start_date_on_delete
(
p_maternity_id            in number
);

procedure get_mat_details
(
p_maternity_id            in number,
p_due_date                in out nocopy date,
p_mpp_start_date          in out nocopy date,
p_earliest_abs_start_date in out nocopy date,
p_earliest_abs_rowid      in out nocopy varchar2,
p_nos_absences            in out nocopy number
);

Function get_due_date (p_maternity_id in number) return date;

Procedure check_val_abs_start (p_date_start in date,
			       p_maternity_id in number);

Procedure check_related_maternity (p_person_id in number);

Procedure check_evd_before_del(p_absence_attendance_id in number,
                               p_medical_type in varchar2);

Function late_abs_notification (p_date_notification in date,
				p_date_start in date,
				p_effective_date in date,
				p_element_name in varchar2) return
				boolean;

Function get_due_date_2 (p_person_id in number,
                         p_leave_type in varchar2,
			 p_smp_due_date in out nocopy date) return BOOLEAN;

Procedure default_MPP_start_date (p_maternity_id     IN NUMBER,
                                  p_start_date       IN DATE,
                                  p_end_date         IN DATE);
--
end PER_ABSENCE_ATTENDANCES_PKG;

 

/
