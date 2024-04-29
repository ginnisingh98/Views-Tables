--------------------------------------------------------
--  DDL for Package OTAP_CMERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTAP_CMERGE" AUTHID CURRENT_USER as
/* $Header: otapcmer.pkh 120.0 2005/05/29 06:58:29 appldev noship $ */
--
PROCEDURE merge (req_id NUMBER,
		 set_num NUMBER,
		 process_mode VARCHAR2);
--
end OTAP_CMERGE;

 

/
