--------------------------------------------------------
--  DDL for Package IGS_HE_VERIFY_RETURN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_VERIFY_RETURN_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSHE27S.pls 120.0 2006/02/06 20:12:15 jbaber noship $*/

PROCEDURE verify_return (errbuf                     OUT NOCOPY VARCHAR2,
                         retcode                    OUT NOCOPY NUMBER,
                         p_submission_name          IN  VARCHAR2,
                         p_sub_rtn_id               IN  NUMBER,
                         p_check_HESA_details       IN  VARCHAR2,
                         p_check_field_associations IN  VARCHAR2);


END igs_he_verify_return_pkg ;

 

/
