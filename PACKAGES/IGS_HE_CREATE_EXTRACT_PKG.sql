--------------------------------------------------------
--  DDL for Package IGS_HE_CREATE_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_CREATE_EXTRACT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSHE28S.pls 120.0 2006/02/06 20:12:50 jbaber noship $*/

PROCEDURE create_file (errbuf                OUT NOCOPY VARCHAR2,
                       retcode               OUT NOCOPY NUMBER,
                       p_extract_run_id      IN  NUMBER,
                       p_file_format         IN  VARCHAR2,
                       p_use_overrides       IN  VARCHAR2,
                       p_person_id_grp       IN  NUMBER,
                       p_program_group       IN  VARCHAR2,
                       p_created_since_date  IN  VARCHAR2  );

END igs_he_create_extract_pkg ;

 

/
