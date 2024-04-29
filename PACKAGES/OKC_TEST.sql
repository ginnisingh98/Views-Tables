--------------------------------------------------------
--  DDL for Package OKC_TEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TEST" AUTHID CURRENT_USER AS
/* $Header: OKCTESTS.pls 115.4 2002/02/06 01:04:47 pkm ship       $ */
G_SQLERRM_TOKEN       CONSTANT VARCHAR2(200) := 'SQLerrm';
G_SQLCODE_TOKEN       CONSTANT VARCHAR2(200) := 'SQLcode';
G_UNEXPECTED_ERROR    CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
G_APP_NAME		       CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

PROCEDURE upd_comments(p_api_version    IN NUMBER,
		       p_init_msg_list  IN VARCHAR2,
		       p_old_kid        IN NUMBER,
		       p_new_k_number   IN VARCHAR2,
		       p_new_k_modifier IN VARCHAR2,
		       p_comments       IN VARCHAR2,
		       x_msg_count     OUT NUMBER,
		       x_msg_data      OUT VARCHAR2,
		       x_return_status OUT VARCHAR2
		       );

FUNCTION party_exists (p_kid IN NUMBER
		      ,p_party_name IN VARCHAR2
		      ,p_role IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE proc1(p_val_1 IN VARCHAR2,
  	        p_val_2 IN NUMBER,
	  	p_val_3 IN DATE default null,
		p_api_version IN NUMBER DEFAULT 1.0,
		p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_TRUE,
		x_return_status OUT NOCOPY VARCHAR2,
		x_msg_count OUT NOCOPY NUMBER,
		x_msg_data  OUT NOCOPY VARCHAR2);

FUNCTION func1 RETURN VARCHAR2;

End OKC_TEST;

 

/
