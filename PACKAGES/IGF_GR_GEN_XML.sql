--------------------------------------------------------
--  DDL for Package IGF_GR_GEN_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_GR_GEN_XML" AUTHID CURRENT_USER AS
/* $Header: IGFGR12S.pls 120.0 2005/06/02 15:45:04 appldev noship $ */
  /*************************************************************
  Created By : ugummall
  Date Created On : 2004/10/04
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/

PROCEDURE main  (
                  errbuf                 OUT    NOCOPY  VARCHAR2,
                  retcode                OUT    NOCOPY  NUMBER,
                  p_award_year           IN             VARCHAR2,
                  p_source_entity_id     IN             VARCHAR2,
                  p_report_entity_id     IN             VARCHAR2,
                  p_rep_dummy            IN             VARCHAR2,
                  p_attend_entity_id     IN             VARCHAR2,
                  p_atd_dummy            IN             VARCHAR2,
                  p_base_id              IN             IGF_GR_RFMS_ALL.BASE_ID%TYPE,
                  p_per_dummy            IN             NUMBER,
                  p_persid_grp           IN             NUMBER
                );

PROCEDURE store_xml ( itemtype   IN VARCHAR2,
                      itemkey    IN VARCHAR2,
                      actid      IN NUMBER,
                      funcmode   IN VARCHAR2,
                      resultout  OUT NOCOPY VARCHAR2);

PROCEDURE print_xml ( errbuf        OUT NOCOPY VARCHAR2,
                      retcode       OUT NOCOPY NUMBER,
                      p_document_id VARCHAR2);

PROCEDURE set_nls_fmt(PARAM in VARCHAR2);

  CURSOR  cur_rfms  ( cp_ci_cal_type          igf_gr_rfms.ci_cal_type%TYPE,
                      cp_ci_sequence_number   igf_gr_rfms.ci_sequence_number%TYPE,
                      cp_rep_entity_id_txt    igf_gr_rfms.rep_entity_id_txt%TYPE,
                      cp_atd_entity_id_txt    igf_gr_rfms.atd_entity_id_txt%TYPE,
                      cp_base_id              igf_gr_rfms.base_id%TYPE
                    ) IS
    SELECT  rfms.*
      FROM  IGF_GR_RFMS RFMS
     WHERE  rfms.ci_cal_type                  = cp_ci_cal_type
      AND   rfms.ci_sequence_number           = cp_ci_sequence_number
      AND   NVL(rfms.rep_entity_id_txt, '-1') = NVL(cp_rep_entity_id_txt, NVL(rfms.rep_entity_id_txt, '-1'))
      AND   NVL(rfms.atd_entity_id_txt, '-1') = NVL(cp_atd_entity_id_txt, NVL(rfms.atd_entity_id_txt, '-1'))
      AND   rfms.base_id                      = NVL(cp_base_id,  rfms.base_id)
      AND   rfms.orig_action_code             = 'R';
      --    FOR UPDATE OF orig_action_code NOWAIT;

END IGF_GR_GEN_XML;

 

/
