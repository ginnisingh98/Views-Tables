--------------------------------------------------------
--  DDL for Package FND_CONC_SUMMARIZER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CONC_SUMMARIZER" AUTHID CURRENT_USER as
/* $Header: AFCPSUMS.pls 115.3 2003/02/28 09:55:58 aranjeet noship $ */
--
-- Function
--   execute_summarizer
-- Purpose
--   Executes the summarizer procedure provided as an argument
--   and return varchar of ';' separated name=value pairs
-- Arguments
--   sum_proc varchar2 Name of Summarizer Procedure
-- Notes
--   Return varchar2.
--

function execute_summarizer(sum_proc varchar2) return varchar2;

--
-- Procedure
--   insert_row
-- Purpose
--   Inserts a row in PL/SQL table P_SUMMARIZER
-- Arguments
--   Name  varchar2 name of the string
--   value varchar2 value of the name

procedure insert_row(name varchar2, value varchar2);

--
-- Procedure
--  purge_program
-- Purpose
--   Sample Summarizer Procedure to insert a row in PL/SQL table P_SUMMARIZER
-- Arguments
--   None
--

procedure purge_program;

end FND_CONC_SUMMARIZER;

 

/
