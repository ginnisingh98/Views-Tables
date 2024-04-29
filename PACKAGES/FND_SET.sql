--------------------------------------------------------
--  DDL for Package FND_SET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_SET" AUTHID CURRENT_USER AS
/* $Header: AFRSSETS.pls 120.3.12010000.4 2014/01/18 15:52:01 ckclark ship $ */
/*#
 * Includes procedures for creating concurrentprogram request sets, adding programs to a request set, deletingprograms from a
 * request set, and defining parameters for request sets. If an error is detected, the "ORA-06501: PL/SQL: internal error" is raised.
 * The error message can be retrieved by a call to the functionfnd_set.message(). Some errors are not trapped by the package,
 * notably "duplicate value on index".
 * @rep:scope public
 * @rep:product FND
 * @rep:displayname Request Set
 * @rep:category BUSINESS_ENTITY FND_CP_REQUEST_SET
 * @rep:lifecycle active
 * @rep:compatibility S
 */

PROCEDURE debug_on ;


PROCEDURE debug_off ;

--
-- Procedure
--   SET_SESSION_MODE
--
-- Purpose
--   Sets the package mode for the current session.
--
-- Arguments:
--   session_mode - 'seed_data' if new data is for Datamerge.
--                  'customer_data' is the default.
--
PROCEDURE set_session_mode(session_mode IN VARCHAR2);


-- Function
--   MESSAGE
--
-- Purpose
--   Return an error message.  Messages are set when
--   validation (program) errors occur.
--
/*#
 * Use the message function to return an error message. Messages are set when any validation errors occur.
 * @return err_msg Returns error message
 * @rep:displayname Message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
FUNCTION message RETURN VARCHAR2 ;



-- Procedure
--   CREATE_SET
--
-- Purpose
--   Register a request set.
--
-- Arguments
--   name                - Name of request set.
--   short_name          - Short name.  Dev key.
--   application         - Short name of set's application.
--   description         - Optional description of the set.
--   owner               - Optional user ID of set owner. (e.g. SYSADMIN)
--   start_date          - Date set becomes effective.
--   end_date            - Optional date set becomes outdated.
--   print_together      - 'Y' or 'N'
--   incompatibilities_allowed - 'Y' or 'N'
--   language_code       - Language code for the above data. (e.g. US)
--
/*#
 * Registers a request set for use within the concurrent processing system
 * @param name The name of the new request set
 * @param short_name The short name of the request set
 * @param application The application that owns the request set
 * @param description An optional description of the set
 * @param owner An optional oracle application user ID identifying the set owner
 * @param start_date The date the set becomes effective
 * @param end_date An optional date on which the set becomes outdated
 * @param print_together Specify 'Y' or 'N' to indicate whether all the reports in a set should print at the same time
 * @param incompatibilities_allowed Specify 'Y' or 'N' to indicate whether to allow incompatibilities for this set
 * @param language_code Language code for the above data
 * @param recalc_parameters Specify 'Y' or 'N' to indicate whether parameters should be re-defaulted on copy or resubmission
 * @rep:displayname  Create Request Set
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
PROCEDURE create_set(  name                          IN VARCHAR2,
                       short_name                    IN VARCHAR2,
	      	       application	     	     IN VARCHAR2,
	               description                   IN VARCHAR2 DEFAULT NULL,
	               owner 	                     IN VARCHAR2 DEFAULT NULL,
	               start_date                    IN DATE   DEFAULT SYSDATE,
	               end_date                      IN DATE     DEFAULT NULL,
	               print_together                IN VARCHAR2 DEFAULT 'N',
                       incompatibilities_allowed     IN VARCHAR2 DEFAULT 'N',
                       recalc_parameters             IN VARCHAR2 DEFAULT 'N',
                       language_code                 IN VARCHAR2 DEFAULT 'US');



-- Procedure
--   Incompatibility
--
-- Purpose
--   Register an incompatibility for a set or stage.
--
--   Examples:
--     1. Set X is incompatible with program Y
--        fnd_set.incompatibility(request_set=>'X',
--                                application=>'APPX',
--                                inc_prog_short_name=>'Y',
--                                inc_prog_application=>'APPY');
--
--     2. Set X is incompatible withset Y.
--        fnd_set.incompatibility(request_set=>'X',
--                                application=>'APPX',
--                                inc_request_set=>'Y',
--                                inc_set_application=>'APPY');
--
--     3. Set X is incompatible with stage 2 of set Y.
--        fnd_set.incompatibility(request_set=>'X',
--                                application=>'APPX',
--                                inc_request_set=>'Y',
--                                inc_set_application=>'APPY',
--                                inc_stage_number=>2);
--
--     4. Stage 3 of set X is incompatable with program Y.
--        fnd_set.incompatibility(request_set=>'X',
--                                application=>'APPX',
--                                stage_number=>3,
--                                inc_prog_short_name=>'Y',
--                                inc_prog_application=>'APPY');
--
--
-- Arguments
--   request_set         - Request set short name.
--   application         - Application short name of request set.
--   stage               - Stage short name (for stage incompatibility).
--   inc_prog            - Short name of the incompatible program.
--   inc_prog_application- Application of the incompatible program.
--   inc_request_set     - Sort name of the incompatible reuqest set.
--   inc_set_application - Applicaiton short name of the incompatible set.
--   inc_stage           - Stage short name to the incompatible stage.
--   inc_type            - Incompatibility type - (D)omain-specific or (G)lobal
--
/*#
 * Registers an incompatibility for a set or a stage
 * @param request_set The short name of the request set
 * @param application The short name of the application that owns the request set
 * @param stage The short name of the stage
 * @param inc_prog The short name of the incompatible program
 * @param inc_prog_application The short name of the application that owns the incompatible program
 * @param inc_request_set The short name of the incompatible request set
 * @param inc_set_application The short name of the application that owns the incompatible request set
 * @param inc_stage The short name of the incompatible stage
 * @param inc_type The type of incompatibility. 'D' if Domain-specific, 'G' if Global.
 * @rep:displayname Register Incompatibility
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
PROCEDURE incompatibility(request_set              IN VARCHAR2,
		  	  application   	   IN VARCHAR2,
                          stage                    IN VARCHAR2 DEFAULT NULL,
			  inc_prog                 IN VARCHAR2 DEFAULT NULL,
			  inc_prog_application     IN VARCHAR2 DEFAULT NULL,
                          inc_request_set          IN VARCHAR2 DEFAULT NULL,
                          inc_set_application      IN VARCHAR2 DEFAULT NULL,
                          inc_stage                IN VARCHAR2 DEFAULT NULL,
			  inc_type                 IN VARCHAR2 DEFAULT 'D');



-- Procedure
--   ADD_STAGE
--
-- Purpose
--   Add a stage to a request set.
--
-- Arguments
--   name                 - Stage name.
--   request_set          - Short name of request set.
--   set_application      - Application short name of the request_set.
--   short_name           - Stage short (non-translated) name.
--   description          - Stage description.
--   display_sequence     - Display sequence.
--   function_short_name  - Function (executable) short name.
--   function_application - Function application short name.
--   critical             - Is this a "critical" stage?  (Use in set outcome.)
--   incompatibilities_allowed - 'Y' or 'N'
--   start_stage          - Is this the start stage for the set? 'Y' or 'N'
--   language_code       - Language code for the above data. (e.g. US)
--
/*#
 * Adds a stage to a request set
 * @param name Name of the stage
 * @param request_set The short name of the request set
 * @param set_application The short name of the application that owns the request set
 * @param short_name The short name of the stage
 * @param description The description of the stage
 * @param display_sequence The display sequence
 * @param function_short_name Accept the default, 'FNDRSSTE', the Standard Stage Evaluation function
 * @param function_application Accept the default, 'FND'
 * @param critical Specify 'Y' if the return value of the stage affects the completion status of the request set
 * @param incompatibilities_allowed Specify 'Y' or 'N' to allow the incompatibilities for this program or not
 * @param start_stage Specify 'Y' or 'N' to indicate whether this stage is the start stage for the set
 * @param language_code The language code for the above data
 * @rep:displayname  Add Stage to Request Set
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
PROCEDURE add_stage(name                          IN VARCHAR2,
	            request_set                     IN VARCHAR2,
	            set_application	              IN VARCHAR2,
                    short_name                    IN VARCHAR2,
                    description                   IN VARCHAR2 DEFAULT NULL,
                    display_sequence              IN NUMBER,
                    function_short_name           IN VARCHAR2
							DEFAULT 'FNDRSSTE',
                    function_application          IN VARCHAR2 DEFAULT 'FND',
                    critical                      IN VARCHAR2 DEFAULT 'N',
                    incompatibilities_allowed     IN VARCHAR2 DEFAULT 'N',
                    start_stage                   IN VARCHAR2 DEFAULT 'N',
                    language_code                 IN VARCHAR2 DEFAULT 'US'
                    );


-- Procedure
--   Link_Stages
--
-- Purpose
--   Link Two Stages.
--
-- Arguments
--   request_set         - Short name of request set.
--   set_application     - Application of the request set.
--   from_stage          - From stage short name.
--   to_stage            - To stage short name. (null to erase a link)
--   success             - Create success link. 'Y' or 'N'
--   warning             - Create warning link. 'Y' or 'N'
--   error               - Create error link. 'Y' or 'N'
--
/*#
 * Links two stages in a given request set
 * @param request_set The short name of the request set
 * @param set_application The short name of the application that owns the request set
 * @param from_stage The short name of the 'from' stage
 * @param to_stage The short name of the 'to' stage
 * @param success Create success link, specify 'Y' or 'N'
 * @param warning Create warning link, specify 'Y' or 'N'
 * @param error Create error link, specify 'Y' or 'N'
 * @rep:displayname  Link Stages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
procedure link_stages (request_set varchar2,
                       set_application varchar2,
                       from_stage varchar2,
                       to_stage varchar2 default null,
                       success varchar2 default 'N',
                       warning varchar2 default 'N',
                       error varchar2 default 'N');


-- Procedure
--   ADD_PROGRAM
--
-- Purpose
--   Add a concurrent program to a request set stage.
--
-- Arguments
--   program             - Short name of the program. (e.g. FNDSCRMT)
--   program_application - Application short name of the program.(e.g. 'FND')
--   request_set         - Short name of request set.
--   set_application     - Application of the request set.
--   stage               - Stage short name.
--   program_sequence    - Must be unique!
--   critical            - Can this program affect the stage outcome?
--   number_of_copies    - Copies to Print. (optional)
--   save_output         - 'Y' or 'N'
--   style               - Print style name. (optional)
--   printer             - Printer name. (optional)
--
/*#
 * Adds a concurrent program to a stage in a given request set
 * @param program The short name that is used as the developer name of the concurrent program
 * @param program_application The short name of the application that owns the concurrent program
 * @param request_set The short name of the request set
 * @param set_application The application that owns the request set
 * @param stage The short name of the stage
 * @param program_sequence The sequence number of this program in the stage
 * @param critical Specify 'Y' if this program can affect the stage's outcome
 * @param number_of_copies An optional default for the number of copies to print
 * @param save_output Specify 'Y' to allow users to save output
 * @param style Optionally provide a default print style
 * @param printer Optionally provide a default printer
 * @rep:displayname Add Program
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
PROCEDURE add_program(program                      IN VARCHAR2,
	             program_application	   IN VARCHAR2,
	             request_set                   IN VARCHAR2,
	             set_application               IN VARCHAR2,
                     stage                         IN VARCHAR2,
                     program_sequence              IN NUMBER,
                     critical                      IN VARCHAR2 DEFAULT 'Y',
                     number_of_copies              IN NUMBER   DEFAULT 0,
                     save_output                   IN VARCHAR2 DEFAULT 'Y',
                     style                         IN VARCHAR2 DEFAULT NULL,
                     printer                       IN VARCHAR2 DEFAULT NULL);


-- Procedure
--   REMOVE_STAGE
--
-- Purpose
--   Remove a stage from a request set.
--
-- Arguments
--   request_set         - Short name of request set.
--   set_application     - Application short name of the request set.
--   stage               - Stage short name.
--
/*#
 * Removes a Stage from a given request set
 * @param request_set The short name of the request set
 * @param set_application The short name of the application that owns the request set
 * @param stage The short name of the stage
 * @rep:displayname Remove Stage
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
PROCEDURE remove_stage(request_set                 IN VARCHAR2,
		       set_application             IN VARCHAR2,
                       stage                       IN VARCHAR2);



-- Procedure
--   REMOVE_PROGRAM
--
-- Purpose
--   Remove a concurrent program from a request set.
--
-- Arguments
--   program             - Short name of the program. (e.g. FNDSCRMT)
--   program_application - Application of the program. (e.g. 'FND')
--   request_set         - Short name of request set.
--   set_application     - Application short name of the request set.
--   stage               - Stage short name.
--   program_sequence    - Program sequence number.
--
/*#
 * Removes a concurrent program from a stage in a request set
 * @param program The short name used as the developer name of the concurrent program
 * @param program_application The short name of the application that owns the program
 * @param request_set The short name of the request set
 * @param set_application The short name of the application that owns the request set
 * @param stage The short name of the stage
 * @param program_sequence The sequence number of this program in the stage
 * @rep:displayname Remove Program
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
PROCEDURE remove_program(program                      IN VARCHAR2,
	                  program_application         IN VARCHAR2,
	                  request_set                 IN VARCHAR2,
		          set_application             IN VARCHAR2,
                          stage                       IN VARCHAR2,
                          program_sequence            IN NUMBER);



-- Procedure
--   PROGRAM_PARAMETER
--
-- Purpose
--   Register a parameter for a request set program
--
-- Arguments:
--   program            - e.g. FNDSCRMT
--   application        - Program application. e.g.'FND'
--   request_set        - Short name of request set.
--   set_application    - Application short name of the request set.
--   stage              - Stage_short_name.
--   program_sequence   - Program sequence number.
--   parameter          - Name of the program parameter.  (NOT the prompt!)
--   display            - 'Y' or 'N'
--   modify             - 'Y' or 'N'
--   shared_parameter   - Name of shared parameter. (optional)
--   default_type       - 'Constant', 'Profile', 'SQL Statement', 'Segment'
--                        (Optional)
--   default_value      - Parameter default (Required if default_type is not
--                        Null)
--
/*#
 * Registers the shared parameter information and the request set level overrides of program parameter attributes
 * @param program The short name used as the developer name of the concurrent program
 * @param program_application The short name of the application that owns the concurrent program
 * @param request_set The short name of the request set
 * @param set_application The short name of the application that owns the request set
 * @param stage The short name of the stage
 * @param program_sequence The sequence number of this program in the stage
 * @param parameter The name of the program parameter
 * @param display Specify 'Y' to display parameter, and 'N' to hide it
 * @param modify Specify 'Y' to allow users to modify the parameter value, and 'N'  to prevent it
 * @param shared_parameter If the parameter uses a shared parameter enter the shared parameter name here
 * @param default_type If the parameters uses a default, enter the type here
 * @param default_value If the parameter uses a default, enter a value appropriate for the default here
 * @rep:displayname Register program parameter
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
PROCEDURE program_parameter(
	program                       IN VARCHAR2,
	program_application           IN VARCHAR2,
	request_set                   IN VARCHAR2,
	set_application               IN VARCHAR2,
        stage                         IN VARCHAR2,
        program_sequence              IN NUMBER,
	parameter                     IN VARCHAR2,
	display                       IN VARCHAR2 DEFAULT 'Y',
	modify                        IN VARCHAR2 DEFAULT 'Y',
	shared_parameter              IN VARCHAR2 DEFAULT NULL,
	default_type                  IN VARCHAR2 DEFAULT NULL,
	default_value                 IN VARCHAR2 DEFAULT NULL);




-- Procedure
--   ADD_SET_TO_GROUP
--
-- Purpose
--   Add a request set to a request group.
--
-- Arguments
--   request_set         - Short name of set.
--   set_application     - Application short name of the set.
--   request_group       - Name of request group.
--   group_application   - Application of the request group.
--
/*#
 * Adds a request set to a specific request group
 * @param request_set The short name of the request set to add to request group
 * @param set_application The short name of the application that owns the request set
 * @param request_group The request group to which the request set has to be added
 * @param group_application The application that owns the request group
 * @rep:displayname  Add Request Set to Group
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
PROCEDURE add_set_to_group(request_set             IN VARCHAR2,
	                   set_application	   IN VARCHAR2,
	                   request_group           IN VARCHAR2,
		           group_application       IN VARCHAR2);



-- Procedure
--   REMOVE_SET_FROM_GROUP
--
-- Purpose
--   Remove a set from a request group.
--
-- Arguments
--   request_set         - Short name of set.
--   set_application     - Application short name of the set.
--   request_group       - Name of request group.
--   group_application   - Application of the request group.
--
/*#
 * Removes request set from a specific request group
 * @param request_set The short name of the request set to remove from the request group
 * @param set_application The application that owns the request group
 * @param request_group The request group from the request set has to be removed
 * @param group_application The application that owns the request group
 * @rep:displayname  Remove Set from Group
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
PROCEDURE remove_set_from_group(request_set         IN VARCHAR2,
	                        set_application	    IN VARCHAR2,
	                        request_group       IN VARCHAR2,
		                group_application   IN VARCHAR2);




-- Procedure
--   DELETE_PROGRAM_PARAMETER
--
-- Purpose
--   Delete a concurrent program request set parameter.
--
-- Arguments
--   program             - Short name of the program. (e.g. FNDSCRMT)
--   program_application - Application short name of the program. (e.g. 'FND')
--   request_set         - Short name of request set.
--   set_application     - Application short name of the request set.
--   stage               - Stage short name.
--   program_sequence    - Program sequence number.
--   parameter           - Name of the program parameter. (NOT the prompt!)
--
/*#
 * Removes a concurrent request parameter for a program in a request set
 * @param program The short name used as the developer name of the program
 * @param program_application The short name of the application that owns the program
 * @param request_set The short name of the request set
 * @param set_application The short name of the application that owns the request set
 * @param stage The short name of the stage
 * @param program_sequence The sequence number of this program in the stage
 * @param parameter The name of the program parameter to delete
 * @rep:displayname Delete program parameter
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
PROCEDURE delete_program_parameter(program               IN VARCHAR2,
	                       program_application   IN VARCHAR2,
	                       request_set           IN VARCHAR2 DEFAULT NULL,
                               stage                 IN VARCHAR2,
	                       set_application       IN VARCHAR2,
                               program_sequence      IN NUMBER,
                               parameter             IN VARCHAR2);



-- Procedure
--   DELETE_SET
--
-- Purpose
--   Delete a request set, and references to that set.
--
-- Arguments
--   request_set     - Short name of the set.
--   application     - Application short name of the set.
--
/*#
 * Deletes a Request Set from the concurrent processing system
 * @param request_set The short name of the request set to delete
 * @param application The short name of the application that owns the request set
 * @rep:displayname Delete Request Set
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
PROCEDURE delete_set(request_set         IN VARCHAR2,
	             application    	 IN VARCHAR2);




-- Procedure
--   DELETE_INCOMPATIBILITY
--
-- Purpose
--   Delete a request set incompatibility rule.
--
-- Arguments
--   request_set         - Short name of the request set.
--   application         - Application short name of the request set.
--   stage               - Stage short name (for stage incompatibility).
--   inc_prog            - Short name of the incompatible program.
--   inc_prog_application- Application of the incompatible program.
--   inc_request_set     - Sort name of the incompatible reuqest set.
--   inc_set_application - Application short name of the incompatible set.
--   inc_stage           - Stage short name the incompatible stage.
--
-- See examples from fnd_set.incompatibility() for argument usage.
--
/*#
 * Deletes a request incompatibility rule
 * @param request_set The short name of the request set
 * @param application The short name of the application that owns the request set
 * @param stage The short name of the stage
 * @param inc_prog The short name of the incompatible program
 * @param inc_prog_application The short name of the application that owns the incompatible program
 * @param inc_request_set The short name of the incompatible request set
 * @param inc_set_application The short name of the application that owns the incompatible request set
 * @param inc_stage The short name of the incompatible stage
 * @rep:displayname Delete Incompatibility
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
PROCEDURE delete_incompatibility(request_set          IN VARCHAR2,
		  	         application   	      IN VARCHAR2,
                                 stage                IN VARCHAR2 DEFAULT NULL,
			         inc_prog             IN VARCHAR2 DEFAULT NULL,
			         inc_prog_application IN VARCHAR2 DEFAULT NULL,
                                 inc_request_set      IN VARCHAR2 DEFAULT NULL,
                                 inc_set_application  IN VARCHAR2 DEFAULT NULL,
                                 inc_stage            IN VARCHAR2 DEFAULT NULL);



-- Function
--   INCOMPATIBILITY_EXISTS
--
-- Purpose
--   Return TRUE if an incompatibility exists.
--
-- Arguments
--   request_set         - Short name of the request set.
--   application         - Application short name of the request set.
--   stage               - Stage number (for stage incompatibility).
--   inc_prog            - Short name of the incompatible program.
--   inc_prog_application- Application of the incompatible program.
--   inc_request_set     - Sort name of the incompatible reuqest set.
--   inc_set_application - Application short name of the incompatible set.
--   inc_stage           - Stage number to the incompatible stage.
--
-- See examples from fnd_set.incompatibility() for argument usage.
--
FUNCTION  incompatibility_exists(request_set          IN VARCHAR2,
		  	         application   	      IN VARCHAR2,
                                 stage                IN VARCHAR2 DEFAULT NULL,
			         inc_prog             IN VARCHAR2 DEFAULT NULL,
			         inc_prog_application IN VARCHAR2 DEFAULT NULL,
                                 inc_request_set      IN VARCHAR2 DEFAULT NULL,
                                 inc_set_application  IN VARCHAR2 DEFAULT NULL,
                                 inc_stage            IN VARCHAR2 DEFAULT NULL)
return boolean;



-- Function
--   REQUEST_SET_EXISTS
--
-- Purpose
--   Returns TRUE if a request set exists.
--
-- Arguments
--   request_set - Short name of the set.
--   application - Application short name of the request set.
--
FUNCTION request_set_exists(request_set    IN VARCHAR2,
	             	    application    IN VARCHAR2) RETURN BOOLEAN;


-- Function
--   STAGE_IN_SET
--
-- Purpose
--   Return TRUE if a stage is in a request set.
--
-- Arguments
--   stage               - Stage short name.
--   request_set         - Short name of request set.
--   set_application     - Application short name of the request set.
--   program_sequence    - Program sequence number.
--
FUNCTION stage_in_set(stage                  IN VARCHAR2,
	              request_set            IN VARCHAR2,
		      set_application        IN VARCHAR2)
                                                           RETURN BOOLEAN;


-- Function
--   PROGRAM_IN_STAGE
--
-- Purpose
--   Return TRUE if a program is in a request set stage.
--
-- Arguments
--   program             - Short name of the program.
--   program_application - Application short name of the program.
--   request_set         - Short name of request set.
--   set_application     - Application short name of the request set.
--   stage               - Stage short name.
--   program_sequence    - Program sequence number.
--
FUNCTION program_in_stage(program                IN VARCHAR2,
	                  program_application    IN VARCHAR2,
	                  request_set            IN VARCHAR2,
		          set_application        IN VARCHAR2,
                          stage                  IN VARCHAR2,
                          program_sequence       IN NUMBER)
                                                           RETURN BOOLEAN;


-- Function
--   PROGRAM_PARAMETER_EXISTS
--
-- Purpose
--   Return TRUE if a parameter has been registered for a request set.
--
-- Arguments
--   program             - Short name of the program.
--   program_application - Application short name of the program.
--   request_set         - Short name of request set.
--   set_application     - Application short name of the request set.
--   stage               - Stage short name.
--   program_sequence    - Program sequence number.
--   parameter           - Name of the program parameter. (NOT the prompt!)
--
FUNCTION program_parameter_exists(program          IN VARCHAR2,
	                      program_application  IN VARCHAR2,
	                      request_set          IN VARCHAR2,
	                      set_application      IN VARCHAR2,
                              stage                IN VARCHAR2,
                              program_sequence     IN NUMBER,
                              parameter            IN VARCHAR2)
			                                       RETURN BOOLEAN;


-- Function
--   SET_IN_GROUP
--
-- Purpose
--   Return TRUE if a request set is in a request group.
--
-- Arguments
--   request_set         - Short name of set.
--   set_application     - Application short name of the set.
--   request_group       - Name of request group.
--   group_application   - Application of the request group.
--
FUNCTION set_in_group(request_set    	 IN VARCHAR2 DEFAULT NULL,
	              set_application	 IN VARCHAR2,
	              request_group      IN VARCHAR2,
		      group_application  IN VARCHAR2)
                                                     RETURN BOOLEAN;

-- Procedure
--   STAGE_FUNCTION
--
-- Purpose
--   Register a request set stage function.
--
-- Arguments
--   function_name       - Name of function.  (e.g. 'My Function')
--   application         - Short name of function's application.
--                        (e.g. 'FND')
--   short_name          - Short (non-translated) name of the function.
--   description         - Optional description of the function.
--   plsql_name 	 - Name of pl/sql stored function.
--   icon_name           - For future web interface. Use null for now.
--   language_code       - Language code for the name and description.
--                         (e.g. 'US')
--
PROCEDURE stage_function(function_name               IN VARCHAR2,
	                 application	     	     IN VARCHAR2,
                         short_name                  IN VARCHAR2,
	                 description                 IN VARCHAR2 DEFAULT NULL,
		         plsql_name                  IN VARCHAR2,
                         icon_name                   IN VARCHAR2 DEFAULT NULL,
                         language_code               IN VARCHAR2 DEFAULT 'US');


-- Function
--   FUNCTION_EXISTS
--
-- Purpose
--   Return TRUE if a stage function exists.
--
-- Arguments
--   funct       - Short name of the function.
--   application - Application short name of the function.
--
FUNCTION function_exists(function_short_name IN VARCHAR2,
	         	 application	     IN VARCHAR2) RETURN BOOLEAN;


-- Function
--   DELETE_FUNCTION
--
-- Purpose
--   Delete a stage function.
--
-- Arguments
--   function_short_name  - Short name of the function.
--   application - Application short name of the function.
--
PROCEDURE delete_function(function_short_name  IN VARCHAR2,
	         	  application	       IN VARCHAR2);


-- Function
--   FUNCTION_IN_GROUP
--
-- Purpose
--   Return TRUE if a stage is in a request group.
--
-- Arguments
--   function_short_name - Short name of set.
--   function_application - Application short name of the function.
--   request_group       - Name of request group.
--   group_application   - Application of the request group.
--
FUNCTION function_in_group(function_short_name  IN VARCHAR2,
	                   function_application IN VARCHAR2,
	                   request_group        IN VARCHAR2,
		           group_application    IN VARCHAR2)
                                                     RETURN BOOLEAN;

-- Function
--   ADD_FUNCTION_TO_GROUP
--
-- Purpose
--   Adds a stage function to a request_group.
--
-- Arguments
--   function_short_name - Short name of set.
--   function_application - Application short name of the function.
--   request_group       - Name of request group.
--   group_application   - Application of the request group.
--
procedure add_function_to_group(function_short_name  IN VARCHAR2,
	                        function_application IN VARCHAR2,
	                        request_group        IN VARCHAR2,
		                group_application    IN VARCHAR2);


-- Function
--   REMOVE_FUNCTION_FROM_GROUP
--
-- Purpose
--   Removes a stage function from a request_group.
--
-- Arguments
--   function_short_name - Short name of set.
--   function_application - Application short name of the function.
--   request_group       - Name of request group.
--   group_application   - Application of the request group.
--
procedure remove_function_from_group(function_short_name  IN VARCHAR2,
	                             function_application IN VARCHAR2,
	                             request_group        IN VARCHAR2,
		                     group_application    IN VARCHAR2);


-- Procedure
--   FUNCTION_PARAMETER
--
-- Purpose
--   Register a request set stage function parameter.
--
-- Arguments
--   function_short_name - Short (non-translated) name of the function.
--   application         - Short name of function's application.
--                        (e.g. 'FND')
--   paramter_name       - Displayed name of parameter.
--   parameter_short_name - Short (non-translated) name of parameter.
--   description         - Optional description of the function.
--   language_code       - Language code for the name and description.
--                         (e.g. 'US')
--
PROCEDURE function_parameter(function_short_name     IN VARCHAR2,
	                     application	     IN VARCHAR2,
                             parameter_name          IN VARCHAR2,
                             parameter_short_name    IN VARCHAR2,
	                     description             IN VARCHAR2 DEFAULT NULL,
                             language_code           IN VARCHAR2 DEFAULT 'US');


-- Function
--   FUNCTION_PARAMETER_EXISTS
--
-- Purpose
--   Return TRUE if a stage function parameter exists.
--
-- Arguments
--   function_short_name  - Short name of the function.
--   application - Application short name of the function.
--   parameter   - Short (non-translated) name of parameter.
--
FUNCTION function_parameter_exists(function_short_name        IN VARCHAR2,
	         	           application	              IN VARCHAR2,
                                   parameter                  IN VARCHAR2)
         RETURN BOOLEAN;


-- Function
--   DELETE_FUNCTION_PARAMETER
--
-- Purpose
--   Delete a stage function parameter.
--
-- Arguments
--   function_short_name  - Short name of the function.
--   application - Application short name of the function.
--   parameter   - Short (non-translated) name of parameter.
--
PROCEDURE delete_function_parameter(function_short_name        IN VARCHAR2,
	         	  application	             IN VARCHAR2,
                          parameter	            IN VARCHAR2);


-- Function
--   FUNCTION_PARAMETER_VALUE
--
-- Purpose
--   Sets the value of a stage function parameter for a given stage.
--
-- Arguments
--   request_set  - Short name of the request set.
--   set_application - Application short name of the set.
--   stage_short_name - Short name of stage.
--   parameter_short_name - Short name of parameter.
--   value - Value to which the paraemter is to be set.
--
PROCEDURE function_parameter_value(request_set        IN VARCHAR2,
                                 set_application      IN VARCHAR2,
                                 stage                IN VARCHAR2,
                                 parameter            IN VARCHAR2,
                                 value                IN VARCHAR2);


-- Function
--    RESTART_REQUEST_SET
--
-- Purpose
--  Restarts an Request Set only if one of it's stages were failed in the last run.
--
-- Arguments
--  request_set_id - request_id of request set
--
-- Return
--  returns true if request set can be restarted, otherwise false.
--
FUNCTION restart_request_set( request_set_id IN number) RETURN BOOLEAN;



END fnd_set;

/
