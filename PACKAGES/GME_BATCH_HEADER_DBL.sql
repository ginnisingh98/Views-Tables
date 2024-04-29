--------------------------------------------------------
--  DDL for Package GME_BATCH_HEADER_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_BATCH_HEADER_DBL" AUTHID CURRENT_USER AS
/*  $Header: GMEVGBHS.pls 120.0 2005/05/26 14:43:46 appldev noship $    */
/* ===========================================================================
 |                Copyright (c) 2001 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 ===========================================================================
 |  FILENAME                                                               |
 |      GMEVBHMS.pls                                                       |
 |                                                                         |
 |  DESCRIPTION                                                            |
 |                                                                         |
 |      Spec of package gme_batch_header_dbl                               |
 |                                                                         |
 |  NOTES                                                                  |
 |                                                                         |
 |  HISTORY                                                                |
 |                                                                         |
 |  13-Feb-02 Created                                                      |
 |                                                                         |
 |             - create_row                                                |
 |             - fetch_row                                                 |
 |             - delete_row                                                |
 |             - update_row                                                |
 |                                                                         |
 |  08-May-2001 Added lock_row.                                            |
 |             - lock_row                                                  |
 |                                                                         |
 |                                                                         |

 ===========================================================================
*/
	FUNCTION insert_row
	(  p_batch_header IN gme_batch_header%ROWTYPE
	,  x_batch_header IN OUT NOCOPY gme_batch_header%ROWTYPE
	)
        RETURN BOOLEAN;

        FUNCTION fetch_row
	(  p_batch_header IN gme_batch_header%ROWTYPE
	,  x_batch_header IN OUT NOCOPY gme_batch_header%ROWTYPE
        )
        RETURN BOOLEAN;

        FUNCTION delete_row
        (p_batch_header IN gme_batch_header%ROWTYPE
        )
        RETURN BOOLEAN;

        FUNCTION update_row
        (p_batch_header IN gme_batch_header%ROWTYPE
        )
        RETURN BOOLEAN;

        FUNCTION lock_row
        (p_batch_header IN gme_batch_header%ROWTYPE
        )
        RETURN BOOLEAN;
END;

 

/
