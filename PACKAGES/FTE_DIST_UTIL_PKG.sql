--------------------------------------------------------
--  DDL for Package FTE_DIST_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_DIST_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: FTEDISXS.pls 115.1 2003/09/13 19:45:58 ablundel noship $ */


TYPE fte_id_tmp_num_table      IS TABLE OF NUMBER         INDEX BY BINARY_INTEGER;


-- ------------------------------------------------------------------------------------------- --
--                                                                                             --
-- PROCEDURE DEFINITONS                                                                        --
-- --------------------                                                                        --
--                                                                                             --
-- ------------------------------------------------------------------------------------------- --
PROCEDURE DELETE_FILES_LINES(p_template_id                IN NUMBER,
                             x_return_message             OUT NOCOPY VARCHAR2,
                             x_return_status              OUT NOCOPY VARCHAR2);

FUNCTION GET_REGION_TYPE RETURN NUMBER;

PROCEDURE GET_DIST_PROFILE (x_profile_value OUT NOCOPY VARCHAR2);

END FTE_DIST_UTIL_PKG;

 

/
