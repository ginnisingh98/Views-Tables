--------------------------------------------------------
--  DDL for Package FND_SUBMIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_SUBMIT" AUTHID CURRENT_USER as
/* $Header: AFCPRSSS.pls 120.6.12010000.7 2015/02/27 19:46:23 jtoruno ship $ */
/*#
 * This package contains the APIs for request set submission.
 * @rep:scope public
 * @rep:product FND
 * @rep:displayname Request Set Submission
 * @rep:category BUSINESS_ENTITY FND_CP_REQUEST_SET
 * @rep:lifecycle active
 * @rep:compatibility S
 */

--
-- Package
--   FND_SUBMIT
--
-- Purpose
--   Concurrent processing related utilities
--
-- History
--   11-SEP-98	Venkat 		Created
--

  --
  -- PUBLIC VARIABLES
  --

  -- Exceptions

  -- Exception Pragmas

  --
  -- PUBLIC FUNCTIONS
  --

  --
  -- Name
  --   set_mode
  -- Purpose
  --   Called before submitting request to set mode to 'database trigger'
  --
  -- Arguments
  --   db_trigger	- Set to TRUE for database trigger mode
  --
/*#
 * Sets the mode if the request is submitted from a database trigger
 * @param db_trigger Set to TRUE if the trigger is submitted from a database trigger
 * @return Returns TRUE on successful completion, FALSE otherwise
 * @rep:displayname Set Mode
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
  function set_mode (db_trigger  IN boolean) return boolean;

  --
  -- Name
  --   set_nls_options
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
  --
/*#
 * Sets request attributes (language-based attributes)
 * @param language The NLS language
 * @param territory The language territory
 * @return Returns TRUE on successful completion, otherwise FALSE
 * @rep:displayname Set NLS options
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
  --
  -- bug5676655/5709193
  --
  function set_nls_options( language  IN varchar2 default NULL,
                territory IN varchar2 default NULL,
                numeric_characters IN varchar2 default NULL,
                nls_sort IN varchar2 default 'BINARY' )
            return boolean;

  --
  -- Name
  --   set_repeat_options
  -- Purpose
  --   Called before submitting request if the request to be submitted
  --   is a repeating request.
  --
  -- Arguments
  --   repeat_time	- Time of day at which it has to be repeated
  --   repeat_interval  - Frequency at which it has to be repeated
  --			- This will be used/applied only when repeat_time
  --			- is NULL
  --   repeat_unit	- Unit for repeat interval. Default is DAYS
  --			- MONTHS/DAYS/HOURS/MINUTES
  --   repeat_type	- Apply repeat interval from START or END of request
  --			- default is START. START/END
  --   repeat_end_time  - Time at which the repetition should be stopped
  --
/*#
 * Sets the repeat options for the request set before submitting a concurrent request
 * @param repeat_time Time of the day at which request set is to be repeated
 * @param repeat_interval Frequency at which the request set has to be repeated
 * @param repeat_unit Unit for the repeat interval
 * @param repeat_type Specifies whether the repeat interval should apply from the start or end of the previous request
 * @param repeat_end_time Time at which the repetitions should end
 * @return Returns TRUE on successful completion, FALSE otherwise
 * @rep:displayname  Set Repeat Options
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
  function set_repeat_options (repeat_time	IN varchar2 default NULL,
			       repeat_interval	IN number   default NULL,
			       repeat_unit	IN varchar2 default 'DAYS',
			       repeat_type	IN varchar2 default 'START',
			       repeat_end_time	IN varchar2 default NULL,
                               recalc_parameters IN varchar2 default NULL)
			       return boolean;

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
  --   increment_dates   - 'Y' if date parameters should be incremented
  --                       each run, otherwise 'N'
  --
/*#
 * Sets the increment date parameters option for the request set before submitting a concurrent request
 * @param increment_dates 'Y' if date parameters should be incremented each run, otherwise 'N'
 * @rep:displayname  Set Increment Dates Option
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
  procedure set_increment_dates_option (increment_dates  IN varchar2);

  --
  -- Name
  --   set_recalc_parameters_dates_option
  -- Purpose
  --   Called before submitting request if the request to be submitted
  --   has a schedule set that repeats.  Making this available outside of
  --   set_repeat_options in case the repeating schedule is set with
  --   set_rel_class_options or fnd_conc_release_class_utils.assign_specific_sch
  --
  -- Arguments
  --   recalc_parameters  - 'Y' if parameters are to be recalculated
  --                       each run, otherwise 'N'
  --
/*#
 * Sets the recalculation parameters option for the request set before submitting a concurrent request
 * @param recalc_parameters 'Y' if parameters are to ve recalculated each run, otherwise 'N'
 * @rep:displayname  Set Recalc Parameters Option
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
  procedure set_recalc_parameters_option (recalc_parameters  IN varchar2);

  --
  -- Name
  --   set_rel_class_options
  -- Purpose
  --   Called before submitting request if the request to be submitted
  --   is using the new scheduler functionality.
  --
  -- Arguments
  --   application      - Application Name of Release Class
  --   class_name       - (Developer) Name of Release Class
  --   cancel_or_hold   - Cancel or hold flag
  --   stale_date       - Cancel request on or after this time if not run
  --
/*#
 * Sets some of the advanced scheduling features available in the concurrent processing system
 * @param application The short name of the application associated with the release class
 * @param class_name The developer name of the release class
 * @param cancel_or_hold Cancel or hold flag
 * @param stale_date Cancel this request after this date if the request has not yet run
 * @return Returns TRUE on successful completion, FALSE otherwise
 * @rep:displayname  Set Release Class Options
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
  function set_rel_class_options (application    IN varchar2 default NULL,
                                  class_name     IN varchar2 default NULL,
                                  cancel_or_hold IN varchar2 default 'H',
                                  stale_date     IN varchar2 default NULL)
                                  return boolean;

  --
  -- Name
  --   set_org_id
  -- Purpose
  --   Called before submitting request if the program is 'Sinle' multi org catagory.,
  --
  -- Arguments
  --   org_id		- Operating unit id
  --
  procedure set_org_id(org_id IN number default NULL);

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
  --
/*#
 * Sets request set print options like printer, print style, copies, etc. for a given request (context-sensitive)
 * @param printer Printer name for the output
 * @param style Print style to be used for printing
 * @param copies Number of copies to print
 * @param save_output Specify TRUE if the output should be saved after printing, FALSE Otherwise
 * @param print_together Applicable only to subrequests. If 'Y' the output will not be printed until all the sub-requests are completed. Default is 'N'
 * @rep:displayname  Set print options
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
  function set_print_options (printer	     IN varchar2 default NULL,
			      style	     IN varchar2 default NULL,
			      copies	     IN number	 default NULL,
			      save_output    IN boolean	 default TRUE,
			      print_together IN varchar2 default 'N')
			      return boolean;


  --
  -- Name
  --   add_printer
  -- Purpose
  --   Called after set print options to add a printer to the
  --   print list.
  --
  -- Arguments
  --   printer		- Printer name where the request o/p should be sent
  --   copies		- Number of copies to print
/*#
 * Adds printer to the printer list (context-sensitive, i.e. works on the request that is currently in context)
 * @param printer Printer name where the printer output should be sent
 * @param copies Number of copies to print
 * @return Returns TRUE on successful completion, FALSE otherwise
 * @rep:displayname  Add Printer
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
  function add_printer (printer in varchar2 default null,
                        copies  in number default null) return boolean;

  --
  -- Name
  --   add_notification
  -- Purpose
  --   Called before submission to add a user to the notify list.
  --
  -- Arguments
  --	User		- User name.
/*#
 * Adds user to the notification list of a particular request (context-sensitive i.e. works on the request currently in context)
 * @param user User name
 * @return Returns TRUE on successful completion, FALSE otherwise
 * @rep:displayname  Add Notification
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
  function add_notification (
  	user in varchar2,
  	on_normal  in varchar2 default 'Y',
  	on_warning in varchar2 default 'N',
  	on_error   in varchar2 default 'N' ) return boolean;


  -- --
  -- Name
  --   set_request_set
  -- Purpose
  --
  --   To set the request set context. Call this function at very
  --   beginning of the submission of a concurrent request set transaction.
  --   Call this function after calling the optional functions SET_MODE,
  --   SET_REL_CLASS_OPTIONS, SET_REPEAT_OPTIONS.
  --   It returns TRUE on sucessful completion, and FALSE otherwise.
  -- Arguments
  --   application	-  Application short name
  --   request_set	-  Developer Request set name
  --
/*#
 * Sets the request set context
 * @param request_set The short name of the request set
 * @param application The short name of the application that owns the request set
 * @return Returns TRUE on successful completion, FALSE otherwise
 * @rep:displayname Set Request Set Context
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
  function set_request_set      (
                                application IN varchar2,
                                request_set IN varchar2
                                )  return boolean;

  --
  -- Name
  --   submit_program
  -- Purpose
  --   Submits concurrent request for the program in the request set to be
  --   processed by a concurrent manager.
  --   Before calling this function you may want to call the optional functions
  --   SET_PRINT_OPTIONS, ADD_PRINTER, ADD_NOTIFICATION, SET_NLS_OPTIONS.
  --   Call submit_program for each program (report) in the request set.
  --   You must call set_request_set before calling this function. You have to
  --   call set_request_set only once for all the submit_program calls for that
  --   request set.
  --   This function returns TRUE on successful completion,
  --   and FALSE otherwise.
  --
  -- Arguments
  --   application	- Short name of application under which the program
  --			- is registered
  --   program		- concurrent program name for which the request has
  --			- to be submitted
  --   stage		- stage name for which the request has to be submitted
  --
  --   argument1..100	- Optional. Arguments for the concurrent request
  --
/*#
 * Submits a program for execution in the concurrent processing system
 * @param application The short name of the application associated with the program within a report set
 * @param program The short name of the program with the report set
 * @param stage The developer name of the request set stage that the program belongs to
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
 * @return Returns TRUE on successful completion, FALSE otherwise
 * @rep:displayname Submit Program
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
  function submit_program (
			  application IN varchar2 default NULL,
			  program     IN varchar2 default NULL,
			  stage	      IN varchar2 default NULL,
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
			  return boolean;

  -- --
  -- Name
  --   submit_set
  -- Purpose
  --   Call this function to submit the request set which is set by using the
  --   set_request_set.
  --   It will check whether each program in the request set is submitted
  --   by using submit_program or not.
  --   If the request completes successfully, this function returns the
  --   concurrent request ID of the parent request set; otherwise;
  --   it returns 0.
  -- Arguments
  --   None
/*#
 * Submits a request set for execution in the concurrent processing system
 * @param start_time The time at which the request should start running
 * @param sub_request Set to TRUE if the request is submitted from another request and should be treated as a sub-request
 * @return Returns the concurrent program ID on successful submission, otherwise it returns '0'
 * @rep:displayname  Message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
  function submit_set ( start_time IN varchar2 default null,
			sub_request In boolean default FALSE)
			return integer;

  procedure set_dest_ops(ops_id IN number default NULL);


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
                      output_format      in varchar2) return boolean;







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
				 nls_language in varchar2 default null) return boolean;


   function add_email (subject         in varchar2,
		       from_address    in varchar2,
		       to_address      in varchar2,
		       cc              in varchar2 default null,
		       lang            in varchar2 default null) return boolean;

   function add_ipp_printer (printer_name in varchar2,
			     copies       in number default null,
			     orientation  in varchar2 default null,
			     username     in varchar2 default null,
			     password     in varchar2 default null,
			     lang         in varchar2 default null) return boolean;



   function add_ipp_printer (printer_id   in number,
			     copies       in number default null,
			     orientation  in varchar2 default null,
			     username     in varchar2 default null,
			     password     in varchar2 default null,
			     lang         in varchar2 default null) return boolean;


   function add_fax ( server_name   in varchar2,
		      fax_number    in varchar2,
		      username      in varchar2 default null,
	              password      in varchar2 default null,
		      lang          in varchar2 default null) return boolean;


   function add_fax ( server_id     in number,
		      fax_number    in varchar2,
		      username      in varchar2 default null,
	              password      in varchar2 default null,
		      lang          in varchar2 default null) return boolean;


   function add_ftp ( server     in varchar2,
		      username   in varchar2,
		      password   in varchar2,
		      remote_dir in varchar2,
		      port       in varchar2 default null,
		      secure     in boolean default FALSE,
		      lang       in varchar2 default null) return boolean;

   function add_webdav ( server     in varchar2,
                         remote_dir in varchar2,
                         port       in varchar2 default null,
		         username   in varchar2 default null,
		         password   in varchar2 default null,
		         authtype   in varchar2 default null,
                         enctype    in varchar2 default null,
		         lang       in varchar2 default null) return boolean;

   function add_http (   server     in varchar2,
                         remote_dir in varchar2,
                         port       in varchar2 default null,
		         username   in varchar2 default null,
		         password   in varchar2 default null,
		         authtype   in varchar2 default null,
                         enctype    in varchar2 default null,
                         method     in varchar2 default null,
		         lang       in varchar2 default null) return boolean;

   function add_custom ( custom_id   in number,
		         lang        in varchar2 default null) return boolean;

   function add_custom ( custom_name   in varchar2,
		         lang          in varchar2 default null) return boolean;

   function add_burst return boolean;

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
                      template_request_set_name in varchar2) return varchar2;

end FND_SUBMIT;

/
