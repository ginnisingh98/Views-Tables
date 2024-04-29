--------------------------------------------------------
--  DDL for Package Body IES_TRANSACTION_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_TRANSACTION_UTIL_PKG" AS
  /* $Header: iestrnb.pls 120.0 2005/06/03 07:34:55 appldev noship $ */
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'ies_transaction_util_pkg';


  /* PRIVATE PROCEDURE */

  PROCEDURE delete_old_data(p_transaction_Id IN NUMBER) IS
     panelDataStmt VARCHAR2(2000);
     questionDataStmt VARCHAR2(2000);
  BEGIN
     questionDataStmt := 'delete from ies_question_data where transaction_id = :1';
     execute immediate questionDataStmt using p_transaction_id;

     panelDataStmt := 'delete from ies_panel_data where transaction_id = :1';
     execute immediate panelDataStmt using p_transaction_id;

  END;

  FUNCTION get_transaction_status(p_transaction_id IN NUMBER) return NUMBER IS
    l_status NUMBER;

    TYPE transaction_status_type IS REF CURSOR;
    trans_status transaction_status_type;
  BEGIN
    OPEN trans_status FOR
    'SELECT nvl(status, 0)
       FROM ies_transactions
      WHERE transaction_id = :id for update' using p_transaction_id;

    FETCH trans_status INTO l_status;
    CLOSE trans_status;
    return l_status;
  END;


  /* PUBLIC PROCEDURES */

  PROCEDURE getTemporaryCLOB (x_clob OUT NOCOPY  CLOB) IS
  BEGIN
    DBMS_LOB.CreateTemporary(x_clob, TRUE, DBMS_LOB.CALL);
  END;


  FUNCTION  getRestartXMLData(p_transaction_Id IN NUMBER) RETURN CLOB IS
    TYPE  restartXML_Type IS REF CURSOR;
    restart   restartXML_Type;

    x_clob    CLOB;
    l_status  NUMBER;
  BEGIN
    l_status := get_transaction_status(p_transaction_id);
    if (l_status = 2) then
       raise_application_error(-20001, 'Error in restart');
    end if;

    OPEN restart FOR
    'SELECT restart_data
       FROM ies_transactions
      WHERE transaction_id = :id' using p_transaction_Id;

    FETCH restart INTO x_clob;
    CLOSE restart;
    return x_clob;
  END;

  PROCEDURE Update_Transaction(p_transaction_Id in number) IS
    sqlstmt   VARCHAR2(2000);
  BEGIN
    sqlStmt := 'update ies_transactions set status = null where transaction_id = :id';
    execute immediate sqlStmt using p_transaction_id;
  END;

  PROCEDURE Update_Transaction(p_transaction_Id in number,
                               p_status IN NUMBER,
                               p_restart_clob IN CLOB,
                               p_user_id IN NUMBER) IS
    sqlstmt   VARCHAR2(2000);
  BEGIN
    delete_Old_Data(p_transaction_Id);
    sqlStmt := 'update ies_transactions set status = :1,
                                      restart_data = :2,
                                  last_update_date = sysdate,
                                  end_time = sysdate,
                                  last_updated_by = :3 where transaction_id = :id';
    execute immediate sqlStmt using p_status, p_restart_clob, p_user_id, p_transaction_id;
  END;

  FUNCTION insert_transaction(p_user_Id IN NUMBER,
                               p_dscript_Id IN NUMBER) RETURN NUMBER IS
    transactionId NUMBER;
    sqlstmt VARCHAR2(2000);
  BEGIN
    SELECT ies_transactions_s.nextval INTO transactionId FROM dual;

    sqlstmt := 'insert into ies_transactions(transaction_id, created_by, creation_date, agent_id, dscript_id, start_time)
                         values(:1, :2, sysdate, :3, :4, sysdate)';
    execute immediate sqlstmt using transactionId, p_user_id, p_user_id, p_dscript_id;
    return transactionId;
  END;




END ies_transaction_util_pkg;

/
