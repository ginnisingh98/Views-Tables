--------------------------------------------------------
--  DDL for Package Body CSC_PROFILE_VARIABLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PROFILE_VARIABLE_PVT" AS
/* $Header: cscvpvab.pls 120.3.12010000.3 2009/12/30 08:30:15 mpathani ship $ */


/*************GLOBAL VARIABLES*************************/

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CSC_Profile_Variable_PVT' ;

/* ************************************************************************* *
 *              Forward Declaration of Local Procedures                      *
 *                                                                           *
 *   The following local procedures are called by the APIs in this package.  *
 *                                                                           *
 * ************************************************************************* */

--------------------------------------------------------------------------
-- Procedure Build_Sql_Stmnt
-- Description: Concatenates the select_Clause, from_clause, where_clause
--   and Other_clause to build an sql statement which will be stored in
--   the sql_statement column in cs_prof_blocks table.
-- Input Parameters
-- p_api_name, standard parameter for writting messages
-- p_validation_mode, whether an update or an insert uses CSC_CORE_UTILS_PVT.G_UPDATE
--  or CSC_CORE_UTILS_PVT.G_CREATE global variable
-- p_sql_statement, concatented field using select_Clause, from_clause
--    where_clause and Other_Clause columns using the Build_Sql_Stmnt
--    procedure
-- Out Parameters
-- x_return_status, standard parameter for the return status
--------------------------------------------------------------------------

PROCEDURE Build_Sql_Stmnt
		( p_api_name	IN	VARCHAR2,
		  p_select_clause IN	VARCHAR2,
		  p_from_clause	IN	VARCHAR2,
		  p_where_clause	IN	VARCHAR2,
		  p_other_clause 	IN	VARCHAR2,
		  x_sql_Stmnt	   OUT NOCOPY	VARCHAR2,
		  x_return_status	OUT NOCOPY	VARCHAR2 )
		IS
 l_sql_stmnt VARCHAR2(2000);
BEGIN
	   -- initialize the return status
	   x_return_status := FND_API.G_RET_STS_SUCCESS;
	   -- check if the select_clause and the from_Clause
	   -- is NULL or missing, if so we cannot form an
	   -- sql_statement.

	   IF (p_Select_Clause IS NULL ) and
	       ( p_Select_Clause = CSC_CORE_UTILS_PVT.G_MISS_CHAR ) and
		( p_from_Clause IS NULL ) and
		    ( p_from_Clause = CSC_CORE_UTILS_PVT.G_MISS_CHAR )
		THEN
	      -- invalid arguments exception
	      x_return_status := FND_API.G_RET_STS_ERROR;
	    CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg( p_api_name => p_api_name,
					  p_argument_value  => p_select_clause||' '||p_from_clause,
					  p_argument  => 'p_Sql_Stmnt'
					  );
	END IF;
	      CSC_CORE_UTILS_PVT.Build_Sql_Stmnt
		( p_select_clause => p_SELECT_CLAUSE,
		  p_from_clause	=> p_FROM_CLAUSE,
		  p_where_clause	=> p_WHERE_CLAUSE,
		  p_other_clause 	=> p_OTHER_CLAUSE,
		  X_sql_Stmnt	=> X_SQL_STMNT,
		  X_return_status => x_return_status );

	     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	       x_return_status := FND_API.G_RET_STS_ERROR;
		 CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
					  p_api_name => p_api_name,
					  p_argument_value  => p_select_clause||' '||p_from_clause,
					  p_argument  => 'P_SQL_STMNT'
					  );
	     END IF;
END Build_Sql_Stmnt;
/****************************
PROCEDURE Build_Drilldown_Sql_Stmnt(
	p_block_id	 	IN  NUMBER,
	P_TABLE_COLUMN_TBL 	IN  Table_Column_Tbl_Type,
	x_sql_stmnt 	OUT NOCOPY VARCHAR2 )
IS
 l_select_clause VARCHAR2(1200) := 'SELECT ';
 l_from_clause  VARCHAR2(800) := 'FROM ';
 l_table_count  NUMBER := 0;
 l_column_count NUMBER := 0;
 l_alias 	    VARCHAR2(80) := 'FIRST';
 l_table_name VARCHAR2(600) := 'FIRST';
 l_where_clause VARCHAR2(2000);
 l_sql_stmnt VARCHAR2(2000);

Cursor C2 is
 select where_clause
   from csc_prof_blocks_b
  where block_id = p_block_id;

BEGIN

    FOR i in 1..p_table_column_tbl.count LOOP
      IF ( l_table_name <> p_table_column_tbl(i).table_name OR
	    l_alias <> p_table_column_tbl(i).table_alias ) THEN
        l_table_count := l_table_count + 1;
	  l_table_name := p_table_column_tbl(i).table_name;
	  l_alias := p_table_column_tbl(i).table_alias;
	  if l_table_count = 1 then
	    l_from_Clause := l_from_clause||' '||p_table_column_tbl(i).table_name||' '||l_alias;
	  else
	    l_from_Clause := l_from_clause||', '||p_table_column_tbl(i).table_name||' '||l_alias;
	  end if;
      END IF;
      l_column_count := l_column_count + 1;
      IF l_column_count = 1 THEN
          if l_alias is not null then
	        l_select_clause:= l_select_clause||' '||l_alias||'.'||p_table_column_tbl(i).column_name;
          else
             l_select_clause := l_select_clause||' '||p_table_column_tbl(i).column_name;
          end if;
      ELSE
          if l_alias is not null then
	       l_select_clause := l_select_clause||', '||l_alias||'.'||p_table_column_tbl(i).column_name;
          else
            l_select_clause := l_select_clause||', '||p_table_column_tbl(i).column_name;
          end if;
      END IF;
    END LOOP;

       l_sql_stmnt := l_select_clause||' '||l_from_Clause;
    Open c2;
    Fetch C2 into l_where_clause;
    Close C2;
    IF l_where_clause is not null THEN
       l_sql_stmnt := l_sql_stmnt||' WHERE '||l_where_clause;
    END IF;
    x_sql_stmnt := l_sql_stmnt;

END Build_Drilldown_Sql_Stmnt;
****************************/
PROCEDURE Build_Drilldown_Sql_Stmnt(
	p_block_id	 	IN  NUMBER,
	P_TABLE_COLUMN_TBL 	IN  Table_Column_Tbl_Type,
	x_sql_stmnt 	OUT NOCOPY VARCHAR2 )
IS
 l_select_clause VARCHAR2(1200) := 'SELECT ';
 l_from_clause  VARCHAR2(800) := 'FROM ';
 l_table_count  NUMBER := 0;
 l_column_count NUMBER := 0;
 l_alias 	    VARCHAR2(80) := 'FIRST';
 l_table_name VARCHAR2(600) := 'FIRST';
 l_where_clause VARCHAR2(2000);
 l_other_clause VARCHAR2(2000);
 /* increased to 4000 for bug 4205145 */
 l_sql_stmnt VARCHAR2(4000);

  x_table_name varchar2(100);
  x_column_name varchar2(100);
  v_data_type	 varchar2(100);

  -- NOTE : This cursor might have multiple rows of the same
  -- table under different owners. Since we do not know the owner
  -- of the table in SQL statement, we assume that the datatypes
  -- and columns in the diff copies would be same and pick up only
  -- the first match.

  cursor datatype is
	select data_type from sys.all_Tab_columns
	where table_name = x_table_name
	and  column_name = x_column_name;


-- Changed cursor to include other_clause and from_clause
    -- Bug 1395031
Cursor C2 is
 select where_clause, other_clause,from_clause
   from csc_prof_blocks_b
  where block_id = p_block_id;

Cursor C3 is
  select count(distinct column_name)
  from sys.all_tab_columns
  where table_name = 'CSC_PROF_DRILLDOWN_V'
  and   column_name <> 'ROW_ID';

  l_count Number := 0;
  l_diff_count Number := 0;
  l_drilldown_count Number := 0;

BEGIN
 --- To restrict the no. of columns in the select clause equal to
 --- the columns in CSC_PROF_DRILLDOWN_V
   Open C3;
   Fetch C3 into l_drilldown_count;
   Close C3;

   l_count := p_table_column_tbl.count;
   If p_table_column_tbl.count > l_drilldown_count then
	l_count := l_drilldown_count;
   end If;

   FOR i in 1..l_count LOOP

    x_table_name := p_table_column_tbl(i).table_name;
    x_column_name := p_table_column_tbl(i).column_name;

    open datatype;
    fetch datatype into v_data_type;
    close datatype;

      IF ( l_table_name <> p_table_column_tbl(i).table_name OR
	    l_alias <> p_table_column_tbl(i).table_alias ) THEN
         l_table_count := l_table_count + 1;
	    l_table_name := p_table_column_tbl(i).table_name;
	    l_alias := p_table_column_tbl(i).table_alias;
	  if l_table_count = 1 then
	    l_from_Clause := l_from_clause||' '||p_table_column_tbl(i).table_name||' '||l_alias;
	  else
	    l_from_Clause := l_from_clause||', '||p_table_column_tbl(i).table_name||' '||l_alias;
	  end if;
      END IF;
      l_column_count := l_column_count + 1;
      IF l_column_count = 1 THEN
          if l_alias is not null then
		   IF v_data_type = 'VARCHAR2' then
	         l_select_clause:= l_select_clause||' '||l_alias||'.'||p_table_column_tbl(i).column_name || ' as Column1';
		   ELSIF v_data_type = 'DATE' then       -- added to fix bug 8545672 by mpathani
	         l_select_clause:= l_select_clause||' to_char('||l_alias||'.'||p_table_column_tbl(i).column_name||', '':date_format'' )' || ' as Column1';  -- added to fix bug 8545672 by mpathani
		   ELSE
	         l_select_clause:= l_select_clause||' to_char('||l_alias||'.'||p_table_column_tbl(i).column_name||')' || ' as Column1';
		   END IF;
          else
		   IF v_data_type = 'VARCHAR2' then
               l_select_clause := l_select_clause||' '||p_table_column_tbl(i).column_name || ' as Column1';
	           ELSIF v_data_type = 'DATE' then       -- added to fix bug 8545672 by mpathani
	       l_select_clause := l_select_clause||' to_char('||p_table_column_tbl(i).column_name||', '':date_format'' )' || ' as Column1';  -- added to fix bug 8545672 by mpathani
		   ELSE
               l_select_clause := l_select_clause||' to_char('||p_table_column_tbl(i).column_name||')' || ' as Column1';
		   END IF;
          end if;
      ELSE
          if l_alias is not null then
		  IF v_data_type  = 'VARCHAR2' then
	         l_select_clause := l_select_clause||', '||l_alias||'.'||p_table_column_tbl(i).column_name || ' as Column'||to_char(l_column_count);
		  ELSIF v_data_type = 'DATE' then       -- added to fix bug 8545672 by mpathani
	         l_select_clause := l_select_clause||', to_char('||l_alias||'.'||p_table_column_tbl(i).column_name||', '':date_format'' )' || ' as Column'||to_char(l_column_count);  -- added to fix bug 8545672 by mpathani
		  ELSE
	         l_select_clause := l_select_clause||', to_char('||l_alias||'.'||p_table_column_tbl(i).column_name||')' || ' as Column'||to_char(l_column_count);
		  END IF;
          else
		  IF v_data_type = 'VARCHAR2' then
              l_select_clause := l_select_clause||', '||p_table_column_tbl(i).column_name || ' as Column'||to_char(l_column_count);
	          ELSIF v_data_type = 'DATE' then       -- added to fix bug 8545672 by mpathani
	      l_select_clause := l_select_clause||', to_char('||p_table_column_tbl(i).column_name||', '':date_format'' )' || ' as Column'||to_char(l_column_count);  -- added to fix bug 8545672 by mpathani
		  ELSE
              l_select_clause := l_select_clause||', to_char('||p_table_column_tbl(i).column_name||')' || ' as Column'||to_char(l_column_count);
		  END IF;
          end if;
      END IF;
    END LOOP;

    l_diff_count :=  l_drilldown_count - l_count;
    if l_count > 0 and l_diff_count > 0 Then
    For  l_index in 1..l_diff_count Loop
    l_column_count := l_column_count + 1;
       l_select_clause := l_select_clause||', '|| 'NULL' || ' as Column'||to_char(l_column_count);
    End Loop;
    End If;

    -- l_sql_stmnt := l_select_clause||' '||l_from_Clause;
    -- commented to use the from_clause from table.
    -- Bug 1395031
    Open c2;
    Fetch C2 into l_where_clause,l_other_clause,l_from_clause;
    Close C2;
    IF l_from_clause is not null THEN
       l_sql_stmnt := l_select_clause||' FROM ' ||l_from_clause;
    END IF;
    IF l_where_clause is not null THEN
       l_sql_stmnt := l_sql_stmnt||' WHERE '||l_where_clause ;
    END IF;
/*BUG 1900100 - CAN'T DEFINE A CUSTOMER CARE PROFILE VARIABLE THAT USES
AN "ORDER BY" CLAUSE - for this bug commenting the statement below*/
    /*IF l_other_clause is not null THEN
       l_sql_stmnt := l_sql_stmnt||'  '||l_other_clause ;
    END IF;
*/
    x_sql_stmnt := l_sql_stmnt;

END Build_Drilldown_Sql_Stmnt;

/*************************************************************************/
PROCEDURE Build_PLSQL_Table(
		  p_block_id  IN NUMBER,
		  x_table_column_tbl OUT NOCOPY Table_Column_Tbl_Type )
IS
Cursor C1 is
 Select table_name,column_name,label,alias_name
 from csc_prof_table_columns_vl
 where block_id = p_block_id
 order by decode(drilldown_column_flag,'Y',1,2),column_sequence;
 l_count Number := 0;
BEGIN
    x_table_column_tbl.delete;
    For c1_rec in c1 Loop
      l_count := l_count + 1;
      x_table_column_tbl(l_Count).TABLE_NAME := c1_rec.table_name;
      x_table_column_tbl(l_Count).TABLE_ALIAS:= c1_rec.alias_name;
      x_table_column_tbl(l_Count).COLUMN_NAME:= c1_rec.column_name;
      x_table_column_tbl(l_Count).LABEL := c1_rec.label;
    End loop;
END Build_PLSQL_Table;


PROCEDURE Build_Drilldown_Sql_Stmnt(
	p_block_id  NUMBER,
	x_sql_stmnt OUT NOCOPY VARCHAR2 )
IS
l_table_column_tbl  Table_Column_Tbl_Type;
BEGIN

   Build_PLSQL_Table(
		  p_block_id,
		  l_table_column_tbl );

   Build_Drilldown_Sql_Stmnt(
	p_block_id	,
	l_TABLE_COLUMN_TBL ,
	x_sql_stmnt  );

    --replace :party_id, cust_acct_id,cust_acct_org_id
    --with :global.party_id, :global.cust_acct_id,:global.cust_acct_org_id
    --respectively in sql_Stmnt_for_drilldown which will be used in
    --drill down form.
     x_sql_stmnt := replace(x_sql_stmnt,':party_id',':global.csc_party_id');
     x_sql_stmnt := replace(x_sql_stmnt,':cust_account_id',':global.csc_cust_account_id');
     x_sql_stmnt := replace(x_sql_Stmnt,':org_id',':global.csc_org_id');
     x_sql_stmnt := replace(x_sql_Stmnt,':employee_id',':global.csc_party_id');
     --Begin fix by spamujul for NCR ER# 8473903
     x_sql_stmnt := replace(x_sql_Stmnt,':party_site_id',':global.csc_party_site_id');
     -- End fix by spamujul for NCR ER# 8473903
END;


----------------------------------------------------------------------------
-- Start of Procedure Body Convert_Columns_to_Rec
----------------------------------------------------------------------------

PROCEDURE Convert_Columns_to_Rec (
		    p_block_id				IN  NUMBER   := NULL,
		    p_block_name			IN  VARCHAR2 ,
		    p_block_name_code		IN  VARCHAR2 ,
		    p_description			IN  VARCHAR2 ,
		    p_sql_stmnt        			IN  VARCHAR2 ,
		    p_batch_sql_stmnt		IN  VARCHAR2,
		    p_seeded_flag			IN  VARCHAR2 ,
		    p_sql_stmnt_for_drilldown  IN  VARCHAR2:=NULL ,
		    p_start_date_active		IN  DATE   ,
		    p_end_date_active      	IN  DATE  ,
		    p_currency_code			IN  VARCHAR2,
		    p_object_code			IN  VARCHAR2 :=NULL ,
		    p_select_clause			IN  VARCHAR2 ,
		    p_from_clause			IN  VARCHAR2 ,
		    p_where_clause			IN  VARCHAR2 ,
		    p_order_by_clause		IN  VARCHAR2,
		    p_other_clause	 		IN  VARCHAR2 ,
		    p_block_level			IN  VARCHAR2,
		    p_CREATED_BY			IN  NUMBER  ,
		    p_CREATION_DATE		IN  DATE    ,
		    p_LAST_UPDATED_BY          IN  NUMBER  ,
		    p_LAST_UPDATE_DATE        IN  DATE    ,
		    p_LAST_UPDATE_LOGIN      IN  NUMBER  ,
		    p_OBJECT_VERSION_NUMBER     IN  NUMBER   := NULL,
		    p_APPLICATION_ID		IN  NUMBER   ,
		    x_Profile_Variables_Rec	OUT NOCOPY ProfVar_Rec_Type
		    )
		  IS
BEGIN
	    x_profile_variables_rec.block_id := p_block_id;
	    x_Profile_Variables_Rec.block_name := p_block_name;
	    x_Profile_Variables_Rec.block_name_code := p_block_name_code;
	    x_Profile_Variables_Rec.description := p_description;
	    x_Profile_Variables_Rec.currency_code := p_currency_code;
	    x_Profile_Variables_Rec.sql_stmnt := p_sql_stmnt;
	    x_Profile_Variables_Rec.batch_sql_stmnt := p_batch_sql_stmnt;
	    x_Profile_Variables_Rec.seeded_flag :=p_seeded_flag;
	    x_Profile_Variables_Rec.sql_stmnt_for_drilldown := p_sql_stmnt_for_drilldown;
	    x_Profile_Variables_Rec.object_code := p_object_code;
	    x_Profile_Variables_Rec.start_date_active := p_start_date_active;
	    x_Profile_Variables_Rec.end_date_active := p_end_date_active;
	    x_Profile_Variables_Rec.select_clause := p_select_clause;
	    x_Profile_Variables_Rec.from_clause := p_from_clause;
	    x_Profile_Variables_Rec.where_clause := p_where_clause;
	    x_Profile_Variables_Rec.order_by_clause := p_order_by_clause;
	    x_Profile_Variables_Rec.other_clause := p_other_clause;
	    x_Profile_Variables_Rec.block_level := p_block_level;
	    x_Profile_Variables_Rec.created_by := p_created_by;
	    x_Profile_Variables_Rec.creation_date := p_creation_date;
	    x_Profile_Variables_Rec.last_updated_by := p_last_updated_by;
	    x_Profile_Variables_Rec.last_update_date := p_last_update_date;
	    x_Profile_Variables_Rec.last_update_login := p_last_update_login;
	    x_Profile_Variables_Rec.object_version_number := p_object_version_number;
	    x_Profile_Variables_Rec.application_id := p_application_id;

END Convert_Columns_to_Rec;

----------------------------------------------------------------------
--  Create_Profile_Variable
-----------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

PROCEDURE Create_Profile_Variable(
			    p_api_version_number	IN  NUMBER,
			    p_init_msg_list			IN  VARCHAR2 := CSC_CORE_UTILS_PVT.G_FALSE,
			    p_commit				IN  VARCHAR2 := CSC_CORE_UTILS_PVT.G_FALSE,
			    p_validation_level		IN  NUMBER := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
			    x_return_status			OUT NOCOPY VARCHAR2,
			    x_msg_count			OUT NOCOPY NUMBER,
			    x_msg_data				OUT NOCOPY VARCHAR2,
			    p_block_name			IN  VARCHAR2,
			    p_block_name_code		IN  VARCHAR2 ,
			    p_description			IN  VARCHAR2 ,
			    p_sql_stmnt				IN  VARCHAR2 ,
			    p_batch_sql_stmnt		IN  VARCHAR2,
			    p_sql_stmnt_for_drilldown  IN  VARCHAR2 DEFAULT NULL,
			    p_seeded_flag			IN  VARCHAR2 ,
			    p_start_date_active		IN  DATE ,
			    p_end_date_active		IN  DATE ,
			    p_currency_code			IN  VARCHAR2,
			    p_object_code		  	IN  VARCHAR2 DEFAULT NULL,
			    p_select_clause			IN  VARCHAR2,
			    p_from_clause			IN  VARCHAR2,
			    p_where_clause			IN  VARCHAR2 ,
			    p_order_by_clause		IN  VARCHAR2 DEFAULT NULL,
			    p_other_clause	 		IN  VARCHAR2,
			    p_block_level			IN  VARCHAR2,
			    p_CREATED_BY			IN  NUMBER,
			    p_CREATION_DATE		IN  DATE ,
			    p_LAST_UPDATED_BY		IN  NUMBER,
			    p_LAST_UPDATE_DATE		IN  DATE ,
			    p_LAST_UPDATE_LOGIN	IN  NUMBER,
			    x_OBJECT_VERSION_NUMBER OUT NOCOPY NUMBER,
			    p_APPLICATION_ID		IN  NUMBER,
			    x_block_id         			OUT NOCOPY NUMBER
			    ) IS
l_prof_var_rec ProfVar_Rec_Type;
BEGIN
	  Convert_Columns_to_Rec (
	    p_block_name           		=> p_block_name,
	    p_block_name_code      	=> p_block_name_code,
	    p_description          		=> p_description,
	    p_sql_stmnt        			=> p_sql_stmnt,
	    p_batch_sql_stmnt		=> p_batch_sql_stmnt,
	    p_seeded_flag			=> p_seeded_flag,
	    p_sql_stmnt_for_drilldown	=> p_sql_stmnt_for_drilldown,
	    p_start_date_active    	=> p_start_date_active,
	    p_end_date_active      	=> p_end_date_active,
	    p_currency_code			=> p_currency_code,
	    p_object_code			=> p_object_code,
	    p_select_clause			=> p_select_clause,
	    p_from_clause			=> p_from_clause,
	    p_where_clause			=> p_where_clause,
	    p_order_by_clause		=> p_order_by_clause,
	    p_other_clause	 		=> p_other_clause,
	    p_block_level			=> p_block_level,
	    p_CREATED_BY			=> p_CREATED_BY,
	    p_CREATION_DATE             => p_CREATION_DATE,
	    p_LAST_UPDATED_BY          => p_LAST_UPDATED_BY,
	    p_LAST_UPDATE_DATE        => p_LAST_UPDATE_DATE,
	    p_LAST_UPDATE_LOGIN      => p_LAST_UPDATE_LOGIN,
	    p_APPLICATION_ID		=> p_APPLICATION_ID,
	    x_Profile_Variables_Rec	=> l_prof_var_rec
	    );

	  Create_Profile_Variable(
	    p_api_version_number	=> p_api_version_number,
	    p_Init_Msg_List			=> p_init_msg_list,
	    P_Commit				=> p_commit,
	    P_Validation_Level 		=> p_validation_level,
	    P_prof_var_rec 			=> l_prof_var_rec,
	    x_msg_data 			=> x_msg_data,
	    x_msg_count			=> x_msg_count,
	    x_return_status			=> x_return_status,
	    x_block_id  				=> x_block_id,
	    x_object_version_number	=> x_object_version_number
	    );

END;
--> with record type
PROCEDURE  Create_Profile_Variable(
				    p_api_version_number	IN	NUMBER,
				    p_init_msg_list			IN	VARCHAR2 := CSC_CORE_UTILS_PVT.G_FALSE,
				    p_commit				IN	VARCHAR2 := CSC_CORE_UTILS_PVT.G_FALSE,
				    p_validation_level 		IN	NUMBER := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
				    p_prof_var_rec 			IN 	ProfVar_Rec_Type := G_MISS_PROF_REC,
				    x_msg_data				OUT NOCOPY	VARCHAR2,
				    x_msg_count			OUT NOCOPY	NUMBER,
				    x_return_status 			OUT NOCOPY	VARCHAR2,
				    x_block_id 				OUT NOCOPY	NUMBER,
				    x_object_version_number	OUT NOCOPY NUMBER
				    )
				IS
l_api_version		NUMBER		:=  1.0 ;
l_api_name		VARCHAR2(30) := 'Create_Profile_Variable_PVT' ;
l_api_name_full	VARCHAR2(61) := G_PKG_NAME || '.' || l_api_name ;
l_block_id			NUMBER;

--local variables
l_prof_var_rec	ProfVar_Rec_Type := p_prof_var_rec;

l_object_type_code VARCHAR2(80);
l_object_id number;
BEGIN
	-- Standard start of API savepoint
	SAVEPOINT Create_Profile_Variable_PVT;
	-- Standard call to check for call compatibility
	IF NOT FND_API.Compatible_API_Call(l_api_version,
				           p_api_version_number,
				           l_api_name,
                                   G_PKG_NAME )
	THEN
    		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  	END IF;
  	-- Initialize message list if p_init_msg_list is set to TRUE
  	IF FND_API.To_Boolean(p_init_msg_list)
	THEN
    		FND_MSG_PUB.Initialize;
  	END IF;
  	-- Initialize API return status to success
  	x_return_status := FND_API.G_RET_STS_SUCCESS;
  	-- we have to build the sql statement in advance before
  	-- going into the validation part to validate the whole
  	-- sql statement
  	/* jamose duplicate validation; validated under build_sql_stmnt
  	IF p_prof_var_rec.select_clause = CSC_CORE_UTILS_PVT.G_MISS_CHAR THEN
 		l_prof_var_rec.select_clause := NULL;
  	END IF;
  	IF p_prof_var_rec.from_clause = CSC_CORE_UTILS_PVT.G_MISS_CHAR THEN
		l_prof_var_rec.from_clause := NULL;
  	END IF;
  	-- jamose */
  	IF p_prof_var_rec.where_clause = CSC_CORE_UTILS_PVT.G_MISS_CHAR THEN
		l_prof_var_rec.where_clause := NULL;
  	END IF;
  	IF p_prof_var_rec.other_clause = CSC_CORE_UTILS_PVT.G_MISS_CHAR THEN
      		l_prof_var_rec.other_clause := NULL;
  	END IF;
  	Build_Sql_Stmnt( 	p_api_name		=> l_api_name,
    		p_select_clause				=> l_prof_var_rec.select_clause,
    		p_from_clause					=> l_prof_var_rec.from_clause,
    		p_where_clause				=> l_prof_var_rec.where_clause,
    		p_other_clause				=> l_prof_var_rec.other_clause,
    		x_sql_stmnt					=> l_prof_var_rec.sql_stmnt,
    		x_return_status				=> x_return_status );
   	IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
     		RAISE FND_API.G_EXC_ERROR;
   	ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
     		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   	END IF;
  	-- ----------------------------------------------------------------------
  	-- Apply business-rule validation to all required and passed parameters
  	-- if validation level is set.
  	-- ----------------------------------------------------------------------
  	IF (p_validation_level >  CSC_CORE_UTILS_PVT.G_VALID_LEVEL_NONE) THEN
   		-- Check for all the required attributes that are being passed should be there
   		-- and should not be passed as null. If passed as null then we will raise error
   		-- Also Check  if Seeded_Flag = 'Y'  and  then allow / disallow updates
   		-- of certain fields

   		Validate_Profile_Variables(
			     p_api_name	=> l_api_name_full,
      			p_validation_mode	=> CSC_CORE_UTILS_PVT.G_CREATE,
      			P_validate_rec	=> l_prof_var_rec,
      			x_return_status  	=> x_return_status,
                        x_msg_count  =>x_msg_count,
                        x_msg_data   =>x_msg_data );

   		IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
     			RAISE FND_API.G_EXC_ERROR;
   		ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
     			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   		END IF;

  	END IF ; /*** p_validation_level ****/

	     --replace :party_id, cust_acct_id,cust_acct_org_id
		--with :global.party_id, :global.cust_acct_id,:global.cust_acct_org_id
		--respectively in sql_Stmnt_for_drilldown which will be used in
		--drill down form.
	     l_prof_var_rec.sql_stmnt_for_drilldown := replace(l_prof_var_rec.sql_stmnt_for_drilldown,
										 ':party_id',':global.csc_party_id');
	     l_prof_var_rec.sql_stmnt_for_drilldown := replace(l_prof_var_rec.sql_stmnt_for_drilldown,
										 ':cust_account_id',':global.csc_cust_account_id');
	     l_prof_var_rec.sql_stmnt_for_drilldown := replace(l_prof_var_rec.sql_Stmnt_for_drilldown,
										 ':org_id',':global.csc_org_id');
	-- Begin fix by spamujul for NCR ER#8473903
	     l_prof_var_rec.sql_stmnt_for_drilldown := replace(l_prof_var_rec.sql_Stmnt_for_drilldown,
										 ':party_site_id',':global.csc_party_site_id');
	-- End fix by spamujul for NCR ER#8473903
		-- Build an insert record, check if any of the parameters
		-- have been not been passed, if not assign a NULL.
		-- The mandatory columns have already been validated in
		-- Validate_Profile_Variables if the validation level is
		-- set to FULL.

 	CSC_PROF_BLOCKS_PKG.Insert_Row(
				px_BLOCK_ID			=> x_block_id,
				p_CREATED_BY		=> FND_GLOBAL.USER_ID,
				p_CREATION_DATE		=>   sysdate,
				p_LAST_UPDATED_BY	=> FND_GLOBAL.USER_ID,
				p_LAST_UPDATE_DATE	=> sysdate,
				p_LAST_UPDATE_LOGIN	=> FND_GLOBAL.CONC_LOGIN_ID,
				p_BLOCK_NAME		=> l_prof_var_rec.BLOCK_NAME,
				p_DESCRIPTION		=> l_prof_var_rec.DESCRIPTION,
				p_START_DATE_ACTIVE   => l_prof_var_rec.START_DATE_ACTIVE,
				p_END_DATE_ACTIVE	=> l_prof_var_rec.END_DATE_ACTIVE,
				p_SEEDED_FLAG		=> l_prof_var_rec.SEEDED_FLAG,
				p_BLOCK_NAME_CODE    => l_prof_var_rec.BLOCK_NAME_CODE,
				p_OBJECT_CODE  		=> l_prof_var_rec.object_code,
				p_SQL_STMNT_FOR_DRILLDOWN    => l_prof_var_rec.SQL_STMNT_FOR_DRILLDOWN,
				p_SQL_STMNT					=> l_prof_var_rec.SQL_STMNT,
				p_BATCH_SQL_STMNT			=> l_prof_var_rec.BATCH_SQL_STMNT,
				p_SELECT_CLAUSE				=> l_prof_var_rec.SELECT_CLAUSE,
				p_CURRENCY_CODE				=> l_prof_var_rec.CURRENCY_CODE,
				p_FROM_CLAUSE				=> l_prof_var_rec.FROM_CLAUSE,
				p_WHERE_CLAUSE				=> l_prof_var_rec.WHERE_CLAUSE,
				p_OTHER_CLAUSE				=> l_prof_var_rec.other_clause,
				p_BLOCK_LEVEL				=> l_prof_var_rec.block_level,
				     x_OBJECT_VERSION_NUMBER	=> x_OBJECT_VERSION_NUMBER,
				p_APPLICATION_ID				=> l_prof_var_rec.APPLICATION_ID
	);

  	--
  	-- Standard check of p_commit
  	IF FND_API.To_Boolean(p_commit) THEN
    		COMMIT WORK;
  	END IF;

  	-- Standard call to get message count and if count is 1, get message info

  	FND_MSG_PUB.Count_And_Get(
	   p_encoded => FND_API.G_FALSE,
    	   p_count => x_msg_count,
        p_data  => x_msg_data );


   EXCEPTION
  	WHEN FND_API.G_EXC_ERROR THEN
    		ROLLBACK TO Create_Profile_Variable_PVT;
    		x_return_status := FND_API.G_RET_STS_ERROR;
    		/* FND_MSG_PUB.Count_And_Get
      			( p_encoded => FND_API.G_FALSE,
				  p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			); */
          APP_EXCEPTION.RAISE_EXCEPTION;
  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		ROLLBACK TO Create_Profile_Variable_PVT;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		/* FND_MSG_PUB.Count_And_Get
      			( p_encoded => FND_API.G_FALSE,
				  p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			); */
          APP_EXCEPTION.RAISE_EXCEPTION;
  	WHEN OTHERS THEN
    		ROLLBACK TO Create_Profile_Variable_PVT;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		--IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                --			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    		-- END IF;
		FND_MSG_PUB.Build_Exc_Msg;
    		/* FND_MSG_PUB.Count_And_Get
      			( p_encoded => FND_API.G_FALSE,
				  p_count => x_msg_count,
        		  	  p_data  => x_msg_data
      			); */
          APP_EXCEPTION.RAISE_EXCEPTION;
END Create_Profile_Variable ;

PROCEDURE Create_table_column(
    P_Api_Version_Number      IN   NUMBER,
    P_Init_Msg_List           IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                  IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level        IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    p_Table_Column_Tbl		   IN   Table_Column_Tbl_Type := G_MISS_Table_Column_TBL,
    X_TABLE_COLUMN_ID     	   OUT NOCOPY NUMBER,
    X_object_version_number	OUT NOCOPY NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    )
IS
l_table_column_rec Table_Column_Rec_Type := G_MISS_Table_Column_Rec;
BEGIN

  FOR i in 1..p_Table_Column_Tbl.Count LOOP

	l_table_Column_rec.Column_Name := p_Table_Column_tbl(i).Column_Name;
	l_table_Column_rec.Table_Name := p_Table_Column_tbl(i).Table_Name;
	l_table_Column_rec.Label := p_Table_Column_tbl(i).Label;
	l_table_Column_rec.Table_Alias := p_Table_Column_Tbl(i).Table_Alias;
     l_table_Column_rec.Column_Sequence := p_Table_Column_Tbl(i).Column_Sequence;
     l_table_column_rec.block_id := p_table_column_tbl(i).block_id;

      -- nullify the table column id so as not to pass the old id
      x_table_column_id := NULL;

      Create_table_column(
        P_Api_Version_Number     => p_api_version_number,
        P_Init_Msg_List          => p_init_msg_list,
        P_Commit                 => p_commit,
        p_validation_level       => p_validation_level,
        p_Table_Column_rec	   => l_table_column_rec,
        X_TABLE_COLUMN_ID     	=> x_table_column_id,
        X_OBJECT_VERSION_NUMBER     => x_object_version_number,
        X_Return_Status             => x_return_status,
        X_Msg_Count                 => x_msg_count,
        X_Msg_Data                  => x_msg_Data );

  END LOOP;
/*      --Need to work on this one...
      -- If drilldown sql statement is not passed in or is null then
      Select object_version_number
      into l_object_version_number
      from csc_prof_blocks_b
      where block_id = p_table_column_rec.block_id;

      Update_Profile_Variable(
      p_api_version_number  => 1.0,
      p_validation_level    => CSC_CORE_UTILS_PVT.G_VALID_LEVEL_NONE,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      px_object_version_number => l_object_version_number,
      p_block_id            => l_table_column_rec.block_id,
      p_sql_stmnt_for_drilldown => ltrim(rtrim(l_sql_stmnt_for_drilldown)));

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF; */
END;

PROCEDURE Create_table_column(
    P_Api_Version_Number    IN   NUMBER,
    P_Init_Msg_List         IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level      IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    p_Table_Column_REC		 IN   Table_Column_Rec_Type := G_MISS_Table_Column_REC,
    X_TABLE_COLUMN_ID     	 OUT NOCOPY NUMBER,
    X_OBJECT_VERSION_NUMBER OUT NOCOPY NUMBER,
    X_Return_Status         OUT NOCOPY VARCHAR2,
    X_Msg_Count             OUT NOCOPY NUMBER,
    X_Msg_Data              OUT NOCOPY  VARCHAR2
    )
 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_table_column';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_table_Column_rec  Table_Column_Rec_Type := p_table_column_rec;
BEGIN

      -- Standard Start of API savepoint
	SAVEPOINT CREATE_Table_Column_PVT;



      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

       IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
	 THEN

	   -- Check for all the required attributes that are being passed should be there
         -- and should not be passed as null. If passed as null then raise error

	    Validate_table_column(
	           p_api_name	   => l_api_name,
		      p_Init_Msg_List    => p_Init_Msg_List,
	           p_validation_mode  => CSC_CORE_UTILS_PVT.G_CREATE,
	           p_Validate_Rec     => l_Table_Column_Rec,
	           x_return_status    => x_return_status);
	  END IF;

	  IF (x_return_status<>FND_API.G_RET_STS_SUCCESS) THEN
	          RAISE FND_API.G_EXC_ERROR;
	  END IF;

	-- Build an insert record, check if any of the parameters
	-- have been not been passed, if not assign a NULL.
	-- The mandatory columns have already been validated in
	-- Validate_table_columns if the validation level is
	-- set to FULL.

	CSC_PROF_TABLE_COLUMNS_PKG.Insert_Row(
	px_TABLE_COLUMN_ID  => x_TABLE_COLUMN_ID,
	p_BLOCK_ID  => l_Table_Column_rec.BLOCK_ID,
	p_TABLE_NAME  => l_Table_Column_rec.TABLE_NAME,
	p_COLUMN_NAME  => l_Table_Column_rec.COLUMN_NAME,
	p_LABEL  => l_Table_Column_rec.LABEL,
  	p_TABLE_ALIAS => l_Table_Column_rec.Table_Alias,
	p_COLUMN_SEQUENCE => l_Table_Column_rec.Column_Sequence,
	p_DRILLDOWN_COLUMN_FLAG => l_Table_Column_rec.DRILLDOWN_COLUMN_FLAG,
	p_LAST_UPDATE_DATE  => SYSDATE,
	p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
	p_CREATION_DATE  => SYSDATE,
	p_CREATED_BY  => FND_GLOBAL.USER_ID,
	p_LAST_UPDATE_LOGIN  =>  FND_GLOBAL.CONC_LOGIN_ID,
        p_SEEDED_FLAG   => l_Table_Column_rec.seeded_flag,
      x_OBJECT_VERSION_NUMBER => x_object_version_number );


     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	          RAISE FND_API.G_EXC_ERROR;
     END IF;


      --
      -- End of API body
      --


      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get(
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data);

  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
           ROLLBACK TO CREATE_Table_Column_PVT;
           x_return_status :=  FND_API.G_RET_STS_ERROR ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;
           APP_EXCEPTION.RAISE_EXCEPTION;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           ROLLBACK TO CREATE_Table_Column_PVT;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;
           APP_EXCEPTION.RAISE_EXCEPTION;
      WHEN OTHERS THEN
           ROLLBACK TO CREATE_Table_Column_PVT;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           --IF FND_MSG_PUB.Check_Msg_Level
           --               (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           --THEN
           --FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
           --END IF ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;
           APP_EXCEPTION.RAISE_EXCEPTION;
End Create_table_column;

----------------------------------------------------------------------
-- Update_Profile_Variable
-----------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

PROCEDURE Update_Profile_Variable(
    p_api_version_number  IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := CSC_CORE_UTILS_PVT.G_FALSE,
    p_commit              IN  VARCHAR2 := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level    IN  NUMBER   := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_block_id            IN  NUMBER ,
    p_block_name          IN  VARCHAR2 DEFAULT NULL,
    p_block_name_code     IN  VARCHAR2 DEFAULT NULL,
    p_description         IN  VARCHAR2 DEFAULT NULL,
    p_currency_code	     IN  VARCHAR2 DEFAULT NULL,
    p_sql_stmnt           IN  VARCHAR2 DEFAULT NULL,
    p_batch_sql_stmnt     IN  VARCHAR2 DEFAULT NULL,
    p_seeded_flag         IN  VARCHAR2 DEFAULT NULL,
    --p_form_function_id  IN	NUMBER  ,
    p_object_code		     IN	VARCHAR2 DEFAULT NULL  ,
    p_start_date_active   IN  DATE DEFAULT NULL,
    p_end_date_active     IN  DATE DEFAULT NULL ,
    p_sql_stmnt_for_drilldown IN  VARCHAR2 DEFAULT NULL ,
    p_select_clause		IN  VARCHAR2 DEFAULT NULL ,
    p_from_clause		   IN  VARCHAR2 DEFAULT NULL,
    p_where_clause		IN  VARCHAR2 DEFAULT NULL,
    p_order_by_clause	IN  VARCHAR2 DEFAULT NULL ,
    p_other_clause		IN  VARCHAR2 DEFAULT NULL,
    p_block_level       IN  VARCHAR2 DEFAULT NULL,
    p_CREATED_BY        IN  NUMBER DEFAULT NULL,
    p_CREATION_DATE     IN  DATE DEFAULT NULL ,
    p_LAST_UPDATED_BY   IN  NUMBER DEFAULT NULL,
    p_LAST_UPDATE_DATE  IN  DATE DEFAULT NULL,
    p_LAST_UPDATE_LOGIN IN  NUMBER DEFAULT NULL,
    px_OBJECT_VERSION_NUMBER  IN OUT NOCOPY  NUMBER ,
    p_APPLICATION_ID          IN  NUMBER DEFAULT NULL)

IS
l_prof_var_rec  ProfVar_Rec_Type;
Begin
Convert_Columns_to_Rec (
    p_block_id			=> p_block_id,
    p_block_name           	=> p_block_name,
    p_block_name_code      	=> p_block_name_code,
    p_description          	=> p_description,
    p_sql_stmnt        		=> p_sql_stmnt,
    p_batch_sql_stmnt        	=> p_batch_sql_stmnt,
    p_seeded_flag               => p_seeded_flag,
    p_sql_stmnt_for_drilldown	=> p_sql_stmnt_for_drilldown,
    p_start_date_active    	=> p_start_date_active,
    p_end_date_active      	=> p_end_date_active,
    p_currency_code	        => p_currency_code,
    --p_form_function_id 	=> p_form_function_id,
    p_object_code		=> p_object_code,
    p_select_clause		=> p_select_clause,
    p_from_clause		=> p_from_clause,
    p_where_clause		=> p_where_clause,
    p_order_by_clause		=> p_order_by_clause,
    p_other_clause	 	=> p_other_clause,
    p_block_level               => p_block_level,
    p_CREATED_BY                => p_CREATED_BY,
    p_CREATION_DATE             => p_CREATION_DATE,
    p_LAST_UPDATED_BY           => p_LAST_UPDATED_BY,
    p_LAST_UPDATE_DATE          => p_LAST_UPDATE_DATE,
    p_LAST_UPDATE_LOGIN         => p_LAST_UPDATE_LOGIN,
    p_APPLICATION_ID            => p_APPLICATION_ID,
    x_Profile_Variables_Rec     => l_prof_var_rec
    );

    Update_Profile_Variable(
    p_api_version_number   => p_api_version_number,
    P_Init_Msg_List	=> p_init_msg_list,
    P_Commit		=> p_commit,
    P_Validation_Level  => p_validation_level,
    P_prof_var_rec 	=> l_prof_var_rec,
    Px_Object_version_number => px_object_version_number,
    x_msg_data 		=> x_msg_data,
    x_msg_count 	=> x_msg_count,
    x_return_status 	=> x_return_status
    );

End Update_Profile_Variable;

----------------------------------------------------------------------
-- Update_Profile_Variable
-----------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

PROCEDURE Update_Profile_Variable(
	p_api_version_number	IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2:= CSC_CORE_UTILS_PVT.G_FALSE,
	p_commit		IN	VARCHAR2:= CSC_CORE_UTILS_PVT.G_FALSE,
	p_validation_level 	IN	NUMBER := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
	p_prof_var_rec 		IN 	ProfVar_Rec_Type := G_MISS_PROF_REC,
        px_Object_Version_Number IN OUT NOCOPY   NUMBER,
	x_msg_data	  	OUT NOCOPY	VARCHAR2,
	x_msg_count	  	OUT NOCOPY	VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2 )

IS
l_api_name       CONSTANT  VARCHAR2(30) := 'Update_Profile_Variable' ;
l_api_name_full  CONSTANT  VARCHAR2(61) := G_PKG_NAME || '.' || l_api_name ;
l_api_version    CONSTANT  NUMBER       := 1.0 ;

-- record to get the old records
l_OLD_PROF_VAR_REC	CSC_PROF_BLOCKS_VL%ROWTYPE ;

l_prof_var_rec	ProfVar_Rec_Type := P_prof_Var_Rec;

BEGIN
	-- standard start of API savepoint
	SAVEPOINT Update_Profile_Variable_Pvt ;

	-- Standard Call to check API compatibility
  	IF NOT FND_API.Compatible_API_Call( l_api_version,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME  )
	THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	END IF ;


  	-- Initialize the message list  if p_msg_list is set to TRUE
	IF FND_API.To_Boolean(p_init_msg_list)   THEN
	  FND_MSG_PUB.initialize ;
	END IF ;


	-- Initialize the API Return Success to True
        x_return_status := FND_API.G_RET_STS_SUCCESS ;

  	-- Fetch the existing Customer Profile Variable Record and lock the record
  	-- for update.
 	-- If lock fails we have to abort
  	-- Get record INTO l_old_prof_var_rec variable
  	GET_PROF_BLOCKS(
    	    p_api_name        =>  l_api_name,
    	    p_BLOCK_ID        =>  p_prof_var_rec.BLOCK_ID,
	    p_object_version_number => px_object_version_number,
    	    X_PROF_BLOCKS_REC  => l_OLD_PROF_VAR_REC,
    	    x_return_status   =>  x_return_status );
  	-- If any error abort the API
  	IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	   RAISE FND_API.G_EXC_ERROR;
  	ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  	END IF;


	-- we have to build the sql statement in advance before
  	-- going into the validation part. Bcauz if any of the
  	-- select, from, where or other columns change the whole
  	-- sql statement gets effected.
    l_prof_var_rec.select_clause := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(l_prof_var_rec.select_clause,l_old_prof_var_rec.select_clause);
    l_prof_var_rec.from_clause := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(l_prof_var_rec.from_clause,l_old_prof_var_rec.from_clause);
    l_prof_var_rec.where_clause := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(l_prof_var_rec.where_clause,l_old_prof_var_rec.where_clause);
    l_prof_var_rec.other_clause := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(l_prof_var_rec.other_clause,l_old_prof_var_rec.other_clause);
    l_prof_var_rec.object_code := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(l_prof_var_rec.object_code,l_old_prof_var_rec.object_code);
    l_prof_var_rec.sql_stmnt_for_drilldown := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(l_prof_var_rec.sql_stmnt_for_drilldown,l_old_prof_var_rec.sql_stmnt_for_drilldown);
    l_prof_var_rec.block_name := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(l_prof_var_rec.block_name,l_old_prof_var_rec.block_name);
    l_prof_var_rec.block_name_code := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(l_prof_var_rec.block_name_code,l_old_prof_var_rec.block_name_code);


	-- build the sql statement if any of the columns have changed

	IF ((l_prof_var_rec.select_clause <> l_old_prof_var_rec.select_clause)
	   OR (l_prof_var_rec.from_clause <> l_old_prof_var_rec.from_clause)
	    OR (l_prof_var_rec.where_clause <> l_old_prof_var_rec.where_clause)
	     OR (l_prof_var_rec.other_clause <> l_old_prof_var_rec.other_clause))
	THEN
        Build_Sql_Stmnt(
	     p_api_name	=> l_api_name,
	     p_SELECT_CLAUSE	=> l_prof_var_rec.SELECT_CLAUSE,
	     p_FROM_CLAUSE	=> l_prof_var_rec.FROM_CLAUSE,
	     p_WHERE_CLAUSE	=> l_prof_var_rec.WHERE_CLAUSE,
	     p_OTHER_CLAUSE	=> l_prof_var_rec.OTHER_CLAUSE,
 	     X_SQL_STMNT	=> l_prof_var_rec.SQL_STMNT,
	     X_return_status	=> x_return_status );

	   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
	ELSE
           l_prof_var_rec.sql_stmnt := l_old_prof_var_rec.sql_stmnt;
	END IF;
	-- ----------------------------------------------------------------------
	-- Apply business-rule validation to all required and passed parameters
	-- if validation level is set.
	-- ----------------------------------------------------------------------

	IF (p_validation_level > CSC_CORE_UTILS_PVT.G_VALID_LEVEL_NONE) THEN

	--
	-- Validate the user and login id
	--
	-- Check for all the required attributes that are being passed should be there
	-- and should not be passed as null. If passed as null then we will raise error
	-- Also Check  if Seeded_Flag = 'Y'  and  then allow / disallow updates
	-- of certain fields

	  Validate_Profile_Variables (
	      p_api_name	      => l_api_name_full,
	      p_validation_mode => CSC_CORE_UTILS_PVT.G_UPDATE,
 	      p_validate_rec    => l_prof_var_rec,
              x_return_status   => x_return_status,
              x_msg_count  =>x_msg_count,
              x_msg_data   =>x_msg_data );

        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;

     -- Replace :party_id, cust_acct_id,cust_acct_org_id with
	-- :global.csc_party_id, :global.csc_cust_acct_id,
	-- :global.csc_cust_acct_org_id
	-- respectively in sql_Stmnt_for_drilldown which will be used in
	-- drill down form.

     l_prof_var_rec.sql_stmnt_for_drilldown := replace(l_prof_var_rec.sql_stmnt_for_drilldown,
									 ':party_id',':global.csc_party_id');
     l_prof_var_rec.sql_stmnt_for_drilldown := replace(l_prof_var_rec.sql_stmnt_for_drilldown,
									 ':cust_account_id',':global.csc_cust_account_id');
     l_prof_var_rec.sql_stmnt_for_drilldown := replace(l_prof_var_rec.sql_Stmnt_for_drilldown,
									 ':org_id',':global.csc_org_id');
   -- Begin fix by spamujul for NCR ER#8473903
     l_prof_var_rec.sql_stmnt_for_drilldown := replace(l_prof_var_rec.sql_Stmnt_for_drilldown,
										 ':party_site_id',':global.csc_party_site_id');
   -- End fix by spamujul for NCR ER#8473903

	-- Build an update record, check if any of the parameters
	-- have been not been passed, if not assign a NULL.
	-- The mandatory columns have already been validated in
	-- Validate_Profile_Variables if the validation level is
	-- set to FULL.

	CSC_PROF_BLOCKS_PKG.Update_Row(
         p_BLOCK_ID  =>  l_prof_var_rec.block_id,
         p_LAST_UPDATED_BY    => FND_GLOBAL.USER_ID,
         p_LAST_UPDATE_DATE    =>sysdate,
         p_LAST_UPDATE_LOGIN    => FND_GLOBAL.CONC_LOGIN_ID,
         p_BLOCK_NAME    => csc_core_utils_pvt.get_g_miss_char(l_prof_var_rec.block_name,l_old_prof_var_rec.block_name) ,
         p_DESCRIPTION   =>  csc_core_utils_pvt.get_g_miss_char(l_prof_var_rec.description,l_old_prof_var_rec.description),
         p_START_DATE_ACTIVE  => csc_core_utils_pvt.get_g_miss_date(l_prof_var_rec.start_date_active,l_old_prof_var_rec.start_date_active),
         p_END_DATE_ACTIVE    => csc_core_utils_pvt.get_g_miss_date(l_prof_var_rec.end_date_active,l_old_prof_var_rec.end_date_active),
         p_SEEDED_FLAG    => csc_core_utils_pvt.get_g_miss_char(l_prof_var_rec.seeded_flag,l_old_prof_var_rec.seeded_flag),
         p_BLOCK_NAME_CODE    => csc_core_utils_pvt.get_g_miss_char(l_prof_var_rec.block_name_code,l_old_prof_var_rec.block_name_code),
	     p_OBJECT_CODE   => csc_core_utils_pvt.get_g_miss_char(l_prof_var_rec.object_code,l_old_prof_var_rec.object_code),
         p_SQL_STMNT_FOR_DRILLDOWN => csc_core_utils_pvt.get_g_miss_char(l_prof_var_rec.sql_stmnt_for_drilldown,l_old_prof_var_rec.sql_stmnt_for_drilldown),
         p_SQL_STMNT   => csc_core_utils_pvt.get_g_miss_char(l_prof_var_rec.sql_stmnt,l_old_prof_var_rec.sql_stmnt),
	 p_BATCH_SQL_STMNT => csc_core_utils_pvt.get_g_miss_char(l_prof_var_rec.batch_sql_stmnt,l_old_prof_var_rec.batch_sql_stmnt),
         p_SELECT_CLAUSE   => l_prof_var_rec.select_clause,
         p_CURRENCY_CODE   => csc_core_utils_pvt.get_g_miss_char(l_prof_var_rec.currency_code,l_old_prof_var_rec.currency_code),
         p_FROM_CLAUSE     => l_prof_var_rec.from_clause,
         p_WHERE_CLAUSE    => l_prof_var_rec.where_clause,
         p_OTHER_CLAUSE    => l_prof_var_rec.other_clause,
         p_BLOCK_LEVEL     => csc_core_utils_pvt.get_g_miss_char(l_prof_var_rec.block_level,l_old_prof_var_rec.block_level),
         px_OBJECT_VERSION_NUMBER => px_Object_Version_Number,
         p_APPLICATION_ID  => csc_core_utils_pvt.get_g_miss_char(l_prof_var_rec.APPLICATION_ID,l_old_prof_var_rec.application_id));


	-- Standard check of p_commit
	IF FND_API.To_Boolean(p_commit) THEN
	   COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get(
	     p_count => x_msg_count,
      	p_data  => x_msg_data );
   EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
   	    ROLLBACK TO Update_Profile_Variable_Pvt;
    	    x_return_status := FND_API.G_RET_STS_ERROR;
     	    --FND_MSG_PUB.Count_And_Get
          --    ( p_count => x_msg_count,
          --      p_data  => x_msg_data  );
         APP_EXCEPTION.RAISE_EXCEPTION;
  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    	    ROLLBACK TO Update_Profile_Variable_Pvt;
    	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    	    --FND_MSG_PUB.Count_And_Get
          --    ( p_count => x_msg_count,
          --      p_data  => x_msg_data  );
         APP_EXCEPTION.RAISE_EXCEPTION;
  	WHEN OTHERS THEN
         ROLLBACK TO Update_Profile_Variable_Pvt;
    	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    	    -- FND_MSG_PUB.Count_And_Get
          --    ( p_count => x_msg_count,
          --      p_data  => x_msg_data );
    	    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           	    FND_MSG_PUB.Build_Exc_Msg(G_PKG_NAME, l_api_name);
    	    END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;
END Update_Profile_Variable;

PROCEDURE Update_table_column(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    p_Table_Column_REC		 IN   Table_Column_Rec_Type := G_MISS_TABLE_COLUMN_REC,
    px_Object_Version_Number	 IN OUT NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )

 IS

l_api_name                CONSTANT VARCHAR2(30) := 'Update_table_column';
l_api_version_number      CONSTANT NUMBER   := 1.0;

-- Local Variables
l_old_table_column_rec CSC_PROF_TABLE_COLUMNS_VL%ROWTYPE;

l_table_column_Rec   Table_Column_Rec_Type := p_Table_Column_REC;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Table_Column_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

	--Get the old record as well lock the record.
	GET_TABLE_COLUMN(
	   p_Api_Name => l_api_name,
	   p_Table_Column_Id => l_table_column_rec.table_column_id,
	   p_object_version_number => px_object_version_number,
	   X_Table_Column_Rec => l_old_table_column_rec,
 	   x_return_status => x_return_status);
	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   RAISE FND_API.G_EXC_ERROR;
	END IF;

      IF ( P_validation_level >= CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL)
      THEN
          -- Invoke validation procedures
          Validate_table_column(
              p_api_name	=> l_api_name,
	         p_init_msg_list    => p_init_msg_list,
              p_validation_mode  => CSC_CORE_UTILS_PVT.G_UPDATE,
              P_Validate_Rec     =>  l_Table_Column_Rec,
              x_return_status    => x_return_status);
          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

      END IF;

      CSC_PROF_TABLE_COLUMNS_PKG.Update_Row(
          p_TABLE_COLUMN_ID  => l_Table_Column_rec.TABLE_COLUMN_ID,
          p_BLOCK_ID  => l_Table_Column_rec.BLOCK_ID,
          p_TABLE_NAME  => l_Table_Column_rec.TABLE_NAME,
          p_COLUMN_NAME  => l_Table_Column_rec.COLUMN_NAME,
          p_LABEL  => l_Table_Column_rec.LABEL,
	       p_TABLE_ALIAS => l_Table_Column_rec.TABLE_ALIAS,
          p_COLUMN_SEQUENCE => l_Table_Column_rec.COLUMN_SEQUENCE,
	       p_DRILLDOWN_COLUMN_FLAG => l_Table_Column_rec.DRILLDOWN_COLUMN_FLAG,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_SEEDED_FLAG     =>  l_Table_Column_rec.seeded_flag,
          px_OBJECT_VERSION_NUMBER =>px_object_version_number  );

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

  EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO UPDATE_Table_Column_PVT;
         x_return_status :=  FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get(
			p_count =>x_msg_count,
                  p_data => x_msg_data
			);
         APP_EXCEPTION.RAISE_EXCEPTION;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO UPDATE_Table_Column_PVT  ;
         x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;
         APP_EXCEPTION.RAISE_EXCEPTION;
      WHEN OTHERS THEN
         ROLLBACK TO UPDATE_Table_Column_PVT  ;
         x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
         IF FND_MSG_PUB.Check_Msg_Level
                          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
           FND_MSG_PUB.Build_Exc_Msg(G_PKG_NAME,l_api_name);
         END IF ;
         --FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
         --                            p_data => x_msg_data) ;
         APP_EXCEPTION.RAISE_EXCEPTION;
End Update_table_column;

PROCEDURE Delete_profile_variables(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_BLOCK_ID			        IN   NUMBER,
    p_OBJECT_VERSION_NUMBER     IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_profile_variables';
l_api_version_number      CONSTANT NUMBER   := 1.0;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Profile_Variables_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      -- Invoke table handler(CSC_PROF_BLOCKS_B_PKG.Delete_Row)
      CSC_PROF_BLOCKS_PKG.Delete_Row(
          p_BLOCK_ID  => P_BLOCK_ID,
	  p_OBJECT_VERSION_NUMBER => p_OBJECT_VERSION_NUMBER);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
         	ROLLBACK TO DELETE_Table_Column_PVT;
         	x_return_status :=  FND_API.G_RET_STS_ERROR ;
         	FND_MSG_PUB.Count_And_Get(
			p_count =>x_msg_count,
                  p_data => x_msg_data
			);
         	APP_EXCEPTION.RAISE_EXCEPTION;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         	ROLLBACK TO DELETE_Table_Column_PVT  ;
         	x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
         	FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;
         	APP_EXCEPTION.RAISE_EXCEPTION;
      WHEN OTHERS THEN
         	ROLLBACK TO DELETE_Table_Column_PVT  ;
         	x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
         	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         	THEN
         	    FND_MSG_PUB.Build_Exc_Msg(G_PKG_NAME,l_api_name);
         	END IF ;
         	--FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
            --                         p_data => x_msg_data) ;
         	APP_EXCEPTION.RAISE_EXCEPTION;
End Delete_profile_variables;

PROCEDURE Delete_Table_Columns(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_BLOCK_ID			    IN   NUMBER,
    px_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_table_columns';
l_api_version_number      CONSTANT NUMBER   := 1.0;
Cursor C1 IS
 Select table_column_id, Object_version_number
 From CSC_PROF_TABLE_COLUMNS_VL
 Where block_id = p_Block_id;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Table_Columns_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
	 FOR C1_rec in C1 LOOP
          -- Invoke table handler(CSC_PROF_BLOCKS_B_PKG.Delete_Row)
          CSC_PROF_TABLE_COLUMNS_PKG.Delete_Row(
              p_TABLE_COLUMN_ID  => C1_rec.TABLE_COLUMN_ID,
		    p_OBJECT_VERSION_NUMBER => C1_rec.OBJECT_VERSION_NUMBER);
      END LOOP;

  	 Update_Profile_Variable(
          p_api_version_number  => 1.0,
          p_validation_level    => CSC_CORE_UTILS_PVT.G_VALID_LEVEL_NONE,
	       p_block_id            => p_block_id,
	       p_sql_stmnt_for_drilldown => NULL,
          px_object_version_number => PX_OBJECT_VERSION_NUMBER,
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data);


      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
         	ROLLBACK TO DELETE_Table_Columns_PVT;
         	x_return_status :=  FND_API.G_RET_STS_ERROR ;
         	FND_MSG_PUB.Count_And_Get(
			p_count =>x_msg_count,
                  p_data => x_msg_data
			);
         	APP_EXCEPTION.RAISE_EXCEPTION;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         	ROLLBACK TO DELETE_Table_Columns_PVT  ;
         	x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
         	FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;
         	APP_EXCEPTION.RAISE_EXCEPTION;
      WHEN OTHERS THEN
         	ROLLBACK TO DELETE_Table_Columns_PVT  ;
         	x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
         	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         	THEN
         	    FND_MSG_PUB.Build_Exc_Msg(G_PKG_NAME,l_api_name);
         	END IF ;
         	--FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
            --                         p_data => x_msg_data) ;
         	APP_EXCEPTION.RAISE_EXCEPTION;
End Delete_Table_Columns;

----------------------------------------------------------------------
-- Validates_Profile_Variables
-----------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Procedure Validate_Block_Name
-- Description: Validates the block_name using the table
--  cs_prof_blocks. Block_name should not be duplicated in the table.
-- Input Parameters
-- p_api_name, standard parameter for writting messages
-- p_validation_mode, whether an update or an insert uses CSC_CORE_UTILS_PVT.G_UPDATE
--  or CSC_CORE_UTILS_PVT.G_CREATE global variable
-- p_block_name, block_name to be validated
-- Out Parameters
-- x_return_status, standard parameter for the return status
--------------------------------------------------------------------------

PROCEDURE Validate_Block_Name
		( p_api_name	    IN  VARCHAR2,
		  p_validation_mode   IN  VARCHAR2,
		  p_block_name        IN  VARCHAR2,
		  p_block_id		  IN	 NUMBER,
		  x_return_status     OUT NOCOPY VARCHAR2
		) IS

		 Cursor get_block_name is
		  Select block_id
		  from csc_prof_blocks_vl
		  where block_name = p_block_name;
l_dummy number;
BEGIN
 -- initialize the return status
		x_return_status := FND_API.G_RET_STS_SUCCESS;
		-- Check if the validation is called for a create or an
		 -- update
		IF p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE THEN
		   -- check if the block name is passed in and is NOT NULL
		   -- if so validate else its an mandatory argument error as its
		   -- in Create Mode.
			IF (( p_block_name <> CSC_CORE_UTILS_PVT.G_MISS_CHAR ) AND
			 ( p_block_name IS NOT NULL )) THEN
			Open get_block_name;
				Fetch get_block_name into l_dummy;
				 if get_block_name%FOUND then
				    x_return_status := FND_API.G_RET_STS_ERROR;
					CSC_CORE_UTILS_PVT.Add_Duplicate_Value_Msg
					   ( p_api_name	=> p_api_name,
					     p_argument	=> 'p_block_name' ,
					     p_argument_value => p_block_name);
				    x_return_status := FND_API.G_RET_STS_ERROR;
				 end if;
			Close get_block_name;
   ELSE
	-- If the block name is not passed or if passed in as NULL write a
      -- mandatory attribute missing message
	 x_return_status := FND_API.G_RET_STS_ERROR;
	CSC_CORE_UTILS_PVT.mandatory_arg_error(
		p_api_name => p_api_name,
		p_argument => 'p_block_name',
		p_argument_value => p_block_name);

   END IF;
 -- If the validation is called for an Update
 ELSIF p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE THEN
     -- if the block name is passed in and as NULL then
     -- its a mandatory argument error.
     if ( p_block_name IS NULL ) then
	x_return_status := FND_API.G_RET_STS_ERROR;
	CSC_CORE_UTILS_PVT.mandatory_arg_error(
		p_api_name => p_api_name,
		p_argument => 'p_block_name',
		p_argument_value => p_block_name);

     elsif ( p_block_name <> CSC_CORE_UTILS_PVT.G_MISS_CHAR ) then
	 -- Valdiate the block name
       Open get_block_name;
       Loop
         Fetch get_block_name into l_dummy;
             -- if the block name passed in is the same as
		 -- the present one then ignore else raise an
		 -- duplicate value error as block name should
		 -- be unique
	 	 if l_dummy <> p_block_id then
		   x_return_status := FND_API.G_RET_STS_ERROR;
		   CSC_CORE_UTILS_PVT.Add_Duplicate_Value_Msg
		     ( p_api_name	=> p_api_name,
		       p_argument	=> 'p_block_name' ,
  		       p_argument_value => p_block_name);
               x_return_status := FND_API.G_RET_STS_ERROR;
		   exit;
           else
		   exit;
		 end if;
       End Loop;
       Close get_block_name;
     end if;
 END IF;
END Validate_Block_Name;

--------------------------------------------------------------------------
-- Procedure Validate_Seeded_Flag
-- Description: Validates the seeded_flag from the fnd_lookups table
-- using CSC_CORE_UTILS_PVT.lookup_code_not_exists function.
-- Input Parameters
-- p_api_name, standard parameter for writting messages
-- p_validation_mode, whether an update or an insert uses CSC_CORE_UTILS_PVT.G_UPDATE
--  or CSC_CORE_UTILS_PVT.G_CREATE global variable
-- p_seeded_flag, seeded_flag to be validated should be an YES or a NO
-- Out Parameters
-- x_return_status, standard parameter for the return status
--------------------------------------------------------------------------

PROCEDURE Validate_Seeded_Flag
( p_api_name	     IN  VARCHAR2,
  p_parameter_name  IN  VARCHAR2,
  p_seeded_flag     IN  VARCHAR2,
  x_return_status   OUT NOCOPY VARCHAR2
) IS
  --
 BEGIN
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- check if the seeded flag is passed in and is not
  -- null, if passed in check if the lookup code
  -- exists in fnd lookups for this date, if not
  -- its an invalid argument.
  IF (( p_seeded_flag <> CSC_CORE_UTILS_PVT.G_MISS_CHAR ) AND
	( p_seeded_flag IS NOT NULL )) THEN
    IF CSC_CORE_UTILS_PVT.lookup_code_not_exists(
 	p_effective_date  => trunc(sysdate),
  	p_lookup_type     => 'YES_NO',
  	p_lookup_code     => p_seeded_flag ) <> FND_API.G_RET_STS_SUCCESS
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(p_api_name => p_api_name,
			            p_argument_value  => p_seeded_flag,
			            p_argument  => p_parameter_name);
    END IF;
  END IF;
END Validate_Seeded_Flag;

PROCEDURE Validate_block_level
( p_api_name        IN  VARCHAR2,
  p_parameter_name  IN  VARCHAR2,
  p_block_level     IN  VARCHAR2,
  x_return_status   OUT NOCOPY VARCHAR2
) IS
  --
 BEGIN
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- check if the block_level is passed in and is not
  -- null

  IF (( p_block_level <> CSC_CORE_UTILS_PVT.G_MISS_CHAR ) AND
        ( p_block_level IS NOT NULL )) THEN
-- Commented the following code by spamujul for NCR ER# 8473903
--  IF (p_block_level <> 'PARTY' AND p_block_level <> 'ACCOUNT'  AND p_block_level <> 'CONTACT' AND p_block_level <> 'EMPLOYEE')
 IF (p_block_level <> 'PARTY' AND p_block_level <> 'ACCOUNT'  AND p_block_level <> 'CONTACT' AND p_block_level <> 'EMPLOYEE' AND p_block_level <> 'SITE')
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(p_api_name => p_api_name,
                                          p_argument_value  => p_block_level,
                                             p_argument  => p_parameter_name);
    END IF;
  END IF;
END Validate_Block_Level;


--------------------------------------------------------------------------
-- Procedure Validate_Currecny_Code
-- Description: Validates the currency_Code from the fnd_currencies table
-- using CSC_CORE_UTILS_PVT.currency_code_not_exists function.
-- Input Parameters
-- p_api_name, standard parameter for writting messages
-- p_validation_mode, whether an update or an insert uses CSC_CORE_UTILS_PVT.G_UPDATE
--  or CSC_CORE_UTILS_PVT.G_CREATE global variable
-- p_currrency_code, currency_code to be validated
-- Out Parameters
-- x_return_status, standard parameter for the return status
--------------------------------------------------------------------------

PROCEDURE Validate_Currency_Code
( p_api_name	  IN  VARCHAR2,
  p_parameter_name  IN  VARCHAR2,
  p_currency_code   IN  VARCHAR2,
  x_return_status   OUT NOCOPY VARCHAR2 )
IS
  --
 BEGIN
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- if the currency code is passed in and is not null,
  -- validate the currency code.
  IF (( p_currency_Code <> CSC_CORE_UTILS_PVT.G_MISS_CHAR ) AND
	( p_currency_code IS NOT NULL )) then

     IF CSC_CORE_UTILS_PVT.Currency_code_not_exists(
 	  p_effective_date  => sysdate,
  	  p_currency_code   => p_currency_code ) <> FND_API.G_RET_STS_SUCCESS THEN

	 -- if the currency code is not valid its an invalid argument
       x_return_status := FND_API.G_RET_STS_ERROR;
       CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(p_api_name => p_api_name,
			            p_argument_value  => p_currency_code,
			            p_argument  => p_parameter_name);

     END IF;
  END IF;

END Validate_Currency_Code;

--------------------------------------------------------------------------
-- Procedure Validate_Sql_Stmnt
-- Description: Validates the sql_statement using the dynamic sql
-- Input Parameters
-- p_api_name, standard parameter for writting messages
-- p_validation_mode, whether an update or an insert uses CSC_CORE_UTILS_PVT.G_UPDATE
--  or CSC_CORE_UTILS_PVT.G_CREATE global variable
-- p_sql_statement, concatented field using select_Clause, from_clause
--    where_clause and Other_Clause columns using the Build_Sql_Stmnt
--    procedure
-- Out Parameters
-- x_return_status, standard parameter for the return status
--------------------------------------------------------------------------
PROCEDURE Validate_Sql_Stmnt(
   p_api_name	 	IN	VARCHAR2,
   p_parameter_Name 	IN 	VARCHAR2,
   p_sql_stmnt	IN	VARCHAR2,
   x_return_status	OUT	NOCOPY VARCHAR2 )
IS
l_sql_cur_hdl  INT;
BEGIN

   -- initialize the return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- if the sql_statement is passed in and if its NOT NULL then
  -- validate the sql_statement by parsing it using the dbms_sql
  -- package.

  CSC_CORE_UTILS_PVT.Validate_Sql_Stmnt(
		p_sql_stmnt	=> p_sql_Stmnt,
  		x_return_status => X_return_status);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
		  p_api_name 	=> p_api_name,
		  p_argument_value  => p_sql_stmnt,
		  p_argument    => p_parameter_name);

  END IF;

END Validate_Sql_Stmnt;

PROCEDURE Validate_Object_ID(
   p_api_name	 	IN	VARCHAR2,
   p_parameter_Name 	IN 	VARCHAR2,
   p_OBJECT_CODE		IN	VARCHAR2,
   x_return_status	OUT	NOCOPY VARCHAR2 )
IS

l_dummy 	VARCHAR2(30);

Cursor get_object_csr is
 Select NULL
 from jtf_objects_vl
 where object_code = p_object_code;
BEGIN

   -- initialize the return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ((p_Object_Code IS NOT NULL) AND
      (p_Object_Code <> CSC_CORE_UTILS_PVT.G_MISS_CHAR )) THEN
   Open get_object_csr;
   Fetch get_object_csr into l_dummy;
   IF get_object_csr%NOTFOUND THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
		  p_api_name 	=> p_api_name,
		  p_argument_value  => p_object_code,
		  p_argument    => p_parameter_name);
   END IF;
   Close get_object_csr;
  END IF;
END;

-------------------------------------------------------------------------
--Validate_Block_Name_Code
-------------------------------------------------------------------------

PROCEDURE Validate_block_name_code
	(p_api_name	  	  IN	VARCHAR2,
	 p_parameter_Name   IN	VARCHAR2,
	 p_block_name_code IN	VARCHAR2,
	 p_block_id		IN	NUMBER,
	 p_validation_mode  IN  VARCHAR2,
	 x_return_status    OUT	NOCOPY VARCHAR2 )
IS
l_dummy	VARCHAR2(1);

cursor get_block_code is
 Select null
 from csc_prof_blocks_b
 where block_name_code = p_block_name_code;

BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- Check if the validation is called for a Create or
 -- an update
 IF p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE THEN
   -- if the block_name_code is passed in and is not null
   -- validate the block_name_code
   if (( p_block_name_code IS NOT NULL ) and
      ( p_block_name_code <> CSC_CORE_UTILS_PVT.G_MISS_CHAR )) then
     open get_block_code;
     fetch get_block_code into l_dummy;
     if get_block_code%FOUND then
	 -- if not valid an invalid argument message
	 x_return_status := FND_API.G_RET_STS_ERROR;
       CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
		  p_api_name  => p_api_name,
		  p_argument_value  => p_block_name_code,
		  p_argument  => p_parameter_name );
     end if;
     close get_block_code;
    else
       --  if block_name_code is not passed in or if passed
       --  in as null raise a mandatory argument error.
	  x_return_status := FND_API.G_RET_STS_ERROR;
	 CSC_CORE_UTILS_PVT.mandatory_arg_error(
		p_api_name => p_api_name,
		p_argument => 'p_block_name_code',
		p_argument_value => p_block_name_code);
    end if;
 -- if its an update mode
 ELSIF p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE THEN
   -- if the block_name_code is passed in as NULL
   -- its an error else validate.
   if p_block_name_code IS NULL THEN
	 -- write a  mandatory attributes missing message
	 x_return_status := FND_API.G_RET_STS_ERROR;
	 CSC_CORE_UTILS_PVT.mandatory_arg_error(
		p_api_name => p_api_name,
		p_argument => 'p_block_name_code',
		p_argument_value => p_block_name_code);
   elsif  p_block_name_code <> CSC_CORE_UTILS_PVT.G_MISS_CHAR then
     open get_block_code;
     loop
     fetch get_block_code into l_dummy;
        -- if the block_name_code passed in is the same as
	   -- the present one then ignore else raise an duplicate
	   -- value error as block_name_code should be unique
        if l_dummy <> p_block_id then
           x_return_status := FND_API.G_RET_STS_ERROR;
	      CSC_CORE_UTILS_PVT.Add_Duplicate_Value_Msg
		     ( p_api_name	=> p_api_name,
		       p_argument	=> 'p_block_name_code' ,
  		       p_argument_value => p_block_name_code);
           exit;
        else
		 exit;
        end if;
     end loop;
     close get_block_code;
   end if;
 END IF;
END Validate_Block_Name_Code;

PROCEDURE Validate_Profile_Variables(
	   p_api_name			IN	VARCHAR2,
	   p_validation_mode	IN	VARCHAR2,
	   p_validate_rec		IN	ProfVar_Rec_Type,
	   x_return_status		OUT	NOCOPY VARCHAR2,
	   x_msg_count		OUT NOCOPY NUMBER,
	   x_msg_data			OUT NOCOPY VARCHAR2 )
IS
BEGIN
	-- Initialize return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	-- Validate Block_Name
	Validate_Block_Name(
			   p_api_name        => p_api_name,
			   p_validation_mode => p_validation_mode,
			   p_block_name      => p_validate_rec.block_name,
			   p_block_id	   => p_Validate_rec.block_id,
			   x_return_status   => x_return_status
		);
       IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
	 RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- validate start and end date
	CSC_CORE_UTILS_PVT.Validate_Start_End_Dt(
	   p_api_name 		=> p_Api_name,
         p_start_date		=> p_validate_rec.start_date_active,
         p_end_date		=> p_validate_rec.end_date_active,
         x_return_status	=> x_return_status );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
	RAISE FND_API.G_EXC_ERROR;
  	END IF;

	--Validate seeded flag
  	Validate_Seeded_Flag(
   	   p_api_name	    => p_api_name,
         p_parameter_name  => 'p_Seeded_Flag',
         p_seeded_flag     => p_validate_rec.seeded_flag,
         x_return_status   => x_return_status );
       IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
	 RAISE FND_API.G_EXC_ERROR;
  	END IF;

         --Validate Block_level
        Validate_Block_Level(
           p_api_name         => p_api_name,
           p_parameter_name   => 'p_Block_Level',
           p_block_level      => p_validate_rec.block_level,
           x_return_status    => x_return_status );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
	 RAISE FND_API.G_EXC_ERROR;
        END IF;

     -- Validate Sql Statement
	Validate_Sql_stmnt(
	  p_api_name	   => p_api_name,
        p_parameter_name => 'p_sql_stmnt',
        p_sql_Stmnt  => p_validate_rec.sql_stmnt,
        x_return_status  => x_return_status );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	  RAISE FND_API.G_EXC_ERROR;
  	END IF;
        -- Validate Batch Sql Statement
	Validate_Sql_stmnt(
        p_api_name       => p_api_name,
        p_parameter_name => 'p_batch_sql_stmnt',
        p_sql_Stmnt      => p_validate_rec.batch_sql_stmnt,
        x_return_status  => x_return_status );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	  RAISE FND_API.G_EXC_ERROR;
  	END IF;
       -- Validate Currency code
	Validate_Currency_Code(
	  p_Api_name 	   => p_api_name,
        p_parameter_name => 'p_currency_code',
        p_currency_code  => p_validate_rec.currency_code,
    	  x_return_status  => x_return_status );

	IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	  RAISE FND_API.G_EXC_ERROR;
  	END IF;

	-- validate block name code
	Validate_block_name_Code(
	  p_api_name	    => p_api_name,
	  p_parameter_Name   => 'p_block_name_code',
	  p_block_name_code => p_validate_rec.block_name_code,
	  p_block_id	    => p_validate_rec.block_id,
	  p_validation_mode  => p_Validation_mode,
	  x_return_status    => x_return_status );
	IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	  RAISE FND_API.G_EXC_ERROR;
	END IF;

  	-- Validate object code
  	Validate_Object_Id(
		p_api_name	 => p_api_name,
	 	p_parameter_Name => 'P_OBJECT_CODE',
	 	p_object_code 	 => p_validate_rec.object_code,
	 	x_return_status  => x_return_status );

  	IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
		RAISE FND_API.G_EXC_ERROR;
  	END IF;

       /* This Call added for Enhancement 1781726 for Validating Application_id*/
        CSC_CORE_UTILS_PVT.Validate_APPLICATION_ID (
           P_Init_Msg_List              => CSC_CORE_UTILS_PVT.G_FALSE,
           P_Application_ID             =>p_validate_rec.application_id,
           X_Return_Status              => x_return_status,
           X_Msg_Count                  => x_msg_count,
           X_Msg_Data                   => x_msg_data,
           p_effective_date             => SYSDATE );

  	IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
		RAISE FND_API.G_EXC_ERROR;
  	END IF;

 END Validate_Profile_Variables;


-- -------------------------------------------------------------------
-- Get Profile Variable Rec
-- -------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

PROCEDURE GET_PROF_BLOCKS(
    p_Api_Name      IN VARCHAR2,
    p_BLOCK_ID      IN NUMBER,
    p_object_version_number NUMBER,
    X_PROF_BLOCKS_REC  OUT NOCOPY CSC_PROF_BLOCKS_VL%ROWTYPE,
    X_return_status OUT NOCOPY VARCHAR2 )
IS
--
Cursor c_Get_prof_rec is
  Select *
  From CSC_PROF_BLOCKS_VL
  Where block_id = p_block_id
  and object_version_number = p_object_version_number
  For update nowait;

Begin

	-- Initialize the  p_return_status  to TRUE
	x_return_status :=  FND_API.G_RET_STS_SUCCESS ;


     OPEN C_get_prof_rec;
	FETCH C_get_prof_rec INTO X_PROF_BLOCKS_REC;
      IF C_get_prof_rec%NOTFOUND THEN
	   CLOSE C_Get_prof_Rec;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
           CSC_CORE_UTILS_PVT.Record_IS_LOCKED_MSG(p_API_NAME=> 'CSC_PROF_BLOCKS');
		 x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
	   raise FND_API.G_EXC_ERROR;
	  END IF;
     IF C_GET_prof_Rec%ISOPEN THEN
	   CLOSE C_Get_Prof_Rec;
     END IF;

END GET_PROF_BLOCKS ;

-- -------------------------------------------------------------------
-- Get_Table_Column_Rec
-- -------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

Procedure GET_TABLE_COLUMN(
   p_Api_Name in VARCHAR2,
   p_Table_Column_Id IN NUMBER,
   p_object_version_number IN NUMBER,
   X_Table_Column_Rec OUT NOCOPY CSC_PROF_TABLE_COLUMNS_VL%ROWTYPE,
   X_Return_status OUT NOCOPY VARCHAR2 )
IS
Cursor C_Get_table_column_rec IS
    Select *
/*  TABLE_COLUMN_ID,
           BLOCK_ID,
           TABLE_NAME,
           COLUMN_NAME,
           LABEL,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN
*/
    From  CSC_PROF_TABLE_COLUMNS_VL
    Where Table_Column_ID = p_Table_Column_ID
    And object_version_number = p_object_version_number
    For Update NOWAIT;
BEGIN
     -- initialze the return status
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     OPEN C_get_table_column_rec;
	FETCH C_get_table_column_rec INTO X_TABLE_COLUMN_REC;
      IF C_get_table_column_rec%NOTFOUND THEN
	   CLOSE C_Get_Table_Column_rec;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
              CSC_CORE_UTILS_PVT.RECORD_IS_LOCKED_MSG(p_API_NAME=>'CSC_PROF_TABLE_COLUMNS');
		    x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
	   raise FND_API.G_EXC_ERROR;
	 END IF;
     IF C_Get_table_Column_rec%ISOPEN THEN
        CLOSE C_get_table_Column_rec;
     END IF;


END GET_TABLE_COLUMN;

--------------------------------------------------------------------------
-- Procedure Validate_Block_Id
-- Description: Validates the block_id using the table
--  cs_prof_blocks.
-- Input Parameters
-- p_api_name, standard parameter for writting messages
-- p_validation_mode, whether an update or an insert uses CSC_CORE_UTILS_PVT.G_UPDATE
--  or CSC_CORE_UTILS_PVT.G_CREATE global variable
-- p_block_id, block_id to be validated while updating
-- Out Parameters
-- x_return_status, standard parameter for the return status
--------------------------------------------------------------------------

PROCEDURE Validate_Block_Id (
  p_api_name	   IN  VARCHAR2,
  p_validation_mode  IN  VARCHAR2,
  p_block_id     	   IN  NUMBER,
  x_return_status    OUT NOCOPY VARCHAR2
  )
IS
   Function chk_block_id (p_block_id IN NUMBER)  RETURN VARCHAR2
   IS
	 Cursor get_block_id is
	  Select NULL
	  From csc_prof_blocks_b
	  Where block_id = p_block_id;
	  l_dummy varchar2(10);
	  l_return_status VARCHAR2(30);
   BEGIN

	-- Initlaize the return status to SUCCESS
	l_return_status := FND_API.G_RET_STS_SUCCESS;

	Open get_block_id;
	Fetch get_block_id into l_dummy;
 	IF get_block_id%NOTFOUND THEN
         l_return_status := FND_API.G_RET_STS_ERROR;
         CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
  			p_api_name        => p_api_name,
      		p_argument_value  => to_char(p_block_id),
      		p_argument        => 'p_block_id' );
  	END IF;
   	Close get_block_id;
   	return (l_return_status);
    END chk_block_id;

BEGIN



	-- Initlaize the return status to SUCCESS
  	x_return_status := FND_API.G_RET_STS_SUCCESS;


  	--
	IF p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE THEN

  	  IF ( p_block_id <> CSC_CORE_UTILS_PVT.G_MISS_NUM )  AND
	      ( p_block_id IS NOT NULL )
	  THEN
	     x_return_status := chk_block_id( p_block_id );
	  ELSE
           x_return_status := FND_API.G_RET_STS_ERROR;
	     CSC_CORE_UTILS_PVT.mandatory_arg_error(
			p_api_name => p_api_name,
			p_argument => 'p_block_id',
			p_argument_value => p_block_id);
	  END IF;

	ELSIF p_Validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE THEN

	  IF ( p_block_id <> CSC_CORE_UTILS_PVT.G_MISS_NUM )
	  THEN
	    IF (p_block_id IS NOT NULL ) THEN
	       x_return_status := chk_block_id( p_block_id );
	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	       CSC_CORE_UTILS_PVT.mandatory_arg_error(
			p_api_name => p_api_name,
			p_argument => 'p_block_id',
			p_argument_value => p_block_id);

	    END IF;
	  END IF;
	END IF;

END Validate_Block_Id;

PROCEDURE Validate_TABLE_NAME (
    p_api_name	   		IN  VARCHAR2,
    P_Validation_mode         IN   VARCHAR2,
    P_TABLE_NAME              IN   VARCHAR2,
    X_Return_Status           OUT NOCOPY VARCHAR2
    )
IS

 l_dummy VARCHAR2(10);

 Cursor get_tname_csr is
  Select NULL
  from fnd_tables
  where table_name = p_table_name;

 Cursor get_vname_csr is
 Select NULL
 from fnd_views
 where view_name = p_table_name;
BEGIN

	-- Initialize API return status to SUCCESS
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF p_TABLE_NAME is not NULL and p_TABLE_NAME <> CSC_CORE_UTILS_PVT.G_MISS_CHAR
     	THEN
   	  Open get_tname_csr;
        Fetch get_tname_csr into l_dummy;
 	  IF get_tname_csr%NOTFOUND THEN
	    Open get_vname_csr;
          Fetch get_vname_csr into l_dummy;
          IF get_vname_csr%NOTFOUND THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
  			   p_api_name        => p_api_name,
      		   p_argument_value  => p_table_name,
      		   p_argument        => 'p_Table_Name' );
          END IF;
          Close get_vname_csr;
  	  END IF;
        Close get_tname_csr;
	END IF;

END Validate_TABLE_NAME;


PROCEDURE Validate_COLUMN_NAME (
    p_api_name	   		IN  VARCHAR2,
    P_Validation_mode         IN   VARCHAR2,
    P_COLUMN_NAME              IN   VARCHAR2,
    X_Return_Status           OUT NOCOPY VARCHAR2
    )
IS
  Cursor get_cname_csr is
   Select NULL
   from fnd_columns
   where column_name = p_column_name;

  Cursor get_vcname_csr is
   Select NULL
   from fnd_view_columns
   where column_name = p_column_name;
l_dummy VARCHAR2(10);
BEGIN

	-- Initialize API return status to SUCCESS
	x_return_status := FND_API.G_RET_STS_SUCCESS;


	IF p_COLUMN_NAME is not NULL and p_COLUMN_NAME <> CSC_CORE_UTILS_PVT.G_MISS_CHAR
	THEN
        Open get_cname_csr;
        Fetch get_cname_csr into l_dummy;
 	  IF get_cname_csr%NOTFOUND THEN
          Open get_vcname_csr;
          Fetch get_vcname_csr into l_dummy;
          IF get_vcname_csr%NOTFOUND THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
		    p_api_name        => p_api_name,
       	    p_argument_value  => p_column_name,
       	    p_argument        => 'p_Column_Name' );
          END IF;
          Close get_vcname_csr;
  	  END IF;
        Close get_cname_csr;
	END IF;

END Validate_COLUMN_NAME;

PROCEDURE Validate_Table_Column(
    P_Api_Name			IN   VARCHAR2,
    P_Init_Msg_List           IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode         IN   VARCHAR2,
    p_validate_rec		IN   Table_Column_Rec_Type,
    X_Return_Status           OUT NOCOPY VARCHAR2
    )
IS
 BEGIN

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	Validate_COLUMN_NAME (
    		p_api_name	=> p_api_name,
    		P_Validation_mode    => p_validation_mode,
    		P_COLUMN_NAME        => p_Validate_rec.column_name,
    		X_Return_Status      => x_return_status
    		);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         raise FND_API.G_EXC_ERROR;
      END IF;

	Validate_TABLE_NAME (
    		p_api_name	    => p_api_name,
    		P_Validation_mode       => p_validation_mode,
    		P_TABLE_NAME            => p_Validate_rec.table_name,
    		X_Return_Status         => x_return_status
    		);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         raise FND_API.G_EXC_ERROR;
      END IF;

	Validate_Block_Id (
  		p_api_name	   	 => p_api_name,
  		p_validation_mode  => p_validation_mode,
  		p_block_id     	 => p_Validate_rec.block_id,
  		x_return_status    => x_return_status
  		);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
      END IF;


        IF p_validate_rec.COLUMN_SEQUENCE is NULL THEN
	       CSC_CORE_UTILS_PVT.mandatory_arg_error(
			p_api_name => p_api_name,
			p_argument => 'p_Column_Sequence',
			p_argument_value => p_validate_rec.Column_Sequence);
        END IF;


END Validate_table_column;

--
END CSC_Profile_Variable_Pvt;

/
