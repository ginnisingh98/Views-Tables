--------------------------------------------------------
--  DDL for Package BSC_BIS_DIM_GROUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_BIS_DIM_GROUP_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCCPMDS.pls 120.0 2005/06/01 15:51:02 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISCPMDS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Wrapper for Dimension, part of PMD APIs                   |
REM |                                                                       |
REM | NOTES                                                                 |
REM | 14-FEB-2003 PAJOHRI  Created.                                         |
REM |                                                                       |
REM +=======================================================================+
*/


/*********************************************************************************
                        UPDATE DIMENSION
*********************************************************************************/
PROCEDURE Update_Dimension
(
        p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_dimension_id          IN              NUMBER
    ,   p_short_name            IN              VARCHAR2
    ,   p_display_name          IN              VARCHAR2
    ,   p_description           IN              VARCHAR2
    ,   p_application_id        IN              NUMBER
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
);

END BSC_BIS_DIM_GROUP_PUB;

 

/
