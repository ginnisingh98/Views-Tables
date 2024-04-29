--------------------------------------------------------
--  DDL for Package IGS_EN_TRANSFER_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_TRANSFER_APIS" AUTHID CURRENT_USER AS
/* $Header: IGSEN82S.pls 120.1 2005/11/25 02:48:54 appldev noship $ */

  /*---------------------------------------------------------------------------------------
   Created by  : Chandrasekhar Kasu, Oracle Student Systems Oracle IDC

  --Change History:
  --Who         When            What
   ckasu       20-Nov-2004     modified signature of cleanup_job as a part of program Transfer
  --                           build
  --ckasu      11-Dec-2004     modified signature as a part of bug#4061818,4061914
  --ctyagi      25-Nov-2005    Created new function arrange_selected_unitsets for bug 4747585
  ----------------------------------------------------------------------------------------*/

    PROCEDURE program_transfer_api
    ( p_person_id               IN   NUMBER,
      p_source_program_cd       IN   VARCHAR2,
      p_source_prog_ver         IN   NUMBER,
      p_term_cal_type           IN   VARCHAR2,
      p_term_seq_num            IN   NUMBER,
      p_acad_cal_type           IN   VARCHAR2,
      p_acad_seq_num            IN   NUMBER,
      p_trans_approval_dt       IN   DATE,
      p_trans_actual_dt         IN   DATE,
      p_dest_program_cd         IN   VARCHAR2,
      p_dest_prog_ver           IN   NUMBER,
      p_dest_coo_id             IN   NUMBER,
      p_uoo_ids_to_transfer     IN   VARCHAR2,
      p_uoo_ids_not_selected    IN   VARCHAR2,
      p_uoo_ids_having_errors   OUT  NOCOPY  VARCHAR2,
      p_unit_sets_to_transfer   IN   VARCHAR2,
      p_unit_sets_not_selected  IN   VARCHAR2,
      p_unit_sets_having_errors OUT  NOCOPY VARCHAR2,
      p_transfer_av             IN   VARCHAR2 DEFAULT 'N',
      p_transfer_re             IN   VARCHAR2 DEFAULT 'N',
      p_discontinue_source      IN   VARCHAR2 DEFAULT 'N',
      p_show_warning            IN   VARCHAR2,
      p_call_from               IN   VARCHAR2,
      p_process_mode            IN   VARCHAR2,
      p_return_status           OUT  NOCOPY  VARCHAR2,
      p_msg_data                OUT  NOCOPY VARCHAR2,
      p_msg_count               OUT  NOCOPY NUMBER
    );


    PROCEDURE log_err_messages(
     p_msg_count      IN NUMBER,
     p_msg_data       IN VARCHAR2,
     p_warn_and_err_msg OUT NOCOPY VARCHAR2
    );

    PROCEDURE cleanup_job(
     errbuf	        OUT  NOCOPY   VARCHAR2,
     retcode            OUT   NOCOPY   NUMBER,
     p_term_cal_comb    IN   VARCHAR2,
     p_mode	        IN   VARCHAR2,
     p_ignore_warnings  IN   VARCHAR2,
     p_drop_enrolled	IN   VARCHAR2
     );



    FUNCTION arrange_selected_unitsets(
       p_person_id            IN   NUMBER,
       p_program_cd           IN   VARCHAR2,
       p_unit_sets_to_transfer IN   VARCHAR2
     ) RETURN VARCHAR2 ;

END IGS_EN_TRANSFER_APIS;

 

/
