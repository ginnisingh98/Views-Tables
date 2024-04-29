--------------------------------------------------------
--  DDL for Package IGS_HE_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_EXTRACT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSHE9AS.pls 120.0 2005/06/01 16:38:43 appldev noship $ */

PROCEDURE extract_main
          (errbuf                IN OUT NOCOPY VARCHAR2,
           retcode               IN OUT NOCOPY NUMBER,
           p_extract_run_id      IN     igs_he_ext_run_dtls.extract_run_id%TYPE,
           p_module_called_from  IN     VARCHAR2,
           p_new_run_flag        IN     VARCHAR2);


END IGS_HE_EXTRACT_PKG;

 

/
