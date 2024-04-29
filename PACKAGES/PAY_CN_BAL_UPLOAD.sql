--------------------------------------------------------
--  DDL for Package PAY_CN_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CN_BAL_UPLOAD" AUTHID CURRENT_USER AS
/* $Header: pycnupld.pkh 115.1 2003/03/21 11:29:03 saikrish noship $ */

FUNCTION expiry_date ( p_upload_date       IN  DATE
                     , p_dimension_name    IN  VARCHAR2
                     , p_assignment_id     IN  NUMBER
                     , p_original_entry_id IN  NUMBER
                     )
RETURN DATE;

PRAGMA RESTRICT_REFERENCES(expiry_date, WNDS, WNPS);

FUNCTION is_supported ( p_dimension_name  IN  VARCHAR2)
RETURN NUMBER;

FUNCTION include_adjustment( p_balance_type_id    IN  NUMBER
                           , p_dimension_name     IN  VARCHAR2
                           , p_original_entry_id  IN  NUMBER
                           , p_upload_date        IN  DATE
                           , p_batch_line_id      IN  NUMBER
                           , p_test_batch_line_id IN  NUMBER
                           )
RETURN NUMBER;

PROCEDURE validate_batch_lines ( p_batch_id  IN  NUMBER );

END pay_cn_bal_upload;

 

/
