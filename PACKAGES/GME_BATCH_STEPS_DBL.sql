--------------------------------------------------------
--  DDL for Package GME_BATCH_STEPS_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_BATCH_STEPS_DBL" AUTHID CURRENT_USER AS
/*  $Header: GMEVGBSS.pls 120.0 2005/05/26 14:34:00 appldev noship $    */
/* ===========================================================================
 |                Copyright (c) 2001 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 ===========================================================================
 |  FILENAME                                                               |
 |      GMEVGBSS.pls                                                       |
 |                                                                         |
 |  DESCRIPTION                                                            |
 |                                                                         |
 |      Spec of package gme_batch_steps_dbl                                |
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
 |                                                                         |
 |                                                                         |

 ===========================================================================
*/
	FUNCTION insert_row
	(  p_batch_step IN gme_batch_steps%ROWTYPE
	,  x_batch_step IN OUT NOCOPY gme_batch_steps%ROWTYPE
	)
        RETURN BOOLEAN;

        FUNCTION fetch_row
	(  p_batch_step IN gme_batch_steps%ROWTYPE
	,  x_batch_step IN OUT NOCOPY gme_batch_steps%ROWTYPE
        )
        RETURN BOOLEAN;

        FUNCTION delete_row
        (p_batch_step IN gme_batch_steps%ROWTYPE
        )
        RETURN BOOLEAN;

        FUNCTION update_row
        (p_batch_step IN gme_batch_steps%ROWTYPE
        )
        RETURN BOOLEAN;

        FUNCTION lock_row
        (p_batch_step IN gme_batch_steps%ROWTYPE
        )
        RETURN BOOLEAN;

END;

 

/
