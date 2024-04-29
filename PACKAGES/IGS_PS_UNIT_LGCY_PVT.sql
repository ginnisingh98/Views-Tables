--------------------------------------------------------
--  DDL for Package IGS_PS_UNIT_LGCY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_UNIT_LGCY_PVT" AUTHID CURRENT_USER AS
/* $Header: IGSPS93S.pls 120.1 2005/09/08 15:21:54 appldev noship $ */


/***********************************************************************************************
Created By:         Sanjeeb Rakshit
Date Created By:    20-Nov-2002
Purpose:            A public API to import data from external system to OSS is declared along with
                    several PL-SQL table types to be used in the API.
Known limitations,enhancements,remarks:

Change History

Who         When           What
smvk        28-Jul-2004    Bug # 3793580. Allowing the user to import instructors for No Set Day USO.
                           Added column no_set_day_ind to uso_ins_rec_type record type.
sarakshi    04-May-2004    Enh#3568858,Added columns ovrd_wkld_val_flag, workload_val_code to the unit record type
sarakshi    10-Nov-2003    Enh#3116171, added logic related to the newly introduced field BILLING_CREDIT_POINTS in unit_ver_rec_type and usec_rec_type
sarakshi    02-sep-2003    Enh#3052452,Removed the reference of the column sup_unit_allowed_ind and sub_unit_allowed_ind.
                           Modified unit section record type(usec_rec_type) to add new columns sup_unit_cd,sup_version_number,
			   sup_teach_cal_alternate_code,sup_location_cd,sup_unit_class,default_enroll_flag
vvutukur    05-Aug-2003    Enh#3045069.PSP Enh Build. Modified unit section record type(usec_rec_type) to add
                           new column not_multiple_section_flag.
sarakshi    28-Jun-2003    Enh#2930935, added fields achievable and enrolled credit points to usec_rec_type
smvk        26-Jun-2003    Bug #  2999888. Added gen_ref_flag in the unit_ref_rec_type record type.
jbegum      02-june-2003   Bug # 2972950.
                           As mentioned in Legacy Enhancements TD:
                           Added an in out paramter p_uso_ins_tbl, defined record / table
                           structure uso_ins_rec_type / uso_ins_tbl_type and Added eight attribute to record structure usec_rec_type.
                           As mentioned in the PSP Scheduling Enhancements TD:
                           Added fields no_set_day_ind and preferred_region_code in the record structure of uso_rec_type.
                           Added fields uso_start_date,uso_end_date and no_set_day_ind in the record structure of unit_ref_rec_type

***********************************************************************************************/



PROCEDURE create_unit(
             p_api_version           IN            NUMBER,
             p_init_msg_list         IN            VARCHAR2 DEFAULT FND_API.G_FALSE,
             p_commit                IN            VARCHAR2 DEFAULT FND_API.G_FALSE,
             p_validation_level      IN            NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
             x_return_status         OUT NOCOPY    VARCHAR2,
             x_msg_count             OUT NOCOPY    NUMBER,
             x_msg_data              OUT NOCOPY    VARCHAR2,
             p_unit_ver_rec          IN OUT NOCOPY igs_ps_generic_pub.unit_ver_rec_type,
             p_unit_tr_tbl           IN OUT NOCOPY igs_ps_generic_pub.unit_tr_tbl_type,
             p_unit_dscp_tbl         IN OUT NOCOPY igs_ps_generic_pub.unit_dscp_tbl_type,
             p_unit_gs_tbl           IN OUT NOCOPY igs_ps_generic_pub.unit_gs_tbl_type,
             p_usec_tbl              IN OUT NOCOPY igs_ps_generic_pub.usec_tbl_type,
             p_usec_gs_tbl           IN OUT NOCOPY igs_ps_generic_pub.usec_gs_tbl_type,
             p_uso_tbl               IN OUT NOCOPY igs_ps_generic_pub.uso_tbl_type,
             p_unit_ref_tbl          IN OUT NOCOPY igs_ps_generic_pub.unit_ref_tbl_type,
             p_uso_ins_tbl           IN OUT NOCOPY igs_ps_generic_pub.uso_ins_tbl_type
             );


END igs_ps_unit_lgcy_pvt;

 

/
