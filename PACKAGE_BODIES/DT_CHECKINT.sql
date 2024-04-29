--------------------------------------------------------
--  DDL for Package Body DT_CHECKINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DT_CHECKINT" as
/* $Header: dtchkint.pkb 115.1 99/07/16 23:59:47 porting ship $ */
--
  --
  --
  -- GLOBAL VARIABLES AND TYPES
  --
  g_output varchar2(80) := 'DBMS_OUTPUT' ;
  g_schema varchar2(80) := user ;


  --
  -- A row is retrieved into the following record type
  --
  type dt_row is record ( id_value             number ,
			  effective_start_date date,
			  effective_end_date   date,
			  creation_date	       date,
			  last_update_date     date  ) ;

  g_temp_row dt_row ;

  --
  -- The row is then stored in the following type
  --
  type tab_id_value             is table of number       index by binary_integer ;
  type tab_effective_start_date is table of date         index by binary_integer ;
  type tab_effective_end_date   is table of date         index by binary_integer ;
  type tab_creation_date        is table of date         index by binary_integer ;
  type tab_message              is table of varchar2(80) index by binary_integer ;

  g_tab_id_value 	     tab_id_value;
  g_tab_effective_start_date tab_effective_start_date;
  g_tab_effective_end_date   tab_effective_start_date;
  g_tab_creation_date        tab_effective_start_date;
  g_tab_last_update_date     tab_effective_start_date;
  g_tab_message              tab_message;

  g_empty_number   tab_id_value ;
  g_empty_date     tab_effective_start_date ;
  g_empty_message  tab_message ;

  TABLE_MAXSIZE constant number := 20  ;		-- Maximum number of datetrack changes for a given id



  g_db_type varchar2(30) ;
  subtype db_col_type is g_db_type%type ;   -- In later release of pl/sql can put a number here directly


  type table_info is record ( tab_name     varchar2(30),
			      schema_name  varchar2(30),
			      has_who_cols boolean ) ;

  --
  -- PRIVATE ROUTINES
  --
  -- Name
  --  initialize_output
  -- Purpose
  --  If DBMS_PIPE is specified then enable trace
  -- Notes
  procedure initialize_output is
  begin

    if ( g_output = 'DBMS_PIPE' )  then

	hr_utility.trace_on('F') ;

    end if;

  end initialize_output ;

  -- Name
  --  output_line
  -- Purpose
  --  Outputs a text line.
  -- Notes
  procedure output_line ( p_text in varchar2 ) is
  begin

    if ( g_output = 'DBMS_OUTPUT' )  then

	dbms_output.put_line ( p_text ) ;

    else

	hr_utility.trace( p_text ) ;


   end if;

  end output_line ;

  -- Name
  --  output_newline
  -- Purpose
  --  Outputs a blank line
  -- Notes
  procedure output_newline is
  begin

      output_line('');

  end output_newline ;

  -- Name
  --  output_row
  -- Purpose
  --  Outputs a row
  -- Notes
  --
  procedure output_row ( p_row     in dt_row,
			 p_message in varchar2 ) is

  l_eff_date_fmt varchar2(30) := 'DD-MON-YYYY' ;
  l_who_col_fmt  varchar2(30) := 'DD-MON-YYYY HH24:MI:SS' ;
  begin

    output_line ( '   '||lpad(to_char(p_row.ID_VALUE),8)||
		  ' '||to_char(p_row.EFFECTIVE_START_DATE , l_eff_date_fmt )  ||
		  ' '||to_char(p_row.EFFECTIVE_END_DATE ,   l_eff_date_fmt )  ||
		  '          '||to_char(p_row.CREATION_DATE ,l_who_col_fmt)||
		  ' '    ||to_char(p_row.LAST_UPDATE_DATE ,l_who_col_fmt)||'  '|| p_message   ) ;

  end output_row ;
  procedure output_row ( p_id_value             in number,
			 p_effective_start_date in date,
			 p_effective_end_date   in date,
			 p_creation_date	in date,
			 p_last_update_date	in date,
			 p_message              in varchar2 ) is
  l_dt_row dt_row ;
  begin

      l_dt_row.id_value             := p_id_value ;
      l_dt_row.effective_start_date := p_effective_start_date ;
      l_dt_row.effective_end_date   := p_effective_end_date ;
      l_dt_row.creation_date        := p_creation_date ;
      l_dt_row.last_update_date     := p_last_update_date ;

      output_row ( l_dt_row , p_message ) ;

  end output_row ;

-------------------------------------------------------------------------------------------

  -- Name
  --  build_sql
  -- Purpose
  --  Builds the cursor which is designed to check the table.
  -- Notes
  function build_sql ( p_table in out table_info ) return varchar2 is
  l_template_cursor varchar2(2000) :=

	  'select :id_col , effective_start_date , effective_end_date  :who_cols
	   from   :table_name
           order by 1 , 2 , 3 ' ;

  function get_id_col ( p_table_name in varchar2 , p_schema in varchar2 ) return varchar2 is
  cursor get_pk_col_name is
    select ind.column_name
    from   all_ind_columns ind,
           all_constraints cons
    where  cons.owner           = p_schema
    and    cons.table_name      = p_table_name
    and    cons.constraint_type = 'P'
    and    cons.constraint_name = ind.index_name
    and    ind.table_owner      = p_schema
    and    ind.table_name       = p_table_name
    and    ind.column_position  = 1 ;

  l_return_value db_col_type ;
  begin


      open get_pk_col_name;
      fetch get_pk_col_name into l_return_value ;
      close get_pk_col_name ;

      return ( l_return_value ) ;

  end get_id_col ;

  -- Determines whether the given table has the standard who cols
  function table_has_who_cols ( p_table_name in varchar2 , p_schema in varchar2 ) return boolean is
  cursor get_creation_date_col is
    select 1
    from   all_tab_columns col
    where  col.owner       = p_schema
    and    col.table_name  = p_table_name
    and    col.column_name = 'CREATION_DATE' ;
  l_dummy         number ;
  l_return_status boolean ;
  begin

      open get_creation_date_col ;
      fetch get_creation_date_col into l_dummy ;
      l_return_status := get_creation_date_col%found ;
      close get_creation_date_col ;

      return ( l_return_status ) ;

  end table_has_who_cols ;


  begin

    l_template_cursor := replace ( l_template_cursor , ':id_col'     ,  get_id_col(p_table.tab_name, p_table.schema_name ) ) ;

    p_table.has_who_cols := table_has_who_cols ( p_table.tab_name , p_table.schema_name ) ;

    if ( p_table.has_who_cols )
    then

         l_template_cursor := replace ( l_template_cursor ,
					':who_cols',
			                ',CREATION_DATE, LAST_UPDATE_DATE ' ) ;

    else

         l_template_cursor := replace( l_template_cursor , ':who_cols'  , null ) ;

    end if;


    l_template_cursor := replace ( l_template_cursor , ':table_name' ,  p_table.tab_name ) ;

    return( l_template_cursor ) ;

  end build_sql ;

-------------------------------------------------------------------------------------------


  function prepare_cursor ( p_table in out table_info )  return integer is
  l_theStatement varchar2(2000) ;
  l_theCursor    integer  ;
  begin

    l_theCursor    := dbms_sql.open_cursor ;
    l_theStatement := build_sql( p_table ) ;

    dbms_sql.parse( l_theCursor, l_theStatement,  dbms_sql.v7 ) ;
    dbms_sql.define_column( l_theCursor, 1 , g_temp_row.id_value) ;
    dbms_sql.define_column( l_theCursor, 2 , g_temp_row.effective_start_date) ;
    dbms_sql.define_column( l_theCursor, 3 , g_temp_row.effective_end_date) ;

    if ( p_table.has_who_cols )
    then

       dbms_sql.define_column( l_theCursor, 4 , g_temp_row.creation_date) ;
       dbms_sql.define_column( l_theCursor, 5 , g_temp_row.last_update_date) ;

    end if;

    return ( l_theCursor ) ;

  end prepare_cursor ;

-------------------------------------------------------------------------------------------

  function copy_to_row ( p_cursor in integer , p_table table_info ) return dt_row is
  l_theRow dt_row ;
  begin

    dbms_sql.column_value( p_cursor, 1 , l_theRow.id_value) ;
    dbms_sql.column_value( p_cursor, 2 , l_theRow.effective_start_date) ;
    dbms_sql.column_value( p_cursor, 3 , l_theRow.effective_end_date) ;

    if ( p_table.has_who_cols )
    then

       dbms_sql.column_value( p_cursor, 4 , l_theRow.creation_date) ;
       dbms_sql.column_value( p_cursor, 5 , l_theRow.last_update_date) ;

    end if;

    return ( l_theRow ) ;

  end copy_to_row ;

-------------------------------------------------------------------------------------------
  procedure initialise_table(p_rowcount in number default null) is
  begin

        for i in 1..p_rowcount loop

	  g_tab_id_value(i)             := null ;
	  g_tab_effective_start_date(i) := null ;
	  g_tab_effective_end_date(i)   := null ;
	  g_tab_creation_date(i)        := null ;
	  g_tab_last_update_date(i)     := null ;
	  g_tab_message(i)              := null ;

        end loop ;

  end initialise_table ;
-------------------------------------------------------------------------------------------
  procedure save_to_table (  p_index number , p_row dt_row , p_message in varchar2 ) is
  begin

     g_tab_id_value(p_index)             := p_row.id_value ;
     g_tab_effective_start_date(p_index) := p_row.effective_start_date ;
     g_tab_effective_end_date(p_index)   := p_row.effective_end_date ;
     g_tab_creation_date(p_index)        := p_row.creation_date ;
     g_tab_last_update_date(p_index)     := p_row.last_update_date ;
     g_tab_message(p_index)              := p_message ;

  end save_to_table ;
-------------------------------------------------------------------------------------------
  procedure output_table( p_has_who_cols in boolean ) is

  procedure output_header ( p_has_who_cols in boolean ) is
  begin

     output_line( '    The following set contains at least one invalid row.');

     if ( not p_has_who_cols ) then
	 output_line('    Note - This table does not have WHO columns.');
     end if;

     output_newline;

     output_line('         ID EFF. START  EFF. END             DATE CREATED         LAST UPDATE           ERROR');
     output_line('    ------- ----------- -----------          -------------------- --------------------  --------------------------');

  end output_header ;

  begin

     output_header(p_has_who_cols) ;

     for i in 1..TABLE_MAXSIZE loop

	exit when g_tab_id_value(i) is null ;

	output_row ( g_tab_id_value(i),
		     g_tab_effective_start_date(i),
	             g_tab_effective_end_date(i),
	             g_tab_creation_date(i),
	             g_tab_last_update_date(i),
		     g_tab_message(i) ) ;

     end loop ;

     output_newline ;

  end output_table ;
-------------------------------------------------------------------------------------------


  -- Name
  --  chk_no_time
  -- Purpose
  --  Checks that there is no time component in the effective start and end dates
  -- Notes
  function check_no_time ( p_therow dt_row ) return varchar2 is

  begin

     if (    ( p_therow.effective_start_date <> trunc(p_therow.effective_start_date) )
	  or ( p_therow.effective_end_date <> trunc(p_therow.effective_end_date ) )
        ) then

       return 'HAS TIME COMPONENT' ;

    else

       return null ;

    end if ;

  end check_no_time ;

-------------------------------------------------------------------------------------------

  -- Name
  --  check_start_before_end
  -- Purpose
  --  Checks that eff. start is before eff end
  -- Notes
  function check_start_before_end ( p_therow dt_row ) return varchar2 is
  begin

     if ( p_therow.effective_start_date > p_therow.effective_end_date ) then

        return ('START DATE AFTER END DATE' ) ;

     else

	return null ;

     end if;

  end check_start_before_end ;

  -- Name
  --  check_for_gaps
  -- Purpose
  --  Compares two rows. If the ID columns have the same value then check the the start
  --  date of the current row is a day after the end date of the previous row.
  --  Also output an error if the last rows end date was end of time
  -- Notes
  function check_for_gaps ( p_current_row  dt_row , p_last_row dt_row ) return varchar2 is
  begin

      if ( p_current_row.id_value = p_last_row.id_value )  then

         if (    ( p_last_row.effective_end_date = hr_general.end_of_time )
	      OR ( p_current_row.effective_start_date < p_last_row.effective_end_date + 1 ) )
         then

	     return( 'OVERLAPS PREVIOUS ROW' ) ;

         elsif (     ( p_last_row.effective_end_date <> hr_general.end_of_time )
		 AND ( p_current_row.effective_start_date > p_last_row.effective_end_date + 1 ) ) then

	     return('GAP WITH PREVIOUS ROW') ;

         end if;

     end if;


     return null ;


  end check_for_gaps ;

  -- PUBLIC PROCEDURES AND FUNCTIONS
-------------------------------------------------------------------------------------------

  procedure set_options ( p_schema        in varchar2,
		          p_output_dest   in varchar2 default 'DBMS_OUTPUT' ) is
  begin

     g_schema := p_schema ;
     g_output := p_output_dest ;

     initialize_output ;

  end set_options ;

  procedure check_table ( p_table_name   in varchar2,
			  p_max_errors   in number   default  1 ) is
  l_cursor      integer ;
  l_ignore      integer ;
  l_current_row dt_row ;
  l_last_row    dt_row ;
  l_thetable    table_info ;

  row_count     binary_integer := 0 ;
  errors_found  boolean ;
  error_text    varchar2(2000) ;	-- Error message for the current row

  total_rows    number ;		-- Cumulative number of rows checked
  total_keys    number ;		-- Cumulative number of distinct id values

  begin



    output_line ( 'Checking table '||p_table_name||'...') ;
    output_newline ;

    l_thetable.tab_name    := p_table_name ;
    l_thetable.schema_name := g_schema ;


    l_cursor := prepare_cursor( l_thetable ) ;

    l_ignore := dbms_sql.execute(l_cursor) ;


    errors_found := false ;
    row_count    := 0 ;
    initialise_table( TABLE_MAXSIZE ) ;

    total_rows   := 0 ;
    total_keys   := 0 ;

    loop

       if ( dbms_sql.fetch_rows ( l_cursor ) > 0 ) then


	  l_current_row :=  copy_to_row ( l_cursor  , l_thetable ) ;
	  error_text    := null ;

	  if ( l_current_row.id_value <> l_last_row.id_value ) then

	     if ( errors_found )  then

		 output_table(l_thetable.has_who_cols) ;

	     end if;

	     initialise_table(row_count);
	     row_count    := 1     ;
	     errors_found := false ;

	     total_keys   := total_keys + 1 ;

          end if;


	  error_text := check_no_time ( l_current_row ) ;
	  error_text := error_text || check_start_before_end ( l_current_row ) ;
	  error_text := error_text || check_for_gaps( l_current_row , l_last_row ) ;


	  errors_found := ( error_text is not null ) ;


	  l_last_row :=  copy_to_row ( l_cursor  , l_thetable ) ;

       else

	  exit ;

       end if;

       save_to_table(row_count,l_current_row,error_text) ;
       row_count  := row_count + 1 ;

       total_rows := total_rows + 1 ;


    end loop ;


    dbms_sql.close_cursor(l_cursor ) ;

    if ( errors_found )  then

       output_table(l_thetable.has_who_cols) ;

    end if;

    -- If there were rows then the total number of ids is off by one because
    -- we only count the changes

    if ( total_rows <> 0 ) then

       total_keys := total_keys + 1 ;

    end if;


    output_line ( '    Total Number of Records Checked: '||to_char(total_rows)||' Distinct Key Values: '||to_char(total_keys));
    output_newline ;


  exception
  when others then

     hr_utility.trace('!!END TRACE');
     raise ;

  end check_table ;

  -- Name
  --  check_all_tables
  -- Purpose
  --  Checks All Datetracked tables for basic date rules
  --
  procedure check_all_tables is
  begin

      initialize_output ;

      check_table('BEN_BENEFICIARIES_F');
      check_table('BEN_BENEFIT_CONTRIBUTIONS_F');
      check_table('BEN_COVERED_DEPENDENTS_F');
      check_table('FF_COMPILED_INFO_F');
      --check_table('FF_FDI_USAGES_F');                  4 cols in pk
      check_table('FF_FORMULAS_F');
      check_table('FF_GLOBALS_F');
      check_table('PAY_ASSIGNMENT_LINK_USAGES_F');
      check_table('PAY_BALANCE_FEEDS_F');
      check_table('PAY_COST_ALLOCATIONS_F');
      check_table('PAY_ELEMENT_ENTRIES_F');
      check_table('PAY_ELEMENT_ENTRY_VALUES_F');
      check_table('PAY_ELEMENT_LINKS_F');
      check_table('PAY_ELEMENT_TYPES_F');
      check_table('PAY_EXCHANGE_RATES_F');
      check_table('PAY_FORMULA_RESULT_RULES_F');
      check_table('PAY_GRADE_RULES_F');
      check_table('PAY_INPUT_VALUES_F');
      check_table('PAY_LINK_INPUT_VALUES_F');
      check_table('PAY_ORG_PAYMENT_METHODS_F');
      check_table('PAY_ORG_PAY_METHOD_USAGES_F');
      check_table('PAY_ALL_PAYROLLS_F');
      check_table('PAY_PERSONAL_PAYMENT_METHODS_F');
      -- check_table('PAY_REPORT_FORMAT_MAPPINGS_F'); More than 3 cols in pk,no who
      check_table('PAY_STATUS_PROCESSING_RULES_F');
      check_table('PAY_SUB_CLASSIFICATION_RULES_F');
      check_table('PAY_USER_COLUMN_INSTANCES_F');
      check_table('PAY_USER_ROWS_F');
      check_table('PAY_US_EMP_FED_TAX_RULES_F');
      check_table('PAY_US_EMP_LOCAL_TAX_RULES_F');
      check_table('PAY_US_EMP_STATE_TAX_RULES_F');
      check_table('PAY_US_GARN_ARREARS_RULES_F');
      check_table('PAY_US_GARN_EXEMPTION_RULES_F');
      check_table('PAY_US_GARN_FEE_RULES_F');
      check_table('PAY_US_GARN_LIMIT_RULES_F');
      check_table('PER_ALL_ASSIGNMENTS_F');
      check_table('PER_COBRA_COVERAGE_BENEFITS_F');
      check_table('PER_COBRA_QFYING_EVENTS_F');
      check_table('PER_GRADE_SPINES_F');
      check_table('PER_ALL_PEOPLE_F');
      check_table('PER_SPINAL_POINT_PLACEMENTS_F');
      check_table('PER_SPINAL_POINT_STEPS_F');

end check_all_tables ;

end dt_checkint ;

/
