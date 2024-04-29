--------------------------------------------------------
--  DDL for Package BIX_AGT_COLLECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_AGT_COLLECT" AUTHID CURRENT_USER AS
/* $Header: bixsesso.pls 115.0 2004/09/14 00:41:25 anasubra noship $ */

-- Used by the Concurrent Process to collect and collate the data.
--
PROCEDURE COLLECT_AGT_DATA( errbuf out nocopy varchar2,
					   retcode out nocopy varchar2,
					   p_start_date IN VARCHAR2,
					   p_end_date   IN VARCHAR2
					   );
-- procedure used to cci data able to run on sqlplus
PROCEDURE COLLECT_AGT_DATA(p_start_date IN VARCHAR2,
					  p_end_date   IN VARCHAR2);
-- procedure used to cci data able to run on sqlplus
--PROCEDURE COLLECT_AGT_DATA;


END BIX_AGT_COLLECT;

 

/
