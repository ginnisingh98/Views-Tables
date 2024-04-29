--------------------------------------------------------
--  DDL for Package PER_GENERIC_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_GENERIC_REPORT_PKG" AUTHID CURRENT_USER AS
/* $Header: pergenrp.pkh 115.0 99/07/18 14:47:23 porting ship $ */
/*===========================================================================+
|		Copyright (C) 1995 Oracle Corporation                        |
|		         All rights reserved 				     |
|									     |
+===========================================================================*/
--
 /*
   Name
     PER_GENERIC_REPORT_PKG
   Purpose
    Contains all the procedures to support the generation of customisable
    candidate list reports.

    Notes:

    History
      18-Sep-1995  fshojaas		70.0		Date Created.
		   gperry
      24-Jul-1997  teyres               70.1            Changed as to is on create or replace line
      25-Jun-97    teyres               110.1/70.2      110.1 and 70.2 are the same


============================================================================*/
  --
  -- This procedure is an example of a one parameter customisable report. The
  -- procedure includes some example custom formatting.
  --
  procedure example1(p_param_1 varchar2
                    );
  --
  -- This procedure is an example of a two parameter customisable report. The
  -- procedure includes some example custom formatting.
  --
  procedure example2(p_param_1 varchar2,
                     p_param_2 varchar2
                    );
  --
  -- This procedure is an example of a three parameter customisable report.
  -- The procedure includes some example custom formatting.
  --
  procedure example3(p_param_1 varchar2,
                     p_param_2 varchar2,
                     p_param_3 varchar2
                    );
  --
  -- This procedure is used to define report header, footer and title
  -- requirements. This also calls the appropriate procedure (example1,
  -- example2,example3) based on the report name being processed.
  --
  procedure generate_report(p_report_name varchar2,
                            p_param_1     varchar2,
                            p_param_2     varchar2,
                            p_param_3     varchar2,
                            p_param_4     varchar2,
                            p_param_5     varchar2,
                            p_param_6     varchar2,
                            p_param_7     varchar2,
                            p_param_8     varchar2,
                            p_param_9     varchar2,
                            p_param_10    varchar2,
                            p_param_11    varchar2,
                            p_param_12    varchar2
                           );
  --
  -- This function is used as an initial validation check before submitting
  -- the report to the concurrent request manager.
  --
  function launch_report(p_report_name    varchar2,
                         p_param_1        varchar2,
                         p_param_2        varchar2,
                         p_param_3        varchar2,
                         p_param_4        varchar2,
                         p_param_5        varchar2,
                         p_param_6        varchar2,
                         p_param_7        varchar2,
                         p_param_8        varchar2,
                         p_param_9        varchar2,
                         p_param_10       varchar2,
                         p_param_11       varchar2,
                         p_param_12       varchar2
                        ) return boolean;
--
END PER_GENERIC_REPORT_PKG;

 

/
