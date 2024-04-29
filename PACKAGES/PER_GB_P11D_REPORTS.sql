--------------------------------------------------------
--  DDL for Package PER_GB_P11D_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_GB_P11D_REPORTS" AUTHID CURRENT_USER AS
/* $Header: pegbp11d.pkh 115.2 2003/02/21 07:09:51 bthammin ship $ */
/*
 Change List
 -----------
   Date        Name          Vers     Bug No   Description
   +-----------+-------------+--------+-------+-----------------------+
   03-Jan-2003  Bhaskar       115.0            (Initial)
   20-FEB-2003  Bhaskar       115.1    2765216 Added parameter
                                               P_PRINT_ADDRESS_PAGE
*/
procedure submit_main_report(ERRBUF                     OUT NOCOPY VARCHAR2
                            ,RETCODE                    OUT NOCOPY NUMBER
                            ,P_PRINT_ADDRESS_PAGE       IN         VARCHAR2
                            ,P_PRINT_P11D               IN         VARCHAR2
                            ,P_PRINT_P11D_SUMMARY       IN         VARCHAR2
                            ,P_PRINT_WS                 IN         VARCHAR2
                            ,P_PAYROLL_ACTION_ID        IN         VARCHAR2
                            ,P_ORGANIZATION_ID          IN         VARCHAR2
                            ,P_ORG_HIERARCHY            IN         VARCHAR2
                            ,P_ASSIGNMENT_SET_ID        IN         VARCHAR2
                            ,P_LOCATION_CODE            IN         VARCHAR2
                            ,P_ASSIGNMENT_ACTION_ID     IN         VARCHAR2
                            ,P_BUSINESS_GROUP_ID        IN         VARCHAR2
                            ,P_SORT_ORDER1              IN         VARCHAR2
                            ,P_SORT_ORDER2              IN         VARCHAR2);
--
procedure submit_gaps_report(ERRBUF                             OUT NOCOPY VARCHAR2
                            ,RETCODE                            OUT NOCOPY NUMBER
                            ,P_BENEFIT_START_DATE_CN            IN         VARCHAR2
                            ,P_BENEFIT_START_DATE               IN         VARCHAR2
                            ,P_BENEFIT_END_DATE_CN              IN         VARCHAR2
                            ,P_BENEFIT_END_DATE                 IN         VARCHAR2
                            ,P_BENEFIT_TYPE_ID                  IN         VARCHAR2
                            ,P_BENEFIT_TYPE                     IN         VARCHAR2
                            ,P_OVERLAP                          IN         VARCHAR2
                            ,P_GAP                              IN         VARCHAR2
                            ,P_PAYROLL_ID                       IN         VARCHAR2
                            ,P_PAYROLL                          IN         VARCHAR2
                            ,P_PERSON_ID                        IN         VARCHAR2
                            ,P_PERSON                           IN         VARCHAR2
                            ,P_TAX_DISTRICT_REFERENCE_ID        IN         VARCHAR2
                            ,P_TAX_DISTRICT_REFERENCE           IN         VARCHAR2
                            ,P_CONSOLIDATION_SET_ID             IN         VARCHAR2
                            ,P_CONSOLIDATION_SET                IN         VARCHAR2
                            ,P_ASSIGNMENT_SET_ID                IN         VARCHAR2
                            ,P_ASSIGNMENT_SET                   IN         VARCHAR2
                            ,P_BUSINESS_GROUP_ID                IN         VARCHAR2 );

end per_gb_p11d_reports;

 

/
