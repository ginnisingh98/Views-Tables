--------------------------------------------------------
--  DDL for Package Body BSC_BIS_DIM_GROUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_BIS_DIM_GROUP_PUB" AS
/* $Header: BSCCPMDB.pls 120.0 2005/06/01 16:28:34 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISCPMDB.pls                                                      |
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
)IS
    l_return_status  VARCHAR2(30);
    l_count          NUMBER;
    l_dimension_rec  BIS_DIMENSION_PUB.Dimension_Rec_Type;
    l_error_tbl      BIS_UTILITIES_PUB.Error_Tbl_Type;
    l_msg_data       VARCHAR2(2000);

    CURSOR  cr_dim_id IS
    SELECT  dimension_id, short_name
    FROM    bis_dimensions
    WHERE   dimension_id = p_dimension_id;

    CURSOR  cr_dim_short_name IS
    SELECT  dimension_id, short_name
    FROM    bis_dimensions
    WHERE   short_name = p_short_name;

BEGIN

    --check for not null fields
    IF (p_dimension_id IS NOT NULL) THEN
        IF (cr_dim_id%ISOPEN) THEN
            CLOSE cr_dim_id;
        END IF;
        OPEN    cr_dim_id;
        FETCH   cr_dim_id
        INTO    l_dimension_rec.dimension_id
              , l_dimension_rec.dimension_short_name;
            IF (cr_dim_id%ROWCOUNT = 0) THEN
                l_msg_data      := 'Record does not exist for BIS_DIMENSIONS.DIMENSION_ID =<'||p_dimension_id||'>';
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        CLOSE cr_dim_id;
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    ELSIF (p_short_name IS NOT NULL) THEN
        IF (cr_dim_short_name%ISOPEN) THEN
            CLOSE cr_dim_short_name;
        END IF;
        OPEN    cr_dim_short_name;
        FETCH   cr_dim_short_name
        INTO    l_dimension_rec.dimension_id
              , l_dimension_rec.dimension_short_name;
            IF (cr_dim_short_name%ROWCOUNT = 0) THEN
                l_msg_data      := 'Record does not exist for BIS_DIMENSIONS.SHORT_NAME =<'||p_short_name||'>';
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        CLOSE cr_dim_short_name;
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    ELSE
        l_msg_data  :=  'Either of P_DIMENSION_ID or P_SHORT_NAME must be NOT NULL';
        RAISE           FND_API.G_EXC_ERROR;
    END IF;

    IF (p_display_name IS NULL) THEN
        l_msg_data  :=  'P_DISPLAY_NAME must be NOT NULL';
        RAISE           FND_API.G_EXC_ERROR;
    END IF;

    --check for uniqueness of p_display_name
    SELECT  COUNT(*) INTO l_count FROM bis_dimensions_vl
    WHERE   name            =   p_display_name
    AND     dimension_id   <>   l_dimension_rec.dimension_id;
    IF (l_count > 0) THEN
        l_msg_data  :=  'P_DISPLAY_NAME =<'||p_display_name||'> must be UNIQUE';
        RAISE           FND_API.G_EXC_ERROR;
    END IF;

    --call PMF's API
    l_dimension_rec.Dimension_Name           :=  p_display_name;
    l_dimension_rec.Description              :=  p_description;

    BIS_DIMENSION_PUB.Update_Dimension
    (
            p_api_version           =>  1.0
        ,   p_commit                =>  FND_API.G_FALSE
        ,   p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL
        ,   p_Dimension_Rec         =>  l_dimension_rec
        ,   x_return_status         =>  l_return_status
        ,   x_error_Tbl             =>  l_error_tbl
    );
    IF ((l_return_status  =  FND_API.G_RET_STS_SUCCESS)  OR (l_return_status IS NULL) OR
            ((l_return_status <>  FND_API.G_RET_STS_ERROR)  AND
            (l_return_status <>  FND_API.G_RET_STS_UNEXP_ERROR))) THEN
        x_return_status  :=  FND_API.G_RET_STS_SUCCESS;
        IF (p_commit = FND_API.G_TRUE) THEN
            COMMIT;
        END if;
    ELSE
        IF (l_error_tbl.COUNT > 0) THEN
            l_msg_data  :=  l_error_tbl(l_error_tbl.COUNT).Error_Description;
        END IF;

        l_msg_data  := 'BSC_BIS_DIM_GROUP_PUB.UPDATE_DIMENSION Failed : at BIS_DIMENSION_PUB.UPDATE_DIMENSION <'||l_msg_data||'>';
        RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (cr_dim_id%ISOPEN) THEN
            CLOSE cr_dim_id;
        END IF;
        IF (cr_dim_short_name%ISOPEN) THEN
            CLOSE cr_dim_short_name;
        END IF;
        ROLLBACK;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        x_msg_data      :=  l_msg_data;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (cr_dim_id%ISOPEN) THEN
            CLOSE cr_dim_id;
        END IF;
        IF (cr_dim_short_name%ISOPEN) THEN
            CLOSE cr_dim_short_name;
        END IF;
        ROLLBACK;
        FND_MSG_PUB.Count_And_Get
        (
               p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data      :=  x_msg_data||' '||l_msg_data;
    WHEN NO_DATA_FOUND THEN
        IF (cr_dim_id%ISOPEN) THEN
            CLOSE cr_dim_id;
        END IF;
        IF (cr_dim_short_name%ISOPEN) THEN
            CLOSE cr_dim_short_name;
        END IF;
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
        (
               p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
    WHEN OTHERS THEN
        IF (cr_dim_id%ISOPEN) THEN
            CLOSE cr_dim_id;
        END IF;
        IF (cr_dim_short_name%ISOPEN) THEN
            CLOSE cr_dim_short_name;
        END IF;
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
        (
               p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
END UPDATE_DIMENSION;

END BSC_BIS_DIM_GROUP_PUB;

/
