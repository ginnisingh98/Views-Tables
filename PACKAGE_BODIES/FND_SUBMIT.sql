--------------------------------------------------------
--  DDL for Package Body FND_SUBMIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SUBMIT" as
/* $Header: AFCPRSSB.pls 120.6.12010000.11 2015/04/23 03:55:20 jtoruno ship $ */

--
-- Package
--   FND_SUBMIT
--
-- Purpose
--   Concurrent processing related utilities
--

  --
  -- PRIVATE VARIABLES
  --
    P_OPS_ID            integer         := null;
    P_PRINT_STYLE       varchar2(30)    := null;
    P_SAVE_OUTPUT       char            := null;
    P_PRINT_TOGETHER    char            := null;
    P_LANGUAGE          varchar2(30)    := null;
    P_TERRITORY         varchar2(30)    := null;
    P_DATAGROUP         varchar2(30)    := null;
    P_DB_TRIGGER_MODE   boolean         := FALSE;
    P_CRITICAL_REQUEST  varchar2(1)     := null;
    P_REQUEST_TYPE      varchar2(1)     := NULL;
    P_SET_APP_ID        integer         := NULL;
    P_SET_ID            integer         := NULL;
    P_PHASE_CODE        varchar2(1)     := NULL;
    P_STATUS_CODE       varchar2(1)     := NULL;
    P_RS_REQUEST_ID     integer         := 0;
    P_TEMPLATE_APPL     varchar2(30)    := NULL;
    P_TEMPLATE_CODE     varchar2(80)    := NULL;
    P_TEMPLATE_LANG     varchar2(6)     := NULL;
    P_TEMPLATE_TERR     varchar2(6)     := NULL;
    P_OUTPUT_FORMAT     varchar2(30)    := NULL;
    P_ORG_ID		integer		:= null;
    P_NUMERIC_CHARACTERS varchar2(2)    := null;
    P_NLS_SORT           varchar2(30)   := null;


        TYPE printer_record_type is record
             (printer varchar2(30),
              copies  number);

        TYPE printer_tab_type is table of printer_record_type
             index by binary_integer;

	-- 12.1 Project Changes: Added orig_system and orig_system_id
	TYPE notification_record_type is record
 		(name 		varchar2(100),
 		orig_system 	varchar2(48),
 		orig_system_id 	number,
 		on_normal         varchar2(1),
 		on_warning        varchar2(1),
 		on_error          varchar2(1));

		   TYPE notification_tab_type is table of notification_record_type
       		index by binary_integer;

    -- bug 1679626 (ckclark): When there is more than one occurance
    -- of a specific program within the stage, need to check the
    -- RSP.sequence within the stage to avoid ORA-1422

        TYPE rs_program_record_type is record
             (stage   varchar2(30),
              program varchar2(30),
          seq     number(15),
              flag    boolean);

        TYPE rs_program_tab_type is table of rs_program_record_type
             index by binary_integer;

        TYPE delivery_record_type is record
                ( argument1          varchar2(255),
		  argument2          varchar2(255),
		  argument3          varchar2(255),
		  argument4          varchar2(255),
		  argument5          varchar2(255),
		  argument6          varchar2(255),
		  argument7          varchar2(255),
		  argument8          varchar2(255),
		  argument9          varchar2(255),
		  argument10         varchar2(255),
		  lang               varchar2(30));

        TYPE delivery_tab_type is table of delivery_record_type
		index by binary_integer;

        P_PRINTERS        printer_tab_type;
        P_PRINTER_COUNT     number := 0;
	   		P_NOTIFICATIONS     notification_tab_type;
        P_NOTIFICATION_COUNT     number := 0;
        P_SET_PROGRAMS         rs_program_tab_type;
        P_SET_PROGRAM_COUNT     number := 0;

        P_DELIVERY_OPTIONS  delivery_tab_type;
        P_DELIV_OPTS_COUNT  number := 0;

  -- Exception info.

  --
  -- PRIVATE FUNCTIONS
  --
  -- --

  -- Name
  --   init_pvt_vars
  -- Purpose
  --   Called after submitting request to re-initialize repeat options
  --
  -- --

  procedure init_pvt_vars( roll_back boolean default FALSE ) is
        empty_array        printer_tab_type;
        empty_notify_array notification_tab_type;
        empty_rs_array     rs_program_tab_type;
	empty_delivery     delivery_tab_type;

  begin
    -- if not db_trigger_mode and roll_back
        -- and the set_request_set program called then rollback to
    -- start_of_submission

    if(( not (P_DB_TRIGGER_MODE)) and roll_back and
        not ( P_SET_APP_ID is null or P_SET_ID is null) ) then
       rollback to start_of_submission;
    end if;

    P_OPS_ID             := null;
    P_PRINT_STYLE        := null;
    P_SAVE_OUTPUT        := null;
    P_PRINT_TOGETHER     := null;
    P_LANGUAGE           := null;
    P_TERRITORY          := null;
    P_DATAGROUP          := null;
    P_DB_TRIGGER_MODE    := FALSE;
    P_CRITICAL_REQUEST   := null;
    P_REQUEST_TYPE       := NULL;
    P_PRINTERS           := empty_array;
    P_PRINTER_COUNT      := 0;
    P_NOTIFICATIONS      := empty_notify_array;
    P_NOTIFICATION_COUNT := 0;
    P_SET_APP_ID         := null;
    P_SET_ID             := null;
    P_SET_PROGRAMS       := empty_rs_array;
    P_SET_PROGRAM_COUNT  := 0;
    P_PHASE_CODE         := null;
    P_STATUS_CODE        := null;
    P_RS_REQUEST_ID      := 0;
    P_TEMPLATE_APPL      := NULL;
    P_TEMPLATE_CODE      := NULL;
    P_TEMPLATE_LANG      := NULL;
    P_TEMPLATE_TERR      := NULL;
    P_OUTPUT_FORMAT      := NULL;
    P_ORG_ID             := NULL;
    P_NLS_SORT           := null;
    P_DELIV_OPTS_COUNT   := 0;
    P_DELIVERY_OPTIONS   := empty_delivery;

  end init_pvt_vars;


  -- Name
  --   init_prog_pvt_vars
  -- Purpose
  --   Called after submitting program to re-initialize print options
  --
  -- --

  procedure init_prog_pvt_vars is
        empty_array        printer_tab_type;
        empty_notify_array notification_tab_type;
        empty_rs_array     rs_program_tab_type;
	empty_delivery     delivery_tab_type;
  begin
    P_PRINT_STYLE         := null;
    P_SAVE_OUTPUT         := null;
    P_PRINT_TOGETHER      := null;
    P_LANGUAGE            := null;
    P_TERRITORY           := null;
    P_REQUEST_TYPE        := NULL;
    P_PRINTERS            := empty_array;
    P_PRINTER_COUNT       := 0;
    P_NOTIFICATIONS       := empty_notify_array;
    P_NOTIFICATION_COUNT  := 0;
    P_TEMPLATE_APPL       := NULL;
    P_TEMPLATE_CODE       := NULL;
    P_TEMPLATE_LANG       := NULL;
    P_TEMPLATE_TERR       := NULL;
    P_OUTPUT_FORMAT       := NULL;
    P_ORG_ID              := NULL;
    P_NLS_SORT            := NULL;
    P_DELIV_OPTS_COUNT    := 0;
    P_DELIVERY_OPTIONS    := empty_delivery;

  end init_prog_pvt_vars;


 -- --
 -- Name
 --   set_request_set
 -- Purpose
 --   To set the request set context. Call this function at very
 --   beginning of the submission of a concurrent request set.
 --   It returns TRUE on sucessful completion, and FALSE otherwise.
 -- --

  function set_request_set    (
                application IN varchar2,
                request_set IN varchar2
                )  return boolean is
     incompatibilities_allowed  varchar2(1);
     print_together           varchar2(1);
     rs_printer            varchar2(30);
     rs_print_style        varchar2(30);
     rs_application_id        Fnd_Request_Sets.Application_id%TYPE;
     rs_id            Fnd_Request_Sets.Request_Set_Id%TYPE;
     rs_owner            Fnd_Request_Sets.Owner%TYPE;
     rs_conc_program        varchar2(30);
     par_request_id         number;
     sub_request        boolean := FALSE;
     success_failure        boolean;
     user_rs_name        varchar2(240);
     i                number;
     rs_submission_program    varchar2(30);
     rs_program_application     varchar2(50);
     invalid_program        boolean;

     -- bug 1679626 (ckclark): When there is more than one occurance
     -- of a specific program within the stage, need to check the
     -- RSP.sequence within the stage to avoid ORA-1422

     cursor set_programs( set_app_id number, set_id number) is
    select CP.concurrent_program_name, CP.enabled_flag, RSS.stage_name,
           RSP.sequence
      from fnd_request_sets RS, fnd_request_set_stages RSS,
           fnd_concurrent_programs CP, fnd_request_set_programs RSP
     where RS.application_id           = set_app_id
       and RS.request_set_id           = set_id
           and RSS.set_application_id      = RS.application_id
           and RSS.request_set_id          = RS.request_set_id
           and RSP.set_application_id      = RSS.set_application_id
           and RSP.request_set_id          = RSS.request_set_id
           and RSP.request_set_stage_id    = RSS.request_set_stage_id
           and RSP.program_application_id  = CP.application_id(+)
           and RSP.concurrent_program_id   = CP.concurrent_program_id(+)
           order by RSP.sequence;

     crec set_programs%ROWTYPE;

     set_not_found        exception;
     sql_generic_error        exception;
     set_print_option_failed    exception;
     fndrssub_failed        exception;
     programs_not_available    exception;
     request_not_found        exception;
     update_failed        exception;
     invalid_program_in_set     exception;

  begin
     -- If not in database trigger mode;
     -- Rollback to start_of_submission if any of the functions fails
     --
     if ( not (P_DB_TRIGGER_MODE) ) then
       savepoint start_of_submission;
     end if;

     -- Get info. about requests origination
     -- if being submitted from another concurrent request get parent
     -- request information.

     par_request_id := FND_GLOBAL.conc_request_id;

     -- Bug - 1162507
     -- The fact that a concurrent request is submitting
     -- request set using the API's does not implicitly make the request
     -- that is being submitted a "sub request"
     -- Caller of the API's need to explicitly indicate that it plans
     -- to manage the request(set) being submitted as a sub request
     -- Commenting the following code ...

     --  if ( to_number(par_request_id) > 0 ) then
     --    sub_request := TRUE;
     -- else
     --    sub_request := FALSE;
     -- end if;

     -- Get Request set info

     begin
       select RS.application_id, RS.request_set_id,
          allow_constraints_flag, RS.print_together_flag,
          RS.owner, RS.printer, RS.print_style,
          CP.Concurrent_Program_Name, RS.User_Request_Set_Name
         into P_SET_APP_ID, P_SET_ID,
          incompatibilities_allowed, print_together,
          rs_owner, rs_printer, rs_print_style,
          rs_conc_program, user_rs_name
     from Fnd_Request_Sets_Vl RS, Fnd_Application A,
              Fnd_Concurrent_Programs CP
    where
          RS.Application_id         = A.Application_id
      And RS.Request_Set_Name         = upper(request_set)
      And A.Application_Short_Name         = upper(application)
          And RS.Start_Date_Active            <= sysdate
      And nvl(RS.End_Date_Active,sysdate)     >= sysdate
      And RS.Concurrent_Program_Id        = CP.Concurrent_Program_Id(+)
      And RS.Application_Id            = CP.Application_Id(+);

     exception
     when no_data_found then
        raise set_not_found;

     when others then
        raise sql_generic_error;
     end;

    -- Populate the P_SET_PROGRAMS with all the programs that are available
    -- in the given set.

    i := 0;
    invalid_program := FALSE;

    for crec in set_programs( P_SET_APP_ID, P_SET_ID ) loop
        -- check program exists in fnd_concurrent_programs or not
    -- check program enabled or not
    -- Bug 5680619
    /*if( crec.concurrent_program_name is null
     or crec.enabled_flag = 'N') then
       invalid_program := TRUE;
        end if;*/
  if( crec.concurrent_program_name is null) then
       invalid_program := TRUE;
        end if;

  if (crec.enabled_flag <> 'N') then
    P_SET_PROGRAMS(i).program := crec.concurrent_program_name;
    P_SET_PROGRAMS(i).stage   := crec.stage_name;
    P_SET_PROGRAMS(i).seq      := crec.sequence;
    P_SET_PROGRAMS(i).flag    := FALSE;
    i := i + 1;
  end if;
    end loop;

    if ( invalid_program ) then
    raise invalid_program_in_set;
    end if;

    P_SET_PROGRAM_COUNT := i;

    if ( i = 0 ) then
    raise programs_not_available;
    end if;


     -- Set the Print options for the FNDRSSUB concurrent program

     success_failure := fnd_request.set_print_options (
                    rs_printer,
                    rs_print_style,
                    0,
                    NULL,
                    print_together);

     -- if set_print_options failes then just return
     -- it is up to the caller to retrive the error message set by
     -- set_print_options

     if ( not success_failure ) then
         raise set_print_option_failed;
     end if;

     -- Set the request set type before submitting the FNDRSSUB request

     fnd_request.internal( NULL, 'M' );

     if ( nvl(incompatibilities_allowed,'N') = 'Y' ) then
         rs_submission_program  := rs_conc_program;
         rs_program_application := application;
     else
     rs_submission_program := 'FNDRSSUB';
         rs_program_application := 'FND';
     end if;

     -- Submit concurrent request for request set

     P_RS_REQUEST_ID := fnd_request.submit_request(
                    rs_program_application,
                    rs_submission_program,
                    user_rs_name,
                    NULL,
                    sub_request,
                    P_SET_APP_ID,
                    P_SET_ID,
                    chr(0),
                    '','','','','','','',
                    '','','','','','','','','','',
                    '','','','','','','','','','',
                    '','','','','','','','','','',
                    '','','','','','','','','','',
                    '','','','','','','','','','',
                    '','','','','','','','','','',
                    '','','','','','','','','','',
                    '','','','','','','','','','',
                    '','','','','','','','','','');

    if ( P_RS_REQUEST_ID = 0 OR P_RS_REQUEST_ID is NULL) then
       raise fndrssub_failed;
    end if;


    -- Before returning update the P_RS_REQUEST_IDs phase and status to
    -- completed with error, we will updated them back to original values
    -- in submit_set function.
    -- If we don't do this then in some cases the set_request_set will
    -- submit the request and if the later calls (submit_program,submit_set..)
    -- fails then the transaction will be in inconsistance state.

    begin
       select phase_code, status_code
     into P_PHASE_CODE, P_STATUS_CODE
     from fnd_concurrent_requests
    where request_id = P_RS_REQUEST_ID;

    exception
       when no_data_found then
      raise request_not_found;
       when others then
      raise sql_generic_error;
    end;

    -- Update the request phase_code and status_code to completed with error

    update fnd_concurrent_requests
       set phase_code = 'C', status_code = 'E',
       completion_text =
           'Errored during request submission using request see APIs '
     where request_id = P_RS_REQUEST_ID;

    if (sql%rowcount = 0 ) then
    raise update_failed;
    end if;

    return( TRUE );

    exception
       when set_not_found then
          fnd_message.set_name('FND', 'CONC-Request Set Not Found');
          fnd_message.set_token('REQUEST_SET', request_set, FALSE);
          init_pvt_vars (TRUE);
          return( FALSE );

       when sql_generic_error then
      fnd_message.set_name('FND', 'SQL-Generic error');
      fnd_message.set_token('ERROR', sqlcode, FALSE);
      fnd_message.set_token('REASON', sqlerrm, FALSE);
      init_pvt_vars(TRUE);
      return( FALSE );

       when set_print_option_failed then
      init_pvt_vars(TRUE);
      return( FALSE );

       when fndrssub_failed then
      init_pvt_vars(TRUE);
      return( FALSE );

       when programs_not_available then
      fnd_message.set_name('FND', 'SRS-EMPTY SET');
      init_pvt_vars(TRUE);
      return( FALSE );

       when request_not_found then
      fnd_message.set_name('FND', 'CONC-MISSING REQUEST');
      fnd_message.set_token('ROUTINE', 'set_request_set', FALSE);
      fnd_message.set_token('REQUEST', rs_submission_program, FALSE);
      init_pvt_vars(TRUE);
      return(FALSE);

       when update_failed then
      fnd_message.set_name('FND', 'SQL-NO UPDATE');
      fnd_message.set_token('TABLE', 'fnd_concurrent_requests', FALSE);
      init_pvt_vars(TRUE);
      return( FALSE );

    when invalid_program_in_set then
      fnd_message.set_name('FND', 'CONC-Invalid program in set');
      fnd_message.set_token('SET_NAME', request_set, FALSE);
      init_pvt_vars(TRUE);
      return(FALSE);

  end set_request_set;

  procedure set_dest_ops(ops_id IN number default NULL) is

  begin
     P_OPS_ID := ops_id;
  end;

-- --
-- Name
--    Submit_Program
-- Purpose
--    It inserts rows into FND_RUN_REQUESTS table for program specified.
--    The program should exists in Request Set. It also inserts rows into
--    FND_RUN_REQ_PP_ACTIONS table based on the options set before calling
--    this function.
--    Call set_request_set function before calling this function to set the
--    context for the report set submission. Call this function for each
--    program in the report set.
--    Function will return TRUE on success and FALSE on failure.

  function submit_program (
          application IN varchar2 default null,
          program     IN varchar2 default null,
          stage       IN varchar2 default null,
          argument1   IN varchar2 default CHR(0),
          argument2   IN varchar2 default CHR(0),
            argument3   IN varchar2 default CHR(0),
          argument4   IN varchar2 default CHR(0),
          argument5   IN varchar2 default CHR(0),
          argument6   IN varchar2 default CHR(0),
          argument7   IN varchar2 default CHR(0),
          argument8   IN varchar2 default CHR(0),
          argument9   IN varchar2 default CHR(0),
          argument10  IN varchar2 default CHR(0),
          argument11  IN varchar2 default CHR(0),
          argument12  IN varchar2 default CHR(0),
            argument13  IN varchar2 default CHR(0),
          argument14  IN varchar2 default CHR(0),
          argument15  IN varchar2 default CHR(0),
          argument16  IN varchar2 default CHR(0),
          argument17  IN varchar2 default CHR(0),
          argument18  IN varchar2 default CHR(0),
          argument19  IN varchar2 default CHR(0),
          argument20  IN varchar2 default CHR(0),
          argument21  IN varchar2 default CHR(0),
          argument22  IN varchar2 default CHR(0),
            argument23  IN varchar2 default CHR(0),
          argument24  IN varchar2 default CHR(0),
          argument25  IN varchar2 default CHR(0),
          argument26  IN varchar2 default CHR(0),
          argument27  IN varchar2 default CHR(0),
          argument28  IN varchar2 default CHR(0),
          argument29  IN varchar2 default CHR(0),
          argument30  IN varchar2 default CHR(0),
          argument31  IN varchar2 default CHR(0),
          argument32  IN varchar2 default CHR(0),
            argument33  IN varchar2 default CHR(0),
          argument34  IN varchar2 default CHR(0),
          argument35  IN varchar2 default CHR(0),
          argument36  IN varchar2 default CHR(0),
          argument37  IN varchar2 default CHR(0),
            argument38  IN varchar2 default CHR(0),
          argument39  IN varchar2 default CHR(0),
          argument40  IN varchar2 default CHR(0),
          argument41  IN varchar2 default CHR(0),
            argument42  IN varchar2 default CHR(0),
          argument43  IN varchar2 default CHR(0),
          argument44  IN varchar2 default CHR(0),
          argument45  IN varchar2 default CHR(0),
          argument46  IN varchar2 default CHR(0),
          argument47  IN varchar2 default CHR(0),
            argument48  IN varchar2 default CHR(0),
          argument49  IN varchar2 default CHR(0),
          argument50  IN varchar2 default CHR(0),
          argument51  IN varchar2 default CHR(0),
          argument52  IN varchar2 default CHR(0),
          argument53  IN varchar2 default CHR(0),
          argument54  IN varchar2 default CHR(0),
          argument55  IN varchar2 default CHR(0),
          argument56  IN varchar2 default CHR(0),
          argument57  IN varchar2 default CHR(0),
          argument58  IN varchar2 default CHR(0),
          argument59  IN varchar2 default CHR(0),
          argument60  IN varchar2 default CHR(0),
          argument61  IN varchar2 default CHR(0),
          argument62  IN varchar2 default CHR(0),
          argument63  IN varchar2 default CHR(0),
          argument64  IN varchar2 default CHR(0),
          argument65  IN varchar2 default CHR(0),
          argument66  IN varchar2 default CHR(0),
          argument67  IN varchar2 default CHR(0),
          argument68  IN varchar2 default CHR(0),
          argument69  IN varchar2 default CHR(0),
          argument70  IN varchar2 default CHR(0),
          argument71  IN varchar2 default CHR(0),
          argument72  IN varchar2 default CHR(0),
          argument73  IN varchar2 default CHR(0),
          argument74  IN varchar2 default CHR(0),
          argument75  IN varchar2 default CHR(0),
          argument76  IN varchar2 default CHR(0),
          argument77  IN varchar2 default CHR(0),
          argument78  IN varchar2 default CHR(0),
          argument79  IN varchar2 default CHR(0),
          argument80  IN varchar2 default CHR(0),
          argument81  IN varchar2 default CHR(0),
          argument82  IN varchar2 default CHR(0),
          argument83  IN varchar2 default CHR(0),
          argument84  IN varchar2 default CHR(0),
          argument85  IN varchar2 default CHR(0),
          argument86  IN varchar2 default CHR(0),
          argument87  IN varchar2 default CHR(0),
          argument88  IN varchar2 default CHR(0),
          argument89  IN varchar2 default CHR(0),
          argument90  IN varchar2 default CHR(0),
          argument91  IN varchar2 default CHR(0),
          argument92  IN varchar2 default CHR(0),
          argument93  IN varchar2 default CHR(0),
          argument94  IN varchar2 default CHR(0),
          argument95  IN varchar2 default CHR(0),
          argument96  IN varchar2 default CHR(0),
          argument97  IN varchar2 default CHR(0),
          argument98  IN varchar2 default CHR(0),
          argument99  IN varchar2 default CHR(0),
          argument100 IN varchar2 default CHR(0))
          return boolean is

    par_request_id     number;
    profile_buffer       varchar2(80) := null;
    request_threshold  number := 0;
    print_copies       number := 0;
    req_limit          char;
    issubreq           char     := 'N';


        default_copies     number;
    default_printer    varchar2(30);
        fcr_printer        varchar2(30);
    fcp_printer        varchar2(30);
        curr_printer       varchar2(30);
        curr_copies        number;
        tot_copies         number := 0;
    print_style        varchar2(30);
    valid_style        varchar2(30) := null;
        reqrd_flag         char;
    minwid             number(3);
    maxwid             number(3) := null;
    minlen             number(3);
      maxlen             number(3) := null;
    execcode       char;
    saveout            char;
    prtflg           char;
    qctlflg           char;
    styl_ok            boolean  := FALSE;
    dummy           char;
        request_set_flag   varchar2(1);
        base_len           number;
        encoded_msg       varchar2(4000);

    rsp_program_id       number;
    rsp_prog_app_id    number;
    rsp_save_output       varchar2(1);
    rsp_conc_prog_id   number;
    rsp_nls_lang       varchar2(30);
    rsp_nls_territory  varchar2(30);
    rsp_copies       number;
    rsp_printer       varchar2(30);
    rsp_style       varchar2(30);
    rsp_save_output_flag varchar2(1);

    TAB_INDEX       number := 0;
    FOUND           boolean := FALSE;

    printer_error       exception;
    style_error       exception;
    srw_style_error       exception;
    printer_styl_error exception;
    insert_error       exception;
    dual_no_rows       exception;
    dual_too_many_rows exception;
    nls_error       exception;
    appl_prog_error       exception;
    already_msg       exception;
    program_not_found  exception;
        context_not_set       exception;

        i                  number;
    new_class  boolean;

  begin
        -- findout the set_request_set called or not.
    if( P_SET_APP_ID is null or P_SET_ID is null ) then
       raise context_not_set;
    end if;



    -- check the program exists in the specified stage by checking
        -- in the table.
        --
    -- bug 1679626 (ckclark): When there is more than one occurance
    -- of a specific program within the stage, need to check the
    -- flag to see whether this instance of the program has already
    -- been submitted within the stage.  The cursor used to populate
    -- P_SET_PROGRAMS was already in order by RSP.sequence, so we
    -- should be picking out the lowest ordered instance of the program
    -- each time

        TAB_INDEX      := 0;
        FOUND          := false;

        while (TAB_INDEX < P_SET_PROGRAM_COUNT) and (not FOUND) loop
            if ( upper( P_SET_PROGRAMS(TAB_INDEX).program )
                = upper( program )
        and
         upper( P_SET_PROGRAMS(TAB_INDEX).stage )
                = upper( stage )
        and
         not ( P_SET_PROGRAMS(TAB_INDEX).flag)  ) then

                    FOUND := true;
            else
                    TAB_INDEX := TAB_INDEX + 1;
            end if;
        end loop;

    if ( not FOUND ) then
       raise program_not_found;
    end if;

    -- get the request_set_program_id,prog_app_id, conc_prog_id and
    -- all options from the fnd_request_set_programs

    begin
        select request_set_program_id, program_application_id,
          RSP.concurrent_program_id, RSP.nls_language,
          RSP.nls_territory, RSP.number_of_copies, RSP.printer,
          RSP.print_style, RSP.save_output_flag
         into rsp_program_id, rsp_prog_app_id,
          rsp_conc_prog_id, rsp_nls_lang,
          rsp_nls_territory, rsp_copies, rsp_printer,
          rsp_style, rsp_save_output_flag
         from fnd_request_set_programs RSP, fnd_request_set_stages RSS,
          fnd_concurrent_programs CP
        where RSP.set_application_id = P_SET_APP_ID
          and RSP.request_set_id     = P_SET_ID
          and RSP.set_application_id = RSS.set_application_id
          and RSP.request_set_id     = RSS.request_set_id
          and RSP.request_set_stage_id = RSS.request_set_stage_id
          and upper(RSS.stage_name)  =
            upper( P_SET_PROGRAMS(TAB_INDEX).stage)
          and CP.application_id     = RSP.program_application_id
          and CP.concurrent_program_id = RSP.concurrent_program_id
          and upper(CP.concurrent_program_name) =
            upper( P_SET_PROGRAMS(TAB_INDEX).program )
          and RSP.sequence = P_SET_PROGRAMS(TAB_INDEX).seq;

    exception
        when no_data_found then
        raise program_not_found;
        when others then
        raise;
    end;


    if (P_PRINT_TOGETHER is NULL) then
      FND_PROFILE.GET ('CONC_PRINT_TOGETHER', profile_buffer);
      if (substr (profile_buffer, 1, 1) = 'Y') then
        P_PRINT_TOGETHER := 'Y';
      else
        P_PRINT_TOGETHER := 'N';
      end if;
    end if;


    -- Default NLS language
    if (P_LANGUAGE is NULL) then
      begin
            select substr(userenv('LANGUAGE'),1,
              instr(userenv('LANGUAGE'), '_') -1)
              into P_LANGUAGE
              from dual;

        exception
          when no_data_found then
        raise nls_error;
          when others then
        raise;
      end;
    end if;

    -- Default NLS territory
    if (P_TERRITORY is NULL) then
      begin
        select substr ( userenv('LANGUAGE') ,
               instr ( userenv('LANGUAGE') , '_') + 1,
               (instr ( userenv('LANGUAGE') , '.') - 1 -
                            instr ( userenv('LANGUAGE') , '_') ))
          into P_TERRITORY
          from dual;

        exception
          when no_data_found then
        raise nls_error;
          when others then
        raise;
      end;
    end if;

    -- Get program's  Printer, Print Style,
    -- Save output flag, priority, and request set flag
        -- from fnd_concurrent_programs
    begin
      Select
         Printer_Name, NVL(Output_Print_Style, 'PORTRAIT'),
         Required_Style, Minimum_Width,
         Minimum_Length,
         Execution_Method_Code, Save_Output_Flag, Print_Flag,
         Queue_Control_Flag
            Into
         fcp_printer, print_style, reqrd_flag, minwid,
         minlen, execcode, saveout, prtflg,
         qctlflg
            From Fnd_Concurrent_Programs P
           Where P.Application_ID = rsp_prog_app_id
         and P.concurrent_program_id = rsp_conc_prog_id;


      exception
        when no_data_found then
          raise appl_prog_error;
        when others then
          raise;
    end;


    -- Set save output flag.  First look for the token.
    -- Then in Request_set_programs, FCP,
    -- profiles, and lastly set it to Y

    if (P_SAVE_OUTPUT in ('Y', 'N')) then
      saveout := P_SAVE_OUTPUT;
    else
      if (rsp_save_output in ('Y', 'N')) then
        saveout := rsp_save_output;
      else
        if ( not saveout in ('Y', 'N')) then
           FND_PROFILE.GET ('CONC_SAVE_OUTPUT', profile_buffer);
           if (not profile_buffer in ('Y', 'N')) then
              saveout := 'Y';
           else
              saveout := profile_buffer;
           end if;
        end if;
      end if;
    end if;


    -- Printer logic

    -- Get default for # of copies
    FND_PROFILE.GET ('CONC_COPIES', profile_buffer);
        if (profile_buffer is not null) then
      default_copies := To_Number (profile_buffer);
      if (default_copies < 0) then
        default_copies := 0;
      end if;
        else
          default_copies := 0;
        end if;

    -- Is printer specified in FCP?
    if (fcp_printer is null) then
      FND_PROFILE.GET ('PRINTER', default_printer);
        else
          default_printer := fcp_printer;
    end if;

    -- If style is passed as an argument, use it only if style is
    -- not required in FCP (fcp.required_style = 'N').
        if ((reqrd_flag <> 'Y') and (P_PRINT_STYLE is not null)) then
      print_style := P_PRINT_STYLE;
    end if;

        -- Get ready for loop.  If no printers were specified, then
        -- we need to set up a default printer if the default copies > 0.
        if ((P_PRINTER_COUNT = 0) and (default_copies > 0)) then
          P_PRINTERS(1).printer := default_printer;
          P_PRINTERS(1).copies := default_copies;
          P_PRINTER_COUNT := 1;
        end if;

        -- Printer Loop
        for i in 1..P_PRINTER_COUNT loop

          curr_printer := P_PRINTERS(i).printer;
          curr_copies  := P_PRINTERS(i).copies;

          if (curr_copies is null) then
            curr_copies := default_copies;
          end if;

          if (curr_copies > 0) then
            tot_copies := tot_copies + curr_copies;

            if (curr_printer is null) then
              curr_printer := default_printer;
            end if;

          -- Printer validation
        -- Validate the printer only if we are going to print, which is,
        -- if the number of copies is > 0, print = Yes, and it is not
        -- a queue control request (e.g. Deactivate Concurrent Manager).
        if ((prtflg = 'Y') and (qctlflg <> 'Y')) then
          -- Error if printer is not specified.
          -- Or, if printer is specified in FCP and also passed as an
          -- argument, but they don't match.
          if ((curr_printer is null) or
              ((curr_printer is not null) and (fcp_printer is not null) and
               (curr_printer <> fcp_printer))) then
            raise printer_error;
          end if;
        end if;

          -- Print style logic

        -- Print style validation

        if ((prtflg = 'Y') and (print_style is null))
            then
              raise style_error;
            end if;

        -- We do not need to validate print style if it's a queue
        -- control request or if the the style is DYNAMIC
        if ((qctlflg <> 'Y') and (print_style <> 'DYNAMIC')) then
          styl_ok := fnd_print.get_style (print_style,
                      minwid, maxwid, minlen, maxlen,
                      (reqrd_flag = 'Y'), curr_printer,
                      valid_style);

          -- If printer and print_style were incompatible, valid_style
          -- is null.  Also check to see if fnd_printer.get_style failed.
          if ((valid_style is null) or (not styl_ok)) then

            -- If we still intend to print, bad news.
            if (prtflg = 'Y') then

                  -- Check for message on stack
                  encoded_msg := FND_MESSAGE.GET_ENCODED;
                  if (encoded_msg is not null) then
                     FND_MESSAGE.SET_ENCODED(encoded_msg);
                     raise already_msg;
                  end if;

              raise printer_styl_error;

            end if; -- ((curr_copies > 0) and (prtflg = 'Y'))
          end if; -- ((valid_style is null) or (not styl_ok))
        end if; -- ((qctlflg <> 'Y') and (print_style <> 'DYNAMIC'))

            -- insert the action
            -- (don't print on warning or failure)

            insert into fnd_run_req_pp_actions
               (parent_request_id, request_set_program_id,
        set_application_id, request_set_id,
        action_type, status_s_flag,
                status_w_flag, status_f_flag,
                program_application_id, program_id,
        arguments, number_of_copies, sequence,ops_instance)
            values
               (P_RS_REQUEST_ID, rsp_program_id,
        P_SET_APP_ID, P_SET_ID,
        1, 'Y', 'N', 'N', NULL, NULL, curr_printer,
                curr_copies, i, NVL(P_OPS_ID,fnd_conc_global.ops_inst_num));

          end if; -- Curr_copies > 0
        end loop;

        -- The first printer in the list will be written into
        -- fcr.  Reports might use it.  Product teams might also
        -- depend on the printer profile in their requests.
        if (P_PRINTER_COUNT > 0) then
          fcr_printer := P_PRINTERS(1).printer;
        else
          fcr_printer := fcp_printer;
        end if;

        -- Even if we aren't going to print, we'll populate
        -- the style.  Styles are required by Oracle Reports.
        if (valid_style is null) then
      -- if it's an Oracle Reports request, we must get
      -- some (valid) print style
      if (execcode = 'P') then
        styl_ok := fnd_print.get_style (print_style,
                            minwid, maxwid,
                        minlen, maxlen,
                        (reqrd_flag = 'Y'),
                        null,
                        valid_style);

        if ((valid_style is null) or (not styl_ok)) then
              -- Check for message on stack
              encoded_msg := FND_MESSAGE.GET_ENCODED;
              if (encoded_msg is not null) then
                 FND_MESSAGE.SET_ENCODED(encoded_msg);
                 raise already_msg;
              end if;

              raise srw_style_error;
            end if;
          else  -- No need to validate style
            valid_style := print_style;
      end if; -- (execcode = 'P')
        end if; -- (valid_style is null)


        -- Insert Notifications
	-- 12.1 Project Changes: Added orig_system and orig_system_id
        for i in 1..P_NOTIFICATION_COUNT loop
           insert into fnd_run_req_pp_actions
               (parent_request_id, request_set_program_id,
        set_application_id, request_set_id,
        action_type, status_s_flag,
                status_w_flag, status_f_flag,
                program_application_id, program_id,
        arguments, number_of_copies, sequence,ops_instance, orig_system, orig_system_id)
            values
               (P_RS_REQUEST_ID, rsp_program_id,
        	P_SET_APP_ID, P_SET_ID,	2,
        	P_NOTIFICATIONS(i).on_normal, P_NOTIFICATIONS(i).on_warning, P_NOTIFICATIONS(i).on_error,
        	NULL, NULL, P_NOTIFICATIONS(i).name,
        	NULL, i,NVL(P_OPS_ID,fnd_conc_global.ops_inst_num),
		P_NOTIFICATIONS(i).orig_system,
 	      P_NOTIFICATIONS(i).orig_system_id);
        end loop;


        -- Insert layout options
		if P_TEMPLATE_CODE is not null then
            insert into fnd_run_req_pp_actions
               (parent_request_id, request_set_program_id,
                set_application_id, request_set_id,
                action_type, status_s_flag,
                status_w_flag, status_f_flag,
                program_application_id, program_id,
                arguments, number_of_copies, sequence, ops_instance,
                argument1, argument2, argument3, argument4, argument5)
                values
               (P_RS_REQUEST_ID, rsp_program_id,
                P_SET_APP_ID, P_SET_ID,
                6, 'Y', 'N', 'N', NULL, NULL, NULL,
                NULL, 1, NVL(P_OPS_ID, fnd_conc_global.ops_inst_num),
                P_TEMPLATE_APPL, P_TEMPLATE_CODE, P_TEMPLATE_LANG,
                P_TEMPLATE_TERR, P_OUTPUT_FORMAT);
        end if;

	 -- Insert delivery options
         if (P_DELIV_OPTS_COUNT > 0) then
	   for i in 1..P_DELIV_OPTS_COUNT loop
               insert into fnd_run_req_pp_actions
                      (parent_request_id,
                        request_set_id,set_application_id,request_set_program_id,
                        action_type,status_s_flag,status_w_flag,status_f_flag,
                        program_application_id,program_id,sequence,
                        argument1,argument2,
		        argument3,argument4,
                        argument5,argument6,
                        argument7,argument8,
                        argument9,argument10,
                        nls_language,ops_instance)
             values
                       (P_RS_REQUEST_ID,
                        P_SET_ID, P_SET_APP_ID, rsp_program_id,
                        decode( P_DELIVERY_OPTIONS(i).argument1, 'B', 8, 7 ),
                        'Y', 'Y', 'N',
			NULL, NULL, i,
			P_DELIVERY_OPTIONS(i).argument1,P_DELIVERY_OPTIONS(i).argument2,
			P_DELIVERY_OPTIONS(i).argument3,P_DELIVERY_OPTIONS(i).argument4,
			P_DELIVERY_OPTIONS(i).argument5,P_DELIVERY_OPTIONS(i).argument6,
			P_DELIVERY_OPTIONS(i).argument7,P_DELIVERY_OPTIONS(i).argument8,
			P_DELIVERY_OPTIONS(i).argument9,P_DELIVERY_OPTIONS(i).argument10,
			P_DELIVERY_OPTIONS(i).lang, -1);
	   end loop;
         end if;

    -- Insert into fnd_run_requests table
    --
    -- bug5676655/bug5709193 added numeric_characters
    --
    insert
      into fnd_run_requests (
        application_id, concurrent_program_id,
        parent_request_id, request_set_program_id,
        set_application_id, request_set_id,
        number_of_copies, printer, print_style,
        save_output_flag, nls_language, nls_territory, OPS_Instance,
        argument1,  argument2,  argument3,  argument4,
        argument5,  argument6,  argument7,  argument8,
        argument9,  argument10, argument11, argument12,
        argument13, argument14, argument15, argument16,
        argument17, argument18, argument19, argument20,
        argument21, argument22, argument23, argument24,
        argument25, argument26, argument27, argument28,
        argument29, argument30, argument31, argument32,
        argument33, argument34, argument35, argument36,
        argument37, argument38, argument39, argument40,
        argument41, argument42, argument43, argument44,
        argument45, argument46, argument47, argument48,
        argument49, argument50, argument51, argument52,
        argument53, argument54, argument55, argument56,
        argument57, argument58, argument59, argument60,
        argument61, argument62, argument63, argument64,
        argument65, argument66, argument67, argument68,
        argument69, argument70, argument71, argument72,
        argument73, argument74, argument75, argument76,
        argument77, argument78, argument79, argument80,
        argument81, argument82, argument83, argument84,
        argument85, argument86, argument87, argument88,
        argument89, argument90, argument91, argument92,
        argument93, argument94, argument95, argument96,
        argument97, argument98, argument99, argument100, org_id,
        numeric_characters, recalc_parameters, nls_sort)
    select  rsp_prog_app_id, rsp_conc_prog_id,
        P_RS_REQUEST_ID, rsp_program_id,
        P_SET_APP_ID, P_SET_ID,
        tot_copies, fcr_printer, valid_style,
        saveout, P_LANGUAGE, P_TERRITORY,
        NVL(P_OPS_ID,fnd_conc_global.ops_inst_num),
        submit_program.argument1, submit_program.argument2,
        submit_program.argument3, submit_program.argument4,
        submit_program.argument5, submit_program.argument6,
        submit_program.argument7, submit_program.argument8,
        submit_program.argument9, submit_program.argument10,
        submit_program.argument11, submit_program.argument12,
        submit_program.argument13, submit_program.argument14,
        submit_program.argument15, submit_program.argument16,
        submit_program.argument17, submit_program.argument18,
        submit_program.argument19, submit_program.argument20,
        submit_program.argument21, submit_program.argument22,
        submit_program.argument23, submit_program.argument24,
        submit_program.argument25, submit_program.argument26,
        submit_program.argument27, submit_program.argument28,
        submit_program.argument29, submit_program.argument30,
        submit_program.argument31, submit_program.argument32,
        submit_program.argument33, submit_program.argument34,
        submit_program.argument35, submit_program.argument36,
        submit_program.argument37, submit_program.argument38,
        submit_program.argument39, submit_program.argument40,
        submit_program.argument41, submit_program.argument42,
        submit_program.argument43, submit_program.argument44,
        submit_program.argument45, submit_program.argument46,
        submit_program.argument47, submit_program.argument48,
        submit_program.argument49, submit_program.argument50,
        submit_program.argument51, submit_program.argument52,
        submit_program.argument53, submit_program.argument54,
        submit_program.argument55, submit_program.argument56,
        submit_program.argument57, submit_program.argument58,
        submit_program.argument59, submit_program.argument60,
        submit_program.argument61, submit_program.argument62,
        submit_program.argument63, submit_program.argument64,
        submit_program.argument65, submit_program.argument66,
        submit_program.argument67, submit_program.argument68,
        submit_program.argument69, submit_program.argument70,
        submit_program.argument71, submit_program.argument72,
        submit_program.argument73, submit_program.argument74,
        submit_program.argument75, submit_program.argument76,
        submit_program.argument77, submit_program.argument78,
        submit_program.argument79, submit_program.argument80,
        submit_program.argument81, submit_program.argument82,
        submit_program.argument83, submit_program.argument84,
        submit_program.argument85, submit_program.argument86,
        submit_program.argument87, submit_program.argument88,
        submit_program.argument89, submit_program.argument90,
        submit_program.argument91, submit_program.argument92,
        submit_program.argument93, submit_program.argument94,
        submit_program.argument95, submit_program.argument96,
        submit_program.argument97, submit_program.argument98,
        submit_program.argument99, submit_program.argument100,
        P_ORG_ID,
        P_NUMERIC_CHARACTERS,
        null,
        P_NLS_SORT
       from sys.dual;

    if (sql%rowcount = 0) then
       raise insert_error;
    end if;

    -- set the P_SET_PROGRAMS table flag to TRUE, which indicates that
        -- the program is submitted. We already got the index for the program
    P_SET_PROGRAMS(TAB_INDEX).flag := TRUE;

    init_prog_pvt_vars;
    return (TRUE);

    exception
      when context_not_set then
        fnd_message.set_name('FND', 'CONC-Context not set');
        fnd_message.set_token('ROUTINE', 'submit_program', FALSE);
        init_pvt_vars(TRUE);
        return(FALSE);
      when program_not_found then
        fnd_message.set_name ('FND', 'CONC-Invalid prog for stage');
        fnd_message.set_token('PROGRAM', program, FALSE);
        fnd_message.set_token('STAGE', stage, FALSE);
        init_pvt_vars(TRUE);
        return(FALSE);
      when printer_error then
        fnd_message.set_name ('FND', 'CONC-Illegal printer spec');
        init_pvt_vars(TRUE);
        return (FALSE);
      when style_error then
        fnd_message.set_name ('FND', 'SRS-Must specify print style');
        init_pvt_vars(TRUE);
        return (FALSE);
      when printer_styl_error then
        fnd_message.set_name ('FND', 'CONC-Invalid printer style');
        fnd_message.set_token ('STYLE', print_style, FALSE);
        fnd_message.set_token ('PRINTER', curr_printer, FALSE);
        init_pvt_vars(TRUE);
        return (FALSE);
      when srw_style_error then
        fnd_message.set_name ('FND', 'SRS-Must specify srw style');
        init_pvt_vars(TRUE);
        return (FALSE);
      when nls_error then
        fnd_message.set_name ('FND', 'GLI-Not found');
        init_pvt_vars(TRUE);
        return (FALSE);

      when insert_error then
         fnd_message.set_name ('FND', 'SQL-Generic error');
         fnd_message.set_token ('ERRNO', sqlcode, FALSE);
         fnd_message.set_token ('REASON', sqlerrm, FALSE);
         fnd_message.set_token (
            'ROUTINE', 'SUBMIT_PROGRAM: insert_error2', FALSE);
         init_pvt_vars(TRUE);
         return (FALSE);
      when dual_no_rows then
        fnd_message.set_name ('FND', 'No Rows in SYS.Dual');
        init_pvt_vars(TRUE);
        return (FALSE);
      when dual_too_many_rows then
        fnd_message.set_name ('FND', 'Too many rows in SYS.Dual');
        init_pvt_vars(TRUE);
        return (FALSE);
      when already_msg then
        init_pvt_vars(TRUE);
        return (FALSE);
      when others then
        fnd_message.set_name ('FND', 'SQL-Generic error');
        fnd_message.set_token ('ERRNO', sqlcode, FALSE);
        fnd_message.set_token ('REASON', sqlerrm, FALSE);
        fnd_message.set_token (
                'ROUTINE', 'SUBMIT_PROGRAM: others', FALSE);
        init_pvt_vars(TRUE);
        return (FALSE);

  end submit_program;

  -- --
  -- Name
  --   submit_set
  -- Purpose
  --   Call this function to submit the request set which is set by using the
  --   set_request_set.
  --   It will check whether each program in the request set is submitted
  --   or not.
  --   If the request completes successfully, thsi function returns the
  --   concurrent request ID (P_RS_REQUEST_ID); otherwise; it returns 0.

  function submit_set( start_time IN varchar2 default NULL,
               sub_request IN boolean default FALSE)
        return integer is
     TAB_INDEX             integer;
     req_id            integer;
     profile_buffer        varchar2(80) := null;
     tz_offset            integer;
     requested_start        date;
     issubreq            varchar2(1) := 'N';
     par_request_id         number;

     program_not_called        exception;
     update_failed        exception;
     context_not_set        exception;
     start_time_error        exception;

  begin
     -- findout the set_request_set called or not.
     if( P_SET_APP_ID is null or P_SET_ID is null ) then
    raise context_not_set;
     end if;

     -- Check submit_program is called for all the programs in the request set.
     -- If not rollback to the start_of_transaction.
     TAB_INDEX := 0;

     while (TAB_INDEX < P_SET_PROGRAM_COUNT) loop
        if ( not  P_SET_PROGRAMS(TAB_INDEX).flag ) then
       raise program_not_called;
        end if;
    TAB_INDEX := TAB_INDEX + 1;
     end loop;

     -- Get info. about requests origination
     -- if being submitted from another concurrent request get parent
     -- request information.

     par_request_id := FND_GLOBAL.conc_request_id;

     profile_buffer := NULL;
     FND_PROFILE.GET('CONC_MULTI_TZ', profile_buffer);

     if (profile_buffer in ('Y', 'y')) then
        tz_offset := 1;
     else
        tz_offset := 0;
     end if;

     profile_buffer := NULL;
     if (start_time is null) then
      FND_PROFILE.GET ('CONC_REQ_START', profile_buffer);
     else
      profile_buffer := start_time;
     end if;

     if (profile_buffer is not null) then
        requested_start := fnd_conc_date.string_to_date(profile_buffer);
        if (requested_start is null) then
            raise start_time_error;
        end if;
     else
        requested_start := null;
     end if;

     if( sub_request ) then
    issubreq := 'Y';
     end if;

     -- Update back the request phase_code and status_code to the original
     -- values.
     update fnd_concurrent_requests
        set phase_code  = P_PHASE_CODE,
            status_code = Decode(issubreq, 'Y', 'Z', P_STATUS_CODE),
        completion_text = '',
        is_sub_request = issubreq,
        requested_start_date =
        Decode (requested_start,
               '', (SYSDATE - tz_offset),
               Greatest (requested_start,
                       Decode (par_request_id,
                         0, (SYSDATE - tz_offset),
                        To_Date ('01-01-0001',
                             'DD-MM-YYYY'))))
      where request_id = P_RS_REQUEST_ID;

    if (sql%rowcount = 0 ) then
    raise update_failed;
    end if;

     -- initialize the private variables and return the request id of the
     -- set submitted in set_request_set
     req_id := P_RS_REQUEST_ID;
     init_pvt_vars(FALSE);
     return( req_id );

  exception
     when context_not_set then
    fnd_message.set_name('FND', 'CONC-Context not set');
    fnd_message.set_token('ROUTINE', 'submit_set', FALSE);
    init_pvt_vars(TRUE);
    return(0);

     when program_not_called then
    fnd_message.set_name('FND', 'CONC-submit program not called');
    fnd_message.set_token('PROGRAM', P_SET_PROGRAMS(TAB_INDEX).program,
                        FALSE);
    fnd_message.set_token('STAGE',P_SET_PROGRAMS(TAB_INDEX).stage, FALSE);
    init_pvt_vars(TRUE);
    return ( 0 );
     when update_failed then
    fnd_message.set_name('FND', 'SQL-NO UPDATE');
    fnd_message.set_token('TABLE', 'fnd_concurrent_requests', FALSE);
    init_pvt_vars(TRUE);
    return( 0 );
     when start_time_error then
    fnd_message.set_name ('FND', 'CONC-Invalid Req Start Date');
    fnd_message.set_token ('START_DATE', requested_start, FALSE);
    init_pvt_vars(TRUE);
    return (0);
  end submit_set;

  --
  -- Name
  --   set_mode
  -- Purpose
  --   Called before submitting request to set database trigger mode
  --
  -- Arguments
  --   db_trigger    - Set to TRUE for database trigger mode
  --
  function set_mode (db_trigger  IN boolean) return boolean is
  begin
    P_DB_TRIGGER_MODE := db_trigger;
    return (fnd_request.set_mode(db_trigger));
    return TRUE;
  end;


  -- Name
  --   set_nls_options
  --   bug5676655/bug5709193 - added p_numeric_characters
  -- Purpose
  --   Called before submitting request to set request attributes
  --
  -- Arguments
  --
  --   language        - NLS language
  --   territory    - Language territory
  --   numeric_characters - Numeric Characters
  --   nls_sort           - NLS Sort
  --
  -- --

  function set_nls_options( language  IN varchar2 default NULL,
                territory IN varchar2 default NULL,
                numeric_characters IN varchar2 default NULL,
                nls_sort IN varchar2 default 'BINARY')
            return boolean is
  begin

    P_LANGUAGE := language;
    P_TERRITORY := territory;
    P_NUMERIC_CHARACTERS := numeric_characters;
    P_NLS_SORT := nls_sort;


    return (TRUE);

  end set_nls_options;


  --
  -- Name
  --   set_repeat_options
  -- Purpose
  --   Called before submitting request if the request to be submitted
  --   is a repeating request.
  --   All the messages are set by fnd_request.set_repeat_options function.
  --
  -- Arguments
  --   repeat_time    - Time of day at which it has to be repeated
  --   repeat_interval  - Frequency at which it has to be repeated
  --            - This will be used/applied only when repeat_time
  --            - is NULL ( non null repeat_interval overrides )
  --   repeat_unit    - Unit for repeat interval. Default is DAYS.
  --            - MONTHS/DAYS/HOURS/MINUTES
  --   repeat_type    - Apply repeat interval from START or END of request
  --            - default is START. START/END
  --   repeat_end_time  - Time at which the repetition should be stopped
  --
  function set_repeat_options (repeat_time      IN varchar2 default NULL,
                   repeat_interval  IN number   default NULL,
                   repeat_unit      IN varchar2 default 'DAYS',
                   repeat_type      IN varchar2 default 'START',
                   repeat_end_time  IN varchar2 default NULL,
                   recalc_parameters IN varchar2 default NULL)
                   return boolean is
  success boolean;
  begin

     -- Just call the fnd_request.set_repeat_options with the passed parameters

     success := fnd_request.set_repeat_options(repeat_time,
                          repeat_interval,
                          repeat_unit,
                          repeat_type,
                          repeat_end_time,
                          recalc_parameters);
     if ( not success ) then
    init_pvt_vars(FALSE);
    return( FALSE );
     else
    return ( TRUE );
     end if;

  end set_repeat_options;

  --
  -- Name
  --   set_increment_dates_option
  -- Purpose
  --   Called before submitting request if the request to be submitted
  --   has a schedule set that repeats.  Making this available outside of
  --   set_repeat_options in case the repeating schedule is set with
  --   set_rel_class_options or fnd_conc_release_class_utils.assign_specific_sch
  --
  -- Arguments
  --   increment_dates   - 'Y' if dates should be incremented each run,
  --                      otherwise 'N'
  --
  procedure set_increment_dates_option (increment_dates  IN varchar2)
                               is
  begin

     -- Just call the fnd_request.set_increment_dates_option
     -- with the passed parameters

     fnd_request.set_increment_dates_option(increment_dates);

  end set_increment_dates_option;

  --
  -- Name
  --   set_recalc_parameters_option
  -- Purpose
  --   Called before submitting request if the request to be submitted
  --   has a schedule set that repeats.  Making this available outside of
  --   set_repeat_options in case the repeating schedule is set with
  --   set_rel_class_options or fnd_conc_release_class_utils.assign_specific_sch
  --
  -- Arguments
  --   recalc_parameters   - 'Y' if parameters are recalculated each run,
  --                      otherwise 'N'
  --
  procedure set_recalc_parameters_option (recalc_parameters  IN varchar2)
                               is
  begin

     -- Just call the fnd_request.set_recalc_parameters_option
     -- with the passed parameters

     fnd_request.set_recalc_parameters_option(recalc_parameters);

  end set_recalc_parameters_option;

  --
  -- Name
  --   set_rel_class_options
  -- Purpose
  --   Called before submitting request if the request to be submitted
  --   is using the new scheduler functionality.
  --   All the failure messages are from the fnd_request package.
  --
  -- Arguments
  --   application    - Application Name of Release Class
  --   class_name    - (Developer) Name of Release Class
  --   cancel_or_hold    - Cancel or hold flag
  --   stale_date    - Cancel request on or after this time if not run
  --
  function set_rel_class_options (application      IN varchar2 default NULL,
                      class_name      IN varchar2 default NULL,
                      cancel_or_hold IN varchar2 default 'H',
                      stale_date      IN varchar2 default NULL)
                      return boolean is

  success boolean;
  begin
     -- just call fnd_request.set_rel_class_options and return the return code
     -- set_rel_class_options is with respect to set_request_set function.

     success := fnd_request.set_rel_class_options (
                    application,
                    class_name,
                    cancel_or_hold,
                    stale_date
                    );

     if ( success ) then
    return ( TRUE );
     else
    init_pvt_vars(FALSE);
    return (FALSE);
     end if;

  end set_rel_class_options;

  --
  -- Name
  --   set_org_id
  -- Purpose
  --   Called before submitting request if the program is 'Sinle' multi org catagory.,
  --
  -- Arguments
  --   org_id		- Operating unit id
  --
	procedure set_org_id(org_id IN number default NULL) is
	begin
		 P_ORG_ID := org_id;
	end;

  --
  -- Name
  --   set_print_options
  -- Purpose
  --   Called before submitting request if the printing of output has
  --   to be controlled with specific printer/style/copies etc.,
  --
  -- Arguments
  --   printer        - Printer name where the request o/p should be sent
  --   style        - Print style that needs to be used for printing
  --   copies        - Number of copies to print
  --   save_output    - Should the output file be saved after printing
  --               - Default is TRUE.  TRUE/FALSE
  --   print_together   - Applies only for sub requests. If 'Y', output
  --            - will not be printed until all the sub requests
  --            - complete. Default is N. Y/N
  function set_print_options (printer         IN varchar2 default NULL,
                  style         IN varchar2 default NULL,
                  copies         IN number     default NULL,
                  save_output    IN boolean  default TRUE,
                  print_together IN varchar2 default 'N')
                  return  boolean is

    printer_typ        varchar2 (30) := null;
    dummy_fld        varchar (2);

    print_together_error    exception;
    printer_error        exception;
    style_error        exception;
    printer_style_error    exception;
        empty_array             printer_tab_type;
        prec  printer_record_type;

  begin
        -- Clear any old printers
        -- Just in case this was called twice.
        if P_PRINTER_COUNT > 0 then
          P_PRINTERS := empty_array;
          P_PRINTER_COUNT := 0;
        end if;

    if (upper (print_together) not in ('Y', 'N')) then
      raise print_together_error;
    end if;

    if (upper (print_together) = 'Y') then
      P_PRINT_TOGETHER   := 'Y';
    elsif (upper (print_together) = 'N') then
      P_PRINT_TOGETHER   := 'N';
    else
      P_PRINT_TOGETHER   := NULL;
    end if;

    if (save_output is null) then
      P_SAVE_OUTPUT      := NULL;
    elsif (save_output) then
      P_SAVE_OUTPUT      := 'Y';
        else
      P_SAVE_OUTPUT      := 'N';
    end if;

    if (printer is not null) then -- Verify printer
      begin
        Select printer_type
          Into printer_typ
          From fnd_printer
         Where printer_name = printer;

        exception
          when no_data_found then
        raise printer_error;

          when others then
        raise;
      end;
    end if; -- Verify printer


    if (style is not null) then -- Verify style
      begin
        Select Printer_Style_Name
          Into P_PRINT_STYLE
          From Fnd_Printer_styles
         Where Printer_Style_Name = style;

        exception
          when no_data_found then
        raise style_error;

          when others then
        raise;
      end;
     end if; -- Verify style

    if ((printer is not null) and
        (style is not null)) then -- Verify printer/style comination
      begin
        Select 'X'
          Into Dummy_fld
          From Fnd_Printer_Information
         Where Printer_Style = P_PRINT_STYLE
           And Printer_Type  = printer_typ;

        exception
          when no_data_found then
        raise printer_style_error;

          when others then
        raise;
      end;
    end if; -- Verify printer/style comination

        -- Add printer/copies to the list.
        -- Note that we will attempt to process the defaults
        -- for nulls at submission time.  For now, store the
        -- nulls.

        if (copies is not null or printer is not null) then
          P_PRINTER_COUNT := 1;

          -- The following inderect assignment was required to get
          -- the procedure to compile.  The problem, for some reason
          -- doesn't seem to affect the other procedures in this package.
          prec.printer := printer;
          prec.copies := copies;
          P_PRINTERS(1) := prec;
        end if;


    return (TRUE);

    exception
      when print_together_error then
        fnd_message.set_name ('FND', 'CONC-Invalid opt:Print Group');
        init_pvt_vars (TRUE);
        return (FALSE);

      when printer_error then
        fnd_message.set_name ('FND', 'PRINTERS-No system printer');
        fnd_message.set_token ('PRINTER', printer, FALSE);
        init_pvt_vars (TRUE);
        return (FALSE);

      when style_error then
        fnd_message.set_name ('FND', 'PRT-Invalid print style');
        fnd_message.set_token ('STYLE', style, FALSE);
        init_pvt_vars(TRUE);
        return (FALSE);

      when printer_style_error then
        fnd_message.set_name ('FND', 'CONC-Invalid printer style');
        fnd_message.set_token ('STYLE', style, FALSE);
        fnd_message.set_token ('PRINTER', printer, FALSE);
        init_pvt_vars(TRUE);
        return (FALSE);

      when others then
        init_pvt_vars(TRUE);
        fnd_message.set_name ('FND', 'SQL-Generic error');
        fnd_message.set_token ('ERRNO', sqlcode, FALSE);
        fnd_message.set_token ('REASON', sqlerrm, FALSE);
        fnd_message.set_token ('ROUTINE', 'SET_PRINT_OPTIONS', FALSE);
        return (FALSE);
  end set_print_options;

  --
  -- Name
  --   add_printer
  -- Purpose
  --   Called after set print options to add a printer to the
  --   print list.
  --
  -- Arguments
  --   printer        - Printer name where the request o/p should be sent
  --   copies        - Number of copies to print
  function add_printer (printer in varchar2 default null,
                        copies  in number default null) return boolean is
    printer_typ        varchar2 (30) := null;
    dummy_fld        varchar (2);
    print_together_error    exception;
    printer_error        exception;
    style_error        exception;
    printer_style_error    exception;
  begin
    if (printer is not null) then -- Verify printer
      begin
        Select printer_type
          Into printer_typ
          From fnd_printer
         Where printer_name = printer;

        exception
          when no_data_found then
        raise printer_error;

          when others then
        raise;
      end;
    end if; -- Verify printer


    if ((printer is not null) and
        (P_PRINT_STYLE is not null)) then -- Verify printer/style combo
      begin
        Select 'X'
          Into Dummy_fld
          From Fnd_Printer_Information
         Where Printer_Style = P_PRINT_STYLE
           And Printer_Type  = printer_typ;

        exception
          when no_data_found then
        raise printer_style_error;

          when others then
        raise;
      end;
    end if; -- Verify printer/style comination

        -- Add printer/copies to the list.
        -- Note that we will attempt to process the defaults
        -- for nulls at submission time.  For now, store the
        -- nulls.
        P_PRINTER_COUNT := P_PRINTER_COUNT + 1;
        P_PRINTERS(P_PRINTER_COUNT).printer := printer;
        P_PRINTERS(P_PRINTER_COUNT).copies := copies;

    return (TRUE);

    exception
      when print_together_error then
        fnd_message.set_name ('FND', 'CONC-Invalid opt:Print Group');
        init_pvt_vars(TRUE);
        return (FALSE);

      when printer_error then
        fnd_message.set_name ('FND', 'PRINTERS-No system printer');
        fnd_message.set_token ('PRINTER', printer, FALSE);
        init_pvt_vars(TRUE);
        return (FALSE);

      when style_error then
        fnd_message.set_name ('FND', 'PRT-Invalid print style');
        fnd_message.set_token ('STYLE', P_PRINT_STYLE, FALSE);
        init_pvt_vars(TRUE);
        return (FALSE);

      when printer_style_error then
        fnd_message.set_name ('FND', 'CONC-Invalid printer style');
        fnd_message.set_token ('STYLE', P_PRINT_STYLE, FALSE);
        fnd_message.set_token ('PRINTER', printer, FALSE);
        init_pvt_vars(TRUE);
        return (FALSE);

      when others then
        init_pvt_vars(TRUE);
        fnd_message.set_name ('FND', 'SQL-Generic error');
        fnd_message.set_token ('ERRNO', sqlcode, FALSE);
        fnd_message.set_token ('REASON', sqlerrm, FALSE);
        fnd_message.set_token ('ROUTINE', 'SET_PRINT_OPTIONS', FALSE);
        return (FALSE);

  end;


  --
  -- Name
  --   add_notification
  -- Purpose
  --   Called before submission to add a user to the notify list.
  --
  -- Arguments
  --    User        - User name.
  -- 12.1 Project Changes: Added orig_system and orig_system_id

  function add_notification (
    user in varchar2,
  	on_normal  in varchar2 default 'Y',
  	on_warning in varchar2 default 'N',
  	on_error   in varchar2 default 'N' ) return boolean is
n_index number;
/*    c number;
  begin
    select count(*)
      into c
      from wf_roles
      where user = name;

    if (c > 0) then
      P_NOTIFICATION_COUNT := P_NOTIFICATION_COUNT + 1;
      P_NOTIFICATIONS(P_NOTIFICATION_COUNT).name := user;
	   	P_NOTIFICATIONS(P_NOTIFICATION_COUNT).on_normal := on_normal;
	   	P_NOTIFICATIONS(P_NOTIFICATION_COUNT).on_warning := on_warning;
	   	P_NOTIFICATIONS(P_NOTIFICATION_COUNT).on_error := on_error;
      return TRUE;
    else
      fnd_message.set_name('FND', 'CONC-INVALID NOTIFY USER');
      return FALSE;
    end if;*/
cursor c1( user_name varchar2) is
        select name, orig_system, orig_system_id
          from wf_roles
         where name = user_name;
   begin

    -- Same user may exists in different departments(tables).
    -- use cursor because we dont know the given user name will return one row
    -- multiple rows.
    -- we are considering only the first row that matched in wf_roles.

     n_index := P_NOTIFICATION_COUNT + 1;
     open c1( user );
     fetch c1 into P_NOTIFICATIONS(n_index).name,
 			P_NOTIFICATIONS(n_index).orig_system,
 			P_NOTIFICATIONS(n_index).orig_system_id;

     P_NOTIFICATIONS(n_index).on_normal := on_normal;
     P_NOTIFICATIONS(n_index).on_warning := on_warning;
     P_NOTIFICATIONS(n_index).on_error := on_error;

     if( c1%notfound ) then
       fnd_message.set_name('FND', 'CONC-INVALID NOTIFY USER');
       close c1;
       return FALSE;
     else
       P_NOTIFICATION_COUNT := P_NOTIFICATION_COUNT + 1;
       close c1;
       return TRUE;
     end if;
  end;


  --
  -- Name
  --   add_layout
  -- Purpose
  --   Called before submission to add layout options to a request.
  --
  -- Arguments
  --   template_appl_name   - Template application short name
  --   template_code        - Template code
  --   template_language    - ISO 2-letter language code
  --   template_territory   - ISO 2-letter territory code
  --   output_format        - Output format type of the final output
  function add_layout(template_appl_name in varchar2,
                      template_code      in varchar2,
                      template_language  in varchar2,
                      template_territory in varchar2,
                      output_format      in varchar2) return boolean is


  begin
      -- It is callers responsibility to provide valid values.
      P_TEMPLATE_APPL   := template_appl_name;
      P_TEMPLATE_CODE   := template_code;
      P_TEMPLATE_LANG   := template_language;
      P_TEMPLATE_TERR   := template_territory;
      P_OUTPUT_FORMAT   := output_format;
      return (TRUE);

  end;





  --
  -- Name
  --   add_delivery_option
  -- Purpose
  --   Called before submission to add a delivery option
  --
  -- Arguments
  --	Type		- Delivery type, see FND_DELIVERY
  --    p_argument1 - p_argument9 - Options specific to the delivery type
  --    nls_language    - Add only for this language
  --
  function add_delivery_option ( type in varchar2,
				 p_argument1 in varchar2 default null,
				 p_argument2 in varchar2 default null,
                                 p_argument3 in varchar2 default null,
				 p_argument4 in varchar2 default null,
				 p_argument5 in varchar2 default null,
				 p_argument6 in varchar2 default null,
                                 p_argument7 in varchar2 default null,
				 p_argument8 in varchar2 default null,
				 p_argument9 in varchar2 default null,
				 nls_language in varchar2 default null) return boolean is

     begin

	P_DELIV_OPTS_COUNT := P_DELIV_OPTS_COUNT + 1;

	P_DELIVERY_OPTIONS(P_DELIV_OPTS_COUNT).argument1 := type;
	P_DELIVERY_OPTIONS(P_DELIV_OPTS_COUNT).argument2 := p_argument1;
        P_DELIVERY_OPTIONS(P_DELIV_OPTS_COUNT).argument3 := p_argument2;
	P_DELIVERY_OPTIONS(P_DELIV_OPTS_COUNT).argument4 := p_argument3;
	P_DELIVERY_OPTIONS(P_DELIV_OPTS_COUNT).argument5 := p_argument4;
	P_DELIVERY_OPTIONS(P_DELIV_OPTS_COUNT).argument6 := p_argument5;
	P_DELIVERY_OPTIONS(P_DELIV_OPTS_COUNT).argument7 := p_argument6;
	P_DELIVERY_OPTIONS(P_DELIV_OPTS_COUNT).argument8 := p_argument7;
	P_DELIVERY_OPTIONS(P_DELIV_OPTS_COUNT).argument9 := p_argument8;
	P_DELIVERY_OPTIONS(P_DELIV_OPTS_COUNT).argument10 := p_argument9;
        P_DELIVERY_OPTIONS(P_DELIV_OPTS_COUNT).lang := nls_language;

	return (TRUE);

     end add_delivery_option;



     function add_email (subject         in varchar2,
		         from_address    in varchar2,
		         to_address      in varchar2,
		         cc              in varchar2 default null,
		         lang            in varchar2 default null) return boolean is

      begin

	 if (subject is null or from_address is null or to_address is null) then
	    return false;
	 end if;

	 return add_delivery_option(type => fnd_delivery.type_email,
			    p_argument1  => subject,
			    p_argument2  => from_address,
			    p_argument3  => to_address,
			    p_argument4  => cc,
			    nls_language => lang);

      end add_email;


      function add_ipp_printer (printer_name in varchar2,
			        copies       in number default null,
			        orientation  in varchar2 default null,
			        username     in varchar2 default null,
			        password     in varchar2 default null,
			        lang         in varchar2 default null) return boolean is
         printer_id   number;

      begin

        select delivery_id
	    into printer_id
	    from fnd_cp_ipp_printers
	    where ipp_printer_name = printer_name;

        return add_ipp_printer(printer_id, copies, orientation, username, password, lang);

      exception
	 when others then
	    return false;

      end add_ipp_printer;


      function add_ipp_printer (printer_id   in number,
			        copies       in number default null,
			        orientation  in varchar2 default null,
			        username     in varchar2 default null,
			        password     in varchar2 default null,
			        lang         in varchar2 default null) return boolean is

        cnt   number;
        svc_key varchar2(16) := null;

      begin

	 if (printer_id is null) then
	    return false;
	 end if;

	 if (orientation is not null and
	     orientation <> fnd_delivery.orientation_portrait and
	     orientation <> fnd_delivery.orientation_landscape) then
	    return false;
	 end if;


         select count(*)
	     into cnt
	     from fnd_cp_ipp_printers
	     where delivery_id = printer_id;

         if (cnt = 0) then
	    return false;
	 end if;

         if (username is not null and password is not null) then
            svc_key := fnd_delivery.set_temp_credentials(username, password);
         end if;

         return add_delivery_option(type         => fnd_delivery.type_ipp_printer,
				    p_argument1  => printer_id,
				    p_argument2  => copies,
				    p_argument3  => orientation,
				    p_argument4  => username,
			    	    p_argument5  => null,
			    	    p_argument6  => svc_key,
				    nls_language => lang);


      end add_ipp_printer;



      function add_fax ( server_name   in varchar2,
		         fax_number    in varchar2,
		         username      in varchar2 default null,
	                 password      in varchar2 default null,
		         lang          in varchar2 default null) return boolean is

      server_id   number;

      begin

        select delivery_id
	    into server_id
	    from fnd_cp_ipp_printers
	    where ipp_printer_name = server_name;

        return add_fax(server_id, fax_number, username, password, lang);

      exception
	 when others then
	    return false;

      end add_fax;



      function add_fax ( server_id     in number,
		         fax_number    in varchar2,
		         username      in varchar2 default null,
	                 password      in varchar2 default null,
		         lang          in varchar2 default null) return boolean is
        cnt   number;
        svc_key varchar2(16) := null;

      begin

         if (server_id is null or fax_number is null) then
	    return false;
	 end if;

         select count(*)
	     into cnt
	     from fnd_cp_ipp_printers
	     where delivery_id = server_id
	     and support_fax = 'Y';

         if (cnt = 0) then
	    return false;
	 end if;

         if (username is not null and password is not null) then
            svc_key := fnd_delivery.set_temp_credentials(username, password);
         end if;

	 return add_delivery_option(type         => fnd_delivery.type_ipp_fax,
				    p_argument1  => server_id,
				    p_argument2  => fax_number,
				    p_argument3  => username,
				    p_argument4  => null,
				    p_argument5  => svc_key,
				    nls_language => lang);

      end add_fax;



      function add_ftp ( server     in varchar2,
		         username   in varchar2,
		         password   in varchar2,
		         remote_dir in varchar2,
		         port       in varchar2 default null,
		         secure     in boolean default FALSE,
		         lang       in varchar2 default null) return boolean is

        stype    varchar2(1) := fnd_delivery.type_ftp;
        svc_key varchar2(16) := null;

      begin

	 if (server is null or username is null or password is null or ((not secure) and remote_dir is null)) then
	    return false;
	 end if;

	 if (secure) then
	    stype := fnd_delivery.type_sftp;
	 end if;

	 svc_key := fnd_delivery.set_temp_credentials(username, password);

	 return add_delivery_option(type         => stype,
			  	    p_argument1  => server,
				    p_argument2  => username,
				    p_argument3  => null,
				    p_argument4  => remote_dir,
				    p_argument5  => port,
				    p_argument8  => svc_key,
				    nls_language => lang);

      end add_ftp;



     function add_webdav ( server     in varchar2,
                         remote_dir in varchar2,
                         port       in varchar2 default null,
		         username   in varchar2 default null,
		         password   in varchar2 default null,
		         authtype   in varchar2 default null,
                         enctype    in varchar2 default null,
    		         lang       in varchar2 default null) return boolean is
      svc_key varchar2(16) := null;
      begin

        if (server is null or remote_dir is null) then
            return false;
        end if;

        if (username is not null and password is not null) then
           svc_key := fnd_delivery.set_temp_credentials(username, password);
        end if;
        return add_delivery_option(type => fnd_delivery.type_webdav,
						p_argument1  => server,
						p_argument2  => remote_dir,
						p_argument3  => port,
						p_argument4  => username,
						p_argument5  => null,
                                                p_argument6  => authtype,
						p_argument7  => enctype,
						p_argument8  => svc_key,
						nls_language => lang);

      end add_webdav;


   function add_http (   server     in varchar2,
                         remote_dir in varchar2,
                         port       in varchar2 default null,
		         username   in varchar2 default null,
		         password   in varchar2 default null,
		         authtype   in varchar2 default null,
                         enctype    in varchar2 default null,
                         method     in varchar2 default null,
		         lang       in varchar2 default null) return boolean is

        svc_key varchar2(16) := null;
        begin

        if (server is null or remote_dir is null) then
            return false;
        end if;

        if (username is not null and password is not null) then
           svc_key := fnd_delivery.set_temp_credentials(username, password);
        end if;

        return add_delivery_option(type => fnd_delivery.type_http,
						p_argument1  => server,
						p_argument2  => remote_dir,
						p_argument3  => port,
						p_argument4  => username,
						p_argument5  => null,
                                                p_argument6  => authtype,
						p_argument7  => enctype,
                                                p_argument8  => method,
                                                p_argument9  => svc_key,
						nls_language => lang);

      end add_http;



    function add_custom ( custom_id  in number,
		          lang       in varchar2 default null) return boolean is

      cnt   number;

      begin

         if (custom_id is null) then
	    return false;
	 end if;

         select count(*)
	     into cnt
	     from fnd_cp_delivery_commands
	     where delivery_id = custom_id;

         if (cnt = 0) then
	    return false;
	 end if;

	 return add_delivery_option(type         => fnd_delivery.type_custom,
				    p_argument1  => custom_id,
				    nls_language => lang);

      end add_custom;


    function add_custom ( custom_name   in varchar2,
		         lang          in varchar2 default null) return boolean is

      custom_id   number;

      begin

        select delivery_id
	    into custom_id
	    from fnd_cp_delivery_options
	    where delivery_name = custom_name;

        return add_custom(custom_id, lang);

      exception
	 when others then
	    return false;

      end add_custom;

    function add_burst return boolean is

      begin

	 return add_delivery_option(type => fnd_delivery.type_burst);

      end add_burst;


  -- Bug5680619  5680669
  -- Name
  --   justify_program
  -- Purpose
  --   It lists all the disabled program in request set
  --   Call this function at the first step of the submission of a concurrent
  --   request set transaction.
  --   It returns a string containing all disabled program name based on
  --   the criticality
  -- Arguments
  --   template_appl_name   - Template application short name
  --   template_request_set_name        - Template Request Set Name

function justify_program(template_appl_name in varchar2,
                      template_request_set_name in varchar2)
return varchar2 is
cursor program_cursor is
select fcp.concurrent_program_name, frsp.critical
FROM fnd_request_set_programs frsp,
  fnd_concurrent_programs_vl fcp,
  fnd_request_sets_vl frs,
  fnd_application fa
WHERE fa.application_short_name = template_appl_name
 AND fa.application_id = frs.application_id
 AND frs.request_set_name = template_request_set_name
 AND frs.request_set_id = frsp.request_set_id
 AND frs.application_id = frsp.set_application_id
 AND frsp.program_application_id = fcp.application_id
 AND frsp.concurrent_program_id = fcp.concurrent_program_id
 AND fcp.srs_flag IN('Y',   'Q')
 AND fcp.enabled_flag = 'N'
 AND fcp.request_set_flag = 'N';

err_buf       varchar2(240) default('E');
warn_buf      varchar2(240) default('W');
err_flag      varchar2(1) default('N');
warn_flag      varchar2(1) default('N');
begin
for i in program_cursor
loop
  if i.critical = 'Y' then
      err_buf := err_buf||','||i.concurrent_program_name;
      err_flag := 'Y';
  else
      warn_buf := warn_buf||','||i.concurrent_program_name;
      warn_flag := 'Y';
  end if;
end loop;
  if err_flag = 'Y' then
    return err_buf;
  elsif warn_flag = 'Y' then
    return warn_buf;
  else
    return null;
  end if;
end;

end FND_SUBMIT;

/
