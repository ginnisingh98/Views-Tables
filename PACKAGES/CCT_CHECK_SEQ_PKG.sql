--------------------------------------------------------
--  DDL for Package CCT_CHECK_SEQ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_CHECK_SEQ_PKG" AUTHID CURRENT_USER AS
/* $Header: cctcksqs.pls 120.0.12010000.1 2008/07/25 23:41:47 appldev ship $ */

   PROCEDURE check_sequence  (
        table_name      IN VARCHAR2,
        column_name     IN VARCHAR2,
		sequence_name   IN VARCHAR2,
		cct_schema      IN VARCHAR2
		);

END cct_check_seq_pkg;

/
