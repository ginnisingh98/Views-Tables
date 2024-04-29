--------------------------------------------------------
--  DDL for Package Body IGS_GE_PURGE_DEL_RECORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GE_PURGE_DEL_RECORD" AS
/* $Header: IGSGE13B.pls 120.1 2006/01/09 06:33:30 sommukhe noship $ */
PROCEDURE purge_records(
            errbuf  OUT NOCOPY   VARCHAR2,
            retcode OUT NOCOPY   NUMBER
          ) AS
/***********************************************************************************************

  Created By     :  Shtatiko
  Date Created By:  19-FEB-2003
  Purpose        :  To purge logically deleted records from the tables, where logical delete
                    functionality is being used. This process will invoke module wise sub-processes.

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
  sommukhe   9-JAN-2006       Bug# 4869737,included call to igs_ge_gen_003.set_org_id.
********************************************************************************************** */

BEGIN

  igs_ge_gen_003.set_org_id (NULL);
  -- Invoke sub-process for PS module
  igs_ps_purge_del_record.purge_ps_records ;

EXCEPTION
  WHEN OTHERS THEN
    retcode := 2;
    fnd_message.set_name ( 'IGS', 'IGS_GE_UNHANDLED_EXP' );
    fnd_message.set_token ( 'NAME', 'purge_records' );
    errbuf := fnd_message.get || ' : ' || SQLERRM ;
    IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL ;

END purge_records;

END igs_ge_purge_del_record;

/
