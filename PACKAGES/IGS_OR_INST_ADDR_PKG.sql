--------------------------------------------------------
--  DDL for Package IGS_OR_INST_ADDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_INST_ADDR_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSOI03S.pls 115.4 2002/02/12 17:08:09 pkm ship    $ */

  FUNCTION Get_PK_For_Validation (
    x_institution_cd IN VARCHAR2,
    x_addr_type IN VARCHAR2,
    x_start_dt IN DATE
    ) RETURN BOOLEAN ;

  PROCEDURE GET_FK_IGS_CO_ADDR_TYPE (
    x_addr_type IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_OR_INSTITUTION (
    x_institution_cd IN VARCHAR2
    );
  PROCEDURE GET_FK_IGS_PE_SUBURB_POSTCD (
    x_postcode IN VARCHAR2
    );
end IGS_OR_INST_ADDR_PKG;

 

/
