--------------------------------------------------------
--  DDL for Package FV_CMERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_CMERGE" AUTHID CURRENT_USER AS
-- $Header: FVARCMGS.pls 120.3 2002/12/24 16:12:14 snama ship $
 procedure merge(req_id IN Number,
		 set_num IN NUMBER,
		 process_mode IN VARCHAR2);
end FV_CMERGE;

 

/
