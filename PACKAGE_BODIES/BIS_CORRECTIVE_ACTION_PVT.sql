--------------------------------------------------------
--  DDL for Package Body BIS_CORRECTIVE_ACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_CORRECTIVE_ACTION_PVT" AS
/* $Header: BISVCACB.pls 120.0.12010000.2 2009/07/13 10:04:26 karthmoh ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVCACB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for the Corrective Action
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM |     APR-2000 irchen   Creation                                        |
REM |     OCT-2000 hhchi    JSP notification to Workflow Notification       |
REM |     JAN-2001 hhchi    fix bug#1567627 in Get_Result_Owners            |
REM |     DEC-2001 rchandra fix bug#1880142,1736261 for alert messgs        |
REM | 	  JAN-2002 sashaik  fix for enhancement 2164190. Modified procedure |
REM |                         send_alert to get report url from bis_actual_values |
REM |                         table.					    |
REM |     JAN-2002 sashaik  Made changes w.r.t the following procs for 1740789:|
REM |                       Retrieve_Org_level_value, Is_Previous_Time_Period |
REM |                       Is_Current_Time_Period, Get_Time_From, Get_Time_To|
REM |  17-JUN-2002 rchandra added bis_utilities_pub.encode                  |                                 --
REM |                         for encoding for bug 2418741                  |
REM |     NOV-15   sashaik  Unsubscribe alerts 1898436
REM |     DEC-12   sashaik  2684836
REM | 23-JAN-03    mahrao For having different local variables for IN and OUT
REM |                     parameters.
REM |     MAR-03   sashaik  2837974
REM |  09-APR-03   smuruges Bug# 2871017                                    |
REM |                       - Removed the html tags that were set in the    |
REM |                         item attributes.                              |
REM |                       - For the following attributes the HTML tags    |
REM |                         cannot be removed. Hence, used the following  |
REM |                         new item attributes and set the values devoid |
REM |                         of tags in these attributes.                  |
REM |                         BIS_DIMENSION_REGION :                        |
REM |                                           BIS_DIMENSION_REGION_TXT    |
REM |                         L_RECEPIENT          : L_RECEPIENT_TXT        |
REM |                         L_ALERT_SCHEDULE_MSG :                        |
REM |                                           L_ALERT_SCHEDULE_MSG_TXT    |
REM |                       - The API GenerateAlert is set to the Document  |
REM |                         item attribute BIS_ALERT_DOC.                 |
REM |                       - Defined the package body for the procedure    |
REM |                         GenerateAlert.                                |
REM |  21-APR-03   mahrao Bug# 2905588                                      |
REM |                       - A new text attribute L_RELATED_INFORAMTION_TXT|
REM |                         has been used in text text messages section of|
REM |                         GenerateAlerts procedure.                     |
REM |                         Tokens are passed for following messages      |
REM |                         1. BIS_ALERT_SCHEDULE_MSG2                    |
REM |                         2. BIS_ALERT_SCHEDULE_MSG1                    |
REM |  05-JUL-03   rchandra  Bug# 2929282                                   |
REM |                        Unsubscribe link will be generated only for    |
REM |                        subscribers and not for owners of the Target   |
REM |                        Removed the unwanted Functions                 |
REM |                        isRoleTargetOwner and isTargetOwner            |
REM |  07-NOV-03   ankgoel   Added conversion for ATG Timezone Project	    |
REM |  14-NOV-03   ankgoel   Modified for bug# 3153918		            |
REM |  10-DEC-03   ankgoel   Modified for bug# 3309374. To comply	    |
REM |			     BLAF standards.				    |
REM | 15-Dec-2003 arhegde enh# 3148615 Change/Target based alerting.        |
REM | 09-Jan-2004 ankgoel    Modified for WF_HEADER_ATTR for Measure        |
REM | 14-Jan-2004 jxyu       Modified for bug#3374352                       |
REM | 25-Jan-2004 ankgoel    Modified Next Run Date format for bug#3083617  |
REM | 11-Feb-2004 gramasam   Blaf Enhancement for TwoCol Layout		    |
REM | 10-Jun-2004 ankgoel    Modified for OAC violations                    |
REM | 10-Sep-2004 rpenneru   Modified for bug#3611608                       |
REM | 27-Oct-2004 ankgoel    Modified for bug#3651600                       |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):= 'BIS_CORRECTIVE_ACTION_PVT';
G_BREAK CONSTANT VARCHAR2(200) := '<BR>';
G_RPT_ERROR CONSTANT VARCHAR2(200) := 'DEFAULT URL';
G_NOTIFICATION_JSP_PAGE CONSTANT VARCHAR2(200) := 'bisalrbk.jsp';

--
-- Procedures
--

PROCEDURE Get_User_List_From_Role -- 2684836
( p_recipient_short_name  IN  VARCHAR2
, x_user_tbl              OUT NOCOPY wf_directory.UserTable
, x_return_status         OUT NOCOPY VARCHAR2
, x_return_msg            OUT NOCOPY VARCHAR2
) ;

FUNCTION Get_Line RETURN VARCHAR2;

FUNCTION Get_Style_Class RETURN VARCHAR2;

FUNCTION Get_Header
( p_item_type      IN VARCHAR2
 ,p_wf_item_key    IN WF_ITEM_ATTRIBUTE_VALUES.ITEM_KEY%TYPE
 ,p_attribute_name IN VARCHAR2
) RETURN VARCHAR2 ;

FUNCTION Get_Label
( p_item_type      IN VARCHAR2
 ,p_wf_item_key    IN WF_ITEM_ATTRIBUTE_VALUES.ITEM_KEY%TYPE
 ,p_attribute_name IN VARCHAR2
) RETURN VARCHAR2 ;

FUNCTION Get_Text
( p_item_type      IN VARCHAR2
 ,p_wf_item_key    IN WF_ITEM_ATTRIBUTE_VALUES.ITEM_KEY%TYPE
 ,p_attribute_name IN VARCHAR2
) RETURN VARCHAR2 ;

FUNCTION Get_Servlet_Agent RETURN VARCHAR2; /* returns the servlet agent dir */
FUNCTION getDate RETURN VARCHAR2; /* returns formated send date */

--FUNCTION Get_Display_Unit(p_unit_code IN VARCHAR2) RETURN VARCHAR2;

FUNCTION getAdHocRole
( p_Alert_recipients_tbl IN BIS_UTILITIES_PUB.BIS_VARCHAR_TBL )RETURN VARCHAR2;
FUNCTION Format_Message(p_message_tbl IN BIS_UTILITIES_PUB.BIS_VARCHAR_TBL)
RETURN VARCHAR2;

FUNCTION Generate_parameter_string
( p_target_id             IN VARCHAR2
, p_comparison_result     IN VARCHAR2
, p_role                  IN VARCHAR2
, p_date                  IN VARCHAR2
, p_schedule_date         IN VARCHAR2
, P_schedule_time         IN VARCHAR2
, p_schedule_freq_unit    IN VARCHAR2
, p_next_run_date         IN VARCHAR2
, p_next_run_time         IN VARCHAR2
, p_description           IN VARCHAR2
) RETURN VARCHAR2;

Procedure Get_Performance_Measure_Msg
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_comparison_result     IN VARCHAR2
, x_message_tbl           OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
);

Procedure Get_Message_Banner
( p_Sent_Date          IN VARCHAR2
, p_Item               IN VARCHAR2
, p_to                 IN VARCHAR2
, x_Message_Banner_tbl OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
);

Procedure Get_Message_Intro
( p_Sent_Date          IN VARCHAR2
, x_Message_Intro_tbl  OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
);

Procedure Get_Message_Body
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_comparison_result     IN VARCHAR2
, x_message_body_tbl      OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
);

Procedure Get_Alert_Information
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_Alert_Information_tbl OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
);

Procedure Get_Related_Links
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_Related_Links_tbl     OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
);

Procedure Get_Report_Attachement
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_attachement_url_tbl   OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
);

Procedure Get_Alert_Recipients
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_comparison_result     IN VARCHAR2
, x_Alert_recipients_tbl  OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
, x_Alert_recipients_sh_nm_tbl OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
, x_number_out_of_range    OUT NOCOPY NUMBER
);

Procedure Get_Alert_Message
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_Alert_Message_tbl     OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
);

Procedure Set_Message
( p_message_tbl           IN BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
, x_return_status         OUT NOCOPY VARCHAR2
);

Function Get_Role
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_comparison_result     IN VARCHAR2
) RETURN VARCHAR2 ;

PROCEDURE Get_Result_Owners
( p_target_Owners_rec      IN BIS_TARGET_PUB.Target_Owners_Rec_Type
, p_comparison_result      IN VARCHAR2
, x_owners_tbl             OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
, x_owners_sh_nm_tbl       OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
, x_number_out_of_range    OUT NOCOPY NUMBER
);

Procedure Get_Workflow_Info
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_comparison_result     IN VARCHAR2
, x_item_type             OUT NOCOPY VARCHAR2
, x_process               OUT NOCOPY VARCHAR2
);

-- Starts the corrective action workflow
--
Procedure Start_Corrective_Action
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_comparison_result     IN VARCHAR2
)
IS

  l_item_type     VARCHAR2(32000);
  l_process       VARCHAR2(32000);
  l_Alert_recipients_tbl BIS_UTILITIES_PUB.BIS_VARCHAR_TBL;
  l_Alert_recipients_sh_nm_tbl BIS_UTILITIES_PUB.BIS_VARCHAR_TBL;
  l_target_level_rec    BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;

  l_message             VARCHAR2(32000);
  l_message_tbl         BIS_UTILITIES_PUB.BIS_VARCHAR_TBL;
  l_schedule_date       VARCHAR2(32000);
  l_schedule_time       VARCHAR2(32000);
  l_schedule_unit       VARCHAR2(32000);
  l_schedule_freq       VARCHAR2(32000);
  l_schedule_freq_unit  VARCHAR2(32000);
  l_next_run_date       VARCHAR2(32000);
  l_next_run_time       VARCHAR2(32000);
  l_description         VARCHAR2(32000);
  l_date                VARCHAR2(32000);
  l_number_out_of_range NUMBER;

  l_return_status       VARCHAR2(32000);

BEGIN

  --BIS_UTILITIES_PUB.put_line(p_text =>'Starting corrective action workflow');
  Get_Request_Info
  ( p_measure_instance    => p_measure_instance
  , x_schedule_date       => l_schedule_date
  , x_schedule_time       => l_schedule_time
  , x_schedule_unit       => l_schedule_unit
  , x_schedule_freq       => l_schedule_freq
  , x_next_run_date  	  => l_next_run_date
  , x_next_run_time  	  => l_next_run_time
  , x_description         => l_description
  , x_return_status       => l_return_status
  );

  Get_Alert_Recipients
  ( p_measure_instance     => p_measure_instance
  , p_dim_level_value_tbl  => p_dim_level_value_tbl
  , p_comparison_result    => p_comparison_result
  , x_Alert_recipients_tbl => l_Alert_recipients_tbl
  , x_Alert_recipients_sh_nm_tbl => l_Alert_recipients_sh_nm_tbl
  , x_number_out_of_range  => l_number_out_of_range
  );

  Get_Workflow_Info
  ( p_measure_instance     => p_measure_instance
  , p_dim_level_value_tbl  => p_dim_level_value_tbl
  , p_comparison_result    => p_comparison_result
  , x_item_type            => l_item_type
  , x_process              => l_process
  );

  l_date := getDate;

  Get_Performance_Measure_Msg
  ( p_measure_instance     => p_measure_instance
  , p_dim_level_value_tbl  => p_dim_level_value_tbl
  , p_comparison_result    => p_comparison_result
  , x_message_tbl          => l_message_tbl
  );

  l_message := Format_Message(p_message_tbl => l_message_tbl);

  --BIS_UTILITIES_PUB.put_line(p_text =>'Corrective action message: '||l_message);

  FOR i IN 1..l_Alert_recipients_sh_nm_tbl.COUNT LOOP
    BIS_UTIL.Start_Workflow_Engine
    ( p_exception_message => l_message
    , p_msg_subject       => l_description
    , p_exception_date    => l_date
    , p_item_type         => l_item_type
    , p_wf_process        => l_process
    , p_notify_resp_name  => l_Alert_recipients_sh_nm_tbl(i) -- 2628529
    , x_return_status     => l_return_status
    );

    BIS_UTILITIES_PUB.put_line(p_text =>'Started workflow Process '||i||'. item type: '||l_item_type
      ||', notified: '||l_Alert_recipients_tbl(i) || ' Status ' || nvl(l_return_status, 'x') );

    commit;
  END LOOP;

END Start_Corrective_Action;




-- Sends the Alert notification
--
Procedure Send_Alert
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_comparison_result     IN VARCHAR2
)
IS

  l_wf_item_key   NUMBER;
  l_item_type     VARCHAR2(32000)
    := BIS_CORRECTIVE_ACTION_PUB.G_BIS_GEN_WORKFLOW_ITEM_TYPE;
  l_process       VARCHAR2(32000)
    := BIS_CORRECTIVE_ACTION_PUB.G_BIS_ALR_WORKFLOW_PROCESS;

  l_Alert_recipients_tbl BIS_UTILITIES_PUB.BIS_VARCHAR_TBL;
  l_Alert_recipients_sh_nm_tbl BIS_UTILITIES_PUB.BIS_VARCHAR_TBL;

  l_document_type_value  VARCHAR2(32000);
  l_message             varchar2(32000);
  l_document_type       varchar2(32000);
  l_return_status       varchar2(32000);
  l_error_Tbl           BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_date                VARCHAR2(32000);
  l_role                VARCHAR2(32000);
  l_schedule_date       VARCHAR2(32000);
  l_schedule_time       VARCHAR2(32000);
  l_schedule_unit       VARCHAR2(32000);
  l_schedule_freq       VARCHAR2(32000);
  l_schedule_freq_unit  VARCHAR2(32000);
  l_next_run_date       VARCHAR2(32000);
  l_next_run_time       VARCHAR2(32000);
  l_description         VARCHAR2(32000);
  l_alert_details       VARCHAR2(32000);
  l_alert_details1      VARCHAR2(32000);
  l_label               VARCHAR2(32000);
  l_label1              VARCHAR2(32000);
  l_target_rec          BIS_TARGET_PUB.Target_rec_type;
  l_actual_rec          BIS_ACTUAL_PUB.Actual_rec_type;
  l_actual_rec1         BIS_ACTUAL_PUB.Actual_rec_type;	-- 2164190 sashaik
  l_dimension_level_rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_dim_level_value_rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_target_level_rec    BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_REC_TYPE;
  l_measure_rec         BIS_MEASURE_PUB.Measure_Rec_Type;

  l_Dim_Level_Value_Rec_oltp 	BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_dimension_level_number_oltp NUMBER;
  l_Org_Level_Value_ID 		VARCHAR2(40); -- := '204';
  l_Org_Level_Short_name   	VARCHAR2(40);

  l_msg                 VARCHAR2(32000);
  l_msg1                VARCHAR2(32000);
  l_link                VARCHAR2(32000);
  l_alert_details_label VARCHAR2(32000);
  l_sequence_no         NUMBER;
  l_time_level_id    NUMBER;
  l_time_level_short_name VARCHAR2(32000);
  l_time_level_name  VARCHAR2(32000);
  l_from                VARCHAR2(32000);
  l_to                  VARCHAR2(32000);
  l_many                NUMBER;
  l_dim_level_value_tbl BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type;
  l_dimlevel_short_name VARCHAR2(32000);
  l_select_String       VARCHAR2(32000);
  l_table_name          VARCHAR2(32000);
  l_value_name          VARCHAR2(32000);
  l_id_name             VARCHAR2(32000);
  l_level_name          VARCHAR2(32000);
  l_msg_Count           NUMBER;
  l_msg_data            VARCHAR2(32000);

  l_Parm1Level_short_name  VARCHAR2(240);
  l_Parm1Value_name        VARCHAR2(240);
  l_Parm2Level_short_name  VARCHAR2(240);
  l_Parm2Value_name        VARCHAR2(240);
  l_Parm3Level_short_name  VARCHAR2(240);
  l_Parm3Value_name        VARCHAR2(240);
  l_Parm4Level_short_name  VARCHAR2(240);
  l_Parm4Value_name        VARCHAR2(240);
  l_Parm5Level_short_name  VARCHAR2(240);
  l_Parm5Value_name        VARCHAR2(240);
  l_Parm6Level_short_name  VARCHAR2(240);
  l_Parm6Value_name        VARCHAR2(240);
  l_Parm7Level_short_name  VARCHAR2(240);
  l_Parm7Value_name        VARCHAR2(240);
  l_param_count            NUMBER;

  l_formatted_actual	   varchar2(300);

  l_number_out_of_range NUMBER;

  TYPE t_dim_Value IS TABLE OF VARCHAR2(32000)
     INDEX BY BINARY_INTEGER;
  TYPE t_dim_value_level IS TABLE OF VARCHAR2(32000)
     INDEX BY BINARY_INTEGER;
  TYPE t_dim_level_input IS TABLE OF VARCHAR2(32000)
     INDEX BY BINARY_INTEGER;
  TYPE t_dim_value_input IS TABLE OF VARCHAR2(32000)
     INDEX BY BINARY_INTEGER;

  v_dim_level_input t_dim_level_input;
  v_dim_value_input t_dim_value_input;
  v_dim_value_level t_dim_value_level;
  v_dim_level t_dim_value_level;
  v_dim_value t_dim_value;

  l_rolling_period_end_date	DATE;
  l_rolling_period_start_date	DATE;
  l_is_rolling_period		NUMBER;
  l_start_label			VARCHAR2(30);
  l_end_label			VARCHAR2(30);

  l_unscubscribe_url   VARCHAR2(32000) := NULL;  -- begin 1898436
  l_notifiers_code     bis_pmf_alert_parameters.notifiers_code%TYPE;
  l_Param_Set_Rec      BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type; -- end 1898436

  l_wf_user_table      wf_directory.UserTable; -- 2684836
  l_return_message     VARCHAR2(32000);
  k                    NUMBER;

  l_dimension_level_rec_p BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_dim_level_value_rec_p BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_target_level_rec_p    BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_REC_TYPE;
  l_measure_rec_p         BIS_MEASURE_PUB.Measure_Rec_Type;

  ll_message VARCHAR2(500);

  l_NL           VARCHAR2(1) := fnd_global.newline;

BEGIN


  BIS_UTILITIES_PUB.put_line(p_text =>' ........... START: Notification email ........... ');

  Get_Request_Info
  ( p_measure_instance    => p_measure_instance
  , x_schedule_date       => l_schedule_date
  , x_schedule_time       => l_schedule_time
  , x_schedule_unit       => l_schedule_unit
  , x_schedule_freq       => l_schedule_freq
  , x_next_run_date 	  => l_next_run_date
  , x_next_run_time  	  => l_next_run_time
  , x_description         => l_description
  , x_return_status       => l_return_status
  );

  BIS_CONCURRENT_MANAGER_PVT.Format_Schedule_Freq_Unit
  ( p_schedule_unit       => l_schedule_unit
  , p_schedule_freq       => l_schedule_freq
  , x_schedule_freq_unit  => l_schedule_freq_unit
  );

  Get_Alert_Recipients
  ( p_measure_instance     => p_measure_instance
  , p_dim_level_value_tbl  => p_dim_level_value_tbl
  , p_comparison_result    => p_comparison_result
  , x_Alert_recipients_tbl => l_Alert_recipients_tbl
  , x_Alert_recipients_sh_nm_tbl => l_Alert_recipients_sh_nm_tbl
  , x_number_out_of_range  => l_number_out_of_range
  );

  /*
  BIS_UTILITIES_PUB.put_line(p_text => ' recip count = ' || l_Alert_recipients_tbl.count );
  BIS_UTILITIES_PUB.put_line(p_text => ' Recipt count = ' || l_Alert_recipients_sh_nm_tbl.count );

  for i in 1..l_Alert_recipients_tbl.count loop
    BIS_UTILITIES_PUB.put_line(p_text => ' alert recip  i = ' || i || ' val = ' || l_Alert_recipients_tbl(i) );
  end loop;

  for i in 1..l_Alert_recipients_sh_nm_tbl.count loop
    BIS_UTILITIES_PUB.put_line(p_text => ' Alert recipt  i = ' || i || ' val = ' || l_Alert_recipients_sh_nm_tbl(i) );
  end loop;
  */

  l_measure_rec.measure_id := p_measure_instance.measure_id;

	l_measure_rec_p := l_measure_rec;
  BIS_MEASURE_PUB.Retrieve_Measure
  ( p_api_version           => 1.0
   , p_measure_rec          => l_measure_rec_p
   , x_measure_rec          => l_measure_rec
   , x_return_status        => l_return_status
   , x_error_tbl            => l_error_tbl
   );

  --BIS_UTILITIES_PUB.put_line(p_text =>'Performance Measure: '||l_measure_rec.measure_short_name);
  BIS_PMF_DATA_SOURCE_PUB.Retrieve_Target
  ( p_measure_instance     => p_measure_instance
  , p_dim_level_value_tbl  => p_dim_level_value_tbl
  , x_target_rec           => l_target_rec
  );

  --BIS_UTILITIES_PUB.put_line(p_text =>'Retrive_Target: '||l_target_rec.Target_Id);

  l_target_level_rec.target_level_id := l_target_rec.target_level_id;

  l_target_level_rec.measure_id := l_measure_rec.measure_id;

	l_target_level_rec_p := l_target_level_rec;
  BIS_TARGET_LEVEL_PUB.Retrieve_target_level
  (p_api_version => 1.0
  ,p_target_level_rec => l_target_level_rec_p
  ,x_target_level_rec => l_target_level_rec
  ,x_return_status => l_return_status
  ,x_error_tbl =>  l_error_tbl);

  BIS_PMF_DEFINER_WRAPPER_PVT.Get_Time_Level_Id
  ( p_performance_measure_id => l_measure_rec.measure_id
  , p_target_level_id        => l_target_rec.Target_Level_Id
  , x_sequence_no            => l_sequence_no
  , x_dim_level_id           => l_time_level_id
  , x_dim_level_short_name   => l_time_level_short_name
  , x_dim_level_name         => l_time_level_name
  , x_return_status          => l_return_status
  );


  l_dim_level_value_tbl := p_dim_level_value_tbl;
  For i IN 1..7 Loop
    l_dim_level_value_rec.Dimension_Level_Value_id := p_dim_level_value_tbl(i).Dimension_Level_Value_id;
    if (i=1) then
       l_dim_level_value_rec.dimension_level_id := l_target_level_rec.dimension1_level_id;
       l_dimension_level_rec.dimension_level_id := l_target_level_rec.dimension1_level_id;
       l_dim_level_value_tbl(i).dimension_level_id := l_dim_level_value_rec.dimension_level_id;
    end if;
    if (i=2) then
       l_dim_level_value_rec.dimension_level_id := l_target_level_rec.dimension2_level_id;
       l_dimension_level_rec.dimension_level_id := l_target_level_rec.dimension2_level_id;
       l_dim_level_value_tbl(i).dimension_level_id := l_dim_level_value_rec.dimension_level_id;
    end if;
    if (i=3) then
       l_dim_level_value_rec.dimension_level_id := l_target_level_rec.dimension3_level_id;
       l_dimension_level_rec.dimension_level_id := l_target_level_rec.dimension3_level_id;
       l_dim_level_value_tbl(i).dimension_level_id := l_dim_level_value_rec.dimension_level_id;
    end if;
    if (i=4) then
       l_dim_level_value_rec.dimension_level_id := l_target_level_rec.dimension4_level_id;
       l_dimension_level_rec.dimension_level_id := l_target_level_rec.dimension4_level_id;
       l_dim_level_value_tbl(i).dimension_level_id := l_dim_level_value_rec.dimension_level_id;
    end if;
    if (i=5) then
       l_dim_level_value_rec.dimension_level_id := l_target_level_rec.dimension5_level_id;
       l_dimension_level_rec.dimension_level_id := l_target_level_rec.dimension5_level_id;
       l_dim_level_value_tbl(i).dimension_level_id := l_dim_level_value_rec.dimension_level_id;
    end if;
    if (i=6) then
       l_dim_level_value_rec.dimension_level_id := l_target_level_rec.dimension6_level_id;
       l_dimension_level_rec.dimension_level_id := l_target_level_rec.dimension6_level_id;
       l_dim_level_value_tbl(i).dimension_level_id := l_dim_level_value_rec.dimension_level_id;
    end if;
    if (i=7) then
       l_dim_level_value_rec.dimension_level_id := l_target_level_rec.dimension7_level_id;
       l_dimension_level_rec.dimension_level_id := l_target_level_rec.dimension7_level_id;
       l_dim_level_value_tbl(i).dimension_level_id := l_dim_level_value_rec.dimension_level_id;
    end if;


    IF (l_dim_level_value_rec.Dimension_Level_value_Id IS NOT NULL) then

			 l_dimension_level_rec_p := l_dimension_level_rec;
			 BIS_DIMENSION_LEVEL_PVT.Retrieve_Dimension_Level
       ( p_api_version          => 1.0
       , p_dimension_level_rec  => l_dimension_level_rec_p
       , x_dimension_level_rec  => l_dimension_level_rec
       , x_return_status        => l_return_status
       , x_error_tbl            => l_error_tbl
       );

       v_dim_value_level(i) := l_dimension_level_rec.Dimension_Level_Name;

       v_dim_level(i) := l_dimension_level_rec.Dimension_Level_Short_Name;

       l_dim_level_value_rec_p := l_dim_level_value_rec;
			 BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_To_Value
       ( p_api_version          => 1.0
       , p_dim_level_value_rec  => l_dim_level_value_rec_p
       , x_dim_level_value_rec  => l_dim_level_value_rec
       , x_return_status        => l_return_status
       , x_error_tbl            => l_error_tbl
       );

       v_dim_value(i) := l_dim_level_value_rec.Dimension_Level_Value_Name;

       l_many := i;

   End If;

  End Loop;


  BIS_PMF_DATA_SOURCE_PUB.Retrieve_Actual
  ( p_measure_instance     => p_measure_instance
  , p_dim_level_value_tbl  => l_dim_level_value_tbl
  , x_actual_rec           => l_actual_rec
  );

  BIS_UTILITIES_PUB.put_line(p_text =>'Retrieve_Actual: '||l_actual_rec.Actual);



  begin		-- Begin addition 2164190 sashaik

    bis_actual_pvt.Retrieve_Actual
    (    p_api_version     	=> 1.0
	  ,p_all_info           => 'F'
	  ,p_Actual_Rec         => l_actual_rec
	  ,x_Actual_Rec         => l_actual_rec1
      	  ,x_return_Status      => l_return_Status
	  ,x_error_tbl          => l_error_tbl
    );

    l_formatted_actual := bis_indicator_region_ui_pvt.getAKFormatValue
                          (  p_measure_id => l_measure_rec.measure_id
                           , p_val 	  => l_actual_rec.Actual
                          );

    l_link := l_actual_rec1.Report_URL;

  exception
  	when others then
            BIS_UTILITIES_PUB.put_line(p_text =>'Error in Procedure  BISVIEWER.GET_NOTIFY_RPT_URL : '||sqlerrm);

  end;		-- End addition 2164190 sashaik

  BIS_UTILITIES_PUB.put_line(p_text =>'Link: '||l_link);



  l_role := getAdHocRole(l_Alert_recipients_tbl);
  l_date := sysdate;                        --getDate;
  l_document_type_value
    := Generate_parameter_string
       ( p_target_id          => p_measure_instance.target_id
       , p_comparison_result  => p_comparison_result
       , p_role               => l_role
       , p_date               => l_date
       , p_schedule_date      => l_schedule_date
       , P_schedule_time      => l_schedule_time
       , p_schedule_freq_unit => l_schedule_freq_unit
       , p_next_run_date      => l_next_run_date
       , p_next_run_time      => l_next_run_time
       , p_description        => l_description
       );

--  Generate_Alert_Message
--  ( document_id   => l_document_type_value
--  , display_type  => 'TEST_DISPLAY'
--  , document      => l_message
--  , document_type => l_document_type
--  );

--  BIS_UTILITIES_PUB.put_line(p_text =>'Passing parameters length: '||length(l_document_type_value));
--  BIS_UTILITIES_PUB.put_line(p_text =>'Passing parameters: '||substr(l_document_type_value,0,200));
--  BIS_UTILITIES_PUB.put_line(p_text =>'generated message: '||substr(l_message,0,200));

  FOR i IN 1..l_Alert_recipients_tbl.COUNT LOOP

    BIS_UTILITIES_PUB.put_line(p_text =>'Starting item type: '||l_item_type||', process: '||l_process);

    SELECT bis_excpt_wf_s.nextval
    INTO l_wf_item_key
    FROM dual;

    BIS_UTILITIES_PUB.put_line(p_text =>'wf_item_key: '||l_wf_item_key);
    --BIS_UTILITIES_PUB.put_line(p_text =>'document_type_value: '||l_document_type_value);

    -- create a new workflow process
    --

    wf_engine.CreateProcess
    ( itemtype => l_item_type
    , itemkey  => l_wf_item_key
    , process  => l_process
    );

    -- JSP to Workflow notification HC 10/24/2000
    -- set the workflow attributes


    if l_time_level_short_name is not NULL then

      l_is_rolling_period := bis_utilities_pvt.Is_Rolling_Period_Level
                              ( p_level_short_name => l_time_level_short_name );

      IF ( l_is_rolling_period = 1 ) THEN

        WF_ENGINE.SetItemAttrText
        ( itemtype => l_item_type
        , itemkey  => l_wf_item_key
        , aname    => 'L_SUBJECT'
        , avalue   => l_measure_rec.Measure_Name||' '||v_dim_value_level(l_sequence_no)
        );

        l_rolling_period_end_date := sysdate;
        l_rolling_period_start_date := bis_utilities_pvt.get_Roll_Period_Start_Date
                                        ( p_level_short_name => l_time_level_short_name
                                        , p_end_date         => l_rolling_period_end_date
                                        );

        l_start_label	:= BIS_UTILITIES_PVT.Get_FND_Message('BIS_ROLLING_START');
        l_end_label	:= BIS_UTILITIES_PVT.Get_FND_Message('BIS_ROLLING_END');

      ELSE

        WF_ENGINE.SetItemAttrText
        ( itemtype => l_item_type
        , itemkey  => l_wf_item_key
        , aname    => 'L_SUBJECT'
        , avalue   => l_measure_rec.Measure_Name||' '||v_dim_value(l_sequence_no)
        );

      END IF;

    else

      WF_ENGINE.SetItemAttrText
      ( itemtype => l_item_type
      , itemkey  => l_wf_item_key
      , aname    => 'L_SUBJECT'
      , avalue   => l_measure_rec.Measure_Name
      );
    end if;




    l_label := BIS_UTILITIES_PVT.getPrompt
               (p_attribute_code     => fnd_message.get_string('BIS', 'BIS_ALERT_SUBJECT')
               );  --  BIS_UTILITIES_PUB.put_line(p_text =>'Subject'||l_label);

    WF_ENGINE.SetItemAttrText
    ( itemtype => l_item_type
    , itemkey  => l_wf_item_key
    , aname    => 'L_SUBJECT_LABEL'
    , avalue   => l_label
    );	 --   BIS_UTILITIES_PUB.put_line(p_text =>'subject'||l_label );


    -- set the workflow attributes
    --
    l_label := BIS_UTILITIES_PVT.getPrompt
               (p_attribute_code     => fnd_message.get_string('BIS', 'BIS_ALERT_DETAILS')
               );	 --   BIS_UTILITIES_PUB.put_line(p_text =>'Details'||l_label);

    WF_ENGINE.SetItemAttrText
    ( itemtype => l_item_type
    , itemkey  => l_wf_item_key
    , aname    => 'L_ALERT_DETAILS_LABEL'
    , avalue   => l_label
    );

    l_label := BIS_UTILITIES_PVT.getPrompt
               (p_attribute_code     => fnd_message.get_string('BIS', 'BIS_ALERT_MSG')
               );
--    BIS_UTILITIES_PUB.put_line(p_text =>'Alert Msg'||l_label);
    WF_ENGINE.SetItemAttrText
    ( itemtype => l_item_type
    , itemkey  => l_wf_item_key
    , aname    => 'L_ALERT_MSG'
    , avalue   => l_label
    );

    l_label := BIS_UTILITIES_PVT.getPrompt
               (p_attribute_code     => fnd_message.get_string('BIS', 'BIS_ALERT_RUN_DATE')
               );
--    BIS_UTILITIES_PUB.put_line(p_text =>'Run Date'||l_label);
    WF_ENGINE.SetItemAttrText
    ( itemtype => l_item_type
    , itemkey  => l_wf_item_key
    , aname    => 'L_RUN_DATE_LABEL'
    , avalue   => l_label
    );

    WF_ENGINE.SetItemAttrText
    ( itemtype => l_item_type
    , itemkey  => l_wf_item_key
    , aname    => 'BIS_RUN_DATE'
    , avalue   => l_date
    );


    For counter IN 1..v_dim_value_level.count Loop

      IF (
               ( counter = l_sequence_no )
           AND ( l_is_rolling_period = 1 )
           AND ( v_dim_value_level ( counter ) IS NOT NULL )
         ) THEN

           l_alert_details_label := l_alert_details_label || v_dim_value_level(counter) || ' ' || l_start_label || '<br>';
           l_alert_details       := l_alert_details || l_rolling_period_start_date || '<br>';
           l_alert_details_label := l_alert_details_label || v_dim_value_level(counter) || ' ' || l_end_label || '<br>';
           l_alert_details       := l_alert_details || l_rolling_period_end_date || '<br>';
           l_alert_details1      := l_alert_details1 || v_dim_value_level(counter) || ' ' || l_start_label || ' : ' || l_rolling_period_start_date || l_NL || v_dim_value_level(counter) || ' ' || l_end_label || ' : ' || l_rolling_period_end_date || l_NL;
      ELSE

        if (v_dim_value(counter) IS NOT NULL ) and(v_dim_value_level(counter) IS NOT NULL) then
           -- BIS_UTILITIES_PUB.put_line(p_text =>'Level: '||v_dim_value_level(counter)||' '||v_dim_value(Counter));
           -- rolling change 2 if time level and if rolling period.

           l_alert_details_label := l_alert_details_label||v_dim_value_level(counter)||'<br>';
           l_alert_details       := l_alert_details||v_dim_value(counter)||'<br>';

           l_alert_details1 := l_alert_details1||v_dim_value_level(counter)||' : ' || v_dim_value(counter) || l_NL;

        END If;

      END IF;


    END Loop;


    wf_engine.SetItemAttrText
        ( itemtype => l_item_type
        , itemkey  => l_wf_item_key
        , aname    => 'BIS_DIMENSION_REGION_LABEL'
        , avalue   => l_alert_details_label
        );
    l_alert_details_label := null;
    wf_engine.SetItemAttrText
        ( itemtype => l_item_type
        , itemkey  => l_wf_item_key
        , aname    => 'BIS_DIMENSION_REGION'
        , avalue   => l_alert_details
        );
    l_alert_details := null;

    wf_engine.SetItemAttrText
        ( itemtype => l_item_type
        , itemkey  => l_wf_item_key
        , aname    => 'BIS_DIMENSION_REGION_TXT'
        , avalue   => l_alert_details1
        );
    l_alert_details1 := null;

    BIS_UTILITIES_PUB.put_line(p_text =>'Dimension: '||l_alert_details);

    l_label := BIS_UTILITIES_PVT.getPrompt
               (p_attribute_code     => fnd_message.get_string('BIS', 'BIS_ALERT_PERF_MEASURE')
               );
    BIS_UTILITIES_PUB.put_line(p_text =>'Perf Measure'||l_label);
    wf_engine.SetItemAttrText
        ( itemtype => l_item_type
        , itemkey  => l_wf_item_key
        , aname    => 'L_PERFORMANCE_MEASURE_LABEL'
        , avalue   => l_label);

    wf_engine.SetItemAttrText
        ( itemtype => l_item_type
        , itemkey  => l_wf_item_key
        , aname    => 'L_PERFORMANCE_MEASURE'
        , avalue   => l_measure_rec.Measure_Name
        );

    l_label := BIS_UTILITIES_PVT.getPrompt
               (p_attribute_code     => fnd_message.get_string('BIS', 'BIS_ALERT_UNIT_MEASURE')
               );
    BIS_UTILITIES_PUB.put_line(p_text =>'Unit Of Measure'||l_label);
    wf_engine.SetItemAttrText
        ( itemtype => l_item_type
        , itemkey  => l_wf_item_key
        , aname    => 'L_UNITOFMEASURE_LABEL'
        , avalue   => l_label);

    wf_engine.SetItemAttrText
        ( itemtype => l_item_type
        , itemkey  => l_wf_item_key
        , aname    => 'L_UNITOFMEASURE'
        , avalue   => l_measure_rec.Unit_Of_Measure_Class
        );

    --BIS_UTILITIES_PUB.put_line(p_text =>l_label||': '||p_measure_instance.Measure_Name);

    l_label := BIS_UTILITIES_PVT.getPrompt
               (p_attribute_code     => fnd_message.get_string('BIS', 'BIS_ALERT_TARGET')
               );
    BIS_UTILITIES_PUB.put_line(p_text =>'Target'||l_label);
    wf_engine.SetItemAttrText
        ( itemtype => l_item_type
        , itemkey  => l_wf_item_key
        , aname    => 'L_TARGET_LABEL'
        , avalue   => l_label);

    wf_engine.SetItemAttrText
        ( itemtype => l_item_type
        , itemkey  => l_wf_item_key
        , aname    => 'L_TARGET'
        , avalue   => l_target_rec.Target
        );

   --BIS_UTILITIES_PUB.put_line(p_text =>l_label||': ' ||l_target_rec.Target);

    if (l_number_out_of_range >= 100) then

        l_label := BIS_UTILITIES_PVT.getPrompt
               (p_attribute_code     => fnd_message.get_string('BIS', 'BIS_ALERT_TOLERANCE_RANGE1')
               );
        BIS_UTILITIES_PUB.put_line(p_text =>'Tolerance Range 1'||l_label);

        wf_engine.SetItemAttrText
        ( itemtype => l_item_type
        , itemkey  => l_wf_item_key
        , aname    => 'L_TOLERANCE_RANGE_1_LABEL'
        , avalue   => l_label);

       wf_engine.SetItemAttrText
           ( itemtype => l_item_type
           , itemkey  => l_wf_item_key
           , aname    => 'L_TOLERANCE_RANGE_1'
           , avalue   => l_target_rec.Range1_low || fnd_message.get_string('BIS', 'BIS_ALERT_BELOW') || ' '||l_target_rec.Range1_high||fnd_message.get_string('BIS', 'BIS_ALERT_ABOVE')||' '||l_target_rec.Notify_Resp1_Name); -- 1880142
      --1880142     , avalue   => l_target_rec.Range1_low || ' - ' || l_target_rec.Range1_high||' - '||l_target_rec.Notify_Resp1_Name);

        --BIS_UTILITIES_PUB.put_line(p_text =>l_label||':  '||l_target_rec.Range1_low || ' - ' || l_target_rec.Range1_high);

    end if;

    if ( mod(l_number_out_of_range, 100) >= 10 ) then

       l_label := BIS_UTILITIES_PVT.getPrompt
               (p_attribute_code     => fnd_message.get_string('BIS', 'BIS_ALERT_TOLERANCE_RANGE2')
               );
       BIS_UTILITIES_PUB.put_line(p_text =>'Tolerance Range 2'||l_label);

       wf_engine.SetItemAttrText
        ( itemtype => l_item_type
        , itemkey  => l_wf_item_key
        , aname    => 'L_TOLERANCE_RANGE_2_LABEL'
        , avalue   => l_label);

       wf_engine.SetItemAttrText
           ( itemtype => l_item_type
           , itemkey  => l_wf_item_key
           , aname    => 'L_TOLERANCE_RANGE_2'
           , avalue   => l_target_rec.Range2_low || fnd_message.get_string('BIS', 'BIS_ALERT_BELOW') || ' '||l_target_rec.Range2_high||fnd_message.get_string('BIS', 'BIS_ALERT_ABOVE')||' '||l_target_rec.Notify_Resp2_Name); -- 1880142
           -- 1880142, avalue   => l_target_rec.Range2_low || ' - ' || l_target_rec.Range2_high||' - '||l_target_rec.Notify_Resp2_Name);

       --BIS_UTILITIES_PUB.put_line(p_text =>l_label||':  '||l_target_rec.Range2_low || ' - ' || l_target_rec.Range2_high);

    end if;

    if ( mod(l_number_out_of_range, 100) = 1 ) or ( mod(l_number_out_of_range, 10) = 1 ) then

       l_label := BIS_UTILITIES_PVT.getPrompt
               (p_attribute_code     => fnd_message.get_string('BIS', 'BIS_ALERT_TOLERANCE_RANGE3')
               );

       BIS_UTILITIES_PUB.put_line(p_text =>'Tolerance Range 3'||l_label);

       wf_engine.SetItemAttrText
        ( itemtype => l_item_type
        , itemkey  => l_wf_item_key
        , aname    => 'L_TOLERANCE_RANGE_3_LABEL'
        , avalue   => l_label);

       wf_engine.SetItemAttrText
           ( itemtype => l_item_type
           , itemkey  => l_wf_item_key
           , aname    => 'L_TOLERANCE_RANGE_3'
           , avalue   => l_target_rec.Range3_low || fnd_message.get_string('BIS', 'BIS_ALERT_BELOW') || ' '||l_target_rec.Range3_high||fnd_message.get_string('BIS', 'BIS_ALERT_ABOVE')||' '||l_target_rec.Notify_Resp3_Name); -- 1880142
    --1880142       , avalue   => l_target_rec.Range3_low || ' - ' || l_target_rec.Range3_high||' - '||l_target_rec.Notify_Resp3_Name);

       --BIS_UTILITIES_PUB.put_line(p_text =>l_label||':  '||l_target_rec.Range3_low || ' - ' || l_target_rec.Range3_high);

    end if;


    l_label := BIS_UTILITIES_PVT.getPrompt
               (p_attribute_code     => fnd_message.get_string('BIS', 'BIS_ALERT_ACTUAL')
               );
    BIS_UTILITIES_PUB.put_line(p_text =>'Actual'||l_label);
    wf_engine.SetItemAttrText
        ( itemtype => l_item_type
        , itemkey  => l_wf_item_key
        , aname    => 'L_ACTUAL_LABEL'
        , avalue   => l_label);

    wf_engine.SetItemAttrText
        ( itemtype => l_item_type
        , itemkey  => l_wf_item_key
        , aname    => 'L_ACTUAL'
        , avalue   => l_formatted_actual
        );

    --BIS_UTILITIES_PUB.put_line(p_text =>l_label||': '||l_actual_rec.Actual);

    l_label := BIS_UTILITIES_PVT.getPrompt
               (p_attribute_code     => fnd_message.get_string('BIS', 'BIS_ALERT_INFO')
               );
    BIS_UTILITIES_PUB.put_line(p_text =>'info'||l_label);
    wf_engine.SetItemAttrText
    ( itemtype => l_item_type
    , itemkey  => l_wf_item_key
    , aname    => 'L_RELATED_INFO_LABEL'
    , avalue   => l_label
    );

    If ( l_link is null ) THEN  --  UPPER(l_link) = G_RPT_ERROR then
       l_label := BIS_UTILITIES_PVT.getPrompt
               (p_attribute_code     => fnd_message.get_string('BIS', 'BIS_ALERT_NORPT1')
               );

       wf_engine.SetItemAttrText
       ( itemtype => l_item_type
       , itemkey  => l_wf_item_key
       , aname    => 'L_RELATE_INFO_LABEL'
       , avalue   => l_label
       );
      l_label := BIS_UTILITIES_PVT.getPrompt
               (p_attribute_code     => fnd_message.get_string('BIS', 'BIS_ALERT_NORPT2')
               );

      wf_engine.SetItemAttrText
      ( itemtype => l_item_type
      , itemkey  => l_wf_item_key
      , aname    => 'L_RELATED_INFORMATION'
      , avalue   => l_label
      );

      wf_engine.SetItemAttrText
      ( itemtype => l_item_type
      , itemkey  => l_wf_item_key
      , aname    => 'L_RELATED_INFORMATION_TXT'
      , avalue   => l_label
      );

    Else


      l_label := BIS_UTILITIES_PVT.getPrompt
               (p_attribute_code     => fnd_message.get_string('BIS', 'BIS_ALERT_INFO_MSG')
               );

      wf_engine.SetItemAttrText
      ( itemtype => l_item_type
      , itemkey  => l_wf_item_key
      , aname    => 'L_RELATE_INFO_LABEL'
      , avalue   => l_label
      );
      --l_link := 'www.oracle.com';
      wf_engine.SetItemAttrText
      ( itemtype => l_item_type
      , itemkey  => l_wf_item_key
      , aname    => 'L_RELATED_INFORMATION'
      , avalue   => '<A HREF = '||'"'||l_link||'">'||'BIS REPORT </A>'
      );

      wf_engine.SetItemAttrText
      ( itemtype => l_item_type
      , itemkey  => l_wf_item_key
      , aname    => 'L_RELATED_INFORMATION_TXT'
      , avalue   => 'BIS REPORT'||L_NL||l_link
      );

		End If;

    l_label := BIS_UTILITIES_PVT.getPrompt
               (p_attribute_code     => fnd_message.get_string('BIS', 'BIS_ALERT_RECIPIENTS')
               );
    BIS_UTILITIES_PUB.put_line(p_text =>'Recipients'||l_label);
    wf_engine.SetItemAttrText
    ( itemtype => l_item_type
    , itemkey  => l_wf_item_key
    , aname    => 'L_ALERT_RECIPIENTS_LABEL'
    , avalue   => l_label
    );

    --BIS_UTILITIES_PUB.put_line(p_text =>l_label);
    l_label := BIS_UTILITIES_PVT.getPrompt
               (p_attribute_code     => fnd_message.get_string('BIS', 'BIS_ALERT_REC_MSG')
               );
    BIS_UTILITIES_PUB.put_line(p_text =>'Rec Msg'||l_label);
    wf_engine.SetItemAttrText
    ( itemtype => l_item_type
    , itemkey  => l_wf_item_key
    , aname    => 'L_ALERT_RECIPIENTS_MSG'
    , avalue   => l_label
    );
    --BIS_UTILITIES_PUB.put_line(p_text =>l_label);

    wf_engine.SetItemAttrText
    ( itemtype => l_item_type
    , itemkey  => l_wf_item_key
    , aname    => 'L_ROLE_NAME'
    , avalue   => l_Alert_recipients_sh_nm_tbl(i)
    );

    --BIS_UTILITIES_PUB.put_line(p_text =>'Role: '||l_Alert_recipients_tbl(i));
    l_msg := null;

    FOR j IN 1..l_Alert_recipients_tbl.COUNT LOOP -- 2684836

  	  Get_User_List_From_Role
  	  ( p_recipient_short_name  => l_Alert_recipients_tbl(j)
	  , x_user_tbl              => l_wf_user_table
	  , x_return_status         => l_return_status
	  , x_return_msg            => l_return_message
	  ) ;

	  IF (l_wf_user_table.COUNT = 0) THEN
            l_msg := l_msg||'<SPACER TYPE=horizantal SIZE=16>'||l_Alert_recipients_tbl(j)||'<br>';
            l_msg1 := l_msg1||l_Alert_recipients_tbl(j)|| l_NL;
	  ELSE
	    FOR k IN 1..l_wf_user_table.COUNT LOOP
              l_msg := l_msg||'<SPACER TYPE=horizantal SIZE=16>'||l_wf_user_table(k)||'<br>';
              l_msg1 := l_msg1||l_wf_user_table(k)||l_NL;
            END LOOP;
	  END IF;

    END LOOP;

    wf_engine.SetItemAttrText
    ( itemtype => l_item_type
    , itemkey  => l_wf_item_key
    , aname    => 'L_RECEPIENT'
    , avalue   => l_msg
    );

    wf_engine.SetItemAttrText
    ( itemtype => l_item_type
    , itemkey  => l_wf_item_key
    , aname    => 'L_RECEPIENT_TXT'
    , avalue   => l_msg1
    );
    l_label := BIS_UTILITIES_PVT.getPrompt
               (p_attribute_code     => fnd_message.get_string('BIS', 'BIS_ALERT_SCHEDULE')
               );

    wf_engine.SetItemAttrText
    ( itemtype => l_item_type
    , itemkey  => l_wf_item_key
    , aname    => 'L_ALERT_SCHEDULE'
    , avalue   => l_label
    );
    --BIS_UTILITIES_PUB.put_line(p_text =>'SS');
    BIS_UTILITIES_PUB.put_line(p_text =>'Schedule Date: '||l_schedule_date);
    BIS_UTILITIES_PUB.put_line(p_text =>'Next Run Date: '||l_next_run_date);

    l_msg := null;
    l_label := null; -- 1880142
    if UPPER(l_schedule_unit) <> 'ONCE' then
       if (l_next_run_date IS NOT NULL) then
          wf_engine.SetItemAttrText
          ( itemtype => l_item_type
          , itemkey  => l_wf_item_key
          , aname    => 'NEXT_RUN_DATE'
          , avalue   => l_next_run_date
          );
          l_label := BIS_UTILITIES_PVT.getPrompt
                       (p_attribute_code => BIS_UTILITIES_PVT.Get_FND_Message(
                                              p_message_name   => 'BIS_ALERT_SCHEDULE_MSG1'
                                            , p_msg_param1     => 'NEXT_RUN_DATE'
                                            , p_msg_param1_val => l_next_run_date
                                            )
                       );
          --l_msg := 'The next scheduled run time is '||l_next_run_date||'. ';
       end if;
       if (l_schedule_freq_unit IS NOT NULL) then
           wf_engine.SetItemAttrText
          ( itemtype => l_item_type
          , itemkey  => l_wf_item_key
          , aname    => 'SCHEDULE_INFO'
          -- 1880142, avalue   => l_schedule_freq ||' '||l_schedule_freq_unit
          , avalue   => l_schedule_unit -- 1880142
          );

           l_label := l_label || ' ' || BIS_UTILITIES_PVT.getPrompt
                     (p_attribute_code => BIS_UTILITIES_PVT.Get_FND_Message(
                                            p_message_name   => 'BIS_ALERT_SCHEDULE_MSG2'
                                          , p_msg_param1     => 'SCHEDULE_INFO'
                                          , p_msg_param1_val => l_schedule_unit
                                          )
                     );
          --l_msg := l_msg||'It is scheduled to run on every '||l_schedule_freq||' '||l_schedule_freq_unit||' basis. ';
       end if;

    else

       l_label := BIS_UTILITIES_PVT.getPrompt(p_attribute_code=> fnd_message.get_string('BIS', 'BIS_ALERT_NOT_REPEAT'));

    end if;

    --l_msg := l_msg||'You will only receive an alert if the actual performane measure is outside of the tolerance range.';
    l_label := l_label || ' ' || BIS_UTILITIES_PVT.getPrompt
                          (p_attribute_code     => fnd_message.get_string('BIS', 'BIS_ALERT_SCHEDULE_MSG3')
                          );


    -- Begin addition 1898436

    BIS_PMF_ALERT_REG_PVT.Form_Param_Set_Rec
    ( p_measure_instance     => p_measure_instance
    , p_dim_level_value_tbl  => l_dim_level_value_tbl
    , x_Param_Set_Rec        => l_Param_Set_Rec
    );

    BIS_PMF_ALERT_REG_PVT.Retrieve_Notifiers_Code
    ( p_api_version    => 1.0
    , p_Param_Set_rec  => l_Param_Set_rec
    , x_Notifiers_Code => l_Notifiers_Code
    , x_return_status  => l_return_status
    );

    l_unscubscribe_url := FND_WEB_CONFIG.PLSQL_AGENT
                          || 'bis_corrective_action_pvt.unsub_launch_jsp'
	                  || '?'
 			  || 'pMeasureId=' || l_param_set_rec.PERFORMANCE_MEASURE_ID
			  || '&' || 'pTargetLevelId=' || l_param_set_rec.TARGET_LEVEL_ID
			  || '&' || 'pTargetId=' || l_target_rec.target_id
			  || '&' || 'pTimeDimensionLevelId=' || l_time_level_id
			  || '&' || 'pPlanId=' || l_param_set_rec.PLAN_ID
			  || '&' || 'pNotifiersCode=' || l_param_set_rec.NOTIFIERS_CODE
			  || '&' || 'pParameter1Value=' || l_param_set_rec.PARAMETER1_VALUE
			  || '&' || 'pParameter2Value=' || l_param_set_rec.PARAMETER2_VALUE
			  || '&' || 'pParameter3Value=' || l_param_set_rec.PARAMETER3_VALUE
			  || '&' || 'pParameter4Value=' || l_param_set_rec.PARAMETER4_VALUE
			  || '&' || 'pParameter5Value=' || l_param_set_rec.PARAMETER5_VALUE
			  || '&' || 'pParameter6Value=' || l_param_set_rec.PARAMETER6_VALUE
			  || '&' || 'pParameter7Value=' || l_param_set_rec.PARAMETER7_VALUE;


    l_label := l_label || ' ' || fnd_message.get_string('BIS', 'BIS_PMF_ALERT_UNSUB') ;
    l_label1 := l_label;
    l_label := l_label || ' '
                       || '<a href="'
                       || l_unscubscribe_url
                       || '">'
                       || fnd_message.get_string('BIS', 'BIS_PMF_UNSUBSCRIBE')
                       || '</a>.';

    l_label1 := l_label1 || ' ' ||
                fnd_message.get_string('BIS', 'BIS_PMF_UNSUBSCRIBE') || l_NL ||
                l_unscubscribe_url;

    -- End addition 1898436


    BIS_UTILITIES_PUB.put_line(p_text =>'schedule msg'||l_label);
    wf_engine.SetItemAttrText
    ( itemtype => l_item_type
    , itemkey  => l_wf_item_key
    , aname    => 'L_ALERT_SCHEDULE_MSG'
    , avalue   => l_label
    );

    --BIS_UTILITIES_PUB.put_line(p_text =>l_label);
    wf_engine.SetItemAttrText
    ( itemtype => l_item_type
    , itemkey  => l_wf_item_key
    , aname    => 'L_ALERT_SCHEDULE_MSG'
    , avalue   => l_label
    );

    wf_engine.SetItemAttrText
    ( itemtype => l_item_type
    , itemkey  => l_wf_item_key
    , aname    => 'L_ALERT_SCHEDULE_MSG_TXT'
    , avalue   => l_label1
    );

    wf_engine.SetItemAttrText
    ( itemtype => l_item_type
    , itemkey  => l_wf_item_key
    , aname    => 'BIS_ALERT_DOC'
    , avalue   => 'PLSQLCLOB:BIS_CORRECTIVE_ACTION_PVT.GenerateAlerts/'||l_item_type || ':' || l_wf_item_key);

    wf_engine.StartProcess
    ( itemtype => l_item_type
    , itemkey  => l_wf_item_key
    );

    /*
    BIS_UTILITIES_PUB.put_line(p_text =>'Started workflow '||i||'. item type: '||l_item_type
    ||', process: '||l_process
    ||', item key: '||l_wf_item_key
    ||', notified: '||l_Alert_recipients_tbl(i));
    */

    commit;

  END LOOP;

  BIS_UTILITIES_PUB.put_line(p_text =>' ........... END : Notification email ........... ');

EXCEPTION
  when FND_API.G_EXC_ERROR then
   BIS_UTILITIES_PUB.put_line(p_text =>'exception 1 at Send_Alert: '||sqlerrm);
   wf_core.context
   ( 'BIS_CORRECTIVE_ACTION_PVT'
   , 'Send_Alert'
   , l_item_type
   , l_wf_item_key
   );
   RETURN;
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    BIS_UTILITIES_PUB.put_line(p_text =>'exception 2 at Send_Alert: '||sqlerrm);
    wf_core.context
    ( 'BIS_CORRECTIVE_ACTION_PVT'
    , 'Send_Alert'
    , l_item_type
    , l_wf_item_key
    );
    RETURN;
  when others then
   BIS_UTILITIES_PUB.put_line(p_text =>'exception 3 at Send_Alert: '||sqlerrm);
   wf_core.context
   ( 'BIS_CORRECTIVE_ACTION_PVT'
   , 'Send_Alert'
   , l_item_type
   , l_wf_item_key
   );
   RETURN;

END Send_Alert;



PROCEDURE Get_User_List_From_Role -- 2684836
( p_recipient_short_name  IN  VARCHAR2
, x_user_tbl              OUT NOCOPY wf_directory.UserTable
, x_return_status         OUT NOCOPY VARCHAR2
, x_return_msg            OUT NOCOPY VARCHAR2
)
IS

  l_user_tbl     wf_directory.UserTable;
  l_num_users    NUMBER := 0;

BEGIN

  IF (
       ( BIS_UTILITIES_PUB.Value_Missing(p_recipient_short_name) = FND_API.G_TRUE ) OR
	   ( BIS_UTILITIES_PUB.Value_Null(p_recipient_short_name) = FND_API.G_TRUE )
     ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
	x_return_msg := 'Recipient short name is null or missing.';
	RETURN;
  END IF;


  wf_directory.GetRoleUsers(p_recipient_short_name, l_user_tbl);
  x_user_tbl := l_user_tbl;
  x_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
	x_return_msg := 'Exception occurred in BISVCACB.Get_User_List_From_Role : ' || sqlerrm;
END Get_User_List_From_Role;


Function Get_Role
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_comparison_result     IN VARCHAR2
)
RETURN VARCHAR2
IS

BEGIN
  return null;
END Get_Role;

Procedure Get_Alert_Recipients
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_comparison_result     IN VARCHAR2
, x_Alert_recipients_tbl  OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
, x_Alert_recipients_sh_nm_tbl OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
, x_number_out_of_range    OUT NOCOPY NUMBER
)
IS

  l_Param_Set_Rec BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type;
  l_Param_Set_Tbl BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type;
  l_Target_owners_rec BIS_TARGET_PUB.Target_Owners_Rec_Type;
  l_Alert_recipients_tbl BIS_UTILITIES_PUB.BIS_VARCHAR_TBL;
  l_Alert_recipients_sh_nm_tbl BIS_UTILITIES_PUB.BIS_VARCHAR_TBL;
  l_notifiers_code    VARCHAR2(32000);
  l_user_tbl          wf_directory.UserTable;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_return_status  VARCHAR2(32000);

BEGIN

  BIS_PMF_ALERT_REG_PVT.Form_Param_Set_Rec
  ( p_measure_instance     => p_measure_instance
  , p_dim_level_value_tbl  => p_dim_level_value_tbl
  , x_Param_Set_Rec        => l_Param_Set_Rec
  );

    /*
    BIS_UTILITIES_PUB.put_line(p_text =>'Formed Param set ');
    BIS_UTILITIES_PUB.put_line(p_text =>'REGISTRATION_ID  : '||l_param_set_rec.REGISTRATION_ID);
    BIS_UTILITIES_PUB.put_line(p_text =>'PERFORMANCE_MEASURE_ID: '
      ||l_param_set_rec.PERFORMANCE_MEASURE_ID );
    BIS_UTILITIES_PUB.put_line(p_text =>'TARGET_LEVEL_ID  : '||l_param_set_rec.TARGET_LEVEL_ID);
    BIS_UTILITIES_PUB.put_line(p_text =>'TIME_DIMENSION_LEVEL_ID: '
      ||l_param_set_rec.TIME_DIMENSION_LEVEL_ID);
    BIS_UTILITIES_PUB.put_line(p_text =>'PLAN_ID          : '||l_param_set_rec.PLAN_ID);
    BIS_UTILITIES_PUB.put_line(p_text =>'NOTIFIERS_CODE   : '||l_param_set_rec.NOTIFIERS_CODE);
    BIS_UTILITIES_PUB.put_line(p_text =>'PARAMETER1_VALUE : '||l_param_set_rec.PARAMETER1_VALUE);
    BIS_UTILITIES_PUB.put_line(p_text =>'PARAMETER2_VALUE : '||l_param_set_rec.PARAMETER2_VALUE);
    BIS_UTILITIES_PUB.put_line(p_text =>'PARAMETER3_VALUE : '||l_param_set_rec.PARAMETER3_VALUE);
    BIS_UTILITIES_PUB.put_line(p_text =>'PARAMETER4_VALUE : '||l_param_set_rec.PARAMETER4_VALUE);
    BIS_UTILITIES_PUB.put_line(p_text =>'PARAMETER5_VALUE : '||l_param_set_rec.PARAMETER5_VALUE);
    BIS_UTILITIES_PUB.put_line(p_text =>'PARAMETER6_VALUE : '||l_param_set_rec.PARAMETER6_VALUE);
    BIS_UTILITIES_PUB.put_line(p_text =>'PARAMETER7_VALUE : '||l_param_set_rec.PARAMETER7_VALUE);
    BIS_UTILITIES_PUB.put_line(p_text =>'NOTIFY_OWNER_FLAG: '||l_param_set_rec.NOTIFY_OWNER_FLAG);
    */

  BIS_PMF_ALERT_REG_PVT.Retrieve_Parameter_set
  ( p_api_version      => 1.0
  , p_Param_Set_Rec    => l_param_set_rec
  , x_Param_Set_tbl    => l_param_set_tbl
  , x_return_status    => l_return_status
  , x_error_Tbl        => l_error_Tbl
  );
  /*
  FOR i IN l_param_set_tbl.FIRST..l_param_set_tbl.LAST LOOP
    BIS_UTILITIES_PUB.put_line(p_text =>'    Param set '||i);
    BIS_UTILITIES_PUB.put_line(p_text =>'REGISTRATION_ID  : '||l_param_set_tbl(i).REGISTRATION_ID);
    BIS_UTILITIES_PUB.put_line(p_text =>'PERFORMANCE_MEASURE_ID: '
      ||l_param_set_tbl(i).PERFORMANCE_MEASURE_ID );
    BIS_UTILITIES_PUB.put_line(p_text =>'TARGET_LEVEL_ID  : '||l_param_set_tbl(i).TARGET_LEVEL_ID);
    BIS_UTILITIES_PUB.put_line(p_text =>'TIME_DIMENSION_LEVEL_ID: '
      ||l_param_set_tbl(i).TIME_DIMENSION_LEVEL_ID);
    BIS_UTILITIES_PUB.put_line(p_text =>'PLAN_ID          : '||l_param_set_tbl(i).PLAN_ID);
    BIS_UTILITIES_PUB.put_line(p_text =>'NOTIFIERS_CODE   : '||l_param_set_tbl(i).NOTIFIERS_CODE);
    BIS_UTILITIES_PUB.put_line(p_text =>'PARAMETER1_VALUE : '||l_param_set_tbl(i).PARAMETER1_VALUE);
    BIS_UTILITIES_PUB.put_line(p_text =>'PARAMETER2_VALUE : '||l_param_set_tbl(i).PARAMETER2_VALUE);
    BIS_UTILITIES_PUB.put_line(p_text =>'PARAMETER3_VALUE : '||l_param_set_tbl(i).PARAMETER3_VALUE);
    BIS_UTILITIES_PUB.put_line(p_text =>'PARAMETER4_VALUE : '||l_param_set_tbl(i).PARAMETER4_VALUE);
    BIS_UTILITIES_PUB.put_line(p_text =>'PARAMETER5_VALUE : '||l_param_set_tbl(i).PARAMETER5_VALUE);
    BIS_UTILITIES_PUB.put_line(p_text =>'PARAMETER6_VALUE : '||l_param_set_tbl(i).PARAMETER6_VALUE);
    BIS_UTILITIES_PUB.put_line(p_text =>'PARAMETER7_VALUE : '||l_param_set_tbl(i).PARAMETER7_VALUE);
    BIS_UTILITIES_PUB.put_line(p_text =>'NOTIFY_OWNER_FLAG: '||l_param_set_tbl(i).NOTIFY_OWNER_FLAG);
  END LOOP;
  */

  IF l_param_set_tbl.COUNT <> 1 THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'odd number of param set found in Get_Alert_Recipients: '
    ||l_param_set_tbl.count);
    return;
  ELSE
    BIS_UTILITIES_PUB.put_line(p_text =>'Getting Target owners');
    BIS_UTILITIES_PUB.put_line(p_text =>'Check: '||p_measure_instance.target_level_id);
    BIS_UTILITIES_PUB.put_line(p_text =>'Check2: '||p_measure_instance.range1_owner_short_name);
    BIS_PMF_DATA_SOURCE_PUB.Retrieve_Target_Owners
    ( p_measure_instance       => p_measure_instance
    , p_dim_level_value_tbl    => p_dim_level_value_tbl
    , p_all_info               => FND_API.G_FALSE
    , x_target_Owners_rec      => l_target_Owners_rec
    );
    Get_Result_Owners
    ( p_target_Owners_rec      => l_target_owners_rec
    , p_comparison_result      => p_comparison_result
    , x_owners_tbl             => l_Alert_recipients_tbl
    , x_owners_sh_nm_tbl       => l_Alert_recipients_sh_nm_tbl
    , x_number_out_of_range    => x_number_out_of_range
    );

    BIS_UTILITIES_PUB.put_line(p_text =>'total number of owners: '||l_Alert_recipients_tbl.count);

    l_notifiers_code := l_param_set_tbl(l_param_set_tbl.FIRST).NOTIFIERS_CODE;
    wf_directory.GetRoleUsers(l_notifiers_code,l_user_tbl);
    IF l_user_tbl.COUNT > 0 THEN
      l_Alert_recipients_tbl(l_Alert_recipients_tbl.COUNT+1) := l_notifiers_code;
      l_Alert_recipients_sh_nm_tbl(l_Alert_recipients_sh_nm_tbl.COUNT+1) := l_notifiers_code;
      BIS_UTILITIES_PUB.put_line(p_text =>'Recipients include '||l_user_tbl.COUNT||' subscriber(s)');
      /*
      FOR i IN 1..l_user_tbl.COUNT LOOP
        BIS_UTILITIES_PUB.put_line(p_text =>i||')'||l_user_tbl(i));
      END LOOP;
      */
    ELSE
      BIS_UTILITIES_PUB.put_line(p_text =>'No subscribers for this alert.');
      null;
    END IF;
  END IF;

  --BIS_UTILITIES_PUB.put_line(p_text =>'get alert recipients returned: '||l_Alert_recipients_tbl.COUNT);
  FOR i IN 1..l_Alert_recipients_sh_nm_tbl.COUNT LOOP
    BIS_UTILITIES_PUB.put_line(p_text =>'Notification will be sent to: '|| l_Alert_recipients_sh_nm_tbl(i));
  END LOOP;

  x_Alert_recipients_tbl := l_Alert_recipients_tbl;
  x_Alert_recipients_sh_nm_tbl := l_Alert_recipients_sh_nm_tbl;

EXCEPTION
  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'exception at Get_Alert_Recipients: '||sqlerrm);
END Get_Alert_Recipients;

PROCEDURE Get_Result_Owners
( p_target_Owners_rec      IN BIS_TARGET_PUB.Target_Owners_Rec_Type
, p_comparison_result      IN VARCHAR2
, x_owners_tbl             OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
, x_owners_sh_nm_tbl       OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
, x_number_out_of_range    OUT NOCOPY NUMBER
)
IS
  l_owners_tbl BIS_UTILITIES_PUB.BIS_VARCHAR_TBL;
  l_owners_sh_nm_tbl BIS_UTILITIES_PUB.BIS_VARCHAR_TBL;

  l_number_out_of_range NUMBER := 0;
  l_first_out_of_range  NUMBER := 0;
  l_second_out_of_range  NUMBER := 0;
  l_third_out_of_range  NUMBER := 0;

BEGIN

  /*
    BIS_UTILITIES_PUB.put_line(p_text => ' owner 1 name = ' ||  p_target_Owners_rec.Range1_Owner_Name ) ;
    BIS_UTILITIES_PUB.put_line(p_text => ' owner 1 short name = ' ||  p_target_Owners_rec.Range1_Owner_short_Name ) ;
    BIS_UTILITIES_PUB.put_line(p_text => ' owner 2 name = ' ||  p_target_Owners_rec.Range2_Owner_Name ) ;
    BIS_UTILITIES_PUB.put_line(p_text => ' owner 2 short name = ' ||  p_target_Owners_rec.Range2_Owner_short_Name ) ;
    BIS_UTILITIES_PUB.put_line(p_text => ' owner 3 name = ' ||  p_target_Owners_rec.Range3_Owner_Name ) ;
    BIS_UTILITIES_PUB.put_line(p_text => ' owner 3 short name = ' ||  p_target_Owners_rec.Range3_Owner_short_Name ) ;
  */

  l_owners_tbl := x_owners_tbl;

  IF
    p_comparison_result >= BIS_GENERIC_PLANNER_PVT.G_COMP_RESULT_OUT_OF_RANGE1
    --p_target_Owners_rec.Range1_Owner_Name is not null
  THEN
    l_owners_tbl(l_owners_tbl.COUNT+1) := p_target_Owners_rec.Range1_Owner_Name;
    l_owners_sh_nm_tbl(l_owners_sh_nm_tbl.COUNT+1) := p_target_Owners_rec.Range1_Owner_short_Name;
    l_first_out_of_range  := 1;

  END IF;
  IF
    p_comparison_result >= BIS_GENERIC_PLANNER_PVT.G_COMP_RESULT_OUT_OF_RANGE2
    --p_target_Owners_rec.Range2_Owner_Name is not null
  THEN
    l_owners_tbl(l_owners_tbl.COUNT+1) := p_target_Owners_rec.Range2_Owner_Name;
    l_owners_sh_nm_tbl(l_owners_sh_nm_tbl.COUNT+1) := p_target_Owners_rec.Range2_Owner_short_Name;
    l_second_out_of_range  := 1;

  END IF;
  IF
    p_comparison_result >= BIS_GENERIC_PLANNER_PVT.G_COMP_RESULT_OUT_OF_RANGE3
    --p_target_Owners_rec.Range3_Owner_Name is not null
  THEN
    l_owners_tbl(l_owners_tbl.COUNT+1) := p_target_Owners_rec.Range3_Owner_Name;
    l_owners_sh_nm_tbl(l_owners_sh_nm_tbl.COUNT+1) := p_target_Owners_rec.Range3_Owner_short_Name;
    l_third_out_of_range  := 1;
  END IF;

  x_owners_tbl := l_owners_tbl;
  x_owners_sh_nm_tbl := l_owners_sh_nm_tbl;

  -- BIS_UTILITIES_PUB.put_line(p_text => ' get result owners owners count ' || l_owners_tbl.COUNT || ' sh nm dt ' || l_owners_sh_nm_tbl.COUNT ) ;

  l_number_out_of_range := 100*l_first_out_of_range + 10*l_second_out_of_range + l_third_out_of_range ;
  x_number_out_of_range := l_number_out_of_range;

EXCEPTION
  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'exception at Get_Result_Owners: '||sqlerrm);

END Get_Result_Owners;

Procedure Get_Performance_Measure_Msg
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_comparison_result     IN VARCHAR2
, x_message_tbl           OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
)
IS

  l_target_level_rec    BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
  l_target_rec          BIS_TARGET_PUB.Target_Rec_Type;

  l_message_tbl BIS_UTILITIES_PUB.BIS_VARCHAR_TBL;
  l_Message_Banner_tbl BIS_UTILITIES_PUB.BIS_VARCHAR_TBL;
  l_Message_Intro_tbl BIS_UTILITIES_PUB.BIS_VARCHAR_TBL;
  l_Message_body_tbl BIS_UTILITIES_PUB.BIS_VARCHAR_TBL;
  l_notify VARCHAR2(32000);
  l_sent_date VARCHAR2(32000);

BEGIN

  -- Retrieve Performance Target information
  --
  BIS_PMF_DATA_SOURCE_PUB.Retrieve_Target_Level
  ( p_measure_instance       => p_measure_instance
  , p_dim_level_value_tbl    => p_dim_level_value_tbl
  , p_all_info               => FND_API.G_TRUE
  , x_target_level_rec       => l_target_level_rec
  );
  BIS_PMF_DATA_SOURCE_PUB.Retrieve_Target
  ( p_measure_instance       => p_measure_instance
  , p_dim_level_value_tbl    => p_dim_level_value_tbl
  , p_all_info               => FND_API.G_TRUE
  , x_target_rec             => l_target_rec
  );
  l_sent_Date := getdate; -- to_char(sysdate,'DD-MON-YYYY HH24:MM:SS'); -- 2837974

  IF
    p_comparison_result = BIS_CORRECTIVE_ACTION_PUB.G_MSG_TYPE_EXCEPTION_RANGE1
  THEN
    l_notify := l_target_rec.Notify_Resp1_Name;
  ELSIF
    p_comparison_result = BIS_CORRECTIVE_ACTION_PUB.G_MSG_TYPE_EXCEPTION_RANGE2
  THEN
    l_notify := l_target_rec.Notify_Resp2_Name;
  ELSIF
    p_comparison_result = BIS_CORRECTIVE_ACTION_PUB.G_MSG_TYPE_EXCEPTION_RANGE3
  THEN
    l_notify := l_target_rec.Notify_Resp3_Name;
  END IF;

  Get_Message_Banner
  ( p_Sent_Date          => l_sent_date
  , p_Item               => l_target_level_rec.Workflow_Process_Name
  , p_to                 => l_notify
  , x_Message_Banner_tbl => l_Message_Banner_tbl
  );

  Get_Message_Intro
  ( p_Sent_Date         => l_sent_date
  , x_Message_Intro_tbl => l_Message_Intro_tbl
  );

  Get_Message_Body
  ( p_measure_instance    => p_measure_instance
  , p_dim_level_value_tbl => p_dim_level_value_tbl
  , p_comparison_result   => p_comparison_result
  , x_message_body_tbl    => l_message_body_tbl
  );

  -- Build message;
  --
  FOR i IN 1..l_Message_Banner_tbl.COUNT LOOP
    l_message_tbl(l_message_tbl.COUNT+1) := l_Message_Banner_tbl(i);
  END LOOP;

  FOR i IN 1..l_Message_intro_tbl.COUNT LOOP
    l_message_tbl(l_message_tbl.COUNT+1) := l_Message_intro_tbl(i);
  END LOOP;

  FOR i IN 1..l_Message_body_tbl.COUNT LOOP
    l_message_tbl(l_message_tbl.COUNT+1) := l_Message_body_tbl(i);
  END LOOP;

  x_message_tbl := l_message_tbl;

EXCEPTION
   WHEN OTHERS THEN
     BIS_UTILITIES_PUB.put_line(p_text =>'error in Get_Performance_Measure_Msg: '||sqlerrm);

END Get_Performance_Measure_Msg;

Procedure Get_Message_Banner
( p_Sent_Date          IN VARCHAR2
, p_Item               IN VARCHAR2
, p_to                 IN VARCHAR2
, x_Message_Banner_tbl OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
)
IS

  l_Message_Banner_tbl BIS_UTILITIES_PUB.BIS_VARCHAR_TBL;

BEGIN

  x_message_banner_tbl := l_message_banner_tbl;

END  Get_Message_Banner;

Procedure Get_Message_Intro
( p_Sent_Date      IN VARCHAR2
, x_Message_Intro_tbl  OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
)
IS

BEGIN
null;
END Get_Message_Intro;

Procedure Get_Message_Body
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_comparison_result     IN VARCHAR2
, x_message_body_tbl      OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
)
IS

BEGIN
null;
END Get_Message_Body;

Procedure Get_Alert_Information
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_Alert_Information_tbl OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
)
IS

BEGIN
null;
END Get_Alert_Information;

Procedure Get_Related_Links
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_Related_Links_tbl     OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
)
IS

BEGIN
null;
END Get_Related_Links;

Procedure Get_Report_Attachement
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_attachement_url_tbl   OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
)
IS

BEGIN

  null;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RETURN;
   when others then
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Get_Report_Attachement'
      );
      RETURN;

END Get_Report_Attachement;


Procedure Get_Alert_Message
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_Alert_Message_tbl     OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
)
IS

BEGIN
null;
END Get_Alert_Message;

Procedure Set_Message
( p_message_tbl           IN BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
, x_return_status         OUT NOCOPY VARCHAR2
)
IS

BEGIN
null;
END Set_Message;

Procedure Generate_Alert_Message
( document_id    IN VARCHAR2
, display_type   IN VARCHAR2
, document       IN OUT NOCOPY VARCHAR2
, document_type  IN OUT NOCOPY VARCHAR2
)
IS

 l_message       varchar2(32000) := NULL;
 l_redirect      varchar2(32000) := NULL;
 l_servlet_agent varchar2(32000) := NULL;
 l_encrypted_session_id	VARCHAR2(1000);
 l_session_id		NUMBER;
 l_document      varchar2(32000);
 l_amp           varchar2(10) := '&';
 l_target_id     varchar2(32000);
 l_wait_msg      varchar2(32000) :=
   BIS_UTILITIES_PVT.Get_FND_Message
   ( p_message_name => 'BIS_ALERT_RETRIEVING_MSG' );

BEGIN

  l_servlet_agent := Get_Servlet_Agent;
  --l_target_id := document_id;
  l_session_id := icx_sec.getsessioncookie;
  l_encrypted_session_id :=
    icx_call.encrypt3(icx_sec.getID(icx_Sec.PV_SESSION_ID));

  l_redirect :=
    '<HEAD> <META HTTP-EQUIV="Refresh" '
    ||'CONTENT="1;URL='||l_servlet_agent||G_NOTIFICATION_JSP_PAGE
    ||'?dbc='||FND_WEB_CONFIG.DATABASE_ID
    ||l_amp||'sessionid='||l_encrypted_session_id
    ||document_id
    ||'">'
    ||bis_utilities_pub.encode(l_wait_msg)   -- 2418741
    ||' </HEAD> ';

  l_message := l_redirect;
  --BIS_UTILITIES_PUB.put_line(p_text =>'notification redirect: '||l_message);

  document := l_message;
  document_type := 'text/html';
  return;

EXCEPTION
  when others then
    BIS_UTILITIES_PUB.put_line(p_text =>'exception at Generate_Alert_Message;: '||sqlerrm);
    RETURN;

END Generate_Alert_Message;

FUNCTION Get_Servlet_Agent RETURN VARCHAR2
IS

 l_servlet_agent varchar2(32000) := NULL;
 l_dir_tmp varchar2(32000);

BEGIN

  l_servlet_agent :=
    FND_WEB_CONFIG.TRAIL_SLASH(fnd_profile.value('APPS_SERVLET_AGENT'));

  RETURN l_servlet_agent;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'No such agent defined at site level.');

  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'General exception while getting servlet agent: '||sqlerrm);

End Get_Servlet_Agent;

Procedure Get_Request_Info
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, x_schedule_date         OUT NOCOPY VARCHAR2
, x_schedule_time         OUT NOCOPY VARCHAR2
, x_schedule_unit         OUT NOCOPY VARCHAR2
, x_schedule_freq         OUT NOCOPY VARCHAR2
, x_next_run_date         OUT NOCOPY VARCHAR2
, x_next_run_time         OUT NOCOPY VARCHAR2
, x_description           OUT NOCOPY VARCHAR2
, x_return_status         OUT NOCOPY VARCHAR2
)
IS

  l_Param_Set_Rec BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type;

BEGIN
  BIS_PMF_ALERT_REG_PVT.Form_Param_Set_Rec
  ( p_measure_instance     => p_measure_instance
  , x_Param_Set_Rec        => l_Param_Set_Rec
  );

  /*
  BIS_UTILITIES_PUB.put_line(p_text =>'Getting request information. measure id: '
    ||l_Param_Set_Rec.performance_measure_id||', target level: '
    ||l_Param_Set_Rec.target_level_id);
  */

  BIS_CONCURRENT_MANAGER_PVT.Get_Request_Schedule_Info
  ( p_Param_Set_rec       => l_Param_Set_rec
  , x_schedule_date       => x_schedule_date
  , x_schedule_time       => x_schedule_time
  , x_schedule_unit       => x_schedule_unit
  , x_schedule_freq       => x_schedule_freq
  , x_schedule_freq_unit  => x_schedule_unit
  , x_schedule_end_date   => x_schedule_date
  , x_schedule_end_time   => x_schedule_time
  , x_next_run_date  	  => x_next_run_date
  , x_next_run_time  	  => x_next_run_time
  , x_description         => x_description
  , x_return_status       => x_return_status
  );

  BIS_UTILITIES_PUB.put_line(p_text =>'Request description: '||x_description);
  BIS_UTILITIES_PUB.put_line(p_text =>'Schedule Date: '||x_schedule_date);

EXCEPTION
  WHEN OTHERS THEN
  BIS_UTILITIES_PUB.put_line(p_text =>'error at Get_Request_Info: '||sqlerrm);

END Get_Request_Info;

FUNCTION getDate
RETURN VARCHAR2
IS

  l_date_format VARCHAR2(32000);
  l_date        VARCHAR2(32000);

BEGIN

   fnd_profile.get('ICX_DATE_FORMAT_MASK',l_date_format);
   select to_char(sysdate,l_date_format)
   into l_date
   from dual;

   return l_date;

EXCEPTION
  WHEN OTHERS THEN
  l_date := sysdate;
  RETURN l_date;

END getDate;

FUNCTION getAdHocRole
( p_Alert_recipients_tbl IN BIS_UTILITIES_PUB.BIS_VARCHAR_TBL )
RETURN VARCHAR2
IS
  l_role VARCHAR2(32000);
  l_bis_alert VARCHAR2(32000);
  colon  NUMBER;
BEGIN

  FOR i IN 1..p_Alert_recipients_tbl.COUNT LOOP
    colon := instr(p_Alert_recipients_tbl(i), ':');
    l_bis_alert := substr(p_Alert_recipients_tbl(i),0,colon-1);

    IF (l_bis_alert = BIS_PMF_ALERT_REG_PVT.G_BIS_ALERT_ROLE) THEN
      l_role := p_Alert_recipients_tbl(i);
      BIS_UTILITIES_PUB.put_line(p_text =>'Got AddHocRole: '||l_role);
    END IF;
  END LOOP;

  return l_role;

EXCEPTION
  WHEN OTHERS THEN
  l_role := NULL;
  RETURN l_role;

END getAdHocRole;

FUNCTION Format_Message(p_message_tbl IN BIS_UTILITIES_PUB.BIS_VARCHAR_TBL)
RETURN VARCHAR2
IS

  msg_len               NUMBER;
  new_len               NUMBER;
  acceptable_len        NUMBER;
  l_message             VARCHAR2(32000);

BEGIN

  FOR i IN 1..p_message_tbl.COUNT LOOP
    msg_len := length(l_message);
    new_len := length(p_message_tbl(i));
    acceptable_len := 32000-msg_len;
    IF msg_len < 32000 AND new_len <= acceptable_len
    THEN
      l_message := l_message||p_message_tbl(i);
    ELSE
      exit;
    END IF;
  END LOOP;

  Return l_message;

EXCEPTION
  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'Exception while formatting message: '||sqlerrm);

END Format_Message;

Procedure Get_Workflow_Info
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_comparison_result     IN VARCHAR2
, x_item_type             OUT NOCOPY VARCHAR2
, x_process               OUT NOCOPY VARCHAR2
)
IS

  l_target_level_rec    BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;

BEGIN

  BIS_PMF_DATA_SOURCE_PUB.Retrieve_Target_Level
  ( p_measure_instance       => p_measure_instance
  , p_dim_level_value_tbl    => p_dim_level_value_tbl
  , p_all_info   	     => FND_API.G_FALSE
  , x_target_level_rec       => l_target_level_rec
  );
  x_item_type := l_target_level_rec.Workflow_Item_Type;
  x_process := l_target_level_rec.Workflow_Process_Short_Name;

EXCEPTION
  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'Exception while getting workflow info: '||sqlerrm);

END Get_Workflow_Info;

FUNCTION Generate_parameter_string
( p_target_id             IN VARCHAR2
, p_comparison_result     IN VARCHAR2
, p_role                  IN VARCHAR2
, p_date                  IN VARCHAR2
, p_schedule_date         IN VARCHAR2
, P_schedule_time         IN VARCHAR2
, p_schedule_freq_unit    IN VARCHAR2
, p_next_run_date         IN VARCHAR2
, p_next_run_time         IN VARCHAR2
, p_description           IN VARCHAR2
) RETURN VARCHAR2
IS

  l_parameters            VARCHAR2(32000);
  l_amp                   VARCHAR2(10) := '&';
  l_target_id             VARCHAR2(1000);
  l_comparison_result     VARCHAR2(1000);
  l_role                  VARCHAR2(1000);
  l_date                  VARCHAR2(1000);
  l_schedule_date         VARCHAR2(1000);
  l_schedule_time         VARCHAR2(1000);
  l_schedule_freq_unit    VARCHAR2(1000);
  l_next_run_date         VARCHAR2(1000);
  l_next_run_time         VARCHAR2(1000);
  l_description           VARCHAR2(32000);

BEGIN
  -- 2280993 starts
/*
  l_target_id          := wfa_html.conv_special_url_chars(p_target_id);
  l_comparison_result  := wfa_html.conv_special_url_chars(p_comparison_result);
  l_role               := wfa_html.conv_special_url_chars(p_role);
  l_date               := wfa_html.conv_special_url_chars(p_date);
  l_schedule_date      := wfa_html.conv_special_url_chars(p_schedule_date);
  L_schedule_time      := wfa_html.conv_special_url_chars(P_schedule_time);
  l_schedule_freq_unit:= wfa_html.conv_special_url_chars(p_schedule_freq_unit);
  l_next_run_date      := wfa_html.conv_special_url_chars(p_next_run_date);
  l_next_run_time      := wfa_html.conv_special_url_chars(p_next_run_time);
  l_description        := wfa_html.conv_special_url_chars(p_description);
*/
  l_target_id          := BIS_UTILITIES_PUB.encode(p_target_id);
  l_comparison_result  := BIS_UTILITIES_PUB.encode(p_comparison_result);
  l_role               := BIS_UTILITIES_PUB.encode(p_role);
  l_date               := BIS_UTILITIES_PUB.encode(p_date);
  l_schedule_date      := BIS_UTILITIES_PUB.encode(p_schedule_date);
  L_schedule_time      := BIS_UTILITIES_PUB.encode(P_schedule_time);
  l_schedule_freq_unit := BIS_UTILITIES_PUB.encode(p_schedule_freq_unit);
  l_next_run_date      := BIS_UTILITIES_PUB.encode(p_next_run_date);
  l_next_run_time      := BIS_UTILITIES_PUB.encode(p_next_run_time);
  l_description        := BIS_UTILITIES_PUB.encode(p_description);

  -- 2280993 ends

  l_parameters
    := l_amp||'target_id='||l_target_id
    ||l_amp||'compResult='||l_comparison_result
    ||l_amp||'adHocRole='||l_role
    ||l_amp||'sentDate='||l_date
    ||l_amp||'scheduleDate='||l_schedule_date
    ||l_amp||'scheduleTime='||l_schedule_time
    ||l_amp||'scheduleUnit='||l_schedule_freq_unit
    ||l_amp||'nextRunDate='||l_next_run_date
    ||l_amp||'nextRunTime='||l_next_run_time
    ||l_amp||'alertDesc='||l_description
    ;
  return l_parameters;

EXCEPTION
  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'Exception while generating parameter string: '||sqlerrm);

END Generate_parameter_string;




PROCEDURE unsub_launch_jsp -- 1898436
( pMeasureId        IN VARCHAR2 := NULL
, pTargetLevelId    IN VARCHAR2 := NULL
, pTargetId         IN VARCHAR2 := NULL
, pTimeDimensionLevelId IN VARCHAR2 := NULL
, pPlanId           IN VARCHAR2 := NULL
, pNotifiersCode    IN VARCHAR2 := NULL
, pParameter1Value  IN VARCHAR2 := NULL
, pParameter2Value  IN VARCHAR2 := NULL
, pParameter3Value  IN VARCHAR2 := NULL
, pParameter4Value  IN VARCHAR2 := NULL
, pParameter5Value  IN VARCHAR2 := NULL
, pParameter6Value  IN VARCHAR2 := NULL
, pParameter7Value  IN VARCHAR2 := NULL
)
IS
  l_url                VARCHAR2(32000) := NULL;
  l_bis_url            VARCHAR2(5000)  := NULL;
  l_jsp_name           VARCHAR2(500)   := NULL;
  l_parameter          VARCHAR2(32000) := NULL;
  l_server_port        VARCHAR2(80)    := NULL;

BEGIN

  IF icx_sec.validateSession THEN

    l_jsp_name := 'bisunsub.jsp';

    l_bis_url  := bis_utilities_pvt.get_bis_jsp_path;

    l_parameter := 'measureId='||pMeasureId -- 487
                   || '&' || 'targetLevelId=' || pTargetLevelId -- 1964
                   || '&' || 'targetId=' || pTargetId -- 602
		   || '&' || 'timeDimensionLevelId=' || pTimeDimensionLevelId -- 4
		   || '&' || 'planId=' || pPlanId -- 2
		   || '&' || 'notifiersCode=' || pNotifiersCode
		   || '&' || 'parameter1Value=' || pParameter1Value -- 204
		   || '&' || 'parameter2Value=' || pParameter2Value -- 204
		   || '&' || 'parameter3Value=' || pParameter3Value -- 204
		   || '&' || 'parameter4Value=' || pParameter4Value -- 204
		   || '&' || 'parameter5Value=' || pParameter5Value -- 204
		   || '&' || 'parameter6Value=' || pParameter6Value -- 204
		   || '&' || 'parameter7Value=' || pParameter7Value -- 204
                   || '&' || 'warnMsg=BIS_PMF_UNSUBSCRIBE_HDR'
                   || '&' || 'warnMsgDtl=BIS_PMF_UNSUBSCRIBE_CONF'
                   || '&' || 'errorMsg=BIS_PMF_UNSUB_ERR_HDR'
                   || '&' || 'errorMsgDtl=BIS_PMF_UNSUB_ERROR_MSG'
                   || '&' || 'pageTitle=BIS_PMF_UNSUB_TITLE';


    l_url:= l_bis_url || l_jsp_name || '?' || l_parameter; -- l_unsub_params;

    owa_util.redirect_url(l_url);

  END IF;


EXCEPTION
  WHEN OTHERS THEN
    NULL;
END unsub_launch_jsp ;


PROCEDURE unSubscribeFromAlerts  -- 1898436
    (p_measure_Id              IN  VARCHAR2 := NULL
    ,p_target_Level_Id         IN  VARCHAR2 := NULL
    ,p_time_Dimension_Level_Id IN  VARCHAR2 := NULL
    ,p_plan_Id                 IN  VARCHAR2 := NULL
    ,p_notifiers_Code          IN  VARCHAR2 := NULL
    ,p_parameter1_Value        IN  VARCHAR2 := NULL
    ,p_parameter2_Value        IN  VARCHAR2 := NULL
    ,p_parameter3_Value        IN  VARCHAR2 := NULL
    ,p_parameter4_Value        IN  VARCHAR2 := NULL
    ,p_parameter5_Value        IN  VARCHAR2 := NULL
    ,p_parameter6_Value        IN  VARCHAR2 := NULL
    ,p_parameter7_Value        IN  VARCHAR2 := NULL
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
) IS
  l_RoleName               VARCHAR2(30);
  l_UserName               VARCHAR2(100);
  l_UserExists             NUMBER;
  l_Count                  NUMBER := 0;
  l_notifiers_code         VARCHAR2(300);
  l_return_status          VARCHAR2(100);
  l_users_table            Wf_Directory.UserTable;
  l_Param_Set_rec          BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type;
  l_user_in_role           BOOLEAN := FALSE;
  l_error_Tbl              BIS_UTILITIES_PUB.Error_Tbl_Type;
  i                        NUMBER;
  l_user_tbl               wf_directory.UserTable;
  l_role                   VARCHAR2(300) := NULL; -- 'BIS_ALERT880';
  l_error_Tbl_p            BIS_UTILITIES_PUB.Error_Tbl_Type;


BEGIN

  x_msg_count := 0;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT unSubscribeFromAlerts_pvt;

  l_username := FND_GLOBAL.USER_NAME; -- 'SYSADMIN'; -- 'SADIQ'; --

  l_Param_Set_rec.performance_measure_id  := p_measure_id;
  l_Param_Set_rec.target_level_id         := p_target_level_id;
  l_Param_Set_rec.time_dimension_level_id := p_time_dimension_level_id;
  l_Param_Set_rec.plan_id                 := p_plan_id;
  l_Param_Set_rec.parameter1_value        := p_parameter1_value;
  l_Param_Set_rec.parameter2_value        := p_parameter2_value;
  l_Param_Set_rec.parameter3_value        := p_parameter3_value;
  l_Param_Set_rec.parameter4_value        := p_parameter4_value;
  l_Param_Set_rec.parameter5_value        := p_parameter5_value;
  l_Param_Set_rec.parameter6_value        := p_parameter6_value;
  l_Param_Set_rec.parameter7_value        := p_parameter7_value;

  BIS_PMF_ALERT_REG_PVT.Retrieve_Notifiers_Code
  ( p_api_version    => 1.0
  , p_Param_Set_rec  => l_Param_Set_rec
  , x_Notifiers_Code => l_Notifiers_Code
  , x_return_status  => l_return_status
  );

  wf_directory.GetRoleUsers ( l_Notifiers_Code, l_users_table);

  FOR i IN 1..l_users_table.count LOOP
    IF ( l_users_table(i) = l_UserName ) THEN
      l_user_in_role := TRUE;
      EXIT;
    END IF;
  END LOOP;

  IF l_user_in_role THEN
    wf_directory.RemoveUsersFromAdHocRole( l_notifiers_code , l_UserName);
  END IF;

  COMMIT;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO unSubscribeFromAlerts_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
    (p_count  =>   x_msg_count,
     p_data   =>   x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO unSubscribeFromAlerts_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_count := 1;
    x_msg_data := 'Error in BISVCACB.pls in unSubscribeFromAlerts' || sqlerrm;
  	l_error_tbl_p := l_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.unSubscribeFromAlerts'
    , p_error_table       => l_error_tbl_p
    , x_error_table       => l_error_tbl
    );
END unSubscribeFromAlerts;



-- Bug 2871017.
-- This procedure is invoked by the workflow notification system to
-- generate the mail content.
-- This procedure obtains the values set in the item attributes and the
-- message body is returned as a CLOB. HTML/TXT content is determined based
-- on the content type.

PROCEDURE GenerateAlerts
   ( document_id    IN VARCHAR2,
     content_type   IN VARCHAR2,
     document       IN OUT NOCOPY CLOB,
     document_type  IN OUT NOCOPY VARCHAR2)
IS

l_NL            VARCHAR2(1) := fnd_global.newline;
l_sp            VARCHAR2(32);
l_document      VARCHAR2(32000);
l_item_type     VARCHAR2(300) := document_id;
l_wf_item_key   WF_ITEM_ATTRIBUTE_VALUES.ITEM_KEY%TYPE := '';
l_document_id   NUMBER ;
l_label         VARCHAR2(32000);
l_server_date	DATE;
l_client_date	DATE;
l_server_code	varchar2(50);
l_client_code	varchar2(50);
l_run_date	varchar2(50);
l_next_run_date	varchar2(50);
l_sys_run_date	varchar2(50);
l_sys_next_run_date	varchar2(50);
l_unit		varchar2(100);
l_freq		varchar2(100);
l_alert_message varchar2(32000);
l_date_format   varchar2(50);
l_hdr_support   varchar2(100);
l_alert		varchar2(50);
l_dbi_measure	varchar2(50) := 'DBI_MEASURE';
l_alert_attribute  varchar2(100);
l_alert_attribute_label  varchar2(100);
l_user_id number;

Begin

  l_document := '';
  l_alert_message := '';
  l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
  l_wf_item_key  := substr(document_id, instr(document_id, ':') + 1,
                                            length(document_id) - 2);
  l_sp := '<SPACER TYPE=horizontal SIZE=72>';

  l_date_format := fnd_profile.value('ICX_DATE_FORMAT_MASK');
  l_date_format := l_date_format || ' HH24:MI:SS';

  l_sys_run_date := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'BIS_RUN_DATE' );

  l_server_code := fnd_timezones.get_server_timezone_code;
  l_client_code := fnd_timezones.get_client_timezone_code;

  l_server_date := to_date(l_sys_run_date,'DD/MM/RRRR HH24:MI:SS');

  /*
  l_client_date := fnd_timezones_pvt.adjust_datetime(
						date_time => l_server_date
						,from_tz => l_server_code
						,to_tz => l_client_code
						);
  */

   l_client_date := Adjust_Datetime
          			( p_date_time     => l_server_date
          			, p_from_tz       => l_server_code
          			, p_to_tz         => l_client_code
          			) ;
   select FND_GLOBAL.USER_ID into l_user_id from dual;
--Added for bug#7538754
   if (FND_RELEASE.MAJOR_VERSION = 12 and FND_RELEASE.minor_version >= 1 and FND_RELEASE.POINT_VERSION >= 1 ) or (FND_RELEASE.MAJOR_VERSION > 12) then
      l_run_date := to_char(l_client_date,
                                 FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', l_user_id),
                                 'NLS_CALENDAR = ''' || FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', l_user_id) || '''');
   else
      l_run_date := to_char(l_client_date, l_date_format);
   end if;


--  l_run_date := to_char(l_client_date, l_date_format);

  l_unit := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'SCHEDULE_INFO' );

  l_freq := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'SCHEDULE_FREQ' );

  IF ((l_unit IS NOT NULL) AND (l_unit <> 'ONCE')) THEN
    IF (l_run_date IS NOT NULL) THEN

      l_sys_next_run_date := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'NEXT_RUN_DATE' );

      l_server_date := to_date(l_sys_next_run_date, 'DD/MM/RRRR HH24:MI:SS');

      /*
      l_client_date := fnd_timezones_pvt.adjust_datetime(
						date_time => l_server_date
						,from_tz => l_server_code
						,to_tz => l_client_code
						);
      */

      l_client_date := Adjust_Datetime
                                ( p_date_time     => l_server_date
                                , p_from_tz       => l_server_code
                                , p_to_tz         => l_client_code
                                ) ;
 --Added for bug#7538754
   if (FND_RELEASE.MAJOR_VERSION = 12 and FND_RELEASE.minor_version >= 1 and FND_RELEASE.POINT_VERSION >= 1 ) or (FND_RELEASE.MAJOR_VERSION > 12) then
	   l_next_run_date := to_char(l_client_date,
                                 FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', l_user_id),
                                 'NLS_CALENDAR = ''' || FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', l_user_id) || '''');
   else
      l_next_run_date := to_char(l_client_date, l_date_format);
   end if;

     -- l_next_run_date := to_char(l_client_date, l_date_format);

      l_alert_message := l_alert_message || BIS_UTILITIES_PVT.Get_FND_Message(
							 p_message_name => 'BIS_ALERT_SCHEDULE_MSG1'
							,p_msg_param1 => 'NEXT_RUN_DATE'
							,p_msg_param1_val => l_next_run_date
							);
    END IF;

    IF (l_freq IS NOT NULL) THEN
      l_alert_message := l_alert_message || BIS_UTILITIES_PVT.Get_FND_Message(
							 p_message_name => 'BIS_ALERT_SCHEDULE_MSG2'
							,p_msg_param1 => 'SCHEDULE_INFO'
							,p_msg_param1_val => l_freq
							);
    END IF;
  ELSE
    l_alert_message := l_alert_message || BIS_UTILITIES_PVT.Get_FND_Message(
							 p_message_name => 'BIS_ALERT_NOT_REPEAT'
							);
  END IF;

  l_alert_message := l_alert_message || BIS_UTILITIES_PVT.Get_FND_Message(
							 p_message_name => 'BIS_ALERT_SCHEDULE_MSG3'
							 );

  l_hdr_support := wf_core.translate('WF_HEADER_ATTR');

  l_alert := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'ALERT_BASED_ON' );

  IF (l_alert = BIS_CONCURRENT_MANAGER_PVT.C_ALERT_BASED_ON_CHANGE) THEN
    l_alert_attribute := 'L_CHANGE';
    l_alert_attribute_label := 'L_CHANGE_LABEL';
  ELSE
    l_alert_attribute := 'L_TARGET';
    l_alert_attribute_label := 'L_TARGET_LABEL';
  END IF;

  IF (content_type = Wf_Notification.doc_html) THEN

     l_document := l_document || '<body>' ;

     l_document := l_document || Get_Style_Class;

     l_document := l_document || Get_Header(
					p_item_type => l_item_type,
					p_wf_item_key  => l_wf_item_key,
                                        p_attribute_name    => 'L_ALERT_DETAILS_LABEL');

     l_document := l_document || '<span class="label">';

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_ALERT_MSG' );

     l_document := l_document || l_label;
     l_document := l_document || '</span><br>' ;
     l_document := l_document || '<br>' ;
     l_document := l_document || '<table valign="top" cellpadding="0" cellspacing="0" border="0">' ;

     l_document := l_document || '<tr>' ;


     l_document := l_document || '<td valign="top">' ;
     l_document := l_document || '<table border="0" cellspacing="0" cellpadding="1">' ;

     IF (l_hdr_support <> 'Y') THEN
       l_document := l_document || '<tr>' ;
       l_document := l_document || Get_Label(
					p_item_type => l_item_type,
					p_wf_item_key  => l_wf_item_key,
                                        p_attribute_name    => 'L_PERFORMANCE_MEASURE_LABEL');
       l_document := l_document || Get_Text(
					p_item_type => l_item_type,
					p_wf_item_key  => l_wf_item_key,
                                        p_attribute_name    => 'L_PERFORMANCE_MEASURE');

       l_document := l_document || '</tr>' ;

     END IF;

     l_document := l_document || '<tr>' ;
     l_document := l_document || Get_Label(
					p_item_type => l_item_type,
					p_wf_item_key  => l_wf_item_key,
                                        p_attribute_name    => 'L_UNITOFMEASURE_LABEL');

     l_document := l_document || Get_Text(
					p_item_type => l_item_type,
					p_wf_item_key  => l_wf_item_key,
                                        p_attribute_name    => 'L_UNITOFMEASURE');

     l_document := l_document || '</tr>' ;

     l_document := l_document || '<tr>' ;
     l_document := l_document || Get_Label(
					p_item_type => l_item_type,
					p_wf_item_key  => l_wf_item_key,
                                        p_attribute_name    => l_alert_attribute_label);

     l_document := l_document || Get_Text(
					p_item_type => l_item_type,
					p_wf_item_key  => l_wf_item_key,
                                        p_attribute_name    => l_alert_attribute);
     l_document := l_document || '</tr>' ;

     IF (l_hdr_support <> 'Y') THEN
       l_document := l_document || '<tr>' ;
       l_document := l_document || Get_Label(
					p_item_type => l_item_type,
					p_wf_item_key  => l_wf_item_key,
                                        p_attribute_name    => 'L_ACTUAL_LABEL');

       l_document := l_document || Get_Text(
					p_item_type => l_item_type,
					p_wf_item_key  => l_wf_item_key,
                                        p_attribute_name    => 'L_ACTUAL');

       l_document := l_document || '</tr>' ;
     END IF;

     l_document := l_document || '<tr>' ;
     l_document := l_document || Get_Label(
					p_item_type => l_item_type,
					p_wf_item_key  => l_wf_item_key,
                                        p_attribute_name    => 'L_TOLERANCE_RANGE_1_LABEL');

     l_document := l_document || Get_Text(
					p_item_type => l_item_type,
					p_wf_item_key  => l_wf_item_key,
                                        p_attribute_name    => 'L_TOLERANCE_RANGE_1');

     l_document := l_document || '</tr>' ;
     l_document := l_document || '<tr>' ;

     l_document := l_document || Get_Label(
					p_item_type => l_item_type,
					p_wf_item_key  => l_wf_item_key,
                                        p_attribute_name    => 'L_TOLERANCE_RANGE_2_LABEL');

     l_document := l_document || Get_Text(
					p_item_type => l_item_type,
					p_wf_item_key  => l_wf_item_key,
                                        p_attribute_name    => 'L_TOLERANCE_RANGE_2');

     l_document := l_document || '</tr>' ;
     l_document := l_document || '<tr>' ;
     l_document := l_document || Get_Label(
					p_item_type => l_item_type,
					p_wf_item_key  => l_wf_item_key,
                                        p_attribute_name    => 'L_TOLERANCE_RANGE_3_LABEL');

     l_document := l_document || Get_Text(
					p_item_type => l_item_type,
					p_wf_item_key  => l_wf_item_key,
                                        p_attribute_name    => 'L_TOLERANCE_RANGE_3');

     l_document := l_document || '</tr>' ;
     l_document := l_document || '<tr>' ;
     l_document := l_document || '<td><SPACER TYPE=horizonal SIZE=4></td>' ;
     l_document := l_document || '</tr>' ;

     l_document := l_document || '</table><br>' ;

          l_document := l_document || '</td><td width="5%"></td>' ;
     l_document := l_document || '<td valign="top" nowrap>' ;
     l_document := l_document || '<table border="0" cellspacing="0" cellpadding="1">' ;
     l_document := l_document || '<tr>' ;
     l_document := l_document || Get_Label(
					p_item_type => l_item_type,
					p_wf_item_key  => l_wf_item_key,
                                        p_attribute_name    => 'L_RUN_DATE_LABEL');

     l_document := l_document || '<td VALIGN=TOP NOWRAP><span class="text">' ;
     l_document := l_document || '&nbsp;&nbsp;' ;
     l_document := l_document || l_run_date;
     l_document := l_document || '</span></td>' ;
     l_document := l_document || '</tr>' ;
	 l_document := l_document || '<tr nowrap>' ;
     l_document := l_document || Get_Label(
					p_item_type => l_item_type,
					p_wf_item_key  => l_wf_item_key,
                                        p_attribute_name    => 'BIS_DIMENSION_REGION_LABEL');

     l_document := l_document || '<td nowrap>' ;
     l_document := l_document || '<span class="text">';

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'BIS_DIMENSION_REGION' );

     l_document := l_document || l_label;
     l_document := l_document || '</span>';
     l_document := l_document || '</td>' ;
     l_document := l_document || '</tr>' ;
     l_document := l_document || '</table>' ;
     l_document := l_document || '</td>' ;
     l_document := l_document || '</tr>' ;
     l_document := l_document || '</table><br>' ;

     l_document := l_document || Get_Header(
					p_item_type => l_item_type,
					p_wf_item_key  => l_wf_item_key,
                                        p_attribute_name    => 'L_RELATED_INFO_LABEL');

     WF_NOTIFICATION.WriteToClob(document, l_document);

     Generate_Report(document_id,
                  content_type,
                  document,
                  document_type);

     l_document := '';

     l_document := l_document || Get_Header(
					p_item_type => l_item_type,
					p_wf_item_key  => l_wf_item_key,
                                        p_attribute_name    =>'L_ALERT_RECIPIENTS_LABEL');

     l_document := l_document || '<span class="label">';

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_ALERT_RECIPIENTS_MSG' );

     l_document := l_document || l_label;
     l_document := l_document || '</span>';
     l_document := l_document || '<br><SPACER TYPE=horizonal SIZE=16>' ;
     l_document := l_document || '<br>' ;
     l_document := l_document || '<span class="label">';

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_RECEPIENT' );

     l_document := l_document || l_label;
     l_document := l_document || '</span>';

     l_document := l_document || Get_Header(
					p_item_type => l_item_type,
					p_wf_item_key  => l_wf_item_key,
                                        p_attribute_name    => 'L_ALERT_SCHEDULE');

     l_document := l_document || '<span class="label">';

     l_document := l_document || l_alert_message;

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_ALERT_SCHEDULE_MSG' );

     l_document := l_document || l_label;
     l_document := l_document || '</span>';
     l_document := l_document || '<br>' ;

     l_document := l_document || '</body>' ;

     WF_NOTIFICATION.WriteToClob(document, l_document);

  ELSIF (content_type = Wf_Notification.Doc_Text) THEN

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_ALERT_DETAILS_LABEL' );


     l_document := l_document || l_label ;
     l_document := l_document || l_NL ;
     l_document := l_document || '---------------------------------------------------------------------------' ;
     l_document := l_document || l_NL ;

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_ALERT_MSG' );

     l_document := l_document || l_label;
     l_document := l_document || l_NL ;
     l_document := l_document || l_NL ;

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_RUN_DATE_LABEL' );

     l_document := l_document || l_label;
     l_document := l_document || ' : ' ;

     l_document := l_document || l_run_date;
     l_document := l_document || l_NL ;

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'BIS_DIMENSION_REGION_TXT' );

     l_document := l_document || l_label;
     l_document := l_document || l_NL ;

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_PERFORMANCE_MEASURE_LABEL' );

     l_document := l_document || l_label;
     l_document := l_document || ' : ';

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_PERFORMANCE_MEASURE' );

     l_document := l_document || l_label;
     l_document := l_document || l_NL ;

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_UNITOFMEASURE_LABEL' );

     l_document := l_document || l_label;
     l_document := l_document || ' : ' ;

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_UNITOFMEASURE' );

     l_document := l_document || l_label;
     l_document := l_document || l_NL ;

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => l_alert_attribute_label );

     l_document := l_document || l_label;

     l_document := l_document || ' : ' ;

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => l_alert_attribute );

     l_document := l_document || l_label;
     l_document := l_document || l_NL ;

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_ACTUAL_LABEL' );

     l_document := l_document || l_label;
     l_document := l_document || ' : ' ;

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_ACTUAL' );

     l_document := l_document || l_label;
     l_document := l_document || l_NL ;

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_TOLERANCE_RANGE_1_LABEL' );

     l_document := l_document || l_label;
     IF ( l_label IS NOT NULL ) THEN
        l_document := l_document || ' : ' ;
     END IF;

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_TOLERANCE_RANGE_1' );

     l_document := l_document || l_label;
     l_document := l_document || l_NL ;

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_TOLERANCE_RANGE_2_LABEL' );

     l_document := l_document || l_label;
     IF ( l_label IS NOT NULL ) THEN
        l_document := l_document || ' : ' ;
     END IF;

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_TOLERANCE_RANGE_2' );

     l_document := l_document || l_label;
     l_document := l_document || l_NL ;

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_TOLERANCE_RANGE_3_LABEL' );

     l_document := l_document || l_label;
     IF ( l_label IS NOT NULL ) THEN
        l_document := l_document || ' : ' ;
     END IF;

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_TOLERANCE_RANGE_3' );

     l_document := l_document || l_label;
     l_document := l_document || l_NL ;

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_RELATED_INFO_LABEL' );

     l_document := l_document || l_label;
     l_document := l_document || l_NL ;
     l_document := l_document || '---------------------------------------------------------------------------' ;
     l_document := l_document || l_NL ;

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_RELATE_INFO_LABEL' );

     l_document := l_document || l_label;

     l_document := l_document || '  ';

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_RELATED_INFORMATION_TXT' );


     l_document := l_document || l_label;
     l_document := l_document || l_NL ;
     l_document := l_document || l_NL ;
     l_document := l_document || l_NL ;

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_ALERT_RECIPIENTS_LABEL' );


     l_document := l_document || l_label;
     l_document := l_document || l_NL ;
     l_document := l_document || '---------------------------------------------------------------------------' ;
     l_document := l_document || l_NL ;

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_ALERT_RECIPIENTS_MSG' );


     l_document := l_document || l_label;
     l_document := l_document || l_NL ;
     l_document := l_document || l_NL ;
     l_document := l_document || l_NL ;

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_RECEPIENT_TXT' );


     l_document := l_document || l_label;
     l_document := l_document || l_NL ;
     l_document := l_document || l_NL ;
     l_document := l_document || l_NL ;

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_ALERT_SCHEDULE' );


     l_document := l_document || l_label;
     l_document := l_document || l_NL ;
     l_document := l_document || '---------------------------------------------------------------------------' ;
     l_document := l_document || l_NL ;

     l_document := l_document || l_alert_message;

     l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_ALERT_SCHEDULE_MSG_TXT' );

     l_document := l_document || l_label;
     l_document := l_document || l_NL ;

     WF_NOTIFICATION.WriteToClob(document, l_document);

  END IF; -- Check for content type

End GenerateAlerts;
--=============================================================================

PROCEDURE Generate_Report
   ( document_id    IN VARCHAR2,
     content_type   IN VARCHAR2,
     document       IN OUT NOCOPY CLOB,
     document_type  IN OUT NOCOPY VARCHAR2)
IS

l_document      VARCHAR2(32000);
l_item_type     VARCHAR2(300) := document_id;
l_wf_item_key   WF_ITEM_ATTRIBUTE_VALUES.ITEM_KEY%TYPE := '';
l_document_id   NUMBER ;
l_label         VARCHAR2(32000);
vHTMLPieces     utl_http.html_pieces;
l_html_pieces   varchar2(32000);

BEGIN
  l_document := '';
  l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
  l_wf_item_key  := substr(document_id, instr(document_id, ':') + 1,
                                            length(document_id) - 2);

  l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_REPORT_URL' );

  IF (l_label IS NULL OR l_label = '') THEN
    l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_RELATE_INFO_LABEL' );

    l_document := l_document || '<span class="label">';

    l_document := l_document || l_label;

    l_document := l_document || '  ';

    l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => l_item_type,
                           itemkey  => l_wf_item_key,
                           aname    => 'L_RELATED_INFORMATION' );

   l_document := l_document || l_label;
   l_document := l_document || '</span>';

   WF_NOTIFICATION.WriteToClob(document,l_document);

  ELSE

    vHTMLPieces := utl_http.request_pieces(url        => l_label,
                                         max_pieces => 32000);

    FOR i IN 1 .. vHTMLPieces.count loop

        l_html_pieces := vHTMLpieces(i);
	WF_NOTIFICATION.WriteToClob(document,l_html_pieces);
    END LOOP;

  END IF;

  EXCEPTION
    when others then
      l_document := sqlerrm||' Inside Exception';
End Generate_Report;

--=============================================================================

FUNCTION Get_Line
RETURN VARCHAR2 IS

l_line VARCHAR2(500);

BEGIN
  l_line := '<TABLE CELLSPACING=0 CELLPADDING=0 BORDER=0 WIDTH="100%">
		<TR BGCOLOR="#cccc99"><TD><IMG SRC="http://qapache.us.oracle.com:26700/OA_MEDIA/bisspace.gif" WIDTH="1" HEIGHT="1" BORDER="0"
		ALT="------------------------------------------------------------"></TD></TR></TABLE>' ;
  RETURN l_line;
END Get_Line;

FUNCTION Get_Style_Class
RETURN VARCHAR2 IS

l_style VARCHAR2(500);

BEGIN
  l_style :=  '<STYLE TYPE="text/css" >
		<!--
		 p .header {font-family: Arial; font-size:13.0pt;font-weight:bold; color:#6699cc}
   		-->
		<!--
		 p .label {font-size:10.0pt; font-family:Arial; color:#000000}
		-->
		<!--
		 p .text {font-size:10.0pt; font-family:Arial; font-weight:bold; color:#000000}
		-->
		</STYLE>' ;
  RETURN l_style;
END Get_Style_Class;

FUNCTION Get_Header(
   p_item_type     IN VARCHAR2
  ,p_wf_item_key   IN WF_ITEM_ATTRIBUTE_VALUES.ITEM_KEY%TYPE
  ,p_attribute_name IN VARCHAR2
) RETURN VARCHAR2 IS

l_header_html  VARCHAR2(1000);
l_label   VARCHAR2(32000);

BEGIN
  l_header_html := '' ;
  l_header_html := l_header_html || '<p><span class="header">' ;

  l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => p_item_type,
                           itemkey  => p_wf_item_key,
                           aname    => p_attribute_name );

  l_header_html := l_header_html || l_label ;
  l_header_html := l_header_html || '</span>';

  l_header_html := l_header_html || Get_Line;

  RETURN l_header_html;
END Get_Header;

FUNCTION Get_Label(
   p_item_type     IN VARCHAR2
  ,p_wf_item_key   IN WF_ITEM_ATTRIBUTE_VALUES.ITEM_KEY%TYPE
  ,p_attribute_name IN VARCHAR2
) RETURN VARCHAR2 IS

l_label_html  VARCHAR2(1000);
l_label   VARCHAR2(32000);

BEGIN
  l_label_html := '';

  l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => p_item_type,
                           itemkey  => p_wf_item_key,
                           aname    => p_attribute_name );

  IF (l_label IS NOT NULL) THEN
    l_label_html := l_label_html || '<td valign="top" nowrap>';
    l_label_html := l_label_html || '<div align=right>';
    l_label_html := l_label_html || '<span class="label">';
    l_label_html := l_label_html || l_label;
    l_label_html := l_label_html || '</span>';
    l_label_html := l_label_html || '<SPACER TYPE=horizonal SIZE=4></div>' ;
    l_label_html := l_label_html || '</td>' ;
  END IF;

RETURN l_label_html;

END Get_Label;

FUNCTION Get_Text(
   p_item_type     IN VARCHAR2
  ,p_wf_item_key   IN WF_ITEM_ATTRIBUTE_VALUES.ITEM_KEY%TYPE
  ,p_attribute_name IN VARCHAR2
) RETURN VARCHAR2 IS

l_text_html  VARCHAR2(1000);
l_label   VARCHAR2(32000);

BEGIN
  l_text_html := '';

  l_label := WF_ENGINE.GetItemAttrText (
                           itemtype => p_item_type,
                           itemkey  => p_wf_item_key,
                           aname    => p_attribute_name );

  IF (l_label IS NOT NULL) THEN
    l_text_html := l_text_html || '<td>' ;
    l_text_html := l_text_html || '<span class="text">';
    l_text_html := l_text_html || '&nbsp;&nbsp;' ;
    l_text_html := l_text_html || l_label;
    l_text_html := l_text_html || '</span>';
    l_text_html := l_text_html || '</td>' ;
  END IF;

  RETURN l_text_html;

END Get_Text;

FUNCTION Adjust_Datetime
( p_date_time     IN  DATE
, p_from_tz       IN VARCHAR2
, p_to_tz         IN VARCHAR2
) RETURN DATE
IS
  l_db_ver   NUMBER;
  l_sql_stmt VARCHAR2(400);
  l_client_date  DATE;

BEGIN
  l_db_ver := BIS_UTILITIES_PUB.Get_DB_Version;
  l_client_date := p_date_time;

  l_sql_stmt := 'begin :1 := fnd_timezones_pvt.adjust_datetime(:2, :3, :4); end;';

  IF l_db_ver > 8 THEN
     execute immediate l_sql_stmt using OUT l_client_date , IN p_date_time, IN p_from_tz, IN p_to_tz;
  END IF;

  /*
  l_client_date := fnd_timezones_pvt.adjust_datetime(
                                                date_time => p_date_time
                                                ,from_tz => p_from_tz
                                                ,to_tz => p_to_tz
                                                );
  */

  RETURN l_client_date;

END Adjust_Datetime;

END BIS_CORRECTIVE_ACTION_PVT;

/
