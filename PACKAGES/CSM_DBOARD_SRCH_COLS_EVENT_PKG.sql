--------------------------------------------------------
--  DDL for Package CSM_DBOARD_SRCH_COLS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_DBOARD_SRCH_COLS_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmedscs.pls 120.0 2005/12/05 01:19:42 saradhak noship $ */


PROCEDURE REFRESH_ACC(p_status OUT NOCOPY VARCHAR2,p_message OUT NOCOPY VARCHAR2 );

END CSM_DBOARD_SRCH_COLS_EVENT_PKG;

 

/
