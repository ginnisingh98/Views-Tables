--------------------------------------------------------
--  DDL for Package HR_PARAMETER_HRMNPSUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PARAMETER_HRMNPSUM" AUTHID CURRENT_USER as
/* $Header: hripmsum.pkh 120.2 2008/02/01 11:06:56 vjaganat noship $ */

PROCEDURE Before_Parameter_HRMNPSUM;

PROCEDURE After_Parameter_HRMNPSUM;

PROCEDURE Parameter_FormView_HRMNPSUM;

PROCEDURE Param25_ActionView_HRMNPSUM(
          P_ORGANIZATION_ID varchar2 default '-1',
          P_ORGANIZATION_NAME varchar2,
          ORGPRC varchar2 default 'SIRO',
          ORGVER number,
          BUS_ID number,
          BPL_ID number,
          GEOLVL varchar2 default '1',
          GEOVAL varchar2 default '-1',
          PRODID varchar2 default '-1',
          P_JOB_ID varchar2 default '-1',
          P_JOB_NAME varchar2,
          JOBCAT varchar2 default '__ALL__',
          BGTTYP varchar2,
          VIEWBY varchar2 default 'HR_BIS_TIME',
          FRQNCY varchar2 default 'CM',
          P_START_DATE_V varchar2,
          P_END_DATE_V varchar2);

end HR_Parameter_HRMNPSUM;

/
