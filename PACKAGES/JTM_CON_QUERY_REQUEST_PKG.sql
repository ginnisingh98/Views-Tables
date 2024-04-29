--------------------------------------------------------
--  DDL for Package JTM_CON_QUERY_REQUEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTM_CON_QUERY_REQUEST_PKG" AUTHID CURRENT_USER AS
/* $Header: jtmconqs.pls 120.1 2005/08/24 02:09:50 saradhak noship $*/

PROCEDURE Run_Query_Requests(
    P_Status       OUT NOCOPY  VARCHAR2,
    P_Message      OUT NOCOPY  VARCHAR2);

PROCEDURE Run_Query_Requests;

PROCEDURE WorkAround;

PROCEDURE FIX_DFF_ACC(
    P_Status       OUT NOCOPY  VARCHAR2,
    P_Message      OUT NOCOPY  VARCHAR2);

G_FINE     CONSTANT VARCHAR2(10) := 'Fine';
G_WARNING  CONSTANT VARCHAR2(10) := 'Warning';
G_ERROR    CONSTANT VARCHAR2(10) := 'Error';
G_RUNNING  CONSTANT VARCHAR2(10) := 'Running';

END JTM_CON_QUERY_REQUEST_PKG;

 

/
