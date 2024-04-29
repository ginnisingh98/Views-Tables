--------------------------------------------------------
--  DDL for Package MSC_X_USER_EXCEP_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_X_USER_EXCEP_GEN" AUTHID CURRENT_USER AS
/* $Header: MSCUDERS.pls 115.5 2002/11/06 19:28:49 praman ship $ */


   G_SUCCESS                    CONSTANT NUMBER := 0;
   G_WARNING                    CONSTANT NUMBER := 1;
   G_ERROR                      CONSTANT NUMBER := 2;

vBatchSize                      INTEGER := 1000;
vNotificationSep                VARCHAR2(3) := '@';
vPMFLabel                       VARCHAR2(30) := 'GETTHRESHOLD';
v_msg_name                      VARCHAR2(30) := 'USEREXCEPTIONNTFMESSAGE';

Procedure GenerateException(ERRBUF out nocopy Varchar2,
                            RETCODE out nocopy number,
                             pException_Id   In NUMBER,
                             pFullLoad       In VARCHAR2  default NULL );

Procedure ValidateDefinition( pExceptionId   In NUMBER ,
                              oSqlStmt       OUT NOCOPY VARCHAR2,
                              oErrorMessage  OUT NOCOPY VARCHAR2,
                              oErrorPosition OUT NOCOPY NUMBER
                              ) ;
procedure SEND_NTF(p_item_type      IN VARCHAR2,
                   pItemKey       IN VARCHAR2,
                   p_actid          IN NUMBER,
                   p_funcmode       IN VARCHAR2,
                   p_result         OUT NOCOPY VARCHAR2);

procedure setMesgAttribute(
command in varchar2,
context in varchar2,
attr_name in varchar2,
attr_type in varchar2,
text_value in out nocopy varchar2,
number_value in out nocopy number,
date_value in out nocopy date);


FUNCTION GET_MESSAGE_GROUP(p_exception_group in Number) RETURN Varchar2;
Procedure copyException(newExName      IN Varchar2,
                        newDescription IN Varchar2,
                        exceptionId    IN Number,
                        status         OUT NOCOPY NUMBER,
                        returnMessage  OUT NOCOPY VARCHAR2);
Procedure deleteException(exceptionId IN NUMBER,
                          status      OUT NOCOPY NUMBER,
                          returnMessage OUT NOCOPY VARCHAR2);

Procedure ValidateCalculation(pCalculationString in varchar2,
                              oErrorMessage  OUT NOCOPY VARCHAR2,
                              oErrorPosition OUT NOCOPY NUMBER );

Procedure  ValidateCondition(pAdvCondition  in varchar2,
                              oErrorMessage  OUT NOCOPY VARCHAR2,
                              oErrorPosition OUT NOCOPY NUMBER ) ;

Procedure RunCustomExcepWithNetting;

END MSC_X_USER_EXCEP_GEN;

 

/
