--------------------------------------------------------
--  DDL for Package FND_PROGRAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_PROGRAM" AUTHID CURRENT_USER AS
/* $Header: AFCPRCPS.pls 120.2.12010000.4 2013/12/16 21:53:16 pferguso ship $ */
/*#
 * Contains procedures for creating the concurrent program executables, concurrent programs with parameters and incompatibility rules, request sets and request groups
 * @rep:scope public
 * @rep:product FND
 * @rep:displayname Concurrent Program Loaders
 * @rep:category BUSINESS_ENTITY FND_CP_PROGRAM
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


/*#
 * This function returns an error message. Messages are set when any validation errors occur during the processing of other functions/procedures in this package.
 * @rep:displayname Message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
-- Function
--   MESSAGE
--
-- Purpose
--   Return an error message.  Messages are set when
--   validation (program) errors occur.
--
FUNCTION message RETURN VARCHAR2 ;

/*#
 * Creates a new parameter for the specified concurrent program
 * @param program_short_name The short name used as the developer's name of the concurrent program
 * @param application The short name of the application the owns the concurrent program
 * @param sequence The parameter sequence number that determines the order of the parameters
 * @param parameter The parameter name
 * @param description An optional parameter description
 * @param enabled Specify 'Y' for enabled parameters and 'N' for disabled parameters
 * @param value_set The value set to be used with the parameter
 * @param default_type An optional default type. Possible values are 'Constant', 'Profile', 'SQL Statement',  or 'Segment'
 * @param default_value Required only when the default type is not null
 * @param required Specify 'Y' for required parameters, 'N' for optional ones
 * @param enable_security 'Y' enables value security if the value set permits it, 'N' prevents value security from operating on this parameter
 * @param range Optionally specify 'High', 'Low' or 'Pair'
 * @param display Specify 'Y' to display the parameter and 'N' to hide it
 * @param display_size The length of the item in the parameter window
 * @param description_size The length of the item's description in the parameter window
 * @param concatenated_description_size The length of the description in the concatenated parameters field
 * @param prompt The item prompt in the parameter window
 * @param token The Oracle Reports token
 * @rep:displayname Create Parameter
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
-- Procedure
--   PARAMETER
--
-- Purpose
--   Register an SRS parameter for a program
--
-- Arguments:
--   program_short_name - e.g. FNDSCRMT
--   application        - Program application short name. e.g. 'FND'
--   sequence           - Parameter sequence number
--   parameter          - Name of parameter
--   description        - Parameter description (Optional)
--   enabled            - 'Y' or 'N'
--   value_set          - Name of value set (e.g. '30 Characters Optional')
--   default_type       - 'Constant', 'Profile', 'SQL Statement', 'Segment'
--                        (Optional)
--   default_value      - Parameter default (Required if default_type is not
--                        Null)
--   required           - 'Y' or 'N'
--   enable_security    - 'Y' or 'N', Enables security if value set allows.
--   range              - 'High', 'Low', or 'Pair' (Optional)
--   display            - 'Y' or 'N'
--   display_size       - Length of item in parameter window
--   description_size   - Length of item description in parameter window
--   concatenated_description_size - Length of description in concatenated
--                                   parameters field.
--   prompt             - Item prompt in parameter window
--   token              - Required token for Oracle Reports parameters
--   cd_parameter       - 'Y' sets this parameter to be this program's cd_parameter
--
PROCEDURE parameter(
	program_short_name            IN VARCHAR2,
	application                   IN VARCHAR2,
	sequence                      IN NUMBER,
	parameter                     IN VARCHAR2,
	description                   IN VARCHAR2 DEFAULT NULL,
	enabled                       IN VARCHAR2 DEFAULT 'Y',
	value_set                     IN VARCHAR2,
	default_type                  IN VARCHAR2 DEFAULT NULL,
	default_value                 IN VARCHAR2 DEFAULT NULL,
	required                      IN VARCHAR2 DEFAULT 'N',
	enable_security               IN VARCHAR2 DEFAULT 'N',
	range                         IN VARCHAR2 DEFAULT NULL,
	display                       IN VARCHAR2 DEFAULT 'Y',
	display_size                  IN NUMBER,
	description_size              IN NUMBER,
	concatenated_description_size IN NUMBER,
	prompt                        IN VARCHAR2 DEFAULT NULL,
        token                         IN VARCHAR2 DEFAULT NULL,
	cd_parameter                  IN VARCHAR2 DEFAULT 'N');



/*#
 * Defines a concurrent program for use in the concurrent processing system
 * @param program User visible program name
 * @param application The short name of the application that owns the program
 * @param enabled Specify 'Y' to enable, 'N' otherwise
 * @param short_name The Internal developer program name
 * @param description An optional description of the program
 * @param executable_short_name The short name of the registered concurrent program executable
 * @param executable_application The short Nname of the application under which the executable is registered
 * @param execution_options Any special option string used by certain executables such as Oracle Reports
 * @param priority An optional program level priority
 * @param save_output Indicate with 'Y' or 'N' whether to save the output
 * @param print Allow printing by specifying 'Y', otherwise 'N'
 * @param cols The page width of the report columns
 * @param rows The page length of the report rows
 * @param style The default print style name
 * @param style_required Specify whether to allow changing the default print style from the Submit Requests window
 * @param printer Force output to the specified printer
 * @param request_type A user defined request type
 * @param request_type_application The short name of the application owning the request type
 * @param use_in_srs Specify 'Y' to allow users to submit the program from the Submit Requests window, otherwise 'N'
 * @param allow_disabled_values Specify 'Y' to allow parameters based on outdated value sets to validate anyway. Specify 'N' to require current values
 * @param run_alone Program must have the whole system to itself. Specify 'Y' or 'N'
 * @param output_type The type of the output generated by the concurrent program
 * @param enable_trace Specify 'Y' if you want to always enable SQL trace for this program, 'N' if not
 * @param nls_compliant Reserved for use for internal developers only. Use 'N'
 * @param icon_name Reserved for use by the internal developers only. Use NULL
 * @param language_code Language code for the name and description
 * @param mls_function_short_name The name of the registered MLS function
 * @param mls_function_application The short name of the application under which the MLS function is registered
 * @param incrementor The incrementor PL/SQL function name
 * @rep:displayname Define Concurrent Program
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
-- Procedure
--   REGISTER
--
-- Purpose
--   Register a concurrent program.
--
-- Arguments
--   program                - User-visible program name. e.g. 'Menu Report'
--   application            - Program application short name. e.g. 'FND'
--   enabled                - 'Y' or 'N'
--   short_name             - Internal program name.  e.g. 'FNDSCRMT'
--   description            - Description of program.
--   executable_short_name  - Name of the registered executable.
--   executable_application - Short name of the application under which the
--                            executable is registered.
--   execution_options      - Special options string for certain executables.
--   priority               - Program level priority. 1..99
--   save_output            - Save 'report' file? 'Y' or 'N'
--   print                  - 'Y' or 'N'
--   cols                   - Report columns (page width).
--   rows                   - Report rows (page length).
--   style                  - Print style name. (e.g. 'Landwide')
--   style_required         - Prevent style changes in SRS form. 'Y' or 'N'
--   printer                - Named printer cannot be changed in SRS form.
--   request_type           - User-defined request type
--   request_type_application - Application short name of request type.
--   use_in_srs             - Allow program to be submitted form SRS form
--                            'Y' or 'N'
--   allow_disabled_values  - Allow parameters based on outdated value sets
--                            to validate anyway.
--   run_alone              - Program must have the whole system to itself.
--                            'Y' or 'N'
--   output_type            - Type of output generated by the concurrent
--                            program.  'HTML', 'PS', 'TEXT', or 'PDF'
--   enable_trace           - Always enable SQL trace for this program?
--   restart                - Restart program if it was running during a
--                            general system failure.
--   nls_compliant          - Certifies NLS standards compliance.
--   icon_name              - For future web interfaces. Not yet supported.
--   language_code          - Language code for the name and description.
--                            e.g. 'US'
--   mls_function_short_name- Name of the registered mls function
--   mls_function_application- Name of the application under which mls function
--                              was registered
--   incrementor	    - Incrementor pl/sql function name
--   refresh_portlet        - Refresh Portlet based on the specified program
--                            outcome ('Never','On Success', 'Always',
--                                     'On Success or Warning')
--
PROCEDURE register(program  	                IN VARCHAR2,
		   application  		IN VARCHAR2,
		   enabled       		IN VARCHAR2,
		   short_name	  	        IN VARCHAR2,
		   description		 	IN VARCHAR2 DEFAULT NULL,
		   executable_short_name	IN VARCHAR2,
		   executable_application       IN VARCHAR2,
		   execution_options		IN VARCHAR2 DEFAULT NULL,
		   priority			IN NUMBER   DEFAULT NULL,
		   save_output			IN VARCHAR2 DEFAULT 'Y',
		   print			IN VARCHAR2 DEFAULT 'Y',
		   cols				IN NUMBER   DEFAULT NULL,
		   rows				IN NUMBER   DEFAULT NULL,
		   style 			IN VARCHAR2 DEFAULT NULL,
		   style_required		IN VARCHAR2 DEFAULT 'N',
		   printer			IN VARCHAR2 DEFAULT NULL,
		   request_type			IN VARCHAR2 DEFAULT NULL,
		   request_type_application     IN VARCHAR2 DEFAULT NULL,
		   use_in_srs			IN VARCHAR2 DEFAULT 'N',
		   allow_disabled_values	IN VARCHAR2 DEFAULT 'N',
		   run_alone			IN VARCHAR2 DEFAULT 'N',
                   output_type                  IN VARCHAR2 DEFAULT 'TEXT',
                   enable_trace                 IN VARCHAR2 DEFAULT 'N',
                   restart                      IN VARCHAR2 DEFAULT 'Y',
                   nls_compliant                IN VARCHAR2 DEFAULT 'Y',
                   icon_name                    IN VARCHAR2 DEFAULT NULL,
                   language_code                IN VARCHAR2 DEFAULT 'US',
                   mls_function_short_name      IN VARCHAR2 DEFAULT NULL,
                   mls_function_application     IN VARCHAR2 DEFAULT NULL,
                   incrementor			IN VARCHAR2 DEFAULT NULL,
                   refresh_portlet              IN VARCHAR2 DEFAULT NULL
		    );


/*#
 * Registers an incompatibility for the specified concurrent program
 * @param program_short_name The short name used as the developer name of the concurrent program
 * @param application The short name of the application that owns the concurrent program
 * @param inc_prog_short_name The short name of the incompatible program
 * @param inc_prog_application The application that owns the incompatible program
 * @param scope Specify either 'Set' or 'Program Only'
 * @param inc_type Type of incompatibility  D - Domain-specific or G - Global
 * @rep:displayname Define Incompatibility
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
-- Procedure
--   Incompatibility
--
-- Purpose
--   Register a concurrent program incompatibility.
--
-- Arguments
--   program_short_name  - Short name of the first program. (e.g. FNDSCRMT)
--   application         - Application of the first program. (e.g. FND)
--   inc_prog_short_name - Short name of the incompatible program.
--   inc_prog_application- Application of the incompatible program.
--   scope               - 'Set' or 'Program Only'
--   inc_type            - Incompatibility type - (D)omain-specific or (G)lobal
--
PROCEDURE incompatibility(program_short_name       IN VARCHAR2,
			  application   	   IN VARCHAR2,
			  inc_prog_short_name  	   IN VARCHAR2,
			  inc_prog_application     IN VARCHAR2,
                          scope                    IN VARCHAR2 DEFAULT 'Set',
			  inc_type                 IN VARCHAR2 DEFAULT 'D');


/*#
 * Registers an executable with the concurrent processing system
 * @param executable The name of the executable
 * @param application The short name of executable's application
 * @param description The description of the executable
 * @param execution_method The type of program the executable uses
 * @param execution_file_name The operating system name of the file
 * @param subroutine_name Subroutine name. Used only by immediate programs.
 * @param icon_name Icon name
 * @param language_code language code for the name and description
 * @rep:displayname Register Executable
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
-- Procedure
--   EXECUTABLE
--
-- Purpose
--   Register a concurrent program executable.
--
-- Arguments
--   executable          - Name of executable.  (e.g. 'FNDSCRMT')
--   application         - Short name of executable's application.
--                        (e.g. 'FND')
--   short_name          - Short (non-translated) name of the executable.
--   description         - Optional description of the executable.
--   execution method    - 'FlexRpt', 'FlexSQL', 'Host', 'Immediate',
--                         'Oracle Reports', 'PL/SQL Stored Procedure',
--                         'Spawned', 'SQL*Loader', 'SQL*Plus', 'SQL*Report',
--                         'Request Set Stage Function',
--			   'Multi Language Function','Java Stored Procedure'
--                         'Shutdown Callback', 'Java Concurrent Program'
--   execution_file_name - Required for all but 'Immediate' programs.
--                         Cannot contain spaces or periods.
--   subroutine_name     - Used only for 'Immediate' programs.
--                         Cannot contain spaces or periods.
--   icon_name           - For future web interfaces. Not yet supported.
--   language_code       - Language code for the name and description.
--                         (e.g. 'US')
--   execution_file_path - Used only for 'Java Concurrent Program'
--   			   It is the package path for the class
--
PROCEDURE executable(executable            	     IN VARCHAR2,
	             application	     	     IN VARCHAR2,
                     short_name                      IN VARCHAR2,
	             description                     IN VARCHAR2 DEFAULT NULL,
		     execution_method                IN VARCHAR2,
		     execution_file_name             IN VARCHAR2 DEFAULT NULL,
	             subroutine_name                 IN VARCHAR2 DEFAULT NULL,
                     icon_name                       IN VARCHAR2 DEFAULT NULL,
                     language_code                   IN VARCHAR2 DEFAULT 'US',
		     execution_file_path	     IN VARCHAR2 DEFAULT NULL);


-- Procedure
--   REQUEST_GROUP
--
-- Purpose
--   Registers a request group.
--
-- Arguments
--   request_group       - Name of request group.
--   application         - Name of group's application. (e.g. 'FND')
--   code                - Optional group code.
--   description         - Optional description of the set.
PROCEDURE request_group(request_group        	     IN VARCHAR2,
	        	 application	     	     IN VARCHAR2,
	        	 code 		     	     IN VARCHAR2 DEFAULT NULL,
	        	 description                 IN VARCHAR2 DEFAULT NULL);



/*#
 * Adds a concurrent program to an existing request group
 * @param program_short_name The short name used as the developer name of the concurrent program
 * @param program_application The application that owns the concurrent program
 * @param request_group The request group to which to add the concurrent program
 * @param group_application The application that owns the request group
 * @rep:displayname Delete Request Group
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
-- Procedure
--   ADD_TO_GROUP
--
-- Purpose
--   Add a concurrent program to a request group.
--
-- Arguments
--   program_short_name  - Short name of the program. (e.g. FNDSCRMT)
--   program_application - Application of the program. (e.g. 'FND')
--   request_group       - Name of request group.
--   group_application   - Application of the request group.
--
PROCEDURE add_to_group(program_short_name            IN VARCHAR2,
	               program_application	     IN VARCHAR2,
	               request_group                 IN VARCHAR2,
		       group_application             IN VARCHAR2);

/*#
 * Deletes a concurrent program from an existing request group
 * @param program_short_name The short name used as the developer name of the concurrent program
 * @param program_application The application that owns the concurrent program
 * @param request_group The request group from which to delete the concurrent program
 * @param group_application The application that owns the request group
 * @rep:displayname Remove From Request Group
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
-- Procedure
--   REMOVE_FROM_GROUP
--
-- Purpose
--   Remove a concurrent program to a request group.
--
-- Arguments
--   program_short_name  - Short name of the program. (e.g. FNDSCRMT)
--   program_application - Application of the program. (e.g. 'FND')
--   request_group       - Name of request group.
--   group_application   - Application of the request group.
--
PROCEDURE remove_from_group(program_short_name            IN VARCHAR2,
	                    program_application	          IN VARCHAR2,
	                    request_group                 IN VARCHAR2,
		            group_application             IN VARCHAR2);


/*#
 * Deletes a concurrent program. All the references to the concurrent program are also deleted as well (cascaded).
 * @param program_short_name The short name used as the developer name of the concurrent program
 * @param application Short Name of the application that owns the concurrent program
 * @rep:displayname Delete Program
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
-- Procedure
--   DELETE_PROGRAM
--
-- Purpose
--   Delete a concurrent program.  All references to the program are
--   also deleted.
--
-- Arguments
--   program_short_name  - Short name of the program. (e.g. FNDSCRMT)
--   application         - Application of the program. (e.g. 'FND')
--
PROCEDURE delete_program(program_short_name          IN VARCHAR2,
	                 application	     	     IN VARCHAR2);


/*#
 * Deletes a parameter to a concurrent program
 * @param program_short_name The short name used as the developer name of the concurrent program
 * @param application The short name of the application that owns the concurrent program
 * @param parameter The parameter to delete
 * @rep:displayname Delete Parameter
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
-- Procedure
--   DELETE_PARAMETER
--
-- Purpose
--   Delete a concurrent program parameter.
--
-- Arguments
--   program_short_name  - Short name of the program. (e.g. FNDSCRMT)
--   application         - Application of the program. (e.g. 'FND')
--   parameter           - Parameter name.
PROCEDURE delete_parameter(program_short_name          IN VARCHAR2,
	                   application	     	       IN VARCHAR2,
                           parameter                   IN VARCHAR2);


/*#
 * Deletes a concurrent program executable
 * @param executable_short_name The short name of the executable to delete
 * @param application The short name of the executable's application
 * @rep:displayname Delete Executable
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
-- Procedure
--   DELETE_EXECUTABLE
--
-- Purpose
--   Delete a concurrent program executable.  An executable that
--   is assigned to a concurrent program cannot be deleted.
--
-- Arguments
--   executable_short_name  - Short name of the executable. (e.g. FNDSCRMT)
--   application - Application of the executable. (e.g. 'FND')
--
PROCEDURE delete_executable(executable_short_name IN VARCHAR2,
	         	    application	     	  IN VARCHAR2);


/*#
 * Deletes an existing request group
 * @param request_group The short name of the request group to delete
 * @param application The short name of the application that owns the concurrent program
 * @rep:displayname Delete Request Group
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
-- Procedure
--   DELETE_GROUP
--
-- Purpose
--   Delete a request group and group units.
--
-- Arguments
--   group       - Name of the group. (e.g. FNDSCRMT)
--   application - Application of the executable. (e.g. 'FND')
--
PROCEDURE delete_group(request_group  IN VARCHAR2,
	               application    IN VARCHAR2);


/*#
 * Deletes a concurrent program. All the references to the concurrent program are also deleted as well (cascaded)
 * @param program_short_name The short name used as the developer name of the concurrent program
 * @param application The short name of the application that owns the concurrent program
 * @param inc_prog_short_name The short name of the incompatible program to delete
 * @param inc_prog_application The application that owns the incompatible program
 * @rep:displayname Delete Incompatibility
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
-- Procedure
--   DELETE_INCOMPATIBILITY
--
-- Purpose
--   Delete a concurrent program incompatibility rule.
--
-- Arguments
--   program_short_name  - Short name of the first program. (e.g. FNDSCRMT)
--   application         - Application of the first program. (e.g. 'FND')
--   inc_prog_short_name - Short name of the incompatible program.
--   inc_prog_application- Application of the incompatible program.
--
PROCEDURE delete_incompatibility(program_short_name         IN VARCHAR2,
			  	application     	    IN VARCHAR2,
			  	inc_prog_short_name  	    IN VARCHAR2,
			  	inc_prog_application        IN VARCHAR2);

/*#
 * Enables or disables an existing concurrent program
 * @param short_name The short name of the program
 * @param application The application short name of the program
 * @param  enabled Specify 'Y' to enable the program and 'N' to disable the program
 * @rep:displayname Enable program
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
-- Procedure
--   enable_program
--
-- Purpose
--   enable or disable the concurrent program.
--
-- Arguments
--   program_short_name  - Short name of the program.
--   program_application - Application of the program.
--   enabled             - 'Y' or 'N' values.
--
PROCEDURE enable_program(short_name        IN VARCHAR2,
                         application       IN VARCHAR2,
                         enabled           IN VARCHAR2);

/*#
 * Checks if the specified concurrent program exists
 * @param program The short name of the program
 * @param application The application short name of the program
 * @return Returns TRUE if the concurrent program exists
 * @rep:displayname Program Exists
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
-- Function
--   PROGRAM_EXISTS
--
-- Purpose
--   Return TRUE if a concurrent program exists.
--
-- Arguments
--   program     - Short name of the program.
--   application - Application short name of the program.
--
FUNCTION program_exists(program 	IN VARCHAR2,
			application	IN VARCHAR2) RETURN BOOLEAN;


/*#
 * Checks if the parameter provided is valid for the given program
 * @param program_short_name The short name of the program
 * @param application The application short name of the program
 * @param parameter The name of the parameter
 * @return Returns TRUE if the program parameter exists
 * @rep:displayname Program Parameter Exists
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
-- Function
--   PARAMETER_EXISTS
--
-- Purpose
--   Return TRUE if a program parameter exists.
--
-- Arguments
--   program_short_name - Short name of program.
--   application        - Application short name of the program.
--   parameter          - Name of the parameter.
--
FUNCTION parameter_exists(program_short_name IN VARCHAR2,
			  application        IN VARCHAR2,
			  parameter	     IN VARCHAR2) RETURN BOOLEAN;

/*#
 * Checks if the specified program incompatibility exists
 * @param program_short_name The short name of the first program
 * @param application The application short name of the program
 * @param inc_prog_short_name The short name of the incompatible program
 * @param inc_prog_application The application short name of the incompatible program
 * @return Returns TRUE if the program incompatibility exists
 * @rep:displayname Program Incompatibility Exists
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
-- Function
--   INCOMPATIBILITY_EXISTS
--
-- Purpose
--   Return TRUE if a program incompatibility exists.
--
-- Arguments
--   program_short_name  - Short name of the first program.
--   application         - Application short name of the first program.
--   inc_prog_short_name - Short name of the incompatible program.
--   inc_prog_application- Application short name of the incompatible program.
--
FUNCTION incompatibility_exists(program_short_name         IN VARCHAR2,
			  	application     	    IN VARCHAR2,
			  	inc_prog_short_name  	    IN VARCHAR2,
			  	inc_prog_application        IN VARCHAR2)
				RETURN BOOLEAN;


/*#
 * Checks if an executable of the give name exists
 * @param executable_short_name The name of the executable
 * @param application The application short name of the executable
 * @return Returns TRUE if the program executable exists
 * @rep:displayname Executable Exists
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
-- Function
--   EXECUTABLE_EXISTS
--
-- Purpose
--   Return TRUE if a program executable exists.
--
-- Arguments
--   executable_short_name - Name of the executable.
--   application - Application short name of the executable.
--
FUNCTION executable_exists(executable_short_name IN VARCHAR2,
	         	   application	     IN VARCHAR2) RETURN BOOLEAN;


/*#
 * Checks if a Request Group of the given name exists in the specified application
 * @param request_group The short name of the request group
 * @param application The application short name of the Request Group
 * @return Returns TRUE if the request group exists
 * @rep:displayname Executable Exists
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
-- Function
--   REQUEST_GROUP_EXISTS
--
-- Purpose
--   Return TRUE if a request group exists.
--
-- Arguments
--   group       - Name of the group.
--   application - Application short name of the executable.
--
FUNCTION request_group_exists(request_group  IN VARCHAR2,
	                      application    IN VARCHAR2) RETURN BOOLEAN;


/*#
 * Checks if the program, uniquely identified by the program name and the program application short name, belongs the given request group
 * @param program_short_name The short name of the program
 * @param program_application The application short name of the program
 * @param request_group The name of the request group
 * @param group_application The application short name of the request group
 * @return Returns TRUE if the program exists in the request group
 * @rep:displayname Program In Request Group
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
-- Function
--   PROGRAM_IN_GROUP
--
-- Purpose
--   Returns true if a program is in a request group.
--
-- Arguments
--   program_short_name  - Short name of the program.
--   program_application - Application of the program.
--   request_group       - Name of request group.
--   group_application   - Application of the request group.
--
FUNCTION program_in_group(program_short_name	IN VARCHAR2,
	                  program_application	IN VARCHAR2,
	                  request_group         IN VARCHAR2,
		          group_application     IN VARCHAR2) RETURN BOOLEAN;

-- Procedure
--   ADD_APPLICATION_TO_GROUP
--
-- Purpose
--   Add a applicaiton to a request group.
--
-- Arguments
--   application_name - Application of the program.
--                         (e.g. 'Application Object Library')
--   request_group       - Name of request group.
--   group_application   - Application of the request group.
--
PROCEDURE add_application_to_group(
		       application_name 	     IN VARCHAR2,
	               request_group                 IN VARCHAR2,
		       group_application             IN VARCHAR2);

-- Procedure
--   REMOVE_APPLICATION_FROM_GROUP
--
-- Purpose
--   Remove a application from a request group.
--
-- Arguments
--   application_name - Application of the program.
--                         (e.g. 'Application Object Library')
--   request_group       - Name of request group.
--   group_application   - Application of the request group.
--
PROCEDURE remove_application_from_group(
			    application_name	          IN VARCHAR2,
	                    request_group                 IN VARCHAR2,
		            group_application             IN VARCHAR2);

-- Function
--   APPLICATION_IN_GROUP
--
-- Purpose
--   Returns true if a program is in a request group.
--
-- Arguments
--   program_application - Application of the program.
--   request_group       - Name of request group.
--   group_application   - Application of the request group.
--
FUNCTION application_in_group(application_name	IN VARCHAR2,
	                  request_group         IN VARCHAR2,
		          group_application     IN VARCHAR2) RETURN BOOLEAN;

/*#
 * Checks if the program, uniquely identified by the program name and the program application short name, has a valid mls function
 * @param program_short_name The short name of the program
 * @param program_application The application short name of the program
 * @return Returns TRUE if the program has a valid mls function
 * @rep:displayname Program Is MLS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
-- Function
--   PROGRAM_IS_MLS
--
-- Purpose
--   Returns NTRUE (1) if the program, uniquely identified by the program name
--   and the program application short name, has a valid mls function
--   Otherwise, return NFALSE (0)
--
-- Arguments
--   program_short_name  - Short name of the program.
--   program_application - Application short name of the program.
--
FUNCTION program_is_mls(program_short_name	IN VARCHAR2,
	                  program_application	IN VARCHAR2) RETURN NUMBER;





/* Array type for use with set_shelf_life procedures */
TYPE program_list IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;


-- Procedure
--   SET_SHELF_LIFE
--
-- Purpose
--   Set shelf_life for a single program
--
-- Arguments
--   program_application - Application of the program
--   program_short_name  - Concurrent program short name
--   shelf_life          - New shelf_life value
--
PROCEDURE set_shelf_life(program_application IN VARCHAR2,
                         program_short_name  IN VARCHAR2,
                         shelf_life          IN NUMBER);


-- Procedure
--   SET_SHELF_LIFE
--
-- Purpose
--   Set shelf_life for a single program
--
-- Arguments
--   program_application_id - Application id of the program
--   concurrent_program_id  - Concurrent program id
--   shelf_life             - New shelf_life value
--
PROCEDURE set_shelf_life(program_application_id IN NUMBER,
                         concurrent_program_id  IN NUMBER,
                         shelf_life             IN NUMBER);


-- Procedure
--   SET_SHELF_LIFE
--
-- Purpose
--   Set shelf_life for a list of programs
--
-- Arguments
--   program_application_id - Application id of the program
--   programs               - List of concurrent program ids
--                            Pass an empty program_list to update all programs
--                            belonging to the application
--   shelf_life             - New shelf_life value
--
PROCEDURE set_shelf_life(program_application_id IN NUMBER,
                         programs               IN program_list,
                         shelf_life             IN NUMBER);



-- Procedure
--   SET_ALL_SHELF_LIFE
--
-- Purpose
--   Set shelf_life for all programs that currently have a certain
--   shelf_life value
--
-- Arguments
--   current_value - Current shelf_life value
--                   Can be NULL to update all programs that currently
--                   have a NULL shelf_life
--   new_value     - New shelf_life value
--
PROCEDURE set_all_shelf_life(current_value  IN NUMBER,
                             new_value      IN NUMBER);



-- Procedure
--   SET_ALL_SHELF_LIFE
--
-- Purpose
--   Set shelf_life for all programs
--
-- Arguments
--   new_value     - New shelf_life value
--
PROCEDURE set_all_shelf_life(new_value      IN NUMBER);



END fnd_program;

/
