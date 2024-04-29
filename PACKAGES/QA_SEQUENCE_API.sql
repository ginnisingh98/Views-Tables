--------------------------------------------------------
--  DDL for Package QA_SEQUENCE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_SEQUENCE_API" AUTHID CURRENT_USER AS
/* $Header: qltseqs.pls 120.3.12010000.1 2008/07/25 09:22:21 appldev ship $ */

 -- Gapless Sequence Proj. rponnusa Wed Jul 30 04:52:45 PDT 2003
 TYPE ID_TABLE IS TABLE OF NUMBER index by BINARY_INTEGER;


 FUNCTION get_nextval(p_char_id NUMBER) RETURN NUMBER;

 -- Gapless Sequence Proj. Added new parameter p_commit
 FUNCTION get_next_seq(p_char_id NUMBER,
                       p_commit BOOLEAN DEFAULT NULL) RETURN VARCHAR2;

 FUNCTION max_sequence RETURN NUMBER;

 -- Added the below procedure for bug 2548710. rponnusa Mon Nov 18 03:49:15 PST 2002
 PROCEDURE FILL_SEQ_TABLE (p_char_id IN NUMBER,
                           p_count   IN NUMBER,
                           x_seq_table  OUT NOCOPY  QLTTRAWB.CHAR50_TABLE);


 -- Gapless Sequence Proj Start. rponnusa Wed Jul 30 04:52:45 PDT 2003

 FUNCTION get_nextval_nocommit(p_char_id NUMBER) RETURN NUMBER;

 -- Bug 5335509. SHKALYAN 15-Jun-2006
 -- This function is needed as public becuase we are including
 -- a call to this function to get the translated value for
 -- 'Automatic' while inserting background results.
 FUNCTION get_sequence_default_value RETURN VARCHAR2;

 PROCEDURE generate_seq_for_Txn(p_collection_id             NUMBER,
                                p_return_status  OUT NOCOPY VARCHAR2);

 PROCEDURE generate_seq_for_DDE(p_txn_header_id             NUMBER,
                                p_plan_id                   NUMBER,
                                p_return_status  OUT NOCOPY VARCHAR2);

 -- Bug 3160651. Added following overloaded procedure.
 -- rponnusa Thu Sep 25 02:24:28 PDT 2003

 PROCEDURE generate_seq_for_DDE(p_txn_header_id             NUMBER,
                                p_plan_id                   NUMBER,
                                p_return_status  OUT NOCOPY VARCHAR2,
                                x_message        OUT NOCOPY VARCHAR2);

 PROCEDURE audit_sequence_values(p_plan_id       NUMBER,
                                 p_collection_id NUMBER,
                                 p_occurrence    NUMBER,
                                 p_enabled_flag  VARCHAR2);

 PROCEDURE audit_sequence_values(p_plan_ids             DBMS_SQL.number_table,
                                 p_collection_ids       DBMS_SQL.number_table,
                                 p_occurrences          DBMS_SQL.number_table,
                                 p_parent_plan_id       NUMBER,
                                 p_parent_collection_id NUMBER,
                                 p_parent_occurrence    NUMBER);

 PROCEDURE sequence_audit_log(p_plan_id           NUMBER,
                              p_collection_id     NUMBER,
                              p_occurrence        NUMBER,
                              p_char_id           NUMBER,
                              p_txn_header_id     NUMBER,
                              p_sequence_value    VARCHAR2,
                              p_user_id           NUMBER,
                              p_source_code       VARCHAR2,
                              p_source_id         NUMBER,
                              p_audit_type        VARCHAR2,
                              p_audit_date        DATE,
                              p_last_update_date  DATE,
                              p_last_updated_by   NUMBER,
                              p_creation_date     DATE,
                              p_created_by        NUMBER,
                              p_last_update_login NUMBER);

 PROCEDURE delete_auditinfo_for_Txn(p_collection_id NUMBER);

 PROCEDURE delete_auditinfo_for_DDE(p_txn_header_id NUMBER);

 -- Gapless Sequence Proj End

  -- Bug 5368983. saugupta Fri, 01 Sep 2006 02:00:42 -0700 PDT
  -- Generating Sequence Number for OA Txn Integration Flows.
 /**
  ** generate_seq_for_txninteg
  ** Description:
  **     This procedure is called from OA Txn Integ flows to
  **     generate Sequence Numbers.
  **
  ** Arguments:
  **     p_collection_id: takes the new collection_id
  **
  ** Returns:
  **     Sequence Message String
  **
  */

 PROCEDURE generate_seq_for_txninteg(p_collection_id IN NUMBER,
                                    p_return_status OUT nocopy VARCHAR2,
                                    x_message OUT nocopy VARCHAR2);

 --
 -- Bug 5955808
 -- New procedure to support sequence generation in
 -- Mobile application
 -- ntungare Mon Jul 23 12:36:31 PDT 2007
 --
 PROCEDURE generate_seq_for_txn(p_collection_id             NUMBER,
                                p_return_status  OUT NOCOPY VARCHAR2,
                                x_message        OUT NOCOPY VARCHAR2);



END QA_SEQUENCE_API;

/
