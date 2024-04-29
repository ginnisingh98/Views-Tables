--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_011
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_011" AUTHID CURRENT_USER AS
/* $Header: IGSAD89S.pls 115.6 2002/12/23 08:55:58 pkpatel ship $ */

/*
	  ||  Created By :
	  ||  Created On :
	  ||  Purpose :
	  ||  Known limitations, enhancements or remarks :
	  ||  Change History :
	  ||  Who             When            What
	  ||  ssawhney       21-oct-2002     Bug no.2630860:SWS104
      ||                                 PRC_PE_RES_DTLS added
      ||  pkpatel        23-DEC-2002     Bug No: 2722027
	  ||                                 PRC_SPECIAL_NEEDS added
	  ||  (reverse chronological order - newest change first)
 */

PROCEDURE PRC_APCNT_ACADHNR_DTLS (
		  P_SOURCE_TYPE_ID	IN	NUMBER,
		  P_BATCH_ID	IN	NUMBER );


PROCEDURE PRC_PE_RES_DTLS (
		  P_SOURCE_TYPE_ID	IN	NUMBER,
		  P_BATCH_ID	IN	NUMBER );

PROCEDURE PRC_SPECIAL_NEEDS(
		  P_SOURCE_TYPE_ID	IN	NUMBER,
		  P_BATCH_ID	IN	NUMBER );

END IGS_AD_IMP_011;

 

/
