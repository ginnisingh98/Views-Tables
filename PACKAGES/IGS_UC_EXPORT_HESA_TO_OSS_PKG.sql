--------------------------------------------------------
--  DDL for Package IGS_UC_EXPORT_HESA_TO_OSS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_EXPORT_HESA_TO_OSS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSUC25S.pls 120.0 2005/06/02 03:42:29 appldev noship $ */

PROCEDURE chk_person_present (l_per_id igs_pe_person.person_id%type
                            , l_per_present OUT NOCOPY varchar2);
PROCEDURE pre_enrollement_process( l_person_id IGS_PE_PERSON.person_id%type
			    ,l_COURSE_CD varchar2 ,l_VERSION_NUMBER number);

PROCEDURE export_data(errbuf OUT NOCOPY varchar2,retcode OUT NOCOPY number,
                      p_person_id IGS_PE_PERSON.person_id%type);

END igs_uc_export_hesa_to_oss_pkg;

 

/
