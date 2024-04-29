--------------------------------------------------------
--  DDL for Package BIM_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_UTL_PKG" AUTHID CURRENT_USER AS
/* $Header: bimutlps.pls 120.1 2005/06/09 14:40:10 appldev  $*/

PROCEDURE DROP_INDEX( p_table_name             IN  VARCHAR2 );

PROCEDURE CREATE_INDEX ( p_table_name             IN  VARCHAR2);

FUNCTION  convert_currency(
   p_from_currency          VARCHAR2 ,
   p_from_amount            NUMBER) return NUMBER;

PROCEDURE LOG_HISTORY
   (p_object                VARCHAR2,
    p_start_time            DATE,
    p_end_time              DATE,
    x_msg_count             OUT NOCOPY NUMBER       ,
    x_msg_data              OUT NOCOPY VARCHAR2     ,
    x_return_status         OUT NOCOPY VARCHAR2
) ;
END BIM_UTL_PKG;

 

/
