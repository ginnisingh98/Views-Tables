--------------------------------------------------------
--  DDL for Package FA_ADJUSTMENTS_T_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_ADJUSTMENTS_T_PKG" AUTHID CURRENT_USER AS
/* $Header: fapadjts.pls 120.0.12010000.3 2009/03/27 02:51:58 bridgway ship $   */

 PROCEDURE prepare(w_clause in varchar2, p_batch_id in number, action_flag in varchar2);

 END FA_ADJUSTMENTS_T_PKG;

/
