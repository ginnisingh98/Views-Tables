--------------------------------------------------------
--  DDL for Package OTFR2483
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTFR2483" AUTHID CURRENT_USER as
/* $Header: otfr2483.pkh 120.1 2005/11/03 08:39:32 aparkes noship $ */
--
FUNCTION get_dif_balance(p_assignment_id     IN NUMBER,
                         p_accrual_plan_id   IN NUMBER,
                         p_payroll_id        IN NUMBER,
                         p_business_group_id IN NUMBER,
                         p_end_date          IN DATE)  RETURN NUMBER;
--
procedure build_XML (P_COMPANY_ID     IN  NUMBER,
                     P_YEAR           IN  NUMBER,
                     P_DATE_TO        IN  VARCHAR2 DEFAULT NULL,
                     P_DETAIL_SECTION IN  VARCHAR2,
                     P_TEMPLATE_NAME  IN  VARCHAR2 DEFAULT NULL,
                     p_xml            OUT NOCOPY CLOB);
--
PROCEDURE run_2483 (errbuf              OUT NOCOPY VARCHAR2
                   ,retcode             OUT NOCOPY NUMBER
                   ,p_business_group_id IN NUMBER
                   ,p_template_id       IN NUMBER
                   ,p_company_id        IN NUMBER
                   ,p_calendar          IN VARCHAR2
                   ,p_time_period_id    IN NUMBER
                   ,p_currency_code     IN VARCHAR2
                   ,p_process_name      IN VARCHAR2
                   ,p_debug             IN VARCHAR2);
--
end otfr2483;

 

/
