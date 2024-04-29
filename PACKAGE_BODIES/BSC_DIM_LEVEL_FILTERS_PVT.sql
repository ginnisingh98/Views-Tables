--------------------------------------------------------
--  DDL for Package Body BSC_DIM_LEVEL_FILTERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_DIM_LEVEL_FILTERS_PVT" AS
/* $Header: BSCVFILB.pls 120.0.12000000.1 2007/07/17 07:44:42 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCVFILB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: This Package handle Common Dimension Level for Scorecards |
REM |                                                                       |
REM | NOTES                                                                 |
REM | 16-12-2006 PSOMESUL E#5678943 MIGRATE COMMON DIMENSIONS AND DIMENSION FILTERS TO SCORECARD DESIGNER|
REM +=======================================================================+
*/

PROCEDURE delete_filters
(
        p_tab_id         IN             NUMBER
       ,p_dim_level_id   IN             NUMBER
       ,p_commit         IN             VARCHAR2 := FND_API.G_FALSE
       ,x_return_status  OUT   NOCOPY   VARCHAR2
       ,x_msg_count      OUT   NOCOPY   NUMBER
       ,x_msg_data       OUT   NOCOPY   VARCHAR2
)
IS

BEGIN
IF (p_tab_id is not null and p_dim_level_id is not null) THEN
   DELETE
   FROM bsc_sys_filters
   WHERE source_type = 1
     AND source_code = p_tab_id
     AND dim_level_id = p_dim_level_id;
END IF;

IF (p_commit = FND_API.G_TRUE) THEN
  COMMIT;
END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );

        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        RAISE;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PVT.delete_filters ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PVT.delete_filters ';
        END IF;

        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PVT.delete_filters ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PVT.delete_filters ';
        END IF;

        RAISE;

END delete_filters;


PROCEDURE insert_filters
(
        p_source_type     IN             bsc_sys_filters.source_type%TYPE
       ,p_source_code     IN             bsc_sys_filters.source_code%TYPE
       ,p_dim_level_id    IN             bsc_sys_filters.dim_level_id%TYPE
       ,p_dim_level_value IN             bsc_sys_filters.dim_level_value%TYPE
       ,p_commit          IN             VARCHAR2 := FND_API.G_FALSE
       ,x_return_status   OUT   NOCOPY   VARCHAR2
       ,x_msg_count       OUT   NOCOPY   NUMBER
       ,x_msg_data        OUT   NOCOPY   VARCHAR2
)
IS
BEGIN
  IF (p_source_type IS NOT NULL AND p_source_code IS NOT NULL AND p_dim_level_id  IS NOT NULL AND p_dim_level_value IS NOT NULL) THEN
    INSERT
    INTO
    bsc_sys_filters(source_type,
                    source_code,
                    dim_level_id,
                    dim_level_value
                   )
            VALUES (p_source_type,
                    p_source_code ,
                    p_dim_level_id,
                    p_dim_level_value
                   );
    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );

        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        RAISE;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PVT.insert_filters ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PVT.insert_filters ';
        END IF;

        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PVT.insert_filters ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PVT.insert_filters ';
        END IF;

        RAISE;

END insert_filters;


PROCEDURE delete_filters_view
(
        p_tab_id         IN             NUMBER
       ,p_dim_level_id   IN             NUMBER
       ,p_commit         IN             VARCHAR2 := FND_API.G_FALSE
       ,x_return_status  OUT   NOCOPY   VARCHAR2
       ,x_msg_count      OUT   NOCOPY   NUMBER
       ,x_msg_data       OUT   NOCOPY   VARCHAR2
)
IS

BEGIN
IF (p_tab_id is not null and p_dim_level_id is not null) THEN
   DELETE
   FROM bsc_sys_filters_views
   WHERE source_type  = 1
     AND source_code  = p_tab_id
     AND dim_level_id = p_dim_level_id;
END IF;

IF (p_commit = FND_API.G_TRUE) THEN
  COMMIT;
END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );

        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        RAISE;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PVT.delete_filters_view ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PVT.delete_filters_view ';
        END IF;

        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PVT.delete_filters_view ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PVT.delete_filters_view ';
        END IF;

        RAISE;
END delete_filters_view;


PROCEDURE insert_filters_view
(
        p_source_type      IN            bsc_sys_filters_views.source_type%TYPE
       ,p_source_code      IN            bsc_sys_filters_views.source_code%TYPE
       ,p_dim_level_id     IN            bsc_sys_filters_views.dim_level_id%TYPE
       ,p_level_table_name IN            bsc_sys_filters_views.level_table_name%TYPE
       ,p_level_view_name  IN            bsc_sys_filters_views.level_view_name%TYPE
       ,p_commit           IN            VARCHAR2 := FND_API.G_FALSE
       ,x_return_status   OUT   NOCOPY   VARCHAR2
       ,x_msg_count       OUT   NOCOPY   NUMBER
       ,x_msg_data        OUT   NOCOPY   VARCHAR2
)
IS
BEGIN

IF (p_source_type IS NOT NULL AND p_source_code IS NOT NULL AND p_dim_level_id  IS NOT NULL AND p_level_table_name IS NOT NULL AND p_level_view_name IS NOT NULL) THEN
    INSERT
    INTO
    bsc_sys_filters_views(
                          source_type,
                          source_code,
                          dim_level_id,
                          level_table_name,
                          level_view_name)
    VALUES (p_source_type,
            p_source_code,
            p_dim_level_id,
            p_level_table_name,
            p_level_view_name
            );
    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );

        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        RAISE;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PVT.insert_filters_view ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PVT.insert_filters_view ';
        END IF;

        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PVT.insert_filters_view ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PVT.insert_filters_view ';
        END IF;

        RAISE;

END insert_filters_view;

END BSC_DIM_LEVEL_FILTERS_PVT;

/
