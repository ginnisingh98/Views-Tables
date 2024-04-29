--------------------------------------------------------
--  DDL for Package IGF_GR_LI_IMPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_GR_LI_IMPORT" AUTHID CURRENT_USER AS
/* $Header: IGFGR10S.pls 120.0 2005/06/01 14:25:41 appldev noship $ */

  PROCEDURE main(
                 errbuf          OUT NOCOPY VARCHAR2,
                 retcode         OUT NOCOPY NUMBER,
                 p_award_year    IN         VARCHAR2,
                 p_batch_num     IN         NUMBER,
                 p_delete_flag   IN         VARCHAR2
            );

END igf_gr_li_import;

 

/
