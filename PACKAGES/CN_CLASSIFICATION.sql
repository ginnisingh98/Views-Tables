--------------------------------------------------------
--  DDL for Package CN_CLASSIFICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CLASSIFICATION" AUTHID CURRENT_USER AS
-- $Header: cnclclss.pls 115.0 99/07/16 07:03:43 porting ship $

--
-- Package Name
--   cn_classification
-- Purpose
--   Package specification for classifying transactions
-- History
--   12-MAY-95          CN            Created
--


--
-- Procedure Name
--   classify_batch
-- Purpose
--   Classify a transaction by physical_batch_id
-- History
--   12-MAY-95  CN           Created
--   07-JUL-95  P Cook       Removed debug_pipe parameter
--   14-JUL-95  P Cook       Added process_audit_id parameter
--   19-JUL-95  A. Erickson  Fixed spelling in input parameter

   PROCEDURE classify_batch (x_physical_batch_id  NUMBER,
                             x_process_audit_id   NUMBER);

--
-- Procedure Name
--   classify_line
-- Purpose
--   Classify a transaction by sales_line_id
-- History
--   12-MAY-95  CN           Created
--   19-JUL-95  A. Erickson  Removed debug_pipe parameter
--
--   PROCEDURE classify_line (x_trx_sales_line_id     NUMBER,
--                            x_sales_line_status OUT VARCHAR2);


END cn_classification;

 

/
