--------------------------------------------------------
--  DDL for Package Body BIS_COMPUTED_TARGET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_COMPUTED_TARGET_PVT" AS
/* $Header: BISVCTVB.pls 115.11 2003/01/27 13:44:19 sugopal noship $ */

G_PKG_NAME CONSTANT varchar2(30) := 'BIS_COMPUTED_TARGET_PVT';
G_BISTAR_CLAUSE CONSTANT varchar2(50) := '%pFunctionType=BISTAR%' ;

PROCEDURE Retrieve_Computed_Targets
( p_api_version          IN  number
, x_Computed_Target_Tbl  out NOCOPY Computed_Target_Tbl_Type
, x_return_status        OUT NOCOPY VARCHAR2
, x_error_tbl            OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

i NUMBER := 0;
cursor comp_target is
    select function_id,function_name, user_function_name
    from fnd_form_functions_vl
 where parameters like G_BISTAR_CLAUSE ;
    --where TYPE = 'BISTAR';

l_rec Computed_target_Rec_Type;

BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    for comptar in comp_target loop
      i := i+1;


      l_rec.Computed_Target_id := comptar.function_id;
      l_rec.Computed_Target_Short_name := comptar.function_name;
      l_rec.Computed_Target_name := comptar.user_function_name;

      x_Computed_Target_Tbl(i) := l_rec;

    end loop;
    if comp_target%isopen then close comp_target; end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Computed_Targets'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_Computed_Targets;
--
PROCEDURE Validate_Computed_Target_Id
( p_api_version           IN  NUMBER
, p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Computed_Target_ID    IN  NUMBER
, x_return_status         OUT NOCOPY VARCHAR2
, x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

CURSOR val_cur is
    select 1
    from fnd_form_functions_vl
    where function_id = p_Computed_Target_ID
  and parameters like G_BISTAR_CLAUSE ;
    --and  TYPE = 'BISTAR';
l_dummy number;
l_error_Tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN
  --added status
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  if(   BIS_UTILITIES_PUB.Value_Not_Missing(p_Computed_Target_ID)
        =FND_API.G_TRUE
    AND BIS_UTILITIES_PUB.Value_Not_NULL(p_Computed_Target_ID)
        =FND_API.G_TRUE ) then
    open val_cur;
    fetch val_cur into l_dummy;
    if (val_cur%NOTFOUND) then
      close val_cur;
      -- POPULATE THE TABLE
      --added last two params
      l_error_Tbl := x_error_tbl;

      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_COMP_FUNCTION'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Computed_Target_Id'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
       , p_error_table       => l_error_Tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_ERROR;
    end if;
    close val_cur;
  end if;
--commented RAISE
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Computed_Target_Id'
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Computed_Target_Id;
--
--
PROCEDURE Value_ID_Conversion
( p_api_version                IN  NUMBER
, p_Computed_Target_Short_Name IN  VARCHAR2
, p_Computed_Target_Name       IN  VARCHAR2
, x_Computed_Target_ID         OUT NOCOPY NUMBER
, x_return_status              OUT NOCOPY VARCHAR2
, x_error_Tbl                  OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

BEGIN

  x_return_status  := FND_API.G_RET_STS_SUCCESS;

  if (BIS_UTILITIES_PUB.Value_Not_Missing(p_Computed_Target_Short_Name)
                       = FND_API.G_TRUE) then

    select function_id into x_Computed_Target_ID
    from fnd_form_functions_vl
    where function_name = p_Computed_Target_Short_Name
 and parameters like G_BISTAR_CLAUSE;
    --and  TYPE = 'BISTAR';

  elsif (BIS_UTILITIES_PUB.Value_Not_Missing(p_Computed_Target_Name)
                       = FND_API.G_TRUE) then

    select function_id into x_Computed_Target_ID
    from fnd_form_functions_vl
    where user_function_name = p_Computed_Target_Name
 and parameters like G_BISTAR_CLAUSE ;
    --and  TYPE = 'BISTAR';

  else
    -- POLPULATE ERROR TABLE
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_COMP_FUNC_VALUE'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Value_ID_Conversion'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    );
    RAISE FND_API.G_EXC_ERROR;
  end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Value_ID_Conversion'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Value_ID_Conversion;
--
--
END BIS_COMPUTED_TARGET_PVT;

/
