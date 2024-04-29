--------------------------------------------------------
--  DDL for Package Body MRPP_CMERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRPP_CMERGE" as
	/* $Header: MRPPMRGB.pls 120.0 2005/05/25 03:41:54 appldev noship $ */
	procedure MERGE (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is
	begin
          MRPP_cmerge_fcst.merge(req_id, set_num, process_mode);
	end MERGE;
end MRPP_CMERGE;

/
