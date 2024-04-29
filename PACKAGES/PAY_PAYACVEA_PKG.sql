--------------------------------------------------------
--  DDL for Package PAY_PAYACVEA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYACVEA_PKG" AUTHID CURRENT_USER as
/* $Header: pyacvea.pkh 115.0 99/07/17 05:41:43 porting ship $ */
--
PROCEDURE get_dates(
                    p_element_entry_id IN  number,
                    p_payroll_id       IN  number,
                    p_session_date     IN  date,
                    p_person_id        IN  number,
                    p_start_date       OUT date,
                    p_end_date         OUT date
                   );
--
END PAY_PAYACVEA_PKG;

 

/
