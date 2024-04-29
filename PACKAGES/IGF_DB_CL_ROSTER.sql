--------------------------------------------------------
--  DDL for Package IGF_DB_CL_ROSTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_DB_CL_ROSTER" AUTHID CURRENT_USER AS
/* $Header: IGFDB04S.pls 120.0 2005/06/01 13:17:28 appldev noship $ */

  /*************************************************************
  Created By : sjadhav
  Date Created On : 2000/12/18
  Purpose : Class Roster for disbursements

    This process
     - Reads the header file to ensure correct input file.
     - Parses the file as per the format and loads into response
       interface tables.


  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/


PROCEDURE roster_ack(errbuf        OUT NOCOPY    VARCHAR2,
                     retcode       OUT NOCOPY    NUMBER,
                     p_update_disb IN VARCHAR2);


END igf_db_cl_roster;

 

/
