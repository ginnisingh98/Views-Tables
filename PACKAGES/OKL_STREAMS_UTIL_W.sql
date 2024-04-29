--------------------------------------------------------
--  DDL for Package OKL_STREAMS_UTIL_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_STREAMS_UTIL_W" AUTHID CURRENT_USER as
  /* $Header: OKLESULS.pls 120.1 2005/10/30 03:16:51 appldev noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy okl_streams_util.log_msg_tbl, a0 JTF_VARCHAR2_TABLE_4000);
  procedure rosetta_table_copy_out_p1(t okl_streams_util.log_msg_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_4000);

  procedure rosetta_table_copy_in_p21(t out nocopy okl_streams_util.clobtabtyp, a0 JTF_CLOB_TABLE);
  procedure rosetta_table_copy_out_p21(t okl_streams_util.clobtabtyp, a0 out nocopy JTF_CLOB_TABLE);

  procedure rosetta_table_copy_in_p22(t out nocopy okl_streams_util.datetabtyp, a0 JTF_DATE_TABLE);
  procedure rosetta_table_copy_out_p22(t okl_streams_util.datetabtyp, a0 out nocopy JTF_DATE_TABLE);

  procedure rosetta_table_copy_in_p23(t out nocopy okl_streams_util.numbertabtyp, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p23(t okl_streams_util.numbertabtyp, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p24(t out nocopy okl_streams_util.number15tabtyp, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p24(t okl_streams_util.number15tabtyp, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p25(t out nocopy okl_streams_util.var10tabtyp, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p25(t okl_streams_util.var10tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p26(t out nocopy okl_streams_util.var12tabtyp, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p26(t okl_streams_util.var12tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p27(t out nocopy okl_streams_util.var120tabtyp, a0 JTF_VARCHAR2_TABLE_200);
  procedure rosetta_table_copy_out_p27(t okl_streams_util.var120tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_200);

  procedure rosetta_table_copy_in_p28(t out nocopy okl_streams_util.var15tabtyp, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p28(t okl_streams_util.var15tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p29(t out nocopy okl_streams_util.var150tabtyp, a0 JTF_VARCHAR2_TABLE_200);
  procedure rosetta_table_copy_out_p29(t okl_streams_util.var150tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_200);

  procedure rosetta_table_copy_in_p30(t out nocopy okl_streams_util.var1995tabtyp, a0 JTF_VARCHAR2_TABLE_2000);
  procedure rosetta_table_copy_out_p30(t okl_streams_util.var1995tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_2000);

  procedure rosetta_table_copy_in_p31(t out nocopy okl_streams_util.var24tabtyp, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p31(t okl_streams_util.var24tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p32(t out nocopy okl_streams_util.var200tabtyp, a0 JTF_VARCHAR2_TABLE_200);
  procedure rosetta_table_copy_out_p32(t okl_streams_util.var200tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_200);

  procedure rosetta_table_copy_in_p33(t out nocopy okl_streams_util.var240tabtyp, a0 JTF_VARCHAR2_TABLE_300);
  procedure rosetta_table_copy_out_p33(t okl_streams_util.var240tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_300);

  procedure rosetta_table_copy_in_p34(t out nocopy okl_streams_util.var3tabtyp, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p34(t okl_streams_util.var3tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p35(t out nocopy okl_streams_util.var30tabtyp, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p35(t okl_streams_util.var30tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p36(t out nocopy okl_streams_util.var300tabtyp, a0 JTF_VARCHAR2_TABLE_300);
  procedure rosetta_table_copy_out_p36(t okl_streams_util.var300tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_300);

  procedure rosetta_table_copy_in_p37(t out nocopy okl_streams_util.var40tabtyp, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p37(t okl_streams_util.var40tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p38(t out nocopy okl_streams_util.var450tabtyp, a0 JTF_VARCHAR2_TABLE_500);
  procedure rosetta_table_copy_out_p38(t okl_streams_util.var450tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_500);

  procedure rosetta_table_copy_in_p39(t out nocopy okl_streams_util.var50tabtyp, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p39(t okl_streams_util.var50tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p40(t out nocopy okl_streams_util.var600tabtyp, a0 JTF_VARCHAR2_TABLE_600);
  procedure rosetta_table_copy_out_p40(t okl_streams_util.var600tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_600);

  procedure rosetta_table_copy_in_p41(t out nocopy okl_streams_util.var75tabtyp, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p41(t okl_streams_util.var75tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p42(t out nocopy okl_streams_util.var90tabtyp, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p42(t okl_streams_util.var90tabtyp, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p43(t out nocopy okl_streams_util.okl_strm_type_id_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p43(t okl_streams_util.okl_strm_type_id_tbl_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure log_message(p_msgs_tbl JTF_VARCHAR2_TABLE_4000
    , p_translate  VARCHAR2
    , p_file_name  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
end okl_streams_util_w;

 

/
