--------------------------------------------------------
--  DDL for Package PER_HU_PERSON_EXTRA_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_HU_PERSON_EXTRA_INFO" AUTHID CURRENT_USER AS
/* $Header: pehupeip.pkh 120.0.12000000.1 2007/01/21 23:19:22 appldev ship $ */

PROCEDURE create_hu_person_extra_info
  (p_person_id                     IN     NUMBER
  ,p_information_type              IN     VARCHAR2
  ,p_pei_information_category      IN     VARCHAR2
  ,p_pei_information3              IN     VARCHAR2
  ,p_pei_information4              IN     VARCHAR2
  );
  --
 PROCEDURE update_hu_person_extra_info
  (p_person_extra_info_id          IN     NUMBER
  ,p_pei_information_category      IN     VARCHAR2
  ,p_pei_information3              IN     VARCHAR2
  ,p_pei_information4              IN     VARCHAR2
  ) ;
  --
END per_hu_person_extra_info;

 

/
