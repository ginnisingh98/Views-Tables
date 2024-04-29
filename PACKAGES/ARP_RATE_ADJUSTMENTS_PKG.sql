--------------------------------------------------------
--  DDL for Package ARP_RATE_ADJUSTMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_RATE_ADJUSTMENTS_PKG" AUTHID CURRENT_USER AS
/*$Header: ARRIRADS.pls 115.1 2002/11/15 03:04:55 anukumar ship $*/

--
-- Public procedures/functions
--
PROCEDURE insert_p( p_radj_rec   IN ar_rate_adjustments%ROWTYPE,
		    p_radj_id	 OUT NOCOPY ar_rate_adjustments.rate_adjustment_id%TYPE );

END ARP_RATE_ADJUSTMENTS_PKG;

 

/
