--------------------------------------------------------
--  DDL for Package Body BIS_REPORT_FUNCTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_REPORT_FUNCTION_PVT" AS
/* $Header: BISVRPFB.pls 115.4 99/09/19 11:20:38 porting ship  $ */

G_PKG_NAME CONSTANT varchar2(30) := 'BIS_Report_Function_PVT';

PROCEDURE Retrieve_Report_Functions
( p_api_version          IN  number
, x_Report_Function_Tbl  out Report_Function_Tbl_Type
, x_return_status        OUT VARCHAR2
, x_error_tbl            OUT BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

i NUMBER := 0;
cursor web_reports is
    select function_id, function_name, user_function_name
    from fnd_form_functions_vl
    where UPPER(PARAMETERS) like '%REPORT%'
      and TYPE = 'WWW';

l_rec Report_Function_Rec_Type;

BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    for cr in web_reports loop
      i := i+1;


      l_rec.Report_Function_id        := cr.function_id;
      l_rec.Report_Function_name      := cr.function_name;
      l_rec.Report_User_Function_name := cr.user_function_name;

      x_Report_Function_Tbl(i) := l_rec;

    end loop;
    if web_reports%isopen then close web_reports; end if;

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
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Report_Functions'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_Report_Functions;
--
PROCEDURE Validate_Report_Function_Id
( p_api_version           IN  NUMBER
, p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Report_Function_ID    IN  NUMBER
, x_return_status         OUT VARCHAR2
, x_error_Tbl             OUT BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

CURSOR val_cur is
    select 1
    from fnd_form_functions_vl
    where function_id = p_Report_Function_ID
    and  TYPE = 'BISTAR';
l_dummy number;

BEGIN

  open val_cur;
  fetch val_cur into l_dummy;
  if (val_cur%NOTFOUND) then
    close val_cur;
    -- POPULATE THE TABLE
    RAISE FND_API.G_EXC_ERROR;
  end if;
  close val_cur;

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
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Report_Function_Id'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Report_Function_Id;
--
--
PROCEDURE Value_ID_Conversion
( p_api_version                IN  NUMBER
, p_Report_Function_Name       IN  VARCHAR2
, p_Report_user_Function_Name  IN  VARCHAR2
, x_Report_Function_ID         OUT NUMBER
, x_return_status              OUT VARCHAR2
, x_error_Tbl                  OUT BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

BEGIN

  x_return_status  := FND_API.G_RET_STS_SUCCESS;

  if (BIS_UTILITIES_PUB.Value_Not_Missing(p_Report_Function_Name)
                       = FND_API.G_TRUE) then

    select function_id into x_Report_Function_ID
    from fnd_form_functions_vl
    where function_name = p_Report_Function_Name
    and  TYPE = 'BISTAR';

  elsif (BIS_UTILITIES_PUB.Value_Not_Missing(p_Report_user_Function_Name)
                       = FND_API.G_TRUE) then

    select function_id into x_Report_Function_ID
    from fnd_form_functions_vl
    where user_function_name = p_Report_user_Function_Name
    and  TYPE = 'BISTAR';

  else
    -- POLPULATE ERROR TABLE
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
END BIS_Report_Function_PVT;

/
