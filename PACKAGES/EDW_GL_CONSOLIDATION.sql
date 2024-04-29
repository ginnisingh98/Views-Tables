--------------------------------------------------------
--  DDL for Package EDW_GL_CONSOLIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_GL_CONSOLIDATION" AUTHID CURRENT_USER AS
/* $Header: FIIECONS.pls 120.2 2005/08/30 15:05:10 sgautam noship $ */

procedure edw_get_cons_flex_value (
 p_coa_mapping_id      IN  gl_cons_segment_map.coa_mapping_id%TYPE ,
 p_cons_from_flex_set_id IN  fnd_flex_values.FLEX_VALUE_SET_ID%TYPE ,
 p_cons_to_flex_set_id   IN  fnd_flex_values.FLEX_VALUE_SET_ID%TYPE ,
 p_cons_from_flex_value	 IN  fnd_flex_values.FLEX_VALUE%TYPE ,
 p_parent_flag		 IN  varchar2 ,
 p_cons_to_flex_value    OUT NOCOPY /* file.sql.39 change */ fnd_flex_values.FLEX_VALUE%TYPE ,
 p_return_msg            OUT NOCOPY /* file.sql.39 change */ varchar2 ,
 p_status                OUT NOCOPY /* file.sql.39 change */ boolean
) ;

END EDW_GL_CONSOLIDATION ;

 

/
