--------------------------------------------------------
--  DDL for Package Body FND_RESUB_PRIVATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_RESUB_PRIVATE" as
/* $Header: AFCPRSPB.pls 120.5.12010000.13 2019/07/09 18:10:28 pferguso ship $ */



  -- PRIVATE VARIABLES
  --

        P_nargs			number		:= null;
	P_ProgName		varchar2(30)    := null;
        P_ProgAppName		varchar2(30)    := null;
        P_ReqStartDate		date		:= null;
        P_reqid			number		:= null;
        P_delta			number		:= null;
        P_count			integer         := null;
        P_increment_flag	varchar2(1)     :='N';
        P_sch_type		varchar2(1)     := null;
	P_sch_app_id		number		:= null;
        P_sch_id                number          := null;
        P_sch_name		VARCHAR2(20)	:= null;
        P_errbuf		varchar2(240)	:= null;
        P_errnum		number		:= 0;
        P_inc_proc		varchar2(61)    := null;
        P_fsegs			fnd_dflex.segments_dr;
        P_rsub_int              number          := null;  -- Resubmit_Interval
        P_rsub_int_unit_code    varchar2(30)    := null;  -- Resubmit_Interval_Unit_Code
        P_IncrOpt               varchar2(1)     :='S'; -- profile: CONC_DATE_INCREMENT_OPTION
	P_recalc_flag           varchar2(1)     := 'N'; -- Recalculate default parameters
	P_resp_id               number;
	P_resp_app_id           number;
	P_delim                 varchar2(1)     := ':';
	P_request_type          varchar2(1)     := 'X';
        P_morg_cat              varchar2(1)     := null;
        P_org_id                number;


        TYPE t_arglist IS varray(100) OF VARCHAR2(240);
        p_args	t_arglist := t_arglist(CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0),
                                       CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0),
                                       CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0),
                                       CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0),
                                       CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0),
                                       CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0),
                                       CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0),
                                       CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0),
                                       CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0),
                                       CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0));


----------------------------------------------------------------------
---           PRIVATE PROCEDURES
----------------------------------------------------------------------

procedure RETURN_INFO(errcode in number, errbuf in varchar2) is

begin
  P_errbuf := errbuf;
  P_errnum := errcode;
end;

procedure set_resub_delta (old_req_start  IN  date) is

begin
  if (P_IncrOpt = 'S') then

     P_delta := P_ReqStartDate - old_req_start;

  else

     if (P_rsub_int_unit_code = 'MINUTES') then
        P_delta := P_rsub_int/1440;
     elsif (P_rsub_int_unit_code = 'HOURS') then
        P_delta := P_rsub_int/24;
     else -- P_rsub_int_unit_code = 'DAYS'
        P_delta := P_rsub_int;
     end if;

  end if;

end;



-- Check to see if a parameter had its default value recalculated
-- If the parameter has a default type that is not 'C'onstant, assume
-- that it was recalculated.
function param_was_defaulted(param_num in number) return boolean is
begin
   if P_recalc_flag <> 'Y' then
      return FALSE;
   end if;

   if P_fsegs.default_type(param_num) is not null and P_fsegs.default_type(param_num) <> 'C' then
     return TRUE;
   end if;

   return FALSE;

end;

-- Check to see if a the request is for a set or individual program
function request_is_set return boolean is
begin
   if P_request_type in ('M', 'B') then
      return TRUE;
   else
      return FALSE;
   end if;
end;

procedure execute_increment_proc is

   cur_dyn INTEGER;
   row_dyn INTEGER;

begin

   begin

   cur_dyn := dbms_sql.open_cursor;
   exception
        when others then
           P_errnum := -1;
	   P_errbuf := 'dbms_sql.open_cursor failed';
           return;
   end;

   begin
        /* choosing V7 as language flag as less likely to cause problems */
        dbms_sql.parse(cur_dyn, 'begin ' || P_inc_proc || '; end;',dbms_sql.V7);
   exception
        when others then
           P_errnum := -1;
	   P_errbuf := 'dbms_sql.parse failed';
           return;
   end;

   begin
        /* choosing V7 as language flag as less likely to cause problems */
        row_dyn := dbms_sql.execute(cur_dyn);
   exception
        when others then
           P_errnum := -1;
	   P_errbuf := 'dbms_sql.execute failed';
           return;
   end;

   begin
        /* choosing V7 as language flag as less likely to cause problems */
        dbms_sql.close_cursor(cur_dyn);
   exception
        when others then
           P_errnum := -1;
	   P_errbuf := 'dbms_sql.close_cursor failed';
           return;
   end;

end;




procedure recalc_parameters(set_app_id number, set_id number, set_prog_id number) is

  cc_valid        boolean;
  delimiter       varchar2(1) := P_delim;
  concat_params   varchar2(24000) := '';
  concat_ids_out  varchar2(24000);
  error_msg_out   varchar2(2000);
  p_flex_values   fnd_flex_server1.stringarray;
  flex_cnt        number;
  l_wc            VARCHAR2(10);
  i               pls_integer;
  l_escapedelim   VARCHAR2(10);
  FLEX_DELIMITER_ESCAPE CONSTANT VARCHAR2(1) := '\';
begin

   for i in 1 .. P_nargs loop
      p_flex_values(i) := p_args(i);
   end loop;


    -- Set multiorg context
   mo_global.init('M');
   if ( P_morg_cat = 'S' ) then
      mo_global.set_policy_context(P_morg_cat, P_org_id);
   elsif ( P_morg_cat = 'M' ) then
      mo_global.set_policy_context(P_morg_cat, null);
   end if;


/*-----------------------------------------------------------------------+
  Bug 27748205: The following code is added at the request of the
  flex team. The issue occurs when there is only one parameter for
  the program (ie: one flex segment for the dff)
  The value of the parameter value entered by user contains a colon,
  which also happens to be the CP delimiter for multiple parameters/
  dff flex segments.
  The first request submission goes fine. As explained by flex team,
  escape characters before the colon are stripped and segment value
  works for the parameter value.
  The issue occurs for recalc time. Flex code treats a dff with only
  one segment differently in that it parses the segment value and
  removes the escape character before the colon, since it is a single
  value.
  The recalc code requires the escape character, but it was removed
  during the processing for the first submission.The escape character
  must be re-added before the first resubmission but will remain there
  for any additional resubmits.

  Below fix is to only add the escape character under the following
  conditions:
  (a) if the program only has one parameter
  (b) if parameter/segment value contains the delimiter (:)
  (c) if the escape character is not already there preceding the delimiter
  Flex team has requested we add this change to our code because recalc
  of program parameters is the only scenario in which there is a problem.
  Adding the fix to their code risks that other types of dff's will be
  adversely affected
+-----------------------------------------------------------------------*/
   l_escapedelim := FLEX_DELIMITER_ESCAPE || delimiter;
   if (P_nargs = 1 and
       FLEX_DELIMITER_ESCAPE <> delimiter and
       instr(p_flex_values(1), l_escapedelim) = 0 and
       instr(p_flex_values(1), delimiter) > 0)
   then
      i := 1;
      --
      -- Escaping loop.
      --
      LOOP
         l_wc := Substr(p_flex_values(1), i, 1);
         i := i + 1;

         IF (l_wc IS NULL) THEN
            EXIT;
         ELSIF (l_wc = FLEX_DELIMITER_ESCAPE) THEN
            concat_params := concat_params || FLEX_DELIMITER_ESCAPE;
            concat_params := concat_params || FLEX_DELIMITER_ESCAPE;
         ELSIF (l_wc = delimiter) THEN
            concat_params := concat_params || FLEX_DELIMITER_ESCAPE;
            concat_params := concat_params || delimiter;
         ELSE
            concat_params := concat_params || l_wc;
         END IF;
      END LOOP;
   else
      fnd_flex_server.concatenate_flex_values(p_flex_values, P_nargs, delimiter, concat_params);
   end if;

   concat_params := concat_params || delimiter;

   cc_valid := FND_FLEX_DESCVAL.val_desc_and_redefault(
    APPL_SHORT_NAME => P_ProgAppName,
    DESC_FLEX_NAME  => '$SRS$.' || P_ProgName,
    CONCAT_SEGMENTS => concat_params,
    RESP_APPL_ID    => P_resp_app_id,
    RESP_ID         => P_resp_id,
    srs_reqst_appl_id => set_app_id,
    srs_reqst_id    => set_id,
    srs_reqst_pgm_id => set_prog_id,
    concat_ids      => concat_ids_out,
    error_msg       => error_msg_out);

   if (cc_valid = false) then
     return_info(-1, error_msg_out);
   else
     if(nvl(P_nargs, 0) = 1) then
        concat_ids_out := rtrim(concat_ids_out, P_delim);
     end if;
     fnd_flex_server.parse_flex_values(concat_ids_out, delimiter, P_nargs, p_flex_values, flex_cnt);
     for i in 1 .. P_nargs loop
	p_args(i) := p_flex_values(i);
     end loop;
     return_info(0, '');
  end if;

end;



procedure start_toy(req_id in number, new_req_start in varchar2) is

flexi fnd_dflex.dflex_dr;
fcontexts fnd_dflex.contexts_dr;
fcontext fnd_dflex.context_r;
prog_app_name varchar2(30);
prog_name varchar2(30);
old_req_start date;

begin

   /* init params */
   RETURN_INFO(0,NULL);
   P_reqid := req_id;
   P_ReqStartDate := fnd_conc_date.string_to_date(new_req_start);

   select NVL(resub_count, 1), REQUESTED_START_DATE, NUMBER_OF_ARGUMENTS,
   r.RESUBMIT_INTERVAL, r.RESUBMIT_INTERVAL_UNIT_CODE,
   ARGUMENT1, ARGUMENT2, ARGUMENT3, ARGUMENT4, ARGUMENT5,
   ARGUMENT6, ARGUMENT7, ARGUMENT8, ARGUMENT9, ARGUMENT10,
   ARGUMENT11, ARGUMENT12, ARGUMENT13, ARGUMENT14, ARGUMENT15,
   ARGUMENT16, ARGUMENT17, ARGUMENT18, ARGUMENT19, ARGUMENT20,
   ARGUMENT21, ARGUMENT22, ARGUMENT23, ARGUMENT24, ARGUMENT25,
   INCREMENT_DATES, RELEASE_CLASS_APP_ID, r.RELEASE_CLASS_ID,
   CONCURRENT_PROGRAM_NAME, APPLICATION_SHORT_NAME,
   RELEASE_CLASS_NAME, CLASS_TYPE, INCREMENT_PROC,
   RESPONSIBILITY_ID, RESPONSIBILITY_APPLICATION_ID,
   MULTI_ORG_CATEGORY, ORG_ID
   into P_count, old_req_start, P_nargs,
   P_rsub_int, P_rsub_int_unit_code,
   p_args(1), p_args(2), p_args(3), p_args(4), p_args(5), p_args(6), p_args(7),
   p_args(8), p_args(9), p_args(10), p_args(11), p_args(12), p_args(13), p_args(14),
   p_args(15), p_args(16), p_args(17), p_args(18), p_args(19), p_args(20),
   p_args(21), p_args(22), p_args(23), p_args(24), p_args(25),
   P_increment_flag, P_sch_app_id, P_sch_id,
   prog_name, prog_app_name,
   P_sch_name,P_sch_type,P_inc_proc,
   P_resp_id, P_resp_app_id,
   P_morg_cat, P_org_id
   from fnd_concurrent_requests r,
   fnd_concurrent_programs p,
   fnd_application a,
   fnd_conc_release_classes c
   where r.request_id = req_id
   and r.concurrent_program_id = p.concurrent_program_id
   and r.program_application_id = p.application_id
   and r.program_application_id = a.application_id
   and c.RELEASE_CLASS_ID = r.RELEASE_CLASS_ID
   and r.RELEASE_CLASS_APP_ID = c.APPLICATION_ID;

   if (P_nargs >25) then
     select
	 	 Argument26, Argument27, Argument28, Argument29, Argument30,
                 Argument31, Argument32, Argument33, Argument34, Argument35,
                 Argument36, Argument37, Argument38, Argument39, Argument40,
                 Argument41, Argument42, Argument43, Argument44, Argument45,
                 Argument46, Argument47, Argument48, Argument49, Argument50,
                 Argument51, Argument52, Argument53, Argument54, Argument55,
                 Argument56, Argument57, Argument58, Argument59, Argument60,
                 Argument61, Argument62, Argument63, Argument64, Argument65,
                 Argument66, Argument67, Argument68, Argument69, Argument70,
                 Argument71, Argument72, Argument73, Argument74, Argument75,
                 Argument76, Argument77, Argument78, Argument79, Argument80,
                 Argument81, Argument82, Argument83, Argument84, Argument85,
                 Argument86, Argument87, Argument88, Argument89, Argument90,
                 Argument91, Argument92, Argument93, Argument94, Argument95,
                 Argument96, Argument97, Argument98, Argument99, Argument100
     into       p_args(26), p_args(27), p_args(28), p_args(29), p_args(30),
		p_args(31), p_args(32), p_args(33), p_args(34), p_args(35),
		p_args(36), p_args(37), p_args(38), p_args(39), p_args(40),
		p_args(41), p_args(42), p_args(43), p_args(44), p_args(45),
		p_args(46), p_args(47), p_args(48), p_args(49), p_args(50),
		p_args(51), p_args(52), p_args(53), p_args(54), p_args(55),
		p_args(56), p_args(57), p_args(58), p_args(59), p_args(60),
		p_args(61), p_args(62), p_args(63), p_args(64), p_args(65),
		p_args(66), p_args(67), p_args(68), p_args(69), p_args(70),
		p_args(71), p_args(72), p_args(73), p_args(74), p_args(75),
		p_args(76), p_args(77), p_args(78), p_args(79), p_args(80),
		p_args(81), p_args(82), p_args(83), p_args(84), p_args(85),
		p_args(86), p_args(87), p_args(88), p_args(89), p_args(90),
		p_args(91), p_args(92), p_args(93), p_args(94), p_args(95),
		p_args(96), p_args(97), p_args(98), p_args(99), p_args(100)
     from Fnd_Conc_Request_Arguments
     where Request_Id = req_id;

   end if;

   -- If the program has a custom increment proc, do not recalculate parameters
   if P_inc_proc is null then
      P_inc_proc := 'FND_RESUB_PRIVATE.DEFAULT_INCREMENT_PROC';
   else
      P_recalc_flag := 'N';
   end if;

   fnd_dflex.get_flexfield(prog_app_name, '$SRS$.' || prog_name,
	fcontext.flexfield, flexi);
   fnd_dflex.get_contexts(fcontext.flexfield, fcontexts);
   fcontext.context_code := fcontexts.context_code(fcontexts.global_context);
   fnd_dflex.get_segments(fcontext,P_fsegs, TRUE);

   P_ProgName := prog_name;
   P_ProgAppName := prog_app_name;

   P_delim := flexi.segment_delimeter;

   set_resub_delta (old_req_start);
end;

procedure stop_toy(new_req_id in number, errnum out nocopy number,
        errbuf out nocopy varchar2) is

   argtxt             varchar2(24200) := null;
   argtxt2            varchar2(240);

begin

     -- Recalc flag trumps increment flag
     if P_recalc_flag = 'Y' then
	recalc_parameters(null, null, null);

	errbuf := P_errbuf;
        errnum := P_errnum;

        /* uh-oh the recalculatron found a problem */
        if (P_errnum<0) then
	   return;
        end if;
     end if;



     if P_increment_flag = 'Y' then
	execute_increment_proc;

	errbuf := P_errbuf;
        errnum := P_errnum;

        /* uh-oh the incrementor found a problem */
        if (P_errnum<0) then
	   return;
        end if;

     end if;



     -- build argstr based on new arguments.
     -- know number of arguments did not change.
        argtxt := '';

        for i in 1 .. p_nargs loop
            if (i > 1) then
              argtxt := argtxt || ', ' || p_args(i);
            else
              argtxt := p_args(i);
            end if;
        end loop;

        argtxt2 := substrb (argtxt, 1, 240);

        UPDATE FND_CONCURRENT_REQUESTS
        SET Argument_Text = argtxt2,
        ARGUMENT1 = p_args(1), ARGUMENT2 = p_args(2), ARGUMENT3 = p_args(3), ARGUMENT4 = p_args(4),
        ARGUMENT5 = p_args(5), ARGUMENT6 = p_args(6), ARGUMENT7 = p_args(7), ARGUMENT8 = p_args(8),
        ARGUMENT9 = p_args(9), ARGUMENT10 = p_args(10), ARGUMENT11 = p_args(11),
        ARGUMENT12 = p_args(12), ARGUMENT13 = p_args(13), ARGUMENT14 = p_args(14),
        ARGUMENT15 = p_args(15), ARGUMENT16 = p_args(16), ARGUMENT17 = p_args(17),
        ARGUMENT18 = p_args(18), ARGUMENT19 = p_args(19), ARGUMENT20 = p_args(20),
        ARGUMENT21 = p_args(21), ARGUMENT22 = p_args(22),
        ARGUMENT23 = p_args(23), ARGUMENT24 = p_args(24), ARGUMENT25 = p_args(25)
        WHERE REQUEST_ID = new_req_id;

       if (P_nargs > 25) then
        Update Fnd_Conc_Request_Arguments
        Set Argument26 = p_args(26), Argument27 = p_args(27), Argument28 = p_args(28),
        Argument29 = p_args(29), Argument30 = p_args(30), Argument31 = p_args(31),
        Argument32 = p_args(32), Argument33 = p_args(33), Argument34 = p_args(34),
        Argument35 = p_args(35), Argument36 = p_args(36), Argument37 = p_args(37),
        Argument38 = p_args(38), Argument39 = p_args(39), Argument40 = p_args(40),
        Argument41 = p_args(41), Argument42 = p_args(42), Argument43 = p_args(43),
        Argument44 = p_args(44), Argument45 = p_args(45), Argument46 = p_args(46),
        Argument47 = p_args(47), Argument48 = p_args(48), Argument49 = p_args(49),
        Argument50 = p_args(50), Argument51 = p_args(51), Argument52 = p_args(52),
        Argument53 = p_args(53), Argument54 = p_args(54), Argument55 = p_args(55),
        Argument56 = p_args(56), Argument57 = p_args(57), Argument58 = p_args(58),
        Argument59 = p_args(59), Argument60 = p_args(60), Argument61 = p_args(61),
        Argument62 = p_args(62), Argument63 = p_args(63), Argument64 = p_args(64),
        Argument65 = p_args(65), Argument66 = p_args(66), Argument67 = p_args(67),
        Argument68 = p_args(68), Argument69 = p_args(69), Argument70 = p_args(70),
        Argument71 = p_args(71), Argument72 = p_args(72), Argument73 = p_args(73),
        Argument74 = p_args(74), Argument75 = p_args(75), Argument76 = p_args(76),
        Argument77 = p_args(77), Argument78 = p_args(78), Argument79 = p_args(79),
        Argument80 = p_args(80), Argument81 = p_args(81), Argument82 = p_args(82),
        Argument83 = p_args(83), Argument84 = p_args(84), Argument85 = p_args(85),
        Argument86 = p_args(86), Argument87 = p_args(87), Argument88 = p_args(88),
        Argument89 = p_args(89), Argument90 = p_args(90), Argument91 = p_args(91),
        Argument92 = p_args(92), Argument93 = p_args(93), Argument94 = p_args(94),
        Argument95 = p_args(95), Argument96 = p_args(96), Argument97 = p_args(97),
        Argument98 = p_args(98), Argument99 = p_args(99), Argument100 = p_args(100)
        where Request_Id=new_req_id;
       end if;
end;






procedure process_set(req_id in number, new_req_start in varchar2,
                      new_req_id in number, errnum out nocopy number, errbuf out nocopy varchar2) is

old_req_start      date;
flexi              fnd_dflex.dflex_dr;
fcontexts          fnd_dflex.contexts_dr;
fcontext           fnd_dflex.context_r;
v_app_id           number(15);
v_prog_id          number(15);
v_rsp_id           number(15);
v_set_app_id       number(15);
v_set_id           number(15);
v_print_style      varchar2(30);
v_save_flag        varchar2(1);
v_nls_lang         varchar2(30);
v_nls_terr         varchar2(30);
v_num_char         varchar2(2);
v_ops_instance     number;
v_nls_sort         varchar2(30);

cursor c_requests is
  select r.application_id, r.concurrent_program_id,
         r.request_set_program_id, r.set_application_id, r.request_set_id,
         r.print_style, r.save_output_flag, r.nls_language, r.nls_territory,
         r.numeric_characters, r.nls_sort, r.ops_instance,
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
         concurrent_program_name, application_short_name, increment_proc, multi_org_category, org_id
   from fnd_run_requests r,
   fnd_concurrent_programs p,
   fnd_application a
   where r.parent_request_id = req_id
   and r.concurrent_program_id = p.concurrent_program_id
   and r.application_id = p.application_id
   and r.application_id = a.application_id;


begin

   RETURN_INFO(0,NULL);
   P_reqid := req_id;
   P_ReqStartDate := fnd_conc_date.string_to_date(new_req_start);

   -- select information about the request set
   select NVL(resub_count, 1), REQUESTED_START_DATE,
          r.RESUBMIT_INTERVAL, r.RESUBMIT_INTERVAL_UNIT_CODE,
          INCREMENT_DATES, RELEASE_CLASS_APP_ID, r.RELEASE_CLASS_ID,
          RELEASE_CLASS_NAME, CLASS_TYPE,
          r.RESPONSIBILITY_ID, r.RESPONSIBILITY_APPLICATION_ID
   into P_count, old_req_start,
        P_rsub_int, P_rsub_int_unit_code,
        P_increment_flag, P_sch_app_id, P_sch_id,
        P_sch_name, P_sch_type, P_resp_id, P_resp_app_id
   from fnd_concurrent_requests r,
        fnd_conc_release_classes c
   where r.request_id = req_id
   and c.RELEASE_CLASS_ID = r.RELEASE_CLASS_ID
   and r.RELEASE_CLASS_APP_ID = c.APPLICATION_ID;

   set_resub_delta (old_req_start);


   -- loop over each request in the set
   open c_requests;
   loop
      fetch c_requests into
      v_app_id, v_prog_id, v_rsp_id, v_set_app_id, v_set_id,
      v_print_style, v_save_flag, v_nls_lang, v_nls_terr,
      v_num_char, v_nls_sort, v_ops_instance,
      p_args(1), p_args(2), p_args(3), p_args(4), p_args(5),
      p_args(6), p_args(7), p_args(8), p_args(9), p_args(10),
      p_args(11), p_args(12), p_args(13), p_args(14), p_args(15),
      p_args(16), p_args(17), p_args(18), p_args(19), p_args(20),
      p_args(21), p_args(22), p_args(23), p_args(24), p_args(25),
      p_args(26), p_args(27), p_args(28), p_args(29), p_args(30),
      p_args(31), p_args(32), p_args(33), p_args(34), p_args(35),
      p_args(36), p_args(37), p_args(38), p_args(39), p_args(40),
      p_args(41), p_args(42), p_args(43), p_args(44), p_args(45),
      p_args(46), p_args(47), p_args(48), p_args(49), p_args(50),
      p_args(51), p_args(52), p_args(53), p_args(54), p_args(55),
      p_args(56), p_args(57), p_args(58), p_args(59), p_args(60),
      p_args(61), p_args(62), p_args(63), p_args(64), p_args(65),
      p_args(66), p_args(67), p_args(68), p_args(69), p_args(70),
      p_args(71), p_args(72), p_args(73), p_args(74), p_args(75),
      p_args(76), p_args(77), p_args(78), p_args(79), p_args(80),
      p_args(81), p_args(82), p_args(83), p_args(84), p_args(85),
      p_args(86), p_args(87), p_args(88), p_args(89), p_args(90),
      p_args(91), p_args(92), p_args(93), p_args(94), p_args(95),
      p_args(96), p_args(97), p_args(98), p_args(99), p_args(100),
      P_Progname, P_ProgAppName, P_inc_proc, P_morg_cat, P_org_id;

      exit when c_requests%NOTFOUND;

      fnd_dflex.get_flexfield(P_ProgAppName, '$SRS$.' || P_progname, fcontext.flexfield, flexi);
      fnd_dflex.get_contexts(fcontext.flexfield, fcontexts);
      fcontext.context_code := fcontexts.context_code(fcontexts.global_context);
      fnd_dflex.get_segments(fcontext, P_fsegs, TRUE);

      P_nargs := P_fsegs.nsegments;
      P_delim := flexi.segment_delimeter;

      if P_inc_proc is null and P_recalc_flag = 'Y' then
	recalc_parameters(v_set_app_id, v_set_id, v_rsp_id);
	errbuf := P_errbuf;
        errnum := P_errnum;

        /* uh-oh the recalculatron found a problem */
        if (P_errnum<0) then
	   return;
        end if;
      end if;


      if P_increment_flag = 'Y' then

	  if P_inc_proc is null then
	    P_inc_proc := 'FND_RESUB_PRIVATE.DEFAULT_INCREMENT_PROC';
	  end if;

          execute_increment_proc;

          errbuf := P_errbuf;
          errnum := P_errnum;

          /* uh-oh the incrementor found a problem */
          if (P_errnum<0) then
	      return;
          end if;

      end if;

      -- insert the new row into fnd_run_requests
      insert into fnd_run_requests (application_id, concurrent_program_id,
	                              parent_request_id, request_set_program_id,
                                      set_application_id, request_set_id,
                                      print_style, save_output_flag,
                                      nls_language, nls_territory, numeric_characters,
                                      nls_sort, ops_instance,
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
                                      argument96, argument97, argument98, argument99, argument100, org_id)
	  VALUES(v_app_id, v_prog_id, new_req_id, v_rsp_id,
	  v_set_app_id, v_set_id,
	  v_print_style, v_save_flag, v_nls_lang, v_nls_terr,
          v_num_char, v_nls_sort, v_ops_instance,
	  p_args(1), p_args(2), p_args(3), p_args(4), p_args(5),
	  p_args(6), p_args(7), p_args(8), p_args(9), p_args(10),
	  p_args(11), p_args(12), p_args(13), p_args(14), p_args(15),
	  p_args(16), p_args(17), p_args(18), p_args(19), p_args(20),
	  p_args(21), p_args(22), p_args(23), p_args(24), p_args(25),
	  p_args(26), p_args(27), p_args(28), p_args(29), p_args(30),
	  p_args(31), p_args(32), p_args(33), p_args(34), p_args(35),
	  p_args(36), p_args(37), p_args(38), p_args(39), p_args(40),
	  p_args(41), p_args(42), p_args(43), p_args(44), p_args(45),
	  p_args(46), p_args(47), p_args(48), p_args(49), p_args(50),
	  p_args(51), p_args(52), p_args(53), p_args(54), p_args(55),
	  p_args(56), p_args(57), p_args(58), p_args(59), p_args(60),
	  p_args(61), p_args(62), p_args(63), p_args(64), p_args(65),
	  p_args(66), p_args(67), p_args(68), p_args(69), p_args(70),
	  p_args(71), p_args(72), p_args(73), p_args(74), p_args(75),
	  p_args(76), p_args(77), p_args(78), p_args(79), p_args(80),
	  p_args(81), p_args(82), p_args(83), p_args(84), p_args(85),
	  p_args(86), p_args(87), p_args(88), p_args(89), p_args(90),
	  p_args(91), p_args(92), p_args(93), p_args(94), p_args(95),
	  p_args(96), p_args(97), p_args(98), p_args(99), p_args(100),
          P_org_id);

       insert into fnd_run_req_pp_actions (
                request_set_program_id, request_set_id,
                set_application_id,
                parent_request_id,action_type,status_s_flag,
                status_w_flag,status_f_flag,
                program_application_id,program_id,arguments,
                number_of_copies,sequence,ops_instance,
                orig_system,orig_system_id,nls_language,
                argument1,argument2,argument3,argument4,argument5,
                argument6,argument7,argument8,argument9,argument10)
        select  request_set_program_id, request_set_id,
                set_application_id,
                new_req_id, action_type,status_s_flag,
                status_w_flag,status_f_flag,
                program_application_id,program_id,arguments,
                number_of_copies,sequence,ops_instance,
                orig_system,orig_system_id,nls_language,
                argument1,argument2,argument3,argument4,argument5,
                argument6,argument7,argument8,argument9,argument10
        from fnd_run_req_pp_actions
        where parent_request_id = req_id
	and request_set_program_id = v_rsp_id;

   end loop;

   close c_requests;

exception
   when others then
       return_info(-1, 'FND_RESUB_PRIVATE.PROCESS_SET EXCEPTION: ' || substr(sqlerrm, 1, 100));

end;


----------------------------------------------------------------------
---           PUBLIC PROCEDURES
----------------------------------------------------------------------

FUNCTION GET_PARAM_INFO(Param_num in number, Name out nocopy varchar2)  return number is
begin

  if (Param_num>P_fsegs.nsegments) then
    return (-1);
  end if;

  Name := P_fsegs.segment_name(Param_num);

  return(0);
end;

FUNCTION GET_PARAM_TYPE(Param_num in number, Param_type out nocopy varchar2) return number is

vset 		fnd_vset.valueset_r;
fmt 		fnd_vset.valueset_dr;

begin

  if (Param_num>P_fsegs.nsegments) then
    return (-1);
  end if;

  fnd_vset.get_valueset(P_fsegs.value_set(Param_num), vset, fmt);
  Param_type := fmt.format_type;

  return(0);


end;

FUNCTION GET_PARAM_NUMBER(name in varchar2, Param_num out nocopy number) return number is

counter number;

begin
  if (P_fsegs.nsegments < 1) then
     return (-1);
  end if;

  counter := 1;
  while ((counter < P_fsegs.nsegments) and
         (Name <> P_fsegs.segment_name(counter))) loop
              counter := counter + 1;
  end loop;

  IF (Name <> P_fsegs.segment_name(counter)) then
     return (-1);
  end if;

  Param_num := counter;

  return(0);

end;


FUNCTION GET_REQUESTED_START_DATE return date is
begin
return(P_ReqStartDate);
end;

FUNCTION GET_RUSUB_COUNT return number is
begin
return(P_count);
end;

PROCEDURE SET_PARAMETER(param_num in number, param_value in varchar2) is

begin
        if (param_num > P_nargs) then return; end if;
        p_args(param_num) := param_value;

end;

PROCEDURE GET_PROGRAM(PROG_NAME out nocopy VARCHAR2, PROG_APP_NAME out nocopy varchar2) is

begin
   PROG_NAME := P_ProgName;
   PROG_APP_NAME := P_ProgAppName;
end;

PROCEDURE GET_SCHEDULE(TYPE out nocopy VARCHAR2, APP_ID out nocopy number,
        ID out nocopy number, Name out nocopy varchar2) is

begin
   TYPE := P_sch_type;
   APP_ID := P_sch_app_id;
   ID := P_sch_ID;
   Name := P_sch_name;
end;

FUNCTION GET_INCREMENT_FLAG return varchar2 is

begin
  return(P_increment_flag);
end;



FUNCTION GET_RUSUB_DELTA return number is

begin
  return(P_delta);
end;

FUNCTION GET_PARAMETER(param_num in number) return varchar2 is

begin
	if (param_num > P_nargs) then return(NULL); end if;
        return p_args(param_num);

end;



procedure default_increment_proc is

param    varchar2(240);
retval   number;
ptype    varchar2(1);
date_fmt varchar2(32);
date_param date;
def_type varchar2(1);

begin

   if P_increment_flag <> 'Y' then
       return_info(0, '');
       return;
   end if;


   for i in 1 .. P_nargs loop

       param := get_parameter(i);
       if param is not null and param <> chr(0) then

           retval := get_param_type(i, ptype);
           if retval >= 0 then
	      if (ptype = 'X') or (ptype = 'Y')   or  (ptype = 'D') or (ptype = 'T') then
		 if not param_was_defaulted(i) then
                   date_fmt := fnd_conc_date.get_date_format(param);
                   date_param := fnd_conc_date.string_to_date(param);
                   if date_fmt is not null then
                       if (upper(nvl(P_rsub_int_unit_code,'UNDEF')) <> 'MONTHS') then
                            param := to_char((date_param + P_delta), date_fmt);

                       else
                            /* 2316601: P_delta only works for MONTHS if request date |
                             | month happens to have the same days as the param month */
                            param := to_char(ADD_MONTHS(date_param, P_rsub_int), date_fmt);
                       end if;
                       set_parameter(i, param);
		   end if;
		 end if;
               end if;
           end if;
       end if;

   end loop;

   return_info(0, '');

exception
   when others then
       return_info(-1, 'DEFAULT_INCREMENT_PROC EXCEPTION: ' || substr(sqlerrm, 1, 100));

end;



procedure process_increment(req_id in number, new_req_start in varchar2,
                 new_req_id in number, errnum out nocopy number, errbuf out nocopy varchar2) is

profile_buffer	varchar2(80) := null;

begin

   errnum := 0;

   select nvl(increment_dates, 'N'), nvl(request_type, 'X'),
          nvl(recalc_parameters, 'N')
   into   P_increment_flag, P_request_type, P_recalc_flag
   from   fnd_concurrent_requests
   where  request_id = req_id;


  if P_increment_flag <> 'Y' and P_recalc_flag <> 'Y' and not request_is_set() then
    errnum := 0;
	return;
  end if;

  /*-----------------------------------------------------------------------+
   3197639- New profile option to define how to increment date parameters:
      S-  Start Date Interval- by subtracting the requested_start_date
          of previous request from the requested_start_date of current request
      R-  Resubmit Interval- by adding the amount of time represented by the
          resubmit_interval and resubmit_unit_code defined for the request
          when originally scheduled
   +-----------------------------------------------------------------------*/

   FND_PROFILE.GET ('CONC_DATE_INCREMENT_OPTION', profile_buffer);
   if ( profile_buffer in ('S', 'R') ) then
      P_IncrOpt := profile_buffer;
   else
      P_IncrOpt := 'S';
   end if;

   -- sets need to always be processed
   if request_is_set() then
       process_set(req_id, new_req_start, new_req_id, errnum, errbuf);
   else
       start_toy(req_id, new_req_start);
       stop_toy (new_req_id, errnum, errbuf);

   end if;

   -- make sure we return a non-null value
   if errnum is null then
      errnum := 0;
   end if;

exception
   when others then
       errnum := -1;
       errbuf := 'FND_RESUB_PRIVATE.PROCESS_INCREMENT EXCEPTION: ' || substr(sqlerrm, 1, 100);
end;




end;

/
