--------------------------------------------------------
--  DDL for Package Body IGS_UC_PURGE_INT_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_PURGE_INT_DATA" AS
/* $Header: IGSUC39B.pls 120.2 2006/08/21 03:52:55 jbaber noship $ */
   PROCEDURE purge_data( errbuf  OUT NOCOPY VARCHAR2,
                        retcode OUT NOCOPY NUMBER,
                        p_del_obsolete_data IN VARCHAR2,
		        p_del_proc_data IN VARCHAR2
                      ) IS
    /*************************************************************
    Created By      : DSRIDHAR
    Date Created On : 05-JUN-2003
    Purpose :     Created the Document w.r.t. MUS Build, Bug No: 2669208.
		  This process is created to delete all records from the Interface tables
		  which have been successfully processed and populated into the main UCAS
		  tables or have been obsoleted by a change in data coming from UCAS.

    Know limitations, enhancements or remarks
    Change History
    Who             When            What
    (reverse chronological order - newest change first)
    anwest          18-JAN-2006     Bug# 4950285 R12 Disable OSS Mandate
    dsridhar        14-JUL-2003     Changed package name to CAPS, changed concatenation
    ***************************************************************/

    TYPE InterfaceTableNames IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    InterfaceTables InterfaceTableNames;
    l_index BINARY_INTEGER;
    l_statement VARCHAR2(3000);
    l_where VARCHAR2(100);

    BEGIN

       --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
       IGS_GE_GEN_003.SET_ORG_ID;

       --Checking if both the parameters p_del_obsolete_data and p_del_proc_data are 'NO'
       --If both are 'NO' then logging a message "Both parameters cannot be NO"
       IF p_del_obsolete_data = 'N' AND p_del_proc_data = 'N' THEN

          fnd_message.set_name('IGS','IGS_UC_BOTH_CANT_BE_NO');
          fnd_file.put_line(fnd_file.log, fnd_message.get);
	  retcode := 2;
          RETURN;

       END IF;

       --Set the where clause for delete
       IF p_del_obsolete_data = 'Y' AND p_del_proc_data = 'Y' THEN
          l_where := ' WHERE record_status IN (''O'', ''D'') ';
       ELSIF p_del_obsolete_data = 'Y' AND p_del_proc_data = 'N' THEN
          l_where := ' WHERE record_status = ''O'' ';
       ELSIF p_del_obsolete_data = 'N' AND p_del_proc_data = 'Y' THEN
          l_where := ' WHERE record_status = ''D'' ';
       END IF;

       --Initialising the TABLE InterfaceTables with the Interface Table Names
       InterfaceTables(1)  := 'IGS_UC_CCRSE_INTS';
       InterfaceTables(2)  := 'IGS_UC_CEBLSBJ_INTS';
       InterfaceTables(3)  := 'IGS_UC_CINST_INTS';
       InterfaceTables(4)  := 'IGS_UC_CJNTADM_INTS';
       InterfaceTables(5)  := 'IGS_UC_CCONTRL_INTS';
       InterfaceTables(6)  := 'IGS_UC_CRAPR_INTS';
       InterfaceTables(7)  := 'IGS_UC_CRAWDBD_INTS';
       InterfaceTables(8)  := 'IGS_UC_CRFCODE_INTS';
       InterfaceTables(9)  := 'IGS_UC_CRKYWD_INTS';
       InterfaceTables(10) := 'IGS_UC_CROFFAB_INTS';
       InterfaceTables(11) := 'IGS_UC_CREFPOC_INTS';
       InterfaceTables(12) := 'IGS_UC_CRPREPO_INTS';
       InterfaceTables(13) := 'IGS_UC_CRSUBJ_INTS';
       InterfaceTables(14) := 'IGS_UC_CTARIFF_INTS';
       InterfaceTables(15) := 'IGS_UC_CSCHCNT_INTS';
       InterfaceTables(16) := 'IGS_UC_CVSCH_INTS';
       InterfaceTables(17) := 'IGS_UC_IOFFER_INTS';
       InterfaceTables(18) := 'IGS_UC_IQUAL_INTS';
       InterfaceTables(19) := 'IGS_UC_ISTARA_INTS';
       InterfaceTables(20) := 'IGS_UC_ISTARC_INTS';
       InterfaceTables(21) := 'IGS_UC_ISTARG_INTS';
       InterfaceTables(22) := 'IGS_UC_ISTARH_INTS';
       InterfaceTables(23) := 'IGS_UC_ISTARK_INTS';
       InterfaceTables(24) := 'IGS_UC_ISTARN_INTS';
       InterfaceTables(25) := 'IGS_UC_ISTRPQR_INTS';
       InterfaceTables(26) := 'IGS_UC_ISTART_INTS';
       InterfaceTables(27) := 'IGS_UC_ISTARW_INTS';
       InterfaceTables(28) := 'IGS_UC_ISTARX_INTS';
       InterfaceTables(29) := 'IGS_UC_ISTARZ1_INTS';
       InterfaceTables(30) := 'IGS_UC_ISTARZ2_INTS';
       InterfaceTables(31) := 'IGS_UC_ISTMNT_INTS';
       InterfaceTables(32) := 'IGS_UC_UCNTACT_INTS';
       InterfaceTables(33) := 'IGS_UC_UCNTGRP_INTS';
       InterfaceTables(34) := 'IGS_UC_UCRSKWD_INTS';
       InterfaceTables(35) := 'IGS_UC_UCRSVAC_INTS';
       InterfaceTables(36) := 'IGS_UC_UCRSVOP_INTS';
       InterfaceTables(37) := 'IGS_UC_UCRSE_INTS';
       InterfaceTables(38) := 'IGS_UC_UINST_INTS';
       InterfaceTables(39) := 'IGS_UC_UOFABRV_INTS';
       InterfaceTables(40) := 'IGS_UC_IREFRNC_INTS';
       InterfaceTables(41) := 'IGS_UC_IFRMQUL_INTS';
       InterfaceTables(42) := 'IGS_UC_ISTARJ_INTS';
       InterfaceTables(43) := 'IGS_UC_COUNTRY_INTS';

        FOR j IN InterfaceTables.First..InterfaceTables.Last LOOP

	   --Delete statement to delete obsolete and processed data
           IF p_del_obsolete_data = 'Y' OR p_del_proc_data = 'Y' THEN

	          l_statement := 'DECLARE
				  BEGIN
		                     DELETE FROM ' || InterfaceTables(j) || l_where || ' ; ' || '
				     IF SQL%ROWCOUNT > 0 THEN
				        fnd_message.set_name(''IGS'',''IGS_UC_DEL_OBSOL_INT_DATA'');
				        fnd_message.set_token(''TNAME'',''' || InterfaceTables(j) || ''');
                                        fnd_file.put_line(fnd_file.log, fnd_message.get);
				     END IF;
				  EXCEPTION
	                             WHEN OTHERS THEN
                                     ROLLBACK;
				  END; ';

		  EXECUTE IMMEDIATE l_statement;

	    END IF;
       END LOOP;

       EXCEPTION
       WHEN OTHERS THEN
                 fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
                 fnd_message.set_token('NAME','IGS_UC_PURGE_INT_DATA.purge_data');
                 fnd_file.put_line(fnd_file.log, fnd_message.get);
                 errbuf  := fnd_message.get ;
                 retcode := 2;

                 IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

  END purge_data;

END igs_uc_purge_int_data;

/
