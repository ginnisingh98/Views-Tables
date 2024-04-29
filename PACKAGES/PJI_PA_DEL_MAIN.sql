--------------------------------------------------------
--  DDL for Package PJI_PA_DEL_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PA_DEL_MAIN" AUTHID CURRENT_USER as
  /* $Header: PJIDFW1S.pls 120.0.12010000.2 2009/08/23 06:10:53 arbandyo noship $ */

  g_retcode             varchar2(255);
  g_from_conc           varchar2(1);

  procedure DELETE
  (
    errbuf                    out nocopy varchar2,
    retcode                   out nocopy varchar2,
    p_operating_unit          in         number   default null,
    p_from_project            in         varchar2 default null,
    p_to_project              in         varchar2 default null,
    p_fp_option               in         varchar2 default null,
    p_plan_type               in         number   default null,
    p_wp_option               in         varchar2 default null,
    p_rep_only                in         varchar2 default 'Y'
  );

  procedure PRINT_OUTPUT(p_from_project IN varchar2,
                         p_to_project   IN varchar2);

  procedure DELETE_WP(p_project_id IN number,
                      p_rep_only   IN varchar2,
                      p_return_status OUT nocopy varchar2);

  procedure DELETE_FP(p_project_id IN number,
                      p_plan_type_id in number,
                      p_rep_only   IN varchar2,
                      p_return_status OUT nocopy varchar2);

end PJI_PA_DEL_MAIN;

/
