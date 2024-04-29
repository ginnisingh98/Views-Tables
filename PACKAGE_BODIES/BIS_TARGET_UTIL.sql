--------------------------------------------------------
--  DDL for Package Body BIS_TARGET_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_TARGET_UTIL" AS
/* $Header: BISUTRGB.pls 115.24 99/07/17 16:11:36 porting shi $ */

--  Functions/ Procedures
Procedure Get_Level_name
   (p_level_id       IN Number
   ,x_level_name     OUT Varchar2
   ,x_return_status  OUT Varchar2
   ,x_msg_count      OUT Number
   ,x_msg_data       OUT Varchar2)
is
l_rtn_val Varchar2(80);
Begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  select short_name
  into x_level_name
  from BIS_levels
  where level_id = p_level_id;
EXCEPTION

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_level_name'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
end Get_Level_name;

Procedure Create_Ind_Level_View
   (p_ind_level_name IN Varchar2
   ,p_msg_init       IN Varchar2 default FND_API.G_TRUE
   ,x_return_status  OUT Varchar2
   ,x_msg_count      OUT Number
   ,x_msg_data       OUT Varchar2)
is
l_cursor       Integer;
l_sql_result   Integer := 0;

l_view_from_stmt  Varchar2(2000) := ' from BIS_target_values val, '||
       'BIS_business_plans plan,BIS_target_levels lvl ';

l_view_from_stmt2  Varchar2(2000);

l_view_from_stmt3 Varchar2(2000) := ' val.target_level_id = lvl.target_level_id ' ||
      ' and val.plan_id = plan.plan_id' ;

l_level_col_list1 Varchar2(2000) :=
      'wf_process,plan_id, plan_short_name,' ||
      'version_no,current_plan_flag' ;
l_level_col_list2 Varchar2(2000) :=
      ',target, range1_low, range1_high,' ||
      'range2_low, range2_high, range3_low, range3_high,' ||
      'role1_id,role2_id,role3_id,role1,role2,role3';
l_level_col_list3 Varchar2(2000);
l_level_select_list1 Varchar2(2000) :=
      'lvl.wf_process,PLan.plan_id, plan.short_name,' ||
      'plan.version_no,plan.current_plan_flag' ;
l_level_select_list2 Varchar2(2000) :=
      ',val.target, val.range1_low, val.range1_high,' ||
      'val.range2_low, val.range2_high, val.range3_low, val.range3_high,' ||
      'val.role1_id,'||
      'val.role2_id,'||
      'val.role3_id,'||
      'val.role1,'||
      'val.role2,'||
      'val.role3';
l_level_select_list3 Varchar2(2000);
l_trg_lvl_rec    BIS_TARGET_LEVELS%ROWTYPE;
l_level_name     Varchar2(30);
l_period_type 	 Varchar2(15);
l_year		 number(15);
l_calendar	 Varchar2(15);
l_return_status  Varchar2(30);
l_msg		 Varchar2(100);
l_file	Varchar2(20);
Begin
BIS_debug_pub.Debug_OFF;

  l_return_status := FND_API.G_RET_STS_SUCCESS;

   --  Initialize message list.
   if p_msg_init = FND_API.G_TRUE then
      FND_MSG_PUB.initialize;
   end if;

  BIS_debug_pub.add('Selecting row from BIS_target_levels for : '
         || p_ind_level_name);

  select *
  into l_trg_lvl_rec
  from BIS_target_levels
  where short_name = p_ind_level_name;

  -- Time dimension
  BIS_debug_pub.add('Select Level Name For Time');
  if l_trg_lvl_rec.time_level_id is not null then
     Get_Level_name
     (p_level_id  => l_trg_lvl_rec.time_level_id
     ,x_level_name => l_level_name
     ,x_return_status  => l_return_status
     ,x_msg_count      => x_msg_count
     ,x_msg_data       => x_msg_data);

  BIS_debug_pub.add('The return status is ' || l_return_status || ': and'
          || ' time level name is :' || l_level_name);

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
     END IF;

  if UPPER(substr(l_level_name,1,5)) <> 'TOTAL' then
     l_level_col_list1 := l_level_col_list1 || ',' || 'Calendar_' ||replace(l_level_name,' ','_');
     l_level_col_list3 := l_level_col_list3||', Period_Value, Year, Calendar';
     l_view_from_stmt3 := ' and '||l_view_from_stmt3;

  if UPPER(substr(l_level_name,1,2)) = 'HR' then
     l_level_select_list3 := ','||' substr(val.time_level_value,instr(val.time_level_value,''+'',1,1)+1) '
			  ||', '|| ' substr(val.time_level_value,-4), '
		          || 'substr(val.time_level_value,1,instr(val.time_level_value,''+'',1,1)-1)';

     l_view_from_stmt2  := 'and substr(time_level_value,1,2) '||' = ''HR''';

  else
     l_level_select_list3 := ','||'substr(val.time_level_value,instr(val.time_level_value,''+'',1,1)+1) '
			  ||', '||'to_number(' ||'gl.period_year'||')'||','
		          || 'substr(val.time_level_value,1,instr(val.time_level_value,''+'',1,1)-1)';

     l_view_from_stmt := l_view_from_stmt ||', gl_periods gl ';
     l_view_from_stmt2  := ' and gl.period_set_name = '
			||'substr(val.time_level_value,1,instr(val.time_level_value,''+'',1,1)-1)';

     l_view_from_stmt2  :=  l_view_from_stmt2||' and gl.period_name = '
	 		|| 'substr(val.time_level_value,instr(val.time_level_value,''+'',1,1)+1) ';
  end if;

-- WHY DOES TOTAL_TIME SHOW?
  else l_level_col_list1 := l_level_col_list1 || ',' ||replace(l_level_name,' ','_');
      l_view_from_stmt3 := 'and '||l_view_from_stmt3;

  end if;
     l_level_select_list1 := l_level_select_list1 || ',' || 'val.time_level_value';
     l_view_from_stmt := l_view_from_stmt || 'where lvl.short_name = '''
         || p_ind_level_name || '''';
  end if;

  -- Org Dimension
  if l_trg_lvl_rec.org_level_id is not null then
  BIS_debug_pub.add('Select Level Name For Org');
     Get_Level_name
     (p_level_id  => l_trg_lvl_rec.org_level_id
     ,x_level_name => l_level_name
     ,x_return_status  => l_return_status
     ,x_msg_count      => x_msg_count
     ,x_msg_data       => x_msg_data);
  BIS_debug_pub.add('The return status is ' || l_return_status || ': and'
          || ' org level name is:' || l_level_name);
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
     END IF;
     if substr(upper(l_level_name),1,5) <> 'TOTAL' then
        l_level_col_list1 := l_level_col_list1
                      || ',' || replace(l_level_name,' ','_');
        l_level_select_list1 := l_level_select_list1
                      || ',' || 'val.org_level_value';
     end if;
  end if;
  -- Dimesion 1
  if l_trg_lvl_rec.dimension1_level_id is not null then
  BIS_debug_pub.add('Select Level Name For Dimension 1');
     Get_Level_name
     (p_level_id  => l_trg_lvl_rec.dimension1_level_id
     ,x_level_name => l_level_name
     ,x_return_status  => l_return_status
     ,x_msg_count      => x_msg_count
     ,x_msg_data       => x_msg_data);
  BIS_debug_pub.add('The return status is ' || l_return_status || ': and'
          || ' Dimension1 level name is:' || l_level_name);
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
     END IF;
     if substr(upper(l_level_name),1,5) <> 'TOTAL' then
        l_level_col_list1 := l_level_col_list1 || ','
                   || replace(l_level_name,' ','_');
        l_level_select_list1 := l_level_select_list1 || ','
                   || 'val.dimension1_level_value';
     end if;
  end if;
  -- Dimesion 2
  if l_trg_lvl_rec.dimension2_level_id is not null then
  BIS_debug_pub.add('Select Level Name For Dimension 2');
     Get_Level_name
     (p_level_id  => l_trg_lvl_rec.dimension2_level_id
     ,x_level_name => l_level_name
     ,x_return_status  => l_return_status
     ,x_msg_count      => x_msg_count
     ,x_msg_data       => x_msg_data);
  BIS_debug_pub.add('The return status is ' || l_return_status || ': and'
          || ' Dimension2 level name is:' || l_level_name);
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
     END IF;
     if substr(upper(l_level_name),1,5) <> 'TOTAL' then
        l_level_col_list1 := l_level_col_list1 || ','
              || replace(l_level_name,' ','_');
        l_level_select_list1 := l_level_select_list1 || ','
              || 'val.dimension2_level_value';
     end if;
  end if;
  -- Dimesion 3
  if l_trg_lvl_rec.dimension3_level_id is not null then
  BIS_debug_pub.add('Select Level Name For Dimension 3');
     Get_Level_name
     (p_level_id  => l_trg_lvl_rec.dimension3_level_id
     ,x_level_name => l_level_name
     ,x_return_status  => l_return_status
     ,x_msg_count      => x_msg_count
     ,x_msg_data       => x_msg_data);
  BIS_debug_pub.add('The return status is ' || l_return_status || ': and'
          || ' Dimension3 level name is:' || l_level_name);
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
     END IF;
     if substr(upper(l_level_name),1,5) <> 'TOTAL' then
        l_level_col_list1 := l_level_col_list1 || ','
                       || replace(l_level_name,' ','_');
        l_level_select_list1 := l_level_select_list1 || ','
                       || 'val.dimension3_level_value';
     end if;
  end if;
  -- Dimesion 4
  if l_trg_lvl_rec.dimension4_level_id is not null then
  BIS_debug_pub.add('Select Level Name For Dimension 4');
     Get_Level_name
     (p_level_id  => l_trg_lvl_rec.dimension4_level_id
     ,x_level_name => l_level_name
     ,x_return_status  => l_return_status
     ,x_msg_count      => x_msg_count
     ,x_msg_data       => x_msg_data);
  BIS_debug_pub.add('The return status is ' || l_return_status || ': and'
          || ' Dimension4 level name is:' || l_level_name);
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
     END IF;
     if substr(upper(l_level_name),1,5) <> 'TOTAL' then
        l_level_col_list1 := l_level_col_list1 || ','
             || replace(l_level_name,' ','_');
        l_level_select_list1 := l_level_select_list1 || ','
             || 'val.dimension4_level_value';
     end if;
  end if;
  -- Dimesion 5
  if l_trg_lvl_rec.dimension5_level_id is not null then
  BIS_debug_pub.add('Select Level Name For Dimension 5');
     Get_Level_name
     (p_level_id  => l_trg_lvl_rec.dimension5_level_id
     ,x_level_name => l_level_name
     ,x_return_status  => l_return_status
     ,x_msg_count      => x_msg_count
     ,x_msg_data       => x_msg_data);
  BIS_debug_pub.add('The return status is ' || l_return_status || ': and'
          || ' Dimension5 level name is:' || l_level_name);
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
     END IF;
     if substr(upper(l_level_name),1,5) <> 'TOTAL' then
        l_level_col_list1 := l_level_col_list1 || ','
             || replace(l_level_name,' ','_');
        l_level_select_list1 := l_level_select_list1
             || ',' || 'val.dimension5_level_value';
     end if;
  end if;

  -- Open cursor
  l_cursor := dbms_sql.open_cursor;

  -- parse the statment
  BIS_debug_pub.add('sql  statement: ' ||  ' create or replace force view bis_'
                    || substr(replace(p_ind_level_name,' ','_'),1,24)
                    || '_v(' );
  BIS_debug_pub.add(l_level_col_list1 || l_level_col_list2);
  BIS_debug_pub.add(l_level_col_list3|| ') as select ' );
  BIS_debug_pub.add(l_level_select_list1 || l_level_select_list2|| l_level_select_list3);
  BIS_debug_pub.add(l_view_from_stmt);
  BIS_debug_pub.add(substr(l_view_from_stmt2,1,150));
  BIS_debug_pub.add(substr(l_view_from_stmt2,151));

   dbms_sql.parse(c => l_cursor
                ,statement=> ' create or replace force view bis_'
                            || substr(replace(p_ind_level_name,' ','_'),1,24)
                            || '_v(' || l_level_col_list1
                            || l_level_col_list2
			    || l_level_col_list3 || ') as select '
                            || l_level_select_list1
			    || l_level_select_list2
			    || l_level_select_list3
                            || ' ' || l_view_from_stmt ||' '||l_view_from_stmt2||' '||l_view_from_stmt3
               ,language_flag => DBMS_SQL.Native);

  -- Execute the cursor
  l_sql_result := dbms_sql.execute(l_cursor);
  -- Close the cursor
     dbms_sql.close_cursor(l_cursor);
  -- check for sql execution result
     BIS_debug_pub.add('The view creation sql execution result is :'
                               || to_char(l_sql_result));

     if nvl(l_sql_result,-1) <> 0 then
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg
              (   G_PKG_NAME
              ,   'Create_Ind_Level_View'
              );
          END IF;
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
     else

/*      fnd_message.set_name('_','IND_LEVEL_VIEW_CREATED');
      fnd_message.set_token('VIEW_NAME','BIS_'
                      || substr(replace(p_ind_level_name,' ','_'),1,24)|| '_v');
      fnd_message.set_token('FOR_LEVEL',p_ind_level_name);
      fnd_msg_pub.add;
*/
     null;
     end if;
     FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
     x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_Ind_Level_View'
            );

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Create_Ind_Level_View;

Procedure Create_Indicator_views
   (p_indicator_name IN Varchar2
   ,p_msg_init       IN Varchar2 default FND_API.G_TRUE
   ,x_return_status  OUT Varchar2
   ,x_msg_count      OUT Number
   ,x_msg_data       OUT Varchar2)
is
Cursor C_levels(p_indicator_name Varchar2) is
   select lvl.short_name
   from BIS_target_levels lvl,
        BIS_indicators ind
   where lvl.indicator_id = ind.indicator_id
   and ind.short_name = p_indicator_name;
l_return_status varchar2(10);
Begin
   BIS_debug_pub.add('In Create Indicator Views');
   BIS_debug_pub.add('Select Levels for Indicator:' || p_indicator_name);
   l_return_status := FND_API.G_RET_STS_SUCCESS;

   --  Initialize message list.
   if p_msg_init = FND_API.G_TRUE then
      FND_MSG_PUB.initialize;
   end if;

   for r1 in c_levels(p_indicator_name) loop
      BIS_debug_pub.add('Calling Create Level force View for Level:'
         || r1.short_name);
      Create_Ind_Level_View
      (p_ind_level_name => r1.short_name
      ,p_msg_init => fnd_api.g_false
      ,x_return_status=> l_return_status
      ,x_msg_count => x_msg_count
      ,x_msg_data => x_msg_data
      );
   end loop;
   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
   END IF;
   x_return_status := l_return_status;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_Indicator_views'
            );

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Create_Indicator_views;

Procedure Create_BIS_views
   (p_msg_init       IN Varchar2 default FND_API.G_TRUE
   ,x_return_status  OUT Varchar2
   ,x_msg_count      OUT Number
   ,x_msg_data       OUT Varchar2)
is
Cursor C_indicator is
   select short_name
   from BIS_indicators ;
l_return_status varchar2(10);
Begin
   BIS_debug_pub.add('In Create BIS Views');
   l_return_status := FND_API.G_RET_STS_SUCCESS;

   --  Initialize message list.
   if p_msg_init = FND_API.G_TRUE then
      FND_MSG_PUB.initialize;
   end if;

   for r1 in c_indicator loop
      BIS_debug_pub.add('Calling Create BIS force View for Indicator:'
         || r1.short_name);
      Create_Indicator_views
      (p_indicator_name => r1.short_name
      ,p_msg_init => fnd_api.g_false
      ,x_return_status=> l_return_status
      ,x_msg_count => x_msg_count
      ,x_msg_data => x_msg_data
      );
   end loop;
   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
   END IF;
   x_return_status := l_return_status;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_BIS_views'
            );

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Create_BIS_views;

Procedure Drop_Ind_Level_view
   (p_target_level_id IN  Number
   ,x_return_status   OUT Varchar2
   ,x_msg_count       OUT Number
   ,x_msg_data        OUT Varchar2)
IS
l_view_name	Varchar2(30);
l_cursor	Integer;
l_sql_result	number;
l_rtn_val Varchar2(80);
begin
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   select short_name into l_view_name from bis_target_levels
   where target_level_id = p_target_level_id;
   -- open cursor
   l_cursor := dbms_sql.open_cursor;

   -- parse statement
   dbms_sql.parse(c => l_cursor
		 ,statement => 'drop view BIS_'|| l_view_name ||'_V'
		 ,language_flag => DBMS_SQL.Native);

   -- execuse cursor
   l_sql_result := dbms_sql.execute(l_cursor);

   -- close cursor
   dbms_sql.close_cursor(l_cursor);
   if nvl(l_sql_result,-1) <> 0 then
   NULL;
--      dbms_output.put_line('Error');
   else
   NULL;
--      dbms_output.put_line('View dropped');
   end if;
EXCEPTION

	WHEN OTHERS THEN

	   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	   THEN
	      FND_MSG_PUB.Add_Exc_Msg
		(G_PKG_NAME
		,'Drop_Ind_Level_View');
	   END IF;

	-- get message count and data
	FND_MSG_PUB.Count_And_Get
	(p_count	=> x_msg_count
	,p_data		=> x_msg_data
	);

END Drop_Ind_Level_view;


Procedure Get_Dimension_Display_Value
   (p_dim_level_id    IN number
   ,p_dim_level_value_id    IN Varchar2
   ,x_dim_level_value_name  OUT Varchar2
   ,x_return_status   OUT Varchar2
   ,x_msg_count       OUT Number
   ,x_msg_data        OUT Varchar2)
IS
  l_view_name Varchar2(80);
  v_value Varchar2(80);
  l_cursor Integer;
  l_value_id Varchar2(40);
  l_select_stmt Varchar2(2000);
  l_sql_result   Integer := 0;
begin
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   select level_values_view_name into l_view_name
   from bis_levels where level_id = p_dim_level_id;

  l_cursor := dbms_sql.open_cursor;

  l_select_stmt := 'select value from '|| l_view_name
		   ||' where id = :dim_level_value_id';

  dbms_sql.parse(c => l_cursor,
		 statement => l_select_stmt,
		 language_flag => DBMS_SQL.Native);

  dbms_sql.bind_variable(l_cursor, ':dim_level_value_id',p_dim_level_value_id);
  dbms_sql.define_column(l_cursor,1,v_value,80);
  l_sql_result := dbms_sql.execute_and_fetch(l_cursor,TRUE);
  dbms_sql.column_value(l_cursor,1,v_value);

  x_dim_level_value_name := v_value;

  dbms_sql.close_cursor(l_cursor);

EXCEPTION

	WHEN OTHERS THEN

	   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	   THEN
	      FND_MSG_PUB.Add_Exc_Msg
		(G_PKG_NAME
		,'Get_Dimension_Display_Value');
	   END IF;

	-- get message count and data
	FND_MSG_PUB.Count_And_Get
	(p_count	=> x_msg_count
	,p_data		=> x_msg_data
	);
end Get_Dimension_Display_Value;

Procedure Validate_Resp_Org
   (p_dim_level_id     	IN number
   ,p_responsibility_id IN number
   ,p_organization_id 	IN number
   ,p_user_id		IN number
   ,x_return_status   OUT Varchar2
   ,x_msg_count       OUT Number
   ,x_msg_data        OUT Varchar2)
IS
  l_view_name Varchar2(80);
  l_resp_id number;
  l_org_id number;
  l_user_id number;
  l_cursor Integer;
  l_value_id Varchar2(40);
  l_select_stmt Varchar2(2000);
  l_sql_result   Integer := 0;
begin

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   select level_values_view_name into l_view_name
   from bis_levels where level_id = p_dim_level_id;
--dbms_output.put_line('view name: '||l_view_name);

   l_cursor := DBMS_SQL.OPEN_CURSOR;

   l_select_stmt := 'select v.responsibility_id, v.id, f.user_id '
		    ||' from '||l_view_name||' v, fnd_user_responsibility f '
		    ||' where v.responsibility_id = :responsibility_id '
		    ||' and v.id = :organization_id '
		    ||' and f.user_id = :user_id '
		    ||' and v.responsibility_id = f.responsibility_id '
		    ||' and f.start_date <= SYSDATE and nvl(f.end_date,SYSDATE) >= SYSDATE ';

   DBMS_SQL.PARSE(c => l_cursor,
		  statement => l_select_stmt,
		  language_flag => DBMS_SQL.NATIVE);

   DBMS_SQL.BIND_VARIABLE(l_cursor, ':responsibility_id',p_responsibility_id);
   DBMS_SQL.BIND_VARIABLE(l_cursor, ':organization_id',p_organization_id);
   DBMS_SQL.BIND_VARIABLE(l_cursor, ':user_id',p_user_id);

   DBMS_SQL.DEFINE_COLUMN(l_cursor, 1, l_resp_id);
   DBMS_SQL.DEFINE_COLUMN(l_cursor, 2, l_org_id);
   DBMS_SQL.DEFINE_COLUMN(l_cursor, 3, l_user_id);

   l_sql_result := DBMS_SQL.EXECUTE(l_cursor);

   DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_resp_id);
   DBMS_SQL.COLUMN_VALUE(l_cursor, 2, l_org_id);
   DBMS_SQL.COLUMN_VALUE(l_cursor, 3, l_user_id);

   if DBMS_SQL.FETCH_ROWS(l_cursor) = 0 then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   else
--dbms_output.put_line('resp id : '||to_char(l_resp_id));
--dbms_output.put_line('org id : '||to_char(l_org_id));
--dbms_output.put_line('user id : '||to_char(l_user_id));


   DBMS_SQL.CLOSE_CURSOR(l_cursor);

   end if;

EXCEPTION

	WHEN OTHERS THEN

	   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	   THEN
	      FND_MSG_PUB.Add_Exc_Msg
		(G_PKG_NAME
		,'Validate_Resp_Org');
	   END IF;

	-- get message count and data
	FND_MSG_PUB.Count_And_Get
	(p_count	=> x_msg_count
	,p_data		=> x_msg_data
	);

end Validate_Resp_Org;

END BIS_TARGET_UTIL;

/
