--------------------------------------------------------
--  DDL for Package Body IGS_FI_ACCOUNT_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_ACCOUNT_INT" AS
/* $Header: IGSFI47B.pls 120.1 2005/09/08 14:44:08 appldev noship $ */

/******************************************************************

Created By:         Lakshmi.Priyadharshini

Date Created By:    12-05-2000

Purpose: To interace the Receivables account details with Student System

Known limitations,enhancements,remarks:

Change History

Who     When       What
agairola 04-Oct-2001 Obsoletion Code added
vchappid 11-May-01 table handler was modifed for IGS_FI_CONTROL_PKG,
                   changes are incorporated.
msrinivi 18-Jul-01 Call to IGS_FI_CONTROL_PKG now takes
                   additional parameter set_of_books_id
******************************************************************/
PROCEDURE account_int( errbuf  OUT NOCOPY  VARCHAR2,
                       retcode OUT NOCOPY  NUMBER,
                       p_org_id NUMBER) AS
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
END account_int;
END IGS_FI_ACCOUNT_INT;

/
