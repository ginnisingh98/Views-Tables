--------------------------------------------------------
--  DDL for Package Body BIS_TARGET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_TARGET_PUB" AS
/* $Header: BISPTARB.pls 115.29 2003/01/27 13:34:00 mahrao ship $ */
--
/*
REM dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
REM dbdrv: checkfile:~PROD:~PATH:~FILE
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPTARS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for creating and managing Targets for the
REM |     Key Performance Framework.
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 02-DEC-98 irchen Creation
REM | 10-JAN-2003 rchandra for bug 2715432 , changed OUT parameter          |
REM |                       x_Target_Level_Rec , x_Target_Rec to IN OUT     |
REM |                       in API RETRIEVE_TARGET_FROM_SHNMS               |
REM |
REM | 23-JAN-03 mahrao For having different local variables for IN and OUT
REM |                  parameters.
REM +=======================================================================+
*/
--
--
--
--   Defines one target for a specific set of dimension values for
--   one target level
PROCEDURE Create_Target
( p_api_version   IN  NUMBER
, p_commit        IN  VARCHAR2 := FND_API.G_FALSE
, p_Target_Rec    IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_Target_Rec BIS_TARGET_PUB.Target_Rec_Type;
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  -- do value - id conversions
  BIS_TARGET_PVT.Value_ID_Conversion
                 ( p_api_version   => p_api_version
                 , p_Target_Rec    => p_Target_Rec
                 , x_Target_Rec    => l_Target_Rec
                 , x_return_status => x_return_status
                 , x_error_Tbl     => x_error_Tbl
                 );
--
-- call pvt create
  BIS_TARGET_PVT.Create_Target
                 ( p_api_version   => p_api_version
                 , p_commit        => p_commit
                 , p_Target_Rec    => l_Target_Rec
                 , x_return_status => x_return_status
                 , x_error_Tbl     => x_error_Tbl
                 );
--
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PUB.Create_Target:G_EXC_ERROR'); htp.para;
    END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PUB.Create_Target:G_EXC_UNEXPECTED_ERROR'); htp.para;
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PUB.Create_Target:OTHERS'); htp.para;
    END IF;
--
END Create_Target;
--
--
-- retrieve information for all targets of the given target level
-- if information about dimension values are not required, set all_info
-- to FALSE.
PROCEDURE Retrieve_Targets
( p_api_version      IN  NUMBER
, p_Target_Level_Rec IN  BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
, p_all_info         IN  VARCHAR2 := FND_API.G_TRUE
, x_Target_Tbl       OUT NOCOPY BIS_TARGET_PUB.Target_Tbl_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_Target_Level_Rec BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
l_target_tbl BIS_TARGET_PUB.Target_Tbl_Type;
--
BEGIN
  -- do value - id conversions
  BIS_TARGET_LEVEL_PVT.Value_ID_Conversion
  ( p_api_version      => p_api_version
  , p_Target_Level_Rec => p_Target_Level_Rec
  , x_Target_Level_Rec => l_Target_Level_Rec
  , x_return_status    => x_return_status
  , x_error_Tbl        => x_error_Tbl
  );
--
-- call pvt retrieve
  BIS_TARGET_PVT.Retrieve_Targets
  ( p_api_version      => p_api_version
  , p_Target_Level_Rec => p_Target_Level_Rec
  , p_all_info         => p_all_info
  , x_Target_Tbl       => x_Target_Tbl
  , x_return_status    => x_return_status
  , x_error_Tbl        => x_error_Tbl
  );
  -- For product teams still using the Org and Time values populate those fields
  --added this check

  IF (x_target_tbl.COUNT > 0) THEN
     l_target_tbl := x_target_tbl;
		 FOR l_count IN 1..l_target_tbl.COUNT LOOP
		 BIS_UTILITIES_PVT.resequence_dim_level_values
                       (l_target_tbl(l_count)
		       ,'R'
		       ,x_target_tbl(l_count)
		       ,x_Error_tbl
		       );
     END LOOP;
  END IF;


--
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PUB.Retrieve_Targets:G_EXC_ERROR'); htp.para;
    END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PUB.Retrieve_Targets:G_EXC_UNEXPECTED_ERROR'); htp.para;
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PUB.Retrieve_Targets:OTHERS'); htp.para;
    END IF;
--
END Retrieve_Targets;
--
--
-- retrieve information for one target
-- If information about dimension values are not required, set all_info
-- to FALSE.
PROCEDURE Retrieve_Target
( p_api_version   IN  NUMBER
, p_Target_Rec    IN  BIS_TARGET_PUB.Target_Rec_Type
, p_all_info      IN  VARCHAR2 := FND_API.G_TRUE
, x_Target_Rec    IN OUT NOCOPY BIS_TARGET_PUB.Target_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_Target_Rec BIS_TARGET_PUB.Target_Rec_Type;
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
l_Target_Rec_p BIS_TARGET_PUB.Target_Rec_Type;
--
BEGIN
  -- do value - id conversions
  BIS_TARGET_PVT.Value_ID_Conversion
                 ( p_api_version   => p_api_version
                 , p_Target_Rec    => p_Target_Rec
                 , x_Target_Rec    => l_Target_Rec
                 , x_return_status => x_return_status
                 , x_error_Tbl     => x_error_Tbl
                 );

--
   --Resequence the dimensions. This is for backward compatibility for product teams
   --still using Org and Time
   l_Target_Rec_p := l_Target_Rec;
	 BIS_UTILITIES_PVT.resequence_dim_level_values
                 (l_Target_Rec_p
		  ,'N'
		 ,l_target_rec
		 ,x_Error_tbl
		);
-- call pvt retrieve
  BIS_TARGET_PVT.Retrieve_Target
                 ( p_api_version   => p_api_version
                 , p_Target_Rec    => l_Target_Rec
                 , x_Target_Rec    => x_Target_Rec
                 , x_return_status => x_return_status
                 , x_error_Tbl     => x_error_Tbl
                 );
--
   --Put the values back in Org and Time for the product teams still using them
   --added this check
   if(x_return_status = FND_API.G_RET_STS_SUCCESS) then
      l_Target_Rec_p := x_Target_Rec;
			BIS_UTILITIES_PVT.resequence_dim_level_values
                 (l_Target_Rec_p
		  ,'R'
		 ,x_target_rec
		 ,x_Error_tbl
		 );
    end if;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PUB.Retrieve_Target:G_EXC_ERROR'); htp.para;
    END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PUB.Retrieve_Target:G_EXC_UNEXPECTED_ERROR'); htp.para;
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PUB.Retrieve_Target:OTHERS'); htp.para;
    END IF;
--
END Retrieve_Target;
--
-- Modifies one target for a specific set of dimension values for
-- one target level
PROCEDURE Update_Target
( p_api_version   IN  NUMBER
, p_commit        IN  VARCHAR2 := FND_API.G_FALSE
, p_Target_Rec    IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_Target_Rec BIS_TARGET_PUB.Target_Rec_Type;
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  -- do value - id conversions
  BIS_TARGET_PVT.Value_ID_Conversion
                   ( p_api_version   => p_api_version
                   , p_Target_Rec    => p_Target_Rec
                   , x_Target_Rec    => l_Target_Rec
                   , x_return_status => x_return_status
                   , x_error_Tbl     => x_error_Tbl
                   );
--
-- call pvt update
--added the p_commit
  BIS_TARGET_PVT.Update_Target
                   ( p_api_version   => p_api_version
                   , p_commit      => p_commit
                   , p_Target_Rec    => l_Target_Rec
                   , x_return_status => x_return_status
                   , x_error_Tbl     => x_error_Tbl
                   );
--
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PUB.Update_Target:G_EXC_ERROR'); htp.para;
    END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PUB.Update_Target:G_EXC_UNEXPECTED_ERROR'); htp.para;
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PUB.Update_Target:OTHERS'); htp.para;
    END IF;
--
END Update_Target;
--
-- Deletes one target for a specific set of dimension values for
-- one target level
PROCEDURE Delete_Target
( p_api_version   IN  NUMBER
, p_commit        IN  VARCHAR2 := FND_API.G_FALSE
, p_Target_Rec    IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_Target_Rec BIS_TARGET_PUB.Target_Rec_Type;
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  -- do value - id conversions
  BIS_TARGET_PVT.Value_ID_Conversion
  ( p_api_version   => p_api_version
  , p_Target_Rec    => p_Target_Rec
  , x_Target_Rec    => l_Target_Rec
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_Tbl
  );
--
-- call pvt delete
  BIS_TARGET_PVT.Delete_Target
  ( p_api_version   => p_api_version
  , p_commit        => p_commit
  , p_Target_Rec    => l_Target_Rec
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_Tbl
  );
--
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PUB.Delete_Target:G_EXC_ERROR'); htp.para;
    END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PUB.Delete_Target:G_EXC_UNEXPECTED_ERROR'); htp.para;
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PUB.Delete_Target:OTHERS'); htp.para;
    END IF;
--
END Delete_Target;
--
-- Validates target record
PROCEDURE Validate_Target
( p_api_version     IN  NUMBER
, p_Target_Rec      IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_Tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_Target_Rec BIS_TARGET_PUB.Target_Rec_Type;
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
--  dbms_output.put_line('> Validate_Target');
  -- do value - id conversions
  BIS_TARGET_PVT.Value_ID_Conversion
  ( p_api_version   => p_api_version
  , p_Target_Rec    => p_Target_Rec
  , x_Target_Rec    => l_Target_Rec
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_Tbl
  );
--
-- call pvt validate
  BIS_TARGET_PVT.Validate_Target
  ( p_api_version     => p_api_version
  , p_Target_Rec      => l_Target_Rec
  , x_return_status   => x_return_status
  , x_error_Tbl       => x_error_Tbl
  );
  --
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PUB.Validate_Target:G_EXC_ERROR'); htp.para;
    END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PUB.Validate_Target:G_EXC_UNEXPECTED_ERROR'); htp.para;
    END IF;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PUB.Validate_Target:OTHERS'); htp.para;
    END IF;
END Validate_Target;
--

-- New Procedure to return TargetLevel and Target given the DimensionLevel ShortNames in any sequence
-- and the Measure Short Name
PROCEDURE Retrieve_Target_From_ShNms
( p_api_version      IN  NUMBER
, p_target_level_rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, p_Target_Rec      IN BIS_TARGET_PUB.TARGET_REC_TYPE
, x_Target_Level_Rec IN OUT NOCOPY BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_Target_Rec       IN OUT NOCOPY BIS_TARGET_PUB.TARGET_REC_TYPE
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  BIS_Target_PVT.Retrieve_Target_From_ShNms
  (
    p_api_version   =>  p_api_version
  , p_Target_Level_Rec   => p_Target_Level_Rec
   ,p_Target_Rec   => p_Target_Rec
  , x_Target_Level_Rec   => x_Target_Level_Rec
  , x_Target_Rec   => x_Target_Rec
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_Tbl
  );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PUB.Retrieve_Target:G_EXC_ERROR'); htp.para;
    END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PUB.Retrieve_Target:G_EXC_UNEXPECTED_ERROR'); htp.para;
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
END Retrieve_Target_From_ShNms;
--
END BIS_TARGET_PUB;

/
