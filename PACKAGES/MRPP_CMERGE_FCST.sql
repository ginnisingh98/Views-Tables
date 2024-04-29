--------------------------------------------------------
--  DDL for Package MRPP_CMERGE_FCST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRPP_CMERGE_FCST" AUTHID CURRENT_USER as
		/* $Header: MRPPMGFS.pls 120.0 2005/05/25 03:46:28 appldev noship $ */

        procedure MERGE (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2);

END MRPP_CMERGE_FCST;

 

/
