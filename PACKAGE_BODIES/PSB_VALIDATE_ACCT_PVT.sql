--------------------------------------------------------
--  DDL for Package Body PSB_VALIDATE_ACCT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_VALIDATE_ACCT_PVT" AS
/* $Header: PSBVVACB.pls 120.5.12010000.4 2010/04/30 14:43:28 rkotha ship $ */

  G_PKG_NAME CONSTANT   VARCHAR2(30):= 'PSB_VALIDATE_ACCT_PVT';

  -- Table to store active segments for a given chart of accounts.
  TYPE Active_Segments_tbl_type IS TABLE OF VARCHAR2(10)
       INDEX BY BINARY_INTEGER;
  -- To store total number of active segments for the current chart of
  -- accounts..
  g_total_active_segments  NUMBER := 0;

  -- To store all active segments for the chart of accounts.
  g_active_segments_tbl    Active_Segments_tbl_type;

  -- WHO columns variables
  --
  g_current_date           DATE   := sysdate                     ;
  g_current_user_id        NUMBER := NVL(Fnd_Global.User_Id , 0) ;
  g_current_login_id       NUMBER := NVL(Fnd_Global.Login_Id, 0) ;

  /*bug:7572397:start*/

  TYPE g_bg_details_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  g_bg_details_tbl   g_bg_details_tbl_type;

  g_ccid_tbl         g_bg_details_tbl_type;
  g_bg_tbl           g_bg_details_tbl_type;

  g_startdate_pp date;
  g_enddate_cy   date;
  g_parent_budget_group_id   NUMBER;

  /*bug:7572397:end*/

/* ----------------------------------------------------------------------- */
/*                                                                         */
/*                      Private Function and Procedure Declaration         */
/*                                                                         */
/* ----------------------------------------------------------------------- */

-- To perform range check with only the active segments
FUNCTION Get_Active_Segments
	   ( p_chart_of_accounts_id  IN  NUMBER
	   ) RETURN BOOLEAN;

-- Check if a CCID falls within an account position set
FUNCTION Check_APS(
	  p_aps_id IN NUMBER,
	  p_code_combination_id IN NUMBER
	 ) RETURN BOOLEAN;


-- Check if a ccid falls within segx_high and segx_low in account position lines
FUNCTION  Check_Account_Line(
	   p_aps_line_id          IN NUMBER,
	   p_code_combination_id  IN NUMBER
	  ) RETURN BOOLEAN;


-- Check if CC belongs to budget group using budget account table

PROCEDURE Find_CCID_In_Budget_Accounts
	  (
	    p_parent_budget_group_id      IN      NUMBER,
	    p_code_combination_id         IN      NUMBER,
	    p_startdate_pp                IN      DATE,
	    p_enddate_cy                  IN      DATE,
	    p_return_code                 OUT  NOCOPY     NUMBER,
	    p_budget_group_id             OUT  NOCOPY     NUMBER
	 );



-- Check if CC belongs to budget group using range of accounts
PROCEDURE  Find_CCID_In_Budget_Group
	 (
	 p_parent_budget_group_id      IN      NUMBER,
	 p_set_of_books_id             IN      NUMBER,
	 p_flex_code                   IN      NUMBER,
	 p_code_combination_id         IN      NUMBER,
	 p_startdate_pp                IN      DATE,
	 p_enddate_cy                  IN      DATE,
	 p_create_budget_account       IN      VARCHAR2,
	 p_worksheet_id                IN      NUMBER := FND_API.G_MISS_NUM,
	 p_return_code                 OUT  NOCOPY     NUMBER,
	 p_budget_group_id             OUT  NOCOPY     NUMBER
	) ;




/* ----------------------------------------------------------------------- */




PROCEDURE Validate_Account
(
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status              OUT  NOCOPY      VARCHAR2,
  p_msg_count                  OUT  NOCOPY      NUMBER,
  p_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_parent_budget_group_id      IN      NUMBER,
  p_startdate_pp                IN      DATE,
  p_enddate_cy                  IN      DATE,
  p_set_of_books_id             IN      NUMBER,
  p_flex_code                   IN      NUMBER,
  p_create_budget_account       IN      VARCHAR2 := FND_API.G_FALSE,
  p_concatenated_segments       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_worksheet_id                IN      NUMBER := FND_API.G_MISS_NUM,
  p_in_ccid                     IN      NUMBER := FND_API.G_MISS_NUM,
  p_out_ccid                    OUT  NOCOPY     NUMBER,
  p_budget_group_id             OUT  NOCOPY     NUMBER
)
 IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'Validate_Account';
  l_api_version         CONSTANT NUMBER         := 1.0;
  --
  l_return_status VARCHAR2(1);
  --
  l_ccid                NUMBER;
  l_return_code         NUMBER;
  l_budget_group_id     NUMBER;
  l_concat_segments     VARCHAR2(1000);



BEGIN
/* algorithm:

 Get the ccid for the input code combination using flex api
 if ccid is not returned raise error
 if ccid is returned, check if ccid already exists in budget accounts table
   if ccid exists in budget accounts table then
      check if ccid belongs to the budget group or
       to any budget group below that in the budget group hrchy
      if yes -- Account is valid
       else raise error - account does not belong to the budget group

   else  -- this is a valid new account
     - check if ccid belongs to the budget group or
       to any budget group below that in the budget group hrchy using range of accounts
       if ccid belongs to the budget group
	   create records in budget accounts table for the budget group
       else raise error --ccid does not belong to the budget group

*/


  --
  SAVEPOINT Validate_Account_Pvt ;
  -- Standard call to check for call compatibility.
  IF not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  THEN
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- Call Flex API and get ccid

  IF p_in_ccid = FND_API.G_MISS_NUM  THEN

    IF p_concatenated_segments = FND_API.G_MISS_CHAR THEN
      FND_MESSAGE.Set_Name('PSB', 'PSB_INVALID_ARGUMENT');
      FND_MESSAGE.Set_Token('ROUTINE', 'PSB_VALIDATE_ACCT_PVT.Validate_Account');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_ccid := FND_FLEX_EXT.Get_CCID
		 (application_short_name => 'SQLGL',
		  key_flex_code => 'GL#',
		  structure_number => p_flex_code,
		  validation_date => to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS'),
		  concatenated_segments => p_concatenated_segments);

    IF l_ccid = 0 then
       FND_MESSAGE.Set_Name('PSB', 'PSB_INVALID_CC');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR ;
    END IF;


  ELSE
    -- Note: no validation is done if ccid is input
    l_ccid := p_in_ccid;

  END IF;
  -- check if this account is a summary or detail posting not allowed acct
  /*For Bug No : 2715705 Start*/
  --changed validation from posting_allowed flag to budgeting_allowed flag
  --changed the message also accordingly
  IF l_ccid > 0 THEN
    for cc_rec in
     (select detail_budgeting_allowed_flag, summary_flag
      from gl_code_combinations
      where code_combination_id = l_ccid
     )
    loop
      if cc_rec.detail_budgeting_allowed_flag = 'N'
	or  cc_rec.summary_flag = 'Y' then

        /* Bug 3692601 Start */
        l_concat_segments := FND_FLEX_EXT.Get_Segs
                             (application_short_name => 'SQLGL',
                              key_flex_code => 'GL#',
                              structure_number => p_flex_code,
                              combination_id => l_ccid);
        /* Bug 3692601 End */

	FND_MESSAGE.Set_Name('PSB', 'PSB_SUMMARY_DETAIL_BUDGETING');
        /* Bug 3692601 Start */
        FND_MESSAGE.Set_Token('ACCOUNT', l_concat_segments);
        /* Bug 3692601 End */
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR ;
      end if;
    end loop;
  END IF;
  /*For Bug No : 2715705 End*/

  p_out_ccid := l_ccid;

  l_return_code := 0;
  Find_CCID_In_Budget_Accounts
     (
	p_parent_budget_group_id      =>     p_parent_budget_group_id ,
	p_code_combination_id         =>     l_ccid,
	p_startdate_pp                =>     p_startdate_pp,
	p_enddate_cy                  =>     p_enddate_cy,
	p_return_code                 =>     l_return_code,
	p_budget_group_id             =>     l_budget_group_id
     );


  -- 0 - Valid CCID that exists in budget accounts and belongs to the budget group
  -- 1 - Valid CCID that exists in budget accounts and does not belong to the budget group
  IF l_return_code = 0 THEN
    p_budget_group_id := l_budget_group_id;
    RETURN;
  ELSIF l_return_code = 1 THEN
    FND_MESSAGE.Set_Name('PSB', 'PSB_INVALID_BG_CC');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;

  -- Return code status is 2 - CCID does not exist in Budget Accounts Table

  --  reset l_return_code
  l_return_code := 0;
  -- If valid account also add accounts to Budget Accounts Table
  Find_CCID_In_Budget_Group
	 (
	 p_parent_budget_group_id      =>      p_parent_budget_group_id,
	 p_set_of_books_id             =>      p_set_of_books_id,
	 p_flex_code                   =>      p_flex_code,
	 p_code_combination_id         =>      l_ccid,
	 p_startdate_pp                =>      p_startdate_pp,
	 p_enddate_cy                  =>      p_enddate_cy,
	 p_create_budget_account       =>      p_create_budget_account,
	 p_worksheet_id                =>      p_worksheet_id,
	 p_return_code                 =>      l_return_code,
	 p_budget_group_id             =>      l_budget_group_id
	 ) ;

  IF l_return_code = 0 THEN
    p_budget_group_id := l_budget_group_id;
    RETURN;
  ELSIF l_return_code = 1 THEN
    FND_MESSAGE.Set_Name('PSB', 'PSB_INVALID_BG_CC');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;

EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Validate_Account_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Validate_Account_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Validate_Account_Pvt ;
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

END Validate_Account;

/* ----------------------------------------------------------------------- */
PROCEDURE Find_CCID_In_Budget_Accounts
	  (
	    p_parent_budget_group_id      IN      NUMBER,
	    p_code_combination_id         IN      NUMBER,
	    p_startdate_pp                IN      DATE,
	    p_enddate_cy                  IN      DATE,
	    p_return_code                 OUT  NOCOPY     NUMBER,
	    p_budget_group_id             OUT  NOCOPY     NUMBER
	  ) IS

l_cc_in_ba_flag      VARCHAR2(1);
l_cc_in_bg_flag      VARCHAR2(1);

/*bug:7572397:start*/
cursor bg_details_csr is
select sr.budget_group_id,ba.code_combination_id
  from psb_set_relations_v sr,
       psb_budget_accounts ba
 where sr.budget_group_id in
   (select budget_group_id
      from PSB_BUDGET_GROUPS
     where budget_group_type = 'R'
       and (g_startdate_pp is null or effective_start_date <= g_startdate_pp)
       and (effective_end_date is null or effective_end_date >= g_enddate_cy)
     start with budget_group_id = g_parent_budget_group_id
   connect by prior budget_group_id = parent_budget_group_id)
       and sr.account_position_set_id = ba.account_position_set_id;

/*bug:7572397:end*/

BEGIN
-- Returns 0 in p_return_code if ccid exists in Budget Accounts Table and belongs to the budget group
-- Returns 1 in p_return_code if ccid exists in Budget Accounts Table but doesn't belong to the budget group
-- Returns 2 in p_return_code if ccid doesn't exist in Budget Accounts Table

-- Returns the specific budget group the ccid belongs to.
-- This is valid only if p_return_code is 0

  /*bug:7572397:start*/
  IF ((g_ccid_tbl.COUNT = 0) OR
       (NOT g_bg_details_tbl.EXISTS(p_code_combination_id)) OR  --bug:8851338
       (g_parent_budget_group_id IS NOT NULL AND g_parent_budget_group_id <> p_parent_budget_group_id) OR
       (g_startdate_pp IS NOT NULL AND g_startdate_pp <> nvl(p_startdate_pp,g_startdate_pp)) OR
       (g_enddate_cy IS NOT NULL AND g_enddate_cy <> nvl(p_enddate_cy,g_enddate_cy))) THEN

         g_startdate_pp := p_startdate_pp;
         g_enddate_cy := p_enddate_cy;
         g_parent_budget_group_id := p_parent_budget_group_id;
         g_ccid_tbl.delete;
         g_bg_tbl.delete;
         g_bg_details_tbl.delete;

      OPEN bg_details_csr;
      FETCH bg_details_csr BULK COLLECT INTO g_bg_tbl,g_ccid_tbl;

      IF ((bg_details_csr%NOTFOUND) OR (bg_details_csr%ISOPEN))THEN
        CLOSE bg_details_csr;
      END IF;

      FOR l_ccid_ind IN 1..g_ccid_tbl.COUNT LOOP
         g_bg_details_tbl(g_ccid_tbl(l_ccid_ind)) := g_bg_tbl(l_ccid_ind);
      END LOOP;

  END IF;
  /*bug:7572397:end*/

  l_cc_in_ba_flag := FND_API.G_FALSE;
  FOR  ba_rec IN
    (select 1 from PSB_BUDGET_ACCOUNTS
    where code_combination_id = p_code_combination_id)
  LOOP
    l_cc_in_ba_flag := FND_API.G_TRUE;
    EXIT;
  END LOOP;

  IF l_cc_in_ba_flag = FND_API.G_FALSE THEN
     p_return_code := 2;  --ccid doesn't exist in Budget Accounts Table
     RETURN;
  END IF;

  -- ccid is in the budget accounts table
  -- now check if it belongs to the budget group
  l_cc_in_bg_flag := FND_API.G_FALSE;
  p_budget_group_id := 0;

  /*bug:7572397:start*/
  IF g_bg_details_tbl.EXISTS(p_code_combination_id) THEN
     p_budget_group_id := g_bg_details_tbl(p_code_combination_id);
     l_cc_in_bg_flag := FND_API.G_TRUE;
  END IF;
  /*bug:7572397:end*/

  IF l_cc_in_bg_flag = FND_API.G_TRUE THEN
    p_return_code := 0;  -- CCID exists and belongs to the budget group
  ELSE
    p_return_code := 1;  -- CCID exists and does not belong to the budget group
  END IF;

END Find_CCID_In_Budget_Accounts;





/* ----------------------------------------------------------------------- */
PROCEDURE  Find_CCID_In_Budget_Group
	 (
	 p_parent_budget_group_id      IN      NUMBER,
	 p_set_of_books_id             IN      NUMBER,
	 p_flex_code                   IN      NUMBER,
	 p_code_combination_id         IN      NUMBER,
	 p_startdate_pp                IN      DATE,
	 p_enddate_cy                  IN      DATE,
	 p_create_budget_account       IN      VARCHAR2,
	 p_worksheet_id                IN      NUMBER := FND_API.G_MISS_NUM,
	 p_return_code                 OUT  NOCOPY     NUMBER,
	 p_budget_group_id             OUT  NOCOPY     NUMBER
	)
IS
l_cc_in_bg_flag         VARCHAR2(1);
l_root_budget_group_id  NUMBER;
/*For Bug No : 2026323 Start*/
l_ccid_exists           BOOLEAN;
CURSOR c_budget_account(aps_id NUMBER, ccid NUMBER) IS
  SELECT 1
    FROM PSB_BUDGET_ACCOUNTS
   WHERE account_position_set_id = aps_id
     AND code_combination_id = ccid;
/*For Bug No : 2026323 End*/

BEGIN

-- Returns 0 in p_return_code if ccid belongs to the budget group
-- Returns 1 in p_return_code if ccid doesn't belong to the budget group

-- Returns the specific budget group the ccid belongs to.
-- This is valid only if p_return_code is 0

/* algorithm :

  Get account position sets(aps) that belong to the budget group
      and to the budget groups below that in the budget group hrcy

  For each aps loop
       Get aps lines that are excluded
       For each aps line that is excluded loop
	  call function check account line(apslineid, ccid);
	   ( this will return true if the ccid falls with in the segment range)
	  if function returns true then
	   -- the ccid is excluded
	    exit
	  else continue with the next aps line
       end loop

       if the function never returned true for any excluded aps line then
       -- Check for inclusion
       Get aps lines that are included
	  For each aps line that is included loop
	    call function check account line(apslineid, ccid);
	       ( this will return true if the ccid falls with in the segment range)
	    if function returns true then
	    -- the ccid is included
	      exit
	    else continue with the next aps line
	  end loop

	if the function never returned true for any included aps line then
	the ccid does not belong to the account position set


	if the function returned true then,
	   create a line in budget accounts table with the ccid and set id
	   proceed to the next aps

  end loop

  If the function returned true
    Get the Position and Non Position Account Position Sets
    from the Root Budget Group and include the ccid in one of them
    based on segment values.

  If the function call made in inclusion loop never returned true for all aps
  then the ccid does not belong to the budget group, raise an error -- return false

  Added on 28th May 1999
  Get the Account Position Sets for the Allocation Rule Set assigned to the
  Global worksheet and add the new account to the account position set

*/


  -- Find active segments for the chart of accounts
  -- this is used by Check Range
  IF NOT Get_Active_Segments( p_flex_code ) THEN
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_cc_in_bg_flag  := FND_API.G_FALSE;

  -- Get account position sets for the budget group using set relations
  FOR l_set_rec IN
    (
      SELECT aps.account_position_set_id, sr.budget_group_id
      FROM   psb_account_position_sets aps, psb_set_relations sr
      WHERE  sr.account_position_set_id = aps.account_position_set_id
      and    aps.account_or_position_type = 'A'
      and    sr.budget_group_id in (select budget_group_id
	     from PSB_BUDGET_GROUPS
	    where budget_group_type = 'R'
	      and effective_start_date <= p_startdate_pp
	      and (effective_end_date is null or effective_end_date >= p_enddate_cy)
	    start with budget_group_id = p_parent_budget_group_id
	  connect by prior budget_group_id = parent_budget_group_id)
    )
  LOOP
    --dbms_output.put_line(' bg : ' || to_char(l_set_rec.budget_group_id)
    --        || ' aps :'||to_char(l_set_rec.account_position_set_id));

    IF Check_APS(l_set_rec.account_position_set_id,
		 p_code_combination_id
		) THEN

      l_cc_in_bg_flag    := FND_API.G_TRUE;
      p_budget_group_id  := l_set_rec.budget_group_id;

      -- create record in budget accounts table only if flag is on
      IF p_create_budget_account  = FND_API.G_TRUE then

	 INSERT INTO psb_budget_accounts(
		    account_position_set_id,
		    set_of_books_id,
		    code_combination_id,
		    last_update_date,
		    last_updated_by,
		    last_update_login,
		    created_by,
		    creation_date) values
		    (l_set_rec.account_position_set_id,
		     p_set_of_books_id,
		     p_code_combination_id,
		     g_current_date,
		     g_current_user_id,
		     g_current_login_id,
		     g_current_user_id,
		     g_current_date);
      END IF;

      EXIT; -- no need to continue as only one aps can have this ccid in the
	    -- budget group hierarchy

    END IF;


  END LOOP;


  -- Include CCID in Position or Non Position APS found on Root Budget Group
  IF l_cc_in_bg_flag  = FND_API.G_TRUE THEN

    -- Get the Root Budget Group for the Budget Group
    FOR l_bg_rec IN
    (
      SELECT nvl(root_budget_group_id, budget_group_id) root_budget_group_id
      FROM psb_budget_groups_v
      WHERE budget_group_id = p_parent_budget_group_id
    )
    LOOP
      l_root_budget_group_id := l_bg_rec.root_budget_group_id;
    END LOOP;

    FOR l_set_rec IN
    (
    SELECT aps.account_position_set_id, bg.budget_group_id
    FROM  psb_account_position_sets aps, psb_budget_groups bg
    WHERE bg.budget_group_id = l_root_budget_group_id
    AND   aps.account_position_set_id IN
       ( bg.ps_account_position_set_id, bg.nps_account_position_set_id)
    )
    LOOP
      IF Check_APS(l_set_rec.account_position_set_id,
		 p_code_combination_id
		) THEN

	-- create record in budget accounts table only if flag is on
	IF p_create_budget_account  = FND_API.G_TRUE then

	  INSERT INTO psb_budget_accounts(
		    account_position_set_id,
		    set_of_books_id,
		    code_combination_id,
		    last_update_date,
		    last_updated_by,
		    last_update_login,
		    created_by,
		    creation_date) values
		    (l_set_rec.account_position_set_id,
		     p_set_of_books_id,
		     p_code_combination_id,
		     g_current_date,
		     g_current_user_id,
		     g_current_login_id,
		     g_current_user_id,
		     g_current_date);
	END IF;

	EXIT; -- no need to continue as only one aps (position or non position) can have this CCID
      END IF;

    END LOOP;
  END IF;

  -- Added on May 29, 1999
  -- Add CCIDs for Account Position Sets that belong the Allocation set assigned
  -- to the Worksheet
  IF l_cc_in_bg_flag  = FND_API.G_TRUE and ( p_worksheet_id <> FND_API.G_MISS_NUM ) THEN

    FOR alloc_aps_rec IN
    (
      SELECT worksheet_id, w.allocrule_set_id , sr.account_position_set_id,
	     sr.allocation_rule_id, pe.name ,pea.entity_set_id, pea.entity_id,
	     pe.entity_subtype,
	     pe.allocation_type
      FROM  psb_worksheets w,
	    psb_entity_assignment pea,
	    psb_entity pe,
	    psb_set_relations sr
      WHERE pe.entity_type = 'ALLOCRULE'
      AND pea.entity_set_id = w.allocrule_set_id
      AND pea.entity_id = pe.entity_id
      AND sr.allocation_rule_id = pea.entity_id
      AND worksheet_id = p_worksheet_id
    )
    LOOP
      /*For Bug No 2026323 Start*/
      l_ccid_exists := FALSE;
      FOR c_budget_account_rec IN c_budget_account(alloc_aps_rec.account_position_set_id, p_code_combination_id) LOOP
	l_ccid_exists := TRUE;
      END LOOP;
      IF NOT l_ccid_exists THEN
      BEGIN
      /*For Bug No 2026323 End*/
	IF Check_APS(alloc_aps_rec.account_position_set_id,
		   p_code_combination_id
		  ) THEN

	-- create record in budget accounts table only if flag is on
	  IF p_create_budget_account  = FND_API.G_TRUE then

	    INSERT INTO psb_budget_accounts(
		    account_position_set_id,
		    set_of_books_id,
		    code_combination_id,
		    last_update_date,
		    last_updated_by,
		    last_update_login,
		    created_by,
		    creation_date) values
		    (alloc_aps_rec.account_position_set_id,
		     p_set_of_books_id,
		     p_code_combination_id,
		     g_current_date,
		     g_current_user_id,
		     g_current_login_id,
		     g_current_user_id,
		     g_current_date);
	  END IF;


	END IF;
      /*For Bug No 2026323 Start*/
      END;
      END IF;
      /*For Bug No 2026323 End*/
    END LOOP;
  END IF;





  IF l_cc_in_bg_flag  = FND_API.G_TRUE THEN
    p_return_code := 0;
  ELSE
     p_return_code := 1;
  END IF;






END Find_CCID_In_Budget_Group;

/* ----------------------------------------------------------------------- */
FUNCTION Check_APS(
	  p_aps_id IN NUMBER,
	  p_code_combination_id IN NUMBER
	 )
	 RETURN BOOLEAN IS

l_excluded_flag VARCHAR2(1) := FND_API.G_FALSE;
l_included_flag VARCHAR2(1) := FND_API.G_FALSE;

BEGIN
    -- First check exclusion

    FOR l_line_e_rec IN
	(
	   SELECT line_sequence_id, include_or_exclude_type
	   FROM   psb_account_position_set_lines
	   WHERE  account_position_set_id = p_aps_id
	   and include_or_exclude_type = 'E'
	)
    LOOP
      --

      IF Check_Account_Line(l_line_e_rec.line_sequence_id,
			     p_code_combination_id
			    ) THEN
	l_excluded_flag := FND_API.G_TRUE;
	EXIT;  -- if it is excluded, no need to proceed
      END IF;

    END LOOP;

    -- Check for Inclusion only if it is not excluded
    IF l_excluded_flag = FND_API.G_FALSE then
       FOR l_line_i_rec IN
	 (
	   SELECT line_sequence_id, include_or_exclude_type
	   FROM   psb_account_position_set_lines
	   WHERE  account_position_set_id = p_aps_id
	   and include_or_exclude_type = 'I'
	  )
       LOOP
	 --
	 IF Check_Account_Line(l_line_i_rec.line_sequence_id,
				       p_code_combination_id
			    ) THEN
	  l_included_flag := FND_API.G_TRUE;

	  EXIT;  -- if it is included, no need to proceed
	END IF;

      END LOOP;
    END IF;

    IF l_included_flag = FND_API.G_TRUE THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

END  Check_APS;


/* ----------------------------------------------------------------------- */
FUNCTION  Check_Account_Line(
	   p_aps_line_id          IN NUMBER,
	   p_code_combination_id  IN NUMBER
	  ) RETURN BOOLEAN IS

  l_sql      VARCHAR2(5000);
  l_sql_tmp  VARCHAR2(4500);

  l_rec_count    INTEGER;
  l_ignore       INTEGER;
  l_cursor_id    INTEGER;
BEGIN


  l_sql :=  ' SELECT count(*) FROM gl_code_combinations glcc, ' ||
	      ' psb_account_position_set_lines apsl ' ||
	      ' WHERE glcc.code_combination_id = :ccid ' ||
	      ' AND   apsl.line_sequence_id = :line_sequence_id ' ||
	      ' AND glcc.enabled_flag = ''Y''' ||
	      ' AND glcc.detail_budgeting_allowed_flag = ''Y''' ||
	      ' AND glcc.template_id is null ' ;



  FOR i in 1..g_total_active_segments
  LOOP
    --
    l_sql_tmp := l_sql_tmp ||
		 ' AND glcc.' || g_active_segments_tbl(i) ||
		 ' BETWEEN apsl.' || g_active_segments_tbl(i) ||
		 '_low AND apsl.' || g_active_segments_tbl(i) ||
		 '_high';
  END LOOP;
  --
  l_sql := l_sql ||l_sql_tmp;

  l_cursor_id := dbms_sql.open_cursor;

  -- Parsing the statement.
  dbms_sql.parse(l_cursor_id, l_sql, dbms_sql.v7);
  -- Bind input variables
  dbms_sql.bind_variable(l_cursor_id, ':ccid',
			  p_code_combination_id);

  dbms_sql.bind_variable(l_cursor_id, ':line_sequence_id',
			 p_aps_line_id);

  -- define output varaible
  dbms_sql.define_column(l_cursor_id, 1, l_rec_count);
  -- execute
  l_ignore := dbms_sql.execute(l_cursor_id);
  -- fetch
  l_ignore := dbms_sql.fetch_rows(l_cursor_id );
  -- retrieve the value
  dbms_sql.column_value(l_cursor_id,1,l_rec_count);
  -- close the cursor
  dbms_sql.close_cursor(l_cursor_id);

  IF l_rec_count > 0 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

END Check_Account_Line;

--Copy of Get_Active_Segments function in PSB_Account_Position_Set_PVT
/*===========================================================================+
 |                FUNCTION  Get_Active_Segments (Private)                    |
 +===========================================================================*/
--
-- This Private function finds active segments in gl_code_combinations table
-- and stores those in a global table g_active_segments_tab.
--

FUNCTION Get_Active_Segments( p_chart_of_accounts_id IN NUMBER )
	 RETURN BOOLEAN
IS
  /* Start bug #4924031 */
  l_id_flex_code    fnd_id_flex_structures.id_flex_code%TYPE;
  l_application_id  fnd_id_flex_structures.application_id%TYPE;
  l_yes_flag        VARCHAR2(1);
  /* End bug #4924031 */

BEGIN
  --
  -- Initialize for each chart of accounts.
  --
  g_total_active_segments := 0;

  /* Start bug #4924031 */
  l_id_flex_code    := 'GL#';
  l_application_id  := 101;
  l_yes_flag        := 'Y';
  /* End bug #4924031 */


  FOR l_flex_rec IN
  (
    SELECT seg.application_column_name
    FROM   fnd_id_flex_structures str, fnd_id_flex_segments seg
    WHERE  str.application_id = l_application_id    -- bug #4924031
    AND    str.id_flex_code   = l_id_flex_code      -- bug #4924031
    AND    str.id_flex_num    = p_chart_of_accounts_id
    AND    str.id_flex_code   = seg.id_flex_code
    AND    str.id_flex_num    = seg.id_flex_num
    AND    seg.enabled_flag   = l_yes_flag          -- bug #4924031
    AND    seg.application_id = str.application_id  -- bug #4924031
  )
  LOOP
    g_total_active_segments := g_total_active_segments + 1;
    --
    g_active_segments_tbl(g_total_active_segments) :=
					l_flex_rec.application_column_name;
    --
  END LOOP;
  --
  --dbms_output.Put_Line('L'||g_active_segments_tbl(g_total_active_segments));

  RETURN (TRUE);
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME,
				 'Get_Active_Segments' );
    END if;
    --
    RETURN (FALSE);
    --
END Get_Active_Segments;
/*---------------------------------------------------------------------------*/


END PSB_VALIDATE_ACCT_PVT;

/
