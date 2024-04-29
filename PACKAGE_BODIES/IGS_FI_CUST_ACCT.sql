--------------------------------------------------------
--  DDL for Package Body IGS_FI_CUST_ACCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_CUST_ACCT" AS
/* $Header: IGSFI72B.pls 115.13 2003/05/30 09:32:14 shtatiko noship $ */

/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  15-Feb-2002
  Purpose        :  This package is used to create customer                        |
  Known limitations,enhancements,remarks:
  Change History
  Who        When         What
  shtatiko   28-MAY-2003  Enh# 2831582, Obsoleted process "Create Customer Accounts".
                          Removed create_cust_acct, log_pers_id functions. Also removed
                          local procedures, log_messages, log_person and lookup_desc as they are no longer used.
  shtatiko   25-APR-2003  Enh# 2831569, Modified process_cust_acct procedure.
  vchappid   13-Jun-2002  Bug#2411529, Incorrectly used message names have been modified
  sarakshi   27-Feb-2002  changed the hz_parties references to igs_fi_parties_v from all the selects, bug:2238362
********************************************************************************************** */

PROCEDURE  process_cust_acct( errbuf             OUT NOCOPY   VARCHAR2,
                              retcode            OUT NOCOPY   NUMBER,
                              p_person_id        IN    igs_pe_person_v.person_id%TYPE,
                              p_person_id_grp    IN    igs_pe_persid_group.group_id%TYPE) IS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  18-Feb-2002
  Purpose        :  To create the customer corresponding to a person or person group.
  Known limitations,enhancements,remarks:
  Change History
  Who       When          What
  shtatiko  28-MAY-2003   Enh# 2831582, Obsoleted this process.
  shtatiko  25-APR-2003   Enh# 2831569, Added check for Manage Account System Option
  pathipat  06-Jan-2003   Bug:2684782 - Logged group_cd instead of group_id for person_id_Group
                          in the log file - Used func igs_fi_gen_005.finp_get_prsid_grp_code()
  vchappid  13-Jun-2002   Bug#2411529, Incorrectly used message names have been modified
********************************************************************************************** */

BEGIN

 /*
  * Enh# 2831582, Lockbox design introduces a new Lockbox functionality
  * detached from Oracle Receivables (AR) Module.
  * Due to this change, Process, "Create Customer Accounts" is obsoleted.
  */
  fnd_message.set_name('IGS', 'IGS_GE_OBSOLETE_JOB');
  fnd_file.put_line( fnd_file.LOG, fnd_message.get());
  retcode := 0;

END process_cust_acct;

END igs_fi_cust_acct;

/
