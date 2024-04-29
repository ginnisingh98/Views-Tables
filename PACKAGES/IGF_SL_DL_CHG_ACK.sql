--------------------------------------------------------
--  DDL for Package IGF_SL_DL_CHG_ACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_DL_CHG_ACK" AUTHID CURRENT_USER AS
/* $Header: IGFSL06S.pls 115.5 2002/11/28 14:33:19 nsidana ship $ */

  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/29
  Purpose : Direct Loan Change Acknowledgement Process
    This sql*loader loads the data from the response file into the
    temporary table.
    This process can load the file type :
       1. Change Response File
    This process
     - Reads the header file to ensure correct input file.
     - Parses the file as per the format and loads into response
       interface tables.
     - Every Loan Number in the transaction record is checked for few
       conditions like Batch ID in the header File and File creation Date.
       If already not loaded, then loads the results.

  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/


PROCEDURE dl_chg_ack(errbuf  OUT NOCOPY    VARCHAR2,
                     retcode OUT NOCOPY    NUMBER,
                     p_org_id IN    NUMBER );


END igf_sl_dl_chg_ack;

 

/
