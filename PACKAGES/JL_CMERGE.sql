--------------------------------------------------------
--  DDL for Package JL_CMERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_CMERGE" AUTHID CURRENT_USER AS
/* $Header: jlzzmrgs.pls 120.2 2005/10/30 02:05:59 appldev ship $ */

PROCEDURE merge (req_id NUMBER,
                 set_num NUMBER,
                 process_mode VARCHAR2) ;

END JL_CMERGE;

 

/
