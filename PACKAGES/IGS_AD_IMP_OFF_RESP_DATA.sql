--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_OFF_RESP_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_OFF_RESP_DATA" AUTHID CURRENT_USER AS
/* $Header: IGSADC2S.pls 115.2 2002/11/28 21:51:51 nsidana noship $ */
----------------------------------------------------------------------------------------------------------------------------------------------------
--  Created By : rboddu
--  Date Created On : 09-SEP-2002
--  Purpose : 2395510
--  Know limitations, enhancements or remarks
--  Change History
--  Who             When            What
----------------------------------------------------------------------------------------------------------------------------------------------------

  PROCEDURE imp_off_resp(            errbuf              OUT NOCOPY   VARCHAR2,
                                     retcode             OUT NOCOPY   NUMBER,
                                     p_batch_id          IN    igs_ad_offresp_batch.batch_id%TYPE,
                                     p_yes_no            IN    VARCHAR2 DEFAULT '2');
END igs_ad_imp_off_resp_data;

 

/
