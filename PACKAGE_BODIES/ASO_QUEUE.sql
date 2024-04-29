--------------------------------------------------------
--  DDL for Package Body ASO_QUEUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_QUEUE" AS
/* $Header: asoqinsb.pls 115.4 2002/12/07 19:50:37 hagrawal ship $ */


-- ---------------------------------------------------------
-- Declare Local Variables
-- ---------------------------------------------------------
l_schema             varchar2(30);
l_status             varchar2(1);
l_industry           varchar2(1);

-- ---------------------------------------------------------
-- Initialize Package Globals
-- ---------------------------------------------------------

BEGIN
  if (FND_INSTALLATION.get_app_info('ASO', l_status, l_industry, l_schema)) then
      ASO_QUEUE.ASO_OF_Q :=  l_schema||'.'||'ASO_OF_Q';
      ASO_QUEUE.ASO_OF_Q_E :=  l_schema||'.'||'ASO_OF_Q_E';
      ASO_QUEUE.ASO_OF_EXCP_Q := l_schema||'.'||'ASO_OF_EXCP_Q';
      ASO_QUEUE.ASO_OF_EXCP_Q_E := l_schema||'.'||'ASO_OF_EXCP_Q_E';
  else
      raise_application_error(-20000,
                               'Failed to get information for product'||
                               'ASO');
  end if;

END ASO_QUEUE;

/
