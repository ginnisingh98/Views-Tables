--------------------------------------------------------
--  DDL for Package GMD_DISP_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_DISP_GRP" AUTHID CURRENT_USER AS
/* $Header: GMDGDISS.pls 120.0.12010000.1 2009/03/31 18:23:08 rnalla noship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDGDISS.pls                                        |
--| Package Name       : GMD_DISP_GRP                                        |
--| Type               : Group                                               |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains Group layer APIs for Changing the disposition   |
--|    of a Sample/Group                                                     |
--|                                                                          |
--| HISTORY                                                                  |
--|     Ravi Lingappa Nagaraja    16-Jun-2008     Created.                   |
--+==========================================================================+
-- End of comments

PROCEDURE update_sample_comp_disp
(
  p_update_disp_rec	        IN Gmd_Samples_Grp.update_disp_rec
, p_to_disposition		IN         VARCHAR2
, x_return_status 		OUT NOCOPY VARCHAR2
, x_message_data		OUT NOCOPY VARCHAR2
);

PROCEDURE update_lot_grade_batch
(
  p_sample_id			IN         NUMBER DEFAULT NULL
, p_composite_spec_disp_id  	IN         NUMBER DEFAULT NULL
, p_to_lot_status_id	  	IN         NUMBER
, p_from_lot_status_id	  	IN         NUMBER
, p_to_grade_code		IN         VARCHAR2
, p_from_grade_code		IN         VARCHAR2 DEFAULT NULL
, p_to_qc_status		IN         NUMBER
, p_reason_id			IN         NUMBER
, p_hold_date                   IN         DATE DEFAULT SYSDATE
, x_return_status 		OUT NOCOPY VARCHAR2
, x_message_data		OUT NOCOPY VARCHAR2
);

END gmd_disp_grp;


/
