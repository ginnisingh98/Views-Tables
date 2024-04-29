--------------------------------------------------------
--  DDL for Package IGS_FI_PRC_WAIVERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_PRC_WAIVERS" AUTHID CURRENT_USER AS
/* $Header: IGSFI93S.pls 120.0 2005/09/09 19:16:49 appldev noship $ */

    /*****************************************************************
     Created By      :   Amit Gairola
     Date Created By :   14-Apr-2005
     Purpose         :   Package for Waiver Processing

     Known limitations,enhancements,remarks:
     Change History
     Who        When         What

    ******************************************************************/
  PROCEDURE create_waivers(
                           p_n_person_id                NUMBER,
                           p_v_fee_type                 VARCHAR2,
                           p_v_fee_cal_type             VARCHAR2,
                           p_n_fee_ci_seq_number        NUMBER,
                           p_v_waiver_name              VARCHAR2,
                           p_v_currency_cd              VARCHAR2,
                           p_d_gl_date                  DATE,
                           p_v_real_time_flag           VARCHAR2,
                           p_v_process_mode             VARCHAR2,
                           p_v_career                   VARCHAR2,
                           p_b_init_msg_list            BOOLEAN DEFAULT FALSE,
                           p_validation_level           NUMBER  DEFAULT fnd_api.g_valid_level_full,
                           p_v_raise_wf_event           VARCHAR2,
                           x_waiver_amount   OUT NOCOPY NUMBER,
                           x_return_status   OUT NOCOPY VARCHAR2,
                           x_msg_count       OUT NOCOPY NUMBER,
                           x_msg_data        OUT NOCOPY VARCHAR2);

  PROCEDURE process_waivers( errbuf              OUT NOCOPY VARCHAR2,
                             retcode             OUT NOCOPY NUMBER,
                             p_person_id         IN  hz_parties.party_id%TYPE,
                             p_person_grp_id     IN  igs_pe_persid_group.group_id%TYPE,
                             p_fee_cal           IN  VARCHAR2,
                             p_waiver_name       IN  igs_fi_waiver_pgms.waiver_name%TYPE,
                             p_fee_type          IN  igs_fi_waiver_pgms.target_fee_type%TYPE,
                             p_gl_date           IN  VARCHAR2 );
END igs_fi_prc_waivers;

 

/
