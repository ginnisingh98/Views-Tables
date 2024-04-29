--------------------------------------------------------
--  DDL for Package IGI_IAC_RETIREMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_RETIREMENT" AUTHID CURRENT_USER AS
--  $Header: igiiarts.pls 120.3.12000000.2 2007/10/16 14:26:49 sharoy ship $

 Function Do_IAC_Retirement (
                              P_Asset_Id         IN NUMBER ,
                              P_Book_Type_Code   IN VARCHAR2 ,
                              P_Retirement_Id    IN NUMBER ,
                              P_Calling_Function IN VARCHAR2,
                              P_Event_Id         IN NUMBER ) --R12 uptake

 RETURN BOOLEAN ;



END; --package spec

 

/
