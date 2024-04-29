--------------------------------------------------------
--  DDL for Package IGF_AP_TODO_GRPS_PRC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_TODO_GRPS_PRC_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAP28S.pls 120.4 2006/04/20 02:58:09 veramach ship $ */
/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL body for package: IGF_AP_TODO_GRPS_PRC_PKG                |
 |                                                                       |
 | NOTES:                                                                |
 |   This process adds one or more To Do Items to the given Student or to|
 |   the group of students using Person ID Groups for a given Award Year.|
 |                                                                       |
 | HISTORY                                                               |
 | Who         When          What                                        |
 | bvisvana   20-Jun-2005   FA 140 - To Do Item Process                  |
 |                          Included Status 1 to Status 15 corresponding |
 |                          to the 15 to do items in main procedure      |
 | brajendr    12-Oct-2002   Changes the paramter order as specified in  |
 |                           the concurrent Job                          |
 |                           Modified the Messages IGF_AP_NO_BASEID      |
 |                                                                       |
 *=======================================================================*/

 FUNCTION assign_todo(
                         p_base_id         IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                         p_person_id_grp   IN  igs_pe_persid_group_all.group_id%TYPE,
                         p_awd_cal_type    IN  igs_ca_inst.cal_type%TYPE,
                         p_awd_seq_num     IN  igs_ca_inst.sequence_number%TYPE,
                         p_upd_mode        IN  VARCHAR2,
                         p_item_number_1   IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_1        IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_2   IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_2        IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_3   IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_3        IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_4   IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_4        IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_5   IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_5        IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_6   IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_6        IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_7   IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_7        IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_8   IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_8        IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_9   IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_9        IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_10  IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_10       IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_11  IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_11       IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_12  IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_12       IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_13  IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_13       IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_14  IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_14       IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_item_number_15  IN  igf_ap_td_item_mst_all.todo_number%TYPE,
                         p_status_15       IN  igf_ap_td_item_inst_all.status%TYPE DEFAULT NULL,
                         p_calling_from    IN  VARCHAR2
                        ) RETURN BOOLEAN;

  PROCEDURE main(
                 errbuf            OUT NOCOPY VARCHAR2,
                 retcode           OUT NOCOPY NUMBER,
                 p_award_year      IN  VARCHAR2,
                 p_person_id_grp   IN  NUMBER,
                 p_base_id         IN  NUMBER,
                 p_upd_mode        IN  VARCHAR2,
                 p_item_1          IN  NUMBER,
                 p_status_1        IN  VARCHAR2 DEFAULT NULL,
                 p_item_2          IN  NUMBER,
                 p_status_2        IN  VARCHAR2 DEFAULT NULL,
                 p_item_3          IN  NUMBER,
                 p_status_3        IN  VARCHAR2 DEFAULT NULL,
                 p_item_4          IN  NUMBER,
                 p_status_4        IN  VARCHAR2 DEFAULT NULL,
                 p_item_5          IN  NUMBER,
                 p_status_5        IN  VARCHAR2 DEFAULT NULL,
                 p_item_6          IN  NUMBER,
                 p_status_6        IN  VARCHAR2 DEFAULT NULL,
                 p_item_7          IN  NUMBER,
                 p_status_7        IN  VARCHAR2 DEFAULT NULL,
                 p_item_8          IN  NUMBER,
                 p_status_8        IN  VARCHAR2 DEFAULT NULL,
                 p_item_9          IN  NUMBER,
                 p_status_9        IN  VARCHAR2 DEFAULT NULL,
                 p_item_10         IN  NUMBER,
                 p_status_10       IN  VARCHAR2 DEFAULT NULL,
                 p_item_11         IN  NUMBER,
                 p_status_11       IN  VARCHAR2 DEFAULT NULL,
                 p_item_12         IN  NUMBER,
                 p_status_12       IN  VARCHAR2 DEFAULT NULL,
                 p_item_13         IN  NUMBER,
                 p_status_13       IN  VARCHAR2 DEFAULT NULL,
                 p_item_14         IN  NUMBER,
                 p_status_14       IN  VARCHAR2 DEFAULT NULL,
                 p_item_15         IN  NUMBER,
                 p_status_15       IN  VARCHAR2 DEFAULT NULL
                );


END igf_ap_todo_grps_prc_pkg;

 

/
