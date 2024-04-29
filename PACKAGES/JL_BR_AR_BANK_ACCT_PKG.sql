--------------------------------------------------------
--  DDL for Package JL_BR_AR_BANK_ACCT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_AR_BANK_ACCT_PKG" AUTHID CURRENT_USER AS
/* $Header: jlbrslas.pls 120.11.12010000.1 2008/07/31 04:23:37 appldev ship $ */

/*========================================================================
 | PUBLIC PROCEDURE Create_Event_Dists
 |
 | DESCRIPTION
 |      Main routine which creates SLA Event and distributions for
 |      JLBR AR Bank Transfer accounting. It returns EVENT_ID value
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      a) Create_SLA_Event
 |      b) Create_Distribution
 |      c) Cancel_Reject_Distributions
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 *=======================================================================*/

TYPE NUMBER_TBL_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

TYPE VARCHAR2_TBL_TYPE IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

TYPE r_dist is Record
(
  rev_dist_id NUMBER_TBL_TYPE,
  dist_id     NUMBER_TBL_TYPE
);

TYPE r_event is Record
(
  row_id      VARCHAR2_TBL_TYPE,
  EVENT_TYPE_CODE VARCHAR2_TBL_TYPE,
  EVENT_ID        NUMBER_TBL_TYPE,
  CANCEL_EVENT_ID NUMBER_TBL_TYPE
);

trx_dist r_dist;

trx_events r_event;

PROCEDURE Create_Event_Dists   (p_event_type_code       IN  VARCHAR2,
                                p_event_date            IN  DATE,
                                p_document_id           IN  NUMBER,
                                p_gl_date               IN  DATE,
                                p_occurrence_id         IN  NUMBER,
                                p_bank_occurrence_type  IN  VARCHAR2,
                                p_bank_occurrence_code  IN  VARCHAR2,
                                p_std_occurrence_code   IN  VARCHAR2,
                                p_bordero_type          IN  VARCHAR2,
                                p_endorsement_amt       IN  NUMBER,
                                p_bank_charges_amt      IN  NUMBER,
                                p_factoring_charges_amt IN  NUMBER,
                                p_event_id              OUT NOCOPY NUMBER);

/*========================================================================
 | PUBLIC PROCEDURE Upgrade_Occurrences
 |
 | DESCRIPTION
 |      Upgrades Occurrences during downtime and on-demand upgrade
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 *=======================================================================*/

-- Called by Downtime Upgrade script
-- Internally calls the other version

PROCEDURE UPGRADE_OCCURRENCES(
                       l_table_owner  IN VARCHAR2,
                       l_table_name   IN VARCHAR2,
                       l_script_name  IN VARCHAR2,
                       l_worker_id    IN VARCHAR2,
                       l_num_workers  IN VARCHAR2,
                       l_batch_size   IN VARCHAR2,
                       l_batch_id     IN NUMBER,
                       l_action_flag  IN VARCHAR2);

-- Main Upgrade Procedure
PROCEDURE UPGRADE_OCCURRENCES(
                       l_table_owner  IN VARCHAR2,
                       l_table_name   IN VARCHAR2,
                       l_script_name  IN VARCHAR2,
                       l_worker_id    IN VARCHAR2,
                       l_num_workers  IN VARCHAR2,
                       l_batch_size   IN VARCHAR2,
                       l_batch_id     IN NUMBER,
                       l_action_flag  IN VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2);

/*========================================================================
 | PUBLIC PROCEDURE Update_Distributions
 |
 | DESCRIPTION
 |      Upgrades Occurrences during downtime and on-demand upgrade
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 *=======================================================================*/

-- Main Upgrade Procedure
PROCEDURE UPDATE_OCCURRENCES(
                       l_table_owner  IN VARCHAR2,
                       l_table_name   IN VARCHAR2,
                       l_script_name  IN VARCHAR2,
                       l_worker_id    IN VARCHAR2,
                       l_num_workers  IN VARCHAR2,
                       l_batch_size   IN VARCHAR2,
                       l_batch_id     IN NUMBER,
                       l_action_flag  IN VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2);

/*========================================================================
 | PUBLIC PROCEDURE Upgrade_Distributions
 |
 | DESCRIPTION
 |      Upgrades Distributions during downtime and on-demand upgrade
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 *=======================================================================*/

PROCEDURE UPGRADE_DISTRIBUTIONS(
                       l_start_id     IN NUMBER,
                       l_end_id       IN NUMBER);

/*========================================================================
 | PUBLIC PROCEDURE Update_distributions
 |
 | DESCRIPTION
 |      Updates Distributions during downtime and on-demand upgrade
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 *=======================================================================*/

/*
PROCEDURE UPDATE_DISTRIBUTIONS(
                       l_start_rowid     IN rowid,
                       l_end_rowid       IN rowid);

*/
/*========================================================================
 | PUBLIC PROCEDURE Load_Occurrences_Header_Data
 |
 | DESCRIPTION
 |      Inserts into AR_XLA_LINES_EXTRACT to get AR Sources for SLA Events
 |      of Collection Document Occurrences
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 *=======================================================================*/

PROCEDURE load_occurrences_header_data(p_application_id IN NUMBER);

/*========================================================================
 | PUBLIC FUNCTION Check_If_Upgrade_Occs
 |
 | DESCRIPTION
 |      To be used only by the on-demand SLA upgrade program of AR to check
 |      if Brazilian Occurrences Upgrade is to be executed or not
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 *=======================================================================*/

FUNCTION check_if_upgrade_occs RETURN BOOLEAN;

/*============================================================================+
 |
 | PUBLIC PROCEDURE Check_If_Upgrade_Occs
 |
 | DESCRIPTION
 |      Upgrades JL MRC records to SLA Archetecture
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-SEP-2005           JVARKEY           Created
 *============================================================================*/

-- Called by Downtime Upgrade script
-- Internally calls the other version

PROCEDURE UPGRADE_MC_OCCURRENCES(
                       l_table_owner  IN VARCHAR2,
                       l_table_name   IN VARCHAR2,
                       l_script_name  IN VARCHAR2,
                       l_worker_id    IN VARCHAR2,
                       l_num_workers  IN VARCHAR2,
                       l_batch_size   IN VARCHAR2,
                       l_batch_id     IN NUMBER,
                       l_action_flag  IN VARCHAR2);

-- Main Upgrade Procedure

PROCEDURE UPGRADE_MC_OCCURRENCES(
                       l_table_owner  IN VARCHAR2,
                       l_table_name   IN VARCHAR2,
                       l_script_name  IN VARCHAR2,
                       l_worker_id    IN VARCHAR2,
                       l_num_workers  IN VARCHAR2,
                       l_batch_size   IN VARCHAR2,
                       l_batch_id     IN NUMBER,
                       l_action_flag  IN VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2);

END JL_BR_AR_BANK_ACCT_PKG;

/
