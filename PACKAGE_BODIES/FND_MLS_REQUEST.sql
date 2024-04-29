--------------------------------------------------------
--  DDL for Package Body FND_MLS_REQUEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_MLS_REQUEST" as
/* $Header: AFMLSUBB.pls 120.8.12010000.11 2015/06/09 16:20:38 ckclark ship $ */



/*
** GEN_ERROR (Internal)
**
** Return error message for unexpected sql errors
*/
function GEN_ERROR(routine in varchar2,
	           errcode in number,
	           errmsg in varchar2) return varchar2 is
begin
    fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
    fnd_message.set_token('ROUTINE', routine);
    fnd_message.set_token('ERRNO', errcode);
    fnd_message.set_token('REASON', errmsg);
    return substr( fnd_message.get, 1, 240);
end;

/*
** FNDMLSUB
**
** MLS master program.
**
*/
procedure FNDMLSUB  (errbuf            out nocopy varchar2,
                     retcode           out nocopy number,
                     appl_id           in number,
                     prog_id           in number,
		     use_func          in varchar2 default 'N') is

cursor run_req_info(appl_id number, prog_id number, parent_id number) is
  select a.application_short_name,
         cp.concurrent_program_name,
         r.request_set_program_id,
         r.application_id,
         r.concurrent_program_id,
	  r.description,
         r.number_of_copies,
         r.printer,
         r.print_style,
         r.save_output_flag,
         argument1, argument2, argument3, argument4, argument5,
         argument6, argument7, argument8, argument9, argument10,
         argument11, argument12, argument13, argument14, argument15,
         argument16, argument17, argument18, argument19, argument20,
         argument21, argument22, argument23, argument24, argument25,
         argument26, argument27, argument28, argument29, argument30,
         argument31, argument32, argument33, argument34, argument35,
         argument36, argument37, argument38, argument39, argument40,
         argument41, argument42, argument43, argument44, argument45,
         argument46, argument47, argument48, argument49, argument50,
         argument51, argument52, argument53, argument54, argument55,
         argument56, argument57, argument58, argument59, argument60,
         argument61, argument62, argument63, argument64, argument65,
         argument66, argument67, argument68, argument69, argument70,
         argument71, argument72, argument73, argument74, argument75,
         argument76, argument77, argument78, argument79, argument80,
         argument81, argument82, argument83, argument84, argument85,

         argument86, argument87, argument88, argument89, argument90,
         argument91, argument92, argument93, argument94, argument95,
         argument96, argument97, argument98, argument99, argument100,
         r.org_id, r.recalc_parameters
    from fnd_run_requests r,
         fnd_concurrent_programs cp, fnd_application a
   where r.parent_request_id = parent_id
     and a.application_id = r.application_id
     and cp.application_id = r.application_id
     and cp.concurrent_program_id = r.concurrent_program_id
   order by r.request_set_program_id;

  cursor mls_requests( parent_req_id number ) is
     select nls_language, nls_territory, numeric_characters, nls_sort
       from fnd_run_req_languages
      where parent_request_id = parent_req_id;

  cursor mls_req_printers(parent_req_id number,
                             set_program_id number,
			     language varchar2) is
    select arguments printer, number_of_copies
      from fnd_run_req_pp_actions
     where parent_request_id = parent_req_id
       and request_set_program_id = set_program_id
       and action_type = 1
       and (nls_language = language
           or nls_language is null)
     order by sequence;

  cursor mls_req_notifications(parent_req_id number,
                                  set_program_id number,
				  language varchar2) is
    select arguments notify
      from fnd_run_req_pp_actions
     where parent_request_id = parent_req_id
       and request_set_program_id = set_program_id
       and action_type = 2
       and (nls_language = language
           or nls_language is null)
     order by sequence;

  cursor mls_req_layouts(parent_req_id number,
                             set_program_id number,
			     language varchar2) is
    select argument1, argument2, argument3, argument4, argument5
      from fnd_run_req_pp_actions
     where parent_request_id = parent_req_id
       and request_set_program_id = set_program_id
       and action_type = 6
       and (nls_language = language
           or nls_language is null)
     order by sequence;

  cursor mls_function_req_layouts(parent_req_id number,
                                 set_program_id number) is
    select argument1, argument2, argument5
      from fnd_run_req_pp_actions
     where parent_request_id = parent_req_id
       and request_set_program_id = set_program_id
       and action_type = 6
     order by sequence;


  cursor mls_req_delivery(parent_req_id number,
                                  set_program_id number,
				  language varchar2) is
    select argument1, argument2, argument3, argument4, argument5,
	   argument6, argument7, argument8, argument9, argument10
      from fnd_run_req_pp_actions
     where parent_request_id = parent_req_id
       and request_set_program_id = set_program_id
       and action_type in (7, 8)
       and (nls_language = language
           or nls_language is null)
     order by sequence;

  TYPE lang_record_type is record
	(lang_code     varchar2(4),
	 terr_code     varchar2(4),
	 nc_code       varchar2(2),
	 nls_language  varchar2(30),
	 nls_territory varchar2(30),
         numeric_characters varchar2(2),
         nls_sort varchar2(30));

  TYPE lang_tab_type is table of lang_record_type
	index by binary_integer;

  TYPE req_record_type is record
	( req_id       number(15));

  TYPE req_tab_type is table of req_record_type
	index by binary_integer;

  P_LANG lang_tab_type;
  P_REQ  req_tab_type;

  req_id            number;
  error             boolean         default FALSE;
  req_data          varchar2(240);  /* State of last FNDMLSUB run.     */
  has_reqs          boolean         default FALSE;
  funct             varchar2(61);  /* Function string */
  fcursor           varchar2(75);  /* Cursor string for dbms_sql */
  cid               number;        /* Cursor ID for dbms_sql */
  dummy             number;
  printer           varchar2(30);
  copies            number;
  parent_id         number;
  func_outcome      varchar2(240) := '';
  function_id       number;
  function_appl_id  number;
  nls_comp	    varchar2(1);
  P_LCOUNT	    number;
  endloc	    number;
  endloc1	    number;
  endloc2	    number;
  startloc          number;
  chkstrloc         number;
  i 		    number;
  current_outcome   varchar2(1);
  request_error     boolean := FALSE;
  request_warning   boolean := FALSE;
  outcome_meaning   varchar2(240);
  req_info_line     varchar2(100) := '';
  UserProgramName   varchar2(240);  /*  Concurrent Program associated with the request */
  /* xml project */
  t_app_name        varchar2(50);
  t_code            varchar2(80);
  t_language        varchar2(2);
  t_territory       varchar2(2);
  t_format          varchar2(6);

  parent_nls_lang   varchar2(30);
  parent_nls_terr   varchar2(30);
  parent_nls_char   varchar2(2);
  parent_nls_sort   varchar2(30);
  nls_char_spaces   varchar2(2);

  iso_lang          varchar2(2);
  iso_terr          varchar2(2);
  l_description     varchar2(240);

begin
  /* if use language function then get list of languages from that function
     and submit the requests for those languages */

  P_LCOUNT	:= 0;
  parent_id 	:= fnd_global.conc_request_id;

  /* Get state from last run if any. */
  req_data := fnd_conc_global.request_data;

  /* Is this the first run? */
  if (req_data is null) then
/*
 * CODE FOLDED : Begining
 */

  if ( use_func = 'Y') then
  /* Get  function for program if any.
   * Also, set up function globals.
   */
     begin
        select execution_file_name,
               p.mls_executable_id, p.mls_executable_app_id,
	       p.nls_compliant, P.User_Concurrent_Program_Name
          into funct,
               function_id, function_appl_id,
	       nls_comp, UserProgramName
          from fnd_concurrent_programs_vl p, fnd_executables e
         where p.application_id = appl_id
           and p.concurrent_program_id = prog_id
       	   and e.executable_id(+) = p.mls_executable_id
           and e.application_id(+) = p.mls_executable_app_id;

     exception
          when NO_DATA_FOUND then
             fnd_message.set_name('FND','CONC-Missing program');
      	     errbuf := substr(fnd_message.get,1, 240);
             retcode := 2;
          return;
     end;


     /* Initialize the request information to access by the language function
       */
     fnd_request_info.initialize;

     fnd_file.put_line(fnd_file.log,
	'+---------------------------------------------------------------------------+');
     fnd_message.set_name('FND', 'CONC-Before lang function');
     fnd_message.set_token('FUNCTION', funct);
     fnd_file.put_line(fnd_file.log, fnd_message.get || '  : ' ||
				     to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));

     fcursor := 'begin :r := '||funct||'; end;';
     begin
        cid := dbms_sql.open_cursor;
        dbms_sql.parse(cid, fcursor, dbms_sql.v7);
        dbms_sql.bind_variable(cid, ':r', func_outcome, 240);
        dummy := dbms_sql.execute(cid);
        dbms_sql.variable_value(cid, ':r', func_outcome);
        dbms_sql.close_cursor(cid);
     exception
        when others then
          errbuf := gen_error(funct, SQLCODE, SQLERRM);
          retcode := 2;
          return;
     end;

     fnd_message.set_name('FND', 'CONC-After lang function');
     fnd_message.set_token('VALUE', func_outcome );

     fnd_file.put_line(fnd_file.log, fnd_message.get || '  : ' ||
				     to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
     fnd_file.put_line(fnd_file.log,
	'+---------------------------------------------------------------------------+');

     /* Parse func_outcome to get nls_languages  */
     startloc := 1;
     endloc   := 1;
     P_LCOUNT   := 0;

     -- Fix for BUG 1207108
     -- Language function associated with [PROGRAM] determined no data exists
     -- for the given set of parameters

     if (func_outcome is null ) then
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       fnd_message.set_name('FND', 'CONC-MLS no data');
       fnd_message.set_token('PROGRAM', UserProgramName);
       errbuf := substr(fnd_message.get, 1, 240);
       retcode := 1;
       return;
     end if;

     -- 12.1  NEW MLS Function Str with optional territory and num char
     chkstrloc := instr( func_outcome, ':', 1 );

     if ( chkstrloc = 0 ) then
        -- Process for original MLS Functionality for lang code only
        if ( func_outcome is not null ) then
        loop
   	   endloc := instr( func_outcome, ',', startloc );
	   P_LCOUNT := P_LCOUNT + 1;
	   if ( endloc = 0 ) then
              P_LANG(P_LCOUNT).lang_code := LTRIM(RTRIM( substr( func_outcome, startloc,
							 length(func_outcome) -
							   startloc + 1
							)
						    )
						);
              P_LANG(P_LCOUNT).terr_code := null;
              P_LANG(P_LCOUNT).nc_code := null;
              exit;
	   else
	      P_LANG(P_LCOUNT).lang_code := LTRIM(RTRIM( substr( func_outcome, startloc,
							 endloc - startloc
							)
						    )
						);
              P_LANG(P_LCOUNT).terr_code := null;
              P_LANG(P_LCOUNT).nc_code := null;
	   end if;
           startloc := endloc + 1;
        end loop;
        end if;
     else

        -- Process for MLS Functionality for lang code with
        -- optional territory and numeric characters
        loop
   	   endloc := instr( func_outcome, ';', startloc );
	   P_LCOUNT := P_LCOUNT + 1;
	   if ( endloc = 0 ) then
              endloc1 := instr( func_outcome, ':', startloc );
              P_LANG(P_LCOUNT).lang_code :=
                    LTRIM(RTRIM( substr( func_outcome, startloc, endloc1 - startloc) ));

              endloc2 := instr( func_outcome, ':', endloc1 + 1 );
              P_LANG(P_LCOUNT).terr_code :=
                    LTRIM(RTRIM( substr( func_outcome, endloc1 + 1, endloc2 - (endloc1 + 1) )));

              P_LANG(P_LCOUNT).nc_code :=
                    LTRIM(RTRIM( substr( func_outcome, endloc2 + 1, length(func_outcome) - endloc2 + 1 )));
              exit;
	   else
              endloc1 := instr( func_outcome, ':', startloc );
              P_LANG(P_LCOUNT).lang_code :=
                    LTRIM(RTRIM( substr( func_outcome, startloc, endloc1 - startloc) ));

              endloc2 := instr( func_outcome, ':', endloc1 + 1 );
              P_LANG(P_LCOUNT).terr_code :=
                    LTRIM(RTRIM( substr( func_outcome, endloc1 + 1, endloc2 - (endloc1 + 1) )));

              P_LANG(P_LCOUNT).nc_code :=
                    LTRIM(RTRIM( substr( func_outcome, endloc2 + 1, endloc - (endloc2 + 1) )));
	   end if;
           startloc := endloc + 1;
        end loop;
     end if;

     /* select lang, terr, num char from parent req id */
     begin
        select nls_language, nls_territory, nls_numeric_characters, nls_sort
          into parent_nls_lang, parent_nls_terr, parent_nls_char,
parent_nls_sort
          from fnd_concurrent_requests
         where request_id =  parent_id;
        exception
           when NO_DATA_FOUND then
              fnd_message.set_name('FND','CONC-Missing Request');
              fnd_message.set_token('ROUTINE', 'FND_MLS_REQUEST.FNDMLSUB');
              fnd_message.set_token('REQUEST', to_char(parent_id));
              errbuf := fnd_message.get;
              retcode := 2;
           return;
     end;

     /* get nls_language and nls_territory for each language_code  */
     -- 12.1  NEW MLS Function Str with optional territory and num char
     -- Use the New Str if present otherwise keep as before
     for i in 1..P_LCOUNT loop
        /* if program is nls_compliant then use the default territory from
           fnd_languages, otherwise use user environment */
        if ( nls_comp  = 'Y' ) then
           if (chkstrloc = 0 ) then
 	      begin
		   select nls_language, nls_territory
		     into P_LANG(i).nls_language, P_LANG(i).nls_territory
		     from fnd_languages
		    where language_code = P_LANG(i).lang_code;
	      exception
		   when no_data_found then
                      fnd_message.set_name('FND', 'CONC-Invalid Language Code');
		      fnd_message.set_token('LANG', P_LANG(i).lang_code);
		      errbuf := substr(fnd_message.get, 1, 240);
		      retcode := 2;
		      return;
	      end;
           else
              if ( P_LANG(i).terr_code is NULL ) then
                 begin
                      select nls_language, nls_territory
                        into P_LANG(i).nls_language, P_LANG(i).nls_territory
                        from fnd_languages
                       where language_code = P_LANG(i).lang_code;
                 exception
                      when no_data_found then
                         fnd_message.set_name('FND', 'CONC-Invalid LangTerr Code');
                         fnd_message.set_token('LANG', P_LANG(i).lang_code);
		         fnd_message.set_token('TERR', P_LANG(i).terr_code);
                         errbuf := substr(fnd_message.get, 1, 240);
                         retcode := 2;
                         return;
                 end;
              else
 	         begin
		      select nls_language, b.nls_territory
		        into P_LANG(i).nls_language, P_LANG(i).nls_territory
		        from fnd_languages a, fnd_territories b
		       where language_code = P_LANG(i).lang_code
                         and territory_code = P_LANG(i).terr_code;
	         exception
		      when no_data_found then
                         fnd_message.set_name('FND', 'CONC-Invalid LangTerr Code');
		         fnd_message.set_token('LANG', P_LANG(i).lang_code);
		         fnd_message.set_token('TERR', P_LANG(i).terr_code);
		         errbuf := substr(fnd_message.get, 1, 240);
		         retcode := 2;
		         return;
	         end;
              end if;

           end if;
	else
	   /* use territory from the user environment which is parent_id's
	      nls_territory */
           -- 12.1  NEW MLS Function Str with optional territory and num char
           -- Use the New Str if present otherwise keep as before
           begin
		select nls_language
		  into P_LANG(i).nls_language
		  from fnd_languages
		 where language_code = P_LANG(i).lang_code;
	   exception
		when no_data_found then
                   fnd_message.set_name('FND', 'CONC-Invalid Language Code');
		   fnd_message.set_token('LANG', P_LANG(i).lang_code);
		   errbuf := substr(fnd_message.get, 1, 240);
		   retcode := 2;
		   return;
	   end;

           if ( chkstrloc = 0 ) then
              P_LANG(i).nls_territory := fnd_request_info.get_territory;
           else

              if ( P_LANG(i).terr_code is NULL ) then
                 P_LANG(i).nls_territory := fnd_request_info.get_territory;
              else
                 begin
                   select nls_territory
                     into P_LANG(i).nls_territory
                     from fnd_territories
                    where territory_code = P_LANG(i).terr_code;
                 exception
                      when no_data_found then
                         fnd_message.set_name('FND', 'CONC-Invalid Territory Code');
                         fnd_message.set_token('TERR', P_LANG(i).terr_code);
                         errbuf := substr(fnd_message.get, 1, 240);
                         retcode := 2;
                         return;
                 end;
              end if;
           end if;

	end if;

        -- 12.1  NEW MLS Function Str with optional territory and num char
        -- Use the New Str if present otherwise keep as before
        if ( chkstrloc = 0 ) then
           /* Determine Numeric Character value to use */
           if (parent_nls_lang = P_LANG(i).nls_language) then
              P_LANG(i).nls_territory := parent_nls_terr;
              P_LANG(i).numeric_characters := parent_nls_char;
           else
              P_LANG(i).numeric_characters := NULL;
           end if;
        else
           if ( P_LANG(i).nc_code is NULL ) then
              if (parent_nls_lang = P_LANG(i).nls_language) then
                 P_LANG(i).numeric_characters := parent_nls_char;
              else
                 P_LANG(i).numeric_characters := NULL;
              end if;
           else
              P_LANG(i).numeric_characters := P_LANG(i).nc_code;
           end if;
        end if;

        P_LANG(i).nls_sort := parent_nls_sort;

     end loop;

  else          /* not using the language function */
     for req in mls_requests(parent_id) loop
	P_LCOUNT := P_LCOUNT + 1;
	P_LANG(P_LCOUNT).nls_language := req.nls_language;
	P_LANG(P_LCOUNT).nls_territory := req.nls_territory;
        /* NLS Project - Set the numeric characters  */
        P_LANG(P_LCOUNT).numeric_characters := req.numeric_characters;
	P_LANG(P_LCOUNT).nls_sort := req.nls_sort;
     end loop;
  end if;      /* use_func    */


  -- 12.1  NEW MLS Function Str with optional territory and num char
  if ( chkstrloc = 0 ) then
     fnd_message.set_name('FND', 'CONC-About submitted requests');
  else
     fnd_message.set_name('FND', 'CONC-About submitted req full');
  end if;
  fnd_file.put_line(fnd_file.log, fnd_message.get);

  /* process all the requests   */
  begin
    /* using cursor for loop for easy coding. run_req_info will return
       only one row  */
    for req in run_req_info(appl_id, prog_id, parent_id) loop

      for ind in 1..P_LCOUNT loop

        /* set the language and territory and numeric characters for this request
           all individual requests are protected against updates */
        /* NLS Project - added numeric character */
        /* 4079398 - Check the numeric character for single character; if so,
                     Add a space for set options to pass the new Numeric Characters */
        if (length(P_LANG(ind).numeric_characters) = 1) then
           nls_char_spaces := substr(P_LANG(ind).numeric_characters,1,1)||' ';
        else
           nls_char_spaces := P_LANG(ind).numeric_characters;
        end if;

	if ( not fnd_request.set_options(
				implicit => 'NO',
				protected => 'YES',
				language  => P_LANG(ind).nls_language,
				territory => P_LANG(ind).nls_territory,
                                datagroup => '',
                                numeric_characters =>  nls_char_spaces,
				nls_sort  => P_LANG(ind).nls_sort )) then
	   errbuf  := substr(fnd_message.get, 1, 240);
	   retcode := 2;
	   rollback;
	   return;
	end if;

        /* set the print pp actions for this request  */
        open mls_req_printers(parent_id, 0, P_LANG(ind).nls_language);

        fetch mls_req_printers into printer, copies;

        if (mls_req_printers%found) then
          if (not fnd_request.set_print_options(
                              printer => printer,
                              style => req.print_style,
                              copies => copies,
                              save_output => (req.save_output_flag = 'Y'),
                              print_together => NULL))
          then
            errbuf := substr(fnd_message.get, 1, 240);
            retcode := 2;
            close mls_req_printers;
            rollback;
            return;
          end if;

          fetch mls_req_printers into printer, copies;
          while (mls_req_printers%found) loop
            if (not fnd_request.add_printer(
                              printer => printer,
                              copies => copies)) then
              errbuf := substr(fnd_message.get, 1, 240);
              retcode := 2;
              close mls_req_printers;
              rollback;
              return;
            end if;
            fetch mls_req_printers into printer, copies;
          end loop;
        else
          if (not fnd_request.set_print_options(
                              printer => null,
                              style => req.print_style,
                              copies => 0,
                              save_output => (req.save_output_flag = 'Y'),
                              print_together => NULL))
          then
            errbuf := substr(fnd_message.get, 1, 240);
            retcode := 2;
            close mls_req_printers;
            rollback;
            return;
          end if;
        end if;
        close mls_req_printers;

        /* set notification pp actions for this request */
        for notify_rec in mls_req_notifications
                            (parent_id, req.request_set_program_id,
				P_LANG(ind).nls_language) loop
          if (not fnd_request.add_notification(
                              user=>notify_rec.notify)) then
            errbuf := substr(fnd_message.get, 1, 240);
            retcode := 2;
            rollback;
            return;
          end if;
        end loop;

        /* Determine if an MLS Function is associated with this prog_id */
        /* If so, then use iso_language and iso_territory to add to     */
        /* layout for each language that is in the MLS Function.        */
        if (function_id is not NULL) then
           open mls_function_req_layouts(parent_id, 0);
           fetch mls_function_req_layouts into t_app_name,
                                               t_code,
                                               t_format;

           /* Change the language and terr */
           select iso_language, iso_territory
             into t_language, t_territory
             from fnd_languages
            where nls_language = P_LANG(ind).nls_language;

           -- 12.1  NEW MLS Function Str with optional territory and num char
           select territory_code
             into t_territory
             from fnd_territories
            where nls_territory = P_LANG(ind).nls_territory
              and obsolete_flag = 'N';

           t_language := lower(t_language);

           while (mls_function_req_layouts%found) loop
             if (not fnd_request.add_layout(
                                 t_app_name,
                                 t_code,
                                 t_language,
                                 t_territory,
                                 t_format)) then
               errbuf := substr(fnd_message.get, 1, 240);
               retcode := 2;
               close mls_function_req_layouts;
               rollback;
               return;
             end if;
             fetch mls_function_req_layouts into t_app_name,
                                                 t_code,
                                                 t_format;
           end loop;
           close mls_function_req_layouts;
        else
           /* set the layout pp actions for this request  */
           open mls_req_layouts(parent_id, 0, P_LANG(ind).nls_language);

           fetch mls_req_layouts into t_app_name,
                                      t_code,
                                      t_language,
                                      t_territory,
                                      t_format;

           while (mls_req_layouts%found) loop
             if (not fnd_request.add_layout(
                                 t_app_name,
                                 t_code,
                                 t_language,
                                 t_territory,
                                 t_format)) then
               errbuf := substr(fnd_message.get, 1, 240);
               retcode := 2;
               close mls_req_layouts;
               rollback;
               return;
             end if;
             fetch mls_req_layouts into t_app_name,
                                        t_code,
                                        t_language,
                                        t_territory,
                                        t_format;
           end loop;
           close mls_req_layouts;
        end if;


	/* set delivery pp actions for this request */
        for delivery_rec in mls_req_delivery
                            (parent_id, req.request_set_program_id,
				P_LANG(ind).nls_language) loop
          if (not fnd_request.add_delivery_option(
                                                  delivery_rec.argument1,
                                                  delivery_rec.argument2,
						  delivery_rec.argument3,
						  delivery_rec.argument4,
						  delivery_rec.argument5,
						  delivery_rec.argument6,
						  delivery_rec.argument7,
						  delivery_rec.argument8,
						  delivery_rec.argument9,
						  delivery_rec.argument10
						  )) then
            errbuf := substr(fnd_message.get, 1, 240);
            retcode := 2;
            rollback;
            return;
          end if;
        end loop;


        fnd_request.internal(critical => null, type=>'C');

        fnd_request.set_org_id(req.org_id);
        fnd_request.set_recalc_parameters_option(req.recalc_parameters);


        -- Prepend the ISO language and territory to the request description

        -- Get ISO language, default territory
	select ISO_LANGUAGE, ISO_TERRITORY
	  into iso_lang, iso_terr
          from fnd_languages
	where nls_language = P_LANG(ind).nls_language;

        -- If a territory was specified, use it
        -- else use the default for the language
        if P_LANG(ind).nls_territory is not null then
	    select territory_code
              into iso_terr
	      from fnd_territories
              where nls_territory = P_LANG(ind).nls_territory
	      and obsolete_flag = 'N';
	end if;

	if req.description is null then
	   l_description := iso_lang || '-' || iso_terr || ':';
	else
	   l_description := substr(iso_lang || '-' || iso_terr || ': ' || req.description, 1, 240);
        end if;


        req_id := fnd_request.submit_request(
                      req.application_short_name, req.concurrent_program_name,
                      l_description, NULL, TRUE,
                      req.argument1, req.argument2, req.argument3,
                      req.argument4, req.argument5, req.argument6,
                      req.argument7, req.argument8, req.argument9,
                      req.argument10, req.argument11, req.argument12,
                      req.argument13, req.argument14, req.argument15,
                      req.argument16, req.argument17, req.argument18,
                      req.argument19, req.argument20, req.argument21,
                      req.argument22, req.argument23, req.argument24,
                      req.argument25, req.argument26, req.argument27,
                      req.argument28, req.argument29, req.argument30,
                      req.argument31, req.argument32, req.argument33,
                      req.argument34, req.argument35, req.argument36,
                      req.argument37, req.argument38, req.argument39,
                      req.argument40, req.argument41, req.argument42,
                      req.argument43, req.argument44, req.argument45,
                      req.argument46, req.argument47, req.argument48,
                      req.argument49, req.argument50, req.argument51,
                      req.argument52, req.argument53, req.argument54,
                      req.argument55, req.argument56, req.argument57,
                      req.argument58, req.argument59, req.argument60,
                      req.argument61, req.argument62, req.argument63,
                      req.argument64, req.argument65, req.argument66,
                      req.argument67, req.argument68, req.argument69,
                      req.argument70, req.argument71, req.argument72,
                      req.argument73, req.argument74, req.argument75,
                      req.argument76, req.argument77, req.argument78,
                      req.argument79, req.argument80, req.argument81,
                      req.argument82, req.argument83, req.argument84,
                      req.argument85, req.argument86, req.argument87,
                      req.argument88, req.argument89, req.argument90,
                      req.argument91, req.argument92, req.argument93,
                      req.argument94, req.argument95, req.argument96,
                      req.argument97, req.argument98, req.argument99,
                      req.argument100);
        if (req_id = 0) then
          errbuf := substr(fnd_message.get, 1, 240);
          retcode := 2;
          return;
        end if;
        has_reqs := TRUE;

        /* prepare the req_data to be set after submission of all req's */
	if ( req_data is null ) then
	   req_data := to_char(req_id);
	else
           req_data := req_data || ',' || to_char(req_id);
	end if;

        -- 12.1  NEW MLS Function Str with optional territory and num char
        /* print the submitted request in log file  */
        if ( chkstrloc = 0 ) then
           req_info_line := '     ' || RPAD(to_char(req_id),15) || P_LANG(ind).nls_language;
        else
           req_info_line := '     ' || RPAD(to_char(req_id),15) || RPAD(P_LANG(ind).nls_language,31)||RPAD(P_LANG(ind).nls_territory,31)||P_LANG(ind).nc_code;
        end if;
	fnd_file.put_line(fnd_file.log, req_info_line);
      end loop;

    end loop;   /* run_req_info  */


    if ( has_reqs = FALSE ) then
       fnd_message.set_name('FND', 'CONC-MLS has no requests');
       errbuf := substr(fnd_message.get, 1, 240);
       retcode := 2;
    else
       fnd_conc_global.set_req_globals(
                        conc_status => 'PAUSED',
                        request_data => req_data);
    end if;

  end;

/*
 * CODE FOLDED: ENDS
 */

  else   /* program was restarted */

     P_LCOUNT := 0;
     startloc := 1;
     endloc   := 1;

     loop
	endloc := instr( req_data, ',', startloc );
	P_LCOUNT := P_LCOUNT + 1;
	if ( endloc = 0 ) then
	   P_REQ(P_LCOUNT).req_id := to_number( substr( req_data, startloc,
					                length(req_data) -
                                                        startloc + 1
							)
						);
           exit;
	else
	   P_REQ(P_LCOUNT).req_id := to_number( substr( req_data, startloc,
							endloc - startloc
							)
						);
	end if;
        startloc := endloc + 1;
     end loop;

     /* print the header for completed request status */
     fnd_message.set_name('FND', 'CONC-About completed requests');
     fnd_file.put_line(fnd_file.log, fnd_message.get);

     for ind in 1..P_LCOUNT loop
	begin
           select decode(status_code, 'C', 'S', 'G', 'W', 'E')
             into current_outcome
             from fnd_concurrent_requests
            where request_id = P_REQ(ind).req_id;

           if ( current_outcome = 'E' ) then
		request_error := TRUE;
	   elsif ( current_outcome = 'W' ) then
		request_warning := TRUE;
	   end if;

        exception
           when NO_DATA_FOUND then
              fnd_message.set_name('FND','CONC-Missing Request');
              fnd_message.set_token('ROUTINE', 'FND_MLS_REQUEST.FNDMLSUB');
              fnd_message.set_token('REQUEST', to_char(P_REQ(ind).req_id));
              errbuf := fnd_message.get;
              retcode := 2;
           return;
        end;

        select meaning
          into outcome_meaning
          from fnd_lookups
         where lookup_type = 'CP_SET_OUTCOME'
           and lookup_code = current_outcome;

       req_info_line := '     '||RPAD(to_char(P_REQ(ind).req_id),15) || outcome_meaning;
       fnd_file.put_line(fnd_file.log, req_info_line);

     end loop;

     if ( request_error ) then
	retcode := 2;
     elsif ( request_warning ) then
	retcode := 1;
     else
	retcode := 0;
     end if;

      /* Get final outcome meaning */
      select meaning
        into outcome_meaning
        from fnd_lookups
       where lookup_type = 'CP_SET_OUTCOME'
         and lookup_code = decode(retcode,2,'E',1,'W','S');

      fnd_message.set_name('FND', 'CONC-mls Completed');
      fnd_message.set_token('OUTCOME', outcome_meaning);
      errbuf := substr(fnd_message.get, 1, 240);

  end if;  /* req_data */

end FNDMLSUB;



function standard_languages return varchar2 is
   cursor langs_c is
      select language_code
        from fnd_languages
       where installed_flag in ('B','I')
             order by language_id;
   lang_str   varchar2(240);
   ret_val    varchar2(240);
begin
   lang_str := null;

   for langs in langs_c loop
	select concat ( lang_str, langs.language_code || ',')
	  into lang_str
          from dual;
   end loop;

   if ( length( lang_str) > 0) then
       ret_val := substr(lang_str, 1, length(lang_str) - 1);
   else
       ret_val := null;
   end if;

   return (ret_val);

end;


end FND_MLS_REQUEST;

/
