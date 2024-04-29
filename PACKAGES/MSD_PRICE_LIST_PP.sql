--------------------------------------------------------
--  DDL for Package MSD_PRICE_LIST_PP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_PRICE_LIST_PP" AUTHID CURRENT_USER AS
/* $Header: msdplpps.pls 115.0 2003/04/30 01:44:19 esubrama noship $ */

 PROCEDURE price_list_post_process( errbuf           OUT NOCOPY VARCHAR2,
                                   retcode           OUT NOCOPY VARCHAR2,
                                   p_instance_id     IN  VARCHAR2,
                                   p_price_list      IN  VARCHAR2 );

  END MSD_PRICE_LIST_PP;

 

/
