--------------------------------------------------------
--  DDL for Package HZ_IMP_DQM_STAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_IMP_DQM_STAGE" AUTHID CURRENT_USER AS
/* $Header: ARHDISTS.pls 120.5 2005/10/30 03:51:45 appldev noship $ */

PROCEDURE gen_pkg_spec (
	    p_pkg_name 	IN	VARCHAR2,
        p_rule_id	IN	NUMBER
);

PROCEDURE gen_pkg_body (
        p_pkg_name      IN      VARCHAR2,
        p_rule_id	IN	NUMBER
);

PROCEDURE dqm_pre_imp_cleanup (
    p_batch_id  IN NUMBER,
     x_return_status                    OUT NOCOPY    VARCHAR2,
     x_msg_count                        OUT NOCOPY    NUMBER,
     x_msg_data                         OUT NOCOPY    VARCHAR2
);

PROCEDURE dqm_inter_imp_cleanup (
    p_batch_id  IN NUMBER,
     x_return_status                    OUT NOCOPY    VARCHAR2,
     x_msg_count                        OUT NOCOPY    NUMBER,
     x_msg_data                         OUT NOCOPY    VARCHAR2
);

PROCEDURE dqm_post_imp_cleanup (
    p_batch_id  IN NUMBER,
     x_return_status                    OUT NOCOPY    VARCHAR2,
     x_msg_count                        OUT NOCOPY    NUMBER,
     x_msg_data                         OUT NOCOPY    VARCHAR2
) ;

PROCEDURE interface_dup_id(
    retcode  OUT NOCOPY   VARCHAR2,
    err             OUT NOCOPY    VARCHAR2,
    p_batch_id IN   VARCHAR2,
    p_match_rule_id IN  VARCHAR2,
    p_num_of_workers    IN  VARCHAR2
);

PROCEDURE interface_dup_id_worker (
    retcode  OUT NOCOPY   VARCHAR2,
    err             OUT NOCOPY    VARCHAR2,
    p_batch_id IN   VARCHAR2,
    p_match_rule_id IN  VARCHAR2,
    p_worker_num    IN VARCHAR2,
    p_num_of_workers    IN  VARCHAR2,
    p_phase IN  OUT NOCOPY VARCHAR2
);

PROCEDURE POP_INTERFACE_SEARCH_TAB (
    p_batch_id				 IN   NUMBER,
    p_match_rule_id         IN      NUMBER,
    p_from_osr                       IN   VARCHAR2,
    p_to_osr                         IN   VARCHAR2,
    x_return_status                    OUT NOCOPY    VARCHAR2,
    x_msg_count                        OUT NOCOPY    NUMBER,
    x_msg_data                         OUT NOCOPY    VARCHAR2
  );

 PROCEDURE POP_INT_TCA_SEARCH_TAB (
     p_batch_id				 IN   NUMBER,
     p_match_rule_id         IN      NUMBER,
     p_from_osr                       IN   VARCHAR2,
     p_to_osr                         IN   VARCHAR2 ,
     p_batch_mode_flag                 IN VARCHAR2,
     x_return_status                    OUT NOCOPY    VARCHAR2,
     x_msg_count                        OUT NOCOPY    NUMBER,
     x_msg_data                         OUT NOCOPY    VARCHAR2
   );


FUNCTION get_os (p_batch_id IN NUMBER
) RETURN VARCHAR2 ;

  FUNCTION get_owner_name (
    p_object_name IN  VARCHAR2,
    p_object_type IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION EXIST_COL (attr_name IN VARCHAR2,
                entity IN VARCHAR2)
RETURN VARCHAR2;

/*
procedure gen_hz_dqm_imp_debug(
	    p_rule_id	IN	NUMBER,
        x_return_status         OUT NOCOPY     VARCHAR2,
        x_msg_count             OUT NOCOPY     NUMBER,
        x_msg_data              OUT NOCOPY     VARCHAR2
);
*/
END HZ_IMP_DQM_STAGE;


 

/
