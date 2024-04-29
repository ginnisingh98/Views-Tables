--------------------------------------------------------
--  DDL for Package BIS_ERROR_MESSAGE_FORM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_ERROR_MESSAGE_FORM_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVERFS.pls 115.6 99/11/01 09:29:03 porting ship  $ */
-- +=======================================================================+
-- |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
-- |                         All rights reserved.                          |
-- +=======================================================================+
-- | FILENAME                                                              |
-- |     BISVERFS.pls                                                      |
-- |                                                                       |
-- | DESCRIPTION                                                           |
-- |     Private API for displaying errors
-- | NOTES                                                                 |
-- |                                                                       |
-- | HISTORY                                                               |
-- | 15-APR-99 ansingha Creation
-- |
-- +=======================================================================+


-- Data Types: Records

G_ONLOAD_FUNCTION_NAME CONSTANT VARCHAR2(30) := 'displayMsgs';
G_ERROR_VARIABLE_NAME CONSTANT VARCHAR2(30) := 'Msg';

-- Procedure just puts the relevant function in the javascript
-- with all the messages displayed as specified in the p_msg_window_text
PROCEDURE Put_Errors
( p_api_version         IN NUMBER
, p_msg_window_text     IN VARCHAR2
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- Procedure just puts the relevant function in the javascript
-- with all the messages displayed as specified by caption and error table
PROCEDURE Put_Errors
( p_api_version         IN NUMBER
, p_caption             IN VARCHAR2
, p_error_Tbl           IN BIS_UTILITIES_PUB.Error_Tbl_Type
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Put_Errors
( p_api_version         IN  NUMBER
, p_caption             IN  VARCHAR2
, p_error_Tbl           IN  BIS_UTILITIES_PUB.Error_Tbl_Type
, p_form_name           IN  VARCHAR2
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Put_Errors
( p_error VARCHAR2
);
--
PROCEDURE Put_Error_Variable
( p_api_version         IN  NUMBER
, p_form_name           IN  VARCHAR2
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Put_Errors
( p_api_version         IN  NUMBER
, p_form_name           IN  VARCHAR2
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Put_Error_Variable
( p_api_version         IN  NUMBER
, p_form_name           IN  VARCHAR2
,  p_error_message      IN  VARCHAR2
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- Procedure returns a window_text_string to be used in any manner
PROCEDURE Get_Error_String
( p_api_version         IN NUMBER
, p_caption             IN VARCHAR2
, p_error_Tbl           IN BIS_UTILITIES_PUB.Error_Tbl_Type
, x_msg_window_text     OUT VARCHAR2
, x_return_status       OUT VARCHAR2
, x_error_Tbl           OUT BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
END BIS_ERROR_MESSAGE_FORM_PVT;

 

/
