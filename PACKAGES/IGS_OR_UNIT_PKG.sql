--------------------------------------------------------
--  DDL for Package IGS_OR_UNIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_UNIT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSOI10S.pls 115.7 2002/10/27 12:24:08 pkpatel ship $ */

  FUNCTION Get_PK_For_Validation (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN DATE
    ) RETURN BOOLEAN ;
/****** for  validating structure Id's ****/
  FUNCTION Get_PK_For_Str_Validation (
    x_org_unit_cd IN VARCHAR2
    ) RETURN BOOLEAN ;

  PROCEDURE GET_FK_IGS_OR_INSTITUTION (
    x_institution_cd IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_OR_STATUS (
    x_org_status IN VARCHAR2
    );

end IGS_OR_UNIT_PKG;

 

/
