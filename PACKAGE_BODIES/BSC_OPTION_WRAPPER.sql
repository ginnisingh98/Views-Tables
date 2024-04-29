--------------------------------------------------------
--  DDL for Package Body BSC_OPTION_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_OPTION_WRAPPER" as
/* $Header: BSCAOWRB.pls 115.7 2003/05/13 13:00:08 pwali ship $ */

procedure Update_Option_Name(
  p_old_option_name			varchar2
 ,p_new_option_name			varchar2
 ,p_option_dim_levels		varchar2
 ,p_option_description		varchar2
) is

TYPE Recdc_value		IS REF CURSOR;
dc_value			Recdc_value;

l_Anal_Opt_Rec			BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;

l_msg_count			number;

l_commit			varchar2(100) := FND_API.G_TRUE;
l_return_status			varchar2(100);
l_msg_data			varchar2(100);
l_sql				varchar2(2000);


begin

  -- Set language values for l_Anal_Opt_Rec record.
  l_Anal_Opt_Rec.Bsc_Language := 'US';
  l_Anal_Opt_Rec.Bsc_Source_Language := 'US';

  -- Set new name and description value for l_Anal_Opt_Rec record.
  l_Anal_Opt_Rec.Bsc_Option_Name := p_new_option_name;
  l_Anal_Opt_Rec.Bsc_Option_Help := p_option_description;


  -- Need to get the different Indicators and Analysis Options which exactly
  -- match the current Analysis Option Name and Dimension Level Combination.
  l_sql := 'select distinct indicator ' ||
           '               ,analysis_group_id ' ||
           '               ,option_id ' ||
           '  from BSC_OPTS_PMF_MEAS_V ' ||
           ' where option_name = :1'||
           ' and dim_levels = :2';

  open dc_value for l_sql using p_old_option_name, p_option_dim_levels;
    loop
      fetch dc_value into l_Anal_Opt_Rec.Bsc_Kpi_Id,
                          l_Anal_Opt_Rec.Bsc_Analysis_Group_Id,
                          l_Anal_Opt_Rec.Bsc_Analysis_Option_Id;
      exit when dc_value%NOTFOUND;
      BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options( l_commit
                                                      ,l_Anal_Opt_Rec
                                                      ,l_return_status
                                                      ,l_msg_count
                                                      ,l_msg_data);
    end loop;
  close dc_value;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    l_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      l_msg_count
                              ,p_data   =>      l_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      l_msg_count
                              ,p_data     =>      l_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback;
    l_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      l_msg_count
                              ,p_data     =>      l_msg_data);
  WHEN OTHERS THEN
    rollback;
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      l_msg_count
                              ,p_data     =>      l_msg_data);


end Update_Option_Name;

end BSC_OPTION_WRAPPER;

/
