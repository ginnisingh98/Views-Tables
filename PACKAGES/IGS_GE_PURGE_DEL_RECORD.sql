--------------------------------------------------------
--  DDL for Package IGS_GE_PURGE_DEL_RECORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GE_PURGE_DEL_RECORD" AUTHID CURRENT_USER AS
/* $Header: IGSGE13S.pls 115.0 2003/02/25 13:55:14 shtatiko noship $ */
/***********************************************************************************************

  Created By     :  shtatiko
  Date Created By:  24-FEB-2003
  Purpose        :  To purge logically deleted records from the tables, where logical delete
                    functionality is being used. This process will invoke module wise sub-processes.

  Known limitations,enhancements,remarks:
  Change History
  Who 	     When          What

***********************************************************************************************/

PROCEDURE purge_records (
  errbuf  OUT NOCOPY   VARCHAR2,
  retcode OUT NOCOPY   NUMBER
);

END igs_ge_purge_del_record;

 

/
