--------------------------------------------------------
--  DDL for Package HRI_BPL_CONC_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_CONC_LOG" AUTHID CURRENT_USER AS
/* $Header: hribcncl.pkh 120.3 2005/11/24 05:23:33 jtitmas noship $ */
--
-- Global type for passing lists of table columns
--
TYPE col_list_rec_type IS RECORD
 (column_value   VARCHAR2(240),
  column_length  PLS_INTEGER);

TYPE col_list_tab_type IS TABLE OF col_list_rec_type
                       INDEX BY BINARY_INTEGER;

g_empty_col_list    col_list_tab_type;
--
-- Global varibale to store a row in the process log table
--
g_msg_log_record hri_adm_msg_log%rowtype;
--
FUNCTION get_last_collect_to_date
                 (p_process_code    IN VARCHAR2
                 ,p_table_name      IN VARCHAR2
                 )
RETURN VARCHAR2;
--
PROCEDURE delete_process_log( p_process_code    IN VARCHAR2 );
--
-- Generic output procedure
--
PROCEDURE output(p_text       IN VARCHAR2,
                 p_mode       IN VARCHAR2,
                 p_line_type  IN VARCHAR2,
                 p_col_list   IN col_list_tab_type DEFAULT g_empty_col_list,
                 p_format     IN VARCHAR2 DEFAULT null);
--
-- Procedure to store row in concurrent program log
--
PROCEDURE output(p_text  VARCHAR2);
--
-- Procedure to store row in concurrent program log if debug is enabled
--
PROCEDURE dbg(p_text  VARCHAR2);
--
-- Procedure to store the the process start information
--
PROCEDURE record_process_start(p_process_code         IN VARCHAR2);
--
PROCEDURE log_process_info
                  (p_msg_type              VARCHAR2
                  ,p_package_name          VARCHAR2 DEFAULT NULL
                  ,p_msg_group             VARCHAR2 DEFAULT NULL
                  ,p_msg_sub_group         VARCHAR2 DEFAULT NULL
                  ,p_sql_err_code          VARCHAR2 DEFAULT NULL
                  ,p_note                  VARCHAR2 DEFAULT NULL
                  ,p_effective_date        DATE     DEFAULT TRUNC(SYSDATE)
                  ,p_assignment_id         NUMBER   DEFAULT NULL
                  ,p_person_id             NUMBER   DEFAULT NULL
                  ,p_job_id                NUMBER   DEFAULT NULL
                  ,p_location_id           NUMBER   DEFAULT NULL
                  ,p_event_id              NUMBER   DEFAULT NULL
                  ,p_supervisor_id         NUMBER   DEFAULT NULL
                  ,p_person_type_id        NUMBER   DEFAULT NULL
                  ,p_formula_id            NUMBER   DEFAULT NULL
                  ,p_other_ref_id          NUMBER   DEFAULT NULL
                  ,p_other_ref_column      VARCHAR2 DEFAULT NULL
                  ,p_fnd_msg_name          VARCHAR2 DEFAULT NULL
                  );
--
PROCEDURE flush_process_info(p_package_name   IN VARCHAR2);
--
PROCEDURE log_process_end
                  (p_status        IN BOOLEAN
                  ,p_count         IN NUMBER   DEFAULT 0
                  ,p_message       IN VARCHAR2 DEFAULT NULL
                  ,p_period_from   IN DATE     DEFAULT to_date(NULL)
                  ,p_period_to     IN DATE     DEFAULT to_date(NULL)
                  ,p_attribute1    IN VARCHAR2 DEFAULT NULL
                  ,p_attribute2    IN VARCHAR2 DEFAULT NULL
                  ,p_attribute3    IN VARCHAR2 DEFAULT NULL
                  ,p_attribute4    IN VARCHAR2 DEFAULT NULL
                  ,p_attribute5    IN VARCHAR2 DEFAULT NULL
                  ,p_attribute6    IN VARCHAR2 DEFAULT NULL
                  ,p_attribute7    IN VARCHAR2 DEFAULT NULL
                  ,p_attribute8    IN VARCHAR2 DEFAULT NULL
                  ,p_attribute9    IN VARCHAR2 DEFAULT NULL
                  ,p_attribute10   IN VARCHAR2 DEFAULT NULL
                  --
                  -- New parameters for bug fix 4043240
                  --
                  ,p_process_type  IN VARCHAR2 DEFAULT NULL
                  ,p_package_name  IN VARCHAR2 DEFAULT NULL
                  ,p_full_refresh  IN VARCHAR2 DEFAULT NULL
                  ,p_attribute11   IN VARCHAR2 DEFAULT NULL
                  ,p_attribute12   IN VARCHAR2 DEFAULT NULL
                  ,p_attribute13   IN VARCHAR2 DEFAULT NULL
                  ,p_attribute14   IN VARCHAR2 DEFAULT NULL
                  ,p_attribute15   IN VARCHAR2 DEFAULT NULL
                  ,p_attribute16   IN VARCHAR2 DEFAULT NULL
                  ,p_attribute17   IN VARCHAR2 DEFAULT NULL
                  ,p_attribute18   IN VARCHAR2 DEFAULT NULL
                  ,p_attribute19   IN VARCHAR2 DEFAULT NULL
                  ,p_attribute20   IN VARCHAR2 DEFAULT NULL
                  );
--
PROCEDURE obsoleted_message(errbuf          OUT NOCOPY  VARCHAR2,
                            retcode         OUT  NOCOPY VARCHAR2);
--
END hri_bpl_conc_log;

 

/
