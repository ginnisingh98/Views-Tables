--------------------------------------------------------
--  DDL for Package Body IGS_FI_INVOICE_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_INVOICE_PROCESS" AS
/* $Header: IGSFI49B.pls 120.1 2005/09/08 14:36:35 appldev noship $ */

PROCEDURE igs_fi_fee_asto_int(errbuf          OUT NOCOPY        VARCHAR2,
                              retcode         OUT NOCOPY        NUMBER,
                              p_person_id     IN         NUMBER   DEFAULT NULL,
                              p_course_cd     IN         VARCHAR2 DEFAULT NULL,
                              p_fee_cat       IN         VARCHAR2 DEFAULT NULL,
                              p_fee_period    IN         VARCHAR2 DEFAULT NULL,
                              p_fee_type      IN         VARCHAR2 DEFAULT NULL,
                              p_org_id        IN         NUMBER) AS
BEGIN
-- As per the SFCR005, this concurrent program is obsoleted
-- and if the user tries to run this program, then an error
-- message should be written to the log file that this is obsolete
  FND_MESSAGE.Set_Name('IGS',
                       'IGS_GE_OBSOLETE_JOB');
  FND_FILE.Put_Line(FND_FILE.Log,
                    FND_MESSAGE.Get);
  retcode := 0;
EXCEPTION
    WHEN Others THEN
      retcode := 2;
      FND_MESSAGE.Set_Name('IGS',
                           'IGS_GE_UNHANDLED_EXCEPTION');
      errbuf := FND_MESSAGE.Get;
      IGS_GE_MSG_STACK.Conc_Exception_Hndl;
END igs_fi_fee_asto_int;

PROCEDURE IGS_FI_INTTO_OAR(errbuf              OUT NOCOPY        VARCHAR2,
                           retcode             OUT NOCOPY        NUMBER,
                           p_person_id         IN         NUMBER   DEFAULT NULL,
                           p_course_cd         IN         VARCHAR2 DEFAULT NULL,
                           p_fee_cat           IN         VARCHAR2 DEFAULT NULL,
                           p_fee_period        IN         VARCHAR2 DEFAULT NULL,
                           p_fee_type          IN         VARCHAR2 DEFAULT NULL,
                           p_org_id            IN         NUMBER) AS
BEGIN
-- As per the SFCR005, this concurrent program is obsoleted
-- and if the user tries to run this program, then an error
-- message should be written to the log file that this is obsolete
  FND_MESSAGE.Set_Name('IGS',
                       'IGS_GE_OBSOLETE_JOB');
  FND_FILE.Put_Line(FND_FILE.Log,
                    FND_MESSAGE.Get);
  retcode := 0;
EXCEPTION
    WHEN Others THEN
      retcode := 2;
      FND_MESSAGE.Set_Name('IGS',
                           'IGS_GE_UNHANDLED_EXCEPTION');
      errbuf := FND_MESSAGE.Get;
      IGS_GE_MSG_STACK.Conc_Exception_Hndl;
END igs_fi_intto_oar;

PROCEDURE IGS_FI_OARTO_INVPAY(errbuf          OUT NOCOPY        VARCHAR2,
                              retcode         OUT NOCOPY        NUMBER,
                              p_org_id        IN         NUMBER) AS
BEGIN
-- As per the SFCR005, this concurrent program is obsoleted
-- and if the user tries to run this program, then an error
-- message should be written to the log file that this is obsolete
  FND_MESSAGE.Set_Name('IGS',
                       'IGS_GE_OBSOLETE_JOB');
  FND_FILE.Put_Line(FND_FILE.Log,
                    FND_MESSAGE.Get);
  retcode := 0;
EXCEPTION
    WHEN Others THEN
      retcode := 2;
      FND_MESSAGE.Set_Name('IGS',
                           'IGS_GE_UNHANDLED_EXCEPTION');
      errbuf := FND_MESSAGE.Get;
      IGS_GE_MSG_STACK.Conc_Exception_Hndl;
END igs_fi_oarto_invpay;

PROCEDURE IGS_FI_PER_PAY_SCHED(errbuf          OUT NOCOPY        VARCHAR2,
                               retcode         OUT NOCOPY        NUMBER,
                               p_org_id        IN         NUMBER) AS
BEGIN
-- As per the SFCR005, this concurrent program is obsoleted
-- and if the user tries to run this program, then an error
-- message should be written to the log file that this is obsolete
  FND_MESSAGE.Set_Name('IGS',
                       'IGS_GE_OBSOLETE_JOB');
  FND_FILE.Put_Line(FND_FILE.Log,
                    FND_MESSAGE.Get);
  retcode := 0;
EXCEPTION
    WHEN Others THEN
      retcode := 2;
      FND_MESSAGE.Set_Name('IGS',
                           'IGS_GE_UNHANDLED_EXCEPTION');
      errbuf := FND_MESSAGE.Get;
      IGS_GE_MSG_STACK.Conc_Exception_Hndl;
END igs_fi_per_pay_sched;

END IGS_FI_INVOICE_PROCESS;

/
