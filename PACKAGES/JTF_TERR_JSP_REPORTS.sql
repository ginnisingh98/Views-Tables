--------------------------------------------------------
--  DDL for Package JTF_TERR_JSP_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_JSP_REPORTS" AUTHID CURRENT_USER as
/* $Header: jtfpjrps.pls 120.0 2005/06/02 18:20:43 appldev ship $ */

---------------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERR_JSP_REPORTS
--    ---------------------------------------------------
--    PURPOSE
--      JTF/A Territories JSP Reports Package
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      05/18/2001    EIHSU           Created
--    End of Comments
--

TYPE report_out_rec_type IS record
  (column1       varchar2(2000),
   column2       varchar2(2000),
   column3       varchar2(2000),
   column4       varchar2(2000),
   column5       varchar2(2000),
   column6       varchar2(2000),
   column7       varchar2(2000),
   column8       varchar2(2000),
   column9       varchar2(2000),
   column10      varchar2(2000),
   column11      varchar2(2000),
   column12      varchar2(2000),
   column13      varchar2(2000),
   column14      varchar2(2000),
   column15      varchar2(2000),
   column16      varchar2(2000),
   column17      varchar2(2000),
   column18      varchar2(2000),
   column19      varchar2(2000),
   column20      varchar2(2000)
  );

TYPE report_out_tbl_type is table of report_out_rec_type;

PROCEDURE REPORT_CONTROL (p_report in varchar2,
                          p_param1 in varchar2,
                          p_param2 in varchar2,
                          p_param3 in varchar2,
                          p_param4 in varchar2,
                          p_param5 in varchar2,
                          x_result_tbl OUT NOCOPY report_out_tbl_type);




end;

 

/
