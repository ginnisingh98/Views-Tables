--------------------------------------------------------
--  DDL for Package FND_CONTEXT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CONTEXT_UTIL" AUTHID CURRENT_USER as
/* $Header: AFCPCTUS.pls 115.0 2004/01/27 00:20:44 vvengala ship $ */

  --
  -- PUBLIC VARIABLES
  --


  -- Exceptions

  -- Exception Pragmas

  --
  -- PUBLIC FUNCTIONS
  --

  --
  -- Name
  --   get_tag_value
  -- Purpose
  --   get_tag_value returns value for a variable from context_file
  --
  -- Parameters:
  --   node_name  - name of the node for which you want to get the variable
  --                value
  --   tag_name   - name of the tag from context file for which you want to
  --                get value.
  --
  --
  function get_tag_value(node_name  in varchar2,
		         tag_name   in varchar2) return varchar2;


 end FND_CONTEXT_UTIL;

 

/
