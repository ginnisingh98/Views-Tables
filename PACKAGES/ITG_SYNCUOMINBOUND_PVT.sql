--------------------------------------------------------
--  DDL for Package ITG_SYNCUOMINBOUND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ITG_SYNCUOMINBOUND_PVT" AUTHID CURRENT_USER AS
/* ARCS: $Header: itgvsuis.pls 120.1 2005/10/06 02:11:36 bsaratna noship $
 * CVS:  itgvsuis.pls,v 1.8 2002/12/23 21:20:30 ecoe Exp
 */

  PROCEDURE Sync_UOM_All(
    x_return_status    OUT NOCOPY VARCHAR2,         /* VARCHAR2(1) */
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,         /* VARCHAR2(2000) */

    p_task             IN         VARCHAR2,
    p_syncind          IN         VARCHAR2,
    p_uom              IN         VARCHAR2 := NULL,
    p_uomcode          IN         VARCHAR2 := NULL,
    p_uomclass         IN         VARCHAR2 := NULL,
    p_buomflag         IN         VARCHAR2 := NULL,
    p_description      IN         VARCHAR2 := NULL,
    p_defconflg        IN         VARCHAR2 := NULL,
    p_fromcode         IN         VARCHAR2 := NULL,
    p_touomcode        IN         VARCHAR2 := NULL,
    p_itemid           IN         NUMBER   := NULL,
    p_fromfactor       IN         VARCHAR2 := NULL,
    p_tofactor         IN         VARCHAR2 := NULL,
    p_dt_creation      IN         DATE     := NULL,
    p_dt_expiration    IN         DATE     := NULL
  ) ;

END ITG_SyncUOMInbound_PVT;

 

/
