--------------------------------------------------------
--  DDL for Package ITG_BATCHMANAGEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ITG_BATCHMANAGEMENT_PVT" AUTHID CURRENT_USER AS
/* ARCS: $Header: itgbmgrs.pls 115.0 2003/01/31 18:32:39 ecoe noship $
 * CVS:  itgbmgrs.pls,v 1.7 2002/12/23 21:20:30 ecoe Exp
 */

  /* Public (client-side) API */

  PROCEDURE Get_ProcessSetId(
    p_api_version      IN         NUMBER,
    x_return_status    OUT NOCOPY VARCHAR2,

    p_pkg_name         IN         VARCHAR2,
    x_process_set_id   OUT NOCOPY NUMBER
  );

  PROCEDURE Flush_RequestItems(
    p_api_version      IN         NUMBER,
    x_return_status    OUT NOCOPY VARCHAR2,

    p_pkg_name         IN         VARCHAR2,
    p_get_next	       IN         VARCHAR2 := FND_API.G_FALSE,
    x_process_set_id   OUT NOCOPY NUMBER
  );

  PROCEDURE Added_RequestItem(
    p_api_version      IN         NUMBER,
    x_return_status    OUT NOCOPY VARCHAR2,

    p_pkg_name         IN         VARCHAR2,
    p_transaction_id   IN         NUMBER,
    p_item_info        IN         VARCHAR2
  );

  /* WF activities */

  /* IN:     IMP_PKG_NAME
   *
   * OUT:    none
   *
   * ACTION: Closes current batch if timed out, with autonomous commit.
   */
  PROCEDURE wf_check_batch_timeout(
    itemtype  IN         VARCHAR2,
    itemkey   IN         VARCHAR2,
    actid     IN         NUMBER,
    funcmode  IN         VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
  );

  /* IN:     IMP_PKG_NAME
   *
   * OUT:    BATCH_CLASS_ID
   *	     REPORTING_PROC
   *	     PEND_REQ_ID
   *	     PEND_COUNT
   *	     RUN_REQ_ID
   *	     RUN_CCM_ID
   *
   * ACTION: Loads of computes these values from batch tables.
   *	     Locks batch class.
   */

  PROCEDURE wf_get_batch_info(
    itemtype  IN         VARCHAR2,
    itemkey   IN         VARCHAR2,
    actid     IN         NUMBER,
    funcmode  IN         VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
  );

  /* IN:     IMP_PKG_NAME
   *	     PEND_REQ_ID
   *
   * OUT:    none
   *
   * ACTION: Starts a pending batch, updating batch tables to match.
   */
  PROCEDURE wf_start_batch(
    itemtype  IN         VARCHAR2,
    itemkey   IN         VARCHAR2,
    actid     IN         NUMBER,
    funcmode  IN         VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
  );

  /* IN:     IMP_PKG_NAME
   *	     RUN_REQ_ID
   *
   * OUT:    none
   *
   * ACTION: Restarts a stopped batch, updating batch tables to match.
   */
  PROCEDURE wf_restart_batch(
    itemtype  IN         VARCHAR2,
    itemkey   IN         VARCHAR2,
    actid     IN         NUMBER,
    funcmode  IN         VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
  );

  /* IN:     IMP_PKG_NAME
   *         REPORTING_PROC
   *	     RUN_REQ_ID
   *	     RUN_CCM_ID
   *	     RECOVERY
   *
   * OUT:    MORE_ITEMS
   *
   * ACTION: Clean up and reap results of batch. Indicate is batch run is
   *         incomplete and needs a restart (if recovery is set).
   */
  PROCEDURE wf_complete_batch(
    itemtype  IN         VARCHAR2,
    itemkey   IN         VARCHAR2,
    actid     IN         NUMBER,
    funcmode  IN         VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
  );

END ITG_BatchManagement_PVT;

 

/
