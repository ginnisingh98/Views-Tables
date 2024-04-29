--------------------------------------------------------
--  DDL for Package PSA_FUNDS_CHECKER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_FUNDS_CHECKER_PKG" AUTHID CURRENT_USER AS
/* $Header: psafbcfs.pls 120.24.12010000.2 2010/01/28 19:08:14 sasukuma ship $ */
/*#
 * PSA_FUNDS_CHECKER_PKG is an online funds checker that enforces budgetary control.
 * General Ledger provides this uniform interface through which subledgers
 * and General Ledger can check and reserve funds.
 * @rep:scope public
 * @rep:product PSA
 * @rep:lifecycle active
 * @rep:displayname PSA Funds Checker
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GL_BC_PACKETS
 * @rep:ihelp psa/@aproverchpx#aproverchpx Product Overview, Oracle Public Sector Advanced Features Help.
 */

  -- Funds Checker Main Routine

/*#
 * Glxfck is the main Funds Check API for any process that needs to perform Funds Check
 * and/or Funds Reservation. This routine returns TRUE if successfull; otherwise
 * it returns FALSE.
 * @param p_ledgerid The Ledger Id
 * @param p_packetid The packet id of the packet in process
 * @param p_mode The Funds check operation mode, default to C
 * @param p_override Override indicator in case of Funds Reservation failure; default is N
 * @param p_conc_flag Indicates whether the API is invoked from a Concurrent program; default is N
 * @param p_user_id The User ID for Override (From AP AutoApproval)
 * @param p_user_resp_id The User Responsibility ID for Override (From AP AutoApproval)
 * @param p_calling_prog_flag Identifies whether Funds Checker called from SLA validation routine
 * @param p_return_code Contains the funds check return code of the packet in process
 * @return Returns TRUE if successful else FALSE
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname PSA Funds Check API
 * @rep:compatibility S
 * @rep:ihelp psa/@aproverchpx#aproverchpx Product Overview, Oracle Public Sector Advanced Features Help.
 */
  FUNCTION glxfck(p_ledgerid          IN  NUMBER,
                  p_packetid          IN  NUMBER,
                  p_mode              IN  VARCHAR2 DEFAULT 'C',
                  p_override          IN  VARCHAR2 DEFAULT 'N',
                  p_conc_flag         IN  VARCHAR2 DEFAULT 'N',
                  p_user_id           IN  NUMBER   DEFAULT NULL,
                  p_user_resp_id      IN  NUMBER   DEFAULT NULL,
                  p_calling_prog_flag IN  VARCHAR2 DEFAULT 'S',
                  p_return_code       OUT NOCOPY   VARCHAR2) RETURN BOOLEAN;

  --
  -- Overloaded Version of glxfck()
  -- This contains an additional OUT parameter p_unrsv_packet_id.
  -- This is to be used by General Ledger only.
  --
  FUNCTION glxfck(p_ledgerid             IN  NUMBER,
                  p_packetid          IN  NUMBER,
                  p_mode              IN  VARCHAR2 DEFAULT 'C',
                  p_override          IN  VARCHAR2 DEFAULT 'N',
                  p_conc_flag         IN  VARCHAR2 DEFAULT 'N',
                  p_user_id           IN  NUMBER   DEFAULT NULL,
                  p_user_resp_id      IN  NUMBER   DEFAULT NULL,
                  p_calling_prog_flag IN  VARCHAR2 DEFAULT 'G',
                  p_return_code       OUT NOCOPY   VARCHAR2,
                  p_unrsv_packet_id   OUT NOCOPY   NUMBER) RETURN BOOLEAN;

  --
  -- This contains an additional OUT parameter p_unrsv_packet_id and
  -- an additional IN parameter p_confirm_override
  -- This is to be used by General Ledger only for override behaviour
  --

  FUNCTION gl_confirm_override(p_ledgerid          IN  NUMBER,
                  p_packetid          IN  NUMBER,
                  p_mode              IN  VARCHAR2 DEFAULT 'C',
                  p_override          IN  VARCHAR2 DEFAULT 'N',
                  p_conc_flag         IN  VARCHAR2 DEFAULT 'N',
                  p_user_id           IN  NUMBER   DEFAULT NULL,
                  p_user_resp_id      IN  NUMBER   DEFAULT NULL,
                  p_calling_prog_flag IN  VARCHAR2 DEFAULT 'G',
                  p_confirm_override  IN  VARCHAR2 DEFAULT 'Y',
                  p_return_code       OUT NOCOPY   VARCHAR2,
                          p_unrsv_packet_id   OUT NOCOPY   NUMBER) RETURN BOOLEAN;

  PROCEDURE glxfpp(p_eventid       IN NUMBER);

  FUNCTION get_debug return VARCHAR2;

  PROCEDURE bc_optimizer (err_buf           OUT NOCOPY VARCHAR2,
                          ret_code          OUT NOCOPY VARCHAR2,
                          p_ledger_id        IN NUMBER,
                          p_purge_days       IN NUMBER,
                          p_delete_mode      IN VARCHAR2);


  PROCEDURE bc_purge_hist (err_buf           OUT NOCOPY VARCHAR2,
                           ret_code          OUT NOCOPY VARCHAR2,
                           p_ledger_id       IN NUMBER,
                           p_purge_mode      IN VARCHAR2,
                           p_purge_statuses  IN VARCHAR2,
                           p_purge_date      IN VARCHAR2);

  PROCEDURE glxfma (err_buf           OUT NOCOPY VARCHAR2,
                    ret_code          OUT NOCOPY VARCHAR2,
                    p_ledger_id       IN NUMBER,
                    p_check_flag      IN VARCHAR2,
                    p_autopost_set_id IN NUMBER);

  PROCEDURE glsibc (p_last_updated_by IN NUMBER,
                    p_new_template_id IN NUMBER,
                    p_ledger_id IN NUMBER);

  PROCEDURE glsfbc (p_curr_temp_id IN NUMBER,
                    p_ledger_id IN NUMBER,
                    p_last_updated_by IN NUMBER);

  FUNCTION  budgetary_control (p_ledgerid IN NUMBER,
                               p_return_code OUT NOCOPY VARCHAR2) return BOOLEAN;

  PROCEDURE populate_group_id (p_grp_id IN NUMBER,
                               p_application_id IN NUMBER,
                               p_je_batch_name  IN VARCHAR2 DEFAULT NULL);

  TYPE xla_events_table IS TABLE OF psa_xla_events_logs%ROWTYPE;

  TYPE xla_validation_lines_table IS TABLE OF psa_xla_validation_lines_logs%ROWTYPE;

  TYPE xla_ae_lines_table IS TABLE OF psa_xla_ae_lines_logs%ROWTYPE;

  TYPE xla_ae_headers_table IS TABLE OF psa_xla_ae_headers_logs%ROWTYPE;

  TYPE xla_distribution_links_table IS TABLE OF psa_xla_dist_links_logs%ROWTYPE;

  TYPE bc_pkts_rec IS TABLE OF gl_bc_packets%rowtype;
  g_bc_pkts_hist bc_pkts_rec;

  TYPE ae_lines_gt_rec is TABLE of xla_ae_lines_gt%rowtype;
  TYPE validation_lines_gt_rec is TABLE of xla_validation_lines_gt%rowtype;
  g_ae_lines_gt_rec ae_lines_gt_rec;
  g_validation_lines_gt_rec validation_lines_gt_rec;

  TYPE num_rec IS TABLE OF NUMBER(15);
  g_debug VARCHAR2(32000);

  -- To be called by SLA only
  PROCEDURE sync_xla_errors (p_failed_ldgr_array IN num_rec,
                             p_failed_evnt_array IN num_rec);


END PSA_FUNDS_CHECKER_PKG;

/
