--------------------------------------------------------
--  DDL for Package PAY_SE_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_BAL_UPLOAD" AUTHID CURRENT_USER AS
/* $Header: pysebalupl.pkh 120.0.12000000.1 2007/07/23 10:29:31 rravi noship $ */

FUNCTION expiry_date
                (p_upload_date          IN      DATE,
                 p_dimension_name       IN      VARCHAR2,
                 p_assignment_id        IN      NUMBER,
                 p_original_entry_id    IN      NUMBER)
RETURN DATE;

FUNCTION is_supported ( p_dimension_name  IN  VARCHAR2)
RETURN NUMBER;

FUNCTION include_adjustment
        ( p_balance_type_id     NUMBER
         ,p_dimension_name      VARCHAR2
         ,p_original_entry_id   NUMBER
         ,p_upload_date         DATE
         ,p_batch_line_id       NUMBER
         ,p_test_batch_line_id  NUMBER
         )
RETURN NUMBER;

PROCEDURE validate_batch_lines ( p_batch_id  IN  NUMBER );
 FUNCTION GET_EARN_END_YEAR(p_start_month varchar2,
  p_end_month varchar2,
  p_upload_date date)
  RETURN NUMBER;

END PAY_SE_BAL_UPLOAD;

 

/
