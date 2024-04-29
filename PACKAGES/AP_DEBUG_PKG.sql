--------------------------------------------------------
--  DDL for Package AP_DEBUG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_DEBUG_PKG" AUTHID CURRENT_USER AS
/* $Header: apdebugs.pls 120.3 2003/06/17 18:25:39 isartawi noship $ */

PROCEDURE SPLIT
        (
        P_string                IN      VARCHAR2
        );

/* This function may be put in later
FUNCTION INDENT_TEXT
       (
       P_main                   IN      NUMBER
       ) RETURN VARCHAR2;
*/

-- In our pl/sql code, we generally report errors using this version of print
-- and never go beyond token2 and its value. So, in order to preserve the
-- defaulting order such that we did not have to give a lot of "commas",
-- the P_called_online param was placed in that spot.
PROCEDURE Print
        (
        P_debug                 IN      VARCHAR2,
        P_app_short_name        IN      VARCHAR2,
        P_message_name          IN      VARCHAR2,
        P_token1                IN      VARCHAR2,
        P_value1                IN      VARCHAR2 DEFAULT NULL,
        P_token2                IN      VARCHAR2 DEFAULT NULL,
        P_value2                IN      VARCHAR2 DEFAULT NULL,
        P_called_online         IN      BOOLEAN  DEFAULT FALSE,
        P_token3                IN      VARCHAR2 DEFAULT NULL,
        P_value3                IN      VARCHAR2 DEFAULT NULL,
        P_token4                IN      VARCHAR2 DEFAULT NULL,
        P_value4                IN      VARCHAR2 DEFAULT NULL,
        P_token5                IN      VARCHAR2 DEFAULT NULL,
        P_value5                IN      VARCHAR2 DEFAULT NULL,
        P_token6                IN      VARCHAR2 DEFAULT NULL,
        P_value6                IN      VARCHAR2 DEFAULT NULL
        );

PROCEDURE Print
        (
        P_debug                 IN      VARCHAR2,
        P_string                IN      VARCHAR2,
        P_called_online         IN      BOOLEAN  DEFAULT FALSE
        );

PROCEDURE Print
        (
        P_debug                 IN      VARCHAR2,
        P_variable_name         IN      VARCHAR2,
        P_variable_value        IN      DATE,
        P_called_online         IN      BOOLEAN  DEFAULT FALSE
        );

PROCEDURE Print
        (
        P_debug                 IN      VARCHAR2,
        P_variable_name         IN      VARCHAR2,
        P_variable_value        IN      NUMBER ,
        P_called_online         IN      BOOLEAN  DEFAULT FALSE
        );

PROCEDURE Print
        (
        P_debug                 IN      VARCHAR2,
        P_variable_name         IN      VARCHAR2,
        P_variable_value        IN      VARCHAR2,
        P_called_online         IN      BOOLEAN  DEFAULT FALSE
        );

-- In the following proc, the variable_value is passed before the
-- variable_name to avoid matching signatures with the (second from top)
-- overloaded version of Print.
PROCEDURE Print
        (
        P_debug                 IN      VARCHAR2,
        P_variable_value        IN      BOOLEAN,
        P_variable_name         IN      VARCHAR2,
        P_called_online         IN      BOOLEAN  DEFAULT FALSE
        );


end AP_DEBUG_PKG;


 

/
