--------------------------------------------------------
--  DDL for Package WMS_RULE_LABEL_PKG3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_RULE_LABEL_PKG3" AS

 ---- For Opening the Label CURSOR ----
 ----
PROCEDURE EXECUTE_LABEL_RULE(
          p_rule_id                    IN NUMBER,
          p_label_request_id           IN NUMBER,
          x_return_status              OUT NOCOPY NUMBER);


END WMS_RULE_LABEL_PKG3;
--COMMIT;
--EXIT;



/
