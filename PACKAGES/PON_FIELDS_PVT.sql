--------------------------------------------------------
--  DDL for Package PON_FIELDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_FIELDS_PVT" AUTHID CURRENT_USER AS
/* $Header: PONFMFES.pls 120.1 2006/04/13 05:37:27 sdewan noship $ */

PROCEDURE  insert_field(p_code          IN      VARCHAR2,
                        p_name          IN      VARCHAR2,
                        p_description   IN      VARCHAR2,
                        p_result        OUT     NOCOPY  NUMBER,
                        p_err_code      OUT     NOCOPY  VARCHAR2,
                        p_err_msg       OUT     NOCOPY  VARCHAR2);

PROCEDURE delete_field (p_code IN VARCHAR2,
                        p_result OUT NOCOPY NUMBER,
                        p_err_code OUT NOCOPY VARCHAR2,
                        p_err_msg OUT NOCOPY VARCHAR2);

PROCEDURE  update_field(p_code          IN      VARCHAR2,
                                p_name          IN      VARCHAR2,
                                p_description   IN      VARCHAR2,
                                p_lastUpdate    IN      DATE,
				p_old_code	IN	VARCHAR2,
                                p_result        OUT     NOCOPY  NUMBER,
                                p_err_code      OUT     NOCOPY  VARCHAR2,
                                p_err_msg       OUT     NOCOPY  VARCHAR2);
PROCEDURE  add_language;

END PON_FIELDS_PVT;

 

/
