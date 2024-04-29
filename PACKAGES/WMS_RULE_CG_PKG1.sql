--------------------------------------------------------
--  DDL for Package WMS_RULE_CG_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_RULE_CG_PKG1" AS


 ---- For Calling the Cost Group  rule ----
 ----

PROCEDURE EXECUTE_CG_RULE(
          p_rule_id                    IN NUMBER,
          p_line_id                    IN NUMBER,
          x_result                     OUT NOCOPY NUMBER);

END WMS_RULE_CG_PKG1;
--COMMIT;
--EXIT;



/
