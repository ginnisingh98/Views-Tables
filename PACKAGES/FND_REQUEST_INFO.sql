--------------------------------------------------------
--  DDL for Package FND_REQUEST_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_REQUEST_INFO" AUTHID CURRENT_USER as
/* $Header: AFCPRINS.pls 120.4 2006/04/05 02:32:09 ktanneru ship $ */
/*#
 * Used in MLS functions to get the MLS information for a request. An MLS function can use the FND_REQUEST_INFO APIs to retrieve the
 * concurrent program application short name, the concurrent program short name, and the concurrent request parameters if needed.
 * @rep:scope public
 * @rep:product FND
 * @rep:displayname Request Information
 * @rep:category BUSINESS_ENTITY FND_CP_REQUEST
 * @rep:lifecycle active
 * @rep:compatibility S
 */


 -- Name
 --  initialize
 -- Purpose
 --  It initilizes the global variables and for the current request.

procedure initialize;


 -- Name
 --  get_request_id
 -- Purpose
 --  It will return the current request id.

FUNCTION GET_REQUEST_ID return number;
pragma restrict_references(get_request_id, WNDS, WNPS );

 -- Name
 --  get_param_info
 -- Purpose
 --  It will return request parameter name for a given parameter number
 -- Arguments
 --  param_num - IN     - number
 --  name      - OUT    - varchar2
/*#
 * Retrieves the parameter name for a given parameter number. The function will return -1 if it fails to retrieve the parameter number.
 * @param Param_num The parameter number for the given parameter name
 * @param Name The name of the parameter of the request's concurrent program
 * @return Returns -1 if it fails to retrieve information
 * @rep:displayname Get Parameter Information
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
FUNCTION GET_PARAM_INFO(Param_num in number,
                        Name out nocopy varchar2)
return number;
pragma restrict_references(get_param_info, WNDS, WNPS);

 -- Name
 --  get_param_number
 -- Purpose
 --  It will return request parameter number for a given parameter name
 -- Arguments
 --  name      - IN    - varchar2
 --  param_num - OUT   - number
/*#
 * Retrieves the parameter number for a given parameter name. The function will return -1 if it fails to retrieve the parameter number.
 * @param name The name of the parameter of the request's concurrent program
 * @param Param_num Parameter number for the given parameter name
 * @return Returns -1 if fails to retrieve information
 * @rep:displayname Get Parameter Number
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
FUNCTION GET_PARAM_NUMBER(name in varchar2,
                          Param_num out nocopy number)
return number;

pragma restrict_references(get_param_number, WNDS, WNPS);


 -- Name
 --  get_program
 -- Purpose
 --  It will return requests developer concurrent program name and
 --  application short name
/*#
 * Retrieves the concurrent program short name and the short name of the application that owns the concurrent program
 * @param PROG_NAME The short name of the concurrent program
 * @param PROG_APP_NAME The short name of the application that owns the program
 * @rep:displayname Get Program
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
PROCEDURE GET_PROGRAM(PROG_NAME out nocopy VARCHAR2,
                      PROG_APP_NAME out nocopy varchar2);

pragma restrict_references(get_program, WNDS, WNPS);


 -- Name
 --  get_parameter
 -- Purpose
 --  Returns request parameter value for a given parameter number or parameter
 --   name.
 --  Function will return the value as varchar2.
/*#
 * Retrieves the concurrent requests's parameter value for a given parameter number. Values are always returned as strings (varchar2).
 * @param param_num The number of the parameter of the request's concurrent program
 * @return Returns the parameter value for the given parameter number
 * @rep:displayname Get Parameter
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S */
FUNCTION GET_PARAMETER(param_num in number) return varchar2;

pragma restrict_references(get_parameter, WNDS, WNPS);

FUNCTION GET_PARAMETER(name in varchar2) return varchar2;

 -- Name
 --  get_territory
 -- Purpose
 --  Returns request nls_territory value
 --  Function will return the value as varchar2.

FUNCTION GET_TERRITORY return varchar2;

pragma restrict_references(get_territory, WNDS, WNPS);

end;

 

/
