--------------------------------------------------------
--  DDL for Package QP_JAVA_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_JAVA_ENGINE" AUTHID CURRENT_USER AS
/* $Header: QPXINTJS.pls 120.0 2005/06/02 00:26:04 appldev noship $ */

--GLOBAL Constant holding the package name
G_PKG_NAME               CONSTANT  VARCHAR2(30) := 'QP_JAVA_ENGINE';

G_HARD_CHAR varchar2(1) := '&';
G_PATN_SEPERATOR varchar2(1) := '|';
G_PARAM_NAME_REQUEST_ID varchar2(15) := 'RequestId';
G_PARAM_NAME_PO_CTRL_PATN varchar2(15) :='POCtrlPatn';
G_PARAM_NAME_HPO_CTRL_PATN varchar2(15) :='HPOCtrlPatn';
G_PARAM_NAME_PROFL_PATN varchar2(15) :='ProfPatn';
G_PARAM_NAME_CTRL_PATN varchar2(15) :='CtrlPatn';
G_JPE_LINES_THRESHOLD number := nvl(FND_PROFILE.VALUE('QP_JPE_LINES_THRESHOLD'), 1500);

PROCEDURE REQUEST_PRICE( request_id IN NUMBER,
                        p_control_rec  IN   QP_PREQ_GRP.CONTROL_RECORD_TYPE,
                        x_return_status          OUT NOCOPY  VARCHAR2,
                        x_return_status_text     OUT NOCOPY  VARCHAR2

 );
END QP_JAVA_ENGINE;

 

/
