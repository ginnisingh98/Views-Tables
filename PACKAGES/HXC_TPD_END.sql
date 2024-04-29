--------------------------------------------------------
--  DDL for Package HXC_TPD_END
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TPD_END" AUTHID CURRENT_USER as
/* $Header: hxcendtp.pkh 120.1.12010000.3 2009/02/18 15:54:51 asrajago ship $ */


-- Resource_Id added since it needs to be saved along with the start and end period.
-- This way, while retrieving the missing TC periods, we can ensure only that resource's data is retrieved.

TYPE period_dates IS RECORD
(START_TIME  hxc_time_building_blocks.start_time%type
,STOP_TIME   hxc_time_building_blocks.stop_time%type
,RESOURCE_ID hxc_time_building_blocks.resource_id%type
);


TYPE time_periods_table is TABLE OF
period_dates
INDEX BY BINARY_INTEGER;

g_time_periods time_periods_table;



-- Bug 6998662
-- Added new record and associative array types for
-- storing and sorting preferences.

TYPE MISTC_PREF_TABLE_ROW IS RECORD
( resource_id       NUMBER(15),
  start_date        DATE,
  stop_date         DATE,
  attributelist     VARCHAR2(400));

TYPE MISTC_PREF_TABLE IS TABLE OF MISTC_PREF_TABLE_ROW INDEX BY BINARY_INTEGER;

TYPE MISTC_PREF_LIST_ROW IS RECORD
( resource_id       NUMBER(15),
  tcard_req_table   mistc_pref_table,
  appln_set_table   mistc_pref_table );

TYPE MISTC_PREF_LIST IS TABLE OF MISTC_PREF_LIST_ROW INDEX BY BINARY_INTEGER;

g_mistc_pref_list MISTC_PREF_LIST;



-- New function added.
FUNCTION Appl_Id
   (p_person_id in number
   ) Return number;


FUNCTION get_supervisor_name
  (p_supervisor_id         in number,
   p_effective_date        in date
   ) Return varchar2 ;

-- Extra parameter added.

-- Bug 6998662
-- Added the last two parameters for effective querying.

FUNCTION populate_missing_time_periods
  (p_resource_id         in number,
   p_assignment_id       in number,
   p_start_date          in date,
   p_end_date            in date,
   p_appln_set_id        in number,
   p_tim_rec_id          in number

   ) Return number ;

-- Extra parameter added.

-- Bug 6998662
-- Added assignment id
FUNCTION retrieve_missing_time_periods
  (p_resource_id   in number,
   p_assignment_id in number default null,
   p_rownum        in number) Return Varchar2 ;

function return_archived_status(p_date date)
return varchar2;


-- Bug 6998662
-- Added the following procedures.
-- Detailed descriptions available in body.

PROCEDURE sort_pref_table( p_in_table  IN   MISTC_PREF_TABLE,
                           p_out_table OUT NOCOPY  MISTC_PREF_TABLE);





FUNCTION load_preferences( p_resource_id   IN NUMBER,
                           p_start_date    IN DATE,
                           p_stop_date     IN DATE )
RETURN NUMBER                            ;




PROCEDURE load_preferences( p_resource_id   IN NUMBER,
                            p_start_date    IN DATE,
                            p_stop_date     IN DATE );




FUNCTION check_tc_required ( p_resource_id           IN NUMBER,
                             p_start_date      	     IN DATE DEFAULT NULL,
                             p_stop_date       	     IN DATE DEFAULT NULL,
                             p_evaluation_start_date IN DATE,
                             p_evaluation_stop_date  IN DATE,
                             p_time_rec_id           IN NUMBER )
RETURN VARCHAR2 ;




FUNCTION check_appln_set ( p_resource_id              IN NUMBER,
                           p_start_date               IN DATE DEFAULT NULL,
                           p_stop_date                IN DATE DEFAULT NULL,
                           p_evaluation_start_date    IN DATE,
                           p_evaluation_stop_date     IN DATE)
RETURN varchar2;




PROCEDURE clear_global_tables;




FUNCTION check_appln_set_id (p_resource_id     IN NUMBER,
                             p_start_date      IN DATE,
                             p_stop_date       IN DATE,
                             p_appln_set_id    IN NUMBER )
RETURN Varchar2;




FUNCTION get_full_name(p_resource_id     IN NUMBER,
                       p_date            IN DATE )
RETURN VARCHAR2;




FUNCTION person_type(p_date        IN DATE,
                     p_resource_id IN NUMBER)
RETURN VARCHAR2 ;


end hxc_tpd_end;

/
