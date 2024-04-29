--------------------------------------------------------
--  DDL for Package Body PSB_BUDGET_ACCOUNT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_BUDGET_ACCOUNT_PVT" AS
/* $Header: PSBVMBAB.pls 120.8.12010000.3 2009/04/02 13:37:26 rkotha ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_Budget_Account_PVT';


/*--------------------------- Global variables -----------------------------*/


  -- The concurrent program executes the execution file in the same session.
  -- Still it is safe to use these global variables here as each execution
  -- of the program, re-populated the global variables first.

  -- The flag determines whether to print debug information or not.
  g_debug_flag             VARCHAR2(1) := 'N' ;

  -- Bug 3458191: To store chart of account id to caching active segments
  g_cached_chart_of_account_id NUMBER :=0;

  -- Table to store active segments for a given chart of accounts.
  TYPE Active_Segments_tbl_type IS TABLE OF VARCHAR2(10)
       INDEX BY BINARY_INTEGER;

  -- To store set of books id for the current set.
  g_set_of_books_id        psb_account_position_sets.set_of_books_id%TYPE;

  -- To store chart of accounts id for the current set.
  g_chart_of_accounts_id   gl_sets_of_books.chart_of_accounts_id%TYPE;

  -- To store total number of active segments for the current chart of
  -- accounts..
  g_total_active_segments  NUMBER := 0;

  -- To store all active segments for the chart of accounts.
  g_active_segments_tbl    Active_Segments_tbl_type;

  -- To store maximum code combination id for a chart of accounts.
  g_max_code_combination_id
		   psb_account_position_sets.max_code_combination_id%TYPE;

  -- To store current account set id.
  g_account_set_id
		   psb_account_position_sets.account_position_set_id%TYPE;

  --
  -- WHO columns variables
  --

  g_current_date           DATE   := sysdate                     ;
  g_current_user_id        NUMBER := NVL(Fnd_Global.User_Id , 0) ;
  g_current_login_id       NUMBER := NVL(Fnd_Global.Login_Id, 0) ;

/*----------------------- End Private variables -----------------------------*/





/* ---------------------- Private Routine prototypes  -----------------------*/

     PROCEDURE Init;
     --
     --
     FUNCTION Populate_Budget_Account_Set ( p_account_set_id  IN  NUMBER ,
                                            -- bug no 3573740
	 										p_full_maintainence_flag IN  VARCHAR2 := 'N')
	      RETURN BOOLEAN;
     --
     --
     FUNCTION Get_Active_Segments ( p_chart_of_accounts_id  IN  NUMBER )
	      RETURN BOOLEAN;

     --
     --
     FUNCTION Make_Account_Assignments
	      (
		  p_line_sequence_id         IN  NUMBER   ,
		  p_include_or_exclude_type  IN  VARCHAR2
	       )
	      RETURN BOOLEAN;

     PROCEDURE  pd
     (
       p_message                   IN      VARCHAR2
     ) ;

/* ------------------ End Private Routines prototypes  ----------------------*/



/*===========================================================================+
 |                     PROCEDURE PSB_Budget_Account_PVT                      |
 +===========================================================================*/
--
-- The Public API to populate account codes for account sets.
--

PROCEDURE Populate_Budget_Accounts
(
  p_api_version               IN       NUMBER ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_set_of_books_id           IN       NUMBER   := FND_API.G_MISS_NUM ,
  p_account_set_id            IN       NUMBER   := FND_API.G_MISS_NUM ,
  -- bug no 3573740
  p_full_maintainence_flag    IN       VARCHAR2 := 'N'
)
IS
  --
  l_api_name          CONSTANT VARCHAR2(30)   := 'Populate_Budget_Accounts' ;
  l_api_version       CONSTANT NUMBER         :=  1.0;
  --
  l_set_of_books_id            psb_account_position_sets.set_of_books_id%TYPE ;
  l_number                     NUMBER;
  --
BEGIN
  --
  SAVEPOINT Populate_Budget_Accounts_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  --
  -- As FND_API.G_MISS_NUM is bigger than NUMBERR(15), Using a local variable.
  --
  IF p_set_of_books_id = FND_API.G_MISS_NUM THEN
    l_set_of_books_id := NULL;
  ELSE
    l_set_of_books_id := p_set_of_books_id ;
  END IF;


  IF ( p_account_set_id = FND_API.G_MISS_NUM ) OR ( p_account_set_id IS NULL)
  THEN
    --
    -- As no parameter is supplied, we have to populate all the account
    -- sets in psb_account_position_sets table.
    --
    FOR l_set_rec IN
    (
      SELECT account_position_set_id
      FROM   psb_account_position_sets
      WHERE  account_or_position_type = 'A'
      AND    set_of_books_id = NVL( l_set_of_books_id, set_of_books_id )
      -- Bug 3458191: Add order by to taking advantage of caching
      ORDER BY set_of_books_id
    )
    LOOP
      --
      -- Perform initilization. To be done for each account set.
      --
      Init;

      --
      -- Call the Populate_Budget_Account_Set routine for each account set.
      --
      -- bug no 3573740 (added parameter p_full_maintainence_flag)
      IF Populate_Budget_Account_Set( l_set_rec.account_position_set_id ,
                                      p_full_maintainence_flag ) THEN
	--
	-- The concurrent program is the only one which calls  the API
	-- without any argument. We need to release lock as soon as an
	-- account_set_id is exploded. Committing will also ensure
	-- that rollback segments do not go out of bounds.
	--
	COMMIT WORK;
	--
	-- Re-establish the savepoint after the commit.
	SAVEPOINT Populate_Budget_Accounts_Pvt ;
	--
      ELSE
	--
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	--
      END IF;
    END LOOP;
    --
  ELSE
    --
    -- Only the passed account set will be populated.
    -- Perform initilization for this set.
    --
    Init;

    --
    -- Call Populate_Budget_Account_Set only for the given account set.
    --
    -- bug no 3573740 (added parameter p_full_maintainence_flag)
    IF NOT ( Populate_Budget_Account_Set( p_account_set_id ,
                                          p_full_maintainence_flag) ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
  END IF;


  --
  IF FND_API.To_Boolean ( p_commit ) THEN
    pd('Final Commiting');
    COMMIT WORK;
  END IF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );
  --

EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Populate_Budget_Accounts_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Populate_Budget_Accounts_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Populate_Budget_Accounts_Pvt ;
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
END Populate_Budget_Accounts;
/*---------------------------------------------------------------------------*/



/*===========================================================================+
 |                     PROCEDURE Init (Private)                              |
 +===========================================================================*/
--
-- Private procedure to perform variable initilization.
--

PROCEDURE Init
IS
--
BEGIN
  --
  -- Date needs to be re-initialized because the concurrent program
  -- may run for days in backgroud.
  --
  g_current_date := sysdate;
  --
END Init;
/*---------------------------------------------------------------------------*/




/*===========================================================================+
 |            FUNCTION  Populate_Budget_Account_Set (Private)                |
 +===========================================================================*/
--
-- This Private function is to populate a given account set.
--

FUNCTION Populate_Budget_Account_Set( p_account_set_id IN NUMBER ,
                                      -- bug no 3573740
                                      p_full_maintainence_flag IN  VARCHAR2 := 'N')
	 RETURN BOOLEAN
IS
  -- Local variables
  l_last_maintained_date    DATE ;
  l_last_update_date        DATE ;

BEGIN
  -- Populate the global variable.
  g_account_set_id := p_account_set_id;

  -- Get various information for the account_set_id.
  SELECT set_of_books_id,
	 NVL( max_code_combination_id, 0 ),
	 NVL( last_maintained_date,    last_update_date - 1 ),
	 last_update_date
  INTO   g_set_of_books_id,
	 g_max_code_combination_id,
	 l_last_maintained_date,
	 l_last_update_date
  FROM   psb_account_position_sets
  WHERE  account_position_set_id = p_account_set_id ;

  -- Get the chart of accounts for the set_of_books_id.
  SELECT chart_of_accounts_id INTO g_chart_of_accounts_id
  FROM   gl_sets_of_books
  WHERE  set_of_books_id = g_set_of_books_id;

  -- Bug 3458191: Introduce the following condition to avoiding extra queries.
  IF g_chart_of_accounts_id <> NVL(g_cached_chart_of_account_id, -99)
  THEN
    -- Finding active segments.
    IF NOT Get_Active_Segments( g_chart_of_accounts_id ) THEN
      RETURN (FALSE);
    END IF;
  END IF;

  --
  -- Lock psb_account_position_sets table to prevent modifications.
  -- Set maintain_status to 'P' (meaning Processing).
  --
  UPDATE psb_account_position_sets
  SET    maintain_status = 'C'
  WHERE  account_position_set_id = p_account_set_id;

  --
  -- Check whether the account_set has been modified since last maintenance.
  -- If Yes, you need to rebuild the psb_budget_accounts table for this
  -- account set.
  --
  IF l_last_update_date > l_last_maintained_date THEN

    -- Delete from psb_budget_accounts
    DELETE psb_budget_accounts
    WHERE  account_position_set_id = p_account_set_id ;

    -- Reset g_max_code_combination_id as you have to rebuild.
    g_max_code_combination_id := 0 ;
  END IF;

  --
  --
  /* start bug 3573740 */
  IF p_full_maintainence_flag = 'Y' THEN
    g_max_code_combination_id := 0;
  END IF;
  /* end bug 3573740 */
  -- Get account ranges in the account set.
  -- We must process Included ranges before Excluded ones.
  --
  FOR l_line_rec IN
  (
    SELECT line_sequence_id, include_or_exclude_type
    FROM   psb_account_position_set_lines
    WHERE  account_position_set_id = p_account_set_id
    ORDER BY include_or_exclude_type DESC
  )
  LOOP
    --
    -- Get the account codes falling in each range represented by
    -- line_sequence_id and put them im psb_budget_accounts table.
    --
    IF NOT Make_Account_Assignments
	   (
	      l_line_rec.line_sequence_id        ,
	      l_line_rec.include_or_exclude_type
	    )
    THEN
      RETURN (FALSE);
    END IF;
  END LOOP;

  --
  -- Update max_code_combination_id info in psb_account_position_sets.
  -- Set maintain_status to 'C' (meaning updated from PSBVMBAB module).
  --
  UPDATE psb_account_position_sets
  SET    maintain_status = 'C' ,
	 last_maintained_date = g_current_date ,
	 max_code_combination_id =
			   ( SELECT max(code_combination_id)
			     FROM gl_code_combinations )
  WHERE account_position_set_id = p_account_set_id;
  --
  RETURN (TRUE);

EXCEPTION
  WHEN OTHERS THEN
    --
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME,
				 'Populate_Budget_Account_Set' );
    END if;
    --
    RETURN (FALSE);
    --
END Populate_Budget_Account_Set;
/*---------------------------------------------------------------------------*/




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
  pd('L' || g_active_segments_tbl(g_total_active_segments));

  -- Bug 3458191
  g_cached_chart_of_account_id := p_chart_of_accounts_id;

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





/*===========================================================================+
 |                FUNCTION  Make_Account_Assignments (Private)               |
 +===========================================================================*/
--
-- Private function to get active account codes for a range and put them
-- in psb_budget_accounts.
--

FUNCTION Make_Account_Assignments
(
    p_line_sequence_id        IN NUMBER   ,
    p_include_or_exclude_type IN VARCHAR2
)
    RETURN BOOLEAN
IS
  -- Local variables
  i                NUMBER;


  -- To store dynamic SQL statement.
  l_sql_insert VARCHAR2(4000);
  l_sql_delete VARCHAR2(4000);
  l_sql_tmp    VARCHAR2(3000);

 /*Start bug: 5736333*/
  TYPE l_ref_type IS REF CURSOR;
  l_ref_csr l_ref_type;
  l_code_combination_id NUMBER;

  TYPE l_ccid_type IS TABLE OF NUMBER;
  l_ccid_tab l_ccid_type := l_ccid_type();

  TYPE l_rowid_type IS TABLE OF VARCHAR2(30);
  l_rowid_tab l_rowid_type := l_rowid_type();

  l_rowid   rowid;
  l_limit NUMBER :=0;
  /*End bug: 5736333*/

--
BEGIN
  pd('Make_Account_Assignments Starting');

  IF p_include_or_exclude_type = 'I' THEN

    pd('Building Insert statement');

    --
    -- Insert the account codes falling in the range.
    --
   /*For bug:5736333 */
   l_sql_insert := ' SELECT      code_combination_id ';    --added for 5736333
   /*End for 5736333*/

  ELSIF p_include_or_exclude_type = 'E' THEN

    pd('Building Delete statement');
    --
    -- Delete the account codes falling in the range.
    --
  /*For bug:5736333: Modified the Delete statement to use select clause
    for fetching rowids. Then used bulk delete */
    l_sql_delete := ' SELECT rowid FROM psb_budget_accounts pba' ||       --added for 5736333
   /*End of addition:5736333*/
		    ' WHERE  account_position_set_id =' ||
		    '                      :account_set_id' ||
   /*For Bug: 5736333. Modified query to use EXISTS instead of the IN clause.*/
		     ' AND   EXISTS ' ||
		    ' ( SELECT 1';

  END IF;
  --
  l_sql_tmp :=   ' FROM gl_code_combinations glcc,' ||
		 '      psb_account_position_set_lines apsl' ||
		 ' WHERE glcc.code_combination_id >' ||
		 '       :max_code_combination_id' ||
		 ' AND   glcc.chart_of_accounts_id = :chart_of_accounts_id' ||
		 ' AND   apsl.line_sequence_id     = :line_sequence_id';


  FOR i in 1..g_total_active_segments
  LOOP
    --
    l_sql_tmp := l_sql_tmp        ||
		 ' AND glcc.'     || g_active_segments_tbl(i) ||
		 ' BETWEEN apsl.' || g_active_segments_tbl(i) ||
		 '_low AND apsl.' || g_active_segments_tbl(i) ||
		 '_high';
  END LOOP;
  --
  l_sql_tmp := l_sql_tmp ||
	       ' AND glcc.template_id IS NULL' ||
	       ' AND glcc.summary_flag = ''N''';


/* ( SRawat : 30-APR-1998 )
   Commenting as the follow is not required. The validation will be done
   at the time worksheet creation.
	       ' AND glcc.enabled_flag = ''Y''' ||
	       ' AND glcc.detail_budgeting_allowed_flag = ''Y''' ||
*/


  IF p_include_or_exclude_type = 'I' THEN
    --
    l_sql_insert := l_sql_insert ||
		    l_sql_tmp ||
   /*For Bug 5736333: Modified to select '1' instead of
   account_position_set_id and code_combination_id in the select clause*/
		    ' AND NOT EXISTS ' ||
		    ' ( SELECT 1'      ||
		    ' FROM  psb_budget_accounts' ||
		    ' WHERE account_position_set_id = :account_set_id' ||
		    ' AND   code_combination_id = glcc.code_combination_id )' ;

    /*Start bug: 5736333 Used REF cursor*/

   OPEN l_ref_csr FOR l_sql_insert USING g_max_code_combination_id,
                                         g_chart_of_accounts_id,
                                         p_line_sequence_id,
                                         g_account_set_id;
   LOOP
   FETCH l_ref_csr INTO l_code_combination_id;
   IF l_code_combination_id is NOT NULL THEN
     l_limit := l_limit+1;
     l_ccid_tab.EXTEND;
     l_ccid_tab(l_ccid_tab.LAST) := l_code_combination_id;

      IF mod(l_limit,25000)=0 THEN

         forall l_ind in 1..l_ccid_tab.COUNT
          insert into psb_budget_accounts(account_position_set_id,
                                                set_of_books_id,
                                                code_combination_id,
                                                last_update_date,
                                                last_updated_by,
                                                last_update_login,
                                                created_by,
                                                creation_date)
                                       values(g_account_set_id,
                                              g_set_of_books_id,
                                              l_ccid_tab(l_ind),
                                              g_current_date,
                                              g_current_user_id,
                                              g_current_login_id,
                                              g_current_user_id,
                                              g_current_date);
         l_ccid_tab.delete;
      END IF;

   END IF;
   EXIT WHEN l_ref_csr%NOTFOUND;
    l_code_combination_id := NULL;
   END LOOP;

   CLOSE l_ref_csr;

   forall l_ind in 1..l_ccid_tab.COUNT
    insert into psb_budget_accounts(account_position_set_id,
                                          set_of_books_id,
                                          code_combination_id,
                                          last_update_date,
                                          last_updated_by,
                                          last_update_login,
                                          created_by,
                                          creation_date)
                                 values(g_account_set_id,
                                        g_set_of_books_id,
                                        l_ccid_tab(l_ind),
                                        g_current_date,
                                        g_current_user_id,
                                        g_current_login_id,
                                        g_current_user_id,
                                        g_current_date);

   /*end of addition for 5736333*/



  ELSE

    /*For Bug 5736333: Added the condition as the Exists clause is used
      instead of IN clause in the query*/

    l_sql_tmp := l_sql_tmp ||' AND pba.code_combination_id = glcc.code_combination_id';

    --
    l_sql_delete := l_sql_delete || l_sql_tmp || ')';

    l_limit := 0;
    OPEN l_ref_csr FOR l_sql_delete USING g_account_set_id,
                                           g_max_code_combination_id,
                                           g_chart_of_accounts_id,
                                           p_line_sequence_id;
   LOOP
   FETCH l_ref_csr INTO l_rowid;
   IF l_rowid is NOT NULL THEN
     l_limit := l_limit+1;
     l_rowid_tab.EXTEND;
     l_rowid_tab(l_rowid_tab.LAST) := l_rowid;

     IF MOD(l_limit,25000)=0 THEN

       FORALL l_ind IN 1..l_rowid_tab.COUNT
          DELETE psb_budget_accounts WHERE rowid=l_rowid_tab(l_ind);

       l_rowid_tab.DELETE;
     END IF;

   END IF;
   EXIT WHEN l_ref_csr%NOTFOUND;
    l_rowid := NULL;
   END LOOP;

   CLOSE l_ref_csr;

   FORALL l_ind in 1..l_rowid_tab.COUNT
        DELETE psb_budget_accounts WHERE rowid=l_rowid_tab(l_ind);

    /*End of Addition: 5736333*/

  --
  END IF;
  --


  /* Used during debugging
  pd( 'Set = ' || g_account_set_id || ' Line = ' ||
			 p_line_sequence_id || ' Type = ' ||
			 p_include_or_exclude_type || ' Rows = ' ||
			 l_rows_processed );
 */

  pd( 'Processing Account Set = ' || g_account_set_id );

  pd('Make_Account_Assignments Done (T)');
  RETURN (TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF l_ref_csr%ISOPEN THEN
      CLOSE l_ref_csr;
    END IF;
    --
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME,
				 'Make_Account_Assignments' );
    END if;
    --
    RETURN (FALSE);

END Make_Account_Assignments;
/*---------------------------------------------------------------------------*/



/*===========================================================================+
 |                   PROCEDURE Populate_Budget_Accounts_CP                   |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Maintain Budget
-- Account Codes'.
--
PROCEDURE Populate_Budget_Accounts_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_set_of_books_id           IN       NUMBER := FND_API.G_MISS_NUM ,
  p_account_set_id            IN       NUMBER := FND_API.G_MISS_NUM ,
  -- bug no 3573740
  p_full_maintainence_flag    IN       VARCHAR2 := 'N'
)
IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Populate_Budget_Accounts_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;
  --
  l_set_of_books_name       gl_sets_of_books.name%TYPE;
  l_account_set_name        psb_account_position_sets.name%TYPE;
  --
BEGIN
  --
  -- SAVEPOINT Populate_Budget_Acct_CP_Pvt ;
  --
  IF ( p_set_of_books_id = FND_API.G_MISS_NUM ) OR ( p_set_of_books_id IS NULL)
  THEN
    FND_FILE.Put_Line( FND_FILE.OUTPUT,
		       'Set of books Name : ALL');
  ELSE
    --
    SELECT name INTO l_set_of_books_name
    FROM   gl_sets_of_books
    WHERE  set_of_books_id = p_set_of_books_id ;
    --
    FND_FILE.Put_Line( FND_FILE.OUTPUT,
		       'Set of books name : ' || l_set_of_books_name );
    --
  END IF;
  --

  --
  IF ( p_account_set_id = FND_API.G_MISS_NUM ) OR ( p_account_set_id IS NULL)
  THEN
    FND_FILE.Put_Line( FND_FILE.OUTPUT, 'Account set name : ALL');
  ELSE
    --
    SELECT name INTO l_account_set_name
    FROM   psb_account_position_sets
    WHERE  account_position_set_id = p_account_set_id ;
    --
    FND_FILE.Put_Line( FND_FILE.OUTPUT,
		       'Account set name  : ' || l_account_set_name );
    --
  END IF;
  --

  PSB_Budget_Account_PVT.Populate_Budget_Accounts
  (
     p_api_version       =>  1.0                         ,
     p_init_msg_list     =>  FND_API.G_TRUE              ,
     p_commit            =>  FND_API.G_FALSE             ,
     p_validation_level  =>  FND_API.G_VALID_LEVEL_FULL  ,
     p_return_status     =>  l_return_status             ,
     p_msg_count         =>  l_msg_count                 ,
     p_msg_data          =>  l_msg_data                  ,
     p_set_of_books_id   =>  p_set_of_books_id           ,
     p_account_set_id    =>  p_account_set_id            ,
     -- bug no 3573740
     p_full_maintainence_flag => p_full_maintainence_flag
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --

  PSB_MESSAGE_S.Print_Success ;
  retcode := 0 ;
  --
  COMMIT WORK;
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    -- ROLLBACK TO Populate_Budget_Acct_CP_Pvt ;
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    -- ROLLBACK TO Populate_Budget_Acct_CP_Pvt ;
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
  WHEN OTHERS THEN
    --
    -- ROLLBACK TO Populate_Budget_Acct_CP_Pvt ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
    END IF ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
END Populate_Budget_Accounts_CP ;
/*---------------------------------------------------------------------------*/



/*===========================================================================+
 |                     PROCEDURE pd (Private)                                |
 +===========================================================================*/
--
-- Private procedure to print debug info. The name is tried to keep as
-- short as possible for better documentaion.
--
PROCEDURE pd
(
   p_message                   IN   VARCHAR2
)
IS
--
BEGIN

  IF g_debug_flag = 'Y' THEN
    NULL;
    -- DBMS_OUTPUT.Put_Line(p_message) ;
  END IF;

END pd ;
/*---------------------------------------------------------------------------*/



/*===========================================================================+
 |                PROCEDURE Validate_Worksheet_CP                            |
 +===========================================================================*/

-- This is the execution file for the concurrent program 'Validate_Worksheet'
-- Created this api for Worksheet Exception report. Bug 3247574

 PROCEDURE Validate_Worksheet_CP
(
  errbuf          OUT  NOCOPY  VARCHAR2,
  retcode         OUT  NOCOPY  VARCHAR2,
  p_worksheet_id  IN   NUMBER
) IS

  l_api_name       CONSTANT VARCHAR2(30)   := 'Validate_Worksheet_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  l_return_status           VARCHAR2(1);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);

BEGIN

  PSB_Budget_Account_PVT.Validate_Worksheet
     (p_api_version => 1.0,
      p_init_msg_list => FND_API.G_TRUE,
      p_commit            =>  FND_API.G_FALSE,
      p_validation_level  =>  FND_API.G_VALID_LEVEL_FULL,
      p_return_status => l_return_status,
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data,
      p_worksheet_id => p_worksheet_id,
      p_msg_wrt_mode => 'OUT');

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;
  COMMIT WORK;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    retcode := 2 ;
    COMMIT WORK ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    retcode := 2 ;
    COMMIT WORK ;

  WHEN OTHERS THEN

    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
    END IF ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    --
    retcode := 2 ;
    COMMIT WORK ;
    --

END Validate_Worksheet_CP;
/*---------------------------------------------------------------------------*/



/*===========================================================================+
 |                PROCEDURE Validate_Worksheet                               |
 +===========================================================================*/

-- This procedure calls all the account and position validation apis
-- Created this api for Worksheet Exception report. Bug 3247574


Procedure Validate_Worksheet (
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 := fnd_api.g_false,
  p_commit               IN VARCHAR2 := fnd_api.g_false,
  p_validation_level     IN NUMBER   := fnd_api.g_valid_level_full,
  p_return_status        OUT  NOCOPY VARCHAR2,
  p_msg_count            OUT  NOCOPY NUMBER,
  p_msg_data             OUT  NOCOPY VARCHAR2,
  p_worksheet_id         IN NUMBER,
  p_msg_wrt_mode	     IN VARCHAR2)
Is

l_api_name            CONSTANT VARCHAR2(30)   := 'Validate_Worksheet';
l_api_version         CONSTANT NUMBER         := 1.0;
l_root_budget_group_id         NUMBER;
l_return_status                VARCHAR2(1);
l_return_status2               VARCHAR2(1);
l_account_set_id               NUMBER;
l_msg_count                    NUMBER;
l_msg_data                     VARCHAR2(2000) ;
l_validation_status            VARCHAR2(1);
l_rep_req_id                   NUMBER;
l_reqid                        NUMBER;
l_data_extract_id              NUMBER;

Begin


  SAVEPOINT  Validate_Worksheet_Pvt;


  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  FOR c_ws_rec in(SELECT NVL(budget_by_position,'N') budget_by_position,
       data_extract_id
       FROM psb_worksheets
      WHERE worksheet_id = p_worksheet_id)
  LOOP

    l_data_extract_id := c_ws_rec.data_extract_id;

    IF c_ws_rec.budget_by_position = 'Y' THEN

       PSB_Budget_Position_Pvt.Populate_Budget_Positions
       (
        p_api_version       =>  1.0                         ,
        p_init_msg_list     =>  FND_API.G_TRUE              ,
        p_commit            =>  FND_API.G_FALSE             ,
        p_validation_level  =>  FND_API.G_VALID_LEVEL_FULL  ,
        p_return_status     =>  l_return_status             ,
        p_msg_count         =>  l_msg_count                 ,
        p_msg_data          =>  l_msg_data                  ,
        p_data_extract_id   =>  l_data_extract_id
       );

       FND_MESSAGE.SET_NAME('PSB', 'PSB_VAL_LINE');
       FND_MSG_PUB.ADD;
       FND_MESSAGE.SET_NAME('PSB', 'PSB_POSITION_VALIDATIONS_DUMMY');
       FND_MSG_PUB.ADD;
       FND_MESSAGE.SET_NAME('PSB', 'PSB_VAL_LINE');
       FND_MSG_PUB.ADD;

       -- position validations
       PSB_POSITIONS_PVT.Position_WS_Validation
         (p_api_version          => 1.0,
          p_return_status        => l_return_status2,
          p_msg_count            => l_msg_count,
          p_msg_data             => l_msg_data,
          p_worksheet_id         => p_worksheet_id,
          p_validation_status    => l_validation_status,
          p_validation_mode      => 'STANDALONE'
         );
    END IF;

  END LOOP;


    l_reqid  := FND_GLOBAL.CONC_REQUEST_ID;

    -- calls the report.
    l_rep_req_id := Fnd_Request.Submit_Request
		       (application   => 'PSB',
			    program       => 'PSBRPERR',
			    description   => 'Position Worksheet Exception Report',
			    start_time    =>  NULL,
			    sub_request   =>  FALSE,
			    argument1     =>  'POSITION_WORKSHEET_EXCEPTION',
			    argument2     =>  p_worksheet_id,
			    argument3     =>  l_reqid
		       );

    IF l_rep_req_id = 0 THEN

      FND_MESSAGE.SET_NAME('PSB', 'PSB_FAIL_TO_SUBMIT_REQUEST');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

    END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Validate_Worksheet_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Validate_Worksheet_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

   WHEN OTHERS THEN
      ROLLBACK TO Validate_Worksheet_Pvt;
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


END Validate_Worksheet;
/*---------------------------------------------------------------------------*/

END PSB_Budget_Account_PVT;

/
