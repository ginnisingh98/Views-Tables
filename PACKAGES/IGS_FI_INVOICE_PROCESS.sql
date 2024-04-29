--------------------------------------------------------
--  DDL for Package IGS_FI_INVOICE_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_INVOICE_PROCESS" AUTHID CURRENT_USER AS
/* $Header: IGSFI49S.pls 115.15 2002/11/29 00:24:16 nsidana ship $ */


  PROCEDURE IGS_FI_FEE_ASTO_INT(errbuf          OUT NOCOPY        VARCHAR2,
                                retcode         OUT NOCOPY        NUMBER,
                                p_person_id     IN         NUMBER   DEFAULT NULL,
                                p_course_cd     IN         VARCHAR2 DEFAULT NULL,
                                p_fee_cat       IN         VARCHAR2 DEFAULT NULL,
                                p_fee_period    IN         VARCHAR2 DEFAULT NULL,
                                p_fee_type      IN         VARCHAR2 DEFAULT NULL,
                                p_org_id        IN         NUMBER);

  PROCEDURE IGS_FI_INTTO_OAR(errbuf              OUT NOCOPY        VARCHAR2,
                            retcode             OUT NOCOPY        NUMBER,
                            p_person_id         IN         NUMBER   DEFAULT NULL,
                            p_course_cd         IN         VARCHAR2 DEFAULT NULL,
                            p_fee_cat           IN         VARCHAR2 DEFAULT NULL,
                            p_fee_period        IN         VARCHAR2 DEFAULT NULL,
                            p_fee_type          IN         VARCHAR2 DEFAULT NULL,
                            p_org_id            IN         NUMBER);

  PROCEDURE IGS_FI_OARTO_INVPAY(errbuf          OUT NOCOPY        VARCHAR2,
                                retcode         OUT NOCOPY        NUMBER,
                                p_org_id        IN         NUMBER);

  PROCEDURE IGS_FI_PER_PAY_SCHED(errbuf          OUT NOCOPY        VARCHAR2,
                                 retcode         OUT NOCOPY        NUMBER,
                                 p_org_id        IN         NUMBER);

END IGS_FI_INVOICE_PROCESS;

 

/
