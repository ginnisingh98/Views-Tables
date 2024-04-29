--------------------------------------------------------
--  DDL for Package Body FND_CONTEXT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONTEXT_UTIL" as
/* $Header: AFCPCTUB.pls 120.2 2005/08/19 19:43:09 tkamiya ship $ */

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
  --                tag_name - 'pathsep' or 'platform'
  --
  function get_tag_value(node_name  in varchar2,
		         tag_name   in varchar2) return varchar2 is
    lobd        CLOB;
    start_pos   INTEGER;
    end_pos     INTEGER;
    ret_string  varchar2(200);
    path_value  varchar2(200);

  begin
    SELECT text INTO lobd
      FROM fnd_oam_context_files
     WHERE upper(node_name) = upper(get_tag_value.node_name)
       and status in ('S','F')
       and name not in ('METADATA', 'TEMPLATE')
       and ctx_type = 'A'
       and rownum=1;

    start_pos := DBMS_LOB.instr(lobd, '<' || tag_name, 1,1);
    end_pos := DBMS_LOB.instr(lobd, '</' || tag_name, 1,1);

    ret_string := dbms_lob.substr(lobd, end_pos - start_pos, start_pos);

    ret_string := substr(ret_string,instr(ret_string,'>',1,1)+1);

     return ret_string;

    exception
       when others then
            fnd_message.set_name ('FND', 'SQL-Generic error');
            fnd_message.set_token ('ERRNO', sqlcode, FALSE);
            fnd_message.set_token ('REASON', sqlerrm, FALSE);
            fnd_message.set_token ('ROUTINE',
                                   'FND_CONTEXT_UTIL.GET_TAG_VALUE',
                                   FALSE);
            if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                            'fnd.plsql.FND_CONTEXT_UTIL.GET_TAG_VALUE.others',
                            FALSE);
            end if;
            return null;
  end;


 end FND_CONTEXT_UTIL;

/
