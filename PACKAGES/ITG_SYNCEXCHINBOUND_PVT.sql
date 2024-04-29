--------------------------------------------------------
--  DDL for Package ITG_SYNCEXCHINBOUND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ITG_SYNCEXCHINBOUND_PVT" AUTHID CURRENT_USER AS
/* ARCS: $Header: itgvseis.pls 120.1 2005/10/06 02:06:23 bsaratna noship $
 * CVS:  itgvseis.pls,v 1.4 2002/12/23 21:20:30 ecoe Exp
 */

  PROCEDURE Process_ExchangeRate(
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,

    p_syncind          IN         VARCHAR2,
    p_quantity         IN         NUMBER,
    p_currency_from    IN         VARCHAR2,
    p_currency_to      IN         VARCHAR2,
    p_factor           IN         VARCHAR2,
    p_sob              IN         VARCHAR2,
    p_ratetype         IN         VARCHAR2,
    p_creation_date    IN         DATE,
    p_effective_date   IN         DATE
  );

END ITG_SyncExchInbound_PVT;

 

/
