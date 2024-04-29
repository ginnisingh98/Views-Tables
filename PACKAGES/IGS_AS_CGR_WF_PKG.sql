--------------------------------------------------------
--  DDL for Package IGS_AS_CGR_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_CGR_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAS54S.pls 115.0 2002/12/26 09:49:35 ddey noship $ */

PROCEDURE   Select_Approver (
                              Itemtype        IN           VARCHAR2,
                              Itemkey         IN           VARCHAR2,
                              Actid           IN           NUMBER,
                              Funcmode        IN           VARCHAR2,
                              Resultout       OUT NOCOPY          VARCHAR2
                            ) ;

PROCEDURE   Approve_Request (
                              Itemtype                 	 IN        VARCHAR2,
                              Itemkey          		 	 IN        VARCHAR2,
                              Actid                      IN        NUMBER,
                              Funcmode         			 IN        VARCHAR2,
                              Resultout           	     OUT NOCOPY       VARCHAR2

                            ) ;
PROCEDURE   Reject_Request(
                            Itemtype                       IN       VARCHAR2,
                            Itemkey                        IN       VARCHAR2,
                            Actid                          IN       NUMBER,
                            Funcmode                       IN       VARCHAR2,
                            Resultout                      OUT NOCOPY      VARCHAR2
                          ) ;

PROCEDURE   Need_Information(
                              Itemtype                      IN      VARCHAR2,
                              Itemkey                       IN      VARCHAR2,
                              Actid                         IN      NUMBER,
                              Funcmode                      IN      VARCHAR2,
                              Resultout                     OUT NOCOPY     VARCHAR2
                           ) ;
END  IGS_AS_CGR_WF_PKG;

 

/
