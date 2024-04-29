--------------------------------------------------------
--  DDL for Package MRPP_CMERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRPP_CMERGE" AUTHID CURRENT_USER as
	/* $Header: MRPPMRGS.pls 120.0 2005/05/24 18:16:46 appldev noship $ */
	procedure MERGE (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2);
end MRPP_CMERGE;

 

/
