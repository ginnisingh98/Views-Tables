--------------------------------------------------------
--  DDL for Package PER_PMP_MASS_NOTIFICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PMP_MASS_NOTIFICATION" AUTHID CURRENT_USER AS
/* $Header: pepmpmas.pkh 120.0.12010000.2 2008/11/09 13:43:49 kgowripe noship $ */
-- Declare Global variables
TYPE r_user  IS RECORD (person_id NUMBER(15),
                        user_name fnd_user.user_name%TYPE,
                        user_display_name per_all_people_f.full_name%TYPE);
TYPE t_userdtls IS TABLE OF r_user index by BINARY_INTEGER;
----
PROCEDURE mass_notify(errbuf     out  nocopy  varchar2
                     ,retcode    out  nocopy  number
                     ,p_plan_id  IN NUMBER
                     ,p_effective_date IN  Varchar2
                     ,p_message_subject IN VARCHAR2
                     ,p_message_body IN VARCHAR2
                     ,p_target_population IN VARCHAR2  default NULL
                     ,p_target_person_id IN NUMBER DEFAULT NULL
                     ,p_person_selection_rule  IN NUMBER DEFAULT NULL);
--
END per_pmp_mass_notification;

/
