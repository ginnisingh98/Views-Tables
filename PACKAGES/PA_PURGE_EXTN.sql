--------------------------------------------------------
--  DDL for Package PA_PURGE_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PURGE_EXTN" AUTHID CURRENT_USER as
/* $Header: PAXAPPXS.pls 120.3 2006/07/05 09:14:23 vgottimu noship $ */
/*#
 * This package contains the extensions to purge your custom tables. By default the extension
 * returns NULL to the calling program.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Archive Custom Tables Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
 * This procedure is used to purge and archive custom tables as a part of the standard purge process.
 * @param p_purge_batch_id Identifier of the purge batch
 * @rep:paraminfo {@rep:required}
 * @param p_project_id  Identifier of the project to be purged
 * @rep:paraminfo {@rep:required}
 * @param p_purge_release  The Oracle Projects version used to run the purge
 * @rep:paraminfo {@rep:required}
 * @param p_txn_through_date For open projects, the date through which the transactions are to be purged
 * @rep:paraminfo {@rep:required}
 * @param p_archive_flag Flag indicating whether records in the custom tables are to be archived
 * @rep:paraminfo {@rep:required}
 * @param p_calling_place Calling place of the extension. BEFORE_PURGE or AFTER_PURGE indicates
 * when the system calls the extension.
 * @rep:paraminfo {@rep:required}
 * @param p_commit_size Number of archive and purge records to be processed before commitment
 * @rep:paraminfo {@rep:required}
 * @param x_err_stack The stack containing all the errors
 * @rep:paraminfo {@rep:required}
 * @param x_err_stage The point of occurrence of an error
 * @rep:paraminfo {@rep:required}
 * @param x_err_code Error handling code
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Purge Custom Tables
 * @rep:compatibility S
*/
 procedure pa_purge_client_extn  ( p_purge_batch_id                 in NUMBER,
                                   p_project_id                     in NUMBER,
                                   p_purge_release                  in VARCHAR2,
                                   p_txn_through_date               in DATE,
                                   p_archive_flag                   in VARCHAR2,
                                   p_calling_place                  in VARCHAR2,
                                   p_commit_size                    in NUMBER,
                                   x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                   x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                   x_err_code                       in OUT NOCOPY NUMBER ) ; --File.Sql.39 bug 4440895

 -- procedure <CUST_PROCEDURE> ( p_purge_batch_id         IN NUMBER,
 --                              p_project_id             IN NUMBER,
 --                              p_txn_to_date            IN DATE,
 --                              p_purge_release          IN VARCHAR2,
 --                              p_archive_flag           IN VARCHAR2,
 --                              p_commit_size            IN NUMBER,
 --                              x_err_code           IN OUT NUMBER,
 --                              x_err_stack          IN OUT VARCHAR2,
 --                              x_err_stage          IN OUT VARCHAR2
 --                            )    ;
 --

 end pa_purge_extn ;

 

/
