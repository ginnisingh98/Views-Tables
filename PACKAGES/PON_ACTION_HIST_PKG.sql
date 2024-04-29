--------------------------------------------------------
--  DDL for Package PON_ACTION_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_ACTION_HIST_PKG" AUTHID CURRENT_USER AS
-- $Header: PONHISTS.pls 120.0 2005/06/01 16:17:59 appldev noship $

PROCEDURE RecordHistory( p_OBJECT_ID           NUMBER,
                         p_OBJECT_ID2          NUMBER DEFAULT 0,
                         p_OBJECT_TYPE_CODE    VARCHAR2,
                         p_ACTION_TYPE         VARCHAR2,
                         p_ACTION_USER_ID      NUMBER,
                         p_ACTION_NOTE         VARCHAR2 DEFAULT NULL,
                         p_ACTION_REASON_CODE  VARCHAR2 DEFAULT NULL,
                         p_ACTION_USER_ID_NEXT NUMBER DEFAULT NULL,
                         p_CONTINUE            VARCHAR2 DEFAULT 'N');

END PON_ACTION_HIST_PKG;


 

/
