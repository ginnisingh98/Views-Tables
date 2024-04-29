--------------------------------------------------------
--  DDL for Package IGS_OR_INSTITUTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_INSTITUTION_PKG" AUTHID CURRENT_USER AS
 /* $Header: IGSOI02S.pls 115.5 2002/03/27 05:41:52 pkm ship     $ */

  FUNCTION Get_PK_For_Validation (
    x_institution_cd IN VARCHAR2
    )RETURN BOOLEAN ;

  PROCEDURE GET_FK_IGS_OR_GOVT_INST_CD (
    x_govt_institution_cd IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_OR_INST_STAT (
    x_institution_status IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_OR_ORG_INST_TYPE (
    x_institution_type IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_OR_ORG_IN_CTLTYP (
    x_inst_control_type IN VARCHAR2
    );

end IGS_OR_INSTITUTION_PKG;

 

/
