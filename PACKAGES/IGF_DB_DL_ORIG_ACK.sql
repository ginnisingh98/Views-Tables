--------------------------------------------------------
--  DDL for Package IGF_DB_DL_ORIG_ACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_DB_DL_ORIG_ACK" AUTHID CURRENT_USER AS
/* $Header: IGFDB03S.pls 115.5 2002/11/28 14:13:17 nsidana ship $ */

  /*************************************************************
  Created By : prchandr
  Date Created On : 2000/11/13
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

PROCEDURE disb_ack(errbuf  OUT NOCOPY    VARCHAR2,
                   retcode OUT NOCOPY    NUMBER,
                   p_org_id IN    NUMBER
                  );

END igf_db_dl_orig_ack;

 

/
