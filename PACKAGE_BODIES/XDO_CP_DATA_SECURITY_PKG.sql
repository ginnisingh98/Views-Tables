--------------------------------------------------------
--  DDL for Package Body XDO_CP_DATA_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDO_CP_DATA_SECURITY_PKG" AS
----$Header: XDODSCRB.pls 120.2 2007/10/23 00:57:25 bgkim noship $
--+===========================================================================+
--|                    Copyright (c) 2006 Oracle Corporation                  |
--|                      Redwood Shores, California, USA                      |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :                                                               |
--|      XDODSCRB.pls                                                         |
--|                                                                           |
--|  DESCRIPTION:                                                             |
--|      This package is used to get the Concurrent requests based on the     |
--|      data security                                                        |
--|                                                                           |
--|                                                                           |
--|  HISTORY:                                                                 |
--|      05/22/2006     hidekoji          Created                             |
--+===========================================================================+

g_package_name          VARCHAR2(100):='oracle.apps.xdo.xdo_cp_data_security.';
g_success_status        VARCHAR2(1)  :='T';
g_result_yes            VARCHAR2(1)  :='Y';
g_result_no             VARCHAR2(1)  :='N';

--==========================================================================
--  FUNCTION NAME:
--
--    get_concurrent_request_ids                 Public
--
--  DESCRIPTION:
--
--      This function gets the request IDs that can be viewed.
--      and stores them into global temporary table
--
--  PARAMETERS:
--      In:
--
--
--  DESIGN REFERENCES:
--
--
--  CHANGE HISTORY:
--	    05/22/2006     hidekoji             Created
--===========================================================================
FUNCTION get_concurrent_request_ids RETURN  VARCHAR2
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_procedure_name         VARCHAR2(100)   :='get_concurrent_request_ids';
  l_exist_cur              VARCHAR2(32767);
  l_predicate              VARCHAR2(32000);
  l_return_status          VARCHAR2(1);
  l_result                 VARCHAR2(1);
  l_separator              VARCHAR2(10);

  TYPE t_num_tab           IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_request_id_tab         t_num_tab;

BEGIN
    --log for debug
  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)  THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                    ,g_package_name||l_procedure_name||'.begin'
                    ,'Enter procedure');
  END IF;  --( l_proc_level >= l_dbg_level )

  -- Delete from Global Temporary table
  delete xdo_concurrent_requests_gt;


  -- Call fnd_data_security.get_security_predicate to get the where clause
  FND_DATA_SECURITY.get_security_predicate(p_api_version   => 1.0
                                          ,p_function      => 'FND_CP_REQ_VIEW'
                                          ,p_object_name   => 'FND_CONCURRENT_REQUESTS'
                                          ,x_predicate     => l_predicate
                                          ,x_return_status => l_return_status);

  IF l_return_status = g_success_status THEN

     l_exist_cur  :=  'SELECT  request_id '||
                      '  FROM  fnd_concurrent_requests '||
                      ' WHERE  '|| l_predicate;

     EXECUTE immediate l_exist_cur BULK COLLECT INTO l_request_id_tab;


     IF SQL%NOTFOUND THEN

            l_result := g_result_no;

     ELSE

          FOR i in l_request_id_tab.first..l_request_id_tab.last LOOP

              insert into xdo_concurrent_requests_gt(CONC_REQUEST_ID)
              values (l_request_id_tab(i));

          END LOOP;
          commit;

          l_result := g_result_yes;

     END IF;


   ELSE -- If FND_DATA_SECURITY.get_security_predicate fails, then return ''

          l_result := g_result_no;

   END IF;

          return l_result;

EXCEPTION

 WHEN OTHERS THEN

  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)  THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                    ,g_package_name||l_procedure_name||':'
                    ,SQLERRM);
  END IF;

  return g_result_no;

END;

END XDO_CP_DATA_SECURITY_PKG;

/
