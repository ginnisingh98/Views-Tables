--------------------------------------------------------
--  DDL for Package WF_BES_FUNCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_BES_FUNCS" AUTHID CURRENT_USER as
/* $Header: WFBESFNS.pls 120.0 2005/09/02 12:46:44 mputhiya noship $ */

TYPE varchar_array is VARRAY(50) OF varchar2(128);

--
-- Procedure
--   GenerateStatic
--
-- Purpose
--    The procedure generates the static function calls
--
-- Returns:
--
--
Procedure GenerateStatic (retcode  out nocopy varchar2,
                          errbuf   out nocopy varchar2,
                     	  p_object_type in varchar2,
			  p_key    in varchar2);

--
-- Procedure
--   StaticGenerateRule
--
-- Purpose
--    This procedure generates the static generate and rule functions
--    based on the correlation id
--
--
Procedure StaticGenerateRule(p_correlation_ids in varchar_array);

--
-- Procedure
--   StaticQH
--
-- Purpose
--    The procedure generates the static enque/dequeue function calls
--
--
Procedure StaticQH(p_agent_names in varchar_array);


END WF_BES_FUNCS;

 

/
