--------------------------------------------------------
--  DDL for Package PA_PURGE_EXTN_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PURGE_EXTN_VALIDATE" AUTHID CURRENT_USER as
/* $Header: PAXAPVXS.pls 120.3 2006/07/05 10:03:34 vgottimu noship $ */
/*#
 * This extension can be used to define additional business rules for validating projects for purging. By default, the extension
 * returns NULL to the calling program.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Archive Project Validation
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/
 -- forward declarations
/*#
 * This procedure is used for validating projects for purging.
 * @param p_project_id Identifier of the project to be purged
 * @rep:paraminfo {@rep:required}
 * @param p_txn_through_date For open projects, the date through which the transactions are to be purged
 * @rep:paraminfo {@rep:required}
 * @param p_active_flag Flag indicating whether the batch is created for open (active) projects.
 * @rep:paraminfo {@rep:required}
 * @param x_err_stack The stack containing all the errors
 * @rep:paraminfo {@rep:required}
 * @param x_err_stage The point of occurrence of an error
 * @rep:paraminfo {@rep:required}
 * @param x_err_code  Error handling code
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Vaildate Extension
 * @rep:compatibility S
*/
 procedure validate_extn ( p_project_id                     in NUMBER,
                           p_txn_through_date               in DATE,
                           p_active_flag                    in VARCHAR2,
                           x_err_code                       in OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                           x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           x_err_stage                      in OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895



END pa_purge_extn_validate;

 

/
