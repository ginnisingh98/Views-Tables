--------------------------------------------------------
--  DDL for Package HXC_RPT_LOAD_TC_SNAPSHOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RPT_LOAD_TC_SNAPSHOT" AUTHID CURRENT_USER AS
/* $Header: hxcrpttcsnpsht.pkh 120.3.12010000.2 2008/10/30 16:57:27 asrajago ship $ */

   TYPE ALIAS_REC IS RECORD
     (
        layout_id             NUMBER,
        alias_column          NUMBER,
        alias_name            VARCHAR2(50),
        alias_definition_id   NUMBER
     );

   TYPE NUMTABLE     IS TABLE OF NUMBER;
   TYPE VARCHARTABLE IS TABLE OF VARCHAR2(2000);
   TYPE DATETABLE    IS TABLE OF DATE;
   TYPE ALIASTAB     IS TABLE OF ALIAS_REC;
   TYPE FLOATTABLE   IS TABLE OF NUMBER(22,14);

   g_request_sysdate  DATE;


   PROCEDURE load_tc_snapshot ( errbuf          OUT NOCOPY VARCHAR2    ,
                                retcode         OUT NOCOPY NUMBER      ,
                                p_date_from     IN  VARCHAR2           ,
                                p_date_to       IN  VARCHAR2           ,
                                p_data_regen    IN  VARCHAR2           ,
                                p_record_save   IN  VARCHAR2           ,
                                p_org_id        IN  NUMBER DEFAULT NULL,
                                p_locn_id       IN  NUMBER DEFAULT NULL,
                                p_payroll_id    IN  NUMBER DEFAULT NULL,
                                p_supervisor_id IN  NUMBER DEFAULT NULL,
                                p_person_id     IN  NUMBER DEFAULT NULL
                               );

   PROCEDURE resource_where_clause (    p_date_from       IN DATE
				     ,  p_date_to         IN DATE
				     ,  p_org_id          IN NUMBER DEFAULT NULL
				     ,  p_locn_id         IN NUMBER DEFAULT NULL
				     ,  p_payroll_id      IN NUMBER DEFAULT NULL
				     ,  p_supervisor_id   IN NUMBER DEFAULT NULL
				     ,  p_person_id       IN NUMBER DEFAULT NULL
                                   );

   PROCEDURE load_tc_level_info (    p_resource_list    IN VARCHAR2
                                  ,  p_tc_from          IN DATE
                                  ,  p_tc_to            IN DATE
                                  ,  p_request_id       IN VARCHAR2 DEFAULT NULL
                                 );


   PROCEDURE load_detail_info ( p_request_sysdate  IN DATE
                               );

   PROCEDURE update_layout_ids ;

   PROCEDURE populate_attributes( p_layout_id IN  NUMBER   DEFAULT NULL,
                                  p_alias_tab OUT NOCOPY ALIASTAB
                                 );

   PROCEDURE translate_attributes( p_layout_id IN NUMBER DEFAULT NULL
                                  );

   PROCEDURE translate_aliases( p_layout_id IN NUMBER   DEFAULT NULL,
                                p_alias_tab IN ALIASTAB DEFAULT NULL
                               );

   PROCEDURE fetch_history_from_date;

   PROCEDURE update_transaction_ids(p_record_save   IN VARCHAR2);

   PROCEDURE log_time_capture( p_request_id      IN VARCHAR2,
                               p_request_sysdate IN DATE
                              );

   PROCEDURE update_last_touched_date;

   PROCEDURE update_timecard_comments;

   PROCEDURE translate_cla_reasons;

   PROCEDURE clear_history_data;

   PROCEDURE translate_created_by;

   PROCEDURE translate_last_updated_by;

   PROCEDURE insert_queries ( p_vo_name   IN VARCHAR2,
                              p_query     IN VARCHAR2);


END HXC_RPT_LOAD_TC_SNAPSHOT;


/
