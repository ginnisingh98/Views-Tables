--------------------------------------------------------
--  DDL for Package CN_EXT_TBL_MAP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_EXT_TBL_MAP_PVT" AUTHID CURRENT_USER AS
/* $Header: cnvextbs.pls 115.6 2002/11/21 21:13:08 hlchen ship $ */

TYPE table_mapping_rec_type  IS RECORD
  (name                      cn_calc_ext_tables.name%TYPE,
   description               cn_calc_ext_tables.description%TYPE,
   internal_table_id         cn_calc_ext_tables.internal_table_id%TYPE,
   external_table_id         cn_calc_ext_tables.external_table_id%TYPE,
   used_flag                 cn_calc_ext_tables.used_flag%TYPE,
   external_table_name       cn_calc_ext_tables.external_table_name%TYPE,
   alias                     cn_calc_ext_tables.alias%TYPE,
   schema                    cn_calc_ext_tables.schema%TYPE,
   attribute_category        cn_calc_ext_tables.attribute_category%TYPE,
   attribute1                cn_calc_ext_tables.attribute1%TYPE,
   attribute2                cn_calc_ext_tables.attribute2%TYPE,
   attribute3                  cn_calc_ext_tables.attribute3%TYPE,
   attribute4                  cn_calc_ext_tables.attribute4%TYPE,
   attribute5                  cn_calc_ext_tables.attribute5%TYPE,
   attribute6                  cn_calc_ext_tables.attribute6%TYPE,
   attribute7                  cn_calc_ext_tables.attribute7%TYPE,
   attribute8                  cn_calc_ext_tables.attribute8%TYPE,
   attribute9                  cn_calc_ext_tables.attribute9%TYPE,
   attribute10                 cn_calc_ext_tables.attribute10%TYPE,
   attribute11                 cn_calc_ext_tables.attribute11%TYPE,
   attribute12                 cn_calc_ext_tables.attribute12%TYPE,
   attribute13                 cn_calc_ext_tables.attribute13%TYPE,
   attribute14                 cn_calc_ext_tables.attribute14%TYPE,
   attribute15                 cn_calc_ext_tables.attribute15%TYPE
 );

TYPE column_mapping_rec  IS RECORD(
  calc_ext_table_id             cn_calc_ext_tbl_dtls.calc_ext_table_id%TYPE   ,
  external_column_id           cn_calc_ext_tbl_dtls.external_column_id%TYPE ,
  internal_column_id           cn_calc_ext_tbl_dtls.internal_column_id%TYPE ,
  attribute_category           cn_calc_ext_tbl_dtls.attribute_category%TYPE ,
  attribute1                   cn_calc_ext_tbl_dtls.attribute1%TYPE         ,
  attribute2                   cn_calc_ext_tbl_dtls.attribute2%TYPE         ,
  attribute3                   cn_calc_ext_tbl_dtls.attribute3%TYPE         ,
  attribute4                   cn_calc_ext_tbl_dtls.attribute4%TYPE         ,
  attribute5                   cn_calc_ext_tbl_dtls.attribute5%TYPE         ,
  attribute6                   cn_calc_ext_tbl_dtls.attribute6%TYPE         ,
  attribute7                   cn_calc_ext_tbl_dtls.attribute7%TYPE         ,
  attribute8                   cn_calc_ext_tbl_dtls.attribute8%TYPE         ,
  attribute9                   cn_calc_ext_tbl_dtls.attribute9%TYPE         ,
  attribute10                  cn_calc_ext_tbl_dtls.attribute10%TYPE        ,
  attribute11                  cn_calc_ext_tbl_dtls.attribute11%TYPE        ,
  attribute12                  cn_calc_ext_tbl_dtls.attribute12%TYPE        ,
  attribute13                  cn_calc_ext_tbl_dtls.attribute13%TYPE        ,
  attribute14                  cn_calc_ext_tbl_dtls.attribute14%TYPE        ,
  attribute15                  cn_calc_ext_tbl_dtls.attribute15%TYPE
);

TYPE  column_mapping_tbl_type  IS TABLE OF column_mapping_rec
  INDEX BY BINARY_INTEGER;

table_mapping_rec	            table_mapping_rec_type ;
column_mapping_tbl                  column_mapping_tbl_type;

PROCEDURE create_external_mapping(
	x_return_status      OUT NOCOPY VARCHAR2                ,
	x_msg_count          OUT NOCOPY NUMBER                  ,
	x_msg_data           OUT NOCOPY VARCHAR2                ,
	x_loading_status     OUT NOCOPY VARCHAR2                ,
	p_api_version        IN  NUMBER                  ,
	p_init_msg_list      IN  VARCHAR2                ,
	p_commit             IN  VARCHAR2                ,
	p_validation_level   IN  VARCHAR2                ,
	p_table_mapping_rec  IN  table_mapping_rec_type  ,
	p_column_mapping_tbl IN  column_mapping_tbl_type ,
	x_calc_ext_table_id  OUT NOCOPY NUMBER
	);
END  cn_ext_tbl_map_pvt;

 

/
