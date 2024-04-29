--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_PRBLTY_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_PRBLTY_VAL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSADB0S.pls 115.3 2002/11/28 21:48:39 nsidana ship $ */

          /*
	  ||  Created By : Prabhat.Patel@Oracle.com
	  ||  Created On : 03-AUG-2001
	  ||  Purpose : This is the driving procedure for the concurrent job
	  ||            'Import Probability Values'
	  ||  Known limitations, enhancements or remarks :
	  ||  Change History :
	  ||  Who             When            What
	  ||  (reverse chronological order - newest change first)
	  */
          PROCEDURE prc_prblty_value(
                             errbuf			OUT NOCOPY		VARCHAR2,
                             retcode			OUT NOCOPY		NUMBER,
                             p_prblty_val_batch_id      IN              igs_ad_recrt_pi_int.prblty_val_batch_id%TYPE
                             );

END igs_ad_imp_prblty_val_pkg;

 

/
