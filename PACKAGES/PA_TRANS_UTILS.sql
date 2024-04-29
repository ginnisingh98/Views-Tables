--------------------------------------------------------
--  DDL for Package PA_TRANS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TRANS_UTILS" AUTHID CURRENT_USER AS
/* $Header: PATRUTLS.pls 115.3 2003/02/14 07:21:27 riyengar noship $
/* This api validates the actuals (EI) exists for the given assignment_id
 * when assignment dates are modified / updated /inserted/ deleted
 * if the EI exists for the given assignment and transaction date not
 * falling between current start and end dates of the assignments OR
 * if the transaction date doesnot falls between the new assignment start and end dates
 * it returns the following error message depending on the calling modes
 *    calling mode             error message                  return_status
 *   ---------------------------------------------------------------------------
 *   CANCEL / DELETE          PA_EI_ASSGN_EXISTS                   E
 *   UPDATE / INSERT          PA_EI_ASSGN_DATE_OUTOFRANGE          E
 *                            PA_EI_ASSGN_INVALID_PARAMS           E
 * If success then x_return_status is 'S' and  x_error_message_code will be null
 *
 */
PROCEDURE check_txn_exists (p_assignment_id   IN  NUMBER
                           ,p_old_start_date  IN  DATE
                           ,p_old_end_date    IN  DATE
                           ,p_new_start_date  IN  DATE
                           ,p_new_end_date    IN  DATE
                           ,p_calling_mode    IN  VARCHAR2  default 'CANCEL'
			   ,p_project_id      IN  NUMBER
			   ,p_person_id       IN  NUMBER
                           ,x_error_message_code OUT NOCOPY VARCHAR2
                           ,x_return_status   OUT  NOCOPY VARCHAR2 );

END PA_TRANS_UTILS;

 

/
