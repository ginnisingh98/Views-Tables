--------------------------------------------------------
--  DDL for Package Body PSB_EXCEL2_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_EXCEL2_PVT" AS
/* $Header: PSBVXL2B.pls 120.12.12010000.4 2009/04/27 15:17:11 rkotha ship $ */

  G_PKG_NAME CONSTANT   VARCHAR2(30):= 'PSB_EXCEL2_PVT';

  g_debug_flag          VARCHAR2(1) := 'N';

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

  TYPE g_posfte_rec_type IS RECORD
     ( worksheet_id          NUMBER,
       start_date            DATE,
       end_date              DATE,
       fte                   NUMBER );

  TYPE g_posfte_tbl_type IS TABLE OF g_posfte_rec_type
      INDEX BY BINARY_INTEGER;

  g_posfte_assignments       g_posfte_tbl_type;
  g_num_posfte_assignments   NUMBER;

  TYPE g_poswkh_rec_type IS RECORD
     ( worksheet_id          NUMBER,
       start_date            DATE,
       end_date              DATE,
       default_weekly_hours  NUMBER );

  TYPE g_poswkh_tbl_type IS TABLE OF g_poswkh_rec_type
      INDEX BY BINARY_INTEGER;

 /* Added for Bug 3558916 */

  -- Number array.
  TYPE Number_tbl_type IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER ;

  -- Character array.
  TYPE Character_tbl_type IS TABLE OF VARCHAR2(150)
       INDEX BY BINARY_INTEGER ;

  -- Character array.
  TYPE Big_character_tbl_type IS TABLE OF VARCHAR2(1000)
       INDEX BY BINARY_INTEGER ;

  g_poswkh_assignments      g_poswkh_tbl_type;
  g_num_poswkh_assignments  NUMBER;

  g_fte_profile              PSB_WS_ACCT1.g_prdamt_tbl_type;
  g_num_fte                  NUMBER;


-- Storage structures from PSBVWP2B.pls end

g_worksheets_tbl PSB_WS_Ops_Pvt.Worksheet_Tbl_Type;

g_ws_line_year_rec  psb_ws_matrix.ws_line_year_rec_type;

g_max_num_cols        CONSTANT NUMBER := 12;
g_max_num_pos_ws_cols CONSTANT NUMBER := 168;

g_export_id       NUMBER;
g_worksheet_id    NUMBER;
g_user_id         NUMBER;
g_stage_id        NUMBER;

g_global_worksheet_id NUMBER;
g_assignment_worksheet_id NUMBER;
g_global_worksheet_flag VARCHAR2(1);
g_local_copy_flag       VARCHAR2(1);

--
g_budget_group_id NUMBER;
g_set_of_books_id NUMBER;
g_chart_of_accounts_id NUMBER;
g_currency_code VARCHAR2(15);
g_stage_set_id      NUMBER;
g_current_stage_seq NUMBER;
g_business_group_id NUMBER;
g_data_extract_id   NUMBER;


-- Calendar
g_budget_calendar_id NUMBER;
g_calendar_start_date DATE;
g_calendar_end_date DATE;
g_cy_end_date DATE;
g_pp_start_date DATE;
g_base_spid  NUMBER;
g_translated_base_sp_name VARCHAR2(30);
g_translated_sp_desc VARCHAR2(200);


g_account_export_status VARCHAR2(10);
g_position_export_status VARCHAR2(10);
g_currency_flag VARCHAR2(1);
g_budget_by_position VARCHAR2(1);


g_coa_id          NUMBER;

g_pos_ws_col_no      NUMBER;
g_total_budget_years NUMBER;


g_ws_cols              PSB_EXCEL_PVT.g_ws_col_tbl_type;
g_pos_ws_cols          PSB_EXCEL_PVT.g_pos_ws_col_tbl_type;
g_year_amts            PSB_EXCEL_PVT.g_year_amount_tbl_type;
g_year_num_periods     PSB_EXCEL_PVT.g_year_num_periods_tbl_type;
g_acl_ids              PSB_EXCEL_PVT.g_acl_id_tbl_type;
g_wlbi_amounts         PSB_EXCEL_PVT.g_period_amount_tbl_type; --1.. 168
g_wal_period_amounts   PSB_EXCEL_PVT.g_period_amount_tbl_type; --1..12(upto 60)
g_fte_period_amounts   PSB_EXCEL_PVT.g_period_amount_tbl_type; --1..12(upto 60)

TYPE g_estimate_year_type IS RECORD
   (
     total_column        NUMBER,
     percent_column      NUMBER,
     period_start_column NUMBER,
     period_end_column   NUMBER
   );
TYPE g_estimate_year_tbl_type IS TABLE of g_estimate_year_type
      INDEX BY BINARY_INTEGER;

g_estimate_years  g_estimate_year_tbl_type;


TYPE g_assignment_type IS RECORD
   (
     period              NUMBER,
     new_amount          NUMBER
   );

g_assignment_count NUMBER;
TYPE g_assignment_tbl_type IS TABLE of g_assignment_type
      INDEX BY BINARY_INTEGER;

g_assignment  g_assignment_tbl_type;
g_assignment_index NUMBER;
g_assignment_amount NUMBER;

g_amt_tolerance_value_type  VARCHAR2(1);
g_amt_tolerance_value       NUMBER;
g_pct_tolerance_value_type  VARCHAR2(1);
g_pct_tolerance_value       NUMBER;

/* ----------------------------------------------------------------------- */
/*                                                                         */
/*                      Private Function and Procedure Declaration         */
/*                                                                         */
/* ----------------------------------------------------------------------- */

  PROCEDURE Clear_WS_Cols;
  PROCEDURE Clear_POS_WS_Cols;

  PROCEDURE Get_WS_Cols;
  PROCEDURE Get_POS_WS_Cols;

  PROCEDURE Get_WS_Line_Bal;
  PROCEDURE Get_POS_WS_Line_Bal;


  PROCEDURE Get_SPID
  (
    p_worksheet_id IN NUMBER,
    p_spname      IN VARCHAR2,
    p_spid        OUT  NOCOPY NUMBER
  );
  PROCEDURE  Set_SPID_ALL_WLBI;

  PROCEDURE  Get_WAL_Element_Cost
  ( p_position_line_id IN NUMBER,
    p_element_set_id IN NUMBER,
    p_budget_year_id IN NUMBER,
    p_pay_element_id IN NUMBER, --bug:6019074
    p_wal_element_cost OUT  NOCOPY NUMBER
  );

  PROCEDURE  Get_WLBI_Element_Cost
  ( p_budget_year_id IN NUMBER,
    p_wlbi_element_cost OUT  NOCOPY NUMBER
  );

  PROCEDURE Get_WLBI_SP_Element_Cost
  ( p_budget_year_id     IN NUMBER,
    p_wlbi_sp_element_cost  OUT  NOCOPY NUMBER
  );

  PROCEDURE  Get_New_Assignments
  (
    p_budget_year_id IN NUMBER
  );

  PROCEDURE Get_Account_Line
  (
    p_worksheet_id    IN NUMBER,
    p_ccid            IN NUMBER,
    p_spid            IN NUMBER,
    p_budget_year_id  IN NUMBER,
    p_stage_seq       IN NUMBER,
    p_account_line_id OUT  NOCOPY NUMBER,
    p_found_acct_line OUT  NOCOPY BOOLEAN
  );

  PROCEDURE Delete_Export_Header;
  PROCEDURE Delete_Export_Details(p_export_worksheet_type IN VARCHAR2);
  PROCEDURE Cache_Position_Data
  (
    p_return_status    OUT  NOCOPY VARCHAR2,
    p_position_line_id IN  NUMBER,
    p_position_id      IN  NUMBER,
    p_start_date       IN  DATE,
    p_end_date         IN  DATE
  );

  PROCEDURE Update_Assignments
  ( p_return_status    OUT  NOCOPY VARCHAR2,
    p_position_line_id IN NUMBER
  );

  PROCEDURE Change_Pos_Year_Assignments
  ( p_return_status              OUT  NOCOPY VARCHAR2,
    p_worksheet_id                IN NUMBER,
    p_budget_calendar_id          IN NUMBER,
    p_data_extract_id             IN NUMBER,
    p_business_group_id           IN NUMBER,
    p_position_line_id            IN NUMBER,
    p_position_id                 IN NUMBER,
    p_position_name               IN VARCHAR2,
    p_pay_element_id              IN NUMBER,
    p_amt_tolerance_value_type    IN VARCHAR2,
    p_amt_tolerance_value         IN NUMBER,
    p_pct_tolerance_value_type    IN VARCHAR2,
    p_pct_tolerance_value         IN NUMBER,
    p_budget_year_id              IN NUMBER,
    p_assignments                 IN g_assignment_tbl_type
  );

  PROCEDURE Change_Element_Cost
  ( p_return_status      OUT  NOCOPY VARCHAR2,
    p_position_line_id   IN NUMBER,
    p_pay_element_id     IN NUMBER,
    p_element_set_id     IN NUMBER
  );

  PROCEDURE  Get_FTE
  ( p_position_line_id IN NUMBER,
    p_budget_year_id IN NUMBER
  );

  /*bug:6019074:added parameters p_position_line_id, p_service_package_id,
    p_code_combination_id and p_pay_element_set_id*/
  PROCEDURE Update_Distributions
  ( p_return_status OUT     NOCOPY VARCHAR2,
    p_position_line_id      NUMBER,
    p_service_package_id    NUMBER,
    p_code_combination_id   NUMBER,
    p_pay_element_set_id    NUMBER
  );

  PROCEDURE Get_Element_Set_ID
  (
    p_pay_element_id        IN  NUMBER,
    p_position_line_id      IN  NUMBER,
    p_element_set_id        OUT  NOCOPY NUMBER,
    p_found_element_set     OUT  NOCOPY BOOLEAN
  );


  PROCEDURE Get_Pos_Account_Line
  (
    p_worksheet_id          IN NUMBER,
    p_ccid                  IN NUMBER,
    p_spid                  IN NUMBER,
    p_position_line_id      IN NUMBER,
    p_budget_year_id        IN NUMBER,
    p_element_set_id        IN NUMBER,
    p_account_line_id       OUT  NOCOPY NUMBER,
    p_found_pos_acct_line   OUT  NOCOPY BOOLEAN
  );

  PROCEDURE Get_Element_Line_ID
  ( p_position_line_id            IN NUMBER,
    p_budget_year_id              IN NUMBER,
    p_pay_element_id              IN NUMBER,
    p_service_package_id          IN NUMBER,
    p_found_element_line         OUT  NOCOPY BOOLEAN,
    p_element_line_id             OUT  NOCOPY NUMBER
  );


/* --------------------- Debug Procedure--------------------- */

  PROCEDURE debug
  ( p_message     IN       VARCHAR2) IS

  BEGIN

    if g_debug_flag = 'Y' then
      null;
--    dbms_output.put_line(p_message);
    end if;

  END debug;

/* --------------------- Import Worksheet Procedure--------------------- */


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

  l_validation_status VARCHAR2(1);
   --
  l_api_name                CONSTANT VARCHAR2(30) := 'Move_To_PSB' ;
  l_api_version             CONSTANT NUMBER       :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --

  l_index             BINARY_INTEGER;
  l_session_id NUMBER;
  l_import_positions BOOLEAN;
  l_import_accounts  BOOLEAN;
  l_import_ws_type   VARCHAR2(1);
  l_selected_template_id NUMBER;
  CURSOR exp_ws_cur IS
	 SELECT worksheet_id, account_export_status, position_export_status,
	 currency_flag, stage_id, budget_by_position, selected_stage_id,
	 selected_template_id
	 FROM psb_worksheets_i
	 WHERE export_id = p_export_id;
  Recinfo   exp_ws_cur%ROWTYPE;

  BEGIN
    --
    SAVEPOINT Move_To_PSB_Pvt ;
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
    --
    l_validation_status := FND_API.G_RET_STS_SUCCESS;

    g_export_id := p_export_id;
    g_amt_tolerance_value_type   := p_amt_tolerance_value_type;
    g_amt_tolerance_value        := p_amt_tolerance_value;
    g_pct_tolerance_value_type   := p_pct_tolerance_value_type;
    g_pct_tolerance_value        := p_pct_tolerance_value;

    IF p_import_worksheet_type = FND_API.G_MISS_CHAR THEN
      l_import_ws_type := 'B';
    ELSE
      l_import_ws_type := p_import_worksheet_type;
    END IF;

    -- Check for Worksheet ID
    OPEN exp_ws_cur;
    FETCH exp_ws_cur INTO Recinfo;
    IF exp_ws_cur%FOUND THEN


      IF ( nvl(Recinfo.selected_stage_id,0) > 0 ) THEN
	FND_MESSAGE.SET_NAME('PSB', 'PSB_IMPORT_NOT_ALLOWED');
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR ;
      END IF;

      l_selected_template_id   := Recinfo.selected_template_id;
      g_position_export_status := Recinfo.position_export_status;
      g_account_export_status := Recinfo.account_export_status;
      g_worksheet_id := Recinfo.worksheet_id;
      g_currency_flag := Recinfo.currency_flag;
      g_budget_by_position := Recinfo.budget_by_position;
      g_current_stage_seq  := Recinfo.stage_id;

    ELSE
      FND_MESSAGE.SET_NAME('PSB', 'PSB_INVALID_ARGUMENT');
      FND_MESSAGE.SET_TOKEN('ROUTINE', 'Import Worksheet Procedure' );
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    CLOSE exp_ws_cur;

    -- Check if the exported worksheet moved stage or is frozen
    FOR ws_rec IN
      (SELECT global_worksheet_id, global_worksheet_flag, local_copy_flag,
	 budget_group_id, extract_id , business_group_id,
	 budget_calendar_id, set_of_books_id, freeze_flag,
	 stage_set_id,current_stage_seq,
	 chart_of_accounts_id, currency_code
       FROM psb_ws_summary_v ws
       WHERE ws.worksheet_id = g_worksheet_id)

    LOOP

      IF g_current_stage_seq <> ws_rec.current_stage_seq
	 OR nvl(ws_rec.freeze_flag,'N') = 'Y' THEN
	FND_MESSAGE.SET_NAME('PSB', 'PSB_IMPORT_NOT_ALLOWED');
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR ;
      END IF;

      g_global_worksheet_flag := ws_rec.global_worksheet_flag;
      g_local_copy_flag       := ws_rec.local_copy_flag;

      IF ws_rec.global_worksheet_flag = 'N' THEN
	g_global_worksheet_id := ws_rec.global_worksheet_id;

      ELSE
	g_global_worksheet_id := g_worksheet_id;

      END IF;

      -- Set the assignment worksheet ID; used in Modify Assignments
      IF nvl(g_local_copy_flag,'N')  = 'Y' THEN
	g_assignment_worksheet_id := g_worksheet_id;
      ELSE
	g_assignment_worksheet_id := g_global_worksheet_id;
      END IF;


      g_budget_group_id         := ws_rec.budget_group_id;
      g_budget_calendar_id      := ws_rec.budget_calendar_id;
      g_set_of_books_id         := ws_rec.set_of_books_id;
      g_chart_of_accounts_id    := ws_rec.chart_of_accounts_id;
      g_stage_set_id            := ws_rec.stage_set_id;
      g_current_stage_seq       := ws_rec.current_stage_seq;
      g_business_group_id       := ws_rec.business_group_id;
      g_data_extract_id         := ws_rec.extract_id;
      g_currency_code           := ws_rec.currency_code;

      IF g_currency_flag = 'S' THEN
	g_currency_code := 'STAT';
      END IF;
    END LOOP;

    l_import_accounts := FALSE;
    l_import_positions := FALSE;
    IF l_import_ws_type IN  ('A','B') and
       nvl(g_account_export_status,'INSERT') = 'VALIDATE' THEN
      l_import_accounts := TRUE;
    END IF;

    -- Rewritten Code
    IF l_import_accounts and  ( nvl(l_selected_template_id,0) > 0 ) THEN
      FND_MESSAGE.SET_NAME('PSB', 'PSB_IMPORT_NOT_ALLOWED');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_import_ws_type IN  ('P','B') and
       nvl(g_position_export_status,'INSERT') = 'VALIDATE' and
      g_budget_by_position = 'Y' THEN
      l_import_positions := TRUE;
    END IF;

    IF ( not  l_import_accounts) AND
       ( not  l_import_positions) THEN
      FND_MESSAGE.SET_NAME('PSB', 'PSB_INVALID_ARGUMENT');
      FND_MESSAGE.SET_TOKEN('ROUTINE', 'Import Worksheet Procedure' );
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR ;
    END IF;

    --
    --comment the line below when done with testing
    --Not required as these values set by conc manager
    --FND_GLOBAL.INITIALIZE(l_session_id, 1011, 500003,101,1,999,1,101,1,1);

    -- Get Parent Worksheets
    IF g_global_worksheet_id <> g_worksheet_id THEN

      FOR i in 1..g_worksheets_tbl.COUNT LOOP
	g_worksheets_tbl(i) := NULL;
      END LOOP;

      PSB_WS_Ops_Pvt.Find_Parent_Worksheets
      (
      p_api_version                 => 1.0,
      p_init_msg_list               => FND_API.G_FALSE,
      p_commit                      => FND_API.G_FALSE,
      p_validation_level            => FND_API.G_VALID_LEVEL_FULL,
      p_return_status               => l_return_status,
      p_msg_count                   => l_msg_count,
      p_msg_data                    => l_msg_data,
      --
      p_worksheet_id                => g_worksheet_id,
      p_worksheet_tbl               => g_worksheets_tbl
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
       raise FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    PSB_WS_ACCT1.Cache_Budget_Calendar
    (p_return_status => l_return_status,
     p_budget_calendar_id => g_budget_calendar_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    -- Setup the Calendar Info in Globals
    PSB_EXCEL_PVT.Get_Calendar_Dates
	    ( p_budget_calendar_id  => g_budget_calendar_id,
	      p_calendar_start_date => g_calendar_start_date,
	      p_calendar_end_date   => g_calendar_end_date,
	      p_cy_end_date         => g_cy_end_date,
	      p_pp_start_date       => g_pp_start_date
	    );

    -- Create or Get Service Package IDs for Service Package name
    FND_MESSAGE.SET_NAME('PSB', 'PSB_IMPORT_SERVICE_PACKAGE');
    g_translated_sp_desc := FND_MESSAGE.GET;

    -- Get Base Service Package ID to improve performance
    FND_MESSAGE.SET_NAME('PSB', 'PSB_BASE_SERVICE_PACKAGE');
    g_translated_base_sp_name := FND_MESSAGE.GET;
    Get_SPID(p_worksheet_id => g_global_worksheet_id,
	     p_spname       => g_translated_base_sp_name,
	     p_spid         => g_base_spid
	    );

    IF l_import_accounts THEN
      debug('Import Accounts');
      Clear_WS_Cols;
      Get_WS_Cols;
      Get_WS_Line_Bal;
      Delete_Export_Details(p_export_worksheet_type => 'A');
    END IF;

    IF l_import_positions THEN
      debug('Import Positions');
      Set_SPID_ALL_WLBI; -- Set SP Ids for all WLBI Position Lines
      Clear_POS_WS_Cols;
      Get_POS_WS_Cols;

      Get_POS_WS_Line_Bal;
      Delete_Export_Details(p_export_worksheet_type => 'P');
    END IF;

    Delete_Export_Header;

    IF FND_API.to_Boolean (p_commit) then
      commit work;
    END IF;

  EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Move_To_PSB_Pvt;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Move_To_PSB_Pvt;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Move_To_PSB_Pvt;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END IF;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
    --
  END Move_To_PSB;

  PROCEDURE Set_SPID_ALL_WLBI IS
    cursor wlbi_cur is
    select service_package_name
    from psb_ws_line_balances_i
    where export_id = g_export_id
    and export_worksheet_type = 'P'
    and service_package_id is NULL
    for update of service_package_id;

    wlbi_rec wlbi_cur%rowtype;

    l_service_package_id NUMBER;
    l_service_package_name VARCHAR2(30);
    l_translated_sp_name  VARCHAR2(30);

  BEGIN

    open wlbi_cur;
    LOOP
      fetch wlbi_cur into wlbi_rec;
      EXIT WHEN wlbi_cur%NOTFOUND ;

      /* Bug 3428156 start */
      -- service package name should keep its original cases
      -- l_service_package_name := upper(wlbi_rec.service_package_name);
      l_service_package_name := wlbi_rec.service_package_name;
      /* Bug 3428156 end */

      IF l_service_package_name is null
	 or l_service_package_name = g_translated_base_sp_name THEN
	l_service_package_id := g_base_spid;
      ELSE
	Get_SPID(p_worksheet_id => g_global_worksheet_id,
		 p_spname       => l_service_package_name,
		 p_spid         => l_service_package_id
		);
      END IF;

      update psb_ws_line_balances_i
      set service_package_id = l_service_package_id
      where current of wlbi_cur;

    END LOOP;
    close wlbi_cur;
  END Set_SPID_ALL_WLBI;


  PROCEDURE Get_SPID(p_worksheet_id IN NUMBER,
		     p_spname      IN VARCHAR2,
		     p_spid        OUT  NOCOPY NUMBER
		    )
  IS

  l_userid NUMBER := FND_GLOBAL.USER_ID;
  l_loginid NUMBER := FND_GLOBAL.LOGIN_ID;

  CURSOR ws_sp_cur IS
    SELECT SERVICE_PACKAGE_ID
    FROM  PSB_SERVICE_PACKAGES
    WHERE GLOBAL_WORKSHEET_ID = p_worksheet_id
    AND SHORT_NAME = p_spname;

  Recinfo   ws_sp_cur%ROWTYPE;


  l_spid NUMBER;

  BEGIN

    OPEN ws_sp_cur;
    FETCH ws_sp_cur INTO Recinfo;
    IF ws_sp_cur%FOUND THEN
       p_spid :=  Recinfo.SERVICE_PACKAGE_ID;

    ELSE
      select psb_service_packages_s.nextval into l_spid from dual;
      INSERT INTO PSB_SERVICE_PACKAGES
      (
	SERVICE_PACKAGE_ID,
	GLOBAL_WORKSHEET_ID,
	BASE_SERVICE_PACKAGE,
	NAME,
	SHORT_NAME,
	DESCRIPTION,
	PRIORITY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATED_BY,
	CREATION_DATE
       ) VALUES
       ( l_spid,
	 p_worksheet_id,
	 'N',
	 p_spname,
	 substr(p_spname,1,15),
	 g_translated_sp_desc,
	 NULL,
	 SYSDATE,
	 l_userid,
	 l_loginid,
	 l_userid,
	 SYSDATE
	);
	p_spid  := l_spid;
    END IF;

    CLOSE ws_sp_cur;

  END Get_SPID;

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

  PROCEDURE Get_WS_Cols
  IS
    l_col_count NUMBER := 0;
    i NUMBER;
  BEGIN

    FOR ws_col_rec IN
      ( SELECT
		COLUMN_NUMBER,
		BUDGET_YEAR_ID,
		BUDGET_YEAR_NAME,
		BALANCE_TYPE,
		YEAR_CATEGORY_TYPE
	  FROM PSB_WS_COLUMNS_I
	  WHERE EXPORT_ID = g_export_id
	  AND EXPORT_WORKSHEET_TYPE = 'A'
	  ORDER BY COLUMN_NUMBER
      )
    LOOP
      i := ws_col_rec.COLUMN_NUMBER;
      g_ws_cols(i).budget_year_id := ws_col_rec.budget_year_id;
      g_ws_cols(i).budget_year_name:= ws_col_rec.budget_year_name;
      g_ws_cols(i).balance_type:= ws_col_rec.balance_type;
      g_ws_cols(i).year_category_type:= ws_col_rec.year_category_type;
      --debug(i);
      --debug(g_ws_cols(i).year_category_type);
      l_col_count := l_col_count + 1;

    END LOOP;
  END Get_WS_Cols;

  PROCEDURE  Get_WS_Line_Bal
  IS

    l_validation_status VARCHAR2(1) ;
    l_currency_flag VARCHAR2(1);

    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_export_status     VARCHAR2(10);


    l_col_count NUMBER;

    l_ccid NUMBER;
    l_old_spid NUMBER;
    l_spid NUMBER;
    l_spname VARCHAR2(30);

    l_concatenated_account VARCHAR2(2000);
    l_currency_code VARCHAR2(15);

    va_ccid NUMBER;
    va_budget_group_id NUMBER;
    l_budget_group_id  NUMBER;
    ca_account_line_id  NUMBER;
    l_account_line_id  NUMBER;

    l_period_amount       PSB_WS_ACCT1.g_prdamt_tbl_type;
    l_amount NUMBER;

    old_acct BOOLEAN;
    new_acct BOOLEAN;
    validated_acct BOOLEAN;
    found_acct_line BOOLEAN;

    l_code_combination_id_tbl	Number_tbl_type;
    l_concat_account_tbl	Big_character_tbl_type;
    l_account_type_tbl		Character_tbl_type;

    l_curr_code_tbl		Character_tbl_type;
    l_template_id_tbl		Number_tbl_type;
    l_service_package_id_tbl    Number_tbl_type;
    l_service_package_name_tbl	Character_tbl_type;
    l_amount1_tbl		Number_tbl_type;
    l_amount2_tbl		Number_tbl_type;
    l_amount3_tbl		Number_tbl_type;
    l_amount4_tbl		Number_tbl_type;
    l_amount5_tbl		Number_tbl_type;
    l_amount6_tbl		Number_tbl_type;
    l_amount7_tbl		Number_tbl_type;
    l_amount8_tbl		Number_tbl_type;
    l_amount9_tbl		Number_tbl_type;
    l_amount10_tbl		Number_tbl_type;
    l_amount11_tbl		Number_tbl_type;
    l_amount12_tbl		Number_tbl_type;
    -- bug 3558916
    l_service_pack_id		psb_service_packages.service_package_id%TYPE;

	/* start Bug 3558916 */
	CURSOR cur_wlbi
	       IS
         SELECT
                MAX(CODE_COMBINATION_ID) CODE_COMBINATION_ID,
                CONCATENATED_ACCOUNT,
                ACCOUNT_TYPE,
                CURRENCY_CODE,
                TEMPLATE_ID,
                MAX(DECODE(SERVICE_PACKAGE_ID,0,l_service_pack_id,
		 SERVICE_PACKAGE_ID)) SERVICE_PACKAGE_ID,
                DECODE(NVL(UPPER(TRIM(SERVICE_PACKAGE_NAME)),'BASE'),
		 'BASE', 'BASE',TRIM(SERVICE_PACKAGE_NAME))
                 SERVICE_PACKAGE_NAME,
                SUM(AMOUNT1) AMOUNT1,
                SUM(AMOUNT2) AMOUNT2,
                SUM(AMOUNT3) AMOUNT3,
                SUM(AMOUNT4) AMOUNT4,
                SUM(AMOUNT5) AMOUNT5,
                SUM(AMOUNT6) AMOUNT6,
                SUM(AMOUNT7) AMOUNT7,
                SUM(AMOUNT8) AMOUNT8,
                SUM(AMOUNT9) AMOUNT9,
                SUM(AMOUNT10) AMOUNT10,
                SUM(AMOUNT11) AMOUNT11,
                SUM(AMOUNT12) AMOUNT12
         FROM PSB_WS_LINE_BALANCES_I
         WHERE EXPORT_ID = g_export_id
         AND EXPORT_WORKSHEET_TYPE = 'A'
         AND NVL(POSITION_ACCOUNT_FLAG,'N') = 'N'
         GROUP BY CONCATENATED_ACCOUNT,
         ACCOUNT_TYPE,
	 CURRENCY_CODE, TEMPLATE_ID,
         DECODE(NVL(UPPER(TRIM(SERVICE_PACKAGE_NAME)),'BASE'),
	       'BASE', 'BASE', TRIM(SERVICE_PACKAGE_NAME))
         ORDER BY CODE_COMBINATION_ID;

	 /* End Bug 3558916 */

        l_budget_period_id NUMBER;
	l_end_date	   DATE;
	l_gl_cutoff_period DATE;
 	l_last_cy_period   BOOLEAN;

  BEGIN
     /* start Bug 3558916 */
     BEGIN
	SELECT service_package_id
	INTO   l_service_pack_id
	FROM   psb_service_packages
	WHERE  global_worksheet_id = g_global_worksheet_id
	AND    name = 'BASE'
	AND    rownum = 1;
    EXCEPTION
	WHEN no_data_found then
		l_service_pack_id := 0;
    END;


    FOR cy_budget_year_cur IN
	(SELECT bp.budget_period_id, bp.end_date
	 FROM   psb_budget_year_types yt,
	       	psb_budget_periods bp
 	 WHERE  yt.budget_year_type_id = bp.budget_year_type_id
	 AND    bp.budget_period_type = 'Y'
	 AND    yt.year_category_type = 'CY'
	 AND    bp. budget_calendar_id = g_budget_calendar_id)
    LOOP

		l_budget_period_id :=  cy_budget_year_cur.budget_period_id;
		l_end_date := cy_budget_year_cur.end_date;
    END LOOP;


    FOR ws_gl_cutoff_cur IN
 	(SELECT gl_cutoff_period
	 FROM   psb_worksheets
	 WHERE  worksheet_id = g_worksheet_id)
    LOOP

	l_gl_cutoff_period := ws_gl_cutoff_cur.gl_cutoff_period;

    END LOOP;
    /* End Bug 3558916 */


    l_validation_status := FND_API.G_RET_STS_SUCCESS;
    -- Initialize the table
    FOR l_index in 1..PSB_WS_ACCT1.G_MAX_NUM_AMOUNTS LOOP
      l_period_amount(l_index) := NULL;
    END LOOP;

    -- Start the Validation process
    /* Modified for Bug 3558916 Start  */
    OPEN cur_wlbi;

    LOOP

     l_code_combination_id_tbl.DELETE;
     FETCH  cur_wlbi BULK COLLECT INTO
                l_code_combination_id_tbl,
		l_concat_account_tbl,
                l_account_type_tbl,
		l_curr_code_tbl,
                l_template_id_tbl, l_service_package_id_tbl,
                l_service_package_name_tbl, l_amount1_tbl,
	 	l_amount2_tbl, l_amount3_tbl,
                l_amount4_tbl, l_amount5_tbl,
		l_amount6_tbl, l_amount7_tbl, l_amount8_tbl,
                l_amount9_tbl, l_amount10_tbl,
		l_amount11_tbl, l_amount12_tbl
                LIMIT 350;

    BEGIN

    IF l_code_combination_id_tbl.COUNT = 0 THEN
      EXIT;
    END IF;

    FOR i IN 1..l_code_combination_id_tbl.COUNT
    LOOP

    /* Modified for Bug 3558916 End */

      old_acct := FALSE;
      new_acct := FALSE;
      --l_ccid := wlbi_rec.CODE_COMBINATION_ID;
	l_ccid := l_code_combination_id_tbl(i);

      IF nvl(l_ccid,0) = 0 then
	new_acct := TRUE;
      ELSE
	old_acct := TRUE;
      END IF;

      --l_old_spid := wlbi_rec.SERVICE_PACKAGE_ID; -- required for reassignment
 	l_old_spid := l_service_package_id_tbl(i); -- required for reassignment

      -- Get the Service Package ID

      /* Bug 3428156 start */
      --service package name should keep its cases
      --l_spname := upper(wlbi_rec.SERVICE_PACKAGE_NAME);
      --l_spname := wlbi_rec.SERVICE_PACKAGE_NAME;
      l_spname := l_service_package_name_tbl(i);
      /* Bug 3428156 end */

      IF l_spname is null
	 or l_spname = g_translated_base_sp_name THEN
	l_spid := g_base_spid;
      ELSE
	Get_SPID(p_worksheet_id => g_global_worksheet_id,
		 p_spname       => l_spname,
		 p_spid         => l_spid
		);
      END IF;


      --l_concatenated_account := wlbi_rec.CONCATENATED_ACCOUNT
      l_concatenated_account := l_concat_account_tbl(i);

      --debug('CCID '||wlbi_rec.CODE_COMBINATION_ID);

      /* Bug 3558916: Commented for implementing BULK FETCH
      Move the amount to PL/SQL Table
      g_year_amts(1).amount  :=  wlbi_rec.amount1;
      g_year_amts(2).amount  :=  wlbi_rec.amount2;
      g_year_amts(3).amount  :=  wlbi_rec.amount3;
      g_year_amts(4).amount  :=  wlbi_rec.amount4;
      g_year_amts(5).amount  :=  wlbi_rec.amount5;
      g_year_amts(6).amount  :=  wlbi_rec.amount6;
      g_year_amts(7).amount  :=  wlbi_rec.amount7;
      g_year_amts(8).amount  :=  wlbi_rec.amount8;
      g_year_amts(9).amount  :=  wlbi_rec.amount9;
      g_year_amts(10).amount :=  wlbi_rec.amount10;
      g_year_amts(11).amount :=  wlbi_rec.amount11;
      g_year_amts(12).amount :=  wlbi_rec.amount12; */

      -- Move the amount to PL/SQL Table
      g_year_amts(1).amount  :=  l_amount1_tbl(i);
      g_year_amts(2).amount  :=  l_amount2_tbl(i);
      g_year_amts(3).amount  :=  l_amount3_tbl(i);
      g_year_amts(4).amount  :=  l_amount4_tbl(i);
      g_year_amts(5).amount  :=  l_amount5_tbl(i);
      g_year_amts(6).amount  :=  l_amount6_tbl(i);
      g_year_amts(7).amount  :=  l_amount7_tbl(i);
      g_year_amts(8).amount  :=  l_amount8_tbl(i);
      g_year_amts(9).amount  :=  l_amount9_tbl(i);
      g_year_amts(10).amount :=  l_amount10_tbl(i);
      g_year_amts(11).amount :=  l_amount11_tbl(i);
      g_year_amts(12).amount :=  l_amount12_tbl(i);

      FOR col_index in 1..g_max_num_cols LOOP
	g_year_amts(col_index).amount := nvl(g_year_amts(col_index).amount,0);
      END LOOP;


      validated_acct := FALSE;
      found_acct_line := FALSE;

      FOR col_index in 1..g_max_num_cols LOOP

	IF g_ws_cols(col_index).balance_type = 'E' THEN

	  found_acct_line := FALSE;

	  /* Bug 3589696: Added the IF statement */
                l_last_cy_period := FALSE;
          IF ((l_budget_period_id = g_ws_cols(col_index).budget_year_id)
              AND (l_gl_cutoff_period = l_end_date)) THEN
         	l_last_cy_period := TRUE;
          END IF;

	  IF old_acct THEN

	    Get_Account_Line
	    (
		p_worksheet_id    => g_worksheet_id,
		p_ccid            => l_ccid,
		p_spid            => l_old_spid,
		p_budget_year_id  => g_ws_cols(col_index).budget_year_id,
		p_stage_seq       => g_current_stage_seq,
		p_account_line_id => l_account_line_id,
		p_found_acct_line => found_acct_line
	    );

	  END IF;


	  IF old_acct and found_acct_line THEN
	     --update account

		/* Bug 3589696: Added the IF statement */
		IF NOT l_last_cy_period THEN

	     	PSB_WS_ACCT_PVT.Create_Account_Dist
		 (
		  p_api_version                 => 1.0,
		  p_init_msg_list               => FND_API.G_FALSE,
		  p_commit                      => FND_API.G_FALSE,
		  p_validation_level            => FND_API.G_VALID_LEVEL_FULL,
		  p_return_status               => l_return_status,
		  p_msg_count                   => l_msg_count,
		  p_msg_data                    => l_msg_data,
		  --
		  p_distribute_flag             => FND_API.G_TRUE,
		  p_worksheet_id                => g_worksheet_id,
		  p_account_line_id             => l_account_line_id,
		  p_service_package_id          => l_spid,
		  p_ytd_amount                  => g_year_amts(col_index).amount,
		  --
		  p_period_amount               => l_period_amount
		 );

	      	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		 RAISE FND_API.G_EXC_ERROR ;
	      	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		 RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	      	END IF;

		END IF;


	  ELSIF (new_acct or ( old_acct and (not found_acct_line) )
		and   g_year_amts(col_index).amount <> 0 ) THEN
          -- bug 4464222 added <> in the above line.

	    --Validate the Account
	    IF not validated_acct THEN
	      PSB_VALIDATE_ACCT_PVT.Validate_Account
	      (
		p_api_version                =>    1.0,
		p_init_msg_list              =>    FND_API.G_FALSE,
		p_commit                     =>    FND_API.G_FALSE,
		p_validation_level           =>    FND_API.G_VALID_LEVEL_FULL,
		p_return_status              =>    l_return_status,
		p_msg_count                  =>    l_msg_count,
		p_msg_data                   =>    l_msg_data,
		--
		p_parent_budget_group_id     =>    g_budget_group_id,
		p_startdate_pp               =>    g_pp_start_date,
		p_enddate_cy                 =>    g_cy_end_date,
		p_set_of_books_id            =>    g_set_of_books_id,
		p_flex_code                  =>    g_chart_of_accounts_id,
		p_create_budget_account      =>    FND_API.G_TRUE,
		--
		p_concatenated_segments      =>    l_concatenated_account,
		--
		p_worksheet_id               =>    g_global_worksheet_id,
		p_in_ccid                    =>    FND_API.G_MISS_NUM,
		p_out_ccid                   =>    va_ccid,
		p_budget_group_id            =>    va_budget_group_id
	      );

	      IF  l_return_status =  FND_API.G_RET_STS_SUCCESS THEN
		validated_acct := TRUE;
		l_budget_group_id := va_budget_group_id;
	      ELSE
		l_validation_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('PSB', 'PSB_INVALID_CC_SEG');
		FND_MESSAGE.SET_TOKEN('CC', l_concatenated_account );
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	      END IF;

	    END IF; -- if not validated even once for the record
	    -- Create the Account

	    /* Bug 3589696 : Added the IF statement */
	    IF l_last_cy_period THEN
		g_year_amts(col_index).amount := 0;
	    END IF;

	    PSB_WS_ACCT_PVT.Create_Account_Dist
	    (
	      p_api_version                 => 1.0,
	      p_init_msg_list               => FND_API.G_FALSE,
	      p_commit                      => FND_API.G_FALSE,
	      p_validation_level            => FND_API.G_VALID_LEVEL_FULL,
	      p_return_status               => l_return_status,
	      p_msg_count                   => l_msg_count,
	      p_msg_data                    => l_msg_data,
	      --
	      p_account_line_id             => ca_account_line_id,
	      p_worksheet_id                => g_worksheet_id,
	      p_map_accounts                => TRUE,
	      p_budget_year_id              => g_ws_cols(col_index).budget_year_id,
	      p_budget_group_id             => va_budget_group_id,
	      p_flex_code                   => g_chart_of_accounts_id,
	      p_concatenated_segments       => l_concatenated_account,
	      p_currency_code               => g_currency_code,
	      p_balance_type                => 'E',  -- Always Estimate
	      p_ytd_amount                  => g_year_amts(col_index).amount,
	      p_distribute_flag             => FND_API.G_TRUE,
	      p_period_amount               => l_period_amount,
	      p_service_package_id          => l_spid
	    );


	    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR ;
	    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	    END IF;


	  END IF; --new acct or old acct and not found_acct_line


	END IF; -- balance type = 'E'
      END LOOP; --for col index 1..colcount

     END LOOP; -- For 1..tblcount

    EXCEPTION -- To handle exceptions at record level and continue with the rest
    WHEN FND_API.G_EXC_ERROR then
      l_validation_status := FND_API.G_RET_STS_ERROR;
      -- Other Exceptions are handled in Import WS procedure
    END;
    END LOOP;  --For each record in WAL Interface

    CLOSE cur_wlbi;

    IF l_validation_status = FND_API.G_RET_STS_ERROR THEN
	raise FND_API.G_EXC_ERROR;
    END IF;

  END Get_WS_Line_Bal;



  PROCEDURE Get_Account_Line
  (
  p_worksheet_id    IN NUMBER,
  p_ccid            IN NUMBER,
  p_spid            IN NUMBER,
  p_budget_year_id  IN NUMBER,
  p_stage_seq       IN NUMBER,
  p_account_line_id OUT  NOCOPY NUMBER,
  p_found_acct_line OUT  NOCOPY BOOLEAN
  )
  IS

    cursor wal_cur is
    SELECT wal.account_line_id
    FROM   psb_ws_account_lines wal,
	  psb_ws_lines wl
    WHERE  wl.worksheet_id = p_worksheet_id
    AND    wl.account_line_id = wal.account_line_id
    AND    wal.code_combination_id = p_ccid
    AND    wal.service_package_id = p_spid
    AND    wal.budget_year_id = p_budget_year_id
    AND    wal.balance_type = 'E'
    AND    wal.currency_code = g_currency_code --bug:6683641
    AND    wal.end_stage_seq is null;


    Recinfo   wal_cur%ROWTYPE;

  BEGIN
    p_account_line_id := 0;
    OPEN wal_cur;
    FETCH wal_cur INTO Recinfo;
    IF wal_cur%FOUND THEN
      p_found_acct_line := TRUE;
      p_account_line_id := Recinfo.account_line_id;
    ELSE
      p_found_acct_line := FALSE;
    END IF;
    close wal_cur;

  END Get_Account_Line;


  PROCEDURE Clear_POS_WS_Cols is
  BEGIN
    for l_init_index in 1..g_max_num_pos_ws_cols loop
      g_pos_ws_cols(l_init_index).column_type := null;
      g_pos_ws_cols(l_init_index).budget_year_id := null;
      g_pos_ws_cols(l_init_index).budget_year_name := null;
      g_pos_ws_cols(l_init_index).budget_period_id := null;
      g_pos_ws_cols(l_init_index).budget_period_name := null;
      g_pos_ws_cols(l_init_index).balance_type  := null;
      g_pos_ws_cols(l_init_index).display_balance_type  := null;
      g_pos_ws_cols(l_init_index).year_category_type  := null;
    end loop;
  END Clear_POS_WS_Cols;

  PROCEDURE Get_POS_WS_Cols
  IS
    l_col_count NUMBER := 1;
    i NUMBER;
    l_budget_year_id NUMBER;
  BEGIN


    FOR ws_col_rec IN
      ( SELECT
		COLUMN_NUMBER,
		COLUMN_TYPE,
		BUDGET_YEAR_ID,
		BUDGET_YEAR_NAME,
		BUDGET_PERIOD_ID,
		BUDGET_PERIOD_NAME,
		BALANCE_TYPE,
		YEAR_CATEGORY_TYPE
	  FROM PSB_WS_COLUMNS_I
	  WHERE EXPORT_ID = g_export_id
	  AND EXPORT_WORKSHEET_TYPE = 'P'
	  ORDER BY COLUMN_NUMBER
      )
    LOOP
      i := ws_col_rec.COLUMN_NUMBER;
      g_pos_ws_cols(i).column_type := ws_col_rec.column_type;
      g_pos_ws_cols(i).budget_year_id := ws_col_rec.budget_year_id;
      g_pos_ws_cols(i).budget_year_name:= ws_col_rec.budget_year_name;
      g_pos_ws_cols(i).budget_period_id := ws_col_rec.budget_year_id;
      g_pos_ws_cols(i).budget_period_name:= ws_col_rec.budget_year_name;
      g_pos_ws_cols(i).balance_type:= ws_col_rec.balance_type;
      g_pos_ws_cols(i).year_category_type:= ws_col_rec.year_category_type;

    END LOOP;

    -- Also create a table of estimate years for easy access

    FOR ws_col_rec IN
      ( SELECT
		min(column_number)    total_column,
		min(column_number)+1  percent_column,
		min(column_number)+2  period_start_column,
		max(column_number)    period_end_column,
		budget_year_id
	FROM psb_ws_columns_i
	WHERE export_id = g_export_id
	AND   export_worksheet_type = 'P'
	AND   balance_type = 'E'
	GROUP BY budget_year_id )
    LOOP
      g_estimate_years(ws_col_rec.budget_year_id).total_column        := ws_col_rec.total_column;
      g_estimate_years(ws_col_rec.budget_year_id).percent_column      := ws_col_rec.percent_column;
      g_estimate_years(ws_col_rec.budget_year_id).period_start_column := ws_col_rec.period_start_column;
      g_estimate_years(ws_col_rec.budget_year_id).period_end_column   := ws_col_rec.period_end_column;

    END LOOP;

  END Get_POS_WS_Cols;

  PROCEDURE  Get_POS_WS_Line_Bal
  IS

  l_return_status VARCHAR2(1);
  ua_return_status VARCHAR2(1);
  ud_return_status VARCHAR2(1);
  l_position_line_id NUMBER;

  BEGIN

    -- Cache all the Elements
    PSB_WS_POS1.Cache_Elements
       (p_return_status => l_return_status,
	p_data_extract_id => g_data_extract_id,
	p_business_group_id => g_business_group_id,
	p_worksheet_id => g_worksheet_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;


    PSB_WS_POS1.Cache_Named_Attributes
       (p_return_status => l_return_status,
	p_business_group_id => g_business_group_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    ua_return_status := FND_API.G_RET_STS_SUCCESS;
    ud_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Drive the process with Positions
    FOR position_rec in
    ( select distinct position_line_id
      from psb_ws_line_balances_i
      where export_id = g_export_id
      and export_worksheet_type = 'P'
    )
    LOOP
      l_position_line_id := position_rec.position_line_id;
      --debug('Plid'||l_position_line_id);


      Update_Assignments(p_return_status => l_return_status,
			 p_position_line_id => position_rec.position_line_id);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
	ua_return_status := l_return_status;
      END IF;

       for l_sp_rec in
       (select distinct service_package_id,code_combination_id,pay_element_set_id
        from   psb_ws_line_balances_i
        where  export_id = g_export_id
        and    export_worksheet_type = 'P'
        and    value_type = 'A'
        and    position_line_id = position_rec.position_line_id) loop

    /*start bug:6019074: STATEMENT level logging*/
   if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then

       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
      'PSB/EXPORT_EXCEL_TO_PSB/PSBVXL2B/Get_POS_WS_Line_Bal',
      'Before calling Update_Distributions for position_line_id:'||position_rec.position_line_id||
      ' service_package_id:'||l_sp_rec.service_package_id||
      ' code_combination_id:'||l_sp_rec.code_combination_id||
      ' element_set_id:'||l_sp_rec.pay_element_set_id);

      /*fnd_file.put_line(fnd_file.LOG,'Before calling Update_Distributions for position_line_id:'||
                                        position_rec.position_line_id||
                                       ' service_package_id:'||l_sp_rec.service_package_id||
                                       ' code_combination_id:'||l_sp_rec.code_combination_id||
                                       ' element_set_id:'||l_sp_rec.pay_element_set_id);
      */

   end if;
   /*end bug:6019074:end STATEMENT level log*/

      /*bug:6019074:update_distributions is called per position_line_id, service_package_id,
        code_combination_id and pay_element_set_id. This helps in calculating the ytd and
        period amounts of an account line based on element set id.*/

         Update_Distributions(p_return_status => ud_return_status,
                                  /*bug:6019074:start*/
       			      p_position_line_id => position_rec.position_line_id,
                              p_service_package_id => l_sp_rec.service_package_id,
                              p_code_combination_id => l_sp_rec.code_combination_id,
                              p_pay_element_set_id => l_sp_rec.pay_element_set_id
                                    /*bug:6019074:end*/
                             );

       -- Using FND_API constants here leads to DB crash
          IF (ua_return_status <> 'S' ) OR
             (ud_return_status <> 'S' ) THEN

        fnd_file.put_line(fnd_file.LOG,'exception raised for p_position_line_id:'||position_rec.position_line_id||
                                       ' p_code_combination_id:'||l_sp_rec.code_combination_id||
                                       ' p_pay_element_set_id:'||l_sp_rec.pay_element_set_id);--bug:6019074

             raise FND_API.G_EXC_ERROR;
          END IF;
       end loop;

    END LOOP;

  END Get_POS_WS_Line_Bal;


  /*bug:6019074:added parameters p_position_line_id, p_service_package_id,
    p_code_combination_id and p_pay_element_set_id*/

  PROCEDURE Update_Distributions
  ( p_return_status          OUT  NOCOPY VARCHAR2,
    p_position_line_id       NUMBER,
    p_service_package_id     NUMBER,
    p_code_combination_id    NUMBER,
    p_pay_element_set_id     NUMBER
  )
  IS

    l_period_start_column NUMBER;
    l_period_end_column   NUMBER;
    l_year_total_column   NUMBER;
    l_year_amount NUMBER := 0;


    l_year_index BINARY_INTEGER;
    l_period_index BINARY_INTEGER;
    l_wlbi_index BINARY_INTEGER;

    l_period_amounts   PSB_WS_ACCT1.g_prdamt_tbl_type;
    l_validation_status VARCHAR2(1) ;
    l_currency_flag VARCHAR2(1);

    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_export_status     VARCHAR2(10);

--
    l_col_count NUMBER;

    l_pay_element_id NUMBER;
    l_position_line_id NUMBER;
    l_ccid NUMBER;
    l_old_spid NUMBER;
    l_spid NUMBER;
    l_spname VARCHAR2(30);
    l_salary_account_line VARCHAR2(1);
    l_element_set_id NUMBER;

    l_concatenated_account VARCHAR2(2000);
    l_currency_code VARCHAR2(15);

    va_ccid NUMBER;
    va_budget_group_id NUMBER;
    l_budget_group_id  NUMBER;
    ca_account_line_id  NUMBER;
    l_account_line_id  NUMBER;


    l_amount NUMBER;

    old_acct BOOLEAN;
    new_acct BOOLEAN;
    validated_acct BOOLEAN;
    found_pos_acct_line BOOLEAN;
    found_element_set   BOOLEAN;
    l_create_follow_sal_acct BOOLEAN;

    l_disp_amt number;

    /*bug:6019074:start*/
    CURSOR l_wlbi_csr IS
    SELECT
	CODE_COMBINATION_ID,
	CONCATENATED_ACCOUNT,
	ACCOUNT_TYPE,
	CURRENCY_CODE,
	TEMPLATE_ID,
	SERVICE_PACKAGE_ID,
	SERVICE_PACKAGE_NAME,
	POSITION_LINE_ID,
	POSITION_ID,
	PAY_ELEMENT_ID,
	PAY_ELEMENT_SET_ID,
	PAY_ELEMENT_NAME,
	FOLLOW_SALARY,
	SALARY_ACCOUNT_LINE,
	AMOUNT1 a1,AMOUNT2 a2,AMOUNT3 a3,AMOUNT4 a4,AMOUNT5 a5,
	AMOUNT6 a6,AMOUNT7 a7,AMOUNT8 a8,AMOUNT9 a9,AMOUNT10 a10,
	AMOUNT11 a11,AMOUNT12 a12,AMOUNT13 a13,AMOUNT14 a14,AMOUNT15 a15,
	AMOUNT16 a16,AMOUNT17 a17,AMOUNT18 a18,AMOUNT19 a19,AMOUNT20 a20,
	AMOUNT21 a21,AMOUNT22 a22,AMOUNT23 a23,AMOUNT24 a24,AMOUNT25 a25,
	AMOUNT26 a26,AMOUNT27 a27,AMOUNT28 a28,AMOUNT29 a29,AMOUNT30 a30,
	AMOUNT31 a31,AMOUNT32 a32,AMOUNT33 a33,AMOUNT34 a34,AMOUNT35 a35,
	AMOUNT36 a36,AMOUNT37 a37,AMOUNT38 a38,AMOUNT39 a39,AMOUNT40 a40,
	AMOUNT41 a41,AMOUNT42 a42,AMOUNT43 a43,AMOUNT44 a44,AMOUNT45 a45,
	AMOUNT46 a46,AMOUNT47 a47,AMOUNT48 a48,AMOUNT49 a49,AMOUNT50 a50,
	AMOUNT51 a51,AMOUNT52 a52,AMOUNT53 a53,AMOUNT54 a54,AMOUNT55 a55,
	AMOUNT56 a56,AMOUNT57 a57,AMOUNT58 a58,AMOUNT59 a59,AMOUNT60 a60,
	AMOUNT61 a61,AMOUNT62 a62,AMOUNT63 a63,AMOUNT64 a64,AMOUNT65 a65,
	AMOUNT66 a66,AMOUNT67 a67,AMOUNT68 a68,AMOUNT69 a69,AMOUNT70 a70,
	AMOUNT71 a71,AMOUNT72 a72,AMOUNT73 a73,AMOUNT74 a74,AMOUNT75 a75,
	AMOUNT76 a76,AMOUNT77 a77,AMOUNT78 a78,AMOUNT79 a79,AMOUNT80 a80,
	AMOUNT81 a81,AMOUNT82 a82,AMOUNT83 a83,AMOUNT84 a84,AMOUNT85 a85,
	AMOUNT86 a86,AMOUNT87 a87,AMOUNT88 a88,AMOUNT89 a89,AMOUNT90 a90,
	AMOUNT91 a91,AMOUNT92 a92,AMOUNT93 a93,AMOUNT94 a94,AMOUNT95 a95,
	AMOUNT96 a96,AMOUNT97 a97,AMOUNT98 a98,AMOUNT99 a99,AMOUNT100 a100,
	AMOUNT101 a101,AMOUNT102 a102,AMOUNT103 a103,AMOUNT104 a104,AMOUNT105 a105,
	AMOUNT106 a106,AMOUNT107 a107,AMOUNT108 a108,AMOUNT109 a109,AMOUNT110 a110,
	AMOUNT111 a111,AMOUNT112 a112,AMOUNT113 a113,AMOUNT114 a114,AMOUNT115 a115,
	AMOUNT116 a116,AMOUNT117 a117,AMOUNT118 a118,AMOUNT119 a119,AMOUNT120 a120,
	AMOUNT121 a121,AMOUNT122 a122,AMOUNT123 a123,AMOUNT124 a124,AMOUNT125 a125,
	AMOUNT126 a126,AMOUNT127 a127,AMOUNT128 a128,AMOUNT129 a129,AMOUNT130 a130,
	AMOUNT131 a131,AMOUNT132 a132,AMOUNT133 a133,AMOUNT134 a134,AMOUNT135 a135,
	AMOUNT136 a136,AMOUNT137 a137,AMOUNT138 a138,AMOUNT139 a139,AMOUNT140 a140,
	AMOUNT141 a141,AMOUNT142 a142,AMOUNT143 a143,AMOUNT144 a144,AMOUNT145 a145,
	AMOUNT146 a146,AMOUNT147 a147,AMOUNT148 a148,AMOUNT149 a149,AMOUNT150 a150,
	AMOUNT151 a151,AMOUNT152 a152,AMOUNT153 a153,AMOUNT154 a154,AMOUNT155 a155,
	AMOUNT156 a156,AMOUNT157 a157,AMOUNT158 a158,AMOUNT159 a159,AMOUNT160 a160,
	AMOUNT161 a161,AMOUNT162 a162,AMOUNT163 a163,AMOUNT164 a164,AMOUNT165 a165,
	AMOUNT166 a166,AMOUNT167 a167,AMOUNT168 a168
      FROM  psb_ws_line_balances_i
      WHERE export_worksheet_type = 'P'
      AND  export_id = g_export_id
      AND  value_type = 'A' -- process only Amount rows
         /*bug:6019074:start*/
      AND  position_line_id   = p_position_line_id
      AND  service_package_id = p_service_package_id
      AND  code_combination_id = p_code_combination_id
      AND  nvl(pay_element_set_id,0) = nvl(p_pay_element_set_id,0)
        /*bug:6019074:end*/
      ORDER BY position_line_id, pay_element_set_id,
               code_combination_id, salary_account_line;

    TYPE l_wlbi_rec_type IS RECORD (
        pay_element_id         NUMBER,
        pay_element_set_id     NUMBER,
        position_line_id       NUMBER,
        code_combination_id    NUMBER,
        service_package_id     NUMBER,
        service_package_name   VARCHAR2(30),
        concatenated_account   VARCHAR2(1000),
        salary_account_line    VARCHAR2(1),
        old_acct               BOOLEAN,
        new_acct               BOOLEAN,
        account_line_id        NUMBER,
        found_pos_acct_line    BOOLEAN
      );


    TYPE g_wlbi_amounts_tbl_type IS TABLE OF l_wlbi_rec_type INDEX BY BINARY_INTEGER;
    g_wlbi_amounts_tbl  g_wlbi_amounts_tbl_type;
    l_index  NUMBER:= 0;

    TYPE l_element_set_rec_type IS RECORD
    (
      pay_element_set_id  NUMBER,
      start_index         NUMBER,
      end_index           NUMBER,
      account_line_id     NUMBER,
      ytd_amount          NUMBER
    );

    l_element_set_tbl      l_element_set_rec_type;
    l_sum_period_amounts   NUMBER := 0;
    l_rounding_diff        NUMBER := 0;

    /*bug:6019074:end*/

  BEGIN
    l_validation_status := FND_API.G_RET_STS_SUCCESS;

      /*bug:6019074:Initializing g_wlbi_amounts table*/
      for l_cnt in 1..g_wlbi_amounts.count loop
        g_wlbi_amounts(l_cnt).amount := 0;
      end loop;

    /*bug:6019074:moved the inline for loop sql and declared it as a cursor l_wlbi_csr.
      Records fetched from cursor l_wlbi_csr are stored in plsql table g_wlbi_amounts_tbl.
      Amount columns are stored in g_wlbi_amounts.This is required as one element_set_id
      can span multiple pay elements assigned to the position. */

      -- Process updates before insert; within updates process non salary account lines first
    FOR  wlbi_rec IN l_wlbi_csr LOOP
    BEGIN

      -- Move the Amounts to PL/SQL table
      g_wlbi_amounts(1).amount := nvl(g_wlbi_amounts(1).amount,0) + wlbi_rec.a1;
      g_wlbi_amounts(2).amount := nvl(g_wlbi_amounts(2).amount,0) + wlbi_rec.a2;
      g_wlbi_amounts(3).amount := nvl(g_wlbi_amounts(3).amount,0) + wlbi_rec.a3;
      g_wlbi_amounts(4).amount := nvl(g_wlbi_amounts(4).amount,0) + wlbi_rec.a4;
      g_wlbi_amounts(5).amount := nvl(g_wlbi_amounts(5).amount,0) + wlbi_rec.a5;
      g_wlbi_amounts(6).amount := nvl(g_wlbi_amounts(6).amount,0) + wlbi_rec.a6;
      g_wlbi_amounts(7).amount := nvl(g_wlbi_amounts(7).amount,0) + wlbi_rec.a7;
      g_wlbi_amounts(8).amount := nvl(g_wlbi_amounts(8).amount,0) + wlbi_rec.a8;
      g_wlbi_amounts(9).amount := nvl(g_wlbi_amounts(9).amount,0) + wlbi_rec.a9;
      g_wlbi_amounts(10).amount := nvl(g_wlbi_amounts(10).amount,0) + wlbi_rec.a10;

      g_wlbi_amounts(11).amount := nvl(g_wlbi_amounts(11).amount,0) + wlbi_rec.a11;
      g_wlbi_amounts(12).amount := nvl(g_wlbi_amounts(12).amount,0) + wlbi_rec.a12;
      g_wlbi_amounts(13).amount := nvl(g_wlbi_amounts(13).amount,0) + wlbi_rec.a13;
      g_wlbi_amounts(14).amount := nvl(g_wlbi_amounts(14).amount,0) + wlbi_rec.a14;
      g_wlbi_amounts(15).amount := nvl(g_wlbi_amounts(15).amount,0) + wlbi_rec.a15;
      g_wlbi_amounts(16).amount := nvl(g_wlbi_amounts(16).amount,0) + wlbi_rec.a16;
      g_wlbi_amounts(17).amount := nvl(g_wlbi_amounts(17).amount,0) + wlbi_rec.a17;
      g_wlbi_amounts(18).amount := nvl(g_wlbi_amounts(18).amount,0) + wlbi_rec.a18;
      g_wlbi_amounts(19).amount := nvl(g_wlbi_amounts(19).amount,0) + wlbi_rec.a19;
      g_wlbi_amounts(20).amount := nvl(g_wlbi_amounts(20).amount,0) + wlbi_rec.a20;

      g_wlbi_amounts(21).amount := nvl(g_wlbi_amounts(21).amount,0) + wlbi_rec.a21;
      g_wlbi_amounts(22).amount := nvl(g_wlbi_amounts(22).amount,0) + wlbi_rec.a22;
      g_wlbi_amounts(23).amount := nvl(g_wlbi_amounts(23).amount,0) + wlbi_rec.a23;
      g_wlbi_amounts(24).amount := nvl(g_wlbi_amounts(24).amount,0) + wlbi_rec.a24;
      g_wlbi_amounts(25).amount := nvl(g_wlbi_amounts(25).amount,0) + wlbi_rec.a25;
      g_wlbi_amounts(26).amount := nvl(g_wlbi_amounts(26).amount,0) + wlbi_rec.a26;
      g_wlbi_amounts(27).amount := nvl(g_wlbi_amounts(27).amount,0) + wlbi_rec.a27;
      g_wlbi_amounts(28).amount := nvl(g_wlbi_amounts(28).amount,0) + wlbi_rec.a28;
      g_wlbi_amounts(29).amount := nvl(g_wlbi_amounts(29).amount,0) + wlbi_rec.a29;
      g_wlbi_amounts(30).amount := nvl(g_wlbi_amounts(30).amount,0) + wlbi_rec.a30;

      g_wlbi_amounts(31).amount := nvl(g_wlbi_amounts(31).amount,0) + wlbi_rec.a31;
      g_wlbi_amounts(32).amount := nvl(g_wlbi_amounts(32).amount,0) + wlbi_rec.a32;
      g_wlbi_amounts(33).amount := nvl(g_wlbi_amounts(33).amount,0) + wlbi_rec.a33;
      g_wlbi_amounts(34).amount := nvl(g_wlbi_amounts(34).amount,0) + wlbi_rec.a34;
      g_wlbi_amounts(35).amount := nvl(g_wlbi_amounts(35).amount,0) + wlbi_rec.a35;
      g_wlbi_amounts(36).amount := nvl(g_wlbi_amounts(36).amount,0) + wlbi_rec.a36;
      g_wlbi_amounts(37).amount := nvl(g_wlbi_amounts(37).amount,0) + wlbi_rec.a37;
      g_wlbi_amounts(38).amount := nvl(g_wlbi_amounts(38).amount,0) + wlbi_rec.a38;
      g_wlbi_amounts(39).amount := nvl(g_wlbi_amounts(39).amount,0) + wlbi_rec.a39;
      g_wlbi_amounts(40).amount := nvl(g_wlbi_amounts(40).amount,0) + wlbi_rec.a40;

      g_wlbi_amounts(41).amount := nvl(g_wlbi_amounts(41).amount,0) + wlbi_rec.a41;
      g_wlbi_amounts(42).amount := nvl(g_wlbi_amounts(42).amount,0) + wlbi_rec.a42;
      g_wlbi_amounts(43).amount := nvl(g_wlbi_amounts(43).amount,0) + wlbi_rec.a43;
      g_wlbi_amounts(44).amount := nvl(g_wlbi_amounts(44).amount,0) + wlbi_rec.a44;
      g_wlbi_amounts(45).amount := nvl(g_wlbi_amounts(45).amount,0) + wlbi_rec.a45;
      g_wlbi_amounts(46).amount := nvl(g_wlbi_amounts(46).amount,0) + wlbi_rec.a46;
      g_wlbi_amounts(47).amount := nvl(g_wlbi_amounts(47).amount,0) + wlbi_rec.a47;
      g_wlbi_amounts(48).amount := nvl(g_wlbi_amounts(48).amount,0) + wlbi_rec.a48;
      g_wlbi_amounts(49).amount := nvl(g_wlbi_amounts(49).amount,0) + wlbi_rec.a49;
      g_wlbi_amounts(50).amount := nvl(g_wlbi_amounts(50).amount,0) + wlbi_rec.a50;

      g_wlbi_amounts(51).amount := nvl(g_wlbi_amounts(51).amount,0) + wlbi_rec.a51;
      g_wlbi_amounts(52).amount := nvl(g_wlbi_amounts(52).amount,0) + wlbi_rec.a52;
      g_wlbi_amounts(53).amount := nvl(g_wlbi_amounts(53).amount,0) + wlbi_rec.a53;
      g_wlbi_amounts(54).amount := nvl(g_wlbi_amounts(54).amount,0) + wlbi_rec.a54;
      g_wlbi_amounts(55).amount := nvl(g_wlbi_amounts(55).amount,0) + wlbi_rec.a55;
      g_wlbi_amounts(56).amount := nvl(g_wlbi_amounts(56).amount,0) + wlbi_rec.a56;
      g_wlbi_amounts(57).amount := nvl(g_wlbi_amounts(57).amount,0) + wlbi_rec.a57;
      g_wlbi_amounts(58).amount := nvl(g_wlbi_amounts(58).amount,0) + wlbi_rec.a58;
      g_wlbi_amounts(59).amount := nvl(g_wlbi_amounts(59).amount,0) + wlbi_rec.a59;
      g_wlbi_amounts(60).amount := nvl(g_wlbi_amounts(60).amount,0) + wlbi_rec.a60;

      g_wlbi_amounts(61).amount := nvl(g_wlbi_amounts(61).amount,0) + wlbi_rec.a61;
      g_wlbi_amounts(62).amount := nvl(g_wlbi_amounts(62).amount,0) + wlbi_rec.a62;
      g_wlbi_amounts(63).amount := nvl(g_wlbi_amounts(63).amount,0) + wlbi_rec.a63;
      g_wlbi_amounts(64).amount := nvl(g_wlbi_amounts(64).amount,0) + wlbi_rec.a64;
      g_wlbi_amounts(65).amount := nvl(g_wlbi_amounts(65).amount,0) + wlbi_rec.a65;
      g_wlbi_amounts(66).amount := nvl(g_wlbi_amounts(66).amount,0) + wlbi_rec.a66;
      g_wlbi_amounts(67).amount := nvl(g_wlbi_amounts(67).amount,0) + wlbi_rec.a67;
      g_wlbi_amounts(68).amount := nvl(g_wlbi_amounts(68).amount,0) + wlbi_rec.a68;
      g_wlbi_amounts(69).amount := nvl(g_wlbi_amounts(69).amount,0) + wlbi_rec.a69;
      g_wlbi_amounts(70).amount := nvl(g_wlbi_amounts(70).amount,0) + wlbi_rec.a70;

      g_wlbi_amounts(71).amount := nvl(g_wlbi_amounts(71).amount,0) + wlbi_rec.a71;
      g_wlbi_amounts(72).amount := nvl(g_wlbi_amounts(72).amount,0) + wlbi_rec.a72;
      g_wlbi_amounts(73).amount := nvl(g_wlbi_amounts(73).amount,0) + wlbi_rec.a73;
      g_wlbi_amounts(74).amount := nvl(g_wlbi_amounts(74).amount,0) + wlbi_rec.a74;
      g_wlbi_amounts(75).amount := nvl(g_wlbi_amounts(75).amount,0) + wlbi_rec.a75;
      g_wlbi_amounts(76).amount := nvl(g_wlbi_amounts(76).amount,0) + wlbi_rec.a76;
      g_wlbi_amounts(77).amount := nvl(g_wlbi_amounts(77).amount,0) + wlbi_rec.a77;
      g_wlbi_amounts(78).amount := nvl(g_wlbi_amounts(78).amount,0) + wlbi_rec.a78;
      g_wlbi_amounts(79).amount := nvl(g_wlbi_amounts(79).amount,0) + wlbi_rec.a79;
      g_wlbi_amounts(80).amount := nvl(g_wlbi_amounts(80).amount,0) + wlbi_rec.a80;

      g_wlbi_amounts(81).amount := nvl(g_wlbi_amounts(81).amount,0) + wlbi_rec.a81;
      g_wlbi_amounts(82).amount := nvl(g_wlbi_amounts(82).amount,0) + wlbi_rec.a82;
      g_wlbi_amounts(83).amount := nvl(g_wlbi_amounts(83).amount,0) + wlbi_rec.a83;
      g_wlbi_amounts(84).amount := nvl(g_wlbi_amounts(84).amount,0) + wlbi_rec.a84;
      g_wlbi_amounts(85).amount := nvl(g_wlbi_amounts(85).amount,0) + wlbi_rec.a85;
      g_wlbi_amounts(86).amount := nvl(g_wlbi_amounts(86).amount,0) + wlbi_rec.a86;
      g_wlbi_amounts(87).amount := nvl(g_wlbi_amounts(87).amount,0) + wlbi_rec.a87;
      g_wlbi_amounts(88).amount := nvl(g_wlbi_amounts(88).amount,0) + wlbi_rec.a88;
      g_wlbi_amounts(89).amount := nvl(g_wlbi_amounts(89).amount,0) + wlbi_rec.a89;
      g_wlbi_amounts(90).amount := nvl(g_wlbi_amounts(90).amount,0) + wlbi_rec.a90;

      g_wlbi_amounts(91).amount := nvl(g_wlbi_amounts(91).amount,0) + wlbi_rec.a91;
      g_wlbi_amounts(92).amount := nvl(g_wlbi_amounts(92).amount,0) + wlbi_rec.a92;
      g_wlbi_amounts(93).amount := nvl(g_wlbi_amounts(93).amount,0) + wlbi_rec.a93;
      g_wlbi_amounts(94).amount := nvl(g_wlbi_amounts(94).amount,0) + wlbi_rec.a94;
      g_wlbi_amounts(95).amount := nvl(g_wlbi_amounts(95).amount,0) + wlbi_rec.a95;
      g_wlbi_amounts(96).amount := nvl(g_wlbi_amounts(96).amount,0) + wlbi_rec.a96;
      g_wlbi_amounts(97).amount := nvl(g_wlbi_amounts(97).amount,0) + wlbi_rec.a97;
      g_wlbi_amounts(98).amount := nvl(g_wlbi_amounts(98).amount,0) + wlbi_rec.a98;
      g_wlbi_amounts(99).amount := nvl(g_wlbi_amounts(99).amount,0) + wlbi_rec.a99;
      g_wlbi_amounts(100).amount := nvl(g_wlbi_amounts(100).amount,0) + wlbi_rec.a100;

      g_wlbi_amounts(101).amount := nvl(g_wlbi_amounts(101).amount,0) + wlbi_rec.a101;
      g_wlbi_amounts(102).amount := nvl(g_wlbi_amounts(102).amount,0) + wlbi_rec.a102;
      g_wlbi_amounts(103).amount := nvl(g_wlbi_amounts(103).amount,0) + wlbi_rec.a103;
      g_wlbi_amounts(104).amount := nvl(g_wlbi_amounts(104).amount,0) + wlbi_rec.a104;
      g_wlbi_amounts(105).amount := nvl(g_wlbi_amounts(105).amount,0) + wlbi_rec.a105;
      g_wlbi_amounts(106).amount := nvl(g_wlbi_amounts(106).amount,0) + wlbi_rec.a106;
      g_wlbi_amounts(107).amount := nvl(g_wlbi_amounts(107).amount,0) + wlbi_rec.a107;
      g_wlbi_amounts(108).amount := nvl(g_wlbi_amounts(108).amount,0) + wlbi_rec.a108;
      g_wlbi_amounts(109).amount := nvl(g_wlbi_amounts(109).amount,0) + wlbi_rec.a109;
      g_wlbi_amounts(110).amount := nvl(g_wlbi_amounts(110).amount,0) + wlbi_rec.a110;

      g_wlbi_amounts(111).amount := nvl(g_wlbi_amounts(111).amount,0) + wlbi_rec.a111;
      g_wlbi_amounts(112).amount := nvl(g_wlbi_amounts(112).amount,0) + wlbi_rec.a112;
      g_wlbi_amounts(113).amount := nvl(g_wlbi_amounts(113).amount,0) + wlbi_rec.a113;
      g_wlbi_amounts(114).amount := nvl(g_wlbi_amounts(114).amount,0) + wlbi_rec.a114;
      g_wlbi_amounts(115).amount := nvl(g_wlbi_amounts(115).amount,0) + wlbi_rec.a115;
      g_wlbi_amounts(116).amount := nvl(g_wlbi_amounts(116).amount,0) + wlbi_rec.a116;
      g_wlbi_amounts(117).amount := nvl(g_wlbi_amounts(117).amount,0) + wlbi_rec.a117;
      g_wlbi_amounts(118).amount := nvl(g_wlbi_amounts(118).amount,0) + wlbi_rec.a118;
      g_wlbi_amounts(119).amount := nvl(g_wlbi_amounts(119).amount,0) + wlbi_rec.a119;
      g_wlbi_amounts(120).amount := nvl(g_wlbi_amounts(120).amount,0) + wlbi_rec.a120;

      g_wlbi_amounts(121).amount := nvl(g_wlbi_amounts(121).amount,0) + wlbi_rec.a121;
      g_wlbi_amounts(122).amount := nvl(g_wlbi_amounts(122).amount,0) + wlbi_rec.a122;
      g_wlbi_amounts(123).amount := nvl(g_wlbi_amounts(123).amount,0) + wlbi_rec.a123;
      g_wlbi_amounts(124).amount := nvl(g_wlbi_amounts(124).amount,0) + wlbi_rec.a124;
      g_wlbi_amounts(125).amount := nvl(g_wlbi_amounts(125).amount,0) + wlbi_rec.a125;
      g_wlbi_amounts(126).amount := nvl(g_wlbi_amounts(126).amount,0) + wlbi_rec.a126;
      g_wlbi_amounts(127).amount := nvl(g_wlbi_amounts(127).amount,0) + wlbi_rec.a127;
      g_wlbi_amounts(128).amount := nvl(g_wlbi_amounts(128).amount,0) + wlbi_rec.a128;
      g_wlbi_amounts(129).amount := nvl(g_wlbi_amounts(129).amount,0) + wlbi_rec.a129;
      g_wlbi_amounts(130).amount := nvl(g_wlbi_amounts(130).amount,0) + wlbi_rec.a130;

      g_wlbi_amounts(131).amount := nvl(g_wlbi_amounts(131).amount,0) + wlbi_rec.a131;
      g_wlbi_amounts(132).amount := nvl(g_wlbi_amounts(132).amount,0) + wlbi_rec.a132;
      g_wlbi_amounts(133).amount := nvl(g_wlbi_amounts(133).amount,0) + wlbi_rec.a133;
      g_wlbi_amounts(134).amount := nvl(g_wlbi_amounts(134).amount,0) + wlbi_rec.a134;
      g_wlbi_amounts(135).amount := nvl(g_wlbi_amounts(135).amount,0) + wlbi_rec.a135;
      g_wlbi_amounts(136).amount := nvl(g_wlbi_amounts(136).amount,0) + wlbi_rec.a136;
      g_wlbi_amounts(137).amount := nvl(g_wlbi_amounts(137).amount,0) + wlbi_rec.a137;
      g_wlbi_amounts(138).amount := nvl(g_wlbi_amounts(138).amount,0) + wlbi_rec.a138;
      g_wlbi_amounts(139).amount := nvl(g_wlbi_amounts(139).amount,0) + wlbi_rec.a139;
      g_wlbi_amounts(140).amount := nvl(g_wlbi_amounts(140).amount,0) + wlbi_rec.a140;

      g_wlbi_amounts(141).amount := nvl(g_wlbi_amounts(141).amount,0) + wlbi_rec.a141;
      g_wlbi_amounts(142).amount := nvl(g_wlbi_amounts(142).amount,0) + wlbi_rec.a142;
      g_wlbi_amounts(143).amount := nvl(g_wlbi_amounts(143).amount,0) + wlbi_rec.a143;
      g_wlbi_amounts(144).amount := nvl(g_wlbi_amounts(144).amount,0) + wlbi_rec.a144;
      g_wlbi_amounts(145).amount := nvl(g_wlbi_amounts(145).amount,0) + wlbi_rec.a145;
      g_wlbi_amounts(146).amount := nvl(g_wlbi_amounts(146).amount,0) + wlbi_rec.a146;
      g_wlbi_amounts(147).amount := nvl(g_wlbi_amounts(147).amount,0) + wlbi_rec.a147;
      g_wlbi_amounts(148).amount := nvl(g_wlbi_amounts(148).amount,0) + wlbi_rec.a148;
      g_wlbi_amounts(149).amount := nvl(g_wlbi_amounts(149).amount,0) + wlbi_rec.a149;
      g_wlbi_amounts(150).amount := nvl(g_wlbi_amounts(150).amount,0) + wlbi_rec.a150;

      g_wlbi_amounts(151).amount := nvl(g_wlbi_amounts(151).amount,0) + wlbi_rec.a151;
      g_wlbi_amounts(152).amount := nvl(g_wlbi_amounts(152).amount,0) + wlbi_rec.a152;
      g_wlbi_amounts(153).amount := nvl(g_wlbi_amounts(153).amount,0) + wlbi_rec.a153;
      g_wlbi_amounts(154).amount := nvl(g_wlbi_amounts(154).amount,0) + wlbi_rec.a154;
      g_wlbi_amounts(155).amount := nvl(g_wlbi_amounts(155).amount,0) + wlbi_rec.a155;
      g_wlbi_amounts(156).amount := nvl(g_wlbi_amounts(156).amount,0) + wlbi_rec.a156;
      g_wlbi_amounts(157).amount := nvl(g_wlbi_amounts(157).amount,0) + wlbi_rec.a157;
      g_wlbi_amounts(158).amount := nvl(g_wlbi_amounts(158).amount,0) + wlbi_rec.a158;
      g_wlbi_amounts(159).amount := nvl(g_wlbi_amounts(159).amount,0) + wlbi_rec.a159;
      g_wlbi_amounts(160).amount := nvl(g_wlbi_amounts(160).amount,0) + wlbi_rec.a160;

      g_wlbi_amounts(161).amount := nvl(g_wlbi_amounts(161).amount,0) + wlbi_rec.a161;
      g_wlbi_amounts(162).amount := nvl(g_wlbi_amounts(162).amount,0) + wlbi_rec.a162;
      g_wlbi_amounts(163).amount := nvl(g_wlbi_amounts(163).amount,0) + wlbi_rec.a163;
      g_wlbi_amounts(164).amount := nvl(g_wlbi_amounts(164).amount,0) + wlbi_rec.a164;
      g_wlbi_amounts(165).amount := nvl(g_wlbi_amounts(165).amount,0) + wlbi_rec.a165;
      g_wlbi_amounts(166).amount := nvl(g_wlbi_amounts(166).amount,0) + wlbi_rec.a166;
      g_wlbi_amounts(167).amount := nvl(g_wlbi_amounts(167).amount,0) + wlbi_rec.a167;
      g_wlbi_amounts(168).amount := nvl(g_wlbi_amounts(168).amount,0) + wlbi_rec.a168;

      /*bug:6019074:start*/
      l_index := l_index + 1;

      g_wlbi_amounts_tbl(l_index).pay_element_id := wlbi_rec.pay_element_id;
      g_wlbi_amounts_tbl(l_index).pay_element_set_id := wlbi_rec.pay_element_set_id;
      g_wlbi_amounts_tbl(l_index).position_line_id := wlbi_rec.position_line_id;
      g_wlbi_amounts_tbl(l_index).code_combination_id := wlbi_rec.code_combination_id;
      g_wlbi_amounts_tbl(l_index).service_package_id := wlbi_rec.service_package_id;
      g_wlbi_amounts_tbl(l_index).service_package_name := wlbi_rec.service_package_name;
      g_wlbi_amounts_tbl(l_index).concatenated_account := wlbi_rec.concatenated_account;
      g_wlbi_amounts_tbl(l_index).salary_account_line := wlbi_rec.salary_account_line;

     END;
     /*bug:6019074:end*/
    end loop;

    /*bug:6019074: Populated l_element_set_tbl with the start and end indexes for
      each pay_element_set_id in g_wlbi_amounts_tbl. This helps in calculating
      period amounts and ytd amount*/

     IF g_wlbi_amounts_tbl.count>0 THEN
       for l_pos_index in 1..g_wlbi_amounts_tbl.count loop
         l_element_set_tbl.pay_element_set_id := g_wlbi_amounts_tbl(l_pos_index).pay_element_set_id;
         IF l_element_set_tbl.start_index IS NULL THEN
             l_element_set_tbl.start_index := l_pos_index;
         END IF;
         l_element_set_tbl.end_index := l_pos_index;
       end loop;
     END IF;
   /*bug:6019074:end*/

   /*bug:6019074:Made estimate years loop as an outer loop. This
     helps in calculating and storing the period amounts and ytd amounts
     for each estimate year.*/

    -- Estimate years pl/sql table is indexed by estimate year id
    l_year_index := g_estimate_years.FIRST;
    WHILE l_year_index IS NOT NULL
    LOOP

      l_account_line_id   := null;
      l_year_amount       := null;
      old_acct            := false;
      new_acct            := false;
      found_pos_acct_line := FALSE;

      FOR l_index in 1..PSB_WS_ACCT1.G_MAX_NUM_AMOUNTS LOOP
         l_period_amounts(l_index) := NULL;
      END LOOP;

     for l_index in l_element_set_tbl.start_index..l_element_set_tbl.end_index loop

      l_pay_element_id         := g_wlbi_amounts_tbl(l_index).pay_element_id;
      l_position_line_id       := g_wlbi_amounts_tbl(l_index).position_line_id;
      l_ccid                   := g_wlbi_amounts_tbl(l_index).code_combination_id;
      l_spid                   := g_wlbi_amounts_tbl(l_index).service_package_id;
      l_spname                 := g_wlbi_amounts_tbl(l_index).service_package_name;
      l_concatenated_account   := g_wlbi_amounts_tbl(l_index).concatenated_account;
      l_salary_account_line    := g_wlbi_amounts_tbl(l_index).salary_account_line;

      IF l_salary_account_line = 'N' THEN
         l_salary_account_line := FND_API.G_FALSE;
      END IF;

     /*bug:6019074:end*/

      -- Get the Element Set ID - Required for both old and new accounts
      found_element_set   := FALSE;

      Get_Element_Set_ID
      (
	p_pay_element_id      => l_pay_element_id,
	p_position_line_id    => l_position_line_id,
	p_element_set_id      => l_element_set_id,
	p_found_element_set   => found_element_set
      );

      IF not found_element_set THEN
	FND_MESSAGE.SET_NAME('PSB', 'PSB_INVALID_ELEMENT_SET');
	FND_MESSAGE.SET_TOKEN('PAY_ELEMENT_ID', l_pay_element_id );
	FND_MESSAGE.SET_TOKEN('POSITION_LINE_ID', l_position_line_id );
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR ;
      END IF;

      g_wlbi_amounts_tbl(l_index).old_acct := FALSE;
      g_wlbi_amounts_tbl(l_index).new_acct := FALSE;

      IF nvl(g_wlbi_amounts_tbl(l_index).code_combination_id,0) = 0 then
	g_wlbi_amounts_tbl(l_index).new_acct := TRUE;
      ELSE
	g_wlbi_amounts_tbl(l_index).old_acct := TRUE;
      END IF;

      validated_acct := FALSE;
      found_pos_acct_line := FALSE;
      l_budget_group_id := g_budget_group_id;

      l_create_follow_sal_acct := FALSE;


	-- Move the values to Update API's Input PL/SQL table
	l_period_index := 0;
        l_sum_period_amounts := 0;
        l_rounding_diff := 0;

	l_period_start_column := g_estimate_years(l_year_index).period_start_column;
	l_period_end_column   := g_estimate_years(l_year_index).period_end_column;

	l_year_total_column   := g_estimate_years(l_year_index).total_column;

	l_year_amount := nvl(g_wlbi_amounts(l_year_total_column).amount,0);
	l_element_set_tbl.ytd_amount := nvl(g_wlbi_amounts(l_year_total_column).amount,0);

	FOR l_wlbi_index IN l_period_start_column .. l_period_end_column
	LOOP
	  l_period_index := l_period_index +1 ;
          l_period_amounts(l_period_index) := nvl(g_wlbi_amounts(l_wlbi_index).amount ,0);
          l_sum_period_amounts := l_sum_period_amounts + l_period_amounts(l_period_index);

	END LOOP;

        /*bug:6019074:Rounding diff between 'sum of period amounts' to 'ytd amount'
         is adjusted in the last period */
       IF nvl(l_year_amount,0) <> nvl(l_sum_period_amounts,0) THEN
          l_rounding_diff := l_year_amount - l_sum_period_amounts;
          l_period_amounts(l_period_index) := nvl(l_period_amounts(l_period_index),0) + nvl(l_rounding_diff,0);
       END IF;
         /*bug:6019074:end*/
	-----

	IF g_wlbi_amounts_tbl(l_index).old_acct THEN
	  -- Find out Account Line Id based on key Ids

	  Get_Pos_Account_Line
	  (
	    p_worksheet_id        => g_worksheet_id,
	    p_ccid                => l_ccid,
	    p_spid                => l_spid,
	    p_position_line_id    => p_position_line_id,
	    p_budget_year_id      => l_year_index,
	    p_element_set_id      => g_wlbi_amounts_tbl(l_index).pay_element_set_id,
	    p_account_line_id     => l_element_set_tbl.account_line_id,
	    p_found_pos_acct_line => g_wlbi_amounts_tbl(l_index).found_pos_acct_line
	  );


	END IF; --old acct

      end loop; -- bug:6019074: --for l_index in l_element_set_tbl.start_index..l_element_rec.end_index loop

      /*bug:6019074:start*/
      for l_index in l_element_set_tbl.start_index..l_element_set_tbl.end_index loop
        IF g_wlbi_amounts_tbl(l_index).old_acct THEN
          old_acct := TRUE;
        else
          new_acct := TRUE;
        end if;

        if g_wlbi_amounts_tbl(l_index).found_pos_acct_line then
           found_pos_acct_line := TRUE;
        else
           found_pos_acct_line := FALSE;
        end if;

      end loop;

        l_account_line_id := l_element_set_tbl.account_line_id;
        l_year_amount     := l_element_set_tbl.ytd_amount;

      /*bug:6019074:end*/

	IF old_acct and found_pos_acct_line THEN

    /*start bug:6019074: STATEMENT level logging*/
   if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then

       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
      'PSB/EXPORT_EXCEL_TO_PSB/PSBVXL2B/Update_Distributions',
      'Before updating existing account line:'||l_account_line_id||' with ytd amount:'||l_year_amount);

      /*fnd_file.put_line(fnd_file.LOG,'Before updating existing account line:'||l_account_line_id||
                                     ' with ytd amount:'||l_year_amount);*/
   end if;
   /*end bug:6019074:end STATEMENT level log*/

	  PSB_WS_ACCT_PVT.Create_Account_Dist
	  (
	    p_api_version                 => 1.0,
	    p_init_msg_list               => FND_API.G_FALSE,
	    p_commit                      => FND_API.G_FALSE,
	    p_validation_level            => FND_API.G_VALID_LEVEL_FULL,
	    p_return_status               => l_return_status,
	    p_msg_count                   => l_msg_count,
	    p_msg_data                    => l_msg_data,
	    --
	    p_worksheet_id                => g_worksheet_id,
	    p_account_line_id             => l_account_line_id,
	    p_service_package_id          => l_spid,
	    p_ytd_amount                  => l_year_amount,
	    --
	    p_period_amount               => l_period_amounts
	  );

	  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR ;
	  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	  END IF;

	  IF ( l_salary_account_line = 'Y') THEN
	     l_create_follow_sal_acct := TRUE;
	  END IF;

	ELSIF (new_acct or ( old_acct and (not found_pos_acct_line) )
	    and   l_year_amount > 0 ) THEN
	  --Validate the Account
	  IF not validated_acct THEN
	    PSB_VALIDATE_ACCT_PVT.Validate_Account
	    (
	      p_api_version                =>    1.0,
	      p_init_msg_list              =>    FND_API.G_FALSE,
	      p_commit                     =>    FND_API.G_FALSE,
	      p_validation_level           =>    FND_API.G_VALID_LEVEL_FULL,
	      p_return_status              =>    l_return_status,
	      p_msg_count                  =>    l_msg_count,
	      p_msg_data                   =>    l_msg_data,
	      --
	      p_parent_budget_group_id     =>    g_budget_group_id,
	      p_startdate_pp               =>    g_pp_start_date,
	      p_enddate_cy                 =>    g_cy_end_date,
	      p_set_of_books_id            =>    g_set_of_books_id,
	      p_flex_code                  =>    g_chart_of_accounts_id,
	      p_create_budget_account      =>    FND_API.G_TRUE,
	      --
	      p_concatenated_segments      =>    l_concatenated_account,
	      --
	      p_worksheet_id               =>    g_global_worksheet_id,
	      p_in_ccid                    =>    FND_API.G_MISS_NUM,
	      p_out_ccid                   =>    va_ccid,
	      p_budget_group_id            =>    va_budget_group_id
	    );

	    IF  l_return_status =  FND_API.G_RET_STS_SUCCESS THEN
	      validated_acct := TRUE;
	      l_budget_group_id := va_budget_group_id;
	    ELSE
	      l_validation_status := FND_API.G_RET_STS_ERROR;
	      FND_MESSAGE.SET_NAME('PSB', 'PSB_INVALID_CC_SEG');
	      FND_MESSAGE.SET_TOKEN('CC', l_concatenated_account );
	      FND_MSG_PUB.Add;
	      RAISE FND_API.G_EXC_ERROR ;
	    END IF;

	  END IF; -- if not validated even once for the record

    /*start bug:6019074: STATEMENT level logging*/
   if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then

       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
      'PSB/EXPORT_EXCEL_TO_PSB/PSBVXL2B/Update_Distributions',
      'Before updating/creating account line with ytd amount:'||l_year_amount);

      /*fnd_file.put_line(fnd_file.LOG,'Before updating/creating account line with ytd amount:'||l_year_amount);
        fnd_file.put_line(fnd_file.LOG,'year processed:'||l_year_index);
      */
   end if;
   /*end bug:6019074:end STATEMENT level log*/

	  PSB_WS_ACCT_PVT.Create_Account_Dist
	  (
	    p_api_version                 => 1.0,
	    p_init_msg_list               => FND_API.G_FALSE,
	    p_commit                      => FND_API.G_FALSE,
	    p_validation_level            => FND_API.G_VALID_LEVEL_FULL,
	    p_return_status               => l_return_status,
	    p_msg_count                   => l_msg_count,
	    p_msg_data                    => l_msg_data,
	    --
	    p_account_line_id             => ca_account_line_id,
	    p_worksheet_id                => g_worksheet_id,
	    p_map_accounts                => TRUE,
	    p_budget_year_id              => l_year_index,
	    p_budget_group_id             => l_budget_group_id,
	    p_flex_code                   => g_chart_of_accounts_id,
	    p_concatenated_segments       => l_concatenated_account,
	    p_currency_code               => g_currency_code,
	    p_balance_type                => 'E',  -- Always Estimate
	    p_ytd_amount                  => l_year_amount,
	    p_distribute_flag             => FND_API.G_FALSE,
	    p_period_amount               => l_period_amounts,
	    p_service_package_id          => l_spid,
	    p_position_line_id            => p_position_line_id,
	    p_element_set_id              => p_pay_element_set_id,
	    p_salary_account_line         => l_salary_account_line

	  );


	  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR ;
	  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	  END IF;

	  IF ( l_salary_account_line = 'Y') AND
	     ( nvl(ca_account_line_id,0) <> 0 )  THEN
	     l_create_follow_sal_acct := TRUE;
	  END IF;


	END IF; --old_acct or (new_acct and valid_acct)
	l_year_index:=  g_estimate_years.NEXT(l_year_index);
      END LOOP; --for each estimate year

      -- Call this API only once per record
      IF l_create_follow_sal_acct THEN

	PSB_WS_POSITION_RFS_PVT.Redistribute_Follow_Salary
	(
	    p_api_version                 => 1.0,
	    p_init_msg_list               => FND_API.G_FALSE,
	    p_commit                      => FND_API.G_FALSE,
	    p_validation_level            => FND_API.G_VALID_LEVEL_FULL,
	    p_return_status               => l_return_status,
	    p_msg_count                   => l_msg_count,
	    p_msg_data                    => l_msg_data,
	    --
	    p_worksheet_id                => g_worksheet_id,
	    p_position_line_id            => p_position_line_id,
	    p_service_package_id          => l_spid,
	    p_stage_set_id                => g_stage_set_id
	);

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  RAISE FND_API.G_EXC_ERROR ;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	END IF;

      END IF; --create follow salary acct(called both on insert and update)

    IF l_validation_status = FND_API.G_RET_STS_ERROR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
    ELSE
      p_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;

  EXCEPTION

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END Update_Distributions;



  PROCEDURE Get_Element_Set_ID
  (
    p_pay_element_id        IN  NUMBER,
    p_position_line_id      IN  NUMBER,
    p_element_set_id        OUT  NOCOPY NUMBER,
    p_found_element_set     OUT  NOCOPY BOOLEAN
  )
  IS
    cursor elem_line_cur is
    SELECT element_set_id
    FROM psb_ws_element_lines
    WHERE position_line_id = p_position_line_id
    AND   pay_element_id =  p_pay_element_id
    AND   end_stage_seq is null;

    l_element_set_id NUMBER;
  BEGIN
    p_found_element_set := FALSE;
    OPEN elem_line_cur;
    FETCH elem_line_cur INTO l_element_set_id;
    IF elem_line_cur%FOUND THEN
      p_element_set_id := l_element_set_id;
      p_found_element_set  := TRUE;
    END IF;
    CLOSE elem_line_cur;

  END Get_Element_Set_ID;

-- Find out Account Line Id based on key Ids
  PROCEDURE Get_Pos_Account_Line
  (
    p_worksheet_id          IN NUMBER,
    p_ccid                  IN NUMBER,
    p_spid                  IN NUMBER,
    p_position_line_id      IN NUMBER,
    p_budget_year_id        IN NUMBER,
    p_element_set_id        IN NUMBER,
    p_account_line_id       OUT  NOCOPY NUMBER,
    p_found_pos_acct_line   OUT  NOCOPY BOOLEAN
  )
  IS


    cursor wal_cur is
    SELECT wal.account_line_id
    FROM   psb_ws_account_lines wal,
	  psb_ws_lines wl
    WHERE  wl.worksheet_id = p_worksheet_id
    AND    wl.account_line_id = wal.account_line_id
    AND    wal.position_line_id = p_position_line_id
    AND    wal.code_combination_id = p_ccid
    AND    wal.service_package_id = p_spid
    AND    wal.budget_year_id = p_budget_year_id
    AND    wal.end_stage_seq is null
    AND    wal.element_set_id = p_element_set_id;

    Recinfo   wal_cur%ROWTYPE;

  BEGIN
    -- First get Element Set Id based on the Pay element id
    p_found_pos_acct_line := FALSE;
    p_account_line_id := 0;
    OPEN wal_cur;
    FETCH wal_cur INTO Recinfo;
    IF wal_cur%FOUND THEN
      p_found_pos_acct_line := TRUE;
      p_account_line_id := Recinfo.account_line_id;
    END IF;
    CLOSE wal_cur;
  END Get_Pos_Account_Line;


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

   cursor c_Attribute_Assignments is
   select worksheet_id,
	   effective_start_date,
	   effective_end_date,
	   attribute_id,
           -- Fixed Bug # 3683644
	   FND_NUMBER.canonical_to_number(attribute_value) attribute_value
      from PSB_POSITION_ASSIGNMENTS
     where attribute_id = PSB_WS_POS1.g_default_wklyhrs_id
       and (worksheet_id is null or worksheet_id = g_global_worksheet_id)
       and assignment_type = 'ATTRIBUTE'
       and (((effective_start_date <= l_end_date)
	 and (effective_end_date is null))
	 or ((effective_start_date between l_start_date and l_end_date)
	  or (effective_end_date between l_start_date and l_end_date)
	 or ((effective_start_date < l_start_date)
	 and (effective_end_date > l_end_date))))
       and position_id = l_position_id
     order by worksheet_id,
	      effective_start_date,
	      effective_end_date,
	      FND_NUMBER.canonical_to_number(attribute_value) desc; -- Fixed Bug # 3683644

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

  for l_init_index in 1..g_poswkh_assignments.Count loop
    g_poswkh_assignments(l_init_index).worksheet_id := null;
    g_poswkh_assignments(l_init_index).start_date := null;
    g_poswkh_assignments(l_init_index).end_date := null;
    g_poswkh_assignments(l_init_index).default_weekly_hours := null;
  end loop;

  g_num_poswkh_assignments := 0;

  PSB_WS_POS1.Cache_Named_Attribute_Values
     (p_return_status => l_return_status,
      p_worksheet_id => g_global_worksheet_id,
      p_data_extract_id => g_data_extract_id,
      p_position_id => l_position_id);


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


  for c_Attributes_Rec in c_Attribute_Assignments loop

      g_num_poswkh_assignments := g_num_poswkh_assignments + 1;

      g_poswkh_assignments(g_num_poswkh_assignments).worksheet_id := c_Attributes_Rec.worksheet_id;
      g_poswkh_assignments(g_num_poswkh_assignments).start_date := c_Attributes_Rec.effective_start_date;
      g_poswkh_assignments(g_num_poswkh_assignments).end_date := c_Attributes_Rec.effective_end_date;
      g_poswkh_assignments(g_num_poswkh_assignments).default_weekly_hours := c_Attributes_Rec.attribute_value;

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


  PROCEDURE Update_Assignments
  ( p_return_status    OUT  NOCOPY VARCHAR2,
    p_position_line_id IN NUMBER
  )
  IS

    l_return_status VARCHAR2(1);
    l_wal_element_cost  NUMBER;
    l_wlbi_element_cost NUMBER;
    i BINARY_INTEGER;

    l_position_id           NUMBER;
    l_position_name         VARCHAR2(1000);
    l_position_start_date   DATE;
    l_position_end_date     DATE;
    l_start_date            DATE;
    l_end_date              DATE;
    l_pay_element_id        NUMBER;
    l_element_set_id        NUMBER;
    found_element_set  BOOLEAN := FALSE;
    l_element_cost_update_reqd BOOLEAN := FALSE;

    cursor c_Positions is
    select a.position_id,
	   a.name,
	   a.effective_start_date,
	   a.effective_end_date
      from PSB_POSITIONS a,
	   PSB_WS_POSITION_LINES b
     where a.position_id = b.position_id
       and b.position_line_id = p_position_line_id;

  BEGIN

  for c_Positions_Rec in c_Positions loop
    l_position_id := c_Positions_Rec.position_id;
    l_position_name := c_Positions_Rec.name;
    l_position_start_date := c_Positions_Rec.effective_start_date;
    l_position_end_date := c_Positions_Rec.effective_end_date;
  end loop;

    -- this assumes the budget calendar is cached
  l_start_date := greatest(PSB_WS_ACCT1.g_startdate_cy, l_position_start_date);
  l_end_date := least(PSB_WS_ACCT1.g_end_est_date,
			nvl(l_position_end_date, PSB_WS_ACCT1.g_end_est_date));

  -- Get the postion data in PL/SQL tables for the effective date
  Cache_Position_Data(p_return_status    => l_return_status,
		      p_position_line_id => p_position_line_id,
		      p_position_id      => l_position_id,
		      p_start_date       => l_start_date,
		      p_end_date         => l_end_date);


  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
     raise FND_API.G_EXC_ERROR;
  end if;


  --Outer loop (element_rec) created to get rid of group by operation
  --which led to sort key too long Oracle error when
  --the used columns were increased from 168 to 192

  FOR element_rec IN
      (
      SELECT distinct pay_element_id
      FROM  psb_ws_line_balances_i
      WHERE position_line_id = p_position_line_id
      AND  export_worksheet_type = 'P'
      AND  export_id = g_export_id
      )
  LOOP
    l_pay_element_id := element_rec.pay_element_id;

    -- Get the Element Set ID
    found_element_set   := FALSE;
    Get_Element_Set_ID
    (
     p_pay_element_id      => l_pay_element_id,
     p_position_line_id    => p_position_line_id,
     p_element_set_id      => l_element_set_id,
     p_found_element_set   => found_element_set
    );

    IF not found_element_set THEN
      FND_MESSAGE.SET_NAME('PSB', 'PSB_INVALID_ELEMENT_SET');
      FND_MESSAGE.SET_TOKEN('PAY_ELEMENT_ID', l_pay_element_id );
      FND_MESSAGE.SET_TOKEN('POSITION_LINE_ID', p_position_line_id );
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR ;
    END IF;

    -- For each pay element
    FOR  element_total_rec IN
      (
      SELECT
	SUM(AMOUNT1) a1,SUM(AMOUNT2) a2,SUM(AMOUNT3) a3,SUM(AMOUNT4) a4,SUM(AMOUNT5) a5,
	SUM(AMOUNT6) a6,SUM(AMOUNT7) a7,SUM(AMOUNT8) a8,SUM(AMOUNT9) a9,SUM(AMOUNT10) a10,
	SUM(AMOUNT11) a11,SUM(AMOUNT12) a12,SUM(AMOUNT13) a13,SUM(AMOUNT14) a14,SUM(AMOUNT15) a15,
	SUM(AMOUNT16) a16,SUM(AMOUNT17) a17,SUM(AMOUNT18) a18,SUM(AMOUNT19) a19,SUM(AMOUNT20) a20,
	SUM(AMOUNT21) a21,SUM(AMOUNT22) a22,SUM(AMOUNT23) a23,SUM(AMOUNT24) a24,SUM(AMOUNT25) a25,
	SUM(AMOUNT26) a26,SUM(AMOUNT27) a27,SUM(AMOUNT28) a28,SUM(AMOUNT29) a29,SUM(AMOUNT30) a30,
	SUM(AMOUNT31) a31,SUM(AMOUNT32) a32,SUM(AMOUNT33) a33,SUM(AMOUNT34) a34,SUM(AMOUNT35) a35,
	SUM(AMOUNT36) a36,SUM(AMOUNT37) a37,SUM(AMOUNT38) a38,SUM(AMOUNT39) a39,SUM(AMOUNT40) a40,
	SUM(AMOUNT41) a41,SUM(AMOUNT42) a42,SUM(AMOUNT43) a43,SUM(AMOUNT44) a44,SUM(AMOUNT45) a45,
	SUM(AMOUNT46) a46,SUM(AMOUNT47) a47,SUM(AMOUNT48) a48,SUM(AMOUNT49) a49,SUM(AMOUNT50) a50,
	SUM(AMOUNT51) a51,SUM(AMOUNT52) a52,SUM(AMOUNT53) a53,SUM(AMOUNT54) a54,SUM(AMOUNT55) a55,
	SUM(AMOUNT56) a56,SUM(AMOUNT57) a57,SUM(AMOUNT58) a58,SUM(AMOUNT59) a59,SUM(AMOUNT60) a60,
	SUM(AMOUNT61) a61,SUM(AMOUNT62) a62,SUM(AMOUNT63) a63,SUM(AMOUNT64) a64,SUM(AMOUNT65) a65,
	SUM(AMOUNT66) a66,SUM(AMOUNT67) a67,SUM(AMOUNT68) a68,SUM(AMOUNT69) a69,SUM(AMOUNT70) a70,
	SUM(AMOUNT71) a71,SUM(AMOUNT72) a72,SUM(AMOUNT73) a73,SUM(AMOUNT74) a74,SUM(AMOUNT75) a75,
	SUM(AMOUNT76) a76,SUM(AMOUNT77) a77,SUM(AMOUNT78) a78,SUM(AMOUNT79) a79,SUM(AMOUNT80) a80,
	SUM(AMOUNT81) a81,SUM(AMOUNT82) a82,SUM(AMOUNT83) a83,SUM(AMOUNT84) a84,SUM(AMOUNT85) a85,
	SUM(AMOUNT86) a86,SUM(AMOUNT87) a87,SUM(AMOUNT88) a88,SUM(AMOUNT89) a89,SUM(AMOUNT90) a90,
	SUM(AMOUNT91) a91,SUM(AMOUNT92) a92,SUM(AMOUNT93) a93,SUM(AMOUNT94) a94,SUM(AMOUNT95) a95,
	SUM(AMOUNT96) a96,SUM(AMOUNT97) a97,SUM(AMOUNT98) a98,SUM(AMOUNT99) a99,SUM(AMOUNT100) a100,
	SUM(AMOUNT101) a101,SUM(AMOUNT102) a102,SUM(AMOUNT103) a103,SUM(AMOUNT104) a104,SUM(AMOUNT105) a105,
	SUM(AMOUNT106) a106,SUM(AMOUNT107) a107,SUM(AMOUNT108) a108,SUM(AMOUNT109) a109,SUM(AMOUNT110) a110,
	SUM(AMOUNT111) a111,SUM(AMOUNT112) a112,SUM(AMOUNT113) a113,SUM(AMOUNT114) a114,SUM(AMOUNT115) a115,
	SUM(AMOUNT116) a116,SUM(AMOUNT117) a117,SUM(AMOUNT118) a118,SUM(AMOUNT119) a119,SUM(AMOUNT120) a120,
	SUM(AMOUNT121) a121,SUM(AMOUNT122) a122,SUM(AMOUNT123) a123,SUM(AMOUNT124) a124,SUM(AMOUNT125) a125,
	SUM(AMOUNT126) a126,SUM(AMOUNT127) a127,SUM(AMOUNT128) a128,SUM(AMOUNT129) a129,SUM(AMOUNT130) a130,
	SUM(AMOUNT131) a131,SUM(AMOUNT132) a132,SUM(AMOUNT133) a133,SUM(AMOUNT134) a134,SUM(AMOUNT135) a135,
	SUM(AMOUNT136) a136,SUM(AMOUNT137) a137,SUM(AMOUNT138) a138,SUM(AMOUNT139) a139,SUM(AMOUNT140) a140,
	SUM(AMOUNT141) a141,SUM(AMOUNT142) a142,SUM(AMOUNT143) a143,SUM(AMOUNT144) a144,SUM(AMOUNT145) a145,
	SUM(AMOUNT146) a146,SUM(AMOUNT147) a147,SUM(AMOUNT148) a148,SUM(AMOUNT149) a149,SUM(AMOUNT150) a150,
	SUM(AMOUNT151) a151,SUM(AMOUNT152) a152,SUM(AMOUNT153) a153,SUM(AMOUNT154) a154,SUM(AMOUNT155) a155,
	SUM(AMOUNT156) a156,SUM(AMOUNT157) a157,SUM(AMOUNT158) a158,SUM(AMOUNT159) a159,SUM(AMOUNT160) a160,
	SUM(AMOUNT161) a161,SUM(AMOUNT162) a162,SUM(AMOUNT163) a163,SUM(AMOUNT164) a164,SUM(AMOUNT165) a165,
	SUM(AMOUNT166) a166,SUM(AMOUNT167) a167,SUM(AMOUNT168) a168
      FROM  psb_ws_line_balances_i
      WHERE position_line_id = p_position_line_id
      AND  export_worksheet_type = 'P'
      AND  export_id = g_export_id
      /* For Bug No. 2378123 : Start */
      -- AND  ( percent_of_salary_flag = 'N'  or value_type = 'P' )
      AND  value_type = 'A'
      /* For Bug No. 2378123 : End */
      AND  pay_element_id = l_pay_element_id  )
    LOOP

      -- Move the Amounts to PL/SQL table
      g_wlbi_amounts(1).amount := element_total_rec.a1;
      g_wlbi_amounts(2).amount := element_total_rec.a2;
      g_wlbi_amounts(3).amount := element_total_rec.a3;
      g_wlbi_amounts(4).amount := element_total_rec.a4;
      g_wlbi_amounts(5).amount := element_total_rec.a5;
      g_wlbi_amounts(6).amount := element_total_rec.a6;
      g_wlbi_amounts(7).amount := element_total_rec.a7;
      g_wlbi_amounts(8).amount := element_total_rec.a8;
      g_wlbi_amounts(9).amount := element_total_rec.a9;
      g_wlbi_amounts(10).amount := element_total_rec.a10;

      g_wlbi_amounts(11).amount := element_total_rec.a11;
      g_wlbi_amounts(12).amount := element_total_rec.a12;
      g_wlbi_amounts(13).amount := element_total_rec.a13;
      g_wlbi_amounts(14).amount := element_total_rec.a14;
      g_wlbi_amounts(15).amount := element_total_rec.a15;
      g_wlbi_amounts(16).amount := element_total_rec.a16;
      g_wlbi_amounts(17).amount := element_total_rec.a17;
      g_wlbi_amounts(18).amount := element_total_rec.a18;
      g_wlbi_amounts(19).amount := element_total_rec.a19;
      g_wlbi_amounts(20).amount := element_total_rec.a20;

      g_wlbi_amounts(21).amount := element_total_rec.a21;
      g_wlbi_amounts(22).amount := element_total_rec.a22;
      g_wlbi_amounts(23).amount := element_total_rec.a23;
      g_wlbi_amounts(24).amount := element_total_rec.a24;
      g_wlbi_amounts(25).amount := element_total_rec.a25;
      g_wlbi_amounts(26).amount := element_total_rec.a26;
      g_wlbi_amounts(27).amount := element_total_rec.a27;
      g_wlbi_amounts(28).amount := element_total_rec.a28;
      g_wlbi_amounts(29).amount := element_total_rec.a29;
      g_wlbi_amounts(30).amount := element_total_rec.a30;

      g_wlbi_amounts(31).amount := element_total_rec.a31;
      g_wlbi_amounts(32).amount := element_total_rec.a32;
      g_wlbi_amounts(33).amount := element_total_rec.a33;
      g_wlbi_amounts(34).amount := element_total_rec.a34;
      g_wlbi_amounts(35).amount := element_total_rec.a35;
      g_wlbi_amounts(36).amount := element_total_rec.a36;
      g_wlbi_amounts(37).amount := element_total_rec.a37;
      g_wlbi_amounts(38).amount := element_total_rec.a38;
      g_wlbi_amounts(39).amount := element_total_rec.a39;
      g_wlbi_amounts(40).amount := element_total_rec.a40;

      g_wlbi_amounts(41).amount := element_total_rec.a41;
      g_wlbi_amounts(42).amount := element_total_rec.a42;
      g_wlbi_amounts(43).amount := element_total_rec.a43;
      g_wlbi_amounts(44).amount := element_total_rec.a44;
      g_wlbi_amounts(45).amount := element_total_rec.a45;
      g_wlbi_amounts(46).amount := element_total_rec.a46;
      g_wlbi_amounts(47).amount := element_total_rec.a47;
      g_wlbi_amounts(48).amount := element_total_rec.a48;
      g_wlbi_amounts(49).amount := element_total_rec.a49;
      g_wlbi_amounts(50).amount := element_total_rec.a50;

      g_wlbi_amounts(51).amount := element_total_rec.a51;
      g_wlbi_amounts(52).amount := element_total_rec.a52;
      g_wlbi_amounts(53).amount := element_total_rec.a53;
      g_wlbi_amounts(54).amount := element_total_rec.a54;
      g_wlbi_amounts(55).amount := element_total_rec.a55;
      g_wlbi_amounts(56).amount := element_total_rec.a56;
      g_wlbi_amounts(57).amount := element_total_rec.a57;
      g_wlbi_amounts(58).amount := element_total_rec.a58;
      g_wlbi_amounts(59).amount := element_total_rec.a59;
      g_wlbi_amounts(60).amount := element_total_rec.a60;

      g_wlbi_amounts(61).amount := element_total_rec.a61;
      g_wlbi_amounts(62).amount := element_total_rec.a62;
      g_wlbi_amounts(63).amount := element_total_rec.a63;
      g_wlbi_amounts(64).amount := element_total_rec.a64;
      g_wlbi_amounts(65).amount := element_total_rec.a65;
      g_wlbi_amounts(66).amount := element_total_rec.a66;
      g_wlbi_amounts(67).amount := element_total_rec.a67;
      g_wlbi_amounts(68).amount := element_total_rec.a68;
      g_wlbi_amounts(69).amount := element_total_rec.a69;
      g_wlbi_amounts(70).amount := element_total_rec.a70;

      g_wlbi_amounts(71).amount := element_total_rec.a71;
      g_wlbi_amounts(72).amount := element_total_rec.a72;
      g_wlbi_amounts(73).amount := element_total_rec.a73;
      g_wlbi_amounts(74).amount := element_total_rec.a74;
      g_wlbi_amounts(75).amount := element_total_rec.a75;
      g_wlbi_amounts(76).amount := element_total_rec.a76;
      g_wlbi_amounts(77).amount := element_total_rec.a77;
      g_wlbi_amounts(78).amount := element_total_rec.a78;
      g_wlbi_amounts(79).amount := element_total_rec.a79;
      g_wlbi_amounts(80).amount := element_total_rec.a80;

      g_wlbi_amounts(81).amount := element_total_rec.a81;
      g_wlbi_amounts(82).amount := element_total_rec.a82;
      g_wlbi_amounts(83).amount := element_total_rec.a83;
      g_wlbi_amounts(84).amount := element_total_rec.a84;
      g_wlbi_amounts(85).amount := element_total_rec.a85;
      g_wlbi_amounts(86).amount := element_total_rec.a86;
      g_wlbi_amounts(87).amount := element_total_rec.a87;
      g_wlbi_amounts(88).amount := element_total_rec.a88;
      g_wlbi_amounts(89).amount := element_total_rec.a89;
      g_wlbi_amounts(90).amount := element_total_rec.a90;

      g_wlbi_amounts(91).amount := element_total_rec.a91;
      g_wlbi_amounts(92).amount := element_total_rec.a92;
      g_wlbi_amounts(93).amount := element_total_rec.a93;
      g_wlbi_amounts(94).amount := element_total_rec.a94;
      g_wlbi_amounts(95).amount := element_total_rec.a95;
      g_wlbi_amounts(96).amount := element_total_rec.a96;
      g_wlbi_amounts(97).amount := element_total_rec.a97;
      g_wlbi_amounts(98).amount := element_total_rec.a98;
      g_wlbi_amounts(99).amount := element_total_rec.a99;
      g_wlbi_amounts(100).amount := element_total_rec.a100;

      g_wlbi_amounts(101).amount := element_total_rec.a101;
      g_wlbi_amounts(102).amount := element_total_rec.a102;
      g_wlbi_amounts(103).amount := element_total_rec.a103;
      g_wlbi_amounts(104).amount := element_total_rec.a104;
      g_wlbi_amounts(105).amount := element_total_rec.a105;
      g_wlbi_amounts(106).amount := element_total_rec.a106;
      g_wlbi_amounts(107).amount := element_total_rec.a107;
      g_wlbi_amounts(108).amount := element_total_rec.a108;
      g_wlbi_amounts(109).amount := element_total_rec.a109;
      g_wlbi_amounts(110).amount := element_total_rec.a110;

      g_wlbi_amounts(111).amount := element_total_rec.a111;
      g_wlbi_amounts(112).amount := element_total_rec.a112;
      g_wlbi_amounts(113).amount := element_total_rec.a113;
      g_wlbi_amounts(114).amount := element_total_rec.a114;
      g_wlbi_amounts(115).amount := element_total_rec.a115;
      g_wlbi_amounts(116).amount := element_total_rec.a116;
      g_wlbi_amounts(117).amount := element_total_rec.a117;
      g_wlbi_amounts(118).amount := element_total_rec.a118;
      g_wlbi_amounts(119).amount := element_total_rec.a119;
      g_wlbi_amounts(120).amount := element_total_rec.a120;

      g_wlbi_amounts(121).amount := element_total_rec.a121;
      g_wlbi_amounts(122).amount := element_total_rec.a122;
      g_wlbi_amounts(123).amount := element_total_rec.a123;
      g_wlbi_amounts(124).amount := element_total_rec.a124;
      g_wlbi_amounts(125).amount := element_total_rec.a125;
      g_wlbi_amounts(126).amount := element_total_rec.a126;
      g_wlbi_amounts(127).amount := element_total_rec.a127;
      g_wlbi_amounts(128).amount := element_total_rec.a128;
      g_wlbi_amounts(129).amount := element_total_rec.a129;
      g_wlbi_amounts(130).amount := element_total_rec.a130;

      g_wlbi_amounts(131).amount := element_total_rec.a131;
      g_wlbi_amounts(132).amount := element_total_rec.a132;
      g_wlbi_amounts(133).amount := element_total_rec.a133;
      g_wlbi_amounts(134).amount := element_total_rec.a134;
      g_wlbi_amounts(135).amount := element_total_rec.a135;
      g_wlbi_amounts(136).amount := element_total_rec.a136;
      g_wlbi_amounts(137).amount := element_total_rec.a137;
      g_wlbi_amounts(138).amount := element_total_rec.a138;
      g_wlbi_amounts(139).amount := element_total_rec.a139;
      g_wlbi_amounts(140).amount := element_total_rec.a140;

      g_wlbi_amounts(141).amount := element_total_rec.a141;
      g_wlbi_amounts(142).amount := element_total_rec.a142;
      g_wlbi_amounts(143).amount := element_total_rec.a143;
      g_wlbi_amounts(144).amount := element_total_rec.a144;
      g_wlbi_amounts(145).amount := element_total_rec.a145;
      g_wlbi_amounts(146).amount := element_total_rec.a146;
      g_wlbi_amounts(147).amount := element_total_rec.a147;
      g_wlbi_amounts(148).amount := element_total_rec.a148;
      g_wlbi_amounts(149).amount := element_total_rec.a149;
      g_wlbi_amounts(150).amount := element_total_rec.a150;

      g_wlbi_amounts(151).amount := element_total_rec.a151;
      g_wlbi_amounts(152).amount := element_total_rec.a152;
      g_wlbi_amounts(153).amount := element_total_rec.a153;
      g_wlbi_amounts(154).amount := element_total_rec.a154;
      g_wlbi_amounts(155).amount := element_total_rec.a155;
      g_wlbi_amounts(156).amount := element_total_rec.a156;
      g_wlbi_amounts(157).amount := element_total_rec.a157;
      g_wlbi_amounts(158).amount := element_total_rec.a158;
      g_wlbi_amounts(159).amount := element_total_rec.a159;
      g_wlbi_amounts(160).amount := element_total_rec.a160;

      g_wlbi_amounts(161).amount := element_total_rec.a161;
      g_wlbi_amounts(162).amount := element_total_rec.a162;
      g_wlbi_amounts(163).amount := element_total_rec.a163;
      g_wlbi_amounts(164).amount := element_total_rec.a164;
      g_wlbi_amounts(165).amount := element_total_rec.a165;
      g_wlbi_amounts(166).amount := element_total_rec.a166;
      g_wlbi_amounts(167).amount := element_total_rec.a167;
      g_wlbi_amounts(168).amount := element_total_rec.a168;


      -- For each estimate get the element costs and check if there is
      -- any difference

      -- Estimate years pl/sql table is indexed by estimate year id

      l_element_cost_update_reqd := FALSE;
      i := g_estimate_years.FIRST;
      WHILE i IS NOT NULL
      LOOP

	Get_WAL_Element_Cost
	 (p_position_line_id  => p_position_line_id,
	  p_element_set_id    => l_element_set_id,
	  p_budget_year_id    => i,
  	  p_pay_element_id    => l_pay_element_id,   --bug:6019074
	  p_wal_element_cost  => l_wal_element_cost
	 );

	Get_WLBI_Element_Cost
	 (p_budget_year_id     => i,
	  p_wlbi_element_cost  => l_wlbi_element_cost
	 );
	--debug('Bud year id :'||i);
	--debug('elsid:'||l_element_set_id);
	--debug('WALC :'||l_wal_element_cost||' WLBIC'||l_wlbi_element_cost);

	/* For Bug No. 2461802 : Start */
	-- IF l_wal_element_cost <> l_wlbi_element_cost THEN
	IF ABS(round(l_wal_element_cost) - round(l_wlbi_element_cost)) > 1 THEN
	/* For Bug No. 2461802 : End */

	  -- Init Assignment Table
	  for l_assignment_index in 1..g_assignment.COUNT loop
	    g_assignment(l_assignment_index).period := null;
	    g_assignment(l_assignment_index).new_amount := null;
	  end loop;

	  -- Get the new assignments in a PL/SQL table
	  Get_New_Assignments(p_budget_year_id   => i);  -- in a PL/SQL table

	  Get_FTE
	  ( p_position_line_id => p_position_line_id,
	    p_budget_year_id => i
	  );

	  fnd_file.put_line(fnd_file.LOG,'before calling Change_Pos_Year_Assignments'||
                                         ' For p_position_line_id:'||p_position_line_id||
	                                 ' position name:'||l_position_name||
	                                 ' pay_element_id:'||element_rec.pay_element_id||
	                                 ' l_wal_element_cost:'||l_wal_element_cost||
	                                 ' l_wlbi_element_cost:'||l_wlbi_element_cost); --bug:6019074:log

	  -- Call assignment API
	  Change_Pos_Year_Assignments
	  ( p_return_status               => l_return_status,
	    p_worksheet_id                => g_worksheet_id,
	    p_budget_calendar_id          => g_budget_calendar_id,
	    p_data_extract_id             => g_data_extract_id,
	    p_business_group_id           => g_business_group_id,
	    p_position_line_id            => p_position_line_id,
	    p_position_id                 => l_position_id,
	    p_position_name               => l_position_name,
	    p_pay_element_id              => element_rec.pay_element_id,
	    p_amt_tolerance_value_type    => g_amt_tolerance_value_type,
	    p_amt_tolerance_value         => g_amt_tolerance_value,
	    p_pct_tolerance_value_type    => g_pct_tolerance_value_type ,
	    p_pct_tolerance_value         => g_pct_tolerance_value,
	    p_budget_year_id              => i,
	    p_assignments                 => g_assignment
	  );


	  -- Change_Position_Assignments; -- Assignment API
	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	       raise FND_API.G_EXC_ERROR;
	  end if;

	  l_element_cost_update_reqd := TRUE;

	END IF;

	i:=  g_estimate_years.NEXT(i);
      END LOOP; --for each estimate year

      --Update_Element Costs
      IF l_element_cost_update_reqd THEN

	Change_Element_Cost
	( p_return_status               => l_return_status,
	  p_position_line_id            => p_position_line_id,
	  p_pay_element_id              => element_rec.pay_element_id,
	  p_element_set_id              => l_element_set_id
	);
      END IF;

    END LOOP; --for each element total in a position
  END LOOP; --for each element in a position (added later to avoid group by operation)

  p_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END Update_Assignments;


  PROCEDURE Change_Element_Cost
  ( p_return_status      OUT  NOCOPY VARCHAR2,
    p_position_line_id   IN NUMBER,
    p_pay_element_id     IN NUMBER,
    p_element_set_id     IN NUMBER
  )
  IS

    l_msg_count  NUMBER;
    l_msg_data   VARCHAR2(2000);
    l_return_status VARCHAR2(1);
    i BINARY_INTEGER;
    l_service_package_id NUMBER;
    l_wlbi_sp_element_cost NUMBER;
    l_found_element_line  BOOLEAN;
    l_element_line_id NUMBER;

  BEGIN

  FOR sp_rec IN
   ( select distinct service_package_id
      from psb_ws_line_balances_i
      where export_id = g_export_id
      and export_worksheet_type = 'P'
      and position_line_id = p_position_line_id
      and pay_element_id = p_pay_element_id
    )
  LOOP


    l_service_package_id := sp_rec.service_package_id;
    FOR  sp_element_cost_rec IN
    (
     SELECT
	SUM(AMOUNT1) a1,SUM(AMOUNT2) a2,SUM(AMOUNT3) a3,SUM(AMOUNT4) a4,SUM(AMOUNT5) a5,
	SUM(AMOUNT6) a6,SUM(AMOUNT7) a7,SUM(AMOUNT8) a8,SUM(AMOUNT9) a9,SUM(AMOUNT10) a10,
	SUM(AMOUNT11) a11,SUM(AMOUNT12) a12,SUM(AMOUNT13) a13,SUM(AMOUNT14) a14,SUM(AMOUNT15) a15,
	SUM(AMOUNT16) a16,SUM(AMOUNT17) a17,SUM(AMOUNT18) a18,SUM(AMOUNT19) a19,SUM(AMOUNT20) a20,
	SUM(AMOUNT21) a21,SUM(AMOUNT22) a22,SUM(AMOUNT23) a23,SUM(AMOUNT24) a24,SUM(AMOUNT25) a25,
	SUM(AMOUNT26) a26,SUM(AMOUNT27) a27,SUM(AMOUNT28) a28,SUM(AMOUNT29) a29,SUM(AMOUNT30) a30,
	SUM(AMOUNT31) a31,SUM(AMOUNT32) a32,SUM(AMOUNT33) a33,SUM(AMOUNT34) a34,SUM(AMOUNT35) a35,
	SUM(AMOUNT36) a36,SUM(AMOUNT37) a37,SUM(AMOUNT38) a38,SUM(AMOUNT39) a39,SUM(AMOUNT40) a40,
	SUM(AMOUNT41) a41,SUM(AMOUNT42) a42,SUM(AMOUNT43) a43,SUM(AMOUNT44) a44,SUM(AMOUNT45) a45,
	SUM(AMOUNT46) a46,SUM(AMOUNT47) a47,SUM(AMOUNT48) a48,SUM(AMOUNT49) a49,SUM(AMOUNT50) a50,
	SUM(AMOUNT51) a51,SUM(AMOUNT52) a52,SUM(AMOUNT53) a53,SUM(AMOUNT54) a54,SUM(AMOUNT55) a55,
	SUM(AMOUNT56) a56,SUM(AMOUNT57) a57,SUM(AMOUNT58) a58,SUM(AMOUNT59) a59,SUM(AMOUNT60) a60,
	SUM(AMOUNT61) a61,SUM(AMOUNT62) a62,SUM(AMOUNT63) a63,SUM(AMOUNT64) a64,SUM(AMOUNT65) a65,
	SUM(AMOUNT66) a66,SUM(AMOUNT67) a67,SUM(AMOUNT68) a68,SUM(AMOUNT69) a69,SUM(AMOUNT70) a70,
	SUM(AMOUNT71) a71,SUM(AMOUNT72) a72,SUM(AMOUNT73) a73,SUM(AMOUNT74) a74,SUM(AMOUNT75) a75,
	SUM(AMOUNT76) a76,SUM(AMOUNT77) a77,SUM(AMOUNT78) a78,SUM(AMOUNT79) a79,SUM(AMOUNT80) a80,
	SUM(AMOUNT81) a81,SUM(AMOUNT82) a82,SUM(AMOUNT83) a83,SUM(AMOUNT84) a84,SUM(AMOUNT85) a85,
	SUM(AMOUNT86) a86,SUM(AMOUNT87) a87,SUM(AMOUNT88) a88,SUM(AMOUNT89) a89,SUM(AMOUNT90) a90,
	SUM(AMOUNT91) a91,SUM(AMOUNT92) a92,SUM(AMOUNT93) a93,SUM(AMOUNT94) a94,SUM(AMOUNT95) a95,
	SUM(AMOUNT96) a96,SUM(AMOUNT97) a97,SUM(AMOUNT98) a98,SUM(AMOUNT99) a99,SUM(AMOUNT100) a100,
	SUM(AMOUNT101) a101,SUM(AMOUNT102) a102,SUM(AMOUNT103) a103,SUM(AMOUNT104) a104,SUM(AMOUNT105) a105,
	SUM(AMOUNT106) a106,SUM(AMOUNT107) a107,SUM(AMOUNT108) a108,SUM(AMOUNT109) a109,SUM(AMOUNT110) a110,
	SUM(AMOUNT111) a111,SUM(AMOUNT112) a112,SUM(AMOUNT113) a113,SUM(AMOUNT114) a114,SUM(AMOUNT115) a115,
	SUM(AMOUNT116) a116,SUM(AMOUNT117) a117,SUM(AMOUNT118) a118,SUM(AMOUNT119) a119,SUM(AMOUNT120) a120,
	SUM(AMOUNT121) a121,SUM(AMOUNT122) a122,SUM(AMOUNT123) a123,SUM(AMOUNT124) a124,SUM(AMOUNT125) a125,
	SUM(AMOUNT126) a126,SUM(AMOUNT127) a127,SUM(AMOUNT128) a128,SUM(AMOUNT129) a129,SUM(AMOUNT130) a130,
	SUM(AMOUNT131) a131,SUM(AMOUNT132) a132,SUM(AMOUNT133) a133,SUM(AMOUNT134) a134,SUM(AMOUNT135) a135,
	SUM(AMOUNT136) a136,SUM(AMOUNT137) a137,SUM(AMOUNT138) a138,SUM(AMOUNT139) a139,SUM(AMOUNT140) a140,
	SUM(AMOUNT141) a141,SUM(AMOUNT142) a142,SUM(AMOUNT143) a143,SUM(AMOUNT144) a144,SUM(AMOUNT145) a145,
	SUM(AMOUNT146) a146,SUM(AMOUNT147) a147,SUM(AMOUNT148) a148,SUM(AMOUNT149) a149,SUM(AMOUNT150) a150,
	SUM(AMOUNT151) a151,SUM(AMOUNT152) a152,SUM(AMOUNT153) a153,SUM(AMOUNT154) a154,SUM(AMOUNT155) a155,
	SUM(AMOUNT156) a156,SUM(AMOUNT157) a157,SUM(AMOUNT158) a158,SUM(AMOUNT159) a159,SUM(AMOUNT160) a160,
	SUM(AMOUNT161) a161,SUM(AMOUNT162) a162,SUM(AMOUNT163) a163,SUM(AMOUNT164) a164,SUM(AMOUNT165) a165,
	SUM(AMOUNT166) a166,SUM(AMOUNT167) a167,SUM(AMOUNT168) a168
      FROM  psb_ws_line_balances_i
      WHERE export_id = g_export_id
      AND  export_worksheet_type = 'P'
      AND  position_line_id = p_position_line_id
      AND  value_type = 'A'
      AND  pay_element_id = p_pay_element_id
      AND  service_package_id = l_service_package_id )
    LOOP

      -- Move the Amounts to PL/SQL table
      g_wlbi_amounts(1).amount := sp_element_cost_rec.a1;
      g_wlbi_amounts(2).amount := sp_element_cost_rec.a2;
      g_wlbi_amounts(3).amount := sp_element_cost_rec.a3;
      g_wlbi_amounts(4).amount := sp_element_cost_rec.a4;
      g_wlbi_amounts(5).amount := sp_element_cost_rec.a5;
      g_wlbi_amounts(6).amount := sp_element_cost_rec.a6;
      g_wlbi_amounts(7).amount := sp_element_cost_rec.a7;
      g_wlbi_amounts(8).amount := sp_element_cost_rec.a8;
      g_wlbi_amounts(9).amount := sp_element_cost_rec.a9;
      g_wlbi_amounts(10).amount := sp_element_cost_rec.a10;

      g_wlbi_amounts(11).amount := sp_element_cost_rec.a11;
      g_wlbi_amounts(12).amount := sp_element_cost_rec.a12;
      g_wlbi_amounts(13).amount := sp_element_cost_rec.a13;
      g_wlbi_amounts(14).amount := sp_element_cost_rec.a14;
      g_wlbi_amounts(15).amount := sp_element_cost_rec.a15;
      g_wlbi_amounts(16).amount := sp_element_cost_rec.a16;
      g_wlbi_amounts(17).amount := sp_element_cost_rec.a17;
      g_wlbi_amounts(18).amount := sp_element_cost_rec.a18;
      g_wlbi_amounts(19).amount := sp_element_cost_rec.a19;
      g_wlbi_amounts(20).amount := sp_element_cost_rec.a20;

      g_wlbi_amounts(21).amount := sp_element_cost_rec.a21;
      g_wlbi_amounts(22).amount := sp_element_cost_rec.a22;
      g_wlbi_amounts(23).amount := sp_element_cost_rec.a23;
      g_wlbi_amounts(24).amount := sp_element_cost_rec.a24;
      g_wlbi_amounts(25).amount := sp_element_cost_rec.a25;
      g_wlbi_amounts(26).amount := sp_element_cost_rec.a26;
      g_wlbi_amounts(27).amount := sp_element_cost_rec.a27;
      g_wlbi_amounts(28).amount := sp_element_cost_rec.a28;
      g_wlbi_amounts(29).amount := sp_element_cost_rec.a29;
      g_wlbi_amounts(30).amount := sp_element_cost_rec.a30;

      g_wlbi_amounts(31).amount := sp_element_cost_rec.a31;
      g_wlbi_amounts(32).amount := sp_element_cost_rec.a32;
      g_wlbi_amounts(33).amount := sp_element_cost_rec.a33;
      g_wlbi_amounts(34).amount := sp_element_cost_rec.a34;
      g_wlbi_amounts(35).amount := sp_element_cost_rec.a35;
      g_wlbi_amounts(36).amount := sp_element_cost_rec.a36;
      g_wlbi_amounts(37).amount := sp_element_cost_rec.a37;
      g_wlbi_amounts(38).amount := sp_element_cost_rec.a38;
      g_wlbi_amounts(39).amount := sp_element_cost_rec.a39;
      g_wlbi_amounts(40).amount := sp_element_cost_rec.a40;

      g_wlbi_amounts(41).amount := sp_element_cost_rec.a41;
      g_wlbi_amounts(42).amount := sp_element_cost_rec.a42;
      g_wlbi_amounts(43).amount := sp_element_cost_rec.a43;
      g_wlbi_amounts(44).amount := sp_element_cost_rec.a44;
      g_wlbi_amounts(45).amount := sp_element_cost_rec.a45;
      g_wlbi_amounts(46).amount := sp_element_cost_rec.a46;
      g_wlbi_amounts(47).amount := sp_element_cost_rec.a47;
      g_wlbi_amounts(48).amount := sp_element_cost_rec.a48;
      g_wlbi_amounts(49).amount := sp_element_cost_rec.a49;
      g_wlbi_amounts(50).amount := sp_element_cost_rec.a50;

      g_wlbi_amounts(51).amount := sp_element_cost_rec.a51;
      g_wlbi_amounts(52).amount := sp_element_cost_rec.a52;
      g_wlbi_amounts(53).amount := sp_element_cost_rec.a53;
      g_wlbi_amounts(54).amount := sp_element_cost_rec.a54;
      g_wlbi_amounts(55).amount := sp_element_cost_rec.a55;
      g_wlbi_amounts(56).amount := sp_element_cost_rec.a56;
      g_wlbi_amounts(57).amount := sp_element_cost_rec.a57;
      g_wlbi_amounts(58).amount := sp_element_cost_rec.a58;
      g_wlbi_amounts(59).amount := sp_element_cost_rec.a59;
      g_wlbi_amounts(60).amount := sp_element_cost_rec.a60;

      g_wlbi_amounts(61).amount := sp_element_cost_rec.a61;
      g_wlbi_amounts(62).amount := sp_element_cost_rec.a62;
      g_wlbi_amounts(63).amount := sp_element_cost_rec.a63;
      g_wlbi_amounts(64).amount := sp_element_cost_rec.a64;
      g_wlbi_amounts(65).amount := sp_element_cost_rec.a65;
      g_wlbi_amounts(66).amount := sp_element_cost_rec.a66;
      g_wlbi_amounts(67).amount := sp_element_cost_rec.a67;
      g_wlbi_amounts(68).amount := sp_element_cost_rec.a68;
      g_wlbi_amounts(69).amount := sp_element_cost_rec.a69;
      g_wlbi_amounts(70).amount := sp_element_cost_rec.a70;

      g_wlbi_amounts(71).amount := sp_element_cost_rec.a71;
      g_wlbi_amounts(72).amount := sp_element_cost_rec.a72;
      g_wlbi_amounts(73).amount := sp_element_cost_rec.a73;
      g_wlbi_amounts(74).amount := sp_element_cost_rec.a74;
      g_wlbi_amounts(75).amount := sp_element_cost_rec.a75;
      g_wlbi_amounts(76).amount := sp_element_cost_rec.a76;
      g_wlbi_amounts(77).amount := sp_element_cost_rec.a77;
      g_wlbi_amounts(78).amount := sp_element_cost_rec.a78;
      g_wlbi_amounts(79).amount := sp_element_cost_rec.a79;
      g_wlbi_amounts(80).amount := sp_element_cost_rec.a80;

      g_wlbi_amounts(81).amount := sp_element_cost_rec.a81;
      g_wlbi_amounts(82).amount := sp_element_cost_rec.a82;
      g_wlbi_amounts(83).amount := sp_element_cost_rec.a83;
      g_wlbi_amounts(84).amount := sp_element_cost_rec.a84;
      g_wlbi_amounts(85).amount := sp_element_cost_rec.a85;
      g_wlbi_amounts(86).amount := sp_element_cost_rec.a86;
      g_wlbi_amounts(87).amount := sp_element_cost_rec.a87;
      g_wlbi_amounts(88).amount := sp_element_cost_rec.a88;
      g_wlbi_amounts(89).amount := sp_element_cost_rec.a89;
      g_wlbi_amounts(90).amount := sp_element_cost_rec.a90;

      g_wlbi_amounts(91).amount := sp_element_cost_rec.a91;
      g_wlbi_amounts(92).amount := sp_element_cost_rec.a92;
      g_wlbi_amounts(93).amount := sp_element_cost_rec.a93;
      g_wlbi_amounts(94).amount := sp_element_cost_rec.a94;
      g_wlbi_amounts(95).amount := sp_element_cost_rec.a95;
      g_wlbi_amounts(96).amount := sp_element_cost_rec.a96;
      g_wlbi_amounts(97).amount := sp_element_cost_rec.a97;
      g_wlbi_amounts(98).amount := sp_element_cost_rec.a98;
      g_wlbi_amounts(99).amount := sp_element_cost_rec.a99;
      g_wlbi_amounts(100).amount := sp_element_cost_rec.a100;

      g_wlbi_amounts(101).amount := sp_element_cost_rec.a101;
      g_wlbi_amounts(102).amount := sp_element_cost_rec.a102;
      g_wlbi_amounts(103).amount := sp_element_cost_rec.a103;
      g_wlbi_amounts(104).amount := sp_element_cost_rec.a104;
      g_wlbi_amounts(105).amount := sp_element_cost_rec.a105;
      g_wlbi_amounts(106).amount := sp_element_cost_rec.a106;
      g_wlbi_amounts(107).amount := sp_element_cost_rec.a107;
      g_wlbi_amounts(108).amount := sp_element_cost_rec.a108;
      g_wlbi_amounts(109).amount := sp_element_cost_rec.a109;
      g_wlbi_amounts(110).amount := sp_element_cost_rec.a110;

      g_wlbi_amounts(111).amount := sp_element_cost_rec.a111;
      g_wlbi_amounts(112).amount := sp_element_cost_rec.a112;
      g_wlbi_amounts(113).amount := sp_element_cost_rec.a113;
      g_wlbi_amounts(114).amount := sp_element_cost_rec.a114;
      g_wlbi_amounts(115).amount := sp_element_cost_rec.a115;
      g_wlbi_amounts(116).amount := sp_element_cost_rec.a116;
      g_wlbi_amounts(117).amount := sp_element_cost_rec.a117;
      g_wlbi_amounts(118).amount := sp_element_cost_rec.a118;
      g_wlbi_amounts(119).amount := sp_element_cost_rec.a119;
      g_wlbi_amounts(120).amount := sp_element_cost_rec.a120;

      g_wlbi_amounts(121).amount := sp_element_cost_rec.a121;
      g_wlbi_amounts(122).amount := sp_element_cost_rec.a122;
      g_wlbi_amounts(123).amount := sp_element_cost_rec.a123;
      g_wlbi_amounts(124).amount := sp_element_cost_rec.a124;
      g_wlbi_amounts(125).amount := sp_element_cost_rec.a125;
      g_wlbi_amounts(126).amount := sp_element_cost_rec.a126;
      g_wlbi_amounts(127).amount := sp_element_cost_rec.a127;
      g_wlbi_amounts(128).amount := sp_element_cost_rec.a128;
      g_wlbi_amounts(129).amount := sp_element_cost_rec.a129;
      g_wlbi_amounts(130).amount := sp_element_cost_rec.a130;

      g_wlbi_amounts(131).amount := sp_element_cost_rec.a131;
      g_wlbi_amounts(132).amount := sp_element_cost_rec.a132;
      g_wlbi_amounts(133).amount := sp_element_cost_rec.a133;
      g_wlbi_amounts(134).amount := sp_element_cost_rec.a134;
      g_wlbi_amounts(135).amount := sp_element_cost_rec.a135;
      g_wlbi_amounts(136).amount := sp_element_cost_rec.a136;
      g_wlbi_amounts(137).amount := sp_element_cost_rec.a137;
      g_wlbi_amounts(138).amount := sp_element_cost_rec.a138;
      g_wlbi_amounts(139).amount := sp_element_cost_rec.a139;
      g_wlbi_amounts(140).amount := sp_element_cost_rec.a140;

      g_wlbi_amounts(141).amount := sp_element_cost_rec.a141;
      g_wlbi_amounts(142).amount := sp_element_cost_rec.a142;
      g_wlbi_amounts(143).amount := sp_element_cost_rec.a143;
      g_wlbi_amounts(144).amount := sp_element_cost_rec.a144;
      g_wlbi_amounts(145).amount := sp_element_cost_rec.a145;
      g_wlbi_amounts(146).amount := sp_element_cost_rec.a146;
      g_wlbi_amounts(147).amount := sp_element_cost_rec.a147;
      g_wlbi_amounts(148).amount := sp_element_cost_rec.a148;
      g_wlbi_amounts(149).amount := sp_element_cost_rec.a149;
      g_wlbi_amounts(150).amount := sp_element_cost_rec.a150;

      g_wlbi_amounts(151).amount := sp_element_cost_rec.a151;
      g_wlbi_amounts(152).amount := sp_element_cost_rec.a152;
      g_wlbi_amounts(153).amount := sp_element_cost_rec.a153;
      g_wlbi_amounts(154).amount := sp_element_cost_rec.a154;
      g_wlbi_amounts(155).amount := sp_element_cost_rec.a155;
      g_wlbi_amounts(156).amount := sp_element_cost_rec.a156;
      g_wlbi_amounts(157).amount := sp_element_cost_rec.a157;
      g_wlbi_amounts(158).amount := sp_element_cost_rec.a158;
      g_wlbi_amounts(159).amount := sp_element_cost_rec.a159;
      g_wlbi_amounts(160).amount := sp_element_cost_rec.a160;

      g_wlbi_amounts(161).amount := sp_element_cost_rec.a161;
      g_wlbi_amounts(162).amount := sp_element_cost_rec.a162;
      g_wlbi_amounts(163).amount := sp_element_cost_rec.a163;
      g_wlbi_amounts(164).amount := sp_element_cost_rec.a164;
      g_wlbi_amounts(165).amount := sp_element_cost_rec.a165;
      g_wlbi_amounts(166).amount := sp_element_cost_rec.a166;
      g_wlbi_amounts(167).amount := sp_element_cost_rec.a167;
      g_wlbi_amounts(168).amount := sp_element_cost_rec.a168;

      -- Estimate years pl/sql table is indexed by estimate year id
      i := g_estimate_years.FIRST;
      WHILE i IS NOT NULL
      LOOP
	Get_WLBI_SP_Element_Cost
	 (p_budget_year_id     => i,
	  p_wlbi_sp_element_cost  => l_wlbi_sp_element_cost
	 );

	l_found_element_line := FALSE;
	Get_Element_Line_ID
	 (p_position_line_id     => p_position_line_id,
	  p_budget_year_id       => i,
	  p_pay_element_id       => p_pay_element_id,
	  p_service_package_id   => l_service_package_id,
	  p_found_element_line   => l_found_element_line,
	  p_element_line_id      => l_element_line_id
	 );


	 IF l_found_element_line THEN


	    PSB_WS_POS_PVT.Create_Element_Lines
		 (
		  p_api_version                 => 1.0,
		  p_init_msg_list               => FND_API.G_FALSE,
		  p_commit                      => FND_API.G_FALSE,
		  p_validation_level            => FND_API.G_VALID_LEVEL_FULL,
		  p_return_status               => l_return_status,
		  p_msg_count                   => l_msg_count,
		  p_msg_data                    => l_msg_data,
		  --
--                p_check_stages                => l_check_stages,
		  p_element_line_id             => l_element_line_id,
		  p_service_package_id          => l_service_package_id,
--                p_current_stage_seq           => l_current_stage_seq,
		  p_element_cost                => l_wlbi_sp_element_cost
		 );

	    --debug('elm_return_status'||l_return_status);
	    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR ;
	    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	    END IF;

	 ELSE
	   -- Call Create Element Lines API

	   PSB_WS_POS_PVT.Create_Element_Lines
		 (
		  p_api_version                 => 1.0,
		  p_init_msg_list               => FND_API.G_FALSE,
		  p_commit                      => FND_API.G_FALSE,
		  p_validation_level            => FND_API.G_VALID_LEVEL_FULL,
		  p_return_status               => l_return_status,
		  p_msg_count                   => l_msg_count,
		  p_msg_data                    => l_msg_data,
		  --
		  p_element_line_id             => l_element_line_id,
--                p_check_spel_exists           => FND_API.G_TRUE,
		  p_position_line_id            => p_position_line_id,
		  p_budget_year_id              => i,
		  p_pay_element_id              => p_pay_element_id,
		  p_currency_code               => g_currency_code,
		  p_element_cost                => l_wlbi_sp_element_cost,
		  p_element_set_id              => p_element_set_id,
		  p_service_package_id          => l_service_package_id,
		  p_stage_set_id                => g_stage_set_id,
		  p_current_stage_seq           => g_current_stage_seq

		 );

	   --debug('elc_return_status'||l_return_status);
	   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	     RAISE FND_API.G_EXC_ERROR ;
	   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	   END IF;

	 END IF;


	i:=  g_estimate_years.NEXT(i);
      END LOOP; --for each estimate year
    END LOOP; -- For each sp_element_cost_rec
  END LOOP; -- For each service package

  END Change_Element_Cost;


  PROCEDURE Get_Element_Line_ID
  ( p_position_line_id            IN NUMBER,
    p_budget_year_id              IN NUMBER,
    p_pay_element_id                  IN NUMBER,
    p_service_package_id          IN NUMBER,
    p_found_element_line         OUT  NOCOPY BOOLEAN,
    p_element_line_id             OUT  NOCOPY NUMBER
  )
  IS

    cursor wel_cur is
    SELECT element_line_id
    FROM   psb_ws_element_lines
    WHERE  position_line_id = p_position_line_id
    AND    budget_year_id = p_budget_year_id
    AND    service_package_id = p_service_package_id
    AND    pay_element_id = p_pay_element_id
    AND    end_stage_seq IS NULL;

    Recinfo   wel_cur%ROWTYPE;

  BEGIN
    p_element_line_id := 0;
    OPEN wel_cur;
    FETCH wel_cur INTO Recinfo;
    IF wel_cur%FOUND THEN
      p_found_element_line := TRUE;
      p_element_line_id := Recinfo.element_line_id;
    ELSE
      p_found_element_line := FALSE;
    END IF;
    close wel_cur;

  END Get_Element_Line_ID;


  PROCEDURE Get_WLBI_SP_Element_Cost
  ( p_budget_year_id     IN NUMBER,
    p_wlbi_sp_element_cost  OUT  NOCOPY NUMBER
  )
  IS
    l_period_start_column NUMBER;
    l_period_end_column NUMBER;
    l_year_amount NUMBER := 0 ;

  BEGIN
    -- Retrieve the sum from PL/SQL Table
    l_period_start_column := g_estimate_years(p_budget_year_id).period_start_column ;
    l_period_end_column   := g_estimate_years(p_budget_year_id).period_end_column;

    FOR i IN l_period_start_column .. l_period_end_column
    LOOP
      l_year_amount := g_wlbi_amounts(i).amount +  l_year_amount;
    END LOOP;
    p_wlbi_sp_element_cost := l_year_amount;

  END Get_WLBI_SP_Element_Cost;


  -- Before calling this routine :
  -- Cache Budget Calendar
  -- Cache Elements, Attributes for data extract and business group id
  -- Cache Position assignments based on effective dates of the position and
     -- the budget calendar(current year start date and estimate year end date)

  PROCEDURE Change_Pos_Year_Assignments
  ( p_return_status              OUT  NOCOPY VARCHAR2,
    p_worksheet_id                IN NUMBER,
    p_budget_calendar_id          IN NUMBER,
    p_data_extract_id             IN NUMBER,
    p_business_group_id           IN NUMBER,
    p_position_line_id            IN NUMBER,
    p_position_id                 IN NUMBER,
    p_position_name               IN VARCHAR2,
    p_pay_element_id              IN NUMBER,
    p_amt_tolerance_value_type    IN VARCHAR2,
    p_amt_tolerance_value         IN NUMBER,
    p_pct_tolerance_value_type    IN VARCHAR2,
    p_pct_tolerance_value         IN NUMBER,
    p_budget_year_id              IN NUMBER,
    p_assignments                 IN g_assignment_tbl_type

  ) IS

  l_return_status VARCHAR2(1);
  l_msg_count     NUMBER;


  l_element_name            VARCHAR2(30);
  l_processing_type         VARCHAR2(1);
  l_max_element_value_type  VARCHAR2(2);
  l_max_element_value       NUMBER;
  l_salary_flag             VARCHAR2(1);
  l_salary_type             VARCHAR2(10);
  l_follow_salary           VARCHAR2(1);
  l_period_type             VARCHAR2(10);
  l_process_period_type     VARCHAR2(10);

  l_fte                    NUMBER;
  l_default_weekly_hours   NUMBER;
  l_pay_element_id         NUMBER;
  l_pay_element_option_id  NUMBER;
  l_pay_basis              VARCHAR2(10);
  l_element_value_type     VARCHAR2(2);
  l_element_value          NUMBER;
  l_formula_id             NUMBER;
  l_option_flag            VARCHAR2(1);
  l_overwrite_flag         VARCHAR2(1);
  l_budget_period_id       NUMBER;


  l_year_index             BINARY_INTEGER;
  l_period_index           BINARY_INTEGER;
  l_calcperiod_index       BINARY_INTEGER;
  l_element_index          BINARY_INTEGER;
  l_assign_index           BINARY_INTEGER;
  l_rate_index             BINARY_INTEGER;
  l_salary_index           BINARY_INTEGER;

  l_ws_assignment          VARCHAR2(1);
  l_element_assigned       VARCHAR2(1);

  l_factor                 NUMBER;
  l_element_cost           NUMBER;
  l_ytd_element_cost       NUMBER;

  l_last_period_index      NUMBER;

  l_salary_defined         VARCHAR2(1) := FND_API.G_FALSE;
  l_salary_element_value   NUMBER;


  l_assign_period          VARCHAR2(1);
  l_calculate_from_salary  VARCHAR2(1);
  l_assign_period_index    NUMBER;


  l_nonrec_calculated      VARCHAR2(1);


  l_period_num              NUMBER;
  l_year_period_num         NUMBER;
  l_num_budget_periods      NUMBER;
  l_new_salary_element_cost NUMBER;
  l_new_element_cost        NUMBER;
  l_new_element_value       NUMBER;

  l_budget_period_type        VARCHAR2(1);
  l_budget_period_start_date  DATE;
  l_budget_period_end_date    DATE;
  l_num_calc_periods          NUMBER;


  l_pos_assignment            VARCHAR2(1);
  l_value_from_elem_rates     VARCHAR2(1);
  l_year_start_date           DATE;
  l_year_end_date             DATE;

  l_tol_max_element_value     NUMBER;
  l_tol_min_element_value     NUMBER;
  l_new_assignment_found     VARCHAR2(1);

  l_new_element_option_id     NUMBER;
  l_position_assignment_id    NUMBER;
  l_rowid                     VARCHAR2(200);
  l_msg_data                  VARCHAR2(2000);

  BEGIN
  l_pay_element_id := p_pay_element_id;

  for l_element_index in 1..PSB_WS_POS1.g_num_elements loop

    if PSB_WS_POS1.g_elements(l_element_index).pay_element_id = l_pay_element_id then

      l_element_name := PSB_WS_POS1.g_elements(l_element_index).element_name;
      l_processing_type := PSB_WS_POS1.g_elements(l_element_index).processing_type;
      l_max_element_value_type := PSB_WS_POS1.g_elements(l_element_index).max_element_value_type;
      l_max_element_value := PSB_WS_POS1.g_elements(l_element_index).max_element_value;
      l_salary_flag := PSB_WS_POS1.g_elements(l_element_index).salary_flag;
      l_salary_type := PSB_WS_POS1.g_elements(l_element_index).salary_type;
      l_follow_salary := PSB_WS_POS1.g_elements(l_element_index).follow_salary;
      l_period_type := PSB_WS_POS1.g_elements(l_element_index).period_type;
      l_process_period_type := PSB_WS_POS1.g_elements(l_element_index).process_period_type;
      l_option_flag := PSB_WS_POS1.g_elements(l_element_index).option_flag;
      l_overwrite_flag := PSB_WS_POS1.g_elements(l_element_index).overwrite_flag;

      exit;
    end if;
  end loop;


  -- Get the last period index
  for l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years loop

     if PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id = p_budget_year_id then
       l_last_period_index := PSB_WS_ACCT1.g_budget_years(l_year_index).last_period_index;
       l_year_start_date :=   PSB_WS_ACCT1.g_budget_years(l_year_index).start_date;
       l_year_end_date   :=   PSB_WS_ACCT1.g_budget_years(l_year_index).end_date;

       exit;
     end if;

  end loop;


  l_pay_element_id := p_pay_element_id;
  l_element_assigned := FND_API.G_FALSE;
  l_nonrec_calculated := FND_API.G_FALSE;

  for l_assign_index in 1..g_num_poselem_assignments loop
     if ((g_poselem_assignments(l_assign_index).pay_element_id = l_pay_element_id) and
	(((g_poselem_assignments(l_assign_index).start_date <= l_year_end_date) and
	  (g_poselem_assignments(l_assign_index).end_date is null)) or
	 ((g_poselem_assignments(l_assign_index).start_date between l_year_start_date and l_year_end_date) or
	  (g_poselem_assignments(l_assign_index).end_date between l_year_start_date and l_year_end_date) or
	 ((g_poselem_assignments(l_assign_index).start_date < l_year_start_date) and
	  (g_poselem_assignments(l_assign_index).end_date > l_year_end_date))))) then
	l_element_assigned := FND_API.G_TRUE;

	exit;
      end if;

  end loop;


  if nvl(l_process_period_type, 'FIRST') = 'FIRST' then
     l_assign_period_index := 1;
  else
    l_assign_period_index := l_last_period_index;
  end if;

  l_ytd_element_cost := 0;
  l_calculate_from_salary := FND_API.G_FALSE;
  l_assign_period := FND_API.G_FALSE;

  -- Main Loop
  -- For each budget period with a new amount

  l_num_budget_periods := (g_estimate_years(p_budget_year_id).period_end_column -
			  g_estimate_years(p_budget_year_id).period_start_column) + 1;



  for l_budget_period in 1..g_assignment_count loop


    l_period_num := p_assignments(l_budget_period).period;


    l_new_element_cost := p_assignments(l_budget_period).new_amount;

    l_new_element_value := 0;

    -- Loop thru cached calendar to get start and end dates for the budget period
    l_year_period_num := 0;

    for l_period_index in 1..PSB_WS_ACCT1.g_num_budget_periods loop

      if PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_year_id = p_budget_year_id then
      begin
	l_year_period_num :=  l_year_period_num + 1;
	IF l_year_period_num = l_period_num THEN

	  l_budget_period_id := PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_period_id;
	  l_budget_period_type := PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_period_type;
	  l_budget_period_start_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date;
	  l_budget_period_end_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).end_date;
	  l_budget_period_type     := PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_period_type;
	  l_num_calc_periods       := PSB_WS_ACCT1.g_budget_periods(l_period_index).num_calc_periods;

	END IF;
      end;
      end if;
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
	l_pay_basis := g_poselem_assignments(l_assign_index).pay_basis;
	l_pay_element_option_id := g_poselem_assignments(l_assign_index).pay_element_option_id;
	l_element_value_type := g_poselem_assignments(l_assign_index).element_value_type;
	l_element_value := g_poselem_assignments(l_assign_index).element_value;

	if l_processing_type = 'N' then
	  l_nonrec_calculated := FND_API.G_TRUE;
	end if;
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
	  l_pay_basis := g_poselem_assignments(l_assign_index).pay_basis;
	  l_pay_element_option_id := g_poselem_assignments(l_assign_index).pay_element_option_id;
	  l_element_value_type := g_poselem_assignments(l_assign_index).element_value_type;
	  l_element_value := g_poselem_assignments(l_assign_index).element_value;

	  if l_processing_type = 'N' then
	    l_nonrec_calculated := FND_API.G_TRUE;
	  end if;


	  exit;
	end;
	end if;

      end loop;

    end;
    end if;  -- if not ws assignment

    -- See if the value is arrived from element rates table
    l_value_from_elem_rates := FND_API.G_FALSE;
    if l_element_value is null then
    begin

      for l_rate_index in 1..g_num_poselem_rates loop

	if ((g_poselem_rates(l_rate_index).pay_element_id = l_pay_element_id) and
	   (nvl(g_poselem_rates(l_rate_index).pay_element_option_id, FND_API.G_MISS_NUM) = nvl(l_pay_element_option_id, FND_API.G_MISS_NUM)) and
	   (((g_poselem_rates(l_rate_index).start_date <= l_budget_period_end_date) and
	   (g_poselem_rates(l_rate_index).end_date is null)) or
	   ((g_poselem_rates(l_rate_index).start_date between l_budget_period_start_date and l_budget_period_end_date) or
	   (g_poselem_rates(l_rate_index).end_date between l_budget_period_start_date and l_budget_period_end_date) or
	   ((g_poselem_rates(l_rate_index).start_date < l_budget_period_start_date) and
	   (g_poselem_rates(l_rate_index).end_date > l_budget_period_end_date))))) then
	begin
	  l_value_from_elem_rates := FND_API.G_TRUE;
	  l_element_value_type := g_poselem_rates(l_rate_index).element_value_type;
	  l_element_value := g_poselem_rates(l_rate_index).element_value;
	  l_formula_id := g_poselem_rates(l_rate_index).formula_id;
	  exit;
	end;
	end if;

      end loop;

      end;
    end if;  -- Element value is null

    -- Get FTE
    l_fte := g_fte_period_amounts(l_period_num).amount;

    if g_num_poswkh_assignments > 0 then
      for l_assign_index in 1 .. g_num_poswkh_assignments loop

	if (((g_poswkh_assignments(l_assign_index).start_date <= l_budget_period_end_date) and
	 (g_poswkh_assignments(l_assign_index).end_date is null)) or
	 ((g_poswkh_assignments(l_assign_index).start_date between l_budget_period_start_date and l_budget_period_end_date) or
	 (g_poswkh_assignments(l_assign_index).end_date between l_budget_period_start_date and l_budget_period_end_date) or
	 ((g_poswkh_assignments(l_assign_index).start_date < l_budget_period_start_date) and
	 (g_poswkh_assignments(l_assign_index).end_date > l_budget_period_end_date)))) then
	begin

	  l_default_weekly_hours := g_poswkh_assignments(l_assign_index).default_weekly_hours;

	  exit;
	end;
	end if;

      end loop;
    end if;


    if l_salary_flag = 'Y' then
    begin

      l_new_salary_element_cost := l_new_element_cost;


      if l_processing_type = 'N' then
	 l_new_element_value := l_new_element_cost;
      else
      begin

	if l_pay_basis = 'ANNUAL' then
	begin

	  PSB_WS_POS1.HRMS_Factor
	    (p_return_status => l_return_status,
	     p_hrms_period_type => 'Y',
	     p_budget_period_type => l_budget_period_type,
	     p_position_name => p_position_name,
	     p_element_name => l_element_name,
	     p_start_date => l_budget_period_start_date,
	     p_end_date => l_budget_period_end_date,
	     p_factor => l_factor);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;


	  l_new_element_value := l_new_element_cost/(l_fte * l_factor * l_num_calc_periods);

	end;
	elsif l_pay_basis = 'HOURLY' then
	begin

	  PSB_WS_POS1.HRMS_Factor
	  (p_return_status => l_return_status,
	   p_hrms_period_type => 'W',
	   p_budget_period_type => l_budget_period_type,
	   p_position_name => p_position_name,
	   p_element_name => l_element_name,
	   p_start_date => l_budget_period_start_date,
	   p_end_date => l_budget_period_end_date,
	   p_factor => l_factor);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	     raise FND_API.G_EXC_ERROR;
	  end if;

	  if l_default_weekly_hours is null then
	     --add_message('PSB', 'PSB_INVALID_NAMED_ATTRIBUTE');
	    null;
	  end if;

	  l_new_element_value := l_new_element_cost/(l_fte * l_factor
				 * l_default_weekly_hours* l_num_calc_periods);

	end;
	elsif l_pay_basis = 'MONTHLY' then
	begin

	  PSB_WS_POS1.HRMS_Factor
	  (p_return_status => l_return_status,
	   p_hrms_period_type => 'CM',
	   p_budget_period_type => l_budget_period_type,
	   p_position_name => p_position_name,
	   p_element_name => l_element_name,
	   p_start_date => l_budget_period_start_date,
	   p_end_date => l_budget_period_end_date,
	   p_factor => l_factor);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	     raise FND_API.G_EXC_ERROR;
	  end if;


	 l_new_element_value := l_new_element_cost/(l_fte * l_factor * l_num_calc_periods);


	end;
	elsif l_pay_basis = 'PERIOD' then
	begin
	  PSB_WS_POS1.HRMS_Factor
	  (p_return_status => l_return_status,
	 /* For Bug No. 2504333 : Start */
	   -- p_hrms_period_type => PSB_WS_POS1.g_elements(l_element_index).period_type,
	   p_hrms_period_type => l_period_type,
	 /* For Bug No. 2504333 : End */
	   p_budget_period_type => l_budget_period_type,
	   p_position_name => p_position_name,
	   p_element_name => l_element_name,
	   p_start_date => l_budget_period_start_date,
	   p_end_date => l_budget_period_end_date,
	   p_factor => l_factor);
	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	  l_new_element_value := l_new_element_cost/(l_fte * l_factor * l_num_calc_periods );

	end;

	end if;   -- pay_basis

      end;
      end if;  -- processing type <> 'N' (Non-recurring)
    end;
    else  --PSB_WS_POS1.g_elements(l_element_index).salary_flag <> 'Y'
    begin

      if l_element_value_type = 'PS' then
      begin
	l_new_element_value := l_new_element_cost;
      end;
      elsif l_element_value_type = 'A' then
      begin

	if l_processing_type = 'N' then
	   l_new_element_value := l_new_element_cost;
	else
	begin
	  PSB_WS_POS1.HRMS_Factor
	  (p_return_status => l_return_status,
	 /* For Bug No. 2504333 : Start */
	   -- p_hrms_period_type => PSB_WS_POS1.g_elements(l_element_index).period_type,
	   p_hrms_period_type => l_period_type,
	 /* For Bug No. 2504333 : End */
	   p_budget_period_type => l_budget_period_type,
	   p_position_name => p_position_name,
	   p_element_name => l_element_name,
	   p_start_date => l_budget_period_start_date,
	   p_end_date => l_budget_period_end_date,
	   p_factor => l_factor);
	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	     raise FND_API.G_EXC_ERROR;
	  end if;
	  l_new_element_value := l_new_element_cost/(l_fte * l_factor * l_num_calc_periods );
	end;
	end if;

      end;
      --Ignore if l_element_value_type = 'F' (Formula)
      end if;  -- l_element_value_type

    end;
    end if;  --PSB_WS_POS1.g_elements(l_element_index).salary_flag <> 'Y'


   -- Limit the element value to the max value
   l_new_element_value := least(l_new_element_value, nvl(l_max_element_value, l_new_element_value));



   -- Find out the tolerance amount or percent

   if  l_new_element_value is not null then
     -- Assign default values to tolerance limits
     l_tol_max_element_value := l_new_element_value;
     l_tol_min_element_value := l_new_element_value;

     if l_element_value_type = 'A' then
       if p_amt_tolerance_value_type = 'A' then
	 l_tol_max_element_value :=  l_new_element_value + p_amt_tolerance_value;
	 l_tol_min_element_value :=  l_new_element_value - p_amt_tolerance_value;
       elsif  p_amt_tolerance_value_type = 'P' then
	 l_tol_max_element_value :=  l_new_element_value *( 1 + p_amt_tolerance_value/100);
	 l_tol_min_element_value :=  l_new_element_value *( 1 - p_amt_tolerance_value/100);
       end if;
     elsif l_element_value_type = 'PS' then
       if p_pct_tolerance_value_type = 'A' then
	 l_tol_max_element_value :=  l_new_element_value + p_pct_tolerance_value;
	 l_tol_min_element_value :=  l_new_element_value - p_pct_tolerance_value;
       elsif  p_pct_tolerance_value_type = 'P' then
	 l_tol_max_element_value :=  l_new_element_value * ( 1 + p_pct_tolerance_value/100);
	 l_tol_min_element_value :=  l_new_element_value * ( 1 - p_pct_tolerance_value/100);
       end if;
     end if;
   end if;


   l_new_assignment_found := FND_API.G_FALSE;
   -- Find out the Element Option from element value

   l_new_element_option_id := null;
   if l_option_flag = 'Y' then

     --debug('g_global_worksheet_id'||g_global_worksheet_id);
     --debug('g_currency_code'||g_currency_code);
     --debug('l_budget_period_start_date'||l_budget_period_start_date);
     --debug('l_budget_period_end_date'||l_budget_period_end_date);
     --debug('g_business_group_id'||g_business_group_id);
     --debug('g_data_extract_id'||g_data_extract_id);


     -- pick the element
     for elem_asgn_rec in
     (select a.worksheet_id,
	     abs(l_new_element_value - a.element_value) near_el,
	     a.pay_element_id,
	     a.pay_element_option_id
	from PSB_PAY_ELEMENT_RATES a,
	   PSB_PAY_ELEMENTS b
       where (a.worksheet_id is null or a.worksheet_id = g_global_worksheet_id)
       and a.currency_code = g_currency_code
       and (((a.effective_start_date <= l_budget_period_end_date)
	 and (a.effective_end_date is null))
	 or ((a.effective_start_date between l_budget_period_start_date and l_budget_period_end_date)
	  or (a.effective_end_date between l_budget_period_start_date and l_budget_period_end_date)
	 or ((a.effective_start_date < l_budget_period_start_date)
	 and (a.effective_end_date > l_budget_period_end_date))))
       and a.pay_element_id = b.pay_element_id
       and b.business_group_id = g_business_group_id
       and b.data_extract_id = g_data_extract_id
       and a.pay_element_id = l_pay_element_id
       and a.element_value between  l_tol_min_element_value and  l_tol_max_element_value
       order by 1,2
     )
     loop
       l_new_element_option_id := elem_asgn_rec.pay_element_option_id;
       l_new_assignment_found := FND_API.G_TRUE;


       exit;
     end loop;  --elem_asgn_rec

     if l_new_assignment_found = FND_API.G_FALSE then

       FND_MESSAGE.SET_NAME('PSB', 'PSB_ELEMENT_OPTION_NOT_FOUND');
       FND_MESSAGE.SET_TOKEN('POSITION_NAME', p_position_name);
       FND_MESSAGE.SET_TOKEN('PAY_ELEMENT_NAME', l_element_name);
       FND_MSG_PUB.Add;
       raise FND_API.G_EXC_ERROR;
     end if;

   elsif  l_option_flag = 'N' then

     -- retain the old element option if overwrite is allowed
     if l_overwrite_flag = 'Y' then
	l_new_element_option_id := l_pay_element_option_id;
     elsif l_new_element_option_id <> l_pay_element_option_id then --modified for bug:6019074
       FND_MESSAGE.SET_NAME('PSB', 'PSB_ELEMENT_OVERIDE_NA');
       FND_MESSAGE.SET_TOKEN('POSITION_NAME', p_position_name);
       FND_MESSAGE.SET_TOKEN('PAY_ELEMENT_NAME', l_element_name);
       FND_MSG_PUB.Add;
       raise FND_API.G_EXC_ERROR;
     end if;


   end if; -- option flag = 'Y'




   -- Call Modify Assignment API to make assignment change
   IF  ( nvl(l_new_element_value,0) > 0 )
       AND nvl(l_new_element_value,0) <> nvl(l_element_value,0)
       AND ( l_new_element_option_id IS NOT NULL )
       AND ( l_new_assignment_found = FND_API.G_TRUE
	     OR
	     l_overwrite_flag =  'Y' ) THEN

     --debug('l_element_value_type'||l_element_value_type);
     --debug('l_new_element_value'||l_new_element_value);
     --debug('l_new_element_option_id'||l_new_element_option_id);
     --debug('p_position_id'||p_position_id);
     --debug('p_pay_element_id'||p_pay_element_id);
     --debug('l_pay_basis'||l_pay_basis);

    -- Change made on 11/10/98
    -- Do not populate element value if a matching element option is found
    IF l_new_assignment_found = FND_API.G_TRUE THEN
       l_new_element_value := null;
    END IF;



     PSB_POSITIONS_PVT.Modify_Assignment(
       p_api_version                => 1.0,
       p_init_msg_list               => FND_API.G_FALSE,
       p_commit                      => FND_API.G_FALSE,
       p_validation_level            => FND_API.G_VALID_LEVEL_FULL,
       p_return_status               => l_return_status,
       p_msg_count                   => l_msg_count,
       p_msg_data                    => l_msg_data,
       p_position_assignment_id      => l_position_assignment_id,
       p_data_extract_id             => g_data_extract_id,
       p_worksheet_id                => g_assignment_worksheet_id,
       p_position_id                 => p_position_id,
       p_assignment_type             => 'ELEMENT',
       p_attribute_id                => null,
       p_attribute_value_id          => null,
       p_attribute_value             => null,
       p_pay_element_id              => p_pay_element_id,
       p_pay_element_option_id       => l_new_element_option_id,
       p_effective_start_date        => l_budget_period_start_date,
       p_effective_end_date          => l_budget_period_end_date,
       p_element_value_type          => l_element_value_type,
       p_element_value               => l_new_element_value,
       p_currency_code               => g_currency_code,
       p_pay_basis                   => l_pay_basis,
       p_employee_id                 => null,
       p_primary_employee_flag       => null,
       p_global_default_flag         => null,
       p_assignment_default_rule_id  => null,
       p_modify_flag                 => null,
       p_rowid                       => l_rowid
      );
      --debug('new asgn id'||l_position_assignment_id);
      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

      --debug('l_element_value_type'||l_element_value_type);
    END IF;
  end loop; -- For each Budget Period in the input PL/SQL table


  p_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END Change_Pos_Year_Assignments;


  PROCEDURE  Get_New_Assignments
  (
    p_budget_year_id IN NUMBER
  )
  IS

    l_wal_index NUMBER;
    l_period_start_column  NUMBER;
    l_period_end_column  NUMBER;
    l_assignment_index NUMBER;

  BEGIN
    -- compare the values from wlbi and wal PL/SQL Tables
    -- and build the input assignment PL/SQL table
    l_period_start_column := g_estimate_years(p_budget_year_id).period_start_column ;
    l_period_end_column   := g_estimate_years(p_budget_year_id).period_end_column;



    l_wal_index := 1;
    l_assignment_index := 1;

    g_assignment_count := 0;

    FOR i IN l_period_start_column .. l_period_end_column
    LOOP
      IF  g_wlbi_amounts(i).amount <>  g_wal_period_amounts(l_wal_index).amount THEN
	g_assignment_count := g_assignment_count + 1;

	g_assignment(l_assignment_index).period := l_wal_index;
	g_assignment(l_assignment_index).new_amount   := g_wlbi_amounts(i).amount;
	l_assignment_index := l_assignment_index + 1;

      END IF;
      l_wal_index := l_wal_index + 1;

    END LOOP;

  END Get_New_Assignments;


  PROCEDURE  Get_WLBI_Element_Cost
  ( p_budget_year_id IN NUMBER,
    p_wlbi_element_cost OUT  NOCOPY NUMBER
  )
  IS
    l_period_start_column NUMBER;
    l_period_end_column NUMBER;
    l_year_amount NUMBER := 0 ;

    /* For Bug No. 2378123 : Start */
    l_total_column NUMBER;
    /* For Bug No. 2378123 : End */

  BEGIN
    -- Retrieve the sum from PL/SQL Table

    /* For Bug No. 2378123 : Start
       Element Cost is taken as YTD amount instead of sum of Period amounts */
     -- Following code is commented and next two lines added
    /*
    l_period_start_column := g_estimate_years(p_budget_year_id).period_start_column ;
    l_period_end_column   := g_estimate_years(p_budget_year_id).period_end_column;

    FOR i IN l_period_start_column .. l_period_end_column
    LOOP
      l_year_amount := g_wlbi_amounts(i).amount +  l_year_amount;
    END LOOP;
    */

    l_total_column := g_estimate_years(p_budget_year_id).total_column;
    l_year_amount := g_wlbi_amounts(l_total_column).amount;
    /* For Bug No. 2378123 : End */

    p_wlbi_element_cost := l_year_amount;

  END Get_WLBI_Element_Cost;


  PROCEDURE  Get_WAL_Element_Cost
  ( p_position_line_id IN NUMBER,
    p_element_set_id IN NUMBER,
    p_budget_year_id IN NUMBER,
    p_pay_element_id IN NUMBER,
    p_wal_element_cost OUT  NOCOPY NUMBER
  )
  IS

    l_wal_element_cost NUMBER;
    l_element_cost     NUMBER;--bug:6019074

  BEGIN
    FOR wal_rec IN
      (SELECT sum(ytd_amount) a,
	sum(period1_amount) a1,
	sum(period2_amount) a2,
	sum(period3_amount) a3,
	sum(period4_amount) a4,
	sum(period5_amount) a5,
	sum(period6_amount) a6,
	sum(period7_amount) a7,
	sum(period8_amount) a8,
	sum(period9_amount) a9,
	sum(period10_amount) a10,
	sum(period11_amount) a11,
	sum(period12_amount) a12
       FROM psb_ws_account_lines wal , psb_ws_lines wl
       WHERE wal.account_line_id = wl.account_line_id
       AND wl.worksheet_id = g_worksheet_id
       AND wal.position_line_id = p_position_line_id
       AND wal.element_set_id = p_element_set_id
       AND wal.budget_year_id = p_budget_year_id
       AND wal.template_id IS NULL
       AND wal.end_stage_seq is null
      )
    LOOP
     /*bug:6019074:start*/
      l_element_cost := 0;

      /*bug:6019074:If an account line is representing the cost of more than
       1 pay element, then element cost is derived from psb_ws_element_lines
       table instead of psb_ws_account_lines*/

      for wel_rec in (select * from psb_ws_element_lines
                       where position_line_id = p_position_line_id
                         and element_set_id   = p_element_set_id
                         and pay_element_id   = p_pay_element_id
                         and budget_year_id   = p_budget_year_id
                       ) loop
          l_element_cost :=  wel_rec.element_cost;
      end loop;

    if (l_element_cost <> 0 AND l_element_cost <> wal_rec.a) then
         p_wal_element_cost := l_element_cost;
    else
      p_wal_element_cost := wal_rec.a;
    end if;
       /*bug:6019074:end*/

      g_wal_period_amounts(1).amount  := wal_rec.a1;
      g_wal_period_amounts(2).amount  := wal_rec.a2;
      g_wal_period_amounts(3).amount  := wal_rec.a3;
      g_wal_period_amounts(4).amount  := wal_rec.a4;
      g_wal_period_amounts(5).amount  := wal_rec.a5;
      g_wal_period_amounts(6).amount  := wal_rec.a6;
      g_wal_period_amounts(7).amount  := wal_rec.a7;
      g_wal_period_amounts(8).amount  := wal_rec.a8;
      g_wal_period_amounts(9).amount  := wal_rec.a9;
      g_wal_period_amounts(10).amount := wal_rec.a10;
      g_wal_period_amounts(11).amount := wal_rec.a11;
      g_wal_period_amounts(12).amount := wal_rec.a12;


    END LOOP;

  END Get_WAL_Element_Cost;

  PROCEDURE  Get_FTE
  ( p_position_line_id IN NUMBER,
    p_budget_year_id IN NUMBER
  )
  IS
  BEGIN
    -- Initiate
    for i in 1.. g_fte_period_amounts.count loop
      g_fte_period_amounts(i).amount  := null;
    end loop;

    FOR ws_fte_rec IN
      -- Refine this query later to handle template id
      (SELECT sum(annual_fte) a,
	sum(period1_fte) a1,
	sum(period2_fte) a2,
	sum(period3_fte) a3,
	sum(period4_fte) a4,
	sum(period5_fte) a5,
	sum(period6_fte) a6,
	sum(period7_fte) a7,
	sum(period8_fte) a8,
	sum(period9_fte) a9,
	sum(period10_fte) a10,
	sum(period11_fte) a11,
	sum(period12_fte) a12
       FROM psb_ws_fte_lines fl
       WHERE position_line_id = p_position_line_id
       AND budget_year_id = p_budget_year_id
       AND end_stage_seq is null
      )
    LOOP
      g_fte_period_amounts(1).amount  := ws_fte_rec.a1;
      g_fte_period_amounts(2).amount  := ws_fte_rec.a2;
      g_fte_period_amounts(3).amount  := ws_fte_rec.a3;
      g_fte_period_amounts(4).amount  := ws_fte_rec.a4;
      g_fte_period_amounts(5).amount  := ws_fte_rec.a5;
      g_fte_period_amounts(6).amount  := ws_fte_rec.a6;
      g_fte_period_amounts(7).amount  := ws_fte_rec.a7;
      g_fte_period_amounts(8).amount  := ws_fte_rec.a8;
      g_fte_period_amounts(9).amount  := ws_fte_rec.a9;
      g_fte_period_amounts(10).amount := ws_fte_rec.a10;
      g_fte_period_amounts(11).amount := ws_fte_rec.a11;
      g_fte_period_amounts(12).amount := ws_fte_rec.a12;

    END LOOP;

  END Get_FTE;

  PROCEDURE Delete_Export_Details(p_export_worksheet_type IN VARCHAR2)
  IS
  BEGIN

    delete from psb_ws_line_balances_i
    where export_id = g_export_id
    and export_worksheet_type = p_export_worksheet_type;

    delete from psb_ws_columns_i
    where export_id = g_export_id
    and export_worksheet_type = p_export_worksheet_type;

    IF p_export_worksheet_type = 'A' THEN
      update psb_worksheets_i
      set account_export_status = 'DELETE'
      where export_id = g_export_id;
      g_account_export_status := 'DELETE';

    ELSE
      update psb_worksheets_i
      set position_export_status = 'DELETE'
      where export_id = g_export_id;
      g_position_export_status := 'DELETE';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END Delete_Export_Details;

  PROCEDURE Delete_Export_Header
  IS
  BEGIN
    IF nvl(g_account_export_status,'DELETE') = 'DELETE'
       and nvl(g_position_export_status,'DELETE') = 'DELETE' THEN
      delete from psb_worksheets_i
      where export_id = g_export_id;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END Delete_Export_Header;


END PSB_EXCEL2_PVT;

/
