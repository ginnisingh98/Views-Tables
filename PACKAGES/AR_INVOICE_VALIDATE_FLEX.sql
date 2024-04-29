--------------------------------------------------------
--  DDL for Package AR_INVOICE_VALIDATE_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_INVOICE_VALIDATE_FLEX" AUTHID CURRENT_USER AS
/* $Header: ARXVINFS.pls 120.2.12010000.2 2008/12/02 12:09:32 npanchak ship $ */


TYPE flex_context_type IS TABLE OF
       fnd_descr_flex_contexts.descriptive_flex_context_code%type
            INDEX by binary_integer;

TYPE flex_num_type IS TABLE OF number INDEX by binary_integer;

TYPE seg_value_type IS TABLE OF
       ra_interface_lines.interface_line_attribute1%type
            INDEX by binary_integer;

TYPE cursor_tbl_type IS
       TABLE OF  BINARY_INTEGER
       INDEX BY  BINARY_INTEGER;

TYPE interface_hdr_rec_type IS RECORD(
    interface_header_context        VARCHAR2(30) DEFAULT NULL,
    /***** Updated fix for Bug 7151383 *******/
    interface_header_attribute1     VARCHAR2(150) DEFAULT NULL,
    interface_header_attribute2              VARCHAR2(150) DEFAULT NULL,
    interface_header_attribute3            VARCHAR2(150) DEFAULT NULL,
    interface_header_attribute4            VARCHAR2(150) DEFAULT NULL,
    interface_header_attribute5            VARCHAR2(150) DEFAULT NULL,
    interface_header_attribute6            VARCHAR2(150) DEFAULT NULL,
    interface_header_attribute7            VARCHAR2(150) DEFAULT NULL,
    interface_header_attribute8            VARCHAR2(150) DEFAULT NULL,
    interface_header_attribute9            VARCHAR2(150) DEFAULT NULL,
    interface_header_attribute10           VARCHAR2(150) DEFAULT NULL,
    interface_header_attribute11           VARCHAR2(150) DEFAULT NULL,
    interface_header_attribute12           VARCHAR2(150) DEFAULT NULL,
    interface_header_attribute13           VARCHAR2(150) DEFAULT NULL,
    interface_header_attribute14           VARCHAR2(150) DEFAULT NULL,
    interface_header_attribute15           VARCHAR2(150) DEFAULT NULL);
    /***** Changes End Here *******/

TYPE interface_line_rec_type IS RECORD(
    interface_line_context        VARCHAR2(30) DEFAULT NULL,
    /***** Updated fix for Bug 7151383 *******/
    interface_line_attribute1     	 VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute2            VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute3            VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute4            VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute5            VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute6            VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute7            VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute8            VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute9            VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute10           VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute11           VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute12           VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute13           VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute14           VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute15           VARCHAR2(150) DEFAULT NULL);
    /***** Changes End Here *******/

pg_char_dummy    varchar2(10) := '!#$%^&*';
pg_num_segs      flex_num_type;        --  number of segments for each context
pg_flex_contexts flex_context_type;    --  flex context values
pg_ctl_cursors   cursor_tbl_type;      --  cursors for ra_customer_trx_lines
pg_ril_cursors   cursor_tbl_type;      --  cursors for ra_interface_lines
pg_active_segs   flex_num_type;        --  active segment numbers
pg_start_loc     flex_num_type;        --  for a context, index to first
                                       --  segment in pg_active_segs
pg_ctx_count     number;               --  total number of contexts


PROCEDURE validate_desc_flex (
    p_validation_type       IN  VARCHAR2,
    x_errmsg                OUT NOCOPY VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2 );

END AR_INVOICE_VALIDATE_FLEX;

/
