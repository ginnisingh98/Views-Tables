--------------------------------------------------------
--  DDL for Package AD_RELEASES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_RELEASES_PVT" 
/* $Header: adphrlss.pls 115.8 2004/06/02 11:43:05 sallamse ship $ */
AUTHID CURRENT_USER as

Procedure CreateRelease
           (p_major_version                 number,
            p_minor_version                 number,
            p_tape_version                  number,
            p_row_src_comments              varchar2,
            p_base_rel_flag                 varchar2,
            p_start_dt                      date,
            p_end_dt                        date     default null,
            p_created_by_user_id            number,
            p_release_id         out nocopy number);

end ad_releases_pvt;

 

/
