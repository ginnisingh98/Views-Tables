--------------------------------------------------------
--  DDL for Package Body PSB_EXCEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_EXCEL_PVT" AS
/* $Header: PSBVXLEB.pls 120.7.12010000.3 2009/04/29 02:47:08 rkotha ship $ */

  G_PKG_NAME CONSTANT   VARCHAR2(30):= 'PSB_EXCEL_PVT';

g_ws_line_year_rec  psb_ws_matrix.ws_line_year_rec_type;
g_export_id       NUMBER;
g_msg_export_id   NUMBER; -- Used in 'Log Messages'
g_worksheet_id    NUMBER;
g_global_worksheet_id NUMBER;
g_data_extract_id     NUMBER;
g_currency_code       VARCHAR2(15);
g_budget_group_id     NUMBER;
g_business_group_id   NUMBER;
g_user_id         NUMBER;
g_stage_id        NUMBER;
g_budget_by_position VARCHAR2(1);
g_budget_calendar_id NUMBER;

g_max_num_cols    CONSTANT NUMBER := 12;
g_max_num_pos_ws_cols CONSTANT NUMBER := 168;
g_coa_id          NUMBER;

g_pos_ws_col_no      NUMBER;
g_total_budget_years NUMBER;
g_total_ps_elements  NUMBER;


--Variables to store Profile Options
g_currency_flag VARCHAR2(1) := 'C';
g_year_flag   VARCHAR2(1) := 'S';
g_service_package_flag   VARCHAR2(1) := 'S';

/* Bug No 2008329 Start */
-- g_account_flag  VARCHAR2(1) := 'A';
-- Changed lookup code from 'C' to 'T' for all accounts for bug 3191611
g_account_flag  VARCHAR2(1) := 'T';
/* Bug No 2008329 End */

g_template_id   NUMBER;

/* Following three global variables added for DDSP to store the valid profile worksheet ID and User ID. */
g_profile_worksheet_id       NUMBER;
g_profile_user_id            NUMBER;
g_global_profile_user_id   CONSTANT  NUMBER := NULL;

g_allow_account_import    VARCHAR2(1) := 'Y';
g_allow_position_import   VARCHAR2(1) := 'Y';

-- Storage structures from PSBVWP2B.pls start
  TYPE g_poselasgn_rec_type IS RECORD
     ( worksheet_id           NUMBER,
       start_date             DATE,
       end_date               DATE,
       pay_element_id         NUMBER,
       pay_element_option_id  NUMBER,
       pay_basis              VARCHAR2(10),
       element_value_type     VARCHAR2(2),
       element_value          NUMBER );

  TYPE g_poselasgn_tbl_type IS TABLE OF g_poselasgn_rec_type
      INDEX BY BINARY_INTEGER;

  g_poselem_assignments      g_poselasgn_tbl_type;
  g_num_poselem_assignments  NUMBER;

  TYPE g_poselrate_rec_type IS RECORD
     ( worksheet_id           NUMBER,
       start_date             DATE,
       end_date               DATE,
       pay_element_id         NUMBER,
       pay_element_option_id  NUMBER,
       pay_basis              VARCHAR2(10),
       element_value_type     VARCHAR2(2),
       element_value          NUMBER,
       formula_id             NUMBER );

  TYPE g_poselrate_tbl_type IS TABLE OF g_poselrate_rec_type
      INDEX BY BINARY_INTEGER;

  g_poselem_rates            g_poselrate_tbl_type;
  g_num_poselem_rates        NUMBER;

-- Storage structures from PSBVWP2B.pls End


/* ----------------------------------------------------------------------- */
/*                                                                         */
/*                      Private Function and Procedure Declaration         */
/*                                                                         */
/* ----------------------------------------------------------------------- */
   -- Routines used by Export_WS
   PROCEDURE Get_WS_User_Profile;
   PROCEDURE Populate_WS_Columns;
   PROCEDURE Populate_WS_Lines;
   PROCEDURE Populate_POS_WS_Columns;
   PROCEDURE Populate_POS_WS_Lines;

   PROCEDURE Cache_Position_Data
   (
    p_return_status    OUT  NOCOPY VARCHAR2,
    p_position_line_id IN  NUMBER,
    p_position_id      IN  NUMBER,
    p_start_date       IN  DATE,
    p_end_date         IN  DATE
   );

   PROCEDURE Setup_Year_View
   (
    p_worksheet_id      IN      NUMBER,
    p_user_id           IN      NUMBER,
    p_stage_id          IN      NUMBER := FND_API.G_MISS_NUM
   );

   -- Routines used by Setup_Year_View
   FUNCTION  Get_Current_Stage_Seq  RETURN NUMBER;
   PROCEDURE Get_Calendar_Years;
   PROCEDURE Get_Saved_Year_Profile;
   PROCEDURE Set_WS_Matrix_View;

/* ---------------Exposed Packages---------------- */
  PROCEDURE Move_To_Interface
  (
  p_api_version               IN       NUMBER   ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_export_name            IN   VARCHAR2,
  p_worksheet_id           IN   NUMBER,
  p_stage_id               IN   NUMBER := FND_API.G_MISS_NUM,
  p_export_worksheet_type  IN   VARCHAR2 := FND_API.G_MISS_CHAR

  )
  IS

  l_export_positions        BOOLEAN;
  l_export_accounts         BOOLEAN;
  l_export_worksheet_type   VARCHAR2(1);
  l_account_export_status   VARCHAR2(10);
  l_position_export_status  VARCHAR2(10);

  l_export_seq              NUMBER;
  l_export_name             psb_worksheets_i.export_name%TYPE;

  l_api_name                CONSTANT VARCHAR2(30) := 'Move_To_Interface' ;
  l_api_version             CONSTANT NUMBER       :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_current_stage_seq       NUMBER;

  l_ws_rec_found            BOOLEAN;
  BEGIN
    --dbms_output.put_line('Exporting ...');
    --
    SAVEPOINT Move_To_Interface_Pvt ;
    --
    IF NOT FND_API.Compatible_API_Call ( l_api_version,
					 p_api_version,
					 l_api_name,
					 G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --

    IF FND_API.To_Boolean ( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize ;
    END IF;
    --
    p_return_status := FND_API.G_RET_STS_SUCCESS ;

    l_ws_rec_found := FALSE;
    FOR ws_recinfo IN
      (SELECT nvl(global_worksheet_id,worksheet_id) global_worksheet_id,
	global_worksheet_flag, local_copy_flag,
	budget_group_id, extract_id , business_group_id,
	budget_calendar_id, set_of_books_id, freeze_flag, budget_by_position,
	stage_set_id, current_stage_seq,
	chart_of_accounts_id, currency_code
      FROM psb_ws_summary_v
      WHERE worksheet_id = p_worksheet_id)
    LOOP
      l_ws_rec_found := TRUE;
      g_budget_by_position  := ws_recinfo.budget_by_position;
      g_budget_calendar_id  := ws_recinfo.budget_calendar_id;
      g_business_group_id   := ws_recinfo.business_group_id;
      l_current_stage_seq   := ws_recinfo.current_stage_seq;
      g_budget_group_id     := ws_recinfo.budget_group_id;
      g_global_worksheet_id := ws_recinfo.global_worksheet_id;
      g_data_extract_id     := ws_recinfo.extract_id;
      g_currency_code       := ws_recinfo.currency_code;
    END LOOP;

    IF NOT l_ws_rec_found  THEN
      FND_MESSAGE.SET_NAME('PSB', 'PSB_INVALID_ARGUMENT');
      FND_MESSAGE.SET_TOKEN('ROUTINE', 'Export Worksheet Procedure' );
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR ;
    END IF;

    g_worksheet_id := p_worksheet_id;
    g_user_id      := FND_GLOBAL.USER_ID;

    /* Following procedure called for DDSP To get the values of Data Selection profile WS Id and User ID
     Start  */

    PSB_WS_PERIOD_TOTAL.get_data_selection_profile
    (p_current_worksheet_id    => g_worksheet_id,
     p_current_user_id         => g_user_id,
     p_global_profile_user_id  => g_global_profile_user_id,
     p_profile_worksheet_id    => g_profile_worksheet_id,
     p_profile_user_id         => g_profile_user_id);

   /* End */

    --g_user_id      := 0;
    -- comment line above when running from conc. manager
    l_export_accounts  := FALSE;
    l_export_positions := FALSE;

    IF p_export_worksheet_type = FND_API.G_MISS_CHAR THEN
      l_export_worksheet_type := 'B';
    ELSE
      l_export_worksheet_type := p_export_worksheet_type;
    END IF;

    IF l_export_worksheet_type IN  ('A','B') THEN
      l_export_accounts := TRUE;
      l_account_export_status := 'INSERT';
    END IF;

    IF l_export_worksheet_type IN  ('P','B') and
      g_budget_by_position = 'Y' THEN
      l_export_positions := TRUE;
      l_position_export_status := 'INSERT';
    END IF;

    IF ( not  l_export_accounts) AND
       ( not  l_export_positions) THEN
      FND_MESSAGE.SET_NAME('PSB', 'PSB_INVALID_ARGUMENT');
      FND_MESSAGE.SET_TOKEN('ROUTINE', 'Export Worksheet Procedure' );
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Set the correct worksheet type
    IF l_export_accounts and l_export_positions THEN
      l_export_worksheet_type := 'B';
    ELSIF l_export_accounts THEN
      l_export_worksheet_type := 'A';
    ELSIF l_export_positions THEN
      l_export_worksheet_type := 'P';
    END IF;

    l_export_seq :=  Get_Next_Export_Seq;
    g_export_id := l_export_seq;
    g_msg_export_id := l_export_seq;

    -- The psb_worksheets_i.export_name is VARCHAR2(80). If necessary, truncate
    -- export_name to accomodate the export_id at the end.
    l_export_name := substr( p_export_name,
			     1,
			     80 - length(to_char(l_export_seq)) - 1)
		     || '-' || to_char(l_export_seq) ;


    Get_WS_User_Profile;

    -- Set default values for Allow Account Export and Allow Position Import
    g_allow_account_import  := 'Y';
    g_allow_position_import := 'Y';

    -- g_template_id is set by Get WS User Profile
    IF g_template_id IS NOT NULL THEN
       g_allow_account_import := 'N';
    END IF;

    IF ( p_stage_id = FND_API.G_MISS_NUM) or (p_stage_id IS NULL) THEN
      g_stage_id     := 0;
    ELSE
      g_allow_position_import := 'N';
      g_allow_account_import  := 'N';
      g_stage_id     := p_stage_id;
    END IF;

    Setup_Year_View(p_worksheet_id, g_user_id);

    Insert into PSB_WORKSHEETS_I
       (EXPORT_ID,
	EXPORT_NAME,
	WORKSHEET_ID,
	STAGE_ID,
	SELECTED_STAGE_ID,
	SELECTED_TEMPLATE_ID,
	ACCOUNT_EXPORT_STATUS,
	POSITION_EXPORT_STATUS,
	BUDGET_BY_POSITION,
	CURRENCY_FLAG,
	EXPORT_WORKSHEET_TYPE,
	ALLOW_ACCOUNT_IMPORT,
	ALLOW_POSITION_IMPORT,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATED_BY,
	CREATION_DATE)
    values
      ( g_export_id,
	l_export_name,
	p_worksheet_id,
	l_current_stage_seq,
	g_stage_id,
	g_template_id,
	l_account_export_status,
	l_position_export_status,
	g_budget_by_position,
	g_currency_flag,
	l_export_worksheet_type,
	g_allow_account_import,
	g_allow_position_import,
	SYSDATE,
	g_user_id,
	g_user_id,
	g_user_id,
	SYSDATE );

    IF l_export_accounts THEN
      --dbms_output.put_line('Exporting Accounts');
      Populate_WS_Columns;
      Populate_WS_Lines;
    END IF;

    IF l_export_positions  THEN
      --dbms_output.put_line('Exporting Positions');
      Populate_POS_WS_Columns;
      Populate_POS_WS_Lines;

    END IF;

    -- Populate Position WS Lines sets the global variable g_allow_position_import
    update psb_worksheets_i
    set allow_position_import = g_allow_position_import
    where export_id = g_export_id;

    IF FND_API.to_Boolean (p_commit) then
      commit work;
    END IF;


  EXCEPTION

  --
  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Move_To_Interface_Pvt;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Move_To_Interface_Pvt;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    ROLLBACK TO Move_To_Interface_Pvt;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --

  END Move_To_Interface;


  PROCEDURE Get_WS_User_Profile
  IS

    --Query Profile
    CURSOR q_rec IS
     select
      TEMPLATE_ID,
      CURRENCY_FLAG,
      YEAR_FLAG,
      SERVICE_PACKAGE_FLAG,
      ACCOUNT_FLAG
    from
      PSB_WS_QUERY_PROFILES_V
   /* Following 2 lines commented and next 2 lines added for DDSP */
   -- where WORKSHEET_ID = g_worksheet_id
    --  and USER_ID = g_user_id;
      where WORKSHEET_ID = g_profile_worksheet_id
	and (USER_ID = g_profile_user_id or (g_profile_user_id IS NULL AND USER_ID IS NULL));

    q_recinfo           q_rec%ROWTYPE;

    --Year Profile
    CURSOR y_rec IS
     SELECT budget_period_id
     FROM  psb_ws_year_profiles_v
   /* Following 2 lines commented and next 2 lines added for DDSP */
   -- where WORKSHEET_ID = g_worksheet_id
    --  and USER_ID = g_user_id;
      where WORKSHEET_ID = g_profile_worksheet_id
	and (USER_ID = g_profile_user_id or (g_profile_user_id IS NULL AND USER_ID IS NULL));

     y_recinfo   y_rec%ROWTYPE;

    --Service Package Profile
    CURSOR sp_rec IS
    SELECT service_package_id
    FROM   PSB_WS_SERVICE_PKG_PROFILES_V
  /* Following 2 lines commented and next 2 lines added for DDSP */
   -- where WORKSHEET_ID = g_worksheet_id
    --  and USER_ID = g_user_id;
      where WORKSHEET_ID = g_profile_worksheet_id
	and (USER_ID = g_profile_user_id or (g_profile_user_id IS NULL AND USER_ID IS NULL));

    sp_recinfo       sp_rec%ROWTYPE;

  BEGIN

    OPEN q_rec;
    FETCH q_rec INTO q_recinfo;
    IF q_rec%FOUND THEN
      g_currency_flag        := q_recinfo.CURRENCY_FLAG;
      g_year_flag            := q_recinfo.YEAR_FLAG;
      g_service_package_flag := q_recinfo.SERVICE_PACKAGE_FLAG;
      g_account_flag         := q_recinfo.ACCOUNT_FLAG;
      g_template_id          := q_recinfo.template_id;
    ELSE    --Set Default Values
      g_currency_flag        := 'C'; --Currency
      g_year_flag            := 'S'; --Selected
      g_service_package_flag := 'S'; --Selected

/* Bug No 2008329 Start */
--      g_account_flag         := 'A'; --All
      g_account_flag         := 'T'; --All
/* Bug No 2008329 End */

      g_template_id          := NULL;
    END IF;
    CLOSE q_rec;

    --
    IF g_year_flag = 'S' THEN

      OPEN y_rec;
      FETCH y_rec INTO y_recinfo;
      IF y_rec%NOTFOUND THEN
	g_year_flag := 'A'; --All from Calendar
      END IF;
      CLOSE y_rec;
    END IF;

    IF g_service_package_flag = 'S' THEN
      OPEN sp_rec;
      FETCH sp_rec INTO sp_recinfo;
      IF (sp_rec%NOTFOUND) then
	g_service_package_flag := 'A';
      END IF;
      CLOSE sp_rec;
    END IF;
  END Get_WS_User_Profile;


  PROCEDURE Setup_Year_View
  (
  p_worksheet_id      IN      NUMBER,
  p_user_id           IN      NUMBER,
  p_stage_id          IN      NUMBER := FND_API.G_MISS_NUM
  )  IS

  BEGIN


    g_worksheet_id := p_worksheet_id;
    g_user_id      := p_user_id;

    select chart_of_accounts_id into g_coa_id from psb_ws_summary_v
    where worksheet_id = g_worksheet_id;


    -- Get the year ids and balance in PL/SQL table(g_ws_cols)

    IF g_year_flag = 'A' THEN
      Get_Calendar_Years;
    ELSE
      Get_Saved_Year_Profile;

    END IF;

    Set_WS_Matrix_View;
    --Setup Global for total budget years
    g_total_budget_years := 0;
    for i in 1..g_max_num_cols loop
      IF g_ws_cols(i).budget_year_id IS NULL THEN
	EXIT;
      ELSE
	g_total_budget_years := g_total_budget_years + 1;
      END IF;
    end loop;

  END Setup_Year_View;


  FUNCTION Get_Current_Stage_Seq  RETURN NUMBER
  IS
    l_current_stage_seq NUMBER := 0;
    CURSOR ws_cur IS
	 SELECT current_stage_seq
	 FROM psb_worksheets
	 WHERE worksheet_id = g_worksheet_id;
    Recinfo   ws_cur%ROWTYPE;
  BEGIN
    OPEN ws_cur;
    FETCH ws_cur INTO Recinfo;
    IF ws_cur%FOUND THEN
      l_current_stage_seq := Recinfo.current_stage_seq;
    END IF;
    CLOSE ws_cur;
    RETURN l_current_stage_seq;

  END Get_Current_Stage_Seq;


  PROCEDURE Clear_WS_Cols is
  BEGIN
    for l_init_index in 1..g_max_num_cols loop
      g_ws_cols(l_init_index).budget_year_id := null;
      g_ws_cols(l_init_index).budget_year_name := null;
      g_ws_cols(l_init_index).balance_type  := null;
      g_ws_cols(l_init_index).display_balance_type  := null;
      g_ws_cols(l_init_index).year_category_type  := null;
    end loop;
  END Clear_WS_Cols;

  PROCEDURE Clear_POS_WS_Cols is
  BEGIN
    for l_init_index in 1..g_max_num_pos_ws_cols loop
      g_pos_ws_cols(l_init_index).column_type := null;
      g_pos_ws_cols(l_init_index).budget_year_id := null;
      g_pos_ws_cols(l_init_index).budget_year_name := null;
      g_pos_ws_cols(l_init_index).balance_type  := null;
      g_pos_ws_cols(l_init_index).display_balance_type  := null;
      g_pos_ws_cols(l_init_index).year_category_type  := null;
    end loop;
  END Clear_POS_WS_Cols;



  PROCEDURE Set_POS_WS_Cols
	     ( p_budget_year_id           IN NUMBER,
	       p_budget_year_name         IN VARCHAR2,
	       p_balance_type             IN VARCHAR2,
	       p_display_balance_type     IN VARCHAR2,
	       p_category_type            IN VARCHAR2
	     )
  IS
    CURSOR C IS
       SELECT budget_period_id,
	      name
       FROM  psb_budget_periods
       WHERE parent_budget_period_id = p_budget_year_id
       AND budget_period_type = 'P';

    Recinfo           C%ROWTYPE;
    l_num_of_periods  NUMBER;
    l_first_rec_flag  VARCHAR2(1);
  BEGIN
    l_num_of_periods := 0;
    l_first_rec_flag := 'Y';


    OPEN C;
    LOOP

      FETCH C INTO Recinfo;

      EXIT WHEN C%NOTFOUND;

      IF l_first_rec_flag = 'Y' THEN

	l_first_rec_flag := 'N';

	-- Create a column for Totals
	g_pos_ws_col_no := g_pos_ws_col_no + 1;
	g_pos_ws_cols(g_pos_ws_col_no).column_type := 'T';
	g_pos_ws_cols(g_pos_ws_col_no).budget_period_id :=  NULL;
	g_pos_ws_cols(g_pos_ws_col_no).budget_period_name := NULL;
	g_pos_ws_cols(g_pos_ws_col_no).budget_year_id := p_budget_year_id;
	g_pos_ws_cols(g_pos_ws_col_no).budget_year_name := p_budget_year_name;
	g_pos_ws_cols(g_pos_ws_col_no).balance_type  := p_balance_type;
	g_pos_ws_cols(g_pos_ws_col_no).display_balance_type  := p_display_balance_type;
	g_pos_ws_cols(g_pos_ws_col_no).year_category_type  := p_category_type;

	-- Create a column for Percentage
	g_pos_ws_col_no := g_pos_ws_col_no + 1;
	g_pos_ws_cols(g_pos_ws_col_no).column_type := 'P';
	g_pos_ws_cols(g_pos_ws_col_no).budget_period_id :=  NULL;
	g_pos_ws_cols(g_pos_ws_col_no).budget_period_name := NULL;
	g_pos_ws_cols(g_pos_ws_col_no).budget_year_id := p_budget_year_id;
	g_pos_ws_cols(g_pos_ws_col_no).budget_year_name := p_budget_year_name;
	g_pos_ws_cols(g_pos_ws_col_no).balance_type  := p_balance_type;
	g_pos_ws_cols(g_pos_ws_col_no).display_balance_type  := p_display_balance_type;
	g_pos_ws_cols(g_pos_ws_col_no).year_category_type  := p_category_type;



      END IF;
      l_num_of_periods :=   l_num_of_periods + 1;
      g_pos_ws_col_no := g_pos_ws_col_no + 1;
      g_pos_ws_cols(g_pos_ws_col_no).column_type := 'A';
      g_pos_ws_cols(g_pos_ws_col_no).budget_period_id :=  recinfo.budget_period_id;
      g_pos_ws_cols(g_pos_ws_col_no).budget_period_name := recinfo.name;
      g_pos_ws_cols(g_pos_ws_col_no).budget_year_id := p_budget_year_id;
      g_pos_ws_cols(g_pos_ws_col_no).budget_year_name := p_budget_year_name;
      g_pos_ws_cols(g_pos_ws_col_no).balance_type  := p_balance_type;
      g_pos_ws_cols(g_pos_ws_col_no).display_balance_type  := p_display_balance_type;
      g_pos_ws_cols(g_pos_ws_col_no).year_category_type  := p_category_type;

    END LOOP;
      g_year_num_periods(p_budget_year_id).num_of_periods :=  l_num_of_periods;


  END Set_POS_WS_Cols;

  PROCEDURE Get_Calendar_Years is

    col_no NUMBER := 0;
    l_init_index        BINARY_INTEGER;

    CURSOR C IS
       SELECT budget_period_id,
	      budget_period_name,
	      year_category_type ,
	      sequence_number
       FROM psb_ws_budget_years_v
	 WHERE worksheet_id = g_worksheet_id
	 ORDER by sequence_number;
    Recinfo           C%ROWTYPE;
    Start_Flag_Is_Set BOOLEAN := FALSE;

  BEGIN

    IF g_budget_by_position = 'Y' THEN
      g_pos_ws_col_no := 0;
      Clear_POS_WS_Cols;
    END IF;

    Clear_WS_Cols;

    OPEN C;
    LOOP
      FETCH C INTO Recinfo;
      EXIT WHEN C%NOTFOUND;
       IF ( Recinfo.year_category_type = 'PY' )
	 OR ( Recinfo.year_category_type = 'CY' )then
	-- Add a record for Budget
	col_no := col_no +1;
	IF col_no > g_max_num_cols THEN
	  EXIT ;
	END IF;
	g_ws_cols(col_no).budget_year_id := recinfo.budget_period_id;
	g_ws_cols(col_no).budget_year_name := recinfo.budget_period_name;
	g_ws_cols(col_no).balance_type  := 'B';
	g_ws_cols(col_no).display_balance_type  := 'Budget';
	g_ws_cols(col_no).year_category_type  := Recinfo.year_category_type;

	IF g_budget_by_position = 'Y' THEN
	   Set_POS_WS_Cols(p_budget_year_id       => recinfo.budget_period_id,
			   p_budget_year_name     => recinfo.budget_period_name,
			   p_balance_type         => 'B',
			   p_display_balance_type => 'Budget',
			   p_category_type        =>  Recinfo.year_category_type
			  );
	 END IF;

	-- Add a record for Actual
	col_no := col_no +1;
	IF col_no > g_max_num_cols THEN
	  EXIT ;
	END IF;
	g_ws_cols(col_no).budget_year_id := recinfo.budget_period_id;
	g_ws_cols(col_no).budget_year_name := recinfo.budget_period_name;
	g_ws_cols(col_no).balance_type  := 'A';
	g_ws_cols(col_no).display_balance_type  := 'Actual';
	g_ws_cols(col_no).year_category_type  := Recinfo.year_category_type;


	IF g_budget_by_position = 'Y' THEN
	   Set_POS_WS_Cols(p_budget_year_id       => recinfo.budget_period_id,
			   p_budget_year_name     => recinfo.budget_period_name,
			   p_balance_type         => 'A',
			   p_display_balance_type => 'Actual',
			   p_category_type        =>  Recinfo.year_category_type
			  );
	END IF;

/* Bug No 2656353 Start */
        -- Add a record for Encumbrance
        col_no := col_no +1;
        IF col_no > g_max_num_cols THEN
          EXIT ;
        END IF;
        g_ws_cols(col_no).budget_year_id := recinfo.budget_period_id;
        g_ws_cols(col_no).budget_year_name := recinfo.budget_period_name;
        g_ws_cols(col_no).balance_type  := 'X';
        g_ws_cols(col_no).display_balance_type  := 'Encumbrance';
        g_ws_cols(col_no).year_category_type  := Recinfo.year_category_type;

        IF g_budget_by_position = 'Y' THEN
           Set_POS_WS_Cols(p_budget_year_id       => recinfo.budget_period_id,
                           p_budget_year_name     => recinfo.budget_period_name,
                           p_balance_type         => 'X',
                           p_display_balance_type => 'Encumbrance',
                           p_category_type        =>  Recinfo.year_category_type
                          );
        END IF;
/* Bug No 2656353 End */

      END IF;

      IF ( Recinfo.year_category_type = 'PP' )
	 OR ( Recinfo.year_category_type = 'CY' )then
	-- Add a record for Estimate
	col_no := col_no +1;
	IF col_no > g_max_num_cols THEN
	  EXIT ;
	END IF;
	g_ws_cols(col_no).budget_year_id := recinfo.budget_period_id;
	g_ws_cols(col_no).budget_year_name := recinfo.budget_period_name;
	g_ws_cols(col_no).balance_type  := 'E';
	g_ws_cols(col_no).display_balance_type  := 'Estimate';
	g_ws_cols(col_no).year_category_type  := Recinfo.year_category_type;

	IF g_budget_by_position = 'Y' THEN
	   Set_POS_WS_Cols(p_budget_year_id       => recinfo.budget_period_id,
			   p_budget_year_name     => recinfo.budget_period_name,
			   p_balance_type         => 'E',
			   p_display_balance_type => 'Estimate',
			   p_category_type        =>  Recinfo.year_category_type
			  );
	END IF;

      END IF;

    END LOOP;

  END Get_Calendar_Years;

  PROCEDURE Get_Saved_Year_Profile is
    col_no   NUMBER := 0;
    CURSOR C IS
	 SELECT budget_period_id,
		budget_period_name,
		year_category_type,
		fte_flag,
		actual_flag,
		budget_flag,
		estimate_flag,
/* Bug No 2656353 Start */
		encumbrance_flag,
/* Bug No 2656353 End */
		start_year_flag
	 FROM psb_ws_year_profiles_v
	/* Following 2 lines commented and next 2 lines added for DDSP */
     -- where WORKSHEET_ID = g_worksheet_id
      --  and  USER_ID = g_user_id
	where WORKSHEET_ID = g_profile_worksheet_id
	  and (USER_ID = g_profile_user_id or (g_profile_user_id IS NULL AND USER_ID IS NULL))
	ORDER by sequence_number;
    Recinfo           C%ROWTYPE;
    Start_Flag_Is_Set BOOLEAN := FALSE;

  BEGIN
    col_no := 0;
    Clear_WS_Cols;
    IF g_budget_by_position = 'Y' THEN
      g_pos_ws_col_no := 0;
      Clear_POS_WS_Cols;
    END IF;


    OPEN C;
    LOOP

      FETCH C INTO Recinfo;
      EXIT WHEN C%NOTFOUND;

      IF ( Recinfo.fte_flag = 'Y') then
	col_no := col_no +1;
	IF col_no > g_max_num_cols THEN
	  EXIT ;
	END IF;
	g_ws_cols(col_no).budget_year_id := recinfo.budget_period_id;
	g_ws_cols(col_no).budget_year_name := recinfo.budget_period_name;
	g_ws_cols(col_no).balance_type  := 'F';
	g_ws_cols(col_no).display_balance_type  := 'FTE';
	g_ws_cols(col_no).year_category_type  := recinfo.year_category_type;


	IF g_budget_by_position = 'Y' THEN
	   Set_POS_WS_Cols(p_budget_year_id        => recinfo.budget_period_id,
			   p_budget_year_name     => recinfo.budget_period_name,
			   p_balance_type         => 'F',
			   p_display_balance_type => 'FTE',
			   p_category_type        =>  Recinfo.year_category_type
			  );
	END IF;


      END IF;

      IF ( Recinfo.Budget_flag = 'Y') then
	col_no := col_no +1;
	IF col_no > g_max_num_cols THEN
	  EXIT ;
	END IF;
	g_ws_cols(col_no).budget_year_id := recinfo.budget_period_id;
	g_ws_cols(col_no).budget_year_name := recinfo.budget_period_name;
	g_ws_cols(col_no).balance_type  := 'B';
	g_ws_cols(col_no).display_balance_type  := 'Budget';
	g_ws_cols(col_no).year_category_type  := Recinfo.year_category_type;

	IF g_budget_by_position = 'Y' THEN
	   Set_POS_WS_Cols(p_budget_year_id       => recinfo.budget_period_id,
			   p_budget_year_name     => recinfo.budget_period_name,
			   p_balance_type         => 'B',
			   p_display_balance_type => 'Budget',
			   p_category_type        =>  Recinfo.year_category_type
			  );
	END IF;


      END IF;


      IF ( Recinfo.Actual_flag = 'Y') then
	-- Add a record for Actual
	col_no := col_no +1;
	IF col_no > g_max_num_cols THEN
	  EXIT ;
	END IF;
	g_ws_cols(col_no).budget_year_id := recinfo.budget_period_id;
	g_ws_cols(col_no).budget_year_name := recinfo.budget_period_name;
	g_ws_cols(col_no).balance_type  := 'A';
	g_ws_cols(col_no).display_balance_type  := 'Actual';
	g_ws_cols(col_no).year_category_type  := Recinfo.year_category_type;


	IF g_budget_by_position = 'Y' THEN
	   Set_POS_WS_Cols(p_budget_year_id        => recinfo.budget_period_id,
			   p_budget_year_name      => recinfo.budget_period_name,
			   p_balance_type          => 'A',
			   p_display_balance_type  => 'Actual',
			   p_category_type         =>  Recinfo.year_category_type
			  );
	END IF;

      END IF;

/* Bug No 2656353 Start */
      IF ( Recinfo.Encumbrance_flag = 'Y') then
        -- Add a record for Encumbrance
        col_no := col_no +1;
        IF col_no > g_max_num_cols THEN
          EXIT ;
        END IF;
        g_ws_cols(col_no).budget_year_id := recinfo.budget_period_id;
        g_ws_cols(col_no).budget_year_name := recinfo.budget_period_name;
        g_ws_cols(col_no).balance_type  := 'X';
        g_ws_cols(col_no).display_balance_type  := 'Encumbrance';
        g_ws_cols(col_no).year_category_type  := Recinfo.year_category_type;


        IF g_budget_by_position = 'Y' THEN
           Set_POS_WS_Cols(p_budget_year_id        => recinfo.budget_period_id,
                           p_budget_year_name      => recinfo.budget_period_name,
                           p_balance_type          => 'X',
                           p_display_balance_type  => 'Encumbrance',
                           p_category_type         =>  Recinfo.year_category_type
                          );
        END IF;

      END IF;
/* Bug No 2656353 End */

      IF ( Recinfo.Estimate_flag = 'Y') then
	-- Add a record for Estimate
	col_no := col_no +1;
	IF col_no > g_max_num_cols THEN
	  EXIT ;
	END IF;
	g_ws_cols(col_no).budget_year_id := recinfo.budget_period_id;
	g_ws_cols(col_no).budget_year_name := recinfo.budget_period_name;
	g_ws_cols(col_no).balance_type  := 'E';
	g_ws_cols(col_no).display_balance_type  := 'Estimate';
	g_ws_cols(col_no).year_category_type  := Recinfo.year_category_type;


	IF g_budget_by_position = 'Y' THEN


	   Set_POS_WS_Cols(p_budget_year_id       => recinfo.budget_period_id,
			   p_budget_year_name     => recinfo.budget_period_name,
			   p_balance_type         => 'E',
			   p_display_balance_type => 'Estimate',
			   p_category_type        =>  Recinfo.year_category_type
			  );
	END IF;

      END IF;

    END LOOP;

  END Get_Saved_Year_Profile;

  PROCEDURE Set_WS_Matrix_View IS
  BEGIN

    g_ws_line_year_rec.stage            :=  g_stage_id;
    g_ws_line_year_rec.c1_year_id       :=  g_ws_cols(1).budget_year_id;
    g_ws_line_year_rec.c2_year_id       :=  g_ws_cols(2).budget_year_id;
    g_ws_line_year_rec.c3_year_id       :=  g_ws_cols(3).budget_year_id;
    g_ws_line_year_rec.c4_year_id       :=  g_ws_cols(4).budget_year_id;
    g_ws_line_year_rec.c5_year_id       :=  g_ws_cols(5).budget_year_id;
    g_ws_line_year_rec.c6_year_id       :=  g_ws_cols(6).budget_year_id;
    g_ws_line_year_rec.c7_year_id       :=  g_ws_cols(7).budget_year_id;
    g_ws_line_year_rec.c8_year_id       :=  g_ws_cols(8).budget_year_id;
    g_ws_line_year_rec.c9_year_id       :=  g_ws_cols(9).budget_year_id;
    g_ws_line_year_rec.c10_year_id      :=  g_ws_cols(10).budget_year_id;
    g_ws_line_year_rec.c11_year_id      :=  g_ws_cols(11).budget_year_id;
    g_ws_line_year_rec.c12_year_id      :=  g_ws_cols(12).budget_year_id;
    g_ws_line_year_rec.c1_amount_type   :=  g_ws_cols(1).balance_type;
    g_ws_line_year_rec.c2_amount_type   :=  g_ws_cols(2).balance_type;
    g_ws_line_year_rec.c3_amount_type   :=  g_ws_cols(3).balance_type;
    g_ws_line_year_rec.c4_amount_type   :=  g_ws_cols(4).balance_type;
    g_ws_line_year_rec.c5_amount_type   :=  g_ws_cols(5).balance_type;
    g_ws_line_year_rec.c6_amount_type   :=  g_ws_cols(6).balance_type;
    g_ws_line_year_rec.c7_amount_type   :=  g_ws_cols(7).balance_type;
    g_ws_line_year_rec.c8_amount_type   :=  g_ws_cols(8).balance_type;
    g_ws_line_year_rec.c9_amount_type   :=  g_ws_cols(9).balance_type;
    g_ws_line_year_rec.c10_amount_type  :=  g_ws_cols(10).balance_type;
    g_ws_line_year_rec.c11_amount_type  :=  g_ws_cols(11).balance_type;
    g_ws_line_year_rec.c12_amount_type  :=  g_ws_cols(12).balance_type;
    psb_ws_matrix.Set_WS_Line_Years(g_ws_line_year_rec);

  END Set_WS_Matrix_View;



  PROCEDURE Populate_WS_Columns IS
  BEGIN


    for i in 1..g_total_budget_years loop

      insert into psb_ws_columns_i(
		EXPORT_ID,
		EXPORT_WORKSHEET_TYPE,
		COLUMN_NUMBER,
		BUDGET_YEAR_ID,
		BUDGET_YEAR_NAME,
		BALANCE_TYPE,
		DISPLAYED_BALANCE_TYPE,
		YEAR_CATEGORY_TYPE,
		DISPLAYED_YEAR_CATEGORY_TYPE,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		CREATED_BY,
		CREATED_DATE)
		values(
		g_export_id,
		'A', -- for All Accounts
		i,
		g_ws_cols(i).budget_year_id,
		g_ws_cols(i).budget_year_name,
		g_ws_cols(i).balance_type,
		g_ws_cols(i).display_balance_type, -- Get translated msg
		g_ws_cols(i).year_category_type,
		g_ws_cols(i).year_category_type, -- Get translated msg
		SYSDATE,
		g_user_id,
		g_user_id,
		g_user_id,
		SYSDATE
		);

    end loop;

  END  Populate_WS_Columns;


  PROCEDURE Populate_POS_WS_Columns IS
  BEGIN
    for i in 1..g_max_num_pos_ws_cols loop
      IF g_pos_ws_cols(i).budget_year_id IS NULL THEN
	EXIT;

      END IF;
      insert into psb_ws_columns_i(
		EXPORT_ID,
		EXPORT_WORKSHEET_TYPE,
		COLUMN_NUMBER,
		COLUMN_TYPE,
		BUDGET_YEAR_ID,
		BUDGET_YEAR_NAME,
		BUDGET_PERIOD_ID,
		BUDGET_PERIOD_NAME,
		BALANCE_TYPE,
		DISPLAYED_BALANCE_TYPE,
		YEAR_CATEGORY_TYPE,
		DISPLAYED_YEAR_CATEGORY_TYPE,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		CREATED_BY,
		CREATED_DATE)
		values(
		g_export_id,
		'P', -- for Position  Accounts
		i,
		g_pos_ws_cols(i).column_type,
		g_pos_ws_cols(i).budget_year_id,
		g_pos_ws_cols(i).budget_year_name,
		g_pos_ws_cols(i).budget_period_id,
		g_pos_ws_cols(i).budget_period_name,
		g_pos_ws_cols(i).balance_type,
		g_pos_ws_cols(i).display_balance_type, -- Get translated msg
		g_pos_ws_cols(i).year_category_type,
		g_pos_ws_cols(i).year_category_type, -- Get translated msg
		SYSDATE,
		g_user_id,
		g_user_id,
		g_user_id,
		SYSDATE
		);

    end loop;

  END  Populate_POS_WS_Columns;

  PROCEDURE Populate_WS_Lines IS
    l_account_segments VARCHAR2(1000);
    l_account_desc VARCHAR2(1000);

    l_position_account_flag VARCHAR2(1);
    l_ccid_type         VARCHAR2(30);
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_root_budget_group_id NUMBER;
  BEGIN

    FOR l_bg_rec IN
    (
      SELECT nvl(root_budget_group_id, budget_group_id) root_budget_group_id
      FROM psb_budget_groups_v
      WHERE budget_group_id = g_budget_group_id
    )
    LOOP
      l_root_budget_group_id := l_bg_rec.root_budget_group_id;
    END LOOP;


    FOR wal_rec IN (
       select
	 CODE_COMBINATION_ID,
	 ACCOUNT_TYPE,
	 SERVICE_PACKAGE_ID,
	 SERVICE_PACKAGE_NAME,
	 PRIORITY,
	 TEMPLATE_ID,
	 CURRENCY_CODE,
	 COLUMN1,
	 COLUMN2,
	 COLUMN3,
	 COLUMN4,
	 COLUMN5,
	 COLUMN6,
	 COLUMN7,
	 COLUMN8,
	 COLUMN9,
	 COLUMN10,
	 COLUMN11,
	 COLUMN12
       from PSB_WS_LINE_YEAR_XL_V
       where WORKSHEET_ID =  g_worksheet_id

/* Bug No 2008329 Start */
--       and  ( g_account_flag = 'A' or ACCOUNT_TYPE = g_account_flag )
       and  ( g_account_flag = 'T' or ACCOUNT_TYPE = g_account_flag
		 OR ( account_type = DECODE(g_account_flag,'P','R')
		      OR account_type = DECODE(g_account_flag,'P','E')
		    )
		 OR ( account_type = DECODE(g_account_flag,'N','A' )
		      OR account_type = DECODE(g_account_flag,'N','L')
		    )
		 OR ( account_type = DECODE(g_account_flag,'B','C' )
		      OR account_type = DECODE(g_account_flag,'B','D')
		    )

	    )
/* Bug No 2008329 End */

       and  ( (g_template_id is null and TEMPLATE_ID  is null)
	       or
	      (TEMPLATE_ID = g_template_id) )
       and  ( ( g_currency_flag = 'C' and CURRENCY_CODE <> 'STAT' )
	      or
	      ( g_currency_flag = 'S' and CURRENCY_CODE = 'STAT')
	    )
       and  ( g_service_package_flag = 'A'   or
	      SERVICE_PACKAGE_ID in
		 (SELECT SERVICE_PACKAGE_ID
		   FROM  PSB_WS_SERVICE_PKG_PROFILES_V
	    /* Following 2 lines commented and next 2 lines added for DDSP */
	       -- where WORKSHEET_ID = g_worksheet_id
	       --  and  USER_ID = g_user_id
		  where WORKSHEET_ID = g_profile_worksheet_id
		    and (USER_ID = g_profile_user_id or (g_profile_user_id IS NULL AND USER_ID IS NULL))   ) )
	     )

    LOOP

      IF FND_FLEX_KEYVAL.validate_ccid('SQLGL', 'GL#', g_coa_id, wal_rec.CODE_COMBINATION_ID) THEN
	l_account_segments :=   substr(FND_FLEX_KEYVAL.concatenated_values,1,1000);
	l_account_desc :=   substr(FND_FLEX_KEYVAL.concatenated_descriptions,1,1000);
      END IF;

      l_position_account_flag := NULL;

      -- Set the value for position_account_flag

    -- added the following IF condition as part of bug fix 3575197.
    IF  NVL(g_budget_by_position,'N') = 'Y' THEN
      BEGIN
	PSB_WS_ACCT_PVT.CHECK_CCID_TYPE
	(
	 p_api_version                =>    1.0,
	 p_init_msg_list              =>    FND_API.G_TRUE,
	 p_validation_level           =>    FND_API.G_VALID_LEVEL_FULL,
	 p_return_status              =>    l_return_status,
	 p_msg_count                  =>    l_msg_count,
	 p_msg_data                   =>    l_msg_data,
	 --
	 p_ccid_type                  =>    l_ccid_type,
	 p_flex_code                  =>    g_coa_id,
	 p_ccid                       =>    wal_rec.code_combination_id,
	 p_budget_group_id            =>    l_root_budget_group_id
	);
	-- If not able to decide status set the record to non updateable
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   l_position_account_flag := 'Y';
	ELSE
	  IF l_ccid_type = 'PERSONNEL_SERVICES' THEN
            l_position_account_flag := 'Y';
          ELSE
	    l_position_account_flag := 'N';
	  END IF;
	END IF;
      EXCEPTION
	WHEN OTHERS THEN
	  l_position_account_flag := 'Y';
      END;
    ELSE
      l_position_account_flag := 'N';
    END IF;

      insert into psb_ws_line_balances_i(
	EXPORT_ID,
	EXPORT_WORKSHEET_TYPE,
	CODE_COMBINATION_ID,
	CONCATENATED_ACCOUNT,
	ACCOUNT_DESCRIPTION,
	SERVICE_PACKAGE_ID,
	SERVICE_PACKAGE_NAME,
	POSITION_ACCOUNT_FLAG,
	AMOUNT1,
	AMOUNT2,
	AMOUNT3,
	AMOUNT4,
	AMOUNT5,
	AMOUNT6,
	AMOUNT7,
	AMOUNT8,
	AMOUNT9,
	AMOUNT10,
	AMOUNT11,
	AMOUNT12,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATED_BY,
	CREATED_DATE)
      values(
	g_export_id,
	'A',
	wal_rec.CODE_COMBINATION_ID,
	l_account_segments,
	l_account_desc,
	wal_rec.SERVICE_PACKAGE_ID,
	wal_rec.SERVICE_PACKAGE_NAME,
	l_position_account_flag,
	wal_rec.COLUMN1,
	wal_rec.COLUMN2,
	wal_rec.COLUMN3,
	wal_rec.COLUMN4,
	wal_rec.COLUMN5,
	wal_rec.COLUMN6,
	wal_rec.COLUMN7,
	wal_rec.COLUMN8,
	wal_rec.COLUMN9,
	wal_rec.COLUMN10,
	wal_rec.COLUMN11,
	wal_rec.COLUMN12,
	SYSDATE,
	g_user_id,
	g_user_id,
	g_user_id,
	SYSDATE
	);

    END LOOP;

  END  Populate_WS_Lines;


  PROCEDURE Clear_PS_Elements_Tbl is
    i BINARY_INTEGER;
  BEGIN
    i := g_ps_elements.FIRST;

    WHILE i IS NOT NULL LOOP
      g_ps_elements(i).pay_element_id := null;
      g_ps_elements(i).pay_element_period_type := null;
      g_ps_elements(i).pay_element_name := null;
      g_ps_elements(i).pay_element_set_id := null;

      i := g_ps_elements.NEXT(i);

    END LOOP;
  END Clear_PS_Elements_Tbl;

  PROCEDURE Cache_PS_Elements
  (p_pay_element_id           NUMBER,
   p_pay_element_name         VARCHAR2,
   p_pay_element_period_type  VARCHAR2,
   p_pay_element_set_id       NUMBER
  )
  IS
    l_ps_element_exists BOOLEAN := FALSE;
    l_index             NUMBER  := 0; --bug:6019074
  BEGIN
    -- Add the PS element only if it doesn't exist already
    IF  g_ps_elements.COUNT > 0 THEN
      FOR i IN 1.. g_ps_elements.COUNT LOOP
	IF g_ps_elements(i).pay_element_id = p_pay_element_id THEN
	  l_ps_element_exists := TRUE;
	  exit;
	END IF;
      END LOOP;
      IF NOT l_ps_element_exists THEN
        l_index := g_ps_elements.COUNT + 1; --bug:6019074
	g_ps_elements(l_index).pay_element_id := p_pay_element_id;
	g_ps_elements(l_index).pay_element_name := p_pay_element_name;
	g_ps_elements(l_index).pay_element_period_type := p_pay_element_period_type;
	g_ps_elements(l_index).pay_element_set_id := p_pay_element_set_id;
      END IF;
    ELSE
      g_ps_elements(1).pay_element_id := p_pay_element_id;
      g_ps_elements(1).pay_element_name := p_pay_element_name;
      g_ps_elements(1).pay_element_period_type := p_pay_element_period_type;
      g_ps_elements(1).pay_element_set_id := p_pay_element_set_id;
    END IF;



  END Cache_PS_Elements;

  -- Cache position data for the calendar period
  PROCEDURE Cache_Position_Data
  (
    p_return_status    OUT  NOCOPY VARCHAR2,
    p_position_line_id IN  NUMBER,
    p_position_id      IN  NUMBER,
    p_start_date       IN  DATE,
    p_end_date         IN  DATE
  )
  IS

  l_return_status         VARCHAR2(1);
  l_position_id           NUMBER;
  l_start_date   DATE;
  l_end_date     DATE;

  cursor c_Positions is
    select a.position_id,
	   a.name,
	   a.effective_start_date,
	   a.effective_end_date
      from PSB_POSITIONS a,
	   PSB_WS_POSITION_LINES b
     where a.position_id = b.position_id
       and b.position_line_id = p_position_line_id;

  cursor c_Element_Assignments is
    select worksheet_id,
	   pay_element_id,
	   pay_element_option_id,
	   pay_basis,
	   element_value_type,
	   element_value,
	   effective_start_date,
	   effective_end_date
      from PSB_POSITION_ASSIGNMENTS
     where (worksheet_id is null or worksheet_id = g_global_worksheet_id)
       and element_value_type = 'PS'
       and currency_code = g_currency_code
       and assignment_type = 'ELEMENT'
       and (((effective_start_date <= l_end_date)
	 and (effective_end_date is null))
	 or ((effective_start_date between l_start_date and l_end_date)
	  or (effective_end_date between l_start_date and l_end_date)
	 or ((effective_start_date < l_start_date)
	 and (effective_end_date > l_end_date))))
       and position_id = l_position_id
     order by effective_start_date,
	      effective_end_date,
	      element_value desc;

  cursor c_Element_Rates is
    select a.worksheet_id,
	   a.pay_element_id,
	   a.pay_element_option_id,
	   a.pay_basis,
	   a.element_value_type,
	   a.element_value,
	   a.formula_id,
	   a.effective_start_date,
	   a.effective_end_date
      from PSB_PAY_ELEMENT_RATES a,
	   PSB_PAY_ELEMENTS b
     where (a.worksheet_id is null or a.worksheet_id = g_global_worksheet_id)
       and a.currency_code = g_currency_code
       and a.element_value_type = 'PS'
       and exists
	  (select 1
	     from PSB_POSITION_ASSIGNMENTS c
	    where nvl(c.pay_element_option_id, FND_API.G_MISS_NUM) = nvl(a.pay_element_option_id, FND_API.G_MISS_NUM)
	      and (c.worksheet_id is null or c.worksheet_id = g_global_worksheet_id)
	      and c.currency_code = g_currency_code
	      and (((c.effective_start_date <= l_end_date)
		and (c.effective_end_date is null))
		or ((c.effective_start_date between l_start_date and l_end_date)
		 or (c.effective_end_date between l_start_date and l_end_date)
		or ((c.effective_start_date < l_start_date)
		and (c.effective_end_date > l_end_date))))
	      and c.pay_element_id = a.pay_element_id
	      and c.position_id = l_position_id)
       and (((a.effective_start_date <= l_end_date)
	 and (a.effective_end_date is null))
	 or ((a.effective_start_date between l_start_date and l_end_date)
	  or (a.effective_end_date between l_start_date and l_end_date)
	 or ((a.effective_start_date < l_start_date)
	 and (a.effective_end_date > l_end_date))))
       and a.pay_element_id = b.pay_element_id
       and b.business_group_id = g_business_group_id
       and b.data_extract_id = g_data_extract_id
     order by a.worksheet_id,
	      a.effective_start_date,
	      a.effective_end_date,
	      a.element_value desc;

  BEGIN
  l_position_id  := p_position_id;
  l_start_date   :=  p_start_date;
  l_end_date     :=  p_end_date;

  -- Initialize the Cache
  for l_init_index in 1..g_poselem_assignments.Count loop
    g_poselem_assignments(l_init_index).worksheet_id := null;
    g_poselem_assignments(l_init_index).start_date := null;
    g_poselem_assignments(l_init_index).end_date := null;
    g_poselem_assignments(l_init_index).pay_element_id := null;
    g_poselem_assignments(l_init_index).pay_element_option_id := null;
    g_poselem_assignments(l_init_index).pay_basis := null;
    g_poselem_assignments(l_init_index).element_value_type := null;
    g_poselem_assignments(l_init_index).element_value := null;
  end loop;

  g_num_poselem_assignments := 0;

  for l_init_index in 1..g_poselem_rates.Count loop
    g_poselem_rates(l_init_index).worksheet_id := null;
    g_poselem_rates(l_init_index).start_date := null;
    g_poselem_rates(l_init_index).end_date := null;
    g_poselem_rates(l_init_index).pay_element_id := null;
    g_poselem_rates(l_init_index).pay_element_option_id := null;
    g_poselem_rates(l_init_index).pay_basis := null;
    g_poselem_rates(l_init_index).element_value_type := null;
    g_poselem_rates(l_init_index).element_value := null;
    g_poselem_rates(l_init_index).formula_id := null;
  end loop;

  g_num_poselem_rates := 0;


  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  for c_Element_Assignments_Rec in c_Element_Assignments loop

    g_num_poselem_assignments := g_num_poselem_assignments + 1;

    g_poselem_assignments(g_num_poselem_assignments).worksheet_id := c_Element_Assignments_Rec.worksheet_id;
    g_poselem_assignments(g_num_poselem_assignments).start_date := c_Element_Assignments_Rec.effective_start_date;
    g_poselem_assignments(g_num_poselem_assignments).end_date := c_Element_Assignments_Rec.effective_end_date;
    g_poselem_assignments(g_num_poselem_assignments).pay_element_id := c_Element_Assignments_Rec.pay_element_id;
    g_poselem_assignments(g_num_poselem_assignments).pay_element_option_id := c_Element_Assignments_Rec.pay_element_option_id;
    g_poselem_assignments(g_num_poselem_assignments).pay_basis := c_Element_Assignments_Rec.pay_basis;
    g_poselem_assignments(g_num_poselem_assignments).element_value_type := c_Element_Assignments_Rec.element_value_type;
    g_poselem_assignments(g_num_poselem_assignments).element_value := c_Element_Assignments_Rec.element_value;

  end loop;

  for c_Element_Rates_Rec in c_Element_Rates loop

    g_num_poselem_rates := g_num_poselem_rates + 1;

    g_poselem_rates(g_num_poselem_rates).worksheet_id := c_Element_Rates_Rec.worksheet_id;
    g_poselem_rates(g_num_poselem_rates).start_date := c_Element_Rates_Rec.effective_start_date;
    g_poselem_rates(g_num_poselem_rates).end_date := c_Element_Rates_Rec.effective_end_date;
    g_poselem_rates(g_num_poselem_rates).pay_element_id := c_Element_Rates_Rec.pay_element_id;
    g_poselem_rates(g_num_poselem_rates).pay_element_option_id := c_Element_Rates_Rec.pay_element_option_id;
    g_poselem_rates(g_num_poselem_rates).pay_basis := c_Element_Rates_Rec.pay_basis;
    g_poselem_rates(g_num_poselem_rates).element_value_type := c_Element_Rates_Rec.element_value_type;
    g_poselem_rates(g_num_poselem_rates).element_value := c_Element_Rates_Rec.element_value;
    g_poselem_rates(g_num_poselem_rates).formula_id := c_Element_Rates_Rec.formula_id;

  end loop;

    p_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END Cache_Position_Data;


  PROCEDURE Populate_PS_Element_Pct
  ( p_budget_year_id      IN   NUMBER,
    p_position_id         IN   NUMBER,
    p_pay_element_id      IN   NUMBER,
    p_element_period_type IN   VARCHAR2,
    p_found_ps_pct        OUT  NOCOPY  BOOLEAN
  )
  IS
    l_year_num_periods    NUMBER;
    l_budget_period_id    NUMBER;
    l_budget_period_type  VARCHAR2(10);
    l_budget_period_start_date  DATE;
    l_budget_period_end_date    DATE;

    l_pay_element_id      NUMBER;
    l_pay_element_option_id  NUMBER;

    l_element_assigned    VARCHAR2(1);
    l_ws_assignment       VARCHAR2(1);
    l_element_value       NUMBER;
    l_pos_assignment      VARCHAR2(1);
    l_year_period_num     NUMBER;
    l_assign_index        BINARY_INTEGER;
    l_value_from_elem_rates  VARCHAR2(1);
    l_hrms_factor         NUMBER;
  BEGIN
    l_pay_element_id := p_pay_element_id;
    l_year_num_periods := g_year_num_periods(p_budget_year_id).num_of_periods;

    -- for each budget period in the budget year
    FOR l_period_num IN 1.. l_year_num_periods LOOP
      l_element_value := NULL;
      -- Loop thru cached calendar to get start and end dates for the budget period
      l_year_period_num := 0;

      for l_period_index in 1..PSB_WS_ACCT1.g_num_budget_periods loop

	if PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_year_id = p_budget_year_id then
	  l_year_period_num :=  l_year_period_num + 1;
	  IF l_year_period_num = l_period_num THEN

	    l_budget_period_id := PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_period_id;
	    l_budget_period_type := PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_period_type;
	    l_budget_period_start_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date;
	    l_budget_period_end_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).end_date;
	    exit;
	  END IF;

	end if;
      end loop;

      -- Set Allow_Position_Import Flag
      for factor_rec in
      ( select factor
	from PSB_HRMS_FACTORS
	where hrms_period_type = p_element_period_type
	and budget_period_type = l_budget_period_type)
      loop
	l_hrms_factor := factor_rec.factor;
	IF l_hrms_factor < 1  THEN
	  g_allow_position_import := 'N';
	END IF;
	exit;
      end loop;

      -- Get the assignment data
      l_ws_assignment := FND_API.G_FALSE;
      for l_assign_index in 1..g_num_poselem_assignments loop

	if ((g_poselem_assignments(l_assign_index).pay_element_id = l_pay_element_id) and
	  (g_poselem_assignments(l_assign_index).worksheet_id is not null) and
	  (((g_poselem_assignments(l_assign_index).start_date <= l_budget_period_start_date) and
	  (g_poselem_assignments(l_assign_index).end_date is null)) or
	  ((g_poselem_assignments(l_assign_index).start_date between l_budget_period_start_date and l_budget_period_end_date) or
	  (g_poselem_assignments(l_assign_index).end_date between l_budget_period_start_date and l_budget_period_end_date) or
	  ((g_poselem_assignments(l_assign_index).start_date < l_budget_period_start_date) and
	  (g_poselem_assignments(l_assign_index).end_date > l_budget_period_end_date))))) then
	begin
	  l_ws_assignment := FND_API.G_TRUE;
	  l_element_value := g_poselem_assignments(l_assign_index).element_value;
	  l_pay_element_option_id := g_poselem_assignments(l_assign_index).pay_element_option_id;
	  exit;
	end;
	end if;
      end loop;

      l_pos_assignment := FND_API.G_FALSE;
      if not FND_API.to_Boolean(l_ws_assignment) then
      begin

	for l_assign_index in 1..g_num_poselem_assignments loop

	  if ((g_poselem_assignments(l_assign_index).pay_element_id = l_pay_element_id) and
	    (g_poselem_assignments(l_assign_index).worksheet_id is null) and
	    (((g_poselem_assignments(l_assign_index).start_date <= l_budget_period_end_date) and
	    (g_poselem_assignments(l_assign_index).end_date is null)) or
	    ((g_poselem_assignments(l_assign_index).start_date between l_budget_period_start_date and l_budget_period_end_date) or
	    (g_poselem_assignments(l_assign_index).end_date between l_budget_period_start_date and l_budget_period_end_date) or
	    ((g_poselem_assignments(l_assign_index).start_date < l_budget_period_start_date) and
	    (g_poselem_assignments(l_assign_index).end_date > l_budget_period_end_date))))) then
	  begin

	    l_pos_assignment := FND_API.G_TRUE;
	    l_pay_element_option_id := g_poselem_assignments(l_assign_index).pay_element_option_id;
	    l_element_value := g_poselem_assignments(l_assign_index).element_value;
	    exit;
	  end;
	  end if;

	end loop;

      end;
      end if;  -- if not ws assignment

      -- See if the value is arrived from element rates table
      l_value_from_elem_rates := FND_API.G_FALSE;
      if l_element_value is null then

	for l_rate_index in 1..g_num_poselem_rates loop

	  if ((g_poselem_rates(l_rate_index).pay_element_id = l_pay_element_id) and
	     (nvl(g_poselem_rates(l_rate_index).pay_element_option_id, FND_API.G_MISS_NUM) = nvl(l_pay_element_option_id, FND_API.G_MISS_NUM)) and
	     (((g_poselem_rates(l_rate_index).start_date <= l_budget_period_end_date) and
	     (g_poselem_rates(l_rate_index).end_date is null)) or
	     ((g_poselem_rates(l_rate_index).start_date between l_budget_period_start_date and l_budget_period_end_date) or
	     (g_poselem_rates(l_rate_index).end_date between l_budget_period_start_date and l_budget_period_end_date) or
	     ((g_poselem_rates(l_rate_index).start_date < l_budget_period_start_date) and
	     (g_poselem_rates(l_rate_index).end_date > l_budget_period_end_date))))) then
	    l_value_from_elem_rates := FND_API.G_TRUE;
	    l_element_value := g_poselem_rates(l_rate_index).element_value;
	    exit;
	  end if;

	end loop;

      end if;  -- Element value is null

      if l_element_value is not null then
	p_found_ps_pct := TRUE;
	g_ps_element_pct(l_period_num).amount:= l_element_value;
      end if;

    END LOOP; -- For each budget period in the budget year

  END Populate_PS_Element_Pct;


  PROCEDURE Populate_POS_WS_Lines IS
    l_account_segments VARCHAR2(1000);
    l_account_desc VARCHAR2(1000);

    l_budget_calendar_id NUMBER;
    l_calendar_start_date DATE;
    l_calendar_end_date DATE;
    l_cy_end_date  DATE;
    l_pp_start_date DATE;



    l_position_line_id NUMBER;
    l_position_id NUMBER;
    l_position_name VARCHAR2(240);
    l_code_combination_id NUMBER;
    l_budget_group_id    NUMBER;
    l_element_set_id NUMBER;
    l_service_package_id NUMBER;
    l_service_package_name  VARCHAR2(30);

    l_element_id      NUMBER;
    l_element_name    VARCHAR2(30);
    l_follow_salary   VARCHAR2(1);

    l_template_id NUMBER;
    l_wlbi_start_index NUMBER;
    l_wlbi_end_index NUMBER;
    l_budget_year_id NUMBER;
    l_balance_type VARCHAR2(1);
    l_year_num_periods NUMBER; -- number of periods in the budget year
    l_wal_col_index NUMBER;

    l_start_stage_seq NUMBER;
    l_current_stage_seq   NUMBER;

    l_wal_rec_found VARCHAR2(1);
    l_fte_rec_found VARCHAR2(1);
    l_element_value_type  VARCHAR2(2);
    l_found_ps_pct  BOOLEAN;

    l_position_start_date DATE;
    l_position_end_date   DATE;
    l_start_date          DATE;
    l_end_date            DATE;
    l_period_type         VARCHAR2(10);

    l_return_status       VARCHAR2(1);
    l_percent_of_salary_flag VARCHAR2(1);

    l_employee_id         NUMBER;
    l_employee_number     VARCHAR2(30);
    l_employee_name           VARCHAR2(240);
    l_job_name            VARCHAR2(240);
    l_job_attribute_id    NUMBER;

    /*bug:6019074:start*/
    l_rounding_factor    NUMBER := 1;
    l_rounding_amt       NUMBER;
    l_rounding_diff      NUMBER;
    l_data_extract_id    NUMBER;
    l_year_amount        NUMBER := 0;
    l_element_cost       NUMBER := 0;
    l_element_set_cost   NUMBER := 0;

    cursor l_eleset_cost_csr(p_curr_stage_seq NUMBER,
                              p_service_package_id NUMBER,
                              p_currency_code  VARCHAR2) IS
    select sum(element_cost) element_set_cost
      from psb_ws_element_lines
     where position_line_id = l_position_line_id
       and element_set_id = l_element_set_id
       and budget_year_id = l_budget_year_id
       and service_package_id = p_service_package_id
       and currency_code = p_currency_code
       and p_curr_stage_seq between start_stage_seq and nvl(end_stage_seq,current_stage_seq);

    /*bug:6019074:end*/

  BEGIN
    -- Processing Logic

    -- Get all the positions for the Worksheet
    --   For each position execute the view 'PSB_WS_YEAR_POSITION_AMOUNTS'
    --    and get the various Account Line IDs.
    --    Move all account line ids to a PL/SQL table
    --      For each Account Line Id, Get the period amounts and move it to a PL/SQL table
    --        Move the values to the insert table for only as many periods for the budget year

    Get_Calendar_Dates
	    ( p_budget_calendar_id  => g_budget_calendar_id,
	      p_calendar_start_date => l_calendar_start_date,
	      p_calendar_end_date   => l_calendar_end_date,
	      p_cy_end_date         => l_cy_end_date,
	      p_pp_start_date       => l_pp_start_date
	    );

    PSB_WS_ACCT1.Cache_Budget_Calendar
    (p_return_status => l_return_status,
     p_budget_calendar_id => g_budget_calendar_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    -- First set up the Positions view
    psb_positions_i_pvt.initialize_view
	   (  p_worksheet_id => g_worksheet_id,
	      p_start_date   => l_calendar_start_date,
	      p_end_date     => l_calendar_end_date,
	      p_select_date  => l_pp_start_date
	   );

    -- Clear wlbi_rec
    FOR l_wlbi_col_index in 1..g_max_num_pos_ws_cols LOOP
      g_wlbi_amounts(l_wlbi_col_index).amount := NULL;
    END LOOP;

   /*bug:6019074:start*/
   for l_worksheet_rec in (select rounding_factor,data_extract_id from psb_worksheets
                           where worksheet_id=g_worksheet_id) loop
        l_rounding_factor := l_worksheet_rec.rounding_factor;
        l_data_extract_id := l_worksheet_rec.data_extract_id;
   end loop;
   /*bug:6019074:end*/

    -- Work with one position at a time
    FOR position_rec in
    (
      SELECT
	     position_line_id,
	     position_id,
	     position_name,
	     position_definition_id,
	     position_segments
      FROM psb_ws_select_positions_v
      WHERE worksheet_id = g_worksheet_id

    )
    LOOP
      l_position_line_id  := position_rec.position_line_id;
      l_position_name     := position_rec.position_name;
      l_position_id       := position_rec.position_id;

      g_ps_elements.DELETE;

    /*start bug:6019074: STATEMENT level logging*/
   if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then

       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
      'PSB/IMPORT_WS_PSB_TO_EXCEL/PSBVXLEB/Populate_POS_WS_Lines',
      'Position under process:'||l_position_name);

      --fnd_file.put_line(fnd_file.LOG,'Position under process:'||l_position_name);--bug:6019074

   end if;
   /*end bug:6019074:end STATEMENT level log*/

  /* Bug 2959635 Start */

      FOR emp_rec IN
      (
        SELECT
              emp.employee_id,
              emp.employee_number,
              emp.full_name
        FROM
              psb_employees emp, psb_position_assignments pavb
        WHERE pavb.assignment_type = 'EMPLOYEE'
        AND   pavb.position_id = l_position_id
        AND   emp.employee_id = pavb.employee_id
        AND   (pavb.worksheet_id = g_worksheet_id
              OR pavb.worksheet_id IS NULL)
       ORDER BY pavb.effective_start_date DESC, NVL(pavb.worksheet_id,0) DESC
       )
       LOOP
         l_employee_id := emp_rec.employee_id;
         l_employee_number := emp_rec.employee_number;
         l_employee_name := emp_rec.full_name;
         EXIT;
       END LOOP;

      FOR job_rec IN
      (
      SELECT
           pava.attribute_id,
           patv.attribute_value
      FROM   psb_attribute_values patv, psb_position_assignments pava
      WHERE  patv.attribute_value_id = pava.attribute_value_id
      AND    pava.position_id = l_position_id
      AND EXISTS (SELECT 1 FROM psb_attributes pat
                  WHERE pat.attribute_id = pava.attribute_id
                  AND pat.system_attribute_type = 'JOB_CLASS')
      AND    (pava.worksheet_id = g_worksheet_id
             OR pava.worksheet_id IS NULL)
      ORDER BY pava.effective_start_date DESC, NVL(pava.worksheet_id,0) DESC
      )
      LOOP
        l_job_attribute_id := job_rec.attribute_id;
        l_job_name := job_rec.attribute_value;
        EXIT;
      END LOOP;

  /* Bug 2959635 End */

      for c_Positions_Rec in (
	select a.position_id,
	  a.name,
	  a.effective_start_date,
	  a.effective_end_date
	from PSB_POSITIONS a,
	PSB_WS_POSITION_LINES b
	where a.position_id = b.position_id
	and b.position_line_id = l_position_line_id)
      loop
	l_position_start_date := c_Positions_Rec.effective_start_date;
	l_position_end_date := c_Positions_Rec.effective_end_date;
      end loop;
      -- this assumes the budget calendar is cached
      l_start_date := greatest(PSB_WS_ACCT1.g_startdate_cy, l_position_start_date);
      l_end_date   := least(PSB_WS_ACCT1.g_end_est_date,
		       nvl(l_position_end_date, PSB_WS_ACCT1.g_end_est_date));


      -- Get the postion data in PL/SQL tables for the effective date
      Cache_Position_Data(p_return_status     => l_return_status,
			  p_position_line_id  => l_position_line_id,
			  p_position_id       => l_position_id,
			  p_start_date        => l_start_date,
			  p_end_date          => l_end_date);


      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;



      -- Get the Account Lines for each position id
      FOR position_acct_rec IN
      (
	SELECT  worksheet_id
	       ,element_set_id
	       ,position_line_id
	       ,code_combination_id
	       ,service_package_id
	       ,service_package_name
	       ,account_type
	       ,currency_code
	       ,stage_set_id
	       ,budget_group_id
	       ,template_id
	       ,salary_account_line
	 FROM  psb_ws_year_positions_v
	 WHERE worksheet_id = g_worksheet_id
	 AND   position_line_id = l_position_line_id

/* Bug No 2008329 Start */
--         AND  ( g_account_flag = 'A' or account_type = g_account_flag )
       and  ( g_account_flag = 'T' or ACCOUNT_TYPE = g_account_flag
		 OR ( account_type = DECODE(g_account_flag,'P','R')
		      OR account_type = DECODE(g_account_flag,'P','E')
		    )
		 OR ( account_type = DECODE(g_account_flag,'N','A' )
		      OR account_type = DECODE(g_account_flag,'N','L')
		    )
		 OR ( account_type = DECODE(g_account_flag,'B','C' )
		      OR account_type = DECODE(g_account_flag,'B','D')
		    )
	    )
/* Bug No 2008329 End */

	 AND  ( ( g_currency_flag = 'C' and currency_code <> 'STAT' )
	      or
	      ( g_currency_flag = 'S' and currency_code = 'STAT')
	      )
	 AND  ( g_service_package_flag = 'A'   or
		service_package_id in
		 (select service_package_id
		   from  psb_ws_service_pkg_profiles_v
	    /* Following 2 lines commented and next 2 lines added for DDSP */
		-- where WORKSHEET_ID = g_worksheet_id
		--  and  USER_ID = g_user_id
		   where WORKSHEET_ID = g_profile_worksheet_id
		     and (USER_ID = g_profile_user_id or (g_profile_user_id IS NULL AND USER_ID IS NULL)) )
		    )
	      )
       LOOP
	 l_element_value_type := NULL;
	 l_code_combination_id   := position_acct_rec.code_combination_id;
	 l_element_set_id        := position_acct_rec.element_set_id;
	 l_service_package_id    := position_acct_rec.service_package_id;
	 l_service_package_name  := substr(position_acct_rec.service_package_name,1,30);
	 l_budget_group_id       := position_acct_rec.budget_group_id;


	 --Get Element name (Code taken from post query in POS WS form)
	 FOR pay_element_rec IN
	   (
	   SELECT distinct pe.pay_element_id, pe.name, pe.follow_salary, pe.element_value_type, pe.period_type
	          ,pe.data_extract_id --bug:6019074
	   FROM psb_ws_element_lines wel, psb_pay_elements_v pe
	   WHERE wel.position_line_id = l_position_line_id
	   AND wel.element_set_id = l_element_set_id
	   AND wel.pay_element_id = pe.pay_element_id)
	 LOOP
	   l_element_id            := pay_element_rec.pay_element_id;
	   l_element_name          := pay_element_rec.name;


	   l_follow_salary         := pay_element_rec.follow_salary;
	   l_element_value_type    := pay_element_rec.element_value_type;
	   l_period_type           := pay_element_rec.period_type;
	   l_data_extract_id       := pay_element_rec.data_extract_id; --bug:6019074
	 --END LOOP; --commented for bug:6019074

	 l_percent_of_salary_flag := 'N';
	 IF l_element_value_type = 'PS' THEN
	   Cache_PS_Elements(p_pay_element_id          => l_element_id,
			     p_pay_element_period_type => l_period_type,
			     p_pay_element_name        => l_element_name,
			     p_pay_element_set_id      => l_element_set_id
			    );
	   l_percent_of_salary_flag := 'Y';
	 END IF;

    /*start bug:6019074: STATEMENT level logging*/
   if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then

       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
      'PSB/IMPORT_WS_PSB_TO_EXCEL/PSBVXLEB/Populate_POS_WS_Lines',
      'element under process:'||l_element_name);

         --fnd_file.put_line(fnd_file.LOG,'element under process:'||l_element_name);--bug:6019074

   end if;
   /*end bug:6019074:end STATEMENT level log*/


	 FOR position_year_amt_rec IN
	 (
	   SELECT  column1_id
		  ,column2_id
		  ,column3_id
		  ,column4_id
		  ,column5_id
		  ,column6_id
		  ,column7_id
		  ,column8_id
		  ,column9_id
		  ,column10_id
		  ,column11_id
		  ,column12_id
	    FROM psb_ws_year_position_amounts_v
	    WHERE worksheet_id = g_worksheet_id
	    AND code_combination_id = l_code_combination_id
	    AND service_package_id = l_service_package_id
	    AND position_line_id = l_position_line_id
	    AND element_set_id = l_element_set_id

/* Bug No 2008329 Start */
--            AND  ( g_account_flag = 'A' or account_type = g_account_flag )
       and  ( g_account_flag = 'T' or ACCOUNT_TYPE = g_account_flag
		 OR ( account_type = DECODE(g_account_flag,'P','R')
		      OR account_type = DECODE(g_account_flag,'P','E')
		    )
		 OR ( account_type = DECODE(g_account_flag,'N','A' )
		      OR account_type = DECODE(g_account_flag,'N','L')
		    )
		 OR ( account_type = DECODE(g_account_flag,'B','C' )
		      OR account_type = DECODE(g_account_flag,'B','D')
		    )
	    )
/* Bug No 2008329 End */

	    AND  ( ( g_currency_flag = 'C' and currency_code <> 'STAT' )
		   or
		   ( g_currency_flag = 'S' and currency_code = 'STAT')
		 )
	 )
	 LOOP
	   -- Get the Account Line IDs and move them to a PL/SQL table
	   g_acl_ids(1).acl_id  := position_year_amt_rec.column1_id;
	   g_acl_ids(2).acl_id  := position_year_amt_rec.column2_id;
	   g_acl_ids(3).acl_id  := position_year_amt_rec.column3_id;
	   g_acl_ids(4).acl_id  := position_year_amt_rec.column4_id;
	   g_acl_ids(5).acl_id  := position_year_amt_rec.column5_id;
	   g_acl_ids(6).acl_id  := position_year_amt_rec.column6_id;
	   g_acl_ids(7).acl_id  := position_year_amt_rec.column7_id;
	   g_acl_ids(8).acl_id  := position_year_amt_rec.column8_id;
	   g_acl_ids(9).acl_id  := position_year_amt_rec.column9_id;
	   g_acl_ids(10).acl_id := position_year_amt_rec.column10_id;
	   g_acl_ids(11).acl_id := position_year_amt_rec.column11_id;
	   g_acl_ids(12).acl_id := position_year_amt_rec.column12_id;


	   l_wlbi_start_index := 1;

	   --dbms_output.put_line('Tot Bud Yrs' ||g_total_budget_years);

	   --- For each budget year get period amts using wal or fte table
	   FOR col_index in 1..g_total_budget_years LOOP

	     -- First Get the number of periods in the budget year
	     l_budget_year_id := g_ws_cols(col_index).budget_year_id;
	     l_balance_type   := g_ws_cols(col_index).balance_type;
	     l_year_num_periods := g_year_num_periods(l_budget_year_id).num_of_periods;
	     l_wlbi_end_index := l_wlbi_start_index + l_year_num_periods + 1;

	     l_fte_rec_found := FND_API.G_FALSE;
	     l_wal_rec_found := FND_API.G_FALSE;

	     IF l_balance_type = 'F' THEN
	       FOR fte_lines_rec IN
	       (
		 select
			annual_fte
		       ,period1_fte
		       ,period2_fte
		       ,period3_fte
		       ,period4_fte
		       ,period5_fte
		       ,period6_fte
		       ,period7_fte
		       ,period8_fte
		       ,period9_fte
		       ,period10_fte
		       ,period11_fte
		       ,period12_fte
		from psb_ws_fte_lines
		where position_line_id = l_position_line_id
		and budget_year_id = l_budget_year_id
		and service_package_id = l_service_package_id
		and ( (g_stage_id = 0 and end_stage_seq is null )
		       or
		      (g_stage_id  between start_stage_seq  and  nvl(end_stage_seq, 9.99e125) ))
	       )
	       LOOP
		 l_fte_rec_found := FND_API.G_TRUE;
		 g_wlbi_amounts(l_wlbi_start_index).amount := fte_lines_rec.annual_fte;
		 g_wal_period_amounts(1).amount  := fte_lines_rec.period1_fte;
		 g_wal_period_amounts(2).amount  := fte_lines_rec.period2_fte;
		 g_wal_period_amounts(3).amount  := fte_lines_rec.period3_fte;
		 g_wal_period_amounts(4).amount  := fte_lines_rec.period4_fte;
		 g_wal_period_amounts(5).amount  := fte_lines_rec.period5_fte;
		 g_wal_period_amounts(6).amount  := fte_lines_rec.period6_fte;
		 g_wal_period_amounts(7).amount  := fte_lines_rec.period7_fte;
		 g_wal_period_amounts(8).amount  := fte_lines_rec.period8_fte;
		 g_wal_period_amounts(9).amount  := fte_lines_rec.period9_fte;
		 g_wal_period_amounts(10).amount := fte_lines_rec.period10_fte;
		 g_wal_period_amounts(11).amount := fte_lines_rec.period11_fte;
		 g_wal_period_amounts(12).amount := fte_lines_rec.period12_fte;

	       END LOOP;


	     ELSIF ( g_acl_ids(col_index).acl_id > 0 ) THEN  -- balance_type in (A,B,E)

         	     /*bug:6019074:start*/
               for i in 1..g_wal_period_amounts.count loop
 	          g_wal_period_amounts(i).amount := 0;
               end loop;
      	           /*bug:6019074:end*/

    /*start bug:6019074: STATEMENT level logging*/
   if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then

       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
      'PSB/IMPORT_WS_PSB_TO_EXCEL/PSBVXLEB/Populate_POS_WS_Lines',
      'ccid under process:'||l_code_combination_id);

      --fnd_file.put_line(fnd_file.LOG,'ccid under process:'||l_code_combination_id);--bug:6019074

   end if;
   /*end bug:6019074:end STATEMENT level log*/


	     /*Bug:6019074:modified the below query by introducing join with
	       psb_ws_element_lines. This is required to fetch the element_cost
	       at element level instead of using the ytd_amount from psb_ws_account_lines */

	       FOR wal_rec IN
		 (
		 -- Include the other period columns if supporting more than 12
		 SELECT ytd_amount
		 /*bug:6019074:start*/
		       ,pwel.element_cost
		       ,ppe.element_value_type
		       ,ppe.salary_flag
		       ,ppe.processing_type
		       ,ppe.period_type
		       ,pwal.service_package_id
		       ,pwal.currency_code
		 /*bug:6019074:end*/
		       ,pwal.start_stage_seq
		       ,pwal.current_stage_seq
		       ,pwal.period1_amount
		       ,pwal.period2_amount
		       ,pwal.period3_amount
		       ,pwal.period4_amount
		       ,pwal.period5_amount
		       ,pwal.period6_amount
		       ,pwal.period7_amount
		       ,pwal.period8_amount
		       ,pwal.period9_amount
		       ,pwal.period10_amount
		       ,pwal.period11_amount
		       ,pwal.period12_amount
		 FROM  psb_ws_account_lines pwal,
		       psb_ws_element_lines pwel,
		       psb_pay_elements     ppe
		 WHERE account_line_id = g_acl_ids(col_index).acl_id
		 /* bug:6019074:start*/
		 AND   pwel.position_line_id = pwal.position_line_id
		 AND   pwal.code_combination_id = l_code_combination_id
		 AND   pwel.element_set_id = pwal.element_set_id
		 AND   pwel.budget_year_id = pwal.budget_year_id
		 AND   pwel.budget_year_id = l_budget_year_id
		 AND   pwel.pay_element_id = l_element_id
		 AND   ppe.pay_element_id  = pwel.pay_element_id
		 AND   ppe.data_extract_id = l_data_extract_id
		 ORDER BY ppe.element_value_type asc, ppe.processing_type desc
		 /* bug:6019074:end*/
		 )
	       LOOP

	  /*bug:6019074:start*/

		 l_rounding_amt := 0;
		 l_year_amount := wal_rec.ytd_amount;

         /*start bug:6019074: STATEMENT level logging*/
        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then

           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
          'PSB/IMPORT_WS_PSB_TO_EXCEL/PSBVXLEB/Populate_POS_WS_Lines',
          'account line id:'||g_acl_ids(col_index).acl_id||
          'l_budget_year_id:'||l_budget_year_id||
          'l_year_amount used:'||l_year_amount||
          'wal_rec.element_cost:'||wal_rec.element_cost);

           --fnd_file.put_line(fnd_file.LOG,'account line id:'||g_acl_ids(col_index).acl_id);
           --fnd_file.put_line(fnd_file.LOG,'l_budget_year_id:'||l_budget_year_id);
           --fnd_file.put_line(fnd_file.LOG,'l_year_amount used:'||l_year_amount);
           --fnd_file.put_line(fnd_file.LOG,'wal_rec.element_cost:'||wal_rec.element_cost);
        end if;
   /*end bug:6019074:end STATEMENT level log*/


                 l_element_set_cost := 0;
                 FOR l_ele_cnt_rec IN l_eleset_cost_csr(wal_rec.current_stage_seq,
                                                         wal_rec.service_package_id,
                                                         wal_rec.currency_code) LOOP
                    l_element_set_cost := l_ele_cnt_rec.element_set_cost;
                 END LOOP;

		 IF l_year_amount > 0 THEN
   		  l_wal_rec_found := FND_API.G_TRUE;

                   g_wal_period_amounts(1).amount :=
                      (wal_rec.period1_amount * wal_rec.element_cost)/(l_element_set_cost);

                    g_wal_period_amounts(2).amount :=
                      (wal_rec.period2_amount * wal_rec.element_cost)/(l_element_set_cost);

                    g_wal_period_amounts(3).amount :=
                      (wal_rec.period3_amount * wal_rec.element_cost)/(l_element_set_cost);

                    g_wal_period_amounts(4).amount :=
                      (wal_rec.period4_amount * wal_rec.element_cost)/(l_element_set_cost);

                    g_wal_period_amounts(5).amount :=
                      (wal_rec.period5_amount * wal_rec.element_cost)/(l_element_set_cost);

                    g_wal_period_amounts(6).amount :=
                      (wal_rec.period6_amount * wal_rec.element_cost)/(l_element_set_cost);

                    g_wal_period_amounts(7).amount :=
                      (wal_rec.period7_amount* wal_rec.element_cost)/(l_element_set_cost);

                    g_wal_period_amounts(8).amount :=
                      (wal_rec.period8_amount * wal_rec.element_cost)/(l_element_set_cost);

                    g_wal_period_amounts(9).amount :=
                      (wal_rec.period9_amount * wal_rec.element_cost)/(l_element_set_cost);

                    g_wal_period_amounts(10).amount :=
                      (wal_rec.period10_amount * wal_rec.element_cost)/(l_element_set_cost);

                    g_wal_period_amounts(11).amount :=
                      (wal_rec.period11_amount * wal_rec.element_cost)/(l_element_set_cost);

                    g_wal_period_amounts(12).amount :=
                      (wal_rec.period12_amount * wal_rec.element_cost)/(l_element_set_cost);

                    g_wlbi_amounts(l_wlbi_start_index).amount :=
                      (wal_rec.ytd_amount * wal_rec.element_cost)/(l_element_set_cost);

                    l_element_cost := g_wlbi_amounts(l_wlbi_start_index).amount;

	 	  g_wal_period_amounts(1).amount  :=
                                  nvl(round(g_wal_period_amounts(1).amount/l_rounding_factor)*l_rounding_factor,0);

	 	  g_wal_period_amounts(2).amount  :=
                                  nvl(round(g_wal_period_amounts(2).amount/l_rounding_factor)*l_rounding_factor,0);

	 	  g_wal_period_amounts(3).amount  :=
                                  nvl(round(g_wal_period_amounts(3).amount/l_rounding_factor)*l_rounding_factor,0);

	 	  g_wal_period_amounts(4).amount  :=
                                  nvl(round(g_wal_period_amounts(4).amount/l_rounding_factor)*l_rounding_factor,0);

	 	  g_wal_period_amounts(5).amount  :=
                                  nvl(round(g_wal_period_amounts(5).amount/l_rounding_factor)*l_rounding_factor,0);

	 	  g_wal_period_amounts(6).amount  :=
                                  nvl(round(g_wal_period_amounts(6).amount/l_rounding_factor)*l_rounding_factor,0);

	 	  g_wal_period_amounts(7).amount  :=
                                  nvl(round(g_wal_period_amounts(7).amount/l_rounding_factor)*l_rounding_factor,0);

	 	  g_wal_period_amounts(8).amount  :=
                                  nvl(round(g_wal_period_amounts(8).amount/l_rounding_factor)*l_rounding_factor,0);

		  g_wal_period_amounts(9).amount  :=
                                  nvl(round(g_wal_period_amounts(9).amount/l_rounding_factor)*l_rounding_factor,0);

		  g_wal_period_amounts(10).amount  :=
                                  nvl(round(g_wal_period_amounts(10).amount/l_rounding_factor)*l_rounding_factor,0);

		  g_wal_period_amounts(11).amount  :=
                                  nvl(round(g_wal_period_amounts(11).amount/l_rounding_factor)*l_rounding_factor,0);

		  g_wal_period_amounts(12).amount  :=
                                  nvl(round(g_wal_period_amounts(12).amount/l_rounding_factor)*l_rounding_factor,0);


		 l_rounding_amt := nvl(g_wal_period_amounts(1).amount,0) +
		                   nvl(g_wal_period_amounts(2).amount,0) +
		                   nvl(g_wal_period_amounts(3).amount,0) +
		                   nvl(g_wal_period_amounts(4).amount,0) +
		                   nvl(g_wal_period_amounts(5).amount,0) +
		                   nvl(g_wal_period_amounts(6).amount,0) +
		                   nvl(g_wal_period_amounts(7).amount,0) +
		                   nvl(g_wal_period_amounts(8).amount,0) +
		                   nvl(g_wal_period_amounts(9).amount,0) +
		                   nvl(g_wal_period_amounts(10).amount,0) +
		                   nvl(g_wal_period_amounts(11).amount,0) +
		                   nvl(g_wal_period_amounts(12).amount,0);


                 l_rounding_diff := nvl(l_rounding_amt,0) - nvl(l_element_cost,0);

         /*start bug:6019074: STATEMENT level logging*/
        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then

           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
          'PSB/IMPORT_WS_PSB_TO_EXCEL/PSBVXLEB/Populate_POS_WS_Lines',
          'rounding amt:'||l_rounding_amt||
          'l_element_cost:'||l_element_cost||
          'l_rounding_diff:'||l_rounding_diff);

            --fnd_file.put_line(fnd_file.LOG,'rounding amt:'||l_rounding_amt);
            --fnd_file.put_line(fnd_file.LOG,'l_element_cost:'||l_element_cost);
            --fnd_file.put_line(fnd_file.LOG,'l_rounding_diff:'||l_rounding_diff);
        end if;
    /*end bug:6019074:end STATEMENT level log*/

	         g_wal_period_amounts(12).amount := g_wal_period_amounts(12).amount - nvl(l_rounding_diff,0);

            END IF;
		 /*bug:6019074:end*/

              END LOOP;  --wal_rec
             END IF; -- balance type = 'F' or (balance_type in (A,B,E) and acl id >0)

	     -- Set the second column to zero percent for each year
	     g_wlbi_amounts(l_wlbi_start_index+1).amount := 0;  -- Set percentage to zero ; dummy column

	     --

	      /* bug:6019074:Initializing the line balances table*/
	       FOR l_wlbi_col_index in l_wlbi_start_index+2  .. l_wlbi_end_index
	       LOOP
		 g_wlbi_amounts(l_wlbi_col_index).amount := NULL;
	       END LOOP;
              /*bug:6019074:end*/

	     IF ( l_wal_rec_found = FND_API.G_TRUE ) OR
		( l_fte_rec_found = FND_API.G_TRUE ) THEN
	       l_wal_col_index := 0;

	       FOR l_wlbi_col_index in l_wlbi_start_index+2 .. l_wlbi_end_index
	       LOOP
		 l_wal_col_index := l_wal_col_index + 1;
		 g_wlbi_amounts(l_wlbi_col_index).amount := g_wal_period_amounts(l_wal_col_index).amount;

	       END LOOP;
	     ELSE

	       -- if no wal or fte rec found set values to null
	       FOR l_wlbi_col_index in l_wlbi_start_index  .. l_wlbi_end_index
	       LOOP
		 g_wlbi_amounts(l_wlbi_col_index).amount := 0;

	       END LOOP;
	     END IF;
	     l_wlbi_start_index := l_wlbi_end_index + 1;

	   END LOOP;  -- For each Budget Year Balance

	   IF FND_FLEX_KEYVAL.validate_ccid('SQLGL', 'GL#', g_coa_id, l_code_combination_id) THEN
	     l_account_segments :=   substr(FND_FLEX_KEYVAL.concatenated_values,1,1000);
	     l_account_desc :=   substr(FND_FLEX_KEYVAL.concatenated_descriptions,1,1000);
	   END IF;

	   -- Maximum columns used = 168
	   -- (12 years * 12 periods ) + 12 years * 2 misc columns = 168
	   --  4 misc columns (Year Total, Percentage, Start stage seq, End stage seq)
	   --  Later include amount169..amount220 when supporting
	   --  more than 12 periods for an year

	   INSERT INTO psb_ws_line_balances_i(
	   EXPORT_ID,
	   EXPORT_WORKSHEET_TYPE,
	   CODE_COMBINATION_ID,
	   BUDGET_GROUP_ID,
	   CONCATENATED_ACCOUNT,
	   ACCOUNT_DESCRIPTION,
	   SERVICE_PACKAGE_ID,
	   SERVICE_PACKAGE_NAME,
	   PAY_ELEMENT_SET_ID,
	   PAY_ELEMENT_ID,
	   PAY_ELEMENT_NAME,
	   SALARY_ACCOUNT_LINE,
	   FOLLOW_SALARY,
	   POSITION_LINE_ID,
	   POSITION_ID,
	   POSITION_NAME,
	   POSITION_SEGMENTS,
	   JOB_NAME,
	   EMPLOYEE_ID,
	   EMPLOYEE_NUMBER,
	   EMPLOYEE_NAME,
	   VALUE_TYPE,
	   PERCENT_OF_SALARY_FLAG,
	   AMOUNT1,
	   AMOUNT2,
	   AMOUNT3,
	   AMOUNT4,
	   AMOUNT5,
	   AMOUNT6,
	   AMOUNT7,
	   AMOUNT8,
	   AMOUNT9,
	   AMOUNT10,
	   AMOUNT11,
	   AMOUNT12,
	   AMOUNT13,
	   AMOUNT14,
	   AMOUNT15,
	   AMOUNT16,
	   AMOUNT17,
	   AMOUNT18,
	   AMOUNT19,
	   AMOUNT20,
	   AMOUNT21,
	   AMOUNT22,
	   AMOUNT23,
	   AMOUNT24,
	   AMOUNT25,
	   AMOUNT26,
	   AMOUNT27,
	   AMOUNT28,
	   AMOUNT29,
	   AMOUNT30,
	   AMOUNT31,
	   AMOUNT32,
	   AMOUNT33,
	   AMOUNT34,
	   AMOUNT35,
	   AMOUNT36,
	   AMOUNT37,
	   AMOUNT38,
	   AMOUNT39,
	   AMOUNT40,
	   AMOUNT41,
	   AMOUNT42,
	   AMOUNT43,
	   AMOUNT44,
	   AMOUNT45,
	   AMOUNT46,
	   AMOUNT47,
	   AMOUNT48,
	   AMOUNT49,
	   AMOUNT50,
	   AMOUNT51,
	   AMOUNT52,
	   AMOUNT53,
	   AMOUNT54,
	   AMOUNT55,
	   AMOUNT56,
	   AMOUNT57,
	   AMOUNT58,
	   AMOUNT59,
	   AMOUNT60,
	   AMOUNT61,
	   AMOUNT62,
	   AMOUNT63,
	   AMOUNT64,
	   AMOUNT65,
	   AMOUNT66,
	   AMOUNT67,
	   AMOUNT68,
	   AMOUNT69,
	   AMOUNT70,
	   AMOUNT71,
	   AMOUNT72,
	   AMOUNT73,
	   AMOUNT74,
	   AMOUNT75,
	   AMOUNT76,
	   AMOUNT77,
	   AMOUNT78,
	   AMOUNT79,
	   AMOUNT80,
	   AMOUNT81,
	   AMOUNT82,
	   AMOUNT83,
	   AMOUNT84,
	   AMOUNT85,
	   AMOUNT86,
	   AMOUNT87,
	   AMOUNT88,
	   AMOUNT89,
	   AMOUNT90,
	   AMOUNT91,
	   AMOUNT92,
	   AMOUNT93,
	   AMOUNT94,
	   AMOUNT95,
	   AMOUNT96,
	   AMOUNT97,
	   AMOUNT98,
	   AMOUNT99,
	   AMOUNT100,
	   AMOUNT101,
	   AMOUNT102,
	   AMOUNT103,
	   AMOUNT104,
	   AMOUNT105,
	   AMOUNT106,
	   AMOUNT107,
	   AMOUNT108,
	   AMOUNT109,
	   AMOUNT110,
	   AMOUNT111,
	   AMOUNT112,
	   AMOUNT113,
	   AMOUNT114,
	   AMOUNT115,
	   AMOUNT116,
	   AMOUNT117,
	   AMOUNT118,
	   AMOUNT119,
	   AMOUNT120,
	   AMOUNT121,
	   AMOUNT122,
	   AMOUNT123,
	   AMOUNT124,
	   AMOUNT125,
	   AMOUNT126,
	   AMOUNT127,
	   AMOUNT128,
	   AMOUNT129,
	   AMOUNT130,
	   AMOUNT131,
	   AMOUNT132,
	   AMOUNT133,
	   AMOUNT134,
	   AMOUNT135,
	   AMOUNT136,
	   AMOUNT137,
	   AMOUNT138,
	   AMOUNT139,
	   AMOUNT140,
	   AMOUNT141,
	   AMOUNT142,
	   AMOUNT143,
	   AMOUNT144,
	   AMOUNT145,
	   AMOUNT146,
	   AMOUNT147,
	   AMOUNT148,
	   AMOUNT149,
	   AMOUNT150,
	   AMOUNT151,
	   AMOUNT152,
	   AMOUNT153,
	   AMOUNT154,
	   AMOUNT155,
	   AMOUNT156,
	   AMOUNT157,
	   AMOUNT158,
	   AMOUNT159,
	   AMOUNT160,
	   AMOUNT161,
	   AMOUNT162,
	   AMOUNT163,
	   AMOUNT164,
	   AMOUNT165,
	   AMOUNT166,
	   AMOUNT167,
	   AMOUNT168,
	   LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_LOGIN,
	   CREATED_BY,
	   CREATED_DATE)
	   values(
	   g_export_id,
	   'P',
	   l_code_combination_id,
	   l_budget_group_id,
	   l_account_segments,
	   l_account_desc,
	   l_service_package_id,
	   l_service_package_name,
	   l_element_set_id,
	   l_element_id,
	   l_element_name,
	   nvl(position_acct_rec.salary_account_line,'N'),
	   nvl(l_follow_salary,'N'),
	   position_rec.position_line_id,
	   position_rec.position_id,
	   position_rec.position_name,
	   position_rec.position_segments,
	   l_job_name,
	   l_employee_id,
	   l_employee_number,
	   l_employee_name,
	   'A',  -- For Amount
	   l_percent_of_salary_flag,
	   g_wlbi_amounts(1).amount,
	   g_wlbi_amounts(2).amount,
	   g_wlbi_amounts(3).amount,
	   g_wlbi_amounts(4).amount,
	   g_wlbi_amounts(5).amount,
	   g_wlbi_amounts(6).amount,
	   g_wlbi_amounts(7).amount,
	   g_wlbi_amounts(8).amount,
	   g_wlbi_amounts(9).amount,
	   g_wlbi_amounts(10).amount,
	   g_wlbi_amounts(11).amount,
	   g_wlbi_amounts(12).amount,
	   g_wlbi_amounts(13).amount,
	   g_wlbi_amounts(14).amount,
	   g_wlbi_amounts(15).amount,
	   g_wlbi_amounts(16).amount,
	   g_wlbi_amounts(17).amount,
	   g_wlbi_amounts(18).amount,
	   g_wlbi_amounts(19).amount,
	   g_wlbi_amounts(20).amount,
	   g_wlbi_amounts(21).amount,
	   g_wlbi_amounts(22).amount,
	   g_wlbi_amounts(23).amount,
	   g_wlbi_amounts(24).amount,
	   g_wlbi_amounts(25).amount,
	   g_wlbi_amounts(26).amount,
	   g_wlbi_amounts(27).amount,
	   g_wlbi_amounts(28).amount,
	   g_wlbi_amounts(29).amount,
	   g_wlbi_amounts(30).amount,
	   g_wlbi_amounts(31).amount,
	   g_wlbi_amounts(32).amount,
	   g_wlbi_amounts(33).amount,
	   g_wlbi_amounts(34).amount,
	   g_wlbi_amounts(35).amount,
	   g_wlbi_amounts(36).amount,
	   g_wlbi_amounts(37).amount,
	   g_wlbi_amounts(38).amount,
	   g_wlbi_amounts(39).amount,
	   g_wlbi_amounts(40).amount,
	   g_wlbi_amounts(41).amount,
	   g_wlbi_amounts(42).amount,
	   g_wlbi_amounts(43).amount,
	   g_wlbi_amounts(44).amount,
	   g_wlbi_amounts(45).amount,
	   g_wlbi_amounts(46).amount,
	   g_wlbi_amounts(47).amount,
	   g_wlbi_amounts(48).amount,
	   g_wlbi_amounts(49).amount,
	   g_wlbi_amounts(50).amount,
	   g_wlbi_amounts(51).amount,
	   g_wlbi_amounts(52).amount,
	   g_wlbi_amounts(53).amount,
	   g_wlbi_amounts(54).amount,
	   g_wlbi_amounts(55).amount,
	   g_wlbi_amounts(56).amount,
	   g_wlbi_amounts(57).amount,
	   g_wlbi_amounts(58).amount,
	   g_wlbi_amounts(59).amount,
	   g_wlbi_amounts(60).amount,
	   g_wlbi_amounts(61).amount,
	   g_wlbi_amounts(62).amount,
	   g_wlbi_amounts(63).amount,
	   g_wlbi_amounts(64).amount,
	   g_wlbi_amounts(65).amount,
	   g_wlbi_amounts(66).amount,
	   g_wlbi_amounts(67).amount,
	   g_wlbi_amounts(68).amount,
	   g_wlbi_amounts(69).amount,
	   g_wlbi_amounts(70).amount,
	   g_wlbi_amounts(71).amount,
	   g_wlbi_amounts(72).amount,
	   g_wlbi_amounts(73).amount,
	   g_wlbi_amounts(74).amount,
	   g_wlbi_amounts(75).amount,
	   g_wlbi_amounts(76).amount,
	   g_wlbi_amounts(77).amount,
	   g_wlbi_amounts(78).amount,
	   g_wlbi_amounts(79).amount,
	   g_wlbi_amounts(80).amount,
	   g_wlbi_amounts(81).amount,
	   g_wlbi_amounts(82).amount,
	   g_wlbi_amounts(83).amount,
	   g_wlbi_amounts(84).amount,
	   g_wlbi_amounts(85).amount,
	   g_wlbi_amounts(86).amount,
	   g_wlbi_amounts(87).amount,
	   g_wlbi_amounts(88).amount,
	   g_wlbi_amounts(89).amount,
	   g_wlbi_amounts(90).amount,
	   g_wlbi_amounts(91).amount,
	   g_wlbi_amounts(92).amount,
	   g_wlbi_amounts(93).amount,
	   g_wlbi_amounts(94).amount,
	   g_wlbi_amounts(95).amount,
	   g_wlbi_amounts(96).amount,
	   g_wlbi_amounts(97).amount,
	   g_wlbi_amounts(98).amount,
	   g_wlbi_amounts(99).amount,
	   g_wlbi_amounts(100).amount,
	   g_wlbi_amounts(101).amount,
	   g_wlbi_amounts(102).amount,
	   g_wlbi_amounts(103).amount,
	   g_wlbi_amounts(104).amount,
	   g_wlbi_amounts(105).amount,
	   g_wlbi_amounts(106).amount,
	   g_wlbi_amounts(107).amount,
	   g_wlbi_amounts(108).amount,
	   g_wlbi_amounts(109).amount,
	   g_wlbi_amounts(110).amount,
	   g_wlbi_amounts(111).amount,
	   g_wlbi_amounts(112).amount,
	   g_wlbi_amounts(113).amount,
	   g_wlbi_amounts(114).amount,
	   g_wlbi_amounts(115).amount,
	   g_wlbi_amounts(116).amount,
	   g_wlbi_amounts(117).amount,
	   g_wlbi_amounts(118).amount,
	   g_wlbi_amounts(119).amount,
	   g_wlbi_amounts(120).amount,
	   g_wlbi_amounts(121).amount,
	   g_wlbi_amounts(122).amount,
	   g_wlbi_amounts(123).amount,
	   g_wlbi_amounts(124).amount,
	   g_wlbi_amounts(125).amount,
	   g_wlbi_amounts(126).amount,
	   g_wlbi_amounts(127).amount,
	   g_wlbi_amounts(128).amount,
	   g_wlbi_amounts(129).amount,
	   g_wlbi_amounts(130).amount,
	   g_wlbi_amounts(131).amount,
	   g_wlbi_amounts(132).amount,
	   g_wlbi_amounts(133).amount,
	   g_wlbi_amounts(134).amount,
	   g_wlbi_amounts(135).amount,
	   g_wlbi_amounts(136).amount,
	   g_wlbi_amounts(137).amount,
	   g_wlbi_amounts(138).amount,
	   g_wlbi_amounts(139).amount,
	   g_wlbi_amounts(140).amount,
	   g_wlbi_amounts(141).amount,
	   g_wlbi_amounts(142).amount,
	   g_wlbi_amounts(143).amount,
	   g_wlbi_amounts(144).amount,
	   g_wlbi_amounts(145).amount,
	   g_wlbi_amounts(146).amount,
	   g_wlbi_amounts(147).amount,
	   g_wlbi_amounts(148).amount,
	   g_wlbi_amounts(149).amount,
	   g_wlbi_amounts(150).amount,
	   g_wlbi_amounts(151).amount,
	   g_wlbi_amounts(152).amount,
	   g_wlbi_amounts(153).amount,
	   g_wlbi_amounts(154).amount,
	   g_wlbi_amounts(155).amount,
	   g_wlbi_amounts(156).amount,
	   g_wlbi_amounts(157).amount,
	   g_wlbi_amounts(158).amount,
	   g_wlbi_amounts(159).amount,
	   g_wlbi_amounts(160).amount,
	   g_wlbi_amounts(161).amount,
	   g_wlbi_amounts(162).amount,
	   g_wlbi_amounts(163).amount,
	   g_wlbi_amounts(164).amount,
	   g_wlbi_amounts(165).amount,
	   g_wlbi_amounts(166).amount,
	   g_wlbi_amounts(167).amount,
	   g_wlbi_amounts(168).amount,
	   SYSDATE,
	   g_user_id,
	   g_user_id,
	   g_user_id,
	   SYSDATE
	   );

	END LOOP; -- position_year_amt_rec
      END LOOP; -- position_acct_rec
    END LOOP; --bug:6019074

      -- Insert PS Element Percentages; Added on 11/18/98
      IF g_ps_elements.COUNT > 0 THEN


	FOR i in 1.. g_ps_elements.COUNT LOOP
	  l_wlbi_start_index := 1;
	  --dbms_output.put_line('Tot Bud Yrs' ||g_total_budget_years);

	  -- For each budget year get ps element percentages
	  FOR col_index in 1..g_total_budget_years LOOP

	    -- First Get the number of periods in the budget year
	    l_budget_year_id   := g_ws_cols(col_index).budget_year_id;
	    l_balance_type     := g_ws_cols(col_index).balance_type;
	    l_year_num_periods := g_year_num_periods(l_budget_year_id).num_of_periods;
	    l_wlbi_end_index   := l_wlbi_start_index + l_year_num_periods + 1;
	    l_found_ps_pct     := FALSE;

	    -- Set the first and second column to zero (not applicable for PS Element Lines)
	    g_wlbi_amounts(l_wlbi_start_index).amount   := 0;
	    g_wlbi_amounts(l_wlbi_start_index+1).amount := 0;

	    IF l_balance_type IN  ('A','B','E') THEN

	      Populate_PS_Element_Pct ( p_budget_year_id      => l_budget_year_id,
					p_position_id         => l_position_id,
					p_pay_element_id      => g_ps_elements(i).pay_element_id,
					p_element_period_type => g_ps_elements(i).pay_element_period_type,
					p_found_ps_pct        => l_found_ps_pct
				      );
	    END IF;

	    IF l_found_ps_pct THEN
	      l_wal_col_index := 0;
	      FOR l_wlbi_col_index in l_wlbi_start_index+2 .. l_wlbi_end_index
	      LOOP
		l_wal_col_index := l_wal_col_index + 1;
		g_wlbi_amounts(l_wlbi_col_index).amount := g_ps_element_pct(l_wal_col_index).amount;
	      END LOOP;
	    ELSE -- populate null
	      FOR l_wlbi_col_index in l_wlbi_start_index  .. l_wlbi_end_index
	      LOOP
		g_wlbi_amounts(l_wlbi_col_index).amount := NULL;
	      END LOOP;
	    END IF;  -- found_ps_pct
	    l_wlbi_start_index := l_wlbi_end_index + 1;

	  END LOOP; -- for each budget year and balance;

	  -- Insert Statement
	   INSERT INTO psb_ws_line_balances_i(
	   EXPORT_ID,
	   EXPORT_WORKSHEET_TYPE,
	   CODE_COMBINATION_ID,
	   BUDGET_GROUP_ID,
	   CONCATENATED_ACCOUNT,
	   ACCOUNT_DESCRIPTION,
	   SERVICE_PACKAGE_ID,
	   SERVICE_PACKAGE_NAME,
	   PAY_ELEMENT_SET_ID,
	   PAY_ELEMENT_ID,
	   PAY_ELEMENT_NAME,
	   SALARY_ACCOUNT_LINE,
	   FOLLOW_SALARY,
	   POSITION_LINE_ID,
	   POSITION_ID,
	   POSITION_NAME,
	   POSITION_SEGMENTS,
	   JOB_NAME,
	   EMPLOYEE_ID,
	   EMPLOYEE_NUMBER,
	   EMPLOYEE_NAME,
	   VALUE_TYPE,
	   PERCENT_OF_SALARY_FLAG,
	   AMOUNT1,
	   AMOUNT2,
	   AMOUNT3,
	   AMOUNT4,
	   AMOUNT5,
	   AMOUNT6,
	   AMOUNT7,
	   AMOUNT8,
	   AMOUNT9,
	   AMOUNT10,
	   AMOUNT11,
	   AMOUNT12,
	   AMOUNT13,
	   AMOUNT14,
	   AMOUNT15,
	   AMOUNT16,
	   AMOUNT17,
	   AMOUNT18,
	   AMOUNT19,
	   AMOUNT20,
	   AMOUNT21,
	   AMOUNT22,
	   AMOUNT23,
	   AMOUNT24,
	   AMOUNT25,
	   AMOUNT26,
	   AMOUNT27,
	   AMOUNT28,
	   AMOUNT29,
	   AMOUNT30,
	   AMOUNT31,
	   AMOUNT32,
	   AMOUNT33,
	   AMOUNT34,
	   AMOUNT35,
	   AMOUNT36,
	   AMOUNT37,
	   AMOUNT38,
	   AMOUNT39,
	   AMOUNT40,
	   AMOUNT41,
	   AMOUNT42,
	   AMOUNT43,
	   AMOUNT44,
	   AMOUNT45,
	   AMOUNT46,
	   AMOUNT47,
	   AMOUNT48,
	   AMOUNT49,
	   AMOUNT50,
	   AMOUNT51,
	   AMOUNT52,
	   AMOUNT53,
	   AMOUNT54,
	   AMOUNT55,
	   AMOUNT56,
	   AMOUNT57,
	   AMOUNT58,
	   AMOUNT59,
	   AMOUNT60,
	   AMOUNT61,
	   AMOUNT62,
	   AMOUNT63,
	   AMOUNT64,
	   AMOUNT65,
	   AMOUNT66,
	   AMOUNT67,
	   AMOUNT68,
	   AMOUNT69,
	   AMOUNT70,
	   AMOUNT71,
	   AMOUNT72,
	   AMOUNT73,
	   AMOUNT74,
	   AMOUNT75,
	   AMOUNT76,
	   AMOUNT77,
	   AMOUNT78,
	   AMOUNT79,
	   AMOUNT80,
	   AMOUNT81,
	   AMOUNT82,
	   AMOUNT83,
	   AMOUNT84,
	   AMOUNT85,
	   AMOUNT86,
	   AMOUNT87,
	   AMOUNT88,
	   AMOUNT89,
	   AMOUNT90,
	   AMOUNT91,
	   AMOUNT92,
	   AMOUNT93,
	   AMOUNT94,
	   AMOUNT95,
	   AMOUNT96,
	   AMOUNT97,
	   AMOUNT98,
	   AMOUNT99,
	   AMOUNT100,
	   AMOUNT101,
	   AMOUNT102,
	   AMOUNT103,
	   AMOUNT104,
	   AMOUNT105,
	   AMOUNT106,
	   AMOUNT107,
	   AMOUNT108,
	   AMOUNT109,
	   AMOUNT110,
	   AMOUNT111,
	   AMOUNT112,
	   AMOUNT113,
	   AMOUNT114,
	   AMOUNT115,
	   AMOUNT116,
	   AMOUNT117,
	   AMOUNT118,
	   AMOUNT119,
	   AMOUNT120,
	   AMOUNT121,
	   AMOUNT122,
	   AMOUNT123,
	   AMOUNT124,
	   AMOUNT125,
	   AMOUNT126,
	   AMOUNT127,
	   AMOUNT128,
	   AMOUNT129,
	   AMOUNT130,
	   AMOUNT131,
	   AMOUNT132,
	   AMOUNT133,
	   AMOUNT134,
	   AMOUNT135,
	   AMOUNT136,
	   AMOUNT137,
	   AMOUNT138,
	   AMOUNT139,
	   AMOUNT140,
	   AMOUNT141,
	   AMOUNT142,
	   AMOUNT143,
	   AMOUNT144,
	   AMOUNT145,
	   AMOUNT146,
	   AMOUNT147,
	   AMOUNT148,
	   AMOUNT149,
	   AMOUNT150,
	   AMOUNT151,
	   AMOUNT152,
	   AMOUNT153,
	   AMOUNT154,
	   AMOUNT155,
	   AMOUNT156,
	   AMOUNT157,
	   AMOUNT158,
	   AMOUNT159,
	   AMOUNT160,
	   AMOUNT161,
	   AMOUNT162,
	   AMOUNT163,
	   AMOUNT164,
	   AMOUNT165,
	   AMOUNT166,
	   AMOUNT167,
	   AMOUNT168,
	   LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_LOGIN,
	   CREATED_BY,
	   CREATED_DATE)
	   values(
	   g_export_id,
	   'P',
	   null,
	   null,
	   null,
	   null,
	   null,
	   null,
	   g_ps_elements(i).pay_element_set_id,
	   g_ps_elements(i).pay_element_id,
	   g_ps_elements(i).pay_element_name,
	   null,
	   null,
	   position_rec.position_line_id,
	   position_rec.position_id,
	   position_rec.position_name,
	   position_rec.position_segments,
	   l_job_name,
	   l_employee_id,
	   l_employee_number,
	   l_employee_name,
	   'P',  -- For Percent rows
	   null,
	   g_wlbi_amounts(1).amount,
	   g_wlbi_amounts(2).amount,
	   g_wlbi_amounts(3).amount,
	   g_wlbi_amounts(4).amount,
	   g_wlbi_amounts(5).amount,
	   g_wlbi_amounts(6).amount,
	   g_wlbi_amounts(7).amount,
	   g_wlbi_amounts(8).amount,
	   g_wlbi_amounts(9).amount,
	   g_wlbi_amounts(10).amount,
	   g_wlbi_amounts(11).amount,
	   g_wlbi_amounts(12).amount,
	   g_wlbi_amounts(13).amount,
	   g_wlbi_amounts(14).amount,
	   g_wlbi_amounts(15).amount,
	   g_wlbi_amounts(16).amount,
	   g_wlbi_amounts(17).amount,
	   g_wlbi_amounts(18).amount,
	   g_wlbi_amounts(19).amount,
	   g_wlbi_amounts(20).amount,
	   g_wlbi_amounts(21).amount,
	   g_wlbi_amounts(22).amount,
	   g_wlbi_amounts(23).amount,
	   g_wlbi_amounts(24).amount,
	   g_wlbi_amounts(25).amount,
	   g_wlbi_amounts(26).amount,
	   g_wlbi_amounts(27).amount,
	   g_wlbi_amounts(28).amount,
	   g_wlbi_amounts(29).amount,
	   g_wlbi_amounts(30).amount,
	   g_wlbi_amounts(31).amount,
	   g_wlbi_amounts(32).amount,
	   g_wlbi_amounts(33).amount,
	   g_wlbi_amounts(34).amount,
	   g_wlbi_amounts(35).amount,
	   g_wlbi_amounts(36).amount,
	   g_wlbi_amounts(37).amount,
	   g_wlbi_amounts(38).amount,
	   g_wlbi_amounts(39).amount,
	   g_wlbi_amounts(40).amount,
	   g_wlbi_amounts(41).amount,
	   g_wlbi_amounts(42).amount,
	   g_wlbi_amounts(43).amount,
	   g_wlbi_amounts(44).amount,
	   g_wlbi_amounts(45).amount,
	   g_wlbi_amounts(46).amount,
	   g_wlbi_amounts(47).amount,
	   g_wlbi_amounts(48).amount,
	   g_wlbi_amounts(49).amount,
	   g_wlbi_amounts(50).amount,
	   g_wlbi_amounts(51).amount,
	   g_wlbi_amounts(52).amount,
	   g_wlbi_amounts(53).amount,
	   g_wlbi_amounts(54).amount,
	   g_wlbi_amounts(55).amount,
	   g_wlbi_amounts(56).amount,
	   g_wlbi_amounts(57).amount,
	   g_wlbi_amounts(58).amount,
	   g_wlbi_amounts(59).amount,
	   g_wlbi_amounts(60).amount,
	   g_wlbi_amounts(61).amount,
	   g_wlbi_amounts(62).amount,
	   g_wlbi_amounts(63).amount,
	   g_wlbi_amounts(64).amount,
	   g_wlbi_amounts(65).amount,
	   g_wlbi_amounts(66).amount,
	   g_wlbi_amounts(67).amount,
	   g_wlbi_amounts(68).amount,
	   g_wlbi_amounts(69).amount,
	   g_wlbi_amounts(70).amount,
	   g_wlbi_amounts(71).amount,
	   g_wlbi_amounts(72).amount,
	   g_wlbi_amounts(73).amount,
	   g_wlbi_amounts(74).amount,
	   g_wlbi_amounts(75).amount,
	   g_wlbi_amounts(76).amount,
	   g_wlbi_amounts(77).amount,
	   g_wlbi_amounts(78).amount,
	   g_wlbi_amounts(79).amount,
	   g_wlbi_amounts(80).amount,
	   g_wlbi_amounts(81).amount,
	   g_wlbi_amounts(82).amount,
	   g_wlbi_amounts(83).amount,
	   g_wlbi_amounts(84).amount,
	   g_wlbi_amounts(85).amount,
	   g_wlbi_amounts(86).amount,
	   g_wlbi_amounts(87).amount,
	   g_wlbi_amounts(88).amount,
	   g_wlbi_amounts(89).amount,
	   g_wlbi_amounts(90).amount,
	   g_wlbi_amounts(91).amount,
	   g_wlbi_amounts(92).amount,
	   g_wlbi_amounts(93).amount,
	   g_wlbi_amounts(94).amount,
	   g_wlbi_amounts(95).amount,
	   g_wlbi_amounts(96).amount,
	   g_wlbi_amounts(97).amount,
	   g_wlbi_amounts(98).amount,
	   g_wlbi_amounts(99).amount,
	   g_wlbi_amounts(100).amount,
	   g_wlbi_amounts(101).amount,
	   g_wlbi_amounts(102).amount,
	   g_wlbi_amounts(103).amount,
	   g_wlbi_amounts(104).amount,
	   g_wlbi_amounts(105).amount,
	   g_wlbi_amounts(106).amount,
	   g_wlbi_amounts(107).amount,
	   g_wlbi_amounts(108).amount,
	   g_wlbi_amounts(109).amount,
	   g_wlbi_amounts(110).amount,
	   g_wlbi_amounts(111).amount,
	   g_wlbi_amounts(112).amount,
	   g_wlbi_amounts(113).amount,
	   g_wlbi_amounts(114).amount,
	   g_wlbi_amounts(115).amount,
	   g_wlbi_amounts(116).amount,
	   g_wlbi_amounts(117).amount,
	   g_wlbi_amounts(118).amount,
	   g_wlbi_amounts(119).amount,
	   g_wlbi_amounts(120).amount,
	   g_wlbi_amounts(121).amount,
	   g_wlbi_amounts(122).amount,
	   g_wlbi_amounts(123).amount,
	   g_wlbi_amounts(124).amount,
	   g_wlbi_amounts(125).amount,
	   g_wlbi_amounts(126).amount,
	   g_wlbi_amounts(127).amount,
	   g_wlbi_amounts(128).amount,
	   g_wlbi_amounts(129).amount,
	   g_wlbi_amounts(130).amount,
	   g_wlbi_amounts(131).amount,
	   g_wlbi_amounts(132).amount,
	   g_wlbi_amounts(133).amount,
	   g_wlbi_amounts(134).amount,
	   g_wlbi_amounts(135).amount,
	   g_wlbi_amounts(136).amount,
	   g_wlbi_amounts(137).amount,
	   g_wlbi_amounts(138).amount,
	   g_wlbi_amounts(139).amount,
	   g_wlbi_amounts(140).amount,
	   g_wlbi_amounts(141).amount,
	   g_wlbi_amounts(142).amount,
	   g_wlbi_amounts(143).amount,
	   g_wlbi_amounts(144).amount,
	   g_wlbi_amounts(145).amount,
	   g_wlbi_amounts(146).amount,
	   g_wlbi_amounts(147).amount,
	   g_wlbi_amounts(148).amount,
	   g_wlbi_amounts(149).amount,
	   g_wlbi_amounts(150).amount,
	   g_wlbi_amounts(151).amount,
	   g_wlbi_amounts(152).amount,
	   g_wlbi_amounts(153).amount,
	   g_wlbi_amounts(154).amount,
	   g_wlbi_amounts(155).amount,
	   g_wlbi_amounts(156).amount,
	   g_wlbi_amounts(157).amount,
	   g_wlbi_amounts(158).amount,
	   g_wlbi_amounts(159).amount,
	   g_wlbi_amounts(160).amount,
	   g_wlbi_amounts(161).amount,
	   g_wlbi_amounts(162).amount,
	   g_wlbi_amounts(163).amount,
	   g_wlbi_amounts(164).amount,
	   g_wlbi_amounts(165).amount,
	   g_wlbi_amounts(166).amount,
	   g_wlbi_amounts(167).amount,
	   g_wlbi_amounts(168).amount,
	   SYSDATE,
	   g_user_id,
	   g_user_id,
	   g_user_id,
	   SYSDATE
	   );
	END LOOP;  --For each PS element
      END IF;  -- IF PS Elements exists



    END LOOP;  -- position_rec
  END Populate_POS_WS_Lines;

  FUNCTION Get_Next_Export_Seq RETURN NUMBER IS
    l_export_id NUMBER;
  BEGIN
    select psb_export_s.nextval into l_export_id from dual;
    RETURN l_export_id;
  END;

  -- Get the current year end date and first proposed year start date
  -- from the calendar.
  PROCEDURE Get_Calendar_Dates
	    ( p_budget_calendar_id  IN NUMBER,
	      p_calendar_start_date OUT  NOCOPY DATE,
	      p_calendar_end_date   OUT  NOCOPY DATE,
	      p_cy_end_date         OUT  NOCOPY DATE,
	      p_pp_start_date       OUT  NOCOPY DATE
	    )
  IS
    cursor c1 is
    select MIN(start_date) start_date , MAX(end_date) end_date
      from psb_budget_periods bp
      where bp.budget_calendar_id = p_budget_calendar_id
      and budget_period_type = 'Y';

    cursor c2 is
    select bp.budget_period_id, yt.year_category_type, bp.start_date, bp.end_date
      from psb_budget_year_types yt,
	   psb_budget_periods bp
      where
	yt.budget_year_type_id = bp.budget_year_type_id
	and bp.budget_period_type = 'Y'
	and bp.budget_calendar_id = p_budget_calendar_id
     order by bp.start_date;

  BEGIN

    FOR c1_rec in c1 LOOP
      p_calendar_start_date := C1_rec.Start_Date;
      p_calendar_end_date   := C1_rec.End_Date;
    END LOOP;

    FOR c2_rec in c2 LOOP
      IF c2_rec.year_category_type = 'CY' THEN
	 p_cy_end_date := c2_rec.End_Date;
      END IF;

      IF c2_rec.year_category_type = 'PP' THEN
	 p_pp_start_date := c2_rec.start_date;
	 EXIT;  -- No need to continue, this is sorted by date
      END IF;
    END LOOP;

  END Get_Calendar_Dates;

  -- Call this routine on Error
  PROCEDURE Log_Messages (p_source_process IN VARCHAR2)
  IS
    l_return_status VARCHAR2(1);
    l_msg_buf       VARCHAR2(2000);
    l_msg_count     NUMBER;
    l_reqid         NUMBER;
    l_rep_req_id    NUMBER;
    l_userid        NUMBER;
    retcode         NUMBER;
    l_desc          VARCHAR2(80);
    l_program_name  VARCHAR2(80);

  BEGIN

    IF p_source_process = 'MOVE_TO_PSB' THEN
      -- g_msg_export_id set while calling PSB_EXCEL2_PVT.Move to PSB
      FND_MESSAGE.SET_NAME('PSB', 'PSB_MOVE_TO_PSB_ERR_MSG_HDR');
    ELSIF p_source_process = 'MOVE_TO_INTERFACE' THEN
      g_msg_export_id := g_export_id;
      FND_MESSAGE.SET_NAME('PSB', 'PSB_MOVE_TO_INTF_ERR_MSG_HDR');
    ELSIF p_source_process = 'DELETE_WORKSHEET' THEN
      FND_MESSAGE.SET_NAME('PSB', 'PSB_DEL_WORKSHT_ERR_MSG_HDR');
    END IF;

    l_desc   := FND_MESSAGE.GET;
    l_reqid  := FND_GLOBAL.CONC_REQUEST_ID;
    l_userid := FND_GLOBAL.USER_ID;

    delete from PSB_ERROR_MESSAGES
    where source_process = p_source_process
    and process_id = g_msg_export_id;

    FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
				p_data  => l_msg_buf );



    PSB_MESSAGE_S.Insert_Error ( p_source_process => p_source_process,
				 p_process_id     => g_msg_export_id,
				 p_msg_count      => l_msg_count,
				 p_msg_data       => l_msg_buf) ;


    -- Also Submit Concurrent Request to Print Error Report
    l_rep_req_id := Fnd_Request.Submit_Request
		       (application   => 'PSB'                          ,
			program       => 'PSBRPERR'                     ,
			description   =>  l_desc                        ,
			start_time    =>  NULL                          ,
			sub_request   =>  FALSE                         ,
			argument1     =>  l_reqid
		       );
    --
    if l_rep_req_id = 0 then
    --
      fnd_message.set_name('PSB', 'PSB_FAIL_TO_SUBMIT_REQUEST');
    --
    end if;

    FND_MSG_PUB.initialize;


  END Log_Messages;
/*---------------------------------------------------------------------------*/

  PROCEDURE Move_To_PSB
  (
  p_api_version               IN       NUMBER   ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_export_id                 IN   NUMBER,
  p_import_worksheet_type     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_amt_tolerance_value_type  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_amt_tolerance_value       IN   NUMBER   := FND_API.G_MISS_NUM,
  p_pct_tolerance_value_type  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_pct_tolerance_value       IN   NUMBER   := FND_API.G_MISS_NUM
  )
  IS
  BEGIN
    g_msg_export_id := p_export_id;

    PSB_EXCEL2_PVT.Move_To_PSB
    (
    p_api_version                 => p_api_version,
    p_init_msg_list               => p_init_msg_list,
    p_commit                      => p_commit,
    p_validation_level            => p_validation_level,
    p_return_status               => p_return_status,
    p_msg_count                   => p_msg_count,
    p_msg_data                    => p_msg_data,
    --
    p_export_id                   => p_export_id,
    p_import_worksheet_type       => p_import_worksheet_type,
    p_amt_tolerance_value_type    => p_amt_tolerance_value_type,
    p_amt_tolerance_value         => p_amt_tolerance_value,
    p_pct_tolerance_value_type    => p_pct_tolerance_value_type,
    p_pct_tolerance_value         => p_pct_tolerance_value
    );

  END Move_To_PSB;


/*===========================================================================+
 |                      PROCEDURE Move_To_Inter_CP                           |
 +==========================================================================*/
--
-- The Concurrent Program execution file for the program 'Transfer Worksheet
-- from PSB to Interface'.
--
PROCEDURE Move_To_Inter_CP
(
  errbuf                      OUT  NOCOPY  VARCHAR2                        ,
  retcode                     OUT  NOCOPY  VARCHAR2                        ,
  --
  p_export_name               IN   VARCHAR2                        ,
  p_worksheet_id              IN   NUMBER                          ,
  p_stage_id                  IN   NUMBER  := FND_API.G_MISS_NUM   ,
  p_export_worksheet_type     IN   VARCHAR2
)
IS
  --
  l_api_name                CONSTANT VARCHAR2(30) := 'Move_To_Inter_CP' ;
  l_api_version             CONSTANT NUMBER       :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;
  --
BEGIN
  --
  SAVEPOINT Move_To_Inter_CP_Pvt ;
  --
  PSB_Excel_Pvt.Move_To_Interface
  (
     p_api_version               =>   1.0                          ,
     p_init_msg_list             =>   FND_API.G_TRUE               ,
     p_commit                    =>   FND_API.G_FALSE              ,
     p_validation_level          =>   FND_API.G_VALID_LEVEL_FULL   ,
     p_return_status             =>   l_return_status              ,
     p_msg_count                 =>   l_msg_count                  ,
     p_msg_data                  =>   l_msg_data                   ,
     --
     p_export_name               =>   p_export_name                ,
     p_worksheet_id              =>   p_worksheet_id               ,
     p_stage_id                  =>   p_stage_id                   ,
     p_export_worksheet_type     =>   p_export_worksheet_type
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;
  --
    /* Start Bug No. 2322856 */
--  PSB_MESSAGE_S.Print_Success ;
    /* End Bug No. 2322856 */
  retcode := 0 ;
  --
  COMMIT WORK;
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Move_To_Inter_CP_Pvt ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header => FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
    Log_Messages(p_source_process => 'MOVE_TO_INTERFACE');
    COMMIT WORK ;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Move_To_Inter_CP_Pvt ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header => FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
    Log_Messages(p_source_process => 'MOVE_TO_INTERFACE');
    COMMIT WORK ;
    --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Move_To_Inter_CP_Pvt ;
    --
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
    END IF ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header => FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
    Log_Messages(p_source_process => 'MOVE_TO_INTERFACE');
    COMMIT WORK ;
    --
END Move_To_Inter_CP ;
/*---------------------------------------------------------------------------*/



/*===========================================================================+
 |                        PROCEDURE Move_To_PSB_CP                           |
 +==========================================================================*/
--
-- The Concurrent Program execution file for the program 'Transfer Worksheet
-- from Interface to PSB'.
--
PROCEDURE Move_To_PSB_CP
(
  errbuf                      OUT  NOCOPY  VARCHAR2 ,
  retcode                     OUT  NOCOPY  VARCHAR2 ,
  --
  p_export_id                 IN   NUMBER   ,
  p_import_worksheet_type     IN   VARCHAR2 ,
  p_amt_tolerance_value_type  IN   VARCHAR2 ,
  p_amt_tolerance_value       IN   NUMBER   ,
  p_pct_tolerance_value_type  IN   VARCHAR2 ,
  p_pct_tolerance_value       IN   NUMBER
)
IS
  --
  l_api_name                CONSTANT VARCHAR2(30) := 'Move_To_PSB_CP' ;
  l_api_version             CONSTANT NUMBER       :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;
  --
BEGIN
  --
  SAVEPOINT Move_To_PSB_CP_Pvt ;
  --
  PSB_Excel_Pvt.Move_TO_PSB
  (
     p_api_version               =>   1.0                         ,
     p_init_msg_list             =>   FND_API.G_TRUE              ,
     p_commit                    =>   FND_API.G_FALSE             ,
     p_validation_level          =>   FND_API.G_VALID_LEVEL_FULL  ,
     p_return_status             =>   l_return_status             ,
     p_msg_count                 =>   l_msg_count                 ,
     p_msg_data                  =>   l_msg_data                  ,
     --
     p_export_id                 =>  p_export_id                  ,
     p_import_worksheet_type     =>  p_import_worksheet_type      ,
     p_amt_tolerance_value_type  =>  p_amt_tolerance_value_type   ,
     p_amt_tolerance_value       =>  p_amt_tolerance_value        ,
     p_pct_tolerance_value_type  =>  p_pct_tolerance_value_type   ,
     p_pct_tolerance_value       =>  p_pct_tolerance_value
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    l_error_api_name := 'PSB_Excel_Pvt.Move_TO_PSB' ;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;
  --
  retcode := 0 ;
  PSB_MESSAGE_S.Get_Success_Message( p_msg_string => l_msg_data ) ;
  errbuf  := l_msg_data ;
  --
  COMMIT WORK;
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Move_To_PSB_CP_Pvt ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header => FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
    Log_Messages(p_source_process => 'MOVE_TO_PSB');
    COMMIT WORK ;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Move_To_PSB_CP_Pvt ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header => FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
    Log_Messages(p_source_process => 'MOVE_TO_PSB');
    COMMIT WORK ;
    --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Move_To_PSB_CP_Pvt ;
    --
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
    END IF ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header => FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
    Log_Messages(p_source_process => 'MOVE_TO_PSB');
    COMMIT WORK ;
    --
END Move_To_PSB_CP ;
/*---------------------------------------------------------------------------*/




/*===========================================================================+
 |                      PROCEDURE Delete_Worksheet                           |
 +==========================================================================*/
--
-- The Program Deletes the Worksheet from the Interface
--
PROCEDURE Del_Worksheet
(
  p_api_version               IN   NUMBER   ,
  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN   VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY  VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY  NUMBER   ,
  p_msg_data                  OUT  NOCOPY  VARCHAR2 ,
  --
  p_export_id                 IN   NUMBER
)
IS

  l_api_name                CONSTANT VARCHAR2(30) := 'Del_Worksheet' ;
  l_api_version             CONSTANT NUMBER       :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  BEGIN
    --dbms_output.put_line('Exporting ...');
    --
    SAVEPOINT Del_Worksheet_Pvt ;
    --
    IF NOT FND_API.Compatible_API_Call ( l_api_version,
					 p_api_version,
					 l_api_name,
					 G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --

    IF FND_API.To_Boolean ( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize ;
    END IF;
    --
    p_return_status := FND_API.G_RET_STS_SUCCESS ;

    DELETE FROM psb_ws_line_balances_i
     WHERE export_id = p_export_id;

    DELETE FROM psb_ws_columns_i
     WHERE export_id = p_export_id;

    DELETE FROM psb_worksheets_i
     WHERE export_id = p_export_id;

    IF FND_API.to_Boolean (p_commit) then
      commit work;
    END IF;


  EXCEPTION

  --
  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Del_Worksheet_Pvt;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Del_Worksheet_Pvt;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    ROLLBACK TO Del_Worksheet_Pvt;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --

END Del_Worksheet;

/* ----------------------------------------------------------------------- */

/*===========================================================================+
 |                        PROCEDURE Del_Worksheet_CP                      |
 +==========================================================================*/
--
-- The Concurrent Program execution file for the program 'Delete Worksheet
-- from Interface '.
--
PROCEDURE Del_Worksheet_CP
(
  errbuf                      OUT  NOCOPY  VARCHAR2 ,
  retcode                     OUT  NOCOPY  VARCHAR2 ,
  --
  p_export_id                 IN   NUMBER
)
IS
  --
  l_api_name                CONSTANT VARCHAR2(30) := 'Del_Worksheet_CP' ;
  l_api_version             CONSTANT NUMBER       :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;
  --
BEGIN
  --
  SAVEPOINT Del_Worksheet_CP_Pvt ;
  --
  PSB_Excel_Pvt.Del_Worksheet
  (
     p_api_version               =>   1.0                         ,
     p_init_msg_list             =>   FND_API.G_TRUE              ,
     p_commit                    =>   FND_API.G_FALSE             ,
     p_validation_level          =>   FND_API.G_VALID_LEVEL_FULL  ,
     p_return_status             =>   l_return_status             ,
     p_msg_count                 =>   l_msg_count                 ,
     p_msg_data                  =>   l_msg_data                  ,
     --
     p_export_id                 =>  p_export_id
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    l_error_api_name := 'PSB_Excel_Pvt.Del_Worksheet' ;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;
  --
  retcode := 0 ;
  PSB_MESSAGE_S.Get_Success_Message( p_msg_string => l_msg_data ) ;
  errbuf  := l_msg_data ;
  --
  COMMIT WORK;
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Del_Worksheet_CP_Pvt ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header => FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
    Log_Messages(p_source_process => 'DELETE_WORKSHEET');
    COMMIT WORK ;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Del_Worksheet_CP_Pvt ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header => FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
    Log_Messages(p_source_process => 'DELETE_WORKSHEET');
    COMMIT WORK ;
    --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Del_Worksheet_CP_Pvt ;
    --
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
    END IF ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header => FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
    Log_Messages(p_source_process => 'DELETE_WORKSHEET');
    COMMIT WORK ;
    --
END Del_Worksheet_CP ;


END PSB_EXCEL_PVT;

/
