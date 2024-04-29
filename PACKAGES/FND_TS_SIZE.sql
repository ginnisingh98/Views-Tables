--------------------------------------------------------
--  DDL for Package FND_TS_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_TS_SIZE" AUTHID CURRENT_USER AS
/* $Header: fndpsizs.pls 120.1 2005/07/02 03:36:37 appldev noship $ */
 PROCEDURE gen_tab_sizing (p_app in varchar2,
                           p_uni_extent in number,
                           p_allocation_type in varchar2,
                           p_creation_date in date);

 PROCEDURE gen_ind_sizing (p_app in varchar2,
                           p_uni_extent in number,
                           p_allocation_type in varchar2,
                           p_creation_date in date);

 PROCEDURE gen_all_tab_sizing ( p_uni_extent IN NUMBER,
                                p_allocation_type in varchar2,
                                p_creation_date IN DATE);

 PROCEDURE gen_all_ind_sizing ( p_uni_extent IN NUMBER,
                                p_allocation_type in varchar2,
                                p_creation_date IN DATE);

END fnd_ts_size;

 

/
