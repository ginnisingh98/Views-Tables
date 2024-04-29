--------------------------------------------------------
--  DDL for Package IGS_UC_RELEASE_TRANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_RELEASE_TRANS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSUC69S.pls 120.0 2005/09/09 20:06:50 appldev noship $*/

  PROCEDURE release_transactions (
     errbuf                        OUT NOCOPY VARCHAR2,
     retcode                       OUT NOCOPY NUMBER,
     p_org_unit_code               IN  VARCHAR2,
     p_ucas_system_code            IN  VARCHAR2,
     p_ucas_program_code           IN  VARCHAR2,
     p_ucas_campus                 IN  VARCHAR2,
     p_ucas_entry_point            IN  NUMBER,
     p_ucas_entry_month            IN  NUMBER,
     p_ucas_entry_year             IN  NUMBER,
     p_ucas_trans_type             IN  VARCHAR2,
     p_ucas_decision_code          IN  VARCHAR2,
     p_trans_creation_dt_from      IN  VARCHAR2,
     p_trans_creation_dt_to        IN  VARCHAR2,
     p_trans_transmit_dt_from      IN  VARCHAR2,
     p_trans_transmit_dt_to        IN  VARCHAR2
    );

END igs_uc_release_trans_pkg;

 

/
