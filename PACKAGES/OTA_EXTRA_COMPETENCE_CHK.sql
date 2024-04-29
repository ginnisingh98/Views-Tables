--------------------------------------------------------
--  DDL for Package OTA_EXTRA_COMPETENCE_CHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_EXTRA_COMPETENCE_CHK" AUTHID CURRENT_USER as
/* $Header: otcmpchk.pkh 120.0 2005/05/29 07:07:11 appldev noship $ */
procedure chk_competence
  (p_competence_id                   in     number
   );

end ota_extra_competence_chk;

 

/
