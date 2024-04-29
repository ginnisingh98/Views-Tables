--------------------------------------------------------
--  DDL for Package HR_RU_ASG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RU_ASG_HOOK" AUTHID CURRENT_USER AS
/* $Header: peruexar.pkh 120.0.12000000.1 2007/01/22 03:54:46 appldev noship $ */

 PROCEDURE validate_asg_upd_details(p_assignment_id     	IN   NUMBER
                               ,p_effective_date    		IN   DATE
                               ,p_datetrack_update_mode 	IN  VARCHAR2
                               ,p_assignment_status_type_id     IN   NUMBER
                               ,p_segment1          		IN  VARCHAR2
                               ,p_segment2          		IN  VARCHAR2
                               ,p_segment3          		IN  VARCHAR2
                               ,p_segment4          		IN  VARCHAR2
                               ,p_segment5          		IN  VARCHAR2
                               ,p_segment6          		IN  VARCHAR2
                               ,p_segment7          		IN  VARCHAR2
                               ,p_segment8          		IN  VARCHAR2
                               ,p_segment9          		IN  VARCHAR2
                               ,p_segment10         		IN  VARCHAR2
                               ,p_segment11         		IN  VARCHAR2
                               ,p_segment12         		IN  VARCHAR2
                               ,p_segment13         		IN  VARCHAR2
                               ,p_segment14         		IN  VARCHAR2
                               ,p_segment15         		IN  VARCHAR2
                               );

 PROCEDURE validate_asg_create_details(p_person_id     	IN   NUMBER
                               ,p_effective_date    		IN   DATE
                               ,p_assignment_status_type_id     IN   NUMBER
                               ,p_scl_segment1          	IN  VARCHAR2
                               ,p_scl_segment2          	IN  VARCHAR2
                               ,p_scl_segment3          	IN  VARCHAR2
                               ,p_scl_segment4          	IN  VARCHAR2
                               ,p_scl_segment5          	IN  VARCHAR2
                               ,p_scl_segment6          	IN  VARCHAR2
                               ,p_scl_segment7          	IN  VARCHAR2
                               ,p_scl_segment8          	IN  VARCHAR2
                               ,p_scl_segment9          	IN  VARCHAR2
                               ,p_scl_segment10         	IN  VARCHAR2
                               ,p_scl_segment11         	IN  VARCHAR2
                               ,p_scl_segment12         	IN  VARCHAR2
                               ,p_scl_segment13         	IN  VARCHAR2
                               ,p_scl_segment14         	IN  VARCHAR2
                               ,p_scl_segment15         	IN  VARCHAR2
                               );
END hr_ru_asg_hook;

 

/
