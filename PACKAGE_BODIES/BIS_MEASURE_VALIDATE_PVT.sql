--------------------------------------------------------
--  DDL for Package Body BIS_MEASURE_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_MEASURE_VALIDATE_PVT" AS
/* $Header: BISVMEVB.pls 120.1 2005/06/03 02:22:05 rpenneru noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVTVLS.pls                                                      |
REM |     MAHRAO		1850860	27/11/2001                                                                      |
REM | DESCRIPTION                                                           |
REM |     Private API for validating items in the MEASUREs record
REM | NOTES                                                                 |
REM |                                                                       |
REM |
REM | 26-JUL-2002 rchandra  Fixed for enh 2440739                           |
REM | 23-JAN-03 sugopal For having different local variables for IN and OUT |
REM |                   parameters (bug#2758428)              	            |
REM | 12-NOV-03 smargand    added the validation for the enable column      |
REM | 22-APR-2005 akoduri   Enhancement#3865711 -- Obsolete Seeded Objects  |
REM | 03-MAY-2005  akoduri  Enh #4268374 -- Weighted Average Measures       |
REM | 02-JUN-2005  rpenneru Enh #4325341 -- Add Calculated Measures         |
REM +=======================================================================+
*/
--
--
G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_MEASURE_VALIDATE_PVT';
--
PROCEDURE Validate_Dimension_Id
( p_api_version          IN  NUMBER
, p_dimension_id         IN  NUMBER
, p_dimension_short_name IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_error_Tbl            OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_dummy  number;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

CURSOR chk_dimension is
  select 1
  from   bisbv_dimensions
  where  dimension_id = p_dimension_id;

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- dbms_output.put_line('PVT. validate dim: '||p_Dimension_ID
  --                      ||' - '||p_Dimension_Short_Name);

  if(BIS_UTILITIES_PUB.Value_Not_Missing(p_dimension_id)=FND_API.G_TRUE
    AND BIS_UTILITIES_PUB.Value_Not_NULL(p_dimension_id)=FND_API.G_TRUE) then
    open chk_dimension;
    fetch chk_dimension into l_dummy;
    if (chk_dimension%NOTFOUND) then
      close chk_dimension;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_DIMENSION_ID'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Dimension_ID'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_ERROR;
    end if;
    close chk_dimension;
  end if;

--commented out NOCOPY RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Dimension_Id'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Validate_Dimension_Id;
--
-- Fix for 1850860 starts here
-----------------------------------------------------------------------
PROCEDURE Val_Actual_Data_Sour_Type
( p_api_version               IN  NUMBER
, p_actual_data_source_type   IN  VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
, x_error_Tbl                 OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_dummy  number;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

CURSOR chk_actual_data_source_type IS
  SELECT 1
  FROM   fnd_lookups
  WHERE  lookup_code = p_actual_data_source_type
  AND    lookup_type = 'BIS_ACTUAL_DATA_SOURCE_TYPE';

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_actual_data_source_type)= FND_API.G_TRUE
    AND BIS_UTILITIES_PUB.Value_Not_NULL(p_actual_data_source_type)= FND_API.G_TRUE)
  THEN
    OPEN chk_actual_data_source_type;
    FETCH chk_actual_data_source_type INTO l_dummy;
    IF chk_actual_data_source_type%NOTFOUND THEN
      CLOSE chk_actual_data_source_type;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_ACTUAL_DATA_SOURCE_TYPE'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Val_Actual_Data_Sour_Type'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_ERROR;
    CLOSE chk_actual_data_source_type;
    END IF;
  END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Val_Actual_Data_Sour_Type'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Val_Actual_Data_Sour_Type;
-----------------------------------------------------------------------
PROCEDURE Val_Actual_Data_Sour
( p_api_version               IN  NUMBER
, p_actual_data_source        IN  VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
, x_error_Tbl                 OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_dummy  number;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

CURSOR chk_actual_data_source IS
  SELECT 1
  FROM   ak_region_items
  WHERE  region_code = SUBSTR(p_actual_data_source, 1,
                              (INSTR(p_actual_data_source, '.', 1)-1)
                             )
--  AND    item_name   = SUBSTR(p_actual_data_source,
  AND    attribute_code   = SUBSTR(p_actual_data_source,
                              (INSTR(p_actual_data_source, '.', 1)+1)
                             );
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_actual_data_source)= FND_API.G_TRUE
    AND BIS_UTILITIES_PUB.Value_Not_NULL(p_actual_data_source)= FND_API.G_TRUE)
  THEN
    OPEN chk_actual_data_source;
    FETCH chk_actual_data_source INTO l_dummy;
    IF chk_actual_data_source%NOTFOUND THEN
      CLOSE chk_actual_data_source;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_ACTUAL_DATA_SOURCE'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Val_Actual_Data_Sour'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_ERROR;
    CLOSE chk_actual_data_source;
    END IF;
  END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Val_Actual_Data_Sour'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Val_Actual_Data_Sour;
-----------------------------------------------------------------------
PROCEDURE Val_Func_Name
( p_api_version               IN  NUMBER
, p_function_name             IN  VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
, x_error_Tbl                 OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_dummy  number;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

CURSOR chk_function_name IS
  SELECT 1
  FROM   fnd_form_functions
  WHERE  function_name = p_function_name;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_function_name)= FND_API.G_TRUE
    AND BIS_UTILITIES_PUB.Value_Not_NULL(p_function_name)= FND_API.G_TRUE)
  THEN
    OPEN chk_function_name;
    FETCH chk_function_name INTO l_dummy;
    IF chk_function_name%NOTFOUND THEN
      CLOSE chk_function_name;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_FUNCTION_NAME'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Val_Func_Name'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_ERROR;
    CLOSE chk_function_name;
    END IF;
  END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Val_Func_Name'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Val_Func_Name;
-----------------------------------------------------------------------
PROCEDURE Val_Comparison_Source
( p_api_version               IN  NUMBER
, p_comparison_source         IN  VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
, x_error_Tbl                 OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_dummy  number;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

CURSOR chk_comparison_source IS
  SELECT 1
  FROM   ak_region_items
  WHERE  region_code = SUBSTR(p_comparison_source, 1,
                              (INSTR(p_comparison_source, '.', 1)-1)
                             )
--  AND    item_name   = SUBSTR(p_comparison_source,
  AND    attribute_code   = SUBSTR(p_comparison_source,
                              (INSTR(p_comparison_source, '.', 1)+1)
                             );
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_comparison_source)= FND_API.G_TRUE
    AND BIS_UTILITIES_PUB.Value_Not_NULL(p_comparison_source)= FND_API.G_TRUE)
  THEN
    OPEN chk_comparison_source;
    FETCH chk_comparison_source INTO l_dummy;
    IF chk_comparison_source%NOTFOUND THEN
      CLOSE chk_comparison_source;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_COMPARISON_SOURCE'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Val_Comparison_Source'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_ERROR;
    CLOSE chk_comparison_source;
    END IF;
  END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Val_Comparison_Source'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Val_Comparison_Source;
-----------------------------------------------------------------------
PROCEDURE Val_Incr_In_Measure
( p_api_version               IN  NUMBER
, p_increase_in_measure       IN  VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
, x_error_Tbl                 OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_dummy  number;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

CURSOR chk_increase_in_measure IS
  SELECT 1
  FROM   fnd_lookups
  WHERE  lookup_code = p_increase_in_measure
  AND    lookup_type = 'BIS_INCREASE_IN_MEASURE';

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_increase_in_measure)= FND_API.G_TRUE
    AND BIS_UTILITIES_PUB.Value_Not_NULL(p_increase_in_measure)= FND_API.G_TRUE)
  THEN
    OPEN chk_increase_in_measure;
    FETCH chk_increase_in_measure INTO l_dummy;
    IF chk_increase_in_measure%NOTFOUND THEN
      CLOSE chk_increase_in_measure;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_INCREASE_IN_MEASURE'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Val_Incr_In_Measure'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_ERROR;
    CLOSE chk_increase_in_measure;
    END IF;
  END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Val_Incr_In_Measure'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Val_Incr_In_Measure;
-----------------------------------------------------------------------
--2440739
PROCEDURE Val_Enable_Link
( p_api_version               IN  NUMBER
, p_enable_link               IN  VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
, x_error_Tbl                 OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_dummy  number;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

CURSOR chk_Enable_Link IS
  SELECT 1
  FROM   fnd_lookups
  WHERE  lookup_code = p_Enable_Link
  AND    lookup_type = 'BIS_PMF_ENABLE_LINK';

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_enable_link)= FND_API.G_TRUE
    AND BIS_UTILITIES_PUB.Value_Not_NULL(p_enable_link)= FND_API.G_TRUE)
  THEN
    IF ( chk_enable_link%ISOPEN ) THEN
     CLOSE chk_enable_link;
    END IF;
    OPEN chk_enable_link;
    FETCH chk_enable_link INTO l_dummy;
    IF chk_enable_link%NOTFOUND THEN
      CLOSE chk_enable_link;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_enable_link'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Val_enable_link'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_ERROR;
    CLOSE chk_enable_link;
    END IF;
  END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF ( chk_enable_link%ISOPEN ) THEN
        CLOSE chk_enable_link;
      END IF;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF ( chk_enable_link%ISOPEN ) THEN
        CLOSE chk_enable_link;
      END IF;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF ( chk_enable_link%ISOPEN ) THEN
        CLOSE chk_enable_link;
      END IF;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      IF ( chk_enable_link%ISOPEN ) THEN
        CLOSE chk_enable_link;
      END IF;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Val_enable_link'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Val_Enable_Link;
----------------------------------------------------------------------- 2440739


--3031053
PROCEDURE Val_Enabled
( p_api_version               IN  NUMBER
, p_enabled                   IN  VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
, x_error_Tbl                 OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_dummy  number;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_enabled)= FND_API.G_TRUE
    AND BIS_UTILITIES_PUB.Value_Not_NULL(p_enabled)= FND_API.G_TRUE)
  THEN
    IF ((p_enabled <> FND_API.G_TRUE) AND (p_enabled <> FND_API.G_FALSE)) THEN
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_PMF_INVALID_ENABLED'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Val_enabled'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Val_enabled'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Val_Enabled;
----------------------------------------------------------------------- 3031053

PROCEDURE Val_Obsolete  --3865711
( p_api_version               IN  NUMBER
, p_obsolete                  IN  VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
, x_error_Tbl                 OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_dummy  number;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF ((p_obsolete <> FND_API.G_TRUE) AND (p_obsolete <> FND_API.G_FALSE) AND ( BIS_UTILITIES_PVT.Value_Missing_Or_Null(p_obsolete) <> FND_API.G_TRUE) ) THEN
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_PMF_INVALID_OBSOLETE_FLAG'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Val_Obsolete'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_ERROR;
  END IF;
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Val_Obsolete'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
END Val_Obsolete;

PROCEDURE Val_Measure_Type
( p_api_version               IN  NUMBER
, p_Measure_Type                  IN  VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
, x_error_Tbl                 OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_dummy  number;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF ((p_Measure_type <> 'CDS_SCORE') AND (p_Measure_Type <> 'CDS_PERF') AND (p_Measure_Type <> 'CDS_CALC')
         AND ( BIS_UTILITIES_PVT.Value_Missing_Or_Null(p_Measure_Type) <> FND_API.G_TRUE) ) THEN
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_PMF_INVALID_MEASURE_TYPE'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Val_Measure_Type'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_ERROR;
  END IF;
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Val_Measure_Type'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
END Val_Measure_Type;


PROCEDURE Val_Actual_Data_Sour_Type_wrap
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec      IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  Val_Actual_Data_Sour_Type( p_api_version
                                  , p_MEASURE_Rec.Actual_Data_Source_Type
                                  , x_return_status
                                  , x_error_tbl
                                  );

--commented out NOCOPY RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Val_Actual_Data_Sour_Type_Wrap'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Val_Actual_Data_Sour_Type_Wrap;
-----------------------------------------------------------------------
PROCEDURE Val_Actual_Data_Sour_Wrap
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec      IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  Val_Actual_Data_Sour( p_api_version
                      , p_MEASURE_Rec.Actual_Data_Source
                      , x_return_status
                      , x_error_tbl
                      );

--commented out NOCOPY RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Val_Actual_Data_Sour_Wrap'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Val_Actual_Data_Sour_Wrap;
-----------------------------------------------------------------------
PROCEDURE Val_Func_Name_Wrap
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec      IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  Val_Func_Name( p_api_version
                     , p_MEASURE_Rec.Function_Name
                     , x_return_status
                     , x_error_tbl
                     );

--commented out NOCOPY RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Val_Func_Name_Wrap'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Val_Func_Name_Wrap;
-----------------------------------------------------------------------
PROCEDURE Val_Comparison_Source_wrap
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec      IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  Val_Comparison_Source( p_api_version
                       , p_MEASURE_Rec.Comparison_Source
                       , x_return_status
                       , x_error_tbl
                       );

--commented out NOCOPY RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Val_Comparison_Source_Wrap'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Val_Comparison_Source_Wrap;
-----------------------------------------------------------------------
PROCEDURE Val_Incr_In_Measure_Wrap
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec      IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  Val_Incr_In_Measure( p_api_version
                     , p_MEASURE_Rec.Increase_In_Measure
                     , x_return_status
                     , x_error_tbl
                     );

--commented out NOCOPY RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Val_Incr_In_Measure_Wrap'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Val_Incr_In_Measure_Wrap;
-----------------------------------------------------------------------
-- Fix for 1850860 starts here
-- 2440739
PROCEDURE Val_enable_link_Wrap
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec      IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  Val_enable_link( p_api_version
                     , p_MEASURE_Rec.enable_link
                     , x_return_status
                     , x_error_tbl
                     );

--commented out NOCOPY RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Val_enable_link_Wrap'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Val_enable_link_Wrap;
-----------------------------------------------------------------------
-- 2440739

-- 3031053
PROCEDURE Val_enabled_Wrap
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec      IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  Val_enabled ( p_api_version
                     , p_MEASURE_Rec.enabled
                     , x_return_status
                     , x_error_tbl
                     );

--commented out NOCOPY RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Val_enabled_Wrap'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Val_enabled_Wrap;
-----------------------------------------------------------------------
-- 2440739


PROCEDURE Val_Obsolete_Wrap --3865711
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec      IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  Val_Obsolete ( p_api_version
                     , p_MEASURE_Rec.Obsolete
                     , x_return_status
                     , x_error_tbl
                     );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Val_Obsolete_Wrap'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
END Val_Obsolete_Wrap;
-----------------------------------------------------------------------

PROCEDURE Val_Measure_Type_Wrap
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec      IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  Val_Measure_Type ( p_api_version
                     , p_MEASURE_Rec.Measure_Type
                     , x_return_status
                     , x_error_tbl
                     );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Val_Measure_Type_Wrap'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
END Val_Measure_Type_Wrap;
-----------------------------------------------------------------------

PROCEDURE Validate_Dimension1_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec       IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  Validate_Dimension_Id( p_api_version
                       , p_MEASURE_Rec.Dimension1_ID
                       , p_Measure_Rec.Dimension1_Short_Name
                       , x_return_status
                       , x_error_tbl
                       );

--commented out NOCOPY RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Dimension1_ID'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Dimension1_ID;
--
PROCEDURE Validate_Dimension2_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec       IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  Validate_Dimension_Id( p_api_version
                       , p_MEASURE_Rec.Dimension2_ID
                       , p_Measure_Rec.Dimension2_Short_Name
                       , x_return_status
                       , x_error_tbl
                       );

--commented out NOCOPY RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Dimension2_ID'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Dimension2_ID;
--
PROCEDURE Validate_Dimension3_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec       IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  Validate_Dimension_Id( p_api_version
                       , p_MEASURE_Rec.Dimension3_ID
                       , p_Measure_Rec.Dimension3_Short_Name
                       , x_return_status
                       , x_error_tbl
                       );

--commented out NOCOPY RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Dimension3_ID'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Dimension3_ID;
--
PROCEDURE Validate_Dimension4_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec       IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  Validate_Dimension_Id( p_api_version
                       , p_MEASURE_Rec.Dimension4_ID
                       , p_Measure_Rec.Dimension4_Short_Name
                       , x_return_status
                       , x_error_tbl
                       );

--commented out NOCOPY RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Dimension4_ID'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Dimension4_ID;
--
PROCEDURE Validate_Dimension5_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec       IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  Validate_Dimension_Id( p_api_version
                       , p_MEASURE_Rec.Dimension5_ID
                       , p_Measure_Rec.Dimension5_Short_Name
                       , x_return_status
                       , x_error_tbl
                       );

--commented out NOCOPY RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Dimension5_ID'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Dimension5_ID;
--
PROCEDURE Validate_Dimension6_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec       IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  Validate_Dimension_Id( p_api_version
                       , p_MEASURE_Rec.Dimension6_ID
                       , p_Measure_Rec.Dimension6_Short_Name
                       , x_return_status
                       , x_error_tbl
                       );

--commented out NOCOPY RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Dimension6_ID'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Dimension6_ID;
--
PROCEDURE Validate_Dimension7_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec       IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  Validate_Dimension_Id( p_api_version
                       , p_MEASURE_Rec.Dimension7_ID
                       , p_Measure_Rec.Dimension7_Short_Name
                       , x_return_status
                       , x_error_tbl
                       );

--commented out NOCOPY RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Dimension7_ID'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Dimension7_ID;
--
END BIS_MEASURE_VALIDATE_PVT;

/
