--------------------------------------------------------
--  DDL for Package Body FND_MLS_SUBMIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_MLS_SUBMIT" as
/* $Header: AFCPMLSB.pls 120.2.12010000.3 2011/03/18 16:59:16 pferguso ship $ */

  procedure internal(critical in varchar2 default null,
                     type     in varchar2 default null) is
   begin
	   null;
   end;


  --
  -- Name
  --   submit_mls_request
  -- Purpose
  --   Submits mls concurrent request to be processed by a concurrent manager
  --
  -- Arguments
  --   application	- Short name of application under which the program
  --			- is registered
  --   program		- concurrent program name for which the request has
  --			- to be submitted
  --   description	- Optional. Will be displayed along with user
  --			- concurrent program name
  --   start_time	- Optional. Time at which the request has to start
  --			- running
  --   sub_request	- Optional. Set to TRUE if the request is submitted
  --   			- from another running request and has to be treated
  --			- as a sub request. Default is FALSE
  --   argument1..100	- Optional. Arguments for the mls concurrent request
  --

function submit_mls_request (
        application IN varchar2 default NULL,
        program     IN varchar2 default NULL,
        description IN varchar2 default NULL,
        start_time  IN varchar2 default NULL,
        sub_request IN boolean  default FALSE,
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
        argument100  IN varchar2 default CHR(0))
			  return number is


  begin
   return 0;
  end submit_mls_request;


  --
  -- Name
  --   add_notification
  -- Purpose
  --   Called before submission to add a user to the notify list.
  --   Added this new method since changing the add_notification will need
  --   generation of all calling forms.
  --   In a major release we can merge this one with previous one with default
  --   values.
  --
  -- Arguments
  --    User            - User name.
  --    on_normal       - Notify when normal completion (Values Y/N)
  --    on_warning      - Notify when request completes with warning (Y/N)
  --    on_error        - Notify when request completed with error (Y/N)

  function add_notification (user       in varchar2,
                             on_normal  in varchar2,
                             on_warning in varchar2,
                             on_error   in varchar2)
            return boolean is
  begin

       return FALSE;

  end;


  --
  -- Name
  --   add_notification
  -- Purpose
  --   Called before submission to add a user to the notify list.
  --
  -- Arguments
  --	User		- User name.

  function add_notification (user in varchar2) return boolean is
  begin

      return FALSE;
  end;


  --
  -- Name
  --   add_layout
  -- Purpose
  --   Called before submission to add layout options for request output.
  --
  -- Arguments
  --    Template_APPL_Name            - Template Application Short name.
  --    Template_code                 - Template code
  --    Template_Language             - Template File language (iso value)
  --    Template_Territory            - Template File Territory (iso value)
  --    Output Format                 - Output Format
  --

 function add_layout (template_appl_name in varchar2,
			template_code     in varchar2,
			template_language in varchar2,
 			template_territory in varchar2,
			output_format     in varchar2,
			nls_language in varchar2) return boolean is
  begin
      return (FALSE);
  end;


  --
  -- Name
  --   add_printer
  -- Purpose
  --   Called after set print options to add a printer to the
  --   print list.
  --
  -- Arguments
  --   printer	- Printer name where the request o/p should be sent
  --   copies		- Number of copies to print
  --   lang     - Language for o/p to print

  function add_printer (printer in varchar2 default null,
                        copies  in number default null,
                        lang in varchar2 default null) return boolean is
  begin
	    return (FALSE);

  end;

  --
  -- Name
  --   set_print_options
  -- Purpose
  --   Called before submitting request if the printing of output has
  --   to be controlled with specific printer/style/copies etc.,
  --
  -- Arguments
  --   printer		- Printer name where the request o/p should be sent
  --   style		- Print style that needs to be used for printing
  --   copies		- Number of copies to print
  --   save_output	- Should the output file be saved after printing
  --   			- Default is TRUE.  TRUE/FALSE
  --   print_together   - Applies only for sub requests. If 'Y', output
  --			- will not be printed until all the sub requests
  --			- complete. Default is N. Y/N
  --   validate_printer - Once submit function is called
  --                    - with a specific program, if the printer specified
  --                    - here conflicts with a printer setting at the
  --                    - program level, one of three options is available:
  --                    - FAIL - raise an error and fail to submit
  --                    - SKIP - skip this print pp action, but submit anyway
  --                    - RESOLVE - switch to the valid printer, if printer
  --                    - and style are compatible
  --                    - Default is RESOLVE
  --   lang   - Language to print the o/p

  function set_print_options (
            printer IN varchar2 default NULL,
			      style IN varchar2 default NULL,
			      copies IN number	 default NULL,
			      save_output IN boolean  default TRUE,
            print_together IN varchar2 default 'N',
            validate_printer IN varchar2 default 'RESOLVE',
            lang IN VARCHAR2 default NULL)
			      return  boolean is


  begin
	    return (FALSE);
  end set_print_options;


  --
  -- Name
  --   add_language
  -- Purpose
  --   Called to add language for request submission.
  --
  -- Arguments
  --	lang		  - Request Language
  --  territory - Request Territory
  --  num_char  - Request Numeric Characters

  function add_language (
               lang IN VARCHAR2,
               territory IN VARCHAR2,
               num_char IN VARCHAR2) return boolean is

  begin

    return(FALSE);

  end add_language;

  function set_options (
              implicit  IN varchar2 default 'NO',
              protected IN varchar2 default 'NO',
              language  IN varchar2 default NULL,
              territory IN varchar2 default NULL,
              datagroup IN varchar2 default NULL,
              numeric_characters IN varchar2 default NULL) return boolean is
    begin
        return(FALSE);

  end set_options;

  procedure set_dest_ops(ops_id IN number default NULL) is
  begin
     null;
  end;

  procedure set_org_id(org_id IN number default NULL) is
  begin
     null;
  end;

END FND_MLS_SUBMIT;

/
