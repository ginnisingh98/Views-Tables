--------------------------------------------------------
--  DDL for Package OPI_DBI_REP_UOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_REP_UOM_PKG" AUTHID CURRENT_USER AS
/* $Header: OPIDUMCNS.pls 120.0 2005/05/24 19:19:21 appldev noship $ */


/**************************************
* Package Level Constants
**************************************/

COL_WIDTH  CONSTANT NUMBER         := 25;
LINE_WIDTH CONSTANT NUMBER         := 80;
LINE       CONSTANT VARCHAR2(30)   := '---------------';
NEWLINE    CONSTANT VARCHAR2(30)   := '
';

/**************************************
* Package Functions and Procedures
**************************************/


FUNCTION  uom_convert (p_item_id    number,
                   p_precision      number,
                   p_from_quantity  number,
                   p_from_code      varchar2,
                   p_to_code        varchar2) RETURN number PARALLEL_ENABLE;


FUNCTION  get_reporting_uom (p_measure_code varchar2) RETURN varchar2 PARALLEL_ENABLE;

FUNCTION  get_w RETURN varchar2 PARALLEL_ENABLE;

FUNCTION  get_v RETURN varchar2 PARALLEL_ENABLE;

FUNCTION  get_d RETURN varchar2 PARALLEL_ENABLE;

PROCEDURE err_msg_header;

PROCEDURE err_msg_footer;

PROCEDURE err_msg_missing_uoms (p_from_uom_code   varchar2,
                                p_to_uom_code     varchar2);

PROCEDURE err_msg_header_spec (p_measure_code IN VARCHAR2,
                               p_entity_type IN VARCHAR2);


END opi_dbi_rep_uom_pkg;

 

/
