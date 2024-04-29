--------------------------------------------------------
--  DDL for Package PA_CI_ACTIONS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CI_ACTIONS_UTIL" AUTHID CURRENT_USER AS
/* $Header: PACIACUS.pls 115.9 2003/02/24 20:09:43 atwang noship $ */

 Function action_with_reply(p_ci_action_id in number)
 return varchar2;

PROCEDURE CheckHzPartyName_Or_Id(
        p_resource_id		IN	NUMBER,
	p_resource_name		IN	VARCHAR2,
 	p_date			IN	DATE 	DEFAULT	SYSDATE,
	p_check_id_flag		IN	VARCHAR2,
	p_resource_type_id  	IN  	NUMBER DEFAULT 101,
	x_party_id   	    OUT NOCOPY	NUMBER,
	x_resource_type_id  OUT NOCOPY NUMBER,
    	x_return_status     OUT NOCOPY VARCHAR2,
    	x_msg_count         OUT NOCOPY NUMBER,
    	x_msg_data	    OUT NOCOPY	VARCHAR2 );

Function get_next_ci_action_number( p_ci_id in number)
 return number;

Function get_party_id (
                        p_user_id in number )
 return number;

function GET_CI_OPEN_ACTIONS(
         p_ci_id        IN NUMBER  := NULL) RETURN NUMBER;

function GET_MY_ACTIONS(p_action_status  IN  VARCHAR2,
         p_ci_id        IN NUMBER  := NULL) RETURN NUMBER;

function CHECK_OPEN_ACTIONS_EXIST(p_ci_id	IN NUMBER := NULL)
RETURN VARCHAR2;

function GET_TOP_PARENT_ACTION(p_ci_action_id IN NUMBER)
RETURN NUMBER;

END; -- Package Specification PA_CI_ACTIONS_UTILS

 

/
