--------------------------------------------------------
--  DDL for Package ARP_DISTRIBUTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_DISTRIBUTIONS_PKG" AUTHID CURRENT_USER AS
/*$Header: ARJIDSTS.pls 120.3 2002/12/17 23:13:32 anukumar ship $*/

--
-- Public procedures/functions
--
PROCEDURE insert_p( p_dist_rec   IN ar_distributions%ROWTYPE,
		    p_line_id  OUT NOCOPY ar_distributions.line_id%TYPE );

PROCEDURE update_p( p_dist_rec   IN ar_distributions%ROWTYPE );

PROCEDURE delete_p( p_line_id IN ar_distributions.line_id%TYPE );

PROCEDURE lock_p( p_line_id IN ar_distributions.line_id%TYPE );

PROCEDURE fetch_p( p_line_id IN ar_distributions.line_id%TYPE,
        	   p_dist_rec OUT NOCOPY ar_distributions%ROWTYPE );

PROCEDURE fetch_pk( p_source_id		IN ar_distributions.source_id%TYPE,
		    p_source_table	IN ar_distributions.source_table%TYPE,
		    p_source_type	IN ar_distributions.source_type%TYPE,
        	   p_dist_rec OUT NOCOPY ar_distributions%ROWTYPE );

PROCEDURE lock_fetch_pk( p_source_id	IN ar_distributions.source_id%TYPE,
		    p_source_table	IN ar_distributions.source_table%TYPE,
		    p_source_type	IN ar_distributions.source_type%TYPE,
        	   p_dist_rec OUT NOCOPY ar_distributions%ROWTYPE );

PROCEDURE nowaitlock_fetch_pk( p_source_id
					IN ar_distributions.source_id%TYPE,
		    p_source_table	IN ar_distributions.source_table%TYPE,
		    p_source_type	IN ar_distributions.source_type%TYPE,
        	   p_dist_rec OUT NOCOPY ar_distributions%ROWTYPE );


END ARP_DISTRIBUTIONS_PKG;

 

/
