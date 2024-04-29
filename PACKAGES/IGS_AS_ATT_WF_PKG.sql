--------------------------------------------------------
--  DDL for Package IGS_AS_ATT_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_ATT_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAS52S.pls 115.0 2002/12/26 09:47:49 ddey noship $ */

PROCEDURE   Select_Approver (
                                                       Itemtype        IN           VARCHAR2,
                                                       Itemkey         IN            VARCHAR2,
                                                       Actid                IN            NUMBER,
                                                       Funcmode       IN            VARCHAR2,
                                                       Resultout         OUT NOCOPY        VARCHAR2
                                                     ) ;
END  IGS_AS_ATT_WF_PKG;

 

/
