--------------------------------------------------------
--  DDL for Package IGF_SL_CL_ORIG_ACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_CL_ORIG_ACK" AUTHID CURRENT_USER AS
/* $Header: IGFSL09S.pls 120.0 2005/06/01 15:46:24 appldev noship $ */

/***************************************************************
   Created By           :       mesriniv
   Date Created By      :       2000/12/06
   Purpose              :       To Load the Common Line Data from DataFile and then
                                Insert into Approriate Tables

   Known Limitations,Enhancements or Remarks
   Change History       :
   Who                  When            What
 ***************************************************************/
  PROCEDURE process_ack(
  errbuf                        OUT NOCOPY    VARCHAR2,
  retcode                       OUT NOCOPY    NUMBER,
  p_c_update_disb_dtls          IN            VARCHAR2
  );

  PROCEDURE prepare_scr_message (itemtype   IN VARCHAR2,
                                 itemkey    IN VARCHAR2,
                                 actid      IN NUMBER,
                                 funcmode   IN VARCHAR2,
                                 resultout  OUT NOCOPY VARCHAR2);

END igf_sl_cl_orig_ack;

 

/
