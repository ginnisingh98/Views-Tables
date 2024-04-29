--------------------------------------------------------
--  DDL for Package OEXCPSVR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OEXCPSVR" AUTHID CURRENT_USER AS
/* $Header: OEXCPSVS.pls 115.2 99/07/16 08:11:59 porting shi $ */

PROCEDURE OE_SV_COPY_RULE
(	source_id			IN	NUMBER
,	destination_id			IN 	NUMBER
,       msg_text                        OUT 	VARCHAR2
,       return_status                   OUT 	NUMBER
);

END OEXCPSVR;

 

/
