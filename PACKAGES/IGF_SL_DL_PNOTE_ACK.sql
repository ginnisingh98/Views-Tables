--------------------------------------------------------
--  DDL for Package IGF_SL_DL_PNOTE_ACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_DL_PNOTE_ACK" AUTHID CURRENT_USER AS
/* $Header: IGFSL15S.pls 115.4 2002/11/28 14:34:59 nsidana noship $ */

  /*************************************************************
  Created By : prchandr
  Date Created On : 2000/05/09
  Purpose : Package Specification for Direct Loan Promissory Note Acknowlegement
            process
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  PROCEDURE process_ack(errbuf  OUT NOCOPY    VARCHAR2,
                      retcode OUT NOCOPY    NUMBER,
                      P_org_id IN    NUMBER );

END igf_sl_dl_pnote_ack;

 

/
