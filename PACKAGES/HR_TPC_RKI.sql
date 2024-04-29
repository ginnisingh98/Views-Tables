--------------------------------------------------------
--  DDL for Package HR_TPC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TPC_RKI" AUTHID CURRENT_USER as
/* $Header: hrtpcrhi.pkh 120.0 2005/05/31 03:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_topic_id                     in number
  ,p_topic_key                    in varchar2
  ,p_handler                      in varchar2
  ,p_object_version_number        in number
  );
end hr_tpc_rki;

 

/
