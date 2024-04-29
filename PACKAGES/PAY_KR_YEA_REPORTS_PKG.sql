--------------------------------------------------------
--  DDL for Package PAY_KR_YEA_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_YEA_REPORTS_PKG" AUTHID CURRENT_USER as
/* $Header: pykryearept.pkh 120.0.12000000.1 2007/02/09 05:51:16 viagarwa noship $ */
--------------------------------------------------------------------------------
function submit_yea_report(
        p_bus_grp_id    number,
        p_bus_plc_id    number,
        p_year          varchar2,
        p_asg_id        number,
        p_assact_id     number,
        p_report_name   varchar2
) return number ;
--------------------------------------------------------------------------------
function submit_xml_report (
        p_bus_grp_id    in number,
        p_bus_plc_id    in number,
        p_year          in varchar2,
        p_asg_id        in number,
        p_assact_id     in number,
        p_report_name   in varchar2
) return number ;
--------------------------------------------------------------------------------
end pay_kr_yea_reports_pkg ;

 

/
