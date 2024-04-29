--------------------------------------------------------
--  DDL for Package Body IGS_FI_PAY_TERM_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_PAY_TERM_INT" AS
/* $Header: IGSFI48B.pls 120.1 2005/09/08 16:12:15 appldev noship $ */

PROCEDURE payment_term_int(  errbuf  OUT NOCOPY  VARCHAR2,
                             retcode OUT NOCOPY  NUMBER ,
                             p_org_id  NUMBER ) AS
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
  WHEN OTHERS THEN
    retcode := 2;
    FND_MESSAGE.Set_Name('IGS',
                         'IGS_GE_UNHANDLED_EXCEPTION');
    IGS_GE_MSG_STACK.Add;
    APP_EXCEPTION.Raise_Exception;
END payment_term_int;
END IGS_FI_PAY_TERM_INT;

/
