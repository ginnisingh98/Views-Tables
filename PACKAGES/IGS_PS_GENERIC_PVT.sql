--------------------------------------------------------
--  DDL for Package IGS_PS_GENERIC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_GENERIC_PVT" AUTHID CURRENT_USER AS
/* $Header: IGSPS90S.pls 120.1 2005/09/08 14:44:51 appldev noship $ */


/***********************************************************************************************
Created By:         Sanjeeb Rakshit
Date Created By:    25-May-2005
Purpose:            A private API to import data from external system to OSS is declared along with
                    several PL-SQL table types to be used in the API.
Known limitations,enhancements,remarks:

Change History

Who         When           What

***********************************************************************************************/


PROCEDURE psp_import (
p_api_version			IN           NUMBER,
p_init_msg_list			IN           VARCHAR2 DEFAULT FND_API.G_FALSE,
p_commit			IN           VARCHAR2 DEFAULT FND_API.G_FALSE,
p_validation_level		IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
x_return_status			OUT NOCOPY   VARCHAR2,
x_msg_count			OUT NOCOPY   NUMBER,
x_msg_data			OUT NOCOPY   VARCHAR2,
p_calling_context		IN VARCHAR2,
p_usec_tbl			IN OUT NOCOPY igs_ps_generic_pub.usec_tbl_type,
p_usec_gs_tbl			IN OUT NOCOPY igs_ps_generic_pub.usec_gs_tbl_type,
p_uso_tbl			IN OUT NOCOPY igs_ps_generic_pub.uso_tbl_type,
p_unit_ref_tbl			IN OUT NOCOPY igs_ps_generic_pub.unit_ref_tbl_type,
p_uso_ins_tbl			IN OUT NOCOPY igs_ps_generic_pub.uso_ins_tbl_type,
p_usec_occurs_facility_tbl	IN OUT NOCOPY igs_ps_generic_pub.usec_occurs_facility_tbl_type,
p_usec_teach_resp_ovrd_tbl	IN OUT NOCOPY igs_ps_generic_pub.usec_teach_resp_ovrd_tbl_type,
p_usec_notes_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_notes_tbl_type,
p_usec_assmnt_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_assmnt_tbl_type,
p_usec_plus_hr_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_plus_hr_tbl_type,
p_usec_cat_tbl			IN OUT NOCOPY igs_ps_generic_pub.usec_cat_tbl_type,
p_usec_rule_tbl			IN OUT NOCOPY igs_ps_generic_pub.usec_rule_tbl_type,
p_usec_cross_group_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_cross_group_tbl_type,
p_usec_meet_with_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_meet_with_tbl_type,
p_usec_waitlist_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_waitlist_tbl_type,
p_usec_res_seat_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_res_seat_tbl_type,
p_usec_sp_fee_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_sp_fee_tbl_type,
p_usec_ret_tbl			IN OUT NOCOPY igs_ps_generic_pub.usec_ret_tbl_type,
p_usec_ret_dtl_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_ret_dtl_tbl_type,
p_usec_enr_dead_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_enr_dead_tbl_type,
p_usec_enr_dis_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_enr_dis_tbl_type,
p_usec_teach_resp_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_teach_resp_tbl_type,
P_usec_ass_item_grp_tbl		IN OUT NOCOPY igs_ps_generic_pub.usec_ass_item_grp_tbl_type,
p_usec_status			OUT NOCOPY VARCHAR2,
p_usec_gs_status		OUT NOCOPY VARCHAR2,
p_uso_status			OUT NOCOPY VARCHAR2,
p_uso_ins_status		OUT NOCOPY VARCHAR2,
p_uso_facility_status		OUT NOCOPY VARCHAR2,
p_unit_ref_status		OUT NOCOPY VARCHAR2,
p_usec_teach_resp_ovrd_status	OUT NOCOPY VARCHAR2,
p_usec_notes_status		OUT NOCOPY VARCHAR2,
p_usec_assmnt_status		OUT NOCOPY VARCHAR2,
p_usec_plus_hr_status		OUT NOCOPY VARCHAR2,
p_usec_cat_status		OUT NOCOPY VARCHAR2,
p_usec_rule_status		OUT NOCOPY VARCHAR2,
p_usec_cross_group_status	OUT NOCOPY VARCHAR2,
p_usec_meet_with_status		OUT NOCOPY VARCHAR2,
p_usec_waitlist_status		OUT NOCOPY VARCHAR2,
p_usec_res_seat_status		OUT NOCOPY VARCHAR2,
p_usec_sp_fee_status		OUT NOCOPY VARCHAR2,
p_usec_ret_status		OUT NOCOPY VARCHAR2,
p_usec_ret_dtl_status		OUT NOCOPY VARCHAR2,
p_usec_enr_dead_status		OUT NOCOPY VARCHAR2,
p_usec_enr_dis_status		OUT NOCOPY VARCHAR2,
p_usec_teach_resp_status	OUT NOCOPY VARCHAR2,
P_usec_ass_item_grp_status	OUT NOCOPY VARCHAR2 ) ;


END igs_ps_generic_pvt;

 

/
