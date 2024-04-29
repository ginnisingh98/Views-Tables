--------------------------------------------------------
--  DDL for Package FEM_DIM_HIER_LOADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_DIM_HIER_LOADER_PKG" AUTHID CURRENT_USER AS
/* $Header: FEMDIMHIERLDR.pls 120.0 2006/05/23 07:31:57 kkulkarn noship $ */

  --------------------------------------------------------------------------------
                           -- Declare all global variables --
  --------------------------------------------------------------------------------

     g_log_level_1                CONSTANT  NUMBER      := fnd_log.level_statement;
     g_log_level_2                CONSTANT  NUMBER      := fnd_log.level_procedure;
     g_log_level_3                CONSTANT  NUMBER      := fnd_log.level_event;
     g_log_level_4                CONSTANT  NUMBER      := fnd_log.level_exception;
     g_log_level_5                CONSTANT  NUMBER      := fnd_log.level_error;
     g_log_level_6                CONSTANT  NUMBER      := fnd_log.level_unexpected;

     g_block     	                CONSTANT VARCHAR2(30) := 'FEM_DIM_HIER_LOADER_PKG';

     c_false                      CONSTANT  VARCHAR2(1)  := fnd_api.g_false;
     c_true                       CONSTANT  VARCHAR2(1)  := fnd_api.g_true;
     c_success                    CONSTANT  VARCHAR2(1)  := fnd_api.g_ret_sts_success;
     c_error                      CONSTANT  VARCHAR2(1)  := fnd_api.g_ret_sts_error;
     c_unexp                      CONSTANT  VARCHAR2(1)  := fnd_api.g_ret_sts_unexp_error;
     c_api_version                CONSTANT  NUMBER       := 1.0;

     c_interval                   CONSTANT  NUMBER       := 3.0;
     c_max_wait_time              CONSTANT  NUMBER       := 1200.0;

     c_dim_loader                 CONSTANT  VARCHAR2(10) := 'DIMENSIONS';
     c_hier_loader                CONSTANT  VARCHAR2(15) := 'HIERARCHIES';

  --------------------------------------------------------------------------------
                           -- Declare all pl/sql collections --
  --------------------------------------------------------------------------------

     TYPE number_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
     TYPE char_table IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;

  --------------------------------------------------------------------------------
                         -- Declare all Public procedures/functions --
  --------------------------------------------------------------------------------


     PROCEDURE process_request(errbuf OUT NOCOPY VARCHAR2,
                               retcode OUT NOCOPY VARCHAR2,
                               p_obj_def_id IN NUMBER);


END Fem_Dim_Hier_Loader_Pkg;
 

/
