--------------------------------------------------------
--  DDL for Package IGF_AP_PROCESS_CORRECTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_PROCESS_CORRECTIONS" AUTHID CURRENT_USER AS
/* $Header: IGFAP02S.pls 120.0 2005/06/01 15:46:35 appldev noship $ */
/*
  ||  Created By : Sridhar
  ||  Created On : 25-NOV-2000
  ||  Purpose : Package creates a flat file with header,corrected records and trailer
  ||            to be sent to CPS. After the file is created igf_ap_isir_corr,
  ||            igf_ap_fa_base_rec tables are updated to change the correction_status.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who      When            What
  ||  ugummall 30-OCT-2003    Bug 3102439. FA 126 - Multiple FA Offices.
  ||                          Added 5 new parameters to prepare_file procedure namely
  ||                          p_base_id, school_type, p_school_code, eti_dest_code, eti_dest_num
--    cdcruz   17-Sep-2003    # 3085558 FA121-Verification Worksheet.
--                            New validation added which will skip the student if one
--                            or more holds exists.
--                            Sql spool scrapped, and conc Job is called directly

  */

   PROCEDURE prepare_file(  errbuf OUT NOCOPY VARCHAR2,
			                      retcode OUT NOCOPY NUMBER,
			                      p_award_year IN VARCHAR2,
                            p_base_id      IN      NUMBER,
                            school_type    IN      VARCHAR2,
                            p_school_code  IN      VARCHAR2,
                            eti_dest_code  IN      VARCHAR2,
                            eti_dest_num   IN      VARCHAR2
         );

END igf_ap_process_corrections;

 

/
