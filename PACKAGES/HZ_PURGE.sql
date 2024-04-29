--------------------------------------------------------
--  DDL for Package HZ_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PURGE" AUTHID CURRENT_USER AS
/* $Header: ARHPURGS.pls 120.6 2005/06/16 21:15:44 jhuang noship $ */

PROCEDURE GENERATE_BODY
(p_init_msg_list           	             IN         	VARCHAR2 := FND_API.G_FALSE,
 x_return_status                         OUT NOCOPY    VARCHAR2,
 x_msg_count                             OUT NOCOPY    NUMBER,
 x_msg_data                              OUT NOCOPY    VARCHAR2);
PROCEDURE IDENTIFY_PURGE_PARTIES(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2, batchid varchar2, con_prg VARCHAR2, regid_proc VARCHAR2 DEFAULT 'F');
/*PROCEDURE check_single_party_trans
(p_init_msg_list           	             IN            VARCHAR2 := FND_API.G_FALSE,
 x_return_status                         OUT NOCOPY    VARCHAR2,
 x_msg_count                             OUT NOCOPY    NUMBER,
 x_msg_data                              OUT NOCOPY    VARCHAR2,
 partyid number,
 allow_purge OUT NOCOPY    VARCHAR2);*/
PROCEDURE PURGE_PARTIES(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2, batchid number, con_prg VARCHAR2);
PROCEDURE PURGE_PARTY
(p_init_msg_list           	             IN            VARCHAR2 := FND_API.G_FALSE,
 x_return_status                         OUT NOCOPY    VARCHAR2,
 x_msg_count                             OUT NOCOPY    NUMBER,
 x_msg_data                              OUT NOCOPY    VARCHAR2,
 p_party_id NUMBER);
FUNCTION logerror RETURN VARCHAR2;
PROCEDURE log(message IN VARCHAR2, con_prg IN boolean, newline IN BOOLEAN DEFAULT TRUE);
FUNCTION get_col_type( p_table VARCHAR2, p_column VARCHAR2, p_app_name  VARCHAR2) RETURN VARCHAR2;
FUNCTION has_context(proc VARCHAR2) RETURN BOOLEAN;
FUNCTION has_index(entity_name VARCHAR2, column_name VARCHAR2, app_name VARCHAR2, join_clause VARCHAR2) RETURN BOOLEAN ;
PROCEDURE delete_template(e1 VARCHAR2, fk1 VARCHAR2,pk1 VARCHAR2,j1 VARCHAR2, pe1 VARCHAR2, fk_data_typ1 VARCHAR2, first VARCHAR2, concat_string OUT NOCOPY VARCHAR2, cnt NUMBER);
PROCEDURE post_app_logic(appid NUMBER, single_party VARCHAR2, check_flag boolean);
FUNCTION get_app_name(appid NUMBER) RETURN VARCHAR2;
PROCEDURE populate_fk_datatype;

END;

 

/
