--------------------------------------------------------
--  DDL for Package RCV_CALL_LCM_WS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_CALL_LCM_WS" AUTHID CURRENT_USER AS
/* $Header: RCVLCMIS.pls 120.0.12010000.2 2008/10/16 18:15:17 musinha noship $ */

TYPE rti_rec IS TABLE OF rcv_transactions_interface%ROWTYPE;

PROCEDURE insertLCM( x_errbuf          	OUT NOCOPY VARCHAR2
                    ,x_retcode           OUT NOCOPY NUMBER);


END RCV_CALL_LCM_WS;


/
