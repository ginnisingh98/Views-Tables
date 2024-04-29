--------------------------------------------------------
--  DDL for Package Body IEX_STRATEGY_TYPE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_STRATEGY_TYPE_PUB" AS
/* $Header: iexpsttb.pls 120.0 2004/01/24 03:20:03 appldev noship $ */


G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IEX_STRATEGY_TYPE_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexpsttb.pls';

l_msg_data                    VARCHAR2(32767);
l_strategy_rec               IEX_STRATEGY_TYPE_PUB.STRY_CNT_REC_TYPE :=
                                    IEX_STRATEGY_TYPE_PUB.INST_STRY_CNT_REC;

l_strategy_tbl               IEX_STRATEGY_TYPE_PUB.STRY_CNT_TBL_TYPE :=
                                    IEX_STRATEGY_TYPE_PUB.INST_STRY_CNT_TBL;

BEGIN
      -- Standard Start of API savepoint
   null;
END;

/
