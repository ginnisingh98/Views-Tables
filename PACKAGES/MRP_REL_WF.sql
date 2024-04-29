--------------------------------------------------------
--  DDL for Package MRP_REL_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_REL_WF" AUTHID CURRENT_USER AS
/*$Header: MRPRLWFS.pls 120.0.12010000.2 2008/12/12 16:08:12 eychen ship $ */

TYPE NumTblTyp IS TABLE OF NUMBER;
TYPE date_arr IS TABLE OF date;

TYPE supply_project_rec  IS  RECORD(
            transaction_id  number,
            organization_id number,
            start_date      date,
            project_id      number,
            task_id         number);

TYPE supply_project_tbl IS TABLE OF supply_project_rec INDEX BY BINARY_INTEGER;

PROCEDURE init_source(p_user_name varchar2,p_resp_name VARCHAR2);

PROCEDURE launch_po_program
(
p_old_need_by_date IN DATE,
p_new_need_by_date IN DATE,
p_po_header_id IN NUMBER,
p_po_line_id IN NUMBER,
p_po_number IN VARCHAR2,
p_user IN VARCHAR2,
p_resp IN VARCHAR2,
p_qty IN NUMBER,
p_out OUT NOCOPY NUMBER
);

 PROCEDURE validate_pjm_selectAll(p_server_dblink IN varchar2,
                                 p_user_name     IN varchar2,
                                 p_plan_id       IN number,
                                 p_query_id      IN number);

 PROCEDURE   validate_pjm ( p_org             NUMBER,
                         p_project_id         NUMBER,
                         p_task_id            NUMBER,
                         p_start_date         DATE,
                         p_completion_date    DATE,
                         p_user_name          VARCHAR2,
                         p_valid OUT NOCOPY   VARCHAR2,
                         p_error OUT NOCOPY   VARCHAR2);



PROCEDURE launch_so_program
(
p_batch_id in number,
p_dblink in varchar2,
p_instance_id in number,
p_user IN VARCHAR2,
p_resp IN VARCHAR2,
p_out OUT NOCOPY NUMBER
);

function get_profile_value ( p_prof_name in varchar2
                           , p_user_name in varchar2
                           , p_resp_name in varchar2
                           , p_appl_name in varchar2
                           ) return varchar2;


END mrp_rel_wf;

/
