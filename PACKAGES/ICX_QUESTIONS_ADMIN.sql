--------------------------------------------------------
--  DDL for Package ICX_QUESTIONS_ADMIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_QUESTIONS_ADMIN" AUTHID CURRENT_USER as
/* $Header: ICXQUADS.pls 115.1 1999/12/09 22:54:04 pkm ship      $ */

/*===========================================================================

Function	FIND_QUESTIONS

Purpose		Search For Questions based on a variety of context

============================================================================*/
procedure FIND_QUESTIONS;

/*===========================================================================

Function	DISPLAY_QUESTIONS

Purpose		 Display a list of existing questions based on the
                 query criteria provided

============================================================================*/
procedure DISPLAY_QUESTIONS
(
 P_APPLICATION_SHORT_NAME       IN  VARCHAR2     DEFAULT NULL,
 P_QUESTION_CODE		IN  VARCHAR2     DEFAULT NULL,
 P_QUESTION		        IN  VARCHAR2     DEFAULT NULL
);


/*===========================================================================

Function	EDIT_QUESTION

Purpose		Edit a question code or content

============================================================================*/
procedure EDIT_QUESTION
(
 P_APPLICATION_ID 	        IN  VARCHAR2     DEFAULT NULL,
 P_APPLICATION_SHORT_NAME       IN  VARCHAR2     DEFAULT NULL,
 P_QUESTION_CODE		IN  VARCHAR2     DEFAULT NULL,
 P_ERROR_MESSAGE                IN  VARCHAR2     DEFAULT NULL,
 P_QUESTION                     IN  VARCHAR2     DEFAULT NULL,
 P_FIND_CRITERIA                IN  VARCHAR2     DEFAULT NULL,
 P_INSERT                       IN  VARCHAR2     DEFAULT NULL
);

/*===========================================================================

Function	INSERT_QUESTION

Purpose		 Insert a new question

============================================================================*/
procedure INSERT_QUESTION
(
 P_APPLICATION_ID               IN  VARCHAR2     DEFAULT NULL,
 P_QUESTION_CODE		IN  VARCHAR2     DEFAULT NULL,
 P_APPLICATION_SHORT_NAME       IN  VARCHAR2     DEFAULT NULL,
 P_QUESTION     	        IN  VARCHAR2     DEFAULT NULL,
 P_FIND_CRITERIA                IN  VARCHAR2     DEFAULT NULL
);

/*===========================================================================

Function	UPDATE_QUESTION

Purpose		Phyically update the question content

============================================================================*/
procedure UPDATE_QUESTION
(
 P_APPLICATION_ID               IN  VARCHAR2     DEFAULT NULL,
 P_QUESTION_CODE		IN  VARCHAR2     DEFAULT NULL,
 P_APPLICATION_SHORT_NAME       IN  VARCHAR2     DEFAULT NULL,
 P_QUESTION     	        IN  VARCHAR2     DEFAULT NULL,
 P_FIND_CRITERIA                IN  VARCHAR2     DEFAULT NULL
);

/*===========================================================================

Function	question_confirm_delete

Purpose		Confirm the delete of the question content

============================================================================*/
procedure question_confirm_delete
(p_application_id  IN VARCHAR2   DEFAULT NULL,
p_question_code   IN VARCHAR2   DEFAULT NULL,
p_find_criteria   IN VARCHAR2   DEFAULT NULL
);

/*===========================================================================

Function	DELETE_QUESTION

Purpose		 Delete a new question

============================================================================*/
procedure DELETE_QUESTION
(
 P_APPLICATION_ID               IN  VARCHAR2     DEFAULT NULL,
 P_QUESTION_CODE		IN  VARCHAR2     DEFAULT NULL,
 P_FIND_CRITERIA                IN  VARCHAR2     DEFAULT NULL
);


/*===========================================================================

Function	DISPLAY_FUNCTIONS

Purpose		Display a list of existing questions based on the query criteria provided

============================================================================*/
procedure DISPLAY_FUNCTIONS
(
 P_QUESTION_CODE		IN  VARCHAR2     DEFAULT NULL,
 P_FIND_CRITERIA		IN  VARCHAR2     DEFAULT NULL

);

/*===========================================================================

Function	application_LOV

Purpose		Create the data for the applications list of values

============================================================================*/
procedure  application_LOV (
p_mode           in varchar2,
p_lov_name       in varchar2,
p_start_row      in number,
p_max_rows       in number,
p_hidden_value   in out varchar2,
p_display_value  in out varchar2,
p_result         out number);


/*===========================================================================

Function	EDIT_FUNCTION

Purpose		Edit function content

============================================================================*/
procedure EDIT_FUNCTION
(
 P_QUESTION_CODE		IN  VARCHAR2     DEFAULT NULL,
 P_FUNCTION_ID                  IN  VARCHAR2     DEFAULT NULL,
 P_FUNCTION_NAME                IN  VARCHAR2     DEFAULT NULL,
 P_INSERT                       IN  VARCHAR2     DEFAULT NULL,
 P_ERROR_MESSAGE                IN  VARCHAR2     DEFAULT NULL,
 P_FIND_CRITERIA                IN  VARCHAR2     DEFAULT NULL
);


/*===========================================================================

Function	FUNCTION_LOV

Purpose		Create the data for the function list of values

============================================================================*/
procedure  function_lov (
p_mode           in varchar2,
p_lov_name       in varchar2,
p_start_row      in number,
p_max_rows       in number,
p_hidden_value   in out varchar2,
p_display_value  in out varchar2,
p_result         out number);

/*===========================================================================

Function	INSERT_FUNCTION

Purpose		Insert an existing function

============================================================================*/
procedure INSERT_FUNCTION
(
 P_FUNCTION_ID                  IN  VARCHAR2     DEFAULT NULL,
 P_OLD_FUNCTION_NAME		IN  VARCHAR2     DEFAULT NULL,
 P_FUNCTION_NAME		IN  VARCHAR2     DEFAULT NULL,
 P_USER_FUNCTION_NAME           IN  VARCHAR2     DEFAULT NULL,
 P_QUESTION_CODE     	        IN  VARCHAR2     DEFAULT NULL,
 P_FIND_CRITERIA                IN  VARCHAR2     DEFAULT NULL
);

/*===========================================================================

Function	UPDATE_FUNCTION

Purpose		Update an existing function

============================================================================*/
procedure UPDATE_FUNCTION
(
 P_FUNCTION_ID                  IN  VARCHAR2     DEFAULT NULL,
 P_OLD_FUNCTION_NAME		IN  VARCHAR2     DEFAULT NULL,
 P_FUNCTION_NAME		IN  VARCHAR2     DEFAULT NULL,
 p_USER_FUNCTION_NAME           IN  VARCHAR2     DEFAULT NULL,
 P_QUESTION_CODE     	        IN  VARCHAR2     DEFAULT NULL,
 P_FIND_CRITERIA                IN  VARCHAR2     DEFAULT NULL
);

/*===========================================================================

Function	DELETE_FUNCTION

Purpose		Delete an existing function

============================================================================*/

procedure DELETE_FUNCTION
(
 P_FUNCTION_ID                  IN  VARCHAR2     DEFAULT NULL,
 P_FUNCTION_NAME		IN  VARCHAR2     DEFAULT NULL,
 P_QUESTION_CODE     	        IN  VARCHAR2     DEFAULT NULL,
 P_FIND_CRITERIA                IN  VARCHAR2     DEFAULT NULL
);

end icx_questions_admin;

 

/
