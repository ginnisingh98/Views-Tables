--------------------------------------------------------
--  DDL for Package IGS_FI_REFUNDS_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_REFUNDS_PROCESS" AUTHID CURRENT_USER AS
/* $Header: IGSFI66S.pls 115.3 2002/11/29 00:28:44 nsidana noship $ */

/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  1-Mar-2002
  Purpose        :  This package is used for transfering data to and fro interface
                    refunds tables.
  Known limitations,enhancements,remarks:
  Change History
  Who        When         What
  vchappid   06-Mar-2002  Enh#2144600, added new concurrent manager program update_pay_info
********************************************************************************************** */


PROCEDURE    transfer_to_int( errbuf             OUT NOCOPY   VARCHAR2,
                              retcode            OUT NOCOPY   NUMBER,
                              p_person_id        IN    igs_pe_person.person_id%TYPE,
                              p_person_id_grp    IN    igs_pe_persid_group.group_id%TYPE,
                              p_start_date       IN    VARCHAR2,
                              p_end_date         IN    VARCHAR2,
                              p_test_run         IN    igs_lookups_view.lookup_code%TYPE);

PROCEDURE update_pay_info   ( errbuf               OUT NOCOPY   VARCHAR2,
                              retcode              OUT NOCOPY   NUMBER,
                              p_person_id          IN    igs_fi_parties_v.person_id%TYPE,
                              p_person_id_group    IN    igs_pe_persid_group.group_id%TYPE,
                              p_start_date         IN    VARCHAR2,
                              p_end_date           IN    VARCHAR2,
                              p_test_run           IN    igs_lookups_view.lookup_code%TYPE);
END igs_fi_refunds_process;

 

/
