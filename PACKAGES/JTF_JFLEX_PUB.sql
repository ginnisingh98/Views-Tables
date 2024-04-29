--------------------------------------------------------
--  DDL for Package JTF_JFLEX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_JFLEX_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfflexs.pls 120.2 2005/10/25 05:20:19 psanyal ship $ */
  c_valueset_valtype_independent CONSTANT VARCHAR(20) := 'I';
  c_valueset_valtype_none        CONSTANT VARCHAR(20) := 'N';

  procedure Get_Flexfield(p_application     IN  varchar2,
                          p_flexfield_name  IN  varchar2,
                          name 		 OUT NOCOPY /* file.sql.39 change */ varchar2,
			  apps_name 	 OUT NOCOPY /* file.sql.39 change */ varchar2,
			  nr_segs 	 OUT NOCOPY /* file.sql.39 change */ number,
			  dfs_name 	 OUT NOCOPY /* file.sql.39 change */ jtf_varchar2_table_300,
			  dfs_dbcolumn_name OUT NOCOPY /* file.sql.39 change */ jtf_varchar2_table_300,
			  dfs_default_value OUT NOCOPY /* file.sql.39 change */ jtf_varchar2_table_300,
			  dfs_prompt	 OUT NOCOPY /* file.sql.39 change */ jtf_varchar2_table_300,
			  dfs_max_size	 OUT NOCOPY /* file.sql.39 change */ jtf_number_table,
			  dfs_min_value	 OUT NOCOPY /* file.sql.39 change */ jtf_varchar2_table_300,
			  dfs_max_value	 OUT NOCOPY /* file.sql.39 change */ jtf_varchar2_table_300,
			  dfs_mandatory	 OUT NOCOPY /* file.sql.39 change */ jtf_varchar2_table_100,
			  dfs_default_type OUT NOCOPY /* file.sql.39 change */ jtf_varchar2_table_100,
			  dfs_valtype	 OUT NOCOPY /* file.sql.39 change */ jtf_varchar2_table_100,
			  dfs_lov_id	 OUT NOCOPY /* file.sql.39 change */ jtf_number_table,
			  dfs_format_type OUT NOCOPY /* file.sql.39 change */ jtf_varchar2_table_100,
			  dfs_display_size OUT NOCOPY /* file.sql.39 change */ jtf_number_table);

  procedure Get_ValueSet(p_valueset_id      IN  number,
                         x_value            OUT NOCOPY /* file.sql.39 change */ jtf_varchar2_table_300,
                         x_meaning          OUT NOCOPY /* file.sql.39 change */ jtf_varchar2_table_300);




end JTF_JFLEX_PUB;

 

/
