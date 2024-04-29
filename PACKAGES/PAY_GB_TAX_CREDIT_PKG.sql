--------------------------------------------------------
--  DDL for Package PAY_GB_TAX_CREDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_TAX_CREDIT_PKG" AUTHID CURRENT_USER AS
/* $Header: pygbtaxc.pkh 120.0.12000000.1 2007/01/17 20:29:56 appldev noship $ */
FUNCTION Get_Element_Link_Id(
            p_assignment_id in NUMBER
                ) RETURN NUMBER;

PROCEDURE Check_Start_date(p_assignment_id in PAY_ELEMENT_ENTRIES_F.assignment_id%TYPE,
                           p_element_entry_id in PAY_ELEMENT_ENTRIES_F.element_entry_id%TYPE,
                           p_start_date in DATE,
                           p_element_name in VARCHAR2 default 'Tax Credit',
                           p_message out nocopy VARCHAR2);

PROCEDURE Check_End_or_Stop_Date(p_assignment_id in PAY_ELEMENT_ENTRIES_F.assignment_id%TYPE,
                         p_element_entry_id in PAY_ELEMENT_ENTRIES_F.element_entry_id%TYPE,
                         p_end_date in DATE,
                         p_start_date in DATE,
                         p_element_name in PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE,
                         p_message out nocopy VARCHAR2);

PROCEDURE Check_Delete_Possible(
                       p_datetrack_mode in VARCHAR2,
                       p_effective_date in DATE,
                       p_assignment_id in PAY_ELEMENT_ENTRIES_F.assignment_id%TYPE,
                       p_start_date in DATE,
                       p_end_date in DATE,
                       p_message out nocopy VARCHAR2);

Procedure Check_Daily_Rate(
               p_assignment_id in PAY_ELEMENT_ENTRIES_F.assignment_id%TYPE,
               p_start_date in DATE,
               p_message out nocopy VARCHAR2
               );

PROCEDURE Fetch_Balances(
            p_assignment_id in PAY_ASSIGNMENT_ACTIONS.ASSIGNMENT_ID%TYPE,
            p_element_entry_id in PAY_RUN_RESULTS.SOURCE_ID%TYPE,
            p_itd_balance   OUT NOCOPY NUMBER,
            p_ptd_balance   OUT NOCOPY NUMBER
             );

PROCEDURE Create_Tax_Credit(
            p_effective_date in DATE
           ,p_business_group_id in NUMBER
           ,p_assignment_id in NUMBER
           ,p_element_link_id in NUMBER
           ,p_reference in VARCHAR2
           ,p_start_date in VARCHAR2
           ,p_end_date in VARCHAR2
           ,p_daily_amount in VARCHAR2
           ,p_total_amount in VARCHAR2
           ,p_stop_date in VARCHAR2
           ,p_reference_ipv_id in NUMBER
           ,p_start_date_ipv_id in NUMBER
           ,p_end_date_ipv_id in NUMBER
           ,p_daily_amount_ipv_id in NUMBER
           ,p_total_amount_ipv_id in NUMBER
           ,p_stop_date_ipv_id in NUMBER
           ,p_from in DATE
           ,p_to in DATE
           ,p_effective_start_date out nocopy DATE
           ,p_effective_end_date out nocopy DATE
           ,p_element_entry_id out nocopy NUMBER
           ,p_object_version_number out nocopy NUMBER);

PROCEDURE Delete_Tax_Credit(
            p_datetrack_mode in VARCHAR2
           ,p_element_entry_id in NUMBER
           ,p_effective_date in DATE
           ,p_object_version_number in NUMBER);

PROCEDURE Update_Tax_Credit(
            p_datetrack_update_mode in     varchar2
           ,p_effective_date        in     date
           ,p_business_group_id     in     number
           ,p_element_entry_id      in     number
           ,p_object_version_number in out nocopy number
           ,p_reference in VARCHAR2
           ,p_start_date in VARCHAR2
           ,p_end_date in VARCHAR2
           ,p_daily_amount in VARCHAR2
           ,p_total_amount in VARCHAR2
           ,p_stop_date in VARCHAR2
           ,p_reference_ipv_id in NUMBER
           ,p_start_date_ipv_id in NUMBER
           ,p_end_date_ipv_id in NUMBER
           ,p_daily_amount_ipv_id in NUMBER
           ,p_total_amount_ipv_id in NUMBER
           ,p_stop_date_ipv_id in NUMBER
           ,p_effective_start_date     out nocopy date
           ,p_effective_end_date       out nocopy date);

END PAY_GB_TAX_CREDIT_PKG;

 

/
