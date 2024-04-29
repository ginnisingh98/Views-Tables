--------------------------------------------------------
--  DDL for Package WMS_RULE_TASK_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_RULE_TASK_PKG2" AS


 ---- For Opening the Task CURSOR ----
 ----
PROCEDURE EXECUTE_TASK_RULE(
          p_rule_id                    IN NUMBER,
          p_transaction_type_id        IN NUMBER,
          x_return_status              OUT NOCOPY NUMBER);

END WMS_RULE_TASK_PKG2;
--COMMIT;
--EXIT;



/
