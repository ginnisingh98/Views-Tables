--------------------------------------------------------
--  DDL for Package BSC_PMA_APIS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_PMA_APIS_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCPMAPS.pls 120.2 2006/01/10 11:51 arsantha noship $ */

FUNCTION sync_dimension_table(p_dim_short_name VARCHAR2, p_action VARCHAR2, p_error_message OUT NOCOPY VARCHAR2 ) return BOOLEAN;

PROCEDURE get_summary_object_for_level(
  p_objective          in number,
  p_periodicity_id     in number,
  p_dim_set_id         in number,
  p_level_pattern      in varchar2,
  p_option_string      in varchar2,
  p_table_name        out nocopy varchar2,
  p_mv_name           out nocopy varchar2,
  p_data_source       out nocopy varchar2,
  p_sql_stmt          out nocopy varchar2,
  p_projection_source out nocopy number,
  p_projection_data   out nocopy varchar2,
  p_error_message     out nocopy varchar2
);

END BSC_PMA_APIS_PUB ;

 

/
