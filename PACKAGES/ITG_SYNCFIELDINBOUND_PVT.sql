--------------------------------------------------------
--  DDL for Package ITG_SYNCFIELDINBOUND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ITG_SYNCFIELDINBOUND_PVT" AUTHID CURRENT_USER AS
/* ARCS: $Header: itgvsfis.pls 120.1 2005/10/06 02:07:15 bsaratna noship $
 * CVS:  itgvsfis.pls,v 1.7 2002/12/23 21:20:30 ecoe Exp
 */
  PROCEDURE Process_PoNumber(
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,

    p_reqid            IN         NUMBER,
    p_reqlinenum       IN         NUMBER,
    p_poid             IN         NUMBER,
    p_org              IN         NUMBER
  );

END ITG_SyncFieldInbound_PVT;

 

/
