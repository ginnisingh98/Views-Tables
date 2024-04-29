--------------------------------------------------------
--  DDL for Package QPR_LOAD_DIM_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_LOAD_DIM_DATA" AUTHID CURRENT_USER AS
/* $Header: QPRUDLDS.pls 120.0 2007/10/11 13:04:48 agbennet noship $ */

type char240_type is table of varchar2(240) index by binary_integer;
type date_type is table of date index by binary_integer;
type QPRDIMDATA is ref cursor;

TYPE DIM_DATA_REC_TYPE IS RECORD
(
	level1_value		char240_type,
	level1_desc		char240_type,
	level1_attribute1	char240_type,
	level1_attribute2	char240_type,
	level1_attribute3	char240_type,
	level1_attribute4	char240_type,
	level1_attribute5	char240_type,
	level2_value		char240_type,
	level2_desc		char240_type,
	level2_attribute1	char240_type,
	level2_attribute2	char240_type,
	level2_attribute3	char240_type,
	level2_attribute4	char240_type,
	level2_attribute5	char240_type,
	level3_value		char240_type,
	level3_desc		char240_type,
	level3_attribute1	char240_type,
	level3_attribute2	char240_type,
	level3_attribute3	char240_type,
	level3_attribute4	char240_type,
	level3_attribute5	char240_type,
	level4_value		char240_type,
	level4_desc		char240_type,
	level4_attribute1	char240_type,
	level4_attribute2	char240_type,
	level4_attribute3	char240_type,
	level4_attribute4	char240_type,
	level4_attribute5	char240_type,
	level5_value		char240_type,
	level5_desc		char240_type,
	level5_attribute1	char240_type,
	level5_attribute2	char240_type,
	level5_attribute3	char240_type,
	level5_attribute4	char240_type,
	level5_attribute5	char240_type,
	level6_value		char240_type,
	level6_desc		char240_type,
	level6_attribute1	char240_type,
	level6_attribute2	char240_type,
	level6_attribute3	char240_type,
	level6_attribute4	char240_type,
	level6_attribute5	char240_type,
	level7_value		char240_type,
	level7_desc		char240_type,
	level7_attribute1	char240_type,
	level7_attribute2	char240_type,
	level7_attribute3	char240_type,
	level7_attribute4	char240_type,
	level7_attribute5	char240_type,
	level8_value		char240_type,
	level8_desc		char240_type,
	level8_attribute1	char240_type,
	level8_attribute2	char240_type,
	level8_attribute3	char240_type,
	level8_attribute4	char240_type,
	level8_attribute5	char240_type,
	check_date		date_type
);



procedure load_dim_data(
                        errbuf OUT NOCOPY VARCHAR2,
                        retcode OUT NOCOPY VARCHAR2,
			p_dim_code in varchar2,
			p_hier_code in varchar2,
			p_instance_id in number,
			p_start_date in varchar2,
			p_end_date in varchar2);


END QPR_LOAD_DIM_DATA;

/
