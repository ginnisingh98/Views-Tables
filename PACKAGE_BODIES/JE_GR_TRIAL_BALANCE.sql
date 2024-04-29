--------------------------------------------------------
--  DDL for Package Body JE_GR_TRIAL_BALANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_GR_TRIAL_BALANCE" as
/* $Header: jegrftbb.pls 120.4.12010000.2 2008/08/04 12:27:16 vgadde ship $ */

/*------------------------------------------------------------------+
 | Package Cursor and Variables                                     |
 +------------------------------------------------------------------*/

/* The following v_n_% variables are needed to include the delimiter
   in the account segment value as well as the parent level values */

v_1_width NUMBER := 0;
v_1_start NUMBER := 0;
v_1_end   NUMBER := 0;
v_2_width NUMBER := 0;
v_2_start NUMBER := 0;
v_2_end   NUMBER := 0;
v_3_width NUMBER := 0;
v_3_start NUMBER := 0;
v_3_end   NUMBER := 0;
v_4_width NUMBER := 0;
v_4_start NUMBER := 0;
v_4_end   NUMBER := 0;
v_5_width NUMBER := 0;
v_5_start NUMBER := 0;
v_5_end   NUMBER := 0;
v_6_width NUMBER := 0;
v_6_start NUMBER := 0;
v_6_end   NUMBER := 0;
v_7_width NUMBER := 0;
v_7_start NUMBER := 0;
v_7_end   NUMBER := 0;
v_8_width NUMBER := 0;
v_8_start NUMBER := 0;
v_8_end   NUMBER := 0;
v_9_width NUMBER := 0;
v_9_start NUMBER := 0;
v_9_end   NUMBER := 0;


/*------------------------------------------------------------------+
 | Private Procedures/Functions - Specification                     |
 +------------------------------------------------------------------*/

PROCEDURE clean_up_hierarchy (p_idx IN NUMBER);
PROCEDURE insert_delimiter   (p_idx IN NUMBER, p_delimiter VARCHAR2);

/*------------------------------------------------------------------+
 | Public Procedures/Functions                                      |
 +------------------------------------------------------------------*/

/*------------------------------------------------------------------+
 | PROCEDURE: init_account_hierarchy                                |
 +------------------------------------------------------------------*/

FUNCTION  init_account_hierarchy (p_request_id        IN     NUMBER,
                                  p_delimiter         IN     VARCHAR2,
                                  p_retcode           IN OUT NOCOPY NUMBER,
				  p_errmsg            IN OUT NOCOPY VARCHAR2)
RETURN NUMBER is

v_idx			           NUMBER;
v_parent_value         varchar2(100);
v_child_value          varchar2(100);
v_hier_level           NUMBER;
v_step                 varchar2(100);
v_found_parent         BOOLEAN;
v_max_levels           NUMBER := 0;
v_status               BOOLEAN;
v_chart_of_accounts_id NUMBER;
v_acct_segnum          NUMBER;
v_appcol_name          VARCHAR2(100);
v_prompt               VARCHAR2(100);
v_value_set_name       VARCHAR2(100);
v_value_set_id         NUMBER;
v_seg_name             VARCHAR2(100);
v_flexfield            FND_FLEX_KEY_API.flexfield_type;
v_structure            FND_FLEX_KEY_API.structure_type;
v_segment              FND_FLEX_KEY_API.segment_type;
v_set_of_books_id      NUMBER;

/* This cursor selects all the account segments that we need to get parents
   for */

cursor c_account_values (c_request_id NUMBER) is
   select distinct account_segment
   from   gl_rx_trial_balance_itf
   where  request_id = c_request_id;


/* This cursor select the parent of a child value */

cursor c_parent_value (c_flex_value_set_id NUMBER, c_child_value varchar2) is
   select
     c.parent_flex_value,
     to_number(fv.hierarchy_level)
   from
     FND_FLEX_VALUES FV,
     FND_FLEX_VALUE_CHILDREN_V C
   where
     c.flex_value_set_id =  c_flex_value_set_id and
     c.flex_value = c_child_value and
     fv.flex_value_set_id = c.flex_value_set_id and
     fv.flex_value = c.parent_flex_value
   order by fv.hierarchy_level desc;

begin

 v_step := 'c_account_values loop';

 /* If this is not the first call, don't populate global PL/SQL table again */

 if (g_request_id = p_request_id) then goto done; end if;

 g_request_id := p_request_id;

 v_set_of_books_id := fnd_profile.value('GL_SET_OF_BKS_ID');

 select chart_of_accounts_id
 into   v_chart_of_accounts_id
 from   gl_sets_of_books
 where  set_of_books_id = v_set_of_books_id;

 v_status := FND_FLEX_APIS.GET_QUALIFIER_SEGNUM (
                		appl_id           => 101,
				key_flex_code     => 'GL#',
				structure_number  => v_chart_of_accounts_id,
				flex_qual_name    => 'GL_ACCOUNT',
				segment_number    => v_acct_segnum);

 v_status := FND_FLEX_APIS.GET_SEGMENT_INFO (
 		  	    	x_application_id  => 101,
				x_id_flex_code    => 'GL#',
				x_id_flex_num     => v_chart_of_accounts_id,
				x_seg_num         => v_acct_segnum,
                		x_seg_name        => v_seg_name,
				x_appcol_name     => v_appcol_name,
				x_prompt          => v_prompt,
				x_value_set_name  => v_value_set_name);

 /* Bug 2560279: Set up session mode. */
 FND_FLEX_KEY_API.set_session_mode('customer_data');

 v_flexfield    := FND_FLEX_KEY_API.FIND_FLEXFIELD ('SQLGL', 'GL#');
 v_structure    := FND_FLEX_KEY_API.FIND_STRUCTURE (v_flexfield, v_chart_of_accounts_id);
 v_segment      := FND_FLEX_KEY_API.FIND_SEGMENT   (v_flexfield, v_structure, v_seg_name);
 v_value_set_id := v_segment.value_set_id;

 open c_account_values (p_request_id);

 /* The following loop fetches all accounts for which we have to find
    the parents */

 LOOP

   fetch c_account_values into v_child_value;
   exit  when c_account_values%NOTFOUND;

   v_step := 'c_parent_value_loop';

   /* Initalize global PL/SQL table */

   g_account_tab(g_idx).account := v_child_value;
   g_account_tab(g_idx).delimit_account := v_child_value;
   g_account_tab(g_idx).levels  := 0;
   g_account_tab(g_idx).L1      := '';
   g_account_tab(g_idx).L2      := '';
   g_account_tab(g_idx).L3      := '';
   g_account_tab(g_idx).L4      := '';
   g_account_tab(g_idx).L5      := '';
   g_account_tab(g_idx).L6      := '';
   g_account_tab(g_idx).L7      := '';
   g_account_tab(g_idx).L8      := '';
   g_account_tab(g_idx).L9      := '';

   /* The following loop takes the child value and goes up the
      hierarchy until the top level parent was found. It stores
      one record per account in global PL/SQL table g_account_tab. */

   LOOP

     v_step := 'c_parent_value_loop';

     open  c_parent_value (v_value_set_id, v_child_value);
     fetch c_parent_value into v_parent_value, v_hier_level;
     exit  when c_parent_value%NOTFOUND; /* At top of hierarchy */

     /* Populate PL/SQL table */

     if    (v_hier_level = 1) then
	        g_account_tab(g_idx).L1     := v_parent_value;
	        g_account_tab(g_idx).levels := 1;
		if (v_max_levels < v_hier_level) then v_max_levels := v_hier_level; end if;
	 elsif (v_hier_level = 2) then
	        g_account_tab(g_idx).L2     := v_parent_value;
	        g_account_tab(g_idx).levels := 2;
		if (v_max_levels < v_hier_level) then v_max_levels := v_hier_level; end if;
	 elsif (v_hier_level = 3) then
	        g_account_tab(g_idx).L3     := v_parent_value;
	        g_account_tab(g_idx).levels := 3;
		if (v_max_levels < v_hier_level) then v_max_levels := v_hier_level; end if;
	 elsif (v_hier_level = 4) then
	        g_account_tab(g_idx).L4     := v_parent_value;
	        g_account_tab(g_idx).levels := 4;
		if (v_max_levels < v_hier_level) then v_max_levels := v_hier_level; end if;
	 elsif (v_hier_level = 5) then
	        g_account_tab(g_idx).L5     := v_parent_value;
	        g_account_tab(g_idx).levels := 5;
		if (v_max_levels < v_hier_level) then v_max_levels := v_hier_level; end if;
	 elsif (v_hier_level = 6) then
	        g_account_tab(g_idx).L6     := v_parent_value;
	        g_account_tab(g_idx).levels := 6;
		if (v_max_levels < v_hier_level) then v_max_levels := v_hier_level; end if;
	 elsif (v_hier_level = 7) then
	        g_account_tab(g_idx).L7     := v_parent_value;
	        g_account_tab(g_idx).levels := 7;
		if (v_max_levels < v_hier_level) then v_max_levels := v_hier_level; end if;
	 elsif (v_hier_level = 8) then
	        g_account_tab(g_idx).L8     := v_parent_value;
	        g_account_tab(g_idx).levels := 8;
		if (v_max_levels < v_hier_level) then v_max_levels := v_hier_level; end if;
	 elsif (v_hier_level = 9) then
	        g_account_tab(g_idx).L9     := v_parent_value;
	        g_account_tab(g_idx).levels := 9;
	 end if; close c_parent_value;

     /* for next open/fetch/close round the current parent will be the new child */

     v_child_value := v_parent_value;

   end loop;

   close c_parent_value;

   g_idx := g_idx + 1;

 END LOOP;

 close c_account_values;

 /* Insert delimiter at correct position for account segment value and
    parent level value */

 FOR v_idx in 0..g_idx-1 LOOP

  if (g_account_tab(v_idx).levels > 0)
  then

    /* We need to clean up the level hierarchy in case there are any gaps
       between the top level parent and the actual account (lowest level entry) */

    clean_up_hierarchy (v_idx);

    /* Insert the delimiter into both the account and the parent level values */

    insert_delimiter (v_idx, p_delimiter);

  end if;

 END LOOP;

 <<done>>

 return(v_max_levels);

EXCEPTION
  WHEN OTHERS THEN
     if c_account_values%ISOPEN then close c_account_values; end if;
     if c_parent_value%ISOPEN   then close c_parent_value;   end if;
     p_retcode := -1;
	 p_errmsg  := 'Error occurred in je_gr_trial_balance.init_account_hierarchy: ' || sqlerrm;
	 return(v_max_levels);
end;

/*------------------------------------------------------------------+
 | FUNCTION: get_level_value                                        |
 +------------------------------------------------------------------*/

FUNCTION get_level_value  (p_level   IN     NUMBER,
                           p_account IN     VARCHAR2)
RETURN VARCHAR2 is

v_idx	       NUMBER;
v_string       VARCHAR2(150);

BEGIN
 v_string := '';
 FOR v_idx in 0..g_idx-1 LOOP

    if (g_account_tab(v_idx).account = p_account)
    then
       if    (p_level = 0) then v_string := g_account_tab(v_idx).delimit_account;
       elsif (p_level = 1) then v_string := g_account_tab(v_idx).L1;
       elsif (p_level = 2) then v_string := g_account_tab(v_idx).L2;
       elsif (p_level = 3) then v_string := g_account_tab(v_idx).L3;
       elsif (p_level = 4) then v_string := g_account_tab(v_idx).L4;
       elsif (p_level = 5) then v_string := g_account_tab(v_idx).L5;
       elsif (p_level = 6) then v_string := g_account_tab(v_idx).L6;
       elsif (p_level = 7) then v_string := g_account_tab(v_idx).L7;
       elsif (p_level = 8) then v_string := g_account_tab(v_idx).L8;
       elsif (p_level = 9) then v_string := g_account_tab(v_idx).L9;
       end if;
    end if;

 END LOOP;

 return(v_string);

EXCEPTION
  WHEN OTHERS THEN
     return(NULL);
END;


/*------------------------------------------------------------------+
 | Private Procedures                                               |
 +------------------------------------------------------------------*/

/*------------------------------------------------------------------+
 | PROCEDURE: clean_up_hierarchy                                    |
 +------------------------------------------------------------------*/

PROCEDURE clean_up_hierarchy (p_idx IN NUMBER) IS

v_clean_level          NUMBER;

BEGIN

  /* Clean up the hierarchy for each account; have to do this in case there
     is a gap in the hierarchy between the top level entry (L1) and the lowest
     level entry (account) */

   v_clean_level := 0;

   /* Determine if cleanup needs to be performed */

   if    (g_account_tab(p_idx).L1 is NULL) then
       v_clean_level := 1;
   elsif (g_account_tab(p_idx).L2 is NULL) then
       v_clean_level := 2;
   elsif (g_account_tab(p_idx).L3 is NULL) then
       v_clean_level := 3;
   elsif (g_account_tab(p_idx).L4 is NULL) then
       v_clean_level := 4;
   elsif (g_account_tab(p_idx).L5 is NULL) then
       v_clean_level := 5;
   elsif (g_account_tab(p_idx).L6 is NULL) then
       v_clean_level := 6;
   elsif (g_account_tab(p_idx).L7 is NULL) then
       v_clean_level := 7;
   elsif (g_account_tab(p_idx).L8 is NULL) then
       v_clean_level := 8;
   elsif (g_account_tab(p_idx).L9 is NULL) then
       v_clean_level := 9;
   end if;

   if (v_clean_level > 0) then /* have to do clean up */

      if (v_clean_level < 10) then g_account_tab(p_idx).L9 := ''; end if;
      if (v_clean_level < 9)  then g_account_tab(p_idx).L8 := ''; end if;
      if (v_clean_level < 8)  then g_account_tab(p_idx).L7 := ''; end if;
      if (v_clean_level < 7)  then g_account_tab(p_idx).L6 := ''; end if;
      if (v_clean_level < 6)  then g_account_tab(p_idx).L5 := ''; end if;
      if (v_clean_level < 5)  then g_account_tab(p_idx).L4 := ''; end if;
      if (v_clean_level < 4)  then g_account_tab(p_idx).L3 := ''; end if;
      if (v_clean_level < 3)  then g_account_tab(p_idx).L2 := ''; end if;
      if (v_clean_level < 2)  then g_account_tab(p_idx).L1 := ''; end if;

      g_account_tab(p_idx).levels := v_clean_level - 1;

   end if;

END;

/*------------------------------------------------------------------+
 | PROCEDURE: insert_delimiter                                      |
 +------------------------------------------------------------------*/


PROCEDURE insert_delimiter (p_idx IN NUMBER, p_delimiter IN VARCHAR2) IS
BEGIN

   /* Initialize delimiter variables */

   v_1_width  := 0;   v_1_start  := 0;   v_1_end    := 0;
   v_2_width  := 0;   v_2_start  := 0;   v_2_end    := 0;
   v_3_width  := 0;   v_3_start  := 0;   v_3_end    := 0;
   v_4_width  := 0;   v_4_start  := 0;   v_4_end    := 0;
   v_5_width  := 0;   v_5_start  := 0;   v_5_end    := 0;
   v_6_width  := 0;   v_6_start  := 0;   v_6_end    := 0;
   v_7_width  := 0;   v_7_start  := 0;   v_7_end    := 0;
   v_8_width  := 0;   v_8_start  := 0;   v_8_end    := 0;
   v_9_width  := 0;   v_9_start  := 0;   v_9_end    := 0;

   /* Now we will determine the start position and width of each parent level
      value */

   if    (g_account_tab(p_idx).L1 is not NULL) then
			  v_1_width := length(g_account_tab(p_idx).L1);
			  v_1_start := 1;
   			  v_1_end   := length(g_account_tab(p_idx).L1);
   end if;

  /* Bug 2226088: In the following if statements, replaced
       v_2_width := length(g_account_tab(p_idx).L2) - v_<number>_width;
     with
       v_2_width := length(g_account_tab(p_idx).L2) - v_<number>_end;
     to insert the delimiter in the correct position. */

   if    (g_account_tab(p_idx).L2 is not NULL) then
                          v_2_width := length(g_account_tab(p_idx).L2) - v_1_end;
			  v_2_start := v_1_end + 1;
			  v_2_end   := v_2_start + v_2_width - 1;
   end if;
   if    (g_account_tab(p_idx).L3 is not NULL) then
                          v_3_width := length(g_account_tab(p_idx).L3) - v_2_end;
			  v_3_start := v_2_end + 1;
			  v_3_end   := v_3_start + v_3_width - 1;
   end if;
   if    (g_account_tab(p_idx).L4 is not NULL) then
                          v_4_width := length(g_account_tab(p_idx).L4) - v_3_end;
			  v_4_start := v_3_end + 1;
			  v_4_end   := v_4_start + v_4_width - 1;
   end if;
   if    (g_account_tab(p_idx).L5 is not NULL) then
                          v_5_width := length(g_account_tab(p_idx).L5) - v_4_end;
			  v_5_start := v_4_end + 1;
			  v_5_end   := v_5_start + v_5_width - 1;
   end if;
   if    (g_account_tab(p_idx).L6 is not NULL) then
                          v_6_width := length(g_account_tab(p_idx).L6) - v_5_end;
			  v_6_start := v_5_end + 1;
			  v_6_end   := v_6_start + v_6_width - 1;
   end if;
   if    (g_account_tab(p_idx).L7 is not NULL) then
                          v_7_width := length(g_account_tab(p_idx).L7) - v_6_end;
			  v_7_start := v_6_end + 1;
			  v_7_end   := v_7_start + v_7_width - 1;
   end if;
   if    (g_account_tab(p_idx).L8 is not NULL) then
                          v_8_width := length(g_account_tab(p_idx).L8) - v_7_end;
			  v_8_start := v_7_end + 1;
			  v_8_end   := v_8_start + v_8_width - 1;
   end if;
   if    (g_account_tab(p_idx).L9 is not NULL) then
                          v_9_width := length(g_account_tab(p_idx).L9) - v_8_end;
			  v_9_start := v_8_end + 1;
			  v_9_end   := v_9_start + v_9_width - 1;
   end if;

   /* Start delimiting - the logic is to insert the delimiter into the parent (L1 through L9) and
      then to also insert it into the delimited account, g_account_tab(p_idx).delimit_account */

   if  (g_account_tab(p_idx).L1 is not NULL) then
       g_account_tab(p_idx).delimit_account :=
	                          substr(g_account_tab(p_idx).account, v_1_start, v_1_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_1_end + 1, 999);
   end if;

   if  (g_account_tab(p_idx).L2 is not NULL) then
       g_account_tab(p_idx).delimit_account :=
	                          substr(g_account_tab(p_idx).account, v_1_start, v_1_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_2_start, v_2_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_2_end + 1, 999);

       g_account_tab(p_idx).L2 := substr(g_account_tab(p_idx).L2, v_1_start, v_1_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L2, v_2_start, v_2_width);

   end if;

   if  (g_account_tab(p_idx).L3 is not NULL) then
       g_account_tab(p_idx).delimit_account :=
	                          substr(g_account_tab(p_idx).account, v_1_start, v_1_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_2_start, v_2_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_3_start, v_3_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_3_end + 1, 999);

       g_account_tab(p_idx).L3 := substr(g_account_tab(p_idx).L3, v_1_start, v_1_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L3, v_2_start, v_2_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L3, v_3_start, v_3_width);
   end if;

   if  (g_account_tab(p_idx).L4 is not NULL) then
       g_account_tab(p_idx).delimit_account :=
	                          substr(g_account_tab(p_idx).account, v_1_start, v_1_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_2_start, v_2_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_3_start, v_3_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_4_start, v_4_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_4_end + 1, 999);

       g_account_tab(p_idx).L4 := substr(g_account_tab(p_idx).L4, v_1_start, v_1_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L4, v_2_start, v_2_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L4, v_3_start, v_3_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L4, v_4_start, v_4_width);
   end if;

   if  (g_account_tab(p_idx).L5 is not NULL) then
       g_account_tab(p_idx).delimit_account :=
	                          substr(g_account_tab(p_idx).account, v_1_start, v_1_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_2_start, v_2_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_3_start, v_3_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_4_start, v_4_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_5_start, v_5_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_5_end + 1, 999);

       g_account_tab(p_idx).L5 := substr(g_account_tab(p_idx).L5, v_1_start, v_1_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L5, v_2_start, v_2_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L5, v_3_start, v_3_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L5, v_4_start, v_4_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L5, v_5_start, v_5_width);
   end if;

   if  (g_account_tab(p_idx).L6 is not NULL) then
       g_account_tab(p_idx).delimit_account :=
	                          substr(g_account_tab(p_idx).account, v_1_start, v_1_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_2_start, v_2_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_3_start, v_3_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_4_start, v_4_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_5_start, v_5_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_6_start, v_6_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_6_end + 1, 999);

       g_account_tab(p_idx).L6 := substr(g_account_tab(p_idx).L6, v_1_start, v_1_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L6, v_2_start, v_2_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L6, v_3_start, v_3_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L6, v_4_start, v_4_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L6, v_5_start, v_5_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L6, v_6_start, v_6_width);
   end if;

   if  (g_account_tab(p_idx).L7 is not NULL) then
       g_account_tab(p_idx).delimit_account :=
	                          substr(g_account_tab(p_idx).account, v_1_start, v_1_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_2_start, v_2_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_3_start, v_3_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_4_start, v_4_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_5_start, v_5_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_6_start, v_6_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_7_start, v_7_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_7_end + 1, 999);

       g_account_tab(p_idx).L7 := substr(g_account_tab(p_idx).L7, v_1_start, v_1_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L7, v_2_start, v_2_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L7, v_3_start, v_3_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L7, v_4_start, v_4_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L7, v_5_start, v_5_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L7, v_6_start, v_6_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L7, v_7_start, v_7_width);
   end if;

   if  (g_account_tab(p_idx).L8 is not NULL) then
       g_account_tab(p_idx).delimit_account :=
	                          substr(g_account_tab(p_idx).account, v_1_start, v_1_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_2_start, v_2_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_3_start, v_3_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_4_start, v_4_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_5_start, v_5_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_6_start, v_6_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_7_start, v_7_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_8_start, v_8_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_8_end + 1, 999);

       g_account_tab(p_idx).L8 := substr(g_account_tab(p_idx).L8, v_1_start, v_1_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L8, v_2_start, v_2_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L8, v_3_start, v_3_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L8, v_4_start, v_4_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L8, v_5_start, v_5_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L8, v_6_start, v_6_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L8, v_7_start, v_7_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L8, v_8_start, v_8_width);
   end if;

   if  (g_account_tab(p_idx).L9 is not NULL) then

       g_account_tab(p_idx).delimit_account :=
	                          substr(g_account_tab(p_idx).account, v_1_start, v_1_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_2_start, v_2_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_3_start, v_3_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_4_start, v_4_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_5_start, v_5_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_6_start, v_6_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_7_start, v_7_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_8_start, v_8_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_9_start, v_9_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).account, v_9_end + 1, 999);

       g_account_tab(p_idx).L9 := substr(g_account_tab(p_idx).L9, v_1_start, v_1_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L9, v_2_start, v_2_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L9, v_3_start, v_3_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L9, v_4_start, v_4_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L9, v_5_start, v_5_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L9, v_6_start, v_6_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L9, v_7_start, v_7_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L9, v_8_start, v_8_width) || p_delimiter ||
	                          substr(g_account_tab(p_idx).L9, v_9_start, v_9_width);
   end if;

end;

END JE_GR_TRIAL_BALANCE;

/
