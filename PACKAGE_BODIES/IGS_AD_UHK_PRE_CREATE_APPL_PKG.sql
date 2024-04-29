--------------------------------------------------------
--  DDL for Package Body IGS_AD_UHK_PRE_CREATE_APPL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_UHK_PRE_CREATE_APPL_PKG" AS
/* $Header: IGSADD3B.pls 120.2 2006/05/24 10:54:10 arvsrini noship $ */

  --
  --  User Hook - which can be customisable by the customer.
  --

  PROCEDURE derive_app_type (
    p_person_id in number,
    p_login_resp in varchar2,
    p_acad_cal_type in varchar2,
    p_acad_cal_seq_number in number,
    p_adm_cal_type in varchar2,
    p_adm_ci_sequence_number in number,
    p_application_type in out nocopy varchar2,
    p_location_code in out nocopy varchar2,
    p_program_type in out nocopy varchar2,
    p_sch_apl_to_id in out nocopy number,
    p_attendance_type in out nocopy varchar2,
    p_attendance_mode in out nocopy varchar2,
    p_oo_attribute_1 in out nocopy varchar2,
    p_oo_attribute_2 in out nocopy varchar2,
    p_oo_attribute_3 in out nocopy varchar2,
    p_oo_attribute_4 in out nocopy varchar2,
    p_oo_attribute_5 in out nocopy varchar2,
    p_oo_attribute_6 in out nocopy varchar2,
    p_oo_attribute_7 in out nocopy varchar2,
    p_oo_attribute_8 in out nocopy varchar2,
    p_oo_attribute_9 in out nocopy varchar2,
    p_oo_attribute_10 in out nocopy varchar2,
    p_citizenship_residency_ind in out nocopy varchar2,
    p_cit_res_attribute_1 in out nocopy varchar2,
    p_cit_res_attribute_2 in out nocopy varchar2,
    p_cit_res_attribute_3 in out nocopy varchar2,
    p_cit_res_attribute_4 in out nocopy varchar2,
    p_cit_res_attribute_5 in out nocopy varchar2,
    p_cit_res_attribute_6 in out nocopy varchar2,
    p_cit_res_attribute_7 in out nocopy varchar2,
    p_cit_res_attribute_8 in out nocopy varchar2,
    p_cit_res_attribute_9 in out nocopy varchar2,
    p_cit_res_attribute_10 in out nocopy varchar2,
    p_state_of_res_type_code in out nocopy varchar2,
    p_dom_attribute_1 in out nocopy varchar2,
    p_dom_attribute_2 in out nocopy varchar2,
    p_dom_attribute_3 in out nocopy varchar2,
    p_dom_attribute_4 in out nocopy varchar2,
    p_dom_attribute_5 in out nocopy varchar2,
    p_dom_attribute_6 in out nocopy varchar2,
    p_dom_attribute_7 in out nocopy varchar2,
    p_dom_attribute_8 in out nocopy varchar2,
    p_dom_attribute_9 in out nocopy varchar2,
    p_dom_attribute_10 in out nocopy varchar2,
    p_gen_attribute_1 in out nocopy varchar2,
    p_gen_attribute_2 in out nocopy varchar2,
    p_gen_attribute_3 in out nocopy varchar2,
    p_gen_attribute_4 in out nocopy varchar2,
    p_gen_attribute_5 in out nocopy varchar2,
    p_gen_attribute_6 in out nocopy varchar2,
    p_gen_attribute_7 in out nocopy varchar2,
    p_gen_attribute_8 in out nocopy varchar2,
    p_gen_attribute_9 in out nocopy varchar2,
    p_gen_attribute_10 in out nocopy varchar2,
    p_gen_attribute_11 in out nocopy varchar2,
    p_gen_attribute_12 in out nocopy varchar2,
    p_gen_attribute_13 in out nocopy varchar2,
    p_gen_attribute_14 in out nocopy varchar2,
    p_gen_attribute_15 in out nocopy varchar2,
    p_gen_attribute_16 in out nocopy varchar2,
    p_gen_attribute_17 in out nocopy varchar2,
    p_gen_attribute_18 in out nocopy varchar2,
    p_gen_attribute_19 in out nocopy varchar2,
    p_gen_attribute_20 in out nocopy varchar2,
    p_entry_status in out nocopy varchar2,
    p_entry_level in out nocopy varchar2,
    p_spcl_gr1 in out nocopy varchar2,
    p_spcl_gr2 in out nocopy varchar2,
    p_apply_for_finaid in out nocopy varchar2,
    p_finaid_apply_date in out nocopy date,
    p_appl_date in out nocopy date,
    p_attribute_category in out nocopy varchar2,
    p_attribute1 in out nocopy varchar2,
    p_attribute2 in out nocopy varchar2,
    p_attribute3 in out nocopy varchar2,
    p_attribute4 in out nocopy varchar2,
    p_attribute5 in out nocopy varchar2,
    p_attribute6 in out nocopy varchar2,
    p_attribute7 in out nocopy varchar2,
    p_attribute8 in out nocopy varchar2,
    p_attribute9 in out nocopy varchar2,
    p_attribute10 in out nocopy varchar2,
    p_attribute11 in out nocopy varchar2,
    p_attribute12 in out nocopy varchar2,
    p_attribute13 in out nocopy varchar2,
    p_attribute14 in out nocopy varchar2,
    p_attribute15 in out nocopy varchar2,
    p_attribute16 in out nocopy varchar2,
    p_attribute17 in out nocopy varchar2,
    p_attribute18 in out nocopy varchar2,
    p_attribute19 in out nocopy varchar2,
    p_attribute20 in out nocopy varchar2,
    p_attribute21 in out nocopy varchar2,
    p_attribute22 in out nocopy varchar2,
    p_attribute23 in out nocopy varchar2,
    p_attribute24 in out nocopy varchar2,
    p_attribute25 in out nocopy varchar2,
    p_attribute26 in out nocopy varchar2,
    p_attribute27 in out nocopy varchar2,
    p_attribute28 in out nocopy varchar2,
    p_attribute29 in out nocopy varchar2,
    p_attribute30 in out nocopy varchar2,
    p_attribute31 in out nocopy varchar2,
    p_attribute32 in out nocopy varchar2,
    p_attribute33 in out nocopy varchar2,
    p_attribute34 in out nocopy varchar2,
    p_attribute35 in out nocopy varchar2,
    p_attribute36 in out nocopy varchar2,
    p_attribute37 in out nocopy varchar2,
    p_attribute38 in out nocopy varchar2,
    p_attribute39 in out nocopy varchar2,
    p_attribute40 in out nocopy varchar2
    )

  --  This procedure would be called from the workflow executed when an Applicant
  --  clicks on continue button in Create Application Page to create an Application.
  --  This procedure would be primally customised for deriving Application Type to create
  --  Unsubmitted Application form the information passed through parameters of this
  --  procedure. There are other parameters which are of in out nocopy type which could be
  --  updated according to the customer needs ( for eg customer might provide values
  --  for Application Instance DFF). The updated value will be used while creating
  --  the Unsubmitted Application.

  --  Who         When            What
  --  Akadam      7/7/2005        Created the procedure

  --
  --  Parameters Description:
  --

  --  p_person_id			                    Applicant Person Identifier
  --  p_login_resp					            Responsibility identifier :- Could be 'ADMIN' for Administrator responsibilities, 'APPLICANT' and 'STUDENT' for respective Self Service Responsibilities.
  --  p_acad_cal_type					        Calendar type relating to the academic period
  --  p_acad_cal_seq_number			            Sequence number which uniquely identifies the academic period calendar instance
  --  p_adm_cal_type					        Calendar type relating to the admission period
  --  p_adm_ci_sequence_number		            Sequence number which uniquely identifies the admission period calendar instance
  --  p_application_type				        Application Type
  --  p_location_code					        Offering Option Location Code
  --  p_program_type					        Institution-defined program type. Program type indicates the type of higher education program
  --  p_sch_apl_to_id					        School Applying To identifier
  --  p_attendance_type				            Offering Option Attendance Type
  --  p_attendance_mode				            Offering Option Attendance Mode
  --  p_oo_attribute_1				            Offering Option custom attribute
  --  p_oo_attribute_2				            Offering Option custom attribute
  --  p_oo_attribute_3				            Offering Option custom attribute
  --  p_oo_attribute_4				            Offering Option custom attribute
  --  p_oo_attribute_5				            Offering Option custom attribute
  --  p_oo_attribute_6				            Offering Option custom attribute
  --  p_oo_attribute_7				            Offering Option custom attribute
  --  p_oo_attribute_8				            Offering Option custom attribute
  --  p_oo_attribute_9				            Offering Option custom attribute
  --  p_oo_attribute_10				            Offering Option custom attribute
  --  p_citizenship_residency_ind		        Citizenship/Residency Indicator
  --  p_cit_res_attribute_1			            Citizenship/Residency custom attribute
  --  p_cit_res_attribute_2			            Citizenship/Residency custom attribute
  --  p_cit_res_attribute_3			            Citizenship/Residency custom attribute
  --  p_cit_res_attribute_4			            Citizenship/Residency custom attribute
  --  p_cit_res_attribute_5			            Citizenship/Residency custom attribute
  --  p_cit_res_attribute_6			            Citizenship/Residency custom attribute
  --  p_cit_res_attribute_7			            Citizenship/Residency custom attribute
  --  p_cit_res_attribute_8			            Citizenship/Residency custom attribute
  --  p_cit_res_attribute_9			            Citizenship/Residency custom attribute
  --  p_cit_res_attribute_10			        Citizenship/Residency custom attribute
  --  p_state_of_res_type_code		            Indicates code for state
  --  p_dom_attribute_1				            Domicile custom attribute
  --  p_dom_attribute_2				            Domicile custom attribute
  --  p_dom_attribute_3				            Domicile custom attribute
  --  p_dom_attribute_4				            Domicile custom attribute
  --  p_dom_attribute_5				            Domicile custom attribute
  --  p_dom_attribute_6				            Domicile custom attribute
  --  p_dom_attribute_7				            Domicile custom attribute
  --  p_dom_attribute_8				            Domicile custom attribute
  --  p_dom_attribute_9				            Domicile custom attribute
  --  p_dom_attribute_10				        Domicile custom attribute
  --  p_gen_attribute_1				            Generic custom attribute
  --  p_gen_attribute_2				            Generic custom attribute
  --  p_gen_attribute_3				            Generic custom attribute
  --  p_gen_attribute_4				            Generic custom attribute
  --  p_gen_attribute_5				            Generic custom attribute
  --  p_gen_attribute_6				            Generic custom attribute
  --  p_gen_attribute_7				            Generic custom attribute
  --  p_gen_attribute_8				            Generic custom attribute
  --  p_gen_attribute_9				            Generic custom attribute
  --  p_gen_attribute_10				        Generic custom attribute
  --  p_gen_attribute_11				        Generic custom attribute
  --  p_gen_attribute_12				        Generic custom attribute
  --  p_gen_attribute_13				        Generic custom attribute
  --  p_gen_attribute_14				        Generic custom attribute
  --  p_gen_attribute_15				        Generic custom attribute
  --  p_gen_attribute_16				        Generic custom attribute
  --  p_gen_attribute_17				        Generic custom attribute
  --  p_gen_attribute_18				        Generic custom attribute
  --  p_gen_attribute_19				        Generic custom attribute
  --  p_gen_attribute_20				        Generic custom attribute
  --  p_entry_status					        Entry Status
  --  p_entry_level					            Entry Level
  --  p_spcl_gr1						        Special Group 1
  --  p_spcl_gr2						        Special Group 2
  --  p_apply_for_finaid				        Apply For Financial Aid Indicator
  --  p_finaid_apply_date				        Financial Aid Apply Date
  --  p_appl_date						        Application Date
  --  p_attribute_category			            Descriptive flex field qualifier.
  --  p_attribute1					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute2					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute3					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute4					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute5					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute6					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute7					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute8					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute9					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute10					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute11					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute12					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute13					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute14					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute15					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute16					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute17					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute18					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute19					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute20					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute21					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute22					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute23					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute24					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute25					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute26					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute27					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute28					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute29					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute30					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute31					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute32					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute33					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute34					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute35					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute36					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute37					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute38					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute39					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute40					            Standard Attribute Column. Meant for descriptive flex field.

  IS
  BEGIN

    -- PUT YOUR CODE HERE
    RETURN ;

  EXCEPTION
    WHEN OTHERS THEN

    FND_MESSAGE.SET_NAME ('IGS','IGS_AD_UH_UNHAND_EXCEPTION');
    FND_MESSAGE.SET_TOKEN ('OBJECTNAME','IGS_AD_UHK_PRE_CREATE_APPL_PKG.DERIVE_APP_TYPE');
    IGS_GE_MSG_STACK.ADD;

    APP_EXCEPTION.RAISE_EXCEPTION;

  END derive_app_type ;

  PROCEDURE derive_app_fee (
    p_person_id in number,
    p_login_resp in varchar2,
    p_acad_cal_type in varchar2,
    p_acad_cal_seq_number in number,
    p_adm_cal_type in varchar2,
    p_adm_ci_sequence_number in number,
    p_application_type in out nocopy varchar2,
    p_application_fee_amount in out nocopy number,
    p_location_code in out nocopy varchar2,
    p_program_type in out nocopy varchar2,
    p_sch_apl_to_id in out nocopy number,
    p_attendance_type in out nocopy varchar2,
    p_attendance_mode in out nocopy varchar2,
    p_oo_attribute_1 in out nocopy varchar2,
    p_oo_attribute_2 in out nocopy varchar2,
    p_oo_attribute_3 in out nocopy varchar2,
    p_oo_attribute_4 in out nocopy varchar2,
    p_oo_attribute_5 in out nocopy varchar2,
    p_oo_attribute_6 in out nocopy varchar2,
    p_oo_attribute_7 in out nocopy varchar2,
    p_oo_attribute_8 in out nocopy varchar2,
    p_oo_attribute_9 in out nocopy varchar2,
    p_oo_attribute_10 in out nocopy varchar2,
    p_citizenship_residency_ind in out nocopy varchar2,
    p_cit_res_attribute_1 in out nocopy varchar2,
    p_cit_res_attribute_2 in out nocopy varchar2,
    p_cit_res_attribute_3 in out nocopy varchar2,
    p_cit_res_attribute_4 in out nocopy varchar2,
    p_cit_res_attribute_5 in out nocopy varchar2,
    p_cit_res_attribute_6 in out nocopy varchar2,
    p_cit_res_attribute_7 in out nocopy varchar2,
    p_cit_res_attribute_8 in out nocopy varchar2,
    p_cit_res_attribute_9 in out nocopy varchar2,
    p_cit_res_attribute_10 in out nocopy varchar2,
    p_state_of_res_type_code in out nocopy varchar2,
    p_dom_attribute_1 in out nocopy varchar2,
    p_dom_attribute_2 in out nocopy varchar2,
    p_dom_attribute_3 in out nocopy varchar2,
    p_dom_attribute_4 in out nocopy varchar2,
    p_dom_attribute_5 in out nocopy varchar2,
    p_dom_attribute_6 in out nocopy varchar2,
    p_dom_attribute_7 in out nocopy varchar2,
    p_dom_attribute_8 in out nocopy varchar2,
    p_dom_attribute_9 in out nocopy varchar2,
    p_dom_attribute_10 in out nocopy varchar2,
    p_gen_attribute_1 in out nocopy varchar2,
    p_gen_attribute_2 in out nocopy varchar2,
    p_gen_attribute_3 in out nocopy varchar2,
    p_gen_attribute_4 in out nocopy varchar2,
    p_gen_attribute_5 in out nocopy varchar2,
    p_gen_attribute_6 in out nocopy varchar2,
    p_gen_attribute_7 in out nocopy varchar2,
    p_gen_attribute_8 in out nocopy varchar2,
    p_gen_attribute_9 in out nocopy varchar2,
    p_gen_attribute_10 in out nocopy varchar2,
    p_gen_attribute_11 in out nocopy varchar2,
    p_gen_attribute_12 in out nocopy varchar2,
    p_gen_attribute_13 in out nocopy varchar2,
    p_gen_attribute_14 in out nocopy varchar2,
    p_gen_attribute_15 in out nocopy varchar2,
    p_gen_attribute_16 in out nocopy varchar2,
    p_gen_attribute_17 in out nocopy varchar2,
    p_gen_attribute_18 in out nocopy varchar2,
    p_gen_attribute_19 in out nocopy varchar2,
    p_gen_attribute_20 in out nocopy varchar2,
    p_entry_status in out nocopy varchar2,
    p_entry_level in out nocopy varchar2,
    p_spcl_gr1 in out nocopy varchar2,
    p_spcl_gr2 in out nocopy varchar2,
    p_apply_for_finaid in out nocopy varchar2,
    p_finaid_apply_date in out nocopy date,
    p_appl_date in out nocopy date,
    p_attribute_category in out nocopy varchar2,
    p_attribute1 in out nocopy varchar2,
    p_attribute2 in out nocopy varchar2,
    p_attribute3 in out nocopy varchar2,
    p_attribute4 in out nocopy varchar2,
    p_attribute5 in out nocopy varchar2,
    p_attribute6 in out nocopy varchar2,
    p_attribute7 in out nocopy varchar2,
    p_attribute8 in out nocopy varchar2,
    p_attribute9 in out nocopy varchar2,
    p_attribute10 in out nocopy varchar2,
    p_attribute11 in out nocopy varchar2,
    p_attribute12 in out nocopy varchar2,
    p_attribute13 in out nocopy varchar2,
    p_attribute14 in out nocopy varchar2,
    p_attribute15 in out nocopy varchar2,
    p_attribute16 in out nocopy varchar2,
    p_attribute17 in out nocopy varchar2,
    p_attribute18 in out nocopy varchar2,
    p_attribute19 in out nocopy varchar2,
    p_attribute20 in out nocopy varchar2,
    p_attribute21 in out nocopy varchar2,
    p_attribute22 in out nocopy varchar2,
    p_attribute23 in out nocopy varchar2,
    p_attribute24 in out nocopy varchar2,
    p_attribute25 in out nocopy varchar2,
    p_attribute26 in out nocopy varchar2,
    p_attribute27 in out nocopy varchar2,
    p_attribute28 in out nocopy varchar2,
    p_attribute29 in out nocopy varchar2,
    p_attribute30 in out nocopy varchar2,
    p_attribute31 in out nocopy varchar2,
    p_attribute32 in out nocopy varchar2,
    p_attribute33 in out nocopy varchar2,
    p_attribute34 in out nocopy varchar2,
    p_attribute35 in out nocopy varchar2,
    p_attribute36 in out nocopy varchar2,
    p_attribute37 in out nocopy varchar2,
    p_attribute38 in out nocopy varchar2,
    p_attribute39 in out nocopy varchar2,
    p_attribute40 in out nocopy varchar2
    )

  --  This procedure would be called from the workflow executed when an Applicant
  --  clicks on continue button in Create Application Page to create an Application.
  --  And this procedure would be called after the 'derive_app_type' User Hook is called.
  --  This procedure would be primally customised for deriving Application Fee Amount
  --  for the Unsubmitted Application to be created after Application Type is derived.
  --  There are other parameters which are of in out nocopy type which could be
  --  updated according to the customer needs ( for eg customer might provide values
  --  for Application Instance DFF). The updated value will be used while creating
  --  the Unsubmitted Application.

  --  Who         When            What
  --  Akadam      7/7/2005        Created the procedure

  --
  --  Parameters Description:
  --

  --  p_person_id			                    Applicant Person Identifier
  --  p_login_resp					            Responsibility identifier :- Could be 'ADMIN' for Administrator responsibilities, 'APPLICANT' and 'STUDENT' for respective Self Service Responsibilities.
  --  p_acad_cal_type					        Calendar type relating to the academic period
  --  p_acad_cal_seq_number			            Sequence number which uniquely identifies the academic period calendar instance
  --  p_adm_cal_type					        Calendar type relating to the admission period
  --  p_adm_ci_sequence_number		            Sequence number which uniquely identifies the admission period calendar instance
  --  p_application_type				        Application Type
  --  p_application_fee_amount                  Application Fee Amount
  --  p_location_code					        Offering Option Location Code
  --  p_program_type					        Institution-defined program type. Program type indicates the type of higher education program
  --  p_sch_apl_to_id					        School Applying To identifier
  --  p_attendance_type				            Offering Option Attendance Type
  --  p_attendance_mode				            Offering Option Attendance Mode
  --  p_oo_attribute_1				            Offering Option custom attribute
  --  p_oo_attribute_2				            Offering Option custom attribute
  --  p_oo_attribute_3				            Offering Option custom attribute
  --  p_oo_attribute_4				            Offering Option custom attribute
  --  p_oo_attribute_5				            Offering Option custom attribute
  --  p_oo_attribute_6				            Offering Option custom attribute
  --  p_oo_attribute_7				            Offering Option custom attribute
  --  p_oo_attribute_8				            Offering Option custom attribute
  --  p_oo_attribute_9				            Offering Option custom attribute
  --  p_oo_attribute_10				            Offering Option custom attribute
  --  p_citizenship_residency_ind		        Citizenship/Residency Indicator
  --  p_cit_res_attribute_1			            Citizenship/Residency custom attribute
  --  p_cit_res_attribute_2			            Citizenship/Residency custom attribute
  --  p_cit_res_attribute_3			            Citizenship/Residency custom attribute
  --  p_cit_res_attribute_4			            Citizenship/Residency custom attribute
  --  p_cit_res_attribute_5			            Citizenship/Residency custom attribute
  --  p_cit_res_attribute_6			            Citizenship/Residency custom attribute
  --  p_cit_res_attribute_7			            Citizenship/Residency custom attribute
  --  p_cit_res_attribute_8			            Citizenship/Residency custom attribute
  --  p_cit_res_attribute_9			            Citizenship/Residency custom attribute
  --  p_cit_res_attribute_10			        Citizenship/Residency custom attribute
  --  p_state_of_res_type_code		            Indicates code for state
  --  p_dom_attribute_1				            Domicile custom attribute
  --  p_dom_attribute_2				            Domicile custom attribute
  --  p_dom_attribute_3				            Domicile custom attribute
  --  p_dom_attribute_4				            Domicile custom attribute
  --  p_dom_attribute_5				            Domicile custom attribute
  --  p_dom_attribute_6				            Domicile custom attribute
  --  p_dom_attribute_7				            Domicile custom attribute
  --  p_dom_attribute_8				            Domicile custom attribute
  --  p_dom_attribute_9				            Domicile custom attribute
  --  p_dom_attribute_10				        Domicile custom attribute
  --  p_gen_attribute_1				            Generic custom attribute
  --  p_gen_attribute_2				            Generic custom attribute
  --  p_gen_attribute_3				            Generic custom attribute
  --  p_gen_attribute_4				            Generic custom attribute
  --  p_gen_attribute_5				            Generic custom attribute
  --  p_gen_attribute_6				            Generic custom attribute
  --  p_gen_attribute_7				            Generic custom attribute
  --  p_gen_attribute_8				            Generic custom attribute
  --  p_gen_attribute_9				            Generic custom attribute
  --  p_gen_attribute_10				        Generic custom attribute
  --  p_gen_attribute_11				        Generic custom attribute
  --  p_gen_attribute_12				        Generic custom attribute
  --  p_gen_attribute_13				        Generic custom attribute
  --  p_gen_attribute_14				        Generic custom attribute
  --  p_gen_attribute_15				        Generic custom attribute
  --  p_gen_attribute_16				        Generic custom attribute
  --  p_gen_attribute_17				        Generic custom attribute
  --  p_gen_attribute_18				        Generic custom attribute
  --  p_gen_attribute_19				        Generic custom attribute
  --  p_gen_attribute_20				        Generic custom attribute
  --  p_entry_status					        Entry Status
  --  p_entry_level					            Entry Level
  --  p_spcl_gr1						        Special Group 1
  --  p_spcl_gr2						        Special Group 2
  --  p_apply_for_finaid				        Apply For Financial Aid Indicator
  --  p_finaid_apply_date				        Financial Aid Apply Date
  --  p_appl_date						        Application Date
  --  p_attribute_category			            Descriptive flex field qualifier.
  --  p_attribute1					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute2					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute3					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute4					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute5					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute6					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute7					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute8					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute9					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute10					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute11					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute12					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute13					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute14					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute15					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute16					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute17					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute18					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute19					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute20					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute21					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute22					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute23					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute24					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute25					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute26					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute27					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute28					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute29					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute30					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute31					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute32					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute33					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute34					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute35					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute36					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute37					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute38					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute39					            Standard Attribute Column. Meant for descriptive flex field.
  --  p_attribute40					            Standard Attribute Column. Meant for descriptive flex field.

  IS

  BEGIN

    -- PUT YOUR CODE HERE
    RETURN ;

  EXCEPTION
    WHEN OTHERS THEN

    FND_MESSAGE.SET_NAME ('IGS','IGS_AD_UH_UNHAND_EXCEPTION');
    FND_MESSAGE.SET_TOKEN ('OBJECTNAME','IGS_AD_UHK_PRE_CREATE_APPL_PKG.DERIVE_APP_FEE');
    IGS_GE_MSG_STACK.ADD;

    APP_EXCEPTION.RAISE_EXCEPTION;

  END derive_app_fee;

  PROCEDURE pre_submit_application (
      p_person_id       in   number,
      p_ss_adm_appl_id  in   number,
      p_return_status   in out nocopy   varchar2,
      p_msg_data        out   nocopy varchar2
   )

  --  This procedure would be called from function subcription attached to the
  --  Business Event (B.E) 'oracle.apps.igs.ad.pre_submit_application'. This B.E
  --  is raised when Submit Application button is clicked in Checklist Page. The B.E
  --  would be raised before Unsubmitted Application is transfered from staging tables
  --  to Core Tables. So This procedure could be used to validate the Application Data or
  --  insert any additional information like Fee Records through Public API's before
  --  Unsubmitted Application is transfered from staging tables to Core Tables.
  --  User has to set p_msg_data with appropriate error message text for any custom
  --  validation failures.

  --  Who         When            What
  --  Akadam      02/5/2005        Created the procedure

  --
  --  Parameters Description:
  --

  --  p_person_id	           Applicant Person Identifier
  --  p_ss_adm_appl_id		   Admission Application Identifier
  --  p_return_status 		   Return Status this should set to following values depending upon
  --                           the execution of the User Hook.
  --                               Error  -->  p_return_status := 'E';
  --                               Unexpected Error -->  p_return_status := 'U';
  --                               Success  -->  p_return_status := 'S';
  --  p_msg_data      		   Appropriate error message text for any Custom Validation Failures.

  IS

  BEGIN

    -- PUT YOUR CODE HERE
    RETURN ;

  EXCEPTION
    WHEN OTHERS THEN

    FND_MESSAGE.SET_NAME ('IGS','IGS_AD_UH_UNHAND_EXCEPTION');
    FND_MESSAGE.SET_TOKEN ('OBJECTNAME','IGS_AD_UHK_PRE_CREATE_APPL_PKG.PRE_SUBMIT_APPLICATION');
    IGS_GE_MSG_STACK.ADD;

    APP_EXCEPTION.RAISE_EXCEPTION;

  END pre_submit_application;


END igs_ad_uhk_pre_create_appl_pkg;

/
