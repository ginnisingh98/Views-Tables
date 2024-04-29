--------------------------------------------------------
--  DDL for Package IGF_AP_VER_GRPS_PRC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_VER_GRPS_PRC_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAP29S.pls 115.5 2002/12/09 09:19:06 rasingh noship $ */


  FUNCTION dup_ver_item ( p_base_id     IN  igf_ap_fa_base_rec_all.base_id%TYPE     ,
                          p_isir_field  IN  igf_ap_inst_ver_item.isir_map_col%TYPE
                        ) RETURN BOOLEAN ;


  FUNCTION add_ver_item( p_base_id           IN  igf_ap_fa_base_rec_all.base_id%TYPE                       ,
                         p_awd_cal_type      IN  igs_ca_inst.cal_type%TYPE                                 ,
                         p_awd_seq_num       IN  igs_ca_inst.sequence_number%TYPE                          ,
                         p_isir_field        IN  igf_ap_inst_ver_item.isir_map_col%TYPE                    ,
                         p_item_number_1     IN  igf_ap_td_item_mst_all.todo_number%TYPE                   ,
                         p_item_number_2     IN  igf_ap_td_item_mst_all.todo_number%TYPE     DEFAULT  NULL ,
                         p_item_number_3     IN  igf_ap_td_item_mst_all.todo_number%TYPE     DEFAULT  NULL ,
                         p_item_number_4     IN  igf_ap_td_item_mst_all.todo_number%TYPE     DEFAULT  NULL ,
                         p_item_number_5     IN  igf_ap_td_item_mst_all.todo_number%TYPE     DEFAULT  NULL ,
                         p_item_number_6     IN  igf_ap_td_item_mst_all.todo_number%TYPE     DEFAULT  NULL ,
                         p_item_number_7     IN  igf_ap_td_item_mst_all.todo_number%TYPE     DEFAULT  NULL ,
                         p_item_number_8     IN  igf_ap_td_item_mst_all.todo_number%TYPE     DEFAULT  NULL ,
                         p_item_number_9     IN  igf_ap_td_item_mst_all.todo_number%TYPE     DEFAULT  NULL ,
                         p_item_number_10    IN  igf_ap_td_item_mst_all.todo_number%TYPE     DEFAULT  NULL ,
                         p_item_number_11    IN  igf_ap_td_item_mst_all.todo_number%TYPE     DEFAULT  NULL ,
                         p_item_number_12    IN  igf_ap_td_item_mst_all.todo_number%TYPE     DEFAULT  NULL ,
                         p_item_number_13    IN  igf_ap_td_item_mst_all.todo_number%TYPE     DEFAULT  NULL ,
                         p_item_number_14    IN  igf_ap_td_item_mst_all.todo_number%TYPE     DEFAULT  NULL ,
                         p_item_number_15    IN  igf_ap_td_item_mst_all.todo_number%TYPE     DEFAULT  NULL
                        ) RETURN BOOLEAN ;


  PROCEDURE main(errbuf              OUT NOCOPY VARCHAR2 ,
                 retcode             OUT NOCOPY NUMBER ,
                 p_awd_yr            IN  VARCHAR2                                               ,
                 p_prs_grp_id        IN  igs_pe_prsid_grp_mem.group_id%TYPE                     ,
                 p_base_id           IN  igf_ap_fa_base_rec_all.base_id%TYPE                    ,
                 p_isir_field        IN  igf_ap_inst_ver_item.isir_map_col%TYPE                 ,
                 p_item_1            IN  igf_ap_td_item_mst_all.todo_number%TYPE                ,
                 p_item_2            IN  igf_ap_td_item_mst_all.todo_number%TYPE  DEFAULT  NULL ,
                 p_item_3            IN  igf_ap_td_item_mst_all.todo_number%TYPE  DEFAULT  NULL ,
                 p_item_4            IN  igf_ap_td_item_mst_all.todo_number%TYPE  DEFAULT  NULL ,
                 p_item_5            IN  igf_ap_td_item_mst_all.todo_number%TYPE  DEFAULT  NULL ,
                 p_item_6            IN  igf_ap_td_item_mst_all.todo_number%TYPE  DEFAULT  NULL ,
                 p_item_7            IN  igf_ap_td_item_mst_all.todo_number%TYPE  DEFAULT  NULL ,
                 p_item_8            IN  igf_ap_td_item_mst_all.todo_number%TYPE  DEFAULT  NULL ,
                 p_item_9            IN  igf_ap_td_item_mst_all.todo_number%TYPE  DEFAULT  NULL ,
                 p_item_10           IN  igf_ap_td_item_mst_all.todo_number%TYPE  DEFAULT  NULL ,
                 p_item_11           IN  igf_ap_td_item_mst_all.todo_number%TYPE  DEFAULT  NULL ,
                 p_item_12           IN  igf_ap_td_item_mst_all.todo_number%TYPE  DEFAULT  NULL ,
                 p_item_13           IN  igf_ap_td_item_mst_all.todo_number%TYPE  DEFAULT  NULL ,
                 p_item_14           IN  igf_ap_td_item_mst_all.todo_number%TYPE  DEFAULT  NULL ,
                 p_item_15           IN  igf_ap_td_item_mst_all.todo_number%TYPE  DEFAULT  NULL
                ) ;


END igf_ap_ver_grps_prc_pkg;

 

/
