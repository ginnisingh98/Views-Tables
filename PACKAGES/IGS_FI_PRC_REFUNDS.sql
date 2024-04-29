--------------------------------------------------------
--  DDL for Package IGS_FI_PRC_REFUNDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_PRC_REFUNDS" AUTHID CURRENT_USER AS
/* $Header: IGSFI65S.pls 120.0 2005/06/02 00:32:03 appldev noship $ */
/***********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  11-Mar-2002
  Purpose        :  This package does the Refund Processing for Excess Unapplied Credits
  Known limitations,enhancements,remarks:
  Change History
  Who      When         What
vvutukur  19-Nov-2002  Enh#2584986.Added p_d_gl_date IN parameter to the procedures process_plus,process_batch.
********************************************************************************************** */

-- Procedure for creating the Refunds for the PLUS loans
  PROCEDURE process_plus(p_credit_id    IN   NUMBER,
                         p_borrower_id  IN   NUMBER,
                         p_err_message  OUT NOCOPY  VARCHAR2,
                         p_status       OUT NOCOPY  BOOLEAN,
			 p_d_gl_date    IN   DATE DEFAULT NULL);

-- Procedure for creating the Refunds through a Concurrent Program
  PROCEDURE process_batch(errbuf               OUT NOCOPY   VARCHAR2,
                          retcode              OUT NOCOPY   NUMBER,
                          p_person_id           IN   NUMBER,
                          p_person_id_grp       IN   NUMBER,
                          p_add_drop            IN   VARCHAR2,
                          p_test_run            IN   VARCHAR2,
			  p_d_gl_date           IN   VARCHAR2 DEFAULT NULL);

-- Log the message in a log file based based on the level passed
-- This procedure will write the line with 3*level no. of spaces
-- appended to the value
  PROCEDURE log_message(p_lookup_type   IN  VARCHAR2,
                        p_lookup_code   IN  VARCHAR2,
                        p_value         IN  VARCHAR2,
                        p_level         IN  NUMBER);


END igs_fi_prc_refunds;

 

/
