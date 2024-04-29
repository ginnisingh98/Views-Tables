--------------------------------------------------------
--  DDL for Package IGF_SL_DL_ORIG_ACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_DL_ORIG_ACK" AUTHID CURRENT_USER AS
/* $Header: IGFSL04S.pls 115.6 2003/02/20 15:40:09 sjadhav ship $ */

-------------------------------------------------------------------------
--
--  Created By : venagara
--  Date Created On : 2000/11/22
--  Purpose : Direct Loan Acknowledgement Process
--    This sql*loader loads the data from the response file into the
--    temporary table.
--
--    This process can load and take in updates for 2 file types :
--       1. Origination Response File
--       2. Credit Response File (incase of PLUS)
--
--    This process
--     - Reads the header file to ensure correct input file.
--     - Parses the file as per the format and loads into response
--       interface tables.
--     - Every Loan ID in the transaction record is checked for few
--       conditions like acknowledgement date etc and Loan Origination
--       record to reflect the Status
--
--  Know limitations, enhancements or remarks
-------------------------------------------------------------------------
-- sjadhav   19-Feb-2003      Bug 2758812 - FA 117 Build
--                            Added
--                            dl_credit_ack to process
--                            Credit Response File
-------------------------------------------------------------------------



PROCEDURE dl_orig_ack(errbuf    OUT  NOCOPY  VARCHAR2,
                      retcode   OUT  NOCOPY  NUMBER,
                      p_org_id  IN   NUMBER );

PROCEDURE dl_credit_ack(errbuf  OUT  NOCOPY  VARCHAR2,
                        retcode OUT  NOCOPY  NUMBER);

END igf_sl_dl_orig_ack;

 

/
