--------------------------------------------------------
--  DDL for Package IGF_SP_CREATE_BASE_REC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SP_CREATE_BASE_REC" AUTHID CURRENT_USER AS
/* $Header: IGFSP01S.pls 115.2 2002/11/28 14:35:54 nsidana noship $ */

 ------------------------------------------------------------------------------------
  --Created by  : smanglm ( Oracle IDC)
  --Date created: 2002/01/11
  --
  --Purpose:  Created as part of the build for DLD Sponsorship
  --          This package deals with the creation of equivalent records of OSS in
  --          Financial Aid system. The system is a pre-requisite for Assigning students
  --          sponsor and also for sponsor award process.
  --          It has the following procedure/function:
  --             i)  procedure create_base_record  - this is the main procedure called
  --                 from the concurrent manager
  --            ii)  function create_fa_base_record - this is a function called from
  --                 create_base_record for actual creation of the base records
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------------------------

PROCEDURE create_base_record
              (errbuf               OUT NOCOPY VARCHAR2,
               retcode              OUT NOCOPY NUMBER,
               p_award_year         IN  VARCHAR2,
               p_person_id          IN  igs_pe_person.person_id%TYPE,
               p_person_group_id    IN  igs_pe_prsid_grp_mem.group_id%TYPE,
               p_org_id             IN  NUMBER DEFAULT NULL);

FUNCTION create_fa_base_record
              (p_cal_type           IN  igs_ca_inst.cal_type%TYPE,
               p_sequence_number    IN  igs_ca_inst.sequence_number%TYPE,
               p_person_id          IN  igs_pe_person.person_id%TYPE,
               p_base_id            OUT NOCOPY igf_ap_fa_base_rec.base_id%TYPE,
               p_message            OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

END IGF_SP_CREATE_BASE_REC;

 

/
