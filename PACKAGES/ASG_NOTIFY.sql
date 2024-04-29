--------------------------------------------------------
--  DDL for Package ASG_NOTIFY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASG_NOTIFY" AUTHID CURRENT_USER as
/* $Header: asgnots.pls 115.1 2000/05/24 16:57:32 pkm ship    $*/
-- This package allows for real time logging of store procedures as well
-- comunications between two or more RDBMS processes
--
-- HISTORY
--   02-FEB-99  D Cassinera           Created.
Procedure Send_Message(text IN varchar2, location varchar2);
Procedure STOP;
Function  Read_PIPE RETURN varchar2;
FUNCTION  SEND_MSG (text in varchar2, location varchar2) return number;
END ASG_NOTIFY;

 

/
