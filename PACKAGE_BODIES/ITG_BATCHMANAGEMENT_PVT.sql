--------------------------------------------------------
--  DDL for Package Body ITG_BATCHMANAGEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITG_BATCHMANAGEMENT_PVT" AS
/* ARCS: $Header: itgbmgrb.pls 115.0 2003/01/31 18:32:31 ecoe noship $
 * CVS:  itgbmgrd.pls,v 1.13 2002/12/23 21:20:30 ecoe Exp
 */

  G_PKG_NAME     CONSTANT VARCHAR2(30) := 'ITG_BatchManagement_PVT';

  PROCEDURE Get_ProcessSetId(
    p_api_version      IN         NUMBER,
    x_return_status    OUT NOCOPY VARCHAR2,

    p_pkg_name         IN         VARCHAR2,
    x_process_set_id   OUT NOCOPY NUMBER
  ) IS
  BEGIN
    ITG_Debug.msg('GPSI', 'Top of debug procedure.');
    ITG_Debug.msg('GPSI', 'p_pkg_name', p_pkg_name);
    x_return_status  := FND_API.G_RET_STS_SUCCESS;
    x_process_set_id := 1;
  END Get_ProcessSetId;

  PROCEDURE Flush_RequestItems(
    p_api_version      IN         NUMBER,
    x_return_status    OUT NOCOPY VARCHAR2,

    p_pkg_name         IN         VARCHAR2,
    p_get_next	       IN         VARCHAR2 := FND_API.G_FALSE,
    x_process_set_id   OUT NOCOPY NUMBER
  ) IS
  BEGIN
    ITG_Debug.msg('FRI', 'Top of debug procedure.');
    ITG_Debug.msg('FRI', 'p_pkg_name', p_pkg_name);
    ITG_Debug.msg('FRI', 'p_get_next', p_get_next);
    x_return_status  := FND_API.G_RET_STS_SUCCESS;
    x_process_set_id := 1;
  END Flush_RequestItems;

  PROCEDURE Added_RequestItem(
    p_api_version      IN         NUMBER,
    x_return_status    OUT NOCOPY VARCHAR2,

    p_pkg_name         IN         VARCHAR2,
    p_transaction_id   IN         NUMBER,
    p_item_info        IN         VARCHAR2
  ) IS
    l_api_name    CONSTANT VARCHAR2(30) := 'Added_RequestItem';

    l_ccm_request_id       NUMBER;
    l_bool		   BOOLEAN;
    l_phase		   VARCHAR2(400);
    l_status		   VARCHAR2(400);
    l_dev_phase		   VARCHAR2(400);
    l_dev_status	   VARCHAR2(400);
    l_errmsg		   VARCHAR2(4000);
    l_reap_status	   NUMBER;
  BEGIN
    ITG_Debug.msg('ARI', 'Top of debug procedure.');
    ITG_Debug.msg('ARI', 'p_pkg_name',       p_pkg_name);
    ITG_Debug.msg('ARI', 'p_transaction_id', p_transaction_id);

    EXECUTE IMMEDIATE
        'BEGIN :1 := '||p_pkg_name||'.Start_BatchProcess(1); END;'
      USING OUT l_ccm_request_id;
    COMMIT;

    /* This was pulled from the original sync item code */
    ITG_Debug.msg('ARI', 'Waiting for concurrent request.');
    ITG_Debug.msg('ARI', 'l_ccm_request_id', l_ccm_request_id);
    l_bool := FND_CONCURRENT.wait_for_request(l_ccm_request_id, 60, 600,
	   l_phase, l_status, l_dev_phase, l_dev_status, l_errmsg);
    ITG_Debug.msg('ARI', 'Results from concurrent request.');
    ITG_Debug.msg('ARI', 'l_phase',      l_phase);
    ITG_Debug.msg('ARI', 'l_status',     l_status);
    ITG_Debug.msg('ARI', 'l_dev_phase',  l_dev_phase);
    ITG_Debug.msg('ARI', 'l_dev_status', l_dev_status);
    ITG_Debug.msg('ARI', 'l_errmsg',     l_errmsg);

    IF l_bool THEN
      ITG_Debug.msg('ARI', 'Reaping batch results.');
      EXECUTE IMMEDIATE
          'BEGIN :1 := '||p_pkg_name||
	  '.Reap_BatchResults(1, :2, :3, 0); END;'
        USING OUT l_reap_status,
	      IN  l_ccm_request_id,
	      IN  p_item_info;

      /* Check for ITG wrapper. */
      DECLARE
	CURSOR check_pkg(p_pkgname VARCHAR2) IS
	  SELECT status
	  FROM   user_objects
	  WHERE  object_name = UPPER(p_pkgname)
	  AND    object_type = 'PACKAGE';

        l_pkgstat VARCHAR2(30) := NULL;
	l_found   BOOLEAN;
	l_active  NUMBER       := 0;
      BEGIN
        ITG_Debug.msg('ARI', 'Checking for wrapper package.');
	OPEN  check_pkg('ITG_BOAPI_Wrappers');
	FETCH check_pkg INTO l_pkgstat;
	l_found := check_pkg%FOUND;
	CLOSE check_pkg;

	IF l_found AND l_pkgstat = 'VALID' THEN
	  ITG_Debug.msg('ARI', 'Checking for active wrapper.');
	  EXECUTE IMMEDIATE
	      'BEGIN :1 := ITG_BOAPI_Wrappers.g_active; END;'
	    USING OUT l_active;
	  IF l_active <> 0 THEN
	    ITG_Debug.msg('ARI', 'Reaping messages.');
	    EXECUTE IMMEDIATE
		'BEGIN ITG_BOAPI_Wrappers.Reap_Messages(:1); END;'
	      USING IN p_transaction_id;
          END IF;
	END IF;
      EXCEPTION
        WHEN OTHERS THEN
	  ITG_Debug.msg('ARI', 'Other error: '||substr(sqlerrm, 1, 1800));
      END;
    ELSE
      ITG_Debug.msg(substr(l_errmsg, 1, 2000), TRUE);
    END IF;
    x_return_status  := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      ITG_Debug.add_exc_error(
        G_PKG_NAME, l_api_name, FND_MSG_PUB.G_MSG_LVL_ERROR);
      ITG_Debug.msg('ARI', 'EXCEPTION, no data found.', TRUE);

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      ITG_Debug.add_error;
      ITG_Debug.msg('ARI', 'EXCEPTION, checked error.', TRUE);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ITG_Debug.msg('ARI', 'EXCEPTION, un-expected error.', TRUE);

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ITG_Debug.add_exc_error(G_PKG_NAME, l_api_name);
      ITG_Debug.msg('ARI', 'EXCEPTION, other error.', TRUE);
  END Added_RequestItem;

  /* WF activities */

  /* In the debug/development version use of workflow is an error */

  PROCEDURE wf_check_batch_timeout(
    itemtype  IN         VARCHAR2,
    itemkey   IN         VARCHAR2,
    actid     IN         NUMBER,
    funcmode  IN         VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
  ) IS
  BEGIN
    resultout := 'ERROR';
  END wf_check_batch_timeout;

  PROCEDURE wf_get_batch_info(
    itemtype  IN         VARCHAR2,
    itemkey   IN         VARCHAR2,
    actid     IN         NUMBER,
    funcmode  IN         VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
  ) IS
  BEGIN
    resultout := 'ERROR';
  END wf_get_batch_info;

  PROCEDURE wf_start_batch(
    itemtype  IN         VARCHAR2,
    itemkey   IN         VARCHAR2,
    actid     IN         NUMBER,
    funcmode  IN         VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
  ) IS
  BEGIN
    resultout := 'ERROR';
  END wf_start_batch;

  PROCEDURE wf_restart_batch(
    itemtype  IN         VARCHAR2,
    itemkey   IN         VARCHAR2,
    actid     IN         NUMBER,
    funcmode  IN         VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
  ) IS
  BEGIN
    resultout := 'ERROR';
  END wf_restart_batch;

  PROCEDURE wf_complete_batch(
    itemtype  IN         VARCHAR2,
    itemkey   IN         VARCHAR2,
    actid     IN         NUMBER,
    funcmode  IN         VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
  ) IS
  BEGIN
    resultout := 'ERROR';
  END wf_complete_batch;

END ITG_BatchManagement_PVT;

/
