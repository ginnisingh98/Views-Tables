--------------------------------------------------------
--  DDL for Package HRI_PARAMETERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_PARAMETERS" AUTHID CURRENT_USER AS
/* $Header: hripmgen.pkh 115.11 2002/12/06 15:32:42 cbridge ship $ */

-- Package Global Variables
  g_bus_id  number;
  g_orgver  number;
  g_report_name varchar2(8);

  cursor c_area is
    select '-1' area_code, ' ' area
    from dual
    union
    select lookup_code area_code, meaning area
    from fnd_lookups
    where lookup_type = 'AREA'
    order by 2;

-- This is the main procedure for this package.
-- It is referenced in the AOL function definition for the report.
-- It creates all the parameters and passes them to a
-- core BIS procedure to create all the formatting of the page

PROCEDURE Parameter_FormView
(p_report_name varchar2,
p_param_request varchar2
);

PROCEDURE Param_ActionView(
          P_ORGANIZATION_ID   varchar2 default '-1',
          P_ORGANIZATION_NAME varchar2,
          ORGPRC              varchar2 default 'SIRO',
          ORGVER              number,
          BUS_ID              number,
          BPL_ID              number,
          GEOLVL              varchar2 default '1',
          GEOVAL              varchar2 default '-1',
          PRODID              varchar2 default '-1',
          P_JOB_ID            varchar2 default '-1',
          P_JOB_NAME          varchar2,
          JOBCAT              varchar2 default '__ALL__',
          JOBCAT1             varchar2 default '__ALL__',
          JOBCAT2             varchar2 default '__ALL__',
          JOBCAT3             varchar2 default '__ALL__',
          BGTTYP              varchar2,
          VIEWBY              varchar2 default 'HR_BIS_TIME',
          FRQNCY              varchar2 default 'CM',
          P_START_DATE_V      varchar2,
          P_END_DATE_V        varchar2,
          P_LOCATION_ID       varchar2 default '-1',
          P_LOCATION_NAME     varchar2,
          BGT_ID              varchar2,
          COMPID              varchar2,
          CURRCD              varchar2,
          P_REPORT_DATE_V     varchar2,
          EMPAPL              varchar2,
          EXCCUR              varchar2,
          P_GRADE_ID          varchar2 default '-1', --bug 1863276 fixed
          P_GRADE_NAME        varchar2, --bug 1863276
          ORDERB              varchar2,
          PAYRLL              varchar2,
          PERFRT              varchar2,
          PFMEAS              varchar2,
          PROPRN              varchar2,
          SEPRSN              varchar2,
          DISPLY              varchar2,
          DCOUNT              varchar2,
          RPNAME              varchar2
);

PROCEDURE Before_Parameter_Form(
  p_function_code IN VARCHAR2
 ,p_rdf_filename  IN VARCHAR2
);

PROCEDURE After_Parameter_Form;

FUNCTION Display_Label(
  p_label_name IN VARCHAR2 )
RETURN VARCHAR2;

PROCEDURE Build_Business_Plan(
  params IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
);

PROCEDURE Build_Geog_Level(
  params IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
);

PROCEDURE Build_Geog_Value(
  params IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
);

PROCEDURE Build_Product (
  params IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
);

PROCEDURE Build_Job_Category (
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN OUT NOCOPY  NUMBER
 ,p_option IN   NUMBER
);

PROCEDURE Build_Budget (
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
 ,P_return_status IN OUT NOCOPY  NUMBER
);

-- cbridge, 28/06/2001, added to support lookup from pqh tables
PROCEDURE Build_pqh_Budget (
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
   ,i      IN     NUMBER
   , p_return_status IN OUT NOCOPY  NUMBER
);

PROCEDURE Build_Frequency (
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
);

PROCEDURE Geography_Cross_Validation;

PROCEDURE Build_Budget_ID(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
);

PROCEDURE Build_Competence_ID(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
 ,P_return_status IN OUT NOCOPY  NUMBER
);

PROCEDURE Build_Report_Currency(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
);

PROCEDURE Build_Display_By(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
);

PROCEDURE Build_Exclude_Currency(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
);

/*
This procedure was commented out by dsheth on 06-AUG-2001
to fix the bug 1863276.

PROCEDURE Build_Grade_ID(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
);
*/

PROCEDURE Build_Employee_Applicant(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
);

PROCEDURE Build_Order_By(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i        IN   NUMBER
 ,p_option IN   NUMBER
);

PROCEDURE Build_Incl_Subord(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i         IN   NUMBER
 ,p_option  IN   NUMBER
);

PROCEDURE Build_Payroll_ID(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
 ,P_OPTION      IN NUMBER
 ,P_return_status IN OUT NOCOPY  NUMBER
);

PROCEDURE Build_Rep_Dates(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i             IN NUMBER
 ,P_OPTION      IN NUMBER
);

PROCEDURE Build_lookup_param(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i             IN NUMBER
 ,P_LABEL       IN VARCHAR2
 ,P_FORM_NAME   IN VARCHAR2
 ,P_LOOKUP_TYPE IN VARCHAR2
 ,P_ALL_OPTION  IN VARCHAR2
);

PROCEDURE Build_Proficiency_Measure(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
);

PROCEDURE Build_View_By(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN     NUMBER
 ,p_option IN NUMBER
);

PROCEDURE Build_LOV(
  params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
 ,i      IN Number
 ,p_option IN NUMBER
 ,param_name IN varchar2
 ,LOV_name   IN varchar2
);

-- enhancement 1110938
PROCEDURE Build_Organization(
	params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
,	i IN NUMBER
,	p_option	IN NUMBER
);

-- enhancement 1110938
PROCEDURE Build_Job(
	params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
,	i IN NUMBER
,	p_option	IN NUMBER
,P_return_status IN OUT NOCOPY  NUMBER
);

-- enhancement 1110938
PROCEDURE Build_Location(
	params IN OUT NOCOPY  BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
,	i IN NUMBER
,	p_option	IN NUMBER
);

PROCEDURE LINK_HRCOMGAP;

PROCEDURE LINK_HRCOMPEO;

PROCEDURE LINK_HRCOMREC;

PROCEDURE LINK_HRMNPBGT;

PROCEDURE LINK_HRMNPCMP;

PROCEDURE LINK_HRMNPRAT;

PROCEDURE LINK_HRMNPSUM;

PROCEDURE LINK_HRORGBGT;

PROCEDURE LINK_HRORGCHG;

PROCEDURE LINK_HRORGSEP;

PROCEDURE LINK_HRSALCOM;

PROCEDURE LINK_HRSALGRG;

PROCEDURE LINK_HRSALGRP;

PROCEDURE LINK_HRSALSPD;

PROCEDURE LINK_HRSALTND;

PROCEDURE LINK_HRTRNSUC;

PROCEDURE LINK_HRUTLABH;

PROCEDURE LINK_HRUTLHRS;

-- cbridge, 28/06/2001, pqh budget reports
PROCEDURE LINK_HRMNPPSB;
PROCEDURE LINK_HRORGPSB;


-- Added to make the parameter page calls (above) look at the database
-- to find their list of values, rather than having them hard coded.
-- This reduces the chances of one place being updated, while the other
-- isn't.  - Bug #1349114 - M.J.Andrews - 31-July-2000

PROCEDURE LINK_PARAMPAGE
  ( p_report_name IN VarChar2);

END HRI_Parameters;


 

/
