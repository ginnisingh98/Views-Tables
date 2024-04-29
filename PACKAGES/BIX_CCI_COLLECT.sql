--------------------------------------------------------
--  DDL for Package BIX_CCI_COLLECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_CCI_COLLECT" AUTHID CURRENT_USER AS
/* $Header: BIXCCIVS.pls 115.4 2003/01/10 00:31:31 achanda noship $ */



TYPE CCI_NVT_PAIR_REC IS RECORD
 ( NAME   VARCHAR(64),
   VALUE  VARCHAR(500),
   TYPE   VARCHAR(32)
 );


--
-- Limitation is imposed as a result of using AQ to send the app data.
-- AQ allows VARRAYS to be passed in objects, but not nested tables.
-- Therefore, I tried to pick a limit that seemed to be more that what is
-- needed given the current use-case scenarios.
--
TYPE CCI_NVT_PAIR_ARY IS VARRAY(30) OF CCI_NVT_PAIR_REC;

--
-- Used by the Concurrent Process to collect and collate the data.
--
PROCEDURE COLLECT_CCI_DATA( errbuf out nocopy varchar2,
					   retcode out nocopy varchar2,
					   p_start_date IN VARCHAR2,
					   p_end_date   IN VARCHAR2
					   );
-- procedure used to cci data able to run on sqlplus
PROCEDURE COLLECT_CCI_DATA(p_start_date IN VARCHAR2,
					  p_end_date   IN VARCHAR2);
-- procedure used to cci data able to run on sqlplus
--PROCEDURE COLLECT_CCI_DATA;

PROCEDURE COLLATE_CALLS(p_start_date IN DATE,
				    p_end_date   IN DATE);

END BIX_CCI_COLLECT;

 

/
