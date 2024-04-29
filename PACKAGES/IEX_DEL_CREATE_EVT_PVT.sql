--------------------------------------------------------
--  DDL for Package IEX_DEL_CREATE_EVT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_DEL_CREATE_EVT_PVT" AUTHID CURRENT_USER AS
/* $Header: iexdevts.pls 120.0 2005/06/15 17:39:49 acaraujo noship $ */

PROCEDURE  RAISE_EVENT(
   	ERRBUF        OUT NOCOPY     VARCHAR2,
	RETCODE       OUT NOCOPY     VARCHAR2,
    P_REQUEST_ID  IN             NUMBER);


PROCEDURE write_log(mesg_level IN NUMBER, mesg IN VARCHAR2);

l_MsgLevel  NUMBER;

END IEX_DEL_CREATE_EVT_PVT;

 

/
