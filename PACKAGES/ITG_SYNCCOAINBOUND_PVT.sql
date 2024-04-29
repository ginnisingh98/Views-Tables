--------------------------------------------------------
--  DDL for Package ITG_SYNCCOAINBOUND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ITG_SYNCCOAINBOUND_PVT" AUTHID CURRENT_USER AS
/* ARCS: $Header: itgvscis.pls 120.1 2005/10/06 02:05:25 bsaratna noship $
 * CVS:  itgvscis.pls,v 1.9 2002/12/23 21:20:30 ecoe Exp
 */

  /* SEE AFQUTILB.pls: FND_IP_UTIL_PKG.processFlexValue() */

  PROCEDURE Add_FlexValue(
    x_return_status    OUT NOCOPY VARCHAR2,           /* VARCHAR2(1) */
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,           /* VARCHAR2(2000) */

    p_flex_value       IN         VARCHAR2,
    p_vset_id          IN         NUMBER,
    p_flex_desc        IN         VARCHAR2,
    p_creation_date    IN         DATE     := NULL,
    p_effective_date   IN         DATE,
    p_expiration_date  IN         DATE,
    p_acct_type        IN         VARCHAR2,
    p_enabled_flag     IN         VARCHAR2
  );

  PROCEDURE Change_FlexValue(
    x_return_status    OUT NOCOPY VARCHAR2,           /* VARCHAR2(1) */
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,           /* VARCHAR2(2000) */

    p_flex_value       IN         VARCHAR2,
    p_vset_id          IN         NUMBER,
    p_flex_desc        IN         VARCHAR2,
    p_update_date      IN         DATE     := NULL,
    p_effective_date   IN         DATE,
    p_expiration_date  IN         DATE,
    p_enabled_flag     IN         VARCHAR2
  );

  PROCEDURE Sync_FlexValue(

    x_return_status    OUT NOCOPY VARCHAR2,           /* VARCHAR2(1) */
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,           /* VARCHAR2(2000) */

    p_syncind          IN         VARCHAR2,	       /* 'A'dd or 'C'hange */
    p_flex_value       IN         VARCHAR2,
    p_vset_id          IN         NUMBER,
    p_flex_desc        IN         VARCHAR2,
    p_action_date      IN         DATE     := NULL,
    p_effective_date   IN         DATE,
    p_expiration_date  IN         DATE,
    p_acct_type        IN         VARCHAR2,
    p_enabled_flag     IN         VARCHAR2
  );

END ITG_SyncCOAInbound_PVT;

 

/
