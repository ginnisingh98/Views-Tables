--------------------------------------------------------
--  DDL for Package WMS_RULE_OP_PKG3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_RULE_OP_PKG3" AS


  ---- For Opening the Operartion Plan CURSOR ----
  ----
 PROCEDURE EXECUTE_OP_RULE(
           p_rule_id                    IN NUMBER,
           p_transaction_type_id        IN NUMBER,
           x_return_status              OUT NOCOPY NUMBER);

 END WMS_RULE_OP_PKG3;
 --COMMIT;
 --EXIT;


 

/
