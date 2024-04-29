--------------------------------------------------------
--  DDL for Package HR_TPC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TPC_RKD" AUTHID CURRENT_USER as
/* $Header: hrtpcrhi.pkh 120.0 2005/05/31 03:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_topic_id                     in number
  ,p_topic_key_o                  in varchar2
  ,p_handler_o                    in varchar2
  ,p_object_version_number_o      in number
  );
--
end hr_tpc_rkd;

 

/
