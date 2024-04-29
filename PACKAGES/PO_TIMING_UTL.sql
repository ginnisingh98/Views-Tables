--------------------------------------------------------
--  DDL for Package PO_TIMING_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_TIMING_UTL" AUTHID CURRENT_USER AS
/* $Header: PO_TIMING_UTL.pls 120.0 2005/07/20 10:54 bao noship $ */

PROCEDURE init;

PROCEDURE start_time
( p_module IN VARCHAR2
);

PROCEDURE stop_time
( p_module IN VARCHAR2
);

PROCEDURE get_formatted_timing_info
( p_cleanup IN VARCHAR2
, x_timing_info OUT NOCOPY PO_TBL_VARCHAR4000
);

END PO_TIMING_UTL;

 

/
