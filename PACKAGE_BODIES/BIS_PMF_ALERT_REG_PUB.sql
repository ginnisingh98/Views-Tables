--------------------------------------------------------
--  DDL for Package Body BIS_PMF_ALERT_REG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMF_ALERT_REG_PUB" AS
/* $Header: BISPARTB.pls 115.16 2002/12/16 10:22:49 rchandra ship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPARTB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for managing Alert Registration Repository
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 17-May-2000  jradhakr Creation
REM | June 2000    irchen takeover
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_PMF_ALERT_REG_PUB';


PROCEDURE Create_Parameter_set
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_Param_Set_Rec    IN OUT NOCOPY BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN


   BIS_PMF_ALERT_REG_PVT.Create_Parameter_set
   ( p_api_version    => p_api_version
   , p_commit         => p_commit
   , p_Param_Set_Rec  => p_Param_Set_Rec
   , x_return_status  => x_return_status
   , x_error_Tbl      => x_error_Tbl
   );


EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Create_Parameter_set'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );

END Create_Parameter_set;

--
-- Delete one parameter set.
--

PROCEDURE Delete_Parameter_set
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_Param_Set_Rec    IN  BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

BEGIN

   BIS_PMF_ALERT_REG_PVT.Delete_Parameter_set
   ( p_api_version    => p_api_version
   , p_commit         => p_commit
   , p_Param_Set_Rec  => p_Param_Set_Rec
   , x_return_status  => x_return_status
   , x_error_Tbl      => x_error_Tbl
   );


EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Delete_Parameter_set'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );

END Delete_Parameter_set;

-- Retrieve a Table of parmeter set.
--
PROCEDURE Retrieve_Parameter_set
( p_api_version              IN  NUMBER
, p_measure_id               IN  NUMBER
, p_time_dimension_level_id  IN  NUMBER
, p_current_row              IN  VARCHAR2 := NULL
, x_Param_Set_Tbl            OUT NOCOPY BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type
, x_return_status            OUT NOCOPY VARCHAR2
, x_error_Tbl                OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN

   BIS_PMF_ALERT_REG_PVT.Retrieve_Parameter_set
   ( p_api_version            => p_api_version
   , p_measure_id             => p_measure_id
   , p_time_dimension_level_id=> p_time_dimension_level_id
   , p_current_row            => p_current_row
   , x_Param_Set_Tbl          => x_Param_Set_Tbl
   , x_return_status          => x_return_status
   , x_error_Tbl              => x_error_Tbl
   );

EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Parameter_set'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );

END Retrieve_Parameter_set;

--
-- Checks if request is scheduled to run again.  If not, the request
-- is deleted from the Registration table and the ad hoc workflow role
-- is removed.
--

PROCEDURE Manage_Alert_Registrations
( p_Param_Set_rec            IN BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, x_request_scheduled        OUT NOCOPY VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR2
, x_error_Tbl                OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN

   BIS_PMF_ALERT_REG_PVT.Manage_Alert_Registrations
   ( p_Param_Set_rec          => p_Param_Set_rec
   , x_request_scheduled      => x_request_scheduled
   , x_return_status          => x_return_status
   , x_error_Tbl              => x_error_Tbl
   );

EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Manage_Alert_Registrations'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
END Manage_Alert_Registrations;

PROCEDURE Manage_Alert_Registrations
( p_Param_Set_Tbl            IN BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type
, x_request_scheduled        OUT NOCOPY VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR2
, x_error_Tbl                OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN

   BIS_PMF_ALERT_REG_PVT.Manage_Alert_Registrations
   ( p_Param_Set_Tbl          => p_Param_Set_Tbl
   , x_request_scheduled      => x_request_scheduled
   , x_return_status          => x_return_status
   , x_error_Tbl              => x_error_Tbl
   );

EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Manage_Alert_Registrations'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
END Manage_Alert_Registrations;

--
-- Function which will return a boolean varible, if parameter set exist
-- and will also return the notifiers_code
--
FUNCTION  Parameter_set_exist
( p_api_version      IN  NUMBER
, p_Param_Set_Rec    IN  BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, x_notifiers_code   OUT NOCOPY VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
) return boolean
IS

  l_p_exist boolean;

BEGIN

   l_p_exist := BIS_PMF_ALERT_REG_PVT.Parameter_set_Exist
                  ( p_api_version    => p_api_version
                  , p_Param_Set_Rec  => p_Param_Set_Rec
                  , x_notifiers_code => x_notifiers_code
                  , x_return_status  => x_return_status
                  , x_error_Tbl      => x_error_Tbl
                  );

   return l_p_exist;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Parameter_set_exist'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );

END Parameter_set_exist;

END  BIS_PMF_ALERT_REG_PUB;

/
