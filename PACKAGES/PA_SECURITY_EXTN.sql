--------------------------------------------------------
--  DDL for Package PA_SECURITY_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_SECURITY_EXTN" AUTHID CURRENT_USER AS
/* $Header: PAPSECXS.pls 120.6.12010000.2 2009/03/04 07:32:45 rthumma ship $ */
/*#
 * This extension is used to implement project security.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Project Security Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
 * This procedure is used to specify business rules to determine project access.
 * @param x_project_id  Identifier of the project or project template
 * @rep:paraminfo {@rep:required}
 * @param x_person_id Identifier of the person
 * @rep:paraminfo {@rep:required}
 * @param x_cross_project_user Flag indicating whether the user is a cross project user
 * @rep:paraminfo {@rep:required}
 * @param x_calling_module  Module from which the project security extension is called. OracleProjects sets this value for each
 * module in which it calls the security extension.
 * @rep:paraminfo {@rep:required}
 * @param x_event Type of access being queried. For example, ALLOW_QUERY, ALLOW_UPDATE, or VIEW_LABOR_ COSTS.
 * @rep:paraminfo {@rep:required}
 * @param x_value Result of the query (Y or N)
 * @rep:paraminfo {@rep:required}
 * @param x_cross_project_view Flag indicating if the user has cross project view access
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Project Security
 * @rep:compatibility S
*/

  PROCEDURE check_project_access ( X_project_id		IN NUMBER
                                 , X_person_id          IN NUMBER
                                 , X_cross_project_user IN VARCHAR2
                                 , X_calling_module	IN VARCHAR2
  	                             , X_event              IN VARCHAR2
                                 , X_value              OUT NOCOPY VARCHAR2
                                 , X_cross_project_view IN VARCHAR2 := 'Y' );
  pragma RESTRICT_REFERENCES ( check_project_access, WNDS, WNPS );


/* Added for Bug 8234670 */

/*#
 * This API is used to allow customization of project accessibility on the project search pages.
 * @param x_mode Mode in which the function is called.
 * @rep:paraminfo {@rep:required}
 * @param x_project_id  Identifier of the project.
 * @rep:paraminfo {@rep:required}
 * @param x_person_id Identifier of the person.
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Custom Project Access.
 * @rep:compatibility S
*/


  FUNCTION custom_project_access ( X_mode           IN VARCHAR2
                                 , X_project_id     IN NUMBER
                                 , X_person_id      IN NUMBER) RETURN VARCHAR2;

END pa_security_extn;

/
