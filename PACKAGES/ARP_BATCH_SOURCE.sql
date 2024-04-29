--------------------------------------------------------
--  DDL for Package ARP_BATCH_SOURCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_BATCH_SOURCE" AUTHID CURRENT_USER AS
/* $Header: ARPLBSUS.pls 120.2 2005/10/30 04:24:19 appldev ship $ */


/*---------------------------------------------------------------------------+
 | PUBLIC PROCEDURE                                                          |
 |    create_trx_sequence                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function dynamically creates trx_number sequences for batch       |
 |    sources with automatic transaction numbering. It calls the             |
 |    bb_dist.create_sequence() procedure so that this will work in          |
 |    distributed environments.                                              |
 |                                                                           |
 | REQUIRES                                                                  |
 |   p_batch_source_id							     |
 |   P_last_number 							     |
 |                                                                           |
 | KNOWN BUGS                                                                |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | HISTORY                                                                   |
 |    9-DEC-94  Charlie Tomberg   Created.				     |
 |                                                                           |
 +---------------------------------------------------------------------------*/

 PROCEDURE create_trx_sequence (
				 P_batch_source_id   IN   number,
				 P_org_id           IN   number default null, --SSA changes anukumar
				 P_last_number       IN   number
			       );


END ARP_BATCH_SOURCE;

 

/
