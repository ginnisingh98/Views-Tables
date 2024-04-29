--------------------------------------------------------
--  DDL for Package PA_CC_GL_TRANS_CCDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CC_GL_TRANS_CCDS" 
--  $Header: PACCGLTS.pls 120.2 2005/08/10 14:08:20 eyefimov noship $       |
AUTHID CURRENT_USER AS

PROCEDURE TRANSFER_CCDS_TO_GL (
          P_Gl_Category          IN  VARCHAR2,
          P_Expenditure_Batch    IN  VARCHAR2,
          P_From_Project_Number  IN  VARCHAR2,
          P_To_Project_Number    IN  VARCHAR2,
          P_End_Gl_Date          IN  DATE,
          P_Debug_Mode           IN  VARCHAR2,
          RET_CODE               IN OUT NOCOPY VARCHAR2,
          ERRBUF                 IN OUT NOCOPY VARCHAR2 );

PROCEDURE Transfer_CCDS_Initialize ;

PROCEDURE log_message( p_message IN VARCHAR2) ;

PROCEDURE set_curr_function(p_function IN VARCHAR2) ;

PROCEDURE reset_curr_function ;

END PA_CC_GL_TRANS_CCDS;

 

/
