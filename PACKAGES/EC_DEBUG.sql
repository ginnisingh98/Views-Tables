--------------------------------------------------------
--  DDL for Package EC_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EC_DEBUG" AUTHID CURRENT_USER AS
-- $Header: ECDEBUGS.pls 120.2 2005/09/28 11:12:52 arsriniv ship $

TYPE prg_stack_record is RECORD
(
  program_name   varchar2(200),
  timestamp      date
);

TYPE  pl_stack is TABLE of prg_stack_record index by BINARY_INTEGER;

G_program_stack         pl_stack;
G_debug_level           NUMBER  :=0;
G_separator             VARCHAR2(3) := '==>';

PROCEDURE ENABLE_DEBUG
        (
        i_level                 IN      VARCHAR2  DEFAULT 0
        );

PROCEDURE DISABLE_DEBUG;

PROCEDURE SPLIT
        (
        i_string                IN      VARCHAR2
        );

PROCEDURE PUSH
        (
        i_program_name          IN      VARCHAR2
        );

PROCEDURE POP
       (
       i_program_name           IN      VARCHAR2
       );

FUNCTION INDENT_TEXT
       (
       i_main                   IN      NUMBER   DEFAULT 0
       ) RETURN VARCHAR2;

PROCEDURE PL
        (
        i_level                 IN      NUMBER default 0,
        i_app_short_name        IN      VARCHAR2,
        i_message_name          IN      VARCHAR2,
        i_token1                IN      VARCHAR2,
        i_value1                IN      VARCHAR2 DEFAULT NULL,
        i_token2                IN      VARCHAR2 DEFAULT NULL,
        i_value2                IN      VARCHAR2 DEFAULT NULL,
        i_token3                IN      VARCHAR2 DEFAULT NULL,
        i_value3                IN      VARCHAR2 DEFAULT NULL,
        i_token4                IN      VARCHAR2 DEFAULT NULL,
        i_value4                IN      VARCHAR2 DEFAULT NULL,
        i_token5                IN      VARCHAR2 DEFAULT NULL,
        i_value5                IN      VARCHAR2 DEFAULT NULL,
        i_token6                IN      VARCHAR2 DEFAULT NULL,
        i_value6                IN      VARCHAR2 DEFAULT NULL
        );

PROCEDURE PL
        (
        i_level                 IN      NUMBER,
        i_string                IN      VARCHAR2
        );

PROCEDURE PL
        (
        i_level                 IN      NUMBER,
        i_variable_name         IN      VARCHAR2,
        i_variable_value        IN      DATE
        );

PROCEDURE PL
        (
        i_level                 IN      NUMBER,
        i_variable_name         IN      VARCHAR2,
        i_variable_value        IN      NUMBER
        );

PROCEDURE PL
        (
        i_level                 IN      NUMBER,
        i_variable_name         IN      VARCHAR2,
        i_variable_value        IN      VARCHAR2
        );

PROCEDURE PL
        (
        i_level                 IN      NUMBER,
        i_variable_name         IN      VARCHAR2,
        i_variable_value        IN      BOOLEAN
        );

PROCEDURE FIND_POS
        (
        i_stack_tbl             IN      pl_stack,
        i_search_text           IN      varchar2,
        o_position              IN OUT NOCOPY  NUMBER
        ) ;


end EC_DEBUG;


 

/
