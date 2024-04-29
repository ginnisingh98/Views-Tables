--------------------------------------------------------
--  DDL for Package IGF_AW_ANTICIPATED_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_ANTICIPATED_DATA" AUTHID CURRENT_USER AS
/* $Header: IGFAW20S.pls 120.0 2005/06/01 14:46:11 appldev noship $ */
PROCEDURE main    ( errbuf          OUT NOCOPY VARCHAR2,
                    retcode         OUT NOCOPY NUMBER,
                    p_award_year    IN         VARCHAR2,
                    p_batch_id      IN         igf_ap_li_bat_ints.batch_num%TYPE,
                    p_del_ind       IN         VARCHAR2 );


END igf_aw_anticipated_data;

 

/
