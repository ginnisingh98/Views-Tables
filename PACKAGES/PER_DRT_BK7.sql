--------------------------------------------------------
--  DDL for Package PER_DRT_BK7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DRT_BK7" AUTHID CURRENT_USER as
/* $Header: pedrtapi.pkh 120.0.12010000.2 2018/04/13 09:21:35 gahluwal noship $ */
--
-- ------------------------------------------------------------------------------------
-- |-----------------------------< delete_drt_details_b >--------------------------|
-- ------------------------------------------------------------------------------------
--
procedure delete_drt_details_b
  (p_table_id      in  number
  ,p_column_id     in  number
  ,p_ff_column_id  in  number
  );
--
-- ------------------------------------------------------------------------------------
-- |-----------------------------< delete_drt_details_a >--------------------------|
-- ------------------------------------------------------------------------------------
--
procedure delete_drt_details_a
  (p_table_id      in  number
  ,p_column_id     in  number
  ,p_ff_column_id  in  number
  );
--
end per_drt_bk7;

/
