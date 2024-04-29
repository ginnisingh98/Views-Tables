--------------------------------------------------------
--  DDL for Package Body JL_BR_AR_BATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AR_BATCH_PKG" as
/* $Header: jlbrrbgb.pls 115.2 2002/11/21 17:44:00 vsidhart ship $ */


/*----------------------------------------------------------------------------*
 |   SETTING AND GETTING GLOBAL PARAMETER 			              |
 *----------------------------------------------------------------------------*/


  PROCEDURE get_batch_id (
        p_request_id IN NUMBER,
        x_batch_id OUT NOCOPY NUMBER) IS

  sqlstmt   VARCHAR2(240);

  BEGIN

    sqlstmt := 'SELECT batch_id FROM jl_br_ar_temp_batch_'||to_char(p_request_id);
    EXECUTE IMMEDIATE sqlstmt INTO x_batch_id;

    sqlstmt := 'DELETE FROM jl_br_ar_temp_batch_'||to_char(p_request_id);
    EXECUTE IMMEDIATE sqlstmt;

    sqlstmt := 'DROP TABLE jl_br_ar_temp_batch_'||to_char(p_request_id);
    EXECUTE IMMEDIATE sqlstmt;

  END;


END JL_BR_AR_BATCH_PKG;

/
