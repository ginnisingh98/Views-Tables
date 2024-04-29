--------------------------------------------------------
--  DDL for Package Body IGS_PS_GENERIC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_GENERIC_PUB" AS
/* $Header: IGSPS89B.pls 120.1 2005/09/08 15:53:18 appldev noship $ */


G_PKG_NAME     CONSTANT VARCHAR2(30) := 'igs_ps_generic_pub';

PROCEDURE psp_import (
p_api_version			      IN           NUMBER,
p_init_msg_list			      IN           VARCHAR2 ,
p_commit			      IN           VARCHAR2 ,
p_validation_level		      IN           NUMBER,
x_return_status			      OUT NOCOPY   VARCHAR2,
x_msg_count			      OUT NOCOPY   NUMBER,
x_msg_data			      OUT NOCOPY   VARCHAR2,
p_calling_context		      IN           VARCHAR2,
p_unit_ver_rec			      IN OUT NOCOPY unit_ver_rec_type,
p_unit_tr_tbl			      IN OUT NOCOPY unit_tr_tbl_type,
p_unit_dscp_tbl			      IN OUT NOCOPY unit_dscp_tbl_type,
p_unit_gs_tbl			      IN OUT NOCOPY unit_gs_tbl_type,
p_usec_tbl			      IN OUT NOCOPY usec_tbl_type,
p_usec_gs_tbl			      IN OUT NOCOPY usec_gs_tbl_type,
p_uso_tbl			      IN OUT NOCOPY uso_tbl_type,
p_unit_ref_tbl			      IN OUT NOCOPY unit_ref_tbl_type,
p_uso_ins_tbl			      IN OUT NOCOPY uso_ins_tbl_type,
p_usec_occurs_facility_tbl	      IN OUT NOCOPY usec_occurs_facility_tbl_type,
p_usec_teach_resp_ovrd_tbl	      IN OUT NOCOPY usec_teach_resp_ovrd_tbl_type,
p_usec_notes_tbl		      IN OUT NOCOPY usec_notes_tbl_type,
p_usec_assmnt_tbl		      IN OUT NOCOPY usec_assmnt_tbl_type,
p_usec_plus_hr_tbl		      IN OUT NOCOPY usec_plus_hr_tbl_type,
p_usec_cat_tbl			      IN OUT NOCOPY usec_cat_tbl_type,
p_usec_rule_tbl			      IN OUT NOCOPY usec_rule_tbl_type,
p_usec_cross_group_tbl		      IN OUT NOCOPY usec_cross_group_tbl_type,
p_usec_meet_with_tbl		      IN OUT NOCOPY usec_meet_with_tbl_type,
p_usec_waitlist_tbl		      IN OUT NOCOPY usec_waitlist_tbl_type,
p_usec_res_seat_tbl		      IN OUT NOCOPY usec_res_seat_tbl_type,
p_usec_sp_fee_tbl		      IN OUT NOCOPY usec_sp_fee_tbl_type,
p_usec_ret_tbl			      IN OUT NOCOPY usec_ret_tbl_type,
p_usec_ret_dtl_tbl		      IN OUT NOCOPY usec_ret_dtl_tbl_type,
p_usec_enr_dead_tbl		      IN OUT NOCOPY usec_enr_dead_tbl_type,
p_usec_enr_dis_tbl		      IN OUT NOCOPY usec_enr_dis_tbl_type,
p_usec_teach_resp_tbl		      IN OUT NOCOPY usec_teach_resp_tbl_type,
p_usec_ass_item_grp_tbl		      IN OUT NOCOPY usec_ass_item_grp_tbl_type,
p_usec_status			      OUT NOCOPY VARCHAR2,
p_usec_gs_status		      OUT NOCOPY VARCHAR2,
p_uso_status			      OUT NOCOPY VARCHAR2,
p_uso_ins_status		      OUT NOCOPY VARCHAR2,
p_uso_facility_status		      OUT NOCOPY VARCHAR2,
p_unit_ref_status		      OUT NOCOPY VARCHAR2,
p_usec_teach_resp_ovrd_status	      OUT NOCOPY VARCHAR2,
p_usec_notes_status		      OUT NOCOPY VARCHAR2,
p_usec_assmnt_status		      OUT NOCOPY VARCHAR2,
p_usec_plus_hr_status		      OUT NOCOPY VARCHAR2,
p_usec_cat_status		      OUT NOCOPY VARCHAR2,
p_usec_rule_status		      OUT NOCOPY VARCHAR2,
p_usec_cross_group_status	      OUT NOCOPY VARCHAR2,
p_usec_meet_with_status		      OUT NOCOPY VARCHAR2,
p_usec_waitlist_status		      OUT NOCOPY VARCHAR2,
p_usec_res_seat_status		      OUT NOCOPY VARCHAR2,
p_usec_sp_fee_status		      OUT NOCOPY VARCHAR2,
p_usec_ret_status		      OUT NOCOPY VARCHAR2,
p_usec_ret_dtl_status		      OUT NOCOPY VARCHAR2,
p_usec_enr_dead_status		      OUT NOCOPY VARCHAR2,
p_usec_enr_dis_status		      OUT NOCOPY VARCHAR2,
p_usec_teach_resp_status	      OUT NOCOPY VARCHAR2,
p_usec_ass_item_grp_status	      OUT NOCOPY VARCHAR2 ) AS
/***********************************************************************************************
Created By:         Sanjeeb Rakshit
Date Created By:    25-May-2005
Purpose:            This is a public API to import data from external system to OSS.
Known limitations,enhancements,remarks:

Change History

Who         When           What
***********************************************************************************************/


l_api_name      CONSTANT VARCHAR2(30) := 'psp_import';
l_api_version   CONSTANT NUMBER := 1.0;

BEGIN
  --Standard start of API savepoint
  SAVEPOINT psp_import_PUB;

  --Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version ,
                                     p_api_version ,
                                     l_api_name    ,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;


  --API body
  IF p_calling_context NOT IN ('L','S','G') THEN
    FND_MESSAGE.SET_NAME('IGS','IGS_PS_INVALID_VALUE_CONTEXT');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_calling_context = 'L' THEN

    --Call the Legacy Private API
    igs_ps_unit_lgcy_pvt.create_unit
     (
       p_api_version      => p_api_version,
       p_init_msg_list    => p_init_msg_list,
       p_commit           => p_commit,
       p_validation_level => p_validation_level,
       p_unit_ver_rec     => p_unit_ver_rec,
       p_unit_tr_tbl      => p_unit_tr_tbl,
       p_unit_dscp_tbl    => p_unit_dscp_tbl,
       p_unit_gs_tbl      => p_unit_gs_tbl,
       p_usec_tbl         => p_usec_tbl,
       p_usec_gs_tbl      => p_usec_gs_tbl,
       p_uso_tbl          => p_uso_tbl,
       p_unit_ref_tbl     => p_unit_ref_tbl,
       p_uso_ins_tbl      => p_uso_ins_tbl,
       x_return_status    => x_return_status,
       x_msg_count        => x_msg_count,
       x_msg_data         => x_msg_data
      );

  ELSE

    --Call the Scheduling/Generic Private API
    igs_ps_generic_pvt.psp_import
    (
      p_api_version                   => p_api_version,
      p_init_msg_list                 => p_init_msg_list,
      p_commit                        => p_commit,
      p_validation_level              => p_validation_level,
      x_return_status	              => x_return_status,
      x_msg_count	              => x_msg_count,
      x_msg_data	              => x_msg_data,
      p_calling_context	              => p_calling_context,
      p_usec_tbl		      => p_usec_tbl,
      p_usec_gs_tbl		      => p_usec_gs_tbl,
      p_uso_tbl			      => p_uso_tbl,
      p_unit_ref_tbl		      => p_unit_ref_tbl,
      p_uso_ins_tbl		      => p_uso_ins_tbl,
      p_usec_occurs_facility_tbl      => p_usec_occurs_facility_tbl,
      p_usec_teach_resp_ovrd_tbl      => p_usec_teach_resp_ovrd_tbl,
      p_usec_notes_tbl		      => p_usec_notes_tbl,
      p_usec_assmnt_tbl		      => p_usec_assmnt_tbl,
      p_usec_plus_hr_tbl	      => p_usec_plus_hr_tbl,
      p_usec_cat_tbl		      => p_usec_cat_tbl,
      p_usec_rule_tbl		      => p_usec_rule_tbl,
      p_usec_cross_group_tbl	      => p_usec_cross_group_tbl,
      p_usec_meet_with_tbl	      => p_usec_meet_with_tbl,
      p_usec_waitlist_tbl	      => p_usec_waitlist_tbl,
      p_usec_res_seat_tbl	      => p_usec_res_seat_tbl,
      p_usec_sp_fee_tbl		      => p_usec_sp_fee_tbl,
      p_usec_ret_tbl		      => p_usec_ret_tbl,
      p_usec_ret_dtl_tbl	      => p_usec_ret_dtl_tbl,
      p_usec_enr_dead_tbl	      => p_usec_enr_dead_tbl,
      p_usec_enr_dis_tbl	      => p_usec_enr_dis_tbl,
      p_usec_teach_resp_tbl	      => p_usec_teach_resp_tbl,
      p_usec_ass_item_grp_tbl	      => p_usec_ass_item_grp_tbl,
      p_usec_status		      => p_usec_status ,
      p_usec_gs_status		      => p_usec_gs_status,
      p_uso_status	              => p_uso_status,
      p_uso_ins_status	              => p_uso_ins_status,
      p_uso_facility_status	      => p_uso_facility_status,
      p_unit_ref_status	              => p_unit_ref_status,
      p_usec_teach_resp_ovrd_status   => p_usec_teach_resp_ovrd_status,
      p_usec_notes_status	      => p_usec_notes_status,
      p_usec_assmnt_status	      => p_usec_assmnt_status,
      p_usec_plus_hr_status	      => p_usec_plus_hr_status,
      p_usec_cat_status	              => p_usec_cat_status,
      p_usec_rule_status	      => p_usec_rule_status,
      p_usec_cross_group_status       => p_usec_cross_group_status,
      p_usec_meet_with_status	      => p_usec_meet_with_status,
      p_usec_waitlist_status	      => p_usec_waitlist_status,
      p_usec_res_seat_status	      => p_usec_res_seat_status,
      p_usec_sp_fee_status	      => p_usec_sp_fee_status,
      p_usec_ret_status	              => p_usec_ret_status,
      p_usec_ret_dtl_status	      => p_usec_ret_dtl_status,
      p_usec_enr_dead_status	      => p_usec_enr_dead_status,
      p_usec_enr_dis_status	      => p_usec_enr_dis_status,
      p_usec_teach_resp_status	      => p_usec_teach_resp_status,
      p_usec_ass_item_grp_status      => p_usec_ass_item_grp_status
     );

  END IF;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO psp_import_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count ,
                                   p_data   => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO psp_import_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count ,
                                   p_data   => x_msg_data );
    WHEN OTHERS THEN
        ROLLBACK TO psp_import_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                   l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count ,
                                   p_data   => x_msg_data );

END psp_import;

END igs_ps_generic_pub;

/
