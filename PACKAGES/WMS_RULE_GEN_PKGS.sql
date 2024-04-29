--------------------------------------------------------
--  DDL for Package WMS_RULE_GEN_PKGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_RULE_GEN_PKGS" AUTHID CURRENT_USER AS
/* $Header: WMSGNPKS.pls 115.5 2002/12/01 04:58:59 rbande noship $ */

TYPE tbl_long_type IS TABLE OF LONG INDEX BY BINARY_INTEGER;
PROCEDURE GenerateRuleExecPkgs
  (p_api_version      IN   NUMBER                                 ,
   p_init_msg_list    IN   VARCHAR2 DEFAULT fnd_api.g_false	  ,
   p_validation_level IN   NUMBER   DEFAULT fnd_api.g_valid_level_full ,
   x_return_status    OUT  NOCOPY VARCHAR2 				  ,
   x_msg_count        OUT  NOCOPY NUMBER 				  ,
   x_msg_data         OUT  NOCOPY VARCHAR2 				  ,
   p_pick_code        IN   NUMBER   DEFAULT NULL                  ,
   p_put_code         IN   NUMBER   DEFAULT NULL                  ,
   p_task_code        IN   NUMBER   DEFAULT NULL                  ,
   p_label_code       IN   NUMBER   DEFAULT NULL                  ,
   p_CG_code          IN   NUMBER   DEFAULT NULL                  ,
   p_OP_code          IN   NUMBER   DEFAULT NULL                  ,
   p_pkg_type         IN   VARCHAR2 DEFAULT NULL
   );

 PROCEDURE  update_count(
                   p_rule_type IN VARCHAR2
                 , p_count     IN  NUMBER );


FUNCTION  get_count_no_lock(p_rule_type IN VARCHAR2)
RETURN NUMBER ;

FUNCTION  get_count_with_lock(P_RULE_TYPE IN VARCHAR2 )
RETURN NUMBER;




END wms_rule_gen_pkgs;



 

/
