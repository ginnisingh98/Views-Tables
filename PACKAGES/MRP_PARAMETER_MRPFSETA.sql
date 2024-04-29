--------------------------------------------------------
--  DDL for Package MRP_PARAMETER_MRPFSETA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_PARAMETER_MRPFSETA" AUTHID CURRENT_USER AS
/* $Header: MRPBISFS.pls 115.4 2002/02/12 23:20:14 svaidyan noship $ */

PROCEDURE Before_Parameter_MRPFSETA;
PROCEDURE After_Parameter_MRPFSETA;
PROCEDURE Parameter_FormView_MRPFSETA(force_display in varchar2 default null);
PROCEDURE Parameter_ActionView_MRPFSETA(
  P_BUSINESS_PLAN                         NUMBER,
  P_ORGANIZATION_ID                       NUMBER,
  P_PLAN1                             VARCHAR2,
  P_PLAN2                                  VARCHAR2,
  P_PERIOD_TYPE                           VARCHAR2
);

END MRP_PARAMETER_MRPFSETA;

 

/
