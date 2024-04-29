--------------------------------------------------------
--  DDL for Package IGS_UC_START_NEW_CYCLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_START_NEW_CYCLE" AUTHID CURRENT_USER AS
/* $Header: IGSUC40S.pls 120.0 2005/06/01 20:17:51 appldev noship $ */


   /*************************************************************
   Created By      : dsridhar
   Date Created On : 19-JUN-2003
   Purpose         : This procedure will configure the UCAS System to a new
                    Admission Cycle.

   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   dsridhar        19-JUN-2003     Create Version as part of UC203FD
                                  Bug# 2669208
   (reverse chronological order - newest change first)
   ***************************************************************/


PROCEDURE start_new_cycle ( errbuf    OUT NOCOPY    VARCHAR2,
                            retcode   OUT NOCOPY    NUMBER
                          );

END igs_uc_start_new_cycle;

 

/
