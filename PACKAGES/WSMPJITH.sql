--------------------------------------------------------
--  DDL for Package WSMPJITH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSMPJITH" AUTHID CURRENT_USER AS
/* $Header: WSMJITHS.pls 115.3 2000/09/20 19:59:26 pkm ship      $ */
PROCEDURE copy_to_wjsi	(
		/*BA#LIIP*/
					p_header_id	IN NUMBER,
		/*EA#LIIP*/
		/*BD#LIIP*/
		/*
					p_interface_id IN NUMBER,
		*/
		/*ED#LIIP*/
					p_wjsi_group_id	OUT NUMBER,
					x_err_code	OUT NUMBER,
					x_err_msg	OUT VARCHAR2	);

PROCEDURE delete_from_wjsi ( 		p_wjsi_group_id	IN NUMBER,
					x_err_code	OUT NUMBER,
					x_err_msg	OUT VARCHAR2	);

END WSMPJITH;

 

/
