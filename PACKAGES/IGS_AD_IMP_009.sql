--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_009
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_009" AUTHID CURRENT_USER AS
/* $Header: IGSAD87S.pls 115.8 2003/12/09 11:54:09 pbondugu ship $ */

/*
  ||  Created By : nsinha
  ||  Created On : 22-JUN-2001
  ||  Purpose : This procedure process the Application
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel       22-JUN-2001      Bug no.2702536
  ||                                 Added the parameters p_match_ind, p_person_id, p_addr_type and p_person_id_type
  ||  (reverse chronological order - newest change first)
*/
PROCEDURE IGS_AD_IMP_FIND_DUP_PERSONS
	(p_d_batch_id IN NUMBER,
	 p_d_source_type_id IN NUMBER,
	 p_d_match_set_id IN NUMBER,
	 p_interface_id   IN igs_ad_interface.interface_id%TYPE,
     p_match_ind      IN OUT NOCOPY igs_ad_interface.match_ind%TYPE,
	 p_person_id      OUT    NOCOPY igs_ad_interface.person_id%TYPE,
     p_addr_type      IN igs_pe_mtch_set_data.value%TYPE,
     p_person_id_type IN igs_pe_mtch_set_data.value%TYPE
);

/*removed the procedure SET_STAT_MATC_RVW_DIS_RCDS as part of bug 3191401*/


END IGS_AD_IMP_009;

 

/
