--------------------------------------------------------
--  DDL for Package Body AHL_OSP_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_OSP_UTIL_PKG" AS
/* $Header: AHLVOPUB.pls 120.5 2008/05/05 15:22:47 mpothuku ship $ */

--G_DEBUG        VARCHAR2(1)            :=FND_PROFILE.VALUE('AHL_API_FILE_DEBUG_ON');
G_DEBUG                VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;

G_LOG_PREFIX   CONSTANT VARCHAR2(100) := 'ahl.plsql.AHL_OSP_UTIL_PKG';

/* Function declarations */
/* Added by jaramana on March 14, 2006 for fixing Perf Bug 4914529 */
FUNCTION GET_OSP_LINE_INSTANCE_NUMBER(p_workorder_id IN NUMBER,
                                      p_serial_number IN VARCHAR2,
                                      p_lot_number IN VARCHAR2) RETURN VARCHAR2;

--Added by mpothuku on 09-Jan-2008 to implement the Osp Receiving feature
FUNCTION GET_IB_SUBTRANS_INSTANCE_ID(p_oe_line_id IN NUMBER) RETURN NUMBER;

-- Start of Comments --
--  Procedure name    : Log_Transaction
--  Type              : Private
--  Function          : Writes the details about a transaction in the Log Table
--  Pre-reqs    :
--  Parameters  :
--
--  Log_Transaction Parameters:
--      p_trans_type_code               IN      VARCHAR2     Required
--      p_src_doc_id                    IN      VARCHAR2     Required
--      p_src_doc_type_code             IN      VARCHAR2     Required
--      p_dest_doc_id                   IN      VARCHAR2     Required
--      p_dest_doc_type_code            IN      VARCHAR2     Required
--      p_attribute_category            IN      VARCHAR2     Default NULL
--      p_attribute1                    IN      VARCHAR2     Default NULL
--      p_attribute2                    IN      VARCHAR2     Default NULL
--      p_attribute3                    IN      VARCHAR2     Default NULL
--      p_attribute4                    IN      VARCHAR2     Default NULL
--      p_attribute5                    IN      VARCHAR2     Default NULL
--      p_attribute6                    IN      VARCHAR2     Default NULL
--      p_attribute7                    IN      VARCHAR2     Default NULL
--      p_attribute8                    IN      VARCHAR2     Default NULL
--      p_attribute9                    IN      VARCHAR2     Default NULL
--      p_attribute10                   IN      VARCHAR2     Default NULL
--      p_attribute11                   IN      VARCHAR2     Default NULL
--      p_attribute12                   IN      VARCHAR2     Default NULL
--      p_attribute13                   IN      VARCHAR2     Default NULL
--      p_attribute14                   IN      VARCHAR2     Default NULL
--      p_attribute15                   IN      VARCHAR2     Default NULL
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
PROCEDURE Log_Transaction
(
    p_trans_type_code       IN VARCHAR2,
    p_src_doc_id            IN NUMBER,
    p_src_doc_type_code     IN VARCHAR2,
    p_dest_doc_id           IN NUMBER,
    p_dest_doc_type_code    IN VARCHAR2,
    p_attribute_category    IN VARCHAR2,
    p_attribute1            IN VARCHAR2,
    p_attribute2            IN VARCHAR2,
    p_attribute3            IN VARCHAR2,
    p_attribute4            IN VARCHAR2,
    p_attribute5            IN VARCHAR2,
    p_attribute6            IN VARCHAR2,
    p_attribute7            IN VARCHAR2,
    p_attribute8            IN VARCHAR2,
    p_attribute9            IN VARCHAR2,
    p_attribute10           IN VARCHAR2,
    p_attribute11           IN VARCHAR2,
    p_attribute12           IN VARCHAR2,
    p_attribute13           IN VARCHAR2,
    p_attribute14           IN VARCHAR2,
    p_attribute15           IN VARCHAR2) IS

    l_osp_order_log_id NUMBER;
    L_DUMMY_TXN_STATUS_CODE CONSTANT VARCHAR2(30) := 'COMPLETE';

BEGIN

  AHL_OSP_ORDER_LOGS_PKG.INSERT_ROW(
    X_OSP_ORDER_LOG_ID          => l_osp_order_log_id,
    X_OBJECT_VERSION_NUMBER     => 1,
    X_LAST_UPDATE_DATE          => SYSDATE,
    X_LAST_UPDATED_BY           => fnd_global.user_id,
    X_CREATION_DATE             => SYSDATE,
    X_CREATED_BY                => fnd_global.user_id,
    X_LAST_UPDATE_LOGIN         => fnd_global.login_id,
    X_TRANSACTION_DATE          => SYSDATE,
    X_TRANSACTION_TYPE_CODE     => p_trans_type_code,
    X_SOURCE_DOCUMENT_ID        => p_src_doc_id,
    X_SOURCE_DOCUMENT_TYPE_CODE => p_src_doc_type_code,
    X_DESTINATION_DOCUMENT_ID   => p_dest_doc_id,
    X_DEST_DOCUMENT_TYPE_CODE   => p_dest_doc_type_code,
    X_TRANSACTION_STATUS_CODE   => L_DUMMY_TXN_STATUS_CODE,
    X_PROGRAM_ID                => AHL_GLOBAL.AHL_OSP_PROGRAM_ID,
    X_ATTRIBUTE_CATEGORY        => p_attribute_category,
    X_ATTRIBUTE1                => p_attribute1,
    X_ATTRIBUTE2                => p_attribute2,
    X_ATTRIBUTE3                => p_attribute3,
    X_ATTRIBUTE4                => p_attribute4,
    X_ATTRIBUTE5                => p_attribute5,
    X_ATTRIBUTE6                => p_attribute6,
    X_ATTRIBUTE7                => p_attribute7,
    X_ATTRIBUTE8                => p_attribute8,
    X_ATTRIBUTE9                => p_attribute9,
    X_ATTRIBUTE10               => p_attribute10,
    X_ATTRIBUTE11               => p_attribute11,
    X_ATTRIBUTE12               => p_attribute12,
    X_ATTRIBUTE13               => p_attribute13,
    X_ATTRIBUTE14               => p_attribute14,
    X_ATTRIBUTE15               => p_attribute15);

END Log_Transaction;

-- Start of Comments --
--  Procedure name    : OPEN_SEARCH_CURSOR
--  Type              : Public
--  Function          : Opens a ref cursor that may have zero to a maximum of 16
--                      dynamic binding variables
--  Pre-reqs    :     Only a maximum of 18 bind variables.
--  Parameters  :
--
--  OPEN_SEARCH_CURSOR Parameters:
--      p_x_csr               IN OUT  ahl_search_csr     Required
--                            This is the cursor to be opened
--      p_conditions_tbl      IN      ahp_conditions_tbl     Required
--                            This is the array containing the binding values
--      p_sql_str             IN      VARCHAR2     Required
--                            This is the sql string with the bind parameters
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
PROCEDURE OPEN_SEARCH_CURSOR(p_x_csr          IN OUT NOCOPY ahl_search_csr,
                             p_conditions_tbl IN            ahl_conditions_tbl,
                             p_sql_str        IN            VARCHAR2) IS

   L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Open_Search_Cursor';

BEGIN
  --@@@@@
--  dbms_output.put_line('*****Entering OPEN_SEARCH_CURSOR**********');
--  dbms_output.put_line('Conditions Table Count = ' || p_conditions_tbl.COUNT);
--  FOR i in 1 .. p_conditions_tbl.count LOOP
--    dbms_output.put_line('Condition ' || i || ': ' || p_conditions_tbl(i));
--  END LOOP;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Conditions Table Count = ' || p_conditions_tbl.COUNT);
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'SEARCH_SQL: ' || p_sql_str);
    FOR i in 1 .. p_conditions_tbl.count LOOP
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Condition ' || i || ': ' || p_conditions_tbl(i));
    END LOOP;
  END IF;

  IF p_conditions_tbl.COUNT = 0 THEN
    OPEN p_x_csr FOR p_sql_str;
  ELSIF p_conditions_tbl.COUNT = 1 THEN
    OPEN p_x_csr FOR p_sql_str USING p_conditions_tbl(1);
  ELSIF p_conditions_tbl.COUNT = 2 THEN
    OPEN p_x_csr FOR p_sql_str USING p_conditions_tbl(1),
                                   p_conditions_tbl(2);
  ELSIF p_conditions_tbl.COUNT = 3 THEN
    OPEN p_x_csr FOR p_sql_str USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3);
  ELSIF p_conditions_tbl.COUNT = 4 THEN
    OPEN p_x_csr FOR p_sql_str USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4);
  ELSIF p_conditions_tbl.COUNT = 5 THEN
    OPEN p_x_csr FOR p_sql_str USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5);
  ELSIF p_conditions_tbl.COUNT = 6 THEN
    OPEN p_x_csr FOR p_sql_str USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5),
                                   p_conditions_tbl(6);
  ELSIF p_conditions_tbl.COUNT = 7 THEN
    OPEN p_x_csr FOR p_sql_str USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5),
                                   p_conditions_tbl(6),
                                   p_conditions_tbl(7);
  ELSIF p_conditions_tbl.COUNT = 8 THEN
    OPEN p_x_csr FOR p_sql_str USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5),
                                   p_conditions_tbl(6),
                                   p_conditions_tbl(7),
                                   p_conditions_tbl(8);
  ELSIF p_conditions_tbl.COUNT = 9 THEN
    OPEN p_x_csr FOR p_sql_str USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5),
                                   p_conditions_tbl(6),
                                   p_conditions_tbl(7),
                                   p_conditions_tbl(8),
                                   p_conditions_tbl(9);
  ELSIF p_conditions_tbl.COUNT = 10 THEN
    OPEN p_x_csr FOR p_sql_str USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5),
                                   p_conditions_tbl(6),
                                   p_conditions_tbl(7),
                                   p_conditions_tbl(8),
                                   p_conditions_tbl(9),
                                   p_conditions_tbl(10);
  ELSIF p_conditions_tbl.COUNT = 11 THEN
    OPEN p_x_csr FOR p_sql_str USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5),
                                   p_conditions_tbl(6),
                                   p_conditions_tbl(7),
                                   p_conditions_tbl(8),
                                   p_conditions_tbl(9),
                                   p_conditions_tbl(10),
                                   p_conditions_tbl(11);
  ELSIF p_conditions_tbl.COUNT = 12 THEN
    OPEN p_x_csr FOR p_sql_str USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5),
                                   p_conditions_tbl(6),
                                   p_conditions_tbl(7),
                                   p_conditions_tbl(8),
                                   p_conditions_tbl(9),
                                   p_conditions_tbl(10),
                                   p_conditions_tbl(11),
                                   p_conditions_tbl(12);
  ELSIF p_conditions_tbl.COUNT = 13 THEN
    OPEN p_x_csr FOR p_sql_str USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5),
                                   p_conditions_tbl(6),
                                   p_conditions_tbl(7),
                                   p_conditions_tbl(8),
                                   p_conditions_tbl(9),
                                   p_conditions_tbl(10),
                                   p_conditions_tbl(11),
                                   p_conditions_tbl(12),
                                   p_conditions_tbl(13);
  ELSIF p_conditions_tbl.COUNT = 14 THEN
    OPEN p_x_csr FOR p_sql_str USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5),
                                   p_conditions_tbl(6),
                                   p_conditions_tbl(7),
                                   p_conditions_tbl(8),
                                   p_conditions_tbl(9),
                                   p_conditions_tbl(10),
                                   p_conditions_tbl(11),
                                   p_conditions_tbl(12),
                                   p_conditions_tbl(13),
                                   p_conditions_tbl(14);
  ELSIF p_conditions_tbl.COUNT = 15 THEN
    OPEN p_x_csr FOR p_sql_str USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5),
                                   p_conditions_tbl(6),
                                   p_conditions_tbl(7),
                                   p_conditions_tbl(8),
                                   p_conditions_tbl(9),
                                   p_conditions_tbl(10),
                                   p_conditions_tbl(11),
                                   p_conditions_tbl(12),
                                   p_conditions_tbl(13),
                                   p_conditions_tbl(14),
                                   p_conditions_tbl(15);
  ELSIF p_conditions_tbl.COUNT = 16 THEN
    OPEN p_x_csr FOR p_sql_str USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5),
                                   p_conditions_tbl(6),
                                   p_conditions_tbl(7),
                                   p_conditions_tbl(8),
                                   p_conditions_tbl(9),
                                   p_conditions_tbl(10),
                                   p_conditions_tbl(11),
                                   p_conditions_tbl(12),
                                   p_conditions_tbl(13),
                                   p_conditions_tbl(14),
                                   p_conditions_tbl(15),
                                   p_conditions_tbl(16);
  ELSIF p_conditions_tbl.COUNT = 17 THEN
    OPEN p_x_csr FOR p_sql_str USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5),
                                   p_conditions_tbl(6),
                                   p_conditions_tbl(7),
                                   p_conditions_tbl(8),
                                   p_conditions_tbl(9),
                                   p_conditions_tbl(10),
                                   p_conditions_tbl(11),
                                   p_conditions_tbl(12),
                                   p_conditions_tbl(13),
                                   p_conditions_tbl(14),
                                   p_conditions_tbl(15),
                                   p_conditions_tbl(16),
                                   p_conditions_tbl(17);
  ELSIF p_conditions_tbl.COUNT = 18 THEN
    OPEN p_x_csr FOR p_sql_str USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5),
                                   p_conditions_tbl(6),
                                   p_conditions_tbl(7),
                                   p_conditions_tbl(8),
                                   p_conditions_tbl(9),
                                   p_conditions_tbl(10),
                                   p_conditions_tbl(11),
                                   p_conditions_tbl(12),
                                   p_conditions_tbl(13),
                                   p_conditions_tbl(14),
                                   p_conditions_tbl(15),
                                   p_conditions_tbl(16),
                                   p_conditions_tbl(17),
                                   p_conditions_tbl(18);
  ELSE
    -- Error: Too many bind values
--    dbms_output.put_line('Error: Too many bind variables');
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Error: Too many bind variables');
    END IF;
    null;
  END IF;
--  dbms_output.put_line('*****Exiting OPEN_SEARCH_CURSOR**********');
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

END OPEN_SEARCH_CURSOR;

-- Start of Comments --
--  Procedure name    : EXEC_IMMEDIATE
--  Type              : Public
--  Function          : Does an execute immediate of a SQL statement that returns
--                      a single number value and that has up to 16 bind variables (0 to 16)
--  Pre-reqs    :
--  Parameters  :
--
--  EXEC_IMMEDIATE Parameters:
--      p_conditions_tbl      IN      ahp_conditions_tbl     Required
--                            This is the array containing the binding values
--      p_sql_str             IN      VARCHAR2     Required
--                            This is the sql string with the bind parameters
--      x_results_count       OUT      NUMBER     Required
--                            This is the result of the execute immediate operation
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
PROCEDURE EXEC_IMMEDIATE(p_conditions_tbl IN         ahl_conditions_tbl,
                         p_sql_str        IN         VARCHAR2,
                         x_results_count  OUT NOCOPY NUMBER) IS

   L_DEBUG_KEY              CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Exec_Immediate';

BEGIN
--  dbms_output.put_line('*****Entering EXEC_IMMEDIATE**********');
--  dbms_output.put_line('Conditions Table Count = ' || p_conditions_tbl.COUNT);
--  FOR i in 1 .. p_conditions_tbl.count LOOP
--    dbms_output.put_line('Condition ' || i || ': ' || p_conditions_tbl(i));
--  END LOOP;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Conditions Table Count = ' || p_conditions_tbl.COUNT);
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'SEARCH_SQL: ' || p_sql_str);
    FOR i in 1 .. p_conditions_tbl.count LOOP
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Condition ' || i || ': ' || p_conditions_tbl(i));
    END LOOP;
  END IF;

  IF p_conditions_tbl.COUNT = 0 THEN
    EXECUTE IMMEDIATE p_sql_str INTO x_results_count;
  ELSIF p_conditions_tbl.COUNT = 1 THEN
    EXECUTE IMMEDIATE p_sql_str INTO x_results_count USING p_conditions_tbl(1);
  ELSIF p_conditions_tbl.COUNT = 2 THEN
    EXECUTE IMMEDIATE p_sql_str INTO x_results_count USING p_conditions_tbl(1),
                                   p_conditions_tbl(2);
  ELSIF p_conditions_tbl.COUNT = 3 THEN
    EXECUTE IMMEDIATE p_sql_str INTO x_results_count USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3);
  ELSIF p_conditions_tbl.COUNT = 4 THEN
    EXECUTE IMMEDIATE p_sql_str INTO x_results_count USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4);
  ELSIF p_conditions_tbl.COUNT = 5 THEN
    EXECUTE IMMEDIATE p_sql_str INTO x_results_count USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5);
  ELSIF p_conditions_tbl.COUNT = 6 THEN
    EXECUTE IMMEDIATE p_sql_str INTO x_results_count USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5),
                                   p_conditions_tbl(6);
  ELSIF p_conditions_tbl.COUNT = 7 THEN
    EXECUTE IMMEDIATE p_sql_str INTO x_results_count USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5),
                                   p_conditions_tbl(6),
                                   p_conditions_tbl(7);
  ELSIF p_conditions_tbl.COUNT = 8 THEN
    EXECUTE IMMEDIATE p_sql_str INTO x_results_count USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5),
                                   p_conditions_tbl(6),
                                   p_conditions_tbl(7),
                                   p_conditions_tbl(8);
  ELSIF p_conditions_tbl.COUNT = 9 THEN
    EXECUTE IMMEDIATE p_sql_str INTO x_results_count USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5),
                                   p_conditions_tbl(6),
                                   p_conditions_tbl(7),
                                   p_conditions_tbl(8),
                                   p_conditions_tbl(9);
  ELSIF p_conditions_tbl.COUNT = 10 THEN
    EXECUTE IMMEDIATE p_sql_str INTO x_results_count USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5),
                                   p_conditions_tbl(6),
                                   p_conditions_tbl(7),
                                   p_conditions_tbl(8),
                                   p_conditions_tbl(9),
                                   p_conditions_tbl(10);
  ELSIF p_conditions_tbl.COUNT = 11 THEN
    EXECUTE IMMEDIATE p_sql_str INTO x_results_count USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5),
                                   p_conditions_tbl(6),
                                   p_conditions_tbl(7),
                                   p_conditions_tbl(8),
                                   p_conditions_tbl(9),
                                   p_conditions_tbl(10),
                                   p_conditions_tbl(11);
  ELSIF p_conditions_tbl.COUNT = 12 THEN
    EXECUTE IMMEDIATE p_sql_str INTO x_results_count USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5),
                                   p_conditions_tbl(6),
                                   p_conditions_tbl(7),
                                   p_conditions_tbl(8),
                                   p_conditions_tbl(9),
                                   p_conditions_tbl(10),
                                   p_conditions_tbl(11),
                                   p_conditions_tbl(12);
  ELSIF p_conditions_tbl.COUNT = 13 THEN
    EXECUTE IMMEDIATE p_sql_str INTO x_results_count USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5),
                                   p_conditions_tbl(6),
                                   p_conditions_tbl(7),
                                   p_conditions_tbl(8),
                                   p_conditions_tbl(9),
                                   p_conditions_tbl(10),
                                   p_conditions_tbl(11),
                                   p_conditions_tbl(12),
                                   p_conditions_tbl(13);
  ELSIF p_conditions_tbl.COUNT = 14 THEN
    EXECUTE IMMEDIATE p_sql_str INTO x_results_count USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5),
                                   p_conditions_tbl(6),
                                   p_conditions_tbl(7),
                                   p_conditions_tbl(8),
                                   p_conditions_tbl(9),
                                   p_conditions_tbl(10),
                                   p_conditions_tbl(11),
                                   p_conditions_tbl(12),
                                   p_conditions_tbl(13),
                                   p_conditions_tbl(14);
  ELSIF p_conditions_tbl.COUNT = 15 THEN
    EXECUTE IMMEDIATE p_sql_str INTO x_results_count USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5),
                                   p_conditions_tbl(6),
                                   p_conditions_tbl(7),
                                   p_conditions_tbl(8),
                                   p_conditions_tbl(9),
                                   p_conditions_tbl(10),
                                   p_conditions_tbl(11),
                                   p_conditions_tbl(12),
                                   p_conditions_tbl(13),
                                   p_conditions_tbl(14),
                                   p_conditions_tbl(15);
  ELSIF p_conditions_tbl.COUNT = 16 THEN
    EXECUTE IMMEDIATE p_sql_str INTO x_results_count USING p_conditions_tbl(1),
                                   p_conditions_tbl(2),
                                   p_conditions_tbl(3),
                                   p_conditions_tbl(4),
                                   p_conditions_tbl(5),
                                   p_conditions_tbl(6),
                                   p_conditions_tbl(7),
                                   p_conditions_tbl(8),
                                   p_conditions_tbl(9),
                                   p_conditions_tbl(10),
                                   p_conditions_tbl(11),
                                   p_conditions_tbl(12),
                                   p_conditions_tbl(13),
                                   p_conditions_tbl(14),
                                   p_conditions_tbl(15),
                                   p_conditions_tbl(16);
  ELSE
    -- Error: Too many bind values
--    dbms_output.put_line('Error: Too many bind variables');

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Error: Too many bind variables');
    END IF;
    null;
  END IF;
--  dbms_output.put_line('*****Exiting EXEC_IMMEDIATE, x_results_count = ' || x_results_count || '**********');

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'x_results_count = ' || x_results_count);
    END IF;
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

END EXEC_IMMEDIATE;

/* Following three functions added by jaramana on March 14, 2006 for fixing Perf Bug 4914529 */
/* This function gets the instance number for a Ship (or Return) Line associated to a OSP Line */
/* Modified by mpothuku on 09-Jan-2008 to support the implementation of the Osp Receiving feature */
FUNCTION GET_SHIP_LINE_INSTANCE_NUMBER(p_ship_line_id IN NUMBER,
                                       p_osp_line_id  IN NUMBER) RETURN VARCHAR2 IS
   /*
   CURSOR get_line_details_csr IS
     SELECT oe_ship_line_id,
            oe_return_line_id,
            workorder_id,
            serial_number,
            lot_number,
            osp_order_id,
            exchange_instance_id
     FROM ahl_osp_order_lines
     WHERE osp_order_line_id = p_osp_line_id;

   CURSOR get_osp_order_type_csr(c_osp_order_id IN NUMBER) IS
     SELECT order_type_code FROM ahl_osp_orders_b
     WHERE osp_order_id = c_osp_order_id;
   */

   CURSOR get_instance_from_id_csr(c_instance_id IN NUMBER) IS
     SELECT instance_number FROM csi_item_instances
     WHERE instance_id = c_instance_id;

   --osp_line_details_rec get_line_details_csr%ROWTYPE;

   l_instance_number VARCHAR2(30) := NULL;
   l_instance_id NUMBER := NULL;
   --l_order_type VARCHAR2(30);

BEGIN
  /*
  open get_line_details_csr;
  fetch get_line_details_csr into osp_line_details_rec;
  if(get_line_details_csr%found) then
    if(p_ship_line_id = osp_line_details_rec.oe_ship_line_id) then
      l_instance_number := GET_OSP_LINE_INSTANCE_NUMBER(p_workorder_id  => osp_line_details_rec.workorder_id,
                                                        p_serial_number => osp_line_details_rec.serial_number,
                                                        p_lot_number    => osp_line_details_rec.lot_number);
    elsif (p_ship_line_id = osp_line_details_rec.oe_return_line_id) then
      -- Get the order type
      open get_osp_order_type_csr(osp_line_details_rec.osp_order_id);
      fetch get_osp_order_type_csr into l_order_type;
      close get_osp_order_type_csr;
      if(l_order_type = 'EXCHANGE') then
        -- Get the instance number from the exchange instance id
        open get_instance_from_id_csr(osp_line_details_rec.exchange_instance_id);
        fetch get_instance_from_id_csr into l_instance_number;
        close get_instance_from_id_csr;
      else
        l_instance_number := GET_OSP_LINE_INSTANCE_NUMBER(p_workorder_id  => osp_line_details_rec.workorder_id,
                                                          p_serial_number => osp_line_details_rec.serial_number,
                                                          p_lot_number    => osp_line_details_rec.lot_number);
      end if;
    end if;
  end if;
  close get_line_details_csr;
  */
  l_instance_id := GET_SHIP_LINE_INSTANCE_ID(p_ship_line_id,p_osp_line_id);

  open get_instance_from_id_csr(l_instance_id);
  fetch get_instance_from_id_csr into l_instance_number;
  close get_instance_from_id_csr;

  return l_instance_number;

END GET_SHIP_LINE_INSTANCE_NUMBER;

--Added by mpothuku on 09-Jan-2008 to implement the Osp Receiving feature
FUNCTION GET_SHIP_LINE_INSTANCE_ID(p_ship_line_id IN NUMBER,
                                   p_osp_line_id  IN NUMBER) RETURN NUMBER IS

   CURSOR get_line_details_csr IS
     SELECT oe_ship_line_id,
            oe_return_line_id,
            workorder_id,
            serial_number,
            lot_number,
            osp_order_id,
            exchange_instance_id
     FROM ahl_osp_order_lines
     WHERE osp_order_line_id = p_osp_line_id;

   CURSOR get_osp_order_type_csr(c_osp_order_id IN NUMBER) IS
     SELECT order_type_code FROM ahl_osp_orders_b
     WHERE osp_order_id = c_osp_order_id;

   CURSOR get_instance_from_id_csr(c_instance_id IN NUMBER) IS
     SELECT instance_number FROM csi_item_instances
     WHERE instance_id = c_instance_id;

   osp_line_details_rec get_line_details_csr%ROWTYPE;

   l_instance_id NUMBER := NULL;
   l_order_type VARCHAR2(30);

BEGIN
  open get_line_details_csr;
  fetch get_line_details_csr into osp_line_details_rec;
  if(get_line_details_csr%found) then
    if(p_ship_line_id = osp_line_details_rec.oe_ship_line_id) then
	  l_instance_id := GET_IB_SUBTRANS_INSTANCE_ID(p_ship_line_id);
    elsif (p_ship_line_id = osp_line_details_rec.oe_return_line_id) then
      -- Get the order type
      open get_osp_order_type_csr(osp_line_details_rec.osp_order_id);
      fetch get_osp_order_type_csr into l_order_type;
      close get_osp_order_type_csr;
      if(l_order_type = 'EXCHANGE') then
        l_instance_id := osp_line_details_rec.exchange_instance_id;
      else
        -- Get the instance number from the IB Subtransaction itself
		l_instance_id := GET_IB_SUBTRANS_INSTANCE_ID(p_ship_line_id);
      end if;
    end if;
  end if;
  close get_line_details_csr;
  return l_instance_id;
END GET_SHIP_LINE_INSTANCE_ID;

---------------------------------
/* This function gets the serial number for a Ship (or Return) Line associated to a OSP Line */
-- Logic:
-- decode(ShipmentLineEO.line_id, nvl(ospl.oe_ship_line_id, -1), ospl.serial_number, nvl(ospl.oe_return_line_id, -1), decode(osp.order_type_code, 'EXCHANGE', ospl.exchange_instance_sl_no, ospl.serial_number), null) SERIAL_NUMBER,

FUNCTION GET_SHIP_LINE_SERIAL_NUMBER(p_ship_line_id IN NUMBER,
                                     p_osp_line_id  IN NUMBER) RETURN VARCHAR2 IS

   CURSOR get_line_details_csr IS
     SELECT oe_ship_line_id,
            oe_return_line_id,
            serial_number,
            lot_number,
            osp_order_id,
            exchange_instance_id
     FROM ahl_osp_order_lines
     WHERE osp_order_line_id = p_osp_line_id;

   CURSOR get_osp_order_type_csr(c_osp_order_id IN NUMBER) IS
     SELECT order_type_code from ahl_osp_orders_b
     WHERE osp_order_id = c_osp_order_id;

   CURSOR get_serial_from_instance_csr(c_instance_id IN NUMBER) IS
     SELECT serial_number FROM csi_item_instances
     WHERE instance_id = c_instance_id;

   cursor get_serial_from_oelsn_csr IS
     SELECT FROM_SERIAL_NUMBER from oe_lot_serial_numbers
     where LINE_ID = p_ship_line_id;

   osp_line_details_rec get_line_details_csr%ROWTYPE;

   l_serial_number VARCHAR2(30) := NULL;
   l_order_type VARCHAR2(30);
   l_instance_id NUMBER := NULL;

BEGIN
  open get_line_details_csr;
  fetch get_line_details_csr into osp_line_details_rec;
  if(get_line_details_csr%found) then
    if(p_ship_line_id = osp_line_details_rec.oe_ship_line_id) then
      l_serial_number := osp_line_details_rec.serial_number;
    elsif (p_ship_line_id = osp_line_details_rec.oe_return_line_id) then
      -- Get the order type
      open get_osp_order_type_csr(osp_line_details_rec.osp_order_id);
      fetch get_osp_order_type_csr into l_order_type;
      close get_osp_order_type_csr;
      if(l_order_type = 'EXCHANGE') then
        -- Get the serial number from the exchange instance id
        open get_serial_from_instance_csr(osp_line_details_rec.exchange_instance_id);
        fetch get_serial_from_instance_csr into l_serial_number;
        close get_serial_from_instance_csr;
      else
        --Modified by mpothuku on 09-Jan-2008 to implement the Osp Receiving feature.
        --If its a service order, we will need to show the serial corresponding to the serial number change (if any)
        l_instance_id := GET_IB_SUBTRANS_INSTANCE_ID(p_ship_line_id);
        IF(l_instance_id is not NULL) THEN
          -- Get the serial number from the l_instance_id
          open get_serial_from_instance_csr(l_instance_id);
          fetch get_serial_from_instance_csr into l_serial_number;
          close get_serial_from_instance_csr;
        ELSE
          l_serial_number := osp_line_details_rec.serial_number;
        END IF;
      end if;
    end if;
  else
    -- Not OSP Line Based: Get the serial number from oe_lot_serial_numbers
    -- Note that this oe_lot_serial_numbers applies only for return lines
    open get_serial_from_oelsn_csr;
    fetch get_serial_from_oelsn_csr into l_serial_number;
    close get_serial_from_oelsn_csr;
  end if;
  close get_line_details_csr;
  return l_serial_number;
END GET_SHIP_LINE_SERIAL_NUMBER;

---------------------------------
/* This function gets the lot number for a Ship (or Return) Line associated to a OSP Line */
--Added by mpothuku on 05-May-2008 to fix the Bug 6322216

FUNCTION GET_SHIP_LINE_LOT_NUMBER(p_ship_line_id IN NUMBER,
                                  p_osp_line_id  IN NUMBER) RETURN VARCHAR2 IS

   CURSOR get_line_details_csr IS
     SELECT oe_ship_line_id,
            oe_return_line_id,
            serial_number,
            lot_number,
            osp_order_id,
            exchange_instance_id
     FROM ahl_osp_order_lines
     WHERE osp_order_line_id = p_osp_line_id;

   CURSOR get_osp_order_type_csr(c_osp_order_id IN NUMBER) IS
     SELECT order_type_code from ahl_osp_orders_b
     WHERE osp_order_id = c_osp_order_id;

   CURSOR get_lot_num_from_instance_csr(c_instance_id IN NUMBER) IS
     SELECT lot_number FROM csi_item_instances
     WHERE instance_id = c_instance_id;

   cursor get_lot_num_from_oelsn_csr IS
     SELECT LOT_NUMBER from oe_lot_serial_numbers
     where LINE_ID = p_ship_line_id;

   osp_line_details_rec get_line_details_csr%ROWTYPE;

   l_lot_number VARCHAR2(80) := NULL;
   l_order_type VARCHAR2(30);
   l_instance_id NUMBER := NULL;

BEGIN
  open get_line_details_csr;
  fetch get_line_details_csr into osp_line_details_rec;
  if(get_line_details_csr%found) then
    if(p_ship_line_id = osp_line_details_rec.oe_ship_line_id) then
      l_lot_number := osp_line_details_rec.lot_number;
    elsif (p_ship_line_id = osp_line_details_rec.oe_return_line_id) then
      -- Get the order type
      open get_osp_order_type_csr(osp_line_details_rec.osp_order_id);
      fetch get_osp_order_type_csr into l_order_type;
      close get_osp_order_type_csr;
      if(l_order_type = 'EXCHANGE') then
        -- Get the lot number from the exchange instance id
        open get_lot_num_from_instance_csr(osp_line_details_rec.exchange_instance_id);
        fetch get_lot_num_from_instance_csr into l_lot_number;
        close get_lot_num_from_instance_csr;
      else
        --Modified by mpothuku on 09-Jan-2008 to implement the Osp Receiving feature.
        --If its a service order, we will need to show the lot corresponding to the lot number change (if any)
        l_instance_id := GET_IB_SUBTRANS_INSTANCE_ID(p_ship_line_id);
        IF(l_instance_id is not NULL) THEN
          -- Get the lot number from the l_instance_id
          open get_lot_num_from_instance_csr(l_instance_id);
          fetch get_lot_num_from_instance_csr into l_lot_number;
          close get_lot_num_from_instance_csr;
        ELSE
          l_lot_number := osp_line_details_rec.lot_number;
        END IF;
      end if;
    end if;
  else
    -- Not OSP Line Based: Get the lot number from oe_lot_serial_numbers
    -- Note that this oe_lot_serial_numbers applies only for return lines
    open get_lot_num_from_oelsn_csr;
    fetch get_lot_num_from_oelsn_csr into l_lot_number;
    close get_lot_num_from_oelsn_csr;
  end if;
  close get_line_details_csr;
  return l_lot_number;
END GET_SHIP_LINE_LOT_NUMBER;


/******* Helper Function *********/

FUNCTION GET_OSP_LINE_INSTANCE_NUMBER(p_workorder_id  IN NUMBER,
                                      p_serial_number IN VARCHAR2,
                                      p_lot_number    IN VARCHAR2) RETURN VARCHAR2 IS
   CURSOR get_wo_instance_csr IS
     SELECT csi.instance_number
     FROM AHL_WORKORDERS WO, AHL_VISITS_VL VST, AHL_VISIT_TASKS_VL VTS, CSI_ITEM_INSTANCES CSI
     WHERE WO.WORKORDER_ID = p_workorder_id AND
      WO.VISIT_TASK_ID = VTS.VISIT_TASK_ID AND
      VST.VISIT_ID = VTS.VISIT_ID AND
      NVL(VTS.INSTANCE_ID, VST.ITEM_INSTANCE_ID) = CSI.INSTANCE_ID;

   CURSOR get_instance_from_sl_csr IS
     SELECT instance_number FROM CSI_ITEM_INSTANCES
     WHERE serial_number = p_serial_number;

   CURSOR get_instance_from_lot_csr IS
     SELECT instance_number FROM csi_item_instances
     WHERE lot_number = p_lot_number;

   l_instance_number VARCHAR2(30) := null;

BEGIN
  if(p_workorder_id is not null) then
    -- If the line's workorder id is not null: Get the workorder instance
    open get_wo_instance_csr;
    fetch get_wo_instance_csr into l_instance_number;
    close get_wo_instance_csr;
  else
    -- If the line's workorder id is null: Get the instance id and instance number from the line's serial number
    if(p_serial_number is not null) then
      open get_instance_from_sl_csr;
      fetch get_instance_from_sl_csr into l_instance_number;
      close get_instance_from_sl_csr;
    else
      -- If line's serial number is null, try to get it from the line's lot number
      if(p_lot_number is not null) then
        open get_instance_from_lot_csr;
        fetch get_instance_from_lot_csr into l_instance_number;
        close get_instance_from_lot_csr;
      end if;
    end if;
  end if;
  return l_instance_number;
END GET_OSP_LINE_INSTANCE_NUMBER;

/******* Added by mpothuku on 09-Jan-2008 to implement the Osp Receiving feature  *********/

FUNCTION GET_IB_SUBTRANS_INSTANCE_ID(p_oe_line_id IN NUMBER) RETURN NUMBER IS
   CURSOR get_IB_subtrans_instanceID_csr IS
    SELECT tld.instance_id
      FROM csi_t_transaction_lines tl,
           csi_t_txn_line_details tld
     WHERE tl.source_transaction_id = p_oe_line_id
       AND tl.source_transaction_table = 'OE_ORDER_LINES_ALL'
       AND tl.transaction_line_id = tld.transaction_line_id;

	   l_instance_id NUMBER := null;
BEGIN
  if(p_oe_line_id is not null) then
    open get_IB_subtrans_instanceID_csr;
    fetch get_IB_subtrans_instanceID_csr into l_instance_id;
    close get_IB_subtrans_instanceID_csr;
  end if;
  return l_instance_id;
END GET_IB_SUBTRANS_INSTANCE_ID;

--mpothuku End

END AHL_OSP_UTIL_PKG;

/
