--------------------------------------------------------
--  DDL for Package HR_QSN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QSN_RKI" AUTHID CURRENT_USER as
/* $Header: hrqsnrhi.pkh 120.1.12010000.3 2008/11/05 10:22:27 rsykam ship $ */

--
-- ---------------------------------------------------------------------------
-- |---------------------------< after_insert >------------------------------|
-- ---------------------------------------------------------------------------
--
Procedure after_insert
   (p_questionnaire_template_id  in  number
   ,p_name      in  varchar2
 --  ,p_text      in  CLOB
   ,p_available_flag    in  varchar2
   ,p_business_group_id    in  number
   ,p_object_version_number  in  number
   ,p_effective_date    in   date
   );
end hr_qsn_rki;

/
