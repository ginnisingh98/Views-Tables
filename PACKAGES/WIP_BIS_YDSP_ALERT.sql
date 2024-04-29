--------------------------------------------------------
--  DDL for Package WIP_BIS_YDSP_ALERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_BIS_YDSP_ALERT" AUTHID CURRENT_USER AS
/* $Header: wipbiaqs.pls 115.7 2002/11/28 19:18:53 rmahidha ship $ */

PROCEDURE PostActual( target_level_id        in number,
                      time_level_value       in varchar2,
                      org_level_value        in varchar2,
                      dimension1_level_value in varchar2,
                      dimension2_level_value in varchar2,
                      actual                 in number,
                      period_set_name        in varchar2);

PROCEDURE PostLevelActuals( target_level_id in number,
                            time_level in number,
                            org_level in number,
                            dimension1_level in number,
                            dimension2_level in number);

PROCEDURE StartFlow( time_level_value       in varchar2,
                     start_date             in date,
                     end_date               in date,
                     org_level_value        in varchar2,
                     dimension1_level_value in varchar2,
                     dimension2_level_value in varchar2,
                     prod_id                in number,
                     sob                    in varchar2,
                     le                     in varchar2,
                     ou                     in varchar2,
                     org                    in varchar2,
                     area                   in varchar2,
                     country                in varchar2,
                     prod                   in varchar2,
                     item                   in varchar2,
                     actual                 in number,
                     target                 in number,
                     plan_id                in number,
                     plan_name              in varchar2,
                     wf                     in varchar2,
                     resp_id                in number,
                     resp_name              in varchar2,
                     org_level              in number,
                     dimension1_level       in number,
                     dimension2_level       in number);

PROCEDURE CompareLevelTarget( target_level_id in number,
                              time_level in number,
                              org_level in number,
                              dimension1_level in number,
                              dimension2_level in number);

PROCEDURE WIP_Strt_Wf_Process(
       p_subject          IN varchar2,
       p_sob              IN varchar2,
       p_le               IN varchar2,
       p_ou               IN varchar2,
       p_org              IN varchar2,
       p_area             IN varchar2,
       p_country          IN varchar2,
       p_prod_cat         IN varchar2,
       p_prod             IN varchar2,
       p_period           IN varchar2,
       p_target           IN varchar2,
       p_actual           IN varchar2,
       p_wf_process       IN varchar2,
       p_role             IN varchar2,
       p_resp_id          IN number,
       p_report_name      IN varchar2,
       p_report_param     IN varchar2,
       x_return_status    OUT NOCOPY varchar2);

PROCEDURE Alert_Check;


END WIP_BIS_YDSP_ALERT;

 

/
