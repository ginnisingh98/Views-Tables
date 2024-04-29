--------------------------------------------------------
--  DDL for Package POA_MV_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_MV_UTILS_PKG" AUTHID CURRENT_USER as
/* $Header: POAMVUTLS.pls 120.0 2005/06/01 13:40:49 appldev noship $ */

  procedure drop_MV_Log(p_mv_log varchar2);

  procedure create_MV_Log(p_base_table varchar2
                       ,p_column_list varchar2 := NULL
                       ,p_sequence_flag varchar2 := 'Y'
                       ,p_rowid varchar2 := 'Y'
                       ,p_new_values varchar2 := 'Y'
                       ,p_data_tablespace varchar2 := null
                       ,p_index_tablespace varchar2 := null
                       ,p_next_extent varchar2 := '32K'
                       );

  procedure drop_MV(p_mv varchar2);

  procedure create_part_MV(p_mv_name varchar2
                    ,p_mv_sql varchar2
                    ,p_build_mode varchar2 := 'D' -- D = DEFERRED, I = IMMEDIATE
                    ,p_refresh_mode varchar2 := 'F' -- F = FAST , C = COMPLETE
                    ,p_enable_qrewrite varchar2 := 'N'
                    ,p_partition_clause varchar2 := NULL
                    ,p_next_extent varchar2 := '2M'
                    );

  procedure create_MV(p_mv_name varchar2
                    ,p_mv_sql varchar2
                    ,p_build_mode varchar2 := 'D' -- DEFERRED
                    ,p_refresh_mode varchar2 := 'F' -- FAST
                    ,p_enable_qrewrite varchar2 := 'N'
                    ,p_partition_flag varchar2 := 'N'
                    ,p_next_extent varchar2 := '2M'
                    ) ;

   procedure create_MV_Index(p_mv_name varchar2
                            ,p_ind_name varchar2
                            ,p_ind_col_list varchar2
                            ,p_unique_flag varchar2 := 'N'
                            ,p_ind_type varchar2 := 'B' -- B = BTree , M = BitMap
                            ,p_next_extent varchar2 := '32K'
                            ,p_partition_type varchar2 := 'L'
                             );
end POA_MV_UTILS_PKG;

 

/
