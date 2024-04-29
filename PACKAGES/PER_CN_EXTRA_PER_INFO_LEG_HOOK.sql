--------------------------------------------------------
--  DDL for Package PER_CN_EXTRA_PER_INFO_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CN_EXTRA_PER_INFO_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: pecnlhep.pkh 120.0 2005/05/31 06:52 appldev noship $ */

  PROCEDURE check_extra_information_exists
  (p_person_extra_info_id           IN NUMBER
  ,p_object_version_number          IN NUMBER
  );

END per_cn_extra_per_info_leg_hook;

 

/
