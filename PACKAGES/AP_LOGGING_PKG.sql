--------------------------------------------------------
--  DDL for Package AP_LOGGING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_LOGGING_PKG" AUTHID CURRENT_USER as
/* $Header: apdologs.pls 120.4 2004/10/27 23:53:44 pjena noship $ */
                                                                         --
DBG_Pipe_Name         varchar2(30);
DBG_Max_Size          number(5);
DBG_Used_Size         number(5);
DBG_Lines_Entered     number(5);
DBG_Message_Level     number(5) := 0;
DBG_Debug_Stack       varchar2(5000);
DBG_Stat              char(16);
DBG_Log_Return_Code   number(1);
DBG_Currently_Logging boolean;
                                                                         --
procedure Ap_Begin_Log          (P_Calling_Module   IN     varchar2
                                ,P_Max_Size         IN     number
                                );
                                                                          --
function Ap_Pipe_Name
return   varchar2;
                                                                          --
procedure Ap_Pipe_Name_23       (P_Pipe_Name         OUT NOCOPY    varchar2);

function Ap_Log_Return_Code
return   number;
                                                                          --
procedure Ap_Begin_Block        (P_Message_Location  IN     varchar2);
                                                                          --
procedure Ap_End_Block          (P_Message_Location  IN     varchar2);
                                                                          --
procedure Ap_Indent;
                                                                          --
procedure Ap_Outdent;
                                                                          --
procedure Ap_Log                (P_Message          IN     varchar2
                                ,P_Message_Location IN     varchar2
                                                           default null
                                );
procedure Ap_End_Log;
                                                                          --
END AP_LOGGING_PKG;

 

/
