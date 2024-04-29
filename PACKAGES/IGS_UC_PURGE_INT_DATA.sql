--------------------------------------------------------
--  DDL for Package IGS_UC_PURGE_INT_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_PURGE_INT_DATA" AUTHID CURRENT_USER AS
/* $Header: IGSUC39S.pls 120.0 2005/06/02 04:12:17 appldev noship $ */
PROCEDURE purge_data( errbuf   OUT NOCOPY VARCHAR2,
                      retcode  OUT NOCOPY NUMBER,
                      p_del_obsolete_data IN VARCHAR2,
		      p_del_proc_data IN VARCHAR2
                      );

END igs_uc_purge_int_data;

 

/
