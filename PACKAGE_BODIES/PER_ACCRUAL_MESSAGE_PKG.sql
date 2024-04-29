--------------------------------------------------------
--  DDL for Package Body PER_ACCRUAL_MESSAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ACCRUAL_MESSAGE_PKG" as
/* $Header: peaclmes.pkb 115.1 99/07/17 18:25:07 porting ship $ */
g_package  varchar2(50) := 'per_accrual_message_pkg.';  -- Global package name
--
/* =====================================================================
   Define a package global table type of text values.
   Declare an instance of the table.
   ---------------------------------------------------------------------*/
--
TYPE global_message_t is TABLE OF varchar2(256) INDEX BY BINARY_INTEGER;
--
global_message global_message_t;
--
/* =====================================================================
   Name    : Put_Message
   Purpose : Insert a message string into the message table.
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function put_message(p_message varchar2) return number is
--
l_proc        varchar2(72) := g_package||'put_message';
l_next_pos    number;
--
begin
   hr_utility.set_location(l_proc, 5);
   --
   l_next_pos := global_message.count + 1;
   global_message(l_next_pos) := p_message;
   --
   hr_utility.set_location(l_proc, 10);
   return 0;
end put_message;
--
/* =====================================================================
   Name    : get_message
   Purpose : Return a message from the table
   Returns : Message string.
   ---------------------------------------------------------------------*/
function get_message(p_table_position number) return varchar2 is
--
l_proc        varchar2(72) := g_package||'get_message';
--
begin
   hr_utility.set_location(l_proc, 5);
   --
   return global_message(p_table_position);
   --
end get_message;
--
/* =====================================================================
   Name    : clear_table
   Purpose : Clears all messages from the table.
   ---------------------------------------------------------------------*/
procedure clear_table is
--
l_proc        varchar2(72) := g_package||'clear_table';
--
begin
   hr_utility.set_location(l_proc, 5);
   --
   global_message.delete;
   --
   hr_utility.set_location(l_proc, 10);
end clear_table;
--
/* =====================================================================
   Name    : count_messages
   Purpose : Return total number of messages in table
   ---------------------------------------------------------------------*/
function count_messages return number is
--
l_proc        varchar2(72) := g_package||'count_messages';
--
begin
   hr_utility.set_location(l_proc, 5);
   --
   return global_message.count;

end count_messages;
--
end per_accrual_message_pkg;

/
