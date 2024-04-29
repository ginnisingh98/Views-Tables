--------------------------------------------------------
--  DDL for Package IGS_FI_DEPOSITS_PRCSS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_DEPOSITS_PRCSS" AUTHID CURRENT_USER AS
/* $Header: IGSFI74S.pls 120.0 2005/06/01 21:34:05 appldev noship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL body for package: IGS_FI_DEPOSITS_PRCSS                   |
 |                                                                       |
 | NOTES:                                                                |
 | Contains procedure for reversing a transaction, reverse_transaction() |
 |                                                                       |
 | HISTORY                                                               |
 | WHO            WHEN           WHAT                                    |
 |pathipat        08-Dec-02      Enh# 2584741 - Deposits build           |
 |                               Added forfeit_deposit and transfer_deposit
 *=======================================================================*/

PROCEDURE forfeit_deposit( p_n_credit_id        IN         NUMBER,
                           p_d_gl_date          IN         DATE,
                           p_b_return_status    OUT NOCOPY BOOLEAN,
                           p_c_message_name     OUT NOCOPY VARCHAR2
                         );

PROCEDURE reverse_transaction( p_n_credit_id         IN  NUMBER,
                               p_c_reversal_reason   IN  VARCHAR2,
			       p_c_reversal_comments IN  VARCHAR2,
			       p_d_gl_date           IN  DATE,
			       p_b_return_status     OUT NOCOPY BOOLEAN,
			       p_c_message_name      OUT NOCOPY VARCHAR2
			     );

PROCEDURE transfer_deposit( p_n_credit_id      IN NUMBER,
                            p_d_gl_date        IN DATE,
                            p_b_return_status  OUT NOCOPY BOOLEAN,
                            p_c_message_name   OUT NOCOPY VARCHAR2,
                            p_c_receipt_number OUT NOCOPY VARCHAR2
                          );

END igs_fi_deposits_prcss;

 

/
