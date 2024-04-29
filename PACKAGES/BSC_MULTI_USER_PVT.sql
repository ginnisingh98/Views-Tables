--------------------------------------------------------
--  DDL for Package BSC_MULTI_USER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_MULTI_USER_PVT" AUTHID CURRENT_USER as
/* $Header: BSCVMUFS.pls 120.0 2005/05/31 18:58:58 appldev noship $*/

procedure Apply_Multi_User_Env(
  p_obj_type            IN      varchar2
 ,p_obj_id              IN      number := 0
 ,p_obj_id2             IN      number := 0
 ,p_obj_id3             IN      number := 0
 ,p_obj_location        IN      varchar2 := 'DUMMY'
 ,p_obj_action	        IN      varchar2
 ,p_time_stamp          IN      varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Have_Time_Stamps_Changed(
  p_obj_type            IN      varchar2
 ,p_obj_id              IN      number
 ,p_time_stamp          IN      date
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Check_Tab_Time_Stamp(
  p_obj_id              IN      number
 ,p_time_stamp          IN      date
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Check_Kpi_Time_Stamp(
  p_obj_id              IN      number
 ,p_time_stamp          IN      date
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Check_System_Change(
  p_property_code       IN      varchar2
 ,p_time_stamp          IN      date
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Tab_Details_Lock(
  p_obj_id              IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Tab_Delete_Lock(
  p_obj_id              IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Tab_Select_Items_Lock(
  p_obj_id              IN     number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Kpi_Lock(
  p_obj_id                      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Option_Lock(
  p_obj_id              IN      number
 ,p_obj_id2             IN      number
 ,p_obj_id3             IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Dim_Level_Lock(
  p_obj_id              IN      number
 ,p_obj_shortName       IN      varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);


end BSC_MULTI_USER_PVT;

 

/
