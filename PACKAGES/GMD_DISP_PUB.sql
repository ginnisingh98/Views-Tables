--------------------------------------------------------
--  DDL for Package GMD_DISP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_DISP_PUB" AUTHID CURRENT_USER AS
/* $Header: GMDPDISS.pls 120.1.12010000.2 2009/06/08 17:18:49 plowe noship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDPDISB.pls                                        |
--| Package Name       : GMD_DISP_PUB                                        |
--| Type               : Public                                              |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains public layer APIs for Changing the disposition  |
--|    of a Sample/Group                                                     |
--|									     |
--| HISTORY                                                                  |
--|     Ravi Lingappa Nagaraja    16-Jun-2008     Created                    |
--|     P Lowe                    19-May-2009     bug 8528505                |
--|     Changed TYPE change_disp_rec IS RECORD is spec to correct size       |
--| The correct size of fields in tables are:
--| to_lot_status VARCHAR2(10) -- VARCHAR2(80)
--| to_grade_code VARCHAR2(10) -- VARCHAR2(150)
--| reason_code VARCHAR2(10) -- REASON_NAME VARCHAR2(30)
--| parent_lot_number VARCHAR2(32) -- VARCHAR2(80)
--| lot_number VARCHAR2(32) -- VARCHAR2(80)
--+==========================================================================+
-- End of comments


TYPE change_disp_rec IS RECORD
(
   sample_id              NUMBER
  ,sampling_event_id	  NUMBER
  ,to_lot_status	  VARCHAR2(80)
  ,to_grade_code	  VARCHAR2(150)
  ,to_disposition	  VARCHAR2(10)
  ,reason_code		  VARCHAR2(30)
  ,parent_lot_number      VARCHAR2(80)
  ,lot_number		  VARCHAR2(80)
  ,lpn                    VARCHAR2(32)
  ,lpn_id                 NUMBER
 );


PROCEDURE change_disposition (
 p_api_version          IN  NUMBER
,p_init_msg_list        IN  VARCHAR2        DEFAULT FND_API.G_FALSE
,p_commit               IN  VARCHAR2        DEFAULT FND_API.G_FALSE
,p_validation_level     IN  NUMBER          DEFAULT FND_API.G_VALID_LEVEL_FULL
,p_change_disp_rec   	IN  CHANGE_DISP_REC
,x_return_status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_data             OUT NOCOPY VARCHAR2
);


END gmd_disp_pub;


/
