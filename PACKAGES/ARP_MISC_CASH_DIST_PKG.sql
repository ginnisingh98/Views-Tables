--------------------------------------------------------
--  DDL for Package ARP_MISC_CASH_DIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_MISC_CASH_DIST_PKG" AUTHID CURRENT_USER AS
/*$Header: ARRIMCDS.pls 120.4 2005/10/30 04:24:57 appldev ship $*/

--
-- Public procedures/functions
--
PROCEDURE insert_p( p_mcd_rec   IN ar_misc_cash_distributions%ROWTYPE,
		    p_mcd_id    OUT NOCOPY ar_misc_cash_distributions.misc_cash_distribution_id%TYPE  );

PROCEDURE update_p( p_mcd_rec   IN ar_misc_cash_distributions%ROWTYPE );

PROCEDURE delete_p( p_mcd_id IN ar_misc_cash_distributions.misc_cash_distribution_id%TYPE );

PROCEDURE lock_p( p_mcd_id IN ar_misc_cash_distributions.misc_cash_distribution_id%TYPE );

PROCEDURE fetch_p( p_mcd_id IN ar_misc_cash_distributions.misc_cash_distribution_id%TYPE,
 	           p_mcd_rec OUT NOCOPY ar_misc_cash_distributions%ROWTYPE );

PROCEDURE nowaitlock_fetch_p( p_mcd_id IN ar_misc_cash_distributions.misc_cash_distribution_id%TYPE,
 	           p_mcd_rec OUT NOCOPY ar_misc_cash_distributions%ROWTYPE );


END ARP_MISC_CASH_DIST_PKG;

 

/
