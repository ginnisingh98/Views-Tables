--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_PROJ_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_PROJ_STATUS" AS
/* $Header: PAXPCECB.pls 120.3 2006/02/20 22:34:52 sunkalya noship $ */

  PROCEDURE Verify_Project_Status_Change
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
            ,x_warnings_only_flag     OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
)
--
 IS
--

/*

You can use this procedure to build additional rules while moving from
one project status to another. For example,you could enforce a rule
that certain class categories and class codes have to be assigned to
a project before you can move to an 'APPROVED' status. Note that you
should check the project_system_status_code to determine whether you
are moving to an APPROVED status. Note that the projects form and the
Activity Management Gateway APIs would be making calls to this procedure
as part of the validations.You can enforce multiple rules and have all
the error messages appear in the front-end interface. Oracle Projects
enforces certain rules as part of validations while moving from one
status to another.You can have your messages appended to the ones
enforced by the product. The projects form displays all error messages
in the message window.In order to append the messages to the stack
you must follow certain API message standards
An example of how you would enforce the above given example and
append the messages is given below
   Example :
     Before the project can change to an APPROVED status

    Rule -1.Ensure that a specific class category is always assigned to a
            project

    Rule -2 Ensure that a CONTRACT project type requires a customer with
            a valid Shipping and Billing contact defined.

    Steps :
       a) Determine the error message you need to display. Check the
          existing error messages and ascertain whether a message that
          meets your requirements already exists. If not,use the
          Messages window under Application Developer responsibility to
          define your messages. Note that the Applications standards
          expect you to prefix all Oracle Projects related messages with
          'PA_'. Please refer to the relevant documentation on defining
          and re-creating the client-side .msb file for PA.

       b) Determine the project_system_status_code. The parameter
          X_new_proj_status_code contains the status to which the
          project is moving into . You will get the project_system_status
          as follows:
              IF X_new_proj_status_code IS NOT NULL THEN
                 select project_system_status_code
                 into l_system_status_code
                 from pa_project_statuses
                 where project_status_code = X_new_proj_status_code;
              END IF;
              IF (l_system_status_code = 'APPROVED', THEN
                   Note that you can specify tokens for the messages while
                   defining them so that a runtime value is displayed
                   to the user.
                   This would be useful , if you want to have a different
		   class category for each project type. Example, a
                   CONTRACT project (The project's project type has a
		   project type class of 'CONTRACT') may require one
		   class category while an INDIRECT project may require a
		   different one. You would achieve this by defining a
		   token for the message and substituting the value
		   of the token at runtime. You can define upto 5 tokens
                   for a message.  You would first define your
		   message as follows

                   Message code :
                   PA_SPEC_CLASS_CATEGORY_REQD

                   Message text :
                    --You must assign the CLASS_CATEGORY class category to
                    --this project before it can be approved.

                   -- Please note to specify an '&' in front of the token
                   -- CLASS_CATEGORY while defining the message

               --- do the validations to enforce the above-mentioned rules
               --- Rule 1
                   Check whether a specific class category has been
                   assigned to the project, by doing a SELECT on the
                   pa_project_classifications table.
                   If the class category is not assigned to the project
                   you would then code the message handling as follows.

                   PA_UTILS.Add_Message
                      (p_app_short_name	=> 'PA',
		       p_msg_name  => 'PA_SPEC_CLASS_CATEGORY_REQD',
		       p_token1	   => 'CLASS_CATEGORY',
		       p_value1    => <your class category>);
                   If you have more than one token you can pass
                   values for p_token2 and p_value2 , etc
                   (upto p_token5).Make sure that the token name is
                   exactly the same as you defined for the message
                   (It is case sensitive).

               --- Rule 2
                   Check whether a CONTRACT project has a customer defined
                   with a billing as well as a shipping contact.

                   You would first define your
                   message as follows :

                   Message code :
                   PA_SPEC_CUST_CONTACT_REQD

                   Message text :
                   --You must assign a customer with a CONTACT_TYPE contact to
                   --this project before it can be approved.

                   -- Please note to specify an '&' in front of the token
                   -- CONTACT_TYPE while defining the message

                   If the customer/contact is not assigned to the project
                   you would then code the message handling as follows.

                   PA_UTILS.Add_Message
                      (p_app_short_name	=> 'PA',
		       p_msg_name  => 'PA_SPEC_CUST_CONTACT_REQD',
		       p_token1	   => 'CONTACT_TYPE',
		       p_value1    => <your contact type>);
                   If you have more than one token you can pass
                   values for p_token2 and p_value2 , etc
                   (upto p_token5).Make sure that the token name is
                   exactly the same as you defined for the message
                   (It is case sensitive).

       c) You can choose to classify the above violations as either warnings
	  or errors that would prevent a project from being approved.If
          you decide to have these messages only displayed as warnings,but
	  would like to continue with approving the project,you can set
	  the x_warnings_only_flag to 'Y'. In this case user must set the
	  x_err_code = 0. If x_err_code > 0 then the warnings will show up
	  as error irrespective of the value of x_warnings_only_flag .
	  Note that, you will set this
	  flag to 'Y' only if you wish to classify all the above violations
	  as warnings. Even if one of them is a business rule that you wish
	  to impose, you should not be setting this flag. Also, note
	  that Oracle Projects enforces its own rules before calling
          this procedure,and any violation of the product defined rules
	  would ensure that the project cannot move to the new status,
          regardless of whether you classify your messages as warnings only
          or not.

       By following the above methods to add your error messages to the
       message stack, you will ensure that all your messages are displayed
       to the user in the messages window of the projects form.

*/
l_api_name VARCHAR2(30) := 'verify_project_status_change'; -- Do not modify this
l_msg_count  NUMBER;
l_msg_data   VARCHAR2(2000);

BEGIN
null;  -- to add some body to the procedure -mpuvathi
 /* Make sure that you set the x_err_code to 0 in case of no errors
    or > 100 in case of any errors. */
       x_err_code := 0;
       x_warnings_only_flag := 'N';

----------------------------------------------------------------------------------------
-- Cost Accrual code
----------------------------------------------------------------------------------------
-- Please uncomment the call to this procedure if you have cost accrual enabled
-- and checks for pre-requisites before a project is closed are to be performed
--
/* *****************************************************************************
PA_REV_CA.Verify_Project_Status_CA
            (x_calling_module
            ,X_project_id
            ,X_old_proj_status_code
            ,X_new_proj_status_code
            ,X_project_type
            ,X_project_start_date
            ,X_project_end_date
            ,X_public_sector_flag
            ,X_attribute_category
            ,X_attribute1
            ,X_attribute2
            ,X_attribute3
            ,X_attribute4
            ,X_attribute5
            ,X_attribute6
            ,X_attribute7
            ,X_attribute8
            ,X_attribute9
            ,X_attribute10
            ,x_pm_product_code
            ,x_err_code
            ,x_warnings_only_flag
	    )
	   ;
******************
 */

EXCEPTION

 /* NOTE : Please ensure that you have the following code to hanlde
    error messages in any of the other exceptions that you may code
    The variable l_pkg_name is defined in the package specification
    Also, do not change the error handling for the WHEN OTHERS exception
 */

WHEN OTHERS THEN
    x_err_code := SQLCODE;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name            => l_pkg_name
    , p_procedure_name      => l_api_name   );
    FND_MSG_PUB.Count_And_Get
    (p_count             =>      l_msg_count     ,
     p_data              =>      l_msg_data      );
     RAISE;

END verify_project_status_change;
-- ==============================================

PROCEDURE Check_wf_enabled
          (x_project_status_code   IN VARCHAR2,
           x_project_type          IN VARCHAR2,
           x_project_id            IN NUMBER,
           x_wf_enabled_flag      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
           x_err_code             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
           x_status_type          IN  VARCHAR2 DEFAULT 'PROJECT'
)
--
IS
--
/*
You can use this procedure to add/modify the conditions to enable
workflow for project status changes. By default,Oracle Projects enables
and launches workflow based on the Project status and Project type setup.
You can choose to override these conditions with your own conditions

*/
l_api_name VARCHAR2(30) := 'Check_wf_enabled'; -- Do not modify this
l_msg_count  NUMBER;
l_msg_data   VARCHAR2(2000);

--Commented the following cursor for Bug#5029322

/*
--MOAC Changes: Bug 4363092: removed nvl usage with org_id
CURSOR l_sel_proj_type_csr IS
select NVL(enable_project_wf_flag,'N')
FROM pa_project_types_all   -- Bug#3807805 : Modified pa_project_types to pa_project_types_all
WHERE project_type = x_project_type
and  org_id = PA_PROJECT_REQUEST_PVT.G_ORG_ID; -- Added the and condition for Bug#3807805
*/

--Modified the cursor l_sel_proj_type_csr as below for Bug#5029322

CURSOR	l_sel_proj_type_csr
IS
SELECT
	PPT.org_id,
	NVL(PPT.enable_project_wf_flag,'N')
FROM
	PA_PROJECT_TYPES_ALL	PPT,
	PA_PROJECTS_ALL		PPA
WHERE
	PPA.org_id		=	PPT.org_id		AND
	PPA.project_type	=	PPT.project_type	AND
	PPA.project_id		=	x_project_id		AND
	PPT.project_type	=	x_project_type;



CURSOR l_sel_proj_stus_csr IS
select NVL(enable_wf_flag,'N')
FROM pa_project_statuses
WHERE project_status_code = x_project_status_code;

l_wf_enabled_flag  VARCHAR2(1) := 'N';
l_org_id	   NUMBER;

BEGIN
       x_err_code := 0;

       --Commented the code below For bug#5029322.Added the same code below after the cursor l_sel_proj_type_csr to make sure that
       --the value of PA_PROJECT_REQUEST_PVT.G_ORG_ID is populated from the cursor. This is to make sure that no regression happens after
       --Bug fix#5029322 as the value of PA_PROJECT_REQUEST_PVT.G_ORG_ID could be used at some other place also.

       /*
	if PA_PROJECT_REQUEST_PVT.G_ORG_ID is null and x_project_type is not null then       -- Added the if block for Bug#3807805
          	select org_id into PA_PROJECT_REQUEST_PVT.G_ORG_ID from pa_project_types where project_type = x_project_type;
       end if;

       */ --End of commenting for Bug#5029322

       OPEN l_sel_proj_type_csr;
       FETCH l_sel_proj_type_csr INTO l_org_id,l_wf_enabled_flag;
       IF l_sel_proj_type_csr%NOTFOUND THEN
          l_wf_enabled_flag := 'N';
       END IF;
       CLOSE l_sel_proj_type_csr;

       --Added the following IF condition for Bug#5029322

       if PA_PROJECT_REQUEST_PVT.G_ORG_ID is null and x_project_type is not null then       -- Added the if block for Bug#3807805
		PA_PROJECT_REQUEST_PVT.G_ORG_ID := l_org_id;
       end if;

       -- End changes for Bug#5029322
  -- If workflow has not been enabled for the project type then do not proceed
  -- further

       IF l_wf_enabled_flag = 'N' THEN
	 x_wf_enabled_flag := 'N';
	 RETURN;
       END IF;

       OPEN l_sel_proj_stus_csr;
       FETCH l_sel_proj_stus_csr INTO l_wf_enabled_flag;
       IF l_sel_proj_stus_csr%NOTFOUND THEN
 	l_wf_enabled_flag := 'N';
       END IF;
       CLOSE l_sel_proj_stus_csr;
       x_wf_enabled_flag := NVL(l_wf_enabled_flag ,'N');


EXCEPTION

WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name            => l_pkg_name
    , p_procedure_name      => l_api_name   );
     FND_MSG_PUB.Count_And_Get
    (p_count             =>      l_msg_count     ,
     p_data              =>      l_msg_data      );
     x_err_code := SQLCODE;
     RAISE;

END Check_wf_enabled;

END Pa_Client_Extn_Proj_Status;

/
