--------------------------------------------------------
--  DDL for Package IGS_HE_IMPORT_POPDLHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_IMPORT_POPDLHE" AUTHID CURRENT_USER AS
/* $Header: IGSHE26S.pls 120.0 2005/10/14 10:29:57 appldev noship $*/

PROCEDURE import_popdlhe_to_oss (errbuf            OUT NOCOPY VARCHAR2,
                                 retcode           OUT NOCOPY NUMBER,
                                 p_submission_name IN  igs_he_sub_rtn_qual.submission_name%TYPE,
                                 p_return_name     IN  igs_he_sub_rtn_qual.return_name%TYPE,
                                 p_qual_period     IN  igs_he_sub_rtn_qual.qual_period_code%TYPE,
                                 p_census_date     IN  VARCHAR2 );


END igs_he_import_popdlhe ;

 

/
