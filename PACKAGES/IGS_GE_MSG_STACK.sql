--------------------------------------------------------
--  DDL for Package IGS_GE_MSG_STACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GE_MSG_STACK" AUTHID CURRENT_USER AS
/* $Header: IGSGE09S.pls 115.4 2002/11/29 00:33:11 nsidana ship $ */

Procedure Initialize;

Function COUNT_MSG
return NUMBER;

Procedure ADD;

Procedure DELETE_MSG
(   p_msg_index IN    NUMBER	:=	NULL
);

Procedure GET
(   p_msg_index	    IN	NUMBER,
    p_encoded	    IN	VARCHAR2,
    p_data	    OUT NOCOPY	VARCHAR2,
    p_msg_index_out OUT NOCOPY	NUMBER
);

Procedure CONC_EXCEPTION_HNDL;

END IGS_GE_MSG_STACK;

 

/
