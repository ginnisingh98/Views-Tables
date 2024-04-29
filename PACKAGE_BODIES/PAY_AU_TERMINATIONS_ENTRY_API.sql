--------------------------------------------------------
--  DDL for Package Body PAY_AU_TERMINATIONS_ENTRY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_TERMINATIONS_ENTRY_API" AS
/*  $Header: pyautapi.pkb 120.6.12010000.2 2009/09/07 13:10:19 pmatamsr ship $
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
**  05-MAR-2002 JKAROUZA 115.1     2246310  Added new parameter
**                                 p_override_user_ent_chk in calls
**                                 to py_element_entry_api.
**  22-MAR-2002 JKAROUZA 115.2     Added SET VERIFY OFF.
**  04-DEC-2002 Ragovind 115.3     Added NOCOPY for the functions update_al_element_entry, update_etp_element_entry
** 				   ,update_lsl_element_entry,update_super_element_entry
**
**  15-May-2003 Ragovind 115.4     Added new parameteres to the procedure update
_etp_element_entry for ETP pre/post enhancement.
**
**  18-May-2003 Ragovind 115.5     Added Bug Reference - Bug#2819479.
**  09-MAr-2006 hnainani 115.6     Bug# 5080026 - 2 new parameters for update_al_element_entry
**  26-Jun-2006 hnainani 115.7     Added new parameters for update_lsl_element_entry
**  09-MAY-2007 priupadh 115.10   5956223  Added New Parameters to update_etp_element_entry
**  04-Sep-2007 priupadh 115.11   6192381  Added New Parameters to update_super_element_entry
**  07-Sep-2009 pmatamsr 115.12   8769345  Added new parameters to update_super_element_entry
**  Wrappers for updating the element entries through the
**  Terminations form.
**
*/
---------------------------------------------------------------------------------------

PROCEDURE update_al_element_entry
               (p_dt_update_mode        IN    VARCHAR2
              ,p_session_date           IN    DATE
              ,p_business_group_id      IN    NUMBER
              ,p_element_entry_id       IN    NUMBER
              ,p_object_version_number  IN OUT NOCOPY NUMBER
              ,p_hours_input_value_id   IN    NUMBER
              ,p_payment_input_value_id IN    NUMBER
              ,p_loading_input_value_id IN    NUMBER
              ,p_other_input_value_id   IN    NUMBER
              ,p_hours_entry_value	    IN    VARCHAR2
              ,p_payment_entry_value    IN    VARCHAR2
              ,p_loading_entry_value    IN    VARCHAR2
              ,p_other_entry_value	    IN    VARCHAR2
              ,p_effective_start_date   IN OUT NOCOPY DATE
              ,p_effective_end_date     IN OUT NOCOPY DATE
              ,p_update_warning         OUT NOCOPY BOOLEAN) IS
BEGIN
   py_element_entry_api.update_element_entry
      (p_datetrack_update_mode =>  P_dt_update_mode
      ,p_effective_date        =>  P_session_date
      ,p_business_group_id     =>  P_business_group_id
      ,p_element_entry_id      =>  P_element_entry_id
      ,p_object_version_number =>  P_object_version_number
      ,p_input_value_id1       =>  P_hours_input_value_id
      ,p_input_value_id2       =>  p_payment_input_value_id
      ,p_input_value_id3       =>  p_loading_input_value_id
      ,p_input_value_id4       =>  p_other_input_value_id
      ,p_entry_value1          =>  p_hours_entry_value
      ,p_entry_value2          =>  p_payment_entry_value
      ,p_entry_value3          =>  p_loading_entry_value
      ,p_entry_value4          =>  p_other_entry_value
      ,p_effective_start_date  =>  p_effective_start_date
      ,p_effective_end_date    =>  p_effective_end_date
      ,p_override_user_ent_chk =>  'Y'
      ,p_update_warning        =>  p_update_warning);

END update_al_element_entry;


PROCEDURE update_lsl_element_entry
              (p_dt_update_mode               IN     VARCHAR2
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
              ,p_override_elig_input_value_id      IN     NUMBER  /*Bug# 5056831 */
              ,p_pre78_pay_entry_value     	      IN     VARCHAR2
              ,p_post78_pay_entry_value           IN     VARCHAR2
              ,p_post93_pay_entry_value           IN     VARCHAR2
              ,p_pre78_hours_entry_value          IN     VARCHAR2
              ,p_post78_hours_entry_value         IN     VARCHAR2
              ,p_post93_hours_entry_value         IN     VARCHAR2
              ,p_override_elig_entry_value        IN    VARCHAR2  /*Bug# 5056831 */
              ,p_effective_start_date 	      IN OUT NOCOPY DATE
              ,p_effective_end_date   	      IN OUT NOCOPY DATE
              ,p_update_warning       	      OUT    NOCOPY BOOLEAN) IS
BEGIN


      py_element_entry_api.update_element_entry
            (p_datetrack_update_mode => p_dt_update_mode
            ,p_effective_date        => p_session_date
            ,p_business_group_id     => p_business_group_id
            ,p_element_entry_id      => p_element_entry_id
            ,p_object_version_number => p_object_version_number
            ,p_input_value_id1       => p_pre78_pay_input_value_id
            ,p_input_value_id2       => p_post78_pay_input_value_id
            ,p_input_value_id3       => p_post93_pay_input_value_id
            ,p_input_value_id4       => p_pre78_hours_input_value_id
            ,p_input_value_id5       => p_post78_hours_input_value_id
            ,p_input_value_id6       => p_post93_hours_input_value_id
            ,p_input_value_id7       => p_override_elig_input_value_id  /*Bug# 5056831 */
            ,p_entry_value1          => p_pre78_pay_entry_value
            ,p_entry_value2          => p_post78_pay_entry_value
            ,p_entry_value3          => p_post93_pay_entry_value
            ,p_entry_value4          => p_pre78_hours_entry_value
            ,p_entry_value5          => p_post78_hours_entry_value
            ,p_entry_value6          => p_post93_hours_entry_value
            ,p_entry_value7          => p_override_elig_entry_value   /*Bug# 5056831 */
            ,p_effective_start_date  => p_effective_start_date
            ,p_effective_end_date    => p_effective_end_date
            ,p_override_user_ent_chk => 'Y'
            ,p_update_warning        => p_update_warning);

END update_lsl_element_entry;

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
                                  ,p_update_warning             OUT NOCOPY BOOLEAN) IS
BEGIN

    py_element_entry_api.update_element_entry
         (p_datetrack_update_mode => p_dt_update_mode
         ,p_effective_date        => p_session_date
         ,p_business_group_id     => p_business_group_id
         ,p_element_entry_id      => p_element_entry_id
         ,p_object_version_number => p_object_version_number
         ,p_input_value_id1       => p_redundancy_input_value_id
         ,p_input_value_id2       => p_pay_etp_input_value_id
         ,p_input_value_id3       => p_golden_input_value_id
         ,p_input_value_id4       => p_lieu_input_value_id
         ,p_input_value_id5       => p_sick_input_value_id
         ,p_input_value_id6       => p_rdo_input_value_id
         ,p_input_value_id7       => p_other_input_value_id
         ,p_input_value_id8       => p_pre_1983_input_value_id
         ,p_input_value_id9       => p_post_1983_input_value_id
         ,p_input_value_id10      => p_etp_cs_date_input_value_id
         ,p_input_value_id11      => p_trans_etp_input_value_id /*5956223 */
         ,p_input_value_id12      => p_part_prev_etp_input_value_id /*5956223 */
         ,p_entry_value1          => p_redundancy_entry_value
         ,p_entry_value2          => p_pay_etp_entry_value
         ,p_entry_value3          => p_golden_entry_value
         ,p_entry_value4          => p_lieu_entry_value
         ,p_entry_value5          => p_sick_entry_value
         ,p_entry_value6          => p_rdo_entry_value
         ,p_entry_value7          => p_other_entry_value
         ,p_entry_value8          => p_pre_1983_entry_value
         ,p_entry_value9          => p_post_1983_entry_value
         ,p_entry_value10         => p_etp_cs_date_entry_value
         ,p_entry_value11         => p_trans_etp_entry_value /*5956223 */
         ,p_entry_value12         => p_part_of_prev_etp_entry_value  /*5956223 */
         ,p_effective_start_date  => p_effective_start_date
         ,p_effective_end_date    => p_effective_end_date
         ,p_override_user_ent_chk => 'Y'
         ,p_update_warning        => p_update_warning);

END update_etp_element_entry;

/* Bug 8769345 - Added new parameters to procedure in order to provide support for
                 two new input values added in Super rollover element */
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
        ,p_update_warning            OUT NOCOPY BOOLEAN) IS
BEGIN

  py_element_entry_api.update_element_entry
       (p_datetrack_update_mode      => p_dt_update_mode
       ,p_effective_date             => p_session_date
       ,p_business_group_id          => p_business_group_id
       ,p_element_entry_id           => p_element_entry_id
       ,p_object_version_number      => p_object_version_number
       ,p_input_value_id1            => p_amount_input_value_id
       ,p_entry_value1               => p_amount_entry_value
       ,p_input_value_id2            => p_amount_ppetp_input_value_id
       ,p_entry_value2               => p_amount_ppetp_entry_value
       ,p_input_value_id3            => p_amount_nppetp_input_value_id
       ,p_entry_value3               => p_amount_nppetp_entry_value
       ,p_input_value_id4            => p_tax_free_ppetp_ip_value_id    /* Start 8769345 */
       ,p_entry_value4               => p_tax_free_ppetp_entry_value
       ,p_input_value_id5            => p_tax_free_nppetp_ip_value_id
       ,p_entry_value5               => p_tax_free_nppetp_entry_value   /* End 8769345 */
       ,p_personal_payment_method_id => p_personal_payment_method_id
       ,p_effective_start_date       => p_effective_start_date
       ,p_effective_end_date         => p_effective_end_date
       ,p_override_user_ent_chk      => 'Y'
       ,P_update_warning             => p_update_warning );

END update_super_element_entry;

END pay_au_terminations_entry_api;

/
