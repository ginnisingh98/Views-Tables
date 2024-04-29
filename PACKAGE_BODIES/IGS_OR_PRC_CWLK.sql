--------------------------------------------------------
--  DDL for Package Body IGS_OR_PRC_CWLK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_PRC_CWLK" AS
/* $Header: IGSOR13B.pls 115.7 2003/10/22 05:07:19 ssaleem ship $ */

-- declaring constants for the different status
  g_stat_pend         CONSTANT VARCHAR2(1) := '2';
  g_stat_err          CONSTANT VARCHAR2(1) := '3';
  g_stat_prc          CONSTANT VARCHAR2(1) := '1';

  PROCEDURE transfer_data(errbuf  IN OUT NOCOPY VARCHAR2,
                          retcode IN OUT NOCOPY NUMBER,
                          p_org_id       NUMBER) AS
/******************************************************************

Created By:         Amit Gairola

Date Created By:    13-07-2001

Purpose:            The procedure imports the Crosswalk Interface data into the OSS
                    Crosswalk Data tables

Known limitations,enhancements,remarks:

Change History

Who     When        What
ssaleem 22-SEP-2003 Made the following changes for IGS.L
                    a) Deletion of completed records is done
		    b) Commit is issued for every 100 records
		       Savepoint is declared for every record and
		       rollback is issued until the last processed
		       record in case of an error
		    c) Successful logging messages for alternate IDs
		       are removed
pkpatel 15-JAN-2003 Bug No: 2528605
                    Made the alt_id_value UPPER while inserting.
***************************************************************** */
    l_rowid             VARCHAR2(25);
    l_cwlk_id           IGS_OR_CWLK.Crosswalk_Id%TYPE;
    l_cwlk_dtl_id       IGS_OR_CWLK_DTL.Crosswalk_Dtl_Id%TYPE;
    l_status            IGS_OR_CWLK_INT.Status%TYPE;
    l_exception         BOOLEAN := FALSE;
    l_records_processed  NUMBER(3);

    l_in_proc_alt_id      igs_or_cwlk_dtl_int.alt_id_type%TYPE;
    l_in_proc_alt_value   igs_or_cwlk_dtl_int.alt_id_value%TYPE;

-- Cursor for fetching the records from IGS_OR_CWLK_INT table
-- based on the status passed as input
    CURSOR cur_cwlk_int(cp_stat  VARCHAR2) IS
      SELECT *
      FROM   IGS_OR_CWLK_INT
      WHERE  status = cp_stat;

-- Cursor for fetching the records from the Crosswalk Detail Interface
-- tables based on the Crosswalk Interface Id from the Crosswalk table
    CURSOR cur_cwlk_dtl_int(cp_cwlk_int_id      IGS_OR_CWLK_INT.Interface_Crosswalk_Id%TYPE) IS
      SELECT *
      FROM   IGS_OR_CWLK_DTL_INT
      WHERE  interface_crosswalk_id   = cp_cwlk_int_id;

    FUNCTION validate_alt_id(p_alternate_id_type IN igs_or_org_alt_idtyp.org_alternate_id_type%TYPE)
             RETURN BOOLEAN AS

        CURSOR rowid_cur(cp_close_ind igs_or_org_alt_idtyp.close_ind%TYPE,
	                 cp_inst_flag igs_or_org_alt_idtyp.inst_flag%TYPE,
			 cp_org_alternate_id_type igs_or_org_alt_idtyp.org_alternate_id_type%TYPE) IS
        SELECT   rowid
        FROM     igs_or_org_alt_idtyp
        WHERE    org_alternate_id_type = cp_org_alternate_id_type AND
                 CLOSE_IND = cp_close_ind AND
		 inst_flag = cp_inst_flag;

        rowid_rec rowid_cur%ROWTYPE;
    BEGIN

        OPEN rowid_cur('N','Y',p_alternate_id_type);
        FETCH rowid_cur INTO rowid_rec;
        IF (rowid_cur%FOUND) THEN
           CLOSE rowid_cur;
           RETURN(TRUE);
        ELSE
           CLOSE rowid_cur;
           RETURN(FALSE);
        END IF;

    END validate_alt_id;
  BEGIN

-- Set the Org Id
   IGS_GE_GEN_003.Set_Org_Id(p_org_id);
-- Initialising the variables
    l_exception        := FALSE;
    l_status           := g_stat_pend;
    l_records_processed := 0;

-- Loop through the Crosswalk Interface table for the records
-- which have the status as Pending
    FOR cwlkrec IN cur_cwlk_int(g_stat_pend) LOOP
      BEGIN

        SAVEPOINT sp_record;

-- Call the Insert Row procedure of the table handler for the
-- Crosswalk table
        l_rowid   := NULL;
        l_cwlk_id := NULL;
        IGS_OR_CWLK_PKG.Insert_Row(x_rowid            => l_rowid,
                                   x_crosswalk_id     => l_cwlk_id,
                                   x_institution_code => NULL,
                                   x_institution_name => cwlkrec.institution_name);

-- Log appropriate messages in the Log file of the Concurrent Manager
        FND_MESSAGE.Set_Name('IGS',
                             'IGS_OR_IMP_INST_NAME');
        FND_MESSAGE.Set_Token('INST_NAME',
                              cwlkrec.institution_name);
        FND_FILE.Put_Line(FND_FILE.Log,
                          FND_MESSAGE.Get);

-- Loop through the Crosswalk Detail Interface table based on the
-- Crosswalk Id passed from the Crosswalk Interface table(previous cursor)

        FOR cwlkdtlrec IN cur_cwlk_dtl_int(cwlkrec.interface_crosswalk_id) LOOP

-- Check if the Alt_Id_Type exists in the IGS_OR_ORG_ALT_IDTYP table
          IF NOT validate_alt_id(cwlkdtlrec.alt_id_type) THEN

-- If it does not exist, then log the appropriate message in the Concurrent Manager logfile
            FND_MESSAGE.Set_Name('IGS',
                                 'IGS_OR_INVALID_ALT_ID_TYP');
            FND_MESSAGE.Set_Token('ALT_ID_TYPE',
                                  cwlkdtlrec.alt_id_type);
            FND_FILE.Put_Line(FND_FILE.Log,
                              FND_MESSAGE.Get);

-- Raise the exception so that the record can be updated to Status 3
            APP_EXCEPTION.RAISE_EXCEPTION;
          END IF;

-- Call the Insert Row tablehandler for the Crosswalk Detail
          l_rowid       := NULL;
          l_cwlk_dtl_id := NULL;

	  l_in_proc_alt_id := cwlkdtlrec.alt_id_type;
	  l_in_proc_alt_value := UPPER(cwlkdtlrec.alt_id_value);

          IGS_OR_CWLK_DTL_PKG.Insert_Row(x_rowid                 => l_rowid,
                                         x_crosswalk_dtl_id      => l_cwlk_dtl_id,
                                         x_crosswalk_id          => l_cwlk_id,
                                         x_alt_id_type           => cwlkdtlrec.alt_id_type,
                                         x_alt_id_value          => UPPER(cwlkdtlrec.alt_id_value));

        END LOOP;
      EXCEPTION
        WHEN Others THEN

-- If the exception is raised, then
-- rollback the transaction and log the message in the
-- Concurrent Manager's log file.Set the Exception variable
-- to TRUE for appropriate updation of the Interface record
          ROLLBACK TO sp_record;
          FND_FILE.Put_Line(FND_FILE.Log,
                            FND_MESSAGE.Get || ' ' || l_in_proc_alt_id || '-' || l_in_proc_alt_value);
          l_exception  := TRUE;
      END;

-- If the Exception variable is set to True, then update the status variable to error
-- else update to Processed.
      IF l_exception THEN
        l_status := g_stat_err;
      ELSE
        l_status := g_stat_prc;
      END IF;

-- Call the Update DML for updating the status appropriately
      UPDATE IGS_OR_CWLK_INT
      SET    status                 = l_status
      WHERE  interface_crosswalk_id = cwlkrec.interface_crosswalk_id;

-- Issue Commit for every 100 records
      l_records_processed := l_records_processed + 1;

      IF l_records_processed = 100 THEN
        l_records_processed := 0;
	commit;
      END IF;

-- Reset the variable to FALSE
      l_exception := FALSE;
    END LOOP;

-- Modification made for IGS.L, delete records that are successfully inserted/updated
    DELETE FROM IGS_OR_CWLK_DTL_INT DTL
    WHERE  EXISTS
          (SELECT 1
	   FROM   IGS_OR_CWLK_INT MSTR
	   WHERE  MSTR.STATUS = '1' AND
	          MSTR.INTERFACE_CROSSWALK_ID = DTL.INTERFACE_CROSSWALK_ID);

    DELETE FROM IGS_OR_CWLK_INT WHERE STATUS = '1';

    commit;

  EXCEPTION
    WHEN Others THEN
      retcode := 2;
      IGS_GE_MSG_STACK.Conc_Exception_Hndl;
  END transfer_data;
END igs_or_prc_cwlk;

/
