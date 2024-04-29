--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_025
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_025" AUTHID CURRENT_USER AS
/* $Header: IGSADB6S.pls 120.0 2005/06/01 17:12:42 appldev noship $ */
/*
  ||  Created By : pkpatel
  ||  Created On : 12-NOV-2001
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || sarakshi        13-Nov-2001     Added procedure declaration for prc_pe_disciplinary_dtls
  ||  (reverse chronological order - newest change first)
*/

PROCEDURE prc_pe_house_status
(
	   P_SOURCE_TYPE_ID	IN	NUMBER,
	   P_BATCH_ID	IN	NUMBER );

PROCEDURE prc_pe_disciplinary_dtls
/*
  ||  Created By : sarakshi
  ||  Created On : 13-NOV-2001
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
*/
        (
	   P_SOURCE_TYPE_ID	IN	NUMBER,
	   P_BATCH_ID	IN	NUMBER
        );

/*
  ||  Created By : pkpatel
  ||  Created On : 5-FEB-2003
  ||  Purpose : Multiple Races TD (This procedure is to import data for Person Races.)
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
*/
PROCEDURE prc_pe_race
        (
	   P_SOURCE_TYPE_ID	IN	NUMBER,
	   P_BATCH_ID	IN	NUMBER
        );

PROCEDURE prc_priv_dtls
(
	   P_SOURCE_TYPE_ID	IN	NUMBER,
	   P_BATCH_ID	IN	NUMBER );

END igs_ad_imp_025;

 

/
