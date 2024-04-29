--------------------------------------------------------
--  DDL for Package IGS_FI_CUST_ACCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_CUST_ACCT" AUTHID CURRENT_USER AS
/* $Header: IGSFI72S.pls 115.3 2003/05/28 08:58:51 shtatiko noship $ */

PROCEDURE  process_cust_acct( errbuf             OUT NOCOPY   VARCHAR2,
                              retcode            OUT NOCOPY   NUMBER,
                              p_person_id        IN    igs_pe_person_v.person_id%TYPE,
                              p_person_id_grp    IN    igs_pe_persid_group.group_id%TYPE);
END igs_fi_cust_acct;

 

/
