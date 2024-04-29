--------------------------------------------------------
--  DDL for Package FND_ODF_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_ODF_UPD" AUTHID CURRENT_USER AS
/* $Header: fndpoups.pls 115.4 2004/02/11 00:24:54 bhthiaga noship $ */


PROCEDURE odfupd_row (p_selst           IN VARCHAR2,
                      p_updst           IN VARCHAR2,
                      p_errorCode      OUT NOCOPY VARCHAR2,
                      p_retmsg         OUT NOCOPY VARCHAR2);
END fnd_odf_upd;

 

/
