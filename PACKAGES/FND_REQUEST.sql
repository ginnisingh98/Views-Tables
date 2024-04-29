--------------------------------------------------------
--  DDL for Package FND_REQUEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_REQUEST" AUTHID CURRENT_USER as
/* $Header: AFCPREQS.pls 120.7.12010000.11 2015/01/26 21:20:43 jtoruno ship $ */
/*#
 * Contains concurrent processing related utilities
 * @rep:scope public
 * @rep:product FND
 * @rep:displayname Concurrent Request
 * @rep:category BUSINESS_ENTITY FND_CP_REQUEST
 * @rep:lifecycle active
 * @rep:compatibility S
 */

--
-- Package
--   FND_REQUEST
--
-- Purpose
--   Concurrent processing related utilities
--
-- History
--   XX-XXX-93	Ram Bhoopalam		Created
--   08-FEB-94	H Pelimuhandiram	Gave life
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
 * Called before submitting a request to set the database trigger mode
 * @param db_trigger Set to TRUE if the request is submitted from a database trigger
 * @return Returns TRUE on successful completion
 * @rep:displayname Set database trigger mode
 * @rep:scope public
 * @rep:lifecycle active
 */
  function set_mode (db_trigger  IN boolean) return boolean;
  pragma restrict_references (set_mode, WNDS, RNDS);

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
  --   nls_sort           - NLS_SORT environment variable
  --
/*#
 * Sets miscellaneous request options
 * @param implicit Determines whether to display the concurrent request in the end user's concurrent request form.
 * Takes values 'NO', 'YES','ERROR','WARNING'.
 * @param protected Specify 'YES' if the request is protected against updates, otherwise specify 'NO'
 * @param language Indicates NLS languages. Defaults to the current language if left NULL
 * @param territory Indicates language territory. Defaults to the current language territory if left NULL
 * @return Returns TRUE on successful completion,FALSE otherwise
 * @rep:displayname Set Request Options
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
  function set_options (implicit  IN varchar2 default 'NO',
		        protected IN varchar2 default 'NO',
		        language  IN varchar2 default NULL,
		        territory IN varchar2 default NULL,
		        datagroup IN varchar2 default NULL,
		        numeric_characters IN varchar2 default NULL,
		        nls_sort IN varchar2 default NULL )
			return boolean;
  pragma restrict_references (set_options, WNDS);


procedure set_dest_ops(ops_id IN number default NULL);

procedure set_org_id(org_id IN number default NULL);

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
 * Sets scheduling options for the concurrent request
 * @param repeat_time The time of the day to repeat the concurrent request
 * @param repeat_interval Interval between the re-submissions of the request
 * @param repeat_unit The unit of time used along with repeat_interval to specify the time between resubmissions of the request.
 * This parameter applies only when repeat_time is NULL.
 * @param repeat_type Determines whether to apply the re-submission interval from either the 'START' or the 'END' of the request's
 * execution. This parameter applies only when repeat_time is NULL.
 * @param repeat_end_time The date and time to stop resubmitting the concurrent request,
 * formatted as either 'DD-MON-YYYY HH24:MI:SS' or 'DD-MON-RR HH24:MI:SS'
 * @return Returns TRUE on successful completion, otherwise FALSE
 * @rep:displayname Set Repeat Options
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
  function set_repeat_options (repeat_time      IN varchar2 default NULL,
			       repeat_interval  IN number   default NULL,
			       repeat_unit      IN varchar2 default 'DAYS',
			       repeat_type      IN varchar2 default 'START',
			       repeat_end_time  IN varchar2 default NULL,
			       increment_dates IN varchar2 default NULL,
                               recalc_parameters IN varchar2 default NULL)
			       return boolean;
  pragma restrict_references (set_repeat_options, WNDS);

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
  --   incrment_dates   - 'Y' if dates should be incremented each run,
  --                      otherwise 'N'
  --
/*#
 * Sets the increment date parameters option for the concurrent request
 * @param increment_dates 'Y' if date parameters should be incremented each run, otherwise 'N'
 * @rep:displayname  Set Increment Dates Option
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
  procedure set_increment_dates_option (increment_dates  IN varchar2);
  pragma restrict_references (set_increment_dates_option, WNDS);


  --
  -- Name
  --   set_recalc_params_option
  -- Purpose
  --   Called before submission to submit a request and set the value
  --
  -- Arguments
  --   recalc_parameters   - 'Y' if recalculation is requested each run,
  --                      otherwise 'N'
  --
/*#
 * Sets the recalculate parameters option for the concurrent request
 * @param recalc_parameters 'Y' if recalculation is requested each run, otherwise 'N'
 * @rep:displayname  Set Recalc Parameters Option
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
  procedure set_recalc_parameters_option (recalc_parameters  IN varchar2);
  pragma restrict_references (set_recalc_parameters_option, WNDS);


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
  function set_rel_class_options (application    IN varchar2 default NULL,
                                  class_name     IN varchar2 default NULL,
                                  cancel_or_hold IN varchar2 default 'H',
                                  stale_date     IN varchar2 default NULL)
                                  return boolean;
  pragma restrict_references (set_rel_class_options, WNDS);

  -- Name
  --   set_target_options
  -- Purpose
  --   Called before submitting request to set target node and or connect
  --   string (instance) for the request.  Currently only primary target
  --   node and connect string are honored and the connect string must be
  --   the name of a RAC instance.
  --
  -- Arguments
  --   node_name1	- primary target node
  --   instance1        - primary target instance (connect string)
  --   node_name2	- secondary target node
  --   instance2        - secondary target instance (connect string)
  --
  -- --
  function set_target_options (node_name1  IN varchar2 default NULL,
		        instance1 IN varchar2 default NULL,
		        node_name2    IN varchar2 default NULL,
		        instance2 IN varchar2 default NULL)
			return boolean;

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
  --
/*#
 * Sets the print options for the concurrent request
 * @param printer The name of the printer to which the concurrent request output should to be sent
 * @param style Style used to print request output
 * @param copies Number of copies of the request output to print
 * @param save_output Indicates whether to save the output file
 * @param print_together This parameter applies only to those requests containing sub-requests.
 * 'Y' indicates that output of the sub-request should not be printed until all sub-requests complete.
 * 'N' indicates that output of the sub-request should be printed as it completes.
 * @param validate_printer Once submit function is called with a specific program, if the printer specified here conflicts with a printer setting at the program level, one of three options is available, with a default of RESOLVE
 * FAIL - raise an error and fail to submit
 * SKIP - skip this print pp action, but submit anyway
 * RESOLVE - switch to the valid printer, if printer and style are compatible
 * @return TRUE on successful completion, otherwise FALSE
 * @rep:displayname Set Print Options
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
  function set_print_options (printer	     IN varchar2 default NULL,
			      style	     IN varchar2 default NULL,
			      copies	     IN number	 default NULL,
			      save_output    IN boolean	 default TRUE,
                              print_together IN varchar2 default 'N',
                              validate_printer IN varchar2 default 'RESOLVE')
			      return boolean;
  pragma restrict_references (set_print_options, WNDS);


  --
  -- Name
  --   use_current_notification
  -- Purpose
  --   Called before submitting a sub-request to reuse the same notification
  --   options as the current request
  --
  -- Arguments
  --   none
  function use_current_notification return boolean;
  pragma restrict_references (use_current_notification, WNDS);


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
  function add_printer (printer in varchar2 default null,
                        copies  in number default null) return boolean;
  pragma restrict_references (add_printer, WNDS);

  function add_printer (printer in varchar2 default null,
                        copies  in number default null,
			lang    in varchar2) return boolean;
  pragma restrict_references (add_printer, WNDS);




  --
  -- Name
  --   add_notification
  -- Purpose
  --   Called before submission to add a user to the notify list.
  --
  -- Arguments
  --	User		- User name.

  -- Added an overload of the 1 parameter for function
  function add_notification (user          in varchar2) return boolean;
  pragma restrict_references (add_notification, WNDS);

  function add_notification (user          in varchar2,
		             nls_language  in varchar2) return boolean;
  pragma restrict_references (add_notification, WNDS);


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

  -- Added an overload of the 5 parameters for function
  function add_layout (template_appl_name in varchar2,
                        template_code     in varchar2,
                        template_language in varchar2,
                        template_territory in varchar2,
                        output_format     in varchar2
		        ) return boolean;

  function add_layout (template_appl_name in varchar2,
                        template_code     in varchar2,
                        template_language in varchar2,
                        template_territory in varchar2,
                        output_format     in varchar2,
		        nls_language      in varchar2) return boolean;



  --
  -- Name
  --   add_language
  -- Purpose
  --   Called before submission to submit a request in a particular language
  --   Can be called multiple times to submit a request in multiple languages
  --
  -- Arguments
  --	Lang		- Language
  --    Territory       - Territory
  --    Num_char        - Numeric characters
  --    Nls_sort        - NLS_SORT environment variable
  --
  function add_language (
               lang IN VARCHAR2,
               territory IN VARCHAR2,
               num_char IN VARCHAR2,
               nls_sort IN VARCHAR2 default 'BINARY') return boolean;



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
  --
  -- Name
  --   submit_request
  -- Purpose
  --   Submits concurrent request to be processed by a concurrent manager
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
  --   argument1..100	- Optional. Arguments for the concurrent request
  --
/*#
 * Submits a request for processing by a concurrent manager
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
 * @rep:displayname Submit Request
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
  function submit_request (
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
  pragma restrict_references (add_notification, WNDS);

  --
  -- Name
  --   submit_svc_ctl_request
  -- Purpose
  --   Submits Queue Control Request
  --   WARNING PERFORMS A COMMIT!!!
  --
  -- Arguments
  --   command		- concurrent program name for which the request has
  --			- to be submitted: ACTIVATE, DEACTIVATE, RESTART,
  --			- ABORT (ie. terminate), VERIFY, SUSPEND, or RESUME
  --   service		- Service instance or manager developer name.
  --   service_app	- manager or service instance's application short name

  function submit_svc_ctl_request (
			  command     IN varchar2,
			  service     IN varchar2,
			  service_app IN varchar2)
			  return number;

  --
  -- Name
  --   submit_svc_ctl_by_app
  -- Purpose
  --   Submits Queue Control Request
  --   WARNING PERFORMS A COMMIT!!!
  --
  -- Arguments
  --   command		- concurrent program name for which the request has
  --			- to be submitted: ACTIVATE, DEACTIVATE, RESTART,
  --			- ABORT (ie. terminate), VERIFY, SUSPEND, or RESUME
  --   service_app	- manager or service instance's application short name
  --   svc_type		- 0 = mgrs, 1= svcs, 2= both

  function submit_svc_ctl_by_app (
			  command     IN varchar2,
			  application IN varchar2,
			  svc_type    in NUMBER default 2)
			  return number;

  --
  -- Name
  --   submit_svc_ctl_by_svc
  -- Purpose
  --   Submits Queue Control Request
  --   WARNING PERFORMS A COMMIT!!!
  --
  -- Arguments
  --   command		- concurrent program name for which the request has
  --			- to be submitted: ACTIVATE, DEACTIVATE, RESTART,
  --			- ABORT (ie. terminate), VERIFY, SUSPEND, or RESUME
  --   service		- Service instance or manager developer name.

  function submit_svc_ctl_by_svc (
			  command     IN varchar2,
			  service     IN varchar2)
			  return number;

  --
  -- Name
  --   submit_svc_ctl_cpinfra
  -- Purpose
  --   Submits Queue Control Request
  --   WARNING PERFORMS A COMMIT!!!
  --
  -- Arguments
  --   command		- concurrent program name for which the request has
  --			- to be submitted: ACTIVATE, DEACTIVATE, RESTART,
  --			- ABORT (ie. terminate), VERIFY, SUSPEND, or RESUME
  --   service		- Service instance or manager developer name.
  --   service_app	- manager or service instance's application short name

  function submit_svc_ctl_cpinfra (
			  command     IN varchar2)
			  return number;

  --
  -- Name
  --   submit_svc_ctl_cpall
  -- Purpose
  --   Submits Queue Control Request
  --   WARNING PERFORMS A COMMIT!!!
  --
  -- Arguments
  --   command		- concurrent program name for which the request has
  --			- to be submitted: ACTIVATE, DEACTIVATE, RESTART,
  --			- ABORT (ie. terminate), VERIFY, SUSPEND, or RESUME

  function submit_svc_ctl_cpall (
			  command     IN varchar2)
			  return number;


  -- Name
  --   set_deferred
  -- Purpose
  --   Called before calling request submission page by other product teams
  --
  -- Arguments
  -- 	none
  --
  function set_deferred
  	return boolean;



  -- Name
  --   set_def_request_id
  -- Purpose
  --   Called for setting global request id and the request id will be used while creating actual request
  --
  -- Arguments
  -- 	request_id - used while creating actual request in fnd_concurrent_request
  --
  function set_def_request_id (
  					request_id IN number)
  	return boolean;


  -- Name
  --   get_fnd_debug_rules_sequence
  -- Purpose
  --   Called to obtain the next sequence value for fnd_debug_rules table
  --
  -- Arguments
  -- 	none
  --
  function get_fnd_debug_rules_sequence
        return number;


  -- Name
  --   update_fnd_debug_rules_req_id
  -- Purpose
  --   Called to set the request id for the specific fnd_debug_rule_id
  --
  -- Arguments
  -- 	debug_rule_id - the specific row in fnd_debug_rules to get updated
  -- 	request_id - the actual request id that debug options is being set for.
  --
  function update_fnd_debug_rules_req_id (
               req_id             IN number,
               fnd_debug_rule_id  IN number )
        return boolean;


  -- Name
  --   delete_fnd_debug_rules_id
  -- Purpose
  --   Called to delete the specific fnd_debug_rule_id from fnd_debug_rules
  --   and fnd_debug_rules_options
  --
  -- Arguments
  -- 	debug_rule_id - the specific sequence number to be deleted
  --
  function delete_fnd_debug_rules_id (
               fnd_debug_rule_id  IN number )
        return boolean;

  -- NAME
  --    get_num_char_for_terr
  -- Purpose
  --    Called to retrieve the num char associated with a territory
  --
  -- Arguments
  --    original_terr
  --    check_terr
  --
  function get_num_char_for_terr (
               original_terr  IN varchar2,
               check_terr     IN varchar2 )
        return varchar2;

  -- NAME
  --    validate_num_char_for_terr
  -- Purpose
  --    Called to validate the num char associated with a territory
  --
  -- Arguments
  --    num_char
  --
  function validate_num_char_for_terr (
               num_char  IN varchar2 )
        return boolean;

 FUNCTION INSERT_USER_SCHEDULE(P_RELEASE_CLASS_NAME IN VARCHAR2,
                              P_REQUESTED_START_DATE IN VARCHAR2,
                              P_REQUESTED_END_DATE IN VARCHAR2,
                              P_REPEAT_INTERVAL IN NUMBER,
                              P_REPEAT_INTERVAL_UNIT IN VARCHAR2,
                              P_REPEAT_INTERVAL_TYPE IN VARCHAR2,
                              P_CLASS_TYPE IN VARCHAR2,
                              P_CLASS_INFO IN VARCHAR2,
                              P_DESCRIPTION IN VARCHAR2,
                              P_ENABLED_FLAG IN VARCHAR2
                              ) return boolean;

FUNCTION UPDATE_USER_SCHEDULE(P_RELEASE_CLASS_NAME IN VARCHAR2,
                              P_REQUESTED_START_DATE IN VARCHAR2,
                              P_REQUESTED_END_DATE IN VARCHAR2,
                              P_REPEAT_INTERVAL IN NUMBER,
                              P_REPEAT_INTERVAL_UNIT IN VARCHAR2,
                              P_REPEAT_INTERVAL_TYPE IN VARCHAR2,
                              P_CLASS_TYPE IN VARCHAR2,
                              P_CLASS_INFO IN VARCHAR2,
                              P_DESCRIPTION IN VARCHAR2,
                              P_ENABLED_FLAG IN VARCHAR2
                              ) return boolean;

function delete_user_schedule(schName varchar2)
RETURN BOOLEAN;

end FND_REQUEST;

/
