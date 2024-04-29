--------------------------------------------------------
--  DDL for Package PQH_PLG_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PLG_RKI" AUTHID CURRENT_USER as
/* $Header: pqplgrhi.pkh 120.0 2005/05/29 02:17:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_process_log_id                 in number
 ,p_module_cd                      in varchar2
 ,p_txn_id                         in number
 ,p_master_process_log_id          in number
 ,p_message_text                   in varchar2
 ,p_message_type_cd                in varchar2
 ,p_batch_status                   in varchar2
 ,p_batch_start_date               in date
 ,p_batch_end_date                 in date
 ,p_txn_table_route_id             in number
 ,p_log_context                    in varchar2
 ,p_information_category           in varchar2
 ,p_information1                   in varchar2
 ,p_information2                   in varchar2
 ,p_information3                   in varchar2
 ,p_information4                   in varchar2
 ,p_information5                   in varchar2
 ,p_information6                   in varchar2
 ,p_information7                   in varchar2
 ,p_information8                   in varchar2
 ,p_information9                   in varchar2
 ,p_information10                  in varchar2
 ,p_information11                  in varchar2
 ,p_information12                  in varchar2
 ,p_information13                  in varchar2
 ,p_information14                  in varchar2
 ,p_information15                  in varchar2
 ,p_information16                  in varchar2
 ,p_information17                  in varchar2
 ,p_information18                  in varchar2
 ,p_information19                  in varchar2
 ,p_information20                  in varchar2
 ,p_information21                  in varchar2
 ,p_information22                  in varchar2
 ,p_information23                  in varchar2
 ,p_information24                  in varchar2
 ,p_information25                  in varchar2
 ,p_information26                  in varchar2
 ,p_information27                  in varchar2
 ,p_information28                  in varchar2
 ,p_information29                  in varchar2
 ,p_information30                  in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
  );
end pqh_plg_rki;

 

/
