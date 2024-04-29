--------------------------------------------------------
--  DDL for Package ITG_SYNCITEMINBOUND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ITG_SYNCITEMINBOUND_PVT" AUTHID CURRENT_USER AS
/* ARCS: $Header: itgvsiis.pls 120.1 2005/10/06 02:08:17 bsaratna noship $
 * CVS:  itgvsiis.pls,v 1.8 2002/12/23 21:20:30 ecoe Exp
 */

  PROCEDURE Sync_Item(
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,

    p_syncind          IN         VARCHAR2,		/* (1) */
    p_org_id           IN         NUMBER,		/* poentity */
    p_hazrdmatl        IN         VARCHAR2,
    p_create_date      IN         DATE     := NULL,
    p_item             IN         VARCHAR2,
    p_uom              IN         VARCHAR2,
    p_itemdesc         IN         VARCHAR2,
    p_itemstatus       IN         VARCHAR2,
    p_itemtype         IN         VARCHAR2,
    p_rctrout          IN         VARCHAR2,		/* ref_rctrout */
    p_commodity1       IN         VARCHAR2,
    p_commodity2       IN         VARCHAR2
  );

  /*
   * DO NOT USE!!
   * The following procedures and functions are not part of the ABO API.
   * They are internal callbacks from the batch management package.
   */

  FUNCTION Get_NextProcessSetId RETURN NUMBER;

  /* Returns CCM request id. */
  FUNCTION Start_BatchProcess(
    p_process_set_id    NUMBER,
    p_syncind		VARCHAR2,
    p_org_id	      VARCHAR2
  ) RETURN NUMBER;

  FUNCTION Reap_BatchResults(
    p_request_id        NUMBER,
    p_msii_rid		ROWID,
    p_mici_rid		ROWID
) RETURN VARCHAR2;

PROCEDURE error_transactions(p_request_id VARCHAR2,p_table_name VARCHAR2);


END ITG_SyncItemInbound_PVT;

 

/
