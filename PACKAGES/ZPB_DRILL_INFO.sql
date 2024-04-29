--------------------------------------------------------
--  DDL for Package ZPB_DRILL_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_DRILL_INFO" AUTHID CURRENT_USER AS
/* $Header: zpbdrill.pls 120.2 2007/12/04 15:26:06 mbhat noship $ */
  procedure get_drill_info ( p_view        IN  VARCHAR2
                           , p_drill_info  IN  VARCHAR2
                           , x_drill_value OUT NOCOPY VARCHAR2
                           , x_result      OUT NOCOPY VARCHAR2
                           , x_msg_out     OUT NOCOPY VARCHAR2) ;

END zpb_drill_info ;

/
