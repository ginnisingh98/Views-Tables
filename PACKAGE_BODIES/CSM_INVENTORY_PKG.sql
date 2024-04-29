--------------------------------------------------------
--  DDL for Package Body CSM_INVENTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_INVENTORY_PKG" AS
/* $Header: csmuinvb.pls 120.1 2005/07/25 01:13:12 trajasek noship $ */

-- MODIFICATION HISTORY
-- Person      Date    Comments
-- RaviRanjan  09/05/03 Created
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below


/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSM_INVENTORY_PKG';  -- package name
g_pub_name     CONSTANT VARCHAR2(30) := 'CSF_M_INVENTORY';  -- publication item name
g_debug_level           NUMBER; -- debug level

CURSOR c_inventory( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT *
  FROM  csf_m_inventory_inq
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name;

/***
  This procedure is called by CSM_UTIL_PKG when publication item <replace>
  is dirty. This happens when a mobile field service device executed DML on an updatable table and did
  a fast sync. This procedure will insert the data that came from mobile into the backend tables using
  public APIs.
***/
PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS

  l_process_status VARCHAR2(1);
  l_error_msg      VARCHAR2(4000);
BEGIN
  g_debug_level := p_debug_level;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*** loop through debrief labor records in inqueue ***/
  FOR r_inventory IN c_inventory( p_user_name, p_tranid) LOOP

    SAVEPOINT save_rec;

    CSM_UTIL_PKG.DELETE_RECORD
      (
        p_user_name,
        p_tranid,
        r_inventory.seqno$$,
        r_inventory.gen_pk,
        g_object_name,
        g_pub_name,
        l_error_msg,
        l_process_status
      );

    /*** was delete successful? ***/
    IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** no -> rollback ***/
        CSM_UTIL_PKG.LOG
        ( 'Deleting from inqueue failed, rolling back to savepoint'
    || ' for PK ' || r_inventory.gen_pk ,'CSM_INVENTORY_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here
      ROLLBACK TO save_rec;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

  END LOOP;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
    CSM_UTIL_PKG.LOG
    ( 'Exception occurred in APPLY_CLIENT_CHANGES:' || ' ' || SQLERRM ,'CSM_INVENTORY_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_EXCEPTION);
    x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_CLIENT_CHANGES;

END CSM_INVENTORY_PKG;

/
