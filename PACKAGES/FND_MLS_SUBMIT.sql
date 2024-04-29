--------------------------------------------------------
--  DDL for Package FND_MLS_SUBMIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_MLS_SUBMIT" AUTHID CURRENT_USER as
/* $Header: AFCPMLSS.pls 120.3 2008/05/02 09:33:54 ddhulla noship $ */
/*#
 * Contains concurrent processing related utilities
 * @rep:scope public
 * @rep:product FND
 * @rep:displayname Concurrent Request
 * @rep:category BUSINESS_ENTITY FND_CP_REQUEST
 * @rep:lifecycle active
 * @rep:compatibility S
 */


/*#
 * Submits a MLS request for processing by a concurrent manager
 * @param application Short name of the application associated with the concurrent request to be submitted
 * @param program Short name of the concurrent program for which the request should be submitted
 * @param description Description of the request that is displayed in the concurrent request's form
 * @param start_time Time at which the request should start running
 * @param sub_request Set to TRUE if the request is submitted from another request and should be treated as a sub-request
 * @param argument1 Argument for concurrent request
 * @param argument2 Argument for concurrent request
 * @param argument3 Argument for concurrent request
 * @param argument4 Argument for concurrent request
 * @param argument5 Argument for concurrent request
 * @param argument6 Argument for concurrent request
 * @param argument7 Argument for concurrent request
 * @param argument8 Argument for concurrent request
 * @param argument9 Argument for concurrent request
 * @param argument10 Argument for concurrent request
 * @param argument11 Argument for concurrent request
 * @param argument12 Argument for concurrent request
 * @param argument13 Argument for concurrent request
 * @param argument14 Argument for concurrent request
 * @param argument15 Argument for concurrent request
 * @param argument16 Argument for concurrent request
 * @param argument17 Argument for concurrent request
 * @param argument18 Argument for concurrent request
 * @param argument19 Argument for concurrent request
 * @param argument20 Argument for concurrent request
 * @param argument21 Argument for concurrent request
 * @param argument22 Argument for concurrent request
 * @param argument23 Argument for concurrent request
 * @param argument24 Argument for concurrent request
 * @param argument25 Argument for concurrent request
 * @param argument26 Argument for concurrent request
 * @param argument27 Argument for concurrent request
 * @param argument28 Argument for concurrent request
 * @param argument29 Argument for concurrent request
 * @param argument30 Argument for concurrent request
 * @param argument31 Argument for concurrent request
 * @param argument32 Argument for concurrent request
 * @param argument33 Argument for concurrent request
 * @param argument34 Argument for concurrent request
 * @param argument35 Argument for concurrent request
 * @param argument36 Argument for concurrent request
 * @param argument37 Argument for concurrent request
 * @param argument38 Argument for concurrent request
 * @param argument39 Argument for concurrent request
 * @param argument40 Argument for concurrent request
 * @param argument41 Argument for concurrent request
 * @param argument42 Argument for concurrent request
 * @param argument43 Argument for concurrent request
 * @param argument44 Argument for concurrent request
 * @param argument45 Argument for concurrent request
 * @param argument46 Argument for concurrent request
 * @param argument47 Argument for concurrent request
 * @param argument48 Argument for concurrent request
 * @param argument49 Argument for concurrent request
 * @param argument50 Argument for concurrent request
 * @param argument51 Argument for concurrent request
 * @param argument52 Argument for concurrent request
 * @param argument53 Argument for concurrent request
 * @param argument54 Argument for concurrent request
 * @param argument55 Argument for concurrent request
 * @param argument56 Argument for concurrent request
 * @param argument57 Argument for concurrent request
 * @param argument58 Argument for concurrent request
 * @param argument59 Argument for concurrent request
 * @param argument60 Argument for concurrent request
 * @param argument61 Argument for concurrent request
 * @param argument62 Argument for concurrent request
 * @param argument63 Argument for concurrent request
 * @param argument64 Argument for concurrent request
 * @param argument65 Argument for concurrent request
 * @param argument66 Argument for concurrent request
 * @param argument67 Argument for concurrent request
 * @param argument68 Argument for concurrent request
 * @param argument69 Argument for concurrent request
 * @param argument70 Argument for concurrent request
 * @param argument71 Argument for concurrent request
 * @param argument72 Argument for concurrent request
 * @param argument73 Argument for concurrent request
 * @param argument74 Argument for concurrent request
 * @param argument75 Argument for concurrent request
 * @param argument76 Argument for concurrent request
 * @param argument77 Argument for concurrent request
 * @param argument78 Argument for concurrent request
 * @param argument79 Argument for concurrent request
 * @param argument80 Argument for concurrent request
 * @param argument81 Argument for concurrent request
 * @param argument82 Argument for concurrent request
 * @param argument83 Argument for concurrent request
 * @param argument84 Argument for concurrent request
 * @param argument85 Argument for concurrent request
 * @param argument86 Argument for concurrent request
 * @param argument87 Argument for concurrent request
 * @param argument88 Argument for concurrent request
 * @param argument89 Argument for concurrent request
 * @param argument90 Argument for concurrent request
 * @param argument91 Argument for concurrent request
 * @param argument92 Argument for concurrent request
 * @param argument93 Argument for concurrent request
 * @param argument94 Argument for concurrent request
 * @param argument95 Argument for concurrent request
 * @param argument96 Argument for concurrent request
 * @param argument97 Argument for concurrent request
 * @param argument98 Argument for concurrent request
 * @param argument99 Argument for concurrent request
 * @param argument100 Argument for concurrent request
 * @return Returns requestid of submitted request, 0 if submission fails
 * @rep:displayname Submit MLS Request
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
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
			  return number;

-- This function is for AOL internal use only:
procedure internal(critical IN varchar2 default null,
                   type IN varchar2     default null);

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
  --   lang     - Language to print the o/p
function add_printer (printer in varchar2 default null,
                        copies  in number default null,
                        lang in varchar2 default null) return boolean;


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
  --			- complete. Default is 'N'. ( Y/N )
  --   validate_printer - Once submit function is called
  --                    - with a specific program, if the printer specified
  --                    - here conflicts with a printer setting at the
  --                    - program level, one of three options is available:
  --                    - FAIL - raise an error and fail to submit
  --                    - SKIP - skip this print pp action, but submit anyway
  --                    - RESOLVE - switch to the valid printer, if printer
  --                    - and style are compatible
  --                    - Default is RESOLVE
  --  lang   - Language to print the o/p

function set_print_options (printer	     IN varchar2 default NULL,
			      style	     IN varchar2 default NULL,
			      copies	     IN number	 default NULL,
			      save_output    IN boolean	 default TRUE,
            print_together IN varchar2 default 'N',
            validate_printer IN varchar2 default 'RESOLVE',
            lang in varchar2 default null)
			      return boolean;

 --
  -- Name
  --   set_options
  -- Purpose
  --   Called before submitting request to set request attributes
  --
  -- Arguments
  --   implicit		- nature of the request to be submitted
  --			- NO/YES/ERROR/WARNING
  --   protected	- Is the request protected against updates
  --			- YES/NO  default is NO
  --   language		- NLS language
  --   territory	- Language territory
  --   datagroup
  --   numeric_characters - NLS Numeric Characters
  --

function set_options (implicit  IN varchar2 default 'NO',
 		        protected IN varchar2 default 'NO',
 		        language  IN varchar2 default NULL,
 		        territory IN varchar2 default NULL,
 		        datagroup IN varchar2 default NULL,
 		        numeric_characters IN varchar2 default NULL)
 			return boolean;


  --
  -- Name
  --   add_notification
  -- Purpose
  --   Called before submission to add a user to the notify list.
  --
  -- Arguments
  --	User		- User name.

function add_layout (template_appl_name in varchar2,
                        template_code     in varchar2,
                        template_language in varchar2,
                        template_territory in varchar2,
                        output_format     in varchar2,
						nls_language in varchar2) return boolean;

  --
  -- Name
  --   add_notification
  -- Purpose
  --   Called before submission to add a user to the notify list.
  --
  -- Arguments
  --    User            - User name.
  --    on_normal       - Notify when normal completion (Values Y/N)
  --    on_warning      - Notify when request completes with warning (Y/N)
  --    on_error	- Notify when request completed with error (Y/N)
  function add_notification (user       in varchar2,
                             on_normal  in varchar2 ,
                             on_warning in varchar2 ,
                             on_error   in varchar2 ) return boolean;

  --   add_notification
  -- Purpose
  --   Called before submission to add a user to the notify list.
  --
  -- Arguments
  --	User		- User name.
  function add_notification (user in varchar2) return boolean;


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
               num_char IN VARCHAR2) return boolean;

procedure set_dest_ops(ops_id IN number default NULL);

procedure set_org_id(org_id IN number default NULL);

end FND_MLS_SUBMIT;

/
