--------------------------------------------------------
--  DDL for Package BEN_EXT_SORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_SORT" AUTHID CURRENT_USER as
/* $Header: benxsort.pkh 120.0 2005/05/28 09:47:26 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|           Copyright (c) 1997 Oracle Corporation                  |
|              Redwood Shores, California, USA                     |
|                   All rights reserved.                             |
+==============================================================================+
Name:
    Extract Sort Process.
Purpose:
    This process handles all sorting logic for extract.
History:
        Date             Who        Version    What?
        ----             ---        -------    -----
        24 Apr 99        Ty Hayden  115.0      Created.
        05 May 99        Ty Hayden  115.1      add g_trans_count.
        23 Dec 02        lakrish    115.2      NOCOPY changes
*/
-----------------------------------------------------------------------------------
--
    g_prmy_sort_val                  ben_ext_rslt_dtl.prmy_sort_val%TYPE;
    g_scnd_sort_val                  ben_ext_rslt_dtl.scnd_sort_val%TYPE;
    g_thrd_sort_val                  ben_ext_rslt_dtl.thrd_sort_val%TYPE;
    g_trans_count                    number := 0;
--
--
PROCEDURE main
    (                        p_ext_rcd_in_file_id         in number,
                             p_sort1_data_elmt_in_rcd_id  in number,
                             p_sort2_data_elmt_in_rcd_id  in number,
                             p_sort3_data_elmt_in_rcd_id  in number,
                             p_sort4_data_elmt_in_rcd_id  in number,
                             p_rcd_seq_num                in number,
                             p_low_lvl_cd                 in varchar2,
                             p_prmy_sort_val              out nocopy varchar2,
                             p_scnd_sort_val              out nocopy varchar2,
                             p_thrd_sort_val              out nocopy varchar2);
--
END;

 

/
