--------------------------------------------------------
--  DDL for Package IGS_FI_PRC_APINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_PRC_APINT" AUTHID CURRENT_USER AS
/* $Header: IGSFI78S.pls 115.1 2003/02/27 10:25:10 agairola noship $ */
/***********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  17-Feb-2003
  Purpose        :  This package transfers the Student Finance refund transactions to AP
  Known limitations,enhancements,remarks:
  Change History
  Who     When       What

********************************************************************************************** */

PROCEDURE transfer(errbuf                OUT NOCOPY VARCHAR2,
                   retcode               OUT NOCOPY NUMBER,
                   p_n_party_id          IN  NUMBER,
                   p_n_person_group_id   IN  NUMBER,
		   p_v_create_supplier   IN  VARCHAR2,
		   p_v_supplier_type     IN  VARCHAR2,
		   p_v_inv_pay_group     IN  VARCHAR2,
		   p_n_inv_pay_term      IN  NUMBER,
		   p_v_test_run          IN  VARCHAR2);

END igs_fi_prc_apint;

 

/
