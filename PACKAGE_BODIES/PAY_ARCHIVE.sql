--------------------------------------------------------
--  DDL for Package Body PAY_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ARCHIVE" as
/* $Header: pyarchiv.pkb 120.2.12010000.1 2008/07/27 22:03:29 appldev ship $ */
/*
 * ---------------------------------------------------------------------------
   Copyright (c) Oracle Corporation (UK) Ltd 1992.
   All Rights Reserved.
  --
  --
  PRODUCT
    Oracle*Payroll
  NAME
    pyarchiv.pkb
  NOTES
    generic archiving procedures.
  PROCEDURES
    --
  MODIFIED
    --
   ssinha   20-APR-1998  Created
   dzshanno 22-JUN-1998  Added handling for multiple jurisdictions
   dzshanno 08-JUL-1998  Added backward compatibility for report
   dzshanno 17-JUL-1998	 non_bal dbi with jurisdiction_code context now
                         supported without multiple jurisdictions
   nbristow 05-AUG-1998  Changes for running magtape only part.
   dzshanno 06-AUG-1998  Fixed typo in arch_db_items_loop
   nbristow 08-MAR-1999  Added remove_report_actions.
   nbristow 17-SEP-1999  Added archive_aa.
   mreid    01-OCT-1999  Added explicit column list to insert on
                         ff_archive_items
   nbristow 09-NOV-1999  Changes to the ff_archive_item table made for
                         the new Archive Item API.
   alogue   15-FEB-2000  Utf8 support : ff_database_items user_name and
                         ff_user_entities item_name lengthened to 240.
                         Use of varchar_240_tbl.
                         Remove insert of 'AAP' into
                         ff_archive_items.archive_type as column doesn't
                         exist in 11i.
   nbristow 19-MAY-2000  Added the deinitialize section.
   ssarma   03-AUG-2000  Added US specific code for EOY related issue.
                         It starts as -- if g_leg_code = US then ....
   nbristow 18-FEB-2001  Changed the process_employee so that the dynamic
                         procedure call can be done with out the
                         initialisation procedure.
   mreid    26-MAR-2002  Bug 2281868.  Added legislation_code to
                         csr_defined_balance cursor.
   nbristow 16-JUL-2002  Added standard_deinit.
   alogue   23-JUN-2003  Handle removal of lines from pay_population_ranges
                         in remove_report_actions.  Bug 3017447.
   nbristow 16-DEC-2003  Now delteting from pay_temp_object_actions.
   alogue   25-FEB-2004  Bulk operations within remove_report_actions
                         for performance purposes.
   nbristow 09-JUL-2004  Added process_chunk.
   mreid    11-NOV-2005  Bug 4729140: added date effective joins in
                         arch_db_items_loop
   alogue   31-AUG-2007  Bug 6196572: performance fix to
                         remove_report_actions.  Deletion of assignment
                         actions to inside this loop to avoid rollback
                         segment issue.
--
--
 * ---------------------------------------------------------------------
 */
--                               TYPES
--
-- The table types are just simple tables or various types. The records
-- are composite types of tables that contain a size (sz) to hold the
-- number of data items currently stored in the table. Data items are
-- stored in the tables within the records contiguously from 1 to sz.
--==================================================================
  TYPE varchar_1_tbl  IS TABLE OF VARCHAR(1)  INDEX BY binary_integer;
  TYPE boolean_tbl IS TABLE OF BOOLEAN INDEX BY binary_integer;
--
  TYPE archive_items IS RECORD
  (
    item_name           varchar_240_tbl,
    user_entity_id      number_tbl,
    data_type           varchar_1_tbl,
    jur_level           number_tbl,
    context_start       number_tbl,
    context_end	        number_tbl,
    sz                  INTEGER
  );
--
  TYPE balances IS RECORD
  (
    	item_name      	varchar_240_tbl,
    	user_entity_id 	number_tbl,
    	balance_id     	number_tbl,
	jur_level       number_tbl,
	context_start   number_tbl,
 	context_end     number_tbl,
    	sz             	integer
  );
--
TYPE contexts IS RECORD
(
  	name            varchar_60_tbl,
  	sz              integer
);
-- Table variables
------------------------------------------------------------------------
  l_balance_dbis               balances;
  l_contexts_dbi               contexts;
  l_assignment_dbis            archive_items;
------------------------------------------------------------------------
  l_jur_set                    varchar_60_tbl;
  l_jur1_set                   varchar_60_tbl;
  l_payroll_action_id          pay_payroll_actions.payroll_action_id%TYPE;
  l_business_group_id          pay_payroll_actions.business_group_id%TYPE;
  l_legislation_code           per_business_groups.legislation_code%TYPE;
  l_effective_date             pay_payroll_actions.effective_date%TYPE;
  l_date_earned                pay_payroll_actions.date_earned%TYPE;
  l_report_format              pay_report_format_mappings_f.report_format%TYPE;
  l_report_type                pay_report_format_mappings_f.report_type%TYPE;
  legislative_parameters       pay_payroll_actions.legislative_parameters%TYPE;
  non_unique_con               boolean := FALSE;
  process_archive              boolean := FALSE;
-----------------------------------------------------------------------
--                           PROCEDURES
  -----------------------------------------------------------------------------
  -- Name
  --   bal_db_item
  -- Purpose
  --   Given the name of a balance DB item as would be seen in a fast formula
  --   it returns the defined_balance_id of the balance it represents.
  -- Arguments
  -- Notes
  --   A defined +balance_id is required by the PLSQL balance function.
  -----------------------------------------------------------------------------
 --
 function bal_db_item
 (
  p_db_item_name varchar2
 ) return number is
   --
   -- Get the defined_balance_id for the specified balance DB item.
   --
   cursor csr_defined_balance is
     select to_number(UE.creator_id)
     from   ff_database_items         DI,
            ff_user_entities          UE
     where  DI.user_name            = p_db_item_name
       and  UE.user_entity_id       = DI.user_entity_id
       and  UE.creator_type         = 'B'
       and (UE.legislation_code     = l_legislation_code
        or  UE.business_group_id    = l_business_group_id);
   --
   l_defined_balance_id pay_defined_balances.defined_balance_id%type;
   --
 begin
   --
   hr_utility.set_location('pay_archive.bal_db_item - opening cursor', 1);
   open csr_defined_balance;
   fetch csr_defined_balance into l_defined_balance_id;
   if csr_defined_balance%notfound then
     close csr_defined_balance;
     raise hr_utility.hr_error;
   else
     hr_utility.set_location('pay_archive.bal_db_item - fetched from cursor', 2);
     close csr_defined_balance;
   end if;
   --
   return (l_defined_balance_id);
   --
 end bal_db_item;
--

 function get_jursd_level(p_route_id  number,p_user_entity_id number) return number is
 l_jursd_value   number:= 0;

 begin

 select frpv.value
 into l_jursd_value
 from ff_route_parameter_values frpv,
      ff_route_parameters frp
 where   frpv.route_parameter_id = frp.route_parameter_id
 and   frpv.user_entity_id = p_user_entity_id
 and   frp.route_id = p_route_id
 and   frp.parameter_name = 'Jursd. Level';

 return(l_jursd_value);

 exception
 when no_data_found then
  return(0);
 when others then
  hr_utility.trace('Error while getting the jursd. value ' ||
          to_char(sqlcode));

 end get_jursd_level;

--
-- PROCEDURE SET_DBI_LEVEL (GLOBAL)--------------------------------------------
--
-- used to set the jurisdiction level for non balance database items.
-- this allows these dbi to be archived to the correct level
-- p_dbi_name	    The name of the dbi you wish to set the jur_level for
-- p_jur_level	    The level to be set
------------------------------------------------------------------------
 procedure set_dbi_level (p_dbi_name in varchar2,
 				p_jur_level in varchar2) is

begin
hr_utility.set_location('set_dbi_level',1);
for i IN 1..l_assignment_dbis.sz LOOP
  if l_assignment_dbis.item_name(i) = p_dbi_name then
    l_assignment_dbis.jur_level(i) := p_jur_level;
    hr_utility.set_location('set_dbi_level',21);
    hr_utility.trace('Jurisdiction level for '||p_dbi_name||' set to '||p_jur_level);
    exit;
  end if;
end loop;
--
end set_dbi_level;
--
-- PROCDURE ARCH_DB_ITEMS_LOOP ----------------------------------------
--
-- Loop through db items and store them in plsql cache tables
-- db_items_csr     Database items cursor for a report format
-- contexts_csr     Contexts cursor for a live user entity id
-- user_entity_id   Current user entity id
-- route_id         Current Route id
-- a_user_entity_id archive user entity id
-- a_data_type      Archive data type
-- creator_type     Creator type == used to identify balance db item
-- name             Database item without prefix
-- flag             flag for which of the two plsql tables to store in
----------------------------------------------------------------------
  procedure arch_db_items_loop (p_effective_date DATE) IS
    CURSOR db_items_csr (p_report_format VARCHAR2) IS
      SELECT distinct us.item_name
        FROM pay_magnetic_blocks mb,
             pay_magnetic_records mr,
             ff_fdi_usages_f us
        WHERE mb.report_format     = p_report_format AND
              mb.magnetic_block_id = mr.magnetic_block_id AND
              mr.formula_id        = us.formula_id AND
              us.usage             = 'D' AND
              p_effective_date BETWEEN us.effective_start_date AND
                                       us.effective_end_date;
--
    CURSOR contexts_csr (p_user_entity_id VARCHAR2) IS
      SELECT con.context_name name
     FROM ff_user_entities ue,
             ff_route_context_usages rcu,
	ff_contexts con
        WHERE ue.user_entity_id = p_user_entity_id AND
              ue.route_id       = rcu.route_id AND
con.context_id = rcu.context_id ;
--
    db_items_row      db_items_csr%ROWTYPE;
    contexts_row      contexts_csr%ROWTYPE;
    user_entity_id    ff_database_items.user_entity_id%TYPE;
    route_id          ff_routes.route_id%TYPE;
    a_user_entity_id  ff_database_items.user_entity_id%TYPE;
    a_data_type       ff_database_items.data_type%TYPE;
    creator_type      ff_user_entities.creator_type%TYPE;
    name              VARCHAR2(240);
    flag              VARCHAR2(1);
--
    BEGIN
    hr_utility.set_location ('arch_db_items_loop',1);
--
--  Loop through database items
FOR db_items_row IN db_items_csr (l_report_format) LOOP
  --
  hr_utility.set_location ('arch_db_items_loop',11);
  --
  -- Ignore any database item found without a A_ prefix
  ----------------------------------------------------------------------
  IF substr(db_items_row.item_name,1,2) <> 'A_' THEN
    hr_utility.trace ('** Ignoring DB Item without A_ prefix: ' ||
                          db_items_row.item_name || ' **');
  ELSE
    hr_utility.set_location ('arch_db_items_loop',111);
    -- get original database item name to run.
    name := substr (db_items_row.item_name,3,
                    length(db_items_row.item_name)-2);
    hr_utility.trace ('** Found '|| db_items_row.item_name ||' **');
    hr_utility.set_location ('arch_db_items_loop',112);
    --
    -- Get archive entity id and data type
    SELECT dbi.user_entity_id, dbi.data_type
      INTO a_user_entity_id, a_data_type
      FROM ff_database_items dbi,
           ff_user_entities  ue
      WHERE dbi.user_name = db_items_row.item_name AND
            dbi.user_entity_id = ue.user_entity_id AND
            ((ue.legislation_code is null
               and ue.business_group_id is null
               and not exists
                      (select ''
                         from ff_user_entities  fue2,
                              ff_database_items fdi2
                        where fdi2.user_name = db_items_row.item_name
                        and   fdi2.user_entity_id = fue2.user_entity_id
                        and  (fue2.business_group_id = l_business_group_id
                           or fue2.legislation_code = l_legislation_code)
                       )
              )
              OR (ue.business_group_id is null
                   and l_legislation_code = ue.legislation_code
                   and not exists
                      (select ''
                         from ff_user_entities  fue2,
                              ff_database_items fdi2
                        where fdi2.user_name = db_items_row.item_name
                        and   fdi2.user_entity_id = fue2.user_entity_id
                        and  fue2.business_group_id = l_business_group_id
                       )
                   )
              OR ue.business_group_id + 0 = l_business_group_id
             );
        hr_utility.set_location ('arch_db_items_loop',1121);
    --------------------------------------------------------------------
    -- Get live entity id to get the contexts
    --
    SELECT dbi.user_entity_id,ue.creator_type,ue.route_id
      INTO user_entity_id,creator_type,route_id
      FROM ff_database_items dbi,
           ff_user_entities ue
      WHERE dbi.user_name = name AND
            dbi.user_entity_id = ue.user_entity_id
       and  ((ue.legislation_code is null
               and ue.business_group_id is null
               and not exists
                      (select ''
                         from ff_user_entities  fue2,
                              ff_database_items fdi2
                        where fdi2.user_name = name
                        and   fdi2.user_entity_id = fue2.user_entity_id
                        and  (fue2.business_group_id = l_business_group_id
                           or fue2.legislation_code = l_legislation_code)
                       )
              )
              or (ue.business_group_id is null
                   and l_legislation_code = ue.legislation_code
                   and not exists
                      (select ''
                         from ff_user_entities  fue2,
                              ff_database_items fdi2
                        where fdi2.user_name = name
                        and   fdi2.user_entity_id = fue2.user_entity_id
                        and  fue2.business_group_id = l_business_group_id
                       )
                   )
              or ue.business_group_id + 0 = l_business_group_id
             );
    --
    -- Check to see if db_item is balance or assignment,
    -- assume that it's an assignment.
    -----------------------------------------------------------------
    flag := 'A';
    IF creator_type = 'B' THEN
      flag := 'B';
    ELSE
      FOR contexts_row IN contexts_csr (user_entity_id) LOOP
        IF (contexts_row.name IN('ASSIGNMENT_ACTION_ID','ASSIGNMENT_ID')) THEN
          flag := 'A';
          EXIT;
        END IF;
      END LOOP;
    END IF;
    --
    hr_utility.set_location ('arch_db_items_loop',113);
    -----------------------------------------------------------------
    -- Store archive data in plsql tables
    -----------------------------------------------------------------
    IF flag = 'B' THEN
      hr_utility.set_location ('arch_db_items_loop',1131);
      --
      l_balance_dbis.sz := l_balance_dbis.sz + 1;
      l_balance_dbis.item_name(l_balance_dbis.sz) := name;
      l_balance_dbis.user_entity_id(l_balance_dbis.sz)
          := a_user_entity_id;
      l_balance_dbis.balance_id(l_balance_dbis.sz)
          := bal_db_item (l_balance_dbis.item_name(l_balance_dbis.sz));
      --
      -- New bit
      -- Find the jurisdiction level of the balance
      -----------------------------------------------------------
      SELECT  jurisdiction_level jur_lev
        INTO  l_balance_dbis.jur_level(l_balance_dbis.sz)
        FROM  pay_balance_types       pbt,
	        pay_defined_balances    pdb
        WHERE pbt.balance_type_id= pdb.balance_type_id AND
              pdb.defined_balance_id =
                l_balance_dbis.balance_id(l_balance_dbis.sz);
      --
      -----------------------------------------------------------
      -- store the name of contexts and how many in the PLSQL table
      --
      l_balance_dbis.context_start(l_balance_dbis.sz)
          :=l_contexts_dbi.sz+1;
      FOR contexts_row IN contexts_csr (user_entity_id) LOOP
        l_contexts_dbi.sz := l_contexts_dbi.sz +1;
        l_contexts_dbi.name(l_contexts_dbi.sz):=contexts_row.name;
        l_balance_dbis.context_end(l_balance_dbis.sz)
            := l_contexts_dbi.sz;
      end loop;
      --
    ELSIF flag = 'A' THEN
      hr_utility.set_location ('arch_db_items_loop',1132);
      --
      l_assignment_dbis.sz := l_assignment_dbis.sz + 1;
      l_assignment_dbis.item_name(l_assignment_dbis.sz) := name;
      l_assignment_dbis.user_entity_id(l_assignment_dbis.sz)
          := a_user_entity_id;
      l_assignment_dbis.data_type(l_assignment_dbis.sz)
          := a_data_type;
      -- New bit
      -- Find the jurisdiction level of the balance
      -----------------------------------------------------------
      l_assignment_dbis.jur_level(l_assignment_dbis.sz)
          := get_jursd_level(route_id,user_entity_id);
      --
      -- store the name of contexts and how many in the PLSQL table
      --
      l_assignment_dbis.context_start(l_assignment_dbis.sz)
          :=l_contexts_dbi.sz+1;
      FOR contexts_row IN contexts_csr (user_entity_id) LOOP
        l_contexts_dbi.sz := l_contexts_dbi.sz +1;
        l_contexts_dbi.name(l_contexts_dbi.sz):=contexts_row.name;
        l_assignment_dbis.context_end(l_assignment_dbis.sz)
             :=l_contexts_dbi.sz;
      end loop;
      --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location ('arch_db_items_loop',12);
  --
END LOOP; -- go back for next dbi
--
hr_utility.set_location ('arch_db_items_loop',2);
END arch_db_items_loop;
--
-----------------------------------------------------------------------
-- ARCH_INITIALISE
--
-- Initialise tables and reference variables.
-- Also instantiate plsql tables with database items.
--======================================================================
  PROCEDURE arch_initialise (p_payroll_action_id in NUMBER)
  IS
  BEGIN
    hr_utility.set_location ('arch_initialise',1);
-----------------------------------------------------------------------
-- Initialise table sizes
-----------------------------------------------------------------------
    l_balance_dbis.sz      	:= 0;
    l_assignment_dbis.sz   	:= 0;
    l_contexts_dbi.sz 	      := 0;
    g_context_values.sz	      := 0;
--
    hr_utility.set_location ('arch_initialise',2);
    l_payroll_action_id    :=  p_payroll_action_id;
-----------------------------------------------------------------------
    SELECT pa.business_group_id,
           bg.legislation_code,
           pa.effective_date,
           pa.date_earned,
           pa.legislative_parameters
      INTO l_business_group_id,
           l_legislation_code,
           l_effective_date,
           l_date_earned,
           legislative_parameters
      FROM pay_payroll_actions pa,
           per_business_groups bg
      WHERE pa.payroll_action_id = l_payroll_action_id AND
            pa.business_group_id = bg.business_group_id;
--
    g_leg_code := l_legislation_code;
    hr_utility.set_location ('arch_initialise',3);
---------------------------------------------------------------------
-- Get format for report type and state specified.
    SELECT prfm.report_format, pac.report_type
      INTO l_report_format, l_report_type
      FROM pay_report_format_mappings_f prfm,
           pay_payroll_actions          pac
      WHERE prfm.report_type      = pac.report_type
      AND   prfm.report_qualifier = pac.report_qualifier
      AND   prfm.report_category  = pac.report_category
      AND   pac.payroll_action_id = l_payroll_action_id
      AND   pac.effective_date BETWEEN effective_start_date AND
                                     effective_end_date;
    hr_utility.set_location ('arch_initialise',5);

-- Create dynsql to invoke legislative hook
   declare
      sql_cur    number;
      ignore     number;
      init_proc  pay_report_format_mappings.initialization_code%TYPE;
      statem     varchar2(256);
      pactid     number;
   begin
       pactid := l_payroll_action_id;
       select prfm.initialization_code
         into init_proc
         from pay_report_format_mappings_f prfm,
              pay_payroll_actions          ppa
        where ppa.payroll_action_id = pactid
          and ppa.report_type       = prfm.report_type
          and ppa.report_category   = prfm.report_category
          and ppa.effective_date between prfm.effective_start_date
                                     and prfm.effective_end_date
          and ppa.report_qualifier  = prfm.report_qualifier;
 --
        /* if the initialisation code is not set
           then we need to record that.
           This means that no archiving will take
           place
        */
        if(init_proc is null) then
             process_archive := FALSE;
/*
            hr_utility.set_message(801,
                   'PAY_34956_ARCINIT_MUST_EXIST');
            hr_utility.raise_error;
*/
        else
          process_archive := TRUE;
        end if;
--
        /* Only process the archiver if process_archive is set */
        if (process_archive = TRUE) then
--
          statem := 'BEGIN '||init_proc||'(:pactid); END;';
--
          hr_utility.set_location ('arch_initialise',6);
          hr_utility.trace(statem);

          sql_cur := dbms_sql.open_cursor;
          dbms_sql.parse(sql_cur,
                       statem,
                       dbms_sql.v7);
--
          dbms_sql.bind_variable(sql_cur, ':pactid', pactid);
          ignore := dbms_sql.execute(sql_cur);
          dbms_sql.close_cursor(sql_cur);
--
          hr_utility.set_location('arch_initialise', 7);
--
        end if;
--
     exception
        when others then
           if (dbms_sql.is_open(sql_cur)) then
             dbms_sql.close_cursor(sql_cur);
           end if;
           raise;
     end;
   -- Call procedure to retrieve all database items
   -- from the magtape formula for formatting magnetic
   -- blocks and headers.
 -- This will also instantiate all plsql tables with db items.
--
   if (process_archive = TRUE) then
     hr_utility.set_location('arch_initialise', 8);
     arch_db_items_loop(l_effective_date);
   end if;
--
  end arch_initialise;
--
-----------------------------------------------------------------------
-- DEINITIALISE
--
-- This basically just calls the deinitialise code specified for this
-- report type.
--
--======================================================================
  PROCEDURE deinitialise (p_payroll_action_id in NUMBER)
  IS
  BEGIN
    hr_utility.set_location ('deinitialise',1);
--
    l_payroll_action_id    :=  p_payroll_action_id;
--
    hr_utility.set_location ('deinitialise',3);
---------------------------------------------------------------------
-- Create dynsql to invoke legislative hook
   declare
      sql_cur    number;
      ignore     number;
      deinit_proc  varchar2(60);
      statem     varchar2(256);
      pactid     number;
   begin
       pactid := l_payroll_action_id;
       select prfm.deinitialization_code
         into deinit_proc
         from pay_report_format_mappings_f prfm,
              pay_payroll_actions          ppa
        where ppa.payroll_action_id = pactid
          and ppa.report_type       = prfm.report_type
          and ppa.report_category   = prfm.report_category
          and ppa.effective_date between prfm.effective_start_date
                                     and prfm.effective_end_date
          and ppa.report_qualifier  = prfm.report_qualifier;
--
        if(deinit_proc is not null) then
--
          statem := 'BEGIN '||deinit_proc||'(:pactid); END;';
--
          hr_utility.set_location ('deinitialise',6);
          hr_utility.trace(statem);

          sql_cur := dbms_sql.open_cursor;
          dbms_sql.parse(sql_cur,
                       statem,
                       dbms_sql.v7);
--
          dbms_sql.bind_variable(sql_cur, ':pactid', pactid);
          ignore := dbms_sql.execute(sql_cur);
          dbms_sql.close_cursor(sql_cur);
--
          hr_utility.set_location('deinitialise', 7);
--
        end if;
--
     exception
        when others then
           if (dbms_sql.is_open(sql_cur)) then
             dbms_sql.close_cursor(sql_cur);
           end if;
           raise;
     end;
--
  end deinitialise;
--------------------------------------------------------------------
-- procedure ARCH_STORE
--
-- Store the data to the archive tables
--
PROCEDURE arch_store (p_item_name      in varchar2,
              p_user_entity_id in ff_archive_items.user_entity_id%TYPE,
              p_context1       in ff_archive_items.context1%TYPE,
              p_value          in ff_archive_items.value%TYPE
  	) IS
begin
  hr_utility.set_location ('arch_store',121);
--
  INSERT INTO ff_archive_items
   ( ARCHIVE_ITEM_ID, USER_ENTITY_ID, CONTEXT1, VALUE)
  VALUES
   ( ff_archive_items_s.nextval,p_user_entity_id,p_context1,p_value);
--
  hr_utility.set_location ('arch_store',122);
END arch_store;
------------------------------------------------------------------------
--
-- PROCEDURE ARCHIVE_DBI
-- single contexts
--
------------------------------------------------------------------------
procedure archive_dbi (	p_balance_ptr 	number,
                       	p_context_ptr 	number,
                        p_assactid 		number) is
--
  context_val_loop 	number;
  balance_ptr 		number;
  context_ptr 		number;
  l_level 			number;
  v_context_value 	ff_archive_item_contexts.context%TYPE;
  v_context_id 		ff_contexts.context_id%TYPE;
  result          	ff_archive_items.value%TYPE;
  begin
--
hr_utility.set_location ('archive_dbi',1);
--
  balance_ptr:=p_balance_ptr;
  context_ptr:=p_context_ptr;
--
hr_utility.set_location ('archive_dbi',2);
--
-- for the context specified (Jur Code, Tax Unit etc) go get all the
-- different values.
FOR context_val_loop IN 1..NVL(g_context_values.sz,0) LOOP
  hr_utility.set_location ('archive_dbi',3);
  --
  if g_context_values.name(context_val_loop) = l_contexts_dbi.name(context_ptr) then
    --
    hr_utility.set_location ('archive_dbi',41);
    --
      non_unique_con := FALSE;
    if g_context_values.name(context_val_loop) = 'JURISDICTION_CODE'
        and l_jur_set.last is not null then
      --
      hr_utility.set_location ('archive_dbi',5);
      --
     non_unique_con := FALSE;
      l_level :=NVL(l_balance_dbis.jur_level(balance_ptr),0);
      --
      FOR i IN 1..l_jur_set.last LOOP
        --
        if substr(l_jur_set(i),1,l_level) =
          substr(g_context_values.value(context_val_loop) ,1,l_level)
        then
          non_unique_con := TRUE;
        end if;
      end loop;
    end if;
    --
      if non_unique_con = FALSE then
    if g_context_values.name(context_val_loop) ='JURISDICTION_CODE' then
       l_level :=NVL(l_balance_dbis.jur_level(balance_ptr),0);

  /* Specific to US Legislation */
       if g_leg_code = 'US' then
        if l_level = 2 and length(rtrim(g_context_values.value(context_val_loop))) <> 11 then
           non_unique_con :=TRUE;
        end if;

        if l_level = 6 and substr(g_context_values.value(context_val_loop),4,3) = '000' then
           non_unique_con :=TRUE;
        end if;

        if l_level = 6 and length(rtrim(g_context_values.value(context_val_loop))) <> 11 then
           non_unique_con :=TRUE;
        end if;

        if l_level =11 and substr(g_context_values.value(context_val_loop),8,4) = '0000' then
           non_unique_con :=TRUE;
        end if;

        if l_level =11 and length(rtrim(g_context_values.value(context_val_loop))) <> 11 then
           non_unique_con :=TRUE;
        end if;

        if l_level > 0 and substr(g_context_values.value(context_val_loop),1,2) = '99' then
           non_unique_con :=TRUE;
        end if;

        if l_level = 8 and length(rtrim(g_context_values.value(context_val_loop))) <> 8 then
           non_unique_con :=TRUE;
        end if;
      end if;

     /*
       non_unique_con := pay_archive_chk.jd_code(p_jurisdiction_code =>
                                                      g_context_values.value(context_val_loop),
                                                 p_jurisdiction_level => l_level);

     */
    end if; -- Context Jurisdiction
  end if; -- Non-Unique False

    if g_context_values.name(context_val_loop) ='JURISDICTION_CODE'
        and non_unique_con = TRUE then
      --
      hr_utility.set_location ('archive_dbi',61);
      null;
    else
      hr_utility.set_location ('archive_dbi',62);
      --
      -- OK, the context names match, Set the context.
      --
      Pay_balance_pkg.set_context 	(
            g_context_values.name(context_val_loop),
            g_context_values.value(context_val_loop)
            );
      hr_utility.set_location ('archive_dbi',63);
      hr_utility.trace(
        'Set '||l_contexts_dbi.name(context_ptr)|| ' to '
        ||g_context_values.value(context_val_loop)
        );
      --
      -- Are all the contexts set for this DBI set?
      --
      if l_balance_dbis.context_end(balance_ptr) = context_ptr then
        --
        -- Yes, All contexts are set go get it
        hr_utility.set_location ('archive_dbi',71);
        -- run user exit to get balance value for
        -- assignment action
        result := pay_balance_pkg.get_value(
                    l_balance_dbis.balance_id(balance_ptr),
                    balance_aa
                    );
        --
        hr_utility.trace ('** Balance Loop ** '||
            l_balance_dbis.item_name(balance_ptr) ||
            ' = ' || result);
        --
        -- Archive balance item
        arch_store ('A_' || l_balance_dbis.item_name(balance_ptr),
                    l_balance_dbis.user_entity_id(balance_ptr),
                    p_assactid,
                    result
                    );
        --
        hr_utility.set_location ('archive_dbi',72);
        --
        --loop through the contexts for this dbi
        --
        for i in l_balance_dbis.context_start(balance_ptr)..
            l_balance_dbis.context_end(balance_ptr) LOOP
          --
          hr_utility.set_location ('archive_dbi',81);
          if l_contexts_dbi.name(i) = 'ASSIGNMENT_ACTION_ID' then
            hr_utility.set_location ('archive_dbi',91);
            null; -- dont store ass_action_id in context table
          else
            hr_utility.set_location ('archive_dbi',92);
            v_context_value
              := pay_balance_pkg.get_context(l_contexts_dbi.name(i));
            --
            select context_id into v_context_id
              from ff_contexts
              where context_name= l_contexts_dbi.name(i);
            --
            --
            insert into ff_archive_item_contexts
            (archive_item_id,sequence_no,context,context_id)
            VALUES
             (ff_archive_items_s.currval,
              1,v_context_value,v_context_id);
            -- if were setting the jur code add to l_jur_set table
            if l_contexts_dbi.name(i) = 'JURISDICTION_CODE' then
              hr_utility.set_location ('archive_dbi',811);
              l_jur_set(NVL(l_jur_set.last+1,1)):= v_context_value;
            end if;
          end if;
          hr_utility.set_location ('archive_dbi',82);
        end loop;
        hr_utility.set_location ('archive_dbi',73);
      else
        hr_utility.set_location ('archive_dbi',64);
        --
        -- No, settup the next context required.
        --
        archive_dbi(balance_ptr, context_ptr + 1,p_assactid);
      end if;
        hr_utility.set_location ('archive_dbi',65);
    end if;
    hr_utility.set_location ('archive_dbi',42);
  end if;
  --
  hr_utility.set_location ('archive_dbi',32);
  --
end loop;
--
hr_utility.set_location ('archive_dbi',10);
--
-- If context_name is JURISDICTION_CODE then clear down the l_jur_set table in prep for
-- the next iteration
if l_contexts_dbi.name(context_ptr) = 'JURISDICTION_CODE' then
  l_jur_set.delete;
  non_unique_con := FALSE;
else
  null;
end if;
--
end archive_dbi;
--==================================================================
-- ARCHIVE_ASS
-- archive details and contexts for non balance dbi's
--
-- similar to archive_bal   but uses run_dbi not get_value
-- if jurisdiction_code is a required context for a non-balance
-- database item then its level should be set in the local code using
-- pay_archive.set_dbi_level
--==================================================================
procedure archive_ass (	p_ass_ptr number,
                       		p_context_ptr number,
p_assactid number) is
--
  context_val_loop 	number;
  ass_ptr 			number;
  context_ptr 		number;
  l_level 			number;
  v_context_value 	ff_archive_item_contexts.context%TYPE;
  v_context_id 		ff_contexts.context_id%TYPE;
  result         		ff_archive_items.value%TYPE;
--
begin
--
hr_utility.set_location ('archive_ass',1);
--
  ass_ptr:=p_ass_ptr;
  context_ptr:=p_context_ptr;
--
hr_utility.set_location ('archive_ass',2);
--
-- for the context specified (Tax Unit etc) go get all the
-- different values.
FOR context_val_loop IN 1..NVL(g_context_values.sz,0) LOOP
  hr_utility.set_location ('archive_ass',3);
  if g_context_values.name(context_val_loop)
      =l_contexts_dbi.name(context_ptr) then
    non_unique_con :=FALSE;
    hr_utility.set_location ('archive_ass',41);
    if g_context_values.name(context_val_loop) = 'JURISDICTION_CODE' and l_jur_set.last is not null then
      hr_utility.set_location('archive_dbi',5);
      non_unique_con := FALSE;
      l_level := NVL(l_assignment_dbis.jur_level(ass_ptr),0);
      FOR i IN 1..l_jur_set.last LOOP
        if substr(l_jur_set(i),1,l_level) = substr(g_context_values.value(context_val_loop),1,l_level) then
          non_unique_con := TRUE;
        end if;
      end loop;
    end if;
    --
      if non_unique_con = FALSE then
     if g_context_values.name(context_val_loop) ='JURISDICTION_CODE' then
        l_level := NVL(l_assignment_dbis.jur_level(ass_ptr),0);

     /* Specific to US Legislation */
       if g_leg_code = 'US' then
        if l_level = 2 and length(rtrim(g_context_values.value(context_val_loop))) <> 11 then
           non_unique_con :=TRUE;
        end if;

        if l_level = 6 and substr(g_context_values.value(context_val_loop),4,3) = '000' then
           non_unique_con :=TRUE;
        end if;

        if l_level = 6 and length(rtrim(g_context_values.value(context_val_loop))) <> 11 then
           non_unique_con :=TRUE;
        end if;

        if l_level =11 and substr(g_context_values.value(context_val_loop),8,4) = '0000' then
           non_unique_con :=TRUE;
        end if;

        if l_level =11 and length(rtrim(g_context_values.value(context_val_loop))) <> 11 then
           non_unique_con :=TRUE;
        end if;

        if l_level > 0 and substr(g_context_values.value(context_val_loop),1,2) = '99' then
           non_unique_con :=TRUE;
        end if;

        if l_level = 8 and length(rtrim(g_context_values.value(context_val_loop))) <> 8 then
           non_unique_con :=TRUE;
        end if;
       end if;


        /*
        non_unique_con := pay_archive_chk.jd_code(p_jurisdiction_code =>
                                                      g_context_values.value(context_val_loop),
                                                 p_jurisdiction_level => l_level);
        */

     end if; /* Context JD */
  end if;    /* non_unique_con = False */

    if g_context_values.name(context_val_loop) ='JURISDICTION_CODE' and non_unique_con=TRUE
    then
      hr_utility.set_location('archive_ass',61);
      null;
    else
      hr_utility.set_location ('archive_ass',62);
      --
      -- OK, the context names match, Set the context.
      --
      Pay_balance_pkg.set_context 	(
            g_context_values.name(context_val_loop),
            g_context_values.value(context_val_loop)
            );
      hr_utility.set_location ('archive_ass',63);
      --
      -- Are all the contexts set for this DBI set?
      --
      if l_assignment_dbis.context_end(ass_ptr) = context_ptr then
        --
        -- Yes, All contexts are set go get it
	  hr_utility.set_location ('archive_ass',71);
        -- run user exit to get balance value for assignment action
        result := pay_balance_pkg.run_db_item(
                           l_assignment_dbis.item_name(ass_ptr),
                           l_business_group_id,
                           l_legislation_code
                            );
        hr_utility.trace (
                  '** Assignment Loop ** '
                  || l_assignment_dbis.item_name(ass_ptr) ||
                  ' = ' || result
                  );
        --
  	  -- store data
        arch_store ('A_' || l_assignment_dbis.item_name(ass_ptr),
                    l_assignment_dbis.user_entity_id(ass_ptr),
                    p_assactid,
                    result );
        hr_utility.set_location ('archive_ass',72);
        --
        --loop through the contexts for this dbi
        --
        for i in l_assignment_dbis.context_start(ass_ptr)..
             l_assignment_dbis.context_end(ass_ptr) LOOP
          hr_utility.set_location ('archive_ass',81);
          if l_contexts_dbi.name(i)='ASSIGNMENT_ACTION_ID' then
            hr_utility.set_location ('archive_ass',91);
            null; -- dont store ass_action_id in context table
          else
            hr_utility.set_location ('archive_ass',92);
            --
            v_context_value:=
                pay_balance_pkg.get_context(l_contexts_dbi.name(i));
            --
            select context_id into v_context_id
	        from ff_contexts
	        where context_name=l_contexts_dbi.name(i);
            --
            --
            insert into ff_archive_item_contexts
              (archive_item_id,sequence_no,context,context_id)
            VALUES
              (ff_archive_items_s.currval,1,
               v_context_value,v_context_id);

            -- if were setting the jur code add to l_jur1_set table
               if l_contexts_dbi.name(i) = 'JURISDICTION_CODE' then
                  l_jur1_set(NVL(l_jur1_set.last+1,1)) := v_context_value;
               end if;
            --
          end if;
          hr_utility.set_location ('archive_ass',82);
        end loop;
        hr_utility.set_location ('archive_ass',73);
        --
      else
        hr_utility.set_location ('archive_ass',64);
        --
        -- No, settup the next context required.
        --
        archive_ass(ass_ptr, context_ptr + 1,p_assactid);
      end if;
      hr_utility.set_location ('archive_ass',65);
    end if;
    hr_utility.set_location ('archive_ass',42);
  end if;
  --
  hr_utility.set_location ('archive_ass',32);
  --
end loop;
--
hr_utility.set_location ('archive_ass',10);
--
--
-- If context_name is JURISDICTION_CODE then clear down the l_jur_set table in prep for
-- the next iteration
if l_contexts_dbi.name(context_ptr) = 'JURISDICTION_CODE' then
  l_jur_set.delete;
  non_unique_con := FALSE;
else
  null;
end if;
--
end archive_ass;
--
--=================================================================
-- PROCESS_CHUNK
--
-- Process each chunk for archiving and archive
-- This is called from the C calling program for each employee
-- within a loop
--==================================================================
  PROCEDURE process_chunk(p_payroll_action_id in number,
                          p_chunk_number in number) IS
  BEGIN
    hr_utility.set_location ('process_chunk',1);
--
--
      -- Call legislative hook to setup up employee contexts
      -- Create dynsql to invoke legislative hook
     declare
        sql_cur     number;
        ignore      number;
        archiv_proc varchar2(60);
        statem      varchar2(256);
        pactid      number;
     begin
         pactid := p_payroll_action_id;
         select prfm.archive_code
           into archiv_proc
           from pay_report_format_mappings_f prfm,
                pay_payroll_actions          ppa
          where ppa.payroll_action_id = pactid
            and ppa.report_type       = prfm.report_type
            and ppa.report_category   = prfm.report_category
            and ppa.effective_date between prfm.effective_start_date
                                       and prfm.effective_end_date
            and ppa.report_qualifier  = prfm.report_qualifier;
--
          --
          -- if the archive code does not exist don't do any archiving
          if(archiv_proc is null) then
              process_archive := FALSE;
          else
            begin
               statem := 'BEGIN '||archiv_proc||'(:pactid, :chunk_number); END;';
--
               hr_utility.trace(statem);
               hr_utility.set_location ('process_chunk',2);
               sql_cur := dbms_sql.open_cursor;
               dbms_sql.parse(sql_cur,
                            statem,
                            dbms_sql.v7);
               dbms_sql.bind_variable(sql_cur, ':pactid', p_payroll_action_id);
               dbms_sql.bind_variable(sql_cur, ':chunk_number',
                                       p_chunk_number);
               ignore := dbms_sql.execute(sql_cur);
               dbms_sql.close_cursor(sql_cur);
--
               hr_utility.set_location ('process_chunk',3);
--
            exception
             when others then
                if (dbms_sql.is_open(sql_cur)) then
                  dbms_sql.close_cursor(sql_cur);
                end if;
                raise;
            end;
          end if;
     end;
--
end process_chunk;
--
--=================================================================
-- PROCESS_EMPLOYEE
--
-- Process each employee for archiving and archive
-- every balance db item and every assignment db item
-- This is called from the C calling program for each employee
-- within a loop
--==================================================================
  PROCEDURE process_employee(p_assact_id in number) IS
    result          ff_archive_items.value%TYPE;
    aactid          pay_assignment_actions.assignment_action_id%TYPE;
    i               INTEGER;
    pactid          NUMBER;
    l_flag		BOOLEAN;
  BEGIN
    hr_utility.set_location ('process_employee',1);
--
--
      aactid := p_assact_id;
--
      -- clear down the plsql_tale holding the contexts
      g_context_values.sz :=0;
      g_context_values.name.delete;
      g_context_values.value.delete;
      -- Call legislative hook to setup up employee contexts
      -- Create dynsql to invoke legislative hook
     declare
        sql_cur     number;
        ignore      number;
        archiv_proc varchar2(60);
        statem      varchar2(256);
        pactid      number;
     begin
         pactid := l_payroll_action_id;
         select prfm.archive_code
           into archiv_proc
           from pay_report_format_mappings_f prfm,
                pay_payroll_actions          ppa
          where ppa.payroll_action_id = pactid
            and ppa.report_type       = prfm.report_type
            and ppa.report_category   = prfm.report_category
            and ppa.effective_date between prfm.effective_start_date
                                       and prfm.effective_end_date
            and ppa.report_qualifier  = prfm.report_qualifier;
--
          -- Set the assignment action id that the balances will be retrieved
          -- as of. This can be overriden by the legislative code
          --
          balance_aa := aactid;
          archive_aa := aactid;
          --
          -- if the archive code does not exist don't do any archiving
          if(archiv_proc is null) then
              process_archive := FALSE;
/*
              hr_utility.set_message(801, 'PAY_34957_ARCPROC_MUST_EXIST');
              hr_utility.raise_error;
*/
          else
--
            begin
               statem := 'BEGIN '||archiv_proc||'(:aactid, :l_effective_date); END;';
--
               hr_utility.trace(statem);
               hr_utility.set_location ('process_employee',2);
               sql_cur := dbms_sql.open_cursor;
               dbms_sql.parse(sql_cur,
                            statem,
                            dbms_sql.v7);
               dbms_sql.bind_variable(sql_cur, ':aactid', aactid);
               dbms_sql.bind_variable(sql_cur, ':l_effective_date',
                                       l_effective_date);
               ignore := dbms_sql.execute(sql_cur);
               dbms_sql.close_cursor(sql_cur);
--
               hr_utility.set_location ('process_employee',3);
--
            exception
             when others then
                if (dbms_sql.is_open(sql_cur)) then
                  dbms_sql.close_cursor(sql_cur);
                end if;
                raise;
            end;
          end if;
     end;
--
--------------------------------------------------------------------
-- Create entries in g_context_values table if needed
--------------------------------------------------------------------
--
  /* Only process the archiver if process_archive is
     set
  */
  if (process_archive = TRUE) then
    For i in 1..l_contexts_dbi.sz LOOP
      l_flag := FALSE;
      For j in 1..g_context_values.sz LOOP
        If g_context_values.name(j) = l_contexts_dbi.name(i) then
          l_flag := TRUE;
        end if;
        --
      end loop;
      --
      if l_flag = FALSE then
        g_context_values.sz := g_context_values.sz + 1;
        g_context_values.name(g_context_values.sz) :=
             l_contexts_dbi.name(i);
        g_context_values.value(g_context_values.sz) :=
             pay_balance_pkg.get_context(l_contexts_dbi.name(i));
      end if;
      --
    end loop;
--
---------------------------------------------------------------------
-- Balance Loop
---------------------------------------------------------------------
    FOR i IN 1..l_balance_dbis.sz LOOP
      hr_utility.set_location ('process_employee',4);
      --
      archive_dbi(i,l_balance_dbis.context_start(i),p_assact_id);
      --
      hr_utility.set_location ('process_employee',5);
      --
    END LOOP;
---------------------------------------------------------------------
-- Assignment Loop
---------------------------------------------------------------------
    FOR i IN 1..l_assignment_dbis.sz LOOP
      hr_utility.set_location ('process_employee',6);
      --
      archive_ass(i,l_assignment_dbis.context_start(i),p_assact_id);
      --
      hr_utility.set_location ('process_employee',7);
    END LOOP;
---------------------------------------------------------------------
    hr_utility.set_location ('process_employee',8);
---------------------------------------------------------------------
--
  end if;
--
end process_employee;
--
--
--=================================================================
-- remove_report_actions
--
-- This procedure deletes actions from the database, this
-- should only be used with report actions.
--==================================================================
procedure remove_report_actions(p_pact_id in number,
                                p_chunk_no in number default null)
is
--
type t_aa_list is table of pay_assignment_actions.assignment_action_id%type;
aalist t_aa_list;

type t_obj_list is table of pay_temp_object_actions.object_action_id%type;
objlist t_obj_list;

i number;
--
cursor asgcur (p_payroll_act in number)
is
select assignment_action_id
from   pay_assignment_actions
where  payroll_action_id = p_payroll_act;
--
cursor objcur (p_payroll_act in number)
is
select object_action_id
from   pay_temp_object_actions
where  payroll_action_id = p_payroll_act;
--
cursor asgrescur (p_payroll_act in number, p_chunk in number)
is
select assignment_action_id
from   pay_assignment_actions
where  payroll_action_id = p_payroll_act
and    chunk_number = p_chunk;
--
begin
--
  if (p_chunk_no is null) then
--
     open asgcur(p_pact_id);
     loop
        fetch asgcur bulk collect into aalist limit 1000;
--
        forall i in 1..aalist.count
           delete from pay_action_interlocks
            where locking_action_id = aalist(i);
--
        forall i in 1..aalist.count
           delete from PAY_MESSAGE_LINES
            where source_id = aalist(i)
              and source_type = 'A';
--
        forall i in 1..aalist.count
           delete from pay_assignment_actions
            where assignment_action_id = aalist(i);
--
        exit when asgcur%notfound;
     end loop;
     close asgcur;
--
     open objcur(p_pact_id);
     loop
        fetch objcur bulk collect into objlist limit 1000;
--
        forall i in 1..objlist.count
           delete from PAY_MESSAGE_LINES
            where source_id = objlist(i)
              and source_type = 'A';
--
        forall i in 1..objlist.count
           delete from pay_temp_object_actions
            where object_action_id = objlist(i);
--
        exit when objcur%notfound;
     end loop;
     close objcur;
--
     delete from PAY_MESSAGE_LINES
      where source_id = p_pact_id
        and source_type = 'P';
--
     delete from pay_population_ranges
      where payroll_action_id = p_pact_id;
--
     delete from pay_payroll_actions
      where payroll_action_id = p_pact_id;
  else
--
     open asgrescur(p_pact_id, p_chunk_no);
     loop
        fetch asgrescur bulk collect into aalist limit 1000;
--
        forall i in 1..aalist.count
           delete from pay_action_interlocks
            where locking_action_id = aalist(i);
--
        forall i in 1..aalist.count
           delete from PAY_MESSAGE_LINES
            where source_id = aalist(i)
              and source_type = 'A';
--
        exit when asgrescur%notfound;
     end loop;
     close asgrescur;
--
     delete from pay_assignment_actions
      where payroll_action_id = p_pact_id
        and chunk_number = p_chunk_no;
--
  end if;
--
end remove_report_actions;
--
  /* Name      : standard_deinit
     Purpose   : This procedure is the standard dinitialisation for some archiver
                 processes. It simply removes all the actions processed in this run
     Arguments :
     Notes     :
  */
  procedure standard_deinit (pactid in number)
  is
  remove_act varchar2(10);
  begin
--
      select pay_core_utils.get_parameter('REMOVE_ACT',
                                          pa1.legislative_parameters)
        into remove_act
        from pay_payroll_actions    pa1
       where pa1.payroll_action_id    = pactid;
--
      if (remove_act is null or remove_act = 'Y') then
         pay_archive.remove_report_actions(pactid);
      end if;
--
  end standard_deinit;
--
end pay_archive;

/
