--------------------------------------------------------
--  DDL for Package PAY_AU_TERMINATIONS_ENTRY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_TERMINATIONS_ENTRY_API" AUTHID CURRENT_USER AS
/*  $Header: pyautapi.pkh 120.7.12010000.2 2009/09/07 13:09:08 pmatamsr ship $
**
**  Copyright (c) 1999 Oracle Corporation
**  All Rights Reserved
**
**  Procedures and functions used in AU terminations entry form
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  =========================================================
**  15-NOV-2000 JMHATRE  115.0     Created for AU
**  21-MAR-2002 jkarouza 115.1     Added dbdrv statements.
**  22-MAR-2002 jkarouza 115.2     Added SET VERIFY OFF.
**  04-DEC-2002 Ragovind 115.3     Added NOCOPY for the functions update_al_element_entry, update_etp_element_entry
** 				   ,update_lsl_element_entry,update_super_element_entry
**
**  15-May-2003 Ragovind 115.4     Added new parameteres to the procedure update_etp_element_entry for ETP pre/post enhancement.
**  18-May-2003 Ragovind 115.5     Added Bug Reference - Bug#2819479.
**  0-Mar-2006 hnainani 115.5      Added 2 new parameters to update_al_element_entry
**  Wrappers for updating the element entries through the
**  Terminations form.
**  12-Oct-2006 abhargav 115.8    5592452  Modified to avoid annotation error.
**  24-OCT-2006 hnainani 115.10   5616936  Re-Introduced update_lsl_element_entry parameters
**  09-MAY-2007 priupadh 115.11   5956223  Added New Parameters to update_etp_element_entry
**  04-SEP-2007 priupadh 115.12   6192381  Added New Parameters to update_super_element_entry
**  07-SEP-2007 pmatamsr 115.13   8769345  Added New Parameters to update_super_element_entry
*/
---------------------------------------------------------------------------------------

PROCEDURE update_al_element_entry(p_dt_update_mode          IN	  VARCHAR2
                                  ,p_session_date           IN    DATE
                                  ,p_business_group_id      IN    NUMBER
                                  ,p_element_entry_id       IN    NUMBER
                                  ,p_object_version_number  IN OUT NOCOPY NUMBER
                                  ,p_hours_input_value_id   IN    NUMBER
                                  ,p_payment_input_value_id IN    NUMBER
                                  ,p_loading_input_value_id IN    NUMBER
                                  ,p_other_input_value_id IN    NUMBER
                                  ,p_hours_entry_value	    IN    VARCHAR2
                                  ,p_payment_entry_value    IN    VARCHAR2
                                  ,p_loading_entry_value    IN    VARCHAR2
                                  ,p_other_entry_value    IN    VARCHAR2
                                  ,p_effective_start_date   IN OUT NOCOPY DATE
                                  ,p_effective_end_date     IN OUT NOCOPY DATE
                                  ,p_update_warning         OUT NOCOPY BOOLEAN) ;

PROCEDURE update_lsl_element_entry(p_dt_update_mode                   IN     VARCHAR2
                                  ,p_session_date       	      IN     DATE
                                  ,p_business_group_id    	      IN     NUMBER
                                  ,p_element_entry_id     	      IN     NUMBER
                                  ,p_object_version_number	      IN OUT NOCOPY NUMBER
                                  ,p_pre78_pay_input_value_id         IN     NUMBER
                                  ,p_post78_pay_input_value_id        IN     NUMBER
                                  ,p_post93_pay_input_value_id        IN     NUMBER
                                  ,p_pre78_hours_input_value_id       IN     NUMBER
                                  ,p_post78_hours_input_value_id      IN     NUMBER
                                  ,p_post93_hours_input_value_id      IN     NUMBER
                                  ,p_override_elig_input_value_id      IN     NUMBER /*Bug# 5056831 */
                                  ,p_pre78_pay_entry_value     	      IN     VARCHAR2
                                  ,p_post78_pay_entry_value           IN     VARCHAR2
                                  ,p_post93_pay_entry_value           IN     VARCHAR2
                                  ,p_pre78_hours_entry_value          IN     VARCHAR2
                                  ,p_post78_hours_entry_value         IN     VARCHAR2
                                  ,p_post93_hours_entry_value         IN     VARCHAR2
                                  ,p_override_elig_entry_value        IN    VARCHAR2  /*Bug# 5056831 */
                                  ,p_effective_start_date 	      IN OUT NOCOPY DATE
                                  ,p_effective_end_date   	      IN OUT NOCOPY DATE
                                  ,p_update_warning       	      OUT  NOCOPY  BOOLEAN);

/* Added new parameters for update_etp_element_entry for Bug#2819479 */
PROCEDURE update_etp_element_entry(p_dt_update_mode              IN VARCHAR2
                                  ,p_session_date                IN DATE
                                  ,p_business_group_id           IN NUMBER
                                  ,p_element_entry_id            IN NUMBER
                                  ,p_object_version_number   IN OUT NOCOPY NUMBER
                                  ,p_redundancy_input_value_id   IN NUMBER
                                  ,p_pay_etp_input_value_id      IN NUMBER
                                  ,p_golden_input_value_id       IN NUMBER
                                  ,p_lieu_input_value_id         IN NUMBER
                                  ,p_sick_input_value_id         IN NUMBER
                                  ,p_rdo_input_value_id          IN NUMBER
                                  ,p_other_input_value_id        IN NUMBER
                                  ,p_pre_1983_input_value_id     IN NUMBER
				  ,p_post_1983_input_value_id    IN NUMBER
                                  ,p_etp_cs_date_input_value_id  IN NUMBER
				  ,p_trans_etp_input_value_id    IN NUMBER /*5956223*/
				  ,p_part_prev_etp_input_value_id IN NUMBER /*5956223*/
                                  ,p_redundancy_entry_value      IN VARCHAR2
                                  ,p_pay_etp_entry_value         IN VARCHAR2
                                  ,p_golden_entry_value          IN VARCHAR2
                                  ,p_lieu_entry_value            IN VARCHAR2
                                  ,p_sick_entry_value            IN VARCHAR2
                                  ,p_rdo_entry_value             IN VARCHAR2
                                  ,p_other_entry_value           IN VARCHAR2
                                  ,p_pre_1983_entry_value        IN VARCHAR2
				  ,p_post_1983_entry_value       IN VARCHAR2
                                  ,p_etp_cs_date_entry_value     IN VARCHAR2
				  ,p_trans_etp_entry_value       IN VARCHAR2  /*5956223 */
				  ,p_part_of_prev_etp_entry_value IN VARCHAR2 /*5956223*/
                                  ,p_effective_start_date    IN OUT NOCOPY DATE
                                  ,p_effective_end_date      IN OUT NOCOPY DATE
                                  ,p_update_warning             OUT NOCOPY BOOLEAN);

/* Bug 8769345 - Added new parameters to procedure in order to provide support for
                 two new input values added in Super Rollover element */
PROCEDURE update_super_element_entry
        (p_dt_update_mode             IN VARCHAR2
        ,p_session_date             IN DATE
        ,p_business_group_id          IN NUMBER
        ,p_element_entry_id           IN NUMBER
        ,p_object_version_number  IN OUT NOCOPY NUMBER
        ,p_amount_input_value_id        IN NUMBER
        ,p_amount_entry_value      IN VARCHAR2
        ,p_amount_ppetp_input_value_id        IN NUMBER
        ,p_amount_ppetp_entry_value      IN VARCHAR2
        ,p_amount_nppetp_input_value_id        IN NUMBER
        ,p_amount_nppetp_entry_value      IN VARCHAR2
        ,p_tax_free_ppetp_ip_value_id      IN NUMBER      /* Start 8769345 */
        ,p_tax_free_ppetp_entry_value      IN VARCHAR2
        ,p_tax_free_nppetp_ip_value_id     IN NUMBER
        ,p_tax_free_nppetp_entry_value     IN VARCHAR2    /* End 8769345 */
        ,p_personal_payment_method_id IN NUMBER
        ,p_effective_start_date   IN OUT NOCOPY DATE
        ,p_effective_end_date     IN OUT NOCOPY DATE
        ,p_update_warning            OUT NOCOPY BOOLEAN);


END pay_au_terminations_entry_api;

/
