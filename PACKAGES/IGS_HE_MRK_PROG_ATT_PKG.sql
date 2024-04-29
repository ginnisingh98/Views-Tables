--------------------------------------------------------
--  DDL for Package IGS_HE_MRK_PROG_ATT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_MRK_PROG_ATT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSHE06S.pls 115.3 2002/11/29 00:42:26 nsidana noship $ */

PROCEDURE update_data(errbuf OUT NOCOPY varchar2,retcode OUT NOCOPY number,l_extract_run_id  igs_he_ex_rn_dat_ln.extract_run_id%type,
	l_submission_name igs_he_submsn_header.submission_name%type,
	l_return_name igs_he_submsn_return.return_name%type );

END igs_he_mrk_prog_att_pkg;

 

/
