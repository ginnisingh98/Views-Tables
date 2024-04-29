--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_PROJ_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_PROJ_STATUS" AUTHID CURRENT_USER AS
/* $Header: PAXPCECS.pls 120.3 2006/07/24 11:52:06 dthakker noship $ */
/*#
 * The Project verification extension contains procedures that enable you to define rules to determine whether
 * a project can change its project status, and to determine whether to call Workflow for a project status change.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Project Verification
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

l_pkg_name VARCHAR2(30) := 'PA_CLIENT_EXTN_PROJ_STATUS'; -- Do not modify this

/*#
 * This API is used to  define requirements a project must satisfy to
 * change from one project status to another.
 * @param x_calling_module The module that called the extension
 * @rep:paraminfo {@rep:required}
 * @param x_project_id Identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param x_old_proj_status_code The current project status code
 * @rep:paraminfo {@rep:required}
 * @param x_new_proj_status_code The new project status code
 * @rep:paraminfo {@rep:required}
 * @param x_project_type The project type of the project
 * @rep:paraminfo {@rep:required}
 * @param x_project_start_date The project start date
 * @rep:paraminfo {@rep:required}
 * @param x_project_end_date  The project end date
 * @rep:paraminfo {@rep:required}
 * @param x_public_sector_flag Public sector indicator
 * @rep:paraminfo {@rep:required}
 * @param x_attribute_category Descriptive flexfield context
 * @rep:paraminfo {@rep:required}
 * @param x_attribute1 Descriptive flexfield segments
 * @rep:paraminfo {@rep:required}
 * @param x_attribute2 Descriptive flexfield segments
 * @rep:paraminfo {@rep:required}
 * @param x_attribute3 Descriptive flexfield segments
 * @rep:paraminfo {@rep:required}
 * @param x_attribute4 Descriptive flexfield segments
 * @rep:paraminfo {@rep:required}
 * @param x_attribute5 Descriptive flexfield segments
 * @rep:paraminfo {@rep:required}
 * @param x_attribute6 Descriptive flexfield segments
 * @rep:paraminfo {@rep:required}
 * @param x_attribute7 Descriptive flexfield segments
 * @rep:paraminfo {@rep:required}
 * @param x_attribute8 Descriptive flexfield segments
 * @rep:paraminfo {@rep:required}
 * @param x_attribute9 Descriptive flexfield segments
 * @rep:paraminfo {@rep:required}
 * @param x_attribute10 Descriptive flexfield segments
 * @rep:paraminfo {@rep:required}
 * @param x_pm_product_code  The project management product code
 * @rep:paraminfo {@rep:required}
 * @param x_err_code  Error handling code
 * @rep:paraminfo {@rep:required}
 * @param x_warnings_only_flag  Warning flag
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Verify project status change
 * @rep:compatibility S
*/

    Procedure verify_project_status_change
            (x_calling_module           IN VARCHAR2
            ,X_project_id               IN NUMBER
            ,X_old_proj_status_code     IN VARCHAR2
            ,X_new_proj_status_code     IN VARCHAR2
            ,X_project_type             IN VARCHAR2
            ,X_project_start_date       IN DATE
            ,X_project_end_date         IN DATE
            ,X_public_sector_flag       IN VARCHAR2
            ,X_attribute_category       IN VARCHAR2
            ,X_attribute1               IN VARCHAR2
            ,X_attribute2               IN VARCHAR2
            ,X_attribute3               IN VARCHAR2
            ,X_attribute4               IN VARCHAR2
            ,X_attribute5               IN VARCHAR2
            ,X_attribute6               IN VARCHAR2
            ,X_attribute7               IN VARCHAR2
            ,X_attribute8               IN VARCHAR2
            ,X_attribute9               IN VARCHAR2
            ,X_attribute10              IN VARCHAR2
            ,x_pm_product_code          IN VARCHAR2
            ,x_err_code               OUT NOCOPY NUMBER  --File.Sql.39 bug 4440895
            ,x_warnings_only_flag     OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

/*#
 * You can use this procedure to override the settings in the project status record and the project type
 * that determine whether Workflow is called for a status change.
 * @param x_project_status_code  The current project status code
 * @rep:paraminfo {@rep:required}
 * @param x_project_type The project type of the project
 * @rep:paraminfo {@rep:required}
 * @param x_project_id Identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param x_wf_enabled_flag Flag indicating whether Workflow is enabled for the
 *  status change. Value is either Y or N.
 * @rep:paraminfo {@rep:required}
 * @param x_err_code Error handling code
 * @rep:paraminfo {@rep:required}
 * @param x_status_type The project status type
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Check workflow enabled
 * @rep:compatibility S
*/

    Procedure Check_wf_enabled
               (x_project_status_code   IN VARCHAR2,
                x_project_type          IN VARCHAR2,
                x_project_id            IN NUMBER,
                x_wf_enabled_flag      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                x_err_code             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                x_status_type          IN VARCHAR2 DEFAULT 'PROJECT' );

END PA_CLIENT_EXTN_PROJ_STATUS;

 

/
