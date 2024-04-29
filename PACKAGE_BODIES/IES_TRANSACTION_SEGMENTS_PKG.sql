--------------------------------------------------------
--  DDL for Package Body IES_TRANSACTION_SEGMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_TRANSACTION_SEGMENTS_PKG" AS
  /* $Header: iestrsb.pls 115.5 2003/06/06 20:16:25 prkotha noship $ */
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'ies_transaction_segments_pkg';


  /* PRIVATE FUNCTION */

  FUNCTION getSegmentId(p_transaction_id IN NUMBER) return NUMBER IS
    segmentId NUMBER;

    TYPE segment_type IS REF CURSOR;
    segment segment_type;
  BEGIN
    OPEN segment FOR
    'SELECT max(segment_id)
       FROM ies_trans_segments
      WHERE transaction_id = :id' using p_transaction_id;

    FETCH segment INTO segmentId;
    CLOSE segment;
    return segmentId;
  END;

  /* PUBLIC PROCEDURES */

  PROCEDURE create_Segment (p_transaction_id IN NUMBER,
                            p_user_id IN number,
                            p_dscript_id IN NUMBER,
                            x_id OUT NOCOPY  NUMBER) IS
    sqlstmt   VARCHAR2(2000);
    transactionId NUMBER;
    seqval        NUMBER;
  BEGIN
    if (p_transaction_id = 0) then
        transactionId := ies_transaction_util_pkg.insert_transaction(p_user_id, p_dscript_id);
    else
        ies_transaction_util_pkg.update_transaction(p_transaction_id, 2, empty_clob(), p_user_id);
        transactionId := p_transaction_id;
    end if;

    execute immediate 'select ies_trans_segments_s.nextval from dual' into seqval;

    sqlStmt := 'insert into ies_trans_segments
                                   (segment_id,
                                    transaction_id,
                                    created_by,
                                    creation_date,
                                    start_time)
                            values (:seq,
                                    :p_transaction_id,
                                    :p_user_id,
                                    :1,
                                    :2)';
    execute immediate sqlStmt using seqval, transactionId, p_user_id, sysdate, sysdate;
    x_id := transactionId;

  END;


   PROCEDURE update_Segment (p_transaction_id IN NUMBER,
                             p_status IN NUMBER,
                             p_restart_clob IN CLOB,
                             p_user_id IN NUMBER) IS
    sqlstmt   VARCHAR2(2000);
    segmentId number;
  BEGIN
    segmentId := getSegmentId(p_transaction_id);
    ies_transaction_util_pkg.update_transaction(p_transaction_id,
                                            p_status,
                                            p_restart_clob,
                                            p_user_id);
    sqlStmt := 'update ies_trans_segments set end_time = :1,
                                               last_update_date = :2,
                                               last_updated_by = :3 where segment_id = :id';
    execute immediate sqlStmt using sysdate, sysdate, p_user_id, segmentId;
  END;



END ies_transaction_segments_pkg;

/
