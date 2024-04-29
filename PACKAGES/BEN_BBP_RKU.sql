--------------------------------------------------------
--  DDL for Package BEN_BBP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BBP_RKU" AUTHID CURRENT_USER as
/* $Header: bebbprhi.pkh 120.0 2005/05/28 00:34:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_batch_parameter_id             in number
 ,p_batch_exe_cd                   in varchar2
 ,p_thread_cnt_num                 in number
 ,p_max_err_num                    in number
 ,p_chunk_size                     in number
 ,p_business_group_id              in number
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_batch_exe_cd_o                 in varchar2
 ,p_thread_cnt_num_o               in number
 ,p_max_err_num_o                  in number
 ,p_chunk_size_o                   in number
 ,p_business_group_id_o            in number
 ,p_object_version_number_o        in number
  );
--
end ben_bbp_rku;

 

/
