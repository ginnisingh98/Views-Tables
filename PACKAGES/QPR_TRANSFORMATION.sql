--------------------------------------------------------
--  DDL for Package QPR_TRANSFORMATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_TRANSFORMATION" AUTHID CURRENT_USER AS
/* $Header: QPRUTRNS.pls 120.0 2007/10/11 13:07:19 agbennet noship $ */

TYPE num_type      IS TABLE OF Number         INDEX BY BINARY_INTEGER;
TYPE QPRTRANS IS REF CURSOR;

TYPE DIM_REC is RECORD
(dim_value_id num_type);

/* Public Procedures */
procedure transform_process(
                        errbuf              OUT nocopy VARCHAR2,
                        retcode             OUT nocopy  VARCHAR2,
                        p_transf_group_id     IN  NUMBER,
                        p_instance_id     IN  NUMBER,
                        p_from_date in varchar2 default null,
                        p_to_date in varchar2 default null);

function get_null return varchar2;
function get_y return varchar2;
function get_n return varchar2;
function get_num(p_char varchar2) return number;
END QPR_TRANSFORMATION ;

/
