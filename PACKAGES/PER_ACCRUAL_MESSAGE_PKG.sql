--------------------------------------------------------
--  DDL for Package PER_ACCRUAL_MESSAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ACCRUAL_MESSAGE_PKG" AUTHID CURRENT_USER as
/* $Header: peaclmes.pkh 115.1 99/07/17 18:25:19 porting ship $ */
--
/* =====================================================================
   Name    : Put_Message
   Purpose : Insert a message string into the message table.
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function put_message(p_message varchar2) return number;
--
/* =====================================================================
   Name    : get_message
   Purpose : Return a message from the table
   Returns : Message string.
   ---------------------------------------------------------------------*/
function get_message(p_table_position number) return varchar2;
--
/* =====================================================================
   Name    : clear_table
   Purpose : Clears all messages from the table.
   ---------------------------------------------------------------------*/
procedure clear_table;
--
/* =====================================================================
   Name    : count_messages
   Purpose : Return total number of messages in table
   ---------------------------------------------------------------------*/
function count_messages return number;
--
end per_accrual_message_pkg;

 

/
