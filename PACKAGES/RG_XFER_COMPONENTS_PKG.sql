--------------------------------------------------------
--  DDL for Package RG_XFER_COMPONENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_XFER_COMPONENTS_PKG" AUTHID CURRENT_USER as
/* $Header: rgixcmps.pls 120.1 2003/04/29 00:48:01 djogg ship $ */


PROCEDURE init(
            SourceCOAId NUMBER,
            TargetCOAId NUMBER,
            LinkName    VARCHAR2,
            ApplId      NUMBER);


PROCEDURE copy_component(ComponentType VARCHAR2,
                         ComponentName VARCHAR2);


END RG_XFER_COMPONENTS_PKG;

 

/
