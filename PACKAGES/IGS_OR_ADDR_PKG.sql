--------------------------------------------------------
--  DDL for Package IGS_OR_ADDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_ADDR_PKG" AUTHID CURRENT_USER AS
 /* $Header: IGSOI07S.pls 115.4 2002/02/12 17:08:21 pkm ship    $ */

  FUNCTION Get_PK_For_Validation (
    x_org_unit_cd IN VARCHAR2,
    x_ou_start_dt IN DATE,
    x_addr_type IN VARCHAR2,
    x_start_dt IN DATE
    ) RETURN BOOLEAN ;

  PROCEDURE GET_FK_IGS_CO_ADDR_TYPE (
    x_addr_type IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_OR_UNIT (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN DATE
    );

  PROCEDURE GET_FK_IGS_PE_SUBURB_POSTCD (
    x_postcode IN NUMBER
    );

end IGS_OR_ADDR_PKG;

 

/
